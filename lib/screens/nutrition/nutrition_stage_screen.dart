// =============================================================================
//  Food for my stage — by trimester, by condition — and the Expert options
//  block
// -----------------------------------------------------------------------------
//  Two tabs over the same shape: a stage or a condition, a video, plain
//  guidance, and (for conditions and T3 only) the one paid surface in all of
//  Nutrition.
//
//  ⚠️ WHERE `ExpertOptionsBlock` IS ALLOWED, PER THE BRIEF: condition pages,
//  the T3 trimester page, and after a dietician explainer video — and
//  NOWHERE ELSE. In particular never on `FoodVerdictScreen`. It is exported
//  from here (rather than living privately) so `nutrients_screen.dart` can
//  reuse it after its own "do I need supplements?" explainer video, which is
//  the third of those three placements.
//
//  Booking itself is a placeholder: `lib/booking/` is a real entitlement
//  engine, and wiring Nutrition into it is a follow-up integration, not
//  something to improvise inside a one-pass content build. `_requestExpert`
//  is the clearly-named stub the integrator swaps for a real booking call.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/conditions_data.dart' show kAllConditions;
import '../../data/nutrition_data.dart';
import '../../data/report_findings_data.dart' show kReportFindings;
import '../../services/pregnancy_controller.dart';
import '../conditions/condition_detail_screen.dart' as pages;
import '../report_screen.dart' show ReportArticleScreen;
import '../../localization/app_language.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_placeholders.dart';
import '../v2/v2_palette.dart';

class NutritionStageScreen extends StatefulWidget {
  const NutritionStageScreen(
      {super.key, this.initialTab = 0, required this.pregnancy});

  /// ⚠️ REQUIRED, AND IT ARRIVED WITH THE COMPLICATIONS LINK. The diet pages
  /// under this one now open the condition page behind them, and both
  /// destinations need a controller. Passing it down beats each leaf screen
  /// reaching for a global — the same reason `PvReaderScreen` takes `lang`
  /// rather than reading one.
  final PregnancyController pregnancy;

  /// ⚠️ WHICH TAB TO LAND ON, AND IT EXISTS FOR ONE REAL CALLER.
  ///
  /// The hub has two nutrition doors: "What should I eat?" and "Something has
  /// been flagged". They were opening the SAME screen, so a mother who tapped
  /// the second one — because a number came up at an appointment — landed on
  /// generic everyday nutrition and had to find the condition tab herself.
  /// Two doors that lead to the same place teach her that the labels do not
  /// mean anything, which is worse than one door.
  ///
  /// Defaulting to 0 means every existing caller is unchanged; only the door
  /// that is ABOUT a condition passes 1.
  final int initialTab;

  @override
  State<NutritionStageScreen> createState() => _NutritionStageScreenState();
}

class _NutritionStageScreenState extends State<NutritionStageScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab =
      TabController(length: 2, vsync: this, initialIndex: widget.initialTab);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text('Food for my stage',
                style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
            bottom: TabBar(
              controller: _tab,
              labelColor: p.action,
              unselectedLabelColor: p.ink3,
              indicatorColor: p.action,
              labelStyle: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800),
              unselectedLabelStyle: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700),
              tabs: const [Tab(text: 'By trimester'), Tab(text: 'By condition')],
            ),
          ),
          body: TabBarView(controller: _tab, children: [
            _TrimesterList(p: p),
            _ConditionList(p: p, pregnancy: widget.pregnancy),
          ]),
        );
      },
    );
  }
}

