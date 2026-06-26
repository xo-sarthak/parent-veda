// =============================================================================
//  ProfileScreen  —  the "Profile" tab
// -----------------------------------------------------------------------------
//  A light profile header, the Dear Baby memory-vault entry point, and a
//  language toggle. Dear Baby lives here (rather than its own tab) so the Tools
//  tab can be a permanent destination.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../localization/app_language.dart';
import '../services/bump_store.dart';
import '../services/daily_store.dart';
import '../services/journal_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_next_store.dart';
import '../services/read_to_baby_saved_store.dart';
import '../services/video_store.dart';
import '../theme/app_theme.dart';
import 'auth/auth_flow_screen.dart';
import 'bump_journey_screen.dart';
import 'dear_baby_vault_screen.dart';
import 'journal_screen.dart';
import 'saved_hub_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final name = controller.motherName;
    final initial = name.isNotEmpty ? name.characters.first : '🌸';

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.profileTitle, style: text.titleLarge),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          // --- Profile header ---------------------------------------------
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: text.headlineSmall?.copyWith(
                    color: AppTheme.primary600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    '${s.weekOf(controller.currentWeek, PregnancyController.lastContentWeek)} · ${s.trimesterName(controller.currentWeek)}',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // --- My Journal -------------------------------------------------
          AnimatedBuilder(
            animation: JournalStore.instance,
            builder: (context, _) {
              final count = JournalStore.instance.manualEntries.length;
              return _VaultCard(
                title: s.jrTitle,
                subtitle: s.jrSubtitle,
                trailing: count > 0 ? '$count' : '',
                icon: Icons.auto_stories_rounded,
                accent: AppTheme.primary500,
                accentBg: AppTheme.primary50,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JournalScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- My Bump Journey --------------------------------------------
          AnimatedBuilder(
            animation: BumpStore.instance,
            builder: (context, _) {
              final count = BumpStore.instance.count;
              return _VaultCard(
                title: s.bumpTitle,
                subtitle: s.bumpSubtitle,
                trailing: count > 0 ? '$count' : '',
                icon: Icons.pregnant_woman_rounded,
                accent: AppTheme.secondary500,
                accentBg: AppTheme.secondary50,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BumpJourneyScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- Dear Baby memory vault -------------------------------------
          AnimatedBuilder(
            animation: DailyStore.instance,
            builder: (context, _) {
              final count = DailyStore.instance.talkEntries.length;
              return _VaultCard(
                title: s.dearBabyVaultTitle,
                subtitle: s.dearBabyVaultSubtitle,
                trailing: s.dearBabyEntries(count),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DearBabyVaultScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- Saved (bookmarked videos) ----------------------------------
          AnimatedBuilder(
            animation: Listenable.merge([
              VideoStore.instance,
              ReadNextStore.instance,
              ReadToBabySavedStore.instance,
            ]),
            builder: (context, _) {
              final count = VideoStore.instance.savedIds.length +
                  ReadNextStore.instance.savedIds.length +
                  ReadToBabySavedStore.instance.recent().length;
              return _VaultCard(
                title: s.savedVaultTitle,
                subtitle: s.savedHubSubtitle,
                trailing: count > 0 ? '$count' : '',
                icon: Icons.bookmark_rounded,
                accent: const Color(0xFF3FA56A),
                accentBg: const Color(0xFFEAF3EF),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SavedHubScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- Language toggle --------------------------------------------
          _LanguageCard(controller: controller),
          const SizedBox(height: 16),
          // --- Sign out (replays the auth flow) ---------------------------
          OutlinedButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(s.profileSignOut),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.secondary600,
              side: BorderSide(
                  color: AppTheme.secondary500.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(s.moreComingSoon, style: text.labelMedium),
          ),
        ],
      ),
      ),
    );
  }

  /// "Sign out" — clears the local auth flag and replays the auth flow over the
  /// app; completing it re-sets the flag (and feeds any picked due date in).
  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    try {
      await (await SharedPreferences.getInstance())
          .setBool(kAuthCompletedKey, false);
    } catch (_) {/* best-effort */}
    nav.push(MaterialPageRoute(
      builder: (_) => AuthFlowScreen(onDone: (due) async {
        try {
          await (await SharedPreferences.getInstance())
              .setBool(kAuthCompletedKey, true);
        } catch (_) {/* best-effort */}
        if (due != null) await controller.setDueDate(due);
        nav.pop();
      }),
    ));
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.icon = Icons.favorite_rounded,
    this.accent = AppTheme.secondary500,
    this.accentBg = AppTheme.secondary50,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final IconData icon;
  final Color accent;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: text.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        Text(trailing, style: text.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: text.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final isEnglish = controller.language.isEnglish;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.translate_rounded,
                color: AppTheme.primary500, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(s.languageLabel, style: text.titleMedium)),
          _Segmented(
            leftLabel: s.languageHinglish,
            rightLabel: s.languageEnglish,
            rightSelected: isEnglish,
            onLeft: () => controller.setLanguage(AppLanguage.hinglish),
            onRight: () => controller.setLanguage(AppLanguage.english),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.leftLabel,
    required this.rightLabel,
    required this.rightSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool rightSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(context, leftLabel, !rightSelected, onLeft),
          _seg(context, rightLabel, rightSelected, onRight),
        ],
      ),
    );
  }

  Widget _seg(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: text.labelMedium?.copyWith(
            color: selected ? Colors.white : AppTheme.neutral600,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
