// =============================================================================
//  TTC — the first-run flow
// -----------------------------------------------------------------------------
//  Language → an introduction → three questions. Shown once, the first time
//  someone opens the Trying-to-Conceive stage, and never again.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THIS IS A TTC SCREEN AND NOT THREE MORE STEPS IN `AuthFlowScreen`
//  ---------------------------------------------------------------------------
//
//  The obvious home for it is the auth machine, which already runs welcome →
//  signup → role → profile and knows whether onboarding is owed. It is the
//  wrong home for two reasons:
//
//    · **Auth is shared by three stages.** A pregnant mother and a father
//      pairing by code go through the same 2,600-line state machine, and
//      hanging TTC's questions off it means every future stage adds its own
//      branch to a file none of them own.
//    · **The trigger is not "signed up", it is "arrived in TTC".** Someone can
//      reach this stage from the pregnancy home's doorway months after
//      creating an account. Gating on signup would show her nothing.
//
//  So the gate is the stage, and it lives with the stage.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THREE QUESTIONS, AND EVERY ONE OF THEM IS READ BY SOMETHING
//  ---------------------------------------------------------------------------
//
//  The reference flow this was modelled on asks seventeen. That is a deliberate
//  reduction, not a first pass — CLAUDE.md's rule is *derive, never ask*: only
//  ask for what is genuinely unknowable, and say what the answer unlocks. Each
//  of these three fails to be derivable and drives something concrete:
//
//    1. **When did your last period start?** → `CycleStore.logPeriodStart`.
//       Nothing in the stage works without one date, and no amount of watching
//       can infer it. Carries an "I don't know" escape, because a guessed date
//       is worse than no date — the engine refuses to estimate on no data and
//       cheerfully estimates on wrong data.
//    2. **How long have you been trying?** → `TtcStore.setJourneyStart`, which
//       is what `monthsTrying` in `ttc_fertility_help_rules.dart` reads to
//       decide when to raise seeking help. Derivable only by waiting a year.
//    3. **Is a clinic involved?** → `TtcStore.setPath`, and this is the one
//       with teeth. It sets `TimingOwnership`, which decides whether the app
//       may generate a fertile window AT ALL. Getting it wrong means showing a
//       woman on IVF an ovulation prediction her clinic never made.
//
//  Everything the reference asks that we do not — diet, sleep, discharge,
//  height, weight, whether a doctor recommended us — is either derivable from
//  what she logs, or is content targeting dressed as care. Neither is worth a
//  screen before she has seen the product.
//
//  ⚠️ AND EVERY STEP IS SKIPPABLE. There is no required answer anywhere in this
//  flow, including the video. A first run that cannot be escaped is the one
//  reliable way to lose someone before they have seen anything.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/reads/read_images.dart' show pvFilmStillFor;
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvChoiceTile, PvPress;
import '../../widgets/pv_placeholders.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_care_pathway.dart';
import '../../services/family_profile.dart' show FamilyProfileStore;
import '../../ttc/ttc_ready_plan.dart'
    show readyMonthLabel, readyMonthsBetween;
import '../../ttc/ttc_ready_plan_store.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';
import 'ttc_tool_chrome.dart' show TtcToolClose, TtcToolLeading;

/// The slot id the introduction film will be mapped to.
///
/// ⚠️ TWO IDS, ONE PER LANGUAGE, AND THE SPLIT IS THE POINT. The spec asks for
/// the introduction to be chosen by the language picked one screen earlier, so
/// a single id would quietly guarantee English audio for a Hindi user the day
/// the files land. Declaring both now means the wiring is stated at the moment
/// the placeholder is written rather than worked out again later — the rule at
/// the head of `pv_placeholders.dart`.
///
/// ⚠️ AND `hinglish` IS AN IDENTITY HERE TOO. It is the persisted enum value,
/// not a description of the script rendered. See CLAUDE.md.
String ttcIntroVideoSlotId(bool hinglish) =>
    hinglish ? 'ttc_intro_hi' : 'ttc_intro_en';

