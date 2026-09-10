# =============================================================================
#  parenting_content_brief.py -- one stage's content order form
# -----------------------------------------------------------------------------
#  ONE document, ONE stage, all three kinds of ask inside it.
#
#  ⚠️ THIS IS THE OTHER CUT OF THE SAME DATA, AND BOTH ARE WANTED.
#  `content_inventory.py` prints three sheets cut by KIND -- every image in one
#  document, every piece of writing in the next -- with the five stages as
#  sections inside each. That is the right shape for costing the whole app.
#  It is the wrong shape for a team that owns one stage, who then has to carry
#  three documents and read a fifth of each. This prints their list instead.
#
#     python tools/parenting_content_brief.py [stage] --pdf
#     stage = pp | ttc | preg | father | shared     (default: pp)
#     python tools/parenting_content_brief.py --all --pdf
#
#  Reads research/content-inventory/<stage>_{images,written,other}.csv, and
#  <stage>_summary.md when one exists. Same look as the door maps: door_map.css, cached fonts,
#  Chrome's print step. Landscape, because the detail tables are wide.
#
#  ⚠️ THE RETIRED WARNING IS THE POINT OF THE FRONT MATTER. 218 of the 3,370
#  items counted here sit on screens the current flow no longer opens -- 85
#  image slots, 75 written items, 58 other units. Commissioning those is money
#  spent on a surface nobody reaches, so `ships()` folds both `old` and
#  `old (retired)` into one bucket and the count is promoted to the front page
#  rather than left for a reader to notice on page 40.
# =============================================================================

import csv
import html
import os
import re
import sys
from collections import OrderedDict, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
# ⚠️ THE BRIEFS LIVE IN THEIR OWN FOLDER. Nine PDFs loose in docs/ buried the
# door maps and the specs; they are one deliverable and they sit together.
DOCS = os.path.join(ROOT, 'docs', 'content-brief')
os.makedirs(DOCS, exist_ok=True)
E = html.escape

sys.path.insert(0, HERE)
from content_inventory import fonts_css, to_pdf, num          # noqa: E402

SRC = os.path.join(ROOT, 'research', 'content-inventory')

# file prefix -> (output name, kicker, cover headline, what was analysed)
STAGES = OrderedDict([
    ('ttc', ('TTC-CONTENT-BRIEF', 'trying to conceive',
             'What the trying-to-conceive<br>side needs made',
             'lib/ttc/ — the seven doors, the reads, the film catalogue and every seed '
             'list — plus lib/screens/ttc/')),
    ('preg', ('PREGNANCY-CONTENT-BRIEF', 'pregnancy, her side',
              'What the pregnancy<br>side needs made',
              'lib/data/ — the weekly spine, the daily content and every seed list — plus '
              'lib/screens/ and assets/')),
    ('father', ('FATHER-CONTENT-BRIEF', 'father mode',
                'What the father<br>side needs made',
                'lib/data/father/, lib/screens/father/ and the father models')),
    ('pp', ('PARENTING-CONTENT-BRIEF', 'parenting, 0 to 5 years',
            'What the parenting<br>side needs made',
            'lib/screens/post_pregnancy/ (226 files) and the parenting entries in '
            'lib/data/')),
    ('skilling', ('SKILLING-CONTENT-BRIEF', 'skilling — a design preview',
                  'What the skilling<br>stage would need',
                  'lib/data/brackets/skilling_brackets.dart and '
                  'lib/screens/skilling/')),
    ('shared', ('SHARED-CONTENT-BRIEF', 'shared, commerce and platform',
                'What the shared<br>surfaces need made',
                'lib/data/brackets/, lib/data/hubs/, lib/experts/, lib/booking/, '
                'lib/brand/ and the platform services')),
])
STAGE = 'pp'
OUT_NAME = STAGES[STAGE][0]

SHEETS = OrderedDict([
    ('images', ('Pictures, film and sound',
                'Every visual and audio slot this stage has, what it is for, '
                'where it appears, what shape it has to be, and what stands in for it today.')),
    ('written', ('Writing',
                 'Every piece of prose the stage renders: what type it is, what it is called, '
                 'what it is for, which age it speaks to, and how long the placeholder runs.')),
    ('other', ('Everything else we have to supply',
               'Audio files, activities, experts, paid offerings, product entries, deals, '
               'rooms and data sources -- the things that are neither a picture nor prose.')),
])

