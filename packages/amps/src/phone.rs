//! Private phone playback. No phone signal is inserted into the VAC patchbay.
use anyhow::{bail, Context, Result};
use serde::{Deserialize, Serialize};
use std::{
	path::Path,
	sync::{
		atomic::{AtomicBool, Ordering},
		mpsc, Arc, Mutex,
	},
	thread,
	time::Duration,
};

#[cfg(any(windows, test))]
mod buffer;
#[cfg(windows)]
mod relay;
#[cfg(windows)]
mod windows;

#[derive(Clone, Debug, Default, Deserialize, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Device {
	pub id: String,
	pub name: String,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq, Eq)]
#[serde(default, rename_all = "camelCase")]
pub struct Settings {
	pub schema_version: u32,
	pub device_id: Option<String>,
	pub auto_connect: bool,
	pub buffer_ms: u32,
}
impl Default for Settings {
	fn default() -> Self {
		Self {
			schema_version: 1,
			device_id: None,
			auto_connect: false,
			buffer_ms: 200,
		}
	}
}
#[cfg(any(windows, test))]
impl Settings {
	fn load(path: &Path) -> Result<Self> {
		let settings: Self = match std::fs::read_to_string(path) {
			Ok(text) => toml::from_str(&text).context("Invalid phone settings; retained unchanged")?,
			Err(e) if e.kind() == std::io::ErrorKind::NotFound => Self::default(),
			Err(e) => return Err(e.into()),
		};
		crate::control::check_schema(settings.schema_version)?;
		check_buffer_ms(settings.buffer_ms)?;
		Ok(settings)
	}
	fn save(&self, path: &Path) -> Result<()> {
		crate::control::atomic_write(path, toml::to_string_pretty(self)?.as_bytes())
	}
}

#[derive(Clone, Debug, Serialize, PartialEq, Eq)]
#[serde(rename_all = "camelCase")]
pub struct Snapshot {
	pub supported: bool,
	pub devices: Vec<Device>,
	pub settings: Settings,
	pub wanted: bool,
	pub connected: bool,
	pub phase: String,
	pub output: Option<Device>,
	pub error: Option<String>,
}
impl Default for Snapshot {
	fn default() -> Self {
		Self {
			supported: cfg!(windows),
			devices: vec![],
			settings: Settings::default(),
			wanted: false,
			connected: false,
			phase: "off".into(),
			output: None,
			error: None,
		}
	}
}

#[derive(Clone, Debug, Deserialize)]
#[serde(rename_all = "camelCase", deny_unknown_fields)]
pub struct Request {
	pub action: String,
	pub device_id: Option<String>,
	pub auto_connect: Option<bool>,
	pub buffer_ms: Option<u32>,
}

fn check_buffer_ms(value: u32) -> Result<()> {
	if !(50..=500).contains(&value) {
		bail!("Phone buffer must be between 50 and 500 ms");
	}
	Ok(())
}

enum Message {
	Output(Option<Device>),
	Edit(Request, mpsc::Sender<std::result::Result<(), String>>),
	Restart,
	#[cfg(windows)]
	Discover,
	Stop,
}

/// The tray owns this receiver; closing its window does not stop phone playback.
pub struct Service {
	sender: mpsc::Sender<Message>,
	snapshot: Arc<Mutex<Snapshot>>,
	meter: Arc<Mutex<Option<crate::MeterReading>>>,
	worker: Mutex<Option<thread::JoinHandle<()>>>,
	stop: Arc<AtomicBool>,
}
impl Service {
	pub fn start(config_path: &Path) -> Self {
		let (sender, receiver) = mpsc::channel();
		let snapshot = Arc::new(Mutex::new(Snapshot::default()));
		let meter = Arc::new(Mutex::new(None));
		let path = config_path.with_file_name("phone.toml");
		let state = snapshot.clone();
		let levels = meter.clone();
		let stop = Arc::new(AtomicBool::new(false));
		let stopped = stop.clone();
		#[cfg(windows)]
		let wakeup = sender.clone();
		let worker = thread::Builder::new()
			.name("amps-phone".into())
			.spawn(move || {
				#[cfg(windows)]
				windows::run(path, receiver, state, levels, stopped, wakeup);
				#[cfg(not(windows))]
				{
					let _ = (path, levels, stopped);
					while let Ok(message) = receiver.recv() {
						match message {
							Message::Stop => break,
							Message::Edit(request, reply) => {
								let _ = request;
								let _ = reply.send(Err("Phone playback requires Windows".into()));
							}
							Message::Output(output) => {
								let _ = output;
							}
							_ => {
								let _ = &state;
							}
						}
					}
				}
			})
			.expect("could not start the AMPS phone receiver");
		Self {
			sender,
			snapshot,
			meter,
			worker: Mutex::new(Some(worker)),
			stop,
		}
	}
	pub fn snapshot(&self) -> Snapshot {
		self.snapshot.lock().unwrap().clone()
	}
	pub fn meter(&self) -> Option<crate::MeterReading> {
		self.meter.lock().unwrap().clone()
	}
	pub fn output(&self, output: Option<Device>) {
		let _ = self.sender.send(Message::Output(output));
	}
	pub fn edit(&self, request: Request) -> Result<()> {
		if let Some(value) = request.buffer_ms {
			check_buffer_ms(value)?;
		}
		if !["connect", "disconnect", "refresh", "settings"].contains(&request.action.as_str()) {
			bail!("Unknown phone action");
		}
		let (sender, receiver) = mpsc::channel();
		self.sender.send(Message::Edit(request, sender))?;
		receiver
			.recv_timeout(Duration::from_secs(45))
			.context("Phone command timed out")?
			.map_err(anyhow::Error::msg)
	}
	pub fn restart(&self) {
		let _ = self.sender.send(Message::Restart);
	}
	pub fn stop(&self) {
		self.stop.store(true, Ordering::Release);
		let _ = self.sender.send(Message::Stop);
		if let Some(worker) = self.worker.lock().unwrap().take() {
			let _ = worker.join();
		}
	}
}
impl Drop for Service {
	fn drop(&mut self) {
		self.stop();
	}
}

