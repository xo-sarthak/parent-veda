// =============================================================================
//  You, Maa — the section's content
// -----------------------------------------------------------------------------
//  Built from docs/../pp_specs/09-you.md. Ten areas. NO TOOLS.
//
//  ⚠️ THERE IS NO TRACKER IN THIS SECTION AND THERE MUST NEVER BE ONE. The spec
//  says it in capitals ("NO tracker anywhere") and the reason is not squeamish,
//  it is clinical. A mother six days after birth does not need a second thing
//  measuring her. She already has a weighing scale, a pad count, a feed log and
//  a household with opinions. `tools: const []` at the foot of this file is the
//  whole implementation of that rule, and it is deliberate rather than unfinished.
//
//  ⚠️ THE "BOUNCE BACK" NARRATIVE IS REJECTED EVERYWHERE IN THIS FILE. No weight
//  loss framing, no before and after, no "get your body back". Her body did not
//  break. It built a person over roughly forty weeks and it is now doing the
//  slower half of that work. `move_bounce_back` states this outright and every
//  other page is written so it does not need to.
//
//  ⚠️ BANDING HERE MEASURES HER, NOT THE BABY. `kPpPostpartumBands` exists for
//  exactly this section (see its note in pp_age_bands.dart): the numbers match a
//  child band set and the meaning does not. A mother four months in must not open
//  this section and be shown how to care for stitches.
//
//  ⚠️ MENTAL HEALTH CONTENT IS AVAILABLE IN EVERY BAND. Postpartum depression can
//  begin months after birth, and in India it is routinely dismissed as tiredness
//  or drama. So every page in `_yourMind` carries all four bands, on purpose, and
//  none of them reads as a screening test. There is no score anywhere.
//
//  ⚠️ COMMERCE NEVER APPEARS ON A MIND PAGE OR ANYWHERE NEAR THE CRISIS ROUTE.
//  Grep this file for `pp_postpartum_products` and check where it does not appear.
// =============================================================================

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// -----------------------------------------------------------------------------
//  Band ids, named once.
//
//  `PpPage.bands` being empty already means "every band", so `_allBands` is
//  strictly redundant to the renderer. It is used anyway, on every page, because
//  the spec's core requirement is that banding is auditable: "every content page,
//  activity, recipe and program is tagged to the band(s) it belongs to". An empty
//  list cannot be told apart from a page nobody got round to tagging.
// -----------------------------------------------------------------------------
const String _b0 = 'pp_0_6w'; // the first six weeks
const String _b1 = 'pp_6w_3m'; // six weeks to three months
const String _b2 = 'pp_3_6m'; // three to six months
const String _b3 = 'pp_6m'; // six months and beyond

const List<String> _allBands = [_b0, _b1, _b2, _b3];
const List<String> _early = [_b0, _b1];
const List<String> _cleared = [_b1, _b2, _b3];
const List<String> _later = [_b2, _b3];

// -----------------------------------------------------------------------------
//  ⚠️ THE CRISIS ROUTE.
//
//  `pp_crisis_path` is NOT yet in pp_surface_router.dart. It needs one line
//  pointing at `MmCrisisPathScreen` (lib/screens/mind_mood/mm_crisis_path.dart),
//  which already ships for pregnancy and already carries the helpline, the "tell
//  someone in the room" line, and the rule that nothing is ever sold on it.
//  Reused rather than rebuilt, per the spec's "build once, reuse (same pattern as
//  pregnancy Mind & Mood)".
//
//  Until that router line exists, the link renders honestly as SOON, so every
//  crisis callout in this file also carries the instruction in its own words. A
//  page that only works once someone wires a link is not safe enough for this.
//
//  // REQUIRED_TO_CONFIRM: the helpline itself. This file never prints a phone
//  number. The name, number and hours live in ONE place,
//  `kCrisisHelplineName` / `kCrisisHelplineNumber` / `kCrisisHelplineHours` in
//  lib/data/mind_mood_data.dart, already flagged there for the product owner. Do
//  not copy a number into this file. If a maternal specific line is chosen later,
//  changing that constant updates every crisis surface at once.
// -----------------------------------------------------------------------------
const String _crisis = 'pp_crisis_path';

/// Not yet routed. Named here so the report and the router agree on the id.
const String? _circleSurface = null; // pp_circle_4th_trimester, notReady
const String? _shopSurface = null; // pp_postpartum_products, notReady

final PpSection kPpYouMaaSection = PpSection(
  id: 'parenting_maternal', // MUST match the hub's bracketId
  title: 'You, Maa',
  subtitle: 'Because you matter too.',
  intro: 'Everyone is asking about the baby. This part of the app is only about '
      'you. Your body, your mind, your strength, your food, and getting back to '
      'being a person as well as a mother.',
  bandSet: kPpPostpartumBands,
  areas: [
    _howAreYou,
    _yourBody,
    _yourMind,
    _pelvicFloor,
    // The six areas that were owed are now here, in the running order the
    // original pass wrote down before it ran out of budget. Kept in that order
    // deliberately: it moves from the most urgent thing a mother opens the app
    // for to the least, so a mother in week one meets healing before she meets
    // a page about her career.
    _movement, //            moving again, and being cleared to move
    _feedingYourself, //     eating like someone who is healing
    _healingKitchen, //      jaapa foods, kadha, gond laddoo
    _thePeopleAroundYou, //  visitors, the mother in law, asking for help
    _backToWork, //          returning, or choosing not to
    _theCircle, //           other mothers, and not doing this alone
    //
    // ⚠️ EVERY BAND RESOLVES. `kPpPostpartumBands` has four bands and every one
    // of them is served by several areas now. `_yourMind`, `_feedingYourself`,
    // `_healingKitchen`, `_thePeopleAroundYou` and `_theCircle` carry all four
    // on purpose: none of what they cover stops being true at three months.
  ],

  // ⚠️ EMPTY, AND THAT IS THE FEATURE. See the file header. No tracker, no
  // scored self test, nothing that logs her mood or measures her recovery.
  tools: const [],
);

// =============================================================================
//  1. HOW ARE YOU TODAY, MAA — the feeling led entry
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS A ROUTER, NOT A QUIZ. She picks the sentence that sounds like her
//  day and lands on a page that starts helping immediately. No questions with
//  right answers, no score, nothing stored. The spec: "This is what makes it feel
//  for HER, not a library."
//
//  ⚠️ AND THE ROUTES ARE THEMSELVES BANDED, so a mother five months in is never
//  offered "I am still bleeding" as a description of her day.
//
//  KNOWN LIMITATION, REPORTED: `PpLink` can only open a router surface, not
//  another page inside this section. So a route page does its own first aid and
//  then names the door to open, rather than jumping there. If `PpLink` ever gains
//  a `pageId`, these seven pages become one tap shorter.
// =============================================================================

final PpArea _howAreYou = PpArea(
  id: 'how_are_you',
  mark: IntentMark.stepsMark,
  title: 'How are you today, Maa?',
  blurb: 'Pick the one that sounds most like today. We will start there.',
  hue: 288,
  pages: [
    PpPage(
      id: 'you_route_scary',
      title: 'I am having thoughts that frighten me',
      subtitle: 'Read this one first.',
      format: 'ROUTE',
      bands: _allBands,
      blocks: [
        PpIntro('You opened the right thing. Nothing you are about to read is '
            'going to judge you, and nothing here is going to tell you that you '
            'are a danger to your baby.'),
        PpCallout(
          'Say it out loud to one person in the room, today. Then tell your '
          'doctor, your gynaecologist or your family doctor, in plain words: '
          '"I am having thoughts that scare me." They have heard it before. '
          'India also has a free helpline you can call any hour of the day or '
          'night, and it is one tap away below.',
          kind: PpCalloutKind.doctor,
          title: 'Do this today, not next week',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'A phone number you can call this minute, and what to say.'),
        PpArticle([
            'Most new mothers get sudden unwanted images or fears about harm '
            'coming to the baby. They arrive uninvited, they horrify her, and '
            'she does not want to act on them. That pattern is extremely '
            'common, it has a name, and it responds well to help.',
            'A different and much rarer thing is thoughts that start to feel '
            'reasonable, or urges you are afraid you might follow, or hearing '
            'or believing things others do not. That one is urgent and treatable '
            'and needs a doctor today rather than a plan for next week.',
            'You do not have to work out which one you have. That is the '
            'doctor\'s job. Your job is only to tell someone.',
          ], heading: 'The difference that matters'),
        PpIndiaNote('If you think nobody at home will take this seriously, you '
            'do not need their permission. Tell your doctor yourself at the next '
            'visit, or call. You are an adult patient and this is your health.'),
      ],
    ),
    PpPage(
      id: 'you_route_low',
      title: 'I feel low, or I keep crying',
      format: 'ROUTE',
      bands: _allBands,
      blocks: [
        PpIntro('This is the most common thing a new mother feels and the least '
            'often said out loud. You are not ungrateful and you are not weak.'),
        PpArticle([
          'For a lot of mothers the first two weeks bring a wave of tears that '
          'comes from nowhere and passes on its own. For a lot of others it does '
          'not pass, or it arrives at four months when everybody has stopped '
          'asking. Both are real and both have help.',
          'Open the door below called "I do not feel like myself". Start with '
          'the short videos, where other mothers say the same sentence you just '
          'read. Hearing it from someone else is often the thing that unlocks '
          'saying it yourself.',
        ]),
        PpCallout('One thing that helps today: get outside the four walls for '
            'ten minutes, even to the balcony or the gate, and eat something '
            'warm. Neither fixes it. Both make the next hour easier.'),
        PpLink('Watch and read: mothers on feeling low',
            surfaceId: 'pp_watch',
            blurb: 'Short, honest, no advice you have already heard.'),
      ],
    ),
    PpPage(
      id: 'you_route_sore',
      title: 'I am sore, or still healing',
      format: 'ROUTE',
      bands: _early,
      blocks: [
        PpIntro('Soreness in the first weeks is normal. There are also a few '
            'things that are not, and it is worth knowing them by heart so you '
            'never have to wonder at 2am.'),
        PpCallout(
          'Call your doctor now, do not wait for the next visit, if any of '
          'these: bleeding soaking through a maternity pad in an hour, a clot '
          'bigger than a lemon, fever, a red hot painful patch on one breast '
          'with flu like aching, pain or swelling in one calf, a bad headache '
          'with blurred vision, a wound that is oozing or opening, burning urine '
          'with fever, or pain that is getting worse each day instead of better.',
          kind: PpCalloutKind.doctor,
          title: 'The list worth memorising',
        ),
        // REQUIRED_REVIEW: this red flag list and its thresholds (one pad in an
        // hour, clot larger than a lemon, fever, one sided calf pain, headache
        // with visual change) is the single most safety critical block in the
        // section. A doctor must sign off the wording and the numbers before ship.
        PpArticle([
          'If none of that is happening, the door below called "What is '
          'happening to my body" has a page for each of the ordinary sore '
          'things: the bleeding, the stitches, the C-section wound, the '
          'afterpains, the engorged breasts, the night sweats.',
          'Pick the one that is bothering you most today. You do not have to '
          'read them all.',
        ]),
        PpIndiaNote('Sitting cross legged on the floor to feed, and then again '
            'to eat, and then again to fold clothes, is a lot of getting up and '
            'down on a healing body. A low stool and a cushion is not laziness.'),
      ],
    ),
    PpPage(
      id: 'you_route_leaking',
      title: 'I leak, or I feel heavy down there',
      format: 'ROUTE',
      bands: _allBands,
      blocks: [
        PpIntro('A little urine escaping when you cough, sneeze, laugh or lift '
            'the baby is very common after birth. Common is not the same as '
            'something you have to live with.'),
        PpCallout('This is fixable, at any point after birth, including years '
            'later. The muscles are trainable like any other muscles. Nobody '
            'should have told you it was just part of being a mother.'),
        PpArticle([
          'Open the door below called "Leaks, heaviness and your pelvic floor". '
          'Start with the breathing exercise, which is the foundation and is '
          'safe from the first weeks, then the page on finding the muscle '
          'correctly. Most women who say kegels did not work for them were '
          'squeezing the wrong thing.',
          'If it has been more than three months, or if there is a dragging '
          'or bulging feeling, see a pelvic floor physiotherapist rather than '
          'doing more exercises harder. That page tells you when.',
        ]),
      ],
    ),
    PpPage(
      id: 'you_route_stiff',
      title: 'I am stiff and I want to move again',
      format: 'ROUTE',
      bands: _cleared,
      blocks: [
        PpIntro('Wanting to move is a good sign and it is not vanity. Movement '
            'after birth is for your back, your mood and your sleep, in that '
            'order.'),
        PpCallout('Nothing on the movement pages is about losing weight, and '
            'there is no before and after photo anywhere in this app. You are '
            'rebuilding, not reversing.'),
        PpArticle([
          'Go to the door called "Moving again, at your own pace". It starts '
          'with breath and gentle work, moves to reconnecting your deep core, '
          'and only then to strength. Skipping to crunches and planks is the '
          'one mistake that sets mothers back, because a separated abdominal '
          'wall gets worse under that load, not better.',
          'If you had a C-section, there is a page written only for that, with '
          'what to avoid and for how long.',
        ]),
        PpLink('Follow along: postpartum classes',
            surfaceId: 'pp_yoga',
            blurb: 'Gentle recovery and postnatal sessions from the library.'),
      ],
    ),
    PpPage(
      id: 'you_route_drained',
      title: 'I am drained, and I keep forgetting to eat',
      format: 'ROUTE',
      bands: _allBands,
      blocks: [
        PpIntro('You are feeding someone every two hours and eating once a day '
            'standing at the kitchen counter. The tiredness is partly that, and '
            'it is fixable faster than you think.'),
        PpCallout('Iron is the usual culprit in India, and a lot of mothers '
            'finish pregnancy already low. Breathless on the stairs, dizzy '
            'standing up, heart racing, pale inner eyelids, hair falling in '
            'handfuls: ask your doctor for a haemoglobin test rather than '
            'assuming it is only lack of sleep.'),
        // REQUIRED_REVIEW: anaemia symptom list and the suggestion to request a
        // haemoglobin test. Correct and standard, but a clinician should confirm
        // the framing does not read as a diagnosis.
        PpArticle([
          'Two doors help here. "Have you eaten today?" has the short version '
          'of what your body actually needs now, and why the advice is different '
          'if you are breastfeeding.',
          '"The healing kitchen" has the real recipes: panjiri, gond ke laddoo, '
          'methi laddoo, harira, and the one handed meals for the days when you '
          'have exactly one free hand and eleven minutes.',
        ]),
        PpLink('Recipes for you, not the baby',
            surfaceId: 'pp_food',
            blurb: 'The full recipe library, if you want to browse wider.'),
      ],
    ),
    PpPage(
      id: 'you_route_alone',
      title: 'I feel alone in this',
      format: 'ROUTE',
      bands: _allBands,
      blocks: [
        PpIntro('A house can be full of people and you can still be completely '
            'alone in it. Being surrounded by relatives is not the same as being '
            'understood by one.'),
        PpArticle([
          'The loneliest part of early motherhood is usually not the hours by '
          'yourself. It is being the only one awake at 3am, the only one who '
          'knows what the baby needs, and the only one whose day nobody asks '
          'about.',
          'Two things help and they are different things. Other mothers at the '
          'same stage, who need no explanation. And one person in your own house '
          'who takes something off you without being asked twice.',
        ]),
        PpLink('The 4th trimester circle',
            surfaceId: _circleSurface,
            blurb: 'Mothers at the same stage as you. Moderated, and private.'),
        PpCallout('If the loneliness has turned into not wanting to see anyone, '
            'not wanting to talk, or feeling nothing at all, read "I do not feel '
            'like myself" instead. That is a different thing and it has '
            'different help.'),
      ],
    ),
    PpPage(
      id: 'you_route_work',
      title: 'I am going back to work soon',
      format: 'ROUTE',
      bands: _later,
      blocks: [
        PpIntro('The last few weeks of maternity leave are their own kind of '
            'hard. There is a lot to arrange and a lot to feel, and the two get '
            'tangled.'),
        PpArticle([
          'The door called "Going back, and finding yourself again" splits it '
          'into the practical and the emotional, because they need different '
          'answers. Milk stash, pumping without a room to pump in, what your '
          'leave actually entitles you to, and who is going to hold your baby '
          'at 10am.',
          'And separately: the guilt, which is almost universal and almost '
          'never proportionate.',
        ]),
        PpCallout('Start the milk stash and the childcare conversation about '
            'four weeks before your return date, not in the last week. Almost '
            'every mother who found it manageable started earlier than she '
            'thought she needed to.'),
      ],
    ),
  ],
);

// =============================================================================
//  2. WHAT IS HAPPENING TO MY BODY — healing, banded hard
// -----------------------------------------------------------------------------
//  ⚠️ THE BANDING IN THIS AREA IS THE WHOLE POINT OF THE SECTION. Eighteen pages
//  live here and a mother never sees more than eight of them. Day one healing is
//  tagged `_b0` only, so a mother four months in opens this door and finds core
//  recovery and energy, not how to care for stitches. That is the spec's stated
//  requirement and it is the difference between a section that knows her and a
//  library that does not.
//
//  ⚠️ NO BIRTH MODE FILTER EXISTS. `PpPage.bands` bands by time, not by whether
//  she had a caesarean, so the C-section pages are banded by time and named
//  unmistakably in their titles instead. Reported as a gap: if `PpPage` ever gains
//  a condition tag, three pages here should use it.
// =============================================================================

