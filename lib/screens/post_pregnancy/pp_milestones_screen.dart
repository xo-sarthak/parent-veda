// =============================================================================
//  Milestones - one place per child, and saving one is a moment
//  (R10, STAGE-TRANSITIONS, built 2026-10-26)
// -----------------------------------------------------------------------------
//  The user (2026-10-25): "we need to be very specific with milestones as an
//  individual section page screen ... right now its hidden also the naming is
//  also not correct like a checklist ... display it as an individial tht
//  parents can easily access and we keep UI UX considring the human
//  psychology tht its a milestone!!"
//
//  Approved prototype: claude.ai/artifact/QGDv1tigpwXAg7PTrZpyHj, phones 2
//  and 3. Decided 2026-10-25/26: the way in is a row under Today on the
//  child's home; the journal's "A first" is this save; the name is
//  "Milestones" and only that (10-26); a parent may save one of her own.
//
//  ⚠️ ONE LIST, ONE STORE (DV2). Everything here reads `MilestoneStore` and
//  the `kMilestones` catalogue, whose ids are the ones already saved on
//  phones and in `pp_milestone_observations`. The other lists (the area
//  stages, the phase snapshots, the Development Map) point at these ids, so
//  a milestone saved anywhere is saved once.
//
//  ⚠️ WORDS. "Might appear soon", never "overdue"; a Seen count per area,
//  never "3 of 7"; nothing to tick. A milestone she has not saved is not one
//  her child has missed, and the page says so.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/pp_use_consent.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress, pvCommitFeedback;
import '../../widgets/storage_image.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, pvStorePalette;
import '../v2/pv_celebration.dart';
import 'development_all_activities_screen.dart';
import 'journal_v2/jv2_store.dart';
import 'phase_map_screen.dart' show PhasePainting;
import 'pp_care_parts.dart' show ppCareHeading, ppCareSaved;
import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_milestones_data.dart';
import 'pp_phases_data.dart' show currentPhase, ppFillChild;
import 'pp_pick_photo.dart';
import 'pp_tools_kit.dart' show ppShortDate, ppToolTextField;
import 'pp_use_ask_card.dart';
import 'health_doctor_visit_screen.dart';
import '../v2/pv_moment_paintings.dart';

/// The route name of the moment page after a save, so a test or the last-
/// profile observer can tell it apart from the stage-move celebration.
const String kPpMilestoneMomentRoute = 'pp/milestone_moment';

/// Which DevArea page holds a domain's play ideas (was the journey's hand
/// map, `_kAreaForDomain`; kept identical).
const Map<DevDomain, String> kMsActivitiesArea = {
  DevDomain.cognitive: 'cognitive',
  DevDomain.grossMotor: 'gross_motor',
  DevDomain.fineMotor: 'fine_motor',
  DevDomain.language: 'language',
  DevDomain.social: 'emotional',
  DevDomain.selfCare: 'selfcare',
};

class PpMilestonesScreen extends StatefulWidget {
  const PpMilestonesScreen({super.key, this.startSave = false});

  /// Opened from the journal's "A milestone": the save picker opens at once.
  final bool startSave;

  @override
  State<PpMilestonesScreen> createState() => _PpMilestonesScreenState();
}

class _PpMilestonesScreenState extends State<PpMilestonesScreen> {
  final _store = MilestoneStore.instance;
  MsArea? _area; // null = All
  bool _showEarlier = false;

