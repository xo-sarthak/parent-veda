// =============================================================================
//  Read Next ❤️ - stage-aware reading & discovery (opened from the mother Home)
// -----------------------------------------------------------------------------
//  A curated, week-aware feed: a hero "This Week's Pick", recommendations for
//  the current week, a "looking ahead" row, curated books, research-simplified
//  cards, expert picks and a saved list. Every item shows "Why this matters
//  now". Recommendations are primary; search is secondary.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/read_next_data.dart';
import '../localization/app_language.dart';
import '../models/read_item.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_done_store.dart';
import '../services/read_next_store.dart';
import '../theme/app_theme.dart';
import 'book_companion_screen.dart';
import 'read_reader_screen.dart';

const Color _accent = AppTheme.primary500;
const Color _gold = Color(0xFFE6A817);
const Color _green = Color(0xFF3FA56A);

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

// Every read card now opens the premium "Learn V2" reader (progress bar, table
// of contents, font-size + light/sepia/dark modes, Why-This-Matters + Research-
// Simplified blocks, read-next chain). The old plain reader (ReadItemScreen,
// below) is kept for reference / revert but no longer wired.
// A book with a companion opens the dedicated Book Companion experience: a
// hero, sticky section nav and reading progress are the shape of a BOOK, and
// forcing them into the article reader would have made both worse. Everything
// else still opens the generic Learn V2 reader, untouched.
void _openItem(BuildContext c, ReadItem item, PregnancyController ctrl) => _push(
      c,
      item.hasCompanion
          ? BookCompanionScreen(item: item, controller: ctrl)
          : ReadReaderScreen(item: item, controller: ctrl),
    );
// void _openItem(BuildContext c, ReadItem item, PregnancyController ctrl) =>
//     _push(c, ReadItemScreen(item: item, controller: ctrl));

Color _statusColor(String status) {
  switch (status) {
    case 'reading':
      return _gold;
    case 'completed':
      return _green;
    default:
      return _accent;
  }
}

String _statusLabel(S s, String status) {
  switch (status) {
    case 'reading':
      return s.rnReadingBadge;
    case 'completed':
      return s.rnCompletedBadge;
    default:
      return s.rnSaveBadge;
  }
}

String _fmtCount(int n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

// ===========================================================================
//  Full screen
// ===========================================================================

class ReadNextScreen extends StatelessWidget {
  const ReadNextScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final week = controller.currentWeek;
    final hero = heroForWeek(week);
    final recommended =
        recommendedForWeek(week).where((r) => r.id != hero?.id).toList();
    final ahead = lookingAhead(week);
    final books = readByType(ReadType.book);
    final research = readByType(ReadType.research);
    final experts = readByType(ReadType.expert);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(s.rnTitle), const Text(' ❤️'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => showSearch<void>(
                context: context, delegate: _ReadSearchDelegate(controller)),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: ReadNextStore.instance,
        builder: (context, _) {
          final saved = ReadNextStore.instance.savedIds
              .map(readById)
              .whereType<ReadItem>()
              .toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
            children: [
              Text(s.rnSubtitle,
                  style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
              const SizedBox(height: 16),
              if (hero != null) _HeroCard(item: hero, controller: controller),
              if (recommended.isNotEmpty) ...[
                _heading(context, s.rnRecommended),
                for (final r in recommended) _ReadCard(item: r, controller: controller),
              ],
              if (ahead.isNotEmpty) ...[
                _heading(context, s.rnLookingAhead),
                for (final r in ahead)
                  _ReadCard(
                      item: r,
                      controller: controller,
                      aheadLabel: s.rnComingUp(r.weekStart)),
              ],
              if (books.isNotEmpty) ...[
                _heading(context, s.rnBooks),
                SizedBox(
                  height: 340,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: books.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, i) =>
                        _BookCard(item: books[i], controller: controller),
                  ),
                ),
              ],
              if (research.isNotEmpty) ...[
                _heading(context, s.rnResearch),
                for (final r in research) _ReadCard(item: r, controller: controller),
              ],
              if (experts.isNotEmpty) ...[
                _heading(context, s.rnExperts),
                for (final r in experts) _ExpertCard(item: r, controller: controller),
              ],
              if (saved.isNotEmpty) ...[
                _heading(context, s.rnSavedSection),
                for (final r in saved) _ReadCard(item: r, controller: controller),
              ],
            ],
          );
        },
      ),
    );
  }
}

