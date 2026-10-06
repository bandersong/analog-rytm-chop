# Analog Rytm sample-chop: who has reverse engineered it, and what to build

2026-10-05. Research by 5 sourced lanes, each claim re-opened by a separate auditor; the repos marked ✔ I re-read myself (GitHub API + raw README) the same day.

## Answer

**Yes. People are patching Analog Rytm firmware right now, on both MK1 and MKII, and the tooling is public.** Nobody has built a chop/slice mod for the Rytm. The closest things are a slice mode on Model:Cycles and a Digitakt MK1 slicer.

All of it is about a month old, and none of it is a proven-safe base yet.

## What exists

| Project | What it is | State |
|---|---|---|
| ✔ [gdeo607/rytm1_mods](https://github.com/gdeo607/rytm1_mods) | Firmware mods for **MK1 OS 1.73**: a new SMP CUT page (low/high cut on the sample layer), euclid accents, velocity humanise, LFO random. Assembly patches at fixed addresses, with a symbol map and an allocation registry. | Created 2026-09-28. **No license.** Its PORTING.md says "Nothing has run on an MK1 yet"; a later pull request by the same author says the mods were loaded and tested on a real MK1. Both are self-reported. |
| `rytm-mods` (MKII) | The MKII project rytm1_mods was ported from. | **Not public** (`gdeo607/rytm-mods` returns Not Found). |
| ✔ [genosdk/analog-rytm-mkii-research](https://github.com/genosdk/analog-rytm-mkii-research) | **MKII OS 1.72** reverse-engineering workspace. Says the container path is understood well enough to "decode, modify, recompress, checksum, and re-encode OS 1.72"; traces the sample Bit Reduction path; has a QEMU model. | Last push 2026-09-25. No license. Firmware bytes kept out of the repo. |
| ✔ [mischa85/elektron-firmware-tool](https://github.com/mischa85/elektron-firmware-tool) | Unpacks and repacks Elektron OS `.syx` files, recomputing checksums. | MIT. The MK1 Rytm file needs a small padding patch that rytm1_mods carries. |
| ✔ [irpina/elekloader](https://github.com/irpina/elekloader) | Mod loader several of these projects build on. | GPL-2.0, active today. Its maintainer has no Rytm. |
| ✔ [TinyGregAudio/Model-TG](https://github.com/TinyGregAudio/Model-TG) | **Model:Cycles** mod: a sampler machine with a Slice mode, user-set markers in a slice editor. Probably the mod you saw (the other candidate is 18nelli18's Modded Cycles). | Created 2026-09-30. |
| digislicer | A Digitakt MK1 slicing mod, listed on [elektronmods.com](https://elektronmods.com/mods.php). | Listed only; not opened at source. |
| libanalogrytm, rytm-rs, elektroid | SysEx and sample-transfer libraries. | Project-data formats only, no firmware code. Your bridge already uses rytm-rs. |

What the firmware is, per rytm1_mods' own docs: MK1 MAIN OS is ColdFire V4 code loaded at `0x40000400`, shipped in a compressed, checksummed container with no secret-key signature. MK1 and MKII are the same code base compiled separately, with shifted addresses and different data layout. The exact CPU, DSP and debug-header parts were **not found** in any source.

## The risks that matter

- **Brick risk is real on MK1 specifically.** The MK1 `.syx` has one section, and the recovery bootstrap sits inside it. A patch that writes into that range can damage the recovery path itself. MKII keeps the bootstrap in a separate section, so it is the safer box, which is the opposite of your test order.
- Recovery when the bootstrap is intact: hold FUNC at power-on, TRIG 4 (OS UPGRADE), send the stock `.syx` over DIN MIDI. Have a DIN MIDI interface and the stock 1.73 file on hand before any flash.
- **Elektron banned sharing mod files, tools and instructions** on Elektronauts and its social channels (statement 2026-09-16), citing bricking, blocked updates, warranty and IP. General discussion is allowed. The community moved to elektronmods.com.
- rytm1_mods and the MKII research repo have **no license**: you can read and build locally, not redistribute or fork publicly without asking the authors.
- The mods pin exact OS versions (MK1 1.73, MKII 1.72). Current OS is 1.74 on both; a mod means staying on the pinned version.

## Your design, checked against the machine

- Sample start (STA) is **0–120, not 0–127**, on both models. It is p-lockable per step and reachable by MIDI: CC 28 (start), CC 29 (end), NRPN 1:12 / 1:13, on the track's channel.
- A forum method relies on this: prepare a clip 120 sixteenth-notes long and every whole STA value lands on a 16th. That makes "marker = STA value" a sound model.
- Your exact idea was requested on Elektronauts in 2014 (hold a pad, set its start, 12 slices) and again in April 2026. No Elektron staff reply was found.
- Nothing native maps pads to start values. Chromatic mode changes pitch only. Scenes can lock STA per pad, but scene pads switch scenes instead of playing the sound.

## Recommended path

1. **Prototype on the Mac first (days, zero brick risk).** Your bridge (`~/analog-rytm-agent-bridge`, MKII, OS 1.72) can already trigger a track. It cannot set sample start live: `rytm_set_live_parameter` accepts only level and mute. Adding `sample_start` (CC 28) is a small change. Then: pad note in → CC 28 → trigger note. This proves the feel, the 0–120 resolution, and whether start-then-trigger ordering is tight enough. Untested: whether CC timing is good enough, and whether the bridge works on an MK1.
2. **Firmware mod on top of rytm1_mods (MK1) once step 1 feels right.** It already has what a chop page needs: a new UI page, key and encoder hooks, a located `trig_fire`, and per-sound settings that save. The chop mod is: a page holding 12 start values for one track, and a pad hook that writes STA before firing the trig.
3. **MKII port.** Blocked on the private `rytm-mods` project or on doing the address work against genosdk's 1.72 research. Ask gdeo607 first.

## Decisions for you

1. **Contact gdeo607?** One message gets you the license answer, the MKII project, and whether the MK1 builds really ran on hardware. I have drafted nothing and sent nothing.
2. **Flash an MK1 at all?** Yours to do, with the stock 1.73 file and DIN MIDI ready. I will not flash.
3. **12 markers or more?** 12 pads give 12 markers per page; "1–127" becomes 0–120 values assignable to those 12 pads, with pages if you want more.

## Not verified

- No one outside the authors has confirmed any Rytm mod running on hardware.
- CPU/DSP part numbers, debug headers: not found.
- MKII manual MIDI appendix not read (file too large); MKII parity is inferred from the shared OS version.
- CC-to-STA scaling and any finer NRPN resolution; MIDI round-trip latency.
- Two `.syx` OS files sit in `~/Downloads`; which model/version they are was not checked.

Evidence: `/Users/creative/corp-audits/2026-10-05-rytm-chop/corp/results_by_lane.json` (60 claims with URL, quote and audit verdict).