/// Whether the first-run flow still owes this user a showing.
///
/// ⚠️ A LOCAL FLAG, AND THAT IS THE RIGHT SCOPE. It records "this install has
/// seen the introduction", which is a fact about the device rather than about
/// the family — the same reading `launch_promo.dart` takes. Syncing it would
/// mean a woman who reinstalls never sees the one screen that explains the
/// stage, to save her a screen she can dismiss in one tap.
class TtcIntroGate {
  static const _key = 'ttc_intro_seen_v1';

  static Future<bool> owed() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_key) ?? false);
  }

  static Future<void> markSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_key, true);
  }

  /// Testing only — the same shape every other TTC store exposes.
  static Future<void> resetForTest() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_key);
    await p.remove(_cardKey);
    await p.remove(_popupKey);
    _cardUntil = null;
    _popupOwed = false;
  }

  // ---- the film as a card on her home (2026-10-18) -------------------------
  //
  // ⚠️ THE FILM STOOD BETWEEN ONBOARDING AND HER HOME. She had just been
  // through a reveal, and a second front door followed it. The user decided:
  // onboarding marks the introduction seen, and the film waits on her home as
  // the first card of the Today rail for her first week, until she opens it.
  // Local, like the gate, for the same reason.

  static const _cardKey = 'ttc_intro_card_until_v1';
  static DateTime? _cardUntil;

  /// True while the card is offered: the first week, until she opens it.
  static bool cardShowing({DateTime? now}) {
    final until = _cardUntil;
    return until != null && (now ?? DateTime.now()).isBefore(until);
  }

  /// Onboarding: offer the card for [days] days, and the welcome pop-up once.
  static Future<void> offerCard({int days = 7}) async {
    final until = DateTime.now().add(Duration(days: days));
    _cardUntil = until;
    _popupOwed = true;
    final p = await SharedPreferences.getInstance();
    await p.setString(_cardKey, until.toIso8601String());
    await p.setBool(_popupKey, true);
  }

  /// The home reads it once.
  static Future<void> loadCard() async {
    final p = await SharedPreferences.getInstance();
    _cardUntil = DateTime.tryParse(p.getString(_cardKey) ?? '');
    _popupOwed = p.getBool(_popupKey) ?? false;
  }

  // ⚠️ THE WELCOME POP-UP (walk 2026-10-20, the user: "the video should be
  // accessible ... right now it disappeared"). Straight after onboarding the
  // film is offered once, centred, with Skip. A persisted flag, not
  // PvFirstHome alone, so a kill between onboarding and the home still gets
  // it; spent the moment it shows, so it never comes back.
  static const _popupKey = 'ttc_intro_popup_owed_v1';
  static bool _popupOwed = false;
  static bool get popupOwed => _popupOwed;

  static Future<void> popupShown() async {
    _popupOwed = false;
    final p = await SharedPreferences.getInstance();
    await p.remove(_popupKey);
  }

  /// She opened the film: the card has done its job.
  ///
  /// ⚠️ NO LONGER CALLED ON TAP (walk 2026-10-20). The home called this
  /// before the film opened, so one tap, even straight back out, removed the
  /// film for good. The card now stays its full week, and the film always
  /// has a home in Learn. Kept for revert and for tests.
  static Future<void> cardOpened() async {
    _cardUntil = null;
    final p = await SharedPreferences.getInstance();
    await p.remove(_cardKey);
  }
}

/// How long she says she has been trying. Maps to a journey start.
// ⚠️ `planning` FIRST (2026-10-17, the Ready-to-Try plan): a couple who have
// not started yet. It sets NO journey start; the month they pick goes to
// `TtcReadyPlanStore`, which `TtcStore.journeyStart` reads, so the
// how-long-trying clock starts in that month and not today. Never persisted
// by index, so adding it first moves nothing.
enum TtcTryingFor { planning, justStarted, upToSix, sixToTwelve, overAYear }

extension TtcTryingForCopy on TtcTryingFor {
  String label(bool hi) => switch (this) {
        // English on both sides: new copy is English (CLAUDE.md).
        TtcTryingFor.planning => "Not yet, we're getting ready",
        TtcTryingFor.justStarted =>
          hi ? 'Abhi shuru kiya hai' : "We've just started",
        TtcTryingFor.upToSix => hi ? '6 mahine tak' : 'Up to six months',
        TtcTryingFor.sixToTwelve =>
          hi ? '6 se 12 mahine' : 'Six months to a year',
        TtcTryingFor.overAYear => hi ? 'Ek saal se zyada' : 'Over a year',
      };

