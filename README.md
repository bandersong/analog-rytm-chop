# CHOP for the Elektron Analog Rytm

**Turn the 12 pads into sample-start markers.** Pick a track, open the CHOP page, and every pad plays that track's sample from its own start point. Record it live and each hit becomes an ordinary STA p-lock, so your patterns play back on stock firmware too.

Unofficial firmware mod for the **Analog Rytm MK1, OS 1.73**, built on [gdeo607/rytm1_mods](https://github.com/gdeo607/rytm1_mods). Not affiliated with or endorsed by Elektron. **Flashing modified firmware is at your own risk.**

| Status | |
|---|---|
| MK1, OS 1.73 | ✅ Working on hardware |
| MK2 | ❌ Not yet |
| Builds reproducibly | ✅ Fresh clone + patch gives the same file, sha256 `a96657b4…caf6` |
| Step-lock (GRID REC: hold steps + pad) | ✅ Working on hardware |
| Sample Focus (hi-res, END, DIV, LAY, RND, STR) | 🧪 Built, reviewed, reproducible; not yet hardware-tested |
| Recovery code untouched | ✅ Byte-for-byte identical to stock |

## Sample Focus (newest build, not yet hardware-tested)
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
| STR | experimental: sets the LFO up to sweep STA over 1–64 steps (time-stretch trick) |

Needs SAMPLE POS RES = HI for decimals. Turn STR off before CHP off. LAY has no undo.
Expected sha256 of `build/AR1_OS1.73_0000_0001.syx`: `734607ae8a213a328a46c474abd2d4b55853172761e753af34e921f41b9d14dc`.

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
- **The build includes rytm1_mods' euclid accents and velocity humanise, but not SMP CUT.** SMP CUT clashes with CHOP.

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
make chop           # (retired in the newest patch: use `make samplefocus`)
make samplefocus    # newest: CHOP + hi-res + END/DIV/LAY/RND/STR; must end with PASS
make control        # stock code repacked, for your first flash
```
On macOS, if `python3` is older than 3.11, add `PY=python3.12` to each `make` command.

The end of `make chop`'s output must show all three of these:
```
ok   null repack: stock .syx rebuilds byte-identically
ok   embedded bootstrap image unchanged (87,068 B) - recovery path intact
PASS
```
Then check your build is the same file this repo was tested with:
```bash
shasum -a 256 build/AR1_OS1.73_0000_0001_0002_0003.syx
# a96657b49e70b42fc20b9d744a0f10ceceb0f065c0aac7201be88866ac15caf6
```

### 3. Flash (Transfer)
1. Back up your projects and +Drive in Transfer.
2. Connect USB, power on, and in Transfer > CONNECTION set MIDI IN and OUT to the Analog Rytm.
3. **Control build first:** drag `build/AR1_OS1.73_control.syx` onto Transfer > DROP and press **YES** on the Rytm. Check it boots and plays normally. This proves the toolchain on your unit.
4. **Then CHOP:** do the same with `build/AR1_OS1.73_0000_0001_0002_0003.syx`.
5. Don't power off during an update or during the first boot after it.

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
