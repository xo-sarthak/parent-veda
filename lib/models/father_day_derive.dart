// =============================================================================
//  Deriving a father's day from the mother's day
// -----------------------------------------------------------------------------
//  Same decision as father_week_derive.dart, one level down, and made for the
//  reason the product owner gave: the content pool is shared. A father is not
//  reading a different pregnancy. He is reading the same one, VOICED FOR HIM.
//
//  Before this there was exactly one authored father day — day 143 — and
//  dayFor() fell back to "the nearest authored day", which with one file meant
//  every father saw day 143 from week 4 to week 40. The mother meanwhile has
//  all 259 days written and reviewed (lib/data/home/week_NN.json). Writing a
//  second 259-day pool would mean inventing content beside reviewed content,
//  and the two would drift.
//
//  WHAT MAPS TO WHAT
//
//     FatherDay.learn    <- HomeDay.grow        identical shape, minus `module`
//     FatherDay.talk     <- HomeDay.talkToBaby  her title IS the prompt
//     FatherDay.mission  <- HomeDay.nurture     re-framed, see below
//
//  THE SHUFFLE, AND WHY IT IS NOT COSMETIC
//
//  A father does not read his partner's day; he reads a day from the same WEEK,
//  picked by a deterministic offset. That does two jobs at once:
//
//   1. They rarely open the app to the identical card, which is what was asked
//      for.
//   2. It is what makes the safety filter below possible. 37 of the mother's
//      259 `grow` blocks speak to her body — "Your Body Is Already Parenting" —
//      and read to a father those are simply wrong, the same way week 22's
//      "your heartbeat" was. No week has more than 3 such days out of 7, so
//      walking the week for a clean one ALWAYS finds one.
//
//  Deterministic, not random: the card must not change under him on a rebuild.
//
//  THE MISSION IS RE-FRAMED, NOT COPIED
//
//  `nurture` is her self-care — a breath, an affirmation, something to eat. Its
//  `content` addresses her body in 60 of 259 days, so it is never shown to him.
//  He gets the title and the one-line `remember`, under a lead-in chosen by the
//  nurture type: breathe -> do it with her, affirm -> say it to her, food ->
//  make it happen. That is a real transformation into an action he can take,
//  not her text with a pronoun swapped.
// =============================================================================

import '../localization/app_language.dart';
import 'father_day.dart';
import 'home_day.dart';

/// Second-person references to something only she has. "your voice" and "your
/// baby" are deliberately absent — both are true of him too.
final RegExp _herBody = RegExp(
  r'your (body|belly|womb|bump|uterus|breasts?|hips?|pelvis|energy|blood|'
  r'hormones?|skin|ankles)',
  caseSensitive: false,
);

final RegExp _herBodyHi = RegExp(
  r'(aapka sharir|aapke sharir|tumhara sharir|aapka pet|aapke pet|'
  r'tumhara pet|aapki energy|tumhari energy)',
  caseSensitive: false,
);

bool _speaksToHer(LocalizedText t) =>
    _herBody.hasMatch(t.en) || _herBodyHi.hasMatch(t.hi);

/// How much of this day would read wrongly to a father. 0 = safe.
int _herScore(HomeDay d) {
  var n = 0;
  for (final t in [
    d.grow.title,
    d.grow.insight,
    d.grow.expanded,
    d.grow.remember,
    if (d.grow.deepDive != null) d.grow.deepDive!,
    d.talk.title,
    d.talk.motivation,
    // Only the nurture fields he is actually shown.
    d.nurture.title,
    d.nurture.remember,
  ]) {
    if (_speaksToHer(t)) n++;
  }
  return n;
}

