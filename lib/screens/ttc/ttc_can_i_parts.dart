// =============================================================================
//  TTC "Can I...?" - the parts that make an answer visible at a glance
// -----------------------------------------------------------------------------
//  Added 2026-09-29, tools rebuilt heading by heading ("Plan and check"). The
//  user, on build 20: "the vaguest of all tools... everything is black text,
//  nothing else. It all looks the same unless you read it carefully."
//
//  The list before this: every row was the question in ink, then the verdict
//  as an 11pt ink mark and a bold ink WORD, then a grey line. Twelve rows of
//  the same weight and colour, so the one fact she came for (yes, a limit,
//  ask, stop) had to be read, not seen.
//
//  ⚠️ THE VERDICT IS A TINTED TAG, AND THE TINT IS NEVER ALONE. Mobbin:
//    · CVS Health "Visit checklist"
//      (https://mobbin.com/screens/5367bf1b-68be-434d-825e-33fa368bfd42):
//      a small tinted tag under each title ("Action Needed", "Completed"),
//      so a column of rows reads as a column of states.
//    · Yuka ingredients
//      (https://mobbin.com/screens/3e160990-7c3e-4f13-bf1b-25ca9f60b2c7):
//      the verdict as a coloured mark AND a word on every row; the word is
//      the meaning, the colour is the scan.
//    · Noom risk rows
//      (https://mobbin.com/screens/a88ad13d-03d2-4e54-8212-7b08f6c2c9cd):
//      one short tinted status pill per row, the number beside it.
//  So a tag carries three things that each survive without the others: the
//  drawn mark (full dot, half dot, ring, ring with a bar; greyscale and a
//  colour-blind eye), the WORD (the meaning, unchanged from
//  `TtcVerdictCopy.label`), and the tint (the glance).
//
//  ⚠️ CALM TINTS, NOT A TRAFFIC LIGHT. The data file's rule stands: a red
//  "avoid" beside papaya would teach fear of a fruit. The four tints are the
//  app's own pale block family, the same lightness for all four so no one of
//  them shouts: sage for yes, sand for a limit, the clinic's blue-grey for
//  "ask your doctor" (206, the hue the clinic door and Care and medicines
//  already wear), and a dusty rose for the one clear no. The word on the tag
//  is ink (ink on light, 4.5:1 and up); only the small mark takes the deeper
//  shade of its hue, measured at 3:1 and up against its own tint
//  (test/ttc_can_i_rebuild_test.dart).
//
//  ⚠️ THE LIMIT IS A CHIP OF ITS OWN, not a clause after a middle dot. "Yes,
//  with a limit" is only half an answer; the chip beside it says the limit
//  ("Limit: about 200mg of caffeine a day"), outlined so it reads as a detail
//  of the tag rather than a second verdict.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_can_i_data.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcInk;
import 'ttc_lookup_parts.dart' show TtcVerdictMark;

/// The hue a verdict's tag wears. See the header: one lightness, four hues.
double ttcVerdictHue(TtcVerdict v) => switch (v) {
      TtcVerdict.safe => 145,
      TtcVerdict.moderate => 40,
      TtcVerdict.askDoctor => 206,
      TtcVerdict.avoid => 350,
    };

/// The tag's pale ground.
Color ttcVerdictTint(TtcVerdict v) =>
    HSLColor.fromAHSL(1, ttcVerdictHue(v), 0.50, 0.90).toColor();

/// The mark's deeper shade of the same hue (3:1 and up on the tint).
Color ttcVerdictDeep(TtcVerdict v) =>
    HSLColor.fromAHSL(1, ttcVerdictHue(v), 0.50, 0.30).toColor();

/// The verdict as a tag: its drawn mark, its word, on its tint.
class TtcVerdictTag extends StatelessWidget {
  const TtcVerdictTag({
    super.key,
    required this.verdict,
    required this.hi,
    this.small = false,
  });

