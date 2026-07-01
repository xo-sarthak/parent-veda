// =============================================================================
//  FatherDailyScreen — standalone port of the Claude Design "Father Daily"
// -----------------------------------------------------------------------------
//  The father's daily space ("grounded, warm — getting ready to meet my baby").
//  A faithful Flutter port of the design, in the SLATE palette (Teal toggle too).
//  Self-contained: its OWN father palette (NOT AppTheme), English copy verbatim.
//  NOT integrated anywhere yet — just a screen that exists and runs.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/father/father_read_data.dart';
import '../../data/father/father_tales.dart';
import '../../data/garbh_data.dart';
import '../../data/scan_schedule.dart';
// garbh_content (GarbhPrompt) parked — the father read-aloud now uses the shared
// SamvadPiece pool. Kept commented for revert.
// import '../../models/garbh_content.dart';
import '../../models/journal_entry.dart';
import '../../models/journey_node.dart';
import '../../models/read_item.dart';
import '../../models/scan_appointment.dart';
import '../../services/app_nav.dart';
import '../../services/father_journal_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/read_to_baby_store.dart';
import '../../services/samvad_pool.dart';
import '../../services/scans_store.dart';
import '../../widgets/journal/journal_create.dart';
import '../profile_screen.dart';
import '../week_flow_screen.dart';
import 'father_journal_screen.dart';
import 'father_stories_screen.dart';

// ---- palettes ---------------------------------------------------------------
class _Pal {
  const _Pal({
    required this.bg,
    required this.card,
    required this.line,
    required this.ink,
    required this.muted,
    required this.accent,
    required this.accent2,
    required this.accentSoft,
    required this.warmSoft,
    required this.cream,
  });
  final Color bg, card, line, ink, muted, accent, accent2, accentSoft, warmSoft, cream;
}

const _slate = _Pal(
  bg: Color(0xFFF4EFE8),
  card: Color(0xFFFFFFFF),
  line: Color(0xFFECE5DA),
  ink: Color(0xFF22333B),
  muted: Color(0xFF6A7B82),
  accent: Color(0xFF2E5266),
  accent2: Color(0xFFE0915B),
  accentSoft: Color(0xFFE7EDEF),
  warmSoft: Color(0xFFFBEDDE),
  cream: Color(0xFFFBF7F0),
);

const _teal = _Pal(
  bg: Color(0xFFEBEEED),
  card: Color(0xFFFFFFFF),
  line: Color(0xFFE3E7E5),
  ink: Color(0xFF1F2E33),
  muted: Color(0xFF647176),
  accent: Color(0xFF2F4858),
  accent2: Color(0xFFC97B5A),
  accentSoft: Color(0xFFE2E9E8),
  warmSoft: Color(0xFFF4E6DC),
  cream: Color(0xFFF6F1EA),
);

// ---- detail content model ---------------------------------------------------
class _Detail {
  const _Detail({
    required this.id,
    required this.eyebrow,
    required this.title,
    this.meta = '',
    // this.script = '',  // read-aloud text now comes from Samvad (_readAloudToday)
    this.paras = const [],
    this.list = const [],
    this.cta = '',
    this.confirm = '',
  });
  final String id, eyebrow, title, meta, cta, confirm;
  final List<String> paras, list;
}

const Map<String, _Detail> _kDetails = {
  'tip': _Detail(
    id: 'tip',
    eyebrow: 'Daily tip for Dad',
    title: "Tonight, don't fix it — just sit with her",
    meta: '2 min · showing up',
    paras: [
      "When she can't sleep, the instinct is to solve it. Resist that. You don't need the right words.",
      "Sit up with her. A hand on her back. Let the quiet do the work — that's the part she'll remember.",
    ],
    list: [
      'Phone face-down',
      'No advice unless she asks for it',
      'Try: "Want me to stay up with you?"',
    ],
    cta: 'Mark as done today',
    confirm: 'Nice. Showing up is the whole thing.',
  ),
  'partner': _Detail(
    id: 'partner',
    eyebrow: 'Support your partner',
    title: "Week 20 — what she's carrying",
    paras: [
      'Her centre of gravity is shifting as the bump grows, and her lower back is taking the strain. By evening, it aches.',
      'Small, specific help lands bigger than grand gestures right now. You do not have to be asked — noticing first is the whole gift.',
    ],
    list: [
      'Take dinner off her plate — cook her favourite, or order it before she has to ask.',
      'Rub her lower back for five minutes — no phone, no agenda.',
      'Quietly handle a chore she usually does, without announcing it.',
      'Keep water and a small snack by her side of the bed.',
      'Ask "how are you feeling today?" and just listen — resist fixing it.',
      'Take over the heavy lifting: groceries, laundry baskets, anything that strains her back.',
      'Come to the next scan, and write down the questions together beforehand.',
      'Let her nap without guilt — take the evening shift on the house.',
      'Help her settle on her side with a pillow tucked behind her back.',
      'Say the small things out loud — "you are doing something incredible."',
    ],
    cta: "I'll handle dinner",
    confirm: "Dinner's handled tonight. She'll feel it.",
  ),
  'read': _Detail(
    id: 'read',
    eyebrow: 'Daily read',
    title: 'What your baby can hear at 20 weeks',
    meta: '4 min read · ParentVeda Reads',
    paras: [
      'Around now the tiny bones of the inner ear finish forming — and your voice, lower and slower than hers, carries especially well through the body.',
      "Reading a few lines a day isn't sentimental. It's how your baby starts to know you before they ever see you.",
    ],
    cta: 'Done reading',
    confirm: 'Nice — a few minutes well spent.',
  ),
  'talk': _Detail(
    id: 'talk',
    eyebrow: 'Read to your baby',
    title: 'Read to your baby tonight',
    meta: 'Read aloud · 1 min',
    // [script] is injected at render time from the mother's Samvad read-aloud
    // set (see _readAloudToday) so Mom and Dad share the same words.
    paras: [
      'Baby can recognise your voice now — lower and slower than hers, it carries especially well. Read it aloud, let your voice rise and fall, and play with the words.',
      "A minute is plenty. It's the rhythm that reaches them, not the meaning.",
    ],
    cta: 'Done reading tonight',
    confirm: 'Beautiful — your voice is a gift they already know.',
  ),
  'story': _Detail(
    id: 'story',
    eyebrow: 'Stories, fables & mythology',
    title: 'The Churning of the Ocean',
    meta: 'A 3-minute myth · read aloud',
    paras: [
      'Long ago, gods and demons gripped the same great rope, coiled it around a mountain, and churned the sea of milk for the nectar of immortality.',
      "Read it slow. The bump can't follow the plot yet — but it can feel the rise and fall of your voice.",
    ],
    cta: 'Start reading',
    confirm: 'Find a quiet spot and read it slow.',
  ),
  'journal': _Detail(
    id: 'journal',
    eyebrow: 'Your journal',
    title: 'A note to your baby',
  ),
};

class _Entry {
  _Entry(this.date, this.text);
  final String date;
  final String text;
}

