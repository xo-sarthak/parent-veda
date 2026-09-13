// =============================================================================
//  MilestoneJourneyScreen - "Development Journey" tool (parenting · Tools)
// -----------------------------------------------------------------------------
//  The Milestone Checklist rebuilt from the Claude Design prompt: not a test, a
//  journey to observe and celebrate. A Development Snapshot hero (age · stage ·
//  recently celebrated · emerging skills · today's encouragement), the six
//  domains as an explorer, milestone cards you can mark "observed" (with a note,
//  turning a checkbox into a memory), a rich milestone detail sheet, and the
//  journey laid out as Emerging now · Recently celebrated · Coming soon. Every
//  word is warm — "emerging", never "delayed". Reads MilestoneStore. New tool
//  (there was no prior milestone screen).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import '../../brand/brand_models.dart';
import '../../brand/presented_by.dart';
import 'development_area_screen.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';
import 'pp_milestones_data.dart';
import 'pp_tools_kit.dart';

// ⚠️ THE FOUR AREAS OF GROWING, AS A CLOSER LOOK INSIDE THE TRACKER. The
// Development brief (reissued): "Brain, Physical, Language and Emotional sit
// inside the tracker as a way to look closer, not as the front of the
// section." Each domain sheet ends with a way into the matching area page
// (the timeline of skills and the go-deeper rails). Two datasets meet here
// — the milestones behind this screen and the `DevArea` skills behind those
// pages — and the join is by hand until they are one list; see
// docs/DOOR-CONTENT-OWED.md.
const Map<DevDomain, String> _kAreaForDomain = {
  DevDomain.cognitive: 'cognitive',
  DevDomain.grossMotor: 'gross_motor',
  DevDomain.fineMotor: 'fine_motor',
  DevDomain.language: 'language',
  DevDomain.social: 'emotional',
  DevDomain.selfCare: 'selfcare',
};

class MilestoneJourneyScreen extends StatefulWidget {
  const MilestoneJourneyScreen({super.key});

  @override
  State<MilestoneJourneyScreen> createState() => _MilestoneJourneyScreenState();
}

