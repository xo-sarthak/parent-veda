// =============================================================================
//  TTC videos — declared now, filmed later
// -----------------------------------------------------------------------------
//  Every film this stage will hold, written to `PvVideoSlot`. See that model's
//  head
//  for why an unfilmed video is a full entry rather than a grey box: a
//  placeholder that occupies the real geometry is the only way to review the
//  SHAPE of a screen before the content exists, which is the whole reason for
//  building ahead of content.
//
//  ⚠️ `url` IS NULL ON EVERY ENTRY, AND THAT IS THE HONEST STATE. Null means
//  every surface renders the placeholder treatment and refuses the tap. When a
//  file lands it is one field, in one place, and every screen showing that video
//  updates at once — the article body, the related rail, the hub.
//
//  ⚠️ SELF-HOSTED ONLY WHEN THEY DO ARRIVE. YouTube was tested to exhaustion on
//  2026-07-12, is systemically blocked, and the code was removed. Supabase
//  Storage now, Bunny or Cloudflare later. Do not re-propose it.
//
//  ⚠️ THE CHAPTER LISTS AND TAKEAWAYS ARE REAL WORK, NOT LOREM. They are what
//  makes a video page useful on the day it ships rather than only on the day the
//  file arrives — someone deciding whether to spend six minutes reads the
//  chapter list, and it is writable long before anything is shot.
//
//  ENGLISH FIRST — every string is `_en(...)`, so `grep -c '_en('` over this
//  file is the size of the Hindi backlog. Never `_t(x, x)`; see CLAUDE.md.
// =============================================================================

