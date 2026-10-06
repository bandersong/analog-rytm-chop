//! Pure chop logic: no MIDI I/O, so it is unit-testable.

pub const CC_SAMPLE_START: u8 = 28; // docs/reference/rytm.yaml (bridge): STA, CC 28, NRPN [1,12], 0-120
pub const CC_SAMPLE_END: u8 = 29; // END, CC 29, NRPN [1,13]
pub const STA_MAX: u8 = 120;

#[derive(Clone, Copy, Debug, PartialEq)]
pub enum Scale {
    /// CC value = marker value (0-120 sent as-is).
    Raw,
    /// CC value = marker scaled 0-120 -> 0-127.
    Linear,
}

#[derive(Clone, Debug)]
pub struct Config {
    /// Target track, 0-11.
    pub track: u8,
    /// Target track's MIDI channel, 0-15.
    pub channel: u8,
    /// 12 sample-start markers, 0-120, one per pad.
    pub markers: [u8; 12],
    /// Also set END to the next marker up, so each pad plays one slice.
    pub slice_end: bool,
    pub scale: Scale,
    /// (channel 0-15, note) each pad sends, pad 1 first.
    pub pads: Vec<(u8, u8)>,
}

pub fn equal_markers() -> [u8; 12] {
    let mut m = [0u8; 12];
    for (i, v) in m.iter_mut().enumerate() {
        *v = (i as u8) * 10;
    }
    m
}

pub fn parse_markers(text: &str) -> Result<[u8; 12], String> {
    let values: Vec<u8> = text
        .split(',')
        .map(|s| s.trim().parse::<u8>().map_err(|_| format!("bad marker {s:?}")))
        .collect::<Result<_, _>>()?;
    if values.len() != 12 {
        return Err(format!("need 12 markers, got {}", values.len()));
    }
    if let Some(v) = values.iter().find(|v| **v > STA_MAX) {
        return Err(format!("marker {v} is above {STA_MAX}"));
    }
    let mut m = [0u8; 12];
    m.copy_from_slice(&values);
    Ok(m)
}

fn to_cc(value: u8, scale: Scale) -> u8 {
    match scale {
        Scale::Raw => value.min(127),
        Scale::Linear => ((value as u32 * 127 + 60) / 120).min(127) as u8,
    }
}

/// END for a pad: the smallest marker above this pad's marker, else 120.
pub fn slice_end_for(markers: &[u8; 12], pad: usize) -> u8 {
    let start = markers[pad];
    markers.iter().copied().filter(|m| *m > start).min().unwrap_or(STA_MAX)
}

pub struct Chopper {
    pub cfg: Config,
    held: Option<usize>,
}

impl Chopper {
    pub fn new(cfg: Config) -> Self {
        Self { cfg, held: None }
    }

    fn pad_of(&self, channel: u8, note: u8) -> Option<usize> {
        self.cfg.pads.iter().position(|p| *p == (channel, note))
    }

    fn note_off(&self) -> Vec<u8> {
        vec![0x80 | self.cfg.channel, self.cfg.track, 0]
    }

    /// One incoming MIDI message in, the messages to send out.
    pub fn handle(&mut self, msg: &[u8]) -> Vec<Vec<u8>> {
        if msg.len() < 3 {
            return vec![];
        }
        let (kind, channel, note, vel) = (msg[0] & 0xF0, msg[0] & 0x0F, msg[1], msg[2]);
        let Some(pad) = self.pad_of(channel, note) else { return vec![] };
        let ch = self.cfg.channel;
        match kind {
            0x90 if vel > 0 => {
                let mut out = vec![];
                // Monophonic: release the previous slice before the next one starts.
                if self.held.is_some() {
                    out.push(self.note_off());
                }
                out.push(vec![0xB0 | ch, CC_SAMPLE_START, to_cc(self.cfg.markers[pad], self.cfg.scale)]);
                if self.cfg.slice_end {
                    let end = slice_end_for(&self.cfg.markers, pad);
                    out.push(vec![0xB0 | ch, CC_SAMPLE_END, to_cc(end, self.cfg.scale)]);
                }
                out.push(vec![0x90 | ch, self.cfg.track, vel]);
                self.held = Some(pad);
                out
            }
            0x80 | 0x90 if self.held == Some(pad) => {
                self.held = None;
                vec![self.note_off()]
            }
            _ => vec![],
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn cfg() -> Config {
        Config {
            track: 2,
            channel: 2,
            markers: equal_markers(),
            slice_end: false,
            scale: Scale::Raw,
            pads: (0..12).map(|i| (9u8, 36 + i as u8)).collect(),
        }
    }

    #[test]
    fn pad_sets_start_then_triggers() {
        let mut c = Chopper::new(cfg());
        let out = c.handle(&[0x99, 36 + 5, 100]);
        assert_eq!(out, vec![vec![0xB2, 28, 50], vec![0x92, 2, 100]]);
    }

    #[test]
    fn release_sends_note_off_only_for_held_pad() {
        let mut c = Chopper::new(cfg());
        c.handle(&[0x99, 36, 100]);
        assert!(c.handle(&[0x89, 37, 0]).is_empty());
        assert_eq!(c.handle(&[0x89, 36, 0]), vec![vec![0x82, 2, 0]]);
        c.handle(&[0x99, 36, 100]);
        assert_eq!(c.handle(&[0x99, 36, 0]), vec![vec![0x82, 2, 0]]); // note-on vel 0 = off
    }

    #[test]
    fn next_pad_releases_previous_first() {
        let mut c = Chopper::new(cfg());
        c.handle(&[0x99, 36, 100]);
        let out = c.handle(&[0x99, 47, 90]);
        assert_eq!(out, vec![vec![0x82, 2, 0], vec![0xB2, 28, 110], vec![0x92, 2, 90]]);
    }

    #[test]
    fn unmapped_and_short_messages_ignored() {
        let mut c = Chopper::new(cfg());
        assert!(c.handle(&[0x90, 36, 100]).is_empty()); // wrong channel
        assert!(c.handle(&[0xB9, 1, 2]).is_empty());
        assert!(c.handle(&[0xF8]).is_empty());
    }

    #[test]
    fn slice_end_uses_next_marker_up() {
        let mut k = cfg();
        k.slice_end = true;
        k.markers = parse_markers("60,0,30,90,10,20,40,50,70,80,100,110").unwrap();
        let mut c = Chopper::new(k);
        assert_eq!(c.handle(&[0x99, 36, 100])[1], vec![0xB2, 29, 70]);
        let last = c.handle(&[0x99, 47, 100]); // marker 110 -> END 120
        assert_eq!(last[2], vec![0xB2, 29, 120]);
    }

    #[test]
    fn linear_scale_maps_120_to_127() {
        assert_eq!(to_cc(120, Scale::Linear), 127);
        assert_eq!(to_cc(0, Scale::Linear), 0);
        assert_eq!(to_cc(60, Scale::Linear), 64);
        assert_eq!(to_cc(60, Scale::Raw), 60);
    }

    #[test]
    fn marker_parsing_validates() {
        assert!(parse_markers("1,2,3").is_err());
        assert!(parse_markers("0,10,20,30,40,50,60,70,80,90,100,121").is_err());
        assert_eq!(parse_markers("0,10,20,30,40,50,60,70,80,90,100,110").unwrap(), equal_markers());
    }
}
