use super::*;
use ::windows::{
	core::{BSTR, GUID, HSTRING, PROPVARIANT},
	Devices::Enumeration::{DeviceInformation, DeviceInformationUpdate, DeviceWatcher},
	Foundation::{AsyncStatus, IAsyncAction, IAsyncOperation, TypedEventHandler},
	Media::Audio::{
		AudioPlaybackConnection, AudioPlaybackConnectionOpenResult, AudioPlaybackConnectionState,
	},
	Win32::{
		Media::Audio::*,
		System::{
			Com::{StructuredStorage::*, *},
			Variant::VT_LPWSTR,
			WinRT::*,
		},
		UI::Shell::PropertiesSystem::*,
	},
};
use std::{path::PathBuf, time::Instant};
use winreg::{
	enums::{HKEY_LOCAL_MACHINE, KEY_READ, KEY_WOW64_64KEY},
	RegKey,
};

pub(super) fn key(pid: u32) -> PROPERTYKEY {
	PROPERTYKEY {
		fmtid: GUID::from_u128(0x24dbb0fc_9311_4b3d_9cf0_18ff155639d4),
		pid,
	}
}

fn check_wait(status: AsyncStatus, deadline: Instant, stop: &AtomicBool) -> Result<bool> {
	if stop.load(Ordering::Acquire) {
		bail!("Phone operation cancelled during shutdown");
	}
	if status != AsyncStatus::Started {
		return Ok(false);
	}
	if Instant::now() >= deadline {
		bail!("Windows Bluetooth operation timed out");
	}
	thread::sleep(Duration::from_millis(30));
	Ok(true)
}
fn wait_action(action: &IAsyncAction, stop: &AtomicBool) -> Result<()> {
	let deadline = Instant::now() + Duration::from_secs(15);
	loop {
		match check_wait(action.Status()?, deadline, stop) {
			Ok(true) => {}
			Ok(false) => return Ok(action.GetResults()?),
			Err(e) => {
				let _ = action.Cancel();
				return Err(e);
			}
		}
	}
}
fn wait_open(
	action: &IAsyncOperation<AudioPlaybackConnectionOpenResult>,
	stop: &AtomicBool,
) -> Result<()> {
	let deadline = Instant::now() + Duration::from_secs(20);
	loop {
		match check_wait(action.Status()?, deadline, stop) {
			Ok(true) => {}
			Ok(false) => break,
			Err(e) => {
				let _ = action.Cancel();
				return Err(e);
			}
		}
	}
	let result = action.GetResults()?.Status()?;
	if result.0 != 0 {
		bail!("Windows could not open phone audio ({result:?}). Check Bluetooth on the phone.");
	}
	Ok(())
}
fn discover(stop: &AtomicBool) -> Result<Vec<Device>> {
	let operation =
		DeviceInformation::FindAllAsyncAqsFilter(&AudioPlaybackConnection::GetDeviceSelector()?)?;
	let deadline = Instant::now() + Duration::from_secs(10);
	loop {
		match check_wait(operation.Status()?, deadline, stop) {
			Ok(true) => {}
			Ok(false) => break,
			Err(e) => {
				let _ = operation.Cancel();
				return Err(e);
			}
		}
	}
	let collection = operation.GetResults()?;
	let mut devices = Vec::new();
	for n in 0..collection.Size()? {
		let device = collection.GetAt(n)?;
		// This is an audio interface: IsPaired may be false even for a paired phone.
		devices.push(Device {
			id: device.Id()?.to_string(),
			name: device.Name()?.to_string(),
		});
	}
	devices.sort_by(|a, b| a.name.cmp(&b.name));
	Ok(devices)
}

