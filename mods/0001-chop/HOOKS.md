# 0001-chop: hook map for MK1 OS 1.73

Source: only the cloned `upstream/rytm1_mods`. Every path below is relative to that folder unless it says
otherwise. There is no stock image on disk (`stock/` holds `README.md` and `SHA256SUMS` only), so nothing here
comes from new disassembly. Every address is upstream's, quoted with its toml section, and every gap is
marked UNKNOWN. Nothing upstream has run on an MK1 yet (`PORTING.md:18-20`, `docs/MANUAL.md:30-35`).
Written 2026-10-05.

Status: **FOUND** = upstream names the address, at status "verified" or "mapped", and it covers what CHOP
needs. **PARTIAL** = related addresses are found, but CHOP's exact need is not covered. **MISSING** =
nothing upstream covers it.

| need | status | anchor |
|---|---|---|
| (a) pad press input | MISSING | none. Nearest: `is_key_held` 0x4008022e |
| (b) fire a trig for one track | PARTIAL | `trig_fire` 0x400989d0 (sequencer path only) |
| (c) STA field: location and encoding | PARTIAL | sound index 21; live array at +0x14. Byte offset and encoding UNKNOWN |
| (d) page add, draw, encoder | FOUND (knobs) / MISSING (custom draw) | 0x400c71d2/d8, 0x400f8736, 0x400381a0, 0x400376e4, 0x400a5908 |
| (e) 12 persistent bytes per sound | MISSING | only sound word 0 (16 bits) persists |
| (f) code cave space | PARTIAL | three pools found; free space depends on the build |
| (g) hook bus in 0000-shared | MISSING | none |

## 1. Needs

### (a) Pad press input: MISSING
`re/symbols.toml` has no pad entry: `grep -c -w -iE 'pads?' re/symbols.toml` returns 0.

| symbol | MK1 | toml section | status | evidence (verbatim) |
|---|---|---|---|---|
| is_key_held | 0x4008022e | `[fn.is_key_held]` | verified | "Key id -> RAM table 0x40a9de08 -> bit in the key bitmap 0x40a9e568 (same 0x760 spacing as MKII's 0x418d0be0/0x418d1340). Called with pea 0x80 at the MICRO TIME ALL title, as on MKII." |
| KEY_FUNC | const 0x80 | `[const.KEY_FUNC]` | verified | "The id the MK1 MICRO TIME ALL title tests (0x4004465c), and the commonest constant argument to is_key_held (12 sites)." |
| knob_cidx_resume | 0x4003a3d4 | `[data.knob_cidx_resume]` | verified | "The page key handler's knob-event path: after jsr param_container_index at 0x4003a3ce; the result is stored to %fp@(-20) at 0x4003a3d8 and read by the release at 0x4003a7fa." |

- The page view's key handler runs at about 0x4003a3xx, but upstream does not give its entry address: UNKNOWN.
- Pads seem to bypass trig_fire's playing-trig path. The source is an MKII note that says "The per-track settings table
  is filled only by `trig_fire`, so pads get no randomisation until the pattern has played"
  (`mods/0004-lfo-rnd/design.md:72-73`). On MK1 that table is filled at trig_fire 0x40099014, after "the event is
  marked valid" (`registry/allocations.toml:629-637`). This is an inference, not proof.
- The key-event layout is known only on MKII, from 0006, which is not ported (`README.md:102`): "The event's code is
  at +12 (... the page keys 0x30..0x35) and the word at +16 its state: bit 0 down, bit 3 a long hold"
  (`mods/0006-comp-preview/stub.s:1071-1073`). That stub's `STOCK_KEYS 0x4003a544` and `IS_KEY_HELD 0x40081bbc` are
  MKII addresses (`stub.s:1082-1083`; `[fn.is_key_held]` mk2 = 0x40081bbc). Handler slots also differ between view
  classes: "`+0x48`, not `+0x08`" (`mods/0002-euclid-accents/design.md:157-158`).
- UNKNOWN: the pad key ids; whether a pad hit reaches the active view's key slot or a global handler first; where
  the pad index becomes a track index; where the velocity comes from; whether `is_key_held` answers for pads (needed for
  hold pad + encoder).

