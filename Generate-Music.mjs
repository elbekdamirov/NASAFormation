// Generates original seamless game stems. Usage: node Generate-Music.mjs
import { mkdirSync, writeFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
const path = fileURLToPath(new URL("./game/music/", import.meta.url));
mkdirSync(path, { recursive: true });
const rate = 22050;
const beat = 0.75;
const length = 64 * beat;
const steps = Math.round(rate * length);
const layers = [Buffer.alloc(44 + steps * 4), Buffer.alloc(44 + steps * 4)];
const spaceChords = [[38, 57, 60, 65, 69], [34, 53, 57, 60, 65],
  [41, 57, 60, 64, 67], [36, 55, 60, 62, 64],
  [38, 57, 62, 65, 69], [33, 52, 55, 60, 64],
  [34, 53, 58, 62, 65], [36, 55, 60, 62, 67]];
const melody = [4, 2, -1, 1, -1, 3, 2, -1];
const tau = 2 * Math.PI;
const hz = (note) => 440 * 2 ** ((note - 69) / 12);
const oscillator = (frequency, t) => Math.sin(tau * frequency * t);
const smooth = (a, b, value) => {
  const t = Math.max(0, Math.min(1, (value - a) / (b - a)));
  return t * t * (3 - 2 * t);
};
const chordFrequencies = spaceChords.map((chord) => chord.map(hz));
for (const buffer of layers) {
  buffer.write("RIFF", 0); buffer.writeUInt32LE(buffer.length - 8, 4);
  buffer.write("WAVEfmt ", 8); buffer.writeUInt32LE(16, 16);
  buffer.writeUInt16LE(1, 20); buffer.writeUInt16LE(2, 22);
  buffer.writeUInt32LE(rate, 24); buffer.writeUInt32LE(rate * 4, 28);
  buffer.writeUInt16LE(4, 32); buffer.writeUInt16LE(16, 34);
  buffer.write("data", 36); buffer.writeUInt32LE(steps * 4, 40);
}
for (let sample = 0; sample < steps; sample++) {
  const t = sample / rate;
  const measure = t / (beat * 8);
  const section = Math.floor(measure);
  const fraction = measure - section;
  const notes = chordFrequencies[section];
  const oldNotes = chordFrequencies[(section + 7) % 8];
  const blend = smooth(0, 0.24, fraction);
  const beatPosition = t / beat;
  const beatIndex = Math.floor(beatPosition);
  const pulse = (beatPosition - beatIndex) * beat;
  const phraseNote = melody[beatIndex % 8];
  const kick = Math.sin(tau * (43 * pulse + 2.1 * (1 - Math.exp(-31 * pulse)))) * Math.exp(-pulse * 17);
  const tick = oscillator(1620, pulse) * oscillator(2243, pulse) * Math.exp(-pulse * 98);
  const fade = smooth(0, 0.06, t) * smooth(0, 0.12, length - t);
  for (let ear = 0; ear < 2; ear++) {
    const detune = ear ? 1.0013 : 0.9986;
    let pad = 0;
    for (let voice = 0; voice < 5; voice++) {
      const note = notes[voice], old = oldNotes[voice];
      const a = oscillator(note * detune, t) * 0.72 + oscillator(note * 2.001, t) * 0.23;
      const b = oscillator(old * detune, t) * 0.72 + oscillator(old * 2.001, t) * 0.23;
      pad += (a * blend + b * (1 - blend)) * (0.024 + 0.007 * oscillator((voice + 1) / 30, t));
    }
    let bell = 0;
    if (phraseNote >= 0) {
      const f = notes[phraseNote] * (phraseNote < 3 ? 2 : 1);
      bell = (oscillator(f * detune, pulse) + 0.23 * oscillator(f * 2.008, pulse)) *
        Math.exp(-pulse * 4.9) * smooth(0, 0.02, pulse) * 0.056;
    }
    const bass = oscillator(notes[0] * detune, pulse) * Math.exp(-pulse * 3.8) * smooth(0, 0.018, pulse);
    const action = bass * 0.115 + kick * (beatIndex % 4 === 0 ? 0.15 : 0.073) + tick * 0.034;
    const offset = 44 + sample * 4 + ear * 2;
    const encode = (value) => Math.round(Math.max(-1, Math.min(1, value * fade)) * 32767);
    layers[0].writeInt16LE(encode(pad + bell), offset);
    layers[1].writeInt16LE(encode(action), offset);
  }
}
for (const [i, name] of ["traverse.wav", "response.wav"].entries()) writeFileSync(path + name, layers[i]);
