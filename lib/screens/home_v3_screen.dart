// =============================================================================
//  HomeV3Screen — direction "2a", built so it can be compared against V2
// -----------------------------------------------------------------------------
//  THE THIRD VERSION, sitting beside Classic and Focus rather than replacing
//  either. home_screen_b.dart (Classic) and home_focus_screen.dart (Focus) are
//  both untouched; the pill in today_home_screen.dart decides which is on
//  screen. Nothing is deleted so all three can be looked at on one phone.
//
//  WHAT 2a IS: grid-led like direction 1a, carrying the full-bleed hero from
//  direction 1b. Four differences from V2, each of which 2a did better —
//  the reasoning for each is in v3_sections.dart.
//
//    header merged INTO the hero  ·  reads as a vertical list  ·  a Begin verb
//    on the practice  ·  "PRICES SHOWN" stated in the products heading
//
//  SAME CONTENT AS V2, and deliberately so. If the two versions differed in
//  what they showed as well as how, a comparison between them would answer
//  nothing. Both read HomeDay, read_next_data, kVideos and product_data.
//
//  ENGLISH ONLY via `.en` — see v2_sections.dart.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../brand/brand_models.dart';
import '../brand/launch_spotlight.dart';
import '../data/product_data.dart' show productImageUrl;
import '../services/app_nav.dart';
import '../services/app_structure.dart';
import '../services/home_content_controller.dart';
import '../services/landing_focus.dart';
import '../services/life_stage_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/scans_store.dart';
import '../widgets/global_ask_fab.dart' show kAskFabReserve, openAskVeda;
import 'referral/invite_nudge_card.dart';
import 'today_home_screen.dart';
import 'v2/v2_block_art.dart';
import 'v2/v2_block_grid.dart';
import 'v2/v2_palette.dart';
import 'v2/v2_sections.dart';
import '../data/garbh_data.dart';
import '../services/garbh_store.dart';
import 'garbh_screen.dart' show ShravanScreen, SamvadScreen, KriyaScreen;
import '../models/journal_entry.dart';
import '../services/medicine_store.dart';
import '../services/reminder_store.dart';
import '../widgets/journal/journal_create.dart';
import 'journal_screen.dart';
import 'reminders_screen.dart' show showMedReminderEditor;
import 'tools/medicine_tracker_screen.dart';
import 'v2/v3_daily.dart';
import 'v2/v3_daily_tip.dart';
import 'v2/v3_garbh.dart';
import 'v2/v3_sections.dart';

class HomeV3Screen extends StatefulWidget {
  const HomeV3Screen({super.key, required this.pregnancy, required this.home});

  final PregnancyController pregnancy;
  final HomeContentController home;

  @override
  State<HomeV3Screen> createState() => _HomeV3ScreenState();
}

class _HomeV3ScreenState extends State<HomeV3Screen> {
  PregnancyController get pregnancy => widget.pregnancy;
  HomeContentController get home => widget.home;

  // ---- The daily tip, fired once when this screen first has content ---------
  //
  // WHY NOT initState. On a cold start both controllers are still loading, so
  // `home.dayFor(...)` is null and the tip would be empty — and the guard in
  // showDailyTip is one-shot, so an empty first call would silently eat the
  // only chance to show it. Instead every build tries, and the first build that
  // actually HAS a line wins. The guard makes the repeats free.
  //
  // Deferred by a frame because showing a dialog synchronously inside build
  // mutates the Navigator mid-build — the same "setState during build" class of
  // crash main_scaffold.dart documents for the Ask FAB.
  bool _tipQueued = false;