  /// ⚠️ THE MIDDLE OF THE BAND, NOT ITS EDGE. "Six months to a year" becomes
  /// nine, not six and not twelve. The readiness rules raise seeking help at
  /// twelve months (six over 35), so anchoring at the bottom of a band delays
  /// that by up to half a year and anchoring at the top brings it forward by
  /// the same — and she will not be told which the app picked.
  int get approxMonths => switch (this) {
        // Never used to set a start: see `_finish`.
        TtcTryingFor.planning => 0,
        TtcTryingFor.justStarted => 0,
        TtcTryingFor.upToSix => 3,
        TtcTryingFor.sixToTwelve => 9,
        TtcTryingFor.overAYear => 18,
      };
}

class TtcIntroFlow extends StatefulWidget {
  const TtcIntroFlow({super.key, required this.onDone});

  /// Called once, whether she answered everything or skipped the lot.
  final VoidCallback onDone;

  @override
  State<TtcIntroFlow> createState() => _TtcIntroFlowState();
}

class _TtcIntroFlowState extends State<TtcIntroFlow> {
  int _step = 0;

  DateTime? _lastPeriod;
  TtcTryingFor? _trying;

  /// The month they want to start trying, when [_trying] is planning.
  DateTime? _plannedMonth;
  TtcPath? _path;

  // ⚠️ THE FILM ONLY, SINCE ONBOARDING V3 (2026-10-17). Onboarding now asks
  // where she is (getting ready / on our own / with a clinic), her last
  // period and how long, once, and writes them to the same stores. Asking
  // again here was the duplicate the user caught. The language step went on
  // the user's word ("NO LANGUAGE QUES! It's only English"). The steps stay
  // in this file, unreachable, kept for revert:
  //   static const _steps = 5; // language · video · 3 questions
  static const _steps = 1; // the film

  void _next() {
    if (_step >= _steps - 1) {
      _finish();
      return;
    }
    setState(() => _step++);
  }

  /// ⚠️ WRITES EVERYTHING AT THE END, NOT AS SHE GOES. A woman who abandons
  /// halfway should leave no half-configured stage behind her: a journey start
  /// with no period, or a pathway with no journey start, both produce a home
  /// screen that has opinions it has not earned. Answered-or-not is checked per
  /// field, so skipping one question does not discard the others.
  Future<void> _finish() async {
    final period = _lastPeriod;
    if (period != null) CycleStore.instance.logPeriodStart(period);

    final trying = _trying;
    // ⚠️ PLANNING SETS NO JOURNEY START. The month goes to the plan's store,
    // which `TtcStore.journeyStart` reads, so seek-help timing counts from
    // the month they actually start. The answer is also kept as the profile's
    // "Trying for" when there is none yet, so You says it.
    if (trying == TtcTryingFor.planning) {
      await TtcReadyPlanStore.instance.setPlannedStart(_plannedMonth);
      if (FamilyProfileStore.instance.otherFor('ttc_duration') == null) {
        FamilyProfileStore.instance.setOther('ttc_duration', 'planning');
      }
    } else if (trying != null) {
      final months = trying.approxMonths;
      TtcStore.instance.setJourneyStart(
          DateTime.now().subtract(Duration(days: (months * 30.44).round())));
    }

    final path = _path;
    if (path != null) TtcStore.instance.setPath(path);

    await TtcIntroGate.markSeen();
    if (mounted) widget.onDone();
  }

