// =============================================================================
//  BumpJourneyScreen - "My Bump Journey" (a visual pregnancy timeline)
// -----------------------------------------------------------------------------
//  A warm, editorial, memory-book feel (not a gallery): a progress header, a
//  week-by-week vertical timeline of bump photos with milestone badges woven
//  in, gentle "capture this week?" encouragement, Then & Now / compare, caption
//  suggestions, favourites and trimester filters. Each photo also flows into My
//  Journal + My Calendar (via BumpStore). Replay (MP4) + memory-book export are
//  future placeholders.
// =============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../localization/app_language.dart';
import '../models/bump_photo.dart';
import '../services/bump_store.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/storage_image.dart';

enum _BumpFilter { all, t1, t2, t3, captioned, favorites }

class BumpJourneyScreen extends StatefulWidget {
  const BumpJourneyScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<BumpJourneyScreen> createState() => _BumpJourneyScreenState();
}

class _BumpJourneyScreenState extends State<BumpJourneyScreen> {
  _BumpFilter _filter = _BumpFilter.all;
  PregnancyController get p => widget.controller;

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([BumpStore.instance, p]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(p.language);
    final all = BumpStore.instance.photos;
    final filtered = all.where(_matches).toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.bumpTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
        actions: [
          if (all.length >= 2)
            IconButton(
              tooltip: s.bumpThenNow,
              icon: const Icon(Icons.compare_rounded),
              onPressed: () => _openCompare(all),
            ),
          IconButton(
            tooltip: s.jrExport,
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _snack(s.bumpExportSoon),
          ),
        ],
      ),
      body: all.isEmpty
          ? _empty(s)
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                _progressCard(s, all),
                const SizedBox(height: 14),
                _filters(s),
                const SizedBox(height: 8),
                if (!BumpStore.instance.hasWeek(p.currentWeek))
                  _captureThisWeek(s),
                ..._timeline(s, filtered),
              ],
            ),
      // Plain round FAB (the photo icon fits the circle cleanly) - the extended
      // label was getting clipped by the circular background.
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addFlow(s),
        backgroundColor: AppTheme.secondary500,
        foregroundColor: Colors.white,
        tooltip: s.bumpAddPhoto,
        child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
      ),
    );
  }

  bool _matches(BumpPhoto b) => switch (_filter) {
        _BumpFilter.all => true,
        _BumpFilter.t1 => b.trimester == 1,
        _BumpFilter.t2 => b.trimester == 2,
        _BumpFilter.t3 => b.trimester == 3,
        _BumpFilter.captioned => b.caption.trim().isNotEmpty,
        _BumpFilter.favorites => b.isFavorite,
      };

  // --- progress --------------------------------------------------------------
  Widget _progressCard(S s, List<BumpPhoto> all) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.secondary100, AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.weekOf(p.currentWeek, 40),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                const SizedBox(height: 3),
                Text(s.bumpPhotosAdded(all.length),
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, color: AppTheme.neutral600)),
                const SizedBox(height: 2),
                Text(s.journeyPercentComplete(p.progressPercent),
                    style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary700)),
              ],
            ),
          ),
          if (all.length >= 2)
            GestureDetector(
              onTap: () => _openCompare(all),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                    color: AppTheme.secondary500,
                    borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  const Icon(Icons.compare_rounded, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(s.bumpThenNow,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _captureThisWeek(S s) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: AppTheme.secondary500.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.camera_alt_rounded,
              size: 20, color: AppTheme.secondary500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(s.bumpCaptureThisWeek(p.currentWeek),
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppTheme.primary800)),
          ),
          TextButton(
            onPressed: () => _addFlow(s),
            child: Text(s.bumpAddPhoto,
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary600)),
          ),
        ]),
      );

  // --- filters ---------------------------------------------------------------
  Widget _filters(S s) {
    final chips = <(_BumpFilter, String)>[
      (_BumpFilter.all, s.bumpFilterAll),
      (_BumpFilter.t1, s.bumpFilterT1),
      (_BumpFilter.t2, s.bumpFilterT2),
      (_BumpFilter.t3, s.bumpFilterT3),
      (_BumpFilter.captioned, s.bumpFilterCaptioned),
      (_BumpFilter.favorites, s.bumpFilterFavorites),
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final c in chips) ...[
            GestureDetector(
              onTap: () => setState(() => _filter = c.$1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _filter == c.$1
                      ? AppTheme.secondary500
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: _filter == c.$1 ? null : _soft,
                ),
                child: Text(c.$2,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _filter == c.$1
                            ? Colors.white
                            : AppTheme.neutral600)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  // --- timeline (photos + milestone badges) ----------------------------------
  List<Widget> _timeline(S s, List<BumpPhoto> photos) {
    if (photos.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 40, 8, 8),
          child: Center(
            child: Text(s.bumpNothingForFilter,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 13.5, color: AppTheme.neutral500)),
          ),
        ),
      ];
    }
    final milestones = <(int, String)>[
      (12, s.jrFirstTriDone),
      (20, s.jrHalfway),
      (28, s.jrThirdTriStart),
      (37, s.jrFullTerm),
    ];
    final out = <Widget>[];
    var mi = 0;
    for (final b in photos) {
      while (mi < milestones.length && milestones[mi].$1 <= b.weekNumber) {
        out.add(_milestoneBadge(milestones[mi].$2));
        mi++;
      }
      out.add(_photoCard(s, b));
    }
    return out;
  }

  Widget _milestoneBadge(String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(child: Divider(color: AppTheme.primary100)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 14, color: AppTheme.primary400),
              const SizedBox(width: 6),
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary500)),
            ]),
          ),
          Expanded(child: Divider(color: AppTheme.primary100)),
        ]),
      );

  Widget _photoCard(S s, BumpPhoto b) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 8),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(s.jrWeekLabel(b.weekNumber),
                    style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary900)),
                Text('${s.formatShortDate(b.date)} · ${s.trimesterName(b.weekNumber)}',
                    style: GoogleFonts.manrope(
                        fontSize: 11.5, color: AppTheme.neutral500)),
              ]),
              const Spacer(),
              IconButton(
                icon: Icon(
                    b.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: AppTheme.secondary500),
                onPressed: () => BumpStore.instance.toggleFavorite(b.id),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz_rounded,
                    color: AppTheme.neutral500),
                onSelected: (v) {
                  if (v == 'caption') _editCaption(s, b);
                  if (v == 'delete') _confirmDelete(s, b);
                },
                itemBuilder: (_) => [
                  PopupMenuItem(value: 'caption', child: Text(s.bumpEditCaption)),
                  PopupMenuItem(value: 'delete', child: Text(s.delete)),
                ],
              ),
            ]),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: StorageImage(
              b.imageUrl,
              width: double.infinity,
              height: 320,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: b.caption.trim().isEmpty
                ? GestureDetector(
                    onTap: () => _editCaption(s, b),
                    child: Text(s.jrCaptionHint,
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.neutral400)),
                  )
                : Text(b.caption,
                    style: GoogleFonts.fraunces(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppTheme.primary800)),
          ),
        ],
      ),
    );
  }

  // --- empty -----------------------------------------------------------------
  Widget _empty(S s) => Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppTheme.secondary50, shape: BoxShape.circle),
                child: const Icon(Icons.pregnant_woman_rounded,
                    size: 44, color: AppTheme.secondary400),
              ),
              const SizedBox(height: 18),
              Text(s.bumpEmptyTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary900)),
              const SizedBox(height: 8),
              Text(s.bumpEmptyBody,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                      fontSize: 14, height: 1.5, color: AppTheme.neutral600)),
              const SizedBox(height: 22),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.secondary500),
                onPressed: () => _addFlow(s),
                icon: const Icon(Icons.add_a_photo_rounded, size: 18),
                label: Text(s.bumpAddFirst),
              ),
            ],
          ),
        ),
      );

  // --- add flow --------------------------------------------------------------
  void _addFlow(S s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
        child: SafeArea(
          top: false,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99))),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded,
                  color: AppTheme.secondary500),
              title: Text(s.bumpTakePhoto,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              onTap: () {
                Navigator.pop(ctx);
                _pick(s, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.secondary500),
              title: Text(s.bumpUpload,
                  style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              onTap: () {
                Navigator.pop(ctx);
                _pick(s, ImageSource.gallery);
              },
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _pick(S s, ImageSource source) async {
    try {
      final x = await ImagePicker()
          .pickImage(source: source, maxWidth: 1600, imageQuality: 88);
      if (x == null) return;
      if (!mounted) return;
      _afterPick(s, x.path);
    } catch (_) {
      _snack(s.cameraFailed);
    }
  }

  void _afterPick(S s, String path) {
    final captionCtrl = TextEditingController();
    var week = p.currentWeek;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.neutral300,
                          borderRadius: BorderRadius.circular(99))),
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(path),
                      height: 220, width: double.infinity, fit: BoxFit.cover),
                ),
                const SizedBox(height: 14),
                // week stepper
                Row(children: [
                  Text(s.jrWeekLabel(week),
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                  const Spacer(),
                  _stepBtn(Icons.remove_rounded,
                      () => setSheet(() => week = (week - 1).clamp(4, 40))),
                  const SizedBox(width: 10),
                  _stepBtn(Icons.add_rounded,
                      () => setSheet(() => week = (week + 1).clamp(4, 40))),
                ]),
                const SizedBox(height: 14),
                TextField(
                  controller: captionCtrl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: s.jrCaptionHint,
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final sug in s.bumpCaptionSuggestions)
                      GestureDetector(
                        onTap: () => setSheet(() => captionCtrl.text = sug),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                              color: AppTheme.secondary50,
                              borderRadius: BorderRadius.circular(99)),
                          child: Text(sug,
                              style: GoogleFonts.manrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.secondary700)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.secondary500),
                    onPressed: () async {
                      await BumpStore.instance.addPhoto(
                        sourcePath: path,
                        week: week,
                        caption: captionCtrl.text.trim(),
                        journalLabel: s.bumpJournalTitle(week),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      _snack(s.bumpSaved);
                    },
                    child: Text(s.saveCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: AppTheme.primary700),
        ),
      );

  void _editCaption(S s, BumpPhoto b) {
    final ctrl = TextEditingController(text: b.caption);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: s.jrCaptionHint,
                filled: true,
                fillColor: AppTheme.surfaceContainer,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  BumpStore.instance.updateCaption(b.id, ctrl.text.trim());
                  Navigator.pop(ctx);
                },
                child: Text(s.saveCta),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmDelete(S s, BumpPhoto b) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deletePhotoQ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          TextButton(
            onPressed: () {
              BumpStore.instance.delete(b.id);
              Navigator.pop(ctx);
            },
            child: Text(s.delete,
                style: const TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _openCompare(List<BumpPhoto> photos) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _BumpCompareScreen(photos: photos, lang: p.language),
    ));
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// =============================================================================
//  Then & Now / compare
// =============================================================================
class _BumpCompareScreen extends StatefulWidget {
  const _BumpCompareScreen({required this.photos, required this.lang});
  final List<BumpPhoto> photos;
  final AppLanguage lang;

