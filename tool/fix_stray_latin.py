"""Unquoted Latin inside the Hindi becomes Devanagari; quoted terms stay.

The rule this settles, which twenty independent translators each guessed at:

  QUOTED  'zone of proximal development', 'name it to tame it', 'good enough'
          stay Latin. Introducing a foreign term in quotes and glossing it is
          how Hindi prose actually handles imported vocabulary, and the quotes
          tell the reader it is a foreign label rather than a word she is
          expected to know.

  NAMES   Carol Dweck, Dan Siegel, Donald Winnicott stay Latin. A person's
          name is not translated.

  BARE    `nervous system`, `oxytocin`, `Charts and apps`, `skin to skin`
          become Devanagari. These are not labels being introduced - they are
          ordinary words in the middle of a sentence, and every one of them is
          a word the hi-IN narration voice will stumble over, because a Hindi
          voice cannot read Roman script at all. That is the same defect that
          made the original Latin-script Hinglish unspeakable, which is the
          whole reason this migration exists.

One exception is deliberately left alone: the week_23 etymology passage about
'discipline' / 'disciplina' / 'disciple'. There the Latin words ARE the
content - the sentence is about the shape of the English word - so rendering
them in Devanagari would destroy the point being made.

    python tool/fix_stray_latin.py --dry
    python tool/fix_stray_latin.py
"""

import glob
import io
import re
import sys

# Bare Latin -> Devanagari. Spoken-Hindi transliterations, not textbook
# coinages: नर्वस सिस्टम is what a Hindi speaker actually says; तंत्रिका तंत्र
# is what a textbook says.
SWAPS = [
    (r'\bnervous system\b', 'नर्वस सिस्टम'),
    (r'\boxytocin\b', 'ऑक्सीटोसिन'),
    (r'\bAttachment\b', 'अटैचमेंट'),
    (r'\bskin to skin\b', 'स्किन-टू-स्किन'),
    (r'\bskin-to-skin\b', 'स्किन-टू-स्किन'),
    (r'\bsausage\b', 'सॉसेज'),
    (r'\bCharts\b', 'चार्ट'),
    (r'\bapps\b', 'ऐप्स'),
    (r'\bmilestones\b', 'पड़ाव'),
    (r'\bfinish line\b', 'फ़िनिश लाइन'),
]

QUOTED = re.compile(r"'[^']*'")


def fix(hi):
    """Apply swaps only OUTSIDE single-quoted spans."""
    out = []
    last = 0
    for m in QUOTED.finditer(hi):
        out.append(sub_all(hi[last:m.start()]))
        out.append(m.group(0))          # quoted span untouched
        last = m.end()
    out.append(sub_all(hi[last:]))
    return ''.join(out)


def sub_all(s):
    for pat, rep in SWAPS:
        s = re.sub(pat, rep, s)
    return s


def main():
    dry = '--dry' in sys.argv
    total = 0
    for path in sorted(glob.glob('tool/hindi/h_batch*.done.tsv')):
        lines = [l.rstrip('\n') for l in io.open(path, encoding='utf-8')
                 if l.strip()]
        changed = []
        n = 0
        for l in lines:
            ptr, _, hi = l.partition('\t')
            new = fix(hi)
            if new != hi:
                n += 1
                if n <= 2 and dry:
                    was = [w for p, _ in SWAPS
                           for w in re.findall(p, hi)]
                    print('  %s\n     %s' % (ptr, ' | '.join(was[:6])))
            changed.append(ptr + '\t' + new)
        if n:
            print('%-32s %3d row(s)' % (path.split('/')[-1], n))
            if not dry:
                io.open(path, 'w', encoding='utf-8', newline='').write(
                    '\n'.join(changed) + '\n')
            total += n
    print('\n%s %d rows' % ('WOULD FIX' if dry else 'FIXED', total))


if __name__ == '__main__':
    main()
