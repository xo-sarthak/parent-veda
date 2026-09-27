// =============================================================================
//  PCOS Symptom Checker — THE RULES LAYER
// -----------------------------------------------------------------------------
//  ⚠️ EVERY MEDICAL THRESHOLD IN THIS FEATURE IS IN THIS FILE, ON PURPOSE.
//
//  This is the file a clinician reviews. It contains no widgets, no navigation
//  and no persistence, so it can be read by someone who does not read Flutter.
//  If a rule below is wrong, it is wrong HERE and nowhere else — and if anyone
//  ever finds an interpretation rule inside a `build()` method, that is a
//  defect regardless of whether the rule itself is correct.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THIS IS NOT A SYMPTOM COUNT
//  ---------------------------------------------------------------------------
//
//  "7 out of 10 means PCOS" is the obvious implementation and it is medically
//  indefensible. PCOS is diagnosed on TWO OF THREE findings — irregular
//  ovulation, raised androgens, and the scan picture — and a count treats a
//  woman with four mild skin complaints and perfect cycles as more concerning
//  than a woman who has not had a period in five months. That is backwards.
//
//  So this engine reads DOMAINS, and the shape of the rule mirrors the
//  diagnostic logic rather than the questionnaire:
//
//    · Three PRIMARY domains: cycle · ovulation · androgen.
//    · A pattern worth discussing needs TWO of the three at moderate or above.
//      One domain alone, however loud, is not a pattern.
//    · Fertility context is a MODIFIER. It can raise urgency and can never
//      create a pattern by itself — someone trying for two years with regular
//      cycles and no other signs does not have a PCOS pattern, she has a
//      different question.
//    · Medical context is a CONFOUNDER. It CAPS the reading. On hormonal
//      contraception the cycle answers describe a withdrawal bleed rather than
//      an ovulatory cycle, so they cannot support a conclusion at all.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE FOUR THINGS THIS ENGINE MAY NEVER PRODUCE
//  ---------------------------------------------------------------------------
//
//    1. A diagnosis, or "you probably have PCOS".
//    2. A number, percentage, score or risk meter of any kind. CLAUDE.md's
//       clinical invariants forbid a personalised probability, and a "PCOS
//       likelihood: 74%" is exactly that with a medical hat on.
//    3. A conclusion that a normal-looking result rules PCOS out.
//    4. Any reading at all when a safety answer has fired.
//
//  Held by `test/ttc_pcos_checker_test.dart`.
// =============================================================================

import '../localization/app_language.dart';
import 'ttc_pcos_check_data.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

// -----------------------------------------------------------------------------
//  Domain readings
// -----------------------------------------------------------------------------

/// How loudly one domain is speaking. Deliberately three coarse steps rather
/// than a number — the precision a score implies is precision this data does
/// not have.
enum PcosStrength { quiet, some, marked }

/// What the engine concluded about one domain, plus how much of it she could
/// actually answer.
class PcosPattern {
  const PcosPattern({
    required this.domain,
    required this.strength,
    required this.unknowns,
    required this.answered,
  });

  final PcosDomain domain;
  final PcosStrength strength;

  /// How many questions in this domain she answered "not sure" or "I don't
  /// track it". Drives the confidence line, never the level.
  final int unknowns;

  final int answered;

  bool get isThin => answered > 0 && unknowns >= answered - unknowns;
}

/// The four bands, exactly as specified in the brief.
enum PcosLevel {
  /// No strong pattern in what she reported. NEVER "PCOS ruled out".
  none,

  /// Something worth keeping an eye on.
  watch,

  /// A combination worth taking to a doctor.
  discuss,

  /// Worth going sooner rather than waiting for the cycle to settle.
  soon,
}

/// Why the check stopped, when it did.
enum PcosStop {
  /// Nothing stopped it.
  none,

  /// Possible pregnancy. The cycle answers cannot be read as a pattern.
  pregnancy,