  @override
  void initState() {
    super.initState();
    if (widget.startSave) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) openMilestonePicker(context);
      });
    }
  }

  bool _inArea(DevDomain d) => _area == null || msAreaOf(d) == _area;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    Widget lead(String t, {Key? key}) =>
        pregToolPad(Text(t, key: key, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)));
    return AnimatedBuilder(
      animation: Listenable.merge([_store, ChildProfileStore.instance]),
      builder: (context, _) {
        final kid = ChildProfileStore.instance;
        final seen = _store.seen.where((s) => _area == null ? true : s.area == _area).toList();
        // Might appear soon: what is in its window now and not yet saved,
        // then the soft look ahead, at most six in all.
        final soon = <Milestone>[
          ..._store.emerging.where((m) => _inArea(m.domain)),
          ..._store.comingSoon.where((m) => _inArea(m.domain)),
        ].take(6).toList();
        final earlier = _store.foundations.where((m) => _inArea(m.domain)).toList();
        return PregToolScaffold(
          hue: 28,
          eyebrow: 'Development',
          mark: IntentMark.stepsMark,
          title: 'Milestones',
          intro: ppFillChild('Every child takes their own time. Save one when you see it; nothing here is a test.'),
          children: [
            pregToolPad(PvCommit(
              key: const ValueKey('pp_milestone_log'),
              label: 'I saw something new',
              onTap: () => openMilestonePicker(context),
            )),
            const SizedBox(height: 18),
            _chips(p),
            // Ask once, after the first milestone she keeps (tools pass D3).
            if (_store.observedCount > 0) ...[
              const SizedBox(height: 16),
              pregToolPad(const PpUseAskCard(
                kind: PpUseKind.development,
                question: 'Add the milestones you see to Before you see the doctor?',
              )),
            ],
            const SizedBox(height: 24),
            pregToolPad(ppCareHeading('Seen so far · ${_store.seenIn(_area)}')),
            const SizedBox(height: 12),
            if (seen.isEmpty)
              lead(
                  _area == null
                      ? ppFillChild('None saved yet. When you see something new, save it here with its day, '
                          'and a photo if you like.')
                      : 'None saved here yet. When you see one, it lands here.',
                  key: const ValueKey('pp_milestones_seen_empty'))
            else
              pregToolPad(_grid(seen, kid)),
            const SizedBox(height: 26),
            pregToolPad(ppCareHeading('Might appear soon')),
            const SizedBox(height: 6),
            lead('Often seen around ${kid.ageLabelWithCorrection}. A window, never a deadline.'),
            const SizedBox(height: 8),
            if (soon.isEmpty)
              lead('Nothing new expected here for a while. What is above keeps growing with play and talk.')
            else
              pregToolPad(Column(children: [for (final m in soon) _soonRow(m, p)])),
            if (earlier.isNotEmpty) ...[
              const SizedBox(height: 22),
              pregToolPad(PvPress(child: GestureDetector(
                key: const ValueKey('pp_milestones_earlier'),
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _showEarlier = !_showEarlier),
                child: Row(children: [
                  Expanded(child: ppCareHeading('Earlier milestones')),
                  Text(_showEarlier ? 'Hide' : 'Show ${earlier.length}',
                      style: ppBody(13, color: ppMuted, w: FontWeight.w700)),
                ]),
              ))),
              if (_showEarlier) ...[
                const SizedBox(height: 6),
                lead('Most children have these by now, and some arrive later and still arrive. '
                    'If you saw one, save it with its day.'),
                const SizedBox(height: 8),
                pregToolPad(Column(children: [for (final m in earlier) _soonRow(m, p)])),
              ],
            ],
            const SizedBox(height: 22),
            pregToolPad(PvPress(child: GestureDetector(
              key: const ValueKey('pp_milestone_own'),
              behavior: HitTestBehavior.opaque,
              onTap: () => openMilestoneSave(context, own: true),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
                child: Text('Save one of your own',
                    style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
            ))),
            const SizedBox(height: 22),
            pregToolPad(_closing(p)),
          ],
        );
      },
    );
  }

  Widget _chips(dynamic p) {
    Widget chip(MsArea? a) {
      final on = _area == a;
      final n = _store.seenIn(a);
      final label = a == null ? 'All' : kMsAreaLabel[a]!;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: PvPress(child: GestureDetector(
          key: ValueKey('pp_ms_area_${a?.name ?? 'all'}'),
          onTap: () => setState(() => _area = a),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: on ? ppInk : Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: on ? ppInk : ppLine),
            ),
            // The Seen count per area: a count of what she saw, never a
            // score (no "of N", no bar).
            child: Text(n > 0 ? '$label · $n' : label,
                style: ppBody(13, color: on ? Colors.white : ppMuted, w: FontWeight.w700)),
          ),
        )),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [chip(null), for (final a in MsArea.values) chip(a)]),
    );
  }

  Widget _grid(List<SeenMilestone> seen, ChildProfileStore kid) {
    return LayoutBuilder(builder: (context, box) {
      final w = (box.maxWidth - 10) / 2;
      return Wrap(spacing: 10, runSpacing: 10, children: [
        for (final s in seen)
          SizedBox(width: w, child: MilestoneSeenCard(seen: s, onTap: () => openMilestoneSave(context, milestoneId: s.id))),
      ]);
    });
  }

  Widget _soonRow(Milestone m, dynamic p) {
    return InkWell(
      key: ValueKey('pp_ms_soon_${m.id}'),
      onTap: () => _openDetail(m),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppLine))),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(m.title, style: ppBody(14.5, color: ppInk, w: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(msWindowLabel(m), style: ppBody(12.5, color: ppMuted, h: 1.35)),
            ]),
          ),
          const SizedBox(width: 10),
          PvPress(child: GestureDetector(
            key: ValueKey('pp_ms_saw_${m.id}'),
            onTap: () => openMilestoneSave(context, milestoneId: m.id),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: ppLine)),
              child: Text('I saw it', style: ppBody(12.5, color: ppInk, w: FontWeight.w800)),
            ),
          )),
        ]),
      ),
    );
  }

  Widget _closing(dynamic p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ppLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Was the journey's "A row you have not ticked is not a row he has
        // missed" (R10 renamed the checklist words).
        Text(
            ppFillChild('A milestone you have not saved is not one he has missed. If a skill he had has gone away, '
                'or something has felt off for a while, that is worth mentioning to your paediatrician, not '
                'because of anything on this page, but because you noticed it.'),
            style: ppBody(13.5, color: ppInk, h: 1.55)),
        const SizedBox(height: 10),
        // D3: the doctor visit page stays, one tap from here.
        PvPress(child: GestureDetector(
          key: const ValueKey('pp_milestones_to_doctor'),
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'pp_doctor_visit'),
              builder: (_) => const HealthDoctorVisitScreen())),
          child: Text(ppFillChild('Note it for his doctor  →'),
              style: ppBody(13.5, color: ppInk, w: FontWeight.w800)),
        )),
        const SizedBox(height: 10),
        Text('This is not a diagnosis or a test. The age windows are typical ranges, and your doctor knows your child best.',
            key: const ValueKey('pp_milestones_not_a_diagnosis'),
            style: ppBody(12.5, color: ppMuted, h: 1.45)),
      ]),
    );
  }

  void _openDetail(Milestone m) => openMilestoneDetail(context, m);
}

