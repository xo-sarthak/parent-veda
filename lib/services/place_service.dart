// =============================================================================
//  PlaceService — "where was this", as a human label
// -----------------------------------------------------------------------------
//  ⚠️ THE ONLY FILE IN THE APP THAT TOUCHES LOCATION. Everything else asks for a
//  `String?` and gets one, or gets null. That boundary is deliberate and it is
//  worth more than the usual "wrap the plugin" tidiness, because location is
//  the one capability in this app with consequences OUTSIDE the code: a runtime
//  permission prompt, a privacy-policy line, a Play Data Safety declaration and
//  an iOS usage string. Keeping the surface to one file means the answer to
//  "where do we use location" is a file path rather than a search.
//
//  ---------------------------------------------------------------------------
//  ⚠️ SHE CAN ALWAYS TYPE INSTEAD, AND THAT IS NOT THE FALLBACK — IT IS THE
//  PRIMARY PATH
//  ---------------------------------------------------------------------------
//  A journal is not a check-in. What a mother wants under an entry is
//  "Maa's house", "Apollo, 3rd floor", "the terrace" — words she chose. GPS,
//  reverse-geocoded, gives "Sector 62, Noida", which is accurate and says
//  almost nothing she would want to read in ten years.
//
//  So the typed field is the feature and this service is a convenience on top:
//  a button that fills the box, after which she can edit what it wrote. The
//  design consequence matters — **nothing here is ever written to an entry
//  without passing through a text field she can see and change.** There is no
//  path where the app silently stamps a location on something she is keeping.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHAT MUST BE ACTIONED OUTSIDE THIS REPO BEFORE SHIPPING
//  ---------------------------------------------------------------------------
//    1. **Play Data Safety**: declare approximate/precise location, collected,
//       not shared, optional. It is stored in her journal entry, which syncs to
//       her own row — so "collected" is true and "shared" is false.
//    2. **Privacy policy**: one line saying location is used only to label a
//       journal entry she is writing, only when she asks for it, and is never
//       used for tracking or advertising.
//    3. **iOS**: `NSLocationWhenInUseUsageDescription` in Info.plist. Without
//       it the app is rejected at review, and the string is user-facing.
//    4. **Android**: `ACCESS_COARSE_LOCATION` in the manifest.
//
//  (3) and (4) are in this repo and done. (1) and (2) are not code.
//
//  ⚠️ COARSE, NOT FINE. A journal entry needs a neighbourhood, not a doorstep.
//  Asking for precise location would be asking for more than the feature uses,
//  which is the thing every privacy review looks for first — and on Android 12+
//  a user can downgrade a fine request to coarse anyway, so requesting fine
//  buys a worse prompt and the same data.
// =============================================================================

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Why a place lookup did not produce a label. Distinguished because they need
/// different words on screen — "turn it on" and "we could not tell" are not the
/// same message, and telling a woman to enable a setting that is already
/// enabled is its own small insult.
enum PlaceFailure {
  /// She said no, this time or permanently.
  denied,

  /// Location is switched off at the device level.
  serviceOff,

  /// Permission and service are fine; we simply could not resolve a name.
  unavailable,
}

class PlaceResult {
  const PlaceResult.found(this.label) : failure = null;
  const PlaceResult.failed(this.failure) : label = null;

  final String? label;
  final PlaceFailure? failure;

  bool get ok => label != null && label!.trim().isNotEmpty;
}

class PlaceService {
  const PlaceService._();

  /// Ask the device where we are and turn it into something readable.
  ///
  /// ⚠️ NEVER THROWS. Every caller is a UI callback, and a location plugin has
  /// more failure modes than most — no service, permission denied, permission
  /// denied forever, a timeout, a geocoder that returns an empty list, a device
  /// with no geocoder at all. A throw from any of those would reach her as a
  /// crash on a screen where she was writing something she wanted to keep.
  static Future<PlaceResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const PlaceResult.failed(PlaceFailure.serviceOff);
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return const PlaceResult.failed(PlaceFailure.denied);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          // ⚠️ A HARD CEILING, BECAUSE THE ALTERNATIVE IS A SPINNER THAT NEVER
          // STOPS. Indoors — which is where most of these entries are written —
          // a fix can take a long time or never arrive. Ten seconds then "type
          // it yourself" is a better experience than a button that stays busy.
          timeLimit: Duration(seconds: 10),
        ),
      );

      // ⚠️ `Geocoding()` INSTANCE, NOT A TOP-LEVEL FUNCTION. geocoding 5.x
      // moved `placemarkFromCoordinates` onto a class; the old top-level form
      // is what every tutorial still shows, so this is the line that will look
      // wrong to the next person and is not.
      final marks =
          await Geocoding().placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (marks.isEmpty) {
        return const PlaceResult.failed(PlaceFailure.unavailable);
      }
      final label = _label(marks.first);
      return label == null
          ? const PlaceResult.failed(PlaceFailure.unavailable)
          : PlaceResult.found(label);
    } catch (_) {
      return const PlaceResult.failed(PlaceFailure.unavailable);
    }
  }

  /// A `Placemark` into a short, human line.
  ///
  /// ⚠️ NEIGHBOURHOOD AND CITY, NOT A POSTAL ADDRESS. A geocoder will happily
  /// return a street number, and putting one under a photograph in a keepsake
  /// she may share is both more than the feature needs and more than she
  /// intended to publish. Two parts at most, and never the street.
  static String? _label(Placemark m) {
    final parts = <String>[
      if ((m.subLocality ?? '').trim().isNotEmpty) m.subLocality!.trim(),
      if ((m.locality ?? '').trim().isNotEmpty) m.locality!.trim(),
    ];
    if (parts.isEmpty) {
      // Some Indian addresses come back with the district or state populated
      // and locality empty. Better a state than nothing.
      final fallback = [
        if ((m.subAdministrativeArea ?? '').trim().isNotEmpty)
          m.subAdministrativeArea!.trim(),
        if ((m.administrativeArea ?? '').trim().isNotEmpty)
          m.administrativeArea!.trim(),
      ];
      if (fallback.isEmpty) return null;
      return fallback.take(2).join(', ');
    }
    // De-duplicate: "Noida, Noida" happens when subLocality and locality agree.
    final seen = <String>{};
    final out = parts.where(seen.add).take(2).toList();
    return out.join(', ');
  }

  /// ⚠️ TEST SEAM. The plugin has no implementation under `flutter test`, so
  /// the label-building rule — the only part with real judgement in it — is
  /// exposed for direct testing rather than being unreachable behind a call
  /// that needs a device.
  static String? debugLabel(Placemark m) => _label(m);
}
