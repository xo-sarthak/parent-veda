"""Point the per-screen month arrays at the one bilingual helper.

Six screens each carried their own `['Jan', 'Feb', …]`, so a date rendered in
English on a Hindi phone in six separate places. Replacing the array with a
call to `S.now.monthShort` fixes all of them and means the next screen that
needs a month cannot reintroduce it.
"""

import os
import re

SHORT = re.compile(
    r"(?:static\s+)?const\s+(_\w+)\s*=\s*\[\s*'Jan',.*?\];", re.S)
LONG = re.compile(
    r"(?:static\s+)?const\s+(_?\w+)\s*=\s*(?:<String>)?\[\s*'',\s*'January',.*?\];",
    re.S)

TARGETS = [
    ('lib/screens/weekly_card_stack_screen.dart', SHORT, 'monthShort'),
    ('lib/screens/father/father_daily_screen.dart', SHORT, 'monthShort'),
    ('lib/screens/father/father_journal_screen.dart', SHORT, 'monthShort'),
    ('lib/data/community_data.dart', LONG, 'monthLong'),
    ('lib/referral/referral_engine.dart', LONG, 'monthLong'),
]


def relative_import(path):
    rel = os.path.relpath('lib/localization/app_language.dart',
                          os.path.dirname(path)).replace(os.sep, '/')
    return f"import '{rel}';"


for path, pattern, helper in TARGETS:
    src = open(path, encoding='utf-8').read()
    m = pattern.search(src)
    if not m:
        print(f'  SKIP (no array found)  {path}')
        continue
    name = m.group(1)
    indexed = 1 if helper == 'monthShort' else 0   # long arrays are 1-indexed
    # Drop the array declaration entirely.
    src = src[:m.start()] + src[m.end():]
    # Rewrite every `name[expr - 1]` / `name[expr]` into a helper call.
    if indexed:
        src = re.sub(rf"{re.escape(name)}\[\s*([A-Za-z_][\w.]*)\.month\s*-\s*1\s*\]",
                     rf"S.now.{helper}(\1.month)", src)
        src = re.sub(rf"{re.escape(name)}\[\s*([A-Za-z_][\w.]*)\s*-\s*1\s*\]",
                     rf"S.now.{helper}(\1)", src)
    else:
        src = re.sub(rf"{re.escape(name)}\[\s*([^\]]+?)\s*\]",
                     rf"S.now.{helper}(\1)", src)
    if 'localization/app_language.dart' not in src:
        imports = list(re.finditer(r"^import .*;$", src, re.M))
        at = imports[-1].end() if imports else 0
        src = src[:at] + '\n' + relative_import(path) + src[at:]
    open(path, 'w', encoding='utf-8', newline='').write(src)
    left = len(re.findall(rf"\b{re.escape(name)}\b", src))
    print(f'  {path}: array `{name}` removed, {left} stray reference(s) left')
