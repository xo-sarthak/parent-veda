// The Dear Baby letters book (2026-10-15, STILL-OPEN §83.2): oldest first,
// the trimester named on its first letter, and a real PDF out the end.

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/services/daily_store.dart';
import 'package:parentveda/services/letter_book_pdf.dart';

TalkEntry _e(String id, int week, String date, String text) => TalkEntry(
      id: id,
      day: week * 7,
      week: week,
      prompt: '',
      text: text,
      dateIso: date,
      spoken: false,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final entries = [
    _e('c', 30, '2026-09-01', 'Third'),
    _e('a', 8, '2026-03-01', 'First'),
    _e('b', 10, '2026-03-15', 'Second'),
    _e('x', 12, '2026-04-01', '   '), // an empty letter is not a page
  ];

  test('the plan reads oldest first and names each trimester once', () {
    final plan = LetterBookPdf.plan(entries, fruitOf: (w) => 'lime');
    expect(plan.map((i) => i.entry.text), ['First', 'Second', 'Third']);
    expect(plan.map((i) => i.trimesterLabel),
        ['First trimester', null, 'Third trimester']);
    expect(plan.first.fruit, 'lime');
  });

  testWidgets('the book builds to a PDF', (t) async {
    final bytes = await t.runAsync(() => LetterBookPdf.build(
          items: LetterBookPdf.plan(entries),
          lang: AppLanguage.english,
          childName: 'Asha',
          bornOn: DateTime(2027, 2, 14),
        ));
    expect(bytes, isNotNull);
    expect(String.fromCharCodes(bytes!.take(5)), '%PDF-');
  });
}
