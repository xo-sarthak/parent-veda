# =============================================================================
#  emit_ttc.py -- the Trying-to-Conceive stage's content inventory
# -----------------------------------------------------------------------------
#  Walks the seven TTC doors tile by tile, the seven read files piece by piece,
#  the film catalogue slot by slot and every seed list in `lib/ttc/`, and
#  writes the three CSVs the inventory PDFs are built from.
#
#      python tools/inventory/emit_ttc.py
#
#  ⚠️ EVERY NUMBER IS PARSED, NONE IS TYPED. The first pass at this inventory
#  was written by hand from greps and undercounted the parenting stage's films
#  by an order of magnitude, because films are declared inside content pages
#  rather than in a film list. A parser finds those; a person reading the app
#  does not.
#
#  ⚠️ TAP PATHS ARE BUILT FROM THE DATA, NOT WRITTEN DOWN. A door's tab labels
#  and section headings come from the focus page itself, so a renamed tab
#  renames every row under it on the next run instead of leaving the brief
#  quietly describing a screen that no longer exists.
# =============================================================================

import csv
import io
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import dartparse as dp                                        # noqa: E402

OUT = os.path.join(ROOT, 'research', 'content-inventory')
S = 'ttc'

IMG = 'stage,area,tap_path,item,kind,count,size_or_aspect,placeholder_now,version,source_file,notes'.split(',')
WRI = ('stage,area,tap_path,content_type,title_or_id,purpose,audience_stage,current_words,'
       'count,status,version,source_file,notes').split(',')
OTH = ('stage,area,tap_path,placeholder_type,item,count,what_is_needed_from_us,'
       'current_state,version,source_file').split(',')

images, written, other = [], [], []


def src(rel):
    return dp.strip_comments(io.open(os.path.join(ROOT, rel), encoding='utf-8').read())


def raw(rel):
    return io.open(os.path.join(ROOT, rel), encoding='utf-8').read()


# -----------------------------------------------------------------------------
#  The seven doors
# -----------------------------------------------------------------------------
DOORS = [
    ('ttc_focus_conceiving.dart', 'Conceiving & the fertile window'),
    ('ttc_focus_pcos.dart', 'PCOS'),
    ('ttc_focus_ivf.dart', 'IVF and IUI'),
    ('ttc_focus_getting_ready.dart', 'Getting ready'),
    ('ttc_focus_his_side.dart', 'His side'),
    ('ttc_focus_mind_body.dart', 'Mind and body'),
    ('ttc_focus_after_loss.dart', 'After a loss'),
]

TILE_KINDS = ['TtcArticleTile', 'TtcGuideTile', 'TtcToolTile', 'TtcVideoTile', 'TtcMythTile',
              'TtcCarouselTile', 'TtcMasterclassTile', 'TtcTalkTile', 'TtcDoTile',
              'TtcCommunityTile', 'TtcBookingTile', 'TtcProductTile', 'TtcInfographicTile',
              'TtcDoorTile', 'TtcRecipeTile', 'TtcChecklistTile']

FORMAT_NAME = {
    'TtcArticleTile': 'article', 'TtcGuideTile': 'guide', 'TtcToolTile': 'tool',
    'TtcVideoTile': 'video', 'TtcMythTile': 'myth vs fact', 'TtcCarouselTile': 'carousel',
    'TtcMasterclassTile': 'course', 'TtcTalkTile': 'talk', 'TtcDoTile': 'do',
    'TtcCommunityTile': 'community', 'TtcBookingTile': 'booking',
    'TtcProductTile': 'product', 'TtcInfographicTile': 'infographic',
    'TtcDoorTile': 'door', 'TtcRecipeTile': 'recipe', 'TtcChecklistTile': 'checklist',
}

read_index = {}          # read id -> (file, body)
door_rail_tiles = 0
door_tiles_total = 0


