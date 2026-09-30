// =============================================================================
//  No random repetition on a Trying to Conceive screen (2026-09-28)
// -----------------------------------------------------------------------------
//  The user: "make sure in app there is no random repetition going on."
//
//  One general sweep, not one test per screen. Each screen below is pumped in
//  the states she can meet it in, and on each the sweep collects:
//
//    1. EVERY TAPPABLE: its visible label (the words inside it) and, by
//       calling its onTap, where it lands (the route that opens, identified
//       by its name and the words on it). Two tappables with the same label,
//       or two different tiles that land on the same page, fail.
//    2. EVERY IMAGE: a network or asset photo drawn twice on one screen fails.
//    3. EVERY SENTENCE: a line of five words or more said twice on one screen
//       fails.
//
//  ⚠️ THE LABEL IS THE WORDS, THE DESTINATION IS THE PAGE. Two reads open the
//  same reader screen, so the route type alone would call them duplicates.
//  The destination key is the route name plus every word on the page that
//  opened, so two reads differ and one read behind two tiles does not.
//
//  ⚠️ WHY onTap IS CALLED, NOT TAPPED. A card with a button inside it has two
//  tappables stacked; a tap at the card's centre can land on either. Calling
//  each GestureDetector's own handler reaches every one, on screen or not.
//
//  ALLOW-LIST. Only true exceptions, each with its reason, in `_allowed*`
//  below. A new entry needs a sentence saying why she is served by seeing the
//  same thing twice.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Kept for revert (2026-09-29): the bento sweeps are a block comment.
// import 'package:parentveda/screens/profile/pv_more_bento.dart';
import 'package:parentveda/screens/profile/pv_settings_screen.dart';
import 'package:parentveda/screens/profile/pv_you_chrome.dart' show PvYouSection;
import 'package:parentveda/screens/profile/pv_you_screen.dart';
import 'package:parentveda/screens/ttc/ttc_all_reads_screen.dart';
import 'package:parentveda/screens/ttc/ttc_all_videos_screen.dart';
import 'package:parentveda/screens/ttc/ttc_common.dart';
import 'package:parentveda/screens/ttc/ttc_home_v3.dart';
import 'package:parentveda/screens/ttc/ttc_home_version.dart';
import 'package:parentveda/screens/ttc/ttc_more_tab.dart';
import 'package:parentveda/screens/ttc/ttc_partner_screen.dart';
import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/screens/ttc/ttc_surface_router.dart' show openTtcSurface;
import 'package:parentveda/screens/ttc/ttc_transition_screen.dart' show TtcPositiveTestScreen;
import 'package:parentveda/screens/ttc/ttc_tools_screen.dart';
import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/ttc/cycle_store.dart';
import 'package:parentveda/ttc/ttc_log_store.dart';
import 'package:parentveda/ttc/ttc_ritual_store.dart';
import 'package:parentveda/ttc/ttc_store.dart';
import 'package:parentveda/ttc/ttc_symptom_data.dart';
import 'package:parentveda/ttc/ttc_treatment_store.dart';
import 'package:parentveda/widgets/pv_nav_bar.dart';

class _NoNet extends HttpOverrides {}

/// Flip to true to print every finding instead of failing on the first.
const _report = bool.fromEnvironment('PV_REPORT');

// ---------------------------------------------------------------------------
//  The collector
// ---------------------------------------------------------------------------

class _Tap {
  _Tap(this.element, this.label);
  final Element element;
  final String label;

  /// Where it landed, and its label at the moment it was called (a rail
  /// that moves a seen card to the end reuses its elements, so the label is
  /// read again right before the call).
  String? dest;
  String? destLabel;
  String? destName;

  /// False for a tappable collected but not called (see `_doNotFollow`).
  bool follow = true;
}

String _norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ').trim();

/// Every word drawn under [root], in tree order.
List<String> _textsUnder(Element root) {
  final out = <String>[];
  void visit(Element e) {
    final w = e.widget;
    // An icon's glyph is drawn as text; it is not a word.
    if (w is Icon) return;
    if (w is Text) {
      final s = w.data ?? w.textSpan?.toPlainText() ?? '';
      if (_norm(s).isNotEmpty) out.add(_norm(s));
      return;
    }
    if (w is RichText) {
      final s = w.text.toPlainText();
      if (_norm(s).isNotEmpty) out.add(_norm(s));
      return;
    }
    e.visitChildElements(visit);
  }

  visit(root);
  return out;
}

