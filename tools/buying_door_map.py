#!/usr/bin/env python3
# =============================================================================
#  buying_door_map.py -- the What to Buy door, which is shaped like nothing else
# -----------------------------------------------------------------------------
#  ⚠️ WHY THIS IS A SEPARATE GENERATOR RATHER THAN AN ELEVENTH CALL TO
#  door_map.py.
#
#  Every other parenting bracket answers its doors with a `PpSection`: bands,
#  areas, pages, blocks. `parenting_buying` has none, on purpose. The registry
#  says so in as many words -- it was the one spec of the eleven that said "this
#  is NOT a ground-up build... do NOT restructure it", because its section is
#  the existing commerce IA, which is richer than a content section and already
#  reachable. Wrapping it in a `PpSection` to make the registry look complete
#  would have put a second, worse front door on a shop that already has one.
#
#  So the document has to map a different thing: two doors into two product
#  modules, nine in-depth guides, a six-by-three taxonomy, twenty-three
#  products, and the eighteen buying-guidance cards that are the actual
#  reader-facing content. Forcing that through the section renderer would have
#  meant inventing areas that do not exist, which is exactly the filler the
#  bracket spec forbids.
#
#  It shares door_map's stylesheet, fonts and helpers, so the eleven documents
#  still look like one set.
#
#  Usage:  python tools/buying_door_map.py [--pdf]
# =============================================================================

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import section_doc as SD                                          # noqa: E402
import door_map as DM                                             # noqa: E402

E, idspan, chip = DM.E, DM.idspan, DM.chip
BRACKET = 'parenting_buying'

RECO_LABEL = {'highly': 'HIGHLY RECOMMENDED', 'recommended': 'BUY',
              'considerations': 'CONSIDER', 'specific': 'SITUATIONAL',
              'notRecommended': 'SKIP'}


# =============================================================================
#  LOAD
# =============================================================================

def guides():
    env = SD.declarations(os.path.join(DM.ROOT, 'lib', 'screens', 'product_guide',
                                       'product_guide_data.dart'))
    gs = SD.resolve(env['kProductGuides'], env)
    out = []
    for g in gs:
        k = g.kwargs
        r = k['rating'].args
        out.append({
            'id': k['id'], 'category': k['category'], 'brand': k['brand'],
            'name': k['name'], 'reco': SD.enum_name(k['reco']),
            'pv': r[0], 'community': r[1],
            'verdict': k['verdict'], 'beforeYouBuy': k['beforeYouBuy'],
            'bestFor': k.get('bestFor') or [], 'whyLike': k.get('whyLike') or [],
            'watchOut': k.get('watchOut') or [],
            'experts': [{'role': x.kwargs['role'], 'name': x.kwargs['name'],
                         'hook': x.kwargs['hook'], 'duration': x.kwargs['duration'],
                         'videoId': x.kwargs.get('videoId')}
                        for x in (k.get('experts') or [])],
            'experiences': [{'text': x.kwargs['text'], 'author': x.kwargs['author'],
                             'context': x.kwargs['context'], 'stars': x.kwargs.get('stars', 5)}
                            for x in (k.get('experiences') or [])],
            'ingredients': [{'name': x.kwargs['name'], 'purpose': x.kwargs['purpose'],
                             'note': x.kwargs['note'], 'caution': x.kwargs.get('caution', '')}
                            for x in (k.get('ingredients') or [])],
            'studies': [{'topic': x.kwargs['topic'], 'summary': x.kwargs['summary'],
                         'meaning': x.kwargs['meaning'], 'source': x.kwargs.get('source', ''),
                         'byMaker': x.kwargs.get('byMaker', False)}
                        for x in (k.get('studies') or [])],
            'specs': [{'label': x.args[0], 'value': x.args[1]}
                      for x in (k.get('specs') or [])],
            'buyUrl': k.get('buyUrl'), 'imageAsset': k.get('imageAsset'),
            'relatedIds': k.get('relatedIds') or [],
        }),
    return [x[0] if isinstance(x, tuple) else x for x in out], SD.resolve(
        env['kProductToGuide'], env)


def catalogue():
    path = os.path.join(SD.PP, 'pp_products_data.dart')
    env = SD.declarations(path)
    cats = [{'name': c.args[0], 'subs': [{'name': s.args[0], 'short': s.args[1]}
                                         for s in c.args[2]]}
            for c in SD.resolve(env['kPpCategories'], env)]
    prods = [{'id': p.kwargs['id'], 'name': p.kwargs['name'], 'brand': p.kwargs['brand'],
              'category': p.kwargs['category'], 'sub': p.kwargs['sub'],
              'rating': p.kwargs['rating'], 'reviews': p.kwargs['reviews'],
              'price': p.kwargs['price'], 'retailer': p.kwargs['retailer'],
              'verified': p.kwargs.get('verified', False),
              'parentVeda': p.kwargs.get('parentVeda', False),
              'bestseller': p.kwargs.get('bestseller', False),
              'summary': p.kwargs.get('summary', ''), 'badge': p.kwargs.get('badge', '')}
             for p in SD.resolve(env['kPpProducts'], env)]
    subguides = {k: {'line': v.kwargs['line'], 'lookFor': v.kwargs['lookFor'],
                     'avoid': v.kwargs['avoid']}
                 for k, v in SD.resolve(env['kPpGuides'], env).items()}
    compare = {k: {f: v.kwargs.get(f) for f in
                   ('whatMatters', 'oftenSkip', 'mistake', 'contextTip')}
               for k, v in SD.resolve(env['kCompareGuides'], env).items()}
    return cats, prods, subguides, compare, \
        SD.resolve(env['kPpReviewOnlyLabel'], env), SD.resolve(env['kPpReviewOnlyWhy'], env)


def inbound_commerce():
    """Every link from a content section into one of this door's surfaces."""
    want = {'pp_products', 'pp_product_guide', 'pp_compare', 'pp_recos'}
    hits = []
    for b in SD.SECTION_FILES:
        s = SD.load_section(b)
        for ai, a in enumerate(s['areas'], 1):
            for pi, p in enumerate(a['pages'], 1):
                for blk in p['blocks']:
                    if blk['t'] == 'link' and blk['surfaceId'] in want:
                        hits.append({'from': s['title'], 'ref': 'P%d.%d' % (ai, pi),
                                     'page': p['title'], 'label': blk['label'],
                                     'to': blk['surfaceId']})
    return hits


