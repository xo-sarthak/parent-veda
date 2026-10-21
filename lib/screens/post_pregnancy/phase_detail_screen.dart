// =============================================================================
//  PhaseDetailScreen — one age phase, in full
// -----------------------------------------------------------------------------
//  Replaces LeapDefinitionScreen. Same job — help a parent understand what is
//  happening right now — but built on the AAP/CDC milestone framework rather
//  than fixed-week leaps.
//
//  Order is deliberate:
//    1. what this phase IS, and the reassurance line (the 3am question)
//    2. what he is working on
//    3. milestones, grouped by the five AAP domains
//    4. the fuller description
//    5. screening prompt, where AAP recommends one
//    6. the Indian-context layer
//
//  Milestones use the AAP 75% threshold — "most children can do this by now",
//  not "average" — which the 2022 revision adopted specifically to stop parents
//  waiting and seeing. That is why the framing is definite rather than vague,
//  and why every screen carries a "talk to your doctor" route.
// =============================================================================

import 'package:flutter/material.dart';

// import '../../widgets/pv_placeholders.dart'; // the film placeholder card moved onto the painting (2026-10-21)
import 'pp_common.dart';
import 'pp_product_widgets.dart';
import 'pp_products_data.dart';
import 'pp_tools_kit.dart';
import 'products_discovery_screen.dart';
import 'pp_phases_data.dart';
import 'pp_phase_film.dart' show ppOpenPhaseRead;
import '../../data/pp_phase_docs.dart' show ppPhaseDocFor, PpSnapshot, PpDocDomain, PpDocDomainX;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;
import '../v2/v3_dev_mark.dart' show DevMark, V3DevMark;
import 'pp_home_reads.dart' show ppPhaseVideo;
import 'pp_phase_doc_reads.dart' show ppOpenMilestoneRead;
import 'video/pv_video_player.dart' show PvVideoPlayer;
import '../../widgets/pv_feedback.dart' show PvPress;
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'phase_map_screen.dart' show PhasePainting;
import 'pp_phase_page.dart' show PpPhasePage;

// ⚠️ THE HOUSE LOOK, 2026-10-17 (the user: "very old UI, font not matching
// and very purple"). Same sections in the same order; only the chrome changed:
// the bare-arrow back bar the rest of the app uses, Pregnancy's w600 serif for
// headings in place of Jakarta, V2Palette ink in place of the phase accent
// (ppPurple on all twenty), and the phase painting at the top so the art made
// from docs/PHASE-PAINTING-PROMPTS.md shows here as well as on the map.
// The old values are noted inline as "was ..." for revert.
V2Palette get _c => V2PaletteStore.instance.current;
TextStyle _serif(double size) => pvFraunces(
    fontSize: size, fontWeight: FontWeight.w600, height: 1.2, letterSpacing: -0.45, color: _c.ink1);

class PhaseDetailScreen extends StatefulWidget {
  const PhaseDetailScreen({super.key, required this.phase});
  final AgePhase phase;

  @override
  State<PhaseDetailScreen> createState() => _PhaseDetailScreenState();
}

class _PhaseDetailScreenState extends State<PhaseDetailScreen> {
  AgePhase get phase => widget.phase;

  /// The film is playing in the painting's place (2026-10-21, Wave 5).
  bool _playing = false;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ⚠️ A FACADE SINCE 2026-10-22 (Wave 6): one phase is the one phase page,
  // opened on this phase, with the full doc as its body. The screen as it
  // was is [buildClassic], kept for revert.
  @override
  Widget build(BuildContext context) => PpPhasePage(initial: phase.number);

