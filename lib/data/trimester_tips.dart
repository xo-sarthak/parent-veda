// =============================================================================
//  Trimester Tips - 2–3 gentle, researched tips per week (bilingual)
// -----------------------------------------------------------------------------
//  Seeded for the preview weeks (4 & 5). Add more weeks here and the Trimester
//  Tips card appears for them automatically (buildWeekCards only shows the card
//  for weeks present in this map - no blank pages for unseeded weeks).
//  Educational + supportive only; never a substitute for a doctor's advice.
// =============================================================================

import '../localization/app_language.dart';

/// A richer tip for the V2 weekly flow - a title + a short explanation (shown in
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
          hi: 'अपने anomaly scan का पूरा फ़ायदा लीजिए'),
      body: LocalizedText(
          en: "Around weeks 18–22, this detailed scan checks your baby's heart, brain, spine and organs, and how they're growing. You can usually bring your partner - and it's perfectly fine to ask the sonographer to explain what they're measuring. Most findings are reassuring.",
          hi: 'लगभग 18–22 हफ़्ते में यह विस्तृत स्कैन शिशु के दिल, दिमाग़, रीढ़ और अंगों की बढ़त जाँचता है। आप अपने साथी को साथ ला सकती हैं — और sonographer से यह पूछना बिलकुल ठीक है कि वे क्या माप रहे हैं। ज़्यादातर नतीजे राहत देने वाले होते हैं।'),
    ),
    TrimesterTip(
      emoji: '🛌',
      title: LocalizedText(
          en: 'Start sleeping on your side',
          hi: 'करवट पर सोना शुरू कीजिए'),
      body: LocalizedText(
          en: "As your bump grows, sleeping on your side - the left is ideal - helps blood and nutrients reach your baby comfortably. A pillow between your knees or under the bump makes it easier. If you wake up on your back, don't worry; just settle back onto your side.",
          hi: 'जैसे-जैसे बंप बढ़ता है, करवट (ख़ासकर बाईं) पर सोना ख़ून और पोषक तत्वों को शिशु तक आराम से पहुँचने में मदद करता है। घुटनों के बीच या बंप के नीचे तकिया रखने से आसानी होती है। अगर पीठ के बल जाग जाएँ तो चिंता मत कीजिए — बस वापस करवट पर आ जाइए।'),
    ),
    TrimesterTip(
      emoji: '🥗',
      title: LocalizedText(
          en: 'Keep iron and calcium on your plate',
          hi: 'Iron और Calcium अपनी थाली में रखिए'),
      body: LocalizedText(
          en: "Your body is busy building your baby's bones and blood right now. Lean on iron (leafy greens, dal, jaggery) and calcium (milk, curd, paneer), and pair iron-rich foods with a little vitamin C - like lemon or orange - to absorb more. Keep taking any supplements your doctor has prescribed.",
          hi: 'अभी आपका शरीर शिशु की हड्डियाँ और ख़ून बना रहा है। Iron (हरी सब्ज़ियाँ, दाल, गुड़) और Calcium (दूध, दही, पनीर) लीजिए, और Iron वाले खाने के साथ थोड़ा Vitamin C — जैसे नींबू या संतरा — लीजिए ताकि ज़्यादा सोखा जाए। डॉक्टर ने जो सप्लीमेंट दिए हैं वे लेते रहिए।'),
    ),
  ],
};

const Map<int, List<LocalizedText>> kTrimesterTips = {
  4: [
    LocalizedText(
        en: "Take folic acid every day - it protects your baby's developing spine and brain.",
        hi: 'रोज़ाना Folic acid लीजिए — यह शिशु की बनती रीढ़ और दिमाग़ की रक्षा करता है।'),
    LocalizedText(
        en: 'Avoid alcohol, smoking and raw or undercooked foods.',
        hi: 'शराब, धूम्रपान और कच्चे या अधपके खाने से बचिए।'),
    LocalizedText(
        en: 'Book your first antenatal visit with your doctor.',
        hi: 'अपने डॉक्टर के साथ पहली antenatal विज़िट बुक कीजिए।'),
  ],
  5: [
    LocalizedText(
        en: 'Eat small, frequent meals to ease early nausea.',
        hi: 'शुरुआती मतली कम करने के लिए थोड़ा-थोड़ा, बार-बार खाइए।'),
    LocalizedText(
        en: 'Sip water through the day and rest whenever you feel tired.',
        hi: 'दिन भर पानी पीजिए और जब भी थकान हो आराम कीजिए।'),
    LocalizedText(
        en: 'Note the first day of your last period - it helps your doctor date the pregnancy.',
        hi: 'अपने पिछले पीरियड का पहला दिन नोट कीजिए — इससे डॉक्टर को गर्भावस्था की तारीख़ तय करने में मदद मिलती है।'),
  ],
  20: [
    LocalizedText(
        en: "Don't miss your anomaly scan (around 18–22 weeks) - it checks baby's growth and organs.",
        hi: 'अपना anomaly scan (लगभग 18–22 हफ़्ते) मत छोड़िए — यह शिशु की बढ़त और अंग जाँचता है।'),
    LocalizedText(
        en: 'Start sleeping on your side as your bump grows.',
        hi: 'बंप बढ़ने के साथ करवट पर सोना शुरू कीजिए।'),
    LocalizedText(
        en: 'Keep up iron- and calcium-rich foods.',
        hi: 'Iron और Calcium से भरपूर खाना जारी रखिए।'),
  ],
};
