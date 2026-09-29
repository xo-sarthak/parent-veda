// An uninitialised backend must behave exactly like being logged out
// (CLAUDE.md, "Local-first is absolute"). The WhatsApp switch on the You/More
// screen threw here until 2026-09-28, because `Supabase.instance.client`
// asserts when Supabase was never initialised.

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/whatsapp_prefs.dart';

void main() {
  test('save reports failure instead of throwing when there is no backend',
      () async {
    final ok = await WhatsAppPrefs.save(
        optIn: true, phone: '9999999999', source: 'test');
    expect(ok, isFalse);
  });

  test('load reads as nothing set when there is no backend', () async {
    final prefs = await WhatsAppPrefs.load();
    expect(prefs.optIn, isFalse);
    expect(prefs.phone, isNull);
  });
}
