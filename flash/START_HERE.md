# CHOP for your MK1 (OS 1.73) — start here

Nothing here has run on a Rytm yet. Every check that can be done on a computer passed; the rest is the test below.

## Before you flash
1. In Transfer, back up your projects / +Drive.
2. Have a DIN MIDI interface ready (recovery is DIN only), and `RECOVERY_stock_Analog-Rytm_OS1.73.syx` from this folder.

## Flash (Transfer > DROP, drag the file, press YES on the Rytm; don't power off during the first boot after)
1. `1_CONTROL_stock-code_…syx` — stock code, just repacked by our tool. It should boot and play exactly like stock. This proves the tool on your unit.
2. `2_CHOP_…syx` — CHOP, plus euclid accents and velocity humanise from rytm1_mods (no SMP CUT).
3. `3_only-if-chop-misbehaves_…syx` — only to narrow down a problem (CHOP alone).

If Transfer refuses a file as "same version", nothing was written. Stop, or use the recovery route.

## Use it
1. Pick the track with the sample you want to chop (normal pad mode, not chromatic).
2. Press **SAMPLE**, let go, pause, press **SAMPLE** again → the **CHOP** page (knobs PAD / STA / CHP). A quick double-tap opens the sample list instead (that's stock).
3. Turn **CHP** right → ON. CHOP now belongs to the track that was selected.
4. Hit pads 1–12: the sample plays from markers 0, 10, 20 … 110.
5. To move a marker: hit the pad (or turn PAD), then turn **STA**.
6. Live REC (REC + PLAY) and play pads: each hit records a normal trig with an STA p-lock — it saves with the pattern and plays on stock firmware too.
7. Turn **CHP** left → OFF. Pads are stock again. Power-off also ends CHOP and resets the markers (they live in RAM by design).

While CHP is ON, every pad goes to the chop track (TRK + pad won't select other tracks), and pad pressure still goes to the pad's own track.

## If it won't boot
Hold **FUNC** while powering on → **TRIG 4** (OS UPGRADE) → Transfer > CONNECTION > LEGACY OS UPGRADE → send `RECOVERY_stock_Analog-Rytm_OS1.73.syx` over **DIN MIDI**. The recovery code in flash is never touched by these files (checked byte for byte).

## Don't
- Don't flash rytm1_mods' SMP CUT or RANDOM builds: they use an MKII offset that is wrong for the MK1.
- Don't use FUNC + SAMPLE (page copy/paste/clear) while the CHOP page is on screen.

## Please check (and tell me)
1. Does a pad hit play from its marker on the **first** hit?
2. Under live REC, does the STA lock land on the same step as the trig?
3. Does the CHOP page draw right and switch back to SAMP?
4. No crash or stuck notes on fast rolls, two pads held, or holding a pad while turning CHP.
5. Going back to stock (same-version reinstall) works.

Full test card: `../mods/0001-chop/src/design.md` § "Hardware-only unknowns". Checksums: `SHA256SUMS`.

## Hardware results
- 2026-10-05, MK1 OS 1.73, CHOP build 3ea80d31…b00b: works. H1 (first hit plays from marker) YES; H2 (live-REC lock on the trig step) YES; H3 (CHOP page draws and switches back) YES. H4–H5 pending.
