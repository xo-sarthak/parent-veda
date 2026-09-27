// =============================================================================
//  TTC reads — the stage's long-form library
// -----------------------------------------------------------------------------
//  Written to `PvRead`. The model's head explains the reader; this file is the
//  content, and the rules it is written under are worth stating once because
//  every article added here has to keep them.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL RULES, WHICH DO NOT RELAX FOR PROSE
//  ---------------------------------------------------------------------------
//
//  · **Never a personalised probability.** No "your chance this month", no
//    computed success rate for her. Population figures are allowed, and only
//    where they REDUCE pressure rather than set a target — CLAUDE.md's exact
//    wording, and `test/ttc_clinical_review_test.dart` scans this source, not
//    just seed lists.
//  · **Never a diagnosis.** Every read carries `whenToSeeSomeone`, required on
//    the model so it cannot be the thing that got left off.
//  · **Never contradict her own clinician.** Where a doctor owns a decision we
//    explain it, remind about it, or help her prepare for it. We do not
//    recreate it. See `TimingOwnership` in `ttc_care_pathway.dart`.
//  · **Named sources, never "studies show".** `evidence` is required by the
//    shape test. An unsourced claim in a fertility article is indistinguishable
//    from the content this product exists to replace.
//
//  ⚠️ COSTS CARRY A DATE. A rupee figure with no year on it is worse than no
//  figure — she plans around it, and it silently rots. Every price range below
//  says when it was checked.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE ARTICLES THEMSELVES LIVE IN `reads/`, ONE FILE PER BRACKET
//  ---------------------------------------------------------------------------
//
//  This file is now the aggregator and the lookup, and the rules above still
//  govern every article in every one of those files — `assertShape` and
//  `ttc_clinical_review_test` both walk `kTtcReads`, so nothing escaped a gate
//  by moving.
//
//  Adding an article means opening the file for its bracket. Adding a BRACKET
//  means one import and one spread below, which is the whole point: five doors
//  can be built at once and they collide on one line rather than on 6,000.
//
//  ENGLISH FIRST — every string is `_en(...)`, so `grep -c '_en('` here is the
//  size of the Hindi backlog. Never `_t(x, x)`: an identical pair reads as
//  finished work to every audit, which is how `can_i_data` was once reported
//  done with 302 strings still English.
// =============================================================================

import '../localization/app_language.dart';
import '../models/pv_read.dart';
import 'reads/ttc_reads_conceiving.dart';
import 'reads/ttc_reads_pcos.dart';
import 'reads/ttc_reads_ivf.dart';
import 'reads/ttc_reads_getting_ready.dart';
import 'reads/ttc_reads_his_side.dart';
import 'reads/ttc_reads_after_loss.dart';
import 'reads/ttc_reads_mind_body.dart';
// TTC gap plan (2026-09-26): the new sections the gap analysis asked for.
import 'reads/ttc_reads_waiting.dart';
import 'reads/ttc_reads_hard_days.dart';
import 'reads/ttc_reads_meal_plan.dart';
import 'reads/ttc_reads_body_intimate.dart';
import 'reads/ttc_reads_sex.dart';
import 'reads/ttc_reads_loss_more.dart';
import 'reads/ttc_reads_body_cycle.dart';
import 'reads/ttc_reads_body_conditions.dart';
import 'reads/ttc_reads_extra.dart';
import 'reads/ttc_reads_age.dart';
import 'reads/ttc_reads_safety.dart';
import 'reads/ttc_reads_treatment.dart';

/// Every TTC read, in bracket order.
///
/// ⚠️ THE SPREADS ARE THE ONLY SHARED LINE IN THE LIBRARY. Everything else a
/// door build touches is its own file, which is what makes parallel work on
/// several brackets safe.
///
/// ⚠️ `final`, NOT `const`, AND IT CANNOT BE OTHERWISE. Every string in every
/// read goes through `_en(...)`, and a method call is not a constant
/// expression — so the per-bracket lists are `final` too. Worth knowing before
/// someone "tightens" one of them and gets 27 errors in a file they did not
/// open.
final List<PvRead> kTtcReads = [
  ...kTtcReadsConceiving,
  ...kTtcReadsPcos,
  ...kTtcReadsIvf,
  ...kTtcReadsGettingReady,
  ...kTtcReadsHisSide,
  ...kTtcReadsAfterLoss,
  ...kTtcReadsMindBody,
  // TTC gap plan, 2026-09-26.
  ...kTtcReadsWaiting,
  ...kTtcReadsHardDays,
  ...kTtcReadsMealPlan,
  ...kTtcReadsBodyIntimate,
  ...kTtcReadsSex,
  ...kTtcReadsLossMore,
  ...kTtcReadsBodyCycle,
  ...kTtcReadsBodyConditions,
  ...kTtcReadsExtra,
  ...kTtcReadsAge,
  ...kTtcReadsSafety,
  ...kTtcReadsTreatment,
];

/// Lookup by id. Null is a real answer — see `ttc_surface_router.dart`.
PvRead? ttcReadById(String id) {
  for (final r in kTtcReads) {
    if (r.id == id) return r;
  }
  return null;
}

/// Title for a read-next card, without handing the reader the whole library.
LocalizedText? ttcReadTitle(String id) => ttcReadById(id)?.title;

/// The TTC reads whose words best match a free-text question, best first.
///
/// Added 2026-09-26 so Ask Veda's "More information" can offer our own reads
/// instead of saying "coming soon" (TTC gap plan). Plain word overlap on the
/// title, teaser and headings: no service, works offline, and never invents a
/// read. Words under four letters are ignored so "can i eat" does not match
/// every read with "can" in it.
List<PvRead> ttcReadsMatching(String question, {int max = 3}) {
  final words = question
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9]+'))
      .where((w) => w.length >= 4)
      .toSet();
  if (words.isEmpty) return const [];
  final scored = <(int, PvRead)>[];
  for (final r in kTtcReads) {
    final title = r.title.en.toLowerCase();
    final rest = [r.teaser.en, ...r.toc.map((h) => h.en)].join(' ').toLowerCase();
    var score = 0;
    for (final w in words) {
      if (title.contains(w)) score += 3;
      if (rest.contains(w)) score += 1;
    }
    if (score >= 2) scored.add((score, r));
  }
  scored.sort((a, b) => b.$1.compareTo(a.$1));
  return [for (final e in scored.take(max)) e.$2];
}
