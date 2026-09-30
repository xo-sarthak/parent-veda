// =============================================================================
//  SpiritualReadingScreen - a gentle, surface-level reading tool (testing)
// -----------------------------------------------------------------------------
//  A respectful, neutral look at how a few faith traditions approach calm,
//  gratitude, family and motherhood. Framed clearly as comfort & curiosity -
//  NOT religious instruction, and not promoting any belief. Content lives in
//  data/spiritual_reading_data.dart (original reflections, organised by
//  tradition → sub-heading → read).
//
//  The mother BROWSES BY RELIGION (a chip selector across the top: All +
//  Hinduism, Islam, Christianity, Sikhism, Jainism, Buddhism, Others) and can
//  mark each read Interested / Not-interested. Interested reads float up,
//  Not-interested ones are greyed and sink - persisted via SpiritualPrefsStore.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/spiritual_reading_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/spiritual_prefs_store.dart';
import '../../theme/pv_fonts.dart';
import '../pregnancy/preg_chrome.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

// ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle): a white ground, the
// serif page title under a back arrow, white cards with the page hairline
// (no shadows), chips that are white with a hairline until chosen and then
// the one ink, the framing and the footnote as quiet notes on the page
// instead of tinted blocks, and each tradition's groups under the one serif
// section heading. Nothing about what is shown or stored changed.
const Color _accent = kPvInk;
const int _previewCount = 3;

// Preferred browse order (matches the section spec). Any tradition not listed
// still appears, appended after these.
const List<String> _religionOrder = [
  'hindu',
  'islam',
  'christian',
  'sikh',
  'jain',
  'buddhist',
  'others',
];

List<SpiritualTradition> _orderedTraditions() {
  final byId = {for (final t in kSpiritualTraditions) t.id: t};
  final out = <SpiritualTradition>[];
  for (final id in _religionOrder) {
    final t = byId[id];
    if (t != null) out.add(t);
  }
  for (final t in kSpiritualTraditions) {
    if (!_religionOrder.contains(t.id)) out.add(t);
  }
  return out;
}

// All reads of a tradition, flattened and sorted by interest rank
// (interested → neutral → not-interested), stable within each group.
List<SpiritualRead> _sortedReads(SpiritualTradition t) {
  final store = SpiritualPrefsStore.instance;
  final all = <SpiritualRead>[];
  for (final sec in t.sections) {
    all.addAll(sec.reads);
  }
  final indexed = [
    for (var i = 0; i < all.length; i++) (i: i, r: all[i]),
  ]..sort((a, b) {
      // .en everywhere SpiritualPrefsStore is keyed: it persists these
      // strings to SharedPreferences, so a translated key would drop every
      // 'interested' mark the moment she switches language - and bring them
      // back when she switches away. Display uses .now; identity never does.
      final ra = store.rank(a.r.title.en), rb = store.rank(b.r.title.en);
      return ra != rb ? ra.compareTo(rb) : a.i.compareTo(b.i);
    });
  return [for (final e in indexed) e.r];
}

void _openRead(BuildContext context, PregnancyController c,
        SpiritualTradition t, SpiritualRead r) =>
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            _SpiritualReadScreen(controller: c, tradition: t, read: r)));

class SpiritualReadingScreen extends StatefulWidget {
  const SpiritualReadingScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<SpiritualReadingScreen> createState() => _SpiritualReadingScreenState();
}

class _SpiritualReadingScreenState extends State<SpiritualReadingScreen> {
  // null = "All religions".
  String? _religion;

