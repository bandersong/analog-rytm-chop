# Chop mode — design

## Behaviour
- Enter CHOP for the active track (entry key TBD; rytm1_mods adds pages by a second press of a page key).
- Each of the 12 pads holds a marker: a sample start value 0–120. Hitting a pad sets STA to its marker and fires the track.
- Hold a pad + turn an encoder to move its marker. Markers save with the sound/kit.
- Default markers: 12 equal divisions (0, 10, 20 … 110).
- Open: END per slice (next marker vs. track END), recording pad hits into the sequencer as STA p-locks, more than 12 markers via pages.

## Phase 1 — host prototype (`proto/`)
Bridge change: accept `sample_start` in `rytm_set_live_parameter` (CC 28 on the track channel; code near `hardware_control.rs` set_live_parameter in `~/analog-rytm-agent-bridge`). Loop: pad note in → CC 28 → trigger note (0–11).
Measure: start-then-trigger ordering, audible latency, CC value → STA mapping (0–127 onto 0–120).
Exit: it feels playable, or we know why not.

## Phase 2 — MK1 firmware mod (`mods/0001-chop/`)
Base: gdeo607/rytm1_mods at OS 1.73. Needs from its symbol map: page draw, key/pad handler, encoder handler, `trig_fire`, the sample-start parameter of a track, a saved settings slot for 12 bytes.
Rule: never write inside the embedded bootstrap range (see HAZARDS).
Exit: null repack is byte-identical to stock; mod image builds; layout check passes; then your flash decision.

## Phase 3 — MKII
Needs the private MKII `rytm-mods` project or address work against genosdk/analog-rytm-mkii-research (OS 1.72).