  void _maybeShowTip(String line, int week, V2Palette p) {
    if (_tipQueued || line.trim().isEmpty) return;
    _tipQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDailyTip(context, line: line, week: week, p: p);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Wired once, here, so v3_sections does not have to import product_data.
    productImageUrlV3 = productImageUrl;
    return AnimatedBuilder(
      animation: Listenable.merge([
        pregnancy,
        home,
        LandingFocus.instance,
        LifeStageStore.instance,
        V2PaletteStore.instance,
        // The grid reads V2BlockArtMode, so this must listen to it too. Without
        // it the toggle flipped the store and nothing rebuilt — the same class
        // of bug as the version pill that went on showing "Classic" while the
        // body had already swapped (see today_home_screen.dart). A store read
        // by a child is a store the parent has to listen to.
        V2BlockArtMode.instance,
      ]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    if (pregnancy.isLoading || home.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeDay = home.previewDay ?? pregnancy.currentDay;
    final week = (((activeDay - 1) ~/ 7) + 1).clamp(4, 40);
    final day = home.dayFor(activeDay, week);
    final p = V2PaletteStore.instance.current;
    final reads = v2ReadsFor(week, activeDay);
    final video = v2VideoFor(week);
    final products = v2ProductsFor(week, activeDay);

    final insight = (day?.grow.remember.en.trim().isNotEmpty ?? false)
        ? day!.grow.remember.en
        : (day?.grow.insight.en ?? '');

    final name = pregnancy.motherName.trim();

    // The tip no longer has a section on this page — it arrives as a card in
    // the middle of the screen on open. See v2/v3_daily_tip.dart for why a
    // greeting is not the interstitial §16.3 bans.
    _maybeShowTip(insight, week, p);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The clock, battery and signal now sit ON the photograph, so they have
      // to be light. Without this they render dark-on-dark and disappear.
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        color: p.ground,
        // NO SafeArea AT THE TOP, deliberately. SafeArea would inset the list
        // below the status bar and leave a coloured strip above the image —
        // which is exactly the seam this screen is trying not to have. The
        // hero adds MediaQuery.padding.top to its own header instead, so the
        // photograph bleeds under the bar while her name still clears it.
        child: SafeArea(
          top: false,
          bottom: false,
        // NO HORIZONTAL PADDING ON THE LIST. The hero has to reach both
        // edges, and a list that pads everything cannot let one child out.
        // Every other section wraps itself in _pad() instead.
        child: ListView(
          padding: const EdgeInsets.only(bottom: kAskFabReserve),
          children: [
            // ---- HEADER AND HERO AS ONE BLOCK -------------------------------
            if (day != null)
              V3Hero(
                name: name.isEmpty ? 'Today' : 'Today, $name',
                subtitle: 'Symptoms, medicines and how you are doing.',
                week: week,
                day: activeDay,
                learning: day.babyLearning.en,
                p: p,
                onTap: () => _open(context, 'weekly_snapshot'),
                onAvatar: () => _open(context, 'journal'),
                onSaved: () => _open(context, 'saved'),
              ),
            // Everything except the hero is inset. The hero is the only
            // child allowed to touch the screen edges.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            const SizedBox(height: 24),

            // ---- The only time-sensitive row, still hiding when empty -------
            V2ComingUp(p: p, onTap: () => _open(context, 'tests_scans')),
            if (ScansStore.instance.appointments.isNotEmpty)
              const SizedBox(height: 12),

            // MOVEMENT / KICK COUNT REMOVED — placement rejected.
            //
            // It sat under "Coming up" on the argument that both answer "does
            // anything need me today". On the phone it read as an interruption
            // between the hero and the doors: the first thing after the
            // photograph was a clinical instruction, which is the opposite of
            // what this screen opens with everywhere else.
            //
            // Not re-homed elsewhere on purpose. The Scans door and the
            // Tests & scans chip already reach it, and a clinical prompt needs
            // a placement decision rather than a spare slot. Note also that the
            // copy was written here rather than taken from the content files —
            // if it comes back, the words come from a clinician.

            // ---- WHERE TO GO ------------------------------------------------
            // "Six doors" counted the tiles, which is a fact about the layout and
            // not a thing she needs. This gives permission instead: no order, no
            // right answer, nothing waiting to be worked through.
            V3SectionHead(
                eyebrow: 'Where to go', title: 'Start anywhere', p: p),
            const SizedBox(height: 12),
            V2BlockGrid(palette: p, blocks: _blocks(context, week, p)),
            const SizedBox(height: 28),

            // ---- TO READ — a LIST, not a rail -------------------------------
            if (reads.isNotEmpty) ...[
              V3SectionHead(
                  eyebrow: 'To read', title: 'Short enough for today', p: p),
              const SizedBox(height: 8),
              for (final r in reads.take(3))
                V3ReadRow(
                    item: r,
                    p: p,
                    onTap: () => _open(context, 'daily_reads')),
              const SizedBox(height: 28),
            ],

            // ---- GARBH SANSKAR ---------------------------------------------
            //
            // One block, not three cards. See v3_garbh.dart for what was wrong
            // and which principle each fix comes from.
            if (day != null) ...[
              ListenableBuilder(
                listenable: GarbhStore.instance,
                builder: (context, _) {
                  final store = GarbhStore.instance;
                  final cd = activeDay;
                  final tri = garbhTrimester(week);
                  final rows = <GarbhPillarRow>[
                    GarbhPillarRow(
                      name: 'Shravan',
                      image:
                          'https://images.unsplash.com/photo-1633411988188-6e63354a9019?w=200&h=200&fit=crop',
                      tag: 'Sacred listening',
                      today: shravanForDay(cd).title.en,
                      icon: Icons.graphic_eq_rounded,
                      accent: const Color(0xFF9A7526),
                      done: store.isDone('shravan'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => ShravanScreen(
                              controller: pregnancy, daily: true))),
                    ),
                    GarbhPillarRow(
                      name: 'Samvad & Vichara',
                      image:
                          'https://images.unsplash.com/photo-1541956799312-3f9df99e0006?w=200&h=200&fit=crop',
                      tag: 'Womb talk',
                      today: promptForDay(cd, tri).text.en,
                      icon: Icons.record_voice_over_rounded,
                      accent: const Color(0xFF9C5F51),
                      done: store.isDone('samvad'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => SamvadScreen(
                              controller: pregnancy, daily: true))),
                    ),
                    GarbhPillarRow(
                      name: 'Kriya',
                      image:
                          'https://images.unsplash.com/photo-1485808269728-77bb07c059a8?w=200&h=200&fit=crop',
                      tag: 'Breath & grounding',
                      today: kriyaForDay(cd).title.en,
                      icon: Icons.spa_rounded,
                      accent: const Color(0xFF3F6E62),
                      done: store.isDone('kriya'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) =>
                              KriyaScreen(controller: pregnancy, daily: true))),
                    ),
                  ];
                  return V3GarbhSection(
                    day: day,
                    p: p,
                    rows: rows,
                    onAbout: () => _open(context, 'garbh_daily'),
                  );
                },
              ),
              const SizedBox(height: 28),
            ],

            // ---- TODAY'S MEDICINES ------------------------------------------
            //
            // Restored from Classic. It sits directly under Garbh Sanskar
            // because the two belong to the same half of the screen: everything
            // above is content she takes in, and these are the things she DOES.
            // Grouping them means the page has one "your turn" region rather
            // than actions scattered between articles.
            V3SectionHead(
                eyebrow: 'Every day',
                title: 'What you take today',
                p: p),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable:
                  Listenable.merge([MedicineStore.instance, ReminderStore.instance]),
              builder: (context, _) {
                final store = MedicineStore.instance;
                return V3MedsSection(
                  p: p,
                  items: [
                    for (final m in store.activeMeds)
                      V3MedItem(
                        name: m.name,
                        sub: [m.dose, m.time]
                            .where((x) => x.isNotEmpty)
                            .join(' · '),
                        taken: store.isTakenToday(m.id),
                        onToggle: () => store.toggleToday(m.id),
                      ),
                  ],
                  onManage: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) =>
                          MedicineTrackerScreen(controller: pregnancy))),
                  onAddReminder: () =>
                      showMedReminderEditor(context, pregnancy),
                );
              },
            ),
            const SizedBox(height: 28),

            // ---- MY JOURNAL --------------------------------------------------
            //
            // Also restored. Four verbs, not a prompt — she arrives already
            // knowing whether she wants to write, photograph or speak, and the
            // job of this card is to not stand between her and that.
            V3SectionHead(
                eyebrow: 'My journal', title: 'Keep today', p: p),
            const SizedBox(height: 12),
            V3JournalSection(
              p: p,
              actions: [
                V3QuickAction(
                    icon: Icons.edit_note_rounded,
                    label: 'Write a\nmemory',
                    onTap: () => openJournalText(
                        context, pregnancy, JournalEntryType.memory)),
                V3QuickAction(
                    icon: Icons.favorite_border_rounded,
                    label: 'Note for\nbaby',
                    onTap: () => openJournalText(
                        context, pregnancy, JournalEntryType.noteForBaby)),
                V3QuickAction(
                    icon: Icons.photo_camera_outlined,
                    label: 'Add a\nphoto',
                    onTap: () => openJournalAddPhoto(context, pregnancy)),
                V3QuickAction(
                    icon: Icons.mic_none_rounded,
                    label: 'Record\nvoice',
                    onTap: () => openJournalRecordVoice(context, pregnancy)),
              ],
              onOpenAll: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => JournalScreen(controller: pregnancy))),
            ),
            const SizedBox(height: 28),

            // ---- TODAY'S TIP — MOVED OUT OF THE PAGE ------------------------
            //
            // Kept commented rather than deleted, per the repo's "comment out,
            // never delete" rule: if the pop-up turns out to be the wrong home
            // for it, this is the section it goes back to.
            //
            // if (insight.trim().isNotEmpty) ...[
            //   V3SectionHead(
            //       eyebrow: "Today's tip", title: 'Worth remembering', p: p),
            //   const SizedBox(height: 12),
            //   V2InsightBlock(line: insight, p: p),
            //   const SizedBox(height: 28),
            // ],

            // ---- ONE VIDEO --------------------------------------------------
            if (video != null) ...[
              V3SectionHead(
                  eyebrow: 'Watch', title: 'Six minutes, this week', p: p),
              const SizedBox(height: 12),
              V2VideoCard(
                  video: video,
                  p: p,
                  onTap: () => _open(context, 'todays_video')),
              const SizedBox(height: 28),
            ],

            // ---- THINGS THAT HELP · PRICES SHOWN ----------------------------
            if (products.isNotEmpty) ...[
              V3SectionHead(
                  eyebrow: 'Things that help',
                  title: 'What mothers ask us about',
                  note: 'Prices shown',
                  p: p),
              const SizedBox(height: 12),
              // A RAIL, NOT A LIST — and the difference is the point.
              //
              // Reads get the committed vertical treatment because a read is
              // the thing we want her to do. Products are optional, so they get
              // the browse treatment: "some things exist, swipe if curious".
              // Four rows with right-aligned prices read like an invoice; a
              // rail reads like a shelf, and takes a third of the height.
              V2ProductRail(
                  items: products, p: p, onOpen: () => _open(context, 'shop')),
              const SizedBox(height: 28),
            ],

            // ---- ALSO TODAY -------------------------------------------------
            //
            // V3 shipped without this row and that quietly removed My journal,
            // Medicines and Tests & scans from the home screen. The row is the
            // demotion mechanism: everything the day does not lead with is
            // still named here, with the tab that owns it.
            _AlsoRow(p: p, onOpen: (id) => _open(context, id)),
            const SizedBox(height: 28),

            // ---- Commerce, after the content --------------------------------
            LaunchSpotlight(
              stage: BrandStage.pregnancy,
              pregnancyWeek: week,
              padding: const EdgeInsets.only(bottom: 14),
            ),
            const InviteNudgeCard(padding: EdgeInsets.only(bottom: 6)),
            const SizedBox(height: 20),
            _ArtToggle(p: p),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  /// Same six doors as V2 — the grid is the part both versions share, so that
  /// what differs between them is structure rather than contents.
  List<V2Block> _blocks(BuildContext context, int week, V2Palette p) => [
        V2Block(
          label: 'Practice',
          mark: V2Mark.practice,
          tint: v2BlockTint(V2BlockHues.practice, p),
          meta: 'Today',
          icon: Icons.self_improvement_rounded,
          asset: 'assets/blocks/block_practice.png',
          onTap: () => _open(context, 'garbh_daily'),
        ),
        V2Block(
          label: 'This week',
          mark: V2Mark.week,
          tint: v2BlockTint(V2BlockHues.week, p),
          meta: 'Week $week',
          icon: Icons.child_care_rounded,
          asset: 'assets/blocks/block_week.png',
          onTap: () => _open(context, 'weekly_snapshot'),
        ),
        V2Block(
          label: 'Scans',
          mark: V2Mark.scan,
          tint: v2BlockTint(V2BlockHues.scans, p),
          icon: Icons.monitor_heart_rounded,
          asset: 'assets/blocks/block_scan.png',
          onTap: () => _open(context, 'tests_scans'),
        ),
        V2Block(
          label: 'Read',
          mark: V2Mark.read,
          tint: v2BlockTint(V2BlockHues.read, p),
          icon: Icons.menu_book_rounded,
          asset: 'assets/blocks/block_read.png',
          onTap: () => _open(context, 'daily_reads'),
        ),
        V2Block(
          label: 'Watch',
          mark: V2Mark.watch,
          tint: v2BlockTint(V2BlockHues.watch, p),
          icon: Icons.play_circle_rounded,
          asset: 'assets/blocks/block_video.png',
          onTap: () => _open(context, 'todays_video'),
        ),
        V2Block(
          label: 'Ask',
          mark: V2Mark.ask,
          tint: v2BlockTint(V2BlockHues.ask, p),
          icon: Icons.auto_awesome_rounded,
          asset: 'assets/blocks/block_ask.png',
          onTap: () => openAskVeda(pregnancy),
        ),
      ];

  /// Open the tab that owns a surface — same contract as V2.
  void _open(BuildContext context, String surfaceId) {
    final h = homeFor(surfaceId);
    if (h == null) return;
    switch (h) {
      case AppHome.today:
      case AppHome.profile:
        TodayVersionStore.instance.set(TodayVersion.classic);
      case AppHome.prepare:
        AppNav.instance.go(1);
      case AppHome.tools:
        AppNav.instance.go(2);
      case AppHome.calendar:
        AppNav.instance.go(3);
      case AppHome.community:
        AppNav.instance.go(4);
    }
  }
}

