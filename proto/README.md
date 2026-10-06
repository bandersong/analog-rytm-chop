# proto — host-side chop (phase 1)

Status: not started. No firmware involved.

1. Bridge: add `sample_start` (CC 28) to the live-parameter path in `~/analog-rytm-agent-bridge`.
2. Rytm settings: RECEIVE NOTES on, RECEIVE CC/NRPN on; pads sending MIDI out (PAD DEST) if pads are the input.
3. Script: note in → CC 28 with that pad's marker → trigger note for the track.
4. Record: latency, ordering, CC→STA scaling.
