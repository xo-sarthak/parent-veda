// =============================================================================
//  Symptoms — the pieces the door's tools share
// -----------------------------------------------------------------------------
//  The round tile (Flo's "select your symptoms": a circle with the mark, the
//  name under it, a ring when chosen), the severity sheet (Visible's none /
//  mild / moderate / severe as three ink chips), the heading, the dot.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/symptoms/symptom_library.dart';
import '../../../models/symptom.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_feedback.dart';
import '../../brackets/hub/hub_intent_art.dart';
import '../../ttc/ttc_mood_face.dart';
import '../../ttc/ttc_symptom_mark.dart';
import '../../v2/v2_palette.dart';

/// The three strengths, in the store's words.
const List<(String, String, String)> kSeverities = [
  ('mild', 'Mild', 'There, but I can get on with things'),
  ('moderate', 'Moderate', "It's getting in the way"),
  ('strong', 'Strong', "It's taking over my day"),
];

String severityLabel(String id) => kSeverities.where((s) => s.$1 == id).firstOrNull?.$2 ?? 'Logged';

int severityDots(String? id) => switch (id) { 'mild' => 1, 'moderate' => 2, 'strong' => 3, _ => 0 };

Widget symptomsHeading(V2Palette p, String text, {String? sub, Widget? trailing}) => Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(text,
                style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, letterSpacing: -0.4, color: p.ink1)),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(sub, style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
            ],
          ]),
        ),
        ?trailing,
      ],
    );

/// The area's tint on a white ground.
Color symptomAreaTint(V2Palette p, SymptomArea a) => v2BlockTint(a.hue, p);

// =============================================================================
//  The marks — drawn in TTC's hand
// -----------------------------------------------------------------------------
//  ⚠️ THE CHECK-IN DRAWS LINE GLYPHS AND FACES, NOT THE FILLED `IntentMark`s.
//  The user, walking the door (2026-09-22): *"in trying to conceive we have
//  those face designs that have been drawn — can we do something for this as
//  well?"* The same woman makes the same gesture a stage earlier on the TTC
//  logger, where every symptom is a line glyph in one hand and every feeling a
//  features-only face (`ttc_mood_face.dart` says why: emoji belong to the OS,
//  filled marks read as stickers). Two hands for one gesture read as two apps.
//
//  So: `symptomGlyphFor` maps the door's ids onto `TtcGlyph` — twelve reuse a
//  shape TTC already had, twenty-three were drawn for this door — and
//  `symptomMoodFor` gives mood swings the swings face. `symptomLineMark` is
//  the one place they are painted; `test/symptoms_door_test.dart` fails if
//  any symptom would fall through to the filled mark, because a mixed set
//  reads as unfinished (TTC's rule, `ttc_symptom_marks_test.dart`).
//
//  `symptomMark` (the filled set) stays: the door's cards and the area
//  headings still wear it, and it is the revert.
// =============================================================================

/// The face for a symptom that is a feeling — only mood swings here. A face
/// is a claim about an expression, so nothing else gets one.
TtcMood? symptomMoodFor(String id) => switch (id) { 'moodSwings' => TtcMood.swings, _ => null };

/// The line glyph for a symptom id, or null (the test says: never).
TtcGlyph? symptomGlyphFor(String id) => switch (id) {
      // ---- reused from TTC's set ------------------------------------------------
      'nausea' => TtcGlyph.queasy,
      'headache' => TtcGlyph.headAche,
      'fatigue' => TtcGlyph.battery,
      'bloating' => TtcGlyph.expand,
      'backPain' => TtcGlyph.spine,
      'roundLigament' => TtcGlyph.bellyAche,
      'troubleSleeping' => TtcGlyph.moonEye,
      'hairSkin' => TtcGlyph.spots,
      'pelvicGirdle' => TtcGlyph.pelvis,
      'legCramps' => TtcGlyph.bolt,
      // ---- drawn for this door -------------------------------------------------
      'heartburn' => TtcGlyph.flame,
      'constipation' => TtcGlyph.knot,
      'metallicTaste' => TtcGlyph.spoon,
      'foodAversions' => TtcGlyph.bowlSlash,
      'dizziness' => TtcGlyph.spiral,
      'breathlessness' => TtcGlyph.breath,
      'blockedNose' => TtcGlyph.breathSlash,
      'nosebleeds' => TtcGlyph.drip,
      'carpalTunnel' => TtcGlyph.tingle,
      'varicoseVeins' => TtcGlyph.veins,
      'ribPain' => TtcGlyph.sideAche,
      'restlessLegs' => TtcGlyph.jitter,
      'vividDreams' => TtcGlyph.cloudStar,
      'itching' => TtcGlyph.scratch,
      'bleedingGums' => TtcGlyph.tooth,
      'hotFlushes' => TtcGlyph.heat,
      'smellSensitivity' => TtcGlyph.scent,
      'frequentUrination' => TtcGlyph.dropRepeat,
      'swelling' => TtcGlyph.puff,
      'babyHiccups' => TtcGlyph.bounce,
      'pelvicPressure' => TtcGlyph.basinDown,
      'braxtonHicks' => TtcGlyph.tighten,
      // ---- the thirteen of 2026-09-29, from marks TTC already draws ------------
      // Five are the right object: TTC draws spotting, discharge, tender
      // breasts and a raised heart for the same things. The rest are the
      // closest unused mark, held until their own are drawn (the report lists
      // them): cramps wear ripples (an ache spreading from one point),
      // leaking breasts and extra saliva a plain and a stretched drop, sharp
      // jabs the storm's bolt, clumsiness the stride, sciatica the seated
      // stretch, blurry vision two blurred rings, red palms the warm
      // thermometer, loose motions the dotted drop.
      'spotting' => TtcGlyph.dropSpot,
      'discharge' => TtcGlyph.dropCreamy,
      'breasts' => TtcGlyph.tender,
      'libido' => TtcGlyph.heartUp,
      'cramps' => TtcGlyph.ripples,
      'leakyBreasts' => TtcGlyph.dropWatery,
      'excessSaliva' => TtcGlyph.dropStretch,
      'lightningCrotch' => TtcGlyph.storm,
      'clumsiness' => TtcGlyph.stride,
      'sciatica' => TtcGlyph.lotus,
      'blurryVision' => TtcGlyph.rings,
      'redPalms' => TtcGlyph.thermometer,
      'diarrhoea' => TtcGlyph.dropSticky,
      _ => null,
    };