COLUMNS = {
    'images': [
        ('tap_path', 'Where it appears', '20%'), ('item', 'What is needed', '20%'),
        ('kind', 'Kind', '7%'), ('count', 'No.', '4%'),
        ('size_or_aspect', 'Shape / size', '15%'), ('placeholder_now', 'Today', '8%'),
        ('version', 'Ships?', '7%'), ('notes', 'Notes', '19%'),
    ],
    'written': [
        ('tap_path', 'Where it appears', '17%'), ('content_type', 'Type', '10%'),
        ('title_or_id', 'Title', '15%'), ('purpose', 'What it is for', '19%'),
        ('audience_age', 'Age', '7%'), ('current_words', 'Words', '4%'),
        ('count', 'No.', '4%'), ('status', 'Today', '7%'),
        ('version', 'Ships?', '6%'), ('notes', 'Notes', '11%'),
    ],
    'other': [
        ('tap_path', 'Where it appears', '18%'), ('placeholder_type', 'Type', '11%'),
        ('item', 'Item', '15%'), ('count', 'No.', '4%'),
        ('what_is_needed_from_us', 'What we have to provide', '24%'),
        ('current_state', 'Today', '16%'), ('version', 'Ships?', '6%'),
        ('source_file', 'In code', '6%'),
    ],
}

STYLE = """
@page { size: A4 landscape; margin: 12mm 11mm 13mm; }
body{font-size:8pt}
.cover{height:170mm}
table{border-collapse:collapse; width:100%; table-layout:fixed}
th{font-family:Manrope; font-size:6.4pt; font-weight:800; letter-spacing:.8pt; text-transform:uppercase;
   color:var(--mute); text-align:left; padding:3pt 4pt; border-bottom:1.5px solid var(--line); vertical-align:bottom}
td{font-size:7.2pt; line-height:1.34; padding:3pt 4pt; border-bottom:1px solid var(--hair); vertical-align:top; word-wrap:break-word}
tr{page-break-inside:avoid; break-inside:avoid}
td.n{font-family:"IBM Plex Mono"; text-align:right; white-space:nowrap; color:var(--ink)}
td.t{color:var(--ink); font-weight:700}
td.m{color:var(--mute)}
td.code{font-family:"IBM Plex Mono"; font-size:6.2pt; color:var(--mute)}
.sum td{font-size:8.4pt}
.sum td.n{font-size:9pt}
.area{margin:10pt 0 3pt; display:flex; align-items:baseline; gap:8pt; border-top:1.5px solid var(--line); padding-top:6pt}
.area h4{font-size:9.6pt}
.area .cnt{font-family:"IBM Plex Mono"; font-size:7pt; color:var(--pv)}
.legend{display:flex; gap:13pt; flex-wrap:wrap; font-size:7.6pt; color:var(--mute); margin:5pt 0 9pt}
.legend b{color:var(--ink)}
.chip.v3{background:var(--safe-soft); color:var(--safe)}
.chip.old{background:var(--myth-soft); color:var(--myth)}
.chip.dead{background:var(--doc-soft); color:var(--doc)}
.chip.un{background:#f2f0f4; color:var(--mute)}
.chip.real{background:var(--safe-soft); color:var(--safe)}
.chip.ph{background:var(--doc-soft); color:var(--doc)}
.chip.cs{background:var(--tool-soft); color:var(--tool)}
.two{columns:2; column-gap:16pt}
.two p, .two li{break-inside:avoid}
.notes{font-size:8.4pt; line-height:1.55}
.notes h4{margin:8pt 0 3pt}
.notes p{margin:0 0 6pt}
.notes ol,.notes ul{margin:0 0 6pt 14pt; padding:0}
.notes li{margin:0 0 4pt}
.warn{border:1.5px solid var(--doc); background:var(--doc-soft); border-radius:5pt; padding:11pt 13pt; margin:0 0 12pt}
.warn h4{color:var(--doc); font-size:10pt; margin-bottom:5pt}
.warn p{font-size:8.6pt; line-height:1.55; color:var(--ink); margin:0 0 5pt}
.big{display:flex; gap:16pt; flex-wrap:wrap; margin:10pt 0 4pt}
.big div{border-left:2.5px solid var(--pv); padding-left:10pt; min-width:88pt}
.big .n{font-family:Fraunces; font-size:22pt; color:var(--ink); line-height:1}
.big .l{font-size:7pt; font-weight:800; letter-spacing:1pt; text-transform:uppercase; color:var(--mute); margin-top:4pt}
"""


