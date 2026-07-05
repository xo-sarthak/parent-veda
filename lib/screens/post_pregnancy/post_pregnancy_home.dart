// =============================================================================
//  PostPregnancyHome — My Child "Today" home (parenting app · screen 1 · v2)
// -----------------------------------------------------------------------------
//  The entry screen of the NEW, isolated post-pregnancy (parenting) app,
//  reached from the "Post-Pregnancy" doorway on the mother's home. Faithful
//  build of Claude Design "post pregnancy app.dc.html" · S1 v2 — "rebuilt to
//  spec" (Snapshot / Solve / Grow): child header + leap progress, growth stats,
//  a milestones peek, a counted challenges list, plays/reads/videos/products
//  carousels, a gentle-commerce moment, journal nudge, and What's-coming-up.
//
//  The hamburger (top-right of the greeting) opens the Explore drawer — the only
//  path to the section pages (Recipes, Recommendations, Learn family, Nuskhe,
//  Find help), so it's kept even though the mock doesn't draw it. Nothing here
//  imports pregnancy code — the two products stay fully separate. Scenario:
//  Priya & baby Aarav, 4 months, mid Leap 4.
// =============================================================================

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

  Widget _div({double top = 26, double bottom = 26}) => Padding(
        padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
        child: const SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      );

  // ---- navigation --------------------------------------------------------
  void _push(Widget screen) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  void _openSnapshot() => _push(const SnapshotExpandedScreen());
  void _openSolve() => _push(const SolveProblemScreen());
  void _openGrowth() => _push(const GrowthActivityScreen());
  void _openJournal() => _push(const MyChildJournalScreen());
  void _openSleepBetter() => _push(const SleepBetterScreen());
  void _openHealth() => _push(const HealthGuideScreen());
  void _openProducts() => _push(const ProductsDiscoveryScreen());
  void _openReads() => openPpTab(context, 1); // AskVeda hosts reads/videos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ppBg,
      drawer: const ExploreDrawer(),
      body: Stack(children: [
        ListView(
          padding: const EdgeInsets.only(top: 58, bottom: 116),
          children: [
            _pad(_greeting()),
            _div(top: 22, bottom: 22),
            _pad(_childHeader()),
            const SizedBox(height: 16),
            _pad(_leapPill()),
            const SizedBox(height: 16),
            _pad(_leapProgress()),
            const SizedBox(height: 20),
            _pad(_growthStats()),
            _div(top: 24, bottom: 26),

            // snapshot hero
            _pad(ppEyebrow('Snapshot of today', spacing: 1.6)),
            const SizedBox(height: 12),
            _pad(Text('Aarav’s world is getting bigger.', style: ppFraunces(38, h: 1.12))),
            const SizedBox(height: 20),
            _pad(_snapshotVideo()),
            const SizedBox(height: 18),
            _pad(Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'He’s deep in '),
                TextSpan(text: 'Leap 4', style: ppBody(15, color: ppInk, w: FontWeight.w600)),
                const TextSpan(
                    text:
                        ' — the leap where babies work out that actions flow in smooth sequences. Watch him track your hands, reach with intent, and roll toward what he wants. His brain is doing heavy lifting, so he’s clingier and his sleep feels upside-down. It passes — and he comes out more capable.'),
              ]),
              style: ppBody(15, h: 1.65),
            )),

            // milestones peek
            const SizedBox(height: 26),
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: ppEyebrow('Where he is right now', color: ppSoft, spacing: 1.6)),
              const SizedBox(width: 10),
              GestureDetector(onTap: _openSnapshot, child: ppSeeAll()),
            ])),
            const SizedBox(height: 4),
            _pad(Column(children: [
              _mile('Motor', 'Swiping at toys, pushing up — a first roll is close.', top: true),
              _mile('Cognitive', 'Following your hand to the toy — cause & effect.', top: true),
              _mile('Social', 'Beaming across the room; a laugh earns a laugh.', top: true),
              _mile('Language', '‘Aah-goo’, raspberries, squeals — rehearsing talk.', top: true, bottom: true),
            ])),

            _div(top: 28, bottom: 0),

            // challenges
            _pad(Row(children: [
              ppEyebrow('In Leap 4', spacing: 1.6),
              const SizedBox(width: 9),
              const Expanded(child: SizedBox(height: 1, child: ColoredBox(color: ppHair))),
            ])),
            const SizedBox(height: 10),
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Flexible(child: Text('Challenges to watch', style: ppJakarta(24), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              Text('4', style: ppBody(13, color: ppMuted, w: FontWeight.w600)),
            ])),
            const SizedBox(height: 10),
            _pad(Text(
                'Every baby rides Leap 4 differently. These are the ones parents of 4-month-olds run into most — tap any to see what helps.',
                style: ppBody(14))),
            const SizedBox(height: 18),
            _pad(Column(children: [
              _challenge('The 4-month sleep regression', 'Sleep cycles are maturing — bedtime feels upside-down.',
                  now: true, top: true),
              _challenge('Clinginess & extra fussiness', 'The stormy stretch of the leap — he wants you, constantly.',
                  top: true),
              _challenge('Distracted feeding', 'Pulling off mid-feed to look around at his new world.', top: true),
              _challenge('Drooling & hands-in-mouth', 'Everything goes to his mouth — usually not teething yet.',
                  top: true, bottom: true),
            ])),

            _div(top: 28, bottom: 0),

            // today's play
            _pad(Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
              Flexible(child: ppEyebrow('Today’s play', color: ppSoft, spacing: 1.6)),
              const SizedBox(width: 8),
              Text('· 5 min', style: ppBody(11, color: ppMuted)),
            ])),
            const SizedBox(height: 10),
            _pad(Text('Peekaboo, slow and silly', style: ppJakarta(21))),
            const SizedBox(height: 9),
            _pad(Text(
                'Leap 4 is about cause and effect — hiding your face and reappearing plants the very first seed of object permanence.',
                style: ppBody(14))),
            const SizedBox(height: 14),
            _pad(GestureDetector(
              onTap: _openGrowth,
              child: Text('How to play & why it works →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
            )),
            const SizedBox(height: 16),
            _pad(Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _playDone = !_playDone),
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _playDone ? ppPanel : ppPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(_playDone ? 'Done for today ✓' : 'Mark as done',
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
                    color: _playLiked ? ppCoralTint : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _playLiked ? ppCoralTint : ppLine),
                  ),
                  child: Icon(_playLiked ? Icons.favorite : Icons.favorite_border,
                      size: 22, color: _playLiked ? ppCoral : ppMuted),
                ),
              ),
            ])),

            // more plays
            const SizedBox(height: 22),
            _pad(Row(children: [
              Expanded(child: Text('More plays for Leap 4', style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              GestureDetector(onTap: _openGrowth, child: ppSeeAll()),
            ])),
            const SizedBox(height: 13),
            _rail(174, [
              _playCard('Peekaboo, slow and silly', '5 min · Object permanence'),
              _playCard('Reach for the ring', '4 min · Grasp & intent'),
              _playCard('Mirror, mirror on the mat', '3 min · Self & faces'),
              _playCard('Roll-toward-the-toy', '5 min · Rolling practice'),
            ]),

            _div(top: 26, bottom: 20),

            // reads
            _pad(Row(children: [
              Expanded(child: Text('Reads for this week', style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              GestureDetector(onTap: _openReads, child: ppSeeAll()),
            ])),
            const SizedBox(height: 14),
            _rail(238, [
              _readCard('Sleep', ppCoral, 'Why baby sleep cycles change at 4 months', '5 min read'),
              _readCard('Play', ppPurple, 'The games that build object permanence', '4 min read'),
              _readCard('Development', ppBrown, 'Leap 4, decoded: what the fussiness means', '6 min read'),
              _readCard('Feeding', ppCoral, 'Distracted feeds: is he getting enough?', '3 min read'),
            ]),

            _div(top: 26, bottom: 20),

            // videos
            _pad(Row(children: [
              Expanded(child: Text('Videos for this week', style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              GestureDetector(onTap: _openReads, child: ppSeeAll()),
            ])),
            const SizedBox(height: 14),
            _rail(190, [
              _videoCard('The 4-month sleep regression, explained', '3 min'),
              _videoCard('Tummy-time games that build rolling', '4 min'),
              _videoCard("Reading your baby's tired cues", '2 min'),
            ]),

            _div(top: 26, bottom: 20),

            // products
            _pad(Row(children: [
              Expanded(child: Text('Products for this week', style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              GestureDetector(onTap: _openProducts, child: ppSeeAll()),
            ])),
            const SizedBox(height: 14),
            _rail(196, [
              _productCard('Dozy white-noise soother', '₹1,499', verified: true),
              _productCard('Blackout curtains', '₹1,299'),
              _productCard('Peekaboo cloth book', '₹399'),
            ]),

            _div(top: 26, bottom: 20),

            // gentle commerce
            _pad(Text('Because Aarav’s in the sleep-regression window —',
                style: ppBody(14).copyWith(fontStyle: FontStyle.italic))),
            const SizedBox(height: 14),
            _pad(_gentleCommerce()),

            _div(top: 26, bottom: 20),

            // journal nudge
            _pad(Row(children: [
              Expanded(child: Text('Capture today', style: ppJakarta(18), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 10),
              GestureDetector(onTap: _openJournal, child: ppSeeAll('Journal →')),
            ])),
            const SizedBox(height: 12),
            _pad(Text('Aarav rolled halfway across the mat today? Save the moment before it blurs into the next.',
                style: ppBody(14))),
            const SizedBox(height: 14),
            _pad(Row(children: [
              _journalBtn(Icons.mic_none_rounded, 'Voice'),
              const SizedBox(width: 10),
              _journalBtn(Icons.photo_camera_outlined, 'Photo'),
              const SizedBox(width: 10),
              _journalBtn(Icons.edit_outlined, 'Note'),
            ])),

            _div(top: 26, bottom: 20),

            // what's coming up
            _pad(Text('What’s coming up', style: ppJakarta(18))),
            const SizedBox(height: 14),
            _rail(88, [
              _comingCard('Leap 5 · The World of Relationships', 'in ~6 weeks', active: true),
              _comingCard('6-month vaccines', 'in ~7 weeks'),
              _comingCard('First solids', 'opens at 6 months'),
            ], width: 150, gap: 24),
          ],
        ),

        // top fade
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: 48,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [ppBg, Color(0x00FBF9FE)],
                ),
              ),
            ),
          ),
        ),

        // bottom nav
        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 0)),
      ]),
    );
  }

  // ---- greeting ----------------------------------------------------------
  Widget _greeting() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow('Tuesday, 8 July', color: ppSoft, spacing: 0.8),
          const SizedBox(height: 4),
          Text('Good morning, Priya', style: ppJakarta(23)),
        ]),
      ),
      const SizedBox(width: 12),
      Row(children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          behavior: HitTestBehavior.opaque,
          child: const Icon(Icons.menu_rounded, size: 22, color: ppInk),
        ),
        const SizedBox(width: 12),
        ppLangToggle(),
        const SizedBox(width: 11),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
          clipBehavior: Clip.antiAlias,
          child: const PpStriped(height: 40),
        ),
      ]),
    ]);
  }

  // ---- child header ------------------------------------------------------
  Widget _childHeader() {
    return Row(children: [
      Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
        clipBehavior: Clip.antiAlias,
        child: const PpStriped(height: 64),
      ),
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
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 15, color: ppPurple),
              ),
            ]),
          ),
          const SizedBox(height: 1),
          Text('4 months 1 week · Born 8 Mar', style: ppBody(13)),
        ]),
      ),
      const SizedBox(width: 10),
      GestureDetector(
        onTap: _openHealth,
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

  Widget _leapPill() => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(999)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Flexible(
                child: Text('Leap 4 · The World of Events',
                    style: ppBody(12, color: ppCoral, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
        ),
      );

  Widget _leapProgress() => Row(children: [
        const Icon(Icons.cloud_rounded, size: 15, color: ppMuted),
        const SizedBox(width: 10),
        Expanded(
          child: LayoutBuilder(builder: (context, c) {
            final w = c.maxWidth;
            const f = 0.46;
            return SizedBox(
              height: 11,
              child: Stack(clipBehavior: Clip.none, children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 3.5,
                  child: Container(
                      height: 4, decoration: BoxDecoration(color: const Color(0xFFECE5F2), borderRadius: BorderRadius.circular(999))),
                ),
                Positioned(
                  left: 0,
                  top: 3.5,
                  child: Container(
                      width: w * f,
                      height: 4,
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999))),
                ),
                Positioned(
                  left: w * f - 5.5,
                  top: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                        color: ppBg, shape: BoxShape.circle, border: Border.all(color: ppPurple, width: 2)),
                  ),
                ),
              ]),
            );
          }),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.wb_sunny_rounded, size: 15, color: ppCoral),
        const SizedBox(width: 8),
        Text('Day 12', style: ppBody(11, color: ppPurple, w: FontWeight.w700)),
      ]);

  // ---- growth stats ------------------------------------------------------
  Widget _growthStats() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          _stat('Weight', '6.4', 'kg', '50th centile'),
          _statDivider(),
          _stat('Height', '63', 'cm', '48th centile'),
          _statDivider(),
          _stat('Head', '41', 'cm', '52nd centile'),
        ]),
      );

  Widget _stat(String label, String value, String unit, String centile) => Expanded(
        child: Column(children: [
          Text(label.toUpperCase(),
              style: ppBody(10, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.4)),
          const SizedBox(height: 4),
          Text.rich(TextSpan(children: [
            TextSpan(text: value, style: ppJakarta(17)),
            TextSpan(text: ' $unit', style: ppBody(12, color: ppSoft, w: FontWeight.w600)),
          ])),
          const SizedBox(height: 1),
          Text(centile, style: ppBody(10, color: ppMuted)),
        ]),
      );

  Widget _statDivider() => Container(width: 1, height: 38, color: ppPanelDiv);

  // ---- snapshot video ----------------------------------------------------
  Widget _snapshotVideo() => GestureDetector(
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
                decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 5, height: 5, decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text('2 min', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                ]),
              ),
            ),
            const Positioned.fill(child: Center(child: _PlayDisc(52))),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x802F2C30)]),
                ),
                child: Text('Watch: Aarav this month — a guide to Leap 4',
                    style: ppBody(12, color: Colors.white, w: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      );

  // ---- milestones peek ---------------------------------------------------
  Widget _mile(String label, String text, {bool top = false, bool bottom = false}) => GestureDetector(
        onTap: _openSnapshot,
        behavior: HitTestBehavior.opaque,
        child: Container(
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
            Expanded(child: Text(text, style: ppBody(13, h: 1.45))),
          ]),
        ),
      );

  // ---- challenge row -----------------------------------------------------
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
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Flexible(child: Text(title, style: ppJakarta(16), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
            const SizedBox(width: 12),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );

  // ---- rails -------------------------------------------------------------
  Widget _rail(double height, List<Widget> cards, {double gap = 12, double? width}) => SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: cards.length,
          separatorBuilder: (_, _) => SizedBox(width: gap),
          itemBuilder: (_, i) => cards[i],
        ),
      );

  Widget _playCard(String title, String meta) => GestureDetector(
        onTap: _openGrowth,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 150,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 100, radius: 16, border: true),
            const SizedBox(height: 10),
            Text(title, style: ppJakarta(14, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(meta, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _readCard(String category, Color catColor, String title, String meta) => GestureDetector(
        onTap: _openReads,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 220,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 130, radius: 18, border: true),
            const SizedBox(height: 12),
            Text(category.toUpperCase(),
                style: ppBody(11, color: catColor, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
            const SizedBox(height: 5),
            Text(title, style: ppJakarta(15, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(meta, style: ppBody(12, color: ppMuted)),
          ]),
        ),
      );

  Widget _videoCard(String title, String min) => GestureDetector(
        onTap: _openReads,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 220,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Stack(children: [
                const PpStriped(height: 130, radius: 18, border: true),
                const Positioned.fill(child: Center(child: _PlayDisc(44))),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                    child: Text(min, style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 11),
            Text(title, style: ppJakarta(15, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _productCard(String title, String price, {bool verified = false}) => GestureDetector(
        onTap: _openProducts,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 160,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 130, radius: 18, border: true),
            const SizedBox(height: 11),
            Text(title, style: ppJakarta(14, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
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

  Widget _comingCard(String title, String meta, {bool active = false}) => SizedBox(
        width: 150,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: active ? ppPurple : ppLine, width: 2)),
            ),
            child: Text(title, style: ppJakarta(14, w: FontWeight.w600).copyWith(height: 1.3)),
          ),
          const SizedBox(height: 6),
          Text(meta, style: ppBody(12, color: ppMuted)),
        ]),
      );

  // ---- gentle commerce ---------------------------------------------------
  Widget _gentleCommerce() => Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ppEyebrow('Suggested for this stage', color: ppBrown, spacing: 0.9),
          const SizedBox(height: 12),
          Text('Sleep Better: a gentle 2-week plan', style: ppJakarta(20).copyWith(height: 1.2)),
          const SizedBox(height: 9),
          Text('A no-cry-it-out routine built for Indian homes and joint families, made with a paediatric sleep consultant.',
              style: ppBody(14)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(
              child: Text.rich(TextSpan(children: [
                TextSpan(text: '₹699', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                TextSpan(text: ' · or free with ', style: ppBody(14, color: ppMuted)),
                TextSpan(text: 'ParentVeda+', style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
              ])),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _openSleepBetter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: ppPurple)),
                child: Text('Take a look', style: ppBody(14, color: ppPurple, w: FontWeight.w700)),
              ),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: SizedBox(height: 1, child: ColoredBox(color: ppPanelDiv)),
          ),
          Text('We only suggest what we’d use for our own kids.', style: ppBody(12, color: ppMuted, h: 1.5)),
        ]),
      );

  Widget _journalBtn(IconData icon, String label) => Expanded(
        child: GestureDetector(
          onTap: _openJournal,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 16, color: ppPurple),
              const SizedBox(width: 7),
              Text(label, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
      );
}

class _PlayDisc extends StatelessWidget {
  const _PlayDisc(this.size);
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: ppPurple, size: size * 0.5),
      );
}
