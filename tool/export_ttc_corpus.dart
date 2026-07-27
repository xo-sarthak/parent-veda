// =============================================================================
//  EXPORT TOOL (not a test) — dump the TRYING-TO-CONCEIVE corpus to JSON.
// -----------------------------------------------------------------------------
//  Run:  flutter test tool/export_ttc_corpus.dart
//  Out:  build/ttc_corpus.json   →  ingest/import_corpus.py in the AskVeda repo
//
//  Companion to export_veda_corpus.dart (pregnancy + parenting). Kept separate
//  because the TTC data files are their own module and the doc-id namespace is
//  distinct.
//
//  TWO RULES FROM THE HANDOFF, both load-bearing:
//
//  1. BOTH LANGUAGES. Every field has an …En/…Hi pair, and a Hinglish question
//     should retrieve the Hinglish text. `body_hi` is stored but NOT embedded by
//     the ingest (it only embeds `body`), so storing the pair alone would leave
//     Hinglish unsearchable. Hence each item is emitted TWICE — an English doc
//     and a `_hi` doc — so both are embedded and either language can be matched.
//
//  2. THE HONESTY HALF. For products, `watchOut` is exported with the SAME
//     weight as `lookFor`. Several entries exist mainly to talk a couple OUT of
//     buying something; dropping that half turns a research page into an advert.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/content_ownership.dart';
import 'package:parentveda/ttc/ttc_can_i_data.dart';
import 'package:parentveda/ttc/ttc_chapter_data.dart';
import 'package:parentveda/ttc/ttc_daily_data.dart';
import 'package:parentveda/ttc/ttc_partner_data.dart';
import 'package:parentveda/ttc/ttc_prepare_data.dart';
import 'package:parentveda/ttc/ttc_products_data.dart';
import 'package:parentveda/ttc/ttc_tests_data.dart';
import 'package:parentveda/ttc/ttc_trackers_data.dart';