### (b) Fire a trig or voice for one track: PARTIAL
| symbol | MK1 | toml section | status | evidence (verbatim) |
|---|---|---|---|---|
| trig_fire | 0x400989d0 | `[fn.trig_fire]` | verified | "delta -0x1fec, confirmed by four unique detour-site matches inside it (0x40098ade, 0x40098b86, 0x40098fb4, 0x40099014)." |
| trig_fire_cfg_resume | 0x4009901c | `[data.trig_fire_cfg_resume]` | verified | "trig_fire after movel %d5,%a4@(12); movel %d0,%a4@(24) (0x40099014). trig_fire's prologue is identical (lea -88, moveml 44 B), so the track is at %sp@(92) here as on MKII." |
| TRIG_FLAGS | 0x8000a9e8 | `[data.TRIG_FLAGS]` | verified | "lfo_block's first lea (MKII 0x8000e508 at the same instruction): per-track long, 1 when a note started this block." |
| track_to_voice | 0x4000704e | `[fn.track_to_voice]` | verified | "track 0..11 -> physical voice from the long table 0x4018d8d4, else -1." |
| voice_owner | 0x40254e2c | `[data.voice_owner]` | verified | "8 bytes, the track that currently owns each physical voice (image default 0,4,1,5,8,6,10,2 ..." |

- trig_fire is the sequencer's: "trig_fire (sequencer interrupt) copies the triggering track's settings word"
  (`mods/0004-lfo-rnd/stub.s:542`). Upstream names no routine that plays track t now. Calling trig_fire from the UI
  is UNKNOWN: only its track slot is known.
- The meaning of TRIG_FLAGS is itself flagged: "assumed to mean "a note started this block"" (`mods/0004-lfo-rnd/design.md:59`, MKII).
- Recommended route, so CHOP never fires anything itself: keep the stock pad trigger, switch its track to the
  active track, and write STA before the trigger runs. That needs (a) and section 3, D1.

### (c) The track's sound sample start (STA): PARTIAL
| symbol | MK1 | toml section | status | evidence (verbatim) |
|---|---|---|---|---|
| kit_track_sound | 0x400a3d08 | `[fn.kit_track_sound]` | verified | "The only standalone routine that clamps the track to 0..11 and returns kit + 60 + track * 352 (40 callers)." |
| sound_get | 0x401737a2 | `[fn.sound_get]` | verified | "Slot 0x28 of Sound's vtable (0x401adc34; typeinfo 5Sound 0x401ad924): return this->+16 - the live sound the kit accessor hands out. ..." |
| project_instance | 0x416c70c0 | `[data.project_instance]` | verified | "project_singleton tests it, stores the new project there and returns it (0x40155768). ..." |
| sound_param_id_for_index | 0x40006f08 | `[fn.sound_param_id_for_index]` | verified | "Identical body (moveq #41 bound, machine table for indices 9..16). 48/48 k-gram votes." |
| PARAMS_EFF | 0x800062c0 | `[data.PARAMS_EFF]` | verified | "The per-track effective parameter array the LFO modulates: ... 42 words per track, stride 0x54." |
| kit_param_changed | 0x40033438 | `[fn.kit_param_changed]` | verified | "(bank, track, id, value): writes at bank + 18 + sel*12194 + track*938 + id*2 with the selector at +0x11de4 (73188), sets bit id in ..." |
| PARAM_ROM | 0x4018e004 | `[data.PARAM_ROM]` | verified | "The 52-byte parameter records ...: +0 container type, +4 index in it, +8 min, +0xc max, +0x24 modflags, +0x28 name, +0x2c group, +0x30 short name. ..." |

Known:
- STA is sound (container) index **21**. In the comment "the 8 machine parameters, then sample FIN and STA", the
  table after the 8 machine parameters reads `.byte 18, 21, 30, ...` (`mods/0004-lfo-rnd/stub.s:686-690`).
- To reach the live sound: `*project_instance + 352 + 60 + 352*t`, then `+16` (`mods/0008-sample-cut/stub.s:53-58`).
  Helpers `shared_sound_of` and `shared_cur_sound` do this (`mods/0000-shared/stub.s:80-110`). Its "live sound parameter
  array" is at +0x14 (`0008 stub.s:43`). Index 0 is at "+0x14, storage slot 41" (`0004 stub.s:15-16`), the sound has
  "42 parameters" (`0004 stub.s:596`), and the machine byte is at +0x68 (`0004 stub.s:33`).
