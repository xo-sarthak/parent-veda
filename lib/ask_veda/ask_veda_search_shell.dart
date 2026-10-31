// =============================================================================
//  ask_veda_search_shell.dart - Ask Veda as a SEARCH (Google's mobile flow)
// -----------------------------------------------------------------------------
//  ONE presentation for all three Ask Veda screens (pregnancy, trying to
//  conceive, parenting), approved as a prototype on 2026-10-31
//  ("ASK VEDA: a search, Google's mobile flow"). It draws four states:
//
//    1. HOME     no header row. A back arrow (left) and her avatar (right); in
//                the middle the Aurora mark and the "Ask Veda" wordmark, one
//                pill bar, "Answers for <her context>", four shortcuts and the
//                stage's "Asked often in ..." questions as tiles.
//    2. FOCUS    she taps the bar: it sits at the top, the keyboard comes up,
//                the stage's questions are listed under it.
//    3. TYPING   those questions filter by prefix, the completion in bold.
//    4. RESULTS  her question in a bar with the small mark, filter tabs
//                (All / Reads / Videos / Products / Experts), then "Veda's
//                answer" (answer + what it means, Show more for what to do,
//                the disclaimer at the foot of the card, a shimmer while it
//                loads), then the results: Reads, Videos, Products, Experts.
//
//  ⚠️ PRESENTATION ONLY. This widget owns no request, no engine and no
//  stage logic. Each screen keeps its own request call to the service (the
//  fields it sends are a two-repo contract), its own suggestion source, its
//  own offline fallback, and decides what every item opens (`onOpen`). The
//  shell is handed the finished state (`query`, `loading`, `failed`,
//  `result`) and calls back (`onAsk`, `onClear`, `onRetry`). That split is why
//  three stages can share one look without sharing one behaviour: a general
//  fact about UI code that has to serve several owners - the shared part
//  draws, the owners decide.
//
//  ⚠️ NOT HERE ON PURPOSE: "People also ask". The service does not send it,
//  so drawing it would be inventing content. "You could also ask" (below the
//  reads) is the older, client-side list of related questions from the
//  stage's own suggestion pool, unchanged in what it is.
//
//  ⚠️ A RED-FLAG ANSWER IS NEVER COLLAPSED. Every screen used to show the
//  recommended actions in full. They now sit behind "Show more", except when
//  the service says the answer is a red flag (`source == 'red_flag'`): then
//  "What to do" is open and the toggle is not offered, so the safety steps
//  are never one tap away.
// =============================================================================

import 'dart:io' show File, Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../localization/app_language.dart' show S;
import '../screens/products/pv_store_chrome.dart' show kPvInk, kPvLine;
import '../services/profile_photo_store.dart';
import '../services/remote/ask_veda_service.dart';
import '../theme/pv_fonts.dart';
import '../widgets/mic_dictation_button.dart';
import 'ask_veda_mark.dart';
import 'pv_veda_reveal.dart';

/// The four kinds of result an answer can carry.
enum VedaSection { reads, videos, products, experts }

/// A result row that is not a [VedaFeedItem]: the app's own pages found on the
/// phone (pregnancy's in-app search, TTC's matching reads) or a stage's
/// standing link ("Talk to an expert"). Tapping runs [onTap].
class VedaRow {
  const VedaRow({
    required this.title,
    required this.onTap,
    this.meta = '',
    this.blurb = '',
    this.icon = Icons.menu_book_outlined,
    this.cta = 'Open',
    this.rowKey,
  });

  final String title;
  final String meta;
  final String blurb;
  final IconData icon;
  final String cta;
  final VoidCallback onTap;
  final Key? rowKey;
}

enum _View { home, focus, results }

enum _Tab { all, reads, videos, products, experts }

// ---- the look: ink on white, one pill grey, the hairline ---------------------
const Color _ink = kPvInk;
const Color _ink2 = Color(0xFF555159);
const Color _ink3 = Color(0xFF6F6B72);
const Color _barFill = Color(0xFFF1F0F3);

