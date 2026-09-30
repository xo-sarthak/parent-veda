// =============================================================================
//  TtcMoreTab — the fifth tab: what ParentVeda offers beyond the other four
// -----------------------------------------------------------------------------
//  Built 2026-09-29. The user, on build 18: the bento was "poor", and "what was
//  the purpose of this 5th tab when you have replicated the same thing inside
//  the top left profile". The avatar and More opened the SAME screen. So the
//  two are split by one question, what the row is ABOUT:
//
//    · About HER (who she is, her answers, her partner, her notes for the
//      doctor, her settings): Profile, from the avatar
//      (`pv_you_screen.dart`, with one Settings row into
//      `pv_settings_screen.dart`).
//    · What the app OFFERS that Today, Learn, Products and Tools do not
//      (experts, courses, groups, her journey's map, benefits): here.
//      Kept for revert (2026-09-29): "(experts, courses, groups, what she
//      booked and ordered, her journey's map, benefits)".
//    · What she HAS booked or bought (Your orders, Your bookings): her
//      profile, two tiles under its hero; delivery addresses: Settings,
//      Account (2026-09-29, the lead with the user, from Ro, Deliveroo,
//      Instacart and Etsy on Mobbin).
//
//  No account, settings, support, preferences or developer row is on this
//  page, on either side. `test/ttc_more_profile_test.dart` fails the build if
//  one comes back, and holds every former You row in exactly one of the three
//  (the ledger is `kTtcFormerYouRows` below).
//
//  THE SHAPE, and where it came from (Mobbin, 2026-09-29):
//
//   * CRED, explore CRED: a page title, then small SECTION HEADINGS (money,
//     bills, payments, explore) with what is offered under each; in its list
//     view every row is a drawn object in a round well, a name and one grey
//     line. "The heading with tabs under it", as the user put it. The
//     settings gear sits apart, top right, never in the list.
//     https://mobbin.com/screens/a2ceda47-8542-4ef8-840e-5faae3d72b54
//     https://mobbin.com/screens/4ecd5dbc-c3c9-441f-a82c-4bfc5981005a
//     https://mobbin.com/screens/221e85e8-4b31-4c47-b2d5-93122764f1e6
//     (its "benefits" heading holds refer and earn: our Benefits section)
//   * Klarna, a More page: a serif-weight heading per purpose, rows of icon,
//     name, one line and a chevron under it, nothing boxed twice.
//     https://mobbin.com/screens/f363dff4-92cd-424c-97c2-9bb8a0e8eb3c
//   * Hims, Care: the tab titled for care, headed groups of what can be
//     booked, each group its own row set.
//     https://mobbin.com/screens/91d3fe31-7ed1-4db3-8034-555c5e17393a
//   * Oura, labs: one row says what it is and what it costs in the same
//     line of sight ("Check 50+ biomarkers for $99"). Our price on the right.
//     https://mobbin.com/screens/5a63c1a6-e847-467f-9bbf-dc61a2a47c6d
//   * Air NZ and American Airlines, More: page title, then headed groups of
//     white rows; the pattern our You screen already used, so the page reads
//     as ParentVeda, not as a new app.
//     https://mobbin.com/screens/ad6427c7-d12c-4d78-8ecf-a66d7431d197
//     https://mobbin.com/screens/fc1f8834-6649-4621-8650-64af6f22dd6d
//
//  WHAT WAS NOT TAKEN: CRED's black ground and 3D renders, and its support
//  row (the user: support belongs in Settings). Our rows draw the TTC door
//  family (`TtcTabArt`, an object on a disc of the section's tint), the marks
//  the door rails already wear, so More looks like the doors and not like
//  Material's icon set.
//
//  ⚠️ PAID LOOKS THE SAME EVERYWHERE: the price, then an ink "Paid" pill with
//  a lock (`TtcOfferTag`), the same words as the door cards' paid tag. Free
//  says Free. A consult nobody is on the roster to take says "Coming soon" and
//  shows no price, because a price on something she cannot book reads as a
//  price she could pay (TTC launch sanity H16).
//
//  ⚠️ HIS MORE (TtcPartnerMode.on) shows only what is for him or for both of
//  them, by the offering's own `forCouple` flag, plus the andrologist and the
//  partner workshop. Nothing on this page is hers alone: her doctor notes and
//  her answers live on HER profile, which his side never draws.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_store.dart';
import '../../data/learn/pv_learn_view.dart';
import '../../localization/app_language.dart';
import '../../services/entitlement_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pv_order_store.dart';
import '../../services/life_stage_store.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_prepare_data.dart'
    show kTtcOfferingAndrologist, kTtcOfferingGarbhCourse, ttcOfferingById;