- The page and setter paths carry values as "8.8 on the 0..127 scale" (`0004 stub.s:105`), and PARAMS_EFF holds 8.8
  (`0004 stub.s:648`). That array "is rebuilt from the smoother each block" (`0004 stub.s:546`).
- "Writing the live sound alone leaves the project holding the previous value" (`0000-shared/stub.s:120-121`).
  So an STA write on each pad hit can stay temporary, and only `kit_param_changed` saves a value.

UNKNOWN:
- STA's byte offset. Hypothesis only: +0x14 + 2*21 = **+0x3e**, if the array holds 42 16-bit words. The arithmetic
  is consistent (+0x14 + 2*42 = +0x68, the machine byte) but proves nothing.
- STA's parameter id, its ROM min and max, how 0..120 is stored (8.8 or not), and its storage slot. Index 0 maps to
  slot 41, so index and slot differ.
- Whether STA is smoothed or stepped in PARAMS_EFF, and when a voice latches its start point.

### (d) Page add, draw and encoder: FOUND for knobs, MISSING for custom draw
| symbol | MK1 | toml section | status | evidence (verbatim) |
|---|---|---|---|---|
| filter_view_page_count | 0x400c71d2 | `[data.filter_view_page_count]` | verified | "moveq #1,%d1 - the count of the one-entry page list the FILTER view is built from (0x400c71d6 pushes the list 0x401af51c = {5}; the view constructor 0x400ce688 follows)." |
| filter_view_page_list | 0x400c71d8 | `[data.filter_view_page_list]` | verified | "Operand of movel #0x401af51c,%d0: the list {5, FILT}. The same pattern builds every page view: {4} SAMP, {6} AMP, {3} LFO, {10} COMP ..." |
| lfo_view_page_count / _list | 0x400c727a / 0x400c7280 | `[data.lfo_view_page_count]`, `[data.lfo_view_page_list]` | verified | "moveq #1,%d1 before movel #0x401af514,%d0 = {3}: the voice LFO view ..." / "Operand of movel #0x401af514,%d0, the one-entry list {3}." |
| page_info / page_info_resume | 0x400f8736 / 0x400f873c | `[fn.page_info]`, `[data.page_info_resume]` | verified | "Page id -> 36-byte descriptor at 0x4024c5d4 + 36*id for ids 0..10 (moveq #10: MK1 has one page fewer than MKII's 0..11), else the empty descriptor 0x401b9840. ..." / "The cmpl after moveq #10,%d1 / movel %sp@(4),%d0." |
| page_get_value / _body | 0x400381a0 / 0x400381a8 | `[fn.page_get_value]`, `[data.page_get_value_body]` | verified | "(view, id, lock): param validity 0x40006e20, container index 0x40006d88, live sound via vtable 0x28, index <= 41 - as MKII. Prologue = 0004's expect bytes." |
| param_apply_delta_body / _track | 0x400376e4 / 0x400376ea | `[data.param_apply_delta_body]`, `[data.param_apply_delta_track]` | verified | "The mvzb that narrows the FUNC-held argument (0004's expect 77832f2a0074 matches here, unique)." / "jsr track_index_of right after mvzb %d3,%d3 / movel %a2@(116),%sp@-." |
| param_value_text_body / _args | 0x400a5908 / 0x400a5910 | `[data.param_value_text_body]`, `[data.param_value_text_args]` | verified | "After the two loads 0003 re-emits." / "After movel %sp@(32),%d2 / movel %sp@(36),%d3: the pea of the value into param_info." |
| view_invalidate | 0x40076c14 | `[fn.view_invalidate]` | verified | "The call the page-cycle code makes on the view right after changing its selected page (0x4003a972), as on MKII." |
| param_knob_draw_body | 0x400a5884 | `[data.param_knob_draw_body]` | verified | "param_knob_draw past lea %sp@(-24),%sp; moveml %d2-%d6/%a2,%sp@. DIFFERS from MKII: ..." |

