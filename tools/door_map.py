#!/usr/bin/env python3
# =============================================================================
#  door_map.py -- render one parenting door as a printable map
# -----------------------------------------------------------------------------
#  Companion to section_doc.py, which does the parsing. This file does the
#  document: the tree, the band matrix, every page in full, the tools, and the
#  routing analysis.
#
#  ⚠️ WHAT IS COMPUTED VS WHAT IS WRITTEN BY HAND, AND WHY THE LINE IS THERE.
#
#  Everything that can be derived from the code IS derived: page counts per
#  band, which chip reads which page, every in-page link and where it lands,
#  consult roles resolved through the category map, duplicate destinations,
#  links that resolve to nothing, video and audio slots. Deriving them means
#  the document cannot claim a route the app does not have -- which is the only
#  thing that makes a document a substitute for opening the app.
#
#  What stays hand-written is the JUDGEMENT: why a gap is a gap, which
#  duplicate is deliberate, what a reader should do about it. Those live in
#  NOTES below, keyed by bracket, and they are the part a person is actually
#  needed for.
#
#  ⚠️ FONTS ARE CACHED, NOT COMMITTED. The finished PDFs must embed Fraunces,
#  Manrope and IBM Plex Mono or Chrome silently falls back to Times New Roman.
#  Base64-inlining them costs ~1.3 MB per HTML file, which does not belong in
#  git eleven times over, so they are downloaded once into a cache directory
#  and inlined at build time. Delete the cache and the next build refetches.
#
#  Usage:
#     python tools/door_map.py parenting_development ...   # HTML only
#     python tools/door_map.py --all --pdf
# =============================================================================

import base64
import html
import os
import re
import subprocess
import sys
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import section_doc as SD                                    # noqa: E402

ROOT = SD.ROOT
DOCS = SD.DOCS
CACHE = os.path.join(os.environ.get('TEMP', '/tmp'), 'parentveda-doormap-fonts')

CHROME_CANDIDATES = [
    r'C:\Program Files\Google\Chrome\Application\chrome.exe',
    r'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
    '/usr/bin/google-chrome', '/usr/bin/chromium',
]

E = html.escape


# =============================================================================
#  HUBS, BRACKETS AND THE ROUTER
# =============================================================================

def _text(v):
    """Unwrap the localisation helpers so a config reads as plain English.

    `_en('x')`, `_t(en:, hi:)`, `_same('x')` and `LocalizedText(en:, hi:)` all
    mean "this string" for our purposes. The `.en` side is taken deliberately:
    parenting is English-only content today, and `.en` is the identity side
    everywhere in this codebase.
    """
    if isinstance(v, str) or v is None:
        return v
    if isinstance(v, SD.Call):
        if v.args:
            return _text(v.args[0])
        for k in ('en', 'hi'):
            if k in v.kwargs:
                return _text(v.kwargs[k])
    return None


def hubs():
    env = SD.declarations(os.path.join(ROOT, 'lib', 'data', 'hubs', 'parenting_hubs.dart'))
    out = {}
    for name, v in env.items():
        v = SD.resolve(v, env)
        if not (isinstance(v, SD.Call) and v.name == 'HubConfig'):
            continue
        k = v.kwargs
        cl = k.get('closing')
        ur = k.get('urgent')
        out[k['bracketId']] = {
            'var': name,
            'template': SD.enum_name(k['template']),
            'coreQuestion': _text(k['coreQuestion']),
            'hero': _text(k['hero']),
            'heroSupport': _text(k['heroSupport']),
            'heroVideoSlot': k.get('heroVideoSlot'),
            'needsTitle': _text(k['needsTitle']),
            'needs': [{'label': _text(n.kwargs['label']),
                       'blurb': _text(n.kwargs['blurb']),
                       'mark': SD.enum_name(n.kwargs['mark']),
                       'hue': n.kwargs['hue'],
                       'surfaceId': n.kwargs.get('surfaceId'),
                       'action': n.kwargs.get('action')} for n in k['needs']],
            'urgent': None if ur is None else {'line': _text(ur.kwargs['line']),
                                               'action': ur.kwargs['action']},
            'closing': None if cl is None else {
                'label': _text(cl.kwargs['label']), 'blurb': _text(cl.kwargs['blurb']),
                'action': cl.kwargs['action'], 'surfaceId': cl.kwargs.get('surfaceId')},
        }
    return out


def brackets():
    path = os.path.join(ROOT, 'lib', 'data', 'brackets', 'parenting_brackets.dart')
    env = SD.declarations(path)
    out = {}
    for name, v in env.items():
        v = SD.resolve(v, env)
        if not isinstance(v, list):
            continue
        for b in v:
            if not (isinstance(b, SD.Call) and b.name == 'Bracket'):
                continue
            k = b.kwargs
            layers = {}
            for lk, lv in (k.get('layers') or {}).items():
                key = SD.enum_name(lk)
                if isinstance(lv, SD.Call) and lv.name.endswith('.live'):
                    layers[key] = ('live', lv.args[0])
                elif isinstance(lv, SD.Call):
                    st = SD.enum_name(lv.kwargs.get('state'))
                    layers[key] = (st, lv.kwargs.get('reason'))
            out[k['id']] = {'label': _text(k['label']), 'title': _text(k['title']),
                            'blurb': _text(k['blurb']), 'hue': k.get('hue'),
                            'theme': k.get('theme'), 'layers': layers}
    return out


def router_ids():
    """Surface ids `pp_surface_router.dart` can resolve.

    Read out of the switch by pattern rather than by parsing statements: this
    is code, not data, and the only thing the document needs from it is the
    set of ids that resolve. An id absent from this set is a link that renders
    as a live row and does nothing -- the failure the wiring gate exists for.
    """
    src = open(os.path.join(SD.PP, 'pp_surface_router.dart'), encoding='utf-8').read()
    ids = set(re.findall(r"'([a-z0-9_/ ]+)'\s*=>", src))
    ids |= set(re.findall(r"case '([a-z0-9_]+)'", src))
    return ids


# ⚠️ THE ACTION MAP IS TRANSCRIBED, NOT PARSED, AND THAT IS A DELIBERATE LIMIT.
#
# `pp_home_v3.dart` resolves a door's `action` in Dart code -- a const map,
# then an area override, then a journey lookup, then a switch. Parsing control
# flow is far past what section_doc.py is for, and a half-parsed switch that
# silently missed an arm would put a wrong destination in the document.
#
# So it is copied here with its ORDER preserved (area override wins over
# section, section wins over the switch), and `verify_actions()` below fails
# loudly if the Dart map and this one drift apart.
ACTION_TO_SECTION = {
    'pp_sleep_problem': 'parenting_sleep',
    'pp_behaviour': 'parenting_behaviour',
    'pp_tradition': 'parenting_traditional',
    'pp_feeding_problem': 'parenting_feeding',
    'pp_school_readiness': 'parenting_early_learning',
    'pp_potty_readiness': 'parenting_potty',
    'pp_potty_training': 'parenting_potty',
    'pp_first_40_days': 'parenting_first_40',
    'pp_maternal_recovery': 'parenting_maternal',
    'pp_maternal_concern': 'parenting_maternal',
}
ACTION_TO_AREA = {
    'pp_potty_readiness': 'parenting_potty/getting_ready',
    'pp_potty_training': 'parenting_potty/how_to_do_it',
}


def verify_actions():
    src = SD.strip_comments(open(os.path.join(SD.PP, 'pp_home_v3.dart'), encoding='utf-8').read())
    consts = dict(re.findall(r"const String (kPpAct\w+) = '([a-z0-9_]+)';",
                             SD.strip_comments(open(os.path.join(
                                 ROOT, 'lib', 'data', 'hubs', 'parenting_hubs.dart'),
                                 encoding='utf-8').read())))
    body = src[src.index('sectionForAction'):]
    body = body[:body.index('};')]
    found = {consts[m[0]]: m[1] for m in re.findall(r"(kPpAct\w+): '([a-z0-9_]+)'", body)
             if m[0] in consts}
    if found != ACTION_TO_SECTION:
        raise SystemExit('ACTION_TO_SECTION has drifted from pp_home_v3.dart:\n'
                         '  dart: %s\n  here: %s' % (found, ACTION_TO_SECTION))


def action_target(action):
    if action in ACTION_TO_AREA:
        return 'pp_section/' + ACTION_TO_AREA[action]
    if action in ACTION_TO_SECTION:
        return 'pp_section/' + ACTION_TO_SECTION[action]
    return None


# =============================================================================
#  DERIVED FACTS
# =============================================================================

def in_band(tagged, band):
    return not tagged or band in tagged


def pages_for(area, band):
    return [p for p in area['pages'] if in_band(p['bands'], band)]


def band_matrix(sec):
    """Rows of (area, {band_id: page_count}) plus per-band totals."""
    rows, totals = [], {}
    for a in sec['areas']:
        counts = {}
        for b in sec['bands']:
            counts[b['id']] = len(pages_for(a, b['id'])) if in_band(a['bands'], b['id']) else None
        rows.append((a, counts))
    for b in sec['bands']:
        totals[b['id']] = sum(c[b['id']] or 0 for _, c in rows)
    return rows, totals


def band_changes_nothing(sec):
    """The screen's own `_bandChangesNothing` -- compares the RESULT, not tags."""
    if len(sec['bands']) < 2:
        return False
    def sig(b):
        return '|'.join('%s:%d' % (a['id'], len(pages_for(a, b)))
                        for a in sec['areas'] if in_band(a['bands'], b))
    first = sig(sec['bands'][0]['id'])
    return all(sig(b['id']) == first for b in sec['bands'])


def walk_blocks(sec):
    for ai, a in enumerate(sec['areas'], 1):
        for pi, p in enumerate(a['pages'], 1):
            for b in p['blocks']:
                yield a, p, 'P%d.%d' % (ai, pi), b


def collect(sec):
    out = {'links': [], 'consults': [], 'videos': [], 'audios': [],
           'dead': [], 'pageids': [], 'callouts': {}}
    for a, p, ref, b in walk_blocks(sec):
        t = b['t']
        if t == 'link':
            tgt = b['surfaceId'] or (('page: ' + b['pageId']) if b['pageId'] else None)
            out['links'].append({'ref': ref, 'page': p['title'], 'label': b['label'],
                                 'blurb': b['blurb'], 'surfaceId': b['surfaceId'],
                                 'pageId': b['pageId']})
            if tgt is None:
                out['dead'].append({'ref': ref, 'label': b['label'], 'why': 'no destination'})
            if b['pageId']:
                out['pageids'].append({'ref': ref, 'label': b['label'], 'pageId': b['pageId']})
        elif t == 'consult':
            out['consults'].append({'ref': ref, 'page': p['title'], 'title': b['title'],
                                    'whoFor': b['whoFor'], 'role': b['role'],
                                    'surface': SD.consult_surface(b)})
        elif t == 'video':
            out['videos'].append({'ref': ref, 'page': p['title'], **b})
        elif t == 'audio':
            out['audios'].append({'ref': ref, 'page': p['title'], **b})
        elif t == 'callout':
            out['callouts'][b['kind']] = out['callouts'].get(b['kind'], 0) + 1
    return out