  Widget buildClassic(BuildContext context) {
    final p = phase;
    final film = ppPhaseVideo(p);
    // ⚠️ A PHASE WITH A DOC (1–15 on 2026-10-13, all 20 since 2026-10-16). `kPhases` has already laid
    // the doc over this phase: `workingOn` is its Living Through titles and
    // `milestones` its Child Snapshot. Those are NOT the AAP 75% milestones,
    // so they must not sit under the "three in four children" caption; they
    // take the doc's own labels, and the full doc page is one tap away.
    final hasDoc = ppPhaseDocFor(p.number) != null;
    return Scaffold(
      backgroundColor: _c.ground, // was ppBg
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBackBar(context, '${ChildProfileStore.instance.theirCap} journey')), // was ppBack; was 'His journey' (2026-10-21)
            const SizedBox(height: 14),
            // ⚠️ THE PAINTING IS THE FILM'S POSTER (2026-10-21, Wave 5; the
            // user: the image "does nothing" and the film sat at the foot as a
            // placeholder). As Insight Timer and Mindvalley do on Mobbin: one
            // cover, one play action. With a film, a tap plays it in place, the
            // same film the home shows (ppPhaseVideo). Without one, a quiet
            // line says it is coming; the painting is never a blank box.
            // Was: ClipRRect(AspectRatio(4 / 3, PhasePainting)).
            _pad(ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: _playing && film != null
                    ? PvVideoPlayer(video: film, inline: true, autoStart: true)
                    : Stack(fit: StackFit.expand, children: [
                        PhasePainting(phase: p),
                        Positioned(
                          right: film == null ? null : 12,
                          left: film == null ? 12 : null,
                          bottom: 12,
                          child: film == null
                              ? Container(
                                  key: const ValueKey('phase_detail_film_soon'),
                                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text('Film for this phase coming soon',
                                      style: ppBody(11.5, color: _c.ink1, w: FontWeight.w700)),
                                )
                              : Semantics(
                                  button: true,
                                  label: 'Play the film for ${p.name}',
                                  excludeSemantics: true,
                                  child: PvPress(child: GestureDetector(
                                    key: const ValueKey('phase_detail_play'),
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
                                          decoration: BoxDecoration(color: _c.ink1, shape: BoxShape.circle),
                                          child: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                                        ),
                                        const SizedBox(width: 7),
                                        Text('Play this phase',
                                            style: ppBody(12.5, color: _c.ink1, w: FontWeight.w800)),
                                      ]),
                                    ),
                                  )),
                                ),
                        ),
                      ]),
              ),
            )),
            const SizedBox(height: 16),
            _pad(Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(
                  color: _c.surfaceAlt, // was p.accent at 0.12
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(p.ageLabel,
                    style: ppBody(11.5, color: _c.ink1, w: FontWeight.w800)),
              ),
              if (p.checkpoint) ...[
                const SizedBox(width: 8),
                Icon(Icons.verified_outlined, size: 15, color: _c.ink3),
                const SizedBox(width: 4),
                Flexible(
                  child: Text('Doctor checkpoint',
                      style: ppBody(11.5, color: _c.ink3, w: FontWeight.w700),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ])),
            const SizedBox(height: 12),
            _pad(Text(p.name, style: _serif(28))), // was ppFraunces(30) w400
            // Doc-only phases (2026-10-14): the docs carry no tagline, so it
            // draws only where one exists.
            if (p.tagline.isNotEmpty) ...[
              const SizedBox(height: 6),
              _pad(Text(p.tagline, style: ppBody(14.5, color: _c.ink2, w: FontWeight.w700))),
            ],
            const SizedBox(height: 14),
            _pad(Text(p.summary, style: ppBody(15, color: ppInk, h: 1.65))),
            if (hasDoc) ...[
              const SizedBox(height: 10),
              _pad(PvPress(child: GestureDetector(
                key: const ValueKey('phase_detail_read_doc'),
                onTap: () => ppOpenPhaseRead(context, p),
                behavior: HitTestBehavior.opaque,
                child: Row(children: [
                  Flexible(child: Text('Read this phase in full', style: ppBody(13.5, color: _c.ink1, w: FontWeight.w700))),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 15, color: _c.ink1), // was ppPurple
                ]),
              ))),
            ],

            // The reassurance line — the thing a worried parent came for.
            // Authored text, so empty on doc-only phases (2026-10-14).
            if (p.reassurance.isNotEmpty) ...[
            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: ppPanel,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.favorite_border, size: 17, color: ppCoral),
                const SizedBox(width: 11),
                Expanded(child: Text(p.reassurance, style: ppBody(13.5, color: ppInk, h: 1.6))),
              ]),
            )),
            ],

            // ---- working on ----
            const SizedBox(height: 26),
            // ⚠️ THE VIDEO GOES AT THE TOP, per the standing feedback for every
            // section. `AgePhase.videoId` has existed since this screen was
            // built and is null on all twenty phases — declared and never
            // populated, which is the same shape as the consult roles and the
            // phase productIds below.
            //
            // So it renders the real player when there is a file and the real
            // placeholder when there is not, rather than rendering nothing and
            // hiding the gap. `slotId` names the wiring at the moment the slot
            // is created.
            // The film moved onto the painting above (2026-10-21, Wave 5). The
            // separate placeholder card, kept for revert:
            // const SizedBox(height: 20),
            // _pad(PvVideoPlaceholder(
            //   title: '${p.name}, in five minutes',
            //   subtitle: 'What is happening for him now, and what helps.',
            //   duration: '5 min',
            //   hue: 268,
            //   flat: true,
            //   slotId: 'development/phase/${p.number}',
            // )),

            if (p.workingOn.isNotEmpty) ...[
            const SizedBox(height: 24),
            _pad(Text(hasDoc ? 'Living through this phase' : 'What he is working on', style: _serif(21))), // was ppJakarta(18)
            const SizedBox(height: 12),
            _pad(Column(children: [
              for (final w in p.workingOn)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7),
                      decoration: BoxDecoration(color: _c.ink1, shape: BoxShape.circle), // was p.accent
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text(w, style: ppBody(14, color: ppInk, h: 1.55))),
                  ]),
                ),
            ])),
            ],

            // ---- milestones by domain ----
            if (p.milestones.isNotEmpty) ...[
            const SizedBox(height: 22),
            _pad(Text(hasDoc ? 'Child snapshot' : 'Most children can, by the end of this phase', style: _serif(21))), // was ppJakarta(18)
            if (!hasDoc) ...[
              const SizedBox(height: 4),
              _pad(Text(
                'These are the milestones about three in four children reach by this age — not an average, and not a deadline.',
                style: ppBody(12.5, color: _c.ink3, h: 1.45),
              )),
            ],
            const SizedBox(height: 10),
            // ⚠️ A DOC PHASE DRAWS THE DOC'S OWN SNAPSHOT (2026-10-21, Wave 5):
            // each area's drawn mark, the card's title AND its one line (the line
            // was dropped before), and a tap opens that area's milestone page in
            // the reader, as the phase's full read already does. Nothing here was
            // tappable. Non-doc phases keep the AAP cards below.
            if (ppPhaseDocFor(p.number) case final doc?)
              _pad(Column(children: [
                for (final s in doc.snapshot)
                  _SnapshotRow(
                    key: ValueKey('phase_snapshot_${s.domain.name}'),
                    snap: s,
                    onTap: switch (doc.milestoneFor(s.domain)) {
                      final m? => () => ppOpenMilestoneRead(context, doc, m),
                      null => null,
                    },
                  ),
              ]))
            else
            // The doc's fixed order (Brain, Physical, Language, Emotional,
            // Nutrition) for a doc phase; the enum's order otherwise.
            for (final d in hasDoc
                ? const [PhaseDomain.cognitive, PhaseDomain.motor, PhaseDomain.language, PhaseDomain.social, PhaseDomain.adaptive]
                : PhaseDomain.values)
              if (p.inDomain(d).isNotEmpty) _pad(_domainCard(p, d)),
            ],

            // ---- fuller description ----
            for (final s in p.sections) ...[
              const SizedBox(height: 22),
              _pad(Text(s.heading, style: _serif(20))), // was ppJakarta(17)
              const SizedBox(height: 10),
              for (final para in s.paragraphs) ...[
                _pad(Text(para, style: ppBody(14.5, color: ppInk, h: 1.65))),
                const SizedBox(height: 12),
              ],
            ],

            // ---- screening ----
            if (p.screeningNote != null) ...[
              const SizedBox(height: 12),
              _pad(Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: _c.surfaceAlt, // was ppPurple at 0.07, border at 0.20
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _c.line),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.fact_check_outlined, size: 17, color: _c.ink1),
                    const SizedBox(width: 9),
                    Expanded(child: Text('A screening is due around now', style: ppJakarta(15, color: _c.ink1))),
                  ]),
                  const SizedBox(height: 9),
                  Text(p.screeningNote!, style: ppBody(13.5, color: ppInk, h: 1.6)),
                  const SizedBox(height: 8),
                  Text(
                    'Screening at these visits is for every child. Being screened says nothing about yours.',
                    style: ppBody(12.5, color: ppSoft, h: 1.5),
                  ),
                ]),
              )),
            ],

            // ---- Indian context ----
            if (p.indianNote != null) ...[
              const SizedBox(height: 14),
              _pad(Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: _c.surfaceAlt, // was amber 0xFFC98A2B at 0.08 (2026-10-21)
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FOR INDIAN FAMILIES',
                      style: ppBody(9.5, color: _c.ink3, w: FontWeight.w800) // was 0xFF9A6B12
                          .copyWith(letterSpacing: 0.8)),
                  const SizedBox(height: 8),
                  Text(p.indianNote!, style: ppBody(13.5, color: ppInk, h: 1.6)),
                ]),
              )),
            ],

            // ---- FAQs ----------------------------------------------------
            // ⚠️ REUSES THE WRITTEN, AGE-BANDED ANSWERS rather than authoring
            // twenty new sets. `ppLearnBlock` opens `ppFaqSheet`, which now
            // prefers `pp_faq_data.dart` over corpus search, and those answers
            // already change with the child's age — so the same four questions
            // read differently on a three-month phase and a three-year one.
            // Twenty hand-written FAQ sets would be twenty things to keep true.
            const SizedBox(height: 26),
            _pad(ppLearnBlock(context, const [
              'Why do babies develop at such different rates?',
              'What does "serve and return" mean?',
              'How can I support development through play?',
              'When is a wait-and-see, and when to ask?',
            ])),

            // ---- products ------------------------------------------------
            // ⚠️ AN INVITATION, NOT INVENTED PICKS. The feedback asks for a
            // recommended-products section with a see-more. `AgePhase` has a
            // `productIds` field and it is EMPTY on all twenty phases, and
            // `PpProduct` carries no age or stage, so there is no honest way to
            // derive "products for this phase" in code.
            //
            // Fabricating a rail by category would be a recommendation the app
            // cannot stand behind, on a page a parent is reading to work out
            // whether her child is fine. So the section renders as a real way
            // in to the catalogue, and becomes a curated rail the moment
            // `productIds` is filled — the rendering below is already written
            // for that case.
            //
            // Empty-but-present rather than hidden, per the repo rule that a
            // feature is never hidden and only its empty copy changes.
            const SizedBox(height: 26),
            _pad(Row(children: [
              Expanded(child: Text('Things that help at this stage', style: _serif(20))), // was ppJakarta(16.5)
            ])),
            const SizedBox(height: 6),
            _pad(Text(
                p.productIds.isEmpty
                    ? 'Nothing is picked out for this phase yet. The full '
                        'catalogue is organised by what you are solving.'
                    : 'Chosen for where he is now.',
                style: ppBody(12.5, color: _c.ink3, h: 1.5))),
            const SizedBox(height: 12),
            if (p.productIds.isNotEmpty)
              _pad(Column(children: [
                for (final id in p.productIds.take(3))
                  PpProductCard(productById(id)),
              ])),
            _pad(PvPress(child: GestureDetector(
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'pp/products'),
                builder: (_) => const ProductsDiscoveryScreen(),
              )),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Text(p.productIds.isEmpty ? 'Browse products' : 'See all for this stage',
                    style: ppBody(13, color: _c.ink1, w: FontWeight.w700)),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 15, color: _c.ink1), // was ppPurple
              ]),
            ))),

            const SizedBox(height: 22),
            _pad(Text(
              'Based on the AAP/CDC 2022 developmental milestone framework. Guidance to help you notice things — never a diagnosis, and never a substitute for your paediatrician.',
              textAlign: TextAlign.center,
              style: ppBody(11.5, color: _c.ink3, h: 1.55),
            )),
          ],
        ),
      ),
    );
  }

  Widget _domainCard(AgePhase p, PhaseDomain d) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _c.line), // was ppHair
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(d.icon, size: 16, color: _c.ink1), // was p.accent
            const SizedBox(width: 9),
            // A doc phase says the doc's domain names (Brain … Nutrition).
            Expanded(
                child: Text(
                    ppPhaseDocFor(p.number) == null
                        ? d.label
                        : switch (d) {
                            PhaseDomain.cognitive => 'Brain',
                            PhaseDomain.motor => 'Physical',
                            PhaseDomain.language => 'Language',
                            PhaseDomain.social => 'Emotional',
                            PhaseDomain.adaptive => 'Nutrition',
                          },
                    style: ppJakarta(14.5, color: _c.ink1))),
          ]),
          const SizedBox(height: 10),
          for (final m in p.inDomain(d))
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.check_rounded, size: 14, color: _c.ink3),
                const SizedBox(width: 9),
                Expanded(child: Text(m.text, style: ppBody(13.5, color: ppInk, h: 1.5))),
              ]),
            ),
        ]),
      );
}

