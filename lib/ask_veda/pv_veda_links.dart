// =============================================================================
//  Pregnancy Ask Veda: document ids, and the way back into the app (2026-10-02)
// -----------------------------------------------------------------------------
//  The user: "the way we did for TTC ... Ask Veda's answers should be in-app
//  stuff as well, so users can use it to search efficiently in the app and for
//  their doubts."
//
//  TTC's pattern, for pregnancy:
//    1. the EXPORT (`tool/export_pregnancy_corpus.dart`) writes every piece of
//       pregnancy content as a document with an id from this file;
//    2. the SERVICE grounds an answer in those documents and hands the ids back
//       as the "More information" cards;
//    3. the SCREEN turns a card's id into the real page (`openPvVedaDoc`), so a
//       tap lands on the read, the door card or the tool, not on a text sheet.
//
//  ⚠️ THE ID HELPERS AND THE RESOLVER LIVE IN ONE FILE ON PURPOSE. They are two
//  halves of one contract (what the exporter writes, the screen reads), and the
//  failure when they disagree is silent: an id that resolves to nothing falls
//  back to a text sheet and nobody notices. `test/pv_veda_links_test.dart`
//  round-trips every exported id through the resolver, so a half cannot change
//  alone.
//
//  THE NAMESPACE, and why each prefix is its own:
//    pvread_<readId>               a long read (kPregnancyReads)
//    pvfaq_<readId>_<n>            one question and answer from that read, its
//                                  own small document (a question matches a
//                                  question far better than a whole article)
//    pvdoor_<bracketId>            a door as a whole: what it is, its tabs
//    pvdoor_<bracketId>__<slug>    one card on a door that is not itself a read
//                                  (a tool, a checklist, a film, a library entry)
//    pvtool_<toolId>               a tool on the Tools list
//
//  ⚠️ NONE OF THESE IS KIND 'read'. 'read' is the editor-owned reads table
//  (`content_ownership.dart`); the export's ratchet would silently skip every
//  document of an editor-owned kind. TTC hit exactly this and named its kind
//  'ttcread' for it.
// =============================================================================

import 'package:flutter/material.dart';

import '../data/doors/pv_door_data.dart';
import '../data/reads/pregnancy_reads.dart' show kPregnancyReads, pregnancyReadById;
import '../localization/app_language.dart';
import '../screens/belly_skin/bump_ritual_screen.dart';
import '../screens/doors/pv_door_router.dart'
    show openPvDoorRead, openPvDoorTile;
import '../screens/doors/pv_door_screen.dart' show PvDoorScreen;
import '../screens/journal_screen.dart';
import '../screens/pregnancy/birth_plan_screen.dart';
import '../screens/reminders_screen.dart';
import '../screens/tools/baby_movement_screen.dart';
import '../screens/tools/contraction_tracker_screen.dart';
import '../screens/tools/due_date_calculator_screen.dart';
import '../screens/tools/kegel_care_screen.dart';
import '../screens/tools/medicine_tracker_screen.dart';
import '../screens/tools/product_checklist_screen.dart';
import '../screens/tools/readings_log_screen.dart';
import '../screens/tools/ready_for_birth_screen.dart';
import '../screens/tools/spiritual_reading_screen.dart';
import '../screens/tools/weight_tracker_screen.dart';
import '../services/bracket_resolver.dart' show bracketById;
import '../services/pregnancy_controller.dart';

const String kPvVedaReadPrefix = 'pvread_';
const String kPvVedaFaqPrefix = 'pvfaq_';
const String kPvVedaDoorPrefix = 'pvdoor_';
const String kPvVedaToolPrefix = 'pvtool_';

/// Every id this file makes starts with this, so the service can prune exactly
/// this namespace (`import_corpus --prune-prefix pv`) and nothing older.
const String kPvVedaNamespace = 'pv';

// ---- ids ----------------------------------------------------------------------

String pvVedaReadId(String readId) => '$kPvVedaReadPrefix$readId';
String pvVedaFaqId(String readId, int n) => '$kPvVedaFaqPrefix${readId}_$n';
String pvVedaToolId(String toolId) => '$kPvVedaToolPrefix$toolId';

/// A card's title as a stable key: lower case, runs of anything that is not a
/// letter or a digit become one underscore.
String pvTileSlug(String title) => title
    .toLowerCase()
    .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
    .replaceAll(RegExp(r'^_+|_+$'), '');