/// The label of a tappable: its words, or its semantics label or tooltip
/// when it has no words (an icon button).
String _labelOf(Element e) {
  final words = _textsUnder(e).join(' · ');
  if (words.isNotEmpty) return words;
  String? sem;
  void visit(Element c) {
    if (sem != null) return;
    final w = c.widget;
    if (w is Semantics && w.properties.label != null) {
      sem = w.properties.label;
      return;
    }
    if (w is Tooltip && w.message != null) {
      sem = w.message;
      return;
    }
    if (w is Icon && w.semanticLabel != null) {
      sem = w.semanticLabel;
      return;
    }
    c.visitChildElements(visit);
  }

  visit(e);
  if (sem == null) {
    // Look up the tree too: a Semantics(button: true, label: …) often wraps
    // the detector from outside.
    e.visitAncestorElements((a) {
      final w = a.widget;
      if (w is Semantics && w.properties.label != null) {
        sem = w.properties.label;
        return false;
      }
      return a.widget is! GestureDetector;
    });
  }
  return sem == null ? '' : 'semantics: $sem';
}

bool _inside<T extends Widget>(Element e) {
  var found = false;
  e.visitAncestorElements((a) {
    if (a.widget is T) {
      found = true;
      return false;
    }
    return true;
  });
  return found;
}

/// Every tappable on the current page (not on a route above it), minus the
/// bottom bar (a tab is a way out, not an item on the page) and any detector
/// that sits inside another with the same label (a press wrapper around an
/// InkWell is one tappable, not two).
List<_Tap> _tappables(WidgetTester tester, Route<dynamic>? page) {
  final raw = <_Tap>[];
  for (final e in find
      .byWidgetPredicate((w) => w is GestureDetector && w.onTap != null,
          skipOffstage: false)
      .evaluate()) {
    if (_inside<PvNavBar>(e)) continue;
    if (page != null && ModalRoute.of(e) != page) continue;
    raw.add(_Tap(e, _labelOf(e)));
  }
  // Drop a detector whose nearest detector ancestor has the same label.
  final keep = <_Tap>[];
  for (final t in raw) {
    var nested = false;
    t.element.visitAncestorElements((a) {
      final w = a.widget;
      if (w is GestureDetector && w.onTap != null) {
        nested = _labelOf(a) == t.label;
        return false;
      }
      return true;
    });
    if (!nested) keep.add(t);
  }
  return keep;
}

/// Every photo on the page: network URL or asset name.
List<String> _images(Route<dynamic>? page) {
  final out = <String>[];
  String? keyOf(ImageProvider p) {
    if (p is ResizeImage) return keyOf(p.imageProvider);
    if (p is NetworkImage) return p.url;
    if (p is AssetImage) return p.assetName;
    if (p is ExactAssetImage) return p.assetName;
    return null;
  }

  for (final e in find
      .byWidgetPredicate(
          (w) =>
              w is Image ||
              (w is DecoratedBox &&
                  w.decoration is BoxDecoration &&
                  (w.decoration as BoxDecoration).image != null),
          skipOffstage: false)
      .evaluate()) {
    if (page != null && ModalRoute.of(e) != page) continue;
    final w = e.widget;
    final k = w is Image
        ? keyOf(w.image)
        : keyOf(((w as DecoratedBox).decoration as BoxDecoration).image!.image);
    if (k != null) out.add(k);
  }
  return out;
}

class _Obs extends NavigatorObserver {
  final stack = <Route<dynamic>>[];
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.add(route);
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.remove(route);
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      stack.remove(route);
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) stack.remove(oldRoute);
    if (newRoute != null) stack.add(newRoute);
  }
}

/// What one screen showed.
class _Sweep {
  final taps = <_Tap>[];
  final images = <String>[];
  final texts = <String>[];
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 250));
  }
}

/// True for a tappable the sweep collects but does not call: a date on the
/// day strip (it re-points the whole home at another day, so every tap after
/// it would sweep a different screen) and the Developer section, which never
/// ships.
bool _doNotFollow(_Tap t) {
  if (_allowedLabelShapes.keys.any((r) => r.hasMatch(t.label))) return true;
  return _isDev(t);
}

