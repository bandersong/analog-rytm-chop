# Chop mode — design

## Behaviour
- Enter CHOP for the active track (entry key TBD; rytm1_mods adds pages by a second press of a page key).
- Each of the 12 pads holds a marker: a sample start value 0–120. Hitting a pad sets STA to its marker and fires the track.
- Hold a pad + turn an encoder to move its marker.
- **Markers live in RAM only.** Power cycle (maybe kit change) resets them to 12 equal divisions (0, 10, 20 … 110); re-chop if you had custom ones. Nothing new is saved per sound, so the one-free-word limit (HOOKS.md) does not apply.
- **In the sequencer a chop is just a p-lock.** Recording a pad hit in CHOP writes a normal trig with a normal STA p-lock; it saves with the pattern and plays back on stock firmware.
- Open: END per slice (next marker vs. track END), more than 12 markers via pages.

## Proven with the host prototype (2026-10-05)
- MK2 and MK1 (OS 1.72): pad → CC 28 → trigger note plays the slice (owner's ear test, both units).
- MK1 OS 1.72, live record: a pad hit through chop records a trig on the target track **with STA p-locked to the marker** (owner checked with TRK + pad, then the trig). So the stock OS already turns "set STA, then trigger" into a p-lock.
- Both units' pads send ch 14 (auto channel), note = pad − 1 (`proto/chop/pads*.json`).
- Prototype quirk: with PAD DEST = EXT a pad press still switches the selected track. The firmware mod intercepts pads in CHOP, so it won't.

## Phase 1 — host prototype (`proto/`)
Done; see `proto/README.md`. Still to measure: CC → STA scaling (raw vs linear), whether a hit ever plays from the previous start, latency.

## Phase 2 — MK1 firmware mod (`mods/0001-chop/`)
Base: gdeo607/rytm1_mods, ported from OS 1.73 to **OS 1.72** (what the MK1 runs; stock image backed up, round-trip proven).
In CHOP the mod needs to:
1. show a CHOP page (rytm1_mods' second-press page mechanism; HOOKS.md (d));
2. hold 12 markers in RAM (a cave, not the sound's free word);
3. hook pad presses: no track switch; set the chop track's STA **through the same path a knob turn uses** (`param_apply_delta` family in symbols.toml), so live record makes the p-lock exactly as stock does; then fire the track as a normal pad hit would.
Rule: never write inside the embedded bootstrap range (see HAZARDS; 1.72 range being located).
First milestone: CHOP page shows and its knobs edit RAM markers; pads unchanged.
Exit: null repack byte-identical (done for 1.72); mod image builds; layout check passes; then your flash decision.

## Phase 3 — MKII
Needs the private MKII `rytm-mods` project or address work against genosdk/analog-rytm-mkii-research (OS 1.72, same version as your MK2).
