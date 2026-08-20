// =============================================================================
//  PvVideoSlot — a film the app will hold, declared before it is shot
// -----------------------------------------------------------------------------
//  ⚠️ NOT `PvVideo`. That name is TAKEN, by `lib/models/pv_video.dart` — the
//  pregnancy "Watch & Learn" model (`title`, `reason`, `duration`, a
//  `VideoCategory`, a week range). This file was very nearly written over the
//  top of it, which broke 86 test files at once and is exactly the kind of
//  collision a distinct name prevents.
//
//  The two are genuinely different things and both should exist:
//
//    · `PvVideo`     — a finished catalogue entry, picked BY WEEK for the
//                      pregnancy weekly flow. Its duration is a display string.
//    · `PvVideoSlot` — a DECLARED slot with an id, chapters and takeaways,
//                      written long before any file exists, resolved by id from
//                      an article body or a hub door.
//
//  "Slot" is also simply the more accurate word for what this is, which is why
//  it is not a grudging rename: the entry's whole purpose is to reserve a
//  position in a page and describe what will fill it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE POINT OF DECLARING A VIDEO BEFORE IT IS SHOT
//  ---------------------------------------------------------------------------
//
//  `lib/widgets/pv_placeholders.dart` was written against one piece of feedback
//  that is right about every placeholder in this product:
//
//    "Right now you have just returned the video name in a bar. You should
//     basically show complete thumbnail and write the head in the way it will
//     appear. Finally only the video will get added later."
//
//  A one-line row saying "Explainer · 6 MIN" cannot be reviewed. It does not
//  occupy the space the video will occupy and does not sit at the ratio the
//  video will sit at, so the SHAPE of a screen cannot be judged until the
//  content arrives — which is backwards, since reviewing the shape early is the
//  entire reason for building ahead of content.
//
//  So a slot is a real entry with a real title, duration, reason to watch and
//  chapter list. What is missing is the FILE, and only the file. [url] is the
//  one nullable field that decides everything: null means placeholder treatment
//  everywhere, non-null means it plays.
//
//  ⚠️ AND IT STAYS HONEST. Looking real is not pretending to be real. Nothing
//  built on this model may show a play control that plays nothing — a
//  placeholder that looks tappable and does nothing teaches her that taps do
//  nothing, everywhere in the app.
//
//  ⚠️ SELF-HOSTED MP4/HLS ONLY. YouTube was tested to exhaustion on 2026-07-12,
//  is systemically blocked, and the code was removed. Do not re-propose it.
//  [url] is filled from the authenticated backend as a signed URL in
//  production — never hardcoded in a data file.
// =============================================================================

import 'package:flutter/foundation.dart';

import '../localization/app_language.dart';

/// One chapter of a film. Rendered as a list under the player, and as the
/// "what this covers" list while the film is still a placeholder.
///
/// ⚠️ CARRIED EVEN WHILE THERE IS NO FILE, deliberately. A chapter list is the
/// single most useful thing on a video page for someone deciding whether to
/// spend six minutes, and it is writable long before anything is shot. It is
/// also what stops a placeholder page from being one sentence and a grey box.
@immutable
class PvVideoChapter {
  const PvVideoChapter({required this.at, required this.label});

  /// Seconds from the start. Shown as `m:ss`.
  final int at;
  final LocalizedText label;

  String get stamp {
    final m = at ~/ 60;
    final s = (at % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

@immutable
class PvVideoSlot {
  const PvVideoSlot({
    required this.id,
    required this.title,
    required this.why,
    required this.seconds,
    required this.hue,
    required this.expert,
    required this.expertRole,
    this.chapters = const [],
    this.takeaways = const [],
    this.url,
    this.readNext = const [],
    this.surfaceNext = const [],
  });

  /// ⚠️ THIS IS THE `slotId` THE PLACEHOLDERS CARRY. One id, declared once, so
  /// the wiring is stated at the moment the placeholder is written rather than
  /// worked out again when the file lands.
  final String id;

  final LocalizedText title;

  /// One line on why it is worth her time — the same required-reason rule
  /// `JourneyElement.value` and `HubNeed.blurb` both carry.
  final LocalizedText why;

  final int seconds;

  /// Tint off the controlled wheel, so a page holding three of these does not
  /// read as three grey boxes.
  final double hue;

  final LocalizedText expert;
  final LocalizedText expertRole;

  final List<PvVideoChapter> chapters;

  /// The two or three things she leaves with. Shown under the film, and shown
  /// INSTEAD of the film while this is a placeholder — so the page is useful on
  /// the day it ships, not only on the day the file arrives.
  final List<LocalizedText> takeaways;

  /// Null until a real file exists. THE flag: null means every surface treats
  /// this as a placeholder and refuses the tap into playback.
  final String? url;

  /// Read ids to chain onward into.
  final List<String> readNext;

  /// Surface ids — the tool or the person this film should hand her to.
  final List<String> surfaceNext;

  bool get isLive => url != null;

  String get durationLabel {
    final m = (seconds / 60).ceil();
    return '$m min';
  }
}