import '../../ttc/ttc_chapter.dart' show TtcChapterCopy;
import '../../ttc/ttc_content_prefs.dart';
import '../../ttc/ttc_store.dart';
import '../../widgets/pv_nav_bar.dart' show pvNavClearance;
import '../enterprise/employer_benefits_screen.dart';
import '../learn/pv_learn_catalog.dart';
import '../learn/pv_offering_screen.dart' show pvOpenOffering;
// The shared learning screen, not the parenting facade that wraps it
// (TTC imports no parenting screen, test/ttc_shell_test.dart).
// Kept for revert (2026-09-29, bookings and orders moved to the profile):
// import '../learn/pv_my_learning_screen.dart' show PvMyLearningScreen;
// import '../products/pv_orders_screen.dart';
import '../products/pv_store_chrome.dart' show kPvLine, pvStorePalette;
// Kept for revert (2026-09-29, addresses moved to Settings, Account):
// import '../profile/pv_you_sheets.dart' show showPvAddressesSheet;
import '../referral/invite_friends_screen.dart';
import '../v2/v2_palette.dart' show V2Palette, v2BlockTint;
import 'doors/ttc_tab_art.dart';
import 'ttc_all_reads_screen.dart';
import 'ttc_all_videos_screen.dart';
import 'ttc_chapter_screen.dart' show openTtcChapter;
import 'ttc_more_marks.dart';
import 'ttc_prepare_screen.dart' show TtcPrepareScreen;
import 'ttc_strings.dart' show TtcPartnerMode;
import 'ttc_tab_root_header.dart';
import 'ttc_tools_screen.dart' show ttcMovedToMoreById;
import 'ttc_common.dart' show ttcTitleInk, ttcSectionHeadingStyle;

/// The page's title. The bar's pill says the same word.
const String kTtcMoreTitle = 'More';

/// The section headings, in order. Tests and the ledger read these.
const String kTtcMoreExpertsHeading = 'Talk to an expert';
const String kTtcMoreCoursesHeading = 'Courses and masterclasses';
// ⚠️ "COHORTS", NOT "GROUPS" (2026-09-30, the user: "Groups" sounds like a
// community, which this is not; it sells cohort programmes, a few weeks of
// live calls with a small group). Kept for revert: 'Groups'.
const String kTtcMoreGroupsHeading = 'Cohorts';
/// ⚠️ NO LONGER DRAWN (2026-09-29): the section moved to the profile.
/// Kept so the tests can hold that it stays gone.
const String kTtcMoreBookingsHeading = 'Your bookings and orders';
const String kTtcMoreJourneyHeading = 'Your journey';
/// Every article and every film, A to Z (2026-09-29, the user: "if someone
/// wants to read all the articles or watch all the videos, that section
/// should also be made").
const String kTtcMoreReadWatchHeading = 'Read and watch';
const String kTtcMoreBenefitsHeading = 'Benefits';

/// The one link under the three offering sections: the whole catalogue.
const String kTtcMoreAllProgrammes = 'All programmes and sessions';

/// The consult section's link to the full consult list (the former "Talk to
/// an expert" row's destination, 'ttc/consults').
const String kTtcMoreSeeAllConsults = 'See all consults';

// ---- the ledger ---------------------------------------------------------------

/// Where a row lives after the split.
enum TtcRowHome { profile, settings, more }