def inbound(bracket_id, sec):
    """Links from OTHER sections that land in this one."""
    want = {'pp_section/' + bracket_id}
    hits = []
    for other in SD.SECTION_FILES:
        if other == bracket_id:
            continue
        try:
            os_ = SD.load_section(other)
        except Exception:
            continue
        for a, p, ref, b in walk_blocks(os_):
            if b['t'] == 'link' and b['surfaceId'] in want:
                hits.append({'from': os_['title'], 'page': p['title'],
                             'label': b['label'], 'blurb': b['blurb']})
    return hits


# =============================================================================
#  HTML
# =============================================================================

FONT_SPEC = ("https://fonts.googleapis.com/css2?"
             "family=Fraunces:opsz,wght@9..144,600&"
             "family=Manrope:wght@400;500;600;700;800&"
             "family=IBM+Plex+Mono:wght@400;500;600&display=swap")


def fonts_css():
    os.makedirs(CACHE, exist_ok=True)
    cached = os.path.join(CACHE, 'fonts.css')
    if os.path.exists(cached):
        return open(cached, encoding='utf-8').read()
    ua = {'User-Agent': 'Mozilla/4.0'}          # a legacy UA gets TTF, not WOFF2
    css = urllib.request.urlopen(urllib.request.Request(FONT_SPEC, headers=ua)).read().decode()
    out = []
    for m in re.finditer(r'@font-face \{(.*?)\}', css, re.S):
        blk = m.group(1)
        fam = re.search(r"font-family: '([^']+)'", blk).group(1)
        w = re.search(r'font-weight: (\d+)', blk).group(1)
        u = re.search(r'url\((https://[^)]+)\)', blk).group(1)
        data = urllib.request.urlopen(urllib.request.Request(u, headers=ua)).read()
        out.append("@font-face{font-family:'%s';font-style:normal;font-weight:%s;"
                   "src:url(data:font/ttf;base64,%s) format('truetype')}"
                   % (fam, w, base64.b64encode(data).decode()))
    css = '\n'.join(out)
    open(cached, 'w', encoding='utf-8').write(css)
    return css


STYLE = open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                          'door_map.css'), encoding='utf-8').read()


def chip(text, cls=''):
    return '<span class="chip %s">%s</span>' % (cls, E(text))


def idspan(text):
    return '<span class="id">%s</span>' % E(text)


# ---- block rendering --------------------------------------------------------

CALLOUT_CLASS = {'key': '', 'doctor': 'doc', 'myth': 'myth', 'safety': 'safe'}
CALLOUT_LABEL = {'key': 'Callout', 'doctor': 'Doctor callout',
                 'myth': 'Myth', 'safety': 'Safety rule'}


def render_block(b):
    t = b['t']
    if t == 'intro':
        return '<p class="intro">%s</p>' % E(b['text'])
    if t == 'article':
        h = ('<div class="blkh">Article%s</div>'
             % (' &mdash; ' + E(b['heading']) if b['heading'] else ''))
        return ('<div class="blk">%s%s</div>'
                % (h, ''.join('<p class="para">%s</p>' % E(p) for p in b['paras'])))
    if t == 'steps':
        h = ('<div class="blkh">Step-list%s</div>'
             % (' &mdash; ' + E(b['heading']) if b['heading'] else ''))
        li = ''.join('<li><b>%s</b>%s</li>'
                     % (E(s['title']),
                        '<span>%s</span>' % E(s['detail']) if s['detail'] else '')
                     for s in b['steps'])
        return '<div class="blk">%s<ol class="steps">%s</ol></div>' % (h, li)
    if t == 'cards':
        h = ('<div class="blkh">Cards%s</div>'
             % (' &mdash; ' + E(b['heading']) if b['heading'] else ''))
        li = ''.join('<li><b>%s</b><span>%s</span></li>' % (E(c['title']), E(c['line']))
                     for c in b['cards'])
        return '<div class="blk">%s<ul class="cards">%s</ul></div>' % (h, li)
    if t == 'table':
        h = ('<div class="blkh">Comparison table%s</div>'
             % (' &mdash; ' + E(b['heading']) if b['heading'] else ''))
        head = ''.join('<th>%s</th>' % E(c) for c in b['columns'])
        rows = ''.join('<tr>%s</tr>' % ''.join('<td>%s</td>' % E(str(c)) for c in r)
                       for r in b['rows'])
        return ('<div class="blk">%s<table><tr>%s</tr>%s</table></div>' % (h, head, rows))
    if t == 'chart':
        sub = (' &middot; ' + E(b['subtitle'])) if b['subtitle'] else ''
        h = '<div class="blkh">Chart card &mdash; %s%s</div>' % (E(b['title']), sub)
        rows = ''.join('<tr><td style="width:54mm">%s</td><td><b>%s</b></td></tr>'
                       % (E(str(r[0])), E(str(r[1]))) for r in b['rows'])
        note = ('<p class="tbl-note">%s</p>' % E(b['note'])) if b['note'] else ''
        return '<div class="blk">%s<table>%s</table>%s</div>' % (h, rows, note)
    if t == 'callout':
        cls = CALLOUT_CLASS.get(b['kind'], '')
        label = b['title'] or CALLOUT_LABEL.get(b['kind'], 'Callout')
        return ('<div class="callout %s"><span class="ct">%s</span>%s</div>'
                % (cls, E(label), E(b['text'])))
    if t == 'script':
        h = ('<div class="blkh">Script box%s</div>'
             % (' &mdash; ' + E(b['heading']) if b['heading'] else ''))
        li = []
        for l in b['lines']:
            bits = ['<b>&ldquo;%s&rdquo;</b>' % E(l['say'])]
            if l['notThis']:
                bits.append('<span class="not">Not: &ldquo;%s&rdquo;</span>' % E(l['notThis']))
            if l['why']:
                bits.append('<span>%s</span>' % E(l['why']))
            li.append('<li>%s</li>' % ''.join(bits))
        return '<div class="blk">%s<ul class="script">%s</ul></div>' % (h, ''.join(li))
    if t == 'when':
        return '<div class="when"><b>When / how much</b>%s</div>' % E(b['text'])
    if t == 'india':
        return '<div class="india"><b>In an Indian home</b>%s</div>' % E(b['text'])
    if t == 'video':
        mins = (' &middot; ' + E(b['minutes'])) if b['minutes'] else ''
        sub = ('<span>%s</span>' % E(b['subtitle'])) if b['subtitle'] else ''
        return ('<div class="slot"><span class="st">Video slot%s &middot; not yet filmed '
                '&middot; hoisted to the top of the page</span><b>%s</b>%s'
                '<span class="sid">%s</span></div>'
                % (mins, E(b['title']), sub, E(b['slotId'])))
    if t == 'audio':
        meta = ' &middot; '.join(x for x in [b['category'], b['minutes']] if x)
        return ('<div class="slot"><span class="st">Audio slot &middot; %s &middot; no file yet'
                '</span><b>%s</b><span class="sid">%s</span></div>'
                % (E(meta), E(b['title']), E(b['slotId'])))
    if t == 'link':
        if b['surfaceId']:
            to = '&rarr; ' + b['surfaceId']
        elif b['pageId']:
            to = '&rarr; page in this section: ' + b['pageId']
        else:
            to = 'renders as SOON &mdash; no destination declared'
        blurb = ('<span>%s</span>' % E(b['blurb'])) if b['blurb'] else ''
        return ('<div class="lnk"><b>%s</b> <span class="to">%s</span>%s</div>'
                % (E(b['label']), to, blurb))
    if t == 'consult':
        role = (' &middot; role: ' + b['role']) if b['role'] else ''
        return ('<div class="lnk consult"><b>Consult &mdash; %s</b> '
                '<span class="to">&rarr; %s%s</span><span>%s</span></div>'
                % (E(b['title']), E(SD.consult_surface(b)), E(role), E(b['whoFor'])))
    raise SystemExit('no renderer for block ' + t)


def render_page(p, ref):
    meta = []
    if p['format']:
        meta.append(chip(p['format']))
    if p['bands']:
        meta += [chip(x, 'n') for x in p['bands']]
    else:
        meta.append(chip('all bands', 'g'))
    sub = ('<p class="pgsub">%s</p>' % E(p['subtitle'])) if p['subtitle'] else ''
    return ('<div class="pg"><div class="pghd"><div class="pgnum">L4 &middot; %s</div>'
            '<h3>%s</h3>%s<div class="pgmeta">%s</div></div>'
            '<div class="stack">%s</div></div>'
            % (ref, E(p['title']), sub, ' '.join(meta),
               ''.join(render_block(b) for b in p['blocks'])))


# =============================================================================
#  THE DOCUMENT
# =============================================================================

LEGEND = """
<section class="break">
  <div class="sec">
    <div class="num">&sect;0</div>
    <h2>How to read this</h2>
    <p class="sub">
      Everything a parent can reach from this one tile sits at one of six depths.
      Every heading below names its depth, so you always know where you are standing.
    </p>
  </div>
  <div class="stack">
    <table>
      <tr><th style="width:16mm">Depth</th><th style="width:34mm">What it is</th><th>What it looks like on the phone</th></tr>
      <tr><td><b>L0</b></td><td>Parenting home</td><td>The V3 grid. Eleven tiles.</td></tr>
      <tr><td><b>L1</b></td><td>The hub</td><td>A hero line, &ldquo;What do you need?&rdquo;, the doors, the tools, one closing offer. <b>Skipped entirely when the hub has only one door</b> &mdash; the tile opens that door's destination.</td></tr>
      <tr><td><b>L2</b></td><td>Door / tool</td><td>What a door or a tool opens.</td></tr>
      <tr><td><b>L3</b></td><td>Area</td><td>Tiles on the section landing, filtered by age band.</td></tr>
      <tr><td><b>L4</b></td><td>Page</td><td>An article, chart, table, step-list or checklist.</td></tr>
      <tr><td><b>L5</b></td><td>Blocks</td><td>The content itself, in the order it renders down the page.</td></tr>
    </table>
    <div class="rule"></div>
    <table>
      <tr><th style="width:40mm">Marker</th><th>Means</th></tr>
      <tr><td><span class="id">pp_activities</span></td><td>A <b>surface id</b>. Resolved by <span class="id">pp_surface_router.dart</span>. Anything in the app can route to it by name.</td></tr>
      <tr><td><span class="id">hub/parenting_x</span></td><td>A <b>route name</b> on the Navigator. Load-bearing &mdash; other parts of the app work out where you are from it.</td></tr>
      <tr><td><span class="chip">ARTICLE</span></td><td>The page's mandated <b>format</b>. Printed on the card that opens it, so the shape is visible before the tap.</td></tr>
      <tr><td><span class="chip n">nb</span> <span class="chip n">tod</span></td><td>The <b>age bands</b> this page is tagged to. &ldquo;All bands&rdquo; means no tag at all.</td></tr>
      <tr><td><span class="chip r">DOCTOR</span></td><td>A flagged callout that ends in a person to call. Coral, never alarm red.</td></tr>
    </table>
    <div class="rule"></div>
    <div class="note">
      <b>Three renderer rules shape everything below. Without them the tree looks wrong.</b><br><br>
      <b>1. A screen that would only restate the tap above it is skipped.</b> A hub with one door
      opens that door directly. An area holding one page in the current band opens that page
      directly. So the number of taps down to a page is not fixed &mdash; it depends on the
      child's age.<br><br>
      <b>2. Age narrows what leads, never what exists.</b> The child's own band is selected when
      the screen opens and sorts first; every other band stays one tap away. A band is a
      reordering, not a lock.<br><br>
      <b>3. Video is hoisted.</b> <span class="id">PpPage.orderedBlocks</span> moves every video
      slot to the top of its page, whatever order it was written in. This document shows pages
      in <i>rendered</i> order, so a video always appears first.
    </div>
  </div>
</section>
"""


