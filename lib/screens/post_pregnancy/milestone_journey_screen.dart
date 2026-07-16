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
import 'pp_common.dart';
import 'pp_milestones_data.dart';
import 'pp_tools_kit.dart';

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
            final achieved = _store.achieved;
            final soon = _store.comingSoon;
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

                const SizedBox(height: 26),
                ppToolPad(ppSectionHead('Explore by area')),
                const SizedBox(height: 4),
                ppToolPad(Text('Development happens across all of these at once.', style: ppBody(13))),
                const SizedBox(height: 14),
                _domainRow(),

                const SizedBox(height: 28),
                ppToolPad(Row(children: [
                  const Icon(Icons.spa_outlined, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Emerging now', style: ppJakarta(17))),
                  Text('you may notice', style: ppBody(12, color: ppMuted)),
                ])),
                const SizedBox(height: 6),
                ppToolPad(Text('Skills that often blossom around ${ChildProfileStore.instance.ageLabel}.', style: ppBody(13))),
                const SizedBox(height: 14),
                if (emerging.isEmpty)
                  ppToolPad(ppEmptyCard(Icons.spa_outlined, 'A quiet stretch between leaps — a lovely time to simply enjoy each other. New skills will surface soon.'))
                else
                  ppToolPad(Column(children: [for (final m in emerging) _card(m)])),

                const SizedBox(height: 24),
                ppToolPad(ppInsightCard(_insight(), tag: 'Development insight')),

                const SizedBox(height: 26),
                ppToolPad(Row(children: [
                  const Icon(Icons.celebration_outlined, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Recently celebrated', style: ppJakarta(17))),
                  Text('${_store.observedCount} noticed', style: ppBody(12, color: ppMuted)),
                ])),
                const SizedBox(height: 14),
                if (achieved.isEmpty)
                  ppToolPad(ppEmptyCard(Icons.celebration_outlined, 'Nothing marked yet — and that is fine. When you notice something lovely, tap "I\'ve seen this" to keep it as a memory.'))
                else
                  ppToolPad(Column(children: [for (final m in achieved.take(4)) _achievedRow(m)])),

                const SizedBox(height: 26),
                ppToolPad(Row(children: [
                  const Icon(Icons.wb_twilight_rounded, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Coming soon', style: ppJakarta(17))),
                ])),
                const SizedBox(height: 6),
                ppToolPad(Text('A soft look ahead — you may begin noticing these in the months to come. Never a deadline.', style: ppBody(13))),
                const SizedBox(height: 14),
                ppToolPad(Column(children: [for (final m in soon.take(4)) _soonRow(m)])),

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
            ],
          ),
        ),
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
