// =============================================================================
//  BrandMark — a partner brand's visual identity, drawn not shipped
// -----------------------------------------------------------------------------
//  The Brand Studio had a real engine and real placements, but every brand was
//  a NAME and a COLOUR with `logoAsset: null`. So a sponsored surface rendered
//  as grey text: architecturally correct, and completely invisible to anyone
//  looking at the app. Sponsorship that cannot be seen is not sponsorship.
//
//  This gives every partner a mark without shipping a single image: a monogram
//  tile in the brand's own colour, derived from its name. A real partner later
//  sets `logoAsset` and it is used instead - the call sites do not change.
//
//  The mark is the brand's colour. ParentVeda's own chrome stays ParentVeda's:
//  a partner colours its OWN mark and nothing else on the screen.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brand_models.dart';

/// The letters shown when a brand has no logo asset: the capitals in its name
/// ("NestlingCo" -> "NC", "PureStart" -> "PS"), else its first letter.
String brandMonogram(String name) {
  final caps = name.replaceAll(RegExp('[^A-Z]'), '');
  if (caps.length >= 2) return caps.substring(0, 2);
  if (caps.isNotEmpty) return caps.substring(0, 1);
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, required this.brand, this.size = 28});

  final Brand brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    final logo = brand.logoAsset;
    final radius = BorderRadius.circular(size * 0.28);
    if (logo != null && logo.isNotEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(logo,
            width: size, height: size, fit: BoxFit.cover,
            // A missing asset must never break a screen - fall back to the
            // monogram exactly as if no logo had been set.
            errorBuilder: (_, _, _) => _monogram()),
      );
    }
    return _monogram();
  }

  Widget _monogram() => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: brand.colour,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Text(
          brandMonogram(brand.name),
          style: GoogleFonts.manrope(
            fontSize: size * 0.40,
            height: 1,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: Colors.white,
          ),
        ),
      );
}

/// Mark + name, for headers and sponsor sheets.
class BrandLockup extends StatelessWidget {
  const BrandLockup({
    super.key,
    required this.brand,
    this.markSize = 28,
    this.nameSize = 14,
    this.color,
  });

  final Brand brand;
  final double markSize;
  final double nameSize;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BrandMark(brand: brand, size: markSize),
          SizedBox(width: markSize * 0.32),
          Flexible(
            child: Text(
              brand.name,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: nameSize,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.1,
                color: color ?? const Color(0xFF2F2C30),
              ),
            ),
          ),
          if (brand.certified) ...[
            SizedBox(width: markSize * 0.22),
            Icon(Icons.verified_rounded,
                size: nameSize + 2, color: brand.colour),
          ],
        ],
      );
}