String pvVedaDoorId(String bracketId, [PvDoorTile? tile]) => tile == null
    ? '$kPvVedaDoorPrefix$bracketId'
    : '$kPvVedaDoorPrefix${bracketId}__${pvTileSlug(tile.title)}';

// ---- which door cards are documents --------------------------------------------

/// A card that opens a read is the read's document (`pvread_`), so it is not
/// also a door document. A card that is not made yet cannot be opened, so it is
/// never pointed to.
bool pvVedaTileIsDocument(PvDoorTile t) {
  if (t.comingSoon) return false;
  if (pvTileSlug(t.title).isEmpty) return false;
  return switch (t) {
    PvDoorReadTile() || PvDoorGuideTile() || PvDoorMythTile() => false,
    _ => true,
  };
}

/// Every door card that is a document, once per door (the first with a given
/// slug wins), in door order. The exporter and the resolver both walk this.
List<(PvDoorPage, PvDoorTile)> pvVedaDoorTiles() {
  final out = <(PvDoorPage, PvDoorTile)>[];
  for (final page in kPvDoorPages) {
    final seen = <String>{};
    for (final t in page.allTiles) {
      if (!pvVedaTileIsDocument(t)) continue;
      if (!seen.add(pvTileSlug(t.title))) continue;
      out.add((page, t));
    }
  }
  return out;
}

// ---- the Tools list -------------------------------------------------------------

/// One tool on the Tools list: the id in its document, its words, and the screen
/// it opens. The words are the Tools list's own (`tools_hub_screen.dart`);
/// `test/pv_veda_links_test.dart` pumps that list and fails if a title here is
/// not on it, so the two cannot drift.
class PvVedaTool {
  const PvVedaTool(this.id, this.title, this.line, this.route, this.build,
      {this.keywords = const []});
  final String id;
  final String Function(S s) title;
  final String line;
  final String route;
  final Widget Function(PregnancyController c) build;
  final List<String> keywords;
}

final List<PvVedaTool> kPvVedaTools = [
  PvVedaTool('movement', (s) => s.babyMovementTracker,
      "Count kicks and get to know your baby's pattern", 'tools/movement',
      (c) => BabyMovementScreen(controller: c),
      keywords: const ['kick count', 'fetal movement', 'baby movements']),
  PvVedaTool('weight', (s) => s.toolWeightTitle,
      'Log your weight and see a healthy range for you', 'tools/weight',
      (c) => WeightTrackerScreen(controller: c),
      keywords: const ['weight gain', 'bmi']),
  PvVedaTool('medicines', (s) => s.medTitle,
      'What your doctor prescribed, with reminders', 'tools/medicines',
      (c) => MedicineTrackerScreen(controller: c),
      keywords: const ['tablets', 'supplements', 'iron', 'folic acid']),
  PvVedaTool('readings', (_) => 'Blood pressure & sugar',
      'Log the numbers your doctor asked for, and share them', 'tools/readings',
      (c) => ReadingsLogScreen(controller: c),
      keywords: const ['bp', 'blood pressure', 'blood sugar', 'glucose']),
  PvVedaTool('kegel', (s) => s.toolKegelTitle,
      'A few minutes a day for your pelvic floor', 'tools/kegel',
      (c) => KegelCareScreen(controller: c),
      keywords: const ['pelvic floor', 'exercise']),
  PvVedaTool('reminders', (s) => s.rmdTitle,
      'What we remind you about, and when', 'tools/reminders',
      (c) => RemindersScreen(controller: c)),
  PvVedaTool('hospital_bag', (s) => s.hbName,
      'What to pack for you, your baby and your partner', 'tools/hospital_bag',
      (c) => ReadyForBirthScreen(controller: c),
      keywords: const ['packing', 'labour bag', 'delivery bag']),
  PvVedaTool('birth_plan', (_) => 'Birth plan',
      'What you would like on the day, to share with your doctor',
      kLabourSurfaceBirthPlan, (c) => BirthPlanScreen(pregnancy: c),
      keywords: const ['delivery preferences']),
  PvVedaTool('contractions', (s) => s.toolContractionTitle,
      'Time your contractions and see when to go in', 'tools/contractions',
      (c) => ContractionTrackerScreen(controller: c),
      keywords: const ['labour pains', 'timer', 'when to go to hospital']),
  PvVedaTool('due_date', (s) => s.ddcToolTitle,
      'Work out your due date, or update it after a scan', 'tools/due_date',
      (c) => DueDateCalculatorScreen(controller: c),
      keywords: const ['edd', 'expected delivery date', 'lmp']),
  PvVedaTool('product_checklist', (s) => s.pclTitle,
      'What you really need before the baby comes', 'tools/product_checklist',
      (c) => ProductChecklistScreen(controller: c),
      keywords: const ['shopping list', 'baby things']),
  PvVedaTool('journal', (s) => s.jrTitle, 'Write to yourself, or to your baby',
      'journal', (c) => JournalScreen(controller: c),
      keywords: const ['diary', 'letters']),
  PvVedaTool('bump', (s) => s.bumpTitle, 'A photo of your bump, week by week',
      'tools/bump', (c) => BumpRitualScreen(controller: c),
      keywords: const ['bump photo']),
  PvVedaTool('spiritual_reading', (s) => s.sprToolTitle,
      'Short readings to hear, or to read aloud', 'tools/spiritual_reading',
      (c) => SpiritualReadingScreen(controller: c),
      keywords: const ['garbh sanskar', 'mantra', 'stories']),
];

