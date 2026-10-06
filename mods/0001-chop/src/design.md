# 0001 CHOP - design

Status: **built** - Sample Focus image A' (`make samplefocus` = 0000-shared + 0001-chop,
tag 0000_0001; `make chop-min` is the same composition) = image A minus STR (corp round 7,
D24: STR did not sweep on the founder's MK1, so knob H is blank and id 2 is 0008's again)
and, since D29, minus the STA dial graphic. **Image B is built** (corp round 7, D25-D29):
`make samplefocus-cut` = 0000-shared (lean) + 0001-chop + 0008-sample-cut SMP CUT, tag
0000_0001_0008 ("Image B" below). It fits by behaviour-identical compaction only (D29
option 4): no feature removed, nothing in cave4..6, state only in `cave`.
`make samplefocus`, `samplefocus-cut`, `chop-min`, `control`, the default `make verify`
(0000 0002 0003 0008), `make random`, `make guard-check` and `make elemod` PASS in the
guest VM, 2026-10-06 (corp `r7b-builder/b5`). **On hardware:** the founder ran image A
and reported only on STR (its writes landed, no sweep: TRUTH round 7); no result for any
other Sample Focus row (H7-H11, H13, H14) is recorded, and neither image A' nor image B
has run. **No 0008 (SMP CUT) code has ever run on an MK1.** The round-4 image (`make chop` at commit ee8665e,
build a96657b4...caf6: page, pads, live-REC locks, note-off pairing, step lock) is
confirmed working on the founder's MK1 (hardware result 2026-10-06, below). `make chop`
(0000 0001 0002 0003) is retired: CHOP now also claims the part of cave2 that 0002
occupies (see Build).
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
.bin/.syx/manifest/ELF and the read-only checks). Round 7 (D24-D28: STR out, image B)
receipts are in `corp/r7-builder/` (`s1`..`s3` per step, `trial/` for the image B fit,
`baseline-imageA/` a copy of image A's build outputs) and, for D29 (the compaction and
image B's layout), in `corp/r7b-builder/` (`a2/`: step 5; `b3/`, `b5/`: step 6, with the
built images, ELFs, the compares, the stack walk and the checks on image B).

## Summary (README text)

