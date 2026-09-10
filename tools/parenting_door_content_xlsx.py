# =============================================================================
#  parenting_door_content_xlsx.py -- what the eleven parenting doors need made
# -----------------------------------------------------------------------------
#      python tools/parenting_door_content_xlsx.py
#
#  Third and last of the per-stage door sheets, same shape and the same three
#  judgement columns as TTC and Pregnancy: image size, medical criticality on
#  written pieces, AI-or-a-real-expert on film.
#
#  Source is the twelve rebuild briefs in Downloads/door-pdf/parenting-doors.
#  Twelve PDFs, eleven doors: Development has two and the later one
#  ("Development, reissued") says in its own footer that it REPLACES the
#  earlier file, so the reissued one is what is read here.
#
#  ⚠️ THE HEADLINE, AND IT IS THE SAME SHAPE AS PREGNANCY, NOT TTC. Every one
#  of these briefs opens with "REUSE, DO NOT REBUILD" in capitals. The written
#  content is largely finished. What parenting is actually short of is not
#  words, it is FILM AND AUDIO: roughly 150 film slots across the eleven doors
#  and 58 story audios, almost none of them shot or recorded. A team handed the
#  raw page list would rewrite a finished product and still not have the thing
#  that is missing.
#
#  ⚠️ TWO DECISIONS ONLY THE USER CAN MAKE, both surfaced on the front sheet:
#    - HEALTH SAFETY FLAG: the built paracetamol / ibuprofen page shows in-app
#      dosing, which the brand deliberately decided against. It must not ship
#      unchanged.
#    - DEVELOPMENT EVIDENCE FLAG: the leap calendar still gives exact-week
#      dates, which the app's own earlier research rejected.
# =============================================================================

import os
from collections import Counter

from openpyxl import Workbook
from openpyxl.styles import Alignment, Border, Font, PatternFill, Side
from openpyxl.utils import get_column_letter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, 'docs', 'content-brief', 'PARENTING-DOOR-CONTENT.xlsx')

# -----------------------------------------------------------------------------
#  Status vocabulary. Parenting briefs use their own badge words (REUSE,
#  REFORMAT, MERGE, SINGLE-SOURCE, WIDEN, FIX); these collapse them into the
#  only question a commissioning team cares about: does someone have to WRITE
#  something, and if not, what does have to happen instead.
# -----------------------------------------------------------------------------
NEW = 'NEW — write from scratch'
WRITTEN = 'NEW — but the copy is already written in the brief'
REFORMAT = 'REFORMAT — same words, new medium'
MERGE = 'MERGE / single-source — no new writing'
BUILT = 'Already built — reuse, do not rewrite'
REF = 'Owned by another door — no new writing'
WIRING = 'WIRING — the piece exists, the link does not'
SAFETY = 'SAFETY REFRAME — do not ship unchanged'
EVIDENCE = 'EVIDENCE FIX — the claim is too precise'

DOORS = ['Sleep', 'Feeding', 'Health', 'Development', 'Behaviour',
         'Early Learning', 'First 40 Days', 'Potty training', 'Traditions',
         'You, Maa', 'What to buy']

S_SLEEP = 'ParentVeda_Sleep_rebuild.pdf'
S_FEED = 'ParentVeda_Feeding_rebuild.pdf'
S_HEALTH = 'ParentVeda_Health_rebuild.pdf'
S_DEV = 'Development_Parenting.pdf'
S_BEH = 'Behaviour_Parenting.pdf'
S_EL = 'Early_Learning_Parenting.pdf'
S_F40 = 'First_40_Days_Prompt.pdf'
S_POT = 'Potty_Parenting.pdf'
S_TRAD = 'Traditions_Parenting.pdf'
S_MAA = 'You_Parenting_Maa_rebuild.pdf'
S_BUY = 'What_to_buy_parenting.pdf'

