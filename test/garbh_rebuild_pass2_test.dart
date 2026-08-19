// =============================================================================
//  Garbh Sanskar rebuild, pass 2 - Samvad, ritual, Kriya safety, invite
// -----------------------------------------------------------------------------
//  ⚠️ THE ORDER OF TWO BUTTONS IS THE WHOLE PRODUCT DECISION IN THIS PASS.
//
//  A narrator reading a story to a baby is content, and every app in this
//  category has it. Her own voice reading it is the thing her baby will
//  recognise at birth, and it is the only thing here nobody else can supply.
//  The moment "Listen" becomes the primary button, Garbh Sanskar is a podcast
//  with a pregnancy theme - and that swap takes one line, looks like a
//  usability improvement, and would never fail a test that only checked both
//  controls exist. So the test checks which one is the filled button.
//
//  ⚠️ AND THE SECOND ONE: the confirmation must never say "completed". It says
//  what happened FOR THE BABY. Completion language describes her performance;
//  this describes the child's experience, which is the difference the whole
//  rebuild rests on.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/garbh_rebuild_data.dart';
import 'package:parentveda/screens/garbh_invite_screen.dart';
import 'package:parentveda/screens/garbh_journal_screen.dart';
import 'package:parentveda/screens/garbh_ritual_screen.dart';
import 'package:parentveda/screens/garbh_samvad_daily.dart';
import 'package:parentveda/services/pregnancy_controller.dart';

PregnancyController _at(int week) {
  final now = DateTime(2026, 1, 1);
  return PregnancyController(
      now: now, dueDate: now.add(Duration(days: (40 - week) * 7)));
}

