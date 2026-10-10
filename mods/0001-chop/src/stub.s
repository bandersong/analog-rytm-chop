        | Mod 0001 - CHOP: a second SAMPLE page that turns the twelve pads into
        | twelve sample-start markers for one track.
        |
        | On the SAMPLE view, a press of SAMPLE switches SAMP <-> CHOP (on its
        | release). Not a quick double-tap: a second press inside stock's
        | double-tap window is stock's sample-list shortcut and stays stock, so
        | press, let go, pause, press again. Knobs (id in brackets):
        |   A PAD (3)  1..12    the marker being edited (a pad hit in CHOP sets it)
        |   B STA (4)  0..120   that marker: a sample start on stock's STA scale,
        |                       with stock STA's resolution (8.8: fine steps under
        |                       SAMPLE POS RES = HI, whole steps under LO, FUNC =
        |                       one whole step)
        |   C CHP (5)  OFF/ON   right: CHOP on for the track selected at that
        |                       moment (the chop track); left: off
        |   D END (11) OFF/ON   MK2 only (corp D42 removed it from MK1, where knob
        |                       D is blank, like H): right: a pad also sets the
        |                       chop track's END to the next marker above its own
        |                       (else 120); left: off, and the chop track's END
        |                       goes back to 120
        |   E DIV (12) 1..12    re-chop: marker i = ((i mod DIV) * 120) / DIV
        |   F LAY (13) -        turned right, with CHOP on and the chop track
        |                       selected (euclid off): n = min(DIV, length)
        |                       slices go onto steps s_i = i*length/n; only an
        |                       EMPTY step gets a trig plus its STA (MK2, END on:
        |                       and END) p-lock; a step with a trig is left alone
        |   G RND (14) -        turned while trig key(s) of the chop track are
        |                       held: each held step gets the STA (MK2, END on:
        |                       and END) of a random marker 0..DIV-1; each detent
        |                       re-rolls. Without a held trig it does nothing.
        |   H (none)            blank. Image A's STR (id 2, an LFO stretch
        |                       macro) was removed in round 7 (D24): it did not
        |                       sweep on hardware. Id 2 is 0008's HCT again.
        |
        | While CHOP is on, pad k (0..11) does three things, in the UI task, before
        | stock sees the pad: chop_pad = k; the chop track's STA is set to marker k
        | through the call a STA knob turn ends in, param_set_value(set, 43, V, T,
        | 1, 1) with V the 8.8 marker, so under live REC stock writes a normal STA
        | p-lock; and the pad's id in the UI message is rewritten to the chop track,
        | so stock plays (and records) the chop track exactly as if its own pad had
        | been hit. Pads never switch the selected track away from it, and no fire
        | call is hand-built. Since corp D41 every such write (chop_put: the pad's
        | STA and END, END's restore) is followed by chop_snap, which makes the
        | engine take the new STA and END at once, as the interrupt's lock pass
        | does for a sequencer p-lock; before it, the interrupt's parameter
        | smoother let the pad's own trig start near the previous marker.
        | With trig key(s) of the chop track held (D15), the STA call is replaced
        | by what stock's hold-trig + turn-STA does: an STA p-lock = marker k on
        | every held step (chop_held_lock); the base STA is then left alone.
        | Note-offs follow their note-ons (D8a): the note-on records where pad k
        | went in chop_route[k] (the chop track, or 0xFF when it was not
        | rewritten), and the note-off of pad k is rewritten to chop_route[k] when
        | that is not 0xFF, which then goes back to 0xFF - whatever chop_on is at
        | the release. Pad ids outside 0..11 touch no table: stock, byte for byte.
        |
        | Corp D42 (2026-10-10), MK1 ONLY - MK2 assembles exactly as before (every
        | difference is .ifdef'd; CHOP_END below is defined on MK2 only):
        |  - END mode is removed ("end is kind of useless as is"): knob D is
        |    blank, id 11 is stock's dead record again, and no CHOP path writes
        |    END (no END knob, END hit, END restore or END step lock; chop_snap
        |    snaps STA only).
        |  - Fix F-A: chop_set_sta passes record 0, so the pad's STA is a base
        |    value only. Under live REC it used to be a p-lock as well, which
        |    param_set_value writes on the UI's CACHED step - not always the step
        |    the hit's trig is recorded on (corp chop-locks-re R1): an unlocked
        |    trig plus a stray lock.
        |  - Fix F-B: record_gate, on live REC's trig writer call (0x4009f106):
        |    after stock has recorded the hit's trig, it writes STA = the pad's
        |    marker as a p-lock on that very step (set->vt[0x40], the store the
        |    step lock and LAY use).
        |
        | State is RAM only (the block at the end of .chst, in `cave`; the image
        | bytes are the power-on defaults). Nothing is saved. CHOP mode is the flag
        | chop_on, not "the CHOP page is on screen", so no view pointer is ever kept.
        |
        | Sections (corp round 7, one layout for image A' and image B; registry
        | 0001-chop): .chst in `cave` (the pad gates, chop_value and, last, the
        | state: run-time state only in `cave`, read pc-relative by the code next to
        | it); .text in `cave2` (the page gates, the SAMPLE key gate, lock_gate,
        | the helpers and the Sample Focus knobs, then the long knob names); .cave2
        | in `cave2` above 0000-shared's slot (the step lock and RND, then, since
        | corp D39, press_gate - the knob-press lock path); .cave3 in
        | `cave3` (constants only: the SAMP page list, the CHOP descriptor, the page
        | name and the short knob names). cave and cave2 are within bsr.w range of
        | each other; nothing branches to or from cave3.
        |
        | Every gate below that 0008 also has (page_info / get / delta / text) keeps
        | 0008's entry frame, displaced instructions, rejoin label and epilogue
        | verbatim (mods/0008-sample-cut/stub.s). Addresses and receipts: design.md.
        |
        | Image B (corp round 7, D26): with 0008-sample-cut in the same build, this
        | mod is the single owner of the page hosts (page_info, get, delta, text,
        | lock; since corp D39 also the knob-press lock path). 0008 then builds
        | without its own page gates (own_pages = 0) and provides its handlers as
        | shared_cut_* labels in build/shared.inc; the gates here send ids 1..2
        | (LCT, HCT) to them and answer page 12 with 0008's descriptor. Without
        | 0008 (image A', chop-min) none of that is assembled (.ifdef): the code
        | is image A' exactly.
        |
        | Analog Rytm MKII 1.73 (DEVICE_MK2: `make DEVICE=mk2 samplefocus` /
        | `samplefocus-cut`; corp MK2 port, TRUTH D34-D38, design.md "MK2"). The
        | same code with the MKII addresses (re/symbols_mk2.toml) and five
        | differences, each selected by .ifdef DEVICE_MK2 so the MK1 bytes stay as
        | they were: (1) stock MK2 has pages 0..11 and its SAMP view already has
        | two pages, SAMPLE (4) and SMPL WAVEFORM (5), so CHOP is page 12, the SAMP
        | list becomes {4, 5, 12} and page_info's displaced compare is moveq #11;
        | (2) no SAMPLE-key gate: every MK2 SAMPLE-key event reaches the base page
        | cycle, so a press of SAMPLE cycles SAMPLE -> SMPL WAVEFORM -> CHOP;
        | (3) samp_draw_gate: the MK2 SAMP view draws every page index but 0 with
        | the waveform layout, so page 12 is sent to the knob page draw;
        | (4) id 4's encoder template is 16 bytes on MK2 (the curve pointer at
        | +0x10), so page_info_gate copies four longs, not three; (5) the RAM
        | record stride (84) and STA's text format ('%d.%02d') come from the MK2
        | symbols and stock code. Sections land per layout A
        | (registry/allocations_mk2.toml): .chst and .cave2 in `cave`, .text and
        | .cave3 in `cave2`; run-time state stays at the end of .chst, in `cave`.

        | Analog Rytm code only. An Analog Keys build (DEVICE_KEYS, `make DEVICE=keys`)
        | must never assemble it with Rytm constants (corp keys-sk-platform C2).
        .ifdef  DEVICE_KEYS
        .error  "Analog Rytm stub: it has no Analog Keys port (DEVICE_KEYS)"
        .endif

        .include "symbols.inc"
        .include "shared.inc"                     | shared_rnd (0000-shared)

        .equ    PAGE_SAMP,      4
        .ifdef  DEVICE_MK2
        | MK2 1.73: stock pages are 0..11 (page_info 0x400ff574 'moveq #11'); the
        | SAMP view's stock pages are 4 SAMPLE and 5 SMPL WAVEFORM (list 0x401e1b20)
        | (corp mk2-addrA/addrB/geometry, skeptic-confirmed; TRUTH D36)
        .equ    PAGE_SMPL_WAVE, 5
        .equ    PAGE_CHOP,      12
        .equ    PAGE_LAST,      11                | page_info's displaced moveq
        .else
        .equ    PAGE_CHOP,      11                | MK1 pages are 0..10 (page_info's moveq #10)
        .equ    PAGE_LAST,      10                | page_info's displaced moveq
        .endif
        | END mode (knob D): MK2 only since corp D42 (removed from MK1). Every
        | END path below is assembled only when CHOP_END is defined.
        .ifdef  DEVICE_MK2
        .equ    CHOP_END,       1
        .endif
        .equ    ID_PAD,         3                 | dead Error records 3..5
        .equ    ID_STA,         4
        .equ    ID_CHP,         5
        .ifdef  CHOP_END
        .equ    ID_END,         11                | dead Error records 11..14 (D19)
        .endif
        .equ    ID_DIV,         12
        .equ    ID_LAY,         13
        .equ    ID_RND,         14
        | the CHOP knobs, as chop_knob numbers them (MK1 since D42: no K_END,
        | so DIV..CUT move down by one)
        .equ    K_PAD,          0
        .equ    K_STA,          1
        .equ    K_CHP,          2
        .ifdef  CHOP_END
        .equ    K_END,          3
        .equ    K_DIV,          4
        .equ    K_LAY,          5
        .equ    K_RND,          6
        .equ    K_CUT,          7                 | not a CHOP knob: 0008's ids 1..2 (image B)
        .else
        .equ    K_DIV,          3
        .equ    K_LAY,          4
        .equ    K_RND,          5
        .equ    K_CUT,          6                 | not a CHOP knob: 0008's ids 1..2 (image B)
        .endif
        .equ    PADS,           12
        .equ    STA_MAX,        0x7800            | stock STA's ROM max (id 43): 120.0 in 8.8
        .equ    VIEW_SEL,       116               | view +116: the track selection (= project + 48)
        .ifndef DEVICE_MK2                        | the SAMPLE key gate's (MK1 only)
        .equ    SAMP_KEY,       50                | the SAMPLE key's code (0x400ce2e0 moveq #50)
        .equ    VIEW_KEY,       136               | view +136: the view's own page key
        .equ    VIEW_POPUP,     512               | SAMP view +512: weak pointer to its list popup
        .else                                     | samp_draw_gate's (MK2 only)
        .equ    VIEW_PAGES,     124               | view +124: its page list (a vector's begin)
        .equ    VIEW_PAGE_IX,   140               | view +140: the page's index in it
        .endif
        | id 4's RAM record +4/+8/+0xc: the encoder's per-tick step, pushed step and
        | acceleration for the CHOP STA knob (the static ctor's own address for it,
        | dis:480494 'pea 0x416a6c08'). MK2: +4..+0x13, a 16-byte template whose
        | +0x10 is the curve the encoder copies (0x419a49dc, the MK2 static ctor's
        | own operand, dis:534569; corp mk2-sk-addrA).
        .equ    REC4_STEP,      PARAM_INFO_BASE + ID_STA * PARAM_INFO_STRIDE + 4

        .text

        | ------------------------------------------------------------------
        | page_info, answering PAGE_CHOP. 0008's gate, plus one thing: id 4 (the
        | CHOP STA knob) gets stock STA's encoder step fields in its RAM record -
        | {2, 0x800, 8} from STA's own template under SAMPLE POS RES = HI, id 4's
        | boot value {0x100, 0x800, 0} under LO (what the encoder forces on 43/44
        | in LO). The page view's knob-to-id slot 0x9c calls page_info on every
        | encoder event before the handler reads param_info(id)+4..+0xc
        | (dis:75090-75099, then 75150-75168), so the knob always turns with the
        | current mode's fields. Touches d0, a0 and those 12 bytes (stock page_info
        | touches d0/d1/a0).
        | MK2: the template is 16 bytes, {1, 0x40, 0, curve 0x417e3800} for STA
        | (0x401ed03c) and {1, 2, 0, curve 0x417e37e4} for the default (0x401ed07c,
        | id 4's boot value; the encoder forces a5 = 1, d6 = 2 and that curve on
        | 43/44 under LO, MK2 dis:75235-75236 and 75327-75328), and the encoder
        | reads +4, +8 and the curve at +0x10 after slot 0x9c (0x4003795a, which
        | calls page_info) - so four longs are copied, 16 bytes.
        | Entered by a jmp at the entry: (%sp) return, 4(%sp) the page id.
        | ------------------------------------------------------------------
        .align  2
page_info_gate:
        moveq   #PAGE_CHOP,%d0
        cmp.l   4(%sp),%d0
        bne.s   1f
        jsr     sample_pos_res                    | d0.b = 0 HI, else LO (d0 only)
        lea     param_tmpl_sta,%a0                | HI: STA's {2, 0x800, 8}
        tst.b   %d0
        beq.s   2f
        lea     param_tmpl_default,%a0            | LO: {0x100, 0x800, 0}
2:      move.l  (%a0)+,REC4_STEP
        move.l  (%a0)+,REC4_STEP+4
        .ifdef  DEVICE_MK2
        move.l  (%a0)+,REC4_STEP+8
        move.l  (%a0),REC4_STEP+12                | MK2: +0x10, the encoder's curve
        .else
        move.l  (%a0),REC4_STEP+8
        .endif
        lea     page_chop,%a0
        move.l  %a0,%d0
        rts
1:
        .ifdef  shared_cut_page_id
        moveq   #shared_cut_page_id,%d0           | image B: 0008's SMP CUT page (12)
        cmp.l   4(%sp),%d0
        bne.s   3f
        move.l  #shared_cut_page,%d0              | its descriptor, as 0008's own gate
        rts
3:
        .endif
        moveq   #PAGE_LAST,%d1                    | displaced (MK1 #10, MK2 #11)
        move.l  %sp@(4),%d0                       | displaced
        jmp     page_info_resume

        | ------------------------------------------------------------------
        | page_get_value for CHOP's ids: the dials, 8.8 (chop_value).
        | Entered by a jmp at the entry: (%sp) return, 4 view, 8 id, 12 lock.
        | ------------------------------------------------------------------
        .align  2
get_gate:
        move.l  8(%sp),%d0
        bsr.w   chop_knob                         | d0 = the knob, or -1
        tst.l   %d0
        bmi.s   9f
        .ifdef  shared_cut_get
        moveq   #K_CUT,%d1
        cmp.l   %d1,%d0
        bne.s   1f
        jmp     shared_cut_get                    | image B, ids 1..2: 0008's dial; its rts
1:
        .endif
        bra.w   chop_value                        | d0 = the shown value, 8.8; its rts
9:      lea     %sp@(-12),%sp                     | displaced
        moveml  %d2-%d3/%a2,%sp@                  | displaced
        jmp     page_get_value_body

        | ------------------------------------------------------------------
        | param_apply_delta for CHOP's ids: the knobs, RAM only.
        |
        | Reached by a jmp over `mvzb %d3,%d3; movel %a2@(116),%sp@-`, past the
        | prologue: %sp@(0..11) holds d2/d3/a2, a2 is the view, %sp@(20) the id,
        | %sp@(24) the delta in 8.8 as the encoder made it (FUNC not applied),
        | %sp@(28) FUNC held (0/1, its byte at %sp@(31)), %sp@(32) the apply
        | pointer. Handling the id and returning means stock never writes a sound
        | or a p-lock for it.
        |
        | PAD and CHP: whole steps (delta asr 8; their template is the default
        | 0x100 per tick). STA (D18): the marker is 8.8, 0..0x7800, and moves as
        | stock STA does - no FUNC: V += the delta (fine and accelerated in HI,
        | whole steps in LO, from the fields page_info_gate gave id 4); FUNC: STA's
        | functor 0x400f448c, V = floor(V) +- 0x100 (a delta of 0 counts as up),
        | and *ptr = 1 as apply_delta 0x400a6976 does, so the encoder re-arms its
        | FUNC lockout and redraws; then clamp 0..0x7800 and, under LO, floor, as
        | the STA writer does after its clamp (0x400a71be).
        |
        | MK2: CHP left, and CHP right latching another track, first give the
        | chop track's END back (chop_end_restore: only while CHOP and END are
        | on). MK1 (D42, no END): CHP left only clears chop_on, CHP right only
        | latches the selected track.
        | The knobs D..G (MK1: E..G) go to chop_delta_more (cave2) with whole
        | steps.
        | chop_knob keeps d3, which the stock path needs (`mvzb %d3,%d3`).
        | ------------------------------------------------------------------
        .align  2
