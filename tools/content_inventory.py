# =============================================================================
#  content_inventory.py -- the "what do we need to make" sheets
# -----------------------------------------------------------------------------
#  Turns the per-stage inventory CSVs (written by an analysis pass over the
#  app, one set per stage) into three printable PDFs:
#
#     docs/CONTENT-NEEDS-1-IMAGES-VIDEO.pdf     every image, video and audio slot
#     docs/CONTENT-NEEDS-2-WRITTEN.pdf          every piece of written content
#     docs/CONTENT-NEEDS-3-OTHER.pdf            everything else that is a placeholder
#
#  The CSVs are the source of truth; this file only lays them out. Re-run after
#  the CSVs change:
#
#     python tools/content_inventory.py <folder-with-csvs> --pdf
#
#  Same look as the door maps (door_map.css), same Chrome print step, same
#  cached fonts. Landscape, because the tables are wide.
# =============================================================================

import base64
import csv
import glob
import html
import os
import re
import subprocess
import sys
import urllib.request
from collections import OrderedDict, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
# ⚠️ THE BRIEFS LIVE IN THEIR OWN FOLDER. Nine PDFs loose in docs/ buried the
# door maps and the specs; they are one deliverable and they sit together.
DOCS = os.path.join(ROOT, 'docs', 'content-brief')
os.makedirs(DOCS, exist_ok=True)
E = html.escape

CHROME_CANDIDATES = [
    r'C:\Program Files\Google\Chrome\Application\chrome.exe',
    r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    '/usr/bin/google-chrome', '/usr/bin/chromium',
]
CACHE = os.path.join(os.environ.get('TEMP', '/tmp'), 'parentveda-doormap-fonts')
FONT_SPEC = ("https://fonts.googleapis.com/css2?"
             "family=Fraunces:opsz,wght@9..144,600&"
             "family=Manrope:wght@400;500;700;800&"
             "family=IBM+Plex+Mono:wght@500;600&display=swap")


def fonts_css():
    os.makedirs(CACHE, exist_ok=True)
    cached = os.path.join(CACHE, 'fonts.css')
    if os.path.exists(cached):
        return open(cached, encoding='utf-8').read()
    try:
        req = urllib.request.Request(FONT_SPEC, headers={'User-Agent': 'Mozilla/5.0'})
        css = urllib.request.urlopen(req, timeout=30).read().decode()
        out = []
        for m in re.finditer(r'@font-face \{(.*?)\}', css, re.S):
            blk = m.group(1)
            fam = re.search(r"font-family: '([^']+)'", blk).group(1)
            w = re.search(r'font-weight: (\d+)', blk).group(1)
            url = re.search(r'url\(([^)]+)\)', blk).group(1)
            data = urllib.request.urlopen(url, timeout=30).read()
            out.append("@font-face{font-family:'%s';font-style:normal;font-weight:%s;"
                       "src:url(data:font/ttf;base64,%s) format('truetype')}"
                       % (fam, w, base64.b64encode(data).decode()))
        css = '\n'.join(out)
        open(cached, 'w', encoding='utf-8').write(css)
        return css
    except Exception:
        return ''


def to_pdf(html_path):
    chrome = next((c for c in CHROME_CANDIDATES if os.path.exists(c)), None)
    if not chrome:
        print('  (no Chrome found; HTML only)')
        return None
    pdf = html_path[:-5] + '.pdf'
    subprocess.run([chrome, '--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                    '--virtual-time-budget=20000', '--print-to-pdf=' + pdf,
                    'file:///' + html_path.replace('\\', '/')],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=600)
    return pdf if os.path.exists(pdf) else None


# -----------------------------------------------------------------------------
#  Reading the CSVs
# -----------------------------------------------------------------------------

