// =============================================================================
//  The folder can hold the actual document
// -----------------------------------------------------------------------------
//  A-49. Fertility results in India arrive on paper and as PDFs. Health Records
//  was text-only, so it could hold a number she retyped and never the report her
//  clinic handed her - which stayed in her gallery or her email, which is where
//  she would go looking for it. The folder was not the folder.
//
//  Two things worth pinning, and neither is "does the picker open":
//
//    * attachments are LOCAL-ONLY on purpose, and that has to stay true by
//      construction rather than by nobody remembering to add a column, and
//    * detaching a document must never delete it.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/ttc/ttc_strings.dart';
import 'package:parentveda/ttc/ttc_records_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() {
    TtcRecordsStore.instance.resetForTest();
    TtcLang.instance.hinglish = false;
  });

  // ===========================================================================
  group('a record can carry documents', () {
    test('it starts with none, and that is not an error state', () {
      final r = TtcRecordsStore.instance
          .add(label: 'AMH', value: '2.1', unit: 'ng/mL', takenOn: DateTime(2026, 7, 1));
      expect(r.attachments, isEmpty);
    });

    test('attaching keeps everything else about the record', () {
      final r = TtcRecordsStore.instance
          .add(label: 'AMH', value: '2.1', unit: 'ng/mL', takenOn: DateTime(2026, 7, 1));
      final updated = r.copyWith(attachments: ['/tmp/amh.pdf']);
      TtcRecordsStore.instance.replace(updated);

      final stored = TtcRecordsStore.instance.records.single;
      expect(stored.id, r.id, reason: 'a new id would orphan the old row');
      expect(stored.label, 'AMH');
      expect(stored.display, '2.1 ng/mL');
      expect(stored.attachments, ['/tmp/amh.pdf']);
    });

    test('and they survive a round trip through the local cache', () {
      final r = TtcRecordsStore.instance
          .add(label: 'Semen analysis', takenOn: DateTime(2026, 6, 2));
      final json = r.copyWith(attachments: ['/tmp/a.jpg', '/tmp/b.pdf']).toJson();
      final back = TtcRecord.fromJson(json)!;
      expect(back.attachments, ['/tmp/a.jpg', '/tmp/b.pdf']);
    });

    test('an older row with no files decodes to an empty list, not a crash', () {
      // Everything already on disk predates this field.
      final back = TtcRecord.fromJson({
        'id': 'x',
        'label': 'FSH',
        'on': '2026-05-01',
      });
      expect(back, isNotNull);
      expect(back!.attachments, isEmpty);
    });
  });

  // ===========================================================================
  group('local-only, and structurally so', () {
    test('the cloud row does not carry the file list', () {
      // `toJson` is the shared_preferences cache; the cloud row is written out
      // column by column in `pushToCloud`. A field therefore reaches the
      // database only when someone types the column name - which is what makes
      // this safe rather than lucky. If a `files` column appears here, the
      // decision to take no new TTC schema has been reversed silently.
      final src = File('lib/ttc/ttc_records_store.dart').readAsStringSync();
      final push = src.substring(src.indexOf('Future<void> pushToCloud'));
      final firstBlock = push.substring(0, push.indexOf('onConflict'));
      expect(firstBlock, isNot(contains('files')));
      expect(firstBlock, isNot(contains('attachment')));
    });

    test('and `replace` does not push a row that has not changed upstream', () {
      final src = File('lib/ttc/ttc_records_store.dart').readAsStringSync();
      final body = src.substring(src.indexOf('void replace('));
      final end = body.indexOf('\n  }');
      expect(body.substring(0, end), isNot(contains('SupabaseRepo')));
    });
  });

  // ===========================================================================
  group('detaching is not deleting', () {
    test('removing a chip leaves the file alone', () {
      // Unrecoverable if wrong: she detaches a scan from the wrong record and
      // the scan is gone from her phone. The store only ever edits the LIST.
      final src =
          File('lib/screens/ttc/ttc_attachments.dart').readAsStringSync();
      final remove = src.substring(src.indexOf('void _remove('));
      final end = remove.indexOf('\n  }');
      // CODE only. An earlier version matched the word "delete" inside the
      // comment that explains why nothing is deleted, and failed on its own
      // reasoning - the same trap the medication test fell into an hour ago.
      final body = remove
          .substring(0, end)
          .split('\n')
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      expect(body, contains('removeAt'));
      expect(body, isNot(contains('StorageService.remove')));
      expect(body, isNot(contains('.delete(')));
    });
  });

  // ===========================================================================
  group('it is reachable and bilingual', () {
    test('the record card renders the attach affordance', () {
      // The wiring gate: an attachment widget nobody can reach is no
      // attachment widget.
      final src =
          File('lib/screens/ttc/ttc_records_screen.dart').readAsStringSync();
      expect(src, contains('TtcAttachments(record: record'));
    });

    test('every attachment string is translated', () {
      const en = TtcS(false);
      const hi = TtcS(true);
      for (final p in [
        (en.recordsAttach, hi.recordsAttach),
        (en.recordsAttachMore, hi.recordsAttachMore),
        (en.recordsAttachCamera, hi.recordsAttachCamera),
        (en.recordsAttachGallery, hi.recordsAttachGallery),
        (en.recordsAttachPdf, hi.recordsAttachPdf),
      ]) {
        expect(p.$1, isNotEmpty);
        expect(p.$2, isNotEmpty);
        expect(p.$1, isNot(p.$2), reason: 'never translated: ${p.$1}');
      }
    });

    test('TTC does not import the parenting attachment screen', () {
      // The stages agree on VALUES, not on widgets. Sharing happens at the
      // infrastructure layer - image_picker, file_picker, StorageService.
      final src =
          File('lib/screens/ttc/ttc_attachments.dart').readAsStringSync();
      expect(src, isNot(contains('post_pregnancy')));
      expect(src, contains('storage_service.dart'));
    });
  });
}