  Future<void> _skipAll() async {
    await TtcIntroGate.markSeen();
    if (mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        // ⚠️ A WAY BACK ONE STEP, FROM STEP TWO ON (2026-09-29, the user:
        // "multi-step flows should be getting a back arrow"). Five steps had
        // Skip and nothing else, and the phone's back gesture on step four
        // left the stage with three answers unsaved. Now steps two to five
        // draw the tools' round back arrow, and a pop on them (the arrow, the
        // gesture) steps back one with every answer kept. Step one has no
        // arrow: this is the stage's first screen and Skip is its way out.
        // Mobbin: Flo's onboarding shows its "<" only after the first step,
        // https://mobbin.com/flows/d64dd348-5de3-40d0-8e2a-1fa781dad065
        return PopScope(
          canPop: _step == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop && _step > 0) setState(() => _step--);
          },
          child: Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: Column(children: [
              // ---- progress and the escape ------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(ttcGutter, 12, ttcGutter, 4),
                child: Row(children: [
                  if (_step > 0) ...[
                    const TtcToolClose(mode: TtcToolLeading.back),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: (_step + 1) / _steps,
                        minHeight: 4,
                        backgroundColor: ttcPanel,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(ttcPurple),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // ⚠️ SMALL AND QUIET, AND ALWAYS THERE. Every step of this
                  // flow can be left. A "skip" that only appears on the screens
                  // we do not mind losing is not an escape, it is a funnel.
                  PvPress(child: GestureDetector(
                    onTap: _skipAll,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Text(t.introSkip,
                          style: ttcBody(12.5,
                              color: ttcMuted, w: FontWeight.w700)),
                    ),
                  )),
                ]),
              ),
              Expanded(child: _current(t)),
            ]),
          ),
          ),
        );
      },
    );
  }

  Widget _current(TtcS t) => _video(t);
  // Kept for revert (Onboarding V3, see `_steps`):
  //   switch (_step) {
  //     0 => _language(t),
  //     1 => _video(t),
  //     2 => _periodQuestion(t),
  //     3 => _tryingQuestion(t),
  //     _ => _pathQuestion(t),
  //   };

  // ===========================================================================
  //  1. Language
  // ---------------------------------------------------------------------------
  //  ⚠️ AFTER LOGIN, NOT BEFORE IT. The reference app asks first, on a cold
  //  screen, before anyone has any reason to care. Asking here means the answer
  //  arrives attached to something — the very next screen is the introduction,
  //  in the language just chosen, which is the only demonstration of the
  //  setting that will ever be that immediate.
  //
  //  ⚠️ TWO OPTIONS, NOT SIX. The app ships English and Hindi. Listing Bangla,
  //  Telugu, Tamil and Kannada because a competitor does would promise four
  //  languages that resolve to English the moment she taps one.
  // ===========================================================================
  // Unreachable since Onboarding V3; kept for revert (see `_steps`).
  // ignore: unused_element
  Widget _language(TtcS t) => _Page(
        title: t.introLanguageTitle,
        body: t.introLanguageBody,
        children: [
          // ⚠️ NO SUB-LABEL ON THIS ONE. The gloss under a language name exists
          // to tell a reader what an unfamiliar script says — "हिन्दी" needs
          // "Hindi" under it. "English" under "English" is the reference app's
          // habit copied without its reason, and it also made the row two
          // identical strings, which is a real problem the moment anything
          // needs to address one of them.
          _Choice(
            label: 'English',
            selected: !TtcLang.instance.hinglish,
            onTap: () {
              TtcLang.instance.hinglish = false;
              _next();
            },
          ),
          const SizedBox(height: 11),
          _Choice(
            // ⚠️ THE FLAG IS `hinglish` AND THAT IS AN IDENTITY, not a
            // description of what it renders. It is persisted verbatim in
            // `shared_preferences`; renaming it would strand everyone who has
            // already chosen it. See CLAUDE.md.
            label: 'हिन्दी',
            sub: 'Hindi',
            selected: TtcLang.instance.hinglish,
            onTap: () {
              TtcLang.instance.hinglish = true;
              _next();
            },
          ),
        ],
      );

  // ===========================================================================
  //  2. The introduction
  // ---------------------------------------------------------------------------
  //  ⚠️ THE PLAYER IS A PLACEHOLDER AND THE SCREEN SAYS SO RATHER THAN
  //  PRETENDING. There is no film yet. Two things had to be true anyway:
  //
  //    · The slot has to exist, at the right point in the flow, or the moment
  //      it is commissioned nobody knows where it goes.
  //    · What is on screen until then has to be honest and useful on its own —
  //      an empty 16:9 rectangle with a play button that does nothing is worse
  //      than no video, because it reads as a broken app on first launch.
  //
  //  So the card carries the summary the film will carry, in words, and says
  //  plainly that the film is coming. When it lands, this becomes a
  //  `video_player` over a self-hosted MP4/HLS — NOT YouTube, which was tested
  //  to exhaustion and is systemically blocked; see the Watch engine.
  //
  //  ⚠️ AND IT IS PER-LANGUAGE. `ttcIntroVideoSlot` resolves by the language
  //  chosen one screen ago, so the Hindi build must get the Hindi film rather
  //  than English audio under Hindi captions.
  // ===========================================================================
  Widget _video(TtcS t) => _Page(
        title: t.introVideoTitle,
        body: t.introVideoBody,
        children: [
          // ⚠️ THE SHIPPED PLACEHOLDER, NOT A FIFTH HAND-ROLLED ONE. This
          // screen originally drew its own gradient box, which is exactly the
          // habit `pv_placeholders.dart` was extracted to stop — its header
          // says so: "placeholders kept being re-rolled per screen". It also
          // gets two behaviours for free that a hand-rolled box did not have:
          // real 16:9 geometry, and NOT being tappable, so nobody taps a play
          // control that plays nothing.
          PvVideoPlaceholder(
            title: t.introVideoLabel,
            overlayTitle: true,
            duration: '2 MIN',
            hue: 268,
            slotId: ttcIntroVideoSlotId(TtcLang.instance.hinglish),
            // A relevant still until the film is made (2026-09-29); "Coming
            // soon" and the not-tappable rule are unchanged.
            still: pvFilmStillFor(
                ttcIntroVideoSlotId(TtcLang.instance.hinglish)),
          ),
          const SizedBox(height: 18),
          // The film's content, as words, so the screen is worth its place
          // before the film exists.
          for (final line in t.introVideoPoints) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                margin: const EdgeInsets.only(top: 7),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                    color: ttcTitleInk, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(line,
                      style: ttcBody(13.5, color: ttcInk, h: 1.55))),
            ]),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 8),
          _Primary(label: t.introContinue, onTap: _next),
        ],
      );

  // ===========================================================================
  //  3. The one date the stage cannot work without
  // ===========================================================================
  // Unreachable since Onboarding V3; kept for revert (see `_steps`).
  // ignore: unused_element
  Widget _periodQuestion(TtcS t) => _Page(
        title: t.introPeriodTitle,
        body: t.introPeriodBody,
        children: [
          _Primary(
            label: _lastPeriod == null
                ? t.introPickDate
                : t.introDatePicked(_fmt(_lastPeriod!)),
            onTap: () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: _lastPeriod ?? now,
                // A period start is always in the past — offering the future
                // invites the one input the engine has to reject. Same bound
                // `logTtcPeriod` uses.
                firstDate: now.subtract(const Duration(days: 400)),
                lastDate: now,
                helpText: t.logPeriodTitle,
              );
              if (picked != null) setState(() => _lastPeriod = picked);
            },
          ),
          const SizedBox(height: 12),
          // ⚠️ "I DON'T KNOW" IS A REAL ANSWER AND IT IS NOT A SKIP. A guessed
          // period start is worse than none: with no date the engine refuses to
          // estimate and says so, and with a wrong one it estimates confidently
          // and is wrong on every screen at once.
          _Ghost(label: t.introDontKnow, onTap: _next),
          if (_lastPeriod != null) ...[
            const SizedBox(height: 12),
            _Ghost(label: t.introContinue, onTap: _next, emphasised: true),
          ],
        ],
      );

  // ===========================================================================
  //  4. How long
  // ===========================================================================
  /// Next month and the six after it. This month is left out: planning means
  /// not yet, and a couple starting now pick "We've just started".
  List<DateTime> _monthChoices() {
    final now = DateTime.now();
    return [for (var i = 1; i <= 7; i++) DateTime(now.year, now.month + i)];
  }

  // Unreachable since Onboarding V3; kept for revert (see `_steps`).
  // ignore: unused_element
  Widget _tryingQuestion(TtcS t) => _Page(
        title: t.introTryingTitle,
        body: t.introTryingBody,
        children: [
          for (final option in TtcTryingFor.values) ...[
            _Choice(
              label: option.label(t.hinglish),
              selected: _trying == option,
              onTap: () {
                setState(() => _trying = option);
                // Planning asks one more thing on this same page: the month.
                if (option != TtcTryingFor.planning) _next();
              },
            ),
            const SizedBox(height: 11),
            // ⚠️ THE MONTH, INLINE, NOT A SIXTH STEP. Still five steps and
            // still skippable: "Not sure yet" moves on with no month.
            if (option == TtcTryingFor.planning &&
                _trying == TtcTryingFor.planning) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 10),
                child: Text('Which month do you want to start trying?',
                    style: ttcBody(14, w: FontWeight.w700)),
              ),
              for (final m in _monthChoices()) ...[
                _Choice(
                  label: readyMonthLabel(m),
                  selected: _plannedMonth != null &&
                      readyMonthsBetween(m, _plannedMonth!) == 0,
                  onTap: () {
                    setState(() => _plannedMonth = m);
                    _next();
                  },
                ),
                const SizedBox(height: 8),
              ],
              _Ghost(
                  label: 'Not sure yet',
                  onTap: () {
                    setState(() => _plannedMonth = null);
                    _next();
                  }),
              const SizedBox(height: 14),
            ],
          ],
          const SizedBox(height: 4),
          _Ghost(label: t.introRatherNotSay, onTap: _next),
        ],
      );

  // ===========================================================================
  //  5. Whether a clinic owns the timing
  // ---------------------------------------------------------------------------
  //  ⚠️ THE MOST CONSEQUENTIAL QUESTION IN THE FLOW, and the only reason it is
  //  asked this early. `TtcStore.setPath` sets `TimingOwnership`, which decides
  //  whether the app may generate a fertile window at all. A woman on IVF who
  //  is shown an ovulation estimate is being given a second opinion nobody
  //  asked for, against a clinician who outranks our calculation by six places
  //  in `truth_hierarchy.dart`.
  //
  //  Defaults to nothing rather than to `natural`. Not answering leaves the
  //  pathway untouched, which is what the store already does.
  // ===========================================================================
  // Unreachable since Onboarding V3; kept for revert (see `_steps`).
  // ignore: unused_element
  Widget _pathQuestion(TtcS t) => _Page(
        title: t.introPathTitle,
        body: t.introPathBody,
        children: [
          _Choice(
            label: TtcPath.natural.label(t.hinglish),
            selected: _path == TtcPath.natural,
            onTap: () {
              setState(() => _path = TtcPath.natural);
              _finish();
            },
          ),
          const SizedBox(height: 11),
          for (final option in const [
            TtcPath.ovulationInduction,
            TtcPath.iui,
            TtcPath.ivf,
          ]) ...[
            _Choice(
              label: option.label(t.hinglish),
              selected: _path == option,
              onTap: () {
                setState(() => _path = option);
                _finish();
              },
            ),
            const SizedBox(height: 11),
          ],
          const SizedBox(height: 4),
          _Ghost(label: t.introRatherNotSay, onTap: _finish),
        ],
      );

  static const _m = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  static String _fmt(DateTime d) => '${d.day} ${_m[d.month - 1]}';
}

