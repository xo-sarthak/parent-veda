// =============================================================================
//  Tests, Scans & Reports  -  Section 16 (merged feature)
// -----------------------------------------------------------------------------
//  Merges the old "Understanding Your Report" + "Scans & Care" into ONE calm,
//  browsable library. Two sections behind a segmented toggle:
//    1. Tests & Scans          - the common pregnancy tests/scans, each with
//                                What it is / Why / When / Preparation /
//                                Procedure / Understanding Your Report /
//                                Medical Disclaimer.
//    2. Findings & Conditions  - common findings, each with What is it / Why /
//                                Symptoms / Diagnosis / Implications /
//                                Management / When to contact / FAQ / Disclaimer.
//
//  Top filter chips (All / Trimester 1 / 2 / 3 / Any Time) apply to whichever
//  library is showing. Appointments have been REMOVED from this tool - they live
//  in the Calendar (out of scope here). List → detail UX; every detail page ends
//  with a reusable Medical Disclaimer.
//
//  Content: lib/data/tests_scans_reports_data.dart.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/tests_scans_reports_data.dart';
import '../../localization/app_language.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';

const Color _accent = Color(0xFF2E9C8E); // calm teal (matches Scans / Journal)
const List<BoxShadow> _soft = [
  BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
];

// ===========================================================================
//  Home (library)
// ===========================================================================

class TestsScansReportsScreen extends StatefulWidget {
  const TestsScansReportsScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<TestsScansReportsScreen> createState() =>
      _TestsScansReportsScreenState();
}

class _TestsScansReportsScreenState extends State<TestsScansReportsScreen> {
  int _section = 0; // 0 Tests & Scans · 1 Findings & Conditions
  TrimesterTag? _filter; // null = All

  PregnancyController get p => widget.controller;

  @override
  Widget build(BuildContext context) {
    final s = S(p.language);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.tsrTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'A calm library of the tests, scans and findings you may meet in '
            'pregnancy - what each one means, and how to read your report.',
            style: GoogleFonts.manrope(
                fontSize: 13.5, height: 1.5, color: AppTheme.neutral600),
          ),
          const SizedBox(height: 16),
          _sectionToggle(),
          const SizedBox(height: 14),
          _filterChips(),
          const SizedBox(height: 16),
          if (_section == 0) ..._testsList() else ..._findingsList(),
        ],
      ),
    );
  }

  // --- Section toggle --------------------------------------------------------
  Widget _sectionToggle() {
    final tabs = ['Tests & Scans', 'Findings & Conditions'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _soft,
      ),
      child: Row(children: [
        for (int i = 0; i < tabs.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _section = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _section == i ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _section == i
                            ? Colors.white
                            : AppTheme.neutral600)),
              ),
            ),
          ),
      ]),
    );
  }

  // --- Filter chips ----------------------------------------------------------
  Widget _filterChips() {
    final options = <(String, TrimesterTag?)>[
      ('All', null),
      ('Trimester 1', TrimesterTag.t1),
      ('Trimester 2', TrimesterTag.t2),
      ('Trimester 3', TrimesterTag.t3),
      ('Any Time', TrimesterTag.anytime),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (label, tag) = options[i];
          final selected = _filter == tag;
          return GestureDetector(
            onTap: () => setState(() => _filter = tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? _accent : AppTheme.surface,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: selected ? _accent : AppTheme.outlineVariant,
                    width: 1),
              ),
              child: Text(label,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color:
                          selected ? Colors.white : AppTheme.neutral700)),
            ),
          );
        },
      ),
    );
  }

  // --- Lists -----------------------------------------------------------------
  List<Widget> _testsList() {
    final items = testsScansByTag(_filter);
    if (items.isEmpty) return [_empty()];
    return [
      for (final t in items)
        _LibraryCard(
          icon: Icons.biotech_rounded,
          title: t.name,
          subtitle: t.altName,
          badge: t.tag.badge,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  TestScanDetailScreen(info: t, controller: p))),
        ),
    ];
  }

  List<Widget> _findingsList() {
    final items = findingsByTag(_filter);
    if (items.isEmpty) return [_empty()];
    return [
      for (final f in items)
        _LibraryCard(
          icon: Icons.description_outlined,
          title: f.name,
          subtitle: f.altName,
          badge: f.tag.badge,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  FindingDetailScreen(info: f, controller: p))),
        ),
    ];
  }

  Widget _empty() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Center(
          child: Text('Nothing in this filter yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13.5, color: AppTheme.neutral500)),
        ),
      );
}