/// The area's deep ink — the tint pulled down until a line reads on it.
Color symptomAreaInk(V2Palette p, SymptomArea a) =>
    HSLColor.fromColor(symptomAreaTint(p, a)).withSaturation(0.45).withLightness(0.42).toColor();

/// A symptom's mark in the door's hand: a face, a line glyph, or — only while
/// a symptom is being added — the filled mark, which the test never lets ship.
Widget symptomLineMark(Symptom s, {required double size, required Color ink}) {
  final mood = symptomMoodFor(s.id);
  if (mood != null) return TtcMoodFace(mood: mood, size: size, ink: ink);
  final g = symptomGlyphFor(s.id);
  if (g == null) {
    return SizedBox(width: size, height: size, child: HubIntentArt(mark: symptomMark(s), tint: ink));
  }
  return TtcGlyphMark(glyph: g, size: size, ink: ink);
}

/// The symptom's own filled mark, where one is drawn; its area's otherwise
/// (2026-09-22, the user: "for headache, bloating, mood swings …"). The
/// check-in no longer draws these — see the note above; kept for the cards
/// and for revert.
IntentMark symptomMark(Symptom s) => switch (s.id) {
      'nausea' => IntentMark.tummyMark,
      'heartburn' => IntentMark.flameMark,
      'constipation' => IntentMark.coilMark,
      'bloating' => IntentMark.balloonMark,
      'metallicTaste' => IntentMark.spoonMark,
      'foodAversions' => IntentMark.noPlateMark,
      'fatigue' => IntentMark.batteryMark,
      'backPain' => IntentMark.spineMark,
      'headache' => IntentMark.headMark,
      'troubleSleeping' => IntentMark.sleepMark,
      'moodSwings' => IntentMark.moodArc,
      'swelling' => IntentMark.swellMark,
      'legCramps' => IntentMark.boltMark,
      'pelvicGirdle' => IntentMark.bodyMark,
      'babyHiccups' => IntentMark.kickMark,
      'braxtonHicks' => IntentMark.tummyMark,
      'dizziness' => IntentMark.spiralMark,
      'breathlessness' => IntentMark.windMark,
      'nosebleeds' => IntentMark.dropMark,
      'blockedNose' => IntentMark.noseMark,
      'smellSensitivity' => IntentMark.noseMark,
      'frequentUrination' => IntentMark.dropMark,
      'hotFlushes' => IntentMark.thermoMark,
      'bleedingGums' => IntentMark.toothMark,
      'restlessLegs' => IntentMark.boltMark,
      'vividDreams' => IntentMark.moonMark,
      'itching' => IntentMark.skinMark,
      'hairSkin' => IntentMark.skinMark,
      'carpalTunnel' => IntentMark.boltMark,
      'varicoseVeins' => IntentMark.swellMark,
      'ribPain' => IntentMark.spineMark,
      'roundLigament' => IntentMark.tummyMark,
      'pelvicPressure' => IntentMark.kickMark,
      _ => symptomArea(s).mark,
    };

/// An area's mark in its own tint, filling its box.
Widget symptomAreaMark(V2Palette p, SymptomArea a) => HubIntentArt(mark: a.mark, tint: symptomAreaTint(p, a));