// -----------------------------------------------------------------------------
//  Shapes
// -----------------------------------------------------------------------------

class _Page extends StatelessWidget {
  const _Page(
      {required this.title, required this.body, required this.children});

  final String title;
  final String body;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ListView(
        // ⚠️ `ttcBottomInset`, NOT A NUMBER. The Ask Veda FAB floats over every
        // route from `MaterialApp.builder`, including this one — it is in no
        // screen's layout, which is exactly why thirty screens once hardcoded a
        // clearance correct for the nav pill they did not have and wrong for
        // the FAB they did. Caught here by `ttc_fab_clearance_test.dart` before
        // it could hide the last answer on the pathway question.
        padding: const EdgeInsets.fromLTRB(
            ttcGutter, 24, ttcGutter, ttcBottomInset),
        children: [
          Text(title,
              style: ttcFraunces(27, w: FontWeight.w600, color: ttcTitleInk)),
          const SizedBox(height: 10),
          Text(body, style: ttcBody(14, color: ttcSoft, h: 1.6)),
          const SizedBox(height: 26),
          ...children,
        ],
      );
}

class _Choice extends StatelessWidget {
  const _Choice(
      {required this.label,
      required this.selected,
      required this.onTap,
      this.sub});

  final String label;
  final String? sub;
  final bool selected;
  final VoidCallback onTap;