  @override
  Widget build(BuildContext context) {
    final s = S(widget.controller.language);
    final traditions = _orderedTraditions();
    final shown = _religion == null
        ? traditions
        : traditions.where((t) => t.id == _religion).toList();
    final p = pvStorePalette;
    // Kept for revert: AppBar(backgroundColor: AppTheme.surfaceContainer,
    // title: Text(s.sprTitle)) on the grey ground. The title is now the serif
    // page title in the body, and the AppBar carries only the back arrow.
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink1,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: SpiritualPrefsStore.instance,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          children: [
            Semantics(
              header: true,
              child: Text(s.sprTitle, style: pregPageTitleStyle()),
            ),
            const SizedBox(height: 12),
            // Respectful framing - informational, not instruction. A quiet
            // note on the page. Kept for revert: the same Row(Icon(favorite_
            // border), Text(s.sprDisclaimer)) in a Container(padding 15,
            // color: _accent 10%, radius 18).
            PregNote(s.sprDisclaimer, icon: Icons.favorite_border_rounded),
            const SizedBox(height: 16),
            // Browse-by-religion selector.
            _religionSelector(traditions),
            const SizedBox(height: 14),
            for (final t in shown) _traditionCard(context, s, t),
          ],
        ),
      ),
    );
  }

  Widget _religionSelector(List<SpiritualTradition> traditions) {
    final hinglish = widget.controller.language.isHinglish;
    Widget chip(String? id, String label, String symbol) {
      final selected = _religion == id;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: GestureDetector(
          onTap: () => setState(() => _religion = id),
          // The store's chip (`PvChip`): white with the hairline, the one
          // ink once chosen. Its own copy because it carries the symbol.
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? _accent : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: selected ? _accent : kPvLine, width: 1.1),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (symbol.isNotEmpty) ...[
                Text(symbol, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: pvManrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : pvStorePalette.ink2)),
            ]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip(null, hinglish ? 'सभी' : 'All', ''),
          for (final t in traditions) chip(t.id, t.name.now, t.symbol),
        ],
      ),
    );
  }

  Widget _traditionCard(BuildContext context, S s, SpiritualTradition t) {
    final text = Theme.of(context).textTheme;
    // Interest-aware preview (interested reads float to the top).
    final preview = _sortedReads(t).take(_previewCount).toList();
    final p = pvStorePalette;
    // A white card with the hairline (kept for revert: boxShadow
    // Color(0x0F2D144C) blur 12, radius 22).
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPvLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: p.surfaceAlt,
                  borderRadius: BorderRadius.circular(12)),
              child: Text(t.symbol, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name.now,
                      style: pvManrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(t.blurb.now,
                      style: pvManrope(
                          fontSize: 12.5,
                          height: 1.35,
                          color: p.ink3)),
                ],
              ),
            ),
          ]),
        ),
        const Divider(height: 1, thickness: 1, color: kPvLine),
        // preview reads
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine, indent: 16),
          _readRow(context, widget.controller, text, t, preview[i]),
        ],
        const Divider(height: 1, thickness: 1, color: kPvLine),
        // view all
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => _TraditionDetailScreen(
                  controller: widget.controller, tradition: t))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
            child: Row(children: [
              Expanded(
                child: Text(s.sprViewAll(t.readCount),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvManrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink2),
            ]),
          ),
        ),
      ]),
    );
  }
}

// A read row that reflects Interested / Not-interested state (greys + icons)
// and greys out not-interested items.
Widget _readRow(BuildContext context, PregnancyController controller,
    TextTheme text, SpiritualTradition t, SpiritualRead r) {
  final store = SpiritualPrefsStore.instance;
  final interested = store.isInterested(r.title.en);
  final notInterested = store.isNotInterested(r.title.now);
  return InkWell(
    onTap: () => _openRead(context, controller, t, r),
    child: Opacity(
      opacity: notInterested ? 0.45 : 1.0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
        child: Row(children: [
          if (interested) ...[
            const Icon(Icons.favorite_rounded, size: 15, color: _accent),
            const SizedBox(width: 8),
          ] else if (notInterested) ...[
            Icon(Icons.not_interested_rounded,
                size: 15, color: pvStorePalette.ink3),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(r.title.now,
                style: pvManrope(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                    color: pvStorePalette.ink1,
                    decoration:
                        notInterested ? TextDecoration.lineThrough : null)),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded,
              size: 20, color: pvStorePalette.ink3),
        ]),
      ),
    ),
  );
}

