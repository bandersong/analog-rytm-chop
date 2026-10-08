# 0010 CHORD - chord memory for the Analog Keys (OS 1.56)

Corp Keys chord memory, TRUTH K1-K5 and K7 (CEO 2026-10-08; founder: "the mix, start with
hold and capture"). Sources: corp `keys-re/results.json` (lanes notes, osc, arp and
platform, with their skeptics; a skeptic correction wins), corp `keys-gesture` and
`keys-gesture-sk` (the gesture decision, skeptic fixes applied below), the Keys panel
(corp `keys-panel-crash`, `keys-panel-purpose`, `keys-panel-brick`) as fixed by corp
`keys-integrator`, and the Keys gate (`keys-gate-fableA`, `keys-gate-fableB`,
`keys-gate-opus`) as fixed by corp `keys-fixer` under TRUTH K7 (a)-(f), and the K7 fix
panel (`keys-fix-panel-hold`, `keys-fix-panel-purpose`) as fixed by corp
`keys-fix-integrator` (HOLD release-all read from the key scanner, the stuck-note
recovery, the HOLD fallback and re-latch, card order; no code change). Built:
`make DEVICE=keys chord`. **Never run on hardware.**

## Summary (README text)

For the **Analog Keys**, OS 1.56. (An Analog Four MK1 runs the same OS image, but its
octave key sends a different key code, so the capture gesture never fires there and chord
mode cannot be turned on: the mod is inert on an A4 MK1, not harmful.)

Hold 2 to 4 keys on the keybed, then hold **FUNCTION** and press **OCTAVE UP**. The held
keys become the chord and chord mode is on; the screen shows `CHORD ON: 0 4 7` (the
intervals in semitones). From then on each key you play sounds the whole chord, transposed
to that key: the key is the root, and the other notes keep their distance from it.
Releasing the key releases the whole chord. To change the chord, hold the new one and do
the gesture again. Chord mode can stay on, but then a key whose notes all already sound
from the other held keys is left out (Limits). For an exact result: release everything,
FUNCTION + OCTAVE UP with nothing held (`CHORD OFF`), then hold the new keys and capture.
FUNCTION + OCTAVE UP with nothing held and nothing latched by HOLD turns chord mode off
(`CHORD OFF`). Nothing is saved: a power cycle turns chord mode off and forgets the chord.

**HOLD**: to latch a chord, hold its key and press HOLD while nothing is latched - the
whole chord stays. While the HOLD key is down, or while any note is latched, keys play
single notes exactly as stock (no chords) until every latched note is released. So a key
held over a latched chord plays one note, and pressing HOLD then latches that one note and
releases the chord. To latch a different chord, first release the latched one, then hold
the new key and press HOLD. To release every latched note (the manual's "press the [HOLD]
key to release all"): with no key down, **tap HOLD on its own** - press and release it
with no other key, panel or keybed, in between, and FUNCTION up. **Stuck note**: release
every key and tap HOLD twice (the first tap latches a note that stock left held under a
key no longer down; the second releases it). Latched notes are never captured.

The chord needs voices: set the kit's POLY CONFIG so that the track you play has a poly
group with enough voices (up to 4). Capture works on internal tracks: with MIDI EXT on,
the gesture with keys held shows `CHORD: NO CAPTURE HERE` and changes nothing (playing
chords with MIDI EXT on works). Under live REC each played chord is recorded as a normal
stock chord trig (NOTE + NO2/NO3/NO4), which plays on stock firmware, with the merge rules
of stock's recorder (below).

## What it does

### Capture (FUNCTION + OCTAVE UP)

On the press of OCTAVE UP (key code 164) with FUNCTION held - KeyEvent flags at +16: bit 0
down = 1, bit 1 FUNCTION = 1, bit 3 repeat = 0, the same test the base view handler makes
for its own FUNCTION combos - `chord_capture` reads the KeyboardView's held-note table
(the vector at this+124..+128, 20-byte entries `{+0 kind, +4 key id, +8 note, +12 track,
+16 state}`) and counts an entry when (TRUTH K7 b):

- kind = 1 (an internal-track note: 0x400b81c4 plays it), and
- state = 1 (held - a key physically down; 2 = latched by HOLD, never counted: K7 a), and
- track = `kv_active_track(this+116)` (0x400aaba8) - the same getter whose value stock
  stores in a kind-1 entry's +12 at the note-on (0x400b9834..0x400b9842, 0x400b9c74).

Each counted entry stands for **its key**, with the note that key was pressed at
(TRUTH K7 c): `chord_root[key id]`, which `chord_on` records at every note-on call (below),
never the entry's own note - with chord mode on a key's entries are its chord tones, and
its root may sit under another key (stock's duplicate guard leaves a shared note with the
key that started it), so the table's notes cannot give the root (corp keys-panel-purpose
F1, keys-panel-crash F2: the v1 "lowest note per key" rule gave `CHORD ON: 0 11` for C + G
under chord 0 4 7; this build gives `0 7`). A key id above 127 has no record (keybed and
trig-key ids are expected well below; not traced) and falls back to the entry's note when
it is its key's lowest. The roots are made distinct in a sorted buffer of five (a fifth
distinct root means "five or more"). Then:

| roots counted | result | popup |
|---|---|---|
| 0, and the table has **no entry at all** (any kind, any state) | chord mode OFF | `CHORD OFF` |
| 0, but a key is held (a state-1 entry of another kind or track: MIDI EXT kind 3, the kind-2 path, another track) | nothing changes | `CHORD: NO CAPTURE HERE` |
| 0, and only HOLD-latched notes (state 2) | nothing changes | `CHORD: RELEASE HOLD FIRST` |
| 1, or 5 or more | nothing changes | `CHORD: HOLD 2-4 KEYS` |
| 2..4 | only the roots at most **63** semitones above the lowest are kept (a stock chord trig stores NO2..NO4 as 64 + semitones, so -64..+63 is all live REC can record); 2..4 left: root = the lowest, `chord_iv[i]` = root[i] - root, `chord_n` = n, chord mode ON; fewer than 2 left: `CHORD: HOLD 2-4 KEYS`, nothing changes | `CHORD ON: 0 a b c` |

Chord mode is turned off **only** with an empty table (K7 b; corp keys-gate-opus F1: v1
turned it off while a HOLD-latched chord was sounding, the start of a hung-note path, and
keys-panel-crash F3 / keys-panel-purpose F2: v1 turned it off with MIDI EXT keys held).
In the built image the only clear of `chord_mode` (0x40234b22) is reached only from
`moveal %a2@(124),%a0; moveal %a2@(128),%a1; cmpal %a1,%a0; bccs` (0x40234b04..0x40234b0e),
i.e. begin >= end, after nothing was counted (`tstl %d6; bnes` 0x40234b00); chord_on never
writes it (corp keys-fixer `props.v2.out` (b)).

