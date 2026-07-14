// =============================================================================
//  Product Guide — shared styling (self-contained; matches both apps' palette)
// -----------------------------------------------------------------------------
//  The Product Guide module lives outside either app's theme so both the
//  pregnancy and parenting apps can import it identically. These tokens mirror
//  the shared ParentVeda palette (purple accent, coral, calm off-white) and the
//  three type families (Fraunces serif · Plus Jakarta Sans titles · Manrope body).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const pgBg = Color(0xFFFBF9FE);
const pgInk = Color(0xFF2F2C30);
const pgTitleInk = Color(0xFF2D144C);
const pgSoft = Color(0xFF69636C);
const pgMuted = Color(0xFFA99CBB);
const pgPurple = Color(0xFF6A30B6);
const pgCoral = Color(0xFFFF5A79);
const pgPanel = Color(0xFFF3EEF7);
const pgHair = Color(0xFFEFEAF2);
const pgLine = Color(0xFFE4E2E5);
const pgGreen = Color(0xFF2E7D57);
const pgAmber = Color(0xFFB26A00);

TextStyle pgSerif(double s, {FontWeight w = FontWeight.w400, Color c = pgInk, double h = 1.15}) =>
    GoogleFonts.fraunces(fontSize: s, fontWeight: w, height: h, letterSpacing: -0.4, color: c);
TextStyle pgTitle(double s, {Color c = pgTitleInk, FontWeight w = FontWeight.w700}) =>
    GoogleFonts.plusJakartaSans(fontSize: s, fontWeight: w, color: c);
TextStyle pgBody(double s, {Color color = pgSoft, double h = 1.6, FontWeight w = FontWeight.w400}) =>
    GoogleFonts.manrope(fontSize: s, height: h, color: color, fontWeight: w);
TextStyle pgEyebrow(Color c) =>
    GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: c);

/// Recommendation tone (0 positive · 1 neutral · 2 cautious) → colour.
Color pgRecoColor(int tone) => tone == 0 ? pgGreen : (tone == 1 ? pgAmber : pgCoral);
