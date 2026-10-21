// =============================================================================
//  The one phase page: every phase, in full, swipeable
// -----------------------------------------------------------------------------
//  2026-10-22, Wave 6 (approved in the Artifact BgbjzKhougqj37K4rmtxKM v2).
//
//  The user, on what a phase tap should do: "when they click upon the phase,
//  they want to know what the phase is about". It used to take three screens
//  to get there (the 20-phase map, the phase screen, then "Read this phase in
//  full"), and only the last one had the real content. Now one tap lands on
//  the phase page:
//
//    * THE HEAD: a strip of the 20 phases (Flo's week pills on Mobbin), the
//      phase painting as the film's poster with ‹ › and, away from the
//      child's own phase, "Back to now" (Clue's "Back to today").
//    * THE BODY IS THE PHASE DOC, in the one reader (CLAUDE.md "One reader"),
//      through `ppPhaseDocAsRead`, the same read "Read this phase in full"
//      opened.
//    * "FOR THIS PHASE", after the child snapshot: the doc's activities,
//      reads from the doors for the phase's age, products for that age, one
//      expert by a small phase-to-need map, and a class. Built from the
//      phase's own age, so a phase you swipe to shows ITS things, not today's.
//    * Swipe, the strip, ‹ ›, or the "Next" step move between phases.
//
//  `PhaseMapScreen` and `PhaseDetailScreen` are facades over this page now,
//  so every link that opened them lands here.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/pp_phase_docs.dart' show ppPhaseDocFor, PpPhaseDoc, PpDocDomain, PpDocDomainX;
import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../doors/pv_list_row.dart' show PvRowGroup, PvListRow;
import '../reader/pv_reader_screen.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading, TtcToolMark;
import '../v2/v2_palette.dart';
import '../v2/v3_dev_mark.dart' show DevMark, V3DevMark;
import 'course_detail_screen.dart' show CourseDetailScreen;
import 'phase_map_screen.dart' show PhasePainting;
import 'pp_activity_read.dart' show ppActivityReader;
import 'pp_age_page_parts.dart' show PpAtThisAge;
import 'pp_common.dart' show PpProductImage;
import 'pp_courses_data.dart' show Course, kCourses;
import 'pp_experts_data.dart' show needLabel;
import 'pp_home_reads.dart' show ppPhaseVideo;
import 'pp_phase_doc_activities.dart' show ppDocActivityNamed;
import 'pp_phase_doc_reads.dart' show ppPhaseDocAsRead, ppPhaseDocBlock, ppOpenMilestoneRead, PpDocSnapshotBlock;
import 'pp_phase_faqs.dart' show phaseFaqs;
import 'pp_phase_film.dart' show ppPhaseAsRead;
import 'pp_phases_data.dart';
import 'pp_products_data.dart' show PpProduct, kPpProducts, categoryByName;
import 'pp_search.dart' show ppOpenSurface;
import 'pp_section_registry.dart' show kPpSections;
import 'pp_section_screen.dart' show ppOpenPage, PpSection;
import 'pp_content.dart' show PpPage;
import 'product_detail_screen.dart' show ProductDetailScreen;
import 'video/pv_video_player.dart' show PvVideoPlayer;

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// Opens the phase page on [phase] (a phase number), or on the child's own.
void ppOpenPhasePage(BuildContext context, {int? phase}) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/phase/${phase ?? currentPhase().number}'),
      builder: (_) => PpPhasePage(initial: phase),
    ));

/// The surface a "Next" step uses to move the page, not push a new one.
const String kPpPhasePageSurface = 'pp_phase_page/';

class PpPhasePage extends StatefulWidget {
  const PpPhasePage({super.key, this.initial});

  /// The phase number to open on; null opens the child's current phase.
  final int? initial;

  @override
  State<PpPhasePage> createState() => _PpPhasePageState();
}

