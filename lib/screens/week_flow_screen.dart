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
import '../services/pregnancy_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/week_cards/week_overview_card.dart';

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
//  The vertical flow
// ===========================================================================
class WeekFlowView extends StatelessWidget {
  const WeekFlowView({super.key, required this.controller});
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final w = controller.weekData(controller.selectedWeek);
        if (w == null) return const SizedBox.shrink();
        final lang = controller.language;
        final s = S(lang);
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
          children: [
            WeekSizeHero(w: w, lang: lang),
            const SizedBox(height: 18),
            // S2 — Weekly video.
            WeekVideoCard(w: w, lang: lang),
            const SizedBox(height: 14),
            // S3 — About baby → Baby Science pop-up.
            _SectionBrief(
              icon: Icons.child_care_rounded,
              color: AppTheme.primary500,
              title: s.wfBabySection,
              brief: w.development.whatImDoing.of(lang),
              cta: s.wfTapExplore,
              onTap: () => _push(context, _BabyDetailScreen(w: w, lang: lang)),
            ),
            const SizedBox(height: 14),
            // S4 — For you, mum.
            _SectionBrief(
              icon: Icons.favorite_rounded,
              color: AppTheme.secondary500,
              title: s.wfMotherSection,
              brief: w.mom.emotionalState.of(lang),
              cta: s.wfTapExplore,
              onTap: () => _push(context, _MotherDetailScreen(w: w, lang: lang)),
            ),
            const SizedBox(height: 14),
            // S5 — What's next.
            _SectionBrief(
              icon: Icons.event_note_rounded,
              color: const Color(0xFF2E9C8E),
              title: s.wfNextSection,
              brief: s.wfNextBrief,
              cta: s.wfTapExplore,
              onTap: () => _push(
                  context, _WhatsNextScreen(controller: controller, lang: lang)),
            ),
            const SizedBox(height: 18),
            // Organic nudge — a clean, warm reminder, woven mid-flow (NOT at the
            // top), that the daily section is waiting — without pulling her out
            // of the week.
            _DailyMomentBridge(controller: controller),
            const SizedBox(height: 18),
            // S6 — This week's videos feed.
            _VideoFeed(lang: lang),
            const SizedBox(height: 18),
            // S6.5 — Trimester tips (3 tips for this trimester; tap → pop-up).
            _TrimesterTips(week: controller.selectedWeek, lang: lang),
            const SizedBox(height: 16),
            // S7 — Share with partner.
            _PartnerSection(w: w, lang: lang),
          ],
        );
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
  const _DailyMomentBridge({required this.controller});
  final PregnancyController controller;

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
                  Text(s.wfDailyBridgeBody,
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
    BuildContext context, PregnancyController controller, AppLanguage lang) {
  _push(context, _WhatsNextScreen(controller: controller, lang: lang));
}

/// Shared bottom overlay for swipeable pop-ups: a "swipe" hint pill (page 0
/// only) above animated page dots.
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
  });
  final IconData icon;
  final Color color;
  final String title;
  final String brief;
  final String cta;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(22),
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
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
          ]),
          const SizedBox(height: 10),
          Text(brief,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                  fontSize: 13.5,
                  height: 1.5,
                  color: const Color(0xFF5B5070))),
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
  const _TrimesterTips({required this.week, required this.lang});
  final int week;
  final AppLanguage lang;

  static const Color _accent = Color(0xFFD98A2B); // warm amber for "tips"

  int get _tri => week <= 13 ? 1 : (week <= 27 ? 2 : 3);

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final tips =
        (kTrimesterTipsV2[_tri] ?? const <TrimesterTip>[]).take(3).toList();
    if (tips.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(2, 0, 2, 12),
        child: Row(children: [
          const Icon(Icons.tips_and_updates_rounded, size: 26, color: _accent),
          const SizedBox(width: 12),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.wfTipsTitle,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              Text(s.wfTrimesterLabel(_tri),
                  style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.neutral500)),
            ]),
          ),
        ]),
      ),
      for (final t in tips) _tipCard(context, s, t),
      // Action to-dos, merged in from the (removed) mother "Actions" tab — shown
      // here without a separate heading, as part of this week's guidance.
      for (final a in _toDos) _todoCard(a),
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
                color: _accent.withValues(alpha: 0.10),
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
                  color: _accent.withValues(alpha: 0.10),
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
                  color: _accent.withValues(alpha: 0.12),
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
                    backgroundColor: _accent,
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
  const _PopupScaffold({required this.body});
  final Widget body;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.primary500,
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

