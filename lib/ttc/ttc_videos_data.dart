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