**CHOP - Sample Focus (MK1 OS 1.73, image A').** A second page on the SAMPLE view turns
the twelve pads into twelve sample-start markers for one track. On the SAMPLE view,
press SAMPLE, let go, pause, press again: the CHOP page. Turn CHP right and the track
selected at that moment becomes the *chop track*; from then on pad k sets the chop
track's STA to marker k and plays it, as a STA knob turn and a pad hit would - so under
live REC stock records an ordinary trig with an ordinary STA p-lock. Hold trig keys of the
chop track (GRID REC) and hit a pad: each held step gets STA = that marker as a p-lock.
The markers have stock STA's resolution (fine steps under SAMPLE POS RES = HI). END sets
each slice's end too, DIV re-chops the sample into 1..12 equal slices, LAY lays the slices
out on the empty steps of the pattern, and RND (turned while holding trigs) gives each held
step a random slice. Everything CHOP keeps is RAM only (a power cycle resets it); what it
writes into patterns and kits (STA/END p-locks, trigs, base STA/END values) are ordinary
stock values that play on stock firmware. No euclid accents, no velocity humanise and no
SMP CUT in image A'; image B adds SMP CUT (a second FILTER page with a low and a high cut
per track, 0008). (Image A also had STR, an LFO stretch macro; it was removed in round 7.)

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
| B `STA` | 4 | 0..120, stock STA's text (`40.` when there is a fraction) | that marker, 8.8 like stock STA (id 43, max 0x7800): HI = fine and accelerated steps, LO = whole steps, FUNC = one whole step (rounded down first), press-and-turn = big steps; the dial is id 4's own (image A drew it as stock STA's; removed in round 7, D29) |
| C `CHP` | 5 | OFF / ON | right: CHOP on, for the track selected at that moment (the *chop track*); left: off (END on: the chop track's END back to 120 first) |
| D `END` | 11 | OFF / ON | right: on - a pad also sets the chop track's END to its slice end (the next marker above its own, else 120), after STA; left: off, and the chop track's END goes back to 120 |
| E `DIV` | 12 | 1..12 | re-chop: marker i = ((i mod DIV) x 120) / DIV for all twelve (pads above DIV repeat the slices); overwrites hand-set markers; turning against an end changes nothing |
| F `LAY` | 13 | `-` | right: lay the slices out - n = min(DIV, pattern length) slices on steps i x length / n; only an EMPTY step gets a trig plus its STA (and END) p-lock; left: nothing |
| G `RND` | 14 | `-` | only while trig key(s) of the chop track are held: each held step gets the STA (and END) p-lock of a random slice 0..DIV-1; each detent re-rolls; otherwise nothing |
| H | - | (blank) | nothing: image A's STR (id 2) was removed in round 7 (D24); the descriptor slot is 0, an empty knob as on stock pages |

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
- LAY edits the pattern with no undo: its trigs and locks stay until you clear them (a
  later DIV change leaves them as they are).
- If you ran image A's STR: the LFO, END and LOOP values it wrote into a kit stay in that
  kit (ordinary stock values); image A' never touches the LFO. Reload or edit the kit.

## Build

```
make samplefocus      # Sample Focus image A' (A minus STR): 0000-shared 0001-chop
                      # -> build/AR1_OS1.73_0000_0001.syx
make samplefocus-cut  # Sample Focus image B: 0000-shared (lean = 1) 0001-chop
                      # (shared_lean = 1) 0008-sample-cut (own_pages = 0)
                      # -> build/AR1_OS1.73_0000_0001_0008.syx
make chop-min         # the same composition and tag as samplefocus (bisection habit)
make control          # no mods: stock MAIN OS repacked by our tool
make guard-check      # proves build.py refuses 0008 with own_pages=0 and no 0001-chop,
                      # 0008 without 0000-shared, and 0001 shared_lean=1 with a full
                      # 0000-shared (round 7)
make chop             # RETIRED: prints why and exits 2 (round 4 = commit ee8665e)
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
it, whatever its owner or gate, so its log can name 0008 or 0004 claims for CHOP bytes.
The read-only `corp/r6-builder/prove.py` (image A) and `corp/r7b-builder/tools/check_b.py`
(image A' and image B since D29) match every changed byte against what the build itself
applied - each mod's written blocks, detours and patches from its manifest - and each
written block against an active claim of an enabled mod (gate evaluated with the build's
params): 0 unclaimed in both (below).

**CHOP and SMP CUT (0008) share image B; CHOP and LFO RND (0004) never share an image.**
CHOP detours the same four page hosts as 0004 (0x400f8736, 0x400381a0, 0x400376e4,
0x400a5908), which build.py refuses to patch twice (its expect check). Round 7 did not
chain the hosts (`chain_pos` is still not implemented, r5b space skeptic S12); it made
0001 the single owner of them, with 0008 as a provider of its handlers ("Image B"
below). Since D29 `excludes = ["0002-euclid-accents", "0003-velocity-humanise",
"0004-lfo-rnd"]`: 0008 is no longer excluded, so layout.py checks every 0001 claim,
detour and patch against 0008's (r5b space skeptic: excludes hide overlaps) - in the
standalone `make layout` (default params: 0008's image-B claims) and in every build;
0003 is excluded because CHOP's `.cave2` claim is 0003's part of cave2.

**Two params tie image B's layout together (D29).** `0000-shared:lean = 1` assembles only
`shared_rnd`, `shared_sound_of` and `shared_mark_changed(_set)` (140 B, the same
instructions as the full build) in a lean claim at the end of 0000-shared's slot
(0x402a2d98 + 0x8c); `0001-chop:shared_lean = 1` gives CHOP's `.text` the other claim of
the pair, 0x402a2780 + 0x618, which runs on into the slot's head. Both default to 0
(image A', and every other build, is unchanged by them). With shared_lean = 1 and a full
0000-shared the two claims overlap and the build is refused (`make guard-check`, third
case); with lean = 1 and shared_lean = 0 the head is simply unused. `tools/mkelemod.py`
now skips a claim, detour or patch whose gate leaves it out of the build it exports from
(0008's gated image-B claims overlap its own_pages = 1 claims, 0000-shared's lean claim
its full one); its output for every mod is identical to the old tooling's on the same
builds (corp `r7b-builder/b3/elemod_compare.txt`: the HEAD-before-D29 tools and registry
run on the same verify/random images in the guest, a JSON compare with the commit field
aside; `b3/elemod.log` is the `make elemod` run).

**The id 0001.** It belonged to a retracted MKII mod, `0001-microtiming-fine`, which
`mods/0002-euclid-accents/mod.toml` still lists in `excludes`. `layout.load_excludes`
works on full id strings, so `0001-microtiming-fine` (which does not exist in this tree)
and `0001-chop` never meet. Cosmetic only.

## Placement

Since D29 (step 6, commit dd84b6c) image A' and image B use **one layout**, four claims
(registry `0001-chop`; D27: run-time state only in `cave`; nothing in cave4..6):

| claim | section | holds | A' | B |
|---|---|---|---|---|
| `cave` 0x402a1edc + 0x124 | `.chst` | pad_on_gate, pad_off_gate, chop_value, then the 48 B of RAM state (read pc-relative by the code beside it) | 280 B | 280 B |
| `cave2` 0x402a2780 + 0x5b8 (shared_lean = 0) / + 0x618 (shared_lean = 1) | `.text` | page_info / get / delta / text gates, sample_key_gate, lock_gate, chop_set_sta, chop_knob, clamp, the knob tables, chop_put, chop_set_of, chop_locked, chop_next_above, the END helpers, chop_delta_more, chop_rechop, chop_lay, the long knob names | 1448 of 1464 B | 1500 of 1560 B |
| `cave2` 0x402a2e24 + 0x1dc (0003's space) | `.cave2` | the step lock (chop_held_lock / chop_held_with, chop_lock_step, chop_lock_one, chop_fn_mgr), chop_rnd_held, chop_rnd_step | 434 B | 434 B |
| `cave3` 0x4024deb8 + 0x54 | `.cave3` | constants only: chop_pages, page_chop, "CHOP" and the short knob names | 77 B | 77 B |

(Sizes from the step-6 build logs, "0001-chop: stub 0x402a2780 (1448 B)" for A' and
"(1500 B)" for B; image B's `.text` carries the 52 B of dispatch to 0008. Before round 7
A' was `.text` 1128 B in `cave` (0x402a1b30) + `.cave2` 1305 B in cave2.) In image A' the
0x402a1b30..0x402a1edc part of `cave` and 0x4024db0c..0x4024deb8 of cave3 are left unused
- they are 0008's image-B claims, which a standalone `make layout` checks against CHOP's.
cave and cave2 are within `bsr.w` range of each other (0x402a2780 - 0x402a1edc = 0x8a4),
and every call between them is a 16-bit displacement the linker resolved (a miss fails at
link time); nothing branches to or from cave3. Both cave and cave2 have hardware
evidence: the round-4 image ran CHOP's code and state in cave, and 0002/0003's code in
cave2. 0000-shared stays at 0x402a2d38 (234 B) in image A'; in image B it is the lean
140 B at 0x402a2d98.

The state sits at the end of `.chst`, after every entry point (build.py refuses an odd
entry); addresses from `m68k-elf-nm` of the built `obj/0001-chop.elf` (image A' and
image B: the same):

| label | addr | default |
|---|---|---|
| `chop_on` | 0x402a1fc4 | 0 |
| `chop_track` | 0x402a1fc5 | 0 |
| `chop_pad` | 0x402a1fc6 | 0 |
| `chop_end` | 0x402a1fc7 | 0 (END off; was the spare byte `chop_rsv`) |
| `chop_marks[12]` | 0x402a1fc8 | 8.8 words 0x0000, 0x0a00 ... 0x6e00 (0, 10 ... 110) |
| `chop_route[12]` | 0x402a1fe0 | 0xFF x 12 (D8a: no note-on rewritten yet) |
| `chop_div` | 0x402a1fec | 12 |
| `chop_rng` | 0x402a1ff0 | 0x5eed0001 (RND's LCG word; the same sequence after every power-on) |

(Round 3 had the state at 0x402a1eb8..0x402a1ed3, round 4 at 0x402a1fdc..0x402a1ff7,
image A at 0x402a1fc0..0x402a1fef (with `chop_str`) and image A' before D29 at
0x402a1f68..0x402a1f97; any address below labelled "round 3", "round 4" or "image A"
refers to that build.)

Nothing is written in the embedded bootstrap [0x4028c708, 0x402a1b24): verify reports it
unchanged, and a python byte compare of the built MAIN OS against
`build/stock_mainos.bin` over that span finds 0 differing bytes (every step, s1..s7).

## Hooks

All expect bytes were re-read from `build/stock_mainos.bin` with python; the registry
entries are in `registry/allocations.toml` under `0001-chop`.

### Detours (8; image A had 9 - dial_gate was removed in round 7, D29)

| host | expect | entry | rejoin | what |
|---|---|---|---|---|
| 0x400f8736 | 720a202f0004 | page_info_gate | 0x400f873c | page_info answers id 11 with `page_chop`, and gives id 4 STA's encoder step fields (D18) |
| 0x400381a0 | 4feffff448d7040c | get_gate | 0x400381a8 | page_get_value for CHOP's eight ids = the shown value, 8.8 |
| 0x400376e4 | 77832f2a0074 | delta_gate | 0x400376ea | param_apply_delta for CHOP's ids: RAM (and the knobs' own writes), then view_invalidate |
| 0x400a5908 | 242f0020262f0024 | text_gate | 0x400a5910 | param_value_text for CHOP's ids: stock STA's text, OFF / ON, or `-` |
| 0x400ce4b8 | 2f0247f9400706f0 | sample_key_gate | 0x400ce4c0 | the SAMPLE key on the SAMP view (below) |
| 0x400a1ee2 | 48780080767e | pad_on_gate | 0x400a1ee8 | UI-loop case 3, pad note-on (D7) |
| 0x400a1f26 | 487800804eb94008022e | pad_off_gate | 0x400a1f30 | UI-loop case 4, pad note-off, 10 bytes displaced, paired with its note-on (D8, D8a) |
| 0x40038336 | 4fefffd048d70cfc | lock_gate | 0x4003833e | held-trig knob path, slot 0x7c (D10): 0 for CHOP's ids (and, in image B, 0008's ids 1..2); RND branches here |

(0x400a587c, param_knob_draw, carried image A's dial_gate - id 4's dial drawn as id 43's.
Removed in round 7 to fit image B (D29); the host reads stock `4fefffe848d7047c` in every
0001 build since, python read of the built images.)

Each stub re-emits exactly the displaced instructions and then `jmp`s the rejoin;
verify.py checks both ("re-emitted", "rejoins"), and the stack walks
(`corp/r6-builder/s7/stackcheck.txt`; since D29 `corp/r7b-builder/b3/stackcheck_A.txt`
and `stackcheck_B.txt`) show each re-emit path leaves with the stack offset the
re-emitted instructions make (pad gates -4: the `pea 0x80`; get -12, lock -48: the
prologue's `lea`; delta -4: the re-emitted `movel %a2@(116),%sp@-`).

### Patches (37)

- SAMP view page list: count 0x400c7162 `7201` -> `7202`; list 0x400c7168 `401af520`
  ({4}) -> `chop_pages` = {4, 11}.
- PARAM_ROM records 3, 4, 5 and (Sample Focus) 11, 12, 13, 14 (0x4018e004 + 52*id), five
  fields each, as 0008 does for its ids: container index +4 `ffffffff` -> 0; max +0xc 0
  -> `00007f00`; long name +0x28, group +0x2c, short name +0x30 -> the CHOP strings (`Chop
  Pad`/`Pad Start`/`Chop Mode`/`Slice End`/`Divide`/`Lay Out`/`Shuffle`, `CHOP`,
  `PAD`/`STA`/`CHP`/`END`/`DIV`/`LAY`/`RND`). Record type +0 stays `ffffffff`, as in 0008:
  the boot map builder then keeps every one of them out of its container-index, CC and
  NRPN maps (Knob ids, below). Image A also patched record 2 (STR); round 7 removed those
  five patches, so record 2 is stock again in image A' (and 0008's HCT in 0008 builds).

The range is 0..0x7f00 for all seven: the encoder handler's step threshold is computed
from the ROM range and gives 0x100 for 0x7f00 as for STA's 0x7800 (r5 encoder enc-4).
PAD, CHP, END, DIV, LAY and RND keep their boot encoder template 0x401ba38c (0x100 per
tick: whole steps after `asr #8`); only id 4 gets STA's template (D18, below).

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
- Registers: d2 (the NoteEvent buffer), d4-d7 and a2-a6 are kept (callees are C;
  chop_put, which chop_set_sta tails into, saves d2/d3/a2/a3); since D29 pad_on_gate
  keeps the marker in d3 across chop_held_lock and chop_set_sta (d3 is dead here: the
  re-emitted `moveq #126,%d3` sets it on every path; both helpers save it); d0/d1/a0/a1
  are dead at entry: the next instruction after
  both re-emits is `jsr 0x4008022e` (is_key_held), which writes d0, a0 and d1 before it
  reads them (dis:165740ff, 0x40080230 / 0x40080234 / 0x4008023a); d3 is set by the
  re-emitted moveq in case 3 and not touched in case 4.

### chop_set_sta (D9)

`chop_set_sta(d0 = T, d1 = V)`: `T > 11` unsigned returns before touching anything
(0x400a39fa maps 12 and up to the FX set, kit+4724, sk-sta F1; stock guards the same way
at dis:180148-180154). Otherwise: project_singleton -> project_kit (0x400ab706, +232) ->
kit_track_param_set(kit, T) (0x400a39fa) -> param_set_value(set, 43, V, T, 1, 1)
(0x400a6316, the entry, so any future gate on it still runs). Since D29 it is a 12-byte
tail, `moveaw #43,%a0; moveaw #1,%a1; braw chop_put`: chop_put (the END / Sample Focus
writer, in cave2) is the same body for any id and record flag - the same guard, the
same three lookups (since D29 one helper, `chop_set_of`) and the same param_set_value
arguments (the pushed longs are 0x2b and 1 either way). Its only extra effect: on the
T > 11 path (unreachable from pad_on_gate, whose chop_track is latched only for 0..11)
it returns with a0 = 43 and a1 = 1, inside its "clobbers d0/d1/a0/a1" contract; the pad
path's stack is 8 B deeper at param_set_value (chop_put saves 16 B, chop_set_sta 8). V is the 8.8 marker since
Sample Focus (rounds 2-4 sent the byte marker << 8: the same value for whole markers).
Stock precedent, the same sequence with id 0x29: dis:180147-180167. It runs in the UI task only (the case-3 loop).
It never uses 0000-shared's `shared_sound_of` (whose `PROJ_KIT` was the MKII 352 until
Sample Focus step 1; 232 since).

### The held-trig path (D10)

The encoder handler calls page-view slot 0x7c (0x40038336) instead of slot 0x58
(param_apply_delta, where delta_gate sits) when 0x40036512(view+108) is non-null or
0x400366a2 is true (dis:75274-75284, 75341-75347): the held-trig / lock-source path,
which would make a stock p-lock. The 0008-only builds now have their own guard there
(round 7, own_pages = 1). `lock_gate` at its entry returns `d0 = 0` for CHOP's ids (3,
4, 5, 11, 12, 13; RND 14 first takes its own branch, which also ends in `d0 = 0`) - what slot 0x7c itself returns when slot
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
step fits (D22's drop order STR, LAY, RND was not needed). **Round 7 (D24) removed STR**
(commit 688dff3; "STR (D21) - removed in round 7" below) **and (D29) the optional STA dial**
(commit bcdc3a9; "Image B", D29 part a); everything else here stands
for image A'.

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
0 could redirect a stock scene path, and nothing here traced those paths. Image A's knob
H (STR) used id 2 instead (Error class, CC 2/34, proven dead the same way). Round 7
removed STR, so id 2 is 0008 SMP CUT's HCT again and the id budget is exact: CHOP 3, 4, 5,
11, 12, 13, 14 and SMP CUT 1, 2 use all nine dead records 1..5, 11..14.

The proof is also recorded in the registry note above the new patches. Assignment: D END
11, E DIV 12, F LAY 13, G RND 14 (H: none). One dispatcher, `chop_knob` (a 16-byte id ->
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
- **Dial (image A step 7, optional) - removed in round 7 (D29, to fit image B).**
  `dial_gate` at param_knob_draw's entry 0x400a587c stored 43 in the id slot for id 4, so
  the dial used STA's dial functor 0x400f8a3a (0..0x7800 rescaled to the full sweep, the
  16-step fraction glyph). Without it the CHOP STA knob's dial is id 4's own, drawn by
  stock param_knob_draw from id 4's records (what image A did before step 7); the value,
  the popup text and the resolution are unchanged. 28 B saved.
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

### STR (D21) - removed in round 7

Image A's knob H, STR (id 2), set the chop track's LFO up to sweep STA (DST STA, WAV RMP,
MOD ONE, SPD/MUL by steps, DEP full, END 120, LOP OFF, as base values). On the founder's
MK1 the writes landed (LFO page DST STA, WAV RMP, MOD ONE, DEP max, SPD +33, MUL 4x) but
there was no sweep, with or without retrig (TRUTH round 7). D24 removed it entirely
(commit 688dff3): `chop_str_held`, `chop_str_turn`, `chop_str_apply`, the LFO value rows,
`chop_str`, the STR branches of `lock_gate`, `chop_value` and `chop_delta_more`,
`text_gate`'s print kind 3 (STR's alone), the strings and 0001's five patches of ROM
record 2. Knob H is blank (descriptor slot 0). What image A's STR wrote into a kit (LFO,
END, LOOP base values) stays there as ordinary stock data.

