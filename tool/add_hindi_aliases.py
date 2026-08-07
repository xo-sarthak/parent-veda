"""Append Hindi search terms to an entry's existing English alias list.

`aliases` is a plain List<String> of things a mother might TYPE. It is matched
with `alias.toLowerCase().contains(query)` in global_search.dart, so it is a
search index, not display copy.

That makes widening it to LocalizedText the wrong move twice over: it forces a
model change for something nobody reads, and - the real risk - REPLACING the
list would delete the Latin terms that let an English or transliterating typist
find anything. `crocin`, `dolo`, `nariyal pani` are how many Indian mothers
actually search, whichever language the app is rendering in.

So the Hindi is ADDED beside the English rather than instead of it. One list,
both scripts, no model change, and search improves in both directions.

    python tool/add_hindi_aliases.py <file.dart> <glossary.tsv> [--dry]
"""

import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from apply_glossary import comment_spans, in_any, literal, load  # noqa: E402

# `aliases:` in can_i/report_findings, `keywords:` in veda_showcase and
# symptom_data - the same thing under two names, both matched with
# contains() and never rendered.
ALIASES = re.compile(r"(?:aliases|keywords): \[([^\]]*)\]")
LIT = re.compile(r"(['\"])((?:\\.|(?!\1).)*?)\1")


def main():
    path, tsv = sys.argv[1], sys.argv[2]
    dry = '--dry' in sys.argv
    glossary = load(tsv)
    src = open(path, encoding='utf-8').read()
    comments = comment_spans(src)

    added, lists = 0, 0

    def one(m):
        nonlocal added, lists
        if in_any(m.start(), comments):
            return m.group(0)
        body = m.group(1)
        # group(2), not group(1): group 1 is the QUOTE CHARACTER. Reading the
        # wrong group made every lookup miss and the run report a confident
        # "0 added" - a silent no-op is the worst failure a tool like this has.
        existing = [x.group(2) for x in LIT.finditer(body)]
        if not existing:
            return m.group(0)
        lists += 1
        extra = []
        for term in existing:
            hi = glossary.get(term)
            # Skip when there is no translation, when it is the same string
            # (a brand like Dolo 650 - already searchable), and when the term
            # is already in the list.
            if not hi or hi == term or hi in existing or hi in extra:
                continue
            extra.append(hi)
        if not extra:
            return m.group(0)
        added += len(extra)
        return (m.group(0).split('[')[0] + '[' + body.rstrip().rstrip(',') + ', '
                + ', '.join(literal(h) for h in extra) + ']')

    out = ALIASES.sub(one, src)

    print(path)
    print('  alias lists    : ' + str(lists))
    print('  Hindi terms added: ' + str(added))
    if dry:
        print('  (dry run - nothing written)')
        return
    open(path, 'w', encoding='utf-8', newline='').write(out)


if __name__ == '__main__':
    main()
