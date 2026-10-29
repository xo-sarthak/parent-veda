// =============================================================================
//  The phone notification's emoji (2026-10-29): one map, all three stages,
//  phone only, none on the sensitive kinds. `lib/services/phone_emoji.dart`.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/services/phone_emoji.dart';
import 'package:parentveda/services/pp_messages_store.dart';
import 'package:parentveda/services/preg_messages_store.dart';
import 'package:parentveda/ttc/ttc_messages_store.dart';

class _PpPhone implements PpMessagePhone {
  final List<String> titles = [];
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) async => titles.add(title);
  @override
  Future<void> cancel(int id) async {}
}

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the map, as decided', () {
    expect(kPhoneEmoji, {
      TtcMessageKind.windowOpens: '🌸',
      TtcMessageKind.periodSoon: '🗓️',
      TtcMessageKind.cycleReport: '📊',
      TtcMessageKind.dayLine: '💡',
      TtcMessageKind.checkIn: '💬',
      TtcMessageKind.offer: '🛍️',
      PregMessageKind.newWeek: '🌸',
      PregMessageKind.dayLine: '💡',
      PregMessageKind.checkIn: '💬',
      PregMessageKind.offer: '🛍️',
      PregMessageKind.firstVisit: '🩺',
      PregMessageKind.datingScan: '🩺',
      PregMessageKind.ntScan: '🩺',
      PregMessageKind.anomalyScan: '🩺',
      PregMessageKind.glucoseTest: '🩺',
      PregMessageKind.growthScan: '🩺',
      PregMessageKind.tdap: '💉',
      PregMessageKind.hospitalBag: '🧳',
      PregMessageKind.babyArrived: '👶',
      PpMessageKind.vaccine: '💉',
      PpMessageKind.milestones: '🌱',
      PpMessageKind.activity: '🧸',
      PpMessageKind.tip: '💡',
      PpMessageKind.offer: '🛍️',
    });
  });

  test('none on the sensitive kinds', () {
    for (final k in kPhoneEmojiNever) {
      expect(phoneEmojiFor(k), '', reason: '$k');
    }
    expect(kPhoneEmojiNever, {
      TtcMessageKind.periodCame,
      TtcMessageKind.lateByOne,
      TtcMessageKind.tryingLong,
      TtcMessageKind.waitStarts,
      TtcMessageKind.treatment,
      PregMessageKind.movements,
    });
  });

  test(
    'every kind of every stage is decided: an emoji, or none on purpose',
    () {
      for (final k in <Enum>[
        ...TtcMessageKind.values,
        ...PregMessageKind.values,
        ...PpMessageKind.values,
      ]) {
        final decided =
            kPhoneEmoji.containsKey(k) ||
            kPhoneEmojiNever.contains(k) ||
            k == PpMessageKind.age;
        expect(
          decided,
          isTrue,
          reason: '$k is new: give it an emoji or list it in kPhoneEmojiNever',
        );
      }
    },
  );

  test(
    'ages: a cake on whole years, a party on the rest, two on the sixth birthday',
    () {
      expect(phoneEmojiFor(PpMessageKind.age, id: 'age:w3'), '🎉');
      expect(phoneEmojiFor(PpMessageKind.age, id: 'age:m6'), '🎉');
      expect(phoneEmojiFor(PpMessageKind.age, id: 'age:m12'), '🎂');
      expect(phoneEmojiFor(PpMessageKind.age, id: 'child:x|age:m36'), '🎂');
      expect(phoneEmojiFor(PpMessageKind.age, id: 'age:m39'), '🎉');
      expect(phoneEmojiFor(PpMessageKind.age, id: 'age:m72'), '🎂🎒');
    },
  );

  test('at the end of the title, after a space; none leaves it as it is', () {
    expect(
      phoneTitle('Week 22 starts today', PregMessageKind.newWeek),
      'Week 22 starts today 🌸',
    );
    expect(
      phoneTitle("Your baby's movements", PregMessageKind.movements),
      "Your baby's movements",
    );
  });

  test(
    'phone only: the stored message, its id and its cloud row stay plain',
    () async {
      SharedPreferences.setMockInitialValues({});
      final s = PpMessagesStore.instance..resetForTest();
      final phone = _PpPhone();
      s.phone = phone;
      final now = DateTime(2026, 11, 2, 7);
      await s.refresh(
        now: now,
        facts: PpMessageFacts(
          dob: DateTime(2026, 5, 10),
          name: 'Meera',
          realChild: true,
        ),
      );
      expect(phone.titles, isNotEmpty);
      expect(phone.titles.every((t) => t.contains(RegExp(r' \S+$'))), isTrue);
      final emoji = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);
      for (final m in s.pending(now: now)) {
        expect(emoji.hasMatch(m.title), isFalse, reason: m.title);
      }
    },
  );

  test('each store adds it where it arms, and nowhere else', () {
    expect(
      _code('lib/services/pp_messages_store.dart'),
      contains('title: phoneTitle(m.title, m.kind, id: m.id)'),
    );
    expect(
      _code('lib/services/preg_messages_store.dart'),
      contains('title: phoneTitle(m.title, m.kind)'),
    );
    expect(
      _code('lib/ttc/ttc_messages_store.dart'),
      contains('title: phoneTitle(m.title, m.kind)'),
    );
  });
}
