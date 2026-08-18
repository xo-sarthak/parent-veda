// =============================================================================
//  WeekFlowView - "V2" vertical week flow (week 20 preview, behind a toggle)
// -----------------------------------------------------------------------------
//  Re-flows the weekly content as ONE vertical scroll of sections instead of a
//  horizontal card swipe. Info sections show a brief; tapping opens a full-
//  screen, descriptive pop-up (carousels / tabs). Kept side-by-side with the
//  classic card layout via a Classic⟷New toggle on the weekly screen.
//
//  Sections: 1 Size hero · 2 Weekly video · 3 About baby (Baby Science + article)
//  · 4 For you (Mother / Health / Eat / To-do) · 5 What's next (Scans /
//  Milestones) · 6 This week's videos · 7 Share with partner.
// =============================================================================

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:share_plus/share_plus.dart';

import '../data/journey_milestones.dart';
import '../data/symptom_data.dart';
import '../data/trimester_tips.dart';
import '../data/week5_full_data.dart';
import '../data/week_articles_data.dart';
import '../services/narration_service.dart';
import '../widgets/narration/narrate_button.dart';
import '../services/article_store.dart';
import '../localization/app_language.dart';
import '../models/journey_node.dart';
import '../models/symptom.dart';
import '../models/week_content.dart';
import '../services/app_nav.dart';
import '../services/father_preview.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/week_cards/week_overview_card.dart';
import '../theme/pv_fonts.dart';

// TESTING-ONLY: when the Dad mode switch is on AND we're on week 20, the weekly
// flow re-voices its copy for the father (same content, read for/about her).
// Mother flow + every other week are unchanged. Strip with FatherPreview.
bool _fatherWeek(int week) => FatherPreview.instance.on && week == 20;

// Father (Slate) SKIN gate - now ALL weeks (the colour scheme rolled out to
// every week). CONTENT/copy stays week-20 via [_fatherWeek] until each week is
// re-voiced, so a non-week-20 father week shows the mother's per-week content in
// the Slate skin.
bool _fatherSkin(int week) => FatherPreview.instance.on;

// Slate palette for the father re-skin (mirrors the Father Daily screen). Only
// used where `_fatherWeek(...)` is true; the mother path never sees these.
const Color _fBg = Color(0xFFF4EFE8); // warm cream background
const Color _fLine = Color(0xFFECE5DA);
const Color _fInk = Color(0xFF22333B); // header ink
const Color _fMuted = Color(0xFF6A7B82);
const Color _fAccent = Color(0xFF2E5266); // deep slate (was purple/coral)
const Color _fAccent2 = Color(0xFFE0915B); // amber highlight

// Father serif header (Fraunces) - parked: the father weekly headings moved to
// the mother's sans font (plusJakartaSans). Kept for revert.
// ignore: unused_element
TextStyle _fSerif(double size, Color c, {FontWeight w = FontWeight.w600}) =>
    pvFraunces(
        fontSize: size, fontWeight: w, color: c, height: 1.18, letterSpacing: -0.2);

// ---------------------------------------------------------------------------
//  Week 5 — the FULL content doc, wired into the Standard weekly UI.
// ---------------------------------------------------------------------------
//  The Standard detail screens (Baby Science, Mother/Health/Diet, Trimester
//  Tips, Share-with-partner) are otherwise hard-coded to the week-20 preview.
//  These adapters map the complete Week 5 doc (week5_full_data.dart) into the
//  Standard widgets' own types, so week 5 shows EVERY section of the document
//  verbatim, in the finalized Standard layout. Every other week is unchanged.
//  Not applied in the father (Slate) preview, which keeps its own voice.
bool _isW5(int week) => week == 5;

const List<Color> _w5Tints = [
  Color(0xFFEDE7F6),
  Color(0xFFFDE7EC),
  Color(0xFFE6F4EA),
  Color(0xFFEAF1FB),
  Color(0xFFFFF3E0),
  Color(0xFFF9E7F3),
];

List<_Fact> _w5Science() {
  const emoji = ['🧠', '🫀', '🧬', '🌿', '🔗', '🙂'];
  final sc = week5Full.science;
  return [
    for (var i = 0; i < sc.length; i++)
      _Fact(emoji[i % emoji.length], _w5Tints[i % _w5Tints.length], sc[i].title, sc[i].body),
  ];
}

List<_Article> _w5BabyArticle() {
  final a = week5Full.about;
  return [
    _Article(const LocalizedText(en: 'In my words', hi: 'मेरी ज़ुबानी'), a.opening),
    _Article(const LocalizedText(en: 'How big am I', hi: 'अभी मेरा आकार कितना है'), a.howBig),
    _Article(const LocalizedText(en: "What's happening this week", hi: 'इस हफ़्ते क्या हो रहा है'), a.whatsHappening),
  ];
}

List<_Article> _w5MotherArticle() {
  final y = week5Full.you;
  return [
    _Article(const LocalizedText(en: 'How you might be feeling', hi: 'आप कैसा महसूस कर रही होंगी'), y.feeling),
    _Article(const LocalizedText(en: 'Your changing body', hi: 'आपका बदलता शरीर'), y.changingBody),
    _Article(const LocalizedText(en: 'Be kind to yourself', hi: 'ख़ुद के साथ नरमी बरतिए'), y.beKind),
  ];
}

List<_MotherTopic> _w5Topics() {
  const emoji = ['🌊', '💗', '🤰', '🍽️'];
  final h = week5Full.you.highlights;
  return [
    for (var i = 0; i < h.length; i++)
      _MotherTopic(emoji[i % emoji.length], h[i].title, h[i].teaser, h[i].body),
  ];
}

List<_Food> _w5Favour() {
  const emoji = ['🥬', '🫘', '🍊', '🌾', '🥛', '🥜', '🍌'];
  final f = week5Full.diet.favour;
  return [
    for (var i = 0; i < f.length; i++) _Food(emoji[i % emoji.length], f[i].title, f[i].body),
  ];
}

List<_Food> _w5Avoid() {
  const emoji = ['🥩', '🧀', '🐟', '☕', '🚫'];
  final f = week5Full.diet.avoid;
  return [
    for (var i = 0; i < f.length; i++) _Food(emoji[i % emoji.length], f[i].title, f[i].body),
  ];
}

Superfood _w5Superfood() {
  final sf = week5Full.diet.superfood;
  return Superfood(food: sf.food, benefit: sf.benefit, howToConsume: sf.tryAs);
}

List<TrimesterTip> _w5Tips() =>
    [for (final x in week5Full.tips) TrimesterTip(title: x.oneLine, body: x.readMore)];

// ---------------------------------------------------------------------------
//  Curated week-20 content (bilingual). Other weeks fall back gracefully.
// ---------------------------------------------------------------------------
class _Fact {
  const _Fact(this.emoji, this.bg, this.title, this.desc);
  final String emoji;
  final Color bg;
  final LocalizedText title;
  final LocalizedText desc;
}

// Distinct "did you know" trivia - kept separate from the article read so the
// two don't repeat each other.
const List<_Fact> _babyScience = [
  _Fact(
      '🧠',
      Color(0xFFF2E9FB),
      // Titles rewritten as complete sentences (card shows heading only now).
      LocalizedText(
          en: 'My brain is growing at an astonishing pace',
          hi: 'मेरा दिमाग़ ग़ज़ब की रफ़्तार से बढ़ रहा है'),
      LocalizedText(
          en: "I'm forming millions of new nerve connections every single day - my brain is working at an astonishing pace!",
          hi: 'हर दिन मेरे भीतर नसों के लाखों नए जोड़ बन रहे हैं — मेरा दिमाग़ ग़ज़ब की रफ़्तार से काम कर रहा है!')),
  _Fact(
      '🤏',
      Color(0xFFFCE3E6),
      LocalizedText(
          en: 'I can already curl my tiny fingers',
          hi: 'अब मेरी नन्ही उँगलियाँ मुड़ने भी लगी हैं'),
      LocalizedText(
          en: "I can curl my little fingers and sometimes grab the umbilical cord - I'm practising for our very first cuddles.",
          hi: 'मेरी नन्ही उँगलियाँ अब मुड़ जाती हैं और कभी-कभी गर्भनाल भी पकड़ में आ जाती है — यह हमारी पहली झप्पी की तैयारी है।')),
  _Fact(
      '🫧',
      Color(0xFFE6F0FA),
      LocalizedText(en: 'I get hiccups!', hi: 'मुझे हिचकी आती है!'),
      LocalizedText(
          en: "Sometimes you'll feel tiny rhythmic taps - that's just me having hiccups, and it's completely normal.",
          hi: 'कभी-कभी आपको छोटी-छोटी लयबद्ध थपकियाँ महसूस होंगी — वह बस मेरी हिचकी है, और यह बिलकुल आम बात है।')),
  _Fact(
      '🦶',
      Color(0xFFFDF0C4),
      LocalizedText(
          en: 'My own fingerprints are forming right now',
          hi: 'अभी मेरी अपनी उँगलियों के निशान बन रहे हैं'),
      LocalizedText(
          en: "My very own fingerprints - and footprints - are forming right now, patterns that will be mine alone for life.",
          hi: 'अभी मेरी अपनी उँगलियों के — और पैरों के — निशान बन रहे हैं, ऐसी लकीरें जो ज़िंदगी भर सिर्फ़ मेरी रहेंगी।')),
  _Fact(
      '💗',
      Color(0xFFEAF1EA),
      LocalizedText(
          en: 'My heart is beating strong and steady',
          hi: 'मेरा दिल मज़बूत और एक लय में धड़क रहा है'),
      LocalizedText(
          en: "My heart is pumping hard, moving several litres of blood around my tiny body every single day.",
          hi: 'मेरा दिल ज़ोर से पंप कर रहा है और हर दिन कई लीटर ख़ून मेरे नन्हे शरीर में घुमाता है।')),
  _Fact(
      '🌗',
      Color(0xFFEDEAF6),
      LocalizedText(en: 'I can sense light', hi: 'मुझे रोशनी का एहसास होता है'),
      LocalizedText(
          en: 'Shine a soft light on your bump and I might turn towards it - my eyes are getting ready to see you.',
          hi: 'अपने बंप पर हल्की रोशनी डालिए, हो सकता है मेरा रुख़ उसी तरफ़ हो जाए — मेरी आँखें आपको देखने के लिए तैयार हो रही हैं।')),
];

class _Article {
  const _Article(this.heading, this.body);
  final LocalizedText heading;
  final LocalizedText body;
}

const List<_Article> _babyArticle = [
  _Article(
      LocalizedText(en: "We're halfway there! 🎉", hi: 'हमारा आधा सफ़र पूरा हो गया! 🎉'),
      LocalizedText(
          en: "We've reached the middle of our journey together! I'm growing quickly now, your bump is showing, and any day now you might feel me move for the very first time.",
          hi: 'हमारा साझा सफ़र आधा पूरा हो गया! मेरा बढ़ना अब तेज़ी पकड़ रहा है, आपका बंप दिखने लगा है, और किसी भी दिन आपको पहली बार मेरी हलचल महसूस हो सकती है।')),
  _Article(
      LocalizedText(en: 'How big am I?', hi: 'अभी मेरा आकार कितना है?'),
      LocalizedText(
          en: "I'm about the size of a banana now - roughly 25 cm from my head to my heels and around 300 g. From this week, you'll measure me head-to-heel instead of head-to-bottom.",
          hi: 'अभी मेरा आकार क़रीब एक केले जितना है — सिर से एड़ी तक लगभग 25 cm और वज़न क़रीब 300 g। इस हफ़्ते से मेरी लंबाई सिर-से-कूल्हे नहीं, सिर-से-एड़ी नापी जाएगी।')),
  _Article(
      LocalizedText(en: "You'll feel me move", hi: 'अब आपको मेरी हलचल महसूस होगी'),
      LocalizedText(
          en: "My first little flutters - called \"quickening\" - often start around now. They feel like bubbles or a gentle tap, and over the next few weeks they'll grow into clear kicks. If this is your first baby you might feel me a little later - that's completely normal.",
          hi: 'मेरी पहली हल्की हलचल — जिसे quickening कहते हैं — अक्सर इसी समय शुरू होती है। यह नरम बुलबुलों या हल्की थपकी जैसी लगती है, और आने वाले कुछ हफ़्तों में साफ़ किक बन जाती है। अगर यह आपका पहला शिशु है तो यह एहसास थोड़ी देर से भी हो सकता है — और यह बिलकुल आम बात है।')),
  _Article(
      LocalizedText(en: 'I can hear you now', hi: 'अब मुझे आपकी आवाज़ सुनाई देती है'),
      LocalizedText(
          en: "The tiny bones in my ears are in place, so I can hear your voice, your heartbeat and the world around us. When you talk, hum or sing to me, it helps us bond - and I'll often recognise your favourite tune after I'm born.",
          hi: 'मेरे कानों की नन्ही हड्डियाँ अपनी जगह ले चुकी हैं, इसलिए अब मुझे आपकी आवाज़, आपकी धड़कन और आसपास की दुनिया सुनाई देती है। जब आप मुझसे बात करती हैं, गुनगुनाती हैं या गाती हैं, तो हमारा जुड़ाव गहरा होता है — और जन्म के बाद आपकी पसंदीदा धुन अक्सर पहचानी हुई लगती है।')),
  _Article(
      LocalizedText(en: "I'm tasting your meals", hi: 'आपके खाने का स्वाद मुझ तक पहुँचता है'),
      LocalizedText(
          en: "I swallow a little amniotic fluid through the day, and my new taste buds pick up the flavours of whatever you eat. A varied, balanced diet now might even shape what I love to eat later!",
          hi: 'दिन भर थोड़ा-सा amniotic fluid मेरे भीतर जाता है, और मेरी नई स्वाद-कलियाँ आपके खाने का स्वाद पकड़ लेती हैं। अभी की तरह-तरह की संतुलित थाली आगे चलकर मेरी पसंद भी बना सकती है!')),
  _Article(
      LocalizedText(en: 'My skin, hair and vernix', hi: 'मेरी त्वचा, बाल और vernix'),
      LocalizedText(
          en: "A soft creamy coating called vernix and a layer of fine hair (lanugo) are protecting my delicate skin. Underneath, I'm building up the fat that will keep me warm and cosy after I'm born.",
          hi: 'vernix नाम की नरम मलाईदार परत और महीन बालों की तह (lanugo) मेरी नाज़ुक त्वचा को बचा रही हैं। उसके नीचे वह चर्बी जमा हो रही है जो जन्म के बाद मुझे गरम और आराम में रखेगी।')),
  _Article(
      LocalizedText(en: 'I sleep and wake', hi: 'मेरा सोना और जागना'),
      LocalizedText(
          en: "I'm settling into my own sleep-and-wake cycles, and I'm often most active just when you lie down to rest! Noticing my patterns is the start of you getting to know me.",
          hi: 'मेरे सोने-जागने के अपने चक्र बनने लगे हैं, और सबसे ज़्यादा हलचल अक्सर तभी होती है जब आप आराम करने लेटती हैं! मेरे इस ढर्रे को पहचानना ही मुझे जानने की शुरुआत है।')),
];

const List<_Food> _avoidFoods = [
  _Food(
      '🥩',
      LocalizedText(
          en: 'Raw or undercooked meat & eggs',
          hi: 'कच्चा या अधपका मांस और अंडे'),
      LocalizedText(
          en: 'Can carry bacteria like salmonella or listeria - cook everything thoroughly.',
          hi: 'इनमें salmonella या listeria जैसे बैक्टीरिया हो सकते हैं — सब कुछ अच्छी तरह पकाइए।')),
  _Food(
      '🧀',
      LocalizedText(
          en: 'Unpasteurised milk & soft cheese',
          hi: 'बिना pasteurised दूध और नरम चीज़'),
      LocalizedText(
          en: 'May contain listeria. Choose pasteurised dairy and hard cheeses instead.',
          hi: 'इनमें listeria हो सकता है। इसकी जगह pasteurised दूध-दही और सख़्त चीज़ चुनिए।')),
  _Food(
      '🐟',
      LocalizedText(en: 'High-mercury fish', hi: 'ज़्यादा पारे वाली मछली'),
      LocalizedText(
          en: "Limit shark, swordfish and king mackerel - mercury can affect baby's developing brain.",
          hi: 'Shark, swordfish और king mackerel कम कीजिए — पारा शिशु के बनते दिमाग़ पर असर डाल सकता है।')),
  _Food(
      '☕',
      LocalizedText(en: 'Too much caffeine', hi: 'ज़्यादा कैफ़ीन'),
      LocalizedText(
          en: 'Keep it under about 200 mg a day - roughly one cup of coffee.',
          hi: 'दिन भर में इसे क़रीब 200 mg से कम रखिए — यानी लगभग एक कप कॉफ़ी।')),
  _Food(
      '🍷',
      LocalizedText(en: 'Alcohol', hi: 'शराब'),
      LocalizedText(
          en: 'No amount is considered safe in pregnancy - best avoided completely.',
          hi: 'गर्भावस्था में कोई भी मात्रा सुरक्षित नहीं मानी जाती — पूरी तरह बचना ही बेहतर है।')),
];

class _Food {
  const _Food(this.emoji, this.name, this.why);
  final String emoji;
  final LocalizedText name;
  final LocalizedText why;
}

const List<_Food> _eatFoods = [
  _Food('🧀', LocalizedText(en: 'Paneer & dairy', hi: 'Paneer & dairy'),
      LocalizedText(
          en: "Rich in calcium and protein - builds your baby's bones and teeth, and keeps yours strong too.",
          hi: 'Calcium और प्रोटीन से भरपूर — शिशु की हड्डियाँ और दाँत बनाता है, और आपकी हड्डियाँ भी मज़बूत रखता है।')),
  _Food('🫘', LocalizedText(en: 'Rajma & legumes', hi: 'राजमा और दालें'),
      LocalizedText(
          en: 'Plant iron, protein and fibre. The iron supports the extra blood your body is making, and the fibre eases constipation.',
          hi: 'पौधों वाला आयरन, प्रोटीन और फ़ाइबर। आयरन उस ज़्यादा ख़ून के काम आता है जो इन दिनों आपका शरीर बना रहा है, और फ़ाइबर क़ब्ज़ में राहत देता है।')),
  _Food('🥬', LocalizedText(en: 'Spinach & greens', hi: 'पालक और हरी सब्ज़ियाँ'),
      LocalizedText(
          en: "Loaded with folate, iron and calcium - key for baby's growth and your own energy.",
          hi: 'Folate, Iron और Calcium से भरपूर — शिशु के विकास और आपकी अपनी ऊर्जा के लिए ज़रूरी।')),
  _Food('🥛', LocalizedText(en: 'Curd & yoghurt', hi: 'दही'),
      LocalizedText(
          en: 'Probiotics plus calcium - gentle on digestion and cooling in the heat.',
          hi: 'प्रोबायोटिक्स के साथ कैल्शियम — पचने में हल्का और गर्मी में ठंडक देने वाला।')),
  _Food('🥚', LocalizedText(en: 'Eggs', hi: 'अंडे'),
      LocalizedText(
          en: "Complete protein and choline, which supports your baby's brain development. Cook them well.",
          hi: 'पूरा प्रोटीन और choline, जो शिशु के दिमाग़ के विकास में मदद करता है। इन्हें अच्छी तरह पकाइए।')),
  _Food('🍊', LocalizedText(en: 'Citrus & amla', hi: 'खट्टे फल और आँवला'),
      LocalizedText(
          en: 'Vitamin C helps your body absorb iron better - pair them with your rajma or spinach.',
          hi: 'Vitamin C से शरीर आयरन कहीं बेहतर सोखता है — इन्हें अपने राजमा या पालक के साथ लीजिए।')),
];

class _ToDo {
  const _ToDo(this.emoji, this.title, this.detail);
  final String emoji;
  final LocalizedText title;
  final LocalizedText detail;
}

const List<_ToDo> _toDos = [
  _ToDo('🩺', LocalizedText(en: 'Your anomaly scan', hi: 'आपका anomaly scan'),
      LocalizedText(
          en: "If you haven't already, book or attend your 20-week scan. This gentle ultrasound checks baby's growth, heart, spine and organs - and you may catch a lovely glimpse of your little one. Take your partner along if you can.",
          hi: 'अगर अब तक नहीं कराया, तो अपना 20 हफ़्ते वाला स्कैन बुक कीजिए या करा लीजिए। यह हल्का अल्ट्रासाउंड शिशु के विकास, दिल, रीढ़ और अंगों की जाँच करता है — और आपको अपने शिशु की प्यारी-सी झलक भी मिल सकती है। हो सके तो अपने साथी को साथ ले जाइए।')),
  _ToDo(
      '🛏️',
      LocalizedText(en: 'Start sleeping on your side', hi: 'अब करवट लेकर सोना शुरू कीजिए'),
      LocalizedText(
          en: "As your bump grows, resting on your side - a pillow tucked between your knees helps - keeps blood flowing well to baby. If you wake on your back, don't worry; just settle gently onto your side again.",
          hi: 'बंप बढ़ने के साथ करवट लेकर आराम करना — घुटनों के बीच एक तकिया रख लीजिए — शिशु तक ख़ून का बहाव अच्छा रखता है। अगर नींद खुले और आप पीठ के बल हों तो घबराइए नहीं; बस धीरे से फिर करवट ले लीजिए।')),
  _ToDo('🚶‍♀️', LocalizedText(en: 'Move gently, every day', hi: 'हर दिन थोड़ी हल्की हलचल कीजिए'),
      LocalizedText(
          en: "A short walk or some prenatal stretches can lift your mood, boost your energy and ease swelling. There's no need to push - listen to your body and rest whenever you need to.",
          hi: 'थोड़ी-सी सैर या गर्भावस्था के लिए बनी हल्की कसरत आपका मन हल्का कर सकती है, ऊर्जा बढ़ा सकती है और सूजन में राहत दे सकती है। ज़ोर लगाने की ज़रूरत नहीं — अपने शरीर की सुनिए और जब लगे तब आराम कीजिए।')),
  _ToDo('🎵', LocalizedText(en: 'Talk and sing to your bump', hi: 'बंप से बात कीजिए, गाइए'),
      LocalizedText(
          en: 'Baby can hear you now, and your voice is already comforting to them. Just a few quiet minutes a day - a song, a story, a hello - is a beautiful way to begin bonding.',
          hi: 'अब शिशु को आपकी आवाज़ सुनाई देती है, और यही आवाज़ अभी से सुकून देती है। दिन के बस कुछ शांत मिनट — एक गाना, एक कहानी, एक हल्का सा हैलो — जुड़ाव की शुरुआत का बेहद प्यारा तरीक़ा है।')),
];

class _Vid {
  const _Vid(this.title, this.tag, this.c1, this.c2);
  final LocalizedText title;
  final String tag; // short corner label (placeholder duration)
  final Color c1;
  final Color c2;
}

const List<_Vid> _weekVideos = [
  _Vid(
      LocalizedText(
          en: 'How big are 20-week bumps?', hi: '20 हफ़्ते का बंप कितना बड़ा होता है?'),
      '0:48',
      Color(0xFFE76A86),
      Color(0xFF8E3B7A)),
  _Vid(
      LocalizedText(
          en: 'Prenatal yoga for week 20', hi: 'हफ़्ता 20 के लिए गर्भावस्था में योग'),
      '5:20',
      Color(0xFF3FA796),
      Color(0xFF276B5C)),
  _Vid(LocalizedText(en: 'Sleeping comfortably now', hi: 'अब आराम से सोना'),
      '3:10', Color(0xFF5B7CC9), Color(0xFF324388)),
  _Vid(LocalizedText(en: 'Dressing your bump', hi: 'बंप के साथ कपड़ों का चुनाव'),
      '2:35', Color(0xFFE8845E), Color(0xFFC0507F)),
];

class _WeekMs {
  const _WeekMs(this.week, this.emoji, this.title, this.short, this.detail);
  final int week;
  final String emoji;
  final LocalizedText title;
  final LocalizedText short;
  final LocalizedText detail;
}

