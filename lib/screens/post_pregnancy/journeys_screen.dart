// =============================================================================
//  Guided journeys (parenting · Explore)
// -----------------------------------------------------------------------------
//  A path with a day 1 and a day 30 — distinct from the ambient trackers that
//  also carry the word "journey" in this app.
//
//  Deliberately soft mechanics: nothing locks, nothing is a streak, and leaving
//  costs one tap. A parent four days behind is not behind — the day counter
//  only ever suggests where to pick up.
// =============================================================================

import 'package:flutter/material.dart';

import '../../brand/brand_models.dart';
import '../../brand/presented_by.dart';
import 'pp_common.dart';
import 'pp_journeys_data.dart';

class JourneysScreen extends StatelessWidget {
  const JourneysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: JourneyStore.instance,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              _pad(ppBack(context, 'Explore')),
              const SizedBox(height: 16),
              _pad(ppEyebrow('Guided journeys', color: ppPurple)),
              const SizedBox(height: 10),
              _pad(Text('One short read at a time', style: ppFraunces(28, h: 1.12))),
              const SizedBox(height: 8),
              _pad(Text(
                'A path with a beginning and an end, for the stretches that are hard to walk alone. Self-paced — miss a week and nothing is lost.',
                style: ppBody(14, h: 1.55),
              )),
              const SizedBox(height: 22),
              for (final j in kJourneys) _pad(_card(context, j)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  Widget _card(BuildContext context, Journey j) {
    final store = JourneyStore.instance;
    final started = store.hasStarted(j.id);
    final prog = store.progress(j);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => JourneyDetailScreen(journey: j)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ppHair),
          boxShadow: ppCardShadow,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.route_rounded, size: 18, color: ppPurple),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(j.title, style: ppJakarta(17))),
          ]),
          const SizedBox(height: 12),
          Text(j.subtitle, style: ppBody(13, h: 1.5)),
          const SizedBox(height: 14),
          if (started) ...[
            _progressBar(prog),
            const SizedBox(height: 8),
            Text(
              '${store.doneCount(j.id)} of ${j.length} read · part ${store.suggestedDay(j)} suggested',
              style: ppBody(11.5, color: ppPurple, w: FontWeight.w700),
            ),
          ] else
            Text('${j.length} parts · read at your own pace', style: ppBody(11.5, color: ppMuted, w: FontWeight.w700)),
          // Renders nothing unless a campaign is live. The journey is ours
          // either way.
          PresentedBy(
            slot: BrandSlot.sponsoredJourney,
            stage: BrandStage.parenting,
            placementKey: j.id,
            padding: const EdgeInsets.only(top: 12),
          ),
        ]),
      ),
    );
  }
}

Widget _progressBar(double p) => ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: p.clamp(0.0, 1.0),
        minHeight: 6,
        backgroundColor: ppPanel,
        valueColor: const AlwaysStoppedAnimation<Color>(ppPurple),
      ),
    );

