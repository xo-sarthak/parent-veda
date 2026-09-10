#!/usr/bin/env python3
# =============================================================================
#  skilling_door_map.py -- the twelve skilling doors, which open nothing yet
# -----------------------------------------------------------------------------
#  ⚠️ THESE DOCUMENTS MAP A PLAN, NOT A BUILD, AND THE FORMAT HAD TO CHANGE TO
#  SAY SO.
#
#  The parenting door maps answer "what is behind this door". For skilling the
#  honest answer is "nothing, on purpose" -- eighty-four cells across twelve
#  brackets and not one live resolver. There is no hub, no PpSection, no
#  content file, no tool, no course, no expert and no screen. The doors do not
#  open bracket screens at all; each opens a sheet showing its own plan.
#
#  So writing these to the parenting template would have produced twelve
#  documents whose §3 through §7 were empty, which reads as an incomplete
#  document rather than as a complete document about an unbuilt thing. Instead
#  each one maps: the tile, the preview home it sits on, the plan sheet in
#  full, why nothing opens, and what would have to be true before it could.
#
#  ⚠️ EVERY LAYER STRING IS THE WORKBOOK'S OWN WORDING, carried through
#  unedited -- including the ten Extras cells that ask for challenges, streaks,
#  certificates and progress reports, which the product's no-scoring rule
#  refuses. Recording the conflict verbatim is the point: it keeps the decision
#  visible rather than pre-empted in either direction.
#
#  Usage:  python tools/skilling_door_map.py [--pdf]
#  Output: docs/skilling-door-maps/<SKILL>-DOOR-MAP.{html,pdf}
# =============================================================================

import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import section_doc as SD                                          # noqa: E402
import door_map as DM                                             # noqa: E402

E, idspan, chip = DM.E, DM.idspan, DM.chip
OUT_DIR = os.path.join(DM.DOCS, 'skilling-door-maps')

# The plan sheet's own headings, in the sheet's own order -- which is NOT the
# layer enum's order. Extras is hoisted above products because the workbook's
# extras cell is the one carrying the unresolved question.
SHEET_ORDER = [
    ('content', 'What this would hold'),
    ('activities', 'What they would do'),
    ('tools', 'What could be tracked'),
    ('extras', 'Beyond the six'),
    ('products', 'Things that help'),
    ('course', 'Learn it properly'),
    ('consult', 'Talk to someone'),
]

MARKS = {
    'skilling_focus': 'focus', 'skilling_confidence': 'speaking',
    'skilling_communication': 'communication', 'skilling_critical_thinking': 'reasoning',
    'skilling_values': 'character', 'skilling_maths': 'maths',
    'skilling_coding': 'coding', 'skilling_reading': 'reading',
    'skilling_creativity': 'creativity', 'skilling_emotional': 'emotions',
    'skilling_stillness': 'stillness', 'skilling_memory': 'memory',
}

SLUG = {
    'skilling_focus': 'FOCUS', 'skilling_confidence': 'CONFIDENCE',
    'skilling_communication': 'COMMUNICATION', 'skilling_critical_thinking': 'THINKING',
    'skilling_values': 'VALUES', 'skilling_maths': 'MATHS',
    'skilling_coding': 'CODING', 'skilling_reading': 'READING',
    'skilling_creativity': 'CREATIVITY', 'skilling_emotional': 'EMOTIONAL',
    'skilling_stillness': 'STILLNESS', 'skilling_memory': 'MEMORY',
}


# =============================================================================
#  LOAD
# =============================================================================

