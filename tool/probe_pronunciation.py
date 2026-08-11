"""Synthesise a word several ways, to find a spelling the voice says correctly.

Chirp deletes the inherent schwa in some words - हमारा comes out "hmaara"
instead of "ha-maa-ra". We cannot retrain the voice, but we can change what we
SEND it without changing what the screen SHOWS, so the fix is a lookup applied
only at synthesis time.

This probe exists to find out which respelling works, empirically, rather than
guessing. Each candidate becomes its own mp3, named after the idea it tests.

    python tool/probe_pronunciation.py
"""

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import generate_audio as G   # noqa: E402

SENT = 'माँ, हमारा आधा सफ़र पूरा हो गया।'

CANDIDATES = [
    # (filename, text to send)
    ('01_word_alone', 'हमारा।'),
    ('02_in_sentence', SENT),
    # A ZWNJ after the consonant is the standard hint that the inherent vowel
    # is NOT to be dropped. Invisible on screen if it ever leaked through.
    ('03_zwnj', 'माँ, ह‌मारा आधा सफ़र पूरा हो गया।'),
    # Explicit short-a. Wrong orthography, but we are writing for an ear.
    ('04_explicit_a', 'माँ, हअमारा आधा सफ़र पूरा हो गया।'),
    # The synonym, in case the fix is simply to avoid the word.
    ('05_synonym', 'माँ, अपना आधा सफ़र पूरा हो गया।'),
    # Slower - schwa deletion sometimes eases when the voice is not rushing.
    ('06_slower_rate', SENT),
]


def main():
    tok = G.token()
    os.makedirs('build/audio/probe', exist_ok=True)
    for name, text in CANDIDATES:
        rate = 0.85 if name.endswith('slower_rate') else 1.0
        seg = G.synth(text, G.VOICE_HI, rate, tok)
        out = 'build/audio/probe/' + name + '.mp3'
        G.stitch([(seg, 0)], out)
        print('%-18s %s' % (name, out))
    print()
    print('Listen for the first word after "माँ," - is it ha-maa-ra or hmaara?')


if __name__ == '__main__':
    main()
