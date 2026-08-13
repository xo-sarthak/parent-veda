// =============================================================================
//  PvVideo - "Watch & Learn" contextual learning videos
// -----------------------------------------------------------------------------
//  Not a video library - the right video at the right time. Metadata is authored
//  in Dart (bilingual); real playback (videoUrl) is wired later, so for now the
//  player is a gentle "coming soon". Each video answers "why this matters now".
// =============================================================================

import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../theme/app_theme.dart';

enum VideoCategory { recommended, skill, expert, birth, newborn }

class PvVideo {
  const PvVideo({
    required this.id,
    required this.title,
    required this.reason,
    required this.duration,
    required this.category,
    this.weekStart = 4,
    this.weekEnd = 40,
  });

  final String id;
  final LocalizedText title;
  final LocalizedText reason; // "why this matters now"
  final String duration;
  final VideoCategory category;
  final int weekStart;
  final int weekEnd;

  bool matchesWeek(int w) => w >= weekStart && w <= weekEnd;
}

class VideoMeta {
  const VideoMeta(this.color, this.icon);
  final Color color;
  final IconData icon;
}

const Map<VideoCategory, VideoMeta> kVideoMeta = {
  VideoCategory.recommended:
      VideoMeta(AppTheme.primary500, Icons.auto_awesome_rounded),
  VideoCategory.skill:
      VideoMeta(Color(0xFF4F7A52), Icons.fitness_center_rounded),
  VideoCategory.expert:
      VideoMeta(Color(0xFF4A7BC8), Icons.health_and_safety_rounded),
  VideoCategory.birth:
      VideoMeta(AppTheme.secondary500, Icons.pregnant_woman_rounded),
  VideoCategory.newborn:
      VideoMeta(AppTheme.tertiary500, Icons.child_care_rounded),
};

VideoMeta videoMeta(VideoCategory c) =>
    kVideoMeta[c] ?? const VideoMeta(AppTheme.primary500, Icons.play_circle_rounded);