class _PpPhasePageState extends State<PpPhasePage> {
  late final List<AgePhase> _phases = kPhases;
  late final int _current = currentPhase().number;
  late final PageController _pc = PageController(
      initialPage: ((widget.initial ?? _current) - 1).clamp(0, _phases.length - 1));

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int number) {
    final i = (number - 1).clamp(0, _phases.length - 1);
    if (!_pc.hasClients) return;
    final now = _pc.page?.round() ?? i;
    // A jump of more than one phase snaps; a neighbour slides.
    if ((now - i).abs() > 1) {
      _pc.jumpToPage(i);
    } else {
      _pc.animateToPage(i, duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) => PageView.builder(
        key: const ValueKey('pp_phase_page'),
        controller: _pc,
        itemCount: _phases.length,
        itemBuilder: (context, i) => _PhaseRead(
          key: ValueKey('pp_phase_page_${_phases[i].number}'),
          phase: _phases[i],
          current: _current,
          count: _phases.length,
          onGo: _go,
        ),
      );
}

/// One phase as a read: the doc (or the older phase prose where a doc is
/// missing) plus this page's own "For this phase", questions and next step.
PvRead ppPhasePageRead(AgePhase phase, {required int current}) {
  final n = phase.number;
  final kicker = n == current
      ? 'This phase · ${phase.ageLabel}'
      : (n > current ? 'Coming up · ${phase.ageLabel}' : 'Earlier · ${phase.ageLabel}');
  final next = n < kPhases.length ? kPhases[n] : null;
  final doc = ppPhaseDocFor(n);
  if (doc == null) return ppPhaseAsRead(phase);
  return ppPhaseDocAsRead(
    doc,
    phase,
    kicker: kicker,
    extra: [
      // The age page that left the home (2026-10-22): sleep and feeding now,
      // the WHO ranges, call the doctor if. It reads the child's own age, so
      // it rides only on the child's own phase.
      if (n == current) PvReadSection(custom: PpPhaseAgeBlock(phase)),
      PvReadSection(heading: _same('For this phase'), custom: PpPhaseOffersBlock(phase, doc)),
    ],
    faqs: [
      for (final f in phaseFaqs(n, count: 3))
        PvReadFaq(question: _same(f.question), answer: _same(f.answer)),
    ],
    nextSteps: [
      if (next != null)
        PvReadNextStep(
          kind: PvNextKind.tool,
          title: _same('Next · ${next.name}'),
          value: _same('Phase ${next.number} · ${next.ageLabel}'),
          surfaceId: '$kPpPhasePageSurface${next.number}',
        ),
    ],
  );
}

class _PhaseRead extends StatelessWidget {
  const _PhaseRead({
    super.key,
    required this.phase,
    required this.current,
    required this.count,
    required this.onGo,
  });
  final AgePhase phase;
  final int current;
  final int count;
  final ValueChanged<int> onGo;

  void _surface(BuildContext context, String id) {
    if (id.startsWith(kPpPhasePageSurface)) {
      final n = int.tryParse(id.substring(kPpPhasePageSurface.length));
      if (n != null) return onGo(n);
    }
    ppOpenSurface(context, id);
  }

  @override
  Widget build(BuildContext context) {
    // The head: the strip (44) and the painting at 4:3 across the page.
    final w = MediaQuery.sizeOf(context).width;
    final head = 54 + (w - 32) * 3 / 4 + 4;
    return PvReaderScreen(
      read: ppPhasePageRead(phase, current: current),
      // Parenting authors in English (CLAUDE.md, "New work is English").
      lang: AppLanguage.english,
      heroHeight: head,
      hero: _PhaseHead(phase: phase, current: current, count: count, onGo: onGo),
      customBlock: (context, block) => switch (block) {
        PpPhaseOffersBlock() => _Offers(block: block),
        PpPhaseAgeBlock(:final phase) => PpAtThisAge(
            phase: phase,
            p: V2PaletteStore.instance.current,
            onGrowth: () => ppOpenSurface(context, 'pp_growth')),
        PpDocSnapshotBlock(:final doc) => _Snapshot(doc: doc),
        _ => ppPhaseDocBlock(context, block),
      },
      openSurface: _surface,
    );
  }
}

// -----------------------------------------------------------------------------
//  The head: the phase strip and the painting
// -----------------------------------------------------------------------------

class _PhaseHead extends StatefulWidget {
  const _PhaseHead({required this.phase, required this.current, required this.count, required this.onGo});
  final AgePhase phase;
  final int current;
  final int count;
  final ValueChanged<int> onGo;

  @override
  State<_PhaseHead> createState() => _PhaseHeadState();
}

class _PhaseHeadState extends State<_PhaseHead> {
  bool _playing = false;
  final ScrollController _strip = ScrollController();

  @override
  void initState() {
    super.initState();
    // Bring this phase's pill into view: about 44pt a pill.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_strip.hasClients) return;
      final target = ((widget.phase.number - 2) * 44.0).clamp(0.0, _strip.position.maxScrollExtent);
      _strip.jumpTo(target);
    });
  }

  @override
  void dispose() {
    _strip.dispose();
    super.dispose();
  }

  Widget _round(String glyph, VoidCallback? onTap, String label) => Semantics(
        button: true,
        label: label,
        child: Opacity(
          opacity: onTap == null ? 0.35 : 1,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
              child: Text(glyph, style: pvManrope(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1F1F23))),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final ph = widget.phase;
    final n = ph.number;
    final film = ppPhaseVideo(ph);
    return ColoredBox(
      color: p.ground,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 6),
        SizedBox(
          height: 36,
          child: ListView.separated(
            key: const ValueKey('pp_phase_strip'),
            controller: _strip,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.count,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final k = i + 1;
              final on = k == n;
              final mine = k == widget.current;
              return GestureDetector(
                key: ValueKey('pp_phase_pill_$k'),
                onTap: on ? null : () => widget.onGo(k),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? p.ink1 : p.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: on || mine ? p.ink1 : p.line),
                  ),
                  child: Text(on ? '$k  ${ph.name}' : '$k',
                      style: pvManrope(
                          fontSize: 12, fontWeight: FontWeight.w700, color: on ? Colors.white : p.ink1)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: _playing && film != null
                  ? PvVideoPlayer(video: film, inline: true, autoStart: true)
                  : Stack(fit: StackFit.expand, children: [
                      PhasePainting(phase: ph),
                      Positioned(
                        left: 8,
                        right: 8,
                        top: 0,
                        bottom: 0,
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          _round('‹', n > 1 ? () => widget.onGo(n - 1) : null, 'Previous phase'),
                          _round('›', n < widget.count ? () => widget.onGo(n + 1) : null, 'Next phase'),
                        ]),
                      ),
                      if (n != widget.current)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: GestureDetector(
                            key: const ValueKey('pp_phase_back_to_now'),
                            onTap: () => widget.onGo(widget.current),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: p.ink1, borderRadius: BorderRadius.circular(999)),
                              child: Text('Back to now',
                                  style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                          ),
                        ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: film == null
                            ? Container(
                                key: const ValueKey('pp_phase_film_soon'),
                                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text('Film for this phase coming soon',
                                    style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w700, color: p.ink1)),
                              )
                            : Semantics(
                                button: true,
                                label: 'Play the film for ${ph.name}',
                                excludeSemantics: true,
                                child: PvPress(
                                  child: GestureDetector(
                                    key: const ValueKey('pp_phase_play'),
                                    onTap: () => setState(() => _playing = true),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(8, 7, 13, 7),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.94),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
                                          child: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                                        ),
                                        const SizedBox(width: 7),
                                        Text('Watch this phase',
                                            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, color: p.ink1)),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ]),
            ),
          ),
        ),
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
//  "For this phase"
// -----------------------------------------------------------------------------

