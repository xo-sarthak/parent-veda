// =============================================================================
//  Can I?™  - the Explore tab
// -----------------------------------------------------------------------------
//  The fastest way to settle a everyday "is this okay?" worry: search → a clear
//  verdict card → short answer → why → trimester notes → Indian context →
//  related questions, with a gentle "Ask Veda" handoff at the end. Calm, not
//  clinical; reassuring, never alarmist.
//
//  Content lives in lib/data/can_i_data.dart (curated seed). Saved questions are
//  persisted via CanIStore.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/can_i_data.dart';
import '../localization/app_language.dart';
import '../models/can_i_entry.dart';
import '../services/can_i_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'tools/ask_veda_screen.dart';

// ---------------------------------------------------------------------------
//  Verdict + category visual language
// ---------------------------------------------------------------------------

({Color color, IconData icon}) _verdictVisual(CanIVerdict v) {
  switch (v) {
    case CanIVerdict.safe:
      return (color: const Color(0xFF3FA56A), icon: Icons.check_circle_rounded);
    case CanIVerdict.moderation:
      return (color: const Color(0xFFE6A817), icon: Icons.balance_rounded);
    case CanIVerdict.depends:
      return (color: const Color(0xFFE8833A), icon: Icons.help_rounded);
    case CanIVerdict.avoid:
      return (
        color: const Color(0xFFD64545),
        icon: Icons.do_not_disturb_on_rounded
      );
    case CanIVerdict.askDoctor:
      return (
        color: const Color(0xFF7A4FC2),
        icon: Icons.medical_information_rounded
      );
  }
}

String _verdictKey(CanIVerdict v) {
  switch (v) {
    case CanIVerdict.safe:
      return 'safe';
    case CanIVerdict.moderation:
      return 'moderation';
    case CanIVerdict.depends:
      return 'depends';
    case CanIVerdict.avoid:
      return 'avoid';
    case CanIVerdict.askDoctor:
      return 'askDoctor';
  }
}

String _catLabel(S s, CanICategory c) {
  switch (c) {
    case CanICategory.eat:
      return s.canICatEat;
    case CanICategory.drink:
      return s.canICatDrink;
    case CanICategory.take:
      return s.canICatTake;
    case CanICategory.doActivity:
      return s.canICatDo;
  }
}

({IconData icon, String emoji, Color color}) _catVisual(CanICategory c) {
  switch (c) {
    case CanICategory.eat:
      return (icon: Icons.restaurant_rounded, emoji: '🍎', color: const Color(0xFF3FA56A));
    case CanICategory.drink:
      return (icon: Icons.local_cafe_rounded, emoji: '🥤', color: const Color(0xFF3B82C4));
    case CanICategory.take:
      return (icon: Icons.medication_rounded, emoji: '💊', color: const Color(0xFF7A4FC2));
    case CanICategory.doActivity:
      return (icon: Icons.directions_run_rounded, emoji: '🏃', color: const Color(0xFFE8833A));
  }
}

int _trimesterIndex(int week) => week <= 13 ? 0 : (week <= 27 ? 1 : 2);

void _openAnswer(BuildContext context, CanIEntry entry, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => CanIAnswerScreen(entry: entry, controller: c),
  ));
}

// ===========================================================================
//  Home (the Explore tab)
// ===========================================================================

class CanIScreen extends StatelessWidget {
  const CanIScreen({super.key, required this.controller});

  final PregnancyController controller;

  Future<void> _search(BuildContext context, AppLanguage lang) async {
    final picked = await showSearch<CanIEntry?>(
      context: context,
      delegate: _CanISearchDelegate(lang),
    );
    if (picked != null && context.mounted) _openAnswer(context, picked, controller);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final lang = controller.language;
        final s = S(lang);
        final text = Theme.of(context).textTheme;
        return Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.scaffoldBackground,
            elevation: 0,
            title: Text(s.canITitle,
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            actions: [
              ListenableBuilder(
                listenable: CanIStore.instance,
                builder: (context, _) => IconButton(
                  tooltip: s.canISavedTitle,
                  icon: Icon(CanIStore.instance.hasSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => _SavedScreen(controller: controller),
                  )),
                ),
              ),
            ],
          ),
          body: SafeArea(
            top: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
              children: [
                Text(s.canISubtitle,
                    style: text.bodyLarge?.copyWith(color: AppTheme.neutral600, height: 1.4)),
                const SizedBox(height: 18),
                _SearchBar(hint: s.canISearchHint, onTap: () => _search(context, lang)),
                const SizedBox(height: 26),
                Text(s.canIPopularTitle,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final p in kCanIPopular)
                      _PopularChip(
                        emoji: p.emoji,
                        label: p.label,
                        onTap: () {
                          final e = canIById(p.id);
                          if (e != null) _openAnswer(context, e, controller);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(s.canIBrowseTitle,
                    style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    for (final c in CanICategory.values)
                      _CategoryTile(
                        label: _catLabel(s, c),
                        visual: _catVisual(c),
                        count: canIByCategory(c).length,
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => _CategoryScreen(category: c, controller: controller),
                        )),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                _Disclaimer(text: s.canIDisclaimer),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hint, required this.onTap});
  final String hint;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary900.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, color: AppTheme.neutral500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(color: AppTheme.neutral500)),
          ),
        ]),
      ),
    );
  }
}

