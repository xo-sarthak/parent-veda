// =============================================================================
//  A date of ours that a scan has probably overtaken
// -----------------------------------------------------------------------------
//  §9.1b. `DueDateSource` has recorded who owns her due date since 2026-07-27,
//  and until now nothing read it. The Due Date Calculator says, at the moment
//  she picks a method, that a dating scan should replace a counted date. Nothing
//  ever asked again AFTERWARDS.
//
//  So a woman who counted from her last period in week six, and had a dating
//  scan in week twelve, quietly keeps the weaker number for the rest of her
//  pregnancy — and every week card, every appointment and every countdown
//  derives from it.
//
//  The reason it needs a test rather than a glance: **this is not a defect she
//  can see.** The app is internally consistent — one date in, everything
//  derived from it. Nothing looks wrong, so nobody goes looking.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

/// A Dart file with its comments stripped, so an assertion cannot match the
/// prose explaining itself. (Three tests did exactly that yesterday.)
String codeOf(String path) => File(path)
    .readAsLinesSync()
    .where((l) => !l.trimLeft().startsWith('//'))
    .join('\n');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  /// A due date that puts her at [week] gestational weeks today.
  ///
  /// `currentWeek` counts backwards from the due date, so week 14 means 26
  /// weeks still to run.
  DateTime dueDateForWeek(int week) =>
      DateTime.now().add(Duration(days: (40 - week) * 7));

  Future<PregnancyController> at(int week, DueDateSource source) async {
    final c = PregnancyController();
    await c.setDueDate(dueDateForWeek(week), source: source);
    return c;
  }

  // ===========================================================================
  group('it asks only when asking is useful', () {
    test('a counted date, past the scan window', () async {
      final c = await at(20, DueDateSource.lastPeriod);
      expect(c.dueDateMayBeStale, isTrue);
    });

    test('a conception date too — also ours', () async {
      final c = await at(20, DueDateSource.conception);
      expect(c.dueDateMayBeStale, isTrue);
    });

    test('but never before the scan would have happened', () async {
      // Asking in week eight is asking about an appointment she is already
      // worrying about, and has not had yet. That is how a useful prompt turns
      // into a nag.
      final c = await at(8, DueDateSource.lastPeriod);
      expect(c.dueDateMayBeStale, isFalse);
    });

    test('the threshold is the real clinical window, not a round number', () {
      // A dating scan runs six to fourteen weeks; the combined/NT scan sits at
      // eleven to fourteen. Past fourteen, if she was going to have one, she
      // has had it.
      expect(PregnancyController.datingScanByWeek, 14);
    });
  });

  // ===========================================================================
  group('and never when the date is not ours to question', () {
    test('a dating scan is already the best answer there is', () async {
      final c = await at(20, DueDateSource.scan);
      expect(c.dueDateMayBeStale, isFalse);
    });

    test('an IVF transfer is the clinic\'s — they scheduled it', () async {
      final c = await at(20, DueDateSource.ivfTransfer);
      expect(c.dueDateMayBeStale, isFalse);
    });

    test('and a date her doctor told her is theirs however they got it',
        () async {
      final c = await at(20, DueDateSource.clinician);
      expect(c.dueDateMayBeStale, isFalse);
    });

    test('`unknown` is excluded on purpose, not by omission', () async {
      // It means an older install whose origin we cannot account for. Telling
      // someone to "update" a date we never recorded the source of is a guess
      // wearing a suggestion's clothes — and `unknown` counts as OURS
      // elsewhere precisely so we never silence our estimate on no evidence.
      final c = await at(20, DueDateSource.unknown);
      expect(c.dueDateMayBeStale, isFalse);
    });

    test('and not while she is still on the week-20 placeholder', () {
      final c = PregnancyController();
      expect(c.isDueDateSet, isFalse);
      expect(c.dueDateMayBeStale, isFalse,
          reason: 'there is no date of hers to question yet');
    });
  });

  // ===========================================================================
  group('it reaches a screen', () {
    // The wiring gate. A getter nobody reads is what §9.1b was ABOUT - the
    // whole finding was that `DueDateSource` existed and no screen consulted
    // it. Shipping a second unread getter would be the same bug twice.
    test('the Tools hub reads it', () {
      final src = codeOf('lib/screens/tools_hub_screen.dart');
      expect(src, contains('controller.dueDateMayBeStale'));
      expect(src, contains('t.staleDueDate'),
          reason: 'read but never rendered is the same as never read');
    });

    test('and says it as an offer, not a correction', () {
      // The app does not get to tell her her date is wrong. TruthSource puts
      // her clinician above our calculation, and there is no clinician here.
      final s = const S(AppLanguage.english).ddcMayBeStale.toLowerCase();
      expect(s, startsWith('if you have had'));
      expect(s, isNot(contains('wrong')));
      expect(s, isNot(contains('incorrect')));
      expect(s, isNot(contains('you should')));
    });

    test('in both languages', () {
      expect(const S(AppLanguage.english).ddcMayBeStale, isNotEmpty);
      expect(const S(AppLanguage.hinglish).ddcMayBeStale, isNotEmpty);
      expect(const S(AppLanguage.english).ddcMayBeStale,
          isNot(const S(AppLanguage.hinglish).ddcMayBeStale));
    });

    test('and it is not shouted from the home screen', () {
      // Nothing is wrong today - the app holds one date and derives everything
      // from it consistently. This is a correction OPPORTUNITY, not an error,
      // and a banner on the home for something that is not yet wrong is exactly
      // the noise this product cannot afford.
      for (final f in ['lib/screens/home_screen_b.dart']) {
        if (!File(f).existsSync()) continue;
        expect(codeOf(f), isNot(contains('dueDateMayBeStale')),
            reason: '$f started nagging');
      }
    });
  });
}