Widget _popupTitle(String week, String title) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(children: [
        Text(week,
            style: GoogleFonts.manrope(
                fontSize: 14, color: AppTheme.neutral500)),
        const SizedBox(height: 2),
        Text(title,
            style: GoogleFonts.plusJakartaSans(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary600)),
      ]),
    );

// ---------------------------------------------------------------------------
//  Inline media + article helpers (shared by the Baby & Mother reads)
// ---------------------------------------------------------------------------

/// A single article section: bold heading + body paragraph.
Widget _articleSection(_Article a, AppLanguage lang) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.heading.of(lang),
            style: GoogleFonts.plusJakartaSans(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.primary900)),
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
    Color accent) {
  final out = <Widget>[];
  for (var i = 0; i < arts.length; i++) {
    out.add(_articleSection(arts[i], lang));
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
    return _PopupScaffold(
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          Center(child: _popupTitle(s.jrWeekLabel(w.week), s.wfBabySection)),
          const SizedBox(height: 8),
          ..._articleWithMedia(
              context, s, _babyArticle, lang, AppTheme.primary500),
          const SizedBox(height: 2),
          Text(s.wfBabyScience,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primary600)),
          const SizedBox(height: 12),
          for (final f in _babyScience) _scienceRow(context, s, f, lang),
          const SizedBox(height: 14),
          Text(s.wfDisclaimer,
              style: GoogleFonts.manrope(
                  fontSize: 11.5, height: 1.5, color: AppTheme.neutral500)),
        ],
      ),
    );
  }

  // A Baby Science fact as a tappable row → opens a small pop-up with the fact.
  Widget _scienceRow(BuildContext context, S s, _Fact f, AppLanguage lang) =>
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
                            color: AppTheme.primary900)),
                    const SizedBox(height: 3),
                    Text(f.desc.of(lang),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            height: 1.4,
                            color: AppTheme.neutral600)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(s.wfTapToRead,
                          style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary500)),
                      const Icon(Icons.chevron_right_rounded,
                          size: 15, color: AppTheme.primary500),
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
  final PageController _pc = PageController();
  int _page = 0;
  int _tab = 0; // health page toggle: 0 = Symptoms · 1 = Diet · 2 = Actions

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _hop(int delta) => _pc.animateToPage(_page + delta,
      duration: const Duration(milliseconds: 280), curve: Curves.easeOut);

  // Now just TWO pages: (1) "You this week" — the read + this-week topics merged
  // — and (2) a single Health page with a Symptoms / Diet / Actions toggle.
  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final s = S(lang);
    const total = 2;
    return _PopupScaffold(
      body: Stack(children: [
        PageView(
          controller: _pc,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            _combinedPage(context, s, lang),
            _togglePage(context, s, lang),
          ],
        ),
        _carouselArrows(
          onPrev: _page > 0 ? () => _hop(-1) : null,
          onNext: _page < total - 1 ? () => _hop(1) : null,
        ),
        _pageCounter(_page + 1, total),
        _swipeOverlay(page: _page, count: total, hint: s.wfSwipeMore),
      ]),
    );
  }

  // Page 1 — "You this week": the "for you, mum" read (woven with image/video
  // frames), then this week's topics + self-care + reassurance, all on one page.
  Widget _combinedPage(BuildContext context, S s, AppLanguage lang) {
    final w = widget.w;
    final m = w.mom;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        Center(child: _popupTitle(s.jrWeekLabel(w.week), s.wfYouThisWeek)),
        const SizedBox(height: 8),
        ..._articleWithMedia(
            context, s, _motherArticle, lang, AppTheme.secondary500),
        for (final t in _motherTopics) _topicCard(t, lang, s),
        const SizedBox(height: 4),
        _tintCard(s.selfCare, m.selfCareTip.of(lang), const Color(0xFF4F7A52),
            Icons.spa_rounded),
        const SizedBox(height: 12),
        _tintCard(s.reassuranceLabel, m.reassurance.of(lang),
            AppTheme.secondary500, Icons.favorite_rounded),
        const SizedBox(height: 16),
        Text(s.wfDisclaimer,
            style: GoogleFonts.manrope(
                fontSize: 11.5, height: 1.5, color: AppTheme.neutral500)),
      ],
    );
  }

  // Page 2 — Symptoms / Diet / Actions on ONE page, switched by a 3-way toggle.
  Widget _togglePage(BuildContext context, S s, AppLanguage lang) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        Center(child:
            _popupTitle(s.jrWeekLabel(widget.w.week), s.wfHealthThisWeek)),
        const SizedBox(height: 10),
        _toggleBar(s),
        const SizedBox(height: 16),
        if (_tab == 0)
          ..._symptomsContent(s, lang)
        else
          ..._dietContent(s, lang),
      ],
    );
  }

  Widget _toggleBar(S s) {
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
              color: on ? AppTheme.secondary500 : Colors.transparent,
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
  Widget _topicCard(_MotherTopic t, AppLanguage lang, S s) => GestureDetector(
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
                  color: AppTheme.secondary500.withValues(alpha: 0.10),
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
                            color: AppTheme.primary900)),
                    const SizedBox(height: 3),
                    Text(t.short.of(lang),
                        style: GoogleFonts.manrope(
                            fontSize: 13.5,
                            height: 1.45,
                            color: AppTheme.neutral600)),
                    const SizedBox(height: 6),
                    Row(children: [
                      Text(s.wfTapToRead,
                          style: GoogleFonts.manrope(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.secondary500)),
                      const Icon(Icons.chevron_right_rounded,
                          size: 15, color: AppTheme.secondary500),
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

  Widget _tintCard(String title, String body, Color c, IconData icon) =>
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
                  fontSize: 14.5, height: 1.55, color: const Color(0xFF5B5070))),
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
  const _WhatsNextScreen({required this.controller, required this.lang});
  final PregnancyController controller;
  final AppLanguage lang;
  @override
  State<_WhatsNextScreen> createState() => _WhatsNextScreenState();
}

