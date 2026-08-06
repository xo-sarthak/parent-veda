// =============================================================================
//  BookingCatalog — the bridge from display models to the booking engine
// -----------------------------------------------------------------------------
//  The engine trades in Offerings and Slots; the app's catalogue is the rich
//  display models (YogaClass / LearningProgram / …). This file DERIVES an
//  Offering for every bookable catalogue item automatically, rather than
//  hand-listing them — so a new yoga class or masterclass is bookable the moment
//  it is added, with nothing to wire, and the two can never drift out of sync.
//
//  WHAT IS BOOKABLE (and what is not):
//    * Yoga  — live group  -> a class-pack (4 credits, 30 days)
//              live 1:1     -> a consult   (1 credit, pick day+time) [calendar]
//              recorded     -> NOT bridged; it plays, it isn't booked.
//    * Learning — masterclass -> buy once, one airing + recording + thread
//                 live cohort -> dated group, seat-capped, thread
//                 recorded course -> NOT bridged; it plays.
//    * Experts (doctors/dietitians) — NOT auto-bridged. They are a designed mix
//      of in-app consults and outbound Practo referrals, so which ones book
//      in-app is a decision, not a derivation. Left for that call.
//
//  TIME IS REAL. Slots are generated as genuine upcoming DateTimes from now
//  (never the old "Sun 13 Jul" strings), deterministically from the item's id
//  so they are stable between reads. This is SEED availability: when an expert
//  (or admin) enters real times, offerings and slots come from Supabase and this
//  generation falls away — the store, screens and reminders are unaffected,
//  because they only ever see Offering/Slot, never this bridge.
// =============================================================================

import '../data/prepare_data.dart';
import '../doctor/doctor_availability.dart'; // retired, kept for revert
import '../doctor/doctor_schedule.dart';
import '../doctor/doctor_schedule_store.dart';
import '../screens/post_pregnancy/pp_experts_data.dart';
import '../screens/post_pregnancy/pp_learning_data.dart';
import '../screens/post_pregnancy/pp_yoga_data.dart';
import '../ttc/ttc_prepare_data.dart';
import '../services/expert_store.dart';
import 'booking_models.dart';
import 'booking_store.dart';

class BookingCatalog {
  BookingCatalog._();
  static final BookingCatalog instance = BookingCatalog._();

  List<Offering>? _cache;

  List<Offering> get _all {
    if (_cache != null) return _cache!;
    final list = <Offering>[];
    for (final y in kYogaClasses) {
      final o = _fromYoga(y);
      if (o != null) list.add(o);
    }
    // Merged, not the bundled const: a masterclass published in the admin
    // panel has to become a bookable offering too, or it renders on the
    // Courses screen and then cannot be bought — visible and inert.
    for (final p in mergedLearningPrograms()) {
      final o = _fromLearning(p);
      if (o != null) list.add(o);
    }
    // In-app doctor/specialist consults (Practo dropped — everything books here).
    // MERGED, not the bundled const: a doctor added in the admin panel has to
    // become a bookable offering too, or they render on the consult screen and
    // then cannot be booked — visible and inert, the same defect the merged
    // programmes call fixed one line above.
    for (final e in mergedExperts()) {
      final o = _fromExpert(e);
      if (o != null) list.add(o);
    }
    // PREGNANCY side — the Prepare tab's programs and specialists, so a mother's
    // history spans both stages from one engine.
    for (final p in kPrepPrograms) {
      final o = _fromPrep(p);
      if (o != null) list.add(o);
    }
    for (final s in kSpecialists) {
      list.add(_fromSpecialist(s));
    }
    // TRYING-TO-CONCEIVE side — the Prepare tab of the stage before pregnancy.
    // Same engine again, so a fertility consult booked while trying and a
    // birthing class booked eight months later sit in ONE history.
    for (final o in ttcOfferings) {
      list.add(_fromTtc(o));
    }
    return _cache = list;
  }

  List<Offering> offerings({ServiceStage? stage}) => _all
      .where((o) => stage == null || o.stage == stage)
      .toList(growable: false);