/// The demotion row — everything the day did not lead with, named, with the tab
/// that owns it.
///
/// Its absence is how V3 first shipped without My journal, Medicines or
/// Tests & scans anywhere on the home screen. A screen that leads with six
/// things still has to say where the other twenty went.
class _AlsoRow extends StatelessWidget {
  const _AlsoRow({required this.p, required this.onOpen});

  final V2Palette p;
  final void Function(String id) onOpen;

  // 'journal' and 'medication' were here and have been REMOVED, because they
  // now have real sections above. A surface named twice on one screen — once as
  // the thing itself and once as a chip pointing at it — teaches her that the
  // chips are unreliable, which costs the whole row its usefulness.
  static const _ids = [
    'tests_scans',
    'weight',
    'hospital_bag',
    'can_i',
  ];

  @override
  Widget build(BuildContext context) {
    final ids = _ids.where((id) => homeFor(id) != null).toList();
    if (ids.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      V3SectionHead(
          eyebrow: 'Also today', title: 'Still here, just not first', p: p),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final id in ids)
          Builder(builder: (context) {
            final surface = kAppSurfaces.firstWhere((x) => x.id == id);
            return InkWell(
              onTap: () => onOpen(id),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: p.line),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(surface.label,
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink1)),
                  if (surface.home != AppHome.today) ...[
                    const SizedBox(width: 6),
                    Text(surface.home.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: p.action.withValues(alpha: 0.7))),
                  ],
                ]),
              ),
            );
          }),
      ]),
    ]);
  }
}

/// Rendered objects vs drawn marks, switchable on the phone.
///
/// Same reasoning as the palette bar: a taste question between two coherent
/// options is settled faster by looking than by arguing. Sandbox chrome —
/// it goes when one of the two wins.
class _ArtToggle extends StatelessWidget {
  const _ArtToggle({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: V2BlockArtMode.instance,
      builder: (context, _) {
        Widget seg(String label, bool vector) {
          final on = V2BlockArtMode.instance.vector == vector;
          return InkWell(
            onTap: () => V2BlockArtMode.instance.set(vector),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: on ? p.action : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? p.action : p.line),
              ),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: on ? p.onAction : p.ink1)),
            ),
          );
        }

        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Divider(color: p.line, height: 1),
          const SizedBox(height: 16),
          Text('DOOR MARKS — SANDBOX ONLY',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: p.ink3)),
          const SizedBox(height: 12),
          Row(children: [
            seg('Rendered', false),
            const SizedBox(width: 8),
            seg('Drawn', true),
          ]),
        ]);
      },
    );
  }
}
