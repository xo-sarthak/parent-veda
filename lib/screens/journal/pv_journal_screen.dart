// =============================================================================
//  My Journal — the pregnancy keepsake, redrawn (2026-09-23)
// -----------------------------------------------------------------------------
//  The user: *"I was never the fan of the designs that we have for the journal
//  right now."* And the home's promise for it: *"Create a memory for your baby
//  to show when it grows up."*
//
//  WHAT WAS WRONG, seen on the phone before a line was written:
//    · a lavender page, purple chips, a purple FAB — the palette thrown at
//      her, which the base UI retired everywhere else (DESIGN-SYSTEM §4.0);
//    · five icons in the app bar, so the title truncated to "M…";
//    · emoji inside milestone titles ("🌿 First Trimester Complete 🎉");
//    · every entry a boxed card with a coloured left edge — the boxed list
//      the user rejected ("squishes everything into between", §4.13);
//    · months as accordions, when a pregnancy is counted in WEEKS;
//    · an entry with no words and no photo drew as an empty card with an
//      icon in it, and said nothing about how to fill it;
//    · tap = edit, long-press = delete: no way to simply READ a memory.
//
//  THE SHAPE, from Mobbin (2026-09-23):
//    · 5 Minute Journal — a date block on the left (weekday over the day),
//      a small grey eyebrow, the words in a serif, and a large photo when
//      there is one. Rows on the page, no boxes.
//    · Retro — "Week to Week": the week is the unit a keepsake is kept in.
//    · Apple Journal — a voice note sits in the entry as a player with a
//      waveform, beside the photos, not as a separate kind of page.
//    · Journal's and Tolan's entry pages — open an entry to READ it: photo
//      first, date, title, words; edit lives behind the menu.
//
//  WHAT DID NOT CHANGE: the data. `JournalStore.timeline` is read exactly as
//  before (her entries, auto milestones, weight logs), every entry opens the
//  same compose screen to edit, and the old screen — with its flip-through
//  book and the "you + Dad" book — is `JournalScreenClassic`, reached from
//  this screen's menu. Nothing she has kept moves or changes shape.
// =============================================================================

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../data/journal_prompts.dart';
import '../../data/preg_size_sets.dart' show pregSizeFor;
import '../../data/reads/read_images.dart' show readImageFor;
import '../../models/journal_entry.dart';
import '../../services/bump_store.dart';
import '../../services/journal_store.dart';
import '../../services/preg_size_set_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/remote/storage_service.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/journal/journal_create.dart'
    show editJournalEntry, openJournalRecordVoice;
import '../../widgets/pv_feedback.dart';
import '../../widgets/storage_image.dart';
import '../journal_compose_screen.dart' show openJournalCompose;
import '../journal_screen.dart' show JournalScreenClassic;
import '../v2/v2_palette.dart';
import '../v2/v3_tip_art.dart' show V3TipArt;

/// The one line the journal exists to keep. Also the home section's title.
const String kJournalPromise =
    'Create a memory for your baby to show when it grows up.';

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July', //
  'August', 'September', 'October', 'November', 'December',
];
const _days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

String _shortMonth(int m) => _months[m - 1].substring(0, 3);

String _clock(DateTime d) {
  final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  return '$h:${d.minute.toString().padLeft(2, '0')} ${d.hour < 12 ? 'am' : 'pm'}';
}

/// "15–21 Sep", or "29 Sep – 5 Oct" across a month.
String _range(DateTime a, DateTime b) => a.month == b.month
    ? '${a.day}–${b.day} ${_shortMonth(b.month)}'
    : '${a.day} ${_shortMonth(a.month)} – ${b.day} ${_shortMonth(b.month)}';

/// ⚠️ NO DECORATIVE EMOJI (repo rule). Auto milestones are built as
/// "🌿  First Trimester Complete" from the Journey library, which is shared
/// with the map and keeps its emoji there. The journal draws the words only.
String journalPlain(String s) => s
    .replaceAll(
        RegExp(r'[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{FE0F}\u{200D}]',
            unicode: true),
        '')
    .replaceAll(RegExp(r'\s{2,}'), ' ')
    .trim();

/// What kind of thing an entry is, in the words the eyebrow uses.
String journalKind(JournalEntry e) => switch (e.type) {
      JournalEntryType.voice => 'Voice note',
      JournalEntryType.photo => 'Photo',
      JournalEntryType.noteForBaby => 'Note for your baby',
      JournalEntryType.milestone => 'Milestone',
      JournalEntryType.weight => 'Weight',
      JournalEntryType.kick => 'Movements',
      JournalEntryType.symptom => 'How you felt',
      JournalEntryType.scan => 'Scan',
      JournalEntryType.custom =>
        e.customTag.trim().isEmpty ? 'Memory' : e.customTag.trim(),
      JournalEntryType.memory => 'Memory',
    };

/// The pregnancy week an entry belongs to. Its own `weekNumber` when that is
/// a real week; otherwise the week its DATE falls in. Found on the phone: a
/// row saved without a week (the column defaults to 0) filed her one memory
/// under "Week 0", dated "30 Jun – 6 Jul", at the very bottom (2026-09-23).
int journalWeekOf(JournalEntry e, PregnancyController p) {
  if (e.weekNumber >= 1 && e.weekNumber <= 42) return e.weekNumber;
  return ((p.dayForDate(e.date) - 1) ~/ 7 + 1).clamp(1, 40);
}

/// The calendar days of pregnancy week [w]: days (w-1)*7+1 to w*7, the same
/// count `currentWeek`, `currentDay` and `dayForDate` use.
///
/// ⚠️ NOT `PregnancyController.weekDates`. That one starts week 40 ON the due
/// date, so every range it gives is a week late — on the phone, "Week 14 ·
/// 29 Sep – 5 Oct" on the day that WAS week 14 day 1, 23 Sep (2026-09-23).
/// It is left alone here because the weekly stack reads it too; see
/// STILL-OPEN §77.5.
({DateTime start, DateTime end}) journalWeekRange(PregnancyController p, int w) {
  final wk = w.clamp(1, 40);
  return (start: p.dateForDay((wk - 1) * 7 + 1), end: p.dateForDay(wk * 7));
}

