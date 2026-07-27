// =============================================================================
//  TTC - "Can I...?"
// -----------------------------------------------------------------------------
//  The fastest way to settle an everyday worry. Same shape as the pregnancy
//  version: a verdict, the short answer, why, and the Indian-context line.
//
//  The colour language is deliberately NOT a traffic light. A red "avoid" chip
//  next to papaya would teach a couple to feel afraid of a fruit, and this
//  stage is already carrying more anxiety than it needs. Intensity carries the
//  meaning instead - which also means the verdict survives a greyscale
//  screenshot and a colour-blind eye.
// =============================================================================

import 'package:flutter/material.dart';

import '../../ttc/ttc_can_i_data.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcCanI(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcCanIScreen(),
    settings: const RouteSettings(name: 'ttc/can_i'),
  ));
}

class TtcCanIScreen extends StatefulWidget {
  const TtcCanIScreen({super.key, this.focusId});

  /// An entry to open on, from an Ask Veda pointer (`ttccani_papaya` →
  /// `papaya`). The library still renders whole - deliberately, because the
  /// neighbouring answers are often the ones she actually needed.
  final String? focusId;

  @override
  State<TtcCanIScreen> createState() => _TtcCanIScreenState();
}

class _TtcCanIScreenState extends State<TtcCanIScreen> {
  final _search = TextEditingController();
  final _focusKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.focusId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _focusKey.currentContext;
      if (ctx == null) return;
      Scrollable.ensureVisible(ctx,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
          alignment: 0.1);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: TtcLang.instance,
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final q = _search.text.trim().toLowerCase();
        final results = q.isEmpty
            ? ttcCanI
            : ttcCanI
                .where((e) =>
                    e.question(hi).toLowerCase().contains(q) ||
                    e.short(hi).toLowerCase().contains(q))
                .toList();

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(ttcGutter, 8, ttcGutter, 40),
              children: [
                TtcBackBar(title: t.canITitle),
                const SizedBox(height: 16),
                Text(t.canIIntro, style: ttcBody(13.5, h: 1.6)),
                const SizedBox(height: 16),

                TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: ttcBody(14.5, color: ttcInk),
                  decoration: InputDecoration(
                    hintText: t.canISearch,
                    hintStyle: ttcBody(14, color: ttcMuted),
                    prefixIcon: const Icon(Icons.search_rounded,
                        size: 20, color: ttcMuted),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: ttcBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: ttcBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(999),
                      borderSide: const BorderSide(color: ttcPurple, width: 1.4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                if (results.isEmpty)
                  TtcEmpty(
                    icon: Icons.search_off_rounded,
                    title: t.canINoneTitle,
                    body: t.canINoneBody,
                  )
                else
                  for (final item in results) ...[
                    _CanICard(
                      key: item.id == widget.focusId ? _focusKey : null,
                      item: item,
                      t: t,
                      startOpen: item.id == widget.focusId,
                    ),
                    const SizedBox(height: 11),
                  ],

                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.canIDisclaimer,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CanICard extends StatefulWidget {
  const _CanICard({
    super.key,
    required this.item,
    required this.t,
    this.startOpen = false,
  });

  final TtcCanI item;
  final TtcS t;

  /// True when Ask Veda pointed here - it opens on the reasoning, not the chip.
  final bool startOpen;

  @override
  State<_CanICard> createState() => _CanICardState();
}

class _CanICardState extends State<_CanICard> {
  late bool _open = widget.startOpen;

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final hi = t.hinglish;
    final item = widget.item;

    return TtcCard(
      onTap: () => setState(() => _open = !_open),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(item.question(hi), style: ttcJakarta(15.5))),
          if (item.forPartner) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcCoralTint,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.forPartnerTag,
                  style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
            ),
          ],
        ]),
        const SizedBox(height: 11),

        // The verdict, in the calm colour language - never a traffic light.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: _tint(item.verdict),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(item.verdict.label(hi),
              style: ttcBody(12, color: _ink(item.verdict), w: FontWeight.w800)),
        ),
        const SizedBox(height: 11),

        // The answer in ten seconds, above the fold.
        Text(item.short(hi),
            style: ttcBody(14, color: ttcInk, w: FontWeight.w600, h: 1.55)),

        if (_open) ...[
          const SizedBox(height: 14),
          Text(item.why(hi), style: ttcBody(13.5, h: 1.65)),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFDF6EC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.emoji_objects_outlined,
                  size: 15, color: ttcBrown),
              const SizedBox(width: 9),
              Expanded(
                child: Text(item.indian(hi),
                    style: ttcBody(12.5,
                        color: ttcBrown, h: 1.55, w: FontWeight.w600)),
              ),
            ]),
          ),
        ],

        const SizedBox(height: 11),
        Row(children: [
          Text(_open ? t.testLess : t.testMore,
              style: ttcBody(12.5, color: ttcPurple, w: FontWeight.w800)),
          const SizedBox(width: 5),
          Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
              size: 17, color: ttcPurple),
        ]),
      ]),
    );
  }

  // A single warm family, graded by intensity. No green, no red - a "better
  // not" and a "yes" should differ in weight, not in alarm.
  Color _tint(TtcVerdict v) {
    switch (v) {
      case TtcVerdict.safe:
        return ttcPanel;
      case TtcVerdict.moderate:
        return const Color(0xFFF6ECFA);
      case TtcVerdict.askDoctor:
        return const Color(0xFFFDF6EC);
      case TtcVerdict.avoid:
        return ttcCoralTint;
    }
  }

  Color _ink(TtcVerdict v) {
    switch (v) {
      case TtcVerdict.safe:
        return ttcSoft;
      case TtcVerdict.moderate:
        return ttcPurple;
      case TtcVerdict.askDoctor:
        return ttcBrown;
      case TtcVerdict.avoid:
        return ttcCoral;
    }
  }
}
