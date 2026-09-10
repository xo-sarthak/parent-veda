# =============================================================================
#  preg_door_content_xlsx.py -- what the ten pregnancy doors need made
# -----------------------------------------------------------------------------
#      python tools/preg_door_content_xlsx.py
#
#  Same shape as the TTC sheet, same three judgement columns (image size,
#  medical criticality, AI-or-expert on film). Source is the eight rebuild
#  briefs in Downloads/door-pdf/pregnancy-doors. Three doors have no brief --
#  Is it safe, Symptoms, Fitness & yoga -- and are read from the app instead,
#  marked "App" in the Source column.
#
#  ⚠️ THE HEADLINE FINDING, AND IT IS THE OPPOSITE OF TTC. Almost every brief
#  here opens by saying the area is ALREADY BUILT and must not be rewritten.
#  Nutrition says it outright: "nothing here is a new page to build... the only
#  two genuinely new items in this whole area are...". So the useful column is
#  not the count of pieces, it is how few of them are new. A team handed the
#  raw list would rewrite a finished product.
#
#  The exception is Mind & mood, where the brief rebuilds nine reads and adds
#  eight more -- and writes every word of them itself. Those rows say so.
# =============================================================================

import os
from collections import Counter, OrderedDict

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'docs', 'content-brief', 'PREGNANCY-DOOR-CONTENT.xlsx')

NEW = 'NEW — write from scratch'
WRITTEN = 'NEW — but the copy is already written in the brief'
REBUILD = 'REBUILD — replace thin existing copy'
DRAFT = 'Exists as a draft — needs a real author'
BUILT = 'Already built — reuse, do not rewrite'
PROMOTE = 'Pointer or reslot — no new writing'
REF = 'Owned by another door — no new writing'
RETITLE = 'Retitle only — content unchanged'

DOORS = ['Scans & tests', 'Complications & conditions', 'Is it safe?',
         'Nutrition & diet', 'Symptoms & discomforts', 'Labour & childbirth prep',
         'Garbh Sanskar & bonding', 'Fitness & yoga', 'Mind & mood', 'Belly & skin']

S_SCAN = 'Scans_and_tests_rebuild.pdf'
S_COMP = 'Complications_rebuild_clean.pdf'
S_NUTR = 'Nutrition_rebuild.pdf'
S_LAB = 'Labour_prep_rebuild.pdf'
S_GARB = 'Garbh_Sanskar_rebuild.pdf'
S_PILL = 'Garbh_Sanskar_pillars_build.pdf'
S_MIND = 'Mind_and_mood_final.pdf'
S_BELLY = 'Belly_and_skin_rebuild.pdf'
APP = 'App (no brief supplied)'

