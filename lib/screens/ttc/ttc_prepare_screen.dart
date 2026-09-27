// =============================================================================
//  TTC - Prepare
// -----------------------------------------------------------------------------
//  "Prepare no longer prepares for birth. It prepares for conception."
//                                                       - TTC master, §2.6
//
//  Everything here runs on the EXISTING booking engine: real Offerings, real
//  slots generated from real availability, real entitlements. A fertility
//  consult booked on this screen appears in the same My Bookings history as a
//  birthing class booked eight months later, because there is one engine.
//
//  Payment is stubbed and says so on screen - the same honesty the rest of the
//  product keeps. Buying grants the entitlement without money moving.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../booking/booking_models.dart';
import '../../booking/booking_store.dart';
import '../../ttc/ttc_prepare_data.dart';
import '../../ttc/ttc_chapter.dart';
import '../../ttc/ttc_store.dart';
import 'ttc_common.dart';
import 'ttc_garbh_course_screen.dart';
import 'ttc_strings.dart';
import '../learn/pv_learn_screen.dart';
import '../../services/life_stage_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../learn/pv_offering_screen.dart';
import '../learn/pv_learn_catalog.dart';

// ⚠️ FACADE since 2026-09-20 (docs/LEARNING-AUDIT.md). The class keeps its
// name and constructor so every push of it lands on the unified learn
// screens; the body below is kept, byte for byte, as `TtcPrepareScreenClassic` for
// revert. Nothing pushes the Classic (test/pv_learn_test.dart holds that).
class TtcPrepareScreen extends StatelessWidget {
  const TtcPrepareScreen({super.key, this.onlyCategory});
  final String? onlyCategory;

  /// The nine Prepare categories, still the stage's vocabulary for the
  /// topic chips; kept on the facade so callers and tests keep one name.
  static List<(String, String, String)> get categories => ttcPrepareCategories;

  @override
  Widget build(BuildContext context) => PvLearnScreen(
        stage: LifeStage.tryingToConceive,
        // The page says what it holds (launch walk, 2026-09-27): "Talk to an
        // expert" opened a page titled "Learn".
        title: switch (onlyCategory) {
          'consults' => 'Talk to an expert',
          'courses' => 'Courses',
          // The unscoped list is what You calls it (2026-09-27): it opened
          // under "Learn", which is a tab of its own.
          null => 'Programmes and sessions',
          _ => null,
        },
        kind: switch (onlyCategory) {
          'consults' => PvLearnKind.consult,
          'courses' => PvLearnKind.course,
          _ => null,
        },
        topic: onlyCategory == 'consults' || onlyCategory == 'courses' ? null : onlyCategory,
      );
}

/// The pre-2026-09-20 body. Kept for revert; nothing pushes it.
class TtcPrepareScreenClassic extends StatelessWidget {
  const TtcPrepareScreenClassic({super.key, this.onlyCategory});

  /// Show one category instead of all nine.
  ///
  /// ⚠️ THREE DIFFERENT DOORS LANDED HERE UNSCOPED — "Speak to a fertility
  /// specialist", "Improve sperm health", and every consult closing. All three
  /// opened the same page and asked her to scroll past yoga, nutrition and
  /// lifestyle to reach the one card she had just tapped a button about.
  ///
  /// ⚠️ AND THE CODE CLAIMED OTHERWISE. A comment on `kTtcActConsult` said "the
  /// hub it was tapped from is the context a resolver uses to pick the right
  /// specific offer". That resolver did not exist. A comment describing
  /// behaviour the implementation does not have is worse than no comment: it
  /// stops the next person from checking.
  final String? onlyCategory;

