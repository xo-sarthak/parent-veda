// =============================================================================
//  Age phases — the spine of My Child (replaces the Wonder Weeks "leaps")
// -----------------------------------------------------------------------------
//  WHY THIS REPLACED LEAPS (see docs/MY-CHILD-PHASES.md):
//
//  The app was built on the Wonder Weeks framework: ten "mental leaps" at fixed
//  weeks. That framework failed replication — Plooij's own PhD student, Dr
//  Carolina de Weerth, could not reproduce the fussy periods or developmental
//  jumps at the predicted weeks, and later attempts also failed. It also stops
//  at ~20 months, leaving nothing for the 2–5 year content we need.
//
//  And it contradicted our own product commitment: telling every parent their
//  baby is "in Leap 5" at the same week is the opposite of personalisation.
//
//  So the structure now follows the AAP/CDC 2022 evidence-informed milestone
//  framework — peer-reviewed, used clinically, and organised around well-child
//  visit checkpoints. Milestones use the AAP 75% threshold ("most children can
//  do this by now"), which the 2022 revision adopted specifically to stop
//  "wait and see" delays.
//
//  WHAT SURVIVED FROM WONDER WEEKS: one insight only — that a fussy patch often
//  precedes a new skill. It lives as CONTENT inside the phases where it is
//  relevant, never as structure. The 6-week crying peak is retained too; that
//  finding IS independently supported.
//
//  A NOTE ON THE 20th PHASE: the source document lists 19 phases but leaves
//  31–35 months uncovered (row 17 ends at the 30-month checkpoint, row 18
//  begins at 3 years). Rather than silently widen a neighbour, phase 18 below
//  fills the gap explicitly and is flagged for review. It is the one boundary
//  here the source document does not sanction.
//
//  All content is DRAFT, written from the AAP/CDC framework for review by the
//  content team before it ships. Nothing here is a diagnosis, and every phase
//  carries the "your paediatrician knows your child" framing.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart'; // ppPurple - the one brand colour every phase uses

/// The five developmental domains AAP/CDC organise milestones under. We use the
/// same five so our content maps cleanly onto the clinical checklists.
enum PhaseDomain { motor, cognitive, language, social, adaptive }

extension PhaseDomainX on PhaseDomain {
  String get label => switch (this) {
        PhaseDomain.motor => 'Movement',
        PhaseDomain.cognitive => 'Thinking',
        PhaseDomain.language => 'Language',
        PhaseDomain.social => 'Social & emotional',
        PhaseDomain.adaptive => 'Everyday skills',
      };

  IconData get icon => switch (this) {
        PhaseDomain.motor => Icons.directions_run_rounded,
        PhaseDomain.cognitive => Icons.psychology_outlined,
        PhaseDomain.language => Icons.chat_bubble_outline_rounded,
        PhaseDomain.social => Icons.favorite_border_rounded,
        PhaseDomain.adaptive => Icons.restaurant_outlined,
      };
}

/// One milestone, at the AAP 75% threshold: most children can do this by the
/// end of this phase. Deliberately NOT "average" — the 2022 revision moved off
/// the 50th percentile precisely so parents act earlier rather than waiting.
class PhaseMilestone {
  const PhaseMilestone(this.domain, this.text);
  final PhaseDomain domain;
  final String text;
}

/// A titled block in the phase's full description.
class PhaseSection {
  const PhaseSection(this.heading, this.paragraphs);
  final String heading;
  final List<String> paragraphs;
}

class AgePhase {
  const AgePhase({
    required this.number,
    required this.name,
    required this.ageLabel,
    required this.startMonth,
    required this.endMonth,
    required this.tagline,
    required this.summary,
    required this.workingOn,
    required this.reassurance,
    required this.milestones,
    required this.sections,
    required this.accent,
    required this.source,
    this.checkpoint = false,
    this.screeningNote,
    this.indianNote,
    this.videoId,
    this.watchCategory,
    this.readCollection,
    this.articleIds = const [],
    this.productIds = const [],
  });

  final int number;

  /// Parent-facing, and deliberately never "Phase 7". A number is a label every
  /// baby shares; a name describes what is actually happening to THIS child.
  final String name;

  /// How the age reads to a parent — "6 months", "13–15 months".
  final String ageLabel;

  /// Inclusive start, exclusive end, in months. Age comes from
  /// ChildProfileStore.ageInMonths so the whole app agrees on one number.
  final double startMonth;
  final double endMonth;

  final String tagline;
  final String summary;
  final List<String> workingOn;

  /// The line that answers "should I be worried?" — every phase has one.
  final String reassurance;

  final List<PhaseMilestone> milestones;
  final List<PhaseSection> sections;
  final Color accent;

  /// Which framework this phase's boundary comes from. Shown in the internal
  /// reference, and the reason we can defend any of this.
  final String source;

  /// True where AAP has a well-child visit checkpoint. Interpolated phases
  /// between checkpoints are honest about being bridges.
  final bool checkpoint;

  /// AAP recommends universal developmental screening at 9, 18 and 30 months,
  /// and autism-specific screening at 18 and 24 months. Where that applies, we
  /// say so — gently, and never as an alarm.
  final String? screeningNote;

  /// Indian-context content: NIS vaccination timing, weaning traditions,
  /// cultural milestones, multilingual language development.
  final String? indianNote;

  final String? videoId;
  final String? watchCategory;
  final String? readCollection;
  final List<String> articleIds;
  final List<String> productIds;

  bool covers(double months) => months >= startMonth && months < endMonth;

  /// 0..1 through THIS phase. Used by the continuous progress bar.
  double progressAt(double months) {
    if (endMonth <= startMonth) return 0;
    final p = (months - startMonth) / (endMonth - startMonth);
    return p.clamp(0.0, 1.0);
  }