class _PopularChip extends StatelessWidget {
  const _PopularChip({required this.emoji, required this.label, required this.onTap});
  final String emoji;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppTheme.outlineVariant, width: 1.2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label,
              style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.label,
    required this.visual,
    required this.count,
    required this.onTap,
  });
  final String label;
  final ({IconData icon, String emoji, Color color}) visual;
  final int count;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: visual.color.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: visual.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(visual.icon, color: visual.color, size: 20),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            ),
            Text('$count',
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          ],
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded, size: 15, color: AppTheme.neutral400),
      const SizedBox(width: 8),
      Expanded(
        child: Text(text,
            style: t.bodySmall?.copyWith(color: AppTheme.neutral500, height: 1.4)),
      ),
    ]);
  }
}

// ===========================================================================
//  Category browse
// ===========================================================================

class _CategoryScreen extends StatelessWidget {
  const _CategoryScreen({required this.category, required this.controller});
  final CanICategory category;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final items = canIByCategory(category)
      ..sort((a, b) => a.name.of(lang).compareTo(b.name.of(lang)));
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(_catLabel(s, category))),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _EntryRow(
          entry: items[i],
          lang: lang,
          onTap: () => _openAnswer(context, items[i], controller),
        ),
      ),
    );
  }
}

/// A compact row: verdict dot + name + chevron. Reused by category + related + saved.
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry, required this.lang, required this.onTap});
  final CanIEntry entry;
  final AppLanguage lang;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final v = _verdictVisual(entry.verdict);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant, width: 1),
        ),
        child: Row(children: [
          Icon(v.icon, color: v.color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(entry.name.of(lang),
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Text(s.canIVerdictLabel(_verdictKey(entry.verdict)),
                  style: text.labelSmall?.copyWith(color: v.color, fontWeight: FontWeight.w700)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Answer page
// ===========================================================================

class CanIAnswerScreen extends StatelessWidget {
  const CanIAnswerScreen({super.key, required this.entry, required this.controller});
  final CanIEntry entry;
  final PregnancyController controller;

  void _askVeda(BuildContext context, S s) {
    // Ask Veda is live - open it pre-filled with this question (it has the data).
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AskVedaScreen(
          controller: controller,
          initialQuery: entry.name.of(controller.language)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final v = _verdictVisual(entry.verdict);
    final tri = _trimesterIndex(controller.currentWeek);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(entry.name.of(lang)),
        actions: [
          ListenableBuilder(
            listenable: CanIStore.instance,
            builder: (context, _) {
              final saved = CanIStore.instance.isSaved(entry.id);
              return IconButton(
                tooltip: saved ? s.canISavedBadge : s.canISave,
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                onPressed: () => CanIStore.instance.toggleSaved(entry.id),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          Text(s.canIDuringPregnancy(entry.name.of(lang)),
              style: text.titleMedium?.copyWith(color: AppTheme.neutral500)),
          const SizedBox(height: 14),

          // --- Verdict card (the hero) ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
            decoration: BoxDecoration(
              color: v.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: v.color.withValues(alpha: 0.35), width: 1.4),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(v.icon, color: v.color, size: 34),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.canIVerdictLabel(_verdictKey(entry.verdict)),
                      style: text.headlineSmall
                          ?.copyWith(color: v.color, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 14),
              Text(entry.short.of(lang),
                  style: text.bodyLarge?.copyWith(height: 1.5, color: AppTheme.neutral800)),
            ]),
          ),
          const SizedBox(height: 22),

          // --- Why? ---
          _SectionTitle(s.canIWhy),
          const SizedBox(height: 8),
          Text(entry.why.of(lang), style: text.bodyLarge?.copyWith(height: 1.55)),

          // --- Trimester notes ---
          if (entry.hasTrimesterNotes) ...[
            const SizedBox(height: 24),
            _SectionTitle(s.canITrimesterNotes),
            const SizedBox(height: 10),
            for (final note in [
              (0, entry.t1),
              (1, entry.t2),
              (2, entry.t3),
            ])
              if (note.$2 != null)
                _TrimesterRow(
                  label: s.canITrimesterLabel(note.$1),
                  body: note.$2!.of(lang),
                  isNow: note.$1 == tri,
                  nowBadge: s.canINowBadge,
                ),
          ],

          // --- Indian context ---
          if (entry.indian != null) ...[
            const SizedBox(height: 24),
            _IndianContextCard(title: s.canIIndianContext, body: entry.indian!.of(lang)),
          ],

          // --- Related questions ---
          if (entry.related.isNotEmpty) ...[
            const SizedBox(height: 26),
            _SectionTitle(s.canIRelated),
            const SizedBox(height: 10),
            for (final rid in entry.related)
              if (canIById(rid) != null) ...[
                _EntryRow(
                  entry: canIById(rid)!,
                  lang: lang,
                  onTap: () => _openAnswer(context, canIById(rid)!, controller),
                ),
                const SizedBox(height: 10),
              ],
          ],

          // --- Ask Veda handoff ---
          const SizedBox(height: 20),
          _AskVedaCard(
            title: s.canIAskTitle,
            body: s.canIAskBody,
            cta: s.canIAskCta,
            onTap: () => _askVeda(context, s),
          ),
          const SizedBox(height: 20),
          _Disclaimer(text: s.canIDisclaimer),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.w800));
  }
}

class _TrimesterRow extends StatelessWidget {
  const _TrimesterRow({
    required this.label,
    required this.body,
    required this.isNow,
    required this.nowBadge,
  });
  final String label;
  final String body;
  final bool isNow;
  final String nowBadge;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final accent = const Color(0xFF7A4FC2);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: isNow ? accent.withValues(alpha: 0.07) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow ? accent.withValues(alpha: 0.4) : AppTheme.outlineVariant,
          width: isNow ? 1.4 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label,
              style: text.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isNow ? accent : AppTheme.neutral700)),
          if (isNow) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(nowBadge,
                  style: text.labelSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700, fontSize: 10)),
            ),
          ],
        ]),
        const SizedBox(height: 6),
        Text(body, style: text.bodyMedium?.copyWith(height: 1.45)),
      ]),
    );
  }
}