# =============================================================================
#  WRITTEN  (door, type, title, what it covers, status, source)
# =============================================================================
W = [
 # ---- Sleep ---------------------------------------------------------------
 ('Sleep', 'Chart', 'Her sleep right now', 'Total, naps, night stretch, feeds — shown for HER age directly. Absorbs the old "Is she sleeping enough?" checker', BUILT, S_SLEEP),
 ('Sleep', 'Animation', 'Why her sleep is not like yours', 'The two cycle waves: she surfaces twice as often as you. Keep the comparison table', REFORMAT, S_SLEEP),
 ('Sleep', 'Tool copy', 'Wake windows', 'Her current happy-awake window by age. A guide, not a stopwatch: watch her, not the clock', NEW, S_SLEEP),
 ('Sleep', 'Carousel', 'The overtired baby', 'The paradox: more overtired means harder to settle. How to catch the window', NEW, S_SLEEP),
 ('Sleep', 'Cards', 'Why babies wake', 'Hunger, needing you, a leap, sleep association, wet nappy, gas, teething, too hot or cold', BUILT, S_SLEEP),
 ('Sleep', 'Table', 'What is normal night waking', 'Leads with HER typical wakes; the age arc stays behind it as context', BUILT, S_SLEEP),
 ('Sleep', 'Video', 'Gentle ways to settle her', 'Patting, shushing, the upright hold, the transfer. The step-list becomes the companion', REFORMAT, S_SLEEP),
 ('Sleep', 'Interactive', 'What to do at 3am', 'One big step at a time, dark and dim, tap to advance. Not a long list to read in the dark', REFORMAT, S_SLEEP),
 ('Sleep', 'Red flag card', 'When night waking needs a doctor', 'Same-day call list and what to mention. Under three months the bar is lower', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'What is a sleep regression', 'Article plus timeline, auto-marks where she is. A regression is a sign of progress', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'The 4 month regression', 'Surfaces in the 3-6mo band; the other regressions surface at their own ages', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'Night weaning, gently', 'From about 6 months, and only once the doctor is happy with her weight. A slow, no-battle taper', NEW, S_SLEEP),
 ('Sleep', 'Article + video', 'Where we stand on sleep training', 'Pinned at the top. Gentle first and why, plus the words to push back when family says "let her cry". Brand-defining', NEW, S_SLEEP),
 ('Sleep', 'Video', 'A calming bedtime routine', 'Already video plus step-list. Absorbs "The hour before bed" as its wind-down section', MERGE, S_SLEEP),
 ('Sleep', 'Video', 'Malish before sleep', 'Massage is shown, not read. The flagship India ritual gets its own demonstrated film', REFORMAT, S_SLEEP),
 ('Sleep', 'Article', 'She only falls asleep on the feed', 'The sleep-association angle. Links to Feeding', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'She sleeps all day and is awake all night', 'Day-night confusion, and how to flip it', BUILT, S_SLEEP),
 ('Sleep', 'Chart', 'When naps drop away', 'Naps-by-age arc, auto-marks her stage and the signs a nap is genuinely ready to go', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'Sleep in a joint family or a shared room', 'India-specific', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'Moving her to her own cot or room', 'India-aware. No right age, the family decides; what actually eases the move from your bed to her cot', NEW, S_SLEEP),
 ('Sleep', 'Carousel', 'Sleep away from home', "Nani's house, a wedding, a festival, a train. Protect the routine, recover after", NEW, S_SLEEP),
 ('Sleep', 'Illustration', 'Safer bed-sharing', 'One labelled safe-setup picture and what to clear away. Keep the harm-reduction wording under it', REFORMAT, S_SLEEP),
 ('Sleep', 'Illustration', 'On her back, every sleep', 'A simple visual: back is the way, every sleep', REFORMAT, S_SLEEP),
 ('Sleep', 'Video', 'Swaddling, and when to stop', 'The hip-safe wrap, and stopping the day she can roll. Shared with First 40 Days', REFORMAT, S_SLEEP),
 ('Sleep', 'Interactive', 'Her sleep space, checked', 'A tap-through checklist, already built as cards', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'Too warm, and how to tell', 'Feel the back of her neck. Indian-summer overheating', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'SIDS, explained calmly', 'Sensitive, so the text stays as text. Links to Health', BUILT, S_SLEEP),
 ('Sleep', 'Carousel', 'The worry set', 'Only sleeps on me, naps only 30 min, up at 5am, sleeps all the time. Each card links to its canonical page, no second copies', REFORMAT, S_SLEEP),
 ('Sleep', 'Article', 'She breathes noisily or snores in her sleep', 'Short article plus a doctor callout. Links to Health', BUILT, S_SLEEP),
 ('Sleep', 'Article', 'Dummy / soother and sleep', 'Honest pros and cons for sleep, safe use, and letting it go later', NEW, S_SLEEP),
 ('Sleep', 'Article', 'Does music actually help babies sleep?', 'Honest article; the "what is myth" section becomes a myth-vs-truth carousel', BUILT, S_SLEEP),
 ('Sleep', 'Audio library', 'The Sleep Sounds library', 'Five categories: lullabies and lori, white noise and womb, nature and calm, soft ragas, bedtime stories. Shares assets with Garbh Sanskar Shravan', REF, S_SLEEP),

 # ---- Feeding -------------------------------------------------------------
 ('Feeding', 'Video', 'Getting the latch right', 'The key one. A physical skill, shown on a real baby from several angles. The latch is the single biggest reason breastfeeding fails', REFORMAT, S_FEED),
 ('Feeding', 'Video', 'Positions that actually work', 'Cradle, cross-cradle, rugby hold, lying down. Spatial, so show them', REFORMAT, S_FEED),
 ('Feeding', 'Articles x8', 'How often and how much, and seven more', 'Making enough milk / what you eat while nursing / pumping for work / it feels like I am not making enough / too much milk / sore and cracked nipples / he is refusing the breast', BUILT, S_FEED),
 ('Feeding', 'Article', 'A hot, painful lump in the breast', 'Add a same-day red flag: mastitis with fever needs a doctor today', BUILT, S_FEED),
 ('Feeding', 'Video', 'Making up a bottle safely', 'Safety-critical: water temperature, sterilising, the ratio, timing. Demonstrated plus a glanceable checklist', REFORMAT, S_FEED),
 ('Feeding', 'Articles x7', 'Fed is fine, and six more', 'Choosing a formula / Indian formula compared honestly / switching brands / doing both / he will not take the bottle / stopping breastfeeding when you are ready', BUILT, S_FEED),
 ('Feeding', 'Chart', 'How much formula, by age', 'Amounts per feed by age and weight. The breast side has "how much"; the bottle side has no numbers today', NEW, S_FEED),
 ('Feeding', 'Illustration', 'Textures, stage by stage', 'What each texture actually looks like: puree, mash, soft finger food, chopped. Photos beat a chart here', REFORMAT, S_FEED),
 ('Feeding', 'Interactive', 'Introducing allergens safely', 'An allergen tracker: tick egg, peanut and the rest, with the wait-and-watch guidance', REFORMAT, S_FEED),
 ('Feeding', 'Articles x4', 'When to start and how to begin, and three more', 'The first foods / spoon-feeding or letting him feed himself / annaprashan, the first bite', BUILT, S_FEED),
 ('Feeding', 'Article', 'Setting up for solids', 'He can sit with support, high-chair basics, one calm mealtime a day', NEW, S_FEED),
 ('Feeding', 'Article', 'Constipation when solids start', 'Why it happens, water and fibre, when to see the doctor. Links to Health', NEW, S_FEED),
 ('Feeding', 'Articles x5', 'Cooking for him', 'Recipes for his age / ragi, khichdi, dalia / cooking for weight, iron or immunity / cooking once and feeding all week / what to feed when he is unwell', BUILT, S_FEED),
 ('Feeding', 'Articles x3', 'Weight gain and growing well', 'Foods that help him gain weight / ghee, nuts and the fats a baby needs / is my baby too thin?', BUILT, S_FEED),
 ('Feeding', 'Article', 'Reading the growth chart without panic', 'Lives with the Growth tracker percentile reads. Link, do not duplicate', REF, S_FEED),
 ('Feeding', 'Articles x4', 'Baby not eating food (toddler)', 'He is not eating anything / who decides what and who decides how much / food jags / mealtime battles and why force-feeding backfires', BUILT, S_FEED),
 ('Feeding', 'Illustration', 'Choking, and how to cut food so it does not happen', 'A labelled "cut it this way" visual (grapes, round foods). Text is the wrong medium for a choking-prevention page', REFORMAT, S_FEED),
 ('Feeding', 'Illustration', 'What an allergic reaction looks like', 'Show it — hives, swelling — plus a clear call-now block for breathing and face', REFORMAT, S_FEED),
 ('Feeding', 'Cards x3', 'Foods to avoid before his first birthday, and two more', 'Iron and the nutrients that matter / when to start water', BUILT, S_FEED),
 ('Feeding', 'Video', 'If he chokes: what to do', 'The missing response: back blows, infant versus older, when to call. Prevention alone is not enough. Canonical copy lives in Health', NEW, S_FEED),
 ('Feeding', 'Carousel', 'Gagging vs choking', 'Gagging is normal and noisy; choking is silent. Stops the panic and teaches the real emergency', NEW, S_FEED),
 ('Feeding', 'Article', 'Vitamin D and supplements', 'India-relevant: indoor babies, exclusive breastfeeding. Iron is covered, Vitamin D is not', NEW, S_FEED),

 # ---- Health --------------------------------------------------------------
 ('Health', 'Chart card', 'What the number actually means', 'Reading a fever number', BUILT, S_HEALTH),
 ('Health', 'Illustrated how-to', "Reading a baby's temperature", "Where to measure, what is normal by route. A quick labelled how-to beats prose", REFORMAT, S_HEALTH),
 ('Health', 'Flagged callout', 'A fever in a baby under three months', 'Leads only in the 0-3mo band, hidden when he is older', BUILT, S_HEALTH),
 ('Health', 'Article', 'Bringing a fever down, and the sponging myths', 'Keep the article; lift the sponging myths into a small myth-vs-fact carousel', BUILT, S_HEALTH),
 ('Health', 'Flagged callout', 'Paracetamol and ibuprofen: the typical ranges', '⚠️ DO NOT SHIP UNCHANGED. The built page gives in-app dosing, which the brand decided against. Reframe to "how to read the dose on the bottle for his weight" plus the overdose mistakes (double-dosing, two brands with the same medicine, the wrong syringe), with the dose itself deferred to the doctor or the label. Keeping the numbers needs paediatric AND legal sign-off plus a weight calculator the medical board owns', SAFETY, S_HEALTH),
 ('Health', 'Flagged callout', 'Fever red flags: when to stop watching', 'Uses the one canonical red-flag list, not a third copy', MERGE, S_HEALTH),
 ('Health', 'Tool view', 'Home remedies for fever, honestly', 'Points at the single Home remedies tool, filtered to fever', REF, S_HEALTH),
 ('Health', 'Article', 'A fever that will not settle: dengue, typhoid and malaria', 'The Indian fevers that are not a cold', BUILT, S_HEALTH),
 ('Health', 'Article', 'The common cold, and why it keeps coming back', '', BUILT, S_HEALTH),
 ('Health', 'Video', 'Clearing a blocked nose', 'Physical skill: saline drops and aspirator technique. Parents get this wrong from text', REFORMAT, S_HEALTH),
 ('Health', 'Flagged callout', 'Cough syrups: what is safe and what is not', 'Callout plus table', BUILT, S_HEALTH),
 ('Health', 'Article', 'When a cough is more than a cold', '', BUILT, S_HEALTH),
 ('Health', 'Article', 'Loose motions', '', BUILT, S_HEALTH),
 ('Health', 'Video', 'ORS, made right', 'The wrong ratio is dangerous. Show the exact measure being made, on screen', REFORMAT, S_HEALTH),
 ('Health', 'Illustrated signs', 'Spotting dehydration early', 'Sunken eyes, no tears, dry mouth, few wet nappies, sunken soft spot. Visual, not a text chart', REFORMAT, S_HEALTH),
 ('Health', 'Article', 'Vomiting', '', BUILT, S_HEALTH),
 ('Health', 'Article', 'Constipation, and the days without a poo', 'Feeding owns constipation-when-solids-start; cross-link, do not duplicate', BUILT, S_HEALTH),
 ('Health', 'Article', 'Colic and the evening crying', "Sleep's evening-crying and settling content cross-links here", BUILT, S_HEALTH),
 ('Health', 'Illustration grid', 'Which rash is this?', '★ The top visual fix in the door. Rashes are matched by eye: a labelled photo grid (this is HFMD, this is nappy rash, this is the glass-test one that means go now) beats any table', REFORMAT, S_HEALTH),
 ('Health', 'Articles x6', 'Hand foot and mouth, and five more', 'Nappy rash / eczema and dry rough patches / prickly heat and Indian summers / cradle cap, baby acne and peeling skin / chickenpox', BUILT, S_HEALTH),
 ('Health', 'Article', 'Ear pain and ear infections', '', BUILT, S_HEALTH),
 ('Health', 'Short article', 'Sticky eyes and eye discharge', '', BUILT, S_HEALTH),
 ('Health', 'Article', 'Newborn jaundice', 'Newborn band only', BUILT, S_HEALTH),
 ('Health', 'Article', 'Allergies, and what an allergy is not', 'Health owns general allergy and anaphylaxis; Feeding owns food-allergen introduction', BUILT, S_HEALTH),
 ('Health', 'Carousel', 'Teething, and why it does not cause a high fever', 'Small but high-value myth fix: parents blame teething for real fevers. Belongs where fevers are read', NEW, S_HEALTH),
 ('Health', 'Red flag callout', 'Go to a hospital now', 'THE canonical red-flag list. Today it is copied in three places and will drift; the fever-check gate and the fever red flags must both reference this one block', MERGE, S_HEALTH),
 ('Health', 'Interactive', 'The three speeds', 'Tap what you are seeing, get the speed: Now / Same day / Can wait. A decision aid used under stress, so interactive beats a static table', REFORMAT, S_HEALTH),
 ('Health', 'Video + steps', 'If he chokes or cannot breathe', '★ Top safety gap. Infant back blows and chest thrusts, numbered steps, a "call an ambulance if" line. The emergency list names "trouble breathing" but nowhere shows the response. Canonical here; Feeding links to it', NEW, S_HEALTH),
 ('Health', 'Video / illustrated', 'If he has a fit', '★ Safety gap. On his side, nothing in the mouth, time it, when to call an ambulance. Named as a red flag today with no in-the-moment answer', NEW, S_HEALTH),
 ('Health', 'Cards', 'Common accidents, fast', '★ Safety gap. Swallowed something (button battery or magnet means go now), a burn, a bad fall or head bump, something in the eye. First minutes only. Entirely absent today', NEW, S_HEALTH),
 ('Health', 'Chart', 'What is due, and when', 'This is the vaccination tool own schedule view. Do not keep a separate chart', MERGE, S_HEALTH),
 ('Health', 'Cards', 'What each shot is for', '', BUILT, S_HEALTH),
 ('Health', 'Article', 'After a shot: what is normal', '', BUILT, S_HEALTH),
 ('Health', 'Short article', 'If you are behind', '', BUILT, S_HEALTH),
 ('Health', 'Comparison table', 'Government hospital or private clinic, and what it costs', 'India-specific, keep', BUILT, S_HEALTH),
 ('Health', 'Article', 'The pressure to make him mota', 'Honest voice, keep', BUILT, S_HEALTH),
 ('Health', 'Short article', 'What a percentile actually means', '', BUILT, S_HEALTH),
 ('Health', 'Flagged callout', 'Growth that needs a doctor', '', BUILT, S_HEALTH),
 ('Health', 'Short article', 'The dull things that actually work', '', BUILT, S_HEALTH),
 ('Health', 'Article', 'Building immunity, and the tonics that will not', 'Honest, keep', BUILT, S_HEALTH),
 ('Health', 'Short article', 'Monsoon, and the season of illness', 'Surfaces seasonally', BUILT, S_HEALTH),
 ('Health', 'Short article', 'Air pollution and small lungs', '', BUILT, S_HEALTH),
 ('Health', 'Video', 'How to give medicine to a baby', '★ Physical skill. Syringe into the cheek, not the throat, and positioning. Done wrong, this chokes babies', REFORMAT, S_HEALTH),
 ('Health', 'Cards', 'When to keep him home', '', BUILT, S_HEALTH),
 ('Health', 'Article', 'Antibiotics, and why the chemist should not decide', 'Honest, keep', BUILT, S_HEALTH),
 ('Health', 'Step-list', 'Getting the most out of seven minutes', 'The papers-library how-to; pairs with the doctor visit companion', BUILT, S_HEALTH),

 # ---- Development ---------------------------------------------------------
 ('Development', 'Article', 'The normal range is much wider than you think', '"Start here if someone just worried you". The first thing a worried parent should land on', BUILT, S_DEV),
 ('Development', 'Flagged callout', 'When something is genuinely worth checking', 'One list per area, plus "if he lost a skill, do not wait", plus talk to a doctor. One of the best pages in the app — an earlier pass wrongly listed this as new', BUILT, S_DEV),
 ('Development', 'Short article', 'If your baby was born early', 'How to read the charts from the due date. Shows only up to 2 years', BUILT, S_DEV),
 ('Development', 'Articles x8', 'When will my baby roll over, and seven more', 'Sit up / crawl / pull up and stand / walk (keeps the "no baby walkers" safety note) / point and wave / say their first word / feed themselves. Each has a range chart, "signs it is coming" cards and a how-to-help list', BUILT, S_DEV),
 ('Development', 'Chart', 'What talking looks like, month by month', '', BUILT, S_DEV),
 ('Development', 'Article', 'Will two languages confuse my child?', '"No, and count all the languages together"', BUILT, S_DEV),
 ('Development', 'Step-list', 'How to help your child talk', '', BUILT, S_DEV),
 ('Development', 'Flagged callout', 'When talking is worth checking', 'Ask for a hearing test every time, plus talk to a speech therapist', BUILT, S_DEV),
 ('Development', 'Article', 'How play builds the brain', 'Back-and-forth is the whole thing', BUILT, S_DEV),
 ('Development', 'Video', 'Tummy time without the tears', 'Was a written list. It is a body position, and a parent copies that from watching, not reading', REFORMAT, S_DEV),
 ('Development', 'Cards', 'Things to do today, from around the house', '', BUILT, S_DEV),
 ('Development', 'Cards', 'Messy play, and why it is worth the mess', '', BUILT, S_DEV),
 ('Development', 'Short article', 'Is my baby going through a leap?', 'Already honest: "a way to think about it, not a rule"', BUILT, S_DEV),
 ('Development', 'Article', 'Activities for feelings and getting on with others', 'This corner of the app is blank today', NEW, S_DEV),
 ('Development', 'Tool copy', "Your baby's phase calendar (the ten phases)", '⚠️ EVIDENCE FIX. The calendar still gives exact-week dates, which the app own early research said do not hold up. Soften to "around this age" and surface the caveat. Keep the ten names, the look-on-the-bright-side bit and the "nazar lag gayi? probably not" line', EVIDENCE, S_DEV),

 # ---- Behaviour -----------------------------------------------------------
 ('Behaviour', 'Article', "Is my baby's crying normal?", '', BUILT, S_BEH),
 ('Behaviour', 'Article', "Why won't my baby settle?", 'Settling depth goes to Sleep', BUILT, S_BEH),
 ('Behaviour', 'Short article', 'You cannot spoil a newborn', '', BUILT, S_BEH),
 ('Behaviour', 'Cards', "Understanding your baby's temperament", '', BUILT, S_BEH),
 ('Behaviour', 'Interactive', 'When the crying is too much', 'The worst format mismatch and the highest stakes. A parent at the edge at 2am cannot read a six-item list. One calm instruction on screen at a time, dark and glanceable. The never-shake-a-baby block and the get-help-today routing stay. Same screen as First 40 Days "when the crying will not stop"', REFORMAT, S_BEH),
 ('Behaviour', 'Flagged callout', 'When crying needs a doctor', 'Medical detail goes to Health', BUILT, S_BEH),
 ('Behaviour', 'Articles x3', 'How to handle a ziddi bachcha, and two more', 'Choices within limits (step-list) / am I too strict, or too soft?', BUILT, S_BEH),
 ('Behaviour', 'Articles x6', 'The first tantrums, and five more', 'Hitting, biting and pulling hair / she cries every time I leave / tantrum or meltdown (comparison table) / the five steps in the moment / when it happens in front of everyone', BUILT, S_BEH),
 ('Behaviour', 'Articles x2', 'Saying no to everything, and she will not share', 'Overlaps the ziddi area; the two stay separate and single-source the shared "why the will arrives before the words" explanation', BUILT, S_BEH),
 ('Behaviour', 'Articles x4', 'He throws everything, and three more', 'The screaming / anger, and hurting out of it / the whining', BUILT, S_BEH),
 ('Behaviour', 'Article', 'He does not listen to anything I say', 'One canonical listening page. "Listening and cooperation" is the same page for the same age — keep one, reference it from both areas', MERGE, S_BEH),
 ('Behaviour', 'Chart', 'How much is too much, honestly', 'Screen time. Keep the chart but lead with his age row, not a table he has to scan', BUILT, S_BEH),
 ('Behaviour', 'Step-list', 'Ending it without a meltdown', '', BUILT, S_BEH),
 ('Behaviour', 'Article', 'When everyone in the house has a phone', '', BUILT, S_BEH),
 ('Behaviour', 'Articles x4', 'Why hitting does not do what it looks like it does, and three more', 'Redirection, consequences and consistency / time-outs and whether they are worth it / when elders discipline differently. Brand-defining, do not water down', BUILT, S_BEH),
 ('Behaviour', 'Explainer', 'Why a child lashes out physically', 'Written three times today (hitting-biting, anger-and-hurting-out-of-it, guiding-without-hitting). Single-source one canonical explainer the three reference; keep the three distinct moments', MERGE, S_BEH),
 ('Behaviour', 'Activities x4', 'A calm-down corner, and three more', 'Naming the feeling / filling the tank / a daily feelings check-in', BUILT, S_BEH),
 ('Behaviour', 'Animation', 'Balloon breathing', 'Render with the shared breathing-circle already built for Mind and body and Kriya. Not a text page', REFORMAT, S_BEH),
 ('Behaviour', 'Video', 'A calm jar', 'A short make-and-use film. Showing beats telling for a physical make', REFORMAT, S_BEH),
 ('Behaviour', 'Articles x3', 'Big feelings and helping him manage them, and two more', 'Early friendships and falling out / the fighting between them (sibling rivalry, reslotted in)', BUILT, S_BEH),
 ('Behaviour', 'Article', 'Lying, fairness and telling on people', 'One lying page, not two. "She told me a lie" is the same page for the same age — merge and delete the copy', MERGE, S_BEH),
 ('Behaviour', 'Article', 'Back-talk, and "I hate you"', 'The full copy is written in the brief and must be dropped in verbatim, not regenerated. Why he does it, five things to do, what not to do, the words, the Indian-home box, when to ask', WRITTEN, S_BEH),
 ('Behaviour', 'Article', 'Why he is suddenly scared of everything', 'NEW AREA: the scared, shy or clingy child. The biggest hole in the door — everything built is about the child who acts out', NEW, S_BEH),
 ('Behaviour', 'Article', 'Fear of the dark, and the monster under the bed', 'Night fears, cross-link Sleep', NEW, S_BEH),
 ('Behaviour', 'Step-list', 'The doctor, the injection, the haircut', '', NEW, S_BEH),
 ('Behaviour', 'Short article', 'Scared of dogs, lifts and loud noises', '', NEW, S_BEH),
 ('Behaviour', 'Article', 'The shy child, and "say hello, beta"', 'The child who will not go to anyone or greet elders', NEW, S_BEH),
 ('Behaviour', 'Flagged callout', 'When fear or clinginess is worth checking', '', NEW, S_BEH),
 ('Behaviour', 'Article', 'Thumb-sucking, and when to just leave it', 'NEW AREA: the habits that worry parents. Ungli chusna, with heavy relative pressure. Exists today only as a symptom-checker entry', NEW, S_BEH),
 ('Behaviour', 'Article', 'Head-banging and rocking', 'Exists only as a checker entry today', NEW, S_BEH),
 ('Behaviour', 'Article + callout', 'Breath-holding spells', 'The reassurance parents need. Nowhere in the app today', NEW, S_BEH),
 ('Behaviour', 'Short article', 'Nail-biting and the other little habits', '', NEW, S_BEH),
 ('Behaviour', 'Article', 'Toddler self-touching (genital exploration)', '⚠️ PENDING YOUR CALL — the brief deliberately did not assume it in. Normal development, and one of the most panic-inducing and least honestly covered topics for Indian parents. Fits the honest-voice brand exactly; culturally sensitive', NEW, S_BEH),

 # ---- Early Learning ------------------------------------------------------
 ('Early Learning', 'Activities x36', 'Something to do with him today', 'Sorted by age (baby 8, 1-2yr 7, 2-3yr 8, 3-4yr 7, 4-6yr 6), all from what is in the kitchen: peekaboo, spooning dal, playing sabzi shop, first sums with kaju and stones. This IS the "Something to do today" picker — one set, not two', BUILT, S_EL),
 ('Early Learning', 'Article', 'Montessori without the forty thousand rupee school', '', BUILT, S_EL),
 ('Early Learning', 'Step-list', 'Setting up a corner he is allowed to touch', '', BUILT, S_EL),
 ('Early Learning', 'Short article', 'Letting him help with real work', '', BUILT, S_EL),
 ('Early Learning', 'Short article', 'Following what he is already interested in', '', BUILT, S_EL),
 ('Early Learning', 'Short article', 'Reading to a baby who cannot understand a word', '', BUILT, S_EL),
 ('Early Learning', 'Step-list', 'Telling a story with no book at all', '', BUILT, S_EL),
 ('Early Learning', 'Short article', 'What to say when the story ends', '', BUILT, S_EL),
 ('Early Learning', 'Stories x10', 'Little bedtime tales', '1yr+. Text written; every story needs a "listen" audio recorded', BUILT, S_EL),
 ('Early Learning', 'Stories x12', 'Panchatantra stories', '2.5yr+. Text written; audio to record', BUILT, S_EL),
 ('Early Learning', 'Stories x10', 'Jataka tales', '2.5yr+. Text written; audio to record', BUILT, S_EL),
 ('Early Learning', 'Stories x10', 'Akbar and Birbal', '3.5yr+. Text written; audio to record', BUILT, S_EL),
 ('Early Learning', 'Stories x6', 'Tenali Rama', '3yr+. Text written; audio to record', BUILT, S_EL),
 ('Early Learning', 'Stories x10', 'Stories from around the world', '2.5yr+. Text written; audio to record', BUILT, S_EL),
 ('Early Learning', 'Rhymes collection', 'Rhymes and songs, a new collection', 'Audio-first like the stories: Hindi, English and regional action rhymes. The door has 58 stories and not one rhyme, and rhymes are half of early learning at this age. ⚠️ Original or public-domain rhymes only, never copyrighted lyrics', NEW, S_EL),
 ('Early Learning', 'Articles x10', 'Brushing his teeth, and nine more habits', 'Washing his hands / please and thank you / putting his toys away / eating by himself / drinking enough water / going to bed on time / greeting people, namaste and hello / looking after himself / helping at home', BUILT, S_EL),
 ('Early Learning', 'Articles x5', 'Sharing, and four more habits also in Behaviour', 'Waiting for his turn / being kind to other people / telling the truth / screens as a habit rather than a battle. Keep the "build the habit calmly" version here and cross-link to the "when it is going wrong right now" version in Behaviour; the two must say the same thing', REF, S_EL),
 ('Early Learning', 'Articles x4', 'What comes before writing, and three more', 'First numbers, without a single worksheet / getting ready to read / colours, shapes and sorting', BUILT, S_EL),
 ('Early Learning', 'Article', 'English or the mother tongue, and when to start letters', 'The pressure to start ABCs and English at two is intense in Indian homes. The door refuses worksheets everywhere but gives the parent no words to hold that line on language', NEW, S_EL),
 ('Early Learning', 'Article', 'What school readiness actually means', '', BUILT, S_EL),
 ('Early Learning', 'Checklist', 'The readiness checklist', '', BUILT, S_EL),
 ('Early Learning', 'Article', 'Choosing a preschool', '', BUILT, S_EL),
 ('Early Learning', 'Step-list', 'The crying at the gate', '', BUILT, S_EL),
 ('Early Learning', 'Short article', 'What comes after preschool', '', BUILT, S_EL),

 # ---- First 40 Days -------------------------------------------------------
 ('First 40 Days', 'Day-spine cards x4', 'Days 1 to 7, and three more ranges', 'Days 8-15 finding the feed / days 16-30 the long evenings / days 31-40 a rhythm appears', BUILT, S_F40),
 ('First 40 Days', 'Short article', 'You made it to 40 days. What now?', 'Shows at the 40-day mark and after', BUILT, S_F40),
 ('First 40 Days', 'Flagged reference', 'When to rush to the doctor', 'The read-once-while-calm reference. Stays second in the door on purpose, so a frightened parent at 3am meets it before cord care', BUILT, S_F40),
 ('First 40 Days', 'Interactive', 'When the crying will not stop', 'One instruction per screen, never-shake block pinned first. Same crisis content as Behaviour "when the crying is too much" — one screen, both doors point at it', REFORMAT, S_F40),
 ('First 40 Days', 'Step-list', 'Looking after the cord stump', '', BUILT, S_F40),
 ('First 40 Days', 'Video + step-list', 'His first bath, and when to start', 'Add a film. Bathing a slippery newborn is a scary physical skill and there is no film today; keep the step-list under it', REFORMAT, S_F40),
 ('First 40 Days', 'Chart + illustration', 'Nappies, and what his poop should look like', 'Add a colour strip of what each looks like. Parents are matching a nappy to a picture', REFORMAT, S_F40),
 ('First 40 Days', 'Video', 'Swaddling, and how tight is right', 'Video-first, reusing the Sleep swaddling film. Do not shoot a second', REFORMAT, S_F40),
 ('First 40 Days', 'Chart card', 'Is he too hot, or too cold?', '', BUILT, S_F40),
 ('First 40 Days', 'Illustrated carousel', 'His skin looks strange. Is that normal?', 'A photo of each: milia, stork mark, the grey-blue patch, cradle cap, newborn acne. Skin is a see-it-to-know-it thing', REFORMAT, S_F40),
 ('First 40 Days', 'Flagged article', 'Jaundice: what to watch and when it matters', 'A small picture of how far the yellow has spread (face, chest, palms) would help; light touch', BUILT, S_F40),
 ('First 40 Days', 'Short article', 'He wants to feed all evening', '', BUILT, S_F40),
 ('First 40 Days', 'Carousel', 'Hiccups, sneezes, grunts and other noises', 'Swipe through the normal noises. Light', REFORMAT, S_F40),
 ('First 40 Days', 'Short article', 'Why he is awake all night', 'Keeps only day-and-night confusion; the why-he-wakes explanation defers to "Newborn sleep, honestly" so the two do not repeat', MERGE, S_F40),
 ('First 40 Days', 'Illustration', 'Sleeping safely, in your bed or his', 'A labelled safe-sleep picture, reusing the Sleep illustration. High stakes, a picture carries it', REFORMAT, S_F40),
 ('First 40 Days', 'Comparison table', 'The old practices: which help and which harm', 'A standout India page, keep it exactly', BUILT, S_F40),
 ('First 40 Days', 'Video + step-list', 'Getting the latch right', 'The same latch film as Feeding. One film', REF, S_F40),
 ('First 40 Days', 'Articles x4', 'How often should he feed?, and three more', 'Is he getting enough? / burping him / newborn sleep, honestly (the main newborn-sleep explainer)', BUILT, S_F40),
 ('First 40 Days', 'Video + step-list', 'Malish, step by step', 'The same malish film as Sleep. Also drop this page own "which oil" cards and point at the Jaapa Essentials oil comparison, so oil advice lives in one place', MERGE, S_F40),
 ('First 40 Days', 'Video', 'Soothing your baby', 'Video-first, reusing the Sleep settling film', REFORMAT, S_F40),
 ('First 40 Days', 'Video + step-list', 'Carrying him, and the jhula', 'Airway safety, so the film is the right call', BUILT, S_F40),
 ('First 40 Days', 'Step-list', 'Skin to skin, and why it is worth the trouble', 'Could be a short film later; gentle, optional', BUILT, S_F40),
 ('First 40 Days', 'Cards x2', 'The quick daily check, and when to start logging properly', '', BUILT, S_F40),
 ('First 40 Days', 'Articles x6', 'Your bleeding: what is normal, and five more', 'After a normal delivery / after a C-section / rest, water and jaapa food / when to call your own doctor / if you do not feel like yourself. ⚠️ You, Maa proposes these consolidate THERE and this door reference them (its judgement call 1)', BUILT, S_F40),
 ('First 40 Days', 'Article + red flag', 'Your breasts in the early weeks', 'HIGHEST VALUE in the door. Engorgement, cracked nipples, a blocked duct and mastitis, with a same-day flag for mastitis. One of the most common and most painful problems of the first forty days and there is no page for it; the warning is scattered across two red-flag lists but the how-to-manage-it is nowhere. ⚠️ You, Maa proposes this consolidates into its own "Sore, rock hard breasts" page instead — decide once', NEW, S_F40),
 ('First 40 Days', 'Short article', 'When your body can get pregnant again', 'The honest note: ovulation can return before the first period, and feeding is not reliable contraception', NEW, S_F40),
 ('First 40 Days', 'Article', 'Bringing home a small or early baby', 'High value for the scared few. A premature, low-birth-weight or just-out-of-NICU baby: what is different about temperature, feeding, kangaroo care, and when to worry. Today only scattered "if he was born early" lines with no home', NEW, S_F40),
 ('First 40 Days', 'Article', 'For your husband, in the first 40 days', 'Guard the door, protect her rest and her food, take a night shift, do skin to skin, watch for her mood dipping. The whole door is mother-and-baby and the one person who can protect both has no page', NEW, S_F40),
 ('First 40 Days', 'Article', 'The ceremonies, and keeping him safe through them', 'India-specific. Chhati, naamkaran, the first outing: crowds, kissing his face, infection, and when it is actually safe to take him out. Touched in one box today, owned nowhere', NEW, S_F40),
 ('First 40 Days', 'Cards x3', 'Jaapa Essentials', 'What you actually need / which malish oil (the one home for oil advice) / which swaddle, and how many', BUILT, S_F40),

 # ---- Potty training ------------------------------------------------------
 ('Potty training', 'Chart card', 'How long this actually takes', 'Pinned above the grid. Already says "worth re-reading the day someone tells you your child is behind", which is exactly why it stays on top', BUILT, S_POT),
 ('Potty training', 'Video + article', 'What is su-su cueing?', 'The cue method the family already knows, done gently. The door honest India premise: this starts long before training does', BUILT, S_POT),
 ('Potty training', 'Article + cards', "How to read your baby's signals", 'The "signs to watch for" could swipe as a carousel; light, optional', BUILT, S_POT),
 ('Potty training', 'Article + script box', 'The grandmother method and diapers, together', 'The peace-keeping page, one of the best in the app. Keep the say-this-not-that box exactly', BUILT, S_POT),
 ('Potty training', 'Short article', 'Diaper-free time, and less rash', 'The yeast-rash line should point at the Health rash pictures rather than describe it in words', BUILT, S_POT),
 ('Potty training', 'Video + article', 'The signs she is ready', 'Keep it as an article about the signs, NOT a quiz. A quiz that says "not ready" is a verdict the parent never asked for', BUILT, S_POT),
 ('Potty training', 'Comparison table', 'Su-su, child-led, or the three-day method', 'An honest three-way comparison. But the three-day method is named here and taught nowhere', BUILT, S_POT),
 ('Potty training', 'Step-list', 'Introducing the potty', 'The slow first week', BUILT, S_POT),
 ('Potty training', 'Video + step-list', 'The daily routine', 'The five fixed moments', BUILT, S_POT),
 ('Potty training', 'Short article', 'One word, whole house', '', BUILT, S_POT),
 ('Potty training', 'Video + article', 'The Indian toilet, and going out', 'Add a film. The squat, the balance, the bucket and mug, front to back: the page itself calls this "the main event" and there is no film. The clearest missing video in the door', REFORMAT, S_POT),
 ('Potty training', 'Short article', 'Boys and girls, the small differences', '', BUILT, S_POT),
 ('Potty training', 'Video + article', 'Accidents are normal', '"What to do with your face" — the film is the right medium for a tone lesson', BUILT, S_POT),
 ('Potty training', 'Article + consult', 'She was doing so well, and now she is not', 'Regressions. The triggers (new baby, starting school) overlap Behaviour and Development, cross-link them', BUILT, S_POT),
 ('Potty training', 'Article + consult', 'She is holding it in', 'The withholding and constipation page, the one genuinely medical part. Health owns the depth, this cross-links. Must be reachable for older children too', BUILT, S_POT),
 ('Potty training', 'Short article', 'She is scared of the potty', '', BUILT, S_POT),
 ('Potty training', 'Activities x3', 'Draw the potty steps, and two more', 'Sit-and-read potty time / teach the toy', BUILT, S_POT),
 ('Potty training', 'Video + chart', 'Dry nights come later', 'Honest: "you cannot train them"', BUILT, S_POT),
 ('Potty training', 'Article + consult', 'Bedwetting at five and older', 'Good medical honesty, keep', BUILT, S_POT),
 ('Potty training', 'Step-list', 'Washing and wiping on her own', 'The mug and front-to-back overlaps the Indian-toilet page; point this at that page new film rather than repeating the technique', MERGE, S_POT),
 ('Potty training', 'Short article', 'School toilets, and toilets out in the world', 'Asking permission is the real skill; keep the exact sentence to rehearse', BUILT, S_POT),
 ('Potty training', 'Article', 'Why there are no star charts here', 'Brand-defining. The door refuses reward charts everywhere but never says why in one place. Gives a parent the words to hold the line when the whole family is pushing stickers and sweets', NEW, S_POT),
 ('Potty training', 'Article', 'The three-day method, done safely', 'The comparison table offers it as one of three real choices and then the door only teaches the gradual method. Lay it out honestly — who it suits and the one risk, a child who starts holding it in — rather than leaving her to a random blog', NEW, S_POT),
 ('Potty training', 'Card', 'Do pull-ups help or hurt?', 'A very common question: many parents worry pull-ups feel like a nappy and slow the daytime work. One honest card, could fold into "Starting out"', NEW, S_POT),
 ('Potty training', 'Card', 'If she is taking much longer than her friends', 'A short calm pointer for the child who is well behind or has other delays, sending them to Development and a paediatrician without alarm', NEW, S_POT),

 # ---- Traditions ----------------------------------------------------------
 ('Traditions', 'Charts x4', 'Which ceremony is coming up now?', 'The first months in order / her first solid meal / birthday, mundan, ears / the start of learning. One per stage, auto-scoped so the app shows the right one on its own', BUILT, S_TRAD),
 ('Traditions', 'Ceremonies x4', 'Chatti, and three more early ceremonies', 'Namkaran the naming ceremony / jhula the cradle ceremony / nishkramana the first outing. Each: what it is, what it is called across India, how the day goes, what you need, what is optional, the newborn-safety note', BUILT, S_TRAD),
 ('Traditions', 'Ceremony', 'Annaprashan, the first solid food', 'Holds the no-honey, no-salt, no-sugar, test-the-temperature rules', BUILT, S_TRAD),
 ('Traditions', 'Cards', 'What to actually feed, on the day and after', 'Keep the ceremony-day version; point the full solids journey and the recipes at Feeding and the food surface, do not rebuild them here', MERGE, S_TRAD),
 ('Traditions', 'Ceremony', 'Mundan, the first head shaving', 'Keep in full. The fresh-sealed-blade rule is the same one on aqiqah and the ceremony-day page, so it lives once and these reference it', MERGE, S_TRAD),
 ('Traditions', 'Ceremonies x3', 'Karnavedha, and two more', 'Ear piercing (mostly aftercare, correctly, and holds the honest "piercing does not help her eyesight" line) / the first birthday, planned around her nap not the guest list / aksharabhyasam, the first letters', BUILT, S_TRAD),
 ('Traditions', 'Ceremonies x5', 'Aqiqah, and four more faith ceremonies', 'Tahneek the first sweet taste (holds the honey warning) / baptism, christening and dedication / Naam Karan at the Gurdwara and kesh / welcomes in Jain and Parsi families. Written in exactly the same shape as the Hindu ceremonies rather than tucked into an appendix, and that sameness is the whole point', BUILT, S_TRAD),
 ('Traditions', 'Chart', 'What a ceremony actually costs', 'Honest price ranges nobody publishes, plus three versions of the same ceremony by size. Excellent, keep as is', BUILT, S_TRAD),
 ('Traditions', 'Step-list', 'How to keep it small', 'The one-hour, at-home version. Let the cost chart own the numbers so this page stays about the how, not the how-much', MERGE, S_TRAD),
 ('Traditions', 'Script box', 'What to say when family wants it bigger', 'The exact lines for the hard conversations. Five pages link to it. This is the payoff page of the door — keep every word', BUILT, S_TRAD),
 ('Traditions', 'Cards', 'On a newborn: kajal, honey and the cord', 'Add a labelled picture to the visual ones (where a kajal dot may go, the bare dry cord, the frog-leg swaddle, head-shaping). These are do-this-not-that, which a photo settles faster than words. Keep the card text', REFORMAT, S_TRAD),
 ('Traditions', 'Cards', 'On the day: blades, piercing and heat', 'The canonical home for the blade rule, the ear-piercing rule and the newborn-in-a-crowd rule that the ceremony pages reference. Also where the shared newborn-gathering safety block lives, in step with the Health go-to-doctor list', MERGE, S_TRAD),
 ('Traditions', 'Article', 'How the date gets chosen, and what to do when it does not suit the baby', 'THE BIGGEST GAP. Half the door tells a parent to push back on a bad muhurat and never explains the muhurat: the panchang, the pandit, the birth-star, why boys get even months and girls odd ones. Belongs at the top', NEW, S_TRAD),
 ('Traditions', 'Article', 'How Indian families choose the name', 'Rashi and nakshatra letters, gotra, numerology, and the practical bit nobody writes: a name that works across languages and does not get mangled at school. Strengthens the Find a name tool rather than competing with it', NEW, S_TRAD),
 ('Traditions', 'Article set', "The baby's first festivals, done safely", 'First Diwali, Holi, Eid, Christmas, Raksha Bandhan. Diyas and cracker noise near a baby, colours on baby skin at Holi, fasting while nursing. Carries real same-day safety. ⚠️ PENDING YOUR CALL — its own small area, or folded into the unsafe-customs area', NEW, S_TRAD),
 ('Traditions', 'Article', 'If you would rather not do a ceremony at all', 'The door is very good at "here is how" and silent on "is it alright to skip it". For a modern, rationalist or interfaith parent that is the real question. ⚠️ Tone-sensitive: read it before it ships', NEW, S_TRAD),
 ('Traditions', 'Card', "Going to someone else's baby's ceremony", 'What to gift, how much to put in the shagun envelope, what to wear, whether to bring your own small baby. A light card, and a very common search', NEW, S_TRAD),
 ('Traditions', 'Card', 'Twins, an adopted baby, or the second child', '"Do we do all of this again for the second one?" and "ceremonies for an adopted child". A short warm card that says there is no rule and no debt', NEW, S_TRAD),
 ('Traditions', 'Article', 'Interfaith families, and doing this far from home', 'The five-faith area assumes one tradition per household and a temple or church nearby. For two-tradition families, and for parents abroad or in a city with no pandit, agiary or gurdwara close by', NEW, S_TRAD),
 ('Traditions', 'Article', 'When the mother is kept apart', 'The honest, quieter one. The mother treated as apart or "not to be touched" during the very ceremonies meant to welcome her baby, kept from the kitchen or the puja. ⚠️ The one to write carefully and sign off on tone before it ships', NEW, S_TRAD),

 # ---- You, Maa ------------------------------------------------------------
 ('You, Maa', 'Routes x8', 'How are you today, Maa?', 'Pinned as the front door. I am having thoughts that frighten me (stays first, routes to the crisis helpline) / I feel low or I keep crying / I am sore or still healing / I leak or I feel heavy down there / I am stiff and I want to move again / I am drained and I keep forgetting to eat / I feel alone in this / I am going back to work soon', BUILT, S_MAA),
 ('You, Maa', 'Flagged callout', 'When to call a doctor, not wait', 'Keep it exactly', BUILT, S_MAA),
 ('You, Maa', 'Article', 'The bleeding, and what is normal', 'This is the deep home. First 40 Days should reference it, not carry its own copy', MERGE, S_MAA),
 ('You, Maa', 'Articles x2', 'Stitches and sitting down again, and after a C-section', 'Both single-source here; First 40 Days references', MERGE, S_MAA),
 ('You, Maa', 'Short articles x2', 'Cramps that come back when you feed, and swelling and sweating through the night', '', BUILT, S_MAA),
 ('You, Maa', 'Article', 'Sore, rock hard breasts', 'Engorgement and mastitis. The brief proposes ALL breast health consolidates here — cracked nipples, blocked duct, mastitis — with Feeding and First 40 Days pointing in', MERGE, S_MAA),
 ('You, Maa', 'Articles x12', 'Rest and why it is not laziness, and eleven more', 'Your C-section scar and the numbness / your back and the way you now stand / wrist, thumb and neck pain from feeding / my hair is coming out in handfuls / the gap in my stomach muscles / constipation and piles / your core and your scar months later / when will I feel normal and what is worth checking / your skin, stretch marks and the line on your belly / getting your energy back', BUILT, S_MAA),
 ('You, Maa', 'Comparison table', 'Baby blues, or something more?', 'Right format, keep', BUILT, S_MAA),
 ('You, Maa', 'Articles x8', 'Anxious every minute, and seven more', 'Thoughts that frighten me / the anger nobody warned me about / I love my baby and I am not okay / who am I now / the guilt and the comparison / alone in a full house / you and your partner after. The honest voice throughout is the point ("rage and love live in the same house") — keep every line', BUILT, S_MAA),
 ('You, Maa', 'Flagged callout', 'Postpartum psychosis: rare, urgent, know the signs', 'Keep exactly, do not soften', BUILT, S_MAA),
 ('You, Maa', 'Step-list', 'How to actually get help, in India', 'Huge value, India-specific navigation. Keep the "ask for haemoglobin and thyroid too" line', BUILT, S_MAA),
 ('You, Maa', 'Articles x5', 'What your pelvic floor is, and four more', 'I leak when I cough, laugh or lift / a heavy dragging feeling down there (prolapse, handled plainly) / wind and bowel control / when sex hurts after birth', BUILT, S_MAA),
 ('You, Maa', 'Flagged callout', 'When to stop exercising and see a physio', 'The physio consult backbone, keep', BUILT, S_MAA),
 ('You, Maa', 'Activities x5', 'Belly breathing, and four more pelvic-floor exercises', 'Kegels done correctly / long holds and quick flicks / connecting breath, pelvic floor and deep core / using it when you lift, cough and carry her', BUILT, S_MAA),
 ('You, Maa', 'Articles x3', 'There is no bouncing back, and two more', 'The six week check and what "cleared" actually means / going back to running, or anything that bounces', BUILT, S_MAA),
 ('You, Maa', 'Activities x6', 'The movement sessions', 'First six weeks / walking / waking up your deep core / training with a gap in your stomach muscles / moving after a caesarean / getting stronger from three months. The full follow-along classes live in the yoga section — keep the short daily activities here and point there', MERGE, S_MAA),
 ('You, Maa', 'Articles x7', 'Have you eaten today?', 'What your body needs now / eating while breastfeeding without the banned list / iron and why you are so tired / calcium, your bones and the sun you never see / why you are so thirsty / when you have no appetite, hands or time / the weight question answered honestly once. ⚠️ No weight-loss framing anywhere — as a goal, a benefit or an aside', BUILT, S_MAA),
 ('You, Maa', 'Articles x3', 'What jaapa food is actually doing, and two more', 'Foods for milk supply, honestly (honest about weak evidence) / where the tradition goes too far (the honest counterweight)', BUILT, S_MAA),
 ('You, Maa', 'Recipes x6', 'Gond ke laddoo, and five more', 'Methi laddoo / panjiri and harira / ajwain, jeera water and kadha / cooking for iron / meals you can eat holding her. Add these to the shared recipe library tagged for the postpartum mother, do not build a separate recipe system', MERGE, S_MAA),
 ('You, Maa', 'Articles x8', 'Visitors and how to survive the first month, and seven more', 'Asking for help without apologising / you and your mother in law / your partner and the work he cannot see / advice you did not ask for / saying no in a house where nobody says no / help at home (maid, cook, maalishwali) / log kya kahenge. Some of the most India-specific writing in the app', BUILT, S_MAA),
 ('You, Maa', 'Article', 'Sex, contraception, and the two of you', 'The home for the "when can I get pregnant again" answer; First 40 Days links here', BUILT, S_MAA),
 ('You, Maa', 'Articles x9', 'Planning your return, and eight more', 'What maternity leave entitles you to / building a milk stash / pumping where there is no room to pump / who will hold her at ten in the morning / the guilt / the first week back / choosing not to go back / finding yourself again', BUILT, S_MAA),
 ('You, Maa', 'Articles x6', 'The 4th trimester circle, and five more', 'What other mothers are actually good for / finding your people / what to say when you do not know what to say / how the circle is kept safe / the mothers online who all seem fine', BUILT, S_MAA),
 ('You, Maa', 'Article', 'Getting sleep when she will not let you', 'THE ONE REAL CONTENT GAP. The door covers her body, mind, food, movement, people and work but not her own sleep survival: splitting the nights, protecting one block of unbroken sleep, why broken sleep is not the same as short sleep, and the line where exhaustion tips into something that needs the mood area', NEW, S_MAA),
 ('You, Maa', 'Card', 'Your thyroid after birth', 'Postpartum thyroid trouble is common and often missed, and it mimics depression, fatigue and hair loss. Mentioned inside the mood pages, but a mother searching "thyroid after delivery" will not find it. Could be a card inside "When will I feel normal"', NEW, S_MAA),
 ('You, Maa', 'Wiring', 'Eight dead product links', 'Maternity pads and cotton underwear, perineal spray and sitz care, C-section belts and scar care, nursing bras and nipple cream, scar creams and sheets, postpartum belts, pumps and cooler bags. The biggest dead end in the door: point them at the shared products surface tagged postpartum, do not build a separate shop', WIRING, S_MAA),
 ('You, Maa', 'Wiring', 'The 4th-trimester circle links', '"Open your circle" and "other mothers at your stage" go nowhere. It is a moderated postpartum room in Community, not a separate build. The distress-routing and privacy-from-family framing are already written and excellent', WIRING, S_MAA),

 # ---- What to buy ---------------------------------------------------------
 ('What to buy', 'Guides x9', 'The nine honest product guides', 'Fragrance-free baby lotion / tear-free baby wash / newborn diapers / water wipes / electric steam sterilizer / single electric breast pump / stage 1 infant formula / ergonomic baby carrier / lightweight travel stroller. Each carries a verdict from "highly recommended" to "situational", set by the same honest arithmetic', BUILT, S_BUY),
 ('What to buy', 'Guidance cards x18', 'One buying-guidance card per shelf', 'Sleep 3, skincare 3, feeding 3, play and development 3, health and safety 3, on the move 3. A plain line on what the thing is for, what to look for and what to avoid. They lead the page on purpose, so the shelf teaches before it sells', BUILT, S_BUY),
 ('What to buy', 'Note', 'Formula and bottles: information only', 'No buy button, by law. The "any stage-1 meets the same standard" honesty is exactly right. Keep every bit of the IMS wording', BUILT, S_BUY),
 ('What to buy', 'Single-source', 'The what-to-look-for advice, written three times', 'The same buying advice sits in the guide, again on the shelf guidance card, and a third time on the compare screen "what actually matters" panel. Three copies drift and one ends up wrong. Make the guidance-card dataset the one source and have the compare panel read from it', MERGE, S_BUY),
 ('What to buy', 'Wiring', 'Seven "compare" links land on an empty tray', 'Links across Health and First 40 Days say "compare nappy rash creams", "compare malish oils side by side", "compare swaddles", "compare nasal aspirators". Every one opens the compare screen with nothing in it, because the link never says which products to compare', WIRING, S_BUY),
 ('What to buy', 'Wiring', 'The chooser offers the wrong guide', 'Tap the anti-colic bottle and it offers a steriliser guide, because both have the word "feeding" attached. The actual steam steriliser matches nothing, because the guide is spelled "Sterilizer" with a z and the product with an s. Match on the product own id, not a shared word', WIRING, S_BUY),
 ('What to buy', 'Wiring', 'The honest "what to skip" link lands on the shelf', 'A link reads "things worth buying, and things worth skipping" — a promise the guides keep and the catalogue does not. Point it at the guides', WIRING, S_BUY),
 ('What to buy', 'Guide', 'Before the baby comes: what you actually need, and what can wait', 'The single most searched buying question there is, and today the answer is split between the hospital-bag packer and the jaapa essentials list with no honest short real list. This is what should greet a parent who taps the tile before the baby is born', NEW, S_BUY),
 ('What to buy', 'Guide', 'The things everyone buys that you can skip', 'The most on-brand page the shop could have, and it is missing. The walker paediatricians advise against, the changing table nobody uses twice, shoes for a baby who cannot walk, the wipe warmer, the baby powder, the top-and-tail set', NEW, S_BUY),
 ('What to buy', 'Guide', 'Car seat', 'There is a car seat in the catalogue but no guide, and it is the one product where getting it wrong is a safety matter, not a comfort one. The honest India version: barely anyone here uses one, never buy it second-hand, rearward-facing for as long as possible', NEW, S_BUY),
 ('What to buy', 'Guide', 'Cot, mattress and safe sleep', 'The other safety-weight buy with no guide. Firm and flat is the whole point, and the honest India question sits under it: in a home that co-sleeps, do you even need a cot', NEW, S_BUY),
 ('What to buy', 'Guide', 'Cloth or disposable, and the langot question', 'A genuine, ongoing money-and-environment decision a huge number of Indian families weigh, and the app is silent on it', NEW, S_BUY),
 ('What to buy', 'Guide', 'Keeping mosquitoes off a baby, safely', 'Very Indian, very searched, and genuinely safety-carrying. What is safe on a baby skin and what is not, nets versus plug-ins versus patches, and the ages each is alright from', NEW, S_BUY),
 ('What to buy', 'Guide', "Second-hand and hand-me-downs: what's fine, and what to buy new", 'Hand-me-downs are the norm here, not the exception, and there is a real safety line through them: the car seat, the mattress and bottle teats should be new, while clothes, toys and a cot frame are fine passed down', NEW, S_BUY),
 ('What to buy', 'Guide', "Buying for the season she's born in", 'A light one. What changes for a summer baby versus a winter one, so a parent is not buying fleece sleepsuits in May', NEW, S_BUY),
]

