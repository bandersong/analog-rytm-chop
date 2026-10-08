        | Mod 0010 - CHORD: chord memory for the Analog Keys, OS 1.56 (corp Keys chord
        | memory, TRUTH K1-K5 and K7; `make DEVICE=keys chord`). Analog Keys only.
        |
        | Capture: hold 2..4 keys on the keybed, then hold FUNCTION and press OCTAVE
        | UP (key code 164). The held keys become the chord: each held key counts with
        | the note it was pressed at (chord_root below, K7 c - never its chord tones),
        | root = the lowest, intervals = the others minus the root (at most 4 notes
        | including the root, each at most 63 semitones above it), chord mode ON, popup
        | "CHORD ON: 0 4 7". Only held (state 1) internal-track notes of the active
        | track count; HOLD-latched notes never do (K7 a/b). The same gesture:
        |   - with nothing in KeyboardView's held-note table at all: chord mode OFF
        |     ("CHORD OFF") - the only way to turn it off (K7 b);
        |   - with 1 key, or 5 or more keys: nothing changes ("CHORD: HOLD 2-4 KEYS");
        |   - with keys held but none that can be captured (MIDI EXT, the kind-2 path,
        |     another track): nothing changes ("CHORD: NO CAPTURE HERE");
        |   - with only HOLD-latched notes: nothing changes ("CHORD: RELEASE HOLD FIRST").
        | The gesture has no stock function (corp keys-gesture + skeptic): stock sends
        | FUNCTION + OCTAVE UP to the base view handler, which ignores it, and that
        | still happens after the capture.
        |
        | Play: while chord mode is on, HOLD is up and no note is HOLD-latched, each
        | note the KeyboardView starts on an internal or MIDI EXT track goes out as
        | root + every stored interval, each through the stock note-on routine itself
        | (chord_stock below = 0x400b9818's own first instructions + a jump into its
        | body) with the SAME key id, root first. So each tone gets stock's own range
        | check, duplicate guard, voice/MIDI call and held-table entry, and the key's
        | release frees all of them through the stock note-off routine (0x400b872e
        | frees every entry with that key id and state 1). Note-offs are never hooked.
        | A tone above note 127 is skipped (K7 d).
        |
        | HOLD (K7 a): while the HOLD key is down (UIStates +436) or any entry in the
        | table is HOLD-latched (state 2), a note is never expanded: it goes to stock as
        | the single note the key plays. One exception, the orphan guard: when stock's
        | duplicate guard would take ANOTHER key's latched note for this one (0x400b9c94
        | makes it state 1 and leaves it with the other key, whose release then never
        | comes once that key is up: a hung note), the note is not sent and the latched
        | note stays latched, released by HOLD as stock releases latched notes. Except
        | when this+136 is set and HOLD is down: stock then frees this kind's latched
        | notes before its duplicate scan (0x400b9874), so the note goes to stock.
        |
        | Pure stock (the caller's stack and registers untouched, a branch to the stock
        | entry) when: chord mode is off; a nested entry while a chord is being played
        | (chord_busy - nothing in stock re-enters, the guard makes it certain); and
        | every note stock sends down its kind-2 path (the same test stock makes at
        | 0x400b984e..0x400b9872 is repeated here). Before any of those tests chord_on
        | records the call's note as chord_root[key id] (RAM, this mod's own state);
        | stock's behaviour is unchanged by that store.
        |
        | State is RAM only (the 136 bytes at the end of this stub; the image bytes are
        | the power-on defaults: chord mode off, no roots). Nothing is saved.
        | Everything runs in the UI task: key events (type 0, KeyEvent) and note events
        | (types 2/3, NoteEvent) are both dispatched by the UI loop 0x40096ce2.
        |
        | Hooks (registry/allocations_keys.toml, owner 0010-chord):
        |   0x400b9818  KeyboardView note-on, 6-byte prologue -> chord_on
        |   0x400b9e5c  KeyboardView::handleKey, 'cmpil #164,%d3' -> chord_key_gate
        | Addresses and receipts: design.md.

        .ifndef DEVICE_KEYS
        .error  "0010-chord is Analog Keys code: build it with make DEVICE=keys chord"
        .endif

        .include "symbols.inc"

        | KeyEvent (vtable 0x4017a0b8 '8KeyEvent', built by UI-loop case 0, 0x400598c8)
        .equ    EV_FLAGS,       16                | +16 flags (+12 is the key code)
        .equ    EV_DOWN,        1                 | bit 0: pressed (0x400599b6)
        .equ    EV_FUNC,        2                 | bit 1: FUNCTION held at the press (0x400599f2)
        .equ    EV_REPEAT,      8                 | bit 3: held repeat (0x400599c2)
        | KeyboardView fields (ctor 0x400b85d4)
        .equ    KV_CHAN_SRC,    104               | the kind-3 channel fallback reads this+104 (0x400b9a1c)
        .equ    KV_UISTATES,    108               | UIStates (0x401305a8()), the popup's owner
        .equ    KV_SEL,         116               | the track selection the note-on reads
        .equ    KV_HELD,        124               | held-note vector: begin +124, end +128
        .equ    KV_RELEASE,     136               | byte: release the latched notes at the next
                                                  | note while HOLD is down (0x400b9874)
        | a held entry, 20 bytes (pushed at 0x400b9c68..0x400b9c8a)
        .equ    HE_SIZE,        20
        .equ    HE_KIND,        0                 | 1 internal track, 2 kind-2 path, 3 MIDI EXT
        .equ    HE_KEY,         4                 | key id
        .equ    HE_NOTE,        8                 | MIDI note
        .equ    HE_TRACK,       12                | kind 1: kv_active_track(+116); kind 3: MIDI channel
        .equ    HE_STATE,       16                | 1 held, 2 latched by HOLD
        .equ    MAX_NOTES,      4                 | 4 voices: root + up to 3 intervals
        .equ    CAP,            MAX_NOTES+1       | capture buffer: a 5th distinct root = too many
        .equ    BOOT_BIT20,     0x100000          | the bit 0x400b9854 tests
        .equ    ROOTS,          128               | chord_root[] covers key ids 0..127
        .equ    NO_ROOT,        0xff              | chord_root[k]: no note recorded

        .section .text
        | ------------------------------------------------------------------
        | chord_on: KeyboardView note-on 0x400b9818 (this, key id, note, velocity),
        | cdecl, called by 'jsr %pc@' from handleNoteEvent (0x400b9d62, keybed) and
        | from handleKey (0x400ba5d0, codes 16..28). Entered by the detour's jmp,
        | so the stack is the caller's: ret, this, key, note, vel. Until it saves
        | registers it uses only d0/d1/a0/a1 (dead at the stock entry: its own
        | prologue sets d0 and saves d2-d7/a2-a5). Both callers ignore d0 on return.
        | ------------------------------------------------------------------
        .align  2
