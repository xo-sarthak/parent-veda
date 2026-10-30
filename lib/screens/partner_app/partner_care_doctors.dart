// =============================================================================
//  "Your doctors" for an IVF centre (P3)
// -----------------------------------------------------------------------------
//  The People tab, for a care_org. One row per doctor: name, how many families
//  joined through their code, and the DAY the latest one did. That is the whole
//  table, and the server (care_org_dashboard, 0139) sends nothing more: no
//  family, no user id, no time of day.
//
//  Counts per doctor are referral facts, so they are shown as they are, even
//  at 1 (R3). What a family DID is never broken down by doctor at all: with a
//  handful of families per doctor, "Dr Rao's families: 1 pregnancy" is a name.
//
//  Three kinds of row, from the server: a listed doctor (even with none yet,
//  because the empty row is the prompt to hand a code out), a doctor no
//  longer listed (her families stay hers; attribution is history), and the
//  centre's own code. Adding a doctor stays ours (STILL-OPEN §5.1c).
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/care_org_store.dart';
import '../../partner_app/partner_org_session.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_care_overview.dart';
import 'partner_sponsor_overview.dart' show PartnerLoadProblem;
import 'partner_words.dart';

class PartnerCareDoctors extends StatefulWidget {
  const PartnerCareDoctors({super.key, required this.org});
  final PartnerOrg org;

  @override
  State<PartnerCareDoctors> createState() => _PartnerCareDoctorsState();
}

class _PartnerCareDoctorsState extends State<PartnerCareDoctors> {
  @override
  void initState() {
    super.initState();
    partnerLoadCareOrgOnce();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: CareOrgStore.instance,
    builder: (context, _) {
      final store = CareOrgStore.instance;
      final d = store.dashboard;
      return DcTab(
        title: 'Your doctors',
        subtitle: widget.org.name,
        onRefresh: store.refresh,
        children: [
          if (store.error != null) ...[
            PartnerLoadProblem(store.error!, onRetry: store.refresh),
            const SizedBox(height: 12),
          ],
          if (d == null && store.loading && !store.everLoaded)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (d == null || d.doctors.isEmpty)
            // P1's empty state, unchanged: it is the advertisement.
            const DcEmpty(
              'Your doctors appear here',
              'Each doctor at your centre, with the families they brought. '
                  'No family is ever named. $kPartnerAddDoctorText',
              icon: Icons.medical_services_outlined,
            )
          else ...[
            Text(
              '${d.listedDoctors} '
              '${d.listedDoctors == 1 ? 'doctor' : 'doctors'} listed · '
              '${d.families} ${d.families == 1 ? 'family' : 'families'} in all',
              style: dcMeta(13),
            ),
            const SizedBox(height: 12),
            DcRowGroup(
              children: [for (final r in d.doctors) PartnerCareDoctorRow(r)],
            ),
            const SizedBox(height: 16),
            const DcNotice(
              'No family is ever named: each row is a count. '
              '$kPartnerAddDoctorText',
            ),
          ],
          const SizedBox(height: DcTab.barClearance),
        ],
      );
    },
  );
}

/// One doctor (or the centre's own code), as a row. Overview shows the top
/// few with the same widget, so the two tabs cannot word a row differently.
class PartnerCareDoctorRow extends StatelessWidget {
  const PartnerCareDoctorRow(this.row, {super.key});
  final CareOrgDoctorRow row;

  String get _title {
    if (row.isCentre) return "Your centre's own code";
    if (row.name.isNotEmpty) return row.name;
    return row.isFormer ? 'A doctor no longer listed' : 'A doctor';
  }

  String get _subtitle {
    final latest = row.latestOn == null
        ? null
        : 'latest joined ${dcDate(row.latestOn!, year: true)}';
    String withLatest(String s) => latest == null ? s : '$s · $latest';
    if (row.isCentre) return withLatest('Codes with no doctor on them');
    if (row.isFormer) return withLatest('No longer listed here');
    if (latest == null) return 'No families yet. Hand out their code.';
    return latest[0].toUpperCase() + latest.substring(1);
  }

  @override
  Widget build(BuildContext context) => DcRow(
    title: _title,
    subtitle: _subtitle,
    icon: row.isCentre
        ? Icons.local_hospital_outlined
        : row.isFormer
        ? Icons.person_off_outlined
        : Icons.medical_services_outlined,
    trailingText: '${row.families}',
    trailingSub: row.families == 1 ? 'family' : 'families',
    chevron: false,
  );
}
