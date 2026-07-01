// =============================================================================
//  WeekFlowView — "V2" vertical week flow (week 20 preview, behind a toggle)
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
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../data/journey_milestones.dart';
import '../data/symptom_data.dart';
import '../data/trimester_tips.dart';
import '../localization/app_language.dart';
import '../models/journey_node.dart';
import '../models/symptom.dart';
import '../models/week_content.dart';
import '../services/app_nav.dart';
import '../services/father_preview.dart';
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/week_cards/week_overview_card.dart';

// TESTING-ONLY: when the Dad mode switch is on AND we're on week 20, the weekly
// flow re-voices its copy for the father (same content, read for/about her).
// Mother flow + every other week are unchanged. Strip with FatherPreview.
bool _fatherWeek(int week) => FatherPreview.instance.on && week == 20;

// Father (Slate) SKIN gate — now ALL weeks (the colour scheme rolled out to
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

// Father serif header (Fraunces) — parked: the father weekly headings moved to
// the mother's sans font (plusJakartaSans). Kept for revert.
// ignore: unused_element
TextStyle _fSerif(double size, Color c, {FontWeight w = FontWeight.w600}) =>
    GoogleFonts.fraunces(
        fontSize: size, fontWeight: w, color: c, height: 1.18, letterSpacing: -0.2);

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

// Distinct "did you know" trivia — kept separate from the article read so the
// two don't repeat each other.
const List<_Fact> _babyScience = [
  _Fact(
      '🧠',
      Color(0xFFF2E9FB),
      LocalizedText(en: 'My busy little brain', hi: 'Mera vyast nanha dimaag'),
      LocalizedText(
          en: "I'm forming millions of new nerve connections every single day — my brain is working at an astonishing pace!",
          hi: 'Main har din laakhon naye nerve connections bana raha hoon — mera dimaag gajab raftaar se kaam kar raha hai!')),
  _Fact(
      '🤏',
      Color(0xFFFCE3E6),
      LocalizedText(en: 'My tiny grip', hi: 'Meri nanhi pakad'),
      LocalizedText(
          en: "I can curl my little fingers and sometimes grab the umbilical cord — I'm practising for our very first cuddles.",
          hi: 'Main apni nanhi ungliyan mod sakta hoon aur kabhi gard-naal pakad leta hoon — main hamari pehli cuddles ki practice kar raha hoon.')),
  _Fact(
      '🫧',
      Color(0xFFE6F0FA),
      LocalizedText(en: 'I get hiccups!', hi: 'Mujhe hichki aati hai!'),
      LocalizedText(
          en: "Sometimes you'll feel tiny rhythmic taps — that's just me having hiccups, and it's completely normal.",
          hi: 'Kabhi aap chhoti taal-baddh thaap mehsoos karengi — yeh bas meri hichki hai, aur bilkul normal hai.')),
  _Fact(
      '🦶',
      Color(0xFFFDF0C4),
      LocalizedText(en: 'My own prints', hi: 'Mere apne nishaan'),
      LocalizedText(
          en: "My very own fingerprints — and footprints — are forming right now, patterns that will be mine alone for life.",
          hi: 'Mere apne fingerprints — aur footprints — abhi ban rahe hain, jo zindagi bhar sirf mere honge.')),
  _Fact(
      '💗',
      Color(0xFFEAF1EA),
      LocalizedText(en: 'My strong heartbeat', hi: 'Meri mazboot dhadkan'),
      LocalizedText(
          en: "My heart is pumping hard, moving several litres of blood around my tiny body every single day.",
          hi: 'Mera dil zor se pump kar raha hai, har din kai litre khoon mere nanhe sharir mein ghumata hai.')),
  _Fact(
      '🌗',
      Color(0xFFEDEAF6),
      LocalizedText(en: 'I can sense light', hi: 'Main roshni mehsoos karta hoon'),
      LocalizedText(
          en: 'Shine a soft light on your bump and I might turn towards it — my eyes are getting ready to see you.',
          hi: 'Bump par halki roshni daalein to main uski taraf mud sakta hoon — meri aankhein aapko dekhne ko taiyar ho rahi hain.')),
];

class _Article {
  const _Article(this.heading, this.body);
  final LocalizedText heading;
  final LocalizedText body;
}

const List<_Article> _babyArticle = [
  _Article(
      LocalizedText(en: "We're halfway there! 🎉", hi: 'Hum aadhe raaste par hain! 🎉'),
      LocalizedText(
          en: "We've reached the middle of our journey together! I'm growing quickly now, your bump is showing, and any day now you might feel me move for the very first time.",
          hi: 'Hum apne safar ke aadhe raaste par pahunch gaye hain! Main ab tezi se badh raha hoon, aapka bump dikhne laga hai, aur kisi bhi din aap mujhe pehli baar mehsoos kar sakti hain.')),
  _Article(
      LocalizedText(en: 'How big am I?', hi: 'Main kitna bada hoon?'),
      LocalizedText(
          en: "I'm about the size of a banana now — roughly 25 cm from my head to my heels and around 300 g. From this week, you'll measure me head-to-heel instead of head-to-bottom.",
          hi: 'Main ab lagbhag ek kele jitna hoon — sir se edi tak takreeban 25 cm aur ~300 g. Is hafte se aap meri lambai sir-se-edi naapengi.')),
  _Article(
      LocalizedText(en: "You'll feel me move", hi: 'Aap mujhe mehsoos karengi'),
      LocalizedText(
          en: "My first little flutters — called \"quickening\" — often start around now. They feel like bubbles or a gentle tap, and over the next few weeks they'll grow into clear kicks. If this is your first baby you might feel me a little later — that's completely normal.",
          hi: 'Meri pehli halki harkatein — "quickening" — aksar is samay shuru hoti hain. Yeh bulbule ya halke tap jaisi lagti hain, aur agle kuch hafton mein saaf kicks ban jaayengi. Agar yeh aapka pehla baby hai to aap mujhe thodi der se mehsoos kar sakti hain — yeh bilkul normal hai.')),
  _Article(
      LocalizedText(en: 'I can hear you now', hi: 'Main ab aapko sun sakta hoon'),
      LocalizedText(
          en: "The tiny bones in my ears are in place, so I can hear your voice, your heartbeat and the world around us. When you talk, hum or sing to me, it helps us bond — and I'll often recognise your favourite tune after I'm born.",
          hi: 'Mere kaano ki nanhi haddiyan ban gayi hain, isliye main aapki awaaz, aapki dhadkan aur aas-paas ki duniya sun sakta hoon. Jab aap mujhse baat karti, gungunaati ya gaati hain, to hamari bonding hoti hai — aur janm ke baad main aksar aapki pasandeeda dhun pehchaan loonga.')),
  _Article(
      LocalizedText(en: "I'm tasting your meals", hi: 'Main aapke khaane ka swaad leta hoon'),
      LocalizedText(
          en: "I swallow a little amniotic fluid through the day, and my new taste buds pick up the flavours of whatever you eat. A varied, balanced diet now might even shape what I love to eat later!",
          hi: 'Main din bhar thoda amniotic fluid nigalta hoon, aur meri nayi swaad-kaliyan aapke khaane ke flavours mehsoos karti hain. Abhi variety wali santulit diet aage chal kar mere swaad ko bhi bana sakti hai!')),
  _Article(
      LocalizedText(en: 'My skin, hair and vernix', hi: 'Meri tvacha, baal aur vernix'),
      LocalizedText(
          en: "A soft creamy coating called vernix and a layer of fine hair (lanugo) are protecting my delicate skin. Underneath, I'm building up the fat that will keep me warm and cosy after I'm born.",
          hi: 'Vernix naam ki narm creamy parat aur mahin baal (lanugo) meri naazuk tvacha ko bacha rahe hain. Iske neeche main woh fat bana raha hoon jo janm ke baad mujhe garm aur aaramdeh rakhega.')),
  _Article(
      LocalizedText(en: 'I sleep and wake', hi: 'Main sota aur jaagta hoon'),
      LocalizedText(
          en: "I'm settling into my own sleep-and-wake cycles, and I'm often most active just when you lie down to rest! Noticing my patterns is the start of you getting to know me.",
          hi: 'Main apne sone-jaagne ke cycle mein aa raha hoon, aur aksar tab sabse zyada active hota hoon jab aap aaram karne letti hain! Mere patterns pehchaanna aapke mujhe jaan-ne ki shuruaat hai.')),
];

const List<_Food> _avoidFoods = [
  _Food(
      '🥩',
      LocalizedText(
          en: 'Raw or undercooked meat & eggs',
          hi: 'Kaccha ya adhpaka maans & ande'),
      LocalizedText(
          en: 'Can carry bacteria like salmonella or listeria — cook everything thoroughly.',
          hi: 'Salmonella ya listeria jaise bacteria ho sakte hain — sab kuch achhe se pakaayein.')),
  _Food(
      '🧀',
      LocalizedText(
          en: 'Unpasteurised milk & soft cheese',
          hi: 'Bina pasteurise doodh & soft cheese'),
      LocalizedText(
          en: 'May contain listeria. Choose pasteurised dairy and hard cheeses instead.',
          hi: 'Inme listeria ho sakta hai. Iske bajaye pasteurise dairy aur hard cheese chunein.')),
  _Food(
      '🐟',
      LocalizedText(en: 'High-mercury fish', hi: 'High-mercury machhli'),
      LocalizedText(
          en: "Limit shark, swordfish and king mackerel — mercury can affect baby's developing brain.",
          hi: 'Shark, swordfish aur king mackerel kam karein — mercury baby ke dimaag ko prabhavit kar sakta hai.')),
  _Food(
      '☕',
      LocalizedText(en: 'Too much caffeine', hi: 'Zyada caffeine'),
      LocalizedText(
          en: 'Keep it under about 200 mg a day — roughly one cup of coffee.',
          hi: 'Ise din mein ~200 mg se kam rakhein — lagbhag ek cup coffee.')),
  _Food(
      '🍷',
      LocalizedText(en: 'Alcohol', hi: 'Sharab'),
      LocalizedText(
          en: 'No amount is considered safe in pregnancy — best avoided completely.',
          hi: 'Pregnancy mein koi bhi maatra surakshit nahi maani jaati — poori tarah bachna behtar.')),
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
          en: "Rich in calcium and protein — builds your baby's bones and teeth, and keeps yours strong too.",
          hi: 'Calcium aur protein se bharpoor — baby ki haddiyan-daant banata hai aur aapki haddiyan bhi mazboot rakhta hai.')),
  _Food('🫘', LocalizedText(en: 'Rajma & legumes', hi: 'Rajma & dalein'),
      LocalizedText(
          en: 'Plant iron, protein and fibre. The iron supports the extra blood your body is making, and the fibre eases constipation.',
          hi: 'Plant iron, protein aur fibre. Iron aapke badhte khoon ko support karta hai, aur fibre kabz mein aaram deta hai.')),
  _Food('🥬', LocalizedText(en: 'Spinach & greens', hi: 'Paalak & saag'),
      LocalizedText(
          en: "Loaded with folate, iron and calcium — key for baby's growth and your own energy.",
          hi: 'Folate, iron aur calcium se bharpoor — baby ke vikas aur aapki urja ke liye zaroori.')),
  _Food('🥛', LocalizedText(en: 'Curd & yoghurt', hi: 'Dahi'),
      LocalizedText(
          en: 'Probiotics plus calcium — gentle on digestion and cooling in the heat.',
          hi: 'Probiotics aur calcium — pachan ke liye halka aur garmi mein thandak deta hai.')),
  _Food('🥚', LocalizedText(en: 'Eggs', hi: 'Ande'),
      LocalizedText(
          en: "Complete protein and choline, which supports your baby's brain development. Cook them well.",
          hi: 'Poora protein aur choline, jo baby ke dimaag ke vikas mein madad karta hai. Achhe se pakaayein.')),
  _Food('🍊', LocalizedText(en: 'Citrus & amla', hi: 'Khatte phal & amla'),
      LocalizedText(
          en: 'Vitamin C helps your body absorb iron better — pair them with your rajma or spinach.',
          hi: 'Vitamin C aapke sharir ko iron behtar absorb karne mein madad karta hai — inhe rajma ya paalak ke saath lein.')),
];

class _ToDo {
  const _ToDo(this.emoji, this.title, this.detail);
  final String emoji;
  final LocalizedText title;
  final LocalizedText detail;
}

