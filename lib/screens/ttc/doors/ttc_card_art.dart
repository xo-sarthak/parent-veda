// =============================================================================
//  The picture on a door card, decided card by card (2026-09-29)
// -----------------------------------------------------------------------------
//  ⚠️ THE USER, LOOKING AT THE FERTILE WINDOW DOOR BESIDE FLO'S: "you have
//  picked so much random images that it's making the section look bad by the
//  images themselves." Judged one by one on a contact sheet, 20 of the door's
//  photos show their subject (the strips, the tests, the hourglass, the thali,
//  the microscope, the stethoscope) and 22 do not (cherry blossom for "Which
//  days", a glacier for "Heat", light bulbs, raindrops, mugs saying "weirdo").
//
//  Flo's answer is an object on a soft colour (its hourglass on blue), so a
//  card without a photo that shows its subject draws one of our marks
//  (`TtcTabMark`) on its kind's colour instead. The rule for the table below:
//    · [kTtcCardPhotoOff]: the photo in `kReadImageUrls` does not show the
//      subject, so the CARD draws its mark. The read's own page still shows
//      the photo; replacing the read photos themselves is owed (STILL-OPEN
//      §80.12) and would reach Learn and the reader too.
//    · [kTtcCardMarks]: the drawn object for a card, chosen for its subject,
//      never the same mark twice in one section.
//  A card in neither keeps the photo it had, or its kind's drawing.
//  The Fertile window door first; the other eight doors keep their photos
//  until they are judged the same way.
// =============================================================================

import 'ttc_tab_art.dart';

/// Cards whose table photo does not show their subject (the Fertile window
/// door, judged 2026-09-29). They draw [kTtcCardMarks] instead.
const Set<String> kTtcCardPhotoOff = {
  'ttc_tile_which_days_can_you_get_pregnant', // cherry blossom
  'ttc_tile_ovulation_kits_when_your_cycles_are_irregular', // notebook, coffee
  'ttc_tile_how_morning_temperature_tracking_works', // a bedroom
  'ttc_tile_buy_an_ovulation_kit', // a crowded pharmacy front
  'ttc_tile_every_day_or_not', // a 2011 desk calendar
  'ttc_tile_do_you_need_to_orgasm', // a dark flower close-up
  'ttc_tile_six_myths_about_timing_one_by_one', // a black pocket watch
  'ttc_tile_your_cycle_drawn_out_step_by_step', // a moon over hills
  'ttc_tile_early_pregnancy_signs_and_why_most_are_also_pms', // cup on a book
  'ttc_tile_implantation_bleeding_or_your_period', // flowers in a basket
  'ttc_tile_when_to_take_a_pregnancy_test_and_which_one', // clock on wallpaper
  'ttc_tile_late_period_negative_test', // raindrops
  'ttc_tile_feeling_pregnant_but_the_test_says_no', // a book and coffee
  'ttc_tile_low_desire_yours_and_his', // a candle on books
  'ttc_tile_staying_close_through_months_of_trying', // "weirdo" mugs
  'ttc_tile_pain_during_sex', // lilac
  'ttc_tile_which_lubricants_are_sperm_friendly', // bubbles
  'ttc_tile_sex_after_the_fertile_window', // light bulbs
  'ttc_tile_heat_habits_and_time_what_changes_sperm', // a glacier
  'ttc_tile_what_to_cut_before_trying', // flowers and lemon water
  'ttc_tile_weight_before_pregnancy_said_kindly', // an arrow on a road
  'ttc_tile_trying_for_many_months', // autumn leaves
  'ttc_tile_how_long_getting_pregnant_usually_takes', // a red leaf
  'ttc_tile_signs_not_to_wait', // a notebook
  // On subject, but a black ground: the one heavy picture on a calm page.
  'ttc_tile_the_two_week_wait_day_by_day', // an hourglass on black
};

/// The drawn object for a card with no photo that shows its subject.
const Map<String, TtcTabMark> kTtcCardMarks = {
  // When should we have sex?
  // Not the ring: the tool beside it draws the window already.
  'ttc_tile_which_days_can_you_get_pregnant': TtcTabMark.cycleDrops,
  'ttc_tile_ovulation_kits_when_your_cycles_are_irregular':
      TtcTabMark.chartLine,
  'ttc_tile_how_morning_temperature_tracking_works': TtcTabMark.sunrise,
  'ttc_tile_buy_an_ovulation_kit': TtcTabMark.testStrip,
  // How often should we have sex?
  'ttc_tile_every_day_or_not': TtcTabMark.twoCircles,
  // Positions, lying down and other myths
  'ttc_tile_do_you_need_to_orgasm': TtcTabMark.tulip,
  'ttc_tile_six_myths_about_timing_one_by_one': TtcTabMark.signpost,
  // How does conception happen?
  'ttc_tile_how_conception_works': TtcTabMark.twoCircles,
  'ttc_tile_your_cycle_drawn_out_step_by_step': TtcTabMark.timelineDots,
  // What happens in the two weeks after ovulation?
  'ttc_tile_the_two_week_wait_day_by_day': TtcTabMark.timelineDots,
  'ttc_tile_early_pregnancy_signs_and_why_most_are_also_pms':
      TtcTabMark.magnifier,
  'ttc_tile_implantation_bleeding_or_your_period': TtcTabMark.cycleDrops,
  // When and how should you take a pregnancy test?
  'ttc_tile_when_to_take_a_pregnancy_test_and_which_one': TtcTabMark.clock,
  // What if the pregnancy test says no?
  'ttc_tile_late_period_negative_test': TtcTabMark.cloudRain,
  'ttc_tile_feeling_pregnant_but_the_test_says_no': TtcTabMark.heartHand,
  // When trying changes your sex life
  'ttc_tile_low_desire_yours_and_his': TtcTabMark.twoFigures,
  'ttc_tile_staying_close_through_months_of_trying': TtcTabMark.twoCircles,
  // The sex questions that are hard to ask
  'ttc_tile_pain_during_sex': TtcTabMark.hotBottle,
  'ttc_tile_which_lubricants_are_sperm_friendly': TtcTabMark.jarLeaf,
  'ttc_tile_sex_after_the_fertile_window': TtcTabMark.bigSmallHearts,
  // What can he do for his fertility?
  'ttc_tile_heat_habits_and_time_what_changes_sperm': TtcTabMark.sun,
  // What can you do before you conceive?
  'ttc_tile_what_to_cut_before_trying': TtcTabMark.checklist,
  'ttc_tile_weight_before_pregnancy_said_kindly': TtcTabMark.scale,
  // When should we see a doctor?
  'ttc_tile_trying_for_many_months': TtcTabMark.doctorChat,
  'ttc_tile_how_long_getting_pregnant_usually_takes': TtcTabMark.windingPath,
  'ttc_tile_signs_not_to_wait': TtcTabMark.signpost,
};