fn capture_id(interface: &str) -> Result<String> {
	let instance = instance_id(interface)?;
	let root = RegKey::predef(HKEY_LOCAL_MACHINE).open_subkey_with_flags(
		r"SOFTWARE\Microsoft\Windows\CurrentVersion\MMDevices\Audio\Capture",
		KEY_READ | KEY_WOW64_64KEY,
	)?;
	let mut matches = Vec::new();
	for name in root.enum_keys() {
		let name = name?;
		let properties = root.open_subkey(format!(r"{name}\Properties"))?;
		let Ok(stored): std::result::Result<String, _> =
			properties.get_value("{b3f8fa53-0004-438e-9003-51a46e139bfc},2")
		else {
			continue;
		};
		if stored
			.strip_prefix("{1}.")
			.unwrap_or(&stored)
			.eq_ignore_ascii_case(&instance)
		{
			matches.push(format!("{{0.0.1.00000000}}.{name}"));
		}
	}
	if matches.len() != 1 {
		bail!(
			"Cannot uniquely resolve this phone's private capture endpoint; playback stayed closed"
		);
	}
	Ok(matches.remove(0))
}

struct Session {
	connection: Option<AudioPlaybackConnection>,
	store: IPropertyStore,
	output: String,
	relay: Option<super::relay::Relay>,
}
impl Session {
	fn start(
		phone: &Device,
		target: &Device,
		config: &Path,
		stop: &AtomicBool,
		buffer_ms: u32,
	) -> Result<Self> {
		unsafe {
			let en: IMMDeviceEnumerator = CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;
			let capture_id = capture_id(&phone.id)?;
			// GetDevice can open this endpoint even though Windows hides it from its UI.
			let source = en.GetDevice(&HSTRING::from(&capture_id))?;
			let store = source.OpenPropertyStore(STGM_READWRITE)?;
			let backup = config.with_file_name(format!(
				"phone-listen-backup-{}.json",
				capture_id.rsplit('.').next().unwrap_or("endpoint")
			));
			if !backup.exists() {
				let old = store.GetValue(&key(0))?;
				let enabled = bool::try_from(&store.GetValue(&key(1))?).ok();
				crate::control::atomic_write(
					&backup,
					&serde_json::to_vec_pretty(&serde_json::json!({
						"captureId":capture_id, "output":BSTR::try_from(&old).ok().map(|s| s.to_string()),
						"enabled":enabled, "originalOutputVariant":format!("{old:?}")
					}))?,
				)?;
			}
			let mut session = Self {
				connection: None,
				store,
				output: String::new(),
				relay: None,
			};
			// Explicit physical destination BEFORE enabling Listen or opening Bluetooth.
			session.route(target)?;
			session.store.SetValue(&key(1), &PROPVARIANT::from(true))?;
			session.store.Commit()?;
			let connection = AudioPlaybackConnection::TryCreateFromId(&HSTRING::from(&phone.id))?;
			session.connection = Some(connection.clone());
			// Retain the discovery ID. Do not call Connection.DeviceId (Windows API bug).
			wait_action(&connection.StartAsync()?, stop)?;
			wait_open(&connection.OpenAsync()?, stop)?;
			session.relay = Some(super::relay::Relay::start(
				capture_id,
				target.id.clone(),
				config.with_file_name("phone-buffer-status.json"),
				buffer_ms,
			));
			Ok(session)
		}
	}
	fn route(&mut self, target: &Device) -> Result<()> {
		unsafe {
			let en: IMMDeviceEnumerator = CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;
			let device = en.GetDevice(&HSTRING::from(&target.id))?;
			let mut state = 0;
			device.GetState(&mut state);
			if state != DEVICE_STATE_ACTIVE.0 {
				bail!("Listening output is unavailable; phone playback will disconnect");
			}
			if self.output == target.id {
				return Ok(());
			}
			let mut value = PROPVARIANT::new();
			// PROPVARIANT::from(&str) makes VT_BSTR, which this Windows property ignores.
			PropVariantChangeType(
				&mut value,
				&PROPVARIANT::from(target.id.as_str()),
				PVCHF_DEFAULT,
				VT_LPWSTR,
			)?;
			self.store.SetValue(&key(0), &value)?;
			self.store.Commit()?;
			let readback = BSTR::try_from(&self.store.GetValue(&key(0))?)?.to_string();
			if !readback.eq_ignore_ascii_case(&target.id) {
				bail!("Windows did not accept the private phone destination");
			}
			self.output.clone_from(&target.id);
			if let Some(relay) = &self.relay {
				relay.output(&target.id);
			}
			Ok(())
		}
	}
	fn is_open(&self) -> bool {
		self
			.connection
			.as_ref()
			.is_some_and(|c| c.State().ok() == Some(AudioPlaybackConnectionState::Opened))
	}
	fn meter(&self) -> Result<Option<crate::MeterReading>> {
		self.relay.as_ref().map(|r| r.meter()).unwrap_or(Ok(None))
	}
}
impl Drop for Session {
	fn drop(&mut self) {
		drop(self.relay.take());
		unsafe {
			// Never restore "default output": that could expose phone audio to VAC.
			let _ = self
				.store
				.SetValue(&key(1), &PROPVARIANT::from(false))
				.and_then(|_| self.store.Commit());
		}
		if let Some(connection) = self.connection.take() {
			let _ = connection.Close();
		}
	}
}

