// =============================================================================
//  AskVedaScreen — ParentVeda's companion (the "Ask Veda Results" design)
// -----------------------------------------------------------------------------
//  Ask Veda is now a SEARCH → STRUCTURED RESULT page (matching the product doc's
//  fixed result page), not a chat thread:
//    • Initial view  — logo·wordmark·profile bar → the white search pill pinned
//      at the TOP (where she types) → stage-wise suggestion cards below it.
//    • After a question — the pill stays put at the TOP (now showing her query),
//      and the structured 7-section result renders below: Veda Answer →
//      What this means → Recommended actions → More information → Community →
//      Products → Services → disclaimer.
//  All the offline logic (vedaAnswer / matchShowcase / retrieval / suggestions /
//  rotation) is untouched — this is the visual + layout layer. The UI is shaped
//  exactly for a real LLM to fill later (Phase B).
// =============================================================================

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/product_data.dart';
import '../../data/veda_showcase.dart';
import '../../data/veda_suggestions.dart';
import '../../localization/app_language.dart';
import '../../models/product_models.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/veda_answer.dart';
import '../../services/veda_index.dart';
import '../../theme/app_theme.dart';
import '../../widgets/mic_dictation_button.dart';
import '../calendar_screen.dart';
import '../community_screen.dart';
import '../products_screen.dart';
import '../profile_screen.dart';
import '../read_next_screen.dart';
import '../weekly_card_stack_screen.dart';
import 'baby_movement_screen.dart';
import 'contraction_tracker_screen.dart';
import 'hospital_bag_screen.dart';
import 'kegel_care_screen.dart';
import 'weight_tracker_screen.dart';

// ---- design palette (the "Ask Veda Results" mock — our brand purple/coral) ----
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
  BoxShadow(
      color: Color(0x14602EA0),
      blurRadius: 30,
      offset: Offset(0, 16),
      spreadRadius: -10),
];

class AskVedaScreen extends StatefulWidget {
  const AskVedaScreen({super.key, required this.controller, this.initialQuery});
  final PregnancyController controller;

  /// When set (e.g. opened from a Can-I? or Report handoff), Ask Veda runs this
  /// question immediately — it already has the whole-app data to answer it.
  final String? initialQuery;

  @override
  State<AskVedaScreen> createState() => _AskVedaScreenState();
}

