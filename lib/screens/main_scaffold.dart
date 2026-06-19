// =============================================================================
//  MainScaffold
// -----------------------------------------------------------------------------
//  The app shell after launch: a bottom navigation bar across the five
//  destinations — Home (daily moment), My Baby (weekly journey entry),
//  Dear Baby, Explore, Profile. Home and My Baby are live; the rest are gentle
//  "coming soon" placeholders for the week-20 prototype.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/baby_voice_service.dart';
import '../services/father_content_controller.dart';
import '../services/home_content_controller.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'tools_screen.dart';
import 'weekly_card_stack_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({
    super.key,
    required this.pregnancy,
    required this.home,
    required this.father,
  });

  final PregnancyController pregnancy;
  final HomeContentController home;
  final FatherContentController father;

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  bool _fatherMode = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.pregnancy,
      builder: (context, _) {
        final s = S(widget.pregnancy.language);
        final pages = [
          HomeScreen(
            pregnancy: widget.pregnancy,
            home: widget.home,
            father: widget.father,
            fatherMode: _fatherMode,
            onFatherModeChanged: (v) => setState(() => _fatherMode = v),
          ),
          // My Baby opens straight into the weekly journey (the card-stack),
          // no intermediate landing card.
          WeeklyCardStackScreen(controller: widget.pregnancy),
          ToolsScreen(controller: widget.pregnancy),
          _ComingSoon(tab: s.exploreTab, icon: Icons.explore_rounded, lang: widget.pregnancy.language),
          ProfileScreen(controller: widget.pregnancy),
        ];
        return Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          body: IndexedStack(index: _index, children: pages),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) {
              // Leaving a surface always stops any baby voice, so audio never
              // bleeds across tabs.
              BabyVoiceService.instance.stop();
              // My Baby always opens at the mother's current week, regardless of
              // which week she last browsed to.
              if (i == 1) {
                widget.pregnancy.selectWeek(widget.pregnancy.currentWeek);
              }
              setState(() => _index = i);
            },
            destinations: [
              NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: s.homeTab),
              NavigationDestination(
                  icon: const Icon(Icons.child_care_outlined),
                  selectedIcon: const Icon(Icons.child_care_rounded),
                  label: s.myBabyTab),
              NavigationDestination(
                  icon: const Icon(Icons.widgets_outlined),
                  selectedIcon: const Icon(Icons.widgets_rounded),
                  label: s.toolsTab),
              NavigationDestination(
                  icon: const Icon(Icons.explore_outlined),
                  selectedIcon: const Icon(Icons.explore_rounded),
                  label: s.exploreTab),
              NavigationDestination(
                  icon: const Icon(Icons.person_outline_rounded),
                  selectedIcon: const Icon(Icons.person_rounded),
                  label: s.profileTab),
            ],
          ),
        );
      },
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.tab, required this.icon, required this.lang});
  final String tab;
  final IconData icon;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, size: 34, color: AppTheme.primary400),
            ),
            const SizedBox(height: 20),
            Text(tab, style: text.headlineSmall),
            const SizedBox(height: 8),
            Text(s.comingSoon,
                style: text.titleMedium?.copyWith(color: AppTheme.secondary600)),
            const SizedBox(height: 10),
            Text(s.comingSoonBody(tab),
                textAlign: TextAlign.center, style: text.bodyMedium),
          ]),
        ),
      ),
    );
  }
}
