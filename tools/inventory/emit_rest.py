# =============================================================================
#  emit_rest.py -- Father mode, and the shared / commerce / platform surfaces
# -----------------------------------------------------------------------------
#      python tools/inventory/emit_rest.py
#
#  Two smaller stages in one file, because both are small and both are mostly
#  about AGREEMENTS rather than words: a father product that is thin by
#  accident, and a commerce layer whose blockers are signed experts, legal text
#  and Meta template approval rather than copy.
#
#  ⚠️ DERIVED CONTENT IS MARKED AND NOT COUNTED AS AN ASK. `father_*_derive.dart`
#  builds his scans view, his What-is-next and his Samvad mirror from HER
#  content at build time. Listing those as things to write would have the team
#  commissioning the same words twice.
# =============================================================================

import csv
import glob
import io
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(HERE))
sys.path.insert(0, HERE)
import dartparse as dp                                        # noqa: E402

OUT = os.path.join(ROOT, 'research', 'content-inventory')

IMG = 'stage,area,tap_path,item,kind,count,size_or_aspect,placeholder_now,version,source_file,notes'.split(',')
WRI = ('stage,area,tap_path,content_type,title_or_id,purpose,audience_stage,current_words,'
       'count,status,version,source_file,notes').split(',')
OTH = ('stage,area,tap_path,placeholder_type,item,count,what_is_needed_from_us,'
       'current_state,version,source_file').split(',')


def src(rel):
    return dp.strip_comments(io.open(os.path.join(ROOT, rel), encoding='utf-8').read())


def jwords(o):
    if isinstance(o, dict):
        return sum(jwords(v) for v in o.values())
    if isinstance(o, list):
        return sum(jwords(v) for v in o)
    if isinstance(o, str):
        return len(o.split())
    return 0


