"""My Child phase docs (.docx) -> lib/data/pp_phase_docs/phase_NN.dart.

Usage (from the repo root):
    python -I tools/phase_pages/docx_to_dart.py "<My Child phase-wise content folder>"

Each doc (PH001-PH015) holds a phase page (Hero, Living Through This Phase,
Child Snapshot, When to Contact Your Doctor), five milestone pages and an
activity set. The docs were written over many revisions and their layout
varies (labels inline or on their own line, tips as list items or "✓" lines,
revision notes in brackets), so parsing is by LABEL, not by paragraph style.

Two moves make the variety tractable:
  * a revision note in brackets - "(89 words)", "(renamed)", "(MS011)" - is
    REPLACED BY A LINE BREAK, not just deleted, which also un-glues
    "What Is It? (89 words)In these early weeks" into label and text;
  * a known inline label ("One-line summary:", "Related Topics:") gets a line
    break before it.

Strict on purpose: a line no section understands, a missing part, or a
snapshot that is not exactly Brain, Physical, Language, Emotional, Nutrition
stops the run, naming the doc and the line. Standard library only.
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'lib', 'data', 'pp_phase_docs')
BR = '\n'
DOMAINS = ['Brain', 'Physical', 'Language', 'Emotional', 'Nutrition']
DOMAIN_RE = '|'.join(DOMAINS)

# A bracketed note is the author's, not the parent's.
NOTE_WORDS = (r'words?|cards?|bullets?|revised|revision|renamed|unchanged|updated|corrected|'
              r'restored|replaces|replaced|frozen|target|primary|secondary|feedback|qualifier|'
              r'safety focus|final|full revised|incorporated|domains?|fixed order|reframed|reworded|added|gate')
NOTE = re.compile(r'\s*\((?:[^()]*\b(?:' + NOTE_WORDS + r')\b[^()]*|[^()]*✓[^()]*|MS\d+|ACT\d+|PH\d+)\)',
                  re.I)
# A paragraph that is a note to the builder, dropped whole.
DROP = re.compile(r'^(Change log|Note:|Note —|Needs paediatric|paediatric panel|Panel to review|Page components|'
                  r'\(No |\(Full |Revision|Important revision|Important:|I would |Why I changed|Medical Flag Summary|Status:|AAP notes|~?\d+ words|\d+ cards|'
                  r'5 fixed domains)', re.I)
INLINE_LABELS = ['One-line summary:', 'Related Topics:', 'Why ParentVeda Recommends It:',
                 "What You'll Need:", 'Variations:', 'Linked Milestones', 'Domain:', 'Typical age:',
                 'What It Builds:', 'Secondary Domain:']
BLOCK_LABELS = ['What Is It?', 'Why It Matters', 'ParentVeda Insight', 'Ways to Support']


class DocError(Exception):
    pass


def paragraphs(path):
    """Each paragraph as (is_list_item, text with BR at line breaks)."""
    xml = zipfile.ZipFile(path).read('word/document.xml').decode('utf8')
    out = []
    for para in re.findall(r'<w:p[ >].*?</w:p>', xml, re.S):
        parts = []
        for run in re.findall(r'<w:r[ >].*?</w:r>', para, re.S):
            t = ''.join(re.findall(r'<w:t[^>]*>([^<]*)</w:t>', run))
            if '<w:br' in run or '<w:cr/>' in run:
                t += BR
            parts.append(t)
        text = html.unescape(''.join(parts)).replace(' ', ' ')
        if text.strip():
            out.append(('<w:numPr>' in para, text))
    return out


def clean_para(text):
    # "…Pretend PlayWhy⏎ParentVeda Recommends It:" - a label broken across lines.
    t = re.sub(r'Why\s*\n\s*ParentVeda Recommends', 'Why ParentVeda Recommends', text)
    # "Settling Into Feeds — note: the activity page names…": an editor's
    # aside. Removed BEFORE the bracket notes, which would split it in two.
    t = re.sub(r'\s+—\s+note:[^\n]*', '', t)
    for _ in range(3):
        t = NOTE.sub(BR, t)
    t = re.sub(r'\s+—\s+(primary|optional, secondary)\b', '', t)
    for lab in INLINE_LABELS:
        t = re.sub(r'(?<!^)(?<!\n)' + re.escape(lab), BR + lab, t)
    return t


def lines_of(paras):
    """Flatten to (is_list_item, line) after cleaning, dropping builder notes."""
    out = []
    for is_list, raw in paras:
        if DROP.match(raw.strip()):
            continue
        segs = []
        for seg in clean_para(raw).split(BR):
            seg = re.sub(r'\s+', ' ', seg).strip()
            if not seg or DROP.match(seg):
                continue
            # A line break mid-sentence: the next piece starts lower-case.
            if segs and seg[0].islower():
                prev = segs[-1]
                segs[-1] = prev + ('' if prev.endswith(('"', '“', "'")) and prev.count('"') % 2 else ' ') + seg
                continue
            segs.append(seg)
        for seg in segs:
            # A label at the start of a line with its text glued on.
            for lab in BLOCK_LABELS:
                if seg.startswith(lab) and len(seg) > len(lab) and seg[len(lab)] not in ' :?':
                    out.append((False, lab))
                    seg = seg[len(lab):].strip()
            out.append((is_list, seg))
    return out


GLUE = re.compile(r"^(.{3,70}?[a-z?!)])([A-Z][a-z]*[’']?[a-z]*\b.*)$")


def unglue(line):
    """'Starting First FoodsAround this age…' -> ('Starting First Foods', 'Around this age…')."""
    m = GLUE.match(line)
    if m and ' ' in m.group(2):
        return m.group(1).strip(), m.group(2).strip()
    return None


def split_ticks(line):
    """'✓ A.✓ B.' -> ['A.', 'B.']"""
    return [x.strip() for x in line.split('✓') if x.strip()]


def is_heading(line, *names):
    l = re.sub(r'^\d+\.\s*', '', line).strip().lower()
    return any(l == n or l.startswith(n + ' ') for n in names)


def section_of(line):
    if is_heading(line, 'hero'):
        return 'hero'
    if is_heading(line, 'living through this phase'):
        return 'living'
    if is_heading(line, 'child snapshot'):
        return 'snapshot'
    if re.match(r'^(\d\.\s*)?when to (contact|consult) your doctor$', line, re.I):
        return 'doctor'
    if re.match(r'^milestone pages?\b', line, re.I):
        return 'milestones'
    if re.match(r'^activity (pages?|set)\b', line, re.I):
        return 'activities'
    return None


def ends_sentence(s):
    return bool(re.search(r'[.!?…"”’)]$', s))


# ---- the phase page -----------------------------------------------------------

def parse_living(rows, code):
    cards, cur = [], None
    for is_list, t in rows:
        if t.startswith('✓') or (is_list and cur and cur['body']):
            if cur is None:
                raise DocError(f'{code}: a tip before any card: {t[:60]!r}')
            cur['tips'] += split_ticks(t)
            continue
        t = re.sub(r'^Card \d+\s*—\s*', '', t)
        # A new card starts once the last one has its tips.
        if cur is None or cur['tips']:
            glued = unglue(t)
            if glued:
                cur = {'title': glued[0], 'body': glued[1], 'tips': []}
                cards.append(cur)
                continue
            if not ends_sentence(t) and len(t) < 70:
                cur = {'title': t, 'body': '', 'tips': []}
                cards.append(cur)
                continue
        if cur is None:
            raise DocError(f'{code}: living text before any card: {t[:60]!r}')
        cur['body'] = (cur['body'] + ' ' + t).strip()
    for c in cards:
        if not c['body'] or not c['tips']:
            raise DocError(f'{code}: living card "{c["title"]}" has no body or no tips')
    if not 4 <= len(cards) <= 6:
        raise DocError(f'{code}: {len(cards)} living cards, expected 4-6')
    return cards


def parse_snapshot(rows, code):
    snaps = []
    for _, t in rows:
        m = re.match(r'^(' + DOMAIN_RE + r')\s*[—–-]\s*(.+)$', t)
        if m:
            snaps.append([m.group(1), m.group(2).strip(), ''])
            continue
        if not snaps:
            raise DocError(f'{code}: snapshot text before a domain: {t[:60]!r}')
        snaps[-1][2] = (snaps[-1][2] + ' ' + t).strip()
    # A title glued to its line ("Focusing on FacesYour baby…"), or "Title: line".
    for s in snaps:
        if not s[2]:
            glued = unglue(s[1])
            if glued is None and ': ' in s[1]:
                glued = tuple(x.strip() for x in s[1].split(': ', 1))
            if glued is None:
                raise DocError(f'{code}: snapshot "{s[1]}" has no line')
            s[1], s[2] = glued
    if [s[0] for s in snaps] != DOMAINS:
        raise DocError(f'{code}: snapshot domains are {[s[0] for s in snaps]}, expected {DOMAINS}')
    return snaps


# ---- milestone pages -----------------------------------------------------------

MS_TITLE = re.compile(r'^(.+?)\s*·\s*(' + DOMAIN_RE + r')$')


def parse_milestones(rows, code):
    pages, cur, field = [], None, None
    for is_list, t in rows:
        m = MS_TITLE.match(t)
        if m and not t.startswith(('Activities', 'Related Topics', 'Phase:')):
            cur = {'title': m.group(1).strip(), 'domain': m.group(2), 'typicalAge': '', 'summary': '',
                   'whatIsIt': '', 'whyItMatters': '', 'insight': '', 'ways': [], 'activities': [],
                   'relatedTopics': [], 'doctor': []}
            pages.append(cur)
            field = None
            continue
        if cur is None:
            raise DocError(f'{code}: milestone text before a milestone title: {t[:60]!r}')
        if t.startswith('Phase:') or t.startswith('Domain:'):
            field = None
            continue
        if t.startswith('Typical age:'):
            cur['typicalAge'] = t[len('Typical age:'):].strip()
            field = None
            continue
        if t.startswith('One-line summary:'):
            cur['summary'] = t[len('One-line summary:'):].strip()
            field = 'summary' if not cur['summary'] else None
            continue
        if t in ('What Is It?', 'What Is It'):
            field = 'whatIsIt'; continue
        if t == 'Why It Matters':
            field = 'whyItMatters'; continue
        if t == 'ParentVeda Insight':
            field = 'insight'; continue
        if t == 'Ways to Support':
            field = 'ways'; continue
        if re.match(r'^Activities\b', t):
            rest = re.sub(r'^Activities:?\s*', '', t)
            field = 'activities'
            if rest:
                cur['activities'] += [x.strip() for x in rest.split('·') if x.strip()]
            continue
        if re.match(r'^Related Topics\b', t):
            rest = re.sub(r'^Related Topics:?\s*', '', t)
            field = 'relatedTopics'
            if rest:
                cur['relatedTopics'] += [x.strip() for x in rest.split('·') if x.strip()]
            continue
        if re.match(r'^When to (Contact|Consult) Your Doctor$', t):
            field = 'doctor'; continue
        if field in ('ways', 'doctor'):
            cur[field].append(t)
        elif field in ('activities', 'relatedTopics'):
            cur[field] += [x.strip() for x in t.split('·') if x.strip()]
        elif field in ('whatIsIt', 'whyItMatters', 'insight', 'summary'):
            cur[field] = (cur[field] + ' ' + t).strip()
        else:
            raise DocError(f'{code}: milestone "{cur["title"]}" line not understood: {t[:70]!r}')
    for p in pages:
        for k in ('summary', 'whatIsIt', 'whyItMatters', 'insight', 'ways', 'doctor'):
            if not p[k]:
                raise DocError(f'{code}: milestone "{p["title"]}" has no {k}')
        p['activities'] = [re.sub(r'\s*\(ACT\d+\)', '', a).strip() for a in p['activities']]
        p['relatedTopics'] = [re.sub(r'\s*\(PH[^()]*\)', '', a).strip() for a in p['relatedTopics']]
    if [p['domain'] for p in pages] != DOMAINS:
        raise DocError(f'{code}: milestone domains are {[p["domain"] for p in pages]}')
    return pages


# ---- activities ---------------------------------------------------------------

# "ACT023 · Reach and Squeal Play · Physical + Language": filed under the first.
ACT_TITLE = re.compile(r'^(?:ACT\d+\s*·\s*)?(.+?)\s*·\s*(' + DOMAIN_RE + r')(?:\s*\+\s*(?:' + DOMAIN_RE + r'))*$')
ACT_LABELS = {
    'Introduction': 'intro',
    'Secondary Domain:': None,
    'What It Builds:': 'builds',
    'Why ParentVeda Recommends It:': 'why',
    "What You'll Need:": 'need',
    'How To Do It:': 'steps',
    'Things to Remember:': 'remember',
    'Keep It Safe:': 'safe',
    'Variations:': 'variations',
    'Linked Milestones': 'linked',
}


def parse_activities(rows, code):
    acts, cur, field = [], None, None
    for is_list, t in rows:
        m = ACT_TITLE.match(t)
        if m and not t.startswith(tuple(ACT_LABELS)):
            cur = {'title': m.group(1).strip(), 'domain': m.group(2), 'intro': '', 'builds': [], 'why': '',
                   'need': [], 'steps': [], 'remember': [], 'safe': [], 'variations': '', 'linked': []}
            acts.append(cur)
            field = 'intro'
            continue
        if cur is None:
            raise DocError(f'{code}: activity text before an activity title: {t[:60]!r}')
        label = next((l for l in ACT_LABELS if t.startswith(l)), None)
        if label:
            field = ACT_LABELS[label]
            rest = t[len(label):]
            rest = re.sub(r'^\s*(\(corrected\))?\s*:?\s*', '', rest).strip()
            if field is None or not rest:
                continue
            t = rest
        if field is None:
            continue  # the secondary domain's value on its own line
        # "Linked Milestones (corrected): X" loses its bracket to a line break,
        # leaving ": X" on the next line.
        t = re.sub(r'^:\s*', '', t)
        if field == 'linked':
            t = re.sub(r'\s*\([^()]*\)', '', t)
            t = re.sub(r'\s*—\s*optional\b', '', t)
            for x in (x.strip() for x in t.split('·')):
                if x and x not in cur[field]:
                    cur[field].append(x)
        elif field in ('builds', 'need'):
            cur[field] += [x.strip() for x in t.split('·') if x.strip()]
        elif field in ('steps', 'remember', 'safe'):
            cur[field].append(re.sub(r'^\d+[.)]\s*', '', t))
        else:
            cur[field] = (cur[field] + ' ' + t).strip()
    for a in acts:
        a['linked'] = [re.sub(r'\s*\((?:[^()]*·[^()]*|MS\d+)\)', '', x).strip() for x in a['linked']]
        for k in ('intro', 'builds', 'why', 'need', 'steps', 'safe'):
            if not a[k]:
                raise DocError(f'{code}: activity "{a["title"]}" has no {k}')
    if len(acts) < 4:
        raise DocError(f'{code}: only {len(acts)} activities')
    return acts


# ---- one doc -------------------------------------------------------------------

def parse(path):
    rows = lines_of(paragraphs(path))
    first = rows[0][1]
    m = re.match(r'^(?:PH0*(\d+)|Phase (\d+))\s*[—–-]\s*(.+)$', first)
    if not m:
        raise DocError(f'{os.path.basename(path)}: first line is not "PHnnn — Name": {first!r}')
    n = int(m.group(1) or m.group(2))
    code = f'PH{n:03d}'
    name = re.sub(r'\s*\(\d+ months?\)$', '', m.group(3)).strip()

    sections = {k: [] for k in ('hero', 'living', 'snapshot', 'doctor', 'milestones', 'activities')}
    cur = 'hero'  # a doc with no Hero heading starts its hero after the title
    for is_list, t in rows[1:]:
        s = section_of(t)
        if s and not (s == 'doctor' and cur in ('milestones', 'activities')):
            cur = s
            continue
        # The age line under the title ("8 months (34–38 weeks)", "13–15 months").
        if cur == 'hero' and not sections['hero'] and re.match(r'^[\d–\- ]+(weeks?|months?)\b', t):
            continue
        sections[cur].append((is_list, t))

    hero = [t for _, t in sections['hero']]
    if not 3 <= len(hero) <= 7:
        raise DocError(f'{code}: hero has {len(hero)} paragraphs: {[h[:30] for h in hero]}')
    doctor = [t for _, t in sections['doctor']]
    if len(doctor) < 3:
        raise DocError(f'{code}: phase doctor list has {len(doctor)} lines')
    return {
        'phase': n, 'code': code, 'name': name, 'hero': hero,
        'living': parse_living(sections['living'], code),
        'snapshot': parse_snapshot(sections['snapshot'], code),
        'doctor': doctor,
        'milestones': parse_milestones(sections['milestones'], code),
        'activities': parse_activities(sections['activities'], code),
        'source': os.path.basename(path),
    }


# ---- Dart -----------------------------------------------------------------------

def q(s):
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{s}'"


def ql(items, ind):
    if not items:
        return 'const []'
    pad = ' ' * ind
    return '[\n' + ''.join(f'{pad}  {q(x)},\n' for x in items) + f'{pad}]'


def dom(d):
    return 'PpDocDomain.' + d.lower()


def dart(p):
    n = p['phase']
    L = ['// GENERATED by tools/phase_pages/docx_to_dart.py - do not edit by hand.',
         f"// Source: {p['source']}", '', "import '../pp_phase_docs.dart';", '',
         f'const PpPhaseDoc kPpPhaseDoc{n:02d} = PpPhaseDoc(',
         f'  phase: {n},', f"  code: {q(p['code'])},", f"  name: {q(p['name'])},",
         f"  hero: {ql(p['hero'], 2)},", '  living: [']
    for c in p['living']:
        L.append(f"    PpLivingCard({q(c['title'])}, {q(c['body'])}, {ql(c['tips'], 4)}),")
    L.append('  ],')
    L.append('  snapshot: [')
    for d, t, line in p['snapshot']:
        L.append(f'    PpSnapshot({dom(d)}, {q(t)}, {q(line)}),')
    L.append('  ],')
    L.append(f"  doctor: {ql(p['doctor'], 2)},")
    L.append('  milestones: [')
    for m in p['milestones']:
        L += ['    PpMilestonePage(',
              f"      domain: {dom(m['domain'])},", f"      title: {q(m['title'])},",
              f"      typicalAge: {q(m['typicalAge'])},", f"      summary: {q(m['summary'])},",
              f"      whatIsIt: {q(m['whatIsIt'])},", f"      whyItMatters: {q(m['whyItMatters'])},",
              f"      insight: {q(m['insight'])},", f"      ways: {ql(m['ways'], 6)},",
              f"      activities: {ql(m['activities'], 6)},",
              f"      relatedTopics: {ql(m['relatedTopics'], 6)},",
              f"      doctor: {ql(m['doctor'], 6)},", '    ),']
    L.append('  ],')
    L.append('  activities: [')
    for a in p['activities']:
        L += ['    PpPhaseActivity(',
              f"      title: {q(a['title'])},", f"      domain: {dom(a['domain'])},",
              f"      intro: {q(a['intro'])},", f"      builds: {ql(a['builds'], 6)},",
              f"      why: {q(a['why'])},", f"      need: {ql(a['need'], 6)},",
              f"      steps: {ql(a['steps'], 6)},", f"      remember: {ql(a['remember'], 6)},",
              f"      safe: {ql(a['safe'], 6)},", f"      variations: {q(a['variations'])},",
              f"      linked: {ql(a['linked'], 6)},", '    ),']
    L.append('  ],')
    L.append(');')
    return '\n'.join(L) + '\n'


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    folder = sys.argv[1]
    files = sorted(f for f in os.listdir(folder) if f.lower().endswith('.docx'))
    docs, errors = [], []
    for f in files:
        try:
            docs.append(parse(os.path.join(folder, f)))
        except DocError as e:
            errors.append(str(e))
    if errors:
        sys.exit('Stopped, nothing written:\n  ' + '\n  '.join(errors))
    phases = sorted(d['phase'] for d in docs)
    if len(phases) != len(set(phases)):
        sys.exit(f'Stopped: a phase appears twice: {phases}')
    os.makedirs(OUT, exist_ok=True)
    for d in docs:
        with open(os.path.join(OUT, f"phase_{d['phase']:02d}.dart"), 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(dart(d))
    idx = ['// GENERATED by tools/phase_pages/docx_to_dart.py - do not edit by hand.', '']
    idx += [f"import 'phase_{n:02d}.dart';" for n in phases]
    idx += ["import '../pp_phase_docs.dart';", '', '/// Every phase with a doc, in phase order.',
            'const List<PpPhaseDoc> kPpPhaseDocList = [']
    idx += [f'  kPpPhaseDoc{n:02d},' for n in phases]
    idx += ['];', '']
    with open(os.path.join(OUT, 'index.dart'), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(idx))
    print(f'Wrote {len(docs)} phases: {", ".join(str(n) for n in phases)}')


if __name__ == '__main__':
    main()
