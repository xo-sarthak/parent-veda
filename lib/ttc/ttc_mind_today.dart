// =============================================================================
//  "Today", for Mind & body — which practice, and whether it is done
// -----------------------------------------------------------------------------
//  No widgets here. The screen renders what this decides, and everything this
//  decides is either a pure function of the date or a row in `TtcLogStore`.
//
//  ⚠️ THERE IS NO STORE IN THIS FILE, AND THAT IS THE DESIGN. Two things needed
//  remembering — which card today's is, and whether it was done — and both
//  already have a home:
//
//    · WHICH CARD is a pure function of the date. Nothing is written down, so
//      nothing can drift, nothing needs migrating, and the same day gives the
//      same answer on a reinstall.
//    · WHETHER IT WAS DONE is a row in `TtcLogStore`, which already persists
//      locally, already syncs, and is already where every other daily fact in
//      this stage lives.
//
//  A third persistence mechanism for two booleans would have been the easiest
//  thing to write and the hardest thing to remember exists.
// =============================================================================

import 'ttc_garbh_course_store.dart';
import 'ttc_log_store.dart';
import 'ttc_practice_data.dart';

/// The tracker id these rows are filed under.
///
/// ⚠️ NOT `habits`. The two habit TICKS on Today write into `habits`, because a
/// sleep habit belongs with the other habits. Practice completion does not — it
/// is not a habit she is working on, it is a record of opening a card. Filing
/// them together would put "did today's breathing" into "What you're working
/// on" beside sleep and alcohol, which quietly turns a five-minute practice
/// into another thing she is being measured on.
const String kTtcMindTracker = 'mindbody';

const String kTtcMindMoveField = 'move';
const String kTtcMindBreatheField = 'breathe';

/// Days since the epoch — the rotation's only input.
int _dayIndex(DateTime d) =>
    DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(1970)).inDays;

/// Today's practice from one library.
///
/// ⚠️ THE BRIEF ASKS FOR SOMETHING ARITHMETIC CANNOT GIVE, AND THIS IS THE
/// HONEST APPROXIMATION. It says *"rotate so the same card does not repeat
/// within seven days"*, and each library holds six cards. Seven days without a
/// repeat needs seven distinct cards; with six, the seventh day must repeat one
/// of them. Pigeonhole, not an implementation problem.
///
/// So this does the strongest thing available: a strict cycle through all six
/// before any card comes round again — no repeat within SIX days, and the gap
/// is always exactly six rather than random. Raising it to seven is one more
/// card in each library, and it is written down in `docs/STILL-OPEN.md` §28.
///
/// ⚠️ AND IT IS A CYCLE, NOT A RANDOM PICK. Random with a memory of the last
/// six is the same thing with more code and a worse failure: a shuffle can
/// serve the ten-minute walk on three consecutive Mondays, and somebody who
/// only practises at the weekend then sees one card forever.
///
/// [offset] is how the two partners get different cards on the same day. Half a
/// library apart, so they are never on the same one.
TtcPractice ttcPracticeOfTheDay(TtcPracticeKind kind,
    {DateTime? on, int offset = 0}) {
  final list = ttcPracticesOfKind(kind);
  final i = (_dayIndex(on ?? DateTime.now()) + offset) % list.length;
  return list[i];
}

/// The offset the partner's Today uses. Three, on a library of six.
const int kTtcPartnerOffset = 3;

// -----------------------------------------------------------------------------
//  Done today
// -----------------------------------------------------------------------------

String _fieldFor(TtcPracticeKind kind) => switch (kind) {
      TtcPracticeKind.move => kTtcMindMoveField,
      TtcPracticeKind.breathe => kTtcMindBreatheField,
    };

bool ttcPracticeDoneToday(TtcPracticeKind kind, {DateTime? on}) =>
    TtcLogStore.instance
            .valueFor(kTtcMindTracker, _fieldFor(kind), on: on)
            ?.value ==
        1;

/// Mark one of today's two practices done, or undo it.
///
/// ⚠️ IT CAN BE UNDONE, WHICH A "well done" SCREEN USUALLY CANNOT. A tick that
/// only goes one way turns a mis-tap into a permanent small lie, and the person
/// most likely to care about that is the person being careful.
void ttcSetPracticeDone(TtcPracticeKind kind, bool done, {DateTime? on}) {
  final field = _fieldFor(kind);
  if (done) {
    TtcLogStore.instance.log(kTtcMindTracker, field, 1, on: on);
  } else {
    TtcLogStore.instance.clear(kTtcMindTracker, field, on: on);
  }
}

// -----------------------------------------------------------------------------
//  The two habit ticks
// -----------------------------------------------------------------------------
//  These go into the `habits` tracker, not into `mindbody` — see the note on
//  `kTtcMindTracker`.

