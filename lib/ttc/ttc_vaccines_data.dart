// =============================================================================
//  TTC — the preconception vaccination list
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS A SURFACE, NOT A PARAGRAPH, AND THAT IS THE WHOLE POINT.
//
//  The audit found that a grep for `rubella`, `MMR` or `vaccin` across the
//  entire TTC stage returned nothing, while the workbook names vaccinations
//  explicitly in the Getting Ready bracket's Content cell. The first fix was to
//  write it into an article — which was better than nothing and still wrong,
//  because of what makes this topic different from every other one in the
//  stage:
//
//  **It has a deadline, and it has a state.**
//
//  Rubella and varicella are LIVE vaccines. If she is not immune she needs the
//  jab AND a month of not conceiving afterwards. That is not a fact to read
//  once; it is a small piece of admin with a status — do I know? have I been
//  tested? am I immune? have I had it? when can we start? Prose cannot hold
//  that, and a woman who reads it in March and starts trying in April has to
//  remember all of it unaided.
//
//  So the vaccines are data, she can record where she stands on each, and the
//  screen computes the one thing she actually wants to know: is there anything
//  here that means waiting.
//
//  ---------------------------------------------------------------------------
//  ⚠️ INDIA, NOT A TRANSLATED WESTERN LIST
//  ---------------------------------------------------------------------------
//
//  Every entry carries [inUip], and it is false for all but one of them. The
//  Universal Immunization Programme gives Td at ten and sixteen and tetanus
//  cover in pregnancy — adult MMR, varicella, Tdap, influenza and hepatitis B
//  are all outside it. In practice that means private cost, and it means
//  nobody raises them unless she does. A vaccination list that does not say so
//  is describing another country's health system.
//
//  The TT/Tdap confusion has its own entry note for the same reason: most
//  Indian women have had TT and reasonably believe they are covered.
//
//  ⚠️ NEVER A DIAGNOSIS, AND NEVER A SCHEDULE OF ITS OWN. This screen records
//  what she tells it and explains what is usually advised. Which vaccine she
//  needs, and when, is her doctor's — see `TimingOwnership`. The status she
//  sets is her own note to herself, not a clinical record.
//
//  ENGLISH FIRST — `_en(...)`, so `grep -c '_en('` is the Hindi backlog.
// =============================================================================

import '../localization/app_language.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// Where she stands on one vaccine. Persisted by NAME, never by index.
enum TtcVaccineStatus {
  /// Default. Nothing recorded — she has not looked into it.
  unknown,

  /// A test or record says she is already protected. Nothing to do.
  immune,

  /// Tested or asked, and she needs it. This is the state that can start a
  /// wait, and the screen surfaces it above everything else.
  needed,

  /// Had it. For a live vaccine this is what starts the month.
  done,

  /// Genuinely does not apply — her doctor said so, or the risk factor is
  /// absent. Distinct from `immune`, because the reasons differ and she may
  /// want to remember which.
  notApplicable,
}

/// Where a vaccine sits in HER sequence, not in our taxonomy.
///
/// ⚠️ ADDED AFTER THE FIRST BUILD RENDERED A FLAT LIST OF SIX WITH A STATUS
/// CONTROL ON EACH — which was a form she cannot fill in. She arrives knowing
/// nothing about her own immunity, so every control was asking a question she
/// has no answer to until a blood test comes back.
///
/// Grouping by what she can DO RIGHT NOW fixes it: one group needs a test
/// before anything can be decided, one is simply information for later, and one
/// she almost certainly already has. Only the first group ever asks her for
/// anything.
enum TtcVaccineTrack {
  /// Needs a blood test now, and can delay trying. The only group that is
  /// urgent, and the only one that is interactive.
  beforeTrying,

  /// Nothing to decide today — given during pregnancy, months away. Worth
  /// knowing exists so it can be asked for at the right time.
  inPregnancy,

  /// Almost certainly already covered by the public programme. Present for
  /// completeness, never as a task.
  background,
}

/// One vaccine on the preconception list.
class TtcVaccine {
  const TtcVaccine({
    required this.id,
    required this.name,
    required this.protectsAgainst,
    required this.why,
    required this.howChecked,
    required this.schedule,
    required this.track,
    this.isLive = false,
    this.waitDays = 0,
    this.inUip = false,
    this.conditional,
    this.note,
  });

  final String id;
  final LocalizedText name;

  /// The one-line "what this is for".
  final LocalizedText protectsAgainst;

  /// Why it matters in THIS stage specifically — the pregnancy consequence.
  final LocalizedText why;

  /// How she finds out whether she needs it. Names the test where there is
  /// one, because "a blood test" is not something she can ask for.
  final LocalizedText howChecked;

  /// Doses and timing, in plain words.
  final LocalizedText schedule;

  /// Which of her three groups this belongs to. See [TtcVaccineTrack].
  final TtcVaccineTrack track;

  /// ⚠️ THE FIELD THE WHOLE SCREEN TURNS ON. A live vaccine cannot be given in
  /// pregnancy and carries a wait afterwards.
  final bool isLive;

  /// Days to avoid conceiving after the dose. Zero for inactivated vaccines.
  final int waitDays;

  /// Whether India's Universal Immunization Programme covers it for an adult
  /// woman. False for almost everything here — see the header.
  final bool inUip;

  /// Set where the vaccine is advised only in defined circumstances, e.g.
  /// hepatitis B. Null means it applies generally.
  final LocalizedText? conditional;

  /// The India-specific thing worth knowing, where there is one.
  final LocalizedText? note;
}

