// =============================================================================
//  Home — what needs attention, then what is coming
// -----------------------------------------------------------------------------
//  Airbnb's host Today tab and Future Pro's coach home, in that order:
//
//     Good morning, Dr Meera             ← who, and the one line under it
//     [Needs your attention]             ← 0..n rows, each ONE action:
//         add your bank account · a prescription owed · a class opening ·
//         no hours set · bookings paused
//     NEXT UP — the next consult as one big card with Join and Prescribe
//     LATER TODAY — the rest of the day as rows
//     THIS WEEK — calls · classes · we owe you        (taps into the tabs)
//     YOUR CLASSES — the next one, → all
//     TAKING BOOKINGS — the switch and the week in one line, → Availability
//
//  Nothing here is a second implementation: join goes through the same
//  green room as Appointments (doctor_class_launch), the money is the
//  ledger's, the hours are the schedule store's. The old dashboard
//  (doctor_home_screen.dart) is kept for revert; the stage toggle it carried
//  for testing now lives under Profile → Developer.
//
//  THE HERO (2026-09-19, audit #8b): a photograph of a place for the hour,
//  the date, the greeting, one line of information, her own photograph, and
//  the first card overlapping the band — see DcHero and doctor_hero_images.
//  Plus one new block, "How parents see you": her public card as the parent
//  side renders it, because the image every provider app has and wastes as a
//  24px avatar is the provider's own.
//
//  HOME V2 (2026-09-21, audit #8c). The first build was a stack of empty
//  cards and read as plain; the seller and host homes that feel full with
//  no data (Whatnot, eBay Selling, Twitch creator, Shopee, Fiverr, Revolut
//  Business, Airbnb host) never show an empty card. They show things to do,
//  the shape of the week, and content. So the spine is FIXED —
//
//     hero → quick actions → next up (or the week strip) → this week →
//     set up your practice (until 4 of 4) → needs you (≤3, see all) →
//     for you (three reads) → from ParentVeda → your classes → your card
//
//  — and the VARIABLE pile (prescriptions owed, a class opening, bookings
//  paused, the bank account) is computed once (doctor_tasks.dart) and shown
//  as a count on the bell, three rows at most, and the Inbox. The user's
//  question that led here: "is it fair to lead the home with 'add your bank
//  account'?" — Monzo, Deel, Jobber, Asana and Greenlight all say no.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../booking/booking_models.dart';
import '../../booking/prescription.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../data/reads/doctor_reads.dart';
import '../../data/reads/read_images.dart' show readImageFor;
import '../../doctor/doctor_directory.dart';
import '../../doctor/doctor_hero_images.dart';
import '../../doctor/doctor_ledger.dart';
import '../../doctor/doctor_roster.dart';
import '../../doctor/doctor_schedule.dart';
import '../../doctor/doctor_schedule_store.dart';
import '../../doctor/doctor_session.dart';
import '../../doctor/doctor_tasks.dart';
import '../../doctor/doctor_updates.dart' show doctorRelativeDay;
import '../../models/pv_read.dart';
import '../../theme/pv_fonts.dart' show PvType;
import '../reader/pv_reader_screen.dart';
import '../v2/v2_palette.dart' show v2BlockTint;
import 'doctor_chrome.dart';
import 'doctor_class_launch.dart';
import 'doctor_classes_screen.dart';
import 'doctor_art.dart';
import 'doctor_prescription_screen.dart';
import 'doctor_referral_kit_screen.dart';
import 'doctor_task_feed.dart';

