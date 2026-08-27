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
import 'booking_sheet.dart';
import 'learning_detail_screen.dart';
import 'pp_channels_data.dart';
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

  @override
  Widget build(BuildContext context) {
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