After the capture the stock path runs exactly as in unmodified 1.56: the re-emitted
`cmpil #164,%d3` and the jump back to 0x400b9e62 send the event to the octave path, which
for a FUNCTION press reaches the base View::handleKey 0x4005fa6e; that handler acts only on
codes 80/81/82 and returns 0. So the gesture changes no octave, as in stock.

### Play (the note-on hook)

`chord_on` replaces the 6-byte prologue of the KeyboardView note-on routine 0x400b9818
(this, key id, note, velocity). Its only callers are `jsr %pc@(0x400b9818)` at 0x400b9d62
(handleNoteEvent, the keybed) and 0x400ba5d0 (handleKey, key codes 16..28 - by inference
the trig keys in a keyboard mode; the OS 1.56 manual names no such mode for the Analog Keys,
whose keyboard-mode keys are MULTI MAP, MIDI EXT and HOLD, so that caller is untested and
out of scope for v1: test row K12). On every call (unless `chord_busy`) it first stores the
call's note in `chord_root[key id]` (key ids 0..127; a note above 127 is stored as 0xFF, no
root) - RAM of this mod only, so stock's behaviour is unchanged by it. Then:

1. **Chord mode off, a nested call (`chord_busy`), or a note stock sends down its kind-2
   path** -> pure stock: a branch to `chord_stock` (stock's two displaced instructions
   `linkw %fp,#-88; moveq #127,%d0` + `jmp 0x400b981e`) with the caller's stack and
   d2-d7/a2-a6 untouched (built: 0x40234860, 0x4023488c, 0x402348bc). The kind-2 test is
   stock's own (0x400b984e..0x400b9872: `boot_flags & 0x100000 ? sel_kind2_test(this+116)
   : UIStates+416`); what that path is - transpose or arp input - is not identified
   (keys-sk-notes plan problem 2). handleNoteEvent's own transpose branch (UIStates +424,
   0x400b9d8a -> 0x400ab198) never reaches 0x400b9818, so chords never apply there either.
2. **HOLD (TRUTH K7 a)**: chord mode on, and the HOLD key is down (`uist_hold`, UIStates
   +436) **or** any entry of the table is HOLD-latched (state 2) -> **no chord**: the note
   goes to stock as the one note the key plays (the same branch to `chord_stock`,
   0x402349a6), with one exception, the **orphan guard** below.
3. Otherwise (chord mode on, HOLD up, nothing latched) -> **the chord**: `chord_stock` is
   called once per tone, root first, then root + each interval, with the **same key id**
   and velocity (built: the only `bsr chord_stock`, 0x402349ea, in the loop
   0x402349aa..0x40234a06). Every tone gets, from stock and unchanged: the range check (a
   tone above 127 is skipped by the stub, K7 d: `moveq #127,%d0; cmpl %d2,%d0; bcss`
   0x402349d6..0x402349da; stock also rejects > 127), the duplicate guard (a tone already
   in the table on that track is not retriggered: stock only marks the existing entry held,
   and it stays owned by the key that started it), the voice / MIDI call (kind 1 internal
   0x400b81c4 -> 0x40064f1c; kind 3 MIDI EXT 0x400668c6, each with its note-off), and the
   held-table entry under that key id. With HOLD up and nothing latched no tone can be
   latched (stock's state = 1 + HOLD down, 0x400b9c5c) and stock's first-note release
   (this+136, needs HOLD down) cannot fire.

Built-image proof that a chord is never played on the HOLD paths (corp keys-fixer
`props.v2.out` (a)): every path from `chord_on` to the loop's `bsr chord_stock` crosses the
fall-through of `tstb %d4; bnes` (0x4023497a/c: d4 = the byte `uist_hold` returned,
written only at 0x40234934) and the taken `tstl %d3; beqs` (0x4023497e/80: d3 = 0 at
0x40234936, set to 1 only at 0x40234952, right after `cmpl %a1@(16),%d0` with d0 = 2 while
the scan walks begin..end in 20-byte steps); with either edge removed the call is
unreachable. From the HOLD branch (0x40234982) 13 instructions are reachable, with no call
among them and two exits: `rts` (the guard) and `braw chord_stock` (one stock note), each
after restoring d2-d6/a2 and the stack.

**The orphan guard** (the one place the HOLD paths differ from stock). Stock's duplicate
guard (0x400b9c94: `moveq #1; movel %d0,%a0@(16)`) turns an existing entry held (state 1)
whatever its state and owner, and leaves the owner unchanged. When that entry was latched
by HOLD under **another** key, the note becomes "held" under a key nobody may be holding:
the pressing key's release does not free it (0x400b872e frees only its own key id), the
latched release does not (0x400b88c6 frees only state 2), and HOLD's release-all no longer
reaches it - a hung note. In stock one key plays one note, so this needs an octave change
(stock's own path, still there with chord mode off); with a latched chord any key on one of
its tones does it. So on the HOLD paths, when an entry stock's own duplicate predicate
would match - same kind (1, or 3 on MIDI EXT: `kv_midi_ext` 0x400ab51c), same note, same
+12 value (the track `kv_active_track`, or the MIDI channel computed as stock does at
0x400b9a08..0x400b9a30) - is latched (state 2) under a key id other than the caller's, the
note is **not sent**: the latched note keeps sounding latched with its own key and is
released the stock ways (HOLD). Not skipped: a latch under the **same** key (stock's "press
the key of a held note a second time releases it", manual HOLD MODE), and a note while this
+136 is set and HOLD is down (stock then frees this kind's latched notes before its
duplicate scan, 0x400b9874, so nothing is taken over). Stock with a latched note under
another key would also start no sound (the duplicate guard makes no voice call); the only
difference is that the latch stays a latch. Built: the scan 0x4023493a..0x40234978, the
guard 0x40234982..0x4023499c.

Why the guard is needed beyond K7 (a)'s literal "pure stock": a chord tone becomes latched
whenever the player latches a chord (hold its key, press HOLD - stock's HOLD press turns
every held entry into state 2, 0x400ba22e..0x400ba256), and from then on every note is a
single stock note. Without the guard, "hold C, HOLD, release C, press E" leaves E held
under key C, sounding after E's release and after HOLD's release-all (corp keys-fixer
`hold_model.all.v3.out`, version `k7-noguard`: 4,668 transitions with chord mode on create
such a hung tone; shortest `C down ; HOLD down ; C up ; E down`). The guard is the one non-stock act on the HOLD paths, ratified by the CEO (TRUTH K8 a).

**Note-offs are never hooked.** Stock's note-off 0x400b872e(this, key id) releases every
held entry with that key id and state 1, so releasing the key releases all its tones.

### No hung note: every ordering (corp keys-fixer `hold_model.py`)

A Python model of stock 1.56's rules (each read from the dis and cited in the model:
note-on with its HOLD / this+136 / duplicate logic, note-off by key id and state 1, the
latched release by kind/track, the HOLD press (release this kind's latches when a key is
held, then every held entry -> latched) and release, and the KeyEvent bit-4 release-all,
explored both with and without that bit; its meaning, a clean tap, was read from the key
scanner after these runs: Limits, HOLD) plus this stub, run
breadth-first over **every reachable state** (every ordering of every event, any length):
chord keys and plain keys (C, E, G, whose chords 0 4 7 share tones), HOLD down/up, the
gesture (capture, re-capture, OFF), starting with chord mode off and with 0 4 7; then with
MIDI EXT toggled at any point; then with an octave key (C2) and the OCTAVE toggle.
Checked in every reachable state: (I1) every held (state 1) tone's key is physically down -
otherwise that tone outlives every key that started it and is not latched; (I2) releasing
every key, then one HOLD tap (press, release with bit 4), leaves nothing sounding;
(I3/I4) with chord mode off, HOLD down or a latched entry, at most one stock call and the result is unmodified stock's,
except where the guard fired, and it fires only where stock would hand another key's
latched tone to that key.

| run (`hold_model.all.v3.out`) | reachable states | I1 / I2 violations | hung tones created with chord mode on | with chord mode off |
|---|---|---|---|---|
| this build, chord off at start | 40,638 | 0 / 0 | 0 | 0 |
| this build, chord 0 4 7 at start | 42,160 | 0 / 0 | 0 | 0 |
| this build, + MIDI EXT toggle | 23,006 | 0 / 0 | 0 | 0 |
| this build, + octave key and OCTAVE toggle | 60,918 | 1,060 / 1,060 | 0 | 208 = stock's own octave path |
| unmodified stock 1.56, octave key and OCTAVE toggle | 594 | 80 / 80 | - | 16 (`C2 down ; HOLD down ; C2 up ; oct ; C down`) |
| K7 (a) without the guard (literal pure-stock bypass) | 70,677 | 8,375 / 8,375 | 4,668 | 0 |
| v1 5f77e62 (reviewed build) | 581,751 | 66,732 / 66,732 | 0 | 23,052 (gesture OFF over a latched chord) |

In the octave run every hung tone is created by a note-on made with chord mode off -
stock's own octave path (a key reaching another key's latched note after an octave
change; chord mode off means pure stock, and every entry was started after the table was
last empty), which unmodified stock has too (16 such transitions in its own run) - and
none by a note-on with chord mode on, where the guard leaves the latch alone. 22 of the
1,060 violating states are not reachable in unmodified stock as a whole only because a
later capture turned chord mode back on while such a stock-made hung tone still sounded. I3/I4: 0
failures in every run of this build. Per ordering, every started tone has a stock release
path: a held tone is freed by its own key's release (I1: that key is down), a latched tone
by HOLD's release of latched notes (I2), and the guard never starts or stops a tone.
The I2 violations of the octave run are those stock-made held tones: one tap's press
latches them (and clears this+136, so that tap's release releases nothing), and a second
tap releases them. Corp keys-fix-panel-hold re-ran the orderings with two taps (its own
model, `hunt_A.out`, `hunt_small.out`, `hunt_rest.out`): nothing is left after two taps in
any state of any run, this build or unmodified stock - the "tap HOLD twice" stuck-note
recovery (Limits, HOLD).
Named card orderings run through the same model: `scenarios.v2.out`; the card as corrected
by corp keys-fix-integrator (K7 variant, K11, K11h-K11j, the HOLD fallback, the exact
re-capture, the two-tap recovery): `int_scen.out`. Not modelled: the
keybed / trig-key shared key ids (stock's own early release, Limits), more than one
track (each entry keeps its track; release is by key id; HOLD's release-all is
track-blind), the kind-2 path (never expanded, its own entries).

### State (RAM only)

136 bytes at the end of the stub (0x40234c7c..0x40234d04 in this build): `chord_mode`,
`chord_busy`, `chord_n`, a pad byte, `chord_iv[4]` (`chord_iv[0]` = 0), `chord_root[128]`.
The image bytes are the power-on defaults (chord mode off; every `chord_root` byte 0xFF, no
root). Written only by `chord_capture` and `chord_on`, both in the UI task: key events
(UI-loop type 0, a `8KeyEvent`, vtable 0x4017a0b8) and note events (types 2/3, a
`9NoteEvent`, vtable 0x4017a86c) are both dispatched by the UI loop 0x40096ce2, one at a
time. Every store into `chord_root` is bounded: the index is the key id after an unsigned
`<= 127` test (0x40234864..0x40234884), and the table is exactly 128 bytes.

## Limits

- **4 notes** including the root (4 voices). A chord tone above MIDI note 127 is skipped
  (silent) - TRUTH K7 (d), which amends K2's "clamp".
- **Poly**: a chord sounds as a chord only on a track whose voice is in a poly group with
  enough voices (stock POLY CONFIG, stored per kit; manual: "Any track can play up to four
  notes using its own track sound"). When all poly voices are busy stock steals the
  oldest. On a voice that is not poly-enabled the outcome is UNKNOWN (keys-notes N20;
  most likely one note sounds).
- **RAM only**: power cycle = chord mode off, chord forgotten. Nothing is stored in the
  kit, the pattern or the global settings.
- **HOLD** (code: UIStates +436 is 1 only while the HOLD key is down - set at its press
  0x400ba192, cleared at its release 0x400ba176 and at init 0x40022722). While HOLD is down
  or any note is latched, no chord is played (K7 a): latch a chord by holding its key and
  pressing HOLD while nothing is latched; afterwards keys play single notes until every
  latched note is released. A HOLD press latches every held note, after releasing the
  earlier latched notes of the keyboard's current kind (this track's, or all MIDI EXT
  ones) when a held note of that kind exists (0x400ba1a2..0x400ba256); after a HOLD press
  the first note played with HOLD down releases them too (0x400b9874). So a key held over a
  latched chord plays one note, and HOLD then latches that note and releases the chord
  (corp keys-fix-panel-purpose F1): to latch a different chord, release the latched one
  first (tap HOLD), then hold the new key and press HOLD (test row K11j). Pressing the
  latched chord's own key again releases only its root (stock: "the key of a held note
  pressed a second time releases it"; the other tones are latched under that key but are
  other notes); a key on one of the other tones changes nothing (the orphan guard).
  - **Release all** (manual: "press the [HOLD] key to release all") is the branch at
    HOLD's release, 0x400b9e74..0x400b9e96 -> 0x400ba14e, a call 0x400b88c6(this, 0, -1)
    that frees every latched note of any kind and track. It runs only when (i) KeyEvent
    bit 4 is set: the panel key scanner sets it on a release (0x40062d3e) only when the
    released key is the last panel key pressed (0x40062c46 `cmpl 0x401ebaf4,%d4`) and its
    bit in 0x408c390c is clear (tested at 0x40062d36; set only by 0x40062938, for a key
    that is down, whose callers were not traced) - a tap; (ii) FUNCTION is up
    (0x400b9e8e); (iii) this+136 is still set: the HOLD press sets it (0x400ba19e) and
    clears it when it latched a held note (0x400ba24e), and a note played while HOLD is
    down clears it (0x400b9884). So: with no key down, tap HOLD on its
    own - press and release, no other key (panel or keybed) in between. Read from the code,
    not yet seen on hardware (test rows K11 f, K15). (Corp keys-fix-panel-hold F1; this
    replaces "bit 4 UNKNOWN".)
  - **Stuck-note recovery**: release every key and tap HOLD twice. A note stock left held
    under a key that is no longer down (stock makes these itself: an octave change under
    HOLD, a keybed key and a trig key on the same key id, or the kind-2 path; the chord
    path makes none, corp keys-fix-panel-hold) is latched by the first tap's press, which
    then clears this+136, so that tap's release releases nothing; the second tap releases
    it (`int_scen.out`, octave orphan, stock and this build).
  - **If a tap does not release** (fallback): hold a key that is **not** one of the
    latched notes (e.g. D over a latched C chord), press HOLD (it releases this track's
    latched notes and latches D), release both, then press and release D (a latched note's
    key pressed again releases it). A key on a latched note does not work: the orphan
    guard sends nothing for it, so it has no held entry, and HOLD's press releases the
    latched notes only when its scan 0x400b7e90 finds a held (state 1) entry (predicate
    0x400b7ae8; `beqs 0x400ba22e` at 0x400ba1d2 / 0x400ba200 / 0x400ba21c skips the release
    0x400ba226). Model: `int_scen.out`, fallback with D (empty) and with E or G (C E G stay
    latched) (corp keys-fix-panel-purpose F1).
  - Latched notes are never captured (K7 a), and with only latched notes the gesture shows
    `CHORD: RELEASE HOLD FIRST` and changes nothing.
- **MIDI EXT** (a keyboard-mode key, manual item 38): notes go out as kind 3 (MIDI), never
  counted, so capture needs MIDI EXT off; the gesture with keys held on MIDI EXT shows
  `CHORD: NO CAPTURE HERE`. Chords do play on MIDI EXT.
- **Re-capture with chord mode on** reads each held key's root (`chord_root`), but a key
  is seen only through the table entries it owns. A key all of whose tones were already
  sounding when it was pressed owns none (stock's duplicate guard adds no entry for it)
  and is left out: chord 0 4 7, hold C, G#, B, then E -> `CHORD ON: 0 8 11`, not
  `0 4 8 11` (corp keys-gate-opus F4; `scenarios.v2.out`). For an exact capture, release
  everything, turn chord mode off (gesture with nothing held), then hold the keys and
  capture. With chord mode off every held key owns its one note, so captures are exact.
- **Shared key ids**: keybed keys and the trig-key note path share key ids 0..12 in the
  held table (keys-sk-notes plan problem 5). Holding keybed key k and trig key k at once,
  one release frees the other's tones too (stock does the same for single notes; a chord
  makes more tones depend on it), and the later press overwrites `chord_root[k]`, so a
  capture at that moment reads that note for both.
- **Overlapping chords**: a tone another key already holds down is not retriggered and
  stays owned by that key (stock duplicate guard, keys-notes N5): releasing the key that
  started it releases it, even while the later key is still down.
- **Popup**: shown through stock's popup 0x40021774 (the call stock uses for `Octave: %d`
  from the same handler). Stock skips it while UIStates byte +69 is set (meaning
  UNKNOWN); how the popup text reaches the screen was traced only to the draw gate
  0x40021840, so on-screen appearance rests on stock's own Octave popup using this call.
- **Over menus**: most menus pass FUNCTION + OCTAVE UP down (keys-gesture-sk), so the
  gesture can capture (and pop up) while a menu is open; modal views that take every key
  stop it first. The view-stack order was not traced.
- **MIDI in / MULTI MAP / arpeggiator / transpose / grid record**: out of scope for v1 and
  untested - whether external MIDI notes also arrive as UI-loop types 2/3 (and so get
  chords) is UNKNOWN; MULTI MAP, the arpeggiator, the TRANSPOSE key path and grid/step
  record were not traced (test rows K18-K21: note what happens).
- **Message load** (keys-sk-notes plan problem 7; corrected per corp keys-panel-crash F4).
  Every internal-track note stock starts posts one 32-byte note message (UI-loop type 12,
  for the recorder), and so does every voice-off: voice-on 0x40064f1c (ring call
  0x400651a6) and voice-off 0x40064c4e (called from 0x400b82c4 at 0x400b8364; its only early
  exit is note > 127, then `jsr 0x40063ca6` at 0x40064dfc) both go through 0x40063ca6, which
  copies the message into a 128-slot ring at 0x408e3c20 (index 0x408e396c, advanced with
  `& 127` and no full check, 0x40063cd8-0x40063ce6) and posts its pointer to the UI queue
  0x4092f098 (1024 entries, initialised at 0x40096454: `pea 0x400` ... `jsr 0x40001e54`;
  the post 0x40001eb6 has no overflow check). A 4-tone chord key posts 4 at its press and
  4 at its release: up to 8 ring messages per key, so the ring wraps once about 16 chord
  keys' presses and releases are pending before the UI loop drains them (the result would
  be lost or repeated recorder messages, not a crash; not a playable case; untested).
  Voice on/off also post to a second queue 0x408fb454 when a per-voice flag is set
  (0x40064d60..0x40064d82, 0x4006501e..0x40065042); its capacity is UNKNOWN.