def load_reads():
    for f in sorted(os.listdir(os.path.join(ROOT, 'lib/ttc/reads'))):
        if not f.endswith('.dart'):
            continue
        rel = 'lib/ttc/reads/' + f
        s = src(rel)
        for st, en, b in dp.entries(s, 'PvRead'):
            rid = dp.text(b, 'id')
            if rid:
                read_index[rid] = (rel, b)


def door_rows():
    """One pass per door: tabs, sections, tiles."""
    global door_rail_tiles, door_tiles_total
    for fname, door in DOORS:
        rel = 'lib/ttc/focus/' + fname
        s = src(rel)
        page = dp.entries(s, 'TtcFocusPage')
        page_body = page[0][2] if page else s

        # tab labels, in order
        tabs = {}
        for st, en, g in dp.entries(s, 'TtcFocusGroup'):
            tabs[dp.text(g, 'id')] = dp.text(g, 'label')

        hero = dp.text(page_body, 'heroImageUrl')
        if hero:
            images.append([S, 'Doors — %s' % door, 'TTC home > %s' % door,
                           'Door hero photograph', 'photo', 1,
                           '900x700 crop, shown about 16:10',
                           'unsplash-url' if 'unsplash' in hero else 'real-asset',
                           'v3', rel,
                           'The picture at the top of the door. Sets the tone before a word '
                           'is read; every one is a stock placeholder chosen for mood.'])

        closing = dp.text(page_body, 'closingLine')
        if closing:
            written.append([S, 'Doors — %s' % door, 'TTC home > %s > foot of the page' % door,
                            'closing line', 'closing line', 'The one sentence the door ends on',
                            door, len(closing.split()), 1, 'placeholder', 'v3', rel, ''])

        head = dp.entries(page_body, 'TtcMasterclassTile')
        # sections
        for st, en, sec in dp.entries(s, 'TtcFocusSection'):
            heading = dp.text(sec, 'heading') or '(no heading)'
            group = dp.text(sec, 'group')
            tab = tabs.get(group, group or '')
            base = 'TTC home > %s > %s > %s' % (door, tab, heading)
            for kind in TILE_KINDS:
                for tst, ten, t in dp.entries(sec, kind):
                    title = dp.text(t, 'title') or ''
                    blurb = dp.text(t, 'blurb') or ''
                    fmt = FORMAT_NAME[kind]
                    door_tiles_total_inc()
                    path = '%s > %s' % (base, title)

                    # --- the card face -------------------------------------
                    images.append([S, 'Doors — %s' % door, path,
                                   'Rail card art for "%s" [%s]' % (title, fmt),
                                   'illustration', 1, '142x176 rail card',
                                   'drawn-placeholder', 'v3', rel,
                                   'Flat tinted block today. One per tile.'])

                    # --- the card copy -------------------------------------
                    written.append([S, 'Doors — %s' % door, path, 'tile copy (title + blurb)',
                                    title, blurb[:180], door,
                                    len((title + ' ' + blurb).split()), 1,
                                    'placeholder', 'v3', rel,
                                    'The words on the card, which decide whether anything '
                                    'behind it gets opened.'])

                    # --- per-format extras ---------------------------------
                    if kind == 'TtcCarouselTile':
                        cards = dp.count(t, 'TtcCarouselCard')
                        images.append([S, 'Doors — %s' % door, path,
                                       'Carousel card art — "%s"' % title, 'carousel-card',
                                       cards, 'full-width swipe card', 'drawn-placeholder',
                                       'v3', rel, '%d cards in this carousel.' % cards])
                        written.append([S, 'Doors — %s' % door, path, 'carousel-card-copy',
                                        title, 'A headline and a line per card', door,
                                        dp.words(t), cards, 'placeholder', 'v3', rel, ''])
                    if kind == 'TtcInfographicTile':
                        written.append([S, 'Doors — %s' % door, path, 'infographic-copy',
                                        title, dp.text(t, 'headline') or '', door,
                                        dp.words(t), 1, 'placeholder', 'v3', rel,
                                        'Two columns of facts, plus a reviewer name.'])
                    if kind == 'TtcMythTile':
                        written.append([S, 'Doors — %s' % door, path, 'myth-fact',
                                        title, 'Myth: %s' % (dp.text(t, 'myth') or '')[:120],
                                        door, dp.words(t), 1, 'clinical-review-owed', 'v3', rel,
                                        'A claim and its correction. Wrong here is worse than '
                                        'silent, so it needs a clinician.'])
                    if kind == 'TtcVideoTile':
                        slot = dp.text(t, 'slotId')
                        images.append([S, 'Films', path,
                                       'Film for "%s"' % title, 'video', 1, '16:9',
                                       'none-rendered', 'v3', rel,
                                       'Slot id %s. See the Films rows for length and '
                                       'chapters.' % slot])
    return


