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
import 'package:google_fonts/google_fonts.dart';

import '../../data/spiritual_reading_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/spiritual_prefs_store.dart';
import '../../theme/app_theme.dart';

const Color _accent = Color(0xFF9A7BB5);
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
      final ra = store.rank(a.r.title), rb = store.rank(b.r.title);
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.sprTitle),
      ),
      body: AnimatedBuilder(
        animation: SpiritualPrefsStore.instance,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            // Respectful framing - informational, not instruction.
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.favorite_border_rounded,
                    size: 20, color: _accent),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.sprDisclaimer,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          height: 1.45,
                          color: AppTheme.primary700)),
                ),
              ]),
            ),
            const SizedBox(height: 14),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color:
                  selected ? _accent : _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: selected
                      ? _accent
                      : _accent.withValues(alpha: 0.20)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (symbol.isNotEmpty) ...[
                Text(symbol, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : _accent)),
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
          chip(null, hinglish ? 'Sabhi' : 'All', ''),
          for (final t in traditions) chip(t.id, t.name, t.symbol),
        ],
      ),
    );
  }

  Widget _traditionCard(BuildContext context, S s, SpiritualTradition t) {
    final text = Theme.of(context).textTheme;
    // Interest-aware preview (interested reads float to the top).
    final preview = _sortedReads(t).take(_previewCount).toList();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
        ],
      ),
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
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(t.symbol, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.name,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 2),
                  Text(t.blurb,
                      style: GoogleFonts.manrope(
                          fontSize: 12,
                          height: 1.35,
                          color: AppTheme.neutral600)),
                ],
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppTheme.outlineVariant),
        // preview reads
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppTheme.outlineVariant),
          _readRow(context, widget.controller, text, t, preview[i]),
        ],
        const Divider(height: 1, color: AppTheme.outlineVariant),
        // view all
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => _TraditionDetailScreen(
                  controller: widget.controller, tradition: t))),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
            child: Row(children: [
              Text(s.sprViewAll(t.readCount),
                  style: GoogleFonts.manrope(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _accent)),
              const Spacer(),
              const Icon(Icons.arrow_forward_rounded, size: 18, color: _accent),
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
  final interested = store.isInterested(r.title);
  final notInterested = store.isNotInterested(r.title);
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
            const Icon(Icons.not_interested_rounded,
                size: 15, color: AppTheme.neutral400),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(r.title,
                style: text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    decoration:
                        notInterested ? TextDecoration.lineThrough : null)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppTheme.neutral400),
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
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text('${tradition.symbol}  ${tradition.name}',
            style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary900)),
      ),
      body: AnimatedBuilder(
        animation: SpiritualPrefsStore.instance,
        builder: (context, _) {
          final store = SpiritualPrefsStore.instance;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              for (final sec in tradition.sections) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                  child: Text(sec.title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                          color: _accent)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x0F2D144C),
                          blurRadius: 10,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: Builder(builder: (context) {
                    // Sort this section's reads by interest rank.
                    final reads = [...sec.reads]..sort((a, b) {
                        final ra = store.rank(a.title), rb = store.rank(b.title);
                        return ra.compareTo(rb);
                      });
                    return Column(children: [
                      for (var i = 0; i < reads.length; i++) ...[
                        if (i > 0)
                          const Divider(
                              height: 1, color: AppTheme.outlineVariant),
                        _readRow(context, controller, text, tradition, reads[i]),
                      ],
                    ]);
                  }),
                ),
                const SizedBox(height: 6),
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
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text('${tradition.symbol}  ${tradition.name}',
            style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
        children: [
          Text(read.title,
              style: GoogleFonts.fraunces(
                  fontSize: 25,
                  height: 1.2,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary900)),
          const SizedBox(height: 16),
          Text(read.body,
              style: GoogleFonts.manrope(
                  fontSize: 15.5,
                  height: 1.7,
                  color: const Color(0xFF4A4358))),
          const SizedBox(height: 20),
          // Interested / Not-interested preference (persists).
          AnimatedBuilder(
            animation: SpiritualPrefsStore.instance,
            builder: (context, _) {
              final store = SpiritualPrefsStore.instance;
              final interested = store.isInterested(read.title);
              final notInterested = store.isNotInterested(read.title);
              return Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        store.toggleInterested(read.title),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: interested ? Colors.white : _accent,
                      backgroundColor:
                          interested ? _accent : Colors.transparent,
                      side: const BorderSide(color: _accent),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: Icon(
                        interested
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 17),
                    label: Text(hinglish ? 'Pasand' : 'Interested',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        store.toggleNotInterested(read.title),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: notInterested
                          ? Colors.white
                          : AppTheme.neutral600,
                      backgroundColor: notInterested
                          ? AppTheme.neutral500
                          : Colors.transparent,
                      side: const BorderSide(color: AppTheme.neutral400),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    icon: Icon(
                        notInterested
                            ? Icons.not_interested_rounded
                            : Icons.block_outlined,
                        size: 17),
                    label: Text(hinglish ? 'Nahi chahiye' : 'Not interested',
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ]);
            },
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(s.sprFootnote,
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    height: 1.4,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.neutral500)),
          ),
        ],
      ),
    );
  }
}
