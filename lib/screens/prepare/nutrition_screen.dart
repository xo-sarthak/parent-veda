// =============================================================================
//  Nutrition funnel - Prepare › Nutrition
// -----------------------------------------------------------------------------
//  A guided funnel, end to end:
//    1. Assessment      (NutritionScreen)          - a short form
//    2. Recommended     (NutritionPlansScreen)     - plan cards scored to answers
//    3. Trailer         (NutritionTrailerScreen)   - a plan preview + Book CTA
//    4. Expert Consult  (ConsultationDetailScreen) - REUSED existing booking UI
//    5. Diet Plan       (NutritionDietPlanScreen)  - the personalized plan
//  Real plans/backends don't exist yet, so plans and the final diet plan are
//  tasteful placeholders (see prepare_data.dart), but the click-through works.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'consultation_detail_screen.dart';
import 'prepare_common.dart';

// ---------------------------------------------------------------------------
//  Step 1 - Assessment
// ---------------------------------------------------------------------------
class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  String _trimester = 't3'; // 30 weeks default; TODO derive from due date
  String? _goal;
  String _diet = 'veg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          children: [
            pvTopBar(context, backLabel: 'Prepare'),
            const SizedBox(height: 22),
            pvEyebrow('Eat well, for two'),
            const SizedBox(height: 10),
            Text('Nutrition', style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text('A two-minute check-in, then a plan built around you - and a nutritionist to make it yours.',
                style: pvSubStyle()),
            pvBanner(icon: Icons.eco_outlined, spans: [
              pvText('Answer a few questions and we\'ll match you to the right plan and expert.'),
            ]),

            const SizedBox(height: 26),
            _q('Which trimester are you in?'),
            const SizedBox(height: 12),
            _chips(kNutriTrimesters, _trimester, (id) => setState(() => _trimester = id)),

            const SizedBox(height: 24),
            _q("What's your main focus right now?"),
            const SizedBox(height: 12),
            _chips(kNutriGoals, _goal, (id) => setState(() => _goal = id)),

            const SizedBox(height: 24),
            _q('How do you eat?'),
            const SizedBox(height: 12),
            _chips(kNutriDiets, _diet, (id) => setState(() => _diet = id)),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: pvPrimaryButton(
                _goal == null ? 'Pick a focus to continue' : 'See my recommended plans',
                _goal == null
                    ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Choose a main focus first'), behavior: SnackBarBehavior.floating))
                    : () => Navigator.of(context).push(MaterialPageRoute<void>(
                        builder: (_) => NutritionPlansScreen(goalId: _goal))),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
            pvFooterNote('Your answers only shape your recommendation - nothing is shared without you.'),
          ],
        ),
      ),
    );
  }

  Widget _q(String t) => Text(t, style: pvTitleStyle(16));

  Widget _chips(List<NutriOption> options, String? selected, ValueChanged<String> onTap) => Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => onTap(o.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                decoration: BoxDecoration(
                  color: o.id == selected ? kPurple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: o.id == selected ? kPurple : kBorder),
                ),
                child: Text(o.label,
                    style: pvBody(o.id == selected ? Colors.white : kInk, 13.5)
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      );
}

// ---------------------------------------------------------------------------
//  Step 2 - Recommended plans
// ---------------------------------------------------------------------------
class NutritionPlansScreen extends StatelessWidget {
  const NutritionPlansScreen({super.key, this.goalId});
  final String? goalId;

  @override
  Widget build(BuildContext context) {
    final plans = recommendPlans(goalId: goalId);
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          children: [
            pvTopBar(context, backLabel: 'Nutrition'),
            const SizedBox(height: 22),
            pvEyebrow('Matched to you'),
            const SizedBox(height: 10),
            Text('Your recommended plans', style: pvHeroStyle().copyWith(fontSize: 28)),
            const SizedBox(height: 12),
            Text('Based on your answers - each one is a starting point a nutritionist will personalise.',
                style: pvSubStyle()),
            const SizedBox(height: 22),
            for (final p in plans) _planCard(context, p),
          ],
        ),
      ),
    );
  }

  Widget _planCard(BuildContext context, NutritionPlan p) => GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => NutritionTrailerScreen(plan: p))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: kBorder),
            boxShadow: pvCardShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            PvStriped(height: 96, colorA: p.accent.withValues(alpha: 0.16), colorB: p.accent.withValues(alpha: 0.05)),
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(p.name, style: pvTitleStyle(18))),
                  pvPill(p.weeks),
                ]),
                const SizedBox(height: 6),
                Text(p.tagline, style: pvBody(kSoft, 13.5).copyWith(height: 1.5)),
                const SizedBox(height: 14),
                Row(children: [
                  Text.rich(TextSpan(children: [
                    TextSpan(text: p.price, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                    TextSpan(text: '  ·  ${p.priceNote}', style: const TextStyle(color: kMuted)),
                  ]), style: pvBody(kInk, 13)),
                  const Spacer(),
                  Text('Preview →', style: pvBody(kPurple, 13).copyWith(fontWeight: FontWeight.w700)),
                ]),
              ]),
            ),
          ]),
        ),
      );
}

// ---------------------------------------------------------------------------
//  Step 3 - Plan trailer / preview
// ---------------------------------------------------------------------------
class NutritionTrailerScreen extends StatelessWidget {
  const NutritionTrailerScreen({super.key, required this.plan});
  final NutritionPlan plan;

