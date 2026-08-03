// =============================================================================
//  veda_suggestions - the doc's stage-wise "Quick Question Cards"
// -----------------------------------------------------------------------------
//  Suggested questions that appear on the Ask Veda home BEFORE the mother types,
//  grouped by life-stage (Pregnancy → Newborn → Toddler → Parenting), so she can
//  just tap one. Pregnancy is the live stage now (its questions all resolve to a
//  real showcase / retrieval answer); the later stages are the journey ahead and
//  render lighter with a "soon" tag (tapping just gives the honest "not yet").
//
//  The Pregnancy questions are deliberately worded so they contain a real match
//  term - the 5 showcase ones hit their structured card; papaya/back-pain/
//  hospital-bag resolve via the whole-app retrieval.
// =============================================================================

import '../localization/app_language.dart';

class VedaSuggestionSection {
  const VedaSuggestionSection({
    required this.title,
    required this.emoji,
    required this.questions,
    this.active = true,
  });

  final LocalizedText title;
  final String emoji;
  final List<LocalizedText> questions;
  final bool active; // false = a future life-stage (shown lighter + "soon")
}

const List<VedaSuggestionSection> kVedaSuggestions = [
  // --- Pregnancy (the live stage) -------------------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Pregnancy', hi: 'गर्भावस्था'),
    emoji: '🤰',
    active: true,
    questions: [
      LocalizedText(
          en: 'When should I have my anomaly scan?',
          hi: 'मेरा anomaly scan कब होना चाहिए?'),
      LocalizedText(
          en: 'What are the early signs of labour?',
          hi: 'प्रसव के शुरुआती संकेत क्या होते हैं?'),
      LocalizedText(
          en: 'What foods boost my iron?',
          hi: 'Iron बढ़ाने के लिए क्या खाऊँ?'),
      LocalizedText(
          en: "What's the best sleeping position?",
          hi: 'सोने की सबसे अच्छी मुद्रा क्या है?'),
      LocalizedText(
          en: 'What should I do about reduced movements?',
          hi: 'हलचल कम हो तो क्या करूँ?'),
      LocalizedText(
          en: 'Can I eat papaya in pregnancy?',
          hi: 'क्या गर्भावस्था में पपीता खा सकती हूँ?'),
      LocalizedText(
          en: 'I have back pain - what helps?',
          hi: 'मुझे कमर दर्द है — क्या मदद करेगा?'),
      LocalizedText(
          en: 'What should I pack in my hospital bag?',
          hi: 'अस्पताल बैग में क्या रखूँ?'),
    ],
  ),
  // --- Newborn (coming as the journey grows) --------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Newborn', hi: 'नवजात'),
    emoji: '👶',
    active: false,
    questions: [
      LocalizedText(
          en: 'How often should I feed my newborn?',
          hi: 'नवजात को कितनी बार दूध पिलाऊँ?'),
      LocalizedText(
          en: 'How much should a newborn sleep?',
          hi: 'नवजात को कितना सोना चाहिए?'),
      LocalizedText(
          en: 'Why does my baby cry so much?',
          hi: 'मेरा शिशु इतना क्यों रोता है?'),
      LocalizedText(
          en: 'Is my baby gaining enough weight?',
          hi: 'क्या मेरे शिशु का वज़न ठीक बढ़ रहा है?'),
    ],
  ),
  // --- Toddler --------------------------------------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Toddler', hi: 'छोटा बच्चा'),
    emoji: '🧒',
    active: false,
    questions: [
      LocalizedText(
          en: 'How do I handle toddler tantrums?',
          hi: 'छोटे बच्चे के नख़रे कैसे सँभालूँ?'),
      LocalizedText(
          en: 'When should my toddler start talking?',
          hi: 'मेरा बच्चा कब बोलना शुरू करेगा?'),
      LocalizedText(
          en: 'How do I start potty training?',
          hi: 'पॉटी ट्रेनिंग कैसे शुरू करूँ?'),
    ],
  ),
  // --- Parenting ------------------------------------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Parenting', hi: 'परवरिश'),
    emoji: '👪',
    active: false,
    questions: [
      LocalizedText(
          en: 'How much screen time is okay?',
          hi: 'कितना स्क्रीन टाइम ठीक है?'),
      LocalizedText(
          en: 'How do I get my child ready for school?',
          hi: 'अपने बच्चे को स्कूल के लिए कैसे तैयार करूँ?'),
      LocalizedText(
          en: 'How do I manage difficult behaviour?',
          hi: 'मुश्किल व्यवहार कैसे सँभालूँ?'),
    ],
  ),
];
