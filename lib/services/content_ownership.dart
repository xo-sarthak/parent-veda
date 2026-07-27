// =============================================================================
//  ContentOwnership — the one place that answers "who owns this content?"
// -----------------------------------------------------------------------------
//  THE PROBLEM THIS SOLVES
//
//  ParentVeda's content has had two homes and no referee. A developer edits a
//  Dart file and the app's screens change. An editor publishes in Directus and
//  Supabase changes — which Ask Veda reads, but the screens do not. The export
//  tools (tool/export_veda_corpus.dart, tool/export_ttc_corpus.dart) push Dart
//  INTO Supabase, so re-running one after an editor has been at work would
//  silently overwrite them. Nothing syncs the other way, and nothing warns.
//
//  This map is the referee. For every content type it states, at compile time,
//  whether the truth lives in Dart or in the database. Exactly two things read
//  it: the content stores, and the export tools.
//
//  WHY DART AND NOT A TABLE
//
//  It is tempting to make this a config row. It must not be. Ownership of the
//  truth is a BUILD decision — putting it in the database would let a network
//  change decide who owns the truth, which is the precise failure this exists to
//  prevent. It is also not the "config object with dozens of flags" CLAUDE.md
//  warns against: it is one constant, one entry per type, read by two call
//  sites, and every entry has something concrete reading it.
//
//  FLIPPING A TYPE — all three in one window, or none:
//    1. the entry here                          -> ContentOwner.editor
//    2. AskVeda ingest/ingest.py SOURCE_SPECS   -> add the table
//    3. delete that type's veda_knowledge rows by doc_id prefix
//
//  Skip (3) and retrieval holds two copies of the same knowledge — one live,
//  one frozen — and Ask Veda answers from whichever scores higher. That is the
//  "same question, two answers" defect all over again.
//
//  See docs/CONTENT-BACKEND.md for the full add-a-type recipe.
// =============================================================================

enum ContentOwner {
  /// The Dart file is the truth. Supabase holds a published copy for Ask Veda,
  /// kept current by re-running the export tool.
  bundled,

  /// The Supabase table is the truth. The Dart list survives ONLY as the
  /// offline/first-run seed, and the export tool must skip this type.
  editor,
}

class ContentOwnership {
  const ContentOwnership._();

  /// Keyed by table name — the same string a [ContentStore] passes as `table`
  /// and the same key AskVeda's SOURCE_SPECS uses. One vocabulary, three repos.
  static const Map<String, ContentOwner> _owners = <String, ContentOwner>{
    // Flipped 2026-07-14 (migration 0019). The weekly-reads carousel reads the
    // table; kWeekArticles is now only the offline seed.
    'articles': ContentOwner.editor,

    // Migrated in Phase 3, one at a time. Each stays `bundled` until its
    // migration, seed, store and parity test have all landed together.
    'recipes': ContentOwner.bundled,
    'reads': ContentOwner.bundled,
    'products': ContentOwner.bundled,

    // Deliberately deferred, with reasons — see docs/ADMIN-PANEL.md:
    //   ttc_daily : TTC is the newest stage and has not been run on a device
    //               yet. Moving content whose structure is still moving means
    //               the table shape chases the Dart shape. lib/ttc/
    //               ttc_daily_data.dart carries kTtcContentIsSeed for this.
    //   videos    : parked behind Bunny Stream, which is deliberately unpaid
    //               until there are real videos to serve.
  };

  /// Which content table a corpus doc's [VedaKind] belongs to.
  ///
  /// The export tools speak in VedaKind; this map and [_owners] speak in table
  /// names. Without the translation an export tool cannot tell whether the docs
  /// it is about to emit have already become an editor's property.
  ///
  /// A kind that is absent here has no content table and is therefore always
  /// safe to export — week content, body changes, garbh, tools and the rest are
  /// fixed product content that stays bundled by decision, not by omission.
  static const Map<String, String> _tableForKindName = <String, String>{
    'recipe': 'recipes',
    'product': 'products',
    'read': 'reads',
    'spiritual': 'reads',
  };

  static ContentOwner of(String table) =>
      _owners[table] ?? ContentOwner.bundled;

  /// True when docs of this corpus kind must NOT be exported, because an editor
  /// now owns them and a re-export would overwrite their work.
  ///
  /// Called by tool/export_veda_corpus.dart and tool/export_ttc_corpus.dart.
  /// `test/content_ownership_test.dart` asserts both tools consult it.
  static bool isKindEditorOwned(String kindName) {
    final table = _tableForKindName[kindName];
    return table != null && isEditorOwned(table);
  }

  /// True when Supabase is the source of truth and Dart is only a fallback.
  /// The export tools MUST skip these — re-exporting would overwrite an editor.
  static bool isEditorOwned(String table) =>
      of(table) == ContentOwner.editor;

  static List<String> get editorOwned => _owners.entries
      .where((e) => e.value == ContentOwner.editor)
      .map((e) => e.key)
      .toList(growable: false);

  static List<String> get known => _owners.keys.toList(growable: false);
}
