# analog rytm firmware — sample chop mode

Goal: a chop mode on the Analog Rytm. Pick one track; the 12 pads fire its sample from 12 stored start positions (STA 0–120). MK1 first, MKII the target.

Start with [REPORT.md](REPORT.md) (who has reverse engineered what, risks, plan) and [docs/DESIGN.md](docs/DESIGN.md).

| path | what |
|---|---|
| `REPORT.md` | research and recommendation, 2026-10-05 |
| `docs/DESIGN.md` | the chop mode spec and the three phases |
| `docs/HAZARDS.md` | brick risk and the rules before any flash |
| `proto/` | phase 1: host-side prototype through the bridge, no firmware |
| `mods/0001-chop/` | phase 2: the firmware mod, laid out like rytm1_mods' `mods/NNNN-slug/` |
| `upstream/` | how to fetch the third-party projects (not vendored, see licenses) |
| `stock/` | your own stock `.syx` files; never committed, never written to |

Nothing here has been built or flashed.