const List<_ToDo> _toDos = [
  _ToDo('🩺', LocalizedText(en: 'Your anomaly scan', hi: 'Aapka anomaly scan'),
      LocalizedText(
          en: "If you haven't already, book or attend your 20-week scan. This gentle ultrasound checks baby's growth, heart, spine and organs — and you may catch a lovely glimpse of your little one. Take your partner along if you can.",
          hi: 'Agar abhi tak nahi kiya, to apna 20-hafte ka scan book karein ya karwaayein. Yeh halka ultrasound baby ki growth, dil, reedh aur organs check karta hai — aur aapko apne nanhe ki jhalak bhi mil sakti hai. Ho sake to partner ko saath le jaayein.')),
  _ToDo(
      '🛏️',
      LocalizedText(en: 'Start sleeping on your side', hi: 'Karwat par sona shuru karein'),
      LocalizedText(
          en: "As your bump grows, resting on your side — a pillow tucked between your knees helps — keeps blood flowing well to baby. If you wake on your back, don't worry; just settle gently onto your side again.",
          hi: 'Bump badhne ke saath, karwat par aaram karna — ghutno ke beech takiya rakhne se aaram milta hai — baby tak khoon achhe se pahunchata hai. Agar peeth ke bal jaag jaayein to ghabraayein nahi; dheere se phir karwat le lein.')),
  _ToDo('🚶‍♀️', LocalizedText(en: 'Move gently, every day', hi: 'Roz halki harkat karein'),
      LocalizedText(
          en: "A short walk or some prenatal stretches can lift your mood, boost your energy and ease swelling. There's no need to push — listen to your body and rest whenever you need to.",
          hi: 'Choti si tehel ya prenatal stretches aapka mood, urja badha sakti hain aur soojan kam karti hain. Zor lagane ki zaroorat nahi — apne sharir ki sunein aur jab chahein aaram karein.')),
  _ToDo('🎵', LocalizedText(en: 'Talk and sing to your bump', hi: 'Bump se baat karein, gaayein'),
      LocalizedText(
          en: 'Baby can hear you now, and your voice is already comforting to them. Just a few quiet minutes a day — a song, a story, a hello — is a beautiful way to begin bonding.',
          hi: 'Baby ab aapko sun sakta hai, aur aapki awaaz use abhi se sukoon deti hai. Din ke kuch shaant minute — ek gaana, ek kahani, ek hello — bonding shuru karne ka pyaara tareeka hai.')),
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
          en: 'How big are 20-week bumps?', hi: '20-hafte ka bump kitna bada?'),
      '0:48',
      Color(0xFFE76A86),
      Color(0xFF8E3B7A)),
  _Vid(
      LocalizedText(
          en: 'Prenatal yoga for week 20', hi: 'Hafta 20 ka prenatal yoga'),
      '5:20',
      Color(0xFF3FA796),
      Color(0xFF276B5C)),
  _Vid(LocalizedText(en: 'Sleeping comfortably now', hi: 'Ab aaraam se sona'),
      '3:10', Color(0xFF5B7CC9), Color(0xFF324388)),
  _Vid(LocalizedText(en: 'Dressing your bump', hi: 'Apne bump ko style karein'),
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

// At least one happy "milestone" per week so the section is never blank — a
// mix of baby development and what your body is achieving.
const List<_WeekMs> _weekMilestones = [
  _WeekMs(20, '✨',
      LocalizedText(en: 'Halfway & first kicks', hi: 'Aadha safar & pehli kicks'),
      LocalizedText(en: "You've reached the midpoint and may feel the first flutters.", hi: 'Aap aadhe raaste par hain aur pehli harkatein mehsoos kar sakti hain.'),
      LocalizedText(en: 'Week 20 is the midpoint of pregnancy. Many mums feel the first gentle movements — "quickening" — around now, like soft bubbles that grow into clear kicks.', hi: 'Hafta 20 pregnancy ka madhya bindu hai. Kai maa is samay pehli halki harkatein ("quickening") mehsoos karti hain — narm bulbule jo aage saaf kicks ban jaate hain.')),
  _WeekMs(20, '🍌',
      LocalizedText(en: 'Size of a banana', hi: 'Kele jitna'),
      LocalizedText(en: 'Baby is about 25 cm and 300 g now.', hi: 'Baby ab lagbhag 25 cm aur 300 g ka hai.'),
      LocalizedText(en: 'Your baby is around the size of a banana — about 25 cm from head to heel and 300 g. From this week, length is measured head-to-heel instead of head-to-bottom.', hi: 'Aapka baby lagbhag ek kele jitna hai — sir se edi ~25 cm aur 300 g. Is hafte se lambai sir-se-edi naapi jaati hai.')),
  _WeekMs(20, '👂',
      LocalizedText(en: 'Baby can hear you', hi: 'Baby aapko sun sakta hai'),
      LocalizedText(en: 'The ears are working — baby hears your voice.', hi: 'Kaan kaam kar rahe hain — baby aapki awaaz sunta hai.'),
      LocalizedText(en: "The tiny bones in baby's ears are in place, so baby can hear your voice and heartbeat. Talk, hum and sing to your bump — it's wonderful early bonding.", hi: 'Baby ke kaano ki nanhi haddiyan ban gayi hain, isliye baby aapki awaaz aur dhadkan sun sakta hai. Bump se baat karein, gungunaayein aur gaayein.')),
  _WeekMs(21, '🍽️',
      LocalizedText(en: 'Tasting flavours', hi: 'Swaad lena'),
      LocalizedText(en: 'Baby swallows and tastes the flavours of your meals.', hi: 'Baby nigalta hai aur aapke khaane ke swaad mehsoos karta hai.'),
      LocalizedText(en: "Baby's taste buds are working and it swallows amniotic fluid daily, getting a hint of what you eat — variety now may shape later tastes.", hi: 'Baby ki swaad-kaliyan kaam kar rahi hain aur woh roz amniotic fluid nigalta hai — variety aage chal kar swaad banati hai.')),
  _WeekMs(22, '👀',
      LocalizedText(en: 'Senses sharpening', hi: 'Indriyaan tez'),
      LocalizedText(en: 'Lips, eyelids and tiny eyebrows are now formed.', hi: 'Hont, palkein aur nanhi bhauhein ban gayi hain.'),
      LocalizedText(en: "Baby's face is fully formed and the senses of touch and sight are developing quickly.", hi: 'Baby ka chehra poori tarah ban gaya hai aur chhoo-ne aur dekhne ki indriyaan tezi se viksit ho rahi hain.')),
  _WeekMs(23, '👂',
      LocalizedText(en: 'Responding to sound', hi: 'Aawaz par react'),
      LocalizedText(en: 'Baby can hear and may react to loud sounds.', hi: 'Baby sun sakta hai aur tez aawaz par react kar sakta hai.'),
      LocalizedText(en: 'Hearing is improving — baby may move or startle at loud sounds and grow familiar with your voice and favourite music.', hi: 'Sun-ne ki shakti behtar ho rahi hai — baby tez aawaz par hil ya chaunk sakta hai aur aapki awaaz se waakif ho jaata hai.')),
  _WeekMs(24, '🛡️',
      LocalizedText(en: 'Viability milestone', hi: 'Viability padaav'),
      LocalizedText(en: "A major milestone — baby's lungs start developing surfactant.", hi: 'Ek bada padaav — baby ke phephde surfactant banana shuru karte hain.'),
      LocalizedText(en: 'Week 24 is an important development milestone. The lungs begin producing surfactant, which will help baby breathe after birth.', hi: 'Hafta 24 ek ahem padaav hai. Phephde surfactant banana shuru karte hain, jo janm ke baad saans lene mein madad karega.')),
  _WeekMs(25, '🤚',
      LocalizedText(en: 'Responds to touch', hi: 'Chhoone par react'),
      LocalizedText(en: 'Baby responds to your voice and a gentle touch on the bump.', hi: 'Baby aapki awaaz aur bump par halke sparsh par react karta hai.'),
      LocalizedText(en: 'Baby reacts to your voice and to gentle touch on your bump, and hair colour and texture are starting to form.', hi: 'Baby aapki awaaz aur bump par halke sparsh par react karta hai, aur baalon ka rang-roop ban-na shuru hota hai.')),
  _WeekMs(26, '👁️',
      LocalizedText(en: 'Eyes begin to open', hi: 'Aankhein khulna shuru'),
      LocalizedText(en: "Baby's eyes start to open and can blink.", hi: 'Baby ki aankhein khulna shuru hoti hain aur palak jhapak sakti hain.'),
      LocalizedText(en: 'After weeks fused shut, the eyelids begin to open and baby can blink — and may respond to bright light.', hi: 'Kai hafton tak band rehne ke baad palkein khulna shuru hoti hain aur baby palak jhapak sakta hai — tez roshni par react bhi kar sakta hai.')),
  _WeekMs(27, '💤',
      LocalizedText(en: 'Sleep cycles & dreams', hi: 'Neend ke cycle & sapne'),
      LocalizedText(en: 'Baby now has regular sleep–wake cycles and REM (dream) sleep.', hi: 'Baby ke ab niyamit sone-jaagne ke cycle aur REM (sapno wali) neend hai.'),
      LocalizedText(en: 'Baby settles into regular sleep and wake cycles and shows REM sleep — the stage linked with dreaming.', hi: 'Baby niyamit sone-jaagne ke cycle mein aa jaata hai aur REM neend dikhata hai — sapno se juda charan.')),
  _WeekMs(28, '🌸',
      LocalizedText(en: 'Third trimester begins', hi: 'Teesri trimester shuru'),
      LocalizedText(en: 'The final stretch begins — check-ups become more frequent.', hi: 'Aakhri padav shuru — check-ups zyada baar hone lagti hain.'),
      LocalizedText(en: "Welcome to the third trimester. Baby's eyes can open and close, and your appointments will start coming more often.", hi: 'Teesri trimester mein swaagat hai. Baby ki aankhein khul-band ho sakti hain, aur appointments zyada baar hone lagengi.')),
  _WeekMs(29, '💪',
      LocalizedText(en: 'Growing stronger', hi: 'Aur mazboot'),
      LocalizedText(en: 'Muscles and lungs keep maturing; kicks feel firmer.', hi: 'Maaspeshiyan aur phephde pakte rehte hain; kicks aur mazboot.'),
      LocalizedText(en: "Baby's muscles and lungs are maturing and movements feel stronger and more defined.", hi: 'Baby ki maaspeshiyan aur phephde pak rahe hain aur harkatein zyada mazboot aur saaf lagti hain.')),
  _WeekMs(30, '🧠',
      LocalizedText(en: 'Brain growing fast', hi: 'Dimaag tezi se badhta'),
      LocalizedText(en: "Baby's brain is developing rapidly now.", hi: 'Baby ka dimaag ab tezi se viksit ho raha hai.'),
      LocalizedText(en: "Baby's brain is growing quickly, forming the grooves and folds that support learning, and can regulate temperature a little.", hi: 'Baby ka dimaag tezi se badh raha hai, seekhne mein madad karne wali silvatein ban-ti hain, aur woh tapmaan thoda niyantrit kar sakta hai.')),
  _WeekMs(31, '🫧',
      LocalizedText(en: 'Practising breathing', hi: 'Saans ki practice'),
      LocalizedText(en: 'Baby makes breathing movements to prepare the lungs.', hi: 'Baby phephdon ki taiyari ke liye saans wali harkatein karta hai.'),
      LocalizedText(en: "Baby 'practises' breathing by moving the diaphragm, getting the lungs ready for that first breath.", hi: 'Baby diaphragm hila kar saans ki "practice" karta hai, pehli saans ke liye phephdon ko taiyar karta hai.')),
  _WeekMs(32, '💅',
      LocalizedText(en: 'Nails & hair', hi: 'Naakhun & baal'),
      LocalizedText(en: 'Fingernails and toenails are formed; hair is growing.', hi: 'Haath-paer ke naakhun ban gaye; baal badh rahe hain.'),
      LocalizedText(en: 'Tiny fingernails and toenails have formed and baby may have a head of hair — the body is filling out with fat.', hi: 'Nanhe naakhun ban gaye hain aur baby ke sir par baal ho sakte hain — sharir fat se bhar raha hai.')),
  _WeekMs(33, '💡',
      LocalizedText(en: 'Reacting to light', hi: 'Roshni par react'),
      LocalizedText(en: "Baby's pupils react to light now.", hi: 'Baby ki aankh ki putli ab roshni par react karti hai.'),
      LocalizedText(en: "Baby's pupils can narrow and widen in response to light, and the immune system is getting a boost from you.", hi: 'Baby ki putli roshni par chhoti-badi ho sakti hai, aur immune system ko aapse boost mil raha hai.')),
  _WeekMs(34, '🫁',
      LocalizedText(en: 'Lungs maturing', hi: 'Phephde pak rahe'),
      LocalizedText(en: 'Central nervous system and lungs are maturing well.', hi: 'Nervous system aur phephde achhe se pak rahe hain.'),
      LocalizedText(en: "Baby's lungs and nervous system are maturing, and the protective vernix coating thickens.", hi: 'Baby ke phephde aur nervous system pak rahe hain, aur surakshit vernix parat ghani hoti hai.')),
  _WeekMs(35, '⚖️',
      LocalizedText(en: 'Gaining weight fast', hi: 'Tezi se vazan'),
      LocalizedText(en: 'Most development is done — baby is plumping up.', hi: 'Zyada vikas ho chuka — baby gol-matol ho raha hai.'),
      LocalizedText(en: "Baby's main development is largely complete; from now the focus is gaining weight and building fat for warmth.", hi: 'Baby ka mukhya vikas lagbhag poora; ab focus vazan badhane aur garmi ke liye fat banane par hai.')),
  _WeekMs(36, '🙃',
      LocalizedText(en: 'Settling head-down', hi: 'Sir-neeche position'),
      LocalizedText(en: 'Baby often settles into a head-down position.', hi: 'Baby aksar sir-neeche position mein aa jaata hai.'),
      LocalizedText(en: 'Many babies move into a head-down position ready for birth and start shedding the fine lanugo hair.', hi: 'Kai babies janm ke liye sir-neeche position mein aa jaate hain aur mahin lanugo baal jhad-ne lagte hain.')),
  _WeekMs(37, '✅',
      LocalizedText(en: 'Early term', hi: 'Early term'),
      LocalizedText(en: 'Baby is now considered early term.', hi: 'Baby ab early term maana jaata hai.'),
      LocalizedText(en: "At 37 weeks baby is 'early term' — the lungs and brain are nearly ready for life outside the womb.", hi: '37 hafte par baby "early term" hai — phephde aur dimaag bahar ki zindagi ke liye lagbhag taiyar hain.')),
  _WeekMs(38, '🤝',
      LocalizedText(en: 'Firm grasp', hi: 'Mazboot pakad'),
      LocalizedText(en: 'Baby has a firm grasp; organs are ready.', hi: 'Baby ki pakad mazboot; organs taiyar.'),
      LocalizedText(en: "Baby's grasp is strong and the organs are ready to function outside the womb — just final touches now.", hi: 'Baby ki pakad mazboot hai aur organs bahar kaam karne ko taiyar hain — bas aakhri taiyariyan.')),
  _WeekMs(39, '🌟',
      LocalizedText(en: 'Full term', hi: 'Full term'),
      LocalizedText(en: 'Baby is full term — brain and lungs keep maturing.', hi: 'Baby full term — dimaag aur phephde pakte rehte hain.'),
      LocalizedText(en: 'Baby is full term. The brain and lungs continue to mature right up until birth.', hi: 'Baby full term hai. Dimaag aur phephde janm tak pakte rehte hain.')),
  _WeekMs(40, '🎉',
      LocalizedText(en: 'Due date!', hi: 'Due date!'),
      LocalizedText(en: 'Baby is ready to meet you.', hi: 'Baby aapse milne ko taiyar hai.'),
      LocalizedText(en: "It's your due date! Remember, only about 1 in 20 babies arrive exactly on it — baby will come when ready.", hi: 'Aapki due date! Yaad rakhein, sirf 20 mein se 1 baby theek isi din aata hai — baby taiyar hone par aayega.')),
];

const List<LocalizedText> _nextRadar = [
  LocalizedText(
      en: 'Your 20-week anomaly scan happens around now.',
      hi: '20-hafte ka anomaly scan is samay hota hai.'),
  LocalizedText(
      en: 'Glucose screening usually comes up between weeks 24–28.',
      hi: 'Glucose screening aksar hafte 24–28 ke beech hoti hai.'),
  LocalizedText(
      en: "A lovely time to start thinking about your birth plan and hospital bag — no rush.",
      hi: 'Birth plan aur hospital bag ke baare mein sochne ka achha samay — koi jaldi nahi.'),
];

// "Mother this week" topics — a short teaser on the card, a fuller read in a
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
          en: 'Levels are steadier now — many feel more energy.',
          hi: 'Ab levels sthir hain — kai logon ko zyada urja.'),
      LocalizedText(
          en: "After the ups and downs of the first trimester, your hormones settle into a steadier rhythm. Many women feel a welcome lift in energy and mood — the 'pregnancy glow' often shows up around now.",
          hi: 'Pehli trimester ke utaar-chadhaav ke baad hormones sthir ho jaate hain. Kai mahilaon ko urja aur mood mein sudhaar mehsoos hota hai — "pregnancy glow" aksar abhi dikhta hai.')),
  _MotherTopic(
      '🤰',
      LocalizedText(en: 'Your bump', hi: 'Aapka bump'),
      LocalizedText(
          en: 'The top of your uterus reaches your belly button.',
          hi: 'Uterus ka upri hissa naabhi tak pahunchta hai.'),
      LocalizedText(
          en: 'Your uterus has grown to about the level of your navel, so your bump is clearly showing now. Roomier clothes and a supportive bra help, and sleeping on your side becomes the comfiest position from here on.',
          hi: 'Aapka uterus lagbhag naabhi tak badh gaya hai, isliye bump ab saaf dikhta hai. Khule kapde aur supportive bra aaram dete hain, aur ab karwat par sona sabse aaramdayak hota hai.')),
  _MotherTopic(
      '🦋',
      LocalizedText(en: 'First movements', hi: 'Pehli harkatein'),
      LocalizedText(
          en: 'You may feel the first gentle flutters (quickening).',
          hi: 'Aap pehli halki harkatein (quickening) mehsoos kar sakti hain.'),
      LocalizedText(
          en: "Those first movements — called 'quickening' — often arrive around week 20. They can feel like bubbles, a light tap or butterflies, and will be irregular at first. Over the coming weeks they grow stronger and more regular. First-time mums sometimes feel them a little later — perfectly normal.",
          hi: 'Pehli harkatein — "quickening" — aksar hafta 20 ke aas-paas aati hain. Yeh bulbule, halki thaap ya titli jaisi lag sakti hain, aur pehle anyamit hoti hain. Aage chal kar yeh mazboot aur niyamit ho jaati hain.')),
  _MotherTopic(
      '✨',
      LocalizedText(en: 'Skin & body', hi: 'Tvacha & sharir'),
      LocalizedText(
          en: 'More blood flow brings a warm glow and fuller hair.',
          hi: 'Zyada blood flow se glow aur ghane baal.'),
      LocalizedText(
          en: 'The extra blood your body is making can give your skin a warm glow and your hair a fuller look. Some women notice a dark line down the belly (linea nigra) or slight skin changes — these are normal and usually fade after birth.',
          hi: 'Aapka sharir jo zyada khoon bana raha hai usse tvacha mein glow aur baal ghane lagte hain. Kuch mahilaon ko pet par gehri rekha (linea nigra) dikhti hai — yeh normal hai aur janm ke baad aksar mit jaati hai.')),
  _MotherTopic(
      '💗',
      LocalizedText(en: 'Heart & breath', hi: 'Dil & saans'),
      LocalizedText(
          en: 'Your heart works harder — you may feel breathless.',
          hi: 'Aapka dil zyada kaam karta hai — saans phool sakti hai.'),
      LocalizedText(
          en: 'Your heart is now pumping much more blood than usual, so you may feel a little breathless on the stairs or notice your heart racing at times. Move at your own pace, rest when you need to, and stay well hydrated.',
          hi: 'Aapka dil ab pehle se kahin zyada khoon pump kar raha hai, isliye seedhi chadhte hue saans phool sakti hai ya dil tez dhadak sakta hai. Apni raftaar se chalein, zaroorat par aaram karein aur paani peete rahein.')),
  _MotherTopic(
      '🤕',
      LocalizedText(en: 'Aches & twinges', hi: 'Dard & khinchaav'),
      LocalizedText(
          en: 'Round-ligament twinges as your bump stretches.',
          hi: 'Bump khinchne se round-ligament khinchaav.'),
      LocalizedText(
          en: "You may feel occasional sharp twinges low on the sides of your bump — round-ligament pain — as the ligaments supporting your growing uterus stretch. It's usually brief and harmless; moving slowly helps. Mention anything severe or persistent to your doctor.",
          hi: 'Bump ke nichle hisson mein kabhi-kabhi tez khinchaav mehsoos ho sakta hai — round-ligament pain — jab badhte uterus ko sambhalne wale ligaments khinchte hain. Yeh aksar thodi der ka aur harmless hota hai; dheere position badalna madad karta hai.')),
];

