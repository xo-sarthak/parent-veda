// =============================================================================
//  LeapCalendarScreen - the whole leap journey, on a timeline
// -----------------------------------------------------------------------------
//  Reached from the Explore drawer. A horizontal, scrollable timeline of all ten
//  Wonder-Weeks leaps, centered on where the child is now: scroll left for the
//  leaps already behind him, right for those ahead - each with the real dates
//  (from his DOB) it runs. Below, a tappable list of every leap opens its full
//  definition (the same LeapDefinitionScreen used across the app).
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_leaps_data.dart';
import 'leap_definition_screen.dart';

const List<String> _kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _fmt(DateTime d) => '${d.day} ${_kMonths[d.month - 1]}';

class LeapCalendarScreen extends StatefulWidget {
  const LeapCalendarScreen({super.key});

  @override
  State<LeapCalendarScreen> createState() => _LeapCalendarScreenState();
}

class _LeapCalendarScreenState extends State<LeapCalendarScreen> {
  static const double _cardW = 168;
  static const double _gap = 12;
  final ScrollController _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    // Centre the timeline on the current leap once laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_sc.hasClients) return;
      final i = currentLeapIndex(ChildProfileStore.instance.ageInWeeks);
      final target = (i * (_cardW + _gap)) - 40;
      _sc.jumpTo(target.clamp(0.0, _sc.position.maxScrollExtent));
    });
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _open(Leap l) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LeapDefinitionScreen(leap: l)));

  @override
  Widget build(BuildContext context) {
    final child = ChildProfileStore.instance;
    final curIdx = currentLeapIndex(child.ageInWeeks);

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 44),
          children: [
            _pad(ppBack(context, 'Explore')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('The Wonder Weeks', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Leap calendar', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('Every mental leap of the first two years, mapped to ${child.name}\'s own dates. He is in ${kLeaps[curIdx].label} right now.',
                style: ppBody(14, h: 1.55))),

            // horizontal timeline
            const SizedBox(height: 22),
            SizedBox(
              height: 168,
              child: ListView.separated(
                controller: _sc,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: kLeaps.length,
                separatorBuilder: (_, _) => const SizedBox(width: _gap),
                itemBuilder: (_, i) => _timelineCard(kLeaps[i], i, curIdx),
              ),
            ),

            // full list
            const SizedBox(height: 30),
            _pad(Text('All leaps', style: ppJakarta(17))),
            const SizedBox(height: 6),
            _pad(Text('Tap any leap to read what it means.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(Column(children: [
              for (int i = 0; i < kLeaps.length; i++) _listRow(kLeaps[i], i, curIdx),
            ])),

            const SizedBox(height: 24),
            _pad(Text("Timings are approximate - every baby's leaps arrive a week or two either side.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
          ],
        ),
      ),
    );
  }

  Widget _timelineCard(Leap l, int i, int curIdx) {
    final child = ChildProfileStore.instance;
    final past = i < curIdx;
    final now = i == curIdx;
    final start = l.startDate(child.dob);
    final end = l.endDate(child.dob);
    final a = l.accent;
    return GestureDetector(
      onTap: () => _open(l),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: _cardW,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: now ? a : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: now ? a : ppHair),
          boxShadow: now ? [BoxShadow(color: a.withValues(alpha: 0.35), blurRadius: 22, spreadRadius: -10, offset: const Offset(0, 10))] : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(l.label, style: ppJakarta(15, color: now ? Colors.white : ppInk)),
            const Spacer(),
            if (now)
              Text('NOW', style: ppBody(9.5, color: Colors.white, w: FontWeight.w800).copyWith(letterSpacing: 0.8))
            else if (past)
              const Icon(Icons.check_rounded, size: 15, color: ppMuted),
          ]),
          const SizedBox(height: 6),
          Text(l.name, style: ppBody(12.5, color: now ? Colors.white.withValues(alpha: 0.95) : ppSoft, w: FontWeight.w600, h: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text('${_fmt(start)} – ${_fmt(end)}', style: ppBody(11.5, color: now ? Colors.white.withValues(alpha: 0.9) : ppMuted, w: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(l.character, style: ppBody(10.5, color: now ? Colors.white.withValues(alpha: 0.8) : (past ? ppMuted : a), w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ),
    );
  }

  Widget _listRow(Leap l, int i, int curIdx) {
    final child = ChildProfileStore.instance;
    final now = i == curIdx;
    final past = i < curIdx;
    final start = l.startDate(child.dob);
    final end = l.endDate(child.dob);
    final a = l.accent;
    return GestureDetector(
      onTap: () => _open(l),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: now ? a.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: now ? a.withValues(alpha: 0.4) : ppHair),
        ),
        child: Row(children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: now ? a : a.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Text('${l.number}', style: ppJakarta(16, color: now ? Colors.white : a)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(l.name, style: ppBody(14.5, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (now) ...[
                  const SizedBox(width: 8),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: a, borderRadius: BorderRadius.circular(999)), child: Text('NOW', style: ppBody(9, color: Colors.white, w: FontWeight.w800))),
                ],
              ]),
              const SizedBox(height: 3),
              Text('${_fmt(start)} – ${_fmt(end)}  ·  ${past ? 'behind him' : now ? 'happening now' : 'ahead'}',
                  style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
        ]),
      ),
    );
  }
}
