// =============================================================================
//  Mother's Body Changes - week-by-week, in gentle biological sections
// -----------------------------------------------------------------------------
//  Richer, researched "what is changing in your body this week" content, broken
//  into small biological sections (hormones, womb, breasts…). Seeded for the
//  preview weeks (4 & 5); when a week is present here, the Mom's Journey card
//  renders these sections instead of the single physical-changes paragraph.
//  Educational + reassuring only - never diagnostic.
// =============================================================================

import '../localization/app_language.dart';

class BodyChange {
  const BodyChange(this.label, this.detail);
  final LocalizedText label;
  final LocalizedText detail;
}

const Map<int, List<BodyChange>> kBodyChanges = {
  4: [
    BodyChange(
      LocalizedText(en: 'Hormones', hi: 'हार्मोन'),
      LocalizedText(
          en: 'The pregnancy hormone hCG is rising - this is what a home test detects.',
          hi: 'गर्भावस्था का हार्मोन hCG बढ़ रहा है — यही घर का टेस्ट पकड़ता है।'),
    ),
    BodyChange(
      LocalizedText(en: 'Your womb', hi: 'आपकी बच्चेदानी'),
      LocalizedText(
          en: 'The tiny embryo is settling into your uterus lining; light spotting can be normal.',
          hi: 'नन्हा embryo आपकी बच्चेदानी की परत में बस रहा है; हल्की spotting सामान्य हो सकती है।'),
    ),
    BodyChange(
      LocalizedText(en: 'How you may feel', hi: 'कैसा लग सकता है'),
      LocalizedText(
          en: 'Often nothing obvious yet - perhaps mild cramps or slightly tender breasts.',
          hi: 'अक्सर अभी कुछ ख़ास नहीं — हल्की ऐंठन या स्तनों में हल्का खिंचाव हो सकता है।'),
    ),
    BodyChange(
      LocalizedText(en: 'Blood supply', hi: 'ख़ून की सप्लाई'),
      LocalizedText(
          en: 'Your body is beginning to make more blood to support your baby.',
          hi: 'आपका शरीर शिशु के लिए ज़्यादा ख़ून बनाना शुरू कर रहा है।'),
    ),
  ],
  5: [
    BodyChange(
      LocalizedText(en: 'Hormones', hi: 'हार्मोन'),
      LocalizedText(
          en: 'Progesterone and hCG keep rising, which can bring the first symptoms.',
          hi: 'Progesterone और hCG बढ़ते रहते हैं, जिससे पहले लक्षण आ सकते हैं।'),
    ),
    BodyChange(
      LocalizedText(en: 'Breasts', hi: 'स्तन'),
      LocalizedText(
          en: 'They may feel fuller, tingly or tender as milk ducts begin to form.',
          hi: 'ये भरे, झुनझुनाहट भरे या नरम लग सकते हैं जैसे milk ducts बनना शुरू होते हैं।'),
    ),
    BodyChange(
      LocalizedText(en: 'Energy', hi: 'ऊर्जा'),
      LocalizedText(
          en: 'Rising progesterone can leave you feeling unusually tired.',
          hi: 'बढ़ता Progesterone आपको बहुत ज़्यादा थका महसूस करा सकता है।'),
    ),
    BodyChange(
      LocalizedText(en: 'Nausea', hi: 'मतली'),
      LocalizedText(
          en: 'Early morning sickness may begin - small, frequent meals help.',
          hi: 'सुबह की मतली शुरू हो सकती है — थोड़ा-थोड़ा बार-बार खाना मदद करता है।'),
    ),
    BodyChange(
      LocalizedText(en: 'Your womb', hi: 'आपकी बच्चेदानी'),
      LocalizedText(
          en: 'Your uterus is still small (about a lemon) - no visible bump yet.',
          hi: 'आपकी बच्चेदानी अभी छोटी है (लगभग नींबू जितनी) — अभी बंप नहीं दिखेगा।'),
    ),
  ],
  20: [
    BodyChange(
      LocalizedText(en: 'Hormones', hi: 'हार्मोन'),
      LocalizedText(
          en: 'Levels are steadier now - many feel more energy in the second trimester.',
          hi: 'अब स्तर ज़्यादा स्थिर हैं — दूसरी तिमाही में कई लोगों को ज़्यादा ऊर्जा महसूस होती है।'),
    ),
    BodyChange(
      LocalizedText(en: 'Your bump', hi: 'आपका बंप'),
      LocalizedText(
          en: 'The top of your uterus reaches your belly button - your bump is clearly showing.',
          hi: 'आपकी बच्चेदानी का ऊपरी हिस्सा नाभि तक पहुँच जाता है — बंप साफ़ दिखने लगता है।'),
    ),
    BodyChange(
      LocalizedText(en: 'First movements', hi: 'पहली हलचल'),
      LocalizedText(
          en: 'You may feel the first gentle flutters (quickening) around now.',
          hi: 'आप इसी समय के आस-पास पहली हल्की हलचल (quickening) महसूस कर सकती हैं।'),
    ),
    BodyChange(
      LocalizedText(en: 'Body', hi: 'शरीर'),
      LocalizedText(
          en: 'More blood flow can bring a warm "glow", fuller hair, and occasional round-ligament twinges.',
          hi: 'ज़्यादा ख़ून के बहाव से एक गर्म "निखार", घने बाल, और कभी-कभी round-ligament खिंचाव आ सकता है।'),
    ),
  ],
};