  // The shared answer row (2026-10-10, one MCQ look app-wide): see
  // `PvChoiceTile` in lib/widgets/pv_feedback.dart.
  @override
  Widget build(BuildContext context) => PvChoiceTile(
      label: label, subtitle: sub, selected: selected, onTap: onTap);

  // Kept for revert (2026-10-10): the tinted-panel choice.
  // ignore: unused_element
  Widget _buildBefore(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          decoration: BoxDecoration(
            color: selected ? ttcPanel : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: selected ? ttcTitleInk : ttcLine,
                width: selected ? 1.6 : 1),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: pvManrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ttcTitleInk)),
                    if (sub != null) ...[
                      const SizedBox(height: 2),
                      Text(sub!, style: ttcBody(12, color: ttcMuted)),
                    ],
                  ]),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  size: 20, color: ttcTitleInk),
          ]),
        ),
      );
}

class _Primary extends StatelessWidget {
  const _Primary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ttcTitleInk,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      );
}

class _Ghost extends StatelessWidget {
  const _Ghost(
      {required this.label, required this.onTap, this.emphasised = false});

  final String label;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: emphasised ? ttcTitleInk : ttcLine),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: emphasised ? ttcTitleInk : ttcSoft)),
        ),
      );
}


// =============================================================================
//  The intro film, from anywhere (2026-10-20)
// =============================================================================