**Proof that the rest is unchanged** (`corp/r7-builder/compare.py`, read-only on the two
built images; `s1/compare_A_vs_Aprime.txt`): each routine of image A (734607ae) and
image A' (f0220e4c) is decoded from the built .bin and every address inside either
image's stubs is replaced by its symbol name, so relocation is not a difference. 48
symbols are identical after naming (every gate, the pad gates, sample_key_gate,
chop_set_sta, the step lock, chop_put, END, DIV, LAY, RND, dial_gate, the state defaults
and the strings); the 8 that differ are only STR's parts: `text_gate` (the kind-3
branch, 3 instructions), `lock_gate` (the STR branch, 3), `chop_value` (the STR case,
10), `chop_delta_more` (the STR case, 5), `page_chop` (knob H id 2 -> 0), `chop_ktab`
(id 2 -> -1), `chop_tkind` (STR's 3 gone) and `chop_div` (only its extent: `chop_str`
after it is gone). The nine detours keep their hosts and entries; 5 patches are gone
(record 2's), the other 37 are the same after naming; 0 other bytes of the image differ;
0000-shared is byte-identical at the same address.

Image A' on its own (round 7 final build, `corp/r7-builder/final/`; r6's read-only
`prove.py` and `stackcheck.py`, unchanged): 2449 bytes differ from stock in 352 runs, 0
outside a claim of 0000-shared or 0001-chop; **0 bytes differ in [0x4028c708,
0x402a1b24)**; cave 1128 B placed of 1232, cave2 1305 + 234 placed of the 1700 claimed,
cave3 nothing; 185 branches and jumps decoded in 0001's code, none lands off an
instruction start or in data. The stack walk reports no problem, and its result for
every routine equals image A's except the three removed STR routines and the STR exits
of `lock_gate` and `chop_delta_more` (`final/stackcheck_Aprime_v2.txt` against
`corp/r6-builder/s7/stackcheck.txt`).