def skilling():
    path = os.path.join(DM.ROOT, 'lib', 'data', 'brackets', 'skilling_brackets.dart')
    env = SD.declarations(path)
    out = []
    for b in SD.resolve(env['kSkillingBrackets'], env):
        k = b.kwargs
        # ⚠️ `layers` IS A CALL, NOT A MAP. Every skilling bracket routes through
        # the `_skillLayers` helper, because the workbook gives twelve rows of
        # the same shape and writing it out longhand would bury the three cells
        # that actually differ. So the reasons are read off the helper's named
        # arguments, and the state is notReady by construction -- the helper
        # cannot express anything else, which is itself the guarantee.
        lay = k['layers']
        assert getattr(lay, 'name', None) == '_skillLayers', \
            '%s no longer uses _skillLayers; the state can no longer be assumed' % k['id']
        out.append({
            'id': k['id'], 'hue': k['hue'], 'theme': k['theme'],
            'label': k['label'].kwargs['en'], 'label_hi': k['label'].kwargs['hi'],
            'title': k['title'].kwargs['en'], 'title_hi': k['title'].kwargs['hi'],
            'blurb': k['blurb'].kwargs['en'], 'blurb_hi': k['blurb'].kwargs['hi'],
            'layers': dict(lay.kwargs),
        })
    return out


# The handful of cells that break the pattern. Everything else is the same
# seven strings twelve times over, so the differences are what a reader needs
# pointed out -- and each one is a real product decision hiding in a spreadsheet
# cell.
DIFFERENT = {
    'skilling_confidence': [
        ('The only bracket in the stage with a named demand signal.',
         'The workbook marks this row <b>High WTP</b> &mdash; willingness to pay &mdash; and it '
         'is the only skilling row carrying one. It is door two for that reason.<br><br>It is '
         'also the only bracket whose consult cell names a real role, <b>Speaking coach</b>, '
         'rather than the &ldquo;Rare&rdquo; that the other eleven carry. And it is the only '
         'one whose tool is not a plain rubric: <b>record &amp; self-review</b> means audio '
         'capture of a child, which brings consent and storage questions that none of the '
         'other eleven do. Worth knowing that the most sellable door is also the one with the '
         'most to settle before it can be built.'),
    ],
    'skilling_values': [
        ('The one Extras cell that is not challenges and certificates.',
         'Every other bracket&rsquo;s extras cell asks for challenges, streaks, certificates or '
         'a progress report. This one asks for <b>&ldquo;Dadi says / Science says&rdquo; '
         'forwardable cards</b> &mdash; a share format rather than a scoring format, and the '
         'only extras cell in the stage that the product&rsquo;s no-scoring rule does not '
         'collide with.<br><br>Its course cell is also worded differently: <b>the rooted layer '
         'for kids</b>. That is a positioning claim, not a description of a feature, and it is '
         'the closest this table comes to saying what would make the paid programme worth '
         'buying.'),
    ],
    'skilling_coding': [
        ('The only cell in the stage that names a competitor, and it names it as a warning.',
         'The course cell reads <b>&ldquo;Leveled program (paid) &mdash; WhiteHat Jr '
         'caution&rdquo;</b>. Its tools cell is the only one that qualifies itself: '
         '<b>&ldquo;honest, no outcome promises&rdquo;</b>.<br><br>Both are pointing at the same '
         'thing. Coding for children is the category where Indian ed-tech made promises about '
         'a child&rsquo;s future and was punished for it, and the workbook is recording, in the '
         'cell itself, that this bracket cannot be built the way that market was built. The '
         'content cell agrees: <b>unplugged first</b>, then blocks, then projects &mdash; the '
         'opposite of an outcome ladder.'),
    ],
    'skilling_reading': [
        ('The only products cell with a business model attached.',
         '<b>Book lists (affiliate)</b>. Ten of the twelve products cells say &ldquo;Optional&rdquo; '
         'and two name a workbook; this is the only one that names how it would make money.<br>'
         '<br>Its extras cell is also the only one asking for <b>streaks</b> alongside '
         'challenges, and the blurb takes a position against exactly that: book lists and '
         'challenges that build <i>the habit rather than the count</i>. The bracket contradicts '
         'its own extras cell, in its own copy, before either is built.'),
    ],
    'skilling_creativity': [
        ('Portfolio, not progress.',
         'Its tools cell is a <b>portfolio tracker</b> and its extras a <b>portfolio '
         'showcase</b> &mdash; the only pair in the stage that proposes keeping what a child '
         'made rather than measuring how well they made it. If the no-scoring question in '
         '&sect;4 is ever settled in favour of the product&rsquo;s existing rule, this is the '
         'bracket whose plan already survives it unchanged.'),
    ],
    'skilling_stillness': [
        ('Its theme is borrowed from pregnancy, and that is worth noticing.',
         'The theme string is <span class="id">garbh</span> &mdash; the same theme key Garbh '
         'Sanskar uses on the pregnancy side. Guided sitting and simple yoga for a child is '
         'genuinely adjacent to content that already exists, which makes this one of the few '
         'skilling brackets where the first version could be an adaptation rather than a '
         'ground-up build.<br><br>Its extras cell asks for <b>streaks</b>, which for a '
         'meditation practice is the most defensible use of a streak in the stage and still '
         'runs into the same rule.'),
    ],
    'skilling_maths': [
        ('The one bracket whose content names specific methods.',
         '<b>Vedic maths, abacus, mental-math drills</b>. Every other content cell describes a '
         'kind of practice; this one names three named systems, two of which carry strong '
         'claims in the Indian market. Whether ParentVeda teaches them, teaches about them, or '
         'declines is a content-authority question, and the cell does not answer it.'),
    ],
}


