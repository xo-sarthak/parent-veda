# =============================================================================
#  emit_preg.py -- the Pregnancy (mother side) content inventory
# -----------------------------------------------------------------------------
#      python tools/inventory/emit_preg.py
#
#  ⚠️ THIS STAGE IS THE ONE THAT IS LARGELY FINISHED, AND THE INVENTORY HAS TO
#  SAY SO. The weekly spine and the daily content are real, shipped, and in two
#  languages -- roughly 380,000 words of them. An inventory that lists them
#  next to genuine placeholders as though both need writing would send a team
#  to rewrite the best thing in the product.
#
#  So `status` is `real` for the JSON content and the baby illustrations, and
#  the counts on the summary page separate "already real" from "still
#  placeholder" for exactly this reason.
#
#  ⚠️ AND THE NARRATION NUMBER IS THE ONE TO GET RIGHT. The manifest lists
#  every passage the app can speak; the staged folder holds what has actually
#  been recorded. Reporting the manifest alone would say the audio is done.
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
S = 'preg'

IMG = 'stage,area,tap_path,item,kind,count,size_or_aspect,placeholder_now,version,source_file,notes'.split(',')
WRI = ('stage,area,tap_path,content_type,title_or_id,purpose,audience_stage,current_words,'
       'count,status,version,source_file,notes').split(',')
OTH = ('stage,area,tap_path,placeholder_type,item,count,what_is_needed_from_us,'
       'current_state,version,source_file').split(',')

images, written, other = [], [], []


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


# -----------------------------------------------------------------------------
#  The weekly spine and the daily content -- both REAL
# -----------------------------------------------------------------------------
def json_rows():
    wc = json.load(io.open(os.path.join(ROOT, 'lib/data/weekContent.json'), encoding='utf-8'))
    hi = json.load(io.open(os.path.join(ROOT, 'lib/data/weekContent.hinglish.json'),
                           encoding='utf-8'))
    fields = [k for k in wc[0].keys() if k not in ('week', 'audioEnabled')]
    weeks = sorted(x.get('week') for x in wc if x.get('week'))
    written.append([S, 'Weekly content', 'Home > this week', 'week-content (%d fields)'
                    % len(fields), 'weekContent.json',
                    'The spine of the product: %s' % ', '.join(fields[:8]),
                    'weeks %d to %d' % (weeks[0], weeks[-1]), jwords(wc), len(wc),
                    'real', 'shared', 'lib/data/weekContent.json',
                    'REAL AND SHIPPING. %d weeks. This is the quality bar for the rest of '
                    'the app, and the thing most at risk from a careless rewrite.' % len(wc)])
    written.append([S, 'Weekly content', 'Home > this week (Hindi)', 'week-content, Devanagari',
                    'weekContent.hinglish.json', 'The Hindi twin of the weekly spine',
                    'weeks %d to %d' % (weeks[0], weeks[-1]), jwords(hi), len(hi),
                    'real', 'shared', 'lib/data/weekContent.hinglish.json',
                    'REAL. Shipped Hindi is shipped product — it must not be stripped.'])

    files = sorted(glob.glob(os.path.join(ROOT, 'lib/data/home/week_*.json')))
    per = {}
    days = 0
    total = 0
    for f in files:
        d = json.load(io.open(f, encoding='utf-8'))
        days += len(d)
        total += jwords(d)
        for it in d:
            for k, v in it.items():
                per[k] = per.get(k, 0) + jwords(v)
    split = ', '.join('%s %s' % (k, '{:,}'.format(v))
                      for k, v in sorted(per.items(), key=lambda kv: -kv[1]) if v)
    written.append([S, 'Daily home', 'Home (daily briefing)', 'daily-moment (6 fields per day)',
                    'lib/data/home/week_04..40.json',
                    'Seven days a week of baby learning, grow, read-to-baby, talk-to-baby, '
                    'Garbh Sanskar and nurture', 'weeks 4 to 40, %d days' % days,
                    total, days, 'real', 'shared', 'lib/data/home/',
                    'THE LARGEST BODY OF CONTENT IN THE APP and it is already written. '
                    'By field: %s.' % split])
    d1 = json.load(io.open(os.path.join(ROOT, 'lib/data/homeDailyContent.json'),
                           encoding='utf-8'))
    written.append([S, 'Daily home', 'Home (before a due date is set)', 'daily-moment fallback',
                    'homeDailyContent.json', 'The one day shown when no due date is known',
                    'fallback', jwords(d1), len(d1), 'real', 'shared',
                    'lib/data/homeDailyContent.json', ''])
    return len(wc), days, total


