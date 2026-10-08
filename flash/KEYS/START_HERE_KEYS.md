# CHORD memory for your Analog Keys (OS 1.56) — start here

**None of these files has run on an Analog Keys yet.** Every check that can be done on a computer passed (built and verified in the VM, same bytes each time; the embedded bootstrap and the UI-board firmware inside the OS are byte-for-byte stock in both files).

**These files are for the Analog Keys only.** Never send them to a Rytm or to an Analog Four **MKII**. (An Analog Four MK1 takes them, but the chord gesture does not exist there.)

## Before you flash
1. In Transfer, back up the Keys' projects.
2. Have a **DIN** MIDI interface ready (the recovery route is DIN only, not USB).
3. The Keys must run **stock 1.56** (`0_STOCK-1.56_and_RECOVERY_…syx`, Elektron's own file).
4. Normal route: Transfer > CONNECTION (MIDI IN/OUT = the Analog Keys), Transfer > DROP, drag the file, press YES on the Keys. Don't power off during the update or the first boot after it.
5. If Transfer refuses a file as "same version", nothing was written: stop, or send it by the recovery route below.
6. Check each file's sha256 against `SHA256SUMS` before sending.

## Order (each only after the one before behaved)
| # | File | What | Test |
|---|---|---|---|
| 0 | `0_STOCK-1.56_and_RECOVERY_…` | Elektron's stock 1.56 | it boots and plays |
| 1 | `1_CONTROL_stock-code_…` | stock Keys code, only repacked by our tool | K0: accepted, boots, plays as before |
| 2 | `2_CHORD_…` | chord memory | K1-K21 below |

Fallbacks: 2 → 1 or stock (file 0) → recovery.

## How it works (file 2)
- **Capture:** hold 2 to 4 keys, then hold **FUNCTION** and press **OCTAVE UP**. The screen shows `CHORD ON: 0 4 7` (the intervals). Every key now plays that chord with itself as the root; releasing the key releases the chord.
- **Change the chord:** hold the new keys and capture again. For an exact result: release everything, FUNCTION + OCTAVE UP with nothing held (`CHORD OFF`), then hold the new keys and capture. (With chord mode still on, a key whose notes already all sound from the other held keys is left out.)
- **Chord off:** FUNCTION + OCTAVE UP with nothing held and nothing latched → `CHORD OFF`. Power off also turns it off and forgets the chord (nothing is saved).
- **Other popups:** `CHORD: HOLD 2-4 KEYS` (1 key, or 5 or more), `CHORD: NO CAPTURE HERE` (keys held on MIDI EXT or another path), `CHORD: RELEASE HOLD FIRST` (only latched notes). Each changes nothing.
- **Voices:** set the kit's POLY CONFIG so the track has a poly group with enough voices (up to 4).

## HOLD with chord mode on
- **Latch a chord:** with nothing latched, hold its key and press HOLD — the whole chord stays.
- While HOLD is down or any note is latched, keys play **single notes** (no chords), and latched notes are never captured.
- A key held over a latched chord plays one note; pressing HOLD then latches that one note and releases the chord. **To latch a different chord:** first release the latched one, then hold the new key and press HOLD.
- **Release all:** with no key down, **tap HOLD on its own** (press and release, no other key in between, FUNCTION up).
- **Stuck note:** release every key and **tap HOLD twice**. Do this before capturing: a stuck note counts as a held key, so it would join the next capture and stop `CHORD OFF` from working.
- If a tap does not release: hold a key that is **not** one of the latched notes (e.g. D over a latched C chord), press HOLD, release both, then press and release D. A key on a latched note (E or G of a C chord) does nothing here.

## Test card (run in order; note what actually happens)
Every expectation comes from the code and a model, not from hardware. Full card with the code references: `mods/0010-chord/design.md`, "Test card".

| row | do | expect |
|---|---|---|
| K0 | flash file 1 | boots, plays, OS 1.56 as before |
| K1 | flash file 2; nothing held or latched; FUNCTION + OCTAVE UP | `CHORD OFF`; the octave does NOT change |
| K2 | POLY CONFIG: 4-voice poly group. HOLD off and nothing latched, MIDI EXT off, MULTI MAP off, keyboard transpose (FUNCTION + HOLD) off. Hold C3 E3 G3, FUNCTION + OCTAVE UP | `CHORD ON: 0 4 7` |
| K3 | single keys D, F, A… | each plays its major triad; release → all three stop |
| K4 | fast repeats, rolled chords, two-handed runs, 20 s | no stuck notes, no crash |
| K5 | hold C, then press E | E adds G# B only; release E → G# B stop, E keeps sounding; release C → all stop |
| K6 | chord off: 1 key + gesture; 5 keys (C D E F G) + gesture; release G + gesture | `HOLD 2-4 KEYS`; `HOLD 2-4 KEYS`; `CHORD ON: 0 2 4 5` |
| K7 | chord on (0 4 7): hold C then G, gesture, release. Then re-capture 0 4 7 (nothing held: gesture; hold C E G, gesture; release); hold C, G#, B, then E, gesture | `CHORD ON: 0 7`; then `CHORD OFF`, `CHORD ON: 0 4 7`, `CHORD ON: 0 8 11` (E left out: all its notes already sounded) |
| K8 | highest keys, high octave | notes above 127 silent, no crash |
| K9 | live REC, chromatic track scale, separate chords on the beat | trigs with NOTE = root and NO2..NO4 = intervals (ARP page); they play back |
| K10 | live REC, legato chords | merges or overwrites as stock's recorder does — note what happens |
| K11 | chord on (0 4 7): (a) hold C, press HOLD, release both; (b) play D; (c) play E; (d) gesture; (e) press and release C; (f) tap HOLD; (g) gesture | (a) C E G latched; (b) single D, stops at release; (c) nothing changes; (d) `RELEASE HOLD FIRST`; (e) C stops, E G keep sounding; (f) all released (fallback above if not); (g) `CHORD OFF` |
| K11h | re-capture 0 4 7 first (hold C E G, gesture, release). Hold HOLD, play C, release, play E, release, release HOLD; gesture; tap HOLD | single C and E, both latched; `RELEASE HOLD FIRST`; the tap releases them |
| K11i | hold HOLD, hold C E G, FUNCTION + OCTAVE UP; release everything; tap HOLD | single latched C, E, G; `RELEASE HOLD FIRST`; they keep sounding after release; the tap releases them |
| K11j | hold C, press HOLD, release both; hold F, press HOLD, release both; tap HOLD; hold F, press HOLD, release both; tap HOLD | single F latched and the C chord released; tap releases F; then F A C latched; tap releases them |
| K12 | MIDI EXT on, external synth, play keys (chord on) | each key sends the chord's notes and their note-offs. (Trig keys as a keyboard: out of scope, the Keys has no such mode in the manual) |
| K13 | chord OFF: normal play, HOLD, OCTAVE, FUNCTION + HOLD, MULTI MAP, arp, live REC | all exactly as stock |
| K14 | power cycle | chord off, chord forgotten |
| K15 | chord on: hold C, press HOLD, release both; press and release E; gesture; tap HOLD; gesture | E changes nothing; `RELEASE HOLD FIRST`; tap releases all; `CHORD OFF` |
| K16 | MIDI EXT on, hold 3 keys, gesture; release, MIDI EXT off, gesture | `NO CAPTURE HERE`; `CHORD OFF` |
| K17 | hold a chord with one hand, FUNCTION + OCTAVE UP with the other | is it comfortable? |
| K18-K21 | chord on with MULTI MAP, arpeggiator, transpose, GRID/STEP record | untested / out of scope: no expectation, note what happens |

## If it won't boot
Connect the Keys' **MIDI IN** (DIN) to your MIDI interface. Hold **FUNCTION** while powering on → **TRIG 4** (OS UPGRADE). In Transfer, on CONNECTION click "go to the SYSEX TRANSFER page", then "OS Upgrade via device startup menu", and send `0_STOCK-1.56_and_RECOVERY_…syx`. USB MIDI does not work from the startup menu. (That the startup menu is served by the bootstrap, which these files leave stock, is proven on the Rytm MK1 and inferred for the Keys.)

## More
Proofs, limits and decisions: [`mods/0010-chord/src/design.md`](../../mods/0010-chord/src/design.md) (source of the mod; also inside `mods/0001-chop/rytm1_mods-chop.patch`). Checksums: `SHA256SUMS` in this folder.
