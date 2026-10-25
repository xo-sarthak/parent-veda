// =============================================================================
//  Food tools, the backend (tools pass 22-24, sync step 20, 2026-10-25)
// -----------------------------------------------------------------------------
//  "Can my baby eat this?" now remembers the foods a child has tried, per
//  child and shared with the co-parent (0115, PpFoodTriesStore). These pin
//  the shape: twins never share a try, Undo removes it, it survives a
//  restart, a logged-out phone keeps working, and the columns the app sends
//  are the columns 0115 creates (a mismatch would fail silently, because
//  cloud writes are fire-and-forget).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_food_tries_store.dart';
import 'package:parentveda/services/pp_use_consent.dart';
import 'package:parentveda/services/remote/supabase_repo.dart';

String _code(String path) => File(path).readAsStringSync().replaceAll('\r\n', '\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ChildProfileStore.instance.resetForTest();
    PpFoodTriesStore.instance.debugReset();
  });

  Future<(String, String)> twins() async {
    final store = ChildProfileStore.instance;
    final dob = DateTime.now().subtract(const Duration(days: 240));
    final a = await store.addChild(name: 'Aarav', isBoy: true, dob: dob);
    final b = await store.addChild(name: 'Meera', isBoy: false, dob: dob);
    await store.switchTo(a.id);
    return (a.id, b.id);
  }

  test("twins: one child's first tries never show for the other", () async {
    final (a, b) = await twins();
    final s = PpFoodTriesStore.instance;
    s.markTried('egg', date: DateTime(2026, 10, 20), reaction: FoodReaction.mild, note: 'Two hives by the mouth');
    expect(s.tried('egg'), isTrue);
    expect(s.tryOf('egg')!.reaction, FoodReaction.mild);

    await ChildProfileStore.instance.switchTo(b);
    expect(s.tried('egg'), isFalse);
    expect(s.count, 0);

    await ChildProfileStore.instance.switchTo(a);
    expect(s.tried('egg'), isTrue);
  });

  test('Undo puts back exactly what was there', () async {
    await twins();
    final s = PpFoodTriesStore.instance;
    s.markTried('ragi', date: DateTime(2026, 10, 1));
    final before = s.tryOf('ragi');
    s.markTried('ragi', date: DateTime(2026, 10, 25), reaction: FoodReaction.doctor);
    s.restore('ragi', before);
    expect(s.tryOf('ragi')!.date, DateTime(2026, 10, 1));
    expect(s.tryOf('ragi')!.reaction, FoodReaction.none);

    s.restore('ragi', null); // a first try undone: gone
    expect(s.tried('ragi'), isFalse);
  });

  test('reactions for the doctor: only tries with a reaction, newest first', () async {
    await twins();
    final s = PpFoodTriesStore.instance;
    s.markTried('banana', date: DateTime(2026, 10, 10));
    s.markTried('egg', date: DateTime(2026, 10, 12), reaction: FoodReaction.mild);
    s.markTried('peanut', date: DateTime(2026, 10, 20), reaction: FoodReaction.doctor);
    s.markTried('fish', date: DateTime(2026, 5, 1), reaction: FoodReaction.mild);
    final r = s.reactionsSince(DateTime(2026, 7, 25));
    expect(r.map((e) => e.key), ['peanut', 'egg']);
  });

  test('works logged out: the tries stay on the phone and nothing throws', () async {
    expect(SupabaseRepo.isLoggedIn, isFalse);
    await twins();
    PpFoodTriesStore.instance.markTried('dal');
    expect(PpFoodTriesStore.instance.tried('dal'), isTrue);
  });

  test('a reaction value from the other phone that this one does not know reads as none', () {
    expect(FoodTry.reactionFrom('something_new'), FoodReaction.none);
    expect(FoodTry.reactionFrom('mild'), FoodReaction.mild);
    expect(FoodReaction.doctor.name, 'doctor', reason: 'persisted and synced: never rename');
  });

  test('food ids are stable slugs of the catalogue name', () {
    expect(ppFoodId('Egg'), 'egg');
    expect(ppFoodId('Grapes, quartered'), 'grapes_quartered');
    expect(ppFoodId('Dal (moong, masoor)'), 'dal_moong_masoor');
  });

  test('consent kind foods exists and is never renamed', () {
    expect(PpUseKind.foods.name, 'foods');
    expect(PpUseKind.foods.label, isNotEmpty);
    expect(PpUseKind.foods.why, isNotEmpty);
  });

  test('contract: every column the app sends is one 0115 creates', () {
    final sql = _code('supabase/migrations/0115_pp_food_tries.sql');
    final body = RegExp(r'create table if not exists public\.pp_food_tries \((.*?)\n\);', dotAll: true)
        .firstMatch(sql)!
        .group(1)!;
    final cols = RegExp(r'^\s+([a-z_]+)\s', multiLine: true)
        .allMatches(body)
        .map((m) => m.group(1)!)
        .where((c) => c != 'primary')
        .toSet();
    final sent = PpFoodTriesStore.cols('egg', FoodTry(date: DateTime(2026))).keys.toSet()
      // The ledger adds these on every push (0104).
      ..addAll(['child_id', 'user_id', 'updated_at', 'removed_at']);
    expect(cols.containsAll(sent), isTrue, reason: 'sent $sent, table has $cols');
    expect(PpFoodTriesStore.table, 'pp_food_tries');
  });

  test('wired: the store starts with the app', () {
    expect(_code('lib/main.dart'), contains('PpFoodTriesStore.instance.init()'));
  });
}
