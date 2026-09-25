// =============================================================================
//  The persistence audit — what a mother does in a door has to come back
// -----------------------------------------------------------------------------
//  2026-09-23. The user: "the wiring has to be absolutely perfect that we are
//  actually able to maintain her activity. If she wishlists something, likes
//  something, saves something, bookmarks something…" The audit that followed
//  (docs/PERSISTENCE-AUDIT.md) found saves that SAVED and could never be
//  opened again — the worst kind of gap, because nothing looks wrong until
//  she goes looking. Each test here is one of those, held.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/doors/pv_door_data.dart';
import 'package:parentveda/data/nutrition_data.dart';
import 'package:parentveda/screens/doors/pv_door_router.dart';
import 'package:parentveda/screens/saved_screen.dart';
import 'package:parentveda/services/pregnancy_controller.dart';
import 'package:parentveda/services/read_to_baby_store.dart';
import 'package:parentveda/services/saved_store.dart';
import 'package:parentveda/services/spiritual_prefs_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

// The read id each door library's reader saves under (the reader's bookmark
// saves `PvRead.id`). Kept beside the test so a renamed prefix fails here.
const _prefix = <PvDoorLibrary, String>{
  PvDoorLibrary.scan: 'scan_',
  PvDoorLibrary.finding: 'finding_',
  PvDoorLibrary.condition: 'condition_',
  PvDoorLibrary.nutrient: 'nutrient_',
  PvDoorLibrary.dietStage: 'dietstage_',
  PvDoorLibrary.dietCondition: 'dietcond_',
  PvDoorLibrary.dietQuestion: 'dietq_',
  PvDoorLibrary.fasting: 'fasting_',
  PvDoorLibrary.bellySkin: 'bs_',
  PvDoorLibrary.mindRead: 'mm_',
  PvDoorLibrary.symptom: 'symptom_',
  PvDoorLibrary.symptomNormal: 'normal_',
};

SavedItem _item(SavedKind kind, String id) {
  final now = DateTime(2026, 9, 23);
  return SavedItem(kind: kind, itemId: id, savedAt: now, updatedAt: now);
}

void main() {
  setUp(() {
    PregnancyController.current =
        PregnancyController(dueDate: DateTime.now().add(const Duration(days: 140)));
  });

  test('a bookmark on any door read finds its way home — titled and openable', () {
    final dead = <String>[];
    var checked = 0;
    for (final page in kPvDoorPages) {
      for (final section in page.sections) {
        for (final t in section.tiles) {
          if (t is! PvDoorEntryTile) continue;
          final prefix = _prefix[t.library];
          if (prefix == null) continue; // recipes, charts: not reader bookmarks
          final readId = '$prefix${t.entryId}';
          checked++;
          final back = pvDoorEntryForReadId(readId);
          final item = _item(SavedKind.article, readId);
          if (back == null ||
              back.library != t.library ||
              back.id != t.entryId ||
              SavedItemOpener.resolveTitle(item) == null ||
              !SavedItemOpener.canOpen(item)) {
            dead.add('${page.bracketId} · ${t.title} ($readId)');
          }
        }
      }
    }
    expect(checked, greaterThan(100), reason: 'the audit should cover every door');
    expect(dead, isEmpty, reason: 'saved but unreachable:\n${dead.join('\n')}');
  });

  test('a saved recipe has a title and opens', () {
    for (final r in kRecipes) {
      final item = _item(SavedKind.recipe, r.id);
      expect(SavedItemOpener.resolveTitle(item), r.name.en);
      expect(SavedItemOpener.canOpen(item), isTrue, reason: '${r.id} saved but cannot open');
    }
  });

  test('her Samvad choices and her reading preferences travel to a new phone', () async {
      // Both were phone-only with no stated reason (the audit). What goes up
      // must come back as the same state, or a new phone gets someone else's
      // choices.
      SharedPreferences.setMockInitialValues({});
      final rtb = ReadToBabyStore.instance;
      await rtb.init();
      rtb.toggleCategory('affirmations');
      rtb.nextPrompt();
      final sent = rtb.cloudData();
      rtb.toggleCategory('affirmations'); // change it locally…
      rtb.applyCloudData(sent); // …and the cloud's copy wins back
      expect(rtb.isCategoryOn('affirmations'), isTrue);
      expect(rtb.promptOffset, greaterThan(0));

      final sp = SpiritualPrefsStore.instance;
      sp.toggleInterested('Gayatri Mantra');
      sp.toggleNotInterested('Something else');
      final up = sp.cloudData();
      sp.toggleInterested('Gayatri Mantra');
      sp.applyCloudData(up);
      expect(sp.isInterested('Gayatri Mantra'), isTrue);
      expect(sp.isNotInterested('Something else'), isTrue);
      expect(rtb.cloudKey, isNot(sp.cloudKey), reason: 'two stores, two blobs');
    });

  test('an unknown id stays a row and never opens a near match', () {
    expect(pvDoorEntryForReadId('scan_does_not_exist'), isNull);
    expect(SavedItemOpener.canOpen(_item(SavedKind.article, 'symptom_nope')), isFalse);
    expect(SavedItemOpener.canOpen(_item(SavedKind.recipe, 'nope')), isFalse);
  });
}
