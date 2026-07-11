// =============================================================================
//  CalendarScreen - "My Calendar" (the pregnancy command center)
// -----------------------------------------------------------------------------
//  Three calm tabs: Journey Timeline (default), Calendar grid, and Upcoming -
//  with a subtle progress card, category filters, search, and mother-added
//  personal events. Answers: where am I, what's happened, what's next. Warm-Nest
//  visual language (no mockup existed; extrapolated). Reuses the shared event
//  assembly in CalendarStore.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../models/calendar_event.dart';
import '../services/calendar_store.dart';
import '../services/journal_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/prepare_store.dart';
import '../services/scans_store.dart';
import '../services/tools_store.dart';
import '../theme/app_theme.dart';
import '../widgets/mic_dictation_button.dart';
import '../widgets/trimester_progress_bar.dart';
import 'journal_screen.dart';
import 'weekly_card_stack_screen.dart';

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

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];

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
    return Container(
      color: AppTheme.surfaceContainer,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _header(s),
            Expanded(
              child: ListView(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
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
        padding: const EdgeInsets.fromLTRB(18, 8, 12, 4),
        child: Row(
          children: [
            Expanded(
              child: _searching
                  ? TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                          hintText: s.calSearchHint, border: InputBorder.none),
                    )
                  : Text(s.calTitle,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
            ),
            IconButton(
              icon: Icon(
                  _searching ? Icons.close_rounded : Icons.search_rounded,
                  color: AppTheme.primary700),
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
                icon: const Icon(Icons.add_circle_outline_rounded,
                    color: AppTheme.primary700),
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
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
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
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
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
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary900)),
                    const SizedBox(height: 2),
                    Text('${s.calDaysTogether(p.daysCompleted)} ❤',
                        style: GoogleFonts.manrope(
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
                      backgroundColor: AppTheme.primary100,
                      valueColor:
                          const AlwaysStoppedAnimation(AppTheme.primary500),
                    ),
                  ),
                  Text('${p.progressPercent}%',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary700)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(s.journeyDaysRemaining(p.daysRemaining),
              style: GoogleFonts.manrope(
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
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _soft,
      ),
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
                    color: _tab == i ? AppTheme.primary500 : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(tabs[i],
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _tab == i
                              ? Colors.white
                              : AppTheme.neutral600)),
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
          s.lang.isHinglish ? 'Tests & Scans' : 'Tests & Scans'),
      (CalEventCategory.program,
          s.lang.isHinglish ? 'Programs' : 'Programs'),
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
                decoration: BoxDecoration(
                  color: _filter == c.$1
                      ? AppTheme.primary500
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
    final m = calMeta(e.category);
    final cur = e.status == CalEventStatus.current;
    final done = e.status == CalEventStatus.completed;
    final dotColor = cur ? AppTheme.primary500 : (done ? _green : AppTheme.neutral300);
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
                  color: done ? _green : (cur ? AppTheme.primary500 : AppTheme.surface),
                  shape: BoxShape.circle,
                  border: Border.all(color: dotColor, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                    : null,
              ),
              Expanded(child: Container(width: 2, color: AppTheme.outlineVariant)),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _eventSheet(s, e),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cur
                        ? AppTheme.primary500.withValues(alpha: 0.06)
                        : AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: _soft,
                    border: Border(left: BorderSide(color: m.color, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(m.icon, size: 16, color: m.color),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.title,
                              style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primary900)),
                        ),
                        if (cur)
                          _pill(s.youAreHere, AppTheme.primary500)
                        else if (done)
                          _pill(s.calStatusCompleted, _green)
                        else
                          _pill(s.calStatusUpcoming, AppTheme.neutral400),
                      ]),
                      if (e.description.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(e.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                height: 1.4,
                                color: AppTheme.neutral600)),
                      ],
                      const SizedBox(height: 5),
                      Text(s.formatShortDate(e.date),
                          style: GoogleFonts.manrope(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.neutral400)),
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

  Widget _pill(String label, Color c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(99)),
        child: Text(label,
            style: GoogleFonts.manrope(
                fontSize: 9.5, fontWeight: FontWeight.w800, color: c)),
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

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                color: AppTheme.primary600,
                onPressed: () => setState(() =>
                    _month = DateTime(_month.year, _month.month - 1)),
              ),
              Expanded(
                child: Text(s.calMonthYear(_month),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                color: AppTheme.primary600,
                onPressed: () => setState(() =>
                    _month = DateTime(_month.year, _month.month + 1)),
              ),
            ],
          ),
          Row(
            children: [
              for (final w in s.calWeekdayLetters)
                Expanded(
                  child: Center(
                    child: Text(w,
                        style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.neutral400)),
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
      final c = calMeta(e.category).color;
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
                              style: GoogleFonts.manrope(
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
                      ? AppTheme.primary500
                      : (selected
                          ? AppTheme.primary500.withValues(alpha: 0.16)
                          : Colors.transparent),
                  shape: BoxShape.circle,
                  border: selected && !isToday
                      ? Border.all(color: AppTheme.primary500, width: 1.5)
                      : null,
                ),
                child: Text('$day',
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight:
                            isToday ? FontWeight.w800 : FontWeight.w600,
                        color: isToday ? Colors.white : AppTheme.neutral700)),
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

    Widget group(String title, List<CalendarEvent> list) {
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 8),
            child: Text(title.toUpperCase(),
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppTheme.primary500)),
          ),
          for (final e in list) _upcomingRow(s, e),
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
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _soft,
        ),
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
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 2),
                  Text(s.calInDays(n),
                      style: GoogleFonts.manrope(
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
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
          if (week >= 4 && week <= 40) ...[
            const SizedBox(height: 4),
            Text('${s.weekWord} $week · ${s.trimesterName(week)}',
                style: GoogleFonts.manrope(
                    fontSize: 12.5, color: AppTheme.neutral600)),
          ],
          if (isToday && snap != null) ...[
            const SizedBox(height: 10),
            Text(s.babyIsSize(snap.fruit.of(p.language)),
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppTheme.primary700)),
          ],
          const SizedBox(height: 14),
          if (events.isEmpty)
            Text(s.calNoEventsDay,
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppTheme.neutral500))
          else
            for (final e in events) _sheetEventRow(s, e),
        ],
      ),
    );
  }

  void _eventSheet(S s, CalendarEvent e) {
    final m = calMeta(e.category);
    _sheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(m.icon, size: 21, color: m.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(e.title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ),
          ]),
          const SizedBox(height: 6),
          Text(s.formatLongDate(e.date),
              style: GoogleFonts.manrope(
                  fontSize: 12, color: AppTheme.neutral500)),
          if (e.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(e.description,
                style: GoogleFonts.manrope(
                    fontSize: 13.5, height: 1.5, color: AppTheme.neutral700)),
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
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary900)),
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
            Icon(icon,
                size: 20,
                color: danger ? AppTheme.danger : AppTheme.primary600),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: danger ? AppTheme.danger : AppTheme.primary700)),
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
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                const SizedBox(height: 14),
                TextField(
                  controller: titleCtrl,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: s.calEventTitleHint,
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    hintText: s.calEventNoteHint,
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    suffixIcon: MicDictateButton(controller: noteCtrl, s: s),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none),
                  ),
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
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16)),
                    child: Row(children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 18, color: AppTheme.primary600),
                      const SizedBox(width: 12),
                      Text(s.formatLongDate(date),
                          style: GoogleFonts.manrope(
                              fontSize: 13.5, color: AppTheme.primary900)),
                    ]),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
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
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.5, color: AppTheme.neutral500)),
        ),
      );

  // The selected-day panel below the grid - date + pregnancy week + that day's
  // events + an "Add Note" entry (a calendar-only note for any date).
  Widget _selectedDayPanel(S s, List<CalendarEvent> events) {
    final date = _selectedDay ?? DateTime.now();
    final wk = _weekAt(date);
    // Every event on this day, across all categories - so each coloured dot is
    // named + explained (she never has to guess what a dot means).
    final dayEvents = events.where((e) => _sameDay(e.date, date)).toList()
      ..sort((a, b) => a.category.index.compareTo(b.category.index));
    return Container(
      key: _detailsKey, // Task 2: scroll target for tap-a-date
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: Text(s.formatLongDate(date),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
          ),
          if (wk >= 4 && wk <= 40)
            Text('$wk ${s.calWeeksUpper}',
                style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFE0921C))),
        ]),
        const SizedBox(height: 6),
        if (dayEvents.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(s.calNoEventsDay,
                style: GoogleFonts.manrope(
                    fontSize: 12.5, color: AppTheme.neutral500)),
          )
        else ...[
          Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 4),
            child: Text(s.calOnThisDay.toUpperCase(),
                style: GoogleFonts.manrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: AppTheme.neutral400)),
          ),
          for (final e in dayEvents) _panelEventRow(s, e),
        ],
        const SizedBox(height: 6),
        const Divider(height: 18, color: AppTheme.outlineVariant),
        GestureDetector(
          onTap: () => _addPersonal(s, date),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            const Icon(Icons.add_circle_outline_rounded,
                size: 20, color: AppTheme.primary500),
            const SizedBox(width: 8),
            Text(s.calAddNote,
                style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary600)),
          ]),
        ),
      ]),
    );
  }

  // A tidy event row for the selected-day panel: category icon + title (+ note),
  // tap opens the event's detail sheet.
  Widget _panelEventRow(S s, CalendarEvent e) {
    final m = calMeta(e.category);
    return GestureDetector(
      onTap: () => _eventSheet(s, e),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: m.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(11)),
            child: Icon(m.icon, size: 17, color: m.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                  // Names the dot's colour + what it means, so it's never a guess.
                  Text('${_catName(s, e.category)} · ${_catMeaning(s, e.category)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: m.color)),
                  if (e.description.isNotEmpty)
                    Text(e.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 11.5, color: AppTheme.neutral600)),
                ]),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 16, color: AppTheme.neutral400),
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
              ? 'Aapka enrolled program ya class'
              : 'A program or class you enrolled in'),
      (CalEventCategory.journal, s.calMeanJournal),
      (CalEventCategory.personal, s.calMeanPersonal),
      // (CalEventCategory.parentveda, s.calMeanParentveda),
    ];
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _soft,
      ),
      child: Column(children: [
        InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() => _legendOpen = !_legendOpen),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
            child: Row(children: [
              const Icon(Icons.palette_outlined,
                  size: 18, color: AppTheme.primary500),
              const SizedBox(width: 10),
              Expanded(
                child: Text(s.calLegendTitle,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary900)),
              ),
              Icon(
                  _legendOpen
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  color: AppTheme.neutral400),
            ]),
          ),
        ),
        if (_legendOpen) ...[
          const Divider(height: 1, color: AppTheme.outlineVariant),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Column(children: [
              for (final c in cats)
                _legendRow(_dotSwatch(calMeta(c.$1).color), _catName(s, c.$1),
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
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  Text(meaning,
                      style: GoogleFonts.manrope(
                          fontSize: 11,
                          height: 1.3,
                          color: AppTheme.neutral500)),
                ]),
          ),
        ]),
      );

  Widget _dotSwatch(Color c) => Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _textSwatch(String t, Color c) => Text(t,
      style: GoogleFonts.manrope(
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
          s.lang.isHinglish ? 'Tests & Scans' : 'Tests & Scans',
        CalEventCategory.appointment => s.calFilterAppointments,
        CalEventCategory.program =>
          s.lang.isHinglish ? 'Programs' : 'Programs',
        CalEventCategory.journal => s.calFilterJournal,
        CalEventCategory.personal => s.calFilterPersonal,
        CalEventCategory.parentveda => s.calFilterParentveda,
      };

  String _catMeaning(S s, CalEventCategory c) => switch (c) {
        CalEventCategory.milestone => s.calMeanMilestone,
        CalEventCategory.medical => s.calMeanMedical,
        CalEventCategory.appointment => s.calMeanAppointment,
        CalEventCategory.program => s.lang.isHinglish
            ? 'Aapka enrolled program ya class'
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
      style: GoogleFonts.manrope(
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFFE0921C)));

  // Distinct, on-brand colours for the three trimester-start pills.
  static Color _triColor(int t) => t == 1
      ? const Color(0xFFC07A4E)
      : (t == 2 ? const Color(0xFF7A4FC2) : const Color(0xFF3E9A66));

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
