// =============================================================================
//  CalendarScreen - "My Calendar" (the pregnancy command center)
// -----------------------------------------------------------------------------
//  Three calm tabs: Journey Timeline (default), Calendar grid, and Upcoming -
//  with a subtle progress card, category filters, search, and mother-added
//  personal events. Answers: where am I, what's happened, what's next. Warm-Nest
//  visual language (no mockup existed; extrapolated). Reuses the shared event
//  assembly in CalendarStore.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the structural restyle). The calendar now
//  reads as the same app as trying to conceive's (`ttc_calendar_screen.dart`,
//  read for shape only, never imported):
//    * A pushed page with a back arrow and the serif page title. It was a bare
//      Container from the days it was a tab, so a push landed with no way back
//      but the system gesture and no Material under its search field.
//    * White cards with the hairline in place of plum-tinted shadows.
//    * The month sits on the page, its name large and left, the arrows two
//      round hairline buttons (TTC's grid).
//    * Rows that open an event carry a drawn mark in the category's hue.
//    * Group labels inside a list or a card are the small grey caps.
//    * No violet: the milestone colour from `calMeta` is the brand violet, so
//      this screen draws milestones in the ink (see [_catColor]).
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/calendar_event.dart';
import '../services/calendar_store.dart';
import '../services/journal_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/prepare_store.dart';
import '../services/scans_store.dart';
import '../services/tools_store.dart';
import '../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../theme/app_theme.dart';
import '../widgets/mic_dictation_button.dart';
import '../widgets/trimester_progress_bar.dart';
import 'brackets/hub/hub_intent_art.dart' show IntentMark;
import 'doors/pv_list_row.dart' show PvMarkWell;
import 'journal_screen.dart';
import 'pregnancy/preg_chrome.dart';
import 'products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import 'v2/v2_palette.dart' show V2Palette;
import 'weekly_card_stack_screen.dart';
import '../theme/pv_fonts.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _tab = 1; // open on the Calendar grid (0 Timeline · 1 Calendar · 2 Upcoming)
  CalEventCategory? _filter; // null = All
  bool _searching = false;
  String _query = '';
  final _searchCtrl = TextEditingController();
  late DateTime _month;
  DateTime? _selectedDay; // the day tapped in the grid (defaults to today)
  bool _legendOpen = false; // the collapsible colour-code legend

  // Tap-a-date → scroll the ListView to that day's detail panel (Task 2).
  final _scrollCtrl = ScrollController();
  final _detailsKey = GlobalKey();

  PregnancyController get p => widget.controller;

  V2Palette get _pal => pvStorePalette;

  // Kept for revert (2026-09-30, hairline cards, no plum shadow):
  // static const List<BoxShadow> _soft = [
  //   BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  // ];

  /// The one card surface: white, the page hairline. [ring] draws the ink
  /// border a current or selected thing wears instead of a tint.
  static BoxDecoration _card({double radius = 20, bool ring = false}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ring ? kPvInk : kPvLine, width: ring ? 1.5 : 1),
      );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // Animate the ListView so the selected-day detail panel comes into view.
  void _scrollToDetails() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _detailsKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        CalendarStore.instance,
        JournalStore.instance,
        ToolsStore.instance,
        ScansStore.instance,
        PrepareStore.instance, // enrolled programs feed the calendar
        p,
      ]),
      builder: (context, _) => _build(context),
    );
  }

  List<CalendarEvent> _filtered() {
    Iterable<CalendarEvent> ev = CalendarStore.instance.allEvents(p);
    // Task 4: ParentVeda recommendations are excluded from the Timeline,
    // Calendar and Upcoming views (this is the single choke point for all three).
    ev = ev.where((e) => e.category != CalEventCategory.parentveda);
    if (_filter != null) ev = ev.where((e) => e.category == _filter);
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      ev = ev.where((e) =>
          e.title.toLowerCase().contains(q) ||
          e.description.toLowerCase().contains(q));
    }
    return ev.toList();
  }

  Widget _build(BuildContext context) {
    final s = S(p.language);
    final events = _filtered();
    // A pushed page: the AppBar carries only the back arrow, the serif title
    // sits in the header below it. Kept for revert (2026-09-30):
    //   Container(color: AppTheme.surfaceContainer, child: SafeArea(
    //     bottom: false, child: Column(...)))
    return Scaffold(
      backgroundColor: _pal.ground,
      appBar: AppBar(
        backgroundColor: _pal.ground,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _pal.ink1,
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            _header(s),
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                // See tools_hub_screen.dart for why this is the constant and
                // not a hand-picked number: 110 left the last card under the
                // Ask Veda FAB.
                padding: const EdgeInsets.fromLTRB(16, 4, 16, kAskFabReserve),
                children: [
                  // Task 1: order is Trimester Progress → Calendar → Filters →
                  // Details. Progress sits at the very top (above the tab bar).
                  _progressCard(s),
                  const SizedBox(height: 16),
                  _segmented(s),
                  const SizedBox(height: 12),
                  if (_tab == 0) ...[
                    _filters(s),
                    const SizedBox(height: 6),
                    _timeline(s, events),
                  ],
                  if (_tab == 1) ...[
                    _calendar(s, events),
                    const SizedBox(height: 12),
                    _filters(s),
                    const SizedBox(height: 12),
                    _legend(s),
                    const SizedBox(height: 12),
                    _selectedDayPanel(s, events),
                  ],
                  if (_tab == 2) ...[
                    _filters(s),
                    const SizedBox(height: 6),
                    _upcoming(s, events),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- header ----------------------------------------------------------------
  Widget _header(S s) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 8, 6),
        child: Row(
          children: [
            Expanded(
              child: _searching
                  ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: pvManrope(fontSize: 16, color: _pal.ink1),
                      decoration: InputDecoration(
                          hintText: s.calSearchHint, border: InputBorder.none),
                    )
                  // The serif page title (was pvJakarta 22 / w700).
                  : Text(s.calTitle, style: pregPageTitleStyle()),
            ),
            IconButton(
              icon: Icon(
                  _searching ? Icons.close_rounded : Icons.search_rounded,
                  color: _pal.ink1),
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
                icon: Icon(Icons.add_circle_outline_rounded, color: _pal.ink1),
                tooltip: s.calAddPersonal,
                onPressed: () => _addPersonal(s),
              ),
          ],
        ),
      );

  // --- progress card ---------------------------------------------------------
  // Task 1: the top-of-screen progress now uses the shared TrimesterProgressBar
  // (horizontal, no percentages) for consistency with the rest of the app.
  Widget _progressCard(S s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: _card(),
      child: TrimesterProgressBar(
        week: p.currentWeek,
        daysRemaining: p.daysRemaining,
        lang: p.language,
      ),
    );
  }

  // Old circular-ring progress card - superseded by TrimesterProgressBar above,
  // kept for revert.
  // ignore: unused_element
  Widget _progressCardLegacy(S s) {
    final pct = p.progress;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: _card(radius: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.weekOf(p.currentWeek, 40),
                        style: pvJakarta(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neutral900)),
                    const SizedBox(height: 2),
                    Text('${s.calDaysTogether(p.daysCompleted)} ❤',
                        style: pvManrope(
                            fontSize: 12.5, color: AppTheme.neutral600)),
                  ],
                ),
              ),
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(alignment: Alignment.center, children: [
                  SizedBox(
                    width: 52,
                    height: 52,
                    child: CircularProgressIndicator(
                      value: pct,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      backgroundColor: AppTheme.neutral100,
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.neutral900),
                    ),
                  ),
                  Text('${p.progressPercent}%',
                      style: pvJakarta(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.neutral900)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(s.journeyDaysRemaining(p.daysRemaining),
              style: pvManrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral500)),
        ],
      ),
    );
  }

  // --- segmented control -----------------------------------------------------
  Widget _segmented(S s) {
    final tabs = [s.calTabTimeline, s.calTabCalendar, s.calTabUpcoming];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: _card(radius: 16),
      child: Row(
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i ? kPvInk : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tabs[i],
                      style: pvManrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _tab == i ? Colors.white : _pal.ink2)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- filters ---------------------------------------------------------------
  Widget _filters(S s) {
    // Task 7: visible chips are exactly All · Milestones · Appointments ·
    // Tests & Scans · Programs. Journal / Personal / ParentVeda are commented
    // out (their enum values are kept for revert).
    final chips = <(CalEventCategory?, String)>[
      (null, s.calFilterAll),
      (CalEventCategory.milestone, s.calFilterMilestones),
      (CalEventCategory.appointment, s.calFilterAppointments),
      // Task 3: "Medical" is displayed as "Tests & Scans" (enum stays `medical`).
      (CalEventCategory.medical,
          s.lang.isHinglish ? 'जाँच और स्कैन' : 'Tests & Scans'),
      (CalEventCategory.program,
          s.lang.isHinglish ? 'प्रोग्राम' : 'Programs'),
      // (CalEventCategory.journal, s.calFilterJournal),
      // (CalEventCategory.personal, s.calFilterPersonal),
      // (CalEventCategory.parentveda, s.calFilterParentveda),
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
                // A selected chip is the ink; the rest white with the
                // hairline (was a plum-tinted shadow).
                decoration: BoxDecoration(
                  color: _filter == c.$1 ? kPvInk : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: _filter == c.$1 ? null : Border.all(color: kPvLine),
                ),
                child: Text(c.$2,
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _filter == c.$1 ? Colors.white : _pal.ink1)),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  // --- TAB 1: Journey timeline ----------------------------------------------
  Widget _timeline(S s, List<CalendarEvent> events) {
    if (events.isEmpty) return _emptyNote(s.calTimelineEmpty);
    return Column(
      children: [
        const SizedBox(height: 8),
        for (final e in events) _timelineRow(s, e),
      ],
    );
  }

  Widget _timelineRow(S s, CalendarEvent e) {
    final cur = e.status == CalEventStatus.current;
    final done = e.status == CalEventStatus.completed;
    final dotColor = cur ? kPvInk : (done ? _green : AppTheme.neutral300);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // rail
          Column(
            children: [
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  color: done ? _green : (cur ? kPvInk : Colors.white),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                    : null,
              ),
              Expanded(child: Container(width: 2, color: kPvLine)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _eventSheet(s, e),
                // A white card with the hairline; "now" wears an ink ring,
                // not a tint behind its words, and the row leads with the
                // category's drawn mark. Kept for revert (2026-09-30):
                //   color: cur ? neutral900 @ 0.06 : AppTheme.surface,
                //   borderRadius 18, boxShadow: _soft,
                //   border: Border(left: BorderSide(color: m.color, width: 3)),
                //   and Icon(m.icon, size: 16, color: m.color) before the title.
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: _card(radius: 18, ring: cur),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _mark(e.category, 36),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Expanded(
                                child: Text(e.title,
                                    style: pvManrope(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        height: 1.25,
                                        color: _pal.ink1)),
                              ),
                              if (cur)
                                _pill(s.youAreHere, kPvInk, filled: true)
                              else if (done)
                                _pill(s.calStatusCompleted, _green)
                              else
                                _pill(s.calStatusUpcoming, _pal.ink3),
                            ]),
                            if (e.description.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(e.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvManrope(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: _pal.ink2)),
                            ],
                            const SizedBox(height: 5),
                            Text(s.formatShortDate(e.date),
                                style: pvManrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _pal.ink3)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // A tint is allowed on a pill. "You are here" is a badge, so it is the ink
  // with white words ([filled]).
  Widget _pill(String label, Color c, {bool filled = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: filled ? c : c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99)),
        child: Text(label,
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: filled ? Colors.white : c)),
      );

  // --- TAB 2: Calendar grid --------------------------------------------------
  Widget _calendar(S s, List<CalendarEvent> events) {
    final byDay = <String, List<CalendarEvent>>{};
    for (final e in events) {
      byDay.putIfAbsent(_key(e.date), () => []).add(e);
    }
    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = first.weekday % 7; // Sun=0
    final today = DateTime.now();
    final cells = <Widget>[];
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(_month.year, _month.month, d);
      final dayEvents = byDay[_key(date)] ?? const [];
      final isToday = date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
      cells.add(_dayCell(s, date, d, dayEvents, isToday));
    }

    // ⚠️ NO CARD ROUND THE MONTH (2026-09-30, TTC's grid): the month sits on
    // the page, its name large and left in the serif, the arrows two round
    // hairline buttons. Kept for revert: Container(margin top 8, padding 12,
    // AppTheme.surface, radius 22, boxShadow: _soft) round a Column of
    // Row(IconButton(chevron_left), centred pvJakarta 15 / w700 month,
    // IconButton(chevron_right)), then the weekday row and the grid.
    Widget arrow(IconData icon, int delta, String label) => Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => setState(
                () => _month = DateTime(_month.year, _month.month + delta)),
            customBorder: const CircleBorder(),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: kPvLine),
              ),
              child: Icon(icon, size: 20, color: _pal.ink1),
            ),
          ),
        );
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.calMonthYear(_month),
                    style: pvFraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.4,
                        color: _pal.ink1)),
              ),
              arrow(Icons.chevron_left_rounded, -1, 'Previous month'),
              const SizedBox(width: 8),
              arrow(Icons.chevron_right_rounded, 1, 'Next month'),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (final w in s.calWeekdayLetters)
                Expanded(
                  child: Center(
                    child: Text(w,
                        style: pvManrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _pal.ink3)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 0.72,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cells,
          ),
        ],
      ),
    );
  }

  Widget _dayCell(S s, DateTime date, int day, List<CalendarEvent> events,
      bool isToday) {
    final dots = <Color>[];
    for (final e in events) {
      final c = _catColor(e.category);
      if (!dots.contains(c) && dots.length < 3) dots.add(c);
    }
    // Descriptive markers: label the start of each pregnancy week (e.g. "21w"),
    // mark the due date ("Birth"), and softly highlight the current week.
    final wk = _weekAt(date);
    final prevWk = _weekAt(date.subtract(const Duration(days: 1)));
    final isDue = _sameDay(date, p.dueDate);
    final isWeekStart = wk >= 4 && wk <= 40 && wk != prevWk;
    final inCurrentWeek = wk == p.currentWeek && wk >= 4 && wk <= 40;
    final selected = _selectedDay != null && _sameDay(date, _selectedDay!);
    // A new trimester begins at week 14 (T2) and week 28 (T3); week 4 marks the
    // visible start of the journey (T1) - shown as a small pill on that day.
    final triStart = isWeekStart && (wk == 4 || wk == 14 || wk == 28);
    final tri = wk == 28 ? 3 : (wk == 14 ? 2 : 1);
    // Round only where the current-week band starts/stops on this calendar row,
    // so the highlight reads as one smooth band (not fused rounded squares).
    final col = date.weekday % 7; // Sun = 0 … Sat = 6
    final bandLeft = inCurrentWeek &&
        (col == 0 ||
            _weekAt(date.subtract(const Duration(days: 1))) != p.currentWeek);
    final bandRight = inCurrentWeek &&
        (col == 6 ||
            _weekAt(date.add(const Duration(days: 1))) != p.currentWeek);
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDay = date);
        // Task 2: if this date has events, scroll to its detail panel.
        if (events.isNotEmpty) _scrollToDetails();
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 13,
            child: isDue
                ? Center(child: _topTag(s.calChildbirth))
                : triStart
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                              color: _triColor(tri),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text(s.calTrimesterTag(tri),
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.visible,
                              style: pvManrope(
                                  fontSize: 7,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      )
                    : isWeekStart
                        ? Center(child: _topTag('${wk}w'))
                        : null,
          ),
          // The week band wraps the day number AND its event dots, so the dots
          // sit inside the highlight and clearly belong to the date.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: inCurrentWeek
                ? BoxDecoration(
                    color: const Color(0xFF4F7A52).withValues(alpha: 0.13),
                    borderRadius: BorderRadius.horizontal(
                      left: bandLeft ? const Radius.circular(18) : Radius.zero,
                      right:
                          bandRight ? const Radius.circular(18) : Radius.zero,
                    ),
                  )
                : null,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday
                      ? kPvInk
                      : (selected
                          ? kPvInk.withValues(alpha: 0.16)
                          : Colors.transparent),
                  shape: BoxShape.circle,
                  border: selected && !isToday
                      ? Border.all(color: kPvInk, width: 1.5)
                      : null,
                ),
                child: Text('$day',
                    style: pvManrope(
                        fontSize: 12.5,
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday ? Colors.white : _pal.ink1)),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final c in dots)
                      Container(
                        width: 5,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration:
                            BoxDecoration(color: c, shape: BoxShape.circle),
                      ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: Upcoming -------------------------------------------------------
  Widget _upcoming(S s, List<CalendarEvent> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Task 6: Upcoming includes ONLY Milestones, Appointments, Tests & Scans
    // (medical) and Programs - journal / personal / parentveda are excluded.
    const upcomingCats = {
      CalEventCategory.milestone,
      CalEventCategory.appointment,
      CalEventCategory.medical,
      CalEventCategory.program,
    };
    final future = events
        .where((e) => upcomingCats.contains(e.category))
        .where((e) => !DateTime(e.date.year, e.date.month, e.date.day)
            .isBefore(today))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    if (future.isEmpty) return _emptyNote(s.calUpcomingEmpty);

    int daysOut(CalendarEvent e) =>
        DateTime(e.date.year, e.date.month, e.date.day).difference(today).inDays;

    final thisWeek = future.where((e) => daysOut(e) <= 7).toList();
    final next2 = future.where((e) => daysOut(e) > 7 && daysOut(e) <= 14).toList();
    final thisMonth =
        future.where((e) => daysOut(e) > 14 && daysOut(e) <= 30).toList();
    final later = future.where((e) => daysOut(e) > 30).toList();

    // A group label inside the list is the small grey caps, and a group's
    // rows share one white card with hairlines between them. Kept for revert
    // (2026-09-30): the label in pvManrope 11.5 / w800 / 0.6 in neutral900,
    // and `for (final e in list) _upcomingRow(s, e)`, a shadowed card each.
    Widget group(String title, List<CalendarEvent> list) {
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
            child: Text(title.toUpperCase(), style: pregGroupLabelStyle()),
          ),
          PregRowCard(children: [
            for (final e in list) _inked(_upcomingOfferRow(s, e)),
          ]),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        group(s.calThisWeek, thisWeek),
        group(s.calNext2Weeks, next2),
        group(s.calThisMonth, thisMonth),
        group(s.calLater, later),
      ],
    );
  }

  // One upcoming event: the category's drawn mark, the title, "in N days".
  // It opens the event's sheet, as the old card did.
  Widget _upcomingOfferRow(S s, CalendarEvent e) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final n = DateTime(e.date.year, e.date.month, e.date.day)
        .difference(today)
        .inDays;
    return PregOfferRow(
      mark: _markOf(e.category),
      hue: _hueOf(e.category),
      title: e.title,
      line: s.calInDays(n),
      onTap: () => _eventSheet(s, e),
    );
  }

  // Superseded by [_upcomingOfferRow] in a [PregRowCard] (2026-09-30); kept
  // for revert.
  // ignore: unused_element
  Widget _upcomingRow(S s, CalendarEvent e) {
    final m = calMeta(e.category);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final n = DateTime(e.date.year, e.date.month, e.date.day)
        .difference(today)
        .inDays;
    return GestureDetector(
      onTap: () => _eventSheet(s, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: _card(radius: 18),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(m.icon, size: 20, color: m.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      style: pvJakarta(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.neutral900)),
                  const SizedBox(height: 2),
                  Text(s.calInDays(n),
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.neutral500)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.neutral400),
          ],
        ),
      ),
    );
  }

  // --- sheets ----------------------------------------------------------------
  // Superseded by the inline selected-day panel; kept for revert.
  // ignore: unused_element
  void _daySheet(S s, DateTime date, List<CalendarEvent> events) {
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;
    final week = _weekAt(date);
    final snap = (week >= 4 && week <= 40) ? p.weekData(week)?.snapshot : null;
    _sheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.formatLongDate(date),
              style: pvJakarta(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.neutral900)),
          if (week >= 4 && week <= 40) ...[
            const SizedBox(height: 4),
            Text('${s.weekWord} $week · ${s.trimesterName(week)}',
                style: pvManrope(
                    fontSize: 12.5, color: AppTheme.neutral600)),
          ],
          if (isToday && snap != null) ...[
            const SizedBox(height: 10),
            Text(s.babyIsSize(snap.fruit.of(p.language)),
                style: pvManrope(
                    fontSize: 13, color: AppTheme.neutral900)),
          ],
          const SizedBox(height: 14),
          if (events.isEmpty)
            Text(s.calNoEventsDay,
                style: pvManrope(
                    fontSize: 13, color: AppTheme.neutral500))
          else
            for (final e in events) _sheetEventRow(s, e),
        ],
      ),
    );
  }

  void _eventSheet(S s, CalendarEvent e) {
    _sheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            // The category's drawn mark (2026-09-30). Kept for revert: a 42
            // Container in m.color @ 0.12, radius 12, Icon(m.icon, 21, m.color).
            _mark(e.category, 44),
            const SizedBox(width: 12),
            Expanded(
              child: Text(e.title,
                  style: pvJakarta(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: _pal.ink1)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(s.formatLongDate(e.date),
              style: pvManrope(fontSize: 12, color: _pal.ink3)),
          if (e.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(e.description,
                style: pvManrope(
                    fontSize: 13.5, height: 1.5, color: _pal.ink2)),
          ],
          const SizedBox(height: 16),
          if (e.weekRef != null)
            _sheetAction(Icons.map_rounded, s.calOpenWeek(e.weekRef!), () {
              Navigator.pop(context);
              p.selectWeek(e.weekRef!);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => WeeklyCardStackScreen(controller: p)));
            }),
          if (e.opensJournal)
            _sheetAction(Icons.auto_stories_rounded, s.calOpenJournal, () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => JournalScreen(controller: p)));
            }),
          if (!e.isSystemGenerated &&
              e.category == CalEventCategory.personal)
            _sheetAction(Icons.delete_outline_rounded, s.delete, () {
              CalendarStore.instance.deletePersonal(e.id);
              Navigator.pop(context);
            }, danger: true),
        ],
      ),
    );
  }

  Widget _sheetEventRow(S s, CalendarEvent e) {
    final m = calMeta(e.category);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: m.color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(e.title,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral900)),
        ),
      ]),
    );
  }

  Widget _sheetAction(IconData icon, String label, VoidCallback onTap,
          {bool danger = false}) =>
      InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Icon(icon, size: 20, color: danger ? AppTheme.danger : _pal.ink1),
            const SizedBox(width: 12),
            Text(label,
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: danger ? AppTheme.danger : _pal.ink1)),
          ]),
        ),
      );

  void _sheet(Widget child) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
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
              child,
            ],
          ),
        ),
      ),
    );
  }

  // --- add personal event ----------------------------------------------------
  Future<void> _addPersonal(S s, [DateTime? initial]) async {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    var date = initial ?? DateTime.now();
    await showModalBottomSheet(
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
                        borderRadius: BorderRadius.circular(99)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(s.calAddPersonal,
                    style: pvJakarta(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _pal.ink1)),
                const SizedBox(height: 14),
                // White fields with the hairline, not a tinted fill behind
                // her words. Kept for revert: filled, fillColor:
                // AppTheme.surfaceContainer, OutlineInputBorder(radius 16,
                // BorderSide.none).
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  decoration: _fieldDecoration(s.calEventTitleHint),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  decoration: _fieldDecoration(s.calEventNoteHint,
                      suffix: MicDictateButton(controller: noteCtrl, s: s)),
                ),
                const SizedBox(height: 10),
                InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: date,
                      firstDate: DateTime(date.year - 1),
                      lastDate: DateTime(date.year + 2),
                    );
                    if (picked != null) setSheet(() => date = picked);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: _card(radius: 16),
                    child: Row(children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 18, color: _pal.ink1),
                      const SizedBox(width: 12),
                      Text(s.formatLongDate(date),
                          style: pvManrope(fontSize: 13.5, color: _pal.ink1)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: pregFilledStyle(),
                    onPressed: () async {
                      final t = titleCtrl.text.trim();
                      if (t.isEmpty) {
                        Navigator.pop(ctx);
                        return;
                      }
                      await CalendarStore.instance.addPersonal(
                          title: t, description: noteCtrl.text.trim(), date: date);
                      if (ctx.mounted) Navigator.pop(ctx);
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

  // --- helpers ---------------------------------------------------------------
  Widget _emptyNote(String msg) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Center(
          child: Text(msg,
              textAlign: TextAlign.center,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: _pal.ink2)),
        ),
      );

  /// A transparent Material under an InkWell that sits inside a white card,
  /// so the press shows on the card and not under it.
  static Widget _inked(Widget child) =>
      Material(type: MaterialType.transparency, child: child);

  /// A form field: white, the hairline, the ink ring when focused.
  InputDecoration _fieldDecoration(String hint, {Widget? suffix}) {
    OutlineInputBorder b(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: c));
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix,
      border: b(kPvLine),
      enabledBorder: b(kPvLine),
      focusedBorder: b(kPvInk),
    );
  }

  /// This screen's colour for a category. `calMeta` gives milestones the
  /// brand violet (`AppTheme.primary500` in lib/models/calendar_event.dart,
  /// not this file's to change), so a milestone is drawn in the ink here.
  static Color _catColor(CalEventCategory c) =>
      c == CalEventCategory.milestone ? kPvInk : calMeta(c).color;

  /// A drawn mark per category, for rows that open an event.
  static IntentMark _markOf(CalEventCategory c) => switch (c) {
        CalEventCategory.milestone => IntentMark.timelineRail,
        CalEventCategory.medical => IntentMark.scanFan,
        CalEventCategory.appointment => IntentMark.askDoctor,
        CalEventCategory.program => IntentMark.schoolMark,
        CalEventCategory.journal => IntentMark.pageMark,
        CalEventCategory.personal => IntentMark.calendarDay,
        CalEventCategory.parentveda => IntentMark.lotusMark,
      };

  /// The well's hue: the category's dot colour, so a mark and its dot on the
  /// grid read as one thing. Milestones take a warm hue (28): their dot is
  /// the ink, which has no hue to borrow, and their `calMeta` colour is the
  /// violet this screen no longer draws.
  static double _hueOf(CalEventCategory c) => c == CalEventCategory.milestone
      ? 28
      : HSLColor.fromColor(calMeta(c).color).hue;

  Widget _mark(CalEventCategory c, double size) =>
      PvMarkWell(p: _pal, hue: _hueOf(c), size: size, mark: _markOf(c));

  // The selected-day panel below the grid - date + pregnancy week + that day's
  // events + an "Add Note" entry (a calendar-only note for any date).
  Widget _selectedDayPanel(S s, List<CalendarEvent> events) {
    final date = _selectedDay ?? DateTime.now();
    final wk = _weekAt(date);
    // Every event on this day, across all categories - so each coloured dot is
    // named + explained (she never has to guess what a dot means).
    final dayEvents = events.where((e) => _sameDay(e.date, date)).toList()
      ..sort((a, b) => a.category.index.compareTo(b.category.index));
    // ⚠️ THE DAY'S CARD (2026-09-30, TTC's day panel): a white hairline card,
    // the day in the serif, its week in grey, a group label in the small grey
    // caps, event rows with the category's drawn mark, and "Add note" as an
    // outlined pill at its foot. Kept for revert: AppTheme.surface, radius 22,
    // boxShadow: _soft; the date in pvJakarta 16 / w700; the week in the gold
    // 0xFFE0921C; "ON THIS DAY" in pvManrope 10.5 / w800 neutral400; a
    // Divider(height 18) then a GestureDetector Row(add_circle icon, text).
    return Container(
      key: _detailsKey, // Task 2: scroll target for tap-a-date
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: _card(),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Text(s.formatLongDate(date),
                style: pvFraunces(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    color: _pal.ink1)),
          ),
          if (wk >= 4 && wk <= 40)
            Text('$wk ${s.calWeeksUpper}',
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: _pal.ink3)),
        ]),
        const SizedBox(height: 10),
        if (dayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(s.calNoEventsDay,
                style: pvManrope(fontSize: 13, height: 1.4, color: _pal.ink2)),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(s.calOnThisDay.toUpperCase(),
                style: pregGroupLabelStyle()),
          ),
          for (final e in dayEvents) _inked(_panelEventRow(s, e)),
        ],
        const SizedBox(height: 10),
        Semantics(
          button: true,
          label: s.calAddNote,
          excludeSemantics: true,
          child: _inked(InkWell(
            onTap: () => _addPersonal(s, date),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: kPvLine, width: 1.2),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, size: 18, color: _pal.ink1),
                const SizedBox(width: 7),
                Text(s.calAddNote,
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: _pal.ink1)),
              ]),
            ),
          )),
        ),
      ]),
    );
  }

  // A tidy event row for the selected-day panel: the category's drawn mark +
  // title (+ note), tap opens the event's detail sheet. The line naming the
  // dot keeps the dot's colour as a small swatch before grey words (it was
  // the words themselves in the colour). Kept for revert: a 34 Container in
  // m.color @ 0.12 with Icon(m.icon, 17), the title in pvJakarta 13.5, the
  // category line in m.color.
  Widget _panelEventRow(S s, CalendarEvent e) {
    return InkWell(
      onTap: () => _eventSheet(s, e),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(children: [
          _mark(e.category, 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _pal.ink1)),
                  const SizedBox(height: 2),
                  // Names the dot's colour + what it means, so it's never a guess.
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 4, right: 6),
                      child: _dotSwatch(_catColor(e.category), size: 7),
                    ),
                    Expanded(
                      child: Text(
                          '${_catName(s, e.category)} · ${_catMeaning(s, e.category)}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 11.5,
                              height: 1.3,
                              fontWeight: FontWeight.w600,
                              color: _pal.ink2)),
                    ),
                  ]),
                  if (e.description.isNotEmpty)
                    Text(e.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(fontSize: 11.5, color: _pal.ink3)),
                ]),
          ),
          Icon(Icons.chevron_right_rounded, size: 18, color: _pal.ink3),
        ]),
      ),
    );
  }

  // --- colour-code legend ----------------------------------------------------
  // A collapsible "What the dots mean" card: colour swatch + name + meaning, so
  // the colour coding is explainable even before tapping a day.
  Widget _legend(S s) {
    // Legend meanings. "Medical" reads as "Tests & Scans" (via _catName);
    // Programs added; ParentVeda commented out (Task 3/4/5).
    final cats = <(CalEventCategory, String)>[
      (CalEventCategory.milestone, s.calMeanMilestone),
      (CalEventCategory.medical, s.calMeanMedical),
      (CalEventCategory.appointment, s.calMeanAppointment),
      (CalEventCategory.program,
          s.lang.isHinglish
              ? 'कोई प्रोग्राम या क्लास जिसमें आपने नाम लिखवाया है'
              : 'A program or class you enrolled in'),
      (CalEventCategory.journal, s.calMeanJournal),
      (CalEventCategory.personal, s.calMeanPersonal),
      // (CalEventCategory.parentveda, s.calMeanParentveda),
    ];
    // A white hairline card (was AppTheme.surface with boxShadow: _soft,
    // its title in pvJakarta 13.5 / w800). Still folds open and shut.
    return Container(
      decoration: _card(radius: 18),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        _inked(InkWell(
          onTap: () => setState(() => _legendOpen = !_legendOpen),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
            child: Row(children: [
              Icon(Icons.palette_outlined, size: 18, color: _pal.ink1),
              const SizedBox(width: 10),
              Expanded(
                child: Text(s.calLegendTitle,
                    style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _pal.ink1)),
              ),
              Icon(
                  _legendOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: _pal.ink3),
            ]),
          ),
        )),
        if (_legendOpen) ...[
          const Divider(height: 1, thickness: 1, color: kPvLine),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(children: [
              for (final c in cats)
                _legendRow(_dotSwatch(_catColor(c.$1)), _catName(s, c.$1),
                    c.$2),
              _legendRow(_textSwatch('21w', const Color(0xFFE0921C)),
                  s.calLegendWeekStart, s.calMeanWeekStart),
              _legendRow(
                  _triSwatch(), s.calLegendTrimester, s.calMeanTrimester),
              _legendRow(_textSwatch(s.calChildbirth, const Color(0xFFE0921C)),
                  s.calLegendBirth, s.calMeanBirth),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _legendRow(Widget swatch, String name, String meaning) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(children: [
          SizedBox(width: 38, child: Center(child: swatch)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _pal.ink1)),
                  Text(meaning,
                      style: pvManrope(
                          fontSize: 11, height: 1.3, color: _pal.ink3)),
                ]),
          ),
        ]),
      );

  Widget _dotSwatch(Color c, {double size = 12}) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _textSwatch(String t, Color c) => Text(t,
      style: pvManrope(
          fontSize: 9, fontWeight: FontWeight.w800, color: c));

  Widget _triSwatch() => Row(mainAxisSize: MainAxisSize.min, children: [
        for (int t = 1; t <= 3; t++)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            width: 9,
            height: 9,
            decoration: BoxDecoration(
                color: _triColor(t), borderRadius: BorderRadius.circular(2)),
          ),
      ]);

  String _catName(S s, CalEventCategory c) => switch (c) {
        CalEventCategory.milestone => s.calFilterMilestones,
        // Task 3: "Medical" displays as "Tests & Scans" (enum unchanged).
        CalEventCategory.medical =>
          s.lang.isHinglish ? 'जाँच और स्कैन' : 'Tests & Scans',
        CalEventCategory.appointment => s.calFilterAppointments,
        CalEventCategory.program =>
          s.lang.isHinglish ? 'प्रोग्राम' : 'Programs',
        CalEventCategory.journal => s.calFilterJournal,
        CalEventCategory.personal => s.calFilterPersonal,
        CalEventCategory.parentveda => s.calFilterParentveda,
      };

  String _catMeaning(S s, CalEventCategory c) => switch (c) {
        CalEventCategory.milestone => s.calMeanMilestone,
        CalEventCategory.medical => s.calMeanMedical,
        CalEventCategory.appointment => s.calMeanAppointment,
        CalEventCategory.program => s.lang.isHinglish
            ? 'कोई प्रोग्राम या क्लास जिसमें आपने नाम लिखवाया है'
            : 'A program or class you enrolled in',
        CalEventCategory.journal => s.calMeanJournal,
        CalEventCategory.personal => s.calMeanPersonal,
        CalEventCategory.parentveda => s.calMeanParentveda,
      };

  // The small gold tag over a day cell (week-start "21w" or "Birth").
  Widget _topTag(String text) => Text(text,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
      style: pvManrope(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE0921C)));

  // Distinct, on-brand colours for the three trimester-start pills.
  static Color _triColor(int t) => t == 1
      ? const Color(0xFFC07A4E)
      : (t == 2 ? const Color(0xFF2F2C30) : const Color(0xFF3E9A66));

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int _weekAt(DateTime d) {
    final days =
        p.dueDate.difference(DateTime(d.year, d.month, d.day)).inDays;
    return (40 - (days / 7).floor()).clamp(0, 40);
  }

  static const Color _green = Color(0xFF4F7A52);
}