import '../localization/app_language.dart';
import '../models/pv_video_slot.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// Hues match the bracket each film belongs to, so a video opened from a door
/// keeps the colour of the door. 288 = PCOS · 344 = fertile window ·
/// 206 = IVF & IUI · 104 = getting ready · 186 = his side · 26 = after a loss ·
/// 42 = mind & body.
final List<PvVideoSlot> kTtcVideos = [
  // ---------------------------------------------------------------------------
  //  PCOS — the highest-demand bracket in the stage
  // ---------------------------------------------------------------------------
  PvVideoSlot(
    id: 'ttc_vid_pcos_explained',
    hue: 288,
    title: _en('PCOS, explained in five minutes'),
    why: _en("What's going on in your ovaries, without the confusing "
        'diagrams.'),
    seconds: 312,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('What the name gets wrong')),
      PvVideoChapter(at: 48, label: _en('Insulin, and why it matters here')),
      PvVideoChapter(at: 132, label: _en('Why cycles get long, or stop')),
      PvVideoChapter(at: 205, label: _en('What helps it change')),
      PvVideoChapter(at: 268, label: _en('When to see someone')),
    ],
    takeaways: [
      _en("The cysts in the name aren't really cysts, and they aren't the "
          'problem. The hormone pattern is.'),
      _en('PCOS is the most common reason ovulation becomes irregular. '
          "Irregular doesn't mean it isn't happening."),
      _en("It's a pattern that can be managed. It doesn't rule out a "
          'pregnancy.'),
    ],
    readNext: ['ttc_read_pcos_cycle'],
    surfaceNext: ['ttc_cycle'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_pcos_treatment',
    hue: 288,
    title: _en('The PCOS treatments your doctor may offer'),
    why: _en('The order treatments are tried in, and what to ask before you '
        'agree to any of them.'),
    seconds: 402,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Why tablets don\'t come first')),
      PvVideoChapter(at: 78, label: _en('Letrozole, and what changed in 2023')),
      PvVideoChapter(at: 168, label: _en('Where metformin fits')),
      PvVideoChapter(at: 252, label: _en('Three questions for the first visit')),
      PvVideoChapter(at: 336, label: _en('What none of it does')),
    ],
    takeaways: [
      _en('Treatment starts with the gentlest thing that might work, and '
          'stops as soon as something does.'),
      _en('Letrozole is now the first tablet doctors prefer, ahead of '
          'clomiphene.'),
      _en("None of it cures PCOS. It helps ovulation get going again, which "
          'is why the first step keeps mattering all the way through.'),
    ],
    readNext: ['ttc_read_pcos_treatment'],
    surfaceNext: ['ttc_tests'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_pcos_plate',
    hue: 288,
    title: _en('What a PCOS-friendly Indian plate looks like'),
    why: _en("Roti, rice and dal aren't the problem. What you eat with them "
        'is what matters.'),
    seconds: 428,
    expert: _en('Akanksha Srivastava'),
    expertRole: _en('Maternal and child nutritionist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Why "cut carbs" is bad advice here')),
      PvVideoChapter(at: 72, label: _en('The order you eat things in')),
      PvVideoChapter(at: 168, label: _en('Protein, at an Indian breakfast')),
      PvVideoChapter(at: 262, label: _en('Three plates, made on camera')),
      PvVideoChapter(at: 372, label: _en('What isn\'t worth the bother')),
    ],
    takeaways: [
      _en('The aim is steadier blood sugar, not fewer calories.'),
      _en('Eating protein and fibre before the carbs keeps blood sugar '
          'steadier than cutting out the carbs does.'),
      _en('You don\'t have to give up any food group.'),
    ],
    readNext: ['ttc_read_pcos_food'],
    surfaceNext: ['ttc_nutrition'],
  ),

  // ---------------------------------------------------------------------------
  //  Conceiving & the fertile window
  // ---------------------------------------------------------------------------
  PvVideoSlot(
    id: 'ttc_vid_cycle_basics',
    hue: 344,
    title: _en('Your cycle, drawn out step by step'),
    why: _en('The two halves, why only one of them changes length, and when '
        'you ovulate in your own cycle.'),
    seconds: 384,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Two halves, not one cycle')),
      PvVideoChapter(at: 66, label: _en('The half that changes')),
      PvVideoChapter(at: 152, label: _en('Ovulation, in about a minute')),
      PvVideoChapter(at: 228, label: _en('The half that stays the same')),
      PvVideoChapter(
          at: 304, label: _en('Counting back, not forward')),
    ],
    takeaways: [
      _en('The first half of a cycle changes in length. The second half is '
          'about fourteen days for almost everyone.'),
      _en('So you find ovulation by counting back from your next period, not '
          'forward from your last one.'),
      _en('"Day 14" is only right if your cycle is 28 days.'),
    ],
    readNext: ['ttc_read_how_conception_works'],
    surfaceNext: ['ttc_cycle'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_timing_myths',
    hue: 344,
    title: _en('Six myths about timing, one by one'),
    why: _en('Positions, saving it up, lying still afterwards. What the '
        'evidence says about each.'),
    seconds: 366,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('"Only on the day you ovulate"')),
      PvVideoChapter(at: 62, label: _en('"Save it up for the fertile days"')),
      PvVideoChapter(at: 138, label: _en('"Lie still for twenty minutes"')),
      PvVideoChapter(at: 204, label: _en('"Position makes a difference"')),
      PvVideoChapter(at: 262, label: _en('"Stress is why it isn\'t working"')),
      PvVideoChapter(at: 318, label: _en('The one that is true')),
    ],
    takeaways: [
      _en('Your fertile window is about six days. The two days before '
          'ovulation matter more than the day itself.'),
      _en('Sex every other day through those days works better than aiming '
          'for one date.'),
      _en("Most of what you've been told to do afterwards does nothing."),
    ],
    readNext: ['ttc_read_timing_myths'],
    surfaceNext: ['ttc_window'],
  ),

  // ---------------------------------------------------------------------------
  //  Infertility & IVF
  // ---------------------------------------------------------------------------
  //  ⚠️ NEITHER OF THESE MAY CARRY A SUCCESS RATE, in the film or in the
  //  chapter list. `ttc_brackets.dart` and `kTtcInfertility` both state it, and
  //  a chapter titled "your chances" would be the easiest place in the product
  //  to break the rule by accident — a video brief is written months before
  //  anyone reviews the page it sits on.
  PvVideoSlot(
    id: 'ttc_vid_when_to_seek_help',
    hue: 206,
    title: _en('Is it time to see someone?'),
    why: _en('The twelve-month rule, and the six situations where it '
        "doesn't apply to you at all."),
    seconds: 294,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Where the twelve months comes from')),
      PvVideoChapter(at: 54, label: _en('Who shouldn\'t wait it out')),
      PvVideoChapter(at: 146, label: _en('What a first appointment is like')),
      PvVideoChapter(at: 222, label: _en('Gynaecologist or fertility clinic?')),
    ],
    takeaways: [
      _en('Twelve months if you are under 36, but only if your cycles are '
          'regular and nothing else is known.'),
      _en('Irregular cycles, painful periods, past pelvic surgery or an '
          "abnormal semen analysis all mean you don't need to wait that long."),
      _en("Most couples who have tests don't end up needing IVF."),
    ],
    readNext: ['ttc_read_when_to_seek_help'],
    surfaceNext: ['ttc_tests'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_ivf_walkthrough',
    hue: 206,
    title: _en('An IVF cycle, start to finish'),
    why: _en('The whole month in order, so nothing in it comes as a '
        'surprise.'),
    seconds: 528,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('IUI first, because it\'s smaller')),
      PvVideoChapter(at: 96, label: _en('Stimulation, and the injections')),
      PvVideoChapter(at: 198, label: _en('Check-up scans, and why they\'re daily')),
      PvVideoChapter(at: 276, label: _en('Egg collection day')),
      PvVideoChapter(at: 354, label: _en('The lab, and the phone calls')),
      PvVideoChapter(at: 438, label: _en('Transfer, and the two weeks after')),
    ],
    takeaways: [
      _en('IUI is one cycle and a two-minute procedure. IVF takes about a '
          'month, with one day under sedation.'),
      _en('The check-up visits, more than the injections, make IVF hard to '
          'fit around a job with fixed hours.'),
      _en('A frozen transfer is normal practice today. It isn\'t a setback.'),
    ],
    readNext: ['ttc_read_ivf_explained'],
    surfaceNext: ['ttc_treatment'],
  ),

  // ---------------------------------------------------------------------------
  //  Getting ready
  // ---------------------------------------------------------------------------
  PvVideoSlot(
    id: 'ttc_vid_three_months_before',
    hue: 104,
    title: _en('Why three months, and not three weeks'),
    why: _en('An egg grows for ninety days and sperm take eleven weeks. '
        'That\'s why what you do now makes a difference.'),
    seconds: 336,
    expert: _en('Akanksha Srivastava'),
    expertRole: _en('Maternal and child nutritionist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Where the three months comes from')),
      PvVideoChapter(at: 72, label: _en('Folic acid, and the two doses')),
      PvVideoChapter(at: 158, label: _en('Weight, in both directions')),
      PvVideoChapter(at: 244, label: _en('His eleven weeks')),
    ],
    takeaways: [
      _en('What you change today shows up in a cycle about three months '
          'from now. That\'s true for both of you.'),
      _en('Folic acid has to be in your body before the neural tube closes. '
          'That often happens before you miss a period.'),
      _en('A change of around five per cent of your weight is the figure '
          'that matters, not a BMI target.'),
    ],
    readNext: ['ttc_read_three_months_before'],
    surfaceNext: ['ttc_supplements'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_preconception_tests',
    hue: 104,
    title: _en('The tests and jabs to sort out once'),
    why: _en('A short set of blood tests, one screening test that matters '
        'more in India, and two vaccines that need a month\'s notice.'),
    seconds: 318,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('The cheap blood tests')),
      PvVideoChapter(at: 84, label: _en('Thalassaemia, and why you both get '
          'tested')),
      PvVideoChapter(at: 176, label: _en('Rubella, and the month you have to '
          'wait')),
      PvVideoChapter(at: 258, label: _en('Going over your medicines')),
    ],
    takeaways: [
      _en('Thalassaemia screening is advised for all couples here, whatever '
          'your family history.'),
      _en("Rubella and varicella are live vaccines. If you're not immune, "
          'you need the jab and then a month before trying.'),
      _en('Take every tablet you both take to one appointment, including '
          'ayurvedic and herbal ones.'),
    ],
    readNext: ['ttc_read_preconception_tests'],
    surfaceNext: ['ttc_tests'],
  ),

  // ---------------------------------------------------------------------------
  //  His side
  // ---------------------------------------------------------------------------
  PvVideoSlot(
    id: 'ttc_vid_whose_side',
    hue: 186,
    title: _en('Why his side gets tested last'),
    why: _en('A male factor plays a part for about half of couples. And his '
        'test takes three days, against your three months.'),
    seconds: 288,
    expert: _en('ParentVeda team'),
    expertRole: _en('Male fertility'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Why the order is usually wrong')),
      PvVideoChapter(at: 66, label: _en('Count, movement, shape')),
      PvVideoChapter(at: 158, label: _en('The eleven-week cycle')),
      PvVideoChapter(at: 232, label: _en('What the test doesn\'t measure')),
    ],
    takeaways: [
      _en('Half of these cases involve him, and his side is the quickest to '
          'check.'),
      _en('How well sperm move matters more than how many there are.'),
      _en('A sample shows what his body was doing three months ago.'),
    ],
    readNext: ['ttc_read_whose_side'],
    surfaceNext: ['ttc_tests'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_semen_analysis',
    hue: 186,
    title: _en('Reading a semen report without panicking'),
    why: _en('What each number means, and why "below normal" isn\'t as final '
        'as it looks.'),
    seconds: 342,
    expert: _en('ParentVeda team'),
    expertRole: _en('Male fertility'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Where the "normal" line comes from')),
      PvVideoChapter(at: 84, label: _en('The four numbers that matter')),
      PvVideoChapter(at: 176, label: _en('The long words, in plain English')),
      PvVideoChapter(at: 258, label: _en('Why the second test counts most')),
    ],
    takeaways: [
      _en('The "normal" limits are set at the fifth percentile of men who '
          'fathered children naturally.'),
      _en('One in twenty men who conceived without help would score below '
          'them.'),
      _en('An abnormal first result gets repeated before anyone acts on it.'),
    ],
    readNext: ['ttc_read_semen_analysis'],
    surfaceNext: ['ttc_records'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_heat_habits',
    hue: 186,
    title: _en('Three things that really change his numbers'),
    why: _en('Tobacco, heat and time. How much each one matters, and how long '
        'before any change shows.'),
    seconds: 306,
    expert: _en('ParentVeda team'),
    expertRole: _en('Male fertility'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Tobacco, including the chewed kind')),
      PvVideoChapter(at: 88, label: _en('Heat, and the cheap fixes')),
      PvVideoChapter(at: 168, label: _en('Alcohol, weight and steroids')),
      PvVideoChapter(at: 246, label: _en('Why nothing shows for three months')),
    ],
    takeaways: [
      _en('Gutka and khaini are tobacco too, though people often leave them '
          'out.'),
      _en('Heat is the cheapest thing to change: the laptop goes on a table, '
          'not his lap.'),
      _en('Any change takes about three months to show up in a test.'),
    ],
    readNext: ['ttc_read_heat_habits'],
    surfaceNext: ['ttc_partner'],
  ),

  // ---------------------------------------------------------------------------
  //  After a loss — ONE film, on the practical half only
  // ---------------------------------------------------------------------------
  //  ⚠️ NO FILM ON "ON TRYING AGAIN", DELIBERATELY. A play control at the top
  //  of a page about whether she is ready to try again is the wrong texture —
  //  it makes the page feel produced at the moment it most needs to feel
  //  written. The physical half carries the video for this bracket.
  PvVideoSlot(
    id: 'ttc_vid_loss_recovery',
    hue: 26,
    title: _en('What the next few weeks look like'),
    why: _en('Bleeding, hormones and when your cycle comes back. The '
        "practical part, explained once so you don't have to look it up at "
        'night.'),
    seconds: 264,
    expert: _en('Dr Ruchika Sood'),
    expertRole: _en('IVF gynaecologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('The bleeding, and how long')),
      PvVideoChapter(at: 62, label: _en('Why a test can stay positive')),
      PvVideoChapter(at: 132, label: _en('When your cycle comes back')),
      PvVideoChapter(at: 198, label: _en('The signs that need a hospital')),
    ],
    takeaways: [
      _en('Bleeding usually settles within one to two weeks.'),
      _en('A positive test for a few weeks afterwards is the hormone leaving '
          'your body. It doesn\'t mean the pregnancy is continuing.'),
      _en('Ovulation often comes back before your first period does.'),
    ],
    readNext: ['ttc_read_loss_recovery'],
    // Community held back for launch (2026-09-26, TTC gap plan §7.1) — kept for revert.
    // surfaceNext: ['ttc_community'],
  ),

  // ---------------------------------------------------------------------------
  //  Mind & body
  // ---------------------------------------------------------------------------
  PvVideoSlot(
    id: 'ttc_vid_stress_fertility',
    hue: 42,
    title: _en('Why "just relax" is the wrong advice'),
    why: _en('What the evidence shows about stress and getting pregnant, and '
        'why that advice hurts.'),
    seconds: 276,
    expert: _en('Parmeshwari'),
    expertRole: _en('Clinical psychologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('What everyone says, and why')),
      PvVideoChapter(at: 58, label: _en('What the studies found')),
      PvVideoChapter(at: 148, label: _en('The one real exception')),
      PvVideoChapter(at: 214, label: _en('So what is a practice for?')),
    ],
    takeaways: [
      _en('Across 14 studies, how upset people felt before treatment made no '
          'difference to whether it worked.'),
      _en('Very high stress that goes on for a long time can stop ovulation. '
          "Everyday worry doesn't."),
      _en('A practice is worth doing because it makes the waiting easier to '
          'bear. That is reason enough.'),
    ],
    readNext: ['ttc_read_stress_fertility'],
    surfaceNext: ['ttc_ritual'],
  ),

  // ⚠️ A SERIES, NOT A SINGLE FILM — `episodeCount` drives the playlist
  // treatment on the placeholder. This is the free course the workbook asks
  // for, so its cover has to read as a course rather than as one video.
  PvVideoSlot(
    id: 'ttc_vid_garbh_preconception',
    hue: 42,
    title: _en('Preconception garbh sanskar, taught'),
    why: _en('The eight sessions, for both of you. You do the practice, not '
        'just hear about it.'),
    seconds: 2160,
    expert: _en('Dr Kajal Sharma'),
    expertRole: _en('Ayurveda and yoga teacher'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('What this is, and isn\'t')),
      PvVideoChapter(at: 240, label: _en('Breath, the first week')),
      PvVideoChapter(at: 660, label: _en('Stillness, and why it\'s short')),
      PvVideoChapter(at: 1080, label: _en('Sound, and reading aloud')),
      PvVideoChapter(at: 1500, label: _en('The conversation, for both of you')),
      PvVideoChapter(at: 1860, label: _en('Carrying on when you miss a day')),
    ],
    takeaways: [
      _en('Five to fifteen minutes. Doing it often matters more than doing it '
          'for long.'),
      _en("Both partners, together. That's what makes it different from "
          'everything else at this stage.'),
      _en('You don\'t need to believe in anything, and nothing is promised.'),
    ],
    readNext: ['ttc_read_garbh_sanskar'],
    surfaceNext: ['ttc_ritual'],
  ),

  // ⚠️ THE ONE FILM THE MIND & BODY REBUILD ADDS, AND IT IS THE ONLY CARD ON
  // that door with no existing source. Everything else there is `reuse`,
  // `promote` or `reference`; the brief marks this one "new (20 to 30 min)".
  //
  // Written and chaptered here rather than left as a bare slot id, which is the
  // pattern the other four owed TTC films follow — and the pattern the
  // conceiving door's hero video did NOT follow, which is exactly why that one
  // could be removed on 2026-09-05 without orphaning anything. A slot with
  // chapters and takeaways is a commissioning brief; a bare id is a hole.
  PvVideoSlot(
    id: 'ttc_vid_mind_longer_session',
    hue: 42,
    title: _en('A longer session, for a day you have time'),
    why: _en('The short daily cards joined together. Movement, breath and '
        'stillness in one sitting, at an easy, unhurried pace.'),
    seconds: 1500,
    expert: _en('Dr Kajal Sharma'),
    expertRole: _en('Ayurveda and yoga teacher'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Settling in, and what this isn\'t')),
      PvVideoChapter(at: 180, label: _en('Loosening the neck and shoulders')),
      PvVideoChapter(at: 540, label: _en('Hips, slowly')),
      PvVideoChapter(at: 900, label: _en('Legs up the wall, and the breath')),
      PvVideoChapter(at: 1200, label: _en('Ten minutes of stillness')),
    ],
    takeaways: [
      _en('The idea is once a week. It doesn\'t replace your few daily '
          'minutes, and it\'s fine to skip it.'),
      _en('Each part of this is also a short card of its own. Nothing here '
          'is new. It\'s the same practices, done without stopping.'),
      _en('Stop whenever you like. Leaving halfway still counts as a '
          'finished session.'),
    ],
    readNext: ['ttc_read_stress_fertility'],
  ),
];

/// The slot lookup the reader is handed.
///
/// ⚠️ NULL IS A REAL ANSWER, same rule as `ttc_surface_router.dart`. An unknown
/// slot is a wiring mistake and the caller renders nothing rather than an empty
/// box — and `test/pv_read_shape_test.dart` fails the build so it never reaches
/// a user.
PvVideoSlot? ttcVideoBySlot(String slotId) {
  for (final v in kTtcVideos) {
    if (v.id == slotId) return v;
  }
  return null;
}
