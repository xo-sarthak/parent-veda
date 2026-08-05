// =============================================================================
//  AskVedaScreen - parenting Ask Veda (SAME UI as the pregnancy app's Ask Veda)
// -----------------------------------------------------------------------------
//  A faithful port of the pregnancy "Ask Veda Results" design (gradient wash, the
//  pinned white search pill, stage-wise suggestion cards, and the fixed 7-section
//  result: Veda Answer → What this means → Recommended actions → More information
//  → Community → Products → disclaimer). Only the FUNCTION differs: it runs the
//  shared engine over the PARENTING corpus (parentingVedaAnswer). Reached from
//  the bottom nav (openPpTab 1). No emojis (parenting rule) - line icons instead.
// =============================================================================

import 'dart:math';
import 'pp_child_profile.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/app_language.dart';
import '../../widgets/mic_dictation_button.dart';
// My Child is reached via the bottom-nav home tab (openPpTab 0) now.
// import 'my_child_screen.dart';
import 'pp_common.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';
import '../../services/remote/ask_veda_service.dart';

// ---- design palette (identical to the pregnancy Ask Veda) --------------------
const _vBgTop = Color(0xFFF8F4FD);
const _vBgMid = Color(0xFFF2EBF9);
const _vBgBot = Color(0xFFEFE7F6);
const _vPurple = Color(0xFF6D28D9);
const _vPurple2 = Color(0xFF7C3AED);
const _vCoral = Color(0xFFF0476A);
const _vInk = Color(0xFF241640);
const _vInk2 = Color(0xFF2A1B47);
const _vBody = Color(0xFF352A4A);
const _vBody2 = Color(0xFF4A4263);
const _vMuted = Color(0xFF948BA6);
const _vMuted2 = Color(0xFF9B8BB5);
const _vCardBorder = Color(0x147C3AED);
const _vDivider = Color(0xFFF4EEFA);
const List<BoxShadow> _vCardShadow = [
  BoxShadow(color: Color(0x0D281646), blurRadius: 6, offset: Offset(0, 2)),
  BoxShadow(color: Color(0x14602EA0), blurRadius: 30, offset: Offset(0, 16), spreadRadius: -10),
];

class AskVedaScreen extends StatefulWidget {
  const AskVedaScreen({super.key, this.initialQuery});

  /// When provided (e.g. from a "FAQ" deep-link elsewhere in the app), the
  /// screen opens straight onto the answer for this question.
  final String? initialQuery;

  @override
  State<AskVedaScreen> createState() => _AskVedaScreenState();
}

