# CHOP / Sample Focus for your MK1 (OS 1.73) — start here

Files **2** and **2b** are proven on your unit (see Hardware results at the bottom). Files **4b** and **5** have never run on a Rytm; every check that can be done on a computer passed.

## Before you flash
1. In Transfer, back up your projects / +Drive.
2. Have a DIN MIDI interface ready (recovery is DIN only), and `RECOVERY_stock_Analog-Rytm_OS1.73.syx` from this folder.
3. Flashing: Transfer > DROP, drag the file, press YES on the Rytm; don't power off during the update or the first boot after it. If Transfer refuses a file as "same version", nothing was written — stop, or use the recovery route below.

## What to flash tonight (in this order)
1. **`4b_SAMPLE-FOCUS-no-STR_…syx`** — the new CHOP page, without SMP CUT. Check CHOP still works (section A). If anything is off, go back to `2b_…`.
2. **`5_SAMPLE-FOCUS+SMP-CUT_…syx`** — the same CHOP plus SMP CUT. Only after 4b behaved. Run section B.

Fallbacks: `4b` (no SMP CUT) → `2b_CHOP+STEPLOCK_…` (proven) → recovery.

## The CHOP page (files 4b and 5): SAMPLE, let go, pause, SAMPLE again
First set **SETTINGS > CONTROLS > SEQUENCER CONFIG > SAMPLE POS RES = HI** (otherwise no decimals).

| Knob | Does |
|---|---|
| A **PAD** | which marker you're editing (1–12); hitting a pad also selects it |
| B **STA** | that marker, **hi-res**: slow turn = decimals (`40.`), FUNC + turn = whole steps |
| C **CHP** | right = CHOP ON for the selected track; left = OFF (pads stock again) |
| D **END** | right = ON: each pad also sets END to the next marker (plays just its slice). Left = OFF (END back to 120) |
| E **DIV** | re-chop into 1–12 equal slices (overwrites hand-set markers) |
| F **LAY** | turn right once: puts slice 1…N on the **empty** steps of the pattern (never touches your trigs). **No undo — try it on a copy of a pattern.** |
| G **RND** | GRID REC: hold steps, turn G → each held step gets a random slice |
| H | blank (STR removed — it didn't work) |

The STA dial graphic is now the plain default (the stock-STA-looking one was dropped to make room); values and decimals are unchanged.
While CHP is ON every pad goes to the chop track (TRK + pad won't select other tracks; turn CHP OFF first), and pad pressure still goes to the pad's own track.
**Step-lock** (proven on 2b): GRID REC (press REC with the sequencer stopped), hold step(s), hit a pad → each held step gets that marker as an STA p-lock.

### A. Check CHOP on 4b (then again quickly on 5)
1. Slow STA turn shows decimals; the pad plays from exactly that spot.
2. Pads, live REC (trig + STA lock), step-lock in GRID REC: all as before.
3. END ON: a pad plays only its slice. DIV 4: markers 0/30/60/90. LAY fills only empty steps. RND re-rolls held steps.
4. Turning a knob other than RND while holding a step then letting go: stock may toggle that step (as after any hold with no edit).

## SMP CUT (file 5 only): FILTER, let go, pause, FILTER again
LCT (low cut) and HCT (high cut) on the sample layer, per track, saved with the sound. **First run of SMP CUT on any MK1** — its filter runs inside the audio engine. For this test: MIDI OUT disconnected, nothing on MIDI IN.

### B. First run, in this order
1. **First boot, before saving anything:** on a sound you haven't touched, **LCT must show OFF (dial far left, 0)** and **HCT must show OFF (dial far right, 127)**. If not, stop and tell me — don't save.
2. FILTER, pause, FILTER → SMP CUT page. Turn LCT up: lows thin out. HCT down: highs roll off. Only on that track.
3. All 12 tracks playing with LCT/HCT on: listen for clicks or dropouts. **If you hear any:** set LCT 0 and HCT 127 on every track, save, stop, and go back to `4b`.
4. **In a copy of your project** (backup from "Before you flash" confirmed): set cuts on two tracks, save kit + project, power-cycle — the values must come back.
5. CHOP and SMP CUT in one session: CHOP on a track; to use SMP CUT on another track, turn CHP OFF, select the track, FILTER ×2.
6. Known quirk: turning HCT then LCT very quickly can make LCT jump back — just turn LCT again.

Full test card: `../mods/0001-chop/src/design.md` (H rows and S1–S10).

## If it won't boot
Hold **FUNC** while powering on → **TRIG 4** (OS UPGRADE) → Transfer > CONNECTION > LEGACY OS UPGRADE → send `RECOVERY_stock_Analog-Rytm_OS1.73.syx` over **DIN MIDI**. The recovery code in flash is never touched by these files (checked byte for byte).

## Don't
- Don't flash **rytm1_mods' own** SMP CUT or RANDOM builds: they use MKII offsets that are wrong for the MK1. (File 5 carries the MK1-fixed SMP CUT.)
- Don't use FUNC + SAMPLE / FUNC + FILTER (page copy/paste/clear) while the CHOP or SMP CUT page is on screen.

## All files
| File | What | Status |
|---|---|---|
| `1_CONTROL_…` | stock code, repacked by our tool | proves the tool |
| `2_CHOP_…` | first CHOP (3 knobs) + euclid/velocity | ✅ proven |
| `2b_CHOP+STEPLOCK_…` | CHOP + step-lock + euclid/velocity | ✅ proven |
| `3_only-if-chop-misbehaves_…` | first CHOP alone (bisect) | — |
| `4_SAMPLE-FOCUS_…` | Sample Focus **with STR** | superseded (STR doesn't work) |
| `4b_SAMPLE-FOCUS-no-STR_…` | Sample Focus, 7 knobs | 🧪 flash first |
| `5_SAMPLE-FOCUS+SMP-CUT_…` | Sample Focus + SMP CUT | 🧪 after 4b |
| `RECOVERY_stock_…` | Elektron's stock 1.73 | recovery |

Checksums: `SHA256SUMS`.

## Hardware results
- 2026-10-05, MK1 OS 1.73, CHOP build 3ea80d31…b00b: works. H1 (first hit plays from marker) YES; H2 (live-REC lock on the trig step) YES; H3 (CHOP page draws and switches back) YES; H4 (no crash or stuck notes, mashing and retriggers) YES. H5 (reinstall stock) pending.
- 2026-10-06, step-lock build a96657b4…caf6: works (founder).
- 2026-10-06, Sample Focus with STR (734607ae…14dc): STR writes the LFO but produces no sweep (founder) → STR removed.
