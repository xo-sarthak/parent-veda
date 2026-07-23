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
import 'package:google_fonts/google_fonts.dart';

import '../../booking/booking_catalog.dart';
import '../../services/prepare_store.dart';
import '../post_pregnancy/booking_sheet.dart';

// ---- palette (mirrors the design's hexes; AppTheme holds the same base) -----
const Color kCanvas = Color(0xFFFBF9FE);
const Color kInk = Color(0xFF2F2C30);
const Color kSoft = Color(0xFF69636C);
const Color kPurple = Color(0xFF6A30B6);
const Color kCoral = Color(0xFFFF5A79);
const Color kPanel = Color(0xFFF3EEF7);
const Color kMuted = Color(0xFFA99CBB);
const Color kBorder = Color(0xFFE7DFEE);
const Color kHair = Color(0xFFEFEAF2);
const Color kCoralTint = Color(0xFFFFF0F3);
const Color kLockBg = Color(0xFFF0EBF5);
const Color kStripeA = Color(0xFFEFE7F5);
const Color kStripeB = Color(0xFFF6F0FA);

// ---- text styles ------------------------------------------------------------
TextStyle pvHeroStyle() => GoogleFonts.fraunces(
    fontSize: 33, fontWeight: FontWeight.w400, height: 1.12, letterSpacing: -0.5, color: kInk);
TextStyle pvSubStyle() => GoogleFonts.manrope(fontSize: 15, height: 1.6, color: kSoft);
TextStyle pvTitleStyle([double size = 16]) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: FontWeight.w700, color: kInk);
TextStyle pvBody([Color c = kSoft, double size = 13]) =>
    GoogleFonts.manrope(fontSize: size, height: 1.5, color: c);

// ---- soft purple card shadow ------------------------------------------------
const List<BoxShadow> pvCardShadow = [
  BoxShadow(color: Color(0x266A30B6), blurRadius: 26, spreadRadius: -12, offset: Offset(0, 14)),
];

// ---- the EN · हिं toggle (visual only for now) ------------------------------
Widget pvLangToggle() => Text.rich(
      TextSpan(children: const [
        TextSpan(text: 'EN', style: TextStyle(color: kPurple, fontWeight: FontWeight.w600)),
        TextSpan(text: ' · ', style: TextStyle(color: Color(0xFFC7BBD6))),
        TextSpan(text: 'हिं', style: TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
      ]),
      style: GoogleFonts.manrope(fontSize: 12),
    );

// ---- top bar: hub shows a title, sub-screens show a back row ----------------
Widget pvTopBar(BuildContext context, {String? title, String? backLabel}) {
  final left = backLabel != null
      ? GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.opaque,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.arrow_back, size: 20, color: kSoft),
            const SizedBox(width: 12),
            Text(backLabel, style: GoogleFonts.manrope(fontSize: 14, color: kSoft)),
          ]),
        )
      : Text(title ?? '', style: pvTitleStyle(15));
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [left, pvLangToggle()],
  );
}

// ---- small parts ------------------------------------------------------------
Widget pvEyebrow(String text, {Color color = kCoral}) => Text(
      text.toUpperCase(),
      style: GoogleFonts.manrope(
          fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.3, color: color),
    );

Widget pvFooterNote(String text) => Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(text,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(fontSize: 12, height: 1.55, color: kMuted)),
    );

Widget pvPill(String text, {Color bg = kPanel, Color fg = kPurple}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(text,
          style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );

// Rounded lavender info/context banner.
Widget pvBanner({IconData? icon, required List<InlineSpan> spans}) => Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: kPurple),
          const SizedBox(width: 11),
        ],
        Expanded(
          child: Text.rich(TextSpan(children: spans),
              style: GoogleFonts.manrope(fontSize: 13, height: 1.5, color: kInk)),
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
              style: GoogleFonts.manrope(
                  fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ),
    );

// Outlined purple button (small).
Widget pvOutlineButton(String label, VoidCallback onTap) => Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          side: const BorderSide(color: kPurple), borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          child: Text(label,
              style: GoogleFonts.manrope(
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
            style: GoogleFonts.manrope(fontSize: 14, color: kInk),
            cursorColor: kPurple,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: hint,
              hintStyle: GoogleFonts.manrope(fontSize: 14, color: kMuted),
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
void pvComingSoon(BuildContext context, [String what = 'Booking']) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('$what opens soon'), behavior: SnackBarBehavior.floating),
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
  required String id,
  required String title,
  required String priceLabel,
  String? whenLabel,
  String heading = 'Reserve your spot',
  String cta = 'Confirm',
  // Optional: run after the sheet is dismissed on success. Used by the Nutrition
  // funnel so booking the expert consult flows on to the personalized diet plan.
  VoidCallback? onConfirmed,
}) {
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
      id: id,
      title: title,
      priceLabel: priceLabel,
      whenLabel: whenLabel,
      heading: heading,
      cta: cta,
      onConfirmed: onConfirmed,
    ),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({
    required this.id,
    required this.title,
    required this.priceLabel,
    required this.heading,
    required this.cta,
    this.whenLabel,
    this.onConfirmed,
  });
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

  @override
  Widget build(BuildContext context) {
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
      Text(widget.heading, style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w500, color: kInk)),
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
      Text("We'll hold your spot and remind you before it starts. Payments aren't live yet - nothing is charged now.",
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
                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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
        child: Text("You're all set!",
            style: GoogleFonts.fraunces(fontSize: 24, fontWeight: FontWeight.w500, color: kInk)),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text('“${widget.title}” is saved to your Prepare list. We\'ll remind you before it starts.',
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
              child: Text('Done',
                  style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
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
    required this.id,
    required this.price,
    required this.note,
    required this.noteColor,
    required this.label,
    required this.bookedLabel,
    required this.onBook,
  });

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
                                style: GoogleFonts.manrope(
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
                                style: GoogleFonts.manrope(
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
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: kCanvas,
        title: Text('Cancel this?', style: pvTitleStyle(18)),
        content: Text('This will remove it from your Prepare list.', style: pvBody(kSoft, 14)),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Keep')),
          TextButton(
            onPressed: () {
              PrepareStore.instance.cancel(id);
              Navigator.of(context).pop();
            },
            child: const Text('Cancel it', style: TextStyle(color: kCoral)),
          ),
        ],
      ),
    );
  }
}
