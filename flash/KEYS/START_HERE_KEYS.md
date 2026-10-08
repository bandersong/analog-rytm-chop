# CHORD memory and JOY RANDOM for your Analog Keys (OS 1.56) — start here

**None of these files has run on an Analog Keys yet.** Every check that can be done on a computer passed (built and verified in the VM, same bytes each time; the embedded bootstrap and the UI-board firmware inside the OS are byte-for-byte stock in every file).

**These files are for the Analog Keys only.** Never send them to a Rytm or to an Analog Four **MKII**. (An Analog Four MK1 takes them, but the chord and joystick gestures do not exist there.)

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
| 3 | `3_JOY_…` | chord memory + joystick roll (JOY RANDOM) | J1-J13 below (scratch project) |

Fallbacks: 3 → 2 → 1 or stock (file 0) → recovery.

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
Every expectation comes from the code and a model, not from hardware. Full card with the code references: `mods/0010-chord/src/design.md`, "Test card".

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

## JOY RANDOM: new joystick assignments at the press of a key (file 3)
File 3 is file 2 (chord memory, unchanged) plus the joystick roll. Flash it only after file 2 behaved. **It has never run on an Analog Keys.**

- **Roll:** hold **FUNCTION** and press **OCTAVE DOWN**. The screen shows `JOY: RANDOM` and the octave does not change. The active track's joystick gets new assignments: sideways (PITCH BEND) slots 2-5, up (MOD WHEEL) slots 1-5 and down (BREATH) slots 1-5 each get a random parameter and a random amount (24 to 63, plus or minus). PITCH BEND slot 1 stays, so sideways still bends the pitch. AFTERTOUCH and the VELOCITY settings are never touched.
- **FX track:** only FX parameters (chorus, delay, reverb, external-input sends and pans, the FX LFOs). Never the external-input volumes, chorus or delay feedback, or delay overdrive. **CV track:** only `JOY: NOT ON CV`; nothing changes.
- **Roll again:** same gesture. A slot can land on the parameter it already had. If one direction does nothing audible, roll again: some parameters only matter when an LFO, ENV2, the noise, a pulse wave or sync is in use.
- **Undo:** `[NO/RELOAD]` + `[SOUND]` brings back the track's saved sound. It also undoes every other unsaved edit of that sound. A roll is an ordinary sound edit: it stays in the working kit like any other edit, and `[YES/SAVE]` + `[KIT]` makes it part of the saved kit.
- **With a menu open:** the roll also happens with the PITCH BEND, MOD WHEEL or BREATH menu open. The stored values are right; the open menu may only show them after you leave and re-open it.
- **After power-on** the first rolls can repeat the ones after the last power-on (the random numbers restart).
- Something wrong: go back to file 2 (chord only) or file 1.

### Test card for file 3 (run in order; note what actually happens)
**Keep the volume low for J3 and J11:** a roll can push filter resonance, overdrive or FX sends up when you move the joystick.
**Use a scratch project for the whole card:** the rolls change real kit data and J8 saves one. Save your own project first, then GLOBAL (`[FUNCTION]` + `[SONG]`) > PROJECT > LOAD PROJECT > CREATE NEW (bottom of the list, a blank project). When done, load your own project again. Every expectation comes from the code and a model, not from hardware. Full card with the code references: `mods/0011-joyrand/src/design.md`, "Test card".