/// A time worth showing: not the midnight a date-only entry carries.
bool _hasTime(DateTime d) => d.hour != 0 || d.minute != 0;

/// An entry she kept with nothing in it — no words, no photo, no voice. It
/// is still hers, so it is drawn (never hidden) and says how to fill it.
bool journalIsEmpty(JournalEntry e) =>
    e.title.trim().isEmpty &&
    e.description.trim().isEmpty &&
    e.images.isEmpty &&
    e.audios.isEmpty;

/// The filters, in the words a person would use. `JournalFilter` is the
/// identity; these are only labels.
const Map<JournalFilter, String> _filterLabels = {
  JournalFilter.all: 'All',
  JournalFilter.memories: 'Memories',
  JournalFilter.photos: 'Photos',
  JournalFilter.baby: 'Notes for baby',
  JournalFilter.milestones: 'Milestones',
  JournalFilter.health: 'Health',
  JournalFilter.scans: 'Scans',
};

// =============================================================================
//  The journal
// -----------------------------------------------------------------------------
//  ⚠️ A PLACE SHE WANTS TO OPEN, NOT A LIST SHE HAS TO KEEP (2026-09-23,
//  second pass the same day). The first redraw was clean and the user called
//  it exactly that: "very clean… not something she would be like, let's open
//  it." What the journals people keep opening have, on Mobbin, and a list
//  does not:
//
//    1. A COVER. stoic.'s Journey, Apple Journal, 5 Minute Journal: the first
//       thing is a picture — hers when she has one (her newest photo, from a
//       memory or a bump photo), a painting when she does not — with "Dear
//       little one," over it. The journal is a book addressed to someone.
//    2. WHERE SHE IS IN IT. one year's 365 dots, as forty weeks: the weeks she
//       kept something in are ink, this week is ringed. ⚠️ NOT A STREAK — it
//       never counts a gap, never says "missed", never totals anything but
//       the weeks until she meets them.
//    3. A QUESTION FOR THIS WEEK. A blank page makes her decide what is worth
//       keeping; a question tied to her week does that for her
//       (`journal_prompts.dart` — questions a grown child would want answered).
//    4. HER WEEKS AS PAGES. A week with a photo becomes the photo (stoic.'s
//       week card); the rest are the rows.
//
//  MOTION, because this is the one screen that should feel like opening
//  something: the cover drifts slower than the page (parallax) and softens as
//  it goes; the forty weeks fill in one by one on open; the week pages rise
//  in turn; a photo travels from its row into the entry (Hero); another
//  question turns in. All of it is under a second and none of it repeats.
// =============================================================================

/// The journal's paper. ⚠️ THE ONE PAGE THAT IS NOT WHITE, ON PURPOSE: a
/// keepsake is paper (5 Minute Journal, the storybook journal's `jvPaper`), and
/// the white cards on it read as pages laid on a table. One constant — white
/// again is one edit.
const Color kJournalPaper = Color(0xFFFAF7F2);