// At least one happy "milestone" per week so the section is never blank - a
// mix of baby development and what your body is achieving.
const List<_WeekMs> _weekMilestones = [
  _WeekMs(20, '✨',
      LocalizedText(en: 'Halfway & first kicks', hi: 'आधा सफ़र और पहली किक'),
      LocalizedText(en: "You've reached the midpoint and may feel the first flutters.", hi: 'आप आधे सफ़र पर पहुँच गई हैं और पहली हल्की हलचल महसूस कर सकती हैं।'),
      LocalizedText(en: 'Week 20 is the midpoint of pregnancy. Many mums feel the first gentle movements - "quickening" - around now, like soft bubbles that grow into clear kicks.', hi: 'हफ़्ता 20 गर्भावस्था का बीच का पड़ाव है। कई माँओं को इसी समय पहली हल्की हलचल महसूस होती है — जिसे quickening कहते हैं — जैसे नरम बुलबुले, जो आगे चलकर साफ़ किक बन जाते हैं।')),
  _WeekMs(20, '🍌',
      LocalizedText(en: 'Size of a banana', hi: 'आकार केले जितना'),
      LocalizedText(en: 'Baby is about 25 cm and 300 g now.', hi: 'अब शिशु की लंबाई क़रीब 25 cm और वज़न 300 g है।'),
      LocalizedText(en: 'Your baby is around the size of a banana - about 25 cm from head to heel and 300 g. From this week, length is measured head-to-heel instead of head-to-bottom.', hi: 'आपके शिशु का आकार क़रीब एक केले जितना है — सिर से एड़ी तक लगभग 25 cm और वज़न 300 g। इस हफ़्ते से लंबाई सिर-से-कूल्हे नहीं, सिर-से-एड़ी नापी जाती है।')),
  _WeekMs(20, '👂',
      LocalizedText(en: 'Baby can hear you', hi: 'अब शिशु को आपकी आवाज़ सुनाई देती है'),
      LocalizedText(en: 'The ears are working - baby hears your voice.', hi: 'कान काम करने लगे हैं — शिशु तक आपकी आवाज़ पहुँचती है।'),
      LocalizedText(en: "The tiny bones in baby's ears are in place, so baby can hear your voice and heartbeat. Talk, hum and sing to your bump - it's wonderful early bonding.", hi: 'शिशु के कानों की नन्ही हड्डियाँ अपनी जगह ले चुकी हैं, इसलिए आपकी आवाज़ और धड़कन उस तक पहुँचती है। बंप से बात कीजिए, गुनगुनाइए और गाइए — यह शुरुआती जुड़ाव का बहुत प्यारा तरीक़ा है।')),
  _WeekMs(21, '🍽️',
      LocalizedText(en: 'Tasting flavours', hi: 'स्वाद की पहचान'),
      LocalizedText(en: 'Baby swallows and tastes the flavours of your meals.', hi: 'आप जो खाती हैं, उसका स्वाद निगलने के साथ शिशु तक पहुँचता है।'),
      LocalizedText(en: "Baby's taste buds are working and it swallows amniotic fluid daily, getting a hint of what you eat - variety now may shape later tastes.", hi: 'शिशु की स्वाद-कलियाँ काम करने लगी हैं और रोज़ थोड़ा amniotic fluid भीतर जाता है, जिससे आपके खाने का हल्का स्वाद पहुँचता है — अभी की तरह-तरह की थाली आगे की पसंद बना सकती है।')),
  _WeekMs(22, '👀',
      LocalizedText(en: 'Senses sharpening', hi: 'इंद्रियाँ पैनी हो रहीं'),
      LocalizedText(en: 'Lips, eyelids and tiny eyebrows are now formed.', hi: 'होंठ, पलकें और नन्ही भौंहें अब बन चुकी हैं।'),
      LocalizedText(en: "Baby's face is fully formed and the senses of touch and sight are developing quickly.", hi: 'शिशु का चेहरा पूरी तरह बन चुका है, और छूने और देखने की समझ तेज़ी से बन रही है।')),
  _WeekMs(23, '👂',
      LocalizedText(en: 'Responding to sound', hi: 'आवाज़ पर प्रतिक्रिया'),
      LocalizedText(en: 'Baby can hear and may react to loud sounds.', hi: 'अब शिशु को सुनाई देता है और तेज़ आवाज़ पर हलचल भी हो सकती है।'),
      LocalizedText(en: 'Hearing is improving - baby may move or startle at loud sounds and grow familiar with your voice and favourite music.', hi: 'सुनने की ताक़त बेहतर होती जा रही है — तेज़ आवाज़ पर हलचल या चौंक हो सकती है, और आपकी आवाज़ और पसंदीदा संगीत की पहचान बनने लगती है।')),
  _WeekMs(24, '🛡️',
      LocalizedText(en: 'Viability milestone', hi: 'जीने की क्षमता का पड़ाव'),
      LocalizedText(en: "A major milestone - baby's lungs start developing surfactant.", hi: 'एक बड़ा पड़ाव — शिशु के फेफड़ों में surfactant बनना शुरू होता है।'),
      LocalizedText(en: 'Week 24 is an important development milestone. The lungs begin producing surfactant, which will help baby breathe after birth.', hi: 'हफ़्ता 24 विकास का एक अहम पड़ाव है। फेफड़ों में surfactant बनना शुरू होता है, जो जन्म के बाद साँस लेने में मदद करेगा।')),
  _WeekMs(25, '🤚',
      LocalizedText(en: 'Responds to touch', hi: 'छूने पर प्रतिक्रिया'),
      LocalizedText(en: 'Baby responds to your voice and a gentle touch on the bump.', hi: 'आपकी आवाज़ और बंप पर हल्के से छूने पर अब शिशु की प्रतिक्रिया होती है।'),
      LocalizedText(en: 'Baby reacts to your voice and to gentle touch on your bump, and hair colour and texture are starting to form.', hi: 'आपकी आवाज़ और बंप पर हल्के से छूने पर शिशु की प्रतिक्रिया होती है, और बालों का रंग-रूप भी बनने लगा है।')),
  _WeekMs(26, '👁️',
      LocalizedText(en: 'Eyes begin to open', hi: 'आँखें खुलने लगीं'),
      LocalizedText(en: "Baby's eyes start to open and can blink.", hi: 'शिशु की आँखें खुलने लगती हैं और पलक झपकना भी शुरू हो जाता है।'),
      LocalizedText(en: 'After weeks fused shut, the eyelids begin to open and baby can blink - and may respond to bright light.', hi: 'कई हफ़्तों तक बंद रहने के बाद पलकें खुलने लगती हैं और पलक झपकना भी होने लगता है — तेज़ रोशनी पर प्रतिक्रिया भी हो सकती है।')),
  _WeekMs(27, '💤',
      LocalizedText(en: 'Sleep cycles & dreams', hi: 'नींद के चक्र और सपने'),
      LocalizedText(en: 'Baby now has regular sleep–wake cycles and REM (dream) sleep.', hi: 'अब शिशु के सोने-जागने के चक्र नियमित हैं, और REM (सपनों वाली) नींद भी।'),
      LocalizedText(en: 'Baby settles into regular sleep and wake cycles and shows REM sleep - the stage linked with dreaming.', hi: 'सोने और जागने के चक्र अब नियमित होने लगे हैं, और REM नींद भी दिखती है — वही दौर जो सपनों से जुड़ा है।')),
  _WeekMs(28, '🌸',
      LocalizedText(en: 'Third trimester begins', hi: 'तीसरी तिमाही शुरू'),
      LocalizedText(en: 'The final stretch begins - check-ups become more frequent.', hi: 'आख़िरी दौर शुरू — अब डॉक्टर से मुलाक़ातें ज़्यादा बार होंगी।'),
      LocalizedText(en: "Welcome to the third trimester. Baby's eyes can open and close, and your appointments will start coming more often.", hi: 'तीसरी तिमाही में आपका स्वागत है। शिशु की आँखें अब खुल-बंद हो सकती हैं, और डॉक्टर से आपकी मुलाक़ातें अब ज़्यादा बार होने लगेंगी।')),
  _WeekMs(29, '💪',
      LocalizedText(en: 'Growing stronger', hi: 'अब और मज़बूत'),
      LocalizedText(en: 'Muscles and lungs keep maturing; kicks feel firmer.', hi: 'मांसपेशियाँ और फेफड़े पकते जा रहे हैं; किक अब और मज़बूत लगती हैं।'),
      LocalizedText(en: "Baby's muscles and lungs are maturing and movements feel stronger and more defined.", hi: 'शिशु की मांसपेशियाँ और फेफड़े पकते जा रहे हैं, और हलचल अब ज़्यादा मज़बूत और साफ़ लगती है।')),
  _WeekMs(30, '🧠',
      LocalizedText(en: 'Brain growing fast', hi: 'दिमाग़ तेज़ी से बढ़ रहा'),
      LocalizedText(en: "Baby's brain is developing rapidly now.", hi: 'शिशु का दिमाग़ अब तेज़ी से बन रहा है।'),
      LocalizedText(en: "Baby's brain is growing quickly, forming the grooves and folds that support learning, and can regulate temperature a little.", hi: 'शिशु का दिमाग़ तेज़ी से बढ़ रहा है — सीखने में मदद करने वाली सिलवटें और लकीरें बन रही हैं, और शरीर का तापमान भी थोड़ा-बहुत सँभाला जाने लगा है।')),
  _WeekMs(31, '🫧',
      LocalizedText(en: 'Practising breathing', hi: 'साँस लेने का अभ्यास'),
      LocalizedText(en: 'Baby makes breathing movements to prepare the lungs.', hi: 'फेफड़ों की तैयारी में अब साँस जैसी हरकतें होने लगी हैं।'),
      LocalizedText(en: "Baby 'practises' breathing by moving the diaphragm, getting the lungs ready for that first breath.", hi: 'शिशु अपनी साँस वाली झिल्ली हिलाकर साँस लेने का अभ्यास करता है, ताकि फेफड़े पहली साँस के लिए तैयार हो जाएँ।')),
  _WeekMs(32, '💅',
      LocalizedText(en: 'Nails & hair', hi: 'नाख़ून और बाल'),
      LocalizedText(en: 'Fingernails and toenails are formed; hair is growing.', hi: 'हाथ-पैर के नाख़ून बन चुके हैं; बाल बढ़ रहे हैं।'),
      LocalizedText(en: 'Tiny fingernails and toenails have formed and baby may have a head of hair - the body is filling out with fat.', hi: 'नन्हे नाख़ून बन चुके हैं और सिर पर बाल भी हो सकते हैं — शरीर पर चर्बी की परत भरने लगी है।')),
  _WeekMs(33, '💡',
      LocalizedText(en: 'Reacting to light', hi: 'रोशनी पर प्रतिक्रिया'),
      LocalizedText(en: "Baby's pupils react to light now.", hi: 'शिशु की आँख की पुतली अब रोशनी पर प्रतिक्रिया करती है।'),
      LocalizedText(en: "Baby's pupils can narrow and widen in response to light, and the immune system is getting a boost from you.", hi: 'शिशु की पुतलियाँ रोशनी के हिसाब से छोटी-बड़ी हो सकती हैं, और आपसे मिल रही ताक़त से रोग-प्रतिरोधक क्षमता भी बढ़ रही है।')),
  _WeekMs(34, '🫁',
      LocalizedText(en: 'Lungs maturing', hi: 'फेफड़े पक रहे'),
      LocalizedText(en: 'Central nervous system and lungs are maturing well.', hi: 'दिमाग़ और नसों का तंत्र और फेफड़े अच्छे से पक रहे हैं।'),
      LocalizedText(en: "Baby's lungs and nervous system are maturing, and the protective vernix coating thickens.", hi: 'शिशु के फेफड़े और नसों का तंत्र पकते जा रहे हैं, और बचाने वाली vernix की परत घनी होती जा रही है।')),
  _WeekMs(35, '⚖️',
      LocalizedText(en: 'Gaining weight fast', hi: 'तेज़ी से बढ़ता वज़न'),
      LocalizedText(en: 'Most development is done - baby is plumping up.', hi: 'ज़्यादातर विकास हो चुका — अब शरीर गोल-मटोल होता जा रहा है।'),
      LocalizedText(en: "Baby's main development is largely complete; from now the focus is gaining weight and building fat for warmth.", hi: 'शिशु का मुख्य विकास लगभग पूरा हो चुका है; अब ध्यान वज़न बढ़ाने और गर्मी के लिए चर्बी जमा करने पर है।')),
  _WeekMs(36, '🙃',
      LocalizedText(en: 'Settling head-down', hi: 'सिर नीचे की ओर'),
      LocalizedText(en: 'Baby often settles into a head-down position.', hi: 'अक्सर इसी समय शिशु का सिर नीचे की ओर आ जाता है।'),
      LocalizedText(en: 'Many babies move into a head-down position ready for birth and start shedding the fine lanugo hair.', hi: 'जन्म की तैयारी में कई शिशुओं का सिर नीचे की ओर आ जाता है, और महीन lanugo बाल झड़ने लगते हैं।')),
  _WeekMs(37, '✅',
      LocalizedText(en: 'Early term', hi: 'Early term'),
      LocalizedText(en: 'Baby is now considered early term.', hi: 'अब यह गर्भावस्था early term मानी जाती है।'),
      LocalizedText(en: "At 37 weeks baby is 'early term' - the lungs and brain are nearly ready for life outside the womb.", hi: '37 हफ़्ते पर शिशु early term माना जाता है — फेफड़े और दिमाग़ बाहर की ज़िंदगी के लिए लगभग तैयार हैं।')),
  _WeekMs(38, '🤝',
      LocalizedText(en: 'Firm grasp', hi: 'मज़बूत पकड़'),
      LocalizedText(en: 'Baby has a firm grasp; organs are ready.', hi: 'शिशु की पकड़ मज़बूत है; अंग तैयार हैं।'),
      LocalizedText(en: "Baby's grasp is strong and the organs are ready to function outside the womb - just final touches now.", hi: 'शिशु की पकड़ मज़बूत है और अंग गर्भ के बाहर काम करने को तैयार हैं — अब बस आख़िरी तैयारियाँ बाक़ी हैं।')),
  _WeekMs(39, '🌟',
      LocalizedText(en: 'Full term', hi: 'Full term'),
      LocalizedText(en: 'Baby is full term - brain and lungs keep maturing.', hi: 'शिशु अब पूरे समय का — दिमाग़ और फेफड़े अभी भी बनते-सँवरते रहते हैं।'),
      LocalizedText(en: 'Baby is full term. The brain and lungs continue to mature right up until birth.', hi: 'शिशु अब पूरे समय का माना जाता है। दिमाग़ और फेफड़े जन्म तक बनते-सँवरते रहते हैं।')),
  _WeekMs(40, '🎉',
      LocalizedText(en: 'Due date!', hi: 'Due date!'),
      LocalizedText(en: 'Baby is ready to meet you.', hi: 'शिशु आपसे मिलने को तैयार है।'),
      LocalizedText(en: "It's your due date! Remember, only about 1 in 20 babies arrive exactly on it - baby will come when ready.", hi: 'आज आपकी डिलीवरी की तारीख़ है! याद रखिए, 20 में से सिर्फ़ 1 शिशु ठीक इसी दिन आता है — शिशु अपनी तैयारी पूरी होने पर ही आएगा।')),
];

const List<LocalizedText> _nextRadar = [
  LocalizedText(
      en: 'Your 20-week anomaly scan happens around now.',
      hi: 'आपका 20 हफ़्ते वाला anomaly scan इसी समय होता है।'),
  LocalizedText(
      en: 'Glucose screening usually comes up between weeks 24–28.',
      hi: 'Glucose screening आमतौर पर 24–28 हफ़्ते के बीच होती है।'),
  LocalizedText(
      en: "A lovely time to start thinking about your birth plan and hospital bag - no rush.",
      hi: 'प्रसव की योजना और अस्पताल बैग के बारे में सोचना शुरू करने का यह प्यारा समय है — कोई जल्दी नहीं।'),
];

// "Mother this week" topics - a short teaser on the card, a fuller read in a
// tap-to-open dialog.
class _MotherTopic {
  const _MotherTopic(this.emoji, this.label, this.short, this.detail);
  final String emoji;
  final LocalizedText label;
  final LocalizedText short;
  final LocalizedText detail;
}

const List<_MotherTopic> _motherTopics = [
  _MotherTopic(
      '🌀',
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'Levels are steadier now - many feel more energy.',
          hi: 'अब स्तर ज़्यादा स्थिर हैं — कई लोगों को ज़्यादा ऊर्जा महसूस होती है।'),
      LocalizedText(
          en: "After the ups and downs of the first trimester, your hormones settle into a steadier rhythm. Many women feel a welcome lift in energy and mood - the 'pregnancy glow' often shows up around now.",
          hi: 'पहली तिमाही के उतार-चढ़ाव के बाद आपके हॉर्मोन एक ज़्यादा स्थिर लय में आ जाते हैं। कई महिलाओं को ऊर्जा और मन दोनों में सुखद निखार महसूस होता है — जिसे pregnancy glow कहते हैं, वह अक्सर इन्हीं दिनों दिखता है।')),
  _MotherTopic(
      '🤰',
      LocalizedText(en: 'Your bump', hi: 'आपका बंप'),
      LocalizedText(
          en: 'The top of your uterus reaches your belly button.',
          hi: 'आपकी बच्चेदानी का ऊपरी हिस्सा नाभि तक पहुँच जाता है।'),
      LocalizedText(
          en: 'Your uterus has grown to about the level of your navel, so your bump is clearly showing now. Roomier clothes and a supportive bra help, and sleeping on your side becomes the comfiest position from here on.',
          hi: 'आपकी बच्चेदानी अब लगभग नाभि के बराबर पहुँच गई है, इसलिए बंप साफ़ दिखने लगा है। खुले-ढीले कपड़े और सहारा देने वाली ब्रा आराम देते हैं, और अब से करवट लेकर सोना सबसे आरामदेह रहता है।')),
  _MotherTopic(
      '🦋',
      LocalizedText(en: 'First movements', hi: 'पहली हलचल'),
      LocalizedText(
          en: 'You may feel the first gentle flutters (quickening).',
          hi: 'आप पहली हल्की हलचल (quickening) महसूस कर सकती हैं।'),
      LocalizedText(
          en: "Those first movements - called 'quickening' - often arrive around week 20. They can feel like bubbles, a light tap or butterflies, and will be irregular at first. Over the coming weeks they grow stronger and more regular. First-time mums sometimes feel them a little later - perfectly normal.",
          hi: 'पहली हलचल - जिसे quickening कहते हैं - अक्सर 20वें हफ़्ते के आसपास आती है। यह बुलबुलों, हल्की थपकी या तितलियों जैसी लग सकती है, और शुरू में बेतरतीब होती है। आने वाले हफ़्तों में यह और मज़बूत और नियमित हो जाती है। पहली बार माँ बन रही महिलाओं को यह कभी थोड़ी देर से महसूस होती है - यह पूरी तरह सामान्य है।')),
  _MotherTopic(
      '✨',
      LocalizedText(en: 'Skin & body', hi: 'त्वचा और शरीर'),
      LocalizedText(
          en: 'More blood flow brings a warm glow and fuller hair.',
          hi: 'ज़्यादा ख़ून का बहाव त्वचा पर निखार और बालों में घनापन लाता है।'),
      LocalizedText(
          en: 'The extra blood your body is making can give your skin a warm glow and your hair a fuller look. Some women notice a dark line down the belly (linea nigra) or slight skin changes - these are normal and usually fade after birth.',
          hi: 'आपका शरीर जो ज़्यादा ख़ून बना रहा है, उससे त्वचा पर निखार आता है और बाल घने लगने लगते हैं। कुछ माँओं को पेट पर एक गहरी रेखा (linea nigra) या त्वचा में हल्के बदलाव दिखते हैं — ये सामान्य हैं और जन्म के बाद अक्सर अपने आप मिट जाते हैं।')),
  _MotherTopic(
      '💗',
      LocalizedText(en: 'Heart & breath', hi: 'दिल और साँस'),
      LocalizedText(
          en: 'Your heart works harder - you may feel breathless.',
          hi: 'आपका दिल ज़्यादा मेहनत कर रहा है — साँस जल्दी फूल सकती है।'),
      LocalizedText(
          en: 'Your heart is now pumping much more blood than usual, so you may feel a little breathless on the stairs or notice your heart racing at times. Move at your own pace, rest when you need to, and stay well hydrated.',
          hi: 'आपका दिल अब पहले से कहीं ज़्यादा ख़ून पंप कर रहा है, इसलिए सीढ़ियाँ चढ़ते हुए साँस थोड़ी फूल सकती है या कभी-कभी दिल तेज़ धड़कता लग सकता है। अपनी रफ़्तार से चलिए, ज़रूरत लगे तो आराम कीजिए, और पानी पीती रहिए।')),
  _MotherTopic(
      '🤕',
      LocalizedText(en: 'Aches & twinges', hi: 'दर्द और खिंचाव'),
      LocalizedText(
          en: 'Round-ligament twinges as your bump stretches.',
          hi: 'बंप के खिंचने से round-ligament में खिंचाव।'),
      LocalizedText(
          en: "You may feel occasional sharp twinges low on the sides of your bump - round-ligament pain - as the ligaments supporting your growing uterus stretch. It's usually brief and harmless; moving slowly helps. Mention anything severe or persistent to your doctor.",
          hi: 'बंप के निचले हिस्सों में कभी-कभी तेज़ खिंचाव महसूस हो सकता है — इसे round-ligament pain कहते हैं — क्योंकि बढ़ते गर्भाशय को थामे रखने वाले ligaments खिंचते हैं। यह आमतौर पर पल भर का होता है और नुक़सानदेह नहीं; धीरे-धीरे हिलना-डुलना राहत देता है। अगर दर्द तेज़ हो या बना रहे, तो अपने डॉक्टर को ज़रूर बताइए।')),
];

// Father-focused "how you can help" lines for the partner share message.
const List<LocalizedText> _partnerHelp = [
  LocalizedText(
      en: 'Come along to the anomaly scan if you can - seeing baby together is special.',
      hi: 'हो सके तो anomaly scan पर साथ जाइए — शिशु को साथ मिलकर देखना ख़ास होता है।'),
  LocalizedText(
      en: 'Help her sleep on her side - a pillow between the knees works wonders.',
      hi: 'उन्हें करवट लेकर सोने में मदद कीजिए — घुटनों के बीच एक तकिया बहुत आराम देता है।'),
  LocalizedText(
      en: 'Take over a few chores; her body is working hard for two.',
      hi: 'घर के कुछ काम अपने ज़िम्मे ले लीजिए; उनका शरीर अभी दो लोगों के लिए मेहनत कर रहा है।'),
  LocalizedText(
      en: 'Keep iron- and calcium-rich meals handy - greens, dairy and dal.',
      hi: 'Iron और Calcium वाला खाना पास रखिए — हरी सब्ज़ियाँ, दूध-दही और दाल।'),
  LocalizedText(
      en: 'Talk or sing to the bump - baby can hear your voice now.',
      hi: 'बंप से बात कीजिए या गुनगुनाइए — आपकी आवाज़ अब शिशु तक पहुँचती है।'),
];

// ===========================================================================
//  FATHER (Dad-preview) WEEK-20 COPY - same content, re-voiced for the partner
//  reading it for/about her. Used only when _fatherWeek(week) is true; the
//  mother data above is never touched. Strip with FatherPreview before launch.
// ===========================================================================
const LocalizedText _fBabyTitle =
    LocalizedText(en: 'About your baby', hi: 'आपके शिशु के बारे में');
const LocalizedText _fBabyBrief = LocalizedText(
    en: "Your baby is about the size of a banana now, can hear your voice, and is starting to move. Here's what's happening this week.",
    hi: 'आपका शिशु अब क़रीब एक केले जितना है, आपकी आवाज़ सुन सकता है, और हिलना-डुलना शुरू कर चुका है। इस हफ़्ते क्या हो रहा है, यहाँ देखिए।');
const LocalizedText _fMotherTitle =
    LocalizedText(en: "How she's doing", hi: 'उनका हाल कैसा है');
const LocalizedText _fMotherBrief = LocalizedText(
    en: "She's in the gentlest stretch of pregnancy - steadier energy, a visible bump, big feelings. Here's how to show up for her this week.",
    hi: 'वे गर्भावस्था के सबसे सुकून भरे दौर में हैं — ऊर्जा ज़्यादा स्थिर, बंप दिखने लगा, और भावनाएँ गहरी। इस हफ़्ते उनका साथ कैसे दें, यहाँ देखिए।');
const LocalizedText _fNextBrief = LocalizedText(
    en: "See the scans and check-ups coming up for her - and how to be there for each.",
    hi: 'उनके आने वाले स्कैन और जाँचें देखिए — और हर एक में कैसे साथ रहना है, यह भी।');
const LocalizedText _fYouThisWeek =
    LocalizedText(en: 'Her this week', hi: 'इस हफ़्ते उनका हाल');

