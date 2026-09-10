// =============================================================================
//  Where a door's tiles and surfaces go
// -----------------------------------------------------------------------------
//  ⚠️ THE SCREEN NEVER IMPORTS A DESTINATION, AND THE DATA NEVER NAMES A
//  WIDGET. This file is the join, and it is the only thing in the door engine
//  that knows what a `ScanTimelineScreen` is.
//
//  That split is what makes the next seven briefs a data change rather than a
//  screen change: a door declares surface ids, this file resolves them, and
//  `pv_door_screen.dart` renders whatever comes back without knowing what it
//  is looking at.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVERY PUSH CARRIES A ROUTE NAME, AND THE NAME IS LOAD-BEARING
//  ---------------------------------------------------------------------------
//
//  `global_ask_fab.dart` reads the route name to decide which Ask Veda opens
//  and what context it receives. The brief's one instruction about Ask Veda is
//  that a scan page and a result page must pass their context — and the
//  mechanism for that is already built and already works, provided the route
//  has a name.
//
//  So an anonymous `MaterialPageRoute` here would not fail, crash or log. The
//  screen would open, look right, and the sparkle button in the corner would
//  quietly ask the wrong brain. That is the shape of failure this repo has hit
//  before, which is why the ids are constants in the data file rather than
//  literals typed twice.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NULL IS A REAL ANSWER
//  ---------------------------------------------------------------------------
//
//  An unknown surface id returns null and opens nothing, rather than guessing
//  at the nearest screen. A wrong destination is worse than none: it looks like
//  it worked. `test/pv_door_scans_test.dart` walks every tile on every door and
//  asserts that each one resolves, so the null branch is unreachable from
//  anything that ships — which is the point of having it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/doors/pv_door_data.dart';
import '../../data/reads/pregnancy_reads.dart';
import '../../data/tests_scans_reports_data.dart';
import '../../services/pregnancy_controller.dart';
import '../brackets/scan_detail_screen.dart';
import '../brackets/scan_next_screen.dart';
import '../brackets/scan_questions_screen.dart';
import '../brackets/scan_reports_screen.dart';
import '../brackets/scan_timeline_screen.dart';
import '../brackets/scan_urgent_screen.dart';
import '../prepare/consultations_screen.dart';
import '../reader/pv_reader_screen.dart';
import '../report_screen.dart';
import '../tools/tests_scans_reports_screen.dart';

/// The screen a door surface opens, or null when nothing does.
Widget? pvDoorScreenFor(String id, PregnancyController c) => switch (id) {
      kScansSurfaceTimeline => ScanTimelineScreen(pregnancy: c),
      kScansSurfaceNext => ScanNextScreen(pregnancy: c),
      kScansSurfaceReports => ScanReportsScreen(pregnancy: c),
      kScansSurfaceDecoder => ReportScreen(controller: c),
      kScansSurfaceUrgent => const ScanUrgentScreen(),
      kScansSurfaceQuestions => ScanQuestionsScreen(pregnancy: c),
      kScansSurfaceConsult => ConsultationsScreen(lang: c.language),

      // ⚠️ THE RESLOT, AND IT IS THE SAME TOOL — NOT A COPY OF IT.
      //
      // "Your report, line by line" is the parameter table inside a scan page:
      // every reading, the usual range, and what it means when hers sits
      // outside it. The brief moves it to My reports and says twice that it
      // must stay single-source — "if it is opened from a scan page too, it is
      // the same tool, not a copy."
      //
      // A scan page reaches it with a scan already chosen. From My reports
      // there is no scan yet, so the library asks which report she is holding
      // and then opens exactly the same screen with `openParameters` set. The
      // scan pages are untouched and still open it directly.
      //
      // ⚠️ THE LIBRARY IS REUSED RATHER THAN A PICKER BEING BUILT.
      // `TestsScansReportsScreen` already lists every test and scan with
      // trimester filters and already opens `TestScanDetailScreen`. Building a
      // second list would have been a second place for the scan library to
      // drift, to answer a question this screen already answers.
      kScansSurfaceParameters => TestsScansReportsScreen(
          controller: c,
          openParameters: true,
          testsOnly: true,
          title: 'Your report, line by line',
          intro: 'Which report are you holding? Open it to see every reading, '
              'the usual range, and what it means when yours sits outside it.',
        ),

      _ => null,
    };

/// The tool a group renders IN PLACE, or null when it is not an inline tool.
///
/// ⚠️ INLINE MEANS A BODY, NOT A SCREEN. Every widget returned here is a
/// `Column` with no `Scaffold` and no app bar — see `ScanTimelineBody`. A
/// `Scaffold` nested inside the door's `ListView` would bring a second
/// background, a second safe area and an unbounded height.
Widget? pvDoorInlineToolFor(String id, PregnancyController c) => switch (id) {
      kScansSurfaceTimeline => ScanTimelineBody(pregnancy: c),
      kScansSurfaceReports => ScanReportsBody(pregnancy: c),
      // ⚠️ A FLAG RATHER THAN A BODY WIDGET, and the reason is on
      // `ReportScreen.embedded`: the decoder's content is inseparable from its
      // filter state, so a body would either duplicate that state or wrap it.
      kScansSurfaceDecoder => ReportScreen(controller: c, embedded: true),
      _ => null,
    };

