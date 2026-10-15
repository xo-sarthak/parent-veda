// =============================================================================
//  PrenatalYogaScreen (S4) - Prepare › Yoga (interactive)
// -----------------------------------------------------------------------------
//  Renamed "Prenatal Yoga" -> "Yoga" in the UI. The screen now opens on the
//  mother's CURRENT pregnancy month and offers Month 1-9 tabs; each month lists
//  all of its sessions (see kYogaSessions, now month-tagged in prepare_data).
//  Sessions play into the placeholder video screen. The Dart class name is kept
//  (PrenatalYogaScreen) so existing imports/tests stay valid.
//
//  NOTE: the previous trimester-lock version (T1/T2 locked at 30 weeks) is
//  superseded by month tabs; its intent lives on as the "current month" default.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'prepare_common.dart';
import 'prepare_video_screen.dart';
import '../../localization/app_language.dart';
import '../post_pregnancy/pp_yoga_data.dart';
import '../post_pregnancy/yoga_class_screen.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

// TODO: derive the current pregnancy month from the saved due date / week.
// 30 weeks ≈ month 7, matching the rest of the Prepare tab's "Priya · 30 weeks".
const int _kCurrentMonth = 7;

class PrenatalYogaScreen extends StatefulWidget {
  const PrenatalYogaScreen({super.key, required this.lang});

  final AppLanguage lang;

  @override
  State<PrenatalYogaScreen> createState() => _PrenatalYogaScreenState();
}

class _PrenatalYogaScreenState extends State<PrenatalYogaScreen> {
  int _month = _kCurrentMonth;
  final ScrollController _tabs = ScrollController();