// ===========================================================================
//  PER-WEEK father section briefs (the re-voicing pass). 3rd-person, warm,
//  partner-facing. Authored trimester by trimester - TRIMESTER 1 (weeks 4–13)
//  + week 20 below; weeks not yet revoiced fall back to the mother's per-week
//  content via [_fBabyBriefFor] / [_fMotherBriefFor].
// ===========================================================================
const Map<int, LocalizedText> _fBabyBriefs = {
  4: LocalizedText(
      en: "Your baby's brain, spinal cord and nervous system are just starting to form, and the cells are multiplying fast. It's all invisible for now, but every day is a big step.",
      hi: 'आपके शिशु का दिमाग़, रीढ़ की हड्डी और नसों का तंत्र अभी बनना शुरू ही हुआ है, और कोशिकाएँ तेज़ी से बढ़ रही हैं। अभी सब कुछ आँखों से ओझल है, पर हर दिन एक बड़ा क़दम है।'),
  5: LocalizedText(
      en: "Your baby's heart is beginning to beat this week, while the brain, spinal cord and major organs keep developing fast. Tiny as they are, they're working hard every day.",
      hi: 'इस हफ़्ते आपके शिशु का दिल धड़कना शुरू हो रहा है, और दिमाग़, रीढ़ की हड्डी और बड़े अंग तेज़ी से बनते जा रहे हैं। इतना छोटा होकर भी, हर दिन कितनी मेहनत हो रही है।'),
  6: LocalizedText(
      en: "Your baby's heart is now beating regularly, the brain is developing fast, and the first hints of eyes, ears and limbs are forming. So many systems are already under construction.",
      hi: 'आपके शिशु का दिल अब नियमित रूप से धड़क रहा है, दिमाग़ तेज़ी से बन रहा है, और आँखों, कानों और हाथ-पैरों की पहली झलक उभरने लगी है। इतने सारे तंत्र अभी से बनने में लगे हैं।'),
  7: LocalizedText(
      en: "Your baby's brain is growing rapidly, tiny arm and leg buds are appearing, and the eyes, ears and nose are becoming more defined. That little heart is still beating strongly.",
      hi: 'आपके शिशु का दिमाग़ तेज़ी से बढ़ रहा है, हाथ-पैरों की नन्ही कलियाँ उभर रही हैं, और आँख, कान और नाक और साफ़ होते जा रहे हैं। वह नन्हा दिल अब भी मज़बूती से धड़क रहा है।'),
  8: LocalizedText(
      en: "Your baby's fingers and toes are starting to form, the little face is becoming more recognisable, and all the major organs have begun developing. The groundwork for the next stage is in place.",
      hi: 'आपके शिशु के हाथ-पैर की उँगलियाँ बनने लगी हैं, नन्हा चेहरा अब ज़्यादा पहचान में आने लगा है, और सारे बड़े अंग बनना शुरू हो चुके हैं। अगले पड़ाव की नींव तैयार है।'),
  9: LocalizedText(
      en: "Your baby's arms and legs are getting longer, the joints are forming, and the first small movements are beginning. The heart now has all four chambers and is working hard.",
      hi: 'आपके शिशु के हाथ-पैर लंबे हो रहे हैं, जोड़ बन रहे हैं, और पहली छोटी हलचल शुरू हो रही है। दिल अब चारों कक्षों के साथ पूरा है और लगातार मेहनत कर रहा है।'),
  10: LocalizedText(
      en: "Your baby's fingers and toes are separating, the jaw and face are taking shape, and the brain is building millions of new connections. There are tiny movements now - still far too small for her to feel.",
      hi: 'आपके शिशु के हाथ-पैर की उँगलियाँ अलग हो रही हैं, जबड़ा और चेहरा आकार ले रहे हैं, और दिमाग़ में लाखों नए जोड़ बन रहे हैं। अब नन्ही हलचल भी होती है — पर इतनी हल्की कि उन्हें अभी महसूस नहीं होती।'),
  11: LocalizedText(
      en: "Your baby's fingers and toes are fully separated now, the bones are starting to harden, and there's stretching, kicking and moving inside that tiny world. The little face grows clearer by the day.",
      hi: 'आपके शिशु के हाथ-पैर की उँगलियाँ अब पूरी तरह अलग हो चुकी हैं, हड्डियाँ सख़्त होने लगी हैं, और उस नन्ही दुनिया के भीतर अंगड़ाई, किक और हलचल चलती रहती है। नन्हा चेहरा दिन-ब-दिन और साफ़ होता जा रहा है।'),
  12: LocalizedText(
      en: "Most of your baby's major organs have formed and are starting to work. There's arm and leg movement, tiny fingers opening and closing, and reflexes developing every day.",
      hi: 'आपके शिशु के ज़्यादातर बड़े अंग बन चुके हैं और काम करना शुरू कर रहे हैं। हाथ-पैर हिलते हैं, नन्ही उँगलियाँ खुलती-बंद होती हैं, और सहज प्रतिक्रियाएँ हर दिन बनती जा रही हैं।'),
  13: LocalizedText(
      en: "Your baby's vocal cords are forming, fingerprints are starting to develop, and the bones keep getting stronger. There's plenty of free movement inside that tiny world now.",
      hi: 'आपके शिशु के गले में आवाज़ की डोरियाँ बन रही हैं, उँगलियों के निशान उभरने लगे हैं, और हड्डियाँ लगातार मज़बूत होती जा रही हैं। अब उस नन्ही दुनिया में ख़ूब खुलकर हलचल होती है।'),
  14: LocalizedText(
      en: "Your baby's facial muscles are developing enough for tiny expressions, the neck is getting stronger, and for the first time the body is growing faster than the head.",
      hi: 'आपके शिशु के चेहरे की मांसपेशियाँ इतनी बन चुकी हैं कि नन्हे भाव बनने लगे हैं, गर्दन मज़बूत हो रही है, और पहली बार शरीर सिर से ज़्यादा तेज़ी से बढ़ रहा है।'),
  15: LocalizedText(
      en: "Your baby's muscles and bones are getting stronger, with smoother movements of the arms, legs and joints. The ears are developing too, getting ready to hear the world in the weeks ahead.",
      hi: 'आपके शिशु की मांसपेशियाँ और हड्डियाँ मज़बूत हो रही हैं, और हाथ, पैर और जोड़ों की हलचल पहले से कहीं सधी हुई है। कान भी बन रहे हैं — आने वाले हफ़्तों में दुनिया को सुनने की तैयारी में।'),
  16: LocalizedText(
      en: "Your baby's bones are hardening, the muscles are getting stronger, and the ears are developing fast - soon there'll be the first responses to sounds from the outside world.",
      hi: 'आपके शिशु की हड्डियाँ सख़्त हो रही हैं, मांसपेशियाँ मज़बूत हो रही हैं, और कान तेज़ी से बन रहे हैं — जल्द ही बाहर की दुनिया की आवाज़ों पर पहली प्रतिक्रिया दिखने लगेगी।'),
  17: LocalizedText(
      en: "Your baby's skeleton is turning from soft cartilage into stronger bone, the muscles are growing more powerful, and there's lots of practising of the movements that help growth.",
      hi: 'आपके शिशु का ढाँचा नरम कच्ची हड्डी से मज़बूत हड्डी में बदल रहा है, मांसपेशियाँ और ताक़तवर हो रही हैं, और ऐसी हलचल का ख़ूब अभ्यास चल रहा है जो बढ़ने में मदद करती है।'),
  18: LocalizedText(
      en: "Your baby's ears are developing fast and the brain is making millions of new connections. Arm and leg movements are more controlled now, and the nervous system is getting more sophisticated.",
      hi: 'आपके शिशु के कान तेज़ी से बन रहे हैं और दिमाग़ में लाखों नए जोड़ बन रहे हैं। हाथ-पैर की हलचल अब ज़्यादा सधी हुई है, और नसों का तंत्र और बारीक होता जा रहा है।'),
  19: LocalizedText(
      en: "Your baby's brain keeps developing fast, the senses are sharpening, and a protective coating called vernix is forming on the skin. The arms and legs are stronger, and there's more activity than ever.",
      hi: 'आपके शिशु का दिमाग़ तेज़ी से बनता जा रहा है, इंद्रियाँ और तेज़ हो रही हैं, और त्वचा पर vernix नाम की बचाने वाली परत बन रही है। हाथ-पैर पहले से मज़बूत हैं, और हलचल भी पहले से कहीं ज़्यादा।'),
  20: _fBabyBrief,
  21: LocalizedText(
      en: "Your baby's taste buds are developing, more amniotic fluid is being swallowed, and the movements are getting stronger and better coordinated. The brain keeps making millions of new connections.",
      hi: 'आपके शिशु की स्वाद-कलियाँ बन रही हैं, amniotic fluid अब पहले से ज़्यादा भीतर जाता है, और हलचल ज़्यादा मज़बूत और सधी हुई होती जा रही है। दिमाग़ में लाखों नए जोड़ बनते ही जा रहे हैं।'),
  22: LocalizedText(
      en: "Your baby's hearing is developing fast - picking up her heartbeat, voices (yours included) and even some sounds from outside the womb. That little brain is busy learning from all of it.",
      hi: 'आपके शिशु की सुनने की ताक़त तेज़ी से बन रही है — उनकी धड़कन, आवाज़ें (आपकी भी) और गर्भ के बाहर की कुछ आवाज़ें भी उस तक पहुँचती हैं। वह नन्हा दिमाग़ इन सब से सीखने में लगा है।'),
  23: LocalizedText(
      en: "Your baby's brain is developing at an incredible pace - new connections forming every second, laying the groundwork for learning, memory and movement. The hearing keeps improving, and familiar sounds are being recognised.",
      hi: 'आपके शिशु का दिमाग़ ग़ज़ब की रफ़्तार से बन रहा है — हर पल नए जोड़ बनते हैं, जो सीखने, याद रखने और हिलने-डुलने की नींव रखते हैं। सुनने की ताक़त बेहतर होती जा रही है, और जानी-पहचानी आवाज़ें पहचानी जाने लगी हैं।'),
  24: LocalizedText(
      en: "Your baby's hearing is getting sharper, the brain keeps building new pathways, and regular periods of sleep and activity are starting to form. The lungs are continuing their important development too.",
      hi: 'आपके शिशु की सुनने की ताक़त और पैनी हो रही है, दिमाग़ में नए रास्ते बनते जा रहे हैं, और सोने-जागने के नियमित दौर बनने लगे हैं। फेफड़े भी अपना ज़रूरी विकास जारी रखे हुए हैं।'),
  25: LocalizedText(
      en: "Your baby's hearing is getting more refined and there are responses to the sounds around now. The brain keeps developing fast, and the movements are stronger and better coordinated.",
      hi: 'आपके शिशु की सुनने की समझ और बारीक हो रही है, और अब आसपास की आवाज़ों पर प्रतिक्रिया भी होती है। दिमाग़ तेज़ी से बनता जा रहा है, और हलचल पहले से मज़बूत और ज़्यादा सधी हुई है।'),
  26: LocalizedText(
      en: "Your baby's eyes are starting to open, the hearing keeps improving, and the brain is developing rapidly. There are responses now to sounds, movement and changes in the surroundings.",
      hi: 'आपके शिशु की आँखें खुलने लगी हैं, सुनने की ताक़त बेहतर होती जा रही है, और दिमाग़ तेज़ी से बन रहा है। अब आवाज़ों, हलचल और माहौल के बदलाव पर प्रतिक्रिया भी होती है।'),
  27: LocalizedText(
      en: "Your baby's brain, lungs and nervous system keep maturing fast. There's practising of breathing movements, eyes opening and closing, and a little more strength every day.",
      hi: 'आपके शिशु का दिमाग़, फेफड़े और नसों का तंत्र तेज़ी से पकते जा रहे हैं। साँस जैसी हरकतों का अभ्यास चलता है, आँखें खुलती-बंद होती हैं, और हर दिन थोड़ी और मज़बूती आती है।'),
  28: LocalizedText(
      en: "Your baby can open and close those eyes now, blink and respond to light. The brain is developing fast, and the lungs keep preparing for life outside the womb.",
      hi: 'आपका शिशु अब आँखें खोल-बंद कर सकता है, पलक झपका सकता है और रोशनी पर प्रतिक्रिया दे सकता है। दिमाग़ तेज़ी से बन रहा है, और फेफड़े गर्भ के बाहर की ज़िंदगी की तैयारी करते जा रहे हैं।'),
  29: LocalizedText(
      en: "Your baby is building fat under the skin, strengthening those muscles, and maturing the lungs and brain. The movements are getting more powerful with every passing week.",
      hi: 'आपके शिशु की त्वचा के नीचे चर्बी जमा हो रही है, मांसपेशियाँ मज़बूत हो रही हैं, और फेफड़े और दिमाग़ पक रहे हैं। हर बीतते हफ़्ते के साथ हलचल और ताक़तवर होती जा रही है।'),
  30: LocalizedText(
      en: "Your baby's brain is developing new folds and connections, the lungs keep maturing, and body fat is building up - the kind that helps keep warm after birth.",
      hi: 'आपके शिशु के दिमाग़ में नई सिलवटें और नए जोड़ बन रहे हैं, फेफड़े पकते जा रहे हैं, और शरीर पर चर्बी की परत भर रही है — वही जो जन्म के बाद गर्मी बनाए रखने में मदद करती है।'),
  31: LocalizedText(
      en: "Your baby is gaining body fat, building muscle, and maturing the lungs and brain. The movements are stronger than ever, even as space inside starts to feel a little tighter.",
      hi: 'आपके शिशु के शरीर पर चर्बी बढ़ रही है, मांसपेशियाँ बन रही हैं, और फेफड़े और दिमाग़ पक रहे हैं। भीतर जगह थोड़ी तंग होने लगी है, फिर भी हलचल पहले से कहीं ज़्यादा मज़बूत है।'),
  32: LocalizedText(
      en: "Your baby is practising breathing movements, sleeping in cycles, and maturing the lungs and nervous system. The body is storing up the nutrients and energy needed for life after birth.",
      hi: 'आपका शिशु साँस जैसी हरकतों का अभ्यास कर रहा है, चक्रों में सो रहा है, और फेफड़े और नसों का तंत्र पक रहे हैं। शरीर जन्म के बाद की ज़िंदगी के लिए ज़रूरी पोषण और ऊर्जा जमा कर रहा है।'),
  33: LocalizedText(
      en: "Your baby's brain and lungs keep maturing, and antibodies are passing across from her - protection that will help after birth. There's more fat and a little more strength every day.",
      hi: 'आपके शिशु के दिमाग़ और फेफड़े पकते जा रहे हैं, और उनसे शिशु तक antibodies पहुँच रही हैं — यही बचाव जन्म के बाद काम आएगा। हर दिन थोड़ी और चर्बी और थोड़ी और मज़बूती आती है।'),
  34: LocalizedText(
      en: "Your baby's lungs keep maturing, the brain is developing fast, and body fat is building to help with temperature after birth. Most of the systems are now getting ready for life outside the womb.",
      hi: 'आपके शिशु के फेफड़े पकते जा रहे हैं, दिमाग़ तेज़ी से बन रहा है, और शरीर पर चर्बी जमा हो रही है जो जन्म के बाद तापमान सँभालने में मदद करेगी। ज़्यादातर तंत्र अब गर्भ के बाहर की ज़िंदगी के लिए तैयार हो रहे हैं।'),
  35: LocalizedText(
      en: "Your baby's lungs are nearly mature, the brain keeps developing fast, and body fat is building every day. Around this stage many babies begin settling into a head-down position, ready for the way out.",
      hi: 'आपके शिशु के फेफड़े लगभग पक चुके हैं, दिमाग़ तेज़ी से बनता जा रहा है, और हर दिन शरीर पर चर्बी बढ़ रही है। इसी पड़ाव के आसपास कई शिशु सिर नीचे की ओर करके बैठने लगते हैं — बाहर आने के रास्ते की तैयारी में।'),
  36: LocalizedText(
      en: "Your baby's lungs are almost fully mature, the brain keeps developing fast, and the reflexes for after birth - sucking, grasping - are being practised. Nearly ready to meet you both.",
      hi: 'आपके शिशु के फेफड़े लगभग पूरी तरह पक चुके हैं, दिमाग़ तेज़ी से बनता जा रहा है, और जन्म के बाद काम आने वाली सहज क्रियाओं — चूसना, पकड़ना — का अभ्यास चल रहा है। आप दोनों से मिलने की तैयारी लगभग पूरी है।'),
  37: LocalizedText(
      en: "Your baby's lungs are ready for life outside the womb, the brain keeps developing, and the reflexes for after birth are being practised. Most of the growth now is about gaining strength and storing energy - full-term is here.",
      hi: 'आपके शिशु के फेफड़े गर्भ के बाहर की ज़िंदगी के लिए तैयार हैं, दिमाग़ बनता रहता है, और जन्म के बाद की सहज क्रियाओं का अभ्यास चल रहा है। अब ज़्यादातर बढ़त ताक़त जुटाने और ऊर्जा जमा करने की है — अब शिशु पूरे समय का माना जाता है।'),
  38: LocalizedText(
      en: "Your baby's lungs are ready, the brain is still developing fast, and strength and energy reserves keep building. Most of the work now is simply getting ready for birth and the world outside.",
      hi: 'आपके शिशु के फेफड़े तैयार हैं, दिमाग़ अब भी तेज़ी से बन रहा है, और ताक़त और ऊर्जा का भंडार बढ़ता जा रहा है। अब ज़्यादातर काम बस जन्म और बाहर की दुनिया की तैयारी का है।'),
  39: LocalizedText(
      en: "Your baby's lungs are ready for that first breath, the reflexes are developed, and small reserves of fat and energy keep building. Most of the work now is simply waiting for labour to begin.",
      hi: 'आपके शिशु के फेफड़े पहली साँस के लिए तैयार हैं, सहज क्रियाएँ बन चुकी हैं, और चर्बी और ऊर्जा का छोटा भंडार बढ़ता जा रहा है। अब ज़्यादातर काम बस प्रसव शुरू होने का इंतज़ार करना है।'),
  40: LocalizedText(
      en: "Your baby's lungs are ready for that first breath, and the heart, brain and body are all prepared for life outside the womb. Right now, your baby is just waiting for the perfect moment to begin the journey into your arms.",
      hi: 'आपके शिशु के फेफड़े पहली साँस के लिए तैयार हैं, और दिल, दिमाग़ और शरीर — सब गर्भ के बाहर की ज़िंदगी के लिए तैयार हैं। अभी आपका शिशु बस उस सही पल का इंतज़ार कर रहा है, जब आपकी बाँहों तक का सफ़र शुरू हो।'),
};

const Map<int, LocalizedText> _fMotherBriefs = {
  4: LocalizedText(
      en: "Excitement, disbelief and a little anxiety are probably arriving all at once as she takes in the news. A calm, steady you helps more than you'd think.",
      hi: 'ख़बर को समझते हुए उन्हें उत्साह, यक़ीन न होना और थोड़ी घबराहट — सब एक साथ महसूस हो रहे होंगे। आपका शांत और टिका हुआ रहना, जितना लगता है उससे कहीं ज़्यादा मदद करता है।'),
  5: LocalizedText(
      en: "She may swing between excitement, joy, disbelief and worry through the day. None of it needs fixing - just let her know you're in it together.",
      hi: 'दिन भर वे उत्साह, ख़ुशी, हैरानी और फ़िक्र के बीच झूल सकती हैं। इनमें से कुछ भी ठीक करने की ज़रूरत नहीं — बस उन्हें एहसास दिलाइए कि इसमें आप साथ हैं।'),
  6: LocalizedText(
      en: "She might feel excited one moment and wiped out the next - the ups and downs are normal this week. Picking up a few chores quietly goes a long way.",
      hi: 'एक पल वे उत्साह से भरी लग सकती हैं और अगले ही पल पूरी तरह थकी हुई — इस हफ़्ते यह उतार-चढ़ाव आम बात है। चुपचाप कुछ काम अपने ज़िम्मे ले लेना बहुत बड़ी मदद है।'),
  7: LocalizedText(
      en: "She may feel excited one moment and worried the next - those swings are a normal part of early pregnancy. Patience and a listening ear are the best things you can offer.",
      hi: 'एक पल वे उत्साहित हो सकती हैं और अगले ही पल परेशान — शुरुआती गर्भावस्था में यह उतार-चढ़ाव आम बात है। सब्र और ध्यान से सुनना ही वह सबसे अच्छी चीज़ है जो आप दे सकते हैं।'),
  8: LocalizedText(
      en: "With her first big scan coming up, she's probably feeling a mix of excitement and uncertainty. Offer to go with her - it helps to have you there.",
      hi: 'पहला बड़ा स्कैन पास आते ही उनके मन में उत्साह और अनिश्चय दोनों होंगे। साथ चलने की पेशकश कीजिए — आपका वहाँ होना बहुत सहारा देता है।'),
  9: LocalizedText(
      en: "She may feel more connected to the pregnancy now, even while wondering what's ahead. Small check-ins - 'how are you feeling today?' - mean a lot.",
      hi: 'अब उन्हें गर्भावस्था से ज़्यादा जुड़ाव महसूस हो सकता है, भले ही आगे क्या होगा यह सवाल मन में रहे। छोटे-छोटे सवाल — आज कैसा लग रहा है — बहुत मायने रखते हैं।'),
  10: LocalizedText(
      en: "She may feel closer to the pregnancy while still carrying some uncertainty about the future. Just being someone she can talk it through with helps settle the nerves.",
      hi: 'उन्हें गर्भावस्था से नज़दीकी महसूस हो सकती है, और साथ ही आगे को लेकर थोड़ी अनिश्चितता भी। बस ऐसा कोई होना जिससे वे खुलकर बात कर सकें, घबराहट को शांत कर देता है।'),
  11: LocalizedText(
      en: "She may feel more confident than a few weeks ago, though the odd worry is still completely normal. Keep reassuring her - and keep showing up at the appointments.",
      hi: 'कुछ हफ़्ते पहले के मुक़ाबले वे अब ज़्यादा भरोसे में महसूस कर सकती हैं, फिर भी कभी-कभार फ़िक्र होना बिलकुल आम बात है। उन्हें भरोसा दिलाते रहिए — और हर मुलाक़ात में साथ जाते रहिए।'),
  12: LocalizedText(
      en: "Reaching the end of the first trimester, she may feel relief, gratitude and fresh confidence. A lovely moment to celebrate together - you've come through the hardest early stretch.",
      hi: 'पहली तिमाही के आख़िर तक पहुँचते हुए उन्हें राहत, शुक्रगुज़ारी और नया भरोसा महसूस हो सकता है। यह साथ मिलकर जश्न मनाने का प्यारा पल है — सबसे मुश्किल शुरुआती दौर आप दोनों पार कर आए हैं।'),
  13: LocalizedText(
      en: "As the first trimester closes, relief and excitement often take the place of the early uncertainty. A good time to start dreaming and planning the next stretch together.",
      hi: 'पहली तिमाही ख़त्म होते-होते शुरुआती अनिश्चितता की जगह अक्सर राहत और उत्साह ले लेते हैं। अगले पड़ाव के सपने देखने और साथ मिलकर योजना बनाने का अच्छा समय है।'),
  14: LocalizedText(
      en: "She may feel more connected to the baby now that the pregnancy is starting to show to the world. Noticing the bump with her - without making her self-conscious - is a sweet way to share it.",
      hi: 'अब जब गर्भावस्था बाहर दिखने लगी है, उन्हें शिशु से और गहरा जुड़ाव महसूस हो सकता है। उनके साथ बंप को निहारना - बिना उन्हें असहज किए - इसे साथ बाँटने का प्यारा तरीक़ा है।'),
  15: LocalizedText(
      en: "She may feel more settled and optimistic now, and might be starting to picture life after the birth. It's a lovely time to dream about it together.",
      hi: 'अब उनका मन ज़्यादा ठहरा और उम्मीद से भरा हो सकता है, और वो प्रसव के बाद की ज़िंदगी की कल्पना करने लगी होंगी। इसे साथ मिलकर सपनों में बुनने का प्यारा समय है।'),
  16: LocalizedText(
      en: "She's likely feeling more confident and emotionally settled in this phase. A good stretch to enjoy together before the busier weeks ahead.",
      hi: 'इस दौर में वो शायद ज़्यादा आश्वस्त और मन से ठहरी हुई महसूस कर रही हैं। आगे के व्यस्त हफ़्तों से पहले इसे साथ जीने का अच्छा पड़ाव है।'),
  17: LocalizedText(
      en: "Excitement often grows around now as she starts anticipating the first movements she'll actually feel. Ask her about them - sharing that wait builds the bond.",
      hi: 'इस समय उत्साह अक्सर बढ़ जाता है, क्योंकि वो पहली हलचल के इंतज़ार में रहने लगती हैं। उनसे इसके बारे में पूछिए - वो इंतज़ार साथ बाँटना जुड़ाव गहरा करता है।'),
  18: LocalizedText(
      en: "With the anomaly scan approaching, excitement is building and the baby feels more real than ever for her. Plan to be at that scan with her if you can.",
      hi: 'anomaly scan पास आते-आते उत्साह बढ़ रहा है और उनके लिए शिशु की मौजूदगी पहले से कहीं ज़्यादा असली लगती है। हो सके तो उस स्कैन पर उनके साथ रहने की योजना बनाइए।'),
  19: LocalizedText(
      en: "She may feel excited about the anomaly scan while also wondering what the second half of pregnancy holds. Being curious alongside her - not rushing to reassure - helps most.",
      hi: 'उन्हें anomaly scan को लेकर उत्साह हो सकता है, और साथ ही यह सवाल भी कि गर्भावस्था का बाक़ी आधा हिस्सा क्या लेकर आएगा। उनके साथ जिज्ञासु बने रहना - जल्दी से भरोसा दिलाने के बजाय - सबसे ज़्यादा काम आता है।'),
  20: _fMotherBrief,
  21: LocalizedText(
      en: "As the movements get more frequent and noticeable, she's likely feeling more and more connected to the baby. Put a hand on the bump with her when there's a kick - it's a moment you can share.",
      hi: 'जैसे-जैसे हलचल बार-बार और साफ़ होती जाती है, उनका जुड़ाव शिशु से और गहरा होता जाता है। जब हलचल हो तो उनके साथ बंप पर हाथ रखिए - यह पल आप दोनों का है।'),
  22: LocalizedText(
      en: "Many mothers feel a stronger bond once they realise the baby can hear their voice - she may too. A good reason for you both to talk and sing to the bump now.",
      hi: 'कई माँओं का जुड़ाव तब और गहरा हो जाता है जब उन्हें पता चलता है कि शिशु को उनकी आवाज़ सुनाई देती है - उनके साथ भी ऐसा हो सकता है। अब आप दोनों के लिए बंप से बातें करने और गुनगुनाने की अच्छी वजह है।'),
  23: LocalizedText(
      en: "She's likely feeling deeply connected now as the baby's movement patterns become familiar. She may start noticing when the baby is awake or resting - ask her about it.",
      hi: 'अब जब शिशु की हलचल का ढंग पहचाना-सा लगने लगा है, उनका जुड़ाव गहरा होता जा रहा है। वो पहचानने लगेंगी कि कब जागने का समय है और कब आराम का - उनसे इस बारे में पूछिए।'),
  24: LocalizedText(
      en: "As the baby's movement patterns become familiar, she may be feeling a deeper connection. Around now there may be a glucose test too - offer to go along and keep her company.",
      hi: 'जैसे-जैसे शिशु की हलचल का ढंग पहचाना-सा लगता है, उनका जुड़ाव और गहरा हो सकता है। इसी समय glucose test भी हो सकता है - साथ चलने और उनका साथ देने की पेशकश कीजिए।'),
  25: LocalizedText(
      en: "She may feel a deeper connection as she starts recognising the baby's own unique movement patterns. When she points one out, lean in - those shared moments matter.",
      hi: 'जब वो शिशु की अपनी ख़ास हलचल पहचानने लगती हैं, जुड़ाव और गहरा हो जाता है। जब वो कोई हलचल दिखाएँ तो पास आकर ध्यान दीजिए - साथ बाँटे हुए ये पल बहुत मायने रखते हैं।'),
  26: LocalizedText(
      en: "She may feel grateful and connected, and increasingly aware that the third trimester is near. A good moment to start thinking together about the months ahead.",
      hi: 'उनके मन में कृतज्ञता और जुड़ाव हो सकता है, और यह एहसास भी बढ़ रहा है कि तीसरी तिमाही क़रीब है। आने वाले महीनों के बारे में साथ मिलकर सोचना शुरू करने का अच्छा पल है।'),
  27: LocalizedText(
      en: "Entering the final trimester, she may feel proud, excited and a little overwhelmed all at once. Taking a few things off her plate now goes a long way.",
      hi: 'आख़िरी तिमाही में क़दम रखते हुए उन्हें गर्व, उत्साह और थोड़ा भारीपन एक साथ महसूस हो सकता है। अभी उनके कुछ काम अपने ज़िम्मे ले लेना बहुत बड़ी मदद है।'),
  28: LocalizedText(
      en: "She may be balancing excitement about meeting the baby with the first real thoughts about labour and birth. A good time to start learning the plan together.",
      hi: 'शिशु से मिलने के उत्साह के साथ-साथ उनके मन में प्रसव के बारे में पहले सच्चे सवाल भी उठ रहे होंगे। साथ मिलकर योजना समझना शुरू करने का अच्छा समय है।'),
  29: LocalizedText(
      en: "She may be thinking more and more about labour, delivery and life with the newborn. Listening as she talks it through - and helping where you can - eases the load.",
      hi: 'वो प्रसव और नवजात के साथ ज़िंदगी के बारे में ज़्यादा से ज़्यादा सोच रही होंगी। जब वो बोलकर सब समझने की कोशिश करें तो सुनिए - और जहाँ हो सके मदद कीजिए - इससे बोझ हल्का होता है।'),
  30: LocalizedText(
      en: "She may be thinking seriously now about labour, delivery and the recovery afterwards. Reading up on postpartum support with her shows you're in this for the long haul.",
      hi: 'अब वो प्रसव और उसके बाद की रिकवरी के बारे में गंभीरता से सोच रही होंगी। प्रसव के बाद की देखभाल के बारे में उनके साथ पढ़ना दिखाता है कि आप लंबे सफ़र के लिए साथ हैं।'),
  31: LocalizedText(
      en: "She may swing between excitement about meeting the baby and feeling overwhelmed by all there still is to prepare. Taking a few prep tasks off her list is a real gift right now.",
      hi: 'कभी शिशु से मिलने का उत्साह, तो कभी बाक़ी सारी तैयारी का भारीपन - उनका मन इनके बीच झूल सकता है। तैयारी के कुछ काम उनकी सूची से हटा लेना अभी सच्चा तोहफ़ा है।'),
  32: LocalizedText(
      en: "She may be mentally preparing for labour while picturing life with the newborn. Around now there's often a growth scan - go along if you can, it's reassuring for you both.",
      hi: 'नवजात के साथ ज़िंदगी की कल्पना करते हुए वो मन ही मन प्रसव की तैयारी कर रही होंगी। इसी समय अक्सर growth scan होता है - हो सके तो साथ जाइए, यह आप दोनों को भरोसा देता है।'),
  33: LocalizedText(
      en: "She may feel excited, protective and increasingly focused on getting ready for the baby's arrival. Sorting the nursery or the hospital bag together channels that energy well.",
      hi: 'उनमें उत्साह, रक्षा का भाव और शिशु के आने की तैयारी पर बढ़ता ध्यान हो सकता है। शिशु का कमरा या अस्पताल का बैग साथ मिलकर तैयार करना उस ऊर्जा को अच्छी जगह लगाता है।'),
  34: LocalizedText(
      en: "She may feel a mix of excitement, anticipation and the odd flash of nerves about labour and delivery. Steady reassurance - and having the plan ready - settles a lot of that.",
      hi: 'प्रसव को लेकर उनके मन में उत्साह, इंतज़ार और बीच-बीच में घबराहट - सब मिला-जुला हो सकता है। ठहरा हुआ भरोसा - और योजना तैयार रखना - उसमें से बहुत कुछ शांत कर देता है।'),
  35: LocalizedText(
      en: "Excitement and anticipation are often mixed with a real curiosity about when labour will start. The 'any day now' feeling is exciting - and a little nerve-wracking for her.",
      hi: 'उत्साह और इंतज़ार के साथ अक्सर यह जिज्ञासा भी रहती है कि प्रसव कब शुरू होगा। किसी भी दिन हो सकता है - यह एहसास रोमांचक भी है, और उनके लिए थोड़ा घबराहट भरा भी।'),
  36: LocalizedText(
      en: "Excitement, impatience and anticipation often grow stronger as the due date nears. This is the week to have the hospital bag packed and the plan locked in together.",
      hi: 'जैसे-जैसे डिलीवरी की तारीख़ पास आती है, उत्साह, बेसब्री और इंतज़ार और बढ़ जाते हैं। यही वो हफ़्ता है जब अस्पताल का बैग तैयार हो और योजना साथ मिलकर पक्की कर ली जाए।'),
  37: LocalizedText(
      en: "Excitement, impatience and anticipation are very common now - she may be wondering every single day whether today's the day. Keep your phone on and stay close by.",
      hi: 'अभी उत्साह, बेसब्री और इंतज़ार बहुत आम हैं - हो सकता है वो हर दिन सोचें कि क्या आज ही वो दिन है। अपना फ़ोन चालू रखिए और पास ही रहिए।'),
  38: LocalizedText(
      en: "As the end of pregnancy nears, she may feel excited, impatient, emotional or deeply reflective - sometimes all at once. Just being present and unhurried with her means a lot now.",
      hi: 'गर्भावस्था के अंत के क़रीब आते-आते उन्हें उत्साह, बेसब्री, भावुकता या गहरी सोच महसूस हो सकती है - कभी सब एक साथ। अभी बस उनके पास, बिना जल्दबाज़ी के मौजूद रहना बहुत मायने रखता है।'),
  39: LocalizedText(
      en: "She may feel excited, impatient, emotional, nervous - or all of them in the same day. Every one of those feelings is normal; your calm, steady presence is the anchor.",
      hi: 'उत्साह, बेसब्री, भावुकता, घबराहट - या एक ही दिन में यह सब उन्हें महसूस हो सकता है। इनमें से हर एहसास का आना सामान्य है; आपकी शांत, ठहरी हुई मौजूदगी ही सहारा है।'),
  40: LocalizedText(
      en: "She may feel excited, impatient, emotional, nervous, peaceful - or all of these in a single day. Every feeling is valid; you've reached the finish line together, and your steadiness matters most now.",
      hi: 'उत्साह, बेसब्री, भावुकता, घबराहट, सुकून - या एक ही दिन में यह सब उन्हें महसूस हो सकता है। हर एहसास सही है; आप दोनों साथ मिलकर आख़िरी पड़ाव तक पहुँचे हैं, और अभी आपका ठहराव सबसे ज़्यादा मायने रखता है।'),
};

