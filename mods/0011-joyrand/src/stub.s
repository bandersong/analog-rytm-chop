        | Mod 0011 - JOY RANDOM: random joystick assignments for the Analog Keys, OS 1.56
        | (corp joyrand, TRUTH K9; `make DEVICE=keys joy` with 0010-chord, `make DEVICE=keys
        | joy-min` alone). Analog Keys only.
        |
        | Hold FUNCTION and press OCTAVE DOWN (key code 165). The active track's joystick
        | assignments are rolled through the same two stock setters the SOUND SETTINGS menus
        | call for one edit (setParam, setDepth on the controller's SoundModConf):
        |   PITCH BEND (sideways)  slots 2-5 (slot 1, stock PMX = the bend itself, is kept)
        |   MOD WHEEL (up)         slots 1-5
        |   BREATH (down)          slots 1-5
        | Each rolled slot gets a destination from this mod's pool for the track type (synth
        | 53 ids, FX 38 ids: the menu's own picker list minus pitch-family, stepped,
        | note-start-only, volume and feedback parameters - design.md) and a depth of
        | 24..63 whole units with a random sign, stored as the menu stores it (units << 8).
        | No destination repeats within one controller (PITCH BEND's kept slot 1 counts).
        | Then the popup "JOY: RANDOM". AFTERTOUCH and VELOCITY are never touched. A CV
        | track only shows "JOY: NOT ON CV". Nothing is saved: [NO/RELOAD] + [SOUND] (stock
        | quick reload) brings the saved assignments back; a kit save keeps the roll.
        |
        | The gesture has no stock function: with FUNCTION held, stock sends OCTAVE DOWN to
        | the base view handler 0x4005fa6e (both branches, 0x400ba008 and 0x400ba338), which
        | acts only on codes 80/81/82 and returns 0. That still happens after the roll.
        |
        | Random numbers: stock rand() 0x400923e4 (the one stock's RND PAGE uses from this
        | same UI task). Its state is never written here; stock zeroes it at reset
        | (0x40000f86) and never seeds it (design.md: why no tick seed).
        |
        | Hook (registry/allocations_keys.toml, owner 0011-joyrand):
        |   0x400b9e66  KeyboardView::handleKey, 'cmpil #165,%d3' -> joy_key_gate
        | No run-time state: the image bytes here are code and constants only.

        .ifndef DEVICE_KEYS
        .error  "0011-joyrand is Analog Keys code: build it with make DEVICE=keys joy"
        .endif

        .include "symbols.inc"

        | KeyEvent (vtable 0x4017a0b8 '8KeyEvent'): +12 the key code, +16 the flags
        .equ    EV_FLAGS,       16
        .equ    EV_DOWN,        1                 | bit 0: pressed (0x400599b6)
        .equ    EV_FUNC,        2                 | bit 1: FUNCTION held (0x400599f2)
        .equ    EV_REPEAT,      8                 | bit 3: held repeat (0x400599c2)
        | KeyboardView (ctor 0x400b85d4): +108 UIStates, the popup's owner
        .equ    KV_UISTATES,    108
        | tracks as sel_track numbers them: 0..3 synth, 4 FX, 5 CV (the getters' own split)
        .equ    TRK_FX,         4
        .equ    TRK_CV,         5
        | a bound SoundModConf has 5 slots (count 0x4001ef3c)
        .equ    SMC_SLOTS,      5
        | depth: |d| = DEP_MIN .. DEP_MIN+DEP_SPAN-1 whole units, sign from bit 14 of the draw
        .equ    DEP_MIN,        24
        .equ    DEP_SPAN,       40
        .equ    DEP_NEG,        0x4000
        | joy_roll's frame: used[5] (the container index of each slot's destination so far)
        | at 0, the 10 saved registers at 20..60
        .equ    USED,           0
        .equ    SAVE,           20
        .equ    FRAME,          60
        | the pool sizes (pool_synth / pool_fx below; checked at the end of this file)
        .equ    N_SYNTH,        53
        .equ    N_FX,           38

        .section .text
        | ------------------------------------------------------------------
        | joy_key_gate: KeyboardView::handleKey 0x400b9de2 at 0x400b9e66, reached only by
        | falling through 'beqw 0x400b9ef2' at 0x400b9e62 (codes above 162 that are not
        | 164; with 0010-chord, chord_key_gate's jmp to 0x400b9e62 comes the same way).
        | Live: d3 = the key code, d2 = the KeyEvent, a2 = the KeyboardView. d0/d1/a0/a1
        | are dead here and at both continuations (0x400b9f9c writes d0 first and calls
        | before reading d1/a0/a1; 0x400ba13e pushes d2/a2 and calls). Kept: d2-d7, a2-a6.
        | FUNCTION + OCTAVE DOWN, press (down, FUNCTION, not a repeat - the test 0010's
        | gate and the base handler make) -> joy_roll. Then always the stock path: the
        | re-emitted compare sets the condition codes 'beqw 0x400b9f9c' at the rejoin reads.
        | ------------------------------------------------------------------
        .align  2
joy_key_gate:
        cmpi.l  #KEY_OCT_DOWN,%d3
        bne.s   9f                                | not OCTAVE DOWN: stock
        move.l  %d2,%a0
        move.l  EV_FLAGS(%a0),%d0
        moveq   #EV_DOWN+EV_FUNC+EV_REPEAT,%d1
        and.l   %d1,%d0
        moveq   #EV_DOWN+EV_FUNC,%d1
        cmp.l   %d1,%d0
        bne.s   9f                                | no FUNCTION, a release or a repeat: stock
        bsr.w   joy_roll
9:      cmpi.l  #165,%d3                          | displaced
        jmp     kv_key_cmp165_resume              | 0x400b9e6c: 'beqw 0x400b9f9c'

        | ------------------------------------------------------------------
        | joy_roll (a2 = the KeyboardView). The track and its kit the way the SOUND
        | SETTINGS menus get them (0x400e00a2..0x400e01ca): proj = proj_singleton(),
        | T = sel_track(proj_sel(proj)), kit = proj_kit(proj), then the controller's
        | getter (kit, T). The getters map any T above 5 to sound 0, so T is checked
        | first. Each controller object must carry the SoundModConf vtable (so slots
        | 0x48/0x54/0x58/0x5c are the verified count/setParam/getParam/setDepth) and be
        | bound (count 5); otherwise it is skipped. Keeps d2-d7/a2-a6.
        |   d2 k (pool position), d3 i (slot), d4 slots written, d5 n (pool size),
        |   d6 T, d7 proj then kit, a3 ctl_tab cursor, a4 pool, a5 the SoundModConf.
        | ------------------------------------------------------------------
        .align  2
joy_roll:
        lea     -FRAME(%sp),%sp
        movem.l %d2-%d7/%a2-%a5,SAVE(%sp)
        jsr     proj_singleton                    | 0x4012e890()
        move.l  %d0,%d7                           | proj
        move.l  %d0,-(%sp)
        jsr     proj_sel                          | 0x400a21f6(proj) = proj+48
        move.l  %d0,(%sp)
        jsr     sel_track                         | 0x400aab78(sel): the active track T
        addq.l  #4,%sp
        move.l  %d0,%d6
        moveq   #TRK_CV,%d0
        cmp.l   %d6,%d0
        bcs.w   70f                               | unsigned: T above 5 - nothing to roll
        bne.s   1f
        lea     str_cv,%a0                        | CV: the popup only
        bra.w   80f
1:      lea     pool_synth,%a4
        moveq   #N_SYNTH,%d5
        moveq   #TRK_FX,%d0
        cmp.l   %d6,%d0
        bne.s   2f
        lea     pool_fx,%a4                       | the FX track: FX destinations
        moveq   #N_FX,%d5
2:      move.l  %d7,-(%sp)
        jsr     proj_kit                          | 0x400a222e(proj) = proj+244
        addq.l  #4,%sp
        move.l  %d0,%d7                           | kit
        moveq   #0,%d4
        lea     ctl_tab,%a3

10:     move.l  (%a3)+,%a0                        | the controller's getter
        move.l  (%a3)+,%d3                        | its first rolled slot
        move.l  %d6,-(%sp)
        move.l  %d7,-(%sp)
        jsr     (%a0)                             | getter(kit, T)
        addq.l  #8,%sp
        move.l  %d0,%a5
        tst.l   %d0
        beq.w   30f
        move.l  (%a5),%d0
        cmpi.l  #smc_vtable,%d0
        bne.w   30f                               | not a SoundModConf: skipped
        move.l  %a5,-(%sp)
        jsr     smc_count                         | 0x4001ef3c: 5 when its data is bound
        addq.l  #4,%sp
        moveq   #SMC_SLOTS,%d1
        cmp.l   %d0,%d1
        bne.w   30f                               | unbound: skipped
        moveq   #0,%d2                            | used[j] for the kept slots j < first:
11:     cmp.l   %d3,%d2                           | their destination's index (getParam,
        bge.s   20f                               | signed byte, -1 when none)
        move.l  %d2,-(%sp)
        move.l  %a5,-(%sp)
        jsr     smc_get_param                     | 0x4001efde(this, slot)
        addq.l  #8,%sp
        move.l  %d0,USED(%sp,%d2.l*4)
        addq.l  #1,%d2
        bra.s   11b

20:     jsr     stock_rand                        | 0x400923e4: 0..32767
        divu.w  %d5,%d0                           | n <= 255: the quotient fits a word
        clr.w   %d0
        swap    %d0                               | rand() % n
        move.l  %d0,%d2                           | k
21:     moveq   #0,%d0
        move.b  0(%a4,%d2.l),%d0                  | pool[k]: a parameter id
        move.l  %d0,-(%sp)
        jsr     param_index                       | 0x4000735a(id): the index setParam stores
        addq.l  #4,%sp
        moveq   #0,%d1                            | j
22:     cmp.l   %d3,%d1
        bge.s   24f                               | not used by slots 0..i-1
        cmp.l   USED(%sp,%d1.l*4),%d0
        beq.s   23f
        addq.l  #1,%d1
        bra.s   22b
23:     addq.l  #1,%d2                            | taken: the next pool entry
        cmp.l   %d5,%d2
        bcs.s   21b
        moveq   #0,%d2                            | (wrapping; at most 4 are taken, n >= 38)
        bra.s   21b
24:     move.l  %d0,USED(%sp,%d3.l*4)             | used[i] = its index
        moveq   #0,%d0
        move.b  0(%a4,%d2.l),%d0
        move.l  %d0,-(%sp)                        | id
        move.l  %d3,-(%sp)                        | slot
        move.l  %a5,-(%sp)
        jsr     smc_set_param                     | 0x4001f17e(this, slot, id)
        lea     12(%sp),%sp
        jsr     stock_rand
        move.l  %d0,%d2                           | the draw: magnitude and sign
        moveq   #DEP_SPAN,%d1
        divu.w  %d1,%d0
        clr.w   %d0
        swap    %d0                               | rand() % 40
        addi.l  #DEP_MIN,%d0                      | 24..63
        andi.l  #DEP_NEG,%d2
        beq.s   25f
        neg.l   %d0                               | -63..-24
25:     lsl.l   #8,%d0                            | whole units in the high byte, as the menu
        move.l  %d0,-(%sp)                        | writes them (0x40036720..0x40036724)
        move.l  %d3,-(%sp)
        move.l  %a5,-(%sp)
        jsr     smc_set_depth                     | 0x4001f032(this, slot, depth)
        lea     12(%sp),%sp
        addq.l  #1,%d4
        addq.l  #1,%d3
        moveq   #SMC_SLOTS,%d0
        cmp.l   %d0,%d3
        blt.w   20b

30:     cmpa.l  #ctl_end,%a3
        bne.w   10b
        lea     str_rnd,%a0
        tst.l   %d4
        bne.s   80f
70:     lea     str_none,%a0
80:     move.l  %a0,-(%sp)
        move.l  KV_UISTATES(%a2),-(%sp)
        jsr     ui_popup                          | 0x40021774(UIStates, text)
        addq.l  #8,%sp
        movem.l SAVE(%sp),%d2-%d7/%a2-%a5
        lea     FRAME(%sp),%sp
        rts

        | ------------------------------------------------------------------
        | Constants.
        | ------------------------------------------------------------------
        .align  2
ctl_tab:
        .long   kit_pb_conf, 1                    | PITCH BEND: slot 1 kept, 2-5 rolled
        .long   kit_mw_conf, 0                    | MOD WHEEL: 1-5
        .long   kit_bc_conf, 0                    | BREATH: 1-5
ctl_end:

        | The pools (corp joyrand-re pools.out; re-derived from the ROM walk by the
        | builder, design.md): every id is in the menu's own picker list for its track
        | type (0x4009e13e, type 1 synth / 7 FX, mask 0x200), its container index is at
        | most 111 and the stock index->id map gives the id back, so setParam(slot, id)
        | stores exactly what the menu's edit of that destination stores.
pool_synth:
        .byte   42, 44, 47, 48, 49, 55, 57, 60, 61, 62, 67, 72
        .byte   73, 74, 75, 76, 77, 78, 79, 81, 82, 83, 84, 86
        .byte   88, 89, 90, 91, 92, 94, 95, 96, 97, 100, 101, 102
        .byte   103, 107, 109, 110, 111, 112, 113, 117, 119, 120, 122, 127
        .byte   129, 130, 132, 137, 139
pool_synth_end:
pool_fx:
        .byte   141, 142, 143, 144, 146, 147, 148, 149, 151, 152, 153, 154
        .byte   156, 157, 158, 159, 160, 161, 163, 165, 166, 168, 169, 170
        .byte   171, 172, 173, 174, 175, 176, 177, 179, 184, 186, 187, 189
        .byte   194, 196
pool_fx_end:
        .if     (pool_synth_end - pool_synth) - N_SYNTH
        .error  "pool_synth does not hold N_SYNTH ids"
        .endif
        .if     (pool_fx_end - pool_fx) - N_FX
        .error  "pool_fx does not hold N_FX ids"
        .endif

        | the popups (each under the popup's 32 characters)
str_rnd:  .asciz "JOY: RANDOM"
str_cv:   .asciz "JOY: NOT ON CV"
str_none: .asciz "JOY: NO CHANGE"
