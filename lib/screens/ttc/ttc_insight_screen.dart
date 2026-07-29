// =============================================================================
//  TTC - the insight reader
// -----------------------------------------------------------------------------
//  One insight, read properly. Follows ParentVeda's editorial structure:
//
//      What → Why → What this means for you → Today's takeaway → Related
//                                                    - TTC master, §3.2
//
//  ---------------------------------------------------------------------------
//  A-50: this was the clearest place TTC still read as the junior stage
//
//  It was a title, the body, and a takeaway on a fixed white page. The
//  parenting stage has a full reading experience — progress, contents, font
//  size, light/sepia/dark, read-next, save — so the same company shipped two
//  readers of very different quality, and the one attached to the most anxious
//  audience was the poorer of the two.
//
//  ---------------------------------------------------------------------------
//  What was taken from parenting's reader, and what was deliberately left
//
//  TAKEN: reading progress, font size, light/sepia/dark, save, read-next.
//  Those are about comfort and continuation, and they matter more here than
//  there — this is health writing read at eleven at night by someone who is
//  worried.
//
//  LEFT: the table of contents, and the mid-article video slot. A TTC insight
//  is a twenty-five to sixty second read with no sections. A contents list on
//  it would be ceremony — a control that exists to look thorough and answers a
//  question nobody has. Copying a component because the other stage has it is
//  how uniformity turns into clutter.
//
//  The rule this follows: match the OTHER stage's standard of care, not its
//  component list.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_daily_data.dart';
import '../../ttc/ttc_read_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

/// The three reading surfaces. Sepia is not decoration - it is the one most
/// people actually keep, and dark is what a phone at 11pm needs.
enum TtcReadMode { light, sepia, dark }

class _ReadPalette {
  const _ReadPalette({
    required this.bg,
    required this.card,
    required this.ink,
    required this.soft,
    required this.rule,
    required this.accent,
  });
  final Color bg, card, ink, soft, rule, accent;

  static const light = _ReadPalette(
    bg: ttcBg,
    card: ttcPanel,
    ink: ttcInk,
    soft: ttcSoft,
    rule: ttcLine,
    accent: ttcPurple,
  );

  static const sepia = _ReadPalette(
    bg: Color(0xFFF6EFE3),
    card: Color(0xFFEDE2D0),
    ink: Color(0xFF3B3227),
    soft: Color(0xFF6E6152),
    rule: Color(0xFFDFD2BE),
    accent: Color(0xFF8A5A2B),
  );

  static const dark = _ReadPalette(
    bg: Color(0xFF17141B),
    card: Color(0xFF231E2B),
    ink: Color(0xFFEDE8F2),
    soft: Color(0xFFA79FB4),
    rule: Color(0xFF332C3D),
    accent: Color(0xFFC0A2EA),
  );

  static _ReadPalette of(TtcReadMode m) => switch (m) {
        TtcReadMode.light => light,
        TtcReadMode.sepia => sepia,
        TtcReadMode.dark => dark,
      };
}

/// The enum lives here, so its labels are mapped here too - `ttc_strings.dart`
/// imports nothing from `screens/` on purpose.
String _modeName(TtcS t, TtcReadMode m) => switch (m) {
      TtcReadMode.light => t.readModeLight,
      TtcReadMode.sepia => t.readModeSepia,
      TtcReadMode.dark => t.readModeDark,
    };

class TtcInsightScreen extends StatefulWidget {
  const TtcInsightScreen({super.key, required this.insight});

  final TtcInsight insight;

  @override
  State<TtcInsightScreen> createState() => _TtcInsightScreenState();
}

class _TtcInsightScreenState extends State<TtcInsightScreen> {
  final _scroll = ScrollController();

