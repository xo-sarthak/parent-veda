// =============================================================================
//  SymptomCompanionScreen - "Symptoms Companion"
// -----------------------------------------------------------------------------
//  Calm understanding & reassurance: search, "common around this week", browse
//  by category, a clearly-flagged (non-alarming) urgent section, and a detail
//  page answering how-common / why / what-helps / when-to-call-the-doctor.
//  Logging is optional and can be added to the Journal (→ also the Calendar).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/symptom_data.dart';
import '../../localization/app_language.dart';
import '../../models/symptom.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/symptom_store.dart';
import '../../theme/app_theme.dart';

const List<BoxShadow> _soft = [
  BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
];

String _catLabel(S s, SymptomCategory c) => switch (c) {
      SymptomCategory.digestive => s.symCatDigestive,
      SymptomCategory.physical => s.symCatPhysical,
      SymptomCategory.sleep => s.symCatSleep,
      SymptomCategory.emotional => s.symCatEmotional,
      SymptomCategory.circulation => s.symCatCirculation,
      SymptomCategory.movement => s.symCatMovement,
      SymptomCategory.labour => s.symCatLabour,
      SymptomCategory.urgent => s.symCatUrgent,
    };

int _trimesterOf(int week) => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

class SymptomCompanionScreen extends StatefulWidget {
  const SymptomCompanionScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<SymptomCompanionScreen> createState() =>
      _SymptomCompanionScreenState();
}

class _SymptomCompanionScreenState extends State<SymptomCompanionScreen> {
  String _query = '';
  SymptomCategory? _category;
  final _searchCtrl = TextEditingController();
  PregnancyController get p => widget.controller;

  static const List<SymptomCategory> _browseCats = [
    SymptomCategory.digestive,
    SymptomCategory.physical,
    SymptomCategory.sleep,
    SymptomCategory.emotional,
    SymptomCategory.circulation,
    SymptomCategory.movement,
    SymptomCategory.labour,
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(p.language);
    final lang = p.language;
    final searching = _query.trim().isNotEmpty;
    final week = p.currentWeek;
    final tri = _trimesterOf(week);

    final commonNow = kSymptoms
        .where((x) => !x.urgent && x.commonInTrimester(tri))
        .take(8)
        .toList();
    final urgent = kSymptoms.where((x) => x.urgent).toList();

    final List<Symptom> listed;
    if (searching) {
      listed = kSymptoms.where((x) => x.matchesQuery(_query, lang)).toList();
    } else if (_category != null) {
      listed = kSymptoms.where((x) => x.category == _category).toList();
    } else {
      listed = kSymptoms.where((x) => !x.urgent).toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.symTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          // search
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _soft,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: s.symSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searching
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => setState(() {
                          _query = '';
                          _searchCtrl.clear();
                        }),
                      )
                    : null,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (!searching) ...[
            if (commonNow.isNotEmpty) ...[
              _sectionTitle(s.symCommonNow(week)),
              const SizedBox(height: 10),
              for (final x in commonNow) _symRow(s, lang, x),
              const SizedBox(height: 18),
            ],
            _sectionTitle(s.symBrowse),
            const SizedBox(height: 10),
            _categoryChips(s),
            const SizedBox(height: 18),
            _urgentCard(s, lang, urgent),
            const SizedBox(height: 18),
            _sectionTitle(_category == null ? s.symAll : _catLabel(s, _category!)),
            const SizedBox(height: 10),
          ],

          if (listed.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Center(
                child: Text(s.symNoResults,
                    style: GoogleFonts.manrope(
                        fontSize: 13.5, color: AppTheme.neutral500)),
              ),
            )
          else
            for (final x in listed) _symRow(s, lang, x),

          const SizedBox(height: 16),
          _disclaimer(s),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary900));

  Widget _categoryChips(S s) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final c in _browseCats)
            GestureDetector(
              onTap: () =>
                  setState(() => _category = _category == c ? null : c),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: _category == c ? AppTheme.primary500 : AppTheme.surface,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: _category == c ? null : _soft,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(symptomCatMeta(c).icon,
                      size: 15,
                      color: _category == c
                          ? Colors.white
                          : symptomCatMeta(c).color),
                  const SizedBox(width: 6),
                  Text(_catLabel(s, c),
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _category == c
                              ? Colors.white
                              : AppTheme.neutral700)),
                ]),
              ),
            ),
        ],
      );

  Widget _symRow(S s, AppLanguage lang, Symptom x) {
    final m = symptomCatMeta(x.category);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _SymptomDetail(symptom: x, controller: p))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _soft,
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: m.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(m.icon, size: 19, color: m.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(x.name.of(lang),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                Text(x.commonness.of(lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.manrope(
                        fontSize: 12, color: AppTheme.neutral500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }

  Widget _urgentCard(S s, AppLanguage lang, List<Symptom> urgent) {
    const c = AppTheme.secondary700;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.health_and_safety_rounded, size: 20, color: c),
          const SizedBox(width: 10),
          Text(s.symUrgentTitle,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 15, fontWeight: FontWeight.w700, color: c)),
        ]),
        const SizedBox(height: 6),
        Text(s.symUrgentBody,
            style: GoogleFonts.manrope(
                fontSize: 12.5, height: 1.4, color: AppTheme.neutral700)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final x in urgent)
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        _SymptomDetail(symptom: x, controller: p))),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(99)),
                  child: Text(x.name.of(lang),
                      style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: c)),
                ),
              ),
          ],
        ),
      ]),
    );
  }

  Widget _disclaimer(S s) => Row(children: [
        const Icon(Icons.info_outline_rounded,
            size: 15, color: AppTheme.neutral400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(s.symDisclaimer,
              style: GoogleFonts.manrope(
                  fontSize: 11.5, color: AppTheme.neutral500)),
        ),
      ]);
}