/// ⚠️ EVERY ROW THE OLD TTC YOU / MORE BENTO HAD, AND WHERE IT WENT
/// (2026-09-29). Key: the old row's title. Value: its one home, and the words
/// it wears there (a row renamed to say what it is keeps its destination).
/// `test/ttc_more_profile_test.dart` pumps all three screens and checks that
/// each label is on its home and on neither of the other two, so "nothing
/// lost, nothing twice" is a failing test, not a promise.
const Map<String, (TtcRowHome, String)> kTtcFormerYouRows = {
  // Profile: about her.
  'Saved': (TtcRowHome.profile, 'Saved'),
  'Notes for your doctor': (TtcRowHome.profile, 'Notes for your doctor'),
  // The row that opened her answers is now the section that shows them.
  'Your answers': (TtcRowHome.profile, 'YOUR ANSWERS'),
  'I got a positive test': (TtcRowHome.profile, 'I got a positive test'),
  'Your partner': (TtcRowHome.profile, 'Your partner'),
  // Settings: how the app behaves for her, her account, help.
  'Messages': (TtcRowHome.settings, 'Messages'),
  'What you see': (TtcRowHome.settings, 'What you see'),
  'Language': (TtcRowHome.settings, 'Language'),
  'Reminders': (TtcRowHome.settings, 'Reminders'),
  'WhatsApp updates': (TtcRowHome.settings, 'WhatsApp updates'),
  'Get help now': (TtcRowHome.settings, 'Get help now'),
  'Help': (TtcRowHome.settings, 'Help'),
  'About ParentVeda': (TtcRowHome.settings, 'About ParentVeda'),
  'Not signed in': (TtcRowHome.settings, 'Not signed in'),
  'Data and privacy': (TtcRowHome.settings, 'Data and privacy'),
  'Delete account': (TtcRowHome.settings, 'Delete account'),
  // More: what the app offers.
  'Talk to an expert': (TtcRowHome.more, kTtcMoreSeeAllConsults),
  'Courses': (TtcRowHome.more, 'Preconception garbh sanskar'),
  'All programmes and sessions': (TtcRowHome.more, kTtcMoreAllProgrammes),
  // ⚠️ WHAT SHE BOUGHT OR BOOKED IS ON HER PROFILE (2026-09-29): two tiles
  // under the hero; the addresses went to Settings, Account. Kept for revert:
  //   'Bookings': (TtcRowHome.more, 'Bookings'),
  //   'Orders': (TtcRowHome.more, 'Orders'),
  //   'Addresses': (TtcRowHome.more, 'Delivery addresses'),
  'Bookings': (TtcRowHome.profile, 'Your bookings'),
  'Orders': (TtcRowHome.profile, 'Your orders'),
  'Addresses': (TtcRowHome.settings, 'Delivery addresses'),
  // Left More on 2026-09-30 (the user; see the Your journey note below). It has
  // no home in the three pages now. Kept for revert:
  //   'Journey map': (TtcRowHome.more, 'Journey map'),
  'Invite a friend': (TtcRowHome.more, 'Invite a friend'),
  'Employer benefits': (TtcRowHome.more, 'Employer benefits'),
};

// ---- the tag ----------------------------------------------------------------

enum TtcOfferKind { paid, free, comingSoon }

/// The one tag a priced thing wears on More: "Paid" with a lock in an ink
/// pill, "Free" outlined, "Coming soon" on the quiet ground. The door cards'
/// paid tag says the same word (ttc_focus_screen.dart's "Paid" chip).
class TtcOfferTag extends StatelessWidget {
  const TtcOfferTag(this.kind, {super.key});
  final TtcOfferKind kind;

  static String label(TtcOfferKind k) => switch (k) {
        TtcOfferKind.paid => 'Paid',
        TtcOfferKind.free => 'Free',
        TtcOfferKind.comingSoon => 'Coming soon',
      };

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final paid = kind == TtcOfferKind.paid;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: paid
            ? ttcTitleInk
            : (kind == TtcOfferKind.comingSoon ? p.surfaceAlt : Colors.white),
        borderRadius: BorderRadius.circular(999),
        border: kind == TtcOfferKind.free ? Border.all(color: kPvLine) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (paid) ...[
          const Icon(Icons.lock_outline_rounded, size: 11, color: Colors.white),
          const SizedBox(width: 3),
        ],
        Text(
          label(kind),
          style: pvManrope(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: paid ? Colors.white : p.ink2,
          ),
        ),
      ]),
    );
  }
}

// ---- the data -----------------------------------------------------------------

/// One row: a drawn mark, a name, one line, and what it costs.
class TtcMoreRow {
  const TtcMoreRow({
    required this.id,
    required this.art,
    required this.title,
    required this.line,
    required this.open,
    this.price,
    this.tag,
  });
  final String id;
  /// The drawn mark, for the section's tint (`ttc_more_marks.dart`).
  final TtcArtBuilder art;
  final String title;
  final String line;
  final String? price;
  final TtcOfferKind? tag;
  final void Function(BuildContext) open;
}

/// One headed section. [link] is an optional words-link beside the heading.
class TtcMoreSection {
  const TtcMoreSection({
    required this.id,
    required this.title,
    required this.hue,
    required this.rows,
    this.lead,
    this.link,
    this.onLink,
  });
  final String id;
  final String title;
  final String? lead;
  final double hue;
  final List<TtcMoreRow> rows;
  final String? link;
  final void Function(BuildContext)? onLink;
}

void _push(BuildContext c, Widget w, String name) => Navigator.of(c).push(
      MaterialPageRoute<void>(
          builder: (_) => w, settings: RouteSettings(name: name)),
    );

/// Whether an offering is for him too: the offering's own `forCouple`, plus
/// the two that are about him. An offering the TTC table does not know (a
/// Directus row) is shown, because hiding it would hide a feature.
bool ttcMoreForHim(PvOfferingView v) {
  if (v.id == kTtcOfferingAndrologist || v.id == 'ttc_partner_workshop') {
    return true;
  }
  final o = ttcOfferingById(v.id);
  return o == null || o.forCouple;
}

