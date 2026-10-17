// =============================================================================
//  The pregnancy calendar: one hub (2026-10-17)
// -----------------------------------------------------------------------------
//  The old calendar was three tabs (Timeline · Calendar · Upcoming): a busy
//  grid with 7pt tags, appointments that opened nothing, weight and kicks
//  posing as "journal", every program pinned to today, and an empty day that
//  did nothing when tapped. The user, setting the bar: "the way you have worked
//  for trying to conceive, do it for pregnancy… informative, yet simple…
//  each screen usable, the space utilised well."
//
//  Approved prototype: claude.ai/artifact/N6Y95pDA2i5dkQQbFaAF26. Top to bottom:
//
//    · where she is: "20 weeks 2 days", the trimester bar, days to go, and
//      WHERE the due date came from (Clue 4109e86e, Oura ee1f0724, Apple
//      Health 9710c735);
//    · the month: dots under the date, this week as a pale band, today in ink,
//      the picked day ringed (Weverse 5d94bb1b, Todoist a62d6a9f). No tags in
//      the cells; the week lives in the day card instead;
//    · the picked day: its things as rows, and one Add. An empty day invites;
//    · Coming up, the next three (Lex cb327064, Fixtured 11d10641);
//    · the usual checks this trimester, as windows (Zocdoc 86529650);
//    · rows to Whole journey and the four tools.
//
//  ⚠️ HIS SIDE IS READ-ONLY. He sees the same calendar and adds nothing: no
//  Add, no due date change, no edit or delete in any sheet, and a line that
//  says whose calendar it is.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../services/calendar_store.dart';
import '../../../services/journal_store.dart';
import '../../../services/pregnancy_controller.dart';
import '../../../services/prepare_store.dart';
import '../../../services/reminder_store.dart';
import '../../../services/scans_store.dart';
import '../../../services/symptom_store.dart';
import '../../../services/tools_store.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/global_ask_fab.dart' show kAskFabReserve;
import '../../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;
import '../../tools/due_date_calculator_screen.dart';
import 'preg_cal_data.dart';
import 'preg_cal_journey_screen.dart';
import 'preg_cal_parts.dart';
import 'preg_cal_sheets.dart';
import 'preg_cal_upcoming_screen.dart';

/// Every store the calendar reads, so any change redraws it.
Listenable pregCalListenable(PregnancyController p) => Listenable.merge([
      CalendarStore.instance,
      ScansStore.instance,
      ToolsStore.instance,
      SymptomStore.instance,
      JournalStore.instance,
      ReminderStore.instance,
      PrepareStore.instance,
      p,
    ]);

class PregCalendarHub extends StatefulWidget {
  const PregCalendarHub({
    super.key,
    required this.controller,
    this.readOnly = false,
    this.today,
  });

  final PregnancyController controller;

  /// His side: everything shown, nothing changed.
  final bool readOnly;

  /// Tests pin the day; the app uses the clock.
  final DateTime? today;

  @override
  State<PregCalendarHub> createState() => _PregCalendarHubState();
}

class _PregCalendarHubState extends State<PregCalendarHub> {
  static const int _kBasePage = 1200;
  static const double _kCell = 48;

  late final DateTime _today = pregDayOnly(widget.today ?? DateTime.now());
  late DateTime _pick = _today;
  late DateTime _month = DateTime(_today.year, _today.month);
  late final PageController _pages = PageController(initialPage: _kBasePage);
  final ScrollController _scroll = ScrollController();
  final GlobalKey _dayKey = GlobalKey();
  bool _searching = false;
  String _query = '';

  PregnancyController get p => widget.controller;
  bool get _ro => widget.readOnly;

  @override
  void dispose() {
    _pages.dispose();
    _scroll.dispose();
    super.dispose();
  }

  DateTime _monthFor(int page) =>
      DateTime(_today.year, _today.month + (page - _kBasePage));

  int _pageFor(DateTime month) =>
      _kBasePage + (month.year - _today.year) * 12 + (month.month - _today.month);

  void _goMonth(DateTime month, {bool animate = true}) {
    final target = _pageFor(month);
    if (!_pages.hasClients) return;
    if (animate && (target - (_pages.page ?? target)).abs() <= 2) {
      _pages.animateToPage(target,
          duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic);
    } else {
      _pages.jumpToPage(target);
    }
  }

