// =============================================================================
//  Prepare - shared styling & building blocks ("Warm Nest")
// -----------------------------------------------------------------------------
//  The "Prepare" tab (mother side) is ParentVeda's guided/paid-experience hub -
//  Masterclasses · 1:1 Consultations · Cohort Programs · Prenatal Yoga ·
//  Birthing Classes. It replaces the old Journey tab (the weekly stack is now
//  reached from the Home hero). This file holds the palette + reusable pieces
//  so every Prepare screen renders the same Warm-Nest system faithfully.
//
//  Design source: Claude Design "pregnancy app commerce.dc.html". Content is a
//  faithful static replica of that mock (Priya · 30 weeks). Purchase CTAs are
//  placeholders for now - no payment gateway is wired yet.
// =============================================================================

import 'package:flutter/material.dart';
import '../v2/v2_palette.dart';
import '../../widgets/pv_feedback.dart';

import '../../booking/booking_catalog.dart';
import '../../services/prepare_store.dart';
import '../../experts/expert_link.dart';
import '../post_pregnancy/booking_sheet.dart';
import '../../theme/pv_fonts.dart';
import '../../localization/app_language.dart';

// ---- palette (mirrors the design's hexes; AppTheme holds the same base) -----
// ⚠️ INKED — 2026-09-18, the door walk (DESIGN-SYSTEM §4.0). The kit was
// violet on lavender: violet icons, violet outline buttons, a lavender
// panel behind every banner, lavender hairlines, a lavender canvas. The
// user on the consult list: "purple… like a sore thumb." Every constant
// keeps its NAME so the fourteen Prepare screens compile unchanged; the
// VALUES are the base palette — white ground, ink, neutral greys. `kPurple`
// is ink now; the accent survives only as the coral that marks urgency.
// Old values kept beside each for revert.
const Color kCanvas = Color(0xFFFFFFFF); // was 0xFFFBF9FE
const Color kInk = Color(0xFF2F2C30);
const Color kSoft = Color(0xFF69636C);
const Color kPurple = Color(0xFF2F2C30); // was 0xFF6A30B6 — ink now
const Color kCoral = Color(0xFFFF5A79);
const Color kPanel = Color(0xFFF5F4F6); // was 0xFFF3EEF7
const Color kMuted = Color(0xFF8E8A92); // was 0xFFA99CBB
const Color kBorder = Color(0xFFE4E2E5); // was 0xFFE7DFEE
const Color kHair = Color(0xFFEEEDEF); // was 0xFFEFEAF2
const Color kCoralTint = Color(0xFFFFF0F3);
const Color kLockBg = Color(0xFFF5F4F6); // was 0xFFF0EBF5
const Color kStripeA = Color(0xFFF1F0F2); // was 0xFFEFE7F5
const Color kStripeB = Color(0xFFF8F7F9); // was 0xFFF6F0FA

// ---- text styles ------------------------------------------------------------
TextStyle pvHeroStyle() => pvFraunces(
    fontSize: 33, fontWeight: FontWeight.w400, height: 1.12, letterSpacing: -0.5, color: kInk);
TextStyle pvSubStyle() => pvManrope(fontSize: 15, height: 1.6, color: kSoft);
TextStyle pvTitleStyle([double size = 16]) =>
    pvJakarta(fontSize: size, fontWeight: FontWeight.w700, color: kInk);
TextStyle pvBody([Color c = kSoft, double size = 13]) =>
    pvManrope(fontSize: size, height: 1.5, color: c);

// ---- soft purple card shadow ------------------------------------------------
const List<BoxShadow> pvCardShadow = [
  BoxShadow(color: Color(0x266A30B6), blurRadius: 26, spreadRadius: -12, offset: Offset(0, 14)),
];