// =============================================================================
//  One journey — what it is, then every day
// =============================================================================
class JourneyDetailScreen extends StatelessWidget {
  const JourneyDetailScreen({super.key, required this.journey});
  final Journey journey;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final store = JourneyStore.instance;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final started = store.hasStarted(journey.id);
            final today = store.suggestedDay(journey);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Journeys')),
                const SizedBox(height: 16),
                _pad(ppEyebrow('${journey.length} parts', color: ppPurple)),
                const SizedBox(height: 10),
                _pad(Text(journey.title, style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 10),
                _pad(Text(journey.about, style: ppBody(14, h: 1.6))),
                _pad(PresentedBy(
                  slot: BrandSlot.sponsoredJourney,
                  stage: BrandStage.parenting,
                  placementKey: journey.id,
                  padding: const EdgeInsets.only(top: 14),
                )),
                if (journey.expertHookPresent) ...[
                  const SizedBox(height: 18),
                  _pad(_expert()),
                ],
                const SizedBox(height: 20),
                _pad(started ? _resume(context, today) : _startButton(context)),
                const SizedBox(height: 26),
                _pad(Text('Every day', style: ppJakarta(17))),
                const SizedBox(height: 12),
                for (final d in journey.days) _pad(_dayRow(context, d, today, started)),
                if (started) ...[
                  const SizedBox(height: 18),
                  _pad(Center(
                    child: TextButton(
                      onPressed: () => store.reset(journey.id),
                      child: Text('Leave this journey', style: ppBody(12.5, color: ppMuted, w: FontWeight.w700)),
                    ),
                  )),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _expert() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.verified_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 7),
            ppEyebrow('Who wrote this', color: ppPurple),
          ]),
          const SizedBox(height: 10),
          Text(journey.expertName, style: ppJakarta(14)),
          Text(journey.expertRole, style: ppBody(12)),
        ]),
      );

  Widget _startButton(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: ppPurple,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () {
            JourneyStore.instance.start(journey.id);
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => JourneyDayScreen(journey: journey, day: journey.dayAt(1))),
            );
          },
          child: Text('Start day 1', style: ppBody(14.5, color: Colors.white, w: FontWeight.w800)),
        ),
      );

  Widget _resume(BuildContext context, int today) => SizedBox(
        width: double.infinity,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: ppPurple,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => JourneyDayScreen(journey: journey, day: journey.dayAt(today))),
          ),
          child: Text('Read part $today', style: ppBody(14.5, color: Colors.white, w: FontWeight.w800)),
        ),
      );

  Widget _dayRow(BuildContext context, JourneyDay d, int today, bool started) {
    final store = JourneyStore.instance;
    final done = store.isDone(journey.id, d.day);
    final isToday = started && d.day == today;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Nothing is locked. A parent can read ahead, or go back, or dip in at
      // day 20 — the day number is a suggestion, never a gate.
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => JourneyDayScreen(journey: journey, day: d)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isToday ? ppPanel : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isToday ? ppPurple.withValues(alpha: 0.35) : ppHair),
        ),
        child: Row(children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? ppPurple : Colors.transparent,
              shape: BoxShape.circle,
              border: done ? null : Border.all(color: ppBorder, width: 1.5),
            ),
            child: done
                ? const Icon(Icons.check_rounded, size: 13, color: Colors.white)
                : Text('${d.day}', style: ppBody(11, color: ppSoft, w: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(d.title, style: ppJakarta(13.5), maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (isToday) ppEyebrow('Today', color: ppPurple, spacing: 0.8),
        ]),
      ),
    );
  }
}

// =============================================================================
//  One day
// =============================================================================
/// SWIPEABLE (18 Jul review). A parent working through a journey wants to move
/// straight to the next part, not go back out to the list and hunt for it. The
/// whole journey is one PageView: swipe left for the next part, right for the
/// previous, with arrows for anyone who does not think to swipe.
class JourneyDayScreen extends StatefulWidget {
  const JourneyDayScreen({super.key, required this.journey, required this.day});
  final Journey journey;
  final JourneyDay day;

  @override
  State<JourneyDayScreen> createState() => _JourneyDayScreenState();
}

class _JourneyDayScreenState extends State<JourneyDayScreen> {
  late final PageController _pc;
  late int _index;

  Journey get journey => widget.journey;