  List<PhaseMilestone> inDomain(PhaseDomain d) =>
      milestones.where((m) => m.domain == d).toList();
}

// PHASE ACCENTS - all ParentVeda purple, on purpose.
//
// A five-step palette that shifted the app's colour as the child grew was
// trialled here (purple -> blue -> teal -> amber -> rose, kept below). It was
// rejected: the parenting app is purple, and a hero card turning blue at three
// months reads as a bug, not as a new chapter. Brand colour is not content, so
// it is not something a phase gets to personalise.
//
// Every phase now points at ppPurple. The `accent` field stays because screens
// consume it; changing these five constants is how the palette comes back.
const Color _c1 = ppPurple;
const Color _c2 = ppPurple;
const Color _c3 = ppPurple;
const Color _c4 = ppPurple;
const Color _c5 = ppPurple;

// The rejected growing-child palette, kept for revert:
// const Color _c1 = Color(0xFF7A5AA8);  // purple
// const Color _c2 = Color(0xFF4A7BC8);  // blue
// const Color _c3 = Color(0xFF3E9A8C);  // teal
// const Color _c4 = Color(0xFFC98A2B);  // amber
// const Color _c5 = Color(0xFFCB6F94);  // rose

const List<AgePhase> kPhases = [
  // ---- 1 ------------------------------------------------------------------
  AgePhase(
    number: 1,
    name: 'The fourth trimester',
    ageLabel: '0–4 weeks',
    startMonth: 0,
    endMonth: 1,
    accent: _c1,
    source: 'AAP newborn care guidance',
    tagline: 'Surviving, together',
    summary:
        'Nothing is expected of him yet, and almost nothing should be expected of you. These weeks are about feeding, sleeping in fragments, and the two of you learning each other.',
    workingOn: [
      'Feeding — finding a rhythm, whatever route you are on',
      'Regulating temperature, breathing and digestion outside the womb',
      'Recognising your voice and smell above all others',
    ],
    reassurance:
        'There are no milestones to hit this month. If he is feeding, weeing, and gaining after the first two weeks, he is doing his job.',
    milestones: [
      PhaseMilestone(PhaseDomain.motor, 'Moves both arms and legs, mostly in reflex'),
      PhaseMilestone(PhaseDomain.social, 'Calms when held, spoken to, or fed'),
      PhaseMilestone(PhaseDomain.adaptive, 'Feeds every 2–4 hours, day and night'),
    ],
    sections: [
      PhaseSection('What is actually happening', [
        'He has left an environment that was warm, dark, constant and loud with your heartbeat, for one that is none of those things. Almost everything he does this month is about managing that.',
        'Sleep is chaotic because his body has no day-night rhythm yet — that develops around 6 to 8 weeks. Nothing you do makes it arrive sooner, and nothing you do wrong delays it.',
      ]),
      PhaseSection('What helps', [
        'Skin to skin, as often as you can. It regulates his temperature and heart rate measurably, and it is the one thing that reliably calms both of you.',
        'Accept every offer of help with everything except feeding him. Your job this month is him; everything else can be someone else\'s.',
      ]),
    ],
    indianNote:
        'BCG, the birth dose of Hepatitis B and OPV-0 are given at birth or within the first weeks under the National Immunization Schedule. Traditional oil massage is widely practised and is generally safe on intact skin — avoid the face and never leave oil in the nose or ears.',
  ),

  // ---- 2 ------------------------------------------------------------------
  AgePhase(
    number: 2,
    name: 'The peak, and the first smile',
    ageLabel: '1 month',
    startMonth: 1,
    endMonth: 2,
    accent: _c1,
    source: 'AAP 2-month checkpoint · Wonder Weeks crying-peak insight',
    tagline: 'The hardest few weeks, and then it lifts',
    summary:
        'Crying peaks somewhere around six weeks — this is one of the best-supported findings in infant research. It is also the month a real, deliberate smile usually arrives.',
    workingOn: [
      'Lifting his head briefly during tummy time',
      'Following a face as it moves',
      'Making sounds that are not crying',
    ],
    reassurance:
        'If this is the hardest month, that is not a sign you are doing it badly. Crying genuinely peaks now and genuinely declines after. It is a shape, not a verdict.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Calms when picked up or spoken to'),
      PhaseMilestone(PhaseDomain.social, 'Looks at your face'),
      PhaseMilestone(PhaseDomain.language, 'Makes sounds other than crying'),
      PhaseMilestone(PhaseDomain.motor, 'Holds head up briefly on his tummy'),
      PhaseMilestone(PhaseDomain.cognitive, 'Watches you as you move'),
    ],
    sections: [
      PhaseSection('The six-week peak', [
        'Crying rises from birth, peaks around six weeks, and falls away through three to four months. It happens across cultures and feeding methods, which is why it is one of the few infant-development findings almost nobody disputes.',
        'Knowing the shape does not make the evenings shorter. It does mean that when you are at your worst, you are also close to the turn.',
      ]),
      PhaseSection('The first real smile', [
        'Somewhere in here he will smile at you on purpose — not the fleeting reflex smiles of the first weeks, but one aimed at your face and held. Most parents remember it.',
      ]),
    ],
  ),

  // ---- 3 ------------------------------------------------------------------
  AgePhase(
    number: 3,
    name: 'Coming into focus',
    ageLabel: '2 months',
    startMonth: 2,
    endMonth: 3,
    accent: _c1,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 2-month well visit',
    tagline: 'He knows your face now',
    summary:
        'The first AAP checkpoint. Smiling settles into something reliable, cooing begins, and tummy time starts building the neck strength everything else depends on.',
    workingOn: [
      'Smiling back when you smile',
      'Cooing — long vowel sounds, aah and ooh',
      'Pushing up during tummy time',
    ],
    reassurance:
        'Tummy time is often hated at first. Short and frequent beats long and once, and stopping while he is still content is what makes the next one easier.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Smiles when you talk or smile at him'),
      PhaseMilestone(PhaseDomain.social, 'Looks at your face and holds the look'),
      PhaseMilestone(PhaseDomain.language, 'Makes cooing sounds'),
      PhaseMilestone(PhaseDomain.cognitive, 'Reacts to loud sounds'),
      PhaseMilestone(PhaseDomain.motor, 'Holds his head up when on his tummy'),
      PhaseMilestone(PhaseDomain.motor, 'Opens his hands briefly'),
    ],
    sections: [
      PhaseSection('Why this visit matters', [
        'The two-month well visit is the first full developmental check, and the first big vaccination appointment. Bring anything you have been wondering about, however small it sounds — this is what the visit is for.',
      ]),
    ],
    indianNote:
        'Under the National Immunization Schedule the 6-week doses are due around now: pentavalent-1, OPV-1, rotavirus-1 and PCV-1. A mild fever afterwards is common and expected.',
  ),

  // ---- 4 ------------------------------------------------------------------
  AgePhase(
    number: 4,
    name: 'Hands discovered',
    ageLabel: '3 months',
    startMonth: 3,
    endMonth: 4,
    accent: _c2,
    source: 'AAP/CDC 2022 (between checkpoints)',
    tagline: 'The world gets interesting',
    summary:
        'A bridge month, and a lovely one. He finds his own hands, holds his head steadier, and the evening crying that peaked at six weeks is usually well behind you.',
    workingOn: [
      'Watching his own hands with genuine interest',
      'Holding his head steadier when upright',
      'Chuckling and squealing',
    ],
    reassurance:
        'There is no AAP checkpoint this month. He is between two, and steady progress is all that is being asked.',
    milestones: [
      PhaseMilestone(PhaseDomain.cognitive, 'Looks at his hands with interest'),
      PhaseMilestone(PhaseDomain.social, 'Chuckles when you play with him'),
      PhaseMilestone(PhaseDomain.motor, 'Pushes up on his forearms during tummy time'),
      PhaseMilestone(PhaseDomain.motor, 'Brings his hands to his mouth'),
    ],
    sections: [
      PhaseSection('Hands are the first toy', [
        'He does not know his hands are his yet. Watching them, then working out that HE is moving them, is one of the first pieces of self-knowledge he will ever assemble.',
      ]),
    ],
  ),

  // ---- 5 ------------------------------------------------------------------
  AgePhase(
    number: 5,
    name: 'Reaching out',
    ageLabel: '4 months',
    startMonth: 4,
    endMonth: 5,
    accent: _c2,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 4-month well visit',
    tagline: 'Cause, meet effect',
    summary:
        'A big checkpoint. Head control arrives properly, he laughs out loud, and he begins reaching deliberately for things — the beginning of understanding that his actions change the world.',
    workingOn: [
      'Reaching for a toy and swinging at it',
      'Laughing out loud',
      'Rolling preparation — rocking, pushing, shifting weight',
    ],
    reassurance:
        'Sleep often fragments around now as his sleep matures into adult-like cycles. It reads as a regression and is closer to the opposite. Feeding more by day rarely changes it.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Smiles on his own to get your attention'),
      PhaseMilestone(PhaseDomain.social, 'Chuckles when you try to make him laugh'),
      PhaseMilestone(PhaseDomain.language, 'Makes cooing sounds back at you'),
      PhaseMilestone(PhaseDomain.language, 'Turns his head towards your voice'),
      PhaseMilestone(PhaseDomain.motor, 'Holds his head steady without support'),
      PhaseMilestone(PhaseDomain.motor, 'Holds a toy when you put it in his hand'),
      PhaseMilestone(PhaseDomain.cognitive, 'Opens his mouth when he sees the breast or bottle'),
    ],
    sections: [
      PhaseSection('The four-month sleep change', [
        'His sleep is reorganising from the simple newborn pattern into cycles with lighter and deeper phases — the structure he will keep for life. At the end of each cycle he surfaces close to waking, and if he cannot settle himself back, he calls you.',
        'It is developmental, not a habit you have created, and it passes.',
      ]),
      PhaseSection('The fussy-patch pattern', [
        'You may notice a few days where he seems off — clingier, harder to settle, sleeping worse — and then a new skill appears. That pattern is real and worth knowing, though it does not run to any fixed schedule and no two babies follow the same one.',
      ]),
    ],
    indianNote:
        'The 14-week NIS doses fall around now: pentavalent-3, OPV-3, rotavirus-3, PCV-booster and IPV-2.',
  ),

  // ---- 6 ------------------------------------------------------------------
  AgePhase(
    number: 6,
    name: 'Rolling and grabbing',
    ageLabel: '5 months',
    startMonth: 5,
    endMonth: 6,
    accent: _c2,
    source: 'AAP/CDC 2022 (between checkpoints)',
    tagline: 'Nothing stays where you put it',
    summary:
        'Rolling arrives for many babies this month, and with it the end of leaving him anywhere raised. He grabs with intent now, and everything he grabs goes in his mouth.',
    workingOn: [
      'Rolling, in one direction or both',
      'Grabbing a toy and holding on to it',
      'Mouthing everything — the main way he investigates',
    ],
    reassurance:
        'Some babies never roll much and go straight to sitting and crawling. The route matters far less than that he keeps finding new ways to move.',
    milestones: [
      PhaseMilestone(PhaseDomain.motor, 'Rolls from tummy to back'),
      PhaseMilestone(PhaseDomain.motor, 'Reaches out to grab a toy he wants'),
      PhaseMilestone(PhaseDomain.cognitive, 'Puts things in his mouth to explore them'),
      PhaseMilestone(PhaseDomain.social, 'Recognises familiar people from across a room'),
    ],
    sections: [
      PhaseSection('Mouthing is investigation', [
        'His mouth has far more nerve endings than his hands do at this age, so it is genuinely his best tool for working out what something is. It is not a habit to stop — it is how he learns texture, temperature and shape.',
      ]),
    ],
  ),

  // ---- 7 ------------------------------------------------------------------
  AgePhase(
    number: 7,
    name: 'Sitting up to the world',
    ageLabel: '6 months',
    startMonth: 6,
    endMonth: 7,
    accent: _c3,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 6-month well visit',
    tagline: 'A new view, and the first tastes',
    summary:
        'A major checkpoint. He sits with support, laughs properly, blows raspberries, and — the big one — food begins.',
    workingOn: [
      'Sitting propped, wobbling but upright',
      'First tastes of solid food alongside milk',
      'Taking turns making sounds with you',
    ],
    reassurance:
        'Food before one is about learning to eat, not about calories. A teaspoon taken with interest beats a bowl pushed in, and milk still supplies almost all of it.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Knows familiar people'),
      PhaseMilestone(PhaseDomain.social, 'Likes to look at himself in a mirror'),
      PhaseMilestone(PhaseDomain.social, 'Laughs out loud'),
      PhaseMilestone(PhaseDomain.language, 'Takes turns making sounds with you'),
      PhaseMilestone(PhaseDomain.language, 'Blows raspberries and squeals'),
      PhaseMilestone(PhaseDomain.motor, 'Rolls from tummy to back'),
      PhaseMilestone(PhaseDomain.motor, 'Leans on his hands to support himself sitting'),
      PhaseMilestone(PhaseDomain.adaptive, 'Closes his lips to show he does not want more'),
    ],
    sections: [
      PhaseSection('Starting solids', [
        'Iron is the reason food matters now. He was born with stores that carry him to about six months, and they are running down at exactly the age his brain needs iron most — which is why first foods should lead with iron rather than fruit.',
        'One new single food at a time, a few days apart, so a reaction is traceable. Textures should progress faster than most parents are told: lumps by eight months matter.',
      ]),
    ],
    indianNote:
        'Annaprashan — the first-rice ceremony — traditionally falls around now and lines up well with the WHO guidance to start complementary foods at six months. Ragi, moong dal and well-mashed rice with a little ghee are excellent first foods. No salt, no sugar, and no honey before one year.',
  ),

  // ---- 8 ------------------------------------------------------------------
  AgePhase(
    number: 8,
    name: 'Sitting steady, babbling loud',
    ageLabel: '7 months',
    startMonth: 7,
    endMonth: 8,
    accent: _c3,
    source: 'AAP/CDC 2022 (between checkpoints) · WHO weaning guidance',
    tagline: 'Consonants arrive',
    summary:
        'He sits without propping for longer stretches, and his sounds gain consonants — the babbling that will eventually become words.',
    workingOn: [
      'Sitting unsupported, hands free to play',
      'Babbling with consonants — ba, da, ma',
      'Passing a toy from one hand to the other',
    ],
    reassurance:
        '"Mama" and "dada" this early are usually sound practice rather than names. They become names in the months ahead, and it does not mean he loves you less in the meantime.',
    milestones: [
      PhaseMilestone(PhaseDomain.motor, 'Sits without support'),
      PhaseMilestone(PhaseDomain.motor, 'Moves things from one hand to the other'),
      PhaseMilestone(PhaseDomain.language, 'Makes sounds like ba, da and ma'),
      PhaseMilestone(PhaseDomain.cognitive, 'Bangs two things together'),
    ],
    sections: [
      PhaseSection('Babble is rehearsal', [
        'He is practising the physical shapes of speech — tongue, lips, breath — long before any of it means anything. Answering his babble as though it were conversation is the single most useful thing you can do for his language.',
      ]),
    ],
    indianNote:
        'Most Indian children hear two to four languages from birth. Multilingual exposure is NOT a cause of speech delay — total words heard across all languages is what counts, and mixing them in one sentence is normal and healthy.',
  ),

  // ---- 9 ------------------------------------------------------------------
  AgePhase(
    number: 9,
    name: 'On the move, and missing you',
    ageLabel: '8 months',
    startMonth: 8,
    endMonth: 9,
    accent: _c3,
    source: 'AAP/CDC 2022 (between checkpoints)',
    tagline: 'He knows you exist when you leave',
    summary:
        'Object permanence is arriving — he understands that things still exist when hidden, including you. That is why separation anxiety usually starts now, and why peekaboo suddenly delights him.',
    workingOn: [
      'Getting mobile — shuffling, commando crawling, or proper crawling',
      'Looking for a toy he has watched you hide',
      'Protesting when you leave the room',
    ],
    reassurance:
        'Separation anxiety is a developmental achievement wearing an exhausting disguise. It means he has worked out that you continue to exist elsewhere — and that he would rather you existed here.',
    milestones: [
      PhaseMilestone(PhaseDomain.cognitive, 'Looks for a toy he has seen you hide'),
      PhaseMilestone(PhaseDomain.social, 'Reacts when you leave the room'),
      PhaseMilestone(PhaseDomain.motor, 'Gets himself into a sitting position'),
      PhaseMilestone(PhaseDomain.adaptive, 'Uses his fingers to rake food towards himself'),
    ],
    sections: [
      PhaseSection('Why peekaboo works now', [
        'Before object permanence, a hidden face is simply gone and there is nothing funny about it. Once he knows you are still there behind your hands, the reappearance becomes a joke — and he will want it a hundred times.',
      ]),
    ],
  ),

  // ---- 10 -----------------------------------------------------------------
  AgePhase(
    number: 10,
    name: 'The first screening',
    ageLabel: '9 months',
    startMonth: 9,
    endMonth: 10,
    accent: _c3,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 9-month visit + first universal screening point',
    tagline: 'A checkpoint that looks a little wider',
    summary:
        'The 9-month visit is the first at which AAP recommends a formal developmental screening for every child — not because anything is suspected, but because early is better than late.',
    workingOn: [
      'Crawling, and pulling up to stand for some',
      'Responding to his own name',
      'Stranger wariness — a normal, healthy sign',
    ],
    reassurance:
        'Screening at this visit is universal. It is not triggered by a concern, and being screened says nothing about your child.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Is shy, clingy or fearful around strangers'),
      PhaseMilestone(PhaseDomain.social, 'Shows several facial expressions'),
      PhaseMilestone(PhaseDomain.social, 'Smiles or laughs at peekaboo'),
      PhaseMilestone(PhaseDomain.language, 'Looks when you call his name'),
      PhaseMilestone(PhaseDomain.language, 'Makes sounds like mamamama and babababa'),
      PhaseMilestone(PhaseDomain.motor, 'Sits without support'),
      PhaseMilestone(PhaseDomain.motor, 'Moves things from one hand to the other'),
      PhaseMilestone(PhaseDomain.cognitive, 'Looks for objects dropped out of sight'),
    ],
    sections: [
      PhaseSection('What a screening actually is', [
        'A short structured questionnaire, usually filled in by you, about what he is doing day to day. It takes a few minutes and it is designed to catch things early enough to help easily.',
      ]),
    ],
    screeningNote:
        'AAP recommends a developmental screening for every child at this visit. Worth asking your paediatrician about it if it is not offered.',
    indianNote:
        'The 9-month NIS doses are due: measles-rubella-1, JE-1 where applicable, and vitamin A-1.',
  ),

  // ---- 11 -----------------------------------------------------------------
  AgePhase(
    number: 11,
    name: 'Finger and thumb',
    ageLabel: '10 months',
    startMonth: 10,
    endMonth: 11,
    accent: _c4,
    source: 'AAP/CDC 2022 (between checkpoints)',
    tagline: 'Small things, picked up properly',
    summary:
        'The pincer grasp arrives — thumb and forefinger together — and with it real self-feeding, and an ability to pick up anything small he finds on the floor.',
    workingOn: [
      'Picking up small pieces with finger and thumb',
      'Pointing at things he wants',
      'Pulling up on furniture',
    ],
    reassurance:
        'This is the month to get down at his eye level and look at your floor. What he can now pick up, he can now choke on.',
    milestones: [
      PhaseMilestone(PhaseDomain.motor, 'Picks things up between thumb and forefinger'),
      PhaseMilestone(PhaseDomain.motor, 'Pulls up to stand'),
      PhaseMilestone(PhaseDomain.language, 'Starts to point at things'),
      PhaseMilestone(PhaseDomain.adaptive, 'Feeds himself soft finger foods'),
    ],
    sections: [
      PhaseSection('Pointing is language', [
        'Pointing to share something — not just to demand it — is one of the strongest early language signals there is. It means he wants you to see what he sees, which is the whole basis of conversation.',
      ]),
    ],
  ),

  // ---- 12 -----------------------------------------------------------------
  AgePhase(
    number: 12,
    name: 'Cruising',
    ageLabel: '11 months',
    startMonth: 11,
    endMonth: 12,
    accent: _c4,
    source: 'AAP/CDC 2022 (between checkpoints)',
    tagline: 'Upright, holding on',
    summary:
        'He moves along the furniture on his feet, and communicates with gesture long before words — waving, reaching up, pushing away.',
    workingOn: [
      'Cruising sideways along furniture',
      'Waving, reaching up to be lifted',
      'A first word, for some',
    ],
    reassurance:
        'First words land anywhere from about nine months to well past fifteen. Gestures matter more than words right now — a child who communicates well without words is communicating well.',
    milestones: [
      PhaseMilestone(PhaseDomain.motor, 'Walks holding on to furniture'),
      PhaseMilestone(PhaseDomain.language, 'Uses gestures — waving, lifting arms'),
      PhaseMilestone(PhaseDomain.cognitive, 'Puts something into a container'),
      PhaseMilestone(PhaseDomain.social, 'Plays games like pat-a-cake with you'),
    ],
    sections: [
      PhaseSection('Why not to rush walking', [
        'Cruising builds the balance and hip strength that independent walking needs. Walkers and jumpers do not speed it up and can delay it — floor time and furniture do the work.',
      ]),
    ],
  ),

  // ---- 13 -----------------------------------------------------------------
  AgePhase(
    number: 13,
    name: 'One year old',
    ageLabel: '12 months',
    startMonth: 12,
    endMonth: 13,
    accent: _c4,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 12-month well visit',
    tagline: 'A whole year of him',
    summary:
        'The first birthday checkpoint. First steps for some, one to three words for many, and a real understanding of "no".',
    workingOn: [
      'Standing alone, and first steps for some',
      'One to three words used meaningfully',
      'Drinking from an open cup',
    ],
    reassurance:
        'Walking at twelve months and walking at seventeen months are both entirely normal. Do mention it to your doctor if he is not pulling to stand at all.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Plays games with you, like pat-a-cake'),
      PhaseMilestone(PhaseDomain.language, 'Waves bye-bye'),
      PhaseMilestone(PhaseDomain.language, 'Calls a parent mama or dada, meaning it'),
      PhaseMilestone(PhaseDomain.language, 'Understands "no"'),
      PhaseMilestone(PhaseDomain.cognitive, 'Looks for things he has watched you hide'),
      PhaseMilestone(PhaseDomain.motor, 'Pulls up to stand and walks holding furniture'),
      PhaseMilestone(PhaseDomain.motor, 'Picks things up between thumb and forefinger'),
      PhaseMilestone(PhaseDomain.adaptive, 'Drinks from a cup without a lid, with help'),
    ],
    sections: [
      PhaseSection('Milk changes now', [
        'Formula is no longer needed and whole cow milk is fine — but cap it around 500 ml a day. More than that crowds out iron-rich food, and toddler iron deficiency is common in India for exactly this reason.',
      ]),
    ],
    indianNote:
        'The 12-month NIS window covers Hepatitis A and, in many private schedules, the first varicella dose. Mundan is traditionally performed anywhere between one and three years.',
  ),

  // ---- 14 -----------------------------------------------------------------
  AgePhase(
    number: 14,
    name: 'Walking and naming',
    ageLabel: '13–15 months',
    startMonth: 13,
    endMonth: 16,
    accent: _c4,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 15-month visit (added in the 2022 revision)',
    tagline: 'The world at walking pace',
    summary:
        'A checkpoint that did not exist before 2022. Walking becomes confident, vocabulary starts building, and pretend play appears — the first sign of imagination.',
    workingOn: [
      'Walking without holding on',
      'A handful of words beyond mama and dada',
      'Copying you — sweeping, stirring, phoning',
    ],
    reassurance:
        'The phase widens to three months here on purpose. Normal ranges genuinely spread out at this age, and monthly comparison stops being useful.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Copies other children'),
      PhaseMilestone(PhaseDomain.social, 'Shows you an object he likes'),
      PhaseMilestone(PhaseDomain.social, 'Claps when excited'),
      PhaseMilestone(PhaseDomain.language, 'Tries to say one or two words besides mama and dada'),
      PhaseMilestone(PhaseDomain.language, 'Looks at a familiar object when you name it'),
      PhaseMilestone(PhaseDomain.language, 'Points to ask for something'),
      PhaseMilestone(PhaseDomain.motor, 'Takes a few steps on his own'),
      PhaseMilestone(PhaseDomain.motor, 'Stacks at least two small objects'),
      PhaseMilestone(PhaseDomain.adaptive, 'Uses his fingers to feed himself'),
    ],
    sections: [
      PhaseSection('Imitation is the engine', [
        'Copying you doing real things — wiping, stirring, sweeping — teaches sequences he could not learn from a toy version. A safe real object beats a plastic one almost every time.',
      ]),
    ],
  ),

  // ---- 15 -----------------------------------------------------------------
  AgePhase(
    number: 15,
    name: 'Words gathering',
    ageLabel: '16–18 months',
    startMonth: 16,
    endMonth: 19,
    accent: _c5,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 18-month visit + universal autism screening point',
    tagline: 'Ten words, then twenty',
    summary:
        'Vocabulary builds to somewhere around ten to twenty-five words, he walks confidently, and he begins following simple instructions without you gesturing.',
    workingOn: [
      'Three or more words beyond mama and dada',
      'Following a one-step instruction without a gesture',
      'Scribbling, and trying a spoon',
    ],
    reassurance:
        'Vocabulary counts vary enormously and late talkers frequently catch up completely. What matters more is whether he is communicating at all — pointing, gesturing, bringing you things.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Moves away from you but checks you are still near'),
      PhaseMilestone(PhaseDomain.social, 'Points to show you something interesting'),
      PhaseMilestone(PhaseDomain.social, 'Helps you dress him'),
      PhaseMilestone(PhaseDomain.language, 'Tries to say three or more words besides mama and dada'),
      PhaseMilestone(PhaseDomain.language, 'Follows one-step directions without a gesture'),
      PhaseMilestone(PhaseDomain.cognitive, 'Copies you doing chores'),
      PhaseMilestone(PhaseDomain.motor, 'Walks without holding on'),
      PhaseMilestone(PhaseDomain.motor, 'Scribbles'),
      PhaseMilestone(PhaseDomain.adaptive, 'Tries to use a spoon'),
    ],
    sections: [
      PhaseSection('The 18-month screening', [
        'AAP recommends both a general developmental screening and an autism-specific screening at this visit, for every child. Universal screening exists so that support, if it is ever needed, starts early — when it works best.',
      ]),
    ],
    screeningNote:
        'AAP recommends both developmental and autism-specific screening at this visit, for every child. Ask if it is not offered.',
  ),

  // ---- 16 -----------------------------------------------------------------
  AgePhase(
    number: 16,
    name: 'Two words together',
    ageLabel: '19–24 months',
    startMonth: 19,
    endMonth: 25,
    accent: _c5,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 24-month visit + second autism screening point',
    tagline: 'Sentences begin',
    summary:
        'Two-word phrases arrive — "more milk", "daddy gone" — and with them running, kicking, and playing alongside other children.',
    workingOn: [
      'Putting two words together',
      'Running, and kicking a ball',
      'Playing near other children',
    ],
    reassurance:
        'Playing NEAR other children rather than with them is exactly right at this age. Sharing is a skill that arrives much later, and its absence now is not a character flaw.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Notices when others are hurt or upset'),
      PhaseMilestone(PhaseDomain.social, 'Looks at your face to see how to react'),
      PhaseMilestone(PhaseDomain.language, 'Says at least two words together'),
      PhaseMilestone(PhaseDomain.language, 'Points to at least two body parts'),
      PhaseMilestone(PhaseDomain.cognitive, 'Plays with more than one toy at the same time'),
      PhaseMilestone(PhaseDomain.cognitive, 'Tries to use switches and knobs'),
      PhaseMilestone(PhaseDomain.motor, 'Runs, and kicks a ball'),
      PhaseMilestone(PhaseDomain.motor, 'Walks up a few stairs'),
      PhaseMilestone(PhaseDomain.adaptive, 'Eats with a spoon'),
    ],
    sections: [
      PhaseSection('Tantrums, and why', [
        'He now knows what he wants and can picture it clearly, but has almost none of the language to negotiate for it and none of the brain machinery to manage the frustration. That gap is the tantrum. It closes with language, not with discipline.',
      ]),
    ],
    screeningNote:
        'AAP recommends a second autism-specific screening at this visit.',
  ),

  // ---- 17 -----------------------------------------------------------------
  AgePhase(
    number: 17,
    name: 'Real conversation',
    ageLabel: '25–30 months',
    startMonth: 25,
    endMonth: 31,
    accent: _c5,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 30-month visit (added in 2022) + screening point',
    tagline: 'Fifty words, and opinions',
    summary:
        'Around fifty words, sentences with an action word in them, pretend play in earnest, and the first real readiness signals for potty training.',
    workingOn: [
      'Sentences with a doing-word — "mama go", "want juice"',
      'Pretend play — feeding a doll, driving a block',
      'Following a two-step instruction',
    ],
    reassurance:
        'Potty readiness is about his signals, not his age or anyone else\'s child. Staying dry for a couple of hours and telling you afterwards are the ones that matter.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Plays next to other children, sometimes with them'),
      PhaseMilestone(PhaseDomain.social, 'Follows simple routines'),
      PhaseMilestone(PhaseDomain.language, 'Says about fifty words'),
      PhaseMilestone(PhaseDomain.language, 'Says two or more words with one action word'),
      PhaseMilestone(PhaseDomain.language, 'Uses words like I, me and we'),
      PhaseMilestone(PhaseDomain.cognitive, 'Uses things to pretend'),
      PhaseMilestone(PhaseDomain.cognitive, 'Follows two-step instructions'),
      PhaseMilestone(PhaseDomain.motor, 'Jumps off the ground with both feet'),
      PhaseMilestone(PhaseDomain.adaptive, 'Takes some clothes off by himself'),
    ],
    sections: [
      PhaseSection('The 30-month visit', [
        'This checkpoint was added in the 2022 revision because the gap between two and three years was too wide to leave unwatched. It carries a universal developmental screening.',
      ]),
    ],
    screeningNote:
        'AAP recommends a developmental screening at this visit, for every child.',
  ),

  // ---- 18 -----------------------------------------------------------------
  //  ⚠ FLAGGED FOR REVIEW. The source document lists 19 phases and leaves
  //  31–35 months uncovered: row 17 ends at the 30-month checkpoint and row 18
  //  begins at 3 years. Rather than silently widen a neighbour, this fills the
  //  gap explicitly. It is the only boundary here the source does not sanction,
  //  and there is no AAP checkpoint inside it.
  AgePhase(
    number: 18,
    name: 'Nearly three',
    ageLabel: '31–35 months',
    startMonth: 31,
    endMonth: 36,
    accent: _c1,
    source: 'Bridge phase — no AAP checkpoint (ParentVeda, flagged for review)',
    tagline: 'Between the toddler and the child',
    summary:
        'No checkpoint falls here. Language consolidates fast, independence pushes hard, and the tantrums of two begin — slowly — to give way to negotiation.',
    workingOn: [
      'Longer sentences, and asking questions',
      'Dressing himself, badly and insistently',
      'Playing with other children rather than beside them',
    ],
    reassurance:
        'There is no formal checkpoint in these months. If anything has been on your mind since the 30-month visit, it does not need to wait for the three-year one.',
    milestones: [
      PhaseMilestone(PhaseDomain.language, 'Strings several words into a clear request'),
      PhaseMilestone(PhaseDomain.language, 'Asks simple questions'),
      PhaseMilestone(PhaseDomain.social, 'Begins genuinely playing with other children'),
      PhaseMilestone(PhaseDomain.cognitive, 'Sorts objects by shape or colour'),
      PhaseMilestone(PhaseDomain.adaptive, 'Pulls on simple clothes without help'),
    ],
    sections: [
      PhaseSection('Independence, loudly', [
        '"I do it" belongs to this stretch. Letting him do the slow, imperfect version of things builds the competence that makes the next year easier — and it is almost always faster than the argument.',
      ]),
    ],
  ),

  // ---- 19 -----------------------------------------------------------------
  AgePhase(
    number: 19,
    name: 'The talking years',
    ageLabel: '3–4 years',
    startMonth: 36,
    endMonth: 48,
    accent: _c2,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 4-year visit',
    tagline: 'Conversations, and questions without end',
    summary:
        'Real back-and-forth conversation, endless why, and the beginnings of the social skill that school will ask for.',
    workingOn: [
      'Conversations with several exchanges',
      'Playing pretend with other children',
      'Drawing, and holding a crayon properly',
    ],
    reassurance:
        'Strangers should understand most of what he says by four. If they routinely cannot, that is worth raising — not a reason to panic, but worth raising.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Calms within about ten minutes after you leave'),
      PhaseMilestone(PhaseDomain.social, 'Notices other children and joins them'),
      PhaseMilestone(PhaseDomain.social, 'Comforts others who are hurt or sad'),
      PhaseMilestone(PhaseDomain.language, 'Has a conversation with two or more back-and-forths'),
      PhaseMilestone(PhaseDomain.language, 'Asks who, what, where and why'),
      PhaseMilestone(PhaseDomain.language, 'Says his first name when asked'),
      PhaseMilestone(PhaseDomain.cognitive, 'Says what is happening in a picture'),
      PhaseMilestone(PhaseDomain.motor, 'Draws a circle, and a person with a few body parts'),
      PhaseMilestone(PhaseDomain.adaptive, 'Uses a fork, and puts on some clothes'),
    ],
    sections: [
      PhaseSection('Why the questions', [
        'The why phase is not testing your patience — he has just worked out that things have causes, and that you might know them. Answering shortly and honestly, including "I don\'t know, shall we find out", does more than a perfect answer.',
      ]),
    ],
    indianNote:
        'Preschool commonly begins in these years in India. Children fluent in a mother tongue at home pick up the school language faster, not slower — keeping the home language strong is an advantage, not a competing demand.',
  ),

  // ---- 20 -----------------------------------------------------------------
  AgePhase(
    number: 20,
    name: 'Getting ready for school',
    ageLabel: '4–5 years',
    startMonth: 48,
    endMonth: 60,
    accent: _c3,
    checkpoint: true,
    source: 'AAP/CDC 2022 — 5-year visit',
    tagline: 'Rules, stories, and letters',
    summary:
        'School readiness: taking turns, telling a story with a beginning and an end, counting, and the fine motor control that writing needs.',
    workingOn: [
      'Following rules and taking turns in games',
      'Telling a story with at least two events',
      'Writing some letters of his name',
    ],
    reassurance:
        'Readiness for school is far more about attention, turn-taking and separating from you calmly than about letters and numbers. Academics catch up quickly; the rest takes longer to build.',
    milestones: [
      PhaseMilestone(PhaseDomain.social, 'Follows rules or takes turns in games'),
      PhaseMilestone(PhaseDomain.social, 'Sings, dances or performs for you'),
      PhaseMilestone(PhaseDomain.language, 'Tells a story with at least two events'),
      PhaseMilestone(PhaseDomain.language, 'Keeps a conversation going over several exchanges'),
      PhaseMilestone(PhaseDomain.cognitive, 'Counts to ten'),
      PhaseMilestone(PhaseDomain.cognitive, 'Pays attention for five to ten minutes'),
      PhaseMilestone(PhaseDomain.motor, 'Writes some letters of his name'),
      PhaseMilestone(PhaseDomain.motor, 'Hops on one foot'),
      PhaseMilestone(PhaseDomain.adaptive, 'Buttons some buttons'),
    ],
    sections: [
      PhaseSection('What schools actually look for', [
        'Sitting for a short activity, following a two-step instruction, managing the toilet independently, and separating from you without distress. Letters and counting are the easy part.',
      ]),
    ],
  ),
];