delta_gate:
        move.l  %sp@(20),%d0
        bsr.w   chop_knob                         | d0 = the knob, or -1; keeps d3
        tst.l   %d0
        bmi.w   9f
        .ifdef  shared_cut_delta
        moveq   #K_CUT,%d1
        cmp.l   %d1,%d0
        bne.s   13f
        jmp     shared_cut_delta                  | image B, ids 1..2: 0008's knob, the
13:                                               | host frame as is; its epilogue
        .endif
        move.l  %sp@(24),%d2                      | the delta, 8.8
        move.l  %d0,%d3                           | the knob
        subq.l  #1,%d0
        beq.s   1f                                | STA: 8.8
        asr.l   #8,%d2                            | the others: whole steps, sign kept
        beq.w   7f
        tst.l   %d3
        beq.s   10f                               | PAD
        moveq   #K_CHP,%d1
        cmp.l   %d1,%d3
        beq.w   3f                                | CHP
        bsr.w   chop_delta_more                   | D..G (MK1 E..G): d2 steps, d3 knob, a2 view
        bra.w   6f
10:     moveq   #0,%d0                            | PAD: 0..11 (shown 1..12)
        move.b  chop_pad,%d0
        add.l   %d2,%d0
        moveq   #PADS-1,%d1
        bsr.w   clamp
        move.b  %d0,chop_pad
        bra.w   6f
1:      moveq   #0,%d1                            | STA: marker[chop_pad], 8.8
        move.b  chop_pad,%d1
        add.l   %d1,%d1
        lea     chop_marks,%a0
        adda.l  %d1,%a0                           | a0 = &chop_marks[chop_pad]
        mvz.w   (%a0),%d0
        tst.b   %sp@(31)                          | FUNC held
        beq.s   2f
        clr.b   %d0                               | FUNC: floor, then one whole step
        move.l  #0x100,%d1
        tst.l   %d2
        bpl.s   11f                               | 0 counts as up, as 0x400f449a..e
        neg.l   %d1
11:     add.l   %d1,%d0
        move.l  %sp@(32),%d1                      | *ptr = 1, as 0x400a6976
        beq.s   4f
        move.l  %d1,%a1
        moveq   #1,%d1
        move.b  %d1,(%a1)
        bra.s   4f
2:      tst.l   %d2                               | no FUNC: the encoder's own delta
        beq.w   7f
        add.l   %d2,%d0
4:      move.l  #STA_MAX,%d1
        bsr.w   clamp                             | 0..0x7800; keeps a0
        move.l  %d0,%d2
        jsr     sample_pos_res                    | d0 only; a0 kept
        tst.b   %d0
        beq.s   5f
        clr.b   %d2                               | LO: whole steps, as 0x400a71be
5:      move.w  %d2,(%a0)
        bra.s   6f
3:      tst.l   %d2                               | CHP
        bgt.s   4f
        .ifdef  CHOP_END
        bsr.w   chop_end_restore                  | END on: the chop track's END = 120
        .endif
        clr.b   chop_on                           | left: off
        bra.s   6f
4:      move.l  VIEW_SEL(%a2),-(%sp)              | right: on, for the selected track
        jsr     track_index_of                    | as stock at 0x400376e6..ea
        addq.l  #4,%sp
        moveq   #PADS-1,%d1
        cmp.l   %d1,%d0
        bhi.s   6f                                | FX (12) or worse: never latched
        .ifdef  CHOP_END
        move.l  %d0,%d2                           | the new chop track
        moveq   #0,%d1
        move.b  chop_track,%d1
        cmp.l   %d1,%d0
        beq.s   12f
        bsr.w   chop_end_restore                  | another track: the old one's END = 120
12:     move.b  %d2,chop_track
        .else
        move.b  %d0,chop_track                    | the new chop track (MK1: no END to give back)
        .endif
        moveq   #1,%d0
        move.b  %d0,chop_on
6:      move.l  %a2,-(%sp)                        | the view
        jsr     view_invalidate                   | redraw now
        addq.l  #4,%sp