def read(kind):
    p = os.path.join(SRC, '%s_%s.csv' % (STAGE, kind))
    with open(p, encoding='utf-8-sig', newline='') as f:
        return [{(k or '').strip(): (v or '').strip() for k, v in r.items()}
                for r in csv.DictReader(f)]


def n(row):
    return num(row.get('count')) or 0


def ships(v):
    """Three buckets that matter to whoever is paying: live, retired, unknown."""
    v = (v or '').lower()
    if 'retired' in v:
        return 'retired'
    if v.startswith('old'):
        return 'retired'
    if 'unsure' in v or not v:
        return 'unsure'
    return 'live'


def chip_ships(v):
    b = ships(v)
    if b == 'retired':
        return '<span class="chip dead">%s</span>' % E(v or 'old')
    if b == 'unsure':
        return '<span class="chip un">unsure</span>'
    return '<span class="chip v3">%s</span>' % E(v)


def chip_state(v):
    t = (v or '').lower()
    if 'real' in t and 'unreal' not in t:
        return '<span class="chip real">%s</span>' % E(v)
    if 'coming' in t or 'derived' in t:
        return '<span class="chip cs">%s</span>' % E(v)
    return '<span class="chip ph">%s</span>' % E(v or '--')


def cell(kind, col, row):
    v = row.get(col, '')
    if col in ('count', 'current_words'):
        return '<td class="n">%s</td>' % E(v or '--')
    if col == 'version':
        return '<td>%s</td>' % chip_ships(v)
    if col in ('placeholder_now', 'status', 'current_state'):
        if col == 'current_state':
            return '<td class="m">%s</td>' % E(v)
        return '<td>%s</td>' % chip_state(v)
    if col in ('item', 'title_or_id'):
        return '<td class="t">%s</td>' % E(v)
    if col == 'source_file':
        return '<td class="code">%s</td>' % E(v.replace('lib/screens/post_pregnancy/', ''))
    if col == 'notes':
        return '<td class="m">%s</td>' % E(v)
    return '<td>%s</td>' % E(v)


def table(kind, rows):
    cols = COLUMNS[kind]
    out = ['<table><colgroup>%s</colgroup><thead><tr>%s</tr></thead><tbody>' % (
        ''.join('<col style="width:%s">' % w for _, _, w in cols),
        ''.join('<th>%s</th>' % E(h) for _, h, _ in cols))]
    for r in rows:
        out.append('<tr>%s</tr>' % ''.join(cell(kind, c, r) for c, _, _ in cols))
    out.append('</tbody></table>')
    return ''.join(out)


def group_table(rows, col, label, top=None):
    by = defaultdict(lambda: [0, 0])
    for r in rows:
        k = (r.get(col) or 'unspecified')
        by[k][0] += 1
        by[k][1] += n(r) or 1
    items = sorted(by.items(), key=lambda kv: -kv[1][1])
    if top:
        items = items[:top]
    out = ['<table class="sum"><colgroup><col style="width:58%%"><col style="width:21%%">'
           '<col style="width:21%%"></colgroup><thead><tr><th>%s</th><th>Lines</th>'
           '<th>Items to make</th></tr></thead><tbody>' % E(label)]
    for k, (lines, items_n) in items:
        out.append('<tr><td class="t">%s</td><td class="n">%d</td><td class="n">%d</td></tr>'
                   % (E(k), lines, items_n))
    out.append('</tbody></table>')
    return ''.join(out)