/// Only a unique currently applied listening endpoint is eligible. Never use a
/// Windows default, desired-but-not-applied selection, or arbitrary VAC endpoint.
pub fn applied_output(
	graph: &crate::GraphSnapshot,
	runtime: Option<&crate::control::Status>,
) -> Option<Device> {
	let runtime = runtime.filter(|r| r.online && r.applied_revision.is_some())?;
	let mut matches = graph
		.output_devices
		.iter()
		.filter(|d| d.name.eq_ignore_ascii_case(&runtime.output_name));
	let device = matches.next()?;
	if matches.next().is_some() {
		return None;
	}
	Some(Device {
		id: device.id.clone(),
		name: device.name.clone(),
	})
}

/// Match device-instance identity, not user-visible names or Bluetooth addresses.
#[cfg(any(windows, test))]
fn instance_id(interface: &str) -> Result<String> {
	let parts: Vec<_> = interface
		.strip_prefix(r"\\?\")
		.context("Unexpected phone interface")?
		.split('#')
		.collect();
	if parts.len() != 4
		|| !parts[0].eq_ignore_ascii_case("BTHENUM")
		|| !parts[3].to_ascii_uppercase().ends_with(r"\SNK")
	{
		bail!("Unsupported Bluetooth audio interface; refusing to guess a capture endpoint");
	}
	Ok(parts[..3].join(r"\").to_ascii_uppercase())
}

pub fn append_topology(topology: &mut crate::topology::Topology, phone: &Snapshot) {
	if !phone.supported {
		return;
	}
	use crate::topology::{Edge, Node, Port};
	topology.nodes.push(Node {
		id: "phone".into(),
		title: "Phone Audio".into(),
		kind: "device",
		detail: phone
			.devices
			.iter()
			.find(|d| Some(&d.id) == phone.settings.device_id.as_ref())
			.map(|d| format!("{} · {}", d.name, phone.phase))
			.unwrap_or_else(|| "Select a paired phone · private playback".into()),
		meter: Some("phone".into()),
		inputs: vec![],
		effect: None,
		outputs: vec![Port {
			id: "out".into(),
			label: "Private listening".into(),
			direction: "output",
			editable: false,
			signal: "Phone PCM",
			fan_in: false,
		}],
	});
	if phone.connected && phone.output.is_some() {
		if let Some(output) = topology.nodes.iter_mut().find(|n| n.id == "main_output") {
			output.inputs.push(Port {
				id: "phone".into(),
				label: "Private phone".into(),
				direction: "input",
				editable: false,
				signal: "Phone PCM",
				fan_in: false,
			});
		}
		topology.edges.push(Edge {
			id: "fixed:phone:main_output".into(),
			source: "phone".into(),
			target: "main_output".into(),
			source_handle: "out".into(),
			target_handle: "phone".into(),
			kind: "fixed",
			meter: Some("phone".into()),
			label: "Private phone playback · bypasses VAC and listening mix".into(),
		});
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	#[test]
	fn maps_exact_bluetooth_instance() {
		assert_eq!(
			instance_id(r"\\?\BTHENUM#{source}_VID&1234#A&B&0&INSTANCE#{class}\SNK").unwrap(),
			r"BTHENUM\{SOURCE}_VID&1234\A&B&0&INSTANCE"
		);
		assert!(instance_id("My Phone").is_err());
		assert!(instance_id(r"\\?\SWD#foo#bar#{class}\SNK").is_err());
	}
	#[test]
	fn settings_roundtrip_and_future_schema_protected() {
		let temp = tempfile::tempdir().unwrap();
		let path = temp.path().join("phone.toml");
		assert!(!Settings::load(&path).unwrap().auto_connect);
		assert_eq!(Settings::load(&path).unwrap().buffer_ms, 200);
		let settings = Settings {
			device_id: Some("fixture".into()),
			auto_connect: true,
			buffer_ms: 300,
			..Default::default()
		};
		settings.save(&path).unwrap();
		assert_eq!(Settings::load(&path).unwrap().device_id, settings.device_id);
		assert_eq!(Settings::load(&path).unwrap().buffer_ms, 300);
		assert!(check_buffer_ms(49).is_err());
		assert!(check_buffer_ms(501).is_err());
		std::fs::write(&path, "schemaVersion = 2").unwrap();
		assert!(Settings::load(&path).is_err());
		assert_eq!(std::fs::read_to_string(&path).unwrap(), "schemaVersion = 2");
	}
	#[test]
	fn phone_never_projects_to_patch_buses() {
		let mut topology = crate::topology::Topology {
			nodes: vec![],
			edges: vec![],
		};
		let phone = Snapshot {
			supported: true,
			connected: true,
			output: Some(Device {
				id: "test".into(),
				name: "Headphones".into(),
			}),
			..Default::default()
		};
		append_topology(&mut topology, &phone);
		assert!(topology.nodes[0].outputs.iter().all(|p| !p.editable));
		assert_eq!(topology.edges.len(), 1);
		assert_eq!(topology.edges[0].target, "main_output");
	}
}