def chooser_matches(gs, mapped, prods):
    """Which parenting products make the view chooser appear, and which guide.

    Reimplements `guideForProduct` exactly, including the loose fallback: a
    match on the LAST WORD of a guide's name, or on the guide's CATEGORY name,
    anywhere in the product name.
    """
    by_id = {g['id']: g for g in gs}
    out = []
    for p in prods:
        why, hit = None, None
        if p['id'] in by_id:
            why, hit = 'exact id', by_id[p['id']]
        elif p['id'] in mapped:
            why, hit = 'kProductToGuide', by_id.get(mapped[p['id']])
        else:
            n = p['name'].lower()
            for g in gs:
                key = g['name'].lower().split(' ')[-1]
                if key in n:
                    why, hit = 'name contains "%s"' % key, g
                    break
                if g['category'].lower() in n:
                    why, hit = 'name contains category "%s"' % g['category'].lower(), g
                    break
        out.append((p, why, hit))
    return out


# =============================================================================
#  RENDER
# =============================================================================

def stars(n):
    return '&#9733;' * int(n) + '&#9734;' * (5 - int(n))


def render():
    hub = DM.hubs()[BRACKET]
    br = DM.brackets()[BRACKET]
    rids = DM.router_ids()
    gs, mapped = guides()
    cats, prods, subguides, compare, ro_label, ro_why = catalogue()
    inb = inbound_commerce()
    matches = chooser_matches(gs, mapped, prods)
    fired = [(p, w, g) for p, w, g in matches if g]

    P = []

    # ---- cover ------------------------------------------------------------
    stats = [(len(hub['needs']), 'Doors'), (len(gs), 'Deep guides'),
             (len(cats), 'Categories'), (sum(len(c['subs']) for c in cats), 'Subcategories'),
             (len(prods), 'Products'), (len(inb), 'Ways in')]
    P.append("""
<section class="cover">
  <div class="kicker">ParentVeda &middot; Parenting stage &middot; V3 home</div>
  <h1>What to buy,<br>the whole door.</h1>
  <p class="lede">The one parenting bracket with no content library behind it &mdash; and the
  most linked-to destination in the stage. Two doors into two product modules, nine in-depth
  guides, eighteen buying-guidance cards, twenty-three products. Drawn as a tree and then
  written out in full.</p>
  <div class="coverstat">%s</div>
  <div class="meta">
    <b>Bracket</b> &nbsp;%s &nbsp;&middot;&nbsp; hue %s &nbsp;&middot;&nbsp; theme %s<br>
    <b>Hub config</b> &nbsp;%s &nbsp;&middot;&nbsp; template %s<br>
    <b>Modules</b> &nbsp;%s &nbsp;%s<br>
    <b>Core question</b> &nbsp;%s<br>
    <b>Generated</b> &nbsp;31 August 2026 by %s, from the code on %s
  </div>
</section>
""" % (''.join('<div><div class="n">%s</div><div class="l">%s</div></div>' % (n, l)
               for n, l in stats),
       idspan(BRACKET), br['hue'], br['theme'], idspan(hub['var']), hub['template'],
       idspan('lib/screens/product_guide/'), idspan('lib/screens/post_pregnancy/products_*'),
       E(hub['coreQuestion']), idspan('tools/buying_door_map.py'), idspan('main')))

    # ---- legend -----------------------------------------------------------
    P.append("""
<section class="break">
  <div class="sec"><div class="num">&sect;0</div><h2>How to read this</h2>
  <p class="sub">This door does not have the shape of the other ten. There are no age bands,
  no areas and no pages &mdash; so the depths below are the ones this door actually has.</p></div>
  <div class="stack">
    <table>
      <tr><th style="width:16mm">Depth</th><th style="width:36mm">What it is</th><th>What it looks like on the phone</th></tr>
      <tr><td><b>L0</b></td><td>Parenting home</td><td>The V3 grid. Eleven tiles.</td></tr>
      <tr><td><b>L1</b></td><td>The hub</td><td>A hero line, &ldquo;What do you need?&rdquo;, and two doors. No tools, no closing offer.</td></tr>
      <tr><td><b>L2</b></td><td>Module</td><td>Either the Product Guide, or the product catalogue. Two separate modules, in two separate folders.</td></tr>
      <tr><td><b>L3</b></td><td>List</td><td>The guide list, or the six categories and their subcategories.</td></tr>
      <tr><td><b>L4</b></td><td>Item</td><td>One in-depth Guide, or one product page.</td></tr>
      <tr><td><b>L5</b></td><td>Sections</td><td>The blocks down an item page, in render order.</td></tr>
    </table>
    <div class="rule"></div>
    <div class="note">
      <b>Why this bracket has no library, stated by the code that would have held it.</b><br><br>
      The section registry lists ten of the eleven parenting brackets and names this one as
      absent on purpose. It was the one spec of the eleven that said &ldquo;this is <b>not</b> a
      ground-up build&hellip; do <b>not</b> restructure it&rdquo;, because its content is the
      existing commerce IA &mdash; richer than a content section, and already reachable.
      Wrapping it in a section to make the registry look complete would have put a second,
      worse front door on a shop that already has one.<br><br>
      The tests know about the gap by name, so the count asserts ten rather than silently
      accepting any number. That is the distinction the bracket model exists to keep:
      <b>deliberately elsewhere</b> is not the same as <b>forgotten</b>.
    </div>
  </div>
</section>
""")

    # ---- tree -------------------------------------------------------------
    T = []
    T.append('L0  PARENTING HOME (V3)  &mdash; eleven bracket tiles')
    T.append(' |')
    T.append(' +-- <b>%s</b>   <i>tile &middot; hue %s</i>' % (E(br['label']), br['hue']))
    T.append('     |')
    T.append('L1   +-- <b>WHAT TO BUY HUB</b>   <i>route: hub/%s</i>' % BRACKET)
    T.append('         |   "%s"' % E(hub['hero']))
    T.append('         |   <i>no tools, no closing offer -- see &sect;2</i>')
    T.append('         |')
    d1, d2 = hub['needs']
    T.append('L2       +-- DOOR 1  <b>%s</b>%s-&gt; <b>%s</b>'
             % (E(d1['label']), ' ' * (30 - len(d1['label'])), d1['surfaceId']))
    T.append('         |   |   <i>ProductGuideHubScreen</i>')
    T.append('L3       |   +-- searchable list, grouped by category  (%d guides)' % len(gs))
    for g in gs:
        T.append('         |   |     +-- %-30s %-16s <i>%s</i>'
                 % (E(g['name'][:30]), E(g['category']), RECO_LABEL[g['reco']]))
    T.append('         |   +-- <b>Compare products</b>  -&gt; <b>pp_compare</b>  <u>[same screen as Door 2 can reach]</u>')
    T.append('         |   |')
    T.append('L4       |   +-- one Guide  <i>ProductGuideScreen</i>')
    T.append('         |         hero -&gt; before you buy -&gt; an honest look')
    T.append('         |         -- "explore more if you want" --')
    T.append('         |         experts -&gt; community -&gt; ingredients -&gt; research -&gt; specs')
    T.append('         |         -&gt; related -&gt; Ask Veda -&gt; disclaimer')
    T.append('         |')
    T.append('L2       +-- DOOR 2  <b>%s</b>%s-&gt; <b>%s</b>'
             % (E(d2['label']), ' ' * (30 - len(d2['label'])), d2['surfaceId']))
    T.append('             |   <i>ProductsDiscoveryScreen</i>')
    T.append('L3           +-- search, filters (6 kinds), sort, "Shop by category"')
    for c in cats:
        n = len([p for p in prods if p['category'] == c['name']])
        T.append('             |     +-- %-20s %d products' % (E(c['name']), n))
        for s in c['subs']:
            sn = len([p for p in prods if p['sub'] == s['name']])
            has = 'guidance card' if s['name'] in subguides else 'NO guidance'
            T.append('             |     |     +-- %-26s %d product%s  <i>%s</i>'
                     % (E(s['name']), sn, '' if sn == 1 else 's', has))
    T.append('             +-- <b>Compare any two</b>  -&gt; <b>pp_compare</b>')
    T.append('             |     <i>ProductsCompareScreen -- same category only, up to 3</i>')
    T.append('L4           +-- one product  <i>ProductDetailScreen</i>')
    T.append('                   the guidance card -&gt; pros and cons -&gt; research')
    T.append('                   -&gt; verified reviews -&gt; compare -&gt; buy or "%s"' % E(ro_label))
    fs = DM.tree_font(T)
    P.append('<section class="break"><div class="sec"><div class="num">&sect;1</div>'
             '<h2>The whole door, in one tree</h2><p class="sub">Two modules, side by side, '
             'that between them are the whole answer. Red marks a place where the two meet.'
             '</p></div><div class="tree" style="font-size:%.2fpt">%s</div></section>'
             % (fs, '\n'.join(T)))
    return P, hub, br, rids, gs, mapped, cats, prods, subguides, compare, ro_label, ro_why, \
        inb, matches, fired