# =============================================================================
#  VIDEO  (door, title, what it covers, length, status, sits inside, source)
# =============================================================================
V = [
 ('Sleep', 'Gentle ways to settle her', 'Patting, shushing, the upright hold, the transfer, on a real baby', 'TBD', REFORMAT, 'Its own page; the step-list stays as companion', S_SLEEP),
 ('Sleep', 'Malish before sleep', 'The massage sequence, demonstrated. The flagship India ritual', 'TBD', REFORMAT, 'Its own page. Shared with First 40 Days', S_SLEEP),
 ('Sleep', 'Swaddling, and when to stop', 'The hip-safe wrap, and stopping the day she can roll', 'TBD', REFORMAT, 'Its own page. Shared with First 40 Days', S_SLEEP),
 ('Sleep', 'Where we stand on sleep training', 'Gentle first and why, plus the words to push back when family says "let her cry"', 'TBD', NEW, 'Pinned at the top of "Getting her to sleep"', S_SLEEP),
 ('Sleep', 'A calming bedtime routine', 'Already filmed. Absorbs "The hour before bed" as its wind-down section', 'Built', BUILT, 'Its own page', S_SLEEP),
 ('Sleep', 'What is normal night waking', 'Three Indian parents on what their nights actually look like', 'TBD', NEW, 'Inside the night-waking table', S_SLEEP),
 ('Sleep', 'What is a sleep regression', 'The explainer film for the regression timeline', 'TBD', NEW, 'Inside the regression article', S_SLEEP),

 ('Feeding', 'Getting the latch right', 'A physical skill, shown on a real baby from several angles. The single biggest reason breastfeeding fails', 'TBD', REFORMAT, 'Its own page. Shared with First 40 Days — one film', S_FEED),
 ('Feeding', 'Positions that actually work', 'Cradle, cross-cradle, rugby hold, lying down', 'TBD', REFORMAT, 'Its own page', S_FEED),
 ('Feeding', 'Making up a bottle safely', 'Water temperature, sterilising, the ratio, timing', 'TBD', REFORMAT, 'Its own page, plus a glanceable checklist', S_FEED),
 ('Feeding', 'If he chokes: what to do', 'Back blows, infant versus older, when to call', 'TBD', NEW, 'Canonical copy lives in Health Get-help-now; Feeding links to it', S_FEED),

 ('Health', 'Clearing a blocked nose', 'Saline drops and aspirator technique. Parents get this wrong from text', 'TBD', REFORMAT, 'Its own page', S_HEALTH),
 ('Health', 'ORS, made right', 'The exact measure being made, on screen. The wrong ratio is dangerous', 'TBD', REFORMAT, 'Its own page', S_HEALTH),
 ('Health', 'How to give medicine to a baby', 'Syringe into the cheek, not the throat, and positioning. Done wrong, this chokes babies', 'TBD', REFORMAT, 'Keeping him well', S_HEALTH),
 ('Health', 'The signs that mean go now', 'Already filmed', 'Built', BUILT, 'Get help now', S_HEALTH),
 ('Health', 'If he chokes or cannot breathe', 'Infant back blows and chest thrusts, numbered steps, a "call an ambulance if" line', 'TBD', NEW, 'Get help now. THE canonical version; Feeding links here', S_HEALTH),
 ('Health', 'If he has a fit', 'On his side, nothing in the mouth, time it, when to call an ambulance', 'TBD', NEW, 'Get help now', S_HEALTH),

 ('Development', 'The normal range is much wider than you think', 'The reassurance film for a worried parent', '7 min', NEW, 'On track', S_DEV),
 ('Development', 'When something is genuinely worth checking', 'One list per area, plus "if he lost a skill, do not wait"', '7 min', NEW, 'On track', S_DEV),
 ('Development', 'When will my baby crawl?', 'The range, the signs it is coming, how to help gently', '9 min', NEW, 'When will my baby...', S_DEV),
 ('Development', 'When will my baby walk?', 'Keeps the "no baby walkers" safety note', '8 min', NEW, 'When will my baby...', S_DEV),
 ('Development', 'When will my baby say their first word?', '', '8 min', NEW, 'When will my baby...', S_DEV),
 ('Development', 'What talking looks like, month by month', 'The month-by-month arc, and counting all the languages at home together', '11 min', NEW, 'Talking', S_DEV),
 ('Development', 'How play builds the brain', 'Back-and-forth is the whole thing', '10 min', NEW, 'What to do', S_DEV),
 ('Development', 'Tummy time without the tears', 'A body position, and a parent copies that from watching, not reading', 'TBD', REFORMAT, 'What to do', S_DEV),

 ('Behaviour', "Is my baby's crying normal?", '', '5 min', NEW, 'Why is my baby crying so much?', S_BEH),
 ('Behaviour', 'How to handle a ziddi bachcha', '', '6 min', NEW, 'The ziddi child', S_BEH),
 ('Behaviour', 'The first tantrums', '', '5 min', NEW, 'The first tantrums, and hitting', S_BEH),
 ('Behaviour', 'The five steps, in the moment', '', '5 min', NEW, 'The first tantrums, and hitting', S_BEH),
 ('Behaviour', 'Saying no to everything', '', '4 min', NEW, 'She says no to everything', S_BEH),
 ('Behaviour', 'He throws everything', '', '4 min', NEW, 'He keeps doing this one thing', S_BEH),
 ('Behaviour', 'Anger, and hurting out of it', '', '6 min', NEW, 'He keeps doing this one thing', S_BEH),
 ('Behaviour', 'How much is too much, honestly', 'Screen time', '6 min', NEW, 'Screens, in a real house', S_BEH),
 ('Behaviour', 'Ending it without a meltdown', 'Ending screen time', '3 min', NEW, 'Screens, in a real house', S_BEH),
 ('Behaviour', 'Why hitting does not do what it looks like it does', 'Brand-defining, do not water down', '7 min', NEW, 'Guiding without hitting', S_BEH),
 ('Behaviour', 'A calm-down corner', '', '3 min', NEW, 'Things that actually calm him', S_BEH),
 ('Behaviour', 'Filling the tank', '', '4 min', NEW, 'Things that actually calm him', S_BEH),
 ('Behaviour', 'Big feelings, and helping him manage them', '', '5 min', NEW, 'Three to six', S_BEH),
 ('Behaviour', 'A calm jar', 'A short make-and-use film. Showing beats telling for a physical make', 'TBD', REFORMAT, 'Things that actually calm him', S_BEH),

 ('Early Learning', 'Montessori: a corner in one bedroom', '', '8 min', NEW, 'Do something today', S_EL),
 ('Early Learning', 'Telling a story with no book at all', '', '4 min', NEW, 'Stories and rhymes', S_EL),
 ('Early Learning', 'What comes before writing', '', '5 min', NEW, 'Getting ready for school', S_EL),
 ('Early Learning', 'What school readiness actually means', '', '7 min', NEW, 'Getting ready for school', S_EL),
 ('Early Learning', 'Brushing his teeth', '', '5 min', NEW, 'Good habits', S_EL),
 ('Early Learning', 'Activity how-to films x4', 'Tummy-time reach / pouring water / spooning dal / the strokes before letters. The four activities that already carry a video slot', 'TBD', NEW, 'Do something today', S_EL),
 ('Early Learning', 'Read-aloud films x6', 'One per story collection, on the first story: bedtime tales, Panchatantra, Jataka, Akbar and Birbal, Tenali Rama, stories from around the world', 'TBD', NEW, 'Stories and rhymes', S_EL),

 ('First 40 Days', 'Days 1 to 7: the first week', '', '8 min', NEW, 'Din by Din', S_F40),
 ('First 40 Days', 'When to rush to the doctor', 'The read-once-while-calm reference', '6 min', NEW, 'When to Rush to the Doctor', S_F40),
 ('First 40 Days', 'Looking after the cord stump', '', '4 min', NEW, 'Samjho Your Newborn', S_F40),
 ('First 40 Days', 'His first bath, and when to start', 'Bathing a slippery newborn is a scary physical skill and there is no film today', 'TBD', REFORMAT, 'Samjho Your Newborn', S_F40),
 ('First 40 Days', 'Carrying him, and the jhula', 'Airway safety, so the film is the right call', '9 min', NEW, 'Malish, Jhula and Soothing', S_F40),
 ('First 40 Days', 'The quick daily check', '', '4 min', NEW, 'Is My Baby OK?', S_F40),
 ('First 40 Days', 'Your bleeding: what is normal', '', '9 min', NEW, 'Maa Ki Dekhbhaal', S_F40),
 ('First 40 Days', 'Ask anything, at any hour', 'The what-to-ask / what-it-will-not-do onboarding for Ask Veda', '7 min', NEW, 'Puchho ParentVeda', S_F40),
 ('First 40 Days', 'The First 40 Days course', 'The paid course trailer', '3 min', NEW, 'The Jaapa Course', S_F40),
 ('First 40 Days', 'What you actually need', '', '5 min', NEW, 'Jaapa Essentials', S_F40),

 ('Potty training', 'How long this actually takes', 'The honest timeline, from the first su-su to dry nights', '5 min', NEW, 'Pinned card', S_POT),
 ('Potty training', 'What is su-su cueing?', 'A physical skill: the supported hold, the sound', '5 min', NEW, 'Catching the su-su', S_POT),
 ('Potty training', 'The signs she is ready', '', '6 min', NEW, 'Is she ready yet?', S_POT),
 ('Potty training', 'The daily routine', 'The five fixed moments', '9 min', NEW, 'Starting out, day by day', S_POT),
 ('Potty training', 'The Indian toilet, and going out', 'The supported squat, the balance and something to hold, the bucket-and-mug technique, front to back. THE clearest missing video in the door — a physical, India-specific skill the page itself calls "the main event"', 'TBD', REFORMAT, 'Starting out, day by day', S_POT),
 ('Potty training', 'Accidents are normal', '"What to do with your face" — the film is the right medium for a tone lesson', '5 min', NEW, 'Accidents, refusals and going backwards', S_POT),
 ('Potty training', 'Draw the potty steps', '', '3 min', NEW, 'Things to do together', S_POT),
 ('Potty training', 'Dry nights come later', 'Honest: "you cannot train them"', '7 min', NEW, 'Dry nights, and doing it herself', S_POT),

 ('Traditions', 'Kajal, honey and the cord, explained calmly', '★ THE most valuable film in the door, so it goes first. Its own line says it best: the version to watch WITH a grandmother, not at her', '5 min', NEW, 'Customs done with love that are not safe', S_TRAD),
 ('Traditions', 'Jhula, the cradle ceremony', 'Setting the cradle up safely, and the three checks. The safety-carrying one of the four early ceremonies', '5 min', NEW, 'Welcoming her home', S_TRAD),
 ('Traditions', 'Mundan, the first head shaving', 'The hold that keeps his head still, and the blade check', '6 min', NEW, 'Hair, ears and the first birthday', S_TRAD),
 ('Traditions', 'Karnavedha, ear piercing', 'The piercing and the six weeks after', '5 min', NEW, 'Hair, ears and the first birthday', S_TRAD),
 ('Traditions', 'Tahneek, the first sweet taste', 'Short but safety-carrying: the trace, clean hands, no honey', '3 min', NEW, 'Ceremonies in Muslim, Christian, Sikh, Jain and Parsi families', S_TRAD),
 ('Traditions', 'Aqiqah, and naming in a Muslim family', '', '6 min', NEW, 'Five-faith area', S_TRAD),
 ('Traditions', 'Baptism, christening and dedication', '', '5 min', NEW, 'Five-faith area', S_TRAD),
 ('Traditions', 'Naam Karan at the Gurdwara, and kesh', '', '5 min', NEW, 'Five-faith area', S_TRAD),
 ('Traditions', 'Welcomes in Jain and Parsi families', '', '5 min', NEW, 'Five-faith area', S_TRAD),
 ('Traditions', 'Chatti, the sixth day', '', '5 min', NEW, 'Welcoming her home', S_TRAD),
 ('Traditions', 'Namkaran, the naming ceremony', '', '6 min', NEW, 'Welcoming her home', S_TRAD),
 ('Traditions', 'Nishkramana, the first outing', '', '4 min', NEW, 'Welcoming her home', S_TRAD),
 ('Traditions', 'Annaprashan, the first solid food', 'How to hold and feed on the day', 'TBD', NEW, 'Her first solid meal', S_TRAD),
 ('Traditions', 'The first birthday', '', '5 min', NEW, 'Hair, ears and the first birthday', S_TRAD),
 ('Traditions', 'Aksharabhyasam, the first letters', '', '4 min', NEW, 'Hair, ears and the first birthday', S_TRAD),
 ('Traditions', 'The ceremonies of the first year', 'The overview film', '6 min', NEW, 'Which ceremony is coming up now?', S_TRAD),
 ('Traditions', 'A complete ceremony in one hour, at home', 'Shows the whole "small is complete" idea in one go', '6 min', NEW, 'What it costs, and how to keep it small', S_TRAD),

 ('You, Maa', 'How do you feel right now? (11 feeling-films)', '★ THE highest-value video set in the app, and the priority to film. Low / crying / numb / rage / anxious / identity / guilty / alone / intrusive thoughts / resentment. A mother needs to hear "I feel nothing at all" said aloud by someone who has been there', '~55 min total', NEW, 'I do not feel like myself — a video shelf', S_MAA),
 ('You, Maa', 'The pelvic floor exercises (5 films)', 'Belly breathing / kegels done correctly / long holds and quick flicks / connecting breath, pelvic floor and deep core / using it when you lift, cough and carry her. A physical skill you cannot see, so video is essential', '5-9 min each', NEW, 'Leaks, heaviness and your pelvic floor', S_MAA),
 ('You, Maa', 'The movement sessions (6 films)', 'First six weeks / walking / waking up your deep core / training with a gap in your stomach muscles / moving after a caesarean / getting stronger from three months. Follow-along', 'TBD', NEW, 'Moving again, at your own pace', S_MAA),
 ('You, Maa', 'The healing-kitchen recipes (6 films)', 'Gond ke laddoo / methi laddoo / panjiri and harira / ajwain, jeera water and kadha / cooking for iron / meals you can eat holding her', 'TBD', NEW, 'The healing kitchen — filmed into the shared recipe library', S_MAA),
 ('You, Maa', "Mothers' stories, and finding yourself (2 films)", 'Going back to work, or choosing not to, and the person she was before', 'TBD', NEW, 'Going back, and finding yourself again', S_MAA),

 ('What to buy', 'The expert films behind four guides', '⚠️ COMMERCIAL FLAG. Four of the nine expert-video cards have no film behind them and say so honestly. That is fine, except this exact surface is SPONSORED inventory — a stub here is a paid slot sitting on top of nothing. Flag it before anyone sells against a film that has not been shot', 'TBD', NEW, 'The product guides', S_BUY),
]

