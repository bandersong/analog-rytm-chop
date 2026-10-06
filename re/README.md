# re — MK1 OS 1.72 addresses

`port_1.73_to_1.72.json`: every symbol in rytm1_mods' `re/symbols.toml` (MK1 OS 1.73) located in the stock MK1 OS 1.72 MAIN OS (sha256 be5295a5…9130), plus the embedded bootstrap range. Each was found from the 1.73 evidence by one agent and re-derived by an independent skeptic (2026-10-05; run wf_482845f2-207, full evidence in build/1.72/port/journal.jsonl).

**Never write in the 1.72 embedded bootstrap: [0x4027fd90, 0x402951ac)** (file offsets [0x27f990, 0x294dac)). Its sha256 equals the 1.73 map's embedded_bootstrap_sha256 (re-hashed by hand), so the bootstrap is byte-identical in 1.72 and 1.73.
