// =============================================================================
//  Week6PreviewScreen  ·  TEMPORARY design preview
// -----------------------------------------------------------------------------
//  A faithful, self-contained replica of the proposed home-screen mockup, wired
//  for WEEK 6 only ("just to see how it looks"). Nothing here is hooked into the
//  real card-stack flow - it is a static visual prototype. Values for week 6 are
//  pulled from weekContent.json (pomegranate seed · 4–6 mm · <1 g).
//
//  To stop previewing, point main.dart `home:` back at WeeklyCardStackScreen.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class Week6PreviewScreen extends StatelessWidget {
  const Week6PreviewScreen({super.key});

  static const _bg = AppTheme.scaffoldBackground;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            const _TopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                physics: const BouncingScrollPhysics(),
                children: const [
                  _TrimesterBar(),
                  SizedBox(height: 18),
                  _DateRange(),
                  SizedBox(height: 14),
                  _WeekStrip(),
                  SizedBox(height: 22),
                  _SizeCard(),
                  SizedBox(height: 18),
                  _MilestonesCard(),
                  SizedBox(height: 18),
                  _DailyReadCard(),
                  SizedBox(height: 18),
                  _PageDots(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ---------------------------------------------------------------------------
//  Top bar - logo + EN, then "Week 6 of 40"
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.spa_rounded, color: AppTheme.primary500, size: 24),
              const SizedBox(width: 8),
              Text('ParentVeda',
                  style: text.headlineSmall?.copyWith(
                      color: AppTheme.primary600, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: Text('EN',
                    style: text.labelMedium
                        ?.copyWith(color: AppTheme.neutral600, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Week 6 of 40',
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral500)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Trimester + progress
// ---------------------------------------------------------------------------

class _TrimesterBar extends StatelessWidget {
  const _TrimesterBar();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const progress = 6 / 40; // 15%
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trimester 1',
                style: text.headlineSmall?.copyWith(
                    color: AppTheme.primary600, fontWeight: FontWeight.w700)),
            Text('WEEK 6 · ${(progress * 100).round()}%',
                style: text.labelSmall?.copyWith(
                    color: AppTheme.neutral500, letterSpacing: 0.6)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: AppTheme.surfaceContainerHigh,
            valueColor: const AlwaysStoppedAnimation(AppTheme.secondary500),
          ),
        ),
      ],
    );
  }
}

class _DateRange extends StatelessWidget {
  const _DateRange();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Text('12 – 18 FEB',
          style: text.labelMedium?.copyWith(
              color: AppTheme.neutral500,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700)),
    );
  }
}

// ---------------------------------------------------------------------------
//  Week strip - 4,5,[6],7,8 with 6 selected
// ---------------------------------------------------------------------------

class _WeekStrip extends StatelessWidget {
  const _WeekStrip();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const weeks = [4, 5, 6, 7, 8];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final w in weeks) _WeekDot(week: w, selected: w == 6),
          ],
        ),
        const SizedBox(height: 8),
        Text('WEEKS',
            style: text.labelSmall?.copyWith(
                color: AppTheme.neutral400, letterSpacing: 2)),
      ],
    );
  }
}

class _WeekDot extends StatelessWidget {
  const _WeekDot({required this.week, required this.selected});
  final int week;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final size = selected ? 56.0 : 46.0;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? AppTheme.secondary500
            : AppTheme.neutral50,
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppTheme.secondary500.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Text('$week',
          style: (selected ? text.titleLarge : text.titleMedium)?.copyWith(
            color: selected ? Colors.white : AppTheme.neutral400,
            fontWeight: FontWeight.w700,
          )),
    );
  }
}

// ---------------------------------------------------------------------------
//  Shared card chrome
// ---------------------------------------------------------------------------

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
//  Size card - "How big am I?"
// ---------------------------------------------------------------------------

