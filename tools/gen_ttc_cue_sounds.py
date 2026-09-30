"""Generate the Trying to Conceive practice cue sounds.

Writes five short, soft WAV files to assets/audio/cues/ (44.1 kHz, 16-bit,
mono) and checks each one before saving. Run from the repo root:

    python tools/gen_ttc_cue_sounds.py

Why generated rather than downloaded (2026-09-28): the cues are pure tones, a
file this small is easier to make than to license, and the numbers below are
the whole design, so a cue that is too loud or too bright is a one-line change
and a re-run, not a new search for a sound.

The rules every cue follows, and the check at the bottom enforces:
  * no click: the first and last samples are zero, the attack and release
    are raised-cosine fades, and a glide integrates its frequency into the
    phase, so the waveform never jumps;
  * nothing harsh: every partial sits between about 300 and 900 Hz;
  * quiet: the peak is about -10 dBFS, and the app plays it lower still;
  * small: under 60 KB, so 600 ms is the longest a cue may run.

Uses numpy and the standard library's wave module only.
"""

from __future__ import annotations

import os
import wave

import numpy as np

RATE = 44100
PEAK = 0.32  # about -10 dBFS
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "cues")


def _t(seconds: float) -> np.ndarray:
    return np.arange(int(RATE * seconds)) / RATE


def _fade(n: int, attack: float, release: float) -> np.ndarray:
    """A raised-cosine fade in and out, exactly zero at both ends."""
    env = np.ones(n)
    a = max(2, int(RATE * attack))
    r = max(2, int(RATE * release))
    env[:a] = 0.5 - 0.5 * np.cos(np.linspace(0, np.pi, a))
    env[-r:] = 0.5 + 0.5 * np.cos(np.linspace(0, np.pi, r))
    return env


def glide(f0: float, f1: float, seconds: float) -> np.ndarray:
    """A soft tone that slides from f0 to f1: rising for in, falling for out.

    The frequency is integrated into the phase (a cumulative sum), which is
    what keeps a glide smooth. Computing sin(2*pi*f(t)*t) directly would
    make the pitch race ahead of the slide and warble.
    """
    t = _t(seconds)
    # An eased slide, so the pitch settles rather than stopping dead.
    s = 0.5 - 0.5 * np.cos(np.pi * t / t[-1])
    f = f0 + (f1 - f0) * s
    phase = 2 * np.pi * np.cumsum(f) / RATE
    # A quiet fifth above for warmth, still under 900 Hz for these pitches.
    tone = np.sin(phase) + 0.18 * np.sin(1.5 * phase)
    return tone * _fade(len(t), attack=0.09, release=0.22)


def steady(f: float, seconds: float) -> np.ndarray:
    """One flat, quiet tone: the hold."""
    t = _t(seconds)
    tone = np.sin(2 * np.pi * f * t) + 0.12 * np.sin(2 * np.pi * 1.5 * f * t)
    return 0.8 * tone * _fade(len(t), attack=0.06, release=0.16)


def bell(f: float, seconds: float, decay: float, delay: float = 0.0,
         total: float | None = None) -> np.ndarray:
    """A struck tone that dies away, with a short fade in so it cannot click."""
    total = total or seconds
    out = np.zeros(int(RATE * total))
    t = _t(seconds)
    tone = (np.sin(2 * np.pi * f * t) * np.exp(-t / decay)
            + 0.25 * np.sin(2 * np.pi * 1.5 * f * t) * np.exp(-t / (decay * 0.6)))
    tone *= _fade(len(t), attack=0.008, release=0.05)
    start = int(RATE * delay)
    end = min(len(out), start + len(tone))
    out[start:end] += tone[: end - start]
    return out


def _normalise(x: np.ndarray) -> np.ndarray:
    return x / np.max(np.abs(x)) * PEAK


CUES = {
    # Breathe in: rises G4 to C5, as a breath fills.
    "breathe_in.wav": lambda: glide(392.0, 523.25, 0.55),
    # Breathe out: falls C5 to G4, the same two notes the other way.
    "breathe_out.wav": lambda: glide(523.25, 392.0, 0.55),
    # Hold: one level A4, shorter and quieter, so a pause sounds like a pause.
    "hold.wav": lambda: steady(440.0, 0.35),
    # A step changes: a single soft tap of D5, gone in 150 ms (its fifth,
    # 880 Hz, is the brightest partial of any cue).
    "step.wav": lambda: bell(587.33, 0.15, decay=0.05),
    # The end: two bell notes, G4 then C5, that ring out together.
    "done.wav": lambda: (bell(392.0, 0.6, decay=0.22, total=0.6)
                         + 0.8 * bell(523.25, 0.48, decay=0.2, delay=0.12,
                                      total=0.6)),
}


def check(name: str, x: np.ndarray) -> None:
    """Refuse a cue that would click, sting or weigh too much."""
    assert abs(x[0]) < 1e-3 and abs(x[-1]) < 1e-3, f"{name}: ends not silent"
    # A click is a jump between neighbouring samples. At -10 dBFS a 900 Hz
    # sine moves at most 2*pi*900/44100*0.32 = 0.041 per sample.
    jump = float(np.max(np.abs(np.diff(x))))
    assert jump < 0.05, f"{name}: a jump of {jump:.3f} would click"
    spec = np.abs(np.fft.rfft(x)) ** 2
    freqs = np.fft.rfftfreq(len(x), 1 / RATE)
    peak_hz = float(freqs[np.argmax(spec)])
    assert 300 <= peak_hz <= 900, f"{name}: loudest at {peak_hz:.0f} Hz"
    high = float(spec[freqs > 1000].sum() / spec.sum())
    assert high < 0.01, f"{name}: {high:.2%} of the energy above 1 kHz"
    size = 44 + 2 * len(x)
    assert size < 60_000, f"{name}: {size} bytes"
    print(f"{name:16} {len(x) / RATE * 1000:4.0f} ms  {size / 1000:5.1f} KB  "
          f"loudest {peak_hz:4.0f} Hz  above 1 kHz {high:.3%}  "
          f"max step {jump:.3f}")


def main() -> None:
    os.makedirs(OUT, exist_ok=True)
    for name, make in CUES.items():
        x = _normalise(make())
        x[0] = 0.0
        x[-1] = 0.0
        check(name, x)
        pcm = np.round(x * 32767).astype("<i2")
        with wave.open(os.path.join(OUT, name), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(pcm.tobytes())


if __name__ == "__main__":
    main()
