# 0001 CHOP - design

Status: **built** - Sample Focus image A (`make samplefocus` = 0000-shared + 0001-chop,
tag 0000_0001; `make chop-min` is the same composition) and `make control` PASS verify in
the guest VM, 2026-10-06, after every one of the seven Sample Focus steps below; the
default `make` (0000 0002 0003 0008) and `make random` (0000 0002 0003 0004), which do
not contain 0001, PASS as well. **Nothing added in Sample Focus has run on hardware.**
The round-4 image (`make chop` at commit ee8665e, build a96657b4...caf6: page, pads,
live-REC locks, note-off pairing, step lock) is confirmed working on the founder's MK1
(hardware result 2026-10-06, below). `make chop` (0000 0001 0002 0003) is retired: CHOP
now also claims the part of cave2 that 0002 occupies (see Build).
Local only: this tree has no license and is never pushed or published. Nothing here
flashes a device; the founder flashes.
Commit hashes in this file are those after the 2026-10-06 re-author of branch `chop` to
bandersong (every commit 2fae7ce..chop; trees, messages and dates unchanged). The corp
notes cite the earlier hashes: the map is `corp/r6-integrator/reauthor_map.txt`, and the
old commits stay on branch `chop-pre-reauthor-20261006`.

Line references `dis:N` are lines of
`/Users/creative/analog rytm firmware/build/mainos_1.73_emac.dis` (objdump of
`build/stock_mainos.bin`, base 0x40000400). The RE behind every hook is corp round r2
(`/Users/creative/corp-audits/2026-10-05-rytm-chop/corp/`: `TRUTH.md` decisions D1-D14
and D8a, `r2-re/results.json`, `r2-re/skeptic_fixes.md`). Round 3 (D8a) pairs each pad's
note-off with its note-on; receipts in `corp/fixer-r3/`. Round 4 (D15-D15d) adds the step
lock: trig key(s) held + pad = STA p-lock of that pad's marker on every held step; RE in
`corp/r4-re/results.json` (seats r4-heldlock HL1-HL13 and r4-padheld F1-F10, and their
skeptics' plan problems), build receipts in `corp/r4-builder/`. Round 6 ("Sample Focus",
D17-D23) adds hi-res markers and five knobs; RE in `corp/r5-re`, `corp/r5b-re`,
`corp/r5c-re` (`results.json`, with the skeptics' plan problems), build and proof receipts
in `corp/r6-builder/` (`s1`..`s7`: one folder per step, with the guest logs, the built
.bin/.syx/manifest/ELF and the read-only checks).

## Summary (README text)

**CHOP - Sample Focus (MK1 OS 1.73, image A).** A second page on the SAMPLE view turns
the twelve pads into twelve sample-start markers for one track. On the SAMPLE view,
press SAMPLE, let go, pause, press again: the CHOP page. Turn CHP right and the track
selected at that moment becomes the *chop track*; from then on pad k sets the chop
track's STA to marker k and plays it, as a STA knob turn and a pad hit would - so under
live REC stock records an ordinary trig with an ordinary STA p-lock. Hold trig keys of the
chop track (GRID REC) and hit a pad: each held step gets STA = that marker as a p-lock.
The markers have stock STA's resolution (fine steps under SAMPLE POS RES = HI). END sets
each slice's end too, DIV re-chops the sample into 1..12 equal slices, LAY lays the slices
out on the empty steps of the pattern, RND (turned while holding trigs) gives each held
step a random slice, and STR (EXPERIMENTAL) sets up the track's LFO to sweep STA over 1..64
steps. Everything CHOP keeps is RAM only (a power cycle resets it); what it writes into
patterns and kits (STA/END p-locks, trigs, base STA/END/LFO values) are ordinary stock
values that play on stock firmware. No euclid accents, no velocity humanise, no SMP CUT in
this image.

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
| B `STA` | 4 | 0..120, stock STA's text (`40.` when there is a fraction) | that marker, 8.8 like stock STA (id 43, max 0x7800): HI = fine and accelerated steps, LO = whole steps, FUNC = one whole step (rounded down first), press-and-turn = big steps; the dial draws as stock STA's |
| C `CHP` | 5 | OFF / ON | right: CHOP on, for the track selected at that moment (the *chop track*); left: off (END on: the chop track's END back to 120 first) |
| D `END` | 11 | OFF / ON | right: on - a pad also sets the chop track's END to its slice end (the next marker above its own, else 120), after STA; left: off, and the chop track's END goes back to 120 |
| E `DIV` | 12 | 1..12 | re-chop: marker i = ((i mod DIV) x 120) / DIV for all twelve (pads above DIV repeat the slices); overwrites hand-set markers; turning against an end changes nothing |
| F `LAY` | 13 | `-` | right: lay the slices out - n = min(DIV, pattern length) slices on steps i x length / n; only an EMPTY step gets a trig plus its STA (and END) p-lock; left: nothing |
| G `RND` | 14 | `-` | only while trig key(s) of the chop track are held: each held step gets the STA (and END) p-lock of a random slice 0..DIV-1; each detent re-rolls; otherwise nothing |
| H `STR` | 2 | OFF, 1, 2, 4 ... 64 | EXPERIMENTAL: the chop track's LFO sweeps STA once over that many steps (below); OFF switches the sweep off |

The twelve markers start at 0, 10, 20 ... 110 (DIV 12). Gestures: no new pad gestures -
the pads do what they did in round 4; every new action is a knob on the CHOP page, and the
one "hold trig + turn knob" action (RND) is stock's own grammar.

While CHOP is on, a hit on pad k (k = 0..11):

1. `chop_pad = k` (the PAD knob follows; it is redrawn at the next redraw);
2. **with trig key(s) of the chop track held (D15):** STA = marker k is written as a
   p-lock on every held step (and END = its slice end, with END on and END lockable),
   exactly what stock does when you hold those trigs and turn the STA knob; the base STA
   is left alone, so step 3 below is skipped (see "The step lock"). Otherwise:
3. the chop track's STA is set to marker k with
   `param_set_value(set, 43, marker, T, record = 1, notify = 1)` (marker in 8.8) on
   `set = kit_track_param_set(project_kit(project_singleton()), T)` - the call a STA
   knob turn ends in (dis:213877-213897 `braw 0x400a6316` with flags 1, 1), so under
   live REC stock writes an ordinary STA p-lock on the chop track's current step; with
   END on, the same call for END (id 44) follows, after STA, as stock's own STA/END
   writer orders them (0x4008b840);
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
chop track, the knob values and the flag are RAM only and come back as the image's
defaults at power-on. A recorded chop is an ordinary STA (and END) p-lock and plays back
on stock firmware.

Consequences to know (by design):
- Like a STA knob turn, every pad hit in CHOP also changes the chop track's base STA
  (and END, with END on) and marks the kit edited (kit_param_changed). Leaving CHOP does
  not restore STA. The one exception is a pad hit that wrote held-step locks (D15a): like
  the stock STA knob on held trigs, it leaves the base values and the kit untouched.
- END OFF, CHP OFF (with END on) and CHP re-latching another track (with END on) write
  the chop track's END = 120 (record 0: a base value, never a lock) - also when END had
  never moved it, so a hand-set END on that track is replaced by 120.
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
- **Pad pressure (aftertouch) is not rerouted** (UI-loop case 2 is untouched): leaning
  on a pad in CHOP still drives the pad's own track, while its note plays the chop track.
- LAY and STR edit the pattern and the kit with no undo: LAY's trigs and locks stay until
  you clear them (a later DIV change leaves them as they are), STR overwrites the chop
  track's LFO, END and LOOP base values (reload the kit to get them back).
- **STR acts only while CHOP is on.** CHP OFF does not stop a sweep STR set up, and with
  CHOP off H only changes its number: turn STR OFF before CHP OFF or a re-latch. Keep END
  OFF while you use STR (END on moves END to each slice end and cuts the sweep). Details in
  "STR" below.

## Build

```
make samplefocus  # Sample Focus image A: 0000-shared 0001-chop
                  # -> build/AR1_OS1.73_0000_0001.syx
make chop-min     # the same composition and tag (kept for the bisection habit)
make control      # no mods: stock MAIN OS repacked by our tool
make chop         # RETIRED: prints why and exits 2 (round 4 = commit ee8665e)
```

Each runs `symbols layout` first, then `build.py --mods ... --tag ...`, then
`verify.py --tag ...`. Builds run only in the guest VM. 0001 is `enabled = false`, so the
default `make` is unchanged in composition (0000 0002 0003 0008); it and `make random`
(0000 0002 0003 0004) rebuild and PASS after every Sample Focus step (they change only by
0000-shared's PROJ_KIT fix, 2 bytes, below).

**Why `make chop` is retired.** D22 puts CHOP's new code in cave2, the space 0002 and
0003 leave free in image A. CHOP's second claim, 0x402a2780 + 0x5b8 (section `.cave2`),
is exactly 0002's claim, so `excludes` now lists `0002-euclid-accents` and a build with
both can no longer exist (build.py would refuse at "cave ... is not free"). 0003's claim
is untouched, so 0000 + 0001 + 0003 would still lay out; it is not a target. The round-4
image is reproducible from commit ee8665e (`make chop`, a96657b4...caf6).

**0000-shared PROJ_KIT = 232 (D17).** 0000-shared's `shared_sound_of` used the MKII kit
offset 352; on MK1 1.73 the active kit is project + 232 (project_kit 0x400ab706,
`addil #232`; r5b-offsets O1, skeptic-confirmed). Fixed. CHOP itself never calls it (its sound
writes go through project_kit); in image A it is dead code, and the fix is for image B
(0008 SMP CUT). The built operand is `pea %a0@(232)` (`4868 00e8`) at 0x402a2db4 and
`4868 0160` appears nowhere in the image (python byte search, `corp/r6-builder` step 1 and
final). 0008's own `SOUND0 = 352+60` is NOT fixed here (image B).

verify.py's claim check credits a changed byte to the first registry claim that covers
it, whatever its owner, so its log can name 0008 or 0004 claims for CHOP bytes (it does
for the dial_gate host 0x400a587c, which 0004 also claims). The read-only
`corp/r6-builder/prove.py` matches every changed byte against the claims of the mods in
the build only (0 unclaimed, below).

**The CHOP image has no SMP CUT (0008) and no LFO RND (0004).** CHOP detours the same
four page hosts (0x400f8736, 0x400381a0, 0x400376e4, 0x400a5908), which build.py
refuses to patch twice (its expect check), and takes the same `cave` claim; so
`excludes = ["0002-euclid-accents", "0004-lfo-rnd", "0008-sample-cut"]`. Chaining with
`chain_pos` needs a tools change first (r5b space skeptic S12: layout.py and build.py
refuse a shared host today).

**The id 0001.** It belonged to a retracted MKII mod, `0001-microtiming-fine`, which
`mods/0002-euclid-accents/mod.toml` still lists in `excludes`. `layout.load_excludes`
works on full id strings, so `0001-microtiming-fine` (which does not exist in this tree)
and `0001-chop` never meet. Cosmetic only.

## Placement

Two claims (D22: run-time state stays in `cave`; code goes to `cave2`; nothing in cave3 or
cave4..6):

| claim | section | holds | built size | free |
|---|---|---|---|---|
| `cave` 0x402a1b30 + 0x4d0 | `.text` | the nine gates' hot paths, chop_set_sta, chop_knob, chop_value, clamp, STR's value rows, the page list and descriptor, the knob tables, then the RAM state | 1216 B (0x402a1b30..0x402a1fef) | 16 B |
| `cave2` 0x402a2780 + 0x5b8 (0002's space) | `.cave2` | the step lock (chop_held_lock / chop_held_with, chop_lock_step, chop_lock_one, chop_fn_mgr), chop_put, END, DIV, LAY, RND, STR, dial_gate, the strings | 1461 B (0x402a2780..0x402a2d34) | 3 B |

(Sizes from the `make samplefocus` log, "0001-chop: stub 0x402a1b30 (1216 B)" and
"0x402a2780 (1461 B)"; 0000-shared stays at 0x402a2d38, 234 B.) cave2 is within `bsr.w`
range of cave (0x402a2780 - 0x402a1b30 = 0xc50), and every call between the two is a
16-bit displacement the linker resolved (a miss would fail at link time). cave2 holds code
only. Both pools have hardware evidence: the round-4 image ran CHOP's code and state in
cave, and 0002/0003's code and state in cave2.

The state sits at the end of `.text`, after every entry point (build.py refuses an odd
entry); addresses from `m68k-elf-nm` of the built `obj/0001-chop.elf` (image A):

| label | addr | default |
|---|---|---|
| `chop_on` | 0x402a1fc0 | 0 |
| `chop_track` | 0x402a1fc1 | 0 |
| `chop_pad` | 0x402a1fc2 | 0 |
| `chop_end` | 0x402a1fc3 | 0 (END off; was the spare byte `chop_rsv`) |
| `chop_marks[12]` | 0x402a1fc4 | 8.8 words 0x0000, 0x0a00 ... 0x6e00 (0, 10 ... 110) |
| `chop_route[12]` | 0x402a1fdc | 0xFF x 12 (D8a: no note-on rewritten yet) |
| `chop_div` | 0x402a1fe8 | 12 |
| `chop_str` | 0x402a1fe9 | 0 (STR OFF) |
| `chop_rng` | 0x402a1fec | 0x5eed0001 (RND's LCG word; the same sequence after every power-on) |

(Round 3 had the state at 0x402a1eb8..0x402a1ed3 and round 4 at 0x402a1fdc..0x402a1ff7;
any address below labelled "round 3" or "round 4" refers to that build.)

Nothing is written in the embedded bootstrap [0x4028c708, 0x402a1b24): verify reports it
unchanged, and a python byte compare of the built MAIN OS against
`build/stock_mainos.bin` over that span finds 0 differing bytes (every step, s1..s7).

## Hooks

All expect bytes were re-read from `build/stock_mainos.bin` with python; the registry
entries are in `registry/allocations.toml` under `0001-chop`.

### Detours (9)

| host | expect | entry | rejoin | what |
|---|---|---|---|---|
| 0x400f8736 | 720a202f0004 | page_info_gate | 0x400f873c | page_info answers id 11 with `page_chop`, and gives id 4 STA's encoder step fields (D18) |
| 0x400381a0 | 4feffff448d7040c | get_gate | 0x400381a8 | page_get_value for CHOP's eight ids = the shown value, 8.8 |
| 0x400376e4 | 77832f2a0074 | delta_gate | 0x400376ea | param_apply_delta for CHOP's ids: RAM (and the knobs' own writes), then view_invalidate |
| 0x400a5908 | 242f0020262f0024 | text_gate | 0x400a5910 | param_value_text for CHOP's ids: stock STA's text, OFF / ON, or `-` |
| 0x400ce4b8 | 2f0247f9400706f0 | sample_key_gate | 0x400ce4c0 | the SAMPLE key on the SAMP view (below) |
| 0x400a1ee2 | 48780080767e | pad_on_gate | 0x400a1ee8 | UI-loop case 3, pad note-on (D7) |
| 0x400a1f26 | 487800804eb94008022e | pad_off_gate | 0x400a1f30 | UI-loop case 4, pad note-off, 10 bytes displaced, paired with its note-on (D8, D8a) |
| 0x40038336 | 4fefffd048d70cfc | lock_gate | 0x4003833e | held-trig knob path, slot 0x7c (D10): 0 for CHOP's ids; RND and STR branch here |
| 0x400a587c | 4fefffe848d7047c | dial_gate | 0x400a5884 | param_knob_draw: id 4 draws as id 43 (D18 optional) |

Each stub re-emits exactly the displaced instructions and then `jmp`s the rejoin;
verify.py checks both ("re-emitted", "rejoins"), and `corp/r6-builder/s7/stackcheck.txt`
shows each re-emit path leaves with the stack offset the re-emitted instructions make
(pad gates -4: the `pea 0x80`; get -12, lock -48, dial -24: the prologue's `lea`).

### Patches (42)

- SAMP view page list: count 0x400c7162 `7201` -> `7202`; list 0x400c7168 `401af520`
  ({4}) -> `chop_pages` = {4, 11}.
- PARAM_ROM records 3, 4, 5 and (Sample Focus) 11, 12, 13, 14 and 2 (0x4018e004 +
  52*id), five fields each, as 0008 does for its ids: container index +4 `ffffffff` -> 0;
  max +0xc 0 -> `00007f00`; long name +0x28, group +0x2c, short name +0x30 -> the CHOP
  strings (`Chop Pad`/`Pad Start`/`Chop Mode`/`Slice End`/`Divide`/`Lay Out`/`Shuffle`/
  `Stretch`, `CHOP`, `PAD`/`STA`/`CHP`/`END`/`DIV`/`LAY`/`RND`/`STR`). Record type +0
  stays `ffffffff`, as in 0008: the boot map builder then keeps every one of them out of
  its container-index, CC and NRPN maps (Knob ids, below). Read back from the built image
  with python (`corp/r6-builder/s6/rom_page_check.txt`: knobs A..H = ids 3, 4, 5, 11, 12,
  13, 14, 2 with those names, index 0, max 0x7f00).

The range is 0..0x7f00 for all eight: the encoder handler's step threshold is computed
from the ROM range and gives 0x100 for 0x7f00 as for STA's 0x7800 (r5 encoder enc-4).
PAD, CHP, END, DIV, LAY, RND and STR keep their boot encoder template 0x401ba38c (0x100
per tick: whole steps after `asr #8`); only id 4 gets STA's template (D18, below).

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

(Sample Focus: the marker is an 8.8 word, loaded with `mvzw %a0@(0,%d0:l:2)`; with END
on, `chop_end_hit` follows `chop_set_sta`. Everything else below is unchanged - proof (b)
in "Sample Focus".)

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
kit_track_param_set(kit, T) (0x400a39fa) -> param_set_value(set, 43, V, T, 1, 1)
(0x400a6316, the entry, so any future gate on it still runs). V is the 8.8 marker since
Sample Focus (rounds 2-4 sent the byte marker << 8: the same value for whole markers).
Stock precedent, the same sequence with id 0x29: dis:180147-180167. It runs in the UI task only (the case-3 loop).
It never uses 0000-shared's `shared_sound_of` / `PROJ_KIT = 352`.

### The held-trig path (D10)

The encoder handler calls page-view slot 0x7c (0x40038336) instead of slot 0x58
(param_apply_delta, where delta_gate sits) when 0x40036512(view+108) is non-null or
0x400366a2 is true (dis:75274-75284, 75341-75347): the held-trig / lock-source path,
which would make a stock p-lock. 0008 has no guard there. `lock_gate` at its entry
returns `d0 = 0` for CHOP's ids (3, 4, 5, 11, 12, 13; RND 14 and STR 2 first take
their own branches, which also end in `d0 = 0`) - what slot 0x7c itself returns when slot
0x6c says the id cannot be locked (dis:73011-73018, 73154-73157) - and the only caller ignores d0
(`lea %sp@(12),%sp; braw 0x40039f8e`). Slot 0x7c has no direct jsr; seven vtable words
point at it (base 0x4019a7ac+0x7c and SAMP 0x401b0a84+0x7c among them) and nothing points
into its first 8 bytes past the entry. No stock page lists ids 1..15 (python read of all
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
chop_lock_step}` (round 4; since Sample Focus V is already 8.8 and the functor is 20 B,
see the note at the end of this section); `hold_set_edited(S, 1)` (S+352 = 1: the trig key's release then skips
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
  overwritten in place with V (round 4: V << 8). Any cap in the DataChangeInfo ->
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

**Sample Focus.** The helper is now `chop_held_with(d0 = T, d1 = V, a1 = the invoker)`
with `chop_held_lock` = the same with `chop_lock_step`; the functor is 20 bytes (+16 = E,
the END lock, or -1), and chop_lock_step hands (step, set, V, E) to `chop_lock_one`, which
makes round 4's STA call and, only for E >= 0, the END call after it. RND uses the same
helper with `chop_rnd_step`. Guards and stock call sequence are round 4's (proof (b)).

#### Round-4 proof on the built image (host, read-only objdump / python)

Files in `corp/r4-builder/` (copies of the guest's outputs): `baseline-head/` (HEAD
58ca59b's `make chop` image, rebuilt in the guest: identical to the pre-existing one) and
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

## Disassembly check of the built image (round 3)

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

## Sample Focus (round 6, D17-D23)

Built in seven steps, each built and verified in the guest before the next and committed
on branch `chop` (step 1 f50dd30, 2 ad157ce, 3 d9b0302, 4 449b935, 5 90500f4, 6 5a3e44b,
7 5ecdce6): (1) PROJ_KIT fix + `samplefocus`; (2) hi-res markers; (3) knob ids + END +
DIV; (4) RND; (5) LAY; (6) STR; (7) the optional STA dial. Nothing was dropped: every
step fits (D22's drop order STR, LAY, RND was not needed).

### Knob ids (D19)

Knobs D..H need five dead parameter records. TRUTH named 7, 11, 12, 13, 14; each was
re-proven here (read-only python over `build/stock_mainos.bin`, grep over the stock
disassembly; scripts in `corp/r6-builder`):

- **ROM record.** 11..14 are byte-for-byte the Error class of 3..5 (type, container index
  and +0x1c all ffffffff, min = max = default 0, names Error / "" / ERR); only +0x14, the
  CC words +0x18 and the self-id +0x20 differ.
- **Pages.** No stock page descriptor (pages 0..10, 0x4024c5d4 + 36*p) lists any id from 1
  to 15.
- **RAM record.** The static ctor builds the records of 2, 3, 4, 5, 7, 11, 12, 13, 14 the
  same way: +0 cleared, +4..+0x17 from template 0x401ba38c (d2, written once at
  dis:480429 and not again through id 14), text functor 0x416a6a4c at +24, dial functor
  0x416a684c at +40, +64/+80 cleared (dis:480466-480482 for id 2, 480590-480647 for 11..14;
  `ramrec.py`). Nothing else addresses the RAM table except param_info (its one `addil
  #0x416a6aa4`, dis:322116).
- **No reference.** No instruction operand and no 32-bit word at any byte offset of the
  image points into records 1..14 (`0x4018e038..0x4018e310`; all access is id*52).
- **Maps.** The boot builder 0x40006bb8 (container-index, CC and NRPN maps) skips every
  record whose type is not 0..62 (dis:7311-7406: `cmpl %d2,%d5` with 52, then the 53..55,
  56..59, 60/61/62 tests, else `0x40006d22` = next record), so type-ffffffff ids are in no
  map; the CC-in lookup reads only those maps (r5c sk-stretch). The CC/NRPN getters
  (0x400070ae/d0/f2) are called only from SoundParameterSet methods (MIDI out on
  param_set_value), which CHOP never calls with its own ids.
- **No constant.** None of the 82 direct calls of the 14 PARAM_ROM getters, param_info or
  param_set_value passes 1, 2, 7 or 11..14 as an immediate (`idconst2.py`: the only
  constant ids are 41 and 55). Register-indirect calls and id lists walked at run time
  (e.g. 0x400ac6xx, 0x400ae86x) take ids from variables - the same residual ids 3..5
  have carried on hardware since round 2.

**Id 7 is rejected.** Its record is Error-named, but its CC word is 92 and its +0x1c is
0xe8 = NRPN 1:104 - the MK1 manual's "Active Scene" (appendix C.3), in the kit-common
group whose neighbours are ids 6, 8, 9, 10 (Machine Type, Solo, Mute, Level = NRPN 1:103,
1:102, 1:101, 1:100). It is a live kit parameter's record; patching its container index to
0 could redirect a stock scene path, and nothing here traced those paths. **Knob H uses
id 2** instead: Error class (type/index/+0x1c ffffffff, CC 2/34, +0x14 = 1 like id 3),
proven dead the same way. Id 2 is 0008 SMP CUT's HCT, which is not in image A (0001
excludes 0008); **image B must re-allocate** (CHOP 8 knobs + SMP CUT 2 > the 9 dead ids
1..5, 11..14).

The proof is also recorded in the registry note above the new patches. Assignment: D END
11, E DIV 12, F LAY 13, G RND 14, H STR 2. One dispatcher, `chop_knob` (a 16-byte id ->
knob table; -1 for every other id, and ids above 15 never index it), serves the get,
delta, text and lock gates.

### Hi-res markers (D18, r5 encoder + display plans and their skeptic fixes)

- `chop_marks` = 12 x `.word` 8.8 (0x0000..0x6e00 step 0x0a00); every load is a word
  load with a *2 index (pad_on_gate twice, chop_value, chop_next_above, RND, LAY);
  chop_set_sta and the step lock take V already in 8.8 (no `<< 8`).
- **Encoder fields.** Stock STA is fine because of its RAM template, not a ROM flag: ids
  43/44 boot with {2, 0x800, 8} from 0x401ba300, id 4 with {0x100, 0x800, 0} from
  0x401ba38c (r5 enc-2, enc-10; skeptic P1). page_info_gate, on PAGE_CHOP, copies id 4's
  RAM +4/+8/+0xc (0x416a6c08, the ctor's own address for it) from 0x401ba300 under
  SAMPLE POS RES = HI and from 0x401ba38c under LO (`sample_pos_res` 0x400f3cfc). The
  page view's slot 0x9c calls page_info on every encoder event before the handler reads
  param_info(id)+4..+0xc (dis:75090-75099, 75150-75168; enc-12). It touches d0, a0 and
  those 12 bytes - not a1 (r5 sk-encoder's a1 note).
- **delta_gate STA.** No FUNC: V += the encoder's own 8.8 delta (HI: 2t x max(1,
  |A|/2) with stock STA's acceleration; LO: 0x100 t - bit-for-bit stock except a pushed
  knob with |t| >= 16 in one event, where id 4's 16-bit count truncates and stock's
  43/44 path does not, r5 sk-encoder). FUNC (tested first, so a 0 delta steps up as
  0x400f449a does): V = (V & ~0xff) +- 0x100 and `*ptr = 1` through %sp@(32) when it is
  not null (apply_delta's 0x400a6976), so the encoder re-arms its 6-tick FUNC lockout and
  redraws (skeptic P3). Then clamp 0..0x7800 and, under LO, floor (the writer's order:
  clamp, then `andil #-256`, 0x400a71be).
- **Text.** PAD and STA (and DIV) print through stock STA's own text routine
  `sta_value_text` 0x400f4cbc with the 8.8 value: '%d.' with a fraction, '%d' without -
  exactly stock STA's popup (r5 display D3/D5); `put_u3` is gone. The routine writes the
  terminator (sprintf), so the gate goes straight to the epilogue.
- **Dial (step 7, optional, fits and verified).** `dial_gate` at param_knob_draw's entry
  0x400a587c stores 43 in the id slot for id 4, so the dial uses STA's dial functor
  0x400f8a3a (0..0x7800 rescaled to the full sweep, the 16-step fraction glyph).
  param_knob_draw reads that slot only for param_info and overwrites it before its
  callback (dis:212548-212563). 28 B in cave2.
- Not done (optional, moot): patching id 4's ROM max to 0x7800 (r5 sk-encoder: the 0x700
  quirk it would avoid cannot fire with markers <= 0x7800; its dial effect is UNKNOWN).

### END (D20, r5c features F1 + skeptic P1-P3)

`chop_end` (the old spare byte). Turning D right: on; left: off - directional, so the
number of detents does not matter (P1). With END on:
- a pad hit with no held step: chop_set_sta(T, V), then `chop_end_hit`: END (id 44) =
  `chop_next_above(k)` (the smallest marker strictly above marker k, else 0x7800),
  through `chop_put` = param_set_value(set, 44, E, T, record 1, notify 1): STA first,
  END second, as stock's only STA/END co-writer 0x4008b840 orders them;
- held steps (the step lock): the functor grows to 20 B (+16 = E, or -1), and
  `chop_lock_one` makes the second `set->vt[0x40](set, 44, E, step)` call after STA's -
  only when id 44 is lockable now (param_info(44) & 0x100 == 0, slot 0x6c's test, P3);
- END off / CHP off / CHP re-latching another track: `chop_end_restore` writes the chop
  track's END = 0x7800 with record 0 (a base value, never a lock), so no later STA lands
  above a stale slice end (P2). It acts only while CHOP and END are both on.
With END off, every path makes exactly round 4's stock calls (proof below).

### DIV (D20, F2)

`chop_div` 1..12, default 12. A change re-chops all twelve markers: M[i] = ((i mod DIV) x
0x7800) / DIV (`mulu.w` then `divu.w`; at most 11 x 0x7800 = 0x52800, every quotient below
0x7800). DIV 12 reproduces the power-on markers; 1, 2, 3, 4, 5, 6, 8, 10, 12 are exact in
8.8, 7, 9, 11 floor (under 1/256 of a step). `chop_rechop` does not look at SAMPLE POS
RES, so under LO, DIV 7, 9 and 11 still store fractional markers: the STA knob shows e.g.
`17.` (DIV 7: pad 2's marker M[1] = 0x1124) while the pad plays 17, because the STA/END writer
floors 43/44 under LO (`andil #-256` at 0x400a71be, taken when 0x400f3cfc != 0 and the id
is 43 or 44); the marker turns whole on its next STA turn. Pads above DIV repeat slices 0..DIV-1, so
`chop_next_above` still finds each slice's end. RAM only; it overwrites hand-set markers;
turning against an end (no change) leaves them alone. `divu` cannot trap: DIV is clamped
1..12 and `chop_rechop` returns on 0.

### LAY (D20, F3 + skeptic P4/P5/P10)

Turning F right, `chop_lay` refuses, with no side effect, unless: CHOP on; T = chop_track
<= 11; the selected track is T (`track_index_of(project_selection(project))` - the lock
store writes the selected track's pattern); `tp = current_track_pattern(project)` is not
null; `euclid_enabled_get(tp) != 1` (in euclid mode the grid remaps steps, dis:79239-79252);
STA lockable. Then n = min(DIV, `pattern_length(tp)`), and for i = 0..n-1, s = i x length /
n: if `step_flag_test(tp, s, 1)` is 0 (an EMPTY step - both stock trig tests 0x400bcfa6 /
0x400bd036 read 0 exactly then, and the grid trig key creates only then, dis:79437-79453),
`trig_create(tp, s, 1)` (the trig key's own call) and `chop_lock_one(s, set, M[i], E)`
(E = the slice end with END on and lockable, else none). **A step that holds a trig is
never touched** (D20). Last, `view_refresh_request(view)` (0x40076c4c), as the trig key
after its create. Length 16, DIV 12: steps 0, 1, 2, 4, 5, 6, 8, 9, 10, 12, 13, 14 (0-based).
No undo; a second turn adds nothing to steps it filled. It works in any mode (stock's live
REC also creates trigs outside GRID REC); use GRID REC to see the trig keys.

### RND (D20, F4)

Knob G does nothing on its own (delta path). With trig key(s) held the encoder calls slot
0x7c (lock_gate), which sends id 14 to `chop_rnd_held`: while CHOP is on, the step lock
(`chop_held_with`: the same six guards and stock's hold_set_edited / hold_each_step /
hold_clear_actions sequence) with the invoker `chop_rnd_step`: i = (shared_rnd(&chop_rng,
32767) + 32767) mod DIV (`divu.w`, remainder; bias under 1 in 5000), then
`chop_lock_one(step, set, M[i], E_i)`. Each detent re-rolls every held step. It never
writes a stock p-lock for id 14 and returns 0 like the other CHOP ids. 0001 now requires
the shared runtime (`[requires] shared = true`, `.include "shared.inc"`) for shared_rnd
only; its LCG word is its own (`chop_rng`, fixed seed: the same sequence after every
power-on).

### STR (D21) - EXPERIMENTAL

Knob H: `chop_str` 0 = OFF, 1..7 = 1, 2, 4, 8, 16, 32, 64 steps. A change, and only while
CHOP is on (with CHOP off the value is stored and nothing is written; r5c sk-stretch P6),
writes the chop track's base values through `chop_put` = param_set_value(set_T, id, value,
T, record 0, notify 1) - never a p-lock, never under live REC:

| id | param | value | why |
|---|---|---|---|
| 67 | LFO DST | 0x1500 | STA's container index 21 << 8 (the encoding the UI validates, r5c S3) |
| 68 | WAV | 0x0500 | RMP |
| 70 | MOD | 0x0300 | ONE (one sweep per trig) |
| 69 | SPH | 0 | start of the ramp |
| 66 | FAD | 0x4000 | centre = no fade |
| 64 | SPD | 0x6000 | 32 if the display is raw >> 8 - 64 (INFERRED from the default 0x7000 = 48) |
| 65 | MUL | (7 - idx) << 8 | index 6..0 for 1..64 steps, from the first (assumed synced) half |
| 71 | DEP | 0x7fff | full positive, constant (skeptic P7: never derived from a marker) |
| 44 | END | 0x7800 | the whole sample |
| 45 | LOP | 0 | loop off |

OFF writes DST = 0 (none) and DEP = 0x4000 (zero depth). Every value is inside its ROM
min..max (python, `corp/r6-builder` step 6). **The speed rule is NOT verified on this
firmware**: steps per LFO cycle = 2048 / (SPD x MUL) is the Elektron convention (SPD 32,
MUL 4 = 16 steps); the LFO runs on the DSP side and nothing offline shows its scaling,
the RMP direction, the depth-to-STA scale or which MUL half is tempo-synced (r5c S4, S11).
**No RETRIG is written** (skeptic P5: the flag setter's reset tail can rewrite an empty
step): set retrig on the steps with stock's RETRIG menu, and LFO.T = ON on the TRIG page.
With a trig held, H takes its own branch in lock_gate (`chop_str_held`): the same turn,
base values only, and no stock p-lock for id 2 (P3). STR overwrites the kit's LFO, END
and LOOP for the chop track with no undo. Each change sends up to ten parameter
changes out over MIDI (notify 1). The native, sample-accurate stretch (r5c "B") is not
built.

**Turn STR OFF before CHP OFF and before CHP re-latches another track.** STR writes only
while CHOP is on (`chop_str_turn`: `tst.b chop_on; beq` - the value is stored, nothing is
written; r5c sk-stretch P6), and CHP OFF (delta_gate's CHP-left branch:
`chop_end_restore`, `clr.b chop_on`) and a re-latch never touch the LFO. So after CHP OFF
the old chop track keeps sweeping STA, and turning H - OFF included - only changes the
number shown; after a power cycle H shows OFF whatever the kit holds. To take a sweep off
later: select that track, CHP ON, turn H to OFF (if H already shows OFF: one detent right,
then back - each change writes, the detent right writes the ten sweep values first), or
reload the kit.

**Keep END OFF while you use STR.** With END on, every pad hit writes END = the slice end
after STA (`chop_end_hit`, record 1) and every held-step lock adds an END lock, so the
sweep stops at that slice's end instead of STR's END 120. Turning END OFF while CHOP is
on writes END = 120 back (`chop_end_restore`).

### Space (D22)

cave: 1216 of 1232 B (16 free; the state at its end, 48 B). cave2: 0001 1461 of its 1464
B claim (3 free) + 0000-shared 234 B; 0x402a2e24..0x402a3000 (476 B, 0003's space) stays
free and unclaimed by 0001. cave3: unused. cave4..6: not claimed. Proven by layout + build
+ verify in the guest and by `prove.py` (below). **Image B will not fit as is**: SMP CUT
(about 2 KB with its tables) needs `cave` and cave3, and both images use ids 1..2; image
B needs a re-plan (D22's drop order: STR first).

### Proof on the built image (host, read-only objdump / nm / python; D23)

Image A: `build/mainos_0000_0001.bin` sha256 e9eb0eef...3d76, `AR1_OS1.73_0000_0001.syx`
sha256 734607ae8a213a328a46c474abd2d4b55853172761e753af34e921f41b9d14dc; copies, the ELF,
`nm`, the labelled disassembly (`stub_final.dis`) and every check below are in
`corp/r6-builder/s7/`. The round-4 reference is the hardware image a96657b4...caf6
(`baseline-r4/`, MAIN OS aac51f43...1931; `stub_r4.dis`). `compare.py` decodes one routine
in both images and names every address inside either stub, so relocation is not a
difference (`s7/compare_r4.txt`).

**(a) CHOP off behaves exactly as round 4 (same stock calls).**
- pad_off_gate, sample_key_gate, chop_fn_mgr, clamp: IDENTICAL instruction for
  instruction after naming.
- pad_on_gate: the k > 11 test, the CHOP-off branch (`tstb chop_on` / `moveq #-1` /
  `moveb %d1,%a0@` / `bras`) and the re-emit `pea 0x80; moveq #126,%d3; jmp 0x400a1ee8`
  are unchanged; the only differences are inside the CHOP-on branch.
- get / delta / text / lock gates, any id that is not CHOP's: `chop_knob` (d0/d1/a0
  only; d3, d4, a3 kept) returns -1, then the same displaced instructions and the same
  rejoin as round 4. a0 is the one register round 4 did not clobber there; it is dead at
  every rejoin: get and lock are function entries (scratch by the ABI; stock writes a0 or
  calls before reading it: 0x400381a8.., 0x40038208, 0x4003833e.. 0x4003834a), delta's
  rejoin calls track_index_of then writes a0 at 0x400376f0, text's calls param_info (d0/d1
  only, dis:322109-322117) then writes a0 at 0x400a5922 or returns at 0x400a597e. page_info
  for other pages: unchanged (d0, d1, the rejoin). dial_gate for other ids: `moveq #4,%d0`
  / `cmpl` / `bnes`, the re-emitted `lea %sp@(-24),%sp; moveml %d2-%d6/%a2,%sp@`, `jmp
  0x400a5884` (d0 only, at the function entry).

**(b) Round-4 behaviours, each changed site (the diffs in `s7/compare_r4.txt`):**
- pad path, CHOP on: the two marker loads `moveq #0,%d1; moveb %a0@(0,%d0:l),%d1` became
  `mvzw %a0@(0,%d0:l:2),%d1` (8.8 word), and `bsrw chop_end_hit` follows `bsrw
  chop_set_sta`. chop_end_hit's first instructions are `tstb chop_end; beqs -> rts`, so with
  END off (the power-on state) it calls nothing.
- live-REC lock: chop_set_sta is round 4's minus one instruction, `lsll #8,%d3` (V
  arrives in 8.8): the same `param_set_value(set, 0x2b, V, T, 1, 1)` after
  project_singleton, project_kit, kit_track_param_set. With the power-on markers V =
  0x0a00 x k, the value round 4 sent for marker 10k.
- note-off pairing: pad_off_gate IDENTICAL.
- step lock: chop_held_lock is now `lea chop_lock_step,%a1` falling into chop_held_with,
  whose six guards and stock call sequence are round 4's (same order, same arguments);
  the differences are the frame (28 -> 32 B), the invoker stored at fn+12 at entry instead
  of before the call, `lsll #8,%d3` gone, and fn+16 = E: `moveq #-1,%d3; tstb chop_end;
  beqs` - with END off no extra call. chop_lock_step now hands (step, set, V, E) to
  chop_lock_one, whose first call is round 4's `set->vt[0x40](set, 0x2b, V, step)`; the END
  call is skipped when E < 0 (`bmis`).
- page cycle: sample_key_gate IDENTICAL; page_info_gate's other-page path unchanged; the
  SAMP page list patch unchanged (now pointing at 0x402a1f7a = {4, 11}).
- PAD and CHP knobs: the same logic behind the new dispatcher; CHP left/right gained only
  `bsrw chop_end_restore`, which returns at once unless CHOP and END are both on.

**(c) Every new branch** (`s7/stackcheck.txt`: every path of every code symbol walked, the
stack offset tracked through every push, pop, `lea`/`addq` on %sp; bsr/jsr net 0):
- every `rts` of a routine called by bsr/jsr is at offset 0; delta_gate's and
  text_gate's handled exits pop the host's frame (12 and 20 B) with its own epilogue, as
  round 4; every re-emit path leaves with exactly its re-emitted push/frame; no join
  sees two different offsets; no unmodelled write to %sp.
- callee-saved registers: every routine that writes d2-d7/a2-a6 saves and restores them
  (movem frames: chop_held_with, chop_put, chop_lay, chop_str_apply, chop_set_sta; a push
  at entry and a pop at exit: chop_next_above, chop_rechop, chop_rnd_step,
  chop_str_turn), except where the host's frame owns them and restores them at the rts
  (delta_gate and chop_delta_more: d2/d3 of param_apply_delta; text_gate: d2-d4/a2-a3 of
  param_value_text) or where the register is the re-emitted stock instruction's (a3 in
  sample_key_gate, d3 in pad_on_gate).
- displacements: 204 branches/jumps decoded in the code; every one that lands in the stub
  lands on an instruction start of the code, none in data (`s7/prove.txt`); the
  out-of-range `.s` branches were all caught by the assembler while building (step 2:
  `bra.s` -> `bra.w`).
- guards: T <= 11 before any track write (chop_set_sta, chop_put, chop_held_with,
  chop_lay); k <= 11 (unsigned) before both pad tables; id <= 15 before chop_ktab;
  DIV != 0 before every `divu` (chop_rechop returns, chop_rnd_step uses 12, LAY's n);
  STA lockable before any STA lock (held path, RND, LAY) and END lockable before any END
  lock; CHOP on before LAY, RND and STR write anything; the selected track == T before any
  lock (held path, RND, LAY); euclid off before LAY; clamps on PAD 0..11, STA 0..0x7800,
  DIV 1..12, STR 0..7.

**(d) Regions and space** (`s7/prove.txt`): 2663 bytes differ from stock in 384 runs;
every one lies in a claim of 0000-shared or 0001-chop (0 unclaimed); **0 bytes differ in
[0x4028c708, 0x402a1b24)**, and verify reports "embedded bootstrap image unchanged" and
"null repack" ok; claims: cave 1232 B claimed / 1216 placed, cave2 1700 claimed (0001
1464 + 0000 236) / 1695 placed, cave3 0, cave4..6 none.

## Hardware-only unknowns (the founder's test card)

Nothing below can be proven offline. H1-H6 passed on the founder's MK1 with the round-3
and round-4 builds (the result line under H5). **Everything in H7-H14 is new in image A
and has never run on hardware**; H13 re-runs H1-H6 on image A, because every routine
moved and several changed (proof (b) above).

### Before you flash

1. Back up your projects (Transfer can back up the +Drive).
2. Keep at hand the stock file, `stock/Analog-Rytm_OS1.73.syx` (sha256
   `9115c3888354bb388f90410e0445cd312bf020593ed99f768a99e475d1d6157c`, stock/SHA256SUMS),
   and a DIN MIDI interface: the recovery route is DIN only.
3. Check each file's sha256 against the list below before you send it.
4. Keep the round-4 file (a96657b4...caf6) as the known-good fallback: it is the image
   H1-H6 passed on. It is `flash/2b_CHOP+STEPLOCK_AR1_OS1.73_0000_0001_0002_0003.syx` in
   your flash folder (`/Users/creative/analog rytm firmware/flash/`, listed in its
   SHA256SUMS); a second copy is
   `corp/r6-builder/baseline-r4/AR1_OS1.73_0000_0001_0002_0003.syx`. It is **not**
   `build/AR1_OS1.73_0000_0001_0002_0003.syx`: that name in `build/` was a Sample Focus
   step-1 rebuild (sha256 4847571b...271f, 0000-shared's PROJ_KIT 232; not in the flash
   folder and not tested on hardware), now
   moved to `build/aside-20261006-step1-rebuild/`, and `make chop` is retired, so nothing
   writes that name again.

### Flash order

Normal route each time (docs/FLASHING.md): USB connected, power on; Transfer >
CONNECTION: MIDI IN and OUT = the Analog Rytm; Transfer > DROP: drag the `.syx` on;
press `[YES]` on the device. The unit restarts by itself. **Do not power off during
the first boot afterwards** (docs/HAZARDS.md: the MK1's bootstrap upgrade runs from
inside MAIN OS). The embedded bootstrap [0x4028c708, 0x402a1b24) is byte-identical to
stock in every file below (verify "embedded bootstrap image unchanged", and a python
byte compare: 0 differing bytes).

1. **Control first (optional now):** `build/AR1_OS1.73_control.syx` - stock code, only
   repacked by our tool (`make control`: PASS, 0 differing regions; unchanged since
   round 2). It already proved the packer on this unit before round 3.
2. **Sample Focus image A:** `build/AR1_OS1.73_0000_0001.syx` (`make samplefocus`: CHOP
   with 0000 shared only - no euclid accents, no velocity humanise, no SMP CUT). Check it
   boots and plays, run H13 (the round-4 regression) first, then H7-H12 and H14.
3. If image A misbehaves in H13: go back to the round-4 file,
   `flash/2b_CHOP+STEPLOCK_AR1_OS1.73_0000_0001_0002_0003.syx` (a96657b4...caf6; Before you
   flash, item 4), and report which row failed.

If Transfer refuses a file as the same version, nothing has been written: either stop, or
send that file through the recovery route below (FUNC at power-on, TRIG 4, LEGACY OS
UPGRADE over DIN).

**Never flash the upstream SMP CUT (`..._0008.syx`) or RANDOM (`..._0004.syx`) builds** from
this tree. 0000-shared's PROJ_KIT is fixed (232) as of Sample Focus step 1, but 0008's own
`SOUND0 = 352+60` is not (image B), and neither image has run on an MK1.

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
- Nothing CHOP keeps is saved: power-cycling ends CHOP and resets the markers and the
  knobs. What CHOP wrote into patterns and kits (STA/END p-locks, LAY's trigs, base
  STA/END/LFO values) is ordinary stock data and stays (stock plays it).

Files verified on 2026-10-06 after Sample Focus step 7 (guest VM, `make samplefocus`,
`make chop-min`, `make control`, `make verify`, `make random`, all PASS; rebuilt again
by the r6 integrator after its text-only corrections, the same bytes, logs in
`corp/r6-integrator/build/`), sha256:
`AR1_OS1.73_control.syx` 3407638c3f450daba0faedbddc0d4f08b154925a3ba162172346f51ef9ed6a8d,
`AR1_OS1.73_0000_0001.syx` (image A) 734607ae8a213a328a46c474abd2d4b55853172761e753af34e921f41b9d14dc
(MAIN OS e9eb0eef5843a803c39da7fe7019d1af9e1c28a1f2832aa61c8398534a333d76).
Round 4 (fallback, commit ee8665e, built as `AR1_OS1.73_0000_0001_0002_0003.syx`):
`flash/2b_CHOP+STEPLOCK_AR1_OS1.73_0000_0001_0002_0003.syx`
a96657b49e70b42fc20b9d744a0f10ceceb0f065c0aac7201be88866ac15caf6. (Not the step-1
rebuild 4847571b92a036ca03cb50adcef3c200180b59dc4da4d7ee53bc755bc829271f, now in
`build/aside-20261006-step1-rebuild/`: not tested on hardware. The round-4
`AR1_OS1.73_0000_0001.syx` 86c543c9... is superseded by image A under the same name; the
round-3 files 3ea80d31... and 3c77f43b... have no step lock; the round-2 files 5614a93e...
and e19703af... do not pair note-offs.)

### The unknowns (test in the normal pad mode, D14)

- **H1** Does a pad hit play from the new STA on that same hit? (Voice latch timing: the
  audio target word 0x80005116 + 0x54*T is written synchronously, but whether the voice
  latches STA from it or from the smoothed PARAMS_EFF is unknown. The 1.72 host prototype,
  CC 28 then note, says yes for that path.)
- **H2** Under live REC, does the STA p-lock land on the same step as the pad's recorded
  trig (quantize, late hits)? The lock goes on 0x40035208's current step for the track.
- **H3** Does the CHOP page draw and cycle correctly: SAMPLE -> SAMP; press, let go,
  pause, SAMPLE again -> CHOP; again (after a pause) -> SAMP; the eight knob labels,
  A..H: PAD STA CHP END DIV LAY RND STR; each knob's popup with its name (Chop Pad, Pad
  Start, Chop Mode, Slice End, Divide, Lay Out, Shuffle, Stretch; group CHOP) and value;
  a long hold of SAMPLE behaves as stock. (Needs the SAMPLE release
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
  untraced for CHOP's ids (2..5, 11..14).
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
- **H7 Hi-res markers (D18).** Global setting SAMPLE POS RES = HI first. On the CHOP page:
  (a) turn STA slowly: fine steps, the popup shows `40.` when there is a fraction and
  `40` without, as the SAMP page's STA does; turn it fast: it accelerates like stock STA;
  press and turn: big steps. Compare side by side with the SAMP page's STA knob.
  (b) FUNC + turn STA: one whole step per detent (a fractional marker first rounds down),
  at stock's pace (the FUNC lockout).
  (c) SAMPLE POS RES = LO: whole steps; a marker with a fraction floors on its next turn.
  (d) the STA dial (step 7): the needle reaches the end at 120 and the fraction glyph
  moves with fine turns, as on the SAMP page. UNKNOWN (r5 sk-display P7): the label row
  and the dial-vs-bitmap choice read id 4's own RAM flags (bits 18/19), not id 43's - note
  anything that looks different from the SAMP page's STA.
  (e) set a marker to a fractional value, CHOP on, hit its pad: the SAMP page's STA shows
  the same value (`40.`); the pad plays from it (H1).
  (f) live REC / step lock with a fractional marker: the recorded STA lock shows the
  fraction too (INFERRED from id 43's ROM +0x14 = 1, r5 sk-encoder enc-2; UNKNOWN).
- **H8 END (D20).** CHOP on for T, END right (ON):
  (a) hit pad k: the SAMP page shows STA = marker k and END = the next marker above it
  (pad 1 with DIV 12: STA 0, END 10; the top marker: END 120);
  (b) END left (OFF): T's END = 120; turn END ON again, hit a pad, then CHP OFF: T's END =
  120. The re-latch case (CHP turned right while CHOP is on and another sound track U is
  selected: T's END = 120, U becomes the chop track) needs a way to select U that is not
  a pad press - as in H6 (f), record it as not reachable if there is none ([FX] selects
  the FX track, which CHP never latches and which restores nothing);
  (c) live REC: one pad hit records a trig with an STA lock AND an END lock - check both
  land on the same step (two calls; UNKNOWN if the sequencer can step in between);
  (d) **GRID REC precondition** (trig keys hold steps only there): hold trig(s) of T and
  hit pad k: each held step gets STA = marker k and END = its slice end; base STA/END
  unchanged;
  (e) a marker at 120 with END on, or (LO) two markers less than 1.0 apart: STA = END, a
  zero-length slice - note what it sounds like (UNKNOWN);
  (f) END on while a voice already sounds: does a retrigger click (STA new / END old
  for an instant; UNKNOWN).
- **H9 DIV (D20).** SAMPLE POS RES = HI. Turn E: DIV 4 -> PAD 1..4 read STA 0, 30, 60, 90
  and pads 5..8 repeat them; DIV 12 -> 0, 10 ... 110 again (any hand-set marker is
  overwritten); DIV 7 -> markers with fractions (`17.`, `34.` ...). At 1 or 12, turning
  further changes nothing. With END on, each pad's END is its slice end (DIV 4: pad 1 END
  30). Then SAMPLE POS RES = LO, DIV 7 (turn E away and back to 7 to re-chop): PAD 2's
  STA knob still shows `17.` while pad 2 plays 17 (the SAMP page's STA reads 17; the
  writer floors under LO, see DIV above) - expected, not a fault; one STA turn makes the
  marker whole.
- **H10 LAY (D20).** Preconditions: CHOP ON for T, **T selected**, euclid OFF on T, STA
  not locked out; use **GRID REC** to see the trig keys (LAY itself works in any mode).
  (a) empty pattern of length 16, DIV 12, turn F right once: trigs on steps 1, 2, 3, 5, 6,
  7, 9, 10, 11, 13, 14, 15 (1-based), each with an STA lock = slice 0..11 in order (with
  END on, an END lock too); the trig keys show them (do they light at once, or only after
  a redraw? the refresh is stock's trig-key call, UNKNOWN);
  (b) put your own trig on step 1 first, then LAY: step 1 keeps its own trig and gets no
  lock; the other steps as in (a);
  (c) turn F right again: nothing changes; turn F left: nothing;
  (d) euclid ON for T: LAY does nothing; another track selected: nothing;
  (e) length 64 / DIV 12: steps 1, 6, 11, 17, 22, 27, 33, 38, 43, 49, 54, 59; length 8 /
  DIV 12: all eight steps get slices 0..7;
  (f) change DIV after a LAY: the earlier trigs and locks stay (stale, by design);
  (g) while the sequencer plays: no crash, the new trigs play;
  (h) the pattern's lock capacity: LAY can add up to 24 locks (12 STA + 12 END); is there
  a cap (UNKNOWN, as for stock's knob locks)?
- **H11 RND (D20).** Precondition: **GRID REC**, CHOP ON for T, T selected. Hold one or
  more trig keys of T and turn G: each held step gets the STA lock of a random slice
  0..DIV-1 (with END on, its END too); each detent re-rolls; the trigs are not toggled on
  release; no other step changes. Without a held trig, G does nothing; with CHOP OFF,
  nothing. After a power cycle the same sequence of random slices comes back (fixed
  seed). It never writes a lock for the RND knob itself.
- **H12 STR - EXPERIMENTAL (D21).** Preconditions: CHOP ON for T; **END OFF (knob D
  left)** - with END on each pad hit sets END to the slice end and cuts the sweep; set
  RETRIG on the steps you want stretched with stock's RETRIG menu (CHOP writes no retrig);
  TRIG page LFO.T = ON on those trigs. Turn H to 16: T's LFO page reads DST STA, WAV RMP, MOD ONE, SPH 0,
  FAD 0, SPD 32 (?), MUL 4 (?), DEP max; SAMP: END 120, LOP OFF. Then:
  (a) does each retrig restart the LFO (if it does, the sweep collapses - the trick
  fails)?
  (b) is one sweep 16 steps long at 16, 1 step at 1, 64 at 64 (the unverified rule
  2048 / (SPD x MUL); which MUL half is tempo-synced is UNKNOWN)?
  (c) does RMP sweep STA up or down? (d) how far does STA move at DEP max? (e) is the SPD
  display 32 (raw >> 8 - 64)?
  (f) STR with CHOP OFF, in this order: H at 16, CHP left (OFF): T's LFO page still
  reads the sweep (CHP OFF does not stop it); turn H, to OFF included: only the number
  changes, T's LFO page is unchanged and the sweep goes on. Then select T, CHP ON, and
  turn H to OFF (from OFF: one detent right, then back): DST none, DEP 0. **So turn STR
  OFF before CHP OFF and before a re-latch;**
  (g) hold a trig and turn H: the same base writes, no p-lock for STR;
  (h) LFO.T OFF: no sweep; (i) the click level of 1/64 retrigs with stock AMP;
  (j) turning H while the sequencer plays: no crash; each change sends parameter
  changes on MIDI out (notify 1); (k) H to OFF (CHOP ON): DST none, DEP 0 - the sample
  plays unmodulated again; (l) END ON with H at 16, then hit a pad: END = that pad's slice
  end (the sweep stops there); END OFF: END = 120 again. STR overwrites T's LFO/END/LOOP:
  reload the kit to restore them.
- **H13 Round-4 regression on image A.** Run H1, H3, H4 and H6 (a)-(e), (g), (i) again
  with END OFF, DIV 12, STR OFF (the power-on state): every result as with the round-4
  image. Then H4 (b)/(c) and H6 (a)/(b) once more with END ON (END follows each pad and
  each held step) and once with a fractional marker (H7).
  Stop at the first deviation; the round-4 file is the fallback.
- **H14 Knobs A..F with a trig held (D19, lock_gate).** Precondition: **GRID REC**, CHOP
  ON for T, T selected, the CHOP page shown. Note the values of PAD, STA, CHP, END, DIV and
  the held step's STA/END (SAMP page while holding). Hold one trig key of T and turn each
  of A..F a few detents both ways: nothing changes - the knob values stay, CHP stays ON,
  END and DIV stay, LAY adds no trig, no STA/END p-lock appears on the held step, and no
  other step changes (with a trig held the encoder calls lock_gate instead of the delta
  path, and lock_gate returns 0 for ids 3, 4, 5, 11, 12, 13). Release the trig key and
  note what it does (stock after a hold with no edit). Repeat once with CHOP OFF: the
  same. G (RND) and H (STR) with a trig held are H11 and H12 (g).

Also unknown, low priority: whether external MIDI CC reaches CHOP's ids through PARAM_ROM
+0x18 (ids 3..5: CC 6/38, 7, 10; 11..14: CC 99/98, 120, 121, 123; 2: CC 2/34; lead F14) -
the boot maps skip them (type ffffffff), but another MIDI-in path is not excluded; with
container index 0 a stray write would land in the sound's free word 0, which nothing in
image A uses but 0008 reads as its cut settings in image B. FUNC + SAMPLE (page copy /
paste / clear) on the CHOP page is untraced (H3 (f)).

## Next steps (out of scope for image A)

- Image B (0000 + 0001 + 0008 SMP CUT): re-allocate the knob ids (both mods use id 2;
  ids 1..5 and 11..14 are the dead records), re-plan space (CHOP fills cave and its cave2
  claim; SMP CUT needs about 2 KB plus cave3), fix 0008's `SOUND0` (232+96), and give the
  shared page hosts a chaining tool (r5b skeptics). D22's drop order there: STR first.
- A pad press selects the PAD knob on screen (redraw the CHOP page when a pad sets
  chop_pad; today it shows at the next redraw).
- More than 12 markers (pages of markers); saving the markers (RAM only by design).
- STR: once H12 settles the speed rule, the depth scale and the RMP direction, fix SPD /
  MUL / DEP from the measurements; a native, sample-accurate stretch (r5c "B") stays
  research (the retrig re-fire site and its context are INFERRED).
- Optional: restore the chop track's base STA when CHOP ends (sta lane: param_set_value
  with record 0, notify 1).