  void _pickDay(DateTime d) {
    setState(() => _pick = pregDayOnly(d));
    // The day card answers the tap: bring it into view if it sits below.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _dayKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration: MediaQuery.of(context).disableAnimations
              ? Duration.zero
              : const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
    });
  }

  void _showDay(DateTime d) {
    final day = pregDayOnly(d);
    setState(() {
      _pick = day;
      _month = DateTime(day.year, day.month);
    });
    _goMonth(_month, animate: false);
    _pickDay(day);
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: pregCalListenable(p),
        builder: (context, _) => _build(context),
      );

  Widget _build(BuildContext context) {
    final items = pregCalItems();
    final pal = pvStorePalette;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: kPvInk),
        title: Text('Calendar', style: pregCalSerif(22)),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search your calendar',
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () => setState(() {
              _searching = !_searching;
              _query = '';
            }),
          ),
          IconButton(
            tooltip: 'About this calendar',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => showPregCalInfo(context, 'About this calendar', const [
              (Icons.calendar_month_outlined,
                  'Every appointment, weight, symptom and note you add, on one calendar.'),
              (Icons.health_and_safety_outlined,
                  'Usual checks show the weeks they normally happen. Your doctor sets the real date.'),
              (Icons.add_circle_outline_rounded,
                  'Tap a day, then Add. It saves to the same place as the tool itself.'),
            ]),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        controller: _scroll,
        padding: EdgeInsets.fromLTRB(16, 4, 16, kAskFabReserve + 8),
        children: [
          if (_searching) ...[_search(items), const SizedBox(height: 14)],
          if (_ro) ...[pregCalReadOnlyBanner(), const SizedBox(height: 14)],
          _hero(),
          const SizedBox(height: 14),
          _monthCard(items),
          const SizedBox(height: 14),
          KeyedSubtree(key: _dayKey, child: _dayCard(items)),
          const SizedBox(height: 14),
          _comingUp(items),
          const SizedBox(height: 14),
          _checksCard(),
          const SizedBox(height: 14),
          _rows(),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 14, 4, 0),
            child: Text(
                'For information only. Your doctor decides your care and your dates.',
                style: pregCalBody(size: 12, color: pal.ink3, height: 1.45)),
          ),
        ],
      ),
    );
  }

  // ---- search ---------------------------------------------------------------

  Widget _search(List<PregCalItem> items) {
    final q = _query.trim().toLowerCase();
    final hits = q.isEmpty
        ? const <PregCalItem>[]
        : [
            for (final i in items.reversed)
              if ('${i.title} ${i.detail}'.toLowerCase().contains(q)) i
          ];
    return Column(children: [
      TextField(
        autofocus: true,
        onChanged: (v) => setState(() => _query = v),
        style: pregCalBody(size: 15),
        decoration: InputDecoration(
          hintText: 'Search your calendar',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPvLine)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: kPvLine)),
        ),
      ),
      if (q.isNotEmpty) ...[
        const SizedBox(height: 10),
        PregCalCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: hits.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('Nothing matches. Try a word from a title or note.',
                      style: pregCalBody(color: pvStorePalette.ink2)),
                )
              : Column(children: [
                  for (final (i, it) in hits.take(8).indexed)
                    PregCalItemRow(
                      item: PregCalItem(
                          id: it.id,
                          kind: it.kind,
                          date: it.date,
                          title: it.title,
                          detail: pregDayLabel(it.date)),
                      first: i == 0,
                      onTap: () {
                        setState(() => _searching = false);
                        _showDay(it.date);
                      },
                    ),
                ]),
        ),
      ],
    ]);
  }

  // ---- where she is ---------------------------------------------------------

  String _sourceLine() {
    if (!p.isDueDateSet) return 'An estimate until you add your due date';
    return switch (p.dueDateSource) {
      DueDateSource.scan => 'Due date set by your dating scan',
      DueDateSource.clinician => 'Due date set by your doctor',
      DueDateSource.ivfTransfer => 'Due date set from your transfer date',
      DueDateSource.lastPeriod => 'Counted from your last period',
      DueDateSource.conception => 'Counted from your conception date',
      DueDateSource.unknown => 'Counted from the due date you gave',
    };
  }

  Widget _hero() {
    final pal = pvStorePalette;
    final ga = pregGaDays(p.dueDate, _today).clamp(0, 300);
    final w = ga ~/ 7, d = ga % 7;
    final tri = pregTrimesterFor(w);
    final left = pregDayOnly(p.dueDate).difference(_today).inDays;
    // Fill per segment: 0–14 weeks, 14–28, 28–40.
    double fill(int fromDay, int toDay) =>
        ((ga - fromDay) / (toDay - fromDay)).clamp(0.0, 1.0);
    final fills = [fill(0, 98), fill(98, 196), fill(196, 280)];
    final dueText = left > 0
        ? '$left days to go · due ${pregShortDate(p.dueDate)} ${p.dueDate.year}'
        : (left == 0
            ? 'Your due date is today'
            : 'Due ${pregShortDate(p.dueDate)} · ${-left} days ago');
    return PregCalCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('TODAY · ${pregDayLabel(_today).toUpperCase()}', style: pregCalEyebrow()),
        const SizedBox(height: 6),
        Semantics(
          header: true,
          child: Text('$w weeks $d ${d == 1 ? 'day' : 'days'}', style: pregCalSerif(30)),
        ),
        const SizedBox(height: 4),
        Text('${kPregTrimesterNames[tri]} · week ${(w + 1).clamp(1, 42)} of 40',
            style: pregCalBody(size: 14, weight: FontWeight.w600, color: pal.ink2)),
        const SizedBox(height: 14),
        Row(children: [
          for (final (i, f) in fills.indexed) ...[
            if (i > 0) const SizedBox(width: 4),
            Expanded(
              flex: i == 1 ? 14 : (i == 0 ? 14 : 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: f,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE7E6E2),
                  valueColor: const AlwaysStoppedAnimation(kPvInk),
                ),
              ),
            ),
          ],
        ]),
        const SizedBox(height: 6),
        Row(children: [
          for (final (i, l) in const ['1st', '2nd', '3rd'].indexed)
            Expanded(
              flex: i == 2 ? 12 : 14,
              child: Text(l,
                  textAlign: i == 0 ? TextAlign.left : (i == 1 ? TextAlign.center : TextAlign.right),
                  style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: tri == i + 1 ? kPvInk : pal.ink3)),
            ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: Text(dueText,
                  style: pregCalBody(size: 14, weight: FontWeight.w600))),
          if (!_ro)
            PregCalPill(
              label: 'Change',
              icon: Icons.edit_outlined,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'calendar/due_date'),
                  builder: (_) => DueDateCalculatorScreen(controller: p))),
            ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Icon(p.dueDateFromClinic ? Icons.verified_outlined : Icons.calculate_outlined,
              size: 14, color: pal.ink3),
          const SizedBox(width: 6),
          Expanded(
              child: Text(_sourceLine(),
                  style: pregCalBody(size: 12, color: pal.ink3))),
        ]),
      ]),
    );
  }

  // ---- the month ------------------------------------------------------------

  Widget _monthCard(List<PregCalItem> items) {
    final pal = pvStorePalette;
    final isThisMonth =
        _month.year == _today.year && _month.month == _today.month;
    final curWeek = pregWeekOf(p.dueDate, _today);
    final inMonth = {
      for (final i in items)
        if (i.date.year == _month.year && i.date.month == _month.month) i.kind
    };
    final kinds = PregCalKind.values.where(inMonth.contains).toList();
    return PregCalCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const SizedBox(width: 4),
          Expanded(
            child: Text('${kPregMonthNames[_month.month - 1]} ${_month.year}',
                style: pregCalSerif(20)),
          ),
          if (!isThisMonth)
            PregCalPill(
                label: 'Today',
                onTap: () {
                  _goMonth(DateTime(_today.year, _today.month));
                  setState(() => _pick = _today);
                }),
          IconButton(
            tooltip: 'Previous month',
            icon: const Icon(Icons.chevron_left_rounded, color: kPvInk),
            onPressed: () => _goMonth(DateTime(_month.year, _month.month - 1)),
          ),
          IconButton(
            tooltip: 'Next month',
            icon: const Icon(Icons.chevron_right_rounded, color: kPvInk),
            onPressed: () => _goMonth(DateTime(_month.year, _month.month + 1)),
          ),
        ]),
        Row(children: [
          for (final l in const ['S', 'M', 'T', 'W', 'T', 'F', 'S'])
            Expanded(
              child: Text(l,
                  textAlign: TextAlign.center,
                  style: pvManrope(
                      fontSize: 11, fontWeight: FontWeight.w700, color: pal.ink3)),
            ),
        ]),
        const SizedBox(height: 4),
        SizedBox(
          height: _kCell * 6,
          child: PageView.builder(
            controller: _pages,
            onPageChanged: (i) => setState(() => _month = _monthFor(i)),
            itemBuilder: (_, i) => _grid(_monthFor(i), items, curWeek),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: kPvLine))),
          child: Wrap(spacing: 12, runSpacing: 6, children: [
            if (isThisMonth) _keyItem(_bandSwatch(), 'This week (week $curWeek)'),
            for (final k in kinds) _keyItem(_dot(pregCalMeta(k).color, 8), pregCalMeta(k).label),
            if (!isThisMonth && kinds.isEmpty)
              Text('Nothing added this month yet.',
                  style: pregCalBody(size: 12, color: pal.ink3)),
          ]),
        ),
      ]),
    );
  }

  Widget _keyItem(Widget swatch, String label) => Row(mainAxisSize: MainAxisSize.min, children: [
        swatch,
        const SizedBox(width: 5),
        Text(label,
            style: pvManrope(
                fontSize: 11.5, fontWeight: FontWeight.w600, color: pvStorePalette.ink2)),
      ]);

  Widget _bandSwatch() => Container(
      width: 16,
      height: 8,
      decoration: BoxDecoration(
          color: kPregCalWeekTint, borderRadius: BorderRadius.circular(99)));

  Widget _dot(Color c, double size) => Container(
      width: size, height: size, decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _grid(DateTime month, List<PregCalItem> items, int curWeek) {
    final first = DateTime(month.year, month.month);
    final lead = first.weekday % 7; // Sunday first
    final days = DateTime(month.year, month.month + 1, 0).day;
    final byDay = <int, List<PregCalKind>>{};
    for (final i in items) {
      if (i.date.year != month.year || i.date.month != month.month) continue;
      final ks = byDay.putIfAbsent(i.date.day, () => []);
      if (!ks.contains(i.kind)) ks.add(i.kind);
    }
    final cells = <Widget>[
      for (var i = 0; i < lead; i++) const SizedBox.shrink(),
      for (var d = 1; d <= days; d++)
        _cell(DateTime(month.year, month.month, d), (lead + d - 1) % 7,
            byDay[d] ?? const [], curWeek, days),
    ];
    while (cells.length % 7 != 0) {
      cells.add(const SizedBox.shrink());
    }
    return Column(children: [
      for (var r = 0; r < cells.length ~/ 7; r++)
        SizedBox(
          height: _kCell,
          child: Row(children: [
            for (var c = 0; c < 7; c++) Expanded(child: cells[r * 7 + c]),
          ]),
        ),
    ]);
  }

  Widget _cell(DateTime d, int col, List<PregCalKind> kinds, int curWeek, int daysInMonth) {
    final pal = pvStorePalette;
    final isToday = pregSameDay(d, _today);
    final isPick = pregSameDay(d, _pick);
    final isDue = pregSameDay(d, p.dueDate);
    final inWeek = pregWeekOf(p.dueDate, d) == curWeek;
    final ga = pregGaDays(p.dueDate, d);
    final bandStart = inWeek && (ga % 7 == 0 || col == 0 || d.day == 1);
    final bandEnd = inWeek && (ga % 7 == 6 || col == 6 || d.day == daysInMonth);
    final label = [
      pregDayLabel(d),
      if (isToday) 'today',
      if (isDue) 'your due date',
      if (kinds.isNotEmpty) kinds.map((k) => pregCalMeta(k).label).join(', '),
    ].join(', ');
    return Semantics(
      button: true,
      selected: isPick,
      label: label,
      excludeSemantics: true,
      child: pregCalTap(
        onTap: () => _pickDay(d),
        child: Stack(alignment: Alignment.topCenter, children: [
          if (inWeek)
            Positioned(
              top: 3,
              height: 30,
              left: bandStart ? 6 : 0,
              right: bandEnd ? 6 : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: kPregCalWeekTint,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(bandStart ? 99 : 0),
                    right: Radius.circular(bandEnd ? 99 : 0),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isToday ? kPvInk : null,
                  shape: BoxShape.circle,
                  border: isPick
                      ? Border.all(color: isToday ? Colors.white : kPvInk, width: 2)
                      : null,
                  boxShadow: isPick && isToday
                      ? const [BoxShadow(color: kPvInk, spreadRadius: 2)]
                      : null,
                ),
                child: Text('${d.day}',
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: isToday || isPick ? FontWeight.w800 : FontWeight.w600,
                        color: isToday
                            ? Colors.white
                            : (d.isAfter(_today) ? pal.ink2 : pal.ink1))),
              ),
              const SizedBox(height: 3),
              if (isDue)
                Text('DUE',
                    style: pvManrope(
                        fontSize: 11,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: const Color(0xFFA77A1E)))
              else
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (final (i, k) in kinds.take(3).indexed) ...[
                    if (i > 0) const SizedBox(width: 3),
                    _dot(pregCalMeta(k).color, 5),
                  ],
                ]),
            ]),
          ),
        ]),
      ),
    );
  }

  // ---- the picked day -------------------------------------------------------

  Widget _dayCard(List<PregCalItem> items) {
    final pal = pvStorePalette;
    final d = _pick;
    final dayItems = pregItemsOn(items, d);
    final ga = pregGaDays(p.dueDate, d);
    final isToday = pregSameDay(d, _today);
    final future = d.isAfter(_today);
    final outside = ga < 0 || ga >= 294; // before her last period, or past 42 weeks
    final meta = ga < 0
        ? 'Before this pregnancy'
        : (ga >= 294
            ? 'After your due date'
            : [
                if (isToday) 'Today',
                'Week ${ga ~/ 7 + 1}, day ${ga % 7 + 1}',
                if (ga % 7 == 0) 'week ${ga ~/ 7 + 1} starts',
              ].join(' · '));
    final canAdd = !_ro && !outside;
    return PregCalCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(pregDayLabel(d), style: pregCalSerif(19)),
              const SizedBox(height: 2),
              Text(meta,
                  style: pregCalBody(size: 12.5, weight: FontWeight.w600, color: pal.ink3)),
            ]),
          ),
          if (canAdd && dayItems.isNotEmpty)
            PregCalPill(
                label: 'Add',
                icon: Icons.add_rounded,
                onTap: () => showPregCalAdd(context, p, d, today: _today)),
        ]),
        const SizedBox(height: 8),
        if (dayItems.isNotEmpty)
          Column(children: [
            for (final (i, it) in dayItems.indexed)
              PregCalItemRow(
                item: it,
                first: i == 0,
                onTap: () => showPregCalItem(context, p, it, readOnly: _ro),
              ),
          ])
        else
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
                future
                    ? 'Nothing planned for this day yet.'
                    : 'Nothing on this day yet.',
                style: pregCalBody(color: pal.ink2)),
            if (canAdd) ...[
              const SizedBox(height: 10),
              PregCalPill(
                  label: 'Add to ${pregShortDate(d)}',
                  ink: true,
                  icon: Icons.add_rounded,
                  onTap: () => showPregCalAdd(context, p, d, today: _today)),
            ],
          ]),
        if (canAdd && future) ...[
          const SizedBox(height: 10),
          Text(
              'On a future day you can add an appointment or a note. Weight, symptoms and kicks are logged on the day.',
              style: pregCalBody(size: 12, color: pal.ink3, height: 1.45)),
        ],
      ]),
    );
  }

  // ---- coming up ------------------------------------------------------------

  Future<void> _openUpcoming() async {
    final picked = await Navigator.of(context).push<DateTime>(MaterialPageRoute(
        settings: const RouteSettings(name: 'calendar/upcoming'),
        builder: (_) => PregCalUpcomingScreen(
            controller: p, readOnly: _ro, today: _today)));
    if (picked != null && mounted) _showDay(picked);
  }

  Future<void> _openJourney() async {
    final picked = await Navigator.of(context).push<DateTime>(MaterialPageRoute(
        settings: const RouteSettings(name: 'calendar/journey'),
        builder: (_) => PregCalJourneyScreen(controller: p, today: _today)));
    if (picked != null && mounted) _showDay(picked);
  }

  Widget _comingUp(List<PregCalItem> items) {
    final up = pregUpcoming(items, p.dueDate, _today).take(3).toList();
    return PregCalCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Coming up', style: pregCalSerif(19))),
          TextButton(
            onPressed: _openUpcoming,
            style: TextButton.styleFrom(foregroundColor: kPvInk),
            child: Text('See all',
                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ]),
        if (up.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Nothing booked yet.', style: pregCalBody(color: pvStorePalette.ink2)),
              if (!_ro) ...[
                const SizedBox(height: 10),
                PregCalPill(
                  label: 'Add your next check-up',
                  ink: true,
                  icon: Icons.add_rounded,
                  onTap: () => showPregCalAdd(context, p, _today, today: _today),
                ),
              ],
            ]),
          )
        else
          for (final (i, u) in up.indexed)
            PregCalUpcomingRow(
              u: u,
              today: _today,
              first: i == 0,
              onTap: () => u.around
                  ? showPregCalCheck(context, p, u.check!, readOnly: _ro)
                  : showPregCalItem(context, p, u.item!, readOnly: _ro),
            ),
      ]),
    );
  }

  // ---- usual checks this trimester -------------------------------------------

  Widget _checksCard() {
    final pal = pvStorePalette;
    final tri = pregTrimesterFor(pregCompletedWeeks(p.dueDate, _today));
    final checks = [for (final c in pregChecks()) if (c.trimester == tri) c];
    return PregCalCard(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text('Usual checks this trimester', style: pregCalSerif(19))),
          IconButton(
            tooltip: 'About usual checks',
            icon: const Icon(Icons.info_outline_rounded, size: 20, color: kPvInk),
            onPressed: () => showPregCalInfo(context, 'Usual checks', const [
              (Icons.health_and_safety_outlined,
                  'These are the checks most clinics in India follow, with the weeks they usually happen.'),
              (Icons.event_outlined,
                  'Your doctor sets the real date. Tap Add date once it is booked.'),
              (Icons.check_circle_outline_rounded,
                  'A check you have marked done in Scans & appointments shows as Done.'),
            ]),
          ),
        ]),
        if (checks.isEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 4),
            child: Text('No usual checks fall in this trimester.',
                style: pregCalBody(color: pal.ink2)),
          ),
        for (final (i, c) in checks.indexed) _checkRow(c, first: i == 0),
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 8),
          child: Text('Your doctor sets the real date. These windows are what most clinics follow.',
              style: pregCalBody(size: 12, color: pal.ink3, height: 1.45)),
        ),
      ]),
    );
  }

  Widget _checkRow(PregCheck c, {required bool first}) {
    final pal = pvStorePalette;
    final st = pregCheckStatus(c);
    final hasWeeks = c.windowLabel.startsWith('Around');
    final sub = switch (st.state) {
      PregCheckState.done => 'Done${st.date == null ? '' : ' on ${pregShortDate(st.date!)}'}',
      PregCheckState.booked => 'Booked for ${pregDayLabel(st.date!)}',
      PregCheckState.open => hasWeeks
          ? '${c.windowLabel} · ${pregCheckDates(c, p.dueDate)}'
          : c.windowLabel,
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 10, 8, 10),
      decoration: BoxDecoration(
          border: first ? null : const Border(top: BorderSide(color: kPvLine))),
      child: Row(children: [
        Expanded(
          child: pregCalTap(
            onTap: () => showPregCalCheck(context, p, c, readOnly: _ro),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title, style: pregCalBody(weight: FontWeight.w700)),
              const SizedBox(height: 1),
              Text(sub, style: pregCalBody(size: 12.5, color: pal.ink3)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        switch (st.state) {
          PregCheckState.done => Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.check_rounded, size: 16, color: Color(0xFF1F8A5B)),
              const SizedBox(width: 3),
              Text('Done',
                  style: pvManrope(
                      fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF1F8A5B))),
            ]),
          PregCheckState.booked => const SizedBox.shrink(),
          PregCheckState.open => _ro
              ? const SizedBox.shrink()
              : PregCalPill(
                  label: 'Add date',
                  onTap: () => pregCalBookCheck(context, p, c, today: _today)),
        },
      ]),
    );
  }

  // ---- rows -----------------------------------------------------------------

  Widget _rows() {
    final rows = <(IntentMark, String, String?, VoidCallback)>[
      (IntentMark.timelineRail, 'Whole journey', 'Week by week', _openJourney),
      if (!_ro) ...[
        (IntentMark.askDoctor, 'Scans & appointments', null, () => pregCalOpenScans(context, p)),
        (IntentMark.stepsMark, 'Kick counter', 'From about week 28', () => pregCalOpenKicks(context, p)),
        (IntentMark.scaleMark, 'Weight', null, () => pregCalOpenWeight(context, p)),
        (IntentMark.bodyMark, 'Symptoms', null, () => pregCalOpenSymptoms(context, p)),
      ],
    ];
    return PregCalCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Column(children: [
        for (final (i, (mark, title, sub, onTap)) in rows.indexed)
          pregCalTap(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                  border: i == 0 ? null : const Border(top: BorderSide(color: kPvLine))),
              child: Row(children: [
                pregCalPlainMark(mark, size: 32, hue: 206),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: pregCalBody(size: 14.5, weight: FontWeight.w700))),
                if (sub != null)
                  Text(sub, style: pregCalBody(size: 12.5, color: pvStorePalette.ink3)),
                Icon(Icons.chevron_right_rounded, size: 20, color: pvStorePalette.ink3),
              ]),
            ),
          ),
      ]),
    );
  }
}
