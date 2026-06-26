// =============================================================================
//  Understanding Your Report™  — Tools tab feature
// -----------------------------------------------------------------------------
//  A calm, searchable library that helps a worried mother understand a scan or
//  test finding. Reassurance-first: every article answers "What does this mean?"
//  before anything else, follows the same 7 sections, and ends with a fixed
//  reassurance message + an Ask Veda handoff. No verdicts, no diagnosis, no
//  predictions — just clear, balanced explanations.
//
//  Content: lib/data/report_findings_data.dart (curated seed).
// =============================================================================

import 'package:flutter/material.dart';

import '../data/report_findings_data.dart';
import '../localization/app_language.dart';
import '../models/report_finding.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'tools/ask_veda_screen.dart';

const Color _calm = Color(0xFF18A39B); // teal — calm, non-alarming accent
const Color _reassure = Color(0xFF3FA56A); // soft green — "things to remember"

void _openArticle(BuildContext context, ReportFinding f, PregnancyController c) {
  Navigator.of(context).push(MaterialPageRoute(
    builder: (_) => ReportArticleScreen(finding: f, controller: c),
  ));
}

// ===========================================================================
//  Home
// ===========================================================================

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key, required this.controller});

  final PregnancyController controller;

  Future<void> _search(BuildContext context, AppLanguage lang) async {
    final picked = await showSearch<ReportFinding?>(
      context: context,
      delegate: _ReportSearchDelegate(lang),
    );
    if (picked != null && context.mounted) _openArticle(context, picked, controller);
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    final popular = kReportPopular.map(reportById).whereType<ReportFinding>().toList();
    final all = [...kReportFindings]
      ..sort((a, b) => a.name.of(lang).compareTo(b.name.of(lang)));
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(s.rTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Text(s.rSubtitle,
              style: text.bodyLarge?.copyWith(color: AppTheme.neutral600, height: 1.4)),
          const SizedBox(height: 18),
          _SearchBar(hint: s.rSearchHint, onTap: () => _search(context, lang)),
          const SizedBox(height: 26),
          Text(s.rPopularTitle,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final f in popular) ...[
            _TopicRow(
              finding: f,
              lang: lang,
              onTap: () => _openArticle(context, f, controller),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 18),
          Text(s.rAllTopics,
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          for (final f in all) ...[
            _TopicRow(
              finding: f,
              lang: lang,
              onTap: () => _openArticle(context, f, controller),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.hint, required this.onTap});
  final String hint;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.outlineVariant, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary900.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, color: AppTheme.neutral500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(hint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(color: AppTheme.neutral500)),
          ),
        ]),
      ),
    );
  }
}

/// A topic / search-result row: name + optional alt name + chevron.
class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.finding, required this.lang, required this.onTap});
  final ReportFinding finding;
  final AppLanguage lang;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant, width: 1),
        ),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _calm.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.description_outlined, color: _calm, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(finding.name.of(lang),
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              if (finding.altName != null)
                Text(finding.altName!.of(lang),
                    style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }
}

// ===========================================================================
//  Article (the 7 sections)
// ===========================================================================

class ReportArticleScreen extends StatelessWidget {
  const ReportArticleScreen({super.key, required this.finding, required this.controller});
  final ReportFinding finding;
  final PregnancyController controller;