def cover(bracket_id, sec, hub, br, notes, stats):
    cells = ''.join('<div><div class="n">%s</div><div class="l">%s</div></div>' % (n, l)
                    for n, l in stats)
    return """
<section class="cover">
  <div class="kicker">ParentVeda &middot; Parenting stage &middot; V3 home</div>
  <h1>%(h1)s</h1>
  <p class="lede">%(lede)s</p>
  <div class="coverstat">%(cells)s</div>
  <div class="meta">
    <b>Bracket</b> &nbsp;%(bid)s &nbsp;&middot;&nbsp; hue %(hue)s &nbsp;&middot;&nbsp; theme %(theme)s<br>
    <b>Hub config</b> &nbsp;%(hubvar)s &nbsp;&middot;&nbsp; template %(tmpl)s<br>
    <b>Content</b> &nbsp;%(file)s<br>
    <b>Core question</b> &nbsp;%(cq)s<br>
    <b>Generated</b> &nbsp;31 August 2026 by %(gen)s, from the code on %(branch)s
  </div>
</section>
""" % dict(h1=notes['h1'], lede=notes['lede'], cells=cells,
           bid=idspan(bracket_id), hue=br['hue'], theme=br['theme'],
           hubvar=idspan(hub['var']), tmpl=hub['template'],
           file=idspan('lib/screens/post_pregnancy/' + SD.SECTION_FILES[bracket_id]),
           cq=E(hub['coreQuestion']), gen=idspan('tools/door_map.py'), branch=idspan('main'))


def rp(s, w):
    """Escape for HTML, pad to width on the RAW length.

    ⚠️ THE ORDER IS THE WHOLE POINT. Padding an already-escaped string counts
    `&#x27;` as six characters, so one apostrophe in a page title pushed that
    row's band column six spaces right and the tree stopped lining up. Escape
    after measuring, never before.
    """
    s = str(s)
    return E(s) + ' ' * max(0, w - len(s))


def plain_len(line):
    """Visible width of a rendered tree line: no tags, entities resolved."""
    return len(html.unescape(re.sub(r'<[^>]+>', '', line)))


def tree_font(lines):
    """Type size for a tree box: fit the width, then fit one page if close.

    ⚠️ TWO CONSTRAINTS, AND THE SECOND ONLY APPLIES WHEN IT CAN BE MET.
    Width is mandatory -- the box hides its overflow, so a line one character
    too wide loses its last word silently. Height is a courtesy: a tree that
    spills six lines onto a fresh page wastes most of that page, so if the
    whole thing fits within a page at 5.6pt or larger it is shrunk to fit.
    Beyond that (Early Learning's tree is over two hundred lines) it simply
    flows, because shrinking it further would be unreadable for no gain.
    """
    widest = max(plain_len(x) for x in lines)
    fs = max(6.0, min(7.6, 497.0 / (0.6 * widest)))
    n = len(lines)
    if n * 1.62 * fs <= 657:
        return fs
    fit = 657.0 / (1.62 * n)
    return fit if fit >= 5.6 else fs


def tree(bracket_id, sec, hub, br, section_door_index):
    one = len(hub['needs']) == 1
    band_ids = [b['id'] for b in sec['bands']]
    L = []
    L.append('L0  PARENTING HOME (V3)  &mdash; eleven bracket tiles')
    L.append(' |')
    L.append(' +-- <b>%s</b>   <i>tile &middot; hue %s</i>' % (E(br['label']), br['hue']))
    L.append('     |')
    if one:
        L.append('L1   |   <u>the hub screen is SKIPPED</u> <i>-- one door, so the tile opens it directly</i>')
        L.append('     |   <i>the tools and the closing offer are drawn on the section screen instead</i>')
        L.append('     |')
        ind = '     '
    else:
        L.append('L1   +-- <b>%s HUB</b>   <i>route: hub/%s</i>'
                 % (E(sec['title'].upper()), bracket_id))
        L.append('         |   "%s"' % E(hub['hero']))
        L.append('         |')
        ind = '         '

    def target(n):
        if n['surfaceId']:
            return n['surfaceId']
        return action_target(n['action']) or ('action %s -- nothing built yet' % n['action'])

    # ⚠️ A PAGE TAGGED TO EVERY BAND IS AN UNTAGGED PAGE, and printing the full
    # list of five ids for it cost forty characters of line width for no
    # information. Development tags all five explicitly on eight pages.
    everything = set(band_ids)

    def bandstr(p):
        if not p['bands'] or set(p['bands']) == everything:
            return '[all]'
        return '[%s]' % ','.join(p['bands'])

    # Columns sized from this section's own longest strings rather than fixed,
    # so no title is ever cut.
    wa = min(64, max([len(a['title']) for a in sec['areas']] or [1]) + 1)
    wt = min(58, max([len(p['title']) for a in sec['areas'] for p in a['pages']] or [1]) + 1)
    wb = max([len(bandstr(p)) for a in sec['areas'] for p in a['pages']] or [5]) + 2

    for i, n in enumerate(hub['needs']):
        L.append('L2   %s+-- DOOR %d  %s-&gt; <b>%s</b>'
                 % (ind, i + 1, rp(n['label'], 36).replace(E(n['label']),
                                                           '<b>%s</b>' % E(n['label'])),
                    E(target(n))))
        if i != section_door_index:
            L.append('     %s|' % ind)
            continue
        L.append('     %s|   |' % ind)
        if sec['bands']:
            L.append('L3   %s|   +-- band chooser:  %s'
                     % (ind, ' | '.join(E(b['label']) for b in sec['bands'])))
            L.append('     %s|   |' % ind)
        for ai, a in enumerate(sec['areas'], 1):
            shown = [b for b in band_ids if in_band(a['bands'], b)] or ['-']
            counts = [len(pages_for(a, b)) for b in shown if b != '-'] or [len(a['pages'])]
            lo, hi = min(counts), max(counts)
            unit = 'page' if hi == 1 else 'pages'
            if lo == hi:
                rng = '%d %s' % (hi, unit)
            else:
                rng = '%d-%d pages' % (lo, hi)
            where = ('every band' if len(shown) == len(band_ids)
                     else 'only ' + ','.join(shown))
            extra = ''
            if a['pinned']:
                extra += '  <u>[pinned]</u>'
            if a['toolSurfaceId']:
                extra += '  <u>[opens %s]</u>' % E(a['toolSurfaceId'])
            if lo == 0:
                extra += '  <u>[0 pages in one band: dead card]</u>'
            L.append('     %s|   +-- AREA %-2d %s %s, %s%s'
                     % (ind, ai, rp(a['title'], wa), rng, where, extra))
            for p in a['pages']:
                L.append('     %s|   |     +-- %s %s %s'
                         % (ind, rp(p['title'], wt), rp(bandstr(p), wb),
                            E(p['format'] or '')))
            L.append('     %s|   |' % ind)
        L.append('     %s|' % ind)

    for i, t in enumerate(sec['tools'], 1):
        L.append('L2   %s+-- TOOL %d  %s-&gt; <b>%s</b>'
                 % (ind, i, rp(t['label'], 36).replace(E(t['label']),
                                                       '<b>%s</b>' % E(t['label'])),
                    E(t['surfaceId'])))
        L.append('     %s|' % ind)
    if hub['closing']:
        c = hub['closing']
        L.append('L2   %s+-- CLOSING %s-&gt; <b>%s</b>'
                 % (ind, rp(c['label'], 34).replace(E(c['label']),
                                                    '<b>%s</b>' % E(c['label'])),
                    E(c['surfaceId'] or c['action'])))
    else:
        L.append('     %s    <i>(no closing offer -- see the note in &sect;2)</i>' % ind)

    # ⚠️ SIZED TO FIT, NOT CLIPPED. The tree box hides its overflow, so a line
    # one character too wide loses its last word silently -- the format column
    # was reading "CHART-CARI". The usable text width is 184mm minus the box
    # padding, and IBM Plex Mono sits at about 0.6em per character, so the type
    # size follows from the longest line rather than being guessed.
    fs = tree_font(L)
    return ('<section class="break"><div class="sec"><div class="num">&sect;1</div>'
            '<h2>The whole door, in one tree</h2><p class="sub">Read top to bottom. '
            'Everything indented under a line is what that line opens. Purple is a '
            'destination you can route to by name; red marks something worth stopping on.'
            '</p></div><div class="tree" style="font-size:%.2fpt">%s</div></section>'
            % (fs, chr(10).join(L)))


