"""Does any passage commit to the reader's baby being a boy or a girl?

The app must never state or imply an unborn baby's sex - the product rule, and
PCPNDT behind it.

WHAT THIS DELIBERATELY DOES NOT FLAG, and why it matters:

  बच्चा is a GRAMMATICALLY masculine noun. "बच्चा देखता है" is the ordinary,
  neutral way a Hindi speaker says "the child watches" - about a daughter as
  readily as a son. Flagging that agreement would be linguistically wrong, and
  "fixing" it produces stilted Hindi that no mother would say aloud. Generic
  masculine agreement on बच्चा/शिशु is NOT a sex claim.

  The genuine claims are LEXICAL, not grammatical: बेटा, बेटी, लड़का, लड़की -
  words that mean son/daughter/boy/girl and cannot be read any other way.

  First-person baby voice is the separate case handled by extract_gendered.py:
  there the verb agreement IS the whole claim, because the sentence is the baby
  speaking about itself and there is no noun to carry generic gender.

STORY CHARACTERS ARE EXEMPT. `readToBaby` is folk tales, and a tale about a
king's daughter is not a claim about the reader's baby. Scoping to the fields
that describe HER baby is what keeps this signal worth reading.

KNOWN GOOD HIT, do not "fix" it: week_30 day 5 talkToBaby.motivation renders
"the child you once were" as `उस बच्ची से ... जो कभी आप थीं`. The बच्ची is the
MOTHER as a girl, and she is female, so the feminine form is right. This is a
review trigger, not a verdict - a hit means read the sentence, not change it.

    python tool/check_baby_sex.py
"""

import glob
import json
import re

# Lexical sex claims. Note बच्ची (a girl child) is included and बच्चा is not -
# the feminine form is marked, the masculine is the generic.
SEX = re.compile(r'बेटा|बेटी|बेटे|लड़का|लड़की|लड़के|बच्ची|पुत्र|पुत्री')

# Blocks that describe the reader's own baby. `readToBaby` is excluded on
# purpose - see the module docstring.
ABOUT_HER_BABY = ('babyLearning', 'grow', 'talkToBaby', 'nurture')


def main():
    hits = []
    for path in sorted(glob.glob('lib/data/home/*.json')
                       + ['lib/data/homeDailyContent.json']):
        try:
            doc = json.load(open(path, encoding='utf-8'))
        except Exception:
            continue
        days = doc if isinstance(doc, list) else [doc]
        for day in days:
            if not isinstance(day, dict):
                continue
            for block in ABOUT_HER_BABY:
                node = day.get(block)
                if isinstance(node, dict) and 'en' in node:
                    node = {block: node}
                if not isinstance(node, dict):
                    continue
                for field, t in node.items():
                    if not isinstance(t, dict) or 'en' not in t:
                        continue
                    hi = t.get('hi') or ''
                    m = SEX.search(hi)
                    if m:
                        hits.append((path.replace('\\', '/'), block, field,
                                     m.group(0), hi[:100]))

    if not hits:
        print('clean - no passage about her baby names a sex')
        return
    print('%d passage(s) name a sex:\n' % len(hits))
    for p, b, f, word, hi in hits:
        print('  %s  %s.%s  "%s"\n     %s' % (p, b, f, word, hi))


if __name__ == '__main__':
    main()
