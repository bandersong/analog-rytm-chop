# CHOP for your MK1 (OS 1.73) — start here

Nothing here has run on a Rytm yet. Every check that can be done on a computer passed; the rest is the test below.

## Before you flash
1. In Transfer, back up your projects / +Drive.
2. Have a DIN MIDI interface ready (recovery is DIN only), and `RECOVERY_stock_Analog-Rytm_OS1.73.syx` from this folder.

## Flash (Transfer > DROP, drag the file, press YES on the Rytm; don't power off during the first boot after)
1. `1_CONTROL_stock-code_…syx` — stock code, just repacked by our tool. It should boot and play exactly like stock. This proves the tool on your unit.
2. `2_CHOP_…syx` — CHOP, plus euclid accents and velocity humanise from rytm1_mods (no SMP CUT).
3. `3_only-if-chop-misbehaves_…syx` — only to narrow down a problem (CHOP alone).

If Transfer refuses a file as "same version", nothing was written. Stop, or use the recovery route.

## NEWEST: Sample Focus + SMP CUT (`5_SAMPLE-FOCUS+SMP-CUT_…syx`) — not yet tested on hardware
- **SAMPLE ×2 → CHOP**: PAD, STA (hi-res), CHP, END, DIV, LAY, RND. Knob H is blank (STR removed — it didn't work).
- **FILTER ×2 → SMP CUT**: LCT (low cut) and HCT (high cut) on the sample layer, per track, saved with the sound.
- The CHOP STA dial now uses its own default graphic (the stock-STA-looking dial was dropped to make room). Values and decimals are unchanged.
- **This is SMP CUT's first-ever run on an MK1**, and its filter runs inside the audio engine. Test it before you rely on it:
  1. First boot: on a sound you haven't touched, LCT/HCT must read "off" (no cut). If not, stop and tell me **before saving anything**.
  2. FILTER, pause, FILTER → SMP CUT page. Turn LCT up: lows thin out. HCT down: highs roll off. Only on that track.
  3. All 12 tracks playing with LCT/HCT on: listen for clicks or dropouts (that would mean the filter is too heavy for the audio engine).
  4. Set cuts on two tracks, save kit + project, power-cycle: the values must come back.
  5. Then CHOP as before (pads, live REC, step-lock, END/DIV/LAY/RND), with CHP OFF when you want to select another track for SMP CUT.
  6. Known quirk: turning HCT then LCT very quickly can make LCT jump back — just turn LCT again.
- Fallbacks: `4b_SAMPLE-FOCUS-no-STR_…` (same CHOP, no SMP CUT), then `2b_CHOP+STEPLOCK_…` (proven).
- Full list: design.md, test card S1–S10 and H rows.

The SMP CUT warning further down ("don't flash rytm1_mods' SMP CUT builds") still applies to **rytm1_mods' own** builds; file 5 carries the MK1-fixed SMP CUT.

## Sample Focus with STR (`4_SAMPLE-FOCUS_…syx`) — superseded: STR doesn't work; use 4b or 5
Everything from the step-lock build, minus euclid accents and velocity humanise, plus a full 8-knob CHOP page:

| Knob | Does |
|---|---|
| A **PAD** | which marker you're editing (1–12) |
| B **STA** | that marker, now **hi-res**: slow turn = decimals (`40.`), FUNC + turn = whole steps — same as stock STA |
| C **CHP** | CHOP on/off |
| D **END** | right = ON: each pad also sets END to the next marker (plays just its slice). Left = OFF (END back to 120) |
| E **DIV** | re-chop into 1–12 equal slices (overwrites hand-set markers) |
| F **LAY** | turn right once: puts slice 1…N on the **empty** steps of the pattern (never touches your trigs) |
| G **RND** | GRID REC: hold steps, turn G → each held step gets a random slice |
| H **STR** | **experimental** time-stretch setup: sets the track's LFO to sweep STA over 1–64 steps. Keep END OFF, set RETRIG on the steps yourself (stock RETRIG menu), LFO.T on |

Before you try it:
- Set **SETTINGS > CONTROLS > SEQUENCER CONFIG > SAMPLE POS RES = HI** for decimals.
- **Turn STR OFF before CHP OFF** — after CHP OFF the STR knob can't undo the LFO (reload the kit to restore).
- **LAY has no undo** — try it on a copy of a pattern.
- Fallback if anything's off: `2b_CHOP+STEPLOCK_…` (the version that works today).

What to check (full list: design.md H7–H14): slow STA gives decimals and the pad plays that exact spot; END plays only the slice; DIV 4 gives 0/30/60/90; LAY fills only empty steps; RND re-rolls held steps; everything from before (pads, live REC, step-lock) still works; STR: does each retrig restart the sweep, and is 16 really 16 steps?

## NEW: step-lock build (`2b_CHOP+STEPLOCK_…syx`)
Same as CHOP, plus: **in GRID RECORDING, hold one or more steps and hit a pad → each held step gets an STA p-lock = that pad's marker.** Confirmed working on the MK1 (2026-10-06). Flash it like the CHOP file; if anything is off, flash `2_CHOP_…` again (the version that works today).

How to test it:
1. CHOP ON for your track (that track selected).
2. Press **[REC]** with the sequencer stopped → GRID RECORDING (stock only holds steps for p-locks in grid mode).
3. Hold a step's trig key, hit pad 5 → check the step's STA on the SAMPLE page (still holding) = 40. Let go: the trig must still be there.
4. Hold several steps, hit a pad → all of them get that marker.
5. Hold a step, hit pad 2 then pad 9 → the lock ends at 80.
6. Afterwards, with no step held, the SAMPLE page's base STA should be unchanged.
7. Note what the pad preview plays from while a step is held (the new marker, the step's old lock, or the base STA).
8. Avoid sending MIDI notes into the Rytm while testing.

## Use it
1. Pick the track with the sample you want to chop (normal pad mode, not chromatic).
2. Press **SAMPLE**, let go, pause, press **SAMPLE** again → the **CHOP** page (knobs PAD / STA / CHP). A quick double-tap opens the sample list instead (that's stock).
3. Turn **CHP** right → ON. CHOP now belongs to the track that was selected.
4. Hit pads 1–12: the sample plays from markers 0, 10, 20 … 110.
5. To move a marker: hit the pad (or turn PAD), then turn **STA**.
6. Live REC (REC + PLAY) and play pads: each hit records a normal trig with an STA p-lock — it saves with the pattern and plays on stock firmware too.
7. Turn **CHP** left → OFF. Pads are stock again. Power-off also ends CHOP and resets the markers (they live in RAM by design).

While CHP is ON, every pad goes to the chop track (TRK + pad won't select other tracks), and pad pressure still goes to the pad's own track.

## If it won't boot
Hold **FUNC** while powering on → **TRIG 4** (OS UPGRADE) → Transfer > CONNECTION > LEGACY OS UPGRADE → send `RECOVERY_stock_Analog-Rytm_OS1.73.syx` over **DIN MIDI**. The recovery code in flash is never touched by these files (checked byte for byte).

## Don't
- Don't flash rytm1_mods' SMP CUT or RANDOM builds: they use an MKII offset that is wrong for the MK1.
- Don't use FUNC + SAMPLE (page copy/paste/clear) while the CHOP page is on screen.

## Please check (and tell me)
1. Does a pad hit play from its marker on the **first** hit?
2. Under live REC, does the STA lock land on the same step as the trig?
3. Does the CHOP page draw right and switch back to SAMP?
4. No crash or stuck notes on fast rolls, two pads held, or holding a pad while turning CHP.
5. Going back to stock (same-version reinstall) works.

Full test card: `../mods/0001-chop/src/design.md` § "Hardware-only unknowns". Checksums: `SHA256SUMS`.

## Hardware results
- 2026-10-05, MK1 OS 1.73, CHOP build 3ea80d31…b00b: works. H1 (first hit plays from marker) YES; H2 (live-REC lock on the trig step) YES; H3 (CHOP page draws and switches back) YES; H4 (no crash or stuck notes, mashing and retriggers) YES. H5 pending.
- 2026-10-06, step-lock build a96657b4…caf6: works (founder).
