// 2026-10-10. Signed out means silent, and a positive test is not the last word.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/auth/auth_flow_screen.dart' show kAuthCompletedKey;
import 'package:parentveda/services/notification_service.dart';

void main() {
  test('the service reads the same sign-in flag the app writes', () {
    expect(NotificationService.kAuthFlagKey, kAuthCompletedKey);
  });

  test('sign-out silences notifications before leaving', () {
    final src = File('lib/screens/profile/pv_account_actions.dart').readAsStringSync();
    expect(src, contains('NotificationService.instance.silenceForSignOut()'));
  });

  test('every scheduling path is gated, and the stores re-arm after sign-in', () {
    final n = File('lib/services/notification_service.dart').readAsStringSync();
    expect(RegExp(r'if \(await _muted\(\)\) return;').allMatches(n).length, 5,
        reason: 'showNow, scheduleOneOff, medication alarms, schedule, syncAll');
    for (final f in ['lib/services/reminder_store.dart', 'lib/services/medicine_store.dart']) {
      expect(File(f).readAsStringSync(), contains('SyncRegistry.register(rearmNotifications)'),
          reason: f);
    }
  });

  test('"I\'m pregnant" leads, and a way back exists that is not the loss path', () {
    final you = File('lib/screens/profile/pv_you_content.dart').readAsStringSync();
    expect(you, contains('label: "I\'m pregnant"'));
    expect(you, contains("title: 'Not pregnant after all?'"));
    expect(you, contains('_notPregnant(),'), reason: 'the row is on the pregnancy You list');
    expect(you, contains('TtcTransitionEngine().undo()'));
    expect(you, contains('openPregEnded(c, ctl)'),
        reason: 'an early pregnancy that stopped is a loss and gets that care');
  });
}