TtcArtBuilder _markFor(PvOfferingView v) => switch (v.id) {
      // The general fertility consult is what Tools' old "Talk to an
      // expert" row opened, so it wears that row's mark; the others wear
      // the object of their specialty from the door family.
      'ttc_consult_fertility' => ttcArtTool('expert'),
      'ttc_consult_gynae' => ttcArtTab(TtcTabMark.tulip),
      kTtcOfferingAndrologist => ttcArtTab(TtcTabMark.sprout),
      'ttc_nutrition_consult' => ttcArtTab(TtcTabMark.bowl),
      'ttc_psych_consult' => ttcArtTab(TtcTabMark.twoBubbles),
      'ttc_assessment_couple' => ttcArtTab(TtcTabMark.vialReport),
      // The free course is the former "Courses" row: the Tools mark for it.
      kTtcOfferingGarbhCourse => ttcArtTool('courses'),
      'ttc_course_basics' => ttcArtTab(TtcTabMark.magnifier),
      'ttc_partner_workshop' => ttcArtTab(TtcTabMark.twoFigures),
      'ttc_yoga_pack' => ttcArtTab(TtcTabMark.lotus),
      'ttc_course_pcos' => ttcArtTab(TtcTabMark.windowRing),
      'ttc_loss_support' => ttcArtTab(TtcTabMark.heartHand),
      'ttc_ivf_prep' => ttcArtTab(TtcTabMark.timelineDots),
      'ttc_lifestyle_90' => ttcArtTab(TtcTabMark.scale),
      _ => switch (v.kind) {
          PvLearnKind.consult => ttcArtTool('expert'),
          PvLearnKind.cohort => ttcArtTab(TtcTabMark.twoFigures),
          _ => ttcArtTab(TtcTabMark.openBook),
        },
    };

/// "Dr Surbhi Sharma · IVF gynaecologist, Bloom IVF": the person and what
/// they are. A two-part role ("Couple assessment · IVF gynaecologist") keeps
/// the part that names the doctor, since the row's title names the consult.
String _consultLine(PvOfferingView v) {
  if (pvLearnHasNoNamedPerson(v)) return "We're adding a specialist";
  final role = v.expert.role.contains(' · ')
      ? v.expert.role.split(' · ').last
      : v.expert.role;
  // One doctor runs two consults (the gynaecologist's own and the couple
  // assessment): who joins tells the two lines apart, as the consult list
  // does with its role prefix.
  final both = v.facts.any((f) => f.value == 'Both of you');
  return [
    v.expert.name,
    if (role.isNotEmpty) role,
    if (both) 'for both of you',
  ].join(' · ');
}

TtcMoreRow _offerRow(PvOfferingView v) {
  final soon = v.kind == PvLearnKind.consult && pvLearnHasNoNamedPerson(v);
  final TtcOfferKind tag = soon
      ? TtcOfferKind.comingSoon
      : (v.isFree ? TtcOfferKind.free : TtcOfferKind.paid);
  return TtcMoreRow(
    id: v.id,
    art: _markFor(v),
    title: v.title,
    line: v.kind == PvLearnKind.consult
        ? _consultLine(v)
        : '${v.kind.label} · ${v.subtitle}',
    price: tag == TtcOfferKind.paid ? v.priceLabel : null,
    tag: tag,
    // The free garbh course opens as the course, the way the former
    // "Courses" row did (TtcPrepareScreen's one-course rule); everything
    // else opens its own offering page.
    open: v.id == kTtcOfferingGarbhCourse
        ? ttcMovedToMoreById('courses')!.open
        : (c) => pvOpenOffering(c, v),
  );
}