chord_on:
        tst.b   chord_busy
        bne.w   chord_stock                       | inside a chord: stock, never nested
        move.l  8(%sp),%d0                        | key id
        moveq   #ROOTS-1,%d1
        cmp.l   %d0,%d1
        bcs.s   0f                                | unsigned: key id above 127, not recorded
        move.l  12(%sp),%d1                       | note
        cmpi.l  #127,%d1
        bls.s   1f
        move.l  #NO_ROOT,%d1                      | not a playable note
1:      lea     chord_root,%a0
        move.b  %d1,0(%a0,%d0.l)                  | chord_root[key] = the note this key starts
0:      tst.b   chord_mode
        beq.w   chord_stock                       | chord mode off: stock
        move.l  4(%sp),%a0                        | this
        move.l  boot_flags,%d0                    | stock's kind-2 test, 0x400b984e..72
        andi.l  #BOOT_BIT20,%d0
        beq.s   1f
        move.l  KV_SEL(%a0),-(%sp)
        jsr     sel_kind2_test                    | 0x400ab35e(this+116)
        bra.s   2f
1:      move.l  KV_UISTATES(%a0),-(%sp)
        jsr     uist_kind2_test                   | 0x40021e2c(this+108): UIStates +416
2:      addq.l  #4,%sp
        tst.b   %d0
        bne.w   chord_stock                       | a kind-2 note: stock, unexpanded

        lea     -24(%sp),%sp
        movem.l %d2-%d6/%a2,(%sp)                 | args now: this 28, key 32, note 36, vel 40
        | d5/d6 = how stock files this note: kind 1 with the track, or kind 3 (MIDI
        | EXT) with the MIDI channel - the two values its duplicate predicates compare
        | (kind 1 0x400b7a6a, kind 3 0x400b7a34), computed as stock computes them
        | (0x400b99f6..0x400b9a30 and 0x400b9834..0x400b9842).
        move.l  28(%sp),%a0
        move.l  KV_SEL(%a0),-(%sp)
        jsr     kv_midi_ext                       | 0x400ab51c(this+116): byte result
        addq.l  #4,%sp
        moveq   #1,%d5
        tst.b   %d0
        beq.s   3f
        moveq   #3,%d5                            | MIDI EXT
        move.l  28(%sp),%a0
        move.l  KV_SEL(%a0),-(%sp)
        jsr     kv_ext_chan                       | 0x400ab668(this+116)
        addq.l  #4,%sp
        moveq   #-1,%d1
        cmp.l   %d0,%d1
        bne.s   4f
        move.l  28(%sp),%a0
        move.l  KV_CHAN_SRC(%a0),-(%sp)
        jsr     kv_chan_obj                       | 0x400a2202(this+104) = +128
        addq.l  #4,%sp
        move.l  %d0,-(%sp)
        jsr     kv_chan_fallback                  | 0x400a843c
        addq.l  #4,%sp
        bra.s   4f
