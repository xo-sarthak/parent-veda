// =============================================================================
//  TtcAskVedaScreen — Ask Veda for the trying-to-conceive stage
// -----------------------------------------------------------------------------
//  The third Ask Veda door (after pregnancy and parenting), same 7-section feed
//  from the same RAG backend — but styled with the TTC design layer and, more
//  importantly, sending TTC context so the answer is framed for someone who is
//  hoping to conceive rather than someone who already is pregnant.
//
//  Context sent (all framing-only, never a filter — one journey, no gating):
//    stage=trying · chapter · ttc_path · months_trying · cycle_day
//
//  PRIVACY — read before touching the wire body. The TTC data model keeps
//  `ttc_cycles` own-row so a partner can never read her cycle; he sees only the
//  chapter she publishes. Sending her cycle day from HIS device would route
//  around that rule on the client side. Hence [partnerMode]: it sends the
//  chapter and nothing else. Do not "simplify" that away.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/remote/ask_veda_service.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_chapter_data.dart';
import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_prepare_data.dart';
import '../../ttc/ttc_store.dart';
import '../../widgets/global_ask_fab.dart' show kAskVedaRoute;
import 'ttc_can_i_screen.dart';
import 'ttc_common.dart';
import 'ttc_insight_screen.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_products_screen.dart';
import 'ttc_strings.dart';
import 'ttc_tests_screen.dart';

/// What these lists have to clear at the bottom: the pinned composer, and
/// nothing else.
///
/// Deliberately NOT `ttcBottomInset`. Every other TTC screen reserves room for
/// the Ask Veda FAB, but `FabRouteObserver` suppresses the FAB over
/// `kAskVedaRoute` - it will not offer to open the screen you are standing on.
/// Inheriting the app-wide reserve here would open a hole above the text field
/// in exchange for clearing a button that is never drawn.
const double _composerInset = 108;

/// Open Ask Veda for TTC. [initialQuery] runs a question immediately (used by
/// the chapter screen's suggestion cards). [partnerMode] suppresses cycle day.
void openTtcAskVeda(BuildContext context,
        {String? initialQuery, bool partnerMode = false}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kAskVedaRoute),
      builder: (_) => TtcAskVedaScreen(
          initialQuery: initialQuery, partnerMode: partnerMode),
    ));

class TtcAskVedaScreen extends StatefulWidget {
  const TtcAskVedaScreen({super.key, this.initialQuery, this.partnerMode = false});

  final String? initialQuery;

  /// True when opened from the partner's side. NEVER sends her cycle day.
  final bool partnerMode;

  @override
  State<TtcAskVedaScreen> createState() => _TtcAskVedaScreenState();
}