# =============================================================================
#  IMAGE  (door, what it is, kind, size to deliver, what it should show,
#          what it belongs to, source)
# -----------------------------------------------------------------------------
#  Sizes are read off the code, not guessed, and are the same card geometry the
#  TTC and Pregnancy sheets use — parenting draws the same ContentCard.
#  ⚠️ DELIVER AT 3x. A logical point is three pixels on the phones this app is
#  used on. The numbers below are already multiplied.
# =============================================================================
CARD = ('426 x 528 px  (142x176 pt @3x, portrait 4:5). FULL-BLEED: the title is '
        'laid over the picture, not printed under it')
HERO = ('1800 x 1400 px  (fetched at 900x700 today). Cropped to roughly 16:10 '
        'on screen, so keep the subject centred')
CARO = '1080 x 438 px  (full width x 146 pt @3x, landscape strip)'
ILLU = '1080 x 1080 px  (square illustration)'
GRID = '720 x 720 px each  (square, in a matched grid — same crop and lighting across the set)'
PHOTO = '1080 x 810 px  (4:3 photograph)'
PROD = '1000 x 1000 px  (square, plain background)'
RIVE = 'Rive vector file, not pixels. Loop length and view angle in the note'

I = [
 ('All doors', 'Card art for every content card', 'Card art', CARD,
  'One per card. It fills the whole card and the title sits on top of it, so keep the lower '
  'third calm and uncluttered or the title stops being readable',
  'Every article, guide, video, story, activity, recipe, chart and product card across the '
  'eleven doors (roughly 350 once the story and activity sets are counted individually)', 'All briefs'),
 ('All doors', 'Door hero photograph', 'Door hero', HERO,
  'One per door, eleven in all. Indian homes, real light, unposed. Sleep is dim and quiet; '
  'You, Maa is her alone and unhurried; Traditions is warm and full of people',
  'The eleven door tiles', 'All briefs'),

 ('Sleep', 'Safer bed-sharing setup', 'Labelled illustration', ILLU,
  'HIGH STAKES. One labelled safe-setup picture and what to clear away. The harm-reduction '
  'wording stays under it. Shared with First 40 Days — draw it once',
  'The "Safer bed-sharing" page', S_SLEEP),
 ('Sleep', 'On her back, every sleep', 'Illustration', ILLU,
  'A simple visual: back is the way, every sleep', 'That page', S_SLEEP),
 ('Sleep', 'The overtired baby', 'Carousel art', CARO + '  x 4-5 cards',
  'Catching the window: what overtired looks like before it tips', 'That carousel', S_SLEEP),
 ('Sleep', 'Sleep away from home', 'Carousel art', CARO + '  x 4 cards',
  "Nani's house, a wedding, a festival, a train", 'That carousel', S_SLEEP),
 ('Sleep', 'The worry set', 'Carousel art', CARO + '  x 4 cards',
  'Only sleeps on me, naps only 30 min, up at 5am, sleeps all the time', 'That carousel', S_SLEEP),
 ('Sleep', 'The music myths', 'Carousel art', CARO + '  x 3-4 cards',
  'Myth versus truth, one per card', 'Inside "Does music actually help babies sleep?"', S_SLEEP),
 ('Sleep', 'Why her sleep is not like yours', 'Animation', RIVE + '. Short loop',
  'The two cycle waves side by side: she surfaces twice as often as you', 'That page', S_SLEEP),

 ('Feeding', 'How to cut food so it does not choke him', 'Labelled illustration', ILLU + '  x 6-8 foods',
  '★ HIGHEST-STAKES IMAGE IN THE STAGE. A labelled "cut it this way" visual — grapes quartered '
  'lengthways, round foods, nuts, whole carrot. Text is the wrong medium for a choking-prevention page',
  'The choking-prevention page', S_FEED),
 ('Feeding', 'What an allergic reaction looks like', 'Clinical photograph', GRID + '  x 4-6',
  'Hives, swelling of the face and lips, and what a mild rash looks like next to one that is not. '
  'Paired with a clear call-now block for breathing and face', 'That page', S_FEED),
 ('Feeding', 'Textures, stage by stage', 'Photograph set', PHOTO + '  x 4',
  'What each texture actually looks like in a katori: puree, mash, soft finger food, chopped. '
  'Photos beat a chart here', 'That page', S_FEED),
 ('Feeding', 'Gagging vs choking', 'Carousel art', CARO + '  x 4 cards',
  'Gagging is normal and noisy; choking is silent. The visual difference, card by card', 'That carousel', S_FEED),

 ('Health', 'Which rash is this?', 'Clinical photograph grid', GRID + '  x 10-12',
  '★ THE TOP VISUAL FIX IN THE STAGE, and the one with real medical weight. A labelled grid: '
  'this is HFMD, this is nappy rash, this is eczema, this is prickly heat, this is the glass-test '
  'one that means go now. ⚠️ Must be shot or licensed on INDIAN SKIN TONES — a rash grid on pale '
  'skin is useless to this audience — and every image verified by a paediatrician before it ships',
  'The "Which rash is this?" page', S_HEALTH),
 ('Health', 'Spotting dehydration early', 'Illustrated signs', ILLU + '  x 5',
  'Sunken eyes, no tears, dry mouth, few wet nappies, sunken soft spot. Visual, not a text chart',
  'That page', S_HEALTH),
 ('Health', "Reading a baby's temperature", 'Labelled how-to', ILLU + '  x 3',
  'Where to measure, and what is normal by route. A quick labelled how-to beats prose', 'That page', S_HEALTH),
 ('Health', 'Teething, and why it does not cause a high fever', 'Carousel art', CARO + '  x 4 cards',
  'Myth versus fact, one per card', 'That carousel', S_HEALTH),
 ('Health', 'The sponging myths', 'Carousel art', CARO + '  x 3-4 cards',
  'Lifted out of the fever article into a small myth-vs-fact carousel', 'Inside "Bringing a fever down"', S_HEALTH),
 ('Health', 'Common accidents, fast', 'Card art', CARD + '  x 4',
  'Swallowed something (button battery, magnet), a burn, a bad fall or head bump, something in the eye',
  'The "Common accidents, fast" cards', S_HEALTH),

 ('First 40 Days', 'What his poop should look like', 'Colour strip', PHOTO + '  x 5-6',
  'A colour strip of what each looks like. Parents are literally matching a nappy to a picture',
  'The nappies page', S_F40),
 ('First 40 Days', 'His skin looks strange. Is that normal?', 'Photograph carousel', GRID + '  x 5',
  'Milia, stork mark, the grey-blue patch, cradle cap, newborn acne. ⚠️ On Indian skin tones. '
  'Skin is a see-it-to-know-it thing', 'That carousel', S_F40),
 ('First 40 Days', 'How far the yellow has spread', 'Illustration', ILLU + '  x 3',
  'Face, chest, palms. Light touch, but it helps a parent judge jaundice', 'The jaundice page', S_F40),
 ('First 40 Days', 'Hiccups, sneezes, grunts and other noises', 'Carousel art', CARO + '  x 5 cards',
  'Swipe through the normal noises. Light', 'That carousel', S_F40),

 ('Traditions', 'Kajal, the cord and the frog-leg swaddle', 'Labelled illustration', ILLU + '  x 4',
  'Where a kajal dot may safely go, the bare dry cord stump, the frog-leg swaddle position, '
  'head-shaping. These are do-this-not-that, which a photo settles faster than words. The card '
  'text stays as written', 'The "On a newborn" cards', S_TRAD),

 ('Development', 'The ten leap phases', 'Illustration set', ILLU + '  x 10',
  'One per phase, keeping the fun names. ⚠️ Whatever is drawn must not imply an exact week',
  'The phase calendar', S_DEV),

 ('Behaviour', 'Balloon breathing', 'Animation', RIVE + '. Loops on the breath',
  'Use the shared breathing-circle already built for Mind and body and Kriya. Do not build a second',
  'Things that actually calm him', S_BEH),

 ('You, Maa', 'Finding the right muscle', 'Anatomical animation', RIVE + '. Slow loop',
  'The internal pelvic-floor muscle contracting. Explicitly NOT a filmed body — this is the one '
  'exercise a camera cannot show', 'The pelvic-floor exercises', S_MAA),

 ('Early Learning', 'Story illustration', 'Illustration', ILLU + '  x 58 stories',
  'One per story across the six collections. Indian visual idiom, not a Western storybook look',
  'Little bedtime tales 10, Panchatantra 12, Jataka 10, Akbar and Birbal 10, Tenali Rama 6, '
  'around the world 10', S_EL),
 ('Early Learning', 'Activity photograph', 'Photograph', PHOTO + '  x 36',
  'One per activity, shot in a real Indian kitchen with what is already in it: the katori, the '
  'empty dabba, kaju and stones, the sabzi shop', 'The 36 age-sorted activities', S_EL),

 ('What to buy', 'Product photography', 'Product photo', PROD + '  x 23 products',
  'Real packshots on a plain background', 'The catalogue', S_BUY),
 ('What to buy', 'Guide hero photography', 'Photograph', PHOTO + '  x 9 (17 once the new guides land)',
  'The product in a real home, not a studio', 'The product guides', S_BUY),
]