  Offering? offeringById(String id) {
    for (final o in _all) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// The offering that stands in for a given catalogue (display) item, if it is
  /// bookable. Screens call this: a non-null result means "run the real flow".
  Offering? offeringForCatalog(String catalogId) {
    for (final o in _all) {
      if (o.catalogId == catalogId) return o;
    }
    return null;
  }

  /// Upcoming, bookable slots for an offering — future only, soonest first,
  /// full ones dropped. Recorded/subscription offerings return nothing.
  List<Slot> slotsFor(String offeringId, {DateTime? now}) {
    final o = offeringById(offeringId);
    if (o == null) return const [];
    final at = (now ?? DateTime.now()).toUtc();
    return _generate(o, at)
        .where((s) => s.startsUtc.isAfter(at) && !s.isFull)
        .toList()
      ..sort((a, b) => a.startsUtc.compareTo(b.startsUtc));
  }

  // ---------------------------------------------------------------------------
  //  Derivation — catalogue item -> Offering
  // ---------------------------------------------------------------------------

  /// Prenatal / labour-breathing classes belong to the pregnancy journey, so a
  /// booking made from one files under Pregnancy even though the same catalogue
  /// serves both tabs. Everything else is parenting.
  static ServiceStage _yogaStage(YogaClass y) =>
      (y.category == 'prenatal' || y.category == 'breathing')
          ? ServiceStage.pregnancy
          : ServiceStage.parenting;

  static Offering? _fromYoga(YogaClass y) {
    switch (y.mode) {
      case YogaMode.recorded:
        return null; // plays, not booked
      case YogaMode.liveGroup:
        return Offering(
          id: 'off_${y.id}',
          stage: _yogaStage(y),
          kind: OfferingKind.classPack,
          format: SessionFormat.liveGroup,
          catalogId: y.id,
          title: y.title,
          expertId: _slug(y.instructorName),
          priceMinor: _minor(y.price),
          grant: const EntitlementGrant(credits: 4, validFor: Duration(days: 30)),
        );
      case YogaMode.liveOneToOne:
        return Offering(
          id: 'off_${y.id}',
          stage: _yogaStage(y),
          kind: OfferingKind.consult,
          format: SessionFormat.liveOneToOne,
          catalogId: y.id,
          title: y.title,
          expertId: _slug(y.instructorName),
          priceMinor: _minor(y.price),
          grant: const EntitlementGrant(credits: 1, validFor: Duration(days: 21)),
        );
    }
  }

  static Offering? _fromLearning(LearningProgram p) {
    switch (p.kind) {
      case LearningKind.recordedCourse:
        return null; // plays, not booked
      case LearningKind.masterclass:
        return Offering(
          id: 'off_${p.id}',
          stage: ServiceStage.parenting,
          kind: OfferingKind.masterclass,
          format: SessionFormat.liveGroup,
          catalogId: p.id,
          title: p.title,
          expertId: p.instructorId,
          priceMinor: _minor(p.price),
          grant: const EntitlementGrant(
              credits: 1, recordingAccess: true, discussionThread: true),
        );
      case LearningKind.liveCohort:
        return Offering(
          id: 'off_${p.id}',
          stage: ServiceStage.parenting,
          kind: OfferingKind.cohort,
          format: SessionFormat.liveGroup,
          catalogId: p.id,
          title: p.title,
          expertId: p.instructorId,
          priceMinor: _minor(p.price),
          grant: const EntitlementGrant(
              credits: 1, discussionThread: true, validFor: Duration(days: 60)),
        );
    }
  }

  /// A doctor/specialist with real availability becomes an in-app 1:1 consult —
  /// the calendar case, on a doctor. An expert with no timings set is not
  /// bookable (a light profile, or an instructor whose product is their
  /// sessions), so it is skipped.
  static Offering? _fromExpert(Expert e) {
    if (e.timings.trim().isEmpty) return null;
    return Offering(
      id: 'off_exp_${e.id}',
      stage: ServiceStage.parenting,
      kind: OfferingKind.consult,
      format: SessionFormat.liveOneToOne,
      catalogId: e.id,
      title: 'Consult · ${e.name}',
      expertId: e.id,
      priceMinor: e.priceValue * 100,
      grant: const EntitlementGrant(credits: 1, validFor: Duration(days: 21)),
    );
  }

  /// Pregnancy Prepare program -> Offering. Courses (recorded) are not booked;
  /// masterclasses and cohorts are.
  static Offering? _fromPrep(PrepProgram p) {
    switch (p.kind) {
      case PrepKind.course:
        return null;
      case PrepKind.masterclass:
        return Offering(
          id: 'off_pg_${p.id}',
          stage: ServiceStage.pregnancy,
          kind: OfferingKind.masterclass,
          format: SessionFormat.liveGroup,
          catalogId: p.id,
          title: p.title.now,
          expertId: _slug(p.instructorName.now),
          priceMinor: _minor(p.price),
          grant: const EntitlementGrant(
              credits: 1, recordingAccess: true, discussionThread: true),
        );
      case PrepKind.cohort:
        return Offering(
          id: 'off_pg_${p.id}',
          stage: ServiceStage.pregnancy,
          kind: OfferingKind.cohort,
          format: SessionFormat.liveGroup,
          catalogId: p.id,
          title: p.title.now,
          expertId: _slug(p.instructorName.now),
          priceMinor: _minor(p.price),
          grant: const EntitlementGrant(
              credits: 1, discussionThread: true, validFor: Duration(days: 60)),
        );
    }
  }

  /// Pregnancy specialist -> in-app 1:1 consult (the calendar case).
  /// A Trying-to-Conceive catalogue entry becomes a real Offering, filed under
  /// [ServiceStage.tryingToConceive] so it lands in the same history as every
  /// other stage rather than in a parallel one.
  static Offering _fromTtc(TtcOffering o) {
    final kind = switch (o.kind) {
      'consult' => OfferingKind.consult,
      'cohort' => OfferingKind.cohort,
      'classPack' => OfferingKind.classPack,
      _ => OfferingKind.masterclass,
    };
    return Offering(
      id: o.id,
      stage: ServiceStage.tryingToConceive,
      kind: kind,
      // A consult is 1:1; everything else here is taught live to a small group.
      format: kind == OfferingKind.consult
          ? SessionFormat.liveOneToOne
          : SessionFormat.liveGroup,
      catalogId: o.id,
      title: o.titleEn,
      expertId: o.expertId,
      priceMinor: o.priceMinor,
      grant: EntitlementGrant(
        credits: o.sessions,
        // A class pack is the "redeem any time" case; the rest are dated.
        validFor: kind == OfferingKind.classPack
            ? const Duration(days: 60)
            : null,
        recordingAccess: kind == OfferingKind.masterclass,
        discussionThread: kind == OfferingKind.cohort,
      ),
    );
  }

  static Offering _fromSpecialist(Specialist s) => Offering(
        id: 'off_pg_${s.id}',
        stage: ServiceStage.pregnancy,
        kind: OfferingKind.consult,
        format: SessionFormat.liveOneToOne,
        catalogId: s.id,
        title: 'Consult · ${s.name}',
        expertId: s.id,
        priceMinor: _minor(s.consultPrice),
        grant: const EntitlementGrant(credits: 1, validFor: Duration(days: 21)),
      );

  // ---------------------------------------------------------------------------
  //  Slot generation — real upcoming DateTimes, deterministic per item
  // ---------------------------------------------------------------------------

  static List<Slot> _generate(Offering o, DateTime at) {
    final seed = o.catalogId.hashCode & 0x7fffffff;
    switch (o.kind) {
      case OfferingKind.classPack:
        return _recurring(at, o, seed,
            weekdays: _weekdays(seed),
            hour: 6 + seed % 4, // 6–9am
            durationMin: 45,
            capacity: 18 + seed % 8,
            count: 9);
      case OfferingKind.consult:
        // PHASE 3: the doctor's schedule IS the slot list. What they set in
        // Availability is what a parent sees - same engine, same rules, no
        // second source of truth to drift.
        //
        // The fallback calendar stays for a doctor who has genuinely set
        // nothing: an empty booking screen reads as "broken app" rather than
        // "this doctor has not opened their diary". Once a doctor has saved a
        // schedule, their schedule is the ONLY thing consulted - including when
        // it says they are unavailable.
        if (DoctorScheduleStore.instance.hasSetUp(o.expertId)) {
          return _fromSchedule(at, o);
        }
        return _calendar(at, o, seed);
      case OfferingKind.masterclass:
        return _oneOff(at, o,
            daysAhead: 5 + seed % 4,
            hour: 20,
            durationMin: 75,
            capacity: 100,
            seatsTaken: 40 + seed % 45);
      case OfferingKind.cohort:
        return _oneOff(at, o,
            daysAhead: 8 + seed % 6,
            hour: 19,
            durationMin: 60,
            capacity: 50,
            seatsTaken: 18 + seed % 25);
      case OfferingKind.subscription:
        return const [];
    }
  }

  /// The next [count] occurrences of [weekdays] at [hour]:00 local — a recurring
  /// group class.
  static List<Slot> _recurring(
    DateTime from,
    Offering o,
    int seed, {
    required Set<int> weekdays,
    required int hour,
    required int durationMin,
    required int capacity,
    int count = 9,
  }) {
    final local = from.toLocal();
    final out = <Slot>[];
    var day = DateTime(local.year, local.month, local.day);
    var guard = 0, i = 0;
    while (out.length < count && guard < 60) {
      guard++;
      day = day.add(const Duration(days: 1));
      if (!weekdays.contains(day.weekday)) continue;
      final start = DateTime(day.year, day.month, day.day, hour);
      if (start.isBefore(local)) continue;
      out.add(Slot(
        id: '${o.id}_r$i',
        offeringId: o.id,
        expertId: o.expertId,
        startsUtc: start.toUtc(),
        durationMin: durationMin,
        capacity: capacity,
        booked: (seed + i) % (capacity + 1),
      ));
      i++;
    }
    return out;
  }

  /// THE CALENDAR CASE. Several days ahead, a few times on each — the shape a
  /// 1:1 needs: pick a day, then a time. Capacity 1, and some slots pre-taken so
  /// the availability reads like a real calendar rather than a blank grid.
  static List<Slot> _calendar(DateTime from, Offering o, int seed) {
    final local = from.toLocal();
    final times = <List<int>>[
      [10, 0],
      [17, 0],
      [18, 30],
    ];
    final out = <Slot>[];
    var day = DateTime(local.year, local.month, local.day);
    var guard = 0, idx = 0;
    while (out.length < 12 && guard < 20) {
      guard++;
      day = day.add(const Duration(days: 1));
      if (day.weekday == DateTime.sunday) continue; // no Sundays
      for (final t in times) {
        final start = DateTime(day.year, day.month, day.day, t[0], t[1]);
        if (start.isBefore(local)) continue;
        out.add(Slot(
          id: '${o.id}_c$idx',
          offeringId: o.id,
          expertId: o.expertId,
          startsUtc: start.toUtc(),
          durationMin: 50,
          capacity: 1,
          booked: (seed + idx) % 4 == 0 ? 1 : 0, // ~1 in 4 already taken
        ));
        idx++;
      }
    }
    return out;
  }

  /// A doctor's schedule turned into the slots a parent may book.
  ///
  /// Everything that decides whether a time is offered - sessions, duration,
  /// buffers, per-day and consecutive caps, notice, advance window, time off,
  /// date overrides, pause - lives in generateSlots(). This function only
  /// dresses the result as booking-engine Slots. That split is the point: the
  /// doctor's preview and the parent's list are literally the same computation.
  static List<Slot> _fromSchedule(DateTime from, Offering o) {
    final schedule = DoctorScheduleStore.instance.scheduleFor(o.expertId);
    final now = from.toLocal();

    // Times already taken, so nothing is offered twice. Matched on offeringId:
    // a consult offering is one-per-doctor (off_exp_<id>), so this is exactly
    // "this doctor's booked times". Local, because the schedule works in local
    // wall-clock (IST).
    //
    // NOTE this is the LOCAL view. The authoritative guard against two parents
    // taking the same minute stays the server: book_slot in 0029 locks the row.
    // This only stops us OFFERING something we already know is gone.
    final booked = BookingStore.instance
        .bookings()
        .where((b) =>
            b.offeringId == o.id && b.status != BookingStatus.cancelled)
        .map((b) => b.startsUtc.toLocal())
        .toSet();

    final generated = generateSlots(
      schedule,
      from: now,
      days: schedule.rules.advanceWindowDays,
      booked: booked,
      now: now,
    );

    return [
      for (var i = 0; i < generated.length; i++)
        Slot(
          // Stable across rebuilds: the same minute always yields the same id,
          // so a slot a parent is looking at does not change identity under
          // them mid-booking.
          id: '${o.id}_s${generated[i].start.millisecondsSinceEpoch}',
          offeringId: o.id,
          expertId: o.expertId,
          startsUtc: generated[i].start.toUtc(),
          durationMin: generated[i].durationMin,
          capacity: 1, // a 1:1 consultation is one seat, by definition
          booked: 0,
        ),
    ];
  }

  /// RETIRED (Phase 3): the old weekday+hour windows, fixed at 50 minutes and
  /// blind to buffers, caps, notice, time off and pause. Superseded by
  /// _fromSchedule. Kept for revert alongside doctor_availability.dart.
  // ignore: unused_element
  static List<Slot> _fromAvailability(
      DateTime from, Offering o, List<AvailWindow> wins) {
    final local = from.toLocal();
    final byDay = <int, List<AvailWindow>>{};
    for (final w in wins) {
      (byDay[w.weekday] ??= []).add(w);
    }
    final out = <Slot>[];
    var day = DateTime(local.year, local.month, local.day);
    var guard = 0, idx = 0;
    while (out.length < 24 && guard < 28) {
      guard++;
      day = day.add(const Duration(days: 1));
      final ws = byDay[day.weekday];
      if (ws == null) continue;
      for (final w in ws) {
        final start = DateTime(day.year, day.month, day.day, w.hour, w.minute);
        if (start.isBefore(local)) continue;
        out.add(Slot(
          id: '${o.id}_a$idx',
          offeringId: o.id,
          expertId: o.expertId,
          startsUtc: start.toUtc(),
          durationMin: 50,
          capacity: 1,
          booked: 0,
        ));
        idx++;
      }
    }
    return out;
  }

  /// A single dated session — a masterclass airing or a cohort kickoff.
  static List<Slot> _oneOff(
    DateTime from,
    Offering o, {
    required int daysAhead,
    required int hour,
    required int durationMin,
    required int capacity,
    int seatsTaken = 0,
  }) {
    final local = from.toLocal().add(Duration(days: daysAhead));
    final start = DateTime(local.year, local.month, local.day, hour);
    return [
      Slot(
        id: '${o.id}_s0',
        offeringId: o.id,
        expertId: o.expertId,
        startsUtc: start.toUtc(),
        durationMin: durationMin,
        capacity: capacity,
        booked: seatsTaken.clamp(0, capacity),
      ),
    ];
  }

  // ---------------------------------------------------------------------------
  //  helpers
  // ---------------------------------------------------------------------------

  /// Three weekdays, chosen deterministically so a class always recurs on the
  /// same days between reads.
  static Set<int> _weekdays(int seed) {
    switch (seed % 3) {
      case 0:
        return {DateTime.monday, DateTime.wednesday, DateTime.friday};
      case 1:
        return {DateTime.tuesday, DateTime.thursday, DateTime.saturday};
      default:
        return {DateTime.monday, DateTime.thursday, DateTime.saturday};
    }
  }

  static int _minor(String price) {
    final m = RegExp(r'[\d,]+').firstMatch(price);
    if (m == null) return 0; // "Free on ParentVeda+"
    return (int.tryParse(m.group(0)!.replaceAll(',', '')) ?? 0) * 100;
  }

  static String _slug(String name) =>
      name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
}