STAGE_ORDER = ['ttc', 'preg', 'father', 'pp', 'skilling', 'shared']
STAGE_NAME = {
    'ttc': 'Trying to conceive',
    'preg': 'Pregnancy (her side)',
    'father': 'Father mode',
    'pp': 'Parenting (0 to 5)',
    'skilling': 'Skilling (preview only)',
    'shared': 'Shared, commerce and platform',
}
KINDS = OrderedDict([
    ('images', ('CONTENT-NEEDS-1-IMAGES-VIDEO', 'Images, video and audio',
                'Every picture, film and sound the app has a slot for -- what it is for, '
                'where it shows, how big, and whether a real one exists yet.')),
    ('written', ('CONTENT-NEEDS-2-WRITTEN', 'Written content',
                 'Every piece of writing the app renders -- its type, title, purpose, '
                 'who it is for, and how long the placeholder is today.')),
    ('other', ('CONTENT-NEEDS-3-OTHER', 'Other placeholders',
               'Everything that is neither a picture nor a piece of prose and still '
               'has to come from us -- audio, activities, experts, offerings, products, '
               'rooms, templates, data sources.')),
])


def num(s):
    s = (s or '').strip()
    m = re.match(r'^\s*(\d[\d,]*)', s)
    return int(m.group(1).replace(',', '')) if m else None


def read_all(folder):
    data = {k: [] for k in KINDS}
    summaries = OrderedDict()
    for stage in STAGE_ORDER:
        for kind in KINDS:
            path = os.path.join(folder, '%s_%s.csv' % (stage, kind))
            if not os.path.exists(path):
                continue
            with open(path, encoding='utf-8-sig', newline='') as f:
                for row in csv.DictReader(f):
                    row = {(k or '').strip(): (v or '').strip() for k, v in row.items()}
                    row['_stage'] = stage
                    data[kind].append(row)
        sp = os.path.join(folder, '%s_summary.md' % stage)
        if os.path.exists(sp):
            summaries[stage] = open(sp, encoding='utf-8').read()
    return data, summaries


# -----------------------------------------------------------------------------
#  Layout
# -----------------------------------------------------------------------------

STYLE = """
@page { size: A4 landscape; margin: 12mm 11mm 13mm; }
body{font-size:8pt}
.cover{height:165mm}
table{border-collapse:collapse; width:100%; table-layout:fixed}
th{font-family:Manrope; font-size:6.4pt; font-weight:800; letter-spacing:.8pt; text-transform:uppercase;
   color:var(--mute); text-align:left; padding:3pt 4pt; border-bottom:1.5px solid var(--line); vertical-align:bottom}
td{font-size:7.3pt; line-height:1.35; padding:3pt 4pt; border-bottom:1px solid var(--hair); vertical-align:top; word-wrap:break-word}
tr{page-break-inside:avoid; break-inside:avoid}
td.n{font-family:"IBM Plex Mono"; text-align:right; white-space:nowrap; color:var(--ink)}
td.t{color:var(--ink); font-weight:700}
td.m{color:var(--mute)}
.sum td{font-size:8pt}
.sum td.n{font-size:8.6pt}
.area{margin:9pt 0 3pt; display:flex; align-items:baseline; gap:8pt}
.area h4{font-size:9.2pt}
.area .cnt{font-family:"IBM Plex Mono"; font-size:7pt; color:var(--pv)}
.legend{display:flex; gap:14pt; flex-wrap:wrap; font-size:7.6pt; color:var(--mute); margin:6pt 0 10pt}
.legend b{color:var(--ink)}
.chip.v3{background:var(--safe-soft); color:var(--safe)}
.chip.old{background:var(--myth-soft); color:var(--myth)}
.chip.un{background:#f2f0f4; color:var(--mute)}
.chip.real{background:var(--safe-soft); color:var(--safe)}
.chip.ph{background:var(--doc-soft); color:var(--doc)}
.chip.cs{background:var(--tool-soft); color:var(--tool)}
.notes{columns:2; column-gap:14pt; font-size:8pt; line-height:1.5}
.notes h4{margin-top:6pt}
.notes p{margin:0 0 5pt; break-inside:avoid}
.notes ul{margin:0 0 5pt 12pt; padding:0}
.notes li{margin:0 0 2pt}
"""


