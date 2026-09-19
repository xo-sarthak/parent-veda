// =============================================================================
//  ProviderProfileScreen - reusable expert / provider profile (parenting · S18·detail)
// -----------------------------------------------------------------------------
//  A single expert or provider: why ParentVeda picks them, languages &
//  specialties, verified-mother reviews, a disclosure, and a sticky book bar.
//  Data-driven - pass any `Expert` (from pp_experts_data) and it renders that
//  person; with no expert it defaults to Dr. Neha Sharma (the Problem Solver
//  provider), so the S18·detail flow is unchanged. Reused everywhere an expert
//  is named: masterclasses, cohorts, courses, and local services. Faithful build
//  of Claude Design · S18·detail.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import '../../data/prepare_data.dart';
import '../../localization/app_language.dart';
import '../prepare/program_detail_screen.dart';
import '../prepare/prepare_common.dart' show showPrepareBooking;
import 'booking_sheet.dart';
import 'learning_detail_screen.dart';
import 'pp_channels_data.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'pp_learning_data.dart';
import 'pp_yoga_data.dart';
import 'provider_booking_sheet.dart';
import 'watch_channel_screen.dart';
import 'yoga_class_screen.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({super.key, this.expert});

  /// The person to render. Defaults to Dr. Neha Sharma when null.
  final Expert? expert;

  static const Color _green = Color(0xFF1F8A5B);

  // Known spoken languages, so the flat `tags` list can be split into
  // "Speaks" (languages) vs "Helps with" (focus areas).
  static const Set<String> _languages = {
    'Hindi', 'English', 'Hinglish', 'Gujarati', 'Bengali', 'Tamil', 'Telugu',
    'Punjabi', 'Marathi', 'Kannada', 'Malayalam', 'Urdu', 'Odia',
  };

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ⚠️ THE ONE DOCTOR PAGE — 2026-09-19. The user's brief: "a doctor's
  // LinkedIn — photo, name, field, experience, rating, where they practise,
  // why you can trust them, what they host, whether they offer 1:1s, parent
  // reviews — and a funnel to book." This screen already held all of that
  // for parenting (built 2026-08) and the pregnancy consult list opened a
  // separate detail between the list and it. Now every surface that names a
  // person lands here, in the base UI (DESIGN-SYSTEM §4.0), on the shape
  // Zocdoc, Airbnb's host page, Preply and Udemy's instructor share (Mobbin):
  // avatar · name · role · location · ★ rating · N reviews · a stat row ·
  // About · Why · what she offers · qualifications (unfolds) · reviews as
  // rows · a sticky Book pill. The old body is `buildClassic` below, kept
  // for revert; `ConsultationDetailScreen` is retired from the consult list.
  @override
  Widget build(BuildContext context) {
    final e = expert ?? expertById('neha');
    return _ProfileBody(e: e, screen: this);
  }

  /// The parenting-kit body, 2026-08 → 2026-09-19. Kept for revert.
  // ignore: unused_element
  Widget buildClassic(BuildContext context) {
    final e = expert ?? expertById('neha');
    final programs = programsByInstructor(e.id);
    // ⚠️ THE OTHER TWO THINGS SHE MIGHT TEACH, AND WHY THEY ARE JOINED
    // DIFFERENTLY. Parenting's learning programmes already carry an
    // `instructorId`, so they join on the id — the strong key. Yoga classes and
    // Pregnancy's Prepare programmes carry a NAME, because that is the key
    // those catalogues were built on and re-keying ~40 content literals to
    // gain nothing today is churn in two shipped stages.
    //
    // The weakness of a name key is that a rename in one file silently unlinks
    // it. That is not left to luck: `test/expert_link_coverage_test.dart`
    // asserts every name in both catalogues resolves to exactly one expert, so
    // a rename fails CI rather than quietly emptying this section.
    final yogaClasses = classesByInstructor(e.name);
    final prepPrograms = prepProgramsByInstructor(e.name);
    final channel = channelById(e.id);
    final hasChannel = channel.videos.isNotEmpty || channel.shorts.isNotEmpty || channel.podcasts.isNotEmpty;
    // Split the flat tag list into spoken languages vs. focus areas so each reads
    // clearly, instead of one undifferentiated row of chips.
    //
    // ⚠️ SPLIT ON `tags`, RENDER FROM `tagsNow`. The split is a LOOKUP against
    // a fixed English set, so it has to run over the identity values; the chips
    // are display, so they come from the localised list at the same index.
    // Doing both from `tagsNow` is the `.en`-vs-`.now` mistake in miniature —
    // "हिन्दी" is not in `_languages`, so in Hindi every language would have
    // silently been re-classified as a specialty. Nothing would fail.
    final labels = e.tagsNow;
    String label(int i) => i < labels.length ? labels[i] : e.tags[i];
    final langs = <String>[];
    final focus = <String>[];
    for (var i = 0; i < e.tags.length; i++) {
      (_languages.contains(e.tags[i]) ? langs : focus).add(label(i));
    }
    // Only find-help doctors (who set consult timings) can be booked; they get a
    // fixed "Book a consultation" bar at the very bottom. Educators never do.
    final bookable = e.timings.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: EdgeInsets.only(top: 12, bottom: bookable ? 120 : 40),
            children: [
              _pad(ppBack(context, 'Back')),

              // header
              const SizedBox(height: 20),
              _pad(Row(children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                  clipBehavior: Clip.antiAlias,
                  child: const PpStriped(height: 82, colorA: ppBorder, colorB: ppStripeB),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (e.topPick)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xFFEAF6EF), borderRadius: BorderRadius.circular(999)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_rounded, size: 12, color: _green),
                          const SizedBox(width: 5),
                          Flexible(
                              child: Text(e.topPickLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: ppBody(11, color: _green, w: FontWeight.w700))),
                        ]),
                      ),
                    if (e.topPick) const SizedBox(height: 8),
                    Text(e.name, style: ppFraunces(24, h: 1.1)),
                    const SizedBox(height: 2),
                    Text(e.credentialNow, style: ppBody(13)),
                    if (e.locationNow.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.place_outlined, size: 14, color: ppSoft),
                        const SizedBox(width: 5),
                        Flexible(child: Text(e.locationNow, style: ppBody(12.5, color: ppSoft), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ]),
                    ],
                  ]),
                ),
              ])),

              // stats - rating + reach (centred so two items stay symmetric)
              const SizedBox(height: 20),
              _pad(Row(children: [
                _stat('★ ${e.rating}', e.reviewsCount.isNotEmpty ? e.reviewsCount : 'rating'),
                _statDivider(),
                _stat(e.mid.$1, e.mid.$2),
              ])),

              // who she is - a short "about" description
              if (e.blurbNow.trim().isNotEmpty) ...[
                const SizedBox(height: 26),
                _pad(Text('About ${_firstName(e)}', style: ppJakarta(18))),
                const SizedBox(height: 8),
                _pad(Text(e.blurbNow, style: ppBody(15, h: 1.6))),
              ],

              // ⚠️ THE BLOCK THIS SCREEN WAS MISSING, AND THE REASON IT READ AS
              // A CREDIT RATHER THAN A PROFILE. Everything above is warmth —
              // a rating, a sentence about how she is in a room. None of it
              // answers the question somebody actually has before paying
              // ₹1,499 or handing over a question about their baby: what is
              // she qualified to say this? Degrees, years, where she practises,
              // which council she answers to.
              //
              // It sits ABOVE "why we pick her" deliberately. Our opinion of
              // her should not arrive before her credentials do.
              if (_hasCredentials(e)) ...[
                const SizedBox(height: 24),
                _pad(_credentials(e)),
              ],

              // when she's available (find-help doctors) - info only; booking is
              // the fixed bar at the bottom.
              if (e.timings.trim().isNotEmpty) ...[
                const SizedBox(height: 18),
                _pad(_availability(e)),
              ],

              // why ParentVeda picks her (guarded - light profiles omit it)
              if (e.whyNow.trim().isNotEmpty) ...[
                const SizedBox(height: 26),
                if (e.whyHeadingNow.trim().isNotEmpty) ...[
                  _pad(Text(e.whyHeadingNow, style: ppJakarta(18))),
                  const SizedBox(height: 8),
                ],
                _pad(Text(e.whyNow, style: ppBody(15, h: 1.6))),
              ],

              // languages the expert speaks
              if (langs.isNotEmpty) ...[
                const SizedBox(height: 24),
                _pad(_miniLabel(Icons.translate_rounded, 'Speaks')),
                const SizedBox(height: 9),
                _pad(Wrap(spacing: 8, runSpacing: 8, children: [for (final t in langs) _tag(t)])),
              ],

              // what the expert helps with (focus areas), made more evident
              if (focus.isNotEmpty) ...[
                const SizedBox(height: 18),
                _pad(_miniLabel(Icons.check_circle_outline, 'Helps with')),
                const SizedBox(height: 9),
                _pad(Wrap(spacing: 8, runSpacing: 8, children: [for (final t in focus) _specialtyChip(t)])),
              ],

              // what this expert is hosting - masterclasses, courses & cohorts
              if (programs.isNotEmpty) ...[
                const SizedBox(height: 28),
                _pad(Text('What ${_firstName(e)} is hosting', style: ppJakarta(18))),
                const SizedBox(height: 4),
                _pad(Text('Masterclasses, courses and cohorts led by ${_firstName(e)} - tap any to see dates & details.',
                    style: ppBody(12, color: ppMuted, h: 1.4))),
                const SizedBox(height: 12),
                for (var i = 0; i < programs.length; i++) _pad(_programRow(context, programs[i], top: i == 0)),
              ],

              // ⚠️ THE SAME PERSON, THE OTHER STAGE. Sana Kapoor coaches a
              // Pregnancy cohort AND teaches four postnatal classes; Aditi
              // Verma teaches three. Before this, opening her from Yoga showed
              // only classes and opening her from Prepare showed only
              // programmes, so the app quietly implied two different women.
              //
              // A profile that changes depending on which door you came
              // through is not a profile. Everything she does is listed here,
              // whatever stage it belongs to.
              if (prepPrograms.isNotEmpty) ...[
                const SizedBox(height: 28),
                _pad(Text('In Pregnancy · Prepare', style: ppJakarta(18))),
                const SizedBox(height: 4),
                _pad(Text('Masterclasses, courses and cohorts ${_firstName(e)} leads for expecting mothers.',
                    style: ppBody(12, color: ppMuted, h: 1.4))),
                const SizedBox(height: 12),
                for (var i = 0; i < prepPrograms.length; i++)
                  _pad(_prepProgramRow(context, prepPrograms[i], top: i == 0)),
              ],

              if (yogaClasses.isNotEmpty) ...[
                const SizedBox(height: 28),
                _pad(Text('Classes with ${_firstName(e)}', style: ppJakarta(18))),
                const SizedBox(height: 4),
                _pad(Text('Live and recorded sessions in Yoga & Classes.',
                    style: ppBody(12, color: ppMuted, h: 1.4))),
                const SizedBox(height: 12),
                for (var i = 0; i < yogaClasses.length; i++)
                  _pad(_yogaRow(context, yogaClasses[i], top: i == 0)),
              ],

              // watch their videos - the channel lives in the Watch section
              if (hasChannel) ...[
                const SizedBox(height: 22),
                _pad(_channelLink(context, e)),
              ],

              // reviews - at the bottom
              if (e.reviews.isNotEmpty) ...[
                const SizedBox(height: 28),
                _pad(Text('From verified mothers', style: ppJakarta(18))),
                const SizedBox(height: 4),
                _pad(Text('Same review system as Products - named, never anonymous.', style: ppBody(12))),
                const SizedBox(height: 14),
                for (var i = 0; i < e.reviews.length; i++)
                  _pad(_review(e.reviews[i].$1, e.reviews[i].$2, '★★★★★', e.reviews[i].$3,
                      top: i == 0, bottom: i == e.reviews.length - 1)),
              ],

              const SizedBox(height: 24),
              _pad(Text(e.disclaimer, textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          // fixed "Book a consultation" bar - only for bookable find-help doctors.
          // Clean: just the action, no price and no masterclass framing.
          if (bookable)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00FBF9FE), ppBg],
                    stops: [0, 0.30],
                  ),
                ),
                child: GestureDetector(
                  // In-app consult via the booking engine (calendar case). Falls
                  // back to the old sheet only for an expert not yet bridged.
                  onTap: () {
                    final o = BookingCatalog.instance.offeringForCatalog(e.id);
                    if (o != null) {
                      showBookingSheet(context, o);
                    } else {
                      showProviderBookingSheet(context, e);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                    child: Text('Book a consultation', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  //  Credentials
  // ---------------------------------------------------------------------------

  /// True when there is anything in the credentials block worth drawing.
  ///
  /// ⚠️ ONE GUARD, NOT FIVE INLINE ONES. Roughly forty of the experts in the
  /// registry are lean find-help rows with no degrees recorded, and the card's
  /// heading, padding and border would otherwise render around nothing at all.
  /// A feature is never hidden (CLAUDE.md) — but an EMPTY CARD is not the
  /// feature, it is chrome, and the invitation to fill it belongs in the panel,
  /// not on a mother's screen.
  static bool _hasCredentials(Expert e) =>
      e.qualifications.isNotEmpty ||
      e.experience.trim().isNotEmpty ||
      e.practisesAt.trim().isNotEmpty ||
      e.registration.trim().isNotEmpty ||
      e.memberships.isNotEmpty;

  Widget _credentials(Expert e) {
    final quals = e.qualificationsNow;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      decoration: BoxDecoration(
        color: ppPanel,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ppPanelDiv),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ `Expanded`, NOT A BARE `Text`. A heading in a `Row` takes its
        // intrinsic width and overflows rather than wrapping, and the smoke
        // test caught it at 390dp: 142 pixels off the right edge. Worth
        // knowing WHY the test is stricter than the phone — `flutter_test`
        // renders with a fallback font whose every glyph is a square of the
        // font size, so 27 characters at 15.5 measure 418dp instead of ~230.
        // That is not a false alarm to work around: the real device is one
        // long word or one large accessibility text scale away from the same
        // overflow, and the fix is the same either way.
        Row(children: [
          const Icon(Icons.workspace_premium_outlined, size: 17, color: ppPurple),
          const SizedBox(width: 8),
          Expanded(child: Text('Qualifications & experience', style: ppJakarta(15.5))),
        ]),
        if (quals.isNotEmpty) ...[
          const SizedBox(height: 14),
          for (final q in quals)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle),
                ),
                const SizedBox(width: 11),
                Expanded(child: Text(q, style: ppBody(13.5, color: ppInk, h: 1.5))),
              ]),
            ),
        ],
        const SizedBox(height: 4),
        if (e.experienceNow.trim().isNotEmpty)
          _factRow(Icons.timelapse_outlined, 'Experience', e.experienceNow),
        if (e.practisesAtNow.trim().isNotEmpty)
          _factRow(Icons.local_hospital_outlined, 'Practises at', e.practisesAtNow),
        // ⚠️ PRINTED PLAINLY, WITH NO TICK AND NO "VERIFIED" WORD ANYWHERE
        // NEAR IT. ParentVeda has not checked this number. A registration
        // rendered beside a verification mark is a claim we cannot stand
        // behind, and it is exactly the sort of claim a mother would rely on.
        if (e.registration.trim().isNotEmpty)
          _factRow(Icons.badge_outlined, 'Registration', e.registration),
        if (e.memberships.isNotEmpty)
          _factRow(Icons.groups_outlined, 'Member of', e.memberships.join(' · ')),
      ]),
    );
  }

  Widget _factRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 15, color: ppMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label.toUpperCase(),
                  style: ppBody(10, color: ppMuted, w: FontWeight.w800)
                      .copyWith(letterSpacing: 0.7)),
              const SizedBox(height: 3),
              Text(value, style: ppBody(13, color: ppInk, h: 1.45)),
            ]),
          ),
        ]),
      );

  Widget _stat(String value, String label) => Expanded(
        child: Column(children: [
          Text(value, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(label, style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ]),
      );

  // Availability card (info only) - when a find-help doctor is free. Booking
  // itself is the fixed bar at the bottom of the profile.
  Widget _availability(Expert e) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: e.availableToday ? _green : ppMuted, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text: e.availableToday ? 'Available today  ' : 'Next available tomorrow  ',
                    style: ppBody(12.5, color: ppInk, w: FontWeight.w700)),
                TextSpan(text: e.timings, style: ppBody(12.5, color: ppSoft)),
              ]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (e.videoConsult) ...[
            const SizedBox(width: 8),
            const Icon(Icons.videocam_outlined, size: 16, color: ppPurple),
          ],
        ]),
      );

  Widget _statDivider() => Container(
        width: 1,
        height: 30,
        color: ppLine,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );

  Widget _tag(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(label, style: ppBody(12, color: ppInk, w: FontWeight.w600)),
      );

  // Small labelled header (icon + uppercase caption) for the Speaks / Helps-with groups.
  Widget _miniLabel(IconData icon, String text) => Row(children: [
        Icon(icon, size: 15, color: ppPurple),
        const SizedBox(width: 7),
        Text(text.toUpperCase(), style: ppBody(11, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.8)),
      ]);

  // Focus-area chip - a filled purple chip with a check, so specialties read as
  // "what they can help with", distinct from the plain language pills.
  Widget _specialtyChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_circle_outline, size: 14, color: ppPurple),
          const SizedBox(width: 6),
          Text(label, style: ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
        ]),
      );

  Widget _review(String name, String who, String stars, String quote,
          {bool top = false, bool bottom = false}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: top ? const BorderSide(color: ppHair) : BorderSide.none,
            bottom: bottom ? const BorderSide(color: ppHair) : BorderSide.none,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Flexible(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '$name ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                  TextSpan(text: '· $who', style: ppBody(13, color: ppMuted)),
                ]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(stars, style: ppBody(12, color: ppCoral, w: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          Text(quote, style: ppBody(14, color: ppInk, h: 1.55)),
        ]),
      );

  String _firstName(Expert e) {
    final n = e.name.replaceAll('Dr. ', '').trim();
    return n.isEmpty ? e.name : n.split(' ').first;
  }

  // A program the expert is hosting (masterclass / course / cohort). Informational
  // here - tapping opens the program's own page, where dates + reserve/buy live.
  Widget _programRow(BuildContext context, LearningProgram p, {bool top = false}) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LearningDetailScreen(program: p))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(top: top ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            PpStriped(height: 58, width: 74, radius: 14, border: true, colorA: p.accent.withValues(alpha: 0.16), colorB: p.accent.withValues(alpha: 0.05)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title, style: ppBody(15, color: ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${p.kind.label} · ${p.durationLabel}', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Text(p.price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          ]),
        ),
      );

  // A Prepare (pregnancy) programme she leads. Opens the programme's own page,
  // which owns dates, seats and the pay sheet — this row is a signpost, never a
  // second place a purchase can start.
  //
  // `S.current` rather than a threaded controller: this screen is reached from
  // both stages and from a dozen call sites, several of which have no language
  // in scope. That is exactly the case `LocalizedText.now` documents.
  Widget _prepProgramRow(BuildContext context, PrepProgram p, {bool top = false}) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'prepare/program/${p.id}'),
          builder: (_) => ProgramDetailScreen(program: p, lang: S.current),
        )),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(top: top ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            PpStriped(
                height: 58,
                width: 74,
                radius: 14,
                border: true,
                colorA: p.accent.withValues(alpha: 0.16),
                colorB: p.accent.withValues(alpha: 0.05)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.title.now, style: ppBody(15, color: ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${p.kind.label.now} · ${p.durationLabel.now}',
                    style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Text(p.price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          ]),
        ),
      );

  // A yoga / movement class she teaches.
  //
  // ⚠️ PUSHES THE CLASS RATHER THAN POPPING BACK, unlike the old
  // `YogaInstructorScreen` row, which called `maybePop()` for every class
  // INCLUDING ones the parent had never opened — so tapping her second class
  // from her profile closed the profile and showed the first one. This screen
  // is reachable from anywhere, so there is no "back" it can assume.
  Widget _yogaRow(BuildContext context, YogaClass c, {bool top = false}) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'pp/yoga/class/${c.id}'),
          builder: (_) => YogaClassScreen(cls: c),
        )),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(top: top ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: ppBody(15, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${c.durationLabel} · ${c.level}', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Text(c.price.split('·').first.trim(), style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          ]),
        ),
      );

  // A link out to the expert's channel in Watch (their videos/shorts/podcasts).
  // Following/subscribing happens there - on the channel, not on this profile.
  Widget _channelLink(BuildContext context, Expert e) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WatchChannelScreen(expertId: e.id))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.play_circle_outline, size: 22, color: ppPurple),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Watch ${_firstName(e)} on ParentVeda', style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text('Their videos, shorts & podcasts - follow the channel there.', style: ppBody(12), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

