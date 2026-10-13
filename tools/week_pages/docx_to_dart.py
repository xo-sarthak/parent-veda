"""Pregnancy week-page docs (.docx) -> lib/data/preg_week_pages/week_NN.dart.

Usage (from the repo root):
    python -I tools/week_pages/docx_to_dart.py "<folder with the Week docx files>"

Reads every "Pregnancy Week N ... .docx" in the folder, parses the fixed
seven-section layout, and writes one const PregWeekPage per week plus
index.dart. Standard library only.

Strict on purpose: a heading it does not know, a section that comes out
empty, or a "fixed" line that changed wording stops the run with the week and
the line. A silently half-parsed week would ship a page with a hole in it.

Spec notes in the docs ("Plain data only", "Each row: icon + title", "[ Got
it ]", "(Fixed footer ...)") are instructions to the builder, not content,
and are dropped. The Appendix (sources and review notes) is kept only as a
comment in the generated file.
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'lib', 'data', 'preg_week_pages')

SCIENCE_FOOTER = 'This is for understanding, not diagnosis – your doctor is always the best guide.'
SYMPTOMS_INTRO = 'Common, normal things you may notice now – tap any to understand it and what helps.'

# Lines that are notes to the builder, never shown.
SPEC_PREFIXES = (
    'Plain data only', 'Each row:', 'Each:', 'Shown inline', 'Not shown this week',
    '[ Got it ]', 'Status:', 'Revision note:',
)

# Pictographs, dingbats and the variation selector: no decorative emoji in the app.
EMOJI = re.compile('[\U0001F000-\U0001FAFF☀-➿️]')


class DocError(Exception):
    pass


def paragraphs(path):
    xml = zipfile.ZipFile(path).read('word/document.xml').decode('utf8')
    out = []
    for para in re.findall(r'<w:p[ >].*?</w:p>', xml, re.S):
        st = re.search(r'<w:pStyle w:val="([^"]+)"', para)
        text = ''.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', para))
        text = html.unescape(text).replace(' ', ' ').strip()
        text = re.sub(r'\s+', ' ', text)
        if text:
            out.append((st.group(1) if st else '', text))
    return out


def is_spec(text):
    if text.startswith(SPEC_PREFIXES):
        return True
    # A line that is wholly a parenthetical note: "(Current week to week+4 ...)".
    return text.startswith('(') and text.endswith(')')


def strip_fixed(text):
    """'<line>  (Fixed footer, constant every week.)' -> '<line>'."""
    return re.sub(r'\s*\((Fixed|Current)[^)]*\)\s*$', '', text).strip()


def clean(text):
    t = EMOJI.sub('', text)
    return re.sub(r'\s+', ' ', t).strip()


def split_sections(paras, week):
    """Heading1 title -> list of (style, text) under it."""
    sections = {}
    current = None
    for style, text in paras:
        if style == 'Heading1':
            m = re.match(r'(?:\d+\.\s*)?(.*)', text)
            current = m.group(1).strip()
            sections[current] = []
        elif current is not None:
            sections[current].append((style, text))
    return sections


def find(sections, prefix, week, required=True):
    for k, v in sections.items():
        if k.startswith(prefix):
            return k, v
    if required:
        raise DocError(f'week {week}: no section starting "{prefix}"')
    return None, None


def need(value, what, week):
    if not value:
        raise DocError(f'week {week}: {what} is empty')
    return value


def parse_snapshot(rows, week):
    vals = {}
    for _, t in rows:
        if is_spec(t):
            continue
        m = re.match(r'(Fruit comparison|Length|Weight):\s*(.+)', t)
        if not m:
            raise DocError(f'week {week}: snapshot line not understood: {t!r}')
        vals[m.group(1)] = m.group(2).strip()
    return (need(vals.get('Fruit comparison'), 'fruit', week),
            need(vals.get('Length'), 'length', week),
            need(vals.get('Weight'), 'weight', week))


def parse_about(rows, week):
    teaser = ''
    about, behaviour = [], []
    mode = None  # 'teaser' | 'expanded' | 'behaviour'
    heading = None
    for style, t in rows:
        if style == 'Heading2':
            if t.startswith('Cover teaser'):
                mode = 'teaser'
            elif t.startswith('Expanded page'):
                mode = 'expanded'
            else:
                raise DocError(f'week {week}: About heading not understood: {t!r}')
            continue
        if style == 'Heading3':
            if t.startswith('Behavioural highlights'):
                mode = 'behaviour'
                heading = None
                continue
            heading = clean(t)
            continue
        if is_spec(t):
            continue
        if mode == 'teaser':
            if teaser:
                raise DocError(f'week {week}: two teaser paragraphs')
            teaser = t
        elif mode == 'expanded':
            if heading is None:
                raise DocError(f'week {week}: About text with no heading: {t[:60]!r}')
            about.append((heading, t))
            heading = None
        elif mode == 'behaviour':
            if heading is None:
                raise DocError(f'week {week}: behaviour text with no heading: {t[:60]!r}')
            behaviour.append((heading, t))
            heading = None
        else:
            raise DocError(f'week {week}: About text outside a block: {t[:60]!r}')
    need(teaser, 'cover teaser', week)
    need(about, 'expanded page', week)
    return teaser, about, behaviour


def parse_science(rows, week):
    cards, title = [], None
    footer_seen = False
    for style, t in rows:
        if style == 'Heading3':
            title = clean(t)
            continue
        if is_spec(t):
            continue
        if 'Fixed footer' in t:
            if strip_fixed(t) != SCIENCE_FOOTER:
                raise DocError(f'week {week}: Baby Science footer changed: {t!r}')
            footer_seen = True
            continue
        if title is None:
            raise DocError(f'week {week}: science text with no title: {t[:60]!r}')
        cards.append((title, t))
        title = None
    need(cards, 'Baby Science', week)
    if not footer_seen:
        raise DocError(f'week {week}: Baby Science footer missing')
    return cards


def parse_you(rows, week):
    prose, highlights = [], []
    self_care = reminder = ''
    block = None
    h_title = h_teaser = None
    for style, t in rows:
        if style == 'Heading2':
            block = t
            continue
        if style == 'Heading3' and block == 'Highlights':
            h_title, h_teaser = clean(t), None
            continue
        if is_spec(t):
            continue
        if block == 'Highlights':
            if h_title is None:
                raise DocError(f'week {week}: highlight text with no title: {t[:60]!r}')
            if h_teaser is None:
                h_teaser = t
            else:
                highlights.append((h_title, h_teaser, t))
                h_title = h_teaser = None
        elif block == 'Self-care':
            self_care = t
        elif block == 'A gentle reminder':
            reminder = t
        elif block:
            prose.append((block, t))
        else:
            raise DocError(f'week {week}: You text outside a block: {t[:60]!r}')
    if h_title is not None:
        raise DocError(f'week {week}: highlight "{h_title}" has no card body')
    need(prose, 'You this week', week)
    need(highlights, 'highlights', week)
    need(self_care, 'self-care', week)
    need(reminder, 'gentle reminder', week)
    return prose, highlights, self_care, reminder


LABELS = {
    'HOW COMMON IS IT?': 'howCommon',
    'WHY IT HAPPENS': 'why',
    'WHAT MAY HELP': 'helps',
    'WHEN TO CONTACT YOUR DOCTOR': 'whenToCall',
}


def parse_symptoms(rows, week):
    out, cur, part = [], None, None
    intro = False
    footer = ''

    def close():
        if cur is None:
            return
        for k in ('teaser', 'howCommon', 'why', 'helps', 'whenToCall'):
            if not cur.get(k):
                raise DocError(f'week {week}: symptom "{cur["name"]}" has no {k}')
        out.append(cur)

    for style, t in rows:
        if style == 'Heading3':
            close()
            cur, part = {'name': clean(t), 'helps': []}, 'teaser'
            continue
        if t == SYMPTOMS_INTRO:
            intro = True
            continue
        if 'Fixed footer' in t:
            # Per week: from week 21 it adds leaking fluid and reduced movements.
            footer = strip_fixed(t)
            continue
        if is_spec(t):
            continue
        if cur is None:
            raise DocError(f'week {week}: symptom text before a symptom: {t[:60]!r}')
        if t in LABELS:
            part = LABELS[t]
            continue
        if part == 'helps':
            cur['helps'].append(t)
        else:
            if cur.get(part):
                raise DocError(f'week {week}: symptom "{cur["name"]}" has two {part} lines')
            cur[part] = t
    close()
    if not intro:
        raise DocError(f'week {week}: symptoms intro line missing or changed')
    if not footer:
        raise DocError(f'week {week}: symptoms footer missing')
    return need(out, 'symptoms', week), footer


def food_line(t, week):
    parts = re.split(r'\s+—\s+', t, maxsplit=1)
    if len(parts) != 2:
        raise DocError(f'week {week}: food line has no " — ": {t!r}')
    return parts[0].strip(), parts[1].strip()


def parse_diet(rows, week):
    sf = {}
    favour, avoid = [], []
    block = None
    for style, t in rows:
        if t == 'INDIAN SUPERFOOD OF THE WEEK':
            block = 'superfood'
            continue
        if style == 'Heading3' and block == 'superfood':
            sf['food'] = t
            continue
        if style == 'Heading2':
            if t.startswith('Foods to favour'):
                block = 'favour'
            elif t.startswith('What to avoid'):
                block = 'avoid'
            else:
                raise DocError(f'week {week}: diet heading not understood: {t!r}')
            continue
        if is_spec(t):
            continue
        if block == 'superfood':
            if t.startswith('Try it as:'):
                sf['tryAs'] = t[len('Try it as:'):].strip()
            elif 'benefit' not in sf:
                sf['benefit'] = t
            elif 'note' not in sf:
                sf['note'] = t
            else:
                raise DocError(f'week {week}: extra superfood line: {t[:60]!r}')
        elif block == 'favour':
            favour.append(food_line(t, week))
        elif block == 'avoid':
            avoid.append(food_line(t, week))
        else:
            raise DocError(f'week {week}: diet text outside a block: {t[:60]!r}')
    for k in ('food', 'benefit', 'tryAs'):
        need(sf.get(k), f'superfood {k}', week)
    need(favour, 'foods to favour', week)
    need(avoid, 'what to avoid', week)
    return sf, favour, avoid


def parse_tips(title, rows, week):
    tips, tip = [], None
    for _, t in rows:
        if is_spec(t):
            continue
        m = re.match(r'\d+\.\s+(.*)', t)
        if m:
            if tip is not None:
                raise DocError(f'week {week}: tip with no card: {tip!r}')
            tip = m.group(1).strip()
        else:
            if tip is None:
                raise DocError(f'week {week}: tip card with no tip: {t[:60]!r}')
            tips.append((tip, t))
            tip = None
    m = re.match(r'Trimester Tips\s*—\s*(.*)', title)
    return (m.group(1).strip() if m else ''), need(tips, 'trimester tips', week)


def parse_partner(rows, week):
    note = how_mom = ''
    scans, helps = [], []
    block = None
    for style, t in rows:
        if style == 'Heading2':
            continue  # "Our Pregnancy Week: Week N" - the screen writes its own.
        if style == 'Heading3':
            block = t
            continue
        if is_spec(t):
            continue
        if block == 'A note from your baby':
            note = t
        elif block == 'How mom is doing':
            how_mom = t
        elif block.startswith('Scans'):
            scans.append(t)
        elif block == 'How you can help':
            helps.append(t)
        else:
            raise DocError(f'week {week}: partner block not understood: {block!r}')
    need(note, 'note from your baby', week)
    need(how_mom, 'how mom is doing', week)
    need(scans, 'scans coming up', week)
    need(helps, 'how you can help', week)
    return note, how_mom, scans, helps


def parse(path):
    paras = paragraphs(path)
    title = next((t for _, t in paras if t.startswith('Pregnancy Week')), '')
    m = re.match(r'Pregnancy Week (\d+)', title)
    if not m:
        raise DocError(f'{os.path.basename(path)}: no "Pregnancy Week N" title')
    week = int(m.group(1))
    s = split_sections(paras, week)

    known = ('Opening Snapshot', 'About Your Baby', 'Baby Science', 'You This Week',
             'Health This Week — Symptoms', 'Health This Week — Diet', 'Trimester Tips',
             'Share With Partner', 'Appendix')
    for k in s:
        if not k.startswith(known):
            raise DocError(f'week {week}: unknown section "{k}"')

    page = {'week': week}
    page['fruit'], page['length'], page['weight'] = parse_snapshot(find(s, 'Opening Snapshot', week)[1], week)
    page['teaser'], page['about'], page['behaviour'] = parse_about(find(s, 'About Your Baby', week)[1], week)
    page['science'] = parse_science(find(s, 'Baby Science', week)[1], week)
    page['you'], page['highlights'], page['selfCare'], page['reminder'] = parse_you(find(s, 'You This Week', week)[1], week)
    page['symptoms'], page['symptomsFooter'] = parse_symptoms(find(s, 'Health This Week — Symptoms', week)[1], week)
    page['superfood'], page['favour'], page['avoid'] = parse_diet(find(s, 'Health This Week — Diet', week)[1], week)
    tk, tv = find(s, 'Trimester Tips', week, required=False)
    page['tipsTitle'], page['tips'] = parse_tips(tk, tv, week) if tk else ('', [])
    page['partner'] = parse_partner(find(s, 'Share With Partner', week)[1], week)
    _, appendix = find(s, 'Appendix', week, required=False)
    page['appendix'] = [t for _, t in (appendix or [])]
    page['source'] = os.path.basename(path)
    return page


# ---- Dart output -------------------------------------------------------------

def q(s):
    """A Dart single-quoted string literal."""
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{s}'"


def qlist(items, indent):
    if not items:
        return 'const []'
    pad = ' ' * indent
    return '[\n' + ''.join(f'{pad}  {q(x)},\n' for x in items) + f'{pad}]'


def dart_page(p):
    w = p['week']
    L = []
    a = L.append
    a('// GENERATED by tools/week_pages/docx_to_dart.py - do not edit by hand.')
    a(f"// Source: {p['source']}")
    a('//')
    a('// Appendix (verification notes from the doc, not shown in the app):')
    for line in p['appendix']:
        for chunk in re.findall(r'.{1,76}(?:\s|$)', line):
            a('//   ' + chunk.rstrip())
    a('')
    a("import '../preg_week_pages.dart';")
    a('')
    a(f'const PregWeekPage kPregWeekPage{w:02d} = PregWeekPage(')
    a(f'  week: {w},')
    a(f"  fruit: {q(p['fruit'])},")
    a(f"  length: {q(p['length'])},")
    a(f"  weight: {q(p['weight'])},")
    a(f"  teaser: {q(p['teaser'])},")
    a('  about: [')
    for h, b in p['about']:
        a(f'    PregWeekProse({q(h)}, {q(b)}),')
    a('  ],')
    if p['behaviour']:
        a('  behaviour: [')
        for h, b in p['behaviour']:
            a(f'    PregWeekCard({q(h)}, {q(b)}),')
        a('  ],')
    a('  science: [')
    for h, b in p['science']:
        a(f'    PregWeekCard({q(h)}, {q(b)}),')
    a('  ],')
    a('  you: [')
    for h, b in p['you']:
        a(f'    PregWeekProse({q(h)}, {q(b)}),')
    a('  ],')
    a('  highlights: [')
    for t, te, b in p['highlights']:
        a(f'    PregWeekHighlight({q(t)}, {q(te)}, {q(b)}),')
    a('  ],')
    a(f"  selfCare: {q(p['selfCare'])},")
    a(f"  reminder: {q(p['reminder'])},")
    a('  symptoms: [')
    for s in p['symptoms']:
        a('    PregWeekSymptom(')
        a(f"      name: {q(s['name'])},")
        a(f"      teaser: {q(s['teaser'])},")
        a(f"      howCommon: {q(s['howCommon'])},")
        a(f"      why: {q(s['why'])},")
        a(f"      helps: {qlist(s['helps'], 6)},")
        a(f"      whenToCall: {q(s['whenToCall'])},")
        a('    ),')
    a('  ],')
    a(f"  symptomsFooter: {q(p['symptomsFooter'])},")
    sf = p['superfood']
    a('  superfood: PregWeekSuperfood(')
    a(f"    food: {q(sf['food'])},")
    a(f"    benefit: {q(sf['benefit'])},")
    a(f"    tryAs: {q(sf['tryAs'])},")
    if sf.get('note'):
        a(f"    note: {q(sf['note'])},")
    a('  ),')
    a('  favour: [')
    for n, r in p['favour']:
        a(f'    PregWeekFood({q(n)}, {q(r)}),')
    a('  ],')
    a('  avoid: [')
    for n, r in p['avoid']:
        a(f'    PregWeekFood({q(n)}, {q(r)}),')
    a('  ],')
    if p['tips']:
        a(f"  tipsTitle: {q(p['tipsTitle'])},")
        a('  tips: [')
        for t, m in p['tips']:
            a(f'    PregWeekTip({q(t)}, {q(m)}),')
        a('  ],')
    note, how_mom, scans, helps = p['partner']
    a(f'  partnerNote: {q(note)},')
    a(f'  partnerHowMom: {q(how_mom)},')
    a(f'  partnerScans: {qlist(scans, 2)},')
    a(f'  partnerHelp: {qlist(helps, 2)},')
    a(');')
    return '\n'.join(L) + '\n'


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    folder = sys.argv[1]
    files = sorted(f for f in os.listdir(folder)
                   if f.lower().endswith('.docx') and f.startswith('Pregnancy Week'))
    pages, errors = [], []
    for f in files:
        try:
            pages.append(parse(os.path.join(folder, f)))
        except DocError as e:
            errors.append(str(e))
    if errors:
        sys.exit('Stopped, nothing written:\n  ' + '\n  '.join(errors))
    weeks = [p['week'] for p in pages]
    if len(weeks) != len(set(weeks)):
        sys.exit(f'Stopped: a week appears twice: {sorted(weeks)}')
    pages.sort(key=lambda p: p['week'])
    os.makedirs(OUT, exist_ok=True)
    for p in pages:
        with open(os.path.join(OUT, f"week_{p['week']:02d}.dart"), 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(dart_page(p))
    idx = ['// GENERATED by tools/week_pages/docx_to_dart.py - do not edit by hand.', '']
    idx += [f"import 'week_{w:02d}.dart';" for w in sorted(weeks)]
    idx += ["import '../preg_week_pages.dart';", '',
            '/// Every week with a page, in week order.',
            'const List<PregWeekPage> kPregWeekPageList = [']
    idx += [f'  kPregWeekPage{w:02d},' for w in sorted(weeks)]
    idx += ['];', '']
    with open(os.path.join(OUT, 'index.dart'), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(idx))
    print(f'Wrote {len(pages)} weeks: {", ".join(str(w) for w in sorted(weeks))}')
    sync_week_content(pages)


def _lower_first(s):
    return s[0].lower() + s[1:] if s else s


def sync_week_content(pages):
    """weekContent.json babySnapshot.size.{fruit,length,weight}.en <- the docs.

    Other screens read the snapshot (the home's size line, the father views),
    so they must show the page's numbers. Edits the text in place, so line
    endings and layout survive; the Hindi side is left as it is.
    """
    import json
    path = os.path.join(ROOT, 'lib', 'data', 'weekContent.json')
    raw = open(path, encoding='utf-8', newline='').read()
    want = {}
    for p in pages:
        fruit = _lower_first(p['fruit'])
        fruit = ('an ' if fruit[:1] in 'aeiou' else 'a ') + fruit
        want[p['week']] = {'fruit': fruit, 'length': p['length'], 'weight': _lower_first(p['weight'])}

    starts = [(m.start(), int(m.group(1))) for m in re.finditer(r'"week":\s*(\d+),', raw)]
    out, last, changed = [], 0, 0
    for i, (pos, week) in enumerate(starts):
        end = starts[i + 1][0] if i + 1 < len(starts) else len(raw)
        block = raw[pos:end]
        if week in want:
            m = re.search(r'"size":\s*\{', block)
            seg_start = j = m.end()
            depth = 1
            while depth:
                depth += {'{': 1, '}': -1}.get(block[j], 0)
                j += 1
            seg = block[seg_start:j]
            for k, v in want[week].items():
                pat = re.compile(r'("' + k + r'":\s*\{\s*"en":\s*)"((?:[^"\\]|\\.)*)"')
                mm = pat.search(seg)
                if mm is None:
                    sys.exit(f'Stopped: weekContent.json week {week} has no size.{k}.en')
                if json.loads('"' + mm.group(2) + '"') != v:
                    changed += 1
                seg = pat.sub(lambda m_: m_.group(1) + json.dumps(v, ensure_ascii=False), seg, count=1)
            block = block[:seg_start] + seg + block[j:]
        out.append(raw[last:pos] + block)
        last = end
    new = ''.join(out)
    json.loads(new)  # still valid JSON, or nothing is written
    if changed:
        open(path, 'w', encoding='utf-8', newline='').write(new)
    print(f'weekContent.json: {changed} size field(s) updated')


if __name__ == '__main__':
    main()