/// The list, ordered by how much a delay would cost her — live vaccines first,
/// because they are the only ones that can push a plan back by a month.
final List<TtcVaccine> kTtcVaccines = [
  TtcVaccine(
    id: 'mmr',
    track: TtcVaccineTrack.beforeTrying,
    name: _en('MMR'),
    protectsAgainst: _en('Measles, mumps and rubella'),
    why: _en('Rubella caught in early pregnancy can seriously harm a baby. '
        'This is called congenital rubella syndrome. It\'s the most important '
        'item on this list, and the one most often found out too late.'),
    howChecked: _en('A rubella IgG blood test. Ask for it by name. It doesn\'t '
        'cost much, and most labs do it.'),
    schedule: _en('One dose if you\'re not immune. MMR is better than a '
        'rubella-only or MR vaccine, because it covers measles and mumps too.'),
    isLive: true,
    waitDays: 28,
    note: _en('Most Indian women were vaccinated as children, but very few '
        'still have the record. What counts is being immune, not the card. And '
        'a small number of people vaccinated as children aren\'t immune as '
        'adults. The test settles it either way.'),
  ),

  TtcVaccine(
    id: 'varicella',
    track: TtcVaccineTrack.beforeTrying,
    name: _en('Varicella'),
    protectsAgainst: _en('Chickenpox'),
    why: _en('Chickenpox in pregnancy can be serious for both mother and '
        'baby. More women aren\'t immune than you might expect.'),
    howChecked: _en('A varicella IgG blood test. A clear memory of having had '
        'chickenpox as a child is also a fair guide.'),
    schedule: _en('Two doses, four weeks apart, if you\'ve never had '
        'chickenpox and never been vaccinated.'),
    isLive: true,
    waitDays: 28,
    note: _en('Two doses four weeks apart, plus a month afterwards, is about '
        'two months from starting to being clear to try. That\'s the longest '
        'wait on this page, and the reason to check early, not late.'),
  ),

  TtcVaccine(
    id: 'tdap',
    track: TtcVaccineTrack.inPregnancy,
    name: _en('Tdap'),
    protectsAgainst: _en('Tetanus, diphtheria and whooping cough'),
    why: _en('Antibodies cross the placenta and protect the baby from '
        'whooping cough in the first months, before the baby can be '
        'vaccinated. TT and Td don\'t do this.'),
    howChecked: _en('No test needed. It\'s given during pregnancy, not '
        'before, so it\'s one to know about now and ask for later.'),
    schedule: _en('One dose in each pregnancy, between 27 and 36 weeks. FOGSI '
        'has recommended it since 2014.'),
    note: _en('This is the most common mix-up in India. Two doses of TT '
        'don\'t cover whooping cough, and you can still have Tdap after them. '
        'It\'s a different vaccine doing a different job, not a double dose '
        'to worry about.'),
  ),

  TtcVaccine(
    id: 'influenza',
    track: TtcVaccineTrack.inPregnancy,
    name: _en('Influenza'),
    protectsAgainst: _en('Seasonal flu'),
    why: _en('Flu tends to hit harder in pregnancy, and the vaccine passes '
        'some protection to the baby too.'),
    howChecked: _en('No test. One dose a year, whenever this season’s '
        'vaccine is available.'),
    schedule: _en('Once a year. Safe before and during pregnancy. It\'s an '
        'inactivated vaccine (not live), so there\'s no waiting period.'),
    note: _en('In India it isn\'t available all year round, so it\'s worth '
        'asking for it instead of waiting to be offered.'),
  ),

  TtcVaccine(
    id: 'hepb',
    track: TtcVaccineTrack.beforeTrying,
    name: _en('Hepatitis B'),
    protectsAgainst: _en('Hepatitis B'),
    why: _en('It can pass to the baby at birth, and getting vaccinated '
        'beforehand prevents that.'),
    howChecked: _en('A hepatitis B surface antigen test. It\'s usually part of '
        'the pregnancy blood tests anyway, and it\'s better done before.'),
    schedule: _en('Three doses over six months, where it\'s advised.'),
    conditional: _en('Advised where there\'s a risk, not for everyone: working '
        'in healthcare, living with someone who has it, dialysis, or a '
        'partner who is positive.'),
  ),

  TtcVaccine(
    id: 'td',
    track: TtcVaccineTrack.background,
    name: _en('Td'),
    protectsAgainst: _en('Tetanus and diphtheria'),
    why: _en('The basic tetanus protection most Indian adults already '
        'have. It\'s the one thing on this list the public programme does '
        'cover.'),
    howChecked: _en('No test. Check when you last had a vaccine with tetanus '
        'in it. The government schedule (UIP) gives it at ten and sixteen.'),
    schedule: _en('A booster if it\'s been more than ten years, unless you\'re '
        'having Tdap instead.'),
    inUip: true,
  ),
];

TtcVaccine? ttcVaccineById(String id) {
  for (final v in kTtcVaccines) {
    if (v.id == id) return v;
  }
  return null;
}

/// The live vaccines — the only ones that can delay trying.
List<TtcVaccine> get ttcLiveVaccines =>
    [for (final v in kTtcVaccines) if (v.isLive) v];

List<TtcVaccine> ttcVaccinesOn(TtcVaccineTrack track) =>
    [for (final v in kTtcVaccines) if (v.track == track) v];

/// The exact words to ask for at a lab or an appointment.
///
/// ⚠️ THE MOST USEFUL SINGLE THING ON THE WHOLE SURFACE. Everything else is
/// downstream of one blood test, and "ask about your immunity" is not something
/// anyone can act on. A test has a name, and being able to say the name is the
/// difference between a plan and an intention.
const List<String> kTtcVaccineAsks = [
  'Rubella IgG',
  'Varicella IgG (only if you never had chickenpox)',
  'Hepatitis B surface antigen (usually in the routine tests anyway)',
];
