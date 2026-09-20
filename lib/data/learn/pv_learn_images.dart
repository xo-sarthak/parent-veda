// =============================================================================
//  Learn covers — free photos by topic, with the honest cover as the floor
// -----------------------------------------------------------------------------
//  The three learning catalogues carry no images at all (accent colours and
//  striped placeholders). A course page with no picture reads as a wireframe
//  next to a photographed store, so — the user's call, as for products — a
//  free Unsplash photo of the SUBJECT stands in, chosen by the programme's
//  topic words, never by its title. Every id below resolved on 2026-09-20;
//  a 404 falls through `Image.network`'s error builder to `PvCoverBlock`.
//
//  ⚠️ PLACEHOLDERS BY TOPIC, NOT PORTRAITS. No photo here claims to be the
//  expert; the expert card carries no photo until the roster does. To be
//  checked on the device walk — a wrong subject is a data edit here.
// =============================================================================

import 'pv_learn_view.dart';

String _u(String id) =>
    'https://images.unsplash.com/photo-$id?w=900&q=80&auto=format&fit=crop';

/// Topic word → photo. First match in the programme's topic list wins;
/// the kind's default is the floor.
final Map<String, String> _byTopic = {
  'sleep': _u('1503454537195-1dcabb73ffb9'),
  'newborn': _u('1555252333-9f8e92e65df9'),
  'feeding': _u('1519689680058-324335c77eba'),
  'breastfeeding': _u('1519689680058-324335c77eba'),
  'development': _u('1516627145497-ae6968895b74'),
  'play': _u('1516627145497-ae6968895b74'),
  'behaviour': _u('1527613426441-4da17471b66d'),
  'birth': _u('1476703993599-0035a21b17a9'),
  'labour': _u('1476703993599-0035a21b17a9'),
  'pregnancy': _u('1489710437720-ebb67ec84dd2'),
  'prenatal': _u('1544367567-0f2fcb009e0b'),
  'yoga': _u('1506126613408-eca07ce68773'),
  'postnatal': _u('1571019613454-1cb2f99b2d8b'),
  'breathing': _u('1515488042361-ee00e0ddd4e4'),
  'calm': _u('1515488042361-ee00e0ddd4e4'),
  'mind': _u('1518611012118-696072aa579a'),
  'mental': _u('1518611012118-696072aa579a'),
  'nutrition': _u('1544027993-37dbfe43562a'),
  'food': _u('1544027993-37dbfe43562a'),
  'doctor': _u('1576091160399-112ba8d25d1d'),
  'obstetrician': _u('1559839734-2b71ea197ec2'),
  'gynaecologist': _u('1559839734-2b71ea197ec2'),
  'paediatrician': _u('1584515933487-779824d29309'),
  'consults': _u('1576091160399-112ba8d25d1d'),
  'trying': _u('1524250502761-1ac6f2e30d43'),
  'ivf': _u('1579154204601-01588f351e67'),
  'assessments': _u('1434030216411-0b793f4b4173'),
  'courses': _u('1541781774459-bb2af2f05b55'),
};

final Map<PvLearnKind, String> _byKind = {
  PvLearnKind.course: _u('1588072432836-e10032774350'),
  PvLearnKind.masterclass: _u('1587614382346-4ec70e388b28'),
  PvLearnKind.cohort: _u('1522202176988-66273c2fd55f'),
  PvLearnKind.consult: _u('1576091160399-112ba8d25d1d'),
  PvLearnKind.classPack: _u('1544367567-0f2fcb009e0b'),
};

String? pvLearnCoverFor(List<String> topics, PvLearnKind kind) {
  for (final t in topics) {
    final k = t.toLowerCase().trim();
    for (final e in _byTopic.entries) {
      if (k.contains(e.key)) return e.value;
    }
  }
  return _byKind[kind];
}