def hub_section(bracket_id, sec, hub, br, notes):
    one = len(hub['needs']) == 1
    parts = []
    parts.append('<section class="break"><div class="sec"><div class="num">&sect;2 &middot; L1</div>'
                 '<h2>%s</h2><p class="sub">%s</p></div><div class="stack">'
                 % ('The hub, and what it does not draw' if one else 'The hub screen',
                    ('This hub has <b>one</b> door, so the hub screen never renders: the tile '
                     'opens the door&rsquo;s destination directly. The config below is still real '
                     '&mdash; the tools and the closing offer are drawn by the section screen '
                     'instead. Route <span class="id">hub/%s</span> is therefore never pushed.'
                     % bracket_id) if one else
                    ('One screen, in this order. Every word on it is below. Route '
                     '<span class="id">hub/%s</span>, rendered by '
                     '<span class="id">ProblemHubScreen</span> from '
                     '<span class="id">%s</span>.' % (bracket_id, hub['var']))))

    parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 1</span>'
                 '<h4>The hero</h4></div><p class="intro">%s</p><p class="blurb">%s</p>'
                 '<p class="route">The bracket name <b>%s</b> sits above the hero as an '
                 'eyebrow. %s</p></div>'
                 % (E(hub['hero']), E(hub['heroSupport']), E(br['label']),
                    ('A film fills the hero: <span class="id">%s</span>.' % hub['heroVideoSlot'])
                    if hub['heroVideoSlot'] else
                    '<span class="id">heroVideoSlot</span> is null, so the support line renders '
                    'rather than a film.'))

    if hub['urgent']:
        parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 2</span>'
                     '<h4>The urgent strip</h4></div><p class="intro">%s</p>'
                     '<p class="route">Fires action <span class="id">%s</span>.</p></div>'
                     % (E(hub['urgent']['line']), E(hub['urgent']['action'])))
    else:
        parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 2</span>'
                     '<h4>The urgent strip</h4></div><p class="blurb"><b>Absent, '
                     'deliberately.</b> The config declares no <span class="id">urgent</span>. '
                     'A hub that shows a red-flag strip where no red flags exist trains people '
                     'to ignore the ones that do. This bracket&rsquo;s genuine flags live on the '
                     'pages that earn them, not on the front door.</p></div>')

    rows = []
    for i, n in enumerate(hub['needs'], 1):
        tgt = n['surfaceId'] or action_target(n['action']) or ('nothing built &mdash; action %s' % n['action'])
        via = ('surface <span class="id">%s</span>' % E(n['surfaceId'])) if n['surfaceId'] else \
              ('action <span class="id">%s</span> &rarr; resolves to <span class="id">%s</span>'
               % (E(n['action']), E(tgt)))
        rows.append('<div class="rule"></div><h4>Door %d &mdash; %s</h4>'
                    '<p class="blurb">%s</p><p class="route">mark '
                    '<span class="id">%s</span> &middot; hue %s &middot; %s</p>'
                    % (i, E(n['label']), E(n['blurb']), E(n['mark']), n['hue'], via))
    parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 3</span>'
                 '<h4>%s</h4></div><p class="blurb">%s</p>%s</div>'
                 % (E(hub['needsTitle']),
                    ('One door. Two is the minimum that earns a hub screen, so this one is '
                     'skipped and the tile opens the door below.' if one
                     else '%d doors. Two is the minimum that earns a hub screen at all; more '
                          'than four would be a menu.' % len(hub['needs'])),
                    ''.join(rows)))

    if sec['tools']:
        trows = []
        for t in sec['tools']:
            icon = (' ' + chip((t['icon'] or 'default') + ' icon', 'b')) if t['icon'] else ''
            trows.append('<div class="rule"></div><h4>%s%s</h4><p class="blurb">%s &nbsp;%s</p>'
                         % (E(t['label']), icon, E(t['blurb']), idspan(t['surfaceId'])))
        parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 4</span>'
                     '<h4>Tools</h4></div><p class="blurb">%s</p>%s</div>'
                     % (('%d rows under a hairline <b>TOOLS</b> heading. They are declared once, '
                         'on the section, and read up onto the hub &mdash; so adding a tool to '
                         'the section adds it here.' % len(sec['tools'])) if not one else
                        ('%d rows under a hairline <b>TOOLS</b> heading &mdash; drawn on the '
                         '<b>section</b> screen, since no hub screen renders. This is the fix for '
                         'the bug that stranded seventeen tools across the four one-door '
                         'brackets: they were declared, routable, and drawn by nothing.'
                         % len(sec['tools'])),
                        ''.join(trows)))
    else:
        parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 4</span>'
                     '<h4>Tools</h4></div><p class="blurb"><b>None declared.</b> This section '
                     'has an empty <span class="id">tools</span> list, so no TOOLS heading is '
                     'drawn at all &mdash; an empty heading being worse than none.</p></div>')

    if hub['closing']:
        c = hub['closing']
        parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 5</span>'
                     '<h4>The closing offer</h4></div><h4>%s</h4><p class="blurb">%s</p>'
                     '<p class="route">surface <span class="id">%s</span>%s &mdash; it is '
                     '<b>not</b> a third door: a door names a reason she opened the app, and '
                     'booking a consult is what is left when reading has run out.%s</p></div>'
                     % (E(c['label']), E(c['blurb']), E(c['surfaceId'] or c['action']),
                        (' (falling back to action <span class="id">%s</span>)' % E(c['action']))
                        if c['surfaceId'] else '',
                        ' Drawn by the <b>section</b> screen here, since no hub screen renders.'
                        if one else ''))
    else:
        parts.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 5</span>'
                     '<h4>The closing offer</h4></div><p class="blurb"><b>None.</b> '
                     'See the note below for why.</p></div>')

    for h, body in notes.get('hub', []):
        parts.append('<div class="note"><b>%s</b><br><br>%s</div>' % (h, body))

    layer_rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td></tr>'
                         % (E(k), E(v[0]),
                            E(', '.join(v[1]) if isinstance(v[1], list) else (v[1] or '')))
                         for k, v in br['layers'].items())
    parts.append('<div class="rule"></div><h3>What the bracket declares</h3>'
                 '<p style="font-size:8.8pt;color:var(--mute)">The seven-layer table behind the '
                 'tile. The hub is what a parent sees; this is what the workbook says exists. '
                 'A layer marked live but absent from the hub is reachable only through the '
                 'generic bracket screen, which a bracket with a hub never opens.</p>'
                 '<table><tr><th style="width:30mm">Layer</th><th style="width:24mm">State</th>'
                 '<th>Surfaces, or the reason</th></tr>%s</table>' % layer_rows)
    parts.append('</div></section>')
    return ''.join(parts)


MARK_HINT = 'drawn mark, not a stock glyph'


def _landing_extras(sec, hub):
    """Whether tools and the closing offer are drawn on this screen or the hub.

    ⚠️ NAMED RATHER THAN ASSUMED. The obvious sentence -- "the hub draws both"
    -- is wrong for the two sections with an empty tools list and wrong again
    for a one-door bracket, where this screen draws them because no hub screen
    exists. Three states, so the sentence is built rather than written.
    """
    has_tools, has_closing = bool(sec['tools']), bool(hub['closing'])
    if len(hub['needs']) == 1:
        what = ' and '.join([x for x in [
            '%d tools' % len(sec['tools']) if has_tools else '',
            'the closing offer' if has_closing else ''] if x])
        if not what:
            return (' Neither tools nor a closing offer exist for this bracket, so this screen '
                    'ends on the last area card.')
        return (' %s are drawn <b>here</b>, because a one-door bracket renders no hub screen '
                'to draw them.' % what[0].upper() + what[1:])
    parts = []
    if has_tools:
        parts.append('the %d tool rows' % len(sec['tools']))
    if has_closing:
        parts.append('the closing offer')
    if not parts:
        return (' This section declares no tools, and the bracket has no closing offer, so the '
                'screen ends on the last area card.')
    return (' %s sit on the hub above rather than here &mdash; drawing them twice was the '
            'failure the condition exists to prevent.'
            % (parts[0][0].upper() + parts[0][1:] + (' and ' + parts[1] if len(parts) > 1 else '')))


def landing_section(bracket_id, sec, hub, notes, section_door):
    rows, totals = band_matrix(sec)
    parts = []
    door_label = section_door['label'] if section_door else sec['title']
    tgt = (section_door['surfaceId'] or action_target(section_door['action'])) if section_door else None
    parts.append('<section class="break"><div class="sec">'
                 '<div class="num">&sect;3 &middot; L2 &rarr; L3</div>'
                 '<h2>%s</h2><p class="sub">%s</p></div><div class="stack">'
                 % ('The door into the library: &ldquo;%s&rdquo;' % E(door_label),
                    'It resolves to <span class="id">%s</span> &mdash; the age-banded library. '
                    'This is the screen with the age toggles across the top.' % E(tgt or '')))

    parts.append('<div class="lvl keep"><div class="hd"><span class="lb">SCREEN COPY</span>'
                 '<h4>%s</h4></div>%s<p class="intro">%s</p>'
                 '<p class="route">Rendered by <span class="id">PpSectionScreen</span>. Title, '
                 'one intro line, the band chooser, then a grid of %d area cards.%s</p></div>'
                 % (E(sec['title']),
                    ('<p class="blurb">%s</p>' % E(sec['subtitle'])) if sec['subtitle'] else '',
                    E(sec['intro']), len(sec['areas']),
                    _landing_extras(sec, hub)))

    if sec['bands']:
        brows = ''.join('<tr><td>%s</td><td>%s</td><td>%s to %s months</td><td><b>%d</b></td>'
                        '<td>%s</td></tr>'
                        % (idspan(b['id']), E(b['label']), b['from'], b['to'],
                           totals[b['id']], E(b['blurb'] or ''))
                        for b in sec['bands'])
        parts.append('<h3 style="margin-top:6pt">The age chooser</h3>'
                     '<p style="font-size:8.8pt;color:var(--mute)">%d bands. The child&rsquo;s own '
                     'band is selected on open and sorts to the front; the rest follow in '
                     'natural order and stay tappable. Lower bound inclusive, upper exclusive '
                     '&mdash; so a child exactly at a boundary is in the band that starts '
                     'there.</p>'
                     '<table><tr><th style="width:18mm">Id</th><th style="width:44mm">Label on '
                     'the chip</th><th style="width:28mm">Covers</th><th style="width:16mm">Pages'
                     '</th><th>Blurb under the chips</th></tr>%s</table>'
                     % (len(sec['bands']), brows))

        hdr = ''.join('<th>%s</th>' % E(b['label'].split(',')[0]) for b in sec['bands'])
        mrows = []
        for a, counts in rows:
            cells = ''.join('<td>%s</td>' % ('&mdash;' if counts[b['id']] is None
                                             else counts[b['id']])
                            for b in sec['bands'])
            mrows.append('<tr><td>%s</td>%s</tr>' % (E(a['title']), cells))
        mrows.append('<tr><td><b>Total</b></td>%s</tr>'
                     % ''.join('<td><b>%d</b></td>' % totals[b['id']] for b in sec['bands']))
        note = ''
        ones = [(a['title'], b['label']) for a, c in rows for b in sec['bands']
                if c[b['id']] == 1]
        if ones:
            note = ('<p class="tbl-note"><b>A 1 means the list screen is skipped.</b> In these '
                    'cases tapping the area opens its single page directly: %s.</p>'
                    % E('; '.join('%s in %s' % (t, b) for t, b in ones[:8])))
        # ⚠️ A CARD THAT RENDERS OVER NOTHING. The grid draws every area whose
        # own band tag admits the current band -- but the pages behind it are
        # tagged separately. Where an untagged area holds only tagged pages,
        # a band can arrive at a card whose page list is empty, and `_openArea`
        # returns without pushing anything. A tap that does nothing.
        zeros = [(a['title'], b['label']) for a, c in rows for b in sec['bands']
                 if c[b['id']] == 0]
        if zeros:
            note += ('<p class="tbl-note" style="color:var(--doc)"><b>A 0 is a card that opens '
                     'nothing.</b> The area itself is not band-tagged, so its card is drawn; '
                     'every page behind it is tagged out of this band, so the tap returns '
                     'without pushing a screen: %s.</p>'
                     % E('; '.join('%s in %s' % (t, b) for t, b in zeros)))
        if band_changes_nothing(sec):
            note += ('<p class="tbl-note"><b>Every column is identical, and the screen says so.</b> '
                     'When switching band cannot change what is visible, the landing prints '
                     '&ldquo;Everything here is worth reading at any age. The age above just '
                     'changes what comes first.&rdquo; &mdash; because a chip that re-filters a '
                     'list where nothing is filtered out is indistinguishable from a dead '
                     'control.</p>')
        parts.append('<h3 style="margin-top:6pt">What each band actually sees</h3>'
                     '<p style="font-size:8.8pt;color:var(--mute)">Page counts behind each area '
                     'card. An em-dash means the area itself is band-tagged out and its card '
                     'does not appear at all.</p>'
                     '<table><tr><th style="width:50mm">Area</th>%s</tr>%s</table>%s'
                     % (hdr, ''.join(mrows), note))

    arows = ''.join('<tr><td>%d</td><td><b>%s</b>%s</td><td>%s</td><td>%s &middot; %s</td></tr>'
                    % (i, E(a['title']),
                       ' <span class="chip r">PINNED</span>' if a['pinned'] else
                       (' <span class="chip b">TOOL</span>' if a['toolSurfaceId'] else ''),
                       E(a['blurb']), E(a['mark']), a['hue'])
                    for i, a in enumerate(sec['areas'], 1))
    parts.append('<h3 style="margin-top:6pt">The area cards</h3>'
                 '<p style="font-size:8.8pt;color:var(--mute)">Cover cards in a two-column grid, '
                 'each with a %s on a tinted ground and its page count as the meta line. No '
                 'photography exists yet: a null cover paints the tint and the mark, which is a '
                 'finished state rather than a placeholder for one.</p>'
                 '<table><tr><th style="width:8mm">#</th><th style="width:48mm">Title on the '
                 'card</th><th>Line under it</th><th style="width:26mm">Mark / hue</th></tr>'
                 '%s</table>' % (MARK_HINT, arows))

    for h, body in notes.get('editorial', []):
        parts.append('<div class="note"><b>%s</b><br><br>%s</div>' % (h, body))
    parts.append('</div></section>')
    return ''.join(parts)


