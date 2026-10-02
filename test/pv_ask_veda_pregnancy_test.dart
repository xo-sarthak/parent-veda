// =============================================================================
//  Pregnancy Ask Veda, the way TTC's is (2026-10-02).
//
//  The user: "Ask Veda ... the way we did for TTC; that Ask Veda answers should
//  be in-app stuff as well, so users can use it to search efficiently in the
//  app and for their doubts."
//
//  What this drives, on the real screen with the real network call faked:
//    1. THE REQUEST says which side of the app she is on (`stage: pregnancy`),
//       because the service scopes the answer and buckets its cache on it. The
//       app sent only the week before, and a field the service does not read
//       fails silently, so this holds the app half of that two-repo contract.
//    2. A CARD IN THE ANSWER OPENS THE REAL PAGE: a `pvread_` id opens the
//       reader on that read, not a text sheet.
//    3. WHEN THE SERVICE SENDS NO READING, the app's own search fills "More
//       information", and when there is NO CONNECTION it is what is left.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/ask_veda/pv_veda_links.dart';
import 'package:parentveda/data/reads/pregnancy_reads.dart';
import 'package:parentveda/screens/reader/pv_reader_screen.dart';
import 'package:parentveda/screens/tools/ask_veda_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PregnancyController pregnancy;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    pregnancy = PregnancyController(
        dueDate: DateTime.now().add(const Duration(days: 140)));
    await pregnancy.load();
  });

  Future<void> open(WidgetTester t, String question) async {
    t.view.physicalSize = const Size(900, 2200);
    t.view.devicePixelRatio = 1.0;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      home: AskVedaScreen(controller: pregnancy, initialQuery: question),
    ));
    // The question runs after the first frame; give the (fake) call a moment.
    await t.pump();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
  }

  String reply({List<Map<String, dynamic>> content = const []}) => jsonEncode({
        'answer': 'A dating scan checks how far along you are.',
        'meaning': '',
        'actions': <String>[],
        'content': content,
        'videos': <Map<String, dynamic>>[],
        'products': <Map<String, dynamic>>[],
        'services': <Map<String, dynamic>>[],
        'source': 'llm',
        'cache_hit': false,
      });

  testWidgets('the request says she is on the pregnancy side', (t) async {
    Map<String, dynamic>? sent;
    await http.runWithClient(() async {
      await open(t, 'what does a dating scan check');
    }, () => MockClient((req) async {
      sent = jsonDecode(req.body) as Map<String, dynamic>;
      return http.Response(reply(), 200);
    }));
    expect(sent, isNotNull, reason: 'the screen never asked the service');
    expect(sent!['stage'], 'pregnancy');
    expect(sent!['week'], pregnancy.currentWeek);
    expect(sent!['question'], 'what does a dating scan check');
  });

  testWidgets('a card from the service opens the real read', (t) async {
    final read = kPregnancyReads.first;
    await http.runWithClient(() async {
      await open(t, 'tell me about this');
      expect(find.text(read.title.en), findsOneWidget);
      await t.tap(find.text(read.title.en));
      await t.pump();
      await t.pump(const Duration(milliseconds: 600));
      expect(find.byType(PvReaderScreen), findsOneWidget,
          reason: 'a pvread_ card must open the reader, not a text sheet');
    }, () => MockClient((req) async => http.Response(
          reply(content: [
            {
              'doc_id': pvVedaReadId(read.id),
              'kind': 'pvread',
              'title': read.title.en,
              'snippet': 'A short line.',
              'source_table': 'veda_knowledge',
              'source_id': 'x',
            }
          ]),
          200,
        )));
  });

  testWidgets('with no reading from the service, the app finds its own',
      (t) async {
    await http.runWithClient(() async {
      await open(t, 'scan');
      expect(find.text('More information'), findsOneWidget);
      expect(find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('veda_local_')),
          findsWidgets,
          reason: 'the app\'s own search should have matched "scan"');
    }, () => MockClient((req) async => http.Response(reply(), 200)));
  });

  testWidgets('with no connection, she can still open the app\'s own pages',
      (t) async {
    await http.runWithClient(() async {
      await open(t, 'scan');
      expect(find.text('Meanwhile, in the app'), findsOneWidget);
      expect(find.byWidgetPredicate((w) =>
          w.key is ValueKey<String> &&
          (w.key as ValueKey<String>).value.startsWith('veda_local_')),
          findsWidgets);
    }, () => MockClient((req) async => http.Response('down', 503)));
  });
}
