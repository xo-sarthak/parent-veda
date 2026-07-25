// =============================================================================
//  MemoriesHomeScreen — choose a milestone, and revisit your keepsakes
// -----------------------------------------------------------------------------
//  The calm doorway: two milestones to make a card for, and below, "My
//  Memories" — every card the parent has made, so the feature is a keepsake
//  first and a share second.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../memories/memories_store.dart';
import '../../memories/memory_analytics.dart';
import '../../memories/memory_models.dart';
import '../../memories/memory_templates.dart';
import '../../theme/app_theme.dart';
import 'memory_card.dart';
import 'memory_personalize_screen.dart';
import 'memory_preview_screen.dart';

class MemoriesHomeScreen extends StatefulWidget {
  const MemoriesHomeScreen({super.key});

  @override
  State<MemoriesHomeScreen> createState() => _MemoriesHomeScreenState();
}

class _MemoriesHomeScreenState extends State<MemoriesHomeScreen> {
  @override
  void initState() {
    super.initState();
    MemoriesStore.instance.init();
  }

  void _start(MemoryType type) {
    MemoryAnalytics.started(type.name);
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MemoryPersonalizeScreen(type: type)));
  }

  void _open(SavedMemory m) {
    final t = kMemoryTemplates.firstWhere((t) => t.id == m.templateId,
        orElse: () => templatesFor(m.data.type).first);
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (_) => MemoryPreviewScreen(
            type: m.data.type, data: m.data.copy(), initialTemplateId: t.id)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F2),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _back(context),
            const SizedBox(height: 18),
            Text('MEMORIES',
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                    color: AppTheme.primary500)),
            const SizedBox(height: 8),
            Text('Keepsakes to treasure',
                style: GoogleFonts.fraunces(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A352E),
                    height: 1.1)),
            const SizedBox(height: 6),
            Text('Make a beautiful card for the moments that matter most.',
                style: GoogleFonts.manrope(
                    fontSize: 14, color: const Color(0xFF857D70), height: 1.5)),
            const SizedBox(height: 24),

            _typeCard(MemoryType.expecting, const [Color(0xFFFDF3F5), Color(0xFFF7E2E8)],
                const Color(0xFFDD8496)),
            const SizedBox(height: 14),
            _typeCard(MemoryType.welcomeBaby, const [Color(0xFFEFF5FA), Color(0xFFDCEAF4)],
                const Color(0xFF6FA8CF)),

            const SizedBox(height: 30),
            AnimatedBuilder(
              animation: MemoriesStore.instance,
              builder: (context, _) {
                final items = MemoriesStore.instance.all;
                if (items.isEmpty) return const SizedBox.shrink();
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('MY MEMORIES',
                      style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: const Color(0xFFA99CBB))),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                    children: [
                      for (final m in items) _thumb(m),
                    ],
                  ),
                ]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeCard(MemoryType type, List<Color> bg, Color accent) => GestureDetector(
        onTap: () => _start(type),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight, colors: bg),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  shape: BoxShape.circle),
              child: Text(type.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(type.label,
                    style: GoogleFonts.fraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3A352E))),
                const SizedBox(height: 3),
                Text(type.blurb,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, color: const Color(0xFF857D70))),
              ]),
            ),
            Icon(Icons.arrow_forward_rounded, size: 20, color: accent),
          ]),
        ),
      );

  Widget _thumb(SavedMemory m) {
    final t = kMemoryTemplates.firstWhere((t) => t.id == m.templateId,
        orElse: () => templatesFor(m.data.type).first);
    return GestureDetector(
      onTap: () => _open(m),
      behavior: HitTestBehavior.opaque,
      child: MemoryCardPreview(template: t, data: m.data, maxWidth: 120),
    );
  }

  Widget _back(BuildContext context) => GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF857D70)),
          const SizedBox(width: 6),
          Text('Back',
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF857D70))),
        ]),
      );
}