/// A symptom's mark in its area's tint.
Widget symptomGlyph(V2Palette p, Symptom s, {double size = 28}) {
  final a = symptomArea(s);
  // Kept for revert — the filled mark:
  // return SizedBox(width: size, height: size, child: HubIntentArt(mark: symptomMark(s), tint: symptomAreaTint(p, a)));
  return symptomLineMark(s, size: size, ink: symptomAreaInk(p, a));
}

/// One tile of the check-in: a 64pt disc with the mark, the name under it,
/// and the strength as one to three dots. Not logged: the area's tint.
/// Logged: an ink ring around the tint, the dots filled.
///
/// ⚠️ THE TILE IS A BUTTON WITH TWO MEANINGS AND SAYS WHICH. Not logged →
/// tap logs it as mild (one tap, no sheet — the whole point of a check-in is
/// that it costs nothing). Logged → tap takes it off again (the user,
/// 2026-09-22: "tapping again should un-select it"). Hold → [onOpen], which
/// the check-in points at the strength sheet.
class SymptomTile extends StatelessWidget {
  const SymptomTile({
    super.key,
    required this.p,
    required this.symptom,
    required this.severity,
    required this.onTap,
    required this.onOpen,
    this.enabled = true,
    this.width = 78,
  });
  final V2Palette p;
  final Symptom symptom;

  /// Null when not logged that day.
  final String? severity;
  final VoidCallback onTap;
  final VoidCallback onOpen;
  final bool enabled;
  final double width;

  @override
  Widget build(BuildContext context) {
    final a = symptomArea(symptom);
    final tint = symptomAreaTint(p, a);
    final logged = severity != null;
    final dots = severityDots(severity);
    return Semantics(
      button: true,
      selected: logged,
      label: '${symptom.name.en}${logged ? ', ${severityLabel(severity!)}' : ''}',
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: GestureDetector(
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          onLongPress: () {
            pvCommitFeedback();
            onOpen();
          },
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: width,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                width: 64,
                height: 64,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tint,
                  border: Border.all(color: logged ? p.ink1 : Colors.transparent, width: 2),
                ),
                // Kept for revert — the filled mark:
                // child: HubIntentArt(mark: symptomMark(symptom), tint: tint),
                child: symptomLineMark(symptom, size: 34, ink: symptomAreaInk(p, a)),
              ),
              const SizedBox(height: 7),
              Text(symptom.name.en,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 11.5, height: 1.2, fontWeight: logged ? FontWeight.w800 : FontWeight.w600, color: p.ink1)),
              const SizedBox(height: 4),
              // Three dots, filled to the strength — a fixed slot so the
              // rows do not jump as she logs.
              SizedBox(
                height: 6,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        // The empty dots are faint ink, not `p.line`: at 6px the
                        // line grey read as filled on the phone (2026-09-22).
                        color: i < dots ? p.ink1 : p.ink1.withValues(alpha: logged ? 0.16 : 0),
                      ),
                    ),
                  ],
                ]),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

/// "How strong?" — three chips, and a way to take it off. Returns the
/// severity id, `''` to remove, or null when dismissed.
Future<String?> showSeveritySheet(BuildContext context, Symptom symptom, String current) {
  final p = V2PaletteStore.instance.current;
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: p.surface,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
                width: 36, height: 4, decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 18),
          Row(children: [
            symptomGlyph(p, symptom, size: 30),
            const SizedBox(width: 10),
            Expanded(
              child: Text(symptom.name.en,
                  style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
            ),
          ]),
          const SizedBox(height: 4),
          Text('How strong is it today?', style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink2)),
          const SizedBox(height: 14),
          for (final s in kSeverities) ...[
            _SeverityRow(p: p, id: s.$1, label: s.$2, line: s.$3, on: s.$1 == current, onTap: () => Navigator.of(ctx).pop(s.$1)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 6),
          // Only a logged symptom has a "not today" to offer.
          if (current.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(''),
              child: Text('Not today after all', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
            ),
        ]),
      ),
    ),
  );
}

class _SeverityRow extends StatelessWidget {
  const _SeverityRow({required this.p, required this.id, required this.label, required this.line, required this.on, required this.onTap});
  final V2Palette p;
  final String id;
  final String label;
  final String line;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: on ? p.ink1 : p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: on ? p.ink1 : p.line)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            pvCommitFeedback();
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
            child: Row(children: [
              SizedBox(
                width: 26,
                child: Row(children: [
                  for (var i = 0; i < severityDots(id); i++) ...[
                    if (i > 0) const SizedBox(width: 3),
                    Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: on ? p.ground : p.ink1)),
                  ],
                ]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w800, color: on ? p.ground : p.ink1)),
                  Text(line, style: pvManrope(fontSize: 12, height: 1.35, color: on ? p.ground.withValues(alpha: 0.8) : p.ink2)),
                ]),
              ),
            ]),
          ),
        ),
      );
}