// The father section brief for a week: the re-voiced copy where authored, else
// the mother's per-week content (until that week is revoiced).
LocalizedText _fBabyBriefFor(WeekContent w) =>
    _fBabyBriefs[w.week] ?? w.development.whatImDoing;
LocalizedText _fMotherBriefFor(WeekContent w) =>
    _fMotherBriefs[w.week] ?? w.mom.emotionalState;

// Father "What's next" - Scans & appointments only, re-voiced for the partner:
// what's coming up for her, and how he can show up for each.
const LocalizedText _fNextLabel =
    LocalizedText(en: "What's coming up", hi: 'आगे क्या आने वाला है');

class _FScan {
  const _FScan(this.week, this.emoji, this.title, this.when, this.body, this.help);
  final int week; // the anchor week, so the father's What's-next filters by week
  final String emoji;
  final LocalizedText title;
  final LocalizedText when;
  final LocalizedText body; // what the appointment is
  final LocalizedText help; // how he can show up for it
}

const LocalizedText _fScansIntro = LocalizedText(
    en: "These are the same scans and check-ups she'll have - here's what each one is, and how to be there for it.",
    hi: 'ये वही स्कैन और जाँचें हैं जो उनकी होंगी - हर एक क्या है, और उसमें कैसे साथ देना है, यहाँ देखिए।');

// The MOTHER's scans (same data as kJourneyMilestones medical), re-voiced for the
// partner: what each is + how to show up. One per scan type, filtered by week, so
// the father's What's-next works on EVERY week (not just 20). NOT father-only
// scans - the same appointments, his lens.
const List<_FScan> _fScans = [
  _FScan(
    7,
    '🔎',
    LocalizedText(en: 'Dating / early scan', hi: 'Dating / early scan'),
    LocalizedText(en: 'Weeks 6–9', hi: 'हफ़्ते 6–9'),
    LocalizedText(
        en: "The first proper look at the baby - it confirms the due date and the heartbeat. For many couples this is the moment it all feels real.",
        hi: 'शिशु की पहली ठीक-ठीक झलक - इससे डिलीवरी की तारीख़ और धड़कन पक्की होती है। कई जोड़ों के लिए यही वो पल होता है जब सब कुछ असली लगने लगता है।'),
    LocalizedText(
        en: "Go with her if you can - it's a lovely first memory to share. A full bladder is often needed, so plan the timing together.",
        hi: 'हो सके तो उनके साथ जाइए - यह साथ बाँटने वाली पहली प्यारी याद है। अक्सर स्कैन से पहले पानी पीकर पेशाब रोकना पड़ता है, इसलिए समय साथ मिलकर तय कीजिए।'),
  ),
  _FScan(
    12,
    '🧬',
    LocalizedText(en: 'NT scan & first screening', hi: 'NT scan और पहली screening'),
    LocalizedText(en: 'Weeks 11–14', hi: 'हफ़्ते 11–14'),
    LocalizedText(
        en: "A scan (often with a blood test) that checks the baby's growth and screens for some conditions. Waiting for the results can stir a little anxiety.",
        hi: 'एक स्कैन (अक्सर blood test के साथ) जो शिशु की बढ़त देखता है और कुछ स्थितियों की जाँच करता है। नतीजों का इंतज़ार थोड़ी घबराहट ला सकता है।'),
    LocalizedText(
        en: "Be there for the appointment, and be the steady one while you wait for results. Most come back reassuring.",
        hi: 'जाँच के समय साथ रहिए, और नतीजों के इंतज़ार में ठहरा हुआ सहारा बनिए। ज़्यादातर नतीजे भरोसा देने वाले ही आते हैं।'),
  ),
  _FScan(
    20,
    '🔍',
    LocalizedText(
        en: 'Her 20-week anomaly scan', hi: 'उनका 20 हफ़्ते वाला anomaly scan'),
    LocalizedText(en: 'Weeks 18–22', hi: 'हफ़्ते 18–22'),
    LocalizedText(
        // PCPNDT: dropped "and often shows the sex, if you both want to know".
        // Disclosing it is illegal in India, so promising it here only sets a
        // couple up to ask the sonographer and be refused.
        en: "This detailed scan checks the baby's heart, brain, spine and organs. A big, emotional moment, and most findings are reassuring.",
        hi: "यह विस्तृत स्कैन शिशु के दिल, दिमाग़, रीढ़ और अंगों की जाँच करता है। एक बड़ा, भावुक पल — और ज़्यादातर नतीजे राहत देने वाले होते हैं।"),
    LocalizedText(
        en: "Go with her if you possibly can. Write your questions down together beforehand, and just be the calm beside her in the room.",
        hi: 'हो सके तो ज़रूर उनके साथ जाइए। सवाल पहले से साथ मिलकर लिख लीजिए, और कमरे में उनके पास बस शांत मौजूदगी बनकर रहिए।'),
  ),
  _FScan(
    26,
    '🩸',
    LocalizedText(en: 'Glucose screening', hi: 'Glucose screening'),
    LocalizedText(en: 'Weeks 24–28', hi: 'हफ़्ते 24–28'),
    LocalizedText(
        en: "A routine test for gestational diabetes. She may have to fast and then wait a while after a sugary drink, so it can be a long, tiring morning for her.",
        hi: 'gestational diabetes के लिए एक आम जाँच। उन्हें ख़ाली पेट रहना पड़ सकता है और मीठा पेय पीने के बाद कुछ देर इंतज़ार करना होता है, इसलिए उनके लिए सुबह लंबी और थकाने वाली हो सकती है।'),
    LocalizedText(
        en: "Offer to drive and keep her company through the waiting. Have a proper snack ready for the minute it's done.",
        hi: 'उन्हें ले जाने और इंतज़ार में साथ बैठने की पेशकश कीजिए। जाँच ख़त्म होते ही खाने को कुछ अच्छा तैयार रखिए।'),
  ),
  _FScan(
    32,
    '📏',
    LocalizedText(en: 'Growth scan', hi: 'Growth scan'),
    LocalizedText(en: 'Weeks 30–34', hi: 'हफ़्ते 30–34'),
    LocalizedText(
        en: "A check on the baby's size, position and the fluid around them, making sure everything is on track for the weeks ahead.",
        hi: 'शिशु का आकार, स्थिति और आसपास के पानी की जाँच, ताकि आने वाले हफ़्तों के लिए सब ठीक रास्ते पर हो।'),
    LocalizedText(
        en: "Another lovely one to attend together. If the baby isn't head-down yet, don't worry - there's still plenty of time to turn.",
        hi: 'साथ जाने का एक और प्यारा मौक़ा। अगर अभी सिर नीचे की ओर नहीं है तो चिंता मत कीजिए - पलटने के लिए अभी काफ़ी समय है।'),
  ),
  _FScan(
    36,
    '📝',
    LocalizedText(en: 'Birth plan & final checks', hi: 'बर्थ प्लान और आख़िरी जाँचें'),
    LocalizedText(en: 'Weeks 36–38', hi: 'हफ़्ते 36–38'),
    LocalizedText(
        en: "Around now you'll talk through the birth plan, and she may have a GBS swab and more frequent check-ups as the due date nears.",
        hi: 'इसी समय आप प्रसव की योजना पर बात करेंगे, और डिलीवरी की तारीख़ पास आते ही उनका GBS swab और ज़्यादा बार जाँचें हो सकती हैं।'),
    LocalizedText(
        en: "Learn the plan with her so you can speak up for her on the day. Pack the hospital bag together and keep the car ready.",
        hi: 'योजना उनके साथ मिलकर समझिए ताकि उस दिन आप उनकी आवाज़ बन सकें। अस्पताल का बैग साथ तैयार कीजिए और गाड़ी तैयार रखिए।'),
  ),
];

// Father trimester section - same topics as the mother's tips, re-voiced as
// "what she's going through + how you can help" (he isn't in the trimester, so
// the heading avoids "your trimester tips").
const LocalizedText _fTipsTitle = LocalizedText(
    en: 'Supporting her this trimester', hi: 'इस तिमाही में उनका साथ');
const LocalizedText _fTipsSubtitle = LocalizedText(
    en: "What she's going through - and how to help",
    hi: 'वो किस दौर से गुज़र रही हैं - और आप कैसे मदद कर सकते हैं');

// Father "supporting her this trimester" tips, now PER-TRIMESTER so every week
// has them (T1/T3 added; T2 kept). Re-voiced as "what she's going through + how
// you can help."
const Map<int, List<TrimesterTip>> _fTrimesterTips = {
  // First trimester - early days, mostly invisible but hard for her.
  1: [
    TrimesterTip(
      emoji: '🤢',
      title: LocalizedText(
          en: 'Ride out the nausea with her',
          hi: 'मिचली के दिनों में साथ रहिए'),
      body: LocalizedText(
          en: "Morning sickness and bone-deep tiredness are at their worst now, even though nothing shows yet. Keep plain crackers by the bed, offer ginger or lemon water, and never take the mood swings personally - it's the hormones, not you.",
          hi: 'सुबह की मतली और हड्डियों तक उतरी थकान अभी सबसे ज़्यादा होती है, भले बाहर कुछ न दिखे। बिस्तर के पास सादे बिस्कुट रखिए, अदरक या नींबू पानी दीजिए, और मूड के उतार-चढ़ाव को कभी दिल पर मत लीजिए - यह हॉर्मोन हैं, आप नहीं।'),
    ),
    TrimesterTip(
      emoji: '🩺',
      title: LocalizedText(
          en: 'Come to the first scan',
          hi: 'पहले scan पर साथ जाइए'),
      body: LocalizedText(
          en: "The early dating scan and booking appointment usually happen now - the first glimpse of the baby and the heartbeat. Go with her if you can; it's a big, emotional first, and there's a lot to take in together.",
          hi: 'शुरुआती dating scan और पहली जाँच अक्सर अभी होती है - शिशु और धड़कन की पहली झलक। हो सके तो उनके साथ जाइए; यह एक बड़ा, भावुक पहला पल है, और साथ मिलकर समझने लायक़ बहुत कुछ होता है।'),
    ),
    TrimesterTip(
      emoji: '🍲',
      title: LocalizedText(
          en: 'Take the cooking off her plate',
          hi: 'खाना बनाना अपने ज़िम्मे ले लीजिए'),
      body: LocalizedText(
          en: "Smells and food aversions can make cooking unbearable for her right now. Step in - cook, order, or keep strong smells out of the kitchen - and keep simple snacks and water within her reach all day.",
          hi: 'अभी गंध और खाने से होने वाली अरुचि की वजह से रसोई का काम उनके लिए मुश्किल हो सकता है। आगे आइए - खाना बनाइए, मँगवाइए, या तेज़ गंध रसोई से दूर रखिए - और दिन भर सादा खाने-पीने का सामान और पानी उनके पास रखिए।'),
    ),
  ],
  // Second trimester - the gentlest stretch.
  2: [
    TrimesterTip(
      emoji: '🔍',
      title: LocalizedText(
          en: 'Be there for her anomaly scan',
          hi: 'उनके anomaly scan पर साथ रहिए'),
      body: LocalizedText(
          en: "Around weeks 18–22, this detailed scan checks your baby's heart, brain, spine and organs. Go with her if you can - your presence steadies the nerves these visits can stir. Write the questions down together beforehand. Most findings are reassuring.",
          hi: 'लगभग 18–22 हफ़्ते में यह विस्तार से किया जाने वाला स्कैन शिशु के दिल, दिमाग़, रीढ़ और अंगों को देखता है। हो सके तो उनके साथ जाइए - आपकी मौजूदगी इन मुलाक़ातों की घबराहट संभाल लेती है। सवाल पहले से साथ मिलकर लिख लीजिए। ज़्यादातर नतीजे भरोसा देने वाले होते हैं।'),
    ),
    TrimesterTip(
      emoji: '🛌',
      title: LocalizedText(
          en: 'Help her sleep on her side',
          hi: 'उन्हें करवट लेकर सोने में मदद कीजिए'),
      body: LocalizedText(
          en: "As her bump grows, sleeping on her side - the left is ideal - helps blood and nutrients reach the baby. Slip a pillow between her knees or under the bump. If she wakes up on her back, gently help her settle back onto her side.",
          hi: 'जैसे-जैसे बंप बढ़ता है, करवट लेकर सोना - ख़ासकर बाईं ओर - ख़ून और पोषण को शिशु तक पहुँचाने में मदद करता है। उनके घुटनों के बीच या बंप के नीचे तकिया लगा दीजिए। अगर वो पीठ के बल जाग जाएँ तो प्यार से उन्हें फिर करवट पर ले आइए।'),
    ),
    TrimesterTip(
      emoji: '🥗',
      title: LocalizedText(
          en: 'Keep iron & calcium easy for her',
          hi: 'Iron और Calcium उन तक आसानी से पहुँचाइए'),
      body: LocalizedText(
          en: "Her body is building the baby's bones and blood right now. Keep iron (leafy greens, dal, jaggery) and calcium (milk, curd, paneer) within easy reach, and pair iron-rich foods with a little vitamin C. Remind her gently about any supplements the doctor prescribed.",
          hi: 'अभी उनका शरीर शिशु की हड्डियाँ और ख़ून बना रहा है। Iron (हरी पत्तेदार सब्ज़ियाँ, दाल, गुड़) और Calcium (दूध, दही, पनीर) पास ही रखिए, और Iron वाले खाने के साथ थोड़ा Vitamin C दीजिए। डॉक्टर की लिखी दवाइयों के लिए उन्हें प्यार से याद दिलाते रहिए।'),
    ),
  ],
  // Third trimester - getting ready, getting heavier.
  3: [
    TrimesterTip(
      emoji: '🎒',
      title: LocalizedText(
          en: 'Get the hospital bag ready',
          hi: 'अस्पताल बैग तैयार कीजिए'),
      body: LocalizedText(
          en: "Baby could come a little early, so it pays to be ready. Pack the hospital bag together, know the route to the hospital, keep the car fuelled, and save the important numbers where you can find them fast.",
          hi: 'शिशु का आना थोड़ा जल्दी भी हो सकता है, इसलिए तैयार रहना अच्छा है। अस्पताल का बैग साथ तैयार कीजिए, अस्पताल का रास्ता जान लीजिए, गाड़ी में तेल रखिए, और ज़रूरी नंबर ऐसी जगह सहेजिए जहाँ फ़ौरन मिल जाएँ।'),
    ),
    TrimesterTip(
      emoji: '😴',
      title: LocalizedText(
          en: 'Help her rest through the discomfort',
          hi: 'तकलीफ़ के बीच उन्हें आराम दिलाइए'),
      body: LocalizedText(
          en: "Heartburn, a heavy bump and broken sleep make these weeks tiring. Pile up the pillows, take the late-night and early-morning chores, and protect her naps without making her feel guilty about them.",
          hi: 'सीने की जलन, भारी बंप और टूटती नींद इन हफ़्तों को थकाने वाला बना देते हैं। तकिए लगा दीजिए, देर रात और तड़के के काम अपने ज़िम्मे लीजिए, और उनकी झपकी बचाइए - बिना उन्हें इसका अपराध-बोध कराए।'),
    ),
    TrimesterTip(
      emoji: '📞',
      title: LocalizedText(
          en: 'Learn the signs of labour',
          hi: 'प्रसव के लक्षण पहचानना सीखिए'),
      body: LocalizedText(
          en: "Know the difference between real contractions and practice (Braxton-Hicks) ones, what 'waters breaking' looks like, and when the hospital wants a call. Keep your phone on and charged - being reachable is half the job.",
          hi: 'असली संकुचन और अभ्यास वाले (Braxton-Hicks) संकुचन का फ़र्क़ जानिए, पानी की थैली फटना कैसा होता है यह भी, और अस्पताल को कब फ़ोन करना है। अपना फ़ोन चालू और चार्ज रखिए - पहुँच में रहना आधा काम है।'),
    ),
  ],
};

// Father "don't miss" body - points to what's actually on HIS home (daily read,
// a story to read aloud, a journal prompt - NOT Garbh Sanskar).
const LocalizedText _fDailyBridgeBody = LocalizedText(
    en: 'Your daily read, a story to read aloud and a journal prompt are waiting for you on Home.',
    hi: 'आपका रोज़ का पढ़ना, सुनाने के लिए एक कहानी, और एक जर्नल सवाल — सब होम पर आपका इंतज़ार कर रहे हैं।');