### Live REC (the merge caveat, keys-notes N8/N10/N11 + keys-sk-notes plan problem 3)

Each tone reaches the recorder as its own note (0x400b81c4 -> 0x40064f1c -> UI message type
12 -> 0x40094b4a -> rec_note_to_step 0x400a6570). The recorder writes a note as the step's
NOTE (clearing NO2..NO4) only when its first-note flag is set - the flag is set when the
track's held-note count 0x408e3a04[track] was 0. Every later note while that count is above
0 is stored as 64 + (note - NOTE) in the first of NO2, NO3, NO4 still at -1.

- Chord alone on the track: the root is first (chord_on plays it first), so the step gets
  NOTE = root and NO2..NO4 = the intervals: a stock chord trig.
- **Caveat**: if another note is already sounding on that track when the chord starts
  (legato overlap, another held key), the root arrives unflagged and the whole chord
  merges into the step's existing trig (a merge also needs an existing trig with NOTE
  set; otherwise an unflagged note takes the overwrite path). A 5th note on a step is
  dropped, and a tone equal to the step's NOTE takes the overwrite path (clears the chord).
  A tone the duplicate guard or the orphan guard does not play is not recorded either.
  With a note latched, keys record single notes (no chord, K7 a).
- Where to look: the trig's NOTE on the NOTE page; NO2..NO4 are ARP page parameters (manual
  ARP page: "NO2-NO4 selects the offset in semi-tones for three additional arpeggio notes
  ... The TRK KEY SCALE and TRK KEY NOTE settings ... will affect the note values"), so a
  non-chromatic track scale can change how the recorded chord plays back.