// Father-focused "how you can help" lines for the partner share message.
const List<LocalizedText> _partnerHelp = [
  LocalizedText(
      en: 'Come along to the anomaly scan if you can — seeing baby together is special.',
      hi: 'Ho sake to anomaly scan par saath jaayein — baby ko saath dekhna khaas hota hai.'),
  LocalizedText(
      en: 'Help her sleep on her side — a pillow between the knees works wonders.',
      hi: 'Use karwat par sone mein madad karein — ghutno ke beech takiya bahut aaram deta hai.'),
  LocalizedText(
      en: 'Take over a few chores; her body is working hard for two.',
      hi: 'Kuch kaam apne zimme lein; uska sharir do logon ke liye mehnat kar raha hai.'),
  LocalizedText(
      en: 'Keep iron- and calcium-rich meals handy — greens, dairy and dal.',
      hi: 'Iron aur calcium wale khaane rakhein — saag, dairy aur dal.'),
  LocalizedText(
      en: 'Talk or sing to the bump — baby can hear your voice now.',
      hi: 'Bump se baat karein ya gaayein — baby ab aapki awaaz sunta hai.'),
];

// ===========================================================================
//  FATHER (Dad-preview) WEEK-20 COPY — same content, re-voiced for the partner
//  reading it for/about her. Used only when _fatherWeek(week) is true; the
//  mother data above is never touched. Strip with FatherPreview before launch.
// ===========================================================================
const LocalizedText _fBabyTitle =
    LocalizedText(en: 'About your baby', hi: 'Aapke baby ke baare mein');
const LocalizedText _fBabyBrief = LocalizedText(
    en: "Your baby is about the size of a banana now, can hear your voice, and is starting to move. Here's what's happening this week.",
    hi: 'Aapka baby ab lagbhag ek kele jitna hai, aapki awaaz sun sakta hai, aur hilna shuru kar raha hai. Is hafte kya ho raha hai, yahan dekhein.');
const LocalizedText _fMotherTitle =
    LocalizedText(en: "How she's doing", hi: 'Woh kaisi hai');
const LocalizedText _fMotherBrief = LocalizedText(
    en: "She's in the gentlest stretch of pregnancy — steadier energy, a visible bump, big feelings. Here's how to show up for her this week.",
    hi: 'Woh pregnancy ke sabse aaramdeh daur mein hai — sthir energy, dikhta hua bump, gehre jazbaat. Is hafte uske liye kaise saath dein, yahan dekhein.');
const LocalizedText _fNextBrief = LocalizedText(
    en: "See the scans and check-ups coming up for her — and how to be there for each.",
    hi: 'Uske aane wale scans aur check-ups dekhein — aur har ek mein kaise saath dein.');
const LocalizedText _fYouThisWeek =
    LocalizedText(en: 'Her this week', hi: 'Is hafte woh');

// ===========================================================================
//  PER-WEEK father section briefs (the re-voicing pass). 3rd-person, warm,
//  partner-facing. Authored trimester by trimester — TRIMESTER 1 (weeks 4–13)
//  + week 20 below; weeks not yet revoiced fall back to the mother's per-week
//  content via [_fBabyBriefFor] / [_fMotherBriefFor].
// ===========================================================================
const Map<int, LocalizedText> _fBabyBriefs = {
  4: LocalizedText(
      en: "Your baby's brain, spinal cord and nervous system are just starting to form, and the cells are multiplying fast. It's all invisible for now, but every day is a big step.",
      hi: "Aapke baby ke brain, spinal cord aur nervous system ki neenv abhi banna shuru hui hai, aur cells tezi se badh rahe hain. Abhi sab chhupa hua hai, par har din ek bada kadam hai."),
  5: LocalizedText(
      en: "Your baby's heart is beginning to beat this week, while the brain, spinal cord and major organs keep developing fast. Tiny as they are, they're working hard every day.",
      hi: "Is hafte aapke baby ka dil dhadakna shuru ho raha hai, aur brain, spinal cord aur major organs tezi se ban rahe hain. Itne chhote hone par bhi, woh har din mehnat kar rahe hain."),
  6: LocalizedText(
      en: "Your baby's heart is now beating regularly, the brain is developing fast, and the first hints of eyes, ears and limbs are forming. So many systems are already under construction.",
      hi: "Aapke baby ka dil ab regularly dhadak raha hai, brain tezi se ban raha hai, aur aankhein, kaan aur haath-pair ki pehli jhalak ban rahi hai. Itne saare systems pehle se ban rahe hain."),
  7: LocalizedText(
      en: "Your baby's brain is growing rapidly, tiny arm and leg buds are appearing, and the eyes, ears and nose are becoming more defined. That little heart is still beating strongly.",
      hi: "Aapke baby ka brain tezi se badh raha hai, chhote haath aur pair ke buds ban rahe hain, aur aankhein, kaan aur naak saaf hoti ja rahi hain. Woh nanha dil ab bhi mazbooti se dhadak raha hai."),
  8: LocalizedText(
      en: "Your baby's fingers and toes are starting to form, the little face is becoming more recognisable, and all the major organs have begun developing. The groundwork for the next stage is in place.",
      hi: "Aapke baby ke haath-pair ki ungliyaan banna shuru ho rahi hain, nanha chehra zyada saaf dikhne laga hai, aur saare major organs develop hone lage hain. Agle stage ki neev ab taiyar hai."),
  9: LocalizedText(
      en: "Your baby's arms and legs are getting longer, the joints are forming, and the first small movements are beginning. The heart now has all four chambers and is working hard.",
      hi: "Aapke baby ke haath-pair lambe ho rahe hain, joints ban rahe hain, aur pehli chhoti harkatein shuru ho rahi hain. Dil ab chaaron chambers ke saath ban chuka hai aur mehnat kar raha hai."),
  10: LocalizedText(
      en: "Your baby's fingers and toes are separating, the jaw and face are taking shape, and the brain is building millions of new connections. There are tiny movements now — still far too small for her to feel.",
      hi: "Aapke baby ki ungliyaan aur pair alag ho rahe hain, jaw aur chehra ban raha hai, aur brain laakhon nayi connections bana raha hai. Ab nanhi harkatein bhi hoti hain — abhi itni chhoti ki use mehsoos nahi hotin."),
  11: LocalizedText(
      en: "Your baby's fingers and toes are fully separated now, the bones are starting to harden, and there's stretching, kicking and moving inside that tiny world. The little face grows clearer by the day.",
      hi: "Aapke baby ki ungliyaan ab poori tarah alag ho gayi hain, haddiyan mazboot honi shuru ho rahi hain, aur woh apni chhoti duniya mein stretch, kick aur move kar raha hai. Nanha chehra din-ba-din saaf hota ja raha hai."),
  12: LocalizedText(
      en: "Most of your baby's major organs have formed and are starting to work. There's arm and leg movement, tiny fingers opening and closing, and reflexes developing every day.",
      hi: "Aapke baby ke zyadatar major organs ban chuke hain aur kaam karne lage hain. Haath-pair hilte hain, nanhi ungliyaan khulti-bandh hoti hain, aur reflexes har din develop ho rahe hain."),
  13: LocalizedText(
      en: "Your baby's vocal cords are forming, fingerprints are starting to develop, and the bones keep getting stronger. There's plenty of free movement inside that tiny world now.",
      hi: "Aapke baby ke vocal cords ban rahe hain, fingerprints develop hone lage hain, aur haddiyan aur mazboot ho rahi hain. Ab us chhoti duniya mein khoob aazaadi se harkat hoti hai."),
  14: LocalizedText(
      en: "Your baby's facial muscles are developing enough for tiny expressions, the neck is getting stronger, and for the first time the body is growing faster than the head.",
      hi: "Aapke baby ki chehre ki muscles itni develop ho gayi hain ki nanhe expressions ban-ne lage hain, gardan mazboot ho rahi hai, aur pehli baar body sar se zyada tezi se badh raha hai."),
  15: LocalizedText(
      en: "Your baby's muscles and bones are getting stronger, with smoother movements of the arms, legs and joints. The ears are developing too, getting ready to hear the world in the weeks ahead.",
      hi: "Aapke baby ki muscles aur haddiyan mazboot ho rahi hain, aur haath, pair aur joints ki harkatein zyada smooth ho gayi hain. Kaan bhi develop ho rahe hain, aane wale hafton mein duniya sunne ki taiyaari mein."),
  16: LocalizedText(
      en: "Your baby's bones are hardening, the muscles are getting stronger, and the ears are developing fast — soon there'll be the first responses to sounds from the outside world.",
      hi: "Aapke baby ki haddiyan mazboot ho rahi hain, muscles strong ho rahe hain, aur kaan tezi se develop ho rahe hain — jald hi bahar ki duniya ki aawaazon par pehli react dikhegi."),
  17: LocalizedText(
      en: "Your baby's skeleton is turning from soft cartilage into stronger bone, the muscles are growing more powerful, and there's lots of practising of the movements that help growth.",
      hi: "Aapke baby ka skeleton naram cartilage se mazboot haddi mein badal raha hai, muscles aur powerful ho rahi hain, aur woh aisi movements practice kar raha hai jo growth mein madad karti hain."),
  18: LocalizedText(
      en: "Your baby's ears are developing fast and the brain is making millions of new connections. Arm and leg movements are more controlled now, and the nervous system is getting more sophisticated.",
      hi: "Aapke baby ke kaan tezi se develop ho rahe hain aur brain laakhon naye connections bana raha hai. Haath-pair ab zyada control ke saath hilte hain, aur nervous system aur advanced ho raha hai."),
  19: LocalizedText(
      en: "Your baby's brain keeps developing fast, the senses are sharpening, and a protective coating called vernix is forming on the skin. The arms and legs are stronger, and there's more activity than ever.",
      hi: "Aapke baby ka brain tezi se develop ho raha hai, senses aur sharp ho rahe hain, aur skin par vernix naam ki protective coating ban rahi hai. Haath-pair mazboot hain, aur pehle se zyada activity hai."),
  20: _fBabyBrief,
  21: LocalizedText(
      en: "Your baby's taste buds are developing, more amniotic fluid is being swallowed, and the movements are getting stronger and better coordinated. The brain keeps making millions of new connections.",
      hi: "Aapke baby ke taste buds develop ho rahe hain, woh zyada amniotic fluid nigal raha hai, aur harkatein mazboot aur zyada coordinated ho rahi hain. Brain laakhon naye connections banata ja raha hai."),
  22: LocalizedText(
      en: "Your baby's hearing is developing fast — picking up her heartbeat, voices (yours included) and even some sounds from outside the womb. That little brain is busy learning from all of it.",
      hi: "Aapke baby ki hearing tezi se develop ho rahi hai — uski dil ki dhadkan, awaazein (aapki bhi) aur womb ke bahar ki kuch aawaazein bhi sun raha hai. Woh nanha brain in sab se seekhta ja raha hai."),
  23: LocalizedText(
      en: "Your baby's brain is developing at an incredible pace — new connections forming every second, laying the groundwork for learning, memory and movement. The hearing keeps improving, and familiar sounds are being recognised.",
      hi: "Aapke baby ka brain zabardast raftaar se develop ho raha hai — har second naye connections ban rahe hain, jo seekhne, yaad rakhne aur movement ki neenv banate hain. Hearing behtar ho rahi hai, aur jaani-pehchaani aawazein pehchaani jaane lagi hain."),
  24: LocalizedText(
      en: "Your baby's hearing is getting sharper, the brain keeps building new pathways, and regular periods of sleep and activity are starting to form. The lungs are continuing their important development too.",
      hi: "Aapke baby ki hearing aur sharp ho rahi hai, brain naye rastey banata ja raha hai, aur sone-jaagne ke regular periods ban-ne lage hain. Lungs bhi apna important development safar jaari rakhe hue hain."),
  25: LocalizedText(
      en: "Your baby's hearing is getting more refined and there are responses to the sounds around now. The brain keeps developing fast, and the movements are stronger and better coordinated.",
      hi: "Aapke baby ki hearing aur refined ho rahi hai aur ab aas-paas ki aawaazon par react hota hai. Brain tezi se develop ho raha hai, aur harkatein aur mazboot aur coordinated ho rahi hain."),
  26: LocalizedText(
      en: "Your baby's eyes are starting to open, the hearing keeps improving, and the brain is developing rapidly. There are responses now to sounds, movement and changes in the surroundings.",
      hi: "Aapke baby ki aankhein khulna shuru ho rahi hain, hearing behtar ho rahi hai, aur brain tezi se develop ho raha hai. Ab aawazon, movement aur maahaul ke badlaav par react hota hai."),
  27: LocalizedText(
      en: "Your baby's brain, lungs and nervous system keep maturing fast. There's practising of breathing movements, eyes opening and closing, and a little more strength every day.",
      hi: "Aapke baby ka brain, lungs aur nervous system tezi se mature ho rahe hain. Breathing movements ki practice ho rahi hai, aankhein khulti-bandh hoti hain, aur har din thodi aur mazbooti aati hai."),
  28: LocalizedText(
      en: "Your baby can open and close those eyes now, blink and respond to light. The brain is developing fast, and the lungs keep preparing for life outside the womb.",
      hi: "Aapka baby ab aankhein khol-band kar sakta hai, blink kar sakta hai aur roshni par react karta hai. Brain tezi se develop ho raha hai, aur lungs womb ke bahar ki zindagi ke liye taiyaari karte ja rahe hain."),
  29: LocalizedText(
      en: "Your baby is building fat under the skin, strengthening those muscles, and maturing the lungs and brain. The movements are getting more powerful with every passing week.",
      hi: "Aapka baby skin ke neeche fat bana raha hai, muscles mazboot kar raha hai, aur lungs aur brain ko mature kar raha hai. Har hafte ke saath harkatein aur powerful hoti ja rahi hain."),
  30: LocalizedText(
      en: "Your baby's brain is developing new folds and connections, the lungs keep maturing, and body fat is building up — the kind that helps keep warm after birth.",
      hi: "Aapke baby ke brain mein naye folds aur connections ban rahe hain, lungs mature hote ja rahe hain, aur body fat badh raha hai — wahi jo birth ke baad garam rakhne mein madad karta hai."),
  31: LocalizedText(
      en: "Your baby is gaining body fat, building muscle, and maturing the lungs and brain. The movements are stronger than ever, even as space inside starts to feel a little tighter.",
      hi: "Aapka baby body fat badha raha hai, muscles bana raha hai, aur lungs aur brain ko mature kar raha hai. Andar jagah thodi tang hone lagi hai, phir bhi harkatein pehle se zyada mazboot hain."),
  32: LocalizedText(
      en: "Your baby is practising breathing movements, sleeping in cycles, and maturing the lungs and nervous system. The body is storing up the nutrients and energy needed for life after birth.",
      hi: "Aapka baby saans lene ki movements practice kar raha hai, cycles mein so raha hai, aur lungs aur nervous system ko mature kar raha hai. Body janam ke baad ki zindagi ke liye zaroori nutrients aur energy store kar raha hai."),
  33: LocalizedText(
      en: "Your baby's brain and lungs keep maturing, and antibodies are passing across from her — protection that will help after birth. There's more fat and a little more strength every day.",
      hi: "Aapke baby ke brain aur lungs mature hote ja rahe hain, aur uss se antibodies baby tak pahunch rahi hain — jo birth ke baad raksha mein madad karengi. Har din thoda aur fat aur thodi aur mazbooti aati hai."),
  34: LocalizedText(
      en: "Your baby's lungs keep maturing, the brain is developing fast, and body fat is building to help with temperature after birth. Most of the systems are now getting ready for life outside the womb.",
      hi: "Aapke baby ke lungs mature hote ja rahe hain, brain tezi se develop ho raha hai, aur body fat badh raha hai jo birth ke baad temperature mein madad karega. Zyadatar systems ab womb ke bahar ki zindagi ke liye taiyaar ho rahe hain."),
  35: LocalizedText(
      en: "Your baby's lungs are nearly mature, the brain keeps developing fast, and body fat is building every day. Around this stage many babies begin settling into a head-down position, ready for the way out.",
      hi: "Aapke baby ke lungs lagbhag mature ho chuke hain, brain tezi se develop hota ja raha hai, aur har din body fat badh raha hai. Is stage ke aas-paas kai babies head-down position mein settle hone lagte hain, bahar aane ke liye taiyaar."),
  36: LocalizedText(
      en: "Your baby's lungs are almost fully mature, the brain keeps developing fast, and the reflexes for after birth — sucking, grasping — are being practised. Nearly ready to meet you both.",
      hi: "Aapke baby ke lungs lagbhag poori tarah mature ho chuke hain, brain tezi se develop hota ja raha hai, aur birth ke baad ke reflexes — chusna, pakadna — practice ho rahe hain. Aap dono se milne ke lagbhag taiyaar."),
  37: LocalizedText(
      en: "Your baby's lungs are ready for life outside the womb, the brain keeps developing, and the reflexes for after birth are being practised. Most of the growth now is about gaining strength and storing energy — full-term is here.",
      hi: "Aapke baby ke lungs womb ke bahar ki zindagi ke liye taiyaar hain, brain develop hota rehta hai, aur birth ke baad ke reflexes practice ho rahe hain. Ab zyadatar growth taakat banane aur energy store karne par hai — full-term aa gaya hai."),
  38: LocalizedText(
      en: "Your baby's lungs are ready, the brain is still developing fast, and strength and energy reserves keep building. Most of the work now is simply getting ready for birth and the world outside.",
      hi: "Aapke baby ke lungs taiyaar hain, brain abhi bhi tezi se develop ho raha hai, aur taakat aur energy reserves banti ja rahi hain. Ab zyadatar kaam bas janam aur bahar ki duniya ke liye taiyaari karna hai."),
  39: LocalizedText(
      en: "Your baby's lungs are ready for that first breath, the reflexes are developed, and small reserves of fat and energy keep building. Most of the work now is simply waiting for labour to begin.",
      hi: "Aapke baby ke lungs pehli saans ke liye taiyaar hain, reflexes develop ho chuke hain, aur fat aur energy ke chote reserves banti ja rahi hain. Ab zyadatar kaam bas labour shuru hone ka intezaar karna hai."),
  40: LocalizedText(
      en: "Your baby's lungs are ready for that first breath, and the heart, brain and body are all prepared for life outside the womb. Right now, your baby is just waiting for the perfect moment to begin the journey into your arms.",
      hi: "Aapke baby ke lungs pehli saans ke liye taiyaar hain, aur dil, brain aur body sab womb ke bahar ki zindagi ke liye taiyaar hain. Abhi, aapka baby bas us perfect pal ka intezaar kar raha hai jab woh aapki baahon mein apna safar shuru karega."),
};

