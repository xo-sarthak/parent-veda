// =============================================================================
//  Door pages are about this child: no "he" for a girl (final review, 2026-10-27)
// -----------------------------------------------------------------------------
//  ⚠️ The door pages are written with "he" for the child, and reached the
//  screen as written: a girl's parent read "Lay him on his side" on the
//  emergency steps. `ppFillPage` (pp_page_fill.dart) fills a page once where
//  every page opens, as the phase pages always were. These tests hold it over
//  every page of every door, the two kinds of page that keep their words,
//  and the call site, because a fill that exists and is never called is the
//  failure this repo has actually hit.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/screens/post_pregnancy/pp_child_profile.dart';
import 'package:parentveda/screens/post_pregnancy/pp_content.dart';
import 'package:parentveda/screens/post_pregnancy/pp_page_fill.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

final _he = RegExp(r'\b(he|him|his|himself)\b', caseSensitive: false);

/// Every word a parent reads on a page.
Iterable<String> _words(PpPage p) sync* {
  yield p.title;
  if (p.subtitle case final s?) yield s;
  for (final b in p.blocks) {
    switch (b) {
      case PpIntro(:final text) || PpIndiaNote(:final text) || PpWhenLine(:final text):
        yield text;
      case PpArticle():
        if (b.heading case final h?) yield h;
        yield* b.paragraphs;
      case PpSteps():
        if (b.heading case final h?) yield h;
        for (final s in b.steps) {
          yield s.title;
          if (s.detail case final d?) yield d;
        }
      case PpCards():
        if (b.heading case final h?) yield h;
        for (final c in b.cards) {
          yield c.title;
          yield c.line;
        }
      case PpTable():
        if (b.heading case final h?) yield h;
        yield* b.columns;
        for (final r in b.rows) {
          yield* r;
        }
      case PpChartCard():
        yield b.title;
        for (final (a, v) in b.rows) {
          yield a;
          yield v;
        }
        if (b.note case final n?) yield n;
      case PpCallout():
        if (b.title case final t?) yield t;
        yield b.text;
      case PpScript():
        for (final l in b.lines) {
          yield l.say;
          if (l.notThis case final n?) yield n;
          if (l.why case final w?) yield w;
        }
      case PpLink():
        yield b.label;
        if (b.blurb case final x?) yield x;
      case PpConsult():
        yield b.title;
        yield b.whoFor;
      case PpCarousel():
        for (final c in b.cards) {
          yield c.title;
          yield c.body;
        }
      case PpInteractive():
        yield b.title;
        for (final it in b.items) {
          yield it.title;
          if (it.detail case final d?) yield d;
        }
        if (b.closing case final c?) yield c;
      default:
        break;
    }
  }
}

Iterable<(String, PpPage)> _pages() sync* {
  for (final s in kPpSections) {
    for (final p in s.allPages) {
      yield ('${s.id}/${p.id}', p);
    }
  }
}

void _child({required bool sexGiven, required bool isBoy, String? name, int days = 200}) {
  final c = ChildProfileStore.instance;
  c.debugSetDob(DateTime.now().subtract(Duration(days: days)));
  c.active
    ..isBoy = isBoy
    ..sexGiven = sexGiven;
  if (name != null) c.active.name = name;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => ChildProfileStore.instance.resetForTest());

  test('a girl reads no he, him or his on any door page', () {
    _child(sexGiven: true, isBoy: false, name: 'Meera');
    var filled = 0;
    for (final (where, page) in _pages()) {
      if (ppPageKeepsPronouns(page)) continue;
      final before = _words(page).where(_he.hasMatch).length;
      if (before > 0) filled++;
      for (final w in _words(ppFillPage(page))) {
        expect(_he.hasMatch(w), isFalse, reason: '$where: "$w"');
      }
    }
    // About 340 strings on some 80 pages said "he" before; this guards the walk.
    expect(filled, greaterThan(60));
  });

  test('sex not given: the name, or "your child" from one with no name', () {
    _child(sexGiven: false, isBoy: true, name: 'Meera');
    expect(ppFillChildText('If he has lost a skill, see a doctor.'),
        'If Meera has lost a skill, see a doctor.');
    ChildProfileStore.instance.resetForTest();
    _child(sexGiven: false, isBoy: true, days: 900);
    expect(ppFillChildText('Help him talk'), 'Help your child talk');
  });

  test("a boy's parent gets the page itself, untouched", () {
    _child(sexGiven: true, isBoy: true, name: 'Arjun');
    for (final (_, page) in _pages()) {
      expect(identical(ppFillPage(page), page), isTrue);
    }
  });

  test('stories and pages about an adult keep their words', () {
    _child(sexGiven: true, isBoy: false, name: 'Meera');
    final adult = {
      for (final (where, p) in _pages())
        if (p.aboutAdult) where,
    };
    expect(adult, {
      'parenting_maternal/people_mother_in_law',
      'parenting_maternal/people_partner',
      'parenting_maternal/people_partner_low',
      'parenting_maternal/people_safe_at_home',
      'parenting_family/fam_couple_on_same_page',
    });
    var stories = 0;
    for (final (_, page) in _pages()) {
      if (!ppPageKeepsPronouns(page)) continue;
      if (page.format?.toUpperCase() == 'STORY') stories++;
      expect(identical(ppFillPage(page), page), isTrue);
      expect(ppPageTitle(page), page.title);
    }
    expect(stories, greaterThan(40));
  });

  test('a filled story page keeps every link on its slide', () {
    _child(sexGiven: true, isBoy: false, name: 'Meera');
    for (final (where, page) in _pages()) {
      if (page.format?.toUpperCase() != 'CARDS') continue;
      final slides = ppCardsAsSlides(ppFillPage(page));
      if (slides == null) continue;
      final named = page.blocks.whereType<PpLink>().where((l) => l.slide != null).length;
      expect(slides.where((s) => s.linkLabel != null).length, named,
          reason: '$where: a link lost its slide once the words were filled');
    }
  });

  test('wired: every page opens filled, and the rows show the filled title', () {
    final open = File('lib/screens/post_pregnancy/pp_section_screen.dart').readAsStringSync();
    expect(open, contains('page = ppFillPage(page);'));
    for (final f in [
      'lib/screens/post_pregnancy/doors/pp_door_screen.dart',
      'lib/screens/post_pregnancy/doors/pp_door_inline_tools.dart',
      'lib/screens/post_pregnancy/pp_section_screen.dart',
      'lib/screens/post_pregnancy/pp_home_v3.dart',
      'lib/screens/post_pregnancy/pp_phase_page.dart',
      'lib/screens/post_pregnancy/pp_search.dart',
    ]) {
      expect(File(f).readAsStringSync(), contains('ppPageTitle('), reason: f);
    }
  });
}

/// The active child's fill on one sentence, as a page would get it.
String ppFillChildText(String s) => ppChildFiller()!(s);
