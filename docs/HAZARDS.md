# Hazards — read before any flash

1. MK1: the `.syx` has one section and the recovery bootstrap lives inside it (rytm1_mods `docs/HAZARDS.md` gives the range `0x4028c710..0x402a1b24`). A mod byte in that range can break recovery. MKII keeps the bootstrap separate.
2. Recovery (bootstrap intact): FUNC at power-on → TRIG 4 (OS UPGRADE) → send stock `.syx` over DIN MIDI. Own a DIN MIDI interface and the exact stock file first.
3. Prove the toolchain before trusting it: unpack and repack the stock file with no changes; it must match byte for byte.
4. Mods pin an OS version (MK1 1.73, MKII 1.72). Do not mix versions.
5. Flashing is the owner's act. Warranty and Elektron's forum rules apply; do not post mod files or instructions on Elektronauts.
6. rytm1_mods and analog-rytm-mkii-research have no license: local use only until the authors say otherwise.
