// =============================================================================
//  First 40 days · "Din by din" follows the day (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P2 (First 40 days door): '"Din by din" does not change by the
//  day. Show the card for her day range first (days 1 to 7, 8 to 15…), and add
//  one line a day for the 40 days.'
//
//  Two things, both derived from the birth date and nothing else:
//    * the day-range page she is in moves to the front of the Din by din rail
//      (after day 40, "You made it to 40 days" leads);
//    * a "Day N of 40" card at the top of that tab, with one line for today.
//
//  The lines are about rest, feeding, healing and asking for help. None is a
//  rule or a target; anything that needs a doctor says so plainly.
//  REQUIRED_REVIEW (midwife or lactation consultant): the 40 lines.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_content.dart';

const String kPpDinTabId = 'din_by_din';

/// (first day, last day, page id). Day 1 is the birth day.
const List<(int, int, String)> kPpDinRanges = [
  (1, 7, 'f40_days_1_7'),
  (8, 15, 'f40_days_8_15'),
  (16, 30, 'f40_days_16_30'),
  (31, 40, 'f40_days_31_40'),
];
const String kPpDinAfterPageId = 'f40_forty_mark';

/// One line for each of the 40 days. Index 0 is day 1.
const List<String> kPpDinLines = [
  'Today is for skin to skin, sleep and feeds. Nothing else needs doing.',
  'Small feeds, often, are normal now. Your baby\'s tummy is tiny.',
  'Your milk may start to come in around now. Full, warm breasts are common.',
  'Many mothers feel weepy around day four. It usually passes within days.',
  'Let someone else hold the baby while you eat a proper meal.',
  'Count the wet nappies today. Five or six by now is a good sign.',
  'One week. Rest whenever the baby sleeps, even for twenty minutes.',
  'Your bleeding should be getting lighter. Heavy bleeding again is a reason to call your doctor.',
  'Ask for help with one job today, and let it be done their way.',
  'Feeds may still feel long. Comfort on the breast is part of feeding.',
  'Drink a glass of water with every feed.',
  'A short walk inside the house is enough movement for now.',
  'Your baby may have a fussy evening. It is common and it passes.',
  'Two weeks. Many babies are back to their birth weight around now.',
  'If stitches or a scar feel hotter or more painful, show your doctor.',
  'Say yes to visitors who help and no to visitors who need hosting.',
  'Nap once today. The house can wait.',
  'Your baby is learning your smell and voice. Talk while you feed.',
  'If feeding hurts every time, a lactation consultant can help. Pain is not a test.',
  'Eat something warm and simple. Dal and rice is enough.',
  'Three weeks. Growth spurts can make feeds closer together for a day or two.',
  'Notice how you feel, not just how the baby is doing.',
  'Fresh air by a window or on a balcony is good for both of you.',
  'Let the evenings be slow. Dim lights help everyone settle.',
  'Share one night feed or settle with your partner if you can.',
  'If you feel low most days, tell your doctor. You do not have to wait.',
  'Short tummy time on your chest counts.',
  'Four weeks. You have learned a great deal about this baby.',
  'Gentle pelvic floor squeezes can start when you feel ready.',
  'Write down one thing you want to remember from this month.',
  'Your baby may start to watch your face for longer now.',
  'Keep the vaccine card and the discharge papers in one place.',
  'If relatives give advice, keep what helps and let the rest go.',
  'Look ahead to the six-week check for you and the baby.',
  'Five weeks. A first real smile may be coming soon.',
  'Ask your doctor about what is safe for you as you move more.',
  'Sleep still comes in pieces. That is normal at this age.',
  'Think about what support you want once the 40 days end.',
  'Tomorrow is day 40. Be kind to yourself about how it went.',
  'Day 40. You and your baby have come a long way together.',
];

/// Her day since the birth (day 1 = the birth day).
int ppDinDay([ChildProfileStore? c]) => (c ?? ChildProfileStore.instance).ageInDays + 1;

