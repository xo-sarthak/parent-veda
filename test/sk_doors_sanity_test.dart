// =============================================================================
//  The skilling doors, all of them, one sanity gate
// -----------------------------------------------------------------------------
//  The parenting `pp_doors_sanity_test.dart`, for the fourth stage: every
//  door has content, every surface a door or a page points at resolves,
//  every in-door link lands, every coming-soon slot is in the owed ledger,
//  every "opens elsewhere" page carries no copy, every live skilling cell
//  resolves through the skilling router — and the stage's own three
//  invariants, which no other stage has:
//
//    · nothing under `lib/screens/skilling/` or `lib/data/skilling/` names
//      a score, streak, leaderboard, percentage, points, rank or grade;
//    · the keepsake store has no public member returning a number;
//    · no course or product string promises a child's future.
//
//  The per-door tests hold each brief's map; this one holds the wiring gate
//  across all of them at once, so a future edit that leaves a link pointing
//  at nothing fails here by name.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/brackets/skilling_brackets.dart';
import 'package:parentveda/data/doors/sk_door_data.dart';
import 'package:parentveda/screens/skilling/sk_bands.dart';
import 'package:parentveda/screens/skilling/sk_content.dart';
import 'package:parentveda/screens/skilling/sk_content_registry.dart';
import 'package:parentveda/screens/skilling/sk_surface_router.dart';
import 'package:parentveda/services/bracket_resolver.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('every door has content, five tabs, and a bracket', () {
    final ids = kSkDoors.map((d) => d.doorId).toList();
    expect(ids.toSet(), hasLength(ids.length), reason: 'one door per bracket');
    for (final d in kSkDoors) {
      expect(skDoorContentFor(d.doorId), isNotNull, reason: d.doorId);
      expect(bracketById(d.doorId), isNotNull, reason: d.doorId);
      expect(d.tabs.length, inInclusiveRange(4, 6), reason: '${d.doorId}: the selector draws five');
      expect(d.tabs.map((t) => t.id).toSet(), hasLength(d.tabs.length));
      if (d.heroImageUrl case final url?) {
        expect(url, startsWith('https://images.unsplash.com/'), reason: d.doorId);
      }
    }
    for (final c in kSkDoorContents) {
      expect(skDoorFor(c.doorId), isNotNull, reason: '${c.doorId} has content and no door');
    }
  });

  test('every surface a door, a tool or a page points at resolves to a screen', () {
    final bad = <String>[];
    void check(String where, String? surface) {
      if (surface == null) return;
      if (skScreenForSurface(surface) == null) bad.add('$where -> $surface');
    }
    for (final d in kSkDoors) {
      for (final t in d.tabs) {
        for (final tool in t.tools) {
          check('${d.doorId}/${t.id}/tool', tool.surfaceId);
        }
      }
      check('${d.doorId}/closing', d.closing?.surfaceId);
    }
    for (final c in kSkDoorContents) {
      for (final p in c.allPages) {
        check('${c.doorId}/${p.id}/tool', p.toolSurfaceId);
        for (final b in p.blocks) {
          if (b is SkLink) check('${c.doorId}/${p.id}/link', b.surfaceId);
        }
      }
    }
    expect(bad, isEmpty, reason: 'dead surfaces:\n${bad.join('\n')}');
  });

  test('every in-door page link, every pages-tab id and every tool that follows a page lands', () {
    final bad = <String>[];
    for (final c in kSkDoorContents) {
      for (final p in c.allPages) {
        for (final b in p.blocks) {
          if (b is SkLink && b.pageId != null && c.pageById(b.pageId!) == null) {
            bad.add('${c.doorId}/${p.id} -> page "${b.pageId}"');
          }
        }
      }
      final d = skDoorFor(c.doorId)!;
      for (final t in d.tabs) {
        for (final id in t.pageIds) {
          if (c.pageById(id) == null) bad.add('${c.doorId}/${t.id} names page "$id"');
        }
        for (final tool in t.tools) {
          if (tool.afterPageId != null &&
              c.pageById(tool.afterPageId!) == null &&
              c.activityById(tool.afterPageId!) == null) {
            bad.add('${c.doorId}/${t.id} tool after "${tool.afterPageId}"');
          }
        }
      }
    }
    expect(bad, isEmpty, reason: 'dead page links:\n${bad.join('\n')}');
  });

  test('every band tag on every page, activity, set, course and product is a real band', () {
    final bad = <String>[];
    for (final c in kSkDoorContents) {
      for (final p in c.allPages) {
        for (final b in p.bands) {
          if (skBandById(b) == null) bad.add('${c.doorId}/${p.id} band "$b"');
        }
      }
      for (final a in c.activities) {
        if (skBandById(a.band) == null) bad.add('${c.doorId}/${a.id} band "${a.band}"');
        if (c.skillById(a.skillPurpose) == null) {
          bad.add('${c.doorId}/${a.id} skill "${a.skillPurpose}"');
        }
      }
      for (final s in c.lessonSets) {
        for (final b in s.bands) {
          if (skBandById(b) == null) bad.add('${c.doorId}/set ${s.id} band "$b"');
        }
      }
      for (final k in c.courses) {
        if (skBandById(k.level) == null) bad.add('${c.doorId}/${k.id} level "${k.level}"');
      }
      for (final p in c.products) {
        for (final b in p.bands) {
          if (skBandById(b) == null) bad.add('${c.doorId}/${p.id} band "$b"');
        }
      }
      for (final b in c.bandNames.keys) {
        if (skBandById(b) == null) bad.add('${c.doorId} names band "$b"');
      }
    }
    expect(bad, isEmpty, reason: 'unknown bands or skills:\n${bad.join('\n')}');
  });

  test('every coming-soon slot, on every door, is in the owed ledger', () {
    final ledger = File('docs/DOOR-CONTENT-OWED.md').readAsStringSync();
    final missing = <String>[];
    for (final c in kSkDoorContents) {
      for (final a in c.activities.where((a) => a.comingSoon)) {
        if (!ledger.contains(a.id)) missing.add('${c.doorId}/${a.id}');
      }
      for (final p in c.allPages.where((p) => p.comingSoon)) {
        if (!ledger.contains(p.id)) missing.add('${c.doorId}/${p.id}');
      }
      for (final k in c.courses.where((k) => k.comingSoon)) {
        if (!ledger.contains(k.id)) missing.add('${c.doorId}/${k.id}');
      }
      for (final p in c.products.where((p) => p.comingSoon)) {
        if (!ledger.contains(p.id)) missing.add('${c.doorId}/${p.id}');
      }
    }
    expect(missing, isEmpty, reason: 'coming-soon slots nobody owes:\n${missing.join('\n')}');
  });

  test('a page that opens a tool carries no copy of its own', () {
    for (final c in kSkDoorContents) {
      for (final p in c.allPages.where((p) => p.toolSurfaceId != null)) {
        expect(p.blocks, isEmpty, reason: '${c.doorId}/${p.id} opens ${p.toolSurfaceId} and also holds blocks');
      }
    }
  });

  test('every live skilling cell is sk_-prefixed and resolves through the skilling router', () {
    for (final b in kSkillingBrackets) {
      for (final id in liveSurfaceIds(b)) {
        expect(id, startsWith('sk_'), reason: '${b.id} points at "$id"');
        expect(skScreenForSurface(id), isNotNull,
            reason: '${b.id} points at "$id", which opens nothing');
      }
      // A bracket with live cells has a door, and a door's bracket has live
      // cells — the two lists cannot drift apart.
      expect(b.liveLayers.isNotEmpty, skDoorFor(b.id) != null,
          reason: '${b.id}: live layers and a door go together');
    }
  });

  group('the stage\'s own invariants', () {
    List<File> dartFiles(String dir) => Directory(dir)
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .toList();

    /// Code only: comments and doc comments stripped, so a header that
    /// EXPLAINS the ban does not trip it.
    String code(File f) => f
        .readAsLinesSync()
        .where((l) => !l.trimLeft().startsWith('//'))
        .join('\n');

    /// A sentence that denies a score is the one permitted use of the
    /// vocabulary, in code and in copy alike.
    final denial = RegExp(
        r'\b(no|never|not a|nothing)\b[^.]{0,40}\b(score|scores|ranking|rank|points|streak|streaks|percentage|grade|badges?)\b|ranks no one',
        caseSensitive: false);

    test('no scoring identifier anywhere in the skilling tree', () {
      final banned = RegExp(
          r'\b(score|scores|scoring|streak|streaks|leaderboard|percent|percentage|points|ranking|ranked|grade|graded|xp|badge|badges)\b',
          caseSensitive: false);
      final hits = <String>[];
      // The design preview is excluded: its copy is ABOUT the ban ("Nothing
      // measured. Nothing ranked.") and it predates the doors.
      // The activity data files hold the task PDFs' copy verbatim, and one
      // task-supplied project (Make a Quiz Game) builds a game that keeps
      // its PLAYERS' points — allowed by the task in so many words. Those
      // files are checked by the next test, against the copy and an
      // allow-list, rather than by this source scan.
      final files = [
        ...dartFiles('lib/screens/skilling').where((f) => !f.path.endsWith('skilling_preview_screen.dart')),
        ...dartFiles('lib/data/skilling').where((f) => !f.path.endsWith('_activities.dart')),
        ...dartFiles('lib/data/doors').where((f) => f.path.contains('sk_door')),
      ];
      expect(files, isNotEmpty);
      for (final f in files) {
        for (final (i, line) in code(f).split('\n').indexed) {
          // The disclaimer, the settings line and the parent note SAY there
          // is no score — a string that DENIES one is the one permitted use.
          if (denial.hasMatch(line)) continue;
          if (banned.hasMatch(line)) hits.add('${f.path}:${i + 1}: ${line.trim()}');
        }
      }
      expect(hits, isEmpty, reason: 'scoring vocabulary in code:\n${hits.join('\n')}');
    });

    /// Activities whose copy may carry a scoring word, each for a named
    /// reason, so a new one is a decision and not a drift:
    ///   cd_1114_10  Make a Quiz Game — the CHILD builds a game that keeps
    ///               its players' points; the task allows it in so many words.
    ///   cm_68_11    Say What You Want and Why — "That is how points land":
    ///               the plural of a point MADE, on the door whose sixth skill
    ///               is putting your point. Task copy, verbatim.
    const scoreAllowed = {'cd_1114_10', 'cm_68_11'};

    // ⚠️ `points`, NOT `points?`. "Make your point" is Communication's sixth
    // skill and is on every one of its cards; a score is plural. Tightened
    // 2026-09-15 when the fill tripped it.
    test('no activity copy scores the child; the allow-list names the games she builds', () {
      final word = RegExp(r'\b(score|scores|scoring|points|streak|leaderboard|percent|percentage|rank|ranking|grade|graded|badge|badges)\b',
          caseSensitive: false);
      final hits = <String>[];
      for (final c in kSkDoorContents) {
        for (final a in c.activities) {
          if (scoreAllowed.contains(a.id)) continue;
          // A sentence that DENIES a score ("never a public gallery with
          // likes or ranking") is the one permitted use, as in the source
          // scan above; it is removed before the check.
          final copy = [a.title, a.oneLine, a.materials, ...a.steps, a.theThinking, a.whatYouPractised]
              .join(' ')
              .replaceAll(denial, '');
          if (word.hasMatch(copy)) hits.add('${c.doorId}/${a.id}');
        }
      }
      expect(hits, isEmpty, reason: 'scoring vocabulary in activity copy:\n${hits.join('\n')}');
    });

    test('the keepsake store returns words and bools, never a number', () {
      final src = code(File('lib/screens/skilling/sk_practice_store.dart'));
      final numeric = RegExp(r'^\s*(int|double|num)\s+(get\s+)?[a-z]\w*', multiLine: true);
      expect(numeric.hasMatch(src), isFalse, reason: 'a public numeric member is a score waiting to be drawn');
    });

    test('no course or product string, on any door, promises a future', () {
      const banned = ['future', 'genius', 'ahead of', 'guarantee', 'will become', 'career', 'job-ready'];
      final hits = <String>[];
      for (final c in kSkDoorContents) {
        for (final s in [
          for (final k in c.courses) ...[k.title, k.blurb],
          for (final p in c.products) ...[p.title, p.blurb],
        ]) {
          for (final b in banned) {
            if (s.toLowerCase().contains(b)) hits.add('${c.doorId}: "$s" ($b)');
          }
        }
      }
      expect(hits, isEmpty, reason: 'outcome claims:\n${hits.join('\n')}');
    });

    test('every child-screen tap target is at least 56', () {
      final src = File('lib/screens/skilling/sk_content.dart').readAsStringSync();
      expect(src.contains('const double kSkTap = 56;'), isTrue);
    });
  });
}