def areas_sections(sec, notes):
    out = []
    per_area_notes = notes.get('areas', {})
    for ai, a in enumerate(sec['areas'], 1):
        band_ids = [b['id'] for b in sec['bands']]
        shown = [b for b in band_ids if in_band(a['bands'], b)]
        counts = [len(pages_for(a, b)) for b in shown] or [len(a['pages'])]
        unit = 'page' if len(a['pages']) == 1 else 'pages'
        rng = '%d %s' % (len(a['pages']), unit)
        if shown and len(shown) < len(band_ids):
            rng += ', shown only in the %s band%s' % (
                ' / '.join(next(x['label'] for x in sec['bands'] if x['id'] == b)
                           for b in shown), '' if len(shown) == 1 else 's')
        if len(set(counts)) > 1:
            rng += ', %d to %d of them visible at once' % (min(counts), max(counts))
        head = ('<section class="break"><div class="sec">'
                '<div class="num">&sect;4.%d &middot; L3</div><h2>Area %d &mdash; %s</h2>'
                '<p class="sub">%s Route <span class="id">pp/%s/%s</span>. %s.%s</p></div>'
                % (ai, ai, E(a['title']), E(a['blurb']), sec['id'], a['id'], rng,
                   (' Pinned above the grid as one wide card.' if a['pinned'] else '')))
        body = []
        if a['id'] in per_area_notes:
            for h, txt in per_area_notes[a['id']]:
                body.append('<div class="note" style="margin-bottom:11pt"><b>%s</b><br><br>%s'
                            '</div>' % (h, txt))
        for pi, p in enumerate(a['pages'], 1):
            body.append(render_page(p, 'P%d.%d' % (ai, pi)))
        out.append(head + ''.join(body) + '</section>')
    return ''.join(out)


def tools_section(bracket_id, sec, hub, notes, section_door_index, rids):
    parts = ['<section class="break"><div class="sec"><div class="num">&sect;5 &middot; L2</div>'
             '<h2>The other doors, and the tools</h2><p class="sub">Everything on the hub that '
             'is not the library: the doors that go somewhere else, the tool rows, and the '
             'closing offer. Each one names the screen it opens.</p></div><div class="stack">']

    n = 0
    for i, d in enumerate(hub['needs']):
        if i == section_door_index:
            continue
        n += 1
        tgt = d['surfaceId'] or action_target(d['action'])
        resolves = tgt in rids if tgt else False
        parts.append('<h3 style="margin-top:%dpt">Door %d &mdash; %s &nbsp;%s</h3>'
                     '<div class="lvl keep"><p class="intro">%s</p><p class="route">%s</p></div>'
                     % (2 if n == 1 else 12, i + 1, E(d['label']),
                        idspan(tgt or ('action ' + d['action'])), E(d['blurb']),
                        ('Resolves through the router.' if resolves else
                         'Not a router surface &mdash; see &sect;6.')))
        for h, body in notes.get('door_' + str(i + 1), []):
            parts.append('<div class="note"><b>%s</b><br><br>%s</div>' % (h, body))

    for t in sec['tools']:
        parts.append('<h3 style="margin-top:12pt">Tool &mdash; %s &nbsp;%s</h3>'
                     '<div class="lvl keep"><p class="intro">%s</p><p class="route">Icon: '
                     '<span class="id">%s</span>. %s</p></div>'
                     % (E(t['label']), idspan(t['surfaceId']), E(t['blurb']),
                        E(t['icon'] or 'default'),
                        'Resolves through the router.' if t['surfaceId'] in rids
                        else 'Not a router surface &mdash; see &sect;6.'))
        for h, body in notes.get('tool_' + t['surfaceId'], []):
            parts.append('<div class="note"><b>%s</b><br><br>%s</div>' % (h, body))

    if hub['closing']:
        c = hub['closing']
        parts.append('<h3 style="margin-top:12pt">Closing &mdash; %s &nbsp;%s</h3>'
                     '<div class="lvl keep"><p class="intro">%s</p><p class="route">A filtered '
                     'roster, not the whole expert list: the label names one kind of person, so '
                     'a generic destination would contradict the words just tapped.</p></div>'
                     % (E(c['label']), idspan(c['surfaceId'] or c['action']), E(c['blurb'])))
    for h, body in notes.get('tools', []):
        parts.append('<div class="note"><b>%s</b><br><br>%s</div>' % (h, body))
    parts.append('</div></section>')
    return ''.join(parts)


def routing_section(bracket_id, sec, hub, notes, coll, inb, rids, section_door_index):
    parts = ['<section class="break"><div class="sec"><div class="num">&sect;6</div>'
             '<h2>Where the routes go</h2><p class="sub">Every destination this door can reach, '
             'every way in from elsewhere, and the places where two different taps land in the '
             'same room. Derived from the code, not from reading the screens.</p>'
             '</div><div class="stack">']

    # ---- destinations off the hub -----------------------------------------
    dests = []
    for i, d in enumerate(hub['needs']):
        t = d['surfaceId'] or action_target(d['action']) or ('(nothing) ' + d['action'])
        dests.append(('Door %d' % (i + 1), d['label'], t))
    for t in sec['tools']:
        dests.append(('Tool', t['label'], t['surfaceId']))
    if hub['closing']:
        dests.append(('Closing', hub['closing']['label'],
                      hub['closing']['surfaceId'] or hub['closing']['action']))
    seen = {}
    for kind, label, t in dests:
        seen.setdefault(t, []).append('%s &ldquo;%s&rdquo;' % (kind, label))
    rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td></tr>'
                   % (kind, E(label), idspan(t) +
                      (' <span class="chip r">SHARED</span>' if len(seen[t]) > 1 else ''))
                   for kind, label, t in dests)
    parts.append('<h3>What the tile can reach</h3><table><tr><th style="width:20mm">Where</th>'
                 '<th style="width:56mm">The words you tap</th><th>Destination</th></tr>'
                 '%s</table>' % rows)
    dupes = {t: v for t, v in seen.items() if len(v) > 1}
    if dupes:
        parts.append('<div class="note warn"><b>Two taps, one screen.</b><br><br>%s</div>'
                     % '<br>'.join('%s &rarr; %s &mdash; both open %s'
                                   % (v[0], v[1], idspan(t)) for t, v in dupes.items()))

    # ---- in-page links ----------------------------------------------------
    if coll['links']:
        by = {}
        for l in coll['links']:
            key = l['surfaceId'] or (('page: ' + l['pageId']) if l['pageId'] else '(none)')
            by.setdefault(key, []).append(l)
        rows = ''.join('<tr><td>%s</td><td>%d</td><td>%s</td><td>%s</td></tr>'
                       % (idspan(k), len(v),
                          E(', '.join(sorted({x['ref'] for x in v}))),
                          ' &middot; '.join(E(x) for x in sorted({x['label']
                                                              for x in v})[:4]))
                       for k, v in sorted(by.items(), key=lambda kv: -len(kv[1])))
        parts.append('<h3 style="margin-top:8pt">Where the pages send you</h3>'
                     '<p style="font-size:8.8pt;color:var(--mute)">%d in-page links across the '
                     'section. A link resolves either to a router surface or to another page in '
                     'this same section; anything else renders as a row reading SOON.</p>'
                     '<table><tr><th style="width:44mm">Destination</th><th style="width:12mm">'
                     'Links</th><th style="width:34mm">From</th><th>Labels</th></tr>%s</table>'
                     % (len(coll['links']), rows))
        unresolved = sorted({l['surfaceId'] for l in coll['links']
                             if l['surfaceId'] and l['surfaceId'] not in rids
                             and not l['surfaceId'].startswith('pp_section/')})
        if unresolved:
            parts.append('<div class="note warn"><b>%d link target%s the router does not '
                         'declare.</b><br><br>%s<br><br>Each renders as a live, tappable row '
                         'that does nothing. This is the exact shape the wiring gate exists to '
                         'catch: nothing compiles wrong and nothing fails.</div>'
                         % (len(unresolved), '' if len(unresolved) == 1 else 's',
                            ', '.join(idspan(u) for u in unresolved)))
        if coll['dead']:
            parts.append('<div class="note warn"><b>%d link with no destination at all.</b>'
                         '<br><br>%s<br><br>A null surface renders as SOON, which is honest '
                         'about being unbuilt rather than a dead tap.</div>'
                         % (len(coll['dead']),
                            '<br>'.join('%s &mdash; &ldquo;%s&rdquo;' % (d['ref'], E(d['label']))
                                        for d in coll['dead'])))
        bad_pages = [p for p in coll['pageids']
                     if p['pageId'] not in {x['id'] for a in sec['areas'] for x in a['pages']}]
        if bad_pages:
            parts.append('<div class="note warn"><b>%d page-to-page link points at an id this '
                         'section does not have.</b><br><br>%s</div>'
                         % (len(bad_pages),
                            '<br>'.join('%s &rarr; %s' % (b['ref'], idspan(b['pageId']))
                                        for b in bad_pages)))

    # ---- consults ---------------------------------------------------------
    if coll['consults']:
        byrole = {}
        for c in coll['consults']:
            byrole.setdefault((c['role'], c['surface']), []).append(c)
        rows = ''.join('<tr><td>%s</td><td>%s</td><td>%d</td><td>%s</td></tr>'
                       % (E(r or '&mdash;'), idspan(s), len(v),
                          E(', '.join(sorted({x['ref'] for x in v}))))
                       for (r, s), v in sorted(byrole.items(), key=lambda kv: -len(kv[1])))
        parts.append('<h3 style="margin-top:8pt">Consults offered inside the pages</h3>'
                     '<p style="font-size:8.8pt;color:var(--mute)">%d consult blocks. Each '
                     'carries its own &ldquo;who this is for&rdquo; line, and its '
                     '<span class="id">role</span> is resolved through '
                     '<span class="id">kPpConsultRoleToCategory</span> into a filtered roster '
                     '&mdash; a role that maps to no category falls back to the whole list.</p>'
                     '<table><tr><th style="width:34mm">Role</th><th style="width:46mm">Opens'
                     '</th><th style="width:12mm">Count</th><th>Pages</th></tr>%s</table>'
                     % (len(coll['consults']), rows))

    # ---- inbound ----------------------------------------------------------
    if inb:
        rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td></tr>'
                       % (E(h['from']), E(h['page']), E(h['label'])) for h in inb)
        parts.append('<h3 style="margin-top:8pt">Ways in from other doors</h3>'
                     '<p style="font-size:8.8pt;color:var(--mute)">Links elsewhere in the '
                     'parenting stage that land on this section&rsquo;s landing screen. Each one '
                     'arrives at the top, on the reader&rsquo;s own age band.</p>'
                     '<table><tr><th style="width:36mm">From section</th>'
                     '<th style="width:52mm">On the page</th><th>The words you tap</th></tr>'
                     '%s</table>' % rows)
    else:
        parts.append('<h3 style="margin-top:8pt">Ways in from other doors</h3>'
                     '<div class="note"><b>None.</b> No other parenting section links to this '
                     'one. The tile on the home grid is the only way in.</div>')

    for h, body in notes.get('routing', []):
        parts.append('<div class="note%s"><b>%s</b><br><br>%s</div>'
                     % (' warn' if h.startswith('!') else '', h.lstrip('!'), body))
    parts.append('</div></section>')
    return ''.join(parts)


