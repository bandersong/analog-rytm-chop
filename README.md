# CHOP for the Elektron Analog Rytm

**Turn the 12 pads into sample-start markers.** Pick a track, open the CHOP page, and every pad plays that track's sample from its own start point. Record it live and each hit becomes an ordinary STA p-lock, so your patterns play back on stock firmware too.

Unofficial firmware mod for the **Analog Rytm MK1** (proven on hardware) **and MKII** (built, not yet hardware-tested), **OS 1.73**, plus **chord memory and a joystick randomizer for the Analog Keys** (OS 1.56, built, not yet hardware-tested), built on [gdeo607/rytm1_mods](https://github.com/gdeo607/rytm1_mods). Not affiliated with or endorsed by Elektron. **Flashing modified firmware is at your own risk.**

| Status | |
|---|---|
| MK1, OS 1.73 | ✅ Working on hardware |
| Builds reproducibly | ✅ Fresh clone + patch gives the same files (`ac094b30…c3b4`, `dda5a4f8…8c6f`) |
| Step-lock (GRID REC: hold steps + pad) | ✅ Working on hardware |
| Sample Focus (hi-res, END, DIV, LAY, RND) | 🧪 Built, reviewed, reproducible; not yet hardware-tested |
| First-hit fix (a pad hit plays its marker at once, MK1 + MKII) | ✅ MK1 (file 5b): works on hardware, 2026-10-10. MKII: built, not yet hardware-tested |
| MKII (OS 1.73): CHOP + SMP CUT | 🧪 Built, reviewed, reproducible (`make DEVICE=mk2 samplefocus-cut`); not yet hardware-tested |
| SMP CUT (FILTER ×2: low/high cut), fixed for MK1 | 🧪 Built, reviewed, reproducible; first MK1 run pending |
| STR (time-stretch) | ❌ Removed: didn't work on hardware |
| Analog Keys (OS 1.56): chord memory | 🧪 Built, reviewed, reproducible (`make DEVICE=keys chord`); not yet hardware-tested |
| Analog Keys (OS 1.56): JOY RANDOM (joystick roll) | 🧪 Built, reviewed, reproducible (`make DEVICE=keys joy`); not yet hardware-tested |
| Recovery code untouched | ✅ Byte-for-byte identical to stock |

## Sample Focus + SMP CUT (newest, `make samplefocus-cut`)
CHOP's page (below, minus STR) plus rytm1_mods' **SMP CUT** page on **FILTER ×2** (LCT low cut / HCT high cut on the sample layer), fixed for the MK1: the original uses the MK2's kit and sound offsets, which can crash an MK1. CHOP owns the shared page hooks and hands SMP CUT's knobs to its code. Fitted by code compaction; no features dropped except STR. **SMP CUT has not run on an MK1 yet**: see the test card (S1–S10).
Expected sha256 of `build/AR1_OS1.73_0000_0001_0008.syx`: `ac094b30e7ea68022d00cd06c057229284df36dbc3176423fdd34b26dfffc3b4`.
Without SMP CUT: `make samplefocus` → `build/AR1_OS1.73_0000_0001.syx`, `dda5a4f8b63c58359da3f8f3f3fa70567273df74cd8d4ea136fd62bcd82a8c6f`.

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
- An Analog Rytm **MK1 on OS 1.73**. **Don't install OS 1.74**: these builds are for 1.73. Note: as of October 2026 Elektron's support pages offer only 1.74 for the MK1 and MKII, so if your unit is not already on 1.73 you need Elektron's 1.73 file from elsewhere (check it against the sha256 below). A 1.74 port is not done yet.
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
# ac094b30e7ea68022d00cd06c057229284df36dbc3176423fdd34b26dfffc3b4   (samplefocus-cut)
shasum -a 256 build/AR1_OS1.73_0000_0001.syx
# dda5a4f8b63c58359da3f8f3f3fa70567273df74cd8d4ea136fd62bcd82a8c6f   (samplefocus)
```

### 3. Flash (Transfer)
1. Back up your projects and +Drive in Transfer.
2. Connect USB, power on, and in Transfer > CONNECTION set MIDI IN and OUT to the Analog Rytm.
3. **Control build first:** drag `build/AR1_OS1.73_control.syx` onto Transfer > DROP and press **YES** on the Rytm. Check it boots and plays normally. This proves the toolchain on your unit.
4. **Then Sample Focus** (`build/AR1_OS1.73_0000_0001.syx`, no SMP CUT) and check CHOP works; only then **Sample Focus + SMP CUT** (`build/AR1_OS1.73_0000_0001_0008.syx`). SMP CUT's first-run checks: `flash/START_HERE.md` section B.
5. Don't power off during an update or during the first boot after it.

The hardware-proven step-lock build (CHOP + step-lock + euclid/velocity, sha256 `a96657b4…caf6`) is the previous patch, commit `f82a2f4` of this repo's `mods/0001-chop/rytm1_mods-chop.patch`, built with `make chop`.

If Transfer refuses a file as "same version", nothing was written. Use the recovery route below to send it.

### MKII (OS 1.73)
Not yet run on an MKII. Order and first-run checks: [`flash/MKII/START_HERE_MKII.md`](flash/MKII/START_HERE_MKII.md).
1. The unit must run **stock 1.73** (not 1.74). Elektron's MKII 1.73 file: `Analog-Rytm_MKII_OS1.73.syx`, sha256 `8ad671087ec30433d5407c7380d2396e0915ab931c5d3dd18a78bf284d3d1e52` → copy it to `stock/`.
2. Build:
```bash
make DEVICE=mk2 control           # build/mk2/ARMK2_OS1.73_control.syx            f3f6aad0cad09a7c3d531fb36a34fc78ed45bee126b9aab84cfed93e51d99c04
make DEVICE=mk2 samplefocus       # build/mk2/ARMK2_OS1.73_0000_0001.syx          2ff96af2f5ed05f5884e0dfa74f806091a867be46254250c4b404da609de792d
make DEVICE=mk2 samplefocus-cut   # build/mk2/ARMK2_OS1.73_0000_0001_0008.syx     782955769d2f199af5937eb8c945de659f1dad497b66aef07180c004089f6e8a
```
3. Flash control → CHOP → CHOP + SMP CUT. On the MKII, CHOP is the **third** SAMPLE page (SAMPLE already has two) and SMP CUT is FILTER ×2.
4. Recovery: same STARTUP-menu route (FUNC at power-on, TRIG 4, DIN MIDI) with the MKII stock file; the MKII bootstrap is a separate section these builds never touch.

### Analog Keys (OS 1.56): chord memory and JOY RANDOM
Not yet run on an Analog Keys. Order and first-run checks: [`flash/KEYS/START_HERE_KEYS.md`](flash/KEYS/START_HERE_KEYS.md). **Analog Keys only** — never a Rytm, never an Analog Four MKII.
1. The unit must run **stock 1.56**. Elektron's Analog Four / Analog Keys OS 1.56 file (sha256 `cda4459d14bfba40635440ad9dfa8fc183e5317e5e3ffa7116704f307fdf7010`) → save it as `stock/KEYS_Analog-Four_Analog-Keys_OS1.56.syx` (that exact name; the build looks for it).
2. Build (same clone and patch as above; the Keys file goes in `stock/` too):
```bash
make DEVICE=keys control   # build/keys/AKEYS_OS1.56_control.syx   6981fd94084e8f678e6579a224b009a80e50f9192499f63db2cfcc519f75a475
make DEVICE=keys chord     # build/keys/AKEYS_OS1.56_0010.syx      02a4c784e99d275d3685e3fed02dff84bf5bde8cd6c9440eba5c55e9f7ffa4de
make DEVICE=keys joy       # build/keys/AKEYS_OS1.56_0010_0011.syx ebc9a6ceef5b84847714e8271442e01b9c980fd40437f873ff0cc66f4c246616
```
3. Flash control → chord. **Chord memory:** hold 2-4 keys + FUNCTION + OCTAVE UP captures a chord; each key then plays it with itself as the root. FUNCTION + OCTAVE UP with nothing held turns it off. While HOLD is down or anything is latched, keys play single notes. **JOY RANDOM** (the `joy` build, flash after chord): FUNCTION + OCTAVE DOWN gives the active track's joystick new random assignments (pitch-bend slot 1 stays); `[NO/RELOAD]` + `[SOUND]` undoes it. Try it in a scratch project first. HOLD: tap HOLD on its own to release all; a stuck note: release every key and tap HOLD twice.
4. Recovery: FUNCTION at power-on, TRIG 4, DIN MIDI, Transfer's SYSEX TRANSFER page ("OS Upgrade via device startup menu") with the stock 1.56 file.

### If it won't boot: recovery
1. Hold **FUNC** while powering on.
2. Press **TRIG 4** (OS UPGRADE).
3. In Transfer > CONNECTION, choose **LEGACY OS UPGRADE**, and send the **stock** `Analog-Rytm_OS1.73.syx` over **DIN MIDI** (not USB).

This route runs from the Rytm's recovery code in flash, which CHOP never touches.

**Do not flash rytm1_mods' SMP CUT or RANDOM builds on an MK1.** They use an MK2 memory offset that is wrong for the MK1.

## Tested on hardware (MK1, OS 1.73)
- ⚠️ A pad hit plays from its marker on the first hit: passed on 2026-10-05 (file 2, build `3ea80d31…b00b`), but on 2026-10-09 every CHOP build, step-lock included, was heard landing between markers and locking in after repeats. Likely cause traced in the stock code (the engine glides a start point set like a knob turn; p-locks don't glide); fix built into `make samplefocus` / `make samplefocus-cut` (MK1 and MKII); ✅ works on the MK1 with file 5b (2026-10-10), MKII not yet tested.
- ✅ Under live REC, the STA p-lock lands on the trig's step.
- ✅ The CHOP page draws and switches back to the sample page.
- ✅ No crashes or stuck notes under mashing and fast retriggers.
- ✅ Step-lock: in GRID REC, holding steps + hitting a pad writes that pad's marker as an STA p-lock.
- ⏳ Reinstalling stock 1.73 over CHOP: not yet tried.

## What's in this repo
| Path | What |
|---|---|
| `mods/0001-chop/rytm1_mods-chop.patch` | all the mods (CHOP, SMP CUT fix, MKII port, Keys chord and JOY RANDOM), as one patch series for rytm1_mods @ `2fae7ce` |
| `mods/0011-joyrand/src/` | Analog Keys JOY RANDOM source (joystick roll), same patch |
| `mods/0010-chord/src/` | Analog Keys chord memory source (`stub.s`, `mod.toml`, `design.md` with proofs and test card); built from the same patch |
| `mods/0001-chop/src/` | the mod source (`stub.s`, `mod.toml`, and `design.md` with every hook, address and the full test card) |
| `proto/chop/` | a Mac-side prototype (Rust, MIDI only, no firmware): pads → CC 28 → trigger. Works on MK1 and MK2 |
| `REPORT.md` | research: who has reverse-engineered the Rytm, and the risks |
| `docs/` | design notes and hazards |

## Credits
- **[gdeo607/rytm1_mods](https://github.com/gdeo607/rytm1_mods)**: the MK1 mod framework, symbol map and build/verify tooling that CHOP is built on.
- **[mischa85/elektron-firmware-tool](https://github.com/mischa85/elektron-firmware-tool)** (MIT): Elektron OS container tool.
- **[irpina/elekloader](https://github.com/irpina/elekloader)**: mod loader.

Elektron, Analog Rytm and Overbridge are trademarks of Elektron Music Machines. This project contains no Elektron firmware.