# -----------------------------------------------------------------------------
#  Assets that already exist
# -----------------------------------------------------------------------------
def asset_rows():
    baby = [f for f in os.listdir(os.path.join(ROOT, 'assets/baby')) if f.endswith('.jpg')]
    images.append([S, 'Weekly — baby size', 'Home > this week > Baby toggle',
                   'Per-week baby illustration', 'baby-week-image', len(baby),
                   'optimised JPG', 'real-asset', 'shared', 'assets/baby/',
                   'REAL AND DONE — weeks 4 to 40. The only finished visual set in the app. '
                   'Use it as the quality bar for everything else.'])
    images.append([S, 'Weekly — food compare', 'Home > this week > size hero',
                   'Food-comparison image per week', 'food-image', len(baby), 'unknown',
                   'blank', 'shared', 'lib/data/weekContent.json',
                   'The week data names a food ("the size of a lime") with no picture. '
                   'One per week, to match the finished baby set.'])

    man = json.load(io.open(os.path.join(ROOT, 'assets/narration/manifest_hi.json'),
                            encoding='utf-8'))
    staged = os.path.join(ROOT, 'assets/narration/hi')
    have = len([f for f in os.listdir(staged)]) if os.path.isdir(staged) else 0
    other.append([S, 'Narration (audio)', 'Home > any passage > listen',
                  'audio/narration', 'Hindi narration, %s passages' % '{:,}'.format(len(man)),
                  len(man) - have,
                  'A Hindi voice recording per passage. The manifest lists every passage the '
                  'app can speak; only some are recorded. The rest stream from R2 when they '
                  'exist',
                  '%d of %s recorded (%.0f%%)' % (have, '{:,}'.format(len(man)),
                                                  100.0 * have / max(len(man), 1)),
                  'shared', 'assets/narration/manifest_hi.json'])
    other.append([S, 'Narration (audio)', 'Home > any passage > listen',
                  'audio/narration', 'English narration', len(man),
                  'An English voice set, if English narration is wanted at all. None exists',
                  'none', 'shared', 'assets/narration/'])

    blocks = [f for f in os.listdir(os.path.join(ROOT, 'assets/blocks'))]
    images.append([S, 'Home (V2 experiment)', 'Home > V2 focus', 'Hero block art',
                   'illustration', len(blocks), 'squared transparent PNG', 'real-asset',
                   'old', 'assets/blocks/',
                   'REAL, and regeneratable from docs/IMAGE-PROMPTS.md. Belongs to the V2 '
                   'Focus experiment — confirm that still ships before spending on more.'])