// Kept for revert (2026-09-29): read only by the bookings section, now on
// the profile.
// String _count(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// The page, as data. Read by the screen and by the tests.
List<TtcMoreSection> ttcMoreSections({required bool partner}) {
  final all = PvLearnCatalog.instance
      .all(stage: LifeStage.tryingToConceive)
      .where((v) => !partner || ttcMoreForHim(v))
      .toList();
  List<PvOfferingView> of(Set<PvLearnKind> kinds) =>
      [for (final v in all) if (kinds.contains(v.kind)) v];

  final consults = of({PvLearnKind.consult});
  // The free course leads: it is the one thing on the page she can start
  // without paying.
  final courses = of({
    PvLearnKind.course,
    PvLearnKind.masterclass,
    PvLearnKind.classPack,
  })
    ..sort((a, b) => (a.isFree ? 0 : 1).compareTo(b.isFree ? 0 : 1));
  final groups = of({PvLearnKind.cohort});

  // Kept for revert (2026-09-29), read by the bookings section:
  // final bookings = BookingStore.instance.bookings().length;
  // final orders = PvOrderStore.instance.orders.length;
  // final addresses = PvOrderStore.instance.addresses.length;
  // Kept for revert (2026-09-30), read by the Your journey section:
  // final map = ttcMovedToMoreById('map')!;
  // final chapter = TtcStore.instance.today.chapter;
  final sponsor = EntitlementStore.instance.sponsor;

  return [
    TtcMoreSection(
      id: 'experts',
      title: kTtcMoreExpertsHeading,
      lead: partner
          ? 'Private video calls for you, or for both of you'
          : 'Private video calls with a specialist',
      hue: 176,
      link: kTtcMoreSeeAllConsults,
      onLink: ttcMovedToMoreById('expert')!.open,
      rows: [for (final v in consults) _offerRow(v)],
    ),
    TtcMoreSection(
      id: 'courses',
      title: kTtcMoreCoursesHeading,
      lead: 'Learn at your own pace, or live with an expert',
      hue: 206,
      rows: [for (final v in courses) _offerRow(v)],
    ),
    TtcMoreSection(
      id: 'groups',
      title: kTtcMoreGroupsHeading,
      lead: 'A few weeks of live calls in a small group',
      hue: 96,
      rows: [for (final v in groups) _offerRow(v)],
    ),
    // ⚠️ "YOUR BOOKINGS AND ORDERS" LEFT MORE (2026-09-29, the lead with the
    // user): More holds what she COULD book or buy; what she HAS booked or
    // bought is on her profile (Your orders, Your bookings, under the hero)
    // and the delivery addresses are in Settings, Account. Kept for revert:
    // TtcMoreSection(
    //   id: 'bookings',
    //   title: kTtcMoreBookingsHeading,
    //   hue: 36,
    //   rows: [
    //     TtcMoreRow(
    //       id: 'bookings',
    //       art: ttcArtTab(TtcTabMark.clock),
    //       title: 'Bookings',
    //       line: bookings == 0
    //           ? 'No bookings yet. Consults, classes and courses you book are listed under Bookings'
    //           : '${_count(bookings, 'booking', 'bookings')}: consults, classes and courses',
    //       open: (c) => _push(c, const PvMyLearningScreen(), 'bookings'),
    //     ),
    //     TtcMoreRow(
    //       id: 'orders',
    //       art: ttcArtMore(TtcMoreMark.parcel),
    //       title: 'Orders',
    //       line: orders == 0
    //           ? 'No orders yet. What you buy in Products is listed under Orders'
    //           : '${_count(orders, 'order', 'orders')} from Products',
    //       open: (c) => _push(c, const PvOrdersScreen(), 'store/orders'),
    //     ),
    //     TtcMoreRow(
    //       id: 'addresses',
    //       art: ttcArtMore(TtcMoreMark.house),
    //       title: 'Delivery addresses',
    //       line: addresses == 0
    //           ? 'Where orders are delivered'
    //           : '${_count(addresses, 'address', 'addresses')} saved for delivery',
    //       open: (c) => showPvAddressesSheet(c),
    //     ),
    //   ],
    // ),
    // ⚠️ "READ AND WATCH" (2026-09-29): everything the stage has to read or
    // watch, each in one A-to-Z page. After the three things she can book
    // and before her own journey: the free library sits between what is
    // offered and what is hers. It does not replace Learn (the library to
    // browse); it is the index behind it. Mobbin: CRED's explore groups
    // what is offered under one heading per kind
    // (https://mobbin.com/screens/221e85e8-4b31-4c47-b2d5-93122764f1e6);
    // the pages' own evidence is at the head of each screen file. The
    // counts follow her "Hide sex and intimacy content" choice.
    TtcMoreSection(
      id: 'read_watch',
      title: kTtcMoreReadWatchHeading,
      lead: 'Every article and every film, in one list each',
      hue: 130,
      rows: [
        TtcMoreRow(
          id: 'all_reads',
          art: ttcArtTab(TtcTabMark.openBook),
          title: kTtcAllReadsTitle,
          line: '${ttcArticlesLabel(ttcAllReadsCount())}, by topic',
          open: (c) => _push(c, const TtcAllReadsScreen(), kTtcAllReadsRoute),
        ),
        TtcMoreRow(
          id: 'all_videos',
          art: ttcArtMore(TtcMoreMark.film),
          title: kTtcAllVideosTitle,
          line: ttcAllVideosLine(),
          open: (c) =>
              _push(c, const TtcAllVideosScreen(), kTtcAllVideosRoute),
        ),
      ],
    ),
    // ⚠️ "YOUR JOURNEY" LEFT MORE (2026-09-30, the user: "I don't understand
    // the relevance of any of them… so text heavy"). Researched first: neither
    // Flo nor What to Expect has a journey map or a chapter for trying to
    // conceive; the map's family timeline and "log your period" repeat the
    // calendar and the logger, and what a chapter says is on the doors and
    // the home. Both screens stay in code (his partner screen still links
    // them, decided in the his-side pass). Kept for revert:
    // TtcMoreSection(
    //   id: 'journey',
    //   title: kTtcMoreJourneyHeading,
    //   hue: 350,
    //   rows: [
    //     TtcMoreRow(
    //       id: 'map',
    //       // The Tools hub's own mark for the map (ttc_tool_marks.dart).
    //       art: ttcArtTool('map'),
    //       title: map.nameEn,
    //       line: map.descEn,
    //       open: map.open,
    //     ),
    //     TtcMoreRow(
    //       id: 'chapter',
    //       art: ttcArtTab(TtcTabMark.flagPath),
    //       // Named, never "Your chapter" alone (2026-09-28: a chapter name
    //       // never stands alone).
    //       title: 'Your chapter: ${chapter.title(false)}',
    //       line: partner
    //           ? 'The chapter you are in together, and what comes next'
    //           : 'What your chapter means for you both, and what comes next',
    //       open: (c) => openTtcChapter(c, chapter),
    //     ),
    //   ],
    // ),
    TtcMoreSection(
      id: 'benefits',
      title: kTtcMoreBenefitsHeading,
      hue: 20,
      rows: [
        TtcMoreRow(
          id: 'employer',
          art: ttcArtTab(TtcTabMark.wallet),
          title: sponsor == null
              ? 'Employer benefits'
              : 'Your benefits from ${sponsor.name}',
          line: sponsor == null
              ? 'Does your employer offer ParentVeda?'
              : 'What your employer covers for you',
          open: (c) => _push(
            c,
            EmployerBenefitsScreen(
              lang: PregnancyController.current?.language ??
                  AppLanguage.english,
            ),
            'employer',
          ),
        ),
        TtcMoreRow(
          id: 'invite',
          art: ttcArtTab(TtcTabMark.bigSmallHearts),
          title: 'Invite a friend',
          line: 'Share ParentVeda with someone who is trying too',
          open: (c) => _push(
            c,
            InviteFriendsScreen(controller: PregnancyController.current),
            'invite',
          ),
        ),
      ],
    ),
  ];
}