class _IndianContextCard extends StatelessWidget {
  const _IndianContextCard({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const accent = Color(0xFFE8833A);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.25), width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🇮🇳', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(title,
              style: text.labelLarge?.copyWith(
                  color: accent, fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 8),
        Text(body, style: text.bodyMedium?.copyWith(height: 1.5)),
      ]),
    );
  }
}

class _AskVedaCard extends StatelessWidget {
  const _AskVedaCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary500.withValues(alpha: 0.10),
            AppTheme.secondary500.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.primary500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(body, style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary500,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            label: Text(cta, style: text.labelLarge?.copyWith(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ===========================================================================
//  Saved questions
// ===========================================================================

class _SavedScreen extends StatelessWidget {
  const _SavedScreen({required this.controller});
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.canISavedTitle)),
      body: ListenableBuilder(
        listenable: CanIStore.instance,
        builder: (context, _) {
          final entries = CanIStore.instance.savedIds
              .map(canIById)
              .whereType<CanIEntry>()
              .toList();
          if (entries.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.bookmark_border_rounded,
                      size: 44, color: AppTheme.neutral400),
                  const SizedBox(height: 14),
                  Text(s.canISavedEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium),
                ]),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _EntryRow(
              entry: entries[i],
              lang: lang,
              onTap: () => _openAnswer(context, entries[i], controller),
            ),
          );
        },
      ),
    );
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _CanISearchDelegate extends SearchDelegate<CanIEntry?> {
  _CanISearchDelegate(this.lang);
  final AppLanguage lang;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear_rounded),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final s = S(lang);
    final matches = canISearch(query);
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Text(s.canINoResults,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutral500)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _EntryRow(
        entry: matches[i],
        lang: lang,
        onTap: () => close(context, matches[i]),
      ),
    );
  }
}
