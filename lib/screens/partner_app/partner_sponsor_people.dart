// =============================================================================
//  People for an employer or a school (P2)
// -----------------------------------------------------------------------------
//  sponsor_roster() (0061): everyone on the list the organisation sent us,
//  plus anyone who activated without being on it, each with one bit added:
//  activated, not yet, or removed. Names are HR's own (they sent them), and
//  nothing about what a person DID is here: no bookings, no reading, no
//  last-seen, no user id. That thinness is what lets Overview be rich.
//
//  THREE STATUSES, NOT TWO. The shared SponsorMemberRow once split on
//  `isActive`, and everyone not yet started showed as Removed. Filter on the
//  three getters (sponsor_roster_status_test holds it).
//
//  REMOVE, CONFIRMED IN THE PAGE. Tapping Remove opens the row itself into a
//  confirm (what is lost, what is not, Remove / Keep), not a dialog: the
//  house rule for this app, and a dialog hides the very row being decided on.
//  Only an active person can be removed (sponsor_remove_member resolves an
//  ACTIVE member); not-started people leave the list when HR sends a new one.
//
//  NOT YOURSELF. The row matching the signed-in email has no Remove. The
//  server refuses it too, on the user id (0138), which also catches an admin
//  who activated under a different work address than the one she signs in
//  with; this check only saves the round trip in the common case.
// =============================================================================

import 'package:flutter/material.dart';

import '../../partner_app/partner_org_session.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/sponsor_admin_store.dart';
import '../doctor/doctor_chrome.dart';
import 'partner_sponsor_overview.dart';
import 'partner_words.dart';

enum PartnerPeopleFilter { all, activated, notStarted, removed }

/// The filter as a predicate, kept out of the widget so a test can hold it.
bool partnerPeopleMatches(
  SponsorMemberRow r,
  PartnerPeopleFilter f,
  String query,
) {
  final inFilter = switch (f) {
    PartnerPeopleFilter.all => true,
    PartnerPeopleFilter.activated => r.isActive,
    PartnerPeopleFilter.notStarted => r.isNotActivated,
    PartnerPeopleFilter.removed => r.isRemoved,
  };
  if (!inFilter) return false;
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return r.workEmail.toLowerCase().contains(q) ||
      (r.fullName ?? '').toLowerCase().contains(q);
}

class PartnerSponsorPeople extends StatefulWidget {
  const PartnerSponsorPeople({super.key, required this.org, this.myEmail});
  final PartnerOrg org;

  /// The signed-in email; read from the session when not given (a test
  /// passes it, having no session).
  final String? myEmail;

  @override
  State<PartnerSponsorPeople> createState() => _PartnerSponsorPeopleState();
}

class _PartnerSponsorPeopleState extends State<PartnerSponsorPeople> {
  final _search = TextEditingController();
  PartnerPeopleFilter _filter = PartnerPeopleFilter.all;

  /// The row opened into its confirm, by work email. One at a time.
  String? _confirming;
  bool _removing = false;

  String? get _me => (widget.myEmail ?? SupabaseRepo.userEmail)?.toLowerCase();

