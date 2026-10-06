# proto — host-side chop (phase 1, no firmware)

`chop/` is a small Rust program on the Mac. You pick one track; each of the 12 pads fires that track from its own sample-start marker (STA 0–120).
Path per pad hit: pad note in → CC 28 (start) [+ CC 29 end] → trigger note out. Monophonic: a new pad releases the previous slice.

## Build
```
cd proto/chop && cargo build --release
```

## On the Rytm (MK2), once
- SETTINGS > MIDI CONFIG > PORT CONFIG: **PAD DEST = EXT** (pads only send MIDI, so you don't hear a double hit), **RECEIVE NOTES** on, **RECEIVE CC/NRPN** on.
- Load the sample you want to chop on the target track. For grid-exact slices, make it 120 sixteenths long (7.5 bars): every start value then lands on a 16th.

## Use
```
./target/release/chop ports                     # is the Rytm visible?
./target/release/chop monitor                   # see what the pads send
./target/release/chop learn                     # press pads 1..12 in order -> pads.json
./target/release/chop run --track 1             # pads = markers 0,10,20 ... 110
./target/release/chop run --track 1 --slice-end # each pad plays only up to the next marker
./target/release/chop run --track 1 --markers 0,8,16,24,40,48,56,64,80,88,96,104
```
Flags: `--channel N` if the track's MIDI channel is not its number; `--scale linear` if CC 0–127 turns out to map across STA 0–120 (default sends the value as-is); `--port-match` for another device name; `--dry-run` reads hex messages on stdin and prints what it would send.

Ctrl-C stops it. The start/end values it sets are live sound edits: the kit is not saved, so reload the kit to get your original STA/END back.

## Measure on the MK2 (not done yet)
1. Does CC 28 value 60 show STA 60 (raw) or about 57 (linear)? Pick `--scale` from that.
2. Is the slice start right on the first hit, or does the trigger sometimes beat the CC? If it does, add a 1 ms gap.
3. Feel: is the pad-to-sound latency playable?

Tested so far: 7 unit tests (logic) and a dry run. Nothing has been sent to a Rytm.