Widget _heading(BuildContext context, String t) => Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 12),
      child: Text(t,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w800)),
    );

// ===========================================================================
//  Cards
// ===========================================================================

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.item, required this.controller});
  final ReadItem item;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _openItem(context, item, controller),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_accent.withValues(alpha: 0.16), AppTheme.surface],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _accent.withValues(alpha: 0.20)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.star_rounded, size: 16, color: _gold),
            const SizedBox(width: 6),
            Text(s.rnThisWeekPick.toUpperCase(),
                style: text.labelSmall?.copyWith(
                    color: _gold, letterSpacing: 0.6, fontWeight: FontWeight.w800)),
            const Spacer(),
            _SaveHeart(id: item.id),
          ]),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title,
                    style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
                const SizedBox(height: 4),
                Text('${item.category} · ${item.readingTime}',
                    style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
              ]),
            ),
          ]),
          const SizedBox(height: 14),
          _WhyNow(reason: item.reason, lang: controller.language),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                  backgroundColor: _accent,
                  padding: const EdgeInsets.symmetric(vertical: 13)),
              onPressed: () => _openItem(context, item, controller),
              icon: const Icon(Icons.menu_book_rounded, size: 18, color: Colors.white),
              label: Text(s.rnReadNow,
                  style: text.labelLarge?.copyWith(color: Colors.white)),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ReadCard extends StatelessWidget {
  const _ReadCard({
    required this.item,
    required this.controller,
    this.aheadLabel,
  });
  final ReadItem item;
  final PregnancyController controller;
  final String? aheadLabel;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final status = ReadNextStore.instance.statusOf(item.id);
    return GestureDetector(
      onTap: () => _openItem(context, item, controller),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (aheadLabel != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(aheadLabel!,
                      style: text.labelSmall?.copyWith(
                          color: _gold, fontWeight: FontWeight.w800)),
                ),
              Row(children: [
                Expanded(
                  child: Text(item.title,
                      style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (status != null) ...[
                  const SizedBox(width: 6),
                  _statusChip(context, status, s),
                ],
              ]),
              Text('${item.category} · ${item.readingTime}',
                  style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
              const SizedBox(height: 6),
              Text('${s.rnWhyNow}: ${item.reason}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.35)),
            ]),
          ),
          _SaveHeart(id: item.id),
        ]),
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({required this.item, required this.controller});
  final ReadItem item;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _openItem(context, item, controller),
      child: Container(
        width: 214,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(item.emoji, style: const TextStyle(fontSize: 32)),
            const Spacer(),
            _SaveHeart(id: item.id),
          ]),
          const SizedBox(height: 8),
          Text(item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
          Text(item.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
          if (item.hasRating) ...[
            const SizedBox(height: 5),
            Row(children: [
              const Icon(Icons.star_rounded, size: 15, color: _gold),
              const SizedBox(width: 3),
              Text(item.rating.toStringAsFixed(1),
                  style: text.labelSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(width: 4),
              Text('(${_fmtCount(item.ratingCount)})',
                  style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            ]),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: Text(item.why,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: text.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.35)),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _accent,
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(s.rnBuyComingSoon))),
              child: Text(s.rnBuyNow,
                  style: text.labelMedium?.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: BorderSide(color: _accent.withValues(alpha: 0.5), width: 1.3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _openItem(context, item, controller),
              child: Text(s.rnKnowMore, style: text.labelMedium),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({required this.item, required this.controller});
  final ReadItem item;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: () => _openItem(context, item, controller),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _accent.withValues(alpha: 0.12),
              child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${s.rnRecommendedBy} ${item.author}',
                    style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                Text(item.authorRole,
                    style: text.labelSmall?.copyWith(
                        color: _accent, fontWeight: FontWeight.w700)),
              ]),
            ),
            _SaveHeart(id: item.id),
          ]),
          const SizedBox(height: 12),
          Text(item.title,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(item.why,
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral700, height: 1.4)),
        ]),
      ),
    );
  }
}