/// "Often between 6 and 9 months" (a window, never a due date).
String msWindowLabel(Milestone m) => m.loMonths == 0
    ? 'Often in the first ${m.hiMonths} months'
    : 'Often between ${m.loMonths} and ${m.hiMonths} months';

/// Whole months from [dob] to [d], never below zero.
int msMonthsAt(DateTime dob, DateTime d) {
  var m = (d.year - dob.year) * 12 + d.month - dob.month;
  if (d.day < dob.day) m -= 1;
  return m < 0 ? 0 : m;
}

String msAgeWords(int months) {
  if (months < 1) return 'in the first weeks';
  if (months < 24) return 'at $months ${months == 1 ? 'month' : 'months'}';
  final y = months ~/ 12;
  return 'at $y years';
}

/// One saved milestone as a card: its photo (or a soft tint), the title, the
/// day and the age.
class MilestoneSeenCard extends StatelessWidget {
  const MilestoneSeenCard({super.key, required this.seen, required this.onTap});
  final SeenMilestone seen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = seen.domain == null ? null : kDomainMeta[seen.domain!];
    final dob = ChildProfileStore.instance.dob;
    final months = msMonthsAt(dob, seen.obs.date);
    final ph = seen.obs.photo;
    return PvPress(child: GestureDetector(
      key: ValueKey('pp_ms_seen_${seen.id}'),
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppLine),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(
            aspectRatio: 1 / 0.78,
            child: ph != null && ph.isNotEmpty
                ? StorageImage(ph)
                : Container(
                    color: meta?.tint ?? ppPanel,
                    alignment: Alignment.center,
                    child: Icon(meta?.icon ?? Icons.auto_awesome_outlined, size: 28, color: meta?.ink ?? ppMuted),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(seen.title, maxLines: 3, style: ppBody(13.5, color: ppInk, w: FontWeight.w700, h: 1.3)),
              const SizedBox(height: 2),
              Text('${ppShortDate(seen.obs.date)} · ${msAgeWords(months).replaceFirst('at ', '')}',
                  style: ppBody(11.5, color: ppMuted)),
            ]),
          ),
        ]),
      ),
    ));
  }
}