class DoctorHomeTab extends StatelessWidget {
  const DoctorHomeTab({super.key, required this.goTo});
  final void Function(DoctorTab tab) goTo;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        DoctorSession.instance,
        DoctorRoster.instance,
        DoctorScheduleStore.instance,
        DoctorLedger.instance,
        PrescriptionStore.instance,
      ]),
      builder: (context, _) {
        final session = DoctorSession.instance;
        final e = session.consults ? doctorInfoById(session.expertId!) : null;
        final partner = PartnerDashboardStore.instance.partner;
        final name = e?.name ?? partner?.name ?? 'Your practice';
        final sub = e?.credential ?? (partner == null ? '' : CarePartnerType.label(partner.type));

        final roster = DoctorRoster.instance;
        final upcoming = e == null ? const <Booking>[] : roster.upcomingConsults(e.id);
        final sessions = e == null ? const <Offering>[] : roster.sessionsBy(e.id);
        final hosts = sessions.map(hostSessionFor).toList();
        final schedule = e == null ? null : DoctorScheduleStore.instance.scheduleFor(e.id);
        final ledger = DoctorLedger.instance;
        final profile = session.profile;

        final now = DateTime.now();
        final todayEnd = DateTime(now.year, now.month, now.day + 1);
        final weekEnd = DateTime(now.year, now.month, now.day + 7);
        final today = upcoming.where((b) => b.startsUtc.toLocal().isBefore(todayEnd)).toList();
        final next = upcoming.isEmpty ? null : upcoming.first;
        final thisWeek = upcoming.where((b) => b.startsUtc.toLocal().isBefore(weekEnd)).length;
        final slotsThisWeek = schedule == null ? 0 : DoctorScheduleStore.instance.preview(e!.id, days: 7).length;

        // ---- the one list everything variable is drawn from ----------------
        final feed = DoctorFeed.now();
        final tasks = feed.tasks;
        final pending = tasks.pending;
        final work = tasks.work;
        final setup = tasks.setup;
        final setupDone = tasks.setupDone;
        void openUpdates() => feed.openUpdates(context, goTo);
        void doTask(DoctorTask t) => feed.doTask(context, t, goTo);

        // The date is the eyebrow over the greeting, where a door's eyebrow
        // sits — alone in the top corner it read as lost (the user,
        // 2026-09-21: "that date at the top seems lonely").
        final hero = doctorHeroFor(now);
        return DcTab(
          title: e != null ? _greeting(name) : _greeting(null),
          subtitle: e != null ? (sub.isEmpty ? null : sub) : name,
          hero: DcHero(
            asset: hero.asset,
            eyebrow: doctorDateLine(now),
            greeting: e != null ? _greeting(name) : _greeting(null),
            infoLine: e == null
                ? name
                : _infoLine(
                    now: now,
                    today: today.length,
                    next: next,
                    slotsThisWeek: slotsThisWeek,
                    paused: schedule?.paused ?? false,
                    hasHours: schedule?.hasAnyHours ?? false,
                  ),
            facts: e == null
                ? const []
                : [
                    DcFact('${today.length}', 'today'),
                    DcFact('$thisWeek', 'this week'),
                    DcFact('$slotsThisWeek', schedule?.paused == true ? 'slots · paused' : 'slots open'),
                  ],
            photoUrl: e == null ? null : profile?.photoUrl,
            initial: e == null ? null : _initial(name),
            onAvatar: e == null ? null : () => goTo(DoctorTab.profile),
            // The bell: unread updates — news, not chores. Chores are the rail.
            badge: feed.unread,
            onBell: openUpdates,
          ),
          onRefresh: () async {
            await Future.wait([roster.refresh(), ledger.refresh(), session.loadProfile()]);
          },
          children: [
            // ---- 1. the card that rides into the band: NEXT UP, always --------
            // The day is the defined section. A nag never overlaps the photo.
            if (next != null)
              _NextCard(booking: next)
            else if (e != null && schedule != null)
              _WeekStrip(
                schedule: schedule,
                bookings: upcoming,
                classes: hosts,
                onDay: () => goTo(DoctorTab.appointments),
              )
            else
              const DcEmpty(
                'Nothing booked',
                'An organisation account sees its clinicians\' days from each of their apps.',
                mark: DoctorMark.calendar,
              ),
            const SizedBox(height: 14),

            // ---- 2. quick actions ------------------------------------------
            if (e != null) ...[
              _QuickActions(items: [
                _Quick(DoctorMark.hours, 'Hours', () => goTo(DoctorTab.availability)),
                _Quick(DoctorMark.prescribe, 'Prescribe', () => goTo(DoctorTab.appointments)),
                _Quick(DoctorMark.qr, 'QR kit', () => _openKit(context)),
                _Quick(DoctorMark.earnings, 'Earnings', () => goTo(DoctorTab.earnings)),
              ]),
              const SizedBox(height: 22),
            ],

            // ---- 3. this week: the strip when Next up took the top slot -------
            if (next != null && e != null && schedule != null) ...[
              const DcSectionHead('This week'),
              _WeekStrip(
                schedule: schedule,
                bookings: upcoming,
                classes: hosts,
                onDay: () => goTo(DoctorTab.appointments),
              ),
              const SizedBox(height: 10),
            ] else ...[
              const DcSectionHead('This week'),
            ],
            DcStatRow([
              DcStat('Consults', '$thisWeek', sub: 'next 7 days'),
              DcStat('Slots open', '$slotsThisWeek', sub: schedule?.paused == true ? 'paused' : 'this week'),
              DcStat('We owe you', dcRupees(ledger.summary.owedPaise),
                  sub: ledger.summary.nextPayout == null ? 'next payout' : 'on ${dcDate(ledger.summary.nextPayout!)}'),
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 18, children: [
              _link(context, 'Appointments', () => goTo(DoctorTab.appointments)),
              _link(context, 'Earnings', () => goTo(DoctorTab.earnings)),
            ]),
            // "Am I available or not" — the switch the brief asked for, kept on
            // Home so pausing a day never needs a second tab.
            if (e != null && schedule != null) ...[
              const SizedBox(height: 12),
              DcRowGroup(children: [
                DcSwitchRow(
                  mark: DoctorMark.hours,
                  title: schedule.paused ? 'Not taking bookings' : 'Taking bookings',
                  subtitle: _weekLine(schedule),
                  value: !schedule.paused,
                  onChanged: (on) {
                    DoctorScheduleStore.instance.save(e.id, schedule.copyWith(paused: !on));
                    dcToast(context, on ? 'Taking bookings again.' : 'Bookings paused. Existing ones stand.');
                  },
                ),
              ]),
            ],
            const SizedBox(height: 22),

            // ---- 4. needs you — ONE swipe rail: work first, then set-up ---------
            // 2026-09-21: the user asked for the chores as a horizontal
            // swipe, and for the bell to hold updates instead. Work (a
            // prescription owed, a class opening) leads; set-up steps follow;
            // finished set-up steps stay at the end, ticked, until all four
            // are done — then the rail is a single "caught up" card, never
            // nothing (a feature is never hidden).
            if (e != null) ...[
              DcSectionHead('Needs you',
                  note: pending.isEmpty ? null : '${pending.length} ${pending.length == 1 ? 'thing' : 'things'}'),
              _TaskRail(
                items: [...work, ...setup.where((t) => !t.done), if (setupDone < setup.length) ...setup.where((t) => t.done)],
                onTap: doTask,
              ),
              const SizedBox(height: 22),
            ],

            // ---- 6. for you: three reads with photographs ----------------------
            const DcSectionHead('For you', title: 'How the practice works here'),
            DcRowGroup(children: [
              for (final r in kDoctorReads) _ReadRow(read: r, onTap: () => _openRead(context, r)),
            ]),
            const SizedBox(height: 22),

            // ---- 7. from ParentVeda ---------------------------------------------
            if (session.notice != null) ...[
              const DcSectionHead('From ParentVeda'),
              DcCard(
                onTap: session.notice!.url == null ? null : () => launchUrl(Uri.parse(session.notice!.url!), mode: LaunchMode.externalApplication),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(session.notice!.title, style: dcStrong(16)),
                  if (session.notice!.body.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(session.notice!.body, style: dcMeta(14)),
                  ],
                  if (session.notice!.url != null) ...[
                    const SizedBox(height: 8),
                    Text('Open', style: dcStrong(14, color: dcP.action)),
                  ],
                ]),
              ),
              const SizedBox(height: 22),
            ],

            // ---- 8. classes -----------------------------------------------------
            DcSectionHead('Your classes',
                note: hosts.length > 1 ? 'All ${hosts.length}' : (hosts.isEmpty ? null : 'Open'),
                onNote: hosts.isEmpty ? null : () => _openClasses(context)),
            if (hosts.isEmpty)
              const DcEmpty(
                'No classes yet',
                'When ParentVeda assigns you a masterclass or a cohort, it appears here with its seats and a Start button.',
                mark: DoctorMark.classes,
              )
            else
              ClassCard(session: _soonest(hosts)),
            const SizedBox(height: 22),

            // ---- 9. how parents see you ----------------------------------------
            if (e != null) ...[
              const DcSectionHead('How parents see you'),
              _PublicCard(
                name: profile?.name ?? name,
                credential: profile?.credential ?? sub,
                category: profile?.category ?? e.category,
                location: profile?.location ?? '',
                photoUrl: profile?.photoUrl,
                feeInr: profile?.feeInr ?? 0,
                rating: profile?.rating ?? 0,
                blurb: profile?.blurb ?? e.blurb,
                initial: _initial(name),
              ),
            ],
          ],
        );
      },
    );
  }

  // ---- actions --------------------------------------------------------------

  void _openKit(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'doctor/referral-kit'),
      builder: (_) => const DoctorReferralKitScreen()));

  void _openRead(BuildContext context, PvRead r) => Navigator.of(context).push(MaterialPageRoute(
      settings: RouteSettings(name: 'doctor/read/${r.id}'),
      builder: (_) => PvReaderScreen(
            read: r,
            lang: PvType.lang,
            openRead: (ctx, id) {
              final next = doctorReadById(id);
              if (next != null) _openRead(ctx, next);
            },
          )));

  Widget _link(BuildContext context, String label, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(label, style: dcStrong(14, color: dcP.action)),
            Icon(Icons.chevron_right_rounded, size: 18, color: dcP.action),
          ]),
        ),
      );

  void _openClasses(BuildContext context) => Navigator.of(context).push(MaterialPageRoute(
      settings: const RouteSettings(name: 'doctor/classes'),
      builder: (_) => const DoctorClassesScreen()));

  static HostSession _soonest(List<HostSession> hosts) {
    final sorted = [...hosts]..sort((a, b) {
        if (a.openable != b.openable) return a.openable ? -1 : 1;
        final ad = a.scheduled ? a.next!.startsUtc : DateTime(2100);
        final bd = b.scheduled ? b.next!.startsUtc : DateTime(2100);
        return ad.compareTo(bd);
      });
    return sorted.first;
  }

  static String _initial(String name) {
    final n = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim();
    return n.isEmpty ? '?' : n.characters.first.toUpperCase();
  }

  /// The one line under the greeting. The parent hero's rule: the
  /// information IS the hero, so the line says the thing that matters most
  /// right now and nothing else.
  /// 2026-09-21: a sentence, not a dot-separated fragment — "Nothing today ·
  /// next Tue 22 Sep at 10:30 pm" made the user read it twice. The day is
  /// relative (today, tomorrow, on Thursday) because that is how she thinks
  /// about her week.
  static String? _infoLine({
    required DateTime now,
    required int today,
    required Booking? next,
    required int slotsThisWeek,
    required bool paused,
    required bool hasHours,
  }) {
    if (today > 0 && next != null) {
      final n = today == 1 ? 'One consultation today' : '$today consultations today';
      return '$n. The next one is at ${dcTime(next.startsUtc)}.';
    }
    if (next != null) {
      final when = doctorRelativeDay(next.startsUtc, now, dcDayDate);
      return 'Nothing on your calendar today. Your next consultation is $when at ${dcTime(next.startsUtc)}.';
    }
    if (paused) return 'Bookings are paused. Parents cannot book you until you switch them back on.';
    if (!hasHours) return 'Set your hours and parents can start booking you.';
    return slotsThisWeek > 0 ? 'A free day. $slotsThisWeek slots are open this week.' : 'A free day, and nothing booked this week yet.';
  }

  /// "Mon–Sat · 10am–1pm, 5–8pm" — the week in one line.
  static String _weekLine(DoctorSchedule s) {
    if (!s.hasAnyHours) return 'No hours set';
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final working = [for (var d = 1; d <= 7; d++) if (s.dayFor(d).isWorking) d];
    final contiguous = working.length == working.last - working.first + 1;
    final days = contiguous && working.length > 2
        ? '${names[working.first - 1]}–${names[working.last - 1]}'
        : working.map((d) => names[d - 1]).join(', ');
    final first = s.dayFor(working.first).sessions;
    final same = working.every((d) => s.dayFor(d).sessions.toString() == first.toString());
    final hours = same ? first.map(_compactSession).join(', ') : 'hours vary by day';
    return '$days · $hours';
  }

  /// "10am–1pm", "5–8pm": the meridian once when both ends share it, no ":00".
  static String _compactSession(Session x) {
    String part(int m, {required bool withMeridian}) {
      final h24 = (m ~/ 60) % 24;
      final mm = m % 60;
      final h = h24 % 12 == 0 ? 12 : h24 % 12;
      final min = mm == 0 ? '' : ':${mm.toString().padLeft(2, '0')}';
      return '$h$min${withMeridian ? (h24 < 12 ? 'am' : 'pm') : ''}';
    }
    final sameHalf = ((x.start ~/ 60) % 24 < 12) == ((x.end ~/ 60) % 24 < 12);
    return '${part(x.start, withMeridian: !sameHalf)}–${part(x.end, withMeridian: true)}';
  }

  static String _greeting(String? name) {
    final h = DateTime.now().hour;
    final g = h < 12 ? 'Good morning' : h < 17 ? 'Good afternoon' : 'Good evening';
    if (name == null) return g;
    final short = name.replaceAll(RegExp(r'^(Dr|Prof)\.?\s*'), '').trim().split(' ').first;
    return short.isEmpty ? g : '$g, ${name.startsWith('Dr') ? 'Dr $short' : short}';
  }
}

