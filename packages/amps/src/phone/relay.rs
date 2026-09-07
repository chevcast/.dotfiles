//! Dedicated phone-only WASAPI pump. Slow Bluetooth discovery/control calls must
//! never block this thread or the game/microphone engine's existing audio threads.
use super::{
	buffer::{Buffer, RATE},
	*,
};
use ::windows::{
	core::{w, HSTRING, PROPVARIANT},
	Win32::{
		Foundation::HANDLE,
		Media::Audio::*,
		System::{
			Com::*,
			Threading::{AvRevertMmThreadCharacteristics, AvSetMmThreadCharacteristicsW},
			WinRT::*,
		},
	},
};
use std::{path::PathBuf, sync::atomic::AtomicU32, time::Instant};

#[derive(Default)]
struct State {
	meter: Option<crate::MeterReading>,
	error: Option<String>,
	health: Option<serde_json::Value>,
}
pub(super) struct Relay {
	stop: Arc<AtomicBool>,
	output: Arc<Mutex<String>>,
	state: Arc<Mutex<State>>,
	buffer_ms: Arc<AtomicU32>,
	status_path: PathBuf,
	last_publish: Mutex<Instant>,
	worker: Option<thread::JoinHandle<()>>,
}
impl Relay {
	pub fn start(source: String, output_id: String, status: PathBuf, buffer_ms: u32) -> Self {
		let stop = Arc::new(AtomicBool::new(false));
		let output = Arc::new(Mutex::new(output_id));
		let state = Arc::new(Mutex::new(State::default()));
		let buffer_ms = Arc::new(AtomicU32::new(buffer_ms));
		let size = buffer_ms.clone();
		let (halt, target, shared) = (stop.clone(), output.clone(), state.clone());
		let worker = thread::Builder::new()
			.name("amps-phone-buffer".into())
			.spawn(move || {
				if let Err(error) = run(source, target, &shared, &halt, &size) {
					shared.lock().unwrap().error = Some(format!("Private phone buffer: {error:#}"));
				}
			})
			.expect("could not start phone buffer");
		Self {
			stop,
			output,
			state,
			buffer_ms,
			status_path: status,
			last_publish: Mutex::new(Instant::now()),
			worker: Some(worker),
		}
	}
	pub fn buffer_ms(&self, value: u32) {
		self.buffer_ms.store(value, Ordering::Release);
	}
	pub fn output(&self, id: &str) {
		*self.output.lock().unwrap() = id.into();
	}
	pub fn meter(&self) -> Result<Option<crate::MeterReading>> {
		let state = self.state.lock().unwrap();
		if let Some(error) = &state.error {
			bail!("{error}");
		}
		let (meter, health) = (state.meter.clone(), state.health.clone());
		drop(state);
		// Diagnostic writes happen on the control thread, never the audio pump.
		let mut last = self.last_publish.lock().unwrap();
		if last.elapsed() >= Duration::from_secs(5) {
			if let Some(health) = health {
				if let Ok(bytes) = serde_json::to_vec_pretty(&health) {
					let _ = crate::control::atomic_write(&self.status_path, &bytes);
				}
			}
			*last = Instant::now();
		}
		Ok(meter)
	}
}
impl Drop for Relay {
	fn drop(&mut self) {
		self.stop.store(true, Ordering::Release);
		if let Some(worker) = self.worker.take() {
			let _ = worker.join();
		}
	}
}
struct Client(IAudioClient);
struct AudioPriority(Option<HANDLE>);
impl Drop for AudioPriority {
	fn drop(&mut self) {
		if let Some(handle) = self.0 {
			unsafe {
				let _ = AvRevertMmThreadCharacteristics(handle);
			}
		}
	}
}
impl Drop for Client {
	fn drop(&mut self) {
		unsafe {
			let _ = self.0.Stop();
		}
	}
}
unsafe fn client(device: &IMMDevice, duration: i64) -> Result<Client> {
	let client: IAudioClient = device.Activate(CLSCTX_ALL, None)?;
	let format = WAVEFORMATEX {
		wFormatTag: 3,
		nChannels: 2,
		nSamplesPerSec: RATE as u32,
		nAvgBytesPerSec: (RATE * 8) as u32,
		nBlockAlign: 8,
		wBitsPerSample: 32,
		cbSize: 0,
	};
	client.Initialize(
		AUDCLNT_SHAREMODE_SHARED,
		AUDCLNT_STREAMFLAGS_AUTOCONVERTPCM | AUDCLNT_STREAMFLAGS_SRC_DEFAULT_QUALITY,
		duration,
		0,
		&format,
		None,
	)?;
	Ok(Client(client))
}
struct Render {
	client: Client,
	service: IAudioRenderClient,
	frames: u32,
	started: bool,
}
unsafe fn render(en: &IMMDeviceEnumerator, id: &str) -> Result<Render> {
	// Always explicit: no default endpoint lookup, VAC route, or silent fallback.
	let device = en.GetDevice(&HSTRING::from(id))?;
	// The jitter reservoir cannot protect samples already handed to WASAPI from
	// a missed scheduling deadline. Give the phone's final render queue 100 ms
	// too; this does not change latency for any game or microphone stream.
	let client = client(&device, 1_000_000)?;
	let service = client.0.GetService()?;
	let frames = client.0.GetBufferSize()?;
	Ok(Render {
		client,
		service,
		frames,
		started: false,
	})
}
fn run(
	source_id: String,
	output: Arc<Mutex<String>>,
	shared: &Mutex<State>,
	stop: &AtomicBool,
	size: &AtomicU32,
) -> Result<()> {
	unsafe {
		RoInitialize(RO_INIT_MULTITHREADED)?;
		let mut task = 0;
		let _priority = AudioPriority(AvSetMmThreadCharacteristicsW(w!("Audio"), &mut task).ok());
		let en: IMMDeviceEnumerator = CoCreateInstance(&MMDeviceEnumerator, None, CLSCTX_ALL)?;
		let source = en.GetDevice(&HSTRING::from(&source_id))?;
		let store = source.OpenPropertyStore(STGM_READWRITE)?;
		while !stop.load(Ordering::Acquire) {
			let mut active = 0;
			source.GetState(&mut active);
			if active == DEVICE_STATE_ACTIVE.0 {
				break;
			}
			thread::sleep(Duration::from_millis(50));
		}
		if stop.load(Ordering::Acquire) {
			return Ok(());
		}
		// Hold capture open before switching off Windows's unbuffered Listen relay.
		let input = client(&source, 3_000_000)?;
		let capture: IAudioCaptureClient = input.0.GetService()?;
		input.0.Start()?;
		let mut target = output.lock().unwrap().clone();
		let mut playback = Some(render(&en, &target)?);
		store.SetValue(&super::windows::key(1), &PROPVARIANT::from(false))?;
		store.Commit()?;
		let mut buffer = Buffer::new(size.load(Ordering::Acquire));
		let mut last_input = Instant::now();
		let mut report = Instant::now();
		let mut meter_tick = Instant::now();
		let mut peak = 0f32;
		let mut waveform = Vec::new();
		let mut rendered = 0u64;
		let mut last_pump = Instant::now();
		let mut max_pump_gap_ms = 0u128;
		let mut render_starvations = 0u64;
		let mut capture_position_gaps = 0u64;
		let mut expected_capture_position = None;
		while !stop.load(Ordering::Acquire) {
			max_pump_gap_ms = max_pump_gap_ms.max(last_pump.elapsed().as_millis());
			last_pump = Instant::now();
			let buffer_ms = size.load(Ordering::Acquire);
			buffer.set_target(buffer_ms);
			let desired = output.lock().unwrap().clone();
			if desired != target {
				// Stop the old output before opening the new one; never split the phone.
				drop(playback.take());
				buffer = Buffer::new(buffer_ms);
				playback = Some(render(&en, &desired)?);
				target = desired;
			}
			while capture.GetNextPacketSize()? > 0 {
				let mut data = std::ptr::null_mut();
				let mut frames = 0;
				let mut flags = 0;
				let mut position = 0;
				capture.GetBuffer(
					&mut data,
					&mut frames,
					&mut flags,
					Some(&mut position),
					None,
				)?;
				if flags & AUDCLNT_BUFFERFLAGS_TIMESTAMP_ERROR.0 as u32 == 0 {
					if expected_capture_position.is_some_and(|expected| expected != position) {
						capture_position_gaps += 1;
					}
					expected_capture_position = Some(position + frames as u64);
				} else {
					expected_capture_position = None;
				}
				if flags & AUDCLNT_BUFFERFLAGS_SILENT.0 as u32 != 0 || data.is_null() {
					buffer.push(&vec![0.0; frames as usize * 2]);
				} else {
					buffer.push(std::slice::from_raw_parts(
						data.cast::<f32>(),
						frames as usize * 2,
					));
				}
				capture.ReleaseBuffer(frames)?;
				last_input = Instant::now();
			}
			let render = playback.as_mut().unwrap();
			let padding = render.client.0.GetCurrentPadding()?;
			if render.started && padding == 0 {
				render_starvations += 1;
			}
			let available = render.frames.saturating_sub(padding);
			if available > 0 {
				let data = render.service.GetBuffer(available)?;
				let samples =
					std::slice::from_raw_parts_mut(data.cast::<f32>(), available as usize * 2);
				buffer.render(
					samples,
					last_input.elapsed() > Duration::from_millis(buffer_ms as u64),
				);
				for &sample in samples.iter() {
					peak = peak.max(sample.abs());
				}
				waveform = samples
					.chunks_exact(2)
					.step_by((available as usize / 128).max(1))
					.take(128)
					.map(|v| (v[0] + v[1]) * 0.5)
					.collect();
				render.service.ReleaseBuffer(available, 0)?;
				rendered += available as u64;
				if !render.started {
					render.client.0.Start()?;
					render.started = true;
				}
			}
			if meter_tick.elapsed() >= Duration::from_millis(33) {
				shared.lock().unwrap().meter = Some(crate::MeterReading {
					id: "phone",
					peak,
					dbfs: if peak > 0.0 {
						20.0 * peak.log10()
					} else {
						f32::NEG_INFINITY
					},
					waveform: waveform.clone(),
				});
				peak = 0.0;
				waveform.clear();
				meter_tick = Instant::now();
			}
			if report.elapsed() >= Duration::from_secs(5) {
				// Aggregate health only. Never persist PCM or notification contents.
				shared.lock().unwrap().health = Some(serde_json::json!({
					"targetMs": buffer_ms, "queuedMs": buffer.queued_ms(), "receivedFrames": buffer.received,
					"renderedFrames": rendered, "underruns": buffer.underruns, "overruns": buffer.overruns,
					"renderBufferMs": render.frames as usize * 1000 / RATE, "renderStarvations": render_starvations,
					"maxPumpGapMs": max_pump_gap_ms, "capturePositionGaps": capture_position_gaps,
					"outputId": target, "updatedAt": std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap_or_default().as_secs()
				}));
				report = Instant::now();
			}
			thread::sleep(Duration::from_millis(3));
		}
		Ok(())
	}
}