  /// A symptom that needs care rather than a questionnaire.
  urgent,
}

class PcosInterpretation {
  const PcosInterpretation({
    required this.level,
    required this.stop,
    required this.patterns,
    required this.cappedByContext,
    required this.headline,
    required this.body,
    required this.confidenceNote,
  });

  final PcosLevel level;
  final PcosStop stop;
  final List<PcosPattern> patterns;

  /// True when contraception or a recent birth means the cycle answers cannot
  /// carry a conclusion. The result says so plainly rather than quietly
  /// returning "no pattern", which would read as reassurance she has not
  /// earned and cannot rely on.
  final bool cappedByContext;

  final LocalizedText headline;
  final LocalizedText body;

  /// Present when she could not answer much. Never suppresses the result.
  final LocalizedText? confidenceNote;

  PcosPattern patternFor(PcosDomain d) =>
      patterns.firstWhere((p) => p.domain == d,
          orElse: () => PcosPattern(
              domain: d,
              strength: PcosStrength.quiet,
              unknowns: 0,
              answered: 0));

  bool get stopped => stop != PcosStop.none;
}

// -----------------------------------------------------------------------------
//  THE THRESHOLDS
// -----------------------------------------------------------------------------
//  ⚠️ THE NUMBERS A REVIEWER WOULD WANT TO ARGUE WITH, ALL IN ONE PLACE.

/// Domain total at or above which a domain counts as "some".
const int kPcosSomeAt = 2;

/// Domain total at or above which a domain counts as "marked".
const int kPcosMarkedAt = 4;

/// How many PRIMARY domains must reach `some` before anything is called a
/// pattern worth discussing. Two of three — mirroring the diagnostic rule.
const int kPcosPrimaryDomainsForDiscuss = 2;

/// A single primary domain at `marked` PLUS fertility pressure escalates to
/// `soon`. This is the "she has not had a period in five months and has been
/// trying a year" case, which a two-domain rule would otherwise under-call.
const int kPcosFertilityPressureAt = 2;

const List<PcosDomain> kPcosPrimaryDomains = [
  PcosDomain.cycle,
  PcosDomain.ovulation,
  PcosDomain.androgen,
];

// -----------------------------------------------------------------------------
//  The engine
// -----------------------------------------------------------------------------