const List<_Article> _babyArticleFather = [
  _Article(
      LocalizedText(en: "You're halfway there! 🎉", hi: 'आप आधे रास्ते पर हैं! 🎉'),
      LocalizedText(
          en: "You've reached the middle of the journey together! Baby is growing quickly now, her bump is showing, and any day now she might feel baby move for the very first time.",
          hi: 'आप दोनों साथ मिलकर इस सफ़र के आधे रास्ते पर पहुँच गए हैं! शिशु की बढ़त अब तेज़ है, उनका बंप दिखने लगा है, और किसी भी दिन उन्हें पहली बार हलचल महसूस हो सकती है।')),
  _Article(
      LocalizedText(en: 'How big is baby?', hi: 'शिशु का आकार अभी कितना है?'),
      LocalizedText(
          en: "Baby is about the size of a banana now - roughly 25 cm from head to heel and around 300 g. From this week, length is measured head-to-heel instead of head-to-bottom.",
          hi: 'अभी शिशु का आकार लगभग एक केले जितना है - सिर से एड़ी तक क़रीब 25 cm और तक़रीबन 300 g। इस हफ़्ते से लंबाई सिर से एड़ी तक नापी जाती है, सिर से कूल्हे तक नहीं।')),
  _Article(
      LocalizedText(en: "She'll feel baby move", hi: 'उन्हें हलचल महसूस होगी'),
      LocalizedText(
          en: "Baby's first little flutters - called \"quickening\" - often start around now. They feel like bubbles or a gentle tap, and over the next few weeks they'll grow into clear kicks. With a first baby she might feel them a little later - that's completely normal.",
          hi: 'शिशु की पहली हल्की हलचल - जिसे quickening कहते हैं - अक्सर इसी समय शुरू होती है। यह बुलबुलों या हल्की थपकी जैसी लगती है, और अगले कुछ हफ़्तों में साफ़ और मज़बूत हलचल में बदल जाती है। पहली गर्भावस्था में उन्हें यह थोड़ी देर से महसूस हो सकती है - यह बिलकुल सामान्य है।')),
  _Article(
      LocalizedText(en: 'Baby can hear you both now', hi: 'अब शिशु तक आप दोनों की आवाज़ पहुँचती है'),
      LocalizedText(
          en: "The tiny bones in baby's ears are in place, so baby can hear her voice, yours, the heartbeat and the world around. When you talk, hum or sing, it helps you bond - and baby will often recognise a favourite tune after birth.",
          hi: 'शिशु के कानों की नन्ही हड्डियाँ अपनी जगह बन चुकी हैं, इसलिए अब शिशु को उनकी आवाज़, आपकी आवाज़, धड़कन और आसपास की दुनिया सुनाई देती है। जब आप बात करते हैं, गुनगुनाते या गाते हैं, तो जुड़ाव बनता है - और जन्म के बाद अक्सर पसंदीदा धुन पहचानी जाती है।')),
  _Article(
      LocalizedText(en: "Baby's tasting her meals", hi: 'शिशु तक उनके खाने का स्वाद पहुँचता है'),
      LocalizedText(
          en: "Baby swallows a little amniotic fluid through the day, and new taste buds pick up the flavours of whatever she eats. A varied, balanced diet now might even shape what baby loves to eat later!",
          hi: 'दिन भर में थोड़ा amniotic fluid शिशु के भीतर जाता है, और नई स्वाद-कलियाँ उनके खाने का स्वाद पकड़ लेती हैं। अभी का अलग-अलग तरह का संतुलित खाना आगे चलकर शिशु की पसंद भी बना सकता है!')),
  _Article(
      LocalizedText(en: "Baby's skin, hair and vernix", hi: 'शिशु की त्वचा, बाल और vernix'),
      LocalizedText(
          en: "A soft creamy coating called vernix and a layer of fine hair (lanugo) are protecting baby's delicate skin. Underneath, baby is building up the fat that will keep them warm and cosy after birth.",
          hi: 'vernix नाम की एक नरम मलाई जैसी परत और महीन बालों की एक तह (lanugo) शिशु की नाज़ुक त्वचा को बचा रही हैं। इसके नीचे वो चर्बी बन रही है जो जन्म के बाद गर्मी और आराम देगी।')),
  _Article(
      LocalizedText(en: 'Baby sleeps and wakes', hi: 'शिशु का सोना और जागना'),
      LocalizedText(
          en: "Baby is settling into their own sleep-and-wake cycles, and is often most active just when she lies down to rest! Noticing those patterns is the start of getting to know your little one.",
          hi: 'शिशु के सोने-जागने का अपना ढंग बनने लगा है, और सबसे ज़्यादा हलचल अक्सर तभी होती है जब वो आराम करने लेटती हैं! इस ढंग को पहचानना अपने शिशु को जानने की शुरुआत है।')),
];

const List<_Fact> _babyScienceFather = [
  _Fact(
      '🧠',
      Color(0xFFF2E9FB),
      // Titles rewritten as complete sentences (card shows heading only now).
      LocalizedText(
          en: "Baby's brain is growing at an astonishing pace",
          hi: 'शिशु के दिमाग़ की बढ़त हैरान कर देने वाली रफ़्तार से'),
      LocalizedText(
          en: "Your baby is forming millions of new nerve connections every single day - that little brain is working at an astonishing pace!",
          hi: 'हर दिन शिशु के दिमाग़ में लाखों नए संपर्क बन रहे हैं - वो नन्हा दिमाग़ हैरान कर देने वाली रफ़्तार से काम कर रहा है!')),
  _Fact(
      '🤏',
      Color(0xFFFCE3E6),
      LocalizedText(
          en: 'Baby can already curl those tiny fingers',
          hi: 'नन्ही उँगलियाँ अभी से मुड़ने लगी हैं'),
      LocalizedText(
          en: "Baby can curl those little fingers and sometimes grabs the umbilical cord - practising for your very first cuddles.",
          hi: 'शिशु की नन्ही उँगलियाँ अब मुड़ने लगी हैं और कभी-कभी गर्भनाल पकड़ में आ जाती है - मानो आपकी पहली झप्पी की तैयारी हो।')),
  _Fact(
      '🫧',
      Color(0xFFE6F0FA),
      LocalizedText(en: 'Baby gets hiccups!', hi: 'शिशु को हिचकी आती है!'),
      LocalizedText(
          en: "Sometimes she'll feel tiny rhythmic taps - that's just baby having hiccups, and it's completely normal.",
          hi: 'कभी-कभी उन्हें छोटी-छोटी लयबद्ध थपकियाँ महसूस होंगी - यह बस शिशु की हिचकी है, और बिलकुल सामान्य है।')),
  _Fact(
      '🦶',
      Color(0xFFFDF0C4),
      LocalizedText(
          en: "Baby's own fingerprints are forming right now",
          hi: 'शिशु की अपनी उँगलियों के निशान अभी बन रहे हैं'),
      LocalizedText(
          en: "Baby's very own fingerprints - and footprints - are forming right now, patterns that will be theirs alone for life.",
          hi: 'शिशु की अपनी उँगलियों - और पैरों - के निशान अभी बन रहे हैं, ऐसे निशान जो ज़िंदगी भर सिर्फ़ शिशु के अपने रहेंगे।')),
  _Fact(
      '💗',
      Color(0xFFEAF1EA),
      LocalizedText(
          en: "Baby's heart is beating strong and steady",
          hi: 'शिशु की धड़कन मज़बूत और ठहरी हुई है'),
      LocalizedText(
          en: "Baby's heart is pumping hard, moving several litres of blood around that tiny body every single day.",
          hi: 'शिशु का दिल ज़ोर से काम कर रहा है, हर दिन कई लीटर ख़ून उस नन्हे शरीर में घुमाता है।')),
  _Fact(
      '🌗',
      Color(0xFFEDEAF6),
      LocalizedText(
          en: 'Baby can sense light through the bump',
          hi: 'शिशु को बंप के पार से रोशनी महसूस होती है'),
      LocalizedText(
          en: 'Shine a soft light on her bump and baby might turn towards it - those eyes are getting ready to see you both.',
          hi: 'उनके बंप पर हल्की रोशनी डालिए, हो सकता है शिशु उसी ओर मुड़ जाए — वे आँखें आप दोनों को देखने की तैयारी कर रही हैं।')),
];

const List<_Article> _motherArticleFather = [
  _Article(
      LocalizedText(en: 'How she might be feeling', hi: 'वे कैसा महसूस कर रही होंगी'),
      LocalizedText(
          en: "The second trimester is often the gentlest stretch of pregnancy - the early nausea has usually eased, her energy is back, and her bump is becoming a lovely, visible reminder of the little one growing inside. Emotionally, though, it can still be a rollercoaster: moments of pure joy, then a wave of worry or tears from nowhere. That's completely normal. Her hormones are working hard, and feeling everything a little more deeply is simply part of it.",
          hi: 'दूसरी तिमाही अक्सर गर्भावस्था का सबसे कोमल दौर होती है - शुरुआती मतली आमतौर पर कम हो जाती है, उनकी ऊर्जा लौट आती है, और उनका बंप भीतर पल रहे नन्हे जीव की प्यारी, दिखने वाली निशानी बन जाता है। फिर भी मन का हाल झूले जैसा हो सकता है: कभी शुद्ध ख़ुशी के पल, तो कभी बिना बात चिंता या आँसुओं की लहर। यह बिलकुल सामान्य है। उनके हॉर्मोन बहुत मेहनत कर रहे हैं, और हर बात को थोड़ा गहराई से महसूस करना इसी का हिस्सा है।')),
  _Article(
      LocalizedText(en: 'Her changing body', hi: 'उनका बदलता शरीर'),
      LocalizedText(
          en: "Around now her womb has risen to about her belly button, and many mothers notice their bump 'pop' this month. A few new aches can come with it - a stretching feeling low in the belly, a little backache, or the odd dizzy moment. None of it means something is wrong; her body is simply making room. Moving gently, standing up slowly, and resting all help - and so does your hand to lean on.",
          hi: 'इस समय तक उनका गर्भाशय लगभग नाभि तक आ जाता है, और कई माँएँ इसी महीने अपना बंप अचानक उभरता हुआ पाती हैं। इसके साथ कुछ नई तकलीफ़ें आ सकती हैं - पेट के निचले हिस्से में खिंचाव, हल्का कमर दर्द, या कभी-कभी चक्कर। इनमें से कुछ भी ग़लत नहीं है; उनका शरीर बस जगह बना रहा है। धीरे-धीरे चलना, आराम से उठना और आराम करना - सब मदद करते हैं, और आपका सहारा भी।')),
  _Article(
      LocalizedText(en: 'The first flutters', hi: 'पहली हल्की हलचल'),
      LocalizedText(
          en: "Week 20 is famous for one magical milestone - the first movements, often called 'quickening'. They can feel like bubbles, a gentle tap, or a tiny flutter, and are easy to miss at first. Over the coming weeks they grow into unmistakable kicks. If she hasn't felt anything yet, there's no need to worry - a first pregnancy or the position of the placenta can both delay it, and it will come.",
          hi: '20वाँ हफ़्ता एक जादुई पड़ाव के लिए मशहूर है - पहली हलचल, जिसे अक्सर quickening कहते हैं। यह बुलबुलों, हल्की थपकी या नन्ही सी फुरफुरी जैसी लग सकती है, और शुरू में इसका पता चलना मुश्किल होता है। आने वाले हफ़्तों में यह साफ़ और पहचानी जाने वाली हलचल बन जाती है। अगर उन्हें अभी तक कुछ महसूस नहीं हुआ तो चिंता की बात नहीं - पहली गर्भावस्था या प्लेसेंटा की स्थिति, दोनों इसे थोड़ा देर से ला सकती हैं, और यह ज़रूर आएगी।')),
  _Article(
      LocalizedText(en: 'How to be there for her', hi: 'उनका साथ कैसे दें'),
      LocalizedText(
          en: "This is a beautiful time to help her slow down and connect - a few quiet minutes with a hand on the bump, a short walk together, a proper night's sleep. Ask how she's feeling and really listen. Looking after her calm is one of the very best things you can do for your baby right now.",
          hi: 'यह उन्हें थमने और जुड़ने में मदद करने का ख़ूबसूरत समय है - बंप पर हाथ रखे कुछ शांत मिनट, साथ में एक छोटी सी सैर, या भरपूर नींद। पूछिए कि वो कैसा महसूस कर रही हैं, और सचमुच सुनिए। उनके सुकून का ख़याल रखना अभी शिशु के लिए आप जो सबसे अच्छी चीज़ें कर सकते हैं, उनमें से एक है।')),
];

const List<_MotherTopic> _motherTopicsFather = [
  _MotherTopic(
      '🌀',
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'Levels are steadier now - she may have more energy.',
          hi: 'अब स्तर ज़्यादा स्थिर हैं — उन्हें ज़्यादा ऊर्जा महसूस हो सकती है।'),
      LocalizedText(
          en: "After the ups and downs of the first trimester, her hormones settle into a steadier rhythm. Many women feel a welcome lift in energy and mood - the 'pregnancy glow' often shows up around now.",
          hi: 'पहली तिमाही के उतार-चढ़ाव के बाद उनके हॉर्मोन एक ठहरी हुई लय में आ जाते हैं। कई महिलाओं की ऊर्जा और मूड में सुखद निखार आता है - गर्भावस्था वाली चमक अक्सर इसी समय दिखने लगती है।')),
  _MotherTopic(
      '🤰',
      LocalizedText(en: 'Her bump', hi: 'उनका बंप'),
      LocalizedText(
          en: 'The top of her uterus reaches her belly button.',
          hi: 'उनकी बच्चेदानी का ऊपरी हिस्सा नाभि तक पहुँच जाता है।'),
      LocalizedText(
          en: "Her uterus has grown to about the level of her navel, so the bump is clearly showing now. Roomier clothes and a supportive bra help, and sleeping on her side becomes the comfiest position from here on - keep a pillow handy for between the knees.",
          hi: 'उनका गर्भाशय लगभग नाभि तक बढ़ चुका है, इसलिए अब बंप साफ़ दिखता है। खुले कपड़े और सहारा देने वाली ब्रा आराम देते हैं, और यहाँ से आगे करवट लेकर सोना सबसे आरामदेह रहता है - घुटनों के बीच रखने के लिए एक तकिया पास रखिए।')),
  _MotherTopic(
      '🦋',
      LocalizedText(en: 'First movements', hi: 'पहली हलचल'),
      LocalizedText(
          en: 'She may feel the first gentle flutters (quickening).',
          hi: 'वे पहली हल्की हलचल (quickening) महसूस कर सकती हैं।'),
      LocalizedText(
          en: "Those first movements - called 'quickening' - often arrive around week 20. They can feel like bubbles, a light tap or butterflies, and will be irregular at first. Over the coming weeks they grow stronger and more regular. First-time mums sometimes feel them a little later - perfectly normal.",
          hi: 'पहली हलचल - जिसे quickening कहते हैं - अक्सर 20वें हफ़्ते के आसपास आती है। यह बुलबुलों, हल्की थपकी या तितलियों जैसी लग सकती है, और शुरू में बेतरतीब होती है। आने वाले हफ़्तों में यह और मज़बूत और नियमित हो जाती है। पहली बार माँ बन रही महिलाओं को यह कभी थोड़ी देर से महसूस होती है - यह पूरी तरह सामान्य है।')),
  _MotherTopic(
      '✨',
      LocalizedText(en: 'Skin & body', hi: 'त्वचा और शरीर'),
      LocalizedText(
          en: 'More blood flow brings a warm glow and fuller hair.',
          hi: 'ज़्यादा ख़ून का बहाव त्वचा पर निखार और बालों में घनापन लाता है।'),
      LocalizedText(
          en: 'The extra blood her body is making can give her skin a warm glow and her hair a fuller look. Some women notice a dark line down the belly (linea nigra) or slight skin changes - these are normal and usually fade after birth.',
          hi: 'उनका शरीर जो ज़्यादा ख़ून बना रहा है, उससे त्वचा पर निखार आता है और बाल घने लगने लगते हैं। कुछ माँओं को पेट पर एक गहरी रेखा (linea nigra) या त्वचा में हल्के बदलाव दिखते हैं — ये सामान्य हैं और जन्म के बाद अक्सर अपने आप मिट जाते हैं।')),
  _MotherTopic(
      '💗',
      LocalizedText(en: 'Heart & breath', hi: 'दिल और साँस'),
      LocalizedText(
          en: 'Her heart works harder - she may feel breathless.',
          hi: 'उनका दिल ज़्यादा मेहनत कर रहा है — साँस जल्दी फूल सकती है।'),
      LocalizedText(
          en: 'Her heart is now pumping much more blood than usual, so she may feel a little breathless on the stairs or notice her heart racing at times. Let her move at her own pace, rest when she needs to, and keep water close by.',
          hi: 'उनका दिल अब पहले से कहीं ज़्यादा ख़ून पंप कर रहा है, इसलिए सीढ़ियाँ चढ़ते हुए साँस थोड़ी फूल सकती है या कभी-कभी दिल तेज़ धड़कता लग सकता है। उन्हें अपनी रफ़्तार से चलने दीजिए, ज़रूरत लगे तो आराम करने दीजिए, और पानी पास रखिए।')),
  _MotherTopic(
      '🤕',
      LocalizedText(en: 'Aches & twinges', hi: 'दर्द और खिंचाव'),
      LocalizedText(
          en: 'Round-ligament twinges as her bump stretches.',
          hi: 'बंप के खिंचने से round-ligament में खिंचाव।'),
      LocalizedText(
          en: "She may feel occasional sharp twinges low on the sides of the bump - round-ligament pain - as the ligaments supporting her growing uterus stretch. It's usually brief and harmless; moving slowly helps. Anything severe or persistent is worth a mention to her doctor.",
          hi: 'बंप के निचले हिस्सों में कभी-कभी तेज़ खिंचाव महसूस हो सकता है - round-ligament pain - क्योंकि बढ़ते गर्भाशय को थामने वाले ligaments खिंचते हैं। यह आमतौर पर थोड़ी देर का होता है और नुक़सान नहीं करता; धीरे-धीरे हिलना-डुलना मदद करता है। कुछ भी बहुत तेज़ या लगातार बना रहे तो डॉक्टर को ज़रूर बताइए।')),
];

// Father versions of the two tint cards on the mother read (self-care/reassurance).
const LocalizedText _fHelpTitle =
    LocalizedText(en: 'How to help', hi: 'कैसे मदद करें');
const LocalizedText _fHelpBody = LocalizedText(
    en: "Run her a bath, take a chore off her plate, and make sure she's resting on her side. Small, specific help lands bigger than grand gestures right now.",
    hi: 'उनके लिए नहाने का पानी तैयार कीजिए, कोई एक काम अपने ज़िम्मे लीजिए, और ध्यान रखिए कि वो करवट लेकर आराम करें। अभी छोटी और ठीक जगह पर की गई मदद बड़ी-बड़ी बातों से ज़्यादा मायने रखती है।');
const LocalizedText _fReassureBody = LocalizedText(
    en: "These ups and downs are normal - your steady, calm presence is exactly what she needs most this week.",
    hi: 'ये उतार-चढ़ाव सामान्य हैं - इस हफ़्ते उन्हें सबसे ज़्यादा यही चाहिए: आपकी ठहरी हुई, शांत मौजूदगी।');

// ===========================================================================
//  GENERIC (week-agnostic) father DEEP READS - used on every father week EXCEPT
//  week 20 (which keeps its richer, week-specific father read). Everything here
//  is always-true and in 3rd-person partner voice, so the father never reads the
//  mother's voice (baby-to-mum / "you" = mum) on any week. See [_BabyDetailScreen]
//  / [_combinedBody].
// ===========================================================================
const List<_Article> _babyArticleGen = [
  _Article(
      LocalizedText(
          en: 'Growing a little more every day',
          hi: 'हर दिन थोड़ी और बढ़त'),
      LocalizedText(
          en: "Week by week your baby is forming and strengthening - organs, senses, muscles and brain, each on its own remarkable schedule. The note at the top of this week tells you what's developing right now.",
          hi: 'हफ़्ते-दर-हफ़्ते शिशु का शरीर बनता और मज़बूत होता जाता है - अंग, इंद्रियाँ, मांसपेशियाँ और दिमाग़, हर एक अपने ख़ास समय पर। इस हफ़्ते के ऊपर दिया नोट बताता है कि अभी क्या बन रहा है।')),
  _Article(
      LocalizedText(en: 'Your voice matters', hi: 'आपकी आवाज़ मायने रखती है'),
      LocalizedText(
          en: "From around the middle of pregnancy your baby can hear, and your voice slowly becomes familiar. Talking, humming or singing to the bump is a simple, lovely way to start bonding long before birth.",
          hi: 'गर्भावस्था के लगभग बीच से शिशु को सुनाई देने लगता है, और आपकी आवाज़ धीरे-धीरे जानी-पहचानी हो जाती है। बंप से बातें करना, गुनगुनाना या गाना जन्म से बहुत पहले जुड़ाव शुरू करने का सरल, प्यारा तरीक़ा है।')),
  _Article(
      LocalizedText(
          en: 'Every baby is on their own clock',
          hi: 'हर शिशु की अपनी रफ़्तार होती है'),
      LocalizedText(
          en: "Sizes and milestones are averages, not rules. Whether something happens a little earlier or later, it's almost always perfectly normal - and the scans are there to reassure you both along the way.",
          hi: 'आकार और पड़ाव औसत हैं, नियम नहीं। कुछ थोड़ा जल्दी हो या थोड़ा देर से, यह लगभग हमेशा पूरी तरह सामान्य होता है - और रास्ते में आप दोनों को भरोसा देने के लिए स्कैन हैं ही।')),
  _Article(
      LocalizedText(en: "You're part of this too", hi: 'आप भी इसका हिस्सा हैं'),
      LocalizedText(
          en: "Your baby will come to know your voice, your touch through the bump and the calm you bring. Being present now - for her and for your little one - is the start of a bond that lasts a lifetime.",
          hi: 'आपकी आवाज़, बंप के ज़रिए आपका स्पर्श और आपका लाया हुआ सुकून - ये सब शिशु के लिए जाने-पहचाने हो जाएँगे। अभी मौजूद रहना - उनके लिए और अपने शिशु के लिए - ज़िंदगी भर चलने वाले जुड़ाव की शुरुआत है।')),
];

const List<_Article> _motherArticleGen = [
  _Article(
      LocalizedText(
          en: 'How she might be feeling',
          hi: 'वे कैसा महसूस कर रही होंगी'),
      LocalizedText(
          en: "Pregnancy moves through very different stages, and how she feels shifts with them - energy, appetite, mood and sleep can all change from week to week. Whatever this week brings, her hormones are working hard, and feeling everything a little more deeply is simply part of it.",
          hi: 'गर्भावस्था बहुत अलग-अलग पड़ावों से गुज़रती है, और उनके साथ उनका महसूस करना भी बदलता है - ऊर्जा, भूख, मूड और नींद, सब हफ़्ते-दर-हफ़्ते बदल सकते हैं। यह हफ़्ता जो भी लाए, उनके हॉर्मोन बहुत मेहनत कर रहे हैं, और हर बात को थोड़ा गहराई से महसूस करना इसी का हिस्सा है।')),
  _Article(
      LocalizedText(en: 'Her changing body', hi: 'उनका बदलता शरीर'),
      LocalizedText(
          en: "Her body is doing extraordinary work, and that brings visible changes and the odd ache along the way. Most are completely normal and pass on their own - but anything sharp, severe or that won't settle is always worth a word with her doctor.",
          hi: 'उनका शरीर असाधारण काम कर रहा है, और उसके साथ दिखने वाले बदलाव और बीच-बीच में तकलीफ़ भी आती है। ज़्यादातर बिलकुल सामान्य होती हैं और अपने आप चली जाती हैं - लेकिन कुछ भी तेज़, गंभीर या जो थम ही न रहा हो, उसके बारे में डॉक्टर से बात ज़रूर कीजिए।')),
  _Article(
      LocalizedText(en: 'How to be there for her', hi: 'उनका साथ कैसे दें'),
      LocalizedText(
          en: "The basics matter most: ask how she's really feeling and listen, take a chore off her plate, help her rest, and turn up at the appointments. Looking after her calm is one of the very best things you can do for your baby right now.",
          hi: 'बुनियादी बातें सबसे ज़्यादा मायने रखती हैं: पूछिए कि वो सचमुच कैसा महसूस कर रही हैं और सुनिए, कोई एक काम अपने ज़िम्मे लीजिए, उन्हें आराम करने दीजिए, और जाँचों में साथ पहुँचिए। उनके सुकून का ख़याल रखना अभी शिशु के लिए आप जो सबसे अच्छी चीज़ें कर सकते हैं, उनमें से एक है।')),
];

const List<_MotherTopic> _motherTopicsGen = [
  _MotherTopic(
      '🌀',
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'They shape a lot of how she feels.',
          hi: 'ये उनके मन-मिज़ाज पर बहुत असर डालते हैं।'),
      LocalizedText(
          en: "Pregnancy hormones drive a lot of how she feels - energy, mood and appetite can all swing, sometimes within a single day. None of it is her 'being difficult'; it's her body doing its work.",
          hi: 'गर्भावस्था के हॉर्मोन उनके मन के हाल को काफ़ी हद तक चलाते हैं - ऊर्जा, मूड और भूख, सब बदल सकते हैं, कभी एक ही दिन में। इसमें से कुछ भी उनका नख़रा नहीं है; यह उनका शरीर अपना काम कर रहा है।')),
  _MotherTopic(
      '😴',
      LocalizedText(en: 'Rest & sleep', hi: 'आराम और नींद'),
      LocalizedText(
          en: 'Good sleep gets harder as time goes on.',
          hi: 'वक़्त के साथ अच्छी नींद मुश्किल होती जाती है।'),
      LocalizedText(
          en: "Comfortable sleep gets harder as pregnancy goes on. Help her wind down in the evening, take the late-night and early-morning jobs, and protect her naps without making her feel guilty.",
          hi: 'गर्भावस्था आगे बढ़ने के साथ आरामदेह नींद मुश्किल होती जाती है। शाम को उन्हें हल्का होने में मदद कीजिए, देर रात और तड़के के काम अपने ज़िम्मे लीजिए, और उनकी झपकी बचाइए - बिना उन्हें अपराध-बोध कराए।')),
  _MotherTopic(
      '💗',
      LocalizedText(en: 'Her wellbeing', hi: 'उनकी सेहत'),
      LocalizedText(
          en: 'Small steady habits help most.',
          hi: 'छोटी-छोटी लगातार आदतें सबसे ज़्यादा काम आती हैं।'),
      LocalizedText(
          en: "Gentle movement, plenty of water, decent food and a calm home all help her feel better. The single biggest thing you bring, though, is a steady, reassuring presence she can lean on.",
          hi: 'हल्की चहलक़दमी, ख़ूब पानी, अच्छा खाना और एक शांत घर - ये सब उन्हें बेहतर महसूस कराते हैं। लेकिन सबसे बड़ी चीज़ जो आप देते हैं, वो है एक ठहरी हुई, भरोसा देने वाली मौजूदगी जिसका वो सहारा ले सकें।')),
];