// ---- the screen ------------------------------------------------------------------

class TtcMoreTab extends StatefulWidget {
  const TtcMoreTab({super.key, this.bottomNav});

  /// The stage's bar when More is pushed on its own (no tab host). Inside the
  /// host it stands down (`TtcTabScope`), the same as every other tab.
  final Widget? bottomNav;

  @override
  State<TtcMoreTab> createState() => _TtcMoreTabState();
}

class _TtcMoreTabState extends State<TtcMoreTab> {
  @override
  void initState() {
    super.initState();
    PvOrderStore.instance.init();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([
        TtcPartnerMode.instance,
        BookingStore.instance,
        PvOrderStore.instance,
        EntitlementStore.instance,
        TtcStore.instance,
        // The article count follows the shared-phone switch (2026-09-29).
        TtcContentPrefs.instance,
      ]),
      builder: (context, _) {
        final partner = TtcPartnerMode.instance.on;
        final sections = ttcMoreSections(partner: partner);
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            CustomScrollView(
              key: const ValueKey('ttc_more_scroll'),
              slivers: [
                SliverToBoxAdapter(child: _header(context, p, partner)),
                for (final s in sections)
                  SliverToBoxAdapter(child: _TtcMoreSectionView(s, p: p)),
                SliverToBoxAdapter(
                  child: Padding(
                    // Kept for revert (2026-09-29): fromLTRB(20, 18, 20, 0).
                    padding: const EdgeInsets.fromLTRB(
                        kTtcTabRootGutter, 18, kTtcTabRootGutter, 0),
                    child: _AllProgrammesLink(p: p),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 32 +
                        (widget.bottomNav == null
                            ? MediaQuery.of(context).padding.bottom
                            : pvNavClearance(context)),
                  ),
                ),
              ],
            ),
            if (widget.bottomNav != null)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: SafeArea(top: false, child: widget.bottomNav!),
              ),
          ]),
        );
      },
    );
  }

  /// ⚠️ ONE TAB-ROOT HEADER (2026-09-29, build 19). The user: "More feels
  /// in the middle". Its title sat at the safe area + 14 with no row, 2dp
  /// under Tools and 2.5dp over Learn, and its intro was 13/ink 3 where
  /// Learn's and Tools' were 14/ink 2. `TtcTabRootHeader` puts all four at
  /// Learn's place (ttc_tab_root_header.dart).
  ///
  /// ⚠️ THE GUTTER IS THE STAGE'S 18 NOW (2026-09-29). It was 20, More's
  /// sections' edge, so the title lined up with the headings under it but
  /// sat 2dp to the right of Learn's and Tools' titles: switching tabs, the
  /// title jumped sideways. The sections moved to 18 with it, so both
  /// alignments hold. Kept for revert: gutter: 20 (and 20 on the sections
  /// and the programmes link).
  Widget _header(BuildContext context, V2Palette p, bool partner) =>
      TtcTabRootHeader(
        title: kTtcMoreTitle,
        intro: Text(
          partner
              ? 'Experts, courses and groups for you and your partner. What you have booked or ordered is on your profile.'
              : 'Experts, courses and groups you can book. What you have booked or ordered is on your profile, behind your picture on Today.',
          // Kept for revert (2026-09-29), before bookings left More:
          //   ? 'Experts, courses and groups for you and your partner, and what you have booked.'
          //   : 'Experts, courses and groups, and what you have booked. Your profile and settings are behind your picture on Today.',
          style: ttcTabRootIntroStyle(),
        ),
      );
  // Kept for revert (2026-09-29), More's own header:
  // Widget _header(BuildContext context, V2Palette p, bool partner) => Padding(
  //       padding: EdgeInsets.fromLTRB(
  //           20, MediaQuery.of(context).padding.top + 14, 20, 0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             kTtcMoreTitle,
  //             style: pvFraunces(
  //               fontSize: 30,
  //               fontWeight: FontWeight.w500,
  //               height: 1.1,
  //               color: p.ink1,
  //             ),
  //           ),
  //           const SizedBox(height: 6),
  //           Text(
  //             partner
  //                 ? 'Experts, courses and groups for you and your partner, and what you have booked.'
  //                 : 'Experts, courses and groups, and what you have booked. Your profile and settings are behind your picture on Today.',
  //             style: pvManrope(fontSize: 13, height: 1.4, color: p.ink3),
  //           ),
  //         ],
  //       ),
  //     );
}