  /// The nine Prepare categories from the master document, §2.6.
  static List<(String, String, String)> get categories => ttcPrepareCategories;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([BookingStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        return TtcPage(
          tab: 1,
          header: const TtcHeader(),
          children: [
            // Eyebrow carries WHERE she is, the way pregnancy's Prepare says
            // "30 WEEKS · THIRD TRIMESTER". "PREPARE" alone told her nothing
            // she did not already know from the tab she just tapped.
            ttcEyebrow(
                '${t.tabPrepare.toUpperCase()} · '
                '${TtcStore.instance.today.chapter.title(hi).toUpperCase()}',
                color: ttcCoral),
            const SizedBox(height: 8),
            // Fraunces, matching pregnancy's serif Prepare headline. This is
            // the commerce surface, and it was the plainest page in the stage.
            Text(t.prepareTitle,
                style: ttcFraunces(26, w: FontWeight.w600, color: ttcTitleInk)),
            const SizedBox(height: 10),
            Text(t.prepareBody, style: ttcBody(14, h: 1.6)),
            const SizedBox(height: 20),

            for (final (id, en, hiName) in ttcPrepareCategories.where((e) =>
                onlyCategory == null || e.$1 == onlyCategory)) ...[
              ttcEyebrow(hi ? hiName : en, color: ttcPurple),
              const SizedBox(height: 11),
              for (final o in ttcOfferingsIn(id)) ...[
                _OfferingCard(offering: o, t: t),
                const SizedBox(height: 11),
              ],
              const SizedBox(height: 10),
            ],

            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, size: 15, color: ttcMuted),
              const SizedBox(width: 9),
              Expanded(
                child: Text(t.prepareNoPayment,
                    style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
              ),
            ]),
          ],
        );
      },
    );
  }
}

class _OfferingCard extends StatelessWidget {
  const _OfferingCard({required this.offering, required this.t});

  final TtcOffering offering;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final hi = t.hinglish;
    final entitlement =
        BookingStore.instance.activeEntitlementFor(offering.id);
    return TtcCard(
      onTap: () => _open(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Text(offering.title(hi), style: ttcJakarta(16))),
          const SizedBox(width: 10),
          Text(offering.priceLabel, style: ttcJakarta(15, color: ttcPurple)),
        ]),
        const SizedBox(height: 8),
        Text(offering.body(hi), style: ttcBody(13, h: 1.55)),
        const SizedBox(height: 12),
        Row(children: [
          if (offering.forCouple) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                  color: ttcCoralTint,
                  borderRadius: BorderRadius.circular(999)),
              child: Text(t.prepareForBoth,
                  style: ttcBody(10, color: ttcCoral, w: FontWeight.w800)),
            ),
            const SizedBox(width: 8),
          ],
          Text(t.prepareSessions(offering.sessions),
              style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
          const Spacer(),
          if (entitlement != null)
            Text(t.prepareOwned,
                style: ttcBody(12, color: ttcPurple, w: FontWeight.w800))
          else
            const Icon(Icons.arrow_forward_rounded, size: 17, color: ttcMuted),
        ]),
      ]),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => TtcOfferingScreen(offering: offering),
      settings: RouteSettings(name: 'ttc/offering/${offering.id}'),
    ));
  }
}

// =============================================================================
//  One offering, and its real slots
// =============================================================================

// ⚠️ FACADE since 2026-09-20 (docs/LEARNING-AUDIT.md). The class keeps its
// name and constructor so every push of it lands on the unified learn
// screens; the body below is kept, byte for byte, as `TtcOfferingScreenClassic` for
// revert. Nothing pushes the Classic (test/pv_learn_test.dart holds that).
class TtcOfferingScreen extends StatelessWidget {
  const TtcOfferingScreen({super.key, required this.offering});
  final TtcOffering offering;
  @override
  Widget build(BuildContext context) {
    final v = PvLearnCatalog.instance.byId(offering.id);
    return v == null ? TtcOfferingScreenClassic(offering: offering) : PvOfferingScreen(view: v);
  }
}

/// The pre-2026-09-20 body. Kept for revert; nothing pushes it.
class TtcOfferingScreenClassic extends StatelessWidget {
  const TtcOfferingScreenClassic({super.key, required this.offering});

  final TtcOffering offering;