# -----------------------------------------------------------------------------
#  WRITTEN  (door, type, title, what it covers, status, source)
# -----------------------------------------------------------------------------
W = [
 # ---- Scans & tests -------------------------------------------------------
 ('Scans & tests', 'Article', 'Blood tests (weeks 6-10)', 'The early blood tests and what each checks', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'Dating scan (weeks 6-9)', 'The first scan and what it settles', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'NT scan (weeks 11-13)', 'Card line: checks the baby early growth and development', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'NIPT (weeks 10-14)', 'Card line: a blood test that checks for some conditions early', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'Anomaly scan (weeks 18-22)', 'Card line: the detailed scan that checks the baby head to toe', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'Sugar test / OGTT (weeks 24-28)', 'Card line: checks for pregnancy diabetes', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'Growth scan (weeks 28-36)', 'What a growth scan measures', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'Doppler scan (weeks 30-40)', 'Card line: checks the blood flow to the baby', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'Group B Strep (weeks 35-37)', 'Card line: a swab that checks for a common bacteria before birth', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'What the scan person can and cannot tell you', 'The limits of what a sonographer may say', BUILT, S_SCAN),
 ('Scans & tests', 'Article', 'A word on the report you do not know', 'The report glossary', BUILT, S_SCAN),
 ('Scans & tests', 'Guide', 'Why nobody will tell you the sex', 'The Indian law explained plainly, and that it is not the clinic being unkind. No legal jargon', NEW, S_SCAN),
 ('Scans & tests', 'Guide', 'What scans cost in India', 'Rough real INR ranges, and that prices vary by city and centre', NEW, S_SCAN),
 ('Scans & tests', 'Guide', 'Reading a report without panicking', 'One reading is one moment; ranges vary between labs; a single value is not a verdict', NEW, S_SCAN),
 ('Scans & tests', 'Guide', 'What to keep, and why', 'Which reports to hold on to. Short', NEW, S_SCAN),
 ('Scans & tests', 'Guide', 'Take it to your appointment', 'What to bring, and why it helps. Short', NEW, S_SCAN),
 ('Scans & tests', 'Myth vs fact', 'Do I need every scan on the list?', 'Not every pregnancy needs every test; the doctor decides', NEW, S_SCAN),
 ('Scans & tests', 'Checklist', 'What to ask at your next scan', 'A shareable list, same pattern as the PCOS doctor checklist', NEW, S_SCAN),
 ('Scans & tests', 'Result topics', 'Popular and all result topics', 'Low-lying placenta, cord around neck, pregnancy diabetes, breech, preeclampsia, low fluid and the rest. ⚠️ Remove the duplicate breech and cord entries', BUILT, S_SCAN),
 ('Scans & tests', 'Red flag card', 'Call your doctor if', 'Reduced movements; a bad headache with blurred vision or swelling', BUILT, S_SCAN),

 # ---- Complications & conditions ------------------------------------------
 ('Complications & conditions', 'Condition page', '10 condition pages', 'Gestational diabetes, thyroid, anaemia, hyperemesis, low-lying placenta, high BP, ectopic, breech, low fluid, cord around neck. Each: what it is, India stats, what you might notice, when to call, tests, management, what it means for the baby, FAQ', BUILT, S_COMP),
 ('Complications & conditions', 'Plain one-liner', 'A plain line under each condition name', 'e.g. "Gestational diabetes — pregnancy sugar goes high". Ten short lines, one per condition. This is the ONLY writing this door needs beyond the four items below', NEW, S_COMP),
 ('Complications & conditions', 'Red flag card', 'Signs to get help the same day', 'Bleeding; a bad headache with blurred eyes or swelling; the baby moving less; high fever; waters breaking early. ⚠️ ASSEMBLED from existing CALL NOW sections — no new medical advice', NEW, S_COMP),
 ('Complications & conditions', 'Guide', 'Bleeding in pregnancy', 'What is usually fine and what is not. Short', NEW, S_COMP),
 ('Complications & conditions', 'Guide', 'When the baby moves less', 'Do not wait, call the same day. Short', NEW, S_COMP),
 ('Complications & conditions', 'Guide', 'When blood pressure gets dangerous', 'Moved out of the High BP page into its own card', PROMOTE, S_COMP),
 ('Complications & conditions', 'Guide', 'Handling pregnancy sugar in India', 'Moved out of the gestational diabetes page', PROMOTE, S_COMP),
 ('Complications & conditions', 'Guide', 'The daily thyroid tablet', 'Moved out of the thyroid page', PROMOTE, S_COMP),
 ('Complications & conditions', 'Guide', 'Iron, from food and tablets', 'Moved out of the anaemia page', PROMOTE, S_COMP),
 ('Complications & conditions', 'Checklist', 'What to ask about your condition', 'Shareable appointment prep', NEW, S_COMP),
 ('Complications & conditions', 'Red flag card', 'When to call your doctor', 'The existing per-condition call list, pinned', BUILT, S_COMP),

 # ---- Is it safe? (no brief) ----------------------------------------------
 ('Is it safe?', 'Is-it-safe entry', '193 entries: 74 food, 60 activity, 35 medicine, 24 drink', 'Search any food, drink, medicine or activity and get Safe / Limit / Avoid with the reason', DRAFT, APP),
 ('Is it safe?', 'Craving entry', 'Craving pages + the About cravings section', 'Why cravings happen, sour/spicy/sweet/ice, aversions, pica, the eating-for-two myth. ⚠️ The Nutrition brief folds these into that door', BUILT, S_NUTR),

 # ---- Nutrition & diet ----------------------------------------------------
 ('Nutrition & diet', 'Guide', 'Add this to your plate now', 'ONE OF ONLY TWO NEW ITEMS IN THIS DOOR. One short card per trimester', NEW, S_NUTR),
 ('Nutrition & diet', 'Checklist', 'What to ask about your diet', 'THE OTHER NEW ITEM. Shareable appointment prep', NEW, S_NUTR),
 ('Nutrition & diet', 'Guide', 'Food for your stage (4 guides)', 'Before pregnancy, first, middle and last three months', BUILT, S_NUTR),
 ('Nutrition & diet', 'Guide', 'Eating for a condition (10 guides)', 'Pregnancy sugar, low iron, thyroid, PCOS, high BP, twins (all link to Complications); healthy weight gain, underweight, constipation and piles, brain foods (owned here)', BUILT, S_NUTR),
 ('Nutrition & diet', 'Guide', 'The twelve nutrients', 'Folic acid, iron, calcium, protein, vitamin D, B12, omega-3, iodine, fibre, zinc, magnesium, vitamin C. Each: what it does / everyday Indian foods / do I need a supplement', BUILT, S_NUTR),
 ('Nutrition & diet', 'Guide', 'The bigger questions', 'Prenatal vitamins; iron and calcium timing; veg and vegan protein and B12; is my thali enough', BUILT, S_NUTR),
 ('Nutrition & diet', 'Recipe', 'The recipe library', 'Bengali macher jhol, shukto, Tamil ragi kanji, sambar and the rest. Filter by need and by region', BUILT, S_NUTR),
 ('Nutrition & diet', 'Diet chart', 'Every diet chart', '3-day plans with swaps and go-easy-on. Filter by stage, diet type, condition, region, Hindi', BUILT, S_NUTR),
 ('Nutrition & diet', 'Guide', 'Fasting, by occasion', 'Navratri, Ramzan, Karva Chauth, Ekadashi, Jain fasts', BUILT, S_NUTR),
 ('Nutrition & diet', 'Guide', 'Fasting, in general', 'Should I fast at all? How to fast safely. When to skip it this year', BUILT, S_NUTR),
 ('Nutrition & diet', 'Food entry', 'Every food page, Safe / Limit / Avoid', 'The food checker and its category chips', BUILT, S_NUTR),

 # ---- Symptoms & discomforts (no brief) -----------------------------------
 ('Symptoms & discomforts', 'Symptom entry', '11 everyday symptoms', 'Nausea, heartburn, constipation, fatigue, back pain, headache, trouble sleeping, mood swings, swelling, leg cramps, baby hiccups. Each: is it usual at this stage, and what helps', DRAFT, APP),
 ('Symptoms & discomforts', 'Symptom entry', '6 warning symptoms', '⚠️ Braxton Hicks, heavy bleeding, reduced baby movement, severe headache, sudden swelling, fluid leakage. These are the ones that route to a doctor', DRAFT, APP),

 # ---- Labour & childbirth prep --------------------------------------------
 ('Labour & childbirth prep', 'Guide', 'Pain relief: natural, epidural and C-section', 'THE ONLY NEW ITEM IN THIS DOOR. A short free primer; the paid class covers it in depth', NEW, S_LAB),
 ('Labour & childbirth prep', 'Article', 'If it becomes a C-section', 'What a C-section is and what happens. 6 min', BUILT, S_LAB),
 ('Labour & childbirth prep', 'Article', 'The first hour after birth', 'The golden hour. 5 min', BUILT, S_LAB),
 ('Labour & childbirth prep', 'Article', 'What your partner should actually do', 'For him, 5 min', BUILT, S_LAB),
 ('Labour & childbirth prep', 'Guide', 'What labour is actually like, and your options', 'From Prepare for birth', BUILT, S_LAB),
 ('Labour & childbirth prep', 'Guide', 'Your birth plan, and how to make one', 'Pulled out of the old accordion into its own card', PROMOTE, S_LAB),
 ('Labour & childbirth prep', 'Guide', 'What to pack for whoever comes with you', 'Links to Partner & extras in the hospital bag. Single source', REF, S_LAB),
 ('Labour & childbirth prep', 'Course class', 'Complete Birthing Course — 6 classes', 'Stages of labour (22 min), breathing and relaxation (18), positions and movement (20), pain relief (24), partner as birth support (16), the golden hour (15). Meera Nair, OB-reviewed, EN and Hindi, Rs 1,499', BUILT, S_LAB),
 ('Labour & childbirth prep', 'Safety line', "We can't tell you if it's labour, but your doctor can", '⚠️ REWRITE of the timer disclaimer into human voice. Keeps the safety, drops the legal tone', REBUILD, S_LAB),
 ('Labour & childbirth prep', 'Safety line', 'If anything feels off, call your doctor, even if this screen looks calm', '⚠️ REWRITE of the area disclaimer into human voice', REBUILD, S_LAB),
 ('Labour & childbirth prep', 'Checklist copy', 'Hospital bag: 42 items', 'Documents (6), Mom (21), Baby (10), Partner & extras (5), plus the India tips: bag by the door at full term, monsoon cover and a dry set, hospitals give a cot', BUILT, S_LAB),

 # ---- Garbh Sanskar & bonding ---------------------------------------------
 ('Garbh Sanskar & bonding', 'Note', 'Where this comes from', 'THE ONLY NEW ITEM IN THE REBUILD. The voice part has real evidence; the rest is a calming ritual; it promises nothing about the child intelligence or nature', NEW, S_GARB),
 ('Garbh Sanskar & bonding', 'Affirmation', 'About 20 affirmations spoken to the baby', 'Expand the existing six ("You are loved", "Grow gently") to about twenty', NEW, S_PILL),
 ('Garbh Sanskar & bonding', 'Story', '6 to 8 short gentle stories', '⚠️ PUBLIC DOMAIN ONLY (Panchatantra, Aesop) or original. Short enough to read aloud in a few minutes', NEW, S_PILL),
 ('Garbh Sanskar & bonding', 'Mantras and lullabies', 'A set of traditional mantras and lullabies', '⚠️ PUBLIC DOMAIN ONLY. Each with text, a simple transliteration and a one-line plain meaning, plus two or three original lullabies. No copyrighted lyrics', NEW, S_PILL),
 ('Garbh Sanskar & bonding', 'Spiritual reading', 'Short passages by tradition', '⚠️ PUBLIC-DOMAIN scripture translations only (Gita, Bible, Quran) or original reflective text. She picks the tradition; default none', NEW, S_PILL),
 ('Garbh Sanskar & bonding', 'Practice script', 'Guided relaxation script, 8 min head to toe', 'A written progressive-relaxation script, narrated by TTS for now, data-driven so a recorded voice can replace it', NEW, S_PILL),
 ('Garbh Sanskar & bonding', 'Ritual copy', 'My ritual — 8 faith options', 'Gita paath (40-week plan), a Quran passage, five minutes of silence, japa with a counter, a Bible passage, Hanuman Chalisa, daily pravachan, Sundarkand', BUILT, S_GARB),
 ('Garbh Sanskar & bonding', 'Note', 'This one is for you, and it will not make your baby cleverer', '⚠️ DO NOT SOFTEN OR REMOVE. The honesty line on the Buddhi games', BUILT, S_GARB),
 ('Garbh Sanskar & bonding', 'Red flag card', 'Stop and call your doctor today if', 'Bleeding or fluid leaking; new belly, chest or back pain; a tight painful belly that will not settle; dizziness, bad headache or blurred vision; trouble breathing or racing heart; the baby moving less', BUILT, S_GARB),
 ('Garbh Sanskar & bonding', 'Game', 'Four games: word search, sudoku, logic puzzle, memory match', 'For her, no score pressure, none saves to the Journal', BUILT, S_PILL),

 # ---- Fitness & yoga (no brief) -------------------------------------------
 ('Fitness & yoga', 'Class description', '21 yoga sessions', 'A short session for her stage, with what to avoid this trimester', DRAFT, APP),
 ('Fitness & yoga', 'Safety copy', 'What to avoid this trimester', '⚠️ The per-trimester movement cautions. Owned here; Garbh Sanskar links across rather than rebuilding', DRAFT, APP),

 # ---- Mind & mood ---------------------------------------------------------
 ('Mind & mood', 'Tool copy', 'A hard-day reset', 'A 3-minute guided screen, four steps. ⚠️ FULL COPY ALREADY WRITTEN in the brief, use verbatim', WRITTEN, S_MIND),
 ('Mind & mood', 'Affirmation', 'Affirmations — 18 lines', 'A rotating set, for her, never about the baby. ⚠️ FULL COPY ALREADY WRITTEN, use verbatim', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'One minute okay, next minute not', 'Is this normal? ⚠️ FULL COPY WRITTEN. Byline Dr Sharanya Menon', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Crying at everything', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Short temper, and the guilt after', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Not feeling the bond yet', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'The guilt that follows you around', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Forgetting everything', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'When it all feels like too much', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Numb, when everyone says you should be glowing', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Lonely, even in a full house', 'Is this normal? ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'When everyone polices what you eat and do', 'What no one talks about. India-first. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Log kya kahenge', 'What no one talks about. India-first. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'The secret months, carried alone', 'What no one talks about. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', "When the baby's gender becomes everyone's business", 'What no one talks about. India-first. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', "No corner of the house that's yours", 'What no one talks about. Joint families. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'When the nuskhe and the superstitions start', 'What no one talks about. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', "Bringing him in, when he doesn't get it", 'What no one talks about. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Fear of being a bad mother', 'Fears. ⚠️ FULL COPY WRITTEN', WRITTEN, S_MIND),
 ('Mind & mood', 'Article', 'Fear of labour', 'Reuse, plus a line linking to Labour prep', REF, S_MIND),
 ('Mind & mood', 'Article', 'Fear something is wrong with the baby', 'Reuse, links to Scans & tests', REF, S_MIND),
 ('Mind & mood', 'Article', 'Baby blues, or something more?', '⚠️ FULL COPY WRITTEN. The line between the blues and something that needs help', WRITTEN, S_MIND),
 ('Mind & mood', 'Red flag card', 'When to reach out the same day', '⚠️ FULL COPY WRITTEN. Carries the self-harm line: "any thought of harming yourself or the baby"', WRITTEN, S_MIND),
 ('Mind & mood', 'Guide', 'Helpline numbers', 'India perinatal and mental-health helplines. ⚠️ Real numbers, verified, kept current', NEW, S_MIND),
 ('Mind & mood', 'Guide', 'Tell your doctor', 'How to raise it, with Ask Veda to help word it', NEW, S_MIND),
 ('Mind & mood', 'Article', 'Your partner can feel this too', 'Optional in the brief', NEW, S_MIND),

 # ---- Belly & skin --------------------------------------------------------
 ('Belly & skin', 'Article', 'Stretch marks — 4 reads', 'Why they happen; what actually helps and what does not; oils and creams; fading after delivery. Keeps the "largely genetic, no cream changes that" honesty', BUILT, S_BELLY),
 ('Belly & skin', 'Article', 'The dark line (linea nigra)', '⚠️ RETITLE ONLY, was "The linea nigra (the dark line)". Plain word first', RETITLE, S_BELLY),
 ('Belly & skin', 'Article', 'The pregnancy mask (melasma)', '⚠️ RETITLE ONLY, was "Melasma (the pregnancy mask)". Plain word first', RETITLE, S_BELLY),
 ('Belly & skin', 'Article', 'Pigmentation and skin — 5 more reads', 'Darker underarms neck and thighs; pregnancy acne; the pregnancy glow; dry or sensitive skin; spider veins and skin tags; hair changes', BUILT, S_BELLY),
 ('Belly & skin', 'Article', 'Itchy skin in pregnancy, explained', '⚠️ CARRIES A RED FLAG: intense itching of palms and soles with no rash means call your doctor today', BUILT, S_BELLY),
 ('Belly & skin', 'Article', 'Safe skincare — 4 reads', 'What to avoid; what is safe; a simple safe daily routine; are facials and salon treatments okay', BUILT, S_BELLY),
 ('Belly & skin', 'Article', 'Belly care — 3 reads', 'Belly oiling and gentle massage; belly bands and support; comfort for the growing bump', BUILT, S_BELLY),
 ('Belly & skin', 'Ingredient entry', 'Ingredient Safety Checker list', 'Retinoids, sunscreen, niacinamide, salicylic, hair dye, keratin, hydroquinone, hyaluronic and the rest. FREE. ⚠️ Owns all skincare and salon verdicts; Is it safe? links here', BUILT, S_BELLY),
]

# -----------------------------------------------------------------------------
#  VIDEOS  (door, title, covers, length, status, sits where, source)
# -----------------------------------------------------------------------------
V = [
 ('Labour & childbirth prep', 'The contraction timer, in two minutes', 'How to use the timer', '2 min', BUILT, 'Standalone, on the timer tab. COMING SOON', S_LAB),
 ('Labour & childbirth prep', 'Labour, start to finish', 'The whole of labour, walked through', '12 min', BUILT, 'Standalone in "What actually happens". COMING SOON', S_LAB),
 ('Labour & childbirth prep', 'Watch the free trailer', 'The birthing course trailer', '2 min', BUILT, 'Standalone, FREE, in the paid layer', S_LAB),
 ('Labour & childbirth prep', 'Class 1: The stages of labour, demystified', 'Birthing course, free preview class', '22 min', BUILT, 'Inside the Complete Birthing Course', S_LAB),
 ('Labour & childbirth prep', 'Class 2: Breathing and relaxation that actually works', 'Birthing course', '18 min', BUILT, 'Inside the course', S_LAB),
 ('Labour & childbirth prep', 'Class 3: Positions and movement for an easier labour', 'Birthing course', '20 min', BUILT, 'Inside the course', S_LAB),
 ('Labour & childbirth prep', 'Class 4: Pain relief: natural, epidural and C-section', 'Birthing course', '24 min', BUILT, 'Inside the course', S_LAB),
 ('Labour & childbirth prep', 'Class 5: Your partner as birth support', 'Birthing course. Also surfaced on the partner tab', '16 min', BUILT, 'Inside the course; the partner tab LINKS to it, single source', S_LAB),
 ('Labour & childbirth prep', 'Class 6: The golden hour, the first hour after birth', 'Birthing course', '15 min', BUILT, 'Inside the course', S_LAB),
 ('Nutrition & diet', 'Do I actually need supplements?', 'Whether prenatal supplements are needed at all', 'unstated', BUILT, 'Standalone in Nutrients. COMING SOON', S_NUTR),
 ('Belly & skin', 'Why stretch marks happen', 'The honest version: largely genetic', 'unstated', BUILT, 'INSIDE the stretch-marks read. COMING SOON', S_BELLY),
 ('Belly & skin', 'Itchy skin in pregnancy', 'Itching, and the palms-and-soles warning', 'unstated', BUILT, 'INSIDE the itching read. COMING SOON', S_BELLY),
 ('Complications & conditions', '4-part video series, per condition', 'A short series on each of the ten conditions', 'unstated', BUILT, 'INSIDE each condition page. COMING SOON — 40 films if built for all ten', S_COMP),
 ('Mind & mood', 'Box / 4-7-8 / Slow-down, guided', 'Watch-along versions of the three breathing practices', 'unstated', BUILT, 'Standalone on Feel. COMING SOON', S_MIND),
 ('Garbh Sanskar & bonding', 'Body Awareness Journey', 'A spoken body-scan', '9 min', BUILT, 'Standalone in Listen. Audio, TTS for now', S_PILL),
]

# -----------------------------------------------------------------------------
#  IMAGES
# -----------------------------------------------------------------------------
CARD = ('426 x 528 px  (142x176 pt @3x, portrait 4:5). FULL-BLEED: the title is '
        'laid over the picture, so keep the lower third calm')
HERO = '1800 x 1400 px  (cropped to roughly 16:10 on screen)'
CARO = '1080 x 438 px  (full width strip)'
INFO = '1080 x 1920 px  (full-screen portrait page)'
PROD = '1000 x 1000 px  (square, plain background)'
RIVE = 'Rive vector file, not pixels'
SQ = '1080 x 1080 px  (square)'

I = [
 ('All 10 doors', 'Door hero photograph', 'Door hero', HERO, 'One per door. Indian, warm, unposed. The tone differs per door: Complications calm not frightening; Mind & mood quiet; Belly & skin close and gentle; Labour prep steady', 'The door itself', 'All briefs'),
 ('All 10 doors', 'Card art for every content card', 'Card art', CARD, 'One per card, roughly 130 across the ten doors. The title sits ON the picture, so the lower third must stay uncluttered', 'Every article, guide, video, myth, tool, consult and course card', 'All briefs'),

 ('Scans & tests', 'Scan illustrations', 'Illustration', SQ, 'One per scan: what the machine looks like, what happens in the room. 9 scans', 'The nine scan pages', S_SCAN),
 ('Scans & tests', 'Result-topic artwork', 'Illustration', SQ, 'Low-lying placenta, cord around neck, breech, low fluid and the rest — a simple picture beats a paragraph for each', 'The result topic pages', S_SCAN),
 ('Complications & conditions', 'Condition illustrations', 'Illustration', SQ, 'One per condition, 10 total. Calm and diagrammatic, never frightening', 'The ten condition pages', S_COMP),
 ('Nutrition & diet', 'Food photography', 'Food photo', SQ, 'One per food page in the checker. Real Indian foods as they are actually served', 'Every food page (74 food entries)', S_NUTR),
 ('Nutrition & diet', 'Recipe photography', 'Food photo', '1080 x 1080 px square, plus 1080 x 810 px header', 'Real regional Indian dishes, home-cooked, not styled Western food', 'Every recipe in the library', S_NUTR),
 ('Nutrition & diet', 'Nutrient artwork', 'Illustration', SQ, 'One per nutrient, 12 total. What it does, shown simply', 'The twelve nutrient pages', S_NUTR),
 ('Nutrition & diet', 'Diet chart artwork', 'Infographic artwork', INFO, 'A readable 3-day plan layout, one per chart', 'Every diet chart', S_NUTR),
 ('Symptoms & discomforts', 'Symptom illustrations', 'Illustration', SQ, 'One per symptom, 17 total. Where it is felt and what helps', 'The seventeen symptom pages', APP),
 ('Labour & childbirth prep', 'Hospital bag item artwork', 'Icon art', '256 x 256 px each', 'A small icon per packing item, 42 across Documents, Mom, Baby and Partner', 'The Ready for Birth packer', S_LAB),
 ('Labour & childbirth prep', 'Birthing course class art', 'Card art', CARD, 'One per class, 6 total, plus a course cover', 'The Complete Birthing Course', S_LAB),
 ('Belly & skin', 'Skin change photography', 'Photo', SQ, '⚠️ THE HARDEST BRIEF HERE. Real Indian skin tones showing linea nigra, melasma, darkening in folds, stretch marks and their fading. Stock libraries are overwhelmingly pale skin; this needs commissioning', 'The pigmentation and stretch-mark reads', S_BELLY),
 ('Belly & skin', 'Ingredient artwork', 'Product photo', PROD, 'A packshot or ingredient image per checker entry', 'The Ingredient Safety Checker', S_BELLY),
 ('Garbh Sanskar & bonding', 'Raga and track cover art', 'Audio cover', SQ, 'One per audio track, 10 total. Calm, no religious iconography that excludes anyone', 'The Shravan sound library', S_GARB),
 ('Garbh Sanskar & bonding', 'Story illustrations', 'Illustration', SQ, 'One per story, 6 to 8 total', 'The Samvad story library', S_PILL),
 ('Garbh Sanskar & bonding', 'Outline figure for body relaxation', 'Movement animation', RIVE + '. 8-minute pass down the body', 'A simple outline figure with the current body part highlighted. SHARED with the TTC Mind & body practice cards — build once', 'Kriya guided relaxation', S_PILL),
 ('Garbh Sanskar & bonding', 'Breathing circle component', 'Movement animation', 'Built in code, no artwork needed', 'A circle that grows on the in-breath, holds, shrinks on the out-breath, with phase word and live count. SHARED with TTC and with Mind & mood', 'Kriya breathing practices', S_PILL),
 ('Fitness & yoga', 'Pose photography or animation', 'Movement animation', RIVE + ', or filmed', '⚠️ One per pose. A yoga pose taught from a model that cannot be checked is a safety problem, so this needs a real instructor either filmed or motion-referenced', 'The 21 yoga sessions', APP),
 ('Mind & mood', 'Affirmation card art', 'Card art', CARD, 'A calm backdrop for the rotating affirmations', 'The Affirmations tool', S_MIND),
 ('Is it safe?', 'Food and item artwork', 'Illustration', SQ, 'A small picture per entry helps recognition far more than text for 193 entries', 'The Is-it-safe entries', APP),
]

# -----------------------------------------------------------------------------
#  OTHER
# -----------------------------------------------------------------------------
O = [
 ('Garbh Sanskar & bonding', 'Audio', '10 audio tracks', '⚠️ ROYALTY-FREE, CC0 OR PUBLIC DOMAIN ONLY. 5 ragas (7, 7, 8, 10, 6 min), 4 nature sounds (15, 15, 12, 8 min), 1 guided body scan (9 min). Every asset logged in a manifest with source URL and licence so it can be swapped later', S_PILL),
 ('Garbh Sanskar & bonding', 'Audio', 'Narration for the reading library', 'On-device text-to-speech now, wired so a recorded professional narrator can replace it per passage with no code change', S_PILL),
 ('Garbh Sanskar & bonding', 'Legal', 'The assets manifest', 'One manifest listing every sourced asset with its source URL and licence, for review and later replacement', S_PILL),
 ('Mind & mood', 'Expert', 'Dr Sharanya Menon, perinatal psychologist', 'A real perinatal psychologist to author and sign the 20 Understand reads. The brief already carries the byline', S_MIND),
 ('Mind & mood', 'Consult', 'Three paid tiers', 'Perinatal mental-health counselling (Rs 999, anonymous), one-on-one (Rs 749), ongoing check-in package', S_MIND),
 ('Mind & mood', 'Data', 'India perinatal helpline numbers', '⚠️ Real, verified, current numbers. A dead helpline number in a mental-health surface is the worst possible failure', S_MIND),
 ('Labour & childbirth prep', 'Course', 'Complete Birthing Course', 'Meera Nair, certified childbirth educator, OB-reviewed. 6 classes, EN and Hindi, Rs 1,499 one-time, monthly live Q&A', S_LAB),
 ('Labour & childbirth prep', 'Consult', 'Book a 1:1 about the birth', 'A real childbirth educator or obstetrician', S_LAB),
 ('Nutrition & diet', 'Consult', 'Four paid dietician tiers', 'Personal diet plan, weekly expert calls, daily diet management, book one session. ⚠️ Keep pricing and labels exactly as built', S_NUTR),
 ('Scans & tests', 'Consult', 'Have a doctor go through it with you', 'A real obstetrician or radiologist to read a report with her', S_SCAN),
 ('Scans & tests', 'Data', 'What scans cost in India', 'Real INR ranges per scan, by city tier, refreshed on a schedule', S_SCAN),
 ('Complications & conditions', 'Consult', 'Have a doctor explain your condition', 'A real obstetrician', S_COMP),
 ('Complications & conditions', 'Data', 'How common this is in India', 'Indian prevalence statistics per condition, sourced and dated', S_COMP),
 ('Belly & skin', 'Data', 'Ingredient safety verdicts', 'The SAFE / LIMIT / AVOID call per ingredient, verified by a dermatologist', S_BELLY),
 ('Is it safe?', 'Data', '193 safety verdicts', 'Each Safe / Limit / Avoid call verified by an obstetrician and a pharmacist. This is the most-used surface in the stage', APP),
 ('Fitness & yoga', 'Expert', 'A prenatal yoga instructor', 'To design and demonstrate the 21 sessions, and to write the per-trimester cautions', APP),
]

# =============================================================================
#  Criticality and film-maker classifiers
# =============================================================================
CRITICAL = 'CRITICAL — verify before it ships'
CLINICAL = 'Clinical — a doctor signs it'
SOFT = 'Not clinical — an editor is enough'

_CRIT = {
    'Signs to get help the same day', 'Bleeding in pregnancy', 'When the baby moves less',
    'When blood pressure gets dangerous', 'Call your doctor if', 'When to call your doctor',
    'When to reach out the same day', 'Baby blues, or something more?',
    'Stop and call your doctor today if', 'Itchy skin in pregnancy, explained',
    '6 warning symptoms', '10 condition pages', '193 entries: 74 food, 60 activity, 35 medicine, 24 drink',
    'A plain line under each condition name', 'Helpline numbers',
    "We can't tell you if it's labour, but your doctor can",
    'If anything feels off, call your doctor, even if this screen looks calm',
    'Reading a report without panicking', 'Do I need every scan on the list?',
    'Result topics', 'Popular and all result topics', 'The daily thyroid tablet',
    'Handling pregnancy sugar in India', 'Iron, from food and tablets',
    'Pain relief: natural, epidural and C-section', 'Ingredient Safety Checker list',
    'What to avoid this trimester', '21 yoga sessions',
}
_SOFT = {
    'Log kya kahenge', 'The secret months, carried alone',
    "When the baby's gender becomes everyone's business",
    "No corner of the house that's yours", "Bringing him in, when he doesn't get it",
    'When everyone polices what you eat and do', 'Affirmations — 18 lines',
    'A hard-day reset', 'Your partner can feel this too', 'What scans cost in India',
    'Why nobody will tell you the sex', 'What to keep, and why',
    'Take it to your appointment', 'My ritual — 8 faith options',
    'Where this comes from', 'About 20 affirmations spoken to the baby',
    '6 to 8 short gentle stories', 'Mantras and lullabies',
    'A set of traditional mantras and lullabies', 'Short passages by tradition',
    'Game', 'Four games: word search, sudoku, logic puzzle, memory match',
    'Your birth plan, and how to make one', 'The first hour after birth',
    'What your partner should actually do', 'What to pack for whoever comes with you',
    'Checklist copy', 'Hospital bag: 42 items', 'Fasting, by occasion',
    'The recipe library', 'Add this to your plate now',
}


def criticality(title, ctype, status):
    if title in _CRIT:
        return CRITICAL
    if status == REF:
        return 'n/a — owned by another door'
    if title in _SOFT or ctype in ('Note', 'Game', 'Affirmation', 'Ritual copy',
                                   'Story', 'Spiritual reading', 'Checklist copy'):
        return SOFT
    if ctype in ('Red flag card', 'Safety line', 'Symptom entry', 'Condition page',
                 'Is-it-safe entry', 'Ingredient entry'):
        return CRITICAL
    return CLINICAL


AI_OK = 'AI or animation — no face needed'
AI_VO = 'AI animation, but a doctor must sign the script'
EXPERT = 'Real expert on camera'
FILMED = 'Filmed with a real person (movement)'

MAKER = {
 'The contraction timer, in two minutes': (AI_OK, 'A screen walkthrough of the app itself'),
 'Labour, start to finish': (AI_VO, 'A process, stage by stage. Animation explains it without a birth being filmed'),
 'Watch the free trailer': (EXPERT, 'It sells the educator, so it has to be her'),
 'Class 1: The stages of labour, demystified': (EXPERT, 'Meera Nair teaching. The whole course is her'),
 'Class 2: Breathing and relaxation that actually works': (FILMED, 'Breathing demonstrated by a real person'),
 'Class 3: Positions and movement for an easier labour': (FILMED, 'Movement instruction. Never animate a position being taught'),
 'Class 4: Pain relief: natural, epidural and C-section': (EXPERT, 'Clinical choices explained by a person she trusts'),
 'Class 5: Your partner as birth support': (FILMED, 'Two people practising together'),
 'Class 6: The golden hour, the first hour after birth': (EXPERT, 'Emotional and clinical at once'),
 'Do I actually need supplements?': (AI_VO, 'A claims explainer. Animation, dietitian-signed script'),
 'Why stretch marks happen': (AI_VO, 'A mechanism explainer about skin and collagen'),
 'Itchy skin in pregnancy': (EXPERT, 'It carries a red flag. A dermatologist or obstetrician says it'),
 '4-part video series, per condition': (EXPERT, '⚠️ 40 films if built for all ten conditions. Each is a doctor explaining a diagnosis — decide the scope before commissioning'),
 'Box / 4-7-8 / Slow-down, guided': (AI_OK, 'The breathing circle is already built in code; a watch-along needs no face'),
 'Body Awareness Journey': (AI_OK, 'A spoken body scan over a calm visual. Voice only, and TTS covers it until a voice is recorded'),
}

# =============================================================================
#  Workbook
# =============================================================================
INK = '1F1A29'
HDR = PatternFill('solid', fgColor='2D144C')
BAND = PatternFill('solid', fgColor='F4F1F7')
NEWFILL = PatternFill('solid', fgColor='FFF4E5')
BUILTFILL = PatternFill('solid', fgColor='E7F3EC')
THIN = Side(style='thin', color='DDD8E3')
BORDER = Border(bottom=THIN)


def sheet(wb, name, head, widths, rows, wrap, statuscol=None):
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
        st = str(r[statuscol]) if statuscol is not None else ''
        for c in range(1, len(head) + 1):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, color=INK)
            cell.alignment = Alignment(vertical='top', wrap_text=(c in wrap))
            cell.border = BORDER
            if st.startswith('NEW') or st.startswith('REBUILD'):
                cell.fill = NEWFILL
            elif st.startswith('Already built'):
                cell.fill = BUILTFILL
            elif i % 2:
                cell.fill = BAND
    ws.freeze_panes = 'A2'
    ws.auto_filter.ref = 'A1:%s%d' % (get_column_letter(len(head)), len(rows) + 1)