  final TtcVerdict verdict;
  final bool hi;

  /// The recently checked rows use a step smaller tag.
  final bool small;

  @override
  Widget build(BuildContext context) {
    final word = verdict.label(hi);
    return Semantics(
      label: 'Answer: $word',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(small ? 7 : 9, 4, small ? 9 : 11, 4),
        decoration: BoxDecoration(
          color: ttcVerdictTint(verdict),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          TtcVerdictMark(verdict,
              size: small ? 10 : 12, color: ttcVerdictDeep(verdict)),
          SizedBox(width: small ? 5 : 6),
          Flexible(
            child: Text(word,
                style: pvManrope(
                    fontSize: small ? 11.5 : 12.5,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    color: ttcInk)),
          ),
        ]),
      ),
    );
  }
}

/// An outlined detail pill beside the tag: the limit, or who it is about.
class TtcCanIDetailChip extends StatelessWidget {
  const TtcCanIDetailChip(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: p.line, width: 1.2),
      ),
      child: Text(text,
          style: pvManrope(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.3,
              color: ttcInk)),
    );
  }
}

/// The limit chip's words. Explicit ("Limit: ...") so it cannot be read as a
/// second verdict.
String ttcCanILimitLabel(String limit) => 'Limit: $limit';

/// "About him", on an answer that is really about him (`forPartner`).
const String kTtcCanIAboutHim = 'About him';

/// One question: the question, its tag (and limit, and "About him"), the one
/// line answer, and a chevron to the whole answer.
class TtcCanIRow extends StatelessWidget {
  const TtcCanIRow({
    super.key,
    required this.item,
    required this.hi,
    required this.onTap,
    this.compact = false,
  });

  final TtcCanI item;
  final bool hi;
  final VoidCallback onTap;

  /// The recently checked rows: question and tag only, no answer line.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final limit = item.limit(hi);
    return PvPress(
      child: InkWell(
        onTap: () {
          pvCommitFeedback();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 11 : 15),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.question(hi),
                      style: pvManrope(
                          fontSize: compact ? 14 : 15,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: p.ink1)),
                  SizedBox(height: compact ? 6 : 8),
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    TtcVerdictTag(
                        verdict: item.verdict, hi: hi, small: compact),
                    // "About him" first: it is short, so it sits beside the
                    // tag and a long limit takes the next line on its own.
                    if (!compact && item.forPartner)
                      const TtcCanIDetailChip(kTtcCanIAboutHim),
                    if (!compact && limit != null)
                      TtcCanIDetailChip(ttcCanILimitLabel(limit)),
                  ]),
                  // ⚠️ NOT UNDER A LIMIT CHIP (render check, 2026-09-29):
                  // the limit IS the short answer, shortened, so chai read
                  // "Limit: about 200mg of caffeine a day" and then "Yes, up
                  // to about 200mg of caffeine a day." The whole short answer
                  // opens first in the reader. Kept for revert: if (!compact)
                  if (!compact && limit == null) ...[
                    const SizedBox(height: 8),
                    Text(item.short(hi),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                            fontSize: 13,
                            height: 1.45,
                            color: p.ink2)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, size: 22, color: p.ink2),
          ]),
        ),
      ),
    );
  }
}

/// A topic filter chip: ink when chosen, white with a hairline at rest.
/// The switch black (`ttcInk`), never a hue: colour on this screen means a
/// verdict and nothing else.
class TtcCanITopicChip extends StatelessWidget {
  const TtcCanITopicChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
      button: true,
      selected: selected,
      child: PvPress(
        child: Material(
          color: selected ? ttcInk : p.surface,
          shape: StadiumBorder(
              side: BorderSide(color: selected ? ttcInk : p.line, width: 1.2)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              pvCommitFeedback();
              onTap();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
              child: Text(label,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : ttcInk)),
            ),
          ),
        ),
      ),
    );
  }
}