// ---- detail ------------------------------------------------------------------

/// What to look for, why it matters, ways to help, and the save.
void openMilestoneDetail(BuildContext context, Milestone m) {
  final store = MilestoneStore.instance;
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, sc) => AnimatedBuilder(
        animation: store,
        builder: (ctx, _) {
          final obs = store.observation(m.id);
          Widget head(String t) => Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 6),
                child: Text(t.toUpperCase(),
                    style: ppBody(11, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 1.4)),
              );
          Widget body(String t) => Text(ppFillChild(t), style: ppBody(14, color: ppInk, h: 1.55));
          final area = devAreaIdFor(m.domain);
          return ListView(
            controller: sc,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            children: [
              Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 16),
              Text(m.title, style: pvFraunces(fontSize: 26, fontWeight: FontWeight.w500, color: ppInk, height: 1.15)),
              const SizedBox(height: 4),
              Text('${kMsAreaLabel[msAreaOf(m.domain)]} · ${msWindowLabel(m)}',
                  style: ppBody(13, color: ppMuted, w: FontWeight.w600)),
              const SizedBox(height: 16),
              PvCommit(
                key: const ValueKey('pp_ms_detail_save'),
                label: obs == null ? 'I saw it' : 'Seen ${ppShortDate(obs.date)} · Edit',
                onTap: () {
                  Navigator.of(ctx).pop();
                  openMilestoneSave(context, milestoneId: m.id);
                },
              ),
              head('What to look for'),
              body(m.desc),
              head('Why it matters'),
              body(m.why),
              head('Ways to help'),
              for (final e in m.encourage)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                        padding: EdgeInsets.only(top: 8, right: 10),
                        child: SizedBox(width: 5, height: 5, child: DecoratedBox(decoration: BoxDecoration(color: ppInk, shape: BoxShape.circle)))),
                    Expanded(child: body(e)),
                  ]),
                ),
              head('Every child'),
              body(m.variation),
              head('When to mention it'),
              body(m.discuss),
              const SizedBox(height: 18),
              PvPress(child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: RouteSettings(name: 'pp_activities/$area'),
                      builder: (_) => DevelopmentAllActivitiesScreen(area: area)));
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    Expanded(
                      child: Text('Play ideas for this, at this age',
                          style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
                  ]),
                ),
              )),
            ],
          );
        },
      ),
    ),
  );
}

String devAreaIdFor(DevDomain d) => kMsActivitiesArea[d]!;

// ---- the picker (from the journal and "I saw something new") -----------------

/// Pick which milestone she saw: what is in its window first, then every
/// other, then one of her own.
void openMilestonePicker(BuildContext context) {
  final store = MilestoneStore.instance;
  final search = TextEditingController();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
      final q = search.text.trim().toLowerCase();
      final near = {for (final m in [...store.inWindow, ...store.comingSoon]) m.id};
      final all = [
        ...kMilestones.where((m) => near.contains(m.id)),
        ...kMilestones.where((m) => !near.contains(m.id)),
      ].where((m) => q.isEmpty || m.title.toLowerCase().contains(q)).toList();
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.8,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 12),
            Center(
                child: Container(
                    width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: Text('What did you see?', style: ppJakarta(18)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextField(
                key: const ValueKey('pp_ms_picker_search'),
                controller: search,
                onChanged: (_) => setSheet(() {}),
                decoration: const InputDecoration(hintText: 'Search, or save one of your own below'),
              ),
            ),
            Expanded(
              child: ListView(padding: const EdgeInsets.fromLTRB(24, 6, 24, 24), children: [
                InkWell(
                  key: const ValueKey('pp_ms_picker_own'),
                  onTap: () {
                    final t = search.text.trim();
                    Navigator.of(ctx).pop();
                    openMilestoneSave(context, own: true, ownTitle: t.isEmpty ? null : t);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(children: [
                      const Icon(Icons.add_rounded, size: 20, color: ppInk),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(q.isEmpty ? 'Something else, in your words' : 'Save "${search.text.trim()}" as your own',
                            style: ppBody(14.5, color: ppInk, w: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ),
                for (final m in all)
                  InkWell(
                    key: ValueKey('pp_ms_pick_${m.id}'),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      openMilestoneSave(context, milestoneId: m.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppLine))),
                      child: Row(children: [
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(m.title, style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                            Text(msWindowLabel(m), style: ppBody(12, color: ppMuted)),
                          ]),
                        ),
                        if (store.isObserved(m.id))
                          Text('Seen ${ppShortDate(store.observation(m.id)!.date)}',
                              style: ppBody(12, color: ppMuted, w: FontWeight.w700)),
                      ]),
                    ),
                  ),
              ]),
            ),
          ]),
        ),
      );
    }),
  );
}

