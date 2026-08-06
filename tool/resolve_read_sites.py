"""Append `.now` (or `.en`) at every read site the analyzer flags.

The model half of a widening is mechanical but must be exact, so the positions
come from `flutter analyze --machine`, which reports FILE|LINE|COL|LENGTH for
each error. Patching at a reported offset beats a regex that guesses at
expression boundaries.

Which suffix:

  .en   in veda_index.dart - the offline search index is built once and matched
        against a typed query, so it must not vary with the language on screen.
  .now  everywhere else - screens render in the language the mother chose.

Runs one file at a time, back-to-front, so earlier offsets stay valid. Re-run
until it reports nothing: fixing one error can reveal the next on the same line.

    python tool/resolve_read_sites.py [--dry]
"""

import re
import subprocess
import sys

# Errors that mean "a LocalizedText turned up where a String was wanted".
WANTED = {
    'argument_type_not_assignable',
    'return_of_invalid_type',
    'invalid_assignment',
    'list_element_type_not_assignable',
}

# Deliberately NOT handled here, because the fix is somewhere other than the
# place the analyzer points at:
#
#   constant_pattern_never_matches_value_type - a `switch (x) { case 'Sudoku':`
#       where x widened. The suffix belongs on the SWITCH SUBJECT, not on each
#       case pattern; this script put `.now` inside the patterns and produced
#       `case .now'Sudoku':`, which is not Dart. Worse, the right suffix there
#       was `.en`: that switch dispatches to a game widget, so it must match
#       English whatever is on screen.
#
#   undefined_getter on a record - `(...).now`, the suffix landed on the whole
#       record literal instead of the one field inside it that widened.
#
# Both are judgement calls about identity vs display. They are left to a human.


def analyze():
    # shell=True because on Windows `flutter` is a .bat, which CreateProcess
    # will not exec directly. `--machine` is not honoured by this Flutter
    # version - it prints the human format regardless - so the human format is
    # what gets parsed, and the expression END is scanned for rather than read
    # off a length field.
    out = subprocess.run('flutter analyze lib', shell=True,
                         capture_output=True, text=True, encoding='utf-8')
    rows = []
    pat = re.compile(r'- ([^ ]+\.dart):(\d+):(\d+) - (\w+)$')
    for line in (out.stdout or '').split('\n'):
        line = line.strip()
        m = pat.search(line)
        if not m or m.group(4).lower() not in WANTED:
            continue
        # DIRECTION MATTERS. argument_type_not_assignable fires both ways:
        #
        #   LocalizedText where String is wanted  -> a read site, add .now/.en
        #   String where LocalizedText is wanted  -> a DATA file that has not
        #                                            been converted yet
        #
        # Only the code was checked once, so the second kind was "fixed" by
        # appending .now to string literals - producing `.now.now'text'` and
        # `_t(...).now`, 227 of them across two data files, and a loop that
        # reported the same count every pass because it never converged.
        # A data file needs its literals WRAPPED, which is a different job.
        if "'LocalizedText'" not in line:
            continue
        # Only assignment-shaped messages name a source and a target in that
        # order. A `return_of_invalid_type` reads "can't be returned from",
        # with no 'assigned' at all - indexing for it threw ValueError and took
        # the whole run down.
        marker = line.find('assigned')
        if marker != -1 and line.index("'LocalizedText'") > marker \
                and 'return' not in m.group(4):
            continue    # LocalizedText is the TARGET type, not the source
        rows.append({'file': m.group(1), 'line': int(m.group(2)),
                     'col': int(m.group(3)), 'code': m.group(4).lower()})
    return rows


def expr_end(src, at):
    """End of the expression beginning at [at]: identifiers, dots, and
    balanced call/index brackets. Stops at the first separator seen outside
    any bracket, which is where a suffix has to go."""
    i, depth = at, 0
    while i < len(src):
        c = src[i]
        if c in '([':
            depth += 1
        elif c in ')]':
            if depth == 0:
                break
            depth -= 1
        elif depth == 0 and not (c.isalnum() or c in '._$'):
            break
        i += 1
    return i


def main():
    dry = '--dry' in sys.argv
    rows = analyze()
    if not rows:
        print('nothing to do')
        return

    by_file = {}
    for r in rows:
        by_file.setdefault(r['file'], []).append(r)

    for path, items in by_file.items():
        # NEVER patch a data file. It holds the source content; a type error
        # there means the MODEL has not widened yet, and appending .now would
        # resolve a value at its definition - throwing the other language away
        # at the one place that is supposed to hold both.
        if '/data/' in path.replace(chr(92), '/'):
            print(path + ': skipped - widen the model field instead')
            continue
        suffix = '.en' if path.endswith('veda_index.dart') else '.now'
        src = open(path, encoding='utf-8').read()
        starts = [0]
        for ln in src.split('\n'):
            starts.append(starts[-1] + len(ln) + 1)
        # Back-to-front, and de-duplicated: two errors can point at one span.
        seen, patched = set(), 0
        for r in sorted(items, key=lambda x: (-x['line'], -x['col'])):
            at = expr_end(src, starts[r['line'] - 1] + r['col'] - 1)
            if at in seen:
                continue
            seen.add(at)
            src = src[:at] + suffix + src[at:]
            patched += 1
        print(path + ': ' + str(patched) + ' sites + ' + suffix)
        if not dry:
            open(path, 'w', encoding='utf-8', newline='').write(src)
    if dry:
        print('(dry run - nothing written)')


if __name__ == '__main__':
    main()