PvVedaTool? pvVedaToolById(String id) {
  for (final t in kPvVedaTools) {
    if (t.id == id) return t;
  }
  return null;
}

// ---- the way back into the app ----------------------------------------------------

/// What `openPvVedaDoc` would open for [docId], without opening it: true when
/// the id names something that exists. The exporter's test and the screen both
/// ask this, so "resolves" has one meaning.
bool pvVedaDocResolves(String docId) => _resolve(docId) != null;

enum _Kind { read, door, doorTile, tool }

class _Target {
  const _Target(this.kind, {this.readId, this.page, this.tile, this.tool});
  final _Kind kind;
  final String? readId;
  final PvDoorPage? page;
  final PvDoorTile? tile;
  final PvVedaTool? tool;
}

_Target? _resolve(String rawId) {
  var id = rawId;
  // A `_hi` twin is the same page.
  if (id.endsWith('_hi')) id = id.substring(0, id.length - 3);

  if (id.startsWith(kPvVedaReadPrefix)) {
    final readId = id.substring(kPvVedaReadPrefix.length);
    return pregnancyReadById(readId) == null
        ? null
        : _Target(_Kind.read, readId: readId);
  }
  if (id.startsWith(kPvVedaFaqPrefix)) {
    // The question belongs to a read: the read is what opens.
    final rest = id.substring(kPvVedaFaqPrefix.length);
    final cut = rest.lastIndexOf('_');
    if (cut <= 0) return null;
    final readId = rest.substring(0, cut);
    return pregnancyReadById(readId) == null
        ? null
        : _Target(_Kind.read, readId: readId);
  }
  if (id.startsWith(kPvVedaDoorPrefix)) {
    final key = id.substring(kPvVedaDoorPrefix.length);
    final cut = key.indexOf('__');
    final bracketId = cut < 0 ? key : key.substring(0, cut);
    PvDoorPage? page;
    for (final p in kPvDoorPages) {
      if (p.bracketId == bracketId) page = p;
    }
    if (page == null) return null;
    if (cut < 0) return _Target(_Kind.door, page: page);
    final slug = key.substring(cut + 2);
    for (final t in page.allTiles) {
      if (pvVedaTileIsDocument(t) && pvTileSlug(t.title) == slug) {
        return _Target(_Kind.doorTile, page: page, tile: t);
      }
    }
    return null;
  }
  if (id.startsWith(kPvVedaToolPrefix)) {
    final tool = pvVedaToolById(id.substring(kPvVedaToolPrefix.length));
    return tool == null ? null : _Target(_Kind.tool, tool: tool);
  }
  return null;
}

/// Opens the page [docId] names, and says whether it did. False means "this is
/// not one of ours" (an older document, a product, a film): the caller keeps
/// its own handling.
bool openPvVedaDoc(BuildContext context, String docId, PregnancyController c) {
  final t = _resolve(docId);
  if (t == null) return false;
  switch (t.kind) {
    case _Kind.read:
      openPvDoorRead(context, t.readId!, c);
    case _Kind.doorTile:
      openPvDoorTile(context, t.tile!, c);
    case _Kind.door:
      final bracket = bracketById(t.page!.bracketId);
      if (bracket == null) return false;
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'bracket/${t.page!.bracketId}'),
        builder: (_) =>
            PvDoorScreen(page: t.page!, bracket: bracket, pregnancy: c),
      ));
    case _Kind.tool:
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: t.tool!.route),
        builder: (_) => t.tool!.build(c),
      ));
  }
  return true;
}

/// How many reads exist, for the exporter's report and a test.
int get pvVedaReadCount => kPregnancyReads.length;