class _TrimesterList extends StatelessWidget {
  const _TrimesterList({required this.p});
  final V2Palette p;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          for (final g in kTrimesterGuides) ...[
            _RowCard(
              p: p,
              title: g.label.now,
              subtitle: g.focus.now,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => StageDetailScreen(guide: g),
              )),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _ConditionList extends StatelessWidget {
  const _ConditionList({required this.p, required this.pregnancy});

  final PregnancyController pregnancy;
  final V2Palette p;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
        children: [
          for (final g in kConditionGuides) ...[
            _RowCard(
              p: p,
              title: g.label.now,
              subtitle: g.summary.now,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ConditionDetailScreen(
                        guide: g, pregnancy: pregnancy),
              )),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _RowCard extends StatelessWidget {
  const _RowCard({required this.p, required this.title, required this.subtitle, required this.onTap});
  final V2Palette p;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: pvFraunces(fontSize: 16, fontWeight: FontWeight.w600, color: p.ink1)),
                const SizedBox(height: 4),
                Text(subtitle,
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink2)),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Trimester detail
// ===========================================================================

class StageDetailScreen extends StatelessWidget {
  const StageDetailScreen({super.key, required this.guide});
  final TrimesterGuide guide;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final isT3 = guide.id == 't3';
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(guide.label.now, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                PvVideoPlaceholder(title: guide.videoTitle, subtitle: 'A dietician walks through this stage.', hue: 26),
                const SizedBox(height: 20),
                Text(guide.focus.now, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
                const SizedBox(height: 22),
                _SectionTitle(p: p, title: 'What helps'),
                const SizedBox(height: 10),
                for (final h in guide.helps) _Bullet(p: p, text: h.now),
                const SizedBox(height: 22),
                _SectionTitle(p: p, title: 'Foods to lean on'),
                const SizedBox(height: 10),
                for (final l in guide.leanOn) _Bullet(p: p, text: l.now),
                const SizedBox(height: 22),
                _SectionTitle(p: p, title: 'A sample day'),
                const SizedBox(height: 10),
                _SampleDay(p: p, sampleDay: guide.sampleDay),
                if (isT3) ...[
                  const SizedBox(height: 26),
                  const ExpertOptionsBlock(),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SampleDay extends StatelessWidget {
  const _SampleDay({required this.p, required this.sampleDay});
  final V2Palette p;
  final List<({LocalizedText meal, LocalizedText items})> sampleDay;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: p.line)),
      child: Column(children: [
        for (final row in sampleDay) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
                width: 84,
                child: Text(row.meal.now, style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink3)),
              ),
              Expanded(child: Text(row.items.now, style: pvManrope(fontSize: 13.5, height: 1.4, color: p.ink1))),
            ]),
          ),
          if (row != sampleDay.last) Divider(height: 1, color: p.line),
        ],
      ]),
    );
  }
}

// ===========================================================================
//  Condition detail
// ===========================================================================

class ConditionDetailScreen extends StatelessWidget {
  const ConditionDetailScreen(
      {super.key, required this.guide, required this.pregnancy});
  final ConditionGuide guide;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        return Scaffold(
          backgroundColor: p.ground,
          appBar: AppBar(
            backgroundColor: p.ground,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            title: Text(guide.label.now, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w600, color: p.ink1)),
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
              children: [
                PvVideoPlaceholder(title: guide.videoTitle, subtitle: 'Explained plainly by our dietician.', hue: 206),
                const SizedBox(height: 20),
                Text(guide.summary.now, style: pvManrope(fontSize: 14.5, height: 1.55, color: p.ink1)),
                const SizedBox(height: 20),
                for (final line in guide.guidance) ...[
                  _Bullet(p: p, text: line.now),
                  const SizedBox(height: 4),
                ],
                const SizedBox(height: 24),
                const ExpertOptionsBlock(),
                const SizedBox(height: 20),
                _ComplicationsLink(guide: guide, pregnancy: pregnancy),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A pointer across to the page that explains the condition itself.
///
/// ⚠️ IT WAS A DEAD "COMING SOON" AND COMPLICATIONS HAS SHIPPED — 2026-09-10.
///
/// The note this replaces read *"More on this, and related warning signs,
/// lives in Complications, coming soon"* and was deliberately not tappable,
/// because when it was written there was no Complications screen. There is
/// now: twenty-seven condition pages behind a built door.
///
/// ⚠️ THE INVERSE OF THIS REPO'S USUAL FAILURE, AND WORTH NAMING. The wiring
/// gate exists to catch a card pointing at nothing. This was a real
/// destination sitting behind a card that said it did not exist yet — and that
/// version of the bug is harder to find, because nothing is broken. It renders,
/// it is honest about itself, and it stays wrong until somebody remembers.
///
/// The general lesson: a coming-soon marker is a claim with an expiry date, and
/// nothing expires it. When a thing ships, grep for what promised it.
///
/// ⚠️ AND IT STILL DEGRADES HONESTLY. Four guides are diet-only — healthy
/// weight gain, underweight, brain foods, overweight — and have no condition
/// page at all. Those render nothing rather than a link to a page that would
/// have to be invented.
class _ComplicationsLink extends StatelessWidget {
  const _ComplicationsLink({required this.guide, required this.pregnancy});

  final ConditionGuide guide;
  final PregnancyController pregnancy;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final id = guide.linkId;
    if (id == null) return const SizedBox.shrink();

    return Material(
      color: p.surfaceAlt,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => openConditionFromDiet(context, guide, pregnancy),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          child: Row(children: [
            Icon(Icons.medical_information_outlined, size: 18, color: p.ink3),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  'This page is about what to eat. For the condition itself — '
                  'what it is, what happens next and when to call — read '
                  '${guide.label.now}.',
                  style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3)),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// Opens the page that explains the condition behind a diet guide.
///
/// ⚠️ IT IMPORTS THE DESTINATIONS DIRECTLY, AND THE ALTERNATIVE WAS WORSE.
///
/// The first version registered a callback from `pv_door_router.dart` at
/// startup, to keep this file free of the conditions and report screens. That
/// is a service locator, and its failure mode is the one this repo keeps
/// hitting: forget the registration and the link renders, taps, and does
/// nothing — silently, forever.
///
/// A direct import is a real dependency that the compiler checks, and this page
/// is reached from two places (the door and the old nutrition home), both of
/// which then get a working link without either remembering to wire it.
///
/// ⚠️ `as pages`, BECAUSE `ConditionDetailScreen` IS DEFINED IN THIS FILE TOO.
/// One name, two real screens: this one is the DIET page, the imported one is
/// the condition itself. See `docs/PREGNANCY-DOOR-BUILD.md` §4a.
void openConditionFromDiet(BuildContext context, ConditionGuide guide,
    PregnancyController controller) {
  final id = guide.linkId;
  if (id == null) return;

  switch (guide.linkLibrary) {
    case ConditionLink.complication:
      for (final e in kAllConditions) {
        if (e.id != id) continue;
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'conditions/$id'),
          builder: (_) =>
              pages.ConditionDetailScreen(entry: e, pregnancy: controller),
        ));
        return;
      }
    case ConditionLink.finding:
      for (final f in kReportFindings) {
        if (f.id != id) continue;
        Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'report/$id'),
          builder: (_) =>
              ReportArticleScreen(finding: f, controller: controller),
        ));
        return;
      }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.p, required this.title});
  final V2Palette p;
  final String title;
  @override
  Widget build(BuildContext context) =>
      Text(title, style: pvFraunces(fontSize: 17, fontWeight: FontWeight.w600, color: p.ink1));
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.p, required this.text});
  final V2Palette p;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Container(width: 5, height: 5, decoration: BoxDecoration(color: p.ink3, shape: BoxShape.circle)),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1))),
      ]),
    );
  }
}

