// =============================================================================
//  Kegel Care
// -----------------------------------------------------------------------------
//  Pregnancy self-care & birth preparation - NOT a workout or gamified app.
//  No levels, XP, streaks or achievements. A pregnancy-aware adaptive routine
//  (3 stages by week), a guided hold/relax session, and a calm "Care Journey".
//  Per the product spec.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle). The page wears the
//  trying-to-conceive tool shape through `preg_chrome.dart`: the serif page
//  title under a bare back arrow, white cards with the hairline, the one ink
//  for every button, and the safety list in the warning form (an ink rule, the
//  serif heading, one coral dot a line; no tinted box). Care Journey moved
//  from the app bar into the page as a row with a drawn mark, because a row
//  that opens somewhere carries a mark and the app bar of a pushed tool page
//  carries only the way back.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_door_chrome.dart' show kPvUrgentInk;
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// The Tools tab's "Track" hue, so the marks here match the row she tapped.
const double _kKegelHue = 206;

typedef _Routine = ({
  String Function(S) stage,
  int hold,
  int relax,
  int reps,
  int minutes,
});

int _minutesFor(int hold, int relax, int reps) =>
    (((hold + relax) * reps) / 60).ceil();

/// The RECOMMENDED routine for the current week + adaptive offsets.
_Routine _recommendedFor(int week) {
  int baseHold;
  int baseReps;
  String Function(S) stage;
  if (week <= 16) {
    baseHold = 3;
    baseReps = 8;
    stage = (s) => s.kegelStage1;
  } else if (week <= 28) {
    baseHold = 5;
    baseReps = 10;
    stage = (s) => s.kegelStage2;
  } else {
    baseHold = 8;
    baseReps = 12;
    stage = (s) => s.kegelStage3;
  }
  final store = ToolsStore.instance;
  final hold = (baseHold + store.kegelHoldAdjust).clamp(3, 10);
  final reps = (baseReps + store.kegelRepAdjust).clamp(8, 15);
  final relax = hold;
  return (
    stage: stage,
    hold: hold,
    relax: relax,
    reps: reps,
    minutes: _minutesFor(hold, relax, reps),
  );
}

/// The EFFECTIVE routine that's actually used - the user's custom one if set,
/// otherwise the recommended one.
_Routine _routineFor(int week) {
  final rec = _recommendedFor(week);
  final store = ToolsStore.instance;
  if (store.hasCustomKegelRoutine) {
    final hold = store.kegelCustomHold!;
    final relax = store.kegelCustomRelax!;
    final reps = store.kegelCustomReps!;
    return (
      stage: rec.stage,
      hold: hold,
      relax: relax,
      reps: reps,
      minutes: _minutesFor(hold, relax, reps),
    );
  }
  return rec;
}

// ---- shared pieces (private: the stages stay code-isolated) -----------------

/// The page title on a pushed tool page (`pregPageTitleStyle`), announced as a
/// heading.
Widget _pageTitle(String text) =>
    Semantics(header: true, child: Text(text, style: pregPageTitleStyle()));

/// A card's own title: the serif, smaller than a section heading.
TextStyle _cardTitleStyle() => pvFraunces(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.3,
    color: pvStorePalette.ink1);

TextStyle _bodyStyle() =>
    pvManrope(fontSize: 13.5, height: 1.5, color: pvStorePalette.ink2);

/// An outlined stadium: a second action beside the ink one.
ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
      foregroundColor: kPvInk,
      side: const BorderSide(color: kPvLine, width: 1.5),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      textStyle: pvManrope(fontSize: 14, fontWeight: FontWeight.w700),
    );

/// A tag: a neutral pill with grey words (a tint is allowed on a tag).
Widget _tag(String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: pvStorePalette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: pvStorePalette.ink2)),
    );

class KegelCareScreen extends StatefulWidget {
  const KegelCareScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<KegelCareScreen> createState() => _KegelCareScreenState();
}