const Map<int, LocalizedText> _fMotherBriefs = {
  4: LocalizedText(
      en: "Excitement, disbelief and a little anxiety are probably arriving all at once as she takes in the news. A calm, steady you helps more than you'd think.",
      hi: "News ko samajhte hue excitement, yakeen na hona aur thodi anxiety shayad ek saath aa rahe hain. Aapka shaant aur sthir hona socha se zyada madad karta hai."),
  5: LocalizedText(
      en: "She may swing between excitement, joy, disbelief and worry through the day. None of it needs fixing — just let her know you're in it together.",
      hi: "Din bhar woh excitement, khushi, yakeen na hona aur fikr ke beech jhool sakti hai. Inhe theek karne ki zaroorat nahi — bas use ehsaas dilayein ki aap saath hain."),
  6: LocalizedText(
      en: "She might feel excited one moment and wiped out the next — the ups and downs are normal this week. Picking up a few chores quietly goes a long way.",
      hi: "Kabhi woh excited feel karegi, agle hi pal thaki hui — is hafte yeh utaar-chadhaav normal hai. Chupchaap kuch kaam sambhaal lena bahut madad karta hai."),
  7: LocalizedText(
      en: "She may feel excited one moment and worried the next — those swings are a normal part of early pregnancy. Patience and a listening ear are the best things you can offer.",
      hi: "Kabhi woh excited, to agle pal pareshaan — early pregnancy mein yeh utaar-chadhaav normal hai. Sabra aur dhyaan se sunna sabse achhi cheez hai jo aap de sakte hain."),
  8: LocalizedText(
      en: "With her first big scan coming up, she's probably feeling a mix of excitement and uncertainty. Offer to go with her — it helps to have you there.",
      hi: "Pehla bada scan paas aate hue, woh shayad excitement aur uncertainty dono mehsoos kar rahi hai. Saath jaane ki peshkash karein — aapka wahan hona madad karta hai."),
  9: LocalizedText(
      en: "She may feel more connected to the pregnancy now, even while wondering what's ahead. Small check-ins — 'how are you feeling today?' — mean a lot.",
      hi: "Ab woh pregnancy se zyada juda mehsoos kar sakti hai, bhale hi aage kya hoga yeh soch rahi ho. Chhote sawaal — 'aaj kaisa lag raha hai?' — bahut maayne rakhte hain."),
  10: LocalizedText(
      en: "She may feel closer to the pregnancy while still carrying some uncertainty about the future. Just being someone she can talk it through with helps settle the nerves.",
      hi: "Woh pregnancy se zyada juda mehsoos kar sakti hai, par future ko le kar thodi uncertainty bhi reh sakti hai. Bas aisa koi hona jisse woh baat kar sake, ghabraahat ko shaant karta hai."),
  11: LocalizedText(
      en: "She may feel more confident than a few weeks ago, though the odd worry is still completely normal. Keep reassuring her — and keep showing up at the appointments.",
      hi: "Kuch hafte pehle ke mukable woh zyada confident mehsoos kar sakti hai, par kabhi-kabhi fikr hona bilkul normal hai. Use bharosa dilaate rahein — aur appointments mein saath aate rahein."),
  12: LocalizedText(
      en: "Reaching the end of the first trimester, she may feel relief, gratitude and fresh confidence. A lovely moment to celebrate together — you've come through the hardest early stretch.",
      hi: "Pehle trimester ke ant tak pahunchte hue, woh rahat, kritagyata aur naya confidence mehsoos kar sakti hai. Yeh saath jashn manane ka pyaara pal hai — aap sabse mushkil shuruaati daur paar kar aaye hain."),
  13: LocalizedText(
      en: "As the first trimester closes, relief and excitement often take the place of the early uncertainty. A good time to start dreaming and planning the next stretch together.",
      hi: "Pehla trimester khatam hote hue, shuruaati uncertainty ki jagah aksar rahat aur excitement le leti hai. Agle daur ke sapne dekhne aur saath planning shuru karne ka achha samay."),
  14: LocalizedText(
      en: "She may feel more connected to the baby now that the pregnancy is starting to show to the world. Noticing the bump with her — without making her self-conscious — is a sweet way to share it.",
      hi: "Ab jab pregnancy bahar dikhne lagi hai, woh baby se aur juda mehsoos kar sakti hai. Bump ko uske saath notice karna — bina use self-conscious banaaye — ise baantne ka pyaara tareeka hai."),
  15: LocalizedText(
      en: "She may feel more settled and optimistic now, and might be starting to picture life after the birth. It's a lovely time to dream about it together.",
      hi: "Ab woh zyada settled aur umeed se bhari mehsoos kar sakti hai, aur janm ke baad ki zindagi ki kalpana karne lag sakti hai. Ise saath sapna dekhne ka pyaara samay hai."),
  16: LocalizedText(
      en: "She's likely feeling more confident and emotionally settled in this phase. A good stretch to enjoy together before the busier weeks ahead.",
      hi: "Is phase mein woh shayad zyada confident aur emotionally settled mehsoos kar rahi hai. Aage ke vyast hafton se pehle ise saath enjoy karne ka achha daur hai."),
  17: LocalizedText(
      en: "Excitement often grows around now as she starts anticipating the first movements she'll actually feel. Ask her about them — sharing that wait builds the bond.",
      hi: "Is samay aksar excitement badh jaati hai kyunki woh pehli mehsoos hone wali harkaton ka intezaar karne lagti hai. Unke baare mein uss se poochein — woh intezaar baantna bond banata hai."),
  18: LocalizedText(
      en: "With the anomaly scan approaching, excitement is building and the baby feels more real than ever for her. Plan to be at that scan with her if you can.",
      hi: "Anomaly scan paas aate hue excitement badh rahi hai aur baby uske liye pehle se kahin zyada real lag raha hai. Ho sake to us scan mein uske saath rehne ka plan banayein."),
  19: LocalizedText(
      en: "She may feel excited about the anomaly scan while also wondering what the second half of pregnancy holds. Being curious alongside her — not rushing to reassure — helps most.",
      hi: "Woh anomaly scan ko lekar excited mehsoos kar sakti hai, saath hi soch sakti hai ki pregnancy ka agla aadha hissa kya laayega. Uske saath jigyasu rehna — jaldi bharosa dene ke bajaye — sabse zyada madad karta hai."),
  20: _fMotherBrief,
  21: LocalizedText(
      en: "As the movements get more frequent and noticeable, she's likely feeling more and more connected to the baby. Put a hand on the bump with her when there's a kick — it's a moment you can share.",
      hi: "Jaise-jaise harkatein zyada frequent aur noticeable hoti hain, woh baby se aur juda mehsoos kar rahi hai. Jab kick ho to uske saath bump par haath rakhein — yeh pal aap dono baant sakte hain."),
  22: LocalizedText(
      en: "Many mothers feel a stronger bond once they realise the baby can hear their voice — she may too. A good reason for you both to talk and sing to the bump now.",
      hi: "Bahut si mothers ko gehra bond mehsoos hota hai jab pata chalta hai ki baby unki awaaz sun sakta hai — woh bhi aisa feel kar sakti hai. Ab bump se baat karne aur gungunaane ka achha bahaana."),
  23: LocalizedText(
      en: "She's likely feeling deeply connected now as the baby's movement patterns become familiar. She may start noticing when the baby is awake or resting — ask her about it.",
      hi: "Ab jab baby ke movement patterns familiar ho rahe hain, woh gehraai se juda mehsoos kar rahi hai. Woh notice karne lag sakti hai ki baby kab jaag raha hai ya aaram kar raha hai — uss se poochein."),
  24: LocalizedText(
      en: "As the baby's movement patterns become familiar, she may be feeling a deeper connection. Around now there may be a glucose test too — offer to go along and keep her company.",
      hi: "Jaise-jaise baby ke movement patterns familiar hote hain, woh gehra connection mehsoos kar sakti hai. Is samay glucose test bhi ho sakta hai — saath jaane aur uska saath dene ki peshkash karein."),
  25: LocalizedText(
      en: "She may feel a deeper connection as she starts recognising the baby's own unique movement patterns. When she points one out, lean in — those shared moments matter.",
      hi: "Jab woh baby ke apne khaas movement patterns pehchaanne lagti hai, woh gehra connection mehsoos kar sakti hai. Jab woh koi harkat bataye, dhyaan dein — woh saanjhe pal maayne rakhte hain."),
  26: LocalizedText(
      en: "She may feel grateful and connected, and increasingly aware that the third trimester is near. A good moment to start thinking together about the months ahead.",
      hi: "Woh grateful aur juda mehsoos kar sakti hai, aur yeh ehsaas badh raha hai ki teesra trimester kareeb hai. Aane wale mahinon ke baare mein saath sochna shuru karne ka achha pal."),
  27: LocalizedText(
      en: "Entering the final trimester, she may feel proud, excited and a little overwhelmed all at once. Taking a few things off her plate now goes a long way.",
      hi: "Final trimester mein aate hue, woh proud, excited aur thoda overwhelmed ek saath mehsoos kar sakti hai. Ab uske kuch kaam sambhaal lena bahut madad karta hai."),
  28: LocalizedText(
      en: "She may be balancing excitement about meeting the baby with the first real thoughts about labour and birth. A good time to start learning the plan together.",
      hi: "Woh baby se milne ki excitement ke saath labour aur birth ke pehle asli khayaalon ko balance kar rahi ho sakti hai. Plan saath seekhna shuru karne ka achha samay."),
  29: LocalizedText(
      en: "She may be thinking more and more about labour, delivery and life with the newborn. Listening as she talks it through — and helping where you can — eases the load.",
      hi: "Woh labour, delivery aur newborn ke saath zindagi ke baare mein zyada sochne lag sakti hai. Jab woh ise baat karke samjhe to sunna — aur jahan ho sake madad karna — bojh halka karta hai."),
  30: LocalizedText(
      en: "She may be thinking seriously now about labour, delivery and the recovery afterwards. Reading up on postpartum support with her shows you're in this for the long haul.",
      hi: "Woh ab labour, delivery aur uske baad ki recovery ke baare mein gambhirta se soch sakti hai. Postpartum support ke baare mein uske saath padhna dikhaata hai ki aap lambe safar ke liye saath hain."),
  31: LocalizedText(
      en: "She may swing between excitement about meeting the baby and feeling overwhelmed by all there still is to prepare. Taking a few prep tasks off her list is a real gift right now.",
      hi: "Woh kabhi baby se milne ke excitement aur kabhi abhi tak taiyaar karne wali har cheez se overwhelmed mehsoos kar sakti hai. Kuch prep ke kaam uski list se hata lena abhi sacha tohfa hai."),
  32: LocalizedText(
      en: "She may be mentally preparing for labour while picturing life with the newborn. Around now there's often a growth scan — go along if you can, it's reassuring for you both.",
      hi: "Woh newborn ke saath zindagi ki kalpana karte hue labour ke liye mansik taiyaari kar rahi ho sakti hai. Is samay aksar growth scan hota hai — ho sake to saath jaayein, aap dono ke liye rahat-bhara hota hai."),
  33: LocalizedText(
      en: "She may feel excited, protective and increasingly focused on getting ready for the baby's arrival. Sorting the nursery or the hospital bag together channels that energy well.",
      hi: "Woh excited, protective aur baby ke aane ki taiyaari par zyada focused mehsoos kar sakti hai. Nursery ya hospital bag saath taiyaar karna us energy ko achhe se istemaal karta hai."),
  34: LocalizedText(
      en: "She may feel a mix of excitement, anticipation and the odd flash of nerves about labour and delivery. Steady reassurance — and having the plan ready — settles a lot of that.",
      hi: "Woh labour aur delivery ko le kar excitement, intezaar aur kabhi-kabhi nervousness ka mishran mehsoos kar sakti hai. Sthir bharosa — aur plan taiyaar rakhna — usmein se bahut kuch shaant kar deta hai."),
  35: LocalizedText(
      en: "Excitement and anticipation are often mixed with a real curiosity about when labour will start. The 'any day now' feeling is exciting — and a little nerve-wracking for her.",
      hi: "Excitement aur intezaar ke saath aksar yeh curiosity bhi hoti hai ki labour kab shuru hoga. 'Kisi bhi din' wala ehsaas exciting hai — aur uske liye thoda nerve-wracking bhi."),
  36: LocalizedText(
      en: "Excitement, impatience and anticipation often grow stronger as the due date nears. This is the week to have the hospital bag packed and the plan locked in together.",
      hi: "Jaise-jaise due date paas aati hai, excitement, besabri aur intezaar aksar aur badh jaate hain. Yeh woh hafta hai jab hospital bag pack aur plan saath taiyaar hona chahiye."),
  37: LocalizedText(
      en: "Excitement, impatience and anticipation are very common now — she may be wondering every single day whether today's the day. Keep your phone on and stay close by.",
      hi: "Ab excitement, besabri aur intezaar bahut aam hain — woh har din soch sakti hai ki kya aaj woh din hai. Apna phone on rakhein aur paas rahein."),
  38: LocalizedText(
      en: "As the end of pregnancy nears, she may feel excited, impatient, emotional or deeply reflective — sometimes all at once. Just being present and unhurried with her means a lot now.",
      hi: "Pregnancy ke ant ke kareeb aate hue, woh excited, beqaraar, emotional ya gehraai se vichaarsheel mehsoos kar sakti hai — kabhi sab ek saath. Abhi uske saath maujood aur bina jaldbaazi ke rehna bahut maayne rakhta hai."),
  39: LocalizedText(
      en: "She may feel excited, impatient, emotional, nervous — or all of them in the same day. Every one of those feelings is normal; your calm, steady presence is the anchor.",
      hi: "Woh excited, beqaraar, emotional, nervous — ya ek hi din mein yeh sab mehsoos kar sakti hai. In sab feelings ka aana normal hai; aapki shaant, sthir maujoodgi hi sahara hai."),
  40: LocalizedText(
      en: "She may feel excited, impatient, emotional, nervous, peaceful — or all of these in a single day. Every feeling is valid; you've reached the finish line together, and your steadiness matters most now.",
      hi: "Woh excited, beqaraar, emotional, nervous, peaceful — ya ek hi din mein yeh sab mehsoos kar sakti hai. Har feeling valid hai; aap saath finish line tak pahunch gaye hain, aur abhi aapki sthirta sabse zyada maayne rakhti hai."),
};

