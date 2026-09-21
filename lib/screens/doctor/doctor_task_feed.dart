// =============================================================================
//  The task feed — the pending list and what each verb does, for every tab
// -----------------------------------------------------------------------------
//  Every tab carries the bell (2026-09-21: money and patients do not wait for
//  Home), so the lists that feed it are computed here from the stores, once
//  per build, and the verb-to-action map lives beside them. Home, the
//  Updates panel and the other four tabs cannot drift, because there is one
//  of each.
//
//  Two lists, deliberately: TASKS are chores (a prescription owed, no bank
//  account yet) and live on Home as a rail; UPDATES are news (a parent
//  booked, money came in, a class is next week) and live behind the bell.
//  The bell's count is unread updates, never the chore count — a doctor who
//  has read her notifications should see a quiet bell even with work left.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../booking/booking_models.dart';
import '../../booking/prescription.dart';
import '../../doctor/doctor_directory.dart';
import '../../doctor/doctor_ledger.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../doctor/doctor_session.dart';
import '../../doctor/doctor_tasks.dart';
import '../../doctor/doctor_updates.dart';
import 'doctor_appointments_tab.dart' show DoctorAppointmentsTab;
import 'doctor_chrome.dart';
import 'doctor_class_launch.dart';
// import 'doctor_inbox_screen.dart'; // kept for revert — see openInbox below
import 'doctor_classes_screen.dart';
import 'doctor_payouts_screen.dart';
import 'doctor_payout_account_screen.dart';
import 'doctor_photo_sheet.dart';
import 'doctor_referral_kit_screen.dart';
import 'doctor_updates_screen.dart';

/// The scaffold's tabs, so a screen can send the doctor to one by name.
enum DoctorTab { home, appointments, availability, earnings, profile }

/// Everything the tabs derive together, read from the stores in one place.
class DoctorFeed {
  DoctorFeed._({
    required this.tasks,
    required this.updates,
    required this.next,
    required this.liveClasses,
  });

  final List<DoctorTask> tasks;
  final List<DoctorUpdate> updates;
  final Booking? next;
  final List<HostSession> liveClasses;

  List<DoctorTask> get pending => tasks.pending;

  /// The bell's number: what she has not looked at yet.
  int get unread => DoctorUpdatesRead.instance.unread(updates);

  /// Reads the stores. Call inside a ListenableBuilder over them.
  factory DoctorFeed.now() {
    final session = DoctorSession.instance;
    final e = session.consults ? doctorInfoById(session.expertId!) : null;
    final roster = DoctorRoster.instance;
    final ledger = DoctorLedger.instance;
    final upcoming = e == null ? const <Booking>[] : roster.upcomingConsults(e.id);
    final past = e == null ? const <Booking>[] : roster.pastConsults(e.id);
    final hosts = (e == null ? const <Offering>[] : roster.sessionsBy(e.id)).map(hostSessionFor).toList();
    final schedule = e == null ? null : DoctorScheduleStore.instance.scheduleFor(e.id);
    final next = upcoming.isEmpty ? null : upcoming.first;
    final now = DateTime.now();
    final owedRx = past.where((b) => b.status != BookingStatus.cancelled && !PrescriptionStore.instance.hasFor(b.id)).length;
    final live = hosts.where((h) => h.openable && h.scheduled).toList();
    final tasks = doctorTasks(DoctorTaskInput(
      consults: e != null,
      accountKnown: ledger.accountKnown,
      hasAccount: ledger.account != null,
      accountRejected: ledger.account?.status == 'rejected',
      hasHours: schedule?.hasAnyHours ?? true,
      paused: schedule?.paused ?? false,
      qrPrinted: session.qrKitOpened,
      hasPhoto: session.profile?.photoUrl != null,
      prescriptionsOwed: owedRx,
      classesOpenNow: live.length,
      nextClassTitle: live.isEmpty ? null : live.first.offering.title,
      callInMinutes: next?.startsUtc.toLocal().difference(now).inMinutes,
      callWith: next == null ? null : roster.patientFor(next.id, stage: next.stage).displayName,
    ));
    final updates = doctorUpdates(DoctorUpdateInput(
      now: now,
      upcoming: [
        for (final b in upcoming)
          UpdateBooking(
            id: b.id,
            who: _who(roster.patientFor(b.id, stage: b.stage).displayName),
            startsAt: b.startsUtc.toLocal(),
            durationMin: b.durationMin,
            bookedAt: b.bookedUtc.toLocal(),
          ),
      ],
      classes: [
        for (final h in hosts)
          if (h.scheduled && h.next != null)
            UpdateClass(id: h.next!.id, title: h.offering.title, kind: h.kindLabel, startsAt: h.next!.startsUtc.toLocal(), seats: h.next!.booked),
      ],
      earnings: [
        for (final r in ledger.rowsFor(null))
          UpdateEarning(
            id: r.id,
            headline: r.headline,
            source: r.source.singular,
            at: r.occurredAt.toLocal(),
            expertPaise: r.expertPaise,
            reversal: r.isReversal,
            note: r.note,
          ),
      ],
      payouts: [
        for (final p in ledger.payouts)
          UpdatePayout(
            id: p.id,
            amountPaise: p.amountPaise,
            status: p.status,
            at: (p.paidAt ?? p.periodTo).toLocal(),
            bankLast4: p.bankLast4,
            reference: p.reference,
          ),
      ],
      notices: [
        if (session.notice != null)
          UpdateNotice(
            id: session.notice!.id,
            title: session.notice!.title,
            body: session.notice!.body,
            at: session.notice!.startsAt?.toLocal() ?? now,
            url: session.notice!.url,
          ),
      ],
      rupees: dcRupees,
      dayDate: dcDayDate,
      time: dcTime,
    ));
    return DoctorFeed._(tasks: tasks, updates: updates, next: next, liveClasses: live);
  }