def chip_version(v):
    v = (v or '').lower()
    if v.startswith('v3') or v.startswith('new'):
        return '<span class="chip v3">%s</span>' % E(v)
    if v.startswith('old'):
        return '<span class="chip old">%s</span>' % E(v)
    if 'unsure' in v:
        return '<span class="chip un">unsure</span>'
    return '<span class="chip n">%s</span>' % E(v or '--')


def chip_state(v):
    v = (v or '').lower()
    if 'real' in v:
        return '<span class="chip real">%s</span>' % E(v)
    if 'coming' in v or 'derived' in v:
        return '<span class="chip cs">%s</span>' % E(v)
    if 'none' in v or 'blank' in v or 'placeholder' in v or 'unsplash' in v or 'drawn' in v:
        return '<span class="chip ph">%s</span>' % E(v)
    return '<span class="chip n">%s</span>' % E(v or '--')


COLUMNS = {
    'images': [
        ('tap_path', 'Where', '17%'), ('item', 'What the image is for', '19%'),
        ('kind', 'Kind', '7%'), ('count', 'No.', '4%'), ('size_or_aspect', 'Size / shape', '11%'),
        ('placeholder_now', 'Today', '9%'), ('version', 'Ver.', '6%'), ('notes', 'Notes', '27%'),
    ],
    'written': [
        ('tap_path', 'Where', '14%'), ('content_type', 'Type', '9%'),
        ('title_or_id', 'Title / id', '16%'), ('purpose', 'Purpose', '18%'),
        ('audience', 'For whom', '9%'), ('current_words', 'Words now', '5%'),
        ('count', 'No.', '4%'), ('status', 'Status', '7%'), ('version', 'Ver.', '5%'),
        ('notes', 'Notes', '13%'),
    ],
    'other': [
        ('tap_path', 'Where', '15%'), ('placeholder_type', 'Type', '10%'),
        ('item', 'Item', '17%'), ('count', 'No.', '4%'),
        ('what_is_needed_from_us', 'What we have to provide', '25%'),
        ('current_state', 'Today', '11%'), ('version', 'Ver.', '6%'),
        ('source_file', 'In code', '12%'),
    ],
}


def cell(kind, col, row):
    v = row.get(col, '')
    if col == 'audience':
        v = row.get('audience_stage') or row.get('audience_age') or ''
    if col == 'count' or col == 'current_words':
        return '<td class="n">%s</td>' % E(v or '--')
    if col == 'version':
        return '<td>%s</td>' % chip_version(v)
    if col in ('placeholder_now', 'status', 'current_state'):
        return '<td>%s</td>' % chip_state(v)
    if col in ('item', 'title_or_id'):
        return '<td class="t">%s</td>' % E(v)
    if col == 'source_file':
        return '<td class="m" style="font-family:\'IBM Plex Mono\';font-size:6.4pt">%s</td>' % E(v)
    if col in ('notes',):
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


def summary_table(kind, data):
    """Stage x (rows, total count, real / placeholder split)."""
    by = defaultdict(lambda: {'rows': 0, 'count': 0, 'real': 0, 'ph': 0, 'cs': 0})
    for r in data:
        b = by[r['_stage']]
        b['rows'] += 1
        n = num(r.get('count')) or 1
        b['count'] += n
        st = (r.get('placeholder_now') or r.get('status') or r.get('current_state') or '').lower()
        if 'real' in st:
            b['real'] += n
        elif 'coming' in st or 'derived' in st:
            b['cs'] += n
        else:
            b['ph'] += n
    out = ['<table class="sum"><colgroup><col style="width:34%"><col style="width:12%"><col style="width:14%">'
           '<col style="width:13%"><col style="width:13%"><col style="width:14%"></colgroup>'
           '<thead><tr><th>Stage</th><th>Lines</th><th>Items needed</th><th>Already real</th>'
           '<th>Coming soon / derived</th><th>Still placeholder</th></tr></thead><tbody>']
    T = {'rows': 0, 'count': 0, 'real': 0, 'ph': 0, 'cs': 0}
    for s in STAGE_ORDER:
        if s not in by:
            continue
        b = by[s]
        for k in T:
            T[k] += b[k]
        out.append('<tr><td class="t">%s</td><td class="n">%d</td><td class="n">%d</td>'
                   '<td class="n">%d</td><td class="n">%d</td><td class="n">%d</td></tr>'
                   % (E(STAGE_NAME[s]), b['rows'], b['count'], b['real'], b['cs'], b['ph']))
    out.append('<tr><td class="t">All stages</td><td class="n">%d</td><td class="n">%d</td>'
               '<td class="n">%d</td><td class="n">%d</td><td class="n">%d</td></tr>'
               % (T['rows'], T['count'], T['real'], T['cs'], T['ph']))
    out.append('</tbody></table>')
    return ''.join(out), T