  @override
  void initState() {
    super.initState();
    _index = journey.days.indexWhere((d) => d.day == widget.day.day);
    if (_index < 0) _index = 0;
    _pc = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _go(int delta) {
    final next = _index + delta;
    if (next < 0 || next >= journey.days.length) return;
    _pc.animateToPage(next, duration: const Duration(milliseconds: 260), curve: Curves.easeOutCubic);
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pc,
          itemCount: journey.days.length,
          onPageChanged: (i) => setState(() => _index = i),
          itemBuilder: (context, i) => _page(context, journey.days[i]),
        ),
      ),
    );
  }

  Widget _page(BuildContext context, JourneyDay day) {
    final store = JourneyStore.instance;
    return AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final done = store.isDone(journey.id, day.day);
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, journey.title)),
                const SizedBox(height: 16),
                _pad(ppEyebrow('Part ${day.day} of ${journey.length}', color: ppPurple)),
                const SizedBox(height: 10),
                _pad(Text(day.title, style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 14),
                _pad(Text(day.body, style: ppBody(15.5, color: ppInk, h: 1.65))),
                const SizedBox(height: 22),
                _pad(_actionCard(day)),
                if (day.askSomeone.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _pad(_askCard(day)),
                ],
                const SizedBox(height: 24),
                _pad(_doneButton(day, done)),
                const SizedBox(height: 14),
                _pad(_pager()),
                const SizedBox(height: 18),
                _pad(Text(
                  'This is general information, not a diagnosis — your doctor or lactation consultant knows you and your baby.',
                  style: ppBody(11.5, color: ppMuted),
                )),
              ],
            );
          },
        );
  }

  /// Swipe hint + arrows. Swiping is the primary gesture; the arrows exist for
  /// anyone who would not think to try it.
  Widget _pager() => Row(children: [
        _arrow(Icons.arrow_back_rounded, 'Previous', _index > 0, () => _go(-1)),
        Expanded(
          child: Text('Part ${_index + 1} of ${journey.days.length}',
              textAlign: TextAlign.center,
              style: ppBody(12.5, color: ppMuted, w: FontWeight.w700)),
        ),
        _arrow(Icons.arrow_forward_rounded, 'Next', _index < journey.days.length - 1, () => _go(1)),
      ]);

  Widget _arrow(IconData icon, String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: on ? onTap : null,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: on ? ppPurple.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 19, color: on ? ppPurple : ppLine),
        ),
      );

  Widget _actionCard(JourneyDay day) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.spa_outlined, size: 15, color: ppPurple),
            const SizedBox(width: 7),
            ppEyebrow('Try this today', color: ppPurple),
          ]),
          const SizedBox(height: 10),
          Text(day.action, style: ppBody(14, color: ppInk, h: 1.55, w: FontWeight.w600)),
        ]),
      );

  /// The line that names a real human to call. Visually distinct from the rest
  /// on purpose — this is the one block on the page that must not blend in.
  Widget _askCard(JourneyDay day) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ppCoralTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppCoral.withValues(alpha: 0.28)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.call_outlined, size: 15, color: ppCoral),
            const SizedBox(width: 7),
            ppEyebrow('Ask someone', color: ppCoral),
          ]),
          const SizedBox(height: 10),
          Text(day.askSomeone, style: ppBody(13.5, color: ppInk, h: 1.55)),
        ]),
      );

  Widget _doneButton(JourneyDay day, bool done) => SizedBox(
        width: double.infinity,
        // Once read it goes GREEN with a tick. The old state said "Read", which
        // read as an instruction ("read this") rather than a status ("you have
        // read this") - the one word does both jobs and neither well.
        child: done
            ? OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF3E7A52),
                  backgroundColor: const Color(0xFFEDF5EE),
                  side: BorderSide(color: const Color(0xFF3E7A52).withValues(alpha: 0.4), width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => JourneyStore.instance.toggleDay(journey.id, day.day),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.check_circle_rounded, size: 17, color: Color(0xFF3E7A52)),
                  const SizedBox(width: 7),
                  Text("You've read this",
                      style: ppBody(14, color: const Color(0xFF3E7A52), w: FontWeight.w800)),
                ]),
              )
            : FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: ppPurple,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => JourneyStore.instance.toggleDay(journey.id, day.day),
                child: Text('Mark as read', style: ppBody(14.5, color: Colors.white, w: FontWeight.w800)),
              ),
      );
}
