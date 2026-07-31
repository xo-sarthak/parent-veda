// =============================================================================
//  A doctor added in the panel must reach every surface that lists doctors.
// -----------------------------------------------------------------------------
//  This is a wiring test before it is anything else. The failure it exists to
//  catch is the one this repo has actually hit: correct code that nothing
//  calls. A published expert who appears on the consult screen but not in the
//  booking catalogue is worse than one who does not appear at all — they are
//  visible and unbookable, and the parent blames the app.
//
//  The model itself is checked too, but lightly. `fromMap` is a mapper; the
//  interesting question is not whether it copies a string, it is whether the
//  panel can accidentally assert something it has no business asserting.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/post_pregnancy/pp_experts_data.dart';
import 'package:parentveda/services/content_ownership.dart';
import 'package:parentveda/services/content_registry.dart';
import 'package:parentveda/services/expert_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  final sql = File('supabase/migrations/0072_expert_profiles.sql')
      .readAsStringSync();

  group('the identity and the capability stay separate', () {
    test('partner_id is nullable — consulting does not require onboarding', () {
      // A ParentVeda staff counsellor consults without ever being a referral
      // partner; a hospital is onboarded without ever consulting. Making this
      // NOT NULL would force one to imply the other, which is the split-by-
      // activity mistake this table was built to correct.
      // Read the COLUMN DEFINITION, not the file. An `isNot(contains(...))`
      // over the whole thing keeps matching the comments that explain the
      // decision — which fails on exactly the files that documented it best.
      // I have got this wrong four times now; the fix is to look at code.
      final line = sql
          .split('\n')
          .map((l) => l.trim())
          .firstWhere((l) => l.startsWith('partner_id') && !l.startsWith('--'));
      expect(line, contains('references public.care_partners (id)'));
      expect(line.toLowerCase(), isNot(contains('not null')));
    });

    test('the key is the compiled expert id, so nothing is orphaned', () {
      // expert_accounts.expert_id, booking_slots.expert_id and
      // care_partners.expert_id all already carry these values.
      expect(sql, contains('expert_id     text        primary key'));
    });

    test('a client cannot publish an expert', () {
      // A row here sets a price and puts a clinician's name in front of a
      // pregnant woman. That is an editorial act.
      expect(sql, contains('expert_profiles public read'));
      expect(
        RegExp(r'create policy[^;]*on public\.expert_profiles[^;]*for '
                r'(insert|update|delete|all) to (anon|authenticated)',
                caseSensitive: false, dotAll: true)
            .hasMatch(sql),
        isFalse,
      );
    });

    test('a negative fee is refused by the database, not by a form', () {
      expect(sql, contains('expert_profiles_fee_check'));
      expect(sql, contains('expert_profiles_duration_check'));
    });

    test('the fee is WHOLE RUPEES, so an editor types what they mean', () {
      // 0074. Storing paise passed every constraint while showing ₹8 for a
      // ₹800 consult — silent, and first noticed by a parent who booked.
      final fee = File('supabase/migrations/0074_expert_fee_in_rupees.sql')
          .readAsStringSync();
      expect(fee, contains('add column if not exists fee_inr'));
      expect(fee, contains('drop column fee_paise'));
      // Converted, not renamed: correct whether the table is empty today or
      // full next month.
      expect(fee, contains('set fee_inr = round(fee_paise / 100.0)'));
      final store = File('lib/services/expert_store.dart').readAsStringSync();
      expect(store.contains("row['fee_paise']"), isFalse);
    });

    test('an ORGANISATION can deliver a programme without consulting', () {
      // Got wrong twice. First a FK to expert_profiles — which made teaching
      // require a 1:1 consulting profile. Then a second host column on
      // programme_experts — which is an exception in the schema, and which
      // Postgres refused outright (expert_id is half the primary key, and a
      // PK column cannot be nullable).
      //
      // The answer was smaller: an organisation gets a deliverer row like
      // anybody else, with takes_consults false.
      expect(sql, contains('takes_consults boolean'));
      expect(sql.contains('references public.expert_profiles (expert_id)'),
          isFalse,
          reason: 'teaching must not require a consulting profile.');
      expect(sql.contains('add column if not exists partner_id text'), isFalse,
          reason: 'one host column — two would be the exception itself.');
    });
  });

  group('the panel adds doctors; it does not invent their hours', () {
    test('a published row supersedes a bundled one with the same id', () {
      final bundled = kExperts.first;
      ExpertStore.instance.setItemsForTest([
        Expert(
          id: bundled.id,
          name: 'Dr Panel Override',
          credential: 'MBBS, MD',
          backLabel: 'Obstetrician',
          location: 'Hyderabad',
          rating: '4.8',
          reviewsCount: '0 reviews',
          mid: ('', ''),
          fee: ('₹900', 'consult'),
          whyHeading: '',
          why: '',
          tags: const [],
          reviews: const [],
          ctaPrice: '₹900',
          ctaSub: 'video consult',
          ctaLabel: 'Book a consultation',
          disclaimer: '',
          category: 'Obstetrician',
          timings: 'By schedule',
        ),
      ]);

      final merged = mergedExperts();
      final match = merged.where((e) => e.id == bundled.id).toList();
      expect(match.length, 1, reason: 'never two rows for one id');
      expect(match.single.name, 'Dr Panel Override');
      // ...and everyone else still there, so publishing one does not blank
      // the catalogue.
      expect(merged.length, greaterThanOrEqualTo(kExperts.length));
    });

    test('an empty server list falls back to the bundled catalogue', () {
      // A booking screen with no clinicians on it is indistinguishable from a
      // broken fetch, and it would be broken for someone who has already paid.
      ExpertStore.instance.setItemsForTest(const []);
      expect(mergedExperts().length, kExperts.length);
    });

    test('an entity that only teaches is never offered as a consult', () {
      // takes_consults false -> empty timings -> BookingCatalog derives no
      // consult offering. That is how an organisation appears in the
      // catalogue without being bookable for a 1:1, with no branch on
      // entity type anywhere in the app.
      final store = File('lib/services/expert_store.dart').readAsStringSync();
      expect(store, contains("row['takes_consults'] == false ? ''"));
      // And the panel still cannot set HOURS — those come from the doctor's
      // own schedule in ParentVeda+.
      expect(store.contains("row['timings']"), isFalse,
          reason: 'the panel must not be able to set consulting hours.');
    });
  });

  group('it is actually reachable', () {
    test('every consulting surface reads the merged list, not kExperts', () {
      for (final f in const [
        'lib/booking/booking_catalog.dart',
        'lib/doctor/doctor_directory.dart',
      ]) {
        final src = File(f).readAsStringSync();
        expect(src, contains('mergedExperts()'),
            reason: '$f still reads the compiled list, so a doctor added in '
                'the panel would be invisible there.');
      }
    });

    test('the store is registered and loaded', () {
      expect(ContentRegistry.stores.map((s) => s.table),
          contains('expert_profiles'));
      expect(File('lib/main.dart').readAsStringSync(),
          contains('ExpertStore.instance.ensureLoaded()'));
    });

    test('ownership is declared, so the export tools know', () {
      // An unlisted table is one an export tool would happily overwrite.
      expect(() => ContentOwnership.of('expert_profiles'), returnsNormally);
    });
  });
}
