// =============================================================================
//  MyChildScreen — the living profile of the child ("Who is my child today?")
// -----------------------------------------------------------------------------
//  The understanding-oriented counterpart to the action-oriented "Today" home.
//  Where Home answers "what does my child need from me today?", this page answers
//  "who is my child today?" — a single, gently-revealed flow (no tabs, no grid,
//  no dashboard) that carries the child's story: Identity, a Snapshot of the five
//  developmental domains, the Development Journey (a story, not a checklist),
//  Growth, a compact Health Snapshot, the Memory Timeline (My Journal), and
//  Looking Ahead — the hub that connects outward to the rest of ParentVeda.
//
//  Built to the "My Child" Claude Design prompt. Reached from the home's Child
//  Snapshot card / "My Child →" link, and from the Explore drawer. Pushed screen
//  (back button, no bottom nav). Scenario: Aarav / 4 months / Leap 4 / Priya.
//  Everything here is hand-authored for the scenario; a real Age/Development/
//  Health/Memory engine would generate it per child. No green — warm palette
//  (ppPurple identity · ppCoral the living "now" · amber anticipation · muted).
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'development_area_screen.dart';
import 'development_map_screen.dart';
import 'food_home_screen.dart';
import 'growth_activity_screen.dart';
// My Child's health rows now open the full Health ecosystem; the old
// HealthGuideScreen import is kept (commented) for easy revert.
// import 'health_guide_screen.dart';
import 'health_growth_screen.dart';
import 'health_home_screen.dart';
import 'health_records_screen.dart';
import 'journal_v2/journal_home_screen.dart';
import 'journal_v2/journal_storybook_screens.dart';
import 'multichild_sheet.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'product_detail_screen.dart';
import 'vaccination_screen.dart';
import 'wonder_week_screen.dart';

// journey / status accents (green-free, warm)
const Color _cNext = Color(0xFFC98A2B); // amber — anticipation

class MyChildScreen extends StatefulWidget {
  const MyChildScreen({super.key});

  @override
  State<MyChildScreen> createState() => _MyChildScreenState();
}

