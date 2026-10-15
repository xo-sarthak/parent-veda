// =============================================================================
//  Every tap answers the finger (tap feedback second pass, 2026-10-15)
// -----------------------------------------------------------------------------
//  The user, 2026-09-18: every change "considers the taps and the effects that
//  make the user feel like they did something". The first pass wrapped an
//  owed list; the second wrapped every plain tap in the app (1,338 of them) in
//  `PvPress`, the 2% settle in lib/widgets/pv_feedback.dart.
//
//  This test keeps it that way. It reads the source: every `GestureDetector(`
//  in lib/ must sit directly inside a PvPress, except the ones that are
//  deliberately left alone, counted per file below. They are the taps the
//  pass skipped ON PURPOSE:
//
//    * full-screen layers: a scrim or a tap-to-dismiss backdrop
//      (Positioned.fill, SizedBox.expand, a page body, a blur), which would
//      move the whole screen;
//    * keyboard-dismiss wrappers;
//    * detectors that also drag, long-press or track tap-down;
//    * detectors whose onTap is sometimes null by a condition;
//    * detectors with no onTap, and those inside commented-out code kept for
//      revert (this scan reads text, so it sees those too).
//
//  A NEW plain tap fails here: wrap it, `PvPress(child: GestureDetector(...))`.
//  If it truly must not settle (one of the cases above), raise its file's
//  count below and say why in the commit.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// "Directly inside a PvPress": the text before the detector is a PvPress( whose
/// FIRST `child:` is the detector (other arguments such as `key:` or
/// `enabled:` may come first).
final RegExp _wrapped = RegExp(r'PvPress\((?:(?!child:)[^;])*child:\s*$', dotAll: true);

Map<String, int> _unwrappedByFile() {
  final out = <String, int>{};
  for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (!f.path.endsWith('.dart')) continue;
    final src = f.readAsStringSync();
    var n = 0;
    for (final m in RegExp(r'GestureDetector\(').allMatches(src)) {
      final lineStart = src.lastIndexOf('\n', m.start) + 1;
      if (src.substring(lineStart, m.start).trimLeft().startsWith('//')) continue;
      final before = src.substring((m.start - 200).clamp(0, m.start), m.start);
      if (!_wrapped.hasMatch(before)) n++;
    }
    if (n > 0) out[f.path.replaceAll(r'\', '/')] = n;
  }
  return out;
}

/// Unwrapped detectors each file may keep (see the header for why).
const Map<String, int> kTapFeedbackAllowed = {
  'lib/ask_veda/pv_veda_reveal.dart': 1,
  'lib/ask_veda/veda_result_view.dart': 2,
  'lib/booking/call_screen.dart': 1,
  'lib/brand/sampling_screen.dart': 1,
  'lib/screens/auth/auth_flow_screen.dart': 1,
  'lib/screens/belly_skin/bump_ritual_screen.dart': 1,
  'lib/screens/community_screen.dart': 3,
  'lib/screens/doctor/doctor_home_screen.dart': 2,
  'lib/screens/doors/pv_door_carousel.dart': 2,
  'lib/screens/doors/pv_door_screen.dart': 1,
  'lib/screens/father/father_daily_screen.dart': 2,
  'lib/screens/garbh_shravan_surfaces.dart': 1,
  'lib/screens/home_screen_b.dart': 1,
  'lib/screens/journal_screen.dart': 1,
  'lib/screens/journal_writer_screen.dart': 1,
  'lib/screens/memories/memory_personalize_screen.dart': 2,
  'lib/screens/memories/memory_preview_screen.dart': 2,
  'lib/screens/nutrition/door/nutrition_widgets.dart': 1,
  'lib/screens/post_pregnancy/article_reader_screen.dart': 2,
  'lib/screens/post_pregnancy/community_screen.dart': 3,
  'lib/screens/post_pregnancy/development_activity_screen.dart': 1,
  'lib/screens/post_pregnancy/doors/pp_door_carousel.dart': 2,
  'lib/screens/post_pregnancy/grow_v2_screens.dart': 1,
  'lib/screens/post_pregnancy/growth_journey_screen.dart': 1,
  'lib/screens/post_pregnancy/journal_v2/journal_capture_screens.dart': 1,
  'lib/screens/post_pregnancy/journal_v2/journal_storybook_screens.dart': 1,
  'lib/screens/post_pregnancy/journeys_screen.dart': 1,
  'lib/screens/post_pregnancy/milestone_journey_screen.dart': 1,
  'lib/screens/post_pregnancy/my_bookings_screen.dart': 1,
  'lib/screens/post_pregnancy/name_journey_feed_screen.dart': 4,
  'lib/screens/post_pregnancy/name_swipe_screen.dart': 2,
  'lib/screens/post_pregnancy/pp_content.dart': 1,
  'lib/screens/post_pregnancy/pp_create_post_screen.dart': 1,
  'lib/screens/post_pregnancy/pp_explore_kit.dart': 1,
  'lib/screens/post_pregnancy/pp_story_screen.dart': 1,
  'lib/screens/post_pregnancy/prescription_view_screen.dart': 1,
  'lib/screens/post_pregnancy/provider_booking_sheet.dart': 1,
  'lib/screens/post_pregnancy/video/pv_video_player.dart': 1,
  'lib/screens/post_pregnancy/what_changed_screen.dart': 2,
  'lib/screens/post_pregnancy/yoga_class_screen.dart': 1,
  'lib/screens/product_guide/product_guide_hub_screen.dart': 1,
  'lib/screens/products/pv_gallery_screen.dart': 1,
  'lib/screens/products/pv_product_screen.dart': 1,
  'lib/screens/referral/enter_code_sheet.dart': 1,
  'lib/screens/skilling/doors/sk_door_carousel.dart': 2,
  'lib/screens/symptoms/door/symptoms_widgets.dart': 1,
  'lib/screens/tools/garbh_games.dart': 1,
  'lib/screens/ttc/ttc_appointments_screen.dart': 9,
  'lib/screens/ttc/ttc_cycle_companion.dart': 3,
  'lib/screens/ttc/ttc_cycle_report_v3.dart': 1,
  'lib/screens/ttc/ttc_cycle_screens.dart': 3,
  'lib/screens/ttc/ttc_dose_parts.dart': 1,
  'lib/screens/ttc/ttc_focus_screen.dart': 3,
  'lib/screens/ttc/ttc_practice_screen.dart': 2,
  'lib/screens/ttc/ttc_records_screen.dart': 8,
  'lib/screens/ttc/ttc_records_v2.dart': 2,
  'lib/screens/ttc/ttc_tool_chrome.dart': 1,
  'lib/screens/v2/v3_daily_tip.dart': 1,
  'lib/widgets/baby_voice/speaker_button.dart': 1,
  'lib/widgets/pv_feedback.dart': 1,
  'lib/widgets/pv_placeholders.dart': 1,
};

void main() {
  test('every plain tap in lib/ settles under the finger (PvPress)', () {
    final now = _unwrappedByFile();
    final problems = <String>[];
    for (final e in now.entries) {
      final allowed = kTapFeedbackAllowed[e.key] ?? 0;
      if (e.value > allowed) {
        problems.add("  '${e.key}': ${e.value}, // allowed $allowed");
      }
    }
    expect(problems, isEmpty,
        reason: 'GestureDetector without PvPress. Wrap it in PvPress(child: ...), '
            'or, if it must not settle, raise the file\'s count:\n${problems.join('\n')}');
  });
}