// ===========================================================================
//  The vertical flow
// ===========================================================================
class WeekFlowView extends StatelessWidget {
  const WeekFlowView(
      {super.key, required this.controller, this.trailing});
  final PregnancyController controller;

  /// Optional widget appended to the bottom of the flow - used for the week-40
  /// celebration finale, so the new flow keeps the keepsake-booklet moment.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      // Also listen to FatherPreview so flipping the Dad switch re-flows week 20.
      animation: Listenable.merge([controller, FatherPreview.instance]),
      builder: (context, _) {
        final w = controller.weekData(controller.selectedWeek);
        if (w == null) return const SizedBox.shrink();
        final lang = controller.language;
        final s = S(lang);
        // Father weekly = Slate colours on every week (skin); the per-week briefs
        // are re-voiced where authored, else the mother's content.
        final fatherSkin = _fatherSkin(w.week);
        final list = ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            WeekSizeHero(w: w, lang: lang, father: fatherSkin),
            const SizedBox(height: 18),
            // S2 - Weekly video.
            WeekVideoCard(w: w, lang: lang, father: fatherSkin),
            const SizedBox(height: 14),
            // S3 - About baby → Baby Science pop-up. (colour = skin, copy = week-20)
            _SectionBrief(
              icon: Icons.child_care_rounded,
              color: fatherSkin ? _fAccent : AppTheme.primary500,
              // Father FRAMING (title) on all weeks; the brief WORDING is the
              // week-20 re-voiced copy or the mother's per-week content.
              title: fatherSkin ? _fBabyTitle.of(lang) : s.wfBabySection,
              brief: (fatherSkin
                      ? _fBabyBriefFor(w)
                      : (_isW5(w.week) ? week5Full.about.teaser : w.development.whatImDoing))
                  .of(lang),
              cta: s.wfTapExplore,
              father: fatherSkin,
              // The KEY must name the passage the button is about to read out.
              // Under the father skin the words on the card are his re-voiced
              // copy, while `babyDevelopment.whatImDoing` names the MOTHER's
              // recording - pointing at it here would play her passage under
              // his text. The father namespace is deliberately absent from the
              // manifest, so it falls through to the device voice reading what
              // is actually on screen, and it is already the right key if
              // father narration is ever generated.
              narrate: NarrateButton(
                narrationKey: fatherSkin
                    ? 'father.week${w.week}.babyDevelopment.whatImDoing'
                    : NarrationService.weekKey(
                        w.week, 'babyDevelopment.whatImDoing'),
                text: (fatherSkin
                        ? _fBabyBriefFor(w)
                        : (_isW5(w.week)
                            ? week5Full.about.teaser
                            : w.development.whatImDoing))
                    .of(lang),
                englishText: (fatherSkin
                        ? _fBabyBriefFor(w)
                        : (_isW5(w.week)
                            ? week5Full.about.teaser
                            : w.development.whatImDoing))
                    .en,
                lang: lang,
                color: fatherSkin ? _fAccent : AppTheme.primary500,
              ),
              onTap: () => _push(context, _BabyDetailScreen(w: w, lang: lang)),
            ),
            const SizedBox(height: 14),
            // S4 - For you, mum (→ "How she's doing" in father preview).
            _SectionBrief(
              icon: Icons.favorite_rounded,
              color: fatherSkin ? _fAccent2 : AppTheme.secondary500,
              title: fatherSkin ? _fMotherTitle.of(lang) : s.wfMotherSection,
              brief: (fatherSkin ? _fMotherBriefFor(w) : w.mom.emotionalState)
                  .of(lang),
              cta: s.wfTapExplore,
              father: fatherSkin,
              narrate: NarrateButton(
                narrationKey: fatherSkin
                    ? 'father.week${w.week}.momJourney.emotionalState'
                    : NarrationService.weekKey(
                        w.week, 'momJourney.emotionalState'),
                text: (fatherSkin ? _fMotherBriefFor(w) : w.mom.emotionalState)
                    .of(lang),
                englishText:
                    (fatherSkin ? _fMotherBriefFor(w) : w.mom.emotionalState).en,
                lang: lang,
                color: fatherSkin ? _fAccent2 : AppTheme.secondary500,
              ),
              onTap: () => _push(context, _MotherDetailScreen(w: w, lang: lang)),
            ),
            const SizedBox(height: 14),
            // S5 - What's next.
            _SectionBrief(
              icon: Icons.event_note_rounded,
              color: fatherSkin ? _fAccent : const Color(0xFF2E9C8E),
              title: s.wfNextSection,
              brief: fatherSkin ? _fNextBrief.of(lang) : s.wfNextBrief,
              cta: s.wfTapExplore,
              father: fatherSkin,
              onTap: () => _push(
                  context, _WhatsNextScreen(controller: controller, lang: lang)),
              // Three shortcut icons - Baby, Mom, Scans - each opening its own
              // detail. The card itself still opens the full What's next pop-up.
              // Mother experience only (father's What's next is scans-only).
              footer: fatherSkin
                  ? null
                  : Row(children: [
                      _whatsNextShortcut(
                          context,
                          Icons.child_care_rounded,
                          S(lang).uiBaby,
                          AppTheme.primary500,
                          () => openWeekBabyDetail(
                              context, controller, w.week, lang)),
                      const SizedBox(width: 10),
                      _whatsNextShortcut(
                          context,
                          Icons.favorite_rounded,
                          lang.isEnglish ? 'Mom' : 'माँ',
                          AppTheme.secondary500,
                          () => openWeekMotherDetail(
                              context, controller, w.week, lang)),
                      const SizedBox(width: 10),
                      _whatsNextShortcut(
                          context,
                          Icons.event_note_rounded,
                          S(lang).uiScans,
                          const Color(0xFF2E9C8E),
                          () => openWeekScans(context, controller, lang)),
                    ]),
            ),
            const SizedBox(height: 18),
            // Organic nudge - a clean, warm reminder, woven mid-flow (NOT at the
            // top), that the daily section is waiting - without pulling her out
            // of the week.
            _DailyMomentBridge(controller: controller, father: fatherSkin),
            const SizedBox(height: 18),
            // S6 - This week's videos feed.
            _VideoFeed(lang: lang),
            const SizedBox(height: 18),
            // This week's reads - an articles carousel below the videos
            // (shared by mother + father; hides itself when the week has none).
            _ArticleFeed(lang: lang, week: w.week),
            const SizedBox(height: 18),
            // S6.5 - Trimester tips (3 tips for this trimester; tap → pop-up).
            _TrimesterTips(
                week: controller.selectedWeek, lang: lang, father: fatherSkin),
            const SizedBox(height: 16),
            // S7 - Share with partner. Hidden in father mode: that section is
            // for the mother to share her week WITH the father, so it's pointless
            // when you already are the father.
            if (!fatherSkin) _PartnerSection(w: w, lang: lang),
            // Previous / next week navigation - loads the complete adjacent
            // week (clamped to the available week bounds; ends hide the arrow).
            const SizedBox(height: 18),
            _WeekNav(controller: controller, lang: lang, father: fatherSkin),
            if (trailing != null) ...[
              const SizedBox(height: 18),
              trailing!,
            ],
          ],
        );
        // Warm-cream backdrop for the father re-skin (all weeks); mother stays
        // on the default scaffold background.
        return fatherSkin ? ColoredBox(color: _fBg, child: list) : list;
      },
    );
  }
}

void _push(BuildContext c, Widget w) =>
    Navigator.of(c).push(MaterialPageRoute(builder: (_) => w));

/// A gentle, illustrated "your daily moment is waiting" card woven into the
/// weekly flow - a soft reminder that the daily Home has more for her today,
/// without nagging or pulling her away from the week. Tapping returns to Home.
class _DailyMomentBridge extends StatelessWidget {
  const _DailyMomentBridge({required this.controller, this.father = false});
  final PregnancyController controller;
  final bool father; // father body points to his home, not Garbh Sanskar

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    // Minimalistic: a subtle inline link row (not a full card) woven into the
    // flow - 🌅 + one line + arrow, tapping jumps to the Today (Daily) tab.
    return InkWell(
      onTap: () {
        AppNav.instance.goToday();
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(children: [
          const Text('🌅', style: TextStyle(fontSize: 15)),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              father
                  ? _fDailyBridgeBody.of(controller.language)
                  : s.wfDailyBridgeBody,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary900),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_rounded,
              size: 15, color: AppTheme.secondary600),
        ]),
      ),
    );
  }
}

/// Public entry points so Home can deep-link straight into a week's V2 detail
/// screens (the "Baby" / "Mother" shortcuts).
void openWeekBabyDetail(BuildContext context, PregnancyController controller,
    int week, AppLanguage lang) {
  final w = controller.weekData(week);
  if (w == null) return;
  _push(context, _BabyDetailScreen(w: w, lang: lang));
}

void openWeekMotherDetail(BuildContext context, PregnancyController controller,
    int week, AppLanguage lang) {
  final w = controller.weekData(week);
  if (w == null) return;
  _push(context, _MotherDetailScreen(w: w, lang: lang));
}

/// Opens the "What's next" pop-up directly (the Home hero shortcut deep-links
/// here instead of just jumping to the weekly tab).
void openWeekWhatsNext(
    BuildContext context, PregnancyController controller, AppLanguage lang,
    {bool father = false}) {
  _push(context,
      _WhatsNextScreen(controller: controller, lang: lang, father: father));
}

/// Opens the "What's next" pop-up straight on the Scans tab (tab index 2 in the
/// Baby · Mom · Scans order) - used by the What's next card's Scans shortcut.
void openWeekScans(
    BuildContext context, PregnancyController controller, AppLanguage lang) {
  _push(
      context,
      _WhatsNextScreen(
          controller: controller, lang: lang, initialTab: _wnTabScans));
}

/// Shared bottom overlay for swipeable pop-ups: a "swipe" hint pill (page 0
/// only) above animated page dots. Parked - the weekly pop-ups moved from swipe
/// to top toggles; kept for revert / reuse.
// ignore: unused_element
Widget _swipeOverlay({
  required int page,
  required int count,
  required String hint,
}) {
  return Positioned(
    left: 0,
    right: 0,
    bottom: 18,
    child: IgnorePointer(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // The hint only appears on the first page, and fades itself out after a
        // few seconds (the ‹ › arrows make it redundant once the user gets it).
        if (page == 0) _FadingSwipeHint(hint: hint),
        const SizedBox(height: 10),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (int i = 0; i < count; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == page ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == page ? AppTheme.primary500 : AppTheme.neutral300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
        ]),
      ]),
    ),
  );
}

// Minimal "n / N" page indicator, top-right of a pop-up carousel.
// ignore: unused_element
Widget _pageCounter(int current, int total) {
  return Positioned(
    top: 14,
    right: 16,
    child: IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.primary500.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text('$current / $total',
            style: pvManrope(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary600)),
      ),
    ),
  );
}

// Minimal, semi-transparent prev/next arrows for a pop-up carousel. A null
// handler hides that side (e.g. the first/last page of a non-looping flow).
// ignore: unused_element
Widget _carouselArrows({VoidCallback? onPrev, VoidCallback? onNext}) {
  Widget side(IconData icon, VoidCallback? onTap) {
    if (onTap == null) return const SizedBox(width: 46);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Icon(icon,
            size: 22, color: AppTheme.primary500.withValues(alpha: 0.85)),
      ),
    );
  }

  return Positioned.fill(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        side(Icons.chevron_left_rounded, onPrev),
        side(Icons.chevron_right_rounded, onNext),
      ],
    ),
  );
}

// The "swipe for more" pill - shows briefly on the first page, then fades out
// (the arrows + dots are enough once the user knows the carousel scrolls).
class _FadingSwipeHint extends StatefulWidget {
  const _FadingSwipeHint({required this.hint});
  final String hint;
  @override
  State<_FadingSwipeHint> createState() => _FadingSwipeHintState();
}

class _FadingSwipeHintState extends State<_FadingSwipeHint> {
  double _opacity = 1;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted) setState(() => _opacity = 0);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primary500,
          borderRadius: BorderRadius.circular(99),
          boxShadow: const [
            BoxShadow(
                color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(widget.hint,
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(width: 6),
          const Icon(Icons.keyboard_double_arrow_right_rounded,
              size: 17, color: Colors.white),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Section brief card (tap → detail)
// ---------------------------------------------------------------------------
class _SectionBrief extends StatelessWidget {
  const _SectionBrief({
    required this.icon,
    required this.color,
    required this.title,
    required this.brief,
    required this.cta,
    required this.onTap,
    this.father = false,
    this.footer,
    this.narrate,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String brief;
  final String cta;
  final VoidCallback onTap;

  /// A [NarrateButton] for this section's passage, or null where the passage
  /// has no stable narration key.
  ///
  /// It sits INSIDE the card's GestureDetector, which is fine: IconButton
  /// claims the tap itself, so the speaker plays without also opening the
  /// detail screen underneath it.
  final Widget? narrate;
  final bool father; // Slate re-skin (week-20 Dad preview only)
  // Optional footer row rendered below the CTA - used by the "What's next" card
  // to host the Baby / Mom / Scans shortcut icons (additional tap targets that
  // sit INSIDE the still-tappable card).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: father ? Border.all(color: _fLine) : null,
          boxShadow: const [
            BoxShadow(
                color: Color(0x14704090), blurRadius: 18, offset: Offset(0, 8)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, size: 21, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  // Father headings use the MOTHER's font (plusJakartaSans), a
                  // bit bolder (w800), in Slate ink - the serif read poorly.
                  style: father
                      ? pvJakarta(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _fInk)
                      : pvJakarta(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
            ),
            ?narrate,
            Icon(Icons.chevron_right_rounded,
                color: father ? _fMuted : AppTheme.neutral400),
          ]),
          const SizedBox(height: 10),
          Text(brief,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 13.5,
                  height: 1.5,
                  color: father ? _fMuted : const Color(0xFF5B5070))),
          const SizedBox(height: 8),
          Text(cta,
              style: pvManrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color)),
          if (footer != null) ...[
            const SizedBox(height: 14),
            footer!,
          ],
        ]),
      ),
    );
  }
}

/// A single Baby / Mom / Scans shortcut chip used on the "What's next" card.
/// Its own tap handler wins the gesture arena over the parent card, so tapping
/// a chip opens its detail while the rest of the card still opens the pop-up.
Widget _whatsNextShortcut(
    BuildContext context, IconData icon, String label, Color color,
    VoidCallback onTap) {
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 5),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: pvJakarta(
                  fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
        ]),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
//  Trimester tips - 3 gentle tips for this trimester. Tapping a tip opens a
//  small pop-up that explains it, without leaving the weekly screen.
// ---------------------------------------------------------------------------
class _TrimesterTips extends StatelessWidget {
  const _TrimesterTips(
      {required this.week, required this.lang, this.father = false});
  final int week;
  final AppLanguage lang;
  final bool father; // Slate + father-voiced tips (week-20 Dad preview)

  static const Color _accent = Color(0xFFD98A2B); // warm amber for "tips"
  Color get _accentColor => father ? _fAccent : _accent;

  int get _tri => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final tips = father
        ? (_fTrimesterTips[_tri] ?? const <TrimesterTip>[]).take(3).toList()
        : _isW5(week)
            ? _w5Tips()
            : (kTrimesterTipsV2[_tri] ?? const <TrimesterTip>[]).take(3).toList();
    if (tips.isEmpty) return const SizedBox.shrink();
    final title = father ? _fTipsTitle.of(lang) : s.wfTipsTitle;
    final subtitle =
        father ? _fTipsSubtitle.of(lang) : s.wfTrimesterLabel(_tri);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
        child: Row(children: [
          Icon(Icons.tips_and_updates_rounded, size: 26, color: _accentColor),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: pvJakarta(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: father ? _fInk : AppTheme.primary900)),
              Text(subtitle,
                  style: pvManrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: father ? _fMuted : AppTheme.neutral500)),
            ]),
          ),
        ]),
      ),
      for (final t in tips) _tipCard(context, s, t),
      // Action to-dos, merged in from the (removed) mother "Actions" tab.
      // Hidden in father mode (they're mother-voiced) to keep it focused, and on
      // week 5 (its tips already carry the doc's full to-do guidance).
      if (!father && !_isW5(week)) for (final a in _toDos) _todoCard(a),
    ]);
  }

  Widget _todoCard(_ToDo t) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _accentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12)),
            child: Text(t.emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title.of(lang),
                  style: pvJakarta(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: AppTheme.primary900)),
              const SizedBox(height: 4),
              Text(t.detail.of(lang),
                  style: pvManrope(
                      fontSize: 12.5,
                      height: 1.45,
                      color: const Color(0xFF5B5070))),
            ]),
          ),
        ]),
      );

  Widget _tipCard(BuildContext context, S s, TrimesterTip t) => GestureDetector(
        onTap: () => _showTip(context, s, t),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 4)),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(t.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading only now (a complete-sentence tip). The full
                    // explanation stays in the tap-through pop-up (_showTip).
                    Text(t.title.of(lang),
                        style: pvJakarta(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color: AppTheme.primary900)),
                    // Preview description removed from the card (kept in pop-up):
                    // const SizedBox(height: 4),
                    // Text(t.body.of(lang),
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: pvManrope(
                    //         fontSize: 12.5,
                    //         height: 1.45,
                    //         color: const Color(0xFF5B5070))),
                  ]),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppTheme.neutral400),
          ]),
        ),
      );

  void _showTip(BuildContext context, S s, TrimesterTip t) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Text(t.emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 14),
            Text(t.title.of(lang),
                textAlign: TextAlign.center,
                style: pvJakarta(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 10),
            Text(t.body.of(lang),
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 14.5,
                    height: 1.55,
                    color: const Color(0xFF5B5070))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: _accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.wfGotIt,
                    style: pvManrope(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Shared full-screen pop-up scaffold (purple header + close)
// ---------------------------------------------------------------------------
class _PopupScaffold extends StatelessWidget {
  const _PopupScaffold({required this.body, this.father = false});
  final Widget body;
  final bool father; // Slate re-skin (week-20 Dad preview only)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: father ? _fBg : AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: father ? _fAccent : AppTheme.primary500,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: body,
    );
  }
}

Widget _popupTitle(String week, String title, {bool father = false}) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(children: [
        Text(week,
            style: pvManrope(
                fontSize: 14, color: father ? _fMuted : AppTheme.neutral500)),
        const SizedBox(height: 2),
        Text(title,
            // Father pop-up headers use the MOTHER's font (plusJakartaSans),
            // bolder, Slate ink - consistent with the weekly headings.
            style: father
                ? pvJakarta(
                    fontSize: 24, fontWeight: FontWeight.w800, color: _fInk)
                : pvJakarta(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary600)),
      ]),
    );

// ---------------------------------------------------------------------------
//  Inline media + article helpers (shared by the Baby & Mother reads)
// ---------------------------------------------------------------------------

/// A single article section: bold heading + body paragraph. [headingColor] lets
/// the father re-skin tint the heading (defaults to the mother purple-ink).
Widget _articleSection(_Article a, AppLanguage lang, {Color? headingColor}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.heading.of(lang),
            style: pvJakarta(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: headingColor ?? AppTheme.primary900)),
        const SizedBox(height: 6),
        Text(a.body.of(lang),
            style: pvManrope(
                fontSize: 15, height: 1.6, color: const Color(0xFF5B5070))),
      ]),
    );

/// A lightweight inline image/video placeholder woven between paragraphs, so a
/// read feels like a mix of text + photos + video (real assets drop in later).
/// Video frames tap to a gentle "coming soon"; image frames are static.
Widget _mediaPlaceholder(BuildContext context, S s,
    {required bool video, required Color accent}) {
  final frame = AspectRatio(
    aspectRatio: video ? 16 / 9 : 4 / 3,
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.16),
            accent.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.14)),
      ),
      child: Stack(children: [
        Center(
          child: video
              ? Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      shape: BoxShape.circle),
                  child:
                      Icon(Icons.play_arrow_rounded, size: 30, color: accent),
                )
              : Icon(Icons.image_outlined,
                  size: 34, color: accent.withValues(alpha: 0.7)),
        ),
        Positioned(
          left: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(40)),
            child: Text(video ? s.wfMediaVideo : s.wfMediaPhoto,
                style: pvManrope(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: accent)),
          ),
        ),
      ]),
    ),
  );
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: video
        ? GestureDetector(
            onTap: () => ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                  SnackBar(content: Text(s.wkVideoSoon))),
            child: frame,
          )
        : frame,
  );
}

/// Article sections with image/video placeholders woven between them - a
/// deterministic pattern (no randomness): a frame after every other section,
/// alternating photo / video, so the read reads as a mix of text + media.
List<Widget> _articleWithMedia(
    BuildContext context, S s, List<_Article> arts, AppLanguage lang,
    Color accent, {Color? headingColor}) {
  final out = <Widget>[];
  for (var i = 0; i < arts.length; i++) {
    out.add(_articleSection(arts[i], lang, headingColor: headingColor));
    if (i.isEven && i + 1 < arts.length) {
      out.add(_mediaPlaceholder(context, s,
          video: (i ~/ 2).isOdd, accent: accent));
    }
  }
  return out;
}

// ---------------------------------------------------------------------------
//  S3 - Baby detail (Baby Science carousel + descriptive article)
// ---------------------------------------------------------------------------
// Opens on the descriptive "About your baby" read (page 0), then a swipe hint
// leads into the Baby Science fact cards (pages 1..N).
/// A "listen to this" row for a long-read popup.
///
/// Returns an empty box when the passage has no recording AND no text worth
/// speaking, so a screen never shows a dead control. It does NOT hide itself
/// merely because the recording is missing - NarrationService falls back to the
/// device voice, and a speaker that appears on some weeks and not others reads
/// as broken rather than as partial coverage.
Widget _listenRow(BuildContext context, String key, LocalizedText? passage,
    AppLanguage lang, Color accent) {
  final text = passage?.of(lang).trim() ?? '';
  if (text.isEmpty) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(children: [
      NarrateButton(
        narrationKey: key,
        text: text,
        englishText: passage!.en,
        lang: lang,
        color: accent,
      ),
      Text(S(lang).listenLabel,
          style: pvManrope(
              fontSize: 12.5, fontWeight: FontWeight.w700, color: accent)),
    ]),
  );
}

