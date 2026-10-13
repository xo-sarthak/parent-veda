"""Pregnancy FAQ docs (.docx) -> lib/data/preg_faqs/month_N.dart.

Usage (from the repo root):
    python -I tools/preg_faqs/docx_to_dart.py "<Pregnancy FAQs folder>"

Each doc is one month of the Ask Veda FAQ Library ("Month 1 · Pregnancy · 60
FAQs"). Every FAQ is a fixed block:

    FAQ n · PREG-XXX-000
    <the question>
    Direct Answer / Why This Happens | Why It Matters / What This Means For You /
    When to Speak to Your Doctor / ParentVeda Perspective / Quick Takeaways /
    Related Content
    Category: … Applicability: … Clinical review: … Verification: … Status: …

A section can carry its own short sub-headings ("Can Have", "How It Works")
with bullets under them; those are kept in order. Month 8 marks bullets by
numbering instead of a bullet style, and glues its metadata into one line; both
are read the same way.

The FAQs become Ask Veda's KNOWLEDGE (the facts an answer stands on), not
canned answers: the AI writes every answer fresh for where the mother is (the
user, 2026-10-13). They also open as pages in the one reader.

HELD: an FAQ whose "Clinical review" says Yes, or whose Status says it holds,
is written out with held=true and never shown or exported until its id is
added to kPregFaqSignedOff (lib/data/preg_faqs.dart).

Strict: an unknown section label, an FAQ with no Direct Answer or no doctor
section, a month with no week range, or a duplicate id stops the run with the
doc and the FAQ named. "Related Content" titles that match no FAQ are listed,
never guessed. Standard library only.
"""

import html
import os
import re
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
OUT = os.path.join(ROOT, 'lib', 'data', 'preg_faqs')

# Doc label -> the Dart enum value.
LABELS = {
    'Direct Answer': 'direct',
    'Why This Happens': 'why',
    'Why It Matters': 'whyMatters',
    'What This Means For You': 'forYou',
    'When to Speak to Your Doctor': 'doctor',
    'ParentVeda Perspective': 'perspective',
    'Quick Takeaways': 'takeaways',
    'Related Content': 'related',
}
META_KEYS = ['Category', 'Applicability', 'Can-I', 'Doctor line', 'Clinical review', 'Sensitivity',
             'Words', 'Verification', 'Last verified', 'Status']
META_RE = re.compile(r'(' + '|'.join(re.escape(k) for k in META_KEYS) + r'):')
FAQ_RE = re.compile(r'^FAQ\s+(\d+)\s+·\s+([A-Z][A-Z0-9-]+)\s*$')


class DocError(Exception):
    pass


# ---- reading --------------------------------------------------------------------

def read_docx(path):
    """Lines as (kind, text): 'li' a bullet (style or numbering), 'p' anything else."""
    x = zipfile.ZipFile(path).read('word/document.xml').decode('utf8')
    lines = []
    for blk in re.findall(r'<w:p[ >].*?</w:p>', x, re.S):
        st = (re.search(r'<w:pStyle w:val="([^"]+)"', blk) or [None, ''])[1]
        li = '<w:numPr>' in blk or st.lower().startswith('listbullet')
        # Text, breaks and tabs IN ORDER, so glued metadata keeps its line ends.
        toks = re.findall(r'<w:t[^>]*>([^<]*)</w:t>|(<w:br\b[^>]*/>|<w:cr/>)|(<w:tab/>)', blk)
        t = html.unescape(''.join(a if a else ('\n' if b else ' ') for a, b, c in toks))
        if t.strip():
            lines.append(('li' if li else 'p', t))
    return lines


def parse_meta(text):
    """'Category: X\\nApplicability: Y…' or the same glued on one line -> dict."""
    out = {}
    parts = META_RE.split(text)
    for i in range(1, len(parts) - 1, 2):
        out[parts[i]] = ' '.join(parts[i + 1].split())
    return out


def is_subheading(t):
    """A short line inside a section with no closing punctuation: "Can Have"."""
    t = t.strip()
    return 0 < len(t) <= 60 and not re.search(r'[.?!:;,)"”]$', t) and t[:1].isupper()


