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
import '../../widgets/pv_placeholders.dart';
import '../../ttc/cycle_store.dart';
import '../../ttc/ttc_care_pathway.dart';
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
  }
}

/// How long she says she has been trying. Maps to a journey start.
enum TtcTryingFor { justStarted, upToSix, sixToTwelve, overAYear }

extension TtcTryingForCopy on TtcTryingFor {
  String label(bool hi) => switch (this) {
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
  TtcPath? _path;

  static const _steps = 5; // language · video · 3 questions

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
    if (trying != null) {
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
                  GestureDetector(
                    onTap: _skipAll,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Text(t.introSkip,
                          style: ttcBody(12.5,
                              color: ttcMuted, w: FontWeight.w700)),
                    ),
                  ),
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

  Widget _current(TtcS t) => switch (_step) {
        0 => _language(t),
        1 => _video(t),
        2 => _periodQuestion(t),
        3 => _tryingQuestion(t),
        _ => _pathQuestion(t),
      };

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
                _next();
              },
            ),
            const SizedBox(height: 11),
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

  @override
  Widget build(BuildContext context) => InkWell(
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
