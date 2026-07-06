// =============================================================================
//  PostPregnancyHome — My Child "Today" home (parenting app · screen 1 · v2)
// -----------------------------------------------------------------------------
//  The entry screen of the NEW, isolated post-pregnancy (parenting) app, reached
//  from the "Post-Pregnancy" doorway on the mother's home. Faithful build of
//  Claude Design "post pregnancy app.dc.html" · frame 1 · v2 — "rebuilt to spec"
//  as a THREE-TAB home with a sliding underline:
//    • SNAPSHOT — where Aarav is: hero + video, milestones (tap a domain),
//      reassurance, what's-next, and his journal.
//    • SOLVE — the challenges this stage brings: expandable accordions +
//      watch / read / product / community rails.
//    • GROW — development opportunities: today's activity + more plays, and the
//      same watch / read / product / community rails.
//  A shared header sits above the tabs: greeting, child header (→ switcher), a
//  clickable Leap card (→ Wonder Week), and the growth-stats strip.
//
//  The menu icon (top of the greeting) opens the Explore drawer — the only path
//  to the section pages — so it's kept even though the mock doesn't draw it.
//  Nothing here imports pregnancy code. Scenario: Priya & baby Aarav, Leap 4.
// =============================================================================

import 'package:flutter/material.dart';

import 'article_reader_screen.dart';
import 'explore_drawer.dart';
import 'growth_activity_screen.dart';
import 'journal_screen.dart';
import 'multichild_sheet.dart';
import 'pp_common.dart';
import 'pp_products_data.dart';
import 'product_detail_screen.dart';
import 'snapshot_expanded_screen.dart';
import 'solve_problem_screen.dart';
import 'wonder_week_screen.dart';

class PostPregnancyHome extends StatefulWidget {
  const PostPregnancyHome({super.key});

  @override
  State<PostPregnancyHome> createState() => _PostPregnancyHomeState();
}