- **How a mod declares these.** `mod.toml` carries `id`, `enabled`, `status`, `excludes`, `[sources] stub`,
  `[params]` and `[requires] shared` (`tools/build.py:99-120`). `[requires] symbols` is not read by `build.py`.
  Caves, detours and patches all go in `registry/allocations.toml`, with `owner` set to the mod id. A detour is a
  6-byte `jmp abs.l` to an `entry` label, and its `expect` bytes are checked before patching
  (`tools/layout.py:193-212`, `tools/build.py:328-383`). A patch takes `expect` plus either `replace` or
  `from_symbol` (`layout.py:144-159`). Entry labels must be even (`.align 2`, `build.py:354-361`).
- **A page, as 0008 builds one.** Patch the view's count and list pointer (`allocations.toml:349-363`). Detour
  page_info so it answers the new id with a descriptor `{name, 4 top ids, 4 bottom ids}` (`0008 stub.s:532-538`).
  Rename dead parameter ids through PARAM_ROM patches (`allocations.toml:413-484`). Detour the get, delta and text
  hosts. The delta gate sees "%sp@(20) the id, %sp@(24) the delta in 8.8" (`0008 stub.s:104`). Stock draws the page
  from the descriptor (`README.md:14-15`).
- **Limits.** A page has 8 knob slots, so it cannot show 12 markers: show the selected pad and its marker instead.
  Dead ids 1..5 are free in stock (`[data.PARAM_ROM]`: "Ids 1..5 are dead 'Error' records"). Page 11 is the only
  proven new id. The SAMP view's count and list sites are UNKNOWN: they are not in symbols.toml, which only says the
  pattern exists ("{4} SAMP"). A drawing beyond one knob (for example a 12-marker strip) is MISSING on MK1: the only
  hook is the per-knob `param_knob_draw` (0004's detour at 0x400a587c, `allocations.toml:560-567`).

### (e) Twelve persistent bytes per sound: MISSING
- There is only one persistent word: "sound index 0, the one 16-bit word per sound that the stock OS saves, loads,
  copies and undoes by itself ... and each needs all 16 bits. The other spare storage (slots 42..47) is zeroed by
  every stock save and has no place in the live sound." (`PORTING.md:127-131`)
- 12 markers of 0..120 need 7 bits each, 84 bits in all, against the word's 16. 0004 and 0008 both claim the word
  (`tools/mkelemod.py:71,80` `"sound-word:0"`).
- Pattern-side spare bits are already used: 0003 keeps its amount in TrackPattern +0x2ca bits 2..5, and 0002 owns
  that byte (`mods/0003-velocity-humanise/stub.s:3-7`). They are also per pattern, not per sound.
- Fallback: a RAM table of 12 tracks x 12 B = 144 B in a cave. It resets at power-off and follows the track, not the sound.
- UNKNOWN: any other saved spare field. The MKII `re/subsystems/lfo.md` Q8/Q9 that `PORTING.md:129` cites is not
  in this clone.

### (f) Code cave space: PARTIAL
| pool | range (end exclusive) | toml | status | evidence (verbatim, excerpt) |
|---|---|---|---|---|
| cave2 | 0x402a2780..0x402a3000, 2176 B | `[[pool]] name = "cave2"` | probably-verified | "alignment padding between the end of the read-only data and the first SRAM load image." |
| cave | 0x402a1b30..0x402a2000, 1232 B | `[[pool]] name = "cave"` | probably-verified | "On MK1 what ends just before it is the EMBEDDED BOOTSTRAP IMAGE, whose last byte is 0x402a1b23" |
| cave3 | 0x4024db0c..0x4024df0c, 1024 B | `[[pool]] name = "cave3"` | probably-verified | "So the run is padding." |

Free space per build. Claims are from `allocations.toml:119-136,335-347,492-504`, and the sums were computed with python3:
- SMP CUT build (0000+0002+0003+0008): 36 B, cave2 0x402a2fdc..0x402a3000 ("2140 B used, 36 B spare",
  `PORTING.md:53`). 0008 claims all of `cave` (0x4d0) and all of `cave3` (0x400).
- RANDOM build (with 0004): 112 B in `cave` (0x402a1f90..), 768 B in `cave3` (0x4024dc0c..), plus 36 B in cave2.
- Without 0004 and 0008: all of `cave` (1232 B) and `cave3` (1024 B), plus 36 B in cave2.
- "Not yet ported: MKII's dead-code pools cave4..cave6" (`allocations.toml:108-109`). Never claim inside
  0x4028c708..0x402a1b24 (`docs/HAZARDS.md:24-25`). A claim must be zeros (`build.py:319-323`).

### (g) Hook bus in 0000-shared: MISSING
- 0000 exports only `shared_amounts`, `shared_stops`, `shared_fmt_u8`, `shared_rnd`, `shared_cur_sound`,
  `shared_sound_of`, `shared_mark_changed(_set)` and `shared_func_held` (`mods/0000-shared/stub.s:27-164`). It says:
  "Nothing here detours anything" (`stub.s:4-5`).
- A hook bus appears only as part of a future elekloader core mod: "the hook bus (tick, draw, key, encoder, SETTINGS,
  audio render) ... this is the largest piece" (`PORTING.md:166-168`). `re/symbols.toml` has no tick, draw-loop or
  encoder hook (`grep -ciE 'encoder|hook bus|tick'` returns 0).