3:      move.l  28(%sp),%a0
        move.l  KV_SEL(%a0),-(%sp)
        jsr     kv_active_track                   | 0x400aaba8(this+116)
        addq.l  #4,%sp
4:      move.l  %d0,%d6

        | K7 (a): HOLD down (d4), or any HOLD-latched entry (d3) -> no chord. One scan
        | of the table also finds ANOTHER key's latch on this note (d2): the entry
        | stock's own duplicate predicate would match (kind d5, note, +12 d6).
        move.l  28(%sp),%a0
        move.l  KV_UISTATES(%a0),-(%sp)
        jsr     uist_hold                         | 0x40021e46: UIStates +436, HOLD down
        addq.l  #4,%sp
        move.b  %d0,%d4                           | d4.b = HOLD down
        moveq   #0,%d3                            | d3 = 1: a latched entry exists
        moveq   #0,%d2                            | d2 = 1: another key's latch on this note
        move.l  28(%sp),%a0
        move.l  KV_HELD(%a0),%a1                  | e = begin
        move.l  KV_HELD+4(%a0),%a2                | end
10:     cmpa.l  %a2,%a1
        bcc.s   13f
        moveq   #2,%d0
        cmp.l   HE_STATE(%a1),%d0
        bne.s   12f                               | not latched
        moveq   #1,%d3
        cmp.l   HE_KIND(%a1),%d5
        bne.s   12f
        move.l  36(%sp),%d0
        cmp.l   HE_NOTE(%a1),%d0
        bne.s   12f
        cmp.l   HE_TRACK(%a1),%d6
        bne.s   12f                               | stock's own predicate: kind, note, +12
        move.l  32(%sp),%d0
        cmp.l   HE_KEY(%a1),%d0
        beq.s   12f                               | this key's own latch: stock releases it
        moveq   #1,%d2
12:     lea     HE_SIZE(%a1),%a1
        bra.s   10b
13:     tst.b   %d4
        bne.s   14f
        tst.l   %d3
        beq.s   20f                               | HOLD up and nothing latched: the chord
14:     tst.l   %d2                               | one note, as stock - unless the guard:
        beq.s   16f
        tst.b   %d4
        beq.s   15f
        move.l  28(%sp),%a0
        tst.b   KV_RELEASE(%a0)
        bne.s   16f                               | +136 and HOLD down: stock frees it first
15:     movem.l (%sp),%d2-%d6/%a2                 | the orphan guard: nothing is sent
        lea     24(%sp),%sp
        rts
16:     movem.l (%sp),%d2-%d6/%a2
        lea     24(%sp),%sp
        bra.w   chord_stock                       | stock, the caller's stack untouched

20:     moveq   #1,%d0                            | the chord
        move.b  %d0,chord_busy
        moveq   #0,%d4
        move.b  chord_n,%d4                       | n, bounded to 1..MAX_NOTES
        moveq   #MAX_NOTES,%d0
        cmp.l   %d0,%d4
        bls.s   21f
        move.l  %d0,%d4
21:     tst.l   %d4
        bne.s   22f
        moveq   #1,%d4                            | the root always plays
22:     lea     chord_iv,%a2                      | iv[0] = 0: the root first
        moveq   #0,%d3                            | i