# =============================================================================
#  OTHER  (door, type, item, what we have to provide, source)
# =============================================================================
O = [
 ('Early Learning', 'Audio', '58 story narrations', '⚠️ THE BIGGEST SINGLE PRODUCTION ASK IN THE APP. Every one of the 58 stories is text with a "listen" button and not one is recorded. A story library with no narration is half-built, and the brief names this as the first job. Hindi and English narration, one voice per collection', S_EL),
 ('Early Learning', 'Audio', 'The rhymes and songs collection', 'A whole new audio-first collection: Hindi, English and regional action rhymes. ⚠️ Original or public-domain rhymes only — never copyrighted song lyrics', S_EL),
 ('Sleep', 'Audio', 'The Sleep Sounds library', 'Five categories: lullabies and lori, white noise and womb, nature and calm, soft ragas, bedtime stories. Shares assets with Garbh Sanskar Shravan — record once', S_SLEEP),
 ('Sleep', 'Audio', 'What to do at 3am', 'A short spoken version as an alternative to the tap-through interactive, for a parent who cannot look at a screen', S_SLEEP),
 ('Sleep', 'Data', 'Wake windows by age', 'The happy-awake window per age band (newborn about 45-60 min, rising). Framed as a guide, not a stopwatch', S_SLEEP),
 ('Sleep', 'Sponsor', 'The Sleep journey tracker, presented by Pampers', 'Already sold and live. Do not move or remove the sponsorship in the rebuild', S_SLEEP),
 ('Feeding', 'Data', 'Formula amounts by age and weight', 'ml per feed and per day. ⚠️ Framed as a guide, not a quota, and signed off by the paediatric nutritionist who already reviews Recipes', S_FEED),
 ('Feeding', 'Data', 'Indian formula compared honestly', 'The comparison table behind that page. Real brands, real prices, refreshed on a schedule', S_FEED),
 ('Feeding', 'Expert', 'A lactation consultant', 'For the latch and positions films, and the 1:1 consult roster', S_FEED),
 ('Health', 'Data', 'The canonical go-to-hospital red-flag list', '⚠️ ONE list, verified by a paediatrician, that the fever-check gate and the fever red flags both read from. It is copied in three places today and will drift', S_HEALTH),
 ('Health', 'Data', 'IAP vaccination schedule v2026.1', 'Already reviewed by Dr Ananya Rao. Needs a refresh owner as IAP revises it', S_HEALTH),
 ('Health', 'Data', 'Government hospital versus private clinic costs', 'Real INR ranges per shot, by city tier', S_HEALTH),
 ('Health', 'Expert', 'A paediatrician, and legal sign-off', '⚠️ Specifically for the paracetamol / ibuprofen decision. If the numeric doses stay, they need BOTH a paediatrician and legal sign-off plus a weight calculator the medical board owns', S_HEALTH),
 ('Health', 'Expert', 'A paediatric dermatologist', 'To verify every image in the rash grid, on Indian skin tones', S_HEALTH),
 ('Development', 'Expert', 'A developmental paediatrician', 'For the milestone windows and the "worth getting checked" lists', S_DEV),
 ('Development', 'Expert', 'A speech therapist', 'For the talking arc and the consult roster behind "when talking is worth checking"', S_DEV),
 ('Behaviour', 'Expert', 'A child psychologist', 'The consult roster the door closes on, single-sourced with the in-page consult on the sibling page', S_BEH),
 ('Behaviour', 'Data', 'The "What to say when..." script library', 'The hero tool. Six pages point at it, so it is one library, scoped to his age', S_BEH),
 ('First 40 Days', 'Expert', 'A lactation consultant and a paediatrician', 'The in-page consults that fire where the need is real. Deliberately no closing "book someone" footer', S_F40),
 ('Potty training', 'Expert', 'A paediatrician', 'The closing offer, plus the three in-page consults on withholding, regression and bedwetting', S_POT),
 ('Traditions', 'Data', 'Real ceremony price ranges', 'Honest INR ranges nobody publishes, plus three versions of the same ceremony by size', S_TRAD),
 ('Traditions', 'Data', 'The names library', 'Names by meaning, origin, sound and letter, with a shortlist a couple builds together. Shared tool, lives once', S_TRAD),
 ('Traditions', 'Data', 'Dadi ke nuskhe, checked', 'The home remedies every family passes down, each marked honestly for whether it is safe. Shared tool', S_TRAD),
 ('You, Maa', 'Expert', 'A maternal mental-health roster', '⚠️ Referenced 6+ times and built nowhere. Almost every serious page in the door ends in this consult', S_MAA),
 ('You, Maa', 'Expert', 'A pelvic-floor physiotherapist roster', '⚠️ Referenced 7+ times and built nowhere. The other half of the door consult backbone', S_MAA),
 ('You, Maa', 'Data', 'India perinatal crisis helpline numbers', '⚠️ Real, verified, current numbers. The crisis path is one tap from the triage; a dead helpline number here is the worst possible failure in the app', S_MAA),
 ('You, Maa', 'Community', 'The 4th-trimester circle', 'A moderated postpartum room in Community. The written distress-routing and privacy-from-family framing already exist and are excellent — this needs a moderator, not copy', S_MAA),
 ('What to buy', 'Data', 'Real products for 15 near-empty shelves', '⚠️ COMMERCIAL DECISION, NOT A CONTENT ONE. Fifteen of the eighteen shelves hold a single product, so a parent who taps "thermometers" expecting a choice finds one item. Either fill the catalogue, or own it: let the guidance card be the content and the one product be the example', S_BUY),
 ('What to buy', 'Expert', 'On-camera experts for four guides', 'The four expert-video cards with no film behind them, on sponsored inventory', S_BUY),
]