  // Held in the widget, not a store: a reading preference is about this
  // session's light, not a fact about her. Persisting it is a later decision,
  // not an oversight.
  TtcReadMode _mode = TtcReadMode.light;
  double _scale = 1.0;
  double _progress = 0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // Resume where she stopped, after the first layout so the extent is known.
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _restore() {
    if (!_scroll.hasClients) return;
    final p = TtcReadStore.instance.progressOf(widget.insight.id);
    // Only resume something meaningfully begun and not finished. Jumping her to
    // 4% is worse than doing nothing, and jumping to the end of a piece she
    // completed is just confusing.
    if (p <= 0.05 || p >= 0.95) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    _scroll.jumpTo(max * p);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    // A piece shorter than the screen is read the moment it is opened. Calling
    // that 0% would mean her shortest insights never counted as read.
    final p = max <= 0 ? 1.0 : (_scroll.offset / max).clamp(0.0, 1.0);
    TtcReadStore.instance.setProgress(widget.insight.id, p);
    if ((p - _progress).abs() > 0.005) setState(() => _progress = p);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLang.instance, TtcReadStore.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final p = _ReadPalette.of(_mode);
        final insight = widget.insight;
        final paragraphs = insight.body(hi).split('\n\n');
        final saved = TtcReadStore.instance.isSaved(insight.id);

        return Scaffold(
          backgroundColor: p.bg,
          body: SafeArea(
            child: Column(children: [
              _TopBar(
                p: p,
                saved: saved,
                onBack: () => Navigator.of(context).maybePop(),
                onSave: () =>
                    TtcReadStore.instance.toggleSaved(insight.id),
                onSettings: () => _openSettings(t, p),
              ),
              // How much is left, without a number. A "40%" on a health article
              // invites her to decide whether it is worth finishing.
              SizedBox(
                height: 2,
                child: Stack(children: [
                  Container(color: p.rule),
                  FractionallySizedBox(
                    widthFactor: _progress.clamp(0.0, 1.0),
                    child: Container(color: p.accent),
                  ),
                ]),
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(
                      ttcGutter, 20, ttcGutter, ttcBottomInset),
                  children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: p.card,
                            borderRadius: BorderRadius.circular(999)),
                        child: Text(ttcTopicLabel(insight.topic, hi),
                            style: ttcBody(11,
                                color: p.accent, w: FontWeight.w800)),
                      ),
                      const SizedBox(width: 9),
                      Text(t.readSeconds(insight.readTime(hi)),
                          style: ttcBody(11.5,
                              color: p.soft, w: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 14),

                    // Fraunces for the headline - this is a reading surface,
                    // one of the few places the display serif belongs.
                    Text(insight.title(hi),
                        style: ttcFraunces(26 * _scale,
                            w: FontWeight.w600, color: p.ink)),
                    const SizedBox(height: 18),

                    for (final para in paragraphs) ...[
                      Text(para,
                          style: ttcBody(15 * _scale, h: 1.72, color: p.ink)),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: p.card,
                        borderRadius: BorderRadius.circular(ttcCardRadius),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ttcEyebrow(
                                hi ? 'Aaj ki ek baat' : "Today's takeaway",
                                color: p.accent),
                            const SizedBox(height: 9),
                            Text(insight.takeaway(hi),
                                style: ttcBody(15 * _scale,
                                    color: p.ink,
                                    w: FontWeight.w700,
                                    h: 1.5)),
                          ]),
                    ),
                    const SizedBox(height: 20),

                    _ReadNext(current: insight, p: p, t: t),
                    const SizedBox(height: 18),

                    // Every clinical surface in this product ends with a
                    // disclaimer. This is not decoration - it is the rule.
                    _Disclaimer(hi: hi, p: p),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }

  Future<void> _openSettings(TtcS t, _ReadPalette p) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSheet) => Container(
          decoration: BoxDecoration(
            color: p.bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: p.rule,
                          borderRadius: BorderRadius.circular(999))),
                ),
                const SizedBox(height: 18),
                Text(t.readSettings,
                    style: ttcJakarta(17).copyWith(color: p.ink)),
                const SizedBox(height: 18),

