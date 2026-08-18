// =============================================================================
//  Journey — what happens INSIDE a door
// -----------------------------------------------------------------------------
//  A hub answers "why did you open this?". A journey answers "now finish the
//  job". Doors are a fork; a journey is a walk.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THERE IS NO TEMPLATE, AND THAT IS THE WHOLE POINT
//  ---------------------------------------------------------------------------
//  An earlier draft of this work stamped "do the thing -> understand it -> what
//  next -> consult" across every door. It was rejected, correctly, and the tell
//  was obvious in hindsight: **every journey came out the same length.** Real
//  problems do not have uniform depth. "Can I eat papaya" is finished in two
//  steps and must END; managing gestational diabetes across a pregnancy is not
//  a three-step anything.
//
//  So `JourneyConfig` has no required shape. A journey may be two steps or six,
//  may loop, may end without a consult, and SHOULD differ visibly between hubs.
//  If two journeys in different hubs come out identical, one of them is wrong.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVERY STEP HEADING IS HER QUESTION, NEVER OUR CATEGORY
//  ---------------------------------------------------------------------------
//  "What happens on the day?" — not "Content". "What should I be watching for?"
//  — not "Tools". She has never once thought "I need the activities layer".
//  The elements are how we answer; they are not what she is shown.
//
//  ⚠️ AN ELEMENT APPEARS ONLY WHERE IT GENUINELY ANSWERS THE STEP.
//  Never add a product because we have products, a course because we have
//  courses, or a consult because it feels responsible. Equally: never omit one
//  that genuinely helps in order to look minimal — under-using a real
//  capability is the opposite failure and just as bad.
// =============================================================================

import '../../../localization/app_language.dart';
import 'hub_solution_cards.dart';

/// One thing that answers a step. `SolutionType` is the app's existing
/// vocabulary — read, watch, tool, activity, product, course, consult — so a
/// journey cannot invent an element type the app cannot render.
class JourneyElement {
  const JourneyElement({
    required this.type,
    required this.title,
    required this.value,
    this.surfaceId,
    this.action,
    this.meta,
    this.owed = false,
  });

  final SolutionType type;

  /// What it is, in her words.
  final LocalizedText title;

  /// ⚠️ REQUIRED. One line on why it is worth her time. An element with a
  /// title and no reason is a link, and a list of links is the catalogue this
  /// restructure replaced.
  final LocalizedText value;

  final String? surfaceId;
  final String? action;

  /// "6 MIN", "CALCULATOR" — appended to the type chip.
  final LocalizedText? meta;

  /// ⚠️ TRUE MEANS THE PROMISE IS REAL AND THE THING IS NOT BUILT.
  ///
  /// It renders as the same card a shade back, states what it will hold, and is
  /// NOT tappable. That is deliberate: a placeholder that looks tappable and
  /// does nothing teaches her that taps do nothing.
  final bool owed;

  bool get isLive => !owed && (surfaceId != null || action != null);
}

/// One step of a journey: her question, and what answers it.
class JourneyStep {
  const JourneyStep({
    required this.question,
    required this.elements,
    this.note,
  });

  /// ⚠️ HER QUESTION, IN HER WORDS. Never a category name.
  final LocalizedText question;

  /// Usually one. Two is fine when a step genuinely has two halves (read it,
  /// then log it). Three is almost always a category list wearing a heading.
  final List<JourneyElement> elements;

  /// A quiet line under the step — a caution, a reassurance, a cost note.
  final LocalizedText? note;
}

/// The journey behind one door.
class JourneyConfig {
  const JourneyConfig({
    required this.doorId,
    required this.title,
    required this.intro,
    required this.steps,
    this.closesWhen,
    this.reads = const [],
  });

  /// Matches the door's `action` so the router can find it.
  final String doorId;

  /// The door's own words, so she lands on what she tapped.
  final LocalizedText title;

  /// One or two sentences setting up the walk. Not a summary of the steps.
  final LocalizedText intro;

  final List<JourneyStep> steps;

  /// ⚠️ WHAT "DONE" MEANS HERE, written down.
  ///
  /// Every journey must be able to say when it is finished — a solved answer, a
  /// completed action, a saved state, a decision, or an escalation. A journey
  /// with no closure is how a hub grows a "what's next?" step that exists only
  /// because we needed another screen.
  final LocalizedText? closesWhen;

  /// ⚠️ A ROTATING POOL, NOT A STEP.
  ///
  /// This exists because of one line of review about Labour prep:
  ///
  ///   "Remove What Do I get to Choose article. Maybe suggest few reads, but
  ///    better than these suggest 2-3 interesting topics, keep them coming up."
  ///
  /// Three things are packed into that, and the distinction between them is what
  /// this field is for:
  ///
  /// * **Reading is not a step.** A step is a question she has and an answer we
  ///   give. "Here are some articles" is not a question — it was a step in the
  ///   journey because we had an article, which is the supply-side thinking the
  ///   whole door audit was against. It renders *after* the walk instead.
  /// * **A pool, not a list.** More topics live here than are ever shown, and
  ///   three are drawn at a time.
  /// * **"Keep them coming up" means they change.** The selection rotates by the
  ///   day, so the section is different next week without anyone editing it —
  ///   which is the difference between a page that stays alive and one that is
  ///   read once and never again.
  ///
  /// ⚠️ IT ROTATES, IT DOES NOT SHUFFLE. `shownReads` is a pure function of the
  /// date, so the same day always shows the same three. A `Random()` here would
  /// re-draw on every rebuild — she scrolls down, scrolls back, and the section
  /// has changed under her, which reads as a bug and loses whatever she was
  /// about to tap.
  final List<JourneyRead> reads;

  /// The three to show today. Empty pool in, empty list out.
  List<JourneyRead> shownReads(DateTime now, {int take = 3}) {
    if (reads.isEmpty) return const [];
    if (reads.length <= take) return reads;
    // Days since epoch, so the window advances once a day and wraps around the
    // pool. Deterministic per calendar day, and needs no stored state.
    final day = DateTime(now.year, now.month, now.day)
        .difference(DateTime(2026, 1, 1))
        .inDays;
    final start = day % reads.length;
    return [for (var i = 0; i < take; i++) reads[(start + i) % reads.length]];
  }
}

/// One topic in a journey's rotating reading pool.
///
/// Deliberately NOT a `JourneyElement`: an element is something the journey
/// *does*, with a destination and a coming-soon state. A read is a topic, and
/// until real articles are attached it renders as a `PvReadPlaceholder` at the
/// shape a real article card will occupy.
class JourneyRead {
  const JourneyRead({
    required this.title,
    required this.value,
    this.minutes,
    this.surfaceId,
  });

  final LocalizedText title;

  /// One line on why this is worth her time. Not a summary of the article.
  final LocalizedText value;

  /// "4 MIN". Shown where a real article card shows it.
  final LocalizedText? minutes;

  /// Null until a real article exists behind it.
  final String? surfaceId;
}