class _SizeCard extends StatelessWidget {
  const _SizeCard();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primary500,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.spa_rounded, color: Colors.white, size: 22),
              ),
              const Spacer(),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.volume_up_rounded,
                    color: AppTheme.neutral600, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('THIS WEEK',
              style: text.labelSmall?.copyWith(
                  color: AppTheme.neutral400, letterSpacing: 1.4)),
          const SizedBox(height: 4),
          Text('How big am I?',
              style: text.headlineMedium?.copyWith(
                  color: AppTheme.primary600, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          // Milestone pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.secondary50,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.flag_rounded, size: 14, color: AppTheme.secondary500),
              const SizedBox(width: 6),
              Text('THE BEATING HEART',
                  style: text.labelSmall?.copyWith(
                      color: AppTheme.secondary600,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
            ]),
          ),
          const SizedBox(height: 18),
          const Center(child: _SeedHalo()),
          const SizedBox(height: 18),
          const Center(child: _FruitBabyToggle()),
          const SizedBox(height: 18),
          Center(
            child: Text('I am about the size of',
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('a pomegranate seed',
                textAlign: TextAlign.center,
                style: text.headlineMedium?.copyWith(
                    color: AppTheme.primary600, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(height: 18),
          Row(children: const [
            Expanded(
                child: _Metric(
                    icon: Icons.straighten_rounded,
                    label: 'LENGTH',
                    value: '4–6 mm')),
            SizedBox(width: 12),
            Expanded(
                child: _Metric(
                    icon: Icons.hourglass_empty_rounded,
                    label: 'WEIGHT',
                    value: '< 1 g')),
          ]),
          const SizedBox(height: 16),
          // Week 6's own headline + the baby's first-person line (real data).
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your heart is now beating rhythmically, and major organs are beginning to take shape.',
                  style: text.bodyMedium?.copyWith(
                      color: AppTheme.primary900, height: 1.45),
                ),
                const SizedBox(height: 10),
                Text(
                  '“Maa, my little heart is beating steadily and helping me grow stronger every day.”',
                  style: text.bodyMedium?.copyWith(
                      color: AppTheme.primary600,
                      fontStyle: FontStyle.italic,
                      height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft lavender halo with a stylised seed motif (replicating the mockup).
class _SeedHalo extends StatelessWidget {
  const _SeedHalo();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer soft ring
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primary50,
              border: Border.all(
                  color: AppTheme.primary100.withValues(alpha: 0.8), width: 1.5),
            ),
          ),
          // Inner blush disc
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                AppTheme.secondary100,
                AppTheme.secondary200.withValues(alpha: 0.7),
              ]),
            ),
          ),
          // Four little seeds
          SizedBox(
            width: 46,
            height: 46,
            child: GridView.count(
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.secondary500,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FruitBabyToggle extends StatelessWidget {
  const _FruitBabyToggle();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget seg(String label, IconData icon, bool selected) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppTheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            border: selected
                ? Border.all(color: AppTheme.outlineVariant)
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.primary900.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 15,
                color: selected ? AppTheme.neutral700 : AppTheme.neutral400),
            const SizedBox(width: 6),
            Text(label,
                style: text.labelMedium?.copyWith(
                    color: selected ? AppTheme.neutral800 : AppTheme.neutral400,
                    fontWeight: FontWeight.w700)),
          ]),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        seg('FRUIT', Icons.eco_rounded, true),
        seg('BABY', Icons.child_care_rounded, false),
      ]),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(children: [
        Icon(icon, size: 20, color: AppTheme.neutral500),
        const SizedBox(height: 8),
        Text(label,
            style: text.labelSmall?.copyWith(
                color: AppTheme.neutral500, letterSpacing: 1)),
        const SizedBox(height: 3),
        Text(value, style: text.titleLarge?.copyWith(color: AppTheme.neutral900)),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Upcoming Milestones
// ---------------------------------------------------------------------------

class _MilestonesCard extends StatelessWidget {
  const _MilestonesCard();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upcoming Milestones',
              style: text.headlineSmall?.copyWith(
                  color: AppTheme.neutral900, fontWeight: FontWeight.w700)),
          const SizedBox(height: 18),
          const _MilestoneRow(
            week: 'WEEK 7',
            title: 'Tiny Features Begin',
            body:
                "Your baby's face is beginning to take shape and tiny arms and legs continue developing.",
            active: true,
            isLast: false,
          ),
          const _MilestoneRow(
            week: 'WEEK 8',
            title: 'Officially A Baby',
            body:
                'Your baby has completed the embryonic stage and is now officially considered a fetus.',
            active: false,
            isLast: false,
          ),
          const _MilestoneRow(
            week: 'WEEK 12',
            title: 'First Trimester Complete',
            body:
                "Your baby's organs are formed and the first trimester is coming to an end.",
            active: false,
            isLast: true,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.surfaceContainer,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('VIEW FULL TIMELINE',
                  style: text.labelMedium?.copyWith(
                      color: AppTheme.primary600,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneRow extends StatelessWidget {
  const _MilestoneRow({
    required this.week,
    required this.title,
    required this.body,
    required this.active,
    required this.isLast,
  });
  final String week;
  final String title;
  final String body;
  final bool active;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppTheme.secondary500 : AppTheme.neutral200,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.outlineVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(week,
                      style: text.labelSmall?.copyWith(
                          color: active
                              ? AppTheme.secondary600
                              : AppTheme.neutral400,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(title,
                      style: text.titleMedium?.copyWith(
                          color: AppTheme.neutral900,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(body,
                      style: text.bodyMedium
                          ?.copyWith(color: AppTheme.neutral500, height: 1.4)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Daily Read
// ---------------------------------------------------------------------------

class _DailyReadCard extends StatelessWidget {
  const _DailyReadCard();
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return _Card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary500,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.menu_book_rounded,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DAILY READ · NUTRITION',
                        style: text.labelSmall?.copyWith(
                            color: AppTheme.neutral400, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text('Surviving Morning Sickness',
                        style: text.titleMedium?.copyWith(
                            color: AppTheme.neutral900,
                            fontWeight: FontWeight.w700,
                            height: 1.3)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Eat before you feel hungry. An empty stomach often makes nausea worse.',
            style: text.bodyMedium
                ?.copyWith(color: AppTheme.neutral600, height: 1.45),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Page dots
// ---------------------------------------------------------------------------

class _PageDots extends StatelessWidget {
  const _PageDots();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 4; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == 0 ? 22 : 7,
            height: 7,
            decoration: BoxDecoration(
              color: i == 0 ? AppTheme.primary500 : AppTheme.primary200,
              borderRadius: BorderRadius.circular(40),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
//  Bottom nav
// ---------------------------------------------------------------------------

class _BottomNav extends StatelessWidget {
  const _BottomNav();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            _NavItem(icon: Icons.home_rounded, label: 'MAIN', selected: true),
            _NavItem(icon: Icons.list_rounded, label: 'LIST'),
            _NavItem(icon: Icons.timer_outlined, label: 'COUNTERS'),
            _NavItem(icon: Icons.settings_outlined, label: 'SETTINGS'),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem(
      {required this.icon, required this.label, this.selected = false});
  final IconData icon;
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon,
              size: 22,
              color: selected ? Colors.white : AppTheme.neutral400),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: text.labelSmall?.copyWith(
                color: selected ? AppTheme.primary600 : AppTheme.neutral400,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      ],
    );
  }
}
