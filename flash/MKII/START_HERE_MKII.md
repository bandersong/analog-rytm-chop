> **Fixed 2026-10-09:** files 2 and 3 are rebuilt so that a pad hit plays its own marker on the **first** hit (before, the engine glided the start point from the previous marker over ~100 ms, so hits landed between markers and "locked in" after repeats - what you heard on the MK1). The pad now sets the start at once, as a sequencer p-lock does. The earlier files 2 and 3 are in `../_superseded/2026-10-09-pre-snap/MKII/`. Check each file's sha256 against `SHA256SUMS` (file 2 `2ff96af2…`, file 3 `78295576…`).
>
> **Fixed 2026-10-08 (still in these files):** pressing a CHOP or SMP CUT knob while holding steps is ignored (no hidden lock). The files before that are in `../_superseded/2026-10-08-pre-press-gate/MKII/`.

# CHOP / Sample Focus for your MKII (OS 1.73) — start here

**None of these files has run on an MKII yet.** Every check that can be done on a computer passed (built and verified in the VM several times, same bytes each time; the MKII's bootstrap section, and the embedded firmware the OS sends to another device at startup, are byte-for-byte stock in every file). Same features as the MK1's file 5: the CHOP page and SMP CUT.

**These files are for the MKII only.** Never send an `ARMK2_…` file to the MK1, or an MK1 (`AR1_…`) file to the MKII.

## Before you flash
1. In Transfer, back up the MKII's projects / +Drive.
2. Have a **DIN** MIDI interface ready (the recovery route is DIN only, not USB).
3. Your MKII is on **OS 1.72**. First install **stock 1.73**: `0_STOCK-1.73_and_RECOVERY_…syx` (Elektron's own file) by the normal route. **Never install 1.74**: these files are 1.73, and going back from 1.74 would be a downgrade, which Elektron doesn't support.
4. Normal route: Transfer > CONNECTION (MIDI IN/OUT = the Rytm), Transfer > DROP, drag the file, press YES on the Rytm. Don't power off during the update or the first boot after it.
5. If Transfer refuses a file as "same version", nothing was written: stop, or send it by the recovery route below.

## Order (each only after the one before behaved)
| # | File | What | Test |
|---|---|---|---|
| 0 | `0_STOCK-1.73_and_RECOVERY_…` | Elektron's stock 1.73 | it boots and plays |
| 1 | `1_CONTROL_stock-code_…` | stock MKII code, only repacked by our tool | M0: accepted, boots, plays; SAMPLE flips SAMPLE ↔ SMPL WAVEFORM; FILTER has one page. Note what a quick SAMPLE double-tap does. |
| 2 | `2_CHOP_…` | the CHOP page | M1, then **D rows 1–4** (below), then M2, then D rows 5–10 |
| 3 | `3_CHOP+SMP-CUT_…` | CHOP plus SMP CUT | M3 — read "SMP CUT" below first; then D rows 1–10 |

Fallbacks: 3 → 2 → stock (file 0) → recovery.

## The CHOP page (files 2 and 3): SAMPLE, then SAMPLE again until CHOP
On the MKII the SAMPLE key cycles **SAMPLE → SMPL WAVEFORM → CHOP → SAMPLE** (three pages; the MK1 has two). SMPL WAVEFORM must still show its waveform; CHOP must look like a normal knob page (no waveform). First set **SETTINGS > CONTROLS > SEQUENCER CONFIG > SAMPLE POS RES = HI**.

| Knob | Does |
|---|---|
| A **PAD** | which marker you're editing (1–12); hitting a pad also selects it |
| B **STA** | that marker, hi-res: slow turn = decimals (the MKII shows `40.25`), FUNC + turn = whole steps |
| C **CHP** | right = CHOP ON for the selected track; left = OFF (pads stock again) |
| D **END** | right = ON: each pad also sets END to the next marker. Left = OFF (END back to 120) |
| E **DIV** | re-chop into 1–12 equal slices (overwrites hand-set markers) |
| F **LAY** | turn right once: slices on the **empty** steps only. No undo — try it on a copy of a pattern. |
| G **RND** | GRID REC: hold steps, turn G → each held step gets a random slice |
| H | blank |

Write down: the header title on CHOP; whether the long knob names fit the header when you turn a knob; what a quick SAMPLE double-tap does compared with file 1; which page SAMPLE opens on after you leave the view on CHOP.

## D. The first-hit fix (files 2 and 3)
Same rows as the MK1's section D (`../START_HERE.md`; full card: design.md "D41 rows", with the one run order). In short:
**Clean kit first:** a fresh kit with only your sample on the chop track (or on that track: LFO DEP 0, no velocity / aftertouch / performance / scene modulation of STA or END, LOP OFF, the machine's own LEV at 0, no trigs or STA/END locks on its steps). A sample whose start and late part sound different; CHOP ON, END OFF, power-on markers (pad 1 = 0, pad 12 = 110).
1. Sequencer stopped: pad 1, wait 2 s, pad 12, wait 2 s … eight hits — **every hit plays its own slice, the first one included.**
2. Alternate pad 1 / pad 12 at 16ths, then as fast as you can: own slice every time (judge only where each sounding hit starts; count silent hits under 7).
3. Hit pad 12 a few times, then roll pad 1 fast, six hits: every hit starts at 0.
4. Control: LAY the slices onto empty steps and play the pattern: every step exact. If this is smeared too, stop and tell me.
5–6. Row 1 with the sequencer running another track; with live REC on (the next loop plays the recorded locks exactly).
7. Count silent hits: 32 staccato vs 32 legato alternating hits, CHOP page on screen and off (not fixed yet — just count).
8. Long decay; hold pad 1, hit pad 12, let go of pad 1: does pad 12 cut? Report with row 7 (same planned fix; not a failure of this one).
9. (Low priority) marker 55.50 vs 56 at SAMPLE POS RES = HI. 10. END ON once: each pad plays only its slice, first hit included.

## SMP CUT (file 3 only): FILTER, then FILTER again
LCT (low cut) and HCT (high cut) on the sample layer, per track, saved with the sound. The header may still say **FILTER** on this page (no title fix is built). First run of SMP CUT on any MKII — its filter runs inside the audio engine. MIDI OUT disconnected, nothing on MIDI IN.
1. **Only if this MKII ever ran an "LFO RND" mod build:** SMP CUT stores its setting where LFO RND stored its own, so a sound whose LFO RND settings you changed under that build can load with LCT/HCT switched on. Open each such project and check LCT/HCT on every track **before saving**; where they aren't OFF, set LCT 0 and HCT 127.
2. **First boot, before saving anything:** on a sound you haven't touched, LCT must show OFF (0) and HCT OFF (127). If not, stop and tell me — don't save.
3. Then the full SMP CUT rows (S1–S10). On the FX track, also take its LFO and delay/reverb settings to the extremes and listen to the delay/reverb for odd artefacts — stop and tell me if you hear any.
4. Clicks or dropouts with many tracks filtered: set LCT 0 / HCT 127 on every track, save, stop, go back to file 2.

## If it won't boot
Hold **FUNC** while powering on → **TRIG 4** (OS UPGRADE) → Transfer > CONNECTION > LEGACY OS UPGRADE → send `0_STOCK-1.73_and_RECOVERY_…syx` over **DIN MIDI**. This is served by the MKII's bootstrap, which none of these files changes.

## Don't
- Don't use FUNC + SAMPLE / FUNC + FILTER (page copy/paste/clear) while CHOP or SMP CUT is on screen, except as the last test rows say.
- Don't install OS 1.74.

## More
Full MKII test card (M0–M3, with the MK1 rows it reuses), what differs from the MK1, and the proofs: `../../upstream/rytm1_mods/mods/0001-chop/design.md`, section "MK2" (branch `chop`). Checksums: `SHA256SUMS` in this folder.
