# 0011 JOY RANDOM - random joystick assignments for the Analog Keys (OS 1.56)

> Internal shorthand: "corp", "TRUTH Kn", "CEO" and the `joy-*`/`keys-*` names refer to this project's own review rounds and decision log, kept for traceability.

Status: **built and verified in the guest VM, never run on hardware** (corp joyrand, TRUTH
K9; research corp `joyrand-re`, build corp `joy-builder`, panel fixes corp `joy-integrator`:
documentation and test card only, the images are unchanged). Analog Keys only: never send an
`AKEYS` file to an Analog Rytm or an Analog Four MKII.

| file | what | sha256 |
|---|---|---|
| `build/keys/AKEYS_OS1.56_0010_0011.syx` | `make DEVICE=keys joy`: 0010 chord memory + 0011 | `ebc9a6ceef5b84847714e8271442e01b9c980fd40437f873ff0cc66f4c246616` (MAIN OS `03709d216913f2de112e91445f50ab7b4852133daa700b367f377591d4553c0d`) |
| `build/keys/AKEYS_OS1.56_0011.syx` | `make DEVICE=keys joy-min`: 0011 alone (bisection) | `7797f97486ac25ee5a7896fe108b02511333f63ea99ef66a93d3b3b4c747d469` (MAIN OS `115fb080e00cbb50639e31784c263d09e4f9bf0b9fa4bf160b67c37689f5d110`) |
| `build/keys/AKEYS_OS1.56_control.syx` | `make DEVICE=keys control`, unchanged | `6981fd94084e8f678e6579a224b009a80e50f9192499f63db2cfcc519f75a475` |
| `build/keys/AKEYS_OS1.56_0010.syx` | `make DEVICE=keys chord`, unchanged | `02a4c784e99d275d3685e3fed02dff84bf5bde8cd6c9440eba5c55e9f7ffa4de` |

The new files are not staged in the founder's `flash/KEYS/` folder (this round leaves the
parent repo untouched).

## Summary (README text)