  void _askVeda(BuildContext context, S s) {
    // Ask Veda is live — open it pre-filled with this finding (it has the data).
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AskVedaScreen(
          controller: controller,
          initialQuery: finding.name.of(controller.language)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final lang = controller.language;
    final s = S(lang);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(title: Text(finding.name.of(lang))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          if (finding.altName != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(finding.altName!.of(lang),
                  style: text.titleMedium?.copyWith(color: AppTheme.neutral500)),
            ),

          // §1 — What does this mean? (always first)
          _Section(title: s.rSecMeans, body: finding.whatItMeans.of(lang)),

          // §2 — How common is it?
          _Section(title: s.rSecCommon, body: finding.howCommon.of(lang)),

          // §3 — What usually happens next? (the most important — gently emphasised)
          _EmphasisSection(title: s.rSecNext, body: finding.whatNext.of(lang)),

          // §4 — When is it usually discussed?
          if (finding.hasWhen) ...[
            const SizedBox(height: 22),
            _SectionTitle(s.rSecWhen),
            const SizedBox(height: 10),
            _WhenChip(
              label: s.rTypicallyAround,
              value: s.rWeekRange(finding.weekFrom, finding.weekTo),
            ),
          ],

          // §5 — Questions to ask your doctor
          if (finding.questions.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle(s.rSecQuestions),
            const SizedBox(height: 12),
            for (final q in finding.questions)
              _QuestionRow(text: q.of(lang)),
          ],

          // §6 — Things to remember
          if (finding.remember.isNotEmpty) ...[
            const SizedBox(height: 24),
            _SectionTitle(s.rSecRemember),
            const SizedBox(height: 12),
            for (final r in finding.remember)
              _RememberRow(text: r.of(lang)),
          ],

          // §7 — Reassurance message (mandatory, fixed)
          const SizedBox(height: 24),
          _ReassuranceCard(text: s.rReassurance),

          // Ask Veda handoff
          const SizedBox(height: 18),
          _AskVedaCard(
            title: s.rAskTitle,
            body: s.rAskBody,
            cta: s.rAskCta,
            onTap: () => _askVeda(context, s),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;
  @override
  Widget build(BuildContext context) => Text(title,
      style: Theme.of(context)
          .textTheme
          .titleLarge
          ?.copyWith(fontWeight: FontWeight.w800));
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _SectionTitle(title),
        const SizedBox(height: 8),
        Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
      ]),
    );
  }
}

class _EmphasisSection extends StatelessWidget {
  const _EmphasisSection({required this.title, required this.body});
  final String title;
  final String body;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: _calm.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _calm.withValues(alpha: 0.25), width: 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.navigation_rounded, size: 18, color: _calm),
            const SizedBox(width: 8),
            Expanded(
              child: Text(title,
                  style: text.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800, color: _calm)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(body, style: text.bodyLarge?.copyWith(height: 1.55)),
        ]),
      ),
    );
  }
}

class _WhenChip extends StatelessWidget {
  const _WhenChip({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Row(children: [
        const Icon(Icons.event_rounded, size: 18, color: AppTheme.neutral500),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: text.bodyMedium?.copyWith(color: AppTheme.neutral600)),
        ),
        Text(value,
            style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
      ]),
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.primary500.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.help_outline_rounded, size: 14, color: AppTheme.primary500),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: t.bodyLarge?.copyWith(height: 1.45)),
        ),
      ]),
    );
  }
}

class _RememberRow extends StatelessWidget {
  const _RememberRow({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_circle_rounded, size: 18, color: _reassure),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: t.bodyLarge?.copyWith(height: 1.45)),
        ),
      ]),
    );
  }
}

class _ReassuranceCard extends StatelessWidget {
  const _ReassuranceCard({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _reassure.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _reassure.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.favorite_rounded, size: 18, color: _reassure),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text,
              style: t.bodyLarge?.copyWith(height: 1.5, color: AppTheme.neutral800)),
        ),
      ]),
    );
  }
}

class _AskVedaCard extends StatelessWidget {
  const _AskVedaCard({
    required this.title,
    required this.body,
    required this.cta,
    required this.onTap,
  });
  final String title;
  final String body;
  final String cta;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary500.withValues(alpha: 0.10),
            AppTheme.secondary500.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outlineVariant, width: 1),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.auto_awesome_rounded, size: 18, color: AppTheme.primary500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title,
                style: text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(body, style: text.bodyMedium?.copyWith(color: AppTheme.neutral600, height: 1.4)),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primary500,
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: onTap,
            icon: const Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
            label: Text(cta, style: text.labelLarge?.copyWith(color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ===========================================================================
//  Search
// ===========================================================================

class _ReportSearchDelegate extends SearchDelegate<ReportFinding?> {
  _ReportSearchDelegate(this.lang);
  final AppLanguage lang;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
              icon: const Icon(Icons.clear_rounded), onPressed: () => query = ''),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final s = S(lang);
    if (query.trim().isEmpty) return const SizedBox.shrink();
    final matches = reportSearch(query);
    if (matches.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(36),
          child: Text(s.canINoResults,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.neutral500)),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      itemCount: matches.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TopicRow(
        finding: matches[i],
        lang: lang,
        onTap: () => close(context, matches[i]),
      ),
    );
  }
}