// ---- the EN · हिं language indicator ----------------------------------------
//
//  This used to be hardcoded with EN highlighted and a comment saying "visual
//  only for now", which meant a mother reading the app in Hindi was shown a
//  control telling her she was in English. It now reflects the language
//  actually in force.
//
//  It is an INDICATOR, not a control, and that is a deliberate choice.
//  Switching needs `PregnancyController.setLanguage`, and this repo has no
//  singleton controller - `main.dart` owns the only instance and passes it
//  down. The Prepare screens are pushed routes that take `lang` by
//  constructor, so even with a controller threaded in, a tap here would flip
//  the app language while the screen showing the pill kept rendering the old
//  one until it was popped. A truthful badge beats a control that appears to
//  work on the hub and silently lies on the other thirteen screens. The real
//  switch is one tap away in Profile → Language, and stays the single owner
//  of that decision.
//
//  To make it a real toggle later: thread the controller (not just `lang`)
//  from MainScaffold down through every Prepare route, wrap each screen's
//  build in `AnimatedBuilder(animation: controller)` so a change repaints the
//  screen you tapped on, then read `controller.language` instead of `lang`.
Widget pvLangToggle(AppLanguage lang) {
  final en = lang.isEnglish;
  return Text.rich(
    TextSpan(children: [
      TextSpan(
          text: 'EN',
          style: TextStyle(
              color: en ? kPurple : kMuted, fontWeight: FontWeight.w600)),
      const TextSpan(text: ' · ', style: TextStyle(color: Color(0xFFC7BBD6))),
      TextSpan(
          text: 'हिं',
          style: TextStyle(
              color: en ? kMuted : kPurple, fontWeight: FontWeight.w600)),
    ]),
    style: pvManrope(fontSize: 12),
  );
}

// ---- top bar: hub shows a title, sub-screens show a back row ----------------
//
//  `lang` is required rather than defaulted so that adding a Prepare screen
//  cannot quietly reintroduce a language-unaware top bar - the analyzer asks
//  for it at every call site.
Widget pvTopBar(BuildContext context,
    {required AppLanguage lang, String? title, String? backLabel}) {
  final left = backLabel != null
      ? GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back, size: 20, color: kSoft),
            const SizedBox(width: 12),
            Text(backLabel, style: pvManrope(fontSize: 14, color: kSoft)),
          ]),
        )
      : Text(title ?? '', style: pvTitleStyle(15));
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [left, pvLangToggle(lang)],
  );
}

// ---- small parts ------------------------------------------------------------
Widget pvEyebrow(String text, {Color color = kCoral}) => Text(
      text.toUpperCase(),
      style: pvManrope(
          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: color),
    );

Widget pvFooterNote(String text) => Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(text,
          textAlign: TextAlign.center,
          style: pvManrope(fontSize: 12, height: 1.55, color: kMuted)),
    );

Widget pvPill(String text, {Color bg = kPanel, Color fg = kPurple}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );

// Rounded lavender info/context banner.
// No box (2026-09-18): the banner is a line set between two hairlines.
// Kept for revert: BoxDecoration(color: kPanel, radius 16).
Widget pvBanner({IconData? icon, required List<InlineSpan> spans}) => Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: const BoxDecoration(
          border: Border(
              top: BorderSide(color: kHair), bottom: BorderSide(color: kHair))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: kPurple),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Text.rich(TextSpan(children: spans),
              style: pvManrope(fontSize: 13, height: 1.5, color: kInk)),
        ),
      ]),
    );

InlineSpan pvBold(String text) =>
    TextSpan(text: text, style: const TextStyle(fontWeight: FontWeight.w700));
InlineSpan pvPurple(String text) => TextSpan(
    text: text, style: const TextStyle(fontWeight: FontWeight.w700, color: kPurple));
InlineSpan pvText(String text) => TextSpan(text: text);

