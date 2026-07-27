// Father Mode weekly content: 37 weeks, all different, all correct for the
// week they claim to be.
//
// The bug this exists to prevent already happened once. Only week 20 was ever
// authored, and weekFor() silently returned "the nearest authored week" — so a
// father at week 34 read about the anomaly scan and "your baby can hear you
// now", fourteen weeks late, while his partner's app correctly said pelvic
// pressure and labour signs. Nothing errored. Nothing logged. It looked
// entirely normal.
//
// The loader still cannot tell a MISSING file from a BROKEN one — both are
// caught and skipped identically — so a single trailing comma in
// journey_week_34.json would put that silence straight back. These tests are
// what turn that into a build failure instead.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/father_week.dart';
import 'package:parentveda/models/father_week_derive.dart';
import 'package:parentveda/models/week_content.dart';

const _first = 4;
const _last = 40;
const _dir = 'lib/data/father';

List<WeekContent> _motherWeeks() {
  final raw = File('lib/data/weekContent.json').readAsStringSync();
  return (jsonDecode(raw) as List)
      .map((e) => WeekContent.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

Map<String, dynamic>? _fatherJson(int week) {
  final f = File('$_dir/journey_week_${week.toString().padLeft(2, '0')}.json');
  if (!f.existsSync()) return null;
  return Map<String, dynamic>.from(jsonDecode(f.readAsStringSync()) as Map);
}

void main() {
  final mothers = _motherWeeks();
  final motherByWeek = {for (final m in mothers) m.week: m};

  group('every week has a file, and every file parses', () {
    for (var w = _first; w <= _last; w++) {
      test('week $w', () {
        final f =
            File('$_dir/journey_week_${w.toString().padLeft(2, '0')}.json');
        expect(f.existsSync(), isTrue,
            reason: 'journey_week_$w.json is missing — the loader would skip '
                'it silently and this week would fall back to derived content');
        // Parsed here rather than trusting the app's try/catch, which swallows
        // a syntax error and a missing file identically.
        expect(() => jsonDecode(f.readAsStringSync()), returnsNormally,
            reason: 'journey_week_$w.json does not parse');
      });
    }
  });

  test('the file for week N actually declares week N', () {
    for (var w = _first; w <= _last; w++) {
      expect(_fatherJson(w)?['week'], w,
          reason: 'journey_week_$w.json declares a different week');
    }
  });

  group('father_insight is authored, and authored ONCE', () {
    test('every week has a non-empty insight in both languages', () {
      for (var w = _first; w <= _last; w++) {
        final ins = (_fatherJson(w)?['father_insight'] as Map?) ?? {};
        final title = (ins['title'] as Map?) ?? {};
        for (final lang in ['en', 'hi']) {
          expect((title[lang] ?? '').toString().trim(), isNotEmpty,
              reason: 'week $w insight title is empty in $lang');
        }
      }
    });

    test('no two weeks share an insight — the exact failure this replaces', () {
      final seen = <String, int>{};
      for (var w = _first; w <= _last; w++) {
        final t = ((_fatherJson(w)?['father_insight'] as Map?)?['title']
                as Map?)?['en']
            .toString();
        expect(seen.containsKey(t), isFalse,
            reason: 'week $w repeats the insight from week ${seen[t]}');
        seen[t!] = w;
      }
      expect(seen.length, _last - _first + 1);
    });
  });

  group('derivation fills the other three sections for every week', () {
    test('mother content exists for all 37 weeks, so nothing can be blank', () {
      for (var w = _first; w <= _last; w++) {
        expect(motherByWeek[w], isNotNull, reason: 'no mother week $w');
      }
    });

    test('a father week with only an insight comes out complete', () {
      for (var w = _first; w <= _last; w++) {
        final fw = FatherWeek.fromJson(_fatherJson(w)!).filledFrom(
          motherByWeek[w],
        );
        for (final entry in {
          'support': fw.support,
          'connect': fw.connect,
          'mission': fw.mission,
        }.entries) {
          expect(entry.value.title.en.trim(), isNotEmpty,
              reason: 'week $w ${entry.key} is blank in en');
          expect(entry.value.title.hi.trim(), isNotEmpty,
              reason: 'week $w ${entry.key} is blank in hi');
        }
      }
    });

    test('derived sections are the mother\'s own words, so the two apps can '
        'never disagree about the same week', () {
      for (var w = _first; w <= _last; w++) {
        final m = motherByWeek[w]!;
        final json = _fatherJson(w)!;
        final fw = FatherWeek.fromJson(json).filledFrom(m);
        // Only sections the JSON does NOT supply are derived. Weeks 22 and 28
        // hand-author connecting_with_baby because her wording is wrong for
        // him; those are asserted separately below.
        if (json['supporting_partner'] == null) {
          expect(fw.support.title.en, m.partner.whatSheMayFeel.en);
        }
        if (json['mission'] == null) {
          expect(fw.mission.title.en, m.partner.oneMission.en);
        }
        if (json['connecting_with_baby'] == null) {
          expect(fw.connect.title.en, m.development.whatImDoing.en);
        }
      }
    });

    test('and they differ week to week, because hers do', () {
      final supports = <String>{};
      final missions = <String>{};
      for (var w = _first; w <= _last; w++) {
        final fw =
            FatherWeek.fromJson(_fatherJson(w)!).filledFrom(motherByWeek[w]);
        supports.add(fw.support.title.en);
        missions.add(fw.mission.title.en);
      }
      expect(supports.length, _last - _first + 1);
      expect(missions.length, _last - _first + 1);
      // And the only weeks that deviate from her wording are the two we
      // deliberately overrode — if that list grows silently, something was
      // hand-authored without anyone saying so.
      final overridden = [
        for (var w = _first; w <= _last; w++)
          if (_fatherJson(w)!['connecting_with_baby'] != null) w
      ];
      expect(overridden, [22, 28]);
    });
  });

  group('an authored section always beats the derived one', () {
    test('supplying supporting_partner in JSON overrides the mother data', () {
      final fw = FatherWeek.fromJson({
        'week': 34,
        'father_insight': {
          'title': {'en': 'x', 'hi': 'x'}
        },
        'supporting_partner': {
          'title': {'en': 'HAND WRITTEN', 'hi': 'HAND WRITTEN'}
        },
      }).filledFrom(motherByWeek[34]);
      expect(fw.support.title.en, 'HAND WRITTEN');
      // …while the sections it did not supply still derive.
      expect(fw.mission.title.en, motherByWeek[34]!.partner.oneMission.en);
    });

    test('insight is never derived — a blank one stays blank rather than '
        'putting her words in his mouth', () {
      final fw = FatherWeek.fromJson({'week': 34}).filledFrom(motherByWeek[34]);
      expect(fw.insight.title.en, isEmpty);
      expect(fw.mission.title.en, isNotEmpty);
    });
  });

  group('the derived text reads as a father would read it', () {
    // babyDevelopment is the baby speaking to whoever is reading. In HER app
    // "your heartbeat" and "your belly" are correct. In HIS they are not — the
    // baby hears her heartbeat, and the light falls on her bump. Weeks 22 and
    // 28 said exactly that and are overridden in the father JSON.
    //
    // This test is the reason the override cannot quietly rot: if anyone edits
    // the mother content and introduces another one, it fails here rather than
    // in a father's hands.
    //
    // "your voice" is deliberately NOT in this list. The baby does hear his
    // voice, and that is the entire premise of Father Mode.
    final herBody = RegExp(
        r'your (heartbeat|belly|womb|body|tummy|stomach|bump|blood|breath)',
        caseSensitive: false);
    final herBodyHi = RegExp(
        r'(tumhari dil|tumhare pet|tumhara pet|aapke pet|aapka pet|'
        r'tumhari dhadkan|tumhare womb|aapke womb)',
        caseSensitive: false);

    test('no father week tells him the baby hears HIS heartbeat', () {
      for (var w = _first; w <= _last; w++) {
        final fw =
            FatherWeek.fromJson(_fatherJson(w)!).filledFrom(motherByWeek[w]);
        for (final sec in [fw.insight, fw.support, fw.connect, fw.mission]) {
          for (final t in [
            sec.title.en,
            sec.body?.en ?? '',
          ]) {
            expect(herBody.hasMatch(t), isFalse,
                reason: 'week $w says "${herBody.firstMatch(t)?.group(0)}" to '
                    'a father: $t');
          }
          for (final t in [sec.title.hi, sec.body?.hi ?? '']) {
            expect(herBodyHi.hasMatch(t), isFalse,
                reason: 'week $w (hi) addresses her body: $t');
          }
        }
      }
    });

    test('week 22 keeps "your voice" — that is the point of Father Mode', () {
      final fw =
          FatherWeek.fromJson(_fatherJson(22)!).filledFrom(motherByWeek[22]);
      expect(fw.connect.title.en.toLowerCase(), contains('your voice'));
      expect(fw.connect.title.en.toLowerCase(), contains('her heartbeat'));
    });

    test('week 22 does not credit her voice in the one week about his', () {
      final fw =
          FatherWeek.fromJson(_fatherJson(22)!).filledFrom(motherByWeek[22]);
      expect((fw.connect.body?.en ?? '').toLowerCase(),
          isNot(contains("mother's voice")));
    });
  });

  test('week 34 no longer talks about the anomaly scan', () {
    // The concrete regression. Week 20 content surfacing at week 34 is what
    // started this.
    final fw =
        FatherWeek.fromJson(_fatherJson(34)!).filledFrom(motherByWeek[34]);
    final blob = [
      fw.insight.title.en,
      fw.insight.body?.en ?? '',
      fw.support.title.en,
      fw.support.body?.en ?? '',
      fw.connect.title.en,
      fw.mission.title.en,
    ].join(' ').toLowerCase();
    expect(blob.contains('anomaly scan'), isFalse);
    expect(blob.contains('halfway'), isFalse);
  });
}
