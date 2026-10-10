# CHOP / Sample Focus for your MK1 (OS 1.73) — start here

> **Fixed 2026-10-10: each live-REC hit gets its lock on its own step (keep the chop track selected); END mode removed, knob D blank.** New files: `5c` (5b plus this fix) and `4d` (4c plus this fix). Under live REC, a chop hit used to write its STA lock on the step the screen had cached. That was not always the step its trig was recorded on, so some trigs came out unlocked, and a stray lock landed on a nearby step. Now the lock is written on the trig's own step, right after the trig is recorded. END (knob D) is gone: D is blank, like H. The SAMPLE page's own END knob is stock. Everything else is the same as in 5b/4c: the first-hit fix, step lock, LAY, RND and SMP CUT. **5c and 4d have not run on a Rytm yet.** The old 5b/4c go to `_superseded/` once 5c behaves.

**Keep the chop track selected while you record** (don't press [FX]): with another track selected, chop hits record without a lock. **If you used END mode on 5b**, check the chop track's END on the SAMPLE page and set it back to 120; 5c no longer resets it.

**What to flash:** if you're on `5b` and it behaved, flash **`5c_SAMPLE-FOCUS+SMP-CUT_…syx`** directly. Otherwise flash `4d_SAMPLE-FOCUS-no-STR_…syx` first. Fallbacks: `5b` → `4c` → `2b` → recovery. Check the sha256 against `SHA256SUMS` first.

On 5c/4d these existing rows no longer apply, because there is no END: section D row 10, the END part of A3, and the D row of the knob table (D is now blank).

## L. The live-REC fix (5c / 4d): run right after the boot check
Use the clean kit from section D. Normal pad mode, CHOP ON on the chop track, power-on markers (pad 1 = 0, pad 12 = 110).

| row | do | 5c/4d must show |
|---|---|---|
| E1 | Open the CHOP page and turn knob D | D shows nothing and does nothing (like H). A, B, C, E, F and G work as before. |
| L-T1 | Empty pattern, live REC (REC + PLAY) at a slow tempo. Do 16 alternating hits of pad 1 and pad 12: some right on a step, some just before the next step lights. Then GRID REC: count the chop track's trigs and hold each one. | trigs = hits, each with STA = its pad's marker (0 or 110), and no extra trigs |
| L-T2 | Same setup: 8 hits just after a step lights, then 8 just before the next one lights | every one of the 16 is locked |
| L-T3 | The L-T1 rows at a slow and at a fast tempo, then let the pattern loop, hands off | never more trigs than hits; one trig on each step you hit, with the marker of the last pad hit on that step; no stray trigs. Keep live REC ON (REC + PLAY) for two full loops hands off, then stop and check in GRID REC that every trig still has its own pad's marker (not all the last pad's). The loop plays the recorded slices exactly; the base STA still follows the last pad you hit |
| L-T4 | A fast 1→12 roll under live REC with the CHOP page on screen | each trig has its own pad's marker. **If any trig carries the NEXT pad's marker, tell me.** That is a known edge (a stalled screen loop), with a planned fix. |

**Workaround on the older files (5b, 4c and before):** record chop slices with the step lock (GRID REC: hold the trig(s), hit the pad) or with LAY, and repair unlocked trigs the same way. Don't play pads over a pattern that still has unlocked chop trigs.

Also worth knowing: with CHOP on and live REC running, a MIDI note into the chop track also gets the current pad's marker as its lock.


> **Fixed 2026-10-09:** new files `4c` and `5b`. A pad hit now plays its own marker on the **first** hit (it used to start near the previous marker and "lock in" after repeats). The engine glided the start point to the new marker over ~100 ms; the pad now sets it at once, exactly as a sequencer p-lock does. The earlier `4b`/`5` are in `_superseded/2026-10-09-pre-snap/`. **5b works on your MK1 (2026-10-10).** 4c is the same fix without SMP CUT and hasn't been run yet.
>
> **Fixed 2026-10-08 (still in 4c/5b):** pressing a CHOP or SMP CUT knob while holding steps is ignored (it used to write a hidden lock). Files `2`, `2b` and `3` still have the old behaviour — don't *press* a CHOP knob while holding steps on those. They also have the old first-hit glide.

Files **2**, **2b** and **5b** have run on your unit (see Hardware results at the bottom). **4c** has not run on a Rytm yet; every check that can be done on a computer passed (built twice in the VM from scratch, same bytes; recovery code byte-for-byte stock).

## Before you flash
1. In Transfer, back up your projects / +Drive.
2. Have a DIN MIDI interface ready (recovery is DIN only), and `RECOVERY_stock_Analog-Rytm_OS1.73.syx` from this folder.
3. Flashing: Transfer > DROP, drag the file, press YES on the Rytm; don't power off during the update or the first boot after it. If Transfer refuses a file as "same version", nothing was written — stop, or use the recovery route below.
4. Check the file's sha256 against `SHA256SUMS` before you send it.

