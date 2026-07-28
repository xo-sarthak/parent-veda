// Father Mode daily content, derived from the mother's pool.
//
// The bug: one authored father day existed (day 143) and dayFor() returned "the
// nearest authored day", so every father read day 143 from week 4 to week 40.
// The mother has all 259 days written and reviewed.
//
// Two things these tests hold. First that every day of the pregnancy now
// produces content for the week he is actually in. Second — the one that
// matters more — that nothing reaches him which only makes sense said to her.
// 37 of her 259 `grow` blocks speak to her body ("Your Body Is Already
// Parenting"); read by a father those are wrong, not merely oddly voiced.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/models/father_day_derive.dart';
import 'package:parentveda/models/home_day.dart';
import 'package:parentveda/localization/app_language.dart';

const _first = 4;
const _last = 40;

List<HomeDay> _week(int w) {
  final f = File('lib/data/home/week_${w.toString().padLeft(2, '0')}.json');
  return (jsonDecode(f.readAsStringSync()) as List)
      .map((e) => HomeDay.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}

/// Mirrors the filter in father_day_derive.dart. Duplicated on purpose: if the
/// production regex is loosened, this still fails.
final _herBody = RegExp(
  r'your (body|belly|womb|bump|uterus|breasts?|hips?|pelvis|energy|blood|'
  r'hormones?|skin|ankles)',
  caseSensitive: false,
);

/// The regex works on strings; every content leaf is a {en, hi} pair.
bool _hits(LocalizedText t) => _herBody.hasMatch(t.en);

void main() {
  final weeks = {for (var w = _first; w <= _last; w++) w: _week(w)};

  test('the mother pool is complete — 37 weeks x 7 days', () {
    var total = 0;
    weeks.forEach((w, days) {
      expect(days.length, 7, reason: 'week $w has ${days.length} days');
      total += days.length;
    });
    expect(total, 259);
  });

  group('every day of the pregnancy produces a father day', () {
    test('all 259 days build, and carry the right week', () {
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          expect(fd.day, src.day);
          expect(fd.week, w);
          expect(fd.learn.title.en.trim(), isNotEmpty);
          expect(fd.talk.prompt.en.trim(), isNotEmpty);
          expect(fd.mission.action.en.trim(), isNotEmpty);
        }
      }
    });

    test('and both languages are filled everywhere', () {
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          for (final t in <LocalizedText>[
            fd.intro,
            fd.learn.module,
            fd.learn.title,
            fd.learn.insight,
            fd.talk.title,
            fd.talk.prompt,
            fd.talk.motivation,
            fd.mission.title,
            fd.mission.action,
          ]) {
            expect(t.en.trim(), isNotEmpty, reason: 'day ${src.day} en');
            expect(t.hi.trim(), isNotEmpty, reason: 'day ${src.day} hi');
          }
        }
      }
    });
  });

  group('nothing that is only true of her reaches him', () {
    test('no derived father day mentions her body', () {
      final offenders = <String>[];
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          for (final entry in {
            'learn.title': fd.learn.title,
            'learn.insight': fd.learn.insight,
            'learn.expanded': fd.learn.expanded,
            'learn.remember': fd.learn.remember,
            'talk.prompt': fd.talk.prompt,
            'talk.motivation': fd.talk.motivation,
            'mission.title': fd.mission.title,
            'mission.action': fd.mission.action,
          }.entries) {
            if (_herBody.hasMatch(entry.value.en)) {
              offenders.add('day ${src.day} ${entry.key}: '
                  '"${_herBody.firstMatch(entry.value.en)!.group(0)}"');
            }
          }
        }
      }
      expect(offenders, isEmpty,
          reason: 'these would read as wrong, not just oddly voiced:\n'
              '${offenders.take(10).join('\n')}');
    });

    test('the source data really does contain the problem — otherwise the '
        'test above proves nothing', () {
      var flagged = 0;
      for (var w = _first; w <= _last; w++) {
        for (final d in weeks[w]!) {
          if (_hits(d.grow.title) ||
              _hits(d.grow.insight) ||
              _hits(d.grow.expanded)) {
            flagged++;
          }
        }
      }
      expect(flagged, greaterThan(20),
          reason: 'the mother pool no longer speaks to her body anywhere — '
              'either it was rewritten or the filter is looking for the wrong '
              'thing');
    });

    test('a clean day always exists inside a week', () {
      // The filter can only work because no week is entirely flagged. If a
      // future week were, pickFatherSource would silently return a bad day.
      for (var w = _first; w <= _last; w++) {
        final clean = weeks[w]!.where((d) =>
            !_hits(d.grow.title) &&
            !_hits(d.grow.insight) &&
            !_hits(d.grow.expanded) &&
            !_hits(d.talk.title) &&
            !_hits(d.nurture.title) &&
            !_hits(d.nurture.remember));
        expect(clean, isNotEmpty, reason: 'week $w has no father-safe day');
      }
    });

    test('nurture CONTENT is never shown to him — it is the worst offender', () {
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          for (final d in weeks[w]!) {
            expect(fd.mission.action.en, isNot(contains(d.nurture.content.en)),
                reason: 'day ${src.day} leaked her nurture content');
          }
        }
      }
    });
  });

  group('the shuffle', () {
    test('is deterministic — the card cannot change under him on a rebuild',
        () {
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          final a = fatherDayFromMother(src.day, w, weeks[w]!);
          final b = fatherDayFromMother(src.day, w, weeks[w]!);
          expect(a.learn.title.en, b.learn.title.en);
          expect(a.mission.action.en, b.mission.action.en);
        }
      }
    });

    test('mostly moves him off her exact card', () {
      var same = 0, total = 0;
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          total++;
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          if (fd.learn.title.en == src.grow.title.en) same++;
        }
      }
      // Not zero — on a week with flagged days the walk can land back on her
      // day, and that is fine. The point is that it is the exception.
      expect(same / total, lessThan(0.2),
          reason: '$same of $total days show her exact card');
    });

    test('never picks a day from another week', () {
      for (var w = _first; w <= _last; w++) {
        final titles = weeks[w]!.map((d) => d.grow.title.en).toSet();
        for (final src in weeks[w]!) {
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          expect(titles.contains(fd.learn.title.en), isTrue,
              reason: 'day ${src.day} pulled content from outside week $w');
        }
      }
    });
  });

  group('the mission is re-framed, not copied', () {
    test('every mission opens with an instruction to him', () {
      final leads = ['Do this with her', 'Say this to her', 'Make this happen'];
      for (var w = _first; w <= _last; w++) {
        for (final src in weeks[w]!) {
          final fd = fatherDayFromMother(src.day, w, weeks[w]!);
          expect(leads.any((l) => fd.mission.action.en.startsWith(l)), isTrue,
              reason: 'day ${src.day}: "${fd.mission.action.en}"');
        }
      }
    });

    test('the lead-in matches what the nurture actually is', () {
      final src = weeks[20]!;
      for (final d in src) {
        final fd = fatherDayFromMother(d.day, 20, src);
        final chosen = src.firstWhere(
            (x) => x.nurture.title.en == fd.mission.title.en);
        final expected = switch (chosen.nurture.type) {
          NurtureType.breathe => 'Do this with her',
          NurtureType.affirm => 'Say this to her',
          NurtureType.food => 'Make this happen',
        };
        expect(fd.mission.action.en, startsWith(expected));
      }
    });
  });

  group('the curriculum moves with the pregnancy', () {
    test('the Learn eyebrow is not one constant for all 37 weeks', () {
      final modules = <String>{};
      for (var w = _first; w <= _last; w++) {
        modules.add(fatherDayFromMother(weeks[w]!.first.day, w, weeks[w]!)
            .learn
            .module
            .en);
      }
      expect(modules.length, greaterThanOrEqualTo(4));
    });

    test('week 40 is not still saying "becoming a father"', () {
      final fd = fatherDayFromMother(weeks[40]!.first.day, 40, weeks[40]!);
      expect(fd.learn.module.en, isNot(contains('BECOMING')));
    });
  });
}