# =============================================================================
#  Criticality and film-maker classifiers
# =============================================================================
CRITICAL = 'CRITICAL — verify before it ships'
CLINICAL = 'Clinical — a doctor signs it'
SOFT = 'Not clinical — an editor is enough'

_CRIT = {
    'Paracetamol and ibuprofen: the typical ranges',
    'Go to a hospital now', 'The three speeds',
    'If he chokes or cannot breathe', 'If he has a fit', 'Common accidents, fast',
    'If he chokes: what to do', 'Gagging vs choking',
    'Choking, and how to cut food so it does not happen',
    'What an allergic reaction looks like', 'Which rash is this?',
    'Spotting dehydration early', 'ORS, made right',
    'How to give medicine to a baby', 'Cough syrups: what is safe and what is not',
    'A fever in a baby under three months', 'Fever red flags: when to stop watching',
    'Newborn jaundice', 'When night waking needs a doctor',
    'Safer bed-sharing', 'On her back, every sleep', 'SIDS, explained calmly',
    'Swaddling, and when to stop', 'Sleeping safely, in your bed or his',
    'When crying needs a doctor', 'When the crying is too much',
    'When the crying will not stop', 'When to rush to the doctor',
    'Jaundice: what to watch and when it matters',
    'Postpartum psychosis: rare, urgent, know the signs',
    'When to call a doctor, not wait', 'Sore, rock hard breasts',
    'Your breasts in the early weeks', 'Bringing home a small or early baby',
    'A hot, painful lump in the breast', 'She is holding it in',
    'On a newborn: kajal, honey and the cord',
    'On the day: blades, piercing and heat',
    'The ceremonies, and keeping him safe through them',
    "The baby's first festivals, done safely",
    'When something is genuinely worth checking', 'When talking is worth checking',
    'When fear or clinginess is worth checking', 'Growth that needs a doctor',
    'When to stop exercising and see a physio', 'Breath-holding spells',
    'Car seat', 'Cot, mattress and safe sleep', 'Keeping mosquitoes off a baby, safely',
    "Second-hand and hand-me-downs: what's fine, and what to buy new",
    'Formula and bottles: information only',
    "Your baby's phase calendar (the ten phases)",
}
_SOFT = {
    'The old practices: which help and which harm', 'Sleep away from home',
    'Moving her to her own cot or room', 'Sleep in a joint family or a shared room',
    'The worry set', 'Where we stand on sleep training', 'Why there are no star charts here',
    'One word, whole house', 'School toilets, and toilets out in the world',
    'Boys and girls, the small differences', 'Do pull-ups help or hurt?',
    'What a ceremony actually costs', 'How to keep it small',
    'What to say when family wants it bigger',
    'How the date gets chosen, and what to do when it does not suit the baby',
    'How Indian families choose the name', 'If you would rather not do a ceremony at all',
    "Going to someone else's baby's ceremony", 'Twins, an adopted baby, or the second child',
    'Interfaith families, and doing this far from home', 'When the mother is kept apart',
    'Back-talk, and "I hate you"', 'The shy child, and "say hello, beta"',
    'Why he is suddenly scared of everything', 'Fear of the dark, and the monster under the bed',
    'Scared of dogs, lifts and loud noises', 'The doctor, the injection, the haircut',
    'Nail-biting and the other little habits', 'Thumb-sucking, and when to just leave it',
    'English or the mother tongue, and when to start letters',
    'Rhymes and songs, a new collection', 'What school readiness actually means',
    'The readiness checklist', 'Choosing a preschool', 'The crying at the gate',
    'What comes after preschool', 'Montessori without the forty thousand rupee school',
    'Setting up a corner he is allowed to touch', 'Letting him help with real work',
    'Following what he is already interested in',
    'Reading to a baby who cannot understand a word',
    'Telling a story with no book at all', 'What to say when the story ends',
    'Activities for feelings and getting on with others',
    'Things to do today, from around the house', 'Messy play, and why it is worth the mess',
    'For your husband, in the first 40 days', 'The pressure to make him mota',
    'Log kya kahenge', 'Getting the most out of seven minutes',
    'The things everyone buys that you can skip',
    'Before the baby comes: what you actually need, and what can wait',
    'Cloth or disposable, and the langot question',
    "Buying for the season she's born in",
    'The what-to-look-for advice, written three times',
    'The nine honest product guides', 'One buying-guidance card per shelf',
    'You made it to 40 days. What now?',
    'Sex, contraception, and the two of you',
}