## What to flash (in this order)
- **You are on file `5` and it behaved:** flash **`5b_SAMPLE-FOCUS+SMP-CUT_…syx`** directly. It is file 5 with only the first-hit fix added (its SMP CUT code is byte-for-byte file 5's), so your SMP CUT results on file 5 still count.
- **Otherwise** (never ran 5, or it misbehaved): **`4c_SAMPLE-FOCUS-no-STR_…syx`** first, then `5b` only after 4c behaved (and then run section B in full on 5b).

On each file, the one order: **boot check → set up a clean kit → section D rows 1–4 → section A → the rest of D**. On 5b also B5 (CHOP and SMP CUT in one session).

Fallbacks: `5b` → `4c` → `2b_CHOP+STEPLOCK_…` (proven) → recovery. The pre-fix files are in `_superseded/2026-10-09-pre-snap/` if you want them as a comparison (section D's "control").

## The CHOP page (files 4c and 5b): SAMPLE, let go, pause, SAMPLE again
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

The STA dial graphic is the plain default; values and decimals are unchanged.
While CHP is ON every pad goes to the chop track (TRK + pad won't select other tracks; turn CHP OFF first), and pad pressure still goes to the pad's own track.
**Step-lock** (proven on 2b): GRID REC (press REC with the sequencer stopped), hold step(s), hit a pad → each held step gets that marker as an STA p-lock.

## D. The first-hit fix — run rows 1–4 right after the boot check
**Set up a clean kit first** (otherwise something other than the marker moves where a hit starts): simplest is a **fresh kit with only your sample on the chop track**. Otherwise, on that track: LFO DEP 0 (or LFO DST not STA/END); no velocity, aftertouch, performance or scene modulation of STA/END; LOP (loop) OFF; the machine's own LEV at 0 so you hear only the sample (leave the SAMPLE page's LEV up); no trigs or STA/END locks on its steps. **Don't use a kit saved while STR was on** — STR left the LFO sweeping STA at full depth in it.
Use a sample whose start and late part sound clearly different. Normal pad mode, CHOP ON, END OFF, power-on markers: pad 1 = 0, pad 12 = 110.

1. **Slow (the core).** Sequencer stopped, no REC. Pad 1, wait 2 s, pad 12, wait 2 s … eight hits. **Every hit must play its own slice, the first one included.**
2. **Rate.** Alternate pad 1 / pad 12 at 16ths (120 BPM), then as fast as you can. Own slice every time. *Judge only where each hit that sounds starts* — a silent hit is not a failure of this fix (overlapping pads can drop a hit; count those under row 7).
3. **Lock-in.** Hit pad 12 a few times, then roll pad 1 fast (about 30 ms apart), six hits: every hit starts at 0. Same rule for silent hits.
4. **Control.** LAY (F right) the slices onto the empty steps of a 16-step pattern, hands off, play it: every step plays its exact slice. If *this* is smeared too, stop and tell me — the diagnosis is wrong.

Then section A, then:

5. Row 1 again with the sequencer running another track: same result.
6. Row 1 with live REC on and the sequencer running: live hits play their own slice; the next loop plays the recorded locks exactly.
7. **Missing hits (not fixed yet — just count).** 32 staccato hits (let go before the next press) vs 32 legato (press the next pad, let go of the previous within ~20 ms), alternating pads. Count silent hits in each, once with the CHOP page on screen and once on another page. If the drops are mostly in the legato set, that's the known cause and the next fix.
8. **Note-off (just report).** Long decay on the chop track (1 s+). Hold pad 1, hit pad 12, let go of pad 1: does pad 12's sound cut? If yes, tell me with row 7's counts — same planned fix, not a failure of this one.
9. (Low priority) SAMPLE POS RES = HI: marker 55.50 vs 56, no difference expected.
10. **END ON once:** each pad plays only its slice, and the first hit is already right.

Optional comparison: rows 1–3 on the pre-fix file (`_superseded/2026-10-09-pre-snap/4b_…`): it should smear (first hit near the *other* pad's slice). If the pre-fix file already plays the first hit right, tell me.

## A. CHOP still works (on 4c, and again on 5b)
1. Slow STA turn shows decimals; the pad plays from exactly that spot.
2. Pads, live REC (trig + STA lock), step-lock in GRID REC: all as before.
3. END ON: a pad plays only its slice. DIV 4: markers 0/30/60/90. LAY fills only empty steps. RND re-rolls held steps.
4. Turning a knob other than RND while holding a step then letting go: stock may toggle that step (as after any hold with no edit).
5. GRID REC, hold a step that has a trig, **press** (don't turn) each knob A–G: nothing changes, no p-lock appears on that step.

## SMP CUT (file 5b only): FILTER, let go, pause, FILTER again
LCT (low cut) and HCT (high cut) on the sample layer, per track, saved with the sound. **If you already ran file 5 and it behaved**, SMP CUT is byte-for-byte the same in 5b: from section B run only step 1 and step 5. **Otherwise this is SMP CUT's first run on your MK1** — run all of B. For this test: MIDI OUT disconnected, nothing on MIDI IN.

### B. First run, in this order
1. **First boot, before saving anything:** on a sound you haven't touched, **LCT must show OFF (dial far left, 0)** and **HCT must show OFF (dial far right, 127)**. If not, stop and tell me — don't save.
2. FILTER, pause, FILTER → SMP CUT page. Turn LCT up: lows thin out. HCT down: highs roll off. Only on that track.
3. All 12 tracks playing with LCT/HCT on: listen for clicks or dropouts. **If you hear any:** set LCT 0 and HCT 127 on every track, save, stop, and go back to `4c`.
4. **In a copy of your project** (backup from "Before you flash" confirmed): set cuts on two tracks, save kit + project, power-cycle — the values must come back.
5. CHOP and SMP CUT in one session: CHOP on a track; to use SMP CUT on another track, turn CHP OFF, select the track, FILTER ×2.
6. Known quirk: turning HCT then LCT very quickly can make LCT jump back — just turn LCT again.
7. Hold a trig and press LCT and HCT: nothing changes.
8. If you ever pressed a CHOP knob while holding steps on file 2/2b, those steps may carry a hidden lock that 5b plays as LCT/HCT: check LCT/HCT while holding those steps before saving.

Full test card: `../upstream/rytm1_mods/mods/0001-chop/design.md` (also copied to `../mods/0001-chop/src/design.md`): "D41 rows" (= section D, with the one run order) and S1–S10.

## If it won't boot
Hold **FUNC** while powering on → **TRIG 4** (OS UPGRADE) → Transfer > CONNECTION > LEGACY OS UPGRADE → send `RECOVERY_stock_Analog-Rytm_OS1.73.syx` over **DIN MIDI**. The recovery code in flash is never touched by these files (checked byte for byte).

## Don't
- Don't flash **rytm1_mods' own** SMP CUT or RANDOM builds: they use MKII offsets that are wrong for the MK1. (File 5b carries the MK1-fixed SMP CUT.)
- Don't use FUNC + SAMPLE / FUNC + FILTER (page copy/paste/clear) while the CHOP or SMP CUT page is on screen.

## All files
| File | What | Status |
|---|---|---|
| `1_CONTROL_…` | stock code, repacked by our tool | proves the tool |
| `2_CHOP_…` | first CHOP (3 knobs) + euclid/velocity | ✅ proven |
| `2b_CHOP+STEPLOCK_…` | CHOP + step-lock + euclid/velocity | ✅ proven |
| `3_only-if-chop-misbehaves_…` | first CHOP alone (bisect) | — |
| `4_SAMPLE-FOCUS_…` | Sample Focus **with STR** | superseded (STR doesn't work) |
| `4c_SAMPLE-FOCUS-no-STR_…` | Sample Focus, 7 knobs, first-hit fix | 🧪 new (2026-10-09) |
| `5b_SAMPLE-FOCUS+SMP-CUT_…` | Sample Focus + SMP CUT, first-hit fix | 🧪 new (2026-10-09) |
| `RECOVERY_stock_…` | Elektron's stock 1.73 | recovery |
| `_superseded/2026-10-09-pre-snap/4b_…`, `…/5_…` | the same without the first-hit fix | superseded (first hit smears) |

Checksums: `SHA256SUMS`.

## Hardware results
- 2026-10-05, MK1 OS 1.73, CHOP build 3ea80d31…b00b: works. H1 (first hit plays from marker) YES; H2 (live-REC lock on the trig step) YES; H3 (CHOP page draws and switches back) YES; H4 (no crash or stuck notes, mashing and retriggers) YES. H5 (reinstall stock) pending.
- 2026-10-06, step-lock build a96657b4…caf6: works (founder).
- 2026-10-06, Sample Focus with STR (734607ae…14dc): STR writes the LFO but produces no sweep (founder) → STR removed.
- 2026-10-09, all CHOP builds incl. 2b (founder): hits land between markers, lock in after repeats, some retriggers missing → first-hit fix in 4c/5b (section D); the missing retriggers are counted in D7/D8 before their fix is built.
- 2026-10-10, file 5b (ac094b30…c3b4), first-hit fix: "the chopping works excellent" (founder). SMP CUT on file 5 the day before: worked so far (per-row detail pending).