pub(super) fn run(
	path: PathBuf,
	receiver: mpsc::Receiver<Message>,
	shared: Arc<Mutex<Snapshot>>,
	levels: Arc<Mutex<Option<crate::MeterReading>>>,
	stop: Arc<AtomicBool>,
	wakeup: mpsc::Sender<Message>,
) {
	let result = || -> Result<()> {
		unsafe {
			RoInitialize(RO_INIT_MULTITHREADED)?;
		}
		let mut state = Snapshot {
			settings: Settings::load(&path)?,
			..Default::default()
		};
		state.wanted = state.settings.auto_connect;
		match discover(&stop) {
			Ok(devices) => state.devices = devices,
			Err(e) => state.error = Some(format!("{e:#}")),
		}
		// Event-driven discovery, including pairing/unpairing while the UI is hidden.
		let watcher =
			DeviceInformation::CreateWatcherAqsFilter(&AudioPlaybackConnection::GetDeviceSelector()?)?;
		let added = wakeup.clone();
		watcher.Added(&TypedEventHandler::<DeviceWatcher, DeviceInformation>::new(
			move |_, _| {
				let _ = added.send(Message::Discover);
				Ok(())
			},
		))?;
		watcher.Removed(
			&TypedEventHandler::<DeviceWatcher, DeviceInformationUpdate>::new(move |_, _| {
				let _ = wakeup.send(Message::Discover);
				Ok(())
			}),
		)?;
		watcher.Start()?;
		*shared.lock().unwrap() = state.clone();
		let mut session: Option<Session> = None;
		let mut output: Option<Device> = None;
		let mut next_try = Instant::now();
		let mut published = None;
		while !stop.load(Ordering::Acquire) {
			let message = if session.is_some() {
				receiver.recv_timeout(Duration::from_millis(33)).ok()
			} else {
				match receiver.recv() {
					Ok(message) => Some(message),
					Err(_) => break,
				}
			};
			if let Some(message) = message {
				match message {
					Message::Stop => break,
					Message::Discover => {
						match discover(&stop) {
							Ok(devices) => state.devices = devices,
							Err(e) => state.error = Some(format!("{e:#}")),
						}
						next_try = Instant::now();
					}
					Message::Restart => {
						session = None;
						next_try = Instant::now();
					}
					Message::Output(value) => {
						output = value;
					}
					Message::Edit(request, reply) => {
						let edit = || -> Result<()> {
							if request.action == "refresh" {
								state.devices = discover(&stop)?;
								return Ok(());
							}
							let mut settings = state.settings.clone();
							if let Some(id) = request.device_id {
								if !state.devices.iter().any(|d| d.id == id) {
									bail!("Select an available paired phone");
								}
								settings.device_id = Some(id);
							}
							if let Some(value) = request.auto_connect {
								settings.auto_connect = value;
							}
							if let Some(value) = request.buffer_ms {
								check_buffer_ms(value)?;
								settings.buffer_ms = value;
							}
							if request.action == "connect" && settings.device_id.is_none() {
								bail!("Select a paired phone first");
							}
							settings.save(&path)?;
							if settings.device_id != state.settings.device_id {
								session = None;
							}
							state.settings = settings;
							if let Some(relay) = session.as_ref().and_then(|s| s.relay.as_ref()) {
								relay.buffer_ms(state.settings.buffer_ms);
							}
							if request.action == "connect" {
								state.wanted = true;
							}
							if request.action == "disconnect" {
								state.wanted = false;
								session = None;
							}
							next_try = Instant::now();
							state.error = None;
							Ok(())
						};
						let result = edit().map_err(|e| format!("{e:#}"));
						if let Err(error) = &result {
							state.error = Some(error.clone());
						}
						let _ = reply.send(result);
					}
				}
			}
			if !state.wanted || output.is_none() {
				session = None;
			}
			if let (Some(current), Some(target)) = (session.as_mut(), output.as_ref()) {
				if !current.is_open() {
					session = None;
					next_try = Instant::now() + Duration::from_secs(5);
				} else if let Err(error) = current.route(target) {
					state.error = Some(format!("{error:#}"));
					session = None;
					next_try = Instant::now() + Duration::from_secs(5);
				}
			}
			if state.wanted && session.is_none() && output.is_some() && Instant::now() >= next_try {
				state.phase = "connecting".into();
				state.connected = false;
				state.output = None;
				*shared.lock().unwrap() = state.clone();
				let phone = state
					.devices
					.iter()
					.find(|d| Some(&d.id) == state.settings.device_id.as_ref());
				let result = phone
					.context("Selected phone is unavailable; refresh the paired device list")
					.and_then(|phone| {
						Session::start(
							phone,
							output.as_ref().unwrap(),
							&path,
							&stop,
							state.settings.buffer_ms,
						)
					});
				match result {
					Ok(current) => {
						session = Some(current);
						state.error = None;
					}
					Err(error) => {
						state.error = Some(format!("{error:#}"));
						next_try = Instant::now() + Duration::from_secs(15);
					}
				}
			}
			*levels.lock().unwrap() = match session.as_ref().map(Session::meter).transpose() {
				Ok(reading) => reading.flatten(),
				Err(error) => {
					state.error = Some(format!("{error:#}"));
					session = None;
					next_try = Instant::now() + Duration::from_secs(15);
					None
				}
			};
			state.connected = session.is_some();
			state.output = if state.connected {
				output.clone()
			} else {
				None
			};
			state.phase = if state.connected {
				"connected"
			} else if !state.wanted {
				"off"
			} else if output.is_none() {
				"waiting for Main Output"
			} else {
				"waiting to reconnect"
			}
			.into();
			if published.as_ref() != Some(&state) {
				*shared.lock().unwrap() = state.clone();
				if let Ok(bytes) = serde_json::to_vec_pretty(&state) {
					if let Err(error) =
						crate::control::atomic_write(&path.with_file_name("phone-status.json"), &bytes)
					{
						tracing::warn!(%error, "could not publish phone status");
					}
				}
				published = Some(state.clone());
			}
		}
		drop(session);
		let _ = watcher.Stop();
		Ok(())
	};
	if let Err(error) = result() {
		let mut state = shared.lock().unwrap();
		state.error = Some(format!("{error:#}"));
		state.phase = "unavailable".into();
	}
	*levels.lock().unwrap() = None;
	let mut state = shared.lock().unwrap();
	state.connected = false;
	state.output = None;
	if stop.load(Ordering::Acquire) {
		state.phase = "stopped".into();
	}
	if let Ok(bytes) = serde_json::to_vec_pretty(&*state) {
		let _ = crate::control::atomic_write(&path.with_file_name("phone-status.json"), &bytes);
	}
}
