// =============================================================================
//  PrenatalYogaScreen (S4) — Prepare › Prenatal Yoga (interactive)
//  Trimester tabs switch the track; the safe (T3) track lists sessions that
//  play into the placeholder video screen. Earlier trimesters show a locked
//  explanation (their poses aren't safe at 30 weeks).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'prepare_common.dart';
import 'prepare_video_screen.dart';

class PrenatalYogaScreen extends StatefulWidget {
  const PrenatalYogaScreen({super.key});

  @override
  State<PrenatalYogaScreen> createState() => _PrenatalYogaScreenState();
}

class _PrenatalYogaScreenState extends State<PrenatalYogaScreen> {
  int _tri = 2; // 0,1 = earlier (locked at 30 weeks); 2 = current/safe

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            pvTopBar(context, backLabel: 'Prepare'),
            const SizedBox(height: 22),
            pvEyebrow('Safe for your stage'),
            const SizedBox(height: 10),
            Text('Prenatal Yoga', style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text('Trimester-safe movement to feel strong, calm, and ready.', style: pvSubStyle()),
            pvBanner(emoji: '🛡️', spans: [
              pvText("You're in your "),
              pvBold('third trimester'),
              pvText(" — here's your safe track. We hide anything that isn't right for 30 weeks."),
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
                    Text('Prenatal Yoga Program', style: pvTitleStyle(18)),
                    const SizedBox(height: 6),
                    Text('6 weeks · with Sana Kapoor, certified prenatal instructor', style: pvBody(kSoft, 13)),
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

            // trimester tabs
            const SizedBox(height: 22),
            Row(children: [
              Expanded(flex: 10, child: _tab('Trimester 1 🔒', 0)),
              const SizedBox(width: 8),
              Expanded(flex: 10, child: _tab('Trimester 2 🔒', 1)),
              const SizedBox(width: 8),
              Expanded(flex: 13, child: _tab(_tri == 2 ? 'Trimester 3 · here' : 'Trimester 3', 2)),
            ]),

            const SizedBox(height: 20),
            if (_tri == 2) ..._sessions() else _lockedTrack(),

            const SizedBox(height: 18),
            Text("Earlier trimesters include poses that aren't safe now — that's why they're tucked away.",
                style: pvBody(kSoft, 13).copyWith(fontStyle: FontStyle.italic, height: 1.6)),
            pvFooterNote(
                'Certified prenatal instructor. Every session filtered for your exact week — nothing unsafe ever surfaces.'),
          ],
        ),
      ),
    );
  }

  Widget _tab(String label, int index) {
    final active = index == _tri;
    return GestureDetector(
      onTap: () => setState(() => _tri = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? kPurple : kLockBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: pvBody(active ? Colors.white : kMuted, 12)
                .copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  List<Widget> _sessions() {
    return [
      for (int i = 0; i < kYogaSessions.length; i++)
        _session(kYogaSessions[i], top: true, bottom: i == kYogaSessions.length - 1),
    ];
  }

  Widget _lockedTrack() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('🔒', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text('Trimester ${_tri + 1} track', style: pvTitleStyle(16)),
        ]),
        const SizedBox(height: 10),
        Text(
            "These sessions include poses that aren't safe at 30 weeks, so they're tucked away for now. Your Trimester 3 track is ready and waiting.",
            style: pvBody(kSoft, 14).copyWith(height: 1.55)),
        const SizedBox(height: 16),
        pvPrimaryButton('Back to my safe track', () => setState(() => _tri = 2)),
      ]),
    );
  }

  Widget _session(YogaSession y, {bool top = false, bool bottom = false}) {
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