def parse_doc(fname, lines):
    month = None
    m = re.search(r'Month\s+(\d+)\s+·\s+Pregnancy', fname)
    if m:
        month = int(m.group(1))
    else:
        raise DocError(f'{fname}: no "Month N · Pregnancy" in the file name')
    faqs, cur, section = [], None, None
    for kind, text in lines:
        t = text.strip()
        fm = FAQ_RE.match(t)
        if fm:
            cur = {'n': int(fm.group(1)), 'id': fm.group(2), 'month': month, 'file': fname,
                   'question': '', 'parts': [], 'related': [], 'meta': {}}
            faqs.append(cur)
            section = None
            continue
        if cur is None:
            continue  # the cover and the Contents
        if t.startswith('Category:'):
            cur['meta'] = parse_meta(text)
            section = 'done'
            continue
        if section == 'done':
            raise DocError(f'{fname} {cur["id"]}: text after the metadata: "{t[:60]}"')
        if not cur['question']:
            cur['question'] = ' '.join(t.split())
            continue
        if t in LABELS:
            section = LABELS[t]
            if section != 'related':
                cur['parts'].append({'section': section, 'heading': '', 'paras': [], 'bullets': []})
            continue
        if section is None:
            raise DocError(f'{fname} {cur["id"]}: text before any section: "{t[:60]}"')
        t = ' '.join(t.split())
        if section == 'related':
            cur['related'].append(t)
            continue
        part = cur['parts'][-1]
        if kind == 'li':
            part['bullets'].append(t)
        elif is_subheading(t):
            # A sub-heading opens its own block inside the same section.
            cur['parts'].append({'section': section, 'heading': t, 'paras': [], 'bullets': []})
        else:
            if part['bullets']:
                # A paragraph after bullets: a new block keeps the doc's order.
                cur['parts'].append({'section': section, 'heading': '', 'paras': [t], 'bullets': []})
            else:
                part['paras'].append(t)
    for f in faqs:
        secs = {p['section'] for p in f['parts'] if p['paras'] or p['bullets']}
        for need in ('direct', 'doctor'):
            if need not in secs:
                raise DocError(f'{fname} {f["id"]}: no {need} section')
        if not f['meta']:
            raise DocError(f'{fname} {f["id"]}: no metadata block')
        cr = f['meta'].get('Clinical review', '')
        status = f['meta'].get('Status', '')
        f['held'] = cr.lower().startswith('yes') or 'hold' in status.lower()
        f['held_note'] = cr if f['held'] else ''
        # Never carry an empty block (a label with nothing under it).
        f['parts'] = [p for p in f['parts'] if p['paras'] or p['bullets'] or p['heading']]
    return month, faqs


def month_weeks(month, faqs, fname):
    """The doc's own week range, from any 'Month N (weeks a to b)' applicability."""
    for f in faqs:
        m = re.search(rf'Month\s+{month}\s*\(weeks\s+(\d+)\s*(?:to|-|–)\s*(\d+)\)', f['meta'].get('Applicability', ''))
        if m:
            return int(m.group(1)), int(m.group(2))
    # A month whose FAQs all say "All trimesters" names its weeks in its title FAQ.
    for f in faqs:
        m = re.search(r'weeks\s+(\d+)\s*(?:to|-|–)\s*(\d+)', f['question'] + ' '.join(
            ' '.join(p['paras']) for p in f['parts'] if p['section'] == 'direct'))
        if m and f['id'].startswith('PREG-GEN'):
            return int(m.group(1)), int(m.group(2))
    raise DocError(f'{fname}: no week range for month {month}')


# ---- related content -> ids ---------------------------------------------------------

ORDINAL = {'1': 'first', '2': 'second', '3': 'third', '4': 'fourth', '5': 'fifth', '6': 'sixth',
           '7': 'seventh', '8': 'eighth', '9': 'ninth'}


def norm(t):
    t = t.lower().replace('’', "'").replace("'", '')
    # "in Month 1" and "in the first month" are the same words to a reader.
    t = re.sub(r'\bmonth\s+(\d)\b', lambda m: ORDINAL[m.group(1)] + ' month', t)
    return re.sub(r'[^a-z0-9 ]+', '', t).split()


STOP = set('a an the is are am i my me do does did can could should would will what when why how which '
           'in on of to for and or with during pregnancy pregnant it its this that be been at as by from '
           'there any you your we our'.split())


def _stem(w):
    return w[:-1] if len(w) > 3 and w.endswith('s') else w