// ---- queries ----------------------------------------------------------------

/// Index of the phase covering [months]. Clamps at both ends, so a newborn and
/// a six-year-old both land somewhere sensible.
int phaseIndexForMonths(double months) {
  for (var i = 0; i < kPhases.length; i++) {
    if (kPhases[i].covers(months)) return i;
  }
  return months < kPhases.first.startMonth ? 0 : kPhases.length - 1;
}

AgePhase currentPhase([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  return kPhases[phaseIndexForMonths(c.ageInMonths.toDouble())];
}

AgePhase? nextPhase([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  final i = phaseIndexForMonths(c.ageInMonths.toDouble());
  return i + 1 < kPhases.length ? kPhases[i + 1] : null;
}

AgePhase? phaseByNumber(int n) {
  for (final p in kPhases) {
    if (p.number == n) return p;
  }
  return null;
}

/// 0..1 across the WHOLE 0–5 year journey — what the continuous progress bar
/// draws. Deliberately not "phase 7 of 20": the phases are wildly uneven (one
/// month against twelve), so equal-weighted stops would misrepresent where a
/// child actually is.
double journeyProgress([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  final total = kPhases.last.endMonth;
  return (c.ageInMonths / total).clamp(0.0, 1.0);
}

/// The phases either side of the current one, for the compact "where he is"
/// strip. Returns (previous, current, next) — previous/next may be null.
(AgePhase?, AgePhase, AgePhase?) phaseWindow([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  final i = phaseIndexForMonths(c.ageInMonths.toDouble());
  return (
    i > 0 ? kPhases[i - 1] : null,
    kPhases[i],
    i + 1 < kPhases.length ? kPhases[i + 1] : null,
  );
}

// ---- content routing --------------------------------------------------------
//  Which existing Watch category and Read collection best suit a phase.
//
//  Derived from age rather than hand-assigned per phase, deliberately: with
//  twenty phases, twenty hardcoded pairs would drift out of step with the
//  catalogue the first time a category was renamed. This picks what a parent at
//  that age is most likely to be searching for anyway.
//
//  Both fall back to something real, so a rail never renders empty because a
//  phase was missed.

/// The Watch category most useful at this phase.
String watchCategoryForPhase(AgePhase p) {
  if (p.startMonth < 2) return 'Sleep'; // newborn: sleep and survival
  if (p.startMonth < 4) return 'Brain Development';
  if (p.startMonth < 6) return 'Sleep'; // the 4-month sleep change
  if (p.startMonth < 9) return 'Nutrition'; // solids begin
  if (p.startMonth < 12) return 'Brain Development';
  if (p.startMonth < 19) return 'Language'; // words arriving
  if (p.startMonth < 31) return 'Behaviour'; // tantrums, limits
  return 'Play';
}

/// The Read collection most useful at this phase.
String readCollectionForPhase(AgePhase p) {
  if (p.startMonth < 2) return 'parent'; // the fourth trimester is about HER too
  if (p.startMonth < 4) return 'sleep';
  if (p.startMonth < 6) return 'sleep';
  if (p.startMonth < 9) return 'feeding';
  if (p.startMonth < 13) return 'brain';
  if (p.startMonth < 19) return 'brain';
  if (p.startMonth < 31) return 'behaviour';
  return 'play';
}
