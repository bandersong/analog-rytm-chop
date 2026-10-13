# MKII firmware in rytm-emu: screenshots (2026-10-13)

Emulator: trigcondition/rytm-emu (MIT), commit 4177ad4, built with cargo 1.99.0, headless `dtboot` only (no window).
Firmware run (sha256, from the repo):
- stock 1.73: 8ad671087ec30433d5407c7380d2396e0915ab931c5d3dd18a78bf284d3d1e52
- file 2 CHOP: 2ff96af2f5ed05f5884e0dfa74f806091a867be46254250c4b404da609de792d
- file 3 CHOP + SMP CUT: 782955769d2f199af5937eb8c945de659f1dad497b66aef07180c004089f6e8a

Sequence (scenario.sh): boot, NO x5 to close the three start-up popups (calibration prompt, "MISSING CAL", "ANALOG CALIBRATION MISSING"), SMPL x4 (SAMPLE, SMPL WAVEFORM, CHOP, back to SAMPLE), FLTR x3.

What the screens show: CHOP is the third SAMPLE page in files 2 and 3 (PAD STA CHP END / DIV LAY RND, one blank). SMP CUT (LCT, HCT) is on the second FILTER press in file 3 only; file 2's FILTER pages are stock.
Not shown / not verified: pad hits and the sound (the analog voices are stubbed in the emulator), the saved state, and any behaviour beyond the pages drawing. Large single knob turns (delta 30-40) did not move the knobs; small repeated turns did (the label read OFF during the CHP turns, not checked further).

Sheets: `sheet_stock.png`, `sheet_chop2.png`, `sheet_chopcut3.png` (one frame per key step), `smpcut_page_settled.png`, `sheet_chop_knob_turns.png`.

To reproduce: build rytm-emu's `dtboot` and `dtcard`, make a card with `dtcard rytm.img format`, then for each firmware:

```bash
DTBOOT_STEPS=1 DTBOOT_PNG_DIR=out dtboot FW.syx --instr 15G --card rytm.img --every 5G \
  --press NO@4G --press NO@4.6G --press NO@5.2G --press NO@5.8G --press NO@6.4G \
  --press SMPL@7.2G --press SMPL@8.0G --press SMPL@8.8G --press SMPL@9.6G \
  --press FLTR@10.6G --press FLTR@11.4G --press FLTR@12.2G
```

The firmware files are not in this repo; build them as the main README says.