def match_related(title, pool):
    """The FAQ a related title means. Related titles are short paraphrases of the
    full question ("When is a pregnancy test accurate?" for "When is a home
    pregnancy test accurate, and what is the beta hCG blood test?"), so the score
    is how many of the TITLE's content words the question covers, with plain
    overlap only breaking ties. Every content word must be covered: a near miss
    is reported, never guessed."""
    w = norm(title)
    if not w:
        return None
    key = {_stem(x) for x in w if x not in STOP}
    if not key:
        return None
    scored = []
    for f in pool:
        q = norm(f['question'])
        if q == w:
            return f['id']
        qs = {_stem(x) for x in q if x not in STOP}
        # Ties go to the question that opens with the same words ("What is the
        # NT scan?" is "What is the NT (nuchal…) scan…", not "How is the NT
        # scan done…"), then to the closer overall wording.
        lead = 0
        while lead < min(len(w), len(q)) and w[lead] == q[lead]:
            lead += 1
        scored.append(((len(key & qs) / len(key), lead, len(key & qs) / len(key | qs)), f))
    if not scored:
        return None
    scored.sort(key=lambda x: x[0], reverse=True)
    (cov, _, _), best = scored[0]
    return best['id'] if cov == 1.0 else None


# Related titles the writers shortened past any word match, each checked by eye
# against the question it means (2026-10-13). A title not here and not matched
# is reported, never guessed: a wrong "related" link sends her to the wrong page.
ALIASES = {
    'When is nausea more than morning sickness?': 'PREG-HEALTH-011',
    'When should I have my first scan?': 'PREG-SCAN-020',
    'What foods are said to cause miscarriage?': 'PREG-CANI-EAT-011',
    'Should I take folic acid?': 'PREG-CANI-TAKE-001',
    'Is it normal to feel anxious in early pregnancy?': 'PREG-EMOTION-001',
    'Is it normal to worry about miscarriage?': 'PREG-EMOTION-007',
    'Why do I have a metallic taste in my mouth?': 'PREG-BODY-015',
    'Can other family members, like my mother or mother-in-law, be present too?': 'PREG-PARTNER-007',
    'What scans will I need in pregnancy?': 'PREG-SCAN-022',
    # Month 2's exercise FAQ also says "what should I avoid"; the title means food.
    'What should I avoid in early pregnancy?': 'PREG-CANI-EAT-001',
}


def resolve_related(title, f, every):
    """The exact question anywhere, a checked alias, her month's full match, then any month's."""
    w = norm(title)
    for g in every:  # the exact question, in any month, beats a near one in hers
        if g is not f and norm(g['question']) == w:
            return g['id']
    same = [g for g in every if g['month'] == f['month'] and g is not f]
    rest = [g for g in every if g['month'] != f['month']]
    return ALIASES.get(title) or match_related(title, same) or match_related(title, rest)


# ---- Dart ------------------------------------------------------------------------------

def q(s):
    s = s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')
    return f"'{s}'"


def ql(items, ind):
    if not items:
        return '[]'
    pad = ' ' * ind
    return '[\n' + ''.join(f'{pad}  {q(x)},\n' for x in items) + f'{pad}]'


