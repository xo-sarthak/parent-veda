// =============================================================================
//  SavedHubScreen - everything the mother has bookmarked, in one place
// -----------------------------------------------------------------------------
//  Opened from Profile › Saved. Groups her saved things - Read-to-baby pieces,
//  Daily reads, and Videos - newest-saved first within each group, with the
//  save date. The saved content is the priority; a light "discover more" sits
//  below. Every group ALWAYS renders its header - an empty one shows a tappable
//  note leading to where you'd save that kind of thing - so a mother who has
//  only ever saved videos still learns reads and read-to-baby pieces are savable
//  too. A feature is never hidden for being empty.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/read_next_data.dart';
import '../localization/app_language.dart';
import '../models/pv_video.dart';
import '../models/read_item.dart';
import '../services/pregnancy_controller.dart';
import '../services/read_next_store.dart';
import '../services/read_to_baby_saved_store.dart';
import '../services/video_store.dart';
import '../theme/app_theme.dart';
import 'garbh_screen.dart';
import 'read_next_screen.dart';
import 'watch_learn_screen.dart';
import '../theme/pv_fonts.dart';
import 'brackets/hub/hub_intent_art.dart' show IntentMark;
import 'doors/pv_list_row.dart' show PvMarkWell;
import 'pregnancy/preg_chrome.dart';
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

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
    // One ParentVeda (2026-09-30): the page ground, not the old grey
    // container tint.
    return Scaffold(
      backgroundColor: pvStorePalette.ground,
      appBar: AppBar(
        backgroundColor: pvStorePalette.ground,
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

          // Every section renders its header whether or not it has anything in
          // it. Previously each one vanished independently, so someone who had
          // saved a video never discovered that reads and read-to-baby pieces
          // were savable at all - a feature is never hidden for being empty.
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Read-to-baby.
              _header(s.shReadToBaby),
              if (rtb.isEmpty)
                _emptyNote(s.shReadToBabyEmpty, s.shBrowseRtb,
                    () => _push(context, SamvadScreen(controller: controller)))
              else
                for (final p in rtb)
                  _tile(
                    mark: IntentMark.bookMark,
                    hue: 30,
                    title: p.title,
                    subtitle: p.tag,
                    date: _date(s, p.savedAt),
                    onTap: () => _push(
                        context, SavedRtbReadScreen(controller: controller, piece: p)),
                  ),
              // Daily reads.
              _header(s.shReads),
              if (reads.isEmpty)
                _emptyNote(s.shReadsEmpty, s.shRead,
                    () => _push(context, ReadNextScreen(controller: controller)))
              else
                for (final r in reads)
                  _tile(
                    // Kept for revert: emoji: r.emoji, color: AppTheme.neutral900,
                    mark: IntentMark.pageMark,
                    hue: 212,
                    title: r.title.now,
                    subtitle: '${r.category} · ${r.readingTime}',
                    date: _date(s, ReadNextStore.instance.savedAt(r.id)),
                    onTap: () => _push(context,
                        ReadItemScreen(item: r, controller: controller)),
                  ),
              // Videos.
              _header(s.vidSecSaved),
              if (videos.isEmpty)
                _emptyNote(s.shVideosEmpty, s.shWatch,
                    () => _push(context, WatchLearnScreen(controller: controller)))
              else
                for (final v in videos)
                  _tile(
                    // Kept for revert: leadingIcon: videoMeta(v.category).icon,
                    // color: videoMeta(v.category).color,
                    mark: IntentMark.playMark,
                    hue: 345,
                    title: v.title.of(lang),
                    subtitle: v.duration,
                    date: _date(s, VideoStore.instance.savedAt(v.id)),
                    onTap: () => _push(
                        context, WatchLearnScreen(controller: controller)),
                  ),
              const SizedBox(height: 18),
              // Light "discover more".
              _discover(context, s),
            ],
          );
        },
      ),
    );
  }

  // One section heading (2026-09-30): the serif. Was pvJakarta 16 / w800.
  Widget _header(String t) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 22, 2, 10),
        child: PregSectionHeading(t),
      );

  // Sits under a section header when that section has nothing saved, so the
  // section (and the fact that this kind of thing can be saved) stays visible.
  // It is TAPPABLE and carries a CTA: an empty state that only explains itself
  // is still dead space - it has to offer the way in, not just describe it.
  //
  // One ParentVeda (2026-09-30): a white card with the hairline, never a grey
  // block behind text. Kept for revert: the InkWell > Container carried
  // `color: AppTheme.surfaceContainer`, radius 16, padding 14 x 16.
  Widget _emptyNote(String text, String cta, VoidCallback onTap) => PregCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: SizedBox(
            width: double.infinity,
            child: Row(children: [
              const Icon(Icons.bookmark_border_rounded,
                  size: 18, color: AppTheme.neutral500),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(text,
                          style: pvManrope(
                              fontSize: 13,
                              height: 1.45,
                              color: AppTheme.neutral500)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Text(cta,
                            style: pvManrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: kPvInk)),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded,
                            size: 14, color: kPvInk),
                      ]),
                    ]),
              ),
            ]),
        ),
      );

  // One ParentVeda (2026-09-30): a white card with the hairline and no
  // shadow; a row that opens somewhere carries a drawn mark in its group's
  // tint, not an emoji or a tinted line icon. Kept for revert: the leading was
  // a 44pt `color.withValues(alpha: 0.12)` box holding `emoji` or
  // `Icon(leadingIcon, color: color)`, and the card cast a 0x0A2D144C shadow.
  Widget _tile({
    required IntentMark mark,
    required double hue,
    required String title,
    required String subtitle,
    required String date,
    required VoidCallback onTap,
  }) =>
      Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPvLine),
        ),
        child: ListTile(
          onTap: onTap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: PvMarkWell(p: pvStorePalette, hue: hue, size: 44, mark: mark),
          title: Text(title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: kPvInk)),
          subtitle: Text(
              date.isEmpty ? subtitle : '$subtitle · $date',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 12, color: AppTheme.neutral500)),
          trailing:
              const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ),
      );

  // RETIRED - the whole-screen empty state. All three sections now render their
  // own headers and empty notes, which teaches what is savable far better than
  // one generic message did. Kept for revert.
  // ignore: unused_element
  Widget _empty(BuildContext context, S s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.bookmark_border_rounded,
                size: 46, color: AppTheme.neutral300),
            const SizedBox(height: 14),
            Text(s.shEmpty,
                textAlign: TextAlign.center,
                style: pvManrope(
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
              foregroundColor: kPvInk,
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
              foregroundColor: kPvInk,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]);
}

// A simple reader for a saved read-to-baby piece.
// Public since 2026-09-16: the unified SavedScreen opens a saved piece here.
// (This hub itself is no longer pushed from anywhere — kept for revert.)
class SavedRtbReadScreen extends StatelessWidget {
  const SavedRtbReadScreen({super.key, required this.controller, required this.piece});
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
            style: pvManrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        children: [
          Text(piece.title,
              style: pvFraunces(
                  fontSize: 24,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900)),
          const SizedBox(height: 16),
          Text(piece.body,
              style: pvManrope(
                  fontSize: 16, height: 1.7, color: const Color(0xFF2F2C30))),
        ],
      ),
    );
  }
}