/// Pick which of the week's days a father reads on [day].
///
/// Offset so he is rarely on the same card as her, then walk forward to the
/// first day that reads cleanly to him. Falls back to the least-bad day, which
/// in practice never happens — no week has 7 flagged days.
HomeDay pickFatherSource(int day, List<HomeDay> week) {
  if (week.isEmpty) throw ArgumentError('no days for this week');
  final ordered = [...week]..sort((a, b) => a.day.compareTo(b.day));
  // +3 rather than +1: a one-day shift means he reads her yesterday, which
  // feels like lag rather than a different card.
  final start = (day + 3) % ordered.length;
  for (var i = 0; i < ordered.length; i++) {
    final c = ordered[(start + i) % ordered.length];
    if (_herScore(c) == 0) return c;
  }
  ordered.sort((a, b) => _herScore(a).compareTo(_herScore(b)));
  return ordered.first;
}

/// The curriculum chapter shown as the Learn card's eyebrow. Keyed off the
/// week's phase so it moves with the pregnancy instead of being a constant.
LocalizedText _module(int week) {
  if (week <= 12) {
    return const LocalizedText(
        en: 'BECOMING A FATHER', hi: 'PITA BANNE KI SHURUAAT');
  }
  if (week <= 20) {
    return const LocalizedText(en: 'SHOWING UP', hi: 'SAATH DENA');
  }
  if (week <= 27) {
    return const LocalizedText(en: 'BUILDING THE BOND', hi: 'RISHTA BANANA');
  }
  if (week <= 36) {
    return const LocalizedText(en: 'GETTING READY', hi: 'TAIYAARI');
  }
  return const LocalizedText(en: 'THE ARRIVAL', hi: 'UNKA AANA');
}

LocalizedText _intro(int week) {
  if (week <= 12) {
    return const LocalizedText(
      en: 'A moment to sit with what is happening.',
      hi: 'Jo ho raha hai, uske saath thoda ruk kar baithne ka pal.',
    );
  }
  if (week <= 27) {
    return const LocalizedText(
      en: 'A moment to build the father you want to be.',
      hi: 'Woh pita banne ka pal jo aap banna chahte hain.',
    );
  }
  return const LocalizedText(
    en: 'A moment to get ready, in the way that matters.',
    hi: 'Taiyaar hone ka pal, us tarah se jo maayne rakhta hai.',
  );
}

/// A short headline for the Talk card. Her `title` IS the prompt — a full
/// sentence — so it cannot double as a heading.
const _talkHeading = LocalizedText(
  en: 'Talk to your baby',
  hi: 'Apne baby se baat kijiye',
);

/// The lead-in that turns her self-care into his action.
LocalizedText _missionLead(NurtureType t) => switch (t) {
      NurtureType.breathe => const LocalizedText(
          en: 'Do this with her today.', hi: 'Aaj yeh uske saath kijiye.'),
      NurtureType.affirm => const LocalizedText(
          en: 'Say this to her today.', hi: 'Aaj yeh usse kahiye.'),
      NurtureType.food => const LocalizedText(
          en: 'Make this happen for her today.',
          hi: 'Aaj yeh uske liye kar dijiye.'),
    };

LocalizedText _join(LocalizedText a, LocalizedText b) => LocalizedText(
      en: [a.en.trim(), b.en.trim()].where((s) => s.isNotEmpty).join(' '),
      hi: [a.hi.trim(), b.hi.trim()].where((s) => s.isNotEmpty).join(' '),
    );

/// Build the father's day for [day] from the mother's week.
FatherDay fatherDayFromMother(int day, int week, List<HomeDay> weekDays) {
  final src = pickFatherSource(day, weekDays);
  return FatherDay(
    day: day,
    week: week,
    intro: _intro(week),
    learn: FatherLesson(
      module: _module(week),
      title: src.grow.title,
      insight: src.grow.insight,
      expanded: src.grow.expanded,
      deepDive: src.grow.deepDive,
      remember: src.grow.remember,
    ),
    talk: FatherTalkPrompt(
      title: _talkHeading,
      prompt: src.talk.title,
      motivation: src.talk.motivation,
    ),
    mission: FatherMission(
      title: src.nurture.title,
      action: _join(_missionLead(src.nurture.type), src.nurture.remember),
      durationMinutes: src.nurture.durationMinutes,
    ),
  );
}