def render_rest(P, hub, br, rids, gs, mapped, cats, prods, subguides, compare,
                ro_label, ro_why, inb, matches, fired):
    d1, d2 = hub['needs']

    # =========================================================================
    #  2. THE HUB
    # =========================================================================
    P.append('<section class="break"><div class="sec"><div class="num">&sect;2 &middot; L1</div>'
             '<h2>The hub screen</h2><p class="sub">Two doors, and nothing else. This is the '
             'shortest hub in the parenting stage. Route <span class="id">hub/%s</span>.</p>'
             '</div><div class="stack">' % BRACKET)
    P.append('<div class="lvl keep"><div class="hd"><span class="lb">BLOCK 1</span>'
             '<h4>The hero</h4></div><p class="intro">%s</p><p class="blurb">%s</p>'
             '<p class="route">The bracket name <b>%s</b> sits above the hero as an eyebrow.'
             '</p></div>' % (E(hub['hero']), E(hub['heroSupport']), E(br['label'])))
    for i, n in enumerate((d1, d2), 1):
        P.append('<div class="lvl keep"><div class="hd"><span class="lb">DOOR %d</span>'
                 '<h4>%s</h4></div><p class="blurb">%s</p><p class="route">mark '
                 '<span class="id">%s</span> &middot; hue %s &middot; surface '
                 '<span class="id">%s</span> &mdash; %s</p></div>'
                 % (i, E(n['label']), E(n['blurb']), E(n['mark']), n['hue'],
                    E(n['surfaceId']),
                    'resolves through the router' if n['surfaceId'] in rids
                    else 'NOT a router surface'))
    P.append("""
<div class="note">
  <b>No tools and no closing offer, and for once both absences are the same decision.</b><br><br>
  Course and consult are marked <span class="id">notApplicable</span> for this bracket &mdash;
  not <i>notReady</i>, which would mean owed. There is nobody to book about buying a stroller,
  and a &ldquo;talk to an expert&rdquo; footer under a shop would be an offer invented to fill a
  slot.<br><br>
  The tools list is empty for a related reason: the two doors already <i>are</i> the tools. A
  tool row is something you use rather than something you read, and both of these modules are
  things you use.
</div>
<div class="note">
  <b>This is the one hub where commerce is the job, and the bracket table says so.</b><br><br>
  Its template is <span class="id">decisionCommerce</span>, and the workbook&rsquo;s own note
  calls this &ldquo;the app&rsquo;s strongest&rdquo; bracket. Products are not filler here.
  What keeps it from being a shop with a content wrapper is the split between the two doors:
  Door 1 is allowed to say <i>do not buy this</i>, and Door 2 is where she picks. A catalogue
  that could not say &ldquo;skip it&rdquo; would have no reason to be inside a care app.
</div>
""")
    layer_rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td></tr>'
                         % (E(k), E(v[0]),
                            E(', '.join(v[1]) if isinstance(v[1], list) else (v[1] or '')))
                         for k, v in br['layers'].items())
    P.append('<div class="rule"></div><h3>What the bracket declares</h3>'
             '<p style="font-size:8.8pt;color:var(--mute)">The seven-layer table behind the '
             'tile.</p><table><tr><th style="width:30mm">Layer</th>'
             '<th style="width:26mm">State</th><th>Surfaces, or the reason</th></tr>%s</table>'
             % layer_rows)
    P.append('</div></section>')

    # =========================================================================
    #  3. DOOR 1 -- THE PRODUCT GUIDE
    # =========================================================================
    P.append('<section class="break"><div class="sec">'
             '<div class="num">&sect;3 &middot; L2</div>'
             '<h2>Door 1 &mdash; &ldquo;%s&rdquo;</h2><p class="sub">Opens '
             '<span class="id">%s</span> &rarr; <span class="id">ProductGuideHubScreen</span>. '
             'A separate module in its own folder, used identically by the parent app and the '
             'father app.</p></div><div class="stack">'
             % (E(d1['label']), E(d1['surfaceId'])))
    P.append("""
<div class="lvl keep"><div class="hd"><span class="lb">SCREEN COPY</span>
<h4>PRODUCT GUIDE</h4></div>
<p class="intro">Honest, evidence-informed guides for the products parents actually research
&mdash; understand in 10 seconds, go deeper only if you want to.</p>
<p class="blurb"><b>At the foot:</b> Guidance to help you choose &mdash; never a substitute for
your doctor&rsquo;s advice.</p>
<p class="route">A calm, searchable list grouped by category. Search matches name, category,
brand and the &ldquo;best for&rdquo; chips. Only products parents actively research before
buying appear here &mdash; which is why there are nine guides against twenty-three catalogue
products.</p></div>
<div class="lvl keep"><div class="hd"><span class="lb">ALSO ON THIS SCREEN</span>
<h4>Compare products</h4></div><p class="intro">Two picks, side by side.</p>
<p class="route">Opens <span class="id">pp_compare</span>. The comment in the source calls this
&ldquo;the Product Guide&rsquo;s own&rdquo; Compare entry &mdash; the same screen Door 2 reaches
from the catalogue side.</p></div>
""")
    rows = ''.join('<tr><td><b>%s</b></td><td>%s</td><td>%s</td><td>%s</td>'
                   '<td>%.1f / %.1f</td><td>%s</td></tr>'
                   % (E(g['name']), E(g['category']),
                      chip(RECO_LABEL[g['reco']],
                           'g' if g['reco'] in ('highly', 'recommended')
                           else ('r' if g['reco'] == 'notRecommended' else 'n')),
                      idspan(g['id']), g['pv'], g['community'],
                      '&middot;'.join(x for x in [
                          'E' if g['experts'] else '', 'C' if g['experiences'] else '',
                          'I' if g['ingredients'] else '', 'R' if g['studies'] else '',
                          'S' if g['specs'] else ''] if x))
                   for g in gs)
    P.append('<div class="rule"></div><h3>The nine guides</h3>'
             '<p style="font-size:8.8pt;color:var(--mute)">Ratings are ParentVeda / community. '
             'The last column shows which optional deep-dive blocks each guide carries: '
             '<b>E</b>xperts, <b>C</b>ommunity, <b>I</b>ngredients, <b>R</b>esearch, '
             '<b>S</b>pecs.</p>'
             '<table><tr><th style="width:48mm">Guide</th><th style="width:24mm">Category</th>'
             '<th style="width:30mm">Verdict band</th><th style="width:26mm">Id</th>'
             '<th style="width:18mm">Rating</th><th>Deep dive</th></tr>%s</table>' % rows)
    P.append("""
<div class="note">
  <b>The verdict band is not the rating, and the difference is deliberate.</b><br><br>
  A guide&rsquo;s headline score is derived: the ParentVeda rating, times nineteen, then
  <i>tempered by the band</i> &mdash; nothing for <span class="chip g">HIGHLY RECOMMENDED</span>,
  minus six for <span class="chip g">BUY</span>, minus sixteen for
  <span class="chip n">CONSIDER</span>, minus fourteen for
  <span class="chip n">SITUATIONAL</span>, minus thirty-four for
  <span class="chip r">SKIP</span>, clamped to 30&ndash;97.<br><br>
  So a situational pick can rate 4.5 and still score lower than a 4.4 that suits everybody.
  That is the honest arithmetic for a page whose job is to help one parent decide, not to rank
  products against each other. Nothing here reaches 100, and nothing falls below 30 &mdash; the
  clamp is a refusal to publish either a perfect score or a verdict that reads as contempt.
</div>
""")
    P.append('</div></section>')

    # ---- each guide in full ----------------------------------------------
    for gi, g in enumerate(gs, 1):
        B = []
        B.append('<div class="pg"><div class="pghd"><div class="pgnum">L4 &middot; G%d</div>'
                 '<h3>%s</h3><p class="pgsub">%s &middot; %s</p><div class="pgmeta">%s %s</div>'
                 '</div><div class="stack">'
                 % (gi, E(g['name']), E(g['brand']), E(g['category']),
                    chip(RECO_LABEL[g['reco']],
                         'g' if g['reco'] in ('highly', 'recommended')
                         else ('r' if g['reco'] == 'notRecommended' else 'n')),
                    idspan(g['id'])))
        B.append('<p class="intro">%s</p>' % E(g['verdict']))
        B.append('<div class="blk"><div class="blkh">Ratings</div><table>'
                 '<tr><td style="width:54mm">ParentVeda</td><td><b>%.1f</b> / 5</td></tr>'
                 '<tr><td>Community</td><td><b>%.1f</b> / 5</td></tr></table></div>'
                 % (g['pv'], g['community']))
        B.append('<div class="callout"><span class="ct">Before you buy</span>%s</div>'
                 % E(g['beforeYouBuy']))
        if g['bestFor']:
            B.append('<div class="blk"><div class="blkh">Best for</div><p>%s</p></div>'
                     % ' '.join(chip(x, 'b') for x in g['bestFor']))
        if g['whyLike']:
            B.append('<div class="blk"><div class="blkh">What&rsquo;s good</div>'
                     '<ul class="cards">%s</ul></div>'
                     % ''.join('<li><b>%s</b></li>' % E(x) for x in g['whyLike']))
        B.append('<div class="blk"><div class="blkh">Worth considering</div>%s</div>'
                 % ('<ul class="cards">%s</ul>'
                    % ''.join('<li><b>%s</b></li>' % E(x) for x in g['watchOut'])
                    if g['watchOut'] else
                    '<p style="color:var(--mute)">No real downsides stood out. '
                    '<i>(The screen prints exactly that rather than inventing a caveat.)</i></p>'))
        if g['experts']:
            B.append('<div class="blk"><div class="blkh">Expert explains</div>'
                     '<table><tr><th style="width:34mm">Role</th><th style="width:34mm">Name'
                     '</th><th style="width:14mm">Len</th><th>What they explain</th></tr>'
                     '%s</table><p class="tbl-note">%s</p></div>'
                     % (''.join('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                                % (E(x['role']), E(x['name']), E(x['duration']), E(x['hook']))
                                for x in g['experts']),
                        'None of these carries a real video id, so each card says so plainly '
                        'rather than pretending to be tappable.'
                        if all(not x['videoId'] for x in g['experts'])
                        else 'Cards with a video id open the real film from the Watch '
                             'catalogue.'))
        if g['experiences']:
            B.append('<div class="blk"><div class="blkh">From parents (%d)</div>'
                     '<ul class="cards">%s</ul></div>'
                     % (len(g['experiences']),
                        ''.join('<li><b>%s &nbsp;<span style="font-weight:400;color:'
                                'var(--myth)">%s</span></b><span>%s &middot; %s</span></li>'
                                % (E(x['text']), stars(x['stars']), E(x['author']),
                                   E(x['context'])) for x in g['experiences'])))
        if g['ingredients']:
            B.append('<div class="blk"><div class="blkh">Ingredients, explained</div>'
                     '<table><tr><th style="width:30mm">Ingredient</th>'
                     '<th style="width:30mm">Purpose</th><th>Why it is used, and the honest '
                     'caveat</th></tr>%s</table></div>'
                     % ''.join('<tr><td><b>%s</b></td><td>%s</td><td>%s%s</td></tr>'
                               % (E(x['name']), E(x['purpose']), E(x['note']),
                                  ('<br><span style="color:var(--doc)">Caution: %s</span>'
                                   % E(x['caution'])) if x['caution'] else '')
                               for x in g['ingredients']))
        if g['studies']:
            B.append('<div class="blk"><div class="blkh">Research corner</div>'
                     '<table><tr><th style="width:26mm">Topic</th><th>What it found, and what '
                     'it means</th><th style="width:30mm">Source</th></tr>%s</table></div>'
                     % ''.join('<tr><td><b>%s</b></td><td>%s<br><span style="color:var(--mute)">'
                               '%s</span></td><td>%s%s</td></tr>'
                               % (E(x['topic']), E(x['summary']), E(x['meaning']),
                                  E(x['source'] or '&mdash;'),
                                  ' <span class="chip n">MAKER&rsquo;S OWN</span>'
                                  if x['byMaker'] else '')
                               for x in g['studies']))
        if g['specs']:
            B.append('<div class="blk"><div class="blkh">Specs</div><table>%s</table></div>'
                     % ''.join('<tr><td style="width:54mm">%s</td><td><b>%s</b></td></tr>'
                               % (E(x['label']), E(x['value'])) for x in g['specs']))
        buy = ('a real retailer link: <span class="id">%s</span>' % E(g['buyUrl'])
               if g['buyUrl'] else
               'no retailer link, so the screen builds an Amazon search from the product name')
        B.append('<div class="lnk"><b>See buying options</b> <span class="to">&rarr; %s</span>'
                 '<span>An interstitial names the retailer before you leave: '
                 '&ldquo;Continue to Amazon&rdquo; or &ldquo;Stay here&rdquo;.</span></div>'
                 % buy)
        B.append('<div class="lnk"><b>Still deciding?</b> <span class="to">&rarr; Ask Veda'
                 '</span><span>Ask Veda anything about %s for your child. Closes every guide, '
                 'because three bullets and a research corner will not cover every worry a '
                 'parent arrives with &mdash; and pretending otherwise is how a trustworthy '
                 'page loses trust.</span></div>' % E(g['category'].lower()))
        if g['relatedIds']:
            B.append('<p class="tbl-note">Related guides: %s</p>'
                     % ', '.join(idspan(x) for x in g['relatedIds']))
        B.append('</div></div>')
        # ⚠️ ONE SECTION FOR ALL NINE, NOT NINE SECTIONS. A forced page break per
        # guide left eight half-empty pages, because most guides are shorter
        # than a page. They flow instead, and the page-break-after:avoid on
        # each heading keeps a title from being orphaned at a page foot.
        if gi == 1:
            P.append('<section class="break"><div class="sec">'
                     '<div class="num">&sect;3.1 &middot; L4</div>'
                     '<h2>The nine guides, in full</h2><p class="sub">Each one renders in this '
                     'order: hero and ratings, before you buy, an honest look, then a divider '
                     'reading &ldquo;EXPLORE MORE IF YOU WANT TO&rdquo;, and only then the '
                     'deep-dive blocks it happens to carry. Progressive disclosure is the '
                     'design: understand in ten seconds, go deeper only if you want to.</p>'
                     '</div>')
        P.append(''.join(B))
    P.append('</section>')
    return P