/// The painting's warm accent — the tip card's sun.
const Color _warm = Color(0xFFC9831F);

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen>
    with SingleTickerProviderStateMixin {
  JournalFilter _filter = JournalFilter.all;
  bool _searching = false;
  String _query = '';
  int _skip = 0; // "another question"
  final _searchCtrl = TextEditingController();
  final _voice = JournalVoicePlayer();
  final _scroll = ScrollController();
  bool _collapsed = false;

  /// The floating "Add a memory" waits until the question card — which has
  /// its own Write it — has scrolled away. On the phone it sat on top of the
  /// card, two ways to write covering each other (2026-09-23).
  bool _fab = false;

  /// One clock for the opening: the forty weeks fill, then the pages rise.
  late final AnimationController _open = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..forward();

  static const double _coverHeight = 420;

  PregnancyController get p => widget.controller;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      final c = _scroll.hasClients &&
          _scroll.offset > _coverHeight - kToolbarHeight - 40;
      final f = _scroll.hasClients && _scroll.offset > _coverHeight + 360;
      if (c != _collapsed || f != _fab) {
        setState(() {
          _collapsed = c;
          _fab = f;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _voice.dispose();
    _scroll.dispose();
    _open.dispose();
    super.dispose();
  }

  void _addMemory({String? prompt}) =>
      openJournalCompose(context, p, prompt: prompt);
  void _addVoice() => openJournalRecordVoice(context, p);

  void _openClassic({bool book = false, bool withDad = false}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'journal/book'),
        builder: (_) => JournalScreenClassic(
            controller: p, startInBook: book, startCombined: withDad),
      ));

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge([
          JournalStore.instance,
          ToolsStore.instance,
          BumpStore.instance,
          V2PaletteStore.instance,
          _voice,
          p,
        ]),
        builder: (context, _) => _build(context),
      );

  /// Her newest photograph — from a memory or a bump photo, whichever is
  /// later. Null when she has none: the cover paints instead.
  String? _coverPhoto(List<JournalEntry> mine) {
    String? best;
    DateTime? at;
    for (final e in mine) {
      if (e.images.isEmpty) continue;
      if (at == null || e.date.isAfter(at)) {
        at = e.date;
        best = e.images.first;
      }
    }
    final bump = BumpStore.instance.latest;
    if (bump != null && (at == null || bump.date.isAfter(at))) {
      best = bump.imageUrl;
    }
    return best;
  }

  /// A week's photograph: the first in her entries that week, else her bump
  /// photo for that week.
  String? _weekPhoto(int week, List<JournalEntry> entries) {
    for (final e in entries) {
      if (e.images.isNotEmpty && !e.isAutomatic) return e.images.first;
    }
    for (final b in BumpStore.instance.photos) {
      if (b.weekNumber == week) return b.imageUrl;
    }
    return null;
  }

  Widget _build(BuildContext context) {
    final pal = V2PaletteStore.instance.current;
    final all = JournalStore.instance.timeline(p);
    final present = {for (final e in all) metaFor(e.type).filter};
    final mine = all.where((e) => !e.isAutomatic).toList();

    Iterable<JournalEntry> items = all;
    if (_filter != JournalFilter.all) {
      items = items.where((e) => metaFor(e.type).filter == _filter);
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      items = items.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q) ||
          (e.place ?? '').toLowerCase().contains(q));
    }
    final list = items.toList();

    final byWeek = <int, List<JournalEntry>>{};
    for (final e in list) {
      byWeek.putIfAbsent(journalWeekOf(e, p), () => []).add(e);
    }
    final filtered = _filter != JournalFilter.all || q.isNotEmpty;
    if (!filtered) byWeek.putIfAbsent(p.currentWeek, () => []);
    final weeks = byWeek.keys.toList()..sort((a, b) => b.compareTo(a));

    // The weeks she kept something of her own in — the ink dots.
    final kept = {for (final e in mine) journalWeekOf(e, p)};
    for (final b in BumpStore.instance.photos) {
      kept.add(b.weekNumber);
    }

    final cover = _coverPhoto(mine);
    final onPhoto = cover != null && !_collapsed;
    final barInk = onPhoto ? Colors.white : pal.ink1;

    return Scaffold(
      backgroundColor: kJournalPaper,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _searching
          ? null
          : AnimatedSlide(
              offset: _fab ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              child: AnimatedOpacity(
              opacity: _fab ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: FloatingActionButton.extended(
              heroTag: 'journal_add',
              onPressed: () {
                pvCommitFeedback();
                _addMemory();
              },
              backgroundColor: pal.ink1,
              foregroundColor: pal.surface,
              elevation: 2,
              shape: const StadiumBorder(),
              icon: const Icon(Icons.add_rounded),
              label: Text('Add a memory',
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            ),
            ),
      body: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: _searching ? 0 : _coverHeight,
            backgroundColor: kJournalPaper,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            foregroundColor: barInk,
            iconTheme: IconThemeData(color: barInk, shadows: [
              if (onPhoto) const Shadow(color: Colors.black38, blurRadius: 8),
            ]),
            title: _searching
                ? TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: (v) => setState(() => _query = v),
                    style: pvManrope(fontSize: 16, color: pal.ink1),
                    decoration: InputDecoration(
                      hintText: 'Search your journal',
                      hintStyle: pvManrope(fontSize: 16, color: pal.ink3),
                      border: InputBorder.none,
                    ),
                  )
                : AnimatedOpacity(
                    opacity: _collapsed ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text('My Journal',
                        style: pvFraunces(fontSize: 20, color: pal.ink1)),
                  ),
            actions: [
              IconButton(
                tooltip: _searching ? 'Close search' : 'Search',
                icon: Icon(
                    _searching ? Icons.close_rounded : Icons.search_rounded),
                onPressed: () => setState(() {
                  _searching = !_searching;
                  if (!_searching) {
                    _query = '';
                    _searchCtrl.clear();
                  }
                }),
              ),
              if (!_searching)
                PopupMenuButton<String>(
                  tooltip: 'More',
                  icon: const Icon(Icons.more_horiz_rounded),
                  color: pal.surface,
                  onSelected: (v) => switch (v) {
                    'book' => _openClassic(book: true),
                    'dad' => _openClassic(withDad: true),
                    'voice' => _addVoice(),
                    _ => _about(pal),
                  },
                  itemBuilder: (_) => [
                    _menu('voice', Icons.mic_none_rounded, 'Add a voice note', pal),
                    _menu('book', Icons.menu_book_outlined, 'Read it as a book', pal),
                    _menu('dad', Icons.people_outline_rounded,
                        "With your partner's entries", pal),
                    _menu('about', Icons.info_outline_rounded,
                        'About your journal', pal),
                  ],
                ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: _searching
                ? null
                : FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    stretchModes: const [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                    ],
                    background: _Cover(
                      pal: pal,
                      photo: cover,
                      trimester: p.currentWeek <= 13
                          ? 1
                          : (p.currentWeek <= 27 ? 2 : 3),
                      name: p.myName,
                      week: p.currentWeek,
                    ),
                  ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_searching) ...[
                  const SizedBox(height: 22),
                  _FortyWeeks(
                    pal: pal,
                    current: p.currentWeek,
                    kept: kept,
                    open: _open,
                  ),
                  const SizedBox(height: 26),
                  _QuestionCard(
                    pal: pal,
                    week: p.currentWeek,
                    skip: _skip,
                    onWrite: (q) => _addMemory(prompt: q),
                    onSay: _addVoice,
                    onAnother: () => setState(() => _skip++),
                  ),
                  const SizedBox(height: 30),
                ],
                _Filters(
                  pal: pal,
                  present: present,
                  selected: _filter,
                  onSelect: (f) => setState(() => _filter = f),
                ),
              ],
            ),
          ),
          if (_filter == JournalFilter.photos)
            SliverToBoxAdapter(
              child: _PhotoGrid(
                  pal: pal, entries: list, onOpen: (e) => _openEntry(e)),
            )
          else if (weeks.isEmpty)
            SliverToBoxAdapter(
                child: _NothingFound(pal: pal, searching: q.isNotEmpty))
          else
            SliverList.builder(
              itemCount: weeks.length,
              itemBuilder: (_, i) {
                final w = weeks[i];
                final entries = byWeek[w]!;
                return _Rise(
                  open: _open,
                  index: i,
                  child: _WeekSection(
                    pal: pal,
                    week: w,
                    current: w == p.currentWeek,
                    range: journalWeekRange(p, w),
                    entries: entries,
                    photo: _weekPhoto(w, entries),
                    voice: _voice,
                    onOpen: _openEntry,
                    onAdd: () => _addMemory(
                        prompt: journalPromptFor(p.currentWeek, skip: _skip)),
                  ),
                );
              },
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menu(
          String v, IconData icon, String label, V2Palette pal) =>
      PopupMenuItem(
        value: v,
        child: Row(children: [
          Icon(icon, size: 20, color: pal.ink1),
          const SizedBox(width: 12),
          Text(label, style: pvManrope(fontSize: 14.5, color: pal.ink1)),
        ]),
      );

  void _openEntry(JournalEntry e) {
    if (journalIsEmpty(e) && !e.isAutomatic && !e.isPartner) {
      // Nothing to read yet — straight to filling it.
      journalEdit(context, p, e);
      return;
    }
    Navigator.of(context).push(PageRouteBuilder<void>(
      settings: const RouteSettings(name: 'journal/entry'),
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => JournalEntryScreen(pregnancy: p, entry: e),
      // A page laid down, not a screen pushed: it fades in while the photo
      // travels (Hero), rather than sliding over from the side.
      transitionsBuilder: (_, a, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: a, curve: Curves.easeOutCubic),
        child: child,
      ),
    ));
  }

  void _about(V2Palette pal) => showModalBottomSheet<void>(
        context: context,
        backgroundColor: pal.surface,
        showDragHandle: true,
        builder: (ctx) => Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About your journal',
                  style: pvFraunces(fontSize: 22, color: pal.ink1)),
              const SizedBox(height: 12),
              for (final line in const [
                'Everything you add stays yours, kept by the week it happened in.',
                'Milestones and the weight you log join it on their own, so the '
                    'weeks you did not write in still have something in them.',
                'The forty dots are your pregnancy. A filled one is a week you '
                    'kept something in. They are not a score, and an empty one '
                    'is not a miss.',
                'After the birth it is still here — a record your child can read '
                    'one day.',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(line,
                      style: pvManrope(
                          fontSize: 14.5, height: 1.5, color: pal.ink2)),
                ),
            ],
          ),
        ),
      );
}