  @override
  void initState() {
    super.initState();
    partnerLoadSponsorOnce();
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _remove(SponsorMemberRow r) async {
    if (_removing) return;
    setState(() => _removing = true);
    final res = await SponsorAdminStore.instance.removeMember(r.workEmail);
    if (!mounted) return;
    setState(() {
      _removing = false;
      if (res['ok'] == true) _confirming = null;
    });
    dcToast(
      context,
      res['ok'] == true
          ? '${r.workEmail} removed.'
          : (res['message'] ?? 'That did not work. Try again.').toString(),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: SponsorAdminStore.instance,
    builder: (context, _) {
      final org = widget.org;
      final store = SponsorAdminStore.instance;
      final d = store.dashboard;
      final roster = store.roster;
      final list = org.isSchool ? 'parent list' : 'staff list';

      final children = <Widget>[];
      if (d == null) {
        if (store.loading && !store.everLoaded) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        } else if (store.error != null) {
          children.add(PartnerLoadProblem(store.error!));
        } else {
          children.add(_empty(org, list));
        }
      } else if (roster.isEmpty) {
        children.add(_empty(org, list));
      } else {
        children.addAll(_loaded(org, store, d, roster, list));
      }
      children.add(const SizedBox(height: DcTab.barClearance));

      return DcTab(
        title: 'People',
        subtitle: d == null
            ? null
            : '${roster.length} on your list or activated',
        onRefresh: store.refresh,
        children: children,
      );
    },
  );

  Widget _empty(PartnerOrg org, String list) => DcEmpty(
    'Your ${org.peopleWord} appear here',
    'Everyone on your $list, and whether they have activated. '
        'Send us your $list to get started: $kPartnersSupportEmail.',
    icon: Icons.groups_outlined,
  );

  List<Widget> _loaded(
    PartnerOrg org,
    SponsorAdminStore store,
    SponsorDashboard d,
    List<SponsorMemberRow> roster,
    String list,
  ) {
    int count(PartnerPeopleFilter f) =>
        roster.where((r) => partnerPeopleMatches(r, f, '')).length;
    final shown = roster
        .where((r) => partnerPeopleMatches(r, _filter, _search.text))
        .toList();
    return [
      if (store.error != null) ...[
        PartnerLoadProblem(store.error!),
        const SizedBox(height: 12),
      ],
      if (d.seatsLeft == 0) ...[
        Align(
          alignment: Alignment.centerLeft,
          child: const DcStatusPill('All seats taken', hue: 42),
        ),
        const SizedBox(height: 6),
        DcNotice(partnerSeatsFullText(org, d.seatsPurchased ?? 0)),
        const SizedBox(height: 14),
      ],
      DcInput(
        label: 'Search',
        hint: 'Name or email',
        controller: _search,
        keyboard: TextInputType.emailAddress,
      ),
      const SizedBox(height: 12),
      DcSegments(
        labels: [
          'All ${count(PartnerPeopleFilter.all)}',
          'Activated ${count(PartnerPeopleFilter.activated)}',
          'Not started ${count(PartnerPeopleFilter.notStarted)}',
          'Removed ${count(PartnerPeopleFilter.removed)}',
        ],
        index: _filter.index,
        onChanged: (i) => setState(() {
          _filter = PartnerPeopleFilter.values[i];
          _confirming = null;
        }),
      ),
      const SizedBox(height: 8),
      if (shown.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: DcNotice(
            _search.text.trim().isEmpty
                ? 'Nobody here yet.'
                : 'Nobody matches "${_search.text.trim()}".',
          ),
        )
      else
        DcRowGroup(children: [for (final r in shown) _row(org, r)]),
      const SizedBox(height: 16),
      DcNotice(
        'Activation is all we record about a person here. To take someone '
        'who has not started off your list, send us an updated $list: '
        '$kPartnersSupportEmail.',
      ),
    ];
  }

  Widget _row(PartnerOrg org, SponsorMemberRow r) {
    final p = dcP;
    final isMe = _me != null && r.workEmail.toLowerCase() == _me;
    final status = r.isActive
        ? 'Activated ${r.activatedAt == null ? '' : dcDate(r.activatedAt!, year: true)}'
              .trim()
        : r.isNotActivated
        ? 'Not activated yet'
        : 'Removed ${r.removedAt == null ? '' : dcDate(r.removedAt!, year: true)}'
              .trim();
    final named = r.fullName != null;
    final canRemove = r.isActive && !isMe;
    final open = _confirming == r.workEmail;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DcRow(
          title: r.displayName,
          subtitle: [
            if (named) r.workEmail,
            isMe ? '$status · You' : status,
          ].join(' · '),
          titleColor: r.isRemoved ? p.ink3 : null,
          chevron: false,
          trailing: canRemove
              ? IconButton(
                  tooltip: 'Remove',
                  icon: Icon(Icons.person_remove_outlined, color: p.ink2),
                  onPressed: () =>
                      setState(() => _confirming = open ? null : r.workEmail),
                )
              : null,
        ),
        if (open)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Remove ${r.workEmail}?', style: dcStrong(15)),
                const SizedBox(height: 4),
                Text(
                  // What is lost and what is not. Someone who bought Premium
                  // themselves keeps it: that is what `source` on the
                  // entitlement is for, and HR should not fear taking it.
                  'Their seat is freed and the plan ${org.name} provides is '
                  'withdrawn. Anything they bought themselves is untouched, '
                  'and their journal, photos and records stay theirs.',
                  style: dcMeta(13.5),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton(
                      onPressed: _removing ? null : () => _remove(r),
                      child: Text(
                        _removing ? 'Removing…' : 'Remove',
                        style: dcStrong(14, color: dcError),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _removing
                          ? null
                          : () => setState(() => _confirming = null),
                      child: Text('Keep', style: dcStrong(14, color: p.ink1)),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}