def gaps_section(bracket_id, sec, hub, notes, coll):
    parts = ['<section class="break"><div class="sec"><div class="num">&sect;7</div>'
             '<h2>What is written but not yet real</h2><p class="sub">Everything below renders '
             'today as a finished component in its file-less state &mdash; real geometry, real '
             'title, honest label &mdash; rather than as a tap that does nothing. When a file '
             'arrives, no widget changes.</p></div><div class="stack">']

    if coll['videos']:
        rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                       % (v['ref'], E(v['title']), E(v['minutes'] or '&mdash;'),
                          idspan(v['slotId'])) for v in coll['videos'])
        mins = sum(int(re.sub(r'\D', '', v['minutes'] or '0') or 0) for v in coll['videos'])
        parts.append('<h3>%d video slots</h3><p style="font-size:8.8pt;color:var(--mute)">'
                     '%d minutes in total, none filmed. Each occupies real 16:9 geometry at the '
                     'top of its page rather than naming itself in a bar.</p>'
                     '<table><tr><th style="width:14mm">Page</th><th style="width:60mm">Title on '
                     'the thumbnail</th><th style="width:14mm">Len</th><th>Slot id</th></tr>'
                     '%s</table>' % (len(coll['videos']), mins, rows))
        covered = {v['ref'] for v in coll['videos']}
        total = sum(len(a['pages']) for a in sec['areas'])
        parts.append('<p class="tbl-note">%d of %d pages carry a video; %d do not.</p>'
                     % (len(covered), total, total - len(covered)))
    else:
        parts.append('<h3>Video</h3><div class="note warn"><b>No video anywhere in this '
                     'section.</b> Every other built section carries at least one slot. Worth '
                     'deciding whether that is right for this subject or simply not done '
                     'yet.</div>')

    if coll['audios']:
        rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                       % (a['ref'], E(a['title']), E(a['category'] or '&mdash;'),
                          idspan(a['slotId'])) for a in coll['audios'])
        parts.append('<h3 style="margin-top:8pt">%d audio slots</h3>'
                     '<table><tr><th style="width:14mm">Page</th><th style="width:56mm">Track'
                     '</th><th style="width:34mm">Category</th><th>Slot id</th></tr>%s</table>'
                     % (len(coll['audios']), rows))

    if coll['callouts']:
        rows = ''.join('<tr><td>%s</td><td>%d</td><td>%s</td></tr>'
                       % (E(CALLOUT_LABEL.get(k, k)), v,
                          E({'key': 'The one key point on a page. Quiet, purple.',
                             'doctor': 'See a doctor. Coral, never alarm red, and it always '
                                       'names what to do rather than what to fear.',
                             'myth': 'A myth stated and corrected.',
                             'safety': 'A safety rule she acts on herself &mdash; it ends in an '
                                       'action, not in a person.'}.get(k, '')))
                       for k, v in sorted(coll['callouts'].items(), key=lambda kv: -kv[1]))
        parts.append('<h3 style="margin-top:8pt">Callouts by kind</h3>'
                     '<table><tr><th style="width:34mm">Kind</th><th style="width:14mm">Count'
                     '</th><th>What it is for</th></tr>%s</table>' % rows)

    for h, body in notes.get('gaps', []):
        parts.append('<div class="note%s"><b>%s</b><br><br>%s</div>'
                     % (' warn' if h.startswith('!') else '', h.lstrip('!'), body))

    if notes.get('decisions'):
        rows = ''.join('<tr><td>%d</td><td>%s</td><td>%s</td></tr>' % (i, w, wh)
                       for i, (w, wh) in enumerate(notes['decisions'], 1))
        parts.append('<h3 style="margin-top:8pt">The things worth deciding, gathered</h3>'
                     '<table><tr><th style="width:8mm">#</th><th style="width:60mm">What</th>'
                     '<th>Where it is described</th></tr>%s</table>' % rows)

    parts.append('<p class="foot">ParentVeda &middot; %s door map &middot; generated 31 August '
                 '2026 by <span class="id">tools/door_map.py</span> from '
                 '<span class="id">%s</span>, <span class="id">parenting_hubs.dart</span>, '
                 '<span class="id">parenting_brackets.dart</span>, '
                 '<span class="id">pp_section_screen.dart</span> and '
                 '<span class="id">pp_surface_router.dart</span>.<br>All reader-facing copy is '
                 'quoted verbatim from the source. Anything in a grey or coral box is '
                 'commentary written for this document, not text a parent sees.</p>'
                 % (E(sec['title']), SD.SECTION_FILES[bracket_id]))
    parts.append('</div></section>')
    return ''.join(parts)


# =============================================================================
#  THE HAND-WRITTEN HALF
# -----------------------------------------------------------------------------
#  Judgement, not data. Everything countable is computed above; what belongs
#  here is why a gap is a gap, which duplicate is deliberate, and what a reader
#  should do about it.
#
#  Keys: h1, lede, hub, editorial, areas{area_id}, door_N, tool_<surface>,
#  tools, routing, gaps, decisions. A leading '!' on a note heading makes it
#  coral -- reserve that for something someone should act on.
# =============================================================================

