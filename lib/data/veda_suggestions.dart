// =============================================================================
//  veda_suggestions — the doc's stage-wise "Quick Question Cards"
// -----------------------------------------------------------------------------
//  Suggested questions that appear on the Ask Veda home BEFORE the mother types,
//  grouped by life-stage (Pregnancy → Newborn → Toddler → Parenting), so she can
//  just tap one. Pregnancy is the live stage now (its questions all resolve to a
//  real showcase / retrieval answer); the later stages are the journey ahead and
//  render lighter with a "soon" tag (tapping just gives the honest "not yet").
//
//  The Pregnancy questions are deliberately worded so they contain a real match
//  term — the 5 showcase ones hit their structured card; papaya/back-pain/
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
    title: LocalizedText(en: 'Pregnancy', hi: 'Pregnancy'),
    emoji: '🤰',
    active: true,
    questions: [
      LocalizedText(
          en: 'When should I have my anomaly scan?',
          hi: 'Mera anomaly scan kab hona chahiye?'),
      LocalizedText(
          en: 'What are the early signs of labour?',
          hi: 'Labour ke early signs kya hote hain?'),
      LocalizedText(
          en: 'What foods boost my iron?',
          hi: 'Iron badhane ke liye kya khaaun?'),
      LocalizedText(
          en: "What's the best sleeping position?",
          hi: 'Sone ki best position kya hai?'),
      LocalizedText(
          en: 'What should I do about reduced movements?',
          hi: 'Reduced movements hon to kya karun?'),
      LocalizedText(
          en: 'Can I eat papaya in pregnancy?',
          hi: 'Kya pregnancy mein papaya kha sakti hoon?'),
      LocalizedText(
          en: 'I have back pain — what helps?',
          hi: 'Mujhe kamar dard hai — kya help karega?'),
      LocalizedText(
          en: 'What should I pack in my hospital bag?',
          hi: 'Hospital bag mein kya pack karun?'),
    ],
  ),
  // --- Newborn (coming as the journey grows) --------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Newborn', hi: 'Newborn'),
    emoji: '👶',
    active: false,
    questions: [
      LocalizedText(
          en: 'How often should I feed my newborn?',
          hi: 'Newborn ko kitni baar feed karun?'),
      LocalizedText(
          en: 'How much should a newborn sleep?',
          hi: 'Newborn ko kitna sona chahiye?'),
      LocalizedText(
          en: 'Why does my baby cry so much?',
          hi: 'Mera baby itna kyun rota hai?'),
      LocalizedText(
          en: 'Is my baby gaining enough weight?',
          hi: 'Kya mera baby theek weight gain kar raha hai?'),
    ],
  ),
  // --- Toddler --------------------------------------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Toddler', hi: 'Toddler'),
    emoji: '🧒',
    active: false,
    questions: [
      LocalizedText(
          en: 'How do I handle toddler tantrums?',
          hi: 'Toddler ke tantrums kaise handle karun?'),
      LocalizedText(
          en: 'When should my toddler start talking?',
          hi: 'Mera toddler kab bolna shuru karega?'),
      LocalizedText(
          en: 'How do I start potty training?',
          hi: 'Potty training kaise shuru karun?'),
    ],
  ),
  // --- Parenting ------------------------------------------------------------
  VedaSuggestionSection(
    title: LocalizedText(en: 'Parenting', hi: 'Parenting'),
    emoji: '👪',
    active: false,
    questions: [
      LocalizedText(
          en: 'How much screen time is okay?',
          hi: 'Kitna screen time theek hai?'),
      LocalizedText(
          en: 'How do I get my child ready for school?',
          hi: 'Apne bachche ko school ke liye kaise taiyaar karun?'),
      LocalizedText(
          en: 'How do I manage difficult behaviour?',
          hi: 'Difficult behaviour kaise manage karun?'),
    ],
  ),
];
