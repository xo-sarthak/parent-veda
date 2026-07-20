// =============================================================================
//  HealthGuideScreen - Customised Health Guide (parenting app · S17)
// -----------------------------------------------------------------------------
//  A private, longitudinal health record for the child: a proactive "pattern
//  spotted" alert, quick-add (symptom / prescription / scan), a searchable
//  history, a "worked last time" memory-aid (with the not-medical-advice
//  caveat), and a telehealth paediatrician. Reached from the "Health" pill on
//  the My Child home. Faithful build of Claude Design "post pregnancy
//  app.dc.html" · S17. Pushed screen (no bottom nav). Isolated module.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'provider_profile_screen.dart';

class HealthGuideScreen extends StatelessWidget {
  const HealthGuideScreen({super.key});

  static const Color _green = Color(0xFF1F8A5B);
  static const Color _greenBg = Color(0xFFEAF6EF);
  static const Color _warnBg = Color(0xFFFFF7EE);

  void _soon(BuildContext context) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon'), behavior: SnackBarBehavior.floating),
      );

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 32),
          children: [
            // top bar: back + Private
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.arrow_back, size: 20, color: ppSoft),
                  const SizedBox(width: 10),
                  Text('My Child', style: ppBody(14, color: ppSoft)),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: _greenBg, borderRadius: BorderRadius.circular(999)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.lock_outline_rounded, size: 12, color: _green),
                  const SizedBox(width: 5),
                  Text('Private', style: ppBody(11, color: _green, w: FontWeight.w600)),
                ]),
              ),
            ])),

            // header
            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow("${ChildProfileStore.instance.name}'s health record"),
              const SizedBox(height: 10),
              Text('Health Guide', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text("A private, growing memory of ${ChildProfileStore.instance.name}'s health - so the next cough, rash or fever isn't a mystery.",
                  style: ppBody(15)),
            ])),

            // pattern alert (hero)
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: ppCoral, shape: BoxShape.circle),
                    child: const Text('!',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 8),
                  ppEyebrow('Pattern spotted', spacing: 0.9),
                ]),
                const SizedBox(height: 10),
                Text(
                    'Last winter ${ChildProfileStore.instance.name} caught a cough after the first cold day. The first cold snap is forecast next week - keep him layered and watch for a runny nose.',
                    style: ppBody(15, color: ppInk, h: 1.55)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _soon(context),
                  child: Text('See what helped last time →',
                      style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                ),
              ]),
            )),

            // quick add
            const SizedBox(height: 16),
            _pad(Row(children: [
              _quick(context, Icons.add_rounded, 'Log symptom', filled: true),
              const SizedBox(width: 10),
              _quick(context, Icons.description_outlined, 'Prescription'),
              const SizedBox(width: 10),
              _quick(context, Icons.photo_camera_outlined, 'Scan'),
            ])),

            // history
            const SizedBox(height: 28),
            _pad(Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('History', style: ppJakarta(18)),
                Text('Searchable', style: ppBody(12, color: ppMuted)),
              ],
            )),
            const SizedBox(height: 14),
            _pad(_entry('Cold & cough', 'Jan 2026', 'first cold day · woke up congested',
                'saline drops, steam - Dr. Ananya Rao',
                top: true)),
            _pad(_entry('Nappy rash', 'Dec 2025', 'new wipes brand', 'zinc barrier cream',
                top: true, bottom: true)),

            // repeat-prescription memory aid
            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFECE5F2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppEyebrow('Worked last time', color: ppPurple, spacing: 0.6),
                const SizedBox(height: 8),
                Text('For a cold: saline drops + steam', style: ppJakarta(15)),
                const SizedBox(height: 5),
                Text('Prescribed by Dr. Ananya Rao in Jan 2026.', style: ppBody(13, h: 1.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(color: _warnBg, borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: ppBrown),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                          'A memory aid, not medical advice - always consult your doctor before reusing any medication.',
                          style: ppBody(12, color: ppBrown, h: 1.5)),
                    ),
                  ]),
                ),
              ]),
            )),

            // telehealth
            const SizedBox(height: 28),
            _pad(Text('Talk to a paediatrician', style: ppJakarta(18))),
            const SizedBox(height: 6),
            _pad(Text("Location-matched, children's specialists only - via our telehealth partner.",
                style: ppBody(12))),
            const SizedBox(height: 14),
            _pad(_doctor(context)),

            const SizedBox(height: 20),
            _pad(Text('Your records are private and encrypted. Consults are with verified paediatricians, never adult GPs.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
    );
  }

  Widget _quick(BuildContext context, IconData icon, String label, {bool filled = false}) => Expanded(
        child: GestureDetector(
          onTap: () => _soon(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 15),
            decoration: BoxDecoration(
              color: filled ? ppPurple : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: filled ? null : Border.all(color: ppLine),
            ),
            child: Column(children: [
              Icon(icon, size: 20, color: filled ? Colors.white : ppPurple),
              const SizedBox(height: 7),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ppBody(12, color: filled ? Colors.white : ppInk, w: FontWeight.w700)),
            ]),
          ),
        ),
      );

  Widget _entry(String title, String date, String trigger, String rx,
      {bool top = false, bool bottom = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          top: top ? const BorderSide(color: ppHair) : BorderSide.none,
          bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(child: Text(title, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 10),
          Text(date, style: ppBody(12, color: ppMuted)),
        ]),
        const SizedBox(height: 4),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Trigger: ', style: TextStyle(color: ppBrown)),
          TextSpan(text: trigger, style: const TextStyle(color: ppSoft)),
        ]), style: ppBody(13, h: 1.5)),
        Text.rich(TextSpan(children: [
          TextSpan(text: 'Rx: ', style: TextStyle(color: ppPurple)),
          TextSpan(text: rx, style: const TextStyle(color: ppSoft)),
        ]), style: ppBody(13, h: 1.5)),
      ]),
    );
  }

  Widget _doctor(BuildContext context) {
    // A real seed paediatrician - tapping opens her reusable profile (never a
    // dead "coming soon"). Everything shown is drawn from her profile data.
    final e = expertById('neha');
    final languages = e.tags.take(2).join(' / ');
    void openProfile() => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: e)));
    return GestureDetector(
      onTap: openProfile,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair))),
        child: Row(children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
            clipBehavior: Clip.antiAlias,
            child: const PpStriped(height: 60, colorA: ppBorder, colorB: ppStripeB),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.name, style: ppBody(15, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 1),
              Text(e.credential, style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 6),
              Row(children: [
                Text('★ ${e.rating}', style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
                const SizedBox(width: 10),
                Flexible(child: Text(languages, style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 10),
                Text(e.ctaPrice, style: ppBody(12, color: ppInk, w: FontWeight.w600)),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
            decoration:
                BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppPurple)),
            child: Text('Consult', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }
}