Hold FUNCTION and press OCTAVE DOWN. The active track's joystick assignments are rolled:
PITCH BEND (sideways) slots 2-5, MOD WHEEL (up) slots 1-5 and BREATH (down) slots 1-5 each
get a random destination and a random depth of 24..63 with a random sign. PITCH BEND slot 1
(stock: PMX, the bend itself) is kept, so sideways still bends. No destination appears
twice in one controller. The popup says `JOY: RANDOM`. AFTERTOUCH and VELOCITY are never
touched. On the CV track the gesture only shows `JOY: NOT ON CV`. Nothing is saved by the
mod: `[NO/RELOAD]` + `[SOUND]` (stock quick reload of the active track's Sound) brings the
saved assignments back; `[YES/SAVE]` + `[KIT]` keeps the roll.

## What it does

- **Gesture**: KeyboardView::handleKey (0x400b9de2) with key code 165 (OCTAVE DOWN), the
  KeyEvent flags (+16) showing pressed, FUNCTION held and not a repeat (`flags & 0xB ==
  0x3`, the same test as 0010's gate; bits 0x400599b6 / 0x400599f2 / 0x400599c2). A
  release, a repeat or OCTAVE DOWN without FUNCTION is pure stock.
- **Track, kit, controller objects**: exactly as the SOUND SETTINGS menus get them
  (invokers 0x400e00a2..0x400e01ca): `proj = 0x4012e890()`, `T = 0x400aab78(proj + 48)`,
  `kit = proj + 244` (0x400a222e), then the controller's getter `(kit, T)`: PITCH BEND
  0x4009a22a, MOD WHEEL 0x4009a1c4, BREATH 0x4009a290. T 0..3 are the synth tracks
  (kit + 0x60 + 988 T), 4 the FX track (kit + 4144), 5 the CV track (kit + 5156); the
  getters send any other T to sound 0, so T is checked first (T above 5, unsigned: popup
  `JOY: NO CHANGE`, nothing touched).
- **Each controller object** must carry the 12SoundModConf vtable 0x4016fba0 (stored by
  its ctor 0x4001f40e at 0x4001f480; all three are built by it in the sound, FX and CV
  objects, 0x400b0044 / 0x400985bc / 0x40097a1a) and be bound (`count` 0x4001ef3c == 5);
  otherwise that controller is skipped. That check makes the direct calls below exactly the
  object's own vtable slots 0x48 / 0x54 / 0x58 / 0x5c.
- **Writes**: per rolled slot, `setParam(obj, slot, id)` 0x4001f17e, then `setDepth(obj,
  slot, depth)` 0x4001f032 - the two calls the menus make (destination edit 0x400363c8 ->
  thunk 0x4001f202; depth edit 0x40036734 -> thunk 0x4001f0d0; the thunks only subtract
  44 from `this`). Both check the slot against `count`, setDepth clamps to -0x8000..0x7f00,
  and each sends the menu's own DataChangeInfo through vt+0x10. Byte +2 of a slot is never
  written (neither setter writes it).
- **Destination**: `k = rand() % n` into the track type's pool (below); if that
  destination's container index (0x4000735a(id), the byte setParam stores) is already used
  in this controller, the next pool entry (wrapping). "Used" = the slots rolled so far plus,
  for PITCH BEND, the kept slot 1 (getParam 0x4001efde: its stored index, -1 when unbound).
  At most 4 are taken and every pool has at least 38 ids, so the walk ends within 5 steps.
- **Depth**: one `rand()` per slot: `|d| = 24 + r % 40` (24..63 whole units), negative when
  `r & 0x4000`, stored `d << 8` - whole units in the high byte, low byte 0, as the menu
  stores them (`((old >> 8) + delta) << 8`, 0x40036720..0x40036724). The menu draws the
  depth as depth / 256 (0x40035f48..0x40035f52) and a bar at depth / 512 + 64
  (0x40035fa6..0x40035fb8). Manual: the controller menus work "in the same way as setting
  up performance macros", whose depth "is an offset of the original track parameter value"
  (Keys manual, SOUND SETTINGS and PERFORMANCE MACROS).
- **Popup** (`ui_popup` 0x40021774 on KeyboardView+108, the UIStates stock's own `Octave:
  %d` popup uses): `JOY: RANDOM` when at least one slot was written, `JOY: NOT ON CV` on the
  CV track, `JOY: NO CHANGE` otherwise. Stock suppresses popups while UIStates+69 is set.
- **After the roll** stock runs as without the mod: the re-emitted `cmpil #165,%d3` feeds
  `beqw 0x400b9f9c`, and with FUNCTION held both octave branches go to the base view
  handler 0x4005fa6e (transpose 0x400ba008, normal 0x400ba338), which acts only on codes
  80/82/81 and returns 0. So the octave never changes on the gesture.
- **No run-time state**: the claim holds code and constants only (pools, controller table,
  three strings). The used-index buffer is on the stack.

## The pools (corp joyrand-re pools.out; re-derived by the builder)

The menu's own list (picker 0x40035354 and encoder path 0x40036350 both call
`0x4009e13e(out, set, 0x200)` on `set = 0x4009955e(kit, T)`: type 1 for tracks 0..3
(kit+4048+24T, ctor 0x4009e558), type 7 for the FX track (kit+5132, ctor 0x4009e58e)) is
every id 1..294 whose ROM record (0x401699c8, 56 B) has that type and modflags & 0x200:
81 synth ids (37..139), 49 FX ids (140..196). The pools remove:

| synth (28 removed, 53 kept) | why |
|---|---|
| 37 None | an empty slot, not a destination |
| 38 PM1, 39 FM1, 51 PM2, 52 FM2, 65 FMX | pitch family (wild detune at these depths) |
| 64 PMX | the bend itself: stock PITCH BEND slot 1, kept there, never rolled |
| 43/56 TRK, 45/58 WAV, 46/59 SUB, 50 AM1, 63 AM2, 66 SMD | stepped switches (clicks, not sweeps) |
| 93/104/114 SHP, 121/131 MUL | stepped |
| 68 BND | changes the bend range itself |
| 69 SLI, 71 FAD (vibrato), 123/133 SPH, 99 ACC | act only on slides, note start, retrig or accents |
| 98 VOL | track volume (negative depth mutes, positive can clip) |

| FX (11 removed, 38 kept) | why |
|---|---|
| 140 None | an empty slot |
| 145/150 Ext L/R VOL | external input level |
| 155 chorus FDB, 164 delay FDB, 167 delay OVR | runaway / self-oscillation / loud |
| 162 pingpong, 178/188 MUL | switches, stepped |
| 180/190 SPH | only at retrig |

Synth pool (53): 42 44 47 48 49 55 57 60 61 62 67 72 73 74 75 76 77 78 79 81 82 83 84 86 88
89 90 91 92 94 95 96 97 100 101 102 103 107 109 110 111 112 113 117 119 120 122 127 129 130
132 137 139. FX pool (38): 141 142 143 144 146 147 148 149 151 152 153 154 156 157 158 159 160
161 163 165 166 168 169 170 171 172 173 174 175 176 177 179 184 186 187 189 194 196.

Proof (corp joy-builder `pools_rederive.py` -> `pools_rederive.out`, from the stock raw
MAIN OS; `image_proofs.out` repeats it on the bytes in the BUILT image): every id is in
its type's menu list; its container index is at most 111; the stock index->id table (built
at startup by 0x40007204: per (type, index) the first id wins; read by `set->vt[0x64]` =
0x4009bb82 -> 0x400074fa) maps that index back to the same id. The menu's destination edit
calls `setParam(slot, set->vt[0x64](0x4000735a(list_id)))` (0x400363ac..0x400363cc), so for
these ids `setParam(slot, id)` stores exactly what the menu stores. Both re-derived pools
equal pools.out id for id. CV: no pool in v1 (popup only).

## Decision: the menu's two setters, 28 notifications (not setSlot)

PITCH BEND 2-5 + MOD WHEEL 1-5 + BREATH 1-5 = 14 slots, two setter calls each: **28**
DataChangeInfo notifications per gesture (the research's "30" counted PITCH BEND slot 1).
The alternative, `setSlot` (vt+0x50 = 0x4001ef70), would send 14 but:

- it is not what the menu calls;
- it has **no slot bound check** (only "data bound"; it stores `data[slot*4]` for any slot);
- it writes all 4 bytes, so it would also write byte +2, which setParam/setDepth never write;
- the stub would have to compute the stored index itself.

Each notification runs the chain of one menu edit (0x4012f5fe -> listener loop 0x4012f586
-> the track listener 0x400a3ff8, id -1): +8 -> 0x400faeaa (copies the slots into the 4
SRAM sound slots, a bounded loop of 4); +9 -> 0x400f19e8 -> 0x4007410a, a 6-byte message
written through a buffered writer that flushes in chunks (0x40074324 when 28 B or less are
free), bracketed by 0x40001c28 / 0x40001d4a on the same object (a lock, by its use), and
that drops a message only when it is re-entered (its flag +1068) - no unchecked ring or
queue write; then 0x40020d1a and 0x40079610 (voice
updates). No concrete hazard was found, so the menu-identical path stays. What a burst of
28 does under load is a hardware question: row J11. If J11 shows trouble, setSlot (with
its own bound check in the stub and byte +2 read back first) is the fallback.

Between a slot's setParam and its setDepth the engine briefly has the new destination with
the old depth (one notification apart, same UI-loop pass); with the joystick at rest no
controller offset applies.

## Random numbers and the seed (decision: stock rand, no seed)

`stock_rand` 0x400923e4: `state = state * 1103515245 + 12345` (long 0x20000100), returns
`(state >> 16) & 0x7fff`. Stock calls it from this same UI task for RND PAGE (0x4009e2ba),
and at 0x4005d5b0, 0x400efe64, 0x400f4020 and through 0x40092412 (0x40037748,
0x4005d608..0x4005d740). The stub never writes its state.
`srand` 0x4009242e has no caller; the reset code 0x40000f7a-0x40000fa8 zeroes
0x20000100..0x20200000 when bit 0 of 0x401d8ea4 is set. So the first rolls after a power
cycle can repeat (row J9); they differ once stock itself has drawn numbers.

The research's seed idea (XOR the engine tick 0x80006074 into the draw) was **not built**:
that word is not free-running. It lives in the interrupt handler ending at 0x40076b9c
(`rte`), is cleared at 0x40076a70 (when 0x4043ee48 == 0) and incremented at 0x40076b72 only
when 0x4043ee44 == 0 and 0x80006008 == 1; its other readers there (0x40076a94..0x40076b36)
only test it (`tstl`, `andl #-3`). Reading it would be harmless, but as a seed it would often be a
constant, so it buys nothing provable. Leaving stock rand is the documented choice.

## Gesture site and hook (registry/allocations_keys.toml, owner 0011-joyrand)

`0x400b9e66: 0c83 0000 00a5 cmpil #165,%d3` (dis:241569), rejoin `0x400b9e6c: 6700 012e
beqw 0x400b9f9c`. Reached only by falling through `beqw 0x400b9ef2` at 0x400b9e62 (codes
above 162 that are not 164: entry -> 0x400b9e08 `blts` -> 0x400b9e3c -> `bgts 0x400b9e5c`
-> 0x400b9e5c/0x400b9e62 -> here; d2 = the KeyEvent is not written on that path). With
0010-chord in the image, its `chord_key_gate` jumps to 0x400b9e62, so the flow is the same.
Nothing else reaches 0x400b9e66..0x400b9e6b: 0 dis operands/branch targets and 0
big-endian 32-bit words at any byte offset of the raw MAIN OS point into it (corp
joy-builder `site_refs.py` -> `site_refs.out`); handleKey dispatches by compare chains (no
jump table). It does not overlap 0010's 0x400b9e5c..0x400b9e61. The only main-OS compare
against 165 is this one.

Registers: at the site d3 = code, d2 = KeyEvent, a2 = KeyboardView; d0/d1/a0/a1 are dead
(0x400b9f9c writes d0 first and calls before reading d1/a0/a1; 0x400ba13e pushes d2/a2 and
calls). `joy_key_gate` uses only d0/d1/a0, `bsr`s `joy_roll` (which saves and restores
d2-d7/a2-a5 and never touches a6), re-emits the compare and `jmp 0x400b9e6c`.

```
[[detour]] owner 0011-joyrand  addr 0x400b9e66  size 6  expect 0c83000000a5  entry joy_key_gate
[[cave]]   owner 0011-joyrand  addr 0x40234d5c  size 0x2a4
```

## Space

The cave2 tail right after 0010's claim: 0x40234d5c..0x40235000 (676 B), ending exactly at
the pool end (= __bss_start). All zero in stock, in the built AKEYS 0010 image and in
control (0010's last nonzero byte is 0x40234d03). The cave2 pool's static proof (registry
note, TRUTH K7 e standard) covers the whole pool; its status stays "probably-verified" until
a Keys hardware run. Used: 557 B (code 400 B to 0x40234eec, ctl_tab 24 B, pools 91 B,
strings 42 B); 119 B free.

## Build and proofs

Guest only (`make PY=python3.12`, through the session's `gm` wrapper):

- `make DEVICE=keys joy-min`: built `AKEYS_OS1.56_0011.syx`, stub 0x40234d5c (557 B), detour
  0x400b9e66 -> joy_key_gate @ 0x40234d5c; verify PASS: null repack byte-identical, MAIN OS
  round-trips, embedded bootstrap unchanged (53,464 B), embedded UI-board firmware unchanged
  (5,444 B), MAIN OS only; 2 differing regions (0x400b9e66 +6 detour, 0x40234d5c +556 cave),
  both claimed; displaced `0c83000000a5` re-emitted; rejoins 0x400b9e6c.
- `make DEVICE=keys joy`: built `AKEYS_OS1.56_0010_0011.syx`; verify PASS, 4 differing
  regions all claimed (0x400b9819 +5, 0x400b9e5c +16 = 0010's and 0011's detours, 0x4023485c
  +1192, 0x40234d5c +556); all three detours and rejoins correct.
- Unchanged, rebuilt and guest-hashed (`guest_hashes.txt`, identical to the pre-build
  `baseline_hashes.txt` plus the two new files): Keys chord-only 02a4c784..., Keys control
  6981fd94...; Rytm MK1 control 3407638c..., samplefocus 76a2f4d0..., samplefocus-cut
  0ec86d0e..., verify (0000_0002_0003_0008) 0d51f7cb..., random 3dafc0bd...; MK2 control
  f3f6aad0..., samplefocus 016be9ea..., samplefocus-cut 0ce2fe92....

On the BUILT images (host, read-only python + objdump; corp joy-builder):

- `image_proofs.out`: joy-min vs stock and joy vs chord-only: 495 changed bytes each, all in
  0011's two claims; joy vs stock: all in 0010's and 0011's claims; control = stock; 0010's
  claims byte-identical in joy and chord-only; 0011's claims byte-identical in joy and
  joy-min; both never-write ranges stock in all four Keys images; 0x400b9e66 = `4ef9
  40234d5c`, the rejoin untouched; the built pools equal pools.out and pass the membership
  proof; ctl_tab = PB 0x4009a22a/1, MW 0x4009a1c4/0, BC 0x4009a290/0; all 13 absolute
  `jsr`/`jmp` targets are the verified symbols; one indirect call (the getter); the vtable
  constant is 0x4016fba0.
- `emu_joy.out` (`emu_joy.py`: the built code, decoded by objdump into `cave_0011.dis`, run
  in an interpreter that knows only the instruction forms it uses, every stock call modelled
  at its address, `param_index` read from the real ROM): **gate** - 305 key codes x 20 flag
  sets: the roll runs only for 165 with press + FUNCTION + no repeat (6 of 6100 runs), every
  other run makes no call at all; every exit is `jmp 0x400b9e6c` with Z == (code == 165), sp
  and d2-d7/a2-a6 as at entry, nothing written at or above the entry sp. **roll** - 1080
  cases (T 0..7, 0x7fffffff, -1; vtable match/mismatch; count 5/0; PB slot-1 destinations;
  rand vectors forcing collisions and the wrap) plus a null getter result: sp and
  d2-d7/a2-a6 restored, stores only inside the 60-byte frame; T above 5 and CV touch no
  object; only PB/MW/BC getters; setParam/setDepth exactly on PB 1..4, MW 0..4, BC 0..4,
  each id the spec's id for the draw seen, no repeated destination per controller (PB's
  kept slot included), each depth `+-(24 + r % 40) << 8` for its draw, 28 draws per full
  roll; depths seen -63..63, none in -23..23; 133/133 instructions executed and every
  conditional branch taken both ways. PASS. Mutation check (`emu_mutations.out`): flipping
  the gate's FUNCTION test, the duplicate test or the sign, or dropping a5 from the restore,
  each FAILs.
- verify.py's frame check: `lea -60` with `movem` of 10 registers at 20 (ends at 60).

## Limits and risks

- **UI-task stack**: 160 KiB. The task is created at 0x40096486 (`jsr 0x400018e8` with
  TCB 0x4092f044, entry 0x40096908, stack base 0x4092f8bc, size 0x28000 = 163,840 B);
  0x400018e8 sets the task's initial sp to base + (size & ~3) - 12 and stores it at TCB+72,
  so the stack is 0x4092f8bc..0x409578bc. The task's loop calls the key
  dispatcher 0x40095f88 at 0x40096d74 (its only caller; no `rts`/`unlk` between the entry
  and that call); 0x40095f88 -> 0x400611a8 offers the event to the views through vt+8
  (keys-gesture-sk S4). KeyboardView::handleKey 0x400b9de2 has no direct caller: its one
  32-bit reference in the image is its vtable word 0x40187db8 (slot +8). The roll adds 64 B
  (joy_roll's 60-B frame + its return) under handleKey's 52-B frame (`linkw -48`, the
  registers saved inside it), so at each setter call sp is 132 B below handleKey's entry. A
  menu depth edit (ModSetupView vt+0x48 = 0x400365a4, `linkw -32`) calls the same setter 52 B
  below its own entry, and the chain under the setter is the same code. The UI task's peak
  stack use was not computed. (0010's design.md still lists the margin as open; 0010's call
  path was not re-traced in this round.)
- **Notification burst**: 28 per gesture (above); row J11.
- **Overbridge / MIDI**: the +9 path sends a 6-byte message per notification (0x400f19e8 ->
  0x4007410a); its receiver and whether Overbridge mirrors controller assignments are
  UNKNOWN; row J10.
- **Loudness**: filter resonance/overdrive, F12 and the FX sends stay in the pools; volumes,
  feedback and delay overdrive are out. That the joystick springs back to rest is a
  hardware fact not checked here.
- **Repeats after boot**: rolls follow stock rand from its reset state (J9).
- **Menus open**: the controller menus (PITCH BEND, MODULATION WHEEL, BREATH CONTROLLER,
  AFTERTOUCH, VELOCITY MOD: class `12ModSetupView`, vtable 0x401737fc) pass the gesture on,
  so **the roll happens under an open controller menu**. ModSetupView::handleKey 0x40036a1a
  sends code 165 to 0x40036cd6, which calls the base handler 0x4005fa6e (it acts only on
  80/82/81 and returns 0 otherwise) and returns that 0; the view controller then offers the
  key to the views below (keys-gesture-sk S4). Values stay correct, because the menu reads
  the slot from the object before every edit: a depth edit reads getDepth (interface vt+0x2c
  = 0x4001f126 -> 0x4001f0da, at 0x400366fa) and writes `((cur >> 8) + delta) << 8` through
  vt+0x28; a destination edit reads getParam (vt+0x24, at 0x40036336) and looks the id up in
  the picker list, which holds every pool id. So nothing stale is written and no lookup
  misses. Only whether the open menu redraws the new values at once is a hardware check
  (J12). Views that are not controller menus were not traced: they may take the key
  themselves. The gesture acts on the active track whatever the keyboard mode (MIDI EXT,
  MULTI MAP): it edits that track's Sound.
- **Undo** reverts every unsaved edit of that track's Sound, not only the roll (stock
  semantics of the quick reload: 0x400a30da copies the saved 338-B sound back, popup `TRK %d
  SOUND RELOADED`, then 0x400faee2 pushes it to the engine; the FX track: 0x104 B at
  0x400a31aa..0x400a31c2, then 0x400faf30). A saved kit keeps the roll.
- **The same slot can come back**: each rolled slot draws from the whole pool (only the
  destinations already taken in that controller are skipped), so a slot can land on the
  destination it had before. corp joy-integrator `redraw_sim.py` (this stub's walk on
  stock rand, 200,000 consecutive synth rolls): 23.3% of rolls leave at least one of the 14
  slots on its previous destination; no controller ever got a destination twice.
- **Inaudible directions**: some pool destinations change a held note only when another
  part of the sound is in use (an LFO or ENV2 routed somewhere, the noise source, a pulse
  wave, sync). A roll can give the up or the down direction only such destinations; roll
  again (J3). Weighting the pool toward directly audible destinations is a v2 option.
- The physical OCTAVE DOWN = code 165 is inferred from the key table order (J1).

## Test card (never run; Analog Keys on stock 1.56 first)

Before you flash: back up the projects (Transfer); keep the stock
`stock/KEYS_Analog-Four_Analog-Keys_OS1.56.syx` (sha256 `cda4459d14bfba40635440ad9dfa8fc183e5317e5e3ffa7116704f307fdf7010`)
and a DIN MIDI interface at hand; check each file's sha256 (table at the top) before
sending. Route each time: USB, Transfer > CONNECTION > drop the .syx > `[YES]` on the device
(GLOBAL MENU > SYSTEM > OS UPGRADE); do not power off during the first boot afterwards. All
files carry version 1.56, as stock: if Transfer refuses a same-version file, nothing was
written - use the recovery route. Every expectation comes from the code and the emulator,
not from hardware: note what actually happens.

**Run J1-J13 in a scratch project**, never in a project you care about: the rolls change
real kit data, and J8 saves one. GLOBAL (`[FUNCTION]` + `[SONG]`) > PROJECT > LOAD
PROJECT > CREATE NEW (bottom of the list; a blank slate). Loading does not save the active
project first, so save your own project before if it has unsaved edits. When done, load
your own project again; the Transfer backup restores everything.

| row | what | expect |
|---|---|---|
| J0 | **Control first** (skip if 0010's K0 already passed on this unit): flash `AKEYS_OS1.56_control.syx` | boots, plays, OS 1.56 exactly as before |
| J1 | flash `AKEYS_OS1.56_0010_0011.syx`; press OCTAVE DOWN alone, then OCTAVE UP; then hold FUNCTION + OCTAVE DOWN; then (nothing held) FUNCTION + OCTAVE UP | stock `Octave: n` popups, one down then back; `JOY: RANDOM` and the octave does not change (proves 165 = OCTAVE DOWN); `CHORD OFF` (0010 intact) |
| J1b | chord memory with a roll: POLY CONFIG and keyboard as 0010's K2 (4-voice poly group, HOLD off, nothing latched, MIDI EXT, MULTI MAP and transpose off); hold C E G, FUNCTION + OCTAVE UP; release; FUNCTION + OCTAVE DOWN; play D; then, nothing held, FUNCTION + OCTAVE UP | `CHORD ON: 0 4 7`; `JOY: RANDOM`; D plays D F# A (the chord survives the roll: 0011 has no RAM state, and 0010's gate passes code 165 on unchanged); `CHORD OFF` |
| J2 | synth track: first `[NO/RELOAD]` + `[SOUND]` (popup `TRK n SOUND RELOADED`; this undoes J1's roll if J1 was on this track, so the "before" values below are the saved ones); write down SOUND > SOUND SETTINGS > PITCH BEND, MODULATION WHEEL, BREATH CONTROLLER, AFTERTOUCH, VELOCITY MOD (and VELOCITY TO VOL); FUNCTION + OCTAVE DOWN; read the menus again | PITCH BEND slot 1 unchanged; PITCH BEND 2-5, MOD WHEEL 1-5, BREATH 1-5 re-drawn: each a destination from the pool (a slot can land on its old destination by chance; in a model run about 1 roll in 4 has at least one such slot) and a depth of -63..-24 or 24..63; no destination twice in one menu; AFTERTOUCH, VELOCITY MOD and VELOCITY TO VOL unchanged |
| J3 | hold a note; move the joystick up, down and sideways; let go | audible changes; if up or down does nothing audible, press FUNCTION + OCTAVE DOWN again (some destinations only act when an LFO, ENV2, the noise source, a pulse wave or sync is in use) and retry; sideways still bends pitch; at rest the sound is as before the roll |
| J4 | gesture 5 times on the same track | a different set most times |
| J5 | **undo**: `[NO/RELOAD]` + `[SOUND]` | stock popup `TRK n SOUND RELOADED`; the J2 "before" values are back (other unsaved edits of that Sound are reverted too) |
| J6 | FX track: gesture; read the FX track's PITCH BEND / MOD WHEEL / BREATH menus; then `[NO/RELOAD]` + `[SOUND]` on the FX track | FX destinations only (chorus, delay, reverb, EXT sends/pans, FX LFOs); never EXT L/R VOL, chorus or delay feedback, delay overdrive; the reload brings the FX track's saved assignments back (stock reload covers the FX track) |
| J7 | CV track: gesture | `JOY: NOT ON CV`; its menus unchanged |
| J8 | **scratch project only** (see above): roll, then save the kit to the slot it was loaded from (`[YES/SAVE]` + `[KIT]`), power cycle | the roll is still there (it is ordinary kit data) |
| J9 | scratch project: power cycle twice; each time the first gesture on the same track of the same saved kit (after J5 or a kit reload) | note whether the two rolls are identical (stock rand restarts from its reset state) |
| J10 | Overbridge connected (if you use it): gesture 10 times | note any error, desync or what the plug-in shows |
| J11 | **load**: pattern playing, joystick moving, gesture 20 times fast | no crash, no stuck note, no audio dropout (28 setter notifications per press) |
| J12 | open SOUND > SOUND SETTINGS > MODULATION WHEEL; gesture; then turn one depth by one step; leave and re-open the menu. Then gesture with another (not controller) menu open | controller menu: it rolls (the menu passes the key on); note whether the open menu shows the new values at once or only after re-opening; the one-step edit starts from the rolled depth (the menu reads the slot before each edit). Other menu: note whether it rolls |
| J13 | keyboard transpose (FUNCTION + HOLD) or the TRANSPOSE mode active: gesture | rolls (`JOY: RANDOM`); the transpose is unchanged |

0010's own card (K0-K21 in `mods/0010-chord/design.md`) applies to the chord part of the
joy image. If anything in J1-J13 misbehaves, flash `AKEYS_OS1.56_0011.syx` (0011 alone) to
tell 0011 from 0010.

### If it does not boot, or to go back to stock

- **Recovery route** (manual, EARLY STARTUP MENU > OS UPGRADE): Analog Keys **MIDI IN**
  (DIN) from the computer's MIDI interface; hold `[FUNCTION]` while powering on; `[TRIG 4]`
  = OS UPGRADE; in Transfer, SYSEX TRANSFER > "OS Upgrade via device startup menu", send the
  stock `KEYS_Analog-Four_Analog-Keys_OS1.56.syx`. USB MIDI cannot be used from the STARTUP
  menu. Every file here leaves the embedded bootstrap and the UI-board firmware
  byte-identical to stock. That the STARTUP menu is served by the bootstrap is the Rytm
  MK1's case; for the Keys it is inferred, not proven.
- **Back to stock from a booting build**: the normal route with the stock .syx (a
  same-version reinstall, untested here); if refused, the recovery route.
- Nothing the mod keeps is saved; a kit saved after a roll keeps the rolled assignments
  (stock data - `[NO/RELOAD]` + `[SOUND]` before saving, or edit them in the menus).

## Hardware-only unknowns

The notification burst under load (J11); Overbridge (J10); the physical OCTAVE DOWN = 165
(J1); joystick springback (J3); repeats after boot (J9); whether an open controller menu
redraws the rolled values at once, and views other than the controller menus in front of
the keyboard view (J12); cave2's first Keys run (shared with 0010). Not a hardware row: the
UI task's stack size is known (160 KiB, Limits and risks); its peak use was not computed.

## Next steps (not v1)

AFTERTOUCH (one more ctl_tab row, getter 0x4009a2f6, same class); an opt-in CV pool (46
halfword ids, CV set type 8); setSlot if J11 shows the burst matters; a real seed if a
free-running counter is proven.