class _BabyDetailScreen extends StatelessWidget {
  const _BabyDetailScreen({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  // About your baby is now ONE scrolling page (no swipe carousel): the read
  // (text woven with image/video frames), then the Baby Science facts stacked
  // VERTICALLY - tap any one to read it in a small pop-up.
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    // SKIN/framing (colours + titles) = all weeks; the article/science WORDING
    // = the week-20 re-voiced copy, else the mother's (per-week revoice later).
    final father = _fatherWeek(w.week);
    final fatherSkin = _fatherSkin(w.week);
    // Father: week-20 keeps its richer read; other weeks use the generic father
    // read; the mother keeps hers. Science is generic father-voiced on all weeks.
    final w5 = _isW5(w.week) && !fatherSkin;
    final article = w5
        ? _w5BabyArticle()
        : father
            ? _babyArticleFather
            : (fatherSkin ? _babyArticleGen : _babyArticle);
    final science = w5 ? _w5Science() : (fatherSkin ? _babyScienceFather : _babyScience);
    return _PopupScaffold(
      father: fatherSkin,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Center(
              child: _popupTitle(s.jrWeekLabel(w.week),
                  fatherSkin ? _fBabyTitle.of(lang) : s.wfBabySection,
                  father: fatherSkin)),
          const SizedBox(height: 8),
          _listenRow(
              context,
              NarrationService.weekKey(
                  w.week, 'babyDevelopment.whatImDoing'),
              w.development.whatImDoing,
              lang,
              fatherSkin ? _fAccent : AppTheme.primary500),
          ..._articleWithMedia(context, s, article, lang,
              fatherSkin ? _fAccent : AppTheme.primary500,
              headingColor: fatherSkin ? _fInk : null),
          const SizedBox(height: 2),
          Text(s.wfBabyScience,
              style: fatherSkin
                  ? pvJakarta(
                      fontSize: 19, fontWeight: FontWeight.w800, color: _fInk)
                  : pvJakarta(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary600)),
          const SizedBox(height: 12),
          for (final f in science) _scienceRow(context, s, f, lang, fatherSkin),
          const SizedBox(height: 14),
          Text(s.wfDisclaimer,
              style: pvManrope(
                  fontSize: 11.5, height: 1.5, color: AppTheme.neutral500)),
        ],
      ),
    );
  }

  // A Baby Science fact as a tappable row → opens a small pop-up with the fact.
  Widget _scienceRow(BuildContext context, S s, _Fact f, AppLanguage lang,
          [bool father = false]) =>
      GestureDetector(
        onTap: () => _showFact(context, s, f, lang),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x0F2D144C),
                  blurRadius: 14,
                  offset: Offset(0, 6)),
            ],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: f.bg, shape: BoxShape.circle),
              child: Text(f.emoji, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading only now (a complete-sentence fact). The full
                    // fact text stays in the tap-through pop-up (_showFact).
                    Text(f.title.of(lang),
                        style: pvJakarta(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            height: 1.3,
                            color: father ? _fInk : AppTheme.primary900)),
                    // Preview description removed from the card (kept in pop-up):
                    // const SizedBox(height: 3),
                    // Text(f.desc.of(lang),
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: pvManrope(
                    //         fontSize: 13,
                    //         height: 1.4,
                    //         color: father ? _fMuted : AppTheme.neutral600)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(s.wfTapToRead,
                          style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: father ? _fAccent : AppTheme.primary500)),
                      Icon(Icons.chevron_right_rounded,
                          size: 15,
                          color: father ? _fAccent : AppTheme.primary500),
                    ]),
                  ]),
            ),
          ]),
        ),
      );

  // The fact's full read in a centred pop-up (the old carousel hero, now on tap).
  void _showFact(BuildContext context, S s, _Fact f, AppLanguage lang) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 116,
              height: 116,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: f.bg, shape: BoxShape.circle),
              child: Text(f.emoji, style: const TextStyle(fontSize: 54)),
            ),
            const SizedBox(height: 20),
            Text(f.title.of(lang),
                textAlign: TextAlign.center,
                style: pvJakarta(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 12),
            Text(f.desc.of(lang),
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 15, height: 1.6, color: const Color(0xFF5B5070))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.wfGotIt,
                    style: pvManrope(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  S4 - Mother detail (This week / Health / Eat / To-do)
// ---------------------------------------------------------------------------
// Opens on the detailed "Mother this week" read (page 0), then swipes through
// Health (tappable symptoms), What to eat, and What to do. Prominent headings.
// The "For you, mum" in-depth read (page 0 of the Mother pop-up) - continues
// the section brief into a full page before "Mother this week".
const List<_Article> _motherArticle = [
  _Article(
      LocalizedText(
          en: 'How you might be feeling',
          hi: 'आप कैसा महसूस कर रही होंगी'),
      LocalizedText(
          en: "The second trimester is often the gentlest stretch of pregnancy - the early nausea has usually eased, your energy is back, and your bump is becoming a lovely, visible reminder of the little one growing inside. Emotionally, though, it can still be a rollercoaster: moments of pure joy, then a wave of worry or tears from nowhere. That is completely normal. Your hormones are working hard, and feeling everything a little more deeply is simply part of it.",
          hi: 'दूसरी तिमाही अक्सर गर्भावस्था का सबसे कोमल दौर होती है - शुरुआती मतली आमतौर पर कम हो जाती है, आपकी ऊर्जा लौट आती है, और आपका बंप भीतर पल रहे नन्हे जीव की प्यारी, दिखने वाली निशानी बन जाता है। फिर भी मन का हाल झूले जैसा हो सकता है: कभी शुद्ध ख़ुशी के पल, तो कभी बिना बात चिंता या आँसुओं की लहर। यह बिलकुल सामान्य है। आपके हॉर्मोन बहुत मेहनत कर रहे हैं, और हर बात को थोड़ा गहराई से महसूस करना इसी का हिस्सा है।')),
  _Article(
      LocalizedText(en: 'Your changing body', hi: 'आपका बदलता शरीर'),
      LocalizedText(
          en: "Around now your womb has risen to about your belly button, and many mothers notice their bump 'pop' this month. A few new aches can come with it - a stretching feeling low in your belly, a little backache, or the odd dizzy moment. None of it means something is wrong; it is simply your body making room. Moving gently, standing up slowly, and resting when you need to all help.",
          hi: 'इस समय तक आपका गर्भाशय लगभग नाभि तक आ जाता है, और कई माँएँ इसी महीने अपना बंप अचानक उभरता हुआ पाती हैं। इसके साथ कुछ नई तकलीफ़ें आ सकती हैं - पेट के निचले हिस्से में खिंचाव, हल्का कमर दर्द, या कभी-कभी चक्कर। इनमें से कुछ भी ग़लत नहीं है; यह बस आपका शरीर जगह बना रहा है। धीरे-धीरे चलना, आराम से उठना, और ज़रूरत पड़ने पर आराम करना - सब मदद करते हैं।')),
  _Article(
      LocalizedText(en: 'The first flutters', hi: 'पहली हल्की हलचल'),
      LocalizedText(
          en: "Week 20 is famous for one magical milestone - the first movements, often called 'quickening'. They can feel like bubbles, a gentle tap, or a tiny flutter, and they are easy to miss at first. Over the coming weeks they grow into unmistakable kicks. If you haven't felt anything yet, please don't worry - a first pregnancy or the position of your placenta can both delay it, and it will come.",
          hi: '20वाँ हफ़्ता एक जादुई पड़ाव के लिए मशहूर है - पहली हलचल, जिसे अक्सर quickening कहते हैं। यह बुलबुलों, हल्की थपकी या नन्ही सी फुरफुरी जैसी लग सकती है, और शुरू में इसका पता चलना मुश्किल होता है। आने वाले हफ़्तों में यह साफ़ और पहचानी जाने वाली हलचल बन जाती है। अगर आपको अभी तक कुछ महसूस नहीं हुआ तो चिंता मत कीजिए - पहली गर्भावस्था या आपके प्लेसेंटा की स्थिति, दोनों इसे थोड़ा देर से ला सकती हैं, और यह ज़रूर आएगी।')),
  _Article(
      LocalizedText(
          en: 'Be kind to yourself', hi: 'ख़ुद पर मेहरबान रहिए'),
      LocalizedText(
          en: "This is a beautiful time to slow down and connect - a few quiet minutes with your hand on your bump, a short walk, a proper night's sleep. Share how you're feeling with someone you trust. Looking after your own calm is one of the very best things you can do for your baby right now.",
          hi: 'यह थमने और जुड़ने का एक ख़ूबसूरत समय है - बंप पर हाथ रखे कुछ शांत मिनट, एक छोटी सी सैर, या भरपूर नींद। आप जो महसूस कर रही हैं, वो किसी अपने के साथ बाँटिए। अपने सुकून का ख़याल रखना अभी शिशु के लिए आप जो सबसे अच्छी चीज़ें कर सकती हैं, उनमें से एक है।')),
];

class _MotherDetailScreen extends StatefulWidget {
  const _MotherDetailScreen({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;
  @override
  State<_MotherDetailScreen> createState() => _MotherDetailScreenState();
}

class _MotherDetailScreenState extends State<_MotherDetailScreen> {
  // Single page, top toggles (no swipe): 0 = You this week · 1 = Health.
  int _section = 0;
  int _tab = 0; // health sub-toggle: 0 = Symptoms · 1 = Diet

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final s = S(lang);
    // Skin/framing = all weeks; "You this week" content is split inside
    // _combinedBody (week-20 father copy vs the mother's per-week data).
    final fatherSkin = _fatherSkin(widget.w.week);
    return _PopupScaffold(
      father: fatherSkin,
      body: Column(children: [
        const SizedBox(height: 8),
        Center(
            child: _popupTitle(
                s.jrWeekLabel(widget.w.week),
                _section == 0
                    ? (fatherSkin ? _fYouThisWeek.of(lang) : s.wfYouThisWeek)
                    : s.wfHealthThisWeek,
                father: fatherSkin)),
        const SizedBox(height: 6),
        // Listen sits on the "You this week" read only. The Health tab is
        // symptom lists and diet chips - short, scannable, and not something
        // anyone wants read aloud - so a speaker there would be noise.
        if (_section == 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _listenRow(
                context,
                NarrationService.weekKey(
                    widget.w.week, 'momJourney.emotionalState'),
                widget.w.mom.emotionalState,
                lang,
                fatherSkin ? _fAccent2 : AppTheme.secondary500),
          ),
        // Father: no Health tab - that's her symptoms & diet in her own voice,
        // which doesn't belong in the partner view. Just the "Her this week" read.
        if (!fatherSkin) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _motherTabs(s, lang, fatherSkin),
          ),
          const SizedBox(height: 6),
        ],
        Expanded(
          child: (fatherSkin || _section == 0)
              ? _combinedBody(context, s, lang)
              : _healthBody(context, s, lang, fatherSkin),
        ),
      ]),
    );
  }

  // The top toggle row - click a section, the whole page is about it (no swipe).
  Widget _motherTabs(S s, AppLanguage lang, bool father) {
    final accent = father ? _fAccent : AppTheme.secondary500;
    Widget seg(int i, IconData icon, String label) {
      final on = _section == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _section = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? accent : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 15, color: on ? Colors.white : AppTheme.neutral500),
              const SizedBox(width: 6),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvJakarta(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: on ? Colors.white : AppTheme.neutral600)),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(children: [
        seg(0, Icons.favorite_rounded,
            father ? _fYouThisWeek.of(lang) : s.wfYouThisWeek),
        seg(1, Icons.healing_rounded, s.wfHealthThisWeek),
      ]),
    );
  }

  // "You this week" - the "for you, mum" read (woven with image/video frames),
  // then this week's topics + self-care + reassurance. (Title now sits above the
  // toggle row, so this body no longer repeats it.)
  Widget _combinedBody(BuildContext context, S s, AppLanguage lang) {
    final w = widget.w;
    final m = w.mom;
    final father = _fatherWeek(w.week); // copy/wording (week 20)
    final fatherSkin = _fatherSkin(w.week); // colours/skin (all weeks)
    final w5 = _isW5(w.week) && !fatherSkin;
    final article = w5
        ? _w5MotherArticle()
        : father
            ? _motherArticleFather
            : (fatherSkin ? _motherArticleGen : _motherArticle);
    final topics = w5
        ? _w5Topics()
        : father
            ? _motherTopicsFather
            : (fatherSkin ? _motherTopicsGen : _motherTopics);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
      children: [
        ..._articleWithMedia(context, s, article, lang,
            fatherSkin ? _fAccent : AppTheme.secondary500,
            headingColor: fatherSkin ? _fInk : null),
        for (final t in topics) _topicCard(t, lang, s, father: fatherSkin),
        const SizedBox(height: 4),
        _tintCard(
            fatherSkin ? _fHelpTitle.of(lang) : s.selfCare,
            fatherSkin
                ? _fHelpBody.of(lang)
                : (w5 ? week5Full.you.selfCare : m.selfCareTip).of(lang),
            fatherSkin ? _fAccent : const Color(0xFF4F7A52),
            Icons.spa_rounded,
            father: fatherSkin),
        const SizedBox(height: 12),
        _tintCard(
            s.reassuranceLabel,
            fatherSkin ? _fReassureBody.of(lang) : m.reassurance.of(lang),
            fatherSkin ? _fAccent2 : AppTheme.secondary500,
            Icons.favorite_rounded,
            father: fatherSkin),
        const SizedBox(height: 16),
        Text(s.wfDisclaimer,
            style: pvManrope(
                fontSize: 11.5, height: 1.5, color: AppTheme.neutral500)),
      ],
    );
  }

  // Health - Symptoms / Diet on one body, switched by the sub-toggle.
  Widget _healthBody(BuildContext context, S s, AppLanguage lang, bool father) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
      children: [
        _toggleBar(s, father),
        const SizedBox(height: 16),
        if (_tab == 0)
          ..._symptomsContent(s, lang)
        else
          ..._dietContent(s, lang),
      ],
    );
  }

  Widget _toggleBar(S s, [bool father = false]) {
    Widget seg(int i, IconData icon, String label) {
      final on = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on
                  ? (father ? _fAccent : AppTheme.secondary500)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 16, color: on ? Colors.white : AppTheme.neutral500),
              const SizedBox(width: 6),
              Text(label,
                  style: pvJakarta(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: on ? Colors.white : AppTheme.neutral600)),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(children: [
        seg(0, Icons.healing_rounded, s.wfTabSymptoms),
        seg(1, Icons.restaurant_rounded, s.wfTabDiet),
        // "Actions" tab removed - its to-dos now live in the Trimester Tips
        // section below (per request). seg(2, …, s.wfTabActions) kept commented.
      ]),
    );
  }

  // Each topic shows a teaser; tap opens the fuller read.
  Widget _topicCard(_MotherTopic t, AppLanguage lang, S s,
          {bool father = false}) =>
      GestureDetector(
        onTap: () => _showTopicDialog(t, lang),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: (father ? _fAccent : AppTheme.secondary500)
                      .withValues(alpha: 0.10),
                  shape: BoxShape.circle),
              child: Text(t.emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.label.of(lang),
                        style: pvJakarta(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: father ? _fInk : AppTheme.primary900)),
                    const SizedBox(height: 3),
                    Text(t.short.of(lang),
                        style: pvManrope(
                            fontSize: 13.5,
                            height: 1.45,
                            color: father ? _fMuted : AppTheme.neutral600)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(s.wfTapToRead,
                          style: pvManrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color:
                                  father ? _fAccent : AppTheme.secondary500)),
                      Icon(Icons.chevron_right_rounded,
                          size: 15,
                          color: father ? _fAccent : AppTheme.secondary500),
                    ]),
                  ]),
            ),
          ]),
        ),
      );

  void _showTopicDialog(_MotherTopic t, AppLanguage lang) {
    final s = S(lang);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppTheme.secondary500.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Text(t.emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 14),
            Text(t.label.of(lang),
                textAlign: TextAlign.center,
                style: pvJakarta(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 10),
            Text(t.detail.of(lang),
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 14.5,
                    height: 1.55,
                    color: const Color(0xFF5B5070))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.secondary500,
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.wfGotIt,
                    style: pvManrope(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _tintCard(String title, String body, Color c, IconData icon,
          {bool father = false}) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: c.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 8),
            Text(title,
                style: pvJakarta(
                    fontSize: 14.5, fontWeight: FontWeight.w800, color: c)),
          ]),
          const SizedBox(height: 8),
          Text(body,
              style: pvManrope(
                  fontSize: 14.5,
                  height: 1.55,
                  color: father ? _fMuted : const Color(0xFF5B5070))),
        ]),
      );

  // Toggle: Symptoms - common, normal things to notice now (tap → detail sheet).
  List<Widget> _symptomsContent(S s, AppLanguage lang) {
    if (_isW5(widget.w.week)) return _w5SymptomsContent(s, lang);
    final syms = kSymptoms
        .where((x) => !x.urgent && x.commonInTrimester(2))
        .take(7)
        .toList();
    return [
      Text(s.wfHealthIntro,
          textAlign: TextAlign.center,
          style: pvManrope(
              fontSize: 13, height: 1.5, color: AppTheme.neutral600)),
      const SizedBox(height: 14),
      for (final x in syms) _symptomCard(s, x, lang),
    ];
  }

  // Week 5: the doc's own symptom cards (verbatim) in the Standard symptom UI.
  List<Widget> _w5SymptomsContent(S s, AppLanguage lang) {
    return [
      Text(s.wfHealthIntro,
          textAlign: TextAlign.center,
          style: pvManrope(
              fontSize: 13, height: 1.5, color: AppTheme.neutral600)),
      const SizedBox(height: 14),
      for (final x in week5Full.symptoms) _w5SymptomCard(s, x, lang),
    ];
  }

  Widget _w5SymptomCard(S s, W5Symptom x, AppLanguage lang) {
    const accent = AppTheme.secondary500;
    return GestureDetector(
      onTap: () => _showW5SymptomSheet(x, lang),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.healing_rounded, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(x.name.of(lang),
                  style: pvJakarta(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(x.teaser.of(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 12.5, height: 1.4, color: AppTheme.neutral600)),
              const SizedBox(height: 6),
              Row(children: [
                Text(s.wfTapToRead,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: accent)),
                const Icon(Icons.chevron_right_rounded, size: 15, color: accent),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showW5SymptomSheet(W5Symptom x, AppLanguage lang) {
    final s = S(lang);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 16),
            Text(x.name.of(lang),
                style: pvJakarta(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 6),
            Text(x.teaser.of(lang),
                style: pvManrope(
                    fontSize: 13.5, height: 1.5, color: AppTheme.neutral600)),
            const SizedBox(height: 18),
            _sheetSection(s.symHowCommon, x.howCommon.of(lang)),
            _sheetSection(s.symWhy, x.why.of(lang)),
            _sheetList(s.symWhatHelps, x.helps, lang),
            _sheetSection(s.symWhenDoctor, x.whenDoctor.of(lang), warn: true),
          ],
        ),
      ),
    );
  }

  Widget _symptomCard(S s, Symptom x, AppLanguage lang) {
    final meta = symptomCatMeta(x.category);
    return GestureDetector(
      onTap: () => _showSymptomSheet(x, lang),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(meta.icon, size: 19, color: meta.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(x.name.of(lang),
                  style: pvJakarta(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(x.why.of(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(
                      fontSize: 12.5, height: 1.4, color: AppTheme.neutral600)),
              const SizedBox(height: 6),
              Row(children: [
                Text(s.wfTapToRead,
                    style: pvManrope(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: meta.color)),
                Icon(Icons.chevron_right_rounded, size: 15, color: meta.color),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  void _showSymptomSheet(Symptom x, AppLanguage lang) {
    final s = S(lang);
    final meta = symptomCatMeta(x.category);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        builder: (ctx, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppTheme.neutral300,
                    borderRadius: BorderRadius.circular(99)),
              ),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14)),
                child: Icon(meta.icon, color: meta.color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(x.name.of(lang),
                    style: pvJakarta(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary900)),
              ),
            ]),
            const SizedBox(height: 18),
            _sheetSection(s.symHowCommon, x.commonness.of(lang)),
            _sheetSection(s.symWhy, x.why.of(lang)),
            _sheetList(s.symWhatHelps, x.tips, lang),
            _sheetSection(s.symWhenDoctor, x.doctorGuidance.of(lang), warn: true),
          ],
        ),
      ),
    );
  }

  Widget _sheetSection(String label, String body, {bool warn = false}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                  color: warn ? AppTheme.secondary700 : AppTheme.tertiary500)),
          const SizedBox(height: 5),
          Text(body,
              style: pvManrope(
                  fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
        ]),
      );

  Widget _sheetList(String label, List<LocalizedText> items, AppLanguage lang) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.tertiary500)),
          const SizedBox(height: 8),
          for (final t in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 1, right: 8),
                  child: Icon(Icons.check_circle_rounded,
                      size: 16, color: Color(0xFF4F7A52)),
                ),
                Expanded(
                  child: Text(t.of(lang),
                      style: pvManrope(
                          fontSize: 14,
                          height: 1.45,
                          color: const Color(0xFF5B5070))),
                ),
              ]),
            ),
        ]),
      );

  // Toggle: Diet - Indian superfood of the week + foods to favour / to limit.
  List<Widget> _dietContent(S s, AppLanguage lang) {
    if (_isW5(widget.w.week)) return _w5DietContent(s, lang);
    final n = widget.w.nutrition;
    return [
      // Indian superfood of the week - restored into the V2 diet section (it had
      // only survived in the classic layout when the Classic/New toggle was added).
      if (n.superfood != null) ...[
        _superfoodCard(n.superfood!, s, lang),
        const SizedBox(height: 16),
      ],
      Text(n.whyNow.of(lang),
          style: pvManrope(
              fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
      const SizedBox(height: 16),
      Text(s.foodsToFavour,
          style: pvJakarta(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4F7A52))),
      const SizedBox(height: 10),
      for (final f in _eatFoods) _foodCard(f, lang, const Color(0xFF4F7A52)),
      const SizedBox(height: 10),
      Text(s.wfAvoid,
          style: pvJakarta(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.secondary700)),
      const SizedBox(height: 10),
      for (final f in _avoidFoods) _foodCard(f, lang, AppTheme.secondary500),
    ];
  }

  // Week 5: the doc's own superfood + foods-to-favour + what-to-avoid (verbatim,
  // with descriptions) in the Standard diet UI.
  List<Widget> _w5DietContent(S s, AppLanguage lang) {
    final d = week5Full.diet;
    return [
      _superfoodCard(_w5Superfood(), s, lang),
      const SizedBox(height: 16),
      Text(d.superfood.note.of(lang),
          style: pvManrope(
              fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
      const SizedBox(height: 16),
      Text(s.foodsToFavour,
          style: pvJakarta(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4F7A52))),
      const SizedBox(height: 10),
      for (final f in _w5Favour()) _foodCard(f, lang, const Color(0xFF4F7A52)),
      const SizedBox(height: 10),
      Text(s.wfAvoid,
          style: pvJakarta(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.secondary700)),
      const SizedBox(height: 10),
      for (final f in _w5Avoid()) _foodCard(f, lang, AppTheme.secondary500),
    ];
  }

  Widget _foodCard(_Food f, AppLanguage lang, Color accent) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(16)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.10), shape: BoxShape.circle),
            child: Text(f.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.name.of(lang),
                  style: pvJakarta(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 3),
              Text(f.why.of(lang),
                  style: pvManrope(
                      fontSize: 13, height: 1.45, color: const Color(0xFF5B5070))),
            ]),
          ),
        ]),
      );

  // "Indian superfood of the week" - a highlighted hero card (food + benefit +
  // how to eat it), gold-tinted to set it apart from the favour/avoid lists.
  Widget _superfoodCard(Superfood sf, S s, AppLanguage lang) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.tertiary50, AppTheme.surfaceContainer]),
          borderRadius: BorderRadius.circular(18),
          border: Border(left: BorderSide(color: AppTheme.tertiary500, width: 3)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(Icons.star_rounded, size: 16, color: AppTheme.tertiary500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(s.superfoodOfWeek.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppTheme.tertiary600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(sf.food.of(lang),
              style: pvJakarta(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.tertiary700)),
          const SizedBox(height: 5),
          Text(sf.benefit.of(lang),
              style: pvManrope(
                  fontSize: 13.5, height: 1.5, color: const Color(0xFF5B5070))),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.restaurant_menu_rounded,
                size: 15, color: AppTheme.neutral500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(sf.howToConsume.of(lang),
                  style: pvManrope(
                      fontSize: 12.5, height: 1.45, color: const Color(0xFF6B5F7E))),
            ),
          ]),
        ]),
      );

  // Toggle: Actions - moved into the Trimester Tips section; kept for revert.
  // ignore: unused_element
  List<Widget> _actionsContent(S s, AppLanguage lang) => [
        for (final t in _toDos) _toDoCard(t, lang),
      ];

  // ignore: unused_element
  Widget _toDoCard(_ToDo t, AppLanguage lang) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t.title.of(lang),
                  style: pvJakarta(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
              const SizedBox(height: 5),
              Text(t.detail.of(lang),
                  style: pvManrope(
                      fontSize: 14, height: 1.55, color: const Color(0xFF5B5070))),
            ]),
          ),
        ]),
      );

}

// ---------------------------------------------------------------------------
//  S5 - What's next (Scans / Upcoming milestones)
// ---------------------------------------------------------------------------
// Opens on a "what's next" read, then swipes to Upcoming milestones, then
// Scans & appointments. Milestones and scans open a centered detail pop-up.
// Tab indices for the What's next pop-up, in the Baby · Mom · Scans order.
const int _wnTabBaby = 0;
const int _wnTabMom = 1;
const int _wnTabScans = 2;

class _WhatsNextScreen extends StatefulWidget {
  const _WhatsNextScreen(
      {required this.controller,
      required this.lang,
      this.father = false,
      this.initialTab = _wnTabBaby});
  final PregnancyController controller;
  final AppLanguage lang;

  /// When true (the father's "What's next"), show Scans & appointments only,
  /// re-voiced for the partner - no milestones, no "for you" body section.
  final bool father;

  /// Which tab to open on (Baby · Mom · Scans). Defaults to Baby.
  final int initialTab;
  @override
  State<_WhatsNextScreen> createState() => _WhatsNextScreenState();
}

class _WhatsNextScreenState extends State<_WhatsNextScreen> {
  // One page, three tabs (no swipe): Baby · Mom · Scans. Opens on initialTab.
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final s = S(lang);
    final cw = widget.controller.selectedWeek;
    // Father's What's Next = scans-only, for EVERY week now (skin gate), showing
    // the week-relevant scans re-voiced for the partner.
    final father = widget.father || _fatherSkin(cw);

    // Father's What's Next = Scans & appointments only, re-voiced for the partner.
    if (father) {
      return _PopupScaffold(father: true, body: _fatherScansBody(s, lang, cw));
    }