# -----------------------------------------------------------------------------
#  The Dart seed lists
# -----------------------------------------------------------------------------
#  (file, ctor, area, tap path, content type, purpose, image kind or None,
#   other type or None, what we must supply, clinical?)
SPECS = [
    ('lib/data/can_i_data.dart', 'CanIEntry', 'Can I…?', 'Tools > Can I…?', 'can-i entry',
     'Is this food, activity or medicine safe in pregnancy', None, None, None, True),
    ('lib/data/conditions_data.dart', 'ConditionEntry', 'Conditions', 'Explore > Conditions',
     'condition explainer', 'What it is, what it means for the pregnancy, when to worry',
     'illustration', None, None, True),
    ('lib/data/report_findings_data.dart', 'ReportFinding', 'Report findings',
     'Tools > Reports', 'report finding',
     'A plain-English reading of what a scan or blood report says', None, None, None, True),
    ('lib/data/tests_scans_reports_data.dart', 'TestScanInfo', 'Tests and scans',
     'Tools > Tests, scans and reports', 'test explainer',
     'What the test is for and what happens', 'infographic', None, None, True),
    ('lib/data/tests_scans_reports_data.dart', 'FindingInfo', 'Tests and scans',
     'Tools > Tests, scans and reports', 'finding explainer',
     'What a particular finding means', None, None, None, True),
    ('lib/data/symptom_data.dart', 'Symptom', 'Symptoms', 'Home > log a symptom',
     'symptom entry', 'What it is, whether it is normal, when to call', None, None, None, True),
    ('lib/data/nutrition_data.dart', 'Recipe', 'Nutrition', 'Tools > Nutrition', 'recipe',
     'A dish, with method and nutrition', 'food-image', None, None, False),
    ('lib/data/nutrition_data.dart', 'FoodEntry', 'Nutrition', 'Tools > Nutrition > foods',
     'food entry', 'Whether it is safe, and what it gives her', 'food-image', None, None, True),
    ('lib/data/nutrition_data.dart', 'DietChart', 'Nutrition', 'Tools > Nutrition > diet chart',
     'diet chart', 'A day of eating, by trimester', None, None, None, True),
    ('lib/data/cravings_data.dart', 'CravingItem', 'Cravings', 'Tools > Cravings',
     'craving entry', 'What the craving may mean and a safer version', None, None, None, False),
    ('lib/data/belly_skin_data.dart', 'BsPage', 'Belly and skin', 'Tools > Belly and skin',
     'skin page', 'A skin change and what to do about it', 'photo', None, None, True),
    ('lib/data/belly_skin_data.dart', 'BsIngredient', 'Belly and skin',
     'Tools > Belly and skin > ingredients', 'ingredient entry',
     'Whether an ingredient is safe in pregnancy', 'photo', None, None, True),
    ('lib/data/mind_mood_data.dart', 'MmArticle', 'Mind and mood', 'Explore > Mind and mood',
     'article', 'Mental health support through pregnancy', 'photo', None, None, True),
    ('lib/data/mind_mood_data.dart', 'MmScreenerQuestion', 'Mind and mood',
     'Explore > Mind and mood > screener', 'screener question',
     'One question in a mental-health screener', None, None, None, True),
    ('lib/data/mind_mood_data.dart', 'MmSosStep', 'Mind and mood',
     'Explore > Mind and mood > SOS', 'SOS step', 'One step of the panic flow',
     None, 'meditation', 'A voice recording for this step', False),
    ('lib/data/mind_mood_extras.dart', 'MmAffirmation', 'Mind and mood',
     'Explore > Mind and mood', 'affirmation', 'A line to hold on to',
     None, 'meditation', 'A voice recording, if these are spoken', False),
    ('lib/data/spiritual_reading_data.dart', 'SpiritualTradition', 'Spiritual reading',
     'Explore > Spiritual reading', 'tradition content',
     'Readings and practice from one tradition', 'illustration', 'data source',
     'A knowledgeable reviewer for this tradition specifically', False),
    ('lib/data/read_to_baby_data.dart', 'ReadAloudPiece', 'Read to baby',
     'Home > daily > Read to baby', 'passage to read aloud',
     'Something to read to the baby', None, 'audio/narration',
     'A recording, if these are also spoken', False),
    ('lib/data/journey_milestones.dart', 'JourneyMilestone', 'Journey map',
     'Tools > Journey map', 'milestone copy', 'A stop on the trail and what it means',
     'illustration', None, None, False),
    ('lib/data/prepare_data.dart', 'YogaSession', 'Paid services', 'Prepare tab > Yoga',
     'class description', 'One prenatal yoga session', 'photo', 'paid offering (yoga)',
     'A real instructor and a filmed session — yoga cannot be taught in text', False),
    ('lib/data/prepare_data.dart', 'BirthingClass', 'Paid services',
     'Prepare tab > Birthing classes', 'class description', 'One birthing class',
     None, 'paid offering', 'A real educator, a syllabus, a price and a schedule', False),
    ('lib/data/prepare_data.dart', 'NutriOption', 'Paid services',
     'Prepare tab > Nutrition', 'offering-blurb', 'A paid nutrition option',
     None, 'paid offering', 'A real dietitian and a real price', False),
    ('lib/data/product_data.dart', 'Product', 'Products', 'Tools > Products',
     'product-blurb', 'What it is and whether it is worth buying', 'product-image',
     'product entry', 'A real SKU, brand, MRP, link and photography', False),
    ('lib/data/read_next_data.dart', 'ReadItem', 'Read next', 'anywhere > Read next',
     'article', 'The cross-linking read shelf', 'photo', None, None, False),
    ('lib/data/week_articles_data.dart', 'WeekArticle', 'Weekly — reads',
     'Home > this week > This week\'s reads', 'article', 'A read for this week',
     'photo', None, None, False),
    ('lib/data/garbh_data.dart', 'GarbhPrompt', 'Garbh Sanskar', 'Home > Garbh Sanskar',
     'garbh prompt', 'A prompt for one of the four live pillars', None, None, None, False),
    ('lib/data/garbh_data.dart', 'GarbhStory', 'Garbh Sanskar',
     'Home > Garbh Sanskar > Samvad', 'garbh story', 'A story for the baby',
     'illustration', None, None, False),
    ('lib/data/garbh_data.dart', 'GarbhAudio', 'Garbh Sanskar',
     'Home > Garbh Sanskar > Shravan', 'audio track copy',
     'A raga or track and why it is there', 'audio-cover', 'raga/music track',
     'A licensed or recorded raga, full length, rights cleared for app use', False),
    ('lib/data/garbh_rebuild_data.dart', 'GarbhRitual', 'Garbh Sanskar',
     'Home > Garbh Sanskar', 'ritual copy', 'A daily ritual', 'illustration', None,
     None, False),
    ('lib/data/hospital_bag_catalog.dart', 'BagItem', 'Ready for birth',
     'Tools > Ready for birth', 'checklist item', 'Something to pack', None, None,
     None, False),
    ('lib/data/veda_showcase.dart', 'VedaShowcase', 'Ask Veda', 'Ask Veda',
     'showcase Q and A', 'An example question that shows what Ask Veda can do',
     None, None, None, False),
    ('lib/data/content_slots.dart', 'ContentSlot', 'Weekly — films',
     'Home > this week', 'film slot copy', 'A slot a film would fill',
     'video', 'video production', 'A film for this slot; none is defined for pregnancy '
     'the way TTC defines sixteen', False),
]