23:     moveq   #0,%d2
        move.b  0(%a2,%d3.l),%d2                  | iv[i], 0..63
        add.l   36(%sp),%d2                       | tone = note + iv[i]
        moveq   #127,%d0
        cmp.l   %d2,%d0
        bcs.s   24f                               | unsigned: above 127 skipped (K7 d)
        move.l  40(%sp),-(%sp)                    | vel
        move.l  %d2,-(%sp)                        | tone
        move.l  40(%sp),-(%sp)                    | key: the same id for every tone
        move.l  40(%sp),-(%sp)                    | this
        bsr.w   chord_stock                       | stock 0x400b9818 for this tone
        lea     16(%sp),%sp
24:     addq.l  #1,%d3
        cmp.l   %d4,%d3
        bcs.s   23b
        clr.b   chord_busy
        movem.l (%sp),%d2-%d6/%a2
        lea     24(%sp),%sp
        rts

        | ------------------------------------------------------------------
        | chord_stock: 0x400b9818 itself - its two displaced instructions, then its
        | body at 0x400b981e. Reached by bra (chord_on's stock paths, the caller's
        | stack untouched) and by bsr (one chord tone; the stock rts comes back here).
        | ------------------------------------------------------------------
        .align  2
chord_stock:
        link.w  %fp,#-88                          | displaced
        moveq   #127,%d0                          | displaced
        jmp     kv_note_on_body                   | 0x400b981e

        | ------------------------------------------------------------------
        | chord_key_gate: KeyboardView::handleKey 0x400b9de2 at 0x400b9e5c, reached
        | only by 'bgts' from 0x400b9e44 (codes above 162). Live: d3 = the key code,
        | d2 = the KeyEvent, a2 = the KeyboardView. d0/d1/a0/a1 are dead here and at
        | every continuation (0x400b9ef2 writes d0 first, d1 is loaded by moveq
        | before it is read, a0/a1 are not read; keys-gesture-sk). Kept: d2-d7, a2-a6.
        | FUNCTION + OCTAVE UP, press (down, FUNCTION, not a repeat - the test the
        | base handler 0x4005fa6e makes for its own FUNCTION combos) -> the capture.
        | Then always the stock path: the re-emitted compare sets the condition
        | codes the 'beqw 0x400b9ef2' at the rejoin reads.
        | ------------------------------------------------------------------
        .align  2
chord_key_gate:
        cmpi.l  #KEY_OCT_UP,%d3
        bne.s   9f
        move.l  %d2,%a0
        move.l  EV_FLAGS(%a0),%d0
        moveq   #EV_DOWN+EV_FUNC+EV_REPEAT,%d1
        and.l   %d1,%d0
        moveq   #EV_DOWN+EV_FUNC,%d1
        cmp.l   %d1,%d0
        bne.s   9f
        bsr.s   chord_capture
9:      cmpi.l  #164,%d3                          | displaced
        jmp     kv_key_cmp_resume                 | 0x400b9e62: 'beqw 0x400b9ef2'

        | ------------------------------------------------------------------
        | chord_capture (a2 = the KeyboardView). Counts the held entries with kind 1
        | (an internal track note), state 1 (held, not HOLD-latched) and track = the
        | active track (kv_active_track(this+116), the value stock stores in +12).
        | Each counted entry stands for its key: the note chord_on recorded for that
        | key id (chord_root[key], the note the key was pressed at - with chord mode
        | on, the root of its chord, even when a duplicate left the root itself under
        | another key); for a key id without a recorded note (above 127), the entry's
        | own note when it is that key's lowest. Distinct notes into a sorted buffer
        | of CAP = 5 (a fifth distinct note means "5 or more"). Then (K7 b):
        |   0 -> chord mode OFF only when the table has no entry at all; else nothing
        |        changes ("NO CAPTURE HERE" when a key is held, "RELEASE HOLD FIRST"
        |        when only latched notes are left);
        |   1, or 5 or more -> nothing changes ("HOLD 2-4 KEYS");
        |   2..4 -> only those at most 63 semitones above the lowest (the most a stock
        |        chord trig can store); 2..4 left -> captured, ON; else "HOLD 2-4 KEYS".
        | Keeps d2-d7/a2-a6. Buffer: five longs at 0(sp), sorted ascending.
        | ------------------------------------------------------------------
        .align  2