7:      movem.l (%sp),%d2-%d3/%a2                 | param_apply_delta's epilogue
        lea     12(%sp),%sp
        rts
9:      mvzb    %d3,%d3                           | displaced
        move.l  %a2@(116),-(%sp)                  | displaced
        jmp     param_apply_delta_track

        | ------------------------------------------------------------------
        | param_value_text for CHOP's ids: the popup.
        |
        | Reached by a jmp over `movel %sp@(32),%d2; movel %sp@(36),%d3`, past the
        | prologue: %sp@(0..19) holds d2-d4/a2-a3, d4 is the id, a3 the set (both
        | live on the stock path, which chop_knob keeps), %sp@(36) the output
        | buffer; d2/d3/a2 are free here (stock loads them after this point, and
        | the epilogue restores them). chop_tkind says how each knob prints:
        | 0 a number, through stock STA's own text routine (sta_value_text, '%d.'
        | with a fraction, else '%d'), so the STA marker reads exactly as stock
        | STA does and (k+1)<<8 reads 1..12 - it writes the terminator (sprintf);
        | 1 OFF/ON; 2 a dash (an action knob). (Kind 3, OFF or a number, was
        | STR's alone and went with it, D24.)
        | ------------------------------------------------------------------
        .align  2
text_gate:
        move.l  %d4,%d0
        bsr.w   chop_knob                         | keeps d4/a3
        tst.l   %d0
        bmi.w   9f
        .ifdef  shared_cut_text
        moveq   #K_CUT,%d1
        cmp.l   %d1,%d0
        bne.s   7f
        jmp     shared_cut_text                   | image B, ids 1..2: 0008's popup, d4 =
7:                                                | the id; its epilogue
        .endif
        move.l  %d0,%d2                           | the knob
        bsr.w   chop_value                        | d0 = the value, 8.8
        move.l  %sp@(36),%a1                      | the output buffer
        lea     chop_tkind,%a0
        moveq   #0,%d1
        move.b  0(%a0,%d2.l),%d1                  | how this knob prints
        beq.s   4f                                | 0: a number
        moveq   #2,%d3
        cmp.l   %d3,%d1
        beq.s   3f                                | 2: a dash
        tst.l   %d0                               | 1: OFF / ON
        beq.s   2f
        move.b  #0x4f,(%a1)+                      | ON
        move.b  #0x4e,(%a1)+
        bra.s   5f
2:      move.b  #0x4f,(%a1)+                      | OFF
        move.b  #0x46,(%a1)+
        move.b  #0x46,(%a1)+
        bra.s   5f
3:      move.b  #0x2d,(%a1)+                      | -
        bra.s   5f
4:      move.l  %a1,-(%sp)                        | buf
        move.l  %d0,-(%sp)                        | value, 8.8
        clr.l   -(%sp)                            | the functor slot (never read)
        jsr     sta_value_text
        lea     12(%sp),%sp
        bra.s   6f
5:      clr.b   (%a1)
6:      movem.l (%sp),%d2-%d4/%a2-%a3             | param_value_text's epilogue
        lea     20(%sp),%sp
        rts
9:      movel   %sp@(32),%d2                      | displaced
        movel   %sp@(36),%d3                      | displaced
        jmp     param_value_text_args

        .ifndef DEVICE_MK2
        | ------------------------------------------------------------------
        | sample_key_gate: the SAMPLE key on the SAMP view, so a second press
        | cycles to CHOP the way a second FILTER press cycles a FILTER view.
        |
        | The SAMP view overrides the key handler (0x400ce2c4) and, for code 50,
        | never calls the base handler on a plain press or release, so the base's
        | page cycle (0x4003a952) never runs. This detour sits at 0x400ce4b8,
        | reached only with code == 50, bit1 clear (0x400ce48e -> base otherwise),
        | bit2 clear (0x400ce4a8), and, on a release, view +496 == 0
        | (0x400ce3b6). Live: d2 = the event, a2 = the view, the stack clean;
        | d0/d1/a0/a1 are free (d3/d4/a3 are set again on every stock path after).
        |
        |  press, no hold:  arm the base's cycle byte exactly when the press does
        |                   not close a popup (popup expired = 1, else 0); stock
        |  release:         if armed, bit4 set, no hold, the view's own key is
        |                   SAMPLE and no list popup is open, every condition of
        |                   the base's cycle branch (0x4003a610 .. 0x4003a94e)
        |                   holds, so hand the event to the base through SAMP's
        |                   own tail 0x400ce3f4; else stock
        |  anything else:   stock
        |
        | A quick second press of SAMPLE (stock's double-tap window, 0x40249d84 =
        | 64 key-timer ticks, flags it bit2 at 0x400803da..0x400803fa) never gets
        | here: SAMP opens the sample list for it (0x400ce49c..0x400ce4b6). The
        | arm byte from the first press is still set at the second press's
        | release, which is why the release path checks the popup: an open list
        | means stock, no cycle.
        | ------------------------------------------------------------------
        .align  2
sample_key_gate:
        move.l  %d2,-(%sp)
        jsr     ev_is_down
        addq.l  #4,%sp
        tst.l   %d0
        bne.s   2f
        tst.b   page_cycle_arm                    | release
        beq.s   8f
        move.l  %d2,-(%sp)
        jsr     ev_bit4
        addq.l  #4,%sp
        tst.l   %d0
        beq.s   8f
        move.l  %d2,-(%sp)
        jsr     ev_is_held
        addq.l  #4,%sp
        tst.l   %d0
        bne.s   8f
        moveq   #SAMP_KEY,%d1
        cmp.l   VIEW_KEY(%a2),%d1
        bne.s   8f
        pea     VIEW_POPUP(%a2)                   | a list popup open now was opened
        jsr     weak_ptr_expired                  | after the arming press (a double-tap,
        addq.l  #4,%sp                            | bit2, never reaches this gate): stock
        tst.b   %d0                               | keeps it open, so no cycle
        beq.s   8f
        jmp     samp_key_to_base                  | base(view, event): cycles, returns
2:      move.l  %d2,-(%sp)                        | press
        jsr     ev_is_held
        addq.l  #4,%sp
        tst.l   %d0
        bne.s   8f                                | long hold: stock, arm untouched
        pea     VIEW_POPUP(%a2)
        jsr     weak_ptr_expired                  | 1 = no popup open to close
        addq.l  #4,%sp
        tst.b   %d0
        sne     %d0
        moveq   #1,%d1
        and.l   %d1,%d0                           | 0 or 1, as the base stores it
        move.b  %d0,page_cycle_arm
8:      move.l  %d2,-(%sp)                        | displaced
        lea     ev_is_down,%a3                    | displaced (lea 0x400706f0,%a3)
        jmp     samp_key_resume

        .else
        | ------------------------------------------------------------------
        | samp_draw_gate (MK2 only): the SAMP view's draw (vtable 0x401e3170 slot
        | 0x10 = 0x400d1f98) draws page INDEX 0 as a knob page (0x400d1fae: jsr
        | 0x400d2e1a, the knob page draw - 0x40039782 plus FILTER extras for page
        | id 6 only) and every other index with SMPL WAVEFORM's layout (0x400d1fbc:
        | a fixed 8-knob grid and the waveform at view+400). This detour replaces
        | that test, 'tstl %a2@(140); bnes 0x400d1fbc' at 0x400d1fa8 (6 bytes,
        | exactly the jmp), so that the CHOP page draws as a knob page too:
        |   index 0                      -> 0x400d1fae (stock)
        |   page id at the index == 12   -> 0x400d1fae (CHOP)
        |   anything else                -> 0x400d1fbc (stock: SMPL WAVEFORM)
        | The page id is read as the view's own slot 0x68 reads it (0x40037660:
        | view+124 is the page list, view+140 the index; it touches d0/a0 only).
        | Live: a2 = the view, a4 = the draw context, d2-d7/a2-a6 saved by the
        | host's prologue; d0/d1/a0/a1 are not read on either continuation before
        | being written (0x400d1fae pushes a4/a2 and calls; 0x400d1fbc pushes
        | constants and a4 and calls), and neither reads the condition codes.
        | The bne.s is pc-relative, so it is re-implemented here, not re-emitted
        | (registry: reemit = false); tst.l 140(%a2) is the displaced test.
        | ------------------------------------------------------------------
        .align  2
samp_draw_gate:
        tst.l   VIEW_PAGE_IX(%a2)                 | displaced: index 0 (SAMPLE)
        beq.s   1f
        move.l  VIEW_PAGES(%a2),%a0
        move.l  VIEW_PAGE_IX(%a2),%d0
        moveq   #PAGE_CHOP,%d1
        cmp.l   0(%a0,%d0.l*4),%d1
        beq.s   1f                                | CHOP: the knob page as well
        jmp     samp_draw_wave                    | stock: SMPL WAVEFORM's layout