### Space (D22, D27, D29)

Image A: cave 1216 of 1232 B (16 free; the state at its end, 48 B); cave2: 0001 1461 of
its 1464 B claim (3 free) + 0000-shared 234 B. Image A' before D29: cave 1128 B (104
free), cave2 0001 1305 B (159 free). Image A' since D29 (the shared layout, "Placement"):
cave 280 of 292 B claimed (`.chst`), cave2 1448 + 434 of 1464 + 476 B and 0000-shared
234 B, cave3 77 of 84 B; cave4..6 not claimed. Image B: see "Image B". Proven by layout +
build + verify in the guest and by `check_b.py` (corp `r7b-builder/b3/check_A.txt`,
`check_B.txt`).

### Proof on the built image (host, read-only objdump / nm / python; D23)

This proof is of image A (round 6); image A' differs from it only by STR's parts (above;
its own regions and stack walk are at the end of "STR - removed in round 7").
Image A: `build/mainos_0000_0001.bin` (round 6) sha256 e9eb0eef...3d76, `AR1_OS1.73_0000_0001.syx`
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
and round-4 builds (the result line under H5). **H7-H14 are new in image A; the only
recorded hardware result is the founder's STR report (round 7)**; H13 re-runs H1-H6 on it, because every routine moved and
several changed (proof (b) above). Round 7: the card is for **image A'** (image A minus
STR, and since D29 minus the STA dial graphic): H12 (STR) is gone, H7 (d) changed (the
dial), everything else applies unchanged (D28: H7-H11, H13, H14). **Image B** runs the
same rows plus S1-S10 ("Image B test card" at the end).

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
2. **Sample Focus image A':** `build/AR1_OS1.73_0000_0001.syx` (`make samplefocus`: CHOP
   with 0000 shared only - no euclid accents, no velocity humanise, no SMP CUT, no STR;
   sha256 below). Check it boots and plays, run H13 (the round-4 regression) first, then
   H7-H11 and H14. (Image A, 734607ae..., with STR, was under this name before round 7;
   a copy is in `corp/r7-builder/baseline-imageA/`; the pre-D29 image A', f0220e4c..., is
   in `corp/r7b-builder/b0/out/`.)
3. If image A' misbehaves in H13: go back to the round-4 file,
   `flash/2b_CHOP+STEPLOCK_AR1_OS1.73_0000_0001_0002_0003.syx` (a96657b4...caf6; Before you
   flash, item 4), and report which row failed.
