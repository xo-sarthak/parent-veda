// =============================================================================
//  Ask Veda as a search - the shared shell (2026-10-31)
//
//  The approved prototype ("ASK VEDA: a search, Google's mobile flow") has four
//  states, drawn once for the three stages. What this holds:
//    1. HOME   the bar, the context line, four shortcuts, the stage's tiles;
//              no text field until she taps the bar.
//    2. TYPING suggestions filter by prefix, the completion in bold, her own
//              words first; tapping one asks it.
//    3. RESULTS tabs filter the sections; "Show more" opens What to do; a RED
//              FLAG answer is never collapsed; an empty tab is an invitation;
//              offline keeps its retry and the app's own pages.
//    4. WIRING all three screens draw it, and the removed "People also ask"
//              is not drawn (the service does not send it).
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ask_veda/ask_veda_search_shell.dart';
import 'package:parentveda/services/remote/ask_veda_service.dart';

AskVedaResult _result({
  String source = 'llm',
  List<String> actions = const ['Go to sleep on your side.'],
  List<VedaFeedItem> content = const [],
  List<VedaFeedItem> videos = const [],
}) => AskVedaResult(
  answer: 'Side sleeping is best from now on.',
  meaning: 'The weight of the womb can press on a large vein.',
  actions: actions,
  content: content,
  videos: videos,
  products: const [],
  services: const [],
  source: source,
  cacheHit: false,
);

const _read = VedaFeedItem(
  docId: 'pvread_x',
  kind: 'pvread',
  title: 'Sleeping well in the second trimester',
);

/// A stand-in for a stage screen: it owns the state, the shell only draws.
class _Harness extends StatefulWidget {
  const _Harness({
    this.result,
    this.failed = false,
    this.onOpened,
    this.initialQuery,
  });
  final AskVedaResult? result;
  final bool failed;
  final void Function(VedaFeedItem, VedaSection)? onOpened;
  static const suggestions = [
    'Is it safe to sleep on my back now?',
    'What does the glucose test involve?',
    'How much iron do I need?',
    'Can I eat papaya?',
    'A fifth question',
  ];
  final String? initialQuery;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late String? q = widget.initialQuery;
  final asked = <String>[];
  int retries = 0;

  @override
  Widget build(BuildContext context) => AskVedaSearchShell(
    contextLine: 'week 24 of your pregnancy',
    suggestHeading: 'Asked often in week 24',
    suggestions: _Harness.suggestions,
    pool: const ['Is the left side better than the right?'],
    query: q,
    loading: false,
    failed: widget.failed,
    result: q == null || widget.failed ? null : widget.result,
    badge: 'Week 24',
    onAvatar: () {},
    onAsk: (t) => setState(() {
      asked.add(t);
      q = t;
    }),
    onClear: () => setState(() => q = null),
    onRetry: () => retries++,
    onOpen: (it, s) => widget.onOpened?.call(it, s),
    disclaimer: 'General information, not medical advice.',
    offlineExtras: [VedaRow(title: 'Sleep in pregnancy', onTap: () {})],
  );
}

Future<_HarnessState> _pump(WidgetTester t, _Harness h) async {
  t.view.physicalSize = const Size(900, 2400);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  SharedPreferences.setMockInitialValues({});
  // Reduced motion: the answer shows at once instead of typing in.
  await t.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(
          disableAnimations: true,
          size: Size(900, 2400),
        ),
        child: h,
      ),
    ),
  );
  await t.pump(const Duration(milliseconds: 400));
  return t.state<_HarnessState>(find.byType(_Harness));
}

