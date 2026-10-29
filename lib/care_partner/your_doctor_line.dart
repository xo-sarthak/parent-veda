// =============================================================================
//  YourDoctorLine — "Your doctor · Dr Meera Rao, Bloom Fertility Centre"
// -----------------------------------------------------------------------------
//  How a doctor appears in the PARENT app once a family joins with her code
//  (Partner Editions D3: a doctor is a line, never a lockup — a lockup is a
//  sponsor's). One widget, two homes:
//
//    * ParentVeda+ Home → "How parents see you" shows it as a preview, so the
//      doctor sees exactly what her patients will (D2, built here);
//    * the parent homes render it for real (A1, built later).
//
//  Built once, in lib/care_partner/, so the preview can never drift from the
//  real thing. It is drawn in the PARENT palette (white ground, ink, one hair
//  border), not the doctor chrome, because the preview's whole point is to be
//  the parent's view. No partner colours and no logo here: D1 says a partner's
//  brand stops at the lockup, and a doctor has none.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/post_pregnancy/pp_common.dart'
    show ppBody, ppBorder, ppInk, ppJakarta, ppPanel, ppSoft;

/// "Dr Meera Rao, Bloom Fertility Centre", or just the name when there is no
/// clinic to name. A clinic that IS the doctor (a solo practice whose partner
/// row carries her own name) is not repeated: "Dr Meera Rao, Dr Meera Rao"
/// would read as a bug.
String yourDoctorLabel(String name, String? clinic) {
  final n = name.trim();
  final c = (clinic ?? '').trim();
  if (c.isEmpty || c.toLowerCase() == n.toLowerCase()) return n;
  return '$n, $c';
}

class YourDoctorLine extends StatelessWidget {
  const YourDoctorLine({
    super.key,
    required this.name,
    this.clinic,
    this.photoUrl,
    this.onTap,
  });

  final String name;
  final String? clinic;
  final String? photoUrl;

  /// The parent side opens her profile; the doctor-side preview passes null.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty
        ? '?'
        : name
              .trim()
              .replaceFirst(RegExp(r'^Dr\.?\s+'), '')
              .characters
              .first
              .toUpperCase();
    final avatar = Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: photoUrl == null
          ? Text(initial, style: ppJakarta(13, color: ppInk))
          : Image.network(
              photoUrl!,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Text(initial, style: ppJakarta(13, color: ppInk)),
            ),
    );
    return Semantics(
      label: 'Your doctor: ${yourDoctorLabel(name, clinic)}',
      button: onTap != null,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ppBorder),
          ),
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your doctor', style: ppBody(11.5, color: ppSoft)),
                    const SizedBox(height: 1),
                    // Two lines rather than an ellipsis: a name is never cut off.
                    Text(
                      yourDoctorLabel(name, clinic),
                      style: ppJakarta(13.5, color: ppInk),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: ppSoft,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
