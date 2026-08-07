"""Write translated Hindi back into JSON {en, hi} pairs, addressed by path.

The counterpart to extract_json_hinglish. Keyed on the JSON POINTER, not on the
English text, because the father content repeats: several weekly files carry
the same sentence, and a text-keyed applier would collapse them onto one
translation or refuse the duplicate. The path is exact and unique.

Writes each file only if something in it changed, and preserves the original
indent so the diff is the translated strings and nothing else.

    python tool/apply_json_hindi.py <table.tsv> [--dry]
"""

import json
import sys


def load(tsv):
    """path -> hindi, for rows whose Hindi cell is filled."""
    out = {}
    for line in open(tsv, encoding='utf-8'):
        line = line.rstrip('\n')
        if not line.strip() or line.startswith('#'):
            continue
        cols = line.split('\t')
        if len(cols) < 4 or not cols[1].strip():
            continue
        out[cols[3]] = cols[1].replace('\\n', '\n')
    return out


def detect_indent(raw):
    """The file's own indent, so rewriting it changes only the strings.

    These files are not uniform: 37 of the 38 father JSONs use indent=1 and one
    uses 2. Hardcoding either would reformat every line of every other file,
    burying 90 translated strings in a 38-file whitespace diff that nobody can
    review. Round-trip is verified by the caller before anything is written.
    """
    for line in raw.split('\n')[1:]:
        if line.strip():
            return len(line) - len(line.lstrip())
    return 2


def main():
    tsv = sys.argv[1]
    dry = '--dry' in sys.argv
    table = load(tsv)

    # Group by file so each is parsed and written once.
    by_file = {}
    for path, hi in table.items():
        f, _, pointer = path.partition('.json')
        by_file.setdefault(f + '.json', {})[pointer] = hi

    total, missed = 0, []
    for path, edits in sorted(by_file.items()):
        raw = open(path, encoding='utf-8').read()
        indent = detect_indent(raw)
        doc = json.loads(raw)
        changed = 0
        for pointer, hi in edits.items():
            node = doc
            ok = True
            for part in [p for p in pointer.split('/') if p]:
                if isinstance(node, list):
                    node = node[int(part)]
                elif isinstance(node, dict) and part in node:
                    node = node[part]
                else:
                    ok = False
                    break
            # The pointer addresses the {en, hi} map itself.
            if not ok or not isinstance(node, dict) or 'hi' not in node:
                missed.append(path + pointer)
                continue
            node['hi'] = hi
            changed += 1
        total += changed
        print(path.split('/')[-1] + ': ' + str(changed) + ' updated')
        if not dry and changed:
            with open(path, 'w', encoding='utf-8', newline='') as fh:
                json.dump(doc, fh, ensure_ascii=False, indent=indent)
                fh.write('\n')

    print('\ntotal updated : ' + str(total))
    print('pointers missed: ' + str(len(missed)))
    for m in missed[:8]:
        print('   ' + m)
    if dry:
        print('(dry run - nothing written)')


if __name__ == '__main__':
    main()
