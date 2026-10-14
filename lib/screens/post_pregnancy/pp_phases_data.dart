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

import '../../data/pp_phase_docs.dart';
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

  /// This phase with every child pronoun filled for [c] (see `kPhases`).
  AgePhase filledFor(ChildProfileStore c) {
    String f(String t) => ppFillChild(t, c);
    return AgePhase(
      number: number,
      name: f(name),
      ageLabel: ageLabel,
      startMonth: startMonth,
      endMonth: endMonth,
      tagline: f(tagline),
      summary: f(summary),
      workingOn: [for (final w in workingOn) f(w)],
      reassurance: f(reassurance),
      milestones: [for (final m in milestones) PhaseMilestone(m.domain, f(m.text))],
      sections: [for (final sec in sections) PhaseSection(f(sec.heading), [for (final x in sec.paragraphs) f(x)])],
      accent: accent,
      source: source,
      checkpoint: checkpoint,
      screeningNote: screeningNote == null ? null : f(screeningNote!),
      indianNote: indianNote == null ? null : f(indianNote!),
      videoId: videoId,
      watchCategory: watchCategory,
      readCollection: readCollection,
      articleIds: articleIds,
      productIds: productIds,
    );
  }

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

/// ⚠️ ABOUT HER CHILD, NOT "HIM" (gap analysis P1, Behind · Age by age,
/// 2026-10-07): "A girl's mother is told about 'him' on every age page ...
/// fill it from the child's profile; use the child's name where it reads
/// naturally. If sex is not given, use the name or 'your baby'."
///
/// The phases are AUTHORED with he/him/his for the child (every one in this
/// file means the child; there is no she or her and no father in them, which
/// is what makes a word swap safe here and NOT on the door pages). Every screen
/// reads `kPhases`, `currentPhase()`, `nextPhase()`, `phaseByNumber()` or
/// `phaseWindow()`, so the swap happens once, below: `kPhases` is now the
/// authored list filled for the active child, cached until the name or sex
/// changes. `kPhasesAuthored` is the text as written.
List<AgePhase> get kPhases {
  final c = ChildProfileStore.instance;
  final key = '${c.sexGiven}|${c.isBoy}|${c.name}';
  if (key != _phasesKey) {
    _phasesKey = key;
    // Was: [for (final ph in kPhasesAuthored) ph.filledFor(c)]. The phase
    // docs now win where they exist (see `ppPhaseWithDoc`).
    _phasesFilled = [for (final ph in kPhasesAuthored) ppPhaseWithDoc(ph).filledFor(c)];
  }
  return _phasesFilled!;
}

/// The doc domain as the AAP domain the older screens group by.
PhaseDomain ppDocDomainAsPhase(PpDocDomain d) => switch (d) {
      PpDocDomain.brain => PhaseDomain.cognitive,
      PpDocDomain.physical => PhaseDomain.motor,
      PpDocDomain.language => PhaseDomain.language,
      PpDocDomain.emotional => PhaseDomain.social,
      PpDocDomain.nutrition => PhaseDomain.adaptive,
    };