NOTES = {

# -----------------------------------------------------------------------------
'parenting_development': {
 'h1': 'Development,<br>the whole door.',
 'lede': 'Every screen behind the Development tile &mdash; two doors, five tools, '
         'four content areas, twenty pages &mdash; drawn as a tree and then written out '
         'in full. Read this instead of opening the app.',
 'hub': [
   ('Both doors open something real, which is rarer in this stage than it sounds.',
    'Nine of the eleven parenting hubs have at least one door pointing at something not '
    'yet built. This one has two live destinations, and the split is genuine rather than '
    'cosmetic: one door is <i>is my child on track</i>, the other is <i>what do I do about '
    'it</i>.<br><br>The first door used to open <span class="id">pp_milestones</span>, the '
    'milestone tracker alone. The rebuilt library is what the door actually promises &mdash; '
    'on-track reassurance, the skill windows, speech and language, and what to do about any '
    'of it &mdash; and the tracker is now one answer inside it, linked from several pages. '
    'Nothing was lost; the door stopped opening one tool in place of the whole question.'),
 ],
 'editorial': [
   ('The rule this section is written against, stated in its own source: no scoreboard.',
    'The authoring note at the head of the content file is blunt about it. A rigid milestone '
    'tracker does not retain, and the anxiety it creates is off-brand &mdash; <b>the '
    'reassurance content is the product</b>. So the words <i>behind</i>, <i>delayed</i> and '
    '<i>late developer</i> do not describe a child anywhere in the file. A skill is '
    '<b>emerging</b>, or it is one a family is <b>waiting for</b>.<br><br>The same note '
    'refuses the obvious feature: a quiz that concludes &ldquo;everything looks on '
    'track&rdquo;. That is a reassurance the app is not qualified to give on the strength of '
    'eight taps, and if it is wrong it has actively delayed a family &mdash; the worst '
    'outcome this section can produce. &ldquo;Worth a chat with an expert&rdquo; is the only '
    'honest alternative.'),
   ('Why Area 2 disappears for older children, and why that is the design working.',
    'The eight skill pages &mdash; rolling, sitting, crawling, standing, walking, pointing, '
    'first word, self-feeding &mdash; are tagged to the first three bands only. A parent of a '
    'three-year-old does not see that card at all, because a library of &ldquo;when will my '
    'baby roll over&rdquo; for a child who has been walking for two years is filler. Banding '
    'here removes a shelf rather than reordering one, which is the one case where the rule '
    'about never hiding a feature gives way: the feature is not hidden, it has been outgrown.'),
 ],
 'routing': [
   ('Five tools is the most of any parenting section except Health.',
    'And they are five genuinely different acts: a snapshot, a milestone list, an activity '
    'for today, a phase calendar, and a search for something that has changed. Worth knowing '
    'that four of the five are also reachable from elsewhere in the app, so a parent may '
    'arrive at them without ever having seen this hub.'),
 ],
 'decisions': [
   ('Door 2 opens the activities home; Door 1 opens the library. Neither opens the other.',
    'Nothing links Door 2&rsquo;s destination back to this library, so a parent who lands on '
    'activities first may never find the reassurance content &mdash; which is the half the '
    'section says is the product.'),
 ],
},

# -----------------------------------------------------------------------------
'parenting_behaviour': {
 'h1': 'Behaviour,<br>the whole door.',
 'lede': 'Every screen behind the Behaviour tile &mdash; one door, ten content areas, '
         'forty-one pages, and a library that changes almost entirely with the child&rsquo;s '
         'age &mdash; drawn as a tree and then written out in full.',
 'hub': [
   ('A one-door hub, and the bug that hid behind it for a whole pass.',
    'One door means the hub screen never renders: the tile opens the door&rsquo;s destination '
    'directly, because a screen whose only content restates the tile you just tapped is a tap '
    'of pure tax.<br><br>That was right, and it had a consequence nobody saw. The tools and '
    'the closing offer are declared on the hub, and for the four one-door brackets nothing '
    'ever drew them &mdash; seventeen tools across the four, declared, routable, tested for '
    'resolvability, and rendered by nothing at all. It surfaced from the outside as a styling '
    'complaint: Behaviour &ldquo;opens in a very different ui than others&rdquo;. It was not '
    'styling. The screen was missing a section every other bracket shows. The section screen '
    'now draws both whenever it is the top screen, which is why they appear in this document '
    'under &sect;5.'),
   ('The closing offer here is not a duplicate of the in-page consults, and the distinction '
    'is worth holding.',
    'The pages that discuss a red flag carry their own <span class="id">PpConsult</span> with '
    'a psychologist role, offered at the moment it is relevant. The closing offer is the '
    'standing &ldquo;if none of this is enough&rdquo; that every other bracket ends on. One '
    'is timed, the other is permanent, and collapsing them would lose whichever job the '
    'survivor was not doing.'),
 ],
 'editorial': [
   ('!The infant band sees one area out of ten, and that is the whole point of banding.',
    'Every area in this section is age-tagged, and the tags barely overlap. A parent of a '
    'three-month-old sees <b>only</b> Area 1, &ldquo;Why is my baby crying so much?&rdquo; '
    '&mdash; six pages. The tantrum library, the ziddi pages, the screen-time chart, the '
    'discipline pages and the three-to-six area are all tagged away.<br><br>That is the rule '
    'the specs asked for by name: &ldquo;so a parent of a 3-month-old never sees an empty '
    'tantrum library&rdquo;. It is worth stating plainly here because the tree below looks '
    'alarmingly lopsided until you know it: nine of the ten areas are for a child who can '
    'walk.'),
   ('The stance on hitting is a page, not a disclaimer.',
    'Area 8 is called &ldquo;Guiding without hitting&rdquo; and its first page is why hitting '
    'does not do what it looks like it does. The area then spends a page on what to do when '
    'elders in the house discipline differently &mdash; which is the version of this problem '
    'an Indian parent actually has. Taking a position and then helping her hold it in her own '
    'house is a different product from taking a position and stopping.'),
 ],
 'areas': {
   'calming': [
     ('These six are activities, not articles, and they are meant to be set up in advance.',
      'The area&rsquo;s own promise is &ldquo;six small practices to set up <b>before</b> you '
      'need them&rdquo;. Each takes ten minutes to learn and then works for years. That is a '
      'different reading contract from the rest of the section, which is written for the '
      'evening it is going wrong.'),
   ],
 },
 'routing': [
   ('!The switch arm written for this door has never been able to run.',
    'The door&rsquo;s action is <span class="id">pp_behaviour</span>, and '
    '<span class="id">pp_home_v3.dart</span> has a carefully written arm for it that opens '
    'the What Changed library pre-filtered to the Behaviour and Mood categories &mdash; '
    'chosen deliberately over a text match on the word &ldquo;behaviour&rdquo;, which '
    'surfaced only two concerns.<br><br>It is dead code. The section lookup sits above the '
    'switch and returns first, so the arm compiles, reads as live, and never executes. It is '
    'kept as the fallback if the section were ever removed, and it is the same trap the '
    'pregnancy side hit when three of its doors gained real sections. Worth knowing before '
    'somebody debugs the filter.'),
 ],
 'decisions': [
   ('The What Changed tool is the only route to the behaviour concerns the switch arm wanted',
    'It is declared as a section tool, so it does render &mdash; but unfiltered. &sect;5.'),
 ],
},

# -----------------------------------------------------------------------------
'parenting_potty': {
 'h1': 'Toilet learning,<br>the whole door.',
 'lede': 'Every screen behind the Potty training tile &mdash; two doors that land in two '
         'different areas, seven areas, twenty-three pages &mdash; drawn as a tree and then '
         'written out in full.',
 'hub': [
   ('This hub is where the app learned to address an area, not just a section.',
    'Both doors used to resolve to the bare section id, so &ldquo;Is my child ready?&rdquo; '
    'and &ldquo;Start &amp; manage potty training&rdquo; opened the same landing page. Two '
    'differently worded questions, one identical answer &mdash; reported from the outside in '
    'exactly those words.<br><br>The cause was that a section was addressable and an area was '
    'not. The router now accepts <span class="id">pp_section/&lt;bracket&gt;/&lt;area&gt;</span> '
    'and each door carries its own area, which is why this is the only parenting hub whose '
    'two doors land in different rooms of the same library. It was the third instance of that '
    'shape in one review, after Nutrition and Development.'),
   ('!And the deep link ignores the age band, which matters for the first door.',
    'A deep link looks the area up by id across <i>all</i> the section&rsquo;s areas, not '
    'across the ones the current band admits. Both target areas are tagged to the middle band '
    '(1 to 3 years). So a parent of a nine-month-old who taps &ldquo;Is my child ready?&rdquo; '
    'is taken into an area her own band does not show, while the landing underneath her still '
    'lists the su-su content.<br><br>That is arguably correct &mdash; she asked the question, '
    'so she gets the answer &mdash; and it is certainly better than landing nowhere. But it is '
    'unintended rather than designed, and it is the kind of thing that reads as a bug the '
    'first time somebody notices the landing and the pushed screen disagreeing.'),
 ],
 'editorial': [
   ('The premise of this section is that training is not where it starts.',
    'Its own intro says so: in most Indian homes this begins long before any training does, '
    'with the su-su cue and a grandmother who already knows the timing. So the youngest band '
    'is not a waiting room &mdash; it has a real area about cueing, reading signals, and using '
    'the grandmother method and diapers together rather than choosing between them.<br><br>'
    'The alternative, which most apps ship, is a section that says &ldquo;come back at '
    'eighteen months&rdquo;. That would be accurate about Western practice and wrong about the '
    'houses this app is for.'),
   ('One area is pinned, and it is the one a parent actually needs first.',
    '&ldquo;How long does this actually take?&rdquo; renders above the grid as a single wide '
    'card rather than as one tile among seven. The feedback that produced it described the '
    'timeline as &ldquo;a constant, and like a tool it should look different from other '
    'articles&rdquo;. It holds one page, so tapping it opens that page directly &mdash; no '
    'list in between.'),
 ],
 'routing': [
   ('No tools at all, and that is a declared state rather than an oversight.',
    'The section&rsquo;s tools list is empty, so no TOOLS heading is drawn. The bracket table '
    'marks tools <span class="id">notReady</span> for this bracket and calls the need here '
    '&ldquo;Light&rdquo;. A readiness quiz would be the obvious thing to build, and the '
    'section deliberately answers readiness with an article about signs instead &mdash; '
    'because a quiz that concludes &ldquo;not ready&rdquo; hands a parent a verdict she did '
    'not ask for.'),
 ],
},

# -----------------------------------------------------------------------------
'parenting_early_learning': {
 'h1': 'Early Learning,<br>the whole door.',
 'lede': 'The largest content section in the parenting stage: twelve areas, one hundred and '
         'twenty-five pages, fifty-eight of them stories. Every screen behind the Early '
         'learning tile, drawn as a tree and then written out in full.',
 'hub': [
   ('!The biggest library in the stage is reached through the door labelled &ldquo;Prepare '
    'for school&rdquo;.',
    'Door 1, &ldquo;Something to do today&rdquo;, opens <span class="id">pp_activities</span> '
    '&mdash; the activities home, which is a different screen. Door 2, &ldquo;Prepare for '
    'school&rdquo;, is the only door that opens this section.<br><br>So a parent looking for '
    'a story to tell tonight, or the Panchatantra, or the fifteen habits pages, has to tap a '
    'door about school readiness to find them. The section is not mislabelled and the door is '
    'not mislabelled; they simply do not describe each other. Note too that the section has '
    'its own school-readiness area &mdash; Area 12 &mdash; so the door could deep-link '
    'straight to it the way Potty&rsquo;s two doors do, and today it opens the whole landing '
    'instead.'),
   ('The trap this hub was rescued from, worth keeping visible.',
    'An earlier mapping pointed &ldquo;Prepare for school&rdquo; at '
    '<span class="id">pp_courses</span>, which sounds right and is the <i>parent</i> course '
    'catalogue rather than anything child-directed. That is the wrong audience behind a '
    'right-sounding label &mdash; the same failure the router file exists to prevent, and the '
    'reason a door is allowed to stay an unbuilt action rather than open something adjacent '
    'and hope.'),
 ],
 'editorial': [
   ('Fifty-eight of the hundred and twenty-five pages are stories, and they are the reason '
    'this section is the size it is.',
    'Six areas are collections: ten little bedtime tales, twelve Panchatantra, ten Jataka, '
    'ten Akbar and Birbal, six Tenali Rama, ten from around the world. Each collection is '
    'gated at the <b>area</b> level rather than the page level &mdash; so a collection either '
    'appears for a band or it does not, and once it appears every story in it is available. '
    'That is right for stories, where the gate is &ldquo;is she old enough for this kind of '
    'tale&rdquo; and not &ldquo;which of these ten&rdquo;.'),
   ('The word this section spends most of its energy refusing is &ldquo;worksheet&rdquo;.',
    'It appears ten times in the content, every time to rule something out. The stated '
    'position is that what comes before letters and numbers is not letters and numbers, and '
    'the worksheets can wait &mdash; which is a real commercial choice in a market where '
    'early-learning apps sell the opposite.'),
 ],
 'routing': [
   ('Four tools, and two of them are the other door.',
    '<span class="id">pp_activities</span> is Door 1 and also the first tool; '
    '<span class="id">pp_development</span> is a tool here and a door on the Development hub. '
    'Shared destinations across hubs are fine &mdash; a parent arrives from whichever question '
    'she had &mdash; but a door and a tool on the <i>same</i> hub opening the same screen is '
    'the duplication worth a look.'),
 ],
},

# -----------------------------------------------------------------------------
'parenting_first_40': {
 'h1': 'Jaapa,<br>the whole door.',
 'lede': 'Every screen behind the First 40 Days tile &mdash; one door, ten areas, forty-one '
         'pages, a day-by-day spine for the baby and a whole area for the mother &mdash; '
         'drawn as a tree and then written out in full.',
 'hub': [
   ('One door, opening directly, and no closing offer &mdash; the second of those is a '
    'product decision and it is the more interesting one.',
    'The hub used to say a closing offer here could never be seen, because a one-door hub '
    'renders no hub screen. That was true of the hub and false of the bracket: the door lands '
    'on the section screen, which now draws the closing offer whenever it is the top screen. '
    'So the mechanical objection is gone.<br><br>It stays absent on a product ground instead, '
    'which is more durable. The first forty days are the weeks a mother is most reachable and '
    'least able to judge an offer, and a permanent &ldquo;book someone&rdquo; footer under '
    'day-by-day recovery content reads as selling into exhaustion. The section&rsquo;s own '
    'consult blocks already offer a lactation consultant on the feeding pages and a doctor on '
    'the jaundice page &mdash; at the moment the need is real, which is the only time this '
    'bracket should ask.'),
   ('This bracket is named in the code as a candidate for bespoke UI rather than the generic '
    'renderer.',
    'A day-by-day spine is not the same shape as a library of areas, and '
    '<span class="id">hub_config.dart</span> names First 40 Days as an example of a hub that '
    'may render its own body. It has not been done; Area 1 carries the spine as four '
    'day-range pages instead. Worth knowing that the current shape is a deliberate '
    'approximation, not the finished intent.'),
 ],
 'editorial': [
   ('The section holds two audiences at once, and says so in its structure.',
    'Nine areas are about the baby. Area 7, <i>Maa Ki Dekhbhaal</i>, is about the mother '
    '&mdash; bleeding, a normal delivery, a C-section, rest and jaapa food, when to call her '
    '<i>own</i> doctor, and what to do if she does not feel like herself. Putting her recovery '
    'inside the newborn section rather than only in &ldquo;You, Maa&rdquo; is the choice that '
    'makes the section match the six weeks it describes, where nobody asks how she is.'),
   ('Only Area 1 responds to the age chips, which makes the bands quieter here than elsewhere.',
    'The other nine areas leave every page untagged, on purpose: cord care and jaundice do not '
    'become irrelevant on day 31. So the chips move the day-spine and reorder the reading, and '
    'in the last band Area 1 holds a single page and opens it directly.'),
 ],
 'areas': {
   'jaapa_essentials': [
     ('This area is commerce, written to the same standard as the content.',
      'Three pages: what you actually need, which malish oil, which swaddle and how many. Two '
      'of the three are comparison tables. The house style holds &mdash; say what to skip as '
      'readily as what to buy &mdash; which is what makes a buying page inside a care section '
      'tolerable at all.'),
   ],
   'rush_to_doctor': [
     ('Area 2, and its position is the point.',
      'The red flags are the second area, not the tenth. A parent who opens this section at '
      '3am should meet &ldquo;when to rush&rdquo; before she meets cord care.'),
   ],
 },
},

# -----------------------------------------------------------------------------
'parenting_maternal': {
 'h1': 'You, Maa,<br>the whole door.',
 'lede': 'The one door in the parenting stage that is not about the baby. Ten areas, '
         'ninety-eight pages about her body, her mind, her pelvic floor, her food and going '
         'back to work &mdash; drawn as a tree and then written out in full.',
 'hub': [
   ('!Both doors land on exactly the same screen.',
    '&ldquo;Understand my recovery&rdquo; and &ldquo;Get help with a recovery concern&rdquo; '
    'are two different questions, and both resolve to '
    '<span class="id">pp_section/parenting_maternal</span> &mdash; the same landing, at the '
    'same scroll position, on the same band.<br><br>This is the identical shape that was found '
    'and fixed on the Potty hub in the same review: a section was addressable and an area was '
    'not. Here the fix is already available and simply unused. The section has an obvious '
    'target for the second door &mdash; Area 1, &ldquo;How are you today, Maa?&rdquo;, which '
    'is literally a &ldquo;pick the one that sounds most like today&rdquo; triage &mdash; so '
    'pointing it at <span class="id">pp_section/parenting_maternal/how_are_you</span> would '
    'make the two doors mean different things for one line of code.'),
   ('Two switch arms for these doors are dead code, and both were written with care.',
    'The section lookup returns before the switch, so neither arm runs. One of them opens the '
    'reading library filtered to the collection &ldquo;The Parent, Too&rdquo; &mdash; itself a '
    'fix for an earlier bug where a mother asking about her own recovery was shown the whole '
    'library, whose hero is hardcoded to an article about the baby&rsquo;s sleep regression. '
    'The other is an honest &ldquo;owed&rdquo; screen for the recovery-concern door. Both are '
    'now unreachable, and the section is a better answer than either, but somebody debugging '
    'this door will read live-looking code that cannot execute.'),
 ],
 'editorial': [
   ('No weight-loss framing anywhere in the food area. Not as a goal, not as a benefit, not '
    'as an aside.',
    'The authoring note states the position outright so the individual pages never have to '
    'hedge around it, and one page takes the question on directly rather than leaving it '
    'unanswered. The area is called &ldquo;Have you eaten today?&rdquo; &mdash; which is the '
    'question that actually matters in the first weeks, and the one nobody asks.'),
   ('The bands measure her time since birth, not the baby&rsquo;s age, and they are kept in a '
    'separate set for that reason.',
    'The numbers are identical to a child band set and the meaning is not: nought to six weeks '
    'here is her healing, not her baby&rsquo;s newborn stage. They are defined separately and '
    'named for her, because the moment somebody reuses the child bands for her recovery, a '
    'boundary later moved for a reason about babies silently moves her six-week check.'),
   ('!Area 9 draws a card that opens nothing in the first band.',
    '&ldquo;Going back, and finding yourself again&rdquo; is not band-tagged, so its card is '
    'drawn for every band. All nine of its pages are tagged to later bands. In the first six '
    'weeks the card therefore renders and the tap returns without pushing a screen.<br><br>'
    'The content decision is right &mdash; a mother six days post-birth should not be reading '
    'about returning to work. The rendering is not: either the area wants the same band tags '
    'its pages carry, or the grid should skip a card with nothing behind it. The matrix in '
    '&sect;3 marks the cell.'),
 ],
 'routing': [
   ('No tools, in the section with the second-most pages.',
    'The tools list is empty, so no TOOLS heading is drawn. Two candidates are named in the '
    'content but not built: a postpartum products shop and a fourth-trimester circle, both '
    'held as explicit nulls rather than as links that would render as SOON. There is also no '
    'mother-facing &ldquo;something feels off&rdquo; tool at all &mdash; and the router file '
    'is explicit that <span class="id">pp_what_changed</span> is the wrong one to reuse, '
    'because it is built and worded for the baby. Right shape, wrong audience.'),
 ],
 'decisions': [
   ('Point Door 2 at the how_are_you area',
    'One line, and the two doors stop being the same door. &sect;2.'),
   ('Give Area 9 the band tags its pages already carry',
    'Or make the grid skip an area with zero pages in the current band. &sect;3.'),
 ],
},

# -----------------------------------------------------------------------------
'parenting_traditional': {
 'h1': 'Traditions,<br>the whole door.',
 'lede': 'Every screen behind the Traditional tile &mdash; one door, seven areas, '
         'twenty-four pages covering the ceremonies of five faiths, what each costs, and the '
         'customs that are not safe &mdash; drawn as a tree and then written out in full.',
 'hub': [
   ('The door used to open home remedies, and nothing about the wiring looked broken.',
    'It pointed at <span class="id">pp_nuskhe</span> &mdash; dadi ke nuskhe, which is home '
    'remedies for illness: cold, colic, teething. The screen is real, live and good, and it '
    'shares the &ldquo;traditional Indian wisdom&rdquo; voice while answering a completely '
    'different question. That is exactly why it slipped through: a parent looking up '
    'Annaprashan or mundan found zero results, and nothing in the code was wrong.<br><br>'
    'Nuskhe is still here, correctly, as one of the two section tools.'),
   ('No closing offer, and one was added in this pass and rejected by a test.',
    'A one-door hub never renders a hub screen, so a closing offer on the hub could not be '
    'seen. The reason is recorded rather than the config quietly deleted, because &ldquo;add '
    'an expert offer to every hub&rdquo; is a reasonable-sounding instruction that is wrong '
    'for a quarter of them. For this subject there is also nobody to book: the right home for '
    'help here is the content itself.'),
 ],
 'editorial': [
   ('The section&rsquo;s promise is unusually concrete, and the areas deliver it in that order.',
    'What actually happens, what you really need, what it costs, and what you can happily '
    'skip. Area 6 is an entire area about cost and keeping it small, ending in a script box '
    'for what to say when family wants it bigger &mdash; which is the part a couple actually '
    'needs and the part no explainer gives them.'),
   ('Five faiths, in the same format, in one area rather than in an appendix.',
    'Area 5 covers Aqiqah and Muslim naming, Tahneek, baptism and christening, Naam Karan at '
    'the Gurdwara and kesh, and welcomes in Jain and Parsi families &mdash; each rendered as a '
    'CEREMONY page, the same format the Hindu ceremonies use. Same format is the whole '
    'argument: a different template would have made them a supplement.'),
   ('!Area 7 is the reason this section cannot be only explanatory.',
    '&ldquo;Customs done with love that are not safe&rdquo; &mdash; kajal, honey, things put '
    'on the cord, and on the day itself blades, piercing and heat. A section that explains '
    'traditions warmly and stops has no way to say &ldquo;not this one&rdquo;. Naming the '
    'unsafe ones as done <i>with love</i> is what makes it possible to say so without telling '
    'a family they were careless.'),
 ],
 'routing': [
   ('!The age chips print a line that is not quite true here.',
    'The landing shows &ldquo;Everything here is worth reading at any age. The age above just '
    'changes what comes first.&rdquo; The screen decides that by comparing page <i>counts</i> '
    'across bands, and every count here is identical &mdash; so the line renders.<br><br>But '
    'Area 1 has four pages, one tagged to each band, so the chips genuinely change '
    '<b>which</b> page that card opens: the first months, then her first solid meal, then '
    'birthday and mundan, then the start of learning. The counts are equal and the content is '
    'not. The check is doing the right thing for the six untagged areas and the wrong thing '
    'for the one that is tagged.'),
 ],
 'decisions': [
   ('The band note contradicts Area 1',
    'The count-based check cannot see that a card opens a different page per band. &sect;6.'),
 ],
},
}