/// Edit a journal entry the way it was made: a memory in the compose screen
/// (photos, place, words — the same screen that created it), a voice note or
/// a legacy photo entry in its caption sheet.
Future<void> journalEdit(
    BuildContext context, PregnancyController p, JournalEntry e) {
  switch (e.type) {
    case JournalEntryType.memory:
    case JournalEntryType.noteForBaby:
    case JournalEntryType.custom:
      return openJournalCompose(context, p, edit: e);
    default:
      return editJournalEntry(context, p, e);
  }
}

/// Rise into place in turn: the [index]th item fades and lifts 18pt, starting
/// a beat after the one before. Only the first few are staggered — anything
/// further down is off screen when the page opens and simply appears.
class _Rise extends StatelessWidget {
  const _Rise({required this.open, required this.index, required this.child});
  final Animation<double> open;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (0.35 + 0.08 * index.clamp(0, 6)).clamp(0.0, 0.85);
    final a = CurvedAnimation(
        parent: open,
        curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: a,
      builder: (_, c) => Opacity(
        opacity: a.value,
        child: Transform.translate(offset: Offset(0, 18 * (1 - a.value)), child: c),
      ),
      child: child,
    );
  }
}

// =============================================================================
//  The cover
// =============================================================================

class _Cover extends StatelessWidget {
  const _Cover({
    required this.pal,
    required this.photo,
    required this.trimester,
    required this.name,
    required this.week,
  });

  final V2Palette pal;
  final String? photo;
  final int trimester;
  final String? name;
  final int week;

  @override
  Widget build(BuildContext context) {
    // A painting for the trimester when she has no photograph: the user's own
    // artwork once it is in the table (`journal_cover_t1..3`), the drawn sky
    // until then.
    final painted = readImageFor('journal_cover_t$trimester');
    final dark = photo != null || painted != null;
    final ink = dark ? Colors.white : pal.ink1;
    final soft = dark ? Colors.white.withValues(alpha: 0.82) : pal.ink2;
    final who = (name ?? '').trim();

    return Stack(fit: StackFit.expand, children: [
      if (photo != null)
        StorageImage(photo!, fit: BoxFit.cover)
      else if (painted != null)
        Image.network(painted,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => V3TipArt(
                variant: trimester + 2, ink: pal.ink1, accent: _warm))
      else
        V3TipArt(variant: trimester + 2, ink: pal.ink1, accent: _warm),
      if (dark)
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.3, 0.55, 1],
              colors: [
                Color(0x59000000),
                Color(0x00000000),
                Color(0x14000000),
                Color(0xB3000000),
              ],
            ),
          ),
        )
      else
        // The painting fades into the paper, so the page continues from it.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.55, 1],
              colors: [Color(0x00FAF7F2), kJournalPaper],
            ),
          ),
        ),
      Positioned(
        left: 22,
        right: 22,
        bottom: 26,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MY JOURNAL  ·  WEEK $week',
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: soft)),
            const SizedBox(height: 8),
            Text('Dear little one,',
                style: pvFraunces(
                    fontSize: 40,
                    height: 1.05,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.6,
                    color: ink)),
            const SizedBox(height: 10),
            Text(
                who.isEmpty
                    ? 'Everything I kept for you while I waited.'
                    : 'Everything I kept for you while I waited.  — $who',
                style: pvManrope(fontSize: 15, height: 1.4, color: soft)),
          ],
        ),
      ),
    ]);
  }
}

// =============================================================================
//  Forty weeks
// =============================================================================

class _FortyWeeks extends StatelessWidget {
  const _FortyWeeks({
    required this.pal,
    required this.current,
    required this.kept,
    required this.open,
  });

  final V2Palette pal;
  final int current;
  final Set<int> kept;
  final Animation<double> open;