  /// "A parent" when the server has no name — never an empty subject.
  static String _who(String name) => name.trim().isEmpty ? 'A parent' : name.trim();

  /// The bell: the updates panel. Opening it marks everything on it read.
  void openUpdates(BuildContext context, void Function(DoctorTab) goTo) {
    Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'doctor/updates'),
      builder: (_) => DoctorUpdatesScreen(updates: updates, onOpen: (ctx, u) => openUpdate(ctx, u, goTo)),
    ));
  }

  /// One place decides where an update leads.
  void openUpdate(BuildContext context, DoctorUpdate u, void Function(DoctorTab) goTo) {
    switch (u.kind) {
      case DoctorUpdateKind.booking:
      case DoctorUpdateKind.callSoon:
        final n = next;
        if (u.kind == DoctorUpdateKind.callSoon && n != null && n.id == u.refId) {
          openConsult(context, n, waitingFor: DoctorRoster.instance.patientFor(n.id, stage: n.stage).displayName);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
          goTo(DoctorTab.appointments);
        }
      case DoctorUpdateKind.classSoon:
        final live = liveClasses.where((h) => h.next?.id == u.refId).toList();
        if (live.isNotEmpty) {
          openHostSession(context, live.first);
        } else {
          Navigator.of(context).push(MaterialPageRoute(
              settings: const RouteSettings(name: 'doctor/classes'), builder: (_) => const DoctorClassesScreen()));
        }
      case DoctorUpdateKind.earning:
      case DoctorUpdateKind.reversal:
        Navigator.of(context).popUntil((r) => r.isFirst);
        goTo(DoctorTab.earnings);
      case DoctorUpdateKind.payout:
      case DoctorUpdateKind.payoutScheduled:
        Navigator.of(context).push(MaterialPageRoute(
            settings: const RouteSettings(name: 'doctor/payouts'), builder: (_) => const DoctorPayoutsScreen()));
      case DoctorUpdateKind.notice:
        final url = u.refId;
        if (url != null && url.isNotEmpty) launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // Kept for revert (2026-09-21): the bell used to open the task list.
  // void openInbox(BuildContext context, void Function(DoctorTab) goTo) => Navigator.of(context).push(MaterialPageRoute(
  //       settings: const RouteSettings(name: 'doctor/inbox'),
  //       builder: (_) => DoctorInboxScreen(tasks: tasks, onTask: (ctx, t) => doTask(ctx, t, goTo)),
  //     ));

  /// One place decides what a task's verb does.
  void doTask(BuildContext context, DoctorTask t, void Function(DoctorTab) goTo) {
    switch (t.id) {
      case 'class_open':
        if (liveClasses.isNotEmpty) openHostSession(context, liveClasses.first);
      case 'call_soon':
        final n = next;
        if (n != null) {
          openConsult(context, n, waitingFor: DoctorRoster.instance.patientFor(n.id, stage: n.stage).displayName);
        }
      case 'rx_owed':
        DoctorAppointmentsTab.openOn = 2; // Past — where the owed ones are
        goTo(DoctorTab.appointments);
      case 'paused':
      case 'setup_hours':
        goTo(DoctorTab.availability);
      case 'account_rejected':
      case 'setup_account':
        Navigator.of(context).push(MaterialPageRoute(
            settings: const RouteSettings(name: 'doctor/payout-account'),
            builder: (_) => const DoctorPayoutAccountScreen()));
      case 'setup_qr':
        Navigator.of(context).push(MaterialPageRoute(
            settings: const RouteSettings(name: 'doctor/referral-kit'),
            builder: (_) => const DoctorReferralKitScreen()));
      case 'setup_photo':
        showDoctorPhotoSheet(context);
    }
  }
}

/// The stores every tab should listen to for the bell to stay right.
Listenable doctorFeedListenable() => Listenable.merge([
      DoctorSession.instance,
      DoctorRoster.instance,
      DoctorScheduleStore.instance,
      DoctorLedger.instance,
      PrescriptionStore.instance,
      DoctorUpdatesRead.instance,
    ]);

/// The date line every hero carries.
String doctorDateLine(DateTime now) {
  const wd = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  const mo = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
  return '${wd[now.weekday - 1]} ${now.day} ${mo[now.month - 1]}';
}