def render(b, all_brackets):
    P = []
    L = b['layers']

    # ---- cover ------------------------------------------------------------
    P.append("""
<section class="cover">
  <div class="kicker">ParentVeda &middot; Skilling &middot; design preview</div>
  <h1>%s,<br>the whole door.</h1>
  <p class="lede">One of twelve skilling doors. Everything behind it, which today is a plan and
  nothing else: seven declared layers, none built, and the two questions that have to be
  answered before any of them can be.</p>
  <div class="coverstat">%s</div>
  <div class="meta">
    <b>Bracket</b> &nbsp;%s &nbsp;&middot;&nbsp; hue %s &nbsp;&middot;&nbsp; theme %s
    &nbsp;&middot;&nbsp; mark %s<br>
    <b>Stage</b> &nbsp;%s &nbsp;&mdash; the fourth stage, reachable only behind %s<br>
    <b>Source</b> &nbsp;%s<br>
    <b>Screen</b> &nbsp;%s<br>
    <b>Generated</b> &nbsp;31 August 2026 by %s, from the code on %s
  </div>
</section>
""" % (E(b['title']),
       ''.join('<div><div class="n">%s</div><div class="l">%s</div></div>' % (n, l)
               for n, l in [(7, 'Layers'), (0, 'Built'), (0, 'Screens'),
                            (12, 'Sibling doors'), (2, 'Open questions')]),
       idspan(b['id']), b['hue'], E(b['theme']), idspan(MARKS[b['id']]),
       idspan('LifeStage.skilling'), idspan('kDebugMode'),
       idspan('lib/data/brackets/skilling_brackets.dart'),
       idspan('lib/screens/skilling/skilling_preview_screen.dart'),
       idspan('tools/skilling_door_map.py'), idspan('main')))

    # ---- 0. how to read ---------------------------------------------------
    P.append("""
<section class="break">
  <div class="sec"><div class="num">&sect;0</div><h2>How to read this</h2>
  <p class="sub">This is not the same document as a parenting door map, because this is not the
  same kind of door. There is nothing behind it to write out.</p></div>
  <div class="stack">
    <div class="note">
      <b>Eighty-four cells across the stage, and not one live resolver.</b><br><br>
      The other three stages had years of content sitting behind their doors before the doors
      existed &mdash; TTC&rsquo;s grid mostly <i>wired</i> screens that had already shipped.
      Skilling has nothing at all: no content file, no tool, no course, no expert, no
      screen.<br><br>
      So the bracket table is a <b>plan expressed in the same type as the others</b>, and the
      <span class="id">notReady</span> state is doing exactly the job it was added for: real,
      named, not built. Nothing may be promoted to <span class="id">live</span> without a named
      file &mdash; the same gate the pregnancy audit enforces.
    </div>
    <table>
      <tr><th style="width:20mm">Depth</th><th style="width:36mm">What it is</th><th>What it looks like on the phone</th></tr>
      <tr><td><b>L0</b></td><td>Explore drawer</td><td>A debug-only row: &ldquo;Skilling (preview)&rdquo; &mdash; the fourth stage, UI only, nothing behind the doors.</td></tr>
      <tr><td><b>L1</b></td><td>The preview home</td><td>Twelve tiles, a compass drawn empty, and two open questions.</td></tr>
      <tr><td><b>L2</b></td><td>This tile</td><td>Opens a sheet. <b>Not</b> a bracket screen &mdash; see &sect;4.</td></tr>
      <tr><td><b>L3</b></td><td>The plan sheet</td><td>The seven layers, in the workbook&rsquo;s own words, under the heading PLANNED &middot; NONE OF IT BUILT.</td></tr>
    </table>
    <div class="note">
      <b>Why there is no &ldquo;what is written but not yet real&rdquo; section here.</b><br><br>
      In a parenting door map that section lists the video slots and audio files a built page is
      waiting on. For this door <i>everything</i> is that, so a separate section would be the
      whole document repeated. &sect;3 is the list.
    </div>
  </div>
</section>
""")

    # ---- 1. tree ----------------------------------------------------------
    T = []
    T.append('L0  EXPLORE DRAWER  <i>(parenting)</i>')
    T.append(' |   <u>debug builds only -- kDebugMode</u>')
    T.append(' +-- <b>Skilling (preview)</b>')
    T.append(' |     <i>"The fourth stage, UI only -- nothing behind the doors."</i>')
    T.append(' |')
    T.append('L1   +-- <b>SKILLING PREVIEW</b>   <i>SkillingPreviewScreen -- a preview, not a home</i>')
    T.append('     |     hero: "12 skills" / "Nothing measured. Nothing ranked."')
    T.append('     |     banner: "Design preview. None of these doors opens anything yet."')
    T.append('     |')
    T.append('     +-- WHERE TO GO   <i>Twelve things worth getting good at</i>')
    for x in all_brackets:
        me = ' <b>&lt;-- this document</b>' if x['id'] == b['id'] else ''
        T.append('     |     %s %s %s%s'
                 % ('+--' if x['id'] != b['id'] else '+--',
                    DM.rp(x['label'], 16), DM.rp(x['title'], 40), me))
    T.append('     |')
    T.append('     +-- THE SPINE   <i>The compass -- twelve points, drawn unfilled</i>')
    T.append('     +-- OPEN QUESTIONS   <i>Two things to decide first</i>')
    T.append('     |')
    T.append('L2   +-- <b>%s</b>   <i>tile &middot; %s mark &middot; hue %s</i>'
             % (E(b['label']), E(MARKS[b['id']]), b['hue']))
    T.append('         |')
    T.append('L3       +-- <u>a bottom sheet showing the PLAN</u>')
    T.append('               <i>not a bracket screen -- see &sect;4</i>')
    T.append('               "%s"' % E(b['title']))
    T.append('               PLANNED  &middot;  NONE OF IT BUILT')
    for key, heading in SHEET_ORDER:
        T.append('               +-- %s %s' % (DM.rp(heading, 24), E(L[key])))
    fs = DM.tree_font(T)
    P.append('<section class="break"><div class="sec"><div class="num">&sect;1</div>'
             '<h2>The whole door, in one tree</h2><p class="sub">Four levels, and the last one '
             'is a sheet rather than a screen. Red marks the two places where this stage '
             'deliberately stops short.</p></div><div class="tree" style="font-size:%.2fpt">%s'
             '</div></section>' % (fs, '\n'.join(T)))

    # ---- 2. the tile and the home ----------------------------------------
    P.append("""
<section class="break">
  <div class="sec"><div class="num">&sect;2 &middot; L1 &rarr; L2</div>
  <h2>The tile, and the home it sits on</h2>
  <p class="sub">Shared context: every skilling door opens from the same preview screen, and
  the screen&rsquo;s copy is what tells a reviewer that none of this is real.</p></div>
  <div class="stack">
    <div class="lvl keep"><div class="hd"><span class="lb">L1 &middot; HERO</span>
    <h4>SKILLING &middot; DESIGN PREVIEW</h4></div>
    <p class="intro">12 skills</p>
    <p class="blurb"><b>Under it:</b> Nothing measured. Nothing ranked.</p>
    <p class="blurb">Twelve things a child can get better at, and a place to practise each
    one.</p>
    <p class="route">The stage&rsquo;s accent is indigo (hue 258) rather than a borrowed stage
    colour &mdash; the other three run rose for TTC, violet for pregnancy and the phase hue for
    parenting, and a fourth stage arriving in one of those would read as a section of that
    stage rather than as its own place.</p></div>

    <div class="callout doc"><span class="ct">The banner, on screen</span>Design preview. None of
    these doors opens anything yet &mdash; tapping one shows what is planned behind it.</div>

    <div class="lvl keep"><div class="hd"><span class="lb">L1 &middot; THE SPINE</span>
    <h4>The compass</h4></div>
    <p class="blurb">The workbook puts a &ldquo;child capability profile&rdquo; at the centre of
    this stage &mdash; where the child stands, and what to practise next.</p>
    <p class="blurb">Drawn empty on purpose. Filling these arcs by ability would be a score, and
    this app does not score children. What it can honestly show later is which skills have been
    practised &mdash; never how well.</p>
    <p class="route">Twelve points, evenly spaced, none emphasised. Every other stage&rsquo;s
    hero shows a position on its spine; this one cannot, because the obvious rendering &mdash;
    filled arcs, a radar chart, a set of bars &mdash; <b>is a score for a child</b>. The
    parenting Development area already refused a progress bar for exactly this, and its door
    mark had to be redrawn from a bar chart to stepping stones.</p></div>

    <div class="rule"></div>
    <h3>This door&rsquo;s tile</h3>
    <div class="lvl keep"><div class="hd"><span class="lb">L2 &middot; TILE</span>
    <h4>%(label)s</h4></div>
    <p class="intro">%(title)s</p>
    <p class="blurb">%(blurb)s</p>
    <p class="route">mark <span class="id">%(mark)s</span> &middot; hue %(hue)s &middot; theme
    <span class="id">%(theme)s</span> &middot; id <span class="id">%(id)s</span></p></div>

    <div class="note">
      <b>The Hindi on this tile is Devanagari, and that is a deliberate break from TTC.</b><br><br>
      Label <b>%(label_hi)s</b> &middot; title <b>%(title_hi)s</b><br><br>
      TTC&rsquo;s bracket table is Hinglish because that whole stage&rsquo;s chrome is Hinglish,
      and mixing scripts inside one shell is worse than either choice made consistently.
      Skilling has no legacy: nothing to be consistent with, so it starts where the house style
      is going rather than where it has been.<br><br>
      Worth noting against the standing policy that new copy is English-only &mdash; this table
      predates it, the Hindi already ships, and it stays.
    </div>
  </div>
</section>
""" % dict(label=E(b['label']), title=E(b['title']), blurb=E(b['blurb']),
           mark=E(MARKS[b['id']]), hue=b['hue'], theme=E(b['theme']), id=E(b['id']),
           label_hi=E(b['label_hi']), title_hi=E(b['title_hi'])))
    return P, T