Future<void> _pump(WidgetTester t, Widget w) async {
  t.view.physicalSize = const Size(420, 4200);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  await t.pumpWidget(MaterialApp(home: w));
  await t.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUp(() => GarbhJournalStore.instance.resetForTest());

  // ===========================================================================
  //  1 · Samvad is record-first
  // ===========================================================================

  group('Samvad puts her voice first', () {
    testWidgets('Record is the primary action, the narrator is a text link',
        (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhSamvadDailyScreen(controller: c));

      expect(find.text('Record in your voice'), findsOneWidget);
      expect(find.text('Or listen to the narrator read it'), findsOneWidget);

      // ⚠️ THE ASSERTION IS THE WIDGET TYPE, NOT THE PRESENCE. Both controls
      // existing proves nothing; which one is filled is the product decision.
      expect(
          find.ancestor(
              of: find.text('Record in your voice'),
              matching: find.byType(FilledButton)),
          findsOneWidget);
      expect(
          find.ancestor(
              of: find.text('Or listen to the narrator read it'),
              matching: find.byType(FilledButton)),
          findsNothing);
    });

    testWidgets('the four shelves are below the fold, not tabs on top',
        (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t,
          GarbhSamvadDailyScreen(controller: c, onOpenLibrary: () {}));

      // Tabs at the top of a daily practice make today's task ambiguous: she
      // arrives to do one thing and is handed a filing cabinet.
      expect(find.byType(TabBar), findsNothing);
      expect(find.text('Choose something else to read'), findsOneWidget);

      final say = t.getTopLeft(find.text('SAY THIS ALOUD')).dy;
      final lib = t.getTopLeft(find.text('Choose something else to read')).dy;
      expect(say, lessThan(lib));
    });

    testWidgets('the why-this-week line is on the screen too', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhSamvadDailyScreen(controller: c));
      expect(find.text('WHY WEEK 22 MATTERS'), findsOneWidget);
    });

    testWidgets('nothing offers to mark it complete', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhSamvadDailyScreen(controller: c));
      expect(find.text('Mark complete'), findsNothing);
      expect(find.text('Mark done'), findsNothing);
    });
  });

  // ===========================================================================
  //  2 · My ritual: multi-faith, and only the plan gets a bar
  // ===========================================================================

  group('My ritual', () {
    testWidgets('every faith option is on the same screen at equal weight',
        (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhRitualScreen(controller: c));

      // ⚠️ NOT AN "OTHER" BUCKET. A woman with no religious practice is one of
      // the options, not an exception to be handled below the fold.
      expect(find.text('Gita paath, 40-week plan'), findsOneWidget);
      expect(find.text('A Quran passage'), findsOneWidget);
      expect(find.text('A Bible passage'), findsOneWidget);
      expect(find.text('Five minutes of silence'), findsOneWidget);
    });

    testWidgets('picking one shows the plan bar, and only for the plan',
        (t) async {
      final c = _at(20);
      addTearDown(c.dispose);
      await _pump(t, GarbhRitualScreen(controller: c));

      // Nothing selected: no bars at all.
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await t.tap(find.text('Five minutes of silence'));
      await t.pump();
      // ⚠️ A HABIT HAS NO END, so a bar on one can only ever show a deficit.
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await t.tap(find.text('Gita paath, 40-week plan'));
      await t.pump();
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.textContaining('weeks to go'), findsOneWidget);
      // ⚠️ THE PROMISE APPEARS EXACTLY ONCE. It belongs in the blurb, where
      // she reads it before choosing; repeating it on the progress line put
      // the same sentence twice in one card.
      expect(find.textContaining('finishing the week before your due date'),
          findsOneWidget);
    });

    testWidgets('it says nothing here is required', (t) async {
      final c = _at(22);
      addTearDown(c.dispose);
      await _pump(t, GarbhRitualScreen(controller: c));
      // A multi-select with no explicit opt-out reads as a form she must fill,
      // on a subject where being made to declare a practice she does not have
      // is worse than not asking.
      expect(find.textContaining('None of these is required'), findsOneWidget);
    });

    test('selections persist through the store', () {
      final s = GarbhJournalStore.instance;
      expect(s.hasRitual('japa'), isFalse);
      s.toggleRitual('japa');
      expect(s.hasRitual('japa'), isTrue);
      s.toggleRitual('japa');
      expect(s.hasRitual('japa'), isFalse);
    });
  });

  // ===========================================================================
  //  3 · The invite is honest about not working yet
  // ===========================================================================

  group('invite someone to record', () {
    testWidgets('the relationship list is open, not fixed', (t) async {
      await _pump(t, const GarbhInviteScreen());

      for (final w in ['Papa', 'Dadi', 'Nani', 'Bua']) {
        expect(find.text(w), findsOneWidget, reason: w);
      }
      // ⚠️ A CLOSED LIST DECIDES FOR HER, and it fails first for exactly the
      // families whose shape is least standard.
      expect(find.text('Someone else'), findsOneWidget);
    });

    testWidgets('"Someone else" lets her type her own word', (t) async {
      await _pump(t, const GarbhInviteScreen());
      expect(find.byType(TextField), findsNothing);

      await t.tap(find.text('Someone else'));
      await t.pump();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('What do you call them?'), findsOneWidget);
    });

    testWidgets('the share button is disabled until someone is chosen',
        (t) async {
      await _pump(t, const GarbhInviteScreen());
      var btn = t.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNull);

      await t.tap(find.text('Dadi'));
      await t.pump();
      btn = t.widget<FilledButton>(find.byType(FilledButton));
      expect(btn.onPressed, isNotNull);
      expect(find.text('Ask Dadi'), findsOneWidget);
    });

    testWidgets('it says the recorder is not live yet', (t) async {
      await _pump(t, const GarbhInviteScreen());
      // ⚠️ SENDING A DEAD LINK IS WORSE THAN NOT OFFERING THE BUTTON: the
      // family member is not told it failed, they are told nothing, and the
      // mother finds out days later when nothing has arrived.
      expect(find.textContaining('still being built'), findsOneWidget);
    });
  });

  // ===========================================================================
  //  4 · My Journal reaches the invite, and promises the handover
  // ===========================================================================

  group('My Journal closes the loop', () {
    testWidgets('the invite is reachable from the album', (t) async {
      await _pump(t, const GarbhJournalScreen());
      await t.scrollUntilVisible(find.text('Invite someone to record'), 500,
          scrollable: find.byType(Scrollable).first);
      await t.tap(find.text('Invite someone to record'));
      await t.pumpAndSettle();
      expect(find.byType(GarbhInviteScreen), findsOneWidget);
    });

    testWidgets('it promises the album survives the birth', (t) async {
      await _pump(t, const GarbhJournalScreen());
      await t.scrollUntilVisible(
          find.textContaining('does not disappear after the birth'), 500,
          scrollable: find.byType(Scrollable).first);
      expect(find.textContaining('your newborn will already know'),
          findsOneWidget);
    });
  });
}