class _MilestoneJourneyScreenState extends State<MilestoneJourneyScreen> {
  final _store = MilestoneStore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final emerging = _store.emerging;
            // ⚠️ `final achieved = _store.achieved;` USED TO BE HERE. It fed
            // the "Recently celebrated" block, which the feedback removed
            // and which is commented out below. Restoring that block means
            // restoring this line too — written down because an
            // uncommented block referring to a deleted variable is a
            // confusing way to find that out.
            final soon = _store.comingSoon;
            // ⚠️ MERGED FROM "WHERE HE IS RIGHT NOW" (`pp_on_track`), which
            // was this list shown a second way. Its one group this screen
            // lacked: what is typically already there. Observed first, then
            // every window that has closed; `foundations` excludes observed,
            // so nothing counts twice. Framed as "usually settled", never
            // "should be", and never totalled.
            final settled = <Milestone>[..._store.achieved, ..._store.foundations];
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 48),
              children: [
                ...ppToolHeader(
                  context,
                  title: 'Development journey',
                  subtitle: 'Milestones are moments to notice and celebrate — never a test to pass.',
                ),
                const SizedBox(height: 20),
                ppToolPad(_hero()),

                // A way straight in, at the top. Most parents arrive because
                // they just SAW something - waiting for them to scroll the
                // whole map to find it makes them give up before logging it.
                const SizedBox(height: 14),
                ppToolPad(_quickLog()),
                // ⚠️ EMERGING LEADS THE PAGE NOW. Feedback: "the first thing
                // that should come in this page is basically cards with
                // different colours for Movement, talking, thinking etc."
                //
                // It used to sit third, under the snapshot hero and the domain
                // explorer, so the answer to "what is happening with my child
                // right now" was two screens of chrome down.
                const SizedBox(height: 26),
                ppToolPad(Row(children: [
                  const Icon(Icons.spa_outlined, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Emerging now', style: ppJakarta(17))),
                  Text('tap any card', style: ppBody(12, color: ppMuted)),
                ])),
                const SizedBox(height: 6),
                ppToolPad(Text('Skills that often blossom around ${ChildProfileStore.instance.ageLabel}. Tap a card to turn it over.', style: ppBody(13))),
                const SizedBox(height: 14),
                if (emerging.isEmpty)
                  ppToolPad(ppEmptyCard(Icons.spa_outlined, 'A quiet stretch — a lovely time to simply enjoy each other. New skills will surface soon.'))
                else
                  ppToolPad(Column(children: [
                    for (final m in emerging)
                      MilestoneFlipCard(
                        milestone: m,
                        observed: _store.isObserved(m.id),
                        observedLabel:
                            _store.isObserved(m.id) ? _obsDateLabel(m.id) : null,
                        onSeen: () => _openObserveSheet(m),
                        onDetail: () => _openDetail(m),
                      ),
                  ])),

                // ---- usually settled by now, from the merged checklist -----
                if (settled.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  ppToolPad(Row(children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 17, color: ppPurple),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Usually settled by now', style: ppJakarta(17))),
                  ])),
                  const SizedBox(height: 6),
                  ppToolPad(Text('Typical windows that have already passed. Most children have these; some arrive later and still arrive. Tap the circle if you have seen it.', style: ppBody(13))),
                  const SizedBox(height: 14),
                  ppToolPad(Column(children: [for (final m in settled) _settledRow(m)])),
                ],

                // ⚠️ "DEVELOPMENT INSIGHT" AND "RECENTLY CELEBRATED" REMOVED BY
                // FEEDBACK: "No Development Insight needed, No Recently
                // Celebrated". Both builders survive further down, so restoring
                // either is uncommenting this block.
                //
                // The celebration itself is not lost: marking a milestone still
                // opens the memory sheet and still writes a dated note. What is
                // gone is a second list of the same events on the same screen.
                /*
                const SizedBox(height: 24),
                ppToolPad(ppInsightCard(_insight(), tag: 'Development insight')),
                const SizedBox(height: 26),
                ppToolPad(Row(children: [
                  const Icon(Icons.celebration_outlined, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Recently celebrated', style: ppJakarta(17))),
                  Text('NN noticed', style: ppBody(12, color: ppMuted)),
                ])),
                const SizedBox(height: 14),
                ppToolPad(Column(children: [for (final m in achieved.take(4)) _achievedRow(m)])),
                */

                // ⚠️ THE DOMAIN EXPLORER MOVED BELOW THE CARDS, not away.
                // Browsing by area is a real second question; it just is not
                // the first one a parent has.
                const SizedBox(height: 28),
                ppToolPad(ppSectionHead('Explore by area')),
                const SizedBox(height: 4),
                ppToolPad(Text('Development happens across all of these at once.', style: ppBody(13))),
                const SizedBox(height: 14),
                _domainRow(),

                ppToolPad(Row(children: [
                  const Icon(Icons.wb_twilight_rounded, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Coming soon', style: ppJakarta(17))),
                ])),
                const SizedBox(height: 6),
                ppToolPad(Text('A soft look ahead — you may begin noticing these in the months to come. Never a deadline.', style: ppBody(13))),
                const SizedBox(height: 14),
                ppToolPad(Column(children: [for (final m in soon.take(4)) _soonRow(m)])),

                // The merged checklist's closing line, kept word for word:
                // the one sentence that makes the whole page safe to read.
                const SizedBox(height: 8),
                ppToolPad(Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                  child: Text(
                      'A row you have not ticked is not a row he has missed. If a skill he had has gone away, or something has felt off for a while, that is worth mentioning to your paediatrician — not because of anything on this page, but because you noticed it.',
                      style: ppBody(13, h: 1.55)),
                )),

                const SizedBox(height: 28),
                ppToolPad(ppLearnBlock(context, const [
                  'Why do babies develop at such different rates?',
                  'What does "serve and return" mean?',
                  'How can I support development through play?',
                  'When is a wait-and-see, and when to ask?',
                ])),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- hero: development snapshot -----------------------------------------
  /// "He just did something" — a direct entry that searches every milestone by
  /// name, so a parent can log what she saw without scrolling the whole map.
  Widget _quickLog() => GestureDetector(
        onTap: _openQuickLog,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: ppPurple,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Color(0x336A30B6), blurRadius: 18, spreadRadius: -6, offset: Offset(0, 8))],
          ),
          child: Row(children: [
            const Icon(Icons.add_circle_outline_rounded, size: 19, color: Colors.white),
            const SizedBox(width: 11),
            Expanded(
              child: Text('He just did something — find it',
                  style: ppBody(14, color: Colors.white, w: FontWeight.w700),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.search_rounded, size: 18, color: Colors.white),
          ]),
        ),
      );

  void _openQuickLog() {
    final ctl = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final q = ctl.text.trim().toLowerCase();
          final hits = q.isEmpty
              ? const <Milestone>[]
              : kMilestones
                  .where((m) => m.title.toLowerCase().contains(q) || m.desc.toLowerCase().contains(q))
                  .take(12)
                  .toList();
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),
                  Text('What did you see?', style: ppFraunces(22, h: 1.15)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ctl,
                    autofocus: true,
                    onChanged: (_) => setSheet(() {}),
                    style: ppBody(14.5, color: ppInk),
                    decoration: InputDecoration(
                      hintText: 'rolled over, smiled, grabbed…',
                      hintStyle: ppBody(14.5, color: ppMuted),
                      prefixIcon: const Icon(Icons.search_rounded, size: 19, color: ppMuted),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (q.isEmpty)
                    Text('Type what he did and we will find the milestone it belongs to.',
                        style: ppBody(13, color: ppMuted, h: 1.5))
                  else if (hits.isEmpty)
                    Text('Nothing matches that yet — it may not be a tracked milestone, which does not make it any less lovely.',
                        style: ppBody(13, color: ppMuted, h: 1.5))
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final m in hits)
                            GestureDetector(
                              onTap: () {
                                Navigator.of(ctx).pop();
                                _openDetail(m);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(children: [
                                  Icon(kDomainMeta[m.domain]!.icon, size: 17, color: kDomainMeta[m.domain]!.ink),
                                  const SizedBox(width: 11),
                                  Expanded(child: Text(m.title, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
                                  const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
                                ]),
                              ),
                            ),
                        ],
                      ),
                    ),
                ]),
              ),
            ),
          );
        },
      ),
    ).whenComplete(ctl.dispose);
  }

  Widget _hero() {
    final recent = _store.recentlyAchieved;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const RadialGradient(center: Alignment(-0.7, -0.8), radius: 1.3, colors: [Color(0xFFF3ECFA), Colors.white]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: ppHair),
        boxShadow: const [BoxShadow(color: Color(0x1A6A30B6), blurRadius: 30, spreadRadius: -20, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ppEyebrow(ChildProfileStore.instance.ageLabel, color: ppPurple),
        const SizedBox(height: 8),
        Text(_store.stageLabel, style: ppFraunces(24, h: 1.12)),
        // Renders nothing unless sponsored. A milestone is never moved,
        // reworded or gated by a sponsorship — only attributed.
        const PresentedBy(
          slot: BrandSlot.sponsoredMilestone,
          stage: BrandStage.parenting,
          placementKey: 'development_journey',
          padding: EdgeInsets.only(top: 8),
        ),
        const SizedBox(height: 14),
        Row(children: [
          _snap(Icons.celebration_outlined, 'Just celebrated', recent?.title ?? 'Your first memory awaits'),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _snap(Icons.spa_outlined, 'Emerging now', '${_store.emerging.length} ${_store.emerging.length == 1 ? 'skill' : 'skills'} to watch'),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(_store.encouragement, style: ppBody(13.5, color: Colors.white, h: 1.5, w: FontWeight.w600))),
          ]),
        ),
      ]),
    );
  }

  Widget _snap(IconData icon, String label, String value) => Expanded(
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: ppHair)),
            child: Icon(icon, size: 16, color: ppPurple),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(value, style: ppJakarta(14), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      );

  // ---- domain explorer ----------------------------------------------------
  Widget _domainRow() => SizedBox(
        height: 96,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            for (final d in DevDomain.values) ...[
              _domainTile(d),
              if (d != DevDomain.values.last) const SizedBox(width: 12),
            ],
          ],
        ),
      );

  Widget _domainTile(DevDomain d) {
    final meta = kDomainMeta[d]!;
    return GestureDetector(
      onTap: () => _openDomainSheet(d),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(11)),
            child: Icon(meta.icon, size: 18, color: meta.ink),
          ),
          Flexible(child: Text(meta.short, style: ppJakarta(12.5), maxLines: 2, overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  // ---- milestone card -----------------------------------------------------
  Widget _card(Milestone m) {
    final meta = kDomainMeta[m.domain]!;
    final observed = _store.isObserved(m.id);
    return GestureDetector(
      onTap: () => _openDetail(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x0F6A30B6), blurRadius: 18, spreadRadius: -14, offset: Offset(0, 8))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(12)),
              child: Icon(meta.icon, size: 19, color: meta.ink),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title, style: ppJakarta(15), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${meta.label} · ${m.ageRangeLabel}', style: ppBody(11.5, color: ppMuted)),
              ]),
            ),
          ]),
          const SizedBox(height: 12),
          Text(m.desc, style: ppBody(13, h: 1.55), maxLines: 3, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 14),
          if (observed)
            Row(children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: ppPurple),
              const SizedBox(width: 8),
              Text('Noticed ${_obsDateLabel(m.id)}', style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
              const Spacer(),
              Text('Details →', style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
            ])
          else
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openObserveSheet(m),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(12)),
                    child: Text("I've seen this", style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _openDetail(m),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
                  child: Text('Learn more', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                ),
              ),
            ]),
        ]),
      ),
    );
  }

  /* ⚠️ KEPT FOR REVERT — used only by the commented-out
     "Recently celebrated" block above. Commented rather than deleted so restoring
     that section does not mean rewriting this too.

  Widget _achievedRow(Milestone m) {
    final meta = kDomainMeta[m.domain]!;
    return GestureDetector(
      onTap: () => _openDetail(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(11)),
            child: Icon(meta.icon, size: 17, color: meta.ink),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: ppJakarta(13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(_obsSubtitle(m.id), style: ppBody(11.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const Icon(Icons.check_circle_rounded, size: 20, color: ppPurple),
        ]),
      ),
    );
  }
  */

  /// A settled row: the domain colour as a bar, the window, and an empty
  /// circle rather than an empty checkbox — a checkbox asks to be completed;
  /// a circle simply is not filled yet. Tapping it opens the same memory
  /// sheet as the flip-cards, so one dataset is written from every row.
  Widget _settledRow(Milestone m) {
    final meta = kDomainMeta[m.domain]!;
    final ticked = _store.isObserved(m.id);
    return GestureDetector(
      onTap: () => ticked ? _openDetail(m) : _openObserveSheet(m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(15, 13, 14, 13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Row(children: [
          Container(width: 4, height: 34, decoration: BoxDecoration(color: meta.ink, borderRadius: BorderRadius.circular(99))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
              const SizedBox(height: 3),
              Text('${meta.label} · usually ${m.ageRangeLabel.replaceFirst('Typically ', '')}', style: ppBody(11.5, color: ppMuted)),
            ]),
          ),
          const SizedBox(width: 10),
          Icon(ticked ? Icons.check_circle_rounded : Icons.circle_outlined, size: 19, color: ticked ? ppPurple : ppBorder),
        ]),
      ),
    );
  }

  Widget _soonRow(Milestone m) {
    final meta = kDomainMeta[m.domain]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
      child: Row(children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(11)),
          child: Icon(meta.icon, size: 17, color: meta.ink),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('You may begin noticing…', style: ppBody(10.5, color: ppMuted, w: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(m.title, style: ppJakarta(13.5), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        Text(m.ageRangeLabel.replaceFirst('Typically ', ''), style: ppBody(11, color: ppMuted)),
      ]),
    );
  }

  // ---- domain sheet -------------------------------------------------------
  void _openDomainSheet(DevDomain d) {
    final meta = kDomainMeta[d]!;
    final items = _store.inDomain(d);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.5,
        maxChildSize: 0.94,
        expand: false,
        builder: (ctx, sc) => Container(
          decoration: const BoxDecoration(color: ppBg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(13)),
                  child: Icon(meta.icon, size: 21, color: meta.ink),
                ),
                const SizedBox(width: 13),
                Expanded(child: Text(meta.label, style: ppFraunces(23, h: 1.1))),
              ]),
              const SizedBox(height: 16),
              for (final m in items) _card(m),
              // ---- the closer look: this area's own page ----------------
              const SizedBox(height: 6),
              _lookCloser(ctx, d),
            ],
          ),
        ),
      ),
    );
  }

  /// The way from a domain's milestones into its area page — the skills
  /// timeline and the Try-together / Watch / Learn rails. Replaces the
  /// hub's four tiles as the front of the section.
  Widget _lookCloser(BuildContext ctx, DevDomain d) {
    final area = devAreaById(_kAreaForDomain[d]!);
    return GestureDetector(
      onTap: () {
        Navigator.of(ctx).pop();
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DevelopmentAreaScreen(area: area)));
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Look closer at ${area.name.toLowerCase()}', style: ppJakarta(14)),
              const SizedBox(height: 3),
              Text('His skills in this area, what is coming, and small things that help.', style: ppBody(12, color: ppMuted, h: 1.4)),
            ]),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }

  // ---- milestone detail sheet ---------------------------------------------
  void _openDetail(Milestone m) {
    final meta = kDomainMeta[m.domain]!;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, sc) => AnimatedBuilder(
          animation: _store,
          builder: (ctx, _) {
            final observed = _store.isObserved(m.id);
            return Container(
              decoration: const BoxDecoration(color: ppBg, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
                children: [
                  Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
                  const SizedBox(height: 16),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: meta.tint, borderRadius: BorderRadius.circular(999)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(meta.icon, size: 13, color: meta.ink),
                        const SizedBox(width: 6),
                        Text(meta.label, style: ppBody(10.5, color: meta.ink, w: FontWeight.w800)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(m.ageRangeLabel, textAlign: TextAlign.right, style: ppBody(11.5, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 14),
                  Text(m.title, style: ppFraunces(25, h: 1.15)),
                  const SizedBox(height: 14),
                  Text(m.desc, style: ppBody(14.5, color: ppInk, h: 1.6)),
                  const SizedBox(height: 20),
                  _detailBlock('Why it matters', m.why),
                  _detailBlock('Ways to encourage it', null, bullets: m.encourage),
                  _detailBlock('Common variations', m.variation),
                  _detailBlock('When it might be worth a chat', m.discuss, soft: true),
                  const SizedBox(height: 8),
                  ppLearnRow(ctx, 'Related read: how ${meta.short.toLowerCase()} skills develop', top: true, bottom: true),
                  const SizedBox(height: 20),
                  if (observed)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                      child: Row(children: [
                        const Icon(Icons.check_circle_rounded, size: 20, color: ppPurple),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_obsSubtitle(m.id), style: ppBody(13, color: ppInk, h: 1.4))),
                        GestureDetector(
                          onTap: () => _store.unobserve(m.id),
                          behavior: HitTestBehavior.opaque,
                          child: Text('Undo', style: ppBody(12.5, color: ppMuted, w: FontWeight.w700)),
                        ),
                      ]),
                    )
                  else
                    ppLogButton("I've seen this", () {
                      Navigator.of(ctx).pop();
                      _openObserveSheet(m);
                    }, icon: Icons.check_rounded),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _detailBlock(String title, String? body, {List<String>? bullets, bool soft = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: ppJakarta(15, color: soft ? ppSoft : ppTitleInk)),
          const SizedBox(height: 8),
          if (body != null) Text(body, style: ppBody(13.5, color: soft ? ppSoft : ppInk, h: 1.6)),
          if (bullets != null)
            for (final b in bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(margin: const EdgeInsets.only(top: 8), width: 5, height: 5, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(b, style: ppBody(13.5, color: ppInk, h: 1.55))),
                ]),
              ),
        ]),
      );

  // ---- observe (mark as seen) sheet ---------------------------------------
  void _openObserveSheet(Milestone m) {
    final note = TextEditingController();
    ppLogSheet(
      context,
      title: '“${m.title}” — lovely!',
      saveLabel: 'Keep this memory',
      body: (setSheet) => [
        Text('Mark this as observed and, if you like, add a little note to turn it into a memory.', style: ppBody(13, h: 1.55)),
        const SizedBox(height: 16),
        ppToolTextField(note, 'A note (optional)', maxLines: 3),
      ],
      onSave: () => _store.markObserved(m.id, note: note.text.trim().isEmpty ? null : note.text.trim()),
    );
  }

  // ---- helpers ------------------------------------------------------------
  /* ⚠️ KEPT FOR REVERT — used only by the commented-out
     "Development insight" block above. Commented rather than deleted so restoring
     that section does not mean rewriting this too.

  String _insight() {
    final e = _store.emerging.length;
    final name = _store.name;
    if (_store.recentlyAchieved != null && e > 0) {
      return '$name recently reached a lovely milestone, and $e more ${e == 1 ? 'skill is' : 'skills are'} on the horizon. Development often comes in bursts, then pauses — both are healthy.';
    }
    if (e > 0) {
      return 'Several skills are emerging together around now. Following $name\'s lead in play does more for development than any drill.';
    }
    return 'A calmer developmental stretch. These pauses let new skills consolidate — there is nothing to push.';
  }
  */

  String _obsDateLabel(String id) {
    final o = _store.observation(id);
    if (o == null) return '';
    return ppShortDate(o.date);
  }

  String _obsSubtitle(String id) {
    final o = _store.observation(id);
    if (o == null) return '';
    final when = 'Noticed ${ppShortDate(o.date)}';
    return o.note != null ? '$when · ${o.note}' : when;
  }
}

