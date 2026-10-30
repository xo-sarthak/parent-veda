// =============================================================================
//  Your offerings — every run she hosts, and its discussion (0137, LA-21)
// -----------------------------------------------------------------------------
//  The L1 prototype's doctor screen (YouTube Studio's comments list, Linear's
//  inbox rows): one row per run she leads or guests on, with her role, the
//  seats booked, the next session and an unread count for its discussion.
//  A row opens the course room as a host — she posts under her own name with
//  the seal and her role, answers, and pins. Remove and mute stay with the
//  moderators, so the host's menu does not carry them.
//
//  READ FROM THE SERVER (`expert_my_offerings`), not from the bundled
//  catalogue: "Your classes" filtered the phone's own BookingCatalog by
//  expert id (doctor_roster.dart), so a co-host, or a programme the panel
//  added after the build, was invisible. Going live is unchanged: ClassCard
//  and DoctorClassesScreen still do it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/pv_community.dart';
import '../../services/pv_community_store.dart';
import '../../widgets/pv_toast.dart';
import '../community/community_chrome.dart' show openCommunityRoom;
import 'doctor_art.dart';
import 'doctor_chrome.dart';
import 'doctor_community_queue_screen.dart';

const String kDoctorOfferingsRoute = 'doctor/offerings';

void openDoctorOfferings(BuildContext context) => Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: kDoctorOfferingsRoute),
      builder: (_) => const DoctorOfferingsScreen(),
    ));

/// "Tue 10 Nov, 7 pm", in her own clock.
String doctorOfferingWhen(DateTime t) {
  const d = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final mm = t.minute == 0 ? '' : ':${t.minute.toString().padLeft(2, '0')}';
  return '${d[t.weekday - 1]} ${t.day} ${m[t.month - 1]}, $h$mm ${t.hour < 12 ? 'am' : 'pm'}';
}

/// One offering's second line: role · seats · next session.
String doctorOfferingLine(PvExpertOffering o) => [
      pvHostRoleLabel(o.role),
      o.capacity == null ? '${o.seatsBooked} booked' : '${o.seatsBooked} of ${o.capacity} seats',
      o.nextSession == null ? 'no session dated yet' : 'next ${doctorOfferingWhen(o.nextSession!)}',
    ].where((s) => s.isNotEmpty).join(' · ');

/// Opens a run's discussion as its host. The server answers whether she may
/// enter (a route A host of this programme), and creates the room if this is
/// the first time anyone has opened it.
Future<void> openDoctorOffering(BuildContext context, PvExpertOffering o) async {
  final store = PvCommunityStore.instance;
  final room = await store.offeringRoom(o.programmeId, runId: o.runId);
  if (!context.mounted) return;
  if (room == null || !room.access) {
    pvToast(
      context,
      room == null
          ? 'Could not reach ParentVeda. Check your connection and try again.'
          : 'This discussion is not open to your account. Ask the ParentVeda team to check your host link.',
      kind: PvToastKind.gentle,
    );
    return;
  }
  openCommunityRoom(context, room.room.id);
}

/// The unread count, as the home and this list draw it.
class DoctorCountBadge extends StatelessWidget {
  const DoctorCountBadge(this.n, {super.key});
  final int n;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: dcP.ink1, borderRadius: BorderRadius.circular(999)),
        child: Text('$n', style: dcStrong(11.5, color: Colors.white)),
      );
}

/// The doctor home's section 8 (it was "Your classes"): her two soonest
/// offerings with their unread counts, the one "Parents asking an expert to
/// look" row (B4, as drawn), and the go-live card underneath, unchanged.
class DoctorOfferingsSection extends StatefulWidget {
  const DoctorOfferingsSection({super.key, this.goLive, this.onAllClasses});

  /// The existing ClassCard for her soonest class (Start lives there).
  final Widget? goLive;

  /// "All your classes" under it, when she has more than one.
  final VoidCallback? onAllClasses;

  @override
  State<DoctorOfferingsSection> createState() => _DoctorOfferingsSectionState();
}