class AskVedaSearchShell extends StatefulWidget {
  const AskVedaSearchShell({
    super.key,
    required this.contextLine,
    required this.suggestHeading,
    required this.suggestions,
    required this.query,
    required this.loading,
    required this.failed,
    required this.result,
    required this.onAsk,
    required this.onClear,
    required this.onRetry,
    required this.onOpen,
    required this.disclaimer,
    required this.onAvatar,
    this.pool = const [],
    this.badge,
    this.usedLine,
    this.avatarInitial = '',
    this.hint = 'Ask or search anything',
    this.followUps = const [],
    this.contentFallback = const [],
    this.offlineExtras = const [],
    this.offlineHeading = 'Meanwhile, in the app',
    this.offlineTitle = 'Connect to the internet',
    this.offlineBody =
        'Ask Veda needs the internet to answer you. Please check your connection and try again.',
    this.retryLabel = 'Retry',
    this.emptyProducts,
    this.emptyExperts,
    this.typingExtras,
    this.bottomBar,
    this.bottomInset = 28,
  });

  /// The bold part of "Answers for ..., from what ParentVeda holds".
  final String contextLine;

  /// "Asked often in week 24" and the questions it heads: the stage's own.
  final String suggestHeading;
  final List<String> suggestions;

  /// Every question the stage knows, for the typing completions (a superset of
  /// [suggestions]).
  final List<String> pool;

  // ---- the owner's state (the shell holds none of it) -----------------------
  final String? query;
  final bool loading;
  final bool failed;
  final AskVedaResult? result;

  final void Function(String question) onAsk;
  final VoidCallback onClear;
  final VoidCallback onRetry;
  final VoidCallback onAvatar;

  /// What an item opens is the screen's call, exactly as before.
  final void Function(VedaFeedItem item, VedaSection section) onOpen;

  final String disclaimer;
  final String? badge;
  final String? usedLine;
  final String avatarInitial;
  final String hint;

  /// "You could also ask": related questions from the stage's pool.
  final List<String> followUps;

  /// Reads shown when the service sent none (the phone's own matches).
  final List<VedaRow> contentFallback;

  /// What she can still open with no connection.
  final List<VedaRow> offlineExtras;
  final String offlineHeading;
  final String offlineTitle;
  final String offlineBody;
  final String retryLabel;

  /// A standing link a stage shows when the service sent no products/experts.
  final VedaRow? emptyProducts;
  final VedaRow? emptyExperts;

  /// Stage-owned rows under the typing completions (TTC's stage search).
  final List<Widget> Function(String typed)? typingExtras;

  /// Chrome the owner keeps (Parenting's bottom nav): shown on home and
  /// results, hidden while the keyboard is up.
  final Widget? bottomBar;

  /// What the scrolling views keep clear at the foot.
  final double bottomInset;

  @override
  State<AskVedaSearchShell> createState() => _AskVedaSearchShellState();
}