def write(name, header, rows):
    with open(os.path.join(OUT, name), 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print('%-22s %5d rows' % (name, len(rows)))


# =============================================================================
#  Father mode
# =============================================================================
def father():
    F = 'father'
    images, written, other = [], [], []

    daily = json.load(io.open(os.path.join(ROOT, 'lib/data/father/fatherDailyContent.json'),
                              encoding='utf-8'))
    weeks = sorted(glob.glob(os.path.join(ROOT, 'lib/data/father/journey_week_*.json')))
    wwords = sum(jwords(json.load(io.open(f, encoding='utf-8'))) for f in weeks)

    written.append([F, 'Daily', 'Father home', 'daily copy (5 fields)',
                    'fatherDailyContent.json',
                    'Intro, learn, talk-to-baby and a mission for the day', 'fallback only',
                    jwords(daily), len(daily), 'placeholder', 'shared',
                    'lib/data/father/fatherDailyContent.json',
                    '⚠️ ONE DAY EXISTS. The mother side has 259. Either his home is weekly '
                    'and this is only a fallback, or 258 days are missing. That question '
                    'changes this stage\'s ask by two orders of magnitude and the code does '
                    'not answer it.'])
    written.append([F, 'Weekly journey', 'Father home > Weekly', 'weekly copy',
                    'journey_week_04..40.json', 'What is happening this week, in his voice',
                    'weeks 4 to 40', wwords, len(weeks), 'placeholder', 'shared',
                    'lib/data/father/',
                    '%d week files holding %s words between them — about %d words a week, '
                    'against 1,200 a week on the mother side.'
                    % (len(weeks), '{:,}'.format(wwords), wwords // max(len(weeks), 1))])
    images.append([F, 'Weekly journey', 'Father home > Weekly', 'Weekly hero for his side',
                   'photo', len(weeks), 'unknown', 'blank', 'shared', 'lib/data/father/',
                   'Her week images cannot simply be reused: the Slate look is deliberately '
                   'his own.'])

    s = src('lib/data/father/father_tales.dart')
    tales = dp.entries(s, 'FatherTale')
    for st, en, b in tales:
        t = dp.text(b, 'title') or dp.text(b, 'id') or ''
        written.append([F, 'Tales', 'Father home > Tales > %s' % t, 'tale', t,
                        'A story for him to read to the baby', 'all pregnancy',
                        dp.words(b), 1, 'placeholder', 'shared',
                        'lib/data/father/father_tales.dart', ''])
        images.append([F, 'Tales', 'Father home > Tales > %s' % t, 'Tale cover art — %s' % t,
                       'illustration', 1, 'unknown', 'blank', 'shared',
                       'lib/data/father/father_tales.dart', ''])
    other.append([F, 'Tales', 'Father home > Tales', 'audio/narration',
                  '%d tales' % len(tales), len(tales),
                  'His voice reading each tale, if audio is wanted on his side', 'text only',
                  'shared', 'lib/data/father/father_tales.dart'])

    s = src('lib/data/father/father_read_data.dart')
    for st, en, b in dp.entries(s, 'ReadItem'):
        t = dp.text(b, 'title') or dp.text(b, 'id') or ''
        written.append([F, 'Reads', 'Father home > Reads > %s' % t, 'article', t,
                        'A longer piece for him', 'all pregnancy', dp.words(b), 1,
                        'placeholder', 'shared', 'lib/data/father/father_read_data.dart', ''])
        images.append([F, 'Reads', 'Father home > Reads > %s' % t, 'Cover image — %s' % t,
                       'photo', 1, 'unknown', 'blank', 'shared',
                       'lib/data/father/father_read_data.dart', ''])

    for label, rel, what in [
            ('scans view', 'lib/models/father_week_derive.dart',
             'His scans view and What-is-next'),
            ('daily mirror', 'lib/models/father_day_derive.dart',
             'His mirror of her Samvad and read-to-baby')]:
        written.append([F, 'Derived from her side', 'Father home', 'derived copy', label,
                        what, 'by week', 0, 1, 'derived-from-mother', 'shared', rel,
                        'BUILT FROM HER CONTENT AT RUN TIME. Needs no separate '
                        'commissioning — listing it as an ask would buy the same words '
                        'twice.'])

    other.append([F, 'Daily', 'Father home', 'coming-soon feature',
                  'The missing daily content', 258,
                  'A decision first: is his home daily or weekly? If daily, 258 day entries '
                  'are missing. If weekly, the 37 week files need to be four times their '
                  'current length', '1 day exists', 'shared',
                  'lib/data/father/fatherDailyContent.json'])
    other.append([F, 'Films', 'Father home > Weekly', 'video production',
                  'Films for his side', 0,
                  'A decision on whether he gets his own films or shares hers. He has a '
                  'weekly videos carousel and no catalogue', 'not defined', 'unsure',
                  'lib/screens/father/'])
    other.append([F, 'Pairing', 'pairing-code flow', 'onboarding copy',
                  'The pairing explanation', 1,
                  'The words that explain pairing to a father who was handed a code',
                  'placeholder', 'shared', 'lib/screens/father/'])

    write('father_images.csv', IMG, images)
    write('father_written.csv', WRI, written)
    write('father_other.csv', OTH, other)
    return len(tales), wwords


# =============================================================================
#  Shared, commerce and platform
# =============================================================================
def shared():
    K = 'shared'
    images, written, other = [], [], []

    # ---- brackets ----------------------------------------------------------
    for rel in sorted(glob.glob(os.path.join(ROOT, 'lib/data/brackets/*.dart'))):
        r = os.path.relpath(rel, ROOT).replace('\\', '/')
        stage = os.path.basename(rel).replace('_brackets.dart', '')
        if stage == 'skilling':
            continue                      # its own sheet -- see skilling()
        s = src(r)
        bs = dp.entries(s, 'Bracket')
        if not bs:
            continue
        written.append([K, 'Brackets — %s' % stage, '%s home > bracket picker' % stage,
                        'bracket copy', '%d brackets' % len(bs),
                        'The name and framing of every entry point in this stage', stage,
                        sum(dp.words(b) for _, _, b in bs), len(bs), 'placeholder',
                        'shared', r, ''])
        images.append([K, 'Brackets — %s' % stage, '%s home > bracket picker' % stage,
                       'Intent mark per bracket', 'icon-art', len(bs), 'square, in a well',
                       'drawn-placeholder', 'shared',
                       'lib/screens/brackets/hub/hub_intent_art.dart',
                       'Drawn in code today.'])

    # ---- hubs (older shape) ------------------------------------------------
    for rel in sorted(glob.glob(os.path.join(ROOT, 'lib/data/hubs/*.dart'))):
        r = os.path.relpath(rel, ROOT).replace('\\', '/')
        if r.endswith('ttc_hubs.dart') or r.endswith('hub_registry.dart'):
            continue                      # TTC hubs are on the TTC sheet
        s = src(r)
        cfgs = dp.entries(s, 'HubConfig')
        for st, en, b in cfgs:
            hero = dp.text(b, 'hero') or dp.text(b, 'bracketId') or ''
            slot = dp.text(b, 'heroVideoSlot')
            written.append([K, 'Hubs (older shape)', 'hub > %s' % hero, 'hub copy', hero,
                            dp.text(b, 'coreQuestion') or '', 'all stages', dp.words(b), 1,
                            'placeholder', 'old', r,
                            '%d "what do you need" options.' % dp.count(b, 'HubNeed')])
            if slot:
                images.append([K, 'Hubs (older shape)', 'hub > %s' % hero,
                               'Hub hero film', 'video', 1, '16:9', 'none-rendered', 'old', r,
                               '⚠️ DO NOT COMMISSION until someone confirms the hub shape '
                               'still ships alongside the newer doors.'])

    # ---- booking / experts -------------------------------------------------
    #
    # ⚠️ THE EXPERTS ARE NOT IN THE BOOKING CATALOGUE. `booking_catalog.dart`
    # only merges them (`mergedExperts()`); the people themselves are declared
    # in `lib/experts/`. A first pass at this emitter looked in the catalogue,
    # found nothing, and cheerfully reported "0 experts" — which is exactly the
    # kind of confident wrong number an inventory exists to prevent. Counting
    # where the data lives, not where it is used.
    experts = []
    for rel in sorted(glob.glob(os.path.join(ROOT, 'lib/experts/*.dart'))):
        r = os.path.relpath(rel, ROOT).replace('\\', '/')
        if r.endswith('expert.dart') or r.endswith('expert_link.dart'):
            continue                                  # the model, not the people
        s = src(r)
        for st, en, b in dp.entries(s, 'Expert'):
            nm = dp.text(b, 'name') or dp.text(b, 'id') or ''
            if not nm:
                continue
            experts.append(nm)
            role = (dp.text(b, 'role') or dp.text(b, 'speciality')
                    or dp.text(b, 'title') or '')
            other.append([K, 'Booking — experts', 'any stage > consult > %s' % nm,
                          'expert profile', '%s (%s)' % (nm, role) if role else nm, 1,
                          'A real practitioner: credentials, registration number, '
                          'photograph, availability and written consent to be listed',
                          'invented', 'shared', r])
            images.append([K, 'Booking — experts', 'any stage > consult > %s' % nm,
                           'Expert photograph — %s' % nm, 'avatar', 1, 'square', 'blank',
                           'shared', r, ''])
            written.append([K, 'Booking — experts', 'any stage > consult > %s' % nm,
                            'expert bio', nm, 'Who they are and why to trust them',
                            'all stages', dp.words(b), 1, 'placeholder', 'shared', r, ''])

    # ---- community ---------------------------------------------------------
    s = src('lib/data/community_data.dart')
    rooms = dp.entries(s, 'Community')
    posts = dp.entries(s, 'CommunityPost')
    written.append([K, 'Community', 'Community', 'community room name and description',
                    '%d rooms' % len(rooms),
                    'What each room is called and who it is for. Ours to write — it is the '
                    'structure of the place, not the talk inside it', 'all stages',
                    sum(dp.words(b) for _, _, b in rooms), len(rooms), 'real', 'shared',
                    'lib/data/community_data.dart',
                    'Written in both languages. This list never finishes: cohort rooms are '
                    'due-date based, so a new one is owed every month.'])
    written.append([K, 'Community', 'Community', 'community guidelines',
                    'The rules of the room',
                    'What is allowed, what is removed, who decides. Needed before the first '
                    'real post', 'all stages', 0, 1, 'placeholder', 'shared', 'unsure',
                    'Not found in the code. A health community without published rules is a '
                    'liability.'])
    images.append([K, 'Community', 'Community', 'Room icons', 'icon-art', len(rooms),
                   'square, in a well', 'blank', 'shared', 'lib/data/community_data.dart',
                   'The rooms carry a decorative emoji each, which breaks the app\'s own '
                   'no-decorative-emoji rule.'])
    other.append([K, 'Community', 'Community', 'demo data to remove',
                  '%d seed posts' % len(posts), 0,
                  'NOTHING TO WRITE. Community content comes from members. These are '
                  'prototype posts with invented authors and invented like counts — a thing '
                  'to DELETE before launch, or keep behind a demo flag',
                  'prototype seeds', 'shared', 'lib/data/community_data.dart'])
    other.append([K, 'Community', 'Community', 'moderation capacity', 'Who watches the rooms',
                  1, 'People, not content: a moderator rota, an escalation path for medical '
                  'misinformation, and a takedown process', 'not built', 'shared', 'unsure'])

    # ---- brand / sponsors --------------------------------------------------
    s = src('lib/data/promo_data.dart')
    slides = dp.entries(s, 'PromoSlide')
    images.append([K, 'Brand — launch promo', 'app open', 'Sponsor carousel artwork', 'photo',
                   len(slides), 'full-width modal', 'blank', 'shared',
                   'lib/data/promo_data.dart',
                   'Placeholder brands until real sponsors are signed.'])
    other.append([K, 'Brand — launch promo', 'app open', 'brand/sponsor',
                  '%d promo slides' % len(slides), len(slides),
                  'Signed sponsor agreements before any of this can show', 'placeholder',
                  'shared', 'lib/data/promo_data.dart'])
    partners = [f for f in os.listdir(os.path.join(ROOT, 'assets/brand/partners'))
                if f.endswith('.png')]
    images.append([K, 'Brand — partners', 'various', 'Partner logos', 'logo', len(partners),
                   'PNG', 'real-asset', 'shared', 'assets/brand/partners/',
                   'REAL FILES, but DEMO BRANDS: %s. Not signed customers.'
                   % ', '.join(sorted(x[:-4] for x in partners))])
    images.append([K, 'Brand — ParentVeda', 'app-wide', 'ParentVeda marks', 'logo', 3,
                   'transparent PNG', 'real-asset', 'shared', 'assets/brand/', 'REAL.'])

    # ---- platform ----------------------------------------------------------
    for area, path, ctype, title, purpose, rel, note in [
        ('Auth and onboarding', 'app open', 'onboarding copy', 'Sign-in, pairing, permissions',
         'The words around getting in', 'lib/screens/auth/', ''),
        ('Notifications', 'background', 'notification copy', 'Reminder and nudge text',
         'What the app says when it interrupts', 'lib/services/', ''),
        ('WhatsApp', 'WhatsApp', 'WhatsApp template', 'The message templates',
         'Meta requires pre-approved templates; variables are filled in code',
         'supabase/migrations/',
         'The words GATE the feature: templates must be submitted to and approved by Meta. '
         'The engine is already built (migrations 0015-0018).'),
        ('Legal', 'Profile > legal', 'legal/policy text',
         'Privacy, terms, medical disclaimer',
         'The documents a health app legally needs', 'unsure',
         'Lawyer-drafted, not written by us.'),
        ('Doctor app', 'doctor flavour', 'doctor-app copy', 'The ParentVeda+ doctor product',
         'A separate APK from the same repo', 'lib/doctor/', ''),
        ('Enterprise', 'HR portal', 'enterprise copy', 'The sponsor programme',
         'Employers sponsoring staff', 'lib/screens/enterprise/',
         'See docs/ENTERPRISE-HANDOFF.md. Blocked on an email provider.'),
    ]:
        written.append([K, area, path, ctype, title, purpose, 'all stages', 0, 1,
                        'placeholder', 'shared' if 'doctor' not in rel else 'new', rel, note])

    other.append([K, 'Legal', 'Profile > legal', 'legal text',
                  'Privacy, terms, medical disclaimer', 3,
                  'Lawyer-drafted documents for a health app operating in India',
                  'placeholder or absent', 'shared', 'unsure'])
    other.append([K, 'WhatsApp', 'WhatsApp', 'WhatsApp template', 'Message templates', 1,
                  'Template text submitted to and approved by Meta. MSG91 is the chosen '
                  'provider', 'not submitted', 'new', 'supabase/migrations/'])
    other.append([K, 'Fonts and type', 'app-wide', 'data source',
                  'Fraunces, Plus Jakarta, Manrope', 3,
                  'Confirmation that the licences cover commercial app distribution',
                  'in use', 'shared', 'pubspec.yaml'])

    write('shared_images.csv', IMG, images)
    write('shared_written.csv', WRI, written)
    write('shared_other.csv', OTH, other)
    return len(experts), len(rooms), len(posts)


# =============================================================================
#  Skilling -- the fourth stage, which is a DESIGN PREVIEW and not a stage yet
# =============================================================================
def skilling():
    """⚠️ ITS HONEST STATUS IS THE MOST USEFUL THING THIS SHEET CAN SAY.

    `skilling_preview_screen.dart` says it in its own header: UI only, nothing
    behind it is built, reachable only in debug from the Explore drawer, and
    its twelve doors open a sheet describing the plan rather than a screen.

    So listing twelve doors' worth of articles and films here would invent an
    ask that does not exist yet. What genuinely exists is twelve bracket
    descriptions and one preview screen; everything else is contingent on a
    decision to build the stage. The rows say that rather than implying a
    commission is due.
    """
    K = 'skilling'
    images, written, other = [], [], []
    rel = 'lib/data/brackets/skilling_brackets.dart'
    s = src(rel)
    bs = dp.entries(s, 'Bracket')
    for st, en, b in bs:
        t = dp.text(b, 'title') or dp.text(b, 'id') or ''
        written.append([K, 'The twelve skills', 'Explore (debug) > Skilling preview > %s' % t,
                        'bracket copy', t, dp.text(b, 'blurb') or '', 'children',
                        dp.words(b), 1, 'placeholder', 'new', rel,
                        'Written and shipping in the preview. The CONTENT behind this door '
                        'does not exist and is not counted here — see the note on this sheet.'])
        images.append([K, 'The twelve skills', 'Explore (debug) > Skilling preview > %s' % t,
                       'Intent mark — %s' % t, 'icon-art', 1, 'square, in a well',
                       'drawn-placeholder', 'new',
                       'lib/screens/v2/v3_skill_art.dart', ''])
    prev = 'lib/screens/skilling/skilling_preview_screen.dart'
    written.append([K, 'Preview screen', 'Explore (debug) > Skilling preview',
                    'preview copy', 'The preview itself',
                    'The hero, the unfilled compass and the banner saying nothing is built',
                    'children', dp.words(src(prev)), 1, 'placeholder', 'new', prev,
                    'The compass is drawn UNFILLED on purpose: "where a child stands across '
                    'twelve skills" rendered as arcs or bars is a SCORE FOR A CHILD, and '
                    'this product does not score children.'])
    other.append([K, 'The stage itself', 'Explore (debug) > Skilling preview',
                  'coming-soon feature', 'The whole skilling stage', 0,
                  'A BUILD DECISION BEFORE ANY CONTENT. This is a design preview: UI only, '
                  'debug-only access, and its twelve doors open a sheet describing the plan '
                  'rather than a screen. Commissioning content for twelve skills before the '
                  'stage is built would be the largest speculative order in the app',
                  'preview only, nothing behind it', 'new', prev])
    write('skilling_images.csv', IMG, images)
    write('skilling_written.csv', WRI, written)
    write('skilling_other.csv', OTH, other)
    return len(bs)


if __name__ == '__main__':
    ntales, wwords = father()
    nexp, nrooms, nposts = shared()
    nskill = skilling()
    print('skilling: %d skill doors, preview only — nothing behind them is built' % nskill)
    print('father: %d tales, %s words across the weekly files' % (ntales, '{:,}'.format(wwords)))
    print('shared: %d experts (all invented), %d community rooms, %d demo posts to delete'
          % (nexp, nrooms, nposts))