class _WhyNow extends StatelessWidget {
  const _WhyNow({required this.reason, required this.lang});
  final String reason;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _gold.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _gold.withValues(alpha: 0.22)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.lightbulb_rounded, size: 14, color: Color(0xFF9A7A14)),
          const SizedBox(width: 6),
          Text(s.rnWhyNow.toUpperCase(),
              style: text.labelSmall?.copyWith(
                  color: const Color(0xFF9A7A14),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        Text(reason, style: text.bodyMedium?.copyWith(height: 1.4)),
      ]),
    );
  }
}

Widget _statusChip(BuildContext context, String status, S s) {
  final c = _statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: c.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(_statusLabel(s, status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: c, fontWeight: FontWeight.w800)),
  );
}

class _SaveHeart extends StatelessWidget {
  const _SaveHeart({required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ReadNextStore.instance,
      builder: (context, _) {
        final saved = ReadNextStore.instance.isSaved(id);
        return InkResponse(
          radius: 22,
          onTap: () => ReadNextStore.instance.toggleSave(id),
          child: Icon(saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: saved ? const Color(0xFFEF6F8E) : AppTheme.neutral400, size: 22),
        );
      },
    );
  }
}

// ===========================================================================
//  Reader
// ===========================================================================

class ReadItemScreen extends StatelessWidget {
  const ReadItemScreen({super.key, required this.item, required this.controller});
  final ReadItem item;
  final PregnancyController controller;
  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final isBook = item.type == ReadType.book;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [_SaveHeart(id: item.id), const SizedBox(width: 8)],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge(
            [ReadNextStore.instance, ReadDoneStore.instance]),
        builder: (context, _) {
          ReadDoneStore.instance.ensureLoaded();
          final status = ReadNextStore.instance.statusOf(item.id);
          final done = ReadDoneStore.instance.isDone(item.id);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Center(child: Text(item.emoji, style: const TextStyle(fontSize: 56))),
              const SizedBox(height: 12),
              Text(item.title,
                  textAlign: TextAlign.center,
                  style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                  item.author.isNotEmpty
                      ? '${item.author} · ${item.category}'
                      : '${item.category} · ${item.readingTime}',
                  textAlign: TextAlign.center,
                  style: text.labelMedium?.copyWith(color: AppTheme.neutral500)),
              const SizedBox(height: 18),
              _WhyNow(reason: item.reason, lang: controller.language),
              const SizedBox(height: 18),
              if (item.authorRole.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text('${s.rnRecommendedBy} ${item.author} · ${item.authorRole}',
                      style: text.labelMedium?.copyWith(
                          color: _accent, fontWeight: FontWeight.w700)),
                ),
              if (isBook || item.why.isNotEmpty && item.body.isEmpty)
                _sectionCard(context, s.rnWhyRecommend, item.why)
              else
                for (final para in item.body.split('\n\n'))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(para,
                        style: text.bodyLarge?.copyWith(height: 1.6, fontSize: 16)),
                  ),
              const SizedBox(height: 8),
              // status actions - once it's completed we DON'T offer "reading"
              // any more (completed and reading are mutually exclusive).
              Row(children: [
                if (!done) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: status == 'reading' ? _gold : AppTheme.neutral700,
                        side: BorderSide(
                            color: status == 'reading' ? _gold : AppTheme.outlineVariant,
                            width: 1.4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => ReadNextStore.instance.setStatus(item.id, 'reading'),
                      child: Text(status == 'reading' ? s.rnReadingBadge : s.rnMarkReading),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: done ? _green : _accent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    // Marking complete here ticks the Home daily-reads checkbox
                    // too (same ReadDoneStore) and clears any "reading" status -
                    // no second tap, no contradictory state.
                    onPressed: () {
                      ReadDoneStore.instance.toggle(item.id);
                      if (ReadDoneStore.instance.isDone(item.id)) {
                        ReadNextStore.instance.setStatus(item.id, 'completed');
                      } else {
                        ReadNextStore.instance.clearStatus(item.id);
                      }
                    },
                    child: Text(done ? s.rnCompletedBadge : s.rnMarkDone,
                        style: text.labelLarge?.copyWith(color: Colors.white)),
                  ),
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

Widget _sectionCard(BuildContext context, String title, String body) {
  final text = Theme.of(context).textTheme;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.outlineVariant),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
    ]),
  );
}

// ===========================================================================
//  Home card - clean entry point on the mother Home screen
// ===========================================================================