chord_capture:
        lea     -60(%sp),%sp
        movem.l %d2-%d7/%a2-%a5,20(%sp)
        move.l  KV_SEL(%a2),-(%sp)
        jsr     kv_active_track                   | 0x400aaba8(this+116)
        addq.l  #4,%sp
        move.l  %d0,%d7                           | d7 = track
        moveq   #0,%d6                            | d6 = count (saturates at CAP)
        move.l  KV_HELD(%a2),%a3                  | a3 = e = begin
        move.l  KV_HELD+4(%a2),%a5                | a5 = end
10:     cmpa.l  %a5,%a3
        bcc.w   20f
        move.l  %a3,%a0
        bsr.w   cap_counts
        beq.w   18f
        move.l  HE_KEY(%a3),%d2                   | e's key id
        moveq   #ROOTS-1,%d0
        cmp.l   %d2,%d0
        bcs.s   30f                               | unsigned: above 127, no recorded note
        lea     chord_root,%a0
        moveq   #0,%d3
        move.b  0(%a0,%d2.l),%d3                  | the note this key was pressed at
        moveq   #127,%d0
        cmp.l   %d3,%d0
        bcc.s   13f                               | recorded (0..127): the key's note
30:     move.l  HE_NOTE(%a3),%d3                  | else e's note, if its key's lowest:
        move.l  KV_HELD(%a2),%a4                  | f over every entry:
11:     cmpa.l  %a5,%a4
        bcc.s   13f
        move.l  %a4,%a0
        bsr.w   cap_counts
        beq.s   12f
        cmp.l   HE_KEY(%a4),%d2
        bne.s   12f
        cmp.l   HE_NOTE(%a4),%d3
        bgt.w   18f                               | f is lower on the same key: e is not its root
12:     lea     HE_SIZE(%a4),%a4
        bra.s   11b
13:     lea     (%sp),%a1                         | insert d3 into buf[0..count-1]
        moveq   #0,%d4                            | j
14:     cmp.l   %d6,%d4
        bge.s   17f                               | past the end: append
        move.l  0(%a1,%d4.l*4),%d0
        cmp.l   %d0,%d3
        beq.s   18f                               | already listed
        blt.s   15f                               | below buf[j]: insert at j
        addq.l  #1,%d4
        bra.s   14b
15:     move.l  %d6,%d5                           | k = min(count, CAP - 1)
        moveq   #CAP-1,%d0
        cmp.l   %d0,%d5
        ble.s   16f
        move.l  %d0,%d5
16:     cmp.l   %d4,%d5                           | shift buf[j..k-1] up one (full: the top drops)
        ble.s   19f
        move.l  -4(%a1,%d5.l*4),%d0
        move.l  %d0,0(%a1,%d5.l*4)
        subq.l  #1,%d5
        bra.s   16b
19:     move.l  %d3,0(%a1,%d4.l*4)
        moveq   #CAP,%d0
        cmp.l   %d0,%d6
        bge.s   18f                               | was full: still CAP
        addq.l  #1,%d6
        bra.s   18f
17:     moveq   #CAP,%d0
        cmp.l   %d0,%d6
        bge.s   18f                               | full and above them all: still CAP
        move.l  %d3,0(%a1,%d6.l*4)
        addq.l  #1,%d6
18:     lea     HE_SIZE(%a3),%a3
        bra.w   10b

20:     tst.l   %d6
        bne.s   25f
        move.l  KV_HELD(%a2),%a0                  | none counted (K7 b):
        move.l  KV_HELD+4(%a2),%a1
        cmpa.l  %a1,%a0
        bcc.s   32f                               | no entry of any kind or state: OFF
31:     cmpa.l  %a1,%a0                           | why not: a key held, or only latches?
        bcc.s   34f
        moveq   #1,%d0
        cmp.l   HE_STATE(%a0),%d0
        beq.s   33f                               | a held entry (any kind or track)
        lea     HE_SIZE(%a0),%a0
        bra.s   31b
32:     clr.b   chord_mode                        | the table is empty: chord mode OFF
        lea     str_off,%a0
        bra.s   21f
33:     lea     str_here,%a0                      | keys held, none capturable: no change
        bra.s   21f
34:     lea     str_latch,%a0                     | only HOLD-latched notes: no change
        bra.s   21f
25:     moveq   #MAX_NOTES,%d0
        cmp.l   %d0,%d6
        bgt.s   28f                               | 5 or more keys: no change
        lea     (%sp),%a3                         | buf
        move.l  (%a3),%d5                         | root = the lowest
        moveq   #1,%d4                            | keep the notes at most 63 above the root
