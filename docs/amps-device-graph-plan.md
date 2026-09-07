# AMPS: multiple devices and phone calls

Status: design and feasibility investigation, September 7, 2026. This is not a
description of shipped capabilities. It extends the existing
[routing canvas](amps-routing-graph-plan.md), preserving the personal Intrepid
interface, shared frontend, and dotfiles installation.

## Requested behavior

- Add multiple physical inputs and outputs to the graph; no global one-input or
  one-output limit.
- Make received phone audio a routable source, with its own adjustable buffer,
  rather than a fixed side path that can only follow Main Output.
- Preserve Main Input and Main Output as convenient roles, including Windows
  default selection, device history, and Quest/Moonlight overrides.
- Keep phone audio private by default. Only an explicit wire may expose it to an
  application-facing bus, recording stem, or voice send.
- If Windows permits it, receive phone calls and send the chosen microphone to
  the iPhone. Answer, decline, and hang up inside AMPS, not through Phone Link UI.

## Current baseline and evidence

The deployed receiver uses Windows AudioPlaybackConnection and a hidden A2DP
capture endpoint. Its private WASAPI relay follows the engine's applied output.
The 50–500 ms phone reservoir is live-adjustable without reconnecting Bluetooth
or restarting the game/microphone engine. The phone is not yet an editable patch
source and there is no call transmit path.

Increasing the reservoir to 500 ms has not eliminated audible pops. Earlier
reports showed no underruns during some affected periods; a later report showed
two reservoir underruns. The latest implementation gives the final WASAPI queue
100 ms instead of 30 ms and adds timing diagnostics. This is a targeted test,
not a confirmed fix. Require a sustained listening test before declaring success.

A local read-only Windows probe discovers a paired iPhone through
PhoneLineTransportDevice. The generic AppCapability checks for `phoneCall` and
`phoneLineTransportManagement` report Allowed. However, the device-specific
RequestAccessAsync call returns **DeniedBySystem** from the unpackaged native
probe. No RegisterApp, connection, call, contacts query, or call-history query
was performed after that denial. Device discovery alone is not call support.

## Graph model

Keep one versioned Rust graph authoritative. The UI renders its applied nodes,
ports, routes, meters, and capability/error states. Do not add illustrative nodes
for external applications or controls that the backend cannot execute.

- **Capture devices** have stable logical IDs and machine-local endpoint
  bindings. Adding a second microphone does not replace the first.
- **Render devices** can each receive their own mix. Fan-out needs independent
  clock correction and bounded queues for each hardware clock; one slow or
  missing device must not stall another.
- **Main Input / Main Output** are roles assigned to device bindings, not global
  singleton restrictions. A role-following route follows that role; a route
  pinned to a specific device stays pinned. Distinguish these in the inspector.
- **Phone Audio** is the stereo receive source. Its default route follows Main
  Output privately; users may deliberately patch it into other supported mixes.
- **Phone Call Audio** and **Phone Call Mic** are separate receive and transmit
  directions, created only when the native call backend is operational. The
  microphone send is for HFP calls, not arbitrary audio playback in iOS apps.
- Existing buses and real processing stages retain their IDs and meanings.
  Additional internal nodes do not require more VAC cables. A new Windows-visible
  application device would require a separate endpoint decision.

The receiver must move under the engine's audio-graph ownership before exposing
editable phone patches. The tray remains the supervisor and call-control UI;
it must not become a second writer of the graph. Reuse the native endpoint,
sample-format, and gated routing helpers rather than duplicating device policy.

## Routing and privacy rules

1. Preserve all existing VAC endpoint IDs, app/OBS bindings, isolated stems,
   filter settings, and custom labels.
2. Validate every route in Rust, including direction, presence, backend support,
   duplicate edges, and cycles. Preserve protected Comms/AI return domains and
   pure Clean Mic provenance.
3. Propagate phone-call origin through intermediate mixers. Reject any route
   that sends a caller's received audio back to that same call microphone.
   Acoustic feedback and routes created outside AMPS cannot be proven safe by
   this graph alone.
4. Call audio stays private until explicitly patched elsewhere. A disconnected
   private output must not fall back to Game or another application-facing bus.
5. Media buffering and call latency are independent. Do not reuse a 500 ms media
   reservoir for a live conversation. Display negotiated call format and latency;
   never promise stereo/high-fidelity HFP audio.
6. Device disappearance marks only affected routes unavailable. Preserve desired
   bindings for reconnection, and apply history fallback only to roles that
   explicitly use it. Output volume affects listening, not isolated OBS buses.

## Native call feasibility gate

Windows exposes documented call transport and control APIs, but the current
device-specific access denial must be resolved before implementing real buttons.
The next isolated prototype should test a proper application identity and the
required manifest capabilities, using an explicit local development installation
if necessary. Do not change machine security settings, install trusted
certificates, or impersonate Phone Link silently. Sideloaded restricted
capabilities do not by themselves require Store approval, but this does not
guarantee that this Windows build will grant call transport access.

Success requires actual registration and a call-line watcher, then explicit
user-assisted incoming-call testing. Verify answer/decline/hang-up, audio in both
directions, disconnect cleanup, and privacy while OBS runs. No automated test
should place calls or read contacts/history. Unregister only registrations owned
by the prototype. Keep the existing media receiver intact on failure.

Phone Link documents a Bluetooth-headset relay limitation for iPhone calls. Do
not assume an independent AMPS route, AirPods, or Quest bypasses that limitation;
test the actual endpoints. Quest's PC audio endpoint is a different route from a
Bluetooth headset, but its call suitability is not yet verified.

Primary references:

- [Windows remote audio playback](https://learn.microsoft.com/en-us/windows/apps/develop/media-playback/enable-remote-audio-playback)
- [PhoneLineTransportDevice](https://learn.microsoft.com/en-us/uwp/api/windows.applicationmodel.calls.phonelinetransportdevice?view=winrt-26100)
- [RequestAccessAsync](https://learn.microsoft.com/en-us/uwp/api/windows.applicationmodel.calls.phonelinetransportdevice.requestaccessasync?view=winrt-26100)
- [App capability declarations](https://learn.microsoft.com/en-us/windows/apps/package-and-deploy/app-capability-declarations)
- [Phone Link call limitations](https://support.microsoft.com/en-us/windows/apps/phonelink/troubleshooting-calls-in-the-phone-link)

## Rollout and acceptance

1. Finish phone timing diagnosis with aggregate counters and sustained playback;
   do not record private PCM. Keep this independently deployable.
2. Introduce the versioned multi-device model and migration tests without changing
   the live graph. Preserve old logical IDs/layout keys, eight current routes,
   physical history, and all fourteen VAC endpoint IDs. Back up before conversion;
   reject unknown future schemas without rewriting them.
3. Implement independent capture/render bindings and per-sink fan-out, followed by
   the editable phone source. Stage resources off the audio thread, apply only
   affected routes, acknowledge the applied revision, and roll back on failure.
4. Add canvas device creation/removal and role assignment. Removing a connected
   node must explain which routes will be removed. Reuse port-aware layout and
   collision repair; meter updates must not rearrange saved nodes.
5. Ship native call controls only after the feasibility gate passes. Model idle,
   ringing, connecting, active, disconnecting, denied, and unavailable states;
   disable invalid actions and reflect the real backend state.
6. Run native Rust and frontend/browser tests, Ubuntu Home Manager build,
   migration/rollback fixtures, hotplug and concurrent-output tests, call privacy
   tests, and an unchanged second reconciliation. Verify close-to-tray, restart,
   and full exit still govern the whole array. No reboot or VAC reinstall is part
   of the planned graph migration.