/// The custom block that carries the home's old age page (sleep and feeding
/// now, growth, call the doctor if) onto the child's own phase.
class PpPhaseAgeBlock {
  const PpPhaseAgeBlock(this.phase);
  final AgePhase phase;
}

/// The custom block that carries the phase's offers through the reader.
class PpPhaseOffersBlock {
  const PpPhaseOffersBlock(this.phase, this.doc);
  final AgePhase phase;
  final PpPhaseDoc doc;
}

/// One expert per phase, by what that age most often needs (the category is
/// the matching key `pp_experts/<category>` filters on, pp_surface_router).
String ppPhaseExpertCategory(int phase) => switch (phase) {
      <= 2 => 'Lactation expert',
      <= 6 => 'Sleep expert',
      <= 9 => 'Nutritionist',
      <= 14 => 'Development expert',
      _ => 'Speech therapist',
    };

/// Reads from the doors for the phase's age: pages written for that band,
/// one per door, rotated by the phase so neighbours differ.
List<({PpSection section, PpPage page})> ppPhaseReads(AgePhase phase, int n) {
  final months = phase.startMonth.floor();
  final out = <({PpSection section, PpPage page})>[];
  for (final s in kPpSections) {
    final set = s.bandSet;
    if (set == null) continue;
    final band = set.bandFor(months).id;
    final mine = [
      for (final a in s.areas)
        if (a.inBand(band))
          for (final pg in a.pagesFor(band))
            if (!pg.comingSoon && pg.toolSurfaceId == null && (pg.bands.isNotEmpty || a.bands.isNotEmpty)) pg,
    ];
    if (mine.isNotEmpty) out.add((section: s, page: mine[phase.number % mine.length]));
  }
  if (out.isEmpty) return out;
  final start = phase.number % out.length;
  return [for (var i = 0; i < out.length && i < n; i++) out[(start + i) % out.length]];
}