  @override
  Widget build(BuildContext context) {
    final left = (40 - current).clamp(0, 40);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Week $current',
                  style: pvFraunces(fontSize: 22, color: pal.ink1)),
              Text(' of 40',
                  style: pvFraunces(fontSize: 22, color: pal.ink3)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                    left == 0
                        ? 'Any day now'
                        : (left == 1
                            ? 'A week until you meet'
                            : '$left weeks until you meet'),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 13, color: pal.ink2)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Two rows of twenty. Each dot pops in on its own beat as the page
          // opens — the first 40% of the opening clock.
          LayoutBuilder(builder: (context, box) {
            final gap = (box.maxWidth - 20 * 11) / 19;
            return Column(children: [
              for (var row = 0; row < 2; row++) ...[
                if (row == 1) const SizedBox(height: 10),
                Row(children: [
                  for (var i = 0; i < 20; i++) ...[
                    if (i > 0) SizedBox(width: gap),
                    _dot(row * 20 + i + 1),
                  ],
                ]),
              ],
            ]);
          }),
          const SizedBox(height: 12),
          Wrap(spacing: 14, runSpacing: 6, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              _key(pal.ink1, filled: true),
              const SizedBox(width: 6),
              Text('A week you kept something in',
                  style: pvManrope(fontSize: 11.5, color: pal.ink3)),
            ]),
            Row(mainAxisSize: MainAxisSize.min, children: [
              _key(pal.action, filled: false),
              const SizedBox(width: 6),
              Text('This week',
                  style: pvManrope(fontSize: 11.5, color: pal.ink3)),
            ]),
          ]),
        ],
      ),
    );
  }

  Widget _key(Color c, {required bool filled}) => Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: filled ? c : null,
          shape: BoxShape.circle,
          border: filled ? null : Border.all(color: c, width: 1.6),
        ),
      );

  Widget _dot(int w) {
    final isNow = w == current;
    // A week not yet reached cannot hold something she kept — a dot there
    // would read as a mistake (it was one: test data dated ahead of her).
    final has = w <= current && kept.contains(w);
    final past = w < current;
    final t = (w - 1) / 40 * 0.4;
    final a = CurvedAnimation(
        parent: open,
        curve: Interval(t, (t + 0.18).clamp(0.0, 1.0), curve: Curves.easeOutBack));
    final Color fill = has
        ? pal.ink1
        : (past ? pal.ink3.withValues(alpha: 0.28) : Colors.transparent);
    return AnimatedBuilder(
      animation: a,
      builder: (_, _) => Transform.scale(
        scale: a.value.clamp(0.0, 1.2),
        child: Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: isNow && !has ? null : fill,
            shape: BoxShape.circle,
            border: isNow
                ? Border.all(color: pal.action, width: 2)
                : (past || has
                    ? null
                    : Border.all(color: pal.ink3.withValues(alpha: 0.35))),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  This week's question
// =============================================================================

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.pal,
    required this.week,
    required this.skip,
    required this.onWrite,
    required this.onSay,
    required this.onAnother,
  });

  final V2Palette pal;
  final int week;
  final int skip;
  final ValueChanged<String> onWrite;
  final VoidCallback onSay;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final q = journalPromptFor(week, skip: skip);
    final size = pregSizeFor(week, PregSizeSetStore.instance.set);
    final tri = week <= 13 ? 1 : (week <= 27 ? 2 : 3);
    final art = readImageFor('journal_question_t$tri');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: pal.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 132,
              width: double.infinity,
              child: art != null
                  ? Image.network(art,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => V3TipArt(
                          variant: week, ink: pal.ink1, accent: _warm))
                  : V3TipArt(variant: week, ink: pal.ink1, accent: _warm),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text("THIS WEEK'S QUESTION",
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                              color: pal.action)),
                    ),
                    if (journalPromptCount(week) > 1)
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: IconButton(
                          tooltip: 'Another question',
                          padding: EdgeInsets.zero,
                          onPressed: onAnother,
                          icon: AnimatedRotation(
                            turns: skip * 0.5,
                            duration: const Duration(milliseconds: 380),
                            curve: Curves.easeOutCubic,
                            child: Icon(Icons.refresh_rounded,
                                size: 20, color: pal.ink2),
                          ),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 6),
                  // Another question turns in: the old one slides up and out,
                  // the new one rises into its place.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 380),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0, 0.25), end: Offset.zero)
                            .animate(a),
                        child: child,
                      ),
                    ),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: Alignment.topLeft,
                      children: [...previous, ?current],
                    ),
                    child: Text(q,
                        key: ValueKey(q),
                        style: pvFraunces(
                            fontSize: 23,
                            height: 1.3,
                            letterSpacing: -0.2,
                            color: pal.ink1)),
                  ),
                  if (size != null) ...[
                    const SizedBox(height: 10),
                    Text(
                        'Your baby is ${size.line.replaceFirst('About', 'about')} this week.',
                        style: pvManrope(
                            fontSize: 13.5,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                            color: pal.ink2)),
                  ],
                  const SizedBox(height: 18),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    FilledButton(
                      onPressed: () {
                        pvCommitFeedback();
                        onWrite(q);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: pal.ink1,
                        foregroundColor: pal.surface,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: const StadiumBorder(),
                        textStyle: pvManrope(
                            fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Write it'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onSay,
                      icon: const Icon(Icons.mic_none_rounded, size: 18),
                      label: const Text('Say it'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: pal.ink1,
                        side: BorderSide(color: pal.line),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: const StadiumBorder(),
                        textStyle: pvManrope(
                            fontSize: 14.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
//  Filters — only the kinds she actually has, selected in ink
// =============================================================================

class _Filters extends StatelessWidget {
  const _Filters({
    required this.pal,
    required this.present,
    required this.selected,
    required this.onSelect,
  });

  final V2Palette pal;
  final Set<JournalFilter> present;
  final JournalFilter selected;
  final ValueChanged<JournalFilter> onSelect;

  @override
  Widget build(BuildContext context) {
    // A chip for a kind she has none of filters to nothing — so it is not
    // offered. `All` always is; so is whichever one is selected.
    final shown = [
      for (final f in JournalFilter.values)
        if (f == JournalFilter.all || f == selected || present.contains(f)) f,
    ];
    if (shown.length <= 2 && selected == JournalFilter.all) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: shown.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = shown[i];
          final on = f == selected;
          return ChoiceChip(
            label: Text(_filterLabels[f]!),
            selected: on,
            showCheckmark: false,
            onSelected: (_) => onSelect(f),
            labelStyle: pvManrope(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: on ? pal.surface : pal.ink1),
            color: WidgetStatePropertyAll(on ? pal.ink1 : kJournalPaper),
            side: BorderSide(color: on ? pal.ink1 : pal.line),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          );
        },
      ),
    );
  }
}

// =============================================================================
//  One week
// =============================================================================

class _WeekSection extends StatelessWidget {
  const _WeekSection({
    required this.pal,
    required this.week,
    required this.current,
    required this.range,
    required this.entries,
    required this.photo,
    required this.voice,
    required this.onOpen,
    required this.onAdd,
  });

  final V2Palette pal;
  final int week;
  final bool current;
  final ({DateTime start, DateTime end}) range;
  final List<JournalEntry> entries;
  final String? photo;
  final JournalVoicePlayer voice;
  final ValueChanged<JournalEntry> onOpen;
  final VoidCallback onAdd;

  String get _summary {
    final memories = entries.where((e) => !e.isAutomatic).length;
    final voices = entries.fold<int>(0, (n, e) => n + e.audios.length);
    // Each kind by its own name — a weight log was counted as a milestone.
    final milestones =
        entries.where((e) => e.type == JournalEntryType.milestone).length;
    final notes = entries
        .where((e) => e.isAutomatic && e.type != JournalEntryType.milestone)
        .length;
    return [
      if (memories > 0) '$memories ${memories == 1 ? 'memory' : 'memories'}',
      if (voices > 0) '$voices ${voices == 1 ? 'voice note' : 'voice notes'}',
      if (milestones > 0)
        '$milestones ${milestones == 1 ? 'milestone' : 'milestones'}',
      if (notes > 0) '$notes ${notes == 1 ? 'health note' : 'health notes'}',
    ].join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    final size = pregSizeFor(week, PregSizeSetStore.instance.set);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photo != null)
            // stoic.'s week card: the week IS its photograph.
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 11,
                child: Stack(fit: StackFit.expand, children: [
                  StorageImage(photo!, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.45, 1],
                        colors: [Color(0x00000000), Color(0xA6000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            _range(range.start, range.end).toUpperCase() +
                                (current ? '  ·  THIS WEEK' : ''),
                            style: pvManrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: Colors.white.withValues(alpha: 0.85))),
                        const SizedBox(height: 4),
                        Text('Week $week',
                            style: pvFraunces(
                                fontSize: 32, height: 1.1, color: Colors.white)),
                        if (_summary.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(_summary,
                              style: pvManrope(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.9))),
                        ],
                      ],
                    ),
                  ),
                ]),
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('Week $week',
                    style: pvFraunces(
                        fontSize: 28, letterSpacing: -0.3, color: pal.ink1)),
                const SizedBox(width: 10),
                if (current)
                  Text('THIS WEEK',
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: pal.action)),
                // The range gives way first — the week number never does.
                Expanded(
                  child: Text(_range(range.start, range.end),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12.5, color: pal.ink3)),
                ),
              ],
            ),
            if (size != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(size.line.replaceFirst('About', 'Baby, about'),
                    style: pvFraunces(
                        fontSize: 14.5,
                        fontStyle: FontStyle.italic,
                        color: pal.ink3)),
              ),
          ],
          const SizedBox(height: 4),
          if (entries.isEmpty)
            // ⚠️ A FEATURE IS NEVER HIDDEN. Her week with nothing in it asks,
            // once, in its own words — the question card above is the rest.
            InkWell(
              onTap: onAdd,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(children: [
                  Expanded(
                    child: Text(
                        'Nothing kept this week yet. Start with this week\'s '
                        'question, or anything at all.',
                        style: pvManrope(
                            fontSize: 14, height: 1.5, color: pal.ink2)),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.arrow_forward_rounded, size: 20, color: pal.ink1),
                ]),
              ),
            )
          else
            for (var i = 0; i < entries.length; i++) ...[
              if (i > 0 || photo == null)
                Divider(height: 1, thickness: 1, color: pal.line),
              JournalEntryRow(
                pal: pal,
                entry: entries[i],
                voice: voice,
                onTap: () => onOpen(entries[i]),
              ),
            ],
        ],
      ),
    );
  }
}

