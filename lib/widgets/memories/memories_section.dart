// =============================================================================
//  Memories — interactive memory book + read-only celebration collage
// -----------------------------------------------------------------------------
//  MemoriesSection: the mother's "memory book" — every weekly note (text + up to
//  two photos), tap to edit, delete with a tap. Used on Reflect & Remember.
//  MemoryCollage: a structured, read-only photo + journal compilation for the
//  week-40 finale.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/memory_models.dart';
import '../../screens/journal_writer_screen.dart';
import '../../screens/photo_viewer_screen.dart';
import '../../services/memory_store.dart';
import '../../theme/app_theme.dart';

class MemoriesSection extends StatelessWidget {
  const MemoriesSection({super.key, required this.lang, required this.week});

  final AppLanguage lang;
  final int week;

  void _edit(BuildContext context, JournalEntry e) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JournalWriterScreen(
        lang: lang,
        week: e.week,
        source: e.source,
        prompt: e.prompt,
        existing: e,
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context, JournalEntry e) async {
    final s = S(lang);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(s.deleteEntryQ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true) await MemoryStore.instance.deleteJournal(e.id);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return AnimatedBuilder(
      animation: MemoryStore.instance,
      builder: (context, _) {
        final entries = MemoryStore.instance.journal;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.menu_book_rounded, size: 18, color: AppTheme.secondary500),
              const SizedBox(width: 8),
              Text(s.memoryBook, style: text.titleMedium),
              const Spacer(),
              if (entries.isNotEmpty)
                Text(s.entriesCount(entries.length), style: text.labelSmall),
            ]),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              _EmptyMemories(text: s.noEntriesYet)
            else
              for (final e in entries)
                _EntryCard(
                  entry: e,
                  lang: lang,
                  onTap: () => _edit(context, e),
                  onDelete: () => _confirmDelete(context, e),
                ),
          ],
        );
      },
    );
  }
}

class _EmptyMemories extends StatelessWidget {
  const _EmptyMemories({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final styles = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(children: [
        Icon(Icons.auto_awesome_rounded, color: AppTheme.primary400, size: 20),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: styles.bodyMedium?.copyWith(height: 1.4))),
      ]),
    );
  }
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({
    required this.entry,
    required this.lang,
    required this.onTap,
    required this.onDelete,
  });
  final JournalEntry entry;
  final AppLanguage lang;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Text(
                lang.isEnglish ? 'Week ${entry.week}' : 'Hafta ${entry.week}',
                style: text.labelSmall?.copyWith(
                    color: AppTheme.primary700, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 10),
            Text(entry.dateIso, style: text.labelSmall),
            const Spacer(),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppTheme.neutral400),
              ),
            ),
          ]),
          if (entry.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(entry.text,
                style: text.bodyMedium?.copyWith(color: AppTheme.neutral800, height: 1.45)),
          ],
          if (entry.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (final p in entry.photoPaths)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PhotoViewerScreen(
                          photo: PhotoMemory(
                              id: entry.id,
                              week: entry.week,
                              dateIso: entry.dateIso,
                              path: p),
                          lang: lang,
                        ),
                      )),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(File(p),
                            width: 74, height: 74, fit: BoxFit.cover),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ]),
      ),
    );
  }
}

/// The week-scoped journal view used on the Reflect & Remember card for the
/// weeks 4–5 preview. Shows ONLY this week's single entry (text + up to two
/// photos) inline — tap to edit, delete to remove — or a calm prompt to add one.
/// No cross-week contamination: it reads [MemoryStore.journalForWeek].
class WeekEntryView extends StatelessWidget {
  const WeekEntryView({super.key, required this.lang, required this.week});

  final AppLanguage lang;
  final int week;

  void _open(BuildContext context, {JournalEntry? existing}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JournalWriterScreen(
        lang: lang,
        week: week,
        source: 'reflect_remember',
        prompt: S(lang).howWasYourWeek,
        existing: existing,
      ),
    ));
  }

  Future<void> _confirmDelete(BuildContext context, JournalEntry e) async {
    final s = S(lang);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(s.deleteEntryQ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text(s.delete)),
        ],
      ),
    );
    if (ok == true) await MemoryStore.instance.deleteJournal(e.id);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return AnimatedBuilder(
      animation: MemoryStore.instance,
      builder: (context, _) {
        final entry = MemoryStore.instance.journalForWeek(week);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.spa_rounded, size: 18, color: AppTheme.secondary500),
              const SizedBox(width: 8),
              Text(s.yourWeek, style: text.titleMedium),
            ]),
            const SizedBox(height: 12),
            if (entry == null)
              _AddYourWeek(lang: lang, onTap: () => _open(context))
            else
              _WeekEntryCard(
                entry: entry,
                lang: lang,
                onTap: () => _open(context, existing: entry),
                onDelete: () => _confirmDelete(context, entry),
              ),
          ],
        );
      },
    );
  }
}