final PpArea _yourBody = PpArea(
  id: 'your_body',
  mark: IntentMark.lotusMark,
  title: 'What is happening to my body?',
  blurb: 'The bleeding, the stitches, the aches, and which of it needs a doctor.',
  hue: 12,
  pages: [
    PpPage(
      id: 'body_red_flags',
      title: 'When to call a doctor, not wait',
      subtitle: 'The short list. Worth knowing by heart.',
      format: 'FLAGGED CALLOUT',
      bands: _allBands,
      blocks: [
        PpIntro('Almost everything you will feel after birth is ordinary '
            'healing. A small number of things are not, and every one of them is '
            'much easier to treat early. This page exists so you never have to '
            'decide at 2am whether you are overreacting.'),
        PpCallout(
          'Call your doctor or go in today if any of these happen. You are not '
          'wasting anyone\'s time. Bleeding that soaks a maternity pad in an '
          'hour, or that suddenly gets heavier again after slowing down. A clot '
          'bigger than a lemon. Fever, or feeling shivery and flu like. Pain, '
          'swelling, redness or heat in one calf. A bad headache that will not '
          'shift, especially with blurred vision, flashing lights or pain under '
          'your ribs. A breast with a red hot painful patch plus fever. A wound '
          'that opens, oozes or smells. Burning when you pass urine, with fever '
          'or back pain. Discharge that smells bad. Trouble breathing, chest '
          'pain, or fainting.',
          kind: PpCalloutKind.doctor,
          title: 'Go now, or call now',
        ),
        // REQUIRED_REVIEW: the full red flag list and every threshold in it. This
        // is the most safety critical block in the file. A clinician must confirm
        // the items, the wording and the urgency language before this ships.
        // Specifically: the one pad per hour rule, the lemon sized clot
        // comparison, the inclusion of secondary postpartum haemorrhage
        // ("heavier again after slowing"), calf signs for DVT, and the headache
        // plus visual change plus upper abdominal pain cluster for postpartum
        // preeclampsia, which can appear up to about six weeks after birth.
        PpArticle([
            'Lead with the number and the timing, not with an apology. "I have '
            'soaked three pads in two hours" gets a different response from "I '
            'think I might be bleeding a bit more than usual, sorry to bother '
            'you."',
            'Say how many days it has been since you delivered, and whether it '
            'was a normal delivery or a caesarean. Those two facts change what '
            'the doctor is looking for.',
            'If the first person you speak to brushes it off and you still feel '
            'wrong, ask again or go to the hospital where you delivered. You are '
            'allowed to be the one who insists.',
          ], heading: 'How to say it so you are taken seriously'),
        PpWhenLine('These apply from the day you deliver until about six weeks '
            'after, and the fever, breast and calf ones apply for as long as you '
            'are feeding.'),
        PpIndiaNote('If your family is telling you that pain and bleeding are '
            'normal and to just rest, they are usually right and occasionally '
            'very wrong. Nobody at home can tell the difference between the two, '
            'and neither can we. Only a doctor can, and the visit costs you an '
            'afternoon.'),
      ],
    ),
    PpPage(
      id: 'body_lochia',
      title: 'The bleeding, and what is normal',
      format: 'ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('The bleeding after birth is called lochia. It happens after '
            'every delivery, caesarean included, and it lasts a lot longer than '
            'most people expect.'),
        PpArticle([
            'Your uterus is shedding the lining it built for the pregnancy and '
            'closing the place where the placenta was attached. That is a wound '
            'roughly the size of a small plate, healing from the inside, and the '
            'bleeding is how it clears.',
            'It changes colour as it goes, and the change is the useful signal. '
            'Bright red at first, then browner and pinker, then a pale yellowish '
            'discharge, then nothing.',
          ], heading: 'What is happening'),
        PpChartCard(
          title: 'Roughly how it goes',
          rows: [
            ('Days 1 to 4', 'Heavy, bright red, some small clots'),
            ('Days 5 to 10', 'Lighter, browner or pink'),
            ('Week 2 to 4', 'Light, pale, more like discharge'),
            ('Up to 6 weeks', 'Occasional spotting, then it stops'),
          ],
          note: 'A gush when you stand up after lying down is normal. It has '
              'simply been pooling.',
          hue: 12,
        ),
        // REQUIRED_REVIEW: the lochia timeline above. Widely taught and standard,
        // but a clinician should confirm the day ranges before they are printed
        // as a chart a mother measures herself against.
        PpArticle([
            'Maternity pads, not tampons and not a menstrual cup, until your '
            'doctor clears you. Nothing goes inside while that wound is healing.',
            'Change the pad often even when it is not full, because sitting in '
            'it is how infections start in a hot climate.',
            'Doing too much makes it heavier. If your bleeding steps up on a day '
            'you were on your feet a lot, that is your body sending you an '
            'invoice. Sit down.',
          ], heading: 'What helps'),
        PpCallout(
          'Call your doctor if you soak a maternity pad in an hour, pass a clot '
          'bigger than a lemon, the bleeding suddenly gets heavier again after '
          'it had slowed, it smells bad, or it comes with fever.',
          kind: PpCalloutKind.doctor,
          title: 'Not normal',
        ),
        PpWhenLine('Expect six weeks, not six days. Two weeks in and still '
            'bleeding is on time, not late.'),
        PpIndiaNote('Old cloth is still used in many homes for this. If it is '
            'used, it has to be washed hot, dried in full sun and never reused '
            'damp. Disposable maternity pads for the first two weeks are worth '
            'the money for infection reasons alone.'),
        PpLink('Maternity pads and cotton postpartum underwear',
            surfaceId: _shopSurface,
            blurb: 'What to buy, and how many. Honest picks, no brands pushed.'),
      ],
    ),
    PpPage(
      id: 'body_perineum',
      title: 'Stitches, and sitting down again',
      format: 'ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('If you tore or were cut during delivery, the area between your '
            'vagina and back passage is healing. It is sore, it feels alarming, '
            'and it does get better, usually faster than it feels like it will.'),
        PpArticle([
            'The stitches used are the kind that dissolve on their own, so there '
            'is nothing to remove. They loosen and fall away between one and '
            'three weeks and you may find small threads on the pad. That is '
            'expected.',
            'Swelling peaks in the first two or three days and then goes down. '
            'The stinging when you pass urine is the urine touching a raw '
            'surface, not damage.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Pour warm water while you pass urine', 'A mug or a bottle of plain warm water over the area as '
                    'you go. It dilutes the urine so it does not sting.'),
            PpStep('Pat dry from front to back', 'Never rub, and never wipe backwards. A clean soft '
                    'cotton cloth or tissue, once, then discard.'),
            PpStep('Sit on one buttock, or on a soft cushion', 'Lower yourself onto one side and then settle. Sitting '
                    'straight down puts your full weight on the stitches.'),
            PpStep('Cold for the first two days', 'A clean cloth wrapped ice pack for ten minutes at a '
                    'time reduces swelling. Never ice directly on skin.'),
            PpStep('Warm sitz baths after that', 'Sit in a few inches of clean warm water for ten to '
                    'fifteen minutes, twice a day. It relieves ache and keeps '
                    'the area clean.'),
            PpStep('Do not hold your bowels', 'The first motion is frightening but holding it makes it '
                    'harder. Support the area with a clean pad while you go.'),
          ], heading: 'What actually helps'),
        PpCallout(
          'See your doctor if the pain is getting worse rather than better after '
          'day three, if there is a bad smell, if the wound looks like it is '
          'opening, if there is pus, or if you have a fever. An infected '
          'perineal wound is common enough and treats easily with antibiotics.',
          kind: PpCalloutKind.doctor,
          title: 'When to get it looked at',
        ),
        PpWhenLine('Most of the sharp soreness settles within two weeks. Full '
            'healing of the tissue takes about six.'),
        PpIndiaNote('Squatting Indian toilets are hard work on a fresh perineum. '
            'If your home has one, a low stool to hold and push up from makes '
            'the difference, and it is worth asking for a western commode at the '
            'hospital if you have a choice.'),
        PpLink('Perineal care: spray, sitz bath and cushions',
            surfaceId: _shopSurface,
            blurb: 'The three things that genuinely help, and what to skip.'),
      ],
    ),
    PpPage(
      id: 'body_csection_early',
      title: 'After a C-section, the first weeks',
      format: 'ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('You have had major abdominal surgery and you are also caring '
            'for a newborn, which is not how any other surgery is treated. Be '
            'as careful with yourself as you would be with anyone else who had '
            'been operated on last week.'),
        PpArticle([
            'Six or seven separate layers were cut and closed, and they heal at '
            'different speeds. The skin looks closed within about a week, which '
            'is misleading, because the muscle and the uterus underneath are '
            'weeks behind it.',
            'Trapped gas and the pain of it is often worse than the wound in the '
            'first few days. Walking is the fastest thing that shifts it.',
            'Numbness and a strange dead feeling around the scar is extremely '
            'common and not a complication. Nerves were cut and they regrow '
            'slowly.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Lifting anything heavier than your baby',
                'For about six weeks. That includes a full water bucket, a '
                'toddler and a suitcase.'),
            PpCard('Sitting up straight from lying flat',
                'Roll onto your side, drop your legs off the bed, push up with '
                'your arms. It protects the wound and it hurts far less.'),
            PpCard('Stairs, repeatedly',
                'Once or twice a day is fine. Up and down all day is not, for '
                'the first two weeks.'),
            PpCard('Driving',
                'Until you can do an emergency stop without flinching, and check '
                'your insurance. Usually around four to six weeks.'),
            PpCard('Any core exercise',
                'No crunches, no planks, no sit ups. Not at six weeks either. '
                'See the movement pages for what to do instead.'),
          ], heading: 'What to avoid, and for how long', hue: 12),
        // REQUIRED_REVIEW: the six week lifting restriction, the four to six week
        // driving guidance and the stairs advice. These are standard post
        // caesarean instructions but they vary by surgeon and by how the delivery
        // went. A clinician should confirm, and the page should defer to her own
        // surgeon where they differ.
        PpSteps([
            PpStep('Keep it clean and dry', 'Wash gently with plain water while showering, then pat '
                    'dry. No soap scrubbing, no antiseptic unless prescribed.'),
            PpStep('Let air get to it', 'Loose cotton clothes, high waisted so nothing sits on '
                    'the line. In Indian heat, sweat trapped in that fold is the '
                    'main cause of a wound going bad.'),
            PpStep('Support it when you cough, laugh or sneeze', 'A hand or a folded towel pressed over the scar. It is '
                    'not fragile, but it hurts less.'),
            PpStep('Look at it once a day', 'Or ask someone to. You are checking for spreading '
                    'redness, opening, pus or a bad smell.'),
          ], heading: 'Looking after the wound'),
        PpCallout(
          'Call your doctor for fever, spreading redness around the wound, pus '
          'or a bad smell, the wound opening, a hard painful lump under it, '
          'sudden heavy bleeding, or pain and swelling in one calf. Do not wait '
          'for your scheduled check.',
          kind: PpCalloutKind.doctor,
          title: 'Wound and clot warnings',
        ),
        PpWhenLine('Skin closed in about a week. Deep healing about six to '
            'twelve weeks. Full strength closer to six months, which nobody '
            'tells you.'),
        PpIndiaNote('A caesarean is still spoken about in some families as '
            'though you did not really give birth, or took the easy route. You '
            'had surgery to deliver your child. There is no easier route through '
            'an operating theatre.'),
        PpLink('C-section recovery: belts, cushions and scar care',
            surfaceId: _shopSurface,
            blurb: 'A binder helps early. Scar care starts later. Both explained.'),
      ],
    ),
    PpPage(
      id: 'body_afterpains',
      title: 'Cramps that come back when you feed',
      format: 'SHORT ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('Period like cramps in the first days, worse while the baby is '
            'feeding, are called afterpains. They are a good sign even though '
            'they do not feel like one.'),
        PpArticle([
            'Feeding releases oxytocin, and oxytocin makes the uterus squeeze. '
            'That squeezing is what closes off the bleeding and shrinks the '
            'uterus from the size of a watermelon back to the size of a pear.',
            'They are usually stronger with a second or third baby than with the '
            'first, because the uterus has been stretched before and has to work '
            'harder to contract.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('A warm bag on your lower belly',
                'While feeding, not on a caesarean wound.'),
            PpCard('Emptying your bladder before you feed',
                'A full bladder stops the uterus contracting properly and makes '
                'the cramp worse.'),
            PpCard('Slow breathing out through the cramp',
                'The same breathing you used in labour. It works here too.'),
            PpCard('Ask about pain relief',
                'There are painkillers that are safe while breastfeeding. Ask '
                'your doctor which, rather than suffering through on principle.'),
          ], heading: 'What helps', hue: 12),
        PpWhenLine('Strongest in the first two to three days, mostly gone by '
            'the end of the first week.'),
        PpCallout(
          'Cramping that keeps getting worse after the first week, or comes with '
          'fever, heavy bleeding or a bad smell, is not afterpains. Get it '
          'checked.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
    PpPage(
      id: 'body_sweats',
      title: 'Swelling, and sweating through the night',
      format: 'SHORT ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('Waking up with the bedsheet wet through, and hands and feet '
            'more swollen than they were during pregnancy. Both are normal and '
            'both are temporary.'),
        PpArticle([
            'You carried several extra litres of fluid through pregnancy and '
            'your body now has to get rid of it. It does that through sweat and '
            'urine, mostly at night, for one to two weeks.',
            'Swelling can briefly get worse after delivery before it gets '
            'better, especially if you had a drip during labour. Feet and ankles '
            'are the last to settle.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Drink more, not less',
                'It sounds backwards. Restricting water makes your body hold on '
                'to fluid harder.'),
            PpCard('Loose cotton, and a towel on the sheet',
                'Change your top when you wake. Sleeping in damp cloth in Indian '
                'humidity is how skin rashes start.'),
            PpCard('Feet up when you sit',
                'On a cushion or a stool, above hip level if you can, for '
                'fifteen minutes a few times a day.'),
            PpCard('Move your ankles often',
                'Circles and flexes while you feed. It pushes fluid back up.'),
          ], heading: 'What helps', hue: 12),
        PpCallout(
          'Swelling in only one leg, or one calf that is painful, warm or red, '
          'is different and needs a doctor the same day. So does swelling in '
          'your face or hands with a bad headache or blurred vision.',
          kind: PpCalloutKind.doctor,
          title: 'One sided swelling is not this',
        ),
        // REQUIRED_REVIEW: the distinction drawn here between benign postpartum
        // oedema and the two dangerous patterns (unilateral calf for DVT, facial
        // or hand swelling with headache for postpartum preeclampsia).
        PpWhenLine('Night sweats one to two weeks. Swelling one to three weeks.'),
      ],
    ),
    PpPage(
      id: 'body_breasts',
      title: 'Sore, rock hard breasts',
      format: 'ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('Around day three your milk comes in properly and your breasts '
            'can go from soft to hot, hard and painful within a few hours. This '
            'is engorgement and it passes.'),
        PpArticle([
            'Milk arrives faster than the baby can take it, and there is extra '
            'blood and fluid in the tissue at the same time. The breast becomes '
            'so full that the nipple flattens, which makes latching harder, '
            'which makes the fullness worse.',
            'Cracked or bleeding nipples in the same week are almost always a '
            'latch problem, not a toughness problem. That one is worth getting '
            'help with quickly because it is fixable in one session.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Feed often, and do not skip', 'Eight to twelve times in twenty four hours. An emptied '
                    'breast is a comfortable breast.'),
            PpStep('Warm for a minute before, cold after', 'A warm cloth or a quick warm shower helps milk flow to '
                    'start. Cold afterwards settles the swelling.'),
            PpStep('Soften the areola by hand first', 'Press gently inward around the nipple for a minute to '
                    'move fluid back. A softer areola means the baby can latch.'),
            PpStep('Hand express a little if she cannot latch', 'Only enough to soften, not to empty. Emptying fully by '
                    'pump tells your body to make even more.'),
            PpStep('Cold cabbage leaves, if you want to', 'Chilled, in your bra, for twenty minutes. Old remedy, '
                    'genuinely soothing, does no harm.'),
          ], heading: 'Getting through engorgement'),
        PpCallout(
          'A red hot painful wedge on one breast, plus fever, shivering and '
          'feeling flu like, is mastitis. See a doctor the same day rather than '
          'waiting it out. It usually needs antibiotics, and you keep feeding '
          'through it.',
          kind: PpCalloutKind.doctor,
          title: 'Mastitis needs treating',
        ),
        // REQUIRED_REVIEW: the mastitis description, the "same day" urgency and
        // the statement that feeding continues through it. All standard, but this
        // is the page a mother will act on at 11pm.
        PpCallout(
          'Stopping feeding because it hurts makes engorgement and mastitis '
          'worse, not better. If you want to stop feeding, that is your decision '
          'to make, and there is a way to do it that does not hurt. It is on the '
          'weaning page.',
          kind: PpCalloutKind.myth,
        ),
        PpWhenLine('Engorgement peaks around days three to five and settles '
            'within a week as supply matches demand.'),
        PpIndiaNote('You will be told to bind your breasts tightly, or to skip '
            'the first milk because it looks yellow and thin. Do neither. That '
            'first thick yellow milk is the most concentrated feed your baby will '
            'ever get, and tight binding causes blocked ducts.'),
        PpLink('Nursing bras, pads and nipple cream',
            surfaceId: _shopSurface,
            blurb: 'Two bras is enough. Which cream is safe for the baby.'),
      ],
    ),
    PpPage(
      id: 'body_rest',
      title: 'Rest, and why it is not laziness',
      format: 'ARTICLE',
      bands: [_b0],
      blocks: [
        PpIntro('You are going to be told to rest and simultaneously expected to '
            'be up and running the house. This page is the argument you can '
            'borrow when you need it.'),
        PpArticle([
            'Healing costs energy. Closing a placental wound, shrinking a uterus, '
            'rebuilding blood volume and producing around 700 millilitres of milk '
            'a day is a serious metabolic workload happening quietly while you '
            'stand in the kitchen.',
            'Lying down also matters mechanically, not just for tiredness. '
            'Everything in your pelvis is held up by ligaments that are still '
            'soft from pregnancy hormones. Hours upright in the first fortnight '
            'is when heaviness and prolapse symptoms take root.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Horizontal, not just seated',
                'Aim to be lying down, not sitting up, for a good part of the '
                'first two weeks. Feed lying on your side and you get both.'),
            PpCard('Sleep when the baby sleeps, once a day at least',
                'Not the whole time. Once. Pick the longest nap and lie down for '
                'it instead of doing the dishes.'),
            PpCard('Let the house be untidy',
                'A visitor seeing an untidy house costs you nothing. Standing '
                'for two hours to tidy it costs you a week of healing.'),
            PpCard('One job, then sit',
                'If you are doing something, do one thing and then sit for '
                'twenty minutes. Chains of small tasks are how a whole day '
                'disappears on your feet.'),
          ], heading: 'What resting actually looks like', hue: 12),
        PpCallout('If your bleeding gets heavier on a busy day, that is not a '
            'coincidence. It is the clearest feedback your body gives you, and '
            'it is worth treating as an instruction.'),
        PpWhenLine('The first two weeks mostly lying down, weeks three to six '
            'gradually more upright. Not a rule, a direction.'),
        PpIndiaNote('The traditional jaapa period, forty days of being fed and '
            'kept off her feet, got this right long before anyone measured it. '
            'Where families still do it, take it. Where they have stopped, this '
            'is the part worth keeping.'),
        PpLink('Jaapa: your first 40 days',
            surfaceId: null,
            blurb: 'The whole tradition, day by day, in its own section.'),
      ],
    ),
    PpPage(
      id: 'body_scar_care',
      title: 'Your C-section scar, and the numbness',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('The wound has closed and now there is a line, a shelf of skin '
            'above it, and a patch that feels like it belongs to someone else. '
            'All three are normal, and two of them you can improve.'),
        PpArticle([
            'Scar tissue forms in a disorganised mesh and then slowly reorganises '
            'over about a year. In the middle of that it can stick to the layers '
            'underneath, which is what causes pulling, a tugging feeling when you '
            'stretch, and sometimes back pain that nobody connects to the scar.',
            'The numbness is cut nerves regrowing. Sensation usually returns in '
            'patches over six months to two years, and a small permanently numb '
            'strip is common and harmless.',
            'The overhang above the scar is not fat that needs burning off. The '
            'scar is tethered down and the tissue above it has nowhere to sit. '
            'It softens as the scar mobilises.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Check with your doctor first', 'Usually from about six weeks, and only when the wound '
                    'is completely closed with no scabs, no ooze and no pain to '
                    'light touch.'),
            PpStep('Clean hands, a little plain oil', 'Coconut oil or any unscented oil. No need for an '
                    'expensive scar gel to start.'),
            PpStep('Start beside the scar, not on it', 'Small circles on the skin a centimetre above and below '
                    'the line, firm enough to move the skin, for two minutes.'),
            PpStep('Then work along the scar itself', 'Slide the skin side to side across the line, then up '
                    'and down. You are trying to make it glide, not to rub it.'),
            PpStep('Then pick it up', 'Once it moves easily, gently roll the scar between '
                    'thumb and finger along its length.'),
            PpStep('Five minutes, most days', 'Consistency beats pressure. It should never be sharply '
                    'painful.'),
          ], heading: 'Scar massage, once it is fully closed'),
        // REQUIRED_REVIEW: the six week start point for scar massage and the
        // criteria given for "fully closed". A physiotherapist should confirm the
        // technique description and the timing.
        PpCallout(
          'See a doctor for a scar that is hot, red, opening, oozing or has a '
          'hard painful lump under it, or if you get sharp pain shooting from '
          'the scar. A raised, itchy, spreading scar can be treated, so ask '
          'rather than assuming it is permanent.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Massage from about six weeks. Scars keep changing colour and '
            'softness for a full year, sometimes two.'),
        PpIndiaNote('Turmeric paste and hot oil straight onto a new scar is '
            'common advice and a bad idea in the first weeks. Once it is closed '
            'and you are massaging, plain oil is fine and does the job.'),
        PpLink('Scar care creams and sheets, compared',
            surfaceId: _shopSurface,
            blurb: 'What silicone sheets do, what they cost, and who needs them.'),
      ],
    ),
    PpPage(
      id: 'body_back_posture',
      title: 'Your back, and the way you now stand',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('Back pain after birth is so common it gets treated as a joke. '
            'It is almost always mechanical, which means it is almost always '
            'fixable by changing what you do all day.'),
        PpArticle([
            'Nine months of a growing belly pulled your pelvis forward and '
            'switched your deep abdominal muscles off. Your lower back took over '
            'the job of holding you up and it has kept the habit.',
            'Then add the postures of new motherhood: rounded over a feeding '
            'baby forty minutes at a time, bending into a cot, carrying a '
            'nine kilo child on one hip for a year. The pain is the result of '
            'position, repeated.',
            'This is why core reconnection helps back pain more than painkillers '
            'do. It is not about a flat stomach. It is about giving your spine '
            'its support system back.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Bring the baby to your breast, not your breast to the baby',
                'Pillows under the baby until she is at nipple height. Your '
                'shoulders stay down and back.'),
            PpCard('Back against something, always',
                'A wall, a cushion, a headboard. Forty minutes unsupported is '
                'forty minutes your back is doing all the work.'),
            PpCard('Squat, do not bend',
                'Picking up from the floor a hundred times a day. Bend the '
                'knees, keep the back long.'),
            PpCard('Swap the carrying hip',
                'Always the left hip means always the same twist. Alternate, or '
                'use a carrier that spreads the load.'),
            PpCard('Get off the floor to feed, if you can',
                'Cross legged on the floor with a rounded back is the single '
                'most common cause of Indian postpartum back pain.'),
          ], heading: 'The five changes that help most', hue: 12),
        PpLink('Start with core reconnection',
            surfaceId: 'pp_yoga',
            blurb: 'Gentle sessions that rebuild the muscles holding your spine.'),
        PpCallout(
          'See a doctor for back pain that shoots down a leg, comes with '
          'numbness or weakness in a leg, affects your control of urine or '
          'bowels, wakes you at night, or comes with fever. Also for pain right '
          'over your tailbone that will not settle, which can be a bruised or '
          'broken coccyx from delivery.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Most mechanical back pain improves within four to eight '
            'weeks of changing positions and starting core work. Longer than '
            'three months, see a physiotherapist.'),
        PpIndiaNote('The traditional strong oil massage on the back during jaapa '
            'genuinely helps this, and a maalishwali who knows what she is doing '
            'is worth keeping. It is a complement to rebuilding the muscles, not '
            'a replacement.'),
      ],
    ),
    PpPage(
      id: 'body_wrist_neck',
      title: 'Wrist, thumb and neck pain from feeding',
      format: 'SHORT ARTICLE',
      bands: [_b1, _b2],
      blocks: [
        PpIntro('A sharp pain at the base of your thumb, or a wrist that hurts '
            'to lift with. It has a name, it is caused by holding a baby, and it '
            'settles once you change the hold.'),
        PpArticle([
            'Supporting a newborn head means holding your wrist bent back and '
            'your thumb out, twenty times a day, for weeks. The tendon sheath at '
            'the base of the thumb becomes inflamed. It is often called mother\'s '
            'thumb, and pregnancy hormones make the tissue more prone to it.',
            'The neck and upper back version is the same story higher up: chin '
            'down, shoulders rounded, staring at a feeding baby.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Scoop, do not pinch', 'Lift the baby with both hands flat under her, keeping '
                    'your wrists straight, instead of gripping under the arms '
                    'with thumbs out.'),
            PpStep('Support the baby on pillows, not on your wrist', 'Your hand should be resting, not holding.'),
            PpStep('Wear a thumb splint for two weeks', 'A cheap thumb spica from a pharmacy, at night at least. '
                    'Rest is the treatment and a splint is how you get it.'),
            PpStep('Look at the baby with your eyes, not your neck', 'Bring her up to eye level rather than folding down to '
                    'her.'),
            PpStep('Ice for ten minutes after a bad day', 'Over cloth, on the sore tendon, not on the joint.'),
          ], heading: 'What to change'),
        PpCallout(
          'See a doctor if it is not improving after two to three weeks of '
          'splinting, if your fingers go numb or tingle at night, or if you '
          'cannot grip. Both of these treat easily and there is no reason to '
          'carry them for a year.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Usually starts in weeks three to eight and settles in two to '
            'six weeks once the hold changes.'),
      ],
    ),
    PpPage(
      id: 'body_hair_fall',
      title: 'My hair is coming out in handfuls',
      format: 'SHORT ARTICLE',
      bands: [_b1, _b2],
      blocks: [
        PpIntro('Hair in the drain, hair on the pillow, hair wrapped round the '
            'baby\'s fingers. Around three months after birth this frightens '
            'almost every mother, and it is temporary.'),
        PpArticle([
            'During pregnancy high oestrogen kept hair in its growing phase, so '
            'you shed far less than usual and your hair looked thick. After '
            'birth oestrogen drops and all that held back hair enters the '
            'shedding phase at once.',
            'So this is not extra hair falling. It is a year of normal shedding '
            'arriving in three months. It has a name, telogen effluvium, and it '
            'stops on its own.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Being unhurried with it',
                'Wide toothed comb, no tight ponytails, no heat, no chemical '
                'treatments for now.'),
            PpCard('Eating enough protein and iron',
                'Low iron makes it worse and longer. This is the one nutritional '
                'lever that genuinely matters here.'),
            PpCard('Getting your haemoglobin and thyroid checked',
                'If it is severe or still heavy past nine months, ask. Low '
                'thyroid after birth is common and treatable.'),
            PpCard('Ignoring the oils and shampoos aimed at you',
                'No oil regrows hair that has already entered the shedding '
                'phase. Save the money.'),
          ], heading: 'What actually helps', hue: 12),
        // REQUIRED_REVIEW: the suggestion to check haemoglobin and thyroid, and
        // the nine month threshold for doing so. Postpartum thyroiditis is real
        // and commonly missed, but a clinician should set the threshold.
        PpCallout(
          'See a doctor if you can see patches of scalp, if the hair loss comes '
          'in round bald spots, or if it is still heavy nine months after birth. '
          'Those are different problems from this one.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Usually starts around three months, peaks around four, and '
            'has stopped by six to twelve months. Regrowth is short baby hairs '
            'along your hairline.'),
        PpIndiaNote('You will be told to stop washing your hair, or that you '
            'washed it too soon after delivery, or that cutting it will help. '
            'None of that changes what is happening. Washing is fine, and a '
            'clean scalp in this heat is better than an oily one.'),
      ],
    ),
    PpPage(
      id: 'body_diastasis',
      title: 'The gap in my stomach muscles',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('If your belly still looks pregnant, or a ridge or dip appears '
            'down the middle when you sit up, your abdominal muscles have '
            'separated. Most mothers have this at six weeks. It is not damage '
            'and it is not fat.'),
        PpArticle([
            'The two halves of your front abdominal muscle are joined by a strip '
            'of connective tissue down the middle. A growing uterus stretches '
            'that strip sideways, and after birth it is wider and slacker than '
            'it was. This is called diastasis recti.',
            'What matters is not the width of the gap. It is whether the tissue '
            'across it can hold tension. A slightly wider gap that is firm '
            'behaves better than a narrow one that domes and sinks.',
            'This is also why crunches, planks and sit ups are the wrong first '
            'move. They push outward against exactly the tissue you need to '
            'tighten.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Lie on your back, knees bent', 'Feet flat on the floor or bed.'),
            PpStep('Fingers flat down your midline, just above the navel', 'Pointing towards your feet.'),
            PpStep('Lift your head and shoulders slightly', 'Just until you feel the muscles engage. Not a full sit '
                    'up.'),
            PpStep('Feel how many fingers fit, and how firm it is', 'Note whether it feels like a trampoline you can press '
                    'into, or springy resistance. Check above and below the '
                    'navel too.'),
            PpStep('Write it down and check again in six weeks', 'Not daily. This changes over months, and checking daily '
                    'turns your own body into a test you keep failing.'),
          ], heading: 'How to check it yourself'),
        // REQUIRED_REVIEW: the self check method and the guidance that firmness
        // matters more than finger width. This reflects current physiotherapy
        // thinking but a physio should confirm the wording, and confirm we are
        // right not to give a "normal" finger count.
        PpCards([
            PpCard('Do start with breath',
                'Diaphragmatic breathing then deep core connection. Both are on '
                'the pelvic floor pages.'),
            PpCard('Do log roll out of bed',
                'Rolling to your side and pushing up, rather than folding '
                'straight up, for as long as it domes.'),
            PpCard('Do not do crunches, sit ups or planks',
                'Not yet. Not at six weeks. They make doming worse.'),
            PpCard('Do not rely on a binder to close it',
                'A belt supports and feels good early on. It does not rebuild '
                'the tissue, and worn all day it lets the muscles switch off '
                'further.'),
            PpCard('Do see a physio if it is not improving',
                'Especially if there is doming, back pain, or a bulge you can '
                'push into after three to six months of doing the right work.'),
          ], heading: 'What to do, and not do', hue: 12),
        PpCallout(
          'See a doctor for a bulge near the navel that stays out when you '
          'relax, is painful, or gets hard. That can be a hernia rather than a '
          'separation, and it is a different repair.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Most separation narrows on its own over the first six '
            'months. Rebuilding function takes three to six months of consistent '
            'gentle work, not weeks.'),
        PpCallout(
          'A belly that still looks pregnant at three months is not a failure of '
          'discipline. It is a wall of tissue reorganising, on a timeline you do '
          'not control.',
          kind: PpCalloutKind.myth,
        ),
        PpLink('Postpartum belts and binders, compared',
            surfaceId: _shopSurface,
            blurb: 'Useful early and for support. Not a treatment. Here is why.'),
      ],
    ),
    PpPage(
      id: 'body_constipation',
      title: 'Constipation and piles',
      format: 'ARTICLE',
      bands: [_b0, _b1, _b2],
      blocks: [
        PpIntro('Nobody warns you that the first bowel movement is the thing you '
            'will be most afraid of. It is manageable, and dreading it is what '
            'makes it worse.'),
        PpArticle([
            'Everything conspires at once. Pregnancy hormones slowed your gut, '
            'iron tablets harden stool, you lost fluid in delivery, painkillers '
            'and anaesthesia slow things further, and you are afraid to push '
            'because of stitches or a wound.',
            'Piles either appeared during pushing or were already there from '
            'pregnancy. They are swollen veins, they are extremely common, and '
            'most shrink within a few weeks.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Ask for a stool softener', 'Not a laxative. A softener, from your doctor, taken '
                    'daily for the first two weeks. This is the single most '
                    'effective thing and most mothers are never offered it.'),
            PpStep('Water, more than feels necessary', 'You lose a lot into milk. Keep a bottle where you feed '
                    'and finish it every session.'),
            PpStep('Warm and soft first thing', 'Soaked munakka or figs overnight, a warm glass of water '
                    'on waking, dalia or oats rather than a dry paratha.'),
            PpStep('Do not hold it', 'Go when the urge comes. Waiting lets the stool dry '
                    'further, which is the whole problem.'),
            PpStep('Support and breathe, do not strain', 'Feet on a low stool so your knees are above your hips. '
                    'Hold a clean pad against your stitches. Breathe out as you '
                    'go rather than holding your breath and bearing down.'),
            PpStep('Cold, then a sitz bath, for piles', 'Cold pack for ten minutes for the swelling, then warm '
                    'sitz baths twice a day. Ask your doctor for a cream that is '
                    'safe while feeding.'),
          ], heading: 'What works, in order of how much it helps'),
        PpCallout(
          'See a doctor for no bowel movement at all past four days, severe pain '
          'with it, a lot of fresh blood rather than streaks, a pile that is '
          'hard, dark and very painful, or any leaking of stool or wind you '
          'cannot control. The last one is a pelvic floor injury, it is not '
          'something to live with, and it is treatable.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the four day threshold, the description of a
        // thrombosed pile, and the instruction to escalate any faecal
        // incontinence. The last is deliberately emphatic because obstetric anal
        // sphincter injury is routinely under reported. A clinician should confirm.
        PpWhenLine('The first movement usually within two to four days. '
            'Constipation eases in one to two weeks. Piles shrink over three to '
            'six weeks.'),
        PpIndiaNote('If you are on iron tablets and constipated, do not stop '
            'them. Ask your doctor to change the form or add a softener. Stopping '
            'iron to fix constipation trades a small problem for a bigger one.'),
      ],
    ),
    PpPage(
      id: 'body_core_recovery',
      title: 'Your core and your scar, months later',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('Months in, the acute healing is done and what is left is the '
            'slow half: a core that still does not fire properly and a scar that '
            'still pulls. This is the stage almost nobody gets support for.'),
        PpArticle([
            'Deep muscle takes far longer to come back than skin. Your transverse '
            'abdominis and pelvic floor learned to switch off during pregnancy, '
            'and switching them back on is a skill you relearn, not a strength '
            'you regain by working harder.',
            'A caesarean scar keeps remodelling for a year or more. Around three '
            'to six months is when tethering starts causing symptoms that seem '
            'unrelated: a pulling ache, hip or back pain on one side, a numb '
            'shelf that will not soften.',
            'If you have gone back to normal exercise and something feels off, '
            'the answer is rarely to push harder. It is usually that a link in '
            'the chain never came back online.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Doming or a ridge when you sit up or lift',
                'The load is going through connective tissue instead of muscle.'),
            PpCard('Leaking or heaviness when you run, jump or lift',
                'The pelvic floor is part of the core. This is a load problem, '
                'not a bladder problem.'),
            PpCard('Back pain that returns whenever you carry her',
                'Your spine is still borrowing support it should not need to.'),
            PpCard('Holding your breath to lift anything',
                'A reliable sign the deep system is not co-ordinating.'),
          ], heading: 'Signs your core has not come back yet', hue: 12),
        PpLink('Rebuilding, step by step',
            surfaceId: 'pp_yoga',
            blurb: 'Postnatal sessions that start at breath and build from there.'),
        PpConsult(
          title: 'Postpartum recovery assessment',
          whoFor: 'For mothers three months or more after birth who are doing '
              'the right work and still feel like something is not connecting. '
              'A physiotherapist checks your breath, your deep core, your pelvic '
              'floor and your scar together, and gives you a plan for your body '
              'rather than a general one.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
        PpWhenLine('Useful from three months onward, and just as useful at two '
            'years. There is no window that closes.'),
      ],
    ),
    PpPage(
      id: 'body_when_normal',
      title: 'When will I feel normal, and what is worth checking',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('The honest answer is longer than six weeks and shorter than '
            'forever, and the version of normal you arrive at is slightly '
            'different from the one you left.'),
        PpArticle([
            'The six week check exists to confirm you are not bleeding, infected '
            'or in danger. It was never a declaration that healing is finished, '
            'although it gets read as one by everybody including employers.',
            'Most mothers say the fog lifts somewhere between four and nine '
            'months, and that the biggest single factor is sleep rather than '
            'anything they did with their body.',
            'Some things last longer and are not problems: a slightly wider rib '
            'cage, a foot half a size bigger, a softer belly, a scar that still '
            'has opinions about the weather. Your body is not going to pretend '
            'the last two years did not happen, and it should not have to.',
          ], heading: 'The honest timeline'),
        PpChartCard(
          title: 'Roughly what settles when',
          rows: [
            ('Bleeding and wound healing', 'By about 6 weeks'),
            ('Hair fall', 'Starts 3 months, over by 6 to 12'),
            ('Deep core and pelvic floor', '3 to 12 months of real work'),
            ('C-section scar softening', 'Up to 12 to 24 months'),
            ('Energy and mental clarity', 'Tracks your sleep, not the calendar'),
          ],
          note: 'None of this is a deadline. It is a map so you know whether to '
              'wait or to ask.',
          hue: 12,
        ),
        PpCards([
            PpCard('Still exhausted despite reasonable sleep',
                'Ask for haemoglobin, thyroid and vitamin D. Postpartum thyroid '
                'problems are common and frequently missed.'),
            PpCard('Any leaking, heaviness or dragging',
                'A pelvic floor physiotherapist, not more kegels on your own.'),
            PpCard('Pain during sex',
                'Very treatable. It is not something to endure quietly for '
                'years.'),
            PpCard('Periods that came back wildly heavy or not at all',
                'Both are worth checking, especially if you are no longer '
                'feeding.'),
            PpCard('Low mood that has quietly become your baseline',
                'Depression at nine months is still postpartum depression. Read '
                '"I do not feel like myself".'),
          ], heading: 'Months on, these are worth an appointment', hue: 12),
        // REQUIRED_REVIEW: the recovery timeline chart and the list of
        // investigations suggested (haemoglobin, thyroid, vitamin D). A clinician
        // should confirm both, including whether we should be naming tests at all
        // rather than saying "ask what to check".
        PpCallout(
          'See a doctor for pain that is new or worsening months after birth, '
          'bleeding between periods, a lump anywhere, or breathlessness. Late '
          'does not mean minor.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('Once the baby is sleeping and eating, questions about you '
            'stop entirely, and the next question is about the second baby. You '
            'are allowed to book an appointment purely about yourself.'),
      ],
    ),
    PpPage(
      id: 'body_skin_settling',
      title: 'Your skin, stretch marks and the line on your belly',
      format: 'SHORT ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('The dark patches, the line down your belly and the stretch '
            'marks all fade on their own, at their own speed. Very little you '
            'buy changes that timeline.'),
        PpArticle([
            'Pregnancy raised the pigment in your skin, which is what caused the '
            'dark line down the middle, darker patches on your face and darker '
            'skin around the nipples and underarms. As hormones settle, most of '
            'it lightens over six to twelve months.',
            'Stretch marks are tears in the deeper layer of skin. They start '
            'pink, red or purple and gradually become silvery and flat. They do '
            'not disappear and nothing on a shelf makes them disappear. They do '
            'become much less noticeable.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Sunscreen on your face',
                'The one thing with real evidence for pigmentation. Sun makes '
                'melasma darker and it will not fade while it is being fed.'),
            PpCard('Any moisturiser, used regularly',
                'Keeping skin supple helps how marks look. The specific oil '
                'matters far less than doing it at all.'),
            PpCard('Time',
                'The unsatisfying answer, and the accurate one.'),
            PpCard('A dermatologist, if melasma is not shifting past a year',
                'There are real treatments. Some are not suitable while '
                'breastfeeding, so say that you are feeding.'),
          ], heading: 'What genuinely helps', hue: 12),
        PpCallout(
          'These are your body\'s working notes. You are not obliged to remove '
          'them, cover them or apologise for them, and no product advertisement '
          'gets to decide otherwise.',
          kind: PpCalloutKind.myth,
        ),
        PpWhenLine('Pigmentation mostly lightens over six to twelve months. '
            'Stretch marks fade from red to silver over one to two years.'),
      ],
    ),
    PpPage(
      id: 'body_energy',
      title: 'Getting your energy back',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('Months in, the tiredness has changed character. It is no longer '
            'the sharp exhaustion of no sleep, it is a flat, heavy, why is '
            'everything so much effort feeling. That usually has a cause you can '
            'find.'),
        PpArticle([
            'Iron. Blood loss at delivery plus months of feeding on a diet that '
            'is often lighter than it should be. Low iron feels exactly like '
            'this, and it is the most commonly missed cause in Indian mothers.',
            'Thyroid. Roughly one in twenty women gets a thyroid disturbance in '
            'the year after birth. It causes tiredness, weight change, low mood '
            'and hair fall, and it is a simple blood test.',
            'Vitamin D and B12. Very widely low in India, worse if you are '
            'indoors most of the day with a baby, and directly responsible for '
            'body aches and fatigue.',
            'Sleep that is broken rather than short. Six hours in one piece and '
            'six hours in five pieces are not the same six hours. This is the '
            'one nobody can prescribe for, and it is often the biggest.',
          ], heading: 'The four usual causes, in order'),
        // REQUIRED_REVIEW: the prevalence figures and the list of deficiencies
        // named here, particularly "roughly one in twenty" for postpartum thyroid
        // disturbance. Confirm the number and the source, or soften to "not rare".
        PpCards([
            PpCard('Get the blood tests, once',
                'Haemoglobin, ferritin, thyroid, vitamin D, B12. One visit, one '
                'sample, and it either finds something treatable or rules it '
                'out.'),
            PpCard('Protein at breakfast',
                'Eggs, dal, paneer, curd. A tea and biscuit breakfast is why '
                'eleven in the morning feels like the end of the day.'),
            PpCard('Twenty minutes of daylight',
                'Outside, not through a window. It helps vitamin D, mood and '
                'your sleep that night.'),
            PpCard('One protected sleep block a week',
                'Someone else takes the baby from 9pm to 2am, once a week. It '
                'does more than any supplement.'),
            PpCard('Stop drinking chai instead of eating',
                'Tea with a meal also blocks iron absorption. Keep them an hour '
                'apart.'),
          ], heading: 'What to actually do', hue: 12),
        PpCallout(
          'See a doctor for breathlessness climbing one flight of stairs, a '
          'racing heart at rest, fainting, or tiredness that is getting worse '
          'month by month. Also ask if you are feeding and have never had your '
          'iron rechecked since delivery.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('In a joint family the mother often eats last and least, '
            'from what is left. Six months of that is a nutritional deficit no '
            'amount of resting fixes. If this is your house, eating a proper '
            'plate first is not selfishness, it is the reason you can keep going.'),
        PpLink('Iron and recovery, in detail',
            surfaceId: null,
            blurb: 'On the "Have you eaten today?" pages.'),
      ],
    ),
  ],
);

// =============================================================================
//  3. I DO NOT FEEL LIKE MYSELF — the emotional core
// -----------------------------------------------------------------------------
//  ⚠️ EVERY PAGE IN THIS AREA CARRIES ALL FOUR BANDS, DELIBERATELY. Postpartum
//  depression can begin at four months, at eight months, or when she goes back to
//  work. The spec is explicit: "Mind content and the crisis path are available in
//  EVERY band". If a future pass band-restricts anything here, that is a bug.
//
//  ⚠️ NOTHING IN THIS AREA IS A SCREENING TEST. There is no questionnaire, no
//  score, no "you scored 14, consider help". The reason is not squeamishness about
//  measurement: a score she does not like teaches her to answer differently next
//  time, and a score she does like talks her out of asking for help. So every page
//  describes the experience in her own words and then names the door to a person.
//
//  ⚠️ AND THERE IS NO COMMERCE ANYWHERE IN THIS AREA. No products, no compare, no
//  belt, no supplement. The paid consults appear because human help is the actual
//  answer here, and they never appear on the crisis route.
// =============================================================================