def by_type_table(kind, data, col):
    by = defaultdict(lambda: [0, 0])
    for r in data:
        by[(r.get(col) or 'unspecified').lower()][0] += 1
        by[(r.get(col) or 'unspecified').lower()][1] += num(r.get('count')) or 1
    rows = sorted(by.items(), key=lambda kv: -kv[1][1])
    out = ['<table class="sum"><colgroup><col style="width:60%%"><col style="width:20%%"><col style="width:20%%"></colgroup>'
           '<thead><tr><th>%s</th><th>Lines</th><th>Items</th></tr></thead><tbody>' % E(col.replace('_', ' '))]
    for k, (lines, items) in rows:
        out.append('<tr><td class="t">%s</td><td class="n">%d</td><td class="n">%d</td></tr>' % (E(k), lines, items))
    out.append('</tbody></table>')
    return ''.join(out)


def md_to_html(md):
    out, in_list = [], False
    for line in md.splitlines():
        s = line.rstrip()
        if s.startswith('#'):
            if in_list:
                out.append('</ul>'); in_list = False
            out.append('<h4>%s</h4>' % E(s.lstrip('#').strip()))
        elif s.lstrip().startswith(('- ', '* ')):
            if not in_list:
                out.append('<ul>'); in_list = True
            out.append('<li>%s</li>' % inline(s.lstrip()[2:]))
        elif s.strip() == '':
            if in_list:
                out.append('</ul>'); in_list = False
        else:
            if in_list:
                out.append('</ul>'); in_list = False
            out.append('<p>%s</p>' % inline(s))
    if in_list:
        out.append('</ul>')
    return '\n'.join(out)


def inline(s):
    s = E(s)
    s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
    s = re.sub(r'`(.+?)`', r'<span class="id">\1</span>', s)
    return s