/// The heading with its rows under it.
class _TtcMoreSectionView extends StatelessWidget {
  const _TtcMoreSectionView(this.s, {required this.p});
  final TtcMoreSection s;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(s.hue, p);
    return Padding(
      key: ValueKey('ttc_more_section_${s.id}'),
      // Kept for revert (2026-09-29): fromLTRB(20, 26, 20, 0). The stage's
      // gutter, so the headings line up with the title (see `_header`).
      padding: const EdgeInsets.fromLTRB(
          kTtcTabRootGutter, 26, kTtcTabRootGutter, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A WRAP, so at large text the link drops under the heading
          // instead of squeezing it to one letter a line (360dp at 1.5x).
          // ⚠️ THE LINK ON THE LEAD'S ROW (2026-09-30, the user: "See all
          // consults" beside the heading "is not looking right"; put it "in a
          // row below on the right, in the same row as Private video calls
          // with a specialist"). The heading stands alone; under it the lead
          // on the left and the link on the right, a size smaller. Kept for
          // revert: a Wrap of the heading and the link, then the lead.
          Semantics(
            header: true,
            child: Text(
              s.title,
              style: ttcSectionHeadingStyle(color: p.ink1),
            ),
          ),
          if (s.lead != null || (s.link != null && s.onLink != null)) ...[
            const SizedBox(height: 3),
            LayoutBuilder(builder: (context, box) => Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: s.lead == null
                      ? const SizedBox.shrink()
                      : Text(
                          s.lead!,
                          style: pvManrope(
                            fontSize: 12.5,
                            height: 1.4,
                            color: p.ink3,
                          ),
                        ),
                ),
                if (s.link != null && s.onLink != null)
                  // At most 60% of the row, so a very large text size
                  // shortens the link rather than push past the edge.
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: box.maxWidth * 0.6),
                    child: InkWell(
                      key: ValueKey('ttc_more_link_${s.id}'),
                      onTap: () => s.onLink!(context),
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Flexible(
                            child: Text(
                              s.link!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: pvManrope(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: p.ink1,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: p.ink2),
                        ]),
                      ),
                    ),
                  ),
              ],
            )),
          ],
          // Kept for revert (2026-09-30), the heading row:
          //          Wrap(
          //            alignment: WrapAlignment.spaceBetween,
          //            crossAxisAlignment: WrapCrossAlignment.end,
          //            runSpacing: 4,
          //            children: [
          //              Semantics(
          //                header: true,
          //                // Kept for revert (2026-09-29, one heading style): style:
          //                // pvFraunces(fontSize: 21, fontWeight: FontWeight.w500,
          //                //     height: 1.15, color: p.ink1)
          //                child: Text(
          //                  s.title,
          //                  style: ttcSectionHeadingStyle(color: p.ink1),
          //                ),
          //              ),
          //              if (s.link != null && s.onLink != null)
          //                InkWell(
          //                  key: ValueKey('ttc_more_link_${s.id}'),
          //                  onTap: () => s.onLink!(context),
          //                  borderRadius: BorderRadius.circular(999),
          //                  child: Padding(
          //                    padding: const EdgeInsets.fromLTRB(8, 6, 0, 2),
          //                    child: Row(mainAxisSize: MainAxisSize.min, children: [
          //                      Flexible(
          //                        child: Text(
          //                          s.link!,
          //                          style: pvManrope(
          //                            fontSize: 13,
          //                            fontWeight: FontWeight.w700,
          //                            color: p.ink1,
          //                          ),
          //                        ),
          //                      ),
          //                      Icon(Icons.chevron_right_rounded,
          //                          size: 18, color: p.ink2),
          //                    ]),
          //                  ),
          //                ),
          //            ],
          //          ),
          //          if (s.lead != null) ...[
          //            const SizedBox(height: 3),
          //            Text(
          //              s.lead!,
          //              style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
          //            ),
          //          ],
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kPvLine),
            ),
            clipBehavior: Clip.antiAlias,
            child: s.rows.isEmpty
                // A feature is never hidden: an empty section says what will
                // be here, and the catalogue link below still leads on.
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'None on Trying to conceive yet. New sessions are added as experts join.',
                      style: pvManrope(
                          fontSize: 13, height: 1.4, color: p.ink3),
                    ),
                  )
                : Column(children: [
                    for (var i = 0; i < s.rows.length; i++) ...[
                      if (i > 0)
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: kPvLine,
                          indent: 72,
                          endIndent: 16,
                        ),
                      _TtcMoreRowView(s.rows[i], tint: tint, p: p),
                    ],
                  ]),
          ),
        ],
      ),
    );
  }
}