final PpArea _yourMind = PpArea(
  id: 'your_mind',
  mark: IntentMark.moodArc,
  title: 'I do not feel like myself',
  blurb: 'The part nobody asks about. Start with the feeling that fits.',
  hue: 268,
  pages: [
    PpPage(
      id: 'mind_feeling_shelf',
      title: 'How do you feel right now?',
      subtitle: 'Tap the one that fits. A short video, from someone who has '
          'been there or works with mothers who have.',
      format: 'VIDEO SHELF',
      bands: _allBands,
      blocks: [
        PpIntro('No questions, no score, nothing saved. Just pick the sentence '
            'that sounds like today and watch four minutes of someone saying it '
            'back to you.'),
        PpCallout(
          'If what you are feeling is thoughts of harming yourself or your baby, '
          'or urges you are frightened you might follow, stop here and get a '
          'person. Tell someone in the room now and call your doctor today. The '
          'link below opens a helpline you can call this minute.',
          kind: PpCalloutKind.doctor,
          title: 'Before anything else',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'A number to call, and the words to open with.'),
        PpVideoSlot(
          title: 'I feel low',
          subtitle: 'A psychiatrist on why low mood after birth is not '
              'ingratitude, and what shifts it.',
          minutes: '5 MIN',
          slotId: 'you_maa/feel_low',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I cannot stop crying',
          subtitle: 'Three mothers on the crying that arrives without a reason.',
          minutes: '4 MIN',
          slotId: 'you_maa/feel_crying',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I feel nothing at all',
          subtitle: 'On numbness, and why feeling flat frightens mothers more '
              'than sadness does.',
          minutes: '5 MIN',
          slotId: 'you_maa/feel_numb',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I am full of rage',
          subtitle: 'The anger nobody warned you about, and what it is usually '
              'made of.',
          minutes: '5 MIN',
          slotId: 'you_maa/feel_rage',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I am anxious every minute',
          subtitle: 'Checking her breathing at 3am. A therapist on postpartum '
              'anxiety and how to interrupt the loop.',
          minutes: '6 MIN',
          slotId: 'you_maa/feel_anxious',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I do not recognise myself',
          subtitle: 'On the identity shift, and the woman you are afraid you '
              'have lost.',
          minutes: '6 MIN',
          slotId: 'you_maa/feel_identity',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I feel guilty all the time',
          subtitle: 'Guilt for resting, for working, for shouting, for not '
              'enjoying it. Where it comes from.',
          minutes: '4 MIN',
          slotId: 'you_maa/feel_guilty',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I feel completely alone',
          subtitle: 'A mother in a full house, on the loneliest year of her '
              'life.',
          minutes: '5 MIN',
          slotId: 'you_maa/feel_alone',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I get thoughts that scare me',
          subtitle: 'A psychiatrist explains intrusive thoughts plainly. Watch '
              'this one before you decide what they mean about you.',
          minutes: '6 MIN',
          slotId: 'you_maa/feel_intrusive',
          hue: 268,
        ),
        PpVideoSlot(
          title: 'I resent my baby, or my husband',
          subtitle: 'The sentence mothers whisper. Said out loud, without '
              'flinching.',
          minutes: '5 MIN',
          slotId: 'you_maa/feel_resentment',
          hue: 268,
        ),
        PpCallout('You can watch these as many times as you like and nobody is '
            'told. Nothing here is logged, scored or shared with your family.'),
      ],
    ),
    PpPage(
      id: 'mind_blues_vs_ppd',
      title: 'Baby blues, or something more?',
      format: 'COMPARISON TABLE',
      bands: _allBands,
      blocks: [
        PpIntro('Most mothers have a weepy, raw, everything is too much stretch '
            'in the first two weeks. Some have something heavier that does not '
            'lift. Knowing which is which decides whether you wait or ask.'),
        PpTable(
          heading: 'The difference, honestly',
          columns: ['', 'Baby blues', 'Something more'],
          rows: [
            ['When it starts', 'Day 2 to day 5', 'Any time in the first year'],
            ['How long', 'Lifts within 2 weeks', 'Stays, or gets heavier'],
            ['Good moments', 'Yes, in between', 'Few, or none that reach you'],
            ['Sleep', 'Tired but you sleep', 'Cannot sleep even when she does'],
            [
              'Feeling towards baby',
              'Overwhelmed but connected',
              'Flat, distant, or resentful'
            ],
            [
              'Yourself',
              'Fragile, still you',
              'Worthless, a failure, replaceable'
            ],
            ['What it needs', 'Rest, food, company', 'A doctor or a counsellor'],
          ],
        ),
        // REQUIRED_REVIEW: this comparison table. It is the closest thing in the
        // section to a differential and it must not read as a self diagnosis. A
        // maternal mental health clinician should confirm the rows, the wording of
        // the right hand column, and the two week boundary.
        PpArticle([
            'The blues are largely a hormone cliff. Oestrogen and progesterone '
            'fall further and faster in the days after birth than at any other '
            'point in your life. Add no sleep and a body in pain and the result '
            'is tears with no cause.',
            'Postpartum depression is not a stronger version of that. It is a '
            'different thing, it is an illness rather than a mood, and it '
            'responds to treatment in the same way that anaemia or a thyroid '
            'problem does. It affects a large number of Indian mothers and almost '
            'none of them get treated, because it is called weakness at home.',
            'It also does not need a reason. A wanted baby, a supportive '
            'husband, a comfortable house and a healthy delivery do not protect '
            'you from it, and having all four is one of the reasons mothers stay '
            'quiet. There is nothing to justify.',
          ], heading: 'What is happening'),
        PpCallout('Two weeks is the line worth remembering. If it has been more '
            'than two weeks and it has not lifted, or if it is getting heavier '
            'rather than lighter, that is the point at which you talk to '
            'somebody. Not because you have failed a test. Because it is easier '
            'to treat early.'),
        PpCallout(
          'Talk to a doctor today, not in two weeks, if you cannot look after '
          'yourself or the baby, if you feel you would be better off gone, if '
          'you are thinking about harming yourself or her, or if you are hearing '
          'or believing things others around you do not.',
          kind: PpCalloutKind.doctor,
          title: 'Do not wait for these',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'If any of that last part is true, start here.'),
        PpIndiaNote('At home this is called nazar, drama, too much thinking, or '
            'the result of using a phone at night. None of those are treatments. '
            'You can be respectful about the advice and still go to the doctor.'),
        PpConsult(
          title: 'Talk to a maternal mental health counsellor',
          whoFor: 'For any mother whose low mood has lasted more than two weeks, '
              'or who simply wants to say all of this to someone who is not '
              'family. You can book anonymously if you would rather nobody knew, '
              'and nothing appears on any shared account.',
          surfaceId: 'pp_experts',
          role: 'maternal_mental_health',
        ),
      ],
    ),
    PpPage(
      id: 'mind_anxiety',
      title: 'I am anxious every single minute',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Checking her breathing four times a night. Certain something '
            'terrible is about to happen. Unable to hand her to anyone. This is '
            'postpartum anxiety and it is as common as low mood, and much less '
            'talked about.'),
        PpArticle([
            'Some hypervigilance after birth is designed in. A brain that wakes '
            'at the smallest sound kept babies alive for a very long time. What '
            'has happened is that the dial has jammed at maximum and will not '
            'come down when the danger is not there.',
            'It shows up in the body as much as the mind: a racing heart, a tight '
            'chest, no appetite, sleeping badly even when the baby finally '
            'sleeps, needing to check something again after you already checked.',
            'It also loves specific worries. Cot death, the milk not being '
            'enough, dropping her on the stairs, someone else holding her wrong. '
            'The specificity is a symptom, not evidence.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Do name it out loud to one person',
                'Saying "I am anxious, not being sensible" to your partner once a '
                'day breaks the loop more than anything else on this list.'),
            PpCard('Do slow the out breath',
                'In for four, out for seven, six times. It works on the physical '
                'part directly, which then calms the thinking part.'),
            PpCard('Do set one check, not five',
                'Decide that you check her once when you go to bed. Then, hard as '
                'it is, do not check again. Repeated checking feeds it.'),
            PpCard('Do not google the symptom',
                'A search at 2am has never once reassured a new mother. Write the '
                'question down and ask a real doctor in daylight.'),
            PpCard('Do reduce the caffeine',
                'Four cups of chai on no sleep produces something almost '
                'indistinguishable from anxiety.'),
            PpCard('Do not build your day around avoiding it',
                'Never letting anyone else hold her makes the fear bigger, not '
                'smaller.'),
          ], heading: 'What helps, and what makes it worse', hue: 268),
        PpCallout('Anxiety and depression arrive together far more often than '
            'either arrives alone. If you are anxious and also flat, that is one '
            'thing, not two, and it is the same treatment.'),
        PpCallout(
          'See a doctor if the anxiety is stopping you eating, sleeping or '
          'leaving the house, if you have panic attacks, or if it has lasted more '
          'than a few weeks. It treats well, often with talking therapy alone.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('If your house is full of people offering opinions on every '
            'feed and every sneeze, anxiety has a lot of fuel. It is reasonable '
            'to say that you will follow your paediatrician and one person, and '
            'that everyone else can be thanked and set aside.'),
        PpConsult(
          title: 'Talk to a maternal mental health counsellor',
          whoFor: 'For anxiety that has taken over your days, or panic you '
              'cannot ride out. Postpartum anxiety responds particularly well to '
              'a few sessions of the right kind of talking therapy.',
          surfaceId: 'pp_experts',
          role: 'maternal_mental_health',
        ),
      ],
    ),
    PpPage(
      id: 'mind_intrusive',
      title: 'Thoughts that frighten me',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('An image of dropping her down the stairs. A thought about the '
            'knife on the counter. Something so ugly you have never said it to '
            'anyone. Read this page. It is almost certainly not what you are '
            'afraid it is.'),
        PpCallout(
          'The rule that matters: unwanted thoughts that horrify you are one '
          'thing. Thoughts that start to feel reasonable, or urges you are afraid '
          'you might act on, are a different thing and need a doctor today. If '
          'you are not sure which you have, that is exactly what to say to the '
          'doctor.',
          kind: PpCalloutKind.doctor,
          title: 'The one distinction to know',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'If the thoughts feel like urges, start here, right now.'),
        PpArticle([
            'The large majority of new mothers get intrusive thoughts about harm '
            'coming to the baby. Studies that ask the question directly find it '
            'in most of them. Almost nobody says it out loud, so every mother '
            'who has one believes she is the only one.',
            'They arrive because your brain has switched into threat scanning '
            'mode to keep a fragile person alive. It generates worst cases '
            'constantly. In some mothers those come through as vivid pictures '
            'rather than vague worries.',
            'The horror you feel about the thought is the proof of what it is. A '
            'thought that disgusts you is the opposite of an intention. Mothers '
            'with intrusive thoughts are, if anything, over careful.',
            'Where it becomes a problem is the rituals it drives. Hiding the '
            'knives. Not bathing her alone. Checking twenty times. That pattern '
            'has a name, postpartum obsessive compulsive disorder, and it treats '
            'very well.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Do not argue with it', 'Trying to prove to yourself that you would never do it '
                    'gives it more attention and makes it come back.'),
            PpStep('Label it, in the third person', 'Say to yourself: that is an intrusive thought. Not: I '
                    'am someone who thinks about hurting my baby.'),
            PpStep('Let it be there and keep doing the thing', 'Carry on with the feed, the bath, the stairs. Not '
                    'avoiding is the treatment.'),
            PpStep('Tell one person', 'Your partner, your sister, a counsellor. It loses most '
                    'of its power the first time it is said out loud and nobody '
                    'recoils.'),
            PpStep('Tell your doctor if it is running your day', 'If you are arranging your life around avoiding these '
                    'thoughts, that is the point to get help. It is a short '
                    'treatment, not a long one.'),
          ], heading: 'What to do with one when it comes'),
        PpCallout(
          'Having these thoughts does not make you a danger to your child, and '
          'no doctor in India is going to take your baby away because you '
          'described one. That fear is the single biggest reason mothers stay '
          'silent, and it is not how any of this works.',
          kind: PpCalloutKind.myth,
        ),
        PpConsult(
          title: 'Talk to a maternal mental health counsellor',
          whoFor: 'For intrusive thoughts that keep coming back, or that you have '
              'started organising your day around. Say on the booking that this '
              'is what it is about, so you are matched with someone who works '
              'with it. You can book anonymously.',
          surfaceId: 'pp_experts',
          role: 'maternal_mental_health',
        ),
      ],
    ),
    PpPage(
      id: 'mind_rage',
      title: 'The anger nobody warned me about',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Shouting at your husband over a wet towel. Wanting to throw '
            'something. A flash of pure fury at a baby who will not stop crying, '
            'followed immediately by shame. This is real, it has a name, and it '
            'is far more common than the sadness everyone talks about.'),
        PpArticle([
            'Postpartum rage is very often depression wearing different clothes. '
            'Sadness that has nowhere to go, in a person who is not allowed to '
            'complain, comes out as anger. That is why treating the rage as a '
            'character flaw never works.',
            'It is also fed by four ordinary things: no sleep, no food, no help, '
            'and no control over your own day. Every one of those makes anyone '
            'angry. You have all four at once and you are also expected to be '
            'serene.',
            'And it is often anger at the right target pointed at the wrong one. '
            'The husband who sleeps through the night, the relative with opinions '
            'and no hands, the doctor who did not warn you. The wet towel is '
            'rarely about the towel.',
          ], heading: 'What is happening'),
        PpSteps([
            PpStep('Put the baby down safely and step out of the room', 'A cot or the floor, and ten steps away. A crying baby in '
                    'a safe place for two minutes is completely fine. This is the '
                    'most important line on the page.'),
            PpStep('Cold water on your wrists and face', 'It cuts the physical surge quickly, faster than trying '
                    'to talk yourself down.'),
            PpStep('Say it out loud, to nobody', 'I am furious and I am not going to do anything about it '
                    'right now. Naming it takes the top off.'),
            PpStep('Come back when your hands are steady', 'Not before. Nothing is lost by two more minutes.'),
            PpStep('Afterwards, ask what you actually needed', 'Sleep, food, an hour alone, someone to take her. Then '
                    'ask for that specific thing rather than apologising.'),
          ], heading: 'In the moment it rises'),
        PpCallout(
          'If you have shaken, hit or roughly handled your baby, or you are '
          'frightened that you might, tell a doctor today. Not because you are a '
          'bad mother. Because this is the point at which you need real help and '
          'it exists.',
          kind: PpCalloutKind.doctor,
          title: 'When it needs help today',
        ),
        PpLink('Get help now', surfaceId: _crisis),
        PpCallout(
          'Feeling rage at your baby does not mean you do not love her. Rage and '
          'love live in the same house and always have. What matters is what your '
          'hands do, and you can control that even when you cannot control the '
          'feeling.',
          kind: PpCalloutKind.myth,
        ),
        PpIndiaNote('Being told to adjust, to have patience, and that your mother '
            'managed four children without complaining, adds to this rather than '
            'helping. Your mother very likely also felt this and had absolutely '
            'nowhere to say it.'),
      ],
    ),
    PpPage(
      id: 'mind_love_but_not_okay',
      title: 'I love my baby and I am not okay',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Both of those sentences are true at the same time. Holding them '
            'together is not a contradiction and it is not something you have to '
            'resolve before you are allowed to ask for help.'),
        PpArticle([
            'Because the reply is almost always the same. But you have a healthy '
            'baby. But you wanted this. But look how much you have. Every one of '
            'those is meant kindly and every one of them closes the conversation.',
            'Loving your child has never been the thing that protects you from '
            'illness, exhaustion or grief for the life you had. Mothers who adore '
            'their babies get postpartum depression at exactly the same rate as '
            'anyone else.',
            'You are also allowed to miss things. Sleeping until you woke up. '
            'Deciding your own afternoon. Being the most important person in your '
            'own day. Missing them is not a vote against your baby.',
          ], heading: 'Why this is the hardest one to say'),
        PpScript([
            PpScriptLine(
              say: 'I love her completely and I am also struggling. Both are '
                  'true. I need help with the struggling part.',
              notThis: 'I am fine, just a bit tired.',
              why: 'Naming both stops the other person having to choose which '
                  'one to believe.',
            ),
            PpScriptLine(
              say: 'I do not need you to fix it or explain it. I need you to '
                  'take her for two hours.',
              notThis: 'No no, I can manage.',
              why: 'A specific request is much easier to say yes to than a '
                  'general one.',
            ),
            PpScriptLine(
              say: 'I want to see a doctor about how I am feeling. I am not '
                  'asking permission, I am telling you so you know.',
              notThis: 'Do you think I should see someone? Is it silly?',
              why: 'A question invites a no. A statement does not.',
            ),
          ], heading: 'Borrow these words when you need them'),
        PpCallout('If the not okay part has lasted more than two weeks, is '
            'getting heavier, or has started to feel like this is simply who you '
            'are now, that is the moment to talk to somebody. Waiting until it '
            'is unbearable is the most common mistake, and the most avoidable.'),
        PpConsult(
          title: 'Talk to a maternal mental health counsellor',
          whoFor: 'For the mother who cannot say this at home because of what '
              'will come back. A trained listener, no relatives in the room, and '
              'an anonymous option if you want one.',
          surfaceId: 'pp_experts',
          role: 'maternal_mental_health',
        ),
      ],
    ),
    PpPage(
      id: 'mind_identity',
      title: 'Who am I now?',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('You are called somebody\'s mother everywhere now, sometimes '
            'including by your own family. The woman who had a name, a job, '
            'opinions and plans has not gone anywhere, but she is very hard to '
            'find on a Tuesday afternoon.'),
        PpArticle([
            'There is a real psychological transition here, as large as '
            'adolescence, and it has a name: matrescence. The reason nobody warns '
            'you is that pregnancy books stop at delivery.',
            'It is a genuine loss running alongside a genuine gain. Grieving the '
            'freedom, the body, the work identity, the spontaneous evening, the '
            'version of your marriage that existed before, is not ingratitude. '
            'You can mourn something you chose to give up.',
            'It also settles. Most mothers say that somewhere in the second year '
            'the two selves stop competing and become one person who happens to '
            'have a child. It does not feel like that at four months.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Keep one thing that is only yours',
                'Not self care as an idea. One concrete thing: a book, a '
                'language app, a friend you call, twenty minutes of a series. '
                'Same thing, most days.'),
            PpCard('Get your name used',
                'Ask your husband and your friends to use it. Being beta ki mummy '
                'in every sentence, all day, does something to you.'),
            PpCard('Wear clothes you chose',
                'Not smart clothes. Clothes that feel like you and fit the body '
                'you have today, rather than waiting for a body you had before.'),
            PpCard('Say one sentence a day that is not about the baby',
                'To your partner, at dinner. It sounds trivial. Try it for a '
                'week.'),
            PpCard('Write down who you were, once',
                'What you liked, what you were good at, what you wanted. Not to '
                'act on. So it exists somewhere outside your memory.'),
          ], heading: 'Small things that help you stay findable', hue: 268),
        PpCallout('This is not a phase to push through with more positivity. It '
            'is a transition, it takes a couple of years, and mothers who name it '
            'do noticeably better through it than mothers who assume something is '
            'wrong with them.'),
        PpVideoSlot(
          title: 'Finding yourself again',
          subtitle: 'A conversation with mothers two years in about who they '
              'turned out to be.',
          minutes: '14 MIN',
          slotId: 'you_maa/identity_talk',
          hue: 268,
        ),
      ],
    ),
    PpPage(
      id: 'mind_guilt',
      title: 'The guilt, and the comparison',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Guilty for resting. Guilty for working. Guilty for formula, for '
            'crying, for enjoying an hour without her, for wanting the day to '
            'end. The guilt is not information about your mothering.'),
        PpArticle([
            'Guilt is meant to be a signal that you have done harm. In new '
            'motherhood it fires constantly with no harm attached, because the '
            'standard being measured against is impossible: a mother who is '
            'endlessly available, endlessly patient, produces perfect milk, keeps '
            'the house running and never minds.',
            'Comparison makes it worse in a very specific way now. You are seeing '
            'the edited ten seconds of forty other mothers, at 2am, on a phone, '
            'while feeding. That is not a fair sample of anything.',
            'And in a joint family the comparison is in the room. Your sister in '
            'law whose baby slept through, your cousin who was back in shape in '
            'two months, your mother in law who did all this without a washing '
            'machine. None of these are your circumstances.',
          ], heading: 'Where it actually comes from'),
        PpCards([
            PpCard('Ask what harm was done',
                'Actually ask it. If the answer is none, the guilt is a false '
                'alarm, and you do not have to act on a false alarm.'),
            PpCard('Ask whose voice it is',
                'A lot of guilt turns out to be a specific person\'s sentence '
                'that you are now saying to yourself.'),
            PpCard('Take the comparison off your phone',
                'Mute the accounts that make you feel behind. Not forever, just '
                'this year.'),
            PpCard('Notice what guilt is asking of you',
                'It usually asks you to give up rest, food or help. Those are '
                'the three things you cannot afford to give up.'),
            PpCard('Say it to another mother at your stage',
                'The relief of hearing me too is enormous and unavailable from '
                'anybody else.'),
          ], heading: 'What to do with a guilty feeling', hue: 268),
        PpCallout('Guilt that has become constant, or has turned into believing '
            'you are a bad mother or that your baby would be better off with '
            'someone else, is a symptom rather than a mood. That belongs on the '
            '"Baby blues, or something more?" page and with a doctor.'),
        PpLink('Other mothers at your stage',
            surfaceId: _circleSurface,
            blurb: 'The 4th trimester circle. Moderated, and nobody performs '
                'there.'),
      ],
    ),
    PpPage(
      id: 'mind_lonely',
      title: 'Alone in a full house',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('People all around and nobody who knows what your day was. This '
            'particular loneliness is one of the hardest parts of the first year, '
            'and it is not solved by more company.'),
        PpArticle([
            'Company is not the same as being known. A house full of relatives '
            'who ask about the baby, comment on the feeding and leave the night '
            'shift to you can be lonelier than an empty one, because the '
            'loneliness now comes with an audience.',
            'The friendships you had also go quiet, not out of unkindness. Your '
            'hours changed, your conversation changed, and the friends without '
            'children genuinely cannot follow you here yet.',
            'What actually helps is narrow and specific: other mothers at your '
            'exact stage, and one person in your own life who asks about you '
            'rather than the baby.',
          ], heading: 'Why a full house does not fix it'),
        PpCards([
            PpCard('One mother at the same stage',
                'Not a group of twenty. One, who is also awake at 3am. This is '
                'the highest value relationship of your first year.'),
            PpCard('Leave the house once a day',
                'The gate, the balcony, the park, the chemist. Same time each '
                'day if you can. It is about the boundary of the house, not the '
                'exercise.'),
            PpCard('Voice notes instead of calls',
                'You cannot schedule a phone call around feeds. You can talk '
                'into a phone at 4am and get an answer at 9.'),
            PpCard('Tell one old friend the truth once',
                'Most people do not know how to ask. A single honest message '
                'usually brings someone back.'),
            PpCard('Say what you want from a visitor',
                'Come and hold her while I shower is a real invitation. It also '
                'filters out the ones who came to inspect.'),
          ], heading: 'Things that work', hue: 268),
        PpLink('The 4th trimester circle',
            surfaceId: _circleSurface,
            blurb: 'Mothers grouped by how far along you are. Moderated, private, '
                'free.'),
        PpConsult(
          title: 'A facilitated postpartum support circle',
          whoFor: 'A small paid group session with a counsellor and five or six '
              'other new mothers. For mothers who want to be heard by people in '
              'the same week of the same year, with someone trained holding the '
              'room. Costs a fraction of a one to one session.',
          surfaceId: 'pp_experts',
          role: 'group_mental_health',
        ),
        PpCallout('If the loneliness has become not wanting to see anyone at '
            'all, that is worth reading about on the blues page. Withdrawing is '
            'one of the earliest signs of depression and one of the easiest to '
            'explain away as being busy.'),
      ],
    ),
    PpPage(
      id: 'mind_relationship',
      title: 'You and your partner, after',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Most couples find the first year the hardest of their '
            'relationship, and almost nobody says so at the time. This page is '
            'about the emotional half of that. Sex and contraception have their '
            'own page.'),
        PpArticle([
            'You have gone from two people to a small institution with shifts, '
            'and nobody wrote the rota. Most of the fighting in the first year is '
            'about workload and invisible work, dressed up as arguments about '
            'towels and phones.',
            'Resentment builds in a predictable direction. You are awake at '
            'night, tracking everything, and physically recovering. He is likely '
            'to be sleeping, back at work, and to genuinely believe he is helping '
            'a lot. Both of you are exhausted and neither feels seen.',
            'The couples who come through it well are not the ones who fight '
            'less. They are the ones who name the load out loud early and split '
            'it explicitly rather than by default.',
          ], heading: 'What is actually happening between you'),
        PpScript([
            PpScriptLine(
              say: 'From 10pm to 2am she is yours, and I am not on call. I need '
                  'to know I am off duty for four hours.',
              notThis: 'You never help at night.',
              why: 'A shift can be agreed. A complaint can only be defended '
                  'against.',
            ),
            PpScriptLine(
              say: 'I do not want you to help me with the baby. She is also '
                  'yours. I want us to divide her.',
              notThis: 'Thanks for helping.',
              why: 'The word help is the whole problem. It makes her your job and '
                  'his favour.',
            ),
            PpScriptLine(
              say: 'When your mother says that about my feeding, I need you to '
                  'answer her. Not me.',
              notThis: 'Your mother is impossible.',
              why: 'It asks for a specific action and avoids a fight about his '
                  'family.',
            ),
            PpScriptLine(
              say: 'Ask me how I am, before you ask how she slept.',
              why: 'Small, and it changes the shape of the evening.',
            ),
          ], heading: 'Sentences that get somewhere'),
        PpCards([
            PpCard('Fifteen minutes, phones down, most nights',
                'Not a date night you will never manage. Fifteen minutes.'),
            PpCard('Split by task, not by availability',
                'Whoever is free ends up meaning whoever notices, which ends up '
                'meaning you.'),
            PpCard('Let him do it his way',
                'Correcting the nappy, the swaddle and the burping is how a '
                'father quietly becomes an assistant.'),
            PpCard('Say the good things out loud',
                'Both of you are running on nothing. Noticing costs you a '
                'sentence.'),
          ], heading: 'Things that protect a marriage this year', hue: 268),
        PpCallout('If there is shouting that frightens you, controlling '
            'behaviour, any physical roughness, or being stopped from seeing a '
            'doctor or your own family, that is not first year strain. Tell your '
            'doctor privately at your next visit. They are trained to ask and to '
            'help.'),
        PpConsult(
          title: 'Talk to a counsellor, with or without him',
          whoFor: 'For couples stuck in the same fight every week, or for a '
              'mother who wants to work out on her own what she needs before she '
              'raises it. You do not need his agreement to book for yourself.',
          surfaceId: 'pp_experts',
          role: 'maternal_mental_health',
        ),
      ],
    ),
    PpPage(
      id: 'mind_psychosis',
      title: 'Postpartum psychosis: rare, urgent, know the signs',
      format: 'FLAGGED CALLOUT',
      bands: _allBands,
      blocks: [
        PpIntro('This is rare, it affects roughly one or two mothers in a '
            'thousand, and it is a medical emergency that treats very well when '
            'it is caught. It is on this page so that you, or somebody who loves '
            'you, recognises it in time.'),
        // REQUIRED_REVIEW: the prevalence figure (one to two per thousand), the
        // sign list below, the typical onset window, and the emergency framing. A
        // psychiatrist must confirm all four before ship.
        PpCallout(
          'Go to a hospital today, or call your doctor immediately, if a mother '
          'is: hearing or seeing things others do not, believing things that are '
          'not true, unusually suspicious of people close to her, not sleeping at '
          'all for a night or more without feeling tired, speaking very fast or '
          'confusingly, wildly high one hour and desperate the next, behaving '
          'completely unlike herself, or saying anything about harming herself or '
          'the baby. Do not wait to see if it passes and do not leave her alone.',
          kind: PpCalloutKind.doctor,
          title: 'This is an emergency, and it is treatable',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'A number to call, right now, at any hour.'),
        PpArticle([
            'It usually begins early, most often in the first two weeks, and it '
            'can come on within hours. That speed is why the people around her '
            'matter as much as she does. Show them this page.',
            'It is not caused by weakness, by bad thoughts, by nazar or by '
            'anything she did. The risk is higher if she or a close relative has '
            'had bipolar disorder or a previous episode after a birth, and it is '
            'worth telling her obstetrician if that is true before she delivers.',
            'With treatment, most mothers recover fully. The outcomes are good. '
            'The thing that changes those outcomes is how quickly she is seen.',
          ], heading: 'What to know'),
        PpCallout(
          'If you are reading this because you are worried about a mother in your '
          'family: believe her behaviour over her reassurance, stay with her, and '
          'take her in. Being wrong about this costs you an afternoon. Being late '
          'costs much more.',
          kind: PpCalloutKind.key,
        ),
        PpIndiaNote('Behaviour like this is still taken to a temple, a healer or '
            'a family elder before a hospital in many homes. Do both if you must, '
            'but the hospital first. This is an illness of the brain and it has '
            'medicine that works.'),
      ],
    ),
    PpPage(
      id: 'mind_getting_help',
      title: 'How to actually get help, in India',
      format: 'STEP-LIST',
      bands: _allBands,
      blocks: [
        PpIntro('Deciding to get help is the hard part. What comes after is '
            'mostly logistics, and the logistics are more straightforward than '
            'most mothers expect.'),
        PpSteps([
            PpStep('Start with the doctor you already have', 'Your gynaecologist or your family doctor. You do not '
                    'need a psychiatrist first. Say the sentence plainly: "I '
                    'think I may have postpartum depression and I want help." '
                    'They will either treat it or refer you.'),
            PpStep('Or book a counsellor directly', 'You do not need a referral or anyone\'s permission. A '
                    'maternal mental health counsellor is trained for exactly '
                    'this and can be seen online from your own bedroom.'),
            PpStep('Take one physical test off the list first', 'Ask for haemoglobin and thyroid at the same visit. Low '
                    'iron and thyroid problems mimic depression closely, and it '
                    'is worth ruling them out rather than assuming either way.'),
            PpStep('Ask about medicine and feeding together', 'There are antidepressants considered compatible with '
                    'breastfeeding. Do not stop feeding to take medicine, and do '
                    'not refuse medicine to keep feeding, until you have asked. '
                    'It is usually not a choice you have to make.'),
            PpStep('Take one person with you, or nobody', 'Whichever gets you through the door. If your family '
                    'will make it harder, go alone, or do it online.'),
            PpStep('Expect it to take a few weeks to feel different', 'Talking therapy usually shows something within four to '
                    'six sessions. Medicine takes two to four weeks to start '
                    'working. The first week is not the verdict.'),
          ], heading: 'The steps, in order'),
        // REQUIRED_REVIEW: the statement that some antidepressants are considered
        // compatible with breastfeeding, and the timelines given for therapy and
        // medication response. Both are standard, both must be confirmed by a
        // psychiatrist, and the page must never name a drug.
        PpCards([
            PpCard('That it will go on your record and affect your job',
                'It does not work that way. Your treatment is between you and '
                'your doctor.'),
            PpCard('That you will be seen as an unfit mother',
                'Asking for help is the opposite of what an unfit mother does, '
                'and every clinician knows it.'),
            PpCard('That medicine will change your personality',
                'It treats the illness. Most mothers describe it as becoming '
                'themselves again, not becoming someone else.'),
            PpCard('That you have to be desperate to qualify',
                'You do not have to be at the worst point to be allowed help. '
                'Earlier is easier.'),
          ], heading: 'What is not true', hue: 268),
        PpConsult(
          title: 'Maternal mental health counselling, one to one',
          whoFor: 'For any mother who wants to talk to a trained person about how '
              'she is feeling. Online or in person, and there is an anonymous '
              'booking option if privacy at home is a problem.',
          surfaceId: 'pp_experts',
          role: 'maternal_mental_health',
        ),
        PpConsult(
          title: 'A facilitated postpartum support circle',
          whoFor: 'For mothers who would rather not sit alone with a counsellor, '
              'or want something more affordable. A small group of new mothers '
              'with a trained facilitator, weekly.',
          surfaceId: 'pp_experts',
          role: 'group_mental_health',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'If today is worse than that, start here instead.'),
      ],
    ),
  ],
);

// =============================================================================
//  4. LEAKS, HEAVINESS AND YOUR PELVIC FLOOR
// -----------------------------------------------------------------------------
//  ⚠️ THIS AREA IS DELIBERATELY UNEMBARRASSED. The spec asks for "practical and
//  unembarrassed", and the reason is that vagueness here has a measurable cost:
//  most women who say kegels did not work were squeezing the wrong muscle, because
//  every instruction they were given was too polite to say which one. So this area
//  names the muscle, names urine, names sex, and says clearly when to stop
//  exercising and see a physiotherapist instead.
//
//  ⚠️ EXERCISE BANDING IS CLINICAL, NOT EDITORIAL. Breathing is safe from day one
//  and is tagged to every band. Kegels and progressions start at `_b1`, after the
//  six week check, because that is when most Indian mothers are cleared. Flagged
//  REQUIRED_REVIEW below.
// =============================================================================