class _WhatsNextScreenState extends State<_WhatsNextScreen> {
  final PageController _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _hop(int delta) => _pc.animateToPage(_page + delta,
      duration: const Duration(milliseconds: 280), curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang;
    final s = S(lang);
    const total = 2;
    return _PopupScaffold(
      body: Stack(children: [
        PageView(
          controller: _pc,
          onPageChanged: (i) => setState(() => _page = i),
          children: [
            // Merged from 3 → 2: milestones first, then scans (with the useful
            // journey-progress context from the old overview folded in).
            _milestones(s, lang),
            _scans(s, lang),
          ],
        ),
        _carouselArrows(
          onPrev: _page > 0 ? () => _hop(-1) : null,
          onNext: _page < total - 1 ? () => _hop(1) : null,
        ),
        _pageCounter(_page + 1, total),
        _swipeOverlay(page: _page, count: total, hint: s.wfSwipeMore),
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

  // Page 1 — Upcoming milestones (current week onward, tappable).
  Widget _milestones(S s, AppLanguage lang) {
    final cw = widget.controller.selectedWeek;
    // A focused window — the current week's milestones plus a few weeks ahead.
    final list = _weekMilestones
        .where((m) => m.week >= cw && m.week <= cw + 6)
        .take(8)
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        Center(child: _popupTitle(s.jrWeekLabel(cw), s.wfMilestonesTitle)),
        const SizedBox(height: 8),
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

  // Page 2 — Scans & appointments (tappable).
  Widget _scans(S s, AppLanguage lang) {
    final cw = widget.controller.selectedWeek;
    final scans = kJourneyMilestones
        .where((m) =>
            m.type == JourneyNodeType.medical &&
            m.anchorWeek >= cw - 6 &&
            m.anchorWeek <= cw + 10)
        .toList()
      ..sort((a, b) => a.anchorWeek.compareTo(b.anchorWeek));
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
      children: [
        Center(child: _popupTitle(s.jrWeekLabel(cw), s.wfScansTitle)),
        const SizedBox(height: 12),
        // Journey-progress card removed from the top per request — this page is
        // now scans & appointments only. (Commented, kept for an easy revert.)
        // _progressCard(s),
        // const SizedBox(height: 18),
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