// =============================================================================
//  The base-UI body
// =============================================================================

class _ProfileBody extends StatefulWidget {
  const _ProfileBody({required this.e, required this.screen});
  final Expert e;
  final ProviderProfileScreen screen;

  @override
  State<_ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<_ProfileBody> {
  bool _qualsOpen = false;

  Expert get e => widget.e;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final programs = programsByInstructor(e.id);
    final yogaClasses = classesByInstructor(e.name);
    final prepPrograms = prepProgramsByInstructor(e.name);
    final labels = e.tagsNow;
    String label(int i) => i < labels.length ? labels[i] : e.tags[i];
    final langs = <String>[];
    final focus = <String>[];
    for (var i = 0; i < e.tags.length; i++) {
      (ProviderProfileScreen._languages.contains(e.tags[i]) ? langs : focus).add(label(i));
    }
    // ⚠️ THE SPECIALIST TWIN. Pregnancy's 1:1 supply — price, half-hour
    // slots, two named reviews — lives on `Specialist` (prepare_data.dart),
    // matched by name; the parenting doctors carry `timings` on `Expert`
    // instead. The profile reads both, so a person is bookable and reviewed
    // whichever side wrote them. Merging the two models is owed
    // (STILL-OPEN §63.16); until then this seam is the one place they meet.
    final sp = kSpecialists.where((x) => x.name.en == e.name).firstOrNull;
    final bookable = e.timings.trim().isNotEmpty || sp != null;
    final reviews = e.reviews.isNotEmpty
        ? e.reviews
        : [for (final r in sp?.reviews ?? const <Review>[]) (r.who.now, r.when.now, r.quote.now)];
    final first = _first(e);
    final initials = e.name
        .replaceAll('Dr. ', '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0])
        .join();
    final well = Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface);
    final offers = <Widget>[];
    if (bookable) {
      offers.add(_offerRow(
        p,
        icon: Icons.videocam_outlined,
        title: '1:1 consultation  ·  30 min video',
        sub: sp != null
            ? '${sp.consultPrice}  ·  today ${sp.slots.join(', ')}'
            : '${e.fee.$1} ${e.fee.$2}${e.timings.trim().isEmpty ? '' : '  ·  ${e.timings}'}',
        onTap: () => _book(context, sp),
      ));
    }
    for (final pr in prepPrograms) {
      offers.add(_offerRow(
        p,
        icon: Icons.school_outlined,
        title: pr.title.now,
        sub: '${pr.kind.name[0].toUpperCase()}${pr.kind.name.substring(1)}  ·  ${pr.price}',
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          settings: RouteSettings(name: 'prepare/program/${pr.id}'),
          builder: (_) => ProgramDetailScreen(program: pr, lang: S.current),
        )),
      ));
    }
    for (final pr in programs) {
      offers.add(_offerRow(
        p,
        icon: Icons.school_outlined,
        title: pr.title,
        sub: '${pr.kind.label}  ·  ${pr.durationLabel}  ·  ${pr.price}',
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => LearningDetailScreen(program: pr))),
      ));
    }
    for (final c in yogaClasses) {
      offers.add(_offerRow(
        p,
        icon: Icons.self_improvement_rounded,
        title: c.title,
        sub: 'Class  ·  Yoga & fitness',
        onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => YogaClassScreen(cls: c))),
      ));
    }

    return Scaffold(
      backgroundColor: p.surface,
      body: Stack(children: [
        ListView(
          padding: EdgeInsets.only(bottom: bookable ? 120 : 40),
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 18, 0),
                child: Row(children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back_rounded, color: p.ink1),
                    tooltip: 'Back',
                  ),
                ]),
              ),
            ),
            // ---- who ---------------------------------------------------------
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: well, shape: BoxShape.circle),
                  clipBehavior: Clip.antiAlias,
                  // A photograph when the person has one; initials until then.
                  // Real doctors bring their own — a stock face on a named
                  // doctor would be a lie.
                  child: Text(initials,
                      style: pvManrope(
                          fontSize: 30, fontWeight: FontWeight.w800, color: p.ink1)),
                ),
                const SizedBox(height: 16),
                Text(e.name,
                    style: pvFraunces(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                        letterSpacing: -0.6,
                        color: p.ink1)),
                const SizedBox(height: 6),
                Text(e.credentialNow,
                    style: pvManrope(fontSize: 14.5, height: 1.4, color: p.ink2)),
                if (e.locationNow.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(Icons.place_outlined, size: 15, color: p.ink3),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(e.locationNow,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(fontSize: 13, color: p.ink3)),
                    ),
                  ]),
                ],
                if (e.topPick) ...[
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(Icons.verified_outlined, size: 16, color: p.ink1),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(e.topPickLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: pvManrope(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: p.ink1)),
                    ),
                  ]),
                ],
                const SizedBox(height: 20),
                // ---- the stat row (Airbnb's host page) --------------------
                Row(children: [
                  _stat(p, '★ ${e.rating}', e.reviewsCount.isNotEmpty ? e.reviewsCount : 'rating'),
                  _rule(p),
                  _stat(p, e.mid.$1, e.mid.$2),
                  if (e.experience.trim().isNotEmpty) ...[
                    _rule(p),
                    _stat(p, e.experience.split(' ').first, 'years'),
                  ],
                ]),
                const SizedBox(height: 8),
                Divider(height: 1, color: p.line),
              ]),
            ),

            // ---- about --------------------------------------------------------
            if (e.blurbNow.trim().isNotEmpty)
              _section(p, 'About $first', Text(e.blurbNow,
                  style: pvManrope(fontSize: 15, height: 1.6, color: p.ink1))),
            if (e.whyNow.trim().isNotEmpty)
              _section(
                  p,
                  e.whyHeadingNow.trim().isEmpty ? 'Why ParentVeda picks $first' : e.whyHeadingNow,
                  Text(e.whyNow,
                      style: pvManrope(fontSize: 15, height: 1.6, color: p.ink1))),
            if (focus.isNotEmpty || langs.isNotEmpty)
              _section(
                  p,
                  'Helps with',
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final t in focus) _chip(p, t),
                    ]),
                    if (langs.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text('Speaks ${langs.join(', ')}',
                          style: pvManrope(fontSize: 13, color: p.ink2)),
                    ],
                  ])),

            // ---- what she offers ---------------------------------------------
            if (offers.isNotEmpty)
              _section(p, 'Sessions with $first', Column(children: offers)),

            // ---- qualifications, unfolding --------------------------------
            if (_hasCreds(e))
              _section(
                p,
                null,
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  PvPress(
                    child: InkWell(
                      onTap: () {
                        pvCommitFeedback();
                        setState(() => _qualsOpen = !_qualsOpen);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(children: [
                          Expanded(
                            child: Text('Qualifications & experience',
                                style: pvFraunces(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    letterSpacing: -0.45,
                                    color: p.ink1)),
                          ),
                          AnimatedRotation(
                            turns: _qualsOpen ? 0.5 : 0,
                            duration: const Duration(milliseconds: 180),
                            child: Icon(Icons.expand_more_rounded, color: p.ink2),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: _qualsOpen
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (final q in e.qualificationsNow) _line(p, q),
                                  if (e.experience.trim().isNotEmpty) _line(p, e.experience),
                                  if (e.practisesAt.trim().isNotEmpty) _line(p, 'Practises at ${e.practisesAt}'),
                                  if (e.registration.trim().isNotEmpty) _line(p, e.registration),
                                  for (final m in e.memberships) _line(p, m),
                                ]),
                          )
                        : const SizedBox(width: double.infinity),
                  ),
                ]),
              ),

            // ---- reviews -------------------------------------------------
            if (reviews.isNotEmpty)
              _section(
                  p,
                  'From parents',
                  Column(children: [
                    for (var i = 0; i < reviews.length; i++)
                      _reviewRow(p, reviews[i].$1, reviews[i].$2, reviews[i].$3,
                          last: i == reviews.length - 1),
                  ])),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 22, 18, 0),
              child: Text(e.disclaimer,
                  style: pvManrope(fontSize: 12, height: 1.55, color: p.ink3)),
            ),
          ],
        ),

        // ---- the funnel: one pill, always in reach -----------------------
        if (bookable)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(18, 14, 18, 16 + MediaQuery.paddingOf(context).bottom),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [p.surface.withValues(alpha: 0), p.surface],
                  stops: const [0, 0.35],
                ),
              ),
              child: FilledButton(
                onPressed: () => _book(context, sp),
                style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                child: Text('Book a 1:1  ·  ${sp?.consultPrice ?? e.fee.$1}'),
              ),
            ),
          ),
      ]),
    );
  }

  void _book(BuildContext context, Specialist? sp) {
    pvCommitFeedback();
    // A pregnancy specialist books through the Prepare sheet with a slot;
    // the slot picker is the sheet's own (see _pickSlot). Parenting doctors
    // go through the booking engine as before.
    if (sp != null) {
      _pickSlot(context, sp);
      return;
    }
    final o = BookingCatalog.instance.offeringForCatalog(e.id);
    if (o != null) {
      showBookingSheet(context, o);
    } else {
      showProviderBookingSheet(context, e);
    }
  }

  /// Which slot — a sheet of ink pills, then the Prepare confirm sheet.
  Future<void> _pickSlot(BuildContext context, Specialist sp) async {
    final p = V2PaletteStore.instance.current;
    final slot = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: p.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 18, 20, 20 + MediaQuery.paddingOf(ctx).bottom),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('WHEN', style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
          const SizedBox(height: 4),
          Text('Today, with ${_first(e)}',
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
          const SizedBox(height: 6),
          Text('${sp.consultPrice}  ·  30 min video call', style: pvManrope(fontSize: 13.5, color: p.ink2)),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final t in sp.slots)
              PvPress(
                child: Material(
                  color: p.surface,
                  shape: StadiumBorder(side: BorderSide(color: p.line)),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      pvCommitFeedback();
                      Navigator.pop(ctx, t);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(t, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
                    ),
                  ),
                ),
              ),
          ]),
        ]),
      ),
    );
    if (slot == null || !context.mounted) return;
    await showPrepareBooking(
      context,
      lang: S.current,
      id: sp.id,
      title: '${sp.role.now} · ${sp.name.now}',
      priceLabel: '${sp.consultPrice} · 30-min video call',
      whenLabel: 'Today · $slot',
      heading: 'Confirm your consult',
      cta: 'Confirm booking',
    );
  }

  static bool _hasCreds(Expert e) =>
      e.qualifications.isNotEmpty ||
      e.experience.trim().isNotEmpty ||
      e.practisesAt.trim().isNotEmpty ||
      e.registration.trim().isNotEmpty ||
      e.memberships.isNotEmpty;

  static String _first(Expert e) {
    final parts = e.name.replaceAll('Dr. ', '').split(' ');
    return parts.isEmpty ? e.name : parts.first;
  }

  Widget _section(V2Palette p, String? heading, Widget body) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 26, 18, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (heading != null) ...[
            Text(heading,
                style: pvFraunces(
                    fontSize: 21,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                    letterSpacing: -0.45,
                    color: p.ink1)),
            const SizedBox(height: 10),
          ],
          body,
        ]),
      );

  Widget _stat(V2Palette p, String value, String label) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 17, fontWeight: FontWeight.w800, color: p.ink1)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(fontSize: 12, color: p.ink3)),
        ]),
      );

  Widget _rule(V2Palette p) => Container(
      width: 1, height: 30, margin: const EdgeInsets.symmetric(horizontal: 14), color: p.line);

  Widget _chip(V2Palette p, String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999), border: Border.all(color: p.line)),
        child: Text(t,
            style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w600, color: p.ink1)),
      );

  Widget _line(V2Palette p, String t) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 10),
            child: Container(
                width: 5, height: 5, decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle)),
          ),
          Expanded(child: Text(t, style: pvManrope(fontSize: 14, height: 1.5, color: p.ink1))),
        ]),
      );

  Widget _offerRow(V2Palette p,
          {required IconData icon,
          required String title,
          required String sub,
          required VoidCallback onTap}) =>
      PvPress(
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
            child: Row(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: Color.alphaBlend(p.ink1.withValues(alpha: 0.06), p.surface),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, size: 20, color: p.ink2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, height: 1.25, color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(fontSize: 12.5, color: p.ink2)),
                ]),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
            ]),
          ),
        ),
      );

  Widget _reviewRow(V2Palette p, String name, String who, String quote, {required bool last}) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: last ? null : Border(bottom: BorderSide(color: p.line))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text('$name  ·  $who',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
            // Five drawn stars in ink — the glyph string rendered faint and
            // tiny (the user: "the stars are not nearly visible").
            Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < 5; i++)
                Icon(Icons.star_rounded, size: 15, color: p.ink1),
            ]),
          ]),
          const SizedBox(height: 6),
          Text(quote, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        ]),
      );
}