# The gate each layer has to pass before it may stop being a plan. Shared,
# because the workbook gives every bracket the same seven, and the gate is a
# property of the LAYER rather than of the skill.
GATES = {
    'content': ('A named content file, authored to the block model',
                'The same shape the ten parenting sections use: a section with areas, pages '
                'and typed blocks. Nothing may be promoted to live without a named file &mdash; '
                'the gate that stops a bracket table claiming depth it does not have.'),
    'activities': ('An activity set with a real age band',
                   'Parenting&rsquo;s activity engine already exists and is developmental '
                   'rather than skill-specific, so this is an extension of a real thing rather '
                   'than a new one. The band boundaries are the work.'),
    'tools': ('A tracker that does not score a child',
              'This is the layer the second open question decides. A rubric that rates a child '
              'against a level is a score; a record of what was practised is not. Until that is '
              'settled the tool cannot be specified, let alone built.'),
    'products': ('Supply, and a stance on affiliate revenue',
                 'The parenting Product Guide is the pattern: say what to skip as readily as '
                 'what to buy. A workbook sold against a child&rsquo;s skill level would fail '
                 'that test the moment the level is a score.'),
    'course': ('A named programme, a price, and someone to teach it',
               'Every parenting course surface routes through the booking engine, so this is '
               'wiring rather than invention &mdash; but the programme itself does not exist, '
               'and &ldquo;levelled&rdquo; means the scoring question again.'),
    'consult': ('An expert category with real supply',
                'The consult roster resolves a role to a category; ten of fourteen parenting '
                'roles had to be seeded because the category had nobody in it. A skilling '
                'consult would start in the same place.'),
    'extras': ('The no-scoring rule, resolved',
               'Ten of the twelve extras cells in this stage ask for challenges, streaks, '
               'certificates or progress reports. The product refuses to score a child '
               'everywhere else. This cell cannot be built in either direction until somebody '
               'rules.'),
}