class _AskVedaScreenState extends State<AskVedaScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  // A single question → result (no chat history). _query null = the initial
  // (suggestions) view with the search pill at the bottom.
  String? _query;
  VedaResult? _result;

  // A fresh, shuffled subset of each section's suggestions per visit.
  final _rng = Random();
  final Map<String, List<LocalizedText>> _picked = {};

  PregnancyController get p => widget.controller;

  @override
  void initState() {
    super.initState();
    _rollSuggestions();
    // Opened with a question already in hand (Can-I / Report handoff) → answer it.
    final q = widget.initialQuery?.trim() ?? '';
    if (q.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(q);
      });
    }
  }

  void _rollSuggestions() {
    _picked.clear();
    for (final sec in kVedaSuggestions) {
      final n = sec.active ? 4 : 3;
      final qs = [...sec.questions]..shuffle(_rng);
      _picked[sec.title.en] = qs.take(n).toList();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _query = t;
      _result = vedaAnswer(t, p);
      _ctrl.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  void _clearQuery() {
    setState(() {
      _query = null;
      _result = null;
      _ctrl.clear();
    });
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ---- navigation: make the result sections clickable (Google-search style) --
  void _open(Widget w) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => w));

  void _openProducts() => _open(ProductsScreen(controller: p));
  void _openProduct(Product prod) =>
      _open(ProductDetailScreen(product: prod, controller: p));
  void _openReads() => _open(ReadNextScreen(controller: p));
  void _openCommunityPage() => _open(CommunityScreen(controller: p));

  void _openWeeklyJourney() {
    p.selectWeek(p.currentWeek);
    _open(WeeklyCardStackScreen(controller: p));
  }

  /// Open the right tool for a "Tool"-type label (best-effort by its name).
  void _openTool(String l) {
    if (l.contains('contraction')) {
      _open(ContractionTrackerScreen(controller: p));
    } else if (l.contains('movement') || l.contains('kick')) {
      _open(BabyMovementScreen(controller: p));
    } else if (l.contains('hospital')) {
      _open(HospitalBagScreen(controller: p));
    } else if (l.contains('weight')) {
      _open(WeightTrackerScreen(controller: p));
    } else if (l.contains('kegel') || l.contains('pelvic')) {
      _open(KegelCareScreen(controller: p));
    } else if (l.contains('calendar')) {
      _open(CalendarScreen(controller: p));
    } else {
      _openReads();
    }
  }

  /// Route a showcase "More information" card by what it is — its weekly journey,
  /// the calendar, the matching tool, or the reading hub for articles/videos.
  void _openContent(LocalizedText label) {
    final l = label.en.toLowerCase();
    if (l.contains('calendar')) {
      _open(CalendarScreen(controller: p));
    } else if (l.contains('week') || l.contains('journey')) {
      _openWeeklyJourney();
    } else if (l.contains('tool') ||
        l.contains('timer') ||
        l.contains('counter') ||
        l.contains('checklist') ||
        l.contains('tracker')) {
      _openTool(l);
    } else {
      // articles / videos / reads / libraries → the reading hub
      _openReads();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: p,
      builder: (context, _) => _build(context, S(p.language)),
    );
  }

  Widget _build(BuildContext context, S s) {
    final hasResult = _query != null;
    return Scaffold(
      backgroundColor: _vBgMid,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_vBgTop, _vBgMid, _vBgBot],
            stops: [0.0, 0.52, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(children: [
            _topBar(context, s),
            Expanded(
              child: Stack(children: [
                Positioned.fill(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOut,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                                begin: const Offset(0, 0.02), end: Offset.zero)
                            .animate(anim),
                        child: child,
                      ),
                    ),
                    child: hasResult
                        ? _resultScroll(s)
                        : _initialScroll(s),
                  ),
                ),
                // The white search pill now sits at the TOP in BOTH views — the
                // initial (edit) view and the result view — so it never jumps;
                // only its contents cross-fade (edit field ↔ the asked query).
                AnimatedAlign(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 240),
                      child: _inputPill(s, result: hasResult),
                    ),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ---- top app bar : logo · Ask Veda wordmark · profile ---------------------
  Widget _topBar(BuildContext context, S s) {
    final initial = p.motherName.isNotEmpty ? p.motherName[0].toUpperCase() : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/brand/pv-mark.png',
              width: 34, height: 34, fit: BoxFit.contain),
          Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.auto_awesome_rounded, size: 17, color: _vCoral),
            const SizedBox(width: 7),
            RichText(
              text: TextSpan(
                style: GoogleFonts.fraunces(
                    fontSize: 23,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2),
                children: const [
                  TextSpan(text: 'Ask ', style: TextStyle(color: _vPurple)),
                  TextSpan(text: 'Veda', style: TextStyle(color: _vCoral)),
                ],
              ),
            ),
          ]),
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProfileScreen(controller: p))),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_vPurple2, _vCoral]),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x4D6D28D9),
                      blurRadius: 9,
                      offset: Offset(0, 3)),
                ],
              ),
              child: initial.isEmpty
                  ? const Icon(Icons.person_rounded, size: 21, color: Colors.white)
                  : Text(initial,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  // ---- the search pill (edit & asked-query both render at the top) ----------
  Widget _inputPill(S s, {required bool result}) {
    return Container(
      key: ValueKey(result),
      padding: EdgeInsets.symmetric(
          horizontal: 16, vertical: result ? 12 : 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x1A7C3AED)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0D281646), blurRadius: 6, offset: Offset(0, 2)),
          BoxShadow(
              color: Color(0x334D2EA0),
              blurRadius: 30,
              offset: Offset(0, 14),
              spreadRadius: -16),
        ],
      ),
      child: result ? _pillResult(s) : _pillEdit(s),
    );
  }

  Widget _pillEdit(S s) => Row(children: [
        const Icon(Icons.search_rounded, size: 21, color: Color(0xFF9384B0)),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _ctrl,
            textInputAction: TextInputAction.search,
            onSubmitted: _send,
            cursorColor: _vPurple,
            cursorWidth: 2,
            style: GoogleFonts.manrope(
                fontSize: 14.5, fontWeight: FontWeight.w600, color: _vInk),
            decoration: InputDecoration(
              hintText: s.vedaHint,
              filled: false,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              hintStyle: GoogleFonts.manrope(
                  fontSize: 14.5, color: const Color(0xFFB6A9CC)),
            ),
          ),
        ),
        // Real speech-to-text — dictates straight into the search field.
        MicDictateButton(controller: _ctrl, s: s, color: _vPurple),
        const SizedBox(width: 2),
        GestureDetector(
          onTap: () => _send(_ctrl.text),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: _vPurple, shape: BoxShape.circle),
            child: const Icon(Icons.arrow_upward_rounded,
                color: Colors.white, size: 19),
          ),
        ),
      ]);

  Widget _pillResult(S s) => Row(children: [
        const Icon(Icons.search_rounded, size: 21, color: Color(0xFF9384B0)),
        const SizedBox(width: 11),
        Expanded(
          child: Text(_query ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 14.5, fontWeight: FontWeight.w600, color: _vInk)),
        ),
        GestureDetector(
          onTap: _clearQuery,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child:
                Icon(Icons.close_rounded, size: 19, color: Color(0xFFB6A9CC)),
          ),
        ),
        const SizedBox(width: 8),
        Container(width: 1, height: 20, color: const Color(0xFFEADFF5)),
        const SizedBox(width: 12),
        // Ask again by voice → return to the search field (its mic does the STT).
        GestureDetector(
          onTap: _clearQuery,
          child: const Icon(Icons.mic_none_rounded, size: 21, color: _vPurple),
        ),
      ]);

  // ===========================================================================
  //  INITIAL VIEW — stage-wise suggestion cards (pill sits at the bottom)
  // ===========================================================================
  Widget _initialScroll(S s) => ListView(
        key: const ValueKey('initial'),
        // Top padding clears the search pill, which now sits pinned at the top
        // (mirrors the result view's clearance).
        padding: const EdgeInsets.fromLTRB(18, 78, 18, 44),
        children: [_suggestions(s)],
      );

  Widget _suggestions(S s) {
    final lang = p.language;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.vedaSuggestHeader,
                style: GoogleFonts.fraunces(
                    fontSize: 21, fontWeight: FontWeight.w600, color: _vInk2)),
            const SizedBox(height: 3),
            Text(s.vedaSuggestSub,
                style: GoogleFonts.manrope(fontSize: 12.5, color: _vMuted)),
          ]),
        ),
        IconButton(
          tooltip: s.vedaShuffle,
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.shuffle_rounded, size: 20, color: _vPurple),
          onPressed: () => setState(_rollSuggestions),
        ),
      ]),
      const SizedBox(height: 14),
      for (final sec in kVedaSuggestions) _suggestionSection(s, sec, lang),
    ]);
  }

  Widget _suggestionSection(S s, VedaSuggestionSection sec, AppLanguage lang) {
    final active = sec.active;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 14),
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: active ? _vCardBorder : AppTheme.outlineVariant),
        boxShadow: active ? _vCardShadow : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(sec.emoji, style: const TextStyle(fontSize: 17)),
          const SizedBox(width: 8),
          Text(sec.title.of(lang),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: active ? _vInk : _vMuted)),
          if (!active) ...[const Spacer(), _soonTag(s)],
        ]),
        const SizedBox(height: 11),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final q in (_picked[sec.title.en] ?? sec.questions))
            _qChip(q.of(lang), active),
        ]),
      ]),
    );
  }

  Widget _qChip(String text, bool active) => GestureDetector(
        onTap: () => _send(text),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: active
                ? _vPurple.withValues(alpha: 0.06)
                : const Color(0xFFF3EEFA),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(
                color:
                    active ? const Color(0x1F7C3AED) : AppTheme.outlineVariant),
          ),
          child: Text(text,
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? _vPurple : _vMuted)),
        ),
      );

  Widget _soonTag(S s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: const Color(0xFFFBEAF1),
            borderRadius: BorderRadius.circular(99)),
        child: Text(s.vedaStageSoon,
            style: GoogleFonts.manrope(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: _vCoral)),
      );

  // ===========================================================================
  //  RESULT VIEW — the fixed structured page (pill sits at the top)
  // ===========================================================================
  Widget _resultScroll(S s) {
    final r = _result!;
    final lang = p.language;
    final sc = r.showcase;
    final List<Widget> children;
    if (sc != null) {
      children = [
        _vedaAnswerCard(sc, s, lang),
        _whatMeans(sc, s, lang, personalLine: r.personalLine),
        _nextActions(sc, s, lang),
        if (sc.pvContent.isNotEmpty) _moreInfoShowcase(sc, s, lang),
        _community(sc, s, lang),
        if (sc.products.isNotEmpty) _products(sc, s, lang),
        if (sc.services.isNotEmpty) _services(sc, s, lang),
        _disclaimer(s),
      ];
    } else if (r.view != null) {
      // Retrieval answers now render the SAME fixed 7 sections — the content is
      // pulled from across the app as context (typed by content-kind, never a
      // raw "Can I"/"Week N" source card; community is social-proof only).
      children = _viewSections(r.view!, s, lang);
    } else {
      // The honest "I don't have a confident answer yet" case.
      children = [_plainAnswerCard(r.answer, s), _disclaimer(s)];
    }
    return ListView(
      key: const ValueKey('result'),
      controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 78, 18, 44),
      children: children,
    );
  }

  // ===========================================================================
  //  RETRIEVAL view — the SAME 7 sections as the showcase page, built from
  //  vetted app content. Community is excluded from S1–S4 (social proof only).
  // ===========================================================================
  List<Widget> _viewSections(VedaAnswerView v, S s, AppLanguage lang) => [
        _plainAnswerCard(v.answer, s), // S1 — Veda Answer
        _viewMeaning(v, s), // S2
        if (v.actions.isNotEmpty) _viewActions(v, s), // S3
        if (v.content.isNotEmpty) _viewContent(v, s), // S4
        if (v.community != null) _viewCommunity(v.community!, s), // S5
        if (v.products.isNotEmpty) _viewProducts(v, s, lang), // S6
        _disclaimer(s),
      ];

  Widget _viewMeaning(VedaAnswerView v, S s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.favorite_rounded, s.vedaWhatMeans),
          _card(
            padding: const EdgeInsets.fromLTRB(17, 17, 18, 17),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(v.meaning,
                  style: GoogleFonts.manrope(
                      fontSize: 14.5, height: 1.62, color: _vBody2)),
              if (v.urgent) ...[
                const SizedBox(height: 14),
                _whenChecked(s),
              ],
            ]),
          ),
        ],
      );

  Widget _viewActions(VedaAnswerView v, S s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.task_alt_rounded, s.vedaNextActions),
          _card(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (int i = 0; i < v.actions.length; i++)
                _viewActionRow(v.actions[i], last: i == v.actions.length - 1),
            ]),
          ),
        ],
      );

  Widget _viewActionRow(String action, {required bool last}) {
    final en = action.toLowerCase();
    final coral = en.contains('call') ||
        en.contains('doctor') ||
        en.contains('maternity unit');
    final icon = coral
        ? Icons.call_rounded
        : en.contains('track') || en.contains('note') || en.contains('feel')
            ? Icons.event_note_rounded
            : en.contains('read') || en.contains('explore')
                ? Icons.menu_book_rounded
                : Icons.task_alt_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border:
            last ? null : const Border(bottom: BorderSide(color: _vDivider)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: coral
                    ? const [Color(0xFFFFE9EE), Color(0xFFFCE0E8)]
                    : const [Color(0xFFF3E9FF), Color(0xFFEDE2FC)]),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 21, color: coral ? _vCoral : _vPurple),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(action,
              style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _vInk)),
        ),
      ]),
    );
  }

  Widget _viewContent(VedaAnswerView v, S s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.library_books_rounded, s.vedaMoreInfo),
          for (final c in v.content) _viewContentCard(c),
        ],
      );

  Widget _viewContentCard(VedaContentRef ref) {
    final c = _kindColor(ref.kind);
    return GestureDetector(
      onTap: () => _openContentRef(ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _vCardBorder),
          boxShadow: _vCardShadow,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(_kindIcon(ref.kind), size: 24, color: c),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Content TYPE label (e.g. "Weekly journey") — NOT a raw source.
              Text(ref.typeLabel.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: _vPurple2)),
              const SizedBox(height: 4),
              Text(ref.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: _vInk)),
              const SizedBox(height: 3),
              Text(ref.snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 12, height: 1.35, color: _vMuted)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 18),
            child: Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFCBBFDD)),
          ),
        ]),
      ),
    );
  }

  // A content card routes exactly like a source did, keyed by its kind.
  void _openContentRef(VedaContentRef ref) => _openSource(VedaSource(
        kind: ref.kind,
        sourceLabel: ref.typeLabel,
        title: ref.title,
        snippet: ref.snippet,
        body: ref.body,
      ));

  Widget _viewCommunity(String text, S s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.forum_rounded, s.vedaCommunityInsights),
          GestureDetector(
            onTap: _openCommunityPage,
            behavior: HitTestBehavior.opaque,
            child: _card(
              padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
              child: Row(children: [
                _avatarStack(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(text,
                      style: GoogleFonts.manrope(
                          fontSize: 13.5, height: 1.5, color: _vBody2)),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: Color(0xFFCBBFDD)),
              ]),
            ),
          ),
        ],
      );

  Widget _viewProducts(VedaAnswerView v, S s, AppLanguage lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.redeem_rounded, s.vedaProductsHdr, top: 28),
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 13),
            child: Text(s.vedaProductsHint,
                style: GoogleFonts.manrope(fontSize: 12, color: _vMuted2)),
          ),
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: v.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 13),
              itemBuilder: (_, i) => _productCard(
                  LocalizedText(en: v.products[i], hi: v.products[i]), lang),
            ),
          ),
        ],
      );

  // ---- shared building blocks ----
  Widget _card(
          {required Widget child,
          EdgeInsets? padding,
          double radius = 18,
          Gradient? gradient}) =>
      Container(
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
          Expanded(
            child: Text(title,
                style: GoogleFonts.fraunces(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                    color: _vInk2)),
          ),
        ]),
      );

  Widget _contextChip(S s) {
    final wk = p.currentWeek;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFFF3E9FF), Color(0xFFFBEAF1)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.pregnant_woman_rounded, size: 14, color: _vPurple),
          const SizedBox(width: 6),
          Text('${s.jrWeekLabel(wk)} · ${s.trimesterName(wk)}',
              style: GoogleFonts.manrope(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: _vPurple)),
        ]),
      ),
    );
  }

  Widget _urgentBanner(S s) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF0F1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x33F0476A)),
        ),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded, size: 19, color: _vCoral),
          const SizedBox(width: 9),
          Expanded(
            child: Text(s.vedaUrgentBanner,
                style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFC42A4F))),
          ),
        ]),
      );

  // S1 — Veda Answer ----------------------------------------------------------
  Widget _vedaAnswerCard(VedaShowcase sc, S s, AppLanguage lang) => _card(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFCFAFF)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (sc.urgent) _urgentBanner(s),
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 20, color: _vPurple2),
            const SizedBox(width: 9),
            Text(s.vedaAnswerLabel,
                style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w800, color: _vInk)),
            const Spacer(),
            _speakerButton(s),
          ]),
          const SizedBox(height: 13),
          _contextChip(s),
          const SizedBox(height: 14),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: Text(sc.answer.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 15,
                      height: 1.66,
                      fontWeight: FontWeight.w500,
                      color: _vBody)),
            ),
            const SizedBox(width: 15),
            _illustration(sc.id),
          ]),
        ]),
      );

  Widget _speakerButton(S s) => GestureDetector(
        onTap: () => _snack(s.vedaVoiceSoon),
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
              color: Color(0xFFF6F0FE), shape: BoxShape.circle),
          child: const Icon(Icons.volume_up_rounded, size: 18, color: _vPurple2),
        ),
      );

  Widget _illustration(String id) {
    final icon = switch (id) {
      'anomaly_scan' => Icons.monitor_heart_rounded,
      'labour_signs' => Icons.pregnant_woman_rounded,
      'iron_foods' => Icons.restaurant_rounded,
      'sleep_back' => Icons.airline_seat_recline_extra_rounded,
      'reduced_movements' => Icons.monitor_heart_rounded,
      _ => Icons.auto_awesome_rounded,
    };
    return Container(
      width: 98,
      height: 114,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFEFE4FB), Color(0xFFF8EDF6)]),
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 38, color: const Color(0xFFC6B2E4)),
    );
  }

  // S2 — What this means for you ----------------------------------------------
  Widget _whatMeans(VedaShowcase sc, S s, AppLanguage lang,
          {String? personalLine}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.favorite_rounded, s.vedaWhatMeans),
          _card(
            padding: const EdgeInsets.fromLTRB(17, 17, 18, 17),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(sc.meaning.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 14.5, height: 1.62, color: _vBody2)),
              // Personalized to HER (logged symptoms / medications), appended to
              // the curated explanation.
              if (personalLine != null) ...[
                const SizedBox(height: 11),
                Text(personalLine,
                    style: GoogleFonts.manrope(
                        fontSize: 14,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                        color: _vPurple2)),
              ],
              if (sc.urgent) ...[
                const SizedBox(height: 14),
                _whenChecked(s),
              ],
            ]),
          ),
        ],
      );

  Widget _whenChecked(S s) => Container(
        padding: const EdgeInsets.fromLTRB(13, 13, 14, 13),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF5F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0x21F0476A)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child:
                Icon(Icons.monitor_heart_rounded, size: 20, color: Color(0xFFE2436A)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.vedaWhenChecked,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD6325A))),
              const SizedBox(height: 3),
              Text(s.vedaUrgentBanner,
                  style: GoogleFonts.manrope(
                      fontSize: 13, height: 1.55, color: const Color(0xFF6B4651))),
            ]),
          ),
        ]),
      );

  // S3 — Recommended next actions ---------------------------------------------
  Widget _nextActions(VedaShowcase sc, S s, AppLanguage lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.task_alt_rounded, s.vedaNextActions),
          _card(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (int i = 0; i < sc.actions.length; i++)
                _actionRow(sc.actions[i], lang, last: i == sc.actions.length - 1),
            ]),
          ),
        ],
      );

  Widget _actionRow(LocalizedText action, AppLanguage lang,
      {required bool last}) {
    final en = action.en.toLowerCase();
    final coral = en.contains('call') ||
        en.contains('doctor') ||
        en.contains('maternity unit');
    final icon = coral
        ? Icons.call_rounded
        : en.contains('sleep') || en.contains('left') || en.contains('side')
            ? Icons.bedtime_rounded
            : en.contains('book') ||
                    en.contains('appointment') ||
                    en.contains('check-up') ||
                    en.contains('scan') ||
                    en.contains('go in')
                ? Icons.event_rounded
                : en.contains('eat') ||
                        en.contains('food') ||
                        en.contains('iron') ||
                        en.contains('water') ||
                        en.contains('meal') ||
                        en.contains('vitamin')
                    ? Icons.restaurant_rounded
                    : en.contains('stretch') ||
                            en.contains('pelvic') ||
                            en.contains('walk') ||
                            en.contains('active') ||
                            en.contains('move')
                        ? Icons.self_improvement_rounded
                        : Icons.task_alt_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: _vDivider)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: coral
                    ? const [Color(0xFFFFE9EE), Color(0xFFFCE0E8)]
                    : const [Color(0xFFF3E9FF), Color(0xFFEDE2FC)]),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, size: 21, color: coral ? _vCoral : _vPurple),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(action.of(lang),
              style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _vInk)),
        ),
        // No trailing chevron: these are guidance, not navigation — the arrow
        // wrongly implied each row opened somewhere.
      ]),
    );
  }

  // S4 — More information (ParentVeda content) --------------------------------
  Widget _moreInfoShowcase(VedaShowcase sc, S s, AppLanguage lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.library_books_rounded, s.vedaMoreInfo),
          for (final c in sc.pvContent) _contentCard(c, lang),
        ],
      );

  Widget _contentCard(LocalizedText label, AppLanguage lang) {
    final en = label.en.toLowerCase();
    final isVideo = en.contains('video') || en.contains('watch');
    final isWeek = en.contains('week') || en.contains('journey');
    final isTool = en.contains('tool') ||
        en.contains('timer') ||
        en.contains('counter') ||
        en.contains('calendar') ||
        en.contains('checklist');
    final type = isVideo
        ? 'Video'
        : isWeek
            ? 'Weekly Journey'
            : isTool
                ? 'Tool'
                : 'Article';
    return GestureDetector(
      onTap: () => _openContent(label),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _vCardBorder),
          boxShadow: _vCardShadow,
        ),
        child: Row(children: [
          _contentThumb(type),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(type.toUpperCase(),
                      style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                          color: _vPurple2)),
                  const SizedBox(height: 4),
                  Text(label.of(lang),
                      style: GoogleFonts.manrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.32,
                          color: _vInk)),
                ]),
          ),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: Color(0xFFCBBFDD)),
        ]),
      ),
    );
  }

  Widget _contentThumb(String type) {
    if (type == 'Weekly Journey') {
      return Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_vPurple2, Color(0xFF9D6BF0)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('WEEK',
              style: GoogleFonts.manrope(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withValues(alpha: 0.85))),
          Text('${p.currentWeek}',
              style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: Colors.white)),
        ]),
      );
    }
    final isVideo = type == 'Video';
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isVideo
                ? const [Color(0xFFF4E6F3), Color(0xFFFBE9EE)]
                : const [Color(0xFFEEE4FB), Color(0xFFF4ECF7)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isVideo
            ? Icons.play_circle_fill_rounded
            : type == 'Tool'
                ? Icons.build_rounded
                : Icons.menu_book_rounded,
        size: isVideo ? 32 : 26,
        color: isVideo ? const Color(0xFFEC6A87) : const Color(0xFFB9A6DC),
      ),
    );
  }

  // S5 — Community insights ----------------------------------------------------
  Widget _community(VedaShowcase sc, S s, AppLanguage lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.forum_rounded, s.vedaCommunityInsights),
          GestureDetector(
            onTap: _openCommunityPage,
            behavior: HitTestBehavior.opaque,
            child: _card(
              padding: const EdgeInsets.fromLTRB(16, 16, 18, 16),
              child: Row(children: [
                _avatarStack(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(sc.community.of(lang),
                      style: GoogleFonts.manrope(
                          fontSize: 13.5,
                          height: 1.45,
                          fontWeight: FontWeight.w600,
                          color: _vBody2)),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: Color(0xFFCBBFDD)),
              ]),
            ),
          ),
        ],
      );

  Widget _avatarStack() => SizedBox(
        width: 64,
        height: 28,
        child: Stack(children: [
          _miniAvatar(0, const [Color(0xFFF0476A), Color(0xFFFF8AA0)]),
          _miniAvatar(18, const [Color(0xFF7C3AED), Color(0xFFB08BF0)]),
          _miniAvatar(36, const [Color(0xFFF0A046), Color(0xFFFFD08A)]),
        ]),
      );

  Widget _miniAvatar(double left, List<Color> colors) => Positioned(
        left: left,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        ),
      );

  // S6 — Products --------------------------------------------------------------
  Widget _products(VedaShowcase sc, S s, AppLanguage lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.redeem_rounded, s.vedaProductsHdr, top: 28),
          Padding(
            padding: const EdgeInsets.only(left: 30, bottom: 13),
            child: Text(s.vedaProductsHint,
                style: GoogleFonts.manrope(fontSize: 12, color: _vMuted2)),
          ),
          SizedBox(
            height: 188,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              itemCount: sc.products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 13),
              itemBuilder: (_, i) => _productCard(sc.products[i], lang),
            ),
          ),
        ],
      );

  Product? _matchProduct(String label) {
    final l = label.toLowerCase();
    for (final pr in kProducts) {
      final n = pr.name.toLowerCase();
      if (l.contains(n) || n.contains(l)) return pr;
    }
    return null;
  }

  Widget _productCard(LocalizedText label, AppLanguage lang) {
    final prod = _matchProduct(label.en);
    return GestureDetector(
      onTap: () => prod != null ? _openProduct(prod) : _openProducts(),
      child: Container(
      width: 152,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _vCardBorder),
        boxShadow: _vCardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 100,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEEE4FB), Color(0xFFF5ECF7)]),
          ),
          child: prod != null
              ? Text(prod.emoji, style: const TextStyle(fontSize: 40))
              : const Icon(Icons.redeem_rounded,
                  size: 30, color: Color(0xFFBDABDF)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(11, 11, 13, 13),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(prod?.name ?? label.of(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: _vInk)),
            const SizedBox(height: 8),
            if ((prod?.price ?? '').isNotEmpty)
              Text(prod!.price,
                  style: GoogleFonts.manrope(
                      fontSize: 14.5, fontWeight: FontWeight.w800, color: _vPurple))
            else
              Text(' ',
                  style: GoogleFonts.manrope(
                      fontSize: 14.5, fontWeight: FontWeight.w800)),
          ]),
        ),
      ]),
      ),
    );
  }

  // S7 — Services --------------------------------------------------------------
  Widget _services(VedaShowcase sc, S s, AppLanguage lang) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHead(Icons.medical_services_rounded, s.vedaTalkExpert),
          _card(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (int i = 0; i < sc.services.length; i++)
                _serviceRow(sc.services[i], s, lang,
                    first: i == 0, last: i == sc.services.length - 1),
            ]),
          ),
        ],
      );

  Widget _serviceRow(LocalizedText svc, S s, AppLanguage lang,
      {required bool first, required bool last}) {
    final en = svc.en.toLowerCase();
    final coral = en.contains('gyn') ||
        en.contains('doctor') ||
        en.contains('obstetric') ||
        en.contains('hospital') ||
        en.contains('maternity') ||
        en.contains('labour') ||
        en.contains('ward');
    final icon = en.contains('physio')
        ? Icons.accessibility_new_rounded
        : en.contains('scan') || en.contains('sono')
            ? Icons.monitor_heart_rounded
            : en.contains('dietitian') || en.contains('nutrition')
                ? Icons.restaurant_rounded
                : en.contains('midwife') || en.contains('lactation')
                    ? Icons.pregnant_woman_rounded
                    : coral
                        ? Icons.medical_services_rounded
                        : Icons.medical_services_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border:
            last ? null : const Border(bottom: BorderSide(color: _vDivider)),
      ),
      child: Row(children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: coral
                    ? const [Color(0xFFFFE9EE), Color(0xFFFCE0E8)]
                    : const [Color(0xFFF3E9FF), Color(0xFFEDE2FC)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 23, color: coral ? _vCoral : _vPurple),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(svc.of(lang),
              style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _vInk)),
        ),
        const SizedBox(width: 10),
        first
            ? GestureDetector(
                onTap: () => _snack(s.vedaVoiceSoon),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: _vPurple,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x736D28D9),
                          blurRadius: 12,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Text(s.vedaBook,
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              )
            : GestureDetector(
                onTap: () => _snack(s.vedaVoiceSoon),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFE3D6F4)),
                  ),
                  child: Text(s.vedaCall,
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _vPurple)),
                ),
              ),
      ]),
    );
  }

  Widget _disclaimer(S s) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 26, 6, 0),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.shield_rounded, size: 17, color: Color(0xFFB6A9CC)),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(s.vedaDisclaimer,
                style: GoogleFonts.manrope(
                    fontSize: 11.5, height: 1.55, color: _vMuted2)),
          ),
        ]),
      );

  // ---- non-showcase fallback: plain Veda answer + source cards --------------
  Widget _plainAnswerCard(String answer, S s) => _card(
        radius: 22,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFFCFAFF)]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 20, color: _vPurple2),
            const SizedBox(width: 9),
            Text(s.vedaAnswerLabel,
                style: GoogleFonts.manrope(
                    fontSize: 15, fontWeight: FontWeight.w800, color: _vInk)),
            const Spacer(),
            _speakerButton(s),
          ]),
          const SizedBox(height: 13),
          _contextChip(s),
          const SizedBox(height: 14),
          Text(answer,
              style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                  color: _vBody)),
        ]),
      );

  // Old retrieval "source card" (raw Can-I/Week-N label). Replaced by the typed
  // 7-section view (_viewContentCard); kept for revert.
  // ignore: unused_element
  Widget _sourceCard(VedaSource src) {
    final c = _kindColor(src.kind);
    return GestureDetector(
      onTap: () => _openSource(src),
      child: Container(
        margin: const EdgeInsets.only(bottom: 11),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _vCardBorder),
          boxShadow: _vCardShadow,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: c.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14)),
            child: Icon(_kindIcon(src.kind), size: 24, color: c),
          ),
          const SizedBox(width: 13),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(src.sourceLabel.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.7,
                      color: _vPurple2)),
              const SizedBox(height: 4),
              Text(src.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: _vInk)),
              const SizedBox(height: 3),
              Text(src.snippet,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 12, height: 1.35, color: _vMuted)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 18),
            child: Icon(Icons.chevron_right_rounded,
                size: 20, color: Color(0xFFCBBFDD)),
          ),
        ]),
      ),
    );
  }

  /// Tapping a retrieval source goes where it belongs (Google-style): products
  /// → the products page, community → community, weekly/body → the weekly
  /// journey, a tool → that tool. Reference reads (Can-I, symptoms, tips, garbh)
  /// open their content in a sheet, since they have no standalone screen.
  void _openSource(VedaSource src) {
    switch (src.kind) {
      case VedaKind.product:
        _openProducts();
        return;
      case VedaKind.community:
        _openCommunityPage();
        return;
      case VedaKind.weekBaby:
      case VedaKind.weekMother:
      case VedaKind.bodyChange:
        _openWeeklyJourney();
        return;
      case VedaKind.tool:
        _openTool(src.title.toLowerCase());
        return;
      case VedaKind.read:
        _openReads();
        return;
      case VedaKind.canI:
      case VedaKind.symptom:
      case VedaKind.trimesterTip:
      case VedaKind.spiritual:
      case VedaKind.readToBaby:
      case VedaKind.garbh:
        _showSourceSheet(src);
        return;
    }
  }

  void _showSourceSheet(VedaSource src) {
    final s = S(p.language);
    final c = _kindColor(src.kind);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: const Color(0xFFD7CCE8),
                        borderRadius: BorderRadius.circular(99))),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(99)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_kindIcon(src.kind), size: 13, color: c),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(src.sourceLabel,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: c)),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
              Text(src.title,
                  style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: _vInk2)),
              const SizedBox(height: 12),
              Text(src.body.trim(),
                  style: GoogleFonts.manrope(
                      fontSize: 14.5, height: 1.6, color: _vBody)),
              const SizedBox(height: 18),
              Text(s.vedaDisclaimer,
                  style: GoogleFonts.manrope(
                      fontSize: 11.5, height: 1.5, color: _vMuted2)),
            ],
          ),
        ),
      ),
    );
  }

  Color _kindColor(VedaKind k) {
    switch (k) {
      case VedaKind.canI:
        return _vPurple;
      case VedaKind.symptom:
        return const Color(0xFFC9831F);
      case VedaKind.weekBaby:
        return const Color(0xFF4F7A52);
      case VedaKind.weekMother:
        return _vCoral;
      case VedaKind.product:
        return const Color(0xFF3E9A8C);
      case VedaKind.read:
        return const Color(0xFF4A7BC8);
      case VedaKind.trimesterTip:
        return const Color(0xFFE0921C);
      case VedaKind.spiritual:
        return const Color(0xFF7C5CC4);
      case VedaKind.readToBaby:
        return _vCoral;
      case VedaKind.garbh:
        return const Color(0xFF2E9C8E);
      case VedaKind.bodyChange:
        return _vPurple;
      case VedaKind.tool:
        return _vPurple2;
      case VedaKind.community:
        return _vPurple;
    }
  }

  IconData _kindIcon(VedaKind k) {
    switch (k) {
      case VedaKind.canI:
        return Icons.help_outline_rounded;
      case VedaKind.symptom:
        return Icons.healing_rounded;
      case VedaKind.weekBaby:
        return Icons.child_care_rounded;
      case VedaKind.weekMother:
        return Icons.favorite_rounded;
      case VedaKind.product:
        return Icons.shopping_bag_rounded;
      case VedaKind.read:
        return Icons.menu_book_rounded;
      case VedaKind.trimesterTip:
        return Icons.lightbulb_outline_rounded;
      case VedaKind.spiritual:
        return Icons.self_improvement_rounded;
      case VedaKind.readToBaby:
        return Icons.auto_stories_rounded;
      case VedaKind.garbh:
        return Icons.spa_rounded;
      case VedaKind.bodyChange:
        return Icons.accessibility_new_rounded;
      case VedaKind.tool:
        return Icons.build_rounded;
      case VedaKind.community:
        return Icons.groups_rounded;
    }
  }
}