def dart_month(month, weeks, faqs):
    L = ['// GENERATED by tools/preg_faqs/docx_to_dart.py - do not edit by hand.',
         f"// Source: {faqs[0]['file']}", '', "import '../preg_faqs.dart';", '',
         f'/// Month {month}, weeks {weeks[0]} to {weeks[1]}.',
         f'const List<PregFaq> kPregFaqsMonth{month} = [']
    for f in faqs:
        m = f['meta']
        L.append('  PregFaq(')
        L.append(f"    id: {q(f['id'])},")
        L.append(f'    number: {f["n"]},')
        L.append(f'    month: {month},')
        L.append(f"    question: {q(f['question'])},")
        L.append(f"    category: {q(m.get('Category', '').replace('Pregnancy > ', ''))},")
        L.append(f"    applicability: {q(m.get('Applicability', ''))},")
        L.append(f"    canI: {q(m.get('Can-I', ''))},")
        L.append(f"    sensitivity: {q(m.get('Sensitivity', ''))},")
        # The Verification line is a writers' note (sources with brackets inside
        # brackets, search volumes, "No discrepancies"), not text for a mother:
        # it stays in the doc for reviewers and is not carried (2026-10-13).
        if f['held']:
            L.append('    held: true,')
            L.append(f"    heldNote: {q(f['held_note'])},")
        L.append('    parts: [')
        for p in f['parts']:
            L.append(f"      PregFaqPart(PregFaqSection.{p['section']}, {q(p['heading'])}, "
                     f"{ql(p['paras'], 6)}, {ql(p['bullets'], 6)}),")
        L.append('    ],')
        L.append(f"    related: {ql(f['related_ids'], 4)},")
        L.append('  ),')
    L.append('];')
    return '\n'.join(L) + '\n'


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    folder = sys.argv[1]
    months, errors = {}, []
    for fname in sorted(os.listdir(folder)):
        if not fname.lower().endswith('.docx'):
            continue
        try:
            lines = read_docx(os.path.join(folder, fname))
            month, faqs = parse_doc(fname, lines)
            if month in months:
                raise DocError(f'{fname}: month {month} appears twice')
            months[month] = (month_weeks(month, faqs, fname), faqs, lines)
        except DocError as e:
            errors.append(str(e))
    if errors:
        sys.exit('Stopped, nothing written:\n  ' + '\n  '.join(errors))

    every = [f for _, (_, fs, _) in sorted(months.items()) for f in fs]
    ids = {}
    for f in every:
        if f['id'] in ids:
            sys.exit(f'Stopped: {f["id"]} is in both {ids[f["id"]]} and {f["file"]}')
        ids[f['id']] = f['file']

    unmatched = []
    for f in every:
        f['related_ids'] = []
        for t in f['related']:
            hit = resolve_related(t, f, every)
            if hit == f['id']:
                hit = None  # a page never lists itself
            if hit and hit not in f['related_ids']:
                f['related_ids'].append(hit)
            elif not hit:
                unmatched.append(f'{f["id"]}: "{t}"')

    # Dropped-lines audit: every source line must be carried, or be a label,
    # an FAQ marker, the metadata, the cover or the Contents.
    dropped = []
    for month, (_, faqs, lines) in months.items():
        carried = set()
        for f in faqs:
            carried.add(f['question'])
            carried.update(f['related'])
            for p in f['parts']:
                carried.add(p['heading'])
                carried.update(p['paras'])
                carried.update(p['bullets'])
        started = False
        for _, t in lines:
            s = ' '.join(t.split())
            if FAQ_RE.match(t.strip()):
                started = True
                continue
            if not started or s in LABELS or s.startswith('Category:') or s in carried:
                continue
            dropped.append(f'Month {month}: "{s[:90]}"')

    os.makedirs(OUT, exist_ok=True)
    for old in os.listdir(OUT):
        if old.endswith('.dart'):
            os.remove(os.path.join(OUT, old))
    for month, (weeks, faqs, _) in sorted(months.items()):
        with open(os.path.join(OUT, f'month_{month}.dart'), 'w', encoding='utf-8', newline='\n') as fh:
            fh.write(dart_month(month, weeks, faqs))
    idx = ['// GENERATED by tools/preg_faqs/docx_to_dart.py - do not edit by hand.', '']
    idx += [f"import 'month_{m}.dart';" for m in sorted(months)]
    idx += ["import '../preg_faqs.dart';", '',
            '/// Every month the FAQ Library has sent, with its week range.',
            'const List<PregFaqMonth> kPregFaqMonths = [']
    for m, (weeks, _, _) in sorted(months.items()):
        idx.append(f'  PregFaqMonth({m}, {weeks[0]}, {weeks[1]}, kPregFaqsMonth{m}),')
    idx.append('];')
    with open(os.path.join(OUT, 'index.dart'), 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('\n'.join(idx) + '\n')

    held = [f for f in every if f['held']]
    subs = sorted({p['heading'] for f in every for p in f['parts'] if p['heading']})
    print(f'Wrote {len(every)} FAQs in {len(months)} months: ' +
          ', '.join(f'M{m} wk {w[0]}-{w[1]} ({len(fs)})' for m, (w, fs, _) in sorted(months.items())))
    print(f'Held for clinical sign-off: {len(held)}')
    for f in held:
        print(f'  {f["id"]} (M{f["month"]}): {f["question"][:70]} [{f["held_note"][:60]}]')
    print(f'Sub-headings kept ({len(subs)}): ' + '; '.join(subs))
    print(f'Related titles with no FAQ ({len(unmatched)}):')
    for u in unmatched:
        print('  ' + u)
    print(f'Dropped lines ({len(dropped)}):')
    for d in dropped:
        print('  ' + d)


if __name__ == '__main__':
    main()