def render_rest(P, b, all_brackets):
    L = b['layers']

    # ---- 3. the plan sheet ------------------------------------------------
    P.append('<section class="break"><div class="sec">'
             '<div class="num">&sect;3 &middot; L3</div>'
             '<h2>The plan sheet, in full</h2><p class="sub">What tapping this tile actually '
             'shows. A bottom sheet: the title, the blurb, a hairline reading <b>PLANNED '
             '&middot; NONE OF IT BUILT</b>, and then the seven layers under headings written '
             'for a reader rather than for the workbook.</p></div><div class="stack">')
    P.append('<div class="lvl keep"><div class="hd"><span class="lb">SHEET HEAD</span>'
             '<h4>%s</h4></div><p class="intro">%s</p>'
             '<p class="route">%s</p></div>'
             % (E(b['title']), E(b['blurb']),
                chip('PLANNED &middot; NONE OF IT BUILT', 'r')))
    for key, heading in SHEET_ORDER:
        P.append('<div class="blk"><div class="blkh">%s &mdash; the %s layer</div>'
                 '<p class="intro">%s</p></div>'
                 % (E(heading), E(key), E(L[key])))
    P.append("""
<div class="note">
  <b>Every string above is the workbook&rsquo;s, carried through unedited.</b><br><br>
  That includes the ones the product would refuse to build as written. The alternative &mdash;
  softening a cell so the table reads consistently &mdash; would hide the disagreement in the
  one place somebody is going to look for it. A plan that has been quietly corrected is a plan
  nobody can argue with.
</div>
""")
    rows = ''.join('<tr><td><b>%s</b></td><td>%s</td><td>%s</td><td>%s</td></tr>'
                   % (E(k), chip('NOT READY', 'r'), E(L[k]), E(GATES[k][0]))
                   for k, _ in SHEET_ORDER)
    # ⚠️ WRAPPED IN `keep` SO THE TABLE DOES NOT SPLIT. Left to flow, its last
    # four rows landed alone on a fresh page in every one of the twelve
    # documents -- seven rows is small enough to move whole, and a table broken
    # across a page boundary makes a reader check whether they missed a row.
    P.append('<div class="keep"><div class="rule"></div>'
             '<h3>The same seven, as the bracket table states them</h3>'
             '<p style="font-size:8.8pt;color:var(--mute)">The sheet rewords the headings for a '
             'reader. This is the underlying table: layer, state, the workbook&rsquo;s reason, '
             'and the gate each one has to pass before it can stop being a plan.</p>'
             '<table><tr><th style="width:22mm">Layer</th><th style="width:20mm">State</th>'
             '<th style="width:56mm">Reason, verbatim</th><th>What would have to exist</th>'
             '</tr>%s</table></div>' % rows)
    P.append('</div></section>')

    # ---- 4. why nothing opens --------------------------------------------
    P.append("""
<section class="break">
  <div class="sec"><div class="num">&sect;4</div><h2>Why this door opens a sheet</h2>
  <p class="sub">Three refusals, each one written down at the moment it was made, because each
  is the kind of decision that gets quietly reversed by whoever arrives next.</p></div>
  <div class="stack">

  <div class="note">
    <b>1. The door cannot open a bracket screen, and a bracket screen would be worse than
    nothing.</b><br><br>
    A bracket screen with zero live layers renders a header and nothing else. Twelve doors onto
    twelve empty rooms is worse than no doors at all &mdash; <b>an empty room read as a promise
    is what makes an app feel abandoned</b>. So the door shows the plan instead, which is
    honest about being a plan.<br><br>
    This is also why the stage is absent from the hub registry. Its twelve areas are one picker
    behind a debug gate, not twelve hubs, and the gate stays shut until there is content behind
    the doors.
  </div>

  <div class="note">
    <b>2. The screen is called a preview, and it is reached only in debug builds.</b><br><br>
    <span class="id">SkillingHomeV3</span> would have been the symmetrical name and would have
    been a lie &mdash; the other three V3 homes open real screens. It sits behind
    <span class="id">kDebugMode</span> in the Explore drawer, beside the Brand Studio debug row
    that set the precedent, and the banner says so on screen where a reviewer sees it rather
    than in a comment where only a developer would.
  </div>

  <div class="rule"></div>
  <h3>The two questions the stage cannot start without</h3>
  <p style="font-size:8.8pt;color:var(--mute)">Both are rendered on the preview home itself,
  numbered, under the heading &ldquo;Two things to decide first&rdquo;. Both are the
  user&rsquo;s to rule on. Until then nothing is built either way, which is the cheapest place
  for an unresolved question to sit.</p>

  <div class="lvl keep"><div class="hd"><span class="lb">QUESTION 1</span>
  <h4>Who does this stage talk to?</h4></div>
  <p class="blurb">The workbook says skilling &ldquo;speaks to the child&rdquo;. Every other
  stage speaks to the parent, and so does every disclaimer, consent screen and safety line in
  the app. Addressing a child is a product decision, not a change of tone &mdash; this shell is
  written to the parent until it is made.</p>
  <p class="route">It changes consent, data handling and voice at once. The shell below is
  written to the <b>parent</b>, because that is what the app is, and the question is flagged
  rather than silently answered.</p></div>

  <div class="lvl keep"><div class="hd"><span class="lb">QUESTION 2</span>
  <h4>Do we score children here?</h4></div>
  <p class="blurb">The workbook asks for challenges, streaks, certificates and progress reports
  on almost every bracket. The product refuses to score a child anywhere else &mdash;
  Development shows the word &ldquo;Practising&rdquo;, never a percentage. Both cannot be true,
  and nothing is built either way yet.</p>
  <p class="route">This door&rsquo;s own extras cell reads <b>&ldquo;%s&rdquo;</b>, and its
  tools cell reads <b>&ldquo;%s&rdquo;</b>. Whichever way the question is settled, those two
  cells are where it lands first.</p></div>

  <div class="note warn">
    <b>The scoring question is not abstract for this door.</b><br><br>
    Ten of the twelve extras cells in this stage ask for a challenge, a streak, a certificate or
    a progress report. The parenting side has already refused this once and paid for it in
    design work &mdash; a progress bar removed, a door mark redrawn from a bar chart to stepping
    stones, and a helper (<span class="id">devWordLabel</span>) written so a word can be shown
    without a percentage.<br><br>
    So the precedent exists and points one way. What has not happened is somebody saying so for
    this stage, in writing, which is what would let seven of these cells be specified.
  </div>
  </div>
</section>
""" % (E(L['extras']), E(L['tools'])))

    # ---- 5. what makes this door different -------------------------------
    P.append('<section class="break"><div class="sec"><div class="num">&sect;5</div>'
             '<h2>Where this door differs from its eleven siblings</h2>'
             '<p class="sub">Every skilling bracket carries the identical layer pattern, '
             'because the workbook does. So the cells that <i>do not</i> match are the ones '
             'worth reading &mdash; each is a real decision hiding in a spreadsheet cell.</p>'
             '</div><div class="stack">')
    common = {'activities': 'Practice set', 'products': 'Optional',
              'course': 'Leveled program (paid)', 'consult': 'Rare',
              'extras': 'Challenges, certificates, progress report',
              'tools': 'Rubric tracker'}
    diffs = [(k, L[k], common[k]) for k in common
             if L[k].strip().lower() != common[k].strip().lower()]
    if diffs:
        P.append('<h3>Cells that break the shared pattern</h3>'
                 '<table><tr><th style="width:22mm">Layer</th>'
                 '<th style="width:58mm">This door</th><th>What the other eleven mostly say</th>'
                 '</tr>%s</table>'
                 % ''.join('<tr><td><b>%s</b></td><td>%s</td><td style="color:var(--mute)">%s'
                           '</td></tr>' % (E(k), E(v), E(c)) for k, v, c in diffs))
    else:
        P.append('<div class="note"><b>None.</b> This door carries the shared pattern in every '
                 'cell but content: the same practice set, rubric tracker, optional product, '
                 'levelled paid programme, rare consult, and the challenges-and-certificates '
                 'extras that the product refuses. It is the stage&rsquo;s default shape, '
                 'exactly.</div>')
    for h, body in DIFFERENT.get(b['id'], []):
        P.append('<div class="note"><b>%s</b><br><br>%s</div>' % (h, body))

    rows = ''.join('<tr><td>%s<b>%s</b></td><td>%s</td><td>%s</td></tr>'
                   % ('&rarr; ' if x['id'] == b['id'] else '', E(x['label']),
                      E(x['title']), E(x['layers']['content']))
                   for x in all_brackets)
    P.append('<div class="rule"></div><h3>The twelve, for orientation</h3>'
             '<p style="font-size:8.8pt;color:var(--mute)">Order is the workbook&rsquo;s. Each '
             'has its own document in this folder.</p>'
             '<table><tr><th style="width:26mm">Tile</th><th style="width:52mm">Title</th>'
             '<th>What its content layer would hold</th></tr>%s</table>' % rows)

    P.append("""
<div class="note">
  <b>One thing this stage has that the built ones did not.</b><br><br>
  Pregnancy, parenting and TTC were all mapped <i>after</i> they were built, which is why their
  door maps are mostly transcription and their findings are mostly things that had already gone
  wrong. This stage is being mapped before anything exists.<br><br>
  The practical use of that is narrow but real: the two open questions in &sect;4 are cheap to
  answer now and expensive to answer after seven layers have been built around an assumption.
  Everything else in this document is a plan, and plans are free to change.
</div>
<p class="foot">ParentVeda &middot; %s door map &middot; generated 31 August 2026 by
<span class="id">tools/skilling_door_map.py</span> from
<span class="id">skilling_brackets.dart</span>,
<span class="id">skilling_preview_screen.dart</span>,
<span class="id">v3_skill_art.dart</span> and
<span class="id">explore_drawer.dart</span>.<br>All quoted copy is verbatim from the source.
Anything in a grey or coral box is commentary written for this document, not text anyone
sees.</p>
""" % E(b['title']))
    P.append('</div></section>')
    return P