final PpArea _pelvicFloor = PpArea(
  id: 'pelvic_floor',
  mark: IntentMark.listMark,
  title: 'Leaks, heaviness and your pelvic floor',
  blurb: 'The part of recovery nobody discusses. Plainly, and with the exercises.',
  hue: 206,
  pages: [
    PpPage(
      id: 'pf_what_it_is',
      title: 'What your pelvic floor is, and why it matters',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('It is a sling of muscle at the base of your pelvis, about the '
            'size of your palm. It has just carried a baby for nine months and '
            'either stretched enormously or been operated above. It is the most '
            'ignored muscle group in the female body.'),
        PpArticle([
            'It holds your bladder, uterus and bowel up against gravity. It '
            'closes off your bladder and back passage so you stay in control. It '
            'is part of your core, working with your diaphragm and your deep '
            'abdominals every time you breathe or lift. And it is involved in '
            'sensation during sex.',
            'So when it is weak or too tight, the symptoms look unrelated to each '
            'other: leaking, a dragging feeling, back pain, a belly that will not '
            'flatten, pain during sex, urgency. They are one system.',
            'It is skeletal muscle, like your bicep. That is the good news, '
            'because it means it trains. Women get meaningful improvement '
            'starting at six months, at two years, and at fifty.',
          ], heading: 'What it does'),
        PpChartCard(
          title: 'What it went through',
          rows: [
            ('Carried extra weight', 'For about 9 months'),
            ('Stretched during a vaginal birth', 'Up to about three times'),
            ('Recovers on its own', 'Partly, over months'),
            ('Recovers with training', 'Considerably more'),
          ],
          note: 'A caesarean does not exempt you. Nine months of load did most of '
              'this before delivery day.',
          hue: 206,
        ),
        PpCallout('Leaking is not the price of motherhood and not something to '
            'quietly manage with pads for thirty years. It is a muscle problem '
            'with a muscle treatment, and it is one of the most treatable things '
            'in this entire section.'),
        PpWhenLine('Start with the breathing page from the first weeks. The '
            'strengthening work starts after your six week check.'),
        PpIndiaNote('There is no word for this in most Indian households, so '
            'there is no conversation about it either. Almost every mother you '
            'know has some version of it and none of you have mentioned it.'),
      ],
    ),
    PpPage(
      id: 'pf_leaks',
      title: 'I leak when I cough, laugh or lift',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('A little urine escaping when you sneeze, laugh, lift the baby or '
            'run for a rickshaw. It is called stress incontinence, it is extremely '
            'common after birth, and it improves with the right work.'),
        PpArticle([
            'A cough or a lift sends a spike of pressure down into your pelvis. '
            'Normally the pelvic floor tightens a fraction before that spike '
            'arrives and holds the bladder closed. After birth the muscle is '
            'weaker and slower, so the pressure wins.',
            'There is a second kind: sudden desperate urgency, barely making it, '
            'or leaking on the way. That is the bladder muscle itself being '
            'twitchy, and it needs slightly different work. Many mothers have '
            'both.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Do the breathing first, then the kegels properly',
                'In that order. Both pages are in this section. Doing kegels '
                'without finding the muscle first is why they fail.'),
            PpCard('Do the knack before you cough',
                'Squeeze and lift a moment before you cough, sneeze or lift her. '
                'It works immediately, before any strength is gained.'),
            PpCard('Do not cut down your water',
                'Concentrated urine irritates the bladder and makes urgency '
                'worse. Drinking less is the most common self inflicted mistake.'),
            PpCard('Do not go just in case, repeatedly',
                'Emptying every half hour trains your bladder to signal earlier '
                'and earlier. Aim for every two to three hours.'),
            PpCard('Do not push to empty faster',
                'Sit, relax, let it come. Straining pushes everything down.'),
            PpCard('Do treat constipation seriously',
                'Straining daily on the toilet undoes months of pelvic floor '
                'work.'),
          ], heading: 'What helps, and what quietly makes it worse', hue: 206),
        PpCallout('Wearing a pad is a reasonable thing to do while you are '
            'fixing this. It is not a reasonable thing to do instead of fixing '
            'this.'),
        PpCallout(
          'See a doctor for burning, blood in your urine, fever with back pain, '
          'no warning at all before you leak, leaking large amounts, or if you '
          'cannot pass urine properly. And see a pelvic floor physiotherapist '
          'rather than trying harder if there is no improvement after three '
          'months of doing the exercises correctly.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Most mothers notice a real difference within eight to twelve '
            'weeks of doing the exercises daily and correctly.'),
        PpConsult(
          title: 'Pelvic floor physiotherapy assessment',
          whoFor: 'For leaking that has not improved after three months of doing '
              'the work, or if you cannot tell whether you are squeezing the '
              'right muscle. A physiotherapist checks what is actually happening '
              'rather than guessing, and gives you a programme for your body.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
      ],
    ),
    PpPage(
      id: 'pf_heaviness',
      title: 'A heavy, dragging feeling down there',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('A weight or a bulging feeling in your vagina, worse by the end '
            'of the day or after standing. It usually means the support has been '
            'stretched and something has dropped a little. It is common, it is '
            'not dangerous, and it needs a professional rather than more effort.'),
        PpArticle([
            'The bladder, uterus or bowel wall can sit lower than usual when the '
            'muscle and ligament support has stretched. This is called prolapse. '
            'A degree of it is very common after a vaginal birth and often '
            'improves substantially over the first year.',
            'The pattern is the giveaway. Fine in the morning, heavy by evening, '
            'worse after a day on your feet, worse when constipated, better lying '
            'down. Many women can feel a soft bulge at the entrance.',
            'It gets worse with load and better with support. So the first '
            'treatment is not harder exercise, it is less standing, no heavy '
            'lifting, and getting your bowels soft.',
          ], heading: 'What is happening'),
        PpCards([
            PpCard('Get off your feet in the second half of the day',
                'Lying down for twenty minutes twice a day genuinely relieves '
                'it.'),
            PpCard('Stop lifting heavy things, properly',
                'The water bucket, the toddler, the gas cylinder, the suitcase. '
                'Ask, or split the load in two.'),
            PpCard('Fix the constipation first',
                'Daily straining is the single biggest thing making it worse.'),
            PpCard('Breathe out on effort',
                'Never hold your breath and push down to lift. Exhale as you '
                'lift.'),
            PpCard('Do the exercises, and see a physio',
                'Both. The exercises help. A physiotherapist can tell you what '
                'has actually moved and whether a support pessary would help.'),
          ], heading: 'What to do now', hue: 206),
        PpCallout(
          'See a doctor or a pelvic floor physiotherapist for a bulge you can '
          'see or feel at the vaginal opening, difficulty passing urine or '
          'stool, needing to push a bulge back to empty, pain, or heaviness that '
          'is getting worse rather than better. This is not something to wait out '
          'for years, and treatment does not have to mean surgery.',
          kind: PpCalloutKind.doctor,
          title: 'See someone about this',
        ),
        // REQUIRED_REVIEW: the prolapse description, the reassurance that "a
        // degree of it is very common", and the referral thresholds. A pelvic
        // health physiotherapist and a gynaecologist should both confirm, since
        // this page has to reassure without ever discouraging a mother from being
        // examined.
        PpWhenLine('Often improves over the first six to twelve months. Get it '
            'assessed once rather than monitoring it yourself for a year.'),
        PpConsult(
          title: 'Pelvic floor physiotherapy assessment',
          whoFor: 'For heaviness, dragging or a bulge, at any point after birth. '
              'An assessment tells you what has moved and what will actually '
              'help, which is not the same for every mother.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
      ],
    ),
    PpPage(
      id: 'pf_bowel',
      title: 'Wind and bowel control',
      format: 'SHORT ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Not making it to the toilet in time, not being able to hold '
            'wind, or a smear on your underwear. This is the symptom mothers are '
            'least likely to mention and the one most worth mentioning.'),
        PpArticle([
            'The ring of muscle that controls your back passage can be stretched '
            'or torn during a vaginal birth, sometimes without it being obvious '
            'at the time. When it is repaired early the results are much better '
            'than when it is discovered years later.',
            'Some early urgency and difficulty holding wind settles by itself in '
            'the first weeks. Anything that has not settled by about six weeks '
            'needs a professional, and there is real treatment: physiotherapy '
            'first, and surgery only in a minority.',
            'This is the one symptom in this section where waiting genuinely '
            'costs you. Please do not leave it.',
          ], heading: 'Why to say it out loud'),
        PpCallout(
          'Tell your doctor if you cannot control wind or stool, have to rush to '
          'reach the toilet, leak stool, or feel your control is not what it was. '
          'Say the words exactly. If the response is that it is normal after '
          'birth, ask to be referred to a pelvic floor physiotherapist anyway.',
          kind: PpCalloutKind.doctor,
          title: 'Say this one out loud',
        ),
        // REQUIRED_REVIEW: the six week threshold for escalating faecal
        // incontinence and the framing of obstetric anal sphincter injury. This
        // page is deliberately insistent because the condition is heavily under
        // reported. A clinician must confirm the wording.
        PpCards([
            PpCard('Keep stool soft and formed',
                'Loose stool is much harder to hold. Constipation makes you '
                'strain. Aim for the middle.'),
            PpCard('Do not strain, and do not rush',
                'Feet on a stool, knees above hips, breathe out.'),
            PpCard('Empty properly, once',
                'Waiting a moment and going again avoids the smear later.'),
            PpCard('Do the breathing and pelvic floor work',
                'The same muscles. It helps here too.'),
          ], heading: 'What helps while you wait to be seen', hue: 206),
        PpConsult(
          title: 'Pelvic floor physiotherapy assessment',
          whoFor: 'For any loss of control of wind or stool after birth, at any '
              'time. This is what pelvic health physiotherapists are for, and '
              'results are good.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
      ],
    ),
    PpPage(
      id: 'pf_sex_pain',
      title: 'When sex hurts after birth',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('Pain the first few times is common. Pain that continues is not '
            'something to grit your teeth through, and it has causes that can be '
            'treated. This page is about the pain. Contraception and the wider '
            'question are on their own page.'),
        PpArticle([
            'Dryness, which is the most common one by a distance. Breastfeeding '
            'keeps oestrogen low, and low oestrogen makes vaginal tissue thin and '
            'dry. It is a hormonal state, not a comment on desire. A water based '
            'lubricant fixes most of it, generously and without embarrassment.',
            'A tender scar. Tissue where you tore or were cut can stay sensitive '
            'for months and can heal slightly tight. Scar massage and, if needed, '
            'a physiotherapist resolves this.',
            'A pelvic floor that is too tight rather than too weak. After a '
            'painful birth these muscles often guard. Then penetration hurts, '
            'which makes them guard harder. Kegels are the wrong treatment here '
            'and make it worse, which is a reason to be assessed rather than '
            'guessing.',
            'And not being ready. Fear of pain, exhaustion, feeling touched out '
            'all day, and no privacy in a joint family are real physical '
            'obstacles, not excuses.',
          ], heading: 'The usual causes, and what fixes them'),
        PpSteps([
            PpStep('Wait until bleeding has stopped and you feel ready', 'Usually after the six week check. Being medically '
                    'cleared is not the same as being ready, and the second one '
                    'is the one that matters.'),
            PpStep('Use plenty of lubricant', 'Water based, more than you think, reapplied. This is not '
                    'optional while breastfeeding.'),
            PpStep('Start without penetration', 'There is no obligation to go straight there, and going '
                    'slower usually means it hurts less.'),
            PpStep('You choose the position and the pace', 'Being on top or on your side lets you control depth, '
                    'which is the thing that usually hurts.'),
            PpStep('Stop if it hurts', 'Pushing through pain teaches your pelvic floor to brace, '
                    'and that is the problem you are trying to avoid.'),
            PpStep('Empty your bladder first, and afterwards', 'It is more comfortable and it reduces the chance of a '
                    'urine infection.'),
          ], heading: 'If you want to try again gently'),
        PpCallout(
          'See a doctor or a pelvic floor physiotherapist for pain that continues '
          'past a few attempts, pain in a specific spot on a scar, bleeding after '
          'sex, or pain deep inside. All of these have treatments, and none of '
          'them require you to wait a year to see if it settles.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Most couples restart somewhere between six weeks and six '
            'months, and there is no correct number. Dryness improves as feeding '
            'reduces.'),
        PpIndiaNote('If there is pressure at home to resume, or about a second '
            'child soon, that is worth saying out loud to your own doctor at your '
            'next visit. It is a medical matter as much as a private one, and '
            'they can help you push back with an actual reason.'),
        PpConsult(
          title: 'Pelvic floor physiotherapy assessment',
          whoFor: 'For pain during sex after birth, a tender scar, or a pelvic '
              'floor you suspect is too tight rather than too weak. This is '
              'routine work for a pelvic health physiotherapist and it is usually '
              'resolved in a handful of sessions.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
      ],
    ),
    PpPage(
      id: 'pf_physio_when',
      title: 'When to stop exercising and see a physio',
      format: 'FLAGGED CALLOUT',
      bands: _allBands,
      blocks: [
        PpIntro('Doing the exercises harder is the wrong answer to several of '
            'these problems, and for one of them it makes things worse. Here is '
            'the line.'),
        PpCallout(
          'See a pelvic floor physiotherapist rather than continuing on your own '
          'if: you cannot tell whether you are squeezing the right muscle. You '
          'have done the exercises correctly for three months with no change. '
          'There is heaviness, dragging, or a bulge you can feel. Sex hurts. You '
          'cannot control wind or stool. You leak without any warning. Pain '
          'anywhere in the pelvis. Or you are planning to return to running or '
          'the gym and want to know you are ready.',
          kind: PpCalloutKind.doctor,
          title: 'These need a person, not more repetitions',
        ),
        // REQUIRED_REVIEW: the referral list and the three month threshold, and
        // the statement that kegels are contraindicated in an overactive or
        // guarding pelvic floor. A pelvic health physiotherapist must confirm.
        PpArticle([
            'A pelvic floor can be too tight as well as too weak, and the '
            'symptoms overlap almost completely. Pain, urgency and even leaking '
            'can all come from a muscle that is holding on and never fully '
            'relaxing.',
            'Squeezing a muscle that is already gripping makes it grip harder. '
            'That is the one scenario where doing your exercises diligently makes '
            'you worse, and it is not rare after a difficult birth.',
            'An assessment is a fifteen minute answer to a question you cannot '
            'answer at home. That is genuinely the whole reason to go.',
          ], heading: 'Why more kegels is sometimes the wrong answer'),
        PpCards([
            PpCard('A conversation first',
                'Your birth, your symptoms, your day. Most of the appointment.'),
            PpCard('An examination, with your consent, and only if you agree',
                'An internal check is the accurate way to see what the muscle is '
                'doing. You can decline it and still be helped.'),
            PpCard('A programme for your body',
                'Which exercises, how many, how often, what to stop doing. '
                'Specific, not general.'),
            PpCard('A woman physiotherapist, if you ask',
                'Say so when booking. It is a completely normal request.'),
          ], heading: 'What an assessment involves', hue: 206),
        PpConsult(
          title: 'Pelvic floor physiotherapy assessment, one to one',
          whoFor: 'For any of the signs above, at any point after birth, '
              'including years later. Bring your delivery details if you have '
              'them.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
        PpConsult(
          title: 'Guided pelvic floor recovery class',
          whoFor: 'A small group class, follow along, led by a physiotherapist. '
              'For mothers who know their exercises are right but cannot keep '
              'them up alone, and who want something more affordable than one to '
              'one sessions.',
          surfaceId: 'pp_experts',
          role: 'group_physio',
        ),
      ],
    ),
    PpPage(
      id: 'pf_ex_breathing',
      title: 'Belly breathing, the foundation',
      subtitle: 'Safe from the first days, including after a caesarean.',
      format: 'ACTIVITY',
      bands: _allBands,
      blocks: [
        PpIntro('This is not a relaxation exercise, although it relaxes you. It '
            'is the first exercise of your recovery, because your diaphragm and '
            'your pelvic floor move together, and getting that rhythm back is '
            'what everything else is built on.'),
        PpArticle([
            'When you breathe in, your diaphragm drops and your pelvic floor '
            'gently lengthens. When you breathe out, both come back up. That pair '
            'stopped working properly months ago, when a baby took up the space.',
            'So before you strengthen anything, you are re teaching the movement. '
            'Mothers who start here find kegels far easier to do correctly, '
            'because they can already feel the area.',
          ], heading: 'What it is doing'),
        PpSteps([
            PpStep('Lie on your back with knees bent, or sit supported', 'Side lying is fine too. After a caesarean, whatever is '
                    'comfortable.'),
            PpStep('One hand on your belly, one on your ribs', 'You are going to feel where the movement happens.'),
            PpStep('Breathe in slowly through your nose', 'Let your belly rise and your lower ribs widen '
                    'sideways. Your chest and shoulders stay quiet.'),
            PpStep('Notice the gentle release below', 'On the in breath there is a soft letting go in your '
                    'pelvic floor. You are not doing anything. Just noticing.'),
            PpStep('Breathe out slowly through your mouth', 'Belly softens down, and there is a natural gentle lift '
                    'below. Do not force either.'),
            PpStep('Ten slow breaths', 'That is one set. Stop if you feel dizzy.'),
          ], heading: 'How to do it'),
        PpWhenLine('Ten breaths, two or three times a day, from the first days '
            'after birth. Do it while feeding and it costs you no extra time.'),
        PpCallout('If you have been holding your belly in for years, or since '
            'the baby, this will feel wrong at first. Letting the belly rise is '
            'the exercise. Sucking it in is the habit you are undoing.'),
        PpVideoSlot(
          title: 'Belly breathing, demonstrated',
          subtitle: 'Where to put your hands, what should move, and the two '
              'mistakes almost everyone makes.',
          minutes: '5 MIN',
          slotId: 'you_maa/pf_breathing',
          hue: 206,
        ),
        PpCallout(
          'Stop and check with your doctor if this causes pain at a caesarean '
          'wound, dizziness, or any increase in bleeding.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
    PpPage(
      id: 'pf_ex_kegels',
      title: 'Kegels, done correctly',
      subtitle: 'Once your doctor has cleared you, usually after the six week '
          'check.',
      format: 'ACTIVITY',
      bands: _cleared,
      blocks: [
        PpIntro('Most women who say kegels did not work for them were squeezing '
            'their buttocks, their thighs or their stomach and holding their '
            'breath. This page is mostly about finding the right muscle, because '
            'that is the whole difficulty.'),
        // REQUIRED_REVIEW: the start point. This page is banded from six weeks
        // onward on the assumption that clearance happens at the six week check.
        // Some clinicians encourage gentle pelvic floor activation within days of
        // an uncomplicated vaginal birth. A clinician should decide whether this
        // page should also carry pp_0_6w with a stronger clearance condition.
        PpSteps([
            PpStep('Sit or lie comfortably and breathe normally', 'Do not start by squeezing. Start by locating.'),
            PpStep('Imagine stopping yourself passing wind', 'That is the back part. You should feel a tightening '
                    'around your back passage, drawing gently inward.'),
            PpStep('Now imagine stopping the flow of urine midstream', 'That is the front part. Do not practise this on the '
                    'toilet, it is only a way to identify the feeling.'),
            PpStep('Now do both, and lift', 'Squeeze both, then draw them up and in, as though '
                    'lifting something into your body. Squeeze and lift, not '
                    'clench.'),
            PpStep('Check what should not be moving', 'Buttocks still. Thighs still. Belly not sucked in '
                    'hard. Breathing continuing normally. If you are holding '
                    'your breath you are doing something else.'),
            PpStep('Then let go completely', 'The release matters as much as the squeeze. Feel it fully '
                    'let go before the next one.'),
          ], heading: 'Finding the muscle'),
        PpSteps([
            PpStep('Breathe out and lift, hold for three seconds', 'Keep breathing while you hold. Then release fully for '
                    'six seconds.'),
            PpStep('Repeat eight to ten times', 'That is one set. Quality over count. Four good ones beat '
                    'twenty sloppy ones.'),
            PpStep('Do three sets a day', 'Morning, afternoon, night. Link them to feeds so you do '
                    'not have to remember.'),
            PpStep('Build the hold slowly', 'Three seconds this week, five next, up to about ten over '
                    'a couple of months.'),
          ], heading: 'The exercise itself'),
        // REQUIRED_REVIEW: the dosage above (three second holds building to ten,
        // eight to ten repetitions, three sets daily) and the six second release.
        // These follow common physiotherapy guidance but the numbers should be
        // confirmed by a pelvic health physiotherapist.
        PpCards([
            PpCard('Holding your breath',
                'The commonest one. If you cannot talk while holding, you are '
                'bracing instead.'),
            PpCard('Squeezing your buttocks and thighs',
                'Put a hand on your buttock. If it hardens, that is what you are '
                'training.'),
            PpCard('Pushing down instead of lifting up',
                'It should feel like drawing in and up. If it feels like bearing '
                'down, stop.'),
            PpCard('Never fully releasing',
                'A muscle that never relaxes gets tight, and tight causes its own '
                'problems. The release is half the exercise.'),
            PpCard('Doing them on the toilet',
                'Stopping your flow repeatedly can cause bladder problems. Only '
                'ever as a one time way to identify the feeling.'),
          ], heading: 'The mistakes that make them useless', hue: 206),
        PpWhenLine('From your six week clearance, three sets a day. Expect to '
            'notice a difference in eight to twelve weeks, not in a fortnight.'),
        PpVideoSlot(
          title: 'Finding the right muscle',
          subtitle: 'A physiotherapist explains exactly what to squeeze, what '
              'should stay still, and how to check you have got it.',
          minutes: '7 MIN',
          slotId: 'you_maa/pf_find_muscle',
          hue: 206,
        ),
        PpCallout(
          'If you genuinely cannot feel anything happening, or it hurts, stop and '
          'see a pelvic floor physiotherapist rather than trying harder. Feeling '
          'nothing is information, not failure.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('You can do these sitting in a bus, standing in a queue, or '
            'while feeding at 3am. Nobody can tell. This is the one exercise in '
            'your recovery that needs no floor space, no privacy and no time.'),
      ],
    ),
    PpPage(
      id: 'pf_ex_progression',
      title: 'Making it harder: long holds and quick flicks',
      format: 'ACTIVITY',
      bands: _cleared,
      blocks: [
        PpIntro('Your pelvic floor has two jobs. Holding you up all day, and '
            'reacting in a fraction of a second when you cough. They need two '
            'different exercises, which is why long holds alone do not stop the '
            'leaking when you sneeze.'),
        PpArticle([
            'Slow endurance fibres do the all day holding. Long holds train '
            'those, and they are what reduce heaviness and dragging.',
            'Fast fibres do the emergency closing. Quick flicks train those, and '
            'they are what stops the leak when you cough, laugh or lift her '
            'suddenly.',
            'Once you can do both, the last piece is using it on purpose at the '
            'moment of effort. That is on the next page.',
          ], heading: 'Why both'),
        PpSteps([
            PpStep('Squeeze and lift, and hold', 'Aim for the longest you can hold without losing it, up '
                    'to about ten seconds. Keep breathing.'),
            PpStep('Rest twice as long as you held', 'A full release. Rushing the rest is why the next one is '
                    'weaker.'),
            PpStep('Eight to ten repetitions', 'Stop when the quality drops rather than finishing the '
                    'number.'),
          ], heading: 'Long holds'),
        PpSteps([
            PpStep('Squeeze up strongly and let go immediately', 'Fast, sharp, complete release. Like a blink.'),
            PpStep('Ten of them in a row', 'Then rest for thirty seconds.'),
            PpStep('Two or three rounds', 'Do these after your long holds, not before.'),
          ], heading: 'Quick flicks'),
        PpSteps([
            PpStep('Week one to two, lying down', 'Easiest, gravity is not against you.'),
            PpStep('Then sitting', 'Harder, and closer to real life.'),
            PpStep('Then standing', 'Hardest, and the position you actually need it in.'),
          ], heading: 'And in different positions'),
        PpWhenLine('Both sets, once or twice a day, from about eight weeks and '
            'ongoing. Keep going for at least three to six months.'),
        PpVideoSlot(
          title: 'Long holds and quick flicks',
          subtitle: 'Both, demonstrated, with how to tell when you have lost '
              'the squeeze.',
          minutes: '8 MIN',
          slotId: 'you_maa/pf_progression',
          hue: 206,
        ),
        PpCallout('Progress is not linear and it is worse on tired days. A bad '
            'week after a night of no sleep is not you going backwards.'),
      ],
    ),
    PpPage(
      id: 'pf_ex_connect',
      title: 'Connecting breath, pelvic floor and deep core',
      format: 'ACTIVITY',
      bands: _cleared,
      blocks: [
        PpIntro('This is the exercise that turns three separate things into one '
            'working system. It is also the real starting point for your '
            'stomach, and it does more for a separated abdominal wall than any '
            'crunch ever will.'),
        PpArticle([
            'Your diaphragm at the top, your deep abdominal muscle wrapping '
            'around like a corset, and your pelvic floor at the base. They are '
            'meant to work as one canister, timed to your breath.',
            'Pregnancy broke that timing. Reconnecting it is what stops the '
            'doming, supports your back, and gives your stomach the tension it '
            'currently does not have.',
          ], heading: 'What you are connecting'),
        PpSteps([
            PpStep('Lie on your back, knees bent, and take three belly breaths', 'Get the breathing pattern going first. Never skip this.'),
            PpStep('Fingers just inside your hip bones', 'This is where you will feel the deep muscle tighten. It '
                    'is subtle.'),
            PpStep('Breathe in and let everything soften', 'Belly rises, pelvic floor lengthens.'),
            PpStep('Breathe out slowly, and lift your pelvic floor first', 'Squeeze and lift as you exhale.'),
            PpStep('Then let the deep belly follow, gently', 'A quiet drawing in under your fingers, as though '
                    'hugging your baby with your stomach. About three out of ten '
                    'effort. It is not a hard suck in.'),
            PpStep('Hold for three to five breaths, still breathing', 'The test is whether you can talk. If you cannot, you '
                    'are gripping.'),
            PpStep('Release everything completely', 'Then repeat. Eight to ten times.'),
          ], heading: 'How to do it'),
        PpCards([
            PpCard('No doming or ridging',
                'Look at your midline. If it peaks up, you are working too hard. '
                'Reduce the effort.'),
            PpCard('No breath holding',
                'The whole point is co-ordination with breath.'),
            PpCard('No rib flare or tucking the pelvis',
                'Ribs stay down, pelvis stays neutral, back not pressed flat.'),
            PpCard('Then take it into life',
                'Do it as you stand up, lift her, or get out of bed. That is '
                'when it starts mattering.'),
          ], heading: 'What to watch for', hue: 206),
        PpWhenLine('From about six to eight weeks, once your kegels feel '
            'reliable. Eight to ten repetitions, once a day, for a few months.'),
        PpVideoSlot(
          title: 'Breath, pelvic floor and core together',
          subtitle: 'The timing, the effort level, and how to check for doming '
              'as you go.',
          minutes: '9 MIN',
          slotId: 'you_maa/pf_connect',
          hue: 206,
        ),
        PpLink('Follow along with a postnatal class',
            surfaceId: 'pp_yoga',
            blurb: 'The same work, guided, in the recovery and movement '
                'sessions.'),
      ],
    ),
    PpPage(
      id: 'pf_ex_functional',
      title: 'Using it when you lift, cough and carry her',
      format: 'ACTIVITY',
      bands: _later,
      blocks: [
        PpIntro('You do not leak while lying on the bed doing kegels. You leak '
            'while lifting a toddler off the floor with a cough coming. This is '
            'the exercise that closes that gap, and it is the one most mothers '
            'never get told about.'),
        PpArticle([
            'It is called the knack: a deliberate squeeze and lift a moment '
            'before the effort, rather than during or after. Trained into the '
            'habits you repeat a hundred times a day, it works faster than pure '
            'strength does.',
            'The aim is that eventually you stop thinking about it. That takes a '
            'few weeks of consciously doing it at the same moments.',
          ], heading: 'What it is'),
        PpSteps([
            PpStep('Before you lift her out of the cot', 'Breathe out, lift the pelvic floor, then lift her. '
                    'Never hold your breath.'),
            PpStep('Before you cough or sneeze', 'You usually get half a second of warning. Use it.'),
            PpStep('Before you stand up from the floor', 'Which you do about fifty times a day, so it is excellent '
                    'practice.'),
            PpStep('Before you lift anything heavy', 'Bucket, cylinder, suitcase, toddler. And breathe out on '
                    'the effort, always.'),
            PpStep('On the way up from a squat', 'Exhale and lift as you rise, not as you go down.'),
          ], heading: 'The moments to attach it to'),
        PpCards([
            PpCard('Squats holding her',
                'Ten slow squats with the baby held at your chest, exhaling and '
                'lifting as you rise. Functional and unavoidable practice.'),
            PpCard('Step ups on a stair',
                'Ten each leg, same breathing. Builds the hip and pelvic support '
                'together.'),
            PpCard('Carry on both sides',
                'Deliberately swap hips. One sided carrying builds one sided '
                'weakness.'),
            PpCard('Get assessed before running',
                'If you are heading towards running or jumping, this is the point '
                'to see a physiotherapist rather than test it yourself.'),
          ], heading: 'Building real world strength', hue: 206),
        PpWhenLine('From about three months, and then permanently. This is a '
            'habit rather than a programme.'),
        PpCallout(
          'Leaking during exercise is a sign to stop and get assessed, not to '
          'push through. Repeated leaking under load is your pelvic floor telling '
          'you the load is currently too much for it.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
  ],
);

// =============================================================================
//  5. MOVING AGAIN, AT YOUR OWN PACE
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS THE AREA WHERE THE "BOUNCE BACK" NARRATIVE WOULD HAVE CREPT IN, so
//  it is refused on the first page rather than avoided quietly. `move_bounce_back`
//  is deliberately the first page in the area and carries every band, because a
//  mother arrives here having already been asked when she is going to lose the
//  weight, usually by someone who loves her.
//
//  There is no weight anywhere in this area. No before and after, no target, no
//  "get your body back". Movement here is for her back, her mood and her sleep,
//  and it is described in those terms only.
//
//  ⚠️ CLEARANCE IS A CLINICAL GATE, NOT A COURTESY LINE. Everything that loads
//  the abdominal wall or the pelvic floor is banded from `_b1` onward, after the
//  six week check. Walking and breathing carry `_b0` because they are safe from
//  the first days. Every start point in this area is flagged REQUIRED_REVIEW.
//
//  ⚠️ NO BIRTH MODE FILTER EXISTS, same gap as `_yourBody`. The caesarean pages
//  are named unmistakably in their titles so a mother who had a vaginal birth can
//  skip them, and a mother who had a caesarean cannot miss them.
// =============================================================================

const PpArea _movement = PpArea(
  id: 'movement',
  mark: IntentMark.blocksMark,
  title: 'Moving again, at your own pace',
  blurb: 'For your back, your mood and your sleep. Not for your weight.',
  hue: 152,
  pages: [
    PpPage(
      id: 'move_bounce_back',
      title: 'There is no bouncing back, and that is not bad news',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Someone has probably already asked when you are going to lose '
            'the weight. Here is the position this whole app takes, so you know '
            'what you are reading and what you will never be sold.'),
        PpArticle([
          'Your body spent roughly forty weeks building a person. It grew a '
          'whole new organ and then delivered it. It moved your ribs, softened '
          'every ligament you have, doubled the blood in your body and shifted '
          'your centre of gravity. None of that is damage and none of it is a '
          'mistake to be corrected.',
          'A body does not reverse that in six weeks, and nothing that claims '
          'to is telling the truth. What actually happens is slower and less '
          'dramatic: tissue reorganises, muscles relearn how to fire, and '
          'somewhere between six months and two years you arrive at a body that '
          'works well and is not identical to the one you had.',
          'So there is no weight anywhere in this part of the app. No target, '
          'no before and after, no photograph of somebody else at three months. '
          'Not because weight is shameful to talk about, but because it is the '
          'wrong measurement of whether your recovery is going well.',
        ], heading: 'What actually happened to your body'),
        PpCards([
          PpCard('Your back stops hurting when you carry her',
              'The most reliable sign the deep system is coming back online.'),
          PpCard('You can get up off the floor without bracing',
              'Fifty times a day. This is the strength that changes your life.'),
          PpCard('You stop leaking when you cough or sneeze',
              'A trained pelvic floor, and a much better measure than a scale.'),
          PpCard('You sleep slightly better on the days you moved',
              'Even if the baby did not sleep better. This one is yours.'),
          PpCard('You feel less flattened by the afternoon',
              'Energy comes back before shape does, and it matters more.'),
        ], heading: 'What we measure instead', hue: 152),
        PpCallout(
          'Losing weight is not a goal this app will ever set for you. If you '
          'want to move, move because it makes carrying her easier and the day '
          'lighter. Those reasons hold up on the days the mirror does not.',
        ),
        PpCallout(
          'The idea that a mother should look unpregnant within weeks is about '
          'forty years old and comes from magazines. Every generation of women '
          'before that recovered slowly, in company, and nobody thought less of '
          'them for it.',
          kind: PpCalloutKind.myth,
        ),
        PpIndiaNote('The comment will come, and usually from someone who loves '
            'you. You do not have to argue with it. "My doctor has not cleared '
            'me for that yet" ends the conversation, and for the first six weeks '
            'it is simply true.'),
      ],
    ),
    PpPage(
      id: 'move_first_weeks',
      title: 'Moving in the first six weeks',
      subtitle: 'Which is mostly walking, and mostly not much.',
      format: 'ACTIVITY',
      bands: [_b0],
      blocks: [
        PpIntro('You are not exercising yet. You are keeping your circulation '
            'going, your chest clear and your body from stiffening, which after '
            'a birth is a real medical job and not a small one.'),
        PpArticle([
          'The uterus is still shrinking, the placental wound inside is still '
          'healing, and if you had stitches or a caesarean there is a repair '
          'underway. Bed rest for weeks is not the answer either. Lying '
          'completely still after birth raises the risk of a clot in your leg, '
          'which is why hospitals get you up and walking within hours.',
          'So the target for these six weeks is small, deliberate and dull. '
          'Short walks, changing position often, and gentle breathing. That is '
          'the whole programme, and doing it properly is what makes week seven '
          'possible.',
        ], heading: 'What your body is doing'),
        PpSteps([
          PpStep('Get up and walk a little, several times a day',
              'Around the room, to the balcony, down the corridor. Five minutes '
              'at a time is enough at the start.'),
          PpStep('Change position every hour you are awake',
              'Sitting folded over a feeding baby for four hours is the single '
              'biggest cause of the back and neck pain coming next month.'),
          PpStep('Do the belly breathing, ten breaths, a few times a day',
              'It is on the pelvic floor pages. Safe from the first days, '
              'including after a caesarean, and it is the foundation of '
              'everything you will do later.'),
          PpStep('Ankle circles and shoulder rolls while feeding',
              'Twenty ankle circles each side. It costs nothing and it keeps '
              'the blood moving in your legs.'),
          PpStep('Build the walk slowly, week by week',
              'Five minutes becomes ten, ten becomes twenty. If you feel heavy '
              'below or your bleeding increases the next day, you went too far. '
              'Go back a step, not to zero.'),
        ], heading: 'The whole programme, for now'),
        PpWhenLine('From the first day you feel able, in five to ten minute '
            'walks, building to about twenty minutes by six weeks. Nothing that '
            'loads your stomach or your pelvic floor until you are cleared.'),
        PpCallout(
          'Bleeding that increases or turns bright red again after you have been '
          'more active is your body asking you to do less, not a reason to '
          'worry. Rest for a day and start smaller.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'Call your doctor now for pain, swelling, redness or warmth in one '
          'calf, for sudden breathlessness or chest pain, or for a wound that '
          'starts to gape or ooze after you have been walking. The first two are '
          'clot symptoms and they are an emergency, not a wait and see.',
          kind: PpCalloutKind.doctor,
          title: 'Stop and call, do not wait for the check',
        ),
        // REQUIRED_REVIEW: the clot red flags above (one sided calf pain,
        // swelling, warmth, breathlessness, chest pain) and the instruction to
        // treat them as an emergency. Venous thromboembolism is a leading cause
        // of maternal death postpartum, so a clinician must confirm this wording
        // is both accurate and non alarming.
        PpIndiaNote('Jaapa often means being kept in one room for forty days. '
            'Rest and warmth are genuinely good for you. Not moving at all is '
            'not, and it is the one part of the tradition that a doctor will '
            'disagree with. Walking inside the house counts.'),
      ],
    ),
    PpPage(
      id: 'move_six_week_check',
      title: 'The six week check, and what "cleared" actually means',
      format: 'ARTICLE',
      bands: _early,
      blocks: [
        PpIntro('This appointment decides what you are allowed to do next, and '
            'most mothers walk out of it without asking the question they came '
            'in with. Here is what to ask, in words.'),
        PpArticle([
          'The check exists to confirm you are not bleeding, not infected, that '
          'your wound or stitches have healed, that your blood pressure is fine '
          'and that you have contraception if you want it. It is a safety check.',
          'It is not a declaration that healing is finished. Deep muscle, '
          'connective tissue and a caesarean scar are all still remodelling at '
          'six weeks and will be for months. "Cleared" means it is now safe to '
          'begin loading your body gradually. It does not mean you are back to '
          'where you were.',
          'And it is not automatic. Some mothers are told to wait longer, '
          'usually after a difficult birth, a third or fourth degree tear, or a '
          'complicated caesarean. That is not a setback. It is a body being '
          'given the time it actually needs.',
        ], heading: 'What the check is for'),
        PpSteps([
          PpStep('"Am I cleared to start exercising?"',
              'Ask it in those words. Silence is not clearance.'),
          PpStep('"Is there anything I should not do yet, and for how long?"',
              'Lifting limits, running, abdominal work. Get a timeframe, not a '
              'vague nod.'),
          PpStep('"How is my scar or my stitches healing?"',
              'And whether there is anything to watch for as you start moving.'),
          PpStep('"I still leak when I cough. Who do I see?"',
              'Say it even if you are embarrassed. This is the appointment '
              'where a physiotherapy referral is easiest to get.'),
          PpStep('"Can you check my haemoglobin?"',
              'If you are exhausted, breathless on stairs or dizzy standing up. '
              'Anaemia after birth is very common in India and it is treatable.'),
          PpStep('"What contraception is safe while I am breastfeeding?"',
              'Ask now, before you need the answer.'),
        ], heading: 'The six things to ask before you leave the room'),
        PpCallout(
          'If you had a third or fourth degree tear, a difficult forceps birth, '
          'or a caesarean that did not heal cleanly, ask specifically for a '
          'pelvic floor physiotherapy referral rather than a general "you are '
          'fine". Those births carry a higher chance of problems that are much '
          'easier to fix early.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the six week timing itself, and the list of births
        // that should trigger a physiotherapy referral. Indian practice varies
        // and some mothers are checked at three or four weeks. A clinician should
        // confirm both the timing and the referral criteria.
        PpIndiaNote('Many mothers are still at their mother\'s house at six '
            'weeks and skip the check entirely, or send a photo of the wound on '
            'WhatsApp instead. Go. It is one appointment and it is the one that '
            'decides the next six months.'),
        PpWhenLine('At about six weeks after birth, sooner if anything is '
            'worrying you. Do not wait for the appointment to report a symptom.'),
      ],
    ),
    PpPage(
      id: 'move_walking',
      title: 'Walking, which is doing more than you think',
      format: 'ACTIVITY',
      bands: _allBands,
      blocks: [
        PpIntro('Walking is the most underrated thing in postnatal recovery. It '
            'costs nothing, needs no clearance in its gentle form, and it is the '
            'exercise mothers actually keep doing.'),
        PpArticle([
          'A walk does four things at once that matter right now. It moves blood '
          'through your legs, which lowers clot risk. It loads your bones gently '
          'at a time when breastfeeding is drawing calcium out of them. It gets '
          'you daylight, which does more for early low mood than most people '
          'expect. And it is the one form of movement your body is already '
          'expert at, so nothing about it has to be relearned.',
          'It also gets you out of the house, which after weeks in one room is '
          'sometimes the entire point.',
        ], heading: 'Why this one is worth protecting'),
        PpSteps([
          PpStep('Start with what you can do without paying for it tomorrow',
              'Five or ten minutes. If your bleeding increases or you ache the '
              'next day, that was slightly too much.'),
          PpStep('Add about five minutes a week',
              'Not more. Slow progression is what keeps a healing pelvic floor '
              'out of trouble.'),
          PpStep('Walk tall, not folded over the pram',
              'Ribs stacked over hips, shoulders down. Pushing a pram hunched '
              'over is a common cause of the upper back pain in month three.'),
          PpStep('Take her, or leave her, whichever gets you out',
              'A walk with a sleeping baby in a carrier and a walk alone at 7pm '
              'are different medicines. Both count.'),
          PpStep('Skip the hills and the stairs at first',
              'Incline loads the pelvic floor a lot more than flat ground does.'),
        ], heading: 'How to build it'),
        PpWhenLine('From the first week in short bursts, building to twenty or '
            'thirty comfortable minutes by around three months. Brisk walking '
            'once you are cleared and it feels easy.'),
        PpCallout(
          'Heaviness or dragging in your vagina during or after a walk means the '
          'walk was too long or too fast for your pelvic floor today. Shorten '
          'it, do not push through, and read the heaviness page.',
          kind: PpCalloutKind.safety,
        ),
        PpIndiaNote('If going out alone is not realistic, or the heat makes it '
            'impossible, walking inside the house or up and down the terrace at '
            '7am counts fully. So does a lap of the society compound while she '
            'sleeps in the pram.'),
        PpVideoSlot(
          title: 'Your first walk out with her',
          subtitle: 'How to carry her, how long to go, and how to know when to '
              'turn back.',
          minutes: '6 MIN',
          slotId: 'youmaa/move_first_walk',
          hue: 152,
        ),
      ],
    ),
    PpPage(
      id: 'move_core_reconnect',
      title: 'Waking up your deep core',
      subtitle: 'After clearance. This is the one that everything else needs.',
      format: 'ACTIVITY',
      bands: _cleared,
      blocks: [
        PpIntro('Before strength, before any class, before a single crunch, '
            'there is this. Your deep core switched itself off over nine months '
            'and it does not switch back on by itself.'),
        PpArticle([
          'Your deep core is four things working as one unit: your diaphragm at '
          'the top, your pelvic floor at the bottom, your transverse abdominis '
          'wrapping around like a corset, and the small muscles along your '
          'spine. They fire together, a fraction of a second before you move.',
          'Pregnancy stretched the corset and pushed the diaphragm up, and the '
          'timing between them fell apart. That is why a mother can be strong '
          'and still have back pain, still leak, still dome. Strength is not the '
          'missing piece. Co-ordination is.',
          'So this exercise is not hard and it does not feel like much. It is '
          'the most important thing in this area anyway.',
        ], heading: 'What you are reconnecting'),
        PpSteps([
          PpStep('Lie on your back, knees bent, feet flat',
              'Or sit tall, or lie on your side. Anywhere you can feel your '
              'breath.'),
          PpStep('Hands on your lower belly, just inside your hip bones',
              'That is where you want to feel a change, not the six pack on top.'),
          PpStep('Breathe in and let everything soften',
              'Belly rises, ribs widen, pelvic floor gently lengthens. Do '
              'nothing.'),
          PpStep('Breathe out slowly and lift your pelvic floor first',
              'A gentle squeeze and lift, exactly as on the kegel page.'),
          PpStep('Then draw the lower belly gently in, about three out of ten',
              'A whisper, not a suck in. Under your fingers it should feel like '
              'a slow tightening, not a hard clench. Your ribs should not flare '
              'and your back should not press down.'),
          PpStep('Hold for three to five seconds, still breathing, then release',
              'Fully release. Repeat eight to ten times. Two or three times a '
              'day.'),
        ], heading: 'The connection breath, step by step'),
        // REQUIRED_REVIEW: the dosage (three to five second holds, eight to ten
        // repetitions, two or three times daily) and the "three out of ten"
        // intensity cue. Standard physiotherapy practice, but a pelvic health
        // physiotherapist should confirm the numbers and the cue wording.
        PpCards([
          PpCard('Your belly domes into a ridge',
              'Too much effort, or the exercise is too advanced today. Go '
              'gentler.'),
          PpCard('You hold your breath',
              'The single most common mistake. If you cannot talk, you are '
              'bracing, not connecting.'),
          PpCard('Your buttocks or thighs tighten',
              'Put a hand on them. They should stay soft.'),
          PpCard('You feel pressure pushing downwards',
              'Stop. You are bearing down instead of lifting. Rest and try '
              'again tomorrow with less effort.'),
        ], heading: 'Signs you are doing it too hard', hue: 152),
        PpWhenLine('From your six week clearance, eight to ten repetitions, two '
            'or three times a day, for at least six weeks before adding load. '
            'Most mothers feel the difference in about a month.'),
        PpVideoSlot(
          title: 'Finding your deep core again',
          subtitle: 'A physiotherapist shows where to put your hands, what '
              'should move, and what a correct one feels like.',
          minutes: '8 MIN',
          slotId: 'youmaa/move_core_reconnect',
          hue: 152,
        ),
        PpCallout(
          'If you cannot feel anything at all, or it causes pain, see a pelvic '
          'floor physiotherapist rather than practising harder. Feeling nothing '
          'is a finding, and it is exactly what an assessment is for.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
    PpPage(
      id: 'move_diastasis_training',
      title: 'Training with a gap in your stomach muscles',
      format: 'ACTIVITY',
      bands: _cleared,
      blocks: [
        PpIntro('Most mothers still have some separation at six weeks. It is not '
            'a reason to avoid exercise. It is a reason to choose the exercises '
            'in a particular order, which is what this page is.'),
        PpArticle([
          'The page on the gap itself, in "What is happening to my body", '
          'explains what diastasis recti is and how to check yours. This one is '
          'only about what to train and in what sequence.',
          'The rule underneath all of it is simple. Load the tissue in the '
          'middle before it can hold tension and it stretches further. Build the '
          'tension first and the same load becomes useful. So the order is not '
          'caution for its own sake, it is the mechanism.',
          'The test for whether an exercise is right for you today is not how it '
          'looks. It is what your midline does. Watch for a ridge, a dome or a '
          'dip appearing down the centre as you work. If it appears, that '
          'exercise is too much for now, not forever.',
        ], heading: 'The rule underneath everything here'),
        PpSteps([
          PpStep('Weeks one to four after clearance: breath and connection only',
              'Belly breathing and the connection breath. Nothing else on the '
              'stomach. This is the stage most mothers skip and most regret '
              'skipping.'),
          PpStep('Weeks four to eight: add small load with the exhale',
              'Heel slides, a single knee lift, a gentle bridge. Always exhale '
              'and connect before the effort, and always watch the midline.'),
          PpStep('Weeks eight to twelve: add position and gentle resistance',
              'Bird dog on hands and knees, side lying work, a squat holding '
              'her. Still exhaling on effort.'),
          PpStep('Three months and beyond: real strength, carefully chosen',
              'Loaded carries, squats, rows, hip work. Everything except the '
              'exercises below, until a physiotherapist says otherwise.'),
        ], heading: 'The order, and roughly how long each stage takes'),
        PpCards([
          PpCard('Crunches, sit ups and bicycle crunches',
              'They pull the two halves apart against exactly the tissue you '
              'are trying to tighten.'),
          PpCard('Full planks and push ups on the floor',
              'Too much downward pressure too early. An incline plank against a '
              'wall or a sofa is the version that works.'),
          PpCard('Anything that makes you hold your breath and brace',
              'Heavy lifting included. If you cannot talk through it, it is too '
              'heavy for this stage.'),
          PpCard('Sitting straight up out of bed',
              'Log roll to your side and push up instead, for as long as your '
              'midline domes.'),
          PpCard('Deep twists and side bends under load',
              'Rotation through an unsupported midline is a lot of shear.'),
        ], heading: 'What to leave out until you are told otherwise', hue: 12),
        // REQUIRED_REVIEW: the four stage progression and its timings (four
        // weeks of breath work, then eight to twelve weeks before real load) and
        // the exclusion list. This reflects current postnatal physiotherapy
        // practice, but the timings should be confirmed and may need to be
        // framed as a range rather than fixed weeks.
        PpCallout(
          'See a physiotherapist if the midline still domes after three months '
          'of doing this properly, if there is back pain that will not settle, '
          'or if you can push your fingers into a soft gap that is not '
          'improving. That is an assessment, not a failure.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Three to six months of consistent gentle work is the usual '
            'timeline for function to come back. Not six weeks, and not by '
            'working harder.'),
      ],
    ),
    PpPage(
      id: 'move_after_csection',
      title: 'Moving after a caesarean',
      subtitle: 'Written only for mothers who had a C-section.',
      format: 'ACTIVITY',
      bands: _cleared,
      blocks: [
        PpIntro('You had major abdominal surgery and then went straight into '
            'lifting a baby twenty times a day. Nobody would prescribe that '
            'after any other operation. Here is how to rebuild anyway.'),
        PpArticle([
          'The skin closes in a couple of weeks. Underneath, the layers of '
          'muscle sheath, fat and fascia that were cut through are still knitting '
          'at six weeks, still remodelling at six months, and still changing at '
          'a year. That is normal healing, not slow healing.',
          'The scar also tethers. Layers that should glide over each other stick '
          'instead, and the result shows up somewhere else entirely: a pulling '
          'ache, one sided hip or back pain, a numb shelf above the scar, or a '
          'deep core that will not switch on because the area around it is '
          'guarded.',
          'So caesarean recovery has two jobs, not one. Rebuild the deep core, '
          'and free the scar. Doing only the first is why some mothers plateau.',
        ], heading: 'What is still going on under the skin'),
        PpSteps([
          PpStep('Weeks nought to six: breathing, walking, log rolling',
              'Belly breathing from the first days. Roll to your side and push '
              'up rather than folding straight up. Support the wound with a '
              'pillow or your hand when you cough or laugh.'),
          PpStep('Nothing heavier than your baby until you are cleared',
              'That is the usual instruction and it is worth taking literally. '
              'Ask your surgeon for your own limit and your own timeframe.'),
          PpStep('After clearance: scar massage, once it is fully healed',
              'Clean, closed, no scabs, no oozing. Small circles with a little '
              'oil, over the scar and above and below it, five minutes most '
              'days. Firm enough to move the skin, never enough to hurt.'),
          PpStep('Then the connection breath, exactly as on the deep core page',
              'This is where most caesarean mothers start feeling their stomach '
              'again, and it usually takes a few weeks longer than it does after '
              'a vaginal birth.'),
          PpStep('Then bridges, heel slides and supported squats',
              'Exhale on the effort. Watch the scar area for pulling rather than '
              'for pain.'),
          PpStep('Twelve weeks onward: loaded work, still no crunches',
              'Carries, rows, squats with weight. Direct abdominal flexion work '
              'is the last thing to come back, not the first.'),
        ], heading: 'The sequence'),
        // REQUIRED_REVIEW: the lifting restriction ("nothing heavier than your
        // baby" until clearance), the timing of scar massage (only once fully
        // healed, from around six weeks), and the twelve week point for loaded
        // work. Surgical practice varies and these should be confirmed by an
        // obstetrician and a physiotherapist together.
        PpCallout(
          'See your doctor before starting scar massage if the scar is still '
          'red, raised, weeping, opening, or painful to touch, or if there is a '
          'fever. Massaging an unhealed or infected wound makes it worse.',
          kind: PpCalloutKind.doctor,
        ),
        PpCallout(
          'A numb patch above the scar is normal and extremely common. The nerves '
          'were cut and they regrow slowly. Sensation often returns over one to '
          'two years, and sometimes a small area stays numb permanently. Neither '
          'is a sign anything went wrong.',
        ),
        PpVideoSlot(
          title: 'Post caesarean recovery, follow along',
          subtitle: 'A gentle scar aware session with a physiotherapist. Nothing '
              'on your stomach that you are not ready for.',
          minutes: '20 MIN',
          slotId: 'youmaa/move_csection_followalong',
          hue: 152,
        ),
        PpConsult(
          title: 'Post caesarean recovery consult, one to one',
          whoFor: 'For mothers six weeks or more after a caesarean whose scar '
              'pulls, whose stomach still feels disconnected, or who want a '
              'plan built around their own surgery rather than a general one. '
              'A physiotherapist assesses the scar, your breath and your deep '
              'core together.',
          surfaceId: 'pp_experts',
          role: 'physio',
        ),
        PpConsult(
          title: 'Post caesarean recovery programme, small group',
          whoFor: 'A guided programme for caesarean mothers, in a small group, '
              'over several weeks. For mothers who want structure and company '
              'and a lower price than one to one sessions, and who are past '
              'their six week check.',
          surfaceId: 'pp_experts',
          role: 'group_physio',
        ),
        PpLink('The recovery programme, on demand',
            surfaceId: 'pp_courses',
            blurb: 'The recorded course, if a live group does not fit your day.'),
      ],
    ),
    PpPage(
      id: 'move_getting_stronger',
      title: 'Getting stronger, from about three months',
      format: 'ACTIVITY',
      bands: _later,
      blocks: [
        PpIntro('This is the stage nobody talks about, because it is not '
            'dramatic. You are not recovering any more. You are building a body '
            'that can carry a growing child without complaining.'),
        PpArticle([
          'The job description has changed. You now lift a person who gets '
          'heavier every month, off the floor, onto your hip, in and out of a '
          'car seat, usually one handed and usually while holding something '
          'else. That is a strength requirement, and treating it as one is what '
          'stops the back pain.',
          'Strength training after birth is also the best thing available for '
          'your bones, which lose density during breastfeeding and rebuild '
          'afterwards. Two sessions a week does more for you at forty than any '
          'amount of cardio.',
        ], heading: 'What you are actually training for'),
        PpCards([
          PpCard('Squats and sit to stand',
              'Getting off the floor with her. Start with bodyweight, then hold '
              'her, then hold weight.'),
          PpCard('Hip hinges and deadlifts',
              'Picking her up off the floor with your hips instead of your '
              'lower back. The single most useful pattern for a mother.'),
          PpCard('Rows and pulls',
              'The counterweight to hours spent rounded over a feeding baby.'),
          PpCard('Loaded carries',
              'Walking with weight on one side, then the other. This is '
              'literally your day, trained on purpose.'),
          PpCard('Step ups and single leg work',
              'Stairs, kerbs, standing on one leg to put a shoe on. Balance and '
              'hip strength together.'),
          PpCard('Incline planks and side planks',
              'Against a wall or a sofa first. Come to the floor only when the '
              'midline stays flat.'),
        ], heading: 'The six patterns worth your time', hue: 152),
        PpSteps([
          PpStep('Two sessions a week, twenty to thirty minutes',
              'More than that is unrealistic right now and unnecessary.'),
          PpStep('Exhale and connect before every effort',
              'The habit from the deep core page, kept permanently.'),
          PpStep('Add weight only when the last set felt easy',
              'And only when nothing leaks, domes or aches the next day.'),
          PpStep('Stop the set if you leak, dome or hold your breath',
              'Those three are your load gauge. They are more accurate than how '
              'you feel at the time.'),
          PpStep('Keep walking on the other days',
              'Strength and walking do different jobs. You want both.'),
        ], heading: 'How to run it'),
        PpWhenLine('From about three months after a vaginal birth and about '
            'twelve weeks after a caesarean, once the deep core work is '
            'established. Two sessions a week is the useful minimum.'),
        // REQUIRED_REVIEW: the three month and twelve week start points, and the
        // two sessions a week dosage. Should be confirmed against current
        // postnatal exercise guidance and adjusted for complicated births.
        PpCallout(
          'Leaking, heaviness or doming under load is not something to push '
          'through. It means the load is currently more than your system can '
          'manage. Drop the weight, and if it keeps happening see a pelvic floor '
          'physiotherapist.',
          kind: PpCalloutKind.doctor,
        ),
        PpLink('Follow along sessions',
            surfaceId: 'pp_yoga',
            blurb: 'Postnatal strength and mobility from the class library.'),
        PpLink('Postpartum belts, and when they stop helping',
            surfaceId: _shopSurface,
            blurb: 'Useful for support early on. Not a substitute for this.'),
      ],
    ),
    PpPage(
      id: 'move_running',
      title: 'Going back to running, or anything that bounces',
      format: 'ARTICLE',
      bands: [_b3],
      blocks: [
        PpIntro('Running is not banned and it is not the enemy. It is simply the '
            'highest load you can put through a healing pelvic floor, so it is '
            'the last thing to come back rather than the first.'),
        PpArticle([
          'Every running step lands two to three times your body weight through '
          'a system that has spent a year being stretched, and after a vaginal '
          'birth was stretched a great deal in one day. Going back too early is '
          'the commonest route to leaking that becomes permanent and to '
          'prolapse symptoms appearing at thirty five.',
          'The usual guidance is to wait until at least three months and '
          'ideally six, and to pass a simple load test first. Not because '
          'running is dangerous, but because passing the test takes a few weeks '
          'and getting it wrong takes years.',
        ], heading: 'Why this one waits'),
        PpSteps([
          PpStep('Walk thirty minutes briskly with no heaviness or leaking',
              'If a flat thirty minute walk still causes symptoms, you are not '
              'ready. Keep building.'),
          PpStep('Single leg balance, ten seconds each side',
              'And single leg calf raises, ten each side.'),
          PpStep('Twenty squats, twenty single leg sit to stands',
              'No leaking, no heaviness, no breath holding.'),
          PpStep('Jog on the spot for one minute',
              'Then ten hops on each leg, then ten forward bounds. Any leaking '
              'or dragging at any point means not yet.'),
          PpStep('Then start with run walk intervals, not a run',
              'One minute running, two walking, for twenty minutes. Build the '
              'running minutes over several weeks.'),
        ], heading: 'The test to pass before your first run'),
        // REQUIRED_REVIEW: the return to running screen above and the three to
        // six month timeframe. It is adapted from published postnatal return to
        // running guidance and must be confirmed by a pelvic health
        // physiotherapist before it ships as a self administered test.
        PpCallout(
          'See a pelvic floor physiotherapist before you start running if you '
          'had a third or fourth degree tear, if you leak at all, if you feel '
          'any heaviness or bulging, or if you have back or pelvic pain. An '
          'assessment before is far cheaper than treatment after.',
          kind: PpCalloutKind.doctor,
        ),
        PpCards([
          PpCard('Leaking during or after the run',
              'The clearest signal to stop and get assessed.'),
          PpCard('Heaviness or dragging that evening',
              'Even if the run itself felt fine. The load showed up later.'),
          PpCard('Back or pelvic pain that was not there before',
              'Something else is compensating.'),
          PpCard('It gets harder rather than easier over three weeks',
              'A system that is not recovering between sessions.'),
        ], heading: 'Signs to stop and get checked', hue: 12),
        PpWhenLine('Not before three months, ideally not before six, and only '
            'after passing the test above. A good sports bra matters more than '
            'you expect while feeding.'),
      ],
    ),
  ],
);

// =============================================================================
//  6. HAVE YOU EATEN TODAY?
// -----------------------------------------------------------------------------
//  ⚠️ NAMED AS THE QUESTION NOBODY ASKS HER. Everyone in the house asks whether
//  the baby has fed. This area asks the other one, and the title is deliberate.
//
//  ⚠️ NO WEIGHT LOSS FRAMING, ANYWHERE, IN ANY PAGE OF THIS AREA. Not as a goal,
//  not as a benefit, not as an aside. `eat_the_weight_question` states the
//  position outright so the other pages never have to hedge around it. Food here
//  is fuel for healing and for milk, and that is the only frame used.
//
//  ⚠️ THIS AREA IS THE "WHY" AND `_healingKitchen` IS THE "WHAT". Nutrition
//  reasoning lives here; the actual recipes live next door. They cross link
//  rather than repeat, because the commonest failure in a food area is two pages
//  that both half explain iron.
//
//  ⚠️ NO BANNED FOOD LIST. A breastfeeding mother in India is handed one on day
//  one and it costs her most of her diet. This area names the two things that
//  genuinely need care and refuses the rest by name.
// =============================================================================

const PpArea _feedingYourself = PpArea(
  id: 'feeding_yourself',
  mark: IntentMark.feedMark,
  title: 'Have you eaten today?',
  blurb: 'What your body needs while it heals, and while it feeds her.',
  hue: 32,
  pages: [
    PpPage(
      id: 'eat_what_you_need',
      title: 'What your body actually needs right now',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('You are healing a wound the size of a plate inside you, '
            'replacing lost blood, and if you are feeding her you are producing '
            'most of a litre of milk a day. That is a serious job and it needs '
            'to be fed.'),
        PpArticle([
          'Postpartum eating is not a diet and it is not a plan. It is the '
          'simplest thing in this app: eat enough, eat warm, eat regularly, and '
          'make sure protein and iron are actually in there rather than assumed.',
          'The mistake almost every new mother makes is not eating the wrong '
          'foods. It is eating too little and too rarely, standing up, once the '
          'baby is finally down. Three days of that and the tiredness people '
          'blame on sleep is really hunger.',
        ], heading: 'The short version'),
        PpChartCard(
          title: 'What actually matters, in order',
          rows: [
            ('Enough food, at all',
                'Three meals and two or three snacks. Skipping is the real risk.'),
            ('Protein at every meal',
                'Dal, curd, paneer, egg, chicken, fish, rajma, chana. Healing '
                'is built out of protein.'),
            ('Iron, deliberately',
                'Very commonly low after birth in India. See the iron page.'),
            ('Calcium and vitamin D',
                'Breastfeeding draws calcium from your bones. See the calcium '
                'page.'),
            ('Fluid, more than feels necessary',
                'Milk is mostly water and it comes out of you.'),
            ('Fibre',
                'Because constipation after birth is close to universal.'),
          ],
          note: 'Nothing here is exotic and nothing here needs to be bought '
              'special. It is ordinary Indian food, eaten often enough.',
          hue: 32,
        ),
        PpArticle([
          'If you are breastfeeding, your body needs roughly a few hundred extra '
          'calories a day on top of what it needed before pregnancy. In practice '
          'that is two decent snacks, not a different way of eating. Your '
          'appetite will usually tell you, if you let it.',
          'And if you are not breastfeeding, you still need all of the above. '
          'Healing costs the same either way, and the mother who is not feeding '
          'is usually the one told she does not need to eat much. She does.',
        ], heading: 'How much more, honestly'),
        // REQUIRED_REVIEW: the "few hundred extra calories a day" figure for a
        // breastfeeding mother, and the statement that a non breastfeeding
        // mother has the same healing requirements. A dietitian should confirm
        // the number and decide whether it is safer to keep it vague as written
        // or to state a range.
        PpCallout(
          'The one rule worth keeping: never let more than about four waking '
          'hours pass without eating something. Not because of metabolism, but '
          'because low blood sugar makes everything else about this day harder.',
        ),
        PpIndiaNote('If your family is cooking for you during jaapa, this is the '
            'easiest it will ever be to eat well, and it is worth saying out '
            'loud what you actually want. Ask for dal, curd and an egg as often '
            'as you ask for laddoo.'),
        PpLink('Recipes for you, not the baby',
            surfaceId: 'pp_food',
            blurb: 'The jaapa foods, the laddoos and the one handed meals live '
                'in "The healing kitchen". This opens the wider library.'),
      ],
    ),
    PpPage(
      id: 'eat_while_feeding',
      title: 'Eating while breastfeeding, without the banned list',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Someone has probably given you a list of foods you must not '
            'eat. Almost none of it is true, and following it is how a feeding '
            'mother ends up on rice and dal for six months.'),
        PpArticle([
          'Your milk is made from your blood, not directly from your last meal. '
          'What you eat changes the flavour slightly and changes very little '
          'else. Babies across the world are fed by mothers eating garlic, '
          'chilli, rajma, cabbage and fish, and their babies are fine.',
          'The mother who cuts out half of Indian cooking to avoid gas in the '
          'baby usually ends up more tired, less well fed, and with a baby whose '
          'wind was never about her food in the first place. Newborn digestive '
          'noise is newborn digestive noise.',
        ], heading: 'What actually reaches your milk'),
        PpCards([
          PpCard('Rajma, chana and cabbage cause gas in the baby',
              'Gas does not pass into milk. The compounds that cause it in you '
              'do not reach her.'),
          PpCard('Spicy food upsets the baby',
              'Babies in every spice eating culture do fine. If she reacts to '
              'one specific thing, that is worth noticing. A blanket ban is not.'),
          PpCard('Sour or cold food will give her a cold',
              'Colds come from viruses. Curd, buttermilk and fruit are among the '
              'most useful things you can eat.'),
          PpCard('You must drink milk to make milk',
              'Cows make milk eating grass. Milk is a good source of protein and '
              'calcium, and it is not a requirement.'),
          PpCard('Papaya, pineapple and brinjal are forbidden',
              'These are pregnancy beliefs carried forward. They are food.'),
        ], heading: 'The bans you will be given, and what is true', hue: 32),
        PpArticle([
          'Two things do genuinely need care. Alcohol passes into milk, so if '
          'you drink, feed first and then leave a couple of hours per drink '
          'before the next feed. Caffeine passes in small amounts and a newborn '
          'clears it slowly, so two or three cups of tea or coffee a day is '
          'usually fine and six is worth cutting back.',
          'And a very small number of babies react to cow\'s milk protein in the '
          'mother\'s diet, with blood or mucus in the stool, eczema and real '
          'distress. That is a real thing, it is uncommon, and it is diagnosed '
          'by a doctor rather than guessed at by removing foods one by one.',
        ], heading: 'The two that are actually worth care'),
        // REQUIRED_REVIEW: the alcohol guidance (feed first, roughly two hours
        // per standard drink) and the caffeine ceiling (two to three cups
        // daily). Both are standard but the exact framing should be signed off,
        // and a decision made on whether alcohol guidance belongs in the Indian
        // build at all.
        PpCallout(
          'See your paediatrician before cutting anything out of your diet for '
          'the baby\'s sake. Blood or mucus in her stool, or eczema with real '
          'distress, needs a doctor and a proper plan. Removing foods on a guess '
          'starves you and rarely finds the answer.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('If you are being told not to eat something and you cannot '
            'win the argument, you do not have to win it. Eat it when you are '
            'out, or eat it at your own house, or say the doctor told you to. '
            'Six months of restricted eating costs you more than one '
            'disagreement does.'),
      ],
    ),
    PpPage(
      id: 'eat_iron',
      title: 'Iron, and why you are so tired',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('If you are exhausted in a way that sleep does not touch, iron '
            'is the first thing to check. Most Indian mothers finish pregnancy '
            'already low, and then lose more blood at delivery.'),
        PpArticle([
          'Anaemia after birth is not a minor footnote here. A large share of '
          'Indian women are anaemic before they conceive, pregnancy draws on '
          'those stores, and birth takes several hundred millilitres of blood on '
          'top. The result is a mother who is told she is tired because of the '
          'baby when she is actually short of the thing that carries oxygen.',
          'It is worth checking rather than guessing, because the fix is simple '
          'and the difference is large. Mothers who correct it usually describe '
          'the change as getting their brain back, not just their energy.',
        ], heading: 'Why this is the first thing to look at'),
        PpCards([
          PpCard('Breathless climbing one flight of stairs',
              'Something you did without noticing before.'),
          PpCard('Dizzy or greying out when you stand up',
              'Especially first thing in the morning.'),
          PpCard('Heart racing or pounding at rest',
              'Your body compensating for thinner blood.'),
          PpCard('Pale inner eyelids, palms or nail beds',
              'Pull down your lower eyelid and look. Very pale is a sign.'),
          PpCard('Hair falling in handfuls beyond the usual postpartum shed',
              'Iron deficiency worsens it.'),
          PpCard('Cold hands and feet, and a tiredness sleep does not fix',
              'The one mothers describe most often.'),
        ], heading: 'What low iron feels like', hue: 32),
        PpCallout(
          'Ask your doctor for a haemoglobin test rather than starting a '
          'supplement on your own. Only a test tells you whether you are low, '
          'how low, and whether iron tablets alone will be enough. Some mothers '
          'need a different form or an infusion, and that is a decision for a '
          'doctor.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: this whole page, and specifically the symptom list
        // and the instruction to request a haemoglobin test rather than
        // self supplement. It must read as "get checked", never as "you are
        // anaemic". A clinician should also decide whether to name a routine
        // postpartum haemoglobin check as standard advice.
        PpSteps([
          PpStep('Eat iron with something sour, not with tea',
              'Vitamin C multiplies how much iron you absorb. Lemon on the dal, '
              'amla, orange, guava, tomato. Tea and coffee within an hour of a '
              'meal block it, and that habit alone undoes a lot of good eating.'),
          PpStep('Cook in an iron kadhai',
              'Especially anything sour or tomato based. It genuinely adds iron '
              'to the food and it costs nothing.'),
          PpStep('Put iron rich foods in on purpose',
              'Palak and other greens, beetroot, dates, raisins, jaggery, '
              'ragi, chana, rajma, liver and red meat if you eat it.'),
          PpStep('If you are on tablets, take them and keep taking them',
              'The full course, not until you feel better. Stores take months '
              'to refill after the haemoglobin looks normal.'),
          PpStep('Do not stop iron because it constipates you',
              'Ask your doctor for a different form or a stool softener '
              'alongside. Stopping trades a small problem for a bigger one.'),
        ], heading: 'How to actually get iron in'),
        PpWhenLine('Worth checking at the six week visit, and again any time '
            'the exhaustion is not improving. Correcting stores takes about '
            'three months of consistent treatment, not two weeks.'),
        PpLink('The iron rich cooking',
            surfaceId: 'pp_food',
            blurb: 'Dates, beetroot, palak and gur are written up as recipes in '
                '"The healing kitchen". This opens the wider library.'),
      ],
    ),
    PpPage(
      id: 'eat_calcium',
      title: 'Calcium, your bones, and the sun you never see',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Breastfeeding takes calcium out of your bones to put it in her '
            'milk, whatever you eat. Your body rebuilds it afterwards, and it '
            'rebuilds better if the raw material is there.'),
        PpArticle([
          'Bone density drops measurably over months of breastfeeding and comes '
          'back over the months after weaning. That is normal and it is not a '
          'reason to stop feeding. It does mean this is a bad year to eat '
          'almost no calcium, which is easy to do without noticing.',
          'The bigger gap in India is usually vitamin D rather than calcium. '
          'Without it you absorb only a fraction of the calcium you eat, and '
          'deficiency is extremely common here even in sunny cities, because '
          'most women spend the day indoors and cover up outdoors. A mother in '
          'jaapa confinement sees no sun at all for forty days.',
        ], heading: 'What is happening to your bones'),
        PpChartCard(
          title: 'Where calcium actually comes from',
          rows: [
            ('Milk, curd, paneer, buttermilk', 'The easiest and the densest.'),
            ('Ragi', 'One of the richest non dairy sources there is.'),
            ('Til, or sesame', 'Til laddoo and til chutney are real calcium.'),
            ('Almonds and other nuts', 'Handy, and useful while feeding.'),
            ('Green leafy vegetables', 'Sarson, methi leaves, drumstick leaves.'),
            ('Small fish eaten with bones', 'If you eat fish, this is excellent.'),
          ],
          note: 'Two or three servings of the top group a day, or a deliberate '
              'mix of the rest if you do not eat dairy.',
          hue: 32,
        ),
        PpSteps([
          PpStep('Get some direct sun on your arms, most days',
              'Fifteen to twenty minutes of morning or late afternoon sun on '
              'bare forearms. A balcony counts. Through glass does not.'),
          PpStep('Ask your doctor whether you need a vitamin D supplement',
              'Many Indian mothers are prescribed one routinely. It is a blood '
              'test and a weekly or monthly dose, not a daily fight.'),
          PpStep('Keep calcium in every day, not in bursts',
              'A glass of milk or a bowl of curd, plus one other source.'),
          PpStep('Do not take iron and calcium at the same time',
              'They compete. Space them by a couple of hours if you are taking '
              'both as supplements.'),
        ], heading: 'What to do about it'),
        // REQUIRED_REVIEW: the daily calcium target implied here, the sun
        // exposure guidance (fifteen to twenty minutes on bare forearms), and
        // the note that iron and calcium supplements compete. A dietitian and a
        // clinician should confirm, and decide whether a numeric daily target
        // should be stated at all.
        PpCallout(
          'Ask your doctor about your bones, not the internet, if you have back '
          'or hip pain that is not muscular, if you have had a fracture easily, '
          'or if you are feeding beyond a year with very little dairy in your '
          'diet.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('Forty days indoors is the part of jaapa most worth '
            'negotiating. Ten minutes on the balcony in the morning sun is not '
            'breaking confinement and it is one of the few things in this whole '
            'list that is free.'),
      ],
    ),
    PpPage(
      id: 'eat_water',
      title: 'Why you are so thirsty, and what to do about it',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('The thirst that hits the moment the baby latches surprises '
            'almost everyone. It is real, it is physiological, and it is the '
            'easiest thing on this whole list to fix.'),
        PpArticle([
          'Breast milk is around nine tenths water and you are making several '
          'hundred millilitres of it a day. Your body signals for the '
          'replacement hard, usually the second she starts feeding, which is '
          'exactly when you cannot reach anything.',
          'Drinking more water does not increase your supply, and this is worth '
          'knowing because a lot of mothers are told to force litres down. '
          'Drinking enough prevents the headache, the constipation and the '
          'flattened afternoon. That is the actual benefit.',
        ], heading: 'What is going on'),
        PpSteps([
          PpStep('Put a bottle wherever you feed, before you sit down',
              'The single most effective habit in this area. A bottle with a '
              'straw you can use one handed is better still.'),
          PpStep('Drink a glass at the start of every feed',
              'Attached to something you already do a dozen times a day, so it '
              'needs no remembering.'),
          PpStep('Check the colour, not the count',
              'Pale straw is fine. Dark yellow means drink more. This is more '
              'useful than counting glasses.'),
          PpStep('Warm counts, and in jaapa it is easier to get',
              'Warm water, jeera water, saunf water, thin buttermilk, coconut '
              'water, milk, soup. All of it is fluid.'),
          PpStep('Go easy on very sweet drinks and lots of tea',
              'Sweet drinks add up fast, and tea with meals blocks your iron.'),
        ], heading: 'What actually works'),
        PpCallout(
          'Forcing large amounts of water does not make more milk, and a few '
          'mothers who drink very large volumes actually feel their supply dip. '
          'Drink to thirst and a little beyond. That is the whole rule.',
          kind: PpCalloutKind.myth,
        ),
        PpWhenLine('From the first feed onward. Roughly a glass at every feed '
            'plus what you would normally drink, adjusted by the colour of your '
            'urine and the weather.'),
        // REQUIRED_REVIEW: the "glass at every feed" heuristic and the urine
        // colour guidance, and the claim that very high intake can reduce
        // supply. A lactation consultant should confirm all three.
        PpIndiaNote('In a Delhi or Chennai summer, add to all of this. A mother '
            'feeding in forty degree heat with a fan and no cooler is losing '
            'fluid she is not accounting for. Nimbu paani with a pinch of salt '
            'is genuinely useful on those days.'),
        PpLink('The drinks, as recipes',
            surfaceId: 'pp_food',
            blurb: 'Jeera water, saunf water, ajwain water and the kadha are in '
                '"The healing kitchen". This opens the wider library.'),
      ],
    ),
    PpPage(
      id: 'eat_no_appetite',
      title: 'When you have no appetite, or no hands, or no time',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('There are days when eating is genuinely not possible in the '
            'normal way. This page is for those, and it does not ask you to '
            'plan, prep or cook anything.'),
        PpArticle([
          'Appetite after birth goes two ways. Some mothers are ravenous at 3am '
          'and cannot get enough. Others feel completely uninterested in food '
          'for weeks, especially if the birth was hard, if pain is in the way, '
          'or if the days have flattened out.',
          'A missing appetite for a few days is ordinary. A missing appetite '
          'for weeks, with no pleasure in anything else either, is worth '
          'reading about on the mind pages rather than solving with recipes. '
          'The two look identical from the outside and they need different help.',
        ], heading: 'Two different problems that look the same'),
        PpCards([
          PpCard('Keep food where you sit, not where you cook',
              'A jar of laddoo, dry fruit, chana, a banana, next to the feeding '
              'chair. Whatever is within reach is what gets eaten.'),
          PpCard('Eat one handed on purpose',
              'Roti roll, paratha wrap, idli, boiled egg, banana, sandwich. '
              'Foods that survive being put down and picked up again.'),
          PpCard('Drink your meal when you cannot eat it',
              'Milk with a banana, thick lassi, dal soup, sattu drink. Fewer '
              'calories skipped than a skipped meal.'),
          PpCard('Say yes when someone offers to bring food',
              'Every time. And answer honestly when they ask what you want.'),
          PpCard('Ask for one big thing rather than three small ones',
              'A pot of dal or khichdi that lasts three days is worth more than '
              'a fresh meal you have to wait for.'),
          PpCard('Eat before you feed her, not after',
              'After is theoretical. Before actually happens.'),
        ], heading: 'What works when nothing works', hue: 32),
        PpCallout(
          'Talk to your doctor if you have not really eaten for several days, if '
          'food makes you nauseous, if you are losing weight quickly, or if the '
          'appetite went away at the same time as everything else did. The last '
          'one is often the first sign of postpartum depression and it responds '
          'well to help.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the threshold for escalating loss of appetite
        // ("several days", rapid weight loss) and the link drawn between
        // appetite loss and postpartum depression. Both should be confirmed so
        // the page routes early enough without alarming.
        PpIndiaNote('If the appetite went at the same time as everything else '
            'did, open "I do not feel like myself" instead '
            'of this area, and start with the page on baby blues and postpartum '
            'depression. The one handed meals themselves are in "The healing '
            'kitchen".'),
      ],
    ),
    PpPage(
      id: 'eat_the_weight_question',
      title: 'The weight question, answered honestly once',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('You are going to be asked about it, so here is the app\'s '
            'position in full. It will not change on a later page and it is not '
            'a softer way of saying the usual thing.'),
        PpArticle([
          'You did not gain weight by accident. You grew a baby, a placenta, '
          'litres of extra blood, more fluid in every tissue, an enlarged uterus '
          'and a store of fat your body built on purpose to fuel feeding. Most '
          'of that leaves in its own time. The part that is fat is there because '
          'your body put it there for a reason that has not finished yet.',
          'Eating too little while breastfeeding and healing is the one genuinely '
          'risky thing you could do this year. It slows healing, worsens '
          'anaemia, flattens your mood, and for some mothers it reduces supply. '
          'A crash diet at three months postpartum is not discipline. It is a '
          'body being asked to do two jobs on the fuel for none.',
          'Your body will change over the next year or two whether or not you '
          'manage it. Some of it will come back to where it was. Some of it will '
          'not, and that is not a failure of effort. Wider ribs and a different '
          'shape are common and permanent for a lot of mothers.',
        ], heading: 'What that weight actually is'),
        PpCallout(
          'This app will never set you a weight goal, never show you a before '
          'and after, and never sell you anything on the basis of how you look. '
          'If you want to feel stronger, the movement pages are there. They are '
          'about carrying her without pain, and that is genuinely what they are '
          'about.',
        ),
        PpCards([
          PpCard('You are eating enough to not be starving by evening',
              'The floor, and most mothers are under it.'),
          PpCard('Protein and iron are actually in the day',
              'Not assumed to be in there somewhere.'),
          PpCard('You are moving in a way you would repeat next week',
              'Sustainable beats intense, always, and especially now.'),
          PpCard('You are sleeping whenever the opportunity exists',
              'Short sleep drives appetite and mood harder than any food rule.'),
        ], heading: 'What a good year of eating looks like instead', hue: 32),
        PpCallout(
          'Breastfeeding makes you lose weight fast is true for some mothers and '
          'not others, and it is not something you control. Two mothers eating '
          'the same food and feeding the same baby end up in different places. '
          'That is biology, not effort.',
          kind: PpCalloutKind.myth,
        ),
        PpIndiaNote('The belt will be recommended to you within days, often by '
            'someone who wore one herself. Worn for a few hours for support '
            'while your stomach feels unheld, it is fine and it feels good. Worn '
            'all day to make the stomach smaller, it lets the muscles switch off '
            'further and it does not change anything underneath.'),
        PpWhenLine('There is no timeline here to hit and none to miss. If you '
            'want a plan, wait until feeding is established, eat properly, and '
            'talk to a dietitian rather than an app.'),
      ],
    ),
  ],
);

