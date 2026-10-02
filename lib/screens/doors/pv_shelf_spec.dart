// =============================================================================
//  What a pregnancy card says it is (2026-10-02)
// -----------------------------------------------------------------------------
//  The user, with TTC's doors beside the pregnancy ones: "see how a tool is
//  represented with that icon, how an article, a video is; apply the same on
//  the pregnancy side so consistency is maintained ... keep the images as they
//  are; just apply the UI so a user can tell what each thing is."
//
//  So this decides ONLY the identification, never the picture:
//    · the KIND, which picks the badge and the word (TTC's own: a wrench and
//      "Tool", a document and "Article", scales and "Myth or fact", a camera and
//      "Video", a conversation and "Talk to an expert", a fork and "Recipe");
//    · the one FACT after the word ("9 min read", "Weeks 14 to 27", "2 min
//      watch", "30 min loop"), derived, never typed twice;
//    · whether it is PAID (a ₹ in place of the badge) and whether it is a LIVE
//      1:1 (TTC's red-dot pill).
//
//  ⚠️ IT IS A PURE FUNCTION ON PURPOSE, so a test can run it over every tile on
//  every door: the claim ("every card says what it is") is about all of them,
//  and a card that fell through to a generic label would otherwise look fine.
//
//  ⚠️ A WEEK RANGE BEATS A READING TIME WHERE THE CARD HAS ONE. TTC's line is
//  "Article · 9 min read". A pregnancy guide often carries "Weeks 14 to 27",
//  which is what decides whether it is for her today; the minutes are the
//  fallback, not the headline. The word is the same on every card either way.
// =============================================================================

import '../../data/doors/pv_door_data.dart';
import '../../data/reads/pregnancy_reads.dart' show pregnancyReadById;

/// What a card is. TTC's kinds that pregnancy has a tile for, plus the three it
/// keeps of its own (audio, game, plan) so they still say what they are.
enum PvShelfKind { tool, read, myth, video, talk, recipe, audio, game, plan }

/// The card's identification.
class PvShelfSpec {
  const PvShelfSpec(this.kind, {this.fact, this.paid = false, this.live = false});
  final PvShelfKind kind;

  /// The one fact after the word, or null.
  final String? fact;

  /// A ₹ replaces the badge.
  final bool paid;

  /// TTC's "Live 1:1" pill: a format, never a claim that anyone is online.
  final bool live;
}

PvShelfKind pvShelfKindOf(PvDoorFormat f) => switch (f) {
      PvDoorFormat.tool || PvDoorFormat.checklist => PvShelfKind.tool,
      PvDoorFormat.article || PvDoorFormat.guide || PvDoorFormat.read => PvShelfKind.read,
      PvDoorFormat.mythFact => PvShelfKind.myth,
      PvDoorFormat.talk => PvShelfKind.talk,
      PvDoorFormat.recipe => PvShelfKind.recipe,
      PvDoorFormat.video => PvShelfKind.video,
      PvDoorFormat.audio => PvShelfKind.audio,
      PvDoorFormat.game => PvShelfKind.game,
      PvDoorFormat.plan => PvShelfKind.plan,
    };

/// A meta typed in capitals ("3 MIN", "30 MIN LOOP") as a quiet fact ("3 min").
String _quiet(String s) {
  final t = s.trim();
  return t == t.toUpperCase() ? t.toLowerCase() : t;
}

/// "2 MIN" -> "2 min watch" (a film's length, in TTC's words).
String? _watch(String? meta) {
  final m = RegExp(r'(\d+)').firstMatch(meta ?? '');
  return m == null ? null : '${m.group(1)} min watch';
}

bool _isMoney(String? meta) => (meta ?? '').contains('₹');

/// The reading time of the read a tile opens, or null where it opens none.
String? _readMinutes(PvDoorTile t) {
  final id = switch (t) {
    PvDoorGuideTile(:final readId) => readId,
    PvDoorMythTile(:final readId) => readId,
    PvDoorReadTile(:final surfaceId) => surfaceId,
    _ => null,
  };
  final r = id == null ? null : pregnancyReadById(id);
  if (r == null) return null;
  // TTC's rule: a very short piece does not claim a reading time.
  if (r.wordCount < 200) return null;
  return '${r.minutes} min read';
}

PvShelfSpec pvShelfSpecFor(PvDoorTile t) {
  final kind = pvShelfKindOf(t.format);
  final meta = t.meta?.trim();
  final hasMeta = meta != null && meta.isNotEmpty;

  switch (kind) {
    case PvShelfKind.read:
      return PvShelfSpec(kind,
          fact: hasMeta ? _quiet(meta) : _readMinutes(t));
    case PvShelfKind.myth:
      // TTC's line is the word alone: "Myth or fact".
      return PvShelfSpec(kind);
    case PvShelfKind.video:
      return PvShelfSpec(kind, fact: _watch(meta));
    case PvShelfKind.talk:
      final paid = _isMoney(meta);
      final one = (meta ?? '').toLowerCase().contains('per session') ||
          t.title.toLowerCase().contains('1:1') ||
          t.title.toLowerCase().contains('one-on-one');
      return PvShelfSpec(kind, paid: paid, live: one);
    case PvShelfKind.tool:
      // A tool that costs money (a class pack) is paid; one with a length says it.
      if (_isMoney(meta)) return PvShelfSpec(kind, paid: true);
      return PvShelfSpec(kind, fact: hasMeta ? _quiet(meta) : null);
    case PvShelfKind.audio:
    case PvShelfKind.game:
    case PvShelfKind.plan:
    case PvShelfKind.recipe:
      return PvShelfSpec(kind, fact: hasMeta ? _quiet(meta) : null);
  }
}