// ===========================================================================
//  Tradition detail - all readings, grouped by sub-heading
// ===========================================================================
class _TraditionDetailScreen extends StatelessWidget {
  const _TraditionDetailScreen(
      {required this.controller, required this.tradition});
  final PregnancyController controller;
  final SpiritualTradition tradition;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final p = pvStorePalette;
    // Kept for revert: the tradition's name in the AppBar (pvJakarta 17 /
    // w800) on the grey ground, each group under a small Jakarta label, and
    // each group's card with a soft shadow. Now: a back arrow, the serif page
    // title, the one section heading per group, white hairline cards.
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink1,
        elevation: 0,
      ),
      body: AnimatedBuilder(
        animation: SpiritualPrefsStore.instance,
        builder: (context, _) {
          final store = SpiritualPrefsStore.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            children: [
              Semantics(
                header: true,
                child: Text('${tradition.symbol}  ${tradition.name}',
                    style: pregPageTitleStyle()),
              ),
              for (final sec in tradition.sections) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 26, 0, 12),
                  child: PregSectionHeading(sec.title.now),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: kPvLine),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Builder(builder: (context) {
                    // Sort this section's reads by interest rank.
                    final reads = [...sec.reads]..sort((a, b) {
                        final ra = store.rank(a.title.en), rb = store.rank(b.title.en);
                        return ra.compareTo(rb);
                      });
                    return Column(children: [
                      for (var i = 0; i < reads.length; i++) ...[
                        if (i > 0)
                          const Divider(
                              height: 1, thickness: 1, color: kPvLine, indent: 16),
                        _readRow(context, controller, text, tradition, reads[i]),
                      ],
                    ]);
                  }),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ===========================================================================
//  Single read (with Interested / Not-interested controls)
// ===========================================================================
class _SpiritualReadScreen extends StatelessWidget {
  const _SpiritualReadScreen(
      {required this.controller, required this.tradition, required this.read});
  final PregnancyController controller;
  final SpiritualTradition tradition;
  final SpiritualRead read;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final hinglish = controller.language.isHinglish;
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.ink1,
        elevation: 0,
        title: Text('${tradition.symbol}  ${tradition.name}',
            style: pvManrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: p.ink2)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        children: [
          Text(read.title.now,
              style: pvFraunces(
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: p.ink1)),
          const SizedBox(height: 16),
          Text(read.body.now,
              style: pvManrope(
                  fontSize: 15.5,
                  height: 1.7,
                  color: p.ink1)),
          const SizedBox(height: 20),
          // Interested / Not-interested preference (persists).
          AnimatedBuilder(
            animation: SpiritualPrefsStore.instance,
            builder: (context, _) {
              final store = SpiritualPrefsStore.instance;
              final interested = store.isInterested(read.title.en);
              final notInterested = store.isNotInterested(read.title.now);
              return Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        store.toggleInterested(read.title.en),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: interested ? Colors.white : _accent,
                      backgroundColor:
                          interested ? _accent : Colors.transparent,
                      side: BorderSide(color: interested ? _accent : kPvLine),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: Icon(
                        interested
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17),
                    label: Text(hinglish ? 'पसंद है' : 'Interested',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        store.toggleNotInterested(read.title.now),
                    style: OutlinedButton.styleFrom(
                      // The one ink once chosen, like Interested (was a grey
                      // fill, AppTheme.neutral500).
                      foregroundColor: notInterested ? Colors.white : p.ink2,
                      backgroundColor:
                          notInterested ? _accent : Colors.transparent,
                      side: BorderSide(color: notInterested ? _accent : kPvLine),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: Icon(
                        notInterested
                            ? Icons.not_interested_rounded
                            : Icons.block_outlined,
                        size: 17),
                    label: Text(hinglish ? 'पसंद नहीं' : 'Not interested',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ]);
            },
          ),
          const SizedBox(height: 20),
          // A quiet note on the page, not a grey block. Kept for revert:
          // Container(padding 13, color: AppTheme.surfaceContainer, radius
          // 14, Text(s.sprFootnote, italic 11.5, neutral500)).
          PregNote(s.sprFootnote),
        ],
      ),
    );
  }
}