def render_door2(P, hub, rids, gs, cats, prods, subguides, compare, ro_label, ro_why,
                 inb, matches, fired):
    d1, d2 = hub['needs']

    # =========================================================================
    #  4. DOOR 2 -- THE CATALOGUE
    # =========================================================================
    P.append('<section class="break"><div class="sec">'
             '<div class="num">&sect;4 &middot; L2</div>'
             '<h2>Door 2 &mdash; &ldquo;%s&rdquo;</h2><p class="sub">Opens '
             '<span class="id">%s</span> &rarr; '
             '<span class="id">ProductsDiscoveryScreen</span>. The catalogue side: search, '
             'filters, a six-by-three taxonomy, and a buying-guidance card on every '
             'subcategory.</p></div><div class="stack">'
             % (E(d2['label']), E(d2['surfaceId'])))
    P.append("""
<div class="lvl keep"><div class="hd"><span class="lb">SCREEN COPY</span><h4>Products</h4></div>
<p class="intro">Shop by category. Tap a category to open its subcategories.</p>
<p class="blurb"><b>At the foot:</b> Named, verified-mother reviews on every product. Sponsored
slots are always labelled. Your research stays on ParentVeda.</p>
<p class="route">Above the category block: a search field, a <b>Filters</b> button carrying a
count badge, and a <b>Sort by</b> sheet. When a search or filter is active the category block is
replaced by a result count and a &ldquo;Clear all&rdquo;.</p></div>
<div class="lvl keep"><div class="hd"><span class="lb">ALSO ON THIS SCREEN</span>
<h4>Compare any two</h4></div>
<p class="route">Opens <span class="id">pp_compare</span>, the same screen Door 1 offers.</p>
</div>
""")
    P.append('<div class="blk"><div class="blkh">The filter sheet &mdash; six groups</div>'
             '<table><tr><th style="width:40mm">Group</th><th>Options</th></tr>'
             '<tr><td><b>What&rsquo;s the concern?</b></td><td>Rashes &middot; Poor sleep '
             '&middot; Colic &amp; gas &middot; Teething &middot; Dry skin &middot; Fever '
             '&middot; Feeding &middot; Travel</td></tr>'
             '<tr><td><b>Age &amp; stage</b></td><td>Newborn &middot; 0&ndash;3m &middot; '
             '3&ndash;6 months &middot; 6&ndash;12 months &middot; 1&ndash;2 years &middot; '
             '2 years +</td></tr>'
             '<tr><td><b>Category</b></td><td>%s</td></tr>'
             '<tr><td><b>Brand</b></td><td>Derived from the catalogue, sorted</td></tr>'
             '<tr><td><b>Price</b></td><td>Bands</td></tr>'
             '<tr><td><b>Rating</b></td><td>Bands</td></tr></table>'
             '<p class="tbl-note">The sheet&rsquo;s primary button previews the result: '
             '&ldquo;Show 7 products&rdquo;. A <b>Reset</b> clears every group.</p></div>'
             % ' &middot; '.join(E(c['name']) for c in cats))

    rows = []
    for c in cats:
        n = len([p for p in prods if p['category'] == c['name']])
        rows.append('<tr><td><b>%s</b></td><td><b>%d</b></td><td colspan="2"></td></tr>'
                    % (E(c['name']), n))
        for s in c['subs']:
            sp = [p for p in prods if p['sub'] == s['name']]
            rows.append('<tr><td style="padding-left:6mm">%s</td><td>%d</td><td>%s</td>'
                        '<td>%s</td></tr>'
                        % (E(s['name']), len(sp),
                           'yes' if s['name'] in subguides else
                           '<span style="color:var(--doc)">none</span>',
                           E(', '.join(p['name'] for p in sp)) or '&mdash;'))
    P.append('<div class="rule"></div><h3>The taxonomy, and what is actually in it</h3>'
             '<p style="font-size:8.8pt;color:var(--mute)">Six categories, three subcategories '
             'each, eighteen in total. Every one has a buying-guidance card; the products are '
             'thinner.</p><table><tr><th style="width:52mm">Category / subcategory</th>'
             '<th style="width:16mm">Items</th><th style="width:20mm">Guidance</th>'
             '<th>Products</th></tr>%s</table>' % ''.join(rows))
    P.append("""
<div class="note">
  <b>Eighteen subcategories, twenty-three products. Fifteen subcategories hold exactly one.</b>
  <br><br>
  Which is worth stating plainly because it decides what this door can honestly promise today.
  &ldquo;Compare&rdquo; works by <b>category</b> rather than by subcategory, and every category
  has at least three products, so comparison is always possible. But a parent who taps
  &ldquo;Thermometers&rdquo; expecting a shelf finds one item and its guidance card.<br><br>
  The guidance card is what makes that tolerable: the page is genuinely useful with one product
  on it, because the education is the content and the product is the illustration. It stops
  being tolerable the moment somebody reads the page as a shop.
</div>
""")
    P.append('</div></section>')

    # ---- the eighteen guidance cards -------------------------------------
    P.append('<section class="break"><div class="sec">'
             '<div class="num">&sect;4.1 &middot; L3</div>'
             '<h2>The eighteen buying-guidance cards, in full</h2>'
             '<p class="sub">One per subcategory. This is the reader-facing content of this '
             'door &mdash; the twenty-second version of what a good choice looks like, leading '
             'the page before any product does. A one-line lead, what to look for, and what to '
             'avoid.</p></div><div class="stack">')
    for cat in cats:
        for s in cat['subs']:
            g = subguides.get(s['name'])
            if not g:
                continue
            P.append('<div class="pg"><div class="pghd">'
                     '<div class="pgnum">%s</div><h3>%s</h3></div><div class="stack">'
                     '<p class="intro">%s</p>'
                     '<div class="blk"><div class="blkh">Look for</div><ul class="cards">%s</ul>'
                     '</div>'
                     '<div class="blk"><div class="blkh">Avoid</div><ul class="cards">%s</ul>'
                     '</div></div></div>'
                     % (E(cat['name'].upper()), E(s['name']), E(g['line']),
                        ''.join('<li><b>%s</b></li>' % E(x) for x in g['lookFor']),
                        ''.join('<li><b style="color:var(--doc)">%s</b></li>' % E(x)
                                for x in g['avoid'])))
    P.append('</div></section>')

    # ---- compare -----------------------------------------------------------
    P.append('<section class="break"><div class="sec">'
             '<div class="num">&sect;4.2 &middot; L4</div>'
             '<h2>The two item screens</h2><p class="sub">A product page, and the comparison '
             'tray. Both are reached from either door.</p></div><div class="stack">')
    P.append("""
<h3>One product &middot; <span class="id">ProductDetailScreen</span></h3>
<div class="lvl keep"><p class="route">Renders in this order: the subcategory&rsquo;s guidance
card, the product&rsquo;s own pros and cons, &ldquo;Read the research &mdash; the evidence
behind the claims, read it yourself&rdquo; with a link to the full paper on the
publisher&rsquo;s site, then &ldquo;From verified parents &mdash; named, with child &amp; age,
never anonymous&rdquo;, then &ldquo;Compare with alternatives&rdquo;, and finally the buy
row.</p>
<p class="blurb"><b>At the foot:</b> Reviews are from verified ParentVeda parents. No anonymous
reviews, ever.</p></div>
<div class="note warn">
  <b>Some products carry no buy button at all, and the reason is the law.</b><br><br>
  The label is <b>&ldquo;%s&rdquo;</b>, and the page explains it in its own words:<br><br>
  &ldquo;%s&rdquo;<br><br>
  Worth knowing before somebody reports the missing button as a bug. It is the one place in the
  app where a commercial surface deliberately does less than it could, and the copy says why
  rather than leaving a gap.
</div>
""" % (E(ro_label), E(ro_why)))
    rows = ''.join('<tr><td><b>%s</b></td><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                   % (E(k), E(' &middot; '.join(v['whatMatters'] or [])),
                      E(v['oftenSkip'] or ''), E(v['mistake'] or ''),
                      E(v['contextTip'] or '&mdash;'))
                   for k, v in compare.items())
    P.append("""
<h3 style="margin-top:12pt">Comparing &middot; <span class="id">ProductsCompareScreen</span></h3>
<div class="lvl keep"><p class="route">Up to three products, <b>same category only</b>, so
&ldquo;every comparison stays meaningful&rdquo;. Three states: empty (&ldquo;No products
selected yet&rdquo; with a Browse Products button), one picked (&ldquo;Add one more to
compare&rdquo; plus suggestions from the same category), and two or three picked (the table,
headed &ldquo;Comparing 2 bottles for [child]&rdquo;).</p>
<p class="blurb">Attempting to mix categories is refused with a message rather than silently
dropped: &ldquo;Products can only be compared within the same category. Clear your comparison to
start a new one.&rdquo; A fourth pick is refused with &ldquo;You can compare up to 3 &mdash;
remove one first.&rdquo;</p></div>
<div class="blk"><div class="blkh">What actually matters &mdash; one card per category, shown
above the table</div>
<table><tr><th style="width:28mm">Category</th><th>What matters</th>
<th style="width:38mm">Often skipped</th><th style="width:38mm">The common mistake</th>
<th style="width:30mm">Context tip</th></tr>%s</table></div>
""" % rows)
    P.append('</div></section>')

    # =========================================================================
    #  5. ROUTING
    # =========================================================================
    P.append('<section class="break"><div class="sec"><div class="num">&sect;5</div>'
             '<h2>Where the routes go</h2><p class="sub">This door has four addressable '
             'surfaces and is the most linked-to destination in the parenting stage. Derived '
             'from the code, not from reading the screens.</p></div><div class="stack">')
    surf = [('Door 1', d1['label'], d1['surfaceId']),
            ('Door 2', d2['label'], d2['surfaceId']),
            ('On both module screens', 'Compare products / Compare any two', 'pp_compare'),
            ('Alias', 'reached only from other sections', 'pp_recos')]
    P.append('<h3>The four surfaces</h3><table><tr><th style="width:44mm">Where</th>'
             '<th style="width:56mm">The words you tap</th><th>Screen</th></tr>%s</table>'
             % ''.join('<tr><td>%s</td><td>%s</td><td>%s &rarr; %s</td></tr>'
                       % (E(a), E(b), idspan(c),
                          {'pp_product_guide': 'ProductGuideHubScreen',
                           'pp_products': 'ProductsDiscoveryScreen',
                           'pp_compare': 'ProductsCompareScreen',
                           'pp_recos': 'ProductsDiscoveryScreen'}[c])
                       for a, b, c in surf))
    P.append("""
<div class="note warn">
  <b><span class="id">pp_recos</span> and <span class="id">pp_products</span> are the same
  screen.</b><br><br>
  Two ids, one <span class="id">ProductsDiscoveryScreen</span>. Nothing on this door uses
  <span class="id">pp_recos</span> &mdash; only two content sections do, and one of them links
  to it with the label <b>&ldquo;Things worth buying, and things worth skipping&rdquo;</b>.
  That is a promise the <i>Product Guide</i> keeps and the catalogue grid does not: the
  &ldquo;what to skip&rdquo; content lives behind Door 1, and that link lands on Door 2.
</div>
""")
    by = {}
    for h in inb:
        by.setdefault(h['to'], []).append(h)
    rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                   % (idspan(h['to']), E(h['from']), E(h['ref']), E(h['label']))
                   for k in sorted(by) for h in by[k])
    P.append('<h3 style="margin-top:8pt">Every way in from the content sections</h3>'
             '<p style="font-size:8.8pt;color:var(--mute)">%d links from %d of the ten content '
             'sections. No other parenting bracket is linked to this often &mdash; which is the '
             'argument for this door being taken as seriously as the libraries, and the reason '
             'the next note matters.</p>'
             '<table><tr><th style="width:36mm">Lands on</th><th style="width:34mm">From '
             'section</th><th style="width:14mm">Page</th><th>The words you tap</th></tr>'
             '%s</table>' % (len(inb), len({h['from'] for h in inb}), rows))
    ncomp = len(by.get('pp_compare', []))
    P.append("""
<div class="note warn">
  <b>%d of those links land on an empty comparison tray.</b><br><br>
  The <span class="id">pp_compare</span> links are labelled &ldquo;Compare nasal
  aspirators&rdquo;, &ldquo;Compare nappy rash creams&rdquo;, &ldquo;Compare malish oils side by
  side&rdquo;, &ldquo;Compare swaddles&rdquo;. The comparison store starts empty and the router
  entry takes no argument, so every one of them opens
  <span class="id">ProductsCompareScreen</span> in its empty state: &ldquo;No products selected
  yet&rdquo;, and a Browse Products button.<br><br>
  Nothing is broken in the usual sense &mdash; the screen is real, the route resolves, the
  empty state is well written. The label is simply making a promise the destination cannot keep
  without being told which products to compare. The fix has a shape already used elsewhere in
  this codebase: the section router accepts
  <span class="id">pp_section/&lt;bracket&gt;/&lt;area&gt;</span>, so
  <span class="id">pp_compare/&lt;category&gt;</span> or a subcategory argument would let these
  nine links arrive pre-filled.
</div>
""" % ncomp)
    P.append('</div></section>')

    # =========================================================================
    #  6. GAPS
    # =========================================================================
    P.append('<section class="break"><div class="sec"><div class="num">&sect;6</div>'
             '<h2>What is written but not yet real</h2><p class="sub">The placeholder states, '
             'and the four things worth deciding.</p></div><div class="stack">')
    n_no_video = sum(1 for g in gs for x in g['experts'] if not x['videoId'])
    n_experts = sum(len(g['experts']) for g in gs)
    n_no_img = sum(1 for g in gs if not g['imageAsset'])
    n_no_buy = sum(1 for g in gs if not g['buyUrl'])
    P.append('<h3>Placeholders</h3><table><tr><th style="width:56mm">What</th>'
             '<th style="width:20mm">Count</th><th>How it renders today</th></tr>'
             '<tr><td>Expert videos with no video id</td><td><b>%d of %d</b></td>'
             '<td>The card says so plainly rather than pretending to be tappable. Worth knowing '
             'that Brand Studio sponsors this exact surface, so a stub here means live '
             'commercial inventory sitting on top of nothing.</td></tr>'
             '<tr><td>Guides with no product photography</td><td><b>%d of %d</b></td>'
             '<td>The category icon carries the hero. An honest placeholder beats a broken '
             'image, and a parent recognising the bottle on a shelf is worth doing properly '
             'rather than filling with stock art.</td></tr>'
             '<tr><td>Guides with no retailer link</td><td><b>%d of %d</b></td>'
             '<td>The screen builds an Amazon search from the product name, so the flow works '
             'for every guide today and a real affiliate deep link drops in later.</td></tr>'
             '<tr><td>In-app checkout</td><td><b>none</b></td>'
             '<td>A product page&rsquo;s buy action shows &ldquo;Buying &hellip; in-app '
             '&mdash; checkout opens soon.&rdquo;</td></tr></table>'
             % (n_no_video, n_experts, n_no_img, len(gs), n_no_buy, len(gs)))

    rows = ''.join('<tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td></tr>'
                   % (E(p['name']), E(p['category']),
                      ('<span style="color:var(--doc)">%s</span>' % E(w)) if w and 'category' in w
                      else E(w or '&mdash;'),
                      E(g['name']) if g else '&mdash;')
                   for p, w, g in matches if g)
    P.append("""
<h3 style="margin-top:8pt">The view chooser, and how often it fires</h3>
<p style="font-size:8.8pt;color:var(--mute)">When a parent taps a product that HAS an in-depth
Guide, the app does not guess where to send her &mdash; it asks. A two-option sheet: <b>&ldquo;How
would you like to see this?&rdquo;</b> / &ldquo;This is a product parents often research &mdash;
we can go deep, or keep it quick.&rdquo; When no Guide exists it opens the normal page with zero
friction.</p>
<table><tr><th style="width:44mm">Product</th><th style="width:26mm">Category</th>
<th style="width:52mm">Why it matched</th><th>Guide it offers</th></tr>%s</table>
<p class="tbl-note">%d of the %d catalogue products make the chooser appear.</p>
<div class="note warn">
  <b>One of those five matches is wrong, and the neighbouring one is missed &mdash; both from the
  same loose rule.</b><br><br>
  The matcher tries the product id, then a small explicit map, then a fallback: does the product
  name contain the <i>last word</i> of a guide's name, or the guide's <i>category</i> name?<br><br>
  <b>Anti-Colic Feeding Bottle</b> contains the word &ldquo;Feeding&rdquo;, which is the
  <i>category</i> of the <b>Electric Steam Sterilizer</b> guide &mdash; so tapping the bottle
  offers an in-depth guide to a steriliser.<br><br>
  And <b>Steam Steriliser</b>, the product that genuinely has that guide, matches nothing:
  the guide's last word is spelled &ldquo;Sterilizer&rdquo; with a z and the product with an s.
  A substring match across a UK/US spelling boundary fails silently.<br><br>
  Both are the same fix: match on the guide's own id or an explicit map, and let the fallback
  require a name match rather than a category one.
</div>
""" % (rows, len(fired), len(prods)))

    P.append("""
<h3 style="margin-top:8pt">The things worth deciding, gathered</h3>
<table><tr><th style="width:8mm">#</th><th style="width:62mm">What</th><th>Where</th></tr>
<tr><td>1</td><td>%d &ldquo;Compare X&rdquo; links from the content sections open an empty
comparison tray</td><td>&sect;5</td></tr>
<tr><td>2</td><td>The view chooser offers a steriliser guide for a feeding bottle, and misses
the steriliser</td><td>&sect;6</td></tr>
<tr><td>3</td><td>&ldquo;Things worth buying, and things worth skipping&rdquo; lands on the
catalogue grid, not on the Product Guide that holds the skip content</td><td>&sect;5</td></tr>
<tr><td>4</td><td>Fifteen of eighteen subcategories hold a single product</td>
<td>&sect;4</td></tr>
</table>
<p class="foot">ParentVeda &middot; What to buy door map &middot; generated 31 August 2026 by
<span class="id">tools/buying_door_map.py</span> from
<span class="id">product_guide_data.dart</span>,
<span class="id">pp_products_data.dart</span>,
<span class="id">parenting_hubs.dart</span>,
<span class="id">parenting_brackets.dart</span> and
<span class="id">pp_surface_router.dart</span>.<br>All reader-facing copy is quoted verbatim
from the source. Anything in a grey or coral box is commentary written for this document, not
text a parent sees.</p>
""" % ncomp)
    P.append('</div></section>')
    return P


if __name__ == '__main__':
    parts = render()
    P = render_rest(*parts)
    (_, hub, br, rids, gs, mapped, cats, prods, subguides, compare,
     ro_label, ro_why, inb, matches, fired) = parts
    P = render_door2(P, hub, rids, gs, cats, prods, subguides, compare,
                     ro_label, ro_why, inb, matches, fired)
    out = os.path.join(DM.DOCS, 'WHAT-TO-BUY-DOOR-MAP.html')
    with open(out, 'w', encoding='utf-8') as f:
        f.write('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
                '<title>ParentVeda &mdash; What to buy, the whole door</title>\n'
                '<style>\n%s\n</style>\n<style>\n%s\n</style>\n</head>\n<body>\n%s\n'
                '</body>\n</html>\n' % (DM.fonts_css(), DM.STYLE, ''.join(P)))
    print('%-26s %6.0f KB' % ('parenting_buying', os.path.getsize(out) / 1024))
    if '--pdf' in sys.argv:
        pdf = DM.to_pdf(out)
        print('  ->  %s' % (os.path.basename(pdf) if pdf else 'PDF FAILED'))
