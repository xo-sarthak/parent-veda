"""Garbh Sanskar.xlsx -> lib/data/garbh_sheet/*.dart (+ docs/GARBH-AUDIO-OWED.md).

Usage (from the repo root):
    python -I tools/garbh_content/xlsx_to_dart.py "<path to Garbh Sanskar.xlsx>"

What goes where (the user's decisions, 2026-10-13):
  * Affirmations & blessings, Stories & fables -> one entry per day 1-280: the
    mother's affirmation, the father's script, the day's story and its
    closing line. "Developmental Focus" is NOT carried: it reads like
    embryology and is not, and the door already has an honest week line.
  * Mantras (Hindu, Sikh, Muslim, Christian) -> name, text, meaning. The
    "Intent" column is NOT carried (it claims effects on the body). Bible text
    the sheet gives in the NIV wording (copyright) is replaced with the World
    English Bible (public domain) from WEB below; an unknown passage stops
    the run rather than ship copyrighted text.
  * Hindu sacred stories and Gita conversations -> title, source, story,
    moral. "Prenatal Intent" is NOT carried (claims).
  * Raga and music -> NOT the app: no audio exists yet. Written to
    docs/GARBH-AUDIO-OWED.md as the brief for the recordings, without the
    "clinical focus" column.

Strict: a missing day, a day pasted twice with different text, a header that
moved, or an unknown Bible passage stops the run. Standard library only.
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'lib', 'data', 'garbh_sheet')
AUDIO_DOC = os.path.join(ROOT, 'docs', 'GARBH-AUDIO-OWED.md')

# World English Bible (public domain), keyed by the sheet's name column.
WEB = {
    'The Knitting of Life (Psalm 139)': (
        'Psalm 139:13-14',
        'For you formed my inmost being. You knit me together in my mother’s womb. I will give thanks to '
        'you, for I am fearfully and wonderfully made. Your works are wonderful. My soul knows that very well.'),
    'The Blueprint Promise (Jeremiah 1)': (
        'Jeremiah 1:5',
        'Before I formed you in the womb, I knew you. Before you were born, I sanctified you.'),
    'The Absolute Refuge (Psalm 91)': (
        'Psalm 91:1-2',
        'He who dwells in the secret place of the Most High will rest in the shadow of the Almighty. I will '
        'say of Yahweh, “He is my refuge and my fortress; my God, in whom I trust.”'),
}

# A sentence in a Hindu "meaning" cell that claims an effect on the body or
# the baby's development. Such a sentence is dropped (the user, 2026-10-13:
# text and meaning, no health claims).
CLAIM = re.compile(r'cellular|cells?\b|brain|intellectual potential|development|structural|cortisol|'
                   r'nervous system|hormone|immun|organ\b|organs\b|physical|\bIQ\b|DNA|vitality|healthy', re.I)


class SheetError(Exception):
    pass


def read_workbook(path):
    z = zipfile.ZipFile(path)
    ss = []
    if 'xl/sharedStrings.xml' in z.namelist():
        for si in re.findall(r'<si>(.*?)</si>', z.read('xl/sharedStrings.xml').decode('utf8'), re.S):
            ss.append(html.unescape(''.join(re.findall(r'<t[^>]*>([^<]*)</t>', si, re.S))))
    wb = z.read('xl/workbook.xml').decode('utf8')
    rels = z.read('xl/_rels/workbook.xml.rels').decode('utf8')
    relmap = {}
    for rel in re.findall(r'<Relationship [^>]*>', rels):
        rid = re.search(r'Id="([^"]+)"', rel).group(1)
        relmap[rid] = re.search(r'Target="([^"]+)"', rel).group(1)
    sheets = {}
    for name, rid in re.findall(r'<sheet [^>]*name="([^"]+)"[^>]*r:id="([^"]+)"', wb):
        target = relmap[rid].lstrip('/')
        x = z.read(target if target.startswith('xl/') else 'xl/' + target).decode('utf8')
        rows = []
        for row in re.findall(r'<row[^>]*>(.*?)</row>', x, re.S):
            cells = {}
            for attrs, inner in re.findall(r'<c ([^>]*?)(?:/>|>(.*?)</c>)', row, re.S):
                col = re.search(r'r="([A-Z]+)\d+"', attrs).group(1)
                t = re.search(r't="(\w+)"', attrs)
                v = re.search(r'<v>([^<]*)</v>', inner or '')
                inl = re.search(r'<is>(.*?)</is>', inner or '', re.S)
                val = ''
                if t and t.group(1) == 's' and v:
                    val = ss[int(v.group(1))]
                elif inl:
                    val = html.unescape(''.join(re.findall(r'<t[^>]*>([^<]*)</t>', inl.group(1))))
                elif v:
                    val = v.group(1)
                val = re.sub(r'\s+', ' ', val.replace(' ', ' ')).strip()
                if val:
                    cells[col] = val
            if cells:
                rows.append(cells)
        sheets[html.unescape(name)] = rows
    return sheets


def sheet(sheets, prefix):
    for k, v in sheets.items():
        if k.lower().startswith(prefix.lower()):
            return v
    raise SheetError(f'no sheet starting "{prefix}"')


def by_header(rows, *wanted):
    """Map header text -> column letter from the first row; strict."""
    head = rows[0]
    cols = {}
    for w in wanted:
        hit = [c for c, t in head.items() if t.lower().startswith(w.lower())]
        if not hit:
            raise SheetError(f'header "{w}" not found in {list(head.values())}')
        cols[w] = hit[0]
    return cols


def trimesters(s):
    s = (s or '').lower()
    if 'all' in s:
        return [1, 2, 3]
    nums = sorted({int(n) for n in re.findall(r'[123]', s)})
    return nums or [1, 2, 3]


# ---- days -----------------------------------------------------------------------

def parse_days(sheets):
    aff = sheet(sheets, 'Affirmations')
    c = by_header(aff, 'Day', 'Maternal', 'Paternal')
    days = {}
    for r in aff[1:]:
        m = re.match(r'Day (\d+)$', r.get(c['Day'], ''))
        if not m:
            raise SheetError(f'affirmations: a row with no "Day N": {r}')
        d = int(m.group(1))
        entry = (r.get(c['Maternal'], ''), r.get(c['Paternal'], ''))
        if not entry[0] or not entry[1]:
            raise SheetError(f'affirmations: day {d} is missing a script')
        if d in days and days[d] != entry:
            raise SheetError(f'affirmations: day {d} appears twice with different text')
        days[d] = entry

    st = sheet(sheets, 'Stories')
    c = by_header(st, 'Day', 'Story Headline', 'Fable')
    stories = {}
    for r in st[1:]:
        d = int(re.match(r'Day (\d+)$', r[c['Day']]).group(1))
        body = r.get(c['Fable'], '')
        # The closing line is glued to the story with no space:
        # "...freeing the giants.True strength grows..."
        # A sentence end (optionally a CLOSING quote) straight into a capital —
        # not an opening quote, which also sits before a capital ('said, "Please').
        m = re.search(r'[.!?]["”]?(?=[A-Z])', body)
        if not m:
            raise SheetError(f'stories: day {d} has no closing line to split off')
        narrative, close = body[:m.end()].strip(), body[m.end():].strip()
        if d in stories and stories[d] != (r[c['Story Headline']], narrative, close):
            raise SheetError(f'stories: day {d} appears twice with different text')
        stories[d] = (r[c['Story Headline']], narrative, close)

    missing = [d for d in range(1, 281) if d not in days or d not in stories]
    if missing:
        raise SheetError(f'days missing: {missing[:20]}')
    return [(d, *days[d], *stories[d]) for d in range(1, 281)]


# ---- mantras ----------------------------------------------------------------------

def parse_mantras(sheets, prefix, faith, skipped):
    rows = sheet(sheets, prefix)
    head = list(rows[0].values())
    name_c, app_c, text_c, mean_c = 'A', 'B', 'C', 'D'
    has_intent = len(head) >= 5
    out, seen = [], set()
    for r in rows[1:]:
        name, text = r.get(name_c, ''), r.get(text_c, '')
        if not text:
            skipped.append(f'{faith}: "{name}" has no text in the sheet')
            continue
        if re.fullmatch(r'\(.*\)', text):
            skipped.append(f'{faith}: "{name}" gives "{text}" instead of the text')
            continue
        key = re.sub(r'[^a-z]', '', text.lower())[:40]
        if key in seen:
            continue  # the sheet lists some mantras twice
        seen.add(key)
        meaning = r.get(mean_c, '')
        if faith == 'Hindu' and not r.get('E'):
            # A four-column row: the "meaning" cell is an intent line, often a
            # claim. Keep only the sentences that make none.
            keep = [s for s in re.split(r'(?<=[.!?])\s+', meaning) if s and not CLAIM.search(s)]
            if len(' '.join(keep)) < len(meaning):
                skipped.append(f'{faith}: "{name}": dropped a claim from its meaning: "{meaning}"')
            meaning = ' '.join(keep)
        if faith == 'Christian':
            if name not in WEB:
                raise SheetError(f'Christian: "{name}" is not in the WEB table; add its public-domain text')
            ref, web = WEB[name]
            text, name = web, f'{name.split(" (")[0]} ({ref})'
        out.append((name, text, meaning, trimesters(r.get(app_c))))
    return out


# ---- sacred stories -------------------------------------------------------------

def parse_sacred(sheets):
    rows = sheet(sheets, 'Hindu - Sacred')
    stories, gita, seen = [], [], set()
    mode = None
    for r in rows:
        a = r.get('A', '')
        if a in ('Story Title', 'Conversation Title'):
            mode = 'story' if a == 'Story Title' else 'gita'
            continue
        if mode is None:
            raise SheetError('sacred stories: data before a header row')
        # "What You Believe" | "You Become" | "Chapter 17, Verse 3" | …: a title
        # split across two cells shifts the row one column right.
        if 'G' in r:
            r = {'A': f"{r['A']}, {r['B']}", 'B': r['C'], 'C': r['D'], 'D': r['E'], 'E': r['F']}
        title, src, tri, text, moral = (r.get(k, '') for k in 'ABCDE')
        if not text or not moral:
            raise SheetError(f'sacred stories: "{title}" has no story or moral')
        key = re.sub(r'[^a-z]', '', (title + text).lower())[:60]
        if key in seen:
            continue
        seen.add(key)
        if mode == 'gita':
            src = f'Bhagavad Gita, {src}'
            gita.append((title, src, trimesters(tri), text, moral))
        else:
            stories.append((title, src, trimesters(tri), text, moral))
    return stories, gita


# ---- raga brief -------------------------------------------------------------------

def raga_brief(sheets):
    rows = sheet(sheets, 'Raga')
    c = by_header(rows, 'Asset_ID', 'Week Range', 'Audio Category', 'Raga', 'Dominant Instrument',
                  'Prahar', 'Maternal Action Cue')
    lines = ['# Garbh Shravan — audio owed (generated)', '',
             'Generated by `tools/garbh_content/xlsx_to_dart.py` from the "Raga and music" sheet of '
             f'Garbh Sanskar.xlsx. **Nothing here is in the app**: the sheet names {len(rows) - 1} tracks '
             'but no recordings exist. When the audio is made, each file is added to Shravan by its ID.', '',
             'The sheet\'s "Clinical / Developmental Focus" column, tuning and BPM are left out on '
             'purpose: claims such as "lowers evening cortisol" or "528 Hz" break the Garbh door\'s '
             'rule never to claim a practice improves the baby or the body (garbh_rebuild_data.dart).', '',
             '| ID | Weeks | Kind | Raga / sound | Instrument | Time of day | Cue for the mother |',
             '|---|---|---|---|---|---|---|']
    for r in rows[1:]:
        cells = [r.get(c[k], '').replace('|', '/') for k in
                 ('Asset_ID', 'Week Range', 'Audio Category', 'Raga', 'Dominant Instrument', 'Prahar',
                  'Maternal Action Cue')]
        lines.append('| ' + ' | '.join(cells) + ' |')
    return '\n'.join(lines) + '\n', len(rows) - 1


# ---- Dart ----------------------------------------------------------------------------

def q(s):
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{s}'"


HEAD = '// GENERATED by tools/garbh_content/xlsx_to_dart.py - do not edit by hand.\n\nimport \'../garbh_sheet.dart\';\n\n'


def write(name, body):
    with open(os.path.join(OUT, name), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(HEAD + body)


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    try:
        sheets = read_workbook(sys.argv[1])
        days = parse_days(sheets)
        skipped = []
        mantras = {f: parse_mantras(sheets, p, f, skipped) for f, p in
                   (('Hindu', 'Mantras - Hindu'), ('Sikh', 'Mantra- sikh'), ('Muslim', 'Mantras - Muslim'),
                    ('Christian', 'Mantras - Christ'))}
        stories, gita = parse_sacred(sheets)
        brief, n_audio = raga_brief(sheets)
    except SheetError as e:
        sys.exit(f'Stopped, nothing written: {e}')

    os.makedirs(OUT, exist_ok=True)
    body = ['/// Days 1–280: the mother\'s affirmation, the father\'s script, the day\'s story.',
            'const List<GarbhSheetDay> kGarbhSheetDays = [']
    for d, mother, father, title, story, close in days:
        body.append(f'  GarbhSheetDay({d}, {q(mother)}, {q(father)}, {q(title)}, {q(story)}, {q(close)}),')
    body.append('];')
    write('garbh_days.dart', '\n'.join(body) + '\n')

    body = []
    for faith, items in mantras.items():
        body.append(f'const List<GarbhMantra> kGarbhMantras{faith} = [')
        for name, text, meaning, tri in items:
            body.append(f'  GarbhMantra({q(name)}, {q(text)}, {q(meaning)}, {tri}),')
        body.append('];\n')
    write('garbh_mantras.dart', '\n'.join(body))

    body = []
    for var, items in (('kGarbhSacredStories', stories), ('kGarbhGitaConversations', gita)):
        body.append(f'const List<GarbhSacredStory> {var} = [')
        for title, src, tri, text, moral in items:
            body.append(f'  GarbhSacredStory({q(title)}, {q(src)}, {tri}, {q(text)}, {q(moral)}),')
        body.append('];\n')
    write('garbh_sacred.dart', '\n'.join(body))

    with open(AUDIO_DOC, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write(brief)
    print(f'Wrote 280 days; mantras ' + ', '.join(f'{f} {len(v)}' for f, v in mantras.items())
          + f'; {len(stories)} sacred stories, {len(gita)} Gita conversations; audio brief {n_audio} tracks')
    if skipped:
        print('Left out (doc gaps / claims), for the tracker:')
        for s in skipped:
            print('  -', s)


if __name__ == '__main__':
    main()
