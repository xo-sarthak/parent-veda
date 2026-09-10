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
    why: _en('What is actually happening in your ovaries, without the '
        'diagrams nobody understands.'),
    seconds: 312,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('What the name gets wrong')),
      PvVideoChapter(at: 48, label: _en('Insulin, and why it matters here')),
      PvVideoChapter(at: 132, label: _en('Why cycles go long, or go quiet')),
      PvVideoChapter(at: 205, label: _en('What actually shifts it')),
      PvVideoChapter(at: 268, label: _en('When to see someone')),
    ],
    takeaways: [
      _en('The cysts in the name are not cysts, and they are not the '
          'problem — the hormone pattern is.'),
      _en('PCOS is the commonest reason ovulation turns irregular, and '
          'irregular is not the same as absent.'),
      _en('It is a pattern that gets managed, not a door that closes.'),
    ],
    readNext: ['ttc_read_pcos_cycle'],
    surfaceNext: ['ttc_cycle'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_pcos_treatment',
    hue: 288,
    title: _en('What they will actually offer you'),
    why: _en('The order treatment is tried in, and what to ask before you '
        'agree to any of it.'),
    seconds: 402,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Why nothing you swallow comes first')),
      PvVideoChapter(at: 78, label: _en('Letrozole, and what changed in 2023')),
      PvVideoChapter(at: 168, label: _en('Where metformin actually fits')),
      PvVideoChapter(at: 252, label: _en('Three questions for the first visit')),
      PvVideoChapter(at: 336, label: _en('What none of it does')),
    ],
    takeaways: [
      _en('Treatment starts with the least invasive thing that might work '
          'and stops as soon as something does.'),
      _en('Letrozole is now the preferred first tablet, ahead of clomiphene.'),
      _en('None of it treats PCOS — it treats the stall, which is why the '
          'first step stays relevant throughout.'),
    ],
    readNext: ['ttc_read_pcos_treatment'],
    surfaceNext: ['ttc_tests'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_pcos_plate',
    hue: 288,
    title: _en('What a PCOS-friendly Indian plate looks like'),
    why: _en('Roti, rice and dal are not the enemy. What goes beside them '
        'is the whole conversation.'),
    seconds: 428,
    expert: _en('Meghna Iyer'),
    expertRole: _en('Fertility nutritionist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Why "cut carbs" is bad advice here')),
      PvVideoChapter(at: 72, label: _en('The order you eat things in')),
      PvVideoChapter(at: 168, label: _en('Protein, at an Indian breakfast')),
      PvVideoChapter(at: 262, label: _en('Three plates, built on camera')),
      PvVideoChapter(at: 372, label: _en('What is not worth bothering with')),
    ],
    takeaways: [
      _en('The goal is a steadier blood-sugar curve, not fewer calories.'),
      _en('Protein and fibre before the carbohydrate flattens the spike '
          'more than removing the carbohydrate does.'),
      _en('No food group has to leave your kitchen.'),
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
    title: _en('Your cycle, drawn once and for all'),
    why: _en('The two halves, why only one of them moves, and where '
        'ovulation actually sits in yours.'),
    seconds: 384,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Two halves, not one cycle')),
      PvVideoChapter(at: 66, label: _en('The half that moves')),
      PvVideoChapter(at: 152, label: _en('Ovulation, in about a minute')),
      PvVideoChapter(at: 228, label: _en('The half that does not move')),
      PvVideoChapter(
          at: 304, label: _en('Counting backwards, not forwards')),
    ],
    takeaways: [
      _en('The first half of a cycle varies; the second is about fourteen '
          'days in almost everyone.'),
      _en('So ovulation is found by counting back from the next period, not '
          'forward from the last one.'),
      _en('"Day 14" is only right if your cycle is 28 days.'),
    ],
    readNext: ['ttc_read_how_conception_works'],
    surfaceNext: ['ttc_cycle'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_timing_myths',
    hue: 344,
    title: _en('Six timing myths, put down one by one'),
    why: _en('Positions, saving it up, lying still afterwards — what the '
        'evidence actually says about each.'),
    seconds: 366,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('"Only on the day you ovulate"')),
      PvVideoChapter(at: 62, label: _en('"Save it up for the window"')),
      PvVideoChapter(at: 138, label: _en('"Lie still for twenty minutes"')),
      PvVideoChapter(at: 204, label: _en('"Position changes the odds"')),
      PvVideoChapter(at: 262, label: _en('"Stress is why it is not working"')),
      PvVideoChapter(at: 318, label: _en('The one that is actually true')),
    ],
    takeaways: [
      _en('The window is about six days, and the two before ovulation '
          'matter more than the day itself.'),
      _en('Every other day across the window beats trying to hit one date.'),
      _en('Most of what you have been told to do afterwards does nothing.'),
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
    why: _en('The twelve-month rule, and the six situations where it does '
        'not apply to you at all.'),
    seconds: 294,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Where the twelve months comes from')),
      PvVideoChapter(at: 54, label: _en('Who should not wait it out')),
      PvVideoChapter(at: 146, label: _en('What a first appointment is like')),
      PvVideoChapter(at: 222, label: _en('Gynaecologist or fertility clinic?')),
    ],
    takeaways: [
      _en('Twelve months under 36 — but only if your cycles are regular and '
          'nothing else is known.'),
      _en('Irregular cycles, painful periods, past pelvic surgery or an '
          'abnormal semen analysis all mean the clock does not apply.'),
      _en('Most couples who are investigated do not end up having IVF.'),
    ],
    readNext: ['ttc_read_when_to_seek_help'],
    surfaceNext: ['ttc_tests'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_ivf_walkthrough',
    hue: 206,
    title: _en('An IVF cycle, start to finish'),
    why: _en('The whole month laid out in order, so nothing in it arrives as '
        'a surprise.'),
    seconds: 528,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('IUI first, because it is smaller')),
      PvVideoChapter(at: 96, label: _en('Stimulation, and the injections')),
      PvVideoChapter(at: 198, label: _en('Monitoring, and why it is daily')),
      PvVideoChapter(at: 276, label: _en('Retrieval day')),
      PvVideoChapter(at: 354, label: _en('The laboratory, and the phone calls')),
      PvVideoChapter(at: 438, label: _en('Transfer, and the two weeks after')),
    ],
    takeaways: [
      _en('IUI is one cycle and a two-minute procedure; IVF is about a month '
          'with one day under sedation.'),
      _en('The monitoring visits, not the injections, are what makes IVF hard '
          'to fit around a rigid job.'),
      _en('A frozen transfer is normal current practice, not a setback.'),
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
    why: _en('An egg matures for ninety days and sperm take eleven weeks — '
        'which is why the window you can influence is open now.'),
    seconds: 336,
    expert: _en('Meghna Iyer'),
    expertRole: _en('Fertility nutritionist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Where the three months comes from')),
      PvVideoChapter(at: 72, label: _en('Folic acid, and the two doses')),
      PvVideoChapter(at: 158, label: _en('Weight, in both directions')),
      PvVideoChapter(at: 244, label: _en('His eleven weeks')),
    ],
    takeaways: [
      _en('What you change today shows up in a cycle about three months '
          'from now — for both of you.'),
      _en('Folic acid has to be in your body before the neural tube closes, '
          'which is often before a period is missed.'),
      _en('Around five per cent is the weight figure that matters, not a BMI '
          'target.'),
    ],
    readNext: ['ttc_read_three_months_before'],
    surfaceNext: ['ttc_supplements'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_preconception_tests',
    hue: 104,
    title: _en('The errands worth doing once'),
    why: _en('A short blood panel, one screening test that matters more in '
        'India, and two vaccines that need a month of notice.'),
    seconds: 318,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('The cheap blood panel')),
      PvVideoChapter(at: 84, label: _en('Thalassaemia, and why it is a couple '
          'test')),
      PvVideoChapter(at: 176, label: _en('Rubella, and the month you have to '
          'wait')),
      PvVideoChapter(at: 258, label: _en('The medication review')),
    ],
    takeaways: [
      _en('Thalassaemia screening is recommended for all couples here, '
          'whatever the family history.'),
      _en('Rubella and varicella are live vaccines — not immune means the jab '
          'plus a month before trying.'),
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
    title: _en('The half that gets investigated last'),
    why: _en('A male factor is involved in about half of couples — and his '
        'test takes three days against her three months.'),
    seconds: 288,
    expert: _en('Dr. Vikram Nair'),
    expertRole: _en('Andrologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Why the order is usually wrong')),
      PvVideoChapter(at: 66, label: _en('Count, movement, shape')),
      PvVideoChapter(at: 158, label: _en('The eleven-week cycle')),
      PvVideoChapter(at: 232, label: _en('What the test does not measure')),
    ],
    takeaways: [
      _en('Half of these cases involve him, and his half is the fastest to '
          'check.'),
      _en('Movement matters more than count.'),
      _en('A sample reflects what his body was doing three months ago.'),
    ],
    readNext: ['ttc_read_whose_side'],
    surfaceNext: ['ttc_tests'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_semen_analysis',
    hue: 186,
    title: _en('Reading a semen report without panicking'),
    why: _en('What each number means, and why "below normal" is not the '
        'verdict it looks like.'),
    seconds: 342,
    expert: _en('Dr. Vikram Nair'),
    expertRole: _en('Andrologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Where the "normal" line comes from')),
      PvVideoChapter(at: 84, label: _en('The four numbers that matter')),
      PvVideoChapter(at: 176, label: _en('The long words, translated')),
      PvVideoChapter(at: 258, label: _en('Why the repeat is the real test')),
    ],
    takeaways: [
      _en('The reference limits are the fifth percentile of men who fathered '
          'children naturally.'),
      _en('One in twenty men who conceived without help would score below '
          'them.'),
      _en('An abnormal first result is repeated before anyone acts on it.'),
    ],
    readNext: ['ttc_read_semen_analysis'],
    surfaceNext: ['ttc_records'],
  ),

  PvVideoSlot(
    id: 'ttc_vid_heat_habits',
    hue: 186,
    title: _en('Three things that actually change his numbers'),
    why: _en('Tobacco, heat and time — what each is worth, and how long '
        'before any of it shows.'),
    seconds: 306,
    expert: _en('Dr. Vikram Nair'),
    expertRole: _en('Andrologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Tobacco, including the chewed kind')),
      PvVideoChapter(at: 88, label: _en('Heat, and the cheap fixes')),
      PvVideoChapter(at: 168, label: _en('Alcohol, weight and steroids')),
      PvVideoChapter(at: 246, label: _en('Why nothing shows for three months')),
    ],
    takeaways: [
      _en('Gutka and khaini count as tobacco, and are often not counted.'),
      _en('Heat is the cheapest lever: a table, not a lap.'),
      _en('Any change takes about three months to reach a test.'),
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
    why: _en('Bleeding, hormones and when a cycle returns — the practical '
        'part, explained once so you do not have to look it up at night.'),
    seconds: 264,
    expert: _en('Dr. Ananya Rao'),
    expertRole: _en('Gynaecologist · 14 years'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('The bleeding, and how long')),
      PvVideoChapter(at: 62, label: _en('Why a test can stay positive')),
      PvVideoChapter(at: 132, label: _en('When the cycle comes back')),
      PvVideoChapter(at: 198, label: _en('The signs that need a hospital')),
    ],
    takeaways: [
      _en('Bleeding usually settles within one to two weeks.'),
      _en('A positive test for a few weeks afterwards is the hormone '
          'clearing, not a continuing pregnancy.'),
      _en('Ovulation often returns before the first period does.'),
    ],
    readNext: ['ttc_read_loss_recovery'],
    surfaceNext: ['ttc_community'],
  ),

  // ---------------------------------------------------------------------------
  //  Mind & body
  // ---------------------------------------------------------------------------
  PvVideoSlot(
    id: 'ttc_vid_stress_fertility',
    hue: 42,
    title: _en('"Just relax" — why that advice is wrong'),
    why: _en('What the evidence actually shows about stress and conceiving, '
        'and why the advice does damage.'),
    seconds: 276,
    expert: _en('Dr. Sharanya Menon'),
    expertRole: _en('Perinatal psychologist'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('What everyone says, and why')),
      PvVideoChapter(at: 58, label: _en('What the studies actually found')),
      PvVideoChapter(at: 148, label: _en('The one real exception')),
      PvVideoChapter(at: 214, label: _en('So what is a practice for')),
    ],
    takeaways: [
      _en('Emotional distress before treatment was not associated with '
          'whether it worked, across 14 studies.'),
      _en('Severe sustained stress can suppress ovulation — everyday worry '
          'does not.'),
      _en('A practice is worth doing because it makes the waiting bearable, '
          'which is a complete reason.'),
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
    why: _en('The eight sessions, for both of you — the practice done rather '
        'than described.'),
    seconds: 2160,
    expert: _en('Anjali Deshmukh'),
    expertRole: _en('Yoga and breathwork lead'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('What this is, and is not')),
      PvVideoChapter(at: 240, label: _en('Breath, the first week')),
      PvVideoChapter(at: 660, label: _en('Stillness, and why it is short')),
      PvVideoChapter(at: 1080, label: _en('Sound, and reading aloud')),
      PvVideoChapter(at: 1500, label: _en('The conversation, for both of you')),
      PvVideoChapter(at: 1860, label: _en('Keeping it when you miss a day')),
    ],
    takeaways: [
      _en('Five to fifteen minutes, and consistency matters more than '
          'duration.'),
      _en('Both partners, together — that is what makes it different from '
          'everything else in this stage.'),
      _en('No belief required, and no outcome promised.'),
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
    title: _en('A longer session, for a day you have the time'),
    why: _en('The short daily cards, joined up — movement, breath and stillness '
        'in one sitting, at a pace nobody has to keep up with.'),
    seconds: 1500,
    expert: _en('Anjali Deshmukh'),
    expertRole: _en('Yoga and breathwork lead'),
    chapters: [
      PvVideoChapter(at: 0, label: _en('Settling, and what this is not')),
      PvVideoChapter(at: 180, label: _en('Loosening the neck and shoulders')),
      PvVideoChapter(at: 540, label: _en('Hips, slowly')),
      PvVideoChapter(at: 900, label: _en('Legs up the wall, and the breath')),
      PvVideoChapter(at: 1200, label: _en('Ten minutes of stillness')),
    ],
    takeaways: [
      _en('Once a week is the intention. It is not a replacement for the '
          'daily few minutes, and skipping it costs nothing.'),
      _en('Every part of this appears on its own as a short card — nothing '
          'here is new, it is the same practices without stopping.'),
      _en('Stop at any point. Leaving halfway through is a finished session.'),
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
