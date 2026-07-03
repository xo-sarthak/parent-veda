// =============================================================================
//  SpiritualReadingScreen — a gentle, surface-level reading tool (testing)
// -----------------------------------------------------------------------------
//  A respectful, neutral look at how a few faith traditions approach calm,
//  gratitude, family and motherhood. Framed clearly as comfort & curiosity —
//  NOT religious instruction, and not promoting any belief. Content lives in
//  data/spiritual_reading_data.dart (original reflections, organised by
//  tradition → sub-heading → read). The main screen previews each tradition;
//  "View all" opens the full, sub-heading-grouped list.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/spiritual_reading_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';

const Color _accent = Color(0xFF9A7BB5);
const int _previewCount = 3;

void _openRead(BuildContext context, PregnancyController c,
        SpiritualTradition t, SpiritualRead r) =>
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) =>
            _SpiritualReadScreen(controller: c, tradition: t, read: r)));

class SpiritualReadingScreen extends StatelessWidget {
  const SpiritualReadingScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.sprTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Respectful framing — informational, not instruction.
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.favorite_border_rounded, size: 20, color: _accent),
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
          const SizedBox(height: 18),
          for (final t in kSpiritualTraditions) _traditionCard(context, s, t),
        ],
      ),
    );
  }

  Widget _traditionCard(BuildContext context, S s, SpiritualTradition t) {
    final text = Theme.of(context).textTheme;
    final preview = t.preview(_previewCount);
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
                          fontSize: 12, height: 1.35, color: AppTheme.neutral600)),
                ],
              ),
            ),
          ]),
        ),
        const Divider(height: 1, color: AppTheme.outlineVariant),
        // preview reads
        for (var i = 0; i < preview.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppTheme.outlineVariant),
          _readRow(context, controller, text, t, preview[i]),
        ],
        const Divider(height: 1, color: AppTheme.outlineVariant),
        // view all
        InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  _TraditionDetailScreen(controller: controller, tradition: t))),
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

Widget _readRow(BuildContext context, PregnancyController controller,
        TextTheme text, SpiritualTradition t, SpiritualRead r) =>
    InkWell(
      onTap: () => _openRead(context, controller, t, r),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 13, 14, 13),
        child: Row(children: [
          Expanded(
            child: Text(r.title,
                style: text.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600, height: 1.25)),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded,
              size: 20, color: AppTheme.neutral400),
        ]),
      ),
    );

// ===========================================================================
//  Tradition detail — all readings, grouped by sub-heading
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
      body: ListView(
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
              child: Column(children: [
                for (var i = 0; i < sec.reads.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                  _readRow(context, controller, text, tradition, sec.reads[i]),
                ],
              ]),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

// ===========================================================================
//  Single read
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
          const SizedBox(height: 24),
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