// =============================================================================
//  One entry, as a row on the page
// =============================================================================

class JournalEntryRow extends StatelessWidget {
  const JournalEntryRow({
    super.key,
    required this.pal,
    required this.entry,
    required this.voice,
    required this.onTap,
  });

  final V2Palette pal;
  final JournalEntry entry;
  final JournalVoicePlayer voice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final e = entry;
    final d = e.date;
    final title = journalPlain(e.title);
    final body = journalPlain(e.description);
    final empty = journalIsEmpty(e);
    final quiet = e.isAutomatic;
    final eyebrow = [
      journalKind(e).toUpperCase(),
      if (!e.isAutomatic && _hasTime(d)) _clock(d).toUpperCase(),
      if (e.isPartner) 'FROM YOUR PARTNER',
    ].join(' · ');

    return PvPress(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The date block — 5 Minute Journal's.
              SizedBox(
                width: 44,
                child: Column(children: [
                  Text(_days[d.weekday - 1],
                      style: pvManrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: pal.ink3)),
                  Text('${d.day}',
                      style: pvFraunces(
                          fontSize: 24, height: 1.15, color: pal.ink1)),
                ]),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(eyebrow,
                        style: pvManrope(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.9,
                            color: pal.ink3)),
                    const SizedBox(height: 5),
                    if (empty)
                      Text('A page with nothing on it yet — tap to add words '
                          'or a photo.',
                          style: pvManrope(
                              fontSize: 14,
                              height: 1.45,
                              fontStyle: FontStyle.italic,
                              color: pal.ink3)),
                    if (title.isNotEmpty)
                      Text(title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvFraunces(
                              fontSize: quiet ? 16.5 : 18.5,
                              height: 1.3,
                              color: pal.ink1)),
                    if (body.isNotEmpty) ...[
                      if (title.isNotEmpty) const SizedBox(height: 4),
                      Text(body,
                          maxLines: quiet ? 2 : 4,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 14, height: 1.5, color: pal.ink2)),
                    ],
                    if (e.images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _Photos(paths: e.images, heroId: e.id),
                    ],
                    if (e.audios.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      for (var i = 0; i < e.audios.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: JournalVoiceChip(
                            pal: pal,
                            ref: e.audios[i],
                            label: e.audios.length == 1
                                ? 'Voice note'
                                : 'Voice note ${i + 1}',
                            player: voice,
                          ),
                        ),
                    ],
                    if ((e.place ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.place_outlined, size: 14, color: pal.ink3),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(e.place!.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(fontSize: 12.5, color: pal.ink3)),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Hero tag a single-photo entry's picture flies under, from its row to
/// its page.
String journalHeroTag(String entryId) => 'journal_photo_$entryId';

/// One photo wide; two or three as a row of squares.
class _Photos extends StatelessWidget {
  const _Photos({required this.paths, required this.heroId});
  final List<String> paths;
  final String heroId;

  @override
  Widget build(BuildContext context) {
    if (paths.length == 1) {
      return AspectRatio(
        aspectRatio: 4 / 3,
        // The photo travels into the entry page (`journalHeroTag`).
        child: Hero(
          tag: journalHeroTag(heroId),
          child: StorageImage(paths.first,
              fit: BoxFit.cover, borderRadius: BorderRadius.circular(14)),
        ),
      );
    }
    return Row(children: [
      for (var i = 0; i < paths.length && i < 3; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: StorageImage(paths[i],
                fit: BoxFit.cover, borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    ]);
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid(
      {required this.pal, required this.entries, required this.onOpen});
  final V2Palette pal;
  final List<JournalEntry> entries;
  final ValueChanged<JournalEntry> onOpen;

  @override
  Widget build(BuildContext context) {
    final cells = [
      for (final e in entries)
        for (final path in e.images) (e: e, path: path),
    ];
    if (cells.isEmpty) return _NothingFound(pal: pal, searching: false);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cells.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, mainAxisSpacing: 6, crossAxisSpacing: 6),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => onOpen(cells[i].e),
          child: StorageImage(cells[i].path,
              fit: BoxFit.cover, borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}

class _NothingFound extends StatelessWidget {
  const _NothingFound({required this.pal, required this.searching});
  final V2Palette pal;
  final bool searching;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 36, 20, 0),
        child: Text(
            searching
                ? 'Nothing in your journal matches that.'
                : 'Nothing of this kind yet.',
            style: pvManrope(fontSize: 14.5, color: pal.ink2)),
      );
}

// =============================================================================
//  Voice notes — one player for the screen, a chip per note
// =============================================================================

/// Plays one voice note at a time. A ChangeNotifier so every chip on the
/// screen redraws when another starts.
class JournalVoicePlayer extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? playing;
  bool _disposed = false;

  JournalVoicePlayer() {
    _player.onPlayerComplete.listen((_) {
      playing = null;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> toggle(String ref) async {
    if (playing == ref) {
      await _player.stop();
      playing = null;
      notifyListeners();
      return;
    }
    await _player.stop();
    // A local path, or a Storage object fetched once and cached.
    final file = await StorageService.resolve(ref);
    if (file == null || _disposed) return;
    await _player.play(DeviceFileSource(file.path));
    playing = ref;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _player.dispose();
    super.dispose();
  }
}

/// Apple Journal's voice block: a play mark, a waveform, a label.
class JournalVoiceChip extends StatelessWidget {
  const JournalVoiceChip({
    super.key,
    required this.pal,
    required this.ref,
    required this.label,
    required this.player,
  });

  final V2Palette pal;
  final String ref;
  final String label;
  final JournalVoicePlayer player;

  @override
  Widget build(BuildContext context) {
    final on = player.playing == ref;
    // A waveform drawn from the note's own reference, so each note has its
    // own shape and the same note always has the same one.
    final seed = ref.codeUnits.fold<int>(7, (h, c) => (h * 31 + c) & 0x7fffffff);
    return Semantics(
      button: true,
      label: on ? 'Stop $label' : 'Play $label',
      child: InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: () => player.toggle(ref),
        child: Container(
          height: 44,
          padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
          decoration: BoxDecoration(
            border: Border.all(color: pal.line),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: pal.ink1, shape: BoxShape.circle),
              child: Icon(on ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  size: 20, color: pal.surface),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Row(children: [
                for (var i = 0; i < 28; i++)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2.5,
                        height: 5.0 + ((seed >> (i % 24)) ^ (i * 7)) % 17,
                        decoration: BoxDecoration(
                          color: on ? pal.ink1 : pal.ink3.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
              ]),
            ),
            const SizedBox(width: 10),
            Text(label,
                style: pvManrope(
                    fontSize: 12.5, fontWeight: FontWeight.w700, color: pal.ink1)),
          ]),
        ),
      ),
    );
  }
}

// =============================================================================
//  One entry, opened to read
// =============================================================================

class JournalEntryScreen extends StatefulWidget {
  const JournalEntryScreen(
      {super.key, required this.pregnancy, required this.entry});
  final PregnancyController pregnancy;
  final JournalEntry entry;

  @override
  State<JournalEntryScreen> createState() => _JournalEntryScreenState();
}

class _JournalEntryScreenState extends State<JournalEntryScreen> {
  final _voice = JournalVoicePlayer();
  int _photo = 0;

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  /// The entry as the store has it now — an edit made from this page shows
  /// here when she comes back. An auto entry is not in the manual list.
  JournalEntry get _e {
    for (final m in JournalStore.instance.manualEntries) {
      if (m.id == widget.entry.id) return m;
    }
    return widget.entry;
  }

  bool get _gone =>
      !widget.entry.isAutomatic &&
      !widget.entry.isPartner &&
      !JournalStore.instance.manualEntries.any((m) => m.id == widget.entry.id);

  Future<void> _delete(V2Palette pal) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: pal.surface,
        title: Text('Delete this memory?',
            style: pvFraunces(fontSize: 21, color: pal.ink1)),
        content: Text('It will be gone from your journal, and from the book.',
            style: pvManrope(fontSize: 14.5, height: 1.45, color: pal.ink2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Keep it', style: TextStyle(color: pal.ink1))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete',
                  style: TextStyle(color: Color(0xFFC0392B)))),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await JournalStore.instance.deleteEntry(widget.entry.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [JournalStore.instance, V2PaletteStore.instance, _voice]),
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final pal = V2PaletteStore.instance.current;
    if (_gone) return const Scaffold(backgroundColor: kJournalPaper);
    final e = _e;
    final d = e.date;
    final mine = !e.isAutomatic && !e.isPartner;
    final title = journalPlain(e.title);
    final body = journalPlain(e.description);
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', //
      'Sunday',
    ];

    return Scaffold(
      backgroundColor: kJournalPaper,
      appBar: AppBar(
        backgroundColor: kJournalPaper,
        surfaceTintColor: Colors.transparent,
        foregroundColor: pal.ink1,
        elevation: 0,
        actions: [
          if (mine)
            TextButton(
              onPressed: () => journalEdit(context, widget.pregnancy, e),
              child: Text('Edit',
                  style: pvManrope(
                      fontSize: 15, fontWeight: FontWeight.w700, color: pal.ink1)),
            ),
          if (mine)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () => _delete(pal),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 48),
        children: [
          if (e.images.isNotEmpty) ...[
            AspectRatio(
              aspectRatio: 4 / 5,
              child: PageView.builder(
                itemCount: e.images.length,
                onPageChanged: (i) => setState(() => _photo = i),
                itemBuilder: (_, i) {
                  final img = StorageImage(e.images[i],
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(18));
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: i == 0 && e.images.length == 1
                        ? Hero(tag: journalHeroTag(e.id), child: img)
                        : img,
                  );
                },
              ),
            ),
            if (e.images.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < e.images.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _photo ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _photo ? pal.ink1 : pal.line,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    [
                      '${weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]}',
                      'Week ${journalWeekOf(e, widget.pregnancy)}',
                      if (!e.isAutomatic && _hasTime(d)) _clock(d),
                    ].join('  ·  ').toUpperCase(),
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.9,
                        color: pal.ink3)),
                const SizedBox(height: 10),
                Text(title.isNotEmpty ? title : journalKind(e),
                    style: pvFraunces(
                        fontSize: 30, height: 1.2, letterSpacing: -0.3, color: pal.ink1)),
                if (body.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SelectableText(body,
                      style: pvManrope(fontSize: 16.5, height: 1.65, color: pal.ink1)),
                ],
                if (e.audios.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  for (var i = 0; i < e.audios.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: JournalVoiceChip(
                        pal: pal,
                        ref: e.audios[i],
                        label: e.audios.length == 1
                            ? 'Voice note'
                            : 'Voice note ${i + 1}',
                        player: _voice,
                      ),
                    ),
                ],
                if ((e.place ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(children: [
                    Icon(Icons.place_outlined, size: 16, color: pal.ink3),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(e.place!.trim(),
                          style: pvManrope(fontSize: 14, color: pal.ink2)),
                    ),
                  ]),
                ],
                if (e.isAutomatic) ...[
                  const SizedBox(height: 22),
                  Text(
                      'Added to your journal on its own, from your pregnancy. '
                      'It sits in the week it belongs to, beside what you kept.',
                      style: pvManrope(fontSize: 13, height: 1.5, color: pal.ink3)),
                ],
              ],
            ),
          ),
          _TheRestOfTheWeek(
            pal: pal,
            pregnancy: widget.pregnancy,
            entry: e,
            voice: _voice,
          ),
        ],
      ),
    );
  }
}

