// =============================================================================
//  Health — the section's content
// -----------------------------------------------------------------------------
//  Built from pp_specs/03-health.md, against the mechanism in
//  docs/PP-SECTION-PATTERN.md. Eleven areas plus eight tools.
//
//  ⚠️ THIS FILE IS DATA. There is no layout in it, on purpose. `PpSectionScreen`
//  renders the landing, `PpContentPage` renders every page. See pp_content.dart's
//  own header for the full argument.
//
//  ⚠️ MOST OF THIS SECTION IS A FRONT DOOR, NOT A REBUILD. The spec is explicit:
//  "this bracket is mostly LIVE, so wherever the app already has the right
//  screen, store, or feature, use that real one instead of a parallel version."
//  So the vaccination tracker, the growth journey, the health wallet, the
//  emergency card, the doctor visit companion, What Changed, ProblemSolver and
//  Nuskhe are all LINKED here and none of them is reimplemented. A second
//  vaccination schedule would be a second answer to "what is due next", and one
//  of the two would be wrong within a year.
//
//  What is genuinely NEW is the ILLNESS AND SYMPTOM CONTENT, which the app did
//  not have anywhere: fever, cough and cold, loose motions and vomiting, rashes,
//  ear pain, teething, constipation, the named infections, and the triage that
//  sits above all of them.
//
//  ⚠️ THE ORDER OF THE AREAS IS THE DESIGN. "Is this an emergency?" is FIRST,
//  because the spec says triage must be "prominent and fast; never buried under
//  home-care tips", and because the parent who needs it is the parent least able
//  to scroll. It carries no product, no course and no paid consult. Commerce
//  starts three areas later, and never on a red flag.
//
//  ⚠️ NEVER A DIAGNOSIS, NEVER A PRESCRIPTION. Every page here informs and
//  triages; the doctor decides. Dosing appears exactly once, on `fever_dosing`,
//  framed as a typical range to CONFIRM, never as an instruction, and the page
//  spends as many words on the mistakes as on the numbers.
//
//  ⚠️ EVERY CLINICAL NUMBER IN THIS FILE CARRIES A `REQUIRED_REVIEW` COMMENT.
//  Temperatures, doses, durations, breathing rates, dehydration signs, weight
//  thresholds and age cutoffs are all marked, because a number is the one kind of
//  copy that tone cannot soften: if it is wrong, it is wrong at the moment it
//  matters most. A paediatrician signs these off before release. Grep
//  `REQUIRED_REVIEW` for the full list.
//
//  ⚠️ INDIA-FIRST, AND NOT DECORATIVELY SO. The IAP schedule rather than a
//  Western one, the government hospital and its cost, dengue and typhoid in the
//  fever area, monsoon and air pollution as their own pages, ORS made at home,
//  the chemist who sells an antibiotic without a prescription, and the syrup
//  strengths sold in Indian pharmacies, which are where real dosing accidents
//  come from.
//
//  ⚠️ ENGLISH ONLY FOR NOW, plain String, per the standing instruction.
// =============================================================================

import 'package:flutter/material.dart' show Icons;

import 'pp_age_bands.dart';
import '../brackets/hub/hub_intent_art.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

// =============================================================================
//  THE BANDS
// -----------------------------------------------------------------------------
//  Health's own set rather than kPpChildBands, and the reason is one boundary:
//  a fever under three months is an emergency and a fever at eight months is
//  usually not. A single "0 to 12 months" band would have to hedge that
//  sentence, and a hedged sentence is the wrong sentence at 2am. Everything
//  after three months bands the way the rest of the app does.
// =============================================================================

const PpBandSet kPpHealthBands = PpBandSet([
  PpBand(
    id: 'hb_nb',
    label: 'Newborn, 0 to 3 months',
    fromMonths: 0,
    toMonths: 3,
    blurb: 'The age where a fever is never watched at home, and a few ordinary '
        'things look frightening.',
  ),
  PpBand(
    id: 'hb_infant',
    label: '3 to 12 months',
    fromMonths: 3,
    toMonths: 12,
    blurb: 'First colds, first teeth, first tummy bugs.',
  ),
  PpBand(
    id: 'hb_toddler',
    label: '1 to 3 years',
    fromMonths: 12,
    toMonths: 36,
    blurb: 'The illness years. Creche, playgroup, and one thing after another.',
  ),
  PpBand(
    id: 'hb_child',
    label: '3 to 5 years',
    fromMonths: 36,
    toMonths: 72,
    blurb: 'Fewer bugs, longer sentences, and a child who can tell you where '
        'it hurts.',
  ),
]);

// =============================================================================
//  THE SECTION
// =============================================================================

final PpSection kPpHealthSection = PpSection(
  id: 'parenting_health', // MUST match the hub's bracketId.
  title: 'Health',
  subtitle: 'Is this normal, and does it need a doctor?',
  intro: 'When something is wrong, a fast and calm answer. When nothing is '
      'wrong, the proof that nothing is wrong.',
  bandSet: kPpHealthBands,
  areas: [
    _emergency,
    _fever,
    _coughCold,
    _tummy,
    _skin,
    _otherIllness,
    _notSure,
    _vaccines,
    _growth,
    _records,
    _prevention,
  ],
  tools: [
    // ⚠️ THE ONE GENUINELY NEW TOOL. The spec calls it the flagship and says
    // exactly why: parents search "baby fever temperature" and "fever when to
    // worry" far more than they search any article, so fever is a DECISION they
    // arrive with, not a topic they browse. It takes an age and a temperature
    // and returns one of three answers, none of which is a diagnosis.
    PpSectionTool(
      label: 'Fever check',
      blurb: 'His age and his temperature, and a straight answer: see a doctor '
          'now, or watch him at home. Ten seconds.',
      surfaceId: 'pp_fever_check',
      icon: Icons.thermostat_outlined,
    ),
    // ⚠️ EVERYTHING BELOW IS REUSED, NOT REBUILT.
    PpSectionTool(
      label: 'His shots, and what is due next',
      blurb: 'The IAP schedule, what he has had, and a reminder before the next '
          'one is due.',
      surfaceId: 'pp_vaccines',
      icon: Icons.vaccines_outlined,
    ),
    PpSectionTool(
      label: 'Weight, height and head size',
      blurb: 'Plot him over time and see his own curve rather than a single '
          'number on a bad day.',
      surfaceId: 'pp_growth',
      icon: Icons.straighten_outlined,
    ),
    PpSectionTool(
      label: 'His health papers, in one place',
      blurb: 'Prescriptions, reports, visits, medicines and allergies, so you '
          'are not hunting through a drawer at the clinic.',
      surfaceId: 'pp_health_home',
      icon: Icons.folder_shared_outlined,
    ),
    PpSectionTool(
      label: 'Emergency card, ready to show',
      blurb: 'Blood group, allergies, weight, medicines and two numbers to call. '
          'Openable without unlocking a folder.',
      surfaceId: 'pp_emergency_card',
      icon: Icons.emergency_outlined,
    ),
    PpSectionTool(
      label: 'Before you see the doctor',
      blurb: 'Build the list of questions while you remember them, so the seven '
          'minutes are not wasted.',
      surfaceId: 'pp_doctor_visit',
      icon: Icons.medical_information_outlined,
    ),
    PpSectionTool(
      label: 'Something suddenly different?',
      blurb: 'A guided walk through what changed, from a low fever to a new '
          'rash, and where it leads.',
      surfaceId: 'pp_what_changed',
      icon: Icons.change_circle_outlined,
    ),
    PpSectionTool(
      label: 'Home remedies, marked honestly',
      blurb: 'The nuskhe that help, the ones that only comfort, and the few that '
          'are genuinely unsafe.',
      surfaceId: 'pp_nuskhe',
      icon: Icons.spa_outlined,
    ),
  ],
);

// =============================================================================
//  AREA 1 — Is this an emergency?
// -----------------------------------------------------------------------------
//  FIRST, DELIBERATELY, AND UPSELL FREE. The spec: "prominent and fast; never
//  buried under home-care tips" and "never a product surface". So there is no
//  PpConsult and no product link anywhere in this area. The only human offered
//  is a free route to one.
// =============================================================================

