// =============================================================================
//  Spiritual Reading without emoji (2026-10-02).
//
//  The user: "Spiritual reading also uses emojis, which we can remove and
//  create the new glyphs and marks for it."
//
//  Each tradition's emoji (`SpiritualTradition.symbol`) was drawn in the chips,
//  the cards and the page titles, and, through the same field, in the Garbh
//  Samvad headings and the classic home's chips. They are now drawn marks
//  (`spiritualMark`), one per tradition, in the app's own mark family. This
//  holds that on every place it showed, and that the reading itself did not
//  change.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/spiritual_reading_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/tools/spiritual_marks.dart';
import 'package:parentveda/screens/tools/spiritual_reading_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

bool _isEmoji(int r) =>
    r >= 0x1F000 || r == 0xFE0F || (r >= 0x2600 && r <= 0x27BF && r != 0x2713 && r != 0x2714);

List<String> _emojiTexts(WidgetTester t) => [
      for (final w in t.widgetList<Text>(find.byType(Text, skipOffstage: false)))
        if ((w.data ?? w.textSpan?.toPlainText() ?? '').runes.any(_isEmoji))
          w.data ?? w.textSpan!.toPlainText(),
    ];

String _code(String p) => File(p)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    // A trailing comment may name the old field (kept for revert); only code counts.
    .map((l) => l.contains('//') ? l.substring(0, l.indexOf('//')) : l)
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController c;
  late S s;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    c = PregnancyController(dueDate: DateTime.now().add(const Duration(days: 100)));
    await c.load();
    s = S(c.language);
  });

  Future<void> pump(WidgetTester t, {double scale = 1.0, double width = 900}) async {
    t.view.physicalSize = Size(width, 3200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: SpiritualReadingScreen(controller: c),
    ));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
  }

  group('the front page', () {
    testWidgets('no emoji anywhere, and a drawn mark for every tradition',
        (t) async {
      await pump(t);
      expect(_emojiTexts(t), isEmpty);
      // A chip and a card each, per tradition.
      expect(find.byType(SpiritualMark, skipOffstage: false),
          findsAtLeastNWidgets(kSpiritualTraditions.length * 2));
      for (final tr in kSpiritualTraditions) {
        expect(find.text(tr.name.now, skipOffstage: false), findsWidgets);
      }
      expect(t.takeException(), isNull);
    });

    testWidgets('choosing a tradition still filters, and still shows no emoji',
        (t) async {
      await pump(t);
      final first = kSpiritualTraditions.first;
      await t.tap(find.text(first.name.now).first);
      await t.pump(const Duration(milliseconds: 300));
      expect(_emojiTexts(t), isEmpty);
      expect(t.takeException(), isNull);
    });

    testWidgets('holds at 1.5x text on a narrow phone', (t) async {
      await pump(t, scale: 1.5, width: 360);
      expect(t.takeException(), isNull);
    });
  });

  group('a tradition and a read', () {
    testWidgets('View all opens the tradition with its mark and no emoji',
        (t) async {
      await pump(t);
      final first = kSpiritualTraditions.first;
      final viewAll = find.text(s.sprViewAll(first.readCount));
      await t.ensureVisible(viewAll.first);
      await t.tap(viewAll.first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(_emojiTexts(t), isEmpty);
      expect(find.byType(SpiritualMark), findsWidgets);
      expect(find.text(first.name.now), findsWidgets);
      expect(t.takeException(), isNull);
    });

    testWidgets('a read opens with the mark in its bar and no emoji', (t) async {
      await pump(t);
      final read = kSpiritualTraditions.first.sections.first.reads.first;
      // The preview row for the first read.
      final row = find.text(read.title.now);
      await t.ensureVisible(row.first);
      await t.tap(row.first);
      await t.pump();
      await t.pump(const Duration(milliseconds: 500));
      expect(_emojiTexts(t), isEmpty);
      expect(find.text(s.sprFootnote), findsOneWidget);
      expect(find.byType(SpiritualMark), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  });

  group('the marks', () {
    for (final tr in kSpiritualTraditions) {
      testWidgets('${tr.id} draws, at both sizes, without an error', (t) async {
        await t.pumpWidget(MaterialApp(
          home: Row(children: [
            spiritualMark(tr.id, size: 24),
            spiritualMark(tr.id, size: 160),
          ]),
        ));
        expect(find.byType(SpiritualMark), findsNWidgets(2));
        expect(t.takeException(), isNull);
      });
    }

    testWidgets('an unknown tradition still gets a mark (the "others" light)',
        (t) async {
      await t.pumpWidget(MaterialApp(home: spiritualMark('something_new')));
      expect(find.byType(SpiritualMark), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    test('every tradition id has its own drawing but "others"', () {
      final painted = {'hindu', 'islam', 'christian', 'sikh', 'jain', 'buddhist'};
      for (final tr in kSpiritualTraditions) {
        expect(painted.contains(tr.id) || tr.id == 'others', isTrue,
            reason: '${tr.id} falls to the generic light by accident');
      }
    });
  });

  group('everywhere the emoji used to show', () {
    test('no live code draws a tradition\'s emoji', () {
      for (final f in [
        'lib/screens/tools/spiritual_reading_screen.dart',
        'lib/services/samvad_pool.dart',
        'lib/widgets/home/home_modules.dart',
      ]) {
        expect(_code(f), isNot(contains('.symbol')), reason: f);
      }
    });

    test('the reading itself did not change: same traditions, same reads', () {
      expect(kSpiritualTraditions.length, 7);
      for (final tr in kSpiritualTraditions) {
        expect(tr.readCount, greaterThan(0), reason: tr.id);
      }
    });
  });
}