// ===========================================================================
//  Screen
// ===========================================================================
class FatherDailyScreen extends StatefulWidget {
  const FatherDailyScreen(
      {super.key, required this.controller, this.embedded = false});

  /// Pregnancy controller — used by the Baby / Mother / What's-next quick
  /// circles to open the (father-skinned) weekly detail screens for week 20.
  final PregnancyController controller;

  /// When embedded inside MainScaffold's Today tab (the testing mode switch),
  /// the screen hides its own bottom tab bar and leaves room for the app's
  /// floating tab bar instead. Standalone (pairing-flow) use keeps both.
  final bool embedded;

  @override
  State<FatherDailyScreen> createState() => _FatherDailyScreenState();
}

class _FatherDailyScreenState extends State<FatherDailyScreen> {
  int _palIdx = 0; // 0 = Slate (default), 1 = Teal
  static const int _week = 20;
  static const String _dadName = 'Arjun';

  // "Read to your baby" mirrors the mother's daily Samvad EXACTLY: same shared
  // pool, same customization (ReadToBabyStore, mother-owned), same day pick. The
  // father has NO controls of his own — whatever the mother enables is what he
  // sees here. Uses her live stage (not the fixed week-20 framing) so the daily
  // piece is identical to the one on her side.
  List<SamvadPiece> get _readAloudPool => samvadDailyPool(
      ReadToBabyStore.instance,
      garbhTrimester(widget.controller.currentWeek));
  SamvadPiece? get _readAloudToday {
    final pool = _readAloudPool;
    if (pool.isEmpty) return null;
    final day = widget.controller.currentDay.clamp(1, 280);
    // Same shared "another prompt" offset the mother cycles on her Samvad, so
    // tapping it on her side advances the father's piece to match.
    final off = ReadToBabyStore.instance.promptOffset;
    return pool[((day - 1) + off) % pool.length];
  }

  // Days-since-epoch — a stable index that ticks over once per day, used to
  // refresh the daily read + the daily tale.
  int get _dayIndex =>
      DateTime.now().millisecondsSinceEpoch ~/ Duration.millisecondsPerDay;

  // "Daily read" is sourced from the father Read-recommendations slots, week-
  // aware (see father_read_data.dart). Rotates day to day so it refreshes every
  // day rather than staying fixed all week. Now a small LOOPING swipe carousel
  // of the day's reads; `_readIdx` tracks the slide currently showing.
  late final List<ReadItem> _reads;
  int _readIdx = 0;
  late final PageController _readPc;
  ReadItem get _todayRead => _reads.isEmpty
      ? fatherReadForWeek(_week)
      : _reads[_readIdx % _reads.length];

  // Stories/Fables/Mythology: one piece a day, alternating across the kinds the
  // user enabled (empty = a mix of all three). Persisted in shared_preferences.
  static const _kTaleKindsKey = 'father_tale_kinds';
  final Set<FatherTaleKind> _taleKinds = {};
  FatherTale get _todayTale => fatherTaleForDay(_dayIndex, _taleKinds);

  String? _shownCard;
  bool _open = false;
  bool _momOpen = false;
  bool _recording = false;
  bool _recorded = false;
  final _draft = TextEditingController();
  final List<_Entry> _entries = [
    _Entry('Yesterday',
        'Felt the first kick against my palm tonight. I actually teared up.'),
    _Entry('Tuesday',
        'Told her the nursery can wait — we just need each other right now.'),
  ];

  String _toast = '';
  bool _toastShow = false;
  Timer? _toastTimer;
  Timer? _closeTimer;

  _Pal get _p => _palIdx == 0 ? _slate : _teal;

  @override
  void initState() {
    super.initState();
    _loadTaleKinds();
    // The day's reads + a controller parked mid-range so the carousel loops both
    // ways without ever feeling stuck at the first slide.
    _reads = fatherDailyReads(_week, _dayIndex);
    _readPc = PageController(
        initialPage: _reads.length > 1 ? _reads.length * 1000 : 0);
    // Mirror the mother's customization live: when she changes what to read,
    // the father's "Read to your baby" card refreshes too.
    ReadToBabyStore.instance.addListener(_onReadStore);
  }

  void _onReadStore() {
    if (mounted) setState(() {});
  }

  Future<void> _loadTaleKinds() async {
    try {
      final saved =
          (await SharedPreferences.getInstance()).getStringList(_kTaleKindsKey);
      if (saved == null || !mounted) return;
      setState(() {
        _taleKinds
          ..clear()
          ..addAll(FatherTaleKind.values.where((k) => saved.contains(k.name)));
      });
    } catch (_) {/* default = a mix of all three */}
  }

  Future<void> _saveTaleKinds() async {
    try {
      await (await SharedPreferences.getInstance()).setStringList(
          _kTaleKindsKey, _taleKinds.map((k) => k.name).toList());
    } catch (_) {/* best-effort */}
  }

  @override
  void dispose() {
    ReadToBabyStore.instance.removeListener(_onReadStore);
    _readPc.dispose();
    _toastTimer?.cancel();
    _closeTimer?.cancel();
    _draft.dispose();
    super.dispose();
  }

