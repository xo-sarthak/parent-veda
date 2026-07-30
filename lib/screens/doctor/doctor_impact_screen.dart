// =============================================================================
//  Partner Journey Dashboard — "how many families have I helped?"
// -----------------------------------------------------------------------------
//  The user's addition, and the one that changes what this platform IS.
//
//  A referral marketplace shows a doctor their commission. This shows them
//  their impact FIRST and their earnings second, because the doctors worth
//  having as partners did not come into medicine for a 2.5% share — and a
//  screen that leads with money quietly tells them what we think of them.
//
//  EVERY NUMBER HERE IS AN AGGREGATE. The server function that feeds it
//  (partner_impact, 0037) returns counts and nothing else; there is no RLS
//  policy anywhere that would let a partner read an individual family's row.
//  A doctor learns that 41 families came through them and that 12 pregnancies
//  are being supported. They never learn WHICH families, and that is not an
//  omission we might fill in later — it is the boundary the whole module rests
//  on.
// =============================================================================

import 'package:flutter/material.dart';

import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';
import 'doctor_referral_kit_screen.dart';

class DoctorImpactScreen extends StatefulWidget {
  const DoctorImpactScreen({super.key});

  @override
  State<DoctorImpactScreen> createState() => _DoctorImpactScreenState();
}

class _DoctorImpactScreenState extends State<DoctorImpactScreen> {
  final _store = PartnerDashboardStore.instance;