- CHOP can reuse `shared_sound_of` (the live sound for the active track), `shared_mark_changed_set` (to save a value),
  `shared_func_held` and `shared_fmt_u8`. Every hook CHOP needs is its own detour in the registry.

## 2. Conflicts
| resource | 0008 SMP CUT | 0004 LFO RND | CHOP needs |
|---|---|---|---|
| sound word 0 (16 bits) | all | all | too small for 12 markers anyway |
| dead param ids 1..5 | 1, 2 | 1..4 | 2 (PAD, MRK); 3..5 free with 0008, only 5 with 0004 |
| new page id | 11 | 11 | 11, or 12 (UNKNOWN whether safe) |
| detour 0x400f8736 page_info | yes | yes | yes |
| detour 0x400381a0 page_get_value | yes | yes | yes |
| detour 0x400376e4 param_apply_delta | yes | yes | yes |
| detour 0x400a5908 param_value_text | yes | yes | yes |
| view page list | FILTER 0x400c71d2/d8 | LFO 0x400c727a/80 | SAMP (UNKNOWN) or FILTER |
| caves | all of cave and cave3 | 0x460 + 0x100 | about 1 KB (estimate) |

- **The same host twice is not buildable.** `layout.py:180-192` asks for `chain_pos` chaining, but `build.py:329-344`
  checks each detour's `expect` against the image after earlier detours wrote, so a second detour on a host
  aborts ("another mod already patched here"). Upstream's working pattern is to stagger hosts on consecutive
  instructions: 0002 at 0x400376d4, then 0003 at 0x400376dc, then 0008 at 0x400376e4 (`allocations.toml:258-264,306-312,381-387`).
- **Where the 12 marker bytes could live.** Not in word 0. Options:
  1. A RAM table in a cave, 144 B, lost at power-off. This works in any build that leaves cave3 free.
  2. A CHOP-only use of word 0 as a grid: first marker (7 bits) plus spacing (7 bits). That persists per sound,
     but per-pad edits stay in RAM.
  3. A saved spare field found by disassembly (D9). UNKNOWN.
- **Coexistence.** CHOP + 0008: **no** with today's layout. There are 36 B of free cave, the same four detour hosts,
  and page 11. CHOP + 0004: **no** for the same hosts and page, with only id 5 left. CHOP + 0000/0002/0003: **yes**.
  No shared host: 0002/0003 sit at 0x400376d4 and 0x400376dc, and CHOP rejoins at the body exactly as 0008 does.
  CHOP's `mod.toml` should therefore declare `excludes = ["0004-lfo-rnd", "0008-sample-cut"]`.
- **Id clash.** 0002 declares `excludes = ["0001-microtiming-fine"]` and says "0001 is retracted"
  (`mods/0002-euclid-accents/mod.toml:11-13`). The id "0001-chop" does not match it, but it shares the number. Consider
  renumbering (for example 0009) before anything goes upstream.