PcosInterpretation interpretPcos(Map<String, String> answers) {
  // ---- 1. SAFETY FIRST, AND IT ENDS THE FUNCTION ---------------------------
  //
  // ⚠️ NO PATTERN IS COMPUTED WHEN A SAFETY ANSWER FIRES. Not computed and
  // hidden — not computed at all. A woman with sudden one-sided pain must not
  // have a PCOS reading sitting behind a warning screen for her to scroll to.
  final redflag = answers['q_redflag'];
  if (redflag != null && redflag != 'none') {
    return PcosInterpretation(
      level: PcosLevel.none,
      stop: PcosStop.urgent,
      patterns: const [],
      cappedByContext: false,
      headline: _en('This needs a doctor, not a check'),
      body: _en("What you've described isn't something a questionnaire should "
          'try to read. Please contact your doctor, or seek urgent care if the '
          "pain or bleeding is severe. We haven't worked out a pattern, "
          'because this comes first.'),
      confidenceNote: null,
    );
  }

  final pregnancy = answers['q_pregnancy'];
  if (pregnancy == 'maybe' || pregnancy == 'unsure') {
    return PcosInterpretation(
      level: PcosLevel.none,
      stop: PcosStop.pregnancy,
      patterns: const [],
      cappedByContext: false,
      headline: _en('Worth ruling this out first'),
      body: _en('A late or missed period has one very common cause. Until '
          "that's settled, a cycle pattern can't be read as anything else. A "
          'home pregnancy test is accurate from the day your period is due. If '
          "it's negative and your period still doesn't come, this check will "
          'be here.'),
      confidenceNote: null,
    );
  }

  // ---- 2. DOMAIN TOTALS ----------------------------------------------------
  final totals = <PcosDomain, int>{};
  final unknowns = <PcosDomain, int>{};
  final answered = <PcosDomain, int>{};

  for (final q in kPcosQuestions) {
    // recordOnly is never scored — see the notes on weight and bleeding
    // duration in the content file.
    if (q.domain == PcosDomain.recordOnly || q.domain == PcosDomain.safety) {
      continue;
    }
    final chosen = answers[q.id];
    if (chosen == null) continue;
    final opt = q.options.where((o) => o.id == chosen);
    if (opt.isEmpty) continue;

    answered[q.domain] = (answered[q.domain] ?? 0) + 1;
    if (opt.first.unknown) {
      unknowns[q.domain] = (unknowns[q.domain] ?? 0) + 1;
    }
    totals[q.domain] = (totals[q.domain] ?? 0) + opt.first.weight;
  }

  PcosStrength strengthOf(PcosDomain d) {
    final t = totals[d] ?? 0;
    if (t >= kPcosMarkedAt) return PcosStrength.marked;
    if (t >= kPcosSomeAt) return PcosStrength.some;
    return PcosStrength.quiet;
  }

  final patterns = [
    for (final d in [...kPcosPrimaryDomains, PcosDomain.fertility])
      PcosPattern(
        domain: d,
        strength: strengthOf(d),
        unknowns: unknowns[d] ?? 0,
        answered: answered[d] ?? 0,
      ),
  ];

  // ---- 3. THE CONFOUNDER CAP ----------------------------------------------
  //
  // ⚠️ THIS RUNS BEFORE THE LEVEL IS DECIDED, NOT AFTER.
  //
  // On hormonal contraception the "periods" are withdrawal bleeds on a
  // schedule the pill sets. They are regular BY CONSTRUCTION, which means the
  // cycle domain would read quiet and the tool would hand back reassurance
  // that describes the medication rather than her. That is the most dangerous
  // false negative this feature could produce, so it is refused outright.
  final contraception = answers['q_contraception'];
  final postpartum = answers['q_postpartum'];
  final capped = contraception == 'yes' ||
      contraception == 'stopped' ||
      postpartum == 'yes';

  // ---- 4. LEVEL ------------------------------------------------------------
  final primaryAtSome = kPcosPrimaryDomains
      .where((d) => strengthOf(d) != PcosStrength.quiet)
      .length;
  final anyPrimaryMarked =
      kPcosPrimaryDomains.any((d) => strengthOf(d) == PcosStrength.marked);
  final fertilityPressure =
      (totals[PcosDomain.fertility] ?? 0) >= kPcosFertilityPressureAt;

  // A doctor has already said one of the two things that outrank everything
  // here. Nothing a questionnaire computes should sit above that.
  final told = answers['q_eval_result'];
  final alreadyTold =
      told == 'pcos' || told == 'anovulation' || answers['q_told_anov'] == 'yes';

  PcosLevel level;
  if (alreadyTold) {
    level = PcosLevel.soon;
  } else if (anyPrimaryMarked &&
      (fertilityPressure || strengthOf(PcosDomain.cycle) == PcosStrength.marked)) {
    level = PcosLevel.soon;
  } else if (primaryAtSome >= kPcosPrimaryDomainsForDiscuss) {
    level = PcosLevel.discuss;
  } else if (primaryAtSome >= 1) {
    level = PcosLevel.watch;
  } else {
    level = PcosLevel.none;
  }

  // ⚠️ THE CAP LOWERS A CONFIDENT READING AND NEVER RAISES A QUIET ONE. Being
  // on the pill is not evidence of anything; it is an absence of evidence. So
  // `discuss` and `soon` fall back to `watch` with the reason stated, and
  // `none` stays `none` — but the copy for a capped `none` says plainly that
  // it is not reassurance.
  if (capped && (level == PcosLevel.discuss || level == PcosLevel.soon)) {
    level = PcosLevel.watch;
  }

  // ---- 5. COPY -------------------------------------------------------------
  final totalUnknowns = unknowns.values.fold<int>(0, (a, b) => a + b);

  return PcosInterpretation(
    level: level,
    stop: PcosStop.none,
    patterns: patterns,
    cappedByContext: capped,
    headline: _headline(level, capped),
    body: _body(level, capped, strengthOf),
    confidenceNote: totalUnknowns >= 3
        ? _en('You answered "not sure" to a few of these, and that\'s '
            'completely normal. Most people have never been asked to watch for '
            'them. It means this reading is a rough sketch, not a full picture. '
            'Tracking a couple of cycles would make it clearer than answering '
            'again.')
        : null,
  );
}

