// =============================================================================
//  Jaapa: Your First 40 Days — the section's content
// -----------------------------------------------------------------------------
//  Built from docs/../pp_specs/08-first-40-days.md. Ten areas plus four tools.
//
//  ⚠️ THIS SECTION LANDS ON THE PEAK-FEAR MOMENT OF THE WHOLE PRODUCT. The spec
//  says it plainly: "a scared parent at day 3". So every page here is written
//  reassurance-first and instruction-second. The order inside a page is not a
//  style choice, it is the design: she is told the thing is ordinary, then told
//  what to do about it. A page that opens with a warning has already failed,
//  because a frightened reader stops at the first alarming line and never
//  reaches the part that would have calmed her.
//
//  ⚠️ AND YET THE RED FLAGS MUST BE UNMISSABLE. Newborn danger signs are
//  genuinely time-critical, so "When to Rush to the Doctor" is the SECOND area,
//  above everything except the day spine, and it carries no product, no course
//  and no paid consult. Only a free link to a human. The spec asks for the
//  consult to be surfaced on that card; the same spec also says the card is
//  upsell-free and carries no commerce. Both are honoured by linking to the
//  expert door with no price and no sell, and putting the actual paid
//  `PpConsult` on the feeding and tracker pages instead.
//
//  ⚠️ THE SPINE IS DAYS, AND `PpBand` COUNTS MONTHS. Stated here because it is
//  the one place this file bends the shared mechanism. `ppDaysSinceBirth`
//  exists (see pp_age_bands.dart) and is the honest unit for a 0-to-40-day
//  section, but `PpPage.bands` is matched against a `PpBandSet` and a band
//  boundary is an `int` month. Days 1 to 30 all floor to month 0, so month
//  bands physically cannot separate "week 1" from "week 3".
//
//  The choice made: THREE honest month bands (the first month / the 40-day mark
//  / past the 40 days) rather than four fake ones whose day labels would be
//  wrong for most readers in them. The four day phases the spec asks for exist
//  as PAGES inside "Din by Din", all visible through the first month, so a
//  mother at day 3 can read ahead and a mother at day 25 is not told day 3 is
//  her present. A true day-level spine needs day boundaries on `PpBand`, and
//  that is written up as a follow-up rather than faked here.
//
//  ⚠️ MYTH VERSUS EVIDENCE, NOT TRADITION VERSUS SCIENCE. Jaapa is honoured on
//  every page it touches, and the specific practices that harm are named
//  specifically. A page that dismissed the whole tradition would be ignored by
//  the grandmother running the house, and she is the reader who can actually
//  change what happens to the baby.
//
//  ⚠️ BOUNDARY: the baby, plus the mother's IMMEDIATE first weeks, live here.
//  Deeper and ongoing recovery (postpartum depression care, pelvic floor,
//  return to work) belongs to the "You, Maa" section and is LINKED, not rebuilt.
//
//  ⚠️ NO GAMIFICATION ANYWHERE. Counts are fine, streaks are not. A woman on day
//  6 after a caesarean must never be told she missed a day.
//
//  ⚠️ EVERY CLINICAL NUMBER IN THIS FILE CARRIES A `REQUIRED_REVIEW` COMMENT.
//  Temperatures, nappy counts, feed intervals, weight-loss percentages,
//  breathing rates and bleeding thresholds are all marked, because a number is
//  the one kind of copy tone cannot soften: if it is wrong, it is wrong at the
//  moment it matters most. A paediatrician and an obstetrician sign these off
//  before release. Grep `REQUIRED_REVIEW` for the full list.
//
//  ⚠️ ENGLISH ONLY FOR NOW, per the standing instruction. Hinglish where the
//  Hinglish word IS the word: jaapa, malish, jhula, kadha, gond laddoo, dai,
//  maalishwali, nada, janam ghutti.
// =============================================================================

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  Declared here rather than in pp_age_bands.dart because no other section
//  measures this window, and a shared set would invite someone to move a
//  boundary here for a reason about six-week checks.
//
//  Three bands, not four. See the file header: months cannot split the first
//  thirty days, and a coarse label beats a label that lies.
// =============================================================================