1:      jmp     samp_draw_knobs                   | stock: the knob page draw
        .endif

        | ------------------------------------------------------------------
        | pad_on_gate: UI-loop case 3 (a pad's note-on message), 0x400a1ee2.
        | Live: a2 = the message (+4 pad id, +8 velocity, +12 time), d2 = the
        | NoteEvent buffer, the stack clean; d0/d1/a0/a1/d3 are free (the
        | re-emitted moveq sets d3, the jsr after the rejoin clobbers the rest).
        | Kept: d2, d4-d7, a2-a6.
        |
        | k > 11 unsigned (or -1): stock, no table touched. k <= 11 with CHOP
        | off: chop_route[k] = 0xFF (this note-on was not rewritten), message
        | untouched. k <= 11 with CHOP on: chop_route[k] = chop_track, then the
        | marker, the held-step lock or the STA call, and the rewrite.
        |
        | Step lock (D15-D15b): chop_held_lock(T, V) first. It returns 1 only
        | when it wrote STA = V as a p-lock on every held step of the chop
        | track (the stock held-trig knob path); then chop_set_sta is SKIPPED,
        | so the base STA is untouched and no live-REC lock lands on the
        | playing step. It returns 0 (nothing done) otherwise, and the hit goes
        | on exactly as before: chop_set_sta(T, V), record 1 (MK1 since D42:
        | record 0, a base value only - record_gate writes the live-REC lock on
        | the trig's own step), then (MK2, END on only) chop_end_hit: END = the
        | slice end, record 1. Either way the rewrite and the stock continuation
        | follow. V is the 8.8 marker. MK2 with END on: the step lock also locks
        | END on each held step (chop_held_lock).
        | ------------------------------------------------------------------
        .section .chst,"awx"                    | cave, with the state (pc-relative reads)
        .align  2
pad_on_gate:
        move.l  4(%a2),%d0                        | k
        moveq   #PADS-1,%d1
        cmp.l   %d1,%d0
        bhi.s   8f                                | unsigned: k > 11 (or -1) is stock
        lea     chop_route,%a0
        adda.l  %d0,%a0                           | a0 = &chop_route[k], k 0..11
        tst.b   chop_on
        bne.s   1f
        moveq   #-1,%d1
        move.b  %d1,(%a0)                         | chop_route[k] = 0xFF: not rewritten
        bra.s   8f
1:      moveq   #0,%d1
        move.b  chop_track,%d1
        move.b  %d1,(%a0)                         | chop_route[k] = T: its note-off follows
        move.b  %d0,chop_pad
        lea     chop_marks,%a0
        mvz.w   0(%a0,%d0.l*2),%d3                | V = marker k, 8.8, in d3: free here
        move.l  %d1,%d0                           | (the re-emitted moveq sets it) and
        move.l  %d3,%d1                           | kept by every helper below
        bsr.w   chop_held_lock                    | d0 = 1: held steps locked
        tst.l   %d0
        bne.s   2f                                | D15a: locked, no chop_set_sta
        moveq   #0,%d0                            | reload T: the helper clobbers
        move.b  chop_track,%d0                    | d0/d1/a0/a1 (it writes no state)
        move.l  %d3,%d1                           | V, unchanged (marks, chop_pad unwritten)
        bsr.w   chop_set_sta
        .ifdef  CHOP_END
        bsr.w   chop_end_hit                      | END on: the slice's END, after STA
        .endif
2:      moveq   #0,%d0
        move.b  chop_track,%d0
        move.l  %d0,4(%a2)                        | the hit now names the chop track
8:      pea     0x80                              | displaced
        moveq   #126,%d3                          | displaced
        jmp     ui_pad_on_resume

        | ------------------------------------------------------------------
        | pad_off_gate: UI-loop case 4 (a pad's note-off message), 0x400a1f26,
        | 10 bytes displaced. Paired with the note-on (D8a): if k <= 11 and
        | chop_route[k] != 0xFF, msg+4 := chop_route[k] and chop_route[k] = 0xFF;
        | otherwise stock. chop_on is not read here, so a note-off follows its
        | note-on even when CHP was turned in between. The re-emitted pea stays
        | pushed: stock's own `lea %sp@(36)` at 0x400a1f56 pops it, as in stock.
        | ------------------------------------------------------------------
        .align  2
pad_off_gate:
        move.l  4(%a2),%d0                        | k
        moveq   #PADS-1,%d1
        cmp.l   %d1,%d0
        bhi.s   8f                                | unsigned: k > 11 (or -1) is stock
        lea     chop_route,%a0
        adda.l  %d0,%a0                           | a0 = &chop_route[k], k 0..11
        moveq   #0,%d0
        move.b  (%a0),%d0                         | T, or 0xFF
        cmpi.l  #0xff,%d0
        beq.s   8f                                | its note-on was not rewritten: stock
        move.l  %d0,4(%a2)                        | the release names the same track
        moveq   #-1,%d1
        move.b  %d1,(%a0)                         | chop_route[k] = 0xFF: used once
8:      pea     0x80                              | displaced
        jsr     is_key_held                       | displaced
        jmp     ui_pad_off_resume

        | ------------------------------------------------------------------
        | lock_gate: the page view's held-trig / lock-source knob path (vtable
        | slot 0x7c, 0x40038336), which the encoder handler calls INSTEAD of
        | param_apply_delta when a trig is held (0x4003a024). For CHOP's ids it
        | returns 0 - what stock returns when slot 0x6c says the id cannot be
        | locked - so a CHOP knob never writes a stock p-lock. RND (knob G) is
        | the one that does something here: chop_rnd_held, the step lock with
        | random markers, which also returns 0. In image B, 0008's ids 1..2
        | (K_CUT) return 0 here too (D26; corp r5b pages P8). Every other id:
        | stock.
        | Entered by a jmp at the entry: (%sp) return, 4 view, 8 id, 12 delta.
        | ------------------------------------------------------------------
        .text
        .align  2
lock_gate:
        move.l  8(%sp),%d0
        bsr.w   chop_knob
        tst.l   %d0
        bmi.s   9f
        moveq   #K_RND,%d1
        cmp.l   %d1,%d0
        beq.w   chop_rnd_held                     | its rts returns to the encoder
        moveq   #0,%d0
        rts
9:      lea     -48(%sp),%sp                      | displaced
        movem.l %d2-%d7/%a2-%a3,(%sp)             | displaced
        jmp     lock_delta_body

        | ------------------------------------------------------------------
        | chop_set_sta(d0 = track T, d1 = marker V, 8.8 0..0x7800): what a STA
        | knob turn ends in, for track T: set = kit_track_param_set(project_kit(
        | project), T), then param_set_value(set, 43, V, T, 1 record, 1 notify) -
        | the same call stock makes at 0x4008ba12..0x4008ba54 (with id 0x29
        | there). Under LO the writer floors V itself (0x400a71be). T > 11
        | returns without writing: 0x400a39fa maps 12 and up to the FX set.
        | Since corp round 7 (D29) it is a tail into chop_put (cave2) with id 43
        | and record 1: chop_put is this routine's body for any id and either
        | record flag (same guard, same calls, same arguments), so the two
        | copies became one. Since corp D41 chop_put ends with chop_snap(T) (the
        | engine takes STA and END at once). UI task only. Clobbers d0/d1/a0/a1,
        | keeps everything else.
        | This copy is MK2's (record 1, unchanged). MK1 since corp D42 (fix F-A):
        | record 0, so the pad's STA is a base value only, never a p-lock -
        | under live REC param_set_value locked the UI's CACHED step (0x400ac968
        | via 0x400a7132, reached only with record != 0: 'tstb %d5' at
        | 0x400a711c), which is not always the step the hit's trig is recorded
        | on (corp chop-locks-re R1); record_gate now writes that lock on the
        | trig's own step. The MK1 chop_set_sta sits right before chop_put and
        | falls into it (below).
        | ------------------------------------------------------------------
        .ifdef  DEVICE_MK2
        .align  2
chop_set_sta:
        movea.w #PARAM_ID_STA,%a0                 | id 43
        movea.w #1,%a1                            | record: a p-lock under live REC
        bra.w   chop_put                          | its rts returns to the caller
        .endif

        | ------------------------------------------------------------------
        | chop_knob(d0 = param id) -> d0 = the CHOP knob (K_PAD..), K_CUT for
        | 0008's ids 1..2 in image B, or -1 for every other id (and for ids
        | above 15 or negative).
        | Clobbers d0/d1/a0; keeps everything else.
        | ------------------------------------------------------------------
        .align  2
chop_knob:
        moveq   #15,%d1
        cmp.l   %d1,%d0
        bhi.s   1f                                | unsigned: > 15, or negative
        lea     chop_ktab,%a0
        mvs.b   0(%a0,%d0.l),%d0
        rts
1:      moveq   #-1,%d0
        rts

        | ------------------------------------------------------------------
        | chop_value(d0 = knob) -> d0 = what the knob shows, 8.8: PAD (k+1)<<8,
        | the STA marker as it is, CHP / END (MK2) 0 or 0x100, DIV 1..12 << 8,
        | the action knobs 0. Clobbers d0/d1/a0; keeps a1.
        | ------------------------------------------------------------------
        .section .chst,"awx"
        .align  2
chop_value:
        tst.l   %d0
        bne.s   1f
        moveq   #0,%d0
        move.b  chop_pad,%d0
        addq.l  #1,%d0                            | PAD 1..12
        bra.s   8f
1:      subq.l  #1,%d0
        bne.s   2f
        moveq   #0,%d1
        move.b  chop_pad,%d1
        lea     chop_marks,%a0
        mvz.w   0(%a0,%d1.l*2),%d0               | STA 0..0x7800
        rts
2:      subq.l  #1,%d0
        bne.s   3f
        moveq   #0,%d0
        move.b  chop_on,%d0                       | CHP 0/1
        bra.s   8f
3:
        .ifdef  CHOP_END
        subq.l  #1,%d0
        bne.s   4f
        moveq   #0,%d0
        move.b  chop_end,%d0                      | END 0/1
        bra.s   8f
4:
        .endif
        subq.l  #1,%d0
        bne.s   6f
        moveq   #0,%d0
        move.b  chop_div,%d0                      | DIV 1..12
        bra.s   8f
6:      moveq   #0,%d0                            | LAY, RND: action knobs
        rts
8:      lsl.l   #8,%d0
        rts

        .text
        | clamp(d0, d1 = max) -> d0 in 0..max. Clobbers nothing else.
        .align  2
clamp:  tst.l   %d0
        bpl.s   1f
        clr.l   %d0
1:      cmp.l   %d1,%d0
        ble.s   2f
        move.l  %d1,%d0
2:      rts

        | ------------------------------------------------------------------
        | Data
        | ------------------------------------------------------------------
        .section .cave3,"aw"                    | cave3: constants only ("aw" so that nm
                                                  | lists its labels as D, which build.py reads)
        .align  2
chop_pages:                                       | the SAMP view's pages
        .ifdef  DEVICE_MK2
        .long   PAGE_SAMP, PAGE_SMPL_WAVE, PAGE_CHOP  | MK2: stock's {4, 5}, then CHOP
        .else
        .long   PAGE_SAMP, PAGE_CHOP
        .endif