  void _flash(String msg) {
    setState(() {
      _toast = msg;
      _toastShow = true;
    });
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2100),
        () => mounted ? setState(() => _toastShow = false) : null);
  }

  void _openCard(String id) {
    _closeTimer?.cancel();
    setState(() {
      _shownCard = id;
      _open = true;
      _recording = false;
    });
  }

  void _closeCard() {
    setState(() => _open = false);
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 360),
        () => mounted ? setState(() => _shownCard = null) : null);
  }

  void _detailPrimary() {
    final d = _shownCard == null ? null : _kDetails[_shownCard];
    final c = d?.confirm ?? '';
    _closeCard();
    if (c.isNotEmpty) _flash(c);
  }

  void _saveEntry() {
    final v = _draft.text.trim();
    if (v.isEmpty) {
      _flash('Write something first');
      return;
    }
    setState(() {
      _entries.insert(0, _Entry('Just now', v));
      _draft.clear();
    });
    _flash('Saved to your journal');
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    return Scaffold(
      backgroundColor: p.bg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          // ---- main column ----
          Column(children: [
            _topBar(p),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(0, 2, 0, widget.embedded ? 120 : 24),
                children: [
                  // Weekly snapshot — mirrors the mother's home hero, in Slate.
                  _weeklySnapshot(p),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                    child: Text('TODAY FOR YOU',
                        style: _eyebrow(p.muted, 0.14)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(children: [
                      _heroTip(p),
                      const SizedBox(height: 14),
                      _supportPartner(p),
                      const SizedBox(height: 14),
                      _dailyRead(p),
                      const SizedBox(height: 14),
                      _talkBaby(p),
                      const SizedBox(height: 14),
                      // Scans & appointments due around now (below Read to baby).
                      _scansCard(p),
                      const SizedBox(height: 14),
                      // "Stories, Fables & Myth" removed from the father's daily
                      // home. Kept for revert.
                      // _storiesMyth(p),
                      // const SizedBox(height: 14),
                      _journalCard(p),
                    ]),
                  ),
                ],
              ),
            ),
            if (!widget.embedded) _tabBar(p),
          ]),
          // ---- detail overlay ----
          _detailOverlay(p),
          // ---- mom sheet ----
          _momSheet(p),
          // ---- toast ----
          _toastPill(p),
        ]),
      ),
    );
  }

  // ---- shared text styles ----
  TextStyle _serif(double size, Color c, {FontWeight w = FontWeight.w600}) =>
      GoogleFonts.fraunces(
          fontSize: size, fontWeight: w, color: c, height: 1.18, letterSpacing: -0.2);
  TextStyle _body(double size, Color c,
          {FontWeight w = FontWeight.w400, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: size, fontWeight: w, color: c, height: h);
  TextStyle _eyebrow(Color c, double spacing) => GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: spacing);

  // ---- Baby / Mother / What's-next quick circles ----
  // Same shortcuts as the mother's weekly; they open the (father-skinned when
  // FatherPreview is on) week-20 detail screens. Parked — the snapshot hero now
  // carries these shortcuts. Kept for revert.
  // ignore: unused_element
  Widget _quickCircles(_Pal p) {
    Widget circle(IconData icon, String label, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: p.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: p.line),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x141C2830),
                        blurRadius: 12,
                        offset: Offset(0, 5)),
                  ],
                ),
                child: Icon(icon, color: p.accent, size: 24),
              ),
              const SizedBox(height: 7),
              Text(label, style: _body(12, p.muted, w: FontWeight.w600)),
            ]),
          ),
        );
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 10, 26, 2),
      child: Row(children: [
        circle(Icons.child_care_rounded, 'Baby', () => _openWeek('baby')),
        circle(Icons.favorite_rounded, 'Mother', () => _openWeek('mother')),
        circle(Icons.event_note_rounded, "What's next", () => _openWeek('next')),
      ]),
    );
  }

  void _openWeek(String which) {
    final c = widget.controller;
    final lang = c.language;
    switch (which) {
      case 'baby':
        openWeekBabyDetail(context, c, _week, lang);
        break;
      case 'mother':
        openWeekMotherDetail(context, c, _week, lang);
        break;
      case 'next':
        openWeekWhatsNext(context, c, lang, father: true);
        break;
    }
  }

  // ---- top bar ----
  Widget _topBar(_Pal p) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 10),
        child: Row(children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.accent, borderRadius: BorderRadius.circular(9)),
            child: Text('P', style: _serif(16, p.cream)),
          ),
          const SizedBox(width: 9),
          Text('ParentVeda', style: _serif(18, p.ink)),
          const Spacer(),
          // Dev Slate/Teal palette toggle (moved here from the snapshot hero).
          GestureDetector(
            onTap: () => setState(() => _palIdx = _palIdx == 0 ? 1 : 0),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: p.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 11,
                    height: 11,
                    decoration:
                        BoxDecoration(color: p.accent, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                        color: p.accent2, shape: BoxShape.circle)),
              ]),
            ),
          ),
          const SizedBox(width: 10),
          // Profile avatar (top-right, like the mother) → ProfileScreen.
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) =>
                    ProfileScreen(controller: widget.controller, father: true))),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: p.accent, shape: BoxShape.circle),
              child: Text(
                  _dadName.isNotEmpty ? _dadName[0].toUpperCase() : 'P',
                  style: _serif(16, p.cream)),
            ),
          ),
        ]),
      );

  // ---- greeting + progress ----
  // ---- Weekly snapshot (full mirror of the mother's home hero, in Slate) ----
  Widget _weeklySnapshot(_Pal p) {
    final hour = DateTime.now().hour;
    final part = hour < 12 ? 'morning' : (hour < 18 ? 'afternoon' : 'evening');
    final pct = (_week / 40).clamp(0.04, 1.0);
    final lang = widget.controller.language;
    final summary = widget.controller
            .weekData(_week)
            ?.snapshot
            .weekHeadline
            .of(lang)
            .trim() ??
        '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
          child: Text('WEEKLY SNAPSHOT', style: _eyebrow(p.muted, 0.14)),
        ),
        GestureDetector(
          onTap: () => AppNav.instance.goWeekly(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [p.accent, const Color(0xFF1E3A47)],
                ),
              ),
              child: Stack(children: [
                Positioned(
                    right: -34,
                    top: -40,
                    child: _softCircle(150, Colors.white.withValues(alpha: 0.06))),
                Positioned(
                    right: 26,
                    bottom: -42,
                    child: _softCircle(96, p.accent2.withValues(alpha: 0.20))),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Good $part, $_dadName',
                                          style: _body(12.5,
                                              p.cream.withValues(alpha: 0.85))),
                                      const SizedBox(height: 6),
                                      Text('Week $_week',
                                          style: _serif(26, p.cream,
                                              w: FontWeight.w600)),
                                      if (summary.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(summary,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: _body(
                                                13,
                                                p.cream
                                                    .withValues(alpha: 0.88))),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Open her week',
                                                style: _body(12.5, p.cream,
                                                    w: FontWeight.w700)),
                                            Icon(Icons.chevron_right_rounded,
                                                size: 17, color: p.cream),
                                          ]),
                                    ]),
                              ),
                              const SizedBox(width: 12),
                              // Circular progress ring (mirrors the mother hero).
                              _snapRing(p, pct, (40 - _week).clamp(0, 40)),
                            ]),
                        const SizedBox(height: 16),
                        Container(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.16)),
                        const SizedBox(height: 14),
                        Row(children: [
                          _snapShortcut(p, Icons.child_care_rounded, 'Baby',
                              () => _openWeek('baby')),
                          _snapShortcut(p, Icons.favorite_rounded, 'Mother',
                              () => _openWeek('mother')),
                          _snapShortcut(p, Icons.explore_rounded, "What's next",
                              () => _openWeek('next')),
                        ]),
                      ]),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  // Circular percentage ring — the father-skin twin of the mother hero's ring.
  Widget _snapRing(_Pal p, double pct, int weeksToGo) => SizedBox(
        width: 74,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
            width: 62,
            height: 62,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 62,
                height: 62,
                child: CircularProgressIndicator(
                  value: pct.toDouble(),
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              Text('${(pct * 100).round()}%',
                  style: _body(13, p.cream, w: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 5),
          Text('$weeksToGo weeks to go',
              textAlign: TextAlign.center,
              style: _body(10.5, p.cream.withValues(alpha: 0.92),
                  w: FontWeight.w700, h: 1.15)),
        ]),
      );

  Widget _snapShortcut(
          _Pal p, IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, size: 21, color: p.cream),
            ),
            const SizedBox(height: 6),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _body(11, p.cream.withValues(alpha: 0.95),
                    w: FontWeight.w700)),
          ]),
        ),
      );

  // Parked — replaced by _weeklySnapshot above. Kept for revert.
  // ignore: unused_element
  Widget _greeting(_Pal p) {
    final hour = DateTime.now().hour;
    final part = hour < 12 ? 'morning' : (hour < 18 ? 'afternoon' : 'evening');
    const sub = 'your partner is halfway there';
    final pct = (_week / 40).clamp(0.04, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Good $part, $_dadName', style: _serif(25, p.ink)),
              const SizedBox(height: 6),
              Row(children: [
                Text('Week $_week',
                    style: _body(13, p.accent, w: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                        color: p.muted.withValues(alpha: 0.5),
                        shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Flexible(child: Text(sub, style: _body(13, p.muted))),
              ]),
            ]),
          ),
          // palette toggle (two dots)
          GestureDetector(
            onTap: () => setState(() => _palIdx = _palIdx == 0 ? 1 : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              decoration: BoxDecoration(
                color: p.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: p.line),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 11,
                    height: 11,
                    decoration:
                        BoxDecoration(color: p.accent, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                        color: p.accent2, shape: BoxShape.circle)),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 13),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 7,
            color: p.accentSoft,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: pct.toDouble(),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(colors: [p.accent, p.accent2]),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ---- card 1: hero tip ----
  Widget _heroTip(_Pal p) => _tap(
        () => _openCard('tip'),
        Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: p.accent,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3822333B), blurRadius: 32, offset: Offset(0, 16)),
            ],
          ),
          child: Stack(children: [
            Positioned(
                right: -34,
                top: -44,
                child: _softCircle(170, Colors.white.withValues(alpha: 0.06))),
            Positioned(
                right: 18,
                bottom: -40,
                child: _softCircle(90, Colors.white.withValues(alpha: 0.05))),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('DAILY TIP FOR DAD',
                            style: _eyebrow(
                                p.cream.withValues(alpha: 0.72), 0.14)),
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: p.accent2,
                          borderRadius: BorderRadius.circular(13)),
                      child: Icon(Icons.wb_sunny_outlined,
                          color: p.cream, size: 22),
                    ),
                  ]),
              const SizedBox(height: 10),
              Text("Tonight, don't fix it. Just sit with her.",
                  style: _serif(24, p.cream)),
              const SizedBox(height: 9),
              Text(
                  "When she can't sleep, presence beats solutions. A hand on her back says more than any advice.",
                  style: _body(14, p.cream.withValues(alpha: 0.84))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
                decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Read today's tip · 2 min",
                      style: _body(13, p.cream, w: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('→', style: _body(15, p.cream)),
                ]),
              ),
            ]),
          ]),
        ),
      );

  // ---- card 2: support partner ----
  Widget _supportPartner(_Pal p) => _tap(
        () => _openCard('partner'),
        _whiteCard(
          p,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _iconTile(p, Icons.favorite_border_rounded, p.accentSoft, p.accent),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SUPPORT YOUR PARTNER',
                          style: _eyebrow(p.accent, 0.12)),
                      const SizedBox(height: 3),
                      Text("Week 20 — what she's carrying",
                          style: _serif(19, p.ink, w: FontWeight.w600)),
                    ]),
              ),
            ]),
            const SizedBox(height: 11),
            Text(
                'Her lower back is taking the strain this week, and by evening it aches.',
                style: _body(14, p.muted)),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                  color: p.warmSoft, borderRadius: BorderRadius.circular(15)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DO THIS TODAY', style: _eyebrow(p.accent2, 0.12)),
                    const SizedBox(height: 4),
                    Text(
                        'Take dinner off her plate — cook her favourite, or order it before she has to ask.',
                        style: _body(13.5, p.ink, h: 1.45)),
                  ]),
            ),
            const SizedBox(height: 14),
            _arrowLink(p, 'See her week'),
          ]),
        ),
      );

  // ---- card 3: daily read — a looping swipe carousel of the day's reads, with
  //      a subtle Instagram-style "more slides" indicator. Card layout per slide
  //      is unchanged; tapping the visible slide opens that read.
  Widget _dailyRead(_Pal p) {
    final n = _reads.length;
    if (n <= 1) {
      return _tap(() => _openCard('read'),
          _whiteCard(p, _readRow(p, _todayRead), pad: 16));
    }
    return _whiteCard(
      p,
      Stack(children: [
        SizedBox(
          height: 112,
          child: PageView.builder(
            controller: _readPc,
            // A big virtual range so it loops endlessly in both directions.
            itemCount: n * 2000,
            onPageChanged: (i) => setState(() => _readIdx = i % n),
            itemBuilder: (_, i) =>
                _tap(() => _openCard('read'), _readRow(p, _reads[i % n])),
          ),
        ),
        // Floating dots, centred at the bottom — quiet, just "there's more".
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(child: _readDots(p, n, _readIdx)),
        ),
      ]),
      pad: 16,
    );
  }

  // One read slide — identical to the original Daily Read card content.
  Widget _readRow(_Pal p, ReadItem r) => Row(children: [
        Expanded(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  _iconTileSm(
                      p, Icons.menu_book_rounded, p.accentSoft, p.accent),
                  const SizedBox(width: 8),
                  Text('DAILY READ', style: _eyebrow(p.accent, 0.12)),
                ]),
                const SizedBox(height: 9),
                Text(r.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: _serif(18, p.ink, w: FontWeight.w600)),
                const SizedBox(height: 9),
                Text('${r.readingTime} · ${r.category}',
                    style: _body(12.5, p.muted)),
              ]),
        ),
        const SizedBox(width: 14),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child:
              SizedBox(width: 86, height: 86, child: _SoundRippleArt(pal: p)),
        ),
      ]);

  // Subtle "more slides ahead" dots (the active one stretches a little).
  Widget _readDots(_Pal p, int n, int active) => Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < n; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == active
                    ? p.accent
                    : p.muted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
        ],
      );

  // ---- card 4: talk to baby ----
  Widget _talkBaby(_Pal p) => _tap(
        () => _openCard('talk'),
        _whiteCard(
          p,
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _iconTile(p, Icons.auto_stories_rounded, p.accentSoft, p.accent),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('READ TO YOUR BABY', style: _eyebrow(p.accent, 0.12)),
                      const SizedBox(height: 3),
                      Text('Read to your baby tonight',
                          style: _serif(19, p.ink, w: FontWeight.w600)),
                    ]),
              ),
            ]),
            const SizedBox(height: 13),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
              decoration: BoxDecoration(
                  color: p.accentSoft, borderRadius: BorderRadius.circular(15)),
              child: Text(
                  _readAloudToday == null
                      ? 'Choose a few lines to read together.'
                      : '“${_readAloudToday!.body}”',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.fraunces(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      height: 1.45,
                      color: p.accent)),
            ),
            const SizedBox(height: 12),
            _arrowLink(p, 'Read it aloud'),
            // PURE READ-ALOUD: the record/play control was removed from this card
            // per spec. Kept commented for easy revert.
            /*
            const SizedBox(height: 14),
            Row(children: [
              GestureDetector(
                onTap: () => _flash('Playing your recorded hello…'),
                child: Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration:
                      BoxDecoration(color: p.accent, shape: BoxShape.circle),
                  child: Icon(Icons.play_arrow_rounded, color: p.cream, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: _Waveform(heights: _kWaveSmall, color: p.accent2)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => setState(() => _recording
                    ? (_recording = false, _recorded = true)
                    : (_recording = true)),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: p.accent, width: 1.5),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                            color: p.accent2, shape: BoxShape.circle)),
                    const SizedBox(width: 7),
                    Text(_recording ? 'Stop' : 'Record',
                        style: _body(12.5, p.accent, w: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
            */
          ]),
        ),
      );

  // ---- card: scans & appointments (due around now), re-voiced for the partner.
  //      Future scans appear when their week arrives; past / not-done ones live
  //      behind "View all scans". "Already done" ticks one off (shared with her).
  Widget _scansCard(_Pal p) => AnimatedBuilder(
        animation: ScansStore.instance,
        builder: (context, _) {
          final cw = widget.controller.currentWeek;
          final due = scansDueAt(cw)
              .where((m) => !ScansStore.instance.isCompleted(m.id))
              .toList();
          final today = DateTime.now();
          final appts = ScansStore.instance.appointments
              .where((a) => !a.date
                  .isBefore(DateTime(today.year, today.month, today.day)))
              .toList();
          return _whiteCard(
            p,
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _iconTile(
                    p, Icons.event_available_rounded, p.accentSoft, p.accent),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SCANS & APPOINTMENTS',
                            style: _eyebrow(p.accent, 0.12)),
                        const SizedBox(height: 3),
                        Text('Coming up for her',
                            style: _serif(19, p.ink, w: FontWeight.w600)),
                      ]),
                ),
              ]),
              const SizedBox(height: 13),
              if (due.isEmpty && appts.isEmpty)
                Text("Nothing due right now — you're both up to date.",
                    style: _body(14, p.muted))
              else ...[
                for (final m in due) _fScanRow(p, m),
                for (final a in appts) _fApptRow(p, a),
              ],
              const SizedBox(height: 6),
              _tap(_openAllScans, _arrowLink(p, 'View all scans')),
            ]),
          );
        },
      );

  Widget _fScanRow(_Pal p, JourneyMilestone m) {
    final lang = widget.controller.language;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Text(m.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 11),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.title.of(lang), style: _body(14.5, p.ink, w: FontWeight.w700)),
            Text(m.rangeLabel?.of(lang) ?? 'Week ${m.anchorWeek}',
                style: _body(12, p.muted)),
          ]),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => ScansStore.instance.markCompleted(
              scanId: m.id,
              journalTitle: m.title.of(lang),
              week: m.anchorWeek),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.accent, width: 1.4),
            ),
            child:
                Text('Already done', style: _body(12, p.accent, w: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  Widget _fApptRow(_Pal p, Appointment a) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Icon(Icons.event_rounded, size: 18, color: p.accent2),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.title, style: _body(14.5, p.ink, w: FontWeight.w700)),
                  Text(
                      _fmtApptDate(a.date) +
                          (a.time.isNotEmpty ? ' · ${a.time}' : ''),
                      style: _body(12, p.muted)),
                ]),
          ),
        ]),
      );

  static const _scanMonths = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _fmtApptDate(DateTime d) =>
      '${d.day} ${_scanMonths[d.month - 1]} ${d.year}';

  // "View all scans" — a Slate sheet of every scan with a done tick, so he can
  // also clear older ones (handy if they joined the app late).
  void _openAllScans() {
    final p = _p;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => AnimatedBuilder(
        animation: ScansStore.instance,
        builder: (ctx, _) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          maxChildSize: 0.92,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                          width: 42,
                          height: 5,
                          decoration: BoxDecoration(
                              color: p.line,
                              borderRadius: BorderRadius.circular(999)))),
                  const SizedBox(height: 16),
                  Text('All scans', style: _serif(20, p.ink)),
                  const SizedBox(height: 4),
                  Text(
                      'Tick off the ones already done — even older ones, if you joined late.',
                      style: _body(13, p.muted)),
                  const SizedBox(height: 14),
                  Expanded(
                    child: ListView(
                      controller: scroll,
                      children: [
                        for (final m in allMedicalScans()) _fAllScanTile(p, m),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _fAllScanTile(_Pal p, JourneyMilestone m) {
    final lang = widget.controller.language;
    final done = ScansStore.instance.isCompleted(m.id);
    return GestureDetector(
      onTap: () => done
          ? ScansStore.instance.unmarkCompleted(m.id)
          : ScansStore.instance.markCompleted(
              scanId: m.id,
              journalTitle: m.title.of(lang),
              week: m.anchorWeek),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: done ? p.accent : p.line, width: done ? 1.5 : 1),
        ),
        child: Row(children: [
          Text(m.emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title.of(lang),
                      style: _body(14.5, p.ink, w: FontWeight.w700)),
                  Text(m.rangeLabel?.of(lang) ?? 'Week ${m.anchorWeek}',
                      style: _body(12, p.muted)),
                ]),
          ),
          Icon(done ? Icons.check_circle_rounded : Icons.circle_outlined,
              color: done ? p.accent : p.muted, size: 24),
        ]),
      ),
    );
  }

  // ---- card 5: stories & myth — REMOVED from the father's daily home (kept
  //      here, unused, for an easy revert). The full collection in Tools was
  //      removed too.
  // ignore: unused_element
  Widget _storiesMyth(_Pal p) {
    final tale = _todayTale;
    return _tap(
      () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => FatherTaleReadScreen(tale: tale))),
      _whiteCard(
        p,
        Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(width: 86, height: 86, child: _OceanArt(pal: p)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    _iconTileSm(
                        p, Icons.history_edu_rounded, p.warmSoft, p.accent2),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('STORIES, FABLES & MYTH',
                          style: _eyebrow(p.accent2, 0.1)),
                    ),
                    GestureDetector(
                      onTap: _showTaleCustomize,
                      behavior: HitTestBehavior.opaque,
                      child:
                          Icon(Icons.tune_rounded, size: 18, color: p.muted),
                    ),
                  ]),
                  const SizedBox(height: 9),
                  Text(tale.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: _serif(18, p.ink, w: FontWeight.w600)),
                  const SizedBox(height: 9),
                  Row(children: [
                    Text('${fatherTaleKindTag(tale.kind)} · read aloud',
                        style: _body(13, p.accent, w: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text('→', style: _body(15, p.accent)),
                  ]),
                ]),
          ),
        ]),
        pad: 16,
      ),
    );
  }

  // Customize which kinds the daily tale draws from (off = a mix of all three).
  void _showTaleCustomize() {
    final p = _p;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          Widget tile(FatherTaleKind k) {
            final on = _taleKinds.contains(k);
            return GestureDetector(
              onTap: () {
                setSheet(() => on ? _taleKinds.remove(k) : _taleKinds.add(k));
                setState(() {});
                _saveTaleKinds();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: on ? p.accent : p.line, width: on ? 1.5 : 1),
                ),
                child: Row(children: [
                  Expanded(
                      child: Text(fatherTaleKindLabel(k),
                          style: _body(15, p.ink, w: FontWeight.w600))),
                  Icon(
                      on
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      color: on ? p.accent : p.muted,
                      size: 22),
                ]),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What would you like to read?', style: _serif(20, p.ink)),
                  const SizedBox(height: 6),
                  Text(
                      'Pick the kinds you want. Leave all off for a mix of everything.',
                      style: _body(13, p.muted)),
                  const SizedBox(height: 16),
                  for (final k in FatherTaleKind.values) tile(k),
                ]),
          );
        },
      ),
    );
  }

  // ---- card 6: journal ----
  // Father journal card — the four quick-add circles (memory / note / photo /
  // voice) into the separate FatherJournalStore, plus a live recent preview.
  // (The old local-only journal overlay '_journalBody' is kept for revert.)
  Widget _journalCard(_Pal p) => _whiteCard(
        p,
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _iconTile(p, Icons.edit_outlined, p.accentSoft, p.accent),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR JOURNAL', style: _eyebrow(p.accent, 0.12)),
                    const SizedBox(height: 3),
                    Text('A note to your baby',
                        style: _serif(19, p.ink, w: FontWeight.w600)),
                  ]),
            ),
            GestureDetector(
              onTap: _showJournalInfo,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 2),
                child:
                    Icon(Icons.info_outline_rounded, size: 19, color: p.muted),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            _journalCircle(
                p, Icons.edit_note_rounded, 'Memory', () => _addJournal('memory')),
            _journalCircle(
                p, Icons.favorite_rounded, 'For baby', () => _addJournal('baby')),
            _journalCircle(
                p, Icons.add_a_photo_rounded, 'Photo', () => _addJournal('photo')),
            _journalCircle(
                p, Icons.mic_none_rounded, 'Voice', () => _addJournal('voice')),
          ]),
          AnimatedBuilder(
            animation: FatherJournalStore.instance,
            builder: (_, _) {
              final entries = FatherJournalStore.instance.entries;
              if (entries.isEmpty) return const SizedBox.shrink();
              final recent = entries.first;
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _tap(
                  _openFatherJournal,
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: p.warmSoft,
                          borderRadius: BorderRadius.circular(7)),
                      child: Text(_journalKindLabel(recent).toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                              color: p.accent2)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                        child: Text('"${_journalPreview(recent)}"',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: _body(13.5, p.ink, h: 1.45))),
                  ]),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _tap(_openFatherJournal, _arrowLink(p, 'See all entries')),
        ]),
      );

  Widget _journalCircle(
          _Pal p, IconData icon, String label, VoidCallback onTap) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration:
                  BoxDecoration(color: p.accentSoft, shape: BoxShape.circle),
              child: Icon(icon, color: p.accent, size: 21),
            ),
            const SizedBox(height: 6),
            Text(label, style: _body(11, p.muted, w: FontWeight.w600)),
          ]),
        ),
      );

  void _openFatherJournal() => Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => FatherJournalScreen(controller: widget.controller)));

  // The "what is this" note, moved off the card into an (i) tap to save space.
  void _showJournalInfo() {
    final p = _p;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your journal', style: _serif(20, p.ink)),
              const SizedBox(height: 8),
              Text(
                  'Your memories, photos and voice notes will live here. Tap a circle above to add one — a memory, a note to your baby, a photo or a voice note.',
                  style: _body(14, p.muted, h: 1.5)),
            ]),
      ),
    );
  }

  void _addJournal(String kind) {
    final c = widget.controller;
    final add = FatherJournalStore.instance.addEntry;
    switch (kind) {
      case 'memory':
        openJournalText(context, c, JournalEntryType.memory,
            onAdd: add, father: true);
        break;
      case 'baby':
        openJournalText(context, c, JournalEntryType.noteForBaby,
            onAdd: add, father: true);
        break;
      case 'photo':
        openJournalAddPhoto(context, c, onAdd: add, father: true);
        break;
      case 'voice':
        openJournalRecordVoice(context, c, onAdd: add, father: true);
        break;
    }
  }

  String _journalKindLabel(JournalEntry e) {
    if (e.images.isNotEmpty) return 'Photo';
    if (e.audios.isNotEmpty) return 'Voice';
    return e.type == JournalEntryType.noteForBaby ? 'For baby' : 'Memory';
  }

  String _journalPreview(JournalEntry e) {
    if (e.title.trim().isNotEmpty) return e.title;
    if (e.description.trim().isNotEmpty) return e.description;
    if (e.images.isNotEmpty) return 'Added a photo';
    if (e.audios.isNotEmpty) return 'Recorded a voice note';
    return 'A memory';
  }

  // ---- bottom tab bar ----
  Widget _tabBar(_Pal p) => Container(
        height: 72,
        decoration: BoxDecoration(
          color: p.card,
          border: Border(top: BorderSide(color: p.line)),
        ),
        padding: const EdgeInsets.only(top: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tab(p, Icons.wb_sunny_outlined, 'Today', active: true),
            _tab(p, Icons.menu_book_rounded, 'Reads', onTap: () => _openCard('read')),
            _tab(p, Icons.auto_stories_rounded, 'Read', onTap: () => _openCard('talk')),
            _tab(p, Icons.edit_outlined, 'Journal', onTap: _openFatherJournal),
            _tab(p, Icons.person_outline_rounded, 'You',
                onTap: () => _flash('That space is coming soon')),
          ],
        ),
      );

  Widget _tab(_Pal p, IconData icon, String label,
      {bool active = false, VoidCallback? onTap}) {
    final c = active ? p.accent : p.muted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 21, color: c),
        const SizedBox(height: 4),
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                color: c)),
      ]),
    );
  }

  // ===========================================================================
  //  Detail overlay (slides up)
  // ===========================================================================
  Widget _detailOverlay(_Pal p) {
    final d = _shownCard == null ? null : _kDetails[_shownCard];
    return AnimatedSlide(
      offset: _open ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      child: IgnorePointer(
        ignoring: !_open,
        child: Container(
          color: p.bg,
          child: d == null
              ? const SizedBox.expand()
              : Column(children: [
                  // header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                    child: Row(children: [
                      GestureDetector(
                        onTap: _closeCard,
                        child: Container(
                          width: 38,
                          height: 38,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: p.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.line),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              color: p.ink, size: 20),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                          child: Text(d.eyebrow.toUpperCase(),
                              style: _eyebrow(p.accent, 0.12))),
                    ]),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 6, 22, 32),
                      children: _detailBody(p, d),
                    ),
                  ),
                  if (d.id != 'journal' && d.cta.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                      decoration: BoxDecoration(
                        color: p.bg,
                        border: Border(top: BorderSide(color: p.line)),
                      ),
                      child: GestureDetector(
                        onTap: _detailPrimary,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: p.accent,
                              borderRadius: BorderRadius.circular(16)),
                          child: Text(d.cta,
                              style: _body(15, p.cream, w: FontWeight.w600)),
                        ),
                      ),
                    ),
                ]),
        ),
      ),
    );
  }

  List<Widget> _detailBody(_Pal p, _Detail d) {
    final isRead = d.id == 'read';
    final r = isRead ? _todayRead : null;
    final out = <Widget>[
      Text(isRead ? r!.title : d.title, style: _serif(27, p.ink)),
    ];
    final metaStr = isRead ? '${r!.readingTime} · ${r.category}' : d.meta;
    if (metaStr.isNotEmpty) {
      out.add(const SizedBox(height: 9));
      out.add(Text(metaStr, style: _body(13, p.muted, w: FontWeight.w500)));
    }
    if (isRead) {
      final rr = r!;
      out.add(const SizedBox(height: 18));
      out.add(ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(height: 170, child: _SoundRippleArt(pal: p))));
      for (final para in rr.body.split('\n\n')) {
        out.add(const SizedBox(height: 16));
        out.add(Text(para,
            style: _body(15.5, p.ink.withValues(alpha: 0.9), h: 1.62)));
      }
    }
    if (d.id == 'story') {
      out.add(const SizedBox(height: 18));
      out.add(ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(height: 170, child: _OceanArt(pal: p))));
    }
    if (d.id == 'talk') {
      final today = _readAloudToday;
      out.add(const SizedBox(height: 18));
      out.add(Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: p.accentSoft, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (today?.title != null && today!.title!.trim().isNotEmpty) ...[
            Text(today.title!, style: _serif(18, p.accent, w: FontWeight.w700)),
            const SizedBox(height: 8),
          ],
          Text(
              today == null
                  ? 'Choose a few lines to read together.'
                  : '“${today.body}”',
              style: GoogleFonts.fraunces(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                  color: p.accent)),
        ]),
      ));
    }
    if (d.id == 'partner') {
      out.add(const SizedBox(height: 18));
      out.add(Container(
        padding: const EdgeInsets.fromLTRB(17, 16, 17, 16),
        decoration: BoxDecoration(
            color: p.warmSoft, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DO THIS TODAY', style: _eyebrow(p.accent2, 0.12)),
          const SizedBox(height: 5),
          Text(
              'Take dinner off her plate — cook her favourite, or order it before she has to ask. Then rub her lower back for five minutes, no phone.',
              style: _body(15, p.ink)),
        ]),
      ));
    }
    if (d.paras.isNotEmpty && !isRead) {
      out.add(const SizedBox(height: 18));
      for (final para in d.paras) {
        out.add(Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Text(para,
              style: _body(15.5, p.ink.withValues(alpha: 0.9), h: 1.62)),
        ));
      }
    }
    // Support-your-partner: a longer list of concrete ways to help this week.
    if (d.id == 'partner' && d.list.isNotEmpty) {
      out.add(const SizedBox(height: 6));
      out.add(Text('MORE WAYS TO HELP THIS WEEK', style: _eyebrow(p.muted, 0.12)));
      out.add(const SizedBox(height: 12));
      out.add(Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(children: [
          for (var i = 0; i < d.list.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: i < d.list.length - 1
                    ? Border(bottom: BorderSide(color: p.line))
                    : null,
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.favorite_rounded, size: 14, color: p.accent2),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(d.list[i], style: _body(14.5, p.ink, h: 1.4))),
              ]),
            ),
        ]),
      ));
    }
    if (d.id == 'tip' && d.list.isNotEmpty) {
      out.add(const SizedBox(height: 4));
      out.add(Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            for (var i = 0; i < d.list.length; i++)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: i < d.list.length - 1
                      ? Border(bottom: BorderSide(color: p.line))
                      : null,
                ),
                child: Row(children: [
                  Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                          color: p.accent2, shape: BoxShape.circle)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(d.list[i], style: _body(14.5, p.ink))),
                ]),
              ),
          ],
        ),
      ));
    }
    // "MORE TO READ ALOUD" list removed — this is a daily section, so just the
    // one piece (matching the mother's daily Samvad). Kept commented for revert.
    // PURE READ-ALOUD: the record block was also removed here (see _recordBlock).
    if (d.id == 'journal') {
      out.addAll(_journalBody(p));
    }
    return out;
  }

  // ignore: unused_element  (kept for revert — see PURE READ-ALOUD note above)
  Widget _recordBlock(_Pal p) => Column(children: [
        GestureDetector(
          onTap: () => setState(() => _recording
              ? (_recording = false, _recorded = true)
              : (_recording = true)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 78,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _recording ? p.accent2 : p.accent,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                    color: Color(0x3822333B),
                    blurRadius: 24,
                    offset: Offset(0, 10)),
              ],
            ),
            child: Icon(_recording ? Icons.stop_rounded : Icons.mic_none_rounded,
                color: p.cream, size: 30),
          ),
        ),
        const SizedBox(height: 12),
        Text(
            _recording
                ? 'Recording… tap to stop'
                : (_recorded
                    ? 'Saved · tap to re-record'
                    : 'Tap to record your voice'),
            style: _body(13, p.muted, w: FontWeight.w600)),
        const SizedBox(height: 12),
        _Waveform(
            heights: _kWaveBig, color: _recorded ? p.accent : p.line, height: 34),
      ]);

  List<Widget> _journalBody(_Pal p) => [
        const SizedBox(height: 18),
        Container(
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          padding: const EdgeInsets.all(15),
          child: TextField(
            controller: _draft,
            maxLines: null,
            minLines: 4,
            style: _body(15, p.ink, h: 1.55),
            decoration: InputDecoration.collapsed(
              hintText: "Write to your baby, or just jot today's thought…",
              hintStyle: _body(15, p.muted),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _saveEntry,
          child: Container(
            padding: const EdgeInsets.all(14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.accent, borderRadius: BorderRadius.circular(14)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.add_rounded, color: p.cream, size: 18),
              const SizedBox(width: 8),
              Text('Save entry', style: _body(14.5, p.cream, w: FontWeight.w600)),
            ]),
          ),
        ),
        const SizedBox(height: 24),
        Text('RECENT ENTRIES', style: _eyebrow(p.muted, 0.12)),
        const SizedBox(height: 12),
        for (final e in _entries)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.date.toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: p.accent2)),
              const SizedBox(height: 6),
              Text(e.text, style: _body(14.5, p.ink, h: 1.5)),
            ]),
          ),
      ];

  // ===========================================================================
  //  Mom-view bottom sheet
  // ===========================================================================
  Widget _momSheet(_Pal p) => IgnorePointer(
        ignoring: !_momOpen,
        child: Stack(children: [
          GestureDetector(
            onTap: () => setState(() => _momOpen = false),
            child: AnimatedOpacity(
              opacity: _momOpen ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(color: const Color(0x6B141E28)),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSlide(
              offset: _momOpen ? Offset.zero : const Offset(0, 1),
              duration: const Duration(milliseconds: 340),
              curve: Curves.easeOutCubic,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                decoration: BoxDecoration(
                  color: p.card,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                          color: p.line,
                          borderRadius: BorderRadius.circular(999))),
                  const SizedBox(height: 18),
                  Row(children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: Color(0xFFF3E3EC), shape: BoxShape.circle),
                      child: Text('M',
                          style: GoogleFonts.fraunces(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFA2417A))),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Switch to Mom's view",
                                style: _serif(20, p.ink, w: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text("You'll both stay in sync.",
                                style: _body(13, p.muted)),
                          ]),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Text(
                      "Mom's daily space — her body this week, cravings, kicks and her own journal — lives one tap away. Anything you mark here shows up for her too.",
                      style: _body(14.5, p.ink.withValues(alpha: 0.85), h: 1.55)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() => _momOpen = false);
                      _flash("Mom's view lives in the other tab");
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: const Color(0xFF6A30B6),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text("Open Mom's view",
                          style: _body(15, Colors.white, w: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _momOpen = false),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      alignment: Alignment.center,
                      child: Text("Stay in Dad's view",
                          style: _body(14, p.muted, w: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      );

  // ===========================================================================
  //  Toast
  // ===========================================================================
  Widget _toastPill(_Pal p) => Positioned(
        left: 0,
        right: 0,
        bottom: 96,
        child: IgnorePointer(
          child: Center(
            child: AnimatedSlide(
              offset: _toastShow ? Offset.zero : const Offset(0, 0.3),
              duration: const Duration(milliseconds: 300),
              child: AnimatedOpacity(
                opacity: _toastShow ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: p.ink,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x4D141E28),
                          blurRadius: 26,
                          offset: Offset(0, 10)),
                    ],
                  ),
                  child: Text(_toast,
                      style: _body(13, Colors.white, w: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ),
      );

  // ---- small shared builders ----
  Widget _tap(VoidCallback onTap, Widget child) => GestureDetector(
      onTap: onTap, behavior: HitTestBehavior.opaque, child: child);

  Widget _whiteCard(_Pal p, Widget child, {double pad = 18}) => Container(
        width: double.infinity,
        padding: EdgeInsets.all(pad),
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p.line),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0D1C2830), blurRadius: 18, offset: Offset(0, 6)),
          ],
        ),
        child: child,
      );

  Widget _iconTile(_Pal p, IconData icon, Color bg, Color fg) => Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: fg, size: 22),
      );

  Widget _iconTileSm(_Pal p, IconData icon, Color bg, Color fg) => Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: fg, size: 18),
      );

  Widget _softCircle(double d, Color c) => Container(
      width: d,
      height: d,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle));

  Widget _arrowLink(_Pal p, String label) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: _body(13.5, p.accent, w: FontWeight.w600)),
        const SizedBox(width: 6),
        Text('→', style: _body(15, p.accent)),
      ]);
}