/// The Din by din pages with her current range first. Other tabs untouched.
List<PpPage> ppDinOrder(List<PpPage> pages, {int? day}) {
  final d = day ?? ppDinDay();
  String? lead;
  for (final (from, to, id) in kPpDinRanges) {
    if (d >= from && d <= to) lead = id;
  }
  if (d > 40) lead = kPpDinAfterPageId;
  final i = pages.indexWhere((p) => p.id == lead);
  if (i <= 0) return pages;
  return [pages[i], ...pages.sublist(0, i), ...pages.sublist(i + 1)];
}

/// Today's card for the Din by din tab, or null outside it or after day 40.
({int day, String line})? ppDinToday(String tabId, {int? day}) {
  if (tabId != kPpDinTabId) return null;
  // No birthday saved: no day to count (FD7). The tab's shelf asks for it.
  if (day == null && !ppDinKnown()) return null;
  final d = day ?? ppDinDay();
  if (d < 1 || d > kPpDinLines.length) return null;
  return (day: d, line: kPpDinLines[d - 1]);
}

class PpDinTodayCard extends StatelessWidget {
  const PpDinTodayCard({super.key, required this.day, required this.line, required this.p});
  final int day;
  final String line;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('pp_din_today'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('DAY $day OF 40',
              style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action)),
          const SizedBox(height: 6),
          Text(line, style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w500, height: 1.35, color: p.ink1)),
        ]),
      );
}

// =============================================================================
//  No birthday yet, and after the forty days (door plan 06, FD7 and FD3)
// =============================================================================

/// ⚠️ A DAY WE CAN ACTUALLY COUNT (FD7). With no child saved, the seeded
/// date of birth is today, so the card said "Day 1 of 40" for ever. A day
/// count needs a real birthday; until then the tab asks for one.
bool ppDinKnown([ChildProfileStore? c]) => (c ?? ChildProfileStore.instance).hasRealChild;

/// True on the Day by day tab once the forty days are done (FD3).
bool ppDinAfter(String tabId, {int? day}) =>
    tabId == kPpDinTabId && (day ?? ppDinDay()) > kPpDinLines.length;

/// The doors the after-forty line points on to (FD3): name -> surface.
/// Each opens on its own first tab for his age.
const List<(String, String)> kPpDinOnward = [
  ('Feeding', 'pp_section/parenting_feeding'),
  ('Sleep', 'pp_section/parenting_sleep'),
  ('Development', 'pp_section/parenting_development'),
];

/// "Your forty days start the day he's born", and a button to add him.
class PpDinNoBirthdayCard extends StatelessWidget {
  const PpDinNoBirthdayCard({super.key, required this.p, required this.onAdd});
  final V2Palette p;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final kid = ChildProfileStore.instance;
    return Container(
      key: const ValueKey('pp_din_no_birthday'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text("Your forty days start the day ${kid.they}'s born.",
            style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w500, height: 1.35, color: p.ink1)),
        const SizedBox(height: 6),
        Text('Tell us ${kid.their} birthday and this page follows you day by day.',
            style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
        const SizedBox(height: 12),
        FilledButton(
          key: const ValueKey('pp_din_add_birthday'),
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            backgroundColor: p.ink1,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
          child: Text('Add ${kid.their} birthday',
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
        ),
      ]),
    );
  }
}

/// "Your forty days are done", with the three doors as links (FD3).
class PpDinAfterCard extends StatelessWidget {
  const PpDinAfterCard({super.key, required this.p, required this.onSurface});
  final V2Palette p;
  final void Function(String surfaceId) onSurface;

  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('pp_din_after'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your forty days are done.',
              style: pvFraunces(fontSize: 18, fontWeight: FontWeight.w500, height: 1.35, color: p.ink1)),
          const SizedBox(height: 6),
          Text('What comes next lives in three places. Your own recovery carries '
              'on, on the Your recovery tab.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final (name, surface) in kPpDinOnward)
              OutlinedButton(
                key: ValueKey('pp_din_onward_$name'),
                onPressed: () => onSurface(surface),
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.ink1,
                  side: BorderSide(color: p.line),
                  shape: const StadiumBorder(),
                ),
                child: Text(name,
                    style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink1)),
              ),
          ]),
        ]),
      );
}