def ships_table(data):
    out = ['<table class="sum"><colgroup><col style="width:34%"><col style="width:22%">'
           '<col style="width:22%"><col style="width:22%"></colgroup><thead><tr>'
           '<th>Sheet</th><th>On a live screen</th><th>On a retired screen</th>'
           '<th>Unclear</th></tr></thead><tbody>']
    tot = defaultdict(int)
    for kind, (title, _) in SHEETS.items():
        b = defaultdict(int)
        for r in data[kind]:
            b[ships(r.get('version'))] += n(r) or 1
        for k in b:
            tot[k] += b[k]
        out.append('<tr><td class="t">%s</td><td class="n">%d</td><td class="n">%d</td>'
                   '<td class="n">%d</td></tr>'
                   % (E(title), b['live'], b['retired'], b['unsure']))
    out.append('<tr><td class="t">All three</td><td class="n">%d</td><td class="n">%d</td>'
               '<td class="n">%d</td></tr></tbody></table>'
               % (tot['live'], tot['retired'], tot['unsure']))
    return ''.join(out), tot


def md_to_html(md):
    out, lst = [], None
    for line in md.splitlines():
        s = line.rstrip()
        if s.startswith('#'):
            if lst:
                out.append('</%s>' % lst); lst = None
            depth = len(s) - len(s.lstrip('#'))
            if depth <= 1:
                continue                       # the document has its own title
            out.append('<h4>%s</h4>' % E(s.lstrip('#').strip()))
        elif re.match(r'^\s*\d+\.\s', s):
            if lst != 'ol':
                if lst:
                    out.append('</%s>' % lst)
                out.append('<ol>'); lst = 'ol'
            out.append('<li>%s</li>' % inline(re.sub(r'^\s*\d+\.\s*', '', s)))
        elif s.lstrip().startswith(('- ', '* ')):
            if lst != 'ul':
                if lst:
                    out.append('</%s>' % lst)
                out.append('<ul>'); lst = 'ul'
            out.append('<li>%s</li>' % inline(s.lstrip()[2:]))
        elif not s.strip():
            if lst:
                out.append('</%s>' % lst); lst = None
        else:
            if lst:
                out.append('</%s>' % lst); lst = None
            out.append('<p>%s</p>' % inline(s))
    if lst:
        out.append('</%s>' % lst)
    return '\n'.join(out)


def inline(s):
    s = E(s)
    s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
    s = re.sub(r'`(.+?)`', r'<span class="id">\1</span>', s)
    return s