class _KegelCareScreenState extends State<KegelCareScreen> {
  final _store = ToolsStore.instance;
  bool _whyExpanded = false;
  // The old single "What is a Kegel & how to do it" collapsible was replaced by
  // three always-visible intro cards (see build). Field kept (commented) for a
  // quick revert to the collapsible version.
  // bool _howExpanded = true;

  @override
  void initState() {
    super.initState();
    _store.init();
  }

  S get _s => S(widget.controller.language);

  void _openCareJourney() => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _CareJourneyScreen(controller: widget.controller),
      ));

  @override
  Widget build(BuildContext context) {
    final s = _s;
    final p = pvStorePalette;
    // FRONT PAGE ON THE TOOL SHELL (2026-09-30, Tools audit). WH: she opens this
    // to DO her routine, so the routine and its Start button lead, straight under
    // the hero. The three explainer cards (what / why / how) used to come first
    // and made her read before she could begin; they now sit under a heading
    // below, for the visit when she wants them.
    // Kept for revert: Scaffold(appBar: AppBar(), body: ListView([_pageTitle(
    //   s.kegelToolTitle), _IntroCard x3, routine card, Care Journey row,
    //   _Expandable, _SafetyWarning])).
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final r = _routineFor(widget.controller.currentWeek);
        return PregToolScaffold(
          hue: _kKegelHue,
          eyebrow: 'Track',
          title: s.kegelToolTitle,
          mark: IntentMark.lotusMark,
          intro: 'A gentle pelvic floor routine for your stage of pregnancy. '
              'It is self-care, not treatment, and your doctor\'s advice comes first.',
          children: [
            pregToolPad(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current routine, with the Edit and the Start session button.
                _currentRoutineCard(context, s, r),
                const SizedBox(height: 14),
                // Care Journey (was the app bar's action): a row that opens
                // somewhere, so a drawn mark, a name and one line.
                PregRowCard(children: [
                  PregOfferRow(
                    key: const ValueKey('kegel_care_journey_row'),
                    mark: IntentMark.chartLog,
                    hue: _kKegelHue,
                    title: s.careJourneyCta,
                    line: 'Your stage, your sessions and how each one felt',
                    onTap: _openCareJourney,
                  ),
                ]),
                const SizedBox(height: 28),
                // INTRODUCTION - three small titled cards: What / Why / How.
                // NOTE (i18n): section titles + the "How" step copy are literal
                // English here; the bodies reuse existing bilingual strings
                // where they fit (kegelHowBody, whyAmIDoingThisBody).
                const PregSectionHeading('How a Kegel works'),
                const SizedBox(height: 12),
                _IntroCard(
                  title: S.now.uiWhatKegel,
                  body:
                      'A Kegel is a simple exercise that squeezes and lifts the '
                      'pelvic-floor muscles - the sling of muscles supporting your '
                      'bladder, bowel and uterus - and then fully relaxes them. '
                      'During pregnancy these muscles carry extra weight, so keeping '
                      'them working well matters.',
                ),
                const SizedBox(height: 12),
                _IntroCard(
                  title: S.now.uiWhyShouldIDo,
                  body: s.whyAmIDoingThisBody,
                ),
                const SizedBox(height: 12),
                _IntroCard(
                  title: S.now.uiHowDoKegel,
                  body: s.kegelHowBody,
                  // Rule 9 (no placeholder images): a quiet line. Kept for
                  // revert: footer: _videoPlaceholder(context, s),
                  footer: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: PregNote(S.now.uiAnimatedGuideComingSoon,
                        icon: Icons.play_circle_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                _Expandable(
                  title: s.whyAmIDoingThis,
                  expanded: _whyExpanded,
                  onToggle: () => setState(() => _whyExpanded = !_whyExpanded),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.kegelHeroBody, style: _bodyStyle()),
                        const SizedBox(height: 10),
                        _benefit(s.kegelBenefitBladder),
                        _benefit(s.kegelBenefitSupport),
                        _benefit(s.kegelBenefitRecovery),
                        const SizedBox(height: 8),
                        Text(s.kegelFollowProvider,
                            style: pvManrope(
                                fontSize: 12.5, height: 1.45, color: p.ink3)),
                      ]),
                ),
                const SizedBox(height: 28),
                // Safety - the warning form (DESIGN-SYSTEM §4.0 addendum): an ink
                // rule, the heading in the serif, one coral dot a line.
                _SafetyWarning(title: s.kegelSafetyTitle, lines: [
                  s.kegelSafetyPain,
                  s.kegelSafetyBleeding,
                  s.kegelSafetyDizziness,
                  s.kegelSafetyContractions,
                ]),
              ],
            )),
          ],
        );
      },
    );
  }

  // Tappable 16:9 placeholder for the animated instructional video (no asset
  // yet). Retired by rule 9 (no placeholder images); the page now shows the
  // same "coming soon" line as a PregNote. Kept for revert, as it stood:
  // Widget _videoPlaceholder(BuildContext context, S s) => Padding(
  //   padding: const EdgeInsets.only(top: 12),
  //   child: GestureDetector(
  //     onTap: () => ScaffoldMessenger.of(context)..clearSnackBars()
  //       ..showSnackBar(SnackBar(content: Text(S.now.uiAnimatedGuideComingSoon))),
  //     child: AspectRatio(aspectRatio: 16 / 9, child: Container(
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(colors: [
  //           AppTheme.secondary500.withValues(alpha: 0.16),
  //           AppTheme.secondary500.withValues(alpha: 0.05)]),
  //         borderRadius: BorderRadius.circular(18)),
  //       child: Stack(children: [
  //         Center(child: <white 54 disc, play_arrow_rounded in secondary600>),
  //         Positioned(left: 10, bottom: 10,
  //             child: <pill: S.now.uiAnimatedGuideComingSoon>),
  //       ]))),
  //   ));

  // The benefit bullets were a ❤️ emoji each; no decorative emoji, so a small
  // line glyph.
  Widget _benefit(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 8),
            child: Icon(Icons.check_rounded, size: 16, color: pvStorePalette.ink2),
          ),
          Expanded(
              child: Text(label,
                  style: pvManrope(
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: pvStorePalette.ink1))),
        ]),
      );

  Widget _routineRow(String label, String value) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(label,
                    style: pvManrope(fontSize: 13.5, color: p.ink2))),
            const SizedBox(width: 8),
            Text(value,
                style: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
          ]),
    );
  }

  /// The "Current routine" card: shows the effective routine, an info (i) that
  /// explains the recommendation, and a Customize button (with Reset when a
  /// custom routine is active).
  Widget _currentRoutineCard(BuildContext context, S s, _Routine r) {
    final p = pvStorePalette;
    final rec = _recommendedFor(widget.controller.currentWeek);
    final isCustom = _store.hasCustomKegelRoutine;
    return PregCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 10, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(
                  child: Text(s.currentRoutineLabel, style: _cardTitleStyle()),
                ),
                if (isCustom) ...[
                  const SizedBox(width: 8),
                  // Kept for revert: a coral pill (secondary50 / secondary600).
                  _tag(s.customLabel.toUpperCase()),
                ],
              ]),
              const SizedBox(height: 6),
              // Replaces the old stage line ("Building consistency"). Tapping
              // this ℹ️ opens the "Why this routine?" explanation.
              InkWell(
                onTap: () => _showWhyThisRoutine(context, s),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: p.ink2),
                    const SizedBox(width: 5),
                    Flexible(child: Text(s.whyThisRoutine,
                        style: pvManrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink1))),
                  ]),
                ),
              ),
            ]),
          ),
          // Edit (✏️) - opens the Customize sheet (moved here from the old
          // bottom "Customize" button; Reset-to-recommended lives in the sheet).
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: s.customizeLabel,
            onPressed: () => _showCustomize(context, s, rec),
            icon: Icon(Icons.edit_outlined, size: 20, color: p.ink1),
          ),
        ]),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Column(children: [
            _routineRow(s.holdLabel, '${r.hold} ${s.secShort}'),
            _routineRow(s.relaxLabel, '${r.relax} ${s.secShort}'),
            _routineRow(s.repsLabel, '${r.reps}'),
            _routineRow(s.estTimeLabel, s.minutesShort(r.minutes)),
          ]),
        ),
        if (isCustom) ...[
          const SizedBox(height: 6),
          Text(
            '${s.recommendedLabel}: ${rec.hold} ${s.secShort} · '
            '${rec.relax} ${s.secShort} · ${rec.reps} '
            '${s.repsLabel.toLowerCase()}',
            style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3),
          ),
        ],
        const SizedBox(height: 16),
        // Start session - replaces the old "Customize" button (the standalone
        // Start Care Session button was removed; Customize is now the ✏️ above).
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: pregFilledStyle().copyWith(
                minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
              ),
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => _SessionScreen(
                  controller: widget.controller,
                  hold: r.hold,
                  relax: r.relax,
                  reps: r.reps,
                ),
              )),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(s.startCareSession,
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800)),
            ),
          ),
        ),
      ]),
    );
  }

  /// Opens the "Why this routine?" explanation (from the ℹ️ in the card).
  Future<void> _showWhyThisRoutine(BuildContext context, S s) {
    final p = pvStorePalette;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(s.whyThisRoutine,
            style: pvFraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        content: Text(s.whyThisRoutineBody,
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.gotIt,
                  style: pvManrope(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: p.ink1))),
        ],
      ),
    );
  }

  // Old recommended-routine info popup - no longer used (the ℹ️ now shows "Why
  // this routine?"); kept for revert.
  // ignore: unused_element
  Future<void> _showRecommendInfo(BuildContext context, S s, _Routine rec) {
    final text = Theme.of(context).textTheme;
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.recommendedLabel),
        content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${rec.hold} ${s.secShort} · ${rec.relax} ${s.secShort} · '
                '${rec.reps} ${s.repsLabel.toLowerCase()}',
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(s.kegelCustomizeInfo, style: text.bodyMedium),
            ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(), child: Text(s.gotIt)),
        ],
      ),
    );
  }

  Future<void> _showCustomize(BuildContext context, S s, _Routine rec) async {
    int hold = _store.kegelCustomHold ?? rec.hold;
    int relax = _store.kegelCustomRelax ?? rec.relax;
    int reps = _store.kegelCustomReps ?? rec.reps;
    final p = pvStorePalette;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheet) {
          final minutes = _minutesFor(hold, relax, reps);
          return Padding(
            padding: EdgeInsets.fromLTRB(
                22, 4, 22, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.customizeRoutineTitle,
                      style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.4,
                          color: p.ink1)),
                  const SizedBox(height: 6),
                  Text(s.kegelCustomizeInfo,
                      style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                  const SizedBox(height: 12),
                  _stepper(s.holdLabel, '${s.recommendedLabel}: ${rec.hold}',
                      '$hold ${s.secShort}',
                      () => setSheet(() => hold = (hold - 1).clamp(2, 15)),
                      () => setSheet(() => hold = (hold + 1).clamp(2, 15))),
                  _stepper(
                      s.relaxLabel,
                      '${s.recommendedLabel}: ${rec.relax}',
                      '$relax ${s.secShort}',
                      () => setSheet(() => relax = (relax - 1).clamp(2, 15)),
                      () => setSheet(() => relax = (relax + 1).clamp(2, 15))),
                  _stepper(s.repsLabel, '${s.recommendedLabel}: ${rec.reps}',
                      '$reps',
                      () => setSheet(() => reps = (reps - 1).clamp(5, 25)),
                      () => setSheet(() => reps = (reps + 1).clamp(5, 25))),
                  const SizedBox(height: 10),
                  // Kept for revert: this row sat on a grey block
                  // (AppTheme.surfaceContainer, radius 14). A hairline above it
                  // now, no tint behind the words.
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: kPvLine))),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s.estTimeLabel,
                              style: pvManrope(fontSize: 13.5, color: p.ink2)),
                          Text(s.minutesShort(minutes),
                              style: pvManrope(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                  color: p.ink1)),
                        ]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: pregFilledStyle().copyWith(
                        minimumSize:
                            const WidgetStatePropertyAll(Size.fromHeight(50)),
                      ),
                      onPressed: () {
                        _store.setKegelCustomRoutine(
                            hold: hold, relax: relax, reps: reps);
                        Navigator.of(ctx).pop();
                      },
                      child: Text(s.saveCta,
                          style: pvManrope(
                              fontSize: 14.5, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(foregroundColor: p.ink2),
                      onPressed: () {
                        _store.clearKegelCustomRoutine();
                        Navigator.of(ctx).pop();
                      },
                      child: Text(s.resetToRecommended,
                          style: pvManrope(
                              fontSize: 13.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
          );
        });
      },
    );
  }

  Widget _stepper(String label, String sub, String value,
      VoidCallback onMinus, VoidCallback onPlus) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: pvManrope(
                    fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
            Text(sub, style: pvManrope(fontSize: 11.5, color: p.ink3)),
          ]),
        ),
        _roundBtn(Icons.remove_rounded, onMinus),
        SizedBox(
          width: 64,
          child: Text(value,
              textAlign: TextAlign.center,
              style: pvManrope(
                  fontSize: 16, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
        _roundBtn(Icons.add_rounded, onPlus),
      ]),
    );
  }

  // Kept for revert: a coral disc (secondary50) with a secondary600 glyph.
  // Pressable, so white with the hairline and the ink.
  Widget _roundBtn(IconData icon, VoidCallback onTap) => Material(
        color: Colors.white,
        shape: const CircleBorder(side: BorderSide(color: kPvLine, width: 1.5)),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20, color: kPvInk),
          ),
        ),
      );
}

