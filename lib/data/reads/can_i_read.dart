// =============================================================================
//  Is it safe? — one entry as a read
// -----------------------------------------------------------------------------
//  2026-09-19. The Can I? answer used to be its own screen (`CanIAnswerScreen`,
//  kept in can_i_screen.dart for revert); ONE READER means it opens in
//  `PvReaderScreen` as a `PvRead` like every other piece of writing. The
//  parts the reader does not model — the verdict for her week, the swap
//  rail, her doctor's call — ride as `PvReadSection.custom` blocks, data
//  only, and `lib/screens/can_i/can_i_answer.dart` draws them.
//
//  Order on the page, and why:
//    photo hero  → the thing itself, edge to edge (Vivino, Yami, HelloFresh
//                  all open on the picture)
//    verdict     → the word, then the note for HER trimester, first
//    why         → the reasoning, no jargon
//    instead     → a "no" that ends in what she CAN have (Amazon Fresh's
//                  "Replace with" rail)
//    trimesters  → the other two notes, folded
//    Indian      → the ParentVeda line
//    doctor said → the truth hierarchy on screen
//    also asked  → related entries, as read-next tiles
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/can_i_entry.dart';
import '../../models/pv_read.dart';
import '../can_i_groups.dart';

const String kCanIReadPrefix = 'cani_';

/// The verdict block at the top of the answer. `week` is hers, or null when
/// the stage does not know it (then the block prints no trimester line).
class PvCanIVerdictBlock {
  const PvCanIVerdictBlock(this.entry, {this.week});
  final CanIEntry entry;
  final int? week;
  LocalizedText? get noteForHer => week == null ? null : canINoteForWeek(entry, week!);
}

/// "Instead, try" — the safe swaps, as data; the stage draws the photo rail.
class PvCanIInsteadBlock {
  const PvCanIInsteadBlock(this.entry, this.swaps);
  final CanIEntry entry;
  final List<CanIEntry> swaps;
}

/// "My doctor said" — one item, her clinician's call recorded on the page.
class PvCanIDoctorBlock {
  const PvCanIDoctorBlock(this.entry);
  final CanIEntry entry;
}

const LocalizedText _kicker = LocalizedText(en: 'Is it safe?', hi: 'Is it safe?'); // English only (the user, 2026-09-19)
const LocalizedText _desk = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');

/// The question the category asks, for the teaser under the name.
String canIQuestion(CanICategory c) => switch (c) {
      CanICategory.eat => 'Can I eat it?',
      CanICategory.drink => 'Can I drink it?',
      CanICategory.take => 'Can I take it?',
      CanICategory.doActivity => 'Can I do it?',
    };

/// One hue per category, so the reader's tint and the door's tiles agree.
double canIHue(CanICategory c) => switch (c) {
      CanICategory.eat => 140,
      CanICategory.drink => 200,
      CanICategory.take => 268,
      CanICategory.doActivity => 28,
    };

/// One word for a verdict. The word is the verdict's whole voice on a tile;
/// the reasoning waits for the tap.
String canIVerdictWord(CanIVerdict v) => switch (v) {
      CanIVerdict.safe => 'Safe',
      CanIVerdict.moderation => 'In moderation',
      CanIVerdict.depends => 'Depends',
      CanIVerdict.avoid => 'Avoid',
      CanIVerdict.askDoctor => 'Ask your doctor',
    };

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// The heading over the Indian line. "Kitchen" fits food and drink; a
/// flight or a medicine gets the plainer "In India" (2026-09-29).
String canIIndianHeading(CanICategory c) =>
    c == CanICategory.eat || c == CanICategory.drink ? 'In an Indian kitchen' : 'In India';

PvRead pvReadFromCanI(CanIEntry e, {int? week}) {
  final swaps = canIInsteadOf(e);
  final swapIds = {for (final s in swaps) s.id};
  final others = [
    for (final t in [1, 2, 3])
      if (week == null || canITrimester(week) != t)
        if (switch (t) { 1 => e.t1, 2 => e.t2, _ => e.t3 } case final n?)
          _same('${switch (t) { 1 => 'First', 2 => 'Second', _ => 'Third' }} trimester: ${n.en}'),
  ];
  return PvRead(
    id: '$kCanIReadPrefix${e.id}',
    kicker: _kicker,
    title: e.name,
    teaser: _same(canIQuestion(e.category)),
    scaleSetter: e.short,
    // The short answer is the entry's own two-line answer (2026-09-29, the
    // pregnancy warmth pass: every read opens with one).
    shortAnswer: e.short,
    author: _desk,
    authorRole: _kicker,
    reviewed: false,
    hue: canIHue(e.category),
    sections: [
      PvReadSection(custom: PvCanIVerdictBlock(e, week: week)),
      PvReadSection(heading: _same('Why'), paragraphs: [e.why]),
      if (swaps.isNotEmpty) PvReadSection(custom: PvCanIInsteadBlock(e, swaps)),
      if (others.isNotEmpty)
        PvReadSection(
            heading: _same(week == null ? 'Through the trimesters' : 'Earlier and later in pregnancy'),
            bullets: others,
            collapsible: true,
            summary: _same('How the answer changes as the weeks go by.')),
      if (e.indian case final ind?)
        PvReadSection(heading: _same(canIIndianHeading(e.category)), paragraphs: [ind]),
      PvReadSection(custom: PvCanIDoctorBlock(e)),
    ],
    whenToSeeSomeone: PvCallout(
      tone: e.verdict == CanIVerdict.askDoctor ? PvCalloutTone.urgent : PvCalloutTone.note,
      title: _same(e.verdict == CanIVerdict.askDoctor
          ? 'This one is your doctor\'s call'
          : 'General guidance, not a prescription'),
      body: _same(e.verdict == CanIVerdict.askDoctor
          ? 'The right answer depends on your history and your dose. Take this '
              'page to your doctor and let them decide.'
          : 'If your doctor has told you something different for your '
              'pregnancy, go with your doctor. Record what they said under '
              'My doctor said, and this answer will remember it.'),
    ),
    faqs: const [],
    readNext: [
      for (final id in e.related)
        if (!swapIds.contains(id)) '$kCanIReadPrefix$id',
    ],
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _same('Send this answer to someone'),
        value: _same('The verdict and the reason, as a message for whoever does the shopping.'),
        action: 'cani_share',
      ),
      PvReadNextStep(
        kind: PvNextKind.ask,
        title: _same('Something specific? Ask Veda about ${e.name.en}'),
        value: _same('Your brand, your dose, your week, in your own words.'),
        action: 'cani_askveda',
      ),
    ],
  );
}