/// Push a surface, named.
void openPvDoorSurface(
    BuildContext context, String id, PregnancyController c) {
  final screen = pvDoorScreenFor(id, c);
  if (screen == null) return; // null is a real answer; see the header
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: id),
    builder: (_) => screen,
  ));
}

/// Open whatever a tile is.
///
/// ⚠️ EVERY BRANCH PUSHES A SCREEN. No bottom sheets: a sheet caps the content
/// at half a screen and tells the reader that what she tapped was minor, and
/// she cannot see which she is getting before she taps. Tapping a piece of
/// content opens that piece of content, full screen, every time.
///
/// ⚠️ AND THE SWITCH IS EXHAUSTIVE OVER A SEALED TYPE. Adding an eighth tile
/// format makes this fail to compile and names the file that has not handled
/// it — rather than the app rendering a card that does nothing.
void openPvDoorTile(
    BuildContext context, PvDoorTile tile, PregnancyController c) {
  // ⚠️ A COMING-SOON CARD IS NOT TAPPABLE AT ALL, and the card draws itself
  // that way. This is the second gate rather than the first: the honest
  // treatment is on the card, and this exists so a route can never be reached
  // by a stray semantics tap or a test driving the tile directly.
  if (tile.comingSoon) return;

  switch (tile) {
    case PvDoorToolTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

    case PvDoorChecklistTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

    case PvDoorTalkTile(:final surfaceId):
      openPvDoorSurface(context, surfaceId, c);

    case PvDoorReadTile(:final surfaceId):
      // Null only on the coming-soon form, which returned above.
      if (surfaceId != null) openPvDoorSurface(context, surfaceId, c);

    // ---- one scan, on the page the stage already ships ----------------------
    case PvDoorScanTile(:final scanId):
      final scan = _scanById(scanId);
      if (scan == null) return; // caught by the wiring test, never by a user
      Navigator.of(context).push(MaterialPageRoute<void>(
        // ⚠️ THE SCAN PAGE'S OWN ROUTE NAME, unchanged from when it was reached
        // through the hub. Ask Veda's context comes off this.
        settings: const RouteSettings(name: 'scans/detail'),
        builder: (_) => ScanDetailScreen(scan: scan, pregnancy: c),
      ));

    // ---- reading ------------------------------------------------------------
    case PvDoorGuideTile(:final readId, :final atHeading):
      openPvDoorRead(context, readId, c, atHeading: atHeading);

    case PvDoorMythTile(:final readId):
      openPvDoorRead(context, readId, c);
  }
}

/// Open a pregnancy read in the shared reader.
///
/// ⚠️ THE READER IS STAGE-NEUTRAL AND STAYS THAT WAY. It takes `openRead`,
/// `openSurface` and `readTitle` as callbacks precisely so it never has to hold
/// a stage's library — which is what let pregnancy start its own without
/// touching TTC's. Passing pregnancy's lookups here is the whole of the
/// wiring.
void openPvDoorRead(
  BuildContext context,
  String readId,
  PregnancyController c, {
  String? atHeading,
}) {
  final read = pregnancyReadById(readId);
  if (read == null) return; // the wiring test makes this unreachable
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: RouteSettings(name: 'read/$readId'),
    builder: (_) => PvReaderScreen(
      read: read,
      // ⚠️ THE STAGE'S OWN LANGUAGE, NOT A GLOBAL. Pregnancy's flag lives on
      // the controller; reading TTC's would render Devanagari inside an English
      // shell. The reader does not guess and must not.
      lang: c.language,
      openAtHeading: atHeading,
      readTitle: pregnancyReadTitle,
      openRead: (ctx, id) => openPvDoorRead(ctx, id, c),
      openSurface: (ctx, id) => openPvDoorSurface(ctx, id, c),
    ),
  ));
}

/// The scan library entry for an id, or null.
TestScanInfo? _scanById(String id) {
  for (final s in kTestsScans) {
    if (s.id == id) return s;
  }
  return null;
}

/// Whether a surface id opens anything at all. Used by the wiring test.
bool pvDoorSurfaceResolves(String id) => switch (id) {
      kScansSurfaceTimeline ||
      kScansSurfaceNext ||
      kScansSurfaceReports ||
      kScansSurfaceDecoder ||
      kScansSurfaceUrgent ||
      kScansSurfaceQuestions ||
      kScansSurfaceConsult ||
      kScansSurfaceParameters =>
        true,
      _ => false,
    };