def seed_rows():
    for (rel, ctor, area, path, ctype, purpose, ikind, otype, oneed, clinical) in SPECS:
        full = os.path.join(ROOT, rel)
        if not os.path.exists(full):
            continue
        s = src(rel)
        for st, en, b in dp.entries(s, ctor):
            eid = dp.text(b, 'id') or ''
            title = (dp.text(b, 'name') or dp.text(b, 'nameEn') or dp.text(b, 'title')
                     or dp.text(b, 'titleEn') or dp.text(b, 'label') or dp.text(b, 'question')
                     or dp.text(b, 'q') or dp.text(b, 'item') or eid or ctor)
            w = dp.words(b)
            p = '%s > %s' % (path, title)
            written.append([S, area, p, ctype, title, purpose, 'all pregnancy', w, 1,
                            'clinical-review-owed' if clinical else 'placeholder',
                            'shared', rel, ''])
            if ikind:
                # A film's row is titled with the FILM, not with the kind of
                # row it is: "Film slot copy — X" then had "Film" stripped off
                # the front by the overview's prefix cleaner, leaving "slot
                # copy — X" as the title of a thing to shoot.
                label = ('Film: %s' % title if ikind == 'video'
                         else '%s — %s' % (ctype.capitalize(), title))
                images.append([S, area, p, label, ikind, 1,
                               'unknown', 'blank', 'shared', rel, ''])
            if otype:
                other.append([S, area, p, otype, title, 1, oneed, 'placeholder',
                              'shared', rel])