/// A small, always-visible titled intro block/card (used for the three split
/// Introduction sub-sections: What / Why / How). Optional [footer] hosts extra
/// content such as the "animated guide" note under "How to do Kegel?".
class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.title, required this.body, this.footer});
  final String title;
  final String body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PregCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: _cardTitleStyle()),
          const SizedBox(height: 8),
          Text(body, style: _bodyStyle()),
          ?footer,
        ]),
      ),
    );
  }
}

class _Expandable extends StatelessWidget {
  const _Expandable({
    required this.title,
    // `body` (a plain-text body) is no longer passed by any caller since the
    // top intro moved to the always-visible _IntroCard blocks. Kept commented
    // for a quick revert to a text-only collapsible.
    // this.body,
    this.child,
    required this.expanded,
    required this.onToggle,
  });
  final String title;
  // final String? body; // simple text body
  final Widget? child; // OR a rich body (e.g. the pelvic-floor intro)
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregCard(
      padding: EdgeInsets.zero,
      child: Column(children: [
        Semantics(
          button: true,
          expanded: expanded,
          child: InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
              child: Row(children: [
                Expanded(child: Text(title, style: _cardTitleStyle())),
                Icon(
                    expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: p.ink2),
              ]),
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
      ]),
    );
  }
}

/// The safety list in the warning form: an ink rule (1.5), the heading in the
/// serif, the lines as a list with one coral dot each, a hairline under. The
/// dot is the only colour and it is the signal (DESIGN-SYSTEM §4.0 addendum).
class _SafetyWarning extends StatelessWidget {
  const _SafetyWarning({required this.title, required this.lines});
  final String title;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: 1.5, color: p.ink1),
      const SizedBox(height: 14),
      Semantics(
          header: true, child: Text(title, style: pregSectionHeadingStyle())),
      const SizedBox(height: 10),
      for (final line in lines)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 11),
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: kPvUrgentInk, shape: BoxShape.circle),
              ),
            ),
            Expanded(
                child: Text(line,
                    style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1))),
          ]),
        ),
      const SizedBox(height: 12),
      Container(height: 1, color: kPvLine),
    ]);
  }
}

