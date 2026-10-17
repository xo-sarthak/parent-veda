// =============================================================================
//  The Yoga & fitness hub, for every stage (2026-10-17)
// -----------------------------------------------------------------------------
//  The hub (YogaHomeScreen) serves all three stages since 2026-10-16, but its
//  file still lives in post_pregnancy/ from when it was Parenting's alone. TTC
//  must import nothing from another stage's screens (ttc_shell_test), so TTC
//  reaches the shared hub through here instead of through that folder.
// =============================================================================

import 'package:flutter/widgets.dart';

import '../post_pregnancy/yoga_home_screen.dart';

/// The one Yoga & fitness hub, opening on For you for the current stage.
Widget pvMoveHub({String? backLabel}) => backLabel == null
    ? const YogaHomeScreen()
    : YogaHomeScreen(backLabel: backLabel);