// The father section brief for a week: the re-voiced copy where authored, else
// the mother's per-week content (until that week is revoiced).
LocalizedText _fBabyBriefFor(WeekContent w) =>
    _fBabyBriefs[w.week] ?? w.development.whatImDoing;
LocalizedText _fMotherBriefFor(WeekContent w) =>
    _fMotherBriefs[w.week] ?? w.mom.emotionalState;

// Father "What's next" — Scans & appointments only, re-voiced for the partner:
// what's coming up for her, and how he can show up for each.
const LocalizedText _fNextLabel =
    LocalizedText(en: "What's coming up", hi: 'Aage kya aana hai');

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
    en: "These are the same scans and check-ups she'll have — here's what each one is, and how to be there for it.",
    hi: "Yeh wahi scans aur check-ups hain jo use honge — har ek kya hai, aur usmein kaise saath dein, yahan dekhein.");

// The MOTHER's scans (same data as kJourneyMilestones medical), re-voiced for the
// partner: what each is + how to show up. One per scan type, filtered by week, so
// the father's What's-next works on EVERY week (not just 20). NOT father-only
// scans — the same appointments, his lens.
const List<_FScan> _fScans = [
  _FScan(
    7,
    '🔎',
    LocalizedText(en: 'Dating / early scan', hi: 'Dating / early scan'),
    LocalizedText(en: 'Weeks 6–9', hi: 'Hafte 6–9'),
    LocalizedText(
        en: "The first proper look at the baby — it confirms the due date and the heartbeat. For many couples this is the moment it all feels real.",
        hi: "Baby ki pehli theek-thaak jhalak — yeh due date aur dhadkan confirm karta hai. Kai couples ke liye yahi woh pal hota hai jab sab kuch asli lagne lagta hai."),
    LocalizedText(
        en: "Go with her if you can — it's a lovely first memory to share. A full bladder is often needed, so plan the timing together.",
        hi: "Ho sake to uske saath jaayein — yeh saath baantne wali pehli pyaari yaad hai. Aksar bhara hua bladder chahiye hota hai, isliye timing saath plan karein."),
  ),
  _FScan(
    12,
    '🧬',
    LocalizedText(en: 'NT scan & first screening', hi: 'NT scan aur pehli screening'),
    LocalizedText(en: 'Weeks 11–14', hi: 'Hafte 11–14'),
    LocalizedText(
        en: "A scan (often with a blood test) that checks the baby's growth and screens for some conditions. Waiting for the results can stir a little anxiety.",
        hi: "Ek scan (aksar blood test ke saath) jo baby ki growth dekhta hai aur kuch conditions ki screening karta hai. Results ka intezaar thodi ghabraahat la sakta hai."),
    LocalizedText(
        en: "Be there for the appointment, and be the steady one while you wait for results. Most come back reassuring.",
        hi: "Appointment mein saath rahein, aur results ke intezaar mein shaant sahara banein. Zyaadatar rahat dene wale aate hain."),
  ),
  _FScan(
    20,
    '🔍',
    LocalizedText(
        en: 'Her 20-week anomaly scan', hi: 'Uska 20-hafte ka anomaly scan'),
    LocalizedText(en: 'Weeks 18–22', hi: 'Hafte 18–22'),
    LocalizedText(
        en: "This detailed scan checks the baby's heart, brain, spine and organs — and often shows the sex, if you both want to know. A big, emotional moment, and most findings are reassuring.",
        hi: "Yeh detailed scan baby ke dil, dimaag, reedh aur organs check karta hai — aur agar aap dono jaanna chaahein to aksar sex bhi dikha deta hai. Ek bada, bhaavuk pal, aur zyaadatar findings rahat dene wale hote hain."),
    LocalizedText(
        en: "Go with her if you possibly can. Write your questions down together beforehand, and just be the calm beside her in the room.",
        hi: "Ho sake to zaroor uske saath jaayein. Sawaal pehle se saath likh lein, aur room mein uske paas bas shaant maujoodgi banein."),
  ),
  _FScan(
    26,
    '🩸',
    LocalizedText(en: 'Glucose screening', hi: 'Glucose screening'),
    LocalizedText(en: 'Weeks 24–28', hi: 'Hafte 24–28'),
    LocalizedText(
        en: "A routine test for gestational diabetes. She may have to fast and then wait a while after a sugary drink, so it can be a long, tiring morning for her.",
        hi: "Gestational diabetes ke liye ek routine test. Use fast karna pad sakta hai aur sugary drink ke baad thoda intezaar karna hota hai, isliye uske liye subah lambi aur thakaane wali ho sakti hai."),
    LocalizedText(
        en: "Offer to drive and keep her company through the waiting. Have a proper snack ready for the minute it's done.",
        hi: "Use le jaane aur intezaar mein saath dene ki peshkash karein. Test khatam hote hi ek achha snack taiyar rakhein."),
  ),
  _FScan(
    32,
    '📏',
    LocalizedText(en: 'Growth scan', hi: 'Growth scan'),
    LocalizedText(en: 'Weeks 30–34', hi: 'Hafte 30–34'),
    LocalizedText(
        en: "A check on the baby's size, position and the fluid around them, making sure everything is on track for the weeks ahead.",
        hi: "Baby ke size, position aur uske aas-paas ke fluid ki jaanch, taaki aane wale hafton ke liye sab theek raste par ho."),
    LocalizedText(
        en: "Another lovely one to attend together. If the baby isn't head-down yet, don't worry — there's still plenty of time to turn.",
        hi: "Saath jaane wala ek aur pyaara moka. Agar baby abhi sir-neeche nahi hai to chinta na karein — palatne ke liye abhi kaafi samay hai."),
  ),
  _FScan(
    36,
    '📝',
    LocalizedText(en: 'Birth plan & final checks', hi: 'Birth plan aur aakhri checks'),
    LocalizedText(en: 'Weeks 36–38', hi: 'Hafte 36–38'),
    LocalizedText(
        en: "Around now you'll talk through the birth plan, and she may have a GBS swab and more frequent check-ups as the due date nears.",
        hi: "Is samay aap birth plan par baat karenge, aur due date paas aate hi use GBS swab aur zyada baar check-ups ho sakte hain."),
    LocalizedText(
        en: "Learn the plan with her so you can speak up for her on the day. Pack the hospital bag together and keep the car ready.",
        hi: "Plan use ke saath seekhein taaki us din aap uski awaaz ban sakein. Hospital bag saath pack karein aur gaadi taiyar rakhein."),
  ),
];

// Father trimester section — same topics as the mother's tips, re-voiced as
// "what she's going through + how you can help" (he isn't in the trimester, so
// the heading avoids "your trimester tips").
const LocalizedText _fTipsTitle = LocalizedText(
    en: 'Supporting her this trimester', hi: 'Is trimester mein uska saath');
const LocalizedText _fTipsSubtitle = LocalizedText(
    en: "What she's going through — and how to help",
    hi: 'Woh kya mehsoos kar rahi hai, aur kaise madad karein');

// Father "supporting her this trimester" tips, now PER-TRIMESTER so every week
// has them (T1/T3 added; T2 kept). Re-voiced as "what she's going through + how
// you can help."
const Map<int, List<TrimesterTip>> _fTrimesterTips = {
  // First trimester — early days, mostly invisible but hard for her.
  1: [
    TrimesterTip(
      emoji: '🤢',
      title: LocalizedText(
          en: 'Ride out the nausea with her',
          hi: 'Matli mein uska saath dein'),
      body: LocalizedText(
          en: "Morning sickness and bone-deep tiredness are at their worst now, even though nothing shows yet. Keep plain crackers by the bed, offer ginger or lemon water, and never take the mood swings personally — it's the hormones, not you.",
          hi: "Subah ki matli aur gehri thakaan abhi sabse zyada hoti hai, bhale hi bahar kuch na dikhe. Bistar ke paas saade crackers rakhein, adrak ya nimbu paani dein, aur mood swings ko kabhi dil par na lein — yeh hormones hain, aap nahi."),
    ),
    TrimesterTip(
      emoji: '🩺',
      title: LocalizedText(
          en: 'Come to the first scan',
          hi: 'Pehle scan mein saath aayein'),
      body: LocalizedText(
          en: "The early dating scan and booking appointment usually happen now — the first glimpse of the baby and the heartbeat. Go with her if you can; it's a big, emotional first, and there's a lot to take in together.",
          hi: "Shuruaati dating scan aur booking appointment aksar abhi hote hain — baby aur dhadkan ki pehli jhalak. Ho sake to uske saath jaayein; yeh ek bada, bhaavuk pehla pal hai, aur saath samajhne layak kaafi kuch hota hai."),
    ),
    TrimesterTip(
      emoji: '🍲',
      title: LocalizedText(
          en: 'Take the cooking off her plate',
          hi: 'Cooking uske zimme se hata dein'),
      body: LocalizedText(
          en: "Smells and food aversions can make cooking unbearable for her right now. Step in — cook, order, or keep strong smells out of the kitchen — and keep simple snacks and water within her reach all day.",
          hi: "Abhi smells aur food aversions ki wajah se cooking uske liye mushkil ho sakti hai. Aage aayein — khaana banayein, order karein, ya tez smells kitchen se door rakhein — aur din bhar saade snacks aur paani uske paas rakhein."),
    ),
  ],
  // Second trimester — the gentlest stretch.
  2: [
    TrimesterTip(
      emoji: '🔍',
      title: LocalizedText(
          en: 'Be there for her anomaly scan',
          hi: 'Uske anomaly scan mein saath rahein'),
      body: LocalizedText(
          en: "Around weeks 18–22, this detailed scan checks your baby's heart, brain, spine and organs. Go with her if you can — your presence steadies the nerves these visits can stir. Write the questions down together beforehand. Most findings are reassuring.",
          hi: 'Lagbhag 18–22 hafte mein yeh detailed scan baby ke dil, dimaag, reedh aur organs check karta hai. Ho sake to uske saath jaayein — aapki maujoodgi in visits ki ghabraahat sambhaal deti hai. Sawaal pehle se saath likh lein. Zyaadatar findings rahat dene wale hote hain.'),
    ),
    TrimesterTip(
      emoji: '🛌',
      title: LocalizedText(
          en: 'Help her sleep on her side',
          hi: 'Use karwat par sone mein madad karein'),
      body: LocalizedText(
          en: "As her bump grows, sleeping on her side — the left is ideal — helps blood and nutrients reach the baby. Slip a pillow between her knees or under the bump. If she wakes up on her back, gently help her settle back onto her side.",
          hi: 'Jaise-jaise bump badhta hai, karwat (khaaskar baayein) par sona blood aur nutrients ko baby tak pahunchne mein madad karta hai. Ghutno ke beech ya bump ke neeche takiya laga dein. Agar woh peeth ke bal jaag jaaye to pyaar se use wapas karwat par le aayein.'),
    ),
    TrimesterTip(
      emoji: '🥗',
      title: LocalizedText(
          en: 'Keep iron & calcium easy for her',
          hi: 'Iron aur calcium use aasaani se dein'),
      body: LocalizedText(
          en: "Her body is building the baby's bones and blood right now. Keep iron (leafy greens, dal, jaggery) and calcium (milk, curd, paneer) within easy reach, and pair iron-rich foods with a little vitamin C. Remind her gently about any supplements the doctor prescribed.",
          hi: 'Abhi uska shareer baby ki haddiyaan aur khoon bana raha hai. Iron (hari sabziyaan, dal, gud) aur calcium (doodh, dahi, paneer) aaram se haath mein rakhein, aur iron wale khaane ke saath thoda vitamin C dein. Doctor ke diye supplements ke liye use pyaar se yaad dilaate rahein.'),
    ),
  ],
  // Third trimester — getting ready, getting heavier.
  3: [
    TrimesterTip(
      emoji: '🎒',
      title: LocalizedText(
          en: 'Get the hospital bag ready',
          hi: 'Hospital bag taiyar rakhein'),
      body: LocalizedText(
          en: "Baby could come a little early, so it pays to be ready. Pack the hospital bag together, know the route to the hospital, keep the car fuelled, and save the important numbers where you can find them fast.",
          hi: "Baby thoda jaldi aa sakta hai, isliye taiyar rehna achha hai. Hospital bag saath pack karein, hospital ka raasta jaanein, gaadi mein fuel rakhein, aur zaroori numbers aise jagah save karein jahan jaldi mil jaayein."),
    ),
    TrimesterTip(
      emoji: '😴',
      title: LocalizedText(
          en: 'Help her rest through the discomfort',
          hi: 'Takleef mein use aaram dilayein'),
      body: LocalizedText(
          en: "Heartburn, a heavy bump and broken sleep make these weeks tiring. Pile up the pillows, take the late-night and early-morning chores, and protect her naps without making her feel guilty about them.",
          hi: "Heartburn, bhaari bump aur tooti-phooti neend in hafton ko thakaane wala bana dete hain. Takiye lagayein, raat-deri aur subah-jaldi ke kaam khud sambhalein, aur uski neend ki raksha karein bina use guilty feel karaaye."),
    ),
    TrimesterTip(
      emoji: '📞',
      title: LocalizedText(
          en: 'Learn the signs of labour',
          hi: 'Labour ke sanket seekhein'),
      body: LocalizedText(
          en: "Know the difference between real contractions and practice (Braxton-Hicks) ones, what 'waters breaking' looks like, and when the hospital wants a call. Keep your phone on and charged — being reachable is half the job.",
          hi: "Asli contractions aur practice (Braxton-Hicks) ke beech farak jaanein, 'paani toot-na' kaisa hota hai, aur hospital ko kab call karna hai. Apna phone on aur charged rakhein — reachable rehna aadha kaam hai."),
    ),
  ],
};

// Father "don't miss" body — points to what's actually on HIS home (daily read,
// a story to read aloud, a journal prompt — NOT Garbh Sanskar).
const LocalizedText _fDailyBridgeBody = LocalizedText(
    en: 'Your daily read, a story to read aloud and a journal prompt are waiting for you on Home.',
    hi: 'Aapka daily read, baby ko sunane ke liye ek kahaani, aur ek journal prompt aapke Home par taiyaar hain.');

