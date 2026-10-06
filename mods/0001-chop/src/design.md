# 0001 CHOP - design

Status: **built** (`make chop`, `make chop-min` and `make control` PASS verify in the
guest VM, 2026-10-05, after the round-4 change D15 below - the step lock; `make random`
and the default `make` passed earlier the same day and do not contain 0001). The round-3
build (page, pads, live-REC locks) is reported working on the founder's MK1 (corp round-4
brief; no hardware receipt in this file); **the round-4 step lock has never run on
hardware.**
Local only: this tree has no license and is never pushed or published. Nothing here
flashes a device; the founder flashes.

Line references `dis:N` are lines of
`/Users/creative/analog rytm firmware/build/mainos_1.73_emac.dis` (objdump of
`build/stock_mainos.bin`, base 0x40000400). The RE behind every hook is corp round r2
(`/Users/creative/corp-audits/2026-10-05-rytm-chop/corp/`: `TRUTH.md` decisions D1-D14
and D8a, `r2-re/results.json`, `r2-re/skeptic_fixes.md`). Round 3 (D8a) pairs each pad's
note-off with its note-on; receipts in `corp/fixer-r3/`. Round 4 (D15-D15d) adds the step
lock: trig key(s) held + pad = STA p-lock of that pad's marker on every held step; RE in
`corp/r4-re/results.json` (seats r4-heldlock HL1-HL13 and r4-padheld F1-F10, and their
skeptics' plan problems), build receipts in `corp/r4-builder/`.

## What it does

The **CHOP** page (page id 11) is the SAMPLE view's second page. SAMPLE from another
screen opens the SAMPLE view; there, each press of SAMPLE switches SAMP <-> CHOP (the
page changes on the release). **Press, let go, pause, press again** - not a quick
double-tap: a second press of SAMPLE inside stock's double-tap window is stock 1.73's
sample-list shortcut and stays stock (below, "The SAMPLE key"). The window is 64
key-timer ticks, 2.7 times the delay before a held key counts as held (24 ticks); its
length in seconds is UNKNOWN (H3).

| knob | id | shows | turning it |
|---|---|---|---|
| A `PAD` | 3 | 1..12 | which marker PAD/STA edit (a pad hit in CHOP also sets it) |
| B `STA` | 4 | 0..120 | that marker: a sample start on stock's STA scale (id 43, max 0x7800) |
| C `CHP` | 5 | OFF / ON | right: CHOP on, for the track selected at that moment (the *chop track*); left: off |
| D..H | 0 | blank | - |

The twelve markers start at 0, 10, 20 ... 110.

While CHOP is on, a hit on pad k (k = 0..11):

1. `chop_pad = k` (the PAD knob follows; it is redrawn at the next redraw);
2. **with trig key(s) of the chop track held (D15):** STA = marker k is written as a
   p-lock on every held step, exactly what stock does when you hold those trigs and turn
   the STA knob; the base STA is left alone, so step 3 below is skipped (see "The step
   lock"). Otherwise:
3. the chop track's STA is set to marker k with
   `param_set_value(set, 43, marker << 8, T, record = 1, notify = 1)` on
   `set = kit_track_param_set(project_kit(project_singleton()), T)` - the call a STA
   knob turn ends in (dis:213877-213897 `braw 0x400a6316` with flags 1, 1), so under
   live REC stock writes an ordinary STA p-lock on the chop track's current step;
4. either way, the pad id in the UI message is rewritten to the chop track, and the message goes
   on into stock. KeyboardView then plays (and live-records) the chop track exactly as
   a hit on its own pad: no hand-built fire call, and no track switch away from it.

Note-offs follow their note-ons (D8a). Every note-on of pad k (0..11) records where it
went in `chop_route[k]`: the chop track when it was rewritten, 0xFF when it was not (CHOP
off). The note-off of pad k is rewritten to `chop_route[k]` when that is not 0xFF, and
`chop_route[k]` goes back to 0xFF; otherwise the note-off is stock. The note-off does not
look at `chop_on`, so turning CHP while a pad is held - off, on, or on again with another
track selected - still sends the note-off to the track its note-on went to (below, "The
pads"). A pad id outside 0..11 touches no table and is stock byte for byte; with CHOP
off, pads 0..11 only store 0xFF in `chop_route` and the messages stay stock.

CHOP mode is the RAM flag `chop_on`, not "the CHOP page is on screen" (D6): leaving the
page does not end CHOP; CHP OFF or a power cycle does. Nothing is saved: markers, the
chop track and the flag are RAM only and come back as the image's defaults at power-on.
A recorded chop is an ordinary STA p-lock and plays back on stock firmware.

Consequences to know (by design, from the STA lane):
- Like a STA knob turn, every pad hit in CHOP also changes the chop track's base STA
  and marks the kit edited (kit_param_changed). Leaving CHOP does not restore it. The one
  exception is a pad hit that wrote held-step locks (D15a): like the stock STA knob on
  held trigs, it leaves the base STA and the kit untouched.
- A repeated hit on the same marker still writes and still records (slot 0x24 is only a
  range check, sta-14).
- **CHOP is for the normal pad mode (D14).** With chromatic, scale or any other pad mode
  active (or a mute mode, or anything where pads do something other than play their own
  track), **turn CHP OFF first.** CHOP rewrites every pad note-on and note-off message
  0..11 while it is on, whatever pad mode the unit is in, and its behaviour in those modes is
  unverified (nothing offline shows what their NoteEvent consumers do with a rewritten
  pad id).
- **While CHP is ON, every pad press goes to the chop track and writes its STA - with or
  without a held key** (TRK, FUNC, or any modifier + pad gesture is rewritten too), so the
  pads cannot select another track until CHP is OFF.
- **Pad pressure (aftertouch) is not rerouted in v1** (UI-loop case 2 is untouched): leaning
  on a pad in CHOP still drives the pad's own track, while its note plays the chop track.

## Build

```
make chop       # 0000-shared 0001-chop 0002-euclid-accents 0003-velocity-humanise
                # -> build/AR1_OS1.73_0000_0001_0002_0003.syx
make chop-min   # 0000-shared 0001-chop (bisection) -> build/AR1_OS1.73_0000_0001.syx
```

Both run `symbols layout` first, then `build.py --mods ... --tag ...`, then
`verify.py --tag ...` (modelled on `random`). Builds run only in the guest VM.
0001 is `enabled = false`, so the default `make` is unchanged (0000 0002 0003 0008;
rebuilt after this change: byte-identical .syx, PASS). `make control` (no mods: 0
differing regions) and `make random` (0000 0002 0003 0004) PASS as well.

verify.py's claim check credits a changed byte to the first registry claim that covers
it, whatever its owner, so its log can name 0008 or 0004 claims for CHOP bytes; and it
does not test the .syx packet / content / stream checksums (the vendored tool's extract
ignores its own verdict). Both were checked separately for these builds (in-build claims
only: every changed byte covered; all .syx gates ok, ELE2 header equal to stock); making
verify.py do it is a separate tools change.

**The CHOP image has no SMP CUT (0008) and no LFO RND (0004).** CHOP detours the same
four page hosts (0x400f8736, 0x400381a0, 0x400376e4, 0x400a5908), which build.py
refuses to patch twice (its expect check), and takes the same `cave` claim; so
`excludes = ["0004-lfo-rnd", "0008-sample-cut"]`. Chaining with `chain_pos` is the
alternative if the founder ever wants both in one image.

**The id 0001.** It belonged to a retracted MKII mod, `0001-microtiming-fine`, which
`mods/0002-euclid-accents/mod.toml` still lists in `excludes`. `layout.load_excludes`
works on full id strings, so `0001-microtiming-fine` (which does not exist in this tree)
and `0001-chop` never meet: layout reports `layout ok`, and `make chop` builds with
0001 and 0002 together. Cosmetic only.

## Placement

One claim, `cave` 0x402a1b30 + 0x4d0 (the pool 0008 and 0004 use), section `.text`;
the stub is 1224 B (0x402a1b30..0x402a1ff7, `make chop` and `make chop-min` logs:
"0001-chop: stub 0x402a1b30 (1224 B)"), so **8 bytes of the claim are left free**
(0x402a1ff8..0x402a1fff, zero in the built image; stock UTF-16 data starts at
0x402a2000, unchanged). Round 3 was 932 B; the step lock (D15) added 292 B. Code, the page
list and descriptor, the strings and the 28 B of RAM state all fit there; nothing goes
in cave3 (whose `.tab` neighbour is unexplained, F15), and no second claim was needed
(D15c). The state sits at the end, after every entry point (build.py refuses an odd
entry); addresses from `m68k-elf-nm` of the built `obj/0001-chop.elf`, the same in both
CHOP images (nm of both ELFs compared, round 4):

| label | addr (built, round 4) | default |
|---|---|---|
| `chop_on` | 0x402a1fdc | 0 |
| `chop_track` | 0x402a1fdd | 0 |
| `chop_pad` | 0x402a1fde | 0 |
| `chop_rsv` | 0x402a1fdf | 0 |
| `chop_marks[12]` | 0x402a1fe0 | 0, 10, 20 ... 110 |
| `chop_route[12]` | 0x402a1fec | 0xFF x 12 (D8a: no note-on rewritten yet) |

(Round 3 had them at 0x402a1eb8..0x402a1ed3; the step lock's code moved them up. Any
round-3 address below that is labelled "round 3" refers to that build.)

Every field is a byte, so every store is one instruction. Nothing is written in the
embedded bootstrap [0x4028c708, 0x402a1b24): verify reports it unchanged, and a python
byte compare of each built MAIN OS against `build/stock_mainos.bin` over that span finds
0 differing bytes (chop, chop-min, control).

## Hooks

All expect bytes were re-read from `build/stock_mainos.bin` with python; the registry
entries are in `registry/allocations.toml` under `0001-chop`.

### Detours (8)

| host | expect | entry | rejoin | what |
|---|---|---|---|---|
| 0x400f8736 | 720a202f0004 | page_info_gate | 0x400f873c | page_info answers id 11 with `page_chop` (0008's gate verbatim) |
| 0x400381a0 | 4feffff448d7040c | get_gate | 0x400381a8 | page_get_value for ids 3..5 = shown value << 8 |
| 0x400376e4 | 77832f2a0074 | delta_gate | 0x400376ea | param_apply_delta for ids 3..5: RAM only, then view_invalidate; 0003's gate rejoins here |
| 0x400a5908 | 242f0020262f0024 | text_gate | 0x400a5910 | param_value_text for ids 3..5: number, or OFF / ON |
| 0x400ce4b8 | 2f0247f9400706f0 | sample_key_gate | 0x400ce4c0 | the SAMPLE key on the SAMP view (below) |
| 0x400a1ee2 | 48780080767e | pad_on_gate | 0x400a1ee8 | UI-loop case 3, pad note-on (D7) |
| 0x400a1f26 | 487800804eb94008022e | pad_off_gate | 0x400a1f30 | UI-loop case 4, pad note-off, 10 bytes displaced, paired with its note-on (D8, D8a) |
| 0x40038336 | 4fefffd048d70cfc | lock_gate | 0x4003833e | held-trig knob path, slot 0x7c (D10) |

Each stub re-emits exactly the displaced instructions and then `jmp`s the rejoin;
verify.py checks both, and the built image was disassembled to check them by hand
(below).

### Patches (17)

- SAMP view page list: count 0x400c7162 `7201` -> `7202`; list 0x400c7168 `401af520`
  ({4}) -> `chop_pages` = {4, 11}.
- PARAM_ROM records 3, 4, 5 (0x4018e004 + 52*id), five fields each, as 0008 does for
  its ids: container index +4 `ffffffff` -> 0; max +0xc 0 -> `00007f00`; long name +0x28,
  group +0x2c, short name +0x30 -> `Chop Pad`/`Pad Start`/`Chop Mode`, `CHOP`,
  `PAD`/`STA`/`CHP`. Record type +0 stays `ffffffff`, as in 0008.

The range is 0..0x7f00 for all three, not the page lane's 0x0c00/0x7800/0x0100: the
encoder handler's step size is computed from the ROM range (0x4006db16 via 0x40006ed0;
the exact scaling is UNKNOWN), and 0x7f00 is the range 0008 and 0004 use with the same
`asr #8` = whole-steps delta gates (0004 ran on MKII). With a small range a detent may
come out below one step and the knob would do nothing. The dial graphic therefore
shows PAD and CHP on a 0..127 scale; the number shown is the value (cosmetic).

### The SAMPLE key (D3)

The SAMP view (vtable 0x401b0a84) overrides the key handler with 0x400ce2c4. For code
50 (SAMPLE) it never calls the base handler 0x4003a320 on a plain press or release
(F8: dis:267527-267582), so the base's page cycle never runs and a list patch alone
gives a two-page view SAMPLE cannot cycle. `sample_key_gate` sits at 0x400ce4b8, which
is reached only with code 50 (dis:267400-267402), bit1 clear (dis:267526-267530 sends
bit1 to base), bit2 clear (dis:267531-267535) and, on a release, view+496 == 0
(dis:267462-267468). Live there: d2 = event, a2 = view, stack clean (no other path
enters 0x400ce4b9..0x400ce4bf: the only reference is `beqs 0x400ce4b8`).

- **Press, no hold:** `page_cycle_arm` (0x40a07569) = `weak_ptr_expired(view+512)`,
  i.e. 1 exactly when the press does not close the sample-list popup; then stock. The
  base arms the same byte with the same 0/1 (seq/negl, dis:75997-76000).
- **Release:** if the arm byte is set, bit4 is set (ev_bit4), there is no long hold
  (ev_is_held), view+136 == 50 and no sample-list popup is open
  (`weak_ptr_expired(view+512)` = 1; an open popup is stock: no cycle, see the double-tap
  below), then every condition of the base's cycle branch holds
  (dis:75780-75786 arm and code == +136; dis:76015-76031 bit4, no hold, no bit1,
  +496 == 0), so the event goes to the base through the SAMP handler's own tail
  0x400ce3f4 (`base(view, event)`, result -> d3, epilogue; dis:267485-267490). The base
  then advances view+140 modulo the page count, view_invalidate, 0x4006d834, vtable+80
  (title) (dis:76032-76050) and returns. Otherwise: stock.
- **Anything else** (long hold, bit-1/bit-2 events, other keys): stock, arm untouched.

**The double-tap (stock, kept).** The key scanner marks a press bit2 when it is the same
key as the last press and comes less than [0x40249d84] = 0x40 = 64 key-timer ticks after
it (0x400803da `cmpl 0x40249d94,%d4`; 0x400803e2-0x400803ee `now - last < 0x40249d84`;
0x400803fa `moveq #5` = down | bit2). The first held-key event comes [0x40249d80] = 0x18
= 24 ticks after a press (0x40080422-0x40080428). Both words were read from
`build/stock_mainos.bin`. MainScreenView switches screen on a press of keys 48..53
(0x400c8b2e-0x400c8b44) without consuming the event (no call to 0x40070648 or
0x4007066c, the two routines that reset the last-key word through 0x40080334), so a
quick second SAMPLE press after the press that opened the SAMPLE view is bit2 too. The
SAMP handler sends a bit2 SAMPLE press to the sample-list popup routine 0x400cdf62(view,
-1) and returns 1 (0x400ce49c-0x400ce4b6); `sample_key_gate` at 0x400ce4b8 never sees
it. So:

- From another screen, SAMPLE twice quickly = the SAMPLE view with the sample list open
  (stock). CHOP needs a press after the window has passed.
- On the SAMPLE view, a quick double-tap: the first press arms, its release switches the
  page, and the second (bit2) press opens the sample list. The arm byte from the first
  press is still set at the second release (only the gate and the base's press path
  write it: dis:76000 and the gate). Without the popup test that release switched the
  page back and the base's title call vtable+80 = 0x400cdede closed the open list
  (0x400cdef2-0x400cdf14). With it, the list stays open, on top of whichever page the
  first release switched to. Stock leaves the list open too (on SAMP, its only page).
- Residual: 0x400cdf62 can return without opening a list (0x400cdfda, 0x400ce036 and
  0x400ce048 exit early on held-trig / lock-source states). A quick double-tap there
  switches the page twice (back where it started); stock does nothing.

Because the gate checks every condition the base checks before handing over, the base
can only take the cycle branch; it never reaches its default handler 0x40076ace from
here. Premise not proven on MK1: that a SAMPLE release carries bit4 - the same premise
0008's and 0004's FILTER/LFO cycling rely on (H3). The AMP fallback of D3 was not
needed.

### The pads (D7, D8, D8a)

UI loop (dis:207717-207727): `pea 0x40b1065c; moveq #39,%d3; jsr 0x400012c8` takes a
message into a2 and switches on its first byte through the jump table at 0x400a1e62
(entry 3 = 0x0080 -> 0x400a1ee2, entry 4 = 0x00c4 -> 0x400a1f26; a python scan of all
40 entries finds none inside either displaced span, and no branch targets them).

- Case 3, 0x400a1ee2 (dis:207767-207787): `pea 0x80; moveq #126,%d3; jsr is_key_held`,
  then msg+4 (pad), min(msg+8, 127) and msg+12 into the NoteEvent ctor 0x400746e6 and
  the view dispatch 0x4009e350; `lea %sp@(32)`; `bras 0x400a1f5a` (destroy, loop).
  `pad_on_gate` (D7 + D8a): k = msg+4; k > 11 unsigned (or -1): stock, no table
  touched. k <= 11 and CHOP off: `chop_route[k] = 0xFF`, message untouched. k <= 11 and
  CHOP on: `chop_route[k] = chop_track`, chop_pad = k,
  `chop_held_lock(chop_track, chop_marks[k])` and, unless it locked held steps (round 4,
  "The step lock"), `chop_set_sta(chop_track, chop_marks[k])`; then msg+4 := chop_track. Every path then runs
  the displaced `pea 0x80; moveq #126,%d3` and `jmp 0x400a1ee8`. It never jumps to
  0x400a28ba (skeptic: that lands on an `addql #4,%sp` and corrupts the stack).
- Case 4, 0x400a1f26 (dis:207788-207801): `pea 0x80; jsr is_key_held` has no 6-byte
  boundary, so the detour displaces 10 bytes and rejoins at 0x400a1f30; the 4 bytes
  after the jmp stay stock and are never executed. The pushed 0x80 stays on the stack
  until stock's own `lea %sp@(36),%sp` at 0x400a1f56, exactly as in stock.
  `pad_off_gate` (D8a): k = msg+4; k > 11 unsigned: stock, no table touched. k <= 11 and
  `chop_route[k] == 0xFF`: stock. Otherwise msg+4 := chop_route[k] and
  `chop_route[k] = 0xFF` (used once). It does not read `chop_on`.
- So a note-off follows its note-on. Hold pad 5 with CHOP on for track 2 (note-on as 2,
  route[5] = 2), turn CHP left, let go: the note-off goes to track 2 too, and route[5] is
  0xFF again. Turn CHP on for track 7 while pad 5 is held from a CHOP-off note-on
  (route[5] = 0xFF): its note-off stays pad 5, as its note-on was. The values stored in
  `chop_route` are only `chop_track` (which delta_gate sets only when the selected track
  is 0..11, stub `bhi.s 6f` before `move.b %d0,chop_track`; default 0) or 0xFF, so a
  rewritten note-off always names a track 0..11. A note-off that never arrives leaves
  `chop_route[k]` set until pad k's next note-on, which overwrites it. In the normal pad
  mode the consumer is KeyboardView::consumeNoteEvent (0x400c4628), which ignores
  note-offs: it tests note-on (0x400c472a `jsr 0x40074748`, NoteEvent+16 == 1) and on a
  note-off goes to 0x400c4732 `beqw 0x400c48c0` -> `moveq #1` (consumed, nothing played
  or stopped). The pairing matters for any other consumer that does act on note-offs;
  what those do in other pad modes stays unverified (D14: CHP OFF there; H4).
- The table at 0x40249d98 maps nibble 12 to pad id -1 (sk-pads); the unsigned test sends it (and
  anything above 11) down the stock path.
- Registers: d2 (the NoteEvent buffer), d4-d7 and a2-a6 are kept (callees are C and
  chop_set_sta saves d2/d3); d0/d1/a0/a1 are dead at entry: the next instruction after
  both re-emits is `jsr 0x4008022e` (is_key_held), which writes d0, a0 and d1 before it
  reads them (dis:165740ff, 0x40080230 / 0x40080234 / 0x4008023a); d3 is set by the
  re-emitted moveq in case 3 and not touched in case 4.

### chop_set_sta (D9)

`chop_set_sta(d0 = T, d1 = V)`: `T > 11` unsigned returns before touching anything
(0x400a39fa maps 12 and up to the FX set, kit+4724, sk-sta F1; stock guards the same way
at dis:180148-180154). Otherwise: project_singleton -> project_kit (0x400ab706, +232) ->
kit_track_param_set(kit, T) (0x400a39fa) -> param_set_value(set, 43, V << 8, T, 1, 1)
(0x400a6316, the entry, so any future gate on it still runs). Stock precedent, the same
sequence with id 0x29: dis:180147-180167. It runs in the UI task only (the case-3 loop).
It never uses 0000-shared's `shared_sound_of` / `PROJ_KIT = 352`.

### The held-trig path (D10)

The encoder handler calls page-view slot 0x7c (0x40038336) instead of slot 0x58
(param_apply_delta, where delta_gate sits) when 0x40036512(view+108) is non-null or
0x400366a2 is true (dis:75274-75284, 75341-75347): the held-trig / lock-source path,
which would make a stock p-lock. 0008 has no guard there. `lock_gate` at its entry
returns `d0 = 0` for ids 3..5 - what slot 0x7c itself returns when slot 0x6c says the id
cannot be locked (dis:73011-73018, 73154-73157) - and the only caller ignores d0
(`lea %sp@(12),%sp; braw 0x40039f8e`). Slot 0x7c has no direct jsr; seven vtable words
point at it (base 0x4019a7ac+0x7c and SAMP 0x401b0a84+0x7c among them) and nothing points
into its first 8 bytes past the entry. No stock page lists ids 3..5 (python read of all
eleven descriptors), so every other id goes down the stock path unchanged.

### The step lock (D15-D15d, round 4)

Stock 1.73 has a "hold trig + turn knob" path: page-view slot 0x7c (0x40038336) with no
lock source runs `0x40036016(S, 1)`, then `getStepsHeldDown(S, fn, 0)` (0x4003683c) whose
per-step invoker (0x40037c42) ends in `set->vt[0x40](set, id, value, step)` through slot
0x74 (0x40037bdc), then `0x40036114(S)` (dis:73128-73152, 72377-72405). The UI loop runs
the same skeleton on its own at 0x4009f2ee..0x4009f352 (dis:204400-204427). CHOP reuses
that path, with a pad as the "knob" and marker k as the absolute value.

`pad_on_gate`, CHOP on, k = 0..11: `chop_route[k] = chop_track`, `chop_pad = k`, then
`chop_held_lock(T = chop_track, V = chop_marks[k])`. If it returns 1, `chop_set_sta` is
skipped (D15a: the base STA and the kit are untouched and no live-REC lock is written on
the playing step - exact stock held-knob semantics). If it returns 0, T and V are
reloaded (from `chop_track`, and `chop_marks[chop_pad]`, which was just set to k; the
helper clobbers d0/d1/a0/a1) and `chop_set_sta(T, V)` runs with record 1, as in round 3.
Either way the `msg+4 := chop_track` rewrite and the stock continuation follow (D15b),
and `chop_route` pairing is unchanged.

`chop_held_lock(d0 = T, d1 = V)` returns 0, with no side effect, at the first guard that
fails (every call before the last guard is a getter: they only read):

| # | guard (D15) | code |
|---|---|---|
| 1 | S = UIStates | `jsr ui_states` (0x401573b6), kept in a2 |
| 2 | no scene/perf locker | `hold_lock_source(S)` (0x40036512, S+440) == 0 |
| 3 | a trig held | `hold_any_in_length(S)` (0x400366a2) != 0 |
| 4 | T is a sound track | T <= 11 unsigned (0x400a39fa maps 12+ to the FX set at kit+4724, dis:209911; r4 skeptic F7: FxParameterSet's vt[0x40] is a different routine, 0x400a6d42) |
| 5 | the selected track is T | `track_index_of(project_selection(project_singleton()))` (0x400b3a04(0x400ab6ce(...))) == T |
| 6 | STA lockable (slot 0x6c) | `(*(long *)param_info(43)) & 0x100` == 0 (0x400f8718; slot 0x6c 0x40037728 is this test, dis:71991-71999) |

Then, as stock: `set = kit_track_param_set(project_kit(project_singleton()), T)`; a
16-byte functor on the helper's own stack frame, `{+0 V << 8, +4 set, +8 manager, +12
chop_lock_step}`; `hold_set_edited(S, 1)` (S+352 = 1: the trig key's release then skips
its pending toggle, dis:79485-79489); `hold_each_step(S, &fn, 0)`;
`hold_clear_actions(S)` (clears the 64 pending release actions S+88..S+343); return 1.
`chop_lock_step(fn*, step, bool* stop)` calls `set->vt[0x40](set, 43, V << 8, step)`
(SoundParameterSet vtable 0x401aa6b4 + 0x40 = 0x400a6bd0 in the built image, read with
python) and leaves `*stop` alone. The functor: `0x4003683c` returns at once if the word
at fn+8 is 0 (0x40036888), calls fn+12 as `(fn*, step, &stop)` (0x400368c8-0x400368d2),
stops when stop != 0 (0x400368d8), and never calls fn+8, copies or destroys fn (it calls
0x401887cc only when fn+8 is 0, which it already returned on). Stock's own functor is a
heap object freed by 0x40146854; CHOP's lives on the stack, holds its data inline, and
is never freed - nothing is allocated. `chop_fn_mgr` (`moveq #0,%d0; rts`) is the
non-null manager word; nothing calls it. The helper saves and restores d2/d3/a2 (frame:
12 B of registers + the 16 B functor), so pad_on_gate's a2 (the message) and d2 (the
NoteEvent buffer) survive.

What the lock is and where it lands (the claims as the RE skeptics worded them):
- **Same store as the stock knob:** `0x400a6bd0 -> 0x400bd5b4 -> 0x400a9984`, a dense RAM
  table (track*2837 + step*44 + lockid words); an existing STA lock on a held step is
  overwritten in place with V << 8. Any cap in the DataChangeInfo ->
  `PatternParamLocks::updateMirror(patternParamLocksStorage_v0_t*)` storage mirror is
  **UNKNOWN, and identical to stock's** (the knob path fires the same notify).
- `0x400a6bd0` never reads its set argument: it writes the **selected** track
  (project+48). Guard 5 is why the lock can only land on the chop track.
- The held steps are the selected track's steps (the trig-key handler sets the mask from
  view+116; `hold_each_step` with all = 0 visits held steps below
  `pattern_length(current_track_pattern(project))`, as the stock knob path does).
- No transport test anywhere on the route: it works stopped or playing, like the knob.
- No value popup (stock's knob tail draws one, 0x40035ec4; the pad path does not).
  Redraw comes from the hold object's notify (S+56 = 1, from 0x40036016 / 0x40036114) and
  the lock store's DataChangeInfo; who consumes them is UNKNOWN.
- Stock KeyboardView does consult the held trig on the pad hit that follows (0x400c3cac:
  with a trig held it auditions with the first held step's lock row via 0x4024a504, and
  while the sequencer runs - INFERRED - it skips the 0x40117348 block and the record
  tail). The lock is written **before** the rewritten message reaches stock, so the
  audition probably already plays the new STA lock (INFERRED; H6). The meanings of
  0x40083b16 and 0x40117348 are UNKNOWN.
- A held trig on another track than the chop track (CHOP latched on track B while
  track A is selected): guard 5 fails, so no lock is written and the hit takes the
  round-3 path (base STA of the chop track, record 1). The pads cannot set this up:
  with CHP ON every pad press, TRK + pad included, goes to B, and turning CHP right
  again re-latches the chop track to whatever is selected (delta_gate). It needs a way
  to change the selected track that is not a pad press; whether one exists is UNKNOWN
  (H6 (f)). Guard 5 is defensive in normal use.

New stock symbols (re/symbols.toml, with receipts): `ui_states` 0x401573b6,
`hold_lock_source` 0x40036512, `hold_any_in_length` 0x400366a2, `hold_set_edited`
0x40036016, `hold_each_step` 0x4003683c, `hold_clear_actions` 0x40036114,
`project_selection` 0x400ab6ce. `param_info` (0x400f8718) already existed. No new detour
or patch: the existing pad_on_gate detour carries it, so the registry is unchanged.

#### Round-4 proof on the built image (host, read-only objdump / python)

Files in `corp/r4-builder/` (copies of the guest's outputs): `baseline-head/` (HEAD
4bde508's `make chop` image, rebuilt in the guest: identical to the pre-existing one) and
`v2/` (this build); disassemblies `v2/HEAD_pad_on_gate_chop_set_sta.dis`,
`v2/NEW_pad_on_gate_through_chop_fn_mgr.dis`, `v2/cave_code.dis`. The r4 integrator's
corrections (`corp/r4-integrator/`) are text only, in this file and in the registry's
cave note: `make chop`, `make chop-min` and `make control` were rebuilt in the guest
(PASS), and every output (.bin, .syx, manifest) compares equal to the round-4 build.

- **CHOP off, and k > 11:** the instructions from pad_on_gate's entry to its `bras` to
  the re-emit, and the re-emit `pea 0x80; moveq #126,%d3; jmp 0x400a1ee8`, are the same
  as HEAD's, instruction for instruction once branch targets and pc-relative operands are
  named (python over both disassemblies: equal). Only displacements differ.
- **CHOP on, no trig held:** the helper returns 0 at guard 2 or 3 after three getters
  (`ui_states`, `hold_lock_source`, `hold_any_in_length`). Stock calls the last one in
  the UI task as well: KeyboardView's play routine 0x400c3c80 calls it (0x400c3cac) on
  the pad hits it plays. Not on every hit: consumeNoteEvent (0x400c4628) skips the play
  call 0x400c4784 on a note-off (0x400c4732), for a pad above 12 (0x400c473a) and when
  key 0x45 is held and 0x4003624c(S) is true (0x400c46e0-0x400c46f0; r4 skeptic F10),
  among other early exits, and 0x400c3c80 itself skips it for a pad above 12
  (0x400c3ca2-0x400c3ca4). The encoder handler (0x40039f5e) and the routine the UI loop
  calls at 0x400a22da (0x4009f046: 0x4009f0bc, 0x4009f162) call it too. Then the same
  `chop_set_sta(T, V)` with the same T and V as HEAD (chop_pad = k was stored before the
  call and the helper writes no CHOP state), whose 26 instructions are byte-identical to
  HEAD's, then the same rewrite and re-emit. Same side-effecting call sequence as HEAD:
  project_singleton, project_kit, kit_track_param_set, param_set_value(set, 43, V << 8,
  T, 1, 1).
- **chop_held_lock (0x402a1e02..0x402a1ee3):** every guard-fail branch (`bnew/beqw/bhiw
  0x402a1ed8`) is taken with the stack at the frame base (each call's arguments popped
  before the test); the success path pushes and pops 4, 4, 4, 4, 8, 8, 12 and 4 bytes
  (the last is hold_clear_actions, 0x402a1eca-0x402a1ed2; re-counted by the r4
  integrator); both exits restore d2/d3/a2 with `moveml %sp@` and pop the 28-byte
  frame. The functor stores land at sp+12..sp+27, inside the frame; `&fn` is taken with `lea %sp@(12),%a0`
  before any argument is pushed. `chop_lock_step` pushes 16 and pops 16 and touches only
  a0/a1 (plus what the stock callee clobbers).
- **Branches:** every branch in the stub resolves to an instruction start in the stub
  (python over `cave_code.dis`: 0 bad). The far guards are `.w` (+102..+180); every
  `.s` in the changed code (0x402a1ce6..0x402a1f09) is within +92.
- **Unchanged callees:** each stock routine on the route (ui_states, hold_*,
  project_selection, track_index_of, param_info, project_kit, kit_track_param_set,
  0x400a6bd0, project_singleton, 0x40034464, 0x4013730c, 0x4013735c) is byte-identical to
  stock in the built image (python).
- **New vs HEAD image:** 89 differing regions, 77 inside the cave; the 12 outside are the
  relocated jmp targets of the lock_gate and pad_off_gate detours, the chop_pages
  pointer, and the nine string pointers in PARAM_ROM records 3..5.

## Disassembly check of the built image

(Round 3. In the round-4 build the stub labels moved: pad_on_gate 0x402a1ce6 (same),
pad_off_gate 0x402a1d58, lock_gate 0x402a1d8c, chop_set_sta 0x402a1daa, chop_held_lock
0x402a1e02, chop_lock_step 0x402a1ee4, chop_fn_mgr 0x402a1f06, chop_pages 0x402a1f82,
strings 0x402a1fae..0x402a1fdb; the other five gates kept their addresses.)

`m68k-elf-objdump -D -b binary -m m68k:cfv4e --adjust-vma=0x40000400` on
`build/mainos_0000_0001_0002_0003.bin` (host, read-only):

- each of the 8 hosts holds `4ef9 <entry>` and the entry is the right stub label
  (page_info_gate 0x402a1b30, get_gate 0x402a1b4c, delta_gate 0x402a1b6e, text_gate
  0x402a1c0c, sample_key_gate 0x402a1c60, pad_on_gate 0x402a1ce6, pad_off_gate
  0x402a1d3a, lock_gate 0x402a1d6e), in both images; the bytes after each jmp up to the
  end of the expect span are stock (0x400a1ee2 `4ef9402a1ce6`, 0x400a1f26
  `4ef9402a1d3a` + stock `4008022e`);
- sample_key_gate's release path holds the popup test at 0x402a1c9a-0x402a1ca8
  (`pea %a2@(512); jsr 0x40178ed8; addql #4,%sp; tstb %d0; beqs 0x402a1cd8`, the stock
  re-emit) right before `jmp 0x400ce3f4`; the pea is popped before either exit;
- in the stub, each displaced sequence appears exactly once, immediately followed by
  `jmp <rejoin>`, byte-identical to stock;
- every handled path returns with `rts` from a balanced frame (0008's epilogues where
  0008 has the gate; `moveq #0; rts` in lock_gate; chop_set_sta saves and restores d2/d3
  in an 8-byte frame); every other path ends in the re-emit + rejoin; no path jumps
  anywhere else except sample_key_gate's `jmp 0x400ce3f4` with the entry stack.
- the patches: 0x400c7162 `7202`, 0x400c7168 -> `402a1e5c` (= chop_pages {4, 11}),
  the fifteen ROM fields pointing at the strings at 0x402a1e88..0x402a1eb5.

### The pad gates, every path (round 3, built image)

`m68k-elf-objdump -D -b binary -m m68k:cfv4e --adjust-vma=0x40000400
--start-address=0x402a1ce6 --stop-address=0x402a1de4` of
`build/mainos_0000_0001_0002_0003.bin` (saved as `corp/fixer-r3/pad_gates_built.dis`).
Both gates enter by `jmp` with the stack as stock had it at the host (clean), and
touch only d0, d1, a0 (plus d3 via the re-emit in case 3) and memory at msg+4,
`chop_pad` and `chop_route[k]`.

pad_on_gate 0x402a1ce6:
- `movel %a2@(4),%d0; moveq #11,%d1; cmpl %d1,%d0; bhis 0x402a1d2e` - the unsigned k <= 11
  test comes first, before `lea chop_route; addal %d0,%a0` (0x402a1cf0) and before the
  marker index `moveb %a0@(0,%d0:l),%d1` (0x402a1d16). So both tables are only indexed
  with k = 0..11, and the only route store `moveb %d1,%a0@` (0x402a1cfe or 0x402a1d08)
  writes 0x402a1ec8 + k, inside `chop_route`.
- k > 11: straight to 0x402a1d2e. Stack untouched.
- CHOP off (`tstb chop_on; bnes` falls through): `moveq #-1,%d1; moveb %d1,%a0@` (0xFF),
  `bras 0x402a1d2e`. Stack untouched.
- CHOP on: route = chop_track, `moveb %d0,0x402a1eba` (chop_pad), marker into d1, T into
  d0, `bsrw 0x402a1d8c` (chop_set_sta; pushes and pops its own return address), T into
  d0, `movel %d0,%a2@(4)`. chop_set_sta: `cmpil #11,%d0; bhis` -> `rts` with nothing
  pushed; else `lea %sp@(-8)` + `moveml %d2-%d3,%sp@`, then pushes 4 / pops 4 (`addql
  #4`), pushes 8 / pops 8 (`addql #8`), pushes 24 / pops 24 (`lea %sp@(24)`), `moveml
  %sp@,%d2-%d3` + `lea %sp@(8)`, `rts`: balanced, d2/d3 restored.
- 0x402a1d2e: `pea 0x80; moveq #126,%d3; jmp 0x400a1ee8` - the stock bytes `4878 0080
  767e` (dis:207767-207768) and the rejoin right after them (0x400a1ee8 `jsr
  0x4008022e`, dis:207769).

pad_off_gate 0x402a1d3a:
- `movel %a2@(4),%d0; moveq #11,%d1; cmpl %d1,%d0; bhis 0x402a1d5e`, then `lea
  chop_route; addal %d0,%a0`: the same k <= 11 test before the index.
- `moveq #0,%d0; moveb %a0@,%d0; cmpil #255,%d0; beqs 0x402a1d5e`: 0xFF -> stock.
- else `movel %d0,%a2@(4)`, `moveq #-1,%d1; moveb %d1,%a0@` (route[k] = 0xFF, k <= 11).
- No push or pop on any path before 0x402a1d5e: `pea 0x80; jsr 0x4008022e; jmp
  0x400a1f30` - the stock bytes `4878 0080 4eb9 4008 022e` (dis:207788-207789) and the
  rejoin right after them (0x400a1f30 `clrl %sp@-`, dis:207790). The pushed 0x80 is
  popped by stock's `lea %sp@(36),%sp` at 0x400a1f56 as in stock.
- Both stock paths then read msg+4 after the gate: case 3 at 0x400a1ef4 `movel
  %a2@(4),%d1`, case 4 at 0x400a1f3e `movel %a2@(4),%sp@-` - so the rewrite is what stock
  plays.

### Differing regions (round 3)

A python compare of each built MAIN OS with `build/stock_mainos.bin`
(`corp/fixer-r3/regions.py`, output `regions.out`), each changed byte matched against the
registry claims of the mods in that build only:
- `make chop`: 279 regions, 2481 bytes; 0 uncovered. 0001-chop owns: detours 0x400376e4
  (two regions, +3 and +2), 0x400381a0, 0x40038336, 0x400a1ee2, 0x400a1f26, 0x400a5908,
  0x400ce4b8, 0x400f8736 (+6 each); patches 0x400c7163 +1, 0x400c7169 +3 and the 15 ROM
  fields 0x4018e0a4..0x4018e13b (15 regions; 9 detour + 17 patch regions in all); the
  `cave` stub 0x402a1b30..0x402a1ed3 (90 regions: bytes equal to stock's zeros split it).
  0002-euclid-accents owns detours 0x40008ba4, 0x40008e42, 0x400376d4, 0x40098ade,
  0x40098b86, 0x400a58f8, 0x400bde96, 0x400bdec6, 0x400c0ca2, patches 0x400a5b67,
  0x400a6fc3, 0x400f85a3, 0x400f85ad, 0x400f85b9, 0x400f8639, 0x400f8655, 0x4011cbe5 and
  its cave 0x402a2780..; 0003-velocity-humanise owns detours 0x400376dc, 0x40098fb4,
  0x400a5900, 0x400a62ae, patch 0x400a5ad1 and its cave 0x402a2e24..; 0000-shared its cave
  0x402a2d39..0x402a2e21.
- `make chop-min`: 133 regions, 1103 bytes, 0 uncovered: the 0001-chop set above plus
  the 0000-shared cave.
- `make control`: 0 regions.
- All three: 0 differing bytes in [0x4028c708, 0x402a1b24).

Round 4 (`corp/r4-builder/regions.py` on the copies in `corp/r4-builder/v2/`, output
`v2/regions.out`; same method):
- `make chop`: 314 regions, 2733 bytes, 0 uncovered; CHOP's cave bytes differ from stock
  from 0x402a1b30 to 0x402a1ff7 (the claim ends at 0x402a2000).
- `make chop-min`: 168 regions, 1355 bytes, 0 uncovered.
- `make control`: 0 regions.
- All three: 0 differing bytes in [0x4028c708, 0x402a1b24); verify.py also reports
  "embedded bootstrap image unchanged" and "null repack" ok.

## Hardware-only unknowns (the founder's test card)

Nothing below can be proven offline. The round-3 build is reported working on the
founder's MK1 (page, pads, live-REC locks; corp round-4 brief); the round-4 step lock
(H6) has not run on hardware.

### Before you flash

1. Back up your projects (Transfer can back up the +Drive).
2. Keep at hand the stock file, `stock/Analog-Rytm_OS1.73.syx` (sha256
   `9115c3888354bb388f90410e0445cd312bf020593ed99f768a99e475d1d6157c`, stock/SHA256SUMS),
   and a DIN MIDI interface: the recovery route is DIN only.
3. Check each file's sha256 against the list below before you send it.

### Flash order

Normal route each time (docs/FLASHING.md): USB connected, power on; Transfer >
CONNECTION: MIDI IN and OUT = the Analog Rytm; Transfer > DROP: drag the `.syx` on;
press `[YES]` on the device. The unit restarts by itself. **Do not power off during
the first boot afterwards** (docs/HAZARDS.md: the MK1's bootstrap upgrade runs from
inside MAIN OS). The embedded bootstrap [0x4028c708, 0x402a1b24) is byte-identical to
stock in every file below (verify "embedded bootstrap image unchanged", and a python
byte compare: 0 differing bytes).

1. **Control first:** `build/AR1_OS1.73_control.syx` - stock code, only repacked by our
   tool (`make control`: PASS, 0 differing regions). Check it boots and plays a pattern.
   This proves the packer and file format on this unit, so a later problem is a mod.
2. **Then CHOP:** `build/AR1_OS1.73_0000_0001_0002_0003.syx` (`make chop`: CHOP with
   0000 shared, 0002 euclid accents and 0003 velocity humanise). Check it boots and plays,
   then run H1-H6 below (H6 is the round-4 step lock).
3. Only if the CHOP build misbehaves: `build/AR1_OS1.73_0000_0001.syx` (`make chop-min`,
   CHOP and 0000 only) to bisect. Fails the same way = CHOP (or 0000); works = 0002/0003
   next to CHOP.

If Transfer refuses a file as the same version, nothing has been written: either stop, or
send that file through the recovery route below (FUNC at power-on, TRIG 4, LEGACY OS
UPGRADE over DIN).

**Never flash the upstream SMP CUT (`..._0008.syx`) or RANDOM (`..._0004.syx`) builds** from
this tree: 0000-shared's `PROJ_KIT = 352` (the MKII kit offset) is used only by 0008 and
0004 (grep of mods/: 0000-shared, 0004, 0008), and stock 1.73 MK1's kit is at project + 232
(sk-sta S1). The CHOP build does not contain 0004 or 0008, and 0002/0003 call only
shared_rnd / shared_func_held / shared_fmt_u8.

### If it does not boot, or to go back to stock

- **Recovery route** (docs/FLASHING.md; served by the bootstrap in flash, not by MAIN
  OS, so it comes up even after a MAIN OS that does not boot; **DIN MIDI only**, a
  USB-MIDI interface into the Rytm's MIDI IN, not USB):
  1. hold `[FUNC]` while powering on;
  2. `[TRIG 4]` enters OS UPGRADE;
  3. Transfer > CONNECTION: "LEGACY OS UPGRADE mode", select the stock
     `stock/Analog-Rytm_OS1.73.syx` (sha256 above), UPGRADE.
- **Back to stock from a booting build:** the normal route with the stock `.syx`. All
  builds carry version 1.73, the same as stock, so this is a same-version reinstall; the
  device refuses downgrades, and a same-version reinstall over these builds has not been
  tried (H5). If it is refused, use the recovery route.
- Nothing CHOP does is saved: power-cycling ends CHOP and resets the markers. STA p-locks
  recorded with CHOP are ordinary p-locks and stay in the pattern (stock plays them).

Files verified on 2026-10-05 after the round-4 change D15 (guest VM, `make chop`,
`make chop-min`, `make control`, all PASS), sha256:
`AR1_OS1.73_control.syx` 3407638c3f450daba0faedbddc0d4f08b154925a3ba162172346f51ef9ed6a8d,
`AR1_OS1.73_0000_0001_0002_0003.syx` a96657b49e70b42fc20b9d744a0f10ceceb0f065c0aac7201be88866ac15caf6,
`AR1_OS1.73_0000_0001.syx` 86c543c94eeea3820f1d7e9184c14d1a13483ddc80bab809ff2a2dc2b95c988a.
(The round-3 CHOP files 3ea80d31… and 3c77f43b… have no step lock; the round-2 files
5614a93e… and e19703af… do not pair note-offs. Control is unchanged.)

### The unknowns (test in the normal pad mode, D14)

- **H1** Does a pad hit play from the new STA on that same hit? (Voice latch timing: the
  audio target word 0x80005116 + 0x54*T is written synchronously, but whether the voice
  latches STA from it or from the smoothed PARAMS_EFF is unknown. The 1.72 host prototype,
  CC 28 then note, says yes for that path.)
- **H2** Under live REC, does the STA p-lock land on the same step as the pad's recorded
  trig (quantize, late hits)? The lock goes on 0x40035208's current step for the track.
- **H3** Does the CHOP page draw and cycle correctly: SAMPLE -> SAMP; press, let go,
  pause, SAMPLE again -> CHOP; again (after a pause) -> SAMP; knob labels PAD/STA/CHP;
  values and popups; a long hold of SAMPLE behaves as stock. (Needs the SAMPLE release
  to carry bit4.) The double-tap, which is stock and kept:
  (a) from another screen, SAMPLE twice quickly: the sample list opens (stock), no CHOP;
  (b) on the SAMPLE view, SAMPLE twice quickly: the page switches once and the sample
  list opens on top of it and stays open;
  (c) with the list open, one press of SAMPLE after a pause closes it and does not
  switch the page (a quick one is bit2 again and goes to the list routine, as in stock);
  (d) how long the pause must be (the double-tap window, 64 key-timer ticks, in seconds);
  (e) whether SAMPLE from another screen reopens the view on CHOP after you left it on
  CHOP (the page index is kept in the view; no reset on entry was found for a normal
  track - UNKNOWN);
  (f) do not use FUNC + SAMPLE (page copy / paste / clear) while the CHOP page is shown:
  untraced for ids 3..5.
- **H4** No crash and no hung or stuck voice, in the normal pad mode:
  (a) repeated hits on one pad, fast rolls across all twelve pads, two pads held at once;
  (b) note-off pairing (D8a): hold a pad with CHOP on, turn CHP OFF, let go - the chop
  track must not hang, and the pad's own track must get no stray note; then hold a pad
  with CHOP off, turn CHP ON, let go - the pad's own track behaves as stock; then hold
  a pad with CHOP on for track A, turn CHP OFF, select track B (TRK + pad: with CHP ON the
  pads cannot select another track), turn CHP ON again, let go - track A must not hang;
  (c) the chop track's own pad, hit and held in CHOP: plays and releases as stock;
  (d) with the FX track selected, turning CHP right must leave it OFF (no latch);
  (e) CHOP left ON while you leave the CHOP page and play pads elsewhere: the chop track
  plays, no crash;
  (f) press and lean on a pad in CHOP: the note plays the chop track, the pressure still
  goes to the pad's own track (by design in v1) - no crash, no hung voice.
  Other pad modes (chromatic, scale, mutes ...): CHOP is not meant for them - turn CHP
  OFF first (D14). If you do try one with CHOP on, the behaviour is unverified; stop at
  the first hung voice.
- **H5** Recovery: a same-version reinstall of stock 1.73 over a CHOP build (normal
  route), and if that is refused, the DIN recovery route above (untested by the
  upstream author too).
- **Hardware result 2026-10-06 (founder, MK1 OS 1.73, build a96657b4…caf6): step lock works.** H1–H4 passed on 2026-10-05 with the round-3 build. Open: H5 (same-version reinstall of stock), and which source the held-step preview plays from (H6 (a)).
- **H6 Step lock (round 4, D15).** **Precondition: GRID RECORDING mode** (press [REC]
  with the sequencer stopped, the trig keys show the steps). Stock only holds trig keys
  for p-locks in GRID REC; outside it a trig key does not hold a step, and no step lock
  happens (the pad hit is the normal round-3 path). CHOP ON for track T, track T
  selected, normal pad mode. Note the chop track's base STA (SAMP page) before you start.
  Each row: once with the sequencer **stopped**, once **playing** (still in GRID REC).
  (a) Hold one trig key of T (an existing trig) and hit pad k: that step gets an STA
  p-lock = marker k (check on the SAMP page while holding the trig); the pad preview
  plays - note which of three it plays from: (1) marker k (expected: stock auditions
  with the held step's lock row, via 0x4024a504, and the lock is written before the
  message reaches stock - INFERRED); (2) the step's previous STA lock; (3) the base STA
  you noted above. Result (3) means the D15a skip costs the audition (round 3 set the
  base to the marker, so its preview played marker k); also setting the base with
  record = 0 is the alternative the r4 skeptics named (r4-sk-padheld P3, r4-sk-heldlock
  P6) - the founder's call. Release the trig key: **the trig is still there** (not
  toggled off).
  (b) Hold several trig keys at once (existing trigs) and hit pad k: each held step gets
  STA = marker k; no other step gets a lock; all trigs still there after release.
  (c) Hold a trig key on an **empty** step and hit pad k: note whether a trig appears
  (stock's press adds one at once) and that the lock is on it; nothing toggles on release.
  (d) Hold a trig, hit pad k, then pad j (still holding): the step's lock ends at marker j.
  (e) **Base STA unchanged:** after any of (a)-(d), with no trig held, the SAMP page's
  STA shows the value you noted (the held-step hits did not move it). Then a plain pad
  hit (no trig held) moves it to that marker, as in round 3.
  (f) **Another track (guard 5) - reachable with the [FX] key** (it selects the FX track
  without a pad press; with T = 0..11 and FX selected, guard 5 must refuse). With CHP ON every pad press,
  TRK + pad included, goes to the chop track, so the pads cannot select another track
  while CHOP stays on, and turning CHP right again re-latches the chop track to the
  selected one (delta_gate); guard 5 is defensive in normal use. Run (f) only if you
  know a way to select a track U (U != T) that is not a pad press, with CHP left ON for
  T: hold a trig of U and hit a pad: **no lock on U or T** at that step (the hit is the
  round-3 path: T's base STA = marker, preview of T). Look also for a stock track switch
  to T (the rewritten pad can schedule one) and, if it happens while the trig key is
  still held, whether the next pad writes locks into T's steps at the held positions
  (r4 skeptic R1, which only arises if such a way exists; stock's knob path does the
  same after a switch). Otherwise record (f) as "not reachable".
  (g) Live REC: trig keys do not hold steps there in stock 1.73, so there is no step lock
  in LIVE REC; a pad hit records as round 3 (trig + STA lock on the playing step).
  (h) **Do not run** (out of scope, D14). Guard 2 (`hold_lock_source(S)` != 0) is
  defensive: the setter of S+440, 0x400364f2, has two callers (0x400cb49a,
  0x400cd24c), INFERRED to be the scene and performance locker views (r4 skeptic HL12;
  other writes of offset 440, at 0x4010ea86, 0x4010ec5a and 0x40116652, are on objects
  not identified). Those are pad modes where the pads do not play their own track, so
  turn CHP OFF there first.
  (i) No crash, no hung voice across all rows; repeat (a) fast 20 times.
  (j) Unknown: whether a MIDI note arriving through UI-loop case 3 while a trig is held
  also writes the lock (r4 skeptic). Avoid external MIDI notes into the Rytm while testing.
  Stop at the first deviation; the round-3 file (no step lock) is the fallback.

Also unknown, low priority: whether external MIDI CC reaches ids 3..5 through PARAM_ROM
+0x18 (their stock values read as CC 6/38, 7, 10; lead F14) - with container index 0 a
stray write would land in the sound's free word 0, which no mod in the CHOP image uses but
0008 reads as its cut settings in the default image; and whether the knob graphic is drawn
for ids 3..5 (RAM param_info(id)+48).

Side note from the STA skeptic, outside this mod: 0000-shared's `PROJ_KIT = 352` and
0008's `SOUND0 = 352+60` disagree with stock 1.73's kit at project + 232 and
kit_track_sound's 0x60 displacement (sk-sta S1). CHOP does not use either. It should be
checked before any 0008 image is flashed.

## Next steps (out of scope for v1, D13)

- A pad press selects the PAD knob on screen (redraw the CHOP page when a pad sets
  chop_pad; today it shows at the next redraw).
- END per slice (next marker, or the track's END).
- More than 12 markers (pages of markers).
- Saving the markers (today RAM only, by design).
- Hi-res marker values (the 8.8 fraction under SAMPLE POS RES = HI).
- Optional: restore the chop track's base STA when CHOP ends (sta lane: param_set_value
  with record 0, notify 1).
