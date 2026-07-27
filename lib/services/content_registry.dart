// =============================================================================
//  ContentRegistry — every content store in one list.
// -----------------------------------------------------------------------------
//  Without this, "refresh server-driven content" means naming each store at
//  each call site, and adding a content type means remembering to edit
//  main_scaffold.dart and both pull-to-refresh handlers in week_flow_screen.
//  Nobody remembers the third one. Then the new type looks broken in a way that
//  only shows up as "it doesn't update until I reinstall".
//
//  So: register the store here once, and the call sites never change again.
//
//  This is also the list the content tests iterate — unique cache keys, a
//  non-empty seed, and a table that actually exists in supabase/migrations/.
//  That last check is the cheap version of a schema contract test, and it
//  matters because content fetches swallow their errors by design: a renamed or
//  misspelled table would otherwise be indistinguishable from "no content yet".
// =============================================================================

import 'article_store.dart';
import 'content_store.dart';
import 'product_catalog_store.dart';
import 'read_store.dart';
import 'recipe_store.dart';

class ContentRegistry {
  const ContentRegistry._();

  /// Every store the app serves editor-owned content through.
  ///
  /// Add a type here as step 5 of the add-a-type recipe
  /// (docs/CONTENT-BACKEND.md). If it is not in this list it will not refresh
  /// on app resume, which is the whole point of the content backend.
  static List<ContentStore<Object?>> get stores => <ContentStore<Object?>>[
        ArticleStore.instance,
        RecipeStore.instance,
        ReadStore.instance,
        ProductCatalogStore.instance,
      ];

  /// Re-pull everything. Called on app resume; each store applies its own
  /// throttle, so this is cheap to call often and safe to call while offline.
  static Future<void> refreshAll() async {
    await Future.wait(stores.map((s) => s.refresh()));
  }

  /// An explicit user gesture (pull-to-refresh) — skips the throttles.
  static Future<void> forceRefreshAll() async {
    await Future.wait(stores.map((s) => s.refresh(force: true)));
  }
}