class ReadNextHomeCard extends StatelessWidget {
  const ReadNextHomeCard({super.key, required this.controller, required this.lang});
  final PregnancyController controller;
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final hero = heroForWeek(controller.currentWeek);
    if (hero == null) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
          child: Row(children: [
            Text('${s.rnTitle} ❤️',
                style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const Spacer(),
            const Icon(Icons.star_rounded, size: 16, color: _gold),
            const SizedBox(width: 4),
            Text(s.rnThisWeekPick,
                style: text.labelSmall?.copyWith(
                    color: AppTheme.neutral500, fontWeight: FontWeight.w700)),
          ]),
        ),
        GestureDetector(
          onTap: () => _openItem(context, hero, controller),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(hero.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(hero.title,
                      style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.2)),
                  const SizedBox(height: 2),
                  Text('${hero.category} · ${hero.readingTime}',
                      style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
                  const SizedBox(height: 8),
                  Text('${s.rnWhyNow}: ${hero.reason}',
                      style: text.bodySmall?.copyWith(color: AppTheme.neutral600, height: 1.4)),
                ]),
              ),
            ]),
          ),
        ),
        const Divider(height: 1, color: AppTheme.outlineVariant),
        Row(children: [
          Expanded(
            child: TextButton(
              onPressed: () => _openItem(context, hero, controller),
              child: Text(s.rnReadNow,
                  style: text.labelLarge?.copyWith(color: _accent, fontWeight: FontWeight.w800)),
            ),
          ),
          Container(width: 1, height: 24, color: AppTheme.outlineVariant),
          Expanded(
            child: TextButton(
              onPressed: () => _push(context, ReadNextScreen(controller: controller)),
              child: Text(s.rnMoreReading,
                  style: text.labelLarge?.copyWith(color: AppTheme.neutral700)),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ===========================================================================
//  Daily Reads - home section (above Read Next): 3 rotating articles + a
//  books column. Vertical list (no carousel): heading on top, content below.
// ===========================================================================

/// Soft per-category thumbnail tint.
Color _readTint(String category) {
  switch (category) {
    case 'Baby Development':
      return AppTheme.primary100;
    case 'Mother Changes':
      return AppTheme.secondary100;
    case 'Nutrition':
      return const Color(0xFFE3F3E8);
    case 'Preparation':
      return const Color(0xFFF6ECD8);
    case 'Emotional Wellbeing':
      return const Color(0xFFEDE7FA);
    case 'Partner Support':
      return const Color(0xFFE4ECF8);
    default:
      return AppTheme.primary100;
  }
}

class DailyReadsHomeCard extends StatelessWidget {
  const DailyReadsHomeCard(
      {super.key, required this.controller, required this.lang});
  final PregnancyController controller;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    ReadDoneStore.instance.ensureLoaded();
    return AnimatedBuilder(
      animation: Listenable.merge(
          [ReadDoneStore.instance, ReadNextStore.instance]),
      builder: (context, _) {
    final s = S(lang);
    final week = controller.currentWeek;
    final day = controller.currentDay;
    final articles = dailyArticleReads(week, day);
    final research = dailyResearchReads(day);
    final books = dailyBookReads(day);
    if (articles.isEmpty && research.isEmpty && books.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary900.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Gradient header bar.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppTheme.primary600, AppTheme.primary400],
            ),
          ),
          child: Text(
            s.drTitle,
            style: GoogleFonts.fraunces(
                fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
        // Articles.
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
          child: _groupLabel(s.drArticles),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              for (var i = 0; i < articles.length; i++)
                _row(context, articles[i],
                    divider: i != articles.length - 1),
            ],
          ),
        ),
        // Research Summaries.
        if (research.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: _groupLabel(s.drResearch),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (var i = 0; i < research.length; i++)
                  _row(context, research[i],
                      divider: i != research.length - 1),
              ],
            ),
          ),
        ],
        // Book Summaries.
        if (books.isNotEmpty) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 4),
            child: _groupLabel(s.drBooks),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              children: [
                for (var i = 0; i < books.length; i++)
                  _row(context, books[i],
                      isBook: true, divider: i != books.length - 1),
              ],
            ),
          ),
        ],
        // See all.
        const Divider(height: 1, color: AppTheme.outlineVariant),
        Center(
          child: TextButton(
            onPressed: () =>
                _push(context, ReadNextScreen(controller: controller)),
            child: Text(s.drSeeAll,
                style: TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3)),
          ),
        ),
      ]),
    );
      },
    );
  }

  Widget _groupLabel(String text) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: AppTheme.neutral500,
        ),
      );

  Widget _row(BuildContext context, ReadItem r,
      {bool isBook = false, bool divider = true}) {
    final text = Theme.of(context).textTheme;
    final done = ReadDoneStore.instance.isDone(r.id);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          // Daily Reads is a clean read row now - no check-off here, just the
          // read + a bookmark heart (per request). Completion can still be set
          // from the full article view; that just dims the title below.
          Expanded(
            child: InkWell(
              onTap: () => _openItem(context, r, controller),
              child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _readTint(r.category),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child:
                          Text(r.emoji, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            // "Read" is now shown by a small tick on the right
                            // (below) - no strike-through / dimming.
                            style: text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700, height: 1.25),
                          ),
                          const SizedBox(height: 3),
                          if (isBook)
                            Row(children: [
                              const Icon(Icons.star_rounded,
                                  size: 13, color: _gold),
                              const SizedBox(width: 3),
                              Text(r.rating.toStringAsFixed(1),
                                  style: text.labelSmall?.copyWith(
                                      color: AppTheme.neutral600,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(r.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.labelSmall?.copyWith(
                                        color: AppTheme.neutral500)),
                              ),
                            ])
                          else
                            Text('${r.category} · ${r.readingTime}',
                                style: text.labelSmall
                                    ?.copyWith(color: AppTheme.neutral500)),
                        ],
                      ),
                    ),
                  ]),
            ),
          ),
          // A small tick marks this read as done (replaces the old strike-through).
          if (done) ...[
            const Icon(Icons.check_circle_rounded,
                size: 18, color: Color(0xFF4F7A52)),
            const SizedBox(width: 8),
          ],
          // Bookmark this read - saved reads surface in the Profile › Saved hub.
          _SaveHeart(id: r.id),
        ]),
      ),
      // Book summaries get "Read summary" + "Buy Book" actions.
      if (isBook) _bookActions(context, r),
      if (divider) const Divider(height: 1, color: AppTheme.outlineVariant),
    ]);
  }

  // Read-summary + Buy-Book actions shown under a book-summary row.
  Widget _bookActions(BuildContext context, ReadItem r) {
    final s = S(lang);
    return Padding(
      padding: const EdgeInsets.only(left: 66, bottom: 12),
      child: Row(children: [
        _miniBtn(Icons.menu_book_rounded, s.drReadSummary, filled: false,
            () => _openItem(context, r, controller)),
        const SizedBox(width: 8),
        _miniBtn(Icons.shopping_bag_rounded, s.drBuyBook, filled: true,
            () => _openBuy(context, r)),
      ]),
    );
  }

  Widget _miniBtn(IconData icon, String label, VoidCallback onTap,
          {bool filled = false}) =>
      Material(
        color: filled ? _accent : AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon,
                  size: 15,
                  color: filled ? Colors.white : AppTheme.primary700),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: filled ? Colors.white : AppTheme.primary700)),
            ]),
          ),
        ),
      );

  Future<void> _openBuy(BuildContext context, ReadItem r) async {
    final query = Uri.encodeComponent(
        '${r.title} ${r.author} book buy'.trim());
    final url = r.buyUrl.trim().isNotEmpty
        ? r.buyUrl.trim()
        : 'https://www.google.com/search?q=$query';
    final uri = Uri.parse(url);
    final ok = await canLaunchUrl(uri);
    if (ok) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(r.title)));
    }
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _ReadSearchDelegate extends SearchDelegate<void> {
  _ReadSearchDelegate(this.controller);
  final PregnancyController controller;
  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];
  @override
  Widget buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back_rounded), onPressed: () => close(context, null));
  @override
  Widget buildResults(BuildContext context) => _results(context);
  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final results = readSearch(query);
    final text = Theme.of(context).textTheme;
    return ListView(
      children: [
        for (final r in results)
          ListTile(
            leading: Text(r.emoji, style: const TextStyle(fontSize: 24)),
            title: Text(r.title),
            subtitle: Text('${r.category} · ${r.readingTime}',
                style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            onTap: () {
              close(context, null);
              _openItem(context, r, controller);
            },
          ),
      ],
    );
  }
}
