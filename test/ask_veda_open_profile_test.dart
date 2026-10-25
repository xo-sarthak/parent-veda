// =============================================================================
//  F8 + R3's Ask Veda part (2026-10-25)
// -----------------------------------------------------------------------------
//  Ask Veda answers for the open profile: the home on top picks the screen,
//  the parenting screen says when she is pregnant again or trying again, and
//  after a loss the pregnancy screen sends the loss instead of a week. Both
//  fields are declared by the service (parentveda-askveda,
//  tests/test_family_and_loss.py and the wire contract).
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/services/life_stage_store.dart';
import 'package:parentveda/services/remote/ask_veda_service.dart';
import 'package:parentveda/widgets/global_ask_fab.dart';

String _code(String path) => File(path)
    .readAsStringSync()
    .replaceAll('\r\n', '\n')
    .split('\n')
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  group('the home on top picks Ask Veda', () {
    test('the root alone', () {
      expect(askHomeOnTop([null]), AskHome.pregnancy);
      expect(askHomeOnTop(['ttc/today']), AskHome.trying);
      expect(askHomeOnTop(['pp/my_child']), AskHome.parenting);
    });

    test("a child's home over the TTC root is the child's, not trying's", () {
      expect(askHomeOnTop(['ttc/today', 'pp/my_child', 'pp/vaccines']), AskHome.parenting);
    });

    test('back on the root after the child', () {
      expect(askHomeOnTop(['ttc/today', 'ttc/tools']), AskHome.trying);
    });

    test('a parenting home over the pregnancy shell', () {
      expect(askHomeOnTop([null, 'pp/my_child']), AskHome.parenting);
      expect(askHomeOnTop([null, 'pregnancy/week']), AskHome.pregnancy);
    });

    test('openAskVeda reads the home on top, not a home anywhere in the stack', () {
      final src = _code('lib/widgets/global_ask_fab.dart');
      final fn = src.substring(src.indexOf('void openAskVeda('), src.indexOf('class GlobalAskFab'));
      expect(fn, contains('FabState.instance.homeOnTop'));
      expect(fn, isNot(contains('FabState.instance.inTtc')));
    });
  });

  group('family_stage on the parenting side', () {
    test('pregnant again, trying again, or neither', () {
      expect(askVedaFamilyStage(LifeStage.pregnancy, false), 'pregnancy');
      expect(askVedaFamilyStage(LifeStage.tryingToConceive, false), 'trying');
      expect(askVedaFamilyStage(LifeStage.parenting, false), isNull);
      expect(askVedaFamilyStage(LifeStage.skilling, false), isNull);
      expect(askVedaFamilyStage(null, false), isNull);
    });

    test('a pregnancy that ended is not one she is in', () {
      expect(askVedaFamilyStage(LifeStage.pregnancy, true), isNull);
    });

    test('the parenting screen sends it', () {
      final src = _code('lib/screens/post_pregnancy/askveda_screen.dart');
      expect(src, contains('familyStage: askVedaFamilyStage('));
    });
  });

  group('after a loss, no week', () {
    test('the pregnancy screen sends the loss instead of the week', () {
      final src = _code('lib/screens/tools/ask_veda_screen.dart');
      expect(src, contains('week: ended ? null : p.currentWeek,'));
      expect(src, contains('pregnancyEnded: ended,'));
    });
  });

  group('the wire (two repos)', () {
    test('both keys are in the body', () {
      final src = _code('lib/services/remote/ask_veda_service.dart');
      expect(src, contains("if (pregnancyEnded == true) 'pregnancy_ended': true,"));
      expect(src, contains("'family_stage': ?familyStage,"));
    });

    test('and the service declares them, when its repo is beside this one', () {
      final api = File('../parentveda-askveda/app/channels/app_api.py');
      if (!api.existsSync()) return; // the service repo is not checked out here
      final py = api.readAsStringSync();
      expect(py, contains('pregnancy_ended: bool | None = None'));
      expect(py, contains('family_stage: str | None = None'));
    });
  });
}