class _DoctorOfferingsSectionState extends State<DoctorOfferingsSection> {
  final _store = PvCommunityStore.instance;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) async {
      await _store.refreshMe();
      await _store.myOfferings();
      if (_store.me.isExpert) await _store.expertQueue();
    });
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final items = _store.myOfferingItems;
          final asks = _store.expertQueueItems.length;
          return Column(
            key: const ValueKey('doctor_home_offerings'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DcSectionHead('Your offerings',
                  note: items.length > 2 ? 'All ${items.length}' : (items.isEmpty ? null : 'Open'),
                  onNote: items.isEmpty ? null : () => openDoctorOfferings(context)),
              if (items.isEmpty && widget.goLive == null)
                const DcEmpty(
                  'No offerings yet',
                  'When ParentVeda links you to a masterclass or a cohort, it appears here with its discussion, its seats and a Start button.',
                  mark: DoctorMark.classes,
                ),
              if (items.isNotEmpty || _store.me.isExpert)
                DcRowGroup(children: [
                  for (final o in items.take(2))
                    DcRow(
                      mark: DoctorMark.classes,
                      title: [o.title, if (o.runLabel.isNotEmpty) o.runLabel].join(' · '),
                      subtitle: doctorOfferingLine(o),
                      trailing: o.unread > 0 ? DoctorCountBadge(o.unread) : null,
                      onTap: () => openDoctorOffering(context, o),
                    ),
                  if (_store.me.isExpert)
                    DcRow(
                      key: const ValueKey('doctor_home_queue_row'),
                      mark: DoctorMark.inbox,
                      title: 'Parents asking an expert to look',
                      subtitle: 'Community questions, oldest first',
                      trailing: asks > 0 ? DoctorCountBadge(asks) : null,
                      onTap: () => openDoctorCommunityQueue(context),
                    ),
                ]),
              if (widget.goLive != null) ...[
                const SizedBox(height: 12),
                widget.goLive!,
              ],
              if (widget.onAllClasses != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: widget.onAllClasses,
                    child: Text('All your classes', style: dcStrong(14, color: dcP.action)),
                  ),
                ),
            ],
          );
        },
      );
}

class DoctorOfferingsScreen extends StatefulWidget {
  const DoctorOfferingsScreen({super.key});

  @override
  State<DoctorOfferingsScreen> createState() => _DoctorOfferingsScreenState();
}

class _DoctorOfferingsScreenState extends State<DoctorOfferingsScreen> {
  final _store = PvCommunityStore.instance;
  bool _loaded = false;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _store.init().then((_) => _refresh());
  }

  Future<void> _refresh() async {
    final ok = await _store.myOfferings();
    await _store.expertQueue();
    if (mounted) {
      setState(() {
        _loaded = true;
        _offline = !ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: _store,
        builder: (context, _) {
          final items = _store.myOfferingItems;
          final asks = _store.expertQueueItems.length;
          return DcScreen(
            title: 'Your offerings',
            subtitle: 'Every course you lead or join as a guest. Open one to answer the parents and pin what matters.',
            onRefresh: _refresh,
            children: [
              if (_offline)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: DcNotice('Showing what was last loaded. Pull down to try again.'),
                ),
              if (!_loaded && items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                )
              else if (items.isEmpty)
                const DcEmpty(
                  'No offerings yet',
                  'When ParentVeda links you to a masterclass or a cohort as a host, it appears here with its discussion, its seats and its next session.',
                  mark: DoctorMark.classes,
                )
              else
                DcRowGroup(children: [
                  for (final o in items)
                    DcRow(
                      key: ValueKey('doctor_offering_${o.runId}'),
                      mark: DoctorMark.classes,
                      title: [o.title, if (o.runLabel.isNotEmpty) o.runLabel].join(' · '),
                      subtitle: doctorOfferingLine(o),
                      trailing: o.unread > 0 ? DoctorCountBadge(o.unread) : null,
                      onTap: () async {
                        await openDoctorOffering(context, o);
                        if (mounted) _refresh();
                      },
                    ),
                ]),
              const SizedBox(height: 22),
              DcRowGroup(children: [
                DcRow(
                  key: const ValueKey('doctor_offerings_queue_row'),
                  mark: DoctorMark.inbox,
                  title: 'Parents asking an expert to look',
                  subtitle: 'Community questions, oldest first',
                  trailing: asks > 0 ? DoctorCountBadge(asks) : null,
                  onTap: () => openDoctorCommunityQueue(context),
                ),
              ]),
            ],
          );
        },
      );
}