// =============================================================================
//  7. THE HEALING KITCHEN
// -----------------------------------------------------------------------------
//  ⚠️ THIS AREA TAKES THE TRADITION SERIOUSLY AND THEN SAYS WHERE IT GOES TOO
//  FAR, AND BOTH HALVES ARE REQUIRED. An app that dismisses jaapa food as
//  superstition loses the mother on page one and is also wrong: gond, methi,
//  ajwain, saunf and warm ghee laden food are calorie dense, iron and calcium
//  rich, and warm at exactly the moment a body needs all four. Most of it is good
//  postnatal nutrition arrived at without a nutrition label.
//
//  An app that repeats all of it uncritically is worse, because the same
//  tradition also produces a mother eating six laddoo a day with undiagnosed
//  gestational diabetes, a mother denied water because it is "cold", and a mother
//  living on three permitted foods for forty days. `kitchen_where_it_goes_too_far`
//  is the page that does that job, and it does it without calling anybody's
//  grandmother stupid.
//
//  ⚠️ RECIPE PAGES ARE REAL RECIPES, not gestures. Ingredients in Indian
//  household measures, method as steps, why it helps, and the honest line on what
//  it does not do. Each carries a cook along video slot.
//
//  ⚠️ NO RECIPE HERE IS SOLD AS A MILK BOOSTER WITHOUT A CAVEAT. Galactagogue
//  evidence is thin and the harm of the claim is not: a mother whose supply is
//  actually a latch problem eats laddoo for three weeks while the real cause goes
//  unaddressed. Every supply page routes to a feeding assessment.
// =============================================================================