LocalizedText _headline(PcosLevel level, bool capped) {
  if (capped) return _en('Your cycle is hard to read right now');
  return switch (level) {
    PcosLevel.none => _en('No strong pattern in what you told us'),
    PcosLevel.watch => _en('A few things worth keeping an eye on'),
    PcosLevel.discuss => _en('Worth talking to a doctor about'),
    PcosLevel.soon => _en('Worth seeing a doctor sooner rather than later'),
  };
}

LocalizedText _body(
    PcosLevel level, bool capped, PcosStrength Function(PcosDomain) strength) {
  if (capped) {
    return _en('Hormonal contraception controls when you bleed, instead of '
        'letting a cycle run on its own. A recent birth or breastfeeding also '
        'changes cycles, for completely normal reasons. Either way, what '
        "you've described cannot be read as a sign about ovulation, in either "
        "direction. That isn't the same as nothing being there. If you have "
        'other symptoms, or your cycles were irregular before, those are still '
        'worth raising.');
  }

  return switch (level) {
    PcosLevel.none => _en("From what you've entered, your answers don't show "
        'the kind of pattern often linked with PCOS. That is not the same as '
        'ruling it out. This describes what you told us. It is not a test. If '
        "you're finding it hard to conceive, many things other than PCOS can "
        "be involved, and that's worth a conversation of its own."),
    PcosLevel.watch => _en('One part of what you described is worth noticing: '
        "a cycle that isn't always regular, or a symptom that can go with "
        "hormone changes. On its own it doesn't make a pattern. Things like "
        'this are common and often mean nothing. A couple of tracked cycles '
        'would tell you far more than another questionnaire.'),
    PcosLevel.discuss => _en('More than one part of what you described can '
        "happen together in PCOS or with irregular ovulation. This doesn't "
        'diagnose anything. The same mix has other causes too, including '
        'thyroid problems and raised prolactin (a hormone), and a simple blood '
        'test rules out both. What it does mean is that there is something '
        'specific to take to a doctor, not just a vague worry.'),
    PcosLevel.soon => _en('What you described suggests your cycle may not be '
        "finishing on a regular schedule. That's worth raising now, instead "
        'of waiting for it to settle. The usual advice to try for a year first '
        "assumes regular ovulation. If yours isn't regular, that advice "
        "doesn't fit you, and you don't need to wait the full year. Irregular "
        'ovulation is also one of the most treatable things in fertility '
        'care, and that is the more useful half of this.'),
  };
}

// -----------------------------------------------------------------------------
//  Personalised paragraphs
// -----------------------------------------------------------------------------