void main() {
  test('export the TTC corpus to build/ttc_corpus.json', () {
    final out = <Map<String, dynamic>>[];
    final skipped = <String, int>{};

    /// Emit one item as TWO docs (English + Hinglish) so both are embedded.
    void add({
      required String docId,
      required String kind,
      required String sourceLabel,
      required String titleEn,
      required String titleHi,
      required String bodyEn,
      required String bodyHi,
      List<String> keywords = const [],
    }) {
      String clean(String s) => s.trim();
      if (clean(bodyEn).isEmpty || clean(titleEn).isEmpty) return;
      // THE RATCHET — see lib/services/content_ownership.dart. An editor-owned
      // type's truth is the Supabase table; re-exporting it from Dart would
      // overwrite published work with an older bundled copy.
      if (ContentOwnership.isKindEditorOwned(kind)) {
        skipped[kind] = (skipped[kind] ?? 0) + 1;
        return;
      }
      out.add(<String, dynamic>{
        'doc_id': docId,
        'kind': kind,
        'domain': 'trying',
        'source_label': sourceLabel,
        'title': clean(titleEn),
        'body': clean(bodyEn),
        'title_hi': clean(titleHi),
        'body_hi': clean(bodyHi),
        'keywords': keywords,
      });
      // The Hinglish twin — same knowledge, retrievable by a Hinglish question.
      if (clean(bodyHi).isNotEmpty) {
        out.add(<String, dynamic>{
          'doc_id': '${docId}_hi',
          'kind': kind,
          'domain': 'trying',
          'source_label': sourceLabel,
          'title': clean(titleHi),
          'body': clean(bodyHi),
          'title_hi': clean(titleHi),
          'body_hi': clean(bodyHi),
          'keywords': keywords,
        });
      }
    }

    String join(List<String> parts) =>
        parts.where((s) => s.trim().isNotEmpty).join('\n\n');

    // ---- insights (S4) ------------------------------------------------------
    for (final i in ttcInsights) {
      add(
        docId: 'ttcinsight_${i.id}',
        kind: 'ttcinsight',
        sourceLabel: 'Trying to conceive',
        titleEn: i.titleEn,
        titleHi: i.titleHi,
        bodyEn: join([i.bodyEn, i.takeawayEn]),
        bodyHi: join([i.bodyHi, i.takeawayHi]),
        keywords: [i.topic],
      );
    }

    // ---- myths (S4) — the myth AND the correction ---------------------------
    for (final m in ttcMyths) {
      add(
        docId: 'ttcmyth_${m.id}',
        kind: 'ttcmyth',
        sourceLabel: 'Myth vs fact',
        titleEn: m.mythEn,
        titleHi: m.mythHi,
        bodyEn: join(['Myth: ${m.mythEn}', 'What is actually true: ${m.truthEn}']),
        bodyHi: join(['Myth: ${m.mythHi}', 'Sach kya hai: ${m.truthHi}']),
      );
    }

    // ---- chapters (S4) — one doc per section face ---------------------------
    for (final entry in ttcChapterContent.entries) {
      final chapter = entry.key;
      final c = entry.value;
      add(
        docId: 'ttcchapter_${chapter.name}_overview',
        kind: 'ttcchapter',
        sourceLabel: 'Your chapter',
        titleEn: 'Where you are: ${chapter.name}',
        titleHi: 'Tum abhi kahan ho: ${chapter.name}',
        bodyEn: join([c.overviewEn, c.medicalEn]),
        bodyHi: join([c.overviewHi, c.medicalHi]),
      );
      final faces = <String, List<TtcSection>>{
        'me': c.me,
        'us': c.us,
        'next': c.next,
      };
      for (final f in faces.entries) {
        for (var n = 0; n < f.value.length; n++) {
          final s = f.value[n];
          add(
            docId: 'ttcchapter_${chapter.name}_${f.key}_$n',
            kind: 'ttcchapter',
            sourceLabel: 'Your chapter',
            titleEn: s.titleEn,
            titleHi: s.titleHi,
            bodyEn: s.bodyEn,
            bodyHi: s.bodyHi,
          );
        }
      }
    }

    // ---- tests (S4) — what / why / WHEN in the cycle / cost / how to read ---
    for (final t in ttcTests) {
      add(
        docId: 'ttctest_${t.id}',
        kind: 'ttctest',
        sourceLabel: 'Fertility tests',
        titleEn: t.name,
        titleHi: t.name,
        bodyEn: join([
          t.whatEn,
          'Why it is done: ${t.whyEn}',
          'When in the cycle: ${t.whenEn}',
          'Cost in India: ${t.costEn}',
          'How to read it: ${t.readingEn}',
        ]),
        bodyHi: join([
          t.whatHi,
          'Kyun hota hai: ${t.whyHi}',
          'Cycle mein kab: ${t.whenHi}',
          'India mein cost: ${t.costHi}',
          'Result kaise padhein: ${t.readingHi}',
        ]),
        keywords: [t.forHim ? 'for him' : 'for her'],
      );
    }

    // ---- can I…? (S4) — verdict up front ------------------------------------
    for (final c in ttcCanI) {
      add(
        docId: 'ttccani_${c.id}',
        kind: 'ttccani',
        sourceLabel: 'Can I…?',
        titleEn: c.questionEn,
        titleHi: c.questionHi,
        bodyEn: join([
          'Verdict: ${c.verdict.name}. ${c.shortEn}',
          c.whyEn,
          c.indianEn,
        ]),
        bodyHi: join([
          'Verdict: ${c.verdict.name}. ${c.shortHi}',
          c.whyHi,
          c.indianHi,
        ]),
      );
    }

    // ---- products (S6) — lookFor AND watchOut, equal weight -----------------
    for (final p in ttcProducts) {
      add(
        docId: 'ttcprod_${p.id}',
        kind: 'product',
        sourceLabel: 'Products',
        titleEn: p.nameEn,
        titleHi: p.nameHi,
        bodyEn: join([
          p.whyEn,
          'What to look for: ${p.lookForEn}',
          // The honesty half — never drop this.
          'What to watch out for: ${p.watchOutEn}',
          'Typical price: ${p.priceEn}',
        ]),
        bodyHi: join([
          p.whyHi,
          'Kya dekhna hai: ${p.lookForHi}',
          'Kis cheez se bachna hai: ${p.watchOutHi}',
          'Price: ${p.priceEn}',
        ]),
        keywords: [p.category],
      );
    }

    // ---- partner missions + briefs (S4) ------------------------------------
    for (final m in ttcMissions) {
      add(
        docId: 'ttcmission_${m.id}',
        kind: 'ttcmission',
        sourceLabel: 'For your partner',
        titleEn: m.titleEn,
        titleHi: m.titleHi,
        bodyEn: m.bodyEn,
        bodyHi: m.bodyHi,
      );
    }
    for (final entry in ttcPartnerBriefs.entries) {
      final b = entry.value;
      add(
        docId: 'ttcbrief_${entry.key.name}',
        kind: 'ttcmission',
        sourceLabel: 'For your partner',
        titleEn: 'Supporting her: ${entry.key.name}',
        titleHi: 'Uska saath dena: ${entry.key.name}',
        bodyEn: join([
          'She may feel: ${b.sheMayFeelEn}',
          'You can: ${b.youCanEn}',
          'Your body too: ${b.yourBodyEn}',
        ]),
        bodyHi: join([
          'Woh kaisa feel kar sakti hai: ${b.sheMayFeelHi}',
          'Tum kya kar sakte ho: ${b.youCanHi}',
          'Tumhari body bhi: ${b.yourBodyHi}',
        ]),
      );
    }

    // ---- offerings (S7 services) — real bookable ids ------------------------
    for (final o in ttcOfferings) {
      add(
        docId: 'ttcoffer_${o.id}',
        kind: 'service',
        sourceLabel: 'Services',
        titleEn: o.titleEn,
        titleHi: o.titleHi,
        bodyEn: join([o.bodyEn, 'Format: ${o.kind}, ${o.sessions} session(s).']),
        bodyHi: join([o.bodyHi, 'Format: ${o.kind}, ${o.sessions} session(s).']),
        keywords: [o.category, o.kind],
      );
    }

    // ---- trackers: the "why this exists" copy (S4) --------------------------
    for (final tr in ttcTrackers) {
      add(
        docId: 'ttctracker_${tr.id}',
        kind: 'ttctracker',
        sourceLabel: 'Trackers',
        titleEn: tr.titleEn,
        titleHi: tr.titleHi,
        bodyEn: join([tr.subtitleEn, tr.whyEn, tr.disclaimerEn ?? '']),
        bodyHi: join([tr.subtitleHi, tr.whyHi, tr.disclaimerHi ?? '']),
      );
    }

    // ---- nutrition + movement (S4) ------------------------------------------
    for (final n in ttcNutrition) {
      add(
        docId: 'ttcnutrition_${n.id}',
        kind: 'ttcnutrition',
        sourceLabel: 'Nutrition',
        titleEn: n.nutrientEn,
        titleHi: n.nutrientHi,
        bodyEn: join([n.whyEn, 'In a meal: ${n.mealEn}', n.indianEn]),
        bodyHi: join([n.whyHi, 'Khane mein: ${n.mealHi}', n.indianHi]),
      );
    }
    for (final m in ttcMovements) {
      add(
        docId: 'ttcmovement_${m.id}',
        kind: 'ttcmovement',
        sourceLabel: 'Movement',
        titleEn: m.titleEn,
        titleHi: m.titleHi,
        bodyEn: join([m.bodyEn, '${m.minutes} minutes.']),
        bodyHi: join([m.bodyHi, '${m.minutes} minutes.']),
        keywords: [m.kind],
      );
    }

    final f = File('build/ttc_corpus.json');
    f.parent.createSync(recursive: true);
    f.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(out));

    final byKind = <String, int>{};
    for (final m in out) {
      byKind[m['kind'] as String] = (byKind[m['kind'] as String] ?? 0) + 1;
    }
    // ignore: avoid_print
    print('\nEXPORTED ${out.length} TTC docs (En + Hinglish) -> build/ttc_corpus.json');
    if (skipped.isNotEmpty) {
      // ignore: avoid_print
      print('SKIPPED (editor-owned, served from Supabase): $skipped');
    }
    final kinds = byKind.keys.toList()..sort();
    for (final k in kinds) {
      // ignore: avoid_print
      print('   ${k.padRight(16)} ${byKind[k]}');
    }

    expect(out, isNotEmpty);
  });
}