const List<PvVideo> kVideos = [
  // ---- Recommended (week-ranged) -------------------------------------------
  PvVideo(
    id: 'rec_t1',
    category: VideoCategory.recommended,
    weekStart: 4,
    weekEnd: 12,
    duration: '4 min',
    title: LocalizedText(en: 'Your First Trimester', hi: 'आपकी पहली तिमाही'),
    reason: LocalizedText(
        en: 'A gentle look at what is happening in these early weeks.',
        hi: 'इन शुरुआती हफ़्तों में क्या हो रहा है, एक हल्की सी झलक।'),
  ),
  PvVideo(
    id: 'rec_scan1',
    category: VideoCategory.recommended,
    weekStart: 6,
    weekEnd: 10,
    duration: '3 min',
    title: LocalizedText(en: 'Your First Scan', hi: 'आपका पहला स्कैन'),
    reason: LocalizedText(
        en: 'What the first ultrasound looks for, and how to prepare.',
        hi: 'पहला अल्ट्रासाउंड क्या देखता है, और आप कैसे तैयार हो सकती हैं।'),
  ),
  PvVideo(
    id: 'rec_sound',
    category: VideoCategory.recommended,
    weekStart: 18,
    weekEnd: 27,
    duration: '5 min',
    title: LocalizedText(
        en: 'How Babies Respond to Sound', hi: 'आवाज़ सुनकर शिशु कैसे जवाब देते हैं'),
    reason: LocalizedText(
        en: 'Your baby is increasingly responsive to sounds at this stage.',
        hi: 'इस पड़ाव पर शिशु आवाज़ों पर और ज़्यादा जवाब देने लगते हैं।'),
  ),
  PvVideo(
    id: 'rec_movement',
    category: VideoCategory.recommended,
    weekStart: 24,
    weekEnd: 31,
    duration: '4 min',
    title: LocalizedText(en: 'Feeling Your Baby Move', hi: 'शिशु की हलचल महसूस करना'),
    reason: LocalizedText(
        en: 'Getting to know your baby\'s movement pattern.',
        hi: 'शिशु की हलचल का तरीक़ा पहचानना।'),
  ),
  PvVideo(
    id: 'rec_labour',
    category: VideoCategory.recommended,
    weekStart: 32,
    weekEnd: 40,
    duration: '6 min',
    title: LocalizedText(en: 'Getting Ready for Labour', hi: 'प्रसव के लिए तैयारी'),
    reason: LocalizedText(
        en: 'Signs to watch for as your due date comes closer.',
        hi: 'डिलीवरी की तारीख़ पास आते-आते किन बातों पर ध्यान देना है।'),
  ),

  // ---- Learn a skill --------------------------------------------------------
  PvVideo(
    id: 'skill_kegel',
    category: VideoCategory.skill,
    duration: '3 min',
    title: LocalizedText(en: 'Kegel Exercises', hi: 'Kegel Exercises'),
    reason: LocalizedText(
        en: 'A gentle daily practice for your pelvic floor.',
        hi: 'आपके पेल्विक फ़्लोर के लिए एक हल्का सा रोज़ का अभ्यास।'),
  ),
  PvVideo(
    id: 'skill_breathing',
    category: VideoCategory.skill,
    duration: '4 min',
    title: LocalizedText(en: 'Breathing for Calm', hi: 'शांति के लिए साँस'),
    reason: LocalizedText(
        en: 'Simple breathing to ease tension any time of day.',
        hi: 'दिन में कभी भी तनाव कम करने के लिए आसान साँस।'),
  ),
  PvVideo(
    id: 'skill_swaddle',
    category: VideoCategory.skill,
    weekStart: 28,
    duration: '3 min',
    title: LocalizedText(en: 'How to Swaddle', hi: 'शिशु को कैसे लपेटें'),
    reason: LocalizedText(
        en: 'A cosy, secure wrap for your newborn.',
        hi: 'नवजात के लिए एक आरामदायक और सुरक्षित लपेट।'),
  ),
  PvVideo(
    id: 'skill_bag',
    category: VideoCategory.skill,
    weekStart: 30,
    duration: '5 min',
    title: LocalizedText(en: 'Packing Your Hospital Bag', hi: 'अस्पताल का बैग तैयार करना'),
    reason: LocalizedText(
        en: 'What to pack for you, your baby and your partner.',
        hi: 'आपके, शिशु और आपके साथी के लिए क्या रखना है।'),
  ),

  // ---- Expert explains ------------------------------------------------------
  PvVideo(
    id: 'expert_anomaly',
    category: VideoCategory.expert,
    weekStart: 16,
    weekEnd: 24,
    duration: '5 min',
    title: LocalizedText(en: 'Understanding the Anomaly Scan', hi: 'Anomaly scan को समझना'),
    reason: LocalizedText(
        en: 'What this detailed scan checks, explained simply.',
        hi: 'यह पूरा स्कैन क्या-क्या देखता है, आसान शब्दों में।'),
  ),
  PvVideo(
    id: 'expert_gdm',
    category: VideoCategory.expert,
    weekStart: 22,
    weekEnd: 32,
    duration: '4 min',
    title: LocalizedText(en: 'About Gestational Diabetes', hi: 'Gestational diabetes के बारे में'),
    reason: LocalizedText(
        en: 'What it is and how it is usually managed.',
        hi: 'यह क्या है और आम तौर पर इसे कैसे सँभाला जाता है।'),
  ),
  PvVideo(
    id: 'expert_labour',
    category: VideoCategory.expert,
    weekStart: 28,
    duration: '6 min',
    title: LocalizedText(en: 'Labour, Explained', hi: 'प्रसव, आसान शब्दों में'),
    reason: LocalizedText(
        en: 'A doctor gently walks through what to expect.',
        hi: 'एक डॉक्टर शांति से बताते हैं कि आगे क्या होने वाला है।'),
  ),

  // ---- Birth preparation (week 30+) ----------------------------------------
  PvVideo(
    id: 'birth_signs',
    category: VideoCategory.birth,
    weekStart: 30,
    duration: '4 min',
    title: LocalizedText(en: 'Signs of Labour', hi: 'प्रसव के संकेत'),
    reason: LocalizedText(
        en: 'How to tell when labour may be beginning.',
        hi: 'कैसे पहचानें कि प्रसव शुरू हो सकता है।'),
  ),
  PvVideo(
    id: 'birth_pain',
    category: VideoCategory.birth,
    weekStart: 30,
    duration: '5 min',
    title: LocalizedText(en: 'Pain Relief Options', hi: 'दर्द कम करने के तरीक़े'),
    reason: LocalizedText(
        en: 'The choices available to you during birth.',
        hi: 'प्रसव के दौरान आपके पास कौन-कौन से रास्ते हैं।'),
  ),

  // ---- Newborn preparation (week 30+) --------------------------------------
  PvVideo(
    id: 'newborn_feed',
    category: VideoCategory.newborn,
    weekStart: 30,
    duration: '5 min',
    title: LocalizedText(en: 'Newborn Feeding Basics', hi: 'नवजात को दूध पिलाने की बुनियादी बातें'),
    reason: LocalizedText(
        en: 'Getting started with feeding your baby.',
        hi: 'शिशु को दूध पिलाने की शुरुआत।'),
  ),
  PvVideo(
    id: 'newborn_sleep',
    category: VideoCategory.newborn,
    weekStart: 30,
    duration: '3 min',
    title: LocalizedText(en: 'Safe Sleep for Newborns', hi: 'नवजात के लिए सुरक्षित नींद'),
    reason: LocalizedText(
        en: 'Simple steps for safer baby sleep.',
        hi: 'शिशु की नींद को और सुरक्षित बनाने के आसान क़दम।'),
  ),
];
