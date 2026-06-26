// =============================================================================
//  SavedHubScreen — everything the mother has bookmarked, in one place
// -----------------------------------------------------------------------------
//  Opened from Profile › Saved. Groups her saved things — Read-to-baby pieces,
//  Daily reads, and Videos — newest-saved first within each group, with the
//  save date. The saved content is the priority; a light "discover more" sits
//  below. Empty groups are hidden; a friendly empty state shows when nothing's
//  saved yet.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/read_next_data.dart';
import '../localization/app_language.dart';
import '../models/pv_video.dart';
import '../models/read_item.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_next_store.dart';
import '../services/read_to_baby_saved_store.dart';
import '../services/video_store.dart';
import '../theme/app_theme.dart';
import 'read_next_screen.dart';
import 'watch_learn_screen.dart';

PvVideo? _videoById(String id) {
  for (final v in kVideos) {
    if (v.id == id) return v;
  }
  return null;
}

class SavedHubScreen extends StatelessWidget {
  const SavedHubScreen({super.key, required this.controller});
  final PregnancyController controller;

  void _push(BuildContext c, Widget w) =>
      Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

  String _date(S s, int millis) => millis == 0
      ? ''
      : s.formatShortDate(DateTime.fromMillisecondsSinceEpoch(millis));

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.shTitle),
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          VideoStore.instance,
          ReadNextStore.instance,
          ReadToBabySavedStore.instance,
        ]),
        builder: (context, _) {
          final rtb = ReadToBabySavedStore.instance.recent();
          final reads = ReadNextStore.instance
              .savedIdsRecent()
              .map((id) => readById(id))
              .whereType<ReadItem>()
              .toList();
          final videos = VideoStore.instance
              .savedIdsRecent()
              .map(_videoById)
              .whereType<PvVideo>()
              .toList();

          if (rtb.isEmpty && reads.isEmpty && videos.isEmpty) {
            return _empty(context, s);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Read-to-baby.
              if (rtb.isNotEmpty) ...[
                _header(s.shReadToBaby),
                for (final p in rtb)
                  _tile(
                    leadingIcon: Icons.menu_book_rounded,
                    color: AppTheme.secondary500,
                    title: p.title,
                    subtitle: p.tag,
                    date: _date(s, p.savedAt),
                    onTap: () => _push(
                        context, _SavedRtbReadScreen(controller: controller, piece: p)),
                  ),
              ],
              // Daily reads.
              if (reads.isNotEmpty) ...[
                _header(s.shReads),
                for (final r in reads)
                  _tile(
                    emoji: r.emoji,
                    color: AppTheme.primary500,
                    title: r.title,
                    subtitle: '${r.category} · ${r.readingTime}',
                    date: _date(s, ReadNextStore.instance.savedAt(r.id)),
                    onTap: () => _push(context,
                        ReadItemScreen(item: r, controller: controller)),
                  ),
              ],
              // Videos.
              if (videos.isNotEmpty) ...[
                _header(s.vidSecSaved),
                for (final v in videos)
                  _tile(
                    leadingIcon: videoMeta(v.category).icon,
                    color: videoMeta(v.category).color,
                    title: v.title.of(lang),
                    subtitle: v.duration,
                    date: _date(s, VideoStore.instance.savedAt(v.id)),
                    onTap: () => _push(
                        context, WatchLearnScreen(controller: controller)),
                  ),
              ],
              const SizedBox(height: 18),
              // Light "discover more".
              _discover(context, s),
            ],
          );
        },
      ),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 18, 2, 8),
        child: Text(t,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary900)),
      );

  Widget _tile({
    String? emoji,
    IconData? leadingIcon,
    required Color color,
    required String title,
    required String subtitle,
    required String date,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A2D144C), blurRadius: 10, offset: Offset(0, 2)),
          ],
        ),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: emoji != null
                ? Text(emoji, style: const TextStyle(fontSize: 20))
                : Icon(leadingIcon, size: 20, color: color),
          ),
          title: Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          subtitle: Text(
              date.isEmpty ? subtitle : '$subtitle · $date',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 12, color: AppTheme.neutral500)),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ),
      );

  Widget _empty(BuildContext context, S s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bookmark_border_rounded,
                size: 46, color: AppTheme.neutral300),
            const SizedBox(height: 14),
            Text(s.shEmpty,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 14, height: 1.5, color: AppTheme.neutral500)),
            const SizedBox(height: 18),
            _discover(context, s),
          ]),
        ),
      );

  Widget _discover(BuildContext context, S s) => Row(children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                _push(context, WatchLearnScreen(controller: controller)),
            icon: const Icon(Icons.video_library_outlined, size: 18),
            label: Text(s.shWatch),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                _push(context, ReadNextScreen(controller: controller)),
            icon: const Icon(Icons.auto_stories_outlined, size: 18),
            label: Text(s.shRead),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);
}

// A simple reader for a saved read-to-baby piece.
class _SavedRtbReadScreen extends StatelessWidget {
  const _SavedRtbReadScreen({required this.controller, required this.piece});
  final PregnancyController controller;
  final SavedRtbPiece piece;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(piece.tag,
            style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        children: [
          Text(piece.title,
              style: GoogleFonts.fraunces(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary900)),
          const SizedBox(height: 16),
          Text(piece.body,
              style: GoogleFonts.manrope(
                  fontSize: 16, height: 1.7, color: const Color(0xFF4A4358))),
        ],
      ),
    );
  }
}