4. **Sample Focus image B, only after image A' behaved:**
   `build/AR1_OS1.73_0000_0001_0008.syx` (`make samplefocus-cut`: image A' plus SMP CUT;
   sha256 below). It is the first 0008 code ever to run on an MK1: read "Image B test
   card", first-run cautions, and run S1 first. If it misbehaves, go back to image A'.

If Transfer refuses a file as the same version, nothing has been written: either stop, or
send that file through the recovery route below (FUNC at power-on, TRIG 4, LEGACY OS
UPGRADE over DIN).

**Never flash the default (`AR1_OS1.73_0000_0002_0003_0008.syx`) or RANDOM
(`..._0004.syx`) builds** from this tree; image B (`..._0000_0001_0008.syx`, above) is the
only SMP CUT image meant for the founder. Round 7 fixed 0008's offsets (`SOUND0` 232 + 96,
the FX-track guard; "Image B"), but **no 0008 or 0004 image has ever run on an MK1**, any
`..._0008.syx` made before commit 50874ea carries the crash-prone `SOUND0 = 352+60` (corp
r5b offsets O8: the SMP CUT page calls through a bogus vtable), and the corp flashing
notes that point at the old `0_Latest_Custom_OS/AR1_OS1.73_0000_0002_0003_0008.syx` are
withdrawn (r5b offsets O12).

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

Files verified on 2026-10-06 in round 7 after D29 (guest VM, `make samplefocus`, `make
samplefocus-cut`, `make chop-min`, `make control`, `make verify`, `make random`, `make
guard-check`, `make elemod`, all PASS; logs in `corp/r7b-builder/b5/` and `b3/`), sha256:
`AR1_OS1.73_control.syx` 3407638c3f450daba0faedbddc0d4f08b154925a3ba162172346f51ef9ed6a8d,
`AR1_OS1.73_0000_0001.syx` (image A') 23a20937c06fe856abcd1013bda03a14eb775dbcccb9329145d0d808c5157915
(MAIN OS daff5f4ad0e8324913b7b143e2175f8354b59f4c9c2a6c19a656095c131c66c9),
`AR1_OS1.73_0000_0001_0008.syx` (image B) 86e1dd1b2a177b709d1e3977ee61b7f228d587ab752416d203014e66d21fa9a1
(MAIN OS 7fd14fcb0d43c3734aaf9a726e20845295558bb8b2ab15a9c4ee106941c4e313).
Image A' before D29 (dial graphic, round 7 step 1-4; superseded, never flashed as far as
recorded): f0220e4c83da814f7be2bc8cd0fd1276fe2ce6879b94a49a454c806bf3a82efb (MAIN OS
10003dedebc1920edf1ed04e96214a87ce6896f832e6b932d06b338799dbd965), copy in
`corp/r7b-builder/b0/out/`.
Image A (round 6, with STR; superseded; the founder ran it for the STR report):
734607ae8a213a328a46c474abd2d4b55853172761e753af34e921f41b9d14dc (MAIN OS
e9eb0eef5843a803c39da7fe7019d1af9e1c28a1f2832aa61c8398534a333d76), copy in
`corp/r7-builder/baseline-imageA/`.
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
  pause, SAMPLE again -> CHOP; again (after a pause) -> SAMP; the seven knob labels,
  A..G: PAD STA CHP END DIV LAY RND, and H empty (image A'); each knob's popup with its
  name (Chop Pad, Pad Start, Chop Mode, Slice End, Divide, Lay Out, Shuffle; group CHOP)
  and value; turning H does nothing;
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
  untraced for CHOP's ids (3..5, 11..14).
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
  (d) the STA dial (D29: no longer stock STA's - image A's dial_gate was removed): the
  dial is id 4's own. Note what it shows over 0..120 (whether the needle tracks the
  marker, and where it sits at 120: id 4's ROM range is 0..0x7f00, so the needle may stop
  short of the end; UNKNOWN, cosmetic). The value in the popup and on the SAMP page is
  what counts; the needle is display only.
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
  nothing is written - but then nothing marks the hold as edited, so when you let go the
  held trig behaves as after any hold with no edit (stock's pending toggle may remove an
  existing trig, as a plain press and release does; r6 gate G1). Use a spare step; this
  is not a failure. After a power cycle the same sequence of random slices comes back
  (fixed seed). It never writes a lock for the RND knob itself.
- **H12** (STR) - removed with STR in round 7 (D24); nothing to test on image A'.
- **H13 Round-4 regression on image A'.** Run H1, H3, H4 and H6 (a)-(e), (g), (i) again
  with END OFF, DIV 12 (the power-on state): every result as with the round-4
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
  same. G (RND) with a trig held is H11; H is empty in image A'.

Also unknown, low priority in image A': whether external MIDI CC reaches CHOP's ids
through PARAM_ROM +0x18 (ids 3..5: CC 6/38, 7, 10; 11..14: CC 99/98, 120, 121, 123; lead
F14) - the boot maps skip them (type ffffffff), but another MIDI-in path is not
excluded; with container index 0 a stray write would land in the sound's free word 0,
which nothing in image A' uses but 0008 reads as its cut settings (image B: rows S7 and
S8 below). FUNC + SAMPLE (page copy / paste / clear) on the CHOP page is untraced (H3
(f)).

## Image B (round 7, D24-D29) - built: `make samplefocus-cut`

