//! chop — pads fire one Rytm track from 12 sample-start markers (host-side prototype).
//!
//!   chop ports                         list MIDI ports
//!   chop monitor  [--port-match S]     print everything the Rytm sends
//!   chop learn    [--port-match S] [--map FILE]   press pads 1..12 in order, save the map
//!   chop run --track N [--channel C] [--markers a,b,..] [--slice-end] [--scale raw|linear]
//!            [--map FILE] [--port-match S] [--dry-run]

mod chop;

use chop::{equal_markers, parse_markers, Chopper, Config, Scale};
use midir::{MidiInput, MidiOutput, MidiOutputConnection};
use std::collections::HashMap;
use std::io::{self, BufRead};
use std::sync::mpsc;

const DEFAULT_PORT_MATCH: &str = "Elektron Analog Rytm MKII"; // same as the bridge daemon
const DEFAULT_MAP: &str = "pads.json";

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let result = match args.first().map(String::as_str) {
        Some("ports") => ports(),
        Some("monitor") => monitor(&flags(&args[1..])),
        Some("learn") => learn(&flags(&args[1..])),
        Some("run") => run(&flags(&args[1..])),
        _ => Err("usage: chop ports | monitor | learn | run --track N  (see src/main.rs header)".into()),
    };
    if let Err(e) = result {
        eprintln!("chop: {e}");
        std::process::exit(1);
    }
}

fn flags(args: &[String]) -> HashMap<String, String> {
    let mut map = HashMap::new();
    let mut it = args.iter().peekable();
    while let Some(a) = it.next() {
        if let Some(key) = a.strip_prefix("--") {
            let value = match it.peek() {
                Some(v) if !v.starts_with("--") => it.next().unwrap().clone(),
                _ => "true".to_string(),
            };
            map.insert(key.to_string(), value);
        }
    }
    map
}

fn port_match(f: &HashMap<String, String>) -> String {
    f.get("port-match").cloned().unwrap_or_else(|| DEFAULT_PORT_MATCH.to_string())
}

fn ports() -> Result<(), String> {
    let input = MidiInput::new("chop-list").map_err(|e| e.to_string())?;
    let output = MidiOutput::new("chop-list").map_err(|e| e.to_string())?;
    for p in input.ports() {
        println!("in : {}", input.port_name(&p).unwrap_or_default());
    }
    for p in output.ports() {
        println!("out: {}", output.port_name(&p).unwrap_or_default());
    }
    Ok(())
}

/// Opens the input port; every message goes down the channel.
fn open_input(
    pm: &str,
) -> Result<(midir::MidiInputConnection<()>, mpsc::Receiver<Vec<u8>>), String> {
    let mut input = MidiInput::new("chop-in").map_err(|e| e.to_string())?;
    input.ignore(midir::Ignore::All);
    let port = input
        .ports()
        .into_iter()
        .find(|p| input.port_name(p).is_ok_and(|n| n.contains(pm)))
        .ok_or_else(|| format!("no MIDI input contains {pm:?} (is the Rytm connected? try `chop ports`)"))?;
    let (tx, rx) = mpsc::channel();
    let conn = input
        .connect(&port, "chop-in", move |_, msg, _| {
            let _ = tx.send(msg.to_vec());
        }, ())
        .map_err(|e| e.to_string())?;
    Ok((conn, rx))
}

fn open_output(pm: &str) -> Result<MidiOutputConnection, String> {
    let output = MidiOutput::new("chop-out").map_err(|e| e.to_string())?;
    let port = output
        .ports()
        .into_iter()
        .find(|p| output.port_name(p).is_ok_and(|n| n.contains(pm)))
        .ok_or_else(|| format!("no MIDI output contains {pm:?}"))?;
    output.connect(&port, "chop-out").map_err(|e| e.to_string())
}

fn hex(msg: &[u8]) -> String {
    msg.iter().map(|b| format!("{b:02X}")).collect::<Vec<_>>().join(" ")
}

fn monitor(f: &HashMap<String, String>) -> Result<(), String> {
    let (_conn, rx) = open_input(&port_match(f))?;
    eprintln!("monitoring {:?}; Ctrl-C to stop", port_match(f));
    for msg in rx {
        println!("{}", hex(&msg));
    }
    Ok(())
}