# =============================================================================
#  BUILD
# =============================================================================

def build(bracket_id):
    sec = SD.load_section(bracket_id)
    hub = hubs()[bracket_id]
    br = brackets()[bracket_id]
    rids = router_ids()
    notes = NOTES[bracket_id]
    coll = collect(sec)
    inb = inbound(bracket_id, sec)

    # Which door opens this section? The one whose surface or resolved action
    # lands on it. -1 when none does, which would be a section with no way in.
    section_door_index, section_door = -1, None
    for i, d in enumerate(hub['needs']):
        t = d['surfaceId'] or action_target(d['action']) or ''
        if t.startswith('pp_section/' + bracket_id):
            section_door_index, section_door = i, d
            break

    pages = sum(len(a['pages']) for a in sec['areas'])
    stats = [(len(hub['needs']), 'Doors'), (len(sec['tools']), 'Tools'),
             (len(sec['areas']), 'Areas'), (pages, 'Pages'),
             (len(sec['bands']), 'Age bands'), (len(coll['videos']), 'Video slots')]

    body = ''.join([
        cover(bracket_id, sec, hub, br, notes, stats),
        LEGEND,
        tree(bracket_id, sec, hub, br, section_door_index),
        hub_section(bracket_id, sec, hub, br, notes),
        landing_section(bracket_id, sec, hub, notes, section_door),
        areas_sections(sec, notes),
        tools_section(bracket_id, sec, hub, notes, section_door_index, rids),
        routing_section(bracket_id, sec, hub, notes, coll, inb, rids, section_door_index),
        gaps_section(bracket_id, sec, hub, notes, coll),
    ])

    slug = {'parenting_development': 'DEVELOPMENT', 'parenting_behaviour': 'BEHAVIOUR',
            'parenting_potty': 'POTTY', 'parenting_early_learning': 'EARLY-LEARNING',
            'parenting_first_40': 'FIRST-40-DAYS', 'parenting_maternal': 'YOU-MAA',
            'parenting_traditional': 'TRADITIONS', 'parenting_sleep': 'SLEEP',
            'parenting_feeding': 'FEEDING', 'parenting_health': 'HEALTH'}[bracket_id]
    out = os.path.join(DOCS, '%s-DOOR-MAP.html' % slug)
    with open(out, 'w', encoding='utf-8') as f:
        f.write('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
                '<title>ParentVeda &mdash; %s, the whole door</title>\n<style>\n%s\n</style>\n'
                '<style>\n%s\n</style>\n</head>\n<body>\n%s\n</body>\n</html>\n'
                % (sec['title'], fonts_css(), STYLE, body))
    return out, sec, coll


def to_pdf(html_path):
    chrome = next((c for c in CHROME_CANDIDATES if os.path.exists(c)), None)
    if not chrome:
        print('  (no Chrome found; HTML only)')
        return None
    pdf = html_path[:-5] + '.pdf'
    subprocess.run([chrome, '--headless=new', '--disable-gpu', '--no-pdf-header-footer',
                    '--virtual-time-budget=20000', '--print-to-pdf=' + pdf,
                    'file:///' + html_path.replace('\\', '/')],
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=300)
    return pdf if os.path.exists(pdf) else None


if __name__ == '__main__':
    verify_actions()
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    want_pdf = '--pdf' in sys.argv
    targets = args or list(NOTES)
    for b in targets:
        path, sec, coll = build(b)
        line = '%-26s %-24s %6.0f KB' % (b, sec['title'], os.path.getsize(path) / 1024)
        if want_pdf:
            pdf = to_pdf(path)
            if pdf:
                line += '  ->  %s' % os.path.basename(pdf)
        print(line)
