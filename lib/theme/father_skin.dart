// =============================================================================
//  Father weekly skin — Slate palette + Fraunces headers
// -----------------------------------------------------------------------------
//  The father's weekly section is the EXACT same mother weekly UI/layout/
//  components/images — only the colour scheme (Slate) and header fonts
//  (Fraunces) differ, plus the father language (handled in week_flow_screen).
//  These tokens are applied as `fatherWeekActive(week) ? <slate> : <existing>`
//  so the mother path and every week != 20 stay byte-identical.
//
//  TESTING gate: keyed off FatherPreview (the dev Mom|Dad switch). Strip with
//  FatherPreview before launch.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/father_preview.dart';

// Slate palette (mirrors the Father Daily screen / the Pregnancy Week design).
const Color kFBg = Color(0xFFF4EFE8); // warm cream background
const Color kFCard = Color(0xFFFFFFFF);
const Color kFLine = Color(0xFFECE5DA);
const Color kFInk = Color(0xFF22333B); // header ink
const Color kFMuted = Color(0xFF6A7B82);
const Color kFAccent = Color(0xFF2E5266); // deep slate (replaces purple/coral)
const Color kFAccent2 = Color(0xFFE0915B); // amber highlight
const Color kFAccentSoft = Color(0xFFE7EDEF);
const Color kFWarmSoft = Color(0xFFFBEDDE);
const Color kFCream = Color(0xFFFBF7F0);

/// True when the father weekly re-skin should apply (week-20 father preview).
bool fatherWeekActive(int week) => FatherPreview.instance.on && week == 20;

/// Fraunces (serif) header style for the father weekly re-skin.
TextStyle fatherSerif(double size,
        {FontWeight weight = FontWeight.w600, Color color = kFInk}) =>
    GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color);
