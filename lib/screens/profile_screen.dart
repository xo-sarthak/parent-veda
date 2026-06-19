// =============================================================================
//  ProfileScreen  —  the "Profile" tab
// -----------------------------------------------------------------------------
//  A light profile header, the Dear Baby memory-vault entry point, and a
//  language toggle. Dear Baby lives here (rather than its own tab) so the Tools
//  tab can be a permanent destination.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/daily_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'dear_baby_vault_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final name = controller.motherName;
    final initial = name.isNotEmpty ? name.characters.first : '🌸';

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Text(s.profileTitle, style: text.headlineMedium),
          const SizedBox(height: 18),
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
          // --- Language toggle --------------------------------------------
          _LanguageCard(controller: controller),
          const SizedBox(height: 24),
          Center(
            child: Text(s.moreComingSoon, style: text.labelMedium),
          ),
        ],
      ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;

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
                  color: AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.favorite_rounded,
                    color: AppTheme.secondary500, size: 26),
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
