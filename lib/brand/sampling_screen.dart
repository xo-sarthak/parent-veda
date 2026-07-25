// =============================================================================
//  Product Sampling (Brand Product 12) — the claim flow
// -----------------------------------------------------------------------------
//  A campaign existed for this and nothing rendered it: the one product in the
//  system where a parent hands something over (an address) had no flow at all.
//
//  ParentVeda runs the list, not the brand. That is the whole design:
//    * ELIGIBILITY is decided here, by the same audience rules as every other
//      placement - a parent who does not fit never sees the offer.
//    * REGISTRATION is an explicit, reversible opt-in. Nothing is pre-ticked.
//    * The BRAND RECEIVES A COUNT, never a name and never an address. The
//      screen says so plainly, because a sampling flow that is vague about
//      where the address goes is exactly the kind of thing that costs trust.
//    * FEEDBACK closes the loop, and it is ParentVeda's question, not the
//      brand's marketing survey.
//
//  Claim state lives in BrandStudioStore (markCompleted), so it survives a
//  restart and syncs like every other brand state.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_analytics.dart';
import 'brand_mark.dart';
import 'brand_models.dart';
import 'brand_store.dart';

const _bg = Color(0xFFFBF9FE);
const _ink = Color(0xFF2F2C30);
const _soft = Color(0xFF69636C);
const _line = Color(0xFFE7E3EE);

class SamplingScreen extends StatefulWidget {
  const SamplingScreen({super.key, required this.campaign});
  final BrandCampaign campaign;

  @override
  State<SamplingScreen> createState() => _SamplingScreenState();
}

class _SamplingScreenState extends State<SamplingScreen> {
  final _address = TextEditingController();
  bool _consent = false;
  int? _rating; // post-claim feedback, 1..5

  BrandCampaign get c => widget.campaign;
  bool get _claimed => BrandStudioStore.instance.completed(c.id);

  @override
  void dispose() {
    _address.dispose();
    super.dispose();
  }

  void _register() {
    if (!_consent || _address.text.trim().length < 10) return;
    BrandStudioStore.instance.markCompleted(c.id);
    // `completed` is the campaign-lifecycle event, i.e. the parent reached the
    // end of what this placement asks of them. For sampling that is the claim.
    BrandAnalytics.instance.event(c, BrandEvent.completed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final brand = c.brand;
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text('Free sample',
            style: GoogleFonts.fraunces(
                fontSize: 20, fontWeight: FontWeight.w600, color: _ink)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Row(children: [
            BrandMark(brand: brand, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.creative.headline,
                        style: GoogleFonts.fraunces(
                            fontSize: 23,
                            height: 1.1,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2D144C))),
                    const SizedBox(height: 3),
                    Text(c.creative.subline,
                        style: GoogleFonts.manrope(
                            fontSize: 13, height: 1.4, color: _soft)),
                  ]),
            ),
          ]),
          const SizedBox(height: 16),
          Text(c.disclosure,
              style: GoogleFonts.manrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                  color: const Color(0xFF8B8394))),
          const SizedBox(height: 16),
          Text(c.creative.story,
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.6, color: _ink)),
          const SizedBox(height: 20),
          _privacyPanel(brand),
          const SizedBox(height: 20),
          if (_claimed) ..._confirmed(brand) else ..._form(brand),
        ],
      ),
    );
  }

  // ---- the promise, stated before anything is asked for ---------------------

  Widget _privacyPanel(Brand brand) => Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF3E7A5E)),
            const SizedBox(width: 8),
            Text('Where your details go',
                style: GoogleFonts.manrope(
                    fontSize: 13, fontWeight: FontWeight.w800, color: _ink)),
          ]),
          const SizedBox(height: 10),
          _promise('ParentVeda posts it. Your address is used to send this one '
              'parcel and nothing else.'),
          _promise('${brand.name} receives a COUNT of how many were claimed. '
              'Not your name, not your address, not your baby\'s age.'),
          _promise('No card, no subscription, and registering does not sign you '
              'up to anything.'),
        ]),
      );

  Widget _promise(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_rounded, size: 13, color: Color(0xFF3E7A5E)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(s,
                style: GoogleFonts.manrope(
                    fontSize: 12.5, height: 1.5, color: _soft)),
          ),
        ]),
      );

  // ---- registration ---------------------------------------------------------

  List<Widget> _form(Brand brand) => [
        Text('Where should we post it?',
            style: GoogleFonts.manrope(
                fontSize: 13.5, fontWeight: FontWeight.w800, color: _ink)),
        const SizedBox(height: 9),
        TextField(
          controller: _address,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
          style: GoogleFonts.manrope(fontSize: 13.5, color: _ink),
          decoration: InputDecoration(
            hintText: 'Flat / house, street, area, city, PIN',
            hintStyle: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFFB3ACC0)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _line),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: brand.colour.withValues(alpha: 0.6)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Never pre-ticked. An opt-in that starts ticked is not an opt-in.
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _consent = !_consent),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(
              _consent ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              size: 21,
              color: _consent ? brand.colour : const Color(0xFFB3ACC0),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ParentVeda may use this address to post this sample.',
                style: GoogleFonts.manrope(
                    fontSize: 12.5, height: 1.45, color: _soft),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 18),
        _cta(brand),
      ];

  Widget _cta(Brand brand) {
    final ready = _consent && _address.text.trim().length >= 10;
    return GestureDetector(
      onTap: ready ? _register : null,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ready ? brand.colour : const Color(0xFFDDD8E4),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(c.creative.cta,
            style: GoogleFonts.manrope(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: ready ? Colors.white : const Color(0xFF8B8394))),
      ),
    );
  }

  // ---- confirmed + feedback -------------------------------------------------

  List<Widget> _confirmed(Brand brand) => [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF7F2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBE4D7)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.check_circle_rounded, size: 19, color: Color(0xFF3E7A5E)),
              const SizedBox(width: 9),
              Text('You are on the list',
                  style: GoogleFonts.manrope(
                      fontSize: 14.5, fontWeight: FontWeight.w800, color: _ink)),
            ]),
            const SizedBox(height: 9),
            Text(
              'We will post it within about two weeks. If stock runs out before '
              'your turn, we will tell you — you will not be left wondering.',
              style: GoogleFonts.manrope(fontSize: 12.5, height: 1.55, color: _soft),
            ),
          ]),
        ),
        const SizedBox(height: 22),
        Text('When it arrives',
            style: GoogleFonts.fraunces(
                fontSize: 19, fontWeight: FontWeight.w600, color: const Color(0xFF2D144C))),
        const SizedBox(height: 6),
        Text(
          'Our question, not ${brand.name}\'s. What you say here shapes whether '
          'we run a sampling campaign with them again — it is not passed on as '
          'a testimonial.',
          style: GoogleFonts.manrope(fontSize: 12.5, height: 1.55, color: _soft),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 1; i <= 5; i++)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _rating = i),
                  behavior: HitTestBehavior.opaque,
                  child: Icon(
                    (_rating ?? 0) >= i
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 30,
                    color: (_rating ?? 0) >= i
                        ? const Color(0xFFE0A93B)
                        : const Color(0xFFC9C2D4),
                  ),
                ),
              ),
          ],
        ),
        if (_rating != null) ...[
          const SizedBox(height: 12),
          Text('Thank you — noted.',
              style: GoogleFonts.manrope(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF3E7A5E))),
        ],
      ];
}