def summary(wb):
    ws = wb.create_sheet('Read me first', 0)
    ws.column_dimensions['A'].width = 34
    for col in 'BCDEFGH':
        ws.column_dimensions[col].width = 16

    def t(row, txt, size=13):
        ws.cell(row=row, column=1, value=txt).font = Font(name='Arial', size=size, bold=True, color=INK)

    def note(row, txt, h=30):
        c = ws.cell(row=row, column=1, value=txt)
        c.font = Font(name='Arial', size=9, color='5A5265')
        c.alignment = Alignment(wrap_text=True, vertical='top')
        ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=8)
        ws.row_dimensions[row].height = h

    t(1, 'Pregnancy — what the ten doors need', 16)
    note(2, 'THE HEADLINE: pregnancy is largely already built. Almost every brief opens by '
            'saying so, and Nutrition says it outright — "nothing here is a new page to '
            'build". Green rows are finished content: do NOT send them out to be rewritten. '
            'Amber rows are the real ask.', 42)
    note(3, 'Eight of the ten doors have a rebuild brief. Three do not — Is it safe, '
            'Symptoms and Fitness & yoga — and those rows are read from the app instead, '
            'marked "App (no brief supplied)" in the Source column.', 30)
    note(4, 'Tools are excluded, as in the TTC sheet: the timer, the packer, the checkers, '
            'the mood log and the report locker are software, not pieces to write.', 30)

    r = 6
    t(r, 'Written content by door, and how much is genuinely new')
    r += 1
    for i, h in enumerate(['Door', 'Rows', 'NEW to write', 'Copy already written',
                           'Rebuild / retitle', 'Already built', 'Pointer / owned elsewhere']):
        c = ws.cell(row=r, column=1 + i, value=h)
        c.font = Font(name='Arial', size=9, bold=True, color='FFFFFF')
        c.fill = HDR
        c.alignment = Alignment(wrap_text=True, vertical='bottom')
    ws.row_dimensions[r].height = 32
    r += 1
    first = r
    for d in DOORS:
        rows = [x for x in W if x[0] == d]
        ws.cell(row=r, column=1, value=d)
        ws.cell(row=r, column=2, value=len(rows))
        ws.cell(row=r, column=3, value=sum(1 for x in rows if x[4] == NEW))
        ws.cell(row=r, column=4, value=sum(1 for x in rows if x[4] == WRITTEN))
        ws.cell(row=r, column=5, value=sum(1 for x in rows if x[4] in (REBUILD, RETITLE)))
        ws.cell(row=r, column=6, value=sum(1 for x in rows if x[4] in (BUILT, DRAFT)))
        ws.cell(row=r, column=7, value=sum(1 for x in rows if x[4] in (PROMOTE, REF)))
        r += 1
    ws.cell(row=r, column=1, value='All ten doors')
    for c in range(2, 8):
        L = get_column_letter(c)
        ws.cell(row=r, column=c, value='=SUM(%s%d:%s%d)' % (L, first, L, r - 1))
    for rr in range(first, r + 1):
        for c in range(1, 8):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, bold=(rr == r), color=INK)
            cell.border = BORDER

    r += 2
    t(r, 'Videos, images and the rest')
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
    ws.cell(row=r, column=3, value=sum(1 for x in I if x[0] == 'All 10 doors'))
    r += 1
    ws.cell(row=r, column=1, value='All ten doors')
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
    Wx = [(d, t, ti, wh, criticality(ti, t, st), st, src) for (d, t, ti, wh, st, src) in W]
    sheet(wb, 'Written content',
          ['Door', 'Type', 'Title / topic', 'What it covers', 'Medically critical?',
           'Status', 'Source'],
          [24, 18, 42, 66, 30, 34, 26], Wx, wrap=(3, 4, 5, 6), statuscol=5)
    Vx = [(d, ti, wh, ln, MAKER.get(ti, ('To be decided', ''))[0],
           MAKER.get(ti, ('', 'Not classified'))[1], st, sits, src)
          for (d, ti, wh, ln, st, sits, src) in V]
    sheet(wb, 'Videos',
          ['Door', 'Video title', 'What it covers', 'Length', 'AI, or a real expert?',
           'Why', 'Status', 'Standalone, or inside something?', 'Source'],
          [24, 38, 40, 12, 30, 50, 28, 42, 24], Vx, wrap=(2, 3, 5, 6, 7, 8), statuscol=6)
    sheet(wb, 'Images',
          ['Door', 'What the image is', 'Kind', 'Size to deliver', 'What it should show',
           'What it belongs to', 'Source'],
          [22, 38, 20, 42, 64, 38, 24], I, wrap=(2, 4, 5, 6))
    sheet(wb, 'Other',
          ['Door', 'Type', 'Item', 'What we have to provide', 'Source'],
          [24, 14, 40, 70, 24], O, wrap=(3, 4))
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    wb.save(OUT)
    print('written %d | videos %d | images %d | other %d' % (len(W), len(V), len(I), len(O)))
    c = Counter(x[4] for x in W)
    for k, n in c.most_common():
        print('   %-46s %3d' % (k, n))
    cr = Counter(criticality(ti, t, st) for (d, t, ti, wh, st, src) in W)
    print()
    for k, n in cr.most_common():
        print('   %-46s %3d' % (k, n))
    print('-> %s' % os.path.relpath(OUT, ROOT))
