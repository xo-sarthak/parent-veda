// =============================================================================
//  VaxDetailScreen — per-vaccine Learn Why + After-Care + actions
// -----------------------------------------------------------------------------
//  Educate before asking parents to act. For each vaccine in a visit: WHY it
//  matters, the diseases it prevents, expected mild reactions, myths vs facts,
//  FAQs — and then After-Care (what to expect, comfort, red flags/call-now, Ask
//  Veda, and gentle related products, only within after-care, never as ads).
//  Sticky actions: Mark as done, and Set a reminder (real local notification via
//  NotificationService). Reassuring, warm, never clinical.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/notification_service.dart';
import 'askveda_screen.dart';
import 'pp_common.dart';
import 'pp_vaccine_data.dart';

const Color _green = Color(0xFF1F8A5B);
const Color _flagBg = Color(0xFFFFF0F3);
const Color _flagBorder = Color(0xFFFFD9E1);
const Color _flagFg = Color(0xFFC6295A);

class VaxDetailScreen extends StatefulWidget {
  const VaxDetailScreen({super.key, required this.visitId});
  final String visitId;

  @override
  State<VaxDetailScreen> createState() => _VaxDetailScreenState();
}

class _VaxDetailScreenState extends State<VaxDetailScreen> {
  late VaxVisit _visit;
  late Vaccine _vax;