  @override
  void initState() {
    super.initState();
    _store.load(DoctorSession.instance.sessionKey);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final partner = _store.partner;
        final impact = _store.impact;

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            ppEyebrow('YOUR IMPACT', color: ppPurple),
            const SizedBox(height: 8),
            Text(_headline(impact), style: ppFraunces(26, h: 1.15)),
            const SizedBox(height: 8),
            Text(
              partner == null
                  ? 'Families who found ParentVeda through you.'
                  : 'Families who found ParentVeda through ${partner.name}.',
              style: ppBody(13, h: 1.5),
            ),
            const SizedBox(height: 20),
            if (partner != null && partner.status != PartnerStatus.active)
              _statusNote(partner),
            if (_store.isLoading) const LinearProgressIndicator(minHeight: 2),
            const SizedBox(height: 6),
            _grid(impact),
            const SizedBox(height: 4),
            _kitLink(context, (impact?.familiesReferred ?? 0) == 0),
            const SizedBox(height: 22),
            _funnelBlock(_store.funnel),
            const SizedBox(height: 22),
            _privacyNote(),
            const SizedBox(height: 22),
            _earnings(),
          ],
        );
      },
    );
  }

  String _headline(PartnerImpact? i) {
    final n = i?.familiesReferred ?? 0;
    if (n == 0) return 'Your first family is\nyet to arrive';
    if (n == 1) return 'One family found\nParentVeda through you';
    return '$n families found\nParentVeda through you';
  }

  Widget _statusNote(CarePartner p) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: ppCoralTint,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: ppCoral.withValues(alpha: 0.4)),
        ),
        child: Text(p.status.label, style: ppJakarta(12.5)),
      );

  Widget _grid(PartnerImpact? i) {
    final tiles = <(String, int, IconData)>[
      ('Families referred', i?.familiesReferred ?? 0, Icons.family_restroom_rounded),
      ('Active this month', i?.activeThisMonth ?? 0, Icons.bolt_rounded),
      ('Pregnancies supported', i?.pregnanciesSupported ?? 0, Icons.pregnant_woman_rounded),
      ('Babies welcomed', i?.childrenAdded ?? 0, Icons.child_care_rounded),
      ('Consultations completed', i?.consultationsDone ?? 0, Icons.videocam_rounded),
      ('Vaccinations completed', i?.vaccinationsCompleted ?? 0, Icons.vaccines_rounded),
      ('Guides read', i?.contentConsumed ?? 0, Icons.menu_book_rounded),
    ];
    return Column(children: [
      for (var r = 0; r < tiles.length; r += 2)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Expanded(child: _tile(tiles[r])),
            const SizedBox(width: 10),
            Expanded(
              child: r + 1 < tiles.length
                  ? _tile(tiles[r + 1])
                  : const SizedBox.shrink(),
            ),
          ]),
        ),
    ]);
  }

  Widget _tile((String, int, IconData) t) => Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(t.$3, size: 18, color: ppPurple),
          const SizedBox(height: 10),
          Text('${t.$2}', style: ppFraunces(24, h: 1)),
          const SizedBox(height: 3),
          Text(t.$1, style: ppBody(11, h: 1.35)),
        ]),
      );

  /// The way to move every number above. Worded as an invitation when the
  /// dashboard is still empty, and as a quiet utility once it is not.
  Widget _kitLink(BuildContext context, bool empty) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const DoctorReferralKitScreen())),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
            color: empty ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: empty ? ppPurple : ppBorder),
          ),
          child: Row(children: [
            Icon(Icons.qr_code_2_rounded,
                size: 19, color: empty ? Colors.white : ppPurple),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                empty
                    ? 'Share your code with a patient'
                    : 'Your referral kit',
                style: ppJakarta(13, color: empty ? Colors.white : ppInk),
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 16, color: empty ? Colors.white : ppSoft),
          ]),
        ),
      );

  /// The conversion chain. Shown as counts, not as a percentage per step:
  /// "42% install rate" invites a doctor to think they are being scored, and
  /// the number they actually care about is how many families arrived.
  Widget _funnelBlock(PartnerFunnel? f) {
    if (f == null || f.signedUp == 0) return const SizedBox.shrink();
    final steps = <(String, int)>[
      ('Scanned your code', f.scanned),
      ('Installed the app', f.installed),
      ('Signed up', f.signedUp),
      ('Told us about their family', f.activated),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('How families arrive', style: ppJakarta(15)),
      const SizedBox(height: 4),
      Text(
        'Counted for the families who reached ParentVeda. A scan that never '
        'became an account is not tracked at all.',
        style: ppBody(11.5, h: 1.45),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppBorder),
        ),
        child: Column(children: [
          for (final s in steps)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Row(children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: ppPurple, shape: BoxShape.circle),
                ),
                const SizedBox(width: 11),
                Expanded(child: Text(s.$1, style: ppBody(12.5))),
                Text('${s.$2}', style: ppJakarta(13.5)),
              ]),
            ),
        ]),
      ),
    ]);
  }

  /// Said plainly, to the doctor. A partner who understands the boundary is far
  /// less likely to ask us to cross it.
  Widget _privacyNote() => Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
            color: ppPanel, borderRadius: BorderRadius.circular(13)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.lock_outline_rounded, size: 16, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'These are totals only. ParentVeda never shows you which families '
              'these are, or anything about them — the same privacy your own '
              'patients expect from you.',
              style: ppBody(11.5, h: 1.5),
            ),
          ),
        ]),
      );

  Widget _earnings() {
    final rows = _store.earnings;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Where your earnings come from', style: ppJakarta(15)),
      const SizedBox(height: 4),
      Text('Consultations, classes and referrals, in one place.',
          style: ppBody(12)),
      const SizedBox(height: 12),
      if (rows.isEmpty)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder),
          ),
          child: Text('Nothing earned yet.', style: ppBody(12.5)),
        )
      else
        for (final r in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: ppBorder),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.sourceLabel, style: ppJakarta(13)),
                        const SizedBox(height: 2),
                        Text('${r.entries} ${r.entries == 1 ? 'entry' : 'entries'} · ${r.statusLabel}',
                            style: ppBody(11)),
                      ]),
                ),
                Text(r.amountLabel, style: ppJakarta(14, color: ppPurple)),
              ]),
            ),
          ),
    ]);
  }
}