const String kTtcHabitsTracker = 'habits';
const String kTtcBedtimeField = 'bedtime';
const String kTtcHomeCookedField = 'homecooked';

bool ttcHabitTicked(String field, {DateTime? on}) =>
    (TtcLogStore.instance.valueFor(kTtcHabitsTracker, field, on: on)?.value ??
            0) >
        0;

void ttcSetHabitTick(String field, bool on, {DateTime? day}) {
  if (on) {
    TtcLogStore.instance.log(kTtcHabitsTracker, field, 1, on: day);
  } else {
    TtcLogStore.instance.clear(kTtcHabitsTracker, field, on: day);
  }
}

// -----------------------------------------------------------------------------
//  What is deliberately absent
// -----------------------------------------------------------------------------
//  ⚠️ THERE IS NO STREAK FUNCTION HERE, AND THE BRIEF FORBIDS ONE FOUR TIMES:
//  "No streak", "no streak-break message anywhere", "track only done today",
//  "do not add any streak, points, badges or gamification".
//
//  The rows this file writes are date-keyed, so a streak COULD be computed from
//  them — `TtcLogStore.history` would hand it over in one line. That is exactly
//  why the absence is written down rather than left to be noticed: the next
//  person to open this file will see that the data supports a streak and will
//  reasonably assume nobody had got round to it.
//
//  Nobody forgot. A streak turns a five-minute practice into a thing she can
//  fail at during the one part of her life where she is already keeping score
//  of something she cannot control. `test/ttc_mind_body_test.dart` asserts that
//  neither this file nor the screens contain the word.

// -----------------------------------------------------------------------------
//  What Today actually shows — her practice if she built one, else the rotation
// -----------------------------------------------------------------------------
//  ⚠️ THESE ARE SEPARATE FUNCTIONS RATHER THAN A FLAG ON `ttcPracticeOfTheDay`,
//  AND THE REASON IS THAT THE ROTATION HAS TO STAY PURE. `ttcPracticeOfTheDay`
//  is a function of the date and nothing else — a reinstall gives the same card,
//  a test gives the same card, and `ttc_mind_body_test.dart` asserts exactly
//  that. Reaching into a store from inside it would make all three untrue.
//
//  So the rotation stays a calendar and the preference sits in front of it.
//
//  ⚠️ WHY A PREFERENCE EXISTS AT ALL, given the rebuild brief says Today rotates
//  daily. The course brief is equally explicit that session 8 *"must WRITE the
//  user's picks into their Today tab"* and that the course *"must end by
//  producing their practice"*. Both are satisfied by making the rotation the
//  DEFAULT rather than the only behaviour: someone who has never opened the
//  course sees exactly what the rebuild describes, and someone who has just
//  spent eight sessions deciding what she likes is not handed a different card
//  the next morning. Today's header says which of the two is on screen, and
//  `TtcGarbhCourseStore.clearDailyPractice` hands it back.

/// Today's movement — her chosen one if session 8 set it, otherwise the day's.
TtcPractice ttcTodaysMove({DateTime? on, int offset = 0}) {
  final chosen = TtcGarbhCourseStore.instance.moveId;
  if (chosen != null) {
    final p = ttcPracticeById(chosen);
    // Resolved rather than trusted: a stored id whose practice has since been
    // renamed falls back to the rotation instead of showing an empty card.
    if (p != null && p.kind == TtcPracticeKind.move) return p;
  }
  return ttcPracticeOfTheDay(TtcPracticeKind.move, on: on, offset: offset);
}

/// Today's breath or calm — same rule.
TtcPractice ttcTodaysBreathe({DateTime? on, int offset = 0}) {
  final chosen = TtcGarbhCourseStore.instance.breatheId;
  if (chosen != null) {
    final p = ttcPracticeById(chosen);
    if (p != null && p.kind == TtcPracticeKind.breathe) return p;
  }
  return ttcPracticeOfTheDay(TtcPracticeKind.breathe, on: on, offset: offset);
}

/// True when Today is showing something she chose rather than something the
/// calendar chose. Drives one line of copy and nothing else.
///
/// ⚠️ IT ASKS THE STORE, NOT THE TWO CARDS. Comparing the rendered ids against
/// the rotation looks equivalent and is wrong roughly one day in six: her chosen
/// card and the day's card are sometimes the same card, and on that day the line
/// would flip to "the rotation" underneath a practice she picked herself.
bool get ttcTodayIsHerPractice =>
    TtcGarbhCourseStore.instance.moveId != null ||
    TtcGarbhCourseStore.instance.breatheId != null;
