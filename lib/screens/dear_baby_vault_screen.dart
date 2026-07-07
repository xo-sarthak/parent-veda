// =============================================================================
//  DearBabyVaultScreen  -  the "Dear Baby" memory vault
// -----------------------------------------------------------------------------
//  Surfaces every Talk-To-Your-Baby message the mother has saved (persisted in
//  DailyStore). Reached from a card on the Profile tab. Read-only for now.
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../services/daily_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';

class DearBabyVaultScreen extends StatefulWidget {
  const DearBabyVaultScreen({super.key, required this.controller});

  final PregnancyController controller;

  @override
  State<DearBabyVaultScreen> createState() => _DearBabyVaultScreenState();
}

class _DearBabyVaultScreenState extends State<DearBabyVaultScreen> {
  @override
  void initState() {
    super.initState();
    // Idempotent - ensures entries are loaded if this is opened very early.
    DailyStore.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);

    return Scaffold(
      appBar: AppBar(title: Text(s.dearBabyVaultTitle)),
      body: AnimatedBuilder(
        animation: DailyStore.instance,
        builder: (context, _) {
          final entries = DailyStore.instance.talkEntries;
          if (entries.isEmpty) {
            return _EmptyState(message: s.dearBabyEmpty);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final e = entries[i];
              return _VaultCard(
                week: e.week,
                date: e.dateIso,
                prompt: e.prompt,
                body: e.text,
                tag: e.spoken ? s.spokenLabel : s.writtenLabel,
                weekWord: s.weekWord,
              );
            },
          );
        },
      ),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({
    required this.week,
    required this.date,
    required this.prompt,
    required this.body,
    required this.tag,
    required this.weekWord,
  });

  final int week;
  final String date;
  final String prompt;
  final String body;
  final String tag;
  final String weekWord;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary50,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  '$weekWord $week',
                  style: text.labelSmall?.copyWith(
                    color: AppTheme.secondary700,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Text(date, style: text.labelSmall),
            ],
          ),
          if (prompt.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              prompt,
              style: text.labelMedium?.copyWith(color: AppTheme.secondary600),
            ),
          ],
          const SizedBox(height: 6),
          Text(body, style: text.bodyLarge),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite_rounded,
                  size: 13, color: AppTheme.secondary400),
              const SizedBox(width: 6),
              Text(tag, style: text.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.secondary50,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.favorite_rounded,
                  size: 34, color: AppTheme.secondary400),
            ),
            const SizedBox(height: 20),
            Text(message, textAlign: TextAlign.center, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}
