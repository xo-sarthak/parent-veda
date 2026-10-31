// =============================================================================
//  TTC search: the Search button in the home header (2026-10-31)
// -----------------------------------------------------------------------------
//  One header order on every home (header-order pass): profile and messages on
//  the left, the date in the middle, Search and Calendar on the right. Pregnancy
//  and Parenting already had a whole-stage search; Trying to Conceive had only
//  `ttcStageSearch`, the on-the-phone matcher that sits inside its Ask Veda
//  screen. This is the screen that gives that matcher its own door.
//
//  WHAT IT IS: a field, her recent searches (the shared `PvSearchStore`: one
//  person, one history, the same six words Pregnancy and Parenting show), and
//  the hits from `ttcStageSearch`, grouped by kind exactly as Ask Veda groups
//  them. Every hit opens its real screen through the hit's own `open`.
//
//  WHEN NOTHING MATCHES: a calm line, and an "Ask Veda about ..." row that
//  opens TTC Ask Veda with her words already asked (`openTtcAskVeda`). It does
//  not use the global `openAskVeda`, which takes no question and picks the
//  stage from the route stack; TTC's own opener takes the question directly.
//
//  Matching is `ttcStageSearch`'s (word-prefix, title above supporting line, a
//  query under two letters finds nothing). No logic is repeated here.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ask_veda/ask_veda_mark.dart';
import '../../services/pv_search_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../doors/pv_live_search.dart'
    show PvLiveSearchWayOn, pvLiveSearchRecallHeading;
import '../v2/v2_palette.dart';
import 'ttc_askveda_screen.dart' show openTtcAskVeda;
import 'ttc_common.dart';
import 'ttc_stage_search.dart';

/// The route name, so the stage can tell this screen is on top.
const String kTtcSearchRoute = 'ttc/search';

Key ttcSearchHitKey(int i) => ValueKey('ttc_search_hit_$i');

/// Opens the whole-stage search, optionally with her words already in it.
/// [him]: the partner's side (his tools, his films), as `ttcStageSearch` takes.
void openTtcSearch(BuildContext context, {bool him = false, String? query}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: const RouteSettings(name: kTtcSearchRoute),
      builder: (_) => TtcSearchScreen(him: him, query: query),
    ),
  );
}

/// Places to start, before she types: what people on this side look up most.
const List<String> kTtcSearchStarts = [
  'ovulation',
  'fertile window',
  'folic acid',
  'two week wait',
  'irregular periods',
  'pregnancy test',
  'PCOS',
  'IVF',
  'trying after 35',
  'sex timing',
];

class TtcSearchScreen extends StatefulWidget {
  const TtcSearchScreen({super.key, this.him = false, this.query});

  final bool him;
  final String? query;

  @override
  State<TtcSearchScreen> createState() => _TtcSearchScreenState();
}

class _TtcSearchScreenState extends State<TtcSearchScreen> {
  late final TextEditingController _ctl = TextEditingController(
    text: widget.query ?? '',
  );
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    PvSearchStore.instance.init();
    _ctl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _ctl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _put(String q) {
    _ctl.text = q;
    _ctl.selection = TextSelection.collapsed(offset: q.length);
  }

  void _openHit(TtcStageHit h, String q) {
    _focus.unfocus();
    PvSearchStore.instance.remember(q);
    h.open(context);
  }