/// The class for this age: one whose age range covers the phase, else the
/// next one to start (shown as "Starts at …").
({Course course, bool now})? ppPhaseCourse(AgePhase phase) {
  final m = phase.startMonth;
  ({Course course, bool now})? soon;
  double soonFrom = double.infinity;
  for (final c in kCourses) {
    final r = RegExp(r'(\d+)\s*[–-]\s*(\d+)').firstMatch(c.ageTag);
    if (r == null) continue;
    final from = double.parse(r.group(1)!), to = double.parse(r.group(2)!);
    if (m >= from && m <= to) return (course: c, now: true);
    if (from > m && from < soonFrom) {
      soonFrom = from;
      soon = (course: c, now: false);
    }
  }
  return soon;
}

List<PpProduct> ppPhaseProducts(AgePhase phase, int n) {
  final months = phase.startMonth.floor();
  return kPpProducts.where((x) => x.suitsAge(months)).take(n).toList();
}

class _Offers extends StatelessWidget {
  const _Offers({required this.block});
  final PpPhaseOffersBlock block;

  Widget _sub(String s, V2Palette p) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(s.toUpperCase(),
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: p.ink2)),
      );

  Widget _pill(String s, V2Palette p) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: p.ink1)),
        child: Text(s, style: pvManrope(fontSize: 12, fontWeight: FontWeight.w700, color: p.ink1)),
      );

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final phase = block.phase;
    final acts = [
      for (final a in block.doc.activities)
        if (ppDocActivityNamed(block.doc, a.title) case final dev?) (doc: a, dev: dev),
    ];
    final reads = ppPhaseReads(phase, 2);
    final products = ppPhaseProducts(phase, 6);
    final category = ppPhaseExpertCategory(phase.number);
    final course = ppPhaseCourse(phase);
    final tint = v2BlockTint(268, p);
    return Column(
      key: ValueKey('pp_phase_offers_${phase.number}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (acts.isNotEmpty) ...[
          _sub('Things to do together', p),
          PvRowGroup(p: p, children: [
            for (final a in acts.take(3))
              PvListRow(
                key: ValueKey('pp_phase_activity_${a.dev.id}'),
                p: p,
                leading: PpDomainMark(a.doc.domain),
                title: ppFillChild(a.doc.title),
                line: a.doc.builds.isEmpty ? a.dev.metaLine : 'Builds ${a.doc.builds.take(2).join(', ').toLowerCase()}',
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                    settings: RouteSettings(name: 'pp/activity/${a.dev.id}'),
                    builder: (_) => ppActivityReader(a.dev))),
              ),
          ]),
        ],
        if (reads.isNotEmpty) ...[
          _sub('Read next', p),
          PvRowGroup(p: p, children: [
            for (final r in reads)
              PvListRow(
                key: ValueKey('pp_phase_read_${r.page.id}'),
                p: p,
                leading: TtcMarkLeading(tab: TtcTabMark.openBook, tint: tint, size: 40),
                title: r.page.title,
                line: r.section.title,
                onTap: () => ppOpenPage(context, r.section, r.page, onSurface: ppOpenSurface),
              ),
          ]),
        ],
        if (products.isNotEmpty) ...[
          _sub('Useful at this age', p),
          SizedBox(
            height: 150 + ((MediaQuery.textScalerOf(context).scale(10) / 10) - 1).clamp(0.0, 1.0) * 36,
            child: ListView.separated(
              key: ValueKey('pp_phase_products_${phase.number}'),
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final it = products[i];
                return SizedBox(
                  width: 112,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: RouteSettings(name: 'pp/product/${it.id}'),
                        builder: (_) => ProductDetailScreen(product: it))),
                    borderRadius: BorderRadius.circular(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      PpProductImage(
                        url: it.imageUrl,
                        height: 96,
                        width: 112,
                        radius: 14,
                        border: false,
                        icon: categoryByName(it.category).icon,
                      ),
                      const SizedBox(height: 6),
                      Text(it.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, height: 1.25, color: p.ink1)),
                    ]),
                  ),
                );
              },
            ),
          ),
        ],
        _sub('Talk to someone', p),
        PvRowGroup(p: p, children: [
          PvListRow(
            key: ValueKey('pp_phase_expert_${phase.number}'),
            p: p,
            leading: TtcMarkLeading(tool: TtcToolMark.expert, tint: tint, size: 40),
            title: 'A ${needLabel(category).toLowerCase()}',
            line: 'A video call, when something worries you',
            trailing: _pill('Book', p),
            onTap: () => ppOpenSurface(context, 'pp_experts/$category'),
          ),
          if (course case final c?)
            PvListRow(
              key: ValueKey('pp_phase_course_${c.course.id}'),
              p: p,
              leading: TtcMarkLeading(tool: TtcToolMark.courses, tint: tint, size: 40),
              title: '${c.course.title}, the class',
              line: c.now ? c.course.tagline : 'For ${c.course.ageTag} · save it for later',
              trailing: _pill(c.now ? 'Open' : 'Look', p),
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: RouteSettings(name: 'pp/course/${c.course.id}'),
                  builder: (_) => CourseDetailScreen(course: c.course))),
            ),
        ]),
        const SizedBox(height: 4),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