def door_tiles_total_inc():
    global door_tiles_total
    door_tiles_total += 1


# -----------------------------------------------------------------------------
#  Reads
# -----------------------------------------------------------------------------
DOOR_OF_FILE = {
    'ttc_reads_conceiving.dart': 'Conceiving & the fertile window',
    'ttc_reads_pcos.dart': 'PCOS',
    'ttc_reads_ivf.dart': 'IVF and IUI',
    'ttc_reads_getting_ready.dart': 'Getting ready',
    'ttc_reads_his_side.dart': 'His side',
    'ttc_reads_mind_body.dart': 'Mind and body',
    'ttc_reads_after_loss.dart': 'After a loss',
}


def read_rows():
    for rid, (rel, b) in read_index.items():
        door = DOOR_OF_FILE.get(os.path.basename(rel), 'TTC')
        title = dp.text(b, 'title') or rid
        teaser = dp.text(b, 'teaser') or ''
        author = dp.text(b, 'author') or ''
        role = dp.text(b, 'authorRole') or ''
        secs = dp.count(b, 'PvReadSection')
        faqs = dp.count(b, 'PvReadFaq')
        w = dp.words(b)
        ev = 'evidence' if dp.arg(b, 'evidence') else 'NO EVIDENCE LINE'
        hero = dp.text(b, 'heroVideoSlot')
        written.append([S, 'Doors — %s' % door,
                        'TTC home > %s > (article or guide card) > %s' % (door, title),
                        'read/article', title, teaser[:200], door, w, 1,
                        'clinical-review-owed', 'v3', rel,
                        '%d sections, %d FAQs. Byline "%s, %s". %s.%s'
                        % (secs, faqs, author, role, ev,
                           ' Hero film slot %s.' % hero if hero else '')])
        # the red flag every read must carry
        if dp.arg(b, 'whenToSeeSomeone'):
            written.append([S, 'Doors — %s' % door,
                            'TTC home > %s > %s > foot of the piece' % (door, title),
                            'red-flag callout', 'When to see someone — %s' % title,
                            'The sentence that says stop reading and call somebody',
                            door, 0, 1, 'clinical-review-owed', 'v3', rel,
                            'Required on every read. The highest-consequence copy in the '
                            'app: it must be doctor-written, not doctor-reviewed.'])
        if faqs:
            written.append([S, 'Doors — %s' % door,
                            'TTC home > %s > %s > questions' % (door, title),
                            'faq', 'FAQs — %s' % title,
                            'The questions she was too embarrassed to type', door, 0, faqs,
                            'clinical-review-owed', 'v3', rel, ''])


