# CHOP for the Elektron Analog Rytm

**Turn the 12 pads into sample-start markers.** Pick a track, open the CHOP page, and every pad plays that track's sample from its own start point. Record it live and each hit becomes an ordinary STA p-lock, so your patterns play back on stock firmware too.

Unofficial firmware mod for the **Analog Rytm MK1, OS 1.73**, built on [gdeo607/rytm1_mods](https://github.com/gdeo607/rytm1_mods). Not affiliated with or endorsed by Elektron. **Flashing modified firmware is at your own risk.**

| Status | |
|---|---|
| MK1, OS 1.73 | ✅ Working on hardware |
| MK2 | ❌ Not yet |
| Builds reproducibly | ✅ Fresh clone + patch gives the same files (`86e1dd1b…a9a1`, `23a20937…7915`) |
| Step-lock (GRID REC: hold steps + pad) | ✅ Working on hardware |
| Sample Focus (hi-res, END, DIV, LAY, RND) | 🧪 Built, reviewed, reproducible; not yet hardware-tested |
| SMP CUT (FILTER ×2: low/high cut), fixed for MK1 | 🧪 Built, reviewed, reproducible; first MK1 run pending |
| STR (time-stretch) | ❌ Removed: didn't work on hardware |
| Recovery code untouched | ✅ Byte-for-byte identical to stock |

## Sample Focus + SMP CUT (newest, `make samplefocus-cut`)
CHOP's page (below, minus STR) plus rytm1_mods' **SMP CUT** page on **FILTER ×2** (LCT low cut / HCT high cut on the sample layer), fixed for the MK1: the original uses the MK2's kit and sound offsets, which can crash an MK1. CHOP owns the shared page hooks and hands SMP CUT's knobs to its code. Fitted by code compaction; no features dropped except STR. **SMP CUT has not run on an MK1 yet**: see the test card (S1–S10).
Expected sha256 of `build/AR1_OS1.73_0000_0001_0008.syx`: `86e1dd1b2a177b709d1e3977ee61b7f228d587ab752416d203014e66d21fa9a1`.
Without SMP CUT: `make samplefocus` → `build/AR1_OS1.73_0000_0001.syx`, `23a20937c06fe856abcd1013bda03a14eb775dbcccb9329145d0d808c5157915`.

## Sample Focus (previous build; STR has since been removed)
`make samplefocus` builds CHOP plus a full 8-knob page (0000-shared + CHOP only; no euclid/velocity):

| Knob | Does |
|---|---|
| PAD | which marker you're editing |
| STA | the marker, hi-res like stock STA (slow = decimals, FUNC = whole steps) |
| CHP | CHOP on/off |
| END | each pad also sets END to the next marker (slice playback) |
| DIV | re-chop into 1–12 equal slices |
| LAY | lay slices onto the empty steps of the pattern |
| RND | GRID REC: hold steps + turn → random slice per step |
| ~~STR~~ | removed (didn't work) |

Needs SAMPLE POS RES = HI for decimals. LAY has no undo.
(With STR, previous patch: `734607ae…14dc`. The current patch builds the no-STR version.)

## How it works

1. Select the track with the sample you want to chop. Use the normal pad mode, not chromatic or scale.
2. Press **SAMPLE**, let go, pause, then press **SAMPLE** again to open the **CHOP** page.
3. Turn **CHP** right to switch it ON. The selected track becomes the chop track.
4. Hit pads 1–12. The sample plays from markers 0, 10, 20 … 110.
5. To move a marker, hit its pad (or turn **PAD**), then turn **STA** (0–120).
6. Press **REC + PLAY** and play the pads. Each hit records a trig with an STA p-lock.
7. Turn **CHP** left to switch it OFF, and the pads are stock again.

| Knob | Does |
|---|---|
| PAD | which marker you're editing (1–12) |
| STA | that marker's start point (0–120, same scale as the SAMPLE page) |
| CHP | CHOP off / on |

**Step-lock:** in GRID RECORDING (press REC with the sequencer stopped), hold one or more steps and hit a pad. Each held step gets an STA p-lock set to that pad's marker, just like holding the step and turning STA. The trig stays on when you let go.

**Tip:** make your loop 120 sixteenths long (7.5 bars). Then every STA value lands exactly on a 16th.

**Good to know:**
- **Markers reset on power-off.** They live in RAM, so re-chop after a restart. Recorded p-locks stay in your pattern.
- **Pads all go to the chop track while CHP is ON**, including TRK + pad. Turn CHP OFF to select other tracks with the pads.
- **Pad pressure (aftertouch) still goes to the pad's own track.**
- **A quick double-tap of SAMPLE opens the stock sample list.** Pause between presses to get CHOP.
- **Which build has what:** the proven step-lock build (`make chop`, previous patch) includes euclid accents and velocity humanise but not SMP CUT; `make samplefocus-cut` includes the MK1-fixed SMP CUT and drops euclid/velocity; `make samplefocus` is the same without SMP CUT.

## Install

You build the firmware yourself from Elektron's own OS file. This repo never ships Elektron's code.

### You need
- An Analog Rytm **MK1 on OS 1.73**. The Rytm can't go back to an older OS, so update with Elektron's official 1.73 first.
- A Mac or Linux machine with `git`, `make`, a C compiler and **Python 3.11+**.
- **m68k binutils**: `brew install m68k-elf-binutils` (macOS) or `sudo apt install binutils-m68k-linux-gnu` (Debian/Ubuntu).
- Elektron Transfer (free, from elektron.se) for flashing.
- **A DIN MIDI interface.** Recovery works over DIN only, so have one before you flash.

### 1. Get the stock OS
Download Elektron's official MK1 OS 1.73 (`Analog-Rytm_OS1.73_dist.zip`) and unzip it. Check the `.syx`:
```bash
shasum -a 256 Analog-Rytm_OS1.73.syx
# 9115c3888354bb388f90410e0445cd312bf020593ed99f768a99e475d1d6157c
```

### 2. Build
```bash
git clone https://github.com/gdeo607/rytm1_mods
cd rytm1_mods
git checkout 2fae7ce
git am /path/to/this-repo/mods/0001-chop/rytm1_mods-chop.patch
cp /path/to/Analog-Rytm_OS1.73.syx stock/Analog-Rytm_OS1.73.syx
make setup          # fetches and builds the firmware container tool
make samplefocus-cut   # newest: CHOP (hi-res, END/DIV/LAY/RND) + SMP CUT; must end with PASS
make samplefocus       # same without SMP CUT
make control        # stock code repacked, for your first flash
```
On macOS, if `python3` is older than 3.11, add `PY=python3.12` to each `make` command.

The end of the `make` output must show all three of these:
```
ok   null repack: stock .syx rebuilds byte-identically
ok   embedded bootstrap image unchanged (87,068 B) - recovery path intact
PASS
```
Then check your build is the same file this repo was tested with:
```bash
shasum -a 256 build/AR1_OS1.73_0000_0001_0008.syx
# 86e1dd1b2a177b709d1e3977ee61b7f228d587ab752416d203014e66d21fa9a1   (samplefocus-cut)
shasum -a 256 build/AR1_OS1.73_0000_0001.syx
# 23a20937c06fe856abcd1013bda03a14eb775dbcccb9329145d0d808c5157915   (samplefocus)
```

### 3. Flash (Transfer)
1. Back up your projects and +Drive in Transfer.
2. Connect USB, power on, and in Transfer > CONNECTION set MIDI IN and OUT to the Analog Rytm.
3. **Control build first:** drag `build/AR1_OS1.73_control.syx` onto Transfer > DROP and press **YES** on the Rytm. Check it boots and plays normally. This proves the toolchain on your unit.
4. **Then Sample Focus** (`build/AR1_OS1.73_0000_0001.syx`, no SMP CUT) and check CHOP works; only then **Sample Focus + SMP CUT** (`build/AR1_OS1.73_0000_0001_0008.syx`). SMP CUT's first-run checks: `flash/START_HERE.md` section B.
5. Don't power off during an update or during the first boot after it.

The hardware-proven step-lock build (CHOP + step-lock + euclid/velocity, sha256 `a96657b4…caf6`) is the previous patch, commit `f82a2f4` of this repo's `mods/0001-chop/rytm1_mods-chop.patch`, built with `make chop`.

If Transfer refuses a file as "same version", nothing was written. Use the recovery route below to send it.

### If it won't boot: recovery
1. Hold **FUNC** while powering on.
2. Press **TRIG 4** (OS UPGRADE).
3. In Transfer > CONNECTION, choose **LEGACY OS UPGRADE**, and send the **stock** `Analog-Rytm_OS1.73.syx` over **DIN MIDI** (not USB).

This route runs from the Rytm's recovery code in flash, which CHOP never touches.

**Do not flash rytm1_mods' SMP CUT or RANDOM builds on an MK1.** They use an MK2 memory offset that is wrong for the MK1.

## Tested on hardware (MK1, OS 1.73)
- ✅ A pad hit plays from its marker on the first hit.
- ✅ Under live REC, the STA p-lock lands on the trig's step.
- ✅ The CHOP page draws and switches back to the sample page.
- ✅ No crashes or stuck notes under mashing and fast retriggers.
- ✅ Step-lock: in GRID REC, holding steps + hitting a pad writes that pad's marker as an STA p-lock.
- ⏳ Reinstalling stock 1.73 over CHOP: not yet tried.

## What's in this repo
| Path | What |
|---|---|
| `mods/0001-chop/rytm1_mods-chop.patch` | the mod, as a patch for rytm1_mods @ `2fae7ce` |
| `mods/0001-chop/src/` | the mod source (`stub.s`, `mod.toml`, and `design.md` with every hook, address and the full test card) |
| `proto/chop/` | a Mac-side prototype (Rust, MIDI only, no firmware): pads → CC 28 → trigger. Works on MK1 and MK2 |
| `REPORT.md` | research: who has reverse-engineered the Rytm, and the risks |
| `docs/` | design notes and hazards |

## Credits
- **[gdeo607/rytm1_mods](https://github.com/gdeo607/rytm1_mods)**: the MK1 mod framework, symbol map and build/verify tooling that CHOP is built on.
- **[mischa85/elektron-firmware-tool](https://github.com/mischa85/elektron-firmware-tool)** (MIT): Elektron OS container tool.
- **[irpina/elekloader](https://github.com/irpina/elekloader)**: mod loader.

Elektron, Analog Rytm and Overbridge are trademarks of Elektron Music Machines. This project contains no Elektron firmware.