// ignore: unused_element  (used only by the commented-out read-aloud record row)
const List<double> _kWaveSmall = [
  10, 18, 26, 14, 22, 12, 20, 28, 16, 22, 12, 18, 24, 14
];
const List<double> _kWaveBig = [
  12, 22, 34, 18, 28, 40, 24, 34, 16, 26, 38, 20, 30, 14
];

// ---- waveform (static bars) ----
class _Waveform extends StatelessWidget {
  const _Waveform({required this.heights, required this.color, this.height = 30});
  final List<double> heights;
  final Color color;
  final double height;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (final hh in heights)
              Container(
                  width: 4,
                  height: hh,
                  decoration: BoxDecoration(
                      color: color, borderRadius: BorderRadius.circular(2))),
          ],
        ),
      );
}

// ===========================================================================
//  Daily-read art — soft expanding "sound" ripples + pulsing centre dot.
// ===========================================================================
class _SoundRippleArt extends StatefulWidget {
  const _SoundRippleArt({required this.pal});
  final _Pal pal;
  @override
  State<_SoundRippleArt> createState() => _SoundRippleArtState();
}

class _SoundRippleArtState extends State<_SoundRippleArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))
        ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pal;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return LayoutBuilder(builder: (context, box) {
          final w = box.maxWidth;
          final h = box.maxHeight;
          final base = w < h ? w : h;
          final dot = (0.5 + 0.15 * (1 - (2 * ((t * 2) % 1 - 0.5)).abs()));
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [p.accent, const Color(0x8C101A22)],
              ),
            ),
            child: Stack(alignment: Alignment.center, children: [
              for (var i = 0; i < 3; i++)
                _ripple(base, (t + i / 3) % 1.0, p.cream),
              // centre dot
              Container(
                width: base * 0.14 * dot,
                height: base * 0.14 * dot,
                decoration: BoxDecoration(
                  color: p.accent2,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: p.accent2.withValues(alpha: 0.7), blurRadius: 14),
                  ],
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  Widget _ripple(double base, double prog, Color color) {
    final scale = 0.2 + prog * 1.8;
    final opacity = (prog < 0.7 ? 0.9 : (1 - prog) / 0.3 * 0.22).clamp(0.0, 0.9);
    return Opacity(
      opacity: opacity,
      child: Container(
        width: base * 0.48 * scale,
        height: base * 0.48 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
      ),
    );
  }
}

// ===========================================================================
//  Story art — a warm glow rising over a slowly churning ocean.
// ===========================================================================
class _OceanArt extends StatefulWidget {
  const _OceanArt({required this.pal});
  final _Pal pal;
  @override
  State<_OceanArt> createState() => _OceanArtState();
}

class _OceanArtState extends State<_OceanArt>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 24))
        ..repeat();
  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pal;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        final breathe = 1 + 0.09 * (1 - (2 * ((t * 4.3) % 1 - 0.5)).abs());
        return ClipRect(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [p.accent, p.accent2],
                stops: const [0.3, 1.0],
              ),
            ),
            child: LayoutBuilder(builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              return Stack(children: [
                // sun
                Positioned(
                  left: w * 0.32,
                  top: h * 0.16,
                  child: Transform.scale(
                    scale: breathe,
                    child: Container(
                      width: w * 0.36,
                      height: w * 0.36,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFFCEFD8), Color(0xFFE0915B)],
                          stops: [0.0, 0.72],
                        ),
                        boxShadow: [
                          BoxShadow(color: Color(0x8CFCEFD8), blurRadius: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // churning waves
                Positioned(
                  left: -w * 0.32,
                  bottom: -h * 0.62,
                  child: Transform.rotate(
                    angle: t * 6.283,
                    child: Container(
                      width: w * 1.64,
                      height: h * 1.2,
                      decoration: BoxDecoration(
                        color: const Color(0x800E1E28),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.elliptical(160, 120),
                          topRight: Radius.elliptical(120, 160),
                          bottomLeft: Radius.elliptical(140, 110),
                          bottomRight: Radius.elliptical(110, 140),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -w * 0.26,
                  bottom: -h * 0.72,
                  child: Transform.rotate(
                    angle: -t * 4.188,
                    child: Container(
                      width: w * 1.52,
                      height: h * 1.2,
                      decoration: BoxDecoration(
                        color: const Color(0x520E1E28),
                        borderRadius: BorderRadius.circular(w * 0.5),
                      ),
                    ),
                  ),
                ),
              ]);
            }),
          ),
        );
      },
    );
  }
}
