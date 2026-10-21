// =============================================================================
//  No silent user writes (sync log step 11, 2026-10-21)
// -----------------------------------------------------------------------------
//  A write that swallows its own error cannot tell anyone it failed: the
//  Symptoms door's "Strong" was refused by the database for a month and
//  nothing noticed (BACKEND-PATTERNS §16ii-k, mistake 5). Step 11 moved every
//  write of HER data onto a confirmed upload that keeps a waiting mark.
//
//  This scan keeps it that way. It reads the LIVE source (comments and the
//  methods kept for revert under `// ignore: unused_element` are skipped) and
//  fails on a fire-and-forget write in any file not named below. The list is
//  deliberately small and says why each one may stay. A new one fails the
//  build until someone decides about it: loud, and harmless.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// file -> why its fire-and-forget write may stay.
const Map<String, String> allowed = {
  // The definitions themselves.
  'lib/services/remote/supabase_repo.dart': 'the helpers are defined here',
  'lib/ttc/ttc_sync.dart': 'TtcSyncUtil.upsertAll is defined here; no live caller',
  // Confirmed already: `.select()` returns the rows it changed.
  'lib/screens/auth/auth_flow_screen.dart': 'the onboarding write is confirmed with .select()',
  'lib/services/whatsapp_prefs.dart': 'returns false on failure; the Profile card says so',
  // Out of step 11's scope, recorded in STILL-OPEN-BACKEND §3.
  'lib/services/pv_order_store.dart': 'orders: the marketplace build designs these as rows',
  'lib/referral/referral_store.dart': 'referral codes: a separate pass',
  'lib/doctor/doctor_availability.dart': 'the doctor app: a separate pass',
  'lib/doctor/doctor_schedule_store.dart': 'the doctor app: a separate pass',
  'lib/services/can_i_activity_store.dart': 'Can-I misses: a content signal, not her record',
};

final RegExp silent = RegExp(
  r"SupabaseRepo\.upsertRow\(|TtcSyncUtil\.upsertAll\(|"
  r"SupabaseRepo\.updateMyProfile\(|from\('profiles'\)\s*\.update\(",
);

/// The source with comment lines blanked and every `// ignore: unused_element`
/// declaration (the code kept for revert) cut out.
String liveText(String src) {
  final lines = src.replaceAll('\r\n', '\n').replaceAll('\r', '\n').split('\n');
  final out = <String>[];
  var i = 0;
  while (i < lines.length) {
    final l = lines[i];
    if (l.trim() == '// ignore: unused_element') {
      var j = i + 1;
      var depth = 0;
      var started = false;
      while (j < lines.length) {
        for (final ch in lines[j].split('')) {
          if (ch == '{') {
            depth++;
            started = true;
          } else if (ch == '}') {
            depth--;
          }
        }
        if (started && depth <= 0) break;
        j++;
      }
      i = j + 1;
      continue;
    }
    out.add(l.trimLeft().startsWith('//') ? '' : l);
    i++;
  }
  return out.join('\n');
}

void main() {
  test('no fire-and-forget write of her data outside the named exceptions', () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final path = f.path.replaceAll('\\', '/');
      if (allowed.containsKey(path)) continue;
      if (silent.hasMatch(liveText(f.readAsStringSync()))) offenders.add(path);
    }
    expect(offenders, isEmpty,
        reason: 'Use a confirmed write that keeps a waiting mark '
            '(SyncBatch / upsertRowConfirmed / PendingProfile.send), or add '
            'the file to `allowed` with the reason it may stay silent.');
  });

  test('every named exception still has the write (the list never goes stale)',
      () {
    for (final e in allowed.entries) {
      final f = File(e.key);
      expect(f.existsSync(), isTrue, reason: e.key);
      expect(silent.hasMatch(liveText(f.readAsStringSync())), isTrue,
          reason: '${e.key} no longer writes silently: take it off the list');
    }
  });

  test('the scan skips comments and the code kept for revert', () {
    const src = '''
class A {
  // SupabaseRepo.upsertRow('t', {});
  // ignore: unused_element
  Future<void> _old() async {
    if (x) {
      await SupabaseRepo.upsertRow('t', {});
    }
  }
  Future<void> live() async {}
}
''';
    expect(silent.hasMatch(liveText(src)), isFalse);
    expect(silent.hasMatch(liveText('${src}void b() { SupabaseRepo.upsertRow(1); }')),
        isTrue);
  });

  test('the stores step 11 converted stay converted', () {
    String src(String p) => File(p).readAsStringSync();
    expect(src('lib/ttc/ttc_store.dart'), contains('sendTracked('));
    expect(src('lib/ttc/ttc_ready_plan_store.dart'), contains('sendTracked('));
    expect(src('lib/ttc/ttc_treatment_store.dart'), contains('sendTracked('));
    expect(src('lib/services/life_stage_store.dart'), contains('sendTracked('));
    expect(src('lib/ttc/ttc_doctor_questions_store.dart'),
        contains('bool get hasPendingPush'));
    expect(src('lib/services/saved_store.dart'),
        contains('SyncRegistry.registerPending('));
    expect(src('lib/services/journal_store.dart'),
        contains('SyncRegistry.registerPending('));
    expect(src('lib/services/father_journal_store.dart'),
        contains('SyncRegistry.registerPending('));
    // Onboarding's stashed answers are sent on every sync now: before step 11
    // only the retired sign-in screen ever flushed them.
    expect(src('lib/services/remote/sync_registry.dart'),
        contains('PendingProfile.flush()'));
    expect(src('lib/services/pregnancy_controller.dart'),
        contains('PendingProfile.send('));
  });
}