const PpArea _healingKitchen = PpArea(
  id: 'healing_kitchen',
  mark: IntentMark.compassMark,
  title: 'The healing kitchen',
  blurb: 'Jaapa food, the laddoos, the kadha, and where the tradition goes too '
      'far.',
  hue: 42,
  pages: [
    PpPage(
      id: 'kitchen_jaapa',
      title: 'What jaapa food is actually doing',
      format: 'ARTICLE',
      bands: _early,
      blocks: [
        PpIntro('The forty day kitchen your family is running has more sense in '
            'it than you might expect. It is worth knowing what each part is '
            'for, because then you can keep the useful half and negotiate the '
            'rest.'),
        PpArticle([
          'Jaapa food across India varies enormously in the details and agrees '
          'on the shape: warm, cooked soft, calorie dense, heavy on ghee, nuts '
          'and gum, spiced with ajwain, saunf, methi, sonth and haldi, and fed '
          'to her frequently by somebody else. Nobody arrived at that by reading '
          'a nutrition paper. It arrived by watching what helped.',
          'And most of it maps onto what a healing, feeding body actually needs. '
          'Calorie dense because she needs several hundred extra calories and no '
          'time to eat them. Ghee and nuts because fat is dense energy and helps '
          'her absorb the vitamins in everything else. Gond and til because they '
          'are among the richest calcium sources in an Indian kitchen. Ajwain '
          'and saunf because her gut is slow and sore. Warm and soft because '
          'chewing and digesting are effort she does not have.',
          'The one part with no mechanism behind it is the restriction: the '
          'foods forbidden, the water withheld, the vegetables ruled out for '
          'forty days. That half was never the nutrition. It is worth separating '
          'from the half that is.',
        ], heading: 'Why the tradition looks the way it does'),
        PpChartCard(
          title: 'What the jaapa kitchen gets right',
          rows: [
            ('Warm, soft, cooked food', 'Easy on a slow gut and a sore body.'),
            ('Ghee, nuts and gond',
                'Dense calories, calcium and fat soluble vitamins.'),
            ('Ajwain, saunf, sonth, jeera',
                'Genuinely help wind, bloating and a sluggish gut.'),
            ('Methi and til',
                'Iron and calcium, in a form she will actually eat.'),
            ('Fed frequently, by someone else',
                'The single most useful part, and the least discussed.'),
            ('Company in the kitchen',
                'The women around her are also the reason she is not alone.'),
          ],
          note: 'Keep all of this. The page on where it goes too far deals with '
              'the rest.',
          hue: 42,
        ),
        PpCallout(
          'The part of jaapa worth protecting hardest is not any food. It is '
          'that somebody else is cooking, so you eat without standing up. When '
          'the forty days end, that is the thing that disappears and the thing '
          'you will miss.',
        ),
        PpIndiaNote('If you are doing jaapa away from home, or without family, '
            'the shortcut most mothers use is a batch of laddoo and a big pot of '
            'dal or khichdi twice a week. It is not the full tradition. It '
            'covers most of what the tradition was doing.'),
      ],
    ),
    PpPage(
      id: 'kitchen_gond_laddoo',
      title: 'Gond ke laddoo',
      subtitle: 'The one worth making first.',
      format: 'RECIPE',
      bands: _early,
      blocks: [
        PpIntro('Edible gum, ghee, dry fruit and gur, rolled into something you '
            'can eat with one hand at 3am. It is the most useful single food in '
            'the jaapa kitchen and it keeps for weeks.'),
        PpArticle([
          'Gond is edible gum from a tree, and it puffs up like popcorn when it '
          'hits hot ghee. Traditionally it is given for joint strength and back '
          'recovery after birth. What it certainly does is carry a lot of '
          'calcium and a lot of energy in a small, sweet, portable form.',
          'Whether it strengthens joints is not something anyone has properly '
          'measured. What it does reliably is keep a mother from going five '
          'hours without eating, which is a real benefit and enough on its own.',
        ], heading: 'Why this one'),
        PpChartCard(
          title: 'What you need, for about twenty laddoo',
          rows: [
            ('Gond, edible gum', '100 g'),
            ('Whole wheat flour', '1 cup'),
            ('Ghee', 'About 1 cup, some for frying the gond'),
            ('Gur or jaggery, grated', '1 to 1.5 cups, to taste'),
            ('Almonds, cashews, pistachio, chopped', '1 cup total'),
            ('Makhana, optional', '1 cup, roasted and crushed'),
            ('Elaichi powder', '1 tsp'),
            ('Sonth, dry ginger powder', '1 tsp, optional'),
          ],
          hue: 42,
        ),
        PpSteps([
          PpStep('Fry the gond in hot ghee, in small batches',
              'It puffs up several times its size. Do not crowd the pan. Lift '
              'it out when it has puffed and gone pale, and let it cool.'),
          PpStep('Crush the cooled gond coarsely',
              'A rolling pin or a mixer on a single pulse. Some texture is '
              'good.'),
          PpStep('Roast the wheat flour in ghee on a low flame',
              'Ten to fifteen minutes, stirring, until it turns golden and '
              'smells nutty. This step decides the whole thing. Rushing it '
              'leaves a raw taste.'),
          PpStep('Add the nuts and makhana and roast a minute more',
              'Then take the pan off the heat.'),
          PpStep('Let it cool until warm, then add the gur',
              'Hot flour melts jaggery into syrup and the laddoo will not hold. '
              'Warm is the right temperature.'),
          PpStep('Add the gond, elaichi and sonth, and mix well',
              'Taste it. Add more gur now if it needs it.'),
          PpStep('Roll while still warm, and store airtight',
              'If it will not hold, add a spoon of warm ghee. Keeps three to '
              'four weeks in a cool cupboard.'),
        ], heading: 'How to make it'),
        PpWhenLine('From the first days after birth, one or two a day, usually '
            'in the morning or with a glass of warm milk. Traditionally eaten '
            'through the first forty days.'),
        PpCallout(
          'One or two a day is the amount that helps. Six a day is a lot of '
          'jaggery and ghee, and it is where a good food starts working against '
          'you. Nobody in the house will tell you to stop, so this is the page '
          'that does.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'Ask your doctor before eating these daily if you had gestational '
          'diabetes, if your sugar was high in pregnancy, or if you have been '
          'told you are at risk of diabetes. Gur is still sugar, and a mother '
          'who had gestational diabetes needs a check at about six to twelve '
          'weeks after birth anyway.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the "one or two a day" dose, and the gestational
        // diabetes caution including the six to twelve week follow up glucose
        // test. A clinician should confirm both, and confirm we are right to
        // place the caution on the recipe page rather than only on a general
        // page nobody opens.
        PpVideoSlot(
          title: 'Gond ke laddoo, start to finish',
          subtitle: 'Including what the gond should look like when it is '
              'properly puffed, which is the step everyone gets wrong.',
          minutes: '9 MIN',
          slotId: 'youmaa/recipe_gond_laddoo',
          hue: 42,
        ),
        PpIndiaNote('Every family has its own version and yours is probably '
            'better than this one. Ask for it before your mother or your saas '
            'goes home. These recipes are the ones that get lost.'),
      ],
    ),
    PpPage(
      id: 'kitchen_methi_laddoo',
      title: 'Methi laddoo, and the truth about methi for milk',
      format: 'RECIPE',
      bands: _early,
      blocks: [
        PpIntro('Methi is the food most often pushed at a new mother in India, '
            'usually for milk supply. It is genuinely good food. The milk claim '
            'needs a more careful answer than you will be given.'),
        PpArticle([
          'Fenugreek is the most studied galactagogue there is, and the studies '
          'are small, mixed and mostly poor quality. Some mothers report a '
          'noticeable increase within a couple of days. Others notice nothing. '
          'Nobody can predict which you will be.',
          'What is not in doubt is that methi seeds are rich in iron and fibre, '
          'that methi laddoo is warm dense food at a time when you need it, and '
          'that eating properly supports supply regardless of any herb in it.',
          'The important part is what a supply problem usually turns out to be. '
          'Most low supply is about how often and how well the baby is removing '
          'milk, not about what the mother ate. Three weeks of laddoo while a '
          'shallow latch goes unfixed is three weeks lost.',
        ], heading: 'What methi does and does not do'),
        PpChartCard(
          title: 'What you need, for about twenty laddoo',
          rows: [
            ('Methi seeds, ground fine', '4 to 5 tbsp'),
            ('Whole wheat flour', '1.5 cups'),
            ('Ghee', 'About 1 cup'),
            ('Gur or jaggery, grated', '1 to 1.5 cups'),
            ('Milk, warm', '2 to 3 tbsp, to soak the methi'),
            ('Almonds and cashews, chopped', '1 cup'),
            ('Gond, fried and crushed, optional', '50 g'),
            ('Elaichi and sonth', '1 tsp each'),
          ],
          hue: 42,
        ),
        PpSteps([
          PpStep('Soak the ground methi in warm milk for a few hours',
              'This is what takes the bitterness down. Skipping it is why some '
              'methi laddoo are inedible.'),
          PpStep('Roast the soaked methi in ghee on a low flame',
              'Five to seven minutes, until the raw smell goes. Keep the flame '
              'low or it turns bitter again.'),
          PpStep('Roast the wheat flour separately in ghee until golden',
              'Ten to fifteen minutes on low. Nutty, not brown.'),
          PpStep('Combine, add the nuts and gond, and cool to warm',
              'Not hot, or the gur will melt and run.'),
          PpStep('Add gur, elaichi and sonth, mix and roll',
              'Store airtight. Keeps about three weeks.'),
        ], heading: 'How to make it'),
        PpWhenLine('One a day is the usual amount, from the early weeks. Methi '
            'has a strong smell that comes through in your sweat and sometimes '
            'in your milk. That is harmless.'),
        PpCallout(
          'Talk to your doctor before taking methi in large amounts or as a '
          'supplement if you are diabetic or on any medicine for blood sugar. '
          'Fenugreek can lower blood sugar, which matters if something else is '
          'already doing that. It can also worsen reflux and cause wind.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the statement that fenugreek can lower blood sugar
        // and the caution for diabetic mothers, plus the honest framing of
        // galactagogue evidence. A lactation consultant and a clinician should
        // both sign this page off, because it contradicts advice she is being
        // given at home.
        PpCallout(
          'If your supply genuinely worries you, a feeding assessment is worth '
          'more than any food. Someone watching one full feed usually finds the '
          'answer in ten minutes.',
        ),
        PpConsult(
          title: 'Breastfeeding and supply assessment',
          whoFor: 'For any mother worried about supply, painful feeding, a '
              'shallow latch, or a baby who feeds constantly and still seems '
              'hungry. A lactation consultant watches a real feed rather than '
              'asking you to describe one.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        PpVideoSlot(
          title: 'Methi laddoo without the bitterness',
          subtitle: 'The soaking step, the roasting temperature, and how to know '
              'when the raw smell has gone.',
          minutes: '8 MIN',
          slotId: 'youmaa/recipe_methi_laddoo',
          hue: 42,
        ),
      ],
    ),
    PpPage(
      id: 'kitchen_panjiri_harira',
      title: 'Panjiri and harira',
      subtitle: 'The two that get made in the first week.',
      format: 'RECIPE',
      bands: _early,
      blocks: [
        PpIntro('Panjiri is the loose version of a laddoo, eaten by the spoon. '
            'Harira is the warm drink made in the first days. Both are made '
            'early because in the first week chewing is more effort than it '
            'sounds.'),
        PpChartCard(
          title: 'Panjiri, for a jar that lasts two weeks',
          rows: [
            ('Whole wheat flour', '2 cups'),
            ('Ghee', '1 cup'),
            ('Gur, grated, or boora', '1 to 1.5 cups'),
            ('Gond, fried and crushed', '50 g'),
            ('Melon seeds, magaz', '0.5 cup'),
            ('Almonds, cashews, pista, chopped', '1 cup'),
            ('Makhana, roasted and crushed', '1 cup'),
            ('Sonth, elaichi, kali mirch', '1 tsp each'),
          ],
          hue: 42,
        ),
        PpSteps([
          PpStep('Roast the flour in ghee on low heat until golden',
              'Fifteen minutes, patiently. This is the whole recipe.'),
          PpStep('Fry the gond separately until it puffs, then crush it',
              'And roast the makhana and seeds until they crisp.'),
          PpStep('Mix everything off the heat and cool to warm',
              'Then add the gur and the spices.'),
          PpStep('Store in a jar and eat two spoons at a time',
              'With warm milk, or by itself. No rolling, no shaping.'),
        ], heading: 'Panjiri, step by step'),
        PpChartCard(
          title: 'Harira, one warm glass',
          rows: [
            ('Ghee', '1 tbsp'),
            ('Whole wheat flour or almond powder', '2 tbsp'),
            ('Milk', '1 glass'),
            ('Gur or sugar', 'To taste'),
            ('Sonth, haldi, kali mirch, elaichi', 'A pinch of each'),
            ('Chopped almonds', 'A few'),
          ],
          hue: 42,
        ),
        PpSteps([
          PpStep('Warm the ghee and roast the flour until it smells nutty',
              'Two or three minutes on a low flame.'),
          PpStep('Add the sonth and haldi and stir for a few seconds',
              'Then pour in the milk slowly, whisking so it does not lump.'),
          PpStep('Simmer for five minutes until it thickens slightly',
              'Add gur at the end, off the heat, so it does not split the '
              'milk.'),
          PpStep('Drink warm, once a day in the early weeks',
              'Usually in the morning or at night.'),
        ], heading: 'Harira, step by step'),
        PpWhenLine('Both from the first days. Harira once a day for the first '
            'week or two, panjiri two spoons once or twice a day through the '
            'first forty days.'),
        PpCallout(
          'Skip harira if you are avoiding dairy, or make it with almond milk. '
          'And keep the same limit as the laddoo: this is dense food, and two '
          'spoons is a portion, not a starting point.',
          kind: PpCalloutKind.safety,
        ),
        PpVideoSlot(
          title: 'Panjiri and harira, both in one go',
          subtitle: 'Made in the same pan, in about twenty minutes.',
          minutes: '11 MIN',
          slotId: 'youmaa/recipe_panjiri_harira',
          hue: 42,
        ),
        PpIndiaNote('In Punjab it is panjiri, in the south it is a different '
            'preparation, in Maharashtra it is dink laddoo. The ingredients '
            'differ and the idea is identical. Use whichever your family makes.'),
      ],
    ),
    PpPage(
      id: 'kitchen_drinks',
      title: 'Ajwain water, jeera water and the kadha',
      format: 'RECIPE',
      bands: _allBands,
      blocks: [
        PpIntro('These three are the most quietly useful things in the healing '
            'kitchen. They cost almost nothing, they are warm, and they solve '
            'the wind and bloating that nobody warned you about.'),
        PpArticle([
          'After birth the gut is slow, stretched and full of air, and it stays '
          'that way for a few weeks. Ajwain, jeera and saunf are carminatives, '
          'which is a formal way of saying they help wind move. This is one of '
          'the places where the traditional remedy and the pharmacology agree '
          'without argument.',
          'They are also the easiest way to get warm fluid into a mother who is '
          'thirsty all day and cannot be bothered with plain water.',
        ], heading: 'Why these work'),
        PpSteps([
          PpStep('Ajwain water: one teaspoon of ajwain in a litre of water',
              'Boil for five minutes, strain into a flask, sip warm through the '
              'day. For bloating and wind, and traditionally for the uterus '
              'settling back.'),
          PpStep('Jeera water: one teaspoon of jeera, same method',
              'Milder than ajwain. Good all day, and easy to drink a lot of.'),
          PpStep('Saunf water: one teaspoon of fennel, soaked or boiled',
              'Sweeter. Best after meals, and it helps if you are constipated.'),
          PpStep('Sonth, dry ginger, added to any of the three',
              'A quarter teaspoon. Warming, and it helps if you feel cold and '
              'achy, which many mothers do.'),
        ], heading: 'The three waters'),
        PpChartCard(
          title: 'The postpartum kadha, one small cup',
          rows: [
            ('Water', '2 cups, reduced to 1'),
            ('Ajwain', '0.5 tsp'),
            ('Saunf', '0.5 tsp'),
            ('Sonth or fresh ginger', '0.5 tsp'),
            ('Haldi', '0.25 tsp'),
            ('Tulsi leaves', '4 or 5'),
            ('Kali mirch', '2 or 3, crushed'),
            ('Gur', 'A small piece, at the end'),
          ],
          note: 'Simmer everything except the gur for ten minutes until it '
              'reduces by half. Strain, add gur, drink warm. Once a day.',
          hue: 42,
        ),
        PpWhenLine('From the first days. Ajwain or jeera water through the day, '
            'kadha once daily for the first few weeks. Stop the kadha if it '
            'gives you heartburn, which it does to some mothers.'),
        PpCallout(
          'Warm water, in any of these forms, counts fully towards your fluid '
          'for the day. If plain water is being withheld from you because it is '
          '"cold", ask for it warm rather than accepting less of it. A '
          'dehydrated mother is not a well one.',
          kind: PpCalloutKind.safety,
        ),
        // REQUIRED_REVIEW: the kadha ingredients and the once daily frequency,
        // and the claim that ajwain and jeera help postpartum wind. Widely used
        // and low risk, but an ayurvedic practitioner or clinician should
        // confirm quantities and confirm there is nothing here that interacts
        // with common postpartum medication.
        PpVideoSlot(
          title: 'The three waters and the kadha',
          subtitle: 'Made once, kept in a flask, drunk all day.',
          minutes: '6 MIN',
          slotId: 'youmaa/recipe_kadha',
          hue: 42,
        ),
      ],
    ),
    PpPage(
      id: 'kitchen_iron_foods',
      title: 'Cooking for iron: dates, beetroot, palak and gur',
      format: 'RECIPE',
      bands: _allBands,
      blocks: [
        PpIntro('The iron page explains why this matters. This one is what to '
            'actually cook, and the small tricks that decide whether the iron in '
            'the food reaches your blood at all.'),
        PpArticle([
          'Iron from plants is absorbed much less easily than iron from meat, '
          'and what you eat alongside it changes the amount by several times. '
          'That is the whole reason this page exists. The same plate of palak '
          'can deliver a useful amount of iron or almost none, depending on '
          'whether there is lemon on it and tea beside it.',
        ], heading: 'Why the pairing matters more than the food'),
        PpCards([
          PpCard('Khajoor and anjeer laddoo',
              'Dates, figs, almonds and til blended and rolled, no sugar '
              'needed. Two a day, and the easiest iron in the house.'),
          PpCard('Beetroot and carrot sabzi, or beetroot paratha',
              'Grated beetroot is easier to eat than boiled. Squeeze lemon on '
              'it.'),
          PpCard('Palak dal, palak paneer, methi thepla',
              'Greens cooked with tomato and finished with lemon or amchur.'),
          PpCard('Gur instead of sugar, wherever it fits',
              'In your milk, in laddoo, in kadha, in chikki. Not a huge amount '
              'of iron per spoon, but it adds up over a day.'),
          PpCard('Ragi malt or ragi porridge',
              'Iron and calcium together, and it goes down easily on a bad '
              'morning.'),
          PpCard('Chana, rajma, sattu and til chikki',
              'Sattu drink with lemon and salt is close to a perfect one '
              'handed meal.'),
          PpCard('Liver, red meat, fish and egg, if you eat them',
              'Absorbed several times better than plant iron. Once or twice a '
              'week does real work.'),
        ], heading: 'The dishes worth putting in the week', hue: 42),
        PpSteps([
          PpStep('Put something sour with every iron rich meal',
              'Lemon, amchur, tomato, tamarind, amla, guava, orange. Vitamin C '
              'multiplies absorption several times over.'),
          PpStep('Keep tea and coffee away from meals',
              'An hour either side. The tannins block iron, and afternoon chai '
              'right after lunch is the commonest way Indian mothers lose it.'),
          PpStep('Cook in an iron kadhai, especially anything sour',
              'A measurable amount of iron transfers into the food.'),
          PpStep('Soak and sprout dals and chana where you can',
              'It breaks down the phytates that lock iron up.'),
          PpStep('Do not take your calcium and your iron together',
              'Curd with the iron meal is fine. A calcium tablet with an iron '
              'tablet is not.'),
        ], heading: 'The five habits that decide how much you absorb'),
        // REQUIRED_REVIEW: the absorption claims above, specifically that
        // vitamin C multiplies non haem iron absorption "several times over",
        // that tea and coffee should be spaced by an hour, and that an iron
        // kadhai adds a measurable amount. All are well supported but the
        // strength of the wording should be confirmed by a dietitian.
        PpCallout(
          'Food alone will not correct an established anaemia quickly. If your '
          'haemoglobin is low your doctor will prescribe iron, and the tablets '
          'do the work while the food keeps you there afterwards. Eat well and '
          'take the tablets, not one instead of the other.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('From the first weeks, and worth keeping up for at least six '
            'months. Refilling iron stores takes about three months of '
            'consistency, not two weeks.'),
        PpVideoSlot(
          title: 'Khajoor and anjeer laddoo, no sugar',
          subtitle: 'Five ingredients, one mixer, fifteen minutes, and they keep '
              'for three weeks.',
          minutes: '7 MIN',
          slotId: 'youmaa/recipe_khajoor_laddoo',
          hue: 42,
        ),
      ],
    ),
    PpPage(
      id: 'kitchen_one_handed',
      title: 'Meals you can eat holding her',
      format: 'RECIPE',
      bands: _allBands,
      blocks: [
        PpIntro('You have one hand, eleven minutes, and no idea when the next '
            'gap comes. These are the meals built for exactly that, and none of '
            'them needs a fork or a table.'),
        PpArticle([
          'The trick with all of these is that they are cooked once and eaten '
          'three times. A pot of khichdi made in the evening is lunch tomorrow '
          'and a bowl at 4am. Reheating is one hand. Cooking is not.',
        ], heading: 'The rule underneath all of them'),
        PpChartCard(
          title: 'Khichdi that is actually a meal',
          rows: [
            ('Rice', '0.5 cup'),
            ('Moong dal', '0.5 cup'),
            ('Ghee', '2 tbsp'),
            ('Jeera, hing, haldi, ajwain', 'A pinch of each'),
            ('Grated carrot, beans, palak', '1 cup, whatever is in the house'),
            ('Water', '4 cups, for a soft khichdi'),
            ('Salt', 'To taste'),
          ],
          note: 'Everything in the cooker, four whistles, done. Add ghee at the '
              'end and eat it from a bowl with a spoon in one hand.',
          hue: 42,
        ),
        PpCards([
          PpCard('Dalia, savoury or sweet',
              'Cracked wheat with vegetables and ghee, or with milk and gur. '
              'Cooks in one pot in fifteen minutes and reheats well.'),
          PpCard('Roti roll with dal or sabzi inside',
              'Ask whoever is cooking to roll it. It changes a two handed meal '
              'into a one handed one.'),
          PpCard('Sattu drink',
              'Roasted gram flour, water, lemon, salt or gur. Protein, iron, no '
              'cooking, thirty seconds.'),
          PpCard('Curd rice, with a spoon of ghee',
              'Cooling in summer, calcium, and it goes down when nothing else '
              'does.'),
          PpCard('Boiled eggs, kept peeled in the fridge',
              'The highest return per minute of effort in this whole list.'),
          PpCard('Upma, poha or idli with sambar',
              'All reheat, all eat with a spoon, all take one hand.'),
          PpCard('Milk with a banana and soaked almonds',
              'When you truly cannot manage food, this is not nothing.'),
        ], heading: 'The rest of the list', hue: 42),
        PpSteps([
          PpStep('Cook one big thing every two days, not six small ones',
              'Khichdi, dal, dalia, a vegetable. Everything else is assembly.'),
          PpStep('Keep a snack box within arm\'s reach of where you feed',
              'Laddoo, dry fruit, chana, banana, a bottle of water.'),
          PpStep('Ask for food to be cut or rolled before it reaches you',
              'It is a small request and it doubles what you can eat.'),
          PpStep('Eat before you feed her, not after',
              'After is theoretical, as any mother of a cluster feeding newborn '
              'will tell you.'),
        ], heading: 'How to set it up so it keeps happening'),
        PpWhenLine('From the day you come home, and honestly for the first year. '
            'Nothing here is a postpartum food. It is just food you can eat '
            'while occupied.'),
        PpVideoSlot(
          title: 'Three one handed meals in half an hour',
          subtitle: 'Khichdi, dalia and a sattu drink, cooked once for three '
              'days.',
          minutes: '12 MIN',
          slotId: 'youmaa/recipe_one_handed',
          hue: 42,
        ),
        PpIndiaNote('If you have help at home, this is the highest value thing '
            'to hand over. One pot of dal and one pot of khichdi, twice a week, '
            'is worth more to you than a swept floor.'),
      ],
    ),
    PpPage(
      id: 'kitchen_supply_foods',
      title: 'Foods for milk supply, honestly',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('You will be handed a lot of foods for supply, and some of them '
            'are worth eating. What none of them will do is fix a supply problem '
            'that is not about food, which is most of them.'),
        PpArticle([
          'Milk supply works on removal. The more milk that leaves the breast, '
          'and the more completely, the more your body makes. That is the '
          'mechanism, and it is why a baby feeding often and well is the single '
          'biggest driver of supply.',
          'Foods traditionally used for supply are called galactagogues. The '
          'evidence for all of them is thin. Some studies show a small effect, '
          'many show none, and almost all are small and poorly designed. That is '
          'not the same as saying they do nothing. It means nobody can promise '
          'you they will work.',
          'What food does do reliably is keep you fed and hydrated, and a mother '
          'who is severely under eating can see supply drop. So eat the shatavari '
          'kheer if it helps you feel looked after, and eat properly regardless. '
          'Just do not let three weeks pass on food alone if something is '
          'genuinely wrong.',
        ], heading: 'How supply actually works'),
        PpChartCard(
          title: 'The usual suspects, and what is honestly known',
          rows: [
            ('Methi, fenugreek',
                'The most studied. Mixed results. Some mothers notice a '
                'difference in a couple of days.'),
            ('Shatavari',
                'Long used in Ayurveda. Small studies, unclear evidence. Widely '
                'taken as a powder in milk.'),
            ('Oats and dalia',
                'No direct evidence. Good iron, good calories, harmless.'),
            ('Sabudana and rice preparations',
                'Traditional. Energy dense. No evidence for supply itself.'),
            ('Garlic',
                'Changes the flavour of milk and some babies feed more '
                'enthusiastically. That is the mechanism, if there is one.'),
            ('Jeera, saunf, ajwain, til',
                'Traditional across India. Good food, no strong evidence for '
                'supply.'),
            ('Enough food and enough water',
                'The one with the clearest link. Under eating can lower supply.'),
          ],
          note: 'Nothing on this list is harmful in food amounts. Nothing on it '
              'is a substitute for a feeding assessment.',
          hue: 42,
        ),
        PpCallout(
          'See a lactation consultant or your paediatrician rather than eating '
          'your way through this list if your baby is not gaining weight, has '
          'few wet nappies, feeds for an hour and is still frantic, or if '
          'feeding hurts. Those have causes, and the causes are fixable.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: this page deliberately underclaims for every
        // galactagogue, which contradicts what she is being told at home. A
        // lactation consultant should confirm the evidence summary, and confirm
        // the shatavari line in particular, since it is sold as a supplement and
        // supplements carry dosing questions that food does not.
        PpConsult(
          title: 'Feeding and supply consultation',
          whoFor: 'For a mother worried about supply, painful feeding, weight '
              'gain, or a baby who never seems satisfied. One full feed watched '
              'by someone trained usually answers in a single session what '
              'weeks of guessing does not.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        PpIndiaNote('If a supplement or a churna is being given to you daily, '
            'take the packet to your doctor once. Food is food. A concentrated '
            'herbal preparation has a dose, and it is worth having it looked at '
            'while you are also on other medication.'),
      ],
    ),
    PpPage(
      id: 'kitchen_where_it_goes_too_far',
      title: 'Where the tradition goes too far',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('The jaapa kitchen gets most of it right, which is why the parts '
            'it gets wrong are so hard to argue with. Here is the short list, '
            'and none of it is a reason to reject the rest.'),
        PpArticle([
          'A tradition is a set of things that worked, carried forward together '
          'with a set of things that happened to travel alongside. Nobody sorted '
          'them, because there was never a way to. Warm food and frequent '
          'feeding travelled in the same bundle as no water and no vegetables, '
          'and the bundle got passed on whole.',
          'You are allowed to keep the useful half. That is not disrespect. It '
          'is what every generation of women has quietly done.',
        ], heading: 'Why the good and the useless arrive together'),
        PpCards([
          PpCard('Ghee by the katori, several times a day',
              'A spoon or two in your food is genuinely useful. Half a cup a '
              'day is a great deal of fat and it is where mothers start feeling '
              'heavy, greasy and off their food entirely.'),
          PpCard('Six or seven laddoo a day',
              'That is a lot of jaggery. One or two does the job. This matters '
              'especially if your sugar was high in pregnancy.'),
          PpCard('No water, or only warm water in tiny amounts',
              'Withholding fluid from a mother making a litre of milk a day is '
              'the single most harmful item on this list. Ask for it warm '
              'instead of accepting less.'),
          PpCard('No vegetables and no fruit for forty days',
              'This costs you fibre at exactly the moment constipation is '
              'universal, and vitamin C at exactly the moment it is what makes '
              'your iron absorb.'),
          PpCard('No sour food, no curd, no buttermilk',
              'Curd is protein, calcium and comfort. Lemon is what unlocks your '
              'iron. Both are usually on the forbidden list.'),
          PpCard('Forty days without stepping outside at all',
              'Rest is good. No daylight for six weeks costs you vitamin D and '
              'does your mood no favours either. Ten minutes on the balcony is '
              'not breaking the rules.'),
          PpCard('Very long fasting or one meal a day for religious reasons',
              'Worth a conversation with your doctor rather than a decision '
              'made alone while feeding.'),
        ], heading: 'The seven that are worth pushing back on', hue: 12),
        PpCallout(
          'None of this means the people feeding you are wrong about everything. '
          'They are mostly right and they are also doing the cooking. Pick the '
          'one or two items above that actually apply in your house, and let the '
          'rest go.',
        ),
        PpCallout(
          'Heat foods and cold foods causing harm to a healing mother is a '
          'classification, not a mechanism. There is no evidence that curd '
          'causes a cold, that papaya harms a feeding mother, or that a banana '
          'in the evening is dangerous. Where a food genuinely disagrees with '
          'you, that is worth noticing. A list you were handed is not.',
          kind: PpCalloutKind.myth,
        ),
        PpScript([
          PpScriptLine(
            say: 'Doctor said I have to eat vegetables and fruit for the '
                'stitches to heal, so can we add some to my plate?',
            notThis: 'That is just an old superstition.',
            why: 'Attaching it to healing and to the doctor moves it out of the '
                'argument about tradition. Almost nobody argues with a wound.',
          ),
          PpScriptLine(
            say: 'Can I have the water warm? I get very thirsty when I feed her.',
            notThis: 'I am not drinking warm water, give me normal water.',
            why: 'Asking for it warm accepts the rule and gets you the fluid. '
                'You are not trying to win, you are trying to drink.',
          ),
          PpScriptLine(
            say: 'One laddoo in the morning is perfect. My sugar was borderline '
                'so the doctor said to keep the sweets to one a day.',
            notThis: 'Stop giving me so many laddoo.',
            why: 'Naming a medical reason ends it in one sentence and nobody '
                'feels rejected.',
          ),
        ], heading: 'How to say it without a fight'),
        PpCallout(
          'Talk to your doctor if you are being kept from water, from food you '
          'need, or from going outside at all, and you cannot change it by '
          'asking. A line from a doctor carries weight in an Indian house that '
          'your own opinion, unfairly, does not.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
  ],
);

// =============================================================================
//  8. THE PEOPLE IN YOUR HOUSE
// -----------------------------------------------------------------------------
//  ⚠️ THIS AREA IS WHY THE SECTION IS INDIA FIRST RATHER THAN INDIA FLAVOURED.
//  A western postpartum section has a page on visitors and a page on the
//  partner. Here the house is often full, the person cooking for her may also be
//  the person overruling her, help is a person with a name rather than a service,
//  and the thing standing between her and a decision is frequently what the
//  neighbours will say. None of that has a page anywhere else in the app.
//
//  ⚠️ THE MOTHER IN LAW PAGE IS WRITTEN WITH RESPECT AND NO SNARK, DELIBERATELY.
//  The easy version of this page makes her the villain, and it would be both
//  unfair and useless: she is usually the reason the mother is eating at all.
//  What the page actually does is separate the two things that get tangled,
//  which is authority over the baby and gratitude for the help, and then give
//  words for the first without losing the second.
//
//  ⚠️ EVERY DIFFICULT CONVERSATION GETS A `PpScript`, NOT ADVICE. "Set a
//  boundary" is not usable at 6pm with eleven relatives in the drawing room. A
//  sentence she can say out loud is.
//
//  ⚠️ SEX AND CONTRACEPTION ARE HERE AND THEY ARE PLAIN. `pf_sex_pain` covers
//  pain during sex as a pelvic floor matter. `people_intimacy` covers the rest:
//  when, whether, what it does to the two of you, and the fact that
//  breastfeeding is not contraception, which is the single most expensive
//  misunderstanding in this whole area.
// =============================================================================

const PpArea _thePeopleAroundYou = PpArea(
  id: 'people_around_you',
  mark: IntentMark.cuppedHands,
  title: 'The people in your house',
  blurb: 'Visitors, advice, your partner, and how to ask for help without '
      'apologising.',
  hue: 322,
  pages: [
    PpPage(
      id: 'people_visitors',
      title: 'Visitors, and how to survive the first month of them',
      format: 'ARTICLE',
      bands: _early,
      blocks: [
        PpIntro('A newborn in an Indian family means a stream of people at the '
            'door, and every one of them is happy for you. It is also, right '
            'now, work you are doing on top of everything else.'),
        PpArticle([
          'Nobody visiting means any harm. They also do not see what the visit '
          'costs: you sit up, you cover up, you make conversation, you feed her '
          'in front of people, you do not sleep in the gap you had planned to '
          'sleep in, and then somebody asks for tea.',
          'The mothers who come through the first month best are not the ones '
          'who refuse visitors. They are the ones who decided in advance what a '
          'visit looks like, and had one other person say it for them.',
        ], heading: 'What a visit actually costs you'),
        PpSteps([
          PpStep('Pick two hours a day when visits happen',
              'Late afternoon works for most families. Outside those hours, the '
              'answer is a time rather than a no.'),
          PpStep('Let someone else be the gatekeeper',
              'Your partner, your mother, your sister. The message lands '
              'completely differently coming from anyone but you.'),
          PpStep('Set a length, out loud, at the start',
              '"She has to feed at five" is a finishing time everybody accepts.'),
          PpStep('Have somewhere to disappear to',
              'One room that is yours. You leave to feed and you do not come '
              'back until you want to.'),
          PpStep('Let people be useful instead of entertained',
              'When they ask what they can bring, answer with a real thing. '
              'Dal, fruit, a packet of pads.'),
          PpStep('Say no to holding the baby when you want to',
              'Especially if she has just settled, and especially if the person '
              'has a cough.'),
        ], heading: 'What actually works'),
        PpScript([
          PpScriptLine(
            say: 'We are keeping visits to the evenings for the first few weeks. '
                'Come at six, we would love to see you.',
            notThis: 'Please do not come, I am too tired.',
            why: 'It offers a time rather than a refusal, so nobody is turned '
                'away and you still get your mornings.',
          ),
          PpScriptLine(
            say: 'She is due a feed, I am going to take her inside. Do stay, '
                'have your tea.',
            notThis: 'Sorry, I have to go, sorry.',
            why: 'Leaves without apologising and without ending the visit for '
                'everyone else.',
          ),
          PpScriptLine(
            say: 'The doctor asked us to keep visitors small for the first few '
                'weeks, so we are doing two at a time.',
            notThis: 'The whole family cannot come, it is too much for me.',
            why: 'A medical reason ends the discussion. It is also true: a '
                'newborn\'s immune system is genuinely new.',
          ),
        ], heading: 'The words, if you want them'),
        PpCallout(
          'Anybody with a cough, a cold, a fever or a fresh vaccination in the '
          'family should not hold a newborn, and should not kiss her at all. '
          'This one is not about your comfort. In the first weeks an ordinary '
          'adult cold can be a serious illness for her.',
          kind: PpCalloutKind.safety,
        ),
        // REQUIRED_REVIEW: the visitor infection guidance, particularly the "no
        // kissing a newborn" line and whether to name specific illnesses. A
        // paediatrician should confirm the wording and how firm it should be.
        PpIndiaNote('Refusing an elder outright is not realistic in most Indian '
            'homes and this page does not pretend otherwise. Everything above is '
            'built to work without a confrontation, because a confrontation is a '
            'cost you will pay for months.'),
      ],
    ),
    PpPage(
      id: 'people_asking_for_help',
      title: 'Asking for help without apologising for it',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Most new mothers ask for help in a way that makes it easy to '
            'say no. Not because they are polite, but because the request comes '
            'out wrapped in an apology and a question mark.'),
        PpArticle([
          'There is a difference between "if you are not busy, could you maybe '
          'hold her for a bit, sorry" and "can you take her for an hour, I need '
          'to sleep". The first is an offer to be declined. The second is a '
          'request with a shape, and people say yes to it far more often.',
          'The other thing that makes help not arrive is vagueness. "Let me know '
          'if you need anything" is a genuinely kind sentence that puts the '
          'entire job of working out what you need, and asking for it, back on '
          'the person with no time and no bandwidth. Answer it with a specific '
          'task and most people are relieved.',
        ], heading: 'Why the help does not arrive'),
        PpSteps([
          PpStep('Name the task, the time and the person',
              '"Can you take her from four to five" beats "can you help with '
              'the baby" every single time.'),
          PpStep('Take the apology out of the front of the sentence',
              'You are recovering from birth. There is nothing to be sorry '
              'about.'),
          PpStep('Keep a list of jobs on the fridge or in your phone',
              'When someone asks what they can do, read one out. No thinking '
              'required in the moment.'),
          PpStep('Ask for the boring things, not the baby',
              'Most people want to hold her. What you actually need is the '
              'dishes, the medicines, the bank work, a pot of dal.'),
          PpStep('Say yes the first time, so there is a second time',
              'Declining help teaches people to stop offering, and the offers '
              'stop around week three anyway.'),
        ], heading: 'How to ask so the answer is yes'),
        PpScript([
          PpScriptLine(
            say: 'Can you take her from four to five? I need to sleep.',
            notThis: 'If you are free, maybe you could hold her for a bit? '
                'Sorry.',
            why: 'A time and a reason. There is nothing to decline and nothing '
                'to negotiate.',
          ),
          PpScriptLine(
            say: 'Yes, please. Could you bring dal and rice on Thursday?',
            notThis: 'No no, we are managing, do not trouble yourself.',
            why: 'Answers the offer with a task. People who offer food want to '
                'be told what to bring.',
          ),
          PpScriptLine(
            say: 'I am going to lie down for an hour. Wake me only if she will '
                'not settle.',
            notThis: 'I might just rest for a few minutes if that is okay.',
            why: 'A statement, not a request for permission. You do not need '
                'permission to sleep.',
          ),
        ], heading: 'Three sentences worth practising'),
        PpCallout(
          'The list of what to hand over, in rough order of what buys you the '
          'most: one long block of sleep, cooking, dishes, laundry, older '
          'children, errands, and last of all holding the baby. Most people '
          'offer the last one.',
        ),
        PpIndiaNote('If you have paid help at home, the useful ask is usually '
            'cooking rather than cleaning. A pot of dal and a pot of khichdi '
            'twice a week changes your day more than a swept floor does. If you '
            'are considering hiring, that is the job to hire for.'),
      ],
    ),
    PpPage(
      id: 'people_mother_in_law',
      title: 'You and your mother in law',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('This is often the hardest relationship in the house right now, '
            'and it is hard for a reason that is not anybody being unkind. Two '
            'things are getting tangled and they are worth separating.'),
        PpArticle([
          'She raised children, probably with far less help and far less '
          'information than you have, and they lived. That gives her real '
          'confidence and real standing. She is also, in most houses, the reason '
          'you are eating hot food twice a day right now.',
          'And the advice she gives comes from a different decade of medicine. '
          'Ghutti, honey on the lips, kajal, a tight binder, water for a newborn, '
          'a head shaped by hand, oil in the ears. These were normal and some of '
          'them are now known to be harmful. Neither of you is being '
          'unreasonable. You are working from different information.',
          'The thing that turns that into a conflict is when advice arrives as '
          'authority: not "we used to do this" but "give her this". The useful '
          'move is not to win the argument about the past. It is to be clear '
          'about who decides now, while making it obvious you are grateful for '
          'the help.',
        ], heading: 'What is actually going on'),
        PpCards([
          PpCard('Separate gratitude from authority',
              'You can be genuinely thankful for the cooking and still be the '
              'one who decides what goes in the baby\'s mouth. Say both.'),
          PpCard('Let the doctor be the third party',
              '"The paediatrician said" is not a trick. It is true, it is '
              'checkable, and it takes the disagreement out of the family.'),
          PpCard('Pick your three, let the rest go',
              'Feeding, sleep safety and anything that goes into or onto the '
              'baby. Almost everything else is not worth the friction.'),
          PpCard('Give her a job that is genuinely hers',
              'Malish, the kadha, a lullaby, the laddoo. Real, valued, and not '
              'a decision about the baby.'),
          PpCard('Let your partner carry his own mother',
              'The message from a son lands differently from the same message '
              'from a daughter in law. This is the single most useful thing he '
              'can do this year.'),
          PpCard('Do not fight it at 3am',
              'Nothing said at 3am between exhausted people gets remembered '
              'accurately. Say it the next afternoon.'),
        ], heading: 'What works, in most houses', hue: 322),
        PpScript([
          PpScriptLine(
            say: 'You have done this before and I am learning, so I really do '
                'need you. On the feeding, though, I am going to follow what the '
                'doctor told us.',
            notThis: 'That is not how it is done now.',
            why: 'Keeps her standing intact and still draws the line. Very few '
                'people argue after being told they are needed.',
          ),
          PpScriptLine(
            say: 'The paediatrician has said nothing except milk until six '
                'months, not even water. I am scared to do anything different.',
            notThis: 'Ghutti is dangerous, please do not give it.',
            why: 'Puts the rule on the doctor and your own fear rather than on '
                'her judgement, which is the part that stings.',
          ),
          PpScriptLine(
            say: 'Can you make the kadha? Nobody makes it like you and I am '
                'drinking it every day.',
            why: 'A real job, genuinely valued. A person with a role of their '
                'own reaches for other people\'s roles far less.',
          ),
        ], heading: 'Sentences that hold the line without a fight'),
        PpCallout(
          'Ask your paediatrician directly, in front of whoever is insisting, '
          'about anything that goes into the baby: ghutti, honey, water, gripe '
          'water, kajal, or an oil in the nose or ears. Honey before one year is '
          'genuinely dangerous, and a doctor saying so in the room ends the '
          'discussion permanently.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the specific traditional practices named here
        // (ghutti, honey before one year, kajal, oil in the nose or ears) and
        // how firmly each should be discouraged. A paediatrician should confirm
        // the list and the strength of wording, since this page will be read
        // aloud in arguments.
        PpCallout(
          'If she is genuinely making you miserable rather than merely '
          'disagreeing with you, that is a different page. Constant criticism '
          'after birth is one of the strongest drivers of postpartum depression '
          'in Indian studies, and it is worth naming rather than absorbing.',
        ),
      ],
    ),
    PpPage(
      id: 'people_partner',
      title: 'Your partner, and the work he cannot see',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Most partners after a birth are not refusing to help. They are '
            'waiting to be told what to do, which is its own kind of exhausting '
            'for the person who has to do the telling.'),
        PpArticle([
          'There are two kinds of work in a house with a newborn. The visible '
          'kind: changing her, bathing her, washing bottles, cooking. And the '
          'invisible kind: knowing when she last fed, when the vaccination is '
          'due, that the nappies are running out, which cry means what, and that '
          'somebody has to be awake.',
          'The second kind is the one that does not get shared, and it is the '
          'one that wears mothers down. A partner can do half the visible work '
          'and the mother is still carrying the entire mental load, because she '
          'is the one issuing the instructions.',
          'The fix is not more helping. It is owning whole areas, start to '
          'finish, including the noticing. "Nappies are his job" means he tracks '
          'the stock, buys them, and you never think about nappies again.',
        ], heading: 'The work that never gets divided'),
        PpCards([
          PpCard('Hand over whole areas, not tasks',
              'Bath time, the night shift on Saturdays, all medical '
              'appointments, all shopping. His to remember, not his to be '
              'reminded of.'),
          PpCard('Protect one block of your sleep, every night',
              'Even four uninterrupted hours changes a mother\'s week. If she is '
              'breastfeeding, he does the settling after the feed.'),
          PpCard('Let him do it wrong',
              'A nappy on backwards is not worth taking the job back for. '
              'Correcting is how a partner learns to wait for instructions.'),
          PpCard('Say the specific thing at the specific time',
              'He genuinely cannot tell that you have not eaten. Saying it is '
              'not nagging.'),
          PpCard('Ten minutes a day that is not about logistics',
              'Not a date night. Ten minutes on the bed, not discussing the '
              'schedule.'),
          PpCard('He may also be struggling',
              'Fathers get postnatal depression too, at meaningful rates, and '
              'almost nobody asks them.'),
        ], heading: 'What actually changes things', hue: 322),
        PpScript([
          PpScriptLine(
            say: 'I need you to own bath and bedtime completely. Not help with '
                'it, own it, including remembering when it is.',
            notThis: 'You never help with anything.',
            why: 'Names the actual problem, which is ownership rather than '
                'effort, and gives him something he can succeed at.',
          ),
          PpScriptLine(
            say: 'From ten to two, she is yours. Bring her to me only to feed. '
                'I have to sleep.',
            notThis: 'I am so tired.',
            why: 'A specific window with a specific instruction. Tiredness is '
                'information, this is a plan.',
          ),
          PpScriptLine(
            say: 'When you ask me what needs doing, that is still me doing the '
                'thinking. Can you take the whole of the shopping and the '
                'medicines?',
            notThis: 'Do I have to think of everything?',
            why: 'Explains the invisible half in words, which most partners '
                'have genuinely never had described to them.',
          ),
        ], heading: 'How to say it so it changes something'),
        PpIndiaNote('In a joint family the load often shifts sideways instead of '
            'to the father: his mother does it, so he never learns. That is '
            'comfortable for a few months and expensive later, when the '
            'grandparents go home and he has never done a bedtime alone.'),
        PpCallout(
          'If he is withdrawn, sleeping badly, irritable or drinking more, '
          'suggest he talks to a doctor too. Paternal postnatal depression is '
          'real, it is common, and in India it is asked about almost never.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
    PpPage(
      id: 'people_advice',
      title: 'Advice you did not ask for',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('You will get more advice in the first month than in the rest of '
            'your life, most of it contradictory, all of it delivered with '
            'certainty. Here is a way to handle it that costs you nothing.'),
        PpArticle([
          'Almost all unsolicited advice is really a person telling you what '
          'they did, and looking for you to confirm it was right. Very little '
          'of it is a genuine instruction, even when it is phrased as one. That '
          'is why arguing with it goes so badly: you think you are discussing '
          'the baby and they think you are judging their choices.',
          'Which means you do not have to agree, and you do not have to '
          'disagree. You have to acknowledge, and move on. Almost nobody follows '
          'up.',
        ], heading: 'What advice actually is'),
        PpSteps([
          PpStep('Sort it into three piles as it arrives',
              'Harmful, harmless, and helpful. Only the first pile needs '
              'anything from you.'),
          PpStep('For harmless advice, say a warm nothing',
              '"That is interesting, I will keep it in mind." Then do whatever '
              'you were going to do.'),
          PpStep('For harmful advice, put it on the doctor',
              'Never on your own judgement. "The paediatrician has told us not '
              'to" is unarguable and costs no relationship.'),
          PpStep('For helpful advice, take it and say so loudly',
              'Some of it is gold, especially from women who did this without '
              'any of the things you have.'),
          PpStep('Do not defend, explain or produce evidence',
              'Nobody has ever been convinced by a mother reading out a study '
              'at a naming ceremony. It only extends the conversation.'),
        ], heading: 'The three pile method'),
        PpScript([
          PpScriptLine(
            say: 'Thank you, I will keep that in mind.',
            notThis: 'Actually that is not recommended any more.',
            why: 'Ends it. It is not agreement and it is not a fight, and it '
                'works on about eighty per cent of what you will hear.',
          ),
          PpScriptLine(
            say: 'Our doctor has been quite strict about that one, so we are '
                'sticking to what she said.',
            notThis: 'That is dangerous, actually.',
            why: 'For the harmful pile. Firm, final, and it does not tell '
                'anybody they harmed their own children.',
          ),
          PpScriptLine(
            say: 'How did you manage it with three children and no washing '
                'machine?',
            why: 'When you would rather change the subject than have the '
                'conversation. It also usually gets you a better story than the '
                'advice was.',
          ),
        ], heading: 'Three replies that end it'),
        PpCallout(
          'The only advice worth arguing about is the kind that could hurt her: '
          'anything into her mouth before six months, anything that makes her '
          'sleep surface unsafe, skipping a vaccination, or treating a fever in '
          'a newborn at home. Everything else can be smiled at.',
          kind: PpCalloutKind.safety,
        ),
        PpIndiaNote('The advice will also come from strangers in the lift, in '
            'the park and at the chemist. You owe them a nod and nothing else.'),
      ],
    ),
    PpPage(
      id: 'people_saying_no',
      title: 'Saying no in a house where nobody says no',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('In most Indian homes a flat no to an elder is not really '
            'available, and a page that tells you to set boundaries is useless. '
            'These are the ways of saying no that actually work here.'),
        PpArticle([
          'A direct refusal in a joint family does not usually end the request. '
          'It moves it: to your partner, to a phone call, to a comment three '
          'weeks later, to your own mother. So the useful skill is not refusing '
          'harder. It is refusing in a form that closes the matter.',
          'Four forms do that reliably. Deferring to a doctor. Deferring to '
          'time. Offering a smaller version. And letting somebody else deliver '
          'it. None of them requires you to be confrontational, and all of them '
          'end with you doing what you decided.',
        ], heading: 'Why a plain no does not stick'),
        PpCards([
          PpCard('Defer to the doctor',
              'The most powerful tool in an Indian family. Works for feeding, '
              'sleep, visitors, food, going out, and rest.'),
          PpCard('Defer to time',
              '"Not this month, let us see after the vaccination." Nobody '
              'argues with later, and later usually never comes back.'),
          PpCard('Offer a smaller version',
              'Not the whole family at once, but two people on Sunday. You are '
              'agreeing to something, which is what most people needed.'),
          PpCard('Let your partner deliver it',
              'The same sentence from him is a decision. From you it is an '
              'attitude. That is unfair, and it is also useful.'),
          PpCard('Blame the baby, freely',
              '"She will not settle if we go" is available and endlessly '
              'renewable.'),
          PpCard('Do not explain twice',
              'A second explanation reopens the conversation. Say it once and '
              'then repeat the same sentence, unchanged.'),
        ], heading: 'The five that work, and one rule', hue: 322),
        PpScript([
          PpScriptLine(
            say: 'The doctor asked us not to take her out for the first six '
                'weeks, so we will come for the next one.',
            notThis: 'I do not want to come, I am too tired.',
            why: 'Not a refusal of them, a refusal by the doctor, with a '
                'promise attached.',
          ),
          PpScriptLine(
            say: 'Not this month. Let us plan it after her next vaccination.',
            notThis: 'No, we cannot.',
            why: 'Later is much easier to accept than never, and it gives you '
                'six weeks in which the plan usually dissolves.',
          ),
          PpScriptLine(
            say: 'I cannot do a full function, but I can do an hour at the '
                'temple if we go early.',
            notThis: 'I am not going.',
            why: 'A smaller yes. Most social obligation in an Indian family is '
                'satisfied by attendance, not duration.',
          ),
        ], heading: 'The forms, in words'),
        PpCallout(
          'You are allowed to say no to being touched, to your baby being '
          'passed around, to being photographed, and to advice. Those four are '
          'not negotiable, and none of them requires a reason.',
        ),
        PpIndiaNote('"Log kya kahenge" has its own page in this area. If that is '
            'the real reason a no feels impossible, that is the page to read '
            'rather than this one.'),
      ],
    ),
    PpPage(
      id: 'people_help_at_home',
      title: 'Help at home: the maid, the cook, and the maalishwali',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('If hiring help is possible for you at all, the first months '
            'after birth are the single highest value time to do it. It is worth '
            'thinking about what to hire for, because most families hire for the '
            'wrong thing.'),
        PpArticle([
          'The instinct is to hire someone to help with the baby. In practice '
          'the baby is the part most mothers want to do, and the part that is '
          'hardest to hand over anyway. What crushes a new mother is the house: '
          'three meals, dishes after each, laundry that has doubled, and a floor '
          'somebody keeps putting the baby on.',
          'So if you can afford one person, hire a cook. If you can afford part '
          'of a person, buy the cooking. A pot of dal and a pot of sabzi arriving '
          'every day is the difference between eating and not eating, and eating '
          'is the thing this whole area depends on.',
        ], heading: 'What to buy first, if you can buy anything'),
        PpCards([
          PpCard('A cook, or a tiffin service',
              'The highest value help there is right now. Warm food without '
              'anyone standing up.'),
          PpCard('Cleaning, two or three times a week',
              'Especially the floor, once she is on it.'),
          PpCard('A japa maid, for a fixed period',
              'Common in many cities: a live in or day helper for the first '
              'one to three months who does the baby\'s washing, the mother\'s '
              'food and the malish. Agree the hours and the tasks in writing '
              'before she starts.'),
          PpCard('A maalishwali, if malish is part of your tradition',
              'Ask for a gentle massage, ask her to stop if anything hurts, and '
              'keep the belly binding loose enough to breathe in.'),
          PpCard('Night help, if it is affordable and you can sleep with '
              'someone else in the house',
              'Rare and expensive, and for some mothers it is the thing that '
              'saves the year.'),
          PpCard('And the unpaid version: one relative, one job, agreed',
              'Not "everybody helps". One person, one job, so it actually '
              'happens.'),
        ], heading: 'What to actually hire for', hue: 322),
        PpSteps([
          PpStep('Agree the tasks and the hours before she starts',
              'Written down, even roughly. Most trouble with home help comes '
              'from scope, not from money.'),
          PpStep('Ask about her health if she is handling the baby',
              'Any cough or fever, and she should not be around a newborn.'),
          PpStep('Say clearly what you do not want done to the baby',
              'No kajal, no honey, no oil in the nose or ears, no water. Say it '
              'once, kindly, at the start rather than after.'),
          PpStep('Do not leave a newborn alone with anyone you have just met',
              'Not distrust, just sequence. Trust builds over a few weeks.'),
          PpStep('Pay properly and on time',
              'A woman doing the hardest weeks of your life with you deserves '
              'that, and you want her to stay.'),
        ], heading: 'Getting it right'),
        PpCallout(
          'Tell whoever does your malish to stop if anything hurts, and see your '
          'doctor before any belly binding or deep abdominal massage if you had '
          'a caesarean, if you have stitches, or if you have any pain, fever or '
          'increased bleeding afterwards.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: guidance on postnatal malish and belly binding after
        // a caesarean or with unhealed stitches, and how firmly to caution
        // against tight binding. A clinician should confirm, since malish is
        // near universal and the advice needs to be usable rather than
        // prohibitive.
        PpIndiaNote('If hiring is not possible, this page still has one thing in '
            'it: pick the single job that costs you the most and give that one '
            'away, to whoever is around. For most mothers it is the cooking.'),
      ],
    ),
    PpPage(
      id: 'people_log_kya_kahenge',
      title: 'Log kya kahenge',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('A surprising number of decisions in the first year are not made '
            'by you or by your doctor. They are made by an imagined room full of '
            'people who will have an opinion.'),
        PpArticle([
          'It shows up everywhere and it is rarely named. Feeding her formula in '
          'front of relatives. Going back to work at three months, or not going '
          'back at all. Not doing a function. Seeing a counsellor. Saying out '
          'loud that you are not enjoying this. Having a caesarean and being '
          'asked why you did not try harder.',
          'The cost is real and it is not vanity. In India, what people say gets '
          'back to your family, affects your parents, and sometimes affects your '
          'marriage. Pretending it does not matter is not useful advice.',
          'What is useful is separating the decisions where the opinion has a '
          'real consequence from the ones where the consequence is only that '
          'somebody thinks something. Most of them are the second kind, and the '
          'second kind is survivable.',
        ], heading: 'Where it actually shows up'),
        PpCards([
          PpCard('Ask what the actual consequence is',
              'Say it out loud. Very often the answer is "an aunt will '
              'comment", and that is a price worth paying for sleep.'),
          PpCard('Notice who is really being protected',
              'Sometimes it is your mother in law\'s standing, or your parents\' '
              'reputation. That is a real thing, and it is a different '
              'conversation from your own health.'),
          PpCard('Decide once, and stop reopening it',
              'The exhaustion is rarely the decision. It is deciding again '
              'every time somebody raises an eyebrow.'),
          PpCard('Keep the medical ones out of it entirely',
              'Formula, a caesarean, a counsellor, an antidepressant, a '
              'termination of feeding. These are between you and your doctor '
              'and nobody is owed an explanation.'),
          PpCard('Find one person who does not judge you',
              'One is enough. A sister, a friend, a mother from the circle. It '
              'is remarkable how much less the room matters when one person in '
              'it is on your side.'),
        ], heading: 'How to think about it', hue: 322),
        PpCallout(
          'The one place this must never win is your mental health. If shame is '
          'the reason you have not told anybody how you feel, or have not seen '
          'anybody about it, that is the situation this whole section exists '
          'for. Nobody outside your house needs to know, and a counsellor tells '
          'nobody.',
        ),
        PpScript([
          PpScriptLine(
            say: 'The doctor and I have decided this together, and I am not '
                'going to discuss it further.',
            notThis: 'You do not understand what I am going through.',
            why: 'Closes the subject without opening your reasons for '
                'inspection. Repeat the same sentence if it is raised again.',
          ),
          PpScriptLine(
            say: 'I know people will talk. I have thought about it and I am '
                'still doing it.',
            why: 'For the version of this that happens inside your own head, '
                'which is most of it.',
          ),
        ], heading: 'Two sentences worth having ready'),
        PpIndiaNote('This is one of the very few things in this app that is '
            'specific to here. A postpartum guide written elsewhere has no page '
            'for it, which is exactly why it goes unnamed and keeps working.'),
      ],
    ),
    PpPage(
      id: 'people_intimacy',
      title: 'Sex, contraception, and the two of you',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('Nobody discusses this and everybody has questions about it. '
            'Here it is plainly, including the part that catches out more '
            'couples than any other.'),
        PpArticle([
          'The usual advice is to wait until the bleeding has stopped and you '
          'have had your six week check, mainly because until then the cervix is '
          'still open and there is a wound inside where the placenta was. That '
          'is about infection risk, not about morality, and it applies whether '
          'you had a vaginal birth or a caesarean.',
          'After that, the honest answer is whenever you both want to, which for '
          'a lot of couples is considerably later than six weeks and that is '
          'entirely normal. Exhaustion, pain, dryness, feeling touched out after '
          'a whole day of being climbed on, and a body that does not feel like '
          'yours are all real reasons and none of them is a problem with your '
          'relationship.',
          'Dryness in particular is physiological, not psychological. '
          'Breastfeeding keeps oestrogen low, and low oestrogen means less '
          'natural lubrication. Almost every feeding mother experiences it and '
          'almost nobody is told about it in advance. A lubricant is the answer '
          'and it is not a failure.',
        ], heading: 'When, and how it usually actually goes'),
        PpCallout(
          'The one that catches people out: breastfeeding is not reliable '
          'contraception, and you can ovulate before your first period returns. '
          'So the first fertile cycle can arrive with no warning at all. If '
          'another pregnancy right now would be difficult, decide on '
          'contraception before you need it, not after.',
          kind: PpCalloutKind.safety,
        ),
        PpArticle([
          'There is a version of breastfeeding as contraception that is genuinely '
          'effective, and it only works while three things are all true at once: '
          'the baby is under six months, your periods have not returned, and she '
          'is fully breastfed with no long gaps day or night. Miss any one of '
          'those and the protection falls away quickly.',
          'Most mothers do not meet all three for long. A night stretch, a bottle, '
          'the start of solids, or a period appearing ends it. So it is worth '
          'treating as a temporary bridge rather than a plan.',
        ], heading: 'The version that does work, and its three conditions'),
        // REQUIRED_REVIEW: the three lactational amenorrhoea conditions and the
        // statement that ovulation can precede the first period. Both are
        // standard, and both are frequently misunderstood, so a clinician should
        // confirm the wording before ship.
        PpCallout(
          'Ask your doctor which contraception suits you while breastfeeding, '
          'and ask at the six week check rather than later. Several options are '
          'considered compatible with feeding and several are not, the timing of '
          'when each can be started varies, and it is a five minute conversation '
          'that saves a great deal.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: this page deliberately does NOT name individual
        // contraceptive methods, doses or start times. That is a clinical
        // decision per mother and naming options here would invite self
        // selection. If the reviewing clinician wants a comparison table of
        // methods and their compatibility with breastfeeding, it should be added
        // by them and not written by us.
        PpCards([
          PpCard('Use a lubricant, generously',
              'Dryness while feeding is hormonal and extremely common. This is '
              'the fix, and it is not a comment on either of you.'),
          PpCard('Go slowly, and stop if it hurts',
              'Pain is a reason to stop, not to push through. Repeated painful '
              'sex teaches the pelvic floor to tighten, which makes it worse.'),
          PpCard('Scar and stitch worry is normal',
              'Many mothers are afraid something will tear. Ask your doctor to '
              'confirm the healing at the check, which for most women is the '
              'reassurance that actually helps.'),
          PpCard('Touched out is a real thing',
              'After ten hours of being held onto, wanting nobody near you is '
              'not rejection. Say it in those words, because he will not guess.'),
          PpCard('Closeness that is not sex counts',
              'For most couples this comes back first, and it is what makes the '
              'rest come back at all.'),
        ], heading: 'What helps', hue: 322),
        PpCallout(
          'See your doctor or a pelvic floor physiotherapist for pain that '
          'continues past the first few attempts, for bleeding afterwards, for a '
          'scar or stitch line that catches, or for pain deep inside rather than '
          'at the entrance. All of these are treatable and none of them is '
          'something to endure quietly.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('In a joint family with thin walls and a baby in the room, '
            'privacy is its own obstacle and it is not a small one. It is worth '
            'saying out loud to each other rather than each concluding the other '
            'is not interested.'),
      ],
    ),
  ],
);