def criticality(title, ctype, status):
    """Parenting has its own badge words, so criticality is derived from what
    the piece IS, never from its status. The one thing that travels between
    stages: if getting it wrong hurts a child, it is CRITICAL."""
    if title in _CRIT:
        return CRITICAL
    if status in (REF, WIRING):
        return 'n/a — no writing to verify'
    if ctype in ('Red flag card', 'Flagged callout', 'Flagged reference',
                 'Flagged article', 'Article + red flag', 'Article + callout',
                 'Video + steps', 'Article + consult'):
        return CRITICAL
    if title in _SOFT or ctype in ('Story', 'Stories x6', 'Stories x10', 'Stories x12',
                                   'Rhymes collection', 'Script box', 'Routes x8',
                                   'Card', 'Cards', 'Note', 'Guidance cards x18',
                                   'Guide', 'Guides x9', 'Single-source', 'Checklist',
                                   'Activities x36', 'Activities x3', 'Activities x4',
                                   'Activities x5', 'Activities x6'):
        return SOFT
    return CLINICAL


AI_OK = 'AI or animation — no face needed'
AI_VO = 'AI animation, but a clinician must sign the script'
EXPERT = 'Real expert on camera'
FILMED = 'Filmed with a real person (physical skill)'
REAL = 'Filmed with real parents — the point is that they are real'