// ---- quick actions ----------------------------------------------------------

class _Quick {
  const _Quick(this.mark, this.label, this.onTap);
  final DoctorMark mark;
  final String label;
  final VoidCallback onTap;
}

/// Four ink icons in soft wells with one word each — Revolut Business's row
/// under the big number, Shopee's grid, Liven's strip. The fastest answer to
/// "what can I do here", and the thing every empty first week lacked.
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.items});
  final List<_Quick> items;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    return Row(children: [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0) const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            onTap: items[i].onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(children: [
                DoctorArtTile(mark: items[i].mark, p: p, size: 56, radius: 18),
                const SizedBox(height: 7),
                Text(items[i].label, style: dcStrong(12.5), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
          ),
        ),
      ],
    ]);
  }
}

// ---- the week strip ---------------------------------------------------------

/// Seven days from today: the letter, the date, and under each a mark —
/// a dot for a working day, a count where something is booked, nothing on
/// a closed day. Today wears an ink ring. Ten Percent Happier's and Noom's
/// week dots; the shape of a week a doctor with no bookings still owns.
class _WeekStrip extends StatelessWidget {
  const _WeekStrip({required this.schedule, required this.bookings, required this.classes, required this.onDay});
  final DoctorSchedule schedule;
  final List<Booking> bookings;
  final List<HostSession> classes;
  final VoidCallback onDay;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final now = DateTime.now();
    const letters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return DcCard(
      onTap: onDay,
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      child: Row(children: [
        for (var i = 0; i < 7; i++)
          Expanded(child: Builder(builder: (_) {
            final d = DateTime(now.year, now.month, now.day + i);
            final isToday = i == 0;
            final working = schedule.dayFor(d.weekday).isWorking && !schedule.timeOff.any((t) => t.covers(d));
            final count = bookings.where((b) {
                  final l = b.startsUtc.toLocal();
                  return l.year == d.year && l.month == d.month && l.day == d.day;
                }).length +
                classes.where((h) {
                  if (!h.scheduled || h.next == null) return false;
                  final l = h.next!.startsUtc.toLocal();
                  return l.year == d.year && l.month == d.month && l.day == d.day;
                }).length;
            return Column(children: [
              Text(letters[d.weekday - 1], style: dcEyebrow(color: isToday ? p.ink1 : p.ink3)),
              const SizedBox(height: 6),
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isToday ? p.ink1 : Colors.transparent,
                  border: working && !isToday ? Border.all(color: p.line, width: 1.2) : null,
                ),
                child: Text('${d.day}', style: dcStrong(14, color: isToday ? p.surface : (working ? p.ink1 : p.ink3))),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 18,
                child: count > 0
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        decoration: BoxDecoration(color: v2BlockTint(206, p), borderRadius: BorderRadius.circular(999)),
                        child: Text('$count', style: dcStrong(11.5)),
                      )
                    : (working
                        ? Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: p.ink3))
                        : const SizedBox.shrink()),
              ),
            ]);
          })),
      ]),
    );
  }
}