const PpBandSet kPpJaapaBands = PpBandSet([
  PpBand(
    id: 'jaapa_first_month',
    label: 'The first month',
    fromMonths: 0,
    toMonths: 1,
    blurb: 'Roughly day 1 to day 30. The part nobody could have prepared you '
        'for, and the part that goes fastest.',
  ),
  PpBand(
    id: 'jaapa_forty',
    label: 'The 40-day mark',
    fromMonths: 1,
    toMonths: 2,
    blurb: 'Weeks 5 and 6. The forty days of rest are ending, and a rhythm is starting to '
        'show.',
  ),
  PpBand(
    id: 'jaapa_after',
    label: 'Past the 40 days',
    fromMonths: 2,
    toMonths: 600,
    blurb: "You're through it. Everything here stays open, because newborn "
        "questions don't stop on day 41.",
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpFirst40Section = PpSection(
  id: 'parenting_first_40', // MUST match the hub's bracketId
  title: 'Your First 40 Days',
  // ⚠️ THE AGE RULE. "Drop the three buttons at the top. The app knows the
  // baby's age, so open on where she is now. Only one area, the day-by-day
  // guide, actually changes by stage."
  autoScope: true,
  subtitle: 'Newborn care, and care for you, the person who just gave birth.',
  intro: "The first forty days are loud, tender and very short. Here's "
      "what's normal, what to do, and the few things that need a doctor "
      'today.',
  bandSet: kPpJaapaBands,
  areas: [
    // =========================================================================
    //  1. Din by Din — the 0 to 40 day spine
    // =========================================================================
    PpArea(
      id: 'din_by_din',
      mark: IntentMark.stepsMark,
      title: 'Day by Day: Your 40-Day Guide',
      blurb: 'Where you are today, and what it means for you both.',
      hue: 26,
      pages: [
        PpPage(
          id: 'f40_days_1_7',
          title: 'Days 1 to 7: the first week',
          subtitle: "Getting through, not a routine. That's the right plan.",
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month'],
          blocks: [
            PpIntro('This week is meant to feel like this. Your baby is '
                "learning to feed, you're bleeding and sore, and nobody in "
                'the house has slept. None of it means something has gone '
                'wrong.'),
            PpVideoSlot(
              title: 'Your first 40 days, gently explained',
              subtitle: 'What the forty days of rest are for, what changes week by week, and the '
                  'few things worth watching.',
              minutes: '8 MIN',
              slotId: 'first40/welcome_intro',
            ),
            PpChartCard(
              title: 'What is normal in week 1',
              // REQUIRED_REVIEW: every number in this card. Feeds per 24 hours
              // (8 to 12), day-5-onward wet nappy count (6 or more), the stool
              // colour progression, and up-to-10-percent birth weight loss with
              // recovery by day 14.
              rows: [
                ('Feeds in 24 hours', '8 to 12, day and night'),
                ('Longest sleep stretch', '2 to 3 hours, if you are lucky'),
                ('Wet nappies by day 5', '6 or more, pale urine'),
                ('Poop', 'Black and sticky, then green, then yellow'),
                ('Weight', 'Drops up to 10 percent, back up by day 14'),
                ('Cord stump', 'Dries, darkens, still attached'),
              ],
              note: 'A newborn who feeds, wets nappies and can be settled is '
                  'doing well, even with a lot of crying.',
              hue: 26,
            ),
            PpCards([
              PpCard('Feed whenever your baby asks',
                  'No schedule is worth protecting this week. Offer the '
                  'breast at every stir, and wake your baby after a long '
                  'sleep.'),
              PpCard('Keep the cord dry and uncovered',
                  'Nothing on it. No oil, no turmeric, no ash, no powder.'),
              PpCard('Sponge baths only for now',
                  'A soft cloth, a warm room, and no rush. The proper bath can '
                  'wait for the cord.'),
              PpCard('Lie down more than you think you should',
                  'Your bleeding is heaviest now, and it gets worse when '
                  "you're on your feet. Rest is treatment, not laziness."),
              PpCard('Let one person guard the door',
                  'Visitors can come next week. This week is for feeding and '
                  'healing.'),
            ], heading: 'What to do this week', hue: 26),
            PpWhenLine('Fits roughly day 1 to day 7, from the day of birth.'),
            PpIndiaNote('If the house is already full of relatives, give one '
                'family member the job of saying no for you. Your mother or '
                'your husband can turn people away far more easily than you '
                'can from the bed.'),
            PpCallout("You don't need to enjoy this week. Feeding your baby, "
                'and being looked after yourself, is the whole job.'),
            PpCallout(
              "Some things in a newborn can't wait. Trouble breathing, a "
              'fever, refusing feeds, far fewer wet nappies, deepening '
              'jaundice, or a baby who is floppy or hard to wake means a '
              'doctor today. The full list is in "When to Rush to the '
              'Doctor" on the section home.',
              kind: PpCalloutKind.doctor,
              title: 'The few things that need a doctor now',
            ),
          ],
        ),
        PpPage(
          id: 'f40_days_8_15',
          title: 'Days 8 to 15: finding the feed',
          subtitle: 'Jaundice watch, massage begins, and visitors arrive.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month'],
          blocks: [
            PpIntro('The panic of the first week usually softens here. '
                'Feeding starts to work, your milk has come in properly, and '
                'the cord is nearly ready to fall off.'),
            PpChartCard(
              title: 'What is normal in week 2',
              // REQUIRED_REVIEW: cord separation window (day 5 to 15), jaundice
              // peak (day 4 to 5) and fade (day 10 to 14), wet nappy count of 6
              // or more per 24 hours.
              rows: [
                ('Cord stump', 'Falls off between day 5 and day 15'),
                ('Jaundice', 'Peaked around day 4 or 5, now fading'),
                ('Feeds in 24 hours', 'Still 8 to 12, a little more organised'),
                ('Wet nappies', '6 or more every 24 hours'),
                ('Weight', 'Climbing back towards birth weight'),
                ('Awake time', 'Short bursts, still no sense of day and night'),
              ],
              note: 'Milk that leaks, breasts that feel full, and a baby who '
                  'feeds noisily are all signs this is working.',
              hue: 26,
            ),
            PpCards([
              PpCard('Start baby massage once the cord has gone',
                  'Gentle oil massage, warm room, never straight after a feed. '
                  'The full how-to is in "Massage, Carrying and Soothing".'),
              PpCard('Watch the yellow, without panicking',
                  "Look at your baby's face in daylight. Jaundice that is "
                  'fading is ordinary. Jaundice spreading to the palms and '
                  'soles is not.'),
              PpCard('Set visiting hours out loud',
                  'One hour in the evening, hands washed, nobody unwell, '
                  "nobody kissing the baby's face."),
              PpCard('Eat and drink at every feed',
                  'Keep water and a snack beside the place you feed. Hunger '
                  'and thirst hit hardest during letdown.'),
            ], heading: 'What to do this week', hue: 26),
            PpWhenLine('Fits roughly day 8 to day 15.'),
            PpIndiaNote('This is usually when the family\'s massage helper starts coming. '
                'Watch the first massage yourself before you leave your baby '
                'alone with them. Say clearly that nothing goes in the eyes, '
                'ears, nose or mouth.'),
            PpCallout(
              'See a doctor the same day for jaundice that is getting deeper '
              'instead of lighter, or reaches the palms or the soles of the '
              'feet. The same goes for jaundice that appears for the first '
              'time after two weeks. Yellowing together with poor feeding or '
              'a very sleepy baby needs a doctor now.',
              kind: PpCalloutKind.doctor,
              title: 'Jaundice that needs checking',
            ),
          ],
        ),
        PpPage(
          id: 'f40_days_16_30',
          title: 'Days 16 to 30: the long evenings',
          subtitle: 'Cluster feeding, more alert time, and your own healing.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month'],
          blocks: [
            PpIntro('Two things usually arrive together now. Your baby is '
                'awake and looking at you more, and wants to feed on and off '
                'all evening. Both are growth, not a problem.'),
            PpChartCard(
              title: 'What is normal in weeks 3 and 4',
              // REQUIRED_REVIEW: expected weight gain of 150 to 200 grams a
              // week in the first three months, and the crying peak at about
              // week 6.
              rows: [
                ('Weight', 'Above birth weight, gaining 150 to 200 g a week'),
                ('Evening feeding', 'Long clusters, often 4 pm to 10 pm'),
                ('Awake and alert', '30 to 60 minutes at a stretch'),
                ('Crying', 'Peaks around week 6, then eases'),
                ('Your bleeding', 'Lighter, brown or pink, still there'),
              ],
              note: 'Cluster feeding in the evening is how your baby builds '
                  "your milk supply. It doesn't mean you have too little.",
              hue: 26,
            ),
            PpCards([
              PpCard('Plan for the evening instead of fighting it',
                  'Dinner cooked early, phone charged, water nearby, something '
                  'to watch. Feed, and let the evening pass.'),
              PpCard('Give your baby bright mornings',
                  'Daylight, noise and ordinary household life in the day. '
                  "Quiet and dim at night. That's how day and night sort "
                  'themselves out.'),
              PpCard('Start moving gently',
                  'Short slow walks inside the house. Nothing that pulls at '
                  'stitches or a caesarean scar.'),
              PpCard('Book the one-month check',
                  'Weight, feeding, jaundice and the next vaccines all get '
                  'looked at together.'),
            ], heading: 'What to do now', hue: 26),
            PpWhenLine('Fits roughly day 16 to day 30.'),
            PpIndiaNote('If relatives say the evening crying means your milk '
                "isn't enough and formula should start, check the nappies "
                'and the weight instead. Those two answer the question, and '
                "an argument doesn't."),
            PpLink("Your baby's weight, plotted",
                surfaceId: 'pp_growth',
                blurb: 'Add this month\'s weight and see the curve.'),
          ],
        ),
        PpPage(
          id: 'f40_days_31_40',
          title: 'Days 31 to 40: a rhythm appears',
          subtitle: 'The end of the forty days of rest, and what changes after it.',
          format: 'DAY-SPINE CARD',
          bands: ['jaapa_first_month', 'jaapa_forty'],
          blocks: [
            PpIntro('Something shifts in these ten days. You can usually '
                'tell the cries apart, you know roughly how the evenings go, '
                "and you've stopped checking quite so often that your baby "
                'is breathing.'),
            PpChartCard(
              title: 'What is normal now',
              // REQUIRED_REVIEW: 7 to 10 feeds per 24 hours at 5 to 6 weeks,
              // longest night stretch of 3 to 4 hours, and first social smile
              // at around 6 weeks.
              rows: [
                ('Feeds in 24 hours', '7 to 10, more predictable'),
                ('Longest night sleep', '3 to 4 hours, sometimes more'),
                ('Smiling', 'A first real social smile appears around now'),
                ('Your bleeding', 'Mostly stopped, or nearly'),
                ('Neck', 'Lifts the head briefly when lying on the tummy'),
              ],
              note: "If none of this has happened yet, that's still normal. "
                  'Babies reach these things weeks apart.',
              hue: 26,
            ),
            PpCards([
              PpCard("Don't rebuild the house on day 41",
                  "The forty days ending doesn't mean you're back to full strength. "
                  'Add one thing a week, not everything at once.'),
              PpCard('Keep the help you can keep',
                  'Help with cooking and cleaning matters more in month two '
                  "than month one, because that's when everyone assumes "
                  "you're fine."),
              PpCard('Get your own six-week check done',
                  'Bleeding, stitches, blood pressure, mood, and contraception '
                  'if you want it. This one is for you, not the baby.'),
              PpCard('Notice how you feel, not only how feeds are going',
                  "Low mood that hasn't lifted in two weeks deserves the "
                  'same seriousness as a fever.'),
            ], heading: 'What to do now', hue: 26),
            PpWhenLine('Fits roughly day 31 to day 40, and the weeks just '
                'after.'),
            PpIndiaNote('The 40-day mark often brings a ceremony, a first '
                'outing and a house full of people. Going out is fine now. '
                'Being handed around a room of forty guests is still a lot '
                'for your baby, and for you.'),
          ],
        ),
        PpPage(
          id: 'f40_forty_mark',
          title: 'You made it to 40 days. What now?',
          subtitle: 'What the forty days were for, and what comes next.',
          format: 'SHORT ARTICLE',
          bands: ['jaapa_forty', 'jaapa_after'],
          blocks: [
            PpIntro("Forty days isn't a medical deadline. It's the time our "
                'families worked out that a new mother needs to be fed, kept '
                'warm and left alone. They were broadly right.'),
            PpArticle([
              'What the forty days of rest protect is real. Rest while the uterus shrinks '
              'back and the bleeding stops. Warm, easy food while your '
              'appetite is strange. Fewer visitors while your baby has '
              'little immunity yet. Someone else cooking while you feed '
              'every two hours.',
              "What it doesn't do is finish your recovery. A caesarean scar "
              'takes months to stop aching. Your pelvic floor, your back and '
              'your sleep are all still mending on day 41, and nobody throws '
              'a ceremony for month four.',
              'So treat the 40-day mark as the end of the emergency, not the '
              'end of the healing. The next stretch is quieter and longer, and '
              'it has its own section in this app.',
            ]),
            PpCallout('If one thing carries forward from these forty days, let it be '
                "this. You're allowed to be looked after even when you no "
                'longer look unwell.'),
            PpLink('You, the mother: your longer recovery',
                surfaceId: 'pp_you_maa',
                blurb: 'Pelvic floor, mood, strength, going back to work, and '
                    'the parts that take months.'),
            // "His first vaccinations: point to Health's shots tool, not a
            // new page."
            PpLink("Your baby's first vaccinations, and what's due next",
                surfaceId: 'pp_vaccines',
                blurb: 'The schedule, an alarm, and a doctor-ready record.'),
            PpLink('What changes next for your baby',
                surfaceId: 'pp_what_changed',
                blurb: 'The leaps, growth spurts and sudden changes ahead.'),
          ],
        ),
        // ⚠️ [NEW], two scaffolds near the day-by-day guide. "The whole
        // section is mother-and-baby, and the one person who can protect
        // both has no page written for him." And the ceremonies: "touched in
        // one 'In an Indian home' box on the 40-day page, not owned
        // anywhere." Copy supplied, not generated.
        // FILLED 2026-10-02 alongside the parenting gap analysis, which
        // found both competitors carry a father's guide and we had only this
        // scaffold. Written to him, in his voice; the brief's three verbs
        // (guard the door, protect her rest, take a night shift) are the spine.
        PpPage(
          id: 'f40_for_husband',
          title: 'For your husband, in the first 40 days',
          subtitle: 'Guard the door, protect her rest, take a night shift',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This page is for you, the father. Your wife has just '
                'done the hardest physical work of her life. Now she feeds '
                'the baby every two or three hours, around the clock. You '
                "can't breastfeed, but you can do almost everything else, "
                'and it matters more than you think.'),
            PpSteps(heading: 'Three things that make the biggest difference', [
              PpStep('Guard the door',
                  'Visitors love to come, and new mothers are expected to '
                  'sit up and smile. You can be the one who says, "Please '
                  'come next week, she needs rest." Keep visits short, and '
                  'ask everyone to wash their hands before holding the baby.'),
              PpStep('Protect her sleep',
                  'After a feed, take the baby: burp, change and settle, so '
                  'your wife can go straight back to sleep. One block of '
                  "four hours' sleep helps her body heal."),
              PpStep('Take a night shift',
                  "Even one or two nights a week. If she's breastfeeding, "
                  'bring the baby to her for the feed, then take over '
                  'everything after.'),
            ]),
            PpCards(heading: 'Small things that stay with her', [
              PpCard('Bring water and food',
                  'Every time she sits down to feed. Feeding makes a new '
                  'mother very thirsty and hungry.'),
              PpCard('Learn the baby',
                  "Bathing, nappies, swaddling, burping. You'll get good at "
                  'it fast, and your baby will know you.'),
              PpCard('Stand with your wife', 'If elders give advice that worries '
                  "her, back her choices, and the doctor's, calmly."),
              PpCard('Ask how your wife is', 'Ask about her as well as the baby. '
                  'Then listen.'),
              PpCard('Hold your baby skin to skin',
                  'Shirt off, baby in just a nappy, on your chest, a blanket '
                  'over you both. It calms your baby and helps you bond.'),
            ]),
            PpCallout("Watch for signs she isn't okay. Crying most days, not "
                'sleeping even when the baby sleeps, constant worry or '
                "panic. Or saying she can't cope, or that the baby would be "
                'better off without her. These are common and treatable. '
                'Help her call her doctor, and go with her.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('Paternity leave in India is short or missing for '
                'most fathers. If you can take even a week off, or work from '
                'home in the first fortnight, take it. Ask your HR; many '
                'companies now offer it.'),
            // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpTable(
              heading: 'A simple night-shift plan',
              columns: ['Time', 'Who'],
              rows: [
                ['9 pm to 2 am', 'Papa takes the baby, brings the baby to '
                    'Mummy only to feed, then settles the baby again.'],
                ['2 am to 7 am', 'Mummy feeds and settles; Papa sleeps.'],
              ],
            ),
            PpWhenLine('If your wife is pumping or the baby takes a bottle, '
                'she can have the first shift fully off. Swap shifts at '
                'weekends.'),
            PpCards(heading: 'Newborn safety, for fathers', [
              PpCard('Know the danger signs', 'Fever, poor feeding, fast '
                  'breathing, yellow skin spreading to the tummy, or a floppy, '
                  'very sleepy baby: go to the doctor.'),
              PpCard('Never shake a baby', 'If the crying gets too much, put '
                  'your baby down safely in the cot and step out for a few '
                  'minutes.'),
              PpCard('Support the head', 'Always, until your baby can hold '
                  'it up alone.'),
              PpCard('Learn CPR and choking first aid', 'Before you need it.'),
            ]),
          ],
        ),
        // FILLED 2026-10-02 from the parenting gap analysis (P1, ADD TO
        // OURS: What to Expect's "keeping newborns safe from germs"). The
        // germ advice is folded into our ceremonies page, as the analysis
        // said, rather than standing alone: in an Indian home, the crowd at
        // the chhati IS the germ question.
        PpPage(
          id: 'f40_ceremonies',
          title: 'The ceremonies, and keeping your baby safe through them',
          subtitle: 'The sixth-day ceremony, the naming, the first outing: crowds, kisses, and when it is safe',
          format: 'ARTICLE',
          blocks: [
            PpIntro('The sixth-day ceremony (chhati), the naming ceremony (naamkaran), the first visit to the '
                "temple: these are joyful days, and you don't need to miss "
                "them. A newborn's defences against infection are still "
                'building in the first weeks. A few gentle rules let '
                'everyone celebrate while your baby stays well.'),
            PpArticle(heading: 'Why the first weeks need care', [
              'A newborn gets some protection from you through pregnancy and '
                  "breast milk, but the baby's own immune system is still "
                  'learning. A mild cold in an adult can make a baby under '
                  'three months properly unwell. A fever at this age always '
                  'needs a doctor.',
              'The good news: most infections reach a baby through hands and '
                  'faces, which makes them easy to block.',
            ]),
            PpSteps(heading: 'The gentle rules', [
              PpStep('Everyone washes their hands before holding the baby',
                  "Keep soap or sanitiser by the door. It isn't rude; it's "
                  'love.'),
              PpStep("No kissing the baby's face or hands",
                  'Kisses on the feet or the top of the head are fine. Cold '
                  'sores in an adult can be very dangerous to a newborn.'),
              PpStep('Anyone with a cold, cough or fever waits',
                  "They can meet the baby once they're well. Children with "
                  'runny noses too.'),
              PpStep('Keep the crowd around your baby small',
                  'At a function, let your baby rest in a quieter room, and '
                  'pass the baby round less.'),
              PpStep('Keep feeds clean',
                  'Wash bottles and pump parts well. Use expressed milk within '
                  'its safe time, and throw away any milk left in a bottle '
                  'after a feed.'),
            ]),
            PpWhenLine('A short outing to a calm place, like a walk or a '
                'family home, is fine from the first weeks. Crowded places '
                'such as markets, malls and big gatherings are better after '
                'the first vaccines at six weeks.'),
            PpCallout('Any fever of 38 C (100.4 F) or more in a baby under '
                'three months needs a doctor the same day, even if your baby '
                'seems well. Also call if your baby is feeding poorly, '
                'unusually sleepy, or breathing fast.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('If an elder insists on kohl, a kiss or passing the '
                'baby round, a kind line works: "The doctor asked us to be '
                'careful until the first vaccines. You can hold the baby as '
                'soon as you\'ve washed your hands." Most families are happy '
                'to help once they know why.'),
            // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpScript(heading: 'A script for visitors', [
              PpScriptLine(
                  say: "We're so happy you came. Please wash your hands "
                      'before you hold the baby; the doctor asked us to be '
                      'careful until the vaccines.',
                  why: 'It puts the rule on the doctor, not on you.'),
              PpScriptLine(
                  say: "Could you come next week instead? We'd love to see "
                      'you when your cold is better.',
                  notThis: 'You are sick, stay away.',
                  why: 'Kind, and still a clear no.'),
            ]),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  2. When to Rush to the Doctor — THE SAFETY CORE
    // -------------------------------------------------------------------------
    //  ⚠️ SECOND AREA, DELIBERATELY. High enough to find at 2am, not first,
    //  because opening a section for frightened new parents with a list of
    //  emergencies is the anxiety this product is written against.
    //
    //  ⚠️ NO COMMERCE ON EITHER PAGE. No PpConsult, no product link, no course.
    //  The only outward links are free: the expert door with no price attached,
    //  and the help finder.
    // =========================================================================
    PpArea(
      id: 'rush_to_doctor',
      mark: IntentMark.chartLog,
      title: 'When to Rush to the Doctor',
      blurb: "The short list that can't wait until morning. Read it once "
          "now, so you're not reading it for the first time in a panic.",
      hue: 12,
      pages: [
        PpPage(
          id: 'f40_red_flags',
          title: 'When to rush to the doctor',
          subtitle: 'Newborn danger signs, and what to do about each one.',
          format: 'FLAGGED QUICK-REFERENCE',
          blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The signs that mean go now',
          subtitle: 'A paediatrician says them out loud, slowly, in the '
              "order you'd notice them.",
          minutes: '6 MIN',
          slotId: 'first40/red_flags',
        ),
            PpIntro("Almost everything a newborn does is normal. That's why "
                "the short list of things that aren't gets its own page. "
                "Read it once while you're calm."),
            PpCallout(
              "If you're here because something feels badly wrong right now, "
              'stop reading. Go to the nearest hospital with a paediatric or '
              'newborn unit. A newborn seen too early is sent home. A '
              'newborn seen too late can be in real danger.',
              kind: PpCalloutKind.doctor,
              title: 'If you are frightened right now',
            ),
            PpTable(
              heading: 'Go now, or call now',
              columns: ['If you see this', 'What to do'],
              rows: [
                [
                  'Struggling to breathe: fast breathing, grunting with '
                  'every breath, nostrils flaring, ribs pulling in, or '
                  'breathing stops',
                  'Go now. Nearest hospital with a newborn unit.',
                ],
                [
                  'Blue or dusky lips, tongue or face',
                  'Go now.',
                ],
                [
                  "Fever, or a body that feels cold and won't warm up",
                  'Go now. A temperature in a baby under 3 months is always '
                  'treated as urgent.',
                ],
                [
                  'Refusing feeds, or too sleepy to feed for two feeds in a row',
                  'Call now, and be ready to go in.',
                ],
                [
                  'Far fewer wet nappies than usual, or a dry nappy for many '
                  'hours',
                  'Call now. This is the earliest sign of dehydration.',
                ],
                [
                  'Yellow deepening, or reaching the palms and the soles of '
                  'the feet',
                  'Same day. Ask for a bilirubin check.',
                ],
                [
                  'Floppy, limp, or very hard to wake',
                  'Go now.',
                ],
                [
                  'A fit: jerking, stiffening, staring and unresponsive, or lip '
                  'smacking',
                  'Go now.',
                ],
                [
                  'Vomiting every feed, forceful vomiting, or vomit that is '
                  'green or yellow-green',
                  'Go now.',
                ],
                [
                  'Blood in the stool, black stool after the first few days, or '
                  'a swollen hard tummy',
                  'Go now.',
                ],
                [
                  'Cord area red and spreading onto the belly, oozing pus, or '
                  'smelling bad',
                  'Same day.',
                ],
                [
                  'A cry that is different: shrill, weak, or inconsolable for '
                  'hours with nothing helping',
                  'Call now.',
                ],
              ],
            ),
            PpChartCard(
              title: "The numbers, if you've been asked for them",
              subtitle: 'Useful on the phone to a doctor.',
              // REQUIRED_REVIEW: EVERY ROW IN THIS CARD IS A CLINICAL THRESHOLD
              // AND MUST BE CONFIRMED BY A PAEDIATRICIAN BEFORE RELEASE.
              //   * Fever: 100.4 F / 38.0 C, treated as an emergency under 3
              //     months. Confirm the measurement site we state (we do not
              //     name one here on purpose) and whether an axillary figure
              //     should be lower.
              //   * Too cold: below 97.5 F / 36.5 C.
              //   * Breathing too fast: more than 60 breaths a minute at rest,
              //     counted for a full minute while settled.
              //   * Breathing pause: longer than 15 to 20 seconds, or any pause
              //     with a colour change.
              //   * Wet nappies: fewer than 6 in 24 hours from day 5 onward.
              //   * Weight: more than 10 percent below birth weight.
              rows: [
                ('Fever', '100.4 F or 38 C and above'),
                ('Too cold', 'Below 97.5 F or 36.5 C'),
                ('Breathing too fast', 'More than 60 breaths a minute at rest'),
                ('Breathing pause', 'Longer than 15 to 20 seconds'),
                ('Wet nappies, day 5 onward', 'Fewer than 6 in 24 hours'),
                ('Weight', 'More than 10 percent below birth weight'),
              ],
              note: "You don't need a number to be allowed to worry. If your "
                  "baby looks wrong to you, that's reason enough to be seen.",
              hue: 12,
            ),
            PpSteps([
              PpStep("Say your baby's age in days first",
                  'A newborn is a different patient at day 3 and day 30, and '
                  'the age changes what happens next.'),
              PpStep('Say the one thing that frightened you',
                  'Not the whole history. "No feed since morning, and the '
                  'nappy is dry" is the useful sentence.'),
              PpStep('Say the temperature if you have it',
                  'And say how you took it.'),
              PpStep('Ask directly whether to come in',
                  '"Should I bring the baby now, or in the morning?" is a '
                  "fair question, and you're allowed to ask it."),
            ], heading: 'What to say when you call'),
            PpWhenLine('Applies from birth through the whole newborn period. '
                'Under 3 months, everything on this list is treated as more '
                'urgent than it would be later.'),
            PpIndiaNote('Do two things today, while nothing is wrong. Save '
                'the nearest 24-hour paediatric hospital number in your '
                'phone. Find out which chemist near you stays open at night. '
                'At 2am, knowing where to go is most of the problem solved.'),
            PpCallout(
              "Nothing on this page is a diagnosis, and an app can't settle "
              "any of it. It's a list of moments to hand over to a doctor.",
            ),
            // ⚠️ FREE LINK, NOT A SELL. See the area note above.
            PpLink("Not an emergency, but you're not sure",
                surfaceId: 'pp_experts',
                blurb: 'Talk to a newborn nurse or a lactation expert instead '
                    'of guessing at 2am.'),
            PpLink('Find help near you',
                surfaceId: 'pp_find_help',
                blurb: 'Paediatricians, lactation support and night help.'),
          ],
        ),
        PpPage(
          id: 'f40_crying_never_shake',
          title: "When the crying won't stop",
          subtitle: 'What to do for your baby, and what to do for yourself.',
          // ⚠️ [reformat: step-list > interactive] AND ONE SCREEN, NOT TWO.
          // "Same crisis content as Behaviour's 'When the crying is too
          // much', make it one screen both point to." Behaviour's is the
          // dark one-step-at-a-time story (never-shake screen included);
          // this card opens it directly. The copy that lived here is kept
          // below for revert; the never-shake and get-help blocks live on
          // in that story, spoken to her.
          // format: 'STEP-LIST',
          format: 'INTERACTIVE',
          toolSurfaceId: 'pp_page/parenting_behaviour/crying_too_much',
          blocks: [],
        ),
        /* kept for revert: the step-list the shared crisis screen replaced
        PpPage(
          id: 'f40_crying_never_shake_copy',
          title: "When the crying won't stop",
          format: 'STEP-LIST',
          blocks: [
            PpIntro("There will be an evening when you've tried everything, "
                'your baby is still screaming, and you feel something you '
                "didn't expect to feel. That happens to almost every parent, "
                "and it doesn't mean anything is wrong with you."),
            PpArticle([
              'Newborn crying climbs from birth, peaks somewhere around week '
              '6, then eases. Some of it has no cause you can find and no '
              "fix you can apply. That's how newborns are, and it's the "
              'hardest fact of the first two months to accept.',
              "The dangerous moment isn't the crying. It's exhaustion plus "
              'the feeling that you must make it stop. So the plan below '
              'keeps both of you safe, in that order.',
            ]),
            PpSteps([
              PpStep('Check the fixable things once',
                  'Hungry, wet, too warm, too cold, wind, or wanting to be '
                  'held. Once through the list, not five times.'),
              PpStep('Try the calming sequence',
                  'Swaddle, hold your baby on the side against you, shush '
                  'close to the ear, sway. Give each one a full minute '
                  'before changing.'),
              PpStep('If you feel your temper rising, lay your baby down',
                  'Flat on the back in the cot or on a firm bed. A crying '
                  'baby in a safe place is completely fine.'),
              PpStep('Walk out of the room for five minutes',
                  'Drink water. Sit down. Let yourself cry. Set a timer if it '
                  'helps you come back.'),
              PpStep('Call someone in',
                  'Your husband, your mother, your sister, a neighbour. '
                  "Handing your baby over for twenty minutes isn't failure; "
                  "it's the right move."),
              PpStep('Go back to your baby',
                  "Your baby won't remember the five minutes, and will be "
                  'picked up again by calmer arms.'),
            ], heading: 'The plan, in order'),
            PpCallout(
              'Never shake a baby, and never let anyone else. A newborn neck '
              "can't hold the head steady, and shaking causes bleeding and "
              'injury inside the brain that no apology undoes. A baby should '
              'also never be thrown in the air, jerked to stop hiccups, or '
              'rocked hard to force sleep. If your baby has been shaken even '
              'once, go to a hospital today and say exactly what happened. A '
              'shaken baby can look completely fine and still need checking.',
              kind: PpCalloutKind.doctor,
              title: 'Never shake a baby',
            ),
            PpCallout(
              'A cry that sounds really different needs a doctor, not more '
              'soothing. Shrill or high pitched, weak and whimpering, '
              'inconsolable for hours with nothing helping, or crying '
              'alongside a fever, vomiting, a swollen tummy or refusing '
              'feeds.',
              kind: PpCalloutKind.doctor,
              title: 'Crying that needs a doctor',
            ),
            PpIndiaNote('In a joint family the crying is often treated as a '
                'verdict on you: your milk, your handling, your nerves. It '
                "isn't. Say out loud that you need twenty minutes and "
                'someone else needs to hold the baby. A full house only '
                'helps if you use it.'),
            PpWhenLine('Crying peaks around 6 weeks and eases from around 3 to '
                '4 months.'),
            PpLink("If the hard feelings aren't lifting",
                surfaceId: 'pp_you_maa',
                blurb: 'Low mood, rage, numbness and frightening thoughts, '
                    'and what helps.'),
          ],
        ),
        */
      ],
    ),

    // =========================================================================
    //  3. Samjho Your Newborn — the article library
    // -------------------------------------------------------------------------
    //  Every page follows the spec's fixed skeleton: what it is, what to do,
    //  what to watch (flagged where it matters), and which day range it fits.
    // =========================================================================
    PpArea(
      id: 'samjho',
      mark: IntentMark.listMark,
      title: 'Understanding Your Newborn',
      blurb: 'Every strange thing newborns do, and whether it means '
          'anything.',
      hue: 44,
      pages: [
        PpPage(
          id: 'f40_cord_care',
          title: 'Looking after the cord stump',
          subtitle: 'Dry, uncovered, and nothing on it.',
          format: 'STEP-LIST',
          blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'Cord care, without the fear',
          subtitle: 'What to do, what to leave alone, and what a normal cord looks like on day four.',
          minutes: '4 MIN',
          slotId: 'first40/cord_care',
        ),
            PpIntro('The cord stump looks alarming and needs almost nothing '
                'from you. Keeping it dry and open to the air is the whole '
                'treatment. It works better than anything you could put on '
                'it.'),
            PpSteps([
              PpStep('Leave it uncovered',
                  'Air dries it faster than any dressing. No bandage, no '
                  'binder, no cotton pad, no belt.'),
              PpStep('Fold the nappy below it',
                  'Or use a nappy with a dip cut out at the front, so urine '
                  'never soaks the stump.'),
              PpStep('Wash your hands before touching it',
                  'Clean hands help the cord more than anything else in the '
                  'house can.'),
              PpStep('Clean only if it gets dirty',
                  'Plain water on clean cotton, then let it air dry. Not soap, '
                  'not antiseptic, unless your doctor asked for one.'),
              PpStep('Sponge bath until it falls off',
                  'Wash your baby in parts on a towel. No tub baths yet.'),
              PpStep('Let it fall off on its own',
                  'Usually between day 5 and day 15. Never pull it, even if '
                  "it's hanging by a thread."),
            ], heading: 'How to care for it'),
            // REQUIRED_REVIEW: cord separation window of day 5 to 15, and
            // whether we should name chlorhexidine or dry cord care as the
            // default for Indian home births specifically.
            PpWhenLine('From birth until it separates, usually day 5 to day '
                '15. A little dampness or a few drops of blood as it comes '
                'away is normal.'),
            PpCallout(
              'Nothing goes on the cord. Not turmeric, not oil, not ash, '
              'not cow dung, not powder, not kohl, not a coin, not a '
              "binder. This isn't a small superstition to go along with. "
              'These things cause cord infection and tetanus, and tetanus in '
              'a newborn kills. Dry and uncovered is the medical advice '
              'today for a reason.',
              kind: PpCalloutKind.myth,
              title: 'The one hard rule',
            ),
            PpCallout(
              'See a doctor the same day if the skin around the cord is red '
              'and the redness is spreading onto the belly. The same goes '
              'for pus or a foul smell, or bleeding of more than a few '
              'spots. Go too if the belly is swollen and tender, or your '
              'baby has a fever or has gone off feeds.',
              kind: PpCalloutKind.doctor,
              title: 'Cord signs that need a doctor',
            ),
            PpIndiaNote('If an older relative or the traditional midwife (dai) wants to apply '
                'something, offer the swap rather than the argument. "The '
                'doctor said dry only, and it falls off faster this way" '
                'ends the talk more often than a lecture does.'),
          ],
        ),
        PpPage(
          id: 'f40_first_bath',
          title: "Your baby's first bath, and when to start",
          subtitle: 'Later than you think, and shorter than you think.',
          // [reformat: add a film] "Bathing a slippery newborn is a scary
          // physical skill and there is no film here today; keep the
          // step-list under it."
          // format: 'STEP-LIST',
          format: 'VIDEO',
          blocks: [
            PpVideoSlot(
              title: 'The first bath, shown',
              subtitle: 'The hold, the water, the five minutes, and getting '
                  'your baby dry and warm again.',
              minutes: '5 MIN',
              slotId: 'first40/first_bath',
              hue: 26,
            ),
            PpIntro("There's no rush to bathe a newborn. The white coating "
                'at birth protects the skin. Waiting a day or two is better '
                "for your baby's temperature, blood sugar and first feeds."),
            PpArticle([
              'For the first days, a top-to-toe sponge wash on a towel is '
              'enough: face, neck folds, hands, nappy area. Two or three '
              'baths a week is plenty for a newborn, and daily is fine in '
              'hot weather if your baby enjoys it.',
              'Once the cord has fallen off and healed, you can move to a '
              'small tub. Warm the room first, lay everything out within '
              'reach, and keep the whole bath to about five minutes.',
            ]),
            PpSteps([
              PpStep('Warm the room, close the windows',
                  "Bathe your baby where there's no draught. Warmth matters "
                  'more than water depth.'),
              PpStep('Lay everything out first',
                  "Towel, clean clothes, nappy, mug, and the oil if you're "
                  'doing a massage. Never leave your baby to fetch something.'),
              PpStep('Test the water on your elbow',
                  'It should feel pleasantly warm, not hot. Fill the tub '
                  'before your baby goes in, and check again.'),
              PpStep('Wash the face and head first',
                  'Plain water on the face. A little baby soap or wash on the '
                  'scalp, and not every day.'),
              PpStep('Support the head and neck the whole time',
                  'One forearm under the back, your hand holding the far '
                  'shoulder. The head never goes under.'),
              PpStep('Get into the folds',
                  'Neck, armpits, groin and behind the knees hold milk and '
                  "sweat, and that's where rashes start."),
              PpStep('Out, wrapped, dried in the folds, dressed',
                  'Pat dry rather than rubbing hard. Then feed, because your '
                  'baby will be hungry.'),
            ], heading: 'The bath, step by step'),
            // REQUIRED_REVIEW: (a) delaying the first bath by at least 24 hours
            // after birth, (b) bath water at about 37 to 38 C, (c) 2 to 3 baths
            // a week as the newborn norm.
            PpWhenLine('First bath after the first 24 hours, sponge washes '
                'until the cord falls off, tub baths after that. Two or three '
                'a week is enough, more in hot weather.'),
            PpCallout('Never leave your baby alone in water for a second. '
                'Not even in an inch of it, not even with an older child '
                'watching. Answer the door later.'),
            PpIndiaNote("Many families don't bathe the baby for the first "
                'few days, and that custom matches the medical advice. '
                "What's worth changing is the rough head-down "
                'massage-and-bath routine some massage helpers use. The same '
                'goes for pouring water over the face to "make the baby '
                'strong". Gentle is not weak.'),
            PpCallout(
              'Skip the bath and speak to your doctor if your baby is '
              'unwell, feeding poorly, or was born early or small. Cold '
              'stress in a small baby is a real risk, and a wash on a towel '
              'is always the safer option.',
              kind: PpCalloutKind.doctor,
              title: 'When not to bathe your baby',
            ),
          ],
        ),
        PpPage(
          id: 'f40_nappy_poop',
          title: 'Nappies, and what newborn poop should look like',
          subtitle: 'The two counts that tell you your baby is fine.',
          // [reformat: chart + illustration] "add a colour strip of what
          // each looks like. Parents are matching a nappy to a picture."
          format: 'CHART-CARD',
          blocks: [
            PpIntro('Newborn poop changes colour a lot in the first week, '
                'and almost all of it is normal. Nappies are also the '
                'cheapest reassurance you have: enough wet ones means enough '
                'milk.'),
            PpIllustration(
              kind: PpIllustrationKind.poopColours,
              title: 'The colours, in order',
              labels: [
                PpIllustrationLabel('Black and tar-like', 'Meconium, the first two days.'),
                PpIllustrationLabel('Dark green', 'The changeover, days 3 to 4.'),
                PpIllustrationLabel('Mustard yellow with seeds', 'The classic breastfed poop.'),
                PpIllustrationLabel('Tan or brown, firmer', 'Usual on formula.'),
                PpIllustrationLabel('A little dark green sometimes', 'Common and harmless.'),
                PpIllustrationLabel('A pink or orange stain', 'Concentrated urine, or a small hormonal bleed in a girl. Mention it.'),
              ],
              caption: 'Match the nappy to the strip. Chalky white, red, or black after day three are the ones to show a doctor.',
            ),
            PpChartCard(
              title: 'What to expect, day by day',
              // REQUIRED_REVIEW: the whole nappy-count and stool-progression
              // table. Wet nappies rising to 6 or more from day 5, stools of at
              // least 3 to 4 a day from day 4 to about week 6, meconium
              // clearing by day 3 to 4.
              rows: [
                ('Day 1', '1 wet nappy, black sticky meconium'),
                ('Day 2', '2 wet nappies, still black'),
                ('Day 3', '3 wet nappies, turning greenish'),
                ('Day 4', '4 or more wet, yellow starting'),
                ('Day 5 onward', '6 or more wet, pale urine'),
                ('Stools, after day 4', '3 or more a day, yellow and seedy'),
              ],
              note: 'After about 6 weeks, a breastfed baby can go days '
                  'without a stool and still be perfectly well, as long as '
                  "it's soft when it comes.",
              hue: 44,
            ),
            PpCards([
              PpCard('Black and tar-like, first 2 days',
                  'Meconium. Sticky and hard to wipe. Completely normal.'),
              PpCard('Dark green, days 3 to 4',
                  'The changeover. Milk is getting through.'),
              PpCard('Mustard yellow with seeds',
                  "The classic breastfed poop. Loose is normal; it isn't "
                  'diarrhoea.'),
              PpCard('Tan or brown, firmer',
                  'Usual on formula. Also normal.'),
              PpCard('A little dark green sometimes',
                  'Common and harmless in the early weeks.'),
              PpCard('A pink or orange stain in a girl\'s nappy',
                  'Often just concentrated urine, or a small hormonal bleed '
                  "in the first week. Mention it to your doctor; it's rarely "
                  'a worry.'),
            ], heading: 'The colours, and what they mean', hue: 44),
            PpSteps([
              PpStep('Change at every feed, and whenever the nappy is dirty',
                  'A newborn left without a nappy for a couple of minutes is '
                  'good for the skin.'),
              PpStep('Clean front to back, especially for a girl',
                  'Plain water and cotton, or a fragrance-free wipe.'),
              PpStep('Dry properly before the new nappy',
                  'Trapped damp is what causes most nappy rash.'),
              PpStep('Use a thin barrier if the skin is red',
                  'A plain zinc or petroleum jelly layer. Not talcum powder, '
                  'which babies can breathe in.'),
            ], heading: 'Changing your baby'),
            PpWhenLine('This pattern holds through the first 6 weeks. Colours '
                'settle after that.'),
            PpCallout(
              'See a doctor for any of these. No wet nappy for many hours, '
              'or a sudden drop in wet nappies. Blood in the stool, or stool '
              'that is white, chalky or pale grey. Black stool after the '
              'first few days. Watery stools with a fever or a floppy baby. '
              'No stool at all in the first 48 hours of life.',
              kind: PpCalloutKind.doctor,
              title: 'Nappy signs that need a doctor',
            ),
            PpIndiaNote('Cloth nappies (langots) are perfectly fine and often kinder '
                "in the heat. They need changing sooner, because you can't "
                'tell how wet they are. With cloth, count wet nappies by '
                'weight and feel rather than by look.'),
            // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpSteps(heading: 'Washing cloth nappies', [
              PpStep('Rinse off poo into the toilet', 'Breastfed poo washes out '
                  'easily.'),
              PpStep('Store in a dry, lidded bucket', 'No need to soak.'),
              PpStep('Wash every two or three days', 'A rinse, then a hot wash '
                  'with a mild detergent; no fabric softener.'),
              PpStep('Dry in the sun', 'It also fades stains.'),
            ]),
            // Added 2026-10-02 from the parenting gap analysis (daily tips).
            PpCards(heading: 'Easier nappy changes', [
              PpCard('Keep supplies in two or three places',
                  'One by the bed, one in the living room. No walking across '
                      'the house with a dirty baby.'),
              PpCard('For a wriggler', 'Give your baby a toy to hold, sing, '
                  'or hang something to look at above the changing spot.'),
              PpCard('Everything ready first', 'Clean nappy open underneath '
                  'before you take the old one off.'),
              PpCard("You're learning too", 'Every parent fumbles at first. '
                  'Within a couple of weeks this becomes second nature.'),
            ]),
          ],
        ),
        PpPage(
          id: 'f40_swaddle',
          title: 'Swaddling, and how tight is right',
          subtitle: 'Snug at the arms, loose at the hips.',
          // [reformat: step-list > video-first] [reference] Sleep's swaddling
          // film, the same slot id; "do not shoot a second".
          // format: 'STEP-LIST',
          format: 'VIDEO',
          blocks: [
            PpVideoSlot(
              // The shared film's own title; one slot id, one title.
              title: 'The hip-safe swaddle, and the day to stop',
              subtitle: 'Snug at the arms, loose at the hips, and when to stop.',
              minutes: '3 MIN',
              slotId: 'sleep/swaddle_demo',
              hue: 26,
            ),
            PpIntro('A swaddle works because it stops the startle reflex '
                "from waking your baby. It's one of the most useful tricks "
                'of the first weeks, and it has two rules that matter.'),
            PpSteps([
              PpStep('Lay a thin square cloth as a diamond, top corner folded '
                  'down', 'Cotton or muslin. Thin, not a blanket.'),
              PpStep('Lay your baby on it, shoulders on the fold',
                  'Head clear of the cloth, always.'),
              PpStep('Bring one side across the chest and tuck it underneath',
                  'Arms down and snug against the body, or up beside the '
                  'face if your baby prefers that.'),
              PpStep('Fold the bottom up, loosely',
                  'This is the hip rule. The legs must be able to bend up '
                  'and out and kick freely.'),
              PpStep('Bring the other side across and tuck it in',
                  'A flat hand should slide easily between the cloth and the '
                  'chest.'),
              PpStep('Always lay your baby down on the back',
                  'A swaddled baby must never be placed on the front or '
                  'side.'),
            ], heading: 'How to swaddle'),
            PpCallout(
              'Two hard rules. Snug around the chest and arms is fine; tight '
              "around the hips isn't, because it can harm how the hip joint "
              'forms. And a swaddled baby always sleeps on the back, never '
              'on the front or side.',
              kind: PpCalloutKind.key,
            ),
            // REQUIRED_REVIEW: stop swaddling at the first signs of rolling,
            // usually 8 to 12 weeks. Confirm the age we state.
            PpWhenLine('Useful from birth. Stop swaddling at the first sign '
                'of rolling or pushing up onto one side, usually around 8 to '
                '12 weeks.'),
            PpCards([
              PpCard('Not over the face',
                  'Nothing loose near the head. No dupatta, no towel, no '
                  'pillow.'),
              PpCard('Not with a drawstring or tight binder',
                  'Binding the belly or chest with cord or cloth restricts '
                  "breathing and does nothing for the baby's shape."),
              PpCard('Not in layers',
                  'One thin swaddle instead of a swaddle plus a blanket plus a '
                  'sweater. Overheating is the real risk.'),
              PpCard('Not straightening the legs',
                  'Pulling the legs straight and wrapping them tight is the '
                  'practice that harms hips. Bent and free is correct.'),
            ], heading: 'What not to do', hue: 44),
            PpIndiaNote('The old cloth wrap and the modern velcro swaddle '
                'bag both work. In summer, one thin cotton layer with the '
                "arms out is often all a baby can bear, and that's fine. A "
                'sweaty, flushed, hot-necked baby is over-wrapped, whatever '
                'the elders say about catching cold.'),
          ],
        ),
        PpPage(
          id: 'f40_warm_enough',
          title: 'Is your baby too hot, or too cold?',
          subtitle: 'Dressing a newborn for real Indian weather.',
          format: 'CHART-CARD',
          blocks: [
            PpIntro("Newborns can't control their temperature well, so they "
                'do need help. In most Indian homes the mistake goes one '
                'way, though: far too many layers, because everyone fears a '
                'cold baby.'),
            PpChartCard(
              title: 'What to dress your baby in',
              // REQUIRED_REVIEW: room temperature of 26 to 28 C, the "one layer
              // more than an adult" rule, and both temperature figures quoted
              // in the doctor callout below.
              rows: [
                ('The rule', "One layer more than you're comfortable in"),
                ('Room, ideally', '26 to 28 C'),
                ('Summer, no AC', "A thin cotton vest and nappy. That's all"),
                ('In AC', 'Full sleeve cotton, socks, a thin sheet'),
                ('Winter, north India', 'Vest, full sleeves, socks, cap, one '
                    'blanket'),
                ('Monsoon', 'Cotton layers you can change often, dry skin '
                    'folds'),
              ],
              note: 'Check the back of the neck or the tummy, not the hands. '
                  'Cold hands and feet are normal in a warm baby.',
              hue: 44,
            ),
            PpCards([
              PpCard('Too warm looks like this',
                  'Sweaty neck and back, flushed face, damp hair, restless or '
                  'unusually sleepy, a heat rash on the neck and chest.'),
              PpCard('Too cold looks like this',
                  'A cool back or tummy, a pale or mottled body, unusually '
                  'quiet and hard to wake, not interested in feeding.'),
              PpCard('A cap indoors is rarely needed',
                  'Babies lose heat through the head, and that also helps '
                  'them cool down. A cap for outings and cold nights, not '
                  'all day.'),
              PpCard('Never a heater or coal stove in a closed room',
                  'Coal and kerosene in an unventilated room can kill. Room '
                  'heaters must be kept away from the cot and never left on '
                  'with the door and windows shut.'),
            ], heading: "Reading your baby's warmth", hue: 44),
            PpWhenLine('Applies through the whole newborn period, and matters '
                'most in the first two weeks.'),
            PpCallout(
              'A temperature in a baby under 3 months is urgent either way. '
              '100.4 F or 38 C and above, or below 97.5 F or 36.5 C after '
              "warming, needs a doctor the same day. Don't give paracetamol "
              'or any fever medicine to a newborn unless a doctor has told '
              'you the dose.',
              kind: PpCalloutKind.doctor,
              title: 'Fever, and being too cold',
            ),
            PpIndiaNote('If the family insists on a sweater in May, try a '
                'thin cotton full-sleeve top. It looks like a layer, it '
                "won't overheat your baby, and it ends the argument."),
            // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpSteps(heading: 'In winter and on cold outings', [
              PpStep('One more layer than you are wearing', 'And a cap and '
                  'socks.'),
              PpStep('Layers, not one thick blanket', 'Easy to take off '
                  'indoors.'),
              PpStep('No heavy quilts in the cot', 'A sleeping bag or a light '
                  'blanket tucked at chest level.'),
              PpStep('Never a heater or coal stove in a closed room',
                  'They use up oxygen and give off a gas that can kill.'),
              PpStep('Check the chest or back of the neck', 'Not the hands, '
                  'which are often cool.'),
            ]),
          ],
        ),
        PpPage(
          id: 'f40_newborn_skin',
          title: "Your baby's skin looks strange. Is that normal?",
          subtitle: 'Peeling, spots, patches and blotches.',
          // ⚠️ [reformat: cards > illustrated carousel]. "Skin is a
          // see-it-to-know-it thing": one slide per finding, the doctor
          // line and the India note as the last two. The page is its one
          // block, so the card opens the slides directly. The photographs
          // are owed (docs/DOOR-CONTENT-OWED.md); the cards are kept below
          // for revert.
          // format: 'CARDS',
          format: 'CAROUSEL',
          blocks: [
            PpCarousel(
              hue: 44,
              coverTitle: "Your baby's skin looks strange. Is that normal?",
              coverBlurb: 'Eight things newborn skin does in the first weeks, '
                  'and nearly all of it clears on its own.',
              cards: [
                PpCarouselCard('Peeling and flaking',
                    'Especially hands, feet and ankles, in the first two weeks. Normal. A plain moisturiser if it looks dry, nothing more.'),
                PpCarouselCard('Tiny white pinhead spots on the nose and cheeks',
                    'Milia, blocked oil glands. They clear by themselves in '
                    "a few weeks. Don't squeeze them."),
                PpCarouselCard('Blotchy red patches with a small pale centre',
                    'A common newborn rash of the first week. Comes and goes across the body and needs nothing.'),
                PpCarouselCard('Small pimples on the face at 3 to 4 weeks',
                    'Newborn acne, driven by hormones. Wash with plain water and wait. No creams.'),
                PpCarouselCard('Slate grey or bluish patches on the back and buttocks',
                    'Common in Indian babies. Harmless birthmarks that fade over years.'),
                PpCarouselCard('A flat pink patch on the eyelids, forehead or nape',
                    'A stork mark. It reddens with crying and usually fades.'),
                PpCarouselCard('Yellow greasy scales on the scalp',
                    'Cradle cap. Soften with a little oil an hour before a bath, then wash gently. Never pick it off.'),
                PpCarouselCard('Prickly red bumps in the neck folds',
                    'Heat rash. Fewer layers, a cooler room, and keep the folds dry.'),
                PpCarouselCard('A sticky or watery eye',
                    'A blocked tear duct is common and usually clears by '
                    'itself; wipe from the nose outwards with cooled boiled '
                    'water. Yellow-green discharge, redness or a swollen '
                    'lid: show a doctor.'),
                PpCarouselCard('Skin that needs a doctor',
                    'Blisters, or spots filled with pus or fluid. A rash '
                    'with a fever, or with poor feeding. Small dark red or '
                    "purple spots that don't fade when you press them. "
                    'Yellow, weeping or spreading patches. A rash all over '
                    'the body that came up very quickly.'),
                PpCarouselCard('In an Indian home',
                    'Gram flour and milk cream are traditional for the skin and mostly '
                    'harmless on the body. Keep them away from the eyes and '
                    'mouth, and stop if the skin reddens. Skip fairness '
                    "pastes and any lightening product entirely. Your baby's "
                    "colour isn't a problem to be treated."),
                // Added 2026-10-02 from the parenting gap analysis (P2/P3).
                PpCarouselCard('Soft spots on the head',
                    'Two gaps between the skull bones, which let the head shape ' 'during birth and the brain grow. Gentle touching is ' 'safe. The back one closes by about two months, the ' 'front by about 18 months.'),
                PpCarouselCard('A pointed or uneven head',
                    'From the birth. It rounds ' 'out within days to weeks.'),
                PpCarouselCard('Fine body hair (lanugo)',
                    'On the back, shoulders and ears, especially in babies '
                                                  'born early. It falls out '
                                                  'in the first weeks; '
                                                  "there's no need to rub it "
                                                  'off with wheat flour or gram flour.'),
                PpCarouselCard('Hair on the head falling out',
                    'Normal; it grows back.'),
                PpCarouselCard('Swollen breasts or genitals',
                    'From your hormones. A little milky fluid from the '
                                             'nipples, or a small bleed in a '
                                             'girl, can happen. Never '
                                             'squeeze.'),
                PpCarouselCard('A strawberry mark',
                    'A raised red birthmark that may grow for some months, '
                                                            'then fades over '
                                                            'years. Show the '
                                                            'doctor, '
                                                            'especially if '
                                                            "it's near the "
                                                            'eye, mouth or '
                                                            'nappy area.'),
              ],
            ),
            /* kept for revert: the cards the carousel replaced
            PpIntro('Newborn skin does a lot of odd things in the first '
                'weeks, and nearly all of it clears on its own. Most of what '
                'worries parents needs no cream at all.'),
            PpCards([
              PpCard('Peeling and flaking',
                  'Especially hands, feet and ankles, in the first two weeks. '
                  'Normal. A plain moisturiser if it looks dry, nothing more.'),
              PpCard('Tiny white pinhead spots on the nose and cheeks',
                  'Milia, blocked oil glands. They clear by themselves in a '
                  "few weeks. Don't squeeze them."),
              PpCard('Blotchy red patches with a small pale centre',
                  'A common newborn rash of the first week. Comes and goes '
                  'across the body and needs nothing.'),
              PpCard('Small pimples on the face at 3 to 4 weeks',
                  'Newborn acne, driven by hormones. Wash with plain water and '
                  'wait. No creams.'),
              PpCard('Slate grey or bluish patches on the back and buttocks',
                  'Common in Indian babies. Harmless birthmarks that fade over '
                  'years.'),
              PpCard('A flat pink patch on the eyelids, forehead or nape',
                  'A stork mark. It reddens with crying and usually fades.'),
              PpCard('Yellow greasy scales on the scalp',
                  'Cradle cap. Soften with a little oil an hour before a bath, '
                  'then wash gently. Never pick it off.'),
              PpCard('Prickly red bumps in the neck folds',
                  'Heat rash. Fewer layers, a cooler room, and keep the folds '
                  'dry.'),
            ], heading: 'Common and harmless', hue: 44),
            PpWhenLine('Most of this appears in the first 2 to 4 weeks and '
                'settles by 2 to 3 months.'),
            PpCallout(
              'Show a doctor: blisters, or spots filled with pus or fluid. A '
              'rash with a fever, or with poor feeding. Small dark red or '
              "purple spots that don't fade when you press them. Yellow, "
              'weeping or spreading patches, or a rash all over the body '
              'that came up very quickly.',
              kind: PpCalloutKind.doctor,
              title: 'Skin that needs a doctor',
            ),
            PpIndiaNote('Besan and malai are traditional for the skin and '
                'mostly harmless on the body. Keep them away from the eyes '
                'and mouth, and stop if the skin reddens. Skip fairness '
                "pastes and any lightening product entirely. Your baby's "
                "colour isn't a problem to be treated."),
            */
          ],
        ),
        PpPage(
          id: 'f40_jaundice',
          title: 'Jaundice: what to watch and when it matters',
          subtitle: 'Very common, usually harmless, occasionally not.',
          format: 'FLAGGED ARTICLE',
          blocks: [
            PpIntro('Most newborns go a little yellow in the first week. A '
                'new liver is still learning to clear a normal waste '
                'product, and in most babies the yellow fades on its own. '
                "It's still worth watching properly."),
            PpChartCard(
              title: 'The usual timeline',
              // REQUIRED_REVIEW: the entire jaundice timeline. Onset day 2 to
              // 3, peak day 4 to 5, fading by day 10 to 14 (later in breastfed
              // babies), plus the three red-flag timings named below: yellow in
              // the first 24 hours, jaundice reaching palms and soles, and new
              // or persisting jaundice after 2 weeks.
              rows: [
                ('Appears', 'Day 2 or 3, face first'),
                ('Peaks', 'Around day 4 or 5'),
                ('Fades', 'By day 10 to 14, sometimes a little later'),
                ('Spreads', 'Face, then chest, then tummy, then legs'),
                ('Treatment, if needed', 'Light therapy in hospital'),
              ],
              note: 'Feeding often is the most useful thing you can do. Milk '
                  'moves the waste product out through the stools.',
              hue: 44,
            ),
            PpSteps([
              PpStep('Look at your baby in daylight, not under a tube light',
                  'Yellow light hides it and white light exaggerates it. Sit '
                  'near a window.'),
              PpStep('Press gently on the forehead or nose, then let go',
                  'Yellow in the blanched skin as the colour returns is '
                  'jaundice.'),
              PpStep('Check how far down it goes',
                  'Face only is usually mild. Chest and tummy means more. '
                  'Palms and soles means see a doctor today.'),
              PpStep('Feed often, 8 to 12 times a day',
                  'Wake a sleepy baby for feeds. Sleepy plus yellow is the '
                  'combination to act on.'),
              PpStep('Count the wet nappies and stools',
                  'Fewer stools slows the clearing. Report a drop.'),
            ], heading: 'How to check your baby at home'),
            PpCallout(
              "Sunlight through a window isn't treatment. It isn't enough "
              'light to clear jaundice, and direct sun can burn and overheat '
              "a newborn. Stopping breastfeeding doesn't help either; more "
              'feeding is what clears it. Real treatment is a hospital light '
              'unit, and it works quickly.',
              kind: PpCalloutKind.myth,
              title: 'The sunlight myth',
            ),
            PpCallout(
              'See a doctor today if your baby looks yellow in the first 24 '
              'hours of life, or the yellow is deepening rather than fading. '
              'The same if it reaches the palms or the soles of the feet, or '
              'your baby is very sleepy or feeding poorly. Go too for pale '
              'or chalky stools with dark urine, or yellow that lasts past '
              'two weeks. Ask for a bilirubin level, not a look.',
              kind: PpCalloutKind.doctor,
              title: 'Jaundice that needs a doctor',
            ),
            PpWhenLine('Watch daily from day 2 to about day 14. Any jaundice '
                'starting on day 1, or lasting past two weeks, is checked '
                'regardless of how mild it looks.'),
            PpIndiaNote('Home light treatment kits are sold and rented in '
                "many cities. Don't arrange one yourself based on how yellow "
                'your baby looks. Jaundice is treated against a blood level '
                "and the baby's age in hours, and only a doctor can set "
                'that.'),
          ],
        ),
        PpPage(
          id: 'f40_cluster_feeding',
          title: 'Your baby wants to feed all evening',
          subtitle: 'Cluster feeding and growth spurts, explained.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Feeding every twenty minutes from five in the evening '
                'until midnight is one of the most alarming and most normal '
                "things a newborn does. It's almost never about your milk "
                'running out.'),
            PpArticle([
              'Cluster feeding is short feeds bunched close together, '
              'usually in the evening, often with fussing in between. Your '
              'baby is topping up, self-settling, and telling your body to '
              'make more milk for tomorrow. The signal works because your '
              'baby is draining the breast now.',
              'Growth spurts do the same thing for a day or two at a time. They '
              'tend to land at around 2 to 3 weeks, 6 weeks and 3 months, and '
              'they end as suddenly as they start.',
              'It feels like failure because of the timing. Evening is when '
              'your supply naturally feels softest, and when the whole house '
              "is watching. Neither means there's less milk.",
            ]),
            PpCards([
              PpCard('Your baby is fine if the nappies are fine',
                  'Six or more wet nappies a day and steady weight gain '
                  "settle the question. Fussing doesn't."),
              PpCard('Feed on cue rather than by the clock',
                  "A clock can't tell you when your baby is hungry. Your "
                  'baby can.'),
              PpCard('Set yourself up for it',
                  'Water, food, a charged phone, a comfortable corner. Plan the '
                  'evening around feeding rather than fighting it.'),
              PpCard('Let someone else do everything else',
                  'This is the shift where help is worth the most.'),
            ], heading: 'What helps', hue: 44),
            PpWhenLine('Common from about day 10 to 3 months, heaviest in the '
                'evenings and around growth spurts.'),
            PpCallout(
              "This is different from a baby who isn't getting enough. Speak "
              'to a doctor or a lactation expert if there are fewer than 6 '
              'wet nappies a day, or no return to birth weight by two weeks. '
              "The same if there's no gain after that, or your baby is "
              'sleepy and hard to wake for feeds. Or if your baby feeds '
              'constantly and still seems desperate and limp.',
              kind: PpCalloutKind.doctor,
              title: 'When constant feeding is a real problem',
            ),
            PpIndiaNote('Evening cluster feeding is the most common reason '
                'formula gets started in Indian homes, usually on the advice '
                'of someone who loves you. If you want to keep '
                'breastfeeding, ask for the nappy count and the weight to be '
                "checked first. If you choose to top up, that's your "
                'decision, and a fed baby is the point.'),
          ],
        ),
        PpPage(
          id: 'f40_newborn_noises',
          title: 'Hiccups, sneezes, grunts and other noises',
          subtitle: 'The sounds that keep parents awake for nothing.',
          // [reformat: cards > carousel] "swipe through the normal noises."
          // The page is its one block; the cards are kept below for revert.
          // format: 'CARDS',
          format: 'CAROUSEL',
          blocks: [
            PpCarousel(
              hue: 44,
              coverTitle: 'Hiccups, sneezes, grunts and other noises',
              coverBlurb: 'The sounds that make you sit up at 3am, and what '
                  'each one means. Nearly all of them mean nothing.',
              cards: [
                PpCarouselCard('Hiccups, several times a day',
                    "The diaphragm is still immature. Hiccups don't hurt. A "
                    'feed or a cuddle usually settles them; never jerk or '
                    'startle a baby to stop them.'),
                PpCarouselCard('Sneezing often',
                    'Clearing dust and mucus from a tiny nose. Not a cold, '
                    "unless there's also a blocked nose that gets in the way "
                    'of feeds.'),
                PpCarouselCard('Grunting and straining, especially while pooping',
                    'Your baby is learning to push while lying flat. Normal. '
                    'Constipation means hard pellets, not effort.'),
                PpCarouselCard('A rattly or snuffly nose',
                    'Narrow passages plus normal mucus. Saline drops if it blocks a feed, and nothing else.'),
                PpCarouselCard('Squeaks, whimpers and cries in sleep',
                    'Light sleep. Wait a minute before picking your baby up; '
                    'many settle by themselves.'),
                PpCarouselCard('Jerky arms and legs, and a startle with a bang',
                    'A normal newborn reflex. It fades by 3 to 4 months.'),
                PpCarouselCard('Irregular breathing while asleep',
                    'Fast, then slow, then a short pause. Normal in a '
                    'newborn, as long as your baby stays pink and the pauses '
                    'are brief.'),
                PpCarouselCard('A small posset of milk after feeds',
                    'Bringing up a mouthful is normal. Forceful or green vomiting is not.'),
                PpCarouselCard('Noises that mean breathing trouble',
                    'A doctor now if breathing is the problem, not the '
                    'noise. More than 60 breaths a minute at rest, or '
                    'grunting with every single breath. Nostrils flaring, or '
                    'the ribs or the gaps between them pulling in. A pause '
                    'longer than 15 to 20 seconds, a blue tinge to the lips '
                    'or tongue, or a blocked nose that stops feeding at all.'),
                PpCarouselCard('In an Indian home',
                    'Hiccups often get treated at home with water, herbal drops or '
                    "a thread on the forehead. Water before six months isn't "
                    'safe for a baby, and no baby needs gripe water or herbal '
                    'drops (janam ghutti). A feed does the same job with none of the risk.'),
              ],
            ),
            /* kept for revert: the cards the carousel replaced
            PpIntro('Newborns are noisy sleepers and noisy feeders. Most of the '
                'sounds that make you sit up at 3am mean nothing at all.'),
            PpCards([
              PpCard('Hiccups, several times a day',
                  "The diaphragm is still immature. Hiccups don't hurt. A "
                  'feed or a cuddle usually settles them; never jerk or '
                  'startle a baby to stop them.'),
              PpCard('Sneezing often',
                  'Clearing dust and mucus from a tiny nose. Not a cold, '
                  "unless there's also a blocked nose that gets in the way "
                  'of feeds.'),
              PpCard('Grunting and straining, especially while pooping',
                  'Your baby is learning to push while lying flat. Normal. '
                  'Constipation means hard pellets, not effort.'),
              PpCard('A rattly or snuffly nose',
                  'Narrow passages plus normal mucus. Saline drops if it blocks '
                  'a feed, and nothing else.'),
              PpCard('Squeaks, whimpers and cries in sleep',
                  'Light sleep. Wait a minute before picking your baby up; '
                  'many settle by themselves.'),
              PpCard('Jerky arms and legs, and a startle with a bang',
                  'A normal newborn reflex. It fades by 3 to 4 months.'),
              PpCard('Irregular breathing while asleep',
                  'Fast, then slow, then a short pause. Normal in a newborn, '
                  'as long as your baby stays pink and the pauses are brief.'),
              PpCard('A small posset of milk after feeds',
                  'Bringing up a mouthful is normal. Forceful or green vomiting '
                  'is not.'),
            ], heading: 'Normal, and needing nothing', hue: 44),
            PpWhenLine('All of this is usual through the first 3 months.'),
            PpCallout(
              'These same sounds need a doctor now if breathing is the '
              'problem, not the noise. More than 60 breaths a minute at '
              'rest, or grunting with every single breath. Nostrils flaring, '
              'or the ribs or the gaps between them pulling in. A pause '
              'longer than 15 to 20 seconds, a blue tinge to the lips or '
              'tongue, or a blocked nose that stops feeding at all.',
              kind: PpCalloutKind.doctor,
              title: 'Noises that mean breathing trouble',
            ),
            PpIndiaNote('Hiccups often get treated at home with water, gutti '
                "or a thread on the forehead. Water before six months isn't "
                'safe for a baby, and no baby needs gripe water or herbal '
                'drops (janam ghutti). A feed does the same job with none of the risk.'),
            */
          ],
        ),
        PpPage(
          id: 'f40_day_night',
          title: 'Why your baby is awake all night',
          subtitle: 'Day and night confusion, and how it sorts itself out.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Your baby spent nine months in the dark with no idea '
                'when morning was, rocked to sleep every time you walked. '
                "Being awake at night isn't a habit your baby picked up. "
                "It's the setting newborns arrive with."),
            // [single-source] The short-cycles / no-routine-yet explanation
            // is "Newborn sleep, honestly"'s; this page keeps day-and-night
            // confusion and what helps. The paragraph is kept for revert.
            PpArticle([
              'What you can do is give the body clock a gentle nudge: light '
              'and activity in the day, dark and dullness at night. Nothing '
              'else. Most babies find a longer night stretch somewhere '
              'between 6 and 12 weeks, on their own timing rather than '
              'yours.',
            ]),
            PpLink("Why newborns wake so often, and why there's no routine "
                'yet',
                pageId: 'f40_newborn_sleep',
                blurb: 'The short cycles, explained once.'),
            /* kept for revert
            PpArticle([
              'Newborns sleep in short cycles, around the clock, and wake '
              "often because they need to feed often. There's no routine to "
              'build yet and no schedule that will hold. What you can do is '
              'give the body clock a gentle nudge.',
            ]),
            */
            PpSteps([
              PpStep('Make mornings bright and ordinary',
                  'Open the curtains. Let the house be noisy. Feed in the '
                  'light and chat to your baby.'),
              PpStep('Keep night feeds boring',
                  'Dim light, no talking, no play, straight back down. Kind, '
                  'but dull.'),
              PpStep("Don't let daytime sleeps run past 3 hours early on", 'Waking a long daytime sleeper for a feed helps your '
                  'baby take more of the sleep at night.'),
              PpStep('Sleep when your baby sleeps, even in the afternoon',
                  "It's the least glamorous advice in the world, and it's "
                  'still the one that works.'),
              PpStep('Take turns if you can',
                  'One long stretch of unbroken sleep for you, once a day, '
                  'changes how the whole week feels.'),
            ], heading: 'What helps'),
            PpWhenLine('Day and night confusion is normal for the first 6 to 8 '
                'weeks and usually settles by 3 months.'),
            PpCallout("There's no sleep training in this app, and none of it "
                'suits a newborn anyway. At this age, responding to your '
                'baby is the right answer every time.'),
            PpIndiaNote('In a joint family the night is often shared, and '
                "that's a real advantage. If a grandmother offers to take "
                'the 5am shift, say yes. The one thing to hold firm on is '
                "where and how your baby sleeps, because safe sleep doesn't "
                'change with who is holding the baby.'),
            PpLink('Newborn sleep, in full',
                surfaceId: 'pp_sleep',
                blurb: "What's normal at every age, and gentle settling."),
          ],
        ),
        PpPage(
          id: 'f40_safe_sleep',
          title: 'Sleeping safely, in your bed or a cot',
          subtitle: 'How to make the way your family sleeps safer.',
          // [reformat: step-list > illustration] [reference] Sleep's safe-sleep
          // picture, the same drawing. "High stakes, a picture carries it."
          // format: 'STEP-LIST',
          format: 'ILLUSTRATION',
          blocks: [
            PpIntro('Almost every Indian family sleeps with the baby in the '
                'room, and most share the bed. Rather than telling you not '
                "to, here's how to make it as safe as it can be, and the few "
                "situations where it isn't safe at all."),
            PpIllustration(
              kind: PpIllustrationKind.safeBedSetup,
              title: 'A safe sleep space, in your bed or a cot',
              labels: [
                PpIllustrationLabel('On the back', 'Every sleep, naps included, with anyone.'),
                PpIllustrationLabel('A firm, flat surface', 'Not a soft mattress, a quilt nest or a folded quilt.'),
                PpIllustrationLabel('Nothing loose around the head', 'No pillow, soft toys, bumpers or dupatta.'),
                PpIllustrationLabel("A clear space of the baby's own", 'Beside the mother, not between the parents or against a bolster.'),
              ],
            ),
            PpSteps([
              PpStep('On the back, every sleep',
                  'Naps included, at night, with anyone. This one rule reduces '
                  'the risk more than everything else combined.'),
              PpStep('On a firm flat surface',
                  'A firm mattress or a cot. Not a soft mattress, not a '
                  'quilt nest, not a pillow, not a sofa, and never a folded '
                  'quilt a baby can sink into.'),
              PpStep('Nothing loose around the head',
                  'No pillow, no soft toys, no bumpers, no dupatta, no thick '
                  'blanket. A thin sheet tucked low, or a sleep bag.'),
              PpStep("A clear space of the baby's own in the bed",
                  'Beside the mother, not between the parents, not against a '
                  'wall or a bolster where a baby can get wedged.'),
              PpStep('Feet to the foot of the bed, sheet no higher than the '
                  'chest', "So bedding can't ride up over the face."),
              PpStep('In your room for the first 6 months',
                  'In your room protects your baby; in your bed is a '
                  'separate question. A cot beside the bed gives you both.'),
              PpStep('Never on a sofa or an armchair with you',
                  'Falling asleep holding your baby on soft furniture is the '
                  'most dangerous way to sleep together.'),
            ], heading: 'Making sleep safer, wherever your baby sleeps'),
            PpCallout(
              "Don't share a bed with your baby at all if anyone in it has "
              'been drinking, has taken anything that causes drowsiness, '
              'smokes, or is extremely exhausted. The same applies if your '
              'baby was born early or very small. Then use a cot beside you '
              'instead, in the same room.',
              // A rule she acts on, not a flag that sends her to someone: the
              // instruction is complete as written. See PpCalloutKind.safety.
              kind: PpCalloutKind.safety,
              title: 'When bed-sharing is not safe',
            ),
            PpWhenLine('These rules matter most in the first 6 months, and '
                'the back-to-sleep rule holds until your baby rolls '
                'confidently without help.'),
            PpIndiaNote('The cloth swing (jhula) and the metal cradle (palna) are both fine '
                'for supervised naps. Your baby should lie flat on a firm '
                'base with nothing padded underneath, with someone in the '
                "room. What isn't fine is a deep hammock shape that curls "
                'the chin onto the chest, or a baby left swinging while '
                'everyone is outside.'),
            PpLink('The full safe sleep guide',
                surfaceId: 'pp_sleep',
                blurb: 'Cots, sharing a bed, naps, and everything after the '
                    'newborn weeks.'),
          ],
        ),
        PpPage(
          id: 'f40_folk_practices',
          title: 'The old practices: which help and which harm',
          subtitle: 'Honest about both, because both are real.',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro("The traditional forty days of rest (jaapa) get a great deal right, and it's worth saying so "
                'first. It gives the new mother rest and warm food, keeps '
                'crowds away from a new baby and puts loving hands on the '
                'baby every day. Modern newborn care agrees with all of '
                'that.'),
            PpCards([
              PpCard('Forty days of rest for the mother',
                  'Protective. Bleeding settles faster and feeding sets in '
                  "better when the mother isn't running the house."),
              PpCard('Daily baby massage',
                  'Real benefits. Better weight gain, calmer babies, better '
                  "sleep, and it's how fathers and grandmothers bond."),
              PpCard('Warm, easy, ghee-rich food',
                  'Sensible when appetite is low and energy needs are high. '
                  'Protein and iron matter most.'),
              PpCard('Keeping visitors away',
                  'Right. A newborn has very little immunity, and infection '
                  "is the main thing you're protecting your baby from."),
              PpCard('Skin contact and constant holding',
                  'One of the best-supported things in newborn care. '
                  'Tradition knew this long before the textbooks did.'),
            ], heading: 'What tradition gets right', hue: 44),
            PpTable(
              heading: 'What to stop, and why',
              columns: ['The practice', 'Why not', 'Instead'],
              rows: [
                [
                  'Turmeric, oil, ash, powder or cow dung on the cord',
                  'Causes umbilical infection and newborn tetanus, which kills',
                  'Keep it dry and uncovered',
                ],
                [
                  'Kohl (kajal or surma) in the eyes',
                  'Eye infection, and many kohl products carry lead',
                  'Nothing in the eyes at all',
                ],
                [
                  'Oil in the ears or nose',
                  'Can be inhaled into the lungs, and damages the ear canal',
                  'Wipe only what you can see outside',
                ],
                [
                  'Honey, jaggery or herbal drops (ghutti) in the mouth',
                  'Honey can cause infant botulism. Nothing else is needed',
                  'Only breastmilk or formula before 6 months',
                ],
                [
                  'Water, gripe water or holy water before 6 months',
                  "Fills a tiny stomach, dilutes the body's salts, replaces "
                  'milk',
                  'Breastmilk covers every fluid need',
                ],
                [
                  'Pressing the head or nose into shape',
                  'The skull moulds back on its own. Pressing does no good',
                  'Leave it. It settles in weeks',
                ],
                [
                  'A drawstring or tight belly binding on the baby',
                  'Restricts breathing, does nothing for a hernia or navel',
                  'Loose clothes, and show any bulge to a doctor',
                ],
                [
                  'Massaging or pressing the soft spot on the head',
                  'It protects the brain and needs no treatment',
                  "Wash it gently, don't press it",
                ],
                [
                  'Pulling and straightening the legs during massage',
                  'Forcing hips straight can affect how the joint forms',
                  'Gentle strokes, legs free to bend',
                ],
                [
                  'Shaving or scrubbing to change skin colour',
                  "Skin colour isn't a condition. Scrubs damage the skin",
                  "Nothing. Your baby's skin is fine",
                ],
              ],
            ),
            PpCallout(
              "The reason to be firm about this short list isn't that the "
              'old ways are wrong. These few put things inside a body that '
              'has no defences yet. Everything else in the forty days can stay '
              'exactly as it is.',
              kind: PpCalloutKind.myth,
            ),
            PpWhenLine('Applies from birth. The eye, ear, cord and mouth rules '
                'matter most in the first 6 weeks.'),
            PpIndiaNote("You'll be having this talk with someone who raised "
                'children well and loves this baby. Naming the doctor and '
                'offering a swap works better than evidence. "The '
                'paediatrician said no kohl; keep it for after the first '
                'birthday" gives everyone a way to agree.'),
            PpCallout(
              'If something has already gone into the eyes, ears, cord or '
              'mouth, tell your doctor plainly and without embarrassment. '
              'Nobody will scold you, and knowing changes what the doctor '
              'looks for.',
              kind: PpCalloutKind.doctor,
              title: 'If something has already been used',
            ),
          ],
        ),
        // ⚠️ [NEW], a scaffold. "A premature, low-birth-weight, or
        // just-out-of-NICU baby: what is different about temperature,
        // feeding, kangaroo care, and when to worry. Today this exists only
        // as scattered 'if he was born early' lines with no home."
        PpPage(
          id: 'f40_small_or_early',
          title: 'Bringing home a small or early baby',
          subtitle: 'Temperature, feeding, kangaroo care, and when to worry.',
          format: 'ARTICLE',
          
          blocks: [
            // Written 2026-10-02 (parenting gap analysis), filling the scaffold.
            // REQUIRED_REVIEW.
            PpIntro('A baby born small or early is often sent home a little '
                'sooner than parents feel ready. Your baby needs the same '
                'love, with a little extra care around warmth, feeding and '
                'infection. Most small babies catch up beautifully.'),
            PpSteps(heading: 'Warmth', [
              PpStep('Kangaroo care', 'Skin to skin on your chest, for as many hours a '
                  'day as you can. Papa can do it too.'),
              PpStep('A cap and socks', 'Small babies lose heat fast from the head '
                  'and feet.'),
              PpStep('A warm room, not a hot one', 'No heater or coal stove in a closed '
                  'room.'),
            ]),
            PpSteps(heading: 'Feeding', [
              PpStep('Feed often', 'Every two to three hours, waking your '
                  'baby if the doctor advises.'),
              PpStep('Small babies tire quickly', 'Short, frequent feeds; '
                  "expressed milk by cup or spoon if your baby can't suck "
                  'for long.'),
              PpStep('Count wet nappies, and weigh your baby', 'At the visits the doctor sets.'),
            ]),
            PpSteps(heading: 'Keeping your baby well', [
              PpStep('Hand washing', 'Everyone, every time.'),
              PpStep('Fewer visitors', 'For the first weeks, and no one who is unwell.'),
              PpStep('Keep every follow-up', 'Eye checks, hearing tests and growth '
                  'checks for early babies.'),
            ]),
            PpCallout('Go to a doctor straight away if your baby feels cold '
                "or has a fever, or isn't feeding. The same for fast "
                'breathing or pauses in breathing, turning blue, or being '
                'unusually floppy or sleepy.',
                kind: PpCalloutKind.doctor),
            PpLink('If your baby went to the NICU',
                surfaceId: 'pp_page/parenting_special_care/sc_preemie_home'),
          ],
        ),
        // Added 2026-10-02 from the parenting gap analysis (P2/P3).
        PpPage(
          id: 'f40_genital_care',
          title: 'Cleaning a newborn girl or boy',
          subtitle: 'Gentle, front to back, nothing inside',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Newborn private parts can look swollen and surprising '
                'in the first days, because of your hormones. Cleaning is '
                'easy: warm water, cotton, and a light hand.'),
            PpSteps(heading: 'For a girl', [
              PpStep('Wipe from front to back', 'Every nappy change, with '
                  'cotton dipped in warm water.'),
              PpStep("Don't clean deep inside the folds",
                  'A white discharge or a little blood in the first week or '
                      'two is normal and protective.'),
              PpStep('Swelling settles in a few weeks'),
            ]),
            PpSteps(heading: 'For a boy', [
              PpStep('Wash the outside only', 'Never pull back the foreskin.'),
              PpStep('After a circumcision',
                  'Keep the tip clean, put a little petroleum jelly on it or '
                      "on the nappy so it doesn't stick, and fasten the "
                      'nappy loosely. It heals in about a week to ten days.'),
            ]),
            PpCallout('See a doctor for heavy bleeding, pus, a fever or '
                'spreading redness. Also if no urine has passed within 12 '
                'hours after a circumcision.',
                kind: PpCalloutKind.doctor),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  4. Feeding and sleep in the early days
    // -------------------------------------------------------------------------
    //  The newborn slice ONLY. Everything past the first weeks links out to the
    //  Feeding and Sleep sections rather than being written twice.
    // =========================================================================
    PpArea(
      id: 'feeding_sleep_early',
      mark: IntentMark.feedMark,
      title: 'Feeding & Sleep in the Early Days',
      blurb: 'The newborn slice: latch, how often, is your baby getting '
          'enough, and why newborns wake.',
      hue: 190,
      pages: [
        PpPage(
          id: 'f40_latch',
          title: 'Getting the latch right',
          subtitle: 'The one thing that makes feeding stop hurting.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('A deep latch is the difference between feeding that '
                "hurts and feeding that works. It's a skill, not an "
                'instinct, and almost everyone needs a few days and a pair '
                'of experienced hands to learn it.'),
            PpVideoSlot(
              // The shared film's own title; one slot id, one title.
              title: 'A lactation counsellor shows a deep latch',
              subtitle: "Positioning, the mouth wide, and how to tell it's "
                  'right. Filmed with a real mother and baby.',
              minutes: '7 MIN',
              // ⚠️ ITS OWN ID. This shared 'feeding/latch_demo' with the Feeding
              // section, whose video is a lactation counsellor teaching the
              // latch. This one is a newborn-week explainer with a different
              // title and a different job. Two different videos under one id
              // means one file lands and the other never does.
              // [reference] Feeding's latch film, one film. Was
              // 'first40/latch_demo'.
              slotId: 'feeding/latch_demo',
            ),
            PpSteps([
              PpStep('Get yourself comfortable first',
                  'Back supported, feet down, a pillow under your arm or on '
                  "your lap. If you're twisted, your baby will slip."),
              PpStep('Bring your baby chest to chest, nose to nipple',
                  'The whole body facing you, ear, shoulder and hip in a '
                  'line. Not just the head turned.'),
              PpStep('Wait for the wide open mouth',
                  'Brush your nipple on the upper lip. Your baby will gape '
                  "like a yawn. That's the moment."),
              PpStep('Bring your baby on quickly, chin first',
                  'Aim your nipple towards the roof of the mouth. Bring your '
                  "baby to you; don't lean in."),
              PpStep('Check the shape',
                  'More of the darker skin showing above the top lip than '
                  'below. Chin pressed in, nose free, lips flanged out.'),
              PpStep('Listen and watch',
                  'Deep slow jaw movements down to the ear, pauses, and '
                  'swallowing. Not fast fluttery sucking.'),
              PpStep('If it hurts, take your baby off and start again',
                  'Slide a clean finger into the corner of the mouth to '
                  'break the seal. Never pull a baby off a latch.'),
            ], heading: 'The latch, step by step'),
            PpCards([
              PpCard("It's working if",
                  "It's comfortable after the first few seconds and the "
                  'cheeks are full and rounded. You can hear swallowing, and '
                  'your nipple comes out the same round shape it went in.'),
              PpCard('It needs fixing if',
                  'It pinches or burns throughout, you hear clicking, your '
                  'baby keeps slipping off, your nipple comes out flattened '
                  "or creased, or you're cracked and bleeding."),
              PpCard('Try a different hold',
                  'Cross-cradle for control, rugby hold after a caesarean, or '
                  'lying on your side at night. The best hold is the one that '
                  'works for you.'),
              PpCard('Nipple shields and pumps have a place',
                  "They're tools, not failure. Ask someone to show you "
                  'rather than working it out from a box.'),
            ], heading: 'Reading the latch', hue: 190),
            PpWhenLine('Work on this from the first hour after birth and '
                'through the first two weeks. Most pain settles once the latch '
                'is deep.'),
            PpCallout(
              'Get help within a day, not a week, if your nipples are '
              'cracked or bleeding, or feeding hurts badly the whole way '
              'through. The same for a hard, red, painful patch on the '
              'breast with a fever. Or if your baby has lost more than 10 '
              "percent of birth weight, or can't stay latched at all.",
              kind: PpCalloutKind.doctor,
              title: 'When to get help fast',
            ),
            PpIndiaNote('Ask the hospital for a lactation consultant before '
                "you're discharged, and again on day 3 when your milk comes "
                'in properly. Most hospitals have one, and most mothers are '
                'never offered one.'),
            PpConsult(
              title: 'Talk to a Newborn Expert',
              whoFor: 'For a latch that still hurts, cracked nipples, worry '
                  "about supply, or a baby who won't stay on. A lactation "
                  'expert and a newborn nurse, on video, usually the same '
                  'day.',
              surfaceId: 'pp_experts',
              role: 'lactation',
            ),
          ],
        ),
        PpPage(
          id: 'f40_how_often',
          title: 'How often should my baby feed?',
          subtitle: 'On demand, and what that really means at 3am.',
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('A newborn stomach is tiny and breastmilk digests fast, '
                'so newborns feed far more often than seems reasonable. '
                'Feeding on demand means feeding when your baby asks, not '
                'when a clock says.'),
            PpChartCard(
              title: 'What normal looks like',
              // REQUIRED_REVIEW: 8 to 12 feeds per 24 hours; not letting a
              // newborn go more than 3 hours by day and 4 hours by night
              // without a feed in the first 2 weeks; feed length of 10 to 40
              // minutes.
              rows: [
                ('Feeds in 24 hours', '8 to 12, sometimes more'),
                ('Gap by day, first 2 weeks', 'No more than 3 hours'),
                ('Gap by night, first 2 weeks', 'No more than 4 hours'),
                ('Length of a feed', '10 to 40 minutes, both very normal'),
                ('Which side', 'Finish one properly, then offer the other'),
              ],
              note: 'Counting feeds helps in the first fortnight. After '
                  'that, nappies and weight tell you far more than any '
                  'number of feeds.',
              hue: 190,
            ),
            PpCards([
              PpCard('Early hunger cues, catch these',
                  'Stirring, turning the head, opening the mouth, hands to '
                  'mouth, sucking noises. A feed offered now goes far '
                  'better.'),
              PpCard('Crying is a late cue',
                  "By the time your baby screams, it's too hard to latch. "
                  'Calm your baby against your skin first, then offer.'),
              PpCard('Wake a sleepy newborn to feed',
                  "In the first two weeks, don't let a long sleep run. "
                  'Undress your baby to the nappy, change it, hold skin to '
                  'skin, stroke the feet.'),
              PpCard("Formula isn't a failure",
                  "If you're topping up or fully formula feeding, feed on "
                  'demand the same way, follow the tin exactly, and never '
                  'water it down to stretch it.'),
            ], heading: "Reading your baby's cues", hue: 190),
            PpWhenLine('This pattern holds through the first 6 weeks. Feeds '
                'space out on their own after that.'),
            PpCallout(
              'A very sleepy newborn who has to be woken for every feed, or '
              "won't wake at all, needs a doctor the same day. So does one "
              'who suddenly refuses two feeds in a row. Sleepiness in a '
              'newborn is a symptom, not a personality.',
              kind: PpCalloutKind.doctor,
              title: 'A baby too sleepy to feed',
            ),
            PpIndiaNote("You'll be told that feeding this often means your "
                'milk is thin or not enough, and that a night bottle will '
                'let everyone sleep. Frequent feeding is how supply is '
                "built, and the first weeks are when it's set. If you want "
                'to keep breastfeeding, this is the fortnight to protect.'),
          ],
        ),
        PpPage(
          id: 'f40_getting_enough',
          title: 'Is my baby getting enough?',
          subtitle: 'The two numbers that answer it.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('This question keeps almost every new mother awake, and '
                "the honest answer is reassuring. You don't need to measure "
                'milk to know. You need the nappies and the weight.'),
            PpArticle([
              "You can't see how much comes out of a breast, so the only "
              'reliable evidence is what goes in and what comes out the '
              'other end. A baby who wets enough nappies and gains weight is '
              'getting enough, whatever the evening fussing suggests.',
              'Almost nothing else is evidence. Not how soft your breasts '
              'feel, how long feeds last, or how much you can pump. Not '
              "crying after a feed, and certainly not what someone else's "
              'baby does.',
            ]),
            PpChartCard(
              title: 'The signs your baby is getting enough',
              // REQUIRED_REVIEW: 6 or more wet nappies a day from day 5; 3 or
              // more stools a day after day 4; regains birth weight by day 10
              // to 14; gains 150 to 200 g a week for the first 3 months.
              rows: [
                ('Wet nappies, day 5 onward', '6 or more a day, pale urine'),
                ('Stools, after day 4', '3 or more a day, yellow'),
                ('Back to birth weight', 'By day 10 to 14'),
                ('Weight gain after that', '150 to 200 g a week'),
                ('At the breast', 'Deep swallows, calm at the end'),
                ('Overall', 'Alert when awake, good muscle tone'),
              ],
              note: "If these are in place, your baby is fine. You're "
                  'allowed to stop worrying about this one question.',
              hue: 190,
            ),
            PpCards([
              PpCard('Not evidence: soft breasts',
                  'Breasts settle down after the first few weeks. Supply '
                  "hasn't dropped; it has become efficient."),
              PpCard('Not evidence: what you can pump',
                  'A pump is much worse at removing milk than a baby is.'),
              PpCard('Not evidence: a short feed',
                  "Some babies are fast and effective. Time isn't intake."),
              PpCard('Not evidence: crying after a feed',
                  'Wind, tiredness, too much going on and wanting to be held '
                  'all look just like hunger.'),
            ], heading: 'What people will tell you to measure', hue: 190),
            PpWhenLine('Check nappies daily in the first fortnight, and weight '
                'at each visit. After 6 weeks, weight alone is enough.'),
            PpLink('The quick daily check',
                surfaceId: 'pp_baby_ok_check',
                blurb: 'Wet nappies, weight, jaundice and feeds. Four things, '
                    'thirty seconds, nothing to log.'),
            PpLink("Your baby's weight and growth",
                surfaceId: 'pp_growth',
                blurb: 'Plot it and see the curve rather than a single '
                    'reading.'),
            PpCallout(
              'See a doctor or a lactation expert if there are fewer than 6 '
              'wet nappies a day after day 5. The same for a loss of more '
              'than 10 percent of birth weight, or no return to birth weight '
              'by two weeks, or no gain after that. Go too for a dry mouth, '
              'a sunken soft spot, or a baby who is unusually sleepy and '
              'limp.',
              kind: PpCalloutKind.doctor,
              title: "When it's a real supply problem",
            ),
            PpConsult(
              title: 'Talk to a Newborn Expert',
              whoFor: 'For weight worry, slow gain, or a baby who feeds '
                  "forever and never seems full. If you've been logging "
                  'feeds, the expert can see that history before the call.',
              surfaceId: 'pp_experts',
              role: 'lactation',
            ),
          ],
        ),
        PpPage(
          id: 'f40_burping',
          title: 'Burping your baby',
          subtitle: "Useful, quick, and not the emergency it's made into.",
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Babies swallow air while feeding and some of it comes '
                "back up. Burping helps, and a baby who doesn't burp usually "
                'has no air to bring up.'),
            PpSteps([
              PpStep('Hold your baby upright against your chest',
                  'Chin over your shoulder, one hand under the bottom, a '
                  'cloth under the mouth.'),
              PpStep('Pat, or better, rub upwards',
                  'Firm flat strokes up the back. Gentle patting works too. No '
                  'thumping.'),
              PpStep('Or sit your baby on your lap',
                  'Leaning slightly forward, your hand supporting the chest '
                  'and chin, and rub the back.'),
              PpStep('Give it two or three minutes, then stop',
                  "If nothing comes, there's nothing there. Lay your baby "
                  'down.'),
              PpStep('Burp at the swap and at the end',
                  'And in the middle if your baby is squirming and pulling '
                  'off.'),
              PpStep('Hold your baby upright for ten minutes after a feed',
                  'This helps more with reflux than any amount of patting.'),
            ], heading: 'How to burp your baby'),
            PpWhenLine('Useful for the first 4 to 6 months, and less needed '
                'as feeding gets more skilled.'),
            PpCallout('A little milk coming up with the burp is normal. '
                "Don't jiggle hard, bounce, or hold your baby upside down. "
                'None of that brings up wind, and all of it is unsafe for a '
                'newborn neck.'),
            PpCallout(
              'Speak to a doctor if your baby vomits forcefully after most '
              'feeds, or the vomit is green, yellow-green or has blood in '
              'it. The same for arching and screaming with every feed, or no '
              'weight gain. Ordinary posseting looks like a spill, not a '
              'fountain.',
              kind: PpCalloutKind.doctor,
              title: "Vomiting that isn't just wind",
            ),
            PpIndiaNote('Asafoetida (hing) paste on the tummy, gripe water and herbal '
                'drops (janam ghutti) are all offered for wind. Asafoetida on the skin can burn '
                'a newborn, and nothing needs to go in the mouth. Holding '
                'your baby upright and a gentle clockwise tummy stroke do '
                'the same job safely.'),
            // Added 2026-10-02 from the parenting gap analysis (P2/P3).
            PpCards(heading: 'A gassy baby', [
              PpCard('Why', 'Swallowing air while feeding or crying, and a '
                  "gut that's still learning. Grunting and straining are "
                  'normal.'),
              PpCard('Bicycle the legs', 'Gently, with your baby on the '
                  'back, between feeds.'),
              PpCard('Tummy time and a warm hand on the tummy',
                  'While your baby is awake and watched.'),
              PpCard('Check the latch or teat', 'A shallow latch or a fast '
                  'teat means more air.'),
              PpCard('No gripe water or carom seed water', 'Not for babies under '
                  'six months.'),
            ]),
          ],
        ),
        PpPage(
          id: 'f40_newborn_sleep',
          title: 'Newborn sleep, honestly',
          subtitle: "Why newborns wake, and why there's no routine yet.",
          format: 'ARTICLE',
          blocks: [
            PpIntro('Newborns sleep a great deal and almost never for long. '
                "That isn't a problem to be solved, and it's the most "
                'misunderstood thing about the first two months.'),
            PpChartCard(
              title: 'Newborn sleep, 0 to 6 weeks',
              // REQUIRED_REVIEW: total sleep of 14 to 17 hours per 24 hours,
              // sleep cycle length of about 45 to 50 minutes, longest stretch
              // of 2 to 4 hours.
              rows: [
                ('Total in 24 hours', '14 to 17 hours'),
                ('One sleep cycle', 'About 45 to 50 minutes'),
                ('Longest stretch', '2 to 4 hours'),
                ('Naps a day', '4 to 6, of very uneven length'),
                ('Awake at a stretch', '30 to 60 minutes'),
              ],
              note: 'Waking every 2 to 3 hours to feed is expected. It '
                  "protects your baby's weight and your supply.",
              hue: 190,
            ),
            PpArticle([
              "Newborns wake because sleep cycles are short, because they're "
              'hungry, and because staying close to you is a survival '
              'instinct. None of it is a habit you created, and none of it '
              'can be trained at this age.',
              "So there's nothing to fix in these weeks. What helps is "
              'bright days and dull nights, sleeping when your baby sleeps, '
              'and sharing the nights with someone if you possibly can.',
            ]),
            PpCallout('No sleep training, no crying it out, and no schedules '
                'for a newborn. Responding to your baby at this age is the '
                'right answer every time, and it builds the sleep that comes '
                'later.'),
            PpWhenLine('Applies to the first 6 to 8 weeks. Longer stretches '
                'usually appear between 6 and 12 weeks.'),
            PpLink('Sleep, all the way through',
                surfaceId: 'pp_sleep',
                blurb: 'Safe sleep, gentle settling, naps and every age after '
                    'this one.'),
            PpCallout(
              'Talk to a doctor if your baby sleeps through feeds and is '
              'hard to wake, or is sleeping much more and feeding less. The '
              'same for pauses in breathing, or a usual pattern that '
              'suddenly stops with no clear reason.',
              kind: PpCalloutKind.doctor,
              title: 'Sleep that needs checking',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  5. Malish, Jhula & Soothing — the how-tos
    // =========================================================================
    PpArea(
      id: 'malish_jhula',
      mark: IntentMark.blocksMark,
      title: 'Massage, Carrying and Soothing',
      blurb: 'The things you do with your hands, step by step.',
      hue: 268,
      pages: [
        PpPage(
          id: 'f40_malish',
          title: 'Baby massage, step by step',
          subtitle: 'Which oil, how warm, which order, how long.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Baby massage is one of the best things our tradition hands '
                'down. Done gently, it helps babies gain weight, sleep '
                'better and settle faster. It also gives whoever does it a '
                'daily half hour of closeness with your baby.'),
            PpVideoSlot(
              // The shared film's own title; one slot id, one title.
              title: 'Massage before sleep, demonstrated',
              subtitle: 'Legs, arms, chest, tummy and back, with the pressure '
                  'shown on a real baby.',
              minutes: '10 MIN',
              // [reference] Sleep's malish film, one film. Was
              // 'first40/malish_demo'.
              slotId: 'sleep/malish_demo',
            ),
            PpSteps([
              PpStep('Pick your moment',
                  'Your baby should be awake, calm and not hungry. Wait at '
                  'least 30 to 45 minutes after a feed, and never massage a '
                  'crying or sleepy baby.'),
              PpStep('Warm the room and close the windows',
                  'Twenty minutes undressed needs a warm room with no '
                  'draught. Lay your baby on a towel on the floor or a bed.'),
              PpStep('Warm the oil in your palms, not on the stove',
                  'A little in your hands, rubbed together. Test a drop on your '
                  'own inner wrist first.'),
              PpStep('Legs first, feet to thigh',
                  'Long gentle strokes upwards, one leg at a time. Then '
                  'small circles on the soles and each toe. Babies are '
                  'usually happiest being touched on the legs.'),
              PpStep('Arms next, hands to shoulder',
                  'Same long strokes. Open the palm and circle it with your '
                  'thumb.'),
              PpStep('Chest, outwards from the middle',
                  'Flat hands, from the centre out to the sides, like smoothing '
                  'a page. Never press on the breastbone.'),
              PpStep('Tummy, clockwise only',
                  'Soft flat circles around the navel, clockwise, following '
                  'the gut. Avoid the cord area entirely until it has '
                  'healed.'),
              PpStep('Back, neck to bottom',
                  'Turn your baby onto the tummy across your lap or the '
                  'towel. Long strokes down either side of the spine, never '
                  'on the spine itself.'),
              PpStep('Finish, then a warm bath if you like',
                  'Wipe off the extra oil, dress your baby warmly, and feed. '
                  'Expect hunger, and probably sleepiness.'),
            ], heading: 'The sequence'),
            PpChartCard(
              title: 'The practical numbers',
              // REQUIRED_REVIEW: waiting 30 to 45 minutes after a feed, a
              // massage length of 10 to 15 minutes for a newborn, and starting
              // full-body malish only after the cord has separated and healed.
              rows: [
                ('How long', '10 to 15 minutes for a newborn'),
                ('How often', 'Once a day is plenty. Twice in cold weather'),
                ('Best time', 'Morning, or before an evening bath'),
                ('After a feed', 'Wait 30 to 45 minutes'),
                ('When to start', 'Once the cord has fallen off and healed'),
                ('Pressure', 'Firm enough to move skin, never to press bone'),
              ],
              note: 'Watch your baby rather than the clock. Stop when the '
                  'enjoying stops.',
              hue: 268,
            ),
            // [single-source] "Malish oil is written twice." The comparison
            // on Jaapa Essentials is the one home; this page points there.
            // The cards are kept below for revert.
            PpLink('Which oil? Coconut, til, mustard, almond',
                pageId: 'f40_which_oil',
                blurb: 'The comparison, and the ones to skip.'),
            /* kept for revert
            PpCards([
              PpCard('Coconut oil',
                  'Light, cooling, well tolerated, easy to find. The safest '
                  'default, and best for hot weather.'),
              PpCard('Sesame or til oil',
                  'The traditional winter choice. Warming and nourishing. Use '
                  'cold-pressed and edible grade.'),
              PpCard('Mustard oil',
                  'Widely used in north and east India. Strong and can irritate '
                  'newborn skin, especially if warmed hot. Patch test, and '
                  'avoid it on very young or premature babies.'),
              PpCard('Almond oil',
                  'Gentle and light. Avoid if there is a family history of nut '
                  'allergy.'),
              PpCard('Skip these',
                  'Mineral oil and baby oils that are mostly mineral oil, '
                  "anything perfumed, and all essential oils. A baby's skin "
                  'absorbs far more than yours.'),
            ], heading: 'Which oil', hue: 268),
            */
            PpCallout(
              'Stop and speak to a doctor if the oil leaves the skin red, '
              'itchy or bumpy, or eczema flares after massage. Never let '
              'anyone put oil in the ears, nose, eyes or navel. No '
              'stretching or pulling the limbs straight, no pressing the '
              'soft spot, and no massaging head-down.',
              kind: PpCalloutKind.doctor,
              title: 'When to stop',
            ),
            PpWhenLine('Start once the cord has healed, usually around week '
                '2, and carry on for as long as your baby enjoys it.'),
            PpIndiaNote('If a massage helper comes, watch the whole first '
                'session. The traditional style can be far more forceful '
                'than a newborn needs. Ask for the leg-pulling and '
                "head-shaping parts to be skipped. A calm baby means it's "
                'being done right; a screaming one means too hard, whatever '
                'anyone says about getting used to it.'),
            PpLink('Massage oils and what to look for',
                surfaceId: 'pp_products',
                blurb: 'Cold-pressed, edible grade, no fragrance. What '
                    'matters on the label.'),
          ],
        ),
        PpPage(
          id: 'f40_soothing',
          title: 'Soothing your baby',
          subtitle: 'The calming sequence, in the order that works.',
          // [reformat: step-list > video-first] [reference] Sleep's settling
          // film, the calming moves shown. Steps stay under it.
          // format: 'STEP-LIST',
          format: 'VIDEO',
          blocks: [
            PpVideoSlot(
              // The shared film's own title; one slot id, one title.
              title: 'Gentle settling, demonstrated',
              subtitle: 'Swaddle, side, shush, sway, and when to stop and '
                  'hand your baby over.',
              minutes: '4 MIN',
              slotId: 'sleep/settling_demo',
              hue: 26,
            ),
            PpIntro('Newborns calm down through their bodies, not through '
                'reasoning, and a rough order works better than random '
                'trying. Recreate the womb: snug, sideways, noisy and '
                'moving.'),
            PpSteps([
              PpStep('Swaddle snugly',
                  'Arms contained, hips free. Loose, flailing arms keep the '
                  'startle going.'),
              PpStep('Hold your baby on the side or tummy, against you',
                  'Along your forearm or over your shoulder. This position '
                  'is only for calming in your arms, never for sleeping.'),
              PpStep('Shush loudly, close to the ear',
                  'Louder than the crying, then softer as your baby settles. '
                  'The womb was noisier than your living room.'),
              PpStep('Sway or jiggle, small and fast',
                  'Tiny movements from your hips, supporting the head. Never '
                  'shaking, never jerking.'),
              PpStep('Offer a suck',
                  'The breast, a clean finger, or a dummy once feeding is '
                  'well set. Sucking flips a calming switch in the nervous '
                  'system.'),
              PpStep('If nothing works, go skin to skin',
                  'Your baby in just a nappy against your bare chest, a '
                  'shawl over you both. This is the strongest tool you have.'),
              PpStep("If you're running out of patience, lay your baby down "
                  'safely',
                  'On the back in the cot, and step out for five minutes. '
                  'See "When the crying will not stop".'),
            ], heading: 'The sequence, in order'),
            PpCards([
              PpCard('White noise and a fan',
                  'A steady hum, roughly as loud as a shower, at a distance. '
                  'Not right beside the ear.'),
              PpCard('A warm bath',
                  'Works well for the evening crying window, if your baby '
                  'likes water.'),
              PpCard('A walk outside',
                  'Air, movement and a change of light settle many babies '
                  'within minutes.'),
              PpCard('A wrap or a sling',
                  'Upright against your chest, hands free. Often the only thing '
                  'that works through cluster feeding hours.'),
              PpCard('One thing at a time',
                  'Bouncing plus singing plus patting plus a rattle is more '
                  'noise, not more comfort.'),
            ], heading: 'What else helps', hue: 268),
            PpWhenLine('Most useful from birth to about 4 months, when crying '
                'naturally eases.'),
            PpCallout("Holding a newborn too much isn't possible. Being held "
                "is how a baby's nervous system learns to calm itself later."),
            PpIndiaNote('Everybody in the house will have a technique, and '
                "they'll all take turns on the same crying baby. Being "
                'passed between six people is itself too much. Let one '
                'person hold the baby for a full ten minutes before handing '
                'over.'),
            PpCallout(
              'Crying that is shrill, weak, or completely inconsolable for '
              "hours isn't a soothing problem. Nor is crying with a fever, "
              'vomiting, a swollen tummy or refused feeds. Call a doctor.',
              kind: PpCalloutKind.doctor,
              title: "When soothing isn't the answer",
            ),
          ],
        ),
        PpPage(
          id: 'f40_jhula',
          title: 'Carrying your baby, and the cloth swing',
          subtitle: 'Wraps, carriers and the traditional cloth swing (jhula), done '
              'safely.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Carrying your baby against you is one of the most '
                'practical things you can do in these weeks. Your baby '
                'settles, you get your hands back, and cluster feeding '
                'evenings become bearable. The one thing that matters is the '
                'airway.'),
            PpVideoSlot(
              title: 'Wrapping and carrying your baby safely',
              subtitle: 'A cloth wrap, a soft carrier, and the traditional '
                  'cloth swing, with the airway checks shown.',
              minutes: '9 MIN',
              slotId: 'first40/jhula_demo',
            ),
            PpSteps([
              PpStep('High and upright, close enough to kiss',
                  "Your baby's head should be at your chest level, not down "
                  "at your waist. If you can't kiss the top of the head, "
                  'your baby is too low.'),
              PpStep('Chin off the chest, always',
                  'A curled chin closes a newborn airway silently. Two '
                  'fingers should always fit under the chin.'),
              PpStep('Face visible and clear of fabric',
                  'Nothing over the face. No hood pulled across, no dupatta, '
                  'no shawl covering the nose.'),
              PpStep('Back supported in a gentle curve',
                  "The wrap firm enough that your baby can't slump into a C "
                  'shape. Snug, not loose.'),
              PpStep('Knees higher than the bottom, legs in an M',
                  'Thighs supported, hips spread. Never dangling straight down '
                  'from the crotch, which is what narrow-based carriers do.'),
              PpStep('Check your baby every few minutes at first',
                  'Especially if your baby falls asleep, and especially in '
                  "the first weeks. A quiet baby in a carrier isn't always a "
                  'fine one.'),
              PpStep('Learn it sitting on a bed',
                  'Practise the wrap over a soft surface until your hands know '
                  'it.'),
            ], heading: 'The safety checks, every time'),
            PpCallout(
              'The five things to check every time are the airway, the '
              'position, the height on your chest, the back support and the '
              'hips. If you only remember one: chin off chest, face '
              'uncovered, close enough to kiss.',
              kind: PpCalloutKind.key,
            ),
            PpCards([
              PpCard('A long cloth wrap',
                  'Cheapest and most adjustable, and the closest thing to what '
                  'our mothers used. Takes practice.'),
              PpCard('A soft structured carrier',
                  "Quick to put on. Check it's rated for newborn weight and "
                  'has a wide base for the thighs.'),
              PpCard('A ring sling',
                  'Good for quick ups and downs and for feeding on the move. '
                  'One shoulder, so less comfortable for long stretches.'),
              PpCard('The traditional cloth swing',
                  'Fine for supervised naps if your baby lies flat on a firm '
                  'base with nothing padded underneath. Not for unattended '
                  'sleep and not in a deep hammock curl.'),
              PpCard('Skip narrow-based hanging carriers',
                  'The kind where the legs dangle straight down with no '
                  'thigh support. Bad for the hips and bad for the back.'),
            ], heading: 'What to carry your baby in', hue: 268),
            // REQUIRED_REVIEW: the two-finger airway gap, the "close enough to
            // kiss" height rule, and whether we should name the TICKS acronym
            // explicitly for parents who have been taught it.
            PpWhenLine('From birth, with newborn-safe positioning, and on '
                'through the first year. Front carrying only until your baby '
                'can hold the head steady.'),
            PpIndiaNote('The cloth swing and the cradle are good at settling a baby. '
                "The risk is never the swinging; it's the shape and the "
                'padding. Firm flat base, nothing soft underneath, no '
                'pillow, and someone in the room. Never tie a sheet hammock '
                'between two points and leave your baby in it.'),
            PpCallout(
              'Take your baby out of the carrier at once if the '
              'lips or face look dusky, or breathing sounds strained or '
              'grunting. The same if the chin is pressed to the chest and '
              "doesn't lift when you reposition. Or if your baby is limp and "
              'unusually quiet. Then call your doctor or go to the nearest hospital.',
              kind: PpCalloutKind.doctor,
              title: 'Signs to act on at once',
            ),
          ],
        ),
        PpPage(
          id: 'f40_skin_to_skin',
          title: "Skin to skin, and why it's worth the trouble",
          subtitle: 'The most useful twenty minutes of your day.',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Holding your baby undressed against your bare chest '
                "sounds like a nice idea. It's also one of the best-proven "
                'things in newborn care. It steadies temperature, breathing '
                'and heart rate, and it helps your milk.'),
            PpSteps([
              PpStep('Warm the room first',
                  'Your baby will be in just a nappy. Close the windows and '
                  'switch off the fan overhead.'),
              PpStep('Undress your baby to the nappy, and open your top',
                  'Bare chest to bare chest. A cap if the room is cool.'),
              PpStep("Lie back slightly, don't sit bolt upright",
                  "Semi-reclined, your baby's whole front against you, head "
                  'turned to one side.'),
              PpStep('Cover you both with a shawl or blanket',
                  'Over the back, never over the face. The head stays out '
                  'and visible.'),
              PpStep('Check the position',
                  'Chin up and off the chest, nose and mouth clear, '
                  'breathing quiet and easy.'),
              PpStep('Stay for twenty minutes or more',
                  'Short bursts help; longer is better. Let your baby doze, '
                  'root around and feed if wanted.'),
              PpStep("Don't do it if you might fall asleep",
                  "If you're that tired, hand your baby to someone who is "
                  'awake, or use the cot.'),
            ], heading: 'How to do it'),
            PpCards([
              PpCard('It steadies the body',
                  'Temperature, heart rate, breathing and blood sugar all '
                  'settle against your chest.'),
              PpCard('It helps feeding',
                  'Babies latch better after skin contact, and it lifts the '
                  'hormones that make milk.'),
              PpCard('It calms crying',
                  'Often the only thing that works during the evening hours.'),
              PpCard('Fathers count fully',
                  'Every benefit except milk applies to the father, the '
                  "grandmother, anyone who holds the baby. It's the easiest "
                  'way for a father to be really useful in week one.'),
              PpCard('It matters most for small babies',
                  'For premature or low birth weight babies this is real '
                  'medical care, and hospitals prescribe hours of it a day.'),
            ], heading: 'What it does', hue: 268),
            PpWhenLine('From the first hour after birth, ideally daily through '
                'the first weeks, and useful for months afterwards.'),
            PpIndiaNote('It can feel odd to sit half undressed in a full '
                "house, and that's usually the only reason it doesn't "
                'happen. Ask for the bedroom and twenty minutes with the '
                "door shut. It's a small thing to ask, and it does more than "
                'most of what anyone else does that day.'),
            PpCallout(
              'If your baby was born early or small, ask the hospital about '
              "kangaroo mother care. It's a structured version of this with "
              'real measured benefits, and the staff will show you how to do '
              'long stretches safely.',
              kind: PpCalloutKind.doctor,
              title: 'For a small or premature baby',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  6. Is My Baby OK? — the light check, and when to escalate
    // -------------------------------------------------------------------------
    //  ⚠️ THE POINT OF THIS AREA IS WHAT IT DOES NOT DO. No ml logging, no
    //  feed timer as the default, no caregiver dashboard, no streaks. The spec
    //  is explicit that the India-fit answer to "is he getting enough" is four
    //  reassuring checks, and that the full trackers are an ESCALATION for the
    //  minority who genuinely need them. The full feed and growth trackers are
    //  LIVE already and are linked, never rebuilt.
    // =========================================================================
    PpArea(
      id: 'baby_ok',
      mark: IntentMark.compassMark,
      title: 'Is My Baby OK?',
      blurb: 'A thirty-second check, and the trackers if you ever need more.',
      hue: 152,
      pages: [
        PpPage(
          id: 'f40_light_check',
          title: 'The quick daily check',
          subtitle: 'Four things. Nothing to log, nothing to keep up with.',
          format: 'CHART-CARD',
          blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'The ten-second check',
          subtitle: "Breathing, colour, feeding, nappies. What you're "
              'looking at, shown on a real newborn.',
          minutes: '4 MIN',
          slotId: 'first40/quick_check',
        ),
            PpIntro("You don't need to record every feed to know your baby "
                'is fine. Four quick checks a day answer almost every '
                'newborn worry, and the rest of the day you can just hold '
                'your baby.'),
            PpChartCard(
              title: 'The four checks',
              // REQUIRED_REVIEW: all four thresholds. 6 or more wet nappies a
              // day from day 5; weight back to birth weight by day 14 and 150
              // to 200 g a week after; jaundice reaching palms and soles as the
              // escalation point; and not letting a newborn go beyond 3 hours
              // by day or 4 by night in the first two weeks.
              rows: [
                ('Wet nappies', '6 or more a day from day 5'),
                ('Weight', 'Back to birth weight by day 14, then rising'),
                ('Yellow', 'Fading, and not on palms or soles'),
                ('Feeds', '8 to 12 a day, and your baby wakes for them'),
              ],
              note: 'All four looking fine means your baby is fine, even on '
                  'a day of hours of crying.',
              hue: 152,
            ),
            PpCards([
              PpCard('Wet nappies, counted roughly',
                  "You're looking for a pattern, not an exact total. Six "
                  'fairly wet nappies with pale urine is the mark.'),
              PpCard('Weight, once a week at most',
                  'Weighing daily only feeds your own worry. The trend over '
                  'weeks is what matters.'),
              PpCard('Yellow, checked in daylight',
                  'Press the forehead or nose and look as the colour '
                  'returns. Face only is usually mild.'),
              PpCard('A sleepy feeder needs waking',
                  "In the first two weeks, don't let your baby go more than "
                  '3 hours in the day or 4 at night without a feed.'),
            ], heading: 'How to do each one', hue: 152),
            PpLink('Open the quick check',
                surfaceId: 'pp_baby_ok_check',
                blurb: 'Tap through the four checks and see whether anything '
                    'needs a call.'),
            PpWhenLine('Once a day through the first fortnight is plenty. After '
                'that, only when something feels off.'),
            PpCallout("There's no score here, no streak, and nothing that "
                'notices if you skip a day. This is a reassurance tool, not '
                'a record you have to keep.'),
            PpCallout(
              "If any one of the four checks is off, that's the moment to "
              'call. Fewer wet nappies, no weight gain, deepening yellow, or '
              "a baby who won't wake to feed each need a doctor the same "
              'day, not a wait and see.',
              kind: PpCalloutKind.doctor,
              title: "When a check doesn't look right",
            ),
          ],
        ),
        PpPage(
          id: 'f40_escalate',
          title: 'When to start logging properly',
          subtitle: 'The full trackers, and the few reasons to open them.',
          format: 'CARDS',
          blocks: [
            PpIntro('Detailed feed and weight logging is useful for a small '
                "number of babies, and extra work for everybody else. Here's "
                'where the line is.'),
            PpCards([
              PpCard('Weight gain is slower than expected',
                  'Not back to birth weight by two weeks, or a flat weight '
                  'after that. A feed log makes the pattern visible to a '
                  'doctor.'),
              PpCard('Born early, small, or a twin',
                  'These babies are often sleepy feeders and need feeds counted '
                  'rather than trusted.'),
              PpCard('Jaundice is being followed',
                  'Feeds and stools are part of how it clears, and your doctor '
                  'will ask.'),
              PpCard("Feeding isn't working yet",
                  'Cracked nipples, a shallow latch, top-ups, or a baby who '
                  'feeds for an hour and wakes hungry.'),
              PpCard('A doctor has asked you to',
                  'Then log exactly what the doctor asked for, and only '
                  'that.'),
              PpCard("You'd like to",
                  'Some parents find it calming to see it written down. '
                  "That's a perfectly good reason, and you can stop any "
                  'time.'),
            ], heading: 'Reasons to switch it on', hue: 152),
            PpLink('The full feed log',
                surfaceId: 'pp_feeding',
                blurb: 'Times, sides, top-ups and nappies, if you want the '
                    'detail.'),
            PpLink('Weight and growth',
                surfaceId: 'pp_growth',
                blurb: 'Plot weight, length and head size, and see the '
                    'curve.'),
            PpLink("Sleep, if you're being asked about it",
                surfaceId: 'pp_sleep',
                blurb: 'Useful mostly when a doctor wants the pattern.'),
            PpWhenLine('Switch it on when one of the reasons above applies, and '
                'switch it off again when the worry has passed.'),
            PpCallout('Logging is off by default and stays off unless you turn '
                'it on. Nothing in this app will tell you off for a gap in a '
                'log, and no chart here is a report card.'),
            PpConsult(
              title: 'Talk to a Newborn Expert',
              whoFor: "For slow weight gain, feeding that isn't working, or "
                  "a sleepy baby you have to wake for every feed. If you've "
                  'kept a feed log, share it before the call, so the expert '
                  'starts with the facts, not your memory of a hard week.',
              surfaceId: 'pp_experts',
              role: 'lactation',
            ),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  7. Maa Ki Dekhbhaal — the mother's immediate first weeks
    // -------------------------------------------------------------------------
    //  ⚠️ BOUNDARY, ENFORCED HERE. Immediate recovery essentials only. Ongoing
    //  and deeper recovery links to "You, Maa" (`pp_you_maa`). The mood page
    //  below is deliberately NOT a screening questionnaire and carries NO paid
    //  block: it names what she may be feeling, then routes her to a person.
    // =========================================================================
    PpArea(
      id: 'maa_ki_dekhbhaal',
      mark: IntentMark.lotusMark,
      title: 'Your Recovery: Healing After Birth',
      blurb: 'Your body in these first weeks, and what needs attention.',
      hue: 330,
      pages: [
        PpPage(
          id: 'f40_lochia',
          title: "Your bleeding: what's normal",
          subtitle: 'How much, how long, and how much is too much.',
          format: 'ARTICLE',
          // ⚠️ A WINDOW INTO YOU, MAA, NOT A COPY (judgement call 1 of the
          // You brief, the user's call 2026-09-13): the bleeding is written once, there.
          // The page opens the canonical one; its own copy is kept below.
          toolSurfaceId: 'pp_page/parenting_maternal/body_lochia',
          blocks: [],
          /* kept for revert
          blocks: [
            PpIntro('Bleeding after birth is heavier and longer than most '
                'women expect, and it happens after a caesarean too. Knowing '
                'its normal shape makes the one dangerous version easy to '
                'spot.'),
            PpVideoSlot(
              title: 'Your body in the first weeks',
              subtitle: 'Bleeding, stitches, the caesarean scar, and what '
                  'rest is for.',
              minutes: '9 MIN',
              slotId: 'first40/recovery_basics',
            ),
            PpChartCard(
              title: 'The usual course',
              // REQUIRED_REVIEW: the lochia timeline (bright red days 1 to 4,
              // pink or brown to about day 10, then pale for up to 6 weeks) and
              // the total 4 to 6 week duration.
              rows: [
                ('Days 1 to 4', 'Bright red and heavy, some clots'),
                ('Days 5 to 10', 'Pink or brown, lighter'),
                ('Day 10 to 6 weeks', 'Pale, yellowish, then stops'),
                ('Clots', 'Small ones are normal, especially in the morning'),
                ('After a caesarean', 'The same, usually a little lighter'),
                ('A gush on standing', 'Normal. Pooling while you were lying '
                    'down'),
              ],
              note: 'Bleeding that gets heavier, or turns bright red again '
                  "after it had settled, usually means you're doing too "
                  'much. Lie down.',
              hue: 330,
            ),
            PpCards([
              PpCard('Use pads, not tampons or a cup',
                  "Nothing inside for at least six weeks. It's an infection "
                  'risk while the wound inside is healing.'),
              PpCard('Change every four to six hours',
                  "More often at first. It's also how you keep track of how "
                  "much you're losing."),
              PpCard('Wash front to back with plain water',
                  'A mug of warm water while you pass urine takes the sting '
                  'away. Pat dry rather than rubbing.'),
              PpCard('Expect a smell like a period',
                  'Faint and metallic is fine. Strongly foul is not.'),
              PpCard('Rest is the real treatment',
                  'Every extra hour on your feet in week one shows up as more '
                  'bleeding that evening.'),
            ], heading: 'Looking after yourself', hue: 330),
            PpCallout(
              "Go to hospital now if you're soaking a full pad in an hour or "
              'less, or two pads in two hours. The same for clots bigger '
              'than a lemon, or several large clots. Go if you feel faint, '
              'breathless, or your heart is racing, or the bleeding suddenly '
              'turns bright red and heavy again. Go too for a foul-smelling '
              'discharge with a fever. Heavy bleeding after birth '
              "(postpartum haemorrhage) is an emergency, and it's treatable "
              'when you get there in time.',
              kind: PpCalloutKind.doctor,
              title: 'Bleeding that is an emergency',
            ),
            // REQUIRED_REVIEW: the haemorrhage thresholds above. One full pad
            // soaked in an hour or less, two pads in two hours, and clots
            // larger than a lemon. Obstetrician to confirm the wording and the
            // clot size comparison we use.
            PpWhenLine('Bleeding normally lasts 4 to 6 weeks and reduces the '
                'whole way through. Anything that increases needs a call.'),
            PpIndiaNote('Cloth is still often used instead of pads. If you '
                'use cloth, it must be clean, dried in full sunlight and '
                'changed as often as a pad would be. It also makes judging '
                'the amount much harder. In the first week, pads are worth '
                'the money for that reason alone.'),
          ],
          */
        ),
        PpPage(
          id: 'f40_after_normal_delivery',
          title: 'After a normal delivery',
          subtitle: 'Stitches, soreness, and the first trip to the toilet.',
          format: 'ARTICLE',
          // ⚠️ A WINDOW INTO YOU, MAA, NOT A COPY (judgement call 1 of the
          // You brief, the user's call 2026-09-13): stitches and sitting down, once, there.
          // The page opens the canonical one; its own copy is kept below.
          toolSurfaceId: 'pp_page/parenting_maternal/body_perineum',
          blocks: [],
          /* kept for revert
          blocks: [
            PpIntro('If you tore or were cut, the stitches will be sore for '
                'about two weeks and then improve fast. Almost everything '
                'that helps is easy, and the first few days are the worst of '
                'it.'),
            PpArticle([
              'Sitting down, standing up, coughing and passing urine will all '
              'sting at first. Stitches dissolve on their own and nobody needs '
              'to remove them. The soreness peaks around day two or three and '
              'is usually much better within a fortnight.',
              'The first bowel movement is the thing most women dread, and '
              "it really is fine. The stitches won't tear. Water, fibre and "
              'a stool softener if your doctor agrees make it a non-event.',
            ]),
            PpSteps([
              PpStep('Pour warm water while you pass urine',
                  'A mug or a bottle. It dilutes the urine and takes most of '
                  'the sting away.'),
              PpStep('Pat dry, front to back, every time',
                  "Clean and dry is what prevents infection. Don't rub."),
              PpStep('Sit on something soft, or on your side',
                  'A folded towel or a cushion. Feeding lying down for the '
                  'first days saves you a lot of sitting.'),
              PpStep('Cold, then warm',
                  'A cold pack wrapped in cloth for ten minutes helps swelling '
                  'in the first two days. A warm sitz bath helps after that.'),
              PpStep('Take the painkillers you were given',
                  'Paracetamol and the ones prescribed are safe while '
                  'breastfeeding. Gritting your teeth through pain helps '
                  'nobody; it stops you resting and feeding.'),
              PpStep('Drink and eat for your bowels',
                  'Water all day, fruit, and something with fibre. Ask about a '
                  'stool softener if it has been three days.'),
              PpStep('Start gentle pelvic floor squeezes when it is comfortable',
                  'A few, several times a day. They speed up healing and '
                  'help with leaking.'),
            ], heading: 'What helps'),
            PpWhenLine('Worst for 3 to 5 days, much better by two weeks, fully '
                'healed by about six.'),
            PpCallout(
              'See your doctor if the pain is getting worse rather than '
              'better after day three or four. The same if the stitch line '
              "is hot, hard, swollen or oozing, or there's a foul-smelling "
              "discharge or a fever. Go too if you can't pass urine or can't "
              'control it, or feel a bulge or heaviness at the opening.',
              kind: PpCalloutKind.doctor,
              title: 'Stitches that need checking',
            ),
            PpIndiaNote('Squatting toilets are hard on fresh stitches. Use a '
                "western toilet if there's one in the house for the first "
                'two weeks, or a stool to raise your feet. Ask for it '
                "plainly; it isn't fussiness."),
            PpLink('Pelvic floor, and the longer recovery',
                surfaceId: 'pp_you_maa',
                blurb: 'Leaking, heaviness, core strength and what comes after '
                    'these weeks.'),
          ],
          */
        ),
        PpPage(
          id: 'f40_after_csection',
          title: 'After a C-section',
          subtitle: 'Your first weeks with a fresh scar.',
          format: 'ARTICLE',
          // ⚠️ A WINDOW INTO YOU, MAA, NOT A COPY (judgement call 1 of the
          // You brief, the user's call 2026-09-13): the C-section weeks, once, there.
          // The page opens the canonical one; its own copy is kept below.
          toolSurfaceId: 'pp_page/parenting_maternal/body_csection_early',
          blocks: [],
          /* kept for revert
          blocks: [
            PpIntro("A caesarean is major abdominal surgery, and you've been "
                'sent home to look after a newborn while recovering from it. '
                'Almost every ache in these weeks is normal, and the limits '
                'exist for a reason.'),
            PpArticle([
              'The wound closes in a week or two but the layers underneath take '
              'months. Numbness, itching, tugging, a shelf above the scar and '
              'sharp twinges when you twist are all ordinary and often carry on '
              'for months.',
              'Moving is encouraged, lifting is not. Short slow walks around the '
              'house from day one reduce your risk of clots and help your '
              'bowels. Carrying anything heavier than your baby does not.',
            ]),
            PpSteps([
              PpStep('Support your tummy when you cough, laugh or sneeze',
                  'A hand or a folded towel pressed over the scar. It hurts far '
                  'less.'),
              PpStep('Roll to your side to get up',
                  'Bend your knees, roll, push up with your arms. Never sit '
                  'straight up from flat.'),
              PpStep('Walk a little, often',
                  'Short slow walks from the first day, increasing gradually. '
                  'Stop if it pulls.'),
              PpStep('Keep the scar clean and dry',
                  'A daily shower after your doctor allows it, pat dry, and '
                  'leave it open to the air. No oil, no haldi, no powder on the '
                  'wound.'),
              PpStep('Feed lying down or with a rugby hold',
                  "A pillow across your lap keeps your baby's weight off the "
                  'scar.'),
              PpStep('Lift nothing heavier than your baby',
                  'For at least six weeks. Not the toddler, not a bucket, not '
                  'a suitcase.'),
              PpStep('Take the pain relief on time',
                  'Not only when it becomes unbearable. The prescribed ones are '
                  'compatible with breastfeeding.'),
            ], heading: 'The first six weeks'),
            PpWhenLine('Wound closed in 1 to 2 weeks, no heavy lifting for 6 '
                'weeks, no driving until you can brake hard without flinching. '
                'Deeper healing continues for months.'),
            PpCallout(
              "Go in today if the scar is red, hot, hard or swollen, or it's "
              'oozing or opening. The same for a fever, or pain that is '
              "suddenly much worse. Go too if you're breathless or your "
              'chest hurts, or one calf becomes painful, swollen, hot or '
              'red. The last two can mean a clot and are an emergency.',
              kind: PpCalloutKind.doctor,
              title: 'Caesarean signs that need a doctor now',
            ),
            // REQUIRED_REVIEW: the six-week no-heavy-lifting limit, and the
            // clot warning signs (calf pain, breathlessness, chest pain) as
            // presented here.
            PpIndiaNote('Two things get pushed on caesarean mothers in '
                'Indian homes: a tight belly binder and an early full round '
                'of house visits. A binder can feel supportive for a few '
                "hours a day if your doctor agrees. It doesn't flatten your "
                "stomach, and it must never be tight. And you're allowed to "
                'say no to the stairs, the kitchen and the crowd for six '
                'weeks.'),
            PpLink('Rebuilding your core, later',
                surfaceId: 'pp_you_maa',
                blurb: 'Scar massage, core work and movement, once you are '
                    'cleared.'),
          ],
          */
        ),
        PpPage(
          id: 'f40_rest_and_food',
          title: 'Rest, water and the food of the forty days',
          subtitle: 'What helps you heal, and what is only tradition.',
          format: 'ARTICLE',
          blocks: [
            PpIntro('The food of the forty days is one of the things our families get most '
                'right. Warm, easy, filling meals cooked by someone else are '
                "exactly what you need when you're feeding every two hours."),
            PpArticle([
              'Breastfeeding costs you roughly a small extra meal a day in '
              'energy, and it makes you thirsty like nothing else. Eating '
              'enough matters more than eating perfectly. Skipping meals to '
              'lose weight in these weeks is the one really bad idea.',
              'Nobody needs to eat only bland food, and in most babies '
              'nothing you eat causes colic. Have your usual food, warm and '
              'cooked. If you clearly see the same reaction twice to one '
              'food, mention it rather than cutting out half your diet.',
            ]),
            PpCards([
              PpCard('Traditional sweets: edible gum, roasted flour (panjiri), fenugreek',
                  'Energy dense, easy to eat one-handed at 3am, and traditional '
                  'for good reason. One or two a day, not a plateful.'),
              PpCard('Carom, cumin and fennel water',
                  'Warm and comforting, and they help wind and digestion. '
                  'Harmless and soothing.'),
              PpCard('Herbal brew and turmeric milk',
                  'Warm and comforting. Keep the herbal brew (kadha) mild, and mention any '
                  "strong herbal mixture to your doctor if you're on "
                  'medication.'),
              PpCard('Protein at every meal',
                  'Dal, curd, paneer, eggs, chicken or fish. Most forty-day '
                  'diets are light on this, and it matters most for healing.'),
              PpCard('Iron and calcium, as prescribed',
                  'Keep taking them. Blood loss and breastfeeding both draw on '
                  'your stores, and low iron is why so many mothers feel '
                  'permanently flattened.'),
              PpCard('Water beside every feed',
                  'Thirst hits hardest during letdown. A bottle where you '
                  'feed is the easiest fix in this whole app.'),
            ], heading: 'What helps', hue: 330),
            PpCallout(
              "A few food beliefs of the forty days are worth setting aside. You don't "
              "need to restrict water. Bland food isn't required. Ghee alone "
              "doesn't heal stitches. No food will make your milk thin, and "
              'no single food will make more of it: frequent feeding does '
              'that. Alcohol and smoking are the real things to avoid. Check '
              'any medicine, even ayurvedic, before you take it while '
              'feeding.',
              kind: PpCalloutKind.myth,
              title: 'What you can let go of',
            ),
            PpSteps([
              PpStep('Sleep when your baby sleeps, at least once a day',
                  'One deliberate nap. Put the phone down and lie flat.'),
              PpStep('Give away one job today',
                  'The dishes, the door, the visitors, the older child. Name it '
                  'and hand it over.'),
              PpStep('Eat before you feed, not after',
                  "Once your baby latches, you won't get up again."),
              PpStep('Keep a tray beside your feeding spot',
                  'Water, a sweet or some fruit, and your phone charger. Restock it '
                  'each night.'),
              PpStep('Say no to one visitor this week',
                  "You don't need a reason, and you won't remember their "
                  'disappointment.'),
            ], heading: 'Protecting your own rest'),
            PpWhenLine('Most important through the first 6 weeks, and worth '
                "keeping up for as long as you're feeding."),
            PpIndiaNote("If you're fed well but a stream of guests keeps you "
                "from sleeping, the food isn't the part that's failing. Rest "
                "is the harder half of the forty days to ask for, and it's the half "
                'that decides how the next month feels.'),
            PpLink('Food and recipes',
                surfaceId: 'pp_food',
                blurb: 'Warm, simple, one-handed meals and recipes for the forty days.'),
          ],
        ),
        PpPage(
          id: 'f40_recovery_red_flags',
          title: 'When to call your own doctor',
          subtitle: 'The signs in you that are more than tiredness.',
          format: 'FLAGGED QUICK-REFERENCE',
          blocks: [
            PpIntro('Everyone is watching the baby, including you. These are '
                'the signs in your own body that need a doctor rather than '
                "more rest. Don't sit any of them out politely."),
            PpTable(
              heading: 'Call, or go in',
              columns: ['If you have this', 'What to do'],
              rows: [
                [
                  'Soaking a pad in an hour or less, or clots bigger than a '
                  'lemon',
                  'Go now.',
                ],
                [
                  'Fever, or shaking chills',
                  'Call today.',
                ],
                [
                  'Foul-smelling discharge, or pain low in the belly that is '
                  'getting worse',
                  'Call today.',
                ],
                [
                  'A hard, red, hot painful patch on the breast with a fever '
                  'and body ache',
                  'Call today. Keep feeding from that side meanwhile.',
                ],
                [
                  'Pain, swelling, heat or redness in one calf',
                  'Go now. This can be a clot.',
                ],
                [
                  'Breathlessness, chest pain, or a racing heart',
                  'Go now.',
                ],
                [
                  'A severe headache, blurred vision, flashing lights, or '
                  'swelling of the face and hands',
                  'Go now. Blood pressure can rise after delivery too.',
                ],
                [
                  'A fit, or fainting',
                  'Go now.',
                ],
                [
                  'A stitch line or scar that is hot, opening, or oozing',
                  'Call today.',
                ],
                [
                  "Can't pass urine, or can't control it at all",
                  'Call today.',
                ],
                [
                  'Thoughts of harming yourself or the baby',
                  "Tell someone today. This is urgent, and it's treatable.",
                ],
              ],
            ),
            // REQUIRED_REVIEW: the maternal thresholds on this page. Fever at
            // 100.4 F / 38 C, the haemorrhage pad rate, the pre-eclampsia
            // warning signs and the window in which postpartum blood pressure
            // problems can still occur. Obstetrician to confirm.
            PpChartCard(
              title: 'The numbers for you',
              rows: [
                ('Fever', '100.4 F or 38 C and above'),
                ('Bleeding', 'A full pad soaked in an hour or less'),
                ('Blood pressure', 'Get it checked if you have a bad headache '
                    'or blurred vision'),
              ],
              note: 'Problems after birth are treatable, and timing matters. '
                  'Being seen and sent home is a good outcome, not a wasted '
                  'trip.',
              hue: 330,
            ),
            PpWhenLine('Most problems after birth show up in the first two '
                'weeks, and some can appear up to six weeks after birth.'),
            // Added 2026-10-02 from the parenting gap analysis (P1, ADD TO
            // OURS: What to Expect's postpartum preeclampsia piece).
            PpArticle(heading: 'High blood pressure after the birth', [
              'Pre-eclampsia is usually thought of as a pregnancy problem. '
                  'It can also start after the birth, even if your blood '
                  "pressure was normal all through pregnancy. It's most "
                  'common in the first week, and can happen up to six weeks '
                  'later.',
              "The signs are a bad headache that won't go away, blurred "
                  'vision or flashing lights, or sudden swelling of the face '
                  'or hands. Also pain under the ribs on the right, and '
                  'feeling breathless. These need a hospital the same day, '
                  "not rest. It's very treatable when caught early.",
            ]),
            PpCallout("You're a patient too, for at least six weeks. If "
                "something in your body feels wrong, you don't have to wait "
                'until the baby has been seen to first.'),
            PpIndiaNote("There's real pressure to be uncomplaining in the forty days. "
                "New mothers who say they're unwell are often told to rest "
                'and drink something warm. If you have a symptom on this '
                'list, tell a doctor directly rather than the room.'),
          ],
        ),
        PpPage(
          id: 'f40_not_yourself',
          title: "If you don't feel like yourself",
          subtitle: "What's common, what's more than that, and who to tell.",
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Your body, your sleep and your whole day have just been '
                'rearranged. Feeling weepy, flat, frightened or strangely '
                "empty is very common in these weeks, and it's not a flaw in "
                'you.'),
            PpArticle([
              'Most mothers get a few days of tearfulness and mood swings in '
              'the first week or two, often as the milk comes in. It comes '
              "in waves, it lifts, and it doesn't stop you from coping with "
              'the day.',
              "A low mood, numbness or anxiety that settles in and doesn't "
              'lift is different. It may be postnatal depression or anxiety '
              "if it's there most of the day for more than a couple of "
              'weeks. The same if it makes caring for yourself or your baby '
              "hard. It's very common, and it responds well to help.",
              "There's nothing here to score and no test to take. An app "
              "isn't assessing you. The one thing worth doing is telling one "
              'real person: your doctor, your husband, your mother, a friend '
              'who will keep asking.',
            ]),
            PpCards([
              PpCard('Worth mentioning to your doctor',
                  'Crying most days after week two, not sleeping even when '
                  'your baby sleeps, no appetite, constant dread, feeling '
                  'cut off from your baby, or feeling nothing.'),
              PpCard('Rage and irritability count too',
                  "Postnatal depression doesn't always look like sadness. "
                  'Snapping, fury and feeling always on edge are just as '
                  'common and just as treatable.'),
              PpCard('Frightening thoughts happen',
                  'Sudden unwanted pictures of something bad happening to '
                  'your baby are very common, and horrible to have. They '
                  "aren't a sign you'll act. Say them out loud to a doctor."),
              PpCard("Treatment doesn't mean stopping feeding",
                  "Some options work alongside breastfeeding. That's a "
                  'conversation, not a barrier.'),
            ], heading: 'What to watch for in yourself', hue: 330),
            PpWhenLine('The early tearful days pass within two weeks. Anything '
                'still there after that, or getting heavier, is worth telling '
                'someone about.'),
            PpCallout(
              'Some things need help today, not at the six-week check. '
              'Thoughts of harming yourself or the baby, or feeling you '
              "can't keep your baby safe. Hearing or seeing things others "
              "don't, or feeling confused and unlike yourself in a way that "
              'frightens the people around you. Tell your doctor or go to a '
              'hospital today. This is treatable, and asking is the strong '
              'thing to do.',
              kind: PpCalloutKind.doctor,
              title: 'Get help today if',
            ),
            PpIndiaNote('You may hear that everyone goes through this, and '
                "that it's only weakness or the evil eye. Neither is true. If your "
                "family won't take it seriously, tell your own doctor at the "
                'next visit, or ask your husband to book the appointment for '
                'you. One appointment is usually all it takes to start.'),
            PpLink('You, the mother: your mind in the first year',
                surfaceId: 'pp_you_maa',
                blurb: 'Mood, identity, anger, therapy and what helps. The '
                    'deeper part of this lives there.'),
            PpLink('Find someone to talk to',
                surfaceId: 'pp_find_help',
                blurb: 'Doctors, counsellors and support near you.'),
          ],
        ),
        // ⚠️ [NEW], two scaffolds. "Your breasts in the early weeks" is the
        // single biggest gap in the section: engorgement, cracked nipples, a
        // blocked duct, mastitis with a same-day flag. And the honest note
        // that ovulation can return before the first period.
        // ⚠️ NOT A SCAFFOLD ANY MORE. The You brief consolidates breast
        // health into "Sore, rock hard breasts" there; this card is the
        // window into it. The engorgement, cracked nipples, blocked duct and
        // mastitis copy that page still owes is logged under You (YM3).
        PpPage(
          id: 'f40_breasts',
          title: 'Your breasts in the early weeks',
          subtitle: 'Engorgement, cracked nipples, a blocked duct, and the '
              'one that needs a doctor today.',
          format: 'FLAGGED ARTICLE',
          toolSurfaceId: 'pp_page/parenting_maternal/body_breasts',
          blocks: [],
        ),
        // ⚠️ NOT A SCAFFOLD ANY MORE. "Sex, contraception, and the two of
        // you" (You, Maa) owns the get-pregnant-again answer and already
        // says it: you can ovulate before your first period returns. This
        // card is the window into it.
        PpPage(
          id: 'f40_pregnant_again',
          title: 'When your body can get pregnant again',
          subtitle: "Sooner than the first period, and feeding isn't a "
              'method.',
          format: 'SHORT ARTICLE',
          toolSurfaceId: 'pp_page/parenting_maternal/people_intimacy',
          blocks: [],
        ),
      ],
    ),

    // =========================================================================
    //  8. Puchho ParentVeda — the 2am question
    // -------------------------------------------------------------------------
    //  Reuses Ask Veda. Nothing is rebuilt here. The page exists because a
    //  frightened parent needs to be told what the answer machine will and will
    //  not do before she leans on it at 2am.
    // =========================================================================
    PpArea(
      id: 'puchho',
      mark: IntentMark.lampMark,
      title: 'Ask ParentVeda',
      blurb: 'The 2am "is this normal" question, answered without waking '
          'anybody.',
      hue: 206,
      pages: [
        PpPage(
          id: 'f40_ask_veda',
          title: 'Ask anything, at any hour',
          subtitle: 'What it can answer, and what it hands to a doctor.',
          format: 'CARDS',
          blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'What other mothers ask in the first week',
          subtitle: 'The six questions that come up most, answered plainly.',
          minutes: '7 MIN',
          slotId: 'first40/common_questions',
        ),
            PpIntro("At 3am, with a baby doing something you've never seen "
                'before, you need an answer in your own words, not a page of '
                "search results. Type the question as you'd say it."),
            PpCards([
              PpCard('"Is it normal that my baby\'s poop is green?"',
                  'The ordinary reassurance questions are what this is best '
                  'at.'),
              PpCard('"My baby fed for an hour and is still crying"',
                  "Describe what's happening. You don't need the right "
                  'words.'),
              PpCard('"How long should the cord take to fall off?"',
                  'The small factual things nobody thought to tell you.'),
              PpCard('"Can I take this medicine while feeding?"',
                  "It tells you what's known, and when to check with your "
                  'doctor.'),
              PpCard('"What is a normal amount of bleeding on day 10?"',
                  'Your own body counts as a fair question here too.'),
            ], heading: 'The kind of thing to ask', hue: 206),
            PpLink('Open Ask ParentVeda',
                surfaceId: 'pp_ask_veda',
                blurb: 'Ask in English or Hindi, any time.'),
            PpCallout('Answers come from our own content and trusted medical '
                'sources, never from what other parents post in the '
                'community. When the honest answer is "this needs a doctor", '
                "that's what it says."),
            PpCallout(
              'It will never diagnose your baby, never tell you to skip a '
              'hospital visit, and never contradict your own doctor. '
              'Anything that looks like a red flag goes straight to "When to '
              'Rush to the Doctor" and to a human.',
              kind: PpCalloutKind.doctor,
              title: "What it won't do",
            ),
            PpWhenLine('Open at any hour, and most used between midnight and '
                "4am, which is what it's for."),
            PpIndiaNote('Ask in the language you think in. Hindi questions '
                "get Hindi answers, and you can mix the two the way you'd "
                'talk to a friend.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  9. The Jaapa Course — the hero, surfaced honestly
    // -------------------------------------------------------------------------
    //  ⚠️ REUSES `pp_courses`. The page's job is to be honest enough that a
    //  mother who does not need it can tell. Everything clinical in the course
    //  is also free in this section, and the page says so out loud, because the
    //  alternative is selling to the parent whose problem the free page above
    //  already solved.
    // =========================================================================
    PpArea(
      id: 'jaapa_course',
      mark: IntentMark.improveMark,
      title: 'The First 40 Days Course',
      blurb: 'The First 40 Days, taught in full, if you want it all in one '
          'place.',
      hue: 86,
      pages: [
        PpPage(
          id: 'f40_course',
          title: 'The First 40 Days course',
          subtitle: "What's inside, what it costs, and who doesn't need it.",
          format: 'CARDS',
          blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'What the First 40 Days course covers',
          subtitle: 'A look at the whole forty days before you decide if '
              "it's for you.",
          minutes: '3 MIN',
          slotId: 'first40/course_preview',
        ),
            PpIntro('A digital version of the traditional forty days: the whole first forty days taught in '
                'order, by people who do this for a living. Most families '
                "can't find a well-informed postnatal helper, and those who can "
                'often get the folk practices along with the good parts.'),
            PpCards([
              PpCard('Newborn care, dos and don\'ts',
                  'Cord, bath, nappies, skin, sleep and safety, with the myths '
                  'named and settled.'),
              PpCard('Feeding, from the first latch',
                  'Latch, supply, cluster feeding, expressing, and mixed '
                  'feeding without guilt.'),
              PpCard('Massage, soothing and carrying',
                  'Filmed clearly, so you can copy it rather than guess from '
                  'a diagram.'),
              PpCard('Your own recovery',
                  'Normal delivery and caesarean, bleeding, food, rest, mood, '
                  'and when to call.'),
              PpCard("What a baby's brain needs",
                  'A module on early brain development that sticks to what '
                  'is supported: talking, holding, responding, feeding, '
                  "sleep. It isn't a flashcard programme, and it won't "
                  'promise a genius baby, because nothing can.'),
              PpCard('Handling the house',
                  'Visitors, advice, joint family negotiations and the scripts '
                  'that end an argument politely.'),
            ], heading: "What's inside", hue: 86),
            PpChartCard(
              title: 'What it costs',
              rows: [
                ('The course', 'Rs 1,499'),
                ('Usual price', 'Rs 2,999'),
                ('A live-in postnatal helper, 40 days', 'Rs 20,000 to 35,000'),
                ('Access', 'Yours to keep, watch in any order'),
                ('Language', 'Hindi and English'),
              ],
              note: 'Priced against what it replaces, not against other apps.',
              hue: 86,
            ),
            PpCallout('Everything medical in the course is also free in this '
                'section, and always will be. The red flags, the how-tos, the '
                'trackers and the reading are never behind a payment. The '
                'course is the same material taught in order, on video, with '
                'the parts nobody writes down.'),
            PpLink('See the course',
                surfaceId: 'pp_courses',
                blurb: 'Watch the free first lesson before you decide.'),
            PpWhenLine('Most useful in the last weeks of pregnancy or the first '
                'fortnight after birth. It stays available afterwards.'),
            PpIndiaNote('If a postnatal helper is already coming, the course helps '
                "you tell which advice to follow. That's what most families "
                'use it for.'),
            PpCallout('Infant sleep, taught gently and with no sleep '
                'training, is the next course being built. It will live in '
                'the Sleep section rather than here.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  10. Jaapa Essentials — contextual commerce, never a wall
    // -------------------------------------------------------------------------
    //  ⚠️ NO PRODUCT SURFACE ANYWHERE NEAR THE RED FLAG PAGES OR THE RECOVERY
    //  RED FLAGS. This area is where buying decisions live, and the first page
    //  is deliberately the one that tells her what NOT to buy.
    //
    //  ⚠️ `PpProduct` HAS NO IMAGE FIELD YET, so nothing here promises a photo.
    //  These pages carry named comparisons and route to the live product and
    //  compare surfaces, which degrade to text cleanly. Image seeding is
    //  flagged in the report.
    // =========================================================================
    PpArea(
      id: 'jaapa_essentials',
      mark: IntentMark.nextStep,
      title: 'First 40 Days Essentials',
      blurb: "What's worth buying, and what you can skip.",
      hue: 300,
      pages: [
        PpPage(
          id: 'f40_what_you_need',
          title: 'What you really need',
          subtitle: 'A short list, and a longer list of things to skip.',
          format: 'CARDS',
          blocks: [
        // ⚠️ ADDED IN THE S07-S11 PASS. This area had no video at all, and
        // the doc asks for one in every sub-section - spelled out in the
        // early sections, then pointed at the prompt once it became
        // repetitive.
        PpVideoSlot(
          title: 'What you really need in the first forty days',
          subtitle: 'The short list, and the long list of things you were '
              "told to buy and won't use.",
          minutes: '5 MIN',
          slotId: 'first40/essentials',
        ),
            PpIntro('Most newborn shopping lists going round are written by '
                'people selling things. A newborn needs very little, and you '
                'need more than the lists admit.'),
            PpCards([
              PpCard('Nappies, and plenty of them',
                  'Cloth nappies, disposables, or both. Ten to twelve changes a '
                  'day in the first weeks.'),
              PpCard('Six to eight thin cotton clothes',
                  'Front-opening or wide-necked. Muslin swaddle cloths double '
                  'as everything.'),
              PpCard('One good massage oil',
                  'Cold-pressed, edible grade, unperfumed. One bottle is '
                  'enough.'),
              PpCard('Maternity pads, and a lot of them',
                  'More than you think. This is the item most first-time '
                  'mothers under-buy.'),
              PpCard('Two or three feeding bras and a feeding pillow',
                  "Comfort while feeding isn't a luxury when you're doing it "
                  'ten times a day.'),
              PpCard('A thermometer, and a paediatrician\'s number saved',
                  "Cheap, and the two things you'll want at 2am."),
              PpCard('A safe flat sleep surface',
                  'A firm cot mattress or a firm section of your own bed. No '
                  'soft nest, no pillows.'),
            ], heading: 'Worth buying', hue: 300),
            PpCards([
              PpCard('Skip: baby pillows and head-shaping pillows',
                  'No pillow of any kind for a newborn. Pillows are a '
                  'suffocation risk, and the head shape sorts itself out.'),
              PpCard('Skip: cot bumpers and soft nests',
                  "Every one of them puts something soft near your baby's "
                  'face.'),
              PpCard('Skip: talcum powder',
                  'Breathed in, it irritates newborn lungs. Dry skin folds '
                  'properly instead.'),
              PpCard('Skip: gripe water, herbal drops (janam ghutti) and colic drops',
                  'Not needed, and not for a baby under six months.'),
              PpCard('Skip: walkers and jumpers',
                  'Not for months, and paediatric bodies advise against '
                  'walkers entirely.'),
              PpCard('Skip: a sterilising cupboard full of bottles',
                  'Buy one or two if you might need them. You can add more in a '
                  'day.'),
              PpCard('Wait on: the pram, the cot mobile, the giant toy set',
                  'None of it gets used in the first six weeks. Wait and see '
                  'what you reach for.'),
            ], heading: 'Skip, or wait', hue: 300),
            PpCallout(
              'The things marketed hardest at new parents are often the ones '
              'paediatric bodies advise against: sleep positioners, cot '
              "bumpers, baby pillows, walkers. Expensive doesn't mean safe, "
              'and "recommended by mothers" isn\'t a safety standard.',
              kind: PpCalloutKind.myth,
            ),
            PpWhenLine('Buy the short list before the birth. Everything else '
                'can be bought in a day when you find you need it.'),
            PpIndiaNote('Most of this arrives as gifts, and much of it will '
                'be the pillows and the powder. Accept graciously and put '
                "the unsafe things away. You don't have to use a gift to "
                'have loved it.'),
            PpLink('Newborn and first 40 days essentials',
                surfaceId: 'pp_products',
                blurb: 'The short list, with what to look for on each label.'),
          ],
        ),
        PpPage(
          id: 'f40_which_oil',
          title: 'Which massage oil?',
          subtitle: 'An honest comparison, including the ones to avoid.',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('Any clean, plain, edible-grade oil does the job. The '
                'differences are about weather, skin and tradition, nothing '
                'dramatic. Use the one your family already trusts unless '
                "your baby's skin objects."),
            PpTable(
              heading: 'Comparing the usual choices',
              columns: ['Oil', 'Good for', 'Watch out for'],
              rows: [
                [
                  'Coconut',
                  'Hot weather, sensitive skin, everyday use. The safest '
                  'default',
                  'Solidifies in winter. Warm it in your palms',
                ],
                [
                  'Sesame or til',
                  'Winter, the traditional warming choice, good absorption',
                  'Buy cold-pressed and edible grade. Strong smell',
                ],
                [
                  'Mustard',
                  'Cold north Indian winters, deeply traditional',
                  'Can irritate or burn newborn skin. Patch test, never warm '
                  'it hot, avoid on premature or very young babies',
                ],
                [
                  'Almond',
                  'Light, gentle, absorbs quickly',
                  "Avoid if there's nut allergy in the family. Expensive",
                ],
                [
                  'Olive',
                  'Widely available',
                  'Can worsen eczema-prone skin. Not the best first choice',
                ],
                [
                  'Mineral oil and most baby oils',
                  'Cheap and long-lasting',
                  'Sits on the skin rather than nourishing it. Often perfumed. '
                  'Skip',
                ],
                [
                  'Essential oils and medicated oils',
                  'Nothing, at this age',
                  'Too strong for a newborn. Never use them undiluted or on a '
                  'baby',
                ],
              ],
            ),
            PpSteps([
              PpStep('Check the label says cold-pressed and edible grade',
                  "If you wouldn't cook with it, don't put it on your baby."),
              PpStep('No fragrance, no added colour',
                  'Perfume is the most common cause of a reaction.'),
              PpStep('Patch test on the leg first',
                  'A small amount, then wait a few hours and look for redness.'),
              PpStep('Buy a small bottle and keep it cool',
                  'Oil goes rancid. A small bottle used up in a month beats a '
                  'litre that turns.'),
            ], heading: 'How to choose a bottle'),
            PpWhenLine('Start once the cord has healed. Reconsider the oil in '
                'summer, when a lighter one is usually kinder.'),
            PpCallout(
              'Stop and ask a doctor if the skin turns red, bumpy or itchy '
              'after massage, or eczema flares each time. A reaction is a '
              'reason to change oil, not to push through.',
              kind: PpCalloutKind.doctor,
              title: 'If the skin reacts',
            ),
            PpIndiaNote('Family loyalty to a particular oil runs deep, and '
                "it's usually harmless. Mustard is the one worth a talk, "
                'especially for a very small or premature baby in the first '
                'weeks. Coconut is an easy swap nobody objects to for long.'),
            // [fix] carries its nearest shelf; there is no oils shelf yet
            // (docs/PARENTING-DOORS-REVIEW.md).
            PpLink('Compare massage oils side by side',
                surfaceId: 'pp_compare/Lotions',
                blurb: 'Ingredients, pressing, fragrance and price in one '
                    'table.'),
          ],
        ),
        PpPage(
          id: 'f40_which_swaddle',
          title: 'Which swaddle, and how many?',
          subtitle: 'Cloth, muslin or a velcro bag.',
          format: 'COMPARISON TABLE',
          blocks: [
            PpIntro('A swaddle is a piece of cloth, and the expensive '
                'versions mostly buy you convenience at 3am. Any of these '
                'work, as long as the hips stay free and your baby sleeps on '
                'the back.'),
            PpTable(
              heading: 'The three real options',
              columns: ['Option', 'Good for', 'Watch out for'],
              rows: [
                [
                  'Plain cotton square, the traditional wrap',
                  'Cheapest, breathable, doubles as everything else',
                  'Takes practice. Can come loose, so no loose ends near the '
                  'face',
                ],
                [
                  'Muslin swaddle cloth',
                  'Light, breathable, ideal for Indian heat, gets softer with '
                  'washing',
                  'Thin, so add a layer in winter rather than doubling the '
                  'wrap',
                ],
                [
                  'Velcro or zip swaddle bag',
                  'Fast and the same every time at 3am, hard for a baby to '
                  'kick out of',
                  'Sized by weight, so your baby will outgrow it. Check the '
                  'hip room is really wide',
                ],
                [
                  'Weighted swaddles and sleep positioners',
                  'Nothing',
                  'Not recommended for babies. Skip entirely',
                ],
              ],
            ),
            PpChartCard(
              title: 'How many, and what fabric',
              rows: [
                ('Swaddle cloths', "4 to 6, they're always in the wash"),
                ('Summer', 'Thin cotton or muslin only'),
                ('Winter', 'Cotton swaddle plus a layer under, not a thick '
                    'wrap'),
                ('Size', 'At least a metre square for a newborn'),
                ('Stop using when', 'At the first sign of rolling'),
              ],
              note: 'Old cotton sarees and dhotis cut into squares make the '
                  'softest swaddles there are, and they cost nothing.',
              hue: 300,
            ),
            PpWhenLine('Useful from birth until your baby starts to roll, '
                'usually around 8 to 12 weeks.'),
            PpCallout("Whatever you use, the two rules don't change. Loose "
                'at the hips so the legs can bend and kick, and always on '
                'the back.'),
            PpIndiaNote('Grandmothers make excellent swaddles from old soft '
                'cotton, better than most things sold in a box. Just check '
                'that nothing has a long tie or a loose end that can reach '
                'the face.'),
            // [fix] carries its shelf, so the tray arrives loaded.
            PpLink('Compare swaddles',
                surfaceId: 'pp_compare/Sleepwear & sacks',
                blurb: 'Fabric, sizing, hip room and price, side by side.'),
          ],
        ),
      ],
    ),
  ],
  tools: [
    PpSectionTool(
      label: 'Is my baby OK? The quick check',
      blurb: 'Four things in thirty seconds. Nothing to log, no streaks.',
      surfaceId: 'pp_baby_ok_check',
    ),
    PpSectionTool(
      label: "Your baby's weight and growth",
      blurb: 'Plot the weight and see the curve, not a single reading.',
      surfaceId: 'pp_growth',
    ),
    PpSectionTool(
      label: 'The full feed log, if you want it',
      blurb: 'Off by default. Useful for slow gain or a sleepy feeder.',
      surfaceId: 'pp_feeding',
    ),
    PpSectionTool(
      label: 'Ask ParentVeda',
      blurb: 'Ask the 2am question in your own words.',
      surfaceId: 'pp_ask_veda',
    ),
  ],
);