    // Mother: a single page with a 3-way top tab row, switched in place.
    return _PopupScaffold(
      father: false,
      body: Column(children: [
        const SizedBox(height: 8),
        Center(child: _popupTitle(s.jrWeekLabel(cw), s.wfNextSection)),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _whatsNextTabs(s),
        ),
        const SizedBox(height: 6),
        Expanded(
          // Baby tab reuses the (baby-development) milestones list; Mom tab the
          // "for you" forward look; Scans tab the scans & appointments list.
          // Nothing lost in the Scans/You/Milestones -> Baby/Mom/Scans remap -
          // the old Milestones content now lives under the Baby tab.
          child: _tab == _wnTabBaby
              ? _milestonesList(s, lang, cw)
              : (_tab == _wnTabMom
                  ? _motherNextList(s, lang, cw)
                  : _scansList(s, lang, cw)),
        ),
      ]),
    );
  }

  // The three-way tab row (Baby · Mom · Scans).
  Widget _whatsNextTabs(S s) {
    Widget seg(int i, IconData icon, String label) {
      final on = _tab == i;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _tab = i),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: on ? AppTheme.primary500 : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon,
                  size: 15, color: on ? Colors.white : AppTheme.neutral500),
              const SizedBox(width: 5),
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: pvJakarta(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: on ? Colors.white : AppTheme.neutral600)),
              ),
            ]),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      // Reordered + renamed to Baby · Mom · Scans (inline bilingual labels;
      // app_language.dart untouched). Old labels: Scans / For you / Milestones.
      child: Row(children: [
        seg(_wnTabBaby, Icons.child_care_rounded,
            S(widget.lang).uiBaby),
        seg(_wnTabMom, Icons.favorite_rounded,
            widget.lang.isEnglish ? 'Mom' : 'माँ'),
        seg(_wnTabScans, Icons.event_note_rounded,
            S(widget.lang).uiScans),
      ]),
    );
  }

  /// The journey-progress card (trimester · weeks to go · % there). Currently
  /// not shown (removed from the Scans page) - kept for revert / reuse.
  // ignore: unused_element
  Widget _progressCard(S s) {
    final wk = widget.controller.selectedWeek;
    final weeksToGo = (40 - wk).clamp(0, 40);
    final trimester = wk <= 13 ? 1 : (wk <= 27 ? 2 : 3);
    final progress = (wk / 40).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF1E9FB), AppTheme.surface]),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(s.wfTrimesterLabel(trimester),
              style: pvJakarta(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
          const Spacer(),
          Text(s.wfWeeksToGo(weeksToGo),
              style: pvManrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.secondary500)),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: progress.toDouble(),
            minHeight: 9,
            backgroundColor: AppTheme.primary500.withValues(alpha: 0.12),
            valueColor: const AlwaysStoppedAnimation(AppTheme.primary500),
          ),
        ),
        const SizedBox(height: 8),
        Text(s.wfPercentThere((progress * 100).round()),
            style: pvManrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral500)),
      ]),
    );
  }

  // Old overview page - kept for reference after the 3 → 2 merge (its useful
  // progress card now lives on the Scans page; the "on your radar" list dropped).
  // ignore: unused_element
  Widget _overview(S s, AppLanguage lang) {
    final wk = widget.controller.selectedWeek;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        Center(child: _popupTitle(s.jrWeekLabel(wk), s.wfNextSection)),
        const SizedBox(height: 8),
        Text(s.wfNextIntro,
            style: pvManrope(
                fontSize: 15, height: 1.6, color: const Color(0xFF5B5070))),
        const SizedBox(height: 18),
        _progressCard(s),
        const SizedBox(height: 18),
        Text(s.wfNextRadar,
            style: pvJakarta(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2E9C8E))),
        const SizedBox(height: 10),
        for (final r in _nextRadar)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: const Color(0xFF2E9C8E).withValues(alpha: 0.10),
                    shape: BoxShape.circle),
                child: const Icon(Icons.event_available_rounded,
                    size: 18, color: Color(0xFF2E9C8E)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(r.of(lang),
                    style: pvManrope(
                        fontSize: 13.5,
                        height: 1.45,
                        color: const Color(0xFF5B5070))),
              ),
            ]),
          ),
      ],
    );
  }

  // Tab 3 - Upcoming milestones (current week onward, tappable).
  Widget _milestonesList(S s, AppLanguage lang, int cw) {
    // A focused window - the current week's milestones plus a few weeks ahead.
    final list = _weekMilestones
        .where((m) => m.week >= cw && m.week <= cw + 6)
        .take(8)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
      children: [
        if (list.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(s.scnUpToDate,
                    textAlign: TextAlign.center,
                    style: pvManrope(color: AppTheme.neutral500))),
          ),
        for (final m in list) _milestoneCard(s, m, lang, m.week == cw),
      ],
    );
  }

  Widget _milestoneCard(S s, _WeekMs m, AppLanguage lang, bool current) {
    return GestureDetector(
      onTap: () => _showMilestoneDialog(m, lang),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: current
              ? AppTheme.secondary500.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: current
              ? Border.all(color: AppTheme.secondary500.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: AppTheme.primary500.withValues(alpha: 0.08),
                shape: BoxShape.circle),
            child: Text(m.emoji, style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(m.title.of(lang),
                      style: pvJakarta(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                ),
                if (current)
                  _tag(s.msThisWeek)
                else
                  Text(s.jrWeekLabel(m.week),
                      style: pvManrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary500)),
              ]),
              const SizedBox(height: 3),
              Text(m.short.of(lang),
                  style: pvManrope(
                      fontSize: 12.5, height: 1.4, color: AppTheme.neutral600)),
            ]),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 6, top: 2),
            child: Icon(Icons.chevron_right_rounded,
                size: 18, color: AppTheme.neutral400),
          ),
        ]),
      ),
    );
  }

  Widget _tag(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
            color: AppTheme.secondary500.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(99)),
        child: Text(t.toUpperCase(),
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
                color: AppTheme.secondary700)),
      );

  void _showMilestoneDialog(_WeekMs m, AppLanguage lang) {
    final s = S(lang);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: AppTheme.primary500.withValues(alpha: 0.10),
                  shape: BoxShape.circle),
              child: Text(m.emoji, style: const TextStyle(fontSize: 34)),
            ),
            const SizedBox(height: 14),
            Text(s.jrWeekLabel(m.week),
                style: pvManrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary500)),
            const SizedBox(height: 4),
            Text(m.title.of(lang),
                textAlign: TextAlign.center,
                style: pvJakarta(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 10),
            Text(m.detail.of(lang),
                textAlign: TextAlign.center,
                style: pvManrope(
                    fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primary500,
                    padding: const EdgeInsets.symmetric(vertical: 12)),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(s.wfGotIt,
                    style: pvManrope(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Tab 1 - Scans & appointments (tappable). The default tab.
  Widget _scansList(S s, AppLanguage lang, int cw) {
    final scans = kJourneyMilestones
        .where((m) =>
            m.type == JourneyNodeType.medical &&
            m.anchorWeek >= cw - 6 &&
            m.anchorWeek <= cw + 10)
        .toList()
      ..sort((a, b) => a.anchorWeek.compareTo(b.anchorWeek));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
      children: [
        for (final m in scans) _scanCard(s, m, lang),
        if (scans.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(s.scnUpToDate,
                    textAlign: TextAlign.center,
                    style: pvManrope(color: AppTheme.neutral500))),
          ),
      ],
    );
  }

  // Tab 2 - "What's next for you": a forward look at how she may feel in the
  // coming weeks (per-week body + emotional changes), tappable for the full read.
  Widget _motherNextList(S s, AppLanguage lang, int cw) {
    final last = (cw + 4) > 40 ? 40 : (cw + 4);
    final cards = <Widget>[];
    for (int w = cw; w <= last; w++) {
      final mom = widget.controller.weekData(w)?.mom;
      if (mom == null || mom.physicalChanges.of(lang).trim().isEmpty) continue;
      cards.add(_motherWeekCard(s, lang, w, mom, w == cw));
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 96),
      children: [
        Text(s.wfNextMotherIntro,
            style: pvManrope(
                fontSize: 14, height: 1.55, color: const Color(0xFF5B5070))),
        const SizedBox(height: 16),
        if (cards.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(s.scnUpToDate,
                    textAlign: TextAlign.center,
                    style: pvManrope(color: AppTheme.neutral500))),
          ),
        ...cards,
      ],
    );
  }

  Widget _motherWeekCard(
      S s, AppLanguage lang, int week, MomJourney mom, bool current) {
    return GestureDetector(
      onTap: () => _showMotherWeekDialog(s, lang, week, mom),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: current
              ? AppTheme.secondary500.withValues(alpha: 0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: current
              ? Border.all(color: AppTheme.secondary500.withValues(alpha: 0.4))
              : null,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(s.jrWeekLabel(week),
                  style: pvJakarta(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
            ),
            if (current) _tag(s.msThisWeek),
          ]),
          const SizedBox(height: 6),
          Text(mom.physicalChanges.of(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: pvManrope(
                  fontSize: 13.5, height: 1.5, color: const Color(0xFF5B5070))),
          const SizedBox(height: 8),
          Row(children: [
            Text(s.wfTapToRead,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.secondary600)),
            const Icon(Icons.chevron_right_rounded,
                size: 15, color: AppTheme.secondary500),
          ]),
        ]),
      ),
    );
  }

  void _showMotherWeekDialog(S s, AppLanguage lang, int week, MomJourney mom) {
    Widget section(String label, String body) => body.trim().isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label.toUpperCase(),
                      style: pvManrope(
                          fontSize: 11,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondary600)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: pvManrope(
                          fontSize: 14.5,
                          height: 1.55,
                          color: const Color(0xFF5B5070))),
                ]),
          );
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.jrWeekLabel(week),
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary600)),
                  const SizedBox(height: 4),
                  Text(s.wfYouThisWeek,
                      style: pvJakarta(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 14),
                  section(s.wfBodyLabel, mom.physicalChanges.of(lang)),
                  section(s.wfFeelLabel, mom.emotionalState.of(lang)),
                  section(s.selfCare, mom.selfCareTip.of(lang)),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary500,
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(s.wfGotIt,
                          style: pvManrope(
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  // ---- Father (week-20) Scans & appointments - re-voiced for the partner -----
  Widget _fatherScansBody(S s, AppLanguage lang, int cw) {
    // The week-relevant scans (same ±window as the mother's Scans tab), so this
    // works on EVERY week, not just 20.
    final scans = _fScans
        .where((f) => f.week >= cw - 6 && f.week <= cw + 10)
        .toList()
      ..sort((a, b) => a.week.compareTo(b.week));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        Center(
            child: _popupTitle(s.jrWeekLabel(cw), _fNextLabel.of(lang),
                father: true)),
        const SizedBox(height: 8),
        Text(_fScansIntro.of(lang),
            style: pvManrope(fontSize: 15, height: 1.6, color: _fInk)),
        const SizedBox(height: 16),
        if (scans.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(s.scnUpToDate,
                    textAlign: TextAlign.center,
                    style: pvManrope(color: _fMuted))),
          )
        else
          for (final f in scans) _fScanCard(s, lang, f),
      ],
    );
  }

  Widget _fScanCard(S s, AppLanguage lang, _FScan f) {
    return GestureDetector(
      onTap: () => _fScanDialog(s, lang, f),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _fLine)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(f.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(f.title.of(lang),
                  style: pvJakarta(
                      fontSize: 16, fontWeight: FontWeight.w800, color: _fInk)),
            ),
            Text(f.when.of(lang),
                style: pvManrope(fontSize: 11.5, color: _fMuted)),
          ]),
          const SizedBox(height: 8),
          Text(f.body.of(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  pvManrope(fontSize: 13.5, height: 1.5, color: _fInk)),
          const SizedBox(height: 8),
          Row(children: [
            Text(s.wfTapToRead,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _fAccent)),
            const Icon(Icons.chevron_right_rounded, size: 15, color: _fAccent),
          ]),
        ]),
      ),
    );
  }

  void _fScanDialog(S s, AppLanguage lang, _FScan f) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(f.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(f.title.of(lang),
                          style: pvJakarta(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _fInk)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(f.when.of(lang),
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _fAccent)),
                  const SizedBox(height: 14),
                  Text(f.body.of(lang),
                      style: pvManrope(
                          fontSize: 14.5, height: 1.55, color: _fInk)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: _fAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14)),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(S.now.uiHowShowUp,
                              style: pvManrope(
                                  fontSize: 11,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w800,
                                  color: _fAccent)),
                          const SizedBox(height: 4),
                          Text(f.help.of(lang),
                              style: pvManrope(
                                  fontSize: 14, height: 1.55, color: _fInk)),
                        ]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: _fAccent,
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(s.wfGotIt,
                          style: pvManrope(
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  Widget _scanCard(S s, JourneyMilestone m, AppLanguage lang) {
    return GestureDetector(
      onTap: () => _showScanDialog(m, lang),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: AppTheme.surface, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(m.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(m.title.of(lang),
                  style: pvJakarta(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ),
            Text(m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
                style: pvManrope(
                    fontSize: 11.5, color: AppTheme.neutral500)),
          ]),
          if (m.sections.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(m.sections.first.body.of(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: pvManrope(
                    fontSize: 13.5, height: 1.5, color: const Color(0xFF5B5070))),
          ],
          const SizedBox(height: 8),
          Row(children: [
            Text(s.wfTapToRead,
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2E9C8E))),
            const Icon(Icons.chevron_right_rounded,
                size: 15, color: Color(0xFF2E9C8E)),
          ]),
        ]),
      ),
    );
  }

  void _showScanDialog(JourneyMilestone m, AppLanguage lang) {
    final s = S(lang);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(m.emoji, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(m.title.of(lang),
                          style: pvJakarta(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2E9C8E))),
                  const SizedBox(height: 14),
                  for (final sec in m.sections)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sec.label.of(lang).toUpperCase(),
                                style: pvManrope(
                                    fontSize: 11,
                                    letterSpacing: 0.4,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.tertiary500)),
                            const SizedBox(height: 4),
                            Text(sec.body.of(lang),
                                style: pvManrope(
                                    fontSize: 14.5,
                                    height: 1.55,
                                    color: const Color(0xFF5B5070))),
                          ]),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary500,
                          padding: const EdgeInsets.symmetric(vertical: 12)),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(s.wfGotIt,
                          style: pvManrope(
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  S6 - This week's videos (Instagram-style horizontal feed; placeholders)
// ---------------------------------------------------------------------------
class _VideoFeed extends StatelessWidget {
  const _VideoFeed({required this.lang});
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.play_circle_fill_rounded,
            color: AppTheme.primary500, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(s.wfVideosSection,
              style: pvJakarta(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ),
        _viewAllButton(context, s,
            () => _push(context, _AllVideosScreen(lang: lang))),
      ]),
      const SizedBox(height: 12),
      // A horizontal reel/shorts-style feed - uniform 9:16 tiles.
      SizedBox(
        height: 250,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          itemCount: _weekVideos.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _reel(context, _weekVideos[i], s),
        ),
      ),
    ]);
  }

  Widget _reel(BuildContext context, _Vid v, S s) =>
      _videoReelTile(context, v, s, lang);
}

/// A single 9:16 reel tile (shared by the weekly carousel and the "View all"
/// videos screen). Playback is still a mock (snackbar) until real videos land.
Widget _videoReelTile(BuildContext context, _Vid v, S s, AppLanguage lang,
    {double width = 141}) {
  return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.wkVideoSoon))),
      child: SizedBox(
        width: width, // ≈ 9:16 against the 250 height
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(fit: StackFit.expand, children: [
            // Thumbnail placeholder (a real thumbnail goes here later).
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [v.c1, v.c2]),
              ),
            ),
            // Bottom scrim + title (reels style).
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xD9000000)]),
                ),
                child: Text(v.title.of(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: pvJakarta(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: Colors.white)),
              ),
            ),
            // Play button.
            Center(
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.85),
                        width: 1.5)),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 24, color: Colors.white),
              ),
            ),
            // NEW badge.
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppTheme.secondary500,
                    borderRadius: BorderRadius.circular(99)),
                child: Text(S.now.uiNew,
                    style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: Colors.white)),
              ),
            ),
            // Duration badge.
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(99)),
                child: Text(v.tag,
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
}

// ---------------------------------------------------------------------------
//  Weekly articles - "This week's reads" carousel (mirrors _VideoFeed)
// ---------------------------------------------------------------------------
class _ArticleFeed extends StatelessWidget {
  const _ArticleFeed({required this.lang, required this.week});
  final AppLanguage lang;
  final int week;

  @override
  Widget build(BuildContext context) {
    final store = ArticleStore.instance..ensureLoaded();
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => _content(context, store.forWeek(week)),
    );
  }

  Widget _content(BuildContext context, List<WeekArticle> articles) {
    final s = S(lang);
    if (articles.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.menu_book_rounded,
            color: AppTheme.primary500, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(s.wfArticlesSection,
              style: pvJakarta(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ),
        _viewAllButton(context, s,
            () => _push(context, _AllReadsScreen(lang: lang, week: week))),
      ]),
      const SizedBox(height: 12),
      SizedBox(
        height: 176,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: EdgeInsets.zero,
          itemCount: articles.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, i) => _card(context, articles[i]),
        ),
      ),
    ]);
  }

  Widget _card(BuildContext context, WeekArticle a) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _ArticleReader(article: a))),
      child: Container(
        width: 208,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.outlineVariant),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary900.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 10),
          Expanded(
            child: Text(a.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: pvJakarta(
                    fontSize: 14.5,
                    height: 1.3,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
          ),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.schedule_rounded,
                size: 13, color: AppTheme.neutral500),
            const SizedBox(width: 4),
            Text('${a.readMins} min read',
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutral500)),
          ]),
        ]),
      ),
    );
  }
}

class _ArticleReader extends StatelessWidget {
  const _ArticleReader({required this.article});
  final WeekArticle article;

  @override
  Widget build(BuildContext context) {
    final paras = article.body.split('\n\n');
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        foregroundColor: AppTheme.primary900,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(article.emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(article.title,
              style: pvJakarta(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                  color: AppTheme.primary900)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.schedule_rounded,
                size: 14, color: AppTheme.neutral500),
            const SizedBox(width: 4),
            Text('${article.readMins} min read · Week ${article.week}',
                style: pvManrope(
                    fontSize: 12.5, color: AppTheme.neutral500)),
          ]),
          const SizedBox(height: 18),
          for (final para in paras) ...[
            Text(para,
                style: pvManrope(
                    fontSize: 15, height: 1.6, color: AppTheme.neutral700)),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  "View all" pill (section-header trailing action) + full-list screens for
//  the weekly videos and reads carousels.
// ---------------------------------------------------------------------------
Widget _viewAllButton(BuildContext context, S s, VoidCallback onTap) {
  return TextButton(
    onPressed: onTap,
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(s.lang.isEnglish ? 'View all' : 'सब देखिए',
          style: pvManrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary500)),
      const Icon(Icons.chevron_right_rounded,
          size: 16, color: AppTheme.primary500),
    ]),
  );
}

/// Full-screen list of all weekly videos (reuses the reel tiles + mock play).
class _AllVideosScreen extends StatelessWidget {
  const _AllVideosScreen({required this.lang});
  final AppLanguage lang;
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        foregroundColor: AppTheme.primary900,
        title: Text(s.wfVideosSection,
            style: pvJakarta(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary900)),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 9 / 16,
        ),
        itemCount: _weekVideos.length,
        itemBuilder: (context, i) =>
            _videoReelTile(context, _weekVideos[i], s, lang, width: 400),
      ),
    );
  }
}

/// Full-screen list of all weekly reads (reuses the existing _ArticleReader).
class _AllReadsScreen extends StatelessWidget {
  const _AllReadsScreen({required this.lang, required this.week});
  final AppLanguage lang;
  final int week;
  @override
  Widget build(BuildContext context) {
    final store = ArticleStore.instance..ensureLoaded();
    return AnimatedBuilder(
      animation: store,
      builder: (context, _) => _content(context, store),
    );
  }

  Widget _content(BuildContext context, ArticleStore store) {
    final s = S(lang);
    // Show this week's reads first, then the rest of the library beneath.
    final thisWeek = store.forWeek(week);
    final others =
        store.all.where((a) => a.week != week).toList();
    final all = [...thisWeek, ...others];
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        foregroundColor: AppTheme.primary900,
        title: Text(s.wfArticlesSection,
            style: pvJakarta(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary900)),
      ),
      body: RefreshIndicator(
        // force: an explicit pull-to-refresh should never be swallowed by the
        // store's resume throttle — the gesture means "check now".
        onRefresh: () => store.refresh(force: true),
        child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        itemCount: all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final a = all[i];
          return GestureDetector(
            onTap: () => _push(context, _ArticleReader(article: a)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Row(children: [
                Text(a.emoji, style: const TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.title,
                            style: pvJakarta(
                                fontSize: 15,
                                height: 1.3,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primary900)),
                        const SizedBox(height: 6),
                        Row(children: [
                          const Icon(Icons.schedule_rounded,
                              size: 13, color: AppTheme.neutral500),
                          const SizedBox(width: 4),
                          Text('${a.readMins} min read · Week ${a.week}',
                              style: pvManrope(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.neutral500)),
                        ]),
                      ]),
                ),
                const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppTheme.neutral400),
              ]),
            ),
          );
        },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  S7 - Share with partner (richer, segmented WhatsApp summary)
// ---------------------------------------------------------------------------
class _PartnerSection extends StatelessWidget {
  const _PartnerSection({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  String _message(S s) {
    final week = w.week;
    if (_isW5(week)) {
      final p = week5Full.partner;
      final scanLines = p.scans
          .map((x) => '• ${x.name.of(lang)} (${x.window.of(lang)})')
          .join('\n');
      final helpLines = p.help.map((h) => '• ${h.of(lang)}').join('\n');
      return '👶 ${s.wfPartnerHeader(week)}\n\n'
          '🍼 ${s.ovBaby}: ${p.baby.of(lang)}\n\n'
          '🌸 ${s.ovMother}: ${p.mother.of(lang)}\n\n'
          '🩺 ${s.wfPartnerScansHeader}\n$scanLines\n\n'
          '🤝 ${s.wfPartnerHelp}:\n$helpLines\n\n'
          '${s.wfPartnerSignoff}\n- ParentVeda 💜';
    }
    final baby = w.development.whatImDoing.of(lang);
    final mum = w.mom.emotionalState.of(lang);
    final scans = kJourneyMilestones
        .where((m) =>
            m.type == JourneyNodeType.medical &&
            m.anchorWeek >= week - 2 &&
            m.anchorWeek <= week + 10)
        .toList()
      ..sort((a, b) => a.anchorWeek.compareTo(b.anchorWeek));
    final scanLines = scans.isEmpty
        ? '• ${s.scnUpToDate}'
        : scans
            .map((m) =>
                '• ${m.title.of(lang)} (${m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek)})')
            .join('\n');
    final helpLines = _partnerHelp.map((h) => '• ${h.of(lang)}').join('\n');
    return '👶 ${s.wfPartnerHeader(week)}\n\n'
        '🍼 ${s.ovBaby}: $baby\n\n'
        '🌸 ${s.ovMother}: $mum\n\n'
        '🩺 ${s.wfPartnerScansHeader}\n$scanLines\n\n'
        '🤝 ${s.wfPartnerHelp}:\n$helpLines\n\n'
        '${s.wfPartnerSignoff}\n- ParentVeda 💜';
  }

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFCE3E6), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.volunteer_activism_rounded,
              size: 20, color: AppTheme.secondary500),
          const SizedBox(width: 10),
          Text(s.wfPartnerSection,
              style: pvJakarta(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ]),
        const SizedBox(height: 8),
        Text(s.wfPartnerBlurb,
            style: pvManrope(
                fontSize: 13, height: 1.5, color: AppTheme.neutral700)),
        const SizedBox(height: 14),
        // A preview of the message that will be shared (WhatsApp-style bubble).
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFFE7FBD6),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(_message(s),
              style: pvManrope(
                  fontSize: 12.5, height: 1.55, color: const Color(0xFF2A3D2A))),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary500,
                padding: const EdgeInsets.symmetric(vertical: 14)),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await Share.share(_message(s));
              } catch (_) {
                messenger
                    .showSnackBar(SnackBar(content: Text(s.shareFailed)));
              }
            },
            icon: const Icon(Icons.chat_rounded, size: 18, color: Colors.white),
            label: Text(s.wfPartnerCta,
                style: pvManrope(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}

// ---------------------------------------------------------------------------
//  Previous / next week navigation - loads the complete adjacent week via
//  controller.selectWeek(). selectWeek notifies listeners, so both this flow
//  and the parent week-stack rebuild for the new week automatically.
// ---------------------------------------------------------------------------
class _WeekNav extends StatelessWidget {
  const _WeekNav(
      {required this.controller, required this.lang, this.father = false});
  final PregnancyController controller;
  final AppLanguage lang;
  final bool father;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    // Available (seeded) weeks, sorted, give us the real bounds to clamp to.
    final weeks = [...controller.availableWeeks]..sort();
    final cw = controller.selectedWeek;
    final idx = weeks.indexOf(cw);
    final int? prevWk = idx > 0 ? weeks[idx - 1] : null;
    final int? nextWk =
        (idx >= 0 && idx < weeks.length - 1) ? weeks[idx + 1] : null;
    // Nothing either side (single-week content) -> hide the whole row.
    if (prevWk == null && nextWk == null) return const SizedBox.shrink();
    return Row(children: [
      Expanded(
        child: prevWk == null
            ? const SizedBox.shrink()
            : _navButton(
                context, s,
                isPrev: true,
                week: prevWk,
                onTap: () => controller.selectWeek(prevWk)),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: nextWk == null
            ? const SizedBox.shrink()
            : _navButton(
                context, s,
                isPrev: false,
                week: nextWk,
                onTap: () => controller.selectWeek(nextWk)),
      ),
    ]);
  }

  Widget _navButton(BuildContext context, S s,
      {required bool isPrev, required int week, required VoidCallback onTap}) {
    final accent = father ? _fAccent : AppTheme.primary500;
    final caption = isPrev
        ? (lang.isEnglish ? 'Previous week' : 'पिछला हफ़्ता')
        : (lang.isEnglish ? 'Next week' : 'अगला हफ़्ता');
    final label = isPrev
        ? '← ${s.weekWord} $week'
        : '${s.weekWord} $week →';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: father ? _fBg : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: father ? _fLine : AppTheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment:
              isPrev ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(caption,
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: father ? _fMuted : AppTheme.neutral500)),
            const SizedBox(height: 2),
            Text(label,
                style: pvJakarta(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: accent)),
          ],
        ),
      ),
    );
  }
}