def build_one(b, all_brackets):
    P, _ = render(b, all_brackets)
    P = render_rest(P, b, all_brackets)
    os.makedirs(OUT_DIR, exist_ok=True)
    out = os.path.join(OUT_DIR, '%s-DOOR-MAP.html' % SLUG[b['id']])
    with open(out, 'w', encoding='utf-8') as f:
        f.write('<!doctype html>\n<html lang="en">\n<head>\n<meta charset="utf-8">\n'
                '<title>ParentVeda &mdash; %s, the whole door</title>\n'
                '<style>\n%s\n</style>\n<style>\n%s\n</style>\n</head>\n<body>\n%s\n'
                '</body>\n</html>\n'
                % (E(b['title']), DM.fonts_css(), DM.STYLE, ''.join(P)))
    return out


if __name__ == '__main__':
    bs = skilling()
    want_pdf = '--pdf' in sys.argv
    only = [a for a in sys.argv[1:] if not a.startswith('--')]
    for b in bs:
        if only and b['id'] not in only:
            continue
        path = build_one(b, bs)
        line = '%-28s %-34s %5.0f KB' % (b['id'], b['title'], os.path.getsize(path) / 1024)
        if want_pdf:
            pdf = DM.to_pdf(path)
            line += '  ->  %s' % (os.path.basename(pdf) if pdf else 'PDF FAILED')
        print(line)
    print('\n%d documents in %s' % (len(bs), os.path.relpath(OUT_DIR, DM.ROOT)))