class _PostPregnancyHomeState extends State<PostPregnancyHome> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _tab = 0; // 0 snapshot · 1 solve · 2 grow
  bool _playLiked = false;
  final Set<int> _openAcc = {};

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  Widget _div({double top = 26, double bottom = 26}) => Padding(
        padding: EdgeInsets.fromLTRB(24, top, 24, bottom),
        child: const SizedBox(height: 1, child: ColoredBox(color: ppLine)),
      );

  // ---- navigation --------------------------------------------------------
  void _push(Widget screen) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  void _snapshot() => _push(const SnapshotExpandedScreen());
  void _solve() => _push(const SolveProblemScreen());
  void _grow() => _push(const GrowthActivityScreen());
  void _journal() => _push(const MyChildJournalScreen());
  void _read() => _push(const ArticleReaderScreen());
  void _product() => _push(const ProductDetailScreen());
  void _community() => openPpTab(context, 3);

  void _soon() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Editing coming soon'), behavior: SnackBarBehavior.floating),
      );

  // Tapping the child's photo opens a bottom-sheet of the child's details
  // (faithful to "post pregnancy app.dc.html" · S1 v2 · data-detailsmodal) —
  // NOT the Snapshot screen.
  void _openChildDetails() {
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
                Text("Aarav's details", style: ppJakarta(18)),
                GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, size: 16, color: ppSoft),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              // editable profile row
              Row(children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                      clipBehavior: Clip.antiAlias,
                      child: const PpStriped(height: 70),
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: GestureDetector(
                        onTap: _soon,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: ppPurple, shape: BoxShape.circle, border: Border.all(color: ppBg, width: 2)),
                          child: const Icon(Icons.edit, size: 11, color: Colors.white),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Aarav', style: ppJakarta(20)),
                    const SizedBox(height: 2),
                    Text('4 months 1 week', style: ppBody(13)),
                  ]),
                ),
                GestureDetector(onTap: _soon, behavior: HitTestBehavior.opaque, child: Text('Edit', style: ppBody(13, color: ppPurple, w: FontWeight.w700))),
              ]),
              const SizedBox(height: 10),
              _detailRow('Date of birth', const [TextSpan(text: '8 March 2026')], top: true),
              _detailRow('Sex', const [TextSpan(text: 'Boy')], top: true),
              _detailRow('Weight', [const TextSpan(text: '6.4 kg'), TextSpan(text: ' · 50th', style: ppBody(14, color: ppMuted))], top: true),
              _detailRow('Height', [const TextSpan(text: '63 cm'), TextSpan(text: ' · 48th', style: ppBody(14, color: ppMuted))], top: true),
              _detailRow('Head', [const TextSpan(text: '41 cm'), TextSpan(text: ' · 52nd', style: ppBody(14, color: ppMuted))], top: true, bottom: true),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, List<InlineSpan> value, {bool top = false, bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Expanded(child: Text(label, style: ppBody(13, color: ppSoft))),
          const SizedBox(width: 12),
          Text.rich(TextSpan(children: value), style: ppBody(14, color: ppInk, w: FontWeight.w600)),
        ]),
      );

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
            const SizedBox(height: 14),
            _pad(_leapChip()),
            const SizedBox(height: 20),
            _pad(_growthStats()),
            const SizedBox(height: 24),
            _pad(_tabBar()),
            ..._panel(),

            // Deals — at the very bottom, so commerce never sits on the app's
            // face. A gentle nudge for scrollers, not a marketplace shelf up top.
            const SizedBox(height: 30),
            _dealsSection(),
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
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]),
              ),
            ),
          ),
        ),

        const Positioned(left: 16, right: 16, bottom: 18, child: PpBottomNav(active: 0)),
      ]),
    );
  }

  // ==== shared header =====================================================
  Widget _greeting() => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
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

  Widget _childHeader() => Row(children: [
        GestureDetector(
          key: const ValueKey('child-photo'),
          onTap: _openChildDetails,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 64),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            GestureDetector(
              onTap: () => showMultiChildSheet(context),
              behavior: HitTestBehavior.opaque,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Flexible(child: Text('Aarav', style: ppJakarta(21), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
            const SizedBox(height: 5),
            Row(children: [
              Flexible(child: Text('4 months 1 week', style: ppBody(13, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFFC7BBD6), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('Born 8 March 2026', style: ppBody(12, color: ppMuted)),
            ]),
          ]),
        ),
      ]);

  Widget _leapChip() => GestureDetector(
        onTap: () => _push(const WonderWeekScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppBorder)),
          child: Row(children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: const [BoxShadow(color: Color(0x4D6A30B6), blurRadius: 8, spreadRadius: -4, offset: Offset(0, 3))],
              ),
              child: const Icon(Icons.brightness_4_rounded, size: 18, color: ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Now in · Day 12'.toUpperCase(),
                    style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 1.2)),
                const SizedBox(height: 2),
                Text('Leap 4 · The World of Events', style: ppJakarta(14).copyWith(height: 1.2), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.info_outline, size: 16, color: ppPurple),
          ]),
        ),
      );

  Widget _growthStats() => GestureDetector(
        onTap: _grow,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            _stat('Weight', '6.4', 'kg', '50th'),
            _statDivider(),
            _stat('Height', '63', 'cm', '48th'),
            _statDivider(),
            _stat('Head', '41', 'cm', '52nd'),
          ]),
        ),
      );

  Widget _stat(String label, String value, String unit, String centile) => Expanded(
        child: Column(children: [
          Text(label.toUpperCase(), style: ppBody(10, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.4)),
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

  // ==== tab bar ===========================================================
  Widget _tabBar() => Column(children: [
        Row(children: [_tabItem('Snapshot', 0), _tabItem('Solve', 1), _tabItem('Grow', 2)]),
        SizedBox(
          height: 2,
          child: Stack(children: [
            const Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(color: ppHair))),
            AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOutCubic,
              alignment: Alignment((_tab - 1).toDouble(), 0),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                child: Container(decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(2))),
              ),
            ),
          ]),
        ),
      ]);

  Widget _tabItem(String label, int i) {
    final on = i == _tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tab = i),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(label, textAlign: TextAlign.center, style: ppJakarta(15, color: on ? ppInk : ppMuted)),
        ),
      ),
    );
  }

  // ==== panels ============================================================
  List<Widget> _panel() {
    switch (_tab) {
      case 1:
        return _solvePanel();
      case 2:
        return _growPanel();
      default:
        return _snapshotPanel();
    }
  }

  // ---- SNAPSHOT ----------------------------------------------------------
  List<Widget> _snapshotPanel() => [
        const SizedBox(height: 22),
        _pad(Text("Aarav's world is getting bigger.", style: ppFraunces(32, h: 1.13))),
        const SizedBox(height: 16),
        _pad(_videoHero()),
        const SizedBox(height: 16),
        _pad(Text.rich(TextSpan(children: [
          TextSpan(text: "He's deep in ", style: ppBody(15, h: 1.65)),
          TextSpan(text: 'Leap 4', style: ppBody(15, color: ppInk, w: FontWeight.w600, h: 1.65)),
          TextSpan(
              text:
                  " — working out that actions flow in smooth sequences. He's clingier and his sleep feels upside-down, but it passes, and he comes out more capable.",
              style: ppBody(15, h: 1.65)),
        ]))),
        const SizedBox(height: 22),
        _pad(_railLabel('Milestones')),
        const SizedBox(height: 6),
        _pad(Text('Tap a domain for skills, tips & when to see a doctor.', style: ppBody(12, color: ppMuted))),
        const SizedBox(height: 6),
        _pad(Column(children: [
          _mile('Motor', 'Swiping at toys, pushing up — a first roll is close.', top: true),
          _mile('Cognitive', 'Following your hand to the toy — cause & effect.', top: true),
          _mile('Social', 'Beaming across the room; a laugh earns a laugh.', top: true),
          _mile('Language', "'Aah-goo', raspberries, squeals — rehearsing talk.", top: true, bottom: true),
        ])),
        const SizedBox(height: 14),
        _pad(Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.eco_outlined, size: 16, color: ppPurple),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                  "Every child grows at their own pace. This is a gentle guide, not a test — if Aarav reaches things a little earlier or later, that's completely normal. You're doing beautifully.",
                  style: ppBody(12, h: 1.55)),
            ),
          ]),
        )),
        const SizedBox(height: 16),
        _pad(Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: ppStripeB, borderRadius: BorderRadius.circular(14)),
          child: Text.rich(TextSpan(children: [
            TextSpan(text: 'What to expect next · ', style: ppBody(12, color: ppBrown, w: FontWeight.w700, h: 1.5)),
            TextSpan(text: 'a confident roll, one-handed reaching, and grabbing everything.', style: ppBody(13, color: ppInk, h: 1.5)),
          ])),
        )),
        const SizedBox(height: 14),
        _pad(GestureDetector(
          onTap: _snapshot,
          behavior: HitTestBehavior.opaque,
          child: Text('Full snapshot & child details →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
        )),
        const SizedBox(height: 22),
        _pad(_journalCard()),
      ];

  Widget _videoHero() => GestureDetector(
        onTap: _snapshot,
        behavior: HitTestBehavior.opaque,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(children: [
            const PpStriped(height: 190, radius: 22, border: true),
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
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0x802F2C30)]),
                ),
                child: Text('Aarav this month — a guide to Leap 4', style: ppBody(12, color: Colors.white, w: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      );

  Widget _mile(String label, String text, {bool top = false, bool bottom = false}) => GestureDetector(
        onTap: _snapshot,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            SizedBox(width: 74, child: Text(label, style: ppBody(12, color: ppPurple, w: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: ppBody(13, h: 1.45))),
            const SizedBox(width: 10),
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
              child: const Icon(Icons.chevron_right_rounded, size: 16, color: ppPurple),
            ),
          ]),
        ),
      );

  Widget _journalCard() => Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE5F2))),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [ppPanel, Color(0xFFECE5F2)]),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text("Aarav's journal", style: ppFraunces(20), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                Text('34 saved', style: ppBody(11, color: ppBrown, w: FontWeight.w700)),
              ]),
              const SizedBox(height: 3),
              Text('Your private space inside My Child.', style: ppBody(12)),
            ]),
          ),
          Container(
            color: Colors.white,
            child: Row(children: [
              _journalTile(Icons.mic_none_rounded, 'Voice', right: true),
              _journalTile(Icons.photo_camera_outlined, 'Photo', right: true),
              _journalTile(Icons.edit_outlined, 'Note'),
            ]),
          ),
        ]),
      );

  Widget _journalTile(IconData icon, String label, {bool right = false}) => Expanded(
        child: GestureDetector(
          onTap: _journal,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15),
            decoration: BoxDecoration(
              border: Border(right: right ? const BorderSide(color: Color(0xFFF0EBF5)) : BorderSide.none),
            ),
            child: Column(children: [
              Icon(icon, size: 17, color: ppPurple),
              const SizedBox(height: 6),
              Text(label, style: ppBody(11, color: ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
      );

  // ---- SOLVE -------------------------------------------------------------
  List<Widget> _solvePanel() => [
        const SizedBox(height: 22),
        _pad(Text('Challenges to solve', style: ppJakarta(19))),
        const SizedBox(height: 8),
        _pad(Text(
            "The hurdles this stage tends to bring — the fires you're firefighting today. Each is a real problem for a 4-month-old, surfaced proactively with what actually helps. Tap to expand.",
            style: ppBody(14, h: 1.6))),
        const SizedBox(height: 18),
        _pad(_railLabel("Today's challenges", color: ppCoral)),
        const SizedBox(height: 6),
        _pad(Column(children: [
          _acc(0, 'The 4-month sleep regression',
              "His sleep cycles are maturing into adult-like patterns with lighter phases he briefly wakes in. It's development, not a step back — and it settles in 2–6 weeks with a steady routine.",
              now: true, top: true),
          _acc(1, 'Clinginess & extra fussiness',
              'The stormy stretch of the leap — his brain is working hard, so he wants the safety of you, constantly. Extra closeness now helps him settle faster.',
              top: true),
          _acc(2, 'Distracted feeding',
              "He's so busy taking in his new world that he pulls off mid-feed. Feeding in a calm, dim room helps him focus and take a full feed.",
              top: true, bottom: true),
        ])),
        const SizedBox(height: 24),
        _pad(_railLabel('Watch this leap')),
        const SizedBox(height: 12),
        _rail(170, [
          _videoCard('The regression, explained', '3 min', _solve),
          _videoCard('Drowsy but awake, on video', '4 min', _solve),
          _videoCard('Reading his tired cues', '2 min', _solve),
        ]),
        const SizedBox(height: 22),
        _pad(_railLabel('Read this leap')),
        const SizedBox(height: 12),
        _rail(182, [
          _readCard('5 min read', 'Why sleep cycles change at 4 months'),
          _readCard('4 min read', 'Drowsy but awake: the hardest skill'),
          _readCard('3 min read', 'A survival guide to night wakings'),
        ]),
        const SizedBox(height: 22),
        _pad(_railLabel('Products that help')),
        const SizedBox(height: 12),
        _rail(198, [
          _productCard('White-noise soother', '₹1,499'),
          _productCard('Blackout curtains', '₹1,299'),
          _productCard('SnuggleSack sleep bag', '₹899'),
        ]),
        const SizedBox(height: 24),
        _pad(_railLabel('Your communities')),
        const SizedBox(height: 10),
        _pad(Column(children: [
          _commRow(Icons.groups_outlined, 'March 2025 babies', 'Joined · 8 new posts on sleep', top: true),
          _commRow(Icons.bedtime_outlined, 'Sleep support circle', 'Joined · live chat tonight', top: true, bottom: true),
        ])),
        const SizedBox(height: 22),
        _pad(_railLabel('Recommended communities for you')),
        const SizedBox(height: 12),
        _rail(150, [
          _commCard(Icons.child_care, '4-month regression survivors', '2.4k parents · very active'),
          _commCard(Icons.place_outlined, 'Delhi NCR new mums', 'Near you · meetups'),
          _commCard(Icons.face_outlined, 'Boy moms', 'Suggested for Aarav'),
        ]),
      ];

  Widget _acc(int i, String title, String body, {bool now = false, bool top = false, bool bottom = false}) {
    final open = _openAcc.contains(i);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: ppHair) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        GestureDetector(
          onTap: () => setState(() => open ? _openAcc.remove(i) : _openAcc.add(i)),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(children: [
              Expanded(
                child: Row(children: [
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
              ),
              const SizedBox(width: 10),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 180),
                child: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: ppMuted),
              ),
            ]),
          ),
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(body, style: ppBody(13, h: 1.55)),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _solve,
                behavior: HitTestBehavior.opaque,
                child: Text('Read more →', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
              ),
            ]),
          ),
      ]),
    );
  }

  // ---- GROW --------------------------------------------------------------
  List<Widget> _growPanel() => [
        const SizedBox(height: 22),
        _pad(Text('Baby development opportunities', style: ppJakarta(19))),
        const SizedBox(height: 8),
        _pad(Text(
            "What you can do today to develop Aarav's brain, body, and skills for the future — short, doable activities with a clear developmental benefit.",
            style: ppBody(14, h: 1.6))),
        const SizedBox(height: 22),
        _pad(_railLabel('Activity of today', color: ppCoral)),
        const SizedBox(height: 10),
        _pad(Text('Peekaboo, slow and silly', style: ppJakarta(20))),
        const SizedBox(height: 6),
        _pad(Text('5 min · builds object permanence', style: ppBody(12, color: ppMuted))),
        const SizedBox(height: 10),
        _pad(Text('Hiding your face and reappearing teaches Aarav you still exist when you vanish — the very first seed of object permanence.',
            style: ppBody(14, h: 1.6))),
        const SizedBox(height: 16),
        _pad(Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: _grow,
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                child: Text('How to play', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => setState(() => _playLiked = !_playLiked),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _playLiked ? ppCoralTint : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _playLiked ? ppCoralTint : ppLine),
              ),
              child: Icon(_playLiked ? Icons.favorite : Icons.favorite_border, size: 22, color: _playLiked ? ppCoral : ppMuted),
            ),
          ),
        ])),
        const SizedBox(height: 24),
        _pad(Row(children: [
          Expanded(child: Text('More activities for Leap 4', style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          GestureDetector(onTap: _grow, child: ppSeeAll()),
        ])),
        const SizedBox(height: 13),
        _rail(176, [
          _playCard('Peekaboo, slow and silly', '5 min · Object permanence'),
          _playCard('Reach for the ring', '4 min · Grasp & intent'),
          _playCard('Mirror, mirror on the mat', '3 min · Self & faces'),
          _playCard('Roll-toward-the-toy', '5 min · Rolling practice'),
        ]),
        const SizedBox(height: 24),
        _pad(_railLabel('Watch this leap')),
        const SizedBox(height: 12),
        _rail(170, [
          _videoCard('Peekaboo, done right', '2 min', _grow),
          _videoCard('Tummy-time games for rolling', '3 min', _grow),
          _videoCard('Reaching & grasping play', '4 min', _grow),
        ]),
        const SizedBox(height: 22),
        _pad(_railLabel('Read this leap')),
        const SizedBox(height: 12),
        _rail(182, [
          _readCard('4 min read', 'Games that build object permanence'),
          _readCard('5 min read', 'Why cause & effect matters in Leap 4'),
          _readCard('3 min read', 'Play ideas for a clingy baby'),
        ]),
        const SizedBox(height: 22),
        _pad(_railLabel('Products for Leap 4')),
        const SizedBox(height: 12),
        _rail(198, [
          _productCard('Curious Cubs · peekaboo cloth book', '₹399'),
          _productCard('Soft baby mirror', '₹549'),
          _productCard('Grasping activity rings', '₹299'),
        ]),
        const SizedBox(height: 24),
        _pad(_railLabel('Your communities')),
        const SizedBox(height: 10),
        _pad(Column(children: [
          _commRow(Icons.groups_outlined, 'March 2025 babies', 'Joined · 8 new posts on sleep', top: true),
          _commRow(Icons.child_friendly_outlined, 'Play & development club', 'Joined · new activity ideas', top: true, bottom: true),
        ])),
      ];

  Widget _playCard(String title, String meta) => GestureDetector(
        onTap: _grow,
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

  // ==== shared rail pieces ================================================
  Widget _railLabel(String t, {Color color = ppSoft}) =>
      Text(t.toUpperCase(), style: ppBody(11, color: color, w: FontWeight.w700).copyWith(letterSpacing: 1.0));

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

  Widget _videoCard(String title, String min, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 190,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(children: [
                const PpStriped(height: 110, radius: 16, border: true),
                const Positioned.fill(child: Center(child: _PlayDisc(38))),
                Positioned(
                  top: 9,
                  left: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(999)),
                    child: Text(min, style: ppBody(10, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 9),
            Text(title, style: ppBody(13, color: ppInk, w: FontWeight.w600, h: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _readCard(String meta, String title) => GestureDetector(
        onTap: _read,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 190,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 110, radius: 16, border: true),
            const SizedBox(height: 9),
            Text(meta.toUpperCase(), style: ppBody(10, color: ppCoral, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
            const SizedBox(height: 3),
            Text(title, style: ppBody(13, color: ppInk, w: FontWeight.w600, h: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _productCard(String title, String price) => GestureDetector(
        onTap: _product,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 160,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const PpStriped(height: 120, radius: 16, border: true),
            const SizedBox(height: 10),
            Text(title, style: ppJakarta(14, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _commRow(IconData icon, String title, String sub, {bool top = false, bool bottom = false}) => GestureDetector(
        onTap: _community,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              top: top ? const BorderSide(color: ppHair) : BorderSide.none,
              bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
            ),
          ),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 19, color: ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                const SizedBox(height: 1),
                Text(sub, style: ppBody(12, color: ppMuted)),
              ]),
            ),
            const SizedBox(width: 10),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );

  Widget _commCard(IconData icon, String title, String sub) => GestureDetector(
        onTap: _community,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 175,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppLine)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 18, color: ppPurple),
            ),
            const SizedBox(height: 11),
            Text(title, style: ppJakarta(14).copyWith(height: 1.25), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 5),
            Text(sub, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  // ---- deals for the day (bottom-of-home commerce) -----------------------
  // A gentle, clearly-labelled shelf at the very bottom — affiliate + own
  // picks with placeholder discounts (no finalised deals yet). Tap → detail.
  Widget _dealsSection() {
    const deals = <(String, int)>[
      ('playgym', 20),
      ('clothbook', 15),
      ('snugglesack', 25),
      ('carrier', 15),
      ('thermometer', 20),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pad(Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Deals for the day', style: ppJakarta(18)),
            const SizedBox(height: 2),
            Text("Handpicked for Aarav's stage — affiliate & ParentVeda picks.", style: ppBody(12)),
          ]),
        ),
        const SizedBox(width: 10),
        GestureDetector(onTap: () => openPpTab(context, 4), behavior: HitTestBehavior.opaque, child: ppSeeAll()),
      ])),
      const SizedBox(height: 14),
      SizedBox(
        height: 242,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: deals.length,
          separatorBuilder: (_, _) => const SizedBox(width: 14),
          itemBuilder: (_, i) => _dealCard(deals[i].$1, deals[i].$2),
        ),
      ),
      const SizedBox(height: 12),
      _pad(Text('Sponsored & affiliate picks — always labelled, and never on your research pages.',
          textAlign: TextAlign.center, style: ppBody(11, color: ppMuted, h: 1.5))),
    ]);
  }

  Widget _dealCard(String id, int disc) {
    final p = productById(id);
    final original = (p.price / (1 - disc / 100)).round();
    return GestureDetector(
      onTap: () => _push(ProductDetailScreen(product: p)),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 158,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(children: [
              const PpStriped(height: 126, radius: 16, border: true),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(999)),
                  child: Text('$disc% OFF', style: ppBody(9, color: Colors.white, w: FontWeight.w700).copyWith(letterSpacing: 0.4)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 9),
          Text(p.name, style: ppJakarta(13, w: FontWeight.w600).copyWith(height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Row(children: [
            Flexible(child: Text(p.priceLabel, style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(_money(original),
                  style: ppBody(11, color: ppMuted).copyWith(decoration: TextDecoration.lineThrough),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          const SizedBox(height: 3),
          Text(p.retailer == 'In-app' ? 'ParentVeda · in-app' : 'via ${p.retailer}', style: ppBody(10, color: ppMuted)),
        ]),
      ),
    );
  }

  String _money(int n) {
    final s = n.toString();
    if (s.length <= 3) return '₹$s';
    return '₹${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
  }
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