def prose_rows():
    """Files that are one body of writing rather than a list of entries."""
    for rel, area, path, ctype, purpose, clinical in [
        ('lib/data/diet_chart_content.dart', 'Nutrition', 'Tools > Nutrition > diet chart',
         'diet-chart copy', 'The per-trimester day plans in full', True),
        ('lib/data/scan_guide_data.dart', 'Scans', 'Tools > Scans', 'scan guide',
         'What happens at each scan', True),
        ('lib/data/scan_extras.dart', 'Scans', 'Tools > Scans', 'scan extras',
         'The questions around a scan', True),
        ('lib/data/trimester_tips.dart', 'Trimester tips', 'Home', 'trimester tip',
         'Short practical tips by trimester', False),
        ('lib/data/body_changes.dart', 'Body changes', 'Home > this week',
         'body-change copy', 'What is changing and why', True),
        ('lib/data/week_development_data.dart', 'Weekly — development',
         'Home > this week', 'week-development copy', 'What develops this week', False),
        ('lib/data/week5_full_data.dart', 'Weekly — week 5 Full',
         'Home > week 5 > Full toggle', 'week-content, full variant',
         'A richer treatment of one week, built as a prototype', False),
        ('lib/data/ready_for_birth_data.dart', 'Ready for birth',
         'Tools > Ready for birth', 'readiness copy',
         'The calm readiness experience around the hospital bag', False),
        ('lib/data/hospital_bag_seed.dart', 'Ready for birth', 'Tools > Ready for birth',
         'bag seed copy', 'The starting list', False),
        ('lib/data/veda_suggestions.dart', 'Ask Veda', 'Ask Veda', 'suggestion chips',
         'The example questions offered before she types', False),
    ]:
        full = os.path.join(ROOT, rel)
        if not os.path.exists(full):
            continue
        s = src(rel)
        written.append([S, area, path, ctype, os.path.basename(rel), purpose,
                        'all pregnancy', dp.words(s), 1,
                        'clinical-review-owed' if clinical else 'placeholder',
                        'shared' if 'week5' not in rel else 'unsure', rel,
                        'One body of writing rather than a list of entries.'
                        + (' ⚠️ Behind a Standard | Full toggle on week 5 only. If the Full '
                           'shape is the future, 36 more weeks are owed; if not, it retires. '
                           'That decision changes the largest number in this sheet.'
                           if 'week5' in rel else '')])


def screen_rows():
    """Unsplash placeholders and drawn art on the pregnancy screens."""
    import re
    hits = {}
    for root, dirs, files in os.walk(os.path.join(ROOT, 'lib')):
        dirs[:] = [d for d in dirs if d not in ('post_pregnancy', 'ttc', 'father')]
        for f in files:
            if not f.endswith('.dart'):
                continue
            p = os.path.join(root, f)
            t = io.open(p, encoding='utf-8', errors='ignore').read()
            n = len(re.findall(r'images\.unsplash\.com', t))
            if n:
                hits[os.path.relpath(p, ROOT).replace('\\', '/')] = n
    for rel, n in sorted(hits.items(), key=lambda kv: -kv[1]):
        images.append([S, 'Screens — stock photography', rel.split('/')[-1],
                       'Stock photographs to replace', 'photo', n, 'unknown',
                       'unsplash-url', 'shared', rel,
                       '%d Unsplash URL(s) in this file.' % n])


def write(name, header, rows):
    with open(os.path.join(OUT, name), 'w', encoding='utf-8', newline='') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print('%-20s %5d rows' % (name, len(rows)))


if __name__ == '__main__':
    nweeks, ndays, dwords = json_rows()
    asset_rows()
    seed_rows()
    prose_rows()
    screen_rows()
    write('preg_images.csv', IMG, images)
    write('preg_written.csv', WRI, written)
    write('preg_other.csv', OTH, other)
    real = sum(int(r[7]) for r in written if r[9] == 'real' and str(r[7]).isdigit())
    ph = sum(int(r[7]) for r in written if r[9] != 'real' and str(r[7]).isdigit())
    print('weekly spine %d weeks | daily %d days, %s words | REAL %s words | placeholder %s words'
          % (nweeks, ndays, '{:,}'.format(dwords), '{:,}'.format(real), '{:,}'.format(ph)))