/// [p] with its phase doc laid over it, or [p] unchanged when it has none.
///
/// ⚠️ THE DOC IS THE SOURCE OF TRUTH (the user, 2026-10-13). Phases 1–15 have
/// a doc (lib/data/pp_phase_docs.dart). Laying it over HERE, once, rather
/// than in each screen means the hero, the phase map, the phase page, the
/// at-a-glance card and the age page all say the same thing:
///
///   * name        — the doc's ("The Settling In", was "The fourth trimester")
///   * summary     — the hero's opening paragraph
///   * workingOn   — the Living Through This Phase card titles
///   * milestones  — the Child Snapshot, one per domain
///   * sections    — the authored "Feeding now" and "Sleep now" (the docs
///                   give no numbers, and `PpAtThisAge` shows those), then
///                   "When to call the doctor" as the doc's lines
///
/// ⚠️ THE DOCS ARE THE ONLY PHASE TEXT (the user, 2026-10-14): "I don't want
/// those old leaps and phases anywhere in the app wired." So nothing authored
/// passes through any more: no tagline, reassurance, Feeding now / Sleep now,
/// checkpoint, screening or India note. What a doc phase keeps from the
/// authored list is structure only (number, age range, colour, source) and
/// its links to other content (video, reads, products). Screens draw nothing
/// for an empty field. A phase with no doc yet (16–20 on 2026-10-14) keeps
/// its name and age and says its guide is being written; its doc lands with
/// `tools/phase_pages/docx_to_dart.py` and shows here with no other change.
/// The authored text is untouched in `kPhasesAuthored`, so a revert is this
/// one function.
AgePhase ppPhaseWithDoc(AgePhase p) {
  final doc = ppPhaseDocFor(p.number);
  // Was: `if (doc == null) return p;` (the authored phase in full).
  if (doc == null) return _phaseAwaitingDoc(p);
  // Kept for revert: the authored Feeding now / Sleep now rode along.
  // final keep = {'feeding now', 'sleep now'};
  return AgePhase(
    number: p.number,
    name: doc.name,
    ageLabel: p.ageLabel,
    startMonth: p.startMonth,
    endMonth: p.endMonth,
    tagline: '', // was p.tagline
    summary: doc.hero.first,
    workingOn: [for (final c in doc.living) c.title],
    reassurance: '', // was p.reassurance
    milestones: [for (final s in doc.snapshot) PhaseMilestone(ppDocDomainAsPhase(s.domain), s.title)],
    sections: [
      // for (final s in p.sections)
      //   if (keep.contains(s.heading.toLowerCase())) s,
      PhaseSection('When to call the doctor', doc.doctor),
    ],
    accent: p.accent,
    source: p.source,
    // checkpoint: p.checkpoint,
    // screeningNote: p.screeningNote,
    // indianNote: p.indianNote,
    videoId: p.videoId,
    watchCategory: p.watchCategory,
    readCollection: p.readCollection,
    articleIds: p.articleIds,
    productIds: p.productIds,
  );
}

/// The line a phase with no doc yet shows in place of its text.
const String kPhaseGuideComing = "This phase's guide is being written.";

/// [p] before its doc arrives: name, age and the "being written" line. No
/// authored milestones, sections or notes (the user, 2026-10-14).
AgePhase _phaseAwaitingDoc(AgePhase p) => AgePhase(
      number: p.number,
      name: p.name,
      ageLabel: p.ageLabel,
      startMonth: p.startMonth,
      endMonth: p.endMonth,
      tagline: '',
      summary: kPhaseGuideComing,
      workingOn: const [],
      reassurance: '',
      milestones: const [],
      // ⚠️ THE ONE AUTHORED LINE THAT STAYS: when to call the doctor. A
      // child of 19 months to 5 years must never lose the route to a doctor
      // while the doc is being written; the doc's own lines replace these.
      sections: [
        for (final s in p.sections)
          if (s.heading.toLowerCase() == 'when to call the doctor') s,
      ],
      accent: p.accent,
      source: p.source,
      videoId: p.videoId,
      watchCategory: p.watchCategory,
      readCollection: p.readCollection,
      articleIds: p.articleIds,
      productIds: p.productIds,
    );

/// Whether [p] (as `kPhases` holds it) is still waiting for its doc.
bool phaseAwaitingDoc(AgePhase p) => ppPhaseDocFor(p.number) == null;

String? _phasesKey;
List<AgePhase>? _phasesFilled;

final RegExp _kChildPronoun = RegExp(r"\b(he|him|his|himself)\b", caseSensitive: false);