const List<_Article> _babyArticleFather = [
  _Article(
      LocalizedText(en: "You're halfway there! 🎉", hi: 'Aap aadhe raaste par hain! 🎉'),
      LocalizedText(
          en: "You've reached the middle of the journey together! Baby is growing quickly now, her bump is showing, and any day now she might feel baby move for the very first time.",
          hi: 'Aap apne safar ke aadhe raaste par pahunch gaye hain! Baby ab tezi se badh raha hai, uska bump dikhne laga hai, aur kisi bhi din woh baby ko pehli baar mehsoos kar sakti hai.')),
  _Article(
      LocalizedText(en: 'How big is baby?', hi: 'Baby kitna bada hai?'),
      LocalizedText(
          en: "Baby is about the size of a banana now — roughly 25 cm from head to heel and around 300 g. From this week, length is measured head-to-heel instead of head-to-bottom.",
          hi: 'Baby ab lagbhag ek kele jitna hai — sir se edi tak takreeban 25 cm aur ~300 g. Is hafte se lambai sir-se-edi naapi jaati hai.')),
  _Article(
      LocalizedText(en: "She'll feel baby move", hi: 'Woh baby ko mehsoos karegi'),
      LocalizedText(
          en: "Baby's first little flutters — called \"quickening\" — often start around now. They feel like bubbles or a gentle tap, and over the next few weeks they'll grow into clear kicks. With a first baby she might feel them a little later — that's completely normal.",
          hi: 'Baby ki pehli halki harkatein — "quickening" — aksar is samay shuru hoti hain. Yeh bulbule ya halke tap jaisi lagti hain, aur agle kuch hafton mein saaf kicks ban jaayengi. Pehle baby mein woh thodi der se mehsoos kar sakti hai — yeh bilkul normal hai.')),
  _Article(
      LocalizedText(en: 'Baby can hear you both now', hi: 'Baby ab aap dono ko sun sakta hai'),
      LocalizedText(
          en: "The tiny bones in baby's ears are in place, so baby can hear her voice, yours, the heartbeat and the world around. When you talk, hum or sing, it helps you bond — and baby will often recognise a favourite tune after birth.",
          hi: 'Baby ke kaano ki nanhi haddiyan ban gayi hain, isliye baby uski awaaz, aapki awaaz, dhadkan aur aas-paas ki duniya sun sakta hai. Jab aap baat karte, gungunaate ya gaate hain, to bonding hoti hai — aur janm ke baad baby aksar pasandeeda dhun pehchaan leta hai.')),
  _Article(
      LocalizedText(en: "Baby's tasting her meals", hi: 'Baby uske khaane ka swaad leta hai'),
      LocalizedText(
          en: "Baby swallows a little amniotic fluid through the day, and new taste buds pick up the flavours of whatever she eats. A varied, balanced diet now might even shape what baby loves to eat later!",
          hi: 'Baby din bhar thoda amniotic fluid nigalta hai, aur uski nayi swaad-kaliyan uske khaane ke flavours mehsoos karti hain. Abhi variety wali santulit diet aage baby ke swaad ko bhi bana sakti hai!')),
  _Article(
      LocalizedText(en: "Baby's skin, hair and vernix", hi: 'Baby ki tvacha, baal aur vernix'),
      LocalizedText(
          en: "A soft creamy coating called vernix and a layer of fine hair (lanugo) are protecting baby's delicate skin. Underneath, baby is building up the fat that will keep them warm and cosy after birth.",
          hi: 'Vernix naam ki narm creamy parat aur mahin baal (lanugo) baby ki naazuk tvacha ko bacha rahe hain. Iske neeche baby woh fat bana raha hai jo janm ke baad use garm aur aaramdeh rakhega.')),
  _Article(
      LocalizedText(en: 'Baby sleeps and wakes', hi: 'Baby sota aur jaagta hai'),
      LocalizedText(
          en: "Baby is settling into their own sleep-and-wake cycles, and is often most active just when she lies down to rest! Noticing those patterns is the start of getting to know your little one.",
          hi: 'Baby apne sone-jaagne ke cycle mein aa raha hai, aur aksar tab sabse zyada active hota hai jab woh aaram karne letti hai! Uske patterns pehchaanna apne nanhe ko jaan-ne ki shuruaat hai.')),
];

const List<_Fact> _babyScienceFather = [
  _Fact(
      '🧠',
      Color(0xFFF2E9FB),
      LocalizedText(en: 'A busy little brain', hi: 'Ek vyast nanha dimaag'),
      LocalizedText(
          en: "Your baby is forming millions of new nerve connections every single day — that little brain is working at an astonishing pace!",
          hi: 'Aapka baby har din laakhon naye nerve connections bana raha hai — woh nanha dimaag gajab raftaar se kaam kar raha hai!')),
  _Fact(
      '🤏',
      Color(0xFFFCE3E6),
      LocalizedText(en: 'A tiny grip', hi: 'Ek nanhi pakad'),
      LocalizedText(
          en: "Baby can curl those little fingers and sometimes grabs the umbilical cord — practising for your very first cuddles.",
          hi: 'Baby apni nanhi ungliyan mod sakta hai aur kabhi gard-naal pakad leta hai — aapki pehli cuddles ki practice kar raha hai.')),
  _Fact(
      '🫧',
      Color(0xFFE6F0FA),
      LocalizedText(en: 'Baby gets hiccups!', hi: 'Baby ko hichki aati hai!'),
      LocalizedText(
          en: "Sometimes she'll feel tiny rhythmic taps — that's just baby having hiccups, and it's completely normal.",
          hi: 'Kabhi woh chhoti taal-baddh thaap mehsoos karegi — yeh bas baby ki hichki hai, aur bilkul normal hai.')),
  _Fact(
      '🦶',
      Color(0xFFFDF0C4),
      LocalizedText(en: "Baby's own prints", hi: 'Baby ke apne nishaan'),
      LocalizedText(
          en: "Baby's very own fingerprints — and footprints — are forming right now, patterns that will be theirs alone for life.",
          hi: 'Baby ke apne fingerprints — aur footprints — abhi ban rahe hain, jo zindagi bhar sirf uske honge.')),
  _Fact(
      '💗',
      Color(0xFFEAF1EA),
      LocalizedText(en: 'A strong heartbeat', hi: 'Ek mazboot dhadkan'),
      LocalizedText(
          en: "Baby's heart is pumping hard, moving several litres of blood around that tiny body every single day.",
          hi: 'Baby ka dil zor se pump kar raha hai, har din kai litre khoon uske nanhe sharir mein ghumata hai.')),
  _Fact(
      '🌗',
      Color(0xFFEDEAF6),
      LocalizedText(en: 'Baby senses light', hi: 'Baby roshni mehsoos karta hai'),
      LocalizedText(
          en: 'Shine a soft light on her bump and baby might turn towards it — those eyes are getting ready to see you both.',
          hi: 'Uske bump par halki roshni daalein to baby uski taraf mud sakta hai — woh aankhein aap dono ko dekhne ko taiyar ho rahi hain.')),
];

const List<_Article> _motherArticleFather = [
  _Article(
      LocalizedText(en: 'How she might be feeling', hi: 'Woh kaisa mehsoos kar sakti hai'),
      LocalizedText(
          en: "The second trimester is often the gentlest stretch of pregnancy — the early nausea has usually eased, her energy is back, and her bump is becoming a lovely, visible reminder of the little one growing inside. Emotionally, though, it can still be a rollercoaster: moments of pure joy, then a wave of worry or tears from nowhere. That's completely normal. Her hormones are working hard, and feeling everything a little more deeply is simply part of it.",
          hi: "Doosra trimester aksar pregnancy ka sabse aaramdeh hissa hota hai — shuruaati matli kam ho jaati hai, uski energy lautti hai, aur uska bump andar pal rahe nanhe se jeev ki pyaari nishaani ban jaata hai. Lekin emotionally yeh abhi bhi ek rollercoaster ho sakta hai: kabhi khushi ke pal, to kabhi bina baat ke chinta ya aansoo. Yeh bilkul normal hai. Uske hormones mehnat kar rahe hain, aur har cheez ko thoda gehrayi se mehsoos karna iska hissa hai.")),
  _Article(
      LocalizedText(en: 'Her changing body', hi: 'Uska badalta shareer'),
      LocalizedText(
          en: "Around now her womb has risen to about her belly button, and many mothers notice their bump 'pop' this month. A few new aches can come with it — a stretching feeling low in the belly, a little backache, or the odd dizzy moment. None of it means something is wrong; her body is simply making room. Moving gently, standing up slowly, and resting all help — and so does your hand to lean on.",
          hi: "Is samay tak uski kokh lagbhag naabhi tak aa jaati hai, aur kai maaein is mahine apna bump 'pop' hote dekhti hain. Iske saath kuch nayi takleefein aa sakti hain — pet ke nichle hisse mein khinchaav, halka kamar dard, ya kabhi chakkar. In mein se kuch bhi galat nahi hai; uska shareer bas jagah bana raha hai. Halki harkat, dheere uthna, aur aaram — sab madad karte hain, aur aapka sahara bhi.")),
  _Article(
      LocalizedText(en: 'The first flutters', hi: 'Pehli halki harkatein'),
      LocalizedText(
          en: "Week 20 is famous for one magical milestone — the first movements, often called 'quickening'. They can feel like bubbles, a gentle tap, or a tiny flutter, and are easy to miss at first. Over the coming weeks they grow into unmistakable kicks. If she hasn't felt anything yet, there's no need to worry — a first pregnancy or the position of the placenta can both delay it, and it will come.",
          hi: "Hafta 20 ek jaadui padaav ke liye mashhoor hai — pehli harkatein, jise aksar 'quickening' kehte hain. Yeh bulbule, halke tap, ya chhoti si phurphuri jaisi lag sakti hain, aur pehle inhe pakadna mushkil hota hai. Aane wale hafton mein yeh saaf kicks ban jaati hain. Agar abhi tak use kuch mehsoos nahi hua to chinta ki baat nahi — pehli pregnancy ya placenta ki position dono isse thoda der kar sakti hain, aur yeh zaroor aayegi.")),
  _Article(
      LocalizedText(en: 'How to be there for her', hi: 'Uske liye kaise saath dein'),
      LocalizedText(
          en: "This is a beautiful time to help her slow down and connect — a few quiet minutes with a hand on the bump, a short walk together, a proper night's sleep. Ask how she's feeling and really listen. Looking after her calm is one of the very best things you can do for your baby right now.",
          hi: 'Yeh use dheere hone aur judne mein madad karne ka khoobsurat samay hai — bump par haath rakhe kuch shaant pal, saath mein ek chhoti si sair, ya bharpoor neend. Poochein woh kaisa mehsoos kar rahi hai aur dhyaan se sunein. Uske sukoon ka khayal rakhna abhi aap apne baby ke liye jo sabse achhi cheezein kar sakte hain unmein se ek hai.')),
];

const List<_MotherTopic> _motherTopicsFather = [
  _MotherTopic(
      '🌀',
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'Levels are steadier now — she may have more energy.',
          hi: 'Ab levels sthir hain — use zyada urja ho sakti hai.'),
      LocalizedText(
          en: "After the ups and downs of the first trimester, her hormones settle into a steadier rhythm. Many women feel a welcome lift in energy and mood — the 'pregnancy glow' often shows up around now.",
          hi: 'Pehli trimester ke utaar-chadhaav ke baad uske hormones sthir ho jaate hain. Kai mahilaon ko urja aur mood mein sudhaar mehsoos hota hai — "pregnancy glow" aksar abhi dikhta hai.')),
  _MotherTopic(
      '🤰',
      LocalizedText(en: 'Her bump', hi: 'Uska bump'),
      LocalizedText(
          en: 'The top of her uterus reaches her belly button.',
          hi: 'Uske uterus ka upri hissa naabhi tak pahunchta hai.'),
      LocalizedText(
          en: "Her uterus has grown to about the level of her navel, so the bump is clearly showing now. Roomier clothes and a supportive bra help, and sleeping on her side becomes the comfiest position from here on — keep a pillow handy for between the knees.",
          hi: 'Uska uterus lagbhag naabhi tak badh gaya hai, isliye bump ab saaf dikhta hai. Khule kapde aur supportive bra aaram dete hain, aur ab karwat par sona sabse aaramdayak hota hai — ghutno ke beech takiya paas rakhein.')),
  _MotherTopic(
      '🦋',
      LocalizedText(en: 'First movements', hi: 'Pehli harkatein'),
      LocalizedText(
          en: 'She may feel the first gentle flutters (quickening).',
          hi: 'Woh pehli halki harkatein (quickening) mehsoos kar sakti hai.'),
      LocalizedText(
          en: "Those first movements — called 'quickening' — often arrive around week 20. They can feel like bubbles, a light tap or butterflies, and will be irregular at first. Over the coming weeks they grow stronger and more regular. First-time mums sometimes feel them a little later — perfectly normal.",
          hi: 'Pehli harkatein — "quickening" — aksar hafta 20 ke aas-paas aati hain. Yeh bulbule, halki thaap ya titli jaisi lag sakti hain, aur pehle anyamit hoti hain. Aage chal kar yeh mazboot aur niyamit ho jaati hain.')),
  _MotherTopic(
      '✨',
      LocalizedText(en: 'Skin & body', hi: 'Tvacha & sharir'),
      LocalizedText(
          en: 'More blood flow brings a warm glow and fuller hair.',
          hi: 'Zyada blood flow se glow aur ghane baal.'),
      LocalizedText(
          en: 'The extra blood her body is making can give her skin a warm glow and her hair a fuller look. Some women notice a dark line down the belly (linea nigra) or slight skin changes — these are normal and usually fade after birth.',
          hi: 'Uska sharir jo zyada khoon bana raha hai usse tvacha mein glow aur baal ghane lagte hain. Kuch mahilaon ko pet par gehri rekha (linea nigra) dikhti hai — yeh normal hai aur janm ke baad aksar mit jaati hai.')),
  _MotherTopic(
      '💗',
      LocalizedText(en: 'Heart & breath', hi: 'Dil & saans'),
      LocalizedText(
          en: 'Her heart works harder — she may feel breathless.',
          hi: 'Uska dil zyada kaam karta hai — saans phool sakti hai.'),
      LocalizedText(
          en: 'Her heart is now pumping much more blood than usual, so she may feel a little breathless on the stairs or notice her heart racing at times. Let her move at her own pace, rest when she needs to, and keep water close by.',
          hi: 'Uska dil ab pehle se kahin zyada khoon pump kar raha hai, isliye seedhi chadhte hue saans phool sakti hai ya dil tez dhadak sakta hai. Use apni raftaar se chalne dein, zaroorat par aaram, aur paani paas rakhein.')),
  _MotherTopic(
      '🤕',
      LocalizedText(en: 'Aches & twinges', hi: 'Dard & khinchaav'),
      LocalizedText(
          en: 'Round-ligament twinges as her bump stretches.',
          hi: 'Bump khinchne se round-ligament khinchaav.'),
      LocalizedText(
          en: "She may feel occasional sharp twinges low on the sides of the bump — round-ligament pain — as the ligaments supporting her growing uterus stretch. It's usually brief and harmless; moving slowly helps. Anything severe or persistent is worth a mention to her doctor.",
          hi: 'Bump ke nichle hisson mein kabhi-kabhi tez khinchaav mehsoos ho sakta hai — round-ligament pain — jab badhte uterus ko sambhalne wale ligaments khinchte hain. Yeh aksar thodi der ka aur harmless hota hai; dheere position badalna madad karta hai. Kuch tez ya lagataar ho to doctor ko batayein.')),
];

// Father versions of the two tint cards on the mother read (self-care/reassurance).
const LocalizedText _fHelpTitle =
    LocalizedText(en: 'How to help', hi: 'Kaise madad karein');
const LocalizedText _fHelpBody = LocalizedText(
    en: "Run her a bath, take a chore off her plate, and make sure she's resting on her side. Small, specific help lands bigger than grand gestures right now.",
    hi: 'Uske liye bath chalayein, koi ek kaam apne zimme lein, aur dhyaan rakhein ki woh karwat par aaram kare. Abhi chhoti, theek madad badi baaton se zyada maayne rakhti hai.');
const LocalizedText _fReassureBody = LocalizedText(
    en: "These ups and downs are normal — your steady, calm presence is exactly what she needs most this week.",
    hi: 'Yeh utaar-chadhaav normal hain — aapka sthir, shaant saath hi is hafte use sabse zyada chahiye.');