                Text(t.readTextSize.toUpperCase(),
                    style:
                        ttcBody(9.5, color: p.soft, w: FontWeight.w800)),
                Row(children: [
                  Text('A', style: ttcBody(12, color: p.soft)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: p.accent,
                        thumbColor: p.accent,
                        inactiveTrackColor: p.rule,
                        overlayColor: p.accent.withValues(alpha: 0.12),
                      ),
                      child: Slider(
                        value: _scale,
                        min: 0.9,
                        max: 1.4,
                        divisions: 5,
                        onChanged: (v) {
                          setSheet(() {});
                          setState(() => _scale = v);
                        },
                      ),
                    ),
                  ),
                  Text('A', style: ttcBody(20, color: p.soft)),
                ]),
                const SizedBox(height: 14),

                Text(t.readMode.toUpperCase(),
                    style:
                        ttcBody(9.5, color: p.soft, w: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(children: [
                  for (final m in TtcReadMode.values) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setSheet(() {});
                          setState(() => _mode = m);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _ReadPalette.of(m).bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _mode == m
                                  ? p.accent
                                  : _ReadPalette.of(m).rule,
                              width: _mode == m ? 1.8 : 1,
                            ),
                          ),
                          child: Text(_modeName(t, m),
                              style: ttcBody(12.5,
                                  color: _ReadPalette.of(m).ink,
                                  w: FontWeight.w700)),
                        ),
                      ),
                    ),
                    if (m != TtcReadMode.values.last)
                      const SizedBox(width: 10),
                  ],
                ]),
              ]),
        ),
      ),
    );
  }
}

// ---- chrome -----------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.p,
    required this.saved,
    required this.onBack,
    required this.onSave,
    required this.onSettings,
  });

  final _ReadPalette p;
  final bool saved;
  final VoidCallback onBack, onSave, onSettings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(ttcGutter, 6, ttcGutter, 10),
      child: Row(children: [
        GestureDetector(
          onTap: onBack,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
            child: Icon(Icons.arrow_back_rounded, size: 22, color: p.ink),
          ),
        ),
        const Spacer(),
        _icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            onSave),
        const SizedBox(width: 4),
        _icon(Icons.text_fields_rounded, onSettings),
      ]),
    );
  }

  Widget _icon(IconData i, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(i, size: 21, color: p.ink),
        ),
      );
}

// ---- read next --------------------------------------------------------------

/// What to read after this one.
///
/// The payoff of putting content behind a tap: finishing a piece should lead
/// somewhere rather than dead-ending on a back button. Same topic first,
/// because someone who just read about the fertile window is more interested in
/// fertility than in a random other subject.
class _ReadNext extends StatelessWidget {
  const _ReadNext({required this.current, required this.p, required this.t});

  final TtcInsight current;
  final _ReadPalette p;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final sameTopic = ttcInsights
        .where((i) => i.id != current.id && i.topic == current.topic)
        .toList();
    final others =
        ttcInsights.where((i) => i.id != current.id && i.topic != current.topic);
    final next = [...sameTopic, ...others].take(2).toList();
    if (next.isEmpty) return const SizedBox.shrink();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ttcEyebrow(t.readNext, color: p.soft),
      const SizedBox(height: 12),
      for (final i in next) ...[
        GestureDetector(
          onTap: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => TtcInsightScreen(insight: i),
              settings: const RouteSettings(name: 'ttc/insight'),
            ),
          ),
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(ttcCardRadius),
            ),
            child: Row(children: [
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ttcTopicLabel(i.topic, hi).toUpperCase(),
                          style: ttcBody(9.5,
                              color: p.accent, w: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(i.title(hi),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: ttcBody(14,
                              color: p.ink, w: FontWeight.w700, h: 1.4)),
                      const SizedBox(height: 4),
                      Text(t.readSeconds(i.readTime(hi)),
                          style: ttcBody(11, color: p.soft)),
                    ]),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.soft),
            ]),
          ),
        ),
      ],
    ]);
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer({required this.hi, required this.p});
  final bool hi;
  final _ReadPalette p;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.info_outline_rounded, size: 15, color: p.soft),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          hi
              ? 'Ye jaankari padhne ke liye hai, diagnosis ke liye nahi. Apni sehat ke faisle apne doctor ke saath lein.'
              : 'This is information, never a diagnosis. Decisions about your health belong with your doctor.',
          style: ttcBody(11.5, color: p.soft, h: 1.5),
        ),
      ),
    ]);
  }
}

String ttcTopicLabel(String topic, bool hi) {
  switch (topic) {
    case 'fertility':
      return hi ? 'Fertility' : 'Fertility';
    case 'nutrition':
      return hi ? 'Khaana' : 'Nutrition';
    case 'lifestyle':
      return hi ? 'Lifestyle' : 'Lifestyle';
    case 'male':
      return hi ? 'Male fertility' : 'Male fertility';
    case 'medical':
      return hi ? 'Medical' : 'Medical';
    case 'emotional':
      return hi ? 'Mann' : 'Emotional';
    default:
      return topic;
  }
}