/// Calm empty-state prompt shown when this week has no entry yet.
class _AddYourWeek extends StatelessWidget {
  const _AddYourWeek({required this.lang, required this.onTap});
  final AppLanguage lang;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary100, AppTheme.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.primary100, width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(s.howWasYourWeek,
                  style: text.titleLarge?.copyWith(
                      color: AppTheme.primary800, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                  color: AppTheme.primary500, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: Colors.white),
            ),
          ]),
          const SizedBox(height: 8),
          Text(s.journalCardSubtitle,
              style: text.bodyMedium
                  ?.copyWith(color: AppTheme.neutral700, height: 1.4)),
        ]),
      ),
    );
  }
}

/// This week's entry, shown inline: text + up to two photos, tap to edit.
class _WeekEntryCard extends StatelessWidget {
  const _WeekEntryCard({
    required this.entry,
    required this.lang,
    required this.onTap,
    required this.onDelete,
  });
  final JournalEntry entry;
  final AppLanguage lang;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.secondary50, AppTheme.surfaceContainer],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(entry.dateIso, style: text.labelSmall),
            const Spacer(),
            Icon(Icons.edit_rounded, size: 16, color: AppTheme.neutral400),
            const SizedBox(width: 4),
            Text(s.tapToEdit, style: text.labelSmall),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDelete,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(Icons.delete_outline_rounded,
                    size: 20, color: AppTheme.neutral400),
              ),
            ),
          ]),
          if (entry.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(entry.text,
                style: text.bodyLarge
                    ?.copyWith(color: AppTheme.neutral800, height: 1.5)),
          ],
          if (entry.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                for (final p in entry.photoPaths)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PhotoViewerScreen(
                          photo: PhotoMemory(
                              id: entry.id,
                              week: entry.week,
                              dateIso: entry.dateIso,
                              path: p),
                          lang: lang,
                        ),
                      )),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(File(p),
                            width: 96, height: 96, fit: BoxFit.cover),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ]),
      ),
    );
  }
}

/// Read-only structured compilation for the week-40 finale: a photo grid of all
/// captured memories, followed by the mother's journal reflections.
class MemoryCollage extends StatelessWidget {
  const MemoryCollage({super.key, required this.lang});
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = S(lang);
    final entries = MemoryStore.instance.journal;

    // Gather every photo (from notes + any legacy standalone photos).
    final photoPaths = <String>[
      for (final e in entries) ...e.photoPaths,
      for (final p in MemoryStore.instance.photos) p.path,
    ];
    final notes = entries.where((e) => e.text.trim().isNotEmpty).toList();

    if (photoPaths.isEmpty && notes.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          Icon(Icons.auto_awesome_rounded, color: AppTheme.primary400, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(s.noMemories, style: text.bodyMedium?.copyWith(height: 1.4))),
        ]),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🎞️', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(s.celebrationMemoriesTitle,
              style: text.titleMedium?.copyWith(color: AppTheme.primary800)),
        ]),
        const SizedBox(height: 14),
        if (photoPaths.isNotEmpty) ...[
          _PhotoGrid(paths: photoPaths),
          const SizedBox(height: 6),
          Center(
            child: Text(s.photosCount(photoPaths.length),
                style: text.labelSmall?.copyWith(color: AppTheme.primary600)),
          ),
          const SizedBox(height: 14),
        ],
        for (final e in notes.take(4))
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.format_quote_rounded, size: 16, color: AppTheme.primary400),
                const SizedBox(width: 6),
                Text(
                  lang.isEnglish ? 'Week ${e.week} · ${e.dateIso}' : 'Hafta ${e.week} · ${e.dateIso}',
                  style: text.labelSmall?.copyWith(color: AppTheme.primary600),
                ),
              ]),
              const SizedBox(height: 6),
              Text(e.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(height: 1.45)),
            ]),
          ),
      ],
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.paths});
  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    final shown = paths.take(6).toList();
    final extra = paths.length - shown.length;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < shown.length; i++)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Stack(
              children: [
                Image.file(File(shown[i]), width: 96, height: 96, fit: BoxFit.cover),
                if (i == shown.length - 1 && extra > 0)
                  Positioned.fill(
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Text('+$extra',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
