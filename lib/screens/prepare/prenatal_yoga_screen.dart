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

// TODO: derive the current pregnancy month from the saved due date / week.
// 30 weeks ≈ month 7, matching the rest of the Prepare tab's "Priya · 30 weeks".
const int _kCurrentMonth = 7;

class PrenatalYogaScreen extends StatefulWidget {
  const PrenatalYogaScreen({super.key});

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
    final sessions = yogaSessionsForMonth(_month);
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            pvTopBar(context, backLabel: 'Prepare'),
            const SizedBox(height: 22),
            pvEyebrow('Move with your month'),
            const SizedBox(height: 10),
            Text('Yoga', style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text('Trimester-safe movement to feel strong, calm, and ready - matched to exactly where you are.',
                style: pvSubStyle()),
            pvBanner(icon: Icons.self_improvement_rounded, spans: [
              pvText("You're in "),
              pvBold('month $_kCurrentMonth'),
              pvText(" - we've opened your yoga here. Every session is filtered safe for your stage."),
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
                    Text('Pregnancy Yoga Program', style: pvTitleStyle(18)),
                    const SizedBox(height: 6),
                    Text('9-month journey · with Sana Kapoor, certified prenatal instructor',
                        style: pvBody(kSoft, 13)),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(children: const [
                        TextSpan(text: '₹599', style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                        TextSpan(text: '  ·  ', style: TextStyle(color: kMuted)),
                        TextSpan(
                            text: 'Free with ParentVeda+',
                            style: TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                      ]),
                      style: pvBody(kInk, 14),
                    ),
                  ]),
                ),
              ]),
            ),

            // month tabs
            const SizedBox(height: 22),
            Text('CHOOSE A MONTH',
                style: pvBody(kSoft, 11).copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1)),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: ListView(
                controller: _tabs,
                scrollDirection: Axis.horizontal,
                children: [for (int m = 1; m <= 9; m++) _monthTab(m)],
              ),
            ),

            const SizedBox(height: 20),
            Row(children: [
              Text(_month == _kCurrentMonth ? 'This month for you' : 'Month $_month',
                  style: pvTitleStyle(16)),
              const Spacer(),
              Text('${sessions.length} ${sessions.length == 1 ? 'session' : 'sessions'}',
                  style: pvBody(kMuted, 12)),
            ]),
            const SizedBox(height: 6),

            if (sessions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('Sessions for this month are coming soon.',
                    style: pvBody(kSoft, 14).copyWith(fontStyle: FontStyle.italic)),
              )
            else
              for (int i = 0; i < sessions.length; i++)
                _session(sessions[i], bottom: i == sessions.length - 1),

            const SizedBox(height: 18),
            Text('Every session is filtered for your month - nothing unsafe for where you are ever surfaces.',
                style: pvBody(kSoft, 13).copyWith(fontStyle: FontStyle.italic, height: 1.6)),
            pvFooterNote('Certified prenatal instructor. A calm, safe practice for all nine months.'),
          ],
        ),
      ),
    );
  }

  Widget _monthTab(int m) {
    final active = m == _month;
    final isNow = m == _kCurrentMonth;
    return GestureDetector(
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
          Text('Month $m',
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
    );
  }

  Widget _session(YogaSession y, {bool bottom = false}) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PrepareVideoScreen(
              title: y.title, subtitle: '${y.duration} · ${y.focus}', blurb: y.blurb))),
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
            child: const Text('▸', style: TextStyle(color: kPurple, fontSize: 15)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(y.title, style: pvBody(kInk, 15).copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text('${y.duration} · ${y.focus}', style: pvBody(kMuted, 12)),
            ]),
          ),
          const SizedBox(width: 10),
          pvPill('Safe for you'),
        ]),
      ),
    );
  }
}