// =============================================================================
//  9. GOING BACK, AND FINDING YOURSELF AGAIN
// -----------------------------------------------------------------------------
//  ⚠️ NAMED FOR BOTH HALVES ON PURPOSE. The spec calls this "Back to Work / Back
//  to You", and the two are not the same subject. Some mothers are going back to
//  a job. Some are not, and some never had one. A door called only "Back to work"
//  tells the second and third that this part of the app is not for them, which is
//  precisely the message a mother who has just given up her career does not need.
//
//  ⚠️ BANDED LATE, DELIBERATELY. Almost everything here carries `_b2` and `_b3`.
//  A mother three weeks in does not need a page about her milk stash, and showing
//  it to her turns the section into a countdown. The two exceptions are the
//  entitlement page and the milk stash page, which carry `_b1` as well because
//  Indian maternity leave commonly ends at around six months and the planning that
//  works starts about two months out.
//
//  ⚠️ THE LEGAL PAGE IS THE MOST DANGEROUS PAGE IN THIS FILE. Every figure on it
//  is a legal fact that changes, differs by employer size, and is unevenly
//  enforced. It is flagged REQUIRED_REVIEW in full, it names no lawyer, quotes no
//  penalty, and tells her where to check rather than pretending to be advice.
//
//  ⚠️ NO FORMULA PROMOTION ANYWHERE, EVER. The IMS Act is not a preference. Where
//  a mother stops or reduces breastfeeding, this area supports the decision and
//  names no product and no brand.
// =============================================================================

