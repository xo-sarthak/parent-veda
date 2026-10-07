// =============================================================================
//  The emergency card on the door (gap analysis P1, Health door)
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_health_data.dart';
import 'package:parentveda/screens/post_pregnancy/pp_surface_router.dart';
import 'package:parentveda/screens/post_pregnancy/pp_wallet_data.dart';
import 'package:parentveda/screens/post_pregnancy/wallet_v2_screens.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('the door opens the Wallet card, with its real QR', () {
    expect(ppScreenForSurface('pp_emergency_card'), isA<WalletEmergencyCardScreen>());
  });

  test('two contacts and 112 and 108 printed on the card', () {
    HealthStore.instance.setEmergency(const EmergencyProfile(
      name: 'Meera', dob: '29 Jun 2026', weight: '6 kg', bloodGroup: 'B+',
      allergies: 'None', pediatrician: 'Dr Rao', medications: 'None',
      contacts: [
        (name: 'Asha', relation: 'Mother', phone: '98000 00001'),
        (name: 'Ravi', relation: 'Father', phone: '98000 00002'),
      ],
    ));
    final t = walletEmergencyText();
    expect(t, contains('CONTACT: Asha 98000 00001'));
    expect(t, contains('CONTACT: Ravi 98000 00002'));
    expect(t, contains('112'));
    expect(t, contains('108'));
  });

  test('the editor has the two contacts; the card syncs to its own table', () {
    final ed = File('lib/screens/post_pregnancy/health_emergency_screen.dart').readAsStringSync();
    expect(ed, contains("'First person to call: phone'"));
    expect(ed, contains("'Second person to call: phone'"));
    expect(File('lib/screens/post_pregnancy/pp_health_data.dart').readAsStringSync(),
        contains("_emergencyTable = 'pp_emergency_cards'"));
    final sql = File('supabase/migrations/0095_pp_emergency_cards.sql').readAsStringSync();
    expect(sql, contains('child_id   text        primary key'));
    expect(sql, contains('my_child_ids()'));
  });
}