  @override
  void initState() {
    super.initState();
    _visit = vaxVisitById(widget.visitId);
    _vax = _visit.lead;
  }

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(Widget s) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        AnimatedBuilder(
          animation: VaxStore.instance,
          builder: (context, _) {
            final status = VaxStore.instance.statusOf(_visit);
            return ListView(
              padding: const EdgeInsets.only(top: 60, bottom: 120),
              children: [
                _pad(ppCircleBack(context, eyebrow: '${_visit.ageLabel} · ${_visit.date}')),

                const SizedBox(height: 22),
                _pad(ppEyebrow(vaxStatusLabel(status) == 'Done' ? 'Completed' : (status == VaxStatus.due ? 'Recommended now' : 'Coming up'), color: ppPurple, spacing: 1.2)),
                const SizedBox(height: 10),
                _pad(Text(_vax.name, style: ppFraunces(31, h: 1.12))),

                // vaccine switcher (a visit can carry several)
                if (_visit.vaccines.length > 1) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        for (final v in _visit.vaccines) ...[
                          _switchChip(v),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],

                // protects against
                const SizedBox(height: 18),
                _pad(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ppEyebrow('Why it matters', color: ppPurple, spacing: 0.8),
                    const SizedBox(height: 8),
                    Text(_vax.why, style: ppBody(14, color: ppInk, h: 1.6)),
                  ]),
                )),

                // diseases prevented
                const SizedBox(height: 16),
                _pad(Text('Diseases it prevents', style: ppJakarta(16))),
                const SizedBox(height: 12),
                for (final d in _vax.diseases) _pad(_bullet(d)),

                // myths
                if (_vax.myths.isNotEmpty) ...[
                  _pad(ppSectionDivider()),
                  _pad(Text('Myths vs facts', style: ppJakarta(16))),
                  const SizedBox(height: 12),
                  for (final m in _vax.myths) _pad(_mythCard(m.$1, m.$2)),
                ],

                // FAQs
                if (_vax.faqs.isNotEmpty) ...[
                  _pad(ppSectionDivider()),
                  _pad(Text('Common questions', style: ppJakarta(16))),
                  const SizedBox(height: 6),
                  for (final f in _vax.faqs) _pad(_faq(f.$1, f.$2)),
                ],

                // Ask Veda cross-link
                const SizedBox(height: 14),
                _pad(_crossLink('Ask Veda', 'Can he have ${_vax.shortName} during a cold?', AskVedaScreen(initialQuery: 'Can my baby have ${_vax.shortName} during a mild cold?'))),

                // ---- After-Care ----
                _pad(ppSectionDivider()),
                _pad(Row(children: [
                  const Icon(Icons.healing_outlined, size: 18, color: ppPurple),
                  const SizedBox(width: 10),
                  Text('After the shot', style: ppJakarta(17)),
                ])),
                const SizedBox(height: 12),
                _pad(Text('What to expect', style: ppBody(12.5, color: ppSoft, w: FontWeight.w700))),
                const SizedBox(height: 8),
                for (final r in _vax.reactions) _pad(_bullet(r, icon: Icons.circle, small: true)),
                const SizedBox(height: 14),
                _pad(Text('Comfort measures', style: ppBody(12.5, color: ppSoft, w: FontWeight.w700))),
                const SizedBox(height: 8),
                for (final c in _vax.comfort) _pad(_check(c)),

                // red flags
                const SizedBox(height: 16),
                _pad(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(color: _flagBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _flagBorder)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      const Icon(Icons.warning_amber_rounded, size: 17, color: _flagFg),
                      const SizedBox(width: 8),
                      Text('Call your doctor / 112 if', style: ppBody(13, color: _flagFg, w: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    for (final f in _vax.redFlags) Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('• $f', style: ppBody(13, color: ppInk, h: 1.5)),
                    ),
                  ]),
                )),

                // related products (after-care only)
                if (_vax.products.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _pad(Text('Comfort essentials', style: ppJakarta(15))),
                  const SizedBox(height: 4),
                  _pad(Text('Only if it helps your home — never a must.', style: ppBody(12, color: ppMuted))),
                  const SizedBox(height: 12),
                  for (int i = 0; i < _vax.products.length; i++)
                    _pad(ppProductRow(context, _vax.products[i].$1, _vax.products[i].$2, _vax.products[i].$3, top: true, bottom: i == _vax.products.length - 1, productId: _vax.products[i].$4)),
                ],

                const SizedBox(height: 20),
                _pad(Text('Informational only, not medical advice — always confirm with your paediatrician.', textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
              ],
            );
          },
        ),

        // top fade
        Positioned(top: 0, left: 0, right: 0, child: IgnorePointer(child: Container(height: 52, decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [ppBg, Color(0x00FBF9FE)]))))),

        // sticky actions
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedBuilder(
            animation: VaxStore.instance,
            builder: (context, _) {
              final done = VaxStore.instance.isDone(_visit.id);
              final reminded = VaxStore.instance.hasReminder(_visit.id);
              return Container(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg])),
                child: Row(children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => done ? VaxStore.instance.markNotDone(_visit.id) : VaxStore.instance.markDone(_visit.id),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: done ? _green : ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))]),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(done ? Icons.check_rounded : Icons.check_circle_outline_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 8),
                          Flexible(child: Text(done ? 'Done ✓' : 'Mark as done', maxLines: 1, overflow: TextOverflow.ellipsis, style: ppBody(15, color: Colors.white, w: FontWeight.w700))),
                        ]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _reminderSheet,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: reminded ? const Color(0xFFEDE6F5) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: reminded ? ppPurple : ppLine)),
                      child: Icon(reminded ? Icons.notifications_active_rounded : Icons.notifications_none_rounded, size: 22, color: reminded ? ppPurple : ppInk),
                    ),
                  ),
                ]),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _switchChip(Vaccine v) {
    final on = v.id == _vax.id;
    return GestureDetector(
      onTap: () => setState(() => _vax = v),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(color: on ? ppPurple : Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: on ? ppPurple : ppLine)),
        child: Text(v.shortName, style: ppBody(12.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
      ),
    );
  }

  Widget _bullet(String text, {IconData icon = Icons.arrow_right_rounded, bool small = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: EdgeInsets.only(top: small ? 6 : 2), child: Icon(icon, size: small ? 7 : 18, color: ppPurple)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _check(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 9),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('✓', style: TextStyle(color: ppPurple, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  Widget _mythCard(String myth, String fact) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('MYTH', style: ppBody(9.5, color: ppCoral, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
            const SizedBox(width: 8),
            Expanded(child: Text(myth, style: ppBody(13.5, color: ppInk, h: 1.45))),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('FACT', style: ppBody(9.5, color: _green, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
            const SizedBox(width: 10),
            Expanded(child: Text(fact, style: ppBody(13.5, color: ppInk, h: 1.55))),
          ]),
        ]),
      );

  Widget _faq(String q, String a) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(q, style: ppBody(13.5, color: ppInk, w: FontWeight.w700, h: 1.4)),
          const SizedBox(height: 4),
          Text(a, style: ppBody(13, h: 1.55)),
        ]),
      );

  Widget _crossLink(String pill, String text, Widget screen) => GestureDetector(
        onTap: () => _push(screen),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: ppHair), bottom: BorderSide(color: ppHair))),
          child: Row(children: [
            Container(width: 66, alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 5), decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)), child: Text(pill, style: ppBody(10, color: ppPurple, w: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Text(text, style: ppBody(14, color: ppInk))),
            const SizedBox(width: 10),
            const Text('→', style: TextStyle(color: ppMuted)),
          ]),
        ),
      );

  // ---- reminder scheduling ------------------------------------------------
  void _reminderSheet() {
    final when = vaxVisitDate(_visit) ?? vaxDueDate();
    void set(int daysBefore, String label) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      VaxStore.instance.setReminder(_visit.id, true);
      NotificationService.instance.requestPermission();
      NotificationService.instance.scheduleOneOff(
        id: (_visit.id.hashCode & 0x7fffffff),
        title: 'Vaccine reminder — ${_vax.shortName}',
        body: daysBefore == 0
            ? "Aarav's ${_vax.shortName} (${_visit.ageLabel}) is due today."
            : "Aarav's ${_vax.shortName} (${_visit.ageLabel}) is due ${daysBefore == 1 ? 'tomorrow' : 'in $daysBefore days'} — ${_visit.date}.",
        when: when.subtract(Duration(days: daysBefore)),
      );
      messenger.showSnackBar(SnackBar(content: Text('Reminder set — $label'), behavior: SnackBarBehavior.floating));
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
            const SizedBox(height: 16),
            Text('Remind me about this vaccine', style: ppJakarta(17)),
            const SizedBox(height: 4),
            Text('Due ${_visit.date} · we\'ll send a gentle nudge.', style: ppBody(12.5, color: ppMuted)),
            const SizedBox(height: 14),
            _reminderOption('The day before', () => set(1, '1 day before')),
            _reminderOption('3 days before', () => set(3, '3 days before')),
            _reminderOption('A week before', () => set(7, '1 week before')),
            _reminderOption('On the day', () => set(0, 'on the day')),
            if (VaxStore.instance.hasReminder(_visit.id)) ...[
              const SizedBox(height: 4),
              Center(child: GestureDetector(
                onTap: () {
                  VaxStore.instance.setReminder(_visit.id, false);
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Text('Remove reminder', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
              )),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _reminderOption(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
          child: Row(children: [
            const Icon(Icons.notifications_active_outlined, size: 18, color: ppPurple),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );
}