final PpArea _emergency = PpArea(
  id: 'emergency',
  mark: IntentMark.askDoctor,
  title: 'Is this an emergency?',
  blurb: 'The signs that mean go now, and the ones that can wait until morning.',
  hue: 12,
  pages: [
    PpPage(
      id: 'health_go_now',
      title: 'Go now, or can it wait?',
      format: 'FLAGGED REFERENCE',
      blocks: [
        PpIntro('This is the fastest page in the app. If any line below matches '
            'what you are seeing, stop reading and go. Everything else in Health '
            'will still be here when you are back.'),
        // REQUIRED_REVIEW: THE WHOLE OF THIS CALLOUT IS A RED FLAG LIST AND
        // MUST BE CONFIRMED BY A PAEDIATRICIAN BEFORE RELEASE. Specifically:
        //   * Fever of 100.4 F or 38 C in a baby under 3 months, treated as a
        //     same-hour hospital visit with no home dose first.
        //   * "Ribs sucking in, nostrils flaring, grunting" as the breathing
        //     signs we name, and whether head bobbing should be added.
        //   * A rash that does not fade under glass pressure.
        //   * No urine for 12 hours in a baby, 8 hours if he is also vomiting.
        //   * Any fit or seizure, including a first febrile fit.
        //   * Green or yellow vomit, and a swollen tender belly.
        PpCallout(
          'Breathing hard: fast breaths, ribs sucking in under the chest, '
          'nostrils flaring, or a grunt on every breath. Blue or grey lips, '
          'tongue or face. A fit or seizure of any kind. Floppy, or you cannot '
          'wake him properly. A fever of 100.4 F or 38 C in a baby under three '
          'months. A rash that does not fade when you press a clear glass on it. '
          'No urine for twelve hours. Green or yellow vomit with a swollen, '
          'tender belly. Any of these is a hospital, now, not a phone call '
          'first.',
          kind: PpCalloutKind.doctor,
          title: 'Go to a hospital now',
        ),
        PpTable(
          heading: 'The three speeds',
          columns: ['What you are seeing', 'How fast'],
          // REQUIRED_REVIEW: every row here is a triage threshold. Confirm in
          // particular the "fever above five days" cutoff, the "vomiting
          // everything for more than eight hours" cutoff, and whether a
          // limping or non weight bearing child belongs in same day rather
          // than can wait.
          rows: [
            ['Trouble breathing, a fit, unresponsive, blue lips', 'Now'],
            ['A newborn under three months with any fever', 'Now'],
            ['Vomiting everything for more than eight hours', 'Now'],
            ['A fever that has run more than five days', 'Same day'],
            ['Ear pain with fever, or discharge from an ear', 'Same day'],
            ['Loose motions with no urine and a dry mouth', 'Now'],
            ['A rash with a fever he is otherwise well with', 'Same day'],
            ['A cold, a cough, a mild fever, still feeding', 'Can wait'],
            ['Teething, a nappy rash, one loose stool', 'Can wait'],
          ],
        ),
        PpCallout(
          'Take three things with you and you save fifteen minutes at the worst '
          'possible time: his medicines in their own boxes, his vaccination '
          'card, and his most recent weight. Weight decides almost every dose he '
          'will be given, so write it inside the emergency card tonight.',
          kind: PpCalloutKind.safety,
          title: 'What to pick up on the way out',
        ),
        PpWhenLine('Any age. This page never age-bands, because a red flag at '
            'six weeks is a red flag at six years.'),
        // REQUIRED_REVIEW: the emergency numbers. 112 is the national emergency
        // number; 108 is the ambulance number in most, not all, states. Confirm
        // the wording before release, and confirm we are not implying an
        // ambulance is always the faster option.
        PpIndiaNote('112 reaches the national emergency line and 108 reaches an '
            'ambulance in most states. In heavy city traffic a car often gets '
            'there first, so start moving while somebody else makes the call. '
            'Know the nearest hospital with a paediatric emergency, not just the '
            'nearest hospital.'),
        PpVideoSlot(
          title: 'The signs that mean go now',
          subtitle: 'Breathing trouble, a fit, and the glass test for a rash, '
              'shown on real children.',
          minutes: '5 MIN',
          slotId: 'health/when_to_rush',
        ),
        PpLink(
          'Open his emergency card',
          surfaceId: 'pp_emergency_card',
          blurb: 'Blood group, allergies, weight and the two numbers to call.',
        ),
      ],
    ),
    PpPage(
      id: 'health_clinic_or_hospital',
      title: 'Clinic, or hospital?',
      format: 'COMPARISON TABLE',
      blocks: [
        PpIntro('Half the delay in a sick child is not knowing where to go. This '
            'is the short version, worth reading once on a calm day.'),
        PpTable(
          columns: ['Where', 'Good for', 'Not for'],
          rows: [
            [
              'Your own paediatrician',
              'Anything you can describe on the phone, fever, rashes, coughs, '
                  'feeds, follow ups',
              'Anything on the go now list, or a clinic that is closed',
            ],
            [
              'Government hospital OPD',
              'Vaccination, growth checks, ordinary illness, free or near free',
              'Long waits, so not for a child who is getting worse by the hour',
            ],
            [
              'Government hospital casualty',
              'A genuine emergency at any hour, and it will not turn you away',
              'A mild fever, where you will wait behind sicker children',
            ],
            [
              'Private hospital emergency',
              'A genuine emergency where you can pay, usually faster',
              'Routine illness, where it costs a great deal for the same advice',
            ],
            [
              'The chemist',
              'Buying what a doctor has already prescribed',
              'Deciding what he needs. That is not their job and not their '
                  'training',
            ],
          ],
        ),
        PpCallout('Pick your emergency hospital before you need it. Ask your '
            'paediatrician which one she would send your child to at 2am, and '
            'save it in your phone with the route.'),
        PpWhenLine('Do this once, in the first month, and never again.'),
        PpIndiaNote('Ask specifically whether the hospital has a paediatric '
            'emergency and a paediatric intensive care bed. Many large hospitals '
            'have neither, and finding that out at the gate costs the hour that '
            'mattered.'),
        PpLink(
          'Find a paediatrician near you',
          surfaceId: 'pp_find_help',
          blurb: 'Which kind of doctor for which problem, and who is nearby.',
        ),
      ],
    ),
    PpPage(
      id: 'health_calling_doctor',
      title: 'What to say when you call the doctor',
      format: 'SCRIPT BOX',
      blocks: [
        PpIntro('A doctor on the phone is deciding one thing: does this child '
            'need to be seen, and how fast. Four sentences give her that. A long '
            'history does not.'),
        PpScript(
          [
            PpScriptLine(
              say: 'He is four months old and he has a fever of 39 since last '
                  'night.',
              notThis: 'He has not been himself since yesterday.',
              why: 'Age and a number are the two things that change the answer.',
            ),
            PpScriptLine(
              say: 'The thing that frightened me is that he has not fed since '
                  'morning and his nappy is dry.',
              notThis: 'He was fine on Tuesday, then on Wednesday he...',
              why: 'Say the one worst thing first. The rest can follow if she '
                  'asks.',
            ),
            PpScriptLine(
              say: 'I gave paracetamol at 6am and again at noon, nothing else.',
              notThis: 'I gave him some syrup.',
              why: 'Which drug, and when, decides what she can tell you to give '
                  'next.',
            ),
            PpScriptLine(
              say: 'Should I bring him now, or in the morning?',
              notThis: 'Okay, thank you doctor.',
              why: 'Ask it directly. You are allowed to, and a straight question '
                  'gets a straight time.',
            ),
          ],
          heading: 'Four sentences',
        ),
        PpCallout(
          'If you finish the call still frightened, say so in those words: "I am '
          'still worried, I would rather bring him." A parent who is worried '
          'without being able to say why is a signal doctors are trained to take '
          'seriously.',
          kind: PpCalloutKind.doctor,
          title: 'You do not need a reason to insist',
        ),
        PpWhenLine('Before every call, take ten seconds to find his last '
            'weight and his temperature.'),
        PpIndiaNote('If your paediatrician answers on WhatsApp, send the '
            'temperature, his age and one clear photo of the rash or the spot. A '
            'photo saves a visit more often than a paragraph does.'),
        PpLink(
          'Build your question list before the visit',
          surfaceId: 'pp_doctor_visit',
          blurb: 'Write them down while you remember them.',
        ),
      ],
    ),
    PpPage(
      id: 'health_emergency_card',
      title: 'The card you want to already have',
      format: 'RECORDS',
      blocks: [
        PpIntro('Somebody else may be the one who takes him in: a grandparent, a '
            'neighbour, the person at the creche. The emergency card is for '
            'them, not for you.'),
        PpSteps([
          PpStep('Put his current weight in it',
              'Update it every time he is weighed. Almost every emergency dose '
              'is calculated from weight, and a guess costs time.'),
          PpStep('Put his blood group in it',
              'Ask at the next visit if you do not know it.'),
          PpStep('List every allergy and every regular medicine',
              'Including the inhaler, the drops, and anything ayurvedic. It all '
              'counts.'),
          PpStep('Two numbers, not one',
              'You, and one person who is reachable when you are not.'),
          PpStep('Add the paediatrician and the hospital you chose',
              'Name, number, and which hospital you would go to at night.'),
        ], heading: 'Five minutes, once'),
        PpCallout(
          'Show the card to whoever looks after him when you are out, today. A '
          'card nobody knows about is a card nobody opens.',
          kind: PpCalloutKind.safety,
        ),
        PpWhenLine('Fill it in this week. Update the weight at every growth '
            'check.'),
        PpIndiaNote('If he is with dadi or nani during the day, write the card '
            'out on paper too and stick it inside a kitchen cupboard. Not '
            'everybody in the house will open an app in a panic.'),
        PpLink(
          'Open the emergency card',
          surfaceId: 'pp_emergency_card',
          blurb: 'Fill it in once, keep it current.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 2 — He has a fever
// -----------------------------------------------------------------------------
//  The flagship reactive area. The spec's search data makes fever a DECISION
//  rather than a topic, which is why the tool leads and the articles support it
//  rather than the other way round.
// =============================================================================

final PpArea _fever = PpArea(
  id: 'fever',
  mark: IntentMark.bodyMark,
  title: 'He has a fever',
  blurb: 'What the number means, what to do tonight, and when it stops being '
      'something to watch.',
  hue: 28,
  pages: [
    PpPage(
      id: 'fever_what_number',
      title: 'What the number actually means',
      format: 'CHART-CARD',
      blocks: [
        PpIntro('A fever is not an illness. It is the body turning the heat up '
            'to fight one, and it is usually working. The number tells you less '
            'than how he looks.'),
        PpChartCard(
          title: 'Reading the number',
          subtitle: 'Measured under the arm, on a digital thermometer',
          // REQUIRED_REVIEW: EVERY ROW. Confirm with a paediatrician:
          //   * Normal range 97.5 F to 99.5 F (36.4 C to 37.5 C) axillary.
          //   * Fever defined at 100.4 F / 38.0 C, and whether an axillary
          //     reading should use a lower cutoff than a rectal one.
          //   * "High" at 102.2 F / 39 C and the statement that height alone
          //     does not decide severity.
          //   * 106 F / 41 C as the point at which the number itself matters.
          rows: [
            ('Normal', '97.5 F to 99.5 F, or 36.4 C to 37.5 C'),
            ('Warm, not yet a fever', '99.5 F to 100.4 F, or 37.5 C to 38 C'),
            ('Fever', '100.4 F or 38 C and above'),
            ('High fever', '102.2 F or 39 C and above'),
            ('Rare, and the number itself matters', '106 F or 41 C and above'),
          ],
          note: 'A child of two playing with a toy at 103 F is less worrying '
              'than a child of two who is limp at 100.6 F. Treat the child, not '
              'the thermometer.',
          hue: 28,
        ),
        PpCallout('There is no temperature at which a fever damages the brain. '
            'That belief is the reason families panic at a number, and it is not '
            'true of ordinary infection fevers.'),
        PpCallout(
          'Under three months, any fever at all is a same day hospital visit, '
          'whatever he looks like. A newborn with an infection can look almost '
          'well until he suddenly does not.',
          kind: PpCalloutKind.doctor,
          title: 'The one age where the number decides on its own',
        ),
        PpWhenLine('Check the temperature twice a day while he has a fever, and '
            'again if he changes.'),
        PpIndiaNote('In a 40 degree summer a baby who has been in a hot room, '
            'wrapped, or just fed can read half a degree high. Unwrap him, wait '
            'fifteen minutes and take it again before you act on it.'),
        PpLink(
          'Run the fever check',
          surfaceId: 'pp_fever_check',
          blurb: 'His age and his temperature, and what to do about it.',
        ),
        PpVideoSlot(
          title: 'Fever, explained in five minutes',
          subtitle: 'Why it happens, what it is doing, and the three things that '
              'actually change the decision.',
          minutes: '5 MIN',
          slotId: 'health/fever_explainer',
        ),
      ],
    ),
    PpPage(
      id: 'fever_reading',
      title: 'Reading a baby\'s temperature',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Half of the fever questions doctors get are really measurement '
            'questions. Where you took it, and with what, changes the number by '
            'a whole degree.'),
        PpArticle([
          'A digital thermometer under the arm is the right instrument for a '
          'baby at home. It is cheap, it is accurate enough for the decision you '
          'are making, and it cannot hurt him. Hold his arm gently down against '
          'his side so the tip is fully covered, and wait for the beep, then a '
          'few seconds more.',
          'Forehead and ear thermometers are quick and they drift. They are fine '
          'for a rough look, and if the reading surprises you, confirm it under '
          'the arm before you act on it. Ear readings in particular are '
          'unreliable in small babies because the ear canal is narrow.',
          'Do not use a mercury thermometer. If one breaks in a child\'s mouth '
          'you have two problems instead of one, and they are no longer sold for '
          'good reason. Do not take a temperature in the mouth of a child who '
          'cannot yet be told to hold still. And never judge a fever by touching '
          'his forehead: a hand tells you he is warm, which you already knew.',
        ]),
        PpTable(
          heading: 'Where to measure',
          columns: ['Method', 'Good for', 'Watch out for'],
          rows: [
            [
              'Under the arm, digital',
              'Every age, at home',
              'Needs the tip fully covered by skin, and a still arm',
            ],
            [
              'Forehead scanner',
              'A fast look, older children',
              'Reads low if he is sweaty, or has been near a fan or a heater',
            ],
            [
              'Ear',
              'Over one year',
              'Wax and a narrow canal make it unreliable in babies',
            ],
            [
              'Mouth',
              'Over four or five years',
              'Nothing hot or cold to drink for fifteen minutes first',
            ],
          ],
        ),
        PpCallout(
          'Do not add a degree to an underarm reading to "correct" it. Report '
          'the number you saw and say where you took it, and let the person you '
          'are speaking to do the adjusting.',
          kind: PpCalloutKind.safety,
        ),
        // REQUIRED_REVIEW: the fifteen minute wait after a bath, a feed, or
        // being wrapped, and the advice not to convert an axillary reading.
        PpWhenLine('Wait fifteen minutes after a bath, a feed, or being tightly '
            'wrapped before you trust a reading.'),
        PpIndiaNote('Keep one thermometer for the child and keep it where you '
            'can find it at night. A thermometer in a drawer somewhere is the '
            'reason so many families end up guessing.'),
      ],
    ),
    PpPage(
      id: 'fever_under_3m',
      title: 'A fever in a baby under three months',
      format: 'FLAGGED CALLOUT',
      bands: ['hb_nb'],
      blocks: [
        PpIntro('This page exists on its own because it is the one fever rule '
            'that has no home version. Under three months, fever is not watched '
            'at home.'),
        // REQUIRED_REVIEW: the entire rule. Confirm the age cutoff (3 months),
        // the threshold (100.4 F / 38 C), the instruction NOT to give
        // paracetamol before being seen, and the statement that a low
        // temperature is equally significant at this age.
        PpCallout(
          'A temperature of 100.4 F or 38 C or above in a baby under three '
          'months means being seen by a doctor today, not tomorrow, whatever '
          'else he seems like. Go to the hospital or call your paediatrician on '
          'the way. This is not a cautious rule, it is the rule.',
          kind: PpCalloutKind.doctor,
          title: 'Any fever, any time, seen today',
        ),
        PpCards([
          PpCard('Do not give paracetamol first',
              'Bringing the temperature down before he is examined hides the '
              'thing the doctor needs to see. Take him as he is.'),
          PpCard('A low temperature counts too',
              'A newborn who is unusually cold, below 97.5 F or 36.5 C, is as '
              'significant as one who is hot.'),
          PpCard('Say his age in days or weeks',
              'A newborn is a different patient at day 5 and day 50, and it '
              'changes what happens next.'),
          PpCard('Take the vaccination card',
              'What he has and has not had narrows the list quickly.'),
        ], heading: 'Four things that matter at this age', hue: 12),
        PpCallout('The reason is simple and worth knowing: a young baby has very '
            'few ways of showing he is unwell, so a fever carries more weight '
            'than it will at any later age.'),
        PpWhenLine('From birth to three months. After three months the rest of '
            'this area applies.'),
        PpIndiaNote('If the family is telling you it is only the weather, or '
            'teeth, or the malish oil, this is the one place to be firm. Teeth '
            'do not cause fever in a six week old baby.'),
      ],
    ),
    PpPage(
      id: 'fever_bringing_down',
      title: 'Bringing a fever down, and the sponging myths',
      format: 'ARTICLE',
      blocks: [
        PpIntro('The goal is a comfortable child, not a normal thermometer. If '
            'he is drinking, resting and not distressed, you do not have to do '
            'anything at all.'),
        PpArticle([
          'Fluids matter more than anything else you will do. A fever burns '
          'through water quickly, and most of the misery of a fever is really '
          'the dryness that comes with it. Offer the breast more often if he is '
          'still feeding, or small sips of water, milk, nimbu pani or ORS very '
          'frequently rather than a big glass occasionally.',
          'Take layers off. One thin cotton layer is right, even if he feels '
          'cold and asks for a blanket, because the shivering is the fever '
          'rising rather than the room being cold. A fan on low or a cooler is '
          'fine. He does not need a cold room and he does not need to be '
          'wrapped.',
          'Let him sleep. There is no need to wake a sleeping child to take his '
          'temperature or give him a dose. Sleep is doing more for him than the '
          'reading would tell you.',
        ]),
        PpSteps([
          PpStep('Offer fluid every twenty minutes',
              'Small amounts, often. This is the single most useful thing you '
              'will do all night.'),
          PpStep('Strip him down to one thin layer',
              'Cotton, loose. Cover with a sheet rather than a quilt.'),
          PpStep('Sponge with lukewarm water only if he is uncomfortable',
              'On the forehead, neck, armpits and groin. Stop if he starts '
              'shivering, because shivering pushes the temperature back up.'),
          PpStep('Consider paracetamol if he is miserable, not because of a number',
              'Comfort is the reason to give it. See the dosing page, and '
              'confirm the amount with your doctor.'),
          PpStep('Write down every dose and the time',
              'It is the question you will be asked, and it is the mistake '
              'families most often make when two adults are taking turns.'),
        ]),
        PpCallout(
          'Never sponge with cold water, ice, or anything containing alcohol or '
          'spirit. Cold makes the body shiver and drives the core temperature '
          'up, which is the opposite of what you wanted, and alcohol on skin can '
          'be absorbed. Use lukewarm water or nothing.',
          kind: PpCalloutKind.safety,
          title: 'Cold sponging makes it worse',
        ),
        PpCallout(
          'A fever that stays above 102 F after two doses of paracetamol given '
          'correctly, a child who will not drink, or a fever running past five '
          'days, all need a doctor rather than another dose.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: "two doses" and "past five days" as the points at
        // which home care stops, and the lukewarm sponging advice itself, which
        // some paediatricians now omit entirely.
        PpWhenLine('Reassess every four to six hours, and any time he looks '
            'different rather than just warm.'),
        PpIndiaNote('Wet cloth on the forehead is a comfort, not a treatment, '
            'and it is a perfectly good thing to do because it is soothing. Just '
            'do not stop offering fluids because the cloth feels like action.'),
      ],
    ),
    PpPage(
      id: 'fever_dosing',
      title: 'Paracetamol and ibuprofen: the typical ranges',
      format: 'FLAGGED CALLOUT + TABLE',
      blocks: [
        PpIntro('This page is here so you can check a number somebody has '
            'already given you, and so you can spot the common mistakes. It is '
            'not a prescription and it cannot be one.'),
        PpCallout(
          'These are typical ranges only. Your doctor decides your child\'s '
          'dose, because it depends on his exact weight, his kidneys and liver, '
          'and anything else he is taking. Confirm the amount and the gap with '
          'your paediatrician or a pharmacist before you give it, and if he is '
          'under three months, do not give either of these without being seen.',
          kind: PpCalloutKind.doctor,
          title: 'Confirm every dose with your doctor',
        ),
        PpTable(
          heading: 'Typical single doses, by weight',
          columns: ['Weight', 'Paracetamol, typical', 'Ibuprofen, typical'],
          // REQUIRED_REVIEW: EVERY NUMBER IN THIS TABLE. Built from
          // paracetamol at roughly 15 mg per kg per dose and ibuprofen at
          // roughly 10 mg per kg per dose. A paediatrician must confirm:
          //   * the mg per kg figures themselves,
          //   * the weight bands and the rounding,
          //   * that ibuprofen is withheld under 3 months (some guidance says
          //     6 months, and some withholds it in dengue and in dehydration),
          //   * the maximum daily totals stated below the table.
          rows: [
            ['4 to 6 kg', '60 to 90 mg', 'Not usually given under 3 months'],
            ['6 to 8 kg', '90 to 120 mg', '60 to 80 mg'],
            ['8 to 10 kg', '120 to 150 mg', '80 to 100 mg'],
            ['10 to 12 kg', '150 to 180 mg', '100 to 120 mg'],
            ['12 to 16 kg', '180 to 240 mg', '120 to 160 mg'],
            ['16 to 20 kg', '240 to 300 mg', '160 to 200 mg'],
          ],
        ),
        PpChartCard(
          title: 'The gaps, and the ceilings',
          // REQUIRED_REVIEW: dosing intervals and daily maxima. Paracetamol
          // every 4 to 6 hours, no more than 4 doses in 24 hours; ibuprofen
          // every 6 to 8 hours, no more than 3 doses in 24 hours, and always
          // with food or a feed.
          rows: [
            ('Paracetamol, gap between doses', '4 to 6 hours'),
            ('Paracetamol, most in 24 hours', '4 doses'),
            ('Ibuprofen, gap between doses', '6 to 8 hours'),
            ('Ibuprofen, most in 24 hours', '3 doses'),
            ('Ibuprofen and food', 'Always with a feed or a meal'),
          ],
          note: 'Write down the time of every dose. When two adults are taking '
              'turns through a night, a doubled dose is far more common than a '
              'missed one.',
          hue: 12,
        ),
        PpArticle([
          'The most dangerous mistake in Indian homes is not the milligrams, it '
          'is the bottle. Paracetamol is sold as drops at 100 mg in 1 ml for '
          'babies, as a syrup at 125 mg in 5 ml, and as a stronger syrup at 250 '
          'mg in 5 ml. The drops are more than ten times as concentrated as the '
          'syrup. Giving 5 ml of drops because a syrup dose was 5 ml is an '
          'overdose, and it happens.',
          'So read the strength on the label every single time, use the dropper '
          'or the cup that came in that box, and never a kitchen spoon. If you '
          'buy a different brand next time, check the strength again, because '
          'Crocin, Calpol, Dolo, Pyrigesic and Fepanil are all paracetamol at '
          'different strengths in different bottles.',
          'Paracetamol and ibuprofen are different drugs, so they can be '
          'alternated if a doctor tells you to. Two products that both contain '
          'paracetamol cannot be. A great many cold and cough combinations sold '
          'over the counter already contain paracetamol, which is how a child '
          'ends up with three doses when the family thinks he has had one.',
        ], heading: 'The mistake that actually happens'),
        PpCallout(
          'Never give aspirin to a child with a fever. In a viral illness it is '
          'linked to a rare but very serious liver and brain condition. And '
          'never give mefenamic acid syrup, sold as Meftal P, on your own '
          'judgement, however often it has been prescribed in the past. Use '
          'paracetamol as the first choice and let a doctor decide anything '
          'else.',
          kind: PpCalloutKind.safety,
          title: 'Two drugs to leave alone',
        ),
        // REQUIRED_REVIEW: the aspirin and Reye syndrome statement, the
        // mefenamic acid warning, the syrup strengths quoted (100 mg/ml drops,
        // 125 mg/5 ml and 250 mg/5 ml syrups), and the brand list.
        PpWhenLine('Only when he is uncomfortable. A fever with a cheerful child '
            'needs no medicine at all.'),
        PpIndiaNote('A chemist will hand over a fever syrup without a '
            'prescription and often a stronger one than a child needs. Ask which '
            'drug is in it and at what strength, and if the answer is vague, buy '
            'plain paracetamol instead.'),
        PpLink(
          'How to actually get medicine into him',
          pageId: 'prev_medicine',
          blurb: 'The dropper, the cheek, and what to do when he spits it out.',
        ),
      ],
    ),
    PpPage(
      id: 'fever_red_flags',
      title: 'Fever red flags: when to stop watching',
      format: 'FLAGGED CALLOUT',
      blocks: [
        PpIntro('Most fevers are viral and settle in two or three days. These '
            'are the ones that do not, and the signs worth checking for once '
            'each evening.'),
        // REQUIRED_REVIEW: every threshold in this callout, in particular the
        // five day duration, the "no urine in eight to twelve hours" figure,
        // and the febrile fit guidance below.
        PpCallout(
          'Call or go if: he is under three months with any fever; he is '
          'breathing fast or working hard to breathe; he has not passed urine in '
          'eight to twelve hours; he is very drowsy or very hard to console; the '
          'fever has run more than five days; a rash appears that does not fade '
          'under a pressed glass; he has a stiff neck or hates the light; or he '
          'simply looks wrong to you in a way you cannot explain.',
          kind: PpCalloutKind.doctor,
          title: 'Any one of these means a doctor',
        ),
        PpCards([
          PpCard('A fit with a fever',
              'A febrile fit is frightening and usually harmless. Put him on his '
              'side on the floor, do not put anything in his mouth, note the '
              'time, and get him seen the same day. A first fit always gets '
              'checked.'),
          PpCard('Fever that goes and comes back',
              'A fever that settles for a day and returns is worth a visit, '
              'especially in dengue and typhoid season.'),
          PpCard('Fever with no other symptom at all',
              'After three days with nothing else to explain it, a urine test is '
              'often the thing that finds the answer.'),
          PpCard('Fever after a foreign trip or a village stay',
              'Say where he has been. It changes what gets tested.'),
        ], heading: 'Four that need naming', hue: 12),
        PpCallout('You do not need to meet a threshold to be allowed to worry. '
            'If he looks wrong to you, that is a reason on its own, and it is a '
            'reason paediatricians respect.'),
        PpWhenLine('Look him over properly once each evening while the fever '
            'lasts, rather than checking the thermometer hourly.'),
        PpIndiaNote('In dengue season, ask about the platelet count rather than '
            'assuming a low one means hospital. Falling platelets matter; a '
            'single number on a report usually does not.'),
        PpConsult(
          title: 'Talk to a paediatrician tonight',
          whoFor: 'For the fever that has you awake at 1am and does not look '
              'like an emergency but does not feel fine either. A real '
              'paediatrician, on a call, who can tell you whether this waits '
              'until morning.',
          surfaceId: 'pp_experts',
          role: 'pediatrician',
        ),
      ],
    ),
    PpPage(
      id: 'fever_remedies',
      title: 'Home remedies for fever, honestly',
      format: 'CARDS',
      blocks: [
        PpIntro('Every family has its fever nuskhe, and some of them are lovely. '
            'Here is which ones help, which only comfort, and the two you should '
            'stop.'),
        PpCards([
          PpCard('Safe: a lukewarm wet cloth on the forehead',
              'Soothing, harmless, and it gives you something to do. It will not '
              'bring the temperature down much, and that is fine.'),
          PpCard('Safe: extra fluids, nimbu pani, coconut water, dal ka pani',
              'Genuinely useful. Fluid loss is most of what makes a feverish '
              'child miserable.'),
          PpCard('Safe: tulsi or ginger in warm water, over one year',
              'Comforting for an older child with a sore throat. Not a treatment '
              'for the fever itself.'),
          PpCard('Comfort only: ajwain potli on the chest',
              'Warm, familiar, and it does nothing to the infection. Keep it if '
              'it settles him, and keep giving fluids.'),
          PpCard('Myth: covering him to sweat the fever out',
              'Wrapping a hot child traps heat and pushes the temperature '
              'higher. One thin layer.'),
          PpCard('Stop: honey under one year',
              'Honey can carry spores that a baby under one cannot handle. Not '
              'in water, not on a nipple, not on a finger.'),
          PpCard('Stop: any syrup or churan from the chemist without a name',
              'If nobody can tell you which drug is in it and how much, it does '
              'not go into a feverish child.'),
        ], heading: 'Marked plainly', hue: 28),
        PpCallout(
          'A remedy is for comfort, not for cure. If a fever is running past the '
          'third day, or any red flag appears, the answer is a doctor rather '
          'than a stronger kadha.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: honey withheld under 12 months, tulsi and ginger
        // withheld under 12 months, and the "past the third day" trigger.
        PpWhenLine('Remedies alongside fluids and rest, at any age over one for '
            'the herbal ones, never instead of a visit.'),
        PpIndiaNote('Grandmothers are usually right about fluids and rest and '
            'usually wrong about covering up. That is a good trade, and it is '
            'worth saying out loud in the house rather than quietly doing the '
            'opposite.'),
        PpLink(
          'All 22 nuskhe, marked safe, comfort or unsafe',
          surfaceId: 'pp_nuskhe',
          blurb: 'Fever, cold, colic, teething, skin and sleep.',
        ),
      ],
    ),
    PpPage(
      id: 'fever_long',
      title: 'A fever that will not settle: dengue, typhoid and malaria',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Most fevers are done in three days. Once one runs longer than '
            'that, the question changes from how to bring it down to what is '
            'causing it.'),
        PpArticle([
          'Dengue usually arrives suddenly with a high fever, aching limbs, sore '
          'eyes and a flat red rash that comes later. The dangerous phase is not '
          'the fever itself, it is the day or two after the fever falls, when a '
          'child can become suddenly unwell. So a child whose dengue fever has '
          'just broken is a child to watch more carefully, not less.',
          'Typhoid builds instead of arriving. The fever climbs a little higher '
          'each day for a week, often with a sore tummy, a coated tongue and no '
          'appetite. It comes from contaminated food or water, it is common in '
          'much of India, and there is a vaccine on the IAP schedule that is '
          'worth asking about.',
          'Malaria comes and goes rather than staying: a fever with shaking '
          'chills and sweating, settling and returning. It matters where he has '
          'been in the last month, so say it without being asked. All three are '
          'diagnosed by a blood test, not by how the fever looks, and any fever '
          'past the third day deserves that test rather than another guess.',
        ]),
        PpTable(
          heading: 'Rough shapes, not a diagnosis',
          columns: ['Illness', 'The pattern', 'What usually settles it'],
          rows: [
            [
              'Ordinary viral fever',
              'High for two or three days, then gone',
              'Fluids, rest, time',
            ],
            [
              'Dengue',
              'Sudden high fever, body ache, rash later, worst as it falls',
              'A blood test, fluids, close watching',
            ],
            [
              'Typhoid',
              'Fever climbing over a week, tummy pain, no appetite',
              'A blood test, and antibiotics if confirmed',
            ],
            [
              'Malaria',
              'Fever with chills, coming and going',
              'A blood smear or rapid test',
            ],
            [
              'Urine infection',
              'Fever with nothing else, especially in a baby',
              'A urine test, which is easy to forget to ask for',
            ],
          ],
        ),
        PpCallout(
          'In dengue, avoid ibuprofen and any painkiller of that family unless a '
          'doctor has specifically told you to use it, because they affect '
          'bleeding. Paracetamol is the one to use, and a doctor should be '
          'guiding it by then anyway.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'Any fever running past the fifth day, any fever that returns after '
          'settling, and any fever with severe tummy pain, bleeding gums, black '
          'stools or a child who is suddenly quiet, is a hospital visit rather '
          'than a phone call.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the whole page. Confirm the dengue critical phase
        // description and the NSAID avoidance, the typhoid stepwise fever
        // pattern, the malaria travel history point, the "blood test after day
        // three" trigger, and the "past the fifth day" escalation.
        PpWhenLine('Think about this once a fever has run more than three days, '
            'or in monsoon and the weeks after it.'),
        PpIndiaNote('Dengue peaks after the monsoon. The single most useful '
            'thing you can do is empty standing water at home weekly: coolers, '
            'plant trays, the terrace bucket, the money plant bottle. The '
            'mosquito that carries dengue bites in the daytime, so daytime '
            'repellent and full sleeves matter more than a night net.'),
        PpLink(
          'What is due on his vaccination schedule',
          surfaceId: 'pp_vaccines',
          blurb: 'Typhoid conjugate is on the IAP list. Check where he is.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 3 — Cough, cold and a blocked nose
// -----------------------------------------------------------------------------
//  ⚠️ MEDICINE SAFETY LEADS, PRODUCT FOLLOWS. The spec is explicit about the
//  order on exactly these pages, because cough syrup is one of the highest
//  commercial-intent searches in the whole section and also one of the few
//  places an over-the-counter purchase can genuinely harm a small child. So the
//  safety page comes before the product link, on the same page, every time.
// =============================================================================

final PpArea _coughCold = PpArea(
  id: 'cough_cold',
  mark: IntentMark.listMark,
  title: 'Cough, cold and a blocked nose',
  blurb: 'Why it keeps coming back, what actually helps, and the syrups to '
      'leave on the shelf.',
  hue: 200,
  pages: [
    PpPage(
      id: 'cold_common',
      title: 'The common cold, and why it keeps coming back',
      format: 'ARTICLE',
      blocks: [
        PpIntro('If it feels like he has been ill since he started creche, he '
            'probably has. This is the most normal thing in small childhood and '
            'the most exhausting.'),
        PpArticle([
          'A young child catches somewhere between six and twelve colds a year, '
          'and more than that in the first year of creche or playgroup. There '
          'are hundreds of viruses that cause the common cold and he has met '
          'almost none of them, so each new one is a fresh illness rather than '
          'the old one coming back. This is his immune system doing its '
          'apprenticeship, and it does get better.',
          'A cold runs roughly like this: a day of being off colour, two or '
          'three days of a running nose and possibly a fever, then a week of a '
          'thick nose and a cough that will not quit. The cough is the part that '
          'frightens families, and it is the part that lasts longest. A cough '
          'that is slowly improving over two or three weeks after a cold is '
          'still an ordinary cough.',
          'There is no medicine that shortens a cold. Not an antibiotic, which '
          'does nothing at all to a virus, and not a cough syrup. What helps is '
          'fluid, a clear nose, an upright position for sleeping, and time. That '
          'is an unsatisfying answer and it is the true one.',
        ]),
        PpChartCard(
          title: 'What is normal, roughly',
          // REQUIRED_REVIEW: 6 to 12 colds a year, the 7 to 10 day cold, the
          // cough lasting up to 3 weeks, and green mucus not indicating a
          // bacterial infection. Confirm all four with a paediatrician.
          rows: [
            ('Colds a year, under five', '6 to 12, more in creche'),
            ('How long the cold lasts', '7 to 10 days'),
            ('How long the cough lasts', 'Up to 3 weeks, slowly improving'),
            ('When the fever should stop', 'Within 3 days, usually'),
            ('Green mucus means', 'The cold is a few days old, nothing more'),
          ],
          note: 'Green or yellow mucus is not a sign he needs an antibiotic. It '
              'is what mucus does after a few days.',
          hue: 200,
        ),
        PpCallout('Judge a cold by the child, not by the nose. A child who is '
            'eating, drinking and playing with a river of snot is fine. A child '
            'who is quiet and off his feeds with a small sniffle is the one to '
            'look at twice.'),
        PpCallout(
          'See a doctor if he is breathing fast or working hard to breathe, if '
          'the fever comes back after settling, if he is under three months, if '
          'he is pulling at an ear with a fever, or if he is getting worse after '
          'day five rather than better.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Expect a cold every few weeks through the first two years of '
            'creche, and fewer each year after that.'),
        PpIndiaNote('Not every cold is caused by the cooler, the fan, the bath, '
            'or wet hair. Colds are caused by viruses, which travel on hands and '
            'in crowded rooms. Washing hands at the door does far more than '
            'closing a window.'),
        PpLink(
          'Home remedies for cough and cold',
          pageId: 'cough_remedies',
          blurb: 'What helps, what only comforts, and what to stop.',
        ),
      ],
    ),
    PpPage(
      id: 'cold_blocked_nose',
      title: 'Clearing a blocked nose',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('A small baby breathes through his nose, so a blocked one means '
            'he cannot feed and cannot sleep. This is the single most useful '
            'thing you can do for a cold, and it takes two minutes.'),
        PpSteps([
          PpStep('Lay him on his back with his head slightly turned',
              'On your lap or on the bed. Somebody holding him helps.'),
          PpStep('Two or three drops of saline in each nostril',
              'Plain saline nasal drops from any chemist, or the ones your '
              'paediatrician recommended. This is salt water, not medicine.'),
          PpStep('Wait thirty seconds',
              'The saline is loosening thick mucus. Skipping this is why the '
              'aspirator does not seem to work.'),
          PpStep('Suction gently with a bulb or a nasal aspirator',
              'Squeeze the bulb first, then place it, then release. One or two '
              'goes per nostril and no more.'),
          PpStep('Wipe, and put a little coconut oil under the nose',
              'A sore red upper lip is half the misery of a cold by day three.'),
          PpStep('Do it before a feed and before sleep, not after',
              'Right after a feed it makes him vomit.'),
        ], heading: 'Saline, then suction'),
        PpCallout(
          'Suction no more than three or four times a day, and stop if the '
          'inside of the nose starts to bleed or he fights hard. An irritated '
          'nose swells and blocks more. Gentle and occasional beats thorough.',
          kind: PpCalloutKind.safety,
        ),
        PpArticle([
          'For sleeping, raise the head end of the mattress a little by putting '
          'a folded towel under the mattress, never a pillow under the baby. A '
          'pillow in the cot is a suffocation risk and it does not work anyway, '
          'because he rolls off it.',
          'Steam helps some children and burns others. If you use it, run a hot '
          'shower and sit in the steamy bathroom with him. Never hold a small '
          'child over a bowl of boiling water or a steamer, because scalds from '
          'exactly this are common enough that emergency doctors recognise them '
          'on sight.',
        ], heading: 'Sleeping and steam'),
        // REQUIRED_REVIEW: saline drop counts, the three to four times a day
        // suction limit, no pillow under a baby, and the steam scald warning.
        PpWhenLine('Any age, from the first cold. Most useful under one year, '
            'when he cannot blow his own nose.'),
        PpIndiaNote('Do not put mustard oil, garlic oil or breast milk into a '
            'baby nose to clear it. Saline is the only thing that belongs in '
            'there, and oil in the nose can reach the lungs.'),
        PpVideoSlot(
          title: 'Saline drops and a nasal aspirator, step by step',
          subtitle: 'Shown on a real baby, including how to hold him and how '
              'much suction is enough.',
          minutes: '4 MIN',
          slotId: 'health/nose_saline',
        ),
        PpLink(
          'Compare nasal aspirators',
          surfaceId: 'pp_compare',
          blurb: 'Bulb, tube and battery types, and what each is actually like '
              'to use at 3am.',
        ),
      ],
    ),
    PpPage(
      id: 'cough_syrups',
      title: 'Cough syrups: what is safe and what is not',
      format: 'FLAGGED CALLOUT + TABLE',
      blocks: [
        PpIntro('This is the shelf where a well meant purchase can do real harm. '
            'The short version: most cough syrups do not help a small child, and '
            'a few are dangerous.'),
        // REQUIRED_REVIEW: EVERY AGE CUTOFF ON THIS PAGE.
        //   * No over-the-counter cough and cold combination under 4 years
        //     (some authorities say 6). Confirm which we state.
        //   * Codeine and dextromethorphan withheld in young children, and the
        //     age at which each becomes acceptable.
        //   * Promethazine (Phenergan) not under 2 years.
        //   * Honey only over 12 months.
        PpCallout(
          'Do not give an over the counter cough and cold combination to a child '
          'under four. They have not been shown to help at this age and they '
          'carry real risks, including drowsiness deep enough to affect '
          'breathing. If your paediatrician has prescribed something specific '
          'for your child, follow her, not this page.',
          kind: PpCalloutKind.doctor,
          title: 'Under four, the answer is usually no syrup',
        ),
        PpTable(
          heading: 'What is in the bottle',
          columns: ['What it contains', 'What it does', 'For a small child'],
          rows: [
            [
              'Codeine',
              'Suppresses cough, an opioid',
              'No. It can slow a child\'s breathing',
            ],
            [
              'Promethazine, sold as Phenergan',
              'Antihistamine, strongly sedating',
              'Not under two years',
            ],
            [
              'Dextromethorphan',
              'Suppresses cough',
              'Not in small children, and it rarely helps',
            ],
            [
              'Combination cold syrups',
              'Several drugs at once, often with paracetamol',
              'No under four, and check for hidden paracetamol',
            ],
            [
              'Plain saline nasal drops',
              'Loosens mucus in the nose',
              'Yes, at any age',
            ],
            [
              'Honey, over one year',
              'Coats a sore throat, calms a night cough',
              'Yes over one year, never under',
            ],
          ],
        ),
        PpCallout(
          'Check every syrup in the house for paracetamol before you give a '
          'fever dose. Combination cold syrups very often contain it, and that '
          'is how a child receives a double dose while the family believes he '
          'has had one. Read the ingredients on the box, not the name on the '
          'front.',
          kind: PpCalloutKind.safety,
          title: 'The hidden paracetamol',
        ),
        PpWhenLine('A cough that is slowly improving needs nothing. A cough '
            'getting worse after five days, or with fast breathing, needs a '
            'doctor rather than a syrup.'),
        PpIndiaNote('A chemist will sell you any of these without a '
            'prescription, and will often recommend one. Ask which drug is in '
            'it. If the answer is "it is for cough", put it back.'),
        PpLink(
          'Compare cough and cold products for safety',
          surfaceId: 'pp_compare',
          blurb: 'Read the ingredient list rather than the label claim.',
        ),
      ],
    ),
    PpPage(
      id: 'cough_remedies',
      title: 'Home remedies for cough and cold',
      format: 'CARDS',
      blocks: [
        PpIntro('This is where Indian families start, and often they are right '
            'to. Here is what genuinely helps, what is comfort, and the two to '
            'stop.'),
        PpCards([
          PpCard('Helps: honey, over one year old',
              'A teaspoon at bedtime calms a night cough about as well as any '
              'syrup, and it has been tested properly. Never under one year.'),
          PpCard('Helps: warm fluids, all day',
              'Soup, dal ka pani, warm water, milk. Thins mucus and soothes a '
              'raw throat.'),
          PpCard('Helps: saline drops and a clear nose before feeds',
              'The most useful thing on this list for a baby under one.'),
          PpCard('Comfort: ajwain or garlic potli near the cot',
              'The warmth and the smell settle some babies. Keep it near him, '
              'never on his skin, and never hot enough to mark.'),
          PpCard('Comfort: haldi doodh, over one year',
              'Warm, soothing, familiar. It is not clearing an infection and it '
              'does not need to be.'),
          PpCard('Stop: oil, ghee or juice in the nose',
              'Oil in the nose can reach the lungs. Saline only.'),
          PpCard('Stop: rubbing a menthol balm under a baby nose',
              'Strong menthol products are not for small babies and can make '
              'breathing worse. Check the age on the tub.'),
        ], heading: 'Marked plainly', hue: 200),
        PpCallout(
          'A remedy is comfort, not cure. If he is breathing fast, pulling in '
          'under the ribs, refusing feeds, or getting worse after day five, that '
          'is a doctor and not a stronger kadha.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: honey over 12 months only, menthol rub age limits,
        // and the statement that honey performs comparably to cough syrup.
        PpWhenLine('Alongside fluids and rest, at any age. The honey ones only '
            'after his first birthday.'),
        PpIndiaNote('Kadha made for adults is usually too strong for a small '
            'child, and some contain a lot of black pepper and mulethi. Dilute '
            'heavily, or skip it for a child under two.'),
        PpLink(
          'All the cold and cough nuskhe, marked',
          surfaceId: 'pp_nuskhe',
          blurb: 'Five remedies in this category, each marked safe, comfort '
              'only, or unsafe.',
        ),
      ],
    ),
    PpPage(
      id: 'cough_breathing',
      title: 'When a cough is more than a cold',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost every cough is a cold. The few that are not announce '
            'themselves in the breathing rather than in the cough, and that is '
            'the thing worth learning to look at.'),
        PpArticle([
          'Take his shirt off and watch his chest for a full minute while he is '
          'calm or asleep. You are looking for three things: how fast he is '
          'breathing, whether the skin is sucking in under the ribs or at the '
          'base of the throat, and whether there is a small grunt at the end of '
          'each breath. Any of the three is worth a doctor today, whatever the '
          'cough sounds like.',
          'A wheeze is a whistling sound as he breathes out, and it usually '
          'means the small airways are narrowed. In babies under one this is '
          'often bronchiolitis, a viral illness that peaks around day three to '
          'five and then slowly settles. In older children a repeated wheeze '
          'with colds, at night, or on running about is worth asking a doctor '
          'about properly rather than treating each time as a fresh cold.',
          'A barking cough like a seal, worse at night, with a harsh noise as he '
          'breathes in, is croup. Cool night air often settles it within '
          'minutes, so stepping outside or opening a window is a reasonable '
          'first thing to do while you decide. If the noisy breathing continues '
          'when he is calm and sitting still, that is a hospital.',
        ]),
        PpChartCard(
          title: 'Breathing too fast, roughly',
          subtitle: 'Counted over a full minute, while he is settled',
          // REQUIRED_REVIEW: EVERY THRESHOLD. These are the standard WHO fast
          // breathing cutoffs and must be confirmed, along with the instruction
          // to count for a full minute at rest rather than while crying.
          rows: [
            ('Under 2 months', 'More than 60 breaths a minute'),
            ('2 to 12 months', 'More than 50 breaths a minute'),
            ('1 to 5 years', 'More than 40 breaths a minute'),
            ('At any age', 'Ribs sucking in, or a grunt on each breath'),
          ],
          note: 'Count while he is calm. A crying child breathes fast and it '
              'tells you nothing.',
          hue: 12,
        ),
        PpCallout(
          'Fast breathing, skin sucking in under the ribs, grunting, blue lips, '
          'or a child too breathless to feed or to finish a sentence, all mean '
          'being seen now. Do not wait for the morning clinic.',
          kind: PpCalloutKind.doctor,
          title: 'Breathing is the signal, not the cough',
        ),
        PpWhenLine('Look at his breathing once each evening during any chest '
            'illness, and again if he changes.'),
        PpIndiaNote('If a doctor has given an inhaler with a spacer, use the '
            'spacer. Inhalers are not addictive and they are not a last resort, '
            'and a spacer gets far more of the drug into a small child than a '
            'nebuliser hired by the day.'),
        PpConsult(
          title: 'Talk to a paediatrician about a cough that keeps coming back',
          whoFor: 'For the child whose every cold goes to his chest, or who '
              'wheezes at night, where you want somebody to look at the whole '
              'pattern rather than treat this week again.',
          surfaceId: 'pp_experts',
          role: 'pediatrician',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 4 — Loose motions, vomiting and a hard tummy
// -----------------------------------------------------------------------------
//  ⚠️ ORS IS THE ONE PIECE OF CONTENT IN THIS SECTION MOST LIKELY TO CHANGE AN
//  OUTCOME, so it gets its own page and its own step list rather than a
//  paragraph inside the diarrhoea article. Made wrong, ORS is worse than
//  nothing, and "one packet in one litre" is the single most misremembered
//  instruction in Indian home care.
// =============================================================================

final PpArea _tummy = PpArea(
  id: 'tummy',
  mark: IntentMark.blocksMark,
  title: 'Loose motions, vomiting and a hard tummy',
  blurb: 'Keeping fluid in him, spotting dehydration early, and what a tummy '
      'bug actually needs.',
  hue: 140,
  pages: [
    PpPage(
      id: 'tummy_diarrhoea',
      title: 'Loose motions',
      format: 'ARTICLE',
      blocks: [
        PpIntro('A tummy bug is unpleasant and usually harmless. The only thing '
            'that makes it dangerous is fluid running out faster than it goes '
            'in, and that is entirely in your hands.'),
        PpArticle([
          'Most loose motions are viral, they last three to seven days, and no '
          'medicine shortens them. Antibiotics do not help a viral tummy bug and '
          'usually make the stools worse. What matters is fluid, and then more '
          'fluid, in small amounts, all day.',
          'Keep feeding him. This is the part families most often get wrong, '
          'because it feels sensible to rest the stomach. It is not: a gut that '
          'is fed recovers faster. Keep breastfeeding on demand, keep the '
          'formula at its normal strength, and offer ordinary food, khichdi, '
          'curd rice, dalia, banana, as soon as he will take it. Do not dilute '
          'milk and do not stop it.',
          'Skip the fruit juices and the fizzy drinks. They are sugary enough to '
          'pull water into the gut and make the stools worse. Skip anti-motion '
          'medicines entirely in small children unless a doctor prescribes one, '
          'because stopping the gut is not the same as treating the infection.',
        ]),
        PpCards([
          PpCard('Give after every loose stool',
              'ORS, in small sips, until he refuses. This is the whole '
              'treatment.'),
          PpCard('Zinc, if the doctor advises it',
              'A course of zinc shortens the illness and is standard advice in '
              'India. Ask, do not self dose.'),
          PpCard('Keep the milk going',
              'Breast, formula at normal strength, or cow milk if that is his '
              'usual. Not diluted.'),
          PpCard('Wash hands after every nappy',
              'Tummy bugs travel through the whole household in a day '
              'otherwise.'),
        ], heading: 'Four things that help', hue: 140),
        PpCallout(
          'Go to a doctor if there is blood or mucus in the stool, if he is '
          'vomiting everything and cannot keep ORS down, if there is no urine '
          'for eight hours, if he is drowsy or floppy, if his belly is swollen '
          'and tender, or if he is under six months.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the 3 to 7 day duration, zinc as standard adjunct
        // therapy in India and whether we should state a dose range at all, the
        // "no urine for eight hours" figure, and the "under six months" cutoff.
        PpWhenLine('Most settle within a week. Anything past seven days, or a '
            'child losing weight, needs to be looked at.'),
        PpIndiaNote('Boiled and cooled water, home cooked food, and no street '
            'food or cut fruit while he is ill. In summer and monsoon, tummy '
            'bugs run through neighbourhoods, so if the family is ill too, that '
            'is information worth telling the doctor.'),
        PpLink(
          'How to make and give ORS',
          pageId: 'tummy_ors',
          blurb: 'One packet, one litre, and the mistakes that make it '
              'dangerous.',
        ),
      ],
    ),
    PpPage(
      id: 'tummy_ors',
      title: 'ORS, made right',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('Oral rehydration salts save more children than almost anything '
            'else in medicine, and only when they are mixed correctly. Made too '
            'strong, ORS makes dehydration worse.'),
        PpSteps([
          PpStep('One full packet into one litre of clean water',
              'Not half a packet in half a bottle by eye, and not a spoonful in '
              'a glass. Boiled and cooled water, or bottled.'),
          PpStep('Stir until it is fully dissolved',
              'Taste it yourself. It should be barely salty. If it tastes like '
              'sea water, it is too strong, throw it away and start again.'),
          PpStep('Give small amounts very often',
              'A teaspoon or two every minute or two for a small child, a few '
              'sips every five minutes for an older one. Volume comes from '
              'frequency, not from big glasses.'),
          PpStep('Keep going after every loose stool and every vomit',
              'The rule of thumb is a quarter to half a cup after each loose '
              'stool for a child under two, and up to a full cup for an older '
              'child.'),
          PpStep('Throw away what is left after 24 hours',
              'Make a fresh litre the next day. Keep it covered and cool in '
              'between.'),
        ], heading: 'The five steps'),
        PpCallout(
          'Never add sugar, salt, glucose powder or a flavoured drink to ORS to '
          'make it taste better, and never mix it into milk or juice. The '
          'balance of salt and sugar is the thing that makes it work. If he '
          'refuses the taste, chill it or freeze the made up solution into ice '
          'lollies.',
          kind: PpCalloutKind.safety,
          title: 'Do not improve the recipe',
        ),
        PpArticle([
          'If there is no ORS packet in the house and the chemist is shut, the '
          'home version is six level teaspoons of sugar and half a level '
          'teaspoon of salt in one litre of clean water. It is a stopgap and it '
          'is much easier to get wrong, so buy packets and keep four of them in '
          'the house permanently. They cost very little and they never come to '
          'hand in the middle of the night otherwise.',
          'Bottled sports drinks and packaged nimbu pani are not ORS. They have '
          'far too much sugar and far too little salt, and in a child with loose '
          'motions they make things worse rather than better. Coconut water and '
          'rice kanji with a pinch of salt are decent home fluids alongside ORS, '
          'not instead of it.',
        ], heading: 'If there is no packet'),
        PpCallout(
          'If he vomits the ORS straight back, wait ten minutes and start again '
          'with a teaspoon at a time. If he cannot keep anything down for more '
          'than a few hours, or has passed no urine in eight hours, he needs a '
          'doctor and possibly a drip.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the one packet to one litre ratio, the home recipe
        // of 6 tsp sugar plus half tsp salt per litre, the per-stool volumes
        // (quarter to half a cup under two), and the 24 hour discard rule.
        PpWhenLine('From the first loose stool, at any age, alongside normal '
            'milk and food.'),
        PpIndiaNote('Keep ORS packets in the emergency drawer along with the '
            'thermometer, not in the kitchen where they migrate. In a power cut '
            'or a monsoon night, the chemist is not the plan.'),
        PpVideoSlot(
          title: 'Mixing and giving ORS',
          subtitle: 'The packet, the litre, the spoon, and what to do when he '
              'refuses it.',
          minutes: '4 MIN',
          slotId: 'health/ors_mixing',
        ),
      ],
    ),
    PpPage(
      id: 'tummy_dehydration',
      title: 'Spotting dehydration early',
      format: 'CHART-CARD',
      blocks: [
        PpIntro('This is the one thing to check every few hours in a child with '
            'loose motions or vomiting. It is quicker than a thermometer and it '
            'tells you far more.'),
        PpChartCard(
          title: 'The signs, in order of usefulness',
          // REQUIRED_REVIEW: EVERY LINE. Confirm the urine intervals we quote
          // (6 to 8 hours), the tear and mouth signs, the sunken fontanelle,
          // and the skin pinch description.
          rows: [
            ('Urine', 'Fewer wet nappies, or none in 6 to 8 hours'),
            ('Mouth and tongue', 'Dry and sticky rather than wet'),
            ('Tears', 'Crying without tears'),
            ('The soft spot, under one year', 'Sunken rather than flat'),
            ('Skin', 'Pinched skin on the belly stays up for a moment'),
            ('How he is', 'Quiet, floppy, hard to rouse, or very irritable'),
          ],
          note: 'Wet nappies are the single most useful thing to count. Note a '
              'time, and check whether one has been wet since.',
          hue: 140,
        ),
        PpCallout('Count nappies rather than judging by how he looks. A '
            'dehydrated child can look reasonably alright right up until he '
            'suddenly does not, which is why the count is worth more than an '
            'impression.'),
        PpCallout(
          'No urine in eight hours, a sunken soft spot, a child too drowsy to '
          'drink, sunken eyes, cold hands and feet, or fast breathing, all mean '
          'going to a hospital now rather than trying more ORS at home.',
          kind: PpCalloutKind.doctor,
          title: 'When ORS is no longer enough',
        ),
        PpWhenLine('Check every four to six hours through any tummy bug, and at '
            'least once at night.'),
        PpIndiaNote('In peak summer a child dehydrates faster, and so does an '
            'exclusively breastfed baby in a hot room. Extra breastfeeds are the '
            'correct answer under six months, not water.'),
        PpLink(
          'How to make and give ORS',
          pageId: 'tummy_ors',
          blurb: 'One packet, one litre, small sips.',
        ),
      ],
    ),
    PpPage(
      id: 'tummy_vomiting',
      title: 'Vomiting',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Vomiting frightens parents more than loose motions and is '
            'usually the same illness from the other end. The plan is the same: '
            'small amounts of fluid, very often.'),
        PpArticle([
          'A tummy bug often starts with vomiting for half a day to a day, then '
          'moves to loose motions. During the vomiting phase, big drinks come '
          'straight back, so go small: a teaspoon of ORS every one or two '
          'minutes for an hour is far more effective than a glass every hour, '
          'because a small volume gets absorbed before the stomach objects.',
          'If he vomits, wait ten minutes and start again at a teaspoon. Do not '
          'stop offering. Keep breastfeeding, in shorter and more frequent '
          'feeds. Solid food can wait a few hours if he does not want it, but '
          'fluid cannot.',
          'Spitting up after feeds in a baby under six months is a different '
          'thing entirely and is usually not vomiting at all. A baby who brings '
          'up a mouthful after most feeds, is gaining weight and is otherwise '
          'happy, is a laundry problem rather than a medical one.',
        ]),
        PpCallout(
          'Go to a doctor for: green or bright yellow vomit, blood in the vomit, '
          'vomiting with a swollen hard belly, vomiting after a fall or a knock '
          'to the head, forceful vomiting shooting across the room in a baby '
          'under three months, no urine in eight hours, or vomiting everything '
          'for more than eight hours.',
          kind: PpCalloutKind.doctor,
        ),
        PpCallout(
          'Do not give an anti vomiting medicine on your own, and do not accept '
          'one over a chemist counter. In small children these have real side '
          'effects and they hide the picture. Small sips of ORS instead.',
          kind: PpCalloutKind.safety,
        ),
        // REQUIRED_REVIEW: the teaspoon-every-two-minutes rehydration rate,
        // green or bile stained vomit as a red flag, projectile vomiting under
        // three months as a red flag, and the eight hour limits.
        PpWhenLine('The vomiting phase of a tummy bug is usually over within a '
            'day. Longer than that needs a doctor.'),
        PpIndiaNote('Stop the ghee, the fried food and the heavy milk sweets '
            'while his stomach settles, and come back to normal home food within '
            'a day or two rather than keeping him on plain khichdi for a week.'),
      ],
    ),
    PpPage(
      id: 'tummy_constipation',
      title: 'Constipation, and the days without a poo',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Constipation is about how hard the stool is and how much it '
            'hurts, not about how many days it has been. A baby can go a week '
            'and be perfectly fine.'),
        PpArticle([
          'A fully breastfed baby over six weeks old can genuinely go five to '
          'seven days without a stool, and as long as the stool is soft when it '
          'arrives and he is comfortable and feeding, nothing is wrong. Breast '
          'milk leaves very little waste behind. Straining, going red and '
          'grunting is also normal in small babies, who are learning to push '
          'while lying flat.',
          'Real constipation looks like hard pellet stools, pain, a child who '
          'holds on and refuses to go, or a streak of bright blood from a small '
          'tear. In an older child it usually starts after an illness, a change '
          'of routine, or one painful poo that he then spends a fortnight '
          'avoiding.',
          'What helps: more water through the day, fruit that actually works, '
          'papaya, pear, prune, orange, and less of the things that bind, banana '
          'in large amounts, a great deal of milk, and a lot of refined flour. A '
          'child over one drinking more than about half a litre of milk a day '
          'often improves simply by drinking less of it and eating more.',
        ]),
        PpSteps([
          PpStep('Water first, all day', 'Small amounts often, over one year.'),
          PpStep('Two fruits that move things',
              'Papaya, pear, prune or soaked kishmish water. Every day, not '
              'once.'),
          PpStep('Bicycle legs and a warm tummy rub',
              'Gentle, clockwise, after a bath. Comforting and mildly '
              'effective.'),
          PpStep('A relaxed time on the potty after a meal',
              'Feet supported on a stool, no rush, no watching. A child who has '
              'to hold his own weight cannot push.'),
          PpStep('Ask the doctor before any laxative or suppository',
              'These are sometimes exactly right and they are not a home '
              'decision, especially in babies.'),
        ]),
        PpCallout(
          'Never put a thermometer, a matchstick, soap or a cotton bud into a '
          'child\'s bottom to make him pass stool. It is a common home practice, '
          'it can tear the skin, and a child who learns that passing stool means '
          'being held down will hold on harder.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'See a doctor if a newborn has not passed stool in the first two days '
          'of life, if there is blood beyond a small streak, if there is a '
          'swollen tender belly with vomiting, if he is losing weight, or if the '
          'constipation started in the first weeks of life.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: "up to 5 to 7 days without a stool in a breastfed
        // baby over six weeks", the half litre daily milk figure in a toddler,
        // the newborn 48 hour first stool red flag, and the advice against
        // rectal stimulation.
        PpWhenLine('At any age. Most common at the move to solids, at potty '
            'training, and after any illness.'),
        PpIndiaNote('Janam ghutti and gripe water are commonly given for a hard '
            'tummy and there is no good evidence they help. Water, fruit and '
            'time do, and an unlabelled churan given daily to a baby is a real '
            'risk.'),
      ],
    ),
    PpPage(
      id: 'tummy_colic',
      title: 'Colic and the evening crying',
      format: 'ARTICLE',
      bands: ['hb_nb', 'hb_infant'],
      blocks: [
        PpIntro('Long inconsolable crying in the evening, in a baby who is '
            'otherwise feeding and growing, is one of the hardest ordinary '
            'things in early parenting. It is not your fault and it does end.'),
        PpArticle([
          'Colic is a description rather than a diagnosis: crying for long '
          'stretches, often in the late afternoon and evening, in a healthy '
          'baby. It typically starts around two to three weeks, peaks around six '
          'weeks, and has largely gone by three to four months. Nobody is '
          'certain what causes it. It is not caused by anything the mother ate, '
          'and it is not a sign of a bad feed or a bad parent.',
          'What helps is motion, contact and sound: carrying him upright against '
          'you, a sling, walking, a soft rhythmic shush, a firm hand on the '
          'back. Winding him properly after feeds helps some babies. A warm bath '
          'helps others. Nothing works every night, which is exhausting and is '
          'also normal.',
          'The most important part of this page is the part about you. Crying '
          'that does not stop is built to be unbearable, and it works. If you '
          'feel your patience going, put him down somewhere safe, walk into '
          'another room, and take five minutes. A baby crying in a safe cot is '
          'fine. A shaken baby is not, and it takes only a moment.',
        ]),
        PpCallout(
          'Never shake a baby, however desperate the night has become. Put him '
          'down safely on his back in his cot, step out of the room, breathe, '
          'and go back in when you can. Hand him to someone else if there is '
          'someone else. This is the right thing to do, not a failure.',
          kind: PpCalloutKind.safety,
          title: 'The one rule of a bad night',
        ),
        PpCallout(
          'Crying that is new and sudden in a baby who was settled, a shrill or '
          'weak cry, crying with a fever, with vomiting, with blood in the '
          'stool, with poor feeding or with poor weight gain, is not colic and '
          'needs a doctor today.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the colic timeline (onset 2 to 3 weeks, peak around
        // 6 weeks, resolution by 3 to 4 months) and the statement that maternal
        // diet is not a cause.
        PpWhenLine('Usually from two or three weeks to three or four months. '
            'Rarely beyond that.'),
        PpIndiaNote('Gripe water, janam ghutti and a drop of brandy are all '
            'given for colic and none of them should be. Alcohol in any amount '
            'is dangerous in a baby, and unlabelled ghutti has caused real harm. '
            'Malish, a sling and a walk are the safe versions of the same '
            'instinct.'),
        PpLink(
          'Gentle settling, in more detail',
          surfaceId: 'pp_section/parenting_sleep',
          blurb: 'The Sleep section on evening crying and contact settling.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 5 — A rash appeared
// -----------------------------------------------------------------------------
//  ⚠️ THE IDENTIFIER IS A COMPARISON, NOT A DIAGNOSIS, and the wording works
//  hard to keep it that way. A rash page that says "this is eczema" has
//  diagnosed; a rash page that says "eczema looks like this, HFMD looks like
//  that, here is which one needs a doctor today" has done the useful half
//  without doing the forbidden half.
// =============================================================================

final PpArea _skin = PpArea(
  id: 'skin',
  mark: IntentMark.stepsMark,
  title: 'A rash appeared',
  blurb: 'Which rash looks like what, what to put on it, and the one rash that '
      'means go now.',
  hue: 340,
  pages: [
    PpPage(
      id: 'skin_which_rash',
      title: 'Which rash is this?',
      format: 'COMPARISON TABLE',
      blocks: [
        PpIntro('Most baby rashes are harmless and look alarming. This compares '
            'the common ones so you can tell which page to read next. It cannot '
            'tell you which one your child has.'),
        PpTable(
          heading: 'Side by side',
          columns: ['Rash', 'What it looks like', 'Where', 'Usual answer'],
          rows: [
            [
              'Baby acne',
              'Small red or white pimples, no itch',
              'Cheeks, forehead, nose, first weeks',
              'Nothing. Gone by three months',
            ],
            [
              'Heat rash',
              'Tiny pinpoint red or clear bumps',
              'Neck folds, back, chest, under clothes',
              'Cool him, loose cotton, less oil',
            ],
            [
              'Eczema',
              'Dry rough itchy patches, sometimes weeping',
              'Cheeks first, then elbow and knee creases',
              'Heavy moisturiser, and a doctor for a flare',
            ],
            [
              'Cradle cap',
              'Greasy yellow scales on the scalp',
              'Scalp and eyebrows, first months',
              'Oil, soften, comb gently. Harmless',
            ],
            [
              'Nappy rash',
              'Red sore skin, sometimes shiny',
              'Only where the nappy touches',
              'Air, barrier cream, frequent changes',
            ],
            [
              'HFMD',
              'Small blisters, with mouth ulcers and fever',
              'Hands, feet, around the mouth, bottom',
              'Fluids and pain relief, and it passes',
            ],
            [
              'Chickenpox',
              'Itchy spots that blister then crust, in crops',
              'Trunk first, then everywhere',
              'Comfort, and keep him away from newborns',
            ],
            [
              'Hives',
              'Raised itchy welts that move about and fade',
              'Anywhere, changing hour to hour',
              'Usually settles. Breathing trouble is urgent',
            ],
          ],
        ),
        PpCallout(
          'One rash cannot wait. Small flat red or purple spots that do NOT fade '
          'when you press the side of a clear glass firmly onto them, especially '
          'with a fever, a stiff neck or a very drowsy child, mean going to a '
          'hospital immediately. Do the glass test on any new rash with a fever.',
          kind: PpCalloutKind.doctor,
          title: 'The glass test',
        ),
        // REQUIRED_REVIEW: the glass test description and the non-blanching
        // rash red flag, plus each row of the comparison table.
        PpCallout('Take a clear photo in daylight when you first see a rash. '
            'Rashes change fast, and the photo is often what lets a doctor '
            'answer without a visit.'),
        PpWhenLine('Any age. Newborn rashes are almost all harmless; a new rash '
            'with a fever in any child is the one to look at properly.'),
        PpIndiaNote('Heat rash is by far the most common summer rash in India '
            'and it is very often made worse by a daily oil malish in a hot '
            'room. Malish in the cool of the morning, and lighter oil, usually '
            'fixes it in two days.'),
        PpVideoSlot(
          title: 'Telling the common baby rashes apart',
          subtitle: 'Eczema, heat rash, HFMD, nappy rash and cradle cap, shown '
              'on real skin, and the glass test demonstrated.',
          minutes: '7 MIN',
          slotId: 'health/rash_identify',
        ),
      ],
    ),
    PpPage(
      id: 'skin_hfmd',
      title: 'Hand, foot and mouth disease',
      format: 'ARTICLE',
      blocks: [
        PpIntro('HFMD sweeps through creches and playgroups every year. It looks '
            'much worse than it is, and the hard part is not the rash, it is '
            'getting fluid into a child with a sore mouth.'),
        PpArticle([
          'It starts with a fever and a child who is off his food, then small '
          'blisters appear on the palms, the soles, around the mouth and often '
          'on the bottom, along with ulcers inside the mouth. The mouth ulcers '
          'are the painful part and they are the reason he stops drinking. It is '
          'caused by a virus, so there is no medicine that treats it and no '
          'antibiotic that helps.',
          'It runs about seven to ten days. The fever goes first, the blisters '
          'dry over the following week, and some children lose a fingernail or '
          'toenail a month or two later, which grows back and needs nothing. He '
          'is most infectious in the first week, and it spreads through saliva, '
          'through the blister fluid and through stool, which is why handwashing '
          'after nappies matters as much as anything.',
          'Treatment is comfort. Cold things go down best: chilled milk, curd, '
          'ice cream, cold coconut water, kulfi. Avoid salty, spicy, citrus and '
          'anything crunchy while the mouth hurts. Paracetamol for pain, in the '
          'ranges your doctor has confirmed, makes the difference between a '
          'child who drinks and one who does not.',
        ]),
        PpCards([
          PpCard('Cold and soft, for three days',
              'Curd, kheer, ice cream, cold milk, mashed banana. Calories can '
              'wait, fluid cannot.'),
          PpCard('Nothing citrus, salty or crunchy',
              'Orange juice on a mouth ulcer is the reason he refuses the next '
              'thing you offer too.'),
          PpCard('A soft cloth instead of a brush',
              'Wipe the teeth gently for a few days rather than brushing.'),
          PpCard('Keep him home while he has fever and fresh blisters',
              'Usually about a week. Tell the creche, because they will want to '
              'warn other families.'),
        ], heading: 'Getting through the week', hue: 340),
        PpCallout(
          'See a doctor if he has passed no urine in eight hours, will not drink '
          'anything at all, is very drowsy, has a fever past five days, or has '
          'blisters that turn into large red swollen areas. Dehydration from a '
          'sore mouth is the only common complication and it is preventable.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the 7 to 10 day course, the infectious period, nail
        // shedding weeks later, the "no urine in eight hours" trigger, and the
        // advice on returning to creche.
        PpWhenLine('Most common between six months and five years. Adults catch '
            'it occasionally and get it mildly.'),
        PpIndiaNote('It runs in waves through Indian creches in the monsoon and '
            'again after it. A child can catch it more than once, because '
            'several different viruses cause it, so a second bout is not a sign '
            'that anything is wrong with his immunity.'),
        PpLink(
          'Compare soothing creams and lotions',
          surfaceId: 'pp_compare',
          blurb: 'What is worth putting on drying blisters, and what is not.',
        ),
      ],
    ),
    PpPage(
      id: 'skin_nappy_rash',
      title: 'Nappy rash',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost every baby gets it at some point. It is usually a wet '
            'skin problem rather than an infection, and it usually clears in two '
            'or three days once the skin gets air.'),
        PpArticle([
          'The cause is simple: skin that stays wet, plus the ammonia in urine '
          'and the enzymes in stool, plus rubbing. So the treatment is simple '
          'too: change more often, clean gently with water rather than scrubbing '
          'with a wipe, dry properly, and put a thick barrier layer between the '
          'skin and the nappy at every change.',
          'Nappy free time is the single most effective thing. Twenty minutes '
          'twice a day on a towel or a waterproof mat, no nappy, does more than '
          'any cream. It is inconvenient and it works.',
          'If the rash is bright red with a clear edge, with small spots '
          'scattered outside the main patch, and it is not settling with a '
          'barrier cream, it may be a thrush rash rather than a plain one and it '
          'needs a different cream from a doctor. That is worth knowing, because '
          'families often escalate the barrier cream when the problem has '
          'changed.',
        ]),
        PpSteps([
          PpStep('Change as soon as it is soiled',
              'Especially after a stool. This is most of the treatment.'),
          PpStep('Clean with water and cotton, not a scented wipe',
              'Wipes on already sore skin sting and delay healing.'),
          PpStep('Pat dry, and let the air do the rest',
              'Do not rub. Wait until the skin is properly dry before the '
              'cream.'),
          PpStep('A thick barrier layer every change',
              'Zinc oxide based. It should look like icing, not like a rubbed in '
              'moisturiser.'),
          PpStep('Nappy free time, twice a day',
              'Twenty minutes on a towel. The best thing on this list.'),
        ]),
        PpCallout(
          'Do not use talcum powder in the nappy area. Powder cakes in the folds '
          'when it gets wet and makes the rubbing worse, and fine powder near a '
          'baby face is not good for his lungs. Use a barrier cream instead.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'See a doctor if the rash is not improving after three days of proper '
          'care, if there are blisters, open sores, yellow crusts or pus, if it '
          'spreads beyond the nappy area, or if he has a fever with it.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the three day improvement window, the description of
        // a candidal nappy rash, and the advice against talcum powder.
        PpWhenLine('Any age in nappies. Most common around six to twelve months, '
            'during teething, and during any illness with loose stools.'),
        PpIndiaNote('In summer, cloth nappies and langots are cooler but need '
            'changing sooner, because cotton holds the wet against the skin. If '
            'you use cloth, change at the first sign of damp and skip the '
            'plastic cover during the day.'),
        PpLink(
          'Compare nappy rash creams',
          surfaceId: 'pp_compare',
          blurb: 'Which are true barriers, which are medicated, and which are '
              'just moisturiser.',
        ),
      ],
    ),
    PpPage(
      id: 'skin_eczema',
      title: 'Eczema and dry rough patches',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Dry, rough, itchy skin that comes and goes is one of the '
            'commonest things in small children. It is managed rather than '
            'cured, and the management is mostly moisturiser.'),
        PpArticle([
          'Eczema is a skin barrier that leaks water and lets irritants in. It '
          'usually shows first on the cheeks in a baby, then moves to the folds '
          'of the elbows and knees as he grows. It is itchy, and the scratching '
          'is what turns a dry patch into a weeping one, so most of the work is '
          'keeping the skin comfortable enough not to be scratched.',
          'The routine that works is dull and relentless: a short lukewarm bath, '
          'a gentle non soap cleanser, pat dry, and a thick moisturiser within '
          'three minutes while the skin is still damp, twice a day and more in '
          'winter. Thick means an ointment or a heavy cream rather than a '
          'lotion. Use a great deal more than feels reasonable.',
          'When a patch flares up, red and angry, a doctor will often prescribe '
          'a short course of a mild steroid cream. Families are frightened of '
          'these and then use too little for too long, which is exactly the '
          'wrong way round. Used as prescribed, for a few days on a flare, they '
          'are safe and they end the flare quickly.',
        ]),
        PpCards([
          PpCard('Moisturise twice a day, always',
              'Even on good days. The daily routine is what prevents flares, not '
              'the cream you reach for during one.'),
          PpCard('Short lukewarm baths, not hot',
              'Hot water strips the skin. Five to ten minutes is plenty.'),
          PpCard('Cotton, and no wool against the skin',
              'And wash new clothes before the first wear.'),
          PpCard('Keep his nails short',
              'Scratching does more damage than the eczema does. Cotton mittens '
              'at night help small babies.'),
          PpCard('Find the trigger, gently',
              'Heat, sweat, soap, dust, a new detergent. Food is a much rarer '
              'trigger than families assume.'),
        ], heading: 'The routine', hue: 340),
        PpCallout(
          'See a doctor if the skin is weeping, crusted yellow, blistered or '
          'suddenly painful, which can mean an infection, if a flare is not '
          'settling with your usual care, or if the itching is keeping him awake '
          'at night. Eczema that costs sleep is under treated, not incurable.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the "moisturise within three minutes of a bath"
        // instruction, the guidance on topical steroids, and the statement that
        // food triggers are less common than assumed.
        PpWhenLine('Often starts between two and six months. Many children grow '
            'out of it by school age.'),
        PpIndiaNote('Mustard oil and heavy malish oils irritate eczema in a lot '
            'of babies, and so does turmeric paste on broken skin. Use a plain '
            'thick moisturiser on the affected patches and keep the malish for '
            'the rest of him.'),
        PpLink(
          'Compare moisturisers and barrier creams',
          surfaceId: 'pp_compare',
          blurb: 'Ointment, cream or lotion, and what actually stays on.',
        ),
      ],
    ),
    PpPage(
      id: 'skin_heat_rash',
      title: 'Prickly heat, and Indian summers',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Tiny bumps in the neck folds, across the back and under the '
            'clothes, in a baby who is hot. The most common rash in the country '
            'and the easiest to fix.'),
        PpArticle([
          'Heat rash happens when sweat cannot escape, so the sweat ducts block '
          'and small bumps appear where the skin is covered or folded: the neck, '
          'the upper back, the chest, under the arms, around the nappy waistband '
          'and under the chin where he dribbles.',
          'It clears in a day or two if he simply gets cooler: loose cotton and '
          'nothing under it, a cooler or a fan, a lukewarm bath twice a day, '
          'drying the folds properly afterwards, and skipping the oil malish '
          'until it settles. It does not need a medicated cream, and thick '
          'creams often make it last longer by blocking the skin further.',
        ]),
        PpSteps([
          PpStep('Cool him first', 'A fan, a cooler, or a lukewarm bath.'),
          PpStep('One loose cotton layer, nothing synthetic',
              'And no vest under the kurta in May.'),
          PpStep('Dry the folds properly',
              'Neck, groin, behind the knees. This is where it starts.'),
          PpStep('Pause the oil malish for two days',
              'Or move it to early morning and use much less.'),
          PpStep('Skip the powder',
              'Talc cakes in a sweaty fold and blocks the ducts further.'),
        ]),
        PpCallout('If it is not settling in two or three days of keeping him '
            'cool, it is probably not heat rash. The rash comparison page is the '
            'next stop.'),
        PpCallout(
          'A doctor should look if the bumps become pus filled, if the skin '
          'around them is red, hot and spreading, or if he has a fever with it. '
          'Scratched heat rash does sometimes become infected.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the two to three day resolution window and the
        // advice to pause oil massage.
        PpWhenLine('From the first summer onwards, and in humid coastal weather '
            'all year.'),
        PpIndiaNote('A daily oil malish in a hot unairconditioned room is the '
            'single most common cause of heat rash in Indian babies. Malish is '
            'good for him; malish at 2pm in June is not. Move it to early '
            'morning and use a lighter oil in summer.'),
      ],
    ),
    PpPage(
      id: 'skin_newborn',
      title: 'Cradle cap, baby acne and peeling skin',
      format: 'CARDS',
      bands: ['hb_nb'],
      blocks: [
        PpIntro('Newborn skin does a series of strange things in the first '
            'weeks, and almost all of them need nothing at all. Here are the '
            'ones that fill up a paediatrician\'s morning.'),
        PpCards([
          PpCard('Peeling skin in the first two weeks',
              'Especially on the hands and feet, and more in a baby born a '
              'little late. It needs no cream and it stops on its own.'),
          PpCard('Baby acne on the cheeks',
              'Small red or white pimples at two to four weeks, from your '
              'hormones still in his system. Do not squeeze, do not apply '
              'anything. Gone by three months.'),
          PpCard('Cradle cap on the scalp',
              'Greasy yellow scales. Soften with a little coconut oil for an '
              'hour, comb gently with a soft brush during the bath, wash out. '
              'Never pick it off dry.'),
          PpCard('Milia, tiny white spots on the nose',
              'Blocked pores. They vanish in a few weeks by themselves.'),
          PpCard('Mongolian spots, blue grey patches',
              'Usually on the back or the bottom, present from birth, entirely '
              'harmless, and they fade over the early years.'),
          PpCard('Erythema toxicum, blotchy red patches with a pale centre',
              'Alarming in week one, common, and gone within days. The name is '
              'much worse than the rash.'),
        ], heading: 'Six that need nothing', hue: 340),
        PpCallout(
          'A doctor should see: any blisters or pus filled spots in a newborn, a '
          'rash with a fever at this age, yellowing of the skin or the whites of '
          'the eyes, or a rash that does not fade under a pressed glass. In a '
          'baby under three months, a rash with a fever is a same day visit.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: every timeline in the cards, and the newborn rash
        // red flags, especially blistering or pustular rashes in a newborn.
        PpWhenLine('Birth to about three months. After that these mostly stop '
            'appearing.'),
        PpIndiaNote('Do not apply besan, malai, haldi paste or kajal to newborn '
            'skin or eyes. Kajal in particular has repeatedly been found to '
            'contain lead, and a newborn absorbs it. Plain oil for the malish '
            'and nothing on the face.'),
        PpLink(
          'Newborn jaundice, and the yellow that matters',
          pageId: 'ill_jaundice',
          blurb: 'When yellow skin is ordinary and when it is not.',
        ),
      ],
    ),
    PpPage(
      id: 'skin_chickenpox',
      title: 'Chickenpox',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Itchy spots arriving in crops over a few days, with a fever at '
            'the start. Most children get through it uncomfortably and '
            'completely, and there is a vaccine that prevents it.'),
        PpArticle([
          'It begins with a fever and a child who feels rotten a day before any '
          'spot appears. Then flat red spots come, turn into small blisters, and '
          'crust over, in waves, so at any moment he will have all three stages '
          'on him at once. That mixture is the thing that distinguishes '
          'chickenpox from most other rashes.',
          'He is infectious from a day or two before the rash until every '
          'blister has crusted, usually about five to seven days. Keep him away '
          'from newborn babies, from anyone pregnant who has not had chickenpox, '
          'and from anyone on chemotherapy or steroids, because in those three '
          'groups it is genuinely dangerous.',
          'Treatment is comfort: calamine on the itch, cool lukewarm baths, '
          'short nails, cotton clothes, and paracetamol for the fever in the '
          'range your doctor confirms. An antiviral is sometimes given to older '
          'children or in a severe case, and that is a doctor\'s decision '
          'rather than a request.',
        ]),
        PpCallout(
          'Never give ibuprofen or any similar painkiller in chickenpox unless a '
          'doctor has specifically told you to. It has been linked with serious '
          'skin infections in this illness. Paracetamol is the one to use, and '
          'never aspirin at all.',
          kind: PpCalloutKind.safety,
          title: 'Paracetamol only',
        ),
        PpCallout(
          'See a doctor if a spot becomes large, red, hot and swollen, if he has '
          'a high fever after day four, if he is very drowsy, unsteady on his '
          'feet or has a stiff neck, if he is breathing fast, or if he is a '
          'baby under a month old. Also call if anyone in the house is pregnant '
          'and has never had chickenpox.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the infectious period, the five to seven day
        // crusting window, the NSAID and aspirin avoidance, and the list of
        // high risk contacts.
        PpWhenLine('Most common between two and eight years. The varicella '
            'vaccine is on the IAP schedule and prevents most cases.'),
        PpIndiaNote('Chickenpox peaks in the Indian spring and early summer, and '
            'traditional practice keeps a child indoors with neem leaves. The '
            'neem is harmless and comforting. Do not put haldi or besan on open '
            'blisters, which invites infection, and do not skip the vaccine on '
            'the grounds that everyone gets it anyway.'),
        PpLink(
          'Is the chickenpox vaccine on his list?',
          surfaceId: 'pp_vaccines',
          blurb: 'Varicella sits on the IAP schedule. Check where he is.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 6 — The other things that go around
// =============================================================================

final PpArea _otherIllness = PpArea(
  id: 'other_illness',
  mark: IntentMark.compassMark,
  title: 'The other things that go around',
  blurb: 'Teething, ear pain, sticky eyes, newborn jaundice and allergies.',
  hue: 268,
  pages: [
    PpPage(
      id: 'ill_teething',
      title: 'Teething',
      format: 'ARTICLE',
      bands: ['hb_infant', 'hb_toddler'],
      blocks: [
        PpIntro('Teething is blamed for a great deal it does not cause, and that '
            'is the real risk of it: a genuine illness gets waved away as teeth '
            'for three days.'),
        PpArticle([
          'A first tooth usually arrives somewhere between four and ten months, '
          'and the whole set is in by about two and a half to three years. Late '
          'teeth are common and almost never a problem. Around a tooth coming '
          'through you can expect drooling, chewing on everything, a swollen '
          'sore gum, some crankiness and a few disturbed nights.',
          'Teething does not cause a high fever, loose motions, vomiting, a '
          'cough, a rash on the body, or a child who is genuinely ill. It is '
          'true that babies get more infections at exactly the age they are '
          'teething, which is why the two look connected. If he has a '
          'temperature above 38 C, treat it as a fever and read the fever pages, '
          'not this one.',
          'What helps is pressure and cold: a chilled teething ring from the '
          'fridge, a clean cold spoon, a firm rubber toy, or a clean finger '
          'rubbed on the gum. For an older baby, cold cucumber sticks or chilled '
          'curd. Extra cuddles do more than anything sold for the purpose.',
        ]),
        PpCallout(
          'Do not use a teething gel containing an anaesthetic, and do not use '
          'a homeopathic teething powder or tablet of unknown ingredients. '
          'Several have been withdrawn after harming babies. Cold, pressure and '
          'a chewy toy are the safe versions.',
          kind: PpCalloutKind.safety,
          title: 'What not to put on the gum',
        ),
        PpCallout(
          'Anything more than a mildly warm forehead, a child who is off his '
          'feeds, loose motions or a rash is an illness rather than teeth, and '
          'gets looked at as one. Call your doctor rather than waiting for the '
          'tooth.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the 4 to 10 month first tooth window, the statement
        // that teething does not cause fever above 38 C or diarrhoea, and the
        // warning on anaesthetic teething gels.
        PpWhenLine('First tooth usually between four and ten months. Start '
            'brushing with a soft brush and a smear of fluoride paste as soon as '
            'one appears.'),
        PpIndiaNote('Amber teething necklaces and any thread or chain around a '
            'baby neck are a strangulation and choking risk, whatever they are '
            'said to do. A chilled teether does the same job with no risk.'),
        PpLink(
          'Teething nuskhe, marked',
          surfaceId: 'pp_nuskhe',
          blurb: 'Three teething remedies, marked safe, comfort only or unsafe.',
        ),
      ],
    ),
    PpPage(
      id: 'ill_ear',
      title: 'Ear pain and ear infections',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Ear pain is the classic 2am problem: it wakes a child who was '
            'fine, it hurts a great deal, and it usually appears a few days '
            'into a cold.'),
        PpArticle([
          'A young child\'s ear tube is short and almost flat, so fluid from a '
          'cold sits behind the eardrum easily and gets infected. That is why '
          'ear infections cluster in the first three years and then become '
          'rarer. A baby cannot tell you, so watch for pulling or batting at one '
          'ear, crying that is much worse lying flat, refusing to feed on one '
          'side, or a fever three days into a cold.',
          'The immediate thing to do is pain relief, in the dose your doctor has '
          'confirmed, and holding him upright. Warmth on the ear helps some '
          'children. Then get him seen, because someone has to look inside the '
          'ear to know what is going on, and no app can do that.',
          'Not every ear infection needs an antibiotic. Many settle by '
          'themselves in two or three days, and a good paediatrician will often '
          'give pain relief and review, or give a prescription to fill only if '
          'he is no better in 48 hours. That is careful medicine rather than '
          'neglect, and it is worth knowing before you push for a prescription.',
        ]),
        PpCallout(
          'Never put oil, garlic, warm water, breast milk or ear drops of any '
          'kind into a painful ear before it has been examined. If the eardrum '
          'has burst, anything poured in goes deeper than you can see. Give pain '
          'relief by mouth instead and keep the outside dry.',
          kind: PpCalloutKind.safety,
        ),
        PpCallout(
          'See a doctor the same day for ear pain with a fever, any discharge '
          'from the ear, pain that wakes him repeatedly, swelling or redness of '
          'the bone behind the ear, or an ear problem in a baby under six '
          'months. Repeated infections, or hearing that seems dulled after one, '
          'should be checked properly.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the watchful waiting approach to antibiotics and the
        // 48 hour review window, the "under six months" cutoff, and mastoid
        // swelling as an urgent sign.
        PpWhenLine('Commonest between six months and three years, usually a few '
            'days into a cold.'),
        PpIndiaNote('Ear drops are sold freely over the counter here and are '
            'frequently given before anyone has looked in the ear. Ask the '
            'doctor to look first. Also keep bath and pool water out of an ear '
            'that has been discharging.'),
      ],
    ),
    PpPage(
      id: 'ill_eyes',
      title: 'Sticky eyes and eye discharge',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Crusty lashes in the morning are common and usually minor. The '
            'thing that decides how serious it is, is whether the white of the '
            'eye is red and whether there is swelling around it.'),
        PpArticle([
          'In a baby under a year, a persistently watery eye with a little '
          'yellow crust and a white, calm eyeball is very often a blocked tear '
          'duct. It clears on its own in most babies before their first '
          'birthday. Wipe from the inner corner outwards with clean cotton and '
          'cooled boiled water, a fresh piece for each wipe, and a gentle massage '
          'along the side of the nose helps.',
          'If the white of the eye is red and there is discharge, that is '
          'conjunctivitis, usually viral and usually with a cold. It spreads '
          'very easily, so separate towels and handwashing matter more than any '
          'drop. Most cases settle in a week without antibiotic drops, which are '
          'given far more often than they are needed.',
        ]),
        PpCallout(
          'See a doctor for: a swollen, red or painful eyelid or the skin around '
          'the eye, an eye he cannot open, a child who shies away from light, '
          'any change in vision, an eye injury, thick discharge in a newborn in '
          'the first month, or discharge that is not settling in a week.',
          kind: PpCalloutKind.doctor,
          title: 'When an eye is more than sticky',
        ),
        PpCallout(
          'Do not use anyone else\'s eye drops, and do not use a steroid eye '
          'drop bought over a counter. Steroid drops in the wrong eye condition '
          'can damage sight. Clean with cooled boiled water and get it looked '
          'at.',
          kind: PpCalloutKind.safety,
        ),
        // REQUIRED_REVIEW: blocked tear duct resolving by 12 months, the
        // newborn first month discharge red flag, and the statement that most
        // conjunctivitis needs no antibiotic drop.
        PpWhenLine('Blocked tear ducts appear in the first weeks and usually '
            'clear by one year. Conjunctivitis runs about a week.'),
        PpIndiaNote('Do not put kajal, surma, rose water, breast milk or honey '
            'into a child\'s eye. Kajal has repeatedly been found to contain '
            'lead and is applied to babies daily in many homes. Cooled boiled '
            'water on clean cotton is all an eye needs.'),
      ],
    ),
    PpPage(
      id: 'ill_jaundice',
      title: 'Newborn jaundice',
      format: 'ARTICLE',
      bands: ['hb_nb'],
      blocks: [
        PpIntro('Most newborns go a little yellow in the first week and it '
            'passes. A few need treatment, and the difference is mostly about '
            'timing and how far down the body the yellow reaches.'),
        PpArticle([
          'Ordinary newborn jaundice appears around day two or three, peaks '
          'around day four or five, and fades over the following week. It '
          'happens because a newborn liver is still learning to clear bilirubin, '
          'a normal breakdown product. It usually starts at the face and moves '
          'down the body as it rises, so yellow that has reached the chest, the '
          'belly, the legs or the palms and soles is worth a same day check.',
          'Check him in daylight rather than under a tube light, which makes '
          'everything look yellow. Press a finger gently on the tip of his nose '
          'or his forehead for a second and look at the skin as you lift it. '
          'Look at the whites of his eyes and the inside of his mouth too.',
          'Feeding is the treatment for the ordinary kind: frequent feeds move '
          'bilirubin out through the stool. A sleepy, poorly feeding jaundiced '
          'baby is the pattern that worries doctors, because the two feed each '
          'other. Phototherapy, the blue light, is safe, common and effective, '
          'and needing it is not a failure of anything.',
        ]),
        PpCallout(
          'Go the same day if: the yellow appears in the first 24 hours of life, '
          'it reaches the legs, palms or soles, it is still there after two '
          'weeks, he is very sleepy or feeding poorly, he has few wet nappies, '
          'his stools are pale or chalky white, or his urine is dark. Jaundice '
          'in the first day and jaundice past two weeks are the two that always '
          'get a doctor.',
          kind: PpCalloutKind.doctor,
          title: 'The yellow that needs a doctor',
        ),
        PpCallout(
          'Do not treat jaundice by putting a baby in direct sunlight. It is a '
          'common home practice, it does not work at the intensities involved, '
          'and it risks sunburn and overheating in an Indian summer. Feed him '
          'frequently and get him weighed and checked instead.',
          kind: PpCalloutKind.safety,
          title: 'Sunlight is not phototherapy',
        ),
        // REQUIRED_REVIEW: the whole jaundice timeline (onset day 2 to 3, peak
        // day 4 to 5), the cephalocaudal progression, jaundice in the first 24
        // hours and beyond 14 days as red flags, pale stools as a red flag, and
        // the statement about sunlight.
        PpWhenLine('Watch through the first two weeks, and check once a day in '
            'daylight during the first week.'),
        PpIndiaNote('Jaundice is often called peela and treated at home with '
            'sunlight, with certain leaves, or by stopping breastfeeding. '
            'Stopping breastfeeding makes it worse, because feeding is what '
            'clears it. Keep feeding, and get the level checked if the yellow is '
            'spreading.'),
      ],
    ),
    PpPage(
      id: 'ill_allergies',
      title: 'Allergies, and what an allergy is not',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost everything a child reacts to is not an allergy. Knowing '
            'the difference matters, because families cut out foods for years '
            'on the strength of one bad afternoon.'),
        PpArticle([
          'A true food allergy shows up fast, usually within minutes to two '
          'hours of eating: hives, swelling of the lips or eyes, vomiting, '
          'sudden loose motions, a cough or a wheeze. It happens every time that '
          'food is eaten, not sometimes. The common culprits are milk, egg, '
          'peanut and tree nuts, wheat, soya, fish and shellfish.',
          'What is usually not an allergy: a rash around the mouth from a acidic '
          'food like tomato or citrus, which is irritation; loose stools after a '
          'lot of juice; a cold that comes with the change of season; and a '
          'child who dislikes a food. Lactose intolerance is also not a milk '
          'allergy, it is a different mechanism and it does not need adrenaline.',
          'Delaying allergenic foods does not prevent allergy. The evidence '
          'moved the other way some years ago: introducing egg and peanut in '
          'suitable forms in the first year, once solids have started, reduces '
          'the chance of an allergy rather than raising it. Peanut goes in as '
          'thinned peanut butter or peanut powder, never whole nuts, which are a '
          'choking risk under five.',
        ]),
        PpCallout(
          'Swelling of the lips, tongue or face, difficulty breathing, a hoarse '
          'voice, repeated vomiting with a rash, or a child who goes pale and '
          'floppy after eating, is a medical emergency. Go to a hospital '
          'immediately and say what he ate. Do not wait to see whether it '
          'settles.',
          kind: PpCalloutKind.doctor,
          title: 'The reaction that cannot wait',
        ),
        PpCallout(
          'Do not remove a major food from a small child\'s diet on suspicion '
          'alone. Milk, wheat and egg carry a lot of what he needs, and a long '
          'exclusion has its own cost. Write down what he ate, what happened and '
          'how fast, and take that list to be assessed properly.',
          kind: PpCalloutKind.safety,
        ),
        // REQUIRED_REVIEW: the minutes to two hours reaction window, the early
        // introduction guidance for egg and peanut, the whole nut choking age
        // limit, and the anaphylaxis sign list.
        PpWhenLine('Most food allergies appear in the first two years, at or '
            'soon after the food is first eaten.'),
        PpIndiaNote('Allergy testing is sold widely here as a panel of dozens of '
            'foods, and a positive line on such a panel does not mean an allergy '
            'in a child who eats that food happily. Test on the basis of a '
            'story, not instead of one.'),
        PpConsult(
          title: 'Talk to a paediatrician about a suspected allergy',
          whoFor: 'For the family that has already cut out three foods and is '
              'not sure any of it was necessary, and wants somebody to look at '
              'the actual history before more disappears from his plate.',
          surfaceId: 'pp_experts',
          role: 'pediatrician',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 7 — Not sure what is wrong?
// -----------------------------------------------------------------------------
//  ⚠️ THIS AREA BUILDS NOTHING. Both pages are doors onto features that already
//  exist and are already good: What Changed (29 concerns) and ProblemSolver.
//  The spec asks for one thing that did not exist, which is the HANDOFF between
//  them and onward to the consult, and that is what these two pages carry.
// =============================================================================

final PpArea _notSure = PpArea(
  id: 'not_sure',
  mark: IntentMark.lampMark,
  title: 'Not sure what is wrong?',
  blurb: 'Start from what changed, or from the worry you cannot name.',
  hue: 250,
  pages: [
    PpPage(
      id: 'ns_what_changed',
      title: 'Something suddenly different?',
      format: 'FLOW',
      blocks: [
        PpIntro('When you can point at what changed but not at what it means, '
            'start here. It walks you through the likely reasons and leaves you '
            'somewhere useful.'),
        PpCards([
          PpCard('Illness',
              'A warm or low grade fever, a runny nose and congestion, tugging '
              'at his ears.'),
          PpCard('Skin',
              'A new rash appeared, dry rough patches, a sore red nappy area.'),
          PpCard('Tummy',
              'Has not pooped in a few days, runnier and more frequent poops, '
              'gassy and pulling his legs up.'),
          PpCard('Everything else',
              'Sleep, feeding, mood and behaviour changes all live in the same '
              'walkthrough, twenty nine of them in total.'),
        ], heading: 'The health ones you will find in there', hue: 250),
        PpSteps([
          PpStep('Pick what changed', 'From the list, in plain words.'),
          PpStep('Read the likely reasons',
              'Usually two or three, most likely first, with what to do about '
              'each.'),
          PpStep('Follow the link into the full page',
              'A low fever leads to the fever check, a new rash leads to the '
              'rash comparison, loose poops lead to ORS.'),
          PpStep('If it does not fit, hand over',
              'The next page finds the right kind of doctor, or a '
              'paediatrician will talk to you tonight.'),
        ], heading: 'How it goes'),
        PpCallout('A guided starting point, not a diagnosis. If something '
            'worries you, always check with a doctor.'),
        PpWhenLine('Any age, any time. Best when something changed in the last '
            'day or two.'),
        PpLink(
          'Open Something suddenly different',
          surfaceId: 'pp_what_changed',
          blurb: 'Twenty nine things that change, and what each usually means.',
        ),
        PpLink(
          'Or run the fever check first',
          surfaceId: 'pp_fever_check',
          blurb: 'If a temperature is the thing that changed.',
        ),
      ],
    ),
    PpPage(
      id: 'ns_problem_solver',
      title: 'Something is off and you cannot name it',
      format: 'FLOW',
      blocks: [
        PpIntro('Off his feeds, not himself, crying more, sleeping oddly, and no '
            'single symptom to point at. That instinct is worth taking '
            'seriously, and it is a hard thing to search for.'),
        PpArticle([
          'This walkthrough asks a short series of questions rather than making '
          'you pick a symptom you are not sure of, and it ends somewhere '
          'specific: what is likely going on, what to do about it now, and which '
          'kind of professional to see. In India that last part is often the '
          'real problem. Paediatrician, ENT, dermatologist, dentist, '
          'occupational therapist, lactation consultant: knowing which door to '
          'knock on saves a fortnight.',
          'If what you describe crosses into something urgent, it says so and '
          'stops asking questions. That is the point of a triage flow rather '
          'than a search box.',
        ]),
        PpCallout('A parent who is worried without being able to say why is a '
            'signal doctors are trained to take seriously. You do not need to '
            'have identified a symptom to be allowed to ask.'),
        PpCallout(
          'If he is drowsy and hard to rouse, breathing hard, not passing urine, '
          'or you simply feel that something is badly wrong, do not work through '
          'a flow. Go to a hospital.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Any age. Use it when the worry has lasted more than a day '
            'and has not resolved itself.'),
        PpLink(
          'Work out which help you need',
          surfaceId: 'pp_find_help',
          blurb: 'A few questions, then the likely cause and the right kind of '
              'expert.',
        ),
        PpConsult(
          title: 'Speak to a paediatrician tonight',
          whoFor: 'For the evening when he is not right, it is not an emergency, '
              'and morning feels a long way off. A real paediatrician on a call '
              'who can tell you whether this waits.',
          surfaceId: 'pp_experts',
          role: 'pediatrician',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 8 — Is he up to date on his shots?
// -----------------------------------------------------------------------------
//  The tracker itself is LIVE (VaxTrackerScreen + VaxStore, twelve vaccines and
//  ten visits) and is linked, never rebuilt. What did not exist is the reading
//  around it: what each shot is for, what is normal afterwards, catching up, and
//  the cost question, which the spec's search data shows is asked constantly and
//  answered almost nowhere.
// =============================================================================

final PpArea _vaccines = PpArea(
  id: 'vaccines',
  mark: IntentMark.checkMark,
  title: 'Is he up to date on his shots?',
  blurb: 'The IAP schedule, what each one is for, what happens after, and what '
      'it costs.',
  hue: 180,
  pages: [
    PpPage(
      id: 'vax_schedule',
      title: 'What is due, and when',
      format: 'CHART',
      blocks: [
        PpIntro('The Indian schedule, not a Western one. The visits are more '
            'frequent in the first year than parents expect, and most of them '
            'bundle several vaccines into one appointment.'),
        PpChartCard(
          title: 'The visits, roughly',
          subtitle: 'Indian Academy of Pediatrics schedule',
          // REQUIRED_REVIEW: THE ENTIRE SCHEDULE. It must be checked against
          // the current IAP immunisation timetable, not against memory, because
          // the schedule is revised and a stale row here is a missed dose. The
          // app's own VaxStore holds the authoritative per dose list; this card
          // is a reading overview and the two must not drift.
          rows: [
            ('At birth', 'BCG, Hepatitis B first dose, OPV zero dose'),
            ('6 weeks', 'Pentavalent 1, IPV 1, PCV 1, Rotavirus 1'),
            ('10 weeks', 'Pentavalent 2, IPV 2, PCV 2, Rotavirus 2'),
            ('14 weeks', 'Pentavalent 3, IPV 3, PCV 3, Rotavirus 3'),
            ('6 months', 'Influenza, first of two'),
            ('9 months', 'MMR first dose, Typhoid conjugate'),
            ('12 months', 'Hepatitis A first dose'),
            ('15 months', 'MMR second dose, Varicella, PCV booster'),
            ('16 to 18 months', 'DTP booster 1, IPV booster, Hib booster'),
            ('4 to 6 years', 'DTP booster 2, MMR third dose, Varicella 2'),
          ],
          note: 'Your paediatrician may vary this for good reasons. Her schedule '
              'for your child beats any chart, including this one.',
          hue: 180,
        ),
        PpCallout('Keep the physical vaccination card. It is the document '
            'schools, visas and hospitals ask for, the app is the reminder '
            'rather than the record, and a lost card is genuinely difficult to '
            'reconstruct.'),
        PpWhenLine('Most visits fall in the first eighteen months. After the '
            'four to six year boosters there is very little until adolescence.'),
        PpIndiaNote('The government schedule under the national programme covers '
            'fewer vaccines than the IAP list, so several of the rows above are '
            'paid for privately. That does not make them optional in the '
            'medical sense, and the cost page below is the honest version of '
            'that conversation.'),
        PpLink(
          'Open his vaccination schedule',
          surfaceId: 'pp_vaccines',
          blurb: 'What he has had, what is due next, and a reminder before it '
              'is.',
        ),
      ],
    ),
    PpPage(
      id: 'vax_what_each',
      title: 'What each shot is for',
      format: 'CARDS',
      blocks: [
        PpIntro('Twelve names on a card and no explanation is why families ask '
            'whether some can be skipped. Here is what each one actually '
            'prevents.'),
        PpCards([
          PpCard('BCG',
              'Protects against the severe forms of tuberculosis in small '
              'children. Given at birth, and the small scar it leaves is '
              'expected.'),
          PpCard('Hepatitis B',
              'A liver infection that can become lifelong when caught in '
              'infancy. First dose within a day of birth.'),
          PpCard('Pentavalent',
              'Five in one: diphtheria, tetanus, whooping cough, hepatitis B and '
              'Hib, which causes meningitis in babies.'),
          PpCard('Polio, oral and injected',
              'India is polio free and stays that way only while children keep '
              'being vaccinated.'),
          PpCard('PCV, pneumococcal',
              'The commonest cause of serious pneumonia and meningitis in small '
              'children. Not part of every state programme, and worth paying '
              'for.'),
          PpCard('Rotavirus',
              'Drops rather than a jab. Prevents the severe diarrhoea that '
              'hospitalises babies, which is a large problem in India.'),
          PpCard('MMR',
              'Measles, mumps and rubella. Measles is still common here and is '
              'genuinely dangerous.'),
          PpCard('Typhoid conjugate',
              'Typhoid is widespread in India and this is one of the clearest '
              'reasons the Indian schedule differs from a Western one.'),
          PpCard('Hepatitis A',
              'Spreads through food and water. Also very much an India '
              'specific addition.'),
          PpCard('Varicella',
              'Chickenpox. Often skipped on the grounds that everyone gets it, '
              'and the complications are the reason not to.'),
          PpCard('Influenza',
              'Yearly, from six months. Most useful in children with asthma or '
              'other ongoing conditions.'),
        ], heading: 'Eleven names, in plain words', hue: 180),
        PpCallout('There is no such thing as an optional vaccine in the sense '
            'families mean. There are vaccines the government pays for and '
            'vaccines you pay for. That is a funding line, not a medical one.'),
        PpCallout(
          'If your child has an immune condition, is on steroids or '
          'chemotherapy, or has had a severe reaction to a previous dose, some '
          'vaccines are given differently or not at all. That is a conversation '
          'with your paediatrician, and it is the only real exception list.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: every description here, and in particular the
        // statement that pneumococcal and rotavirus are not in every state
        // programme, which changes over time.
        PpWhenLine('Read once, before the six week visit, so the questions '
            'happen before the needles do.'),
        PpIndiaNote('If a relative is arguing that vaccines cause autism, that '
            'claim came from a single fraudulent paper that was withdrawn and '
            'whose author lost his licence. It has been tested repeatedly since, '
            'in millions of children, and it is not true.'),
      ],
    ),
    PpPage(
      id: 'vax_after',
      title: 'After a shot: what is normal',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost every baby is a bit miserable for a day after his '
            'injections. Here is the ordinary version, and the small list that '
            'is not ordinary.'),
        PpArticle([
          'Expect a sore red lump at the injection site, a mild fever, more '
          'sleep than usual or less, crankiness, and a poor appetite, mostly in '
          'the first 24 to 48 hours. The BCG site behaves differently: it often '
          'becomes a small raised spot at two to six weeks, may ooze a little, '
          'and heals into a scar. That is the vaccine working, not an infection, '
          'and it should be left alone and kept dry.',
          'What helps is a normal day: extra feeds, cuddles, a cool cloth on the '
          'thigh, and moving the leg gently. Paracetamol is reasonable if he is '
          'genuinely uncomfortable, in the range your doctor has confirmed. Do '
          'not give it routinely before the appointment to prevent a fever, '
          'because it is not needed and there is some evidence it slightly '
          'blunts the response.',
          'Some reactions are simply the schedule catching up: MMR can cause a '
          'mild fever and sometimes a faint rash around seven to twelve days '
          'afterwards rather than on the day, which surprises families who have '
          'stopped watching by then.',
        ]),
        PpCallout(
          'Call a doctor for: a fever above 40 C, a fit, crying that goes on '
          'inconsolably for more than three hours, a swollen area larger than a '
          'few centimetres or spreading redness after 48 hours, unusual floppiness '
          'or paleness, or any difficulty breathing or facial swelling, which is '
          'immediate. Severe reactions are rare and they are treatable, which is '
          'why the clinic asks you to wait fifteen minutes afterwards.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the 24 to 48 hour reaction window, the BCG lesion
        // timeline, the MMR delayed reaction at 7 to 12 days, the 40 C and
        // three hour crying thresholds, and the advice against prophylactic
        // paracetamol.
        PpWhenLine('Watch for 48 hours after most vaccines, and again around day '
            'seven to twelve after MMR.'),
        PpIndiaNote('Do not apply haldi, oil or a hot compress to the injection '
            'site, and do not rub it. A cool cloth and gentle movement of the '
            'leg is all it needs. If the clinic asks you to wait fifteen minutes '
            'in the waiting room, wait.'),
        PpVideoSlot(
          title: 'The day after a vaccination',
          subtitle: 'What is normal, what to do for the sore leg, and the short '
              'list that means calling the clinic.',
          minutes: '4 MIN',
          slotId: 'health/after_vaccine_care',
        ),
      ],
    ),
    PpPage(
      id: 'vax_catch_up',
      title: 'If you are behind',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('A missed dose is a delay, not a disaster, and almost never a '
            'reason to start again. This comes up constantly and worries '
            'families far more than it should.'),
        PpArticle([
          'The schedule has minimum gaps between doses rather than fixed dates, '
          'so if a dose is late, the answer is usually to give it now and '
          'continue from there. A course that was interrupted is picked up where '
          'it stopped. Very few vaccines have to be restarted from the '
          'beginning, and your paediatrician will tell you if one of his does.',
          'Some vaccines have an upper age limit: rotavirus in particular has to '
          'be started and finished within a window in infancy, and if that '
          'window has passed it cannot be given later. That is a real reason not '
          'to let the early visits drift, and a good reason to book the catch up '
          'appointment this week rather than next month.',
          'Bring the vaccination card, or a photo of it, even if it is '
          'incomplete. A doctor can rebuild a schedule from a partial record far '
          'more easily than from memory, and where nothing at all was recorded '
          'there is a standard catch up plan by age.',
        ]),
        PpCallout('Late is fine. Never is not. Book the appointment, take '
            'whatever record you have, and let the doctor work out the '
            'sequence.'),
        PpCallout(
          'If he has missed doses and is now unwell, an ordinary cold or a mild '
          'fever is not a reason to postpone again. Ask the clinic rather than '
          'assuming. Only a significant illness usually delays a vaccination.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the "restart is rarely needed" statement, the
        // rotavirus upper age limit, and the guidance that minor illness is not
        // a contraindication.
        PpWhenLine('Any time you notice a gap. The sooner the better for the '
            'ones with an age limit.'),
        PpIndiaNote('Moving city, a long stay at nani\'s house and the pandemic '
            'years put a lot of Indian children behind. Government hospitals and '
            'urban health centres will complete a schedule regardless of where '
            'the earlier doses were given.'),
        PpLink(
          'Check what he has had and what is missing',
          surfaceId: 'pp_vaccines',
          blurb: 'The list, and what is overdue.',
        ),
      ],
    ),
    PpPage(
      id: 'vax_cost',
      title: 'Government hospital or private clinic, and what it costs',
      format: 'COMPARISON TABLE',
      blocks: [
        PpIntro('This is asked far more often than it is answered honestly. '
            'Both routes are real, both are used by careful families, and the '
            'difference is mostly which vaccines are covered and how long you '
            'wait.'),
        PpTable(
          heading: 'The two routes',
          columns: ['', 'Government centre', 'Private clinic'],
          // REQUIRED_REVIEW: the cost bands quoted here, which change and vary
          // by city, and the claim about which vaccines the national programme
          // covers. Confirm before release and date the figures on the screen.
          rows: [
            [
              'Cost',
              'Free for the vaccines in the national programme',
              'Roughly Rs 500 to Rs 5,000 per visit depending on the vaccines',
            ],
            [
              'What is covered',
              'BCG, Hepatitis B, Pentavalent, Polio, MR, and more in some states',
              'Everything on the IAP list, including PCV, Rotavirus, Typhoid, '
                  'Hepatitis A, Varicella',
            ],
            [
              'Quality of the vaccine',
              'Same regulated supply, properly cold stored',
              'Same regulated supply',
            ],
            [
              'Waiting',
              'Fixed immunisation days, often a long queue',
              'By appointment, usually quick',
            ],
            [
              'Record keeping',
              'A card you must keep safe',
              'A card, and usually a clinic record too',
            ],
            [
              'Best for',
              'The core schedule, at no cost, near home',
              'The additional vaccines, and a single place that tracks '
                  'everything',
            ],
          ],
        ),
        PpCallout('Mixing the two is completely normal and completely fine. Many '
            'families take the free core vaccines at the government centre and '
            'pay privately for the ones the programme does not cover. Keep one '
            'card for both.'),
        PpCallout(
          'Ask two questions wherever you go: which vaccine is being given '
          'today, and is it recorded on the card with the date and the batch '
          'number. Those two answers are what make a schedule reconstructable '
          'later.',
          kind: PpCalloutKind.safety,
        ),
        PpWhenLine('Decide once, before the six week visit, and stay flexible '
            'after that.'),
        PpIndiaNote('Government immunisation days are usually fixed days of the '
            'week at the urban health centre or anganwadi. Ask the ASHA worker '
            'or the centre directly, because the day varies by area and a wasted '
            'trip with a baby is a real cost.'),
        PpLink(
          'Find a clinic or paediatrician near you',
          surfaceId: 'pp_find_help',
          blurb: 'Who does what, and who is nearby.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 9 — Is he growing well?
// -----------------------------------------------------------------------------
//  ⚠️ PHYSICAL GROWTH LIVES HERE, DEVELOPMENTAL MILESTONES DO NOT. The spec
//  draws this line explicitly and keeps milestones in the Development section.
//  So this area is weight, height, head size and percentiles, and it links
//  across rather than duplicating.
// =============================================================================

final PpArea _growth = PpArea(
  id: 'growth',
  mark: IntentMark.scaleMark,
  title: 'Is he growing well?',
  blurb: 'Weight, height, head size and percentiles, and the pressure to make '
      'him fatter.',
  hue: 44,
  pages: [
    PpPage(
      id: 'growth_normal',
      title: 'The pressure to make him mota',
      format: 'ARTICLE',
      blocks: [
        PpIntro('Almost every Indian mother is told her baby is too thin, '
            'usually by somebody who loves the baby. Here is what actually '
            'counts as growing well.'),
        PpArticle([
          'A growth chart is not a target and there is no prize for a high '
          'percentile. A child at the tenth percentile who is following his own '
          'line, feeding, active and meeting his milestones is growing '
          'perfectly. A child at the ninetieth percentile who has dropped across '
          'two lines is the one a doctor looks at. The shape of his own curve '
          'over time is the whole signal; a single weight is almost noise.',
          'Weight gain is fastest in the first months and slows sharply after '
          'that. A baby who gained a kilo a month at two months and gains a '
          'third of that at nine months has not stopped growing, he has moved '
          'into the ordinary next phase. Around the first birthday most toddlers '
          'eat noticeably less and become fussy, which is normal and reliably '
          'terrifies the family.',
          'Compare him with himself, not with the neighbour\'s baby or with his '
          'cousin. Children are built differently, and the neighbour is not '
          'weighing her baby on the same scales.',
        ]),
        PpChartCard(
          title: 'Rough expectations, and they are rough',
          // REQUIRED_REVIEW: EVERY FIGURE. Confirm the birth weight regain by
          // day 10 to 14, doubling by 5 months, tripling by 12 months, and the
          // monthly gain bands, and confirm they are stated as ranges rather
          // than targets.
          rows: [
            ('Back to birth weight by', 'Day 10 to 14'),
            ('Weight gain, 0 to 3 months', 'About 150 to 200 g a week'),
            ('Weight gain, 3 to 6 months', 'About 100 to 150 g a week'),
            ('Doubles his birth weight by', 'About 5 months'),
            ('Triples his birth weight by', 'About 12 months'),
            ('Head circumference', 'Measured at every visit in the first year'),
          ],
          note: 'These are averages across many babies. Yours is one baby, and '
              'his own line over time matters more than any row here.',
          hue: 44,
        ),
        PpCallout('The two questions worth asking at every visit: is he '
            'following his own curve, and is he well in himself. Everything '
            'else is conversation.'),
        PpWhenLine('Weigh at the vaccination visits in the first year, then '
            'every few months. Weighing at home every week creates worry rather '
            'than information.'),
        PpIndiaNote('Do not start biscuits, cerelac, ghee spoonfuls or a bottle '
            'top up in order to satisfy a relative. If you genuinely think he is '
            'not gaining, take him to be weighed on the clinic scales and let '
            'the chart answer it. That is a much better argument at home than '
            'anything you can say.'),
        PpLink(
          'Plot his weight and height',
          surfaceId: 'pp_growth',
          blurb: 'His own curve over time, on a real chart.',
        ),
      ],
    ),
    PpPage(
      id: 'growth_percentiles',
      title: 'What a percentile actually means',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Percentiles cause more anxiety than any other number in '
            'paediatrics, mostly because they sound like marks out of a '
            'hundred. They are not.'),
        PpArticle([
          'A percentile is a position in a crowd, not a score. If he is on the '
          'twenty fifth percentile for weight, it means that out of a hundred '
          'healthy children his age, about twenty five weigh less and about '
          'seventy five weigh more. Somebody has to be on the twenty fifth '
          'percentile. It is not a fail.',
          'What a paediatrician watches is the line, not the point. A child who '
          'has tracked along the twenty fifth percentile since birth is doing '
          'exactly what he should. A child who was on the seventy fifth and has '
          'crossed down through two percentile lines over a few months is worth '
          'looking into, even though his weight is still higher than the first '
          'child\'s.',
          'Head circumference is plotted for a different reason: it follows '
          'brain growth in the first two years, and a head that is growing much '
          'faster or much slower than expected is a thing to catch early. That '
          'is why the tape measure comes out at visits that otherwise seem to be '
          'about vaccines.',
        ]),
        PpCallout('One measurement means very little. Three over six months '
            'mean a great deal. That is the entire logic of a growth chart.'),
        PpCallout(
          'Ask a doctor about: crossing downward through two percentile lines, '
          'no weight gain over two months in a baby, weight loss at any age, a '
          'head measurement that jumps or stalls, or a child whose height has '
          'clearly stopped moving. Take the chart with you rather than the '
          'latest number.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: "crossing two centile lines" as the trigger, "no
        // weight gain over two months in a baby", and the head circumference
        // rationale.
        PpWhenLine('Plotted at every growth check through the first two years, '
            'and yearly after that.'),
        PpIndiaNote('Indian charts and international charts differ slightly, and '
            'a clinic may use either. Use the same chart each time. A child who '
            'appears to jump percentiles between two clinics has usually only '
            'changed charts.'),
      ],
    ),
    PpPage(
      id: 'growth_flags',
      title: 'Growth that needs a doctor',
      format: 'FLAGGED CALLOUT',
      blocks: [
        PpIntro('Most growth worry is unnecessary. This is the short list that '
            'is not, so you know what you are actually watching for.'),
        // REQUIRED_REVIEW: EVERY THRESHOLD IN THIS CALLOUT. Confirm the day 14
        // birth weight regain, "no weight gain in two months under one year",
        // any weight loss after the newborn period, and crossing two centile
        // lines downward.
        PpCallout(
          'See a paediatrician if: he has not regained his birth weight by two '
          'weeks; he has not gained weight in two months in the first year; he '
          'has lost weight at any point after the newborn period; he has crossed '
          'downward through two percentile lines; his height has clearly '
          'stalled; his head is growing much faster or much slower than his '
          'chart; or he is persistently pale, very tired, or losing skills he '
          'had.',
          kind: PpCalloutKind.doctor,
          title: 'Seven reasons to have him checked',
        ),
        PpCards([
          PpCard('Take the chart, not the number',
              'The line over months is the thing that answers the question. A '
              'single weight on a phone is not.'),
          PpCard('Say what he actually eats in a day',
              'Write it down for two days before the visit. Memory rounds '
              'upward.'),
          PpCard('Mention how much milk',
              'A toddler drinking a great deal of milk often eats very little '
              'else and can become anaemic on it.'),
          PpCard('Mention any illness that month',
              'Children lose weight during illness and regain it after. Context '
              'changes the reading.'),
        ], heading: 'What to bring', hue: 44),
        PpCallout('Growth is one of the most useful health signals there is, '
            'precisely because it is slow. It rarely needs urgency and it '
            'rewards attention.'),
        PpWhenLine('At every growth check, and any time the chart is going '
            'sideways rather than up.'),
        PpIndiaNote('Anaemia is common in Indian toddlers and shows up as '
            'tiredness, pallor and poor appetite rather than as a dramatic '
            'symptom. Ask about it at the one year visit; a simple blood test '
            'answers it.'),
        PpLink(
          'Developmental milestones live in Development',
          surfaceId: 'pp_section/parenting_development',
          blurb: 'Sitting, walking, talking and playing are tracked there, not '
              'here.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 10 — Keeping his papers together
// -----------------------------------------------------------------------------
//  The quiet organising door. Everything here is LIVE: the wallet, the timeline,
//  the prescriptions, the reports and the doctor visit companion all exist and
//  are reached from `pp_health_home`.
// =============================================================================

final PpArea _records = PpArea(
  id: 'records',
  mark: IntentMark.reportPage,
  title: 'Keeping his papers together',
  blurb: 'Prescriptions, reports, visits and medicines in one place, and '
      'getting more out of a short appointment.',
  hue: 210,
  pages: [
    PpPage(
      id: 'rec_wallet',
      title: 'Everything in one place',
      format: 'RECORDS',
      blocks: [
        PpIntro('Every family keeps health papers in a plastic folder that is '
            'never in the room where you need it. This is the same folder, on '
            'your phone, and it takes about twenty minutes to set up.'),
        PpSteps([
          PpStep('Photograph every prescription as you get it',
              'At the clinic, before it goes into a bag. Later never happens.'),
          PpStep('Add the reports',
              'Blood tests, scans, discharge summaries. The summary matters more '
              'than the whole file.'),
          PpStep('List his regular medicines and his allergies',
              'This is the part a doctor asks for every single time.'),
          PpStep('Record each visit in a line',
              'Date, who he saw, what was decided. Six months later this is the '
              'only thing that answers "when did this start".'),
          PpStep('Keep the vaccination card photographed too',
              'It is the document that is hardest to replace.'),
        ], heading: 'Five habits'),
        PpArticle([
          'The reason this is worth the twenty minutes is that health questions '
          'are almost always about time. Did the cough start before or after the '
          'antibiotic. How long has he been on this inhaler. Was that rash the '
          'same as this one. A record answers those in seconds and memory does '
          'not, particularly in a family where three people take him to '
          'different appointments.',
          'It also matters when you change doctors, change cities, or end up at '
          'a hospital where nobody knows him. Handing over a clear history is '
          'the single most useful thing a parent can do in that room.',
        ]),
        PpCallout('A record is a private thing. Share what is relevant with the '
            'doctor in front of you rather than handing over everything, and '
            'keep the emergency card as the one thing that is meant to be '
            'shown.'),
        PpWhenLine('Set it up once. Add to it on the day, at the clinic, not '
            'later at home.'),
        PpIndiaNote('Hospitals here rarely hold a shared record across visits, '
            'and prescriptions are handwritten. The photograph you take in the '
            'consulting room is frequently the only surviving copy.'),
        PpLink(
          'Open his health papers',
          surfaceId: 'pp_health_home',
          blurb: 'Timeline, prescriptions, reports, medicines, allergies and '
              'visits.',
        ),
      ],
    ),
    PpPage(
      id: 'rec_doctor_visit',
      title: 'Getting the most out of seven minutes',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('A busy paediatric OPD gives you a few minutes. Preparation is '
            'the difference between leaving with answers and remembering your '
            'real question in the car park.'),
        PpSteps([
          PpStep('Write the questions down as they occur to you',
              'Over the days before, not in the waiting room. Three is a good '
              'number, and put the most important one first.'),
          PpStep('Start with your single biggest worry',
              'Doctors organise the whole consultation around the first thing '
              'they hear, so lead with what actually frightens you.'),
          PpStep('Bring the numbers',
              'Current weight, temperatures you recorded, how many days, what '
              'medicine and when.'),
          PpStep('Ask what to watch for at home',
              '"What would make me bring him back?" is the single most useful '
              'question in paediatrics, and it is rarely asked.'),
          PpStep('Ask what happens if it does not settle',
              'A plan for the failure case saves the next appointment.'),
          PpStep('Write down the answer before you leave the building',
              'Or record it on your phone with permission. Nobody remembers a '
              'dosing instruction accurately by evening.'),
        ], heading: 'Six things'),
        PpScript(
          [
            PpScriptLine(
              say: 'What would make me bring him back?',
              notThis: 'Okay doctor, thank you.',
              why: 'It turns a consultation into a plan, and it is the question '
                  'doctors most wish parents asked.',
            ),
            PpScriptLine(
              say: 'Is there anything we should test, or are we watching for '
                  'now?',
              notThis: 'Should we do some tests, just to be safe?',
              why: 'It asks for her reasoning rather than pushing for a test, '
                  'and you usually get a much better answer.',
            ),
            PpScriptLine(
              say: 'Does he actually need an antibiotic for this?',
              notThis: 'Please give something strong, we have a wedding on '
                  'Saturday.',
              why: 'It gives the doctor room to say no, which is often the '
                  'correct answer and is harder to give under pressure.',
            ),
          ],
          heading: 'Three questions worth memorising',
        ),
        PpCallout(
          'If you leave and are still worried, that is a reason to go back, not '
          'a reason to feel foolish. Paediatricians expect return visits in a '
          'child who is not settling, and they would far rather see him twice.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Ten minutes of preparation before any appointment that is '
            'about more than a vaccination.'),
        PpIndiaNote('If more than one adult takes him to appointments, keep the '
            'question list where all of them can see it. A grandmother who took '
            'him last week holds half the history.'),
        PpLink(
          'Build the question list now',
          surfaceId: 'pp_doctor_visit',
          blurb: 'Add questions as they occur to you, and take the list in with '
              'you.',
        ),
      ],
    ),
  ],
);

// =============================================================================
//  AREA 11 — Keeping him well
// -----------------------------------------------------------------------------
//  Prevention and everyday care. Short pages, and only the ones that earn their
//  place: the spec's own rule is "no filler, every page genuinely useful on its
//  own, or dropped".
// =============================================================================

final PpArea _prevention = PpArea(
  id: 'prevention',
  mark: IntentMark.improveMark,
  title: 'Keeping him well',
  blurb: 'The dull things that genuinely cut illness, and the seasons that '
      'bring it.',
  hue: 100,
  pages: [
    PpPage(
      id: 'prev_handwashing',
      title: 'The dull things that actually work',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Nothing in this section prevents illness as effectively as '
            'washing hands, and nothing is more boring to be told. Here is the '
            'short version, once.'),
        PpArticle([
          'Most childhood infections travel on hands and then into a mouth. '
          'Twenty seconds of soap and water at the right moments cuts colds and '
          'cuts tummy bugs measurably, which is more than any tonic, any '
          'supplement and any air purifier will do for him.',
          'The moments that matter: coming home from outside, before eating, '
          'after the toilet or a nappy, after playing with a pet, and after '
          'anyone in the house has been coughing. Teach it as a habit at the '
          'door rather than as a rule, because a habit survives and a rule needs '
          'enforcing.',
        ]),
        PpCards([
          PpCard('Wash at the door, every time',
              'Yours and his. This one habit does most of the work.'),
          PpCard('Cough into the elbow',
              'Teachable from about two, and it works.'),
          PpCard('Own towel, own glass, own handkerchief',
              'Especially when somebody in the house is ill.'),
          PpCard('Do not share a spoon or pre chew his food',
              'It passes on the bacteria that cause tooth decay, along with '
              'whatever else is going around.'),
          PpCard('Keep him home when he is infectious',
              'It is the neighbourly thing and it also stops the illness coming '
              'back around the creche to him.'),
        ], heading: 'Five habits worth the effort', hue: 100),
        PpCallout('Hand sanitiser is a stand in for soap when there is no water, '
            'not an upgrade on it. Keep it out of reach: swallowing it makes a '
            'small child genuinely unwell.'),
        PpWhenLine('From the moment he starts crawling, and taught properly from '
            'about eighteen months.'),
        PpIndiaNote('In a joint household the most useful habit is a wash '
            'station at the entrance, so everyone who comes back from work or '
            'from the market washes before picking up the baby. That is easier '
            'to establish than asking each person separately.'),
      ],
    ),
    PpPage(
      id: 'prev_immunity',
      title: 'Building immunity, and the tonics that will not',
      format: 'ARTICLE',
      blocks: [
        PpIntro('The immunity market in India is enormous and almost none of it '
            'does anything. The things that genuinely help are cheap, dull and '
            'already in your kitchen.'),
        PpArticle([
          'A child\'s immune system is built by exposure, sleep, food and '
          'vaccination. There is no supplement that raises immunity in a well '
          'fed child, and the syrups, chyawanprash formulations and multivitamin '
          'tonics sold for it have not been shown to reduce how often children '
          'fall ill. Where a real deficiency exists, iron, vitamin D or vitamin '
          'B12, the correct answer is a test and a treatment from a doctor, not '
          'a general tonic.',
          'What does help: a varied home diet with iron rich foods, enough '
          'sleep, time outdoors, and completing the vaccination schedule. Iron '
          'matters particularly in Indian toddlers, where anaemia is common, and '
          'it comes from dal, ragi, green leafy vegetables, jaggery, egg and '
          'meat. Vitamin C rich food eaten alongside, a little lemon, amla or '
          'tomato, helps the iron get absorbed.',
          'Vitamin D is the genuine exception. Indian children are commonly '
          'short of it despite the sunshine, because of skin cover, indoor time '
          'and pollution, and many paediatricians supplement it routinely in the '
          'first years. That is a prescription rather than a purchase, so ask '
          'yours what she recommends for him.',
        ]),
        PpCallout(
          'Do not give a daily multivitamin, an iron syrup or a growth tonic on '
          'your own. Iron overdose is one of the more common serious poisonings '
          'in small children, and vitamin A and D can build up. If you think he '
          'needs something, ask for a test first.',
          kind: PpCalloutKind.doctor,
          title: 'Supplements are prescriptions, not groceries',
        ),
        // REQUIRED_REVIEW: the statement that supplements do not reduce
        // infection frequency in a well nourished child, the vitamin D
        // supplementation practice in India, and the iron overdose warning.
        PpWhenLine('Food and sleep from the start. Any supplement only after a '
            'doctor has said so.'),
        PpIndiaNote('Frequent colds in a creche child are not a sign of weak '
            'immunity, and they are the single commonest reason a family starts '
            'a tonic. Six to twelve colds a year at this age is the ordinary '
            'number, and it falls every year on its own.'),
        PpLink(
          'Iron rich meals he will actually eat',
          surfaceId: 'pp_food',
          blurb: 'Recipes from the Food companion, sorted by age.',
        ),
      ],
    ),
    PpPage(
      id: 'prev_monsoon',
      title: 'Monsoon, and the season of illness',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('Every Indian family knows the monsoon brings illness. Knowing '
            'which illnesses, and which precautions actually matter, makes the '
            'season much less of a lottery.'),
        PpArticle([
          'The monsoon and the weeks after it bring three separate problems: '
          'mosquito borne illness, dengue, chikungunya and malaria; water and '
          'food borne illness, typhoid, hepatitis A and the ordinary tummy bugs; '
          'and the viral fevers and chest infections that come with damp and '
          'crowding indoors. They need different precautions, which is why one '
          'general instruction to be careful achieves so little.',
          'For mosquitoes, the highest value action is emptying standing water '
          'at home once a week: cooler trays, plant saucers, the terrace bucket, '
          'the money plant bottle, the fridge tray. The dengue mosquito breeds '
          'in clean water and bites during the day, so daytime full sleeves and '
          'a child safe repellent matter more than a night net.',
          'For water and food, boiled or filtered water, home cooked food, no '
          'cut fruit from a cart, and washing vegetables well. Hepatitis A and '
          'typhoid both have vaccines on the IAP schedule, which is the most '
          'reliable protection of all and one many families skip.',
        ]),
        PpCards([
          PpCard('Empty standing water weekly',
              'Set a day. This is the single most effective dengue precaution '
              'there is.'),
          PpCard('Full sleeves in the daytime',
              'The dengue mosquito bites in daylight, not at night.'),
          PpCard('Boiled or filtered water, always',
              'Including for making up formula and for brushing teeth in a bad '
              'water area.'),
          PpCard('Dry the feet and the folds',
              'Damp skin in humidity gets fungal rashes fast, especially in the '
              'nappy area and between the toes.'),
          PpCard('Check the typhoid and hepatitis A doses',
              'Both are on the schedule. Both are commonly missed.'),
        ], heading: 'Five that earn their place', hue: 100),
        PpCallout(
          'Any fever in the monsoon that lasts past the third day, or that '
          'settles and returns, should be seen by a doctor and usually tested '
          'rather than watched further. This is the season where that rule '
          'matters most, because dengue and typhoid both hide behind an '
          'ordinary looking fever.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('From the first rains until about a month after they stop, '
            'which is when dengue peaks.'),
        PpIndiaNote('Fogging in the colony kills adult mosquitoes for a day and '
            'does nothing about the ones breeding on your own balcony. The '
            'bucket matters more than the fogging machine.'),
      ],
    ),
    PpPage(
      id: 'prev_pollution',
      title: 'Air pollution and small lungs',
      format: 'SHORT ARTICLE',
      blocks: [
        PpIntro('In a lot of Indian cities this is a bigger health question for '
            'a child than any single illness, and it is one of the few where '
            'household choices genuinely change the exposure.'),
        PpArticle([
          'Small children breathe faster than adults, their airways are '
          'narrower, and their lungs are still being built until well into '
          'childhood, so the same air does more to them. The effects that show '
          'up are more coughs and colds, more wheezing, worse asthma where it '
          'exists, and lower lung growth over years rather than a dramatic '
          'single event.',
          'Indoor air is the part you control. The largest indoor sources in '
          'Indian homes are cooking smoke where a chulha or a poorly ventilated '
          'kitchen is used, mosquito coils, incense, and cigarette smoke. A '
          'mosquito coil burned in a closed room overnight beside a baby is a '
          'significant exposure, and a liquid vaporiser or a net is a much '
          'better choice.',
          'Outdoors, the honest advice is to check the air quality on bad days '
          'and shift outdoor play to the times when it is lowest, usually late '
          'morning and afternoon rather than early morning in winter, when smog '
          'settles. On genuinely bad days, indoor play is the right call, and a '
          'purifier in the room he sleeps in is worth it if you can afford one. '
          'Masks do not fit small children and are not the answer for them.',
        ]),
        PpCallout(
          'Nobody smokes in the house or the car, and nobody smokes and then '
          'holds the baby. Smoke stays on clothes and hair and reaches him '
          'anyway. Smoking outside on the balcony is the minimum, and it is '
          'still not nothing.',
          kind: PpCalloutKind.safety,
          title: 'The one that matters most',
        ),
        PpCallout(
          'A child who coughs at night most weeks, wheezes with every cold, gets '
          'breathless running about, or misses school repeatedly for chest '
          'illness, should be assessed for asthma rather than treated cold by '
          'cold. It is common, it is manageable, and it is under diagnosed here.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: the claims about children's relative exposure, the
        // mosquito coil comparison, the advice on outdoor timing in winter smog,
        // and the statement that masks are unsuitable for small children.
        PpWhenLine('All year in a polluted city, and particularly through the '
            'winter smog months.'),
        PpIndiaNote('If the kitchen is closed and there is no chimney or exhaust, '
            'keep the baby out of it while cooking and open a window. Cooking '
            'smoke exposure in the first years is one of the better documented '
            'risks to Indian children\'s lungs.'),
      ],
    ),
    PpPage(
      id: 'prev_medicine',
      title: 'How to give medicine to a baby',
      format: 'STEP-LIST',
      blocks: [
        PpIntro('Half of a prescription that never reaches the child is a '
            'prescription that did not work. Technique matters more than '
            'families expect, and it is easily learned.'),
        PpSteps([
          PpStep('Read the label and the strength, every time',
              'Which drug, what strength, how much, how often. Even the bottle '
              'you have used before, because brands change.'),
          PpStep('Use the syringe or the cup that came in the box',
              'Never a kitchen spoon. A teaspoon in one house is not a teaspoon '
              'in the next.'),
          PpStep('Sit him upright, never lying flat',
              'On your lap, head slightly raised. Flat means it goes down the '
              'wrong way.'),
          PpStep('Aim into the inside of the cheek, not the throat',
              'Slowly, a little at a time, letting him swallow between. Squirting '
              'it at the back of the mouth makes him gag and often vomit.'),
          PpStep('For an older child, offer a choice rather than a fight',
              'Which cup, sitting where, and something to drink after. Holding a '
              'child down works once and makes the next six doses harder.'),
          PpStep('Write the time down',
              'Especially when two adults are sharing the night.'),
        ], heading: 'Six steps'),
        PpCallout(
          'Never mix medicine into a full bottle or a full glass of milk. If he '
          'does not finish it, you have no idea how much he received. Give the '
          'dose on its own, then offer the drink.',
          kind: PpCalloutKind.safety,
        ),
        PpArticle([
          'If he vomits immediately after a dose, do not automatically repeat '
          'it. Doubling by accident is a real risk, and the right answer depends '
          'on the drug and on how long ago it was, so ask the pharmacist or the '
          'clinic before giving it again.',
          'Finish the course of an antibiotic exactly as prescribed, even after '
          'he is better on day three, and never save the leftover half bottle '
          'for the next illness. Old antibiotics in a cupboard are how a family '
          'ends up treating the wrong thing with the wrong drug at the wrong '
          'dose. Store medicines locked away and out of sight, because '
          'accidental swallowing is the commonest childhood poisoning there is.',
        ], heading: 'Two things that go wrong'),
        PpCallout(
          'If he has swallowed a medicine he was not given, call a doctor or go '
          'to a hospital immediately and take the bottle with you. Do not wait '
          'to see if anything happens, and do not make him vomit.',
          kind: PpCalloutKind.doctor,
        ),
        PpWhenLine('Every medicine, every age. Most important under two, when he '
            'cannot cooperate.'),
        PpIndiaNote('Do not accept a strip of tablets cut in half as a child '
            'dose, and do not give an adult tablet broken into pieces unless a '
            'doctor has told you exactly how. Paediatric syrups and drops exist '
            'precisely because a fraction of an adult tablet is not a reliable '
            'dose.'),
        PpVideoSlot(
          title: 'Giving medicine safely, demonstrated',
          subtitle: 'The syringe, the cheek, the upright hold, and what to do '
              'when he spits it out.',
          minutes: '5 MIN',
          slotId: 'health/giving_medicine',
        ),
      ],
    ),
    PpPage(
      id: 'prev_sick_home',
      title: 'When to keep him home',
      format: 'CARDS',
      blocks: [
        PpIntro('Creche and playschool are where illness circulates, and the '
            'guidance is usually vague. Here is a workable version you can also '
            'show to whoever is asking you to send him in.'),
        PpCards([
          PpCard('Keep him home: any fever',
              'Until 24 hours after the fever has gone without medicine. A dose '
              'of paracetamol before drop off is not the same as being well.'),
          PpCard('Keep him home: vomiting or loose motions',
              'Until 24 to 48 hours after the last episode. This is the one that '
              'spreads fastest.'),
          PpCard('Keep him home: HFMD with fever and fresh blisters',
              'Usually about a week. Tell the creche so they can warn others.'),
          PpCard('Keep him home: chickenpox, until every blister has crusted',
              'Roughly five to seven days from the first spot.'),
          PpCard('Keep him home: red weeping eyes',
              'Conjunctivitis moves through a class in days.'),
          PpCard('He can go: a plain runny nose, no fever, himself again',
              'Waiting for a child to have no snot at all in winter means '
              'waiting until March.'),
        ], heading: 'The honest version', hue: 100),
        PpCallout('The test is not whether he has a symptom, it is whether he is '
            'infectious and whether he is well enough to take part in the day. '
            'Those two questions answer almost every case.'),
        PpCallout(
          'Tell the creche what he has, particularly for HFMD, chickenpox, '
          'conjunctivitis and any tummy bug. A pregnant teacher or a baby '
          'sibling elsewhere in the building may need to know, and a doctor may '
          'need to be told about them too.',
          kind: PpCalloutKind.doctor,
        ),
        // REQUIRED_REVIEW: every exclusion period on this page, in particular
        // the 24 hour fever free rule, the 24 to 48 hours after vomiting or
        // diarrhoea, and the chickenpox crusting period.
        PpWhenLine('From the first term at creche, usually somewhere between one '
            'and three years.'),
        PpIndiaNote('Sending a child in on paracetamol so that a working day is '
            'not lost is extremely common and it is how a whole class gets ill. '
            'If leave is genuinely impossible, say so plainly to the creche and '
            'work something out, rather than masking a fever.'),
      ],
    ),
    PpPage(
      id: 'prev_antibiotics',
      title: 'Antibiotics, and why the chemist should not decide',
      format: 'ARTICLE',
      blocks: [
        PpIntro('India uses more antibiotics in children than almost anywhere, '
            'and most of those courses were never needed. This page is the one '
            'to read before you ask for one.'),
        PpArticle([
          'Antibiotics kill bacteria. They do absolutely nothing to a virus, and '
          'colds, flu, most sore throats, most coughs, most fevers, bronchiolitis '
          'and ordinary loose motions are all viral. Giving an antibiotic for '
          'those does not shorten the illness by an hour. What it does is upset '
          'his gut for weeks, sometimes cause a rash or diarrhoea, and make the '
          'bacteria he does carry harder to treat the next time he genuinely '
          'needs one.',
          'That last part is not an abstraction in India. Resistant infections '
          'are already common here, and a child who has had many unnecessary '
          'courses is more likely to be carrying bacteria that the usual drugs '
          'will not touch when he is admitted with something serious. The person '
          'this protects is your own child, later.',
          'So the useful thing to do in the consulting room is the opposite of '
          'what is usual: rather than asking for something strong, ask whether '
          'he actually needs an antibiotic at all, and what she is expecting the '
          'illness to do over the next two days. A doctor who says "this is '
          'viral, give paracetamol and bring him back if he is worse on Friday" '
          'is practising better medicine than one who reaches for a bottle, and '
          'she is far more likely to say it if you have not asked for one.',
        ]),
        PpCards([
          PpCard('Viral, so no antibiotic',
              'Colds, most coughs, flu, most sore throats, bronchiolitis, '
              'ordinary loose motions, HFMD, chickenpox, most fevers.'),
          PpCard('Sometimes bacterial, so it depends',
              'Ear infection, sore throat with certain features, sinus symptoms '
              'that drag on. Someone has to look.'),
          PpCard('Bacterial, so yes',
              'Urine infection, pneumonia, typhoid, and any serious infection '
              'in a young baby. Here the antibiotic is the treatment.'),
          PpCard('Never from a leftover strip',
              'A half course from last time is the wrong drug at the wrong dose '
              'for the wrong illness.'),
        ], heading: 'Roughly, which is which', hue: 100),
        PpCallout(
          'Do not buy an antibiotic over a chemist counter without a '
          'prescription, and do not repeat an old one because the symptoms look '
          'similar. If a course is prescribed, finish it exactly as written and '
          'throw away what remains.',
          kind: PpCalloutKind.safety,
          title: 'The chemist counter rule',
        ),
        PpCallout(
          'Antibiotics genuinely save lives, and the point of this page is not '
          'to make you refuse one. If your paediatrician has examined him and '
          'prescribed a course, give it, all of it, and ask her why if you want '
          'to understand the reasoning.',
          kind: PpCalloutKind.doctor,
          title: 'And when one is prescribed, give it',
        ),
        // REQUIRED_REVIEW: the viral versus bacterial lists, the statement
        // about antibiotic resistance prevalence in India, and the instruction
        // to complete a prescribed course.
        PpWhenLine('Worth reading once, before the next fever, rather than in '
            'the queue at the clinic.'),
        PpIndiaNote('Many Indian chemists will sell antibiotics without a '
            'prescription and some will recommend one. It is not their fault '
            'that the system works this way, and it is still not a safe way to '
            'treat a child. Ask for the drug name and take it to a doctor '
            'instead.'),
        PpConsult(
          title: 'Ask a paediatrician whether this needs an antibiotic',
          whoFor: 'For the parent who has been handed a prescription, or told to '
              'buy something at the chemist, and wants a second opinion from a '
              'paediatrician before starting a course.',
          surfaceId: 'pp_experts',
          role: 'pediatrician',
        ),
      ],
    ),
  ],
);