  @override
  void initState() {
    super.initState();
    // Bring the current month into view once the strip is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_tabs.hasClients) return;
      final target = ((_month - 1) * 92.0 - 40).clamp(0.0, _tabs.position.maxScrollExtent);
      _tabs.animateTo(target, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(widget.lang);
    final sessions = yogaSessionsForMonth(_month);
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            pvTopBar(context, lang: widget.lang, backLabel: s.uiPrepare),
            const SizedBox(height: 22),
            pvEyebrow(s.prepEyebrowMoveWithMonth),
            const SizedBox(height: 10),
            Text(s.uiYoga, style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text(s.uiTrimesterSafeMovementFeel,
                style: pvSubStyle()),
            pvBanner(icon: Icons.self_improvement_rounded, spans: [
              pvText(s.uiRe2),
              pvBold(s.prepMonthBold(_kCurrentMonth)),
              pvText(s.uiWeVeOpenedYoga),
            ]),

            // program card
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kBorder),
                boxShadow: pvCardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const PvStriped(height: 130),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // What this is, before anything else (2026-10-10, the
                    // user's note "no indication of it being a class/live"):
                    // these are follow-along videos, not a class with a
                    // teacher. The live classes have their own section below.
                    _kindTag(Icons.play_circle_outline_rounded, 'SELF-GUIDED VIDEOS'),
                    const SizedBox(height: 10),
                    Text(s.uiPregnancyYogaProgram, style: pvTitleStyle(18)),
                    const SizedBox(height: 6),
                    Text(s.uiMonthJourneySanaKapoor,
                        style: pvBody(kSoft, 13)),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: '₹599', style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                        const TextSpan(text: '  ·  ', style: TextStyle(color: kMuted)),
                        TextSpan(
                            text: s.prepFreeWithPlus,
                            style: const TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                      ]),
                      style: pvBody(kInk, 14),
                    ),
                  ]),
                ),
              ]),
            ),

            // month tabs
            const SizedBox(height: 22),
            Text(s.uiChooseMonth,
                style: pvBody(kSoft, 11).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                controller: _tabs,
                scrollDirection: Axis.horizontal,
                children: [for (int m = 1; m <= 9; m++) _monthTab(s, m)],
              ),
            ),

            const SizedBox(height: 20),
            Row(children: [
              Text(_month == _kCurrentMonth ? s.prepThisMonthForYou : s.prepMonthN(_month),
                  style: pvTitleStyle(16)),
              const Spacer(),
              Text(s.prepSessionCount(sessions.length), style: pvBody(kMuted, 12)),
            ]),
            const SizedBox(height: 6),

            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(s.uiSessionsMonthAreComing,
                    style: pvBody(kSoft, 14).copyWith(fontStyle: FontStyle.italic)),
              )
            else
              for (int i = 0; i < sessions.length; i++)
                _session(s, sessions[i], bottom: i == sessions.length - 1),

            // ---- live classes, with a teacher --------------------------------
            // The Move door's "Classes and tools" tab promised classes and
            // opened only videos. The live pregnancy classes already exist
            // (kYogaClasses, booked through YogaClassScreen); each says it is
            // live, how (group or 1:1) and when, from the class's own data.
            // Prices and seats stay on the booking page, decided server-side.
            if (_liveClasses.isNotEmpty) ...[
              const SizedBox(height: 28),
              Text('Live classes, with a teacher', style: pvTitleStyle(16)),
              const SizedBox(height: 4),
              Text('A real teacher, at a set time. Tap one to see times and book.',
                  style: pvBody(kSoft, 13)),
              const SizedBox(height: 6),
              for (int i = 0; i < _liveClasses.length; i++)
                _liveClass(_liveClasses[i], bottom: i == _liveClasses.length - 1),
            ],

            const SizedBox(height: 18),
            Text(s.uiEverySessionFilteredMonth,
                style: pvBody(kSoft, 13).copyWith(fontStyle: FontStyle.italic, height: 1.6)),
            pvFooterNote(s.prepFooterYoga),
          ],
        ),
      ),
    );
  }

  Widget _monthTab(S s, int m) {
    final active = m == _month;
    final isNow = m == _kCurrentMonth;
    return PvPress(child: GestureDetector(
      onTap: () => setState(() => _month = m),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? kPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: active ? kPurple : kBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(s.prepMonthN(m),
              style: pvBody(active ? Colors.white : kInk, 13)
                  .copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w600)),
          if (isNow) ...[
            const SizedBox(width: 6),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: active ? Colors.white : kCoral, borderRadius: BorderRadius.circular(99)),
            ),
          ],
        ]),
      ),
    ));
  }

  /// The pregnancy categories' live classes: prenatal yoga and labour breathing.
  static final List<YogaClass> _liveClasses = [
    for (final c in kYogaClasses)
      if (c.mode != YogaMode.recorded && (c.category == 'prenatal' || c.category == 'breathing')) c,
  ];

  /// A small boxed tag that says what a thing is, with its line icon.
  static Widget _kindTag(IconData icon, String label) => Container(
        padding: const EdgeInsets.fromLTRB(7, 3, 9, 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: kBorder),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: kInk),
          const SizedBox(width: 5),
          Text(label,
              style: pvBody(kInk, 10.5).copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        ]),
      );

  /// "Tue, Thu, Sat · 8am IST" - the class's own schedule without the
  /// leading "Live", which the tag already says.
  static String _when(YogaClass c) =>
      c.schedule.replaceFirst(RegExp(r'^Live\s*·\s*'), '');

  Widget _liveClass(YogaClass c, {bool bottom = false}) {
    final oneToOne = c.mode == YogaMode.liveOneToOne;
    return PvPress(child: GestureDetector(
      key: ValueKey('preg_yoga_live_${c.id}'),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'move/yoga/class/${c.id}'),
          builder: (_) => YogaClassScreen(cls: c))),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kHair),
            bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
            child: const Icon(Icons.videocam_outlined, size: 20, color: kInk),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _kindTag(oneToOne ? Icons.person_outline_rounded : Icons.groups_outlined,
                  oneToOne ? 'LIVE 1:1' : 'LIVE CLASS'),
              const SizedBox(height: 6),
              Text(c.title, style: pvBody(kInk, 15).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.schedule_rounded, size: 14, color: kMuted),
                const SizedBox(width: 5),
                Expanded(child: Text(_when(c), style: pvBody(kMuted, 12))),
              ]),
              const SizedBox(height: 2),
              Text('${c.durationLabel} · with ${c.instructorName}', style: pvBody(kMuted, 12)),
            ]),
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Icon(Icons.chevron_right_rounded, size: 20, color: kMuted),
          ),
        ]),
      ),
    ));
  }

  Widget _session(S s, YogaSession y, {bool bottom = false}) {
    return PvPress(child: GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PrepareVideoScreen(
              lang: widget.lang,
              title: y.title.now,
              subtitle: '${y.duration.now} · ${y.focus.now}',
              blurb: y.blurb.now))),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kHair),
            bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
            // A line icon in place of the '▸' glyph (2026-10-10), so a
            // session reads as a video to play. Kept for revert:
            // child: const Text('▸', style: TextStyle(color: kPurple, fontSize: 15)),
            child: const Icon(Icons.play_arrow_rounded, size: 20, color: kPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(y.title.now, style: pvBody(kInk, 15).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              // "Video" first, so a session never reads as a live class.
              // Kept for revert:
              // Text('${y.duration.now} · ${y.focus.now}', style: pvBody(kMuted, 12)),
              Text('Video · ${y.duration.now} · ${y.focus.now}', style: pvBody(kMuted, 12)),
            ]),
          ),
          const SizedBox(width: 10),
          pvPill(s.prepSafeForYou),
        ]),
      ),
    ));
  }
}