// A list card for either a test/scan or a finding.
class _LibraryCard extends StatelessWidget {
  const _LibraryCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _soft,
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13)),
            child: Icon(icon, color: _accent, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                  if (subtitle != null && subtitle!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(subtitle!,
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: AppTheme.neutral500)),
                    ),
                  const SizedBox(height: 6),
                  _Badge(badge),
                ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(text,
            style: GoogleFonts.manrope(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: _accent)),
      );
}

// ===========================================================================
//  Test / Scan detail
// ===========================================================================

class TestScanDetailScreen extends StatelessWidget {
  const TestScanDetailScreen(
      {super.key, required this.info, required this.controller});
  final TestScanInfo info;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(info.name,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _DetailHeader(
              icon: Icons.biotech_rounded,
              title: info.name,
              subtitle: info.altName,
              badge: info.tag.badge),
          const SizedBox(height: 16),
          _ExpandableSection(
              title: 'What it is', body: info.whatItIs, initiallyOpen: true),
          _ExpandableSection(title: 'Why it\'s done', body: info.why),
          _ExpandableSection(title: 'When', body: info.when),
          _ExpandableSection(title: 'Preparation', body: info.preparation),
          _ExpandableSection(title: 'Procedure', body: info.procedure),
          _ExpandableSection(
            title: 'Understanding Your Report',
            body: info.understandingReport,
            children: [
              for (final param in info.parameters) _ParameterCard(param),
            ],
          ),
          const SizedBox(height: 4),
          MedicalDisclaimerCard(text: info.disclaimer),
        ],
      ),
    );
  }
}

/// One report parameter, fully explained (measures / why / range / low / high).
class _ParameterCard extends StatelessWidget {
  const _ParameterCard(this.param);
  final ReportParameter param;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(param.name,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: _accent)),
        const SizedBox(height: 8),
        _kv('What it measures', param.measures),
        _kv('Why it\'s important', param.whyImportant),
        if (param.typicalRange != null)
          _kv('Typical pregnancy range', param.typicalRange!),
        if (param.ifLow != null) _kv('If it\'s low', param.ifLow!),
        if (param.ifHigh != null) _kv('If it\'s high', param.ifHigh!),
        if (param.note != null) _kv('Good to know', param.note!),
      ]),
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k,
              style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: AppTheme.neutral500)),
          const SizedBox(height: 2),
          Text(v,
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.5, color: AppTheme.neutral800)),
        ]),
      );
}

// ===========================================================================
//  Finding / Condition detail
// ===========================================================================

class FindingDetailScreen extends StatelessWidget {
  const FindingDetailScreen(
      {super.key, required this.info, required this.controller});
  final FindingInfo info;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(info.name,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _DetailHeader(
              icon: Icons.description_outlined,
              title: info.name,
              subtitle: info.altName,
              badge: info.tag.badge),
          const SizedBox(height: 16),
          _ExpandableSection(
              title: 'What is it?',
              body: info.whatIsIt,
              initiallyOpen: true),
          _ExpandableSection(
              title: 'Why does it happen?', body: info.whyHappens),
          _ExpandableSection(
              title: 'Symptoms', bullets: info.symptoms),
          _ExpandableSection(title: 'Diagnosis', body: info.diagnosis),
          _ExpandableSection(
              title: 'Pregnancy implications', body: info.implications),
          _ExpandableSection(title: 'Management', body: info.management),
          _ExpandableSection(
              title: 'When to contact your doctor',
              bullets: info.whenToContact,
              highlight: true),
          if (info.faqs.isNotEmpty)
            _ExpandableSection(
              title: 'FAQ',
              children: [for (final f in info.faqs) _FaqCard(f)],
            ),
          const SizedBox(height: 4),
          MedicalDisclaimerCard(text: info.disclaimer),
        ],
      ),
    );
  }
}