  void _ask(String q) {
    pvCommitFeedback();
    PvSearchStore.instance.remember(q);
    openTtcAskVeda(context, initialQuery: q, partnerMode: widget.him);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final q = _ctl.text.trim();
    final hits = ttcStageSearch(q, him: widget.him);
    Widget pad(Widget c) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: ttcGutter),
      child: c,
    );
    return Scaffold(
      backgroundColor: ttcBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, ttcGutter, 6),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('ttc_search_back'),
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded, color: ttcInk),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: TextField(
                      key: const ValueKey('ttc_search_field'),
                      controller: _ctl,
                      focusNode: _focus,
                      autofocus: widget.query == null,
                      textInputAction: TextInputAction.search,
                      onSubmitted: (v) {
                        final s = v.trim();
                        if (s.isEmpty) return;
                        final h = ttcStageSearch(s, him: widget.him);
                        if (h.isNotEmpty) {
                          _openHit(h.first, s);
                        } else {
                          _ask(s);
                        }
                      },
                      style: pvManrope(fontSize: 16, color: ttcInk),
                      decoration: InputDecoration(
                        hintText: 'Search cycles, tests, food, anything',
                        hintStyle: pvManrope(fontSize: 15, color: p.ink3),
                        filled: true,
                        fillColor: p.surface,
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: ttcSoft,
                        ),
                        suffixIcon: q.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                icon: const Icon(
                                  Icons.close_rounded,
                                  color: ttcSoft,
                                ),
                                onPressed: () => _ctl.clear(),
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(color: ttcLine),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(color: ttcLine),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(999),
                          borderSide: const BorderSide(color: ttcInk),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: PvSearchStore.instance,
                builder: (context, _) => ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: q.length < 2
                      ? [
                          if (PvSearchStore.instance.recent.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            pvLiveSearchRecallHeading(
                              p,
                              'Recent',
                              onClear: PvSearchStore.instance.clear,
                            ),
                            const SizedBox(height: 4),
                            for (final r in PvSearchStore.instance.recent)
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: ttcGutter,
                                ),
                                leading: const Icon(
                                  Icons.history_rounded,
                                  color: ttcMuted,
                                ),
                                title: Text(
                                  r,
                                  style: pvManrope(fontSize: 15, color: ttcInk),
                                ),
                                onTap: () => _put(r),
                              ),
                          ],
                          const SizedBox(height: 18),
                          pad(
                            Text(
                              'Places to start',
                              style: pvFraunces(
                                fontSize: 21,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: ttcInk,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          pad(
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final s in kTtcSearchStarts)
                                  ActionChip(
                                    key: ValueKey('ttc_search_start_$s'),
                                    label: Text(
                                      s,
                                      style: pvManrope(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: ttcInk,
                                      ),
                                    ),
                                    backgroundColor: p.surface,
                                    side: const BorderSide(color: ttcLine),
                                    shape: const StadiumBorder(),
                                    onPressed: () => _put(s),
                                  ),
                              ],
                            ),
                          ),
                        ]
                      : [
                          const SizedBox(height: 16),
                          pad(
                            Text(
                              hits.isEmpty
                                  ? 'Nothing by that name yet'
                                  : 'In ParentVeda',
                              style: pvFraunces(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                                height: 1.15,
                                color: ttcInk,
                              ),
                            ),
                          ),
                          if (hits.isEmpty) ...[
                            const SizedBox(height: 6),
                            pad(
                              Text(
                                'Check the spelling, try a shorter word, or ask Veda in your own words.',
                                style: pvManrope(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: ttcSoft,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          for (var i = 0; i < hits.length; i++)
                            _TtcHitRow(
                              key: ttcSearchHitKey(i),
                              p: p,
                              hit: hits[i],
                              onTap: () => _openHit(hits[i], q),
                            ),
                          const SizedBox(height: 14),
                          pad(
                            PvLiveSearchWayOn(
                              p: p,
                              mark: const AskVedaMark(size: 20),
                              title: 'Ask Veda about "$q"',
                              line:
                                  'In your own words, about where you are in your journey.',
                              onTap: () => _ask(q),
                            ),
                          ),
                        ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One result, in the geometry the Parenting and Pregnancy search rows share
/// (40 well, title 15/w700, line 12.5, kind 11, chevron).
class _TtcHitRow extends StatelessWidget {
  const _TtcHitRow({
    super.key,
    required this.p,
    required this.hit,
    required this.onTap,
  });
  final V2Palette p;
  final TtcStageHit hit;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final well = Color.alphaBlend(ttcInk.withValues(alpha: 0.06), p.surface);
    return PvPress(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ttcGutter,
            vertical: 10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: well,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(hit.kind.icon, size: 20, color: ttcSoft),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hit.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: ttcInk,
                      ),
                    ),
                    if (hit.line.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        hit.line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: pvManrope(
                          fontSize: 12.5,
                          height: 1.35,
                          color: ttcSoft,
                        ),
                      ),
                    ],
                    const SizedBox(height: 3),
                    Text(
                      hit.kind.heading,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ttcMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(top: 9),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ttcMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