// =============================================================================
//  Symptom detail
// =============================================================================
class _SymptomDetail extends StatelessWidget {
  const _SymptomDetail({required this.symptom, required this.controller});
  final Symptom symptom;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([SymptomStore.instance, controller]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final x = symptom;
    final m = symptomCatMeta(x.category);
    final count = SymptomStore.instance.countThisWeek(x.id);

    Widget section(String label, String body, {Color? color}) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: color ?? m.color)),
            const SizedBox(height: 4),
            Text(body,
                style: GoogleFonts.manrope(
                    fontSize: 14, height: 1.5, color: AppTheme.neutral700)),
          ]),
        );

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(x.name.of(lang),
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(m.icon, size: 22, color: m.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(x.name.of(lang),
                  style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary900)),
            ),
          ]),
          const SizedBox(height: 18),

          if (count >= 2) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: m.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(s.symInsight(x.name.of(lang), count),
                  style: GoogleFonts.manrope(
                      fontSize: 13, height: 1.4, color: AppTheme.primary800)),
            ),
            const SizedBox(height: 16),
          ],

          if (x.commonness.of(lang).trim().isNotEmpty)
            section(s.symHowCommon, x.commonness.of(lang)),
          if (x.why.of(lang).trim().isNotEmpty)
            section(s.symWhy, x.why.of(lang)),

          if (x.tips.isNotEmpty) ...[
            Text(s.symWhatHelps,
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: m.color)),
            const SizedBox(height: 6),
            for (final t in x.tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Container(
                          width: 5,
                          height: 5,
                          decoration:
                              BoxDecoration(color: m.color, shape: BoxShape.circle)),
                    ),
                    Expanded(
                      child: Text(t.of(lang),
                          style: GoogleFonts.manrope(
                              fontSize: 14,
                              height: 1.5,
                              color: AppTheme.neutral700)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],

          // When to contact your doctor (always shown; prominent for urgent).
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (x.urgent ? AppTheme.secondary700 : AppTheme.primary500)
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(
                    x.urgent
                        ? Icons.health_and_safety_rounded
                        : Icons.medical_services_rounded,
                    size: 18,
                    color:
                        x.urgent ? AppTheme.secondary700 : AppTheme.primary600),
                const SizedBox(width: 8),
                Text(s.symWhenDoctor,
                    style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: x.urgent
                            ? AppTheme.secondary700
                            : AppTheme.primary600)),
              ]),
              const SizedBox(height: 6),
              Text(x.doctorGuidance.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 14, height: 1.5, color: AppTheme.neutral800)),
            ]),
          ),

          if (!x.urgent) ...[
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logSheet(context, s, x),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(s.symLog),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _logSheet(BuildContext context, S s, Symptom x) {
    var severity = 'mild';
    var addToJournal = true;
    final notesCtrl = TextEditingController();
    final lang = controller.language;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.neutral300,
                          borderRadius: BorderRadius.circular(99))),
                ),
                const SizedBox(height: 16),
                Text(x.name.of(lang),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                const SizedBox(height: 14),
                Text(s.symSeverity,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.neutral600)),
                const SizedBox(height: 8),
                Row(children: [
                  for (final sev in const ['mild', 'moderate', 'severe'])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setSheet(() => severity = sev),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: severity == sev
                                ? AppTheme.primary500
                                : AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                              sev == 'mild'
                                  ? s.symMild
                                  : sev == 'moderate'
                                      ? s.symModerate
                                      : s.symSevere,
                              style: GoogleFonts.manrope(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: severity == sev
                                      ? Colors.white
                                      : AppTheme.neutral700)),
                        ),
                      ),
                    ),
                ]),
                const SizedBox(height: 14),
                TextField(
                  controller: notesCtrl,
                  minLines: 1,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: s.medNotes,
                    filled: true,
                    fillColor: AppTheme.surfaceContainer,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 6),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: addToJournal,
                  onChanged: (v) => setSheet(() => addToJournal = v),
                  title: Text(s.symAddToJournal,
                      style: GoogleFonts.manrope(
                          fontSize: 13.5, color: AppTheme.primary900)),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () async {
                      await SymptomStore.instance.log(
                        symptomId: x.id,
                        severity: severity,
                        notes: notesCtrl.text.trim(),
                        addToJournal: addToJournal,
                        week: controller.currentWeek,
                        journalTitle: s.symJournalText(x.name.of(lang)),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(s.symLogged(x.name.of(lang)))));
                      }
                    },
                    child: Text(s.saveCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