page_chop:                                        | {name, top row, bottom row}
        .long   str_page
        .ifdef  CHOP_END
        .long   ID_PAD, ID_STA, ID_CHP, ID_END
        .else
        .long   ID_PAD, ID_STA, ID_CHP, 0         | MK1 knob D: none (END removed, D42)
        .endif
        .long   ID_DIV, ID_LAY, ID_RND, 0         | knob H: none (STR removed, D24)

        .text
        | id -> CHOP knob (-1: not CHOP's), for ids 0..15; in image B ids 1..2
        | (0008's LCT, HCT) map to K_CUT, which the gates hand to 0008
chop_ktab:
        .ifdef  shared_cut_get
        .byte   -1, K_CUT, K_CUT, K_PAD, K_STA, K_CHP, -1, -1
        .else
        .byte   -1, -1, -1, K_PAD, K_STA, K_CHP, -1, -1
        .endif
        .ifdef  CHOP_END
        .byte   -1, -1, -1, K_END, K_DIV, K_LAY, K_RND, -1
        .else
        .byte   -1, -1, -1, -1, K_DIV, K_LAY, K_RND, -1 | MK1: id 11 is stock's (D42)
        .endif
        | CHOP knob -> how its popup prints (text_gate)
chop_tkind:
        .ifdef  CHOP_END
        .byte   0, 0, 1, 1, 0, 2, 2             | PAD STA CHP END DIV LAY RND
        .else
        .byte   0, 0, 1, 0, 2, 2                | PAD STA CHP DIV LAY RND
        .endif


        | ==================================================================
        | cave2: the step lock (round 4: V arrives as 8.8, END rides along) and
        | the Sample Focus knobs
        | ==================================================================
        .section .cave2,"ax"

        | ------------------------------------------------------------------
        | chop_held_lock(d0 = T, d1 = V 8.8 0..0x7800) -> d0 = 1 locked / 0 nothing.
        |
        | The stock held-trig knob path (page-view slot 0x7c 0x40038482..e8,
        | and the UI loop's own copy at 0x4009f2ee..0x4009f352), for STA = V on
        | track T, with no view. Returns 0 at the first guard that fails, with
        | no side effect (every call before the last guard only reads):
        |   S = ui_states()                          (UIStates, view+108)
        |   hold_lock_source(S) == 0                 (no scene/perf locker)
        |   hold_any_in_length(S) != 0               (a trig held, < length)
        |   T <= 11                                  (12+ is the FX set)
        |   track_index_of(project_selection(project)) == T
        |                                            (the lock store writes
        |                                             the SELECTED track)
        |   (*param_info(43) & 0x100) == 0           (slot 0x6c: lockable)
        | Then, as stock: hold_set_edited(S, 1) (the release will not toggle
        | the trig); hold_each_step(S, &fn, 0) with a 20-byte stack functor
        | {+0 V, +4 set, +8 manager (non-null; never called), +12 the invoker,
        | +16 E}, set = kit_track_param_set(project_kit(project), T);
        | hold_clear_actions(S); return 1. Stock's own functor is heap-backed
        | and destroyed by 0x40146854; this one holds its data inline, the
        | iterator never copies, destroys or calls the manager (0x40036888,
        | 0x400368bc..0x400368dc) and reads only +8 and +12 of it, so nothing
        | is allocated or freed and the extra word is safe.
        | E (D20) = the END lock: the slice end of chop_pad (chop_next_above)
        | when END is on and id 44 is lockable now (slot 0x6c's test, as for
        | 43), else -1 = no END lock.
        | MK1 since corp D42 (no END): the functor is 16 bytes, {+0 V, +4 set,
        | +8 manager, +12 invoker}; there is no +16 and no END lock.
        | chop_held_lock: the invoker is chop_lock_step (the pad, V = marker k).
        | chop_held_with(d0 = T, d1 = V, a1 = the invoker): the same, for
        | another invoker (the knobs' own held-step writers).
        | UI task only. Clobbers d0/d1/a0/a1; keeps d2-d7/a2-a6.
        | ------------------------------------------------------------------
        .ifdef  CHOP_END
        .equ    HELD_FRAME,     32                | 12 saved + the 20-byte functor
        .else
        .equ    HELD_FRAME,     28                | MK1: 12 saved + the 16-byte functor
        .endif
        .align  2
chop_held_lock:
        lea     chop_lock_step,%a1
chop_held_with:
        lea     -HELD_FRAME(%sp),%sp              | 12 saved + the functor at 12(%sp)
        movem.l %d2-%d3/%a2,(%sp)
        move.l  %a1,24(%sp)                       | fn+12 invoker (our own frame)
        move.l  %d0,%d2                           | T
        move.l  %d1,%d3                           | V, 8.8
        jsr     ui_states
        move.l  %d0,%a2                           | S
        move.l  %a2,-(%sp)
        jsr     hold_lock_source
        addq.l  #4,%sp
        tst.l   %d0
        bne.w   8f                                | a scene/perf locker owns the knobs
        move.l  %a2,-(%sp)
        jsr     hold_any_in_length
        addq.l  #4,%sp
        tst.b   %d0
        beq.w   8f                                | no trig held
        moveq   #PADS-1,%d0
        cmp.l   %d0,%d2
        bhi.w   8f                                | T > 11 unsigned
        jsr     project_singleton
        move.l  %d0,-(%sp)
        jsr     project_selection                 | project + 48
        move.l  %d0,(%sp)
        jsr     track_index_of                    | the selected track
        addq.l  #4,%sp
        cmp.l   %d2,%d0
        bne.w   8f                                | not the chop track
        moveq   #PARAM_ID_STA,%d0
        bsr.w   chop_locked                       | STA's RAM record, bit 8
        bne.w   8f                                | 0x100: STA cannot be locked now
        move.l  %d2,%d0                           | T
        bsr.w   chop_set_of                       | track T's SoundParameterSet
        move.l  %d3,12(%sp)                       | fn+0  V (8.8, as the knob)
        move.l  %d0,16(%sp)                       | fn+4  set
        lea     chop_fn_mgr,%a0
        move.l  %a0,20(%sp)                       | fn+8  manager: non-null
        .ifdef  CHOP_END
        moveq   #-1,%d3                           | fn+16 E: -1 = no END lock
        tst.b   chop_end
        beq.s   1f
        moveq   #PARAM_ID_END,%d0
        bsr.w   chop_locked                       | END's RAM record, bit 8
        bne.s   1f                                | 0x100: END cannot be locked now
        moveq   #0,%d0
        move.b  chop_pad,%d0
        bsr.w   chop_next_above
        move.l  %d0,%d3                           | E, 8.8
1:      move.l  %d3,28(%sp)                       | fn+16
        .endif
        pea     1
        move.l  %a2,-(%sp)
        jsr     hold_set_edited                   | S+352 = 1, as stock 0x4003848a
        addq.l  #8,%sp
        lea     12(%sp),%a0                       | &fn, taken before any push
        clr.l   -(%sp)                            | 0: held steps below the length
        move.l  %a0,-(%sp)                        | &fn
        move.l  %a2,-(%sp)
        jsr     hold_each_step                    | chop_lock_step per held step
        lea     12(%sp),%sp
        move.l  %a2,-(%sp)
        jsr     hold_clear_actions                | as stock 0x400384e2
        addq.l  #4,%sp
        moveq   #1,%d0
        bra.s   9f
8:      moveq   #0,%d0
9:      movem.l (%sp),%d2-%d3/%a2
        lea     HELD_FRAME(%sp),%sp
        rts

        | chop_lock_step(fn*, step, bool* stop): set->vt[0x40](set, 43, V,
        | step) = 0x400a6bd0, the writer stock's slot 0x74 tail-jumps to, then
        | (MK2, fn+16 >= 0 only) the same with 44 = E: STA first, END second,
        | as stock orders them (0x4008b840). *stop is left 0 (the iterator
        | clears it once), so every held step is visited. Clobbers d0/d1/a0/a1
        | only.
        .align  2
chop_lock_step:
        move.l  4(%sp),%a0                        | fn
        .ifdef  CHOP_END
        move.l  16(%a0),-(%sp)                    | E, or -1
        .endif
        move.l  (%a0),-(%sp)                      | V, 8.8
        move.l  4(%a0),-(%sp)                     | set
        .ifdef  CHOP_END
        move.l  20(%sp),-(%sp)                    | step
        bsr.s   chop_lock_one
        lea     16(%sp),%sp
        .else
        move.l  16(%sp),-(%sp)                    | step (8(%sp) at entry, + 2 pushes)
        bsr.s   chop_lock_one
        lea     12(%sp),%sp
        .endif
        rts

        | chop_lock_one(step, set, V, E): set->vt[0x40](set, 43, V, step), then
        | if E >= 0, set->vt[0x40](set, 44, E, step). 0x400a6bd0 writes the
        | SELECTED track and floors 43/44 under LO itself (dis:214107-214114,
        | 214142). Clobbers d0/d1/a0/a1. Since corp round 7 (D29) the two calls
        | share one body (1:, d0 = the id pushed as a long, d1 = the value);
        | d0 on return is no longer -1 when E < 0, which nobody reads: chop_lay
        | drops it, and the held-step iterator (hold_each_step, dis 0x400368d2
        | 'jsr %a0@' then 'lea / tstb %sp@(35)') never reads the invoker's d0.
        | MK1 since corp D42 (no END): chop_lock_one(step, set, V), the STA call
        | alone, the same body run once (callers push three longs, not four).
        .align  2
chop_lock_one:
        move.l  12(%sp),%d1                       | V
        moveq   #PARAM_ID_STA,%d0                 | 43
        .ifdef  CHOP_END
        bsr.s   1f
        move.l  16(%sp),%d1                       | E
        bmi.s   9f                                | -1: no END lock
        moveq   #PARAM_ID_END,%d0                 | 44
        bsr.s   1f
9:      rts
1:      move.l  8(%sp),-(%sp)                     | step (past both returns)
        move.l  %d1,-(%sp)                        | the value
        move.l  %d0,-(%sp)                        | the id
        move.l  24(%sp),%a1                       | set
        .else
        move.l  4(%sp),-(%sp)                     | step
        move.l  %d1,-(%sp)                        | the value
        move.l  %d0,-(%sp)                        | the id
        move.l  20(%sp),%a1                       | set (8(%sp) + 12)
        .endif
        move.l  %a1,-(%sp)
        move.l  (%a1),%a0
        move.l  0x40(%a0),%a0                     | SoundParameterSet vt[0x40]
        jsr     (%a0)
        lea     16(%sp),%sp
        rts

        | The functor's manager word. 0x4003683c only tests it for non-null;
        | nothing calls it (no copy, no destroy). Harmless if ever called.
        .align  2
chop_fn_mgr:
        moveq   #0,%d0
        rts

        | ------------------------------------------------------------------
        | chop_put(d0 = T, d1 = V 8.8, a0 = param id, a1 = record 0/1):
        | param_set_value(kit_track_param_set(project_kit(project), T), id, V,
        | T, record, notify 1) - stock's STA-style writer call, for any id and
        | either record flag (chop_set_sta is its tail with 43 and record 1) -
        | then (corp D41) chop_snap(T): the engine takes the new STA/END at once,
        | as a sequencer p-lock does, instead of gliding to it.
        | T > 11 returns without writing (12+ is the FX set).
        | UI task only. Clobbers d0/d1/a0/a1, keeps everything else.
        | MK1 since corp D42: its one caller is chop_set_sta (record 0), right
        | here, falling in; MK1 has no END writer.
        | ------------------------------------------------------------------
        .text
        .align  2
        .ifndef DEVICE_MK2
chop_set_sta:                                     | MK1 (D42 fix F-A): id 43, record 0
        movea.w #PARAM_ID_STA,%a0                 | id 43
        suba.l  %a1,%a1                           | record 0: a base value, never a p-lock
        .endif                                    | (falls into chop_put)
chop_put:
        cmpi.l  #PADS-1,%d0
        bhi.s   9f
        lea     -16(%sp),%sp
        movem.l %d2-%d3/%a2-%a3,(%sp)
        move.l  %d0,%d2                           | T
        move.l  %d1,%d3                           | V
        move.l  %a0,%a2                           | id
        move.l  %a1,%a3                           | record
        bsr.s   chop_set_of                       | d0 = T -> track T's SoundParameterSet
        pea     1                                 | notify
        move.l  %a3,-(%sp)                        | record
        move.l  %d2,-(%sp)                        | T
        move.l  %d3,-(%sp)                        | V
        move.l  %a2,-(%sp)                        | id
        move.l  %d0,-(%sp)                        | set
        jsr     param_set_value
        lea     24(%sp),%sp
        move.l  %d2,%d0                           | T, 0..11 (guarded above)
        bsr.s   chop_snap                         | D41: STA and END snap to TARGET
        movem.l (%sp),%d2-%d3/%a2-%a3
        lea     16(%sp),%sp
9:      rts

        | ------------------------------------------------------------------
        | chop_snap(d0 = T) (corp D41, chop-timing-re fix F-1): for track T, STA
        | and then END, do what the audio interrupt's per-trig lock pass does
        | for a p-locked parameter (MK1 0x40119538.., MK2 0x40120954..): STATE =
        | v << 16 first, then EFFECTIVE = v, with v = the TARGET word that
        | param_set_value has just written (its engine writer, MK1 0x401185fa /
        | MK2 0x4011f3fa, stores TARGET and zeroes the slide word, nothing else).
        | Without it the interrupt's smoother moves EFFECTIVE - what the sample
        | voices start from - only 3% of the way to TARGET per run, so the
        | pad's own trig (posted right after) started near the previous marker.
        | Writes exactly four places: STATE[T][STA], STATE[T][END] (longs) and
        | EFFECTIVE[T][STA], EFFECTIVE[T][END] (words); TARGET and the slide
        | word are left as param_set_value wrote them. v is copied, never
        | computed, so LO's floor and the writer's clamp carry over. Engine
        | rows (symbols ENG_TARGET, ENG_STATE, PARAMS_EFF): entry T, cidx c at
        | +84T+2c (TARGET, EFFECTIVE) and +168T+4c (STATE); STA is cidx
        | SND_CIDX_STA (21), END the next one. T > 11 unsigned: nothing.
        | The `bsr.w 1f` runs the body for STA and returns into it for END.
        | MK1 since corp D42 (no END): no `bsr.w 1f`, the body runs once, for
        | STA only - two writes, STATE[T][STA] and EFFECTIVE[T][STA].
        | UI task only. Clobbers d0/d1/a0/a1, keeps everything else.
        | ------------------------------------------------------------------
        .equ    SNAP_TGT,       ENG_TARGET + 2 * SND_CIDX_STA
        .equ    SNAP_STATE,     ENG_STATE + 4 * SND_CIDX_STA
        .equ    SNAP_EFF,       PARAMS_EFF - ENG_TARGET   | EFFECTIVE - TARGET
        .align  2
chop_snap:
        moveq   #PADS-1,%d1
        cmp.l   %d1,%d0
        bhi.s   9f                                | T > 11 unsigned: nothing
        moveq   #84,%d1                           | the row stride (TARGET, EFFECTIVE)
        mulu.w  %d1,%d0                           | 84T
        movea.l %d0,%a0
        adda.l  #SNAP_TGT,%a0                     | &TARGET[T][STA]
        movea.l %d0,%a1
        adda.l  %d0,%a1                           | 168T, STATE's row stride
        adda.l  #SNAP_STATE,%a1                   | &STATE[T][STA]
        .ifdef  CHOP_END
        bsr.w   1f                                | STA; its rts lands on 1: for END
        .endif
1:      move.w  (%a0)+,%d1                        | v = TARGET
        swap    %d1
        clr.w   %d1                               | v << 16
        move.l  %d1,(%a1)+                        | STATE = v << 16, first
        swap    %d1                               | v
        move.w  %d1,SNAP_EFF-2(%a0)               | EFFECTIVE = v
9:      rts

        | chop_set_of(d0 = T) -> d0 = kit_track_param_set(project_kit(
        | project_singleton()), T), track T's SoundParameterSet: the three
        | calls chop_put and chop_held_with each made inline until corp round 7
        | (D29), in the same order with the same arguments. T is not checked
        | here (both callers already refused T > 11). Clobbers d0/d1/a0/a1.
        .align  2
chop_set_of:
        move.l  %d0,-(%sp)                        | T, kit_track_param_set's 2nd argument
        jsr     project_singleton
        move.l  %d0,-(%sp)
        jsr     project_kit                       | project + 232, the active kit
        move.l  %d0,(%sp)                         | kit, over the project
        jsr     kit_track_param_set               | (kit, T)
        addq.l  #8,%sp
        rts

        | chop_locked(d0 = param id) -> Z clear (bne) when the id cannot be
        | p-locked now: bit 8 (0x100) of its RAM record's first long, the test
        | the page view's slot 0x6c makes. param_info(id) with the id pushed as
        | a long, as the four inline copies did (pea id) until corp round 7
        | (D29). Clobbers d0/d1/a0/a1; the flags survive the rts.
        .align  2
chop_locked:
        move.l  %d0,-(%sp)
        jsr     param_info                        | the id's RAM record
        addq.l  #4,%sp
        move.l  %d0,%a0
        move.l  (%a0),%d0
        btst    #8,%d0
        rts

        | ------------------------------------------------------------------
        | chop_next_above(d0 = k 0..11) -> d0 = E: the smallest marker strictly
        | above marker k, or 0x7800 (the sample end) when none is. Clobbers
        | d0/d1/a0/a1.
        | MK2 only since corp D42, as are chop_end_hit, chop_end_restore and
        | chop_end_put below: MK1 has no END mode.
        | ------------------------------------------------------------------
        .ifdef  CHOP_END
        .align  2
chop_next_above:
        move.l  %d2,-(%sp)
        lea     chop_marks,%a0
        mvz.w   0(%a0,%d0.l*2),%d1                | V = M[k]
        move.l  #STA_MAX,%d0                      | none above: the sample end
        lea     2*PADS(%a0),%a1
1:      mvz.w   (%a0)+,%d2
        cmp.l   %d1,%d2
        bls.s   2f                                | M[j] <= V
        cmp.l   %d0,%d2
        bcc.s   2f                                | not closer
        move.l  %d2,%d0
2:      cmpa.l  %a1,%a0
        bcs.s   1b
        move.l  (%sp)+,%d2
        rts

        | ------------------------------------------------------------------
        | chop_end_hit: after a pad's chop_set_sta, with END on, the chop
        | track's END = the slice end of chop_pad, record 1 (under live REC a
        | p-lock, after STA's). END off: returns at once. Clobbers d0/d1/a0/a1.
        | ------------------------------------------------------------------
        .align  2
chop_end_hit:
        tst.b   chop_end
        beq.s   9f
        moveq   #0,%d0
        move.b  chop_pad,%d0
        bsr.s   chop_next_above
        move.l  %d0,%d1                           | E
        movea.w #1,%a1                            | record
        bra.s   chop_end_put                      | T, id 44, chop_put

        | ------------------------------------------------------------------
        | chop_end_restore: while CHOP and END are both on, the chop track's END
        | goes back to 0x7800 (120, the whole sample) with record 0 - a base
        | value, never a p-lock (D20 / r5c skeptic P2: otherwise a later STA
        | above the last slice end leaves STA > END). Otherwise nothing.
        | Clobbers d0/d1/a0/a1.
        | chop_end_put (d1 = the value, a1 = the record flag): the tail both
        | share since corp round 7 (D29): T = chop_track, id 44, chop_put.
        | ------------------------------------------------------------------
        .align  2
chop_end_restore:
        tst.b   chop_on
        beq.s   9f
        tst.b   chop_end
        beq.s   9f
        move.l  #STA_MAX,%d1                      | 0x7800: END's max and default
        suba.l  %a1,%a1                           | record 0
chop_end_put:
        moveq   #0,%d0
        move.b  chop_track,%d0                    | T
        movea.w #PARAM_ID_END,%a0
        bra.w   chop_put
9:      rts
        .endif                                    | CHOP_END (MK2 only)

        | ------------------------------------------------------------------
        | chop_delta_more(d2 = whole steps, non-zero; d3 = the knob, K_END..;
        | a2 = the view): the knobs D..G with no trig held (delta_gate). d2/d3
        | are param_apply_delta's to restore (its epilogue does), so they are
        | free here. Clobbers d0/d1/a0/a1 too; keeps a2.
        |   END: (MK2 only; MK1 has no END knob since corp D42) right on; left
        |        off, and while CHOP is on the chop track's END goes back to
        |        120 first (chop_end_restore).
        |   DIV: 1..12; a change re-chops all twelve markers (chop_rechop); no
        |        change (turned against an end) leaves them alone.
        |   LAY: right: chop_lay; left: nothing.
        |   RND: nothing here (it acts on held steps, through lock_gate).
        | ------------------------------------------------------------------
        .align  2
chop_delta_more:
        .ifdef  CHOP_END
        moveq   #K_END,%d0
        cmp.l   %d0,%d3
        bne.s   2f
        tst.l   %d2                               | END
        ble.s   1f
        moveq   #1,%d0
        move.b  %d0,chop_end                      | right: on
        rts
1:      bsr.s   chop_end_restore                  | left: off
        clr.b   chop_end
        rts
2:
        .endif
        moveq   #K_LAY,%d0
        cmp.l   %d0,%d3
        beq.w   chop_lay                          | LAY: its rts returns to delta_gate
        moveq   #K_DIV,%d0
        cmp.l   %d0,%d3
        bne.s   9f
        moveq   #0,%d0                            | DIV
        move.b  chop_div,%d0
        move.l  %d0,%d3                           | the old value
        add.l   %d2,%d0
        subq.l  #1,%d0
        moveq   #PADS-1,%d1
        bsr.w   clamp                             | 0..11
        addq.l  #1,%d0                            | 1..12
        cmp.l   %d3,%d0
        beq.s   9f                                | unchanged: the markers stay
        move.b  %d0,chop_div
        bra.s   chop_rechop
9:      rts

        | ------------------------------------------------------------------
        | chop_rechop: marker i = ((i mod DIV) * 0x7800) / DIV, i = 0..11, DIV =
        | chop_div (1..12; a 0 would trap divu, so it returns). Pads above DIV
        | repeat slices 0..DIV-1. DIV 12 gives the power-on 0, 10 ... 110; DIV
        | 1, 2, 3, 4, 5, 6, 8, 10, 12 are exact in 8.8, 7, 9, 11 floor (less than
        | 1/256 of a step). RAM only. Clobbers d0/d1/a0/a1.
        | ------------------------------------------------------------------
        .align  2
chop_rechop:
        moveq   #0,%d1
        move.b  chop_div,%d1
        tst.l   %d1
        beq.s   9f
        move.l  %d2,-(%sp)
        lea     chop_marks,%a0
        lea     2*PADS(%a0),%a1
        moveq   #0,%d0                            | j = i mod DIV
1:      move.l  %d0,%d2
        mulu.w  #STA_MAX,%d2                      | <= 11 * 0x7800 = 0x52800
        divu.w  %d1,%d2                           | quotient (< 0x7800) in the low word
        move.w  %d2,(%a0)+
        addq.l  #1,%d0
        cmp.l   %d1,%d0
        bcs.s   2f
        moveq   #0,%d0
2:      cmpa.l  %a1,%a0
        bcs.s   1b
        move.l  (%sp)+,%d2
9:      rts

        | ------------------------------------------------------------------
        | chop_lay(d2 = whole steps; a2 = the view): knob F turned right (D20).
        | Refuses, with no side effect, unless all hold (each test only reads):
        |   d2 > 0 (right); chop_on; T = chop_track <= 11;
        |   track_index_of(project_selection(project)) == T  (the lock store
        |     writes the SELECTED track's pattern; current_track_pattern is it);
        |   tp = current_track_pattern(project) != 0;
        |   euclid_enabled_get(tp) != 1  (in euclid mode the grid remaps steps,
        |     dis:79239-79252, and live REC creates no trig, dis:221955-221966);
        |   (*param_info(43) & 0x100) == 0  (STA lockable, slot 0x6c's test).
        | Then: set = kit_track_param_set(project_kit(project), T); E wanted =
        | END on and id 44 lockable (MK2 only; MK1 never locks END, D42); len =
        | pattern_length(tp); n = min(DIV, len);
        | for i = 0..n-1: s = (i * len) / n; if step_flag_test(tp, s, 1) == 0
        | (an EMPTY step - both stock trig tests 0x400bcfa6 / 0x400bd036 read 0
        | exactly then): trig_create(tp, s, 1), as the grid trig key does, then
        | chop_lock_one(s, set, M[i], E wanted ? slice end of i : -1). A step
        | that holds a trig is never touched. Last, view_refresh_request(view),
        | as the trig key after its create (dis:79538-79539); delta_gate then
        | invalidates the view too. Runs in the UI task (the encoder handler).
        | No undo: turning LAY again adds nothing on the steps it filled, but it
        | does fill steps that are empty by then. Keeps a2; clobbers d0/d1/a0/a1
        | (d2/d3 are restored by param_apply_delta's epilogue anyway).
        | ------------------------------------------------------------------
        .align  2
chop_lay:
        tst.l   %d2
        ble.w   99f                               | left: nothing
        tst.b   chop_on
        beq.w   99f
        lea     -32(%sp),%sp
        movem.l %d2-%d7/%a3-%a4,(%sp)
        moveq   #0,%d7
        move.b  chop_track,%d7                    | T
        moveq   #PADS-1,%d0
        cmp.l   %d0,%d7
        bhi.w   9f                                | 12+ is the FX set
        jsr     project_singleton
        move.l  %d0,%a4                           | P
        move.l  %d0,-(%sp)
        jsr     project_selection                 | P + 48
        move.l  %d0,(%sp)
        jsr     track_index_of                    | the selected track
        addq.l  #4,%sp
        cmp.l   %d7,%d0
        bne.w   9f                                | not the chop track
        move.l  %a4,-(%sp)
        jsr     current_track_pattern             | its pattern track
        addq.l  #4,%sp
        move.l  %d0,%a3                           | tp
        tst.l   %d0
        beq.w   9f
        move.l  %a3,-(%sp)
        jsr     euclid_enabled_get
        addq.l  #4,%sp
        mvs.b   %d0,%d0
        moveq   #1,%d1
        cmp.l   %d1,%d0
        beq.w   9f                                | euclid mode: steps are remapped
        moveq   #PARAM_ID_STA,%d0
        bsr.w   chop_locked
        bne.w   9f                                | 0x100: STA cannot be locked now
        .ifdef  CHOP_END
        moveq   #-1,%d6                           | END wanted: -1 no, 0 yes
        tst.b   chop_end
        beq.s   1f
        moveq   #PARAM_ID_END,%d0
        bsr.w   chop_locked
        bne.s   1f                                | END cannot be locked now
        moveq   #0,%d6
1:
        .endif
        move.l  %a4,-(%sp)
        jsr     project_kit                       | P + 232
        move.l  %d7,(%sp)                         | T
        move.l  %d0,-(%sp)                        | kit
        jsr     kit_track_param_set
        addq.l  #8,%sp
        move.l  %d0,%a4                           | set
        move.l  %a3,-(%sp)
        jsr     pattern_length
        addq.l  #4,%sp
        move.l  %d0,%d5                           | len
        ble.w   9f
        moveq   #0,%d4
        move.b  chop_div,%d4                      | DIV
        cmp.l   %d5,%d4
        bls.s   2f
        move.l  %d5,%d4                           | n = min(DIV, len)
2:      tst.l   %d4
        beq.w   9f
        moveq   #0,%d3                            | i
3:      move.l  %d3,%d2
        mulu.w  %d5,%d2                           | i * len (<= 11 * 64)
        divu.w  %d4,%d2                           | / n
        mvz.w   %d2,%d2                           | s = (i * len) / n, < len
        pea     1
        move.l  %d2,-(%sp)
        move.l  %a3,-(%sp)
        jsr     step_flag_test                    | flag 0x1: a trig is there
        lea     12(%sp),%sp
        tst.b   %d0
        bne.s   5f                                | leave that step alone
        pea     1
        move.l  %d2,-(%sp)
        move.l  %a3,-(%sp)
        jsr     trig_create                       | as the grid trig key
        lea     12(%sp),%sp
        .ifdef  CHOP_END
        move.l  %d6,%d0                           | E: -1, or the slice end of i
        bmi.s   4f
        move.l  %d3,%d0
        bsr.w   chop_next_above
4:      move.l  %d0,-(%sp)                        | E
        .endif
        lea     chop_marks,%a0
        mvz.w   0(%a0,%d3.l*2),%d0
        move.l  %d0,-(%sp)                        | V = M[i]
        move.l  %a4,-(%sp)                        | set
        move.l  %d2,-(%sp)                        | step s
        bsr.w   chop_lock_one
        .ifdef  CHOP_END
        lea     16(%sp),%sp
        .else
        lea     12(%sp),%sp                       | MK1: (step, set, V), no E (D42)
        .endif
5:      addq.l  #1,%d3
        cmp.l   %d4,%d3
        bcs.s   3b
        move.l  %a2,-(%sp)                        | the page view
        jsr     view_refresh_request              | as the trig key, 0x4003d63a
        addq.l  #4,%sp
9:      movem.l (%sp),%d2-%d7/%a3-%a4
        lea     32(%sp),%sp
99:     rts

        | ------------------------------------------------------------------
        | chop_rnd_held: knob G turned with trig key(s) held (lock_gate). While
        | CHOP is on: the step lock (chop_held_with, its six guards and stock's
        | hold sequence) with chop_rnd_step as the invoker. Returns d0 = 0, as
        | lock_gate does for CHOP's other knobs (the caller ignores it).
        | ------------------------------------------------------------------
        .section .cave2,"ax"
        .align  2
chop_rnd_held:
        tst.b   chop_on
        beq.s   9f
        moveq   #0,%d0
        move.b  chop_track,%d0                    | T
        moveq   #0,%d1                            | V: chop_rnd_step picks its own
        lea     chop_rnd_step,%a1
        bsr.w   chop_held_with
9:      moveq   #0,%d0
        rts

        | ------------------------------------------------------------------
        | chop_rnd_step(fn*, step, bool* stop): the RND invoker. i = a random
        | slice 0..DIV-1 (shared_rnd on CHOP's own LCG word, N = 32767, made
        | 0..65534 and taken mod DIV: bias under 1 in 5000); then chop_lock_one
        | (step, set, M[i], E) with E = the slice end of i when fn+16 >= 0 (END
        | on and lockable, chop_held_with), else -1. *stop is left 0.
        | MK1 since corp D42: chop_lock_one(step, set, M[i]), no E.
        | Clobbers d0/d1/a0/a1; keeps d2.
        | ------------------------------------------------------------------
        .align  2
chop_rnd_step:
        move.l  %d2,-(%sp)                        | (sp) d2, 4 ret, 8 fn, 12 step
        lea     chop_rng,%a0
        move.l  #32767,%d1
        jsr     shared_rnd                        | d0 = -32767..32767; d0/d1 only
        add.l   #32767,%d0                        | 0..65534
        moveq   #0,%d1
        move.b  chop_div,%d1                      | 1..12
        bne.s   1f
        moveq   #PADS,%d1                         | (never 0; divu must not trap)
1:      divu.w  %d1,%d0                           | remainder:quotient
        swap    %d0
        mvz.w   %d0,%d2                           | i = 0..DIV-1
        .ifdef  CHOP_END
        moveq   #-1,%d0                           | E: none
        move.l  8(%sp),%a0                        | fn
        tst.l   16(%a0)
        bmi.s   2f
        move.l  %d2,%d0
        bsr.w   chop_next_above                   | the slice end of i
2:      move.l  %d0,-(%sp)                        | E
        .endif
        lea     chop_marks,%a0
        mvz.w   0(%a0,%d2.l*2),%d0
        move.l  %d0,-(%sp)                        | V = M[i]
        .ifdef  CHOP_END
        move.l  16(%sp),%a0                       | fn
        move.l  4(%a0),-(%sp)                     | set
        move.l  24(%sp),-(%sp)                    | step
        bsr.w   chop_lock_one
        lea     16(%sp),%sp
        .else
        move.l  12(%sp),%a0                       | fn: (sp) V, 4 d2, 8 ret, 12 fn, 16 step
        move.l  4(%a0),-(%sp)                     | set
        move.l  20(%sp),-(%sp)                    | step (16(%sp) + 4)
        bsr.w   chop_lock_one                     | MK1: (step, set, V), no E (D42)
        lea     12(%sp),%sp
        .endif
        move.l  (%sp)+,%d2
        rts

        | ------------------------------------------------------------------
        | press_gate (corp D39): the page view's knob-PRESS lock path, vtable
        | slot 0x80 (MK1 0x400384f8, MK2 0x400387ba; the same seven page-view
        | vtables that hold lock_gate's slot 0x7c). The base key handler (MK1
        | 0x4003a320, MK2 0x4003a544) calls it on every fresh press of a knob
        | that has an id (MK1 0x4003a6e8, MK2 0x4003a90c). Stock asks slot 0x6c
        | whether the id can be locked; if so, a scene/perf lock source takes
        | the press, or, with trig(s) held, it marks the hold edited and writes
        | the knob's shown value as a p-lock on every held step. CHOP's ids (and
        | 0008's 1..2 in image B) have container index 0 since their ROM renames,
        | so that p-lock would land in lock slot 0 - the sound's free word, which
        | SMP CUT reads as LCT/HCT. For every id chop_knob maps (>= 0) this gate
        | returns d0 = 0 at once: stock's own early exit when slot 0x6c says the
        | id cannot be locked (MK1 0x40038518 / MK2 0x400387da 'beqw' to the
        | epilogue) - no lock, no lock-source call, no hold_set_edited (stock
        | does not call it on that exit; lock_gate, the turn path for the same
        | ids, does not either). The only caller that reads d0 stores its low
        | byte as the knob's "press locked" flag (MK1 0x4003a6f4, MK2 0x4003a918),
        | and 0 is what stock stores for every knob press with no trig held.
        | Every other id: the displaced prologue, then stock at +8.
        | Entered by a jmp at the entry: (%sp) return, 4 view, 8 id. chop_knob
        | clobbers d0/d1/a0 only; d2-d5/a2-a4 reach the re-emitted moveml as the
        | caller left them. Code only, no state.
        | ------------------------------------------------------------------
        .section .cave2,"ax"
        .align  2
press_gate:
        move.l  8(%sp),%d0
        bsr.w   chop_knob                         | d0 = the knob, or -1
        tst.l   %d0
        bmi.s   9f
        moveq   #0,%d0                            | "cannot be locked": stock's early exit
        rts
9:      lea     -48(%sp),%sp                      | displaced
        movem.l %d2-%d5/%a2-%a4,(%sp)             | displaced
        jmp     press_lock_body

        | (dial_gate, image A's optional D18 detour at param_knob_draw 0x400a587c
        | that drew the CHOP STA knob's dial with stock STA's functor, was
        | removed in corp round 7 (D29, to fit image B): the CHOP STA dial now
        | draws as id 4's own dial, as it did before image A. Its value, text and
        | resolution are unchanged.)

        .ifndef DEVICE_MK2
        | ------------------------------------------------------------------
        | record_gate (corp D42 fix F-B, MK1 only): live REC's trig writer call
        | in the UI loop's note-event handler (0x4009f046), host 0x4009f106
        | 'jsr 0x400b1770' (rec_trig_write, 6 bytes), rejoin 0x4009f10c 'braw
        | 0x4009f396', which pops the 32 bytes of arguments ('lea %sp@(32)').
        | The host reaches the call only under live REC (0x4009f0c8 'jsr
        | 0x4003624c / tstb %d0 / beqs 0x4009f110'). Entered by a jmp with its
        | eight arguments pushed: (%sp) project, 4 the event's track (+8, a
        | sign-extended byte), 8 note, 12 velocity, 16 step (+28, a sign-
        | extended word), 20 micro timing, 24, 28.
        | First the displaced call, re-issued with those same arguments - the
        | trig, exactly as stock (0x400b1770 never writes or takes the address
        | of its argument slots %fp@(8..39), so they are intact after it).
        | Then, only when every guard holds (each one only reads):
        |   chop_on;  the event's track == chop_track (T);
        |   track_index_of(project_selection(project)) == T  (set->vt[0x40]
        |     writes the SELECTED track's pattern; 0x400b1770 used T's);
        |   (*param_info(43) & 0x100) == 0  (STA lockable now, slot 0x6c);
        |   step_flag_test(current_track_pattern(project), s, 1) != 0  (the
        |     trig is on s: 0x400b1770's trig writer 0x400bf648 refuses a step
        |     at or past the pattern length, the lock store 0x400bd5b4 only one
        |     past it, so no lock is ever written without its trig);
        | with s = the step clamped to 0..63 exactly as 0x400b1770 does
        | (0x400b1798..0x400b17a8: below 0 -> 0, above 63 -> 63):
        | chop_lock_one(s, set, M[chop_pad]), set = chop_set_of(T) - STA = the
        | pad's marker as a p-lock on the step the trig was just written to,
        | through 0x400a6bd0 (set->vt[0x40]), the store the step lock and LAY
        | use. Whatever the base STA is. Then the stock continuation. When any
        | guard fails it is the stock call and nothing else.
        | Live after the rejoin: only %sp and %fp (0x4009f396 pops the
        | arguments, 0x4009f24e sets d2, 0x4009f500 restores d2-d7/a2-a5 from
        | the frame); this gate keeps d2-d7/a2-a6 anyway (d2 is saved around
        | its use) and clobbers d0/d1/a0/a1. UI task (the UI loop).
        | Marker = chop_pad when the event is handled (no new state): if the
        | UI handles two pad messages before the first hit's event, that trig
        | gets the later pad's marker (corp chop-locks-re L-T4). A MIDI note
        | into the chop track under live REC with CHOP on gets the marker too.
        | ------------------------------------------------------------------
        .text
        .align  2
record_gate:
        jsr     rec_trig_write                    | displaced: the trig, as stock
        tst.b   chop_on
        beq.w   9f
        moveq   #0,%d0
        move.b  chop_track,%d0                    | T
        cmp.l   4(%sp),%d0                        | == the event's track
        bne.w   9f
        move.l  %d2,-(%sp)                        | (sp) d2, 4.. the host's arguments
        jsr     project_singleton
        move.l  %d0,-(%sp)                        | P: (sp) P, 4 d2, 8.. the arguments
        jsr     project_selection                 | P + 48
        move.l  %d0,-(%sp)
        jsr     track_index_of                    | the selected track
        addq.l  #4,%sp
        cmp.l   12(%sp),%d0                       | == the event's track (4 + 8), == T
        bne.s   8f
        moveq   #PARAM_ID_STA,%d0
        bsr.w   chop_locked                       | STA's RAM record, bit 8
        bne.s   8f                                | 0x100: STA cannot be locked now
        move.l  24(%sp),%d0                       | the step (16 + 8)
        moveq   #63,%d1
        bsr.w   clamp                             | s = 0..63, as 0x400b1798..0x400b17a8
        move.l  %d0,%d2                           | s
        jsr     current_track_pattern             | (P): the selected = T's pattern
        move.l  %d0,(%sp)                         | tp, over P
        pea     1                                 | mask 0x1: a trig
        move.l  %d2,-(%sp)                        | s
        move.l  %d0,-(%sp)                        | tp
        jsr     step_flag_test
        lea     12(%sp),%sp
        tst.b   %d0
        beq.s   8f                                | no trig on s: no lock
        moveq   #0,%d0
        move.b  chop_pad,%d0
        lea     chop_marks,%a0
        mvz.w   0(%a0,%d0.l*2),%d0
        move.l  %d0,(%sp)                         | V = M[chop_pad], 8.8, over tp
        move.l  12(%sp),%d0                       | T
        bsr.w   chop_set_of                       | track T's SoundParameterSet
        move.l  %d0,-(%sp)                        | set
        move.l  %d2,-(%sp)                        | s
        bsr.w   chop_lock_one                     | (s, set, V): STA = V on s
        addq.l  #8,%sp                            | (sp) V
8:      addq.l  #4,%sp                            | drop P / tp / V
        move.l  (%sp)+,%d2
9:      jmp     rec_gate_resume                   | 0x4009f10c, the stock continuation
        .endif

        | ------------------------------------------------------------------
        | Strings (constants): the page's name, the parameters' group name and
        | the knobs' long and short names, which the ROM records point at
        | (registry from_symbol patches) - nothing in the code reads them. The
        | long names end .text (cave2); the page name and the short names follow
        | the descriptor in .cave3.
        | ------------------------------------------------------------------
        .text
str_pad_l:      .asciz  "Chop Pad"
str_sta_l:      .asciz  "Pad Start"
str_chp_l:      .asciz  "Chop Mode"
        .ifdef  CHOP_END
str_end_l:      .asciz  "Slice End"
        .endif
str_div_l:      .asciz  "Divide"
str_lay_l:      .asciz  "Lay Out"
str_rnd_l:      .asciz  "Shuffle"

        .section .cave3,"aw"
str_page:
str_group:      .asciz  "CHOP"
str_pad:        .asciz  "PAD"
str_sta:        .asciz  "STA"
str_chp:        .asciz  "CHP"
        .ifdef  CHOP_END
str_end:        .asciz  "END"
        .endif
str_div:        .asciz  "DIV"
str_lay:        .asciz  "LAY"
str_rnd:        .asciz  "RND"

        | ------------------------------------------------------------------
        | Run-time state, RAM only, at the end of .chst in `cave` (after every
        | entry point: build.py refuses an odd entry). The image bytes are the
        | power-on defaults; nothing is saved.
        | MK1 since corp D42: no chop_end; chop_div takes its byte, so the
        | markers stay word-aligned (44 B instead of 48).
        | ------------------------------------------------------------------
        .section .chst,"awx"
        .align  4
chop_state:
chop_on:        .byte   0                         | CHOP mode
chop_track:     .byte   0                         | the chop track, 0..11
chop_pad:       .byte   0                         | the marker PAD/STA edit, 0..11
        .ifdef  CHOP_END
chop_end:       .byte   0                         | END mode (knob D), 0/1
        .else
chop_div:       .byte   12                        | DIV (knob E), 1..12
        .endif
chop_marks:                                       | 8.8, 0..0x7800: 0, 10, 20 ... 110
        .word   0x0000, 0x0a00, 0x1400, 0x1e00, 0x2800, 0x3200
        .word   0x3c00, 0x4600, 0x5000, 0x5a00, 0x6400, 0x6e00
chop_route:                                       | per pad: where its note-on went
        .byte   0xff, 0xff, 0xff, 0xff, 0xff, 0xff | (the chop track), 0xFF = stock
        .byte   0xff, 0xff, 0xff, 0xff, 0xff, 0xff
        .ifdef  CHOP_END
chop_div:       .byte   12                        | DIV (knob E), 1..12
        .endif
        .align  4
chop_rng:       .long   0x5eed0001                | RND's own LCG word (shared_rnd)
