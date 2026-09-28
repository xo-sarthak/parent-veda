// =============================================================================
//  TTC expert sign-off — who has actually reviewed which read
// -----------------------------------------------------------------------------
//  ⚠️ A TICK STATES A REVIEW, SO IT NEEDS ONE (launch sanity H14, 2026-09-28).
//  The warmth pass (2026-09-26) put real roster names on the TTC reads, and
//  the reader drew "REVIEWED BY Dr Ruchika Sood" with a verified tick on every
//  one of them. `docs/TTC-EXPERT-SIGNOFF.md` says nothing has been sent yet:
//  no expert has read a single piece. The tick was a claim nobody had made.
//
//  So a TTC read shows its expert only when that expert's sign-off is written
//  down HERE. Until then it reads as the His side reads always have: "By
//  ParentVeda team · Written from the sources listed at the end", and no
//  tick. The expert's name stays on the read as written (`kTtcReadsAsWritten`
//  in ttc_reads_data.dart, and `tools/ttc_expert_signoff.py` still reads it),
//  so the day a sign-off comes back, one id added below flips that read back
//  to "Reviewed by" with the tick, with no other change.
//
//  The trade-off, named: every TTC read now opens with the desk's byline, and
//  that is a weaker trust signal than a doctor's name. It is also a true one,
//  and a trust surface that says something untrue costs more than it ever
//  earned the day someone checks.
//
//  HOW TO RECORD A SIGN-OFF: when an expert signs a piece off, fill in its
//  "Signed off" date in docs/TTC-EXPERT-SIGNOFF.md and add its id to that
//  expert's set below, in the same commit. `test/ttc_expert_signoff_test.dart`
//  fails if a read shows the tick without its id here.
// =============================================================================

import '../localization/app_language.dart';
import '../models/pv_read.dart';

/// Read ids each expert has signed off, keyed by the name on the read exactly
/// as written (`PvRead.author.en`). Mirrors the "Signed off" column of
/// docs/TTC-EXPERT-SIGNOFF.md. Empty on 2026-09-28: nothing has been sent.
const Map<String, Set<String>> kTtcSignedOffReads = {
  'Dr Ruchika Sood': <String>{},
  'Dr Surbhi Sharma': <String>{},
  'Parmeshwari': <String>{},
  'Akanksha Srivastava': <String>{},
  'Dr Kajal Sharma': <String>{},
};

/// Door carousels, stories and infographics each expert has signed off, keyed
/// by the name as written in the tile's `reviewedBy` (launch sanity, H14's
/// follow-up, 2026-09-28). A tile carries no id, so its TITLE is the id here:
/// the one name the door, the story screen and docs/TTC-EXPERT-SIGNOFF.md
/// all share. Renaming a signed-off tile means renaming it here too, and
/// `test/ttc_expert_signoff_test.dart` fails if a title here matches no tile.
/// Empty on 2026-09-28: nothing has been sent.
const Map<String, Set<String>> kTtcSignedOffStories = {
  'Dr Ruchika Sood': <String>{},
  'Dr Surbhi Sharma': <String>{},
  'Parmeshwari': <String>{},
  'Akanksha Srivastava': <String>{},
  'Dr Kajal Sharma': <String>{},
};

/// The desk's byline, as a story or infographic shows it.
const String kTtcTeamByline = 'ParentVeda team';

/// The byline a door carousel, story or infographic titled [title] may show,
/// given what its data says ([reviewedBy], e.g. "Reviewed by Dr Ruchika
/// Sood, IVF gynaecologist"). As written when that expert signed [title]
/// off, or when it already names the team; else the team, and the screens
/// draw no tick for the team. Null stays null (no byline at all).
///
/// The same rule as `ttcApplySignoff` for reads, for the formats that carry
/// their byline as a line of text rather than a `PvRead.author`.
String? ttcStoryReviewer(String? reviewedBy, String title,
    {Map<String, Set<String>> signedOff = kTtcSignedOffStories}) {
  if (reviewedBy == null) return null;
  final who = reviewedBy
      .trim()
      .replaceFirst(
          RegExp(r'^(reviewed\s+by|by)\s*[:·]?\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'^Dr\.\s*'), 'Dr ');
  if (who.toLowerCase().contains('parentveda')) return reviewedBy;
  for (final e in signedOff.entries) {
    if (who.startsWith(e.key) && e.value.contains(title)) return reviewedBy;
  }
  return kTtcTeamByline;
}

/// Whether a byline returned by [ttcStoryReviewer] names a person who signed
/// the piece off (and so may carry a tick), rather than the team.
bool ttcStoryBylineIsPerson(String? shown) =>
    shown != null && !shown.toLowerCase().contains('parentveda');

/// Whether [read]'s named expert has signed it off.
bool ttcReadSignedOff(PvRead read,
        {Map<String, Set<String>> signedOff = kTtcSignedOffReads}) =>
    signedOff[read.author.en]?.contains(read.id) ?? false;

/// The byline a TTC read may show: as written when its expert signed it off
/// (or when it never claimed a review), else the desk's byline, no tick.
PvRead ttcApplySignoff(PvRead read,
    {Map<String, Set<String>> signedOff = kTtcSignedOffReads}) {
  if (!read.reviewed || ttcReadSignedOff(read, signedOff: signedOff)) {
    return read;
  }
  return PvRead(
    id: read.id,
    kicker: read.kicker,
    title: read.title,
    teaser: read.teaser,
    scaleSetter: read.scaleSetter,
    // The His side pattern (ttc_reads_his_side.dart).
    author: const LocalizedText(en: 'ParentVeda team', hi: 'ParentVeda team'),
    authorRole: const LocalizedText(
        en: 'Written from the sources listed at the end',
        hi: 'Written from the sources listed at the end'),
    hue: read.hue,
    sections: read.sections,
    whenToSeeSomeone: read.whenToSeeSomeone,
    faqs: read.faqs,
    evidence: read.evidence,
    heroVideoSlot: read.heroVideoSlot,
    relatedVideoSlots: read.relatedVideoSlots,
    readNext: read.readNext,
    nextSteps: read.nextSteps,
    imageUrl: read.imageUrl,
    reviewed: false,
    shortAnswer: read.shortAnswer,
  );
}
