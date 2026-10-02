// =============================================================================
//  MemoriesHomeScreen — choose a milestone, and revisit your keepsakes
// -----------------------------------------------------------------------------
//  The calm doorway: two milestones to make a card for, and below, "My
//  Memories" — every card the parent has made, so the feature is a keepsake
//  first and a share second.
//
//  ⚠️ REDRAWN ON THE CURRENT SHELL (2026-10-02, the user: "inside profile ->
//  memories it follows the old UI; use Mobbin for the screen"). It was a cream
//  page (#FBF7F2) with a caps violet label, two gradient cards carrying a
//  decorative emoji, a hand-made "Back" row, and a "My Memories" grid that
//  VANISHED when empty. It is now the shell every tool front page wears
//  (`PregToolScaffold`: the tinted field, a round back, the stage's mark, one
//  serif title, one sentence, a white sheet), and:
//
//    · THE TWO MILESTONES are white rows, the words on the left and a small
//      picture of the card you would make on the right (Mobbin: Starling's
//      "Create new card", https://mobbin.com/screens/a6c35ff1-688a-4070-807e-362256de23f7).
//      A picture of the real template replaces the emoji; the sample words on
//      it are marked as an example.
//    · MY MEMORIES is always there. Empty, it says what will be kept and where
//      (Mobbin: Deliveroo's "You'll see your reward cards here",
//      https://mobbin.com/screens/46a2d38c-1730-4920-93b0-fee1a02ca2da; Photoroom's
//      "No templates yet"), because a feature is never hidden for being empty.
//
//  The old build is kept below as `_buildClassic`, for revert.
// =============================================================================

import 'package:flutter/material.dart';

import '../../memories/memories_store.dart';
import '../../memories/memory_analytics.dart';
import '../../memories/memory_models.dart';
import '../../memories/memory_templates.dart';
import '../../theme/app_theme.dart';
import 'memory_card.dart';
import 'memory_personalize_screen.dart';
import 'memory_preview_screen.dart';
import '../../theme/pv_fonts.dart';
import '../../localization/app_language.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_chrome.dart' show PregSectionHeading;
import '../pregnancy/preg_tool_chrome.dart'
    show PregToolScaffold, pregToolPad;
import '../products/pv_store_chrome.dart' show pvStorePalette;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabArt, TtcTabMark;
import '../v2/v2_palette.dart' show v2BlockTint;

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

  /// "MY MEMORIES" as a sentence-case heading: the existing bilingual string,
  /// lower-cased and capitalised (a no-op in Devanagari).
  String _sentence(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  /// An example for a milestone's row: the first template, with sample words.
  /// Never saved; the row says it is an example.
  (MemoryTemplate, MemoryData)? _sample(MemoryType type) {
    final templates = templatesFor(type);
    if (templates.isEmpty) return null;
    final d = MemoryData(type: type);
    if (type == MemoryType.expecting) {
      d
        ..coupleNames = 'Priya & Arjun'
        ..dueMonth = 'March 2027'
        ..message = 'Our little one is on the way';
    } else {
      d
        ..babyName = 'Aarav'
        ..birthDate = '12 June 2026'
        ..parentNames = 'Priya & Arjun'
        ..message = 'Welcome to the world';
    }
    return (templates.first, d);
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return PregToolScaffold(
      hue: 330, // the Keep group on the Tools list (journal, bump): same colour
      eyebrow: 'Keepsakes',
      title: S.now.memoriesTitle,
      mark: IntentMark.bookMark,
      intro: S.now.uiMakeBeautifulCardMoments,
      children: [
        pregToolPad(const PregSectionHeading('Make a card',
            lead: 'Pick a moment. Add a photo and a few words, then save it or share it.')),
        const SizedBox(height: 14),
        pregToolPad(_typeRow(MemoryType.expecting)),
        const SizedBox(height: 12),
        pregToolPad(_typeRow(MemoryType.welcomeBaby)),
        const SizedBox(height: 30),
        // ⚠️ ALWAYS THERE (2026-10-02). It was `SizedBox.shrink()` when empty,
        // so nobody discovered that cards are kept here until they had made one.
        AnimatedBuilder(
          animation: MemoriesStore.instance,
          builder: (context, _) {
            final items = MemoriesStore.instance.all;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              pregToolPad(PregSectionHeading(_sentence(S.now.uiMyMemories),
                  lead: items.isEmpty
                      ? null
                      : '${items.length} saved on this phone')),
              const SizedBox(height: 14),
              pregToolPad(items.isEmpty
                  ? _emptyKept(p)
                  : GridView.count(
                      key: const ValueKey('memories_grid'),
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                      children: [for (final m in items) _thumb(m)],
                    )),
            ]);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// A milestone: the words on the left, a picture of the card on the right.
  Widget _typeRow(MemoryType type) {
    final p = pvStorePalette;
    final sample = _sample(type);
    return Semantics(
      button: true,
      label: '${type.label}. ${type.blurb}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('memories_type_${type.name}'),
        onTap: () => _start(type),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(type.label,
                    style: pvFraunces(
                        fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
                const SizedBox(height: 4),
                Text(type.blurb,
                    style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2)),
                const SizedBox(height: 12),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Make a card',
                      style: pvManrope(
                          fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: p.ink1),
                ]),
              ]),
            ),
            if (sample != null) ...[
              const SizedBox(width: 14),
              _examplePicture(sample.$1, sample.$2, p.line),
            ],
          ]),
        ),
      ),
    );
  }

  /// The card as it looks, small. Marked as an example so no one thinks it is
  /// one she has made.
  Widget _examplePicture(MemoryTemplate t, MemoryData d, Color line) {
    return Semantics(
      label: 'Example card',
      excludeSemantics: true,
      child: Container(
        key: const ValueKey('memories_example'),
        width: 84,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: line),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: FittedBox(
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          child: MemoryCard(template: t, data: d),
        ),
      ),
    );
  }

  /// What "My memories" says before there is one.
  Widget _emptyKept(dynamic p) {
    final tint = v2BlockTint(330, p);
    return Container(
      key: const ValueKey('memories_empty'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(children: [
        SizedBox(
            width: 52,
            height: 52,
            child: TtcTabArt(mark: TtcTabMark.bigSmallHearts, tint: tint)),
        const SizedBox(height: 14),
        Text('Your cards are kept here',
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
        const SizedBox(height: 6),
        Text(
            'Make one above and it is saved on this phone, ready to open and share again.',
            textAlign: TextAlign.center,
            style: pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
      ]),
    );
  }

  // Kept for revert (2026-10-02): the cream page, the caps label, the gradient
  // cards with the emoji, and a grid that vanished when empty.
  // ignore: unused_element
  Widget _buildClassic(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF7F2),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            _back(context),
            const SizedBox(height: 18),
            Text(S.now.uiMemories2,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.4,
                    color: AppTheme.primary500)),
            const SizedBox(height: 8),
            Text(S.now.uiKeepsakesTreasure,
                style: pvFraunces(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3A352E),
                    height: 1.1)),
            const SizedBox(height: 6),
            Text(S.now.uiMakeBeautifulCardMoments,
                style: pvManrope(
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
                  Text(S.now.uiMyMemories,
                      style: pvManrope(
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
                    style: pvFraunces(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3A352E))),
                const SizedBox(height: 3),
                Text(type.blurb,
                    style: pvManrope(
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
          Text(S.now.uiBack,
              style: pvManrope(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF857D70))),
        ]),
      );
}