MAKER = {
 # Sleep
 'Gentle ways to settle her': (FILMED, 'Patting, shushing and the transfer, on a real baby. Never animate a hold being taught'),
 'Malish before sleep': (FILMED, 'A massage sequence on a real baby. The whole value is watching the hands'),
 'Swaddling, and when to stop': (FILMED, 'A hip-safe wrap has to be seen on real cloth and a real baby'),
 'Where we stand on sleep training': (EXPERT, 'A brand-defining position. It needs a person saying it, not a voiceover'),
 'A calming bedtime routine': (FILMED, 'Already shot'),
 'What is normal night waking': (REAL, 'Three Indian parents on their actual nights. Its credibility IS that they are real'),
 'What is a sleep regression': (AI_VO, 'A mechanism explainer over a timeline. Animation carries it'),
 # Feeding
 'Getting the latch right': (FILMED, 'A real baby at a real breast, from several angles. This is the single most-watched film in the stage and cannot be animated'),
 'Positions that actually work': (FILMED, 'Four holds, demonstrated. Spatial'),
 'Making up a bottle safely': (FILMED, 'Hands, water, powder, a real kitchen. Safety-critical, so show the actual measure'),
 'If he chokes: what to do': (EXPERT, '⚠️ Back blows on an infant manikin, taught by a paediatrician or a certified first-aid trainer. Never AI, never a stock clip'),
 # Health
 'Clearing a blocked nose': (FILMED, 'Saline drops and aspirator technique on a real baby'),
 'ORS, made right': (FILMED, 'The exact measure being made on camera. A wrong ratio is dangerous, so no animation'),
 'How to give medicine to a baby': (FILMED, 'Syringe into the cheek. Done wrong this chokes babies, so it is demonstrated'),
 'The signs that mean go now': (EXPERT, 'Already shot'),
 'If he chokes or cannot breathe': (EXPERT, '⚠️ THE canonical emergency film. Paediatrician or certified first-aid trainer, on an infant manikin. Never AI'),
 'If he has a fit': (EXPERT, '⚠️ A seizure response. A clinician on camera, demonstrated on a doll, never a real fit and never generated'),
 # Development
 'The normal range is much wider than you think': (EXPERT, 'The reassurance film. A developmental paediatrician saying it out loud is the whole point'),
 'When something is genuinely worth checking': (EXPERT, 'It routes to a doctor, so a doctor delivers it'),
 'When will my baby crawl?': (AI_VO, 'A milestone explainer over real baby footage. Animation for the range, script signed by the developmental paediatrician'),
 'When will my baby walk?': (AI_VO, 'Same, and it carries the no-baby-walkers safety note, so the script is signed'),
 'When will my baby say their first word?': (AI_VO, 'Same shape'),
 'What talking looks like, month by month': (AI_VO, 'A month-by-month arc. Animation, speech-therapist-signed script'),
 'How play builds the brain': (AI_OK, 'A mechanism explainer. Animation is honestly better than a talking head here'),
 'Tummy time without the tears': (FILMED, 'A body position. A parent copies it from watching'),
 # Behaviour
 "Is my baby's crying normal?": (EXPERT, 'Reassurance with a red flag underneath, so a clinician says it'),
 'How to handle a ziddi bachcha': (EXPERT, 'A child psychologist. India-specific framing that needs a person'),
 'The first tantrums': (EXPERT, 'Explanation plus real toddler footage'),
 'The five steps, in the moment': (FILMED, 'Steps demonstrated with a real child mid-tantrum, or as close as is filmable'),
 'Saying no to everything': (EXPERT, 'A psychologist explaining autonomy before reason'),
 'He throws everything': (EXPERT, 'Same shape'),
 'Anger, and hurting out of it': (EXPERT, 'Brand-sensitive. A person, not a voiceover'),
 'How much is too much, honestly': (EXPERT, 'Screen time. A contested topic where credibility comes from the face'),
 'Ending it without a meltdown': (FILMED, 'A technique shown with a real child and a real screen'),
 'Why hitting does not do what it looks like it does': (EXPERT, '★ The most brand-defining film in the door. It has to be a person a parent trusts, not a voice over stock footage'),
 'A calm-down corner': (FILMED, 'A physical set-up in a real Indian home'),
 'Filling the tank': (FILMED, 'A practice done with a real child'),
 'Big feelings, and helping him manage them': (EXPERT, 'A psychologist'),
 'A calm jar': (AI_OK, 'A make-and-use craft film. Hands and a jar; no face and no expertise needed'),
 # Early Learning
 'Montessori: a corner in one bedroom': (FILMED, 'A real Indian bedroom, real objects. The whole promise is that it is not a forty-thousand-rupee school'),
 'Telling a story with no book at all': (EXPERT, 'A storyteller. The technique is the performance'),
 'What comes before writing': (EXPERT, 'An early-learning educator holding the anti-worksheet line'),
 'What school readiness actually means': (EXPERT, 'Same, and it is the door credibility piece'),
 'Brushing his teeth': (FILMED, 'A physical skill on a real child'),
 'Activity how-to films x4': (FILMED, 'Hands in a real kitchen: tummy-time reach, pouring water, spooning dal, the strokes before letters'),
 'Read-aloud films x6': (REAL, 'A storyteller reading to a child. Warmth is the product; a synthetic read defeats the point'),
 # First 40 Days
 'Days 1 to 7: the first week': (EXPERT, 'A paediatrician or experienced jaapa nurse walking the first week'),
 'When to rush to the doctor': (EXPERT, 'A red-flag film. A doctor delivers it'),
 'Looking after the cord stump': (FILMED, 'A physical skill with real tetanus stakes attached'),
 'His first bath, and when to start': (FILMED, '★ Bathing a slippery newborn is the scariest physical skill of the forty days and there is no film today'),
 'Carrying him, and the jhula': (FILMED, 'Airway safety. It has to be shown with a real baby and a real jhula'),
 'The quick daily check': (AI_OK, 'A walkthrough of the app own tool'),
 'Your bleeding: what is normal': (EXPERT, 'Her own red flags. An obstetrician or midwife'),
 'Ask anything, at any hour': (AI_OK, 'A screen walkthrough of Ask Veda'),
 'The First 40 Days course': (EXPERT, 'It sells the educator, so it has to be her'),
 'What you actually need': (EXPERT, 'Commerce, so the honesty has to come from a face'),
 # Potty
 'How long this actually takes': (EXPERT, 'The pinned honest timeline. Credibility piece'),
 'What is su-su cueing?': (FILMED, 'The supported hold and the sound. A physical skill, and the door India premise'),
 'The signs she is ready': (EXPERT, 'Deliberately an explanation, not a quiz, so a person explains it'),
 'The daily routine': (FILMED, 'The five fixed moments with a real toddler'),
 'The Indian toilet, and going out': (FILMED, '★ THE clearest missing film in the door. The supported squat, the balance, the bucket and mug, front to back. India-specific and physical — no stock footage exists for this'),
 'Accidents are normal': (EXPERT, '"What to do with your face" is a tone lesson, and a face is the medium'),
 'Draw the potty steps': (AI_OK, 'A craft activity. Hands and paper'),
 'Dry nights come later': (EXPERT, 'Carries "you cannot train them" and a bedwetting red flag'),
 # Traditions
 'Kajal, honey and the cord, explained calmly': (EXPERT, '★ THE most valuable film in the door. Its own brief says it: the version to watch WITH a grandmother, not at her. That needs a warm, credible, ideally older Indian face — an AI voice would land as a lecture'),
 'Jhula, the cradle ceremony': (FILMED, 'Setting the cradle up safely and the three checks. Real cradle, real knots'),
 'Mundan, the first head shaving': (FILMED, 'The hold that keeps his head still and the blade check. Physical and safety-carrying'),
 'Karnavedha, ear piercing': (FILMED, 'The piercing and the six weeks after. Physical'),
 'Tahneek, the first sweet taste': (FILMED, 'The trace, clean hands, no honey. Short but safety-carrying'),
 'Aqiqah, and naming in a Muslim family': (REAL, 'A real family ceremony. Filming an actual welcome is the respect the whole area is built on'),
 'Baptism, christening and dedication': (REAL, 'Same'),
 'Naam Karan at the Gurdwara, and kesh': (REAL, 'Same'),
 'Welcomes in Jain and Parsi families': (REAL, 'Same'),
 'Chatti, the sixth day': (REAL, 'A ceremony walk-through with a real family'),
 'Namkaran, the naming ceremony': (REAL, 'Same'),
 'Nishkramana, the first outing': (REAL, 'Same'),
 'Annaprashan, the first solid food': (FILMED, 'How to hold and feed on the day. Physical, and it carries the no-honey rules'),
 'The first birthday': (REAL, 'A ceremony walk-through'),
 'Aksharabhyasam, the first letters': (REAL, 'A ceremony walk-through'),
 'The ceremonies of the first year': (AI_OK, 'An overview of the order things happen in. Animation over a timeline works'),
 'A complete ceremony in one hour, at home': (REAL, 'The whole "small is complete" idea shown as one real hour'),
 # You, Maa
 'How do you feel right now? (11 feeling-films)': (REAL, '⚠️ ABSOLUTELY NOT AI, and this is the clearest case in the app. The value is a real mother saying "I feel nothing at all" out loud. A synthetic voice saying it would be worse than silence'),
 'The pelvic floor exercises (5 films)': (FILMED, 'A physiotherapist demonstrating. Note the exception: "finding the right muscle" is an ANIMATION of the internal muscle, because a camera cannot show it'),
 'The movement sessions (6 films)': (FILMED, 'Follow-along, so a real body moving in real time'),
 'The healing-kitchen recipes (6 films)': (FILMED, 'Hands in a kitchen. No face needed, but real food'),
 "Mothers' stories, and finding yourself (2 films)": (REAL, 'Real mothers on returning to work or choosing not to'),
 # What to buy
 'The expert films behind four guides': (EXPERT, 'Sponsored inventory. A stub sold against a film that does not exist is a commercial problem, not just a content one'),
}

# =============================================================================
#  Workbook
# =============================================================================
INK = '1F1A29'
HDR = PatternFill('solid', fgColor='2D144C')
BAND = PatternFill('solid', fgColor='F4F1F7')
NEWFILL = PatternFill('solid', fgColor='FFF4E5')
BUILTFILL = PatternFill('solid', fgColor='E7F3EC')
REDFILL = PatternFill('solid', fgColor='FCE8E6')
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
            if st.startswith('SAFETY') or st.startswith('EVIDENCE'):
                cell.fill = REDFILL
            elif st.startswith('NEW'):
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
        ws.column_dimensions[col].width = 17

    def t(row, txt, size=13):
        ws.cell(row=row, column=1, value=txt).font = Font(name='Arial', size=size, bold=True, color=INK)

    def note(row, txt, h=30, red=False):
        c = ws.cell(row=row, column=1, value=txt)
        c.font = Font(name='Arial', size=9, color='922B21' if red else '5A5265')
        c.alignment = Alignment(wrap_text=True, vertical='top')
        ws.merge_cells(start_row=row, start_column=1, end_row=row, end_column=8)
        ws.row_dimensions[row].height = h
        if red:
            for cc in range(1, 9):
                ws.cell(row=row, column=cc).fill = REDFILL

    t(1, 'Parenting — what the eleven doors need', 16)
    note(2, 'THE HEADLINE: like pregnancy, the WRITING is largely done. Every one of the '
            'eleven briefs opens with "REUSE, DO NOT REBUILD" in capitals. What parenting '
            'is actually short of is FILM AND AUDIO — about 150 film slots and 58 story '
            'narrations, almost none of them made. Green rows are finished content: do NOT '
            'send them out to be rewritten. Amber rows are the real writing ask.', 46)
    note(3, 'Twelve briefs, eleven doors. Development has two files and the later one says '
            'in its own footer that it replaces the earlier — the reissued version is what '
            'is read here.', 30)
    note(4, 'Tools are excluded, as in the TTC and pregnancy sheets: the trackers, the '
            'checkers, the meal builder, the emergency card and the records locker are '
            'software, not pieces to write.', 30)

    r = 6
    t(r, 'Two decisions only you can make')
    r += 1
    note(r, 'HEALTH — SAFETY FLAG. The built "Paracetamol and ibuprofen: the typical ranges" '
            'page shows in-app dosing, which the brand deliberately decided to avoid. It must '
            'not ship unchanged. Either reframe it to how-to-read-the-bottle plus the overdose '
            'mistakes, with the dose deferred to the doctor and the label — or keep the numbers '
            'and get BOTH paediatric and legal sign-off plus a weight calculator the medical '
            'board owns. Doing nothing ships the numbers.', 58, red=True)
    r += 1
    note(r, 'DEVELOPMENT — EVIDENCE FLAG. The leap phase calendar still gives exact-week dates '
            '("1-25 Oct"), which the app own earlier research said do not hold up. The leap '
            'PAGE is already honest; the calendar TOOL is not. Soften to "around this age", '
            'keep the ten names and the reassuring lines. This is the one spot the door '
            'over-promises.', 48, red=True)

    r += 2
    t(r, 'Written content by door, and how much is genuinely new')
    r += 1
    for i, h in enumerate(['Door', 'Rows', 'NEW to write', 'Copy already written',
                           'Reformat / merge', 'Already built', 'Elsewhere / wiring']):
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
        ws.cell(row=r, column=5, value=sum(1 for x in rows if x[4] in (REFORMAT, MERGE, SAFETY, EVIDENCE)))
        ws.cell(row=r, column=6, value=sum(1 for x in rows if x[4] == BUILT))
        ws.cell(row=r, column=7, value=sum(1 for x in rows if x[4] in (REF, WIRING)))
        r += 1
    ws.cell(row=r, column=1, value='All eleven doors')
    for c in range(2, 8):
        L = get_column_letter(c)
        ws.cell(row=r, column=c, value='=SUM(%s%d:%s%d)' % (L, first, L, r - 1))
    for rr in range(first, r + 1):
        for c in range(1, 8):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, bold=(rr == r), color=INK)
            cell.border = BORDER

    r += 2
    t(r, 'Films, images and the rest')
    r += 1
    for i, h in enumerate(['Door', 'Film slots', 'Image / animation jobs', 'Other']):
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
    ws.cell(row=r, column=1, value='All eleven doors')
    for c in (2, 3, 4):
        L = get_column_letter(c)
        ws.cell(row=r, column=c, value='=SUM(%s%d:%s%d)' % (L, first, L, r - 1))
    for rr in range(first, r + 1):
        for c in range(1, 5):
            cell = ws.cell(row=rr, column=c)
            cell.font = Font(name='Arial', size=9, bold=(rr == r), color=INK)
            cell.border = BORDER
    r += 1
    note(r, 'The film-slot column counts ROWS on the Videos sheet, and several rows are a set '
            '("11 feeling-films", "6 read-aloud films"). The briefs own totals put the real '
            'number near 150 slots: Behaviour 14, Early Learning 15, Traditions 17 (88 minutes, '
            'none shot), You, Maa 31, First 40 Days 11, Potty 7, Development 7.', 44)

    ws.freeze_panes = 'A2'


if __name__ == '__main__':
    wb = Workbook()
    wb.remove(wb.active)
    summary(wb)
    Wx = [(d, t, ti, wh, criticality(ti, t, st), st, src) for (d, t, ti, wh, st, src) in W]
    sheet(wb, 'Written content',
          ['Door', 'Type', 'Title / topic', 'What it covers', 'Medically critical?',
           'Status', 'Source'],
          [20, 20, 44, 74, 30, 36, 30], Wx, wrap=(3, 4, 5, 6), statuscol=5)
    Vx = [(d, ti, wh, ln, MAKER.get(ti, ('To be decided', ''))[0],
           MAKER.get(ti, ('', 'Not classified'))[1], st, sits, src)
          for (d, ti, wh, ln, st, sits, src) in V]
    sheet(wb, 'Videos',
          ['Door', 'Video title', 'What it covers', 'Length', 'AI, or a real expert?',
           'Why', 'Status', 'Sits inside', 'Source'],
          [20, 40, 52, 14, 32, 60, 30, 40, 30], Vx, wrap=(2, 3, 5, 6, 7, 8), statuscol=6)
    sheet(wb, 'Images',
          ['Door', 'What the image is', 'Kind', 'Size to deliver', 'What it should show',
           'What it belongs to', 'Source'],
          [20, 40, 24, 44, 74, 44, 30], I, wrap=(2, 4, 5, 6))
    sheet(wb, 'Other',
          ['Door', 'Type', 'Item', 'What we have to provide', 'Source'],
          [20, 14, 40, 80, 30], O, wrap=(3, 4))
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
    print()
    unclassified = [x[1] for x in V if x[1] not in MAKER]
    print('videos with no maker call: %d' % len(unclassified))
    for u in unclassified:
        print('   ! %s' % u)
    print('-> %s' % os.path.relpath(OUT, ROOT))
