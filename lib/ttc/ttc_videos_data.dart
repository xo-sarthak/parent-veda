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