class _AskVedaScreenState extends State<AskVedaScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _rng = Random();

  String? _query;
  AskVedaResult? _feed;   // the backend's full 7-section response
  bool _loading = false;  // /ask is in flight
  bool _failed = false;   // backend unreachable → "connect to the internet"
  final Map<String, List<String>> _picked = {};

  // Stage-wise suggestions (icons, not emojis).
  static const List<(String, IconData, List<String>)> _suggest = [
    ('Sleep', Icons.bedtime_outlined, [
      'Why does he wake every 2 hours at night?',
      'Is the 4-month sleep regression normal?',
      'How do I help him self-settle?',
      'How many naps does he need at 4 months?',
    ]),
    ('Feeding', Icons.restaurant_outlined, [
      'When should I start solids?',
      'How much milk does he need now?',
      'Is he getting enough milk?',
      'What are good first foods?',
    ]),
    ('Development', Icons.psychology_outlined, [
      'Is he on track at 4 months?',
      'How can I encourage rolling?',
      'Why is he suddenly so fussy?',
      'How do I support his language?',
    ]),
    ('Health', Icons.monitor_heart_outlined, [
      'What should I do for a fever?',
      'The 4-month vaccines, explained',
      'Could this be teething?',
    ]),
    ('For you', Icons.favorite_border, [
      'I’m exhausted - is that normal?',
      'How do I cope with the fourth-trimester fog?',
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _roll();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(q);
      });
    }
  }

  void _roll() {
    _picked.clear();
    for (final sec in _suggest) {
      final qs = [...sec.$3]..shuffle(_rng);
      _picked[sec.$1] = qs.take(3).toList();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // The answer comes from the RAG backend now (the offline engine is retired from
  // the answer path). NO domain gating — one mother, one journey; her child's age
  // rides along as CONTEXT so pregnancy questions come back in the past tense.
  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _query = t;
      _feed = null;
      _failed = false;
      _loading = true;
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });

    final res = await AskVedaService.ask(
      t,
      childAgeMonths: ChildProfileStore.instance.ageInMonths,
    );
    if (!mounted || _query != t) return; // ignore stale / superseded replies
    setState(() {
      _loading = false;
      if (res != null) {
        _feed = res;
      } else {
        _failed = true; // offline / server down → connect-to-internet state
      }
    });
  }

  void _clearQuery() => setState(() {
        _query = null;
        _feed = null;
        _loading = false;
        _failed = false;
        _ctrl.clear();
      });

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));
  void _open(Widget w) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => w));

  @override
  Widget build(BuildContext context) {
    final hasResult = _query != null;
    return Scaffold(
      backgroundColor: _vBgMid,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [_vBgTop, _vBgMid, _vBgBot], stops: [0.0, 0.52, 1.0]),
          ),
          child: SafeArea(
            child: Column(children: [
              _topBar(),
              Expanded(
                child: Stack(children: [
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      switchInCurve: Curves.easeOut,
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: SlideTransition(position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim), child: child),
                      ),
                      child: hasResult ? _resultScroll() : _initialScroll(),
                    ),
                  ),
                  AnimatedAlign(
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeInOutCubic,
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                      child: AnimatedSwitcher(duration: const Duration(milliseconds: 240), child: _inputPill(result: hasResult)),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 1)),
      ]),
    );
  }

  // ---- top bar : mark · Ask Veda wordmark · child avatar --------------------
  Widget _topBar() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Image.asset('assets/brand/pv-mark.png', width: 34, height: 34, fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(Icons.auto_awesome_rounded, size: 26, color: _vPurple)),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_awesome_rounded, size: 17, color: _vCoral),
            const SizedBox(width: 7),
            RichText(
              text: TextSpan(
                style: GoogleFonts.fraunces(fontSize: 23, fontWeight: FontWeight.w600, letterSpacing: -0.2),
                children: const [
                  TextSpan(text: 'Ask ', style: TextStyle(color: _vPurple)),
                  TextSpan(text: 'Veda', style: TextStyle(color: _vCoral)),
                ],
              ),
            ),
          ]),
          GestureDetector(
            onTap: () => openPpTab(context, 0), // My Child is the home tab now
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_vPurple2, _vCoral]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Color(0x4D6D28D9), blurRadius: 9, offset: Offset(0, 3))],
              ),
              child: Text('A', style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ]),
      );

  // ---- search pill ----------------------------------------------------------
  Widget _inputPill({required bool result}) => Container(
        key: ValueKey(result),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: result ? 12 : 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x1A7C3AED)),
          boxShadow: const [
            BoxShadow(color: Color(0x0D281646), blurRadius: 6, offset: Offset(0, 2)),
            BoxShadow(color: Color(0x334D2EA0), blurRadius: 30, offset: Offset(0, 14), spreadRadius: -16),
          ],
        ),
        child: result ? _pillResult() : _pillEdit(),
      );

  Widget _pillEdit() => Row(children: [
        const Icon(Icons.search_rounded, size: 21, color: Color(0xFF9384B0)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onSubmitted: _send,
            cursorColor: _vPurple,
            cursorWidth: 2,
            style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: _vInk),
            decoration: InputDecoration(
              hintText: 'Ask Veda about ${ChildProfileStore.instance.nameMid}…',
              filled: false,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              hintStyle: GoogleFonts.manrope(fontSize: 14.5, color: const Color(0xFFB6A9CC)),
            ),
          ),
        ),
        MicDictateButton(controller: _ctrl, s: const S(AppLanguage.english), color: _vPurple),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => _send(_ctrl.text),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: _vPurple, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 19),
          ),
        ),
      ]);

  Widget _pillResult() => Row(children: [
        const Icon(Icons.search_rounded, size: 21, color: Color(0xFF9384B0)),
        const SizedBox(width: 11),
        Expanded(child: Text(_query ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: _vInk))),
        GestureDetector(onTap: _clearQuery, child: const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Icon(Icons.close_rounded, size: 19, color: Color(0xFFB6A9CC)))),
        const SizedBox(width: 8),
        Container(width: 1, height: 20, color: const Color(0xFFEADFF5)),
        const SizedBox(width: 12),
        GestureDetector(onTap: _clearQuery, child: const Icon(Icons.mic_none_rounded, size: 21, color: _vPurple)),
      ]);

  // ---- initial view : suggestions -------------------------------------------
  Widget _initialScroll() => ListView(
        key: const ValueKey('initial'),
        padding: const EdgeInsets.fromLTRB(18, 78, 18, 112),
        children: [
          Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('What’s on your mind?', style: GoogleFonts.fraunces(fontSize: 21, fontWeight: FontWeight.w600, color: _vInk2)),
                const SizedBox(height: 3),
                Text('Tap a question, or type your own below.', style: GoogleFonts.manrope(fontSize: 12.5, color: _vMuted)),
              ]),
            ),
            IconButton(
              tooltip: 'Shuffle questions',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.shuffle_rounded, size: 20, color: _vPurple),
              onPressed: () => setState(_roll),
            ),
          ]),
          const SizedBox(height: 14),
          for (final sec in _suggest) _suggestionSection(sec),
        ],
      );

  Widget _suggestionSection((String, IconData, List<String>) sec) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _vCardBorder), boxShadow: _vCardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(sec.$2, size: 17, color: _vPurple2),
            const SizedBox(width: 8),
            Text(sec.$1, style: GoogleFonts.plusJakartaSans(fontSize: 14.5, fontWeight: FontWeight.w800, color: _vInk)),
          ]),
          const SizedBox(height: 11),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final q in (_picked[sec.$1] ?? sec.$3)) _qChip(q)]),
        ]),
      );

  Widget _qChip(String text) => GestureDetector(
        onTap: () => _send(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(color: _vPurple.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(99), border: Border.all(color: const Color(0x1F7C3AED))),
          child: Text(text, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: _vPurple)),
        ),
      );

  // ---- result view : the fixed 7 sections, all from the backend feed --------
  Widget _resultScroll() => ListView(
        key: const ValueKey('result'),
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(18, 78, 18, 112),
        children: _loading
            ? [_loadingCard()]
            : (_failed || _feed == null)
                ? [_offlineCard()]
                : _feedSections(_feed!),
      );

  // The 7 sections. 1-3 from the LLM; 4/6/7 (+ videos, community) always render —
  // an empty section shows "Coming soon" so the format never collapses.
  List<Widget> _feedSections(AskVedaResult f) => [
        _answerCard(f.answer),
        if (f.meaning.isNotEmpty) _meaning(f.meaning),
        if (f.actions.isNotEmpty) _actions(f.actions),
        _moreInfo(f),
        _communityComingSoon(),
        _productsFeed(f),
        _servicesFeed(f),
        _disclaimer(),
      ];

  Widget _loadingCard() => _card(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Row(children: [
          const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: _vPurple2)),
          const SizedBox(width: 14),
          Text('Asking Veda…', style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _vInk)),
        ]),
      );

  Widget _offlineCard() => _card(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.wifi_off_rounded, size: 20, color: _vCoral),
            const SizedBox(width: 9),
            Expanded(child: Text('Connect to the internet', style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: _vInk))),
          ]),
          const SizedBox(height: 10),
          Text('Ask Veda needs a connection to give you a personalized, up-to-date answer. Please check your internet and try again.',
              style: GoogleFonts.manrope(fontSize: 13.5, height: 1.55, color: _vBody2)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () { if (_query != null) _send(_query!); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(color: _vPurple, borderRadius: BorderRadius.circular(99)),
              child: Text('Retry', style: GoogleFonts.manrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
          ),
        ]),
      );

  Widget _comingSoon(String label) => _card(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        child: Row(children: [
          const Icon(Icons.hourglass_empty_rounded, size: 17, color: Color(0xFFB6A9CC)),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: _vMuted2))),
        ]),
      );

  Widget _card({required Widget child, EdgeInsets? padding, double radius = 18, Gradient? gradient}) => Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? Colors.white : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: _vCardBorder),
          boxShadow: _vCardShadow,
        ),
        child: child,
      );

  Widget _sectionHead(IconData icon, String title, {double top = 28}) => Padding(
        padding: EdgeInsets.fromLTRB(2, top, 2, 13),
        child: Row(children: [
          Icon(icon, size: 20, color: _vPurple2),
          const SizedBox(width: 10),
          Expanded(child: Text(title, style: GoogleFonts.fraunces(fontSize: 19, fontWeight: FontWeight.w600, letterSpacing: -0.2, color: _vInk2))),
        ]),
      );

  Widget _contextChip() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFF3E9FF), Color(0xFFFBEAF1)]), borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.child_care_rounded, size: 14, color: _vPurple),
            const SizedBox(width: 6),
            // Real age, not a hardcoded "4 months" - and flexible, because a
            // child's name is not a fixed length.
            Flexible(
              child: Text(
                  '${ChildProfileStore.instance.name} · ${ChildProfileStore.instance.ageLabel}',
                  style: GoogleFonts.manrope(fontSize: 11.5, fontWeight: FontWeight.w800, color: _vPurple),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ]),
        ),
      );

  Widget _speakerButton() => GestureDetector(
        onTap: () => _snack('Listening to answers is coming soon'),
        child: Container(width: 32, height: 32, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFF6F0FE), shape: BoxShape.circle), child: const Icon(Icons.volume_up_rounded, size: 18, color: _vPurple2)),
      );

  // S1 - Veda Answer
  Widget _answerCard(String answer) => _card(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.white, Color(0xFFFCFAFF)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 20, color: _vPurple2),
            const SizedBox(width: 9),
            Text('Veda Answer', style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w800, color: _vInk)),
            const Spacer(),
            _speakerButton(),
          ]),
          const SizedBox(height: 13),
          _contextChip(),
          const SizedBox(height: 14),
          Text(answer, style: GoogleFonts.manrope(fontSize: 14.5, height: 1.6, fontWeight: FontWeight.w500, color: _vBody)),
        ]),
      );

  // S2 - What this means for you
  Widget _meaning(String meaning) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead(Icons.favorite_rounded, 'What this means for you'),
        _card(padding: const EdgeInsets.fromLTRB(17, 17, 18, 17), child: Text(meaning, style: GoogleFonts.manrope(fontSize: 14.5, height: 1.62, color: _vBody2))),
      ]);

  // S3 - Recommended next actions
  Widget _actions(List<String> actions) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead(Icons.task_alt_rounded, 'Recommended next actions'),
        _card(padding: EdgeInsets.zero, child: Column(children: [
          for (int i = 0; i < actions.length; i++) _actionRow(actions[i], last: i == actions.length - 1),
        ])),
      ]);

  Widget _actionRow(String action, {required bool last}) {
    final en = action.toLowerCase();
    final coral = en.contains('call') || en.contains('paediatrician') || en.contains('doctor');
    final icon = coral
        ? Icons.call_rounded
        : en.contains('journal') || en.contains('save') || en.contains('note')
            ? Icons.event_note_rounded
            : en.contains('child') || en.contains('explore') || en.contains('read')
                ? Icons.menu_book_rounded
                : Icons.task_alt_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(border: last ? null : const Border(bottom: BorderSide(color: _vDivider))),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: coral ? const [Color(0xFFFFE9EE), Color(0xFFFCE0E8)] : const [Color(0xFFF3E9FF), Color(0xFFEDE2FC)]),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 21, color: coral ? _vCoral : _vPurple),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(action, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: _vInk))),
      ]),
    );
  }

  // S4 - More information (articles/reads) + a Videos sub-section
  Widget _moreInfo(AskVedaResult f) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead(Icons.library_books_rounded, 'More information'),
        if (f.content.isEmpty)
          _comingSoon('More articles on this are coming soon')
        else
          for (final it in f.content) _feedItemCard(it),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 20, 2, 12),
          child: Row(children: [
            const Icon(Icons.play_circle_outline_rounded, size: 19, color: _vPurple2),
            const SizedBox(width: 9),
            Text('Videos', style: GoogleFonts.fraunces(fontSize: 17, fontWeight: FontWeight.w600, color: _vInk2)),
          ]),
        ),
        if (f.videos.isEmpty)
          _comingSoon('Videos for this are coming soon')
        else
          for (final it in f.videos) _feedItemCard(it),
      ]);

  // A tappable pointer card — deep-links to the exact content on top of Ask Veda.
  Widget _feedItemCard(VedaFeedItem it) {
    final c = _kindColorStr(it.kind);
    final snippet = (it.snippet ?? '').trim();
    return GestureDetector(
      onTap: () => _openItem(it),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _vCardBorder), boxShadow: _vCardShadow),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 56, height: 56, alignment: Alignment.center, decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(_kindIconStr(it.kind), size: 24, color: c)),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_kindLabel(it.kind), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.manrope(fontSize: 10.5, fontWeight: FontWeight.w800, letterSpacing: 0.7, color: _vPurple2)),
              const SizedBox(height: 4),
              Text(it.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3, color: _vInk)),
              if (snippet.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(snippet, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.manrope(fontSize: 12, height: 1.35, color: _vMuted)),
              ],
            ]),
          ),
          const Padding(padding: EdgeInsets.only(left: 4, top: 18), child: Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBBFDD))),
        ]),
      ),
    );
  }

  // S5 - Community insights (on hold — needs its own build)
  Widget _communityComingSoon() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead(Icons.forum_rounded, 'Community insights'),
        _comingSoon('Community insights are coming soon'),
      ]);

  // S6 - Products
  Widget _productsFeed(AskVedaResult f) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead(Icons.redeem_rounded, 'Products', top: 28),
        if (f.products.isEmpty)
          _comingSoon('Relevant products are coming soon')
        else
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: f.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 13),
              itemBuilder: (_, i) => _productPointerCard(f.products[i]),
            ),
          ),
      ]);

  // S7 - Services
  Widget _servicesFeed(AskVedaResult f) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionHead(Icons.verified_user_rounded, 'Services'),
        if (f.services.isEmpty)
          _comingSoon('Relevant services are coming soon')
        else
          for (final it in f.services) _feedItemCard(it),
      ]);

  PpProduct? _matchProduct(String label) {
    final l = label.toLowerCase();
    for (final pr in productCatalog) {
      final n = pr.name.toLowerCase();
      if (l.contains(n) || n.contains(l)) return pr;
    }
    return null;
  }

  Widget _productPointerCard(VedaFeedItem it) {
    final prod = _matchProduct(it.title);
    return GestureDetector(
      onTap: () => prod != null ? _open(ProductDetailScreen(product: prod)) : openPpTab(context, 4),
      child: Container(
        width: 152,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _vCardBorder), boxShadow: _vCardShadow),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            height: 100,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFEEE4FB), Color(0xFFF5ECF7)])),
            child: const Icon(Icons.redeem_rounded, size: 30, color: Color(0xFFBDABDF)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 11, 13, 13),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prod?.name ?? it.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, height: 1.3, color: _vInk)),
              const SizedBox(height: 8),
              Text(prod?.priceLabel ?? 'View in Products', style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: _vPurple)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _disclaimer() => Padding(
        padding: const EdgeInsets.fromLTRB(6, 26, 6, 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.only(top: 1), child: Icon(Icons.shield_rounded, size: 17, color: Color(0xFFB6A9CC))),
          const SizedBox(width: 9),
          Expanded(child: Text('This is general guidance for your child’s stage - please confirm anything important with your paediatrician.', style: GoogleFonts.manrope(fontSize: 11.5, height: 1.55, color: _vMuted2))),
        ]),
      );

  // ---- deep-linking : open the exact content on TOP of Ask Veda -------------
  void _openItem(VedaFeedItem it) {
    final kind = (it.kind ?? '').toLowerCase();
    if (kind == 'product') {
      final prod = _matchProduct(it.title);
      if (prod != null) {
        _open(ProductDetailScreen(product: prod));
      } else {
        openPpTab(context, 4); // Products tab
      }
      return;
    }
    if (kind == 'video') {
      _snack('This video is coming soon'); // wired in a later job
      return;
    }
    // articles / reads / guides / experts → the reader, pushed over Ask Veda.
    _openReader(it);
  }

  // A reader sheet showing the real content (full body). Dismissing returns to
  // Ask Veda — she never leaves the chat.
  void _openReader(VedaFeedItem it) {
    final c = _kindColorStr(it.kind);
    final text = (it.body?.trim().isNotEmpty ?? false)
        ? it.body!.trim()
        : (it.snippet?.trim() ?? '');
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD7CCE8), borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(99)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_kindIconStr(it.kind), size: 13, color: c),
                  const SizedBox(width: 5),
                  Text(_kindLabel(it.kind), style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: c)),
                ]),
              ),
              const SizedBox(height: 12),
              Text(it.title, style: GoogleFonts.fraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: _vInk2)),
              const SizedBox(height: 12),
              Text(text, style: GoogleFonts.manrope(fontSize: 14.5, height: 1.6, color: _vBody)),
              const SizedBox(height: 18),
              Text('This is general guidance for your child’s stage - please confirm anything important with your paediatrician.', style: GoogleFonts.manrope(fontSize: 11.5, height: 1.5, color: _vMuted2)),
            ],
          ),
        ),
      ),
    );
  }

  // ---- kind → label / colour / icon (the backend sends `kind` as a string) --
  String _kindLabel(String? k) {
    switch ((k ?? '').toLowerCase()) {
      case 'product':
        return 'PRODUCT';
      case 'expert':
        return 'EXPERT';
      case 'video':
        return 'VIDEO';
      case 'recipe':
        return 'RECIPE';
      case 'cani':
        return 'CAN I…';
      case 'scan':
        return 'SCAN GUIDE';
      case 'health':
        return 'HEALTH';
      case 'garbh':
      case 'spiritual':
        return 'GARBH SANSKAR';
      case 'symptom':
        return 'SYMPTOM';
      default:
        return 'READING';
    }
  }

  Color _kindColorStr(String? k) {
    switch ((k ?? '').toLowerCase()) {
      case 'product':
        return const Color(0xFF3E9A8C);
      case 'expert':
        return _vPurple2;
      case 'recipe':
        return _vCoral;
      case 'health':
      case 'scan':
        return const Color(0xFF3E6DA6);
      case 'video':
        return const Color(0xFFC0392B);
      case 'garbh':
      case 'spiritual':
        return _vPurple;
      default:
        return const Color(0xFF4A7BC8);
    }
  }

  IconData _kindIconStr(String? k) {
    switch ((k ?? '').toLowerCase()) {
      case 'product':
        return Icons.shopping_bag_rounded;
      case 'expert':
        return Icons.verified_user_rounded;
      case 'recipe':
        return Icons.restaurant_menu_rounded;
      case 'health':
      case 'scan':
        return Icons.monitor_heart_rounded;
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'garbh':
      case 'spiritual':
        return Icons.self_improvement_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}