class _AskVedaSearchShellState extends State<AskVedaSearchShell> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _scroll = ScrollController();

  bool _editing = false;
  _Tab _tab = _Tab.all;

  /// A shortcut she tapped on home: the results open on that tab.
  _Tab? _preTab;

  bool _showMore = false;

  /// How far the answer has arrived: 0 the answer is typing, 1 "What it
  /// means" is typing, 2 everything below has come in. Presentation only.
  int _reveal = 0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(AskVedaSearchShell old) {
    super.didUpdateWidget(old);
    if (!identical(old.result, widget.result) || old.query != widget.query) {
      _reveal = 0;
      _showMore = false;
    }
    if (old.query != widget.query) {
      if (widget.query == null) {
        _tab = _Tab.all;
        _preTab = null;
      } else {
        _tab = _preTab ?? _Tab.all;
        _preTab = null;
      }
      if (_scroll.hasClients) _scroll.jumpTo(0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ---- moving between the states ---------------------------------------------
  void _startEditing({String? text, _Tab? preTab}) {
    setState(() {
      _editing = true;
      if (preTab != null) _preTab = preTab;
      _ctrl.text = text ?? '';
      _ctrl.selection = TextSelection.collapsed(offset: _ctrl.text.length);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _editing) _focus.requestFocus();
    });
  }

  void _leaveFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _editing = false;
      _preTab = null;
      _ctrl.clear();
    });
  }

  void _submit(String text) {
    final t = text.trim();
    if (t.isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _editing = false;
      _ctrl.clear();
    });
    widget.onAsk(t);
  }

  _View get _view => _editing
      ? _View.focus
      : (widget.query != null ? _View.results : _View.home);

  // ---- build -----------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final view = _view;
    final keyboardUp = MediaQuery.viewInsetsOf(context).bottom > 0;
    return PopScope(
      // Back steps out of a state before it leaves the screen: the keyboard
      // view returns to where she was, an answer returns to the home.
      canPop: view == _View.home,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (view == _View.focus) {
          _leaveFocus();
        } else {
          widget.onClear();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0, 0.02),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(view),
                    child: switch (view) {
                      _View.home => _home(),
                      _View.focus => _focusView(),
                      _View.results => _results(),
                    },
                  ),
                ),
              ),
              if (widget.bottomBar != null &&
                  view != _View.focus &&
                  !keyboardUp)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 18,
                  child: widget.bottomBar!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  //  1. HOME
  // ===========================================================================
  Widget _home() {
    return ListView(
      key: const ValueKey('veda_home'),
      padding: EdgeInsets.fromLTRB(18, 0, 18, widget.bottomInset),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 22, color: _ink),
            ),
            const Spacer(),
            _avatar(),
          ],
        ),
        const SizedBox(height: 44),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AskVedaMark(size: 46),
            const SizedBox(width: 10),
            Text(
              'Ask Veda',
              style: pvFraunces(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
                color: _ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _homeBar(),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: pvManrope(fontSize: 12.5, color: _ink2),
            children: [
              const TextSpan(text: 'Answers for '),
              TextSpan(
                text: widget.contextLine,
                style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const TextSpan(text: ', from what ParentVeda holds'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 22),
        _shortcuts(),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 26),
          Text(
            widget.suggestHeading.toUpperCase(),
            key: const ValueKey('veda_home_heading'),
            style: pvManrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: _ink3,
            ),
          ),
          const SizedBox(height: 10),
          for (final q in widget.suggestions.take(4)) _tile(q),
        ],
      ],
    );
  }

  Widget _avatar() {
    final initial = widget.avatarInitial.trim();
    return ListenableBuilder(
      listenable: ProfilePhotoStore.instance..load(),
      builder: (context, _) {
        final path = ProfilePhotoStore.instance.path;
        Widget face = initial.isEmpty
            ? const Icon(Icons.person_rounded, size: 21, color: Colors.white)
            : Text(
                initial,
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              );
        if (path != null && !kIsWeb) {
          face = ClipOval(
            child: Image.file(
              File(path),
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => face,
            ),
          );
        }
        return Semantics(
          button: true,
          label: 'You',
          child: GestureDetector(
            key: const ValueKey('veda_avatar'),
            onTap: widget.onAvatar,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: _ink,
                shape: BoxShape.circle,
              ),
              child: face,
            ),
          ),
        );
      },
    );
  }

  Widget _homeBar() => Material(
    color: _barFill,
    shape: const StadiumBorder(),
    child: InkWell(
      key: const ValueKey('veda_home_bar'),
      customBorder: const StadiumBorder(),
      onTap: () => _startEditing(),
      child: Container(
        height: 52,
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, size: 20, color: _ink2),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _ink3,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _shortcuts() {
    // Four doors into the same search: each opens the bar on that kind of
    // result, so the answer page comes up on the matching tab. Quiet fills
    // behind the icon only, never behind text.
    Widget one(String label, IconData icon, _Tab tab, double hue, String key) {
      final bg = HSLColor.fromAHSL(1, hue, 0.40, 0.94).toColor();
      final fg = HSLColor.fromAHSL(1, hue, 0.45, 0.34).toColor();
      return Expanded(
        child: InkWell(
          key: ValueKey(key),
          borderRadius: BorderRadius.circular(16),
          onTap: () => _startEditing(preTab: tab),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 21, color: fg),
                ),
                const SizedBox(height: 7),
                Text(
                  label,
                  style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        one(
          'Reads',
          Icons.menu_book_outlined,
          _Tab.reads,
          268,
          'veda_short_reads',
        ),
        one(
          'Videos',
          Icons.play_circle_outline_rounded,
          _Tab.videos,
          344,
          'veda_short_videos',
        ),
        one(
          'Products',
          Icons.shopping_bag_outlined,
          _Tab.products,
          42,
          'veda_short_products',
        ),
        one(
          'Experts',
          Icons.forum_outlined,
          _Tab.experts,
          160,
          'veda_short_experts',
        ),
      ],
    );
  }

  Widget _tile(String q) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _submit(q),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: kPvLine),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up_rounded, size: 16, color: _ink3),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  q,
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ===========================================================================
  //  2 + 3. FOCUS and TYPING
  // ===========================================================================
  Widget _focusView() {
    final typed = _ctrl.text;
    return Column(
      key: const ValueKey('veda_focus'),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
          height: 50,
          decoration: BoxDecoration(
            color: _barFill,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: _leaveFocus,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 21,
                  color: _ink,
                ),
              ),
              Expanded(
                child: TextField(
                  key: const ValueKey('veda_field'),
                  controller: _ctrl,
                  focusNode: _focus,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _submit,
                  cursorColor: _ink,
                  cursorWidth: 2,
                  style: pvManrope(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintStyle: pvManrope(fontSize: 15.5, color: _ink3),
                  ),
                ),
              ),
              if (typed.isNotEmpty)
                IconButton(
                  tooltip: 'Clear',
                  onPressed: _ctrl.clear,
                  icon: const Icon(Icons.close_rounded, size: 19, color: _ink3),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: MicDictateButton(
                    controller: _ctrl,
                    s: S.now,
                    color: _ink,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(top: 8, bottom: widget.bottomInset),
            children: typed.trim().isEmpty
                ? _emptyFocusRows()
                : _typingRows(typed.trim()),
          ),
        ),
      ],
    );
  }

  List<Widget> _emptyFocusRows() => [
    if (widget.suggestions.isNotEmpty)
      Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 2),
        child: Text(
          widget.suggestHeading.toUpperCase(),
          style: pvManrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
            color: _ink3,
          ),
        ),
      ),
    for (final q in widget.suggestions)
      _suggestRow(q, '', icon: Icons.trending_up_rounded),
  ];

  /// Typed words, then the questions that START with them (completion in
  /// bold), then the ones that merely contain a word starting with them.
  List<Widget> _typingRows(String typed) {
    final low = typed.toLowerCase();
    final seen = <String>{low};
    final prefix = <String>[];
    final inside = <String>[];
    for (final q in {...widget.suggestions, ...widget.pool}) {
      final k = q.toLowerCase();
      if (!seen.add(k)) continue;
      if (k.startsWith(low)) {
        prefix.add(q);
      } else if (RegExp(r'(^|[^a-z0-9])' + RegExp.escape(low)).hasMatch(k)) {
        inside.add(q);
      }
    }
    return [
      _suggestRow(
        typed,
        typed,
        icon: Icons.search_rounded,
        keyName: 'veda_sug_typed',
      ),
      for (final q in prefix.take(7)) _suggestRow(q, typed),
      for (final q in inside.take(4)) _suggestRow(q, ''),
      if (widget.typingExtras != null) ...widget.typingExtras!(typed),
    ];
  }

  Widget _suggestRow(
    String q,
    String typed, {
    IconData icon = Icons.search_rounded,
    String? keyName,
  }) {
    final lowQ = q.toLowerCase();
    final hasPrefix = typed.isNotEmpty && lowQ.startsWith(typed.toLowerCase());
    final head = hasPrefix ? q.substring(0, typed.length) : '';
    final tail = hasPrefix ? q.substring(typed.length) : q;
    final base = pvManrope(fontSize: 14.5, color: _ink);
    return InkWell(
      key: keyName == null ? null : ValueKey(keyName),
      onTap: () => _submit(q),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 17, color: _ink3),
            const SizedBox(width: 14),
            Expanded(
              child: hasPrefix && tail.isNotEmpty
                  ? Text.rich(
                      TextSpan(
                        style: base,
                        children: [
                          TextSpan(text: head),
                          TextSpan(
                            text: tail,
                            style: base.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    )
                  : Text(q, style: base),
            ),
            // Puts the question in the bar to edit, without asking it.
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                _ctrl.text = q;
                _ctrl.selection = TextSelection.collapsed(offset: q.length);
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.north_west_rounded, size: 17, color: _ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  //  4. RESULTS
  // ===========================================================================
  Widget _results() {
    return Column(
      key: const ValueKey('veda_results'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 0),
          child: Row(
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: widget.onClear,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  size: 21,
                  color: _ink,
                ),
              ),
              const AskVedaMark(size: 30),
              const SizedBox(width: 8),
              Expanded(child: _resultBar()),
            ],
          ),
        ),
        _tabs(),
        Expanded(
          child: ListView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(14, 14, 14, widget.bottomInset + 4),
            children: _body(),
          ),
        ),
      ],
    );
  }

  Widget _resultBar() => Material(
    color: Colors.white,
    shape: StadiumBorder(side: BorderSide(color: kPvLine)),
    child: InkWell(
      key: const ValueKey('veda_edit_query'),
      customBorder: const StadiumBorder(),
      onTap: () => _startEditing(text: widget.query ?? ''),
      child: Container(
        height: 46,
        padding: const EdgeInsets.only(left: 16, right: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.query ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
            ),
            IconButton(
              key: const ValueKey('veda_clear_query'),
              tooltip: 'Clear',
              visualDensity: VisualDensity.compact,
              onPressed: widget.onClear,
              icon: const Icon(Icons.close_rounded, size: 19, color: _ink3),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _tabs() {
    Widget t(String label, _Tab tab) {
      final on = _tab == tab;
      return Padding(
        padding: const EdgeInsets.only(right: 18),
        child: InkWell(
          key: ValueKey('veda_tab_${tab.name}'),
          onTap: () => setState(() => _tab = tab),
          child: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: on ? _ink : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
            child: Text(
              label,
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: on ? _ink : _ink3,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kPvLine)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(18, 8, 0, 0),
        child: Row(
          children: [
            t('All', _Tab.all),
            t('Reads', _Tab.reads),
            t('Videos', _Tab.videos),
            t('Products', _Tab.products),
            t('Experts', _Tab.experts),
          ],
        ),
      ),
    );
  }

  bool _on(_Tab t) => _tab == _Tab.all || _tab == t;

  List<Widget> _body() {
    if (widget.loading) return [_answerCard(null)];
    final f = widget.result;
    if (widget.failed || f == null) return _offline();

    final rest = _reveal >= 2;
    var n = 0;
    Widget later(Widget w) => PvVedaFadeIn(show: rest, index: n++, child: w);
    final out = <Widget>[];

    if (_tab == _Tab.all) out.add(_answerCard(f));

    // ---- Reads: what the service sent, else the phone's own matches ----------
    final reads = <Widget>[
      for (final it in f.content)
        _readRow(
          meta: 'ParentVeda · ${_kindLabel(it.kind)}',
          title: it.title,
          blurb: (it.snippet ?? '').trim(),
          icon: _kindIcon(it.kind),
          onTap: () => widget.onOpen(it, VedaSection.reads),
        ),
      if (f.content.isEmpty)
        for (final r in widget.contentFallback)
          _readRow(
            key: r.rowKey,
            meta: r.meta.isEmpty ? 'In the app' : r.meta,
            title: r.title,
            blurb: r.blurb,
            icon: r.icon,
            onTap: r.onTap,
          ),
    ];
    if (_on(_Tab.reads)) {
      if (reads.isNotEmpty) {
        out.add(later(_section('Reads', reads)));
      } else if (_tab == _Tab.reads) {
        out.add(_invite('reads'));
      }
    }

    if (_tab == _Tab.all && widget.followUps.isNotEmpty) {
      out.add(later(_followUps()));
    }

    // ---- Videos ---------------------------------------------------------------
    if (_on(_Tab.videos)) {
      if (f.videos.isNotEmpty) {
        out.add(
          later(
            _section('Videos', [
              SizedBox(
                height: 138,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: f.videos.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _videoCard(f.videos[i], i),
                ),
              ),
            ]),
          ),
        );
      } else if (_tab == _Tab.videos) {
        out.add(_invite('videos'));
      }
    }

    // ---- Products -------------------------------------------------------------
    if (_on(_Tab.products)) {
      if (f.products.isNotEmpty) {
        out.add(
          later(
            _section('Products', [
              SizedBox(
                height: 150,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: f.products.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (_, i) => _productCard(f.products[i], i),
                ),
              ),
            ]),
          ),
        );
      } else if (widget.emptyProducts != null) {
        out.add(
          later(_section('Products', [_expertRow(null, widget.emptyProducts)])),
        );
      } else if (_tab == _Tab.products) {
        out.add(_invite('products'));
      }
    }

    // ---- Experts (the service's `services`) --------------------------------------
    if (_on(_Tab.experts)) {
      if (f.services.isNotEmpty) {
        out.add(
          later(
            _section('Experts', [
              for (final it in f.services) _expertRow(it, null),
            ]),
          ),
        );
      } else if (widget.emptyExperts != null) {
        out.add(
          later(_section('Experts', [_expertRow(null, widget.emptyExperts)])),
        );
      } else if (_tab == _Tab.experts) {
        out.add(_invite('experts'));
      }
    }
    return out;
  }

  // ---- Veda's answer ------------------------------------------------------------
  Widget _answerCard(AskVedaResult? f) {
    final redFlag = f?.source == 'red_flag';
    final hasActions = f != null && f.actions.isNotEmpty;
    final open = _showMore || redFlag;
    return Container(
      key: const ValueKey('veda_answer_card'),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF6F2FF), Color(0xFFFFF5EE)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AskVedaMark(size: 20),
              const SizedBox(width: 8),
              Text(
                "Veda's answer",
                style: pvManrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const Spacer(),
              if (widget.badge != null)
                Text(
                  widget.badge!,
                  style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _ink3,
                  ),
                ),
            ],
          ),
          if (f == null) ...[
            const SizedBox(height: 12),
            const _Shimmer(),
          ] else ...[
            const SizedBox(height: 10),
            PvTypewriterText(
              f.answer,
              key: ValueKey('veda_answer_${f.answer}'),
              animate: _reveal == 0,
              onDone: _answerDone,
              followBottomInset: 60,
              style: pvFraunces(
                fontSize: 18,
                height: 1.4,
                letterSpacing: -0.2,
                color: _ink,
              ),
            ),
            if (f.meaning.isNotEmpty && _reveal >= 1) ...[
              _label('What it means'),
              PvTypewriterText(
                f.meaning,
                key: ValueKey('veda_meaning_${f.meaning}'),
                animate: _reveal == 1,
                onDone: _meaningDone,
                followBottomInset: 60,
                style: pvManrope(fontSize: 13.5, height: 1.5, color: _ink2),
              ),
            ],
            if (hasActions && _reveal >= 2) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: open
                    ? Column(
                        key: const ValueKey('veda_what_to_do'),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('What to do'),
                          for (final a in f.actions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      top: 7,
                                      right: 9,
                                    ),
                                    child: Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: _ink2,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      a,
                                      style: pvManrope(
                                        fontSize: 13.5,
                                        height: 1.5,
                                        color: _ink2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
              // A red flag keeps what to do open: no toggle to hide it.
              if (!redFlag) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton.icon(
                    key: const ValueKey('veda_show_more'),
                    onPressed: () => setState(() => _showMore = !_showMore),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _ink,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: kPvLine),
                      shape: const StadiumBorder(),
                      textStyle: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    icon: Icon(
                      open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    label: Text(open ? 'Show less' : 'Show more'),
                  ),
                ),
              ],
            ],
            if (widget.usedLine != null && _reveal >= 2) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: _ink2,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.usedLine!,
                      style: pvManrope(
                        fontSize: 12,
                        height: 1.45,
                        color: _ink2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Text(
              widget.disclaimer,
              key: const ValueKey('veda_disclaimer'),
              style: pvManrope(fontSize: 11.5, height: 1.45, color: _ink3),
            ),
          ],
        ],
      ),
    );
  }

  void _answerDone() {
    if (!mounted || _reveal > 0) return;
    setState(
      () => _reveal = (widget.result?.meaning.isNotEmpty ?? false) ? 1 : 2,
    );
  }

  void _meaningDone() {
    if (!mounted || _reveal > 1) return;
    setState(() => _reveal = 2);
  }

  Widget _label(String t) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 14, 0, 5),
    child: Text(
      t.toUpperCase(),
      style: pvManrope(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
        color: _ink3,
      ),
    ),
  );

  // ---- the offline state: unchanged copy, new frame ---------------------------------
  List<Widget> _offline() => [
    Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPvLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 20,
                color: Color(0xFFF0476A),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.offlineTitle,
                  style: pvManrope(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.offlineBody,
            style: pvManrope(fontSize: 13.5, height: 1.55, color: _ink2),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            key: const ValueKey('veda_retry'),
            onTap: widget.onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
              decoration: BoxDecoration(
                color: _ink,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                widget.retryLabel,
                style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    if (widget.offlineExtras.isNotEmpty)
      _section(widget.offlineHeading, [
        for (final r in widget.offlineExtras)
          _readRow(
            key: r.rowKey,
            meta: r.meta.isEmpty ? 'In the app' : r.meta,
            title: r.title,
            blurb: r.blurb,
            icon: r.icon,
            onTap: r.onTap,
          ),
      ]),
  ];

  // ---- the building blocks of a result ------------------------------------------------
  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            title,
            style: pvFraunces(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
        ),
        ...children,
      ],
    ),
  );

  /// An empty tab is an invitation, never a blank page.
  Widget _invite(String what) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Container(
      key: ValueKey('veda_empty_$what'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPvLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No $what for this one yet.',
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try asking it another way, or ask something else.',
            style: pvManrope(fontSize: 13, height: 1.45, color: _ink2),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _startEditing(text: widget.query ?? ''),
            child: Text(
              'Ask another way',
              style: pvManrope(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _ink,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _readRow({
    required String meta,
    required String title,
    required String blurb,
    required IconData icon,
    required VoidCallback onTap,
    Key? key,
  }) => InkWell(
    key: key,
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(2, 6, 2, 14),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: kPvLine)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: _barFill,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 13, color: _ink),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  meta,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 12, color: _ink2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: pvFraunces(
              fontSize: 17.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              color: _ink,
            ),
          ),
          if (blurb.isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              blurb,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 13, height: 1.45, color: _ink2),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _videoCard(VedaFeedItem it, int i) {
    const tones = [
      [Color(0xFF8A7360), Color(0xFF3B2D28)],
      [Color(0xFF6A5ACD), Color(0xFF2E2A5C)],
      [Color(0xFF5E7F86), Color(0xFF26373B)],
    ];
    return InkWell(
      onTap: () => widget.onOpen(it, VedaSection.videos),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 86,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: tones[i % tones.length],
                ),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              it.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _productCard(VedaFeedItem it, int i) {
    final hues = [268.0, 42.0, 206.0, 160.0];
    final bg = HSLColor.fromAHSL(
      1,
      hues[i % hues.length],
      0.32,
      0.91,
    ).toColor();
    return InkWell(
      onTap: () => widget.onOpen(it, VedaSection.products),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 118,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 26,
                color: _ink3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              it.title,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// One expert/service: from the service's feed ([it]) or a stage's standing
  /// link ([row]).
  Widget _expertRow(VedaFeedItem? it, VedaRow? row) {
    final title = it?.title ?? row!.title;
    final sub = it != null ? (it.snippet ?? '').trim() : row!.blurb;
    final cta = it != null ? 'View' : row!.cta;
    final initial = title.trim().isEmpty ? '' : title.trim()[0].toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        key: row?.rowKey,
        borderRadius: BorderRadius.circular(16),
        onTap: () =>
            it != null ? widget.onOpen(it, VedaSection.experts) : row!.onTap(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: kPvLine),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: _barFill,
                  shape: BoxShape.circle,
                ),
                child: row != null
                    ? Icon(row.icon, size: 20, color: _ink)
                    : Text(
                        initial,
                        style: pvManrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: _ink,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    if (sub.isNotEmpty)
                      Text(
                        sub,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 12,
                          height: 1.4,
                          color: _ink2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  cta,
                  style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _followUps() => _section('You could also ask', [
    Container(
      decoration: BoxDecoration(
        border: Border.all(color: kPvLine),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          for (final (i, q) in widget.followUps.indexed)
            InkWell(
              key: ValueKey('veda_follow_$i'),
              onTap: () => widget.onAsk(q),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
                decoration: BoxDecoration(
                  border: i == 0
                      ? null
                      : Border(top: BorderSide(color: kPvLine)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.subdirectory_arrow_right_rounded,
                      size: 18,
                      color: _ink3,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Text(
                        q,
                        style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: _ink,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: _ink,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    ),
  ]);

  // ---- kinds: the service's `kind` string -> a label and a line icon -----------------
  String _kindLabel(String? k) {
    switch ((k ?? '').toLowerCase()) {
      case 'product':
        return 'Product';
      case 'expert':
        return 'Expert';
      case 'video':
        return 'Video';
      case 'recipe':
        return 'Recipe';
      case 'cani':
      case 'ttccani':
        return 'Can I?';
      case 'scan':
        return 'Scan guide';
      case 'ttctest':
        return 'Test';
      case 'health':
        return 'Health';
      case 'garbh':
      case 'spiritual':
        return 'Garbh Sanskar';
      case 'symptom':
        return 'Symptom';
      case 'ttcmyth':
        return 'Myth';
      case 'ttcmission':
        return 'For your partner';
      default:
        return 'Read';
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
      case 'recipe':
        return Icons.restaurant_menu_rounded;
      case 'health':
      case 'scan':
        return Icons.monitor_heart_outlined;
      case 'ttctest':
        return Icons.science_outlined;
      case 'ttcmyth':
        return Icons.lightbulb_outline_rounded;
      case 'garbh':
      case 'spiritual':
        return Icons.self_improvement_rounded;
      default:
        return Icons.menu_book_outlined;
    }
  }
}

/// The wait inside the answer card: four soft bars with a light sweeping
/// across. Still under reduced motion and under `flutter test` (a ticker that
/// never stops would hang every `pumpAndSettle`, as the Aurora mark's does).
class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  bool _started = false;

  static bool get _underTest =>
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = _underTest || MediaQuery.disableAnimationsOf(context);
    if (!still && !_started) {
      _started = true;
      _c.repeat();
    } else if (still && _started) {
      _started = false;
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Veda is putting your answer together',
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          Widget bar(double w) => FractionallySizedBox(
            widthFactor: w,
            alignment: Alignment.centerLeft,
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: const [
                    Color(0xFFE9E2FB),
                    Color(0xFFFBE3EE),
                    Color(0xFFE9E2FB),
                  ],
                  begin: Alignment(-1 - 2 * (1 - _c.value), 0),
                  end: Alignment(1 + 2 * _c.value, 0),
                ),
              ),
            ),
          );
          return Column(
            children: [
              bar(.96),
              const SizedBox(height: 9),
              bar(.88),
              const SizedBox(height: 9),
              bar(.72),
              const SizedBox(height: 9),
              bar(.90),
            ],
          );
        },
      ),
    );
  }
}
