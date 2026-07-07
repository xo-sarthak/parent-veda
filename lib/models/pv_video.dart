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
    title: LocalizedText(en: 'Your First Trimester', hi: 'Aapki Pehli Trimester'),
    reason: LocalizedText(
        en: 'A gentle look at what is happening in these early weeks.',
        hi: 'In shuruaati hafton mein kya ho raha hai, ek pyaari jhalak.'),
  ),
  PvVideo(
    id: 'rec_scan1',
    category: VideoCategory.recommended,
    weekStart: 6,
    weekEnd: 10,
    duration: '3 min',
    title: LocalizedText(en: 'Your First Scan', hi: 'Aapka Pehla Scan'),
    reason: LocalizedText(
        en: 'What the first ultrasound looks for, and how to prepare.',
        hi: 'Pehla ultrasound kya dekhta hai, aur kaise taiyaari karein.'),
  ),
  PvVideo(
    id: 'rec_sound',
    category: VideoCategory.recommended,
    weekStart: 18,
    weekEnd: 27,
    duration: '5 min',
    title: LocalizedText(
        en: 'How Babies Respond to Sound', hi: 'Baby Awaaz Par Kaise React Karte Hain'),
    reason: LocalizedText(
        en: 'Your baby is increasingly responsive to sounds at this stage.',
        hi: 'Is stage par aapka baby awaazon par zyada react karne lagta hai.'),
  ),
  PvVideo(
    id: 'rec_movement',
    category: VideoCategory.recommended,
    weekStart: 24,
    weekEnd: 31,
    duration: '4 min',
    title: LocalizedText(en: 'Feeling Your Baby Move', hi: 'Baby Ki Harkat Mehsoos Karna'),
    reason: LocalizedText(
        en: 'Getting to know your baby\'s movement pattern.',
        hi: 'Apne baby ke movement pattern ko jaan-na.'),
  ),
  PvVideo(
    id: 'rec_labour',
    category: VideoCategory.recommended,
    weekStart: 32,
    weekEnd: 40,
    duration: '6 min',
    title: LocalizedText(en: 'Getting Ready for Labour', hi: 'Labour Ke Liye Taiyaari'),
    reason: LocalizedText(
        en: 'Signs to watch for as your due date comes closer.',
        hi: 'Due date paas aane par kin baaton par dhyan dein.'),
  ),

  // ---- Learn a skill --------------------------------------------------------
  PvVideo(
    id: 'skill_kegel',
    category: VideoCategory.skill,
    duration: '3 min',
    title: LocalizedText(en: 'Kegel Exercises', hi: 'Kegel Exercises'),
    reason: LocalizedText(
        en: 'A gentle daily practice for your pelvic floor.',
        hi: 'Aapke pelvic floor ke liye ek halka rozaana abhyas.'),
  ),
  PvVideo(
    id: 'skill_breathing',
    category: VideoCategory.skill,
    duration: '4 min',
    title: LocalizedText(en: 'Breathing for Calm', hi: 'Shaanti Ke Liye Saans'),
    reason: LocalizedText(
        en: 'Simple breathing to ease tension any time of day.',
        hi: 'Kisi bhi waqt tanaav kam karne ke liye aasaan saans.'),
  ),
  PvVideo(
    id: 'skill_swaddle',
    category: VideoCategory.skill,
    weekStart: 28,
    duration: '3 min',
    title: LocalizedText(en: 'How to Swaddle', hi: 'Swaddle Kaise Karein'),
    reason: LocalizedText(
        en: 'A cosy, secure wrap for your newborn.',
        hi: 'Aapke newborn ke liye ek aaraamdayak, surakshit lapet.'),
  ),
  PvVideo(
    id: 'skill_bag',
    category: VideoCategory.skill,
    weekStart: 30,
    duration: '5 min',
    title: LocalizedText(en: 'Packing Your Hospital Bag', hi: 'Hospital Bag Kaise Packein'),
    reason: LocalizedText(
        en: 'What to pack for you, your baby and your partner.',
        hi: 'Aapke, baby aur partner ke liye kya pack karein.'),
  ),

  // ---- Expert explains ------------------------------------------------------
  PvVideo(
    id: 'expert_anomaly',
    category: VideoCategory.expert,
    weekStart: 16,
    weekEnd: 24,
    duration: '5 min',
    title: LocalizedText(en: 'Understanding the Anomaly Scan', hi: 'Anomaly Scan Ko Samajhna'),
    reason: LocalizedText(
        en: 'What this detailed scan checks, explained simply.',
        hi: 'Yeh vistrit scan kya check karta hai, aasaan shabdon mein.'),
  ),
  PvVideo(
    id: 'expert_gdm',
    category: VideoCategory.expert,
    weekStart: 22,
    weekEnd: 32,
    duration: '4 min',
    title: LocalizedText(en: 'About Gestational Diabetes', hi: 'Gestational Diabetes Ke Baare Mein'),
    reason: LocalizedText(
        en: 'What it is and how it is usually managed.',
        hi: 'Yeh kya hai aur aam tor par ise kaise sambhaala jaata hai.'),
  ),
  PvVideo(
    id: 'expert_labour',
    category: VideoCategory.expert,
    weekStart: 28,
    duration: '6 min',
    title: LocalizedText(en: 'Labour, Explained', hi: 'Labour, Samjhaaya Gaya'),
    reason: LocalizedText(
        en: 'A doctor gently walks through what to expect.',
        hi: 'Ek doctor pyaar se batate hain kya expect karein.'),
  ),

  // ---- Birth preparation (week 30+) ----------------------------------------
  PvVideo(
    id: 'birth_signs',
    category: VideoCategory.birth,
    weekStart: 30,
    duration: '4 min',
    title: LocalizedText(en: 'Signs of Labour', hi: 'Labour Ke Sanket'),
    reason: LocalizedText(
        en: 'How to tell when labour may be beginning.',
        hi: 'Kaise pehchaanein ki labour shuru ho raha hai.'),
  ),
  PvVideo(
    id: 'birth_pain',
    category: VideoCategory.birth,
    weekStart: 30,
    duration: '5 min',
    title: LocalizedText(en: 'Pain Relief Options', hi: 'Dard Kam Karne Ke Vikalp'),
    reason: LocalizedText(
        en: 'The choices available to you during birth.',
        hi: 'Janm ke dauraan aapke paas kaunse vikalp hain.'),
  ),

  // ---- Newborn preparation (week 30+) --------------------------------------
  PvVideo(
    id: 'newborn_feed',
    category: VideoCategory.newborn,
    weekStart: 30,
    duration: '5 min',
    title: LocalizedText(en: 'Newborn Feeding Basics', hi: 'Newborn Feeding Ki Buniyaad'),
    reason: LocalizedText(
        en: 'Getting started with feeding your baby.',
        hi: 'Apne baby ko feed karna shuru karna.'),
  ),
  PvVideo(
    id: 'newborn_sleep',
    category: VideoCategory.newborn,
    weekStart: 30,
    duration: '3 min',
    title: LocalizedText(en: 'Safe Sleep for Newborns', hi: 'Newborn Ke Liye Surakshit Neend'),
    reason: LocalizedText(
        en: 'Simple steps for safer baby sleep.',
        hi: 'Baby ki surakshit neend ke liye aasaan kadam.'),
  ),
];