// ---- set up your practice ---------------------------------------------------

/// eBay's "New seller checklist", Whatnot's "Get started — step 3 of 4":
/// a horizontal rail of cards, each with a drawn mark, a title, one line
/// and one verb; done ones ticked and quiet. Since 2026-09-21 it carries
/// the work too (a prescription owed, a class opening), work first.
class _TaskRail extends StatelessWidget {
  const _TaskRail({required this.items, required this.onTap});
  final List<DoctorTask> items;
  final void Function(DoctorTask) onTap;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    // Undone first, so the next thing is the first thing.
    final ordered = [...items.where((t) => !t.done), ...items.where((t) => t.done)];
    if (ordered.isEmpty) {
      return const DcRowGroup(children: [
        DcRow(mark: DoctorMark.done, markRing: true, title: 'You are all caught up', subtitle: 'Prescriptions, classes, your calendar and your set-up — nothing waiting.', chevron: false),
      ]);
    }
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: ordered.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final t = ordered[i];
          return SizedBox(
            width: 236,
            child: DcCard(
              onTap: t.done ? null : () => onTap(t),
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  DoctorArtTile(mark: t.done ? DoctorMark.done : doctorMarkForTask(t.id), p: p, size: 44, radius: 13, muted: t.done),
                  const Spacer(),
                  if (t.done) Text('Done', style: dcStrong(12.5, color: p.ink3)),
                ]),
                const SizedBox(height: 10),
                Text(t.title, style: dcStrong(15, color: t.done ? p.ink3 : null), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Expanded(child: Text(t.body, style: dcMeta(12.5), maxLines: 2, overflow: TextOverflow.ellipsis)),
                if (!t.done) Text(t.action, style: dcStrong(13.5, color: p.action)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ---- for you ----------------------------------------------------------------

/// A read as a row: the photograph as a 64pt thumbnail, the title, the
/// teaser. Airbnb's "Resources for hosting now".
class _ReadRow extends StatelessWidget {
  const _ReadRow({required this.read, required this.onTap});
  final PvRead read;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final url = readImageFor(read.id, own: read.imageUrl);
    final well = Container(color: v2BlockTint(read.hue, p));
    return DcRow(
      title: read.title.en,
      subtitle: read.teaser.en,
      onTap: onTap,
      leading: SizedBox(
        width: 64,
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: url == null
              ? well
              : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, _, _) => well,
                  loadingBuilder: (_, child, prog) => prog == null ? child : well),
        ),
      ),
    );
  }
}

