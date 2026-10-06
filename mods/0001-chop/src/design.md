# 0001 CHOP - design

Status: **built** (`make chop`, `make chop-min` and `make control` PASS verify in the
guest VM, 2026-10-05, after the round-3 change D8a below; `make random` and the default
`make` passed earlier the same day and do not contain 0001). **Never run on hardware.**
Local only: this tree has no license and is never pushed or published. Nothing here
flashes a device; the founder flashes.

Line references `dis:N` are lines of
`/Users/creative/analog rytm firmware/build/mainos_1.73_emac.dis` (objdump of
`build/stock_mainos.bin`, base 0x40000400). The RE behind every hook is corp round r2
(`/Users/creative/corp-audits/2026-10-05-rytm-chop/corp/`: `TRUTH.md` decisions D1-D14
and D8a, `r2-re/results.json`, `r2-re/skeptic_fixes.md`). Round 3 (D8a) pairs each pad's
note-off with its note-on; receipts in `corp/fixer-r3/`.

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
2. the chop track's STA is set to marker k with
   `param_set_value(set, 43, marker << 8, T, record = 1, notify = 1)` on
   `set = kit_track_param_set(project_kit(project_singleton()), T)` - the call a STA
   knob turn ends in (dis:213877-213897 `braw 0x400a6316` with flags 1, 1), so under
   live REC stock writes an ordinary STA p-lock on the chop track's current step;
3. the pad id in the UI message is rewritten to the chop track, and the message goes
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
  and marks the kit edited (kit_param_changed). Leaving CHOP does not restore it.
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
the stub is 932 B (0x402a1b30..0x402a1ed3, `make chop` and `make chop-min` logs). Code,
the page list and descriptor, the strings and the 28 B of RAM state all fit there;
nothing goes in cave3 (whose `.tab` neighbour is unexplained, F15). The state sits at the
end, after every entry point (build.py refuses an odd entry); addresses from `m68k-elf-nm`
of the built `obj/0001-chop.elf`, the same in both CHOP images (stub bytes compared):

| label | addr (built) | default |
|---|---|---|
| `chop_on` | 0x402a1eb8 | 0 |
| `chop_track` | 0x402a1eb9 | 0 |
| `chop_pad` | 0x402a1eba | 0 |
| `chop_rsv` | 0x402a1ebb | 0 |
| `chop_marks[12]` | 0x402a1ebc | 0, 10, 20 ... 110 |
| `chop_route[12]` | 0x402a1ec8 | 0xFF x 12 (D8a: no note-on rewritten yet) |

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
  `chop_set_sta(chop_track, chop_marks[k])`, msg+4 := chop_track. Every path then runs
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

## Disassembly check of the built image

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

## Hardware-only unknowns (the founder's test card)

Nothing below can be proven offline. Nothing from this pipeline has run on an MK1 yet.

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
   then run H1-H5 below.
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

Files verified on 2026-10-05 after the round-3 change (guest VM, `make chop`,
`make chop-min`, `make control`, all PASS), sha256:
`AR1_OS1.73_control.syx` 3407638c3f450daba0faedbddc0d4f08b154925a3ba162172346f51ef9ed6a8d,
`AR1_OS1.73_0000_0001_0002_0003.syx` 3ea80d31dba5a6ea3c937d6feb68026907759a68c7557e31373f4d7bd1a2b00b,
`AR1_OS1.73_0000_0001.syx` 3c77f43b566fab6c6b178bae3e515d468fb298d560da083c5f71686e31b31066.
(The round-2 files 5614a93e… and e19703af… are superseded: they do not pair note-offs.)

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
  a pad with CHOP on for track A, select track B and turn CHP ON again, let go - track A
  must not hang;
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