/// ⚠️ NO EMPTY SCREENS. A memory of one line opened to a page that was one
/// line over white (the phone, 2026-09-23). Under it now: the week it belongs
/// to — how big the baby was, and everything else she kept that week, each
/// one a tap away. A keepsake reads as a book because each page leads to the
/// next.
class _TheRestOfTheWeek extends StatelessWidget {
  const _TheRestOfTheWeek({
    required this.pal,
    required this.pregnancy,
    required this.entry,
    required this.voice,
  });

  final V2Palette pal;
  final PregnancyController pregnancy;
  final JournalEntry entry;
  final JournalVoicePlayer voice;

  @override
  Widget build(BuildContext context) {
    final p = pregnancy;
    final week = journalWeekOf(entry, p);
    final others = [
      for (final o in JournalStore.instance.timeline(p))
        if (o.id != entry.id && journalWeekOf(o, p) == week) o,
    ];
    final size = pregSizeFor(week, PregSizeSetStore.instance.set);
    final range = journalWeekRange(p, week);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(height: 1, thickness: 1, color: pal.line),
          const SizedBox(height: 26),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('Week $week',
                  style: pvFraunces(fontSize: 26, color: pal.ink1)),
              Expanded(
                child: Text(_range(range.start, range.end),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(fontSize: 12.5, color: pal.ink3)),
              ),
            ],
          ),
          if (size != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(size.line.replaceFirst('About', 'Baby, about'),
                  style: pvFraunces(
                      fontSize: 15, fontStyle: FontStyle.italic, color: pal.ink3)),
            ),
          const SizedBox(height: 8),
          if (others.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                  week == p.currentWeek
                      ? 'The only thing kept this week so far.'
                      : 'The only thing kept that week.',
                  style: pvManrope(fontSize: 14, color: pal.ink2)),
            )
          else ...[
            Text(others.length == 1 ? 'ALSO THAT WEEK' : 'ALSO THAT WEEK  ·  ${others.length} MORE',
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: pal.ink3)),
            for (var i = 0; i < others.length; i++) ...[
              if (i > 0) Divider(height: 1, thickness: 1, color: pal.line),
              JournalEntryRow(
                pal: pal,
                entry: others[i],
                voice: voice,
                // The next page replaces this one, so back returns to the
                // journal rather than walking back through every page read.
                onTap: () => Navigator.of(context).pushReplacement(
                  PageRouteBuilder<void>(
                    settings: const RouteSettings(name: 'journal/entry'),
                    transitionDuration: const Duration(milliseconds: 360),
                    pageBuilder: (_, _, _) =>
                        JournalEntryScreen(pregnancy: p, entry: others[i]),
                    transitionsBuilder: (_, a, _, child) =>
                        FadeTransition(opacity: a, child: child),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
