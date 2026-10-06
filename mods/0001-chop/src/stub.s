        | Mod 0001 - CHOP: a second SAMPLE page that turns the twelve pads into
        | twelve sample-start markers for one track.
        |
        | On the SAMPLE view, a press of SAMPLE switches SAMP <-> CHOP (on its
        | release). Not a quick double-tap: a second press inside stock's
        | double-tap window is stock's sample-list shortcut and stays stock, so
        | press, let go, pause, press again. Knobs A..C (D..H are blank):
        |   PAD  1..12    the marker being edited (a pad hit in CHOP also sets it)
        |   STA  0..120   that marker: a sample start on stock's STA scale
        |   CHP  OFF/ON   turning it right switches CHOP on for the track that is
        |                 selected at that moment (the chop track); left, off
        |
        | While CHOP is on, pad k (0..11) does three things, in the UI task, before
        | stock sees the pad: chop_pad = k; the chop track's STA is set to marker k
        | through the call a STA knob turn ends in, param_set_value(set, 43, V<<8, T,
        | 1, 1), so under live REC stock writes a normal STA p-lock; and the pad's id
        | in the UI message is rewritten to the chop track, so stock plays (and
        | records) the chop track exactly as if its own pad had been hit. Pads never
        | switch the selected track away from it, and no fire call is hand-built.
        | With trig key(s) of the chop track held (D15), the STA call is replaced
        | by what stock's hold-trig + turn-STA does: an STA p-lock = marker k on
        | every held step (chop_held_lock); the base STA is then left alone.
        | Note-offs follow their note-ons (D8a): the note-on records where pad k
        | went in chop_route[k] (the chop track, or 0xFF when it was not
        | rewritten), and the note-off of pad k is rewritten to chop_route[k] when
        | that is not 0xFF, which then goes back to 0xFF - whatever chop_on is at
        | the release. Pad ids outside 0..11 touch no table: stock, byte for byte.
        |
        | State is RAM only (the 28 bytes at the end of this block; the image bytes
        | are the power-on defaults). Nothing is saved. CHOP mode is the flag chop_on,
        | not "the CHOP page is on screen", so no view pointer is ever kept.
        |
        | Every gate below that 0008 also has (page_info / get / delta / text) keeps
        | 0008's entry frame, displaced instructions, rejoin label and epilogue
        | verbatim (mods/0008-sample-cut/stub.s). Addresses and receipts: design.md.

        .include "symbols.inc"

        .equ    PAGE_SAMP,      4
        .equ    PAGE_CHOP,      11                | MK1 pages are 0..10 (page_info's moveq #10)
        .equ    ID_PAD,         3                 | dead Error records 3..5
        .equ    ID_STA,         4
        .equ    ID_CHP,         5
        .equ    PADS,           12
        .equ    STA_MAX,        120
        .equ    SAMP_KEY,       50                | the SAMPLE key's code (0x400ce2e0 moveq #50)
        .equ    VIEW_KEY,       136               | view +136: the view's own page key
        .equ    VIEW_SEL,       116               | view +116: the track selection (= project + 48)
        .equ    VIEW_POPUP,     512               | SAMP view +512: weak pointer to its list popup

        .text

        | ------------------------------------------------------------------
        | page_info, answering PAGE_CHOP. 0008's gate verbatim.
        | Entered by a jmp at the entry: (%sp) return, 4(%sp) the page id.
        | ------------------------------------------------------------------
        .align  2
page_info_gate:
        moveq   #PAGE_CHOP,%d0
        cmp.l   4(%sp),%d0
        bne.s   1f
        lea     page_chop,%a0
        move.l  %a0,%d0
        rts
1:      moveq   #10,%d1                           | displaced
        move.l  %sp@(4),%d0                       | displaced
        jmp     page_info_resume

        | ------------------------------------------------------------------
        | page_get_value for ids 3..5: the dials, value << 8.
        | Entered by a jmp at the entry: (%sp) return, 4 view, 8 id, 12 lock.
        | ------------------------------------------------------------------
        .align  2
get_gate:
        move.l  8(%sp),%d0
        subq.l  #ID_PAD,%d0
        moveq   #2,%d1
        cmp.l   %d1,%d0
        bhi.s   9f
        bsr.w   chop_value                        | d0 = 0..2 -> shown value
        lsl.l   #8,%d0
        rts
9:      lea     %sp@(-12),%sp                     | displaced
        moveml  %d2-%d3/%a2,%sp@                  | displaced
        jmp     page_get_value_body

        | ------------------------------------------------------------------
        | param_apply_delta for ids 3..5: the knobs, RAM only.
        |
        | Reached by a jmp over `mvzb %d3,%d3; movel %a2@(116),%sp@-`, past the
        | prologue (and past 0003's gate, which rejoins here): %sp@(0..11) holds
        | d2/d3/a2, a2 is the view, %sp@(20) the id, %sp@(24) the delta in 8.8.
        | Handling the id and returning means stock never writes a sound or a
        | p-lock for it.
        | ------------------------------------------------------------------
        .align  2
delta_gate:
        move.l  %sp@(20),%d0
        subq.l  #ID_PAD,%d0
        moveq   #2,%d1
        cmp.l   %d1,%d0
        bhi.w   9f
        move.l  %sp@(24),%d2
        asr.l   #8,%d2                            | whole steps, sign preserved
        beq.w   7f
        move.l  %d0,%d3                           | 0 PAD, 1 STA, 2 CHP
        bne.s   2f
        moveq   #0,%d0                            | PAD: 0..11 (shown 1..12)
        move.b  chop_pad,%d0
        add.l   %d2,%d0
        moveq   #PADS-1,%d1
        bsr.w   clamp
        move.b  %d0,chop_pad
        bra.s   6f
2:      subq.l  #1,%d3
        bne.s   3f
        moveq   #0,%d1                            | STA: marker[chop_pad], 0..120
        move.b  chop_pad,%d1
        lea     chop_marks,%a0
        adda.l  %d1,%a0
        moveq   #0,%d0
        move.b  (%a0),%d0
        add.l   %d2,%d0
        moveq   #STA_MAX,%d1
        bsr.w   clamp                             | keeps a0
        move.b  %d0,(%a0)
        bra.s   6f
3:      tst.l   %d2                               | CHP
        bgt.s   4f
        clr.b   chop_on                           | left: off
        bra.s   6f
4:      move.l  VIEW_SEL(%a2),-(%sp)              | right: on, for the selected track
        jsr     track_index_of                    | as stock at 0x400376e6..ea
        addq.l  #4,%sp
        moveq   #PADS-1,%d1
        cmp.l   %d1,%d0
        bhi.s   6f                                | FX (12) or worse: never latched
        move.b  %d0,chop_track
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
        | param_value_text for ids 3..5: the popup, a number or OFF/ON.
        |
        | Reached by a jmp over `movel %sp@(32),%d2; movel %sp@(36),%d3`, past the
        | prologue (and past 0002's and 0003's text gates): %sp@(0..19) holds
        | d2-d4/a2-a3, d4 is the id, %sp@(36) the output buffer.
        | ------------------------------------------------------------------
        .align  2
text_gate:
        move.l  %d4,%d0
        subq.l  #ID_PAD,%d0
        moveq   #2,%d1
        cmp.l   %d1,%d0
        bhi.w   9f
        move.l  %sp@(36),%a1
        cmp.l   %d1,%d0
        beq.s   2f
        bsr.w   chop_value                        | keeps a1
        bsr.w   put_u3
        bra.s   5f
2:      tst.b   chop_on
        beq.s   3f
        move.b  #0x4f,(%a1)+                      | ON
        move.b  #0x4e,(%a1)+
        bra.s   5f
3:      move.b  #0x4f,(%a1)+                      | OFF
        move.b  #0x46,(%a1)+
        move.b  #0x46,(%a1)+
5:      clr.b   (%a1)
        movem.l (%sp),%d2-%d4/%a2-%a3             | param_value_text's epilogue
        lea     20(%sp),%sp
        rts
9:      movel   %sp@(32),%d2                      | displaced
        movel   %sp@(36),%d3                      | displaced
        jmp     param_value_text_args

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
        | on exactly as before: chop_set_sta(T, V), record 1. Either way the
        | rewrite and the stock continuation follow.
        | ------------------------------------------------------------------
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
        moveq   #0,%d1
        move.b  0(%a0,%d0.l),%d1                  | V = marker k
        moveq   #0,%d0
        move.b  chop_track,%d0                    | T
        bsr.w   chop_held_lock                    | d0 = 1: held steps locked
        tst.l   %d0
        bne.s   2f                                | D15a: locked, no chop_set_sta
        moveq   #0,%d0                            | reload: the helper clobbers
        move.b  chop_pad,%d0                      | d0/d1/a0/a1
        lea     chop_marks,%a0
        moveq   #0,%d1
        move.b  0(%a0,%d0.l),%d1                  | V = marker k (k = chop_pad)
        moveq   #0,%d0
        move.b  chop_track,%d0                    | T
        bsr.w   chop_set_sta
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
        | param_apply_delta when a trig is held (0x4003a024). For ids 3..5 it
        | returns 0 - what stock returns when slot 0x6c says the id cannot be
        | locked - so a CHOP knob never writes a p-lock. Every other id: stock.
        | Entered by a jmp at the entry: (%sp) return, 4 view, 8 id, 12 delta.
        | ------------------------------------------------------------------
        .align  2
lock_gate:
        move.l  8(%sp),%d0
        subq.l  #ID_PAD,%d0
        moveq   #2,%d1
        cmp.l   %d1,%d0
        bhi.s   9f
        moveq   #0,%d0
        rts
9:      lea     -48(%sp),%sp                      | displaced
        movem.l %d2-%d7/%a2-%a3,(%sp)             | displaced
        jmp     lock_delta_body

        | ------------------------------------------------------------------
        | chop_set_sta(d0 = track T, d1 = marker V 0..120): what a STA knob turn
        | ends in, for track T: set = kit_track_param_set(project_kit(project), T),
        | then param_set_value(set, 43, V << 8, T, 1 record, 1 notify) - the same
        | call stock makes at 0x4008ba12..0x4008ba54 (with id 0x29 there). T > 11
        | returns without writing: 0x400a39fa maps 12 and up to the FX set.
        | UI task only. Clobbers d0/d1/a0/a1, keeps everything else.
        | ------------------------------------------------------------------
        .align  2
chop_set_sta:
        cmpi.l  #PADS-1,%d0
        bhi.s   9f
        lea     -8(%sp),%sp
        movem.l %d2-%d3,(%sp)
        move.l  %d0,%d2                           | T
        move.l  %d1,%d3                           | V
        jsr     project_singleton
        move.l  %d0,-(%sp)
        jsr     project_kit                       | project + 232, the active kit
        addq.l  #4,%sp
        move.l  %d2,-(%sp)                        | T
        move.l  %d0,-(%sp)                        | kit
        jsr     kit_track_param_set               | d0 = track T's SoundParameterSet
        addq.l  #8,%sp
        pea     1                                 | notify
        pea     1                                 | record: a p-lock under live REC
        move.l  %d2,-(%sp)                        | T
        lsl.l   #8,%d3
        move.l  %d3,-(%sp)                        | V, 8.8
        pea     PARAM_ID_STA                      | 43
        move.l  %d0,-(%sp)                        | set
        jsr     param_set_value
        lea     24(%sp),%sp
        movem.l (%sp),%d2-%d3
        lea     8(%sp),%sp
9:      rts

        | ------------------------------------------------------------------
        | chop_held_lock(d0 = T, d1 = V 0..120) -> d0 = 1 locked / 0 nothing.
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
        | the trig); hold_each_step(S, &fn, 0) with a 16-byte stack functor
        | {+0 V<<8, +4 set, +8 manager (non-null; never called), +12
        | chop_lock_step}, set = kit_track_param_set(project_kit(project), T);
        | hold_clear_actions(S); return 1. Stock's own functor is heap-backed
        | and destroyed by 0x40146854; this one holds its data inline, the
        | iterator never copies, destroys or calls the manager (0x40036888,
        | 0x400368bc..0x400368dc), so nothing is allocated or freed.
        | UI task only. Clobbers d0/d1/a0/a1; keeps d2-d7/a2-a6.
        | ------------------------------------------------------------------
        .align  2
chop_held_lock:
        lea     -28(%sp),%sp                      | 12 saved + 16 functor at 12(%sp)
        movem.l %d2-%d3/%a2,(%sp)
        move.l  %d0,%d2                           | T
        move.l  %d1,%d3                           | V
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
        pea     PARAM_ID_STA
        jsr     param_info                        | STA's RAM record
        addq.l  #4,%sp
        move.l  %d0,%a0
        move.l  (%a0),%d0
        btst    #8,%d0
        bne.w   8f                                | 0x100: STA cannot be locked now
        jsr     project_singleton
        move.l  %d0,-(%sp)
        jsr     project_kit
        move.l  %d2,(%sp)                         | T
        move.l  %d0,-(%sp)                        | kit
        jsr     kit_track_param_set               | track T's SoundParameterSet
        addq.l  #8,%sp
        lsl.l   #8,%d3
        move.l  %d3,12(%sp)                       | fn+0  V << 8 (8.8, as the knob)
        move.l  %d0,16(%sp)                       | fn+4  set
        lea     chop_fn_mgr,%a0
        move.l  %a0,20(%sp)                       | fn+8  manager: non-null
        lea     chop_lock_step,%a0
        move.l  %a0,24(%sp)                       | fn+12 invoker
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
        lea     28(%sp),%sp
        rts

        | chop_lock_step(fn*, step, bool* stop): set->vt[0x40](set, 43, V<<8,
        | step) = 0x400a6bd0, the writer stock's slot 0x74 tail-jumps to. *stop
        | is left 0 (the iterator clears it once), so every held step is
        | visited. Clobbers d0/d1/a0/a1 only.
        .align  2
chop_lock_step:
        move.l  4(%sp),%a0                        | fn
        move.l  8(%sp),-(%sp)                     | step
        move.l  (%a0),-(%sp)                      | V << 8
        pea     PARAM_ID_STA                      | 43
        move.l  4(%a0),%a1
        move.l  %a1,-(%sp)                        | set
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
        | chop_value(d0 = 0 PAD, 1 STA, 2 CHP) -> d0 = what the knob shows.
        | Clobbers d0/d1/a0.
        | ------------------------------------------------------------------
        .align  2
chop_value:
        tst.l   %d0
        bne.s   1f
        moveq   #0,%d0
        move.b  chop_pad,%d0
        addq.l  #1,%d0                            | 1..12
        rts
1:      subq.l  #1,%d0
        bne.s   2f
        moveq   #0,%d1
        move.b  chop_pad,%d1
        lea     chop_marks,%a0
        move.b  0(%a0,%d1.l),%d0                  | 0..120 (d0 is 0 here)
        rts
2:      moveq   #0,%d0
        move.b  chop_on,%d0                       | 0/1
        rts

        | clamp(d0, d1 = max) -> d0 in 0..max. Clobbers nothing else.
        .align  2
clamp:  tst.l   %d0
        bpl.s   1f
        clr.l   %d0
1:      cmp.l   %d1,%d0
        ble.s   2f
        move.l  %d1,%d0
2:      rts

        | put_u3(d0 = 0..999, a1 = out) - decimal, no leading zeros. Clobbers
        | d0/d1, advances a1. 0008's helper verbatim.
        .align  2
put_u3:
        move.l  %d2,-(%sp)
        moveq   #0,%d2                            | a digit has been printed
        divu.w  #100,%d0
        mvzw    %d0,%d1                           | hundreds
        beq.s   1f
        add.l   #0x30,%d1
        move.b  %d1,(%a1)+
        moveq   #1,%d2
1:      clr.w   %d0
        swap    %d0
        divu.w  #10,%d0
        mvzw    %d0,%d1                           | tens
        tst.l   %d2
        bne.s   2f
        tst.l   %d1
        beq.s   3f
2:      add.l   #0x30,%d1
        move.b  %d1,(%a1)+
3:      swap    %d0
        mvzw    %d0,%d1                           | units
        add.l   #0x30,%d1
        move.b  %d1,(%a1)+
        move.l  (%sp)+,%d2
        rts

        | ------------------------------------------------------------------
        | Data
        | ------------------------------------------------------------------
        .align  2
chop_pages:                                       | the SAMP view's pages
        .long   PAGE_SAMP, PAGE_CHOP

page_chop:                                        | {name, top row, bottom row}
        .long   str_page
        .long   ID_PAD, ID_STA, ID_CHP, 0
        .long   0, 0, 0, 0

        | One label, two uses: the page's name and the parameters' group name.
str_page:
str_group:      .asciz  "CHOP"
str_pad_l:      .asciz  "Chop Pad"
str_sta_l:      .asciz  "Pad Start"
str_chp_l:      .asciz  "Chop Mode"
str_pad:        .asciz  "PAD"
str_sta:        .asciz  "STA"
str_chp:        .asciz  "CHP"

        | ------------------------------------------------------------------
        | Run-time state, RAM only, after every entry point (build.py refuses an
        | odd entry). The image bytes are the power-on defaults; nothing is saved.
        | ------------------------------------------------------------------
        .align  4
chop_state:
chop_on:        .byte   0                         | CHOP mode
chop_track:     .byte   0                         | the chop track, 0..11
chop_pad:       .byte   0                         | the marker PAD/STA edit, 0..11
chop_rsv:       .byte   0
chop_marks:     .byte   0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 110
chop_route:                                       | per pad: where its note-on went
        .byte   0xff, 0xff, 0xff, 0xff, 0xff, 0xff | (the chop track), 0xFF = stock
        .byte   0xff, 0xff, 0xff, 0xff, 0xff, 0xff