class _NextCard extends StatelessWidget {
  const _NextCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    final p = dcP;
    final patient = DoctorRoster.instance.patientFor(b.id, stage: b.stage);
    final ctx = patient.contextLine(b.startsUtc);
    final now = DateTime.now();
    final start = b.startsUtc.toLocal();
    final isToday = start.year == now.year && start.month == now.month && start.day == now.day;
    final mins = start.difference(now).inMinutes;
    final soon = mins <= 10 && mins >= -b.durationMin;
    return DcCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.surfaceAlt, shape: BoxShape.circle),
            child: Text(patient.displayName.characters.first.toUpperCase(), style: dcNum(20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(patient.displayName, style: dcStrong(17), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (ctx.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(ctx, style: dcMeta(13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Icon(Icons.event_outlined, size: 16, color: p.ink3),
          const SizedBox(width: 6),
          Text(
            isToday
                ? 'Today · ${dcTime(b.startsUtc)} · ${b.durationMin} min'
                : '${dcDayDate(b.startsUtc)} · ${dcTime(b.startsUtc)} · ${b.durationMin} min',
            style: dcStrong(14),
          ),
          if (soon) ...[
            const SizedBox(width: 10),
            const DcStatusPill('Starting', hue: 104),
          ],
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: ObPrimary(
              p: p,
              label: soon ? 'Join now' : 'Join',
              leading: Icon(Icons.videocam_rounded, size: 18, color: p.surface),
              onTap: () => openConsult(context, b, waitingFor: patient.displayName),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ObSecondary(
              p: p,
              label: 'Prescribe',
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'doctor/prescribe'),
                  builder: (_) => DoctorPrescriptionScreen(bookingId: b.id, title: b.title))),
            ),
          ),
        ]),
      ]),
    );
  }
}