fn learn(f: &HashMap<String, String>) -> Result<(), String> {
    let path = f.get("map").cloned().unwrap_or_else(|| DEFAULT_MAP.to_string());
    let (_conn, rx) = open_input(&port_match(f))?;
    let mut pads: Vec<(u8, u8)> = vec![];
    eprintln!("press pads 1..12 in order (needs PAD DEST = EXT or INT+EXT)");
    eprintln!("pad 1?");
    for msg in rx {
        if msg.len() == 3 && msg[0] & 0xF0 == 0x90 && msg[2] > 0 {
            let key = (msg[0] & 0x0F, msg[1]);
            if pads.contains(&key) {
                eprintln!("  already have ch {} note {}; press pad {}", key.0 + 1, key.1, pads.len() + 1);
                continue;
            }
            pads.push(key);
            eprintln!("  pad {} = ch {} note {}", pads.len(), key.0 + 1, key.1);
            if pads.len() == 12 {
                break;
            }
            eprintln!("pad {}?", pads.len() + 1);
        }
    }
    let json = serde_json::json!({
        "pads": pads.iter().map(|(c, n)| serde_json::json!({"channel": c + 1, "note": n})).collect::<Vec<_>>()
    });
    std::fs::write(&path, serde_json::to_string_pretty(&json).unwrap()).map_err(|e| e.to_string())?;
    eprintln!("saved {path}");
    Ok(())
}

fn load_map(path: &str) -> Result<Vec<(u8, u8)>, String> {
    let text = std::fs::read_to_string(path)
        .map_err(|e| format!("cannot read pad map {path:?}: {e} (run `chop learn` first)"))?;
    let v: serde_json::Value = serde_json::from_str(&text).map_err(|e| e.to_string())?;
    let pads = v["pads"].as_array().ok_or("pad map has no \"pads\" array")?;
    let out: Vec<(u8, u8)> = pads
        .iter()
        .map(|p| {
            let c = p["channel"].as_u64().filter(|c| (1..=16).contains(c)).ok_or("bad channel")?;
            let n = p["note"].as_u64().filter(|n| *n < 128).ok_or("bad note")?;
            Ok(((c - 1) as u8, n as u8))
        })
        .collect::<Result<_, &str>>()?;
    if out.len() != 12 {
        return Err(format!("pad map has {} pads, need 12", out.len()));
    }
    Ok(out)
}

fn number(f: &HashMap<String, String>, key: &str, lo: u8, hi: u8) -> Result<Option<u8>, String> {
    f.get(key)
        .map(|v| v.parse::<u8>().ok().filter(|n| (lo..=hi).contains(n)).ok_or(format!("--{key} must be {lo}-{hi}")))
        .transpose()
}

fn run(f: &HashMap<String, String>) -> Result<(), String> {
    let track = number(f, "track", 1, 12)?.ok_or("--track 1-12 is required")?;
    // Default track channels on the Rytm are 1-12 for tracks 1-12; pass --channel if yours differ.
    let channel = number(f, "channel", 1, 16)?.unwrap_or(track);
    let markers = match f.get("markers") {
        Some(m) => parse_markers(m)?,
        None => equal_markers(),
    };
    let scale = match f.get("scale").map(String::as_str) {
        None | Some("raw") => Scale::Raw,
        Some("linear") => Scale::Linear,
        Some(s) => return Err(format!("--scale must be raw or linear, not {s:?}")),
    };
    let map_path = f.get("map").cloned().unwrap_or_else(|| DEFAULT_MAP.to_string());
    let pads = load_map(&map_path)?;
    if pads.iter().any(|(c, n)| *c == channel - 1 && *n == track - 1) {
        return Err("a pad sends the same channel+note chop sends as the trigger; that would loop".into());
    }
    let cfg = Config {
        track: track - 1,
        channel: channel - 1,
        markers,
        slice_end: f.contains_key("slice-end"),
        scale,
        pads,
    };
    let dry = f.contains_key("dry-run");
    eprintln!(
        "chop: track {track} on ch {channel}, markers {:?}, slice-end {}, scale {:?}{}",
        cfg.markers, cfg.slice_end, cfg.scale, if dry { " (DRY RUN: nothing sent)" } else { "" }
    );
    let mut chopper = Chopper::new(cfg);

    if dry {
        // Read hex messages from stdin ("99 24 64") and print what would be sent.
        for line in io::stdin().lock().lines() {
            let line = line.map_err(|e| e.to_string())?;
            let msg: Vec<u8> = line.split_whitespace().filter_map(|t| u8::from_str_radix(t, 16).ok()).collect();
            for out in chopper.handle(&msg) {
                println!("{}", hex(&out));
            }
        }
        return Ok(());
    }

    let pm = port_match(f);
    let mut out = open_output(&pm)?;
    let (_conn, rx) = open_input(&pm)?;
    eprintln!("running; Ctrl-C to stop");
    for msg in rx {
        for o in chopper.handle(&msg) {
            out.send(&o).map_err(|e| e.to_string())?;
        }
    }
    Ok(())
}
