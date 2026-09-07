//! Bounded phone-only jitter reservoir. No samples are persisted.
use std::collections::VecDeque;

pub(super) const RATE: usize = 44_100;
const FADE: f32 = (RATE / 200) as f32;

pub(super) struct Buffer {
	frames: VecDeque<[f32; 2]>,
	target: usize,
	primed: bool,
	phase: f64,
	ratio: f64,
	gain: f32,
	last: [f32; 2],
	pub received: u64,
	pub underruns: u64,
	pub overruns: u64,
}
impl Buffer {
	pub fn new(buffer_ms: u32) -> Self {
		Self {
			frames: VecDeque::with_capacity(RATE),
			target: RATE * buffer_ms.clamp(50, 500) as usize / 1000,
			primed: false,
			phase: 0.0,
			ratio: 1.0,
			gain: 0.0,
			last: [0.0; 2],
			received: 0,
			underruns: 0,
			overruns: 0,
		}
	}
	pub fn set_target(&mut self, buffer_ms: u32) {
		let target = RATE * buffer_ms.clamp(50, 500) as usize / 1000;
		if target != self.target {
			self.target = target;
			// Only the phone queue reprimes; physical streams and Bluetooth stay open.
			self.frames.clear();
			self.primed = false;
			self.phase = 0.0;
		}
	}
	pub fn push(&mut self, samples: &[f32]) {
		for pair in samples.chunks_exact(2) {
			self
				.frames
				.push_back([sanitize(pair[0]), sanitize(pair[1])]);
			self.received += 1;
		}
		if self.frames.len() > RATE {
			self.frames.drain(..self.frames.len() - self.target);
			self.primed = false;
			self.phase = 0.0;
			self.overruns += 1;
		}
	}
	pub fn queued_ms(&self) -> usize {
		self.frames.len() * 1000 / RATE
	}
	pub fn render(&mut self, output: &mut [f32], tail: bool) {
		if !self.primed
			&& (self.frames.len() >= self.target + output.len() / 2 + 2
				|| (tail && !self.frames.is_empty()))
		{
			self.primed = true;
			self.phase = 0.0;
			self.gain = 0.0;
		}
		// Smooth, bounded correction for the independent Bluetooth/output clocks.
		// Avoid periodically dropping/duplicating whole samples to control latency.
		let error = (self.frames.len() as f64 - self.target as f64) / self.target as f64;
		let wanted = 1.0 + (error * 0.002).clamp(-0.003, 0.003);
		self.ratio += (wanted - self.ratio) * 0.02;
		for pair in output.chunks_exact_mut(2) {
			if self.primed && (self.frames.len() >= 2 || (tail && !self.frames.is_empty())) {
				let a = self.frames[0];
				let b = self.frames.get(1).copied().unwrap_or(a);
				self.gain = (self.gain + 1.0 / FADE).min(1.0);
				for ch in 0..2 {
					self.last[ch] = a[ch] + (b[ch] - a[ch]) * self.phase as f32;
					pair[ch] = self.last[ch] * self.gain;
				}
				self.phase += self.ratio;
				while self.phase >= 1.0 {
					self.frames.pop_front();
					self.phase -= 1.0;
				}
			} else {
				if self.primed {
					self.primed = false;
					if !tail {
						self.underruns += 1;
					}
				}
				self.gain = (self.gain - 1.0 / FADE).max(0.0);
				for ch in 0..2 {
					pair[ch] = self.last[ch] * self.gain;
				}
			}
		}
	}
}
fn sanitize(value: f32) -> f32 {
	if value.is_finite() {
		value.clamp(-1.0, 1.0)
	} else {
		0.0
	}
}

#[cfg(test)]
mod tests {
	use super::*;
	const TARGET: usize = RATE / 5;
	#[test]
	fn prefill_then_absorb_a_hundred_ms_gap() {
		let mut b = Buffer::new(200);
		let mut out = vec![0.0; 882];
		b.push(&vec![0.4; 882]);
		b.render(&mut out, false);
		assert!(out.iter().all(|v| *v == 0.0));
		b.push(&vec![0.4; TARGET * 2 + 4]);
		b.render(&mut out, false);
		for _ in 0..10 {
			b.render(&mut out, false);
		}
		assert_eq!(b.underruns, 0);
		assert!(out.iter().all(|v| *v > 0.3));
	}
	#[test]
	fn short_notifications_flush_and_long_gap_fades_to_silence() {
		let mut b = Buffer::new(200);
		b.push(&vec![0.5; 882]);
		let mut out = vec![0.0; 2000];
		b.render(&mut out, true);
		assert!(out.iter().any(|v| *v > 0.4));
		assert_eq!(*out.last().unwrap(), 0.0);
		assert_eq!(b.underruns, 0);
	}
	#[test]
	fn bounded_finite_and_stereo_aligned() {
		let mut b = Buffer::new(200);
		b.push(&vec![f32::NAN; RATE * 3]);
		assert_eq!(b.overruns, 1);
		assert!(b.queued_ms() <= 200);
		let mut out = vec![0.0; 1000];
		b.render(&mut out, true);
		assert!(out.iter().all(|v| *v == 0.0));
	}
	#[test]
	fn long_run_clock_drift_is_bounded_without_periodic_cuts() {
		let mut b = Buffer::new(200);
		b.push(&vec![0.4; (TARGET + 882) * 2]);
		let mut out = vec![0.0; 882];
		for n in 0..30_000 {
			b.push(&vec![0.4; if n % 10 == 0 { 884 } else { 882 }]);
			b.render(&mut out, false);
		}
		assert_eq!((b.underruns, b.overruns), (0, 0));
		assert!((150..300).contains(&b.queued_ms()));
	}
	#[test]
	fn changing_delay_rebuffers_only_local_queue() {
		let mut b = Buffer::new(100);
		b.push(&vec![0.2; RATE / 2]);
		b.set_target(300);
		assert_eq!(b.queued_ms(), 0);
		assert_eq!(b.target, RATE * 3 / 10);
		assert_eq!((b.underruns, b.overruns), (0, 0));
	}
}