- Grid/step record (the 0x4009455c call in the same handler) was not traced (out of scope
  for v1, test row K21). Chord-trig playback with the arpeggiator off is supported by the
  OS 1.56 release notes ("chords can be programmed by using the ARP NO2, NO3, NO4
  parameters"), not traced in code.

## Gesture: why FUNCTION + OCTAVE UP (corp keys-gesture + skeptic, FIXABLE, fixes applied)

- KeyboardView::handleKey 0x400b9de2 (vtable `12KeyboardView` 0x40187db0, slot +8) sends
  every press of 164/165 with FUNCTION to the base View::handleKey 0x4005fa6e, in both the
  normal branch (0x400b9f84 -> 0x400ba266 -> 0x400ba274 -> 0x400ba13e) and the transpose
  branch (0x400b9f54 / 0x400b9ffe -> 0x400ba13e). The base handler acts only on codes 80,
  81, 82 and otherwise returns 0 (0x4005faa6-0x4005fafa).
- The only main-OS compares against 164/165 are 0x400b9e5c and 0x400b9e66, both in that
  handler; no switch table or range compare in the other 57 view key handlers covers them
  (keys-gesture-sk views2.py: 96 classes); the only global key listener (0x400baa98)
  handles codes 68/69. The bootstrap's `pea 0xa4/0xa5` (0x402278e6) is boot-only and in the
  never-write range.
- The OS 1.56 manual gives OCTAVE UP/DOWN no FUNCTION function.
- That 164 is the key labelled OCTAVE UP is inferred (Keys key table 0x401ebc78 idx 87 =
  164; 164 = +1 octave at 0x400ba2c8), not proven: test-card row K1. On an Analog Four MK1
  the octave key sends code 66 (0x400b9e0a), which never reaches this gate (it compares
  164 only): the capture gesture does not exist there (keys-gate-fableA F4).
- Reach: FUNCTION sits near the TRACK keys and the OCTAVE keys at the left-hand side
  (manual, ONE-HANDED OPERATION and KEYBOARD CONTROL), so whether one hand can press
  FUNCTION + OCTAVE UP while the other holds the chord is UNKNOWN: test row K17. Latched
  chords cannot stand in for held keys (K7 a).
- FUNCTION + OCTAVE DOWN (165) is equally free and kept in reserve.
- Skeptic G4 wording: the claim holds per key code; generic any-key reactions (NameView,
  SynthCalibrationMenuView, modal views) also see the press, none as a FUNCTION + OCTAVE
  function, and the modal ones swallow it first (the gate is then inert).

## Hooks (registry/allocations_keys.toml, owner 0010-chord)

| site | expect (stock) | entry | rejoin | re-emitted |
|---|---|---|---|---|
| 0x400b9818 KeyboardView note-on prologue | `4e56ffa8707f` linkw %fp,#-88; moveq #127,%d0 | `chord_on` 0x4023485c | 0x400b981e (moveml) | in `chord_stock` 0x40234a08 |
| 0x400b9e5c handleKey `cmpil #164,%d3` | `0c83000000a4` | `chord_key_gate` 0x40234a14 | 0x400b9e62 (`beqw 0x400b9ef2`) | at the gate's end |

Site checks (corp keys-builder `step2_site_refs.txt`): the only references into
0x400b9818..0x400b981f are the two `jsr %pc@` callers; the only reference into
0x400b9e5c..0x400b9e67 is `bgts 0x400b9e5c` at 0x400b9e44 (the instruction before the site
is a `braw`); no 32-bit word at any even or odd offset of the raw image points into either
range. tools/build.py re-checked both expects against the stock MAIN OS before patching.

Registers (corp keys-fixer `regcheck.v1.out`). At 0x400b9818 nothing is live in
d0/d1/a0/a1 (stock's prologue writes d0 and saves d2-d7/a2-a5 before reading anything, and
writes d1 before reading it on every path; both callers ignore d0/d1 on return, which is
also why the guard may return without calling stock): before its save `chord_on` writes
only a0, d0, d1 (and the C-ABI scratch of the getters it calls, each argument popped),
then either branches to `chord_stock` with the caller's stack untouched or saves
d2-d6/a2 (0x402348c4) and restores them before each of its three exits (0x40234994 guard,
0x4023499e stock note, 0x402349fe after the chord). At 0x400b9e5c d3 = key code, d2 = the
KeyEvent, a2 = the KeyboardView; d0/d1/a0/a1 are dead at the rejoin and at all three
continuations (0x400b9ef2 writes d0 first, d1 is set by `moveq` before it is read, a0/a1
are not read; keys-gesture-sk). `chord_capture` saves and restores d2-d7/a2-a5 and never
writes a2.

The functions chord_on calls (each a getter with no stores, also called by stock's note-on
itself): `sel_kind2_test` 0x400ab35e / `uist_kind2_test` 0x40021e2c, `kv_midi_ext` 0x400ab51c
(byte result, tested with `tst.b` as stock does), `kv_ext_chan` 0x400ab668, `kv_chan_obj`
0x400a2202, `kv_chan_fallback` 0x400a843c, `kv_active_track` 0x400aaba8, `uist_hold`
0x40021e46 (re/symbols_keys.toml, with dis lines).

## Space (TRUTH K1, K7 e; keys-platform P5/P7 + skeptic)

The Keys has no Rytm-style `cave` after its bootstrap (64 B before the USB strings) and no
proven cave3 (its top 512 B can be read by stock through a sign-extended index). 0010-chord
is one claim at the head of the **cave2 twin**, 0x4023485c..0x40235000 (1956 B: between the
end of the 122-entry static-constructor table and __bss_start): claim 0x4023485c + 0x500
(1280 B), used 1192 B (code, the seven popup strings, then the 136-byte state). 676 B of
the pool stay free.

Pool proof (TRUTH K7 e: the MK1 cave2 standard - no stock reference, no loop walk, no
store, below __bss_start, not cleared - re-derived in this round; corp keys-fixer
`cave2_proof.py` -> `cave2_proof.v2.out`, `usbdesc_extent.py` -> `usbdesc_extent.out`, all
read-only on the stock raw MAIN OS cc19347b... and the stock dis): the run
0x40234858..0x40235000 is 1960 zero bytes; 0 big-endian words at **any** byte offset point
into it; the only dis operand inside it is a pc-relative decode at 0x40230674 inside the
embedded bootstrap blob, which MAIN OS copies to flash and never executes (0 control-flow
instructions outside the blob target it); the constructor loop 0x400ffbfe is count-based
(122 from 0x4023466c, ending exactly at 0x40234858); the SRAM copies and the .bss clear
start at 0x40235000 (0x40000dc8, 0x40000e24) and run upward, the only operand equal to the
image end is that copy's bound, the bootstrap copy stops at 0x40233fc0; the USB
descriptors below are written only by fixed-address byte stores and every pointer into
them reads as a descriptor ending at or below 0x4023466a. The registry records the full
case (cave2 pool note) at status "probably-verified" - the MK1 cave2 status before its
first run; the first run of this image is the Keys hardware run that would promote it.

## Build

`make DEVICE=keys chord` (guest VM): tools/build.py --device keys --mods 0010-chord --tag 0010,
then tools/verify.py --device keys --tag 0010. Output `build/keys/AKEYS_OS1.56_0010.syx`.
Corp keys-fixer logs: `build_v1.log`, `rebuild_all.v1.log`.

verify (guest): null repack of the Keys stock .syx byte-identical; MAIN OS round-trips; the
embedded bootstrap 0x40226ee8..0x40233fc0 unchanged (53,464 B, recovery path) and the
embedded UI-board firmware 0x401b8a92..0x401b9fd6 unchanged (5,444 B); the .syx carries MAIN
OS only, like stock; 3 differing regions, all claimed (0x400b9819 +5, 0x400b9e5c +6,
0x4023485c +1192); both detours jump to their resolved entries; the displaced bytes are
re-emitted in the stub; both rejoins correct; PASS. Every Rytm output and the Keys control
are byte-identical to before (guest-hashed after the rebuild: `final_guest_hashes.v1.txt`).

### Proof on the built image (host, read-only: objdump / nm / python; corp keys-fixer)

- `hostcheck.v1.out`: the build's stock_mainos.bin is the RE lanes' raw section; 1068
  changed bytes, 0 outside the three claims (cave 1057, detours 5 + 6); 0 bytes differ in
  either never-write range (sha256 24c04cc5... and 6b57f974... as in re/symbols_keys.toml);
  site 0x400b9818 stock `4e56ffa8707f` -> `4ef94023485c` (jmp chord_on), site 0x400b9e5c
  stock `0c83000000a4` -> `4ef940234a14` (jmp chord_key_gate); the linked .text (1192 B) is
  byte-identical to the image at 0x4023485c; the rest of the claim and of the pool is zero.
  The state image is 8 zeros then 128 x 0xFF; the popup strings end in NUL (the longest,
  `CHORD: RELEASE HOLD FIRST`, 25 characters; the longest expanded `CHORD ON: 0 63 63 63`
  is 20 of the popup's 32).
- `pathcheck.v1.out` (the keys-integrator's pathcheck.py over `chord_elf.v1.dis`): every
  path of `chord_on`, `chord_key_gate`, `chord_capture` and `cap_counts` walked (302 of 305
  instructions reached; the other 3 are `chord_stock` itself, entered as stock's entry);
  every exit at stack delta 0 with every saved register restored: chord_on's 3 branches to
  the stock entry before its save, its `braw` to it after the restore, its 2 `rts` (guard,
  after the chord), the gate's `jmp 0x400b9e62`, both `rts`. The chord loop pushes 4
  arguments, calls `chord_stock`, pops 16; every getter call is push 4 / `addq.l #4`; the
  popup push is bounded by the 2..4 count and popped as 8 + 4*(n-1); the capture buffer
  indices stay 0..4 (count saturates at 5; the shift starts at min(count, 4)). PASS.
- `regcheck.v1.out`: registers written per part - above.
- `props.v2.out` (scripts/props.py, the control-flow graph of the built stub): (a) the
  HOLD / latched proof above; (a') chord mode off, nested and kind-2 calls branch to the
  stock entry before any register save, the only store on the way being the bounded
  `chord_root` byte; (b) the only `chord_mode` clear is reached only with an empty table;
  (c) the capture's root is `chord_root[key id]` (0x40234a6c..0x40234a7c); (d) the skip of
  tones above 127; and the list of every store in the stub: the state bytes, the bounded
  `chord_root` / `chord_iv` / capture-buffer indices, and the stack.
- `hold_model.all.v3.out` and `scenarios.v2.out`: the ordering model and the card's
  orderings (above).

## Test card (never run; Analog Keys on stock 1.56 first)

Before you flash: back up the projects (Transfer); keep the stock file
`stock/KEYS_Analog-Four_Analog-Keys_OS1.56.syx` (sha256
`cda4459d14bfba40635440ad9dfa8fc183e5317e5e3ffa7116704f307fdf7010`) and a DIN MIDI
interface at hand. Device byte 0x06: these files are for an Analog Keys (an Analog Four
**MK1** takes them too, but the chord gesture does not exist there) - never an Analog Four
MKII (0x0b). Check each file's sha256 before sending.

Files (guest VM builds, this commit):

- `build/keys/AKEYS_OS1.56_control.syx` - stock 1.56 code, only repacked by this tree's
  tool (`make DEVICE=keys control`: PASS, 0 differing regions), sha256
  `6981fd94084e8f678e6579a224b009a80e50f9192499f63db2cfcc519f75a475` (MAIN OS = stock,
  cc19347b...).
- `build/keys/AKEYS_OS1.56_0010.syx` - chord memory, sha256
  `02a4c784e99d275d3685e3fed02dff84bf5bde8cd6c9440eba5c55e9f7ffa4de` (MAIN OS
  `17fa1afa7ae0cb7e8ea73988ef7dd6e0757e7604311acd833a5f089401685fcd`).

These files are staged in the founder's flash folder `flash/KEYS/` with
`START_HERE_KEYS.md` and `SHA256SUMS` (TRUTH K8 d).

Route each time: USB, Transfer > CONNECTION (MIDI IN/OUT = the Analog Keys) > DROP the
.syx > `[YES]` on the device (manual, GLOBAL MENU > SYSTEM > OS UPGRADE). Do not power off
during the first boot afterwards (the OS re-flashes its embedded bootstrap when its version
word is newer than flash; it is byte-identical to stock in both files). Both files carry
version 1.56, the same as stock: if Transfer refuses a same-version file, nothing was
written - use the recovery route.

Every expectation below comes from the code and the model (`scenarios.v2.out`; the rows
corrected by corp keys-fix-integrator: `int_scen.out`), not from hardware: note what
actually happens. Run the rows in order: K11 (g) turns chord mode off, and K11h starts by
turning it on again. If a note keeps sounding at any point: release every key and tap HOLD
twice (Limits, HOLD).

| row | what | expect |
|---|---|---|
| K0 | **Control first**: flash `AKEYS_OS1.56_control.syx` | boots, plays, OS 1.56 as before. It proves this tree's ELE2 repack on the Keys (stock's aPLib stream needs 0 pad bytes, so whether the Keys accepts our 4-byte padding is UNKNOWN - keys-platform C1) |
| K1 | flash `AKEYS_OS1.56_0010.syx`; boots; nothing held, nothing latched, hold FUNCTION, press OCTAVE UP | popup `CHORD OFF`; the octave does NOT change (as stock). Confirms 164 = OCTAVE UP |
| K2 | kit POLY CONFIG: the track's voice in a 4-voice poly group. HOLD off and nothing latched, MIDI EXT off, MULTI MAP off, keyboard transpose (FUNCTION + HOLD) off. Hold C3 E3 G3, FUNCTION + OCTAVE UP | `CHORD ON: 0 4 7` |
| K3 | play single keys D, F, A... | each plays its major triad; release -> all three stop (no stuck notes) |
| K4 | rolls: fast repeated presses, rolled chords, two-handed runs, 20 s | no stuck notes, no crash, voice stealing as stock |
| K5 | held overlap (chord on): hold C (C E G), then press E (its root E already sounds) | E adds G# B only; release E -> G# B stop, E keeps sounding; release C -> all stop |
| K6 | chord off (optionally again with chord on): one key held + gesture; 5 keys held (C D E F G) + gesture; then release G (4 held) + gesture | `CHORD: HOLD 2-4 KEYS`, chord unchanged; again `CHORD: HOLD 2-4 KEYS` (5 or more is not a capture, K7 b); then `CHORD ON: 0 2 4 5` |
| K7 | chord on (0 4 7), hold C then G (their chords share G), gesture, release both; then the variant: first re-capture 0 4 7 (nothing held, gesture; hold C E G, gesture; release), then hold C, G#, B, then E, gesture | `CHORD ON: 0 7` (the two keys' roots; v1 showed `0 11`); then single keys play root + fifth. Variant: `CHORD OFF`, then `CHORD ON: 0 4 7`, then `CHORD ON: 0 8 11` - E is left out because all its tones were already sounding (Limits: release everything, gesture OFF, then capture, for an exact result). Without the re-capture the chord is still 0 7 and the variant shows `CHORD ON: 0 4 8 11` (`int_scen.out`) |
| K8 | top of the range: highest keys with a high octave | tones above note 127 silent, the rest play, no crash |
| K9 | live REC (chord on, REC + PLAY), a track with a chromatic scale, play separate chords on the beat | trigs with NOTE = root (the trig's NOTE page) and NO2..NO4 = the intervals (the ARP page); they play back; optional: the pattern on stock 1.56 plays the same chords. Note that TRK KEY SCALE / TRK KEY NOTE change how chord trigs play |
| K10 | live REC caveat: play legato (next chord before releasing the last) | the overlapping chord merges into the existing trig or takes the overwrite path (stock rules, above) - note what happens |
| K11 | **HOLD with a chord** (chord on, 0 4 7, one track): (a) hold C, press HOLD, release HOLD and C; (b) play D, release; (c) play E (a latched tone), release; (d) gesture with nothing held; (e) press and release C; (f) press HOLD alone (tap); (g) gesture with nothing held | (a) C E G stay latched; (b) a single D sounds (no chord while notes are latched, K7 a) and stops at release; (c) nothing changes - E keeps sounding latched with C, and keeps sounding after E's release (the orphan guard); (d) `CHORD: RELEASE HOLD FIRST`, chord unchanged; (e) C stops at its release (a latched note's key pressed again), E and G keep sounding; (f) every latched note released (the release-all needs a clean tap: nothing pressed between HOLD's press and release, FUNCTION up - read from the code, Limits HOLD; if they keep sounding, use the fallback: hold D (not one of the latched notes), press HOLD, release both, then press and release D - not E or G, which the orphan guard ignores); (g) `CHORD OFF` |
| K11h | precondition: chord on again (K11 (g) turned it off: nothing held, hold C E G, gesture -> `CHORD ON: 0 4 7`, release). HOLD held down: hold HOLD, play C, release C, play E, release E, release HOLD; gesture; then tap HOLD | single C and E (no chords while HOLD is down), both latched (the notes played while HOLD was down keep HOLD's release from releasing them); gesture `CHORD: RELEASE HOLD FIRST`, chord unchanged; the tap releases them (as K11 f) |
| K11i | **capture with HOLD on** (keys-gate-fableA F1; chord still on from K11h): hold HOLD, hold C E G, FUNCTION + OCTAVE UP; release C E G, FUNCTION and HOLD; then tap HOLD | single C, E, G (no chords while HOLD is down), latched; `CHORD: RELEASE HOLD FIRST` (latched notes are never captured, K7 a), chord unchanged; C E G keep sounding after everything is released; the tap releases them. Capture with HOLD off (K2) |
| K11j | **re-latch** (chord on, 0 4 7; keys-fix-panel-purpose F1): hold C, press HOLD, release both (C E G latched); hold F, press HOLD, release both; tap HOLD; hold F, press HOLD, release both; tap HOLD | a single F sounds and stays latched, the C chord is released (a key over a latched chord plays one note); the tap releases F; then F A C latched (the whole chord); the last tap releases them, nothing left sounding |
| K12 | precondition: chord on (capture 0 4 7 again as in K2). The MIDI EXT keyboard mode (MIDI EXT key on) with an external synth. Trig keys as a keyboard: **untested / out of scope v1** - the Keys manual names no trig-key keyboard mode (its keyboard-mode keys are MULTI MAP, MIDI EXT and HOLD) and the code path (handleKey codes 16..28) is by inference; only if you know a way to make the trig keys play notes | on MIDI EXT each key sends the chord's notes and their note-offs; trig keys: not traced, no expectation - note what happens |
| K13 | **chord OFF** (release everything, gesture: `CHORD OFF`): normal play, HOLD, OCTAVE keys, FUNCTION + HOLD (keyboard transpose), MULTI MAP, arpeggiator, trig keys, live REC | all exactly as stock (chord mode off: chord_on only records `chord_root` and branches to the stock entry) |
| K14 | power cycle | chord mode off, chord forgotten |
| K15 | **overlap under HOLD** (the orphan guard's test; chord on, 0 4 7): hold C, press HOLD, release both (C E G latched); press and release E; gesture with nothing down; press HOLD alone (tap); gesture again | E's press changes nothing and C E G keep sounding after E's release; `CHORD: RELEASE HOLD FIRST`; the HOLD tap releases all three, nothing left sounding (a clean tap, as K11 f); `CHORD OFF`. Without the guard E would stay held under C and survive the tap (`scenarios.v2.out`, k7-noguard); v1 played E's chord and let the gesture turn chord mode off |
| K16 | MIDI EXT on, hold 3 keys, gesture; then release, MIDI EXT off, nothing held, gesture | `CHORD: NO CAPTURE HERE`, chord unchanged; then `CHORD OFF` |
| K17 | reach: hold a 3-note chord with one hand, FUNCTION + OCTAVE UP with the other | note whether it is comfortable (hardware unknown; latched chords are not captured in v1) |
| K18 | **untested / out of scope v1**: chord on, MULTI MAP on (a new project's 2-split with the DRUMS section) | not traced, no expectation - note what happens on the drum keys and the lead keys |
| K19 | **untested / out of scope v1**: chord on, arpeggiator on (MODE TRU, then PLY), hold one key | not traced (the arp's input path is unidentified), no expectation - note what happens |
| K20 | **untested / out of scope v1**: chord on, keyboard transpose (FUNCTION + HOLD) and the TRANSPOSE key | not traced; by the code the transpose branch never reaches the note-on, so single notes are likely - note what happens |
| K21 | **untested / out of scope v1**: chord on, GRID / STEP record: hold a trig, press one key | not traced, no expectation - note what happens (NOTE + NO2..NO4 on that trig would match live REC) |

### If it does not boot, or to go back to stock

- **Recovery route** (manual, EARLY STARTUP MENU > OS UPGRADE): connect the Analog Keys
  **MIDI IN** (DIN) to the MIDI OUT of the computer's MIDI interface; hold `[FUNCTION]`
  while powering on (STARTUP menu); `[TRIG 4]` = OS UPGRADE; in Transfer, on the
  CONNECTION page click "go to the SYSEX TRANSFER page"; on the SYSEX TRANSFER page click
  "OS Upgrade via device startup menu" and follow the on-screen instructions, sending the
  stock `KEYS_Analog-Four_Analog-Keys_OS1.56.syx` (sha256 above); the Keys reboots when
  done. USB MIDI cannot be used from the STARTUP menu (manual). Both files leave the
  embedded bootstrap (and the UI-board firmware) byte-identical to stock. That this menu is
  served by the bootstrap in flash rather than by MAIN OS is the Rytm MK1's case
  (docs/FLASHING.md); for the Keys it is inferred, not proven.
- **Back to stock from a booting build**: the normal route with the stock .syx - a
  same-version reinstall, untested here (the Rytm's H5 is the same unknown). If refused, the
  recovery route.
- Nothing the mod keeps is saved. What live REC wrote with chord mode on is ordinary stock
  chord-trig data and stays.

## Decided by TRUTH K7 (CEO 2026-10-08)

- (a) HOLD: no chord while HOLD is down or any note is latched; latched notes are not
  captured. (Was open decision 1.)
- (b) Capture = 2..4 held state-1 internal entries of the active track (by root); OFF only
  with an empty table; otherwise the gesture changes nothing and the popup says why.
- (c) Capture from the per-key-id root table.
- (d) Tones above 127 are skipped. (Was open decision 3.)
- (e) cave2 used with the MK1-standard static proof re-derived in this round (Space).
  (Was open decision 2.)
- (f) The test card above (K9 page, K11/K12/K15 expectations, K11h/i, K18-K21 out of
  scope).

## Decided by TRUTH K8 (CEO 2026-10-08, after the fix gate)

- (a) **The orphan guard is ratified**: on the HOLD paths the build sends one stock note,
  except a note stock would merge into ANOTHER key's latched note (which would hang it).
  K11 (c) and K15 expect it.
- (b) **Five or more keys** capture nothing (`CHORD: HOLD 2-4 KEYS`), as K7 (b) reads.
- (c) A note stock itself left stuck (its octave path) counts as a held key: it joins a
  capture and keeps `CHORD OFF` from working. Release every key and tap HOLD twice first.
- Chords on the trig-key path and MIDI EXT stay on (one hook covers both callers).

## Open decisions (founder)

1. FUNCTION + OCTAVE DOWN (165) is free: e.g. chord mode on/off that keeps the chord.

## Hardware-only unknowns

The ELE2 padding rule (K0); the physical label of code 164 (K1); one-hand reach of FUNCTION
+ OCTAVE UP with a chord held (K17); the popup's on-screen appearance and the UIStates +69
suppress byte; poly allocation and the mono-voice outcome (N20); whether MIDI-in notes take
this path; live-REC merges under overlap; chord-trig playback with the arp off; the kind-2
path's identity; MULTI MAP, arp, transpose and grid/step record with chord mode on
(K18-K21, out of scope v1); the trig keys as a keyboard (K12, out of scope v1); HOLD's
release-all on a clean tap (KeyEvent bit 4, read from the key scanner: K11 f, K11h-K11j,
K15) and the two-tap stuck-note recovery; the
cave2 twin at run time (first Keys image to use it); the UI task's stack margin (chord_on
adds 44 B over stock's note-on frame per call; the capture 60 B plus the popup's frame).

## Next steps (TRUTH K6, not v1)

A CHORD page with a preset knob; dyad mode (OSC2 retune; keys-osc plan + skeptic fixes);
arp integration (needs another RE pass); saving the chord with the kit; capturing a
HOLD-latched chord.