def build(kind, data, summaries, out_dir):
    fname, title, lede = KINDS[kind]
    rows = data[kind]
    sum_html, T = summary_table(kind, rows)
    type_col = {'images': 'kind', 'written': 'content_type', 'other': 'placeholder_type'}[kind]

    body = []
    body.append('<section class="cover"><div class="kicker">ParentVeda &middot; content needs &middot; sheet %s of 3</div>'
                '<h1>%s</h1><p class="lede">%s</p>'
                '<div class="coverstat"><div><div class="n">%d</div><div class="l">items needed</div></div>'
                '<div><div class="n">%d</div><div class="l">already real</div></div>'
                '<div><div class="n">%d</div><div class="l">still placeholder</div></div>'
                '<div><div class="n">%d</div><div class="l">lines in this sheet</div></div></div>'
                '<div class="meta">Generated from an analysis of the app source, %s.<br>'
                'Nothing here is content. It is the list of what content has to be made, where it goes, and what shape it takes.<br>'
                '<b>Ver.</b> says which generation of the app a line belongs to: <b>v3 / new</b> is the current flow, '
                '<b>old</b> is a surface the current flow no longer opens (kept for revert), <b>shared</b> is reached from both, '
                '<b>unsure</b> means the analysis could not tell and it is flagged rather than guessed.</div></section>'
                % (kind and list(KINDS).index(kind) + 1, E(title), E(lede), T['count'], T['real'], T['ph'], T['rows'],
                   E(__import__('datetime').date.today().isoformat())))

    body.append('<section class="break"><div class="sec"><div class="num">00</div><h2>Totals</h2>'
                '<p class="sub">Counted by "No." on each line. A line with no number counts as one. '
                '"Already real" means a real asset or real writing is in the app today and does not need commissioning; '
                '"Coming soon / derived" is a slot the app shows as coming soon, or content derived from another stage\'s content at build time.</p></div>'
                + sum_html + '<div style="height:10pt"></div>'
                + '<div class="sec"><h3>By %s</h3></div>' % E(type_col.replace('_', ' '))
                + by_type_table(kind, rows, type_col) + '</section>')

    legend = ('<div class="legend"><span><b>Ver.</b> %s %s %s %s</span>'
              '<span><b>Today</b> %s %s %s</span></div>'
              % (chip_version('v3'), chip_version('old'), chip_version('shared'), chip_version('unsure'),
                 chip_state('real-asset'), chip_state('placeholder'), chip_state('coming-soon')))

    n = 0
    for stage in STAGE_ORDER:
        srows = [r for r in rows if r['_stage'] == stage]
        if not srows:
            continue
        n += 1
        areas = OrderedDict()
        for r in srows:
            areas.setdefault(r.get('area') or 'General', []).append(r)
        stage_total = sum((num(r.get('count')) or 1) for r in srows)
        body.append('<section class="break"><div class="sec"><div class="num">%02d</div><h2>%s</h2>'
                    '<p class="sub">%d lines, %d items, across %d areas.</p></div>%s'
                    % (n, E(STAGE_NAME[stage]), len(srows), stage_total, len(areas), legend))
        for area, arows in areas.items():
            body.append('<div class="area keep"><h4>%s</h4><span class="cnt">%d lines &middot; %d items</span></div>%s'
                        % (E(area), len(arows), sum((num(r.get('count')) or 1) for r in arows), table(kind, arows)))
        body.append('</section>')

    if summaries:
        body.append('<section class="break"><div class="sec"><div class="num">%02d</div><h2>Notes from the analysis</h2>'
                    '<p class="sub">What each stage\'s pass found hardest to count, and where old and new could not be told apart. '
                    'Read these before treating any number above as final.</p></div><div class="notes">' % (n + 1))
        for stage, md in summaries.items():
            body.append('<h4 style="font-size:10pt;color:var(--pv)">%s</h4>%s' % (E(STAGE_NAME[stage]), md_to_html(md)))
        body.append('</div></section>')

    css = open(os.path.join(HERE, 'door_map.css'), encoding='utf-8').read()
    out = os.path.join(out_dir, fname + '.html')
    with open(out, 'w', encoding='utf-8') as f:
        f.write('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
                '<title>ParentVeda &mdash; content needs &mdash; %s</title>\n<style>\n%s\n</style>\n'
                '<style>\n%s\n</style>\n<style>\n%s\n</style>\n</head>\n<body>\n%s\n</body>\n</html>\n'
                % (E(title), fonts_css(), css, STYLE, '\n'.join(body)))
    return out, T


if __name__ == '__main__':
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    folder = args[0] if args else os.path.join(ROOT, 'research', 'content-inventory')
    want_pdf = '--pdf' in sys.argv
    data, summaries = read_all(folder)
    for kind in KINDS:
        path, T = build(kind, data, summaries, DOCS)
        line = '%-34s %5d lines %6d items %6.0f KB' % (os.path.basename(path), T['rows'], T['count'],
                                                      os.path.getsize(path) / 1024)
        if want_pdf:
            pdf = to_pdf(path)
            if pdf:
                line += '  ->  %s (%.0f KB)' % (os.path.basename(pdf), os.path.getsize(pdf) / 1024)
        print(line)