26:     cmp.l   %d6,%d4                           | (a stock chord trig stores NO2..NO4 as
        bge.s   27f                               | 64 + semitones, -64..+63: live REC); the
        move.l  0(%a3,%d4.l*4),%d0                | list is sorted, so the rest go too
        sub.l   %d5,%d0
        moveq   #63,%d1
        cmp.l   %d1,%d0
        bgt.s   27f
        addq.l  #1,%d4
        bra.s   26b
27:     move.l  %d4,%d6
        moveq   #2,%d0
        cmp.l   %d0,%d6
        bge.s   22f                               | 2..4 notes: capture
28:     lea     str_hold,%a0                      | 1 note, or 5 or more: nothing changes
21:     move.l  %a0,-(%sp)
        move.l  KV_UISTATES(%a2),-(%sp)
        jsr     ui_popup                          | 0x40021774(UIStates, fmt)
        addq.l  #8,%sp
        bra.s   29f

22:     lea     chord_iv,%a0                      | a3 = buf, d5 = root (above)
        moveq   #0,%d4
23:     move.l  0(%a3,%d4.l*4),%d0
        sub.l   %d5,%d0                           | 0 for the root, 1..63 above
        move.b  %d0,0(%a0,%d4.l)
        addq.l  #1,%d4
        cmp.l   %d6,%d4
        blt.s   23b
        move.b  %d6,chord_n
        moveq   #1,%d0
        move.b  %d0,chord_mode                    | ON
        move.l  %d6,%d4                           | popup: "CHORD ON: 0 a b c", the intervals
        subq.l  #1,%d4                            | pushed right to left, i = n-1 .. 1
24:     move.l  0(%a3,%d4.l*4),%d0
        sub.l   %d5,%d0
        move.l  %d0,-(%sp)
        subq.l  #1,%d4
        bne.s   24b
        lea     fmt_on,%a0
        move.l  -8(%a0,%d6.l*4),-(%sp)            | the format for n notes
        move.l  KV_UISTATES(%a2),-(%sp)
        jsr     ui_popup
        move.l  %d6,%d0                           | pop 8 + 4*(n-1)
        lsl.l   #2,%d0
        addq.l  #4,%d0
        adda.l  %d0,%sp

29:     movem.l 20(%sp),%d2-%d7/%a2-%a5
        lea     60(%sp),%sp
        rts

        | cap_counts: a0 = an entry; Z clear (and d0 = 1) when it counts: kind 1,
        | state 1, track = d7. Clobbers d0/d1 only.
        .align  2
cap_counts:
        moveq   #0,%d0
        moveq   #1,%d1
        cmp.l   HE_KIND(%a0),%d1
        bne.s   1f
        cmp.l   HE_STATE(%a0),%d1
        bne.s   1f
        cmp.l   HE_TRACK(%a0),%d7
        bne.s   1f
        moveq   #1,%d0
1:      tst.l   %d0
        rts

        | ------------------------------------------------------------------
        | Constants: the popup formats (each under the popup's 32 characters).
        | ------------------------------------------------------------------
        .align  2
fmt_on: .long   str_on2, str_on3, str_on4         | n = 2, 3, 4
str_on2: .asciz "CHORD ON: 0 %d"
str_on3: .asciz "CHORD ON: 0 %d %d"
str_on4: .asciz "CHORD ON: 0 %d %d %d"
str_off: .asciz "CHORD OFF"
str_hold: .asciz "CHORD: HOLD 2-4 KEYS"
str_here: .asciz "CHORD: NO CAPTURE HERE"
str_latch: .asciz "CHORD: RELEASE HOLD FIRST"

        | ------------------------------------------------------------------
        | RAM state, after every entry point (136 bytes; the image bytes are the
        | power-on defaults). Written only by chord_capture and chord_on, both in
        | the UI task.
        | ------------------------------------------------------------------
        .align  2
chord_mode:  .byte 0                              | 1 = chord mode on
chord_busy:  .byte 0                              | 1 while chord_on plays a chord
chord_n:     .byte 0                              | notes in the chord, root included (2..4)
chord_pad:   .byte 0
chord_iv:    .byte 0, 0, 0, 0                     | semitones above the root; iv[0] = 0
chord_root:  .fill ROOTS, 1, NO_ROOT              | per key id: the note chord_on last
                                                  | started for it (0..127), NO_ROOT none
