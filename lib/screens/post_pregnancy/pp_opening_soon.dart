// =============================================================================
//  PpOpeningSoonScreen — an honest page where a seeded feature used to be
// -----------------------------------------------------------------------------
//  Parenting gap analysis, "Behind · Trust" and "Behind · Community" (P1,
//  2026-10-07). The community showed seeded rooms, fixed member counts,
//  fictional doctors "verifying" posts and a live "Doctor mode (test)" that let
//  any parent post as a paediatrician; the courses showed ratings and "N
//  parents" for lessons never filmed. The gap analysis: show "Opening soon.
//  Tell me when it opens." until each is real.
//
//  ⚠️ WHY THE SCREEN, NOT THE ENTRY POINTS. Pregnancy hid its community by
//  commenting out each way in. Parenting has a dozen (More, What Changed?,
//  the leap page, every recipe's and read's "related room", the surface
//  router), and one missed link would land a parent in the seeded feed. Here
//  the screens themselves draw this page, so every way in lands on the truth,
//  and the feature still advertises itself (CLAUDE.md: "a feature is never
//  hidden"). The seeded screens' bodies stay in place for the day a feed is
//  real; one constant opens each.
//
//  The shell is the tool shell pregnancy and parenting tools share
//  (`PregToolScaffold`: the field, the round back, a serif title), with the
//  "What is this?" shape the app uses to explain itself: three one-line points,
//  each with a line icon, then one ink button.
//
//  ⚠️ INTEREST IS REMEMBERED ON THIS PHONE ONLY, as pregnancy's course
//  interest is (STILL-OPEN §81.3). Counting it across everyone needs a table.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, pvSnack, pvStorePalette;
import 'pp_child_profile.dart';

/// The parenting community opens when there is a shared feed, moderators and
/// real rooms (gap analysis, Behind · Community). Until then every community
/// screen draws [ppCommunityOpeningSoon]. The seeded screens are untouched
/// behind this flag.
const bool kPpCommunityOpen = false;

/// Where "Tell me when it opens" is kept: the ids she asked about.
const String kPpOpeningInterestKey = 'pp_opening_interest_v1';

/// One line of the page: a line icon and a short sentence.
typedef PpSoonPoint = (IconData icon, String text);

class PpOpeningSoonScreen extends StatelessWidget {
  const PpOpeningSoonScreen({
    super.key,
    required this.id,
    required this.title,
    required this.intro,
    required this.points,
    this.footnote,
    this.hue = 268,
    this.mark,
  });

  /// What she is asking to hear about (`community`, `course:<id>`, and so on).
  final String id;
  final String title;
  final String intro;
  final List<PpSoonPoint> points;
  final String? footnote;
  final double hue;
  final IntentMark? mark;

  static Future<void> _remember(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(kPpOpeningInterestKey) ?? const <String>[];
      if (!ids.contains(id)) await prefs.setStringList(kPpOpeningInterestKey, [...ids, id]);
    } catch (_) {
      // Local-first: a storage failure is never a crash, and costs one tap.
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: hue,
      mark: mark,
      eyebrow: 'Opening soon',
      title: title,
      intro: intro,
      children: [
        for (final (icon, text) in points)
          pregToolPad(Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(icon, size: 20, color: p.ink1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(text, style: pvManrope(fontSize: 15, height: 1.45, color: p.ink1)),
              ),
            ]),
          )),
        const SizedBox(height: 10),
        pregToolPad(PvCommit(
          key: const ValueKey('pp_opening_soon_notify'),
          label: 'Tell me when it opens',
          onTap: () {
            pvCommitFeedback();
            _remember(id);
            pvSnack(context, "Noted. We'll tell you here when it opens.");
          },
        )),
        if (footnote != null) ...[
          const SizedBox(height: 16),
          pregToolPad(Text(footnote!, style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3))),
        ],
        const SizedBox(height: 32),
      ],
    );
  }
}

/// The community's page. Its words, in one place, so every gated screen
/// (the feed, a room, a post, writing a post, her activity) says the same.
Widget ppCommunityOpeningSoon() => PpOpeningSoonScreen(
      key: const ValueKey('pp_community_opening_soon'),
      id: 'community',
      title: 'Parents like you, soon',
      intro: 'A place to talk with parents whose babies were born the same month as ${ChildProfileStore.instance.nameMid}. '
          'It opens once real parents are here and people are looking after it.',
      points: const [
        (Icons.groups_outlined, 'A room for babies born in the same month, and rooms for feeding, toddlers, work and dads.'),
        (Icons.shield_outlined, 'House rules and moderators from the very first post.'),
        (Icons.lock_outline_rounded, 'You choose what to share, and can post without your name.'),
      ],
      footnote: 'Until then, every door has answers, and Ask Veda is there any time.',
    );