// ---- the one save --------------------------------------------------------------

/// The one way a milestone is saved, from every place that saves one: this
/// screen, the journal's "A milestone", the home, the area pages and the
/// month page (R10). [milestoneId] for one of ours or one already saved;
/// [own] for a new one of her own.
///
/// Saves to Milestones, and with "Also keep it in the journal" on (the
/// default) keeps one journal memory with it. A first save ends on the
/// moment page; an edit ends on a toast.
Future<void> openMilestoneSave(BuildContext context,
    {String? milestoneId, bool own = false, String? ownTitle}) async {
  assert(milestoneId != null || own);
  final store = MilestoneStore.instance;
  final kid = ChildProfileStore.instance;
  final m = milestoneId == null ? null : store.find(milestoneId);
  final had = milestoneId == null ? null : store.observation(milestoneId);
  final isOwn = m == null;
  final titleCtl = TextEditingController(text: had?.title ?? ownTitle ?? '');
  final noteCtl = TextEditingController(text: had?.note ?? '');
  var when = had?.date ?? DateTime.now();
  String? picked; // a new photo's temporary path
  var keepPhoto = had?.photo; // the one already saved, until she removes it
  var toJournal = true;

  final saved = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: ppBg,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
    builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
      final hasPhoto = picked != null || (keepPhoto != null && keepPhoto!.isNotEmpty);
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(
                  child: Container(
                      width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text(isOwn ? (had == null ? 'A milestone of your own' : (had.title ?? 'A milestone')) : m.title,
                  style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: ppInk, height: 1.2)),
              const SizedBox(height: 4),
              Text('The date, a photo and a line are all optional.', style: ppBody(13, color: ppMuted, h: 1.45)),
              const SizedBox(height: 14),
              if (isOwn) ...[
                TextField(
                  key: const ValueKey('pp_ms_save_title'),
                  controller: titleCtl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(labelText: 'What happened', hintText: 'First time at Nani\'s'),
                  onChanged: (_) => setSheet(() {}),
                ),
                const SizedBox(height: 12),
              ],
              // The photo: tap to add, tap again to remove.
              PvPress(child: GestureDetector(
                key: const ValueKey('pp_ms_save_photo'),
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  if (hasPhoto) {
                    setSheet(() {
                      picked = null;
                      keepPhoto = null;
                    });
                    return;
                  }
                  final path = await ppPickPhoto(ctx);
                  if (path != null) setSheet(() => picked = path);
                },
                child: Container(
                  height: 110,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: hasPhoto ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: ppLine, width: 1.5),
                  ),
                  child: hasPhoto
                      ? Stack(fit: StackFit.expand, children: [
                          StorageImage(picked ?? keepPhoto!),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.88), borderRadius: BorderRadius.circular(999)),
                              child: Text('Photo added · tap to remove', style: ppBody(11.5, color: ppInk, w: FontWeight.w700)),
                            ),
                          ),
                        ])
                      : Center(child: Text('+ Add a photo', style: ppBody(13.5, color: ppMuted, w: FontWeight.w700))),
                ),
              )),
              const SizedBox(height: 10),
              InkWell(
                key: const ValueKey('pp_milestone_seen_on'),
                onTap: () async {
                  final now = DateTime.now();
                  final dob = kid.dob;
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: when,
                    firstDate: dob.isAfter(now) ? now.subtract(const Duration(days: 1)) : dob,
                    lastDate: now,
                    helpText: 'When did you see it?',
                  );
                  if (d != null) setSheet(() => when = d);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [
                    Expanded(child: Text('When: ${_dayWord(when)}', style: ppBody(14, color: ppInk, w: FontWeight.w700))),
                    Text('Change', style: ppBody(13, color: ppMuted, w: FontWeight.w700)),
                  ]),
                ),
              ),
              ppToolTextField(noteCtl, 'A line (optional)', maxLines: 3),
              const SizedBox(height: 4),
              Row(children: [
                Expanded(child: Text('Also keep it in the journal', style: ppBody(14, color: ppInk, w: FontWeight.w700))),
                Switch(
                  key: const ValueKey('pp_ms_save_journal'),
                  value: toJournal,
                  onChanged: (v) => setSheet(() => toJournal = v),
                ),
              ]),
              const SizedBox(height: 12),
              PvCommit(
                key: const ValueKey('pp_ms_save'),
                label: had == null ? 'Save this milestone' : 'Save changes',
                onTap: isOwn && titleCtl.text.trim().isEmpty ? null : () => Navigator.of(ctx).pop(true),
              ),
              if (had != null) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton(
                    key: const ValueKey('pp_ms_remove'),
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text('Take it off Milestones', style: ppBody(13.5, color: ppMuted, w: FontWeight.w700)),
                  ),
                ),
              ],
            ]),
          ),
        ),
      );
    }),
  );
  if (!context.mounted || saved == null) return;

  // Remove (an existing one only). Undo puts back the same record.
  if (saved == false && had != null && milestoneId != null) {
    final name = isOwn ? (had.title ?? 'A milestone') : m.title;
    store.unobserve(milestoneId);
    final kept = PpJournalStore.instance.hasMilestone(milestoneId);
    ppCareSaved(context,
        kept ? '"$name" taken off Milestones. Its journal memory stays.' : '"$name" taken off Milestones.',
        undo: () => store.markObserved(milestoneId,
            date: had.date, note: had.note, photo: had.photo, title: had.title));
    return;
  }

  final note = noteCtl.text.trim().isEmpty ? null : noteCtl.text.trim();
  final photo = picked != null ? await MilestoneStore.savePhoto(picked!) : keepPhoto;
  final title = isOwn ? titleCtl.text.trim() : m.title;
  final String id;
  if (isOwn && milestoneId == null) {
    id = store.markOwn(title, date: when, note: note, photo: photo);
  } else {
    id = milestoneId!;
    store.markObserved(id, date: when, note: note, photo: photo, title: isOwn ? title : null);
  }
  if (toJournal) {
    await PpJournalStore.instance
        .keepMilestone(milestoneId: id, title: title, date: when, body: note ?? '', pickedPhotoPath: picked);
  }
  if (!context.mounted) return;

  if (had != null) {
    ppCareSaved(context, 'Saved: $title, ${_dayWord(when)}.');
    return;
  }
  final months = msMonthsAt(kid.dob, when);
  final childName = kid.nameMid;
  final changes = <String>[
    isOwn ? 'Saved to Milestones' : 'Saved to Milestones, under ${kMsAreaLabel[msAreaOf(m.domain)]}',
    photo != null ? 'With your photo' : 'You can add a photo any time',
    toJournal ? 'Kept in the journal too, as one memory' : 'Not added to the journal',
    if (PpUseConsent.instance.allows(PpUseKind.development)) 'Listed on the doctor visit page for the next check-up',
  ];
  pvCommitFeedback();
  await Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPpMilestoneMomentRoute),
    builder: (_) => PvCelebrationScreen(
      // The "a milestone" painting (prompt in docs/MOMENT-PAINTING-PROMPTS.md,
      // landed 2026-10-26); the child's phase painting is the fallback.
      // Its own painting once the file lands; the phase painting until then
      // (2026-10-26). Kept for revert: painting: PhasePainting(phase: currentPhase(kid)),
      painting: PvMomentPainting(moment: PvMoment.milestone, fallback: PhasePainting(phase: currentPhase(kid))),
      title: title,
      line: '${_longDate(when)}, ${msAgeWords(months)}. One for $childName\'s story.',
      changes: changes,
      primary: 'Back to Milestones',
      onPrimary: (c) => Navigator.of(c).pop(),
    ),
  ));
}

String _dayWord(DateTime d) {
  final now = DateTime.now();
  final day = DateTime(d.year, d.month, d.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  return diff == 0 ? 'today' : diff == 1 ? 'yesterday' : ppShortDate(d);
}

const _kMonthsLong = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
String _longDate(DateTime d) => '${d.day} ${_kMonthsLong[d.month - 1]}';
