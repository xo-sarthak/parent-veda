// =============================================================================
//  Content slots — the constraints a database would enforce for us
// -----------------------------------------------------------------------------
//  `content_slots.dart` is a mapping table with no foreign keys, because there
//  is no database behind it yet. This file is what stands in for them: it
//  checks the things a schema would have made impossible.
// =============================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/data/content_slots.dart';
import 'package:parentveda/data/tests_scans_reports_data.dart';
import 'package:parentveda/models/read_item.dart';
import 'package:parentveda/data/read_next_data.dart';
import 'package:parentveda/localization/app_language.dart';

void main() {
  group('a slot points at something real', () {
    test('every topic is a scan that exists', () {
      final ids = kTestsScans.map((s) => s.id).toSet();
      for (final s in kContentSlots) {
        if (s.topic == null) continue;
        expect(ids, contains(s.topic),
            reason: 'slot "${s.title.en}" is tagged to an unknown scan '
                '"${s.topic}" — the foreign key a database would have caught');
      }
    });

    test('every filled readId resolves to an article that ships', () {
      final ids = kReadItems.map((ReadItem r) => r.id).toSet();
      for (final s in kContentSlots) {
        final id = s.readId;
        if (id == null || id.isEmpty) continue;
        expect(ids, contains(id),
            reason: 'slot "${s.title.en}" claims article "$id"');
      }
    });
  });

  group('an unfilled slot is still honest', () {
    // ⚠️ THE RULE THIS FILE EXISTS FOR. A placeholder that does not say what it
    // will hold is just a gap with a border, and a placeholder that says
    // nothing about why it is worth her time is a link. Both are the inventory
    // UX the hub restructure removed.
    test('every slot promises something specific, filled or not', () {
      for (final s in kContentSlots) {
        expect(s.title.en.trim(), isNotEmpty, reason: s.step);
        expect(s.value.en.trim().length, greaterThan(20),
            reason: 'slot "${s.title.en}" has no real reason to watch/read it');
      }
    });

    test('no slot title names a content type instead of an outcome', () {
      // The same rule the hub doors are held to: "What the anomaly scan looks
      // at", never "Anomaly scan video".
      const inventory = ['video', 'article', 'faq', 'content', 'blog'];
      for (final s in kContentSlots) {
        final t = s.title.en.toLowerCase();
        for (final w in inventory) {
          expect(t.contains(w), isFalse,
              reason: 'slot title "${s.title.en}" names the format, not what '
                  'she gets');
        }
      }
    });
  });

  group('the resolver', () {
    test('topic-specific slots sort above general ones', () {
      final out = slotsFor(kScansHubBracketId, kStepUnderstandScan,
          topic: 'anomaly_scan');
      expect(out.length, greaterThan(1));
      expect(out.first.topic, 'anomaly_scan',
          reason: 'the general slot outranked the specific one');
    });

    test('a topic with no slots of its own still gets the general ones', () {
      final out =
          slotsFor(kScansHubBracketId, kStepUnderstandScan, topic: 'gbs');
      expect(out, isNotEmpty);
      for (final s in out) {
        expect(s.topic, isNull);
      }
    });

    test('an unknown bracket resolves to nothing rather than everything', () {
      expect(slotsFor('not_a_bracket', kStepUnderstandScan), isEmpty);
    });

    test('format filters', () {
      final videos = slotsFor(kScansHubBracketId, kStepUnderstandScan,
          topic: 'anomaly_scan', format: ContentFormat.video);
      expect(videos, isNotEmpty);
      for (final s in videos) {
        expect(s.format, ContentFormat.video);
      }
    });
  });

  group('filling one is a data change', () {
    // The whole point of the layer: nothing about "is this live" is computed
    // anywhere except `isFilled`, so a URL is the only thing that has to change.
    test('isFilled is false until a url or an id is set', () {
      const promised = ContentSlot(
        bracketId: 'x',
        step: 'y',
        format: ContentFormat.video,
        title: _stub,
        value: _stub,
      );
      expect(promised.isFilled, isFalse);

      const live = ContentSlot(
        bracketId: 'x',
        step: 'y',
        format: ContentFormat.video,
        title: _stub,
        value: _stub,
        videoUrl: 'https://example.com/a.mp4',
      );
      expect(live.isFilled, isTrue);
    });

    test('an empty string does not count as filled', () {
      const s = ContentSlot(
        bracketId: 'x',
        step: 'y',
        format: ContentFormat.video,
        title: _stub,
        value: _stub,
        videoUrl: '',
        readId: '',
      );
      expect(s.isFilled, isFalse,
          reason: 'an empty url would render a tappable card that plays '
              'nothing');
    });
  });
}

/// A stand-in so the construction tests do not depend on real copy.
const LocalizedText _stub = LocalizedText(en: 'x', hi: 'x');