// Filled purple button.
Widget pvPrimaryButton(String label, VoidCallback onTap,
        {EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 11)}) =>
    Material(
      color: kPurple,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: padding,
          child: Text(label,
              style: pvManrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );

// Outlined purple button (small).
Widget pvOutlineButton(String label, VoidCallback onTap) => Material(
      color: Colors.transparent,
      // The base pill (DESIGN-SYSTEM §4.0): stadium, ink hairline, ink label.
      // Was radius 14 in violet.
      shape: const StadiumBorder(side: BorderSide(color: kBorder, width: 1.2)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13, fontWeight: FontWeight.w700, color: kPurple)),
        ),
      ),
    );

// Rounded search field used by the Courses & Cohorts home.
Widget pvSearchField({
  required TextEditingController controller,
  required String hint,
  required ValueChanged<String> onChanged,
}) =>
    Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(children: [
        const Icon(Icons.search_rounded, size: 19, color: kMuted),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: pvManrope(fontSize: 14, color: kInk),
            cursorColor: kPurple,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: pvManrope(fontSize: 14, color: kMuted),
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ]),
    );

// Diagonal-striped placeholder (stands in for imagery/video, as in the mock).
class PvStriped extends StatelessWidget {
  const PvStriped({
    super.key,
    required this.height,
    this.colorA = kStripeA,
    this.colorB = kStripeB,
    this.radius = 0,
    this.child,
  });
  final double height;
  final Color colorA;
  final Color colorB;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _StripePainter(colorA, colorB),
        child: SizedBox(height: height, width: double.infinity, child: child),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.a, this.b);
  final Color a;
  final Color b;
  static const double band = 11;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = b);
    final p = Paint()
      ..color = a
      ..strokeWidth = band
      ..style = PaintingStyle.stroke;
    for (double d = -size.height; d < size.width + size.height; d += band * 2) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _StripePainter old) => old.a != a || old.b != b;
}

// A gentle placeholder action for CTAs that don't have a real backend yet.
//
// `what` is nullable rather than defaulted to 'Booking': a default parameter
// must be a compile-time constant, so it could never have been a translated
// string. Resolving it inside the body is how a bilingual default is spelled.
void pvComingSoon(BuildContext context, AppLanguage lang, [String? what]) {
  final s = S(lang);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(s.opensSoon(what ?? s.prepBooking)),
        behavior: SnackBarBehavior.floating),
  );
}

// Circular striped avatar used for coaches/experts in the mock.
Widget pvAvatar(double size) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: kBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: const PvStriped(height: 100, colorA: kBorder, colorB: kStripeB),
    );

// =============================================================================
//  PvExpertRow — a named coach, in Prepare, that actually opens
// -----------------------------------------------------------------------------
//  ⚠️ THE BUG THIS ENDS. Every paid surface in Prepare named the person leading
//  it — "Meet your coach" on a masterclass, "Your coach" on a cohort, "Your
//  instructor" on a course — and not one of those names did anything when
//  tapped. Meanwhile Yoga, two taps away in the same tab, opened a teacher's
//  page. Reported as: "if I click on any cohort and courses like a master class
//  and I see the coach, I'm not able to click on that coach profile… but in
//  Yoga I can."
//
//  An affordance that works in one place and not the next is worse than one
//  that never works. A name that is never tappable teaches "names are not
//  links" once; a name that is tappable in some places teaches nothing, and
//  every dead one reads as the app being broken. Parenting learned this the
//  same way — see `pp_expert_link.dart`, written after twenty-two of
//  twenty-eight names turned out to be dead.
//
//  ⚠️ A WIDGET, NOT FOUR HAND-WRITTEN GestureDetectors. Four screens showed
//  this row and each had its own markup, which is why they had drifted apart
//  (two showed a bio, one showed a fixed sentence, one showed nothing). One
//  widget means the tap, the chevron and the "does this person exist" question
//  are decided once, and the fifth screen written next month gets it free.
//
//  ⚠️ IT RESOLVES THE PERSON BEFORE IT OFFERS THE TAP. `expertByName` returns
//  null for a name with no roster entry, and this renders a plain, un-tappable
//  row in that case rather than `expertById`'s fallback — which hands back a
//  DIFFERENT REAL DOCTOR for an unknown id. Opening a stranger's profile under
//  the coach's name is a worse bug than the dead tap it would be fixing.
class PvExpertRow extends StatelessWidget {
  const PvExpertRow({
    super.key,
    required this.name,
    required this.role,
    this.bio = '',
    this.avatar = 56,
  });