Image B = 0000-shared (PROJ_KIT 232) + 0001-chop (image A') + 0008-sample-cut fixed for
MK1 (D25). Built and committed stepwise on branch `chop`, each step guest-built and
verified first (receipts `corp/r7-builder/s1`..`s3`, then `corp/r7b-builder/` for steps 5
and 6):

1. **688dff3 - STR out (D24):** image A' (above; byte-level proof in "STR - removed").
2. **50874ea - 0008 fixed for MK1 (D25, corp r5b offsets O1-O9 and its skeptic):**
   `SOUND0 = 232 + 96` (328): the kit is at project + 232 and kit_track_sound adds 0x60
   = 96, so cut_process reads the live sound at Sound_T + 16. In the built 0008-only
   image (`make verify`): `2028 0158 movel %a0@(344),%d0` at 0x402a1cba (was `%a0@(428)`,
   Sound_T + 100) and 0000-shared's `4868 00e8 pea %a0@(232)` at 0x402a2db4; `48680160`
   occurs in no built image; `202801ac` occurs only at 0x401178c6, a stock instruction
   (`movel %a0@(428),%d0` in `build/stock_mainos.bin` too). `word_sync` refuses a selected
   track above 11 (the FX track): d0 = a0 = 0, so 0008's delta handler writes nothing
   (mandatory per the offsets skeptic). A symbol compare against the old 0008 build
   shows only those two routines changed (`s2/compare_0008_old_vs_fixed.txt`).
3. **7ccd9c2 - one owner for the page hosts (D26, r5b pages lane + skeptic):** 0001 owns
   page_info, page_get_value, param_apply_delta, param_value_text and lock_gate (and, until
   D29, the dial);
   0008 is a provider (`provides_shared`) exporting `shared_cut_page_id` (12),
   `shared_cut_page`, `shared_cut_get`, `shared_cut_delta`, `shared_cut_text`. When
   build/shared.inc defines them (`.ifdef`), CHOP's `page_info_gate` answers page 12
   with 0008's descriptor, `chop_ktab` maps ids 1..2 to `K_CUT` (7), and get / delta /
   text `jmp` to 0008's handler with the host's frame as the host made it (get: (%sp)
   return, 8(%sp) id; delta: d2/d3/a2 saved at %sp@(0..11), a2 = view, %sp@(20) id,
   %sp@(24) delta; text: d2-d4/a2-a3 saved, d4 = id, %sp@(36) buffer); each handler
   leaves by the host's own rts or epilogue. `lock_gate` returns 0 for K_CUT: **LCT and
   HCT cannot be p-locked or scene-assigned** (held trig or lock source = no effect).
   Ids: CHOP 3, 4, 5, 11, 12, 13, 14, SMP CUT 1, 2 - all nine dead records, no overlap.
   Pages: CHOP 11 (SAMP list {4, 11}), SMP CUT 12 (FILTER list {5, 12}, 0008's patches
   in every build); page_info's own bound is `moveq #10`, both ids are answered before it.
   0008's `own_pages` param (default 0): 1 = its own page gates plus a new lock_gate
   (ids 1..2 -> 0; the r5b pages skeptic's P8 correction), which `make verify` passes.
   Tools (minimal, each from the r5b pages skeptic): build.py deletes build/shared.inc
   at the start and accumulates every provider's exports; a provider that needs the
   shared runtime must follow one (0008 without 0000-shared is refused); 0008 with
   own_pages = 0 and no 0001 is refused (`make guard-check` proves both, with their
   messages); elemod_check builds 0008 with own_pages=1, mkelemod names `page:12`.
   Without 0008 none of the dispatch is assembled: image A' is byte for byte the same
   before and after step 3 (f0220e4c...).
4. **cef0828 - the measured fit:** image B did not fit (below, "The fit before D29").
5. **bcdc3a9 - D29 option 4, part a: compaction in image A'** (below).
6. **dd84b6c - D29 option 4, part b: image B's layout and `make samplefocus-cut`** (below).

**The fit before D29 (D27, measured at cef0828).** A guest trial
(`corp/r7-builder/trial/`) linked the merged gates against 0008's exports and gave every
size: 0000-shared 236, 0001 `.text` 1180 (48 B state) + `.cave2` 1305, 0008 `.text` 887 +
state 128 + `.tab` 860 = **4596 B against the 4432 B** of cave + cave2 + cave3, 164 B
short (136 B without the dial_gate). The CEO chose option 4 (D29): behaviour-identical
compaction only - no feature removed, no cave4..6, no unproven state pool.

### D29 part a: the compaction (commit bcdc3a9, plus chop_lock_one in dd84b6c)

Each change keeps the same stock calls, in the same order, with the same arguments, on
every path; proofs in `corp/r7b-builder/a2/prove_a.txt` and the compares below.

| change | saves | why it is the same |
|---|---|---|
| `chop_set_sta` = tail into `chop_put` (id 43, record 1) | 74 B | chop_put was its body for any id and record flag ("chop_set_sta") |
| `dial_gate` and its detour removed | 28 B | the one visible change: the CHOP STA dial is id 4's own (H7 (d)) |
| `chop_set_of(T)`: project_singleton, project_kit, kit_track_param_set | 18 B | the identical three calls chop_put and chop_held_with made inline |
| `chop_locked(id)`: param_info(id), bit 8 | 36 B | the four identical inline "lockable now?" tests (held lock, LAY; STA and END) |
| `chop_end_put`: the common tail of chop_end_hit / chop_end_restore | 16 B | the same registers at chop_put's entry on every path |
| pad_on_gate keeps the marker in d3 across chop_held_lock | 14 B | d3 is dead at that detour; nothing in between writes chop_pad or chop_marks |
| `chop_lock_one`: its two `set->vt[0x40]` calls share one body | 18 B | same calls and arguments; its returned d0 (no longer -1 when E < 0) is read by nobody: chop_lay drops it and the held-step iterator never reads the invoker's d0 (0x400368d2 `jsr %a0@` then `lea; tstb %sp@(35)`) |
| 0000-shared `lean = 1` (image B only) | 94 B | shared_rnd, shared_sound_of, shared_mark_changed(_set) only - identical instructions (`compare2_0000_full_vs_lean.txt`) |

**Image A' is image A minus STR minus the dial graphic.** `corp/r7b-builder/tools/compare2.py`
decodes each symbol of the built images, names every operand that is a symbol and turns
every branch inside a routine into the index of its target, so a routine that only moved
or changed addressing mode (pc-relative vs absolute) compares equal. Against cef0828's A'
(`b3/compare2_b0_vs_b3A.txt`): 47 symbols identical; `dial_gate` gone; `chop_set_of`,
`chop_locked`, `chop_end_put` new; exactly the eight routines of the table differ
(pad_on_gate, chop_set_sta, chop_held_with, chop_lock_one, chop_put, chop_end_hit,
chop_end_restore, chop_lay); the 37 patches unchanged; 0 other bytes. Stack walk
(`b3/stackcheck_A.txt`): every exit offset as before; the pad path is up to 8 B deeper at
param_set_value, the lockable test 4 B deeper at param_info.

### D29 part b: one layout for A' and B (commit dd84b6c)

- **0008** (own_pages = 0 only; own_pages = 1 is unchanged, `make verify` 0d51f7cb... as
  before): its filter state `cut_state` goes to its own section `.cutst`, claimed in `cave`
  (D27: state only in cave); its page data and strings go to the end of `.tab` (cave3,
  constants). The audio path's entry and body (voice_out_gate, cut_process, the two loops)
  stay in `cave`; its coefficient helper `coefs` (in cave3's top 512 B) and the table it
  reads, `cut_coef` (cave3's bottom 512 B), stay in cave3 as 0008 was always built:
  cut_process calls coefs from the audio interrupt, and coefs only reads (cave3's
  residual, the registry's note: stock may read those bytes in an unknown case; nothing
  there is written at run time). One source for data and state (two macros), so the
  own_pages = 1 build is byte for byte as before.
- **0000-shared** lean claim 0x402a2d98 + 0x8c (gate `lean`); full claim gated `!lean`.
- **0001** four sections ("Placement"); its `.text` claim pair `!shared_lean` / `shared_lean`.
- registry: 0008's own_pages claims gated `own_pages`, its image-B claims `!own_pages`.
- `make samplefocus-cut` (guest: gen_cut_tables --check, build, verify).
- tools (corp r7b panel b1): `verify.py` counts only the claims of the mods the build
  contains, selected by the gates and params in its manifest, and `build.py` checks a
  detour's target against the owner's active claims only. Before, every registry claim
  counted, so a byte written into a gated-out claim or another mod's claim passed (and
  verify named the wrong owners). Every image is unchanged; a byte flipped in image B
  at a 0004 detour site, or in image A' inside 0008's claim, now fails verify where the
  old verify said "ok" (`corp/r7b-integrator/negtest.log`).

**Layout and pool use, image B** (`b3/check_B.txt`, from the built image and manifest):

| pool | claim | owner, section | written / claimed |
|---|---|---|---|
| cave 0x402a1b30..0x402a2000 | 0x402a1b30 + 0x32c | 0008 `.text` (shared_cut_* handlers, audio path) | 810 / 812 |
| | 0x402a1e5c + 0x80 | 0008 `.cutst` (filter state, 8 voices x 16 B) | 128 / 128 |
| | 0x402a1edc + 0x124 | 0001 `.chst` (pad gates, chop_value, CHOP state) | 280 / 292 |
| cave2 0x402a2780..0x402a3000 | 0x402a2780 + 0x618 | 0001 `.text` | 1500 / 1560 |
| | 0x402a2d98 + 0x8c | 0000-shared lean | 140 / 140 |
| | 0x402a2e24 + 0x1dc | 0001 `.cave2` | 434 / 476 |
| cave3 0x4024db0c..0x4024df0c | 0x4024db0c + 0x3ac | 0008 `.tab` (tables, helpers, page data, strings) | 937 / 940 |
| | 0x4024deb8 + 0x54 | 0001 `.cave3` (constants) | 77 / 84 |

4306 of 4432 B written; every pool fully claimed; 126 B free inside the claims (cave 14,
cave2 102, cave3 10); nothing in cave4..6. Image A' uses the same 0001 claims (with the
1464 B `.text` claim and 0000-shared full); 0008's image-B claims stay empty there.

**Proofs on the built image B** (host, read-only objdump / nm / python on the built
`.bin`, ELFs and manifest; `corp/r7b-builder/b3/`):
- **Dispatch** (`dispatch_B.txt`): the five shared hosts hold `jmp` to CHOP's gates
  (page_info 0x400f8736 -> page_info_gate, 0x400381a0 -> get_gate, 0x400376e4 ->
  delta_gate, 0x400a5908 -> text_gate, 0x40038336 -> lock_gate); `chop_ktab` reads
  `ff0707000102ffffffffff03040506ff`: ids 1, 2 -> K_CUT -> `jmp shared_cut_get / _delta /
  _text` with the host's frame unchanged (sp offset 0 at the jmp), and lock_gate returns 0
  (no p-lock); ids 3, 4, 5, 11, 12, 13, 14 -> CHOP (RND 14 on the lock path ->
  chop_rnd_held); every other id (0, 6..10, 15, above 15, negative) -> the displaced
  instructions and the stock rejoin. page_info: 11 -> page_chop, 12 -> 0008's descriptor
  (0x4024de70), every other page -> stock (stock's out-of-range answer also returns d0
  only).
- **0001 in B vs A'** (`compare2_0001_A_vs_B.txt`): identical except page_info_gate,
  get_gate, delta_gate, text_gate (the dispatch heads above, branch indices shifted by
  them) and chop_ktab (ids 1, 2 -> 7).
- **0008 in B vs its own_pages = 1 build** (`compare2_0008_own_vs_B.txt`): the audio path
  (voice_out_gate, cut_process, hp_loop, lp_loop, coefs), the helpers, the tables, the
  state and the data are identical; shared_cut_get / _delta / _text are identical up to
  their rts and lack only the own gates' stock tails.
- **Stack and registers** (`stackcheck_B.txt`): every path of every code symbol walked;
  every rts of a called routine at offset 0 (shared_rnd's `subl %sp@+,%d0` pop is not
  modelled by the walker and was read by hand), delta / text exits pop the host frame (12,
  20 B) with its own epilogue - in CHOP's gates and in 0008's handlers alike - and every
  re-emit path leaves with its re-emitted push; callee-saved registers written only under
  a movem frame, the host's frame, or as the re-emitted instruction's register.
- **0008's audio hook and offsets** (`check_B.txt` 4): the two VOICE_OUT call words
  0x401189ea and 0x40119d8c hold voice_out_gate 0x402a1bfc (was 0x4010795e), which calls
  0x4010795e and falls into cut_process; `4868 00e8` (pea %a0@(232), shared_sound_of) at
  0x402a2dc6 and `2028 0158` (movel %a0@(344),%d0, cut_process) at 0x402a1c50 are new;
  `48680160` occurs nowhere; `202801ac` occurs once, at the stock instruction 0x401178c6
  (in the stock image too). The calls into lean 0000-shared resolve to its labels
  (0x402a1b9a jsr shared_mark_changed, 0x4024dd50 jsr shared_sound_of, 0x402a2f80 jsr
  shared_rnd).
- **State only in cave** (`check_B.txt` 5, 6): every store to an absolute address in the
  stubs' code goes to CHOP's state in cave or to stock RAM (id 4's encoder record
  0x416a6c08..0x416a6c13, page_cycle_arm 0x40a07569 - both as image A); every address a
  stub takes with `lea` and writes through is CHOP's state (chop_marks, chop_route,
  chop_rng) or cut_state, all in cave.
- **Regions** (`check_B.txt` 1, 2): 3787 bytes differ from stock; 0 outside what the build
  applied (written blocks, 8 detours, 51 patches), each block inside an active claim of
  an enabled mod, no two active claims overlap; **0 bytes differ in [0x4028c708,
  0x402a1b24)**; verify: "embedded bootstrap image unchanged", "null repack" ok, PASS.

### SMP CUT (image B)

FILTER view, press FILTER, let go, press again: page **SMP CUT** (page 12). Knob A **LCT**
(Low Cut, id 1): 0 = OFF, 1..127 = 20 Hz .. 20 kHz; knob B **HCT** (High Cut, id 2): 127 =
OFF, lower = darker. 12 dB/octave, on the track's digital layer (sample, digital noise)
before the analog filter; the analog part of a machine is not affected. Stored per sound
in its free parameter word (index 0) and saved with the sound. Popups: `OFF`, Hz (`120`),
kHz (`1.2k`, `12k`).

### Image B test card (S1-S10 and the H rows on B; never run)

File: `build/AR1_OS1.73_0000_0001_0008.syx`, sha256 86e1dd1b...fa9a1 (full hash under
"Before you flash"). Flash it only after image A' passed H13 (Flash order, item 4).

**First-run cautions.** No 0008 image has ever run on an MK1; the old one was
crash-prone (O8) and these offsets are proven only statically. Image B is also the first
image with CHOP's round-7 layout and D29 compaction under SMP CUT. Back up first; keep
image A' and the round-4 file at hand, and the DIN recovery route (above). MIDI OUT
disconnected and nothing on MIDI IN except in S8. Stop at the first deviation; the
fallback is image A'.

**The H rows on image B.** CHOP's code in image B is the same as in image A' except the four page
gates' dispatch heads and the id table (proofs above), so run on B, in this order:
H13 (= H1, H3, H4, H6 (a)-(e), (g), (i), with END OFF / DIV 12, then the END ON and
fractional-marker repeats), H14, then one pass each of H7 (a)-(c), (e) (and (d): the dial
is id 4's own), H8 (a)-(d), H9, H10 (a)-(d), H11. Every result as on image A'; with SMP
CUT set on the chop track (LCT 40, HCT 90, say) for the second half of the pass.

Note: image A' and image B are the first MK1 images to place bytes in cave3 (CHOP constants; in B also 0008 tables and coefs, which the audio interrupt calls); stock's SAMPLE page now depends on cave3 contents.

**Run order: S1-S6, S9, S10, then S7 and S8 last** (they are listed in that order below).
S7 and S8 do on purpose what H3 (f) and the first-run cautions forbid, so if one of them
goes wrong it cannot alter the state the other rows run on.

- **S1 CHOP on image B (pages skeptic: the gates changed).** H3 (the page cycle, labels,
  popups: CHP reads OFF / ON, not 0 / 1), H1, H4 (a)-(c), H6 (a)-(e), H14: as on image A'.
  If S1 fails, stop: image B's CHOP is wrong where image A' is not.
- **S2 The SMP CUT page.** FILTER x2 shows SMP CUT with LCT / HCT (Low Cut / High Cut,
  group SMP CUT), other knobs empty; FILTER again returns to the FILTER page; popups as
  above. (FUNC + FILTER page copy / paste / clear on SMP CUT is S7 (b), run last.)
  First boot: on an untouched sound LCT and HCT must read their 'off' values (no cut) -
  0008 assumes the sound's free word is 0 on existing sounds; if they read anything else,
  stop and report before saving.
  Known quirk (r7b gate): turning HCT and then LCT within one screen update can make LCT
  jump back (both share one saved word, applied in id order) - turn LCT again.
- **S3 Audible, per track.** A sample loop on track T: LCT up thins the lows, HCT down
  dulls the highs, both together; another track playing at the same time is unaffected;
  LCT 0 and HCT 127 sound exactly as before.
- **S4 Load, before you save any kit with LCT/HCT on.** All voices sounding with both
  filters on, sequencer running: no crash, no clicks or dropouts, the UI stays responsive.
  The audio-interrupt cost is an estimate by instruction count, never measured; it grows
  with the number of voices sounding with a filter on, whatever the cutoff, and a kit
  saved with filters on brings it back whenever that kit loads. On any click, dropout or
  UI lag: set LCT 0 and HCT 127 on every track, save, stop the card and go back to image
  A'. Image B cannot measure the filters' share (the measuring build, 0008 `diag = 1`,
  does not fit image B; Next steps).
- **S5 FX track.** With the FX track selected, if SMP CUT can be reached: the knobs show
  OFF and turning them writes nothing (the word_sync guard).
- **S6 Persistence.** Set LCT/HCT on two tracks, save the kit and the project, power
  cycle, reload: the values come back and still act (ids 1..2 reach kit_param_changed
  on MK1 for the first time; what the drain does with them is UNKNOWN).
- **S9 Held trig.** GRID REC, hold a trig of T, turn LCT/HCT: nothing changes, no p-lock
  (lock_gate returns 0 for ids 1..2). Nothing marks the hold as edited, so when you let
  go the held trig behaves as after any hold with no edit (stock's pending toggle may
  remove an existing trig, as a plain press and release does). Use a spare step; this is
  not a failure.
- **S10 Both in one session (D28).** CHOP on T: pads, live REC and step lock. With CHP
  still ON, FILTER x2 and set LCT/HCT on T (the selected track is T: while CHP is ON the
  pads cannot select another track). Then CHP OFF, TRK + pad to select another track U,
  set LCT/HCT on U; select T again (TRK + pad) and turn CHP ON (it latches the selected
  track, T); then CHOP again: pads, live REC and step lock work as before, LCT/HCT on T
  and U are unchanged, and CHOP's pads never change LCT/HCT.

**Run last, after saving the project** (power-cycle and reload the saved project if one
of these misbehaves):

- **S7 Page operations (r5b pages P9; r6 gate F4).** (a) Word 0: LCT/HCT set on T; on the
  CHOP page run FUNC + SAMPLE PASTE, CLEAR, RND PAGE and RELOAD: LCT/HCT on T must not
  change (CHOP's ids also carry container index 0). (b) On SMP CUT, FUNC + FILTER page
  copy / paste / clear: note what happens (untraced, as on page 11).
- **S8 MIDI CC (P9, r6 gate F4), last.** Send CC 6/38, 7, 10, 99/98, 120, 121, 123, and CC
  1/33 and 2/34 (the SMP CUT ids' own fields; CC 1 is the mod wheel) on T's channel:
  LCT/HCT must not change (CC 120/121/123 are channel-mode messages - note any
  stock reaction separately).

## Next steps (out of scope for image A' and image B)

- Image B: the hardware run (its test card). The layout leaves 126 B free inside the
  claims (cave 14, cave2 102 - of which 60 in CHOP's `.text` claim and 42 in `.cave2` -
  cave3 10), so a later CHOP or SMP CUT feature needs more compaction or cave4..6 (r5b
  space lane; candidates that only a probe may claim). The SMP CUT measuring build (0008
  `diag = 1`) does not fit image B's `.cutst` claim and is not laid out.
- A pad press selects the PAD knob on screen (redraw the CHOP page when a pad sets
  chop_pad; today it shows at the next redraw).
- More than 12 markers (pages of markers); saving the markers (RAM only by design).
- A stretch: STR's LFO macro did not sweep on hardware and is gone; a native,
  sample-accurate stretch (r5c "B") stays research.
- Optional: restore the chop track's base STA when CHOP ends (sta lane: param_set_value
  with record 0, notify 1).