class _TtcAskVedaScreenState extends State<TtcAskVedaScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();

  String? _query;
  AskVedaResult? _feed;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    final q = widget.initialQuery?.trim();
    if (q != null && q.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _send(q);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

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

    final s = TtcStore.instance;
    final days = s.daysTrying;
    final res = await AskVedaService.ask(
      t,
      stage: 'trying',
      // displayChapter is the partner-safe accessor (his published chapter, or
      // her own when it's her device).
      chapter: s.displayChapter.name,
      ttcPath: s.path.name,
      // More decisive than the pathway name: the same treatment behaves in
      // opposite ways depending on who is monitoring it, so this is what the
      // service should frame the answer around.
      timingOwnership: s.ownership.id,
      monthsTrying: days == null ? null : (days / 30).floor(),
      // PRIVACY: her cycle day never leaves the partner's device. See the header.
      cycleDay: widget.partnerMode ? null : s.today.cycleDay,
      // Show her the cards in the language she's reading the app in.
      lang: TtcS.current().hinglish ? 'hi' : 'en',
    );
    if (!mounted || _query != t) return;
    setState(() {
      _loading = false;
      if (res != null) {
        _feed = res;
      } else {
        _failed = true;
      }
    });
  }

  void _clear() => setState(() {
        _query = null;
        _feed = null;
        _loading = false;
        _failed = false;
        _ctrl.clear();
      });

  @override
  Widget build(BuildContext context) {
    final t = TtcS.current();
    final hasResult = _query != null;
    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        child: Column(children: [
          _topBar(t),
          Padding(
            padding: const EdgeInsets.fromLTRB(ttcGutter, 4, ttcGutter, 10),
            child: hasResult ? _pillResult() : _pillEdit(t),
          ),
          Expanded(
            child: hasResult ? _resultScroll(t) : _initialScroll(t),
          ),
        ]),
      ),
    );
  }

  Widget _topBar(TtcS t) => Padding(
        padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 8),
        child: Row(children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Icon(Icons.arrow_back_rounded, size: 22, color: ttcInk),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.auto_awesome_rounded, size: 17, color: ttcCoral),
          const SizedBox(width: 7),
          Text('Ask Veda', style: ttcFraunces(21, w: FontWeight.w600)),
        ]),
      );

  Widget _pillEdit(TtcS t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: ttcBorder),
          boxShadow: ttcCardShadow,
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 20, color: ttcMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _ctrl,
              textInputAction: TextInputAction.search,
              onSubmitted: _send,
              cursorColor: ttcPurple,
              style: ttcBody(14, color: ttcInk, w: FontWeight.w600),
              decoration: InputDecoration(
                hintText: t.hinglish ? 'Kuch bhi poochho…' : 'Ask anything…',
                isDense: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: ttcBody(14, color: ttcMuted),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _send(_ctrl.text),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration:
                  const BoxDecoration(color: ttcPurple, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_upward_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
        ]),
      );

  Widget _pillResult() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: ttcBorder),
          boxShadow: ttcCardShadow,
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 20, color: ttcMuted),
          const SizedBox(width: 11),
          Expanded(
            child: Text(_query ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ttcBody(14, color: ttcInk, w: FontWeight.w600)),
          ),
          GestureDetector(
            onTap: _clear,
            child: const Icon(Icons.close_rounded, size: 19, color: ttcMuted),
          ),
        ]),
      );

  // ---- initial view : suggestions from the couple's current chapter --------
  Widget _initialScroll(TtcS t) {
    final chapter = TtcStore.instance.displayChapter;
    final content = ttcChapterContent[chapter];
    final questions = content?.askVeda(t.hinglish) ?? const <String>[];
    return ListView(
      padding: const EdgeInsets.fromLTRB(
          ttcGutter, 6, ttcGutter, _composerInset),
      children: [
        Text(t.hinglish ? 'Kya jaanna hai?' : 'What would you like to know?',
            style: ttcFraunces(20, w: FontWeight.w600)),
        const SizedBox(height: 4),
        Text(
            t.hinglish
                ? 'Neeche se koi sawaal chuno, ya apna likho.'
                : 'Tap a question, or type your own above.',
            style: ttcBody(12.5)),
        const SizedBox(height: 14),
        if (questions.isNotEmpty)
          TtcCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.auto_awesome_outlined,
                    size: 17, color: ttcPurple),
                const SizedBox(width: 9),
                Expanded(
                    child: Text(_chapterTitle(chapter, t), style: ttcJakarta(16))),
              ]),
              const SizedBox(height: 13),
              for (final q in questions) ...[
                GestureDetector(
                  onTap: () => _send(q),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                        color: ttcPanel, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Expanded(
                        child: Text(q,
                            style: ttcBody(13,
                                color: ttcTitleInk, w: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 15, color: ttcPurple),
                    ]),
                  ),
                ),
                const SizedBox(height: 9),
              ],
            ]),
          ),
      ],
    );
  }

  String _chapterTitle(TtcChapter c, TtcS t) => t.hinglish
      ? 'Is chapter ke sawaal'
      : 'Questions for where you are';

  // ---- result view : the 7 sections from the backend feed ------------------
  Widget _resultScroll(TtcS t) => ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(
            ttcGutter, 6, ttcGutter, _composerInset),
        children: _loading
            ? [_loadingCard(t)]
            : (_failed || _feed == null)
                ? [_offlineCard(t)]
                : _sections(_feed!, t),
      );

  List<Widget> _sections(AskVedaResult f, TtcS t) => [
        _answerCard(f.answer, t),
        if (f.meaning.isNotEmpty) ...[
          _head(Icons.favorite_outline_rounded,
              t.hinglish ? 'Tumhare liye iska matlab' : 'What this means for you'),
          TtcCard(child: Text(f.meaning, style: ttcBody(13.5, h: 1.6))),
        ],
        if (f.actions.isNotEmpty) ...[
          _head(Icons.task_alt_rounded,
              t.hinglish ? 'Aage kya kar sakte ho' : 'Recommended next actions'),
          TtcCard(
            child: Column(children: [
              for (var i = 0; i < f.actions.length; i++) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 3),
                    child: Icon(Icons.check_circle_outline_rounded,
                        size: 17, color: ttcPurple),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                      child: Text(f.actions[i],
                          style: ttcBody(13.5,
                              color: ttcTitleInk, w: FontWeight.w600))),
                ]),
                if (i != f.actions.length - 1) const SizedBox(height: 13),
              ],
            ]),
          ),
        ],
        _head(Icons.menu_book_outlined,
            t.hinglish ? 'Aur jaankari' : 'More information'),
        if (f.content.isEmpty)
          _comingSoon(t.hinglish
              ? 'Is par aur padhne ko jaldi aayega'
              : 'More reading on this is coming soon')
        else
          for (final it in f.content) _itemCard(it),
        _head(Icons.play_circle_outline_rounded,
            t.hinglish ? 'Videos' : 'Videos'),
        if (f.videos.isEmpty)
          _comingSoon(t.hinglish
              ? 'Videos jaldi aayenge'
              : 'Videos for this are coming soon')
        else
          for (final it in f.videos) _itemCard(it),
        _head(Icons.forum_outlined,
            t.hinglish ? 'Community' : 'Community insights'),
        _comingSoon(t.hinglish
            ? 'Community insights jaldi aayenge'
            : 'Community insights are coming soon'),
        _head(Icons.redeem_outlined, t.hinglish ? 'Products' : 'Products'),
        if (f.products.isEmpty)
          _comingSoon(t.hinglish
              ? 'Relevant products jaldi aayenge'
              : 'Relevant products are coming soon')
        else
          for (final it in f.products) _itemCard(it),
        _head(Icons.verified_user_outlined, t.hinglish ? 'Services' : 'Services'),
        if (f.services.isEmpty)
          _comingSoon(t.hinglish
              ? 'Relevant services jaldi aayenge'
              : 'Relevant services are coming soon')
        else
          for (final it in f.services) _itemCard(it),
        const SizedBox(height: 18),
        _disclaimer(t),
      ];

  Widget _head(IconData icon, String title) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 24, 2, 11),
        child: Row(children: [
          Icon(icon, size: 18, color: ttcPurple),
          const SizedBox(width: 9),
          Expanded(child: Text(title, style: ttcFraunces(17, w: FontWeight.w600))),
        ]),
      );

  Widget _answerCard(String answer, TtcS t) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.auto_awesome_rounded, size: 18, color: ttcPurple),
            const SizedBox(width: 9),
            Text(t.hinglish ? 'Veda ka jawaab' : 'Veda Answer',
                style: ttcJakarta(15.5)),
          ]),
          const SizedBox(height: 12),
          Text(answer, style: ttcBody(14, h: 1.62, color: ttcInk)),
        ]),
      );

  Widget _loadingCard(TtcS t) => TtcCard(
        child: Row(children: [
          const SizedBox(
              width: 17,
              height: 17,
              child: CircularProgressIndicator(strokeWidth: 2, color: ttcPurple)),
          const SizedBox(width: 13),
          Text(t.hinglish ? 'Veda soch raha hai…' : 'Asking Veda…',
              style: ttcBody(13.5, color: ttcTitleInk, w: FontWeight.w600)),
        ]),
      );

  Widget _offlineCard(TtcS t) => TtcCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.wifi_off_rounded, size: 19, color: ttcCoral),
            const SizedBox(width: 9),
            Expanded(
                child: Text(
                    t.hinglish
                        ? 'Internet se connect karo'
                        : 'Connect to the internet',
                    style: ttcJakarta(15.5))),
          ]),
          const SizedBox(height: 9),
          Text(
              t.hinglish
                  ? 'Ask Veda ko personalised jawaab dene ke liye internet chahiye. Connection check karke dobara try karo.'
                  : 'Ask Veda needs a connection to give you a personalised answer. Please check your internet and try again.',
              style: ttcBody(13.5)),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () { if (_query != null) _send(_query!); },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                  color: ttcPurple, borderRadius: BorderRadius.circular(99)),
              child: Text(t.hinglish ? 'Dobara try karo' : 'Retry',
                  style: ttcBody(13,
                      color: Colors.white, w: FontWeight.w800)),
            ),
          ),
        ]),
      );

  Widget _comingSoon(String label) => TtcCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(children: [
          const Icon(Icons.hourglass_empty_rounded, size: 16, color: ttcMuted),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: ttcBody(12.5, color: ttcMuted, w: FontWeight.w600))),
        ]),
      );

  // A pointer card. Opens the content on TOP of Ask Veda, so Back returns here.
  Widget _itemCard(VedaFeedItem it) {
    final snippet = (it.snippet ?? '').trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TtcCard(
        padding: const EdgeInsets.all(14),
        onTap: () => _openItem(it),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                color: ttcPanel, borderRadius: BorderRadius.all(Radius.circular(13))),
            child: Icon(_kindIcon(it.kind), size: 20, color: ttcPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_kindLabel(it.kind),
                  style: ttcBody(10, color: ttcPurple, w: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(it.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ttcJakarta(14)),
              if (snippet.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(snippet,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ttcBody(12, h: 1.4)),
              ],
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 4, top: 12),
            child: Icon(Icons.chevron_right_rounded, size: 19, color: ttcMuted),
          ),
        ]),
      ),
    );
  }

  void _openItem(VedaFeedItem it) {
    if ((it.kind ?? '').toLowerCase() == 'video') {
      ttcSoon(context, 'Video');
      return;
    }
    if (_deepLink(it)) return; // opened a real TTC screen over Ask Veda
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
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: ttcBorder, borderRadius: BorderRadius.circular(99)),
                ),
              ),
              const SizedBox(height: 16),
              Text(_kindLabel(it.kind),
                  style: ttcBody(10.5, color: ttcPurple, w: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(it.title, style: ttcFraunces(21, w: FontWeight.w600)),
              const SizedBox(height: 12),
              Text(text, style: ttcBody(14, h: 1.62, color: ttcInk)),
            ],
          ),
        ),
      ),
    );
  }

  /// Route a feed card to its REAL screen using the exported doc-id namespace
  /// (`ttcinsight_` / `ttctest_` / `ttccani_` / `ttcprod_` / `ttcoffer_` …).
  /// Everything opens ON TOP of Ask Veda, so Back returns to the conversation.
  /// Returns false when there's no specific screen — the caller falls back to
  /// the reader sheet, which still shows the real content.
  bool _deepLink(VedaFeedItem it) {
    // Hinglish twins carry the same id with a `_hi` suffix.
    var id = it.docId;
    if (id.endsWith('_hi')) id = id.substring(0, id.length - 3);

    void push(Widget w, String name) => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => w, settings: RouteSettings(name: name)));

    if (id.startsWith('ttcinsight_')) {
      final key = id.substring('ttcinsight_'.length);
      final match = ttcInsights.where((i) => i.id == key);
      if (match.isEmpty) return false;
      push(TtcInsightScreen(insight: match.first), 'ttc/insight');
      return true;
    }
    if (id.startsWith('ttcoffer_')) {
      final key = id.substring('ttcoffer_'.length);
      final match = ttcOfferings.where((o) => o.id == key);
      if (match.isEmpty) return false;
      push(TtcOfferingScreen(offering: match.first), 'ttc/offering');
      return true;
    }
    // These three are libraries rather than single-item screens, so the whole
    // library still opens - deliberately, because the neighbouring answers are
    // often the ones she actually needed. The pointed-at item is expanded and
    // scrolled to, so the answer lands on the thing rather than near it.
    if (id.startsWith('ttctest_')) {
      push(TtcTestsScreen(focusId: id.substring('ttctest_'.length)),
          'ttc/tests');
      return true;
    }
    if (id.startsWith('ttccani_')) {
      push(TtcCanIScreen(focusId: id.substring('ttccani_'.length)), 'ttc/canI');
      return true;
    }
    if (id.startsWith('ttcprod_')) {
      push(TtcProductsScreen(focusId: id.substring('ttcprod_'.length)),
          'ttc/products');
      return true;
    }
    return false;
  }

  Widget _disclaimer(TtcS t) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.shield_outlined, size: 15, color: ttcMuted),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
                t.hinglish
                    ? 'Yeh general guidance hai — kuch bhi zaroori ho to apne doctor se zaroor poochho.'
                    : 'This is general guidance — please confirm anything important with your doctor.',
                style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
          ),
        ],
      );

  String _kindLabel(String? k) {
    switch ((k ?? '').toLowerCase()) {
      case 'product':
        return 'PRODUCT';
      case 'expert':
        return 'EXPERT';
      case 'video':
        return 'VIDEO';
      case 'ttctest':
      case 'scan':
        return 'TEST';
      case 'ttccani':
      case 'cani':
        return 'CAN I…';
      case 'ttcmyth':
        return 'MYTH';
      case 'ttcmission':
        return 'FOR YOUR PARTNER';
      default:
        return 'READING';
    }
  }

  IconData _kindIcon(String? k) {
    switch ((k ?? '').toLowerCase()) {
      case 'product':
        return Icons.shopping_bag_outlined;
      case 'expert':
        return Icons.verified_user_outlined;
      case 'video':
        return Icons.play_circle_outline_rounded;
      case 'ttctest':
      case 'scan':
        return Icons.science_outlined;
      case 'ttcmyth':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.menu_book_outlined;
    }
  }
}