/// Pumps [screen] tall and wide enough that every row and every rail is
/// built, and returns the observer watching its navigator.
Future<_Obs> _pump(WidgetTester tester, Widget screen,
    {Size size = const Size(2400, 16000)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final obs = _Obs();
  await tester.pumpWidget(MaterialApp(
    key: UniqueKey(),
    navigatorObservers: [obs],
    home: screen,
  ));
  await _settle(tester);
  return obs;
}

/// Opens the screen under test and returns the observer on its navigator,
/// with the screen as the top route.
typedef _Open = Future<_Obs> Function(WidgetTester tester);

/// Collects what the top route shows.
_Sweep _collect(WidgetTester tester, _Obs obs) {
  final page = obs.stack.last;
  final sweep = _Sweep()
    ..images.addAll(_images(page))
    ..texts.addAll([
      for (final e in find.byType(Text, skipOffstage: false).evaluate())
        if (ModalRoute.of(e) == page) ..._textsUnder(e),
    ]);
  // The Developer section never ships; it is not part of her screen.
  for (final t in _tappables(tester, page)) {
    if (_isDev(t)) continue;
    t.follow = !_doNotFollow(t);
    sweep.taps.add(t);
  }
  return sweep;
}

/// Collects the screen [open] reaches, then follows every tappable.
///
/// ⚠️ EACH TAP ON A FRESH SCREEN. A tap can change the screen it sits on
/// (a quick log takes the "log today" card off the rail, and every card
/// after it slides one place left), so following the taps one after another
/// on one screen reads one card's label against its neighbour's page. So
/// before each tap the stores are [reset], the screen is opened again, and
/// the tappable is found again by its place and its label.
Future<_Sweep> _sweepFresh(
    WidgetTester tester, _Open open, void Function() reset) async {
  reset();
  final sweep = _collect(tester, await open(tester));
  for (var i = 0; i < sweep.taps.length; i++) {
    final want = sweep.taps[i];
    if (!want.follow) continue;
    reset();
    final obs = await open(tester);
    final fresh = [
      for (final t in _tappables(tester, obs.stack.last))
        if (!_isDev(t)) t,
    ];
    _Tap? t = i < fresh.length && fresh[i].label == want.label
        ? fresh[i]
        : fresh.where((f) => f.label == want.label).firstOrNull;
    if (t == null) continue;
    final ro = t.element.findRenderObject();
    if (ro == null || !ro.attached) continue;
    final gd = t.element.widget as GestureDetector;
    final depth = obs.stack.length;
    try {
      gd.onTap!();
      await _settle(tester);
    } catch (_) {
      // A handler that needs a platform channel (a share, a phone call) is
      // not a page on this screen; skip it.
    }
    tester.takeException();
    if (obs.stack.length > depth) {
      final top = obs.stack.last;
      final words = <String>[
        for (final e in find.byType(Text, skipOffstage: false).evaluate())
          if (ModalRoute.of(e) == top) ..._textsUnder(e),
      ];
      // ⚠️ THE PAGE'S WORDS ARE ITS IDENTITY, NOT ITS ROUTE NAME. Two rows
      // on one More page pushed the same Your details screen under two route
      // names; by name they looked like two places.
      want.dest = words.take(60).join(' / ');
      want.destName = '${top.settings.name ?? top.runtimeType}';
    }
  }
  // Leave the tree clean for the next test.
  await tester.pumpWidget(const SizedBox());
  tester.takeException();
  return sweep;
}

bool _isDev(_Tap t) {
  var dev = false;
  t.element.visitAncestorElements((a) {
    final w = a.widget;
    if (w is PvYouSection && w.title.startsWith('Developer')) {
      dev = true;
      return false;
    }
    return true;
  });
  return dev;
}

/// A screen that is its own route.
_Open _screen(Widget w, {Size size = const Size(2400, 16000)}) =>
    (tester) => _pump(tester, w, size: size);

// ---------------------------------------------------------------------------
//  The allow-lists. Each entry: the exact thing, and why it may repeat.
// ---------------------------------------------------------------------------

/// Labels that may appear on more than one tappable on one screen.
const Map<String, String> _allowedLabels = {
  'Mark as done': 'The pill inside each of the five Sanskar cards on her home. '
      "The card's own title names the part ('Today's breath') right above "
      'the pill, and the pill says the act; the five are five different parts.',
  'Mark not done': 'The same pill once a part is done, taking the tick back.',
};

/// Label shapes that may repeat, with the reason.
final Map<RegExp, String> _allowedLabelShapes = {
  RegExp(r'^(S|M|T|W|F|TODAY) · \d{1,2}$'):
      'A date on the day strip. The strip spans seven weeks, so "T · 1" is '
          'the first of two months; the cells are different days.',
  RegExp(r"^(Yes|No|Not sure|None|Some|Mild|Moderate|Severe|Haven't noticed|"
          r"Didn't test|Positive|Negative|Immune \(a test says so\)|"
          r'Need the jab|Had the jab|Not for me|Correct|Remove|−|\+)$'):
      'An answer under a question, or a step or swipe action on a row: '
          'each question, vaccine or period row names what it answers, and '
          'the same answers under each is how a form reads (the PCOS check, '
          'the habits tracker, vaccinations, the Cycle companion).',
};

/// Destinations (by the label pair) two tappables may share.
const Map<String, String> _allowedDestinations = {};

/// Groups of tappables that may open one page: every label in the group
/// matches one of the rule's shapes. Each with its reason.
final List<(List<RegExp>, String)> _allowedDestinationRules = [
  (
    [RegExp(r'^Symptoms$'), RegExp(r'^Test$'), RegExp(r'^YOU LOGGED')],
    "The hero's Symptoms and Test buttons both open the logger for the "
        'selected day, Test at its pregnancy-test group further down the '
        'page. The "You logged today" card on the rail plays back what she '
        'logged, and "tap to see or change" can only mean the logger. A '
        'decision for the user (report, 2026-09-28).',
  ),
  (
    [RegExp(r'^Time to test · '), RegExp(r'^Should I test\?$')],
    "On a late day the hero's headline says 'Time to test' and its one pill "
        'under it names the chat. The headline opens what it says (the rule '
        'in _block, ttc_home_v3.dart); the pill is the labelled way in.',
  ),
  (
    [
      RegExp(r'^(IVF|IUI|FET|Frozen transfer|Tablets|Your round) · '),
      RegExp(r'^See your round$'),
      RegExp(r'[Bb]lood test'),
    ],
    "In a round the hero's headline is the round's step and opens the "
        'round; the pill under it (in the place of the one-tap row) names the '
        'blood test by date, or "See your round" when none is dated yet.',
  ),
];

/// Images that may be drawn twice.
const Map<String, String> _allowedImages = {};

/// Sentences that may be said twice.
const Map<String, String> _allowedTexts = {};

List<String> _findings(String screen, _Sweep s) {
  final out = <String>[];
  // 1a. Same label on two tappables.
  final byLabel = <String, int>{};
  for (final t in s.taps) {
    if (t.label.isEmpty) continue;
    byLabel[t.label] = (byLabel[t.label] ?? 0) + 1;
  }
  byLabel.forEach((label, n) {
    if (n > 1 &&
        !_allowedLabels.containsKey(label) &&
        !_allowedLabelShapes.keys.any((r) => r.hasMatch(label))) {
      out.add('$screen: "$label" is on $n tappables');
    }
  });
  // 1b. Two different tappables, one destination.
  final byDest = <String, List<String>>{};
  for (final t in s.taps) {
    if (t.dest == null) continue;
    byDest.putIfAbsent(t.dest!, () => []).add(t.destLabel ?? t.label);
  }
  byDest.forEach((dest, labels) {
    final distinct = labels.toSet();
    if (distinct.length > 1) {
      final key = (distinct.toList()..sort()).join(' + ');
      final ruled = _allowedDestinationRules.any((r) => distinct
          .every((l) => r.$1.any((shape) => shape.hasMatch(l))));
      if (!_allowedDestinations.containsKey(key) && !ruled) {
        out.add('$screen: ${distinct.map((l) => '"$l"').join(' and ')} '
            'all open ${dest.length > 160 ? '${dest.substring(0, 160)}…' : dest}');
      }
    }
  });
  // 2. Same image twice.
  final byImage = <String, int>{};
  for (final i in s.images) {
    byImage[i] = (byImage[i] ?? 0) + 1;
  }
  byImage.forEach((img, n) {
    if (n > 1 && !_allowedImages.containsKey(img)) {
      out.add('$screen: image $img is drawn $n times');
    }
  });
  // 3. Same sentence twice: five words or more, and not an all-capitals
  // eyebrow or meta line ("HIS SIDE · 6 MIN READ" under two reads is a
  // label of each, not a sentence said twice).
  final byText = <String, int>{};
  for (final t in s.texts) {
    final words = RegExp(r"[A-Za-z][A-Za-z']*").allMatches(t).length;
    if (words < 5 || t == t.toUpperCase()) continue;
    // The words of an allowed repeated label ("Immune (a test says so)", an
    // answer under each vaccine) are that label, not a sentence said twice.
    if (_allowedLabels.containsKey(t) ||
        _allowedLabelShapes.keys.any((r) => r.hasMatch(t))) {
      continue;
    }
    byText[t] = (byText[t] ?? 0) + 1;
  }
  byText.forEach((text, n) {
    if (n > 1 && !_allowedTexts.containsKey(text)) {
      out.add('$screen: "$text" is said $n times');
    }
  });
  return out;
}

void _check(String screen, _Sweep s) {
  final f = _findings(screen, s);
  if (_report) {
    // ignore: avoid_print
    print('=== $screen: ${s.taps.length} tappables, ${s.images.length} images');
    for (final t in s.taps) {
      final dl = t.destLabel != null && t.destLabel != t.label
          ? ' (then "${t.destLabel}")'
          : '';
      // ignore: avoid_print
      print('  TAP "${t.label}"$dl -> ${t.destName ?? ''} '
          '${t.dest == null ? '-' : t.dest!.substring(0, t.dest!.length.clamp(0, 120))}');
    }
    for (final x in f) {
      // ignore: avoid_print
      print('  !! $x');
    }
    return;
  }
  expect(f, isEmpty, reason: f.join('\n'));
}

// ---------------------------------------------------------------------------

/// Fails with the Row or Column that overflowed, by its creator chain: the
/// framework's own message says only how many pixels.
void _expectNoOverflow(WidgetTester tester, String when) {
  final e = tester.takeException();
  if (e == null) return;
  final where = <String>[];
  void visit(RenderObject ro) {
    if (ro is RenderFlex && ro.hasSize) {
      var sum = 0.0;
      ro.visitChildren((c) {
        if (c is RenderBox && c.hasSize) {
          sum += ro.direction == Axis.horizontal ? c.size.width : c.size.height;
        }
      });
      final own =
          ro.direction == Axis.horizontal ? ro.size.width : ro.size.height;
      if (sum > own + 1) {
        where.add('${(sum - own).toStringAsFixed(0)}px: ${ro.debugCreator}');
      }
    }
    ro.visitChildren(visit);
  }

  for (final v in tester.binding.renderViews) {
    visit(v);
  }
  fail('$when: $e ${where.join(' ; ')}');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => HttpOverrides.global = _NoNet());

  final today = DateTime.now();
  DateTime day(int daysAgo) {
    final d = today.subtract(Duration(days: daysAgo));
    return DateTime(d.year, d.month, d.day);
  }

  void resetAll() {
    SharedPreferences.setMockInitialValues({});
    CycleStore.instance.resetForTest();
    TtcStore.instance.resetForTest();
    TtcLogStore.instance.resetForTest();
    TtcTreatmentStore.instance.resetForTest();
    TtcRitualStore.instance.resetForTest();
    LifeStageStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
    TtcHomeVersionStore.instance.set(TtcHomeVersion.v3);
  }

  setUp(() {
    resetAll();
    TtcPartnerMode.instance.on = false;
  });

  /// Her cycle with its last period [daysAgo] days back.
  void cycleOn(int daysAgo) {
    CycleStore.instance
      ..logPeriodStart(day(daysAgo + 56))
      ..logPeriodStart(day(daysAgo + 28))
      ..logPeriodStart(day(daysAgo));
  }

  void logSome() {
    for (final id in ['cramping', 'disch_eggwhite', 'calm']) {
      TtcLogStore.instance.log(kTtcSymptomTracker, id, 1, on: today);
    }
  }

  /// Resets every store, then sets up [arrange].
  void Function() fresh(void Function() arrange) => () {
        resetAll();
        arrange();
      };

  final herDays = <String, void Function()>{
    'nothing logged': () {},
    'period day 2': () => cycleOn(1),
    'fertile, with logs': () {
      cycleOn(12);
      logSome();
    },
    'two-week wait': () => cycleOn(22),
    'late': () => cycleOn(33),
    'in an IVF round': () {
      cycleOn(8);
      TtcTreatmentStore.instance.startRound(
          kind: TtcRoundKind.ivfFresh,
          dates: {
            TtcTreatmentStep.stimStart: day(4),
            TtcTreatmentStep.retrieval: day(-9),
          });
    },
  };

  group('her home', () {
    herDays.forEach((name, arrange) {
      testWidgets(name, (tester) async {
        _check(
            'her home ($name)',
            await _sweepFresh(
                tester, _screen(const TtcHomeV3()), fresh(arrange)));
      });
    });
  });

  group('his side', () {
    setUp(() => TtcPartnerMode.instance.on = true);
    tearDown(() => TtcPartnerMode.instance.on = false);
    testWidgets('his home', (tester) async {
      _check(
          'his home',
          await _sweepFresh(tester, _screen(const TtcPartnerTodayScreen()),
              fresh(() => cycleOn(12))));
    });
    testWidgets('his tools', (tester) async {
      _check(
          'his tools',
          await _sweepFresh(
              tester, _screen(const TtcToolsScreen()), fresh(() {})));
    });
  });

  testWidgets('the Tools hub', (tester) async {
    _check(
        'Tools hub',
        await _sweepFresh(tester, _screen(const TtcToolsScreen()),
            fresh(() => cycleOn(12))));
  });

  // ⚠️ 2026-09-29: the More tab is its own screen of offerings, and the
  // avatar opens her profile with one Settings row. Each of the three is
  // swept. The bento's two sweeps are kept below as a block comment.
  const moreTab = TtcMoreTab(bottomNav: TtcBottomNav(active: 4, v3: true));
  const profile = PvYouScreen(stage: LifeStage.tryingToConceive);

  testWidgets('the More tab', (tester) async {
    _check(
        'More tab',
        await _sweepFresh(
            tester,
            _screen(moreTab, size: const Size(1200, 6000)),
            fresh(() => cycleOn(12))));
  });

  testWidgets('his More tab', (tester) async {
    TtcPartnerMode.instance.on = true;
    addTearDown(() => TtcPartnerMode.instance.on = false);
    _check(
        'his More tab',
        await _sweepFresh(
            tester,
            _screen(moreTab, size: const Size(1200, 6000)),
            fresh(() => cycleOn(12))));
  });

  // ⚠️ 2026-09-29: More's "Read and watch" pages. All videos is swept in
  // full (every card followed). All articles lists every read once, so its
  // labels, images and sentences are collected but its 130-odd rows are not
  // each followed: every row opens the one reader, which the doors' sweeps
  // already follow, and test/ttc_all_reads_videos_test.dart checks the route.
  testWidgets('All articles', (tester) async {
    final obs = await _pump(tester, const TtcAllReadsScreen(),
        size: const Size(1200, 30000));
    _check('All articles', _collect(tester, obs));
  });

  testWidgets('All videos', (tester) async {
    _check(
        'All videos',
        await _sweepFresh(
            tester,
            _screen(const TtcAllVideosScreen(), size: const Size(1200, 9000)),
            fresh(() => cycleOn(12))));
  });

  testWidgets('the profile', (tester) async {
    _check(
        'Profile',
        await _sweepFresh(
            tester,
            _screen(profile, size: const Size(1200, 6000)),
            fresh(() => cycleOn(12))));
  });

  testWidgets('Settings', (tester) async {
    Future<_Obs> open(WidgetTester tester) async {
      final obs = await _pump(tester, profile, size: const Size(1200, 6000));
      await tester.ensureVisible(find.byKey(kPvProfileSettingsRowKey));
      await tester.tap(find.byKey(kPvProfileSettingsRowKey));
      await _settle(tester);
      expect(find.byType(PvSettingsScreen), findsOneWidget);
      return obs;
    }

    _check('Settings',
        await _sweepFresh(tester, open, fresh(() => cycleOn(12))));
  });

  /* Kept for revert (2026-09-29), the bento's sweeps:
  const ttcMore = PvYouScreen(
    stage: LifeStage.tryingToConceive,
    bottomNav: TtcBottomNav(active: 4, v3: true),
  );

  testWidgets('the More grid', (tester) async {
    _check(
        'More grid',
        await _sweepFresh(tester, _screen(ttcMore, size: const Size(1200, 6000)),
            fresh(() => cycleOn(12))));
  });

  testWidgets('every More page', (tester) async {
    await _pump(tester, ttcMore, size: const Size(1200, 6000));
    final ids = [
      for (final e in find
          .byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key as ValueKey<String>).value.startsWith('pv_more_tile_'))
          .evaluate())
        (e.widget.key as ValueKey<String>).value,
    ];
    expect(ids, isNotEmpty);
    final all = <String>[];
    for (final id in ids) {
      var title = id;
      // The page behind the tile, opened the way her thumb opens it.
      Future<_Obs> open(WidgetTester tester) async {
        final obs = await _pump(tester, ttcMore, size: const Size(1200, 6000));
        await tester.ensureVisible(find.byKey(ValueKey(id)));
        await tester.tap(find.byKey(ValueKey(id)));
        await _settle(tester);
        expect(find.byType(PvMoreGroupScreen), findsOneWidget, reason: id);
        title = tester
            .widget<PvMoreGroupScreen>(find.byType(PvMoreGroupScreen))
            .title;
        return obs;
      }

      final s = await _sweepFresh(tester, open, fresh(() => cycleOn(12)));
      all.addAll(_findings('More › $title', s));
      if (_report) {
        _check('More › $title', s);
      }
    }
    if (!_report) {
      expect(all, isEmpty, reason: all.join('\n'));
    }
  });
  */

  // ⚠️ EVERY TOOL, AND THE CYCLE SCREENS THE HUB DOES NOT LIST. Collected
  // (labels, photos, sentences), not followed: each opens from the hub or
  // the home the way her thumb opens it, through its own opener.
  group('every tool screen', () {
    /// Opens [opener] from a bare screen and returns with its page on top.
    _Open via(void Function(BuildContext) opener) => (tester) async {
          final obs = await _pump(
              tester,
              Scaffold(
                body: Builder(
                  builder: (c) => TextButton(
                    key: const ValueKey('open'),
                    onPressed: () => opener(c),
                    child: const Text('open'),
                  ),
                ),
              ),
              size: const Size(1200, 8000));
          await tester.tap(find.byKey(const ValueKey('open')));
          await _settle(tester);
          return obs;
        };

    final screens = <String, void Function(BuildContext)>{
      for (final g in ttcToolGroups)
        for (final tool in g.tools)
          if (tool.built) 'Tools › ${tool.nameEn}': tool.open,
      'Calendar': (c) => openTtcSurface(c, 'ttc_calendar'),
      'Cycle report': (c) => openTtcSurface(c, 'ttc_cycle_report'),
      'Messages': (c) => openTtcSurface(c, 'ttc_messages'),
      // A Tools row since 2026-09-28 ("Tools › Treatment cycle" above).
      // Kept for revert:
      //   'Treatment': (c) => openTtcSurface(c, 'ttc_treatment'),
      'Ritual': (c) => openTtcSurface(c, 'ttc_ritual'),
      'Positive test': (c) => Navigator.of(c).push(MaterialPageRoute<void>(
          builder: (_) => const TtcPositiveTestScreen())),
    };
    for (final e in screens.entries) {
      testWidgets(e.key, (tester) async {
        cycleOn(12);
        logSome();
        final obs = await via(e.value)(tester);
        if (obs.stack.length < 2) return; // opened a sheet or nothing
        final s = _collect(tester, obs);
        for (final t in s.taps) {
          t.follow = false;
        }
        await tester.pumpWidget(const SizedBox());
        tester.takeException();
        _check(e.key, s);
      });
    }
  });

  // ⚠️ HIS HOME AT A PHONE'S WIDTH (the brief: "check the TTC home at 390px
  // for his home's reported 61px overflow"). An overflow is thrown as an
  // exception while laying out, so every scroll position is checked.
  group('at 390 wide', () {
    Future<void> walk(WidgetTester tester, Widget screen) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(MaterialApp(key: UniqueKey(), home: screen));
      await _settle(tester);
      _expectNoOverflow(tester, 'on open');
      final list = find.byType(Scrollable).first;
      for (var i = 0; i < 16; i++) {
        await tester.drag(list, const Offset(0, -500));
        await tester.pump(const Duration(milliseconds: 200));
        _expectNoOverflow(tester, 'after scroll $i');
      }
    }

    testWidgets('his home', (tester) async {
      TtcPartnerMode.instance.on = true;
      addTearDown(() => TtcPartnerMode.instance.on = false);
      cycleOn(12);
      await walk(tester, const TtcPartnerTodayScreen());
    });

    for (final e in herDays.entries) {
      testWidgets('her home (${e.key})', (tester) async {
        e.value();
        await walk(tester, const TtcHomeV3());
      });
    }
  });
}