# -----------------------------------------------------------------------------
#  Films
# -----------------------------------------------------------------------------
def film_rows():
    rel = 'lib/ttc/ttc_videos_data.dart'
    s = src(rel)
    slots = dp.entries(s, 'PvVideoSlot')
    for st, en, b in slots:
        vid = dp.text(b, 'id')
        title = dp.text(b, 'title') or vid
        why = dp.text(b, 'why') or ''
        secs = int(dp.number(b, 'seconds') or 0)
        chapters = dp.count(b, 'PvVideoChapter')
        takeaways = dp.count(b, 'PvVideoTakeaway') or len(
            dp.split_args(dp.arg(b, 'takeaways') or ''))
        expert = dp.text(b, 'expert') or ''
        role = dp.text(b, 'expertRole') or ''
        live = 'real-asset' if dp.arg(b, 'url') else 'none-rendered'
        images.append([S, 'Films', 'TTC home > (any door) > video card > %s' % title,
                       'Film: %s' % title, 'video', 1, '16:9, %d min %02d s' % (secs // 60, secs % 60),
                       live, 'v3', rel,
                       '%d chapters already written. On camera: %s, %s. %s'
                       % (chapters, expert or 'unnamed', role or 'role unstated', why[:110])])
        images.append([S, 'Films', 'TTC home > (any door) > video card > %s' % title,
                       'Poster frame for "%s"' % title, 'video-thumbnail', 1, '16:9',
                       'none-rendered', 'v3', rel,
                       'Needed before the film exists, so the card stops looking empty.'])
        written.append([S, 'Films', 'TTC home > (any door) > video card > %s' % title,
                        'video-script', title, why[:180], 'TTC', dp.words(b), 1,
                        'placeholder', 'v3', rel,
                        'Chapters and takeaways are written; a shootable script is not. '
                        'Expert named as "%s" — invented.' % expert])
        other.append([S, 'Films', 'TTC home > (any door) > video card > %s' % title,
                      'film production', title, 1,
                      'Shoot or licence this film (%d min %02d s) and host it ourselves. '
                      'YouTube is systemically blocked for this product.'
                      % (secs // 60, secs % 60),
                      'script and chapters written, no footage', 'v3', rel])
        other.append([S, 'Films', 'TTC home > (any door) > video card > %s' % title,
                      'expert profile', '%s (%s)' % (expert, role), 1,
                      'A real clinician willing to appear on camera, with credentials and '
                      'consent', 'invented name', 'v3', rel])
    return len(slots), sum(int(dp.number(b, 'seconds') or 0) for _, _, b in slots)


# -----------------------------------------------------------------------------
#  Seed lists
# -----------------------------------------------------------------------------
def seed_rows():
    specs = [
        # file, ctor, area, tap path, content type, what it is, needs-image
        ('lib/ttc/ttc_products_data.dart', 'TtcProduct', 'Shop', 'TTC home > Shop',
         'product-blurb', 'What it is, the evidence, and what it costs', True,
         'product entry',
         'Real SKU, brand, MRP, retailer link, and photography'),
        ('lib/ttc/ttc_prepare_data.dart', 'TtcOffering', 'Paid services',
         'TTC home > Prepare', 'offering-blurb',
         'A paid consult, course, class or assessment', False, 'paid offering',
         'A real expert, a real syllabus, a real price and cancellation terms'),
        ('lib/ttc/ttc_trackers_data.dart', 'TtcTracker', 'Trackers', 'TTC home > Tools',
         'tracker-copy', 'Field labels, the why-it-matters note and the empty state',
         False, 'tracker definition',
         'Confirmation that the fields and units are clinically right'),
        ('lib/ttc/ttc_practice_data.dart', 'TtcPractice', 'Practices',
         'TTC home > Mind and body > practice', 'practice-script',
         'The spoken script for a practice', False, 'practice audio',
         'A voice recording of this script, calm register, plus a bed track'),
        ('lib/ttc/ttc_tests_data.dart', 'TtcTest', 'Test library',
         'TTC home > Tools > Tests', 'test explainer',
         'What the test is, why, when, what it costs and how to read it', False,
         'data source', 'Current INR lab pricing for three or four metros, refreshed'),
        ('lib/ttc/ttc_can_i_data.dart', 'TtcCanI', 'Can I…?', 'TTC home > Can I…?',
         'can-i entry', 'Is this safe while trying', False, None, None),
        ('lib/ttc/ttc_vaccines_data.dart', 'TtcVaccine', 'Vaccines',
         'TTC home > Tools > Vaccinations', 'vaccine explainer',
         'Pre-conception vaccination guidance', False, 'data source',
         'The schedule verified against the current official publication'),
        ('lib/ttc/ttc_milestones.dart', 'TtcMilestone', 'Journey map',
         'TTC home > Journey map', 'milestone copy', 'A stop on the journey map',
         False, None, None),
        ('lib/ttc/ttc_partner_data.dart', 'TtcMission', 'Partner',
         'TTC home > Partner', 'mission copy', 'Something asked of him this week',
         False, None, None),
        ('lib/ttc/ttc_precheck_data.dart', 'PrecheckItem', 'Before you start',
         'TTC home > Getting ready > Before you start', 'precheck question',
         'One item on the pre-conception checklist', False, None, None),
        ('lib/ttc/ttc_pcos_check_data.dart', 'PcosCheckerQuestion', 'Tools — PCOS',
         'TTC home > PCOS > Where do I stand', 'tool question',
         'One question in the PCOS self-read', False, None, None),
        ('lib/ttc/ttc_symptom_data.dart', 'TtcSymptomGroup', 'Symptoms',
         'TTC home > log a symptom', 'symptom group',
         'A group of things she can log and what they may mean', False, None, None),
    ]
    for rel, ctor, area, path, ctype, purpose, needs_img, otype, oneed in specs:
        full = os.path.join(ROOT, rel)
        if not os.path.exists(full):
            continue
        s = src(rel)
        entries = dp.entries(s, ctor)
        for st, en, b in entries:
            eid = dp.text(b, 'id') or ''
            title = (dp.text(b, 'name') or dp.text(b, 'nameEn') or dp.text(b, 'title')
                     or dp.text(b, 'titleEn') or dp.text(b, 'label') or dp.text(b, 'question')
                     or eid)
            w = dp.words(b)
            clinical = ctype in ('test explainer', 'can-i entry', 'vaccine explainer',
                                 'tool question', 'symptom group')
            written.append([S, area, '%s > %s' % (path, title), ctype, title, purpose,
                            'all TTC', w, 1,
                            'clinical-review-owed' if clinical else 'placeholder',
                            'v3', rel, ''])
            if needs_img:
                images.append([S, area, '%s > %s' % (path, title),
                               'Product photography — %s' % title, 'product-image', 1,
                               'unknown', 'drawn-placeholder', 'v3', rel,
                               'Drawn stand-in today.'])
            if otype:
                other.append([S, area, '%s > %s' % (path, title), otype, title, 1,
                              oneed, 'placeholder', 'v3', rel])
    return


def daily_rows():
    rel = 'lib/ttc/ttc_daily_data.dart'
    s = src(rel)
    for ctor, label, purpose in [
            ('TtcInsight', 'daily-insight', 'A line on the daily rail'),
            ('TtcMyth', 'myth-fact', 'A myth and its correction, on the rail'),
            ('TtcJournalPrompt', 'journal prompt', 'Something to write about'),
            ('TtcNutrition', 'nutrition note', 'A food note for the day')]:
        entries = dp.entries(s, ctor)
        if not entries:
            continue
        w = sum(dp.words(b) for _, _, b in entries)
        written.append([S, 'Daily home', 'TTC home > daily rail', label,
                        '%d %s entries' % (len(entries), label), purpose, 'all TTC, by phase',
                        w, len(entries), 'placeholder', 'v3', rel,
                        'The rail repeats once these run out, so volume matters more than '
                        'length here.'])


def tool_rows():
    tools = [
        ('Where do I stand', 'TTC home > PCOS > Where do I stand',
         'lib/ttc/ttc_pcos_stand.dart',
         'What her answers mean, band by band, without ever naming a diagnosis'),
        ('Check my readiness', 'TTC home > IVF and IUI > Check my readiness',
         'lib/ttc/ttc_ivf_readiness.dart',
         'Whether a conversation with a clinic is worth having. Never a score'),
        ('Read your semen report', 'TTC home > His side > Read your semen report',
         'lib/ttc/ttc_semen_reading.dart',
         'His report read back in plain English. Five routes, never a verdict'),
        ('Cycle report', 'TTC home > Cycle report', 'lib/ttc/ttc_cycle_report.dart',
         'What the report says, including the three states where it refuses to draw a cycle'),
        ('Fertility help', 'TTC home > Tools > Should I get help',
         'lib/ttc/ttc_fertility_help_rules.dart',
         'A readiness read, never a probability'),
    ]
    for name, path, rel, purpose in tools:
        if not os.path.exists(os.path.join(ROOT, rel)):
            continue
        s = src(rel)
        written.append([S, 'Tools', path, 'tool-outcome copy', name, purpose, 'all TTC',
                        dp.words(s), 1, 'clinical-review-owed', 'v3', rel,
                        'Every sentence a self-assessment shows is clinical copy, whatever '
                        'the screen calls itself.'])


def hub_rows():
    rel = 'lib/data/hubs/ttc_hubs.dart'
    s = src(rel)
    for st, en, b in dp.entries(s, 'HubConfig'):
        bid = dp.text(b, 'bracketId') or ''
        hero = dp.text(b, 'hero') or bid
        slot = dp.text(b, 'heroVideoSlot')
        needs = dp.count(b, 'HubNeed')
        written.append([S, 'Hubs (older shape)', 'TTC hub > %s' % hero, 'hub copy', hero,
                        dp.text(b, 'coreQuestion') or '', 'all TTC', dp.words(b), 1,
                        'placeholder', 'old', rel,
                        '%d "what do you need" options. The hub shape predates the doors.'
                        % needs])
        if slot:
            images.append([S, 'Hubs (older shape)', 'TTC hub > %s' % hero,
                           'Hub hero film — %s' % (dp.text(b, 'heroVideoTitle') or slot),
                           'video', 1, '16:9', 'none-rendered', 'old', rel,
                           '⚠️ DO NOT COMMISSION until someone confirms the hubs still ship. '
                           'Slot id %s is not in the film catalogue.' % slot])


def community_rows():
    rel = 'lib/data/community_data.dart'
    s = src(rel)
    rooms = [b for _, _, b in dp.entries(s, 'Community')
             if (dp.text(b, 'id') or '').startswith('ttc_')]
    other.append([S, 'Community', 'TTC home > Community', 'community room',
                  '%d TTC rooms' % len(rooms), len(rooms),
                  'Room names and descriptions only — the posts come from members. Cohort '
                  'rooms need a new one on a schedule',
                  'written, in both languages', 'shared', rel])
    images.append([S, 'Community', 'TTC home > Community', 'Room icons', 'icon-art',
                   len(rooms), 'square, in a well', 'blank', 'shared', rel,
                   'The rooms carry a decorative emoji today, which breaks the app\'s own '
                   'no-emoji rule.'])


def governance_rows():
    clinical = sum(1 for r in written if r[9] == 'clinical-review-owed')
    other.append([S, 'Clinical governance', 'every clinical surface in TTC',
                  'clinical review', '%d surfaces awaiting a clinician' % clinical, clinical,
                  'A named doctor to review and SIGN every clinical surface, and to be '
                  'credited. Several reads already carry a byline and a review date for a '
                  'review that has not happened — that is worse than no byline',
                  'AI-written, bylines asserted', 'v3', 'lib/ttc/'])


def write(name, header, rows):
    p = os.path.join(OUT, name)
    with open(p, 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    total = sum((int(r[5]) if str(r[5]).isdigit() else 1) for r in rows) if rows else 0
    print('%-20s %5d rows' % (name, len(rows)))
    return total


if __name__ == '__main__':
    load_reads()
    door_rows()
    read_rows()
    nfilm, nsec = film_rows()
    seed_rows()
    daily_rows()
    tool_rows()
    hub_rows()
    community_rows()
    governance_rows()

    write('ttc_images.csv', IMG, images)
    write('ttc_written.csv', WRI, written)
    write('ttc_other.csv', OTH, other)
    words = sum(int(r[7]) for r in written if str(r[7]).isdigit())
    print('reads: %d | door tiles: %d | films: %d (%d min) | words of placeholder: %s'
          % (len(read_index), door_tiles_total, nfilm, nsec // 60, '{:,}'.format(words)))