/// One Child Snapshot line on the phase screen: the area's drawn mark on its
/// tint, the area's name, the doc's title and its one line, and a chevron when
/// it opens a milestone page. The row every list in the app draws.
class _SnapshotRow extends StatelessWidget {
  const _SnapshotRow({super.key, required this.snap, this.onTap});

  final PpSnapshot snap;
  final VoidCallback? onTap;

  static double _hue(PpDocDomain d) => switch (d) {
        PpDocDomain.brain => 38,
        PpDocDomain.physical => 214,
        PpDocDomain.language => 28,
        PpDocDomain.emotional => 345,
        PpDocDomain.nutrition => 140,
      };

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final hue = _hue(snap.domain);
    final tint = v2BlockTint(hue, c);
    final accent = HSLColor.fromAHSL(1, hue, 0.45, 0.42).toColor();
    final mark = switch (snap.domain) {
      PpDocDomain.brain => DevMark.brain,
      PpDocDomain.physical => DevMark.physical,
      PpDocDomain.language => DevMark.language,
      PpDocDomain.emotional => DevMark.emotional,
      PpDocDomain.nutrition => null,
    };
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ExcludeSemantics(
            child: mark == null
                ? TtcMarkLeading(tab: TtcTabMark.bowl, tint: tint, size: 40)
                : Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                    child: V3DevMark(mark: mark, accent: accent, size: 28),
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(snap.domain.label,
                  style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: c.ink3)),
              const SizedBox(height: 2),
              Text(ppFillChild(snap.title),
                  style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3, color: c.ink1)),
              const SizedBox(height: 3),
              Text(ppFillChild(snap.line),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 12.5, height: 1.45, color: c.ink2)),
            ]),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: c.ink3),
            ),
          ],
        ]),
      ),
    );
  }
}