/// Her public card, as a parent's directory renders it — photo, name,
/// credential, category, fee, rating — and the About text one tap away.
/// Read-only here: a public profile is an editorial act (STILL-OPEN §5.1),
/// so the card says who to write to rather than offering an Edit.
class _PublicCard extends StatelessWidget {
  const _PublicCard({
    required this.name,
    required this.credential,
    required this.category,
    required this.location,
    required this.photoUrl,
    required this.feeInr,
    required this.rating,
    required this.blurb,
    required this.initial,
  });
  final String name;
  final String credential;
  final String category;
  final String location;
  final String? photoUrl;
  final int feeInr;
  final double rating;
  final String blurb;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final meta = [
      if (category.isNotEmpty) category,
      if (location.isNotEmpty) location,
    ].join(' · ');
    return DcCard(
      onTap: () => _open(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: photoUrl == null
                ? Center(child: Text(initial, style: dcNum(26)))
                : Image.network(photoUrl!, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Center(child: Text(initial, style: dcNum(26)))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: dcStrong(16.5), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (credential.isNotEmpty) Text(credential, style: dcMeta(13.5), maxLines: 2, overflow: TextOverflow.ellipsis),
              if (meta.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(meta, style: dcMeta(13, color: p.ink3), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ]),
          ),
          Icon(Icons.chevron_right_rounded, size: 24, color: p.ink3),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          if (feeInr > 0) ...[
            _pill(p, Icons.currency_rupee_rounded, '${dcRupees(feeInr * 100)} a consultation'),
            const SizedBox(width: 8),
          ],
          if (rating > 0) _pill(p, Icons.star_rounded, rating.toStringAsFixed(1)),
          if (feeInr <= 0 && rating <= 0) _pill(p, Icons.visibility_outlined, 'Listed to parents'),
        ]),
      ]),
    );
  }

  Widget _pill(dynamic p, IconData icon, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: p.surfaceAlt, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: p.ink2),
          const SizedBox(width: 5),
          Text(label, style: dcStrong(12.5)),
        ]),
      );

  void _open(BuildContext context) => dcSheet<void>(
        context,
        title: 'How parents see you',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: dcTitle(24)),
          if (credential.isNotEmpty) ...[const SizedBox(height: 4), Text(credential, style: dcMeta(14.5))],
          if (blurb.isNotEmpty) ...[const SizedBox(height: 14), Text(blurb, style: dcBody(15, h: 1.55))],
          const SizedBox(height: 16),
          const DcNotice('This is your public profile. Changes are made by ParentVeda — write to partners@parentveda.com with what to update.'),
          const SizedBox(height: 8),
        ]),
      );
}