  /// The displayed name, and the key the roster is searched with.
  final String name;

  /// The one-line role beneath it ("Doula & birth coach").
  final String role;

  /// An optional sentence about her on THIS offering. Kept where it says
  /// something the profile does not — why she is on this particular class —
  /// and dropped where it merely repeated her profile blurb.
  final String bio;

  final double avatar;

  @override
  Widget build(BuildContext context) {
    final expert = expertByName(name);
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        pvAvatar(avatar),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: pvTitleStyle(15)),
            const SizedBox(height: 1),
            Text(role, style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w600)),
            if (bio.trim().isNotEmpty) ...[
              const SizedBox(height: 7),
              Text(bio, style: pvBody(kSoft, 13).copyWith(height: 1.55)),
            ],
            if (expert != null) ...[
              const SizedBox(height: 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                // English literal, not an `S` entry. New copy is English only
                // as of 2026-08-27 (CLAUDE.md, "New work is English"), and
                // adding a `_p(en, hi)` pair here would have meant writing
                // Hindi nobody asked for.
                Text('View full profile',
                    style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 16, color: kPurple),
              ]),
            ],
          ]),
        ),
      ],
    );
    if (expert == null) return row;
    return GestureDetector(
      onTap: () => openExpertProfile(context, expert),
      behavior: HitTestBehavior.opaque,
      child: row,
    );
  }
}

/// A coach's name inside a card's meta line, with the NAME tappable and
/// nothing else.
///
/// ⚠️ THE CARD KEEPS ITS JOB. `PvExpertRow` above makes a whole block tappable
/// because that block is only about her; a catalogue card is not — it opens the
/// masterclass. Nesting a second full-width tap zone over it would steal the
/// card's own tap, so only the name's glyphs respond. That is what
/// `PpExpertName`'s `TapGestureRecognizer` buys and why it is not an `InkWell`.
///
/// [prefix] and [suffix] carry the surrounding grammar ("with ", " · 90 min"),
/// so a localised sentence keeps its word order with one live word inside it.
///
/// Renders plain text when the name matches nobody. A dead tap is the bug being
/// fixed here; a plain name is just a name.
Widget pvExpertName(String name,
    {String prefix = '', String suffix = '', TextStyle? style}) {
  final expert = expertByName(name);
  if (expert == null) {
    return Text('$prefix$name$suffix',
        style: style, maxLines: 1, overflow: TextOverflow.ellipsis);
  }
  return PpExpertName(expert, style: style, prefix: prefix, suffix: suffix);
}

// ---- bottom "sticky bar" fade backing --------------------------------------
const BoxDecoration pvBottomFade = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FBF9FE), kCanvas],
    stops: [0, 0.22],
  ),
);