class _MyChildScreenState extends State<MyChildScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _reveal;

  @override
  void initState() {
    super.initState();
    _reveal = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));
  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  // Sections gently appear, staggered.
  Widget _rv(int i, Widget c) {
    final start = (i * 0.07).clamp(0.0, 0.6);
    final a = CurvedAnimation(parent: _reveal, curve: Interval(start, (start + 0.5).clamp(0.0, 1.0), curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: a,
      builder: (context, child) => Opacity(
        opacity: a.value.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, (1 - a.value) * 18), child: child),
      ),
      child: c,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 48),
          children: [
            _pad(ppBack(context, 'My Child')),
            const SizedBox(height: 18),
            _rv(0, _hero()),
            const SizedBox(height: 30),
            _rv(1, _snapshot()),
            const SizedBox(height: 32),
            _rv(2, _journey()),
            const SizedBox(height: 32),
            _rv(3, _growth()),
            const SizedBox(height: 32),
            _rv(4, _health()),
            const SizedBox(height: 32),
            _rv(5, _memories()),
            const SizedBox(height: 32),
            _rv(6, _lookingAhead()),
          ],
        ),
      ),
    );
  }

  // ---- section header -----------------------------------------------------
  Widget _header(String eyebrow, String title, {String? sub}) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow(eyebrow, color: ppPurple, spacing: 1.2),
        const SizedBox(height: 8),
        Text(title, style: ppFraunces(26, h: 1.15)),
        if (sub != null) ...[
          const SizedBox(height: 8),
          Text(sub, style: ppBody(14, h: 1.55)),
        ],
      ]);

  // =========================================================================
  //  1 · Child Identity (hero)
  // =========================================================================
  Widget _hero() => _pad(Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFE6D8F1)]),
          borderRadius: BorderRadius.circular(28),
          boxShadow: ppCardShadow,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(children: [
          Positioned(right: -40, top: -36, child: Container(width: 160, height: 160, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.30)))),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                GestureDetector(
                  onTap: _openDetails,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5), boxShadow: const [BoxShadow(color: Color(0x226A30B6), blurRadius: 14, offset: Offset(0, 6))]),
                    clipBehavior: Clip.antiAlias,
                    child: const PpStriped(height: 80),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.auto_awesome, size: 13, color: ppCoral),
                      const SizedBox(width: 6),
                      Flexible(child: ppEyebrow('Curious Explorer', color: ppCoral, spacing: 1.0)),
                    ]),
                    const SizedBox(height: 8),
                    Text('Aarav', style: ppFraunces(30, h: 1.05)),
                    const SizedBox(height: 3),
                    Text('4 months 1 week · Leap 4', style: ppBody(13, color: ppSoft)),
                  ]),
                ),
              ]),
              const SizedBox(height: 18),
              Text(
                'Aarav is reaching for the world with real intent now, and lighting up at familiar faces — his curiosity and his need to connect grow a little more every week.',
                style: ppFraunces(17, h: 1.45),
              ),
              const SizedBox(height: 20),
              Wrap(spacing: 10, runSpacing: 10, children: [
                _heroBtn('Edit profile', filled: true, onTap: _openDetails),
                _heroBtn('Switch child', filled: false, onTap: () => showMultiChildSheet(context)),
              ]),
            ]),
          ),
        ]),
      ));

  Widget _heroBtn(String label, {required bool filled, required VoidCallback onTap}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: filled ? ppPurple : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(999),
            border: filled ? null : Border.all(color: Colors.white),
          ),
          child: Text(label, style: ppBody(12.5, color: filled ? Colors.white : ppPurple, w: FontWeight.w700)),
        ),
      );

  // =========================================================================
  //  2 · Child Snapshot (five developmental domains — no numbers, no charts)
  // =========================================================================
  Widget _snapshot() {
    final cards = <(IconData, String, String, String, String, VoidCallback)>[
      (Icons.psychology_outlined, 'Brain', 'Cause & effect', 'Following your hand all the way to the toy it reaches for.', 'Developing', () => _push(DevelopmentAreaScreen(area: devAreaById('cognitive')))),
      (Icons.child_care_outlined, 'Physical', 'Rolling & reaching', 'Hands clasp at his chest, he pushes up — a first roll any day.', 'Emerging', () => _push(DevelopmentAreaScreen(area: devAreaById('gross_motor')))),
      (Icons.chat_bubble_outline_rounded, 'Language', 'Musical babble', "Coos stretching into 'aah-goo', raspberries and squeals.", 'Emerging', () => _push(DevelopmentAreaScreen(area: devAreaById('language')))),
      (Icons.favorite_border, 'Emotional', 'Social joy', 'Beams at you across a room; a laugh now earns a laugh back.', 'Blossoming', () => _push(DevelopmentAreaScreen(area: devAreaById('emotional')))),
      (Icons.restaurant_outlined, 'Nutrition', 'Milk is everything', 'Solids open up around 6 months — a few weeks away yet.', 'On track', () => _push(const FoodHomeScreen())),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_header('Child snapshot', 'How Aarav is doing', sub: 'Five windows into his development — where he is right now, not a scorecard. Tap any to go deeper.')),
      const SizedBox(height: 18),
      _pad(Column(children: [
        for (final c in cards) ...[
          _snapCard(c.$1, c.$2, c.$3, c.$4, c.$5, c.$6),
          if (c != cards.last) const SizedBox(height: 12),
        ],
      ])),
    ]);
  }

  Widget _snapCard(IconData icon, String domain, String stage, String insight, String status, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x0F6A30B6), blurRadius: 18, spreadRadius: -14, offset: Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 19, color: ppPurple)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(domain.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                  const SizedBox(height: 2),
                  Text(stage, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              const SizedBox(width: 10),
              _statusPill(status),
            ]),
            const SizedBox(height: 12),
            Text(insight, style: ppBody(13, h: 1.5)),
          ]),
        ),
      );

  Color _statusColor(String s) {
    switch (s) {
      case 'Developing':
      case 'Mastered':
        return ppPurple;
      case 'Blossoming':
      case 'Current focus':
        return ppCoral;
      case 'Emerging':
      case 'Coming next':
        return _cNext;
      default: // On track, Later
        return ppSoft;
    }
  }

  Widget _statusPill(String status) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: c.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
      child: Text(status, style: ppBody(11, color: c, w: FontWeight.w700)),
    );
  }

  // =========================================================================
  //  3 · Development Journey (a story unfolding, not a checklist)
  // =========================================================================
  Widget _journey() {
    // state: 'done' · 'now' · 'next' · 'future'
    final steps = <(String, String, String)>[
      ('Head control', 'Steady and strong, even face-down', 'done'),
      ('First social smile', 'Beams at the faces he loves', 'done'),
      ('Cooing & babble', 'Rehearsing the music of conversation', 'done'),
      ('Hands to midline', 'Clasps them together at his chest', 'done'),
      ('Rolling over', 'He pushes up and rocks — any day now', 'now'),
      ('Sitting with support', 'Propped upright, wobbling but proud', 'next'),
      ('Reaching & grasping', 'Aiming a hand for exactly what he wants', 'next'),
      ('Sitting on his own', 'Hands free to explore', 'future'),
      ('Crawling', 'The whole floor becomes his', 'future'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(_header('Development journey', "Aarav's story so far", sub: 'Every skill builds on the last. This is the path he is walking — behind him, right now, and just ahead.')),
      const SizedBox(height: 20),
      _pad(Column(children: [
        for (int i = 0; i < steps.length; i++) _journeyRow(steps[i].$1, steps[i].$2, steps[i].$3, first: i == 0, last: i == steps.length - 1),
      ])),
      const SizedBox(height: 6),
      _pad(GestureDetector(
        onTap: () => _push(const DevelopmentMapScreen()),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [
          Flexible(child: Text('Understand this stage', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
        ]),
      )),
    ]);
  }

  Widget _journeyRow(String title, String sub, String state, {bool first = false, bool last = false}) {
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // connector + node
        SizedBox(
          width: 32,
          child: Column(children: [
            SizedBox(height: 3, child: first ? null : Container(width: 2, color: ppBorder)),
            _node(state),
            Expanded(child: last ? const SizedBox() : Container(width: 2, color: ppBorder)),
          ]),
        ),
        const SizedBox(width: 14),
        // text
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(title, style: ppJakarta(15, color: state == 'future' ? ppMuted : ppInk), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                _journeyTag(state),
              ]),
              if (sub.isNotEmpty) ...[
                const SizedBox(height: 3),
                Text(sub, style: ppBody(12.5, color: state == 'future' ? ppMuted : ppSoft, h: 1.4)),
              ],
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _node(String state) {
    switch (state) {
      case 'done':
        return Container(width: 26, height: 26, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 14, color: Colors.white));
      case 'now':
        return Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(shape: BoxShape.circle, color: ppCoralTint, border: Border.all(color: ppCoral, width: 2)),
          child: Container(width: 12, height: 12, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
        );
      case 'next':
        return Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: ppPurple, width: 2)), child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)));
      default: // future
        return Container(width: 22, height: 22, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFCFC5DB), width: 1.5)));
    }
  }

  Widget _journeyTag(String state) {
    final (String label, Color c) = switch (state) {
      'done' => ('Mastered', ppPurple),
      'now' => ('Current focus', ppCoral),
      'next' => ('Coming next', _cNext),
      _ => ('Later', ppMuted),
    };
    return Text(label.toUpperCase(), style: ppBody(9, color: c, w: FontWeight.w700).copyWith(letterSpacing: 0.5));
  }

  // =========================================================================
  //  4 · Growth (visual cards, not graphs)
  // =========================================================================
  Widget _growth() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_header('Growth', 'Growing at his own pace')),
        const SizedBox(height: 18),
        _pad(Column(children: [
          Row(children: [
            Expanded(child: _growthCard('Weight', '6.4', 'kg', '50th centile')),
            const SizedBox(width: 12),
            Expanded(child: _growthCard('Height', '63', 'cm', '48th centile')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _growthCard('Head', '41', 'cm', '52nd centile')),
            const SizedBox(width: 12),
            Expanded(child: _growthCard('Trend', 'Steady', '', 'Following his curve')),
          ]),
        ])),
        const SizedBox(height: 16),
        _pad(Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.trending_up_rounded, size: 18, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text('Aarav is growing steadily and following his own healthy curve. Nothing here needs attention.', style: ppBody(13, color: ppInk, h: 1.5))),
          ]),
        )),
        const SizedBox(height: 14),
        _pad(GestureDetector(
          onTap: () => _push(const HealthGrowthScreen()),
          behavior: HitTestBehavior.opaque,
          child: Row(children: [
            Flexible(child: Text('View detailed growth charts', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
          ]),
        )),
      ]);

  Widget _growthCard(String label, String value, String unit, String sub) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(children: [
              TextSpan(text: value, style: ppJakarta(22)),
              if (unit.isNotEmpty) TextSpan(text: ' $unit', style: ppBody(13, color: ppSoft, w: FontWeight.w600)),
            ]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(sub, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      );

  // =========================================================================
  //  5 · Health Snapshot (compact — opens the detailed modules)
  // =========================================================================
  Widget _health() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_header('Health', 'A quick, calm overview')),
        const SizedBox(height: 18),
        _pad(Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            _healthRow(Icons.vaccines_outlined, 'Vaccinations', 'Up to date · next PCV due 22 Jul', () => _push(const VaccinationScreen())),
            // Was: _push(const HealthGuideScreen()) — now opens the Health ecosystem:
            _healthRow(Icons.medical_services_outlined, 'Last doctor visit', '12 Jun · routine check, all well', () => _push(const HealthHomeScreen())),
            _healthRow(Icons.shield_outlined, 'Allergies', 'None recorded yet', () => _push(const HealthRecordsScreen(category: 'allergies')), muted: true),
            _healthRow(Icons.medication_outlined, 'Medications', 'None right now', () => _push(const HealthRecordsScreen(category: 'medications')), muted: true),
            // Was: _push(const HealthGuideScreen()) — now opens the Health ecosystem:
            _healthRow(Icons.timeline_rounded, 'Health timeline', 'Growth, visits & vaccines in one place', () => _push(const HealthHomeScreen()), last: true),
          ]),
        )),
      ]);

  Widget _healthRow(IconData icon, String label, String value, VoidCallback onTap, {bool last = false, bool muted = false}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            Icon(icon, size: 19, color: muted ? ppMuted : ppPurple),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(value, style: ppBody(12, color: muted ? ppMuted : ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Icon(muted ? Icons.add_rounded : Icons.chevron_right_rounded, size: muted ? 17 : 20, color: ppMuted),
          ]),
        ),
      );

  // =========================================================================
  //  6 · Memory Timeline (My Journal)
  // =========================================================================
  Widget _memories() {
    final mems = <(String, String)>[
      ('First real smile', '12 Apr'),
      ('Rolled halfway over', '28 Jun'),
      ('First held a toy', '2 Jul'),
      ('The great bath splash', '4 Jul'),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Expanded(child: _header('Memories', 'Moments worth keeping')),
        GestureDetector(onTap: () => _push(const JournalV2Home()), behavior: HitTestBehavior.opaque, child: ppSeeAll('Open journal →')),
      ])),
      const SizedBox(height: 18),
      SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: mems.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) => _memoryCard(mems[i].$1, mems[i].$2),
        ),
      ),
      const SizedBox(height: 18),
      _pad(GestureDetector(
        onTap: () => _push(const StorybookReaderScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            const Icon(Icons.auto_stories_outlined, size: 19, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text("View Aarav's Storybook", style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      )),
    ]);
  }

  Widget _memoryCard(String title, String date) => GestureDetector(
        onTap: () => _push(const JournalV2Home()),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 108, radius: 16, border: true),
            const SizedBox(height: 10),
            Text(title, style: ppJakarta(13.5).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text(date, style: ppBody(11.5, color: ppMuted)),
          ]),
        ),
      );

  // =========================================================================
  //  7 · Looking Ahead (the hub — connects outward)
  // =========================================================================
  Widget _lookingAhead() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _pad(_header('Looking ahead', "What's coming for Aarav", sub: 'A gentle sense of the road just ahead — and where to explore it.')),
        const SizedBox(height: 18),
        _pad(Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
            _aheadRow(Icons.flag_outlined, 'Next milestone', 'Rolling over — any day now', () => _push(DevelopmentAreaScreen(area: devAreaById('gross_motor')))),
            _aheadRow(Icons.brightness_4_rounded, 'Next leap', 'Leap 5 · The World of Relationships · ~3 weeks', () => _push(const WonderWeekScreen())),
            _aheadRow(Icons.vaccines_outlined, 'Next vaccine', 'PCV dose 3 · 22 Jul', () => _push(const VaccinationScreen())),
            _aheadRow(Icons.extension_outlined, 'Suggested activity', 'Reach for the ring — grasp & intent', () => _push(const GrowthActivityScreen(activity: kActReachRing))),
            _aheadRow(Icons.menu_book_outlined, 'Recommended read', 'The games that build object permanence', () => _push(const ArticleReaderScreen())),
            _aheadRow(Icons.shopping_bag_outlined, 'Recommended product', 'Dozy white-noise soother', () => _push(const ProductDetailScreen()), last: true),
          ]),
        )),
      ]);

  Widget _aheadRow(IconData icon, String label, String value, VoidCallback onTap, {bool last = false}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 18, color: ppPurple)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 2),
                Text(value, style: ppBody(13.5, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );

  // ---- child details / edit sheet ----------------------------------------
  void _openDetails() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 30),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text("Aarav's profile", style: ppJakarta(18)),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(width: 30, height: 30, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle), child: const Icon(Icons.close_rounded, size: 16, color: ppSoft)),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(width: 64, height: 64, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)), clipBehavior: Clip.antiAlias, child: const PpStriped(height: 70)),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _soon,
                        child: Container(width: 24, height: 24, alignment: Alignment.center, decoration: BoxDecoration(color: ppPurple, shape: BoxShape.circle, border: Border.all(color: ppBg, width: 2)), child: const Icon(Icons.edit, size: 11, color: Colors.white)),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Aarav', style: ppJakarta(20)), const SizedBox(height: 2), Text('4 months 1 week', style: ppBody(13))])),
                GestureDetector(onTap: _soon, behavior: HitTestBehavior.opaque, child: Text('Edit', style: ppBody(13, color: ppPurple, w: FontWeight.w700))),
              ]),
              const SizedBox(height: 10),
              _detailRow('Date of birth', '8 March 2026', top: true),
              _detailRow('Sex', 'Boy', top: true),
              _detailRow('Weight', '6.4 kg · 50th', top: true),
              _detailRow('Height', '63 cm · 48th', top: true),
              _detailRow('Head', '41 cm · 52nd', top: true, bottom: true),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none, bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none)),
        child: Row(children: [
          Expanded(child: Text(label, style: ppBody(13, color: ppSoft))),
          const SizedBox(width: 12),
          Text(value, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
        ]),
      );
}
