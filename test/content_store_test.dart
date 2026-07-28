// =============================================================================
//  ContentStore invariants — the cheap checks that catch expensive silence.
// -----------------------------------------------------------------------------
//  Content fetches swallow their errors on purpose: a content backend must
//  never crash the app, and being offline is normal. The cost of that decision
//  is that a misspelled table, a duplicated cache key or a missing seed all
//  present identically — as "this section is just empty" — and can ship.
//
//  These tests are the counterweight. They are deliberately structural rather
//  than behavioural: no network, no mocks (this repo has no mocking framework),
//  just the properties every store must hold to be safe.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/content_registry.dart';

void main() {
  final stores = ContentRegistry.stores;

  test('the registry is not empty', () {
    // If this fails, app-resume refresh is a no-op and every content type has
    // silently stopped updating.
    expect(stores, isNotEmpty);
  });

  test('every store ships a non-empty seed, unless it declares serverOnly', () {
    for (final store in stores) {
      if (store.serverOnly) continue; // inventory, not a library — see below
      expect(
        store.seed,
        isNotEmpty,
        reason: '${store.table} has no bundled seed. Local-first is absolute: '
            'first launch, offline, and a failed fetch must all still render '
            'content, and the seed is the only thing standing there. If this '
            'type genuinely ships nothing, declare serverOnly: true.',
      );
    }
  });

  test('serverOnly is used only where there is genuinely nothing to ship', () {
    // The flag exists so an exception is stated rather than smuggled in as an
    // empty list. It is right for INVENTORY — there are no masterclasses until
    // somebody schedules one — and wrong for a library, where an empty screen
    // offline is a defect. Passing a seed AND serverOnly means one of the two
    // is a mistake.
    for (final store in stores.where((s) => s.serverOnly)) {
      expect(
        store.seed,
        isEmpty,
        reason: '${store.table} declares serverOnly but ships ${store.seed.length} '
            'seed item(s). Either it has content to ship — drop the flag — or '
            'the seed is left over.',
      );
    }
  });

  test('cache keys are unique and versioned', () {
    final seen = <String, String>{};
    for (final store in stores) {
      final previous = seen[store.cacheKey];
      expect(
        previous,
        isNull,
        reason: 'Cache key "${store.cacheKey}" is used by both $previous and '
            '${store.table}. They would overwrite each other in '
            'SharedPreferences and each would deserialise the other\'s rows.',
      );
      seen[store.cacheKey] = store.table;

      expect(
        RegExp(r'_v\d+$').hasMatch(store.cacheKey),
        isTrue,
        reason: '${store.cacheKey} needs a version suffix (e.g. _v1). Changing '
            'the cached shape without one leaves old clients decoding rows '
            'that no longer match their model.',
      );
    }
  });

  test('every store points at a table some migration actually creates', () {
    // The cheap version of a schema contract test. A renamed or misspelled
    // table returns a PostgrestException, which _fetchFresh catches by design —
    // so without this check the symptom is "the new content type is always
    // empty" with nothing in the logs.
    final migrations = Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .map((f) => f.readAsStringSync())
        .join('\n');

    for (final store in stores) {
      // A store may read a VIEW rather than a table — programmes do, because
      // "who hosts this" is a join and the rule belongs next to the data.
      final created = RegExp(
              'create (table (if not exists )?|or replace view |view )'
              '(public\\.)?${store.table}\\b',
              caseSensitive: false)
          .hasMatch(migrations);
      expect(
        created,
        isTrue,
        reason: 'No migration creates "${store.table}" as a table or a view, '
            'so every fetch will fail silently and the store will serve its '
            'seed forever.',
      );
    }
  });

  test('stores start by serving their seed, before any network call', () {
    for (final store in stores) {
      store.resetForTest();
      expect(
        store.all.length,
        store.seed.length,
        reason: '${store.table} must render its bundled content immediately, '
            'without waiting for a fetch.',
      );
      expect(store.isServingBackendContent, isFalse);
    }
  });
}