// =============================================================================
//  Mock booking flow (no payment yet) - a confirm sheet → success, persisted
//  via PrepareStore so the item shows as booked afterwards.
// =============================================================================
Future<void> showPrepareBooking(
  BuildContext context, {
  required AppLanguage lang,
  required String id,
  required String title,
  required String priceLabel,
  String? whenLabel,
  // Nullable, not defaulted: a default parameter has to be a compile-time
  // constant, which rules out a translated string. Resolved below against the
  // caller's language.
  String? heading,
  String? cta,
  // Optional: run after the sheet is dismissed on success. Used by the Nutrition
  // funnel so booking the expert consult flows on to the personalized diet plan.
  VoidCallback? onConfirmed,
}) {
  final s = S(lang);
  // If this item is bridged to the booking engine, run the real buy -> pick a
  // slot -> booked flow (one history across both stages). Every Prepare booking
  // funnels through here, so this one interception wires the whole tab. Anything
  // not yet bridged (a recorded course, a light item) keeps the mock below.
  final offering = BookingCatalog.instance.offeringForCatalog(id);
  if (offering != null) {
    return showBookingSheet(context, offering);
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _BookingSheet(
      lang: lang,
      id: id,
      title: title,
      priceLabel: priceLabel,
      whenLabel: whenLabel,
      heading: heading ?? s.prepReserveYourSpot,
      cta: cta ?? s.prepConfirm,
      onConfirmed: onConfirmed,
    ),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.lang,
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.heading,
    required this.cta,
    this.whenLabel,
    this.onConfirmed,
  });
  final AppLanguage lang;
  final String id;
  final String title;
  final String priceLabel;
  final String? whenLabel;
  final String heading;
  final String cta;
  final VoidCallback? onConfirmed;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  bool _done = false;

  // ⚠️ THE BASE UI — 2026-09-19, the doctor-page walk. This sheet is the
  // tail of every Prepare booking (a 1:1, a masterclass, a course, a
  // cohort), and it was the old kit: a lavender panel with the summary
  // inside it, a violet button, a violet tick. The confirm sheets that
  // ship today (Mobbin: Urban Company, Angi, Opendoor, Transit) are a
  // heading, the booking as LINES — what · when · price — and one pill;
  // success is a ring tick, "You're all set", the same lines, Done. The
  // old body is `buildClassic` below, kept for revert.
  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _done ? _successInk(p) : _confirmInk(p),
          ),
        ),
      ),
    );
  }

  Widget _line(V2Palette p, IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(icon, size: 18, color: p.ink2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: pvManrope(fontSize: 14.5, height: 1.45, color: p.ink1)),
          ),
        ]),
      );

  Widget _confirmInk(V2Palette p) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('CONFIRM',
          style: pvManrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.3, color: p.ink3)),
      const SizedBox(height: 4),
      Text(widget.heading,
          style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
      const SizedBox(height: 14),
      _line(p, Icons.person_outline_rounded, widget.title),
      if (widget.whenLabel != null) _line(p, Icons.event_outlined, widget.whenLabel!),
      _line(p, Icons.payments_outlined, widget.priceLabel),
      const SizedBox(height: 10),
      Text(S(widget.lang).uiWeLlHoldSpot,
          style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () {
          pvCommitFeedback();
          PrepareStore.instance.book(widget.id);
          setState(() => _done = true);
        },
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        child: Text(widget.cta),
      ),
    ]);
  }

  Widget _successInk(V2Palette p) {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: p.ink1, width: 1.6)),
        child: Icon(Icons.check_rounded, size: 28, color: p.ink1),
      ),
      const SizedBox(height: 14),
      Text(S(widget.lang).uiReAllSet,
          style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
      const SizedBox(height: 14),
      _line(p, Icons.person_outline_rounded, widget.title),
      if (widget.whenLabel != null) _line(p, Icons.event_outlined, widget.whenLabel!),
      _line(p, Icons.payments_outlined, widget.priceLabel),
      const SizedBox(height: 10),
      Text(S(widget.lang).prepSavedToList(widget.title),
          style: pvManrope(fontSize: 12.5, height: 1.5, color: p.ink3)),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () {
          Navigator.of(context).maybePop();
          widget.onConfirmed?.call();
        },
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        child: Text(S(widget.lang).uiDone),
      ),
    ]);
  }

  /// The old-kit body, 2026-08 → 2026-09-19. Kept for revert.
  // ignore: unused_element
  Widget buildClassic(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: kCanvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: _done ? _success() : _confirm(),
        ),
      ),
    );
  }

  Widget _handle() => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.only(bottom: 18),
          decoration: BoxDecoration(color: kBorder, borderRadius: BorderRadius.circular(999)),
        ),
      );

  Widget _confirm() {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _handle(),
      Text(widget.heading, style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w500, color: kInk)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: pvTitleStyle(16)),
          if (widget.whenLabel != null) ...[
            const SizedBox(height: 6),
            Text(widget.whenLabel!, style: pvBody(kSoft, 13)),
          ],
          const SizedBox(height: 10),
          Text(widget.priceLabel, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w700)),
        ]),
      ),
      const SizedBox(height: 14),
      Text(S(widget.lang).uiWeLlHoldSpot,
          style: pvBody(kMuted, 12).copyWith(height: 1.5)),
      const SizedBox(height: 18),
      SizedBox(
        height: 52,
        width: double.infinity,
        child: Material(
          color: kPurple,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              PrepareStore.instance.book(widget.id);
              setState(() => _done = true);
            },
            child: Center(
              child: Text(widget.cta,
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      ),
    ]);
  }

  Widget _success() {
    return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      _handle(),
      Center(
        child: Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
          child: const Text('✓', style: TextStyle(color: kPurple, fontSize: 28, fontWeight: FontWeight.w700)),
        ),
      ),
      const SizedBox(height: 16),
      Center(
        child: Text(S(widget.lang).uiReAllSet,
            style: pvFraunces(fontSize: 24, fontWeight: FontWeight.w500, color: kInk)),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(S(widget.lang).prepSavedToList(widget.title),
            textAlign: TextAlign.center, style: pvBody(kSoft, 14).copyWith(height: 1.55)),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 52,
        width: double.infinity,
        child: Material(
          color: kPurple,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).maybePop();
              widget.onConfirmed?.call();
            },
            child: Center(
              child: Text(S(widget.lang).uiDone,
                  style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ),
      ),
    ]);
  }
}

