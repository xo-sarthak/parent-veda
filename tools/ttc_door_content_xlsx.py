# =============================================================================
#  ttc_door_content_xlsx.py -- what the seven TTC doors need written and shot
# -----------------------------------------------------------------------------
#      python tools/ttc_door_content_xlsx.py
#
#  ⚠️ THE SOURCE HERE IS THE REBUILD PDFs, NOT THE APP. The briefs in
#  Downloads/door-pdf/TTC-doors are the source of truth; the app is one
#  implementation of them and is behind in places (Mind & body especially).
#  So every row below is transcribed from a brief, and the ONE door with no
#  brief -- Fertile window -- is read from `ttc_focus_conceiving.dart` and
#  marked as such in the Source column.
#
#  ⚠️ TOOLS ARE NOT CONTENT AND ARE LEFT OUT. "Where do I stand", "Check my
#  readiness", "Read your semen report", the trackers and the checklists are
#  software with copy inside them, not pieces somebody writes and hands over.
#  Listing them here would put an engineering job in a writer's queue.
#
#  ⚠️ AND THE RELATIONSHIP MATTERS MORE THAN THE COUNT. An image is never
#  standalone: it is a card's thumbnail, a door's hero, or artwork inside a
#  piece. A video sometimes is standalone and sometimes sits inside an article.
#  Every image and video row therefore names what it belongs to, because
#  "we need 60 images" is useless and "this image is the thumbnail for that
#  article" can be acted on.
# =============================================================================

import os
from collections import Counter, OrderedDict

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'docs', 'content-brief', 'TTC-DOOR-CONTENT.xlsx')

# Status vocabulary, taken from the briefs themselves.
NEW = 'NEW — write from scratch'
DRAFT = 'Exists as a draft — needs a real author'
PROMOTE = 'Pointer only — no new writing'
REF = 'Owned by another door — no new writing'

DOORS = ['Fertile window', 'PCOS', 'IVF and IUI', 'Getting ready', 'His side',
         'Mind and body', 'After a loss']