// ===========================================================================
//  Expert options — the one paid surface in Nutrition
// ===========================================================================

class _ExpertOption {
  const _ExpertOption({required this.title, required this.forWhom, required this.icon});
  final String title;
  final String forWhom;
  final IconData icon;
}

const List<_ExpertOption> _kExpertOptions = [
  _ExpertOption(
    title: 'Personal diet plan',
    forWhom: 'For when you want a plan built around your own reports and routine.',
    icon: Icons.assignment_outlined,
  ),
  _ExpertOption(
    title: 'Weekly expert calls',
    forWhom: 'For steady check-ins as your needs change through pregnancy.',
    icon: Icons.call_outlined,
  ),
  _ExpertOption(
    title: 'Daily diet management',
    forWhom: 'For hands-on help, day to day, if a condition needs close watching.',
    icon: Icons.event_repeat_rounded,
  ),
  _ExpertOption(
    title: 'Book a consultation',
    forWhom: 'For a single session to get your specific questions answered.',
    icon: Icons.calendar_month_outlined,
  ),
];

/// The reusable Expert options block. See this file's header for exactly
/// where it is, and is not, allowed to appear.
class ExpertOptionsBlock extends StatelessWidget {
  const ExpertOptionsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Want a real person on this?',
            style: pvFraunces(fontSize: 16.5, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 4),
        Text('Everything above is free. This is the one part that is not: our dieticians, on call.',
            style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3)),
        const SizedBox(height: 14),
        for (final o in _kExpertOptions) ...[
          _ExpertOptionRow(p: p, option: o),
          if (o != _kExpertOptions.last) const SizedBox(height: 8),
        ],
      ]),
    );
  }
}

class _ExpertOptionRow extends StatelessWidget {
  const _ExpertOptionRow({required this.p, required this.option});
  final V2Palette p;
  final _ExpertOption option;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => _openBookingSheet(context, p, option),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
          child: Row(children: [
            Icon(option.icon, size: 19, color: p.action),
            const SizedBox(width: 11),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(option.title, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
                const SizedBox(height: 2),
                Text(option.forWhom, style: pvManrope(fontSize: 11.5, height: 1.35, color: p.ink3)),
              ]),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// Tap one: see the option and confirm. Tap two: request it. Two taps end to
/// end, exactly what the brief asks for — real dates and seat handling belong
/// to `lib/booking/`, which this is not wired into yet.
void _openBookingSheet(BuildContext context, V2Palette p, _ExpertOption option) {
  showModalBottomSheet(
    context: context,
    backgroundColor: p.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(option.title, style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
        const SizedBox(height: 8),
        Text(option.forWhom, style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: p.action, padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () {
              Navigator.of(sheetContext).pop();
              requestExpertOptionPlaceholder(option.title);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Request sent for "${option.title}". Our team will reach out to schedule it.'),
              ));
            },
            child: Text('Request this',
                style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    ),
  );
}

/// A clearly-named stub. The integrator swaps this for a real call into
/// `lib/booking/` (an entitlement spend or a lead-capture write) once
/// Nutrition's paid layer is wired to the booking engine.
void requestExpertOptionPlaceholder(String optionTitle) {}