class _TtcMoreRowView extends StatelessWidget {
  const _TtcMoreRowView(this.r, {required this.tint, required this.p});
  final TtcMoreRow r;
  final Color tint;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    // At large text the price and tag go under the line, so the name keeps
    // its width (the store's rule for a row at 1.5x).
    final big = MediaQuery.textScalerOf(context).scale(10) / 10 > 1.3;
    final hasPrice = r.price != null || r.tag != null;
    final priceBlock = Column(
      crossAxisAlignment:
          big ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (r.price != null)
          Text(
            r.price!,
            style: pvManrope(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
        if (r.price != null && r.tag != null) const SizedBox(height: 4),
        if (r.tag != null) TtcOfferTag(r.tag!),
      ],
    );
    final label = [
      r.title,
      r.line,
      ?r.price,
      if (r.tag != null) TtcOfferTag.label(r.tag!),
    ].join('. ');
    return Semantics(
      key: ValueKey('ttc_more_row_${r.id}'),
      button: true,
      container: true,
      label: label,
      excludeSemantics: true,
      onTap: () => r.open(context),
      child: InkWell(
        onTap: () => r.open(context),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: r.art(tint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      r.line,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 12.5, height: 1.35, color: p.ink3),
                    ),
                    if (big && hasPrice) ...[
                      const SizedBox(height: 6),
                      priceBlock,
                    ],
                  ],
                ),
              ),
              if (!big && hasPrice) ...[
                const SizedBox(width: 10),
                priceBlock,
              ],
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ],
          ),
        ),
      ),
    );
  }
}

/// The whole catalogue, as one outlined pill under the offerings (CRED's
/// "view all" closing its explore grid).
class _AllProgrammesLink extends StatelessWidget {
  const _AllProgrammesLink({required this.p});
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Semantics(
        key: const ValueKey('ttc_more_all_programmes'),
        button: true,
        label: '$kTtcMoreAllProgrammes. Every consult, course and group in one list',
        excludeSemantics: true,
        onTap: () => _open(context),
        child: InkWell(
          onTap: () => _open(context),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.line, width: 1.2),
            ),
            child: Row(children: [
              Expanded(
                child: Text(
                  kTtcMoreAllProgrammes,
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.ink1,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_rounded, size: 18, color: p.ink2),
            ]),
          ),
        ),
      );

  void _open(BuildContext context) =>
      _push(context, const TtcPrepareScreen(), 'ttc/prepare');
}