//  The area marks: the drawn development marks, one per doc domain
// -----------------------------------------------------------------------------

/// A doc domain's drawn mark on its tint disc: the four development marks
/// (`V3DevMark`), and the bowl for nutrition, which has no development mark.
/// The same mark the phase screen's snapshot drew (2026-10-21, Wave 5), so a
/// domain looks the same wherever it appears.
class PpDomainMark extends StatelessWidget {
  const PpDomainMark(this.domain, {super.key, this.size = 40});
  final PpDocDomain domain;
  final double size;

  static double hue(PpDocDomain d) => switch (d) {
        PpDocDomain.brain => 38,
        PpDocDomain.physical => 214,
        PpDocDomain.language => 28,
        PpDocDomain.emotional => 345,
        PpDocDomain.nutrition => 140,
      };

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final h = hue(domain);
    final tint = v2BlockTint(h, p);
    final mark = switch (domain) {
      PpDocDomain.brain => DevMark.brain,
      PpDocDomain.physical => DevMark.physical,
      PpDocDomain.language => DevMark.language,
      PpDocDomain.emotional => DevMark.emotional,
      PpDocDomain.nutrition => null,
    };
    return ExcludeSemantics(
      child: mark == null
          ? TtcMarkLeading(tab: TtcTabMark.bowl, tint: tint, size: size)
          : Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
              child: V3DevMark(mark: mark, accent: HSLColor.fromAHSL(1, h, 0.45, 0.42).toColor(), size: size * 0.7),
            ),
    );
  }
}

/// The child snapshot as rows with the area marks, each opening its
/// milestone page.
class _Snapshot extends StatelessWidget {
  const _Snapshot({required this.doc});
  final PpPhaseDoc doc;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return PvRowGroup(p: p, children: [
      for (final sn in doc.snapshot)
        PvListRow(
          key: ValueKey('pp_doc_snapshot_${sn.domain.name}'),
          p: p,
          leading: PpDomainMark(sn.domain),
          title: ppFillChild(sn.title),
          line: ppFillChild(sn.line),
          meta: sn.domain.label,
          lineMaxLines: 3,
          onTap: switch (doc.milestoneFor(sn.domain)) {
            final m? => () => ppOpenMilestoneRead(context, doc, m),
            null => () {},
          },
        ),
    ]);
  }
}