// ===========================================================================
//  GENERIC (week-agnostic) father DEEP READS — used on every father week EXCEPT
//  week 20 (which keeps its richer, week-specific father read). Everything here
//  is always-true and in 3rd-person partner voice, so the father never reads the
//  mother's voice (baby-to-mum / "you" = mum) on any week. See [_BabyDetailScreen]
//  / [_combinedBody].
// ===========================================================================
const List<_Article> _babyArticleGen = [
  _Article(
      LocalizedText(
          en: 'Growing a little more every day',
          hi: 'Har din thoda aur badhta hua'),
      LocalizedText(
          en: "Week by week your baby is forming and strengthening — organs, senses, muscles and brain, each on its own remarkable schedule. The note at the top of this week tells you what's developing right now.",
          hi: "Hafte-dar-hafte aapka baby ban aur mazboot ho raha hai — organs, senses, muscles aur brain, har ek apne khaas schedule par. Is hafte ke upar ka note batata hai ki abhi kya develop ho raha hai.")),
  _Article(
      LocalizedText(en: 'Your voice matters', hi: 'Aapki awaaz maayne rakhti hai'),
      LocalizedText(
          en: "From around the middle of pregnancy your baby can hear, and your voice slowly becomes familiar. Talking, humming or singing to the bump is a simple, lovely way to start bonding long before birth.",
          hi: "Pregnancy ke lagbhag beech se aapka baby sun sakta hai, aur aapki awaaz dheere-dheere jaani-pehchaani ban jaati hai. Bump se baat karna, gungunaana ya gaana janm se bahut pehle bonding shuru karne ka saral, pyaara tareeka hai.")),
  _Article(
      LocalizedText(
          en: 'Every baby is on their own clock',
          hi: 'Har baby apne samay par'),
      LocalizedText(
          en: "Sizes and milestones are averages, not rules. Whether something happens a little earlier or later, it's almost always perfectly normal — and the scans are there to reassure you both along the way.",
          hi: "Size aur milestones average hain, niyam nahi. Kuch thoda jaldi ya der se ho, yeh lagbhag hamesha bilkul normal hota hai — aur scans aap dono ko raaste mein bharosa dene ke liye hain.")),
  _Article(
      LocalizedText(en: "You're part of this too", hi: 'Aap bhi iska hissa hain'),
      LocalizedText(
          en: "Your baby will come to know your voice, your touch through the bump and the calm you bring. Being present now — for her and for your little one — is the start of a bond that lasts a lifetime.",
          hi: "Aapka baby aapki awaaz, bump ke zariye aapka sparsh aur aapka laaya sukoon pehchaanne lagega. Abhi maujood rehna — uske aur aapke nanhe ke liye — zindagi bhar chalne wale bond ki shuruaat hai.")),
];

const List<_Article> _motherArticleGen = [
  _Article(
      LocalizedText(
          en: 'How she might be feeling',
          hi: 'Woh kaisa mehsoos kar sakti hai'),
      LocalizedText(
          en: "Pregnancy moves through very different stages, and how she feels shifts with them — energy, appetite, mood and sleep can all change from week to week. Whatever this week brings, her hormones are working hard, and feeling everything a little more deeply is simply part of it.",
          hi: "Pregnancy bahut alag-alag stages se guzarti hai, aur uske saath uska mehsoos karna badalta hai — energy, bhookh, mood aur neend sab hafte-dar-hafte badal sakte hain. Yeh hafta jo bhi laaye, uske hormones mehnat kar rahe hain, aur har cheez ko thoda gehrayi se mehsoos karna iska hissa hai.")),
  _Article(
      LocalizedText(en: 'Her changing body', hi: 'Uska badalta shareer'),
      LocalizedText(
          en: "Her body is doing extraordinary work, and that brings visible changes and the odd ache along the way. Most are completely normal and pass on their own — but anything sharp, severe or that won't settle is always worth a word with her doctor.",
          hi: "Uska shareer asaadharan kaam kar raha hai, aur uske saath dikhne wale badlaav aur kabhi-kabhi takleef aati hai. Zyadatar bilkul normal hain aur khud chale jaate hain — lekin kuch tez, gambhir ya jo theek na ho, use hamesha doctor se kehna chahiye.")),
  _Article(
      LocalizedText(en: 'How to be there for her', hi: 'Uske liye kaise saath dein'),
      LocalizedText(
          en: "The basics matter most: ask how she's really feeling and listen, take a chore off her plate, help her rest, and turn up at the appointments. Looking after her calm is one of the very best things you can do for your baby right now.",
          hi: "Buniyaadi cheezein sabse zyada maayne rakhti hain: poochein woh sach mein kaisa mehsoos kar rahi hai aur sunein, koi ek kaam apne zimme lein, use aaram dilayein, aur appointments mein pahunchein. Uske sukoon ka khayal rakhna abhi aap apne baby ke liye jo sabse achhi cheezein kar sakte hain unmein se ek hai.")),
];

const List<_MotherTopic> _motherTopicsGen = [
  _MotherTopic(
      '🌀',
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'They shape a lot of how she feels.',
          hi: 'Yeh uske mehsoos karne ko kaafi banate hain.'),
      LocalizedText(
          en: "Pregnancy hormones drive a lot of how she feels — energy, mood and appetite can all swing, sometimes within a single day. None of it is her 'being difficult'; it's her body doing its work.",
          hi: "Pregnancy hormones uske mehsoos karne ko kaafi chalate hain — energy, mood aur bhookh sab badal sakte hain, kabhi ek hi din mein. Yeh uska 'mushkil karna' nahi hai; yeh uska shareer apna kaam kar raha hai.")),
  _MotherTopic(
      '😴',
      LocalizedText(en: 'Rest & sleep', hi: 'Aaram & neend'),
      LocalizedText(
          en: 'Good sleep gets harder as time goes on.',
          hi: 'Samay ke saath achhi neend mushkil hoti hai.'),
      LocalizedText(
          en: "Comfortable sleep gets harder as pregnancy goes on. Help her wind down in the evening, take the late-night and early-morning jobs, and protect her naps without making her feel guilty.",
          hi: "Pregnancy aage badhne ke saath aaramdayak neend mushkil hoti jaati hai. Shaam ko use relax karne mein madad karein, raat-deri aur subah-jaldi ke kaam khud lein, aur uski neend ki raksha karein bina use guilty banaaye.")),
  _MotherTopic(
      '💗',
      LocalizedText(en: 'Her wellbeing', hi: 'Uski sehat'),
      LocalizedText(
          en: 'Small steady habits help most.',
          hi: 'Chhoti sthir aadtein sabse zyada madad karti hain.'),
      LocalizedText(
          en: "Gentle movement, plenty of water, decent food and a calm home all help her feel better. The single biggest thing you bring, though, is a steady, reassuring presence she can lean on.",
          hi: "Halki harkat, khoob paani, achha khaana aur ek shaant ghar — sab use behtar mehsoos karaate hain. Lekin sabse badi cheez jo aap dete hain woh hai ek sthir, bharosa dene wali maujoodgi jiska woh sahara le sake.")),
];

// ===========================================================================
//  The vertical flow
// ===========================================================================
class WeekFlowView extends StatelessWidget {
  const WeekFlowView(
      {super.key, required this.controller, this.trailing});
  final PregnancyController controller;

  /// Optional widget appended to the bottom of the flow — used for the week-40
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
            // S2 — Weekly video.
            WeekVideoCard(w: w, lang: lang, father: fatherSkin),
            const SizedBox(height: 14),
            // S3 — About baby → Baby Science pop-up. (colour = skin, copy = week-20)
            _SectionBrief(
              icon: Icons.child_care_rounded,
              color: fatherSkin ? _fAccent : AppTheme.primary500,
              // Father FRAMING (title) on all weeks; the brief WORDING is the
              // week-20 re-voiced copy or the mother's per-week content.
              title: fatherSkin ? _fBabyTitle.of(lang) : s.wfBabySection,
              brief: (fatherSkin ? _fBabyBriefFor(w) : w.development.whatImDoing)
                  .of(lang),
              cta: s.wfTapExplore,
              father: fatherSkin,
              onTap: () => _push(context, _BabyDetailScreen(w: w, lang: lang)),
            ),
            const SizedBox(height: 14),
            // S4 — For you, mum (→ "How she's doing" in father preview).
            _SectionBrief(
              icon: Icons.favorite_rounded,
              color: fatherSkin ? _fAccent2 : AppTheme.secondary500,
              title: fatherSkin ? _fMotherTitle.of(lang) : s.wfMotherSection,
              brief: (fatherSkin ? _fMotherBriefFor(w) : w.mom.emotionalState)
                  .of(lang),
              cta: s.wfTapExplore,
              father: fatherSkin,
              onTap: () => _push(context, _MotherDetailScreen(w: w, lang: lang)),
            ),
            const SizedBox(height: 14),
            // S5 — What's next.
            _SectionBrief(
              icon: Icons.event_note_rounded,
              color: fatherSkin ? _fAccent : const Color(0xFF2E9C8E),
              title: s.wfNextSection,
              brief: fatherSkin ? _fNextBrief.of(lang) : s.wfNextBrief,
              cta: s.wfTapExplore,
              father: fatherSkin,
              onTap: () => _push(
                  context, _WhatsNextScreen(controller: controller, lang: lang)),
            ),
            const SizedBox(height: 18),
            // Organic nudge — a clean, warm reminder, woven mid-flow (NOT at the
            // top), that the daily section is waiting — without pulling her out
            // of the week.
            _DailyMomentBridge(controller: controller, father: fatherSkin),
            const SizedBox(height: 18),
            // S6 — This week's videos feed.
            _VideoFeed(lang: lang),
            const SizedBox(height: 18),
            // S6.5 — Trimester tips (3 tips for this trimester; tap → pop-up).
            _TrimesterTips(
                week: controller.selectedWeek, lang: lang, father: fatherSkin),
            const SizedBox(height: 16),
            // S7 — Share with partner. Hidden in father mode: that section is
            // for the mother to share her week WITH the father, so it's pointless
            // when you already are the father.
            if (!fatherSkin) _PartnerSection(w: w, lang: lang),
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
/// weekly flow — a soft reminder that the daily Home has more for her today,
/// without nagging or pulling her away from the week. Tapping returns to Home.
class _DailyMomentBridge extends StatelessWidget {
  const _DailyMomentBridge({required this.controller, this.father = false});
  final PregnancyController controller;
  final bool father; // father body points to his home, not Garbh Sanskar

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      // Go to Today: switch to the Today tab, then pop back to the main scaffold.
      // The Today screen lives in an IndexedStack, so its scroll position is
      // preserved — she lands right where she left off.
      onTap: () {
        AppNav.instance.goToday();
        Navigator.of(context).popUntil((r) => r.isFirst);
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF2E6), Color(0xFFFDE8F0)],
          ),
          borderRadius: BorderRadius.circular(22),
          border:
              Border.all(color: AppTheme.secondary500.withValues(alpha: 0.16)),
        ),
        child: Row(children: [
          // Soft dawn illustration disc.
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFC56B), Color(0xFFFF8FA8)]),
              shape: BoxShape.circle,
            ),
            child: const Text('🌅', style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.wfDailyBridgeKicker,
                      style: GoogleFonts.manrope(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppTheme.secondary600)),
                  const SizedBox(height: 3),
                  Text(s.wfDailyBridgeTitle,
                      style: text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 3),
                  Text(
                      father
                          ? _fDailyBridgeBody.of(controller.language)
                          : s.wfDailyBridgeBody,
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppTheme.neutral700)),
                  const SizedBox(height: 8),
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(s.wfDailyBridgeCta,
                        style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.secondary600)),
                    const Icon(Icons.arrow_forward_rounded,
                        size: 15, color: AppTheme.secondary600),
                  ]),
                ]),
          ),
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