# -----------------------------------------------------------------------------
#  WRITTEN CONTENT  (door, type, title, what it covers, status, source)
# -----------------------------------------------------------------------------
W = [
 # ---- Fertile window (no brief; read from the app) ------------------------
 ('Fertile window', 'Article', 'Which days can she get pregnant?', 'The fertile window in plain terms: which days actually count and why', DRAFT, 'App'),
 ('Fertile window', 'Article', 'Ovulation kits: do they help?', 'Whether to buy one, how to use it, and what it cannot tell you', DRAFT, 'App'),
 ('Fertile window', 'Article', 'How often is best', 'How often to have sex across the cycle, without turning it into a schedule', DRAFT, 'App'),
 ('Fertile window', 'Article', 'Can stress stop it?', 'What stress does and does not do to conception', DRAFT, 'App'),
 ('Fertile window', 'Article', 'Trying for many months?', 'When taking a while becomes a reason to see somebody', DRAFT, 'App'),
 ('Fertile window', 'Myth vs fact', 'Every day or not?', 'Whether daily sex helps or hurts the odds', DRAFT, 'App'),
 ('Fertile window', 'Myth vs fact', 'Do positions matter?', 'The position question, answered plainly', DRAFT, 'App'),
 ('Fertile window', 'Myth vs fact', 'Should she lie down after?', 'The lying-down advice and where it came from', DRAFT, 'App'),
 ('Fertile window', 'Myth vs fact', 'Does the woman need to finish?', 'Whether her orgasm affects conception', DRAFT, 'App'),
 ('Fertile window', 'Carousel (3 cards)', 'How the body shows the right days', 'The signs the body gives — temperature, mucus, timing — over three cards', DRAFT, 'App'),
 ('Fertile window', 'Carousel (6 cards)', 'How sperm are made', 'The 90-day production cycle, over six cards', DRAFT, 'App'),
 ('Fertile window', 'Carousel (3 cards)', '3 things for her', 'The three things that genuinely matter on her side', DRAFT, 'App'),
 ('Fertile window', 'Carousel (4 cards)', 'Signs to not wait', 'Four signs that mean see a doctor now rather than waiting', DRAFT, 'App'),
 ('Fertile window', 'Reference', 'Whose "side" is it, really', 'Male-factor piece — His side owns it', REF, 'App'),
 ('Fertile window', 'Reference', 'Heat, habits and time', 'Sperm health piece — His side owns it', REF, 'App'),
 ('Fertile window', 'Reference', 'What to eat and avoid', 'Diet — Getting ready owns it', REF, 'App'),
 ('Fertile window', 'Reference', 'Folic acid: why she needs it', 'Supplements — Getting ready owns it', REF, 'App'),
 ('Fertile window', 'Reference', 'What to cut before trying', 'Habits — Getting ready owns it', REF, 'App'),
 ('Fertile window', 'Reference', 'Weight, said kindly', 'Weight — Getting ready owns it', REF, 'App'),

 # ---- PCOS ----------------------------------------------------------------
 ('PCOS', 'Article', 'PCOS and your cycle', 'What PCOS does to a cycle and why periods go irregular', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'Irregular periods, explained', 'What counts as irregular and what it means', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'If a doctor says PCOS', 'What a diagnosis actually means and what happens next', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'What changes the curve, nothing banned', 'Food and insulin without a diet plan and with nothing forbidden', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'Inositol: what is shown to help', 'The one supplement with real evidence, honestly described', DRAFT, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'Weight and PCOS, said kindly', 'Weight with NO numbers, no targets and no judgement', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'Sleep and stress', 'How sleep and stress interact with PCOS', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'PCOS and ovulation', 'Why ovulation is the part PCOS affects most', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'Your realistic odds with PCOS', 'Honest expectations, no personalised probability', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'What treatment usually looks like', 'The usual treatment path', DRAFT, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'Letrozole, metformin and the usual order', 'The medicines, in the order they are usually tried', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Article', 'When to see a specialist', 'When PCOS becomes a fertility-clinic conversation', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Guide', 'Hair changes, explained', 'Extra hair and hair thinning, what causes each', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Guide', 'Anovulatory cycles', 'A cycle without ovulation, and how to spot one', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Myth vs fact', 'How common is PCOS', 'How common it really is, against what people assume', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Myth vs fact', 'Worth it vs hype', 'Which PCOS supplements are worth money and which are marketing', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Infographic', 'PCOS or ovarian cysts', 'The difference, in two columns — they are not the same thing', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Infographic', 'PCOS or thyroid', 'The difference, in two columns — symptoms overlap heavily', NEW, 'pcos_rebuild.pdf'),
 ('PCOS', 'Recipe', 'PCOS-friendly Indian meals', 'Real Indian meals, no imported ingredients, no calorie counting', NEW, 'pcos_rebuild.pdf'),

 # ---- IVF and IUI ---------------------------------------------------------
 ('IVF and IUI', 'Article', 'What IUI and IVF involve', 'The procedures themselves, start to finish', DRAFT, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'ICSI: when it is needed, when routine', 'When ICSI is genuinely indicated versus sold as standard', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'What a fertility check involves', 'The first appointment and the tests that come with it', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'What IVF actually costs in India', 'Real INR costs, city by city', DRAFT, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'What a package leaves out', 'The line items a clinic package does not include', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'The injections, honestly', 'What the injections are actually like to do', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'OHSS: when to call the clinic', 'SAFETY PIECE. The warning signs that mean call now', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'Is egg retrieval painful?', 'What retrieval actually feels like', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Article', 'Can I work through a cycle?', 'Working through a cycle, realistically', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Guide', 'IUI or IVF, and when you move up', 'Which one, and when moving up is the right call', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Guide', "How to read a clinic's success rate", 'How clinics present success rates and how to read them honestly', DRAFT, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Guide', 'Questions to ask before you sign up', 'The questions to ask a clinic before paying', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Myth vs fact', 'Does bed rest after transfer help?', 'The bed-rest belief, answered', NEW, 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Reference', 'His side of the tests', 'Male testing — His side owns it', REF, 'ivf_rebuild.pdf'),

 # ---- Getting ready -------------------------------------------------------
 ('Getting ready', 'Article', 'The three months before', 'The 90-day window before trying, for both of you', DRAFT, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Article', 'What to cut before trying', 'What to stop, and how far ahead', NEW, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Article', 'When to start what, and how early', 'Supplement timing — which one, how early', NEW, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Article', 'Tests and vaccines worth doing first', 'The pre-conception checks worth doing before trying', DRAFT, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Article', 'Weight before pregnancy, said kindly', 'Weight with NO numbers and no targets', NEW, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Article', 'Coming off birth control', 'Stopping contraception and what to expect after', NEW, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Article', 'Medicines and conditions to check with a doctor', 'Which existing medicines and conditions need a conversation first', NEW, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Guide', 'The carrier screening that matters in India', 'Carrier screening, named plainly. ⚠️ The brief says the content author must confirm exactly which screen is meant before this goes into copy', NEW, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Do card', 'Habits worth building now', 'Sleep, movement, alcohol and tobacco as things to do, not read', DRAFT, 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Reference', 'His part', 'Male preparation — His side owns it', REF, 'getting_ready_rebuild.pdf'),

 # ---- His side ------------------------------------------------------------
 ('His side', 'Article', 'Whose "side" is it, really', 'That about half of cases involve him, and that fault is the wrong frame', DRAFT, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'The case for testing early', 'Why his test is worth doing first: cheap, fast, and answers half the question', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'What a semen analysis involves', 'What is measured and how to prepare so the result is worth having', DRAFT, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'If the result is normal', 'What a normal result rules out, and the two things it does not', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'If the first test is abnormal', 'Why one low number is a reason to repeat, not a conclusion', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'If no sperm is found', 'AZOOSPERMIA. Its own piece — the one result that needs a specialist rather than a repeat, and it is far more hopeful than it sounds', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'Heat, habits and time', 'The three levers with evidence, including smokeless tobacco', DRAFT, 'his_side_rebuild.pdf'),
 ('His side', 'Article', 'Zinc and CoQ10, honestly', 'The two supplements with any evidence, and how weak that evidence is', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Guide', 'The words on the report, in plain English', 'Every term on a semen report, translated', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Guide', 'What three months looks like', 'The twelve-week plan: what to change in which week', NEW, 'his_side_rebuild.pdf'),
 ('His side', 'Red flag card', 'Reasons to be seen sooner', 'The signs that mean see a doctor rather than waiting out a year', DRAFT, 'his_side_rebuild.pdf'),
 ('His side', 'Reference', 'His emotional side', 'What this does to him — Mind and body owns it', REF, 'his_side_rebuild.pdf'),

 # ---- Mind and body -------------------------------------------------------
 ('Mind and body', 'Article', 'Stress, and the thing everyone says about it', 'LOCKED — reuse as-is, do not rewrite or re-title', DRAFT, 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'Article', 'Preconception garbh sanskar, honestly', 'LOCKED — reuse as-is, do not rewrite or re-title', DRAFT, 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'Guide', 'Why sleep matters when you are trying', 'Sleep and the cycle, for both of you. FULL COPY ALREADY WRITTEN in the new-guides brief', NEW, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'Fixing a bedtime you will actually keep', 'A bedtime that survives real life, including living with family. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'When family keeps asking', 'Three replies, and how to handle weddings and festivals. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'Bringing him into this', 'The gap where she does everything and he seems relaxed. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Myth vs fact', 'Stop thinking about it and it will happen', 'Pointer into the Stress article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'Where stress does have a real effect', 'Pointer into the Stress article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'What a daily practice is for', 'Pointer into the Stress article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'Five minutes, and not as a target', 'Pointer into the Stress article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'Ways to stay calm', 'Pointer into the Stress article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'What to say to people who keep offering this advice', 'Pointer into the Stress article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Myth vs fact', 'Does it make a smarter baby?', 'Pointer into the garbh sanskar article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Guide', 'And if you are not religious', 'Pointer into the garbh sanskar article. Card blurb only', PROMOTE, 'Mindbody_new_guides.pdf'),
 ('Mind and body', 'Red flag card', 'When this is more than the strain of waiting', 'Carries the self-harm routing. Must not be buried', DRAFT, 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'Red flag card', 'Where a practice is not the right answer', 'When a breathing exercise is the wrong prescription', DRAFT, 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'Practice card', 'Loosen-up: neck, shoulders, side bends', 'MOVE, 3 min. Six steps written. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', "Cat and cow, then child's pose", 'MOVE, 3 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Hip openers: butterfly and slow lunge', 'MOVE, 4 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'A ten-minute walk', 'MOVE, 10 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Legs up the wall', 'MOVE, 3 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Slow sun salutation, three rounds', 'MOVE, 5 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Long out-breath, in four out six', 'BREATHE, 1 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Alternate nostril breathing', 'BREATHE, 1–2 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Box breathing', 'BREATHE, 1 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Two-minute body relaxation', 'BREATHE, 2 min. FULL COPY ALREADY WRITTEN', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Two-minute calm listen', 'BREATHE, 2 min. Needs an audio track chosen by the user', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Practice card', 'Ten slow breaths together', 'BREATHE, 1 min. The only one that needs both partners', NEW, 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Course session', 'Session 1: What this is, and what it is not', 'GARBH SANSKAR COURSE, 12 min. FULL COPY ALREADY WRITTEN', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 2: Breath', 'GARBH SANSKAR COURSE, 15 min. FULL COPY ALREADY WRITTEN', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 3: Stillness', 'GARBH SANSKAR COURSE, 15 min. FULL COPY ALREADY WRITTEN', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 4: Sound', 'GARBH SANSKAR COURSE, 12 min. Needs a calm audio piece', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 5: The body and the day', 'GARBH SANSKAR COURSE, 15 min. FULL COPY ALREADY WRITTEN', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 6: Food', 'GARBH SANSKAR COURSE, 12 min. Points across to Getting ready', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 7: The two of you', 'GARBH SANSKAR COURSE, 15 min. FULL COPY ALREADY WRITTEN', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Course session', 'Session 8: Putting it together', 'GARBH SANSKAR COURSE, 15 min. Ends by writing the user their own daily practice', NEW, 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Reference', 'Nine cards to Getting ready and His side', 'Food, supplements, habits, tests, vaccines, his part — all owned elsewhere', REF, 'Mindbody_rebuild_final.pdf'),

 # ---- After a loss --------------------------------------------------------
 ('After a loss', 'Article', 'Physical recovery, in plain terms', 'Bleeding, hormones, when the cycle returns. By Dr Ananya Rao', DRAFT, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Article', 'On trying again', 'When it is safe, what the evidence says about waiting, and who decides', DRAFT, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Infographic', 'What normal bleeding and spotting looks like', 'NET-NEW. How long, how heavy, and how it differs by how the loss was managed. ⚠️ Clinical content — must come from a doctor, not a writer', NEW, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Myth vs fact', 'You can ovulate before your first period', 'NET-NEW. Ovulation returns before the first period, which matters if she is not ready', NEW, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Myth vs fact', 'A miscarriage is not a pattern', 'NET-NEW. One loss does not change the odds', NEW, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Guide', 'Rh status and retained tissue', 'Pointer into the recovery article. One has a 72-hour window', PROMOTE, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Guide', 'It was almost certainly not preventable', 'Pointer into the trying-again article', PROMOTE, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Guide', 'When investigation is worth asking for', 'Pointer — the two-loss ESHRE threshold', PROMOTE, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Guide', 'What recurrent-loss investigation looks like', 'Pointer — thyroid, antiphospholipid, uterus, chromosomal. ⚠️ Needs its own heading in the article first', PROMOTE, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Myth vs fact', 'The six-month wait, and where it came from', 'Pointer into the trying-again article', PROMOTE, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Guide', 'What to do differently next time', 'Pointer — a short list, shorter than the internet suggests', PROMOTE, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Red flag card', 'Go to hospital today, not tomorrow', 'Heavy bleeding, fever, severe pain. Pinned, always visible', DRAFT, 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Red flag card', 'Some of this needs a person, not a page', 'Carries the self-harm routing. Must not be lost or buried', DRAFT, 'After_a_loss_rebuild.pdf'),
]

# -----------------------------------------------------------------------------
#  HOW MEDICALLY CRITICAL IS EACH PIECE
# -----------------------------------------------------------------------------
#  ⚠️ THIS COLUMN EXISTS TO RANK THE DOCTOR'S QUEUE, NOT TO EXCUSE ANYTHING.
#  Every clinical piece gets verified eventually. What this says is which ones
#  cannot ship a day before that happens, because being wrong in them causes
#  harm rather than confusion.
#
#  CRITICAL is reserved for three shapes: a piece that tells someone when to
#  seek urgent care, a piece that could delay urgent care if it reassures
#  wrongly, and a piece naming medicines, tests or thresholds. Everything else
#  clinical is still a doctor's job, just not a bottleneck.
CRITICAL = 'CRITICAL — verify before it ships'
CLINICAL = 'Clinical — a doctor signs it'
SOFT = 'Not clinical — an editor is enough'

_CRITICAL_TITLES = {
    # tells you when to get urgent help, or could delay it
    'OHSS: when to call the clinic', 'If no sperm is found',
    'What normal bleeding and spotting looks like', 'Rh status and retained tissue',
    'Go to hospital today, not tomorrow', 'Some of this needs a person, not a page',
    'When this is more than the strain of waiting',
    'Where a practice is not the right answer', 'Reasons to be seen sooner',
    'Signs to not wait', 'Trying for many months?', 'When to see a specialist',
    'When investigation is worth asking for',
    'What recurrent-loss investigation looks like',
    'You can ovulate before your first period',
    # names medicines, tests or thresholds
    'Medicines and conditions to check with a doctor',
    'The carrier screening that matters in India',
    'Letrozole, metformin and the usual order',
    'If the first test is abnormal', 'If the result is normal',
    'The six-month wait, and where it came from',
}
_SOFT_TITLES = {
    'Do positions matter?', 'Should she lie down after?',
    'Does the woman need to finish?', 'Every day or not?',
    'When family keeps asking', 'Bringing him into this',
    'What to say to people who keep offering this advice',
    'And if you are not religious', 'What a daily practice is for',
    'Five minutes, and not as a target', 'Ways to stay calm',
    'Does it make a smarter baby?', 'Questions to ask before you sign up',
    "How to read a clinic's success rate", 'What a package leaves out',
    'What IVF actually costs in India', 'Can I work through a cycle?',
    'Your pre-pregnancy checklist',
    'Session 1: What this is, and what it is not',
    'Session 4: Sound', 'Session 7: The two of you',
    'Session 8: Putting it together',
    'Nine cards to Getting ready and His side',
}


def criticality(title, ctype, status):
    if title in _CRITICAL_TITLES:
        return CRITICAL
    if status == REF:
        return 'n/a — owned by another door'
    if title in _SOFT_TITLES:
        return SOFT
    if ctype in ('Practice card',):
        # each card carries its own "skip it if" note, which is a safety line
        return CLINICAL
    if ctype in ('Carousel (3 cards)', 'Carousel (4 cards)', 'Carousel (6 cards)',
                 'Course session', 'Do card'):
        return CLINICAL
    if ctype in ('Red flag card',):
        return CRITICAL
    return CLINICAL


# -----------------------------------------------------------------------------
#  VIDEOS  (door, title, what it covers, length, status, sits where)
# -----------------------------------------------------------------------------
V = [
 ('Fertile window', 'If you feel too much pressure', 'When trying starts to feel like a job, and what helps', 'about 5 min', DRAFT, 'Standalone card in "Does stress stop pregnancy?"', 'App'),
 ('Fertile window', 'Keep his sperm healthy', 'The three things that actually move sperm health', 'about 5 min', DRAFT, 'Standalone card in "What he can do"', 'App'),
 ('PCOS', 'PCOS in five minutes', 'What PCOS is, in five minutes, without the panic', 'about 5 min', NEW, 'Standalone, opens the Understand tab', 'pcos_rebuild.pdf'),
 ('PCOS', 'Food, insulin and PCOS', 'How food and insulin interact with PCOS', 'unstated', DRAFT, 'Standalone in "Food and insulin"', 'pcos_rebuild.pdf'),
 ('PCOS', 'Gentle movement for PCOS', 'Movement that helps, kept gentle', 'unstated', NEW, 'Standalone in "Movement and rest"', 'pcos_rebuild.pdf'),
 ('IVF and IUI', 'An IVF cycle, start to finish', 'A whole IVF cycle walked through, start to finish', 'unstated', NEW, 'Standalone in "The treatments". Marked COMING SOON', 'ivf_rebuild.pdf'),
 ('IVF and IUI', 'Getting through the two-week wait', 'The two-week wait, and how people get through it', 'unstated', NEW, 'Standalone in "What a cycle asks of you"', 'ivf_rebuild.pdf'),
 ('His side', 'What affects sperm health', 'The three things that genuinely move it, and the many that do not', 'about 5 min', NEW, 'Standalone in "Is it about him". Marked COMING SOON', 'his_side_rebuild.pdf'),
 ('His side', 'Reading a semen report', 'The report page, walked through line by line', 'about 6 min', NEW, 'Standalone in "The test". Marked COMING SOON', 'his_side_rebuild.pdf'),
 ('His side', 'Three things that actually change his numbers', 'The hero film inside the "Heat, habits and time" article', 'about 5 min', NEW, 'INSIDE the article "Heat, habits and time"', 'App'),
 ('Mind and body', 'Just relax, why that advice is wrong', 'Why "just relax" is bad advice, and what is true instead', 'unstated', DRAFT, 'Standalone in "About stress". Marked COMING SOON', 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'Preconception garbh sanskar, taught', 'Garbh sanskar taught rather than described', '36 min', DRAFT, 'Standalone in "What garbh sanskar is". Marked COMING SOON', 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'A longer session this week', 'One longer practice session, for a week when there is time', '20 to 30 min', NEW, 'Standalone in "Go deeper". Marked COMING SOON', 'Mindbody_rebuild_final.pdf'),
 ('After a loss', 'What the next few weeks look like', 'The weeks after a loss, walked through gently by a doctor', 'about 5 min', DRAFT, 'Standalone in "What\'s happening now". Marked COMING SOON', 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'On trying again', 'Trying again, in a doctor\'s voice', 'unstated', NEW, 'Standalone in "If and when you do". OPTIONAL in the brief', 'After_a_loss_rebuild.pdf'),
]

# ⚠️ WHO HAS TO MAKE EACH FILM.
#
#  The honest split is not "AI or not", it is whether a real person on camera
#  IS the point. A process explainer works as animation with a scripted
#  voice-over; a doctor saying "this is not your fault" does not, because the
#  credibility is the face. And anything demonstrating a body movement needs a
#  real body, or the app teaches a pose from a model that cannot be checked.
AI_OK = 'AI or animation — no face needed'
AI_VO = 'AI animation, but a doctor must sign the script'
EXPERT = 'Real expert on camera'
FILMED = 'Filmed with a real person (movement)'

VIDEO_MAKER = {
 'If you feel too much pressure': (EXPERT, 'A psychologist. The reassurance only lands from a person'),
 'Keep his sperm healthy': (AI_VO, 'A process explainer — animation carries it, but the claims are clinical'),
 'PCOS in five minutes': (EXPERT, 'The whole promise of the door is calm authority. A named gynaecologist'),
 'Food, insulin and PCOS': (AI_VO, 'Insulin and food is a mechanism — animation explains it better than a face'),
 'Gentle movement for PCOS': (FILMED, 'A real body demonstrating. Never animate a movement instruction'),
 'An IVF cycle, start to finish': (AI_VO, 'A process, step by step. Ideal for animation; script signed by a fertility specialist'),
 'Getting through the two-week wait': (EXPERT, 'Emotional. Needs a person who has sat with people through it'),
 'What affects sperm health': (AI_VO, 'A mechanism explainer. Animation, andrologist-signed script'),
 'Reading a semen report': (AI_OK, 'A walkthrough of a report page. No face needed at all — screen and annotation'),
 'Three things that actually change his numbers': (AI_VO, 'A mechanism explainer inside the article'),
 'Just relax, why that advice is wrong': (EXPERT, 'A psychologist correcting advice everyone gives. The face is the argument'),
 'Preconception garbh sanskar, taught': (FILMED, '36 minutes of teaching a practice. A real teacher, filmed'),
 'A longer session this week': (FILMED, 'A guided 20 to 30 minute practice. A real instructor'),
 'What the next few weeks look like': (EXPERT, 'Days after a loss. An AI voice here would be a betrayal of the moment'),
 'On trying again': (EXPERT, 'The same. A doctor, gently, on camera'),
}

# -----------------------------------------------------------------------------
#  IMAGES  (door, what the image is, kind, what it should show, belongs to)
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
#  SIZES, TAKEN FROM THE CODE RATHER THAN GUESSED
# -----------------------------------------------------------------------------
#  The rail card is 142x176 logical points and the picture FILLS it
#  (`Positioned.fill` behind the title), so card art is full-bleed portrait,
#  not a small thumbnail with a caption under it. The carousel track is 146
#  points tall and full width. Door heroes are fetched at 900x700 today.
#
#  ⚠️ DELIVER AT 3x. A logical point is three pixels on the phones this app is
#  used on, and artwork supplied at the logical size looks soft on every one of
#  them. The numbers below are already multiplied.
CARD = ('426 x 528 px  (142x176 pt @3x, portrait 4:5). FULL-BLEED: the title is '
        'laid over the picture, not printed under it')
HERO = ('1800 x 1400 px  (fetched at 900x700 today). Cropped to roughly 16:10 '
        'on screen, so keep the subject centred')
CARO = '1080 x 438 px  (full width x 146 pt @3x, landscape strip)'
INFO = '1080 x 1920 px  (full-screen portrait page)'
PROD = '1000 x 1000 px  (square, plain background)'
RIVE = 'Rive vector file, not pixels. Loop length and view angle in the note'
ILLU = '1080 x 1080 px  (square illustration)'

I = [
 ('Fertile window', 'Door hero photograph', 'Door hero', HERO,
  'A couple, calm, unposed. Warm and ordinary, not clinical', 'The door itself', 'App'),
 ('PCOS', 'Door hero photograph', 'Door hero', HERO,
  'Calm and reassuring. The door promises "PCOS, without the panic"', 'The door itself', 'App'),
 ('IVF and IUI', 'Door hero photograph', 'Door hero', HERO,
  'Steady and hopeful, not a clinic stock shot', 'The door itself', 'App'),
 ('Getting ready', 'Door hero photograph', 'Door hero', HERO,
  'Unhurried. The framing is "nothing urgent, nothing you have to rush"', 'The door itself', 'App'),
 ('His side', 'Door hero photograph', 'Door hero', HERO,
  'A COUPLE, not a lone man and not a woman. Two earlier attempts got this wrong: '
  'half the point of the door is that this is not only her problem', 'The door itself', 'App'),
 ('Mind and body', 'Door hero photograph', 'Door hero', HERO,
  'Quiet and still. No incense-and-candles cliche', 'The door itself', 'App'),
 ('After a loss', 'Door hero photograph', 'Door hero', HERO,
  'Gentle. No silver linings, nothing celebratory', 'The door itself', 'App'),

 ('All doors', 'Card art for every content card', 'Card art', CARD,
  'One per card. It fills the whole card and the title sits on top of it, so keep the '
  'lower third calm and uncluttered or the title stops being readable',
  'Every article, guide, video, myth, infographic, recipe, product and course card '
  '(about 124 across the seven doors)', 'All briefs'),

 ('PCOS', 'Two-column artwork: PCOS or ovarian cysts', 'Infographic artwork', INFO,
  'A side-by-side comparison a reader can take in at a glance', 'The "PCOS or ovarian cysts" infographic', 'pcos_rebuild.pdf'),
 ('PCOS', 'Two-column artwork: PCOS or thyroid', 'Infographic artwork', INFO,
  'A side-by-side comparison. These two are confused constantly', 'The "PCOS or thyroid" infographic', 'pcos_rebuild.pdf'),
 ('PCOS', 'Body-area picker artwork', 'Tool artwork',
  '512 x 512 px each, one per body area and per severity level',
  'Where extra hair growth appears (upper lip, chin, chest, belly, thighs), plus mild / '
  'moderate / severe visuals for hair thinning and for acne, plus skin-darkening images '
  'for neck, armpits and belly', 'The "Where do I stand" tool', 'pcos_rebuild.pdf'),
 ('PCOS', 'Recipe photography', 'Recipe photo',
  '1080 x 1080 px square, plus 1080 x 810 px for the header',
  'Real Indian meals, home-cooked. Not styled Western food', 'The "PCOS-friendly Indian meals" recipe', 'pcos_rebuild.pdf'),
 ('PCOS', 'Product photograph: Myo-inositol', 'Product photo', PROD,
  'A real packshot on a plain background', 'The Myo-inositol product card', 'pcos_rebuild.pdf'),

 ('After a loss', 'Bleeding and spotting artwork', 'Infographic artwork', INFO,
  'CLINICAL. What normal bleeding looks like across the weeks, and how it differs by how '
  'the loss was managed. The content must come from a doctor before anything is drawn',
  'The bleeding infographic', 'After_a_loss_rebuild.pdf'),

 ('Fertile window', 'Carousel artwork: How the body shows the right days', 'Carousel card art',
  CARO + '  x 3 cards', 'Temperature, mucus, timing. One image per card', 'That carousel', 'App'),
 ('Fertile window', 'Carousel artwork: How sperm are made', 'Carousel card art',
  CARO + '  x 6 cards', 'The 90-day production cycle, one image per card', 'That carousel', 'App'),
 ('Fertile window', 'Carousel artwork: 3 things for her', 'Carousel card art',
  CARO + '  x 3 cards', 'One image per card', 'That carousel', 'App'),
 ('Fertile window', 'Carousel artwork: Signs to not wait', 'Carousel card art',
  CARO + '  x 4 cards', 'One image per card', 'That carousel', 'App'),
 ('Fertile window', 'Product photograph: ovulation kit', 'Product photo', PROD,
  'A real packshot of a kit actually sold in India', 'The "Buy an ovulation kit" card', 'App'),

 ('Getting ready', 'Product photograph: folic acid and supplements', 'Product photo', PROD,
  'Real packshots', 'The folic acid product card', 'getting_ready_rebuild.pdf'),
 ('His side', 'Product photograph: zinc and CoQ10', 'Product photo', PROD,
  'Plain versions, not branded "male fertility" stacks', 'The Zinc / CoQ10 product card', 'his_side_rebuild.pdf'),

 ('Mind and body', 'Rive animation: Loosen-up sequence', 'Movement animation',
  RIVE + '. About 30s, then loops',
  'Looping figure, FRONT view, doing the sequence once through. Step text advances alongside',
  'Practice card 1', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Rive animation: Cat and cow, then child pose', 'Movement animation',
  RIVE + '. Loops',
  'SIDE view, looping between cow and cat on a breath cue, then settling into child pose',
  'Practice card 2', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Rive animation: Hip openers', 'Movement animation',
  RIVE + '. Two-part loop',
  'Butterfly held on a breath cue, then the lunge on each side. SIDE view',
  'Practice card 3', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Rive animation: Walking loop', 'Movement animation',
  RIVE + '. Short loop',
  'A simple walking loop only. No pose animation needed for this card',
  'Practice card 4 (ten-minute walk)', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Rive animation: Legs up the wall', 'Movement animation',
  RIVE + '. Near-static, with a 3-minute ring',
  'A held pose, SIDE view, very little motion. It is a rest pose',
  'Practice card 5', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Rive animation: Slow sun salutation', 'Movement animation',
  RIVE + '. The longest of the six',
  'The full sequence as a loop, SIDE view, with the breath cue marked at each step',
  'Practice card 6', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Outline figure for body relaxation', 'Movement animation',
  RIVE + '. 120s pass down the body',
  'A simple outline figure with the current body part highlighted, moving downward',
  'Practice card 10, and garbh session 3', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Alternate-nostril head and hand', 'Movement animation',
  RIVE + '. 90s loop',
  'Front-view head with a hand, showing which nostril is closed, in time with the breath',
  'Practice card 8, and garbh session 2', 'Mindbody_twelve_practice_cards.pdf'),
 ('Mind and body', 'Two seated outline figures', 'Movement animation',
  RIVE + '. 1-minute loop',
  'Two figures side by side for the ten-breaths-together practice, with two markers',
  'Practice card 12, and garbh session 7', 'garbh_sanskar_eight_sessions.pdf'),
 ('Mind and body', 'Plate illustration', 'Illustration', ILLU,
  'A simple plate for the sattvik food session. No animation needed',
  'Garbh session 6 (Food)', 'garbh_sanskar_eight_sessions.pdf'),
]

# -----------------------------------------------------------------------------
#  OTHER  (door, type, title, what is needed)
# -----------------------------------------------------------------------------
O = [
 ('Fertile window', 'Consult', 'Talk to a doctor', 'A real gynaecologist, with credentials, photograph, price and consent', 'App'),
 ('Fertile window', 'Product', 'Buy an ovulation kit', 'A real SKU, brand, MRP and retailer link', 'App'),
 ('PCOS', 'Consult', 'Talk to a PCOS specialist', 'A real gynaecologist with a PCOS or endocrine focus', 'pcos_rebuild.pdf'),
 ('PCOS', 'Course', 'The PCOS programme', 'A real syllabus, instructor, session count and price', 'pcos_rebuild.pdf'),
 ('PCOS', 'Product', 'Myo-inositol', 'A real SKU with an honest evidence claim', 'pcos_rebuild.pdf'),
 ('PCOS', 'Community', 'PCOS circle', 'A room name and description only. The posts come from members', 'pcos_rebuild.pdf'),
 ('IVF and IUI', 'Consult', 'Speak to a fertility specialist', 'A real fertility specialist. Priced at Rs 899 in the brief', 'ivf_rebuild.pdf'),
 ('Getting ready', 'Product', 'Folic acid and preconception supplements', 'Real SKUs and dosing that a doctor has checked', 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Consult', 'Talk to someone before you start', 'A doctor or nutritionist', 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Checklist', 'Your pre-pregnancy checklist', 'The closing spine: what is covered, what is still worth discussing, the next three steps', 'getting_ready_rebuild.pdf'),
 ('Getting ready', 'Data', 'The full test library, with India costs', 'Current INR lab pricing for three or four metros, refreshed on a schedule', 'getting_ready_rebuild.pdf'),
 ('His side', 'Consult', 'Talk to an andrologist / Have the report read properly', 'A real andrologist. One person, referenced from two cards', 'his_side_rebuild.pdf'),
 ('His side', 'Course', 'The half nobody talks about', 'A real short course on the male side, with an andrologist', 'his_side_rebuild.pdf'),
 ('His side', 'Product', 'Zinc / CoQ10', 'Real SKUs, at the doses the trials used', 'his_side_rebuild.pdf'),
 ('Mind and body', 'Consult', 'Talking to a psychologist', 'A real psychologist. Priced at Rs 799 in the brief', 'Mindbody_rebuild_final.pdf'),
 ('Mind and body', 'Audio', 'Calm listening track', 'A calm piece for the two-minute listen card and garbh session 4. Rights cleared. The brief says do NOT bundle one — the user picks their own — so this is optional', 'Mindbody_twelve_practice_cards.pdf'),
 ('After a loss', 'Consult', 'Talking to someone who does this', 'A counsellor who works with pregnancy loss', 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Course', 'After a loss, four sessions', 'A real group programme. Rs 1499 in the brief, referenced from Prepare, not a second copy', 'After_a_loss_rebuild.pdf'),
 ('After a loss', 'Community', 'Loss & Recovery room + Care Circle + the feed', 'Room names and descriptions. Posts come from members', 'After_a_loss_rebuild.pdf'),
]

# =============================================================================
#  Workbook
# =============================================================================
INK = '1F1A29'
HDR = PatternFill('solid', fgColor='2D144C')
BAND = PatternFill('solid', fgColor='F4F1F7')
NEWFILL = PatternFill('solid', fgColor='FFF4E5')
THIN = Side(style='thin', color='DDD8E3')
BORDER = Border(bottom=THIN)


def sheet(wb, name, head, widths, rows, wrap, newcol=None):
    ws = wb.create_sheet(name)
    ws.append(head)
    for c in range(1, len(head) + 1):
        cell = ws.cell(row=1, column=c)
        cell.font = Font(name='Arial', size=9, bold=True, color='FFFFFF')
        cell.fill = HDR
        cell.alignment = Alignment(vertical='center', wrap_text=True)
        ws.column_dimensions[get_column_letter(c)].width = widths[c - 1]
    ws.row_dimensions[1].height = 30
    for i, r in enumerate(rows):
        ws.append(list(r))
        rr = i + 2
        is_new = newcol is not None and str(r[newcol]).startswith('NEW')
        for c in range(1, len(head) + 1):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, color=INK)
            cell.alignment = Alignment(vertical='top', wrap_text=(c in wrap))
            cell.border = BORDER
            if is_new:
                cell.fill = NEWFILL
            elif i % 2:
                cell.fill = BAND
    ws.freeze_panes = 'A2'
    ws.auto_filter.ref = 'A1:%s%d' % (get_column_letter(len(head)), len(rows) + 1)
    return ws


def summary(wb):
    ws = wb.create_sheet('Read me first', 0)
    ws.column_dimensions['A'].width = 30
    for col in 'BCDEFGH':
        ws.column_dimensions[col].width = 15

    def t(row, txt, size=13, bold=True):
        c = ws.cell(row=row, column=1, value=txt)
        c.font = Font(name='Arial', size=size, bold=bold, color=INK)

    def note(row, txt):
        c = ws.cell(row=row, column=1, value=txt)
        c.font = Font(name='Arial', size=9, color='5A5265')
        c.alignment = Alignment(wrap_text=True, vertical='top')
        ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=8)
        ws.row_dimensions[row].height = 30

    t(1, 'Trying to conceive — what the seven doors need', 16)
    note(2, 'Every row comes from the rebuild brief for that door. The one door with no '
            'brief — Fertile window — is read from the app instead, and its rows say so '
            'in the Source column.')
    note(3, 'Tools are left out on purpose. "Where do I stand", "Check my readiness", '
            '"Read your semen report", the trackers and the checklists are software with '
            'copy inside them, not pieces somebody writes and hands over.')
    note(4, 'Rows shaded amber are NEW — nothing exists yet. The rest either exist as an '
            'AI-written draft that needs a real author, or are pointers into an article '
            'that already exists and need no new writing at all.')

    r = 6
    t(r, 'What each sheet holds')
    r += 1
    for name, what in [
        ('Written content', 'Articles, guides, myth-vs-fact cards, infographics, '
                            'carousels, practice cards and course sessions'),
        ('Videos', 'Every film, what it covers, how long, and whether it stands alone '
                   'or sits inside an article'),
        ('Images', 'Every picture, and what it belongs to. An image is never standalone'),
        ('Other', 'Consults, courses, products, community rooms and data'),
    ]:
        ws.cell(row=r, column=1, value=name).font = Font(name='Arial', size=9, bold=True, color=INK)
        c = ws.cell(row=r, column=2, value=what)
        c.font = Font(name='Arial', size=9, color=INK)
        c.alignment = Alignment(wrap_text=True, vertical='top')
        ws.merge_cells(start_row=r, start_column=2, end_row=r, end_column=8)
        ws.row_dimensions[r].height = 24
        r += 1

    r += 1
    t(r, 'Written content, by door')
    r += 1
    types = sorted({x[1] for x in W})
    ws.cell(row=r, column=1, value='Door').font = Font(name='Arial', size=9, bold=True, color='FFFFFF')
    ws.cell(row=r, column=1).fill = HDR
    for i, ty in enumerate(types):
        c = ws.cell(row=r, column=2 + i, value=ty)
        c.font = Font(name='Arial', size=8, bold=True, color='FFFFFF')
        c.fill = HDR
        c.alignment = Alignment(wrap_text=True, vertical='bottom')
    c = ws.cell(row=r, column=2 + len(types), value='Total')
    c.font = Font(name='Arial', size=9, bold=True, color='FFFFFF')
    c.fill = HDR
    ws.row_dimensions[r].height = 40
    r += 1
    first = r
    for d in DOORS:
        ws.cell(row=r, column=1, value=d)
        cnt = Counter(x[1] for x in W if x[0] == d)
        for i, ty in enumerate(types):
            ws.cell(row=r, column=2 + i, value=cnt.get(ty, 0))
        L1 = get_column_letter(2)
        L2 = get_column_letter(1 + len(types))
        ws.cell(row=r, column=2 + len(types), value='=SUM(%s%d:%s%d)' % (L1, r, L2, r))
        r += 1
    ws.cell(row=r, column=1, value='All doors')
    for i in range(len(types) + 1):
        L = get_column_letter(2 + i)
        ws.cell(row=r, column=2 + i, value='=SUM(%s%d:%s%d)' % (L, first, L, r - 1))
    for rr in range(first, r + 1):
        for c in range(1, 3 + len(types)):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, bold=(rr == r), color=INK)
            cell.border = BORDER

    r += 2
    t(r, 'Videos, images and the rest, by door')
    r += 1
    for i, h in enumerate(['Door', 'Videos', 'Image / animation jobs', 'Other']):
        c = ws.cell(row=r, column=1 + i, value=h)
        c.font = Font(name='Arial', size=9, bold=True, color='FFFFFF')
        c.fill = HDR
    r += 1
    first = r
    for d in DOORS:
        ws.cell(row=r, column=1, value=d)
        ws.cell(row=r, column=2, value=sum(1 for x in V if x[0] == d))
        ws.cell(row=r, column=3, value=sum(1 for x in I if x[0] == d))
        ws.cell(row=r, column=4, value=sum(1 for x in O if x[0] == d))
        r += 1
    ws.cell(row=r, column=1, value='Shared across all doors')
    ws.cell(row=r, column=3, value=sum(1 for x in I if x[0] == 'All doors'))
    r += 1
    ws.cell(row=r, column=1, value='All doors')
    for c in (2, 3, 4):
        L = get_column_letter(c)
        ws.cell(row=r, column=c, value='=SUM(%s%d:%s%d)' % (L, first, L, r - 1))
    for rr in range(first, r + 1):
        for c in range(1, 5):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, bold=(rr == r), color=INK)
            cell.border = BORDER
    ws.freeze_panes = 'A2'


if __name__ == '__main__':
    wb = Workbook()
    wb.remove(wb.active)
    summary(wb)
    Wx = [(d, t, ti, wh, criticality(ti, t, st), st, src)
          for (d, t, ti, wh, st, src) in W]
    sheet(wb, 'Written content',
          ['Door', 'Type', 'Title / topic', 'What it covers',
           'Medically critical?', 'Status', 'Source'],
          [20, 18, 44, 62, 30, 30, 28], Wx, wrap=(3, 4, 5, 6), newcol=5)
    Vx = [(d, ti, wh, ln, VIDEO_MAKER.get(ti, ('To be decided', ''))[0],
           VIDEO_MAKER.get(ti, ('', 'Not classified'))[1], st, sits, src)
          for (d, ti, wh, ln, st, sits, src) in V]
    sheet(wb, 'Videos',
          ['Door', 'Video title', 'What it covers', 'Length',
           'AI, or a real expert?', 'Why', 'Status',
           'Standalone, or inside an article?', 'Source'],
          [18, 36, 46, 13, 30, 50, 28, 40, 26], Vx, wrap=(2, 3, 5, 6, 7, 8),
          newcol=6)
    sheet(wb, 'Images',
          ['Door', 'What the image is', 'Kind', 'Size to deliver',
           'What it should show', 'What it belongs to', 'Source'],
          [18, 42, 20, 44, 62, 38, 26], I, wrap=(2, 4, 5, 6))
    sheet(wb, 'Other',
          ['Door', 'Type', 'Title', 'What we have to provide', 'Source'],
          [20, 14, 44, 66, 30], O, wrap=(3, 4))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    wb.save(OUT)
    print('written %d | videos %d | images %d | other %d'
          % (len(W), len(V), len(I), len(O)))
    print('NEW pieces to write: %d of %d' % (sum(1 for x in W if x[4] == NEW), len(W)))
    crit = Counter(criticality(ti, t, st) for (d, t, ti, wh, st, src) in W)
    for k, n in crit.most_common():
        print('   %-40s %3d' % (k, n))
    mk = Counter(VIDEO_MAKER.get(x[1], ('unclassified',))[0] for x in V)
    for k, n in mk.most_common():
        print('   video: %-34s %3d' % (k, n))
    print('-> %s' % os.path.relpath(OUT, ROOT))