| row | do | expect |
|---|---|---|
| J0 | file 1 first (skip if K0 already passed) | boots, plays as before |
| J1 | flash file 3; scratch project. OCTAVE DOWN alone, then OCTAVE UP; hold FUNCTION + OCTAVE DOWN; then, nothing held, FUNCTION + OCTAVE UP | `Octave` popups, one down and back; `JOY: RANDOM` and the octave stays; `CHORD OFF` |
| J1b | POLY CONFIG and keyboard as K2. Hold C E G, FUNCTION + OCTAVE UP, release; FUNCTION + OCTAVE DOWN; play D; then, nothing held, FUNCTION + OCTAVE UP | `CHORD ON: 0 4 7`; `JOY: RANDOM`; D plays D F# A (the chord survives the roll); `CHORD OFF` |
| J2 | synth track: `[NO/RELOAD]` + `[SOUND]` first (`TRK n SOUND RELOADED`, undoes J1's roll). Write down SOUND > SOUND SETTINGS > PITCH BEND, MODULATION WHEEL, BREATH CONTROLLER, AFTERTOUCH, VELOCITY MOD, VELOCITY TO VOL. FUNCTION + OCTAVE DOWN. Read them again | PITCH BEND slot 1 the same; PITCH BEND 2-5, MOD WHEEL 1-5, BREATH 1-5 re-drawn (one may keep its old parameter by chance); amounts -63..-24 or 24..63; no parameter twice in one menu; AFTERTOUCH, VELOCITY MOD, VELOCITY TO VOL the same |
| J3 | hold a note; joystick up, down, sideways; let go | audible changes (if one direction does nothing, roll again and retry); sideways still bends; at rest it sounds as before the roll |
| J4 | roll 5 times on the same track | a different set most times |
| J5 | `[NO/RELOAD]` + `[SOUND]` | `TRK n SOUND RELOADED`; the values you wrote down in J2 are back |
| J6 | FX track: roll; read its PITCH BEND / MOD WHEEL / BREATH menus; then `[NO/RELOAD]` + `[SOUND]` | FX parameters only, never EXT L/R VOL, chorus or delay feedback, delay overdrive; the reload brings its saved values back |
| J7 | CV track: roll | `JOY: NOT ON CV`; its menus unchanged |
| J8 | **scratch project only:** roll; save the kit to its own slot (`[YES/SAVE]` + `[KIT]`); power cycle | the roll is still there |
| J9 | scratch project: power cycle twice; each time, the first roll on the same track of the same saved kit (after a reload) | note whether the two rolls are identical |
| J10 | Overbridge (if you use it): roll 10 times | note any error, desync or what the plug-in shows |
| J11 | pattern playing, joystick moving, roll 20 times fast | no crash, no stuck note, no dropout |
| J12 | open SOUND SETTINGS > MODULATION WHEEL; roll; turn one amount one step; leave and re-open the menu. Then roll with another (non-joystick) menu open | it rolls under the joystick menu; note whether the menu shows the new values at once or only after re-opening; the one-step edit starts from the rolled amount. Other menu: note whether it rolls |
| J13 | keyboard transpose (FUNCTION + HOLD) or TRANSPOSE on: roll | `JOY: RANDOM`; the transpose is unchanged |

To tell the roll from the chord part: `AKEYS_OS1.56_0011.syx` (roll only, sha256 `7797f97486ac25ee5a7896fe108b02511333f63ea99ef66a93d3b3b4c747d469`) is in the build folder `upstream/rytm1_mods/build/keys/`, not staged here.

## If it won't boot
Connect the Keys' **MIDI IN** (DIN) to your MIDI interface. Hold **FUNCTION** while powering on → **TRIG 4** (OS UPGRADE). In Transfer, on CONNECTION click "go to the SYSEX TRANSFER page", then "OS Upgrade via device startup menu", and send `0_STOCK-1.56_and_RECOVERY_…syx`. USB MIDI does not work from the startup menu. (That the startup menu is served by the bootstrap, which these files leave stock, is proven on the Rytm MK1 and inferred for the Keys.)

## More
Proofs, limits and decisions: [`mods/0010-chord/src/design.md`](../../mods/0010-chord/src/design.md) and [`mods/0011-joyrand/src/design.md`](../../mods/0011-joyrand/src/design.md) (sources of the mods; both also inside `mods/0001-chop/rytm1_mods-chop.patch`). Checksums: `SHA256SUMS` in this folder.