const PpArea _backToWork = PpArea(
  id: 'back_to_work',
  mark: IntentMark.lampMark,
  title: 'Going back, and finding yourself again',
  blurb: 'Returning to work, or choosing not to, and the person you were before '
      'all this.',
  hue: 186,
  pages: [
    PpPage(
      id: 'work_planning',
      title: 'Planning your return, starting about four weeks out',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('Almost every mother who found the return manageable started '
            'arranging it earlier than she thought she needed to. Four weeks is '
            'the number that keeps coming up.'),
        PpArticle([
          'There are really two returns happening at once. The logistical one, '
          'which is childcare, milk, timings and travel, and the emotional one, '
          'which is leaving her. They need completely different preparation and '
          'they get tangled because they arrive on the same morning.',
          'The logistical half is the half you can actually control, and getting '
          'it settled early is what leaves room for the other half. A mother who '
          'is still interviewing carers in her last week has no space left to '
          'feel anything.',
        ], heading: 'The two returns'),
        PpSteps([
          PpStep('Four weeks out: settle childcare and start the trial',
              'Whoever will be with her should start while you are still at '
              'home, for a few hours a day, building up. This one week of '
              'overlap is worth more than any other preparation.'),
          PpStep('Four weeks out: start the milk stash if you are feeding',
              'One extra pumping session a day is enough. Starting a week '
              'before is where the panic comes from.'),
          PpStep('Three weeks out: introduce the bottle or cup, by someone else',
              'Most babies refuse a bottle from their mother and take it '
              'happily from anyone else. Start early enough to have several '
              'goes.'),
          PpStep('Three weeks out: ask your employer the awkward questions',
              'Hours, work from home, a room and a fridge for pumping, and '
              'nursing breaks. In writing, so there is a record.'),
          PpStep('Two weeks out: do a full dress rehearsal day',
              'Wake at the real time, leave at the real time, be out for the '
              'real hours. Everything that is going to go wrong will go wrong '
              'on this day instead of on day one.'),
          PpStep('One week out: shift the sleep and feed timings gently',
              'Move towards the schedule the working days will need, rather '
              'than changing everything on Monday morning.'),
          PpStep('Go back on a Wednesday or a Thursday',
              'A two or three day first week is much easier than a five day '
              'one, and it costs almost nothing to arrange.'),
        ], heading: 'The four week countdown'),
        PpCallout(
          'The single highest value item on that list is the overlap week, where '
          'the carer works while you are still at home. It is the difference '
          'between handing your baby to a stranger on Monday and handing her to '
          'someone you have watched.',
        ),
        PpIndiaNote('If a grandparent is going to be the carer, do the overlap '
            'anyway. It is not about trust. It is about her getting used to '
            'being settled and fed by that person while you are still reachable, '
            'and about agreeing what happens when she cries.'),
        PpWhenLine('Start about four weeks before your return date. Two weeks is '
            'possible and stressful. One week is where mothers describe it going '
            'badly.'),
      ],
    ),
    PpPage(
      id: 'work_your_entitlement',
      title: 'What your maternity leave actually entitles you to',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('A lot of Indian mothers do not know what the law gives them, '
            'and a lot of employers rely on that. Here is the shape of it, and '
            'where to check the details for your own situation.'),
        PpArticle([
          'Paid maternity leave in India comes from the Maternity Benefit Act, '
          'which was substantially amended in 2017 and now provides twenty six '
          'weeks of paid leave for a mother\'s first two children, and twelve '
          'weeks from the third onwards. Adopting mothers and commissioning '
          'mothers have their own, shorter entitlement.',
          'It applies to establishments above a certain size, and there are '
          'conditions, including a minimum period you must have worked before '
          'the expected date. It also carries three things mothers often do not '
          'know about: nursing breaks after you return, a work from home option '
          'where the nature of the work allows it and the employer agrees, and a '
          'creche requirement for larger establishments.',
          'Two honest caveats. This is a summary and not legal advice, and the '
          'details differ by employer size, sector and state. And enforcement is '
          'uneven, particularly in smaller firms and in informal work, where '
          'many mothers have no practical entitlement at all. Knowing the rule '
          'is still worth it, because a written request that cites it is treated '
          'very differently from a verbal one that does not.',
        ], heading: 'The shape of it'),
        // REQUIRED_REVIEW: this entire page is legal content and every figure on
        // it needs verification against the current text of the Maternity
        // Benefit Act and its amendments before ship: the twenty six and twelve
        // week durations, the first two children rule, the adoption and
        // commissioning mother entitlements, the establishment size thresholds,
        // the minimum service condition, the nursing break provision, the work
        // from home clause and the creche requirement. It must also be dated,
        // because it will go out of date silently. Ideally reviewed by an
        // employment lawyer, not by a clinician.
        //
        // REQUIRED_TO_CONFIRM: whether to name an official source she can check
        // her own case against, and which one. This page deliberately names no
        // helpline, no labour office number and no lawyer, because an invented
        // or stale contact is worse than none. If the product owner wants a
        // pointer here, it must be a real, current, verifiable one.
        PpChartCard(
          title: 'The four things worth asking your employer, in writing',
          rows: [
            ('Your leave dates', 'Start, end and how it was calculated.'),
            ('Nursing breaks after you return',
                'What the policy is and who to arrange them with.'),
            ('A private room and a fridge',
                'Not a toilet. Ask specifically, and ask early.'),
            ('Work from home or flexible hours',
                'Whether it is available and for how long.'),
          ],
          note: 'In writing, by email, is the whole point. Verbal agreements '
              'about maternity arrangements have a way of being remembered '
              'differently.',
          hue: 186,
        ),
        PpCards([
          PpCard('Ask by email, always',
              'Even for something you have already discussed. "Just to confirm '
              'what we agreed" is a complete and non confrontational email.'),
          PpCard('Ask about the policy, not about a favour',
              '"What is the company policy on nursing breaks" is a different '
              'question from "would it be alright if".'),
          PpCard('Talk to HR, not only to your manager',
              'Your manager may not know the policy. HR is obliged to.'),
          PpCard('Keep every message',
              'Emails, letters, the policy document. If something goes wrong '
              'later, the record is what you will have.'),
          PpCard('Find the woman who went before you',
              'Somebody in your organisation has already done this. She knows '
              'what actually happens, which is different from what is written.'),
        ], heading: 'How to ask', hue: 186),
        PpCallout(
          'If you are being pressured to resign, having your leave shortened, or '
          'being told the entitlement does not apply to you, do not accept a '
          'verbal explanation. Ask for it in writing, and take proper advice. '
          'This page is a summary, not legal advice, and your situation may have '
          'details it does not cover.',
        ),
        PpIndiaNote('If you work informally, are self employed, or run your own '
            'thing, none of the above applies to you and there is no honest way '
            'to pretend otherwise. What is worth doing instead is deciding your '
            'own return date on purpose rather than drifting into it, and '
            'telling the people who depend on you what it is.'),
      ],
    ),
    PpPage(
      id: 'work_milk_stash',
      title: 'Building a milk stash before you go back',
      format: 'ARTICLE',
      bands: _cleared,
      blocks: [
        PpIntro('You need far less stored milk than the internet suggests, and '
            'you need to start earlier than feels necessary. Both of those are '
            'the opposite of what most mothers assume.'),
        PpArticle([
          'What you actually need on day one is roughly what she will drink '
          'while you are away, and after that you are replacing each day with '
          'what you pumped the day before. The freezer stash is a buffer for bad '
          'days, not the supply itself. Two or three days of feeds is plenty and '
          'a hundred bags is a source of stress.',
          'Milk works on removal, so the way to build a stash is one extra '
          'removal a day rather than pumping harder at existing feeds. Early '
          'morning is when most mothers get the most, because supply is highest '
          'after the long night gap.',
        ], heading: 'How much you actually need'),
        PpSteps([
          PpStep('Start about four weeks out, one session a day',
              'Usually in the morning, an hour after the first feed. Small '
              'amounts at first is normal, and it grows.'),
          PpStep('Expect very little at first and keep going',
              'Thirty or forty millilitres in a session is a normal start. '
              'Your body adds the extra removal to its calculation over about a '
              'week.'),
          PpStep('Freeze in small amounts, sixty to ninety millilitres',
              'Thawed milk that is not finished gets thrown away. Small bags '
              'waste far less.'),
          PpStep('Label every bag with the date, and use the oldest first',
              'A date written on the bag is the whole system.'),
          PpStep('Let somebody else give the first bottle',
              'Ideally three weeks out, so there is time for several attempts. '
              'Many babies refuse a bottle from their mother and take it '
              'happily from a father or a grandmother.'),
          PpStep('Try a cup or a paladai if the bottle is refused',
              'Widely used in India, works well from a few months, and avoids '
              'the whole bottle argument.'),
        ], heading: 'How to build it'),
        PpCallout(
          'If pumping gives you almost nothing, that is not a verdict on your '
          'supply. A lot of mothers with plenty of milk respond poorly to a '
          'pump, because a pump is not a baby. Check the flange size, try after '
          'the morning feed, and get help before you conclude anything.',
        ),
        PpConsult(
          title: 'Pumping and back to work session',
          whoFor: 'For a mother returning to work who wants a plan for pumping, '
              'storing and keeping supply going, or who is getting very little '
              'from a pump. Covers flange fit, timing and how to protect supply '
              'once you are back.',
          surfaceId: 'pp_experts',
          role: 'lactation',
        ),
        PpLink('Pumps, bags and cooler bags, compared',
            surfaceId: _shopSurface,
            blurb: 'Which pump, and what you actually need alongside it.'),
        PpWhenLine('Start about four weeks before your return. Aim for two or '
            'three days of feeds stored, not a freezer full.'),
        // REQUIRED_REVIEW: the "two or three days of feeds" target, the thirty
        // to forty millilitre expectation for an early pumping session, and the
        // sixty to ninety millilitre freezing portions. A lactation consultant
        // should confirm all three numbers.
      ],
    ),
    PpPage(
      id: 'work_pumping_no_room',
      title: 'Pumping at work when there is no room to pump in',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('Most Indian workplaces have no feeding room, no fridge you '
            'would want to use, and no culture of asking. This page assumes all '
            'of that and works anyway.'),
        PpArticle([
          'The advice written elsewhere assumes a lactation room with a lock, a '
          'chair and a fridge. If you have that, use it. If you do not, the '
          'problem is solvable with a hands free set, a cooler bag and about '
          'twenty minutes twice a day, and a great many mothers do it in '
          'exactly those conditions.',
          'The part that decides whether it works is not equipment. It is having '
          'the two slots in your calendar as actual blocked meetings, so they '
          'survive a busy day. Pumping that happens only when there is time '
          'stops happening in the second week.',
        ], heading: 'Starting from what you actually have'),
        PpSteps([
          PpStep('Block two slots in your calendar and name them anything',
              'Twenty minutes each, mid morning and mid afternoon. Treat them '
              'as immovable, because supply is what is at stake.'),
          PpStep('Find the room before your first day',
              'A meeting room that locks, the sick room, the HR room, a '
              'colleague\'s cabin, or the car in the parking area. Ask HR once, '
              'in writing, before you try to improvise.'),
          PpStep('Use a hands free or wearable pump if you can afford one',
              'It turns pumping into something you can do at a desk under a '
              'dupatta, and it is the single item most working mothers say '
              'changed it.'),
          PpStep('Carry a cooler bag with ice packs',
              'Milk keeps safely in a good cooler bag with ice for a working '
              'day, so an office fridge is convenient rather than essential.'),
          PpStep('Wear clothes that open, and carry a spare top',
              'Kurta over leggings, front open shirt, a dupatta or a nursing '
              'cover. Leaks happen, and a spare top ends the panic.'),
          PpStep('Wash parts once at work, sterilise at home',
              'Hot water and soap in the office, or a wet bag and one wash at '
              'the end of the day. Nobody sterilises at work.'),
          PpStep('Feed her yourself in the morning and evening',
              'Direct feeds before you leave and as soon as you are back, plus '
              'night feeds, keep supply up more than any amount of pumping.'),
        ], heading: 'The system that works'),
        PpChartCard(
          title: 'Storing expressed milk, roughly',
          rows: [
            ('At room temperature', 'A few hours, less in an Indian summer'),
            ('In a cooler bag with ice packs', 'About a working day'),
            ('In the fridge', 'Around three to five days, at the back'),
            ('In a freezer compartment', 'A few weeks'),
            ('In a deep freezer', 'Several months'),
            ('Thawed, in the fridge', 'Use within a day, never refreeze'),
          ],
          note: 'Never microwave it and never boil it. Stand the bag in warm '
              'water. Heat destroys the parts of milk that make it worth all '
              'this effort.',
          hue: 186,
        ),
        // REQUIRED_REVIEW: every milk storage duration in the chart above. They
        // are given deliberately as ranges rather than exact hours, and Indian
        // ambient temperatures mean the room temperature figure in particular
        // needs a clinician or lactation consultant to set it. These numbers
        // must be confirmed before ship, because a mother will act on them.
        PpCallout(
          'Milk that smells sour or looks curdled after shaking should be thrown '
          'away. Separated milk with a fat layer on top is normal and just needs '
          'swirling. If you are unsure, ask your paediatrician rather than '
          'guessing.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('If there is genuinely nowhere and asking is not realistic, '
            'a lot of mothers use the car, a locked meeting room booked in '
            'someone else\'s name, or the drive itself with a wearable pump. '
            'None of that is ideal and all of it is better than stopping because '
            'the office had no room.'),
      ],
    ),
    PpPage(
      id: 'work_childcare',
      title: 'Who will hold her at ten in the morning',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('This is the decision the whole return rests on, and it is worth '
            'more of your time than the work arrangements are. Get this right '
            'and everything else is logistics.'),
        PpArticle([
          'In India most families end up with one of four arrangements, and they '
          'have genuinely different trade offs rather than one being correct. '
          'What matters is not which you pick. It is that you picked it '
          'deliberately, with a trial period, and with a plan for what happens '
          'when it does not work.',
        ], heading: 'The honest comparison'),
        PpTable(
          columns: ['Arrangement', 'What it is good at', 'The real cost'],
          rows: [
            [
              'A grandparent at home',
              'Trusted, familiar, flexible, usually free',
              'Older bodies get tired, advice becomes authority, and it is hard '
                  'to correct family'
            ],
            [
              'A hired nanny or aaya at home',
              'One to one, her own routine, her own home',
              'Hardest to verify, no cover when she is ill, and you are her '
                  'only supervision'
            ],
            [
              'A creche or daycare',
              'Regulated, staffed, cover when someone is sick, other children',
              'More illness in the first months, fixed timings, and cost'
            ],
            [
              'Office creche or a nearby one',
              'You are close, and you can feed in the day',
              'Only exists at larger employers, and depends on your commute'
            ],
          ],
          heading: 'The four arrangements, honestly',
        ),
        PpSteps([
          PpStep('Visit unannounced, at least once',
              'For any creche. What it looks like on a normal Tuesday '
              'afternoon is the real answer.'),
          PpStep('Ask the ratio, and count the adults yourself',
              'How many children per adult in her age group, and who is with '
              'them at nap time.'),
          PpStep('Ask what happens when she cries and will not settle',
              'The answer to this question tells you more than any brochure.'),
          PpStep('Check for a first aid trained adult and what they do in an '
              'emergency',
              'Which hospital, who calls you, how fast.'),
          PpStep('Do a paid trial fortnight before you commit',
              'And for a nanny, do the overlap week while you are still home.'),
          PpStep('Verify identity and references for anyone in your home',
              'Documents, a previous family you can call, and police '
              'verification where it is available.'),
          PpStep('Agree the non negotiables out loud on day one',
              'Nothing in her mouth that you have not agreed, no honey, no '
              'kajal, no screen, and how she sleeps.'),
        ], heading: 'How to choose, whichever you choose'),
        PpCallout(
          'Never leave a young baby alone with anyone whose full name and '
          'address you do not have, and never with anyone you have not watched '
          'with her for several hours. This one has no exceptions and it is not '
          'about trust.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'Expect more coughs and colds in the first few months of any group '
          'setting. That is normal and not a sign you chose wrong. Talk to your '
          'paediatrician about which symptoms mean keeping her home, and make '
          'sure her vaccinations are up to date before she starts.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('The grandparent arrangement is the most common here and the '
            'least often discussed properly. Agree the hours, agree what happens '
            'when they need a break, and say the non negotiables kindly and '
            'once, at the start. Assuming it will be fine because it is family '
            'is how it goes wrong six months later.'),
      ],
    ),
    PpPage(
      id: 'work_guilt',
      title: 'The guilt, which almost every mother has',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('Whatever you decide, you will feel you decided wrong. Mothers '
            'who go back feel guilty for leaving. Mothers who stay feel guilty '
            'for stopping. That is not a coincidence.'),
        PpArticle([
          'The guilt is not evidence that you are doing something harmful. It is '
          'produced by a story that says a good mother is continuously present, '
          'a story nobody applies to fathers, and one that would have baffled '
          'every generation of women who worked in fields and factories with '
          'their children nearby.',
          'The research question you are actually worried about has been studied '
          'a great deal. What predicts how children do is the quality of care '
          'they get and the stability of the people giving it, far more than '
          'whether their mother is in the building. A child with a warm, '
          'consistent carer and a mother who returns to her every evening is not '
          'a child at risk.',
          'And the version of you that goes to work is often the version she '
          'gets more of in the evening. That is not a consolation. For a lot of '
          'mothers it is simply the truth.',
        ], heading: 'Where the guilt actually comes from'),
        PpCards([
          PpCard('Guilt at the door in the morning',
              'Almost always worst in the first ten days. It usually settles '
              'into ordinary sadness, which is easier to carry.'),
          PpCard('She cries when you leave',
              'Most babies settle within minutes. Ask the carer to message you '
              'ten minutes later. Once, not every day.'),
          PpCard('She reaches for the carer instead of you',
              'That is attachment working, not attachment lost. A baby who has '
              'a second safe adult is a lucky baby.'),
          PpCard('You are relieved to be at work',
              'Very common, deeply guilt inducing, and it means nothing bad '
              'about you at all.'),
          PpCard('You missed something for the first time',
              'A first step, a first word. It genuinely hurts. It also does not '
              'change your relationship with her.'),
        ], heading: 'The shapes it takes', hue: 186),
        PpCallout(
          'Do not use the goodbye to make yourself feel better. A quick, warm, '
          'confident goodbye with a consistent little phrase is easier for her '
          'than a long one, and far easier than slipping out unseen.',
        ),
        PpCallout(
          'Talk to your doctor if the guilt has turned into dread, crying most '
          'days, being unable to concentrate at work, or a conviction that she '
          'is better off without you. That last one in particular is a symptom '
          'of postpartum depression rather than a thought about childcare, and '
          'it responds well to treatment.',
          kind: PpCalloutKind.doctor,
        ),
        PpIndiaNote('You will also be told you are being selfish, sometimes by '
            'people who never had the option to work. It is worth remembering '
            'that what you are hearing is often about their life rather than '
            'yours.'),
      ],
    ),
    PpPage(
      id: 'work_first_week',
      title: 'The first week back',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('The first week is its own event and it is harder than the '
            'weeks after it. Almost every mother describes the same shape, so it '
            'is worth knowing it in advance.'),
        PpSteps([
          PpStep('Go back mid week, not on a Monday',
              'A Wednesday start gives you a three day week and a weekend to '
              'recover in.'),
          PpStep('Lay everything out the night before',
              'Clothes, pump parts, bags, her things, your lunch. Mornings with '
              'a baby have no slack in them at all.'),
          PpStep('Expect the first morning to go badly, and plan for it',
              'Leave twenty minutes earlier than you need. Something will '
              'happen at the door.'),
          PpStep('Ask the carer to send one message mid morning',
              'One, at a fixed time. Constant updates make the day harder, not '
              'easier.'),
          PpStep('Do not try to prove anything in week one',
              'Nobody expects your best work in the first fortnight, and trying '
              'to demonstrate that nothing has changed is exhausting.'),
          PpStep('Protect the two pumping slots from day one',
              'Skipping them in the first week to look committed is how supply '
              'drops in the second.'),
          PpStep('Come home and do nothing but be with her',
              'The house can wait a week. This hour is what the whole '
              'arrangement is for.'),
        ], heading: 'How to get through it'),
        PpArticle([
          'Two things surprise most mothers. The first is how quickly the days '
          'become ordinary, usually by the second or third week. The second is '
          'how much it takes out of you to be pleasant and competent for eight '
          'hours after months of not having to be either.',
          'It is also common to feel two contradictory things at once: relief at '
          'being a person with a name and a role again, and grief at not being '
          'the one who is with her. Both are allowed to be true.',
        ], heading: 'What nobody warns you about'),
        PpCallout(
          'Feeding often changes in the first fortnight back. Many babies '
          'reverse cycle, feeding less in the day and much more in the evening '
          'and at night. That is normal, it is her getting what she needs, and '
          'it usually settles.',
        ),
        PpCallout(
          'Talk to your doctor if by the end of the first month back you are '
          'still crying daily, not sleeping even when she does, or dreading each '
          'morning in a way that is not lifting. A hard first week is normal. A '
          'hard month is worth help.',
          kind: PpCalloutKind.doctor,
        ),
        PpVideoSlot(
          title: 'Three mothers on their first week back',
          subtitle: 'A software engineer, a teacher and a doctor, on what '
              'actually happened and what they would do differently.',
          minutes: '12 MIN',
          slotId: 'youmaa/work_mother_story',
          hue: 186,
        ),
      ],
    ),
    PpPage(
      id: 'work_not_going_back',
      title: 'Choosing not to go back',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('Not returning is a real decision made by a great many Indian '
            'mothers, sometimes freely and sometimes not. This page is about '
            'making it deliberately rather than drifting into it.'),
        PpArticle([
          'There is a version of this that is a genuine choice, and a version '
          'that is what is left after the childcare did not work out, the '
          'commute was impossible, the employer was unhelpful and the family '
          'assumed. Those two feel completely different a year later, even when '
          'they look identical from outside.',
          'So the useful thing is to name which one it is, out loud, to '
          'yourself. If it is a choice, it is one worth making without apology. '
          'If it is not, it is worth knowing that, because it changes what you '
          'do next.',
        ], heading: 'Two different decisions that look the same'),
        PpCards([
          PpCard('Say what the decision actually is',
              'Leaving for now, or leaving this job, or leaving this field. '
              'They have very different consequences and they get blurred.'),
          PpCard('Keep one professional thread alive',
              'A certification, a few contacts, a freelance piece, a group you '
              'stay in. A gap with a thread through it is a much easier gap to '
              'explain later.'),
          PpCard('Talk about money honestly, now',
              'Whose account, what you have access to, what happens if things '
              'change. Financial dependence is the part nobody discusses at the '
              'time and everybody notices later.'),
          PpCard('Agree it is a decision with a review date',
              '"For a year, and then we look again" is very different from '
              '"she stopped working".'),
          PpCard('Do not accept it being decided for you in a conversation you '
              'were not in',
              'This is your career. It is reasonable to say that plainly.'),
          PpCard('Notice if you are grieving it',
              'Leaving work you loved is a real loss, and it often arrives late '
              'rather than at the time.'),
        ], heading: 'What to sort out either way', hue: 186),
        PpCallout(
          'Full time mothering is work. It is unpaid, largely unrecognised, and '
          'it is roughly two full time jobs when the children are small. Nothing '
          'in this section treats it as the option for mothers who could not '
          'manage the other one.',
        ),
        PpIndiaNote('In many families this is not framed as a decision at all, '
            'and the assumption is simply made. If that is what happened in '
            'yours, it is still worth having the conversation, even after the '
            'fact, and even if the outcome does not change.'),
      ],
    ),
    PpPage(
      id: 'work_finding_yourself',
      title: 'Finding yourself again',
      format: 'ARTICLE',
      bands: _later,
      blocks: [
        PpIntro('At some point the healing is done, the feeding is settled, and '
            'a quieter question arrives: where did the rest of you go, and is '
            'she coming back.'),
        PpArticle([
          'For months you were called somebody\'s mother by people who knew your '
          'name. Your day was organised entirely around another person\'s needs. '
          'Everything you used to do for no reason at all, reading, music, '
          'friends, a walk with nowhere to be, quietly stopped, and nobody '
          'noticed including you.',
          'The version of yourself you are looking for is not exactly the one '
          'you had. That is genuinely the hard part, and it is not a defeat. '
          'Most mothers describe arriving somewhere new rather than going back, '
          'usually around a year, often later, and almost always in small pieces '
          'rather than all at once.',
        ], heading: 'What actually changed'),
        PpCards([
          PpCard('Take back one small thing that is only yours',
              'Twenty minutes, three times a week. A book, a run, a class, a '
              'friend, music with headphones on.'),
          PpCard('Make it a fixed appointment, not spare time',
              'Spare time does not occur in a house with a small child. Put it '
              'in the week and tell somebody it is happening.'),
          PpCard('Answer questions about yourself with something else',
              'When someone asks how you are, try answering about you rather '
              'than about her. It is surprisingly hard and worth practising.'),
          PpCard('Keep two friendships alive on purpose',
              'Not the whole circle. Two, with actual effort, including one who '
              'is not a mother.'),
          PpCard('Do one thing you are bad at',
              'Being a beginner at something is the fastest way back to feeling '
              'like a person rather than a function.'),
          PpCard('Be somewhere without her, occasionally',
              'The first time is awful. The fourth time is not.'),
        ], heading: 'What actually helps', hue: 186),
        PpCallout(
          'Friendships will change, and some will end. Friends without children '
          'often drift, and mothers you barely knew become close. That is normal '
          'and it is not a judgement on anybody. Let the ones that are ending '
          'end gently.',
        ),
        PpVideoSlot(
          title: 'On becoming yourself again',
          subtitle: 'A conversation about identity after birth, and why it takes '
              'longer than the physical recovery does.',
          minutes: '15 MIN',
          slotId: 'youmaa/work_finding_self',
          hue: 186,
        ),
        PpLink('Something for you, not for her',
            surfaceId: 'pp_courses',
            blurb: 'Courses and classes, including ones with nothing to do with '
                'babies.'),
        PpCallout(
          'If nothing interests you at all, not your old life and not a new one, '
          'and that has been true for weeks, talk to your doctor. Losing '
          'interest in everything is a symptom of depression rather than a stage '
          'of motherhood, and it can begin many months after birth.',
          kind: PpCalloutKind.doctor,
        ),
      ],
    ),
  ],
);

// =============================================================================
//  10. YOU ARE NOT THE ONLY ONE
// -----------------------------------------------------------------------------
//  ⚠️ THE CIRCLE ITSELF IS NOT BUILT YET, AND THESE PAGES ARE WRITTEN SO THEY ARE
//  WORTH READING WITHOUT IT. `_circleSurface` is null, so every link to it renders
//  honestly as SOON. A set of pages that only works once someone wires a surface
//  would be a hole with a link in it, which is exactly the wiring failure this
//  repo keeps finding. So each page here does its own work first: what other
//  mothers are actually useful for, how to find them without the app, and what to
//  say when you do not know what to say.
//
//  ⚠️ COMMERCE NEVER APPEARS IN THIS AREA. Not once. A mother who has just said
//  out loud that she is lonely is the most sellable person in the app, which is
//  precisely why nothing is sold to her here.
//
//  ⚠️ THE CRISIS ROUTE APPLIES HERE TOO. Distress surfaces in peer groups more
//  often than anywhere else, because it is the one place she is not performing.
//  `circle_safe` carries the route and the ground rules together, and the rule
//  that peers are never a clinical source is stated rather than assumed.
//
//  ⚠️ THIS IS NOT THE LONELINESS PAGE. `mind_lonely` in "I do not feel like
//  myself" covers loneliness as a feeling and where it turns into something that
//  needs help. This area covers the practical half: other mothers, what they are
//  good for, and how to reach them.
// =============================================================================

const PpArea _theCircle = PpArea(
  id: 'the_circle',
  mark: IntentMark.improveMark,
  title: 'You are not the only one',
  blurb: 'Other mothers at the same stage as you, and what they are actually '
      'good for.',
  hue: 258,
  pages: [
    PpPage(
      id: 'circle_what_it_is',
      title: 'The 4th trimester circle',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('A small, moderated group of mothers whose babies are roughly '
            'the age of yours. Not a forum, not a feed, and not a place anyone '
            'is selling anything.'),
        PpArticle([
          'The reason it is grouped by stage rather than by topic is that the '
          'thing that helps most is talking to someone in the same week as you. '
          'A mother eleven days in and a mother of a two year old are having '
          'completely different problems, and general parenting groups mix them '
          'into advice that does not fit.',
          'So the circles are banded the way this whole section is: the first six '
          'weeks, six weeks to three months, three to six months, and mothers '
          'going back to work. You move with your baby.',
        ], heading: 'How it is put together'),
        PpCards([
          PpCard('Small, so it is not a feed',
              'A group you can actually read, with faces that repeat.'),
          PpCard('Grouped by your stage, not by topic',
              'Everyone in your circle is roughly where you are.'),
          PpCard('Moderated by a real person',
              'Someone whose job is to keep it safe and to step in when it is '
              'needed.'),
          PpCard('Free, and it stays free',
              'The circle is not part of anything paid, and nothing is sold '
              'inside it.'),
          PpCard('You can read without posting for as long as you like',
              'Most mothers do this for weeks first. That is a completely '
              'normal way to use it.'),
        ], heading: 'What it is', hue: 258),
        PpLink('Open your circle',
            surfaceId: _circleSurface,
            blurb: 'Mothers at the same stage as you. Moderated, and private.'),
        PpCallout(
          'The circle is being built, so the link above is not live yet. The '
          'rest of this area is worth reading anyway, because most of what other '
          'mothers are good for does not need an app at all.',
        ),
        PpIndiaNote('If you are worried about privacy, that is reasonable and it '
            'is the commonest reason Indian mothers stay silent in groups. Your '
            'circle does not show your full name to anyone outside it, and '
            'nothing you write there appears anywhere else in the app.'),
      ],
    ),
    PpPage(
      id: 'circle_what_helps',
      title: 'What other mothers are actually good for',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Peer support gets recommended so casually that it sounds like '
            'nothing. It is worth being precise about what it does well, because '
            'it also does some things badly.'),
        PpArticle([
          'The single thing other mothers give you that nothing else can is the '
          'sentence "me too, at exactly this age". Not advice. Recognition. A '
          'great deal of the distress of early motherhood is the private '
          'conviction that everyone else is managing and you alone are not, and '
          'that conviction does not survive contact with five honest women in '
          'the same month.',
          'They are also, practically, the best source in existence for things '
          'no professional knows: which paediatrician actually answers the '
          'phone, which carrier works for a small baby in this heat, what to say '
          'to your employer, and whether the thing your baby is doing at 4am is '
          'a thing.',
        ], heading: 'What it genuinely does'),
        PpTable(
          columns: ['Ask other mothers', 'Ask a professional'],
          rows: [
            ['Is this normal at this age', 'Is this normal for my baby'],
            ['How did you survive the first month', 'Why is feeding painful'],
            ['Which creche did you use', 'Is her weight gain fine'],
            ['What do I say to my mother in law', 'Should I be on medication'],
            ['Did you feel like this too', 'I am having frightening thoughts'],
            ['Which pump was worth it', 'My bleeding has increased'],
          ],
          heading: 'The dividing line, which matters',
        ),
        PpCallout(
          'A peer group is never a clinical source. Ten mothers agreeing about '
          'a symptom is ten anecdotes, and the one time it matters is exactly '
          'the time it will be wrong. Take anything clinical to your doctor, '
          'every time, even when the group is confident.',
          kind: PpCalloutKind.doctor,
        ),
        PpCards([
          PpCard('Comparison, when it arrives',
              'Someone\'s baby will sleep through at eight weeks and yours will '
              'not. That is variation, not a ranking.'),
          PpCard('Confident wrong advice',
              'Delivered warmly and at scale. Especially about sleep, weight '
              'and feeding.'),
          PpCard('The dramatic story',
              'The rare bad outcome travels furthest in any group. It is rare '
              'precisely because it is worth telling.'),
          PpCard('Group opinion hardening into a rule',
              'Every group develops an orthodoxy. Notice when yours has one.'),
        ], heading: 'What to be careful about', hue: 258),
        PpIndiaNote('The building or society group is often the most useful one '
            'you will ever be in, because those mothers are physically nearby at '
            '4pm. It is also the one where privacy is thinnest. Both things are '
            'true, and it is worth knowing which conversations belong there.'),
      ],
    ),
    PpPage(
      id: 'circle_finding_people',
      title: 'Finding your people, with or without an app',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('Most mothers do not have a ready made group and are not going '
            'to build one from nothing. What actually works is smaller and less '
            'ambitious than making friends.'),
        PpArticle([
          'Friendship after birth is mostly a numbers game played at very low '
          'energy. You do not need a group. You need two or three women whose '
          'babies are roughly the age of yours and whose messages you are glad '
          'to see. That is the whole target, and it is achievable.',
          'The other thing worth knowing is that almost everyone you might '
          'approach is also lonely and also assuming everyone else has this '
          'sorted. The first person to say something is doing everyone a '
          'favour.',
        ], heading: 'What you are actually looking for'),
        PpCards([
          PpCard('The mothers from your antenatal class or hospital',
              'Same due month, same hospital, same confusion. The easiest group '
              'there is, and it usually needs one person to start it.'),
          PpCard('Your building or society',
              'The park at five in the evening is the most reliable meeting '
              'place in urban India.'),
          PpCard('The vaccination waiting room',
              'Everybody there has a baby within weeks of yours and everybody '
              'is bored.'),
          PpCard('A postnatal yoga or exercise class',
              'Doing a thing together is far easier than meeting to talk.'),
          PpCard('Cousins, and cousins of friends',
              'The most underused source in Indian families. Someone in your '
              'extended family had a baby in the last year.'),
          PpCard('One person you already know, upgraded',
              'Often faster than finding anyone new. A school friend you have '
              'not spoken to in years is one message away.'),
        ], heading: 'Where the people actually are', hue: 258),
        PpSteps([
          PpStep('Say the honest sentence first',
              '"I am finding this harder than I expected" opens more doors than '
              'any amount of small talk.'),
          PpStep('Ask a specific question rather than making a general offer',
              '"Which pram did you get and do you regret it" starts a '
              'conversation. "We should meet sometime" does not.'),
          PpStep('Suggest something low stakes and nearby',
              'A walk in the park at five. Not lunch, not a plan, nothing that '
              'needs the baby to co-operate for two hours.'),
          PpStep('Accept every invitation for the first few months',
              'Even when you do not feel like it, which will be most times. It '
              'is almost always better than staying in.'),
          PpStep('Do not audition your parenting',
              'The friendships that last are with people you can be tired and '
              'unimpressive in front of.'),
        ], heading: 'How to start, when starting is the hard part'),
        PpCallout(
          'Two or three people is enough. This is not a project and you are not '
          'building a community. You are looking for the small number of women '
          'you can send a photograph to at 2am without explaining it.',
        ),
        PpIndiaNote('If you have moved to your mother\'s house for jaapa, you '
            'will make friends there and then leave. It still counts, and a '
            'group chat survives the move perfectly well.'),
      ],
    ),
    PpPage(
      id: 'circle_first_words',
      title: 'What to say when you do not know what to say',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('The hardest message in any group is the first one. Here are '
            'some that work, and they are all shorter and more honest than the '
            'one you were drafting.'),
        PpArticle([
          'Almost every mother writes her first message, reads it back, decides '
          'it sounds like complaining, and deletes it. The message she deleted '
          'was the useful one. Groups are made of people saying the thing they '
          'nearly did not say.',
        ], heading: 'Why the first one is hard'),
        PpScript([
          PpScriptLine(
            say: 'Three weeks in. Nobody warned me about the crying, mine not '
                'hers. How is everyone doing?',
            notThis: 'Hi everyone, happy to be here, hope you are all well.',
            why: 'Says something true, and asks a question. The polite version '
                'gets three heart emojis and no conversation.',
          ),
          PpScriptLine(
            say: 'Does anyone else feel completely fine at 11am and completely '
                'flattened by 6pm? Trying to work out if this is normal.',
            why: 'A specific question about a real thing. You will get five '
                'answers and probably a friend.',
          ),
          PpScriptLine(
            say: 'I do not have anything useful to add, I just wanted to say I '
                'am reading and it helps.',
            why: 'For when you have been lurking for weeks and cannot find a '
                'way in. This one always gets a warm answer.',
          ),
          PpScriptLine(
            say: 'That happened to me too and I thought I was the only one.',
            why: 'The single most useful sentence anyone says in a group like '
                'this. If you can only manage one, make it this one.',
          ),
        ], heading: 'Messages that actually start something'),
        PpCards([
          PpCard('You do not have to be having a good time to belong',
              'The mothers who say the hard things are the reason the group is '
              'worth being in.'),
          PpCard('You do not have to answer everything',
              'Reading is participating. Nobody is counting.'),
          PpCard('Do not give medical advice, even when you are sure',
              '"That happened to us, we saw the doctor and she said" is the '
              'safe shape.'),
          PpCard('Photographs of your worst day are allowed',
              'A messy room and an exhausted face does more for everyone in '
              'that group than a good one does.'),
          PpCard('Leave a group that makes you feel worse',
              'Quietly, without explaining. Not every group is your group.'),
        ], heading: 'How to be in it', hue: 258),
        PpIndiaNote('If English is not what you are comfortable writing in, '
            'write in whatever you speak at home. Nobody in a mothers\' group at '
            '3am is reading for grammar.'),
      ],
    ),
    PpPage(
      id: 'circle_safe',
      title: 'How the circle is kept safe',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('A group of exhausted new mothers is a place where real distress '
            'surfaces, often for the first time. So the rules here are stricter '
            'than a normal community, and they exist for that reason.'),
        PpCards([
          PpCard('A real moderator, not only a report button',
              'Someone reads the circle. Misinformation gets corrected rather '
              'than left standing.'),
          PpCard('No selling, no brand accounts, no affiliate links',
              'Nothing is advertised in the circle and nothing you say there is '
              'used to sell you anything.'),
          PpCard('No medical advice presented as fact',
              'Sharing what happened to you is welcome. Telling another mother '
              'what to do about a symptom is not.'),
          PpCard('No photographs of another mother or her baby',
              'Yours are yours. Nobody else\'s are yours to post.'),
          PpCard('No judgement on feeding, birth or working',
              'Formula, caesarean, epidural, going back at three months. These '
              'are not debates in here.'),
          PpCard('You can leave, delete and be forgotten',
              'At any time, without asking anybody.'),
        ], heading: 'The ground rules', hue: 258),
        PpArticle([
          'The rule that matters most is the one about distress. If a mother '
          'writes something that suggests she is in real trouble, the circle is '
          'not the answer and warm replies are not the answer. She gets routed '
          'to real help immediately, and the moderator does that rather than '
          'waiting for somebody to notice.',
          'That applies to you too, if you are the one writing it. Nobody in the '
          'circle will tell you to calm down and nobody will send you an '
          'article.',
        ], heading: 'What happens when someone is in trouble'),
        PpCallout(
          'If you are having thoughts of harming yourself or your baby, or '
          'thoughts that frighten you, do not wait for a reply in a group. Tell '
          'one person in the room today and tell your doctor in plain words. '
          'India has a free helpline you can call at any hour, and it is one tap '
          'below.',
          kind: PpCalloutKind.doctor,
          title: 'This one does not go in the circle first',
        ),
        PpLink('Get help now',
            surfaceId: _crisis,
            blurb: 'A number you can call this minute, and what to say.'),
        // REQUIRED_TO_CONFIRM: the helpline itself is never printed in this
        // file. Name, number and hours live once in `kCrisisHelplineName` /
        // `kCrisisHelplineNumber` / `kCrisisHelplineHours` in
        // lib/data/mind_mood_data.dart and are flagged there for the product
        // owner. Do not copy a number here.
        //
        // REQUIRED_TO_CONFIRM: who moderates the circle, in what hours, and what
        // the escalation path is when a moderator sees a distress signal
        // overnight. This page promises a real person. That promise must be
        // staffed before the circle opens, or the promise must be softened.
        PpIndiaNote('Nothing you write in the circle is visible to anyone in '
            'your family, appears in any other part of the app, or is shown '
            'against your name elsewhere. That matters more here than in most '
            'countries, and it is why the circle is separate from the wider '
            'community.'),
      ],
    ),
    PpPage(
      id: 'circle_comparison',
      title: 'The mothers online who all seem fine',
      format: 'ARTICLE',
      bands: _allBands,
      blocks: [
        PpIntro('At 3am, one handed, you will scroll. And everyone you see will '
            'be dressed, calm, and posting a photograph of a baby who is '
            'asleep.'),
        PpArticle([
          'Nobody posts the fourth hour of crying. Nobody posts the argument at '
          'midnight, the untouched plate, the feed that hurt so much she cried '
          'through it. What reaches you is a filtered selection of everyone '
          'else\'s best ninety seconds, arriving at the exact hour when your own '
          'defences are lowest.',
          'This is not a reason to feel weak about it. Comparing yourself to '
          'that is the normal function of a human brain given that input. The '
          'only real defence is to change the input.',
        ], heading: 'What you are actually looking at'),
        PpCards([
          PpCard('Mute rather than unfollow',
              'No awkwardness, no explanation, and you can undo it in a year.'),
          PpCard('Notice which accounts you feel worse after',
              'Not which are bad. Which make you feel worse. That is a '
              'different and more useful test.'),
          PpCard('Put the phone out of arm\'s reach of the feeding chair',
              'A book, or nothing, is better company at 3am than a feed of '
              'other people.'),
          PpCard('Follow the honest ones',
              'They exist. Accounts that show the mess do more for you than '
              'accounts that show the nursery.'),
          PpCard('Remember the milestone posts are a selection',
              'The mothers whose babies sleep through post about it. The '
              'mothers whose babies do not, do not.'),
        ], heading: 'What actually helps', hue: 258),
        PpCallout(
          'If comparison has turned into a settled belief that you are failing '
          'her, that is not about anyone\'s posts. Read the page on guilt and '
          'the comparison trap in "I do not feel like myself", because that '
          'belief is one of the most common and most treatable symptoms there '
          'is.',
        ),
        PpIndiaNote('The family WhatsApp group is often harder than any of this, '
            'because you cannot mute your relatives without it being noticed. '
            'You can, however, read it once a day instead of all day.'),
      ],
    ),
  ],
);

