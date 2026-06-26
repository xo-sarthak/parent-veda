// =============================================================================
//  ToolsHubScreen — the "Tools" tab (Warm Nest)
// -----------------------------------------------------------------------------
//  The calm toolbox: the Pregnancy Journey map as the hero, then a grid of all
//  the gentle helpers — Baby Movement, Weight, Kegel, Contractions, Hospital
//  Bag, Medication & Supplements, Understanding Your Report, Can I?. Lives in
//  the bottom pill (replacing the Sanskar slot, which moved to Home).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../localization/app_language.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import 'bump_journey_screen.dart';
import 'can_i_screen.dart';
import 'garbh_screen.dart';
import 'journal_screen.dart';
import 'journey_map_screen.dart';
import 'read_next_screen.dart';
import 'reminders_screen.dart';
import 'report_screen.dart';
import 'tools/ask_veda_screen.dart';
import 'tools/baby_movement_screen.dart';
import 'tools/contraction_tracker_screen.dart';
import 'tools/due_date_calculator_screen.dart';
import 'tools/hospital_bag_screen.dart';
import 'tools/kegel_care_screen.dart';
import 'tools/medicine_tracker_screen.dart';
import 'tools/product_checklist_screen.dart';
import 'tools/scans_appointments_screen.dart';
import 'tools/spiritual_reading_screen.dart';
import 'tools/symptom_companion_screen.dart';
import 'tools/weight_tracker_screen.dart';

class ToolsHubScreen extends StatelessWidget {
  const ToolsHubScreen({super.key, required this.controller});
  final PregnancyController controller;

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(controller.language);

    void open(Widget Function() b) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => b()));

    final tools = <_Tool>[
      _Tool(s.garbhToolTitle, Icons.spa_rounded, const Color(0xFFBE9C4E),
          () => open(() => GarbhScreen(controller: controller))),
      _Tool(s.sprToolTitle, Icons.auto_stories_rounded, const Color(0xFF9A7BB5),
          () => open(() => SpiritualReadingScreen(controller: controller))),
      _Tool(s.babyMovementTracker, Icons.favorite_rounded,
          AppTheme.secondary500,
          () => open(() => BabyMovementScreen(controller: controller))),
      _Tool(s.bumpTitle, Icons.pregnant_woman_rounded,
          const Color(0xFFCB6F94),
          () => open(() => BumpJourneyScreen(controller: controller))),
      _Tool(s.jrTitle, Icons.menu_book_rounded, const Color(0xFF8A6BBF),
          () => open(() => JournalScreen(controller: controller))),
      _Tool(s.rnTitle, Icons.local_library_rounded, AppTheme.secondary500,
          () => open(() => ReadNextScreen(controller: controller))),
      _Tool(s.toolWeightTitle, Icons.monitor_weight_rounded,
          AppTheme.tertiary500,
          () => open(() => WeightTrackerScreen(controller: controller))),
      _Tool(s.toolKegelTitle, Icons.self_improvement_rounded,
          AppTheme.secondary400,
          () => open(() => KegelCareScreen(controller: controller))),
      _Tool(s.toolContractionTitle, Icons.timer_rounded, AppTheme.primary400,
          () => open(() => ContractionTrackerScreen(controller: controller))),
      _Tool(s.hbName, Icons.luggage_rounded, AppTheme.tertiary400,
          () => open(() => HospitalBagScreen(controller: controller))),
      _Tool(s.pclTitle, Icons.checklist_rounded, const Color(0xFF3E9A8C),
          () => open(() => ProductChecklistScreen(controller: controller))),
      _Tool(s.medTitle, Icons.medication_rounded, const Color(0xFF4F7A52),
          () => open(() => MedicineTrackerScreen(controller: controller))),
      _Tool(s.rmdTitle, Icons.notifications_active_rounded,
          const Color(0xFFE0921C),
          () => open(() => RemindersScreen(controller: controller))),
      _Tool(s.rTitle, Icons.description_rounded, AppTheme.primary500,
          () => open(() => ReportScreen(controller: controller))),
      _Tool(s.toolCanI, Icons.help_outline_rounded, AppTheme.secondary600,
          () => open(() => CanIScreen(controller: controller))),
      _Tool(s.symToolTitle, Icons.healing_rounded, const Color(0xFF4A7BC8),
          () => open(() => SymptomCompanionScreen(controller: controller))),
      _Tool(s.scnToolTitle, Icons.event_note_rounded, const Color(0xFF2E9C8E),
          () => open(() => ScansAppointmentsScreen(controller: controller))),
      _Tool(s.ddcToolTitle, Icons.calendar_month_rounded, AppTheme.primary500,
          () => open(() => DueDateCalculatorScreen(controller: controller))),
      _Tool(s.vedaToolTitle, Icons.auto_awesome_rounded, AppTheme.primary600,
          () => open(() => AskVedaScreen(controller: controller))),
    ];

    return Container(
      color: AppTheme.surfaceContainer,
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
          children: [
            Text(s.toolsTitle,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
            const SizedBox(height: 4),
            Text(s.toolsIntro,
                style: GoogleFonts.manrope(
                    fontSize: 13, color: AppTheme.neutral600)),
            const SizedBox(height: 18),
            _journeyHero(context, s),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, c) {
              const gap = 12.0;
              final w = (c.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final t in tools)
                    SizedBox(width: w, child: _tile(s, t)),
                ],
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                const Icon(Icons.verified_user_rounded,
                    size: 20, color: AppTheme.primary500),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.toolsSupportNote,
                      style: GoogleFonts.manrope(
                          fontSize: 12,
                          height: 1.4,
                          color: AppTheme.primary700)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _journeyHero(BuildContext context, S s) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => JourneyMapScreen(controller: controller))),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary500, AppTheme.primary700],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x292D144C),
                  blurRadius: 22,
                  offset: Offset(0, 8)),
            ],
          ),
          child: Row(children: [
            Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.map_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.toolJourneyTitle,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(s.toolJourneySubtitle,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          color: Colors.white.withValues(alpha: 0.9))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ]),
        ),
      );

  Widget _tile(S s, _Tool t) => GestureDetector(
        onTap: t.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _soft,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: t.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(t.icon, color: t.color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(t.title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 6),
              Row(children: [
                Text(s.openLabel,
                    style: GoogleFonts.manrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: t.color)),
                const SizedBox(width: 3),
                Icon(Icons.arrow_forward_rounded, size: 13, color: t.color),
              ]),
            ],
          ),
        ),
      );
}

class _Tool {
  const _Tool(this.title, this.icon, this.color, this.onTap);
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}