def build():
    data = {k: read(k) for k in SHEETS}
    words = sum(num(r.get('current_words')) or 0 for r in data['written'])
    totals = {k: sum(n(r) or 1 for r in data[k]) for k in SHEETS}
    lines = {k: len(data[k]) for k in SHEETS}
    sh_html, sh = ships_table(data)

    # Films and audio, pulled out because they are the two production lines.
    films = sum(n(r) for r in data['images'] if r.get('kind') in ('video', 'video-thumbnail'))
    audio = sum(n(r) or 1 for r in data['other'] if 'audio' in (r.get('placeholder_type') or ''))
    experts = sum(n(r) or 1 for r in data['other']
                  if 'expert' in (r.get('placeholder_type') or ''))

    body = []

    # ---- cover --------------------------------------------------------------
    body.append(
        '<section class="cover"><div class="kicker">ParentVeda &middot; content order form '
        '&middot; %s</div>'
        '<h1>%s</h1>'
        '<p class="lede">Every picture, film, sound, article and catalogue entry this '
        'stage has a slot for &mdash; counted from the app\'s own source, one '
        'line per slot. Nothing in this document is content. It is the list of what '
        'content has to be made, where it goes, and what shape it takes.</p>'
        '<div class="big">'
        '<div><div class="n">%d</div><div class="l">pictures, films and sounds</div></div>'
        '<div><div class="n">%s</div><div class="l">pieces of writing</div></div>'
        '<div><div class="n">%d</div><div class="l">other things to supply</div></div>'
        '<div><div class="n">%s</div><div class="l">words of writing in place today</div></div>'
        '</div>'
        '<div class="meta">Generated %s from an analysis of <b>%s</b>.<br>'
        'Every number is parsed from the source, not counted by hand.<br>'
        '<b>Ships?</b> tells you whether the screen a line belongs to is one the app opens '
        'today. Read the warning overleaf before commissioning anything.</div></section>'
        % (E(STAGES[STAGE][1]), STAGES[STAGE][2],
           totals['images'], '{:,}'.format(totals['written']), totals['other'],
           '{:,}'.format(words), __import__('datetime').date.today().isoformat(),
           E(STAGES[STAGE][3])))

    # ---- how to read + the retired warning ----------------------------------
    body.append(
        '<section class="break"><div class="sec"><div class="num">01</div>'
        '<h2>Before anyone starts writing or shooting</h2></div>'
        '<div class="warn"><h4>%d of these items sit on screens the app no longer opens</h4>'
        '<p>The parenting stage has been rebuilt in places, and the old screens were kept in '
        'the code so a change could be reversed. They are still in the app; they are simply '
        'not reachable from the current flow. Commissioning content for them is money spent '
        'on a surface nobody sees.</p>'
        '<p><b>So: filter on the "Ships?" column first.</b> Anything marked <span class="chip dead">'
        'old (retired)</span> should be either dropped from the brief or reinstated as a '
        'product decision before a rupee is spent on it. Anything marked <span class="chip un">'
        'unsure</span> means the code did not say and a person has to answer it.</p></div>'
        '%s'
        '<div class="two" style="margin-top:11pt">'
        '<p><b>How the counts work.</b> One line is one slot in the app. The "No." column is how '
        'many pieces that line needs &mdash; a line reading "area cover cards (7 areas)" with 7 in '
        'the column means seven separate images. A line with no number counts as one.</p>'
        '<p><b>"Today" is what a user sees right now.</b> <span class="chip ph">drawn-placeholder</span> '
        'is art drawn in code as a stand-in; <span class="chip ph">none-rendered</span> is a slot that '
        'shows nothing at all; <span class="chip cs">coming-soon</span> is a slot that openly says so '
        'to the user; <span class="chip real">real</span> is finished and needs nothing.</p>'
        '<p><b>What is already real:</b> almost nothing on this side. One image file '
        '(the ParentVeda mark) and one piece of writing. There is no real video or audio file '
        'anywhere in the parenting stage &mdash; a single development MP4 stands in for every '
        'film in the Watch tab.</p>'
        '<p><b>Films must be self-hosted.</b> YouTube was tested to exhaustion and is '
        'systemically blocked for this product, so every film needs hosting we control '
        '(Supabase Storage now, a CDN later). Budget hosting alongside production.</p>'
        '</div></section>' % (sh['retired'], sh_html))

    # ---- the shape of the ask ----------------------------------------------
    body.append(
        '<section class="break"><div class="sec"><div class="num">02</div>'
        '<h2>The shape of the ask</h2>'
        '<p class="sub">What kind of thing is needed, and how much of it. Sorted by volume, '
        'so the top row of each table is where the money goes.</p></div>'
        '<div style="display:flex; gap:14pt; align-items:flex-start">'
        '<div style="flex:1"><h3 style="margin-bottom:5pt">Pictures, film and sound</h3>%s</div>'
        '<div style="flex:1"><h3 style="margin-bottom:5pt">Everything else</h3>%s</div>'
        '</div>'
        '<div style="height:12pt"></div>'
        '<h3 style="margin-bottom:5pt">Writing, by kind of piece</h3>%s'
        '</section>'
        % (group_table(data['images'], 'kind', 'Kind'),
           group_table(data['other'], 'placeholder_type', 'Kind', top=14),
           group_table(data['written'], 'content_type', 'Kind of piece', top=22)))

    # ---- biggest asks + where it concentrates -------------------------------
    body.append(
        '<section class="break"><div class="sec"><div class="num">03</div>'
        '<h2>Where it concentrates</h2>'
        '<p class="sub">The twelve areas carrying the most work, per sheet. The ten "doors" '
        'are the parenting stage\'s spine and they dominate all three.</p></div>'
        '<div style="display:flex; gap:12pt; align-items:flex-start">'
        '<div style="flex:1"><h3 style="margin-bottom:5pt">Pictures and film</h3>%s</div>'
        '<div style="flex:1"><h3 style="margin-bottom:5pt">Writing</h3>%s</div>'
        '<div style="flex:1"><h3 style="margin-bottom:5pt">Everything else</h3>%s</div>'
        '</div></section>'
        % (group_table(data['images'], 'area', 'Area', top=12),
           group_table(data['written'], 'area', 'Area', top=12),
           group_table(data['other'], 'area', 'Area', top=12)))

    # ---- the summary the analysis wrote ------------------------------------
    md_path = os.path.join(SRC, 'pp_summary.md')
    if os.path.exists(md_path):
        body.append(
            '<section class="break"><div class="sec"><div class="num">04</div>'
            '<h2>What the analysis concluded</h2>'
            '<p class="sub">The biggest asks in priority order, and the questions about old '
            'versus new that the code could not answer. Written by the pass that produced the '
            'tables in this document.</p></div><div class="notes two">%s</div>'
            '<div style="height:10pt"></div>'
            '<div class="warn"><h4>Two production lines dominate everything else</h4>'
            '<p><b>%d film and thumbnail slots</b> and <b>%d audio files</b>. Neither exists in any '
            'form today. Most of the film slots are not the Watch tab &mdash; they are explainers '
            'embedded inside the door pages, activity demonstrations and development clips, which '
            'is why the number is so much larger than a look at the app suggests.</p>'
            '<p><b>%d expert profiles</b> are fictional, and some carry invented credentials and '
            'registration numbers. Those have to come out before any build ships, whether or not '
            'real experts replace them in time.</p></div></section>'
            % (md_to_html(open(md_path, encoding='utf-8').read()), films, audio, experts))

    # ---- the detail ---------------------------------------------------------
    legend = ('<div class="legend"><span><b>Ships?</b> %s %s %s</span>'
              '<span><b>Today</b> %s %s %s</span></div>'
              % (chip_ships('new'), chip_ships('old (retired)'), chip_ships('unsure'),
                 chip_state('real-asset'), chip_state('drawn-placeholder'),
                 chip_state('coming-soon')))

    sec = 4 if os.path.exists(md_path) else 3
    for kind, (title, lede) in SHEETS.items():
        sec += 1
        rows = data[kind]
        areas = OrderedDict()
        for r in rows:
            areas.setdefault(r.get('area') or 'General', []).append(r)
        body.append('<section class="break"><div class="sec"><div class="num">%02d</div>'
                    '<h2>%s</h2><p class="sub">%s</p><p class="sub" style="margin-top:4pt">'
                    '<b>%d lines, %d items, %d areas.</b></p></div>%s'
                    % (sec, E(title), E(lede), lines[kind], totals[kind], len(areas), legend))
        for area, arows in areas.items():
            body.append('<div class="area keep"><h4>%s</h4><span class="cnt">%d lines &middot; '
                        '%d items</span></div>%s'
                        % (E(area), len(arows), sum(n(r) or 1 for r in arows),
                           table(kind, arows)))
        body.append('</section>')

    css = open(os.path.join(HERE, 'door_map.css'), encoding='utf-8').read()
    out = os.path.join(DOCS, OUT_NAME + '.html')
    with open(out, 'w', encoding='utf-8') as f:
        f.write('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
                '<title>ParentVeda &mdash; parenting content brief</title>\n'
                '<style>\n%s\n</style>\n<style>\n%s\n</style>\n<style>\n%s\n</style>\n'
                '</head>\n<body>\n%s\n</body>\n</html>\n'
                % (fonts_css(), css, STYLE, '\n'.join(body)))
    return out, totals, lines, words, sh


if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    want = list(STAGES) if '--all' in sys.argv else (args or ['pp'])
    for stage in want:
        if stage not in STAGES:
            print('unknown stage %r; pick from %s' % (stage, ', '.join(STAGES)))
            continue
        STAGE = stage
        OUT_NAME = STAGES[stage][0]
        globals()['STAGE'] = stage
        globals()['OUT_NAME'] = OUT_NAME
        if not os.path.exists(os.path.join(SRC, '%s_written.csv' % stage)):
            print('%-10s no CSVs yet — run tools/inventory/emit_*.py first' % stage)
            continue
        path, totals, lines, words, sh = build()
        print('%-30s %4d img / %4d wri / %4d oth lines | %s words in place | '
              'live %d retired %d unsure %d'
              % (os.path.basename(path), lines['images'], lines['written'],
                 lines['other'], '{:,}'.format(words), sh['live'], sh['retired'],
                 sh['unsure']))
        if '--pdf' in sys.argv:
            pdf = to_pdf(path)
            if pdf:
                print('   -> %s (%.0f KB)' % (os.path.basename(pdf),
                                              os.path.getsize(pdf) / 1024))
