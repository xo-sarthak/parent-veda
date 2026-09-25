// =============================================================================
//  Onboarding art — the ten paintings, and the curved band they sit in
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS A DELIBERATE DEPARTURE FROM DESIGN-SYSTEM §3, AND IT STOPS AT
//  THE FRONT DOOR. The app's rule is drawn marks and line icons, no
//  illustration, because chrome should be quiet. Onboarding is not chrome: it
//  is the one surface whose entire job is a first impression, and the
//  drawn-mark family is a 100x100 utility glyph set that cannot carry a
//  full-bleed hero. So ten commissioned paintings live here and NOWHERE past
//  the reveal — the moment she reaches a home screen, the app is back to its
//  own hand. (docs/ONBOARDING-V2.md §3.)
//
//  THE CURVED BAND is Headspace's actual signature, and reading fourteen
//  onboarding flows on Mobbin it is the single highest-leverage visual
//  device available: a colour field holding one illustration, its bottom edge
//  a curve, white content below. It is one clip path and it does almost all
//  of the warmth.
//
//  ⚠️ EVERY BAND FALLS BACK TO A TINTED FIELD. `Image.asset` throws if a file
//  is missing or malformed, and an onboarding that cannot render is an app
//  nobody sees the inside of. `errorBuilder` puts the hue's own well there
//  instead, so a missing painting costs warmth and never a white screen.
//
//  ⚠️ THE FILES ARE JPEG, AND THAT IS A SIZE DECISION. The generated PNGs are
//  ~2 MB each, 19 MB for the set. At the sizes these actually render — 1200 px
//  for a full-width band, 420 px for a coin-sized stage tile — JPEG q88 is
//  visually identical and the set is 1.3 MB. Download size is not a detail in
//  the market this app is built for. The PNG originals stay on disk for
//  re-cropping and are gitignored.
// =============================================================================

import 'package:flutter/material.dart';

import '../../v2/v2_palette.dart';

/// The ten. Named for what they SAY, not for the file they load, so a
/// re-shoot is one line in `_asset` and nothing else moves.
enum ObArt {
  /// A couple, her hand on the belly and his over hers. The welcome.
  welcome,

  /// A lit home at dusk, seen from outside. Privacy.
  privacy,

  /// Two pairs of hands around a seedling. Trying to conceive.
  stageTrying,

  /// A pregnant profile, one hand resting. Pregnancy.
  stagePregnant,

  /// A swaddled newborn held close. Parenting.
  stageParenting,

  /// A child stacking blocks. Skilling.
  stageSkilling,

  /// A woman waving, warm and unposed. "Nice to meet you."
  hello,

  /// A sleeping newborn curled in light. The week she is in.
  week,

  /// A woman alone at a window, from behind. What we will never do.
  promise,

  /// A woman reading, cards settling around her. Her plan.
  plan,

  /// Her portrait. "Which of you is this?"
  whoMother,

  /// His portrait, turned toward hers. The pair.
  whoPartner,
}

/// The file for a painting. Public because `ObGridCard` paints one into its
/// own well rather than taking a whole band.
String obArtAsset(ObArt a) => _asset(a);

String _asset(ObArt a) => switch (a) {
  ObArt.welcome => 'assets/onboarding/ob_a1.jpg',
  ObArt.privacy => 'assets/onboarding/ob_a2.jpg',
  ObArt.stageTrying => 'assets/onboarding/ob_a3.jpg',
  ObArt.stagePregnant => 'assets/onboarding/ob_a4.jpg',
  ObArt.stageParenting => 'assets/onboarding/ob_a5.jpg',
  ObArt.stageSkilling => 'assets/onboarding/ob_a6.jpg',
  ObArt.hello => 'assets/onboarding/ob_a7.jpg',
  ObArt.week => 'assets/onboarding/ob_a8.jpg',
  ObArt.promise => 'assets/onboarding/ob_a9.jpg',
  ObArt.plan => 'assets/onboarding/ob_a10.jpg',
  ObArt.whoMother => 'assets/onboarding/ob_a11.jpg',
  ObArt.whoPartner => 'assets/onboarding/ob_a12.jpg',
};

/// The hue behind each painting — the fallback field, and the tint the band
/// bleeds into at its edges so a 1:1 image can sit in a wider band without a
/// visible seam. Taken from the background each one was painted on.
double obArtHue(ObArt a) => switch (a) {
  ObArt.welcome => 344, // dusty rose
  ObArt.privacy => 104, // sage
  ObArt.stageTrying => 42, // warm sand
  ObArt.stagePregnant => 344,
  ObArt.stageParenting => 268, // soft lilac
  ObArt.stageSkilling => 18, // terracotta
  ObArt.hello => 42,
  ObArt.week => 344,
  ObArt.promise => 104,
  ObArt.plan => 268,
  ObArt.whoMother => 344,
  ObArt.whoPartner => 104,
};

/// The band: a painting with a curved bottom edge, the content below it.
///
/// ⚠️ THE IMAGE IS SQUARE AND THE BAND IS WIDE, SO IT IS CENTRE-CROPPED.
/// Every prompt asked for the essential content to sit in the middle
/// horizontal two-thirds precisely so this crop is safe. `BoxFit.cover` with
/// a slightly high alignment keeps faces rather than skirts, because in all
/// six full paintings the emotional content is above the midline.
class ObBand extends StatelessWidget {
  const ObBand({
    super.key,
    required this.art,
    required this.p,
    this.height = 300,
  });

  final ObArt art;
  final V2Palette p;
  final double height;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(obArtHue(art), p);
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipPath(
        clipper: _BandCurve(),
        child: Container(
          color: tint,
          child: Image.asset(
            _asset(art),
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.18),
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

/// Headspace's curve: the bottom edge dips, it does not arc symmetrically.
/// A single quadratic with its control point below the baseline gives the
/// shallow smile; a circular arc gives a bowl, which reads as a cut-out
/// rather than as a horizon.
class _BandCurve extends CustomClipper<Path> {
  @override
  Path getClip(Size s) => Path()
    ..lineTo(0, s.height - 34)
    ..quadraticBezierTo(s.width / 2, s.height + 22, s.width, s.height - 34)
    ..lineTo(s.width, 0)
    ..close();

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

/// A painting filling whatever box it is given, with the hue behind it. For
/// the reveal, where the art sits in a rounded card rather than a curved band.
class ObArtFill extends StatelessWidget {
  const ObArtFill({super.key, required this.art, required this.p});
  final ObArt art;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
    color: v2BlockTint(obArtHue(art), p),
    child: Image.asset(
      _asset(art),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      alignment: const Alignment(0, -0.1),
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    ),
  );
}

/// The stage tile's painting: a circle, because four of these sit in a grid
/// and a rounded square at this size reads as a button.
class ObArtDisc extends StatelessWidget {
  const ObArtDisc({
    super.key,
    required this.art,
    required this.p,
    this.size = 56,
  });
  final ObArt art;
  final V2Palette p;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: v2BlockTint(obArtHue(art), p),
    ),
    clipBehavior: Clip.antiAlias,
    child: Image.asset(
      _asset(art),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    ),
  );
}