/// One authored sentence, about this child: he/him/his become she/her/her for
/// a girl, and the name (or "your baby") when the parent did not say.
String ppFillChild(String text, [ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  if (c.sexGiven && c.isBoy) return text;
  return text.replaceAllMapped(_kChildPronoun, (m) {
    final w = m[0]!;
    final low = w.toLowerCase();
    // Keep the author's casing: "he", "He", or "HE" for emphasis.
    final allCaps = w.length > 1 && w == w.toUpperCase();
    final cap = w[0] == w[0].toUpperCase();
    String keep(String r) => allCaps ? r.toUpperCase() : (cap ? r[0].toUpperCase() + r.substring(1) : r);
    if (c.sexGiven) {
      // A girl.
      return keep(switch (low) { 'he' => 'she', 'him' => 'her', 'his' => 'her', _ => 'herself' });
    }
    final r = switch (low) {
      'he' => c.they,
      'him' => c.them,
      'his' => c.their,
      _ => 'themselves',
    };
    return keep(r);
  });
}

const List<AgePhase> kPhasesAuthored = [
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Feed whenever he shows hunger: rooting, sucking his hands, turning towards you. That is usually 8 to 12 times in 24 hours, and some feeds will come close together in the evening. Nothing but breast milk or formula, not even water or herbal drops.',
      ]),
      PhaseSection('Sleep now', [
        'Newborns sleep 14 to 17 hours a day in short stretches, with no difference between day and night yet. On his back, in his own cot or crib beside your bed, with nothing soft around him.',
      ]),
      PhaseSection('Play that helps now', [
        'Your face is his favourite thing. Hold him about 20 to 30 cm from you and talk, sing and smile. Short bursts of tummy time on your chest count from the first days.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Support his head every time you lift him. Never leave him on a bed or sofa. Ask everyone to wash their hands before holding him, and keep sick visitors away.',
      ]),
      PhaseSection('When to call the doctor', [
        'Any fever of 38 C or more, poor feeding, fewer than six wet nappies a day after day five, yellow skin spreading to the tummy or legs, fast or noisy breathing, or a baby who is unusually floppy or hard to wake. Go the same day.',
      ]),
      PhaseSection('And you', [
        'You are healing too. Eat, drink water at every feed, sleep when you can, and let others do the rest. Feeling weepy in the first two weeks is common; feeling hopeless or unable to cope is worth telling your doctor.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Growth spurts around three and six weeks bring days of almost constant feeding. That is him building your supply, not a sign your milk is not enough. Wet nappies and weight gain tell you he is getting enough.',
      ]),
      PhaseSection('Sleep now', [
        'Still short stretches, but he may start to have one longer sleep. Daylight and noise in the day, dim and quiet at night, help his body clock begin to settle.',
      ]),
      PhaseSection('Play that helps now', [
        'Talk to him through the day, describing what you are doing. Copy his little sounds back. Show him high-contrast pictures, black and white, and let him follow a rattle with his eyes.',
      ]),
      PhaseSection('Keeping him safe now', [
        'The evening crying peak is around six weeks. If it all gets too much, put him down safely in his cot and step away for a few minutes. Never shake a baby.',
      ]),
      PhaseSection('When to call the doctor', [
        'Crying that sounds different, high-pitched or weak, vomiting that is green or forceful, a fever, or a baby who will not feed. The first vaccines are due at six weeks.',
      ]),
      PhaseSection('And you', [
        'Your six-week check is about you, not only the baby. Bring your questions about bleeding, stitches, mood, sex and contraception.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Feeds become a little more efficient and may space out. He still needs only milk. Watch his cues rather than the clock.',
      ]),
      PhaseSection('Sleep now', [
        'Around 14 to 16 hours in 24. Some babies sleep a five or six hour stretch at night now; many do not yet, and both are normal.',
      ]),
      PhaseSection('Play that helps now', [
        'Tummy time a few times a day, a few minutes at a time. Lie down face to face with him on the floor. Smile and wait: he is learning to take turns in a conversation.',
      ]),
      PhaseSection('Keeping him safe now', [
        'He may roll sooner than you expect. Change him on the floor, and keep one hand on him whenever he is up high.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he does not smile at you, does not follow your face with his eyes, or does not startle at loud sounds, mention it at the visit. Fever after vaccines is common; a fever over 39 C or lasting more than two days needs a check.',
      ]),
      PhaseSection('And you', [
        'If you are going back to work in the coming months, it is a good time to start thinking about childcare and a milk plan, without rushing.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Milk only, still. Many babies get more distracted at the breast now; feeding in a quiet, dim room helps.',
      ]),
      PhaseSection('Sleep now', [
        'Day naps may become more regular: often three or four. Learning to settle a little on his own begins to be possible; there is no rush.',
      ]),
      PhaseSection('Play that helps now', [
        'Give him safe things to hold and look at his hands. Hang a toy he can bat at. Read picture books aloud; the rhythm of your voice is what he loves.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Everything goes to his mouth soon. Clear small things from the floor and the bed, and check toys for loose parts.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he cannot hold his head steady when held upright, does not bring his hands to his mouth, or does not push up on his arms during tummy time, ask at his next visit.',
      ]),
      PhaseSection('And you', [
        'Hair fall around now is common and temporary; it is hormones settling. Eat well and be patient with yourself.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Milk is still everything he needs. Interest in your food is not a sign to start solids yet; wait for about six months and the readiness signs.',
      ]),
      PhaseSection('Sleep now', [
        'The four-month sleep change can bring more night waking for a while. A calm, predictable bedtime routine helps it pass.',
      ]),
      PhaseSection('Play that helps now', [
        'Offer toys just out of reach to encourage reaching. Laugh with him, sing action songs, and let him feel different textures.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Stop swaddling once he shows signs of rolling. Keep cords, chargers and dupattas away from his reach.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he does not laugh or coo, does not hold toys, or seems stiff or very floppy, tell your doctor. The 14-week vaccines are around now.',
      ]),
      PhaseSection('And you', [
        'Many mothers start to feel more like themselves now, and some feel worse. If low mood or anxiety are hanging on, it is not too late to ask for help.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Watch for readiness for solids: sitting with support, good head control, interest in food, and losing the tongue-thrust. Most babies are ready around six months, not before.',
      ]),
      PhaseSection('Sleep now', [
        'Around 12 to 15 hours in 24, with two or three naps. Rolling in his sleep is fine once he can roll both ways by himself.',
      ]),
      PhaseSection('Play that helps now', [
        'Let him roll and stretch on a clean mat. Play peekaboo. Give him spoons, cups and rattles to bang and mouth.',
      ]),
      PhaseSection('Keeping him safe now', [
        'He can roll off anything now. Never leave him on a bed, sofa or changing table. Lower the cot mattress before he can sit.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he does not reach for things, does not roll in either direction, or does not respond to sounds around him, mention it to your doctor.',
      ]),
      PhaseSection('And you', [
        'Starting solids is a whole new job. Keep it simple: one family pot, his portion taken out before salt and chilli.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Start with soft, mashed foods once or twice a day: dal, khichdi, ragi, mashed banana, vegetables. Milk stays his main food for now. Introduce common allergens like egg and peanut early, one at a time.',
      ]),
      PhaseSection('Sleep now', [
        'Two or three naps, and a night that may still include feeds. Teething can disturb sleep; it does not cause high fever.',
      ]),
      PhaseSection('Play that helps now', [
        'Sit him with cushions around and give him toys to pass from hand to hand. Read the same books again and again; repetition is how he learns.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Start babyproofing: socket covers, cords out of reach, small things off the floor. Cut soft food into safe sizes, and always stay with him while he eats.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he cannot sit with support, shows no interest in sounds or faces, or chokes repeatedly on food, talk to your doctor.',
      ]),
      PhaseSection('And you', [
        'If you are going back to work, a trial week with his carer before you start makes the first real day far easier.',
      ]),
    ],
    indianNote:
        'The first rice feeding (annaprashan) traditionally falls around now and lines up well with the WHO guidance to start complementary foods at six months. Ragi, moong dal and well-mashed rice with a little ghee are excellent first foods. No salt, no sugar, and no honey before one year.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Two to three meals a day, with thicker textures and soft lumps. Let him try to feed himself with his fingers; mess is learning. Water in an open cup with meals.',
      ]),
      PhaseSection('Sleep now', [
        'Two naps for many babies. Separation can make bedtimes harder; a short, warm goodbye routine helps.',
      ]),
      PhaseSection('Play that helps now', [
        'Babble back to him like a real conversation. Name everything he looks at. Roll a ball between you.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Teeth mean a toothbrush: a grain-of-rice smear of fluoride toothpaste, twice a day. Keep hot tea and food well away from his reach.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he does not babble with consonant sounds like ba or da, or does not look when you call his name, raise it at the nine-month visit.',
      ]),
      PhaseSection('And you', [
        'A break of even an hour a week, fully yours, helps more than it sounds.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Three meals a day, plus milk. Offer a variety of colours and textures, and family food mashed or chopped soft. He decides how much.',
      ]),
      PhaseSection('Sleep now', [
        'Separation anxiety can bring night waking. Reassure him briefly, keep it calm and boring, and he usually settles again.',
      ]),
      PhaseSection('Play that helps now', [
        'Peekaboo, hiding a toy under a cloth, nesting cups and stacking. Let him crawl and explore safely.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Once he crawls, gates on stairs, guards on windows, and everything low and dangerous moved up or locked away. Get down to his level and look.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he cannot sit without support, does not bear weight on his legs, or has stopped doing something he could do, tell your doctor.',
      ]),
      PhaseSection('And you', [
        'Crawling babies are exhausting. Take shortcuts where you can, and accept help.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Three meals and a snack or two, alongside milk. Soft finger foods help him practise his pincer grasp. The MMR vaccine is due around now.',
      ]),
      PhaseSection('Sleep now', [
        'Around 12 to 14 hours in 24, usually with two naps.',
      ]),
      PhaseSection('Play that helps now', [
        'Clap, wave and point together. Give him things to put in and take out of a box. Read books with flaps and textures.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Pulling to stand means furniture becomes a ladder: anchor the TV and cupboard, and keep chairs away from windows and the balcony.',
      ]),
      PhaseSection('When to call the doctor', [
        'The nine-month visit is a good time for a developmental check. Mention any worries, however small.',
      ]),
      PhaseSection('And you', [
        'Keep your own vitamin D and iron in mind if you are still breastfeeding and feeling tired.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'He can pick up small pieces now: soft peas, rice, bits of paneer. Keep shapes safe: no whole nuts, whole grapes or hard pieces.',
      ]),
      PhaseSection('Sleep now', [
        'Teething and new skills can unsettle sleep for a few nights. Keep the routine steady.',
      ]),
      PhaseSection('Play that helps now', [
        'Point at things and name them. Let him feed himself with a spoon, badly. Sing rhymes with actions.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Cruising along furniture means bumps: soften sharp corners. Keep the bathroom door shut and buckets empty.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he does not point, wave or respond to his name, or does not pull to stand, ask your doctor.',
      ]),
      PhaseSection('And you', [
        'Plan his first birthday around his nap time; a happy, rested one-year-old makes the best guest of honour.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Family food, cut small and less salty. Move from bottle to cup over the coming months. He may eat a lot one day and very little the next.',
      ]),
      PhaseSection('Sleep now', [
        'Many babies drop to one nap closer to 15 to 18 months; for now two naps is still common.',
      ]),
      PhaseSection('Play that helps now', [
        'Push toys, stacking blocks, and lots of talking. Let him help with simple jobs.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Standing and first steps: watch stairs, balconies and water. Never leave him alone in a bath, even for a second.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he does not stand with support, does not say any words like mama or dada, or does not point to things, tell your doctor.',
      ]),
      PhaseSection('And you', [
        'One year of parenting. Take a moment to notice how much you have both learned.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Whole cow milk as a drink is fine from now, about two cups a day, not more, so he still eats food. Three meals and two snacks, family food cut small.',
      ]),
      PhaseSection('Sleep now', [
        'Around 11 to 14 hours in 24. A calm, predictable bedtime matters more than the exact time.',
      ]),
      PhaseSection('Play that helps now', [
        'Let him walk holding your hands, push a toy cart, and scribble with a fat crayon. Read and name pictures together.',
      ]),
      PhaseSection('Keeping him safe now', [
        'He climbs. Anchor furniture, keep windows guarded, and medicines and cleaners locked away.',
      ]),
      PhaseSection('When to call the doctor', [
        'If he is not walking by 18 months or has no words by 16 months, talk to your doctor. Anaemia is common now; ask about a check.',
      ]),
      PhaseSection('And you', [
        'If you are thinking about another baby, your body benefits from waiting at least 18 months to two years after a birth.',
      ]),
    ],
    indianNote:
        'The 12-month NIS window covers Hepatitis A and, in many private schedules, the first varicella dose. The first head shaving (mundan) is traditionally done anywhere between one and three years.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Fussy patches are normal. Keep offering a variety without pressure; it can take ten or more tries before a new food is accepted.',
      ]),
      PhaseSection('Sleep now', [
        'Many toddlers move to one afternoon nap between 15 and 18 months.',
      ]),
      PhaseSection('Play that helps now', [
        'Simple pretend play, stacking, and lots of chances to climb and walk outdoors. Name his feelings for him: you are angry, you wanted that.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Car seat, rear-facing, every journey. Hot drinks out of reach, and the kitchen gated if you can.',
      ]),
      PhaseSection('When to call the doctor', [
        'Losing words or skills, not following simple instructions, or not showing you things he finds interesting are worth a check.',
      ]),
      PhaseSection('And you', [
        'Tantrums are coming. Plan your own calm-down routine as well as his.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'He can use a spoon and an open cup, with mess. Eat together when you can; he learns by copying.',
      ]),
      PhaseSection('Sleep now', [
        'One nap of one to three hours is typical. Night waking with separation can return for a while.',
      ]),
      PhaseSection('Play that helps now', [
        'Pretend play, books, music, and messy play with water and sand. Give him simple choices: this shirt or that one.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Water safety: buckets, tanks and pools. He moves fast and silently.',
      ]),
      PhaseSection('When to call the doctor', [
        'The 18-month visit includes a development check and boosters. Ask about a screen for speech and social skills.',
      ]),
      PhaseSection('And you', [
        'Comparisons with other children are everywhere. Your child\'s own path is the one that matters.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Two-year-olds eat less than you expect. Offer meals at regular times, keep milk to about two cups, and limit juice and biscuits.',
      ]),
      PhaseSection('Sleep now', [
        'Around 11 to 14 hours in 24, with one nap. Moving from cot to bed can wait until he climbs out or is closer to three.',
      ]),
      PhaseSection('Play that helps now', [
        'Kicking a ball, running, simple puzzles, and lots of talk. Read every day, and let him finish familiar lines.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Tantrums: keep him safe and stay nearby, without giving in or punishing. Never leave him alone near roads or water.',
      ]),
      PhaseSection('When to call the doctor', [
        'No two-word phrases by two, walking only on tiptoe, or no pretend play are worth discussing with your doctor.',
      ]),
      PhaseSection('And you', [
        'Big feelings in a toddler can stir big feelings in us. It is fine to take a breath before you respond.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'He eats most family food. A balanced plate across the day matters more than any single meal.',
      ]),
      PhaseSection('Sleep now', [
        'One nap, though some children start to drop it closer to three. Quiet time can replace it.',
      ]),
      PhaseSection('Play that helps now', [
        'Pretend games, drawing, building, outdoor running. Play with other children begins in earnest.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Teach simple rules: hold hands near roads, no touching the stove. He will still need reminding for years.',
      ]),
      PhaseSection('When to call the doctor', [
        'If strangers cannot understand any of his speech, he does not use two or three word sentences, or he falls a lot, ask your doctor.',
      ]),
      PhaseSection('And you', [
        'Potty training may be on your mind. Readiness matters more than age; there is no rush.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Let him serve himself and help prepare simple food. Children who help cook are more willing to try.',
      ]),
      PhaseSection('Sleep now', [
        'Around 10 to 13 hours, with or without a nap. Bad dreams and fears of the dark can begin; a night light helps.',
      ]),
      PhaseSection('Play that helps now', [
        'Simple board games, stories with questions, and helping with chores. Let him try, and fail, and try again.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Talk about safe touch and private parts using the real words. Teach him your phone number as a song.',
      ]),
      PhaseSection('When to call the doctor', [
        'Ongoing trouble with stairs, very unclear speech, or not playing alongside other children are worth a check.',
      ]),
      PhaseSection('And you', [
        'If preschool is coming, visit a few and trust your gut about where he will be happy.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'Three meals and two snacks, with water as the main drink. Watch the packaged snacks: they fill small stomachs fast.',
      ]),
      PhaseSection('Sleep now', [
        'About 10 to 13 hours a night. A consistent bedtime routine helps through the busy preschool years.',
      ]),
      PhaseSection('Play that helps now', [
        'Answer his whys, or say "let us find out together". Pretend play, drawing, puzzles, and outdoor play every day.',
      ]),
      PhaseSection('Keeping him safe now', [
        'A helmet on the cycle, a booster seat in the car, and the lost-in-a-crowd plan practised.',
      ]),
      PhaseSection('When to call the doctor', [
        'Get his eyes and hearing checked before school. Ask about any worries with speech, behaviour or making friends.',
      ]),
      PhaseSection('And you', [
        'The questions can be endless. It is fine to say "I need a quiet minute" and take it.',
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
      // Added 2026-10-02 from the parenting gap analysis: the age guides
      // of both competitors carry these for every age. REQUIRED_REVIEW.
      PhaseSection('Feeding now', [
        'A healthy tiffin, a good breakfast, and water through the day. Involve him in choosing between two healthy options.',
      ]),
      PhaseSection('Sleep now', [
        'About 10 to 13 hours. School mornings are easier with an early, fixed bedtime and screens off an hour before.',
      ]),
      PhaseSection('Play that helps now', [
        'Games with rules, drawing, building and lots of outdoor play. Reading together every day is the best school preparation there is.',
      ]),
      PhaseSection('Keeping him safe now', [
        'Road sense, swimming lessons, safe adults he can go to, and body safety talks. Check the school van and its driver.',
      ]),
      PhaseSection('When to call the doctor', [
        'Booster vaccines are due between four and six. Ask the doctor about anything a teacher notices, early.',
      ]),
      PhaseSection('And from five to six', [
        'Between five and six, most children ride a bicycle with or without trainers, write their name, tell longer stories, follow multi-step instructions and manage more feelings with words. Friendships matter more and more. Keep reading together even once he can read alone, and protect plenty of free play: it is where confidence grows.',
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

// The phase reads CORRECTED age for a baby born early (devAgeInMonths,
// 2026-10-07); for everyone else it is the same as ageInMonths.
AgePhase currentPhase([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  return kPhases[phaseIndexForMonths(c.devAgeInMonths.toDouble())];
}

AgePhase? nextPhase([ChildProfileStore? child]) {
  final c = child ?? ChildProfileStore.instance;
  final i = phaseIndexForMonths(c.devAgeInMonths.toDouble());
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
