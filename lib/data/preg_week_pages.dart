// =============================================================================
//  Pregnancy week pages — the full week-wise content docs (2026-10-13)
// -----------------------------------------------------------------------------
//  The user's prepared "Week Page Content" docs, one per week, drawn by the
//  week Details page (`PregWeekScreen` → `PregWeekDocBody`). A week with a
//  page here shows it; a week without one keeps the older weekContent.json
//  body. Weeks covered so far: 5–18 and 20–23 (week 19 and 24–40 owed,
//  docs/STILL-OPEN.md).
//
//  ⚠️ THE WEEK FILES ARE GENERATED. `lib/data/preg_week_pages/week_NN.dart`
//  and `index.dart` are written by `tools/week_pages/docx_to_dart.py` from
//  the docx files, word for word. Fix a sentence in the doc and re-run the
//  script; a hand edit in a week file is lost on the next run.
//
//  Why generated Dart rather than a JSON asset read at runtime: the page is
//  opened every week, so it should not wait on an async load; the compiler
//  checks every field; and tests can scan the source for leaked spec notes.
//  The price is one command per content drop.
//
//  The shape is the docs' own: Opening snapshot · About your baby · Baby
//  science · You this week · Symptoms · Diet · (Trimester tips, week 5) ·
//  Share with partner. English only (CLAUDE.md, 2026-08-27). The docs carry
//  "Symptom cards require medical review" — shipped with the doctor footer
//  on the user's word (2026-10-13), review owed in STILL-OPEN.
// =============================================================================

import 'preg_week_pages/index.dart';
export 'preg_week_pages/index.dart' show kPregWeekPageList;

/// A heading and a paragraph: the expanded "About your baby" page and the
/// opening blocks of "You this week".
class PregWeekProse {
  const PregWeekProse(this.heading, this.body);
  final String heading;
  final String body;
}

/// A title and one paragraph: behavioural highlights (drawn inline) and
/// Baby Science (a row that opens a Got-it sheet).
class PregWeekCard {
  const PregWeekCard(this.title, this.body);
  final String title;
  final String body;
}

/// A "You this week" highlight: a row with a teaser that opens a card.
class PregWeekHighlight {
  const PregWeekHighlight(this.title, this.teaser, this.body);
  final String title;
  final String teaser;
  final String body;
}

/// A symptom card: the row, and the four parts its sheet shows.
class PregWeekSymptom {
  const PregWeekSymptom({
    required this.name,
    required this.teaser,
    required this.howCommon,
    required this.why,
    required this.helps,
    required this.whenToCall,
  });
  final String name;
  final String teaser;
  final String howCommon;
  final String why;
  final List<String> helps;
  final String whenToCall;
}

/// The Indian superfood of the week.
class PregWeekSuperfood {
  const PregWeekSuperfood({
    required this.food,
    required this.benefit,
    required this.tryAs,
    this.note = '',
  });
  final String food;
  final String benefit;

  /// "ragi porridge, ragi dosa or roti" — the doc's "Try it as:" without the label.
  final String tryAs;

  /// The closing line under it (why now, or a caution). May be empty.
  final String note;
}

/// A food to favour or avoid, with its reason.
class PregWeekFood {
  const PregWeekFood(this.name, this.reason);
  final String name;
  final String reason;
}

/// A trimester tip: one line, and the card behind "Read more".
class PregWeekTip {
  const PregWeekTip(this.tip, this.more);
  final String tip;
  final String more;
}

/// One week's page.
class PregWeekPage {
  const PregWeekPage({
    required this.week,
    required this.fruit,
    required this.length,
    required this.weight,
    required this.teaser,
    required this.about,
    this.behaviour = const [],
    required this.science,
    required this.you,
    required this.highlights,
    required this.selfCare,
    required this.reminder,
    required this.symptoms,
    required this.symptomsFooter,
    required this.superfood,
    required this.favour,
    required this.avoid,
    this.tipsTitle = '',
    this.tips = const [],
    required this.partnerNote,
    required this.partnerHowMom,
    required this.partnerScans,
    required this.partnerHelp,
  });

  final int week;

  /// The doc's size comparison, as written: "Raspberry".
  final String fruit;

  /// "1.3 to 1.6 cm".
  final String length;

  /// "About 1 g".
  final String weight;

  /// The cover teaser, in the baby's voice.
  final String teaser;

  /// The expanded page: opening, how big, what's happening (or the week's own
  /// headings, as week 20 has).
  final List<PregWeekProse> about;

  /// Behavioural highlights, drawn inline. Empty before the baby moves.
  final List<PregWeekCard> behaviour;

  final List<PregWeekCard> science;

  /// How you might be feeling · your changing body · be kind to yourself, and
  /// any block a week adds (week 20: "The first flutters").
  final List<PregWeekProse> you;

  final List<PregWeekHighlight> highlights;
  final String selfCare;

  /// "A gentle reminder" — when to call the doctor.
  final String reminder;

  final List<PregWeekSymptom> symptoms;

  /// The doctor line under the symptoms. Per week, not a constant: from week
  /// 21 it adds leaking fluid and reduced movements.
  final String symptomsFooter;

  final PregWeekSuperfood superfood;
  final List<PregWeekFood> favour;
  final List<PregWeekFood> avoid;

  /// "Trimester 1 (Weeks 1–13)", when the week carries tips.
  final String tipsTitle;
  final List<PregWeekTip> tips;

  final String partnerNote;
  final String partnerHowMom;
  final List<String> partnerScans;
  final List<String> partnerHelp;
}

/// Every week that has a page, by week.
final Map<int, PregWeekPage> kPregWeekPages = {
  for (final p in kPregWeekPageList) p.week: p,
};

/// The page for [week], or null when no doc covers it yet.
PregWeekPage? pregWeekPageFor(int week) => kPregWeekPages[week];

/// The fixed lines the docs repeat every week (one copy here, not 18).
const String kPregWeekScienceFooter =
    'This is for understanding, not diagnosis – your doctor is always the best guide.';
const String kPregWeekSymptomsIntro =
    'Common, normal things you may notice now – tap any to understand it and what helps.';