Future<void> _settle(WidgetTester t) async {
  for (var i = 0; i < 6; i++) {
    await t.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  group('home', () {
    testWidgets('the bar, the context line, four shortcuts, four tiles', (
      t,
    ) async {
      await _pump(t, const _Harness());
      expect(find.text('Ask Veda'), findsOneWidget);
      expect(find.text('Ask or search anything'), findsOneWidget);
      expect(
        find.textContaining('week 24 of your pregnancy', findRichText: true),
        findsOneWidget,
      );
      for (final k in ['reads', 'videos', 'products', 'experts']) {
        expect(
          find.byKey(ValueKey('veda_short_$k')),
          findsOneWidget,
          reason: k,
        );
      }
      expect(find.text('ASKED OFTEN IN WEEK 24'), findsOneWidget);
      expect(find.text('Is it safe to sleep on my back now?'), findsOneWidget);
      expect(
        find.text('A fifth question'),
        findsNothing,
        reason: 'home shows four tiles',
      );
      expect(
        find.byType(TextField),
        findsNothing,
        reason: 'the field appears when she taps the bar',
      );
    });

    testWidgets('a tile asks its question', (t) async {
      final s = await _pump(t, const _Harness(result: null));
      await t.tap(find.text('What does the glucose test involve?'));
      await _settle(t);
      expect(s.asked, ['What does the glucose test involve?']);
    });
  });

  group('typing', () {
    testWidgets('prefix matches, the completion in bold, her words first', (
      t,
    ) async {
      final s = await _pump(t, const _Harness());
      await t.tap(find.byKey(const ValueKey('veda_home_bar')));
      await _settle(t);
      expect(find.byType(TextField), findsOneWidget);
      // Empty field: the stage's questions.
      expect(find.text('How much iron do I need?'), findsOneWidget);

      await t.enterText(find.byType(TextField), 'is it');
      await _settle(t);
      expect(find.byKey(const ValueKey('veda_sug_typed')), findsOneWidget);
      // Typed prefix regular, completion bold: two spans in one RichText.
      final rich = find.byWidgetPredicate(
        (w) =>
            w is RichText &&
            w.text.toPlainText() == 'Is it safe to sleep on my back now?',
      );
      expect(rich, findsOneWidget);
      final root = (t.widget(rich) as RichText).text as TextSpan;
      // Text.rich wraps the span it is given in a root span of its own.
      final spans = (root.children!.single as TextSpan).children!
          .cast<TextSpan>();
      expect(spans.first.text, 'Is it');
      expect(spans.last.text, ' safe to sleep on my back now?');
      expect(spans.last.style!.fontWeight, FontWeight.w800);
      expect(
        find.text('How much iron do I need?'),
        findsNothing,
        reason: 'not a prefix match, so filtered out',
      );

      await t.tap(rich);
      await _settle(t);
      expect(s.asked, ['Is it safe to sleep on my back now?']);
    });

    testWidgets('a question from the wider pool still completes', (t) async {
      await _pump(t, const _Harness());
      await t.tap(find.byKey(const ValueKey('veda_home_bar')));
      await _settle(t);
      await t.enterText(find.byType(TextField), 'is the left');
      await _settle(t);
      expect(
        find.textContaining('Is the left side better', findRichText: true),
        findsOneWidget,
      );
    });
  });

  group('results', () {
    testWidgets('answer, what it means, Show more reveals What to do', (
      t,
    ) async {
      await _pump(
        t,
        _Harness(
          result: _result(content: const [_read]),
          initialQuery: 'sleep',
        ),
      );
      await _settle(t);
      expect(find.text("Veda's answer"), findsOneWidget);
      expect(find.text('Side sleeping is best from now on.'), findsOneWidget);
      expect(find.text('WHAT IT MEANS'), findsOneWidget);
      expect(find.text('Go to sleep on your side.'), findsNothing);
      expect(find.text('Show more'), findsOneWidget);

      await t.tap(find.byKey(const ValueKey('veda_show_more')));
      await _settle(t);
      expect(find.text('Go to sleep on your side.'), findsOneWidget);
      expect(find.text('Show less'), findsOneWidget);
      // The disclaimer sits at the foot of the card; the read is a result.
      expect(find.byKey(const ValueKey('veda_disclaimer')), findsOneWidget);
      expect(find.text(_read.title), findsOneWidget);
    });

    testWidgets('a red flag keeps What to do open, with no toggle', (t) async {
      await _pump(
        t,
        _Harness(
          result: _result(source: 'red_flag'),
          initialQuery: 'bleeding',
        ),
      );
      await _settle(t);
      expect(find.text('Go to sleep on your side.'), findsOneWidget);
      expect(find.byKey(const ValueKey('veda_show_more')), findsNothing);
    });

    testWidgets('tabs filter; an empty tab is an invitation', (t) async {
      final opened = <VedaSection>[];
      await _pump(
        t,
        _Harness(
          result: _result(content: const [_read]),
          initialQuery: 'sleep',
          onOpened: (_, s) => opened.add(s),
        ),
      );
      await _settle(t);

      await t.tap(find.byKey(const ValueKey('veda_tab_reads')));
      await _settle(t);
      expect(
        find.text("Veda's answer"),
        findsNothing,
        reason: 'the answer card belongs to All',
      );
      expect(find.text(_read.title), findsOneWidget);
      await t.tap(find.text(_read.title));
      expect(opened, [
        VedaSection.reads,
      ], reason: 'a read opens through the screen');

      await t.tap(find.byKey(const ValueKey('veda_tab_videos')));
      await _settle(t);
      expect(find.byKey(const ValueKey('veda_empty_videos')), findsOneWidget);
      expect(find.text(_read.title), findsNothing);
    });

    testWidgets('a shortcut opens the results on that tab', (t) async {
      await _pump(t, _Harness(result: _result(content: const [_read])));
      await t.tap(find.byKey(const ValueKey('veda_short_videos')));
      await _settle(t);
      await t.enterText(find.byType(TextField), 'sleep');
      await t.testTextInput.receiveAction(TextInputAction.search);
      await _settle(t);
      // No videos in this result, so the Videos tab shows its invitation.
      expect(find.byKey(const ValueKey('veda_empty_videos')), findsOneWidget);
    });

    testWidgets('offline keeps Retry and the app\'s own pages', (t) async {
      final s = await _pump(
        t,
        const _Harness(failed: true, initialQuery: 'scan'),
      );
      await _settle(t);
      expect(find.text('Connect to the internet'), findsOneWidget);
      expect(find.text('Meanwhile, in the app'), findsOneWidget);
      expect(find.text('Sleep in pregnancy'), findsOneWidget);
      await t.tap(find.byKey(const ValueKey('veda_retry')));
      expect(s.retries, 1);
    });

    testWidgets('People also ask is not drawn', (t) async {
      await _pump(t, _Harness(result: _result(), initialQuery: 'sleep'));
      await _settle(t);
      expect(find.text('People also ask'), findsNothing);
    });
  });

  group('wiring', () {
    test('all three stage screens draw the shell and keep kAskVedaRoute', () {
      for (final f in [
        'lib/screens/tools/ask_veda_screen.dart',
        'lib/screens/ttc/ttc_askveda_screen.dart',
        'lib/screens/post_pregnancy/askveda_screen.dart',
      ]) {
        expect(
          File(f).readAsStringSync(),
          contains('AskVedaSearchShell('),
          reason: f,
        );
      }
      expect(
        File('lib/widgets/global_ask_fab.dart').readAsStringSync(),
        contains("const String kAskVedaRoute = 'askveda';"),
      );
    });

    test('the shell holds no request and no stage logic', () {
      final src = File(
        'lib/ask_veda/ask_veda_search_shell.dart',
      ).readAsStringSync();
      expect(src, isNot(contains('AskVedaService.ask')));
      expect(src, isNot(contains('http.')));
    });
  });
}