## 3. What disassembly must establish next
First put the stock MK1 1.73 `.syx` that matches `stock/SHA256SUMS` in place. Use `tools/xmatch.py` against MKII
where an MKII address exists (`PORTING.md:146-149`).
- **D1, the pad path.** Starting from the key bitmap 0x40a9e568 and the table 0x40a9de08 (`[fn.is_key_held]`),
  find who sets pad bits and who calls the voice trigger on a pad hit. Questions: what are the pad key ids? Does
  the event pass through the active view's key slot (vtable offset per class)? At which instruction does the pad
  index become the track number, and can a detour there swap in the active track and run code before the
  trigger? Lead: chromatic mode already sends all 12 pads to one track (local `REPORT.md:39`).
- **D2, STA in the live sound.** Read `page_get_value` 0x400381a0 ("live sound via vtable 0x28, index <= 41") to get
  the byte offset per sound index. Confirm or refute +0x3e for index 21. Get STA's parameter id
  (`sound_param_id_for_index`, index 21), its ROM record (min/max at +8/+0xc), and the stored encoding of 0..120.
- **D3, when STA reaches the voice.** Read the PARAMS_EFF rebuild at 0x401199c8 (`[data.PARAMS_EFF]`) and the
  sample voice's note start. Is STA latched from PARAMS_EFF or from the live sound? Is it smoothed? Does a live
  write made just before the pad trigger land on the same note? This decides between "write the live sound, then
  trigger" (the prototype's CC 28 then note) and "write PARAMS_EFF in the audio interrupt" (0004's mechanism,
  `allocations.toml:639-647`).
- **D4, holding a pad.** Does `is_key_held(pad id)` work, or is there a separate pad-state array? This is needed
  for hold pad + encoder.
- **D5, the SAMP view's page list.** Find the `moveq #1` and `movel #<list {4}>` pair near 0x400c71d2..0x400c7280,
  so CHOP opens on a second SAMP press.
- **D6, chaining with 0008.** Is there a free 6-byte instruction boundary after 0x400f873c (page_info),
  0x400381a8, 0x400376ea and 0x400a5910 for staggered detours? Is page id 12 safe, with no table indexed by page id
  up to 11 only?
- **D7, dead id 5.** Check the stock bytes of record 5 at 0x4018e108 (0x4018e004 + 52*5). Container index at
  +4 = 0x4018e10c and names at +0x28..+0x30 should match ids 1..4's `expect` values (`allocations.toml:416-484`).
- **D8, the container index for CHOP's ids.** 0008 sets it to 0 (`allocations.toml:416-421`). What do
  `page_get_value`'s validity check 0x40006e20 and the key handler's list tests do with 0 versus 0xffffffff?
- **D9, persistence.** In the sound storage conversion (slot 41 <-> index 0), is any saved byte unused besides
  slot 41? If not, accept option 1 or 2 from section 2.

## 4. Milestones (each flashed only after `make verify`-style checks; see `docs/HAZARDS.md`)
- **M1: the CHOP page shows and the pads are unchanged.** This needs no new reverse engineering. Build
  0000+0002+0003+CHOP without 0008, so FILTER's proven sites are free. Patch FILTER's list to {5, 11} at
  0x400c71d2/0x400c71d8. Add a page_info gate for page 11, and rename dead ids 1..2 to PAD (1..12) and MRK (0..120).
  Add get, delta and text gates that read and write a 144 B RAM table in `cave3`. The code size is an estimate: it
  should be smaller than 0008's 993 B, because it has no audio code. The knobs use only FOUND symbols. Hardware test: FILTER twice shows CHOP, both knobs and popups work,
  pads play stock, and FILTER returns to FILT. This flash is also the first MK1 run of `cave` and `cave3`.
- **M2: MRK writes STA.** After D2, turning MRK also writes the active track's live STA (temporary, no
  `kit_param_changed`). Test: the SAMP page shows the same STA, and a sequenced trig starts there.
- **M3: pads select.** After D1 and D4, a pad press on CHOP only sets PAD (the display follows). The pad still
  plays its own track. This proves the pad hook with no change to audio.
- **M4: pads chop.** After D1 and D3, on CHOP, pad k writes marker k to the active track's STA, then the trigger
  is redirected to the active track. Compare by ear with the host prototype.
- **M5: hold pad + encoder edits that pad's marker** (D4).
- **M6: persistence** (D9, or option 2), then move CHOP to SAMP (D5), then optional 0008 coexistence (D6).