  @override
  Widget build(BuildContext context) {
    final p = plan;
    return Scaffold(
      backgroundColor: kCanvas,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 110),
            children: [
              pvTopBar(context, backLabel: 'Plans'),

              const SizedBox(height: 18),
              // trailer surface
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(children: [
                  PvStriped(height: 200, radius: 22, colorA: p.accent.withValues(alpha: 0.18), colorB: p.accent.withValues(alpha: 0.05)),
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.94), shape: BoxShape.circle),
                        child: Icon(Icons.play_arrow_rounded, color: p.accent, size: 30),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: kInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                      child: Text('Trailer · 60 sec', style: pvBody(Colors.white, 11).copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 20),
              Row(children: [Expanded(child: Text(p.name, style: pvHeroStyle().copyWith(fontSize: 26))), pvPill(p.weeks)]),
              const SizedBox(height: 10),
              Text(p.tagline, style: pvSubStyle()),

              const SizedBox(height: 22),
              Text("What's inside", style: pvTitleStyle(16)),
              const SizedBox(height: 12),
              for (final h in p.highlights) _check(h),

              const SizedBox(height: 22),
              Text('A day on this plan', style: pvTitleStyle(16)),
              const SizedBox(height: 4),
              Text('A sample - your nutritionist tailors it to your body and tastes.', style: pvBody(kMuted, 12)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
                child: Column(children: [
                  for (int i = 0; i < p.sampleDay.length; i++)
                    _mealRow(p.sampleDay[i].meal, p.sampleDay[i].food, bottom: i == p.sampleDay.length - 1),
                ]),
              ),

              pvBanner(icon: Icons.verified_outlined, spans: [
                pvText('Every plan is finalised with a '),
                pvPurple('registered nutritionist'),
                pvText(' in a 1:1 consult - so it truly fits you.'),
              ]),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: pvBottomFade,
            child: Row(children: [
              Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.price, style: pvBody(kInk, 16).copyWith(fontWeight: FontWeight.w700)),
                Text('with a 1:1 consult', style: pvBody(kPurple, 11).copyWith(fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: pvPrimaryButton('Book my nutritionist', () => _book(context),
                      padding: const EdgeInsets.symmetric(vertical: 15)),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  // Step 4 -> reuse the existing consultation booking UI for the nutritionist,
  // and on a successful booking flow on to the personalized diet plan (step 5).
  void _book(BuildContext context) {
    final nutritionist = specialistById('sp_nutrition') ?? kSpecialists.first;
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ConsultationDetailScreen(
        specialist: nutritionist,
        onBooked: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => NutritionDietPlanScreen(plan: plan),
        )),
      ),
    ));
  }

  Widget _check(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
            child: const Text('✓', style: TextStyle(color: kPurple, fontSize: 11)),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(t, style: pvBody(kInk, 14).copyWith(height: 1.45))),
        ]),
      );

  Widget _mealRow(String meal, String food, {bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
            border: Border(bottom: bottom ? BorderSide.none : const BorderSide(color: Color(0xFFE1D7EC)))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 96,
            child: Text(meal, style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(food, style: pvBody(kInk, 13.5).copyWith(height: 1.4))),
        ]),
      );
}

// ---------------------------------------------------------------------------
//  Step 5 - Personalized diet plan (placeholder, reached after booking)
// ---------------------------------------------------------------------------
class NutritionDietPlanScreen extends StatelessWidget {
  const NutritionDietPlanScreen({super.key, required this.plan});
  final NutritionPlan plan;

  @override
  Widget build(BuildContext context) {
    final p = plan;
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          children: [
            pvTopBar(context, backLabel: 'Back'),
            const SizedBox(height: 22),
            Center(
              child: Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_menu_rounded, size: 30, color: kPurple),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text('Your personalized diet plan', textAlign: TextAlign.center, style: pvHeroStyle().copyWith(fontSize: 26))),
            const SizedBox(height: 10),
            Center(
              child: Text(
                  'Built from ${p.name} and confirmed with your nutritionist. It updates after your consult.',
                  textAlign: TextAlign.center,
                  style: pvSubStyle()),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
              child: Row(children: [
                const Icon(Icons.event_available_outlined, size: 20, color: kPurple),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Consult booked. Your nutritionist will fine-tune this plan on the call, then it lands here in full.',
                      style: pvBody(kInk, 13.5).copyWith(height: 1.5)),
                ),
              ]),
            ),

            const SizedBox(height: 24),
            Text('${p.weeks} · your starting menu', style: pvTitleStyle(16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder)),
              child: Column(children: [
                for (int i = 0; i < p.sampleDay.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: i == p.sampleDay.length - 1
                                ? BorderSide.none
                                : const BorderSide(color: kHair))),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      SizedBox(
                        width: 96,
                        child: Text(p.sampleDay[i].meal,
                            style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(p.sampleDay[i].food, style: pvBody(kInk, 13.5).copyWith(height: 1.4))),
                    ]),
                  ),
              ]),
            ),

            const SizedBox(height: 22),
            Text('Your focus this plan', style: pvTitleStyle(16)),
            const SizedBox(height: 12),
            for (final h in p.highlights)
              Padding(
                padding: const EdgeInsets.only(bottom: 11),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.check_rounded, size: 18, color: kPurple),
                  const SizedBox(width: 10),
                  Expanded(child: Text(h, style: pvBody(kInk, 14).copyWith(height: 1.5))),
                ]),
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: pvPrimaryButton('Download full plan', () => pvComingSoon(context, 'Your plan PDF'),
                  padding: const EdgeInsets.symmetric(vertical: 15)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: pvOutlineButton('Back to Prepare', () => Navigator.of(context).popUntil((r) => r.isFirst)),
            ),
            pvFooterNote('This is a preview plan. Payments and full meal plans go live with the nutrition backend.'),
          ],
        ),
      ),
    );
  }
}