/// Opens "Trying to conceive, explained": the rail card, the welcome pop-up
/// and Learn's Videos row all come here, so it is one film in one place.
void openTtcIntroFilm(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: 'ttc/intro'),
    builder: (ctx) => TtcIntroFlow(onDone: () => Navigator.of(ctx).pop()),
  ));
}

/// ⚠️ CENTRED, NOT A SHEET (the user, 2026-10-20: "it should not be coming
/// from the bottom, it should be in the center"). Brink's welcome and Insight
/// Timer's modal are the references. While the film is not made, the still
/// is the honest "Coming soon" placeholder and the button reads "Read the
/// notes"; when the slot gets a file the placeholder plays, here, with no
/// other change. The footnote answers "where did it go?" before she asks.
Future<void> showTtcIntroFilmDialog(BuildContext context) {
  final t = TtcS.current();
  final slot = ttcIntroVideoSlotId(TtcLang.instance.hinglish);
  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x99000000),
    builder: (ctx) => Dialog(
      key: const ValueKey('ttc_intro_popup'),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PvVideoPlaceholder(
                  title: t.introVideoLabel,
                  overlayTitle: true,
                  duration: '2 MIN',
                  hue: 268,
                  slotId: slot,
                  still: pvFilmStillFor(slot),
                ),
              ),
              const SizedBox(height: 16),
              Text('Welcome. Start with this.',
                  style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: ttcTitleInk)),
              const SizedBox(height: 6),
              Text(t.introVideoBody,
                  style: ttcBody(14, color: ttcInk, h: 1.5)),
              const SizedBox(height: 18),
              KeyedSubtree(
                key: const ValueKey('ttc_intro_popup_watch'),
                child: _Primary(
                  label: 'Read the notes',
                  onTap: () {
                    Navigator.of(ctx).pop();
                    openTtcIntroFilm(context);
                  },
                ),
              ),
              TextButton(
                key: const ValueKey('ttc_intro_popup_skip'),
                onPressed: () => Navigator.of(ctx).pop(),
                style: TextButton.styleFrom(
                    foregroundColor: ttcTitleInk,
                    minimumSize: const Size(44, 48)),
                child: Text('Skip for now',
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: ttcTitleInk)),
              ),
              Text(
                  'It stays on your Today for a week, and always in Learn, '
                  'under Videos.',
                  textAlign: TextAlign.center,
                  style: ttcBody(12, color: ttcInk, h: 1.4)),
            ],
          ),
        ),
      ),
    ),
  );
}