/// A milestone card that turns over.
///
/// ⚠️ THE FLIP IS THE FEEDBACK, AND IT EARNS ITS KEEP RATHER THAN DECORATING.
/// "Show on card the milestone name, image and time when it should be
/// achieved/emerging like range, and as user clicks it flips with details
/// about it."
///
/// The old card showed the title, the range AND three lines of description at
/// once, then offered "Learn more" for the rest. So the front was already
/// half-detail, which made a column of them long and same-y. Splitting it puts
/// one glanceable thing per side: what and when in front, what it looks like
/// behind.
///
/// ⚠️ THE "I HAVE SEEN THIS" CONTROL DOES NOT FLIP WITH THE CARD. It sits under
/// the turning face, visible on both sides, because it is the action a parent
/// arrives wanting and hiding it behind a flip would cost more than the
/// animation gains. The feedback asks for it "below the card", which is also
/// simply correct.
///
/// ⚠️ `Matrix4.rotationY` NEEDS A PERSPECTIVE ENTRY, AND THE BACK FACE HAS TO
/// BE COUNTER-ROTATED. Without `..setEntry(3, 2, 0.0012)` the card scales
/// instead of turning; without handling the back separately its content renders
/// mirrored, which reads as a rendering bug rather than as a card.
class MilestoneFlipCard extends StatefulWidget {
  const MilestoneFlipCard({
    super.key,
    required this.milestone,
    required this.observed,
    required this.onSeen,
    required this.onDetail,
    this.observedLabel,
  });