  @override
  Widget build(BuildContext context) {
    // ⚠️ ONE OFFERING IS NOT A BOOKING, AND THE REDIRECT LIVES HERE RATHER THAN
    // AT THE FOUR CALL SITES. The free garbh sanskar course has no slot, no
    // expert to meet and nothing to pay, so this screen drew it as a ₹0 price
    // tag, a "Buy" button and an empty slot list — which is exactly the "price,
    // upsell or locked session" its own brief forbids. Four places construct
    // this screen (the shelf, two focus tiles, Ask Veda and the semen report);
    // guarding each one is four chances to miss the fifth.
    if (offering.id == kTtcOfferingGarbhCourse) {
      return const TtcGarbhCourseScreen();
    }

    return AnimatedBuilder(
      animation: Listenable.merge([BookingStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final hi = t.hinglish;
        final store = BookingStore.instance;
        final entitlement = store.activeEntitlementFor(offering.id);
        final slots = BookingCatalog.instance.slotsFor(offering.id);

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.tabPrepare),
                const SizedBox(height: 16),
                Text(offering.title(hi),
                    style:
                        ttcFraunces(25, w: FontWeight.w600, color: ttcTitleInk)),
                const SizedBox(height: 12),
                Text(offering.body(hi),
                    style: ttcBody(14.5, color: ttcInk, h: 1.68)),
                const SizedBox(height: 20),

                TtcCard(
                  color: ttcPanel,
                  child: Row(children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.prepareSessions(offering.sessions),
                                style: ttcBody(12.5,
                                    color: ttcSoft, w: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(offering.priceLabel,
                                style: ttcJakarta(22, color: ttcPurple)),
                          ]),
                    ),
                    if (entitlement == null)
                      GestureDetector(
                        onTap: () => _buy(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 13),
                          decoration: BoxDecoration(
                              color: ttcPurple,
                              borderRadius: BorderRadius.circular(15)),
                          child: Text(t.prepareBuy,
                              style: ttcBody(13.5,
                                  color: Colors.white, w: FontWeight.w800)),
                        ),
                      )
                    else
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(t.prepareOwned,
                                style: ttcBody(12.5,
                                    color: ttcPurple, w: FontWeight.w800)),
                            const SizedBox(height: 3),
                            Text(
                                t.prepareCreditsLeft(
                                    entitlement.creditsTotal -
                                        entitlement.creditsUsed),
                                style: ttcBody(11.5, color: ttcMuted)),
                          ]),
                  ]),
                ),
                const SizedBox(height: 20),

                // Real times, from the real engine. Stored UTC, shown local.
                ttcSectionTitle(t.prepareSlots),
                if (entitlement == null)
                  TtcCard(
                    color: ttcPanel,
                    child: Text(t.prepareBuyFirst, style: ttcBody(13.5, h: 1.5)),
                  )
                else if (slots.isEmpty)
                  TtcEmpty(
                    icon: Icons.event_busy_outlined,
                    title: t.prepareNoSlots,
                    body: t.prepareNoSlotsBody,
                  )
                else
                  for (final slot in slots.take(8)) ...[
                    _SlotRow(slot: slot, t: t),
                    const SizedBox(height: 10),
                  ],

                const SizedBox(height: 16),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 15, color: ttcMuted),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(t.prepareNoPayment,
                        style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
                  ),
                ]),
              ],
            ),
          ),
        );
      },
    );
  }

  void _buy(BuildContext context) {
    final o = BookingCatalog.instance.offeringById(offering.id);
    if (o == null) return;
    BookingStore.instance.purchase(o);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(TtcS.current().prepareBought),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.t});

  final Slot slot;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    // Stored UTC, shown local - the engine's rule, kept here.
    final local = slot.startsUtc.toLocal();
    final booked = BookingStore.instance
        .bookings()
        .any((b) => b.slotId == slot.id && b.status == BookingStatus.upcoming);
    return TtcCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: booked ? null : () => _book(context),
      child: Row(children: [
        const Icon(Icons.schedule_rounded, size: 17, color: ttcPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Text(_fmt(local),
              style: ttcBody(13.5, color: ttcInk, w: FontWeight.w600)),
        ),
        Text(booked ? t.prepareBooked : t.prepareBook,
            style: ttcBody(12.5,
                color: booked ? ttcMuted : ttcPurple, w: FontWeight.w800)),
      ]),
    );
  }

  Future<void> _book(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final t = TtcS.current();
    // Seat claims are server-authoritative - the store's reserve() is the only
    // path, and it can legitimately refuse.
    final booking = await BookingStore.instance.reserve(slot);
    messenger.showSnackBar(SnackBar(
      content: Text(booking == null ? t.prepareBookFailed : t.prepareBooked),
      behavior: SnackBarBehavior.floating,
    ));
  }

  static String _fmt(DateTime d) {
    const m = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'am' : 'pm';
    final min = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} · $h:$min$ampm';
  }
}