/// The extra lines the brief asks for, chosen by which domains actually spoke.
List<LocalizedText> pcosDetailLines(PcosInterpretation r) {
  if (r.stopped) return const [];
  final cycle = r.patternFor(PcosDomain.cycle).strength != PcosStrength.quiet;
  final andro = r.patternFor(PcosDomain.androgen).strength != PcosStrength.quiet;
  final ovul = r.patternFor(PcosDomain.ovulation).strength != PcosStrength.quiet;

  final out = <LocalizedText>[];
  if (cycle) {
    out.add(_en('Your cycle pattern is the most useful thing to describe to '
        'a doctor. Irregular or missing periods can mean ovulation '
        "isn't happening on a regular schedule."));
  }
  if (ovul && !cycle) {
    out.add(_en('The ovulation signs you described are worth mentioning. Not '
        "noticing them doesn't prove anything on its own, but strips that give "
        'unpredictable results do tell a doctor something.'));
  }
  if (andro) {
    out.add(_en('You also mentioned things like hair growth, acne or thinning '
        'hair. These can go with higher androgen levels (hormones like '
        'testosterone), and each one has other causes too.'));
  }
  if (cycle && andro) {
    out.add(_en('Together, those two are the mix worth raising. They help a '
        'doctor work out whether PCOS, another hormone cause, or something '
        'else is affecting ovulation.'));
  }
  // ---- THE EMPTY CASE IS NOT ONE CASE ---------------------------------------
  //
  // ⚠️ A BUG WORTH KEEPING THE EXPLANATION OF, because the shape of it recurs
  // anywhere a summary is derived from one input and a verdict from another.
  //
  // Three domains reading quiet used to produce a single fallback line: "if
  // your periods are regular and nothing else concerns you, that is genuinely
  // reassuring". That is true when the LEVEL is also quiet. It is false, and
  // badly so, when the level came from somewhere the domains cannot see.
  //
  // Two routes do exactly that. `alreadyTold` sets `soon` because a doctor has
  // said PCOS or anovulation — her own symptom answers may be entirely
  // unremarkable and the clinician's word still outranks them. Fertility
  // pressure does something similar. Both left a result reading, in order:
  //
  //     "your cycle may not be completing predictably ... worth raising now"
  //     "if your periods are regular ... that is genuinely reassuring"
  //
  // The two paragraphs came from different functions, each correct about its
  // own input, and neither could see the other. Nothing failed. It reached the
  // phone, and it reached exactly the woman who has already been given a
  // diagnosis — the one with the least room for a mixed message.
  //
  // The rule this leaves behind: a derived summary must branch on the SAME
  // verdict the headline branched on, or it is free to contradict it.
  if (out.isEmpty) {
    // The same trap once more, from the other direction. A capped reading is
    // forced down to `watch`, so a level-only branch would land on the
    // reassurance line — directly under a body paragraph that has just said
    // these answers cannot be read as evidence in either direction.
    if (r.cappedByContext) {
      out.add(_en('While the pill is controlling your bleed, or while things '
          "are still settling after a birth, a symptom questionnaire can't "
          'tell you much either way. A few cycles after that changes will say '
          'far more than answering this again.'));
      return out;
    }
    out.add(switch (r.level) {
      // Her answers were unremarkable but the verdict was not. Say why, rather
      // than reassuring her against it.
      PcosLevel.soon || PcosLevel.discuss => _en('Nothing in the symptoms you '
          'described stood out on its own. What moves this is what you\'ve '
          "already been told, or how long you've been trying, and that counts "
          "for more than a questionnaire. It's worth going in with the cycle "
          'history you have.'),
      // Quiet answers, quiet verdict, and the reassurance is earned.
      PcosLevel.watch || PcosLevel.none => _en('If your periods are regular '
          "and nothing else worries you, that's reassuring as far as it goes. "
          'Many things beyond PCOS can affect fertility, so if conceiving is '
          "taking a while, that's still worth a conversation of its own."),
    });
  }
  return out;
}

/// The disclaimer that appears on EVERY result, without exception.
final LocalizedText kPcosResultDisclaimer = _en(
    'This check helps you understand your symptoms and get ready to talk to '
    'a doctor. It cannot diagnose PCOS or anything else. A result either way '
    "doesn't confirm or rule anything out. A doctor can look at your symptoms "
    'and cycle history and, where needed, examine you and run tests.');