// ---------------------------------------------------------------------------
//  Guided session (hold / relax countdown across reps)
// ---------------------------------------------------------------------------

class _SessionScreen extends StatefulWidget {
  const _SessionScreen({
    required this.controller,
    required this.hold,
    required this.relax,
    required this.reps,
  });
  final PregnancyController controller;
  final int hold;
  final int relax;
  final int reps;

  @override
  State<_SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<_SessionScreen>
    with SingleTickerProviderStateMixin {
  S get _s => S(widget.controller.language);

  late final AnimationController _ctrl;
  final FlutterTts _tts = FlutterTts();
  bool _holding = true; // hold phase vs relax
  int _rep = 1;
  // Number of FULLY completed repetitions (a whole hold+relax cycle). Drives the
  // history save rule below - a session is only recorded if this reaches 3+.
  int _completedReps = 0;
  bool _done = false;
  bool _sound = true;

  int get _phaseSeconds => _holding ? widget.hold : widget.relax;
  int get _remaining =>
      (_phaseSeconds * (1 - _ctrl.value)).ceil().clamp(0, _phaseSeconds);
  bool get _paused => !_ctrl.isAnimating && !_done;

  @override
  void initState() {
    super.initState();
    _sound = ToolsStore.instance.kegelVoiceOn;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.hold),
    )..addStatusListener(_onStatus);
    _initTts();
    _startPhase(); // begin the first hold
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _tts.stop();
    super.dispose();
  }

  /// A normal-pitch voice (deliberately NOT the baby voice) for hold/relax cues.
  Future<void> _initTts() async {
    try {
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      // Follow the reading language, with an English fallback if the
      // device has no Hindi voice pack - the same shape the
      // contraction timer already uses. Hardcoding en-IN meant a
      // screen that is entirely Devanagari still counted her
      // through the exercise in English.
      try {
        await _tts.setLanguage(
            widget.controller.language.isHindi ? 'hi-IN' : 'en-IN');
      } catch (_) {
        await _tts.setLanguage('en-IN');
      }
    } catch (_) {/* audio is an enhancement, never fatal */}
  }

  Future<void> _speak(String word) async {
    if (!_sound) return;
    try {
      await _tts.stop();
      await _tts.speak(word);
    } catch (_) {}
  }

  void _startPhase() {
    _ctrl.duration = Duration(seconds: _phaseSeconds);
    _ctrl.forward(from: 0);
    HapticFeedback.lightImpact();
    _speak(_holding ? _s.holdLabel : _s.relaxLabel);
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;
    if (_holding) {
      setState(() => _holding = false);
      _startPhase();
      return;
    }
    // The relax phase just ended -> one full hold+relax repetition is complete.
    _completedReps++;
    if (_rep >= widget.reps) {
      _finish();
    } else {
      setState(() {
        _rep++;
        _holding = true;
      });
      _startPhase();
    }
  }

  void _finish() {
    _ctrl.stop();
    _speak('Well done');
    setState(() => _done = true);
  }

  void _togglePause() {
    if (_ctrl.isAnimating) {
      _ctrl.stop();
    } else {
      _ctrl.forward(); // resume from where it paused
    }
    setState(() {});
  }

  void _toggleSound() {
    setState(() => _sound = !_sound);
    ToolsStore.instance.setKegelVoice(_sound);
    if (!_sound) _tts.stop();
  }

  Future<void> _saveFeedback(String feedback) async {
    // HISTORY SAVE RULE: only persist a session to Care Journey history if the
    // user actually completed at least 3 repetitions (full hold+relax cycles).
    // Shorter attempts are discarded silently so history stays meaningful.
    const kMinRepsToSave = 3;
    if (_completedReps < kMinRepsToSave) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    await ToolsStore.instance.recordKegelSession(
      holdSeconds: widget.hold,
      relaxSeconds: widget.relax,
      repetitions: _completedReps, // record actual completed reps, not planned
      feedback: feedback,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final p = pvStorePalette;
    // Kept for revert: hold drew in coral (AppTheme.secondary500), relax in
    // neutral500. The ink holds, the grey rests.
    final color = _holding ? kPvInk : p.ink3;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.kegelToolTitle),
        // One ParentVeda, rule 7: this page is pushed from Kegel Care, so its
        // way out is the back arrow (the default). Exit below still leaves.
        // Kept for revert:
        // leading: IconButton(
        //   icon: const Icon(Icons.close_rounded),
        //   onPressed: () => Navigator.of(context).pop(),
        // ),
        actions: [
          IconButton(
            tooltip: s.voiceCuesLabel,
            onPressed: _toggleSound,
            icon: Icon(
                _sound ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: _done
            ? _completion(context, s)
            : Padding(
                padding: const EdgeInsets.all(24),
                child: Column(children: [
                  const Spacer(),
                  // Animated ring that depletes over the phase + a gentle
                  // inflate-while-holding / settle-while-relaxing pulse.
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (context, _) {
                      final frac = (1 - _ctrl.value).clamp(0.0, 1.0);
                      final scale = _holding
                          ? 1 + 0.05 * _ctrl.value
                          : 1.05 - 0.05 * _ctrl.value;
                      return SizedBox(
                        width: 250,
                        height: 250,
                        child: CustomPaint(
                          painter: _RingPainter(progress: frac, color: color),
                          child: Center(
                            child: Transform.scale(
                              scale: scale,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_holding ? s.holdLabel : s.relaxLabel,
                                      style: pvFraunces(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: color)),
                                  const SizedBox(height: 4),
                                  Text('$_remaining',
                                      style: pvManrope(
                                          fontSize: 60,
                                          height: 1.1,
                                          fontWeight: FontWeight.w800,
                                          color: p.ink1)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(s.repOf(_rep, widget.reps),
                      style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: p.ink2)),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        style: _outlinedStyle(),
                        onPressed: _togglePause,
                        icon: Icon(_paused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded),
                        label: Text(_paused ? s.resumeLabel : s.pauseLabel),
                      ),
                      OutlinedButton.icon(
                        style: _outlinedStyle(),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        label: Text(s.exitLabel),
                      ),
                    ],
                  ),
                ]),
              ),
      ),
    );
  }

  Widget _completion(BuildContext context, S s) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const Spacer(),
        // Kept for revert: const Text('❤️', style: TextStyle(fontSize: 64)).
        // No decorative emoji; the drawn mark in the tool's tint.
        PvMarkWell(p: p, hue: _kKegelHue, size: 88, mark: IntentMark.cuppedHands),
        const SizedBox(height: 18),
        Text(s.kegelSessionDoneTitle,
            textAlign: TextAlign.center, style: pregPageTitleStyle()),
        const SizedBox(height: 12),
        Text(s.kegelSessionDoneBody,
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 14.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 28),
        Text(s.howDidItFeel,
            style: pvManrope(
                fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
        const SizedBox(height: 14),
        // Kept for revert: each label led with an emoji (😊 / 🙂 / 😓).
        _feedbackButton(s.feedbackEasy, 'easy'),
        const SizedBox(height: 10),
        _feedbackButton(s.feedbackComfortable, 'comfortable'),
        const SizedBox(height: 10),
        _feedbackButton(s.feedbackDifficult, 'difficult'),
        const Spacer(),
      ]),
    );
  }

  Widget _feedbackButton(String label, String value) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: _outlinedStyle(),
        onPressed: () => _saveFeedback(value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Care Journey (replaces a "levels" screen) + history
// ---------------------------------------------------------------------------

class _CareJourneyScreen extends StatelessWidget {
  const _CareJourneyScreen({required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final p = pvStorePalette;
    return Scaffold(
      // Kept for revert: appBar: AppBar(title: Text(s.careJourneyCta)), with
      // the body opening on Text(s.careJourneyTitle, headlineMedium). The two
      // said the same thing; one serif title now, the name she tapped.
      appBar: AppBar(),
      body: AnimatedBuilder(
        animation: ToolsStore.instance,
        builder: (context, _) {
          final store = ToolsStore.instance;
          final r = _routineFor(controller.currentWeek);
          final last = store.kegelLast != null
              ? DateTime.tryParse(store.kegelLast!)
              : null;
          final stats = <(String, String)>[
            (s.stageLabel, r.stage(s)),
            (
              s.currentRoutineLabel,
              '${r.hold} ${s.secShort} · ${r.relax} ${s.secShort} · ${r.reps} ${s.repsLabel.toLowerCase()}'
            ),
            (s.sessionsCompletedLabel, '${store.kegelSessions}'),
            (s.completedThisWeekLabel, '${store.kegelCompletedThisWeek}'),
            (
              s.lastCompletedLabel,
              last != null ? s.formatLongDate(last) : s.neverWord
            ),
          ];
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
            children: [
              _pageTitle(s.careJourneyCta),
              const SizedBox(height: 18),
              // Kept for revert: five separate outlined cards, one per stat.
              // One white card with hairlines between the rows now.
              PregCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(children: [
                  for (var i = 0; i < stats.length; i++) ...[
                    if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine),
                    _stat(stats[i].$1, stats[i].$2),
                  ],
                ]),
              ),
              const SizedBox(height: 28),
              // History always renders its heading, even before the first
              // session - otherwise a new user never learns sessions are kept.
              PregSectionHeading(s.historyLabel),
              const SizedBox(height: 12),
              if (store.kegelHistory.isEmpty)
                Text(s.historyEmptyNote,
                    style: pvManrope(fontSize: 13, height: 1.45, color: p.ink3))
              else
                PregCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Column(children: [
                    for (var i = 0; i < store.kegelHistory.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, thickness: 1, color: kPvLine),
                      _historyRow(store.kegelHistory[i], s),
                    ],
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _stat(String label, String value) {
    final p = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
                child: Text(label, style: pvManrope(fontSize: 13.5, color: p.ink2))),
            const SizedBox(width: 12),
            Flexible(
              child: Text(value,
                  textAlign: TextAlign.right,
                  style: pvManrope(
                      fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
            ),
          ]),
    );
  }

  Widget _historyRow(KegelRecord rec, S s) {
    final p = pvStorePalette;
    final d = DateTime.tryParse(rec.dateIso);
    final fb = switch (rec.feedback) {
      'easy' => s.feedbackEasy,
      'difficult' => s.feedbackDifficult,
      _ => s.feedbackComfortable,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(d != null ? s.formatShortDate(d) : rec.dateIso,
                style: pvManrope(
                    fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
            const SizedBox(height: 2),
            Text(
                '${rec.holdSeconds}${s.secShort} · ${rec.repetitions} ${s.repsLabel.toLowerCase()}',
                style: pvManrope(fontSize: 12.5, color: p.ink3)),
          ]),
        ),
        const SizedBox(width: 10),
        _tag(fb),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Session ring - a soft disc with a depleting arc for the current phase.
// ---------------------------------------------------------------------------

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.color});

  /// 1.0 = phase just started (full ring), 0.0 = phase complete (empty).
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 8;

    // Soft inner disc behind the text.
    canvas.drawCircle(
        center, radius - 6, Paint()..color = color.withValues(alpha: 0.06));

    // Track + depleting arc.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = color.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, track);

    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progress.clamp(0.0, 1.0) * 2 * math.pi,
      false,
      arc,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