/// Shared bottom overlay for swipeable pop-ups: a "swipe" hint pill (page 0
/// only) above animated page dots. Parked — the weekly pop-ups moved from swipe
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
            style: GoogleFonts.manrope(
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

// The "swipe for more" pill — shows briefly on the first page, then fades out
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
              style: GoogleFonts.manrope(
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
  });
  final IconData icon;
  final Color color;
  final String title;
  final String brief;
  final String cta;
  final VoidCallback onTap;
  final bool father; // Slate re-skin (week-20 Dad preview only)

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
                  // bit bolder (w800), in Slate ink — the serif read poorly.
                  style: father
                      ? GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: _fInk)
                      : GoogleFonts.plusJakartaSans(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: father ? _fMuted : AppTheme.neutral400),
          ]),
          const SizedBox(height: 10),
          Text(brief,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  height: 1.5,
                  color: father ? _fMuted : const Color(0xFF5B5070))),
          const SizedBox(height: 8),
          Text(cta,
              style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color)),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  Trimester tips — 3 gentle tips for this trimester. Tapping a tip opens a
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: father ? _fInk : AppTheme.primary900)),
              Text(subtitle,
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: father ? _fMuted : AppTheme.neutral500)),
            ]),
          ),
        ]),
      ),
      for (final t in tips) _tipCard(context, s, t),
      // Action to-dos, merged in from the (removed) mother "Actions" tab.
      // Hidden in father mode (they're mother-voiced) to keep it focused.
      if (!father) for (final a in _toDos) _todoCard(a),
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: AppTheme.primary900)),
              const SizedBox(height: 4),
              Text(t.detail.of(lang),
                  style: GoogleFonts.manrope(
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
                    Text(t.title.of(lang),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            height: 1.25,
                            color: AppTheme.primary900)),
                    const SizedBox(height: 4),
                    Text(t.body.of(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            height: 1.45,
                            color: const Color(0xFF5B5070))),
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
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 10),
            Text(t.body.of(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
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
            style: GoogleFonts.manrope(
                fontSize: 14, color: father ? _fMuted : AppTheme.neutral500)),
        const SizedBox(height: 2),
        Text(title,
            // Father pop-up headers use the MOTHER's font (plusJakartaSans),
            // bolder, Slate ink — consistent with the weekly headings.
            style: father
                ? GoogleFonts.plusJakartaSans(
                    fontSize: 24, fontWeight: FontWeight.w800, color: _fInk)
                : GoogleFonts.plusJakartaSans(
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
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: headingColor ?? AppTheme.primary900)),
        const SizedBox(height: 6),
        Text(a.body.of(lang),
            style: GoogleFonts.manrope(
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
                style: GoogleFonts.manrope(
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

/// Article sections with image/video placeholders woven between them — a
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
//  S3 — Baby detail (Baby Science carousel + descriptive article)
// ---------------------------------------------------------------------------
// Opens on the descriptive "About your baby" read (page 0), then a swipe hint
// leads into the Baby Science fact cards (pages 1..N).
class _BabyDetailScreen extends StatelessWidget {
  const _BabyDetailScreen({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  // About your baby is now ONE scrolling page (no swipe carousel): the read
  // (text woven with image/video frames), then the Baby Science facts stacked
  // VERTICALLY — tap any one to read it in a small pop-up.
  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    // SKIN/framing (colours + titles) = all weeks; the article/science WORDING
    // = the week-20 re-voiced copy, else the mother's (per-week revoice later).
    final father = _fatherWeek(w.week);
    final fatherSkin = _fatherSkin(w.week);
    // Father: week-20 keeps its richer read; other weeks use the generic father
    // read; the mother keeps hers. Science is generic father-voiced on all weeks.
    final article = father
        ? _babyArticleFather
        : (fatherSkin ? _babyArticleGen : _babyArticle);
    final science = fatherSkin ? _babyScienceFather : _babyScience;
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
          ..._articleWithMedia(context, s, article, lang,
              fatherSkin ? _fAccent : AppTheme.primary500,
              headingColor: fatherSkin ? _fInk : null),
          const SizedBox(height: 2),
          Text(s.wfBabyScience,
              style: fatherSkin
                  ? GoogleFonts.plusJakartaSans(
                      fontSize: 19, fontWeight: FontWeight.w800, color: _fInk)
                  : GoogleFonts.plusJakartaSans(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary600)),
          const SizedBox(height: 12),
          for (final f in science) _scienceRow(context, s, f, lang, fatherSkin),
          const SizedBox(height: 14),
          Text(s.wfDisclaimer,
              style: GoogleFonts.manrope(
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
                    Text(f.title.of(lang),
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: father ? _fInk : AppTheme.primary900)),
                    const SizedBox(height: 3),
                    Text(f.desc.of(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            height: 1.4,
                            color: father ? _fMuted : AppTheme.neutral600)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(s.wfTapToRead,
                          style: GoogleFonts.manrope(
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
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 12),
            Text(f.desc.of(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
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
//  S4 — Mother detail (This week / Health / Eat / To-do)
// ---------------------------------------------------------------------------
// Opens on the detailed "Mother this week" read (page 0), then swipes through
// Health (tappable symptoms), What to eat, and What to do. Prominent headings.
// The "For you, mum" in-depth read (page 0 of the Mother pop-up) — continues
// the section brief into a full page before "Mother this week".
const List<_Article> _motherArticle = [
  _Article(
      LocalizedText(
          en: 'How you might be feeling',
          hi: 'Aap kaisa mehsoos kar sakti hain'),
      LocalizedText(
          en: "The second trimester is often the gentlest stretch of pregnancy — the early nausea has usually eased, your energy is back, and your bump is becoming a lovely, visible reminder of the little one growing inside. Emotionally, though, it can still be a rollercoaster: moments of pure joy, then a wave of worry or tears from nowhere. That is completely normal. Your hormones are working hard, and feeling everything a little more deeply is simply part of it.",
          hi: "Doosra trimester aksar pregnancy ka sabse aaramdeh hissa hota hai — shuruaati matli kam ho jaati hai, energy lautti hai, aur aapka bump andar pal rahe nanhe se jeev ki pyaari nishaani ban jaata hai. Lekin emotionally yeh abhi bhi ek rollercoaster ho sakta hai: kabhi khushi ke pal, to kabhi bina baat ke chinta ya aansoo. Yeh bilkul normal hai. Aapke hormones mehnat kar rahe hain, aur har cheez ko thoda gehrayi se mehsoos karna iska hissa hai.")),
  _Article(
      LocalizedText(en: 'Your changing body', hi: 'Aapka badalta shareer'),
      LocalizedText(
          en: "Around now your womb has risen to about your belly button, and many mothers notice their bump 'pop' this month. A few new aches can come with it — a stretching feeling low in your belly, a little backache, or the odd dizzy moment. None of it means something is wrong; it is simply your body making room. Moving gently, standing up slowly, and resting when you need to all help.",
          hi: "Is samay tak aapki kokh lagbhag naabhi tak aa jaati hai, aur kai maaein is mahine apna bump 'pop' hote dekhti hain. Iske saath kuch nayi takleefein aa sakti hain — pet ke nichle hisse mein khinchaav, halka kamar dard, ya kabhi chakkar. In mein se kuch bhi galat nahi hai; yeh bas aapka shareer jagah bana raha hai. Halki harkat, dheere uthna, aur zaroorat par aaram karna — sab madad karte hain.")),
  _Article(
      LocalizedText(en: 'The first flutters', hi: 'Pehli halki harkatein'),
      LocalizedText(
          en: "Week 20 is famous for one magical milestone — the first movements, often called 'quickening'. They can feel like bubbles, a gentle tap, or a tiny flutter, and they are easy to miss at first. Over the coming weeks they grow into unmistakable kicks. If you haven't felt anything yet, please don't worry — a first pregnancy or the position of your placenta can both delay it, and it will come.",
          hi: "Hafta 20 ek jaadui padaav ke liye mashhoor hai — pehli harkatein, jise aksar 'quickening' kehte hain. Yeh bulbule, halke tap, ya chhoti si phurphuri jaisi lag sakti hain, aur pehle inhe pakadna mushkil hota hai. Aane wale hafton mein yeh saaf kicks ban jaati hain. Agar abhi tak kuch mehsoos nahi hua to chinta na karein — pehli pregnancy ya placenta ki position dono isse thoda der kar sakti hain, aur yeh zaroor aayegi.")),
  _Article(
      LocalizedText(
          en: 'Be kind to yourself', hi: 'Apne aap par meherbaan rahein'),
      LocalizedText(
          en: "This is a beautiful time to slow down and connect — a few quiet minutes with your hand on your bump, a short walk, a proper night's sleep. Share how you're feeling with someone you trust. Looking after your own calm is one of the very best things you can do for your baby right now.",
          hi: "Yeh dheere hone aur judne ka ek khoobsurat samay hai — bump par haath rakhe kuch shaant pal, ek chhoti si sair, ya bharpoor neend. Jo aap mehsoos kar rahi hain woh kisi apne ke saath baatein karein. Apne sukoon ka khayal rakhna abhi aap apne baby ke liye jo sabse achhi cheezein kar sakti hain unmein se ek hai.")),
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
        // Father: no Health tab — that's her symptoms & diet in her own voice,
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

  // The top toggle row — click a section, the whole page is about it (no swipe).
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
                    style: GoogleFonts.plusJakartaSans(
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

  // "You this week" — the "for you, mum" read (woven with image/video frames),
  // then this week's topics + self-care + reassurance. (Title now sits above the
  // toggle row, so this body no longer repeats it.)
  Widget _combinedBody(BuildContext context, S s, AppLanguage lang) {
    final w = widget.w;
    final m = w.mom;
    final father = _fatherWeek(w.week); // copy/wording (week 20)
    final fatherSkin = _fatherSkin(w.week); // colours/skin (all weeks)
    final article = father
        ? _motherArticleFather
        : (fatherSkin ? _motherArticleGen : _motherArticle);
    final topics = father
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
            fatherSkin ? _fHelpBody.of(lang) : m.selfCareTip.of(lang),
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
            style: GoogleFonts.manrope(
                fontSize: 11.5, height: 1.5, color: AppTheme.neutral500)),
      ],
    );
  }

  // Health — Symptoms / Diet on one body, switched by the sub-toggle.
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
                  style: GoogleFonts.plusJakartaSans(
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
        // "Actions" tab removed — its to-dos now live in the Trimester Tips
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
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: father ? _fInk : AppTheme.primary900)),
                    const SizedBox(height: 3),
                    Text(t.short.of(lang),
                        style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            height: 1.45,
                            color: father ? _fMuted : AppTheme.neutral600)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(s.wfTapToRead,
                          style: GoogleFonts.manrope(
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
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 10),
            Text(t.detail.of(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
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
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5, fontWeight: FontWeight.w800, color: c)),
          ]),
          const SizedBox(height: 8),
          Text(body,
              style: GoogleFonts.manrope(
                  fontSize: 14.5,
                  height: 1.55,
                  color: father ? _fMuted : const Color(0xFF5B5070))),
        ]),
      );

  // Toggle: Symptoms — common, normal things to notice now (tap → detail sheet).
  List<Widget> _symptomsContent(S s, AppLanguage lang) {
    final syms = kSymptoms
        .where((x) => !x.urgent && x.commonInTrimester(2))
        .take(7)
        .toList();
    return [
      Text(s.wfHealthIntro,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
              fontSize: 13, height: 1.5, color: AppTheme.neutral600)),
      const SizedBox(height: 14),
      for (final x in syms) _symptomCard(s, x, lang),
    ];
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 2),
              Text(x.why.of(lang),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 12.5, height: 1.4, color: AppTheme.neutral600)),
              const SizedBox(height: 6),
              Row(children: [
                Text(s.wfTapToRead,
                    style: GoogleFonts.manrope(
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
                    style: GoogleFonts.plusJakartaSans(
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
              style: GoogleFonts.manrope(
                  fontSize: 11,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w800,
                  color: warn ? AppTheme.secondary700 : AppTheme.tertiary500)),
          const SizedBox(height: 5),
          Text(body,
              style: GoogleFonts.manrope(
                  fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
        ]),
      );

  Widget _sheetList(String label, List<LocalizedText> items, AppLanguage lang) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: GoogleFonts.manrope(
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
                      style: GoogleFonts.manrope(
                          fontSize: 14,
                          height: 1.45,
                          color: const Color(0xFF5B5070))),
                ),
              ]),
            ),
        ]),
      );

  // Toggle: Diet — Indian superfood of the week + foods to favour / to limit.
  List<Widget> _dietContent(S s, AppLanguage lang) {
    final n = widget.w.nutrition;
    return [
      // Indian superfood of the week — restored into the V2 diet section (it had
      // only survived in the classic layout when the Classic/New toggle was added).
      if (n.superfood != null) ...[
        _superfoodCard(n.superfood!, s, lang),
        const SizedBox(height: 16),
      ],
      Text(n.whyNow.of(lang),
          style: GoogleFonts.manrope(
              fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
      const SizedBox(height: 16),
      Text(s.foodsToFavour,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF4F7A52))),
      const SizedBox(height: 10),
      for (final f in _eatFoods) _foodCard(f, lang, const Color(0xFF4F7A52)),
      const SizedBox(height: 10),
      Text(s.wfAvoid,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.secondary700)),
      const SizedBox(height: 10),
      for (final f in _avoidFoods) _foodCard(f, lang, AppTheme.secondary500),
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              const SizedBox(height: 3),
              Text(f.why.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 13, height: 1.45, color: const Color(0xFF5B5070))),
            ]),
          ),
        ]),
      );

  // "Indian superfood of the week" — a highlighted hero card (food + benefit +
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
                  style: GoogleFonts.manrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.0,
                      color: AppTheme.tertiary600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(sf.food.of(lang),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.tertiary700)),
          const SizedBox(height: 5),
          Text(sf.benefit.of(lang),
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.5, color: const Color(0xFF5B5070))),
          const SizedBox(height: 8),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(Icons.restaurant_menu_rounded,
                size: 15, color: AppTheme.neutral500),
            const SizedBox(width: 6),
            Expanded(
              child: Text(sf.howToConsume.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 12.5, height: 1.45, color: const Color(0xFF6B5F7E))),
            ),
          ]),
        ]),
      );

  // Toggle: Actions — moved into the Trimester Tips section; kept for revert.
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary900)),
              const SizedBox(height: 5),
              Text(t.detail.of(lang),
                  style: GoogleFonts.manrope(
                      fontSize: 14, height: 1.55, color: const Color(0xFF5B5070))),
            ]),
          ),
        ]),
      );

}

// ---------------------------------------------------------------------------
//  S5 — What's next (Scans / Upcoming milestones)
// ---------------------------------------------------------------------------
// Opens on a "what's next" read, then swipes to Upcoming milestones, then
// Scans & appointments. Milestones and scans open a centered detail pop-up.
class _WhatsNextScreen extends StatefulWidget {
  const _WhatsNextScreen(
      {required this.controller, required this.lang, this.father = false});
  final PregnancyController controller;
  final AppLanguage lang;

  /// When true (the father's "What's next"), show Scans & appointments only,
  /// re-voiced for the partner — no milestones, no "for you" body section.
  final bool father;
  @override
  State<_WhatsNextScreen> createState() => _WhatsNextScreenState();
}

class _WhatsNextScreenState extends State<_WhatsNextScreen> {
  // One page, three tabs (no swipe). Scans & appointments first (default).
  int _tab = 0;

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
          child: _tab == 0
              ? _scansList(s, lang, cw)
              : (_tab == 1
                  ? _motherNextList(s, lang, cw)
                  : _milestonesList(s, lang, cw)),
        ),
      ]),
    );
  }

  // The three-way tab row (Scans · For you · Milestones).
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
                    style: GoogleFonts.plusJakartaSans(
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
      child: Row(children: [
        seg(0, Icons.event_note_rounded, s.wfNextTabScans),
        seg(1, Icons.favorite_rounded, s.wfNextTabYou),
        seg(2, Icons.emoji_events_rounded, s.wfNextTabMilestones),
      ]),
    );
  }

  /// The journey-progress card (trimester · weeks to go · % there). Currently
  /// not shown (removed from the Scans page) — kept for revert / reuse.
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
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
          const Spacer(),
          Text(s.wfWeeksToGo(weeksToGo),
              style: GoogleFonts.manrope(
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
            style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppTheme.neutral500)),
      ]),
    );
  }

  // Old overview page — kept for reference after the 3 → 2 merge (its useful
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
            style: GoogleFonts.manrope(
                fontSize: 15, height: 1.6, color: const Color(0xFF5B5070))),
        const SizedBox(height: 18),
        _progressCard(s),
        const SizedBox(height: 18),
        Text(s.wfNextRadar,
            style: GoogleFonts.plusJakartaSans(
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
                    style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        height: 1.45,
                        color: const Color(0xFF5B5070))),
              ),
            ]),
          ),
      ],
    );
  }

  // Tab 3 — Upcoming milestones (current week onward, tappable).
  Widget _milestonesList(S s, AppLanguage lang, int cw) {
    // A focused window — the current week's milestones plus a few weeks ahead.
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
                    style: GoogleFonts.manrope(color: AppTheme.neutral500))),
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
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                ),
                if (current)
                  _tag(s.msThisWeek)
                else
                  Text(s.jrWeekLabel(m.week),
                      style: GoogleFonts.manrope(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary500)),
              ]),
              const SizedBox(height: 3),
              Text(m.short.of(lang),
                  style: GoogleFonts.manrope(
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
            style: GoogleFonts.manrope(
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
                style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary500)),
            const SizedBox(height: 4),
            Text(m.title.of(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primary900)),
            const SizedBox(height: 10),
            Text(m.detail.of(lang),
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
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
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // Tab 1 — Scans & appointments (tappable). The default tab.
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
                    style: GoogleFonts.manrope(color: AppTheme.neutral500))),
          ),
      ],
    );
  }

  // Tab 2 — "What's next for you": a forward look at how she may feel in the
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
            style: GoogleFonts.manrope(
                fontSize: 14, height: 1.55, color: const Color(0xFF5B5070))),
        const SizedBox(height: 16),
        if (cards.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(s.scnUpToDate,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(color: AppTheme.neutral500))),
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
                  style: GoogleFonts.plusJakartaSans(
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
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.5, color: const Color(0xFF5B5070))),
          const SizedBox(height: 8),
          Row(children: [
            Text(s.wfTapToRead,
                style: GoogleFonts.manrope(
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
                      style: GoogleFonts.manrope(
                          fontSize: 11,
                          letterSpacing: 0.4,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.secondary600)),
                  const SizedBox(height: 4),
                  Text(body,
                      style: GoogleFonts.manrope(
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
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.secondary600)),
                  const SizedBox(height: 4),
                  Text(s.wfYouThisWeek,
                      style: GoogleFonts.plusJakartaSans(
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
                          style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
  }

  // ---- Father (week-20) Scans & appointments — re-voiced for the partner -----
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
            style: GoogleFonts.manrope(fontSize: 15, height: 1.6, color: _fInk)),
        const SizedBox(height: 16),
        if (scans.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
                child: Text(s.scnUpToDate,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(color: _fMuted))),
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 16, fontWeight: FontWeight.w800, color: _fInk)),
            ),
            Text(f.when.of(lang),
                style: GoogleFonts.manrope(fontSize: 11.5, color: _fMuted)),
          ]),
          const SizedBox(height: 8),
          Text(f.body.of(lang),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  GoogleFonts.manrope(fontSize: 13.5, height: 1.5, color: _fInk)),
          const SizedBox(height: 8),
          Row(children: [
            Text(s.wfTapToRead,
                style: GoogleFonts.manrope(
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
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: _fInk)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(f.when.of(lang),
                      style: GoogleFonts.manrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _fAccent)),
                  const SizedBox(height: 14),
                  Text(f.body.of(lang),
                      style: GoogleFonts.manrope(
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
                          Text('HOW TO SHOW UP',
                              style: GoogleFonts.manrope(
                                  fontSize: 11,
                                  letterSpacing: 0.4,
                                  fontWeight: FontWeight.w800,
                                  color: _fAccent)),
                          const SizedBox(height: 4),
                          Text(f.help.of(lang),
                              style: GoogleFonts.manrope(
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
                          style: GoogleFonts.manrope(
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ),
            Text(m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
                style: GoogleFonts.manrope(
                    fontSize: 11.5, color: AppTheme.neutral500)),
          ]),
          if (m.sections.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(m.sections.first.body.of(lang),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                    fontSize: 13.5, height: 1.5, color: const Color(0xFF5B5070))),
          ],
          const SizedBox(height: 8),
          Row(children: [
            Text(s.wfTapToRead,
                style: GoogleFonts.manrope(
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
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
                      style: GoogleFonts.manrope(
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
                                style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    letterSpacing: 0.4,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.tertiary500)),
                            const SizedBox(height: 4),
                            Text(sec.body.of(lang),
                                style: GoogleFonts.manrope(
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
                          style: GoogleFonts.manrope(
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
//  S6 — This week's videos (Instagram-style horizontal feed; placeholders)
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
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ),
      ]),
      const SizedBox(height: 12),
      // A horizontal reel/shorts-style feed — uniform 9:16 tiles.
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

  Widget _reel(BuildContext context, _Vid v, S s) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.wkVideoSoon))),
      child: SizedBox(
        width: 141, // ≈ 9:16 against the 250 height
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
                    style: GoogleFonts.plusJakartaSans(
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
                child: const Text('NEW',
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
                    style: GoogleFonts.manrope(
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
}

// ---------------------------------------------------------------------------
//  S7 — Share with partner (richer, segmented WhatsApp summary)
// ---------------------------------------------------------------------------
class _PartnerSection extends StatelessWidget {
  const _PartnerSection({required this.w, required this.lang});
  final WeekContent w;
  final AppLanguage lang;

  String _message(S s) {
    final week = w.week;
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
        '${s.wfPartnerSignoff}\n— ParentVeda 💜';
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
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary900)),
        ]),
        const SizedBox(height: 8),
        Text(s.wfPartnerBlurb,
            style: GoogleFonts.manrope(
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
              style: GoogleFonts.manrope(
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
                style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700, color: Colors.white)),
          ),
        ),
      ]),
    );
  }
}