// ---- sticky bottom CTA that reflects booked state ---------------------------
class PvStickyCta extends StatelessWidget {
  const PvStickyCta({
    super.key,
    required this.lang,
    required this.id,
    required this.price,
    required this.note,
    required this.noteColor,
    required this.label,
    required this.bookedLabel,
    required this.onBook,
  });

  final AppLanguage lang;
  final String id;
  final String price;
  final String note;
  final Color noteColor;
  final String label;
  final String bookedLabel;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: PrepareStore.instance,
      builder: (context, _) {
        final booked = PrepareStore.instance.isBooked(id);
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          decoration: pvBottomFade,
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Text(price, style: pvBody(kInk, 16).copyWith(fontWeight: FontWeight.w700)),
              Text(note, style: pvBody(noteColor, 11).copyWith(fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 52,
                child: booked
                    ? Material(
                        color: kPanel,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _confirmCancel(context),
                          child: Center(
                            child: Text('✓  $bookedLabel',
                                style: pvManrope(
                                    fontSize: 15, fontWeight: FontWeight.w700, color: kPurple)),
                          ),
                        ),
                      )
                    : Material(
                        color: kPurple,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: onBook,
                          child: Center(
                            child: Text(label,
                                style: pvManrope(
                                    fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                          ),
                        ),
                      ),
              ),
            ),
          ]),
        );
      },
    );
  }

  void _confirmCancel(BuildContext context) {
    // S(lang), not S.now: the dialog is built from the widget's own language,
    // so it can never disagree with the screen that opened it.
    final s = S(lang);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCanvas,
        title: Text(s.uiCancel, style: pvTitleStyle(18)),
        content: Text(s.uiWillRemoveFromPrepare, style: pvBody(kSoft, 14)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(s.uiKeep)),
          TextButton(
            onPressed: () {
              PrepareStore.instance.cancel(id);
              Navigator.of(context).pop();
            },
            child: Text(s.uiCancel2, style: TextStyle(color: kCoral)),
          ),
        ],
      ),
    );
  }
}
