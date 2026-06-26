// =============================================================================
//  Trimester Tips — 2–3 gentle, researched tips per week (bilingual)
// -----------------------------------------------------------------------------
//  Seeded for the preview weeks (4 & 5). Add more weeks here and the Trimester
//  Tips card appears for them automatically (buildWeekCards only shows the card
//  for weeks present in this map — no blank pages for unseeded weeks).
//  Educational + supportive only; never a substitute for a doctor's advice.
// =============================================================================

import '../localization/app_language.dart';

/// A richer tip for the V2 weekly flow — a title + a short explanation (shown in
/// a small pop-up on tap), grouped by trimester.
class TrimesterTip {
  const TrimesterTip(
      {required this.title, required this.body, this.emoji = '💡'});
  final LocalizedText title;
  final LocalizedText body;
  final String emoji;
}

/// V2 weekly-flow tips, grouped by trimester (1/2/3). Seeded for the second
/// trimester (shown on week 20); add the first/third the same way and the
/// "Trimester tips" section fills in automatically.
const Map<int, List<TrimesterTip>> kTrimesterTipsV2 = {
  2: [
    TrimesterTip(
      emoji: '🔍',
      title: LocalizedText(
          en: 'Make the most of your anomaly scan',
          hi: 'Apne anomaly scan ka poora laabh lein'),
      body: LocalizedText(
          en: "Around weeks 18–22, this detailed scan checks your baby's heart, brain, spine and organs, and how they're growing. You can usually bring your partner — and it's perfectly fine to ask the sonographer to explain what they're measuring. Most findings are reassuring.",
          hi: 'Lagbhag 18–22 hafte mein yeh detailed scan baby ke dil, dimaag, reedh aur organs ki growth check karta hai. Aap apne partner ko saath la sakti hain — aur sonographer se poochna bilkul theek hai ki woh kya maap rahe hain. Zyaadatar findings rahat dene wale hote hain.'),
    ),
    TrimesterTip(
      emoji: '🛌',
      title: LocalizedText(
          en: 'Start sleeping on your side',
          hi: 'Karwat par sona shuru karein'),
      body: LocalizedText(
          en: "As your bump grows, sleeping on your side — the left is ideal — helps blood and nutrients reach your baby comfortably. A pillow between your knees or under the bump makes it easier. If you wake up on your back, don't worry; just settle back onto your side.",
          hi: 'Jaise-jaise bump badhta hai, karwat (khaaskar baayein) par sona blood aur nutrients ko baby tak aaram se pahunchne mein madad karta hai. Ghutno ke beech ya bump ke neeche takiya rakhne se aasaani hoti hai. Agar peeth ke bal jaag jaayein to chinta na karein — bas wapas karwat par aa jaayein.'),
    ),
    TrimesterTip(
      emoji: '🥗',
      title: LocalizedText(
          en: 'Keep iron and calcium on your plate',
          hi: 'Iron aur calcium apni thaali mein rakhein'),
      body: LocalizedText(
          en: "Your body is busy building your baby's bones and blood right now. Lean on iron (leafy greens, dal, jaggery) and calcium (milk, curd, paneer), and pair iron-rich foods with a little vitamin C — like lemon or orange — to absorb more. Keep taking any supplements your doctor has prescribed.",
          hi: 'Abhi aapka shareer baby ki haddiyaan aur khoon bana raha hai. Iron (hari sabziyaan, dal, gud) aur calcium (doodh, dahi, paneer) lein, aur iron wale khaane ke saath thoda vitamin C — jaise nimbu ya santra — lein taaki zyaada absorb ho. Doctor ne jo supplements diye hain woh lete rahein.'),
    ),
  ],
};

const Map<int, List<LocalizedText>> kTrimesterTips = {
  4: [
    LocalizedText(
        en: "Take folic acid every day — it protects your baby's developing spine and brain.",
        hi: 'Rozaana folic acid lein — yeh baby ki banti reedh aur dimaag ki raksha karta hai.'),
    LocalizedText(
        en: 'Avoid alcohol, smoking and raw or undercooked foods.',
        hi: 'Sharaab, dhoomrapaan aur kacche ya adhpake khaane se bachein.'),
    LocalizedText(
        en: 'Book your first antenatal visit with your doctor.',
        hi: 'Apne doctor ke saath pehli antenatal visit book karein.'),
  ],
  5: [
    LocalizedText(
        en: 'Eat small, frequent meals to ease early nausea.',
        hi: 'Shuruaati matli kam karne ke liye thode-thode, baar-baar khaayein.'),
    LocalizedText(
        en: 'Sip water through the day and rest whenever you feel tired.',
        hi: 'Din bhar paani piyein aur jab bhi thakaan ho aaram karein.'),
    LocalizedText(
        en: 'Note the first day of your last period — it helps your doctor date the pregnancy.',
        hi: 'Apne pichhle period ka pehla din note karein — isse doctor pregnancy ki dating mein madad milti hai.'),
  ],
  20: [
    LocalizedText(
        en: "Don't miss your anomaly scan (around 18–22 weeks) — it checks baby's growth and organs.",
        hi: 'Apna anomaly scan (lagbhag 18–22 hafte) miss na karein — yeh baby ki growth aur organs check karta hai.'),
    LocalizedText(
        en: 'Start sleeping on your side as your bump grows.',
        hi: 'Bump badhne ke saath karwat (side) par sona shuru karein.'),
    LocalizedText(
        en: 'Keep up iron- and calcium-rich foods.',
        hi: 'Iron aur calcium se bharpoor khaana jaari rakhein.'),
  ],
};