class _FaqCard extends StatelessWidget {
  const _FaqCard(this.faq);
  final Faq faq;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(faq.q,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary900)),
        const SizedBox(height: 5),
        Text(faq.a,
            style: GoogleFonts.manrope(
                fontSize: 13.5, height: 1.5, color: AppTheme.neutral700)),
      ]),
    );
  }
}

// ===========================================================================
//  Shared building blocks
// ===========================================================================

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });
  final IconData icon;
  final String title;
  final String? subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent.withValues(alpha: 0.14), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: _accent, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary900)),
                if (subtitle != null && subtitle!.trim().isNotEmpty)
                  Text(subtitle!,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5, color: AppTheme.neutral600)),
                const SizedBox(height: 6),
                _Badge(badge),
              ]),
        ),
      ]),
    );
  }
}

/// A collapsible section block. Supports a body paragraph, a bullet list, and/or
/// arbitrary child widgets (used for parameter cards and FAQ cards).
class _ExpandableSection extends StatefulWidget {
  const _ExpandableSection({
    required this.title,
    this.body,
    this.bullets,
    this.children,
    this.initiallyOpen = false,
    this.highlight = false,
  });
  final String title;
  final String? body;
  final List<String>? bullets;
  final List<Widget>? children;
  final bool initiallyOpen;
  final bool highlight; // subtle amber tint (e.g. "when to contact")

  @override
  State<_ExpandableSection> createState() => _ExpandableSectionState();
}

class _ExpandableSectionState extends State<_ExpandableSection> {
  late bool _open = widget.initiallyOpen;

  @override
  Widget build(BuildContext context) {
    final Color tint =
        widget.highlight ? const Color(0xFFB36B12) : _accent;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: widget.highlight ? const Color(0xFFFFF6E9) : AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: widget.highlight
                ? const Color(0x33D9822B)
                : AppTheme.outlineVariant),
      ),
      child: Column(children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(children: [
              if (widget.highlight) ...[
                const Icon(Icons.notifications_active_outlined,
                    size: 18, color: Color(0xFFB36B12)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(widget.title,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: widget.highlight
                            ? const Color(0xFFB36B12)
                            : AppTheme.primary900)),
              ),
              AnimatedRotation(
                turns: _open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(Icons.keyboard_arrow_down_rounded, color: tint),
              ),
            ]),
          ),
        ),
        if (_open)
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.body != null && widget.body!.trim().isNotEmpty)
                    Text(widget.body!,
                        style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            height: 1.55,
                            color: AppTheme.neutral800)),
                  if (widget.bullets != null)
                    for (final b in widget.bullets!)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 6, right: 8),
                                child: Icon(Icons.circle, size: 5, color: tint),
                              ),
                              Expanded(
                                child: Text(b,
                                    style: GoogleFonts.manrope(
                                        fontSize: 13.5,
                                        height: 1.5,
                                        color: AppTheme.neutral800)),
                              ),
                            ]),
                      ),
                  if (widget.children != null) ...widget.children!,
                ]),
          ),
      ]),
    );
  }
}

/// Reusable medical disclaimer - shown on EVERY detail page.
class MedicalDisclaimerCard extends StatelessWidget {
  const MedicalDisclaimerCard({super.key, this.text = kMedicalDisclaimer});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33D9822B)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.health_and_safety_outlined,
            size: 22, color: Color(0xFFB36B12)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Medical disclaimer',
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFB36B12))),
                const SizedBox(height: 4),
                Text(text,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        height: 1.5,
                        color: AppTheme.neutral800)),
              ]),
        ),
      ]),
    );
  }
}