  final Milestone milestone;
  final bool observed;
  final String? observedLabel;
  final VoidCallback onSeen;
  final VoidCallback onDetail;

  @override
  State<MilestoneFlipCard> createState() => _MilestoneFlipCardState();
}

class _MilestoneFlipCardState extends State<MilestoneFlipCard> {
  bool _back = false;

  @override
  Widget build(BuildContext context) {
    final meta = kDomainMeta[widget.milestone.domain]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ppHair),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F6A30B6),
              blurRadius: 18,
              spreadRadius: -14,
              offset: Offset(0, 8)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _back = !_back),
          behavior: HitTestBehavior.opaque,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 420),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, anim) {
              final isBack = child.key == const ValueKey('back');
              return AnimatedBuilder(
                animation: anim,
                builder: (context, _) {
                  final t = isBack ? (1 - anim.value) : -(1 - anim.value);
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0012)
                      ..rotateY(t * 3.14159 / 2),
                    child: child,
                  );
                },
              );
            },
            child: _face(
                _back ? const ValueKey('back') : const ValueKey('front'), meta,
                back: _back),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
          child: widget.observed ? _noticed() : _seenButton(),
        ),
      ]),
    );
  }

  Widget _noticed() => Row(children: [
        const Icon(Icons.check_circle_rounded, size: 18, color: ppPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
              widget.observedLabel == null
                  ? 'Noticed'
                  : 'Noticed ${widget.observedLabel}',
              style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
        ),
        GestureDetector(
          onTap: widget.onDetail,
          behavior: HitTestBehavior.opaque,
          child: Text('Details',
              style: ppBody(12, color: ppMuted, w: FontWeight.w600)),
        ),
      ]);

  // ⚠️ OPENS THE MEMORY SHEET, NOT A CHECKBOX. Feedback: "if user clicks on it
  // then open the memory you are opening to allow user to add memory".
  // `_openObserveSheet` already asks what she saw and keeps it with a date; a
  // tick that recorded only a boolean would throw away the one part she will
  // ever want to read again.
  Widget _seenButton() => GestureDetector(
        onTap: widget.onSeen,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: ppPurple, borderRadius: BorderRadius.circular(12)),
          child: Text('I have seen this',
              style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
        ),
      );

  Widget _face(Key key, DomainMeta meta, {required bool back}) {
    final m = widget.milestone;
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: back
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What this looks like',
                  style: ppBody(11, color: meta.ink, w: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(m.desc, style: ppBody(13.5, h: 1.55)),
              const SizedBox(height: 12),
              // ⚠️ `Flexible`, NOT A BARE `Text` + `Spacer`. The first version
              // overflowed by 2.5px at the narrow end — caught by a widget
              // test rather than by looking, which is the only way a 2.5px
              // overflow ever gets caught. Two fixed-width strings either side
              // of a Spacer have no give at all; letting the hint shrink does.
              Row(children: [
                Flexible(
                  child: Text('Tap to turn back',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ppBody(11.5, color: ppMuted)),
                ),
                const SizedBox(width: 10),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onDetail,
                  behavior: HitTestBehavior.opaque,
                  child: Text('Learn more',
                      style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                ),
              ]),
            ])
          : Row(children: [
              // ⚠️ THE DOMAIN WELL IS THE "IMAGE" UNTIL THERE IS ONE. The
              // feedback asks for a picture on the card. There is no milestone
              // art in the app, and a grey rectangle would be a placeholder
              // somebody has to delete later. A tinted well carrying the
              // domain's own mark is a finished treatment that a photograph
              // can replace without this widget changing.
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: meta.tint, borderRadius: BorderRadius.circular(14)),
                child: Icon(meta.icon, size: 25, color: meta.ink),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(meta.label.toUpperCase(),
                          style:
                              ppBody(10, color: meta.ink, w: FontWeight.w800)),
                      const SizedBox(height: 5),
                      Text(m.title,
                          style: ppJakarta(15.5),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 5),
                      // Read "Usually Typically 1–3 months" on a phone; the
                      // label already carries its own word.
                      Text('Usually ${m.ageRangeLabel.replaceFirst('Typically ', '')}',
                          style: ppBody(12, color: ppMuted)),
                    ]),
              ),
              const Icon(Icons.flip_camera_android_outlined,
                  size: 16, color: ppMuted),
            ]),
    );
  }
}
