// =============================================================================
//  PostPregnancyHome — My Child "Today" home (parenting app · screen 1)
// -----------------------------------------------------------------------------
//  The entry screen of the NEW, isolated post-pregnancy (parenting) app,
//  reached from the "Post-Pregnancy" doorway on the mother's home. Faithful
//  build of Claude Design "post pregnancy app.dc.html" · S1 (Direction A —
//  Editorial Calm). Same experience for mother and father.
//
//  Only this screen is built for now; the bottom nav's other tabs (AskVeda ·
//  Community · Products) are placeholders. Nothing here imports pregnancy code
//  — the two products stay fully separate. Scenario: Priya & baby Aarav, 4
//  months, mid Leap 4.
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'explore_drawer.dart';
import 'growth_activity_screen.dart';
import 'health_guide_screen.dart';
import 'journal_screen.dart';
import 'multichild_sheet.dart';
import 'pp_common.dart';
import 'products_discovery_screen.dart';
import 'sleep_better_screen.dart';
import 'snapshot_expanded_screen.dart';
import 'solve_problem_screen.dart';

class PostPregnancyHome extends StatefulWidget {
  const PostPregnancyHome({super.key});

  @override
  State<PostPregnancyHome> createState() => _PostPregnancyHomeState();
}

class _PostPregnancyHomeState extends State<PostPregnancyHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _playDone = false;
  bool _playLiked = false;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  void _openProducts() => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const ProductsDiscoveryScreen()));
  void _openSnapshot() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SnapshotExpandedScreen()));
  void _openSolve() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SolveProblemScreen()));
  void _openGrowth() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const GrowthActivityScreen()));
  void _openJournal() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MyChildJournalScreen()));
  void _openSleepBetter() =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SleepBetterScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ppBg,
      drawer: const ExploreDrawer(),
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 116),
            children: [
              _pad(_greeting()),
              _pad(_gap(22, ppDivider(), 22)),
              _pad(_childHeader()),
              _pad(Padding(padding: const EdgeInsets.only(top: 16), child: _leapChip())),
              _pad(Padding(padding: const EdgeInsets.only(top: 16), child: _leapProgress())),
              _pad(Padding(padding: const EdgeInsets.only(top: 20), child: _growthStats())),
              _pad(_gap(26, ppDivider(), 26)),

              _pad(_snapshot()),
              _pad(_gap(26, ppDivider(), 28)),
              _pad(_challenges()),
              _pad(_gap(28, ppDivider(), 28)),
              _pad(_todaysPlay()),
              const SizedBox(height: 22),
              _pad(_railHeader('More plays for Leap 4', big: false)),
              const SizedBox(height: 13),
              _morePlaysRail(),
              _pad(_gap(26, ppDivider(), 20)),

              _pad(_railHeader('Reads for this week', onSeeAll: () => openPpTab(context, 1))),
              const SizedBox(height: 14),
              _readsRail(),
              _pad(_gap(26, ppDivider(), 20)),

              _pad(_railHeader('Videos for this week', onSeeAll: () => openPpTab(context, 1))),
              const SizedBox(height: 14),
              _videosRail(),
              _pad(_gap(26, ppDivider(), 20)),

              _pad(_railHeader('Products for this week', onSeeAll: _openProducts)),
              const SizedBox(height: 14),
              _productsRail(),
              _pad(_gap(26, ppDivider(), 20)),

              _pad(_commerce()),
              _pad(_gap(26, ppDivider(), 20)),
              _pad(_journalNudge()),
              _pad(_gap(26, ppDivider(), 20)),
              _pad(_comingUpHeader()),
              const SizedBox(height: 14),
              _comingUpRail(),
            ],
          ),
        ),
        // top fade
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: SizedBox(
              height: 40,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ppBg, Color(0x00FBF9FE)],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(left: 16, right: 16, bottom: 18, child: _bottomNav()),
      ]),
    );
  }

  Widget _gap(double top, Widget child, double bottom) =>
      Padding(padding: EdgeInsets.only(top: top, bottom: bottom), child: child);

  // --- greeting --------------------------------------------------------------
  Widget _greeting() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Chrome row: hamburger (→ Explore) · language · avatar.
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          behavior: HitTestBehavior.opaque,
          child: const Icon(Icons.menu_rounded, size: 24, color: ppInk),
        ),
        Row(children: [
          ppLangToggle(),
          const SizedBox(width: 11),
          const PpStriped(height: 36, width: 36, radius: 999, border: true),
        ]),
      ]),
      const SizedBox(height: 18),
      ppEyebrow('Tuesday, 8 July', color: ppSoft, spacing: 0.7),
      const SizedBox(height: 4),
      Text('Good morning, Priya', style: ppJakarta(23)),
    ]);
  }

  // --- child header ----------------------------------------------------------
  Widget _childHeader() {
    return Row(children: [
      const PpStriped(height: 58, width: 58, radius: 999, border: true),
      const SizedBox(width: 15),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GestureDetector(
            onTap: () => showMultiChildSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('Aarav', style: ppJakarta(21)),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                child: const Text('▾', style: TextStyle(color: ppPurple, fontSize: 11)),
              ),
            ]),
          ),
          const SizedBox(height: 1),
          Text('4 months 1 week · Born 8 Mar', style: ppBody(13)),
        ]),
      ),
      const SizedBox(width: 10),
      // Health pill → Customised Health Guide (S17).
      GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const HealthGuideScreen())),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.monitor_heart_outlined, size: 15, color: Colors.white),
            const SizedBox(width: 6),
            Text('Health', style: ppBody(12, color: Colors.white, w: FontWeight.w700)),
          ]),
        ),
      ),
    ]);
  }

  Widget _leapChip() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Flexible(
            child: Text('Leap 4 · The World of Events',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  Widget _leapProgress() {
    return Row(children: [
      const Icon(Icons.cloud_rounded, size: 15, color: ppMuted),
      const SizedBox(width: 10),
      Expanded(
        child: SizedBox(
          height: 11,
          child: Stack(alignment: Alignment.centerLeft, children: [
            Container(height: 4, decoration: BoxDecoration(color: const Color(0xFFECE5F2), borderRadius: BorderRadius.circular(999))),
            FractionallySizedBox(
              widthFactor: 0.46,
              child: Container(height: 4, decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999))),
            ),
            Align(
              alignment: const Alignment(2 * 0.46 - 1, 0),
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                    color: ppBg, shape: BoxShape.circle, border: Border.all(color: ppPurple, width: 2)),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(width: 10),
      const Icon(Icons.wb_sunny_rounded, size: 15, color: ppCoral),
      const SizedBox(width: 6),
      Text('Day 12', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
    ]);
  }

  Widget _growthStats() {
    Widget col(String label, String value, String unit, String centile) => Expanded(
          child: Column(children: [
            ppEyebrow(label, color: ppMuted, spacing: 0.5),
            const SizedBox(height: 4),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: value, style: ppJakarta(17)),
                TextSpan(text: ' $unit', style: ppBody(12, color: ppSoft, w: FontWeight.w600)),
              ]),
            ),
            const SizedBox(height: 1),
            Text(centile, style: ppBody(10, color: ppMuted)),
          ]),
        );
    Widget vdiv() => Container(width: 1, height: 38, color: ppPanelDiv);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        col('Weight', '6.4', 'kg', '50th centile'),
        vdiv(),
        col('Height', '63', 'cm', '48th centile'),
        vdiv(),
        col('Head', '41', 'cm', '52nd centile'),
      ]),
    );
  }

  // --- snapshot --------------------------------------------------------------
  Widget _snapshot() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ppEyebrow('Snapshot of today'),
      const SizedBox(height: 12),
      Text("Aarav's world is getting bigger.", style: ppFraunces(38, h: 1.12)),
      const SizedBox(height: 20),
      GestureDetector(
        onTap: _openSnapshot,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            const PpStriped(height: 200, radius: 22, border: true),
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('2 min', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                ]),
              ),
            ),
            const Positioned.fill(child: Center(child: _PlayCircle(52))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x802F2C30)]),
                ),
                child: Text('Watch: Aarav this month — a guide to Leap 4',
                    style: ppBody(12, color: Colors.white, w: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 18),
      Text.rich(
        TextSpan(children: [
          TextSpan(text: "He's deep in ", style: ppBody(15)),
          TextSpan(text: 'Leap 4', style: ppBody(15, color: ppInk, w: FontWeight.w600)),
          TextSpan(
              text:
                  " — the leap where babies work out that actions flow in smooth sequences. Watch him track your hands, reach with intent, and roll toward what he wants. His brain is doing heavy lifting, so he's clingier and his sleep feels upside-down. It passes — and he comes out more capable.",
              style: ppBody(15)),
        ]),
      ),
      const SizedBox(height: 26),
      // milestones peek
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(child: ppEyebrow('Where he is right now', color: ppSoft, spacing: 1.2)),
        const SizedBox(width: 10),
        GestureDetector(onTap: _openSnapshot, child: ppSeeAll()),
      ]),
      const SizedBox(height: 4),
      _milestone('Motor', 'Swiping at toys, pushing up — a first roll is close.', top: true),
      _milestone('Cognitive', 'Following your hand to the toy — cause & effect.', top: true),
      _milestone('Social', 'Beaming across the room; a laugh earns a laugh.', top: true),
      _milestone('Language', "'Aah-goo', raspberries, squeals — rehearsing talk.", top: true, bottom: true),
    ]);
  }

  Widget _milestone(String label, String desc, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 74, child: Text(label, style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
          const SizedBox(width: 12),
          Expanded(child: Text(desc, style: ppBody(13, h: 1.45))),
        ]),
      );

  // --- challenges ------------------------------------------------------------
  Widget _challenges() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        ppEyebrow('In Leap 4'),
        const SizedBox(width: 9),
        Expanded(child: Container(height: 1, color: ppHair)),
      ]),
      const SizedBox(height: 6),
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Flexible(
            child: Text('Challenges to watch',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: ppJakarta(24))),
        const SizedBox(width: 10),
        Text('4', style: ppBody(13, color: ppMuted, w: FontWeight.w600)),
      ]),
      const SizedBox(height: 10),
      Text(
          'Every baby rides Leap 4 differently. These are the ones parents of 4-month-olds run into most — tap any to see what helps.',
          style: ppBody(14)),
      const SizedBox(height: 18),
      _challenge('The 4-month sleep regression', 'Sleep cycles are maturing — bedtime feels upside-down.',
          now: true, top: true),
      _challenge('Clinginess & extra fussiness', 'The stormy stretch of the leap — he wants you, constantly.',
          top: true),
      _challenge('Distracted feeding', 'Pulling off mid-feed to look around at his new world.', top: true),
      _challenge('Drooling & hands-in-mouth', 'Everything goes to his mouth — usually not teething yet.',
          top: true, bottom: true),
    ]);
  }

  Widget _challenge(String title, String desc, {bool now = false, bool top = false, bool bottom = false}) =>
      GestureDetector(
        onTap: _openSolve,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(title, style: ppJakarta(16))),
                  if (now) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
                      child: Text('Now', style: ppBody(10, color: ppCoral, w: FontWeight.w700)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(desc, style: ppBody(13, h: 1.5)),
              ]),
            ),
            const SizedBox(width: 14),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );

  // --- today's play ----------------------------------------------------------
  Widget _todaysPlay() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
        Flexible(child: ppEyebrow("Today's play", color: ppSoft, spacing: 1.2)),
        const SizedBox(width: 8),
        Text('· 5 min', style: ppBody(11, color: ppMuted)),
      ]),
      const SizedBox(height: 10),
      Text('Peekaboo, slow and silly', style: ppJakarta(21)),
      const SizedBox(height: 9),
      Text(
          'Leap 4 is about cause and effect — hiding your face and reappearing plants the very first seed of object permanence.',
          style: ppBody(14)),
      const SizedBox(height: 14),
      GestureDetector(
        onTap: _openGrowth,
        child: Text('How to play & why it works →',
            style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
      ),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _playDone = !_playDone),
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _playDone ? ppPanel : ppPurple,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ppPurple),
              ),
              child: Text(_playDone ? 'Done ✓' : 'Mark as done',
                  style: ppBody(15, color: _playDone ? ppPurple : Colors.white, w: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => setState(() => _playLiked = !_playLiked),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ppLine),
            ),
            child: Text(_playLiked ? '♥' : '♡',
                style: TextStyle(color: _playLiked ? ppCoral : ppMuted, fontSize: 20)),
          ),
        ),
      ]),
    ]);
  }

  // --- rails -----------------------------------------------------------------
  Widget _railHeader(String title, {bool big = true, VoidCallback? onSeeAll}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Flexible(
              child: Text(title,
                  maxLines: 1, overflow: TextOverflow.ellipsis, style: ppJakarta(big ? 18 : 15))),
          const SizedBox(width: 10),
          GestureDetector(onTap: onSeeAll ?? _soon, child: ppSeeAll()),
        ],
      );

  Widget _rail(double height, List<Widget> cards) => SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: cards.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) => cards[i],
        ),
      );

  Widget _morePlaysRail() {
    Widget card(String title, String meta) => GestureDetector(
          onTap: _openGrowth,
          child: SizedBox(
            width: 150,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PpStriped(height: 100, radius: 16, border: true),
              const SizedBox(height: 10),
              Text(title, style: ppJakarta(14, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(meta, style: ppBody(12, color: ppMuted)),
            ]),
          ),
        );
    return _rail(178, [
      card('Peekaboo, slow and silly', '5 min · Object permanence'),
      card('Reach for the ring', '4 min · Grasp & intent'),
      card('Mirror, mirror on the mat', '3 min · Self & faces'),
      card('Roll-toward-the-toy', '5 min · Rolling practice'),
    ]);
  }

  Widget _readsRail() {
    Widget card(String cat, Color catColor, String title, String read) => GestureDetector(
          onTap: _soon,
          child: SizedBox(
            width: 220,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PpStriped(height: 130, radius: 18, border: true),
              const SizedBox(height: 12),
              ppEyebrow(cat, color: catColor, spacing: 0.6),
              const SizedBox(height: 5),
              Text(title, style: ppJakarta(15, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Text(read, style: ppBody(12, color: ppMuted)),
            ]),
          ),
        );
    return _rail(228, [
      card('Sleep', ppCoral, 'Why baby sleep cycles change at 4 months', '5 min read'),
      card('Play', ppPurple, 'The games that build object permanence', '4 min read'),
      card('Development', ppBrown, 'Leap 4, decoded: what the fussiness means', '6 min read'),
      card('Feeding', ppCoral, 'Distracted feeds: is he getting enough?', '3 min read'),
    ]);
  }

  Widget _videosRail() {
    Widget card(String title, String dur) => GestureDetector(
          onTap: _soon,
          child: SizedBox(
            width: 220,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(children: [
                  const PpStriped(height: 130, radius: 18, border: true),
                  const Positioned.fill(child: Center(child: _PlayCircle(44))),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: ppInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                      child: Text(dur, style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 11),
              Text(title, style: ppJakarta(15, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        );
    return _rail(200, [
      card('The 4-month sleep regression, explained', '3 min'),
      card('Tummy-time games that build rolling', '4 min'),
      card("Reading your baby's tired cues", '2 min'),
    ]);
  }

  Widget _productsRail() {
    Widget card(String title, String price, {bool verified = false}) => GestureDetector(
          onTap: _openProducts,
          child: SizedBox(
            width: 160,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const PpStriped(height: 130, radius: 18, border: true),
              const SizedBox(height: 11),
              Text(title, style: ppJakarta(14, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 5),
              Row(children: [
                Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                if (verified) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                    child: Text('Verified', style: ppBody(10, color: ppPurple, w: FontWeight.w700)),
                  ),
                ],
              ]),
            ]),
          ),
        );
    return _rail(200, [
      card('Dozy white-noise soother', '₹1,499', verified: true),
      card('Blackout curtains', '₹1,299'),
      card('Peekaboo cloth book', '₹399'),
    ]);
  }

  // --- commerce --------------------------------------------------------------
  Widget _commerce() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text("Because Aarav's in the sleep-regression window —",
          style: ppBody(14).copyWith(fontStyle: FontStyle.italic)),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow('Suggested for this stage', color: ppBrown, spacing: 0.8),
          const SizedBox(height: 12),
          Text('Sleep Better: a gentle 2-week plan', style: ppJakarta(20)),
          const SizedBox(height: 9),
          Text(
              'A no-cry-it-out routine built for Indian homes and joint families, made with a paediatric sleep consultant.',
              style: ppBody(14)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '₹699', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: ' · or free with ', style: ppBody(14, color: ppMuted)),
                  TextSpan(text: 'ParentVeda+', style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
                ]),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openSleepBetter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16), border: Border.all(color: ppPurple)),
                child: Text('Take a look', style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Container(height: 1, color: ppPanelDiv),
          const SizedBox(height: 14),
          Text("We only suggest what we'd use for our own kids.", style: ppBody(12, color: ppMuted, h: 1.5)),
        ]),
      ),
    ]);
  }

  // --- journal ---------------------------------------------------------------
  Widget _journalNudge() {
    Widget btn(IconData icon, String label) => Expanded(
          child: GestureDetector(
            onTap: _openJournal,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ppLine)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 16, color: ppPurple),
                const SizedBox(width: 7),
                Text(label, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
              ]),
            ),
          ),
        );
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Flexible(
            child: Text('Capture today',
                maxLines: 1, overflow: TextOverflow.ellipsis, style: ppJakarta(18))),
        const SizedBox(width: 10),
        GestureDetector(onTap: _openJournal, child: ppSeeAll('Journal →')),
      ]),
      const SizedBox(height: 12),
      Text('Aarav rolled halfway across the mat today? Save the moment before it blurs into the next.',
          style: ppBody(14, h: 1.55)),
      const SizedBox(height: 14),
      Row(children: [
        btn(Icons.mic_none_rounded, 'Voice'),
        const SizedBox(width: 10),
        btn(Icons.photo_camera_outlined, 'Photo'),
        const SizedBox(width: 10),
        btn(Icons.edit_outlined, 'Note'),
      ]),
    ]);
  }

  // --- what's coming up ------------------------------------------------------
  Widget _comingUpHeader() => Text("What's coming up", style: ppJakarta(18));

  Widget _comingUpRail() {
    Widget item(String title, String when, {bool active = false}) => SizedBox(
          width: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: active ? ppPurple : ppLine, width: 2)),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Text(title, style: ppJakarta(14, w: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 6),
            Text(when, style: ppBody(12, color: ppMuted)),
          ]),
        );
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: 3,
        separatorBuilder: (_, _) => const SizedBox(width: 24),
        itemBuilder: (_, i) => [
          item('Leap 5 · The World of Relationships', 'in ~6 weeks', active: true),
          item('6-month vaccines', 'in ~7 weeks'),
          item('First solids', 'opens at 6 months'),
        ][i],
      ),
    );
  }

  // --- bottom nav (My Child active) ------------------------------------------
  Widget _bottomNav() {
    Widget tab(String label, bool active, {VoidCallback? onTap}) => GestureDetector(
          onTap: active ? null : (onTap ?? _soon),
          behavior: HitTestBehavior.opaque,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                  color: active ? ppPurple : Colors.transparent, shape: BoxShape.circle),
            ),
            const SizedBox(height: 5),
            Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ppBody(11, color: active ? ppPurple : ppMuted, w: active ? FontWeight.w700 : FontWeight.w600)),
          ]),
        );
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 62,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFEAF4)),
            boxShadow: const [
              BoxShadow(color: Color(0x1E6A30B6), blurRadius: 26, offset: Offset(0, 10)),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(children: [
            Expanded(child: tab('My Child', true)),
            Expanded(child: tab('AskVeda', false, onTap: () => openPpTab(context, 1))),
            Expanded(child: tab('Community', false, onTap: () => openPpTab(context, 2))),
            Expanded(child: tab('Products', false, onTap: () => openPpTab(context, 3))),
          ]),
        ),
      ),
    );
  }
}

class _PlayCircle extends StatelessWidget {
  const _PlayCircle(this.size);
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
      child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
    );
  }
}
