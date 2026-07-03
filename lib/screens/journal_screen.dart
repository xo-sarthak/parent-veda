// =============================================================================
//  JournalScreen — "My Journal" (the mother's pregnancy memory timeline)
// -----------------------------------------------------------------------------
//  A chronological, emotional feed (newest first) of memories, photos, notes
//  for baby, and auto milestones/health logs. Warm-Nest visual language:
//  soft colour-coded cards, filter chips, a "Create Memory" FAB, gentle empty
//  state. Voice memories + printable export are placeholders (coming soon).
// =============================================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../models/journal_entry.dart';
import '../services/father_journal_store.dart';
import '../services/journal_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/remote/storage_service.dart';
import '../services/tools_store.dart';
import '../theme/app_theme.dart';
import '../widgets/journal/journal_create.dart';
import '../widgets/storage_image.dart';

/// Two ways to read the journal: a tidy grouped LIST, or a flip-through BOOKLET.
enum _JournalView { list, booklet }

/// How the list view buckets entries.
enum _GroupBy { month, week }

/// A journal entry tagged with its author, for the Combined (you + Dad) booklet.
/// `father == false` covers the mother's own entries (manual + auto).
typedef _AE = ({JournalEntry e, bool father});

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  JournalFilter _filter = JournalFilter.all;
  bool _searching = false;
  String _query = '';
  final _searchCtrl = TextEditingController();
  final AudioPlayer _voicePlayer = AudioPlayer();
  String? _playingPath;

  // View state: tidy grouped list (default) vs the flip-through booklet.
  _JournalView _view = _JournalView.list;
  _GroupBy _groupBy = _GroupBy.month;
  final Set<String> _expanded = {};
  bool _groupsTouched = false; // false → default (only most-recent group open)
  final PageController _bookCtrl = PageController();

  // Combined (you + Dad) booklet — a separate mode, reached via its own app-bar
  // icon. Father entries surface ONLY here; her List/Booklet stay her own.
  bool _combined = false;
  final PageController _combinedBookCtrl = PageController();

  PregnancyController get p => widget.controller;

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];

  // A warmer, deeper shadow so a booklet page reads as a real sheet of paper
  // resting on the backdrop (keeps even a sparse page feeling tactile).
  static const List<BoxShadow> _paperShadow = [
    BoxShadow(color: Color(0x336B4E2E), blurRadius: 22, offset: Offset(0, 12)),
    BoxShadow(color: Color(0x16000000), blurRadius: 5, offset: Offset(0, 2)),
  ];

  @override
  void initState() {
    super.initState();
    // Load the father's journal so the Combined view has his entries available.
    FatherJournalStore.instance.init();
    _voicePlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _playingPath = null);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _voicePlayer.dispose();
    _bookCtrl.dispose();
    _combinedBookCtrl.dispose();
    super.dispose();
  }

  Future<void> _playVoice(String ref) async {
    if (_playingPath == ref) {
      await _voicePlayer.stop();
      if (mounted) setState(() => _playingPath = null);
      return;
    }
    await _voicePlayer.stop();
    // Resolve the reference to a local file (downloads from Storage if needed).
    final file = await StorageService.resolve(ref);
    if (file == null) return;
    await _voicePlayer.play(DeviceFileSource(file.path));
    if (mounted) setState(() => _playingPath = ref);
  }

  String _fmtTime(DateTime d) {
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final mm = d.minute.toString().padLeft(2, '0');
    return '$h:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        JournalStore.instance,
        FatherJournalStore.instance,
        ToolsStore.instance,
        p
      ]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(p.language);
    Iterable<JournalEntry> items = JournalStore.instance.timeline(p);
    if (_filter != JournalFilter.all) {
      items = items.where((e) => metaFor(e.type).filter == _filter);
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q));
    }
    final list = items.toList();

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: _searching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: s.jrSearchHint,
                  border: InputBorder.none,
                ),
              )
            : Text(s.jrTitle,
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700, color: AppTheme.primary900)),
        actions: [
          if (!_searching && !_combined)
            IconButton(
              tooltip: _view == _JournalView.list
                  ? s.jrBookletView
                  : s.jrListView,
              icon: Icon(_view == _JournalView.list
                  ? Icons.menu_book_rounded
                  : Icons.view_agenda_rounded),
              onPressed: () => setState(() => _view = _view == _JournalView.list
                  ? _JournalView.booklet
                  : _JournalView.list),
            ),
          // Combined (you + Dad) booklet — its own toggle.
          if (!_searching)
            IconButton(
              tooltip: _combined ? 'My journal' : 'Combined · you + Dad',
              icon: Icon(_combined
                  ? Icons.people_alt_rounded
                  : Icons.people_alt_outlined),
              onPressed: () => setState(() => _combined = !_combined),
            ),
          IconButton(
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _query = '';
                _searchCtrl.clear();
              }
            }),
          ),
          if (!_searching)
            IconButton(
              tooltip: s.jrInfoTitle,
              icon: const Icon(Icons.info_outline_rounded),
              onPressed: () => _infoSheet(s),
            ),
          if (!_searching)
            IconButton(
              tooltip: s.jrExport,
              icon: const Icon(Icons.ios_share_rounded),
              onPressed: () => _snack(s.jrExportSoon),
            ),
        ],
      ),
      body: _combined
          ? _booklet(s, _combinedItems(), ctrl: _combinedBookCtrl, combined: true)
          : (_view == _JournalView.booklet
              ? Column(children: [
                  _filters(s),
                  Expanded(
                      child: _booklet(
                          s, [for (final e in list) (e: e, father: false)],
                          ctrl: _bookCtrl)),
                ])
              : Column(children: [
                  _filters(s),
                  if (_filter != JournalFilter.photos) _groupByBar(s),
                  Expanded(
                    child: list.isEmpty
                        ? _empty(s)
                        : (_filter == JournalFilter.photos
                            ? _photoGrid(s, list)
                            : _groupedList(s, list)),
                  ),
                ])),
      // Just a "+" — the create options open on tap (the long label was
      // spilling out of the button).
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(s),
        backgroundColor: AppTheme.primary500,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  // --- filter chips ----------------------------------------------------------
  Widget _filters(S s) {
    final chips = <(JournalFilter, String)>[
      (JournalFilter.all, s.jrFilterAll),
      (JournalFilter.memories, s.jrFilterMemories),
      (JournalFilter.photos, s.jrFilterPhotos),
      (JournalFilter.milestones, s.jrFilterMilestones),
      (JournalFilter.health, s.jrFilterHealth),
      (JournalFilter.scans, s.jrFilterScans),
      (JournalFilter.baby, s.jrFilterBaby),
    ];
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          for (final c in chips) ...[
            _chip(c.$2, _filter == c.$1, () => _setFilter(c.$1)),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  void _setFilter(JournalFilter f) => setState(() {
        _filter = f;
        _groupsTouched = false;
        _expanded.clear();
      });

  // --- group-by control (list view) -----------------------------------------
  Widget _groupByBar(S s) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
        child: Row(children: [
          Text(s.jrGroupBy,
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral500)),
          const SizedBox(width: 10),
          _seg(s.jrByMonth, _groupBy == _GroupBy.month,
              () => _setGroupBy(_GroupBy.month)),
          const SizedBox(width: 8),
          _seg(s.jrByWeek, _groupBy == _GroupBy.week,
              () => _setGroupBy(_GroupBy.week)),
        ]),
      );

  Widget _seg(String label, bool sel, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: sel
                ? AppTheme.primary500.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
                color: sel
                    ? AppTheme.primary500.withValues(alpha: 0.4)
                    : AppTheme.outlineVariant),
          ),
          child: Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sel ? AppTheme.primary600 : AppTheme.neutral500)),
        ),
      );

  void _setGroupBy(_GroupBy g) => setState(() {
        _groupBy = g;
        _groupsTouched = false;
        _expanded.clear();
      });

  // --- grouped + collapsible list (default tidy view) ------------------------
  Widget _groupedList(S s, List<JournalEntry> list) {
    // Bucket by the chosen period. `list` is newest-first, so first-seen key
    // order is newest-first.
    String keyOf(JournalEntry e) => _groupBy == _GroupBy.month
        ? '${e.date.year}-${e.date.month.toString().padLeft(2, '0')}'
        : (e.weekNumber > 0
            ? 'w${e.weekNumber.toString().padLeft(3, '0')}'
            : 'd${e.date.year}-${e.date.month}-${e.date.day}');
    final groups = <String, List<JournalEntry>>{};
    for (final e in list) {
      groups.putIfAbsent(keyOf(e), () => []).add(e);
    }
    final keys = groups.keys.toList();

    bool isOpen(String k) =>
        _groupsTouched ? _expanded.contains(k) : (k == keys.first);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 2, 16, 100),
      children: [
        for (final k in keys) ...[
          _groupHeaderFor(s, groups[k]!, isOpen(k), () => _toggleGroup(k, keys)),
          if (isOpen(k)) ...[
            // MONTH view: segregate the month's entries into WEEK sections so
            // each week stands apart; WEEK view lists the cards directly.
            if (_groupBy == _GroupBy.month)
              ..._monthWeekSections(s, groups[k]!)
            else
              for (final e in groups[k]!) _card(s, e),
          ],
        ],
      ],
    );
  }

  // The collapsible header for a top-level group. Month → the month name only;
  // Week → "Week N" as the highlight with the date range as a smaller, lighter
  // sub-label.
  Widget _groupHeaderFor(
      S s, List<JournalEntry> es, bool open, VoidCallback onTap) {
    if (_groupBy == _GroupBy.month) {
      return _groupHeader(s.jrMonthYear(es.first.date), es.length, open, onTap);
    }
    if (es.first.weekNumber > 0) {
      final dates = es.map((e) => e.date).toList()..sort();
      return _groupHeader(
          s.jrWeekLabel(es.first.weekNumber), es.length, open, onTap,
          subLabel: s.jrDayRange(dates.first, dates.last));
    }
    return _groupHeader(s.formatShortDate(es.first.date), es.length, open, onTap);
  }

  // Inside a month: split its entries into per-week sections (newest week
  // first), each introduced by a small week sub-header.
  List<Widget> _monthWeekSections(S s, List<JournalEntry> monthEntries) {
    final byWeek = <String, List<JournalEntry>>{};
    for (final e in monthEntries) {
      final key = e.weekNumber > 0
          ? 'w${e.weekNumber.toString().padLeft(3, '0')}'
          : 'd${e.date.year}-${e.date.month}-${e.date.day}';
      byWeek.putIfAbsent(key, () => []).add(e);
    }
    final out = <Widget>[];
    for (final entries in byWeek.values) {
      final first = entries.first;
      if (first.weekNumber > 0) {
        final dates = entries.map((e) => e.date).toList()..sort();
        out.add(_weekSubHeader(s.jrWeekLabel(first.weekNumber),
            s.jrDayRange(dates.first, dates.last)));
      } else {
        out.add(_weekSubHeader(s.formatShortDate(first.date), ''));
      }
      for (final e in entries) {
        out.add(_card(s, e));
      }
    }
    return out;
  }

  // A light, non-collapsible week divider used inside the month view. "Week N"
  // is the highlight; the date range is the smaller, muted sub-highlight.
  Widget _weekSubHeader(String weekLabel, String dateRange) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 10, 6, 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(weekLabel,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary600)),
            if (dateRange.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(dateRange,
                  style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral400)),
            ],
          ],
        ),
      );

  Widget _groupHeader(String label, int count, bool open, VoidCallback onTap,
          {String? subLabel}) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(top: 12, bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _soft,
          ),
          child: Row(children: [
            // Title (the highlight) + an optional date-range sub-label that is
            // deliberately smaller + lighter so it never competes with it.
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary900)),
                  ),
                  if (subLabel != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(subLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutral400)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: AppTheme.primary500.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99)),
              child: Text('$count',
                  style: GoogleFonts.manrope(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary600)),
            ),
            const SizedBox(width: 8),
            AnimatedRotation(
              turns: open ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.neutral400),
            ),
          ]),
        ),
      );

  void _toggleGroup(String k, List<String> keys) => setState(() {
        if (!_groupsTouched) {
          // Seed with the current default (most-recent open) before the user's
          // first manual toggle, so other groups keep their state.
          _groupsTouched = true;
          if (keys.isNotEmpty) _expanded.add(keys.first);
        }
        if (!_expanded.remove(k)) _expanded.add(k);
      });

  Widget _chip(String label, bool sel, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: sel ? AppTheme.primary500 : AppTheme.surface,
            borderRadius: BorderRadius.circular(99),
            boxShadow: sel ? null : _soft,
          ),
          child: Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: sel ? Colors.white : AppTheme.neutral600)),
        ),
      );

  // --- timeline (grouped by day) — replaced by _groupedList; kept for revert.
  // ignore: unused_element
  Widget _timeline(S s, List<JournalEntry> list) {
    final groups = <String, List<JournalEntry>>{};
    for (final e in list) {
      groups.putIfAbsent(s.formatShortDate(e.date), () => []).add(e);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Text(entry.key,
                style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.neutral500,
                    letterSpacing: 0.3)),
          ),
          for (final e in entry.value) _card(s, e),
        ],
      ],
    );
  }

  Widget _card(S s, JournalEntry e) {
    final m = metaFor(e.type);
    final images = e.images;
    final audios = e.audios;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _soft,
        border: Border(left: BorderSide(color: m.color, width: 3)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        // Manual entries: tap to edit, long-press to delete. Auto entries and
        // the partner's entries (read-only in the merged view) aren't editable.
        onTap: (e.isAutomatic || e.isPartner)
            ? null
            : () => editJournalEntry(context, p, e),
        onLongPress:
            (e.isAutomatic || e.isPartner) ? null : () => _confirmDelete(s, e),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: m.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(m.icon, size: 19, color: m.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary900)),
                        if (e.description.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(e.description,
                              style: GoogleFonts.manrope(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: AppTheme.neutral600)),
                        ],
                        if (e.isPartner) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: m.color.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite_rounded,
                                    size: 11, color: m.color),
                                const SizedBox(width: 4),
                                Text('From ${p.fatherName}',
                                    style: GoogleFonts.manrope(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: m.color)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (e.weekNumber > 0) _weekBadge(s, e.weekNumber),
                      const SizedBox(height: 4),
                      // Per-entry date + time, so each memory shows WHEN it was
                      // made (the group header only gives the period range).
                      Text(s.formatShortDate(e.date),
                          style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.neutral500)),
                      Text(_fmtTime(e.createdAt),
                          style: GoogleFonts.manrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutral400)),
                    ],
                  ),
                ],
              ),
              if (e.type == JournalEntryType.custom &&
                  e.customTag.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _tagChip(e.customTag, m.color),
                ),
              ],
              if (images.isNotEmpty) ...[
                const SizedBox(height: 12),
                _imageCarousel(images),
              ],
              if (audios.isNotEmpty) ...[
                const SizedBox(height: 12),
                _voiceCarousel(s, audios),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagChip(String tag, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99)),
        child: Text('#$tag',
            style: GoogleFonts.manrope(
                fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
      );

  // One photo → a single banner; multiple → a horizontal carousel.
  Widget _imageCarousel(List<String> paths) {
    if (paths.length == 1) {
      return StorageImage(
        paths.first,
        height: 170,
        width: double.infinity,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(14),
      );
    }
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => StorageImage(
          paths[i],
          width: 132,
          height: 132,
          fit: BoxFit.cover,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Voice notes as a carousel of play chips.
  Widget _voiceCarousel(S s, List<String> paths) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final playing = _playingPath == paths[i];
          return GestureDetector(
            onTap: () => _playVoice(paths[i]),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: AppTheme.primary500.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                    playing
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    size: 18,
                    color: AppTheme.primary500),
                const SizedBox(width: 6),
                Text('${s.jcVoiceNote} ${i + 1}',
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary600)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _weekBadge(S s, int w) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(s.jrWeekLabel(w),
            style: GoogleFonts.manrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary600)),
      );

  // --- photo grid ------------------------------------------------------------
  Widget _photoGrid(S s, List<JournalEntry> list) {
    final photos = <String>[];
    for (final e in list) {
      photos.addAll(e.images);
    }
    if (photos.isEmpty) return _empty(s);
    return GridView.count(
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        for (final path in photos)
          StorageImage(
            path,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(14),
          ),
      ],
    );
  }

  // --- combined (you + Dad) data ---------------------------------------------
  // Her full timeline (memories + auto milestones/health/scans) merged with the
  // father's manual entries, each tagged with its author, newest first.
  List<_AE> _combinedItems() {
    final out = <_AE>[
      for (final e in JournalStore.instance.timeline(p)) (e: e, father: false),
      for (final e in FatherJournalStore.instance.entries) (e: e, father: true),
    ];
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? out
        : out
            .where((ae) =>
                ae.e.title.toLowerCase().contains(q) ||
                ae.e.description.toLowerCase().contains(q))
            .toList();
    filtered.sort((a, b) => b.e.date.compareTo(a.e.date));
    return filtered;
  }

  // A small "You" / "Dad" pill shown on each entry in the Combined booklet.
  Widget _authorChip(bool father) {
    final c = father ? const Color(0xFF2E5266) : AppTheme.primary500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          color: c.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(99)),
      child: Text(father ? 'Dad' : 'You',
          style: GoogleFonts.manrope(
              fontSize: 10, fontWeight: FontWeight.w800, color: c)),
    );
  }

  // --- booklet view (flip through, like a real diary) ------------------------
  // Drives both the mother-only booklet and the Combined (you + Dad) booklet:
  // entries are wrapped as ({e, father}) so a Combined page can chip each one.
  Widget _booklet(S s, List<_AE> list,
      {required PageController ctrl, bool combined = false}) {
    final chrono = list.reversed.toList(); // earliest → latest
    final byDay = <String, List<_AE>>{};
    for (final ae in chrono) {
      final e = ae.e;
      byDay
          .putIfAbsent('${e.date.year}-${e.date.month}-${e.date.day}', () => [])
          .add(ae);
    }
    final days = byDay.keys.toList();
    if (days.isEmpty) return _empty(s);
    final pages = 1 + days.length;
    return Stack(children: [
      // Warm "linen / desk" backdrop so the cream pages sit ON something and
      // never feel like they're floating on a bare canvas (esp. when sparse).
      const Positioned.fill(child: _BookletBackdrop()),
      PageView.builder(
        controller: ctrl,
        itemCount: pages,
        itemBuilder: (context, i) => AnimatedBuilder(
          animation: ctrl,
          builder: (context, child) {
            final t = (i - _pageOf(ctrl)).clamp(-1.0, 1.0);
            return Opacity(
              opacity: (1 - t.abs() * 0.55).clamp(0.0, 1.0),
              child: Transform(
                alignment:
                    t >= 0 ? Alignment.centerLeft : Alignment.centerRight,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0014)
                  ..rotateY(-t * 0.5),
                child: Transform.scale(scale: 1 - t.abs() * 0.07, child: child),
              ),
            );
          },
          child: i == 0
              ? _bookletCover(s, chrono, combined: combined)
              : _bookletPage(s, byDay[days[i - 1]]!, combined: combined),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 14,
        child: AnimatedBuilder(
          animation: ctrl,
          builder: (context, _) {
            final cur = _pageOf(ctrl).round();
            return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _bookArrow(Icons.chevron_left_rounded, cur > 0,
                  () => ctrl.previousPage(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeInOut)),
              const SizedBox(width: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: _soft),
                child: Text('${cur + 1} / $pages',
                    style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutral600)),
              ),
              const SizedBox(width: 14),
              _bookArrow(Icons.chevron_right_rounded, cur < pages - 1,
                  () => ctrl.nextPage(
                      duration: const Duration(milliseconds: 340),
                      curve: Curves.easeInOut)),
            ]);
          },
        ),
      ),
    ]);
  }

  double _pageOf(PageController c) {
    if (!c.hasClients) return 0;
    return c.page ?? 0;
  }

  Widget _bookArrow(IconData icon, bool enabled, VoidCallback onTap) =>
      GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              boxShadow: _soft),
          child: Icon(icon,
              color: enabled ? AppTheme.primary500 : AppTheme.neutral300),
        ),
      );

  Widget _coverBlob(double d, Color c) => Container(
      width: d,
      height: d,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _bookletCover(S s, List<_AE> entries, {bool combined = false}) {
    final weeks = entries.map((x) => x.e.weekNumber).where((w) => w > 0).toList()
      ..sort();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 60),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), boxShadow: _paperShadow),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary500, AppTheme.primary700],
              ),
            ),
            child: Stack(children: [
              Positioned(
                  right: -34,
                  top: -34,
                  child: _coverBlob(150, Colors.white.withValues(alpha: 0.10))),
              Positioned(
                  left: -24,
                  bottom: -24,
                  child: _coverBlob(
                      120, AppTheme.secondary300.withValues(alpha: 0.22))),
              // a quiet inset frame for a more "bound diary cover" feel
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(13),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.32),
                          width: 1.2),
                    ),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.auto_stories_rounded,
                        color: Colors.white, size: 46),
                    const SizedBox(height: 18),
                    Text(s.jrCoverTitle(p.motherName),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.fraunces(
                            fontSize: 28,
                            fontWeight: FontWeight.w500,
                            height: 1.15,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Container(
                      width: 44,
                      height: 2,
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    if (combined) ...[
                      const SizedBox(height: 10),
                      Text('You + Dad',
                          style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9))),
                    ],
                    if (weeks.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(s.jrCoverWeeks(weeks.first, weeks.last),
                          style: GoogleFonts.manrope(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85))),
                    ],
                    const SizedBox(height: 24),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(s.jrCoverHint,
                          style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white.withValues(alpha: 0.9))),
                      const Icon(Icons.chevron_right_rounded,
                          color: Colors.white, size: 18),
                    ]),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _bookletPage(S s, List<_AE> es, {bool combined = false}) {
    final date = es.first.e.date;
    final wk = es.fold(0, (a, ae) => ae.e.weekNumber > a ? ae.e.weekNumber : a);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 60),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFFBF7EF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEADFCB)),
          boxShadow: _paperShadow,
        ),
        child: Stack(children: [
          // faint ruled-paper texture so a near-empty page still reads as paper
          const Positioned.fill(
              child: CustomPaint(painter: _PaperLinesPainter())),
          // a soft botanical watermark resting in the lower corner
          Positioned(
            right: 6,
            bottom: 2,
            child: Icon(Icons.spa_rounded,
                size: 124,
                color: AppTheme.secondary500.withValues(alpha: 0.05)),
          ),
          // notebook margin line
          Positioned(
            left: 40,
            top: 14,
            bottom: 14,
            child: Container(
                width: 1.5,
                color: AppTheme.secondary500.withValues(alpha: 0.25)),
          ),
          // a little ribbon-bookmark down the top-right edge
          const Positioned(top: 0, right: 28, child: _BookmarkRibbon()),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(54, 22, 18, 22),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  s.jrWeekdayDate(date) +
                      (wk > 0 ? ' · ${s.jrWeekLabel(wk)}' : ''),
                  style: GoogleFonts.fraunces(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary900)),
              const SizedBox(height: 6),
              Container(height: 1, color: const Color(0xFFEADFCB)),
              const SizedBox(height: 14),
              for (final ae in es) _bookletEntry(s, ae, combined: combined),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _bookletEntry(S s, _AE ae, {bool combined = false}) {
    final e = ae.e;
    final m = metaFor(e.type);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(m.icon, size: 16, color: m.color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(e.title,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
          ),
          if (combined) ...[
            _authorChip(ae.father),
            const SizedBox(width: 8),
          ],
          Text(_fmtTime(e.createdAt),
              style: GoogleFonts.manrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral400)),
        ]),
        if (e.description.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(e.description,
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  height: 1.55,
                  color: const Color(0xFF5B5142))),
        ],
        if (e.images.isNotEmpty) ...[
          const SizedBox(height: 10),
          _imageCarousel(e.images),
        ],
        if (e.audios.isNotEmpty) ...[
          const SizedBox(height: 10),
          _voiceCarousel(s, e.audios),
        ],
      ]),
    );
  }

  // --- empty state (filter-aware: explains where each category fills from) ----
  Widget _empty(S s) {
    final isAll = _filter == JournalFilter.all;
    final (IconData icon, String body) = switch (_filter) {
      JournalFilter.all => (Icons.auto_stories_rounded, s.jrEmptyBody),
      JournalFilter.memories => (Icons.auto_stories_rounded, s.jrEmptyMemories),
      JournalFilter.photos => (Icons.photo_rounded, s.jrEmptyPhotos),
      JournalFilter.milestones =>
        (Icons.emoji_events_rounded, s.jrEmptyMilestones),
      JournalFilter.health => (Icons.monitor_heart_rounded, s.jrEmptyHealth),
      JournalFilter.scans => (Icons.medical_services_rounded, s.jrEmptyScans),
      JournalFilter.baby => (Icons.favorite_rounded, s.jrEmptyBaby),
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: AppTheme.primary50, shape: BoxShape.circle),
              child: Icon(icon, size: 38, color: AppTheme.primary400),
            ),
            const SizedBox(height: 18),
            if (isAll) ...[
              Text(s.jrEmptyTitle,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fraunces(
                      fontSize: 21,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary900)),
              const SizedBox(height: 8),
            ],
            Text(body,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    fontSize: 13.5, height: 1.5, color: AppTheme.neutral600)),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () => _infoSheet(s),
              icon: const Icon(Icons.info_outline_rounded, size: 16),
              label: Text(s.jrInfoTitle),
            ),
          ],
        ),
      ),
    );
  }

  // Explains where each category's entries come from (and why some sit empty).
  void _infoSheet(S s) {
    Color col(JournalEntryType t) => metaFor(t).color;
    Widget row(IconData icon, Color c, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: c, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 7),
                  child: Text(text,
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.neutral700)),
                ),
              ),
            ],
          ),
        );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
        child: SafeArea(
          top: false,
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
                      borderRadius: BorderRadius.circular(99)),
                ),
              ),
              const SizedBox(height: 16),
              Text(s.jrInfoTitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 6),
              Text(s.jrInfoIntro,
                  style: GoogleFonts.manrope(
                      fontSize: 13, height: 1.45, color: AppTheme.neutral600)),
              const SizedBox(height: 12),
              row(Icons.auto_stories_rounded, col(JournalEntryType.memory),
                  s.jrSrcMemories),
              row(Icons.favorite_rounded, col(JournalEntryType.noteForBaby),
                  s.jrSrcBaby),
              row(Icons.photo_rounded, col(JournalEntryType.photo),
                  s.jrSrcPhotos),
              row(Icons.emoji_events_rounded, col(JournalEntryType.milestone),
                  s.jrSrcMilestones),
              row(Icons.monitor_heart_rounded, col(JournalEntryType.weight),
                  s.jrSrcHealth),
              row(Icons.medical_services_rounded, col(JournalEntryType.scan),
                  s.jrSrcScans),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // --- create flow -----------------------------------------------------------
  void _openCreate(S s) {
    Widget opt(IconData icon, Color c, String label, VoidCallback onTap) =>
        ListTile(
          leading: Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: c),
          ),
          title: Text(label,
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, color: AppTheme.primary900)),
          onTap: onTap,
        );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99)),
              ),
              const SizedBox(height: 10),
              opt(Icons.edit_note_rounded, const Color(0xFFE0921C),
                  s.jrWriteMemory, () {
                Navigator.pop(ctx);
                openJournalText(context, p, JournalEntryType.memory);
              }),
              opt(Icons.favorite_rounded, const Color(0xFF4F7A52),
                  s.jrNoteForBaby, () {
                Navigator.pop(ctx);
                openJournalText(context, p, JournalEntryType.noteForBaby);
              }),
              opt(Icons.add_a_photo_rounded, const Color(0xFFFF5A79),
                  s.jrAddPhoto, () {
                Navigator.pop(ctx);
                openJournalAddPhoto(context, p);
              }),
              opt(Icons.mic_rounded, const Color(0xFF4A7BC8), s.jrRecordVoice,
                  () {
                Navigator.pop(ctx);
                openJournalRecordVoice(context, p);
              }),
              // Custom-tag entry removed per request (the enum + existing custom
              // entries are kept; only creating new ones is gone).
              // opt(Icons.label_rounded, AppTheme.primary500, s.jcCustom, () {
              //   Navigator.pop(ctx);
              //   openJournalText(context, p, JournalEntryType.custom);
              // }),
            ],
          ),
        ),
      ),
    );
  }

  // Text / photo / voice / custom create + edit flows now live in
  // widgets/journal/journal_create.dart (shared with the Home daily section).

  void _confirmDelete(S s, JournalEntry e) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.jrDeleteEntryQ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          TextButton(
            onPressed: () {
              JournalStore.instance.deleteEntry(e.id);
              Navigator.pop(ctx);
            },
            child: Text(s.delete,
                style: const TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ---------------------------------------------------------------------------
//  Booklet decoration — backdrop, ruled-paper texture, ribbon bookmark.
//  Quiet, low-opacity warm elements so even a single-entry page feels cosy.
// ---------------------------------------------------------------------------

/// A warm linen/desk backdrop the cream pages rest on.
class _BookletBackdrop extends StatelessWidget {
  const _BookletBackdrop();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEFE7D8), Color(0xFFE2D4BD)],
          ),
        ),
        // a faint top glow so the surface isn't flat
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.1,
              colors: [Color(0x16FFFFFF), Color(0x00FFFFFF)],
            ),
          ),
          child: SizedBox.expand(),
        ),
      );
}

/// Faint horizontal ruled lines, like notebook paper.
class _PaperLinesPainter extends CustomPainter {
  const _PaperLinesPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFEADFCB).withValues(alpha: 0.5)
      ..strokeWidth = 1;
    const gap = 30.0;
    for (double y = 46; y < size.height - 6; y += gap) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 16, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A small ribbon bookmark that hangs from the top edge of a page.
class _BookmarkRibbon extends StatelessWidget {
  const _BookmarkRibbon();
  @override
  Widget build(BuildContext context) => const SizedBox(
        width: 16,
        height: 52,
        child: CustomPaint(painter: _RibbonPainter()),
      );
}

class _RibbonPainter extends CustomPainter {
  const _RibbonPainter();
  @override
  void paint(Canvas canvas, Size size) {
    const notch = 12.0;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width / 2, size.height - notch)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = AppTheme.secondary500);
    // a thin highlight down the centre for a touch of dimension
    canvas.drawLine(
      Offset(size.width / 2, 2),
      Offset(size.width / 2, size.height - notch - 2),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