  @override
  State<_BumpCompareScreen> createState() => _BumpCompareScreenState();
}

class _BumpCompareScreenState extends State<_BumpCompareScreen> {
  late BumpPhoto _then;
  late BumpPhoto _now;

  @override
  void initState() {
    super.initState();
    _then = widget.photos.first;
    _now = widget.photos.last;
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.lang);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.bumpThenNow,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _slot(s, s.bumpThen, _then)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 60),
                child: Text('❤', style: TextStyle(fontSize: 20)),
              ),
              Expanded(child: _slot(s, s.bumpNow, _now)),
            ],
          ),
          const SizedBox(height: 18),
          _picker(s, s.bumpThen, (b) => setState(() => _then = b), _then),
          const SizedBox(height: 12),
          _picker(s, s.bumpNow, (b) => setState(() => _now = b), _now),
        ],
      ),
    );
  }

  Widget _slot(S s, String label, BumpPhoto b) => Column(
        children: [
          Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: AppTheme.secondary600)),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: StorageImage(b.imageUrl,
                height: 230, fit: BoxFit.cover, width: double.infinity),
          ),
          const SizedBox(height: 6),
          Text(s.jrWeekLabel(b.weekNumber),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
        ],
      );

  Widget _picker(S s, String label, ValueChanged<BumpPhoto> onPick,
          BumpPhoto selected) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neutral500)),
          const SizedBox(height: 6),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final b in widget.photos) ...[
                  GestureDetector(
                    onTap: () => onPick(b),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: b.id == selected.id
                            ? AppTheme.secondary500
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(s.jrWeekLabel(b.weekNumber),
                          style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: b.id == selected.id
                                  ? Colors.white
                                  : AppTheme.neutral600)),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      );
}
