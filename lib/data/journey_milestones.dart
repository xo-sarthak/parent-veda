// =============================================================================
//  Journey milestone content (bilingual)
// -----------------------------------------------------------------------------
//  Authored in Dart (type-safe LocalizedText) rather than JSON: this is small,
//  structured, config-like content — unlike the bulk week/daily JSON sets.
//  Educational only; never diagnosis or medical advice.
// =============================================================================

import '../localization/app_language.dart';
import '../models/journey_node.dart';

/// Every milestone node on the Pregnancy Journey trail.
const List<JourneyMilestone> kJourneyMilestones = [
  // ===========================================================================
  //  TYPE 2 · ACHIEVEMENTS (gold) — celebrate progress
  // ===========================================================================
  JourneyMilestone(
    id: 'a_w5',
    type: JourneyNodeType.achievement,
    anchorWeek: 5,
    emoji: '🌟',
    title: LocalizedText(en: 'Pregnancy Confirmed', hi: 'Pregnancy Confirm'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'It\'s really happening. A tiny life has begun its journey with you. 🌟',
          hi: 'Yeh sach mein ho raha hai. Ek nanhi si jaan ne aapke saath apna safar shuru kar diya hai. 🌟',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w6',
    type: JourneyNodeType.achievement,
    anchorWeek: 6,
    emoji: '❤️',
    title: LocalizedText(en: 'First Heartbeat', hi: 'Pehli Dhadkan'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Your baby\'s heart has started to beat — a quiet, steady rhythm just for you. ❤️',
          hi: 'Aapke baby ka dil dhadakne laga hai — ek shaant, sthir dhadkan sirf aapke liye. ❤️',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w12',
    type: JourneyNodeType.achievement,
    anchorWeek: 12,
    emoji: '🎉',
    title: LocalizedText(en: 'First Trimester Complete', hi: 'Pehli Trimester Poori'),
    ctaWeek: 12,
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'You have completed one-third of your pregnancy journey. The most delicate weeks are behind you. 🎉',
          hi: 'Aapne apne safar ka ek-tihaai hissa poora kar liya. Sabse naazuk hafte ab peechhe hain. 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w18',
    type: JourneyNodeType.achievement,
    anchorWeek: 19,
    emoji: '🦋',
    rangeLabel: LocalizedText(en: 'Week 18–20', hi: 'Hafta 18–20'),
    title: LocalizedText(en: 'First Movements Felt', hi: 'Pehli Harkat Mehsoos'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Those first flutters — like tiny butterflies — are your baby saying hello. 🦋',
          hi: 'Woh pehli halki harkatein — jaise nanhi titliyan — aapka baby hello keh raha hai. 🦋',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w20',
    type: JourneyNodeType.achievement,
    anchorWeek: 20,
    emoji: '🎉',
    title: LocalizedText(en: 'Halfway Point', hi: 'Aadha Safar'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Halfway there. Look how far you and your baby have already come together. 🎉',
          hi: 'Aadha safar poora. Dekhiye aap aur aapka baby saath mein kitni door aa chuke hain. 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w24',
    type: JourneyNodeType.achievement,
    anchorWeek: 24,
    emoji: '🎉',
    title: LocalizedText(en: 'Viability Milestone', hi: 'Viability Milestone'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'An important milestone — your baby is growing stronger every single day. 🎉',
          hi: 'Ek zaroori padaav — aapka baby har din aur mazboot ho raha hai. 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w28',
    type: JourneyNodeType.achievement,
    anchorWeek: 28,
    emoji: '🎉',
    title: LocalizedText(en: 'Third Trimester Begins', hi: 'Teesri Trimester Shuru'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'The final chapter begins. Soon you\'ll be holding your little one. 🎉',
          hi: 'Aakhri adhyay shuru. Jald hi aap apne nanhe ko godi mein lengi. 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w37',
    type: JourneyNodeType.achievement,
    anchorWeek: 37,
    emoji: '🎉',
    title: LocalizedText(en: 'Full Term', hi: 'Full Term'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Your baby is now full term — ready to meet the world whenever the time is right. 🎉',
          hi: 'Aapka baby ab full term hai — sahi waqt aane par duniya se milne ke liye taiyaar. 🎉',
        ),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'a_w40',
    type: JourneyNodeType.achievement,
    anchorWeek: 40,
    emoji: '🎉',
    title: LocalizedText(en: 'Due Date', hi: 'Due Date'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(
          en: 'Forty weeks of love, strength and magic. Your little one is almost here. 🎉',
          hi: 'Chaalis hafton ka pyaar, taakat aur jaadu. Aapka nanha bas aane hi waala hai. 🎉',
        ),
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 3 · MEDICAL (purple) — preparation & education (no diagnosis)
  // ===========================================================================
  JourneyMilestone(
    id: 'm_ultrasound',
    type: JourneyNodeType.medical,
    anchorWeek: 7,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 6–8', hi: 'Hafta 6–8'),
    title: LocalizedText(en: 'First Ultrasound', hi: 'Pehla Ultrasound'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'Yeh kyun zaroori hai'),
        LocalizedText(
          en: 'The first scan confirms the pregnancy and usually shows the baby\'s heartbeat and how many weeks along you are.',
          hi: 'Pehla scan pregnancy confirm karta hai aur aksar baby ki dhadkan aur aap kitne hafton ki hain yeh dikhata hai.',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'Aam tor par kab'),
        LocalizedText(en: 'Usually between weeks 6 and 8.', hi: 'Aam tor par hafta 6 se 8 ke beech.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'Taiyaari ke tips'),
        [
          LocalizedText(en: 'A full bladder can help an early scan — ask your clinic.', hi: 'Jaldi wale scan mein bhari bladder madad karti hai — apne clinic se poochein.'),
          LocalizedText(en: 'Wear comfortable, loose clothing.', hi: 'Aaraamdayak, dheele kapde pehnein.'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'Kya poochein'),
        [
          LocalizedText(en: 'How many weeks am I, and what is my due date?', hi: 'Main kitne hafton ki hoon, aur meri due date kya hai?'),
          LocalizedText(en: 'Is everything developing as expected?', hi: 'Kya sab kuch theek se viksit ho raha hai?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_nt',
    type: JourneyNodeType.medical,
    anchorWeek: 12,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 11–13', hi: 'Hafta 11–13'),
    title: LocalizedText(en: 'NT Scan', hi: 'NT Scan'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'Yeh kyun zaroori hai'),
        LocalizedText(
          en: 'A routine screening scan that checks early growth. Often combined with a blood test.',
          hi: 'Ek routine screening scan jo shuruaati growth check karta hai. Aksar blood test ke saath hota hai.',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'Aam tor par kab'),
        LocalizedText(en: 'Usually between weeks 11 and 13.', hi: 'Aam tor par hafta 11 se 13 ke beech.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'Taiyaari ke tips'),
        [
          LocalizedText(en: 'Carry any previous reports with you.', hi: 'Apni purani reports saath le jaayein.'),
          LocalizedText(en: 'Stay relaxed — it is a gentle, routine check.', hi: 'Shaant rahein — yeh ek aaram se hone wala routine check hai.'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'Kya poochein'),
        [
          LocalizedText(en: 'Do you recommend any additional screening?', hi: 'Kya aap koi aur screening salah dete hain?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_anomaly',
    type: JourneyNodeType.medical,
    anchorWeek: 20,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 18–22', hi: 'Hafta 18–22'),
    title: LocalizedText(en: 'Anomaly Scan', hi: 'Anomaly Scan'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'Yeh kyun zaroori hai'),
        LocalizedText(
          en: 'A detailed scan that looks at how your baby\'s organs and body are developing.',
          hi: 'Ek vistrit scan jo dekhta hai ki aapke baby ke ang aur sharir kaise viksit ho rahe hain.',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'Aam tor par kab'),
        LocalizedText(en: 'Usually between weeks 18 and 22.', hi: 'Aam tor par hafta 18 se 22 ke beech.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'Taiyaari ke tips'),
        [
          LocalizedText(en: 'It can take longer than other scans — plan some time.', hi: 'Yeh doosre scans se zyada waqt le sakta hai — thoda samay rakhein.'),
          LocalizedText(en: 'You may be able to learn the baby\'s position.', hi: 'Aapko baby ki position pata chal sakti hai.'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'Kya poochein'),
        [
          LocalizedText(en: 'Is the baby growing well for this stage?', hi: 'Kya baby is stage ke hisaab se theek badh raha hai?'),
          LocalizedText(en: 'Where is the placenta positioned?', hi: 'Placenta ki position kahan hai?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_glucose',
    type: JourneyNodeType.medical,
    anchorWeek: 26,
    emoji: '🩺',
    rangeLabel: LocalizedText(en: 'Week 24–28', hi: 'Hafta 24–28'),
    title: LocalizedText(en: 'Glucose Screening', hi: 'Glucose Screening'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'Yeh kyun zaroori hai'),
        LocalizedText(
          en: 'A simple test that checks how your body is handling sugar during pregnancy.',
          hi: 'Ek aasaan test jo dekhta hai ki pregnancy mein aapka sharir sugar ko kaise sambhaal raha hai.',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'Aam tor par kab'),
        LocalizedText(en: 'Usually between weeks 24 and 28.', hi: 'Aam tor par hafta 24 se 28 ke beech.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Preparation tips', hi: 'Taiyaari ke tips'),
        [
          LocalizedText(en: 'Your clinic may ask you to fast — confirm beforehand.', hi: 'Clinic aapse khaali pet aane ko keh sakti hai — pehle confirm karein.'),
          LocalizedText(en: 'Carry a snack for after the test.', hi: 'Test ke baad ke liye ek snack saath rakhein.'),
        ],
      ),
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'Kya poochein'),
        [
          LocalizedText(en: 'Do I need to prepare anything before the test?', hi: 'Test se pehle mujhe kuch taiyaari karni hai?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_growth',
    type: JourneyNodeType.medical,
    anchorWeek: 32,
    emoji: '🩺',
    title: LocalizedText(en: 'Growth Scan (if advised)', hi: 'Growth Scan (agar salah ho)'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'Yeh kyun zaroori hai'),
        LocalizedText(
          en: 'If advised, this scan checks your baby\'s size, position and growth as the due date nears.',
          hi: 'Agar salah ho, yeh scan due date paas aane par baby ka size, position aur growth check karta hai.',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'Aam tor par kab'),
        LocalizedText(en: 'Around week 32, only if your doctor recommends it.', hi: 'Lagbhag hafta 32, sirf jab doctor salah dein.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'Kya poochein'),
        [
          LocalizedText(en: 'Is the baby in a good position?', hi: 'Kya baby achhi position mein hai?'),
          LocalizedText(en: 'Is growth on track?', hi: 'Kya growth theek chal rahi hai?'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'm_birthplan',
    type: JourneyNodeType.medical,
    anchorWeek: 36,
    emoji: '🩺',
    title: LocalizedText(en: 'Birth Planning Visit', hi: 'Birth Planning Visit'),
    sections: [
      CardSection(
        LocalizedText(en: 'Why this matters', hi: 'Yeh kyun zaroori hai'),
        LocalizedText(
          en: 'A chance to talk through your birth preferences and what to expect in the final weeks.',
          hi: 'Apni birth preferences aur aakhri hafton mein kya expect karein, is par baat karne ka mauka.',
        ),
      ),
      CardSection(
        LocalizedText(en: 'Typical timing', hi: 'Aam tor par kab'),
        LocalizedText(en: 'Around week 36.', hi: 'Lagbhag hafta 36.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Questions to ask', hi: 'Kya poochein'),
        [
          LocalizedText(en: 'When should I head to the hospital?', hi: 'Mujhe hospital kab jaana chahiye?'),
          LocalizedText(en: 'What are my pain-relief options?', hi: 'Dard kam karne ke kya vikalp hain?'),
          LocalizedText(en: 'Who can I call any time of day?', hi: 'Main kisi bhi waqt kise call kar sakti hoon?'),
        ],
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 4 · BABY DEVELOPMENT (blue) — wonder & education
  // ===========================================================================
  JourneyMilestone(
    id: 'b_w8',
    type: JourneyNodeType.babyDev,
    anchorWeek: 8,
    emoji: '👶',
    title: LocalizedText(en: 'Embryo Becomes Fetus', hi: 'Embryo Ban-ta Fetus'),
    ctaWeek: 8,
    sections: [
      CardSection(
        LocalizedText(en: 'What is happening', hi: 'Kya ho raha hai'),
        LocalizedText(en: 'Your baby has graduated from embryo to fetus — tiny limbs and features are forming.', hi: 'Aapka baby embryo se fetus ban gaya hai — nanhe haath-pair aur features ban rahe hain.'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'Iska matlab'),
        LocalizedText(en: 'The basic building blocks are in place; now it\'s all about growing.', hi: 'Buniyaadi cheezein ban chuki hain; ab sirf badhna baaki hai.'),
      ),
      CardSection(
        LocalizedText(en: 'Fun fact', hi: 'Mazedaar baat'),
        LocalizedText(en: 'Your baby is about the size of a raspberry right now.', hi: 'Aapka baby abhi lagbhag ek raspberry jitna bada hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w16',
    type: JourneyNodeType.babyDev,
    anchorWeek: 16,
    emoji: '👶',
    title: LocalizedText(en: 'Baby Can Hear Sounds', hi: 'Baby Awaaz Sun-ta Hai'),
    ctaWeek: 16,
    sections: [
      CardSection(
        LocalizedText(en: 'What is happening', hi: 'Kya ho raha hai'),
        LocalizedText(en: 'Tiny ears are forming and your baby is beginning to pick up sounds.', hi: 'Nanhe kaan ban rahe hain aur aapka baby awaazein sunne lagta hai.'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'Iska matlab'),
        LocalizedText(en: 'This is a beautiful time to talk, sing and play gentle music.', hi: 'Yeh baat karne, gaane aur halka sangeet sunaane ka pyaara samay hai.'),
      ),
      CardSection(
        LocalizedText(en: 'Fun fact', hi: 'Mazedaar baat'),
        LocalizedText(en: 'Your voice is one of the first sounds your baby learns to know.', hi: 'Aapki awaaz un pehli awaazon mein hai jo aapka baby pehchaanna seekhta hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w24',
    type: JourneyNodeType.babyDev,
    anchorWeek: 24,
    emoji: '👶',
    title: LocalizedText(en: 'Responds To Sound', hi: 'Awaaz Par React Kar-ta Hai'),
    ctaWeek: 24,
    sections: [
      CardSection(
        LocalizedText(en: 'What is happening', hi: 'Kya ho raha hai'),
        LocalizedText(en: 'Your baby may now move or kick in response to sounds and your voice.', hi: 'Aapka baby ab awaazon aur aapki awaaz par hil sakta ya kick kar sakta hai.'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'Iska matlab'),
        LocalizedText(en: 'A real two-way bond is forming between you and your little one.', hi: 'Aapke aur aapke nanhe ke beech ek sachcha do-tarfa rishta ban raha hai.'),
      ),
      CardSection(
        LocalizedText(en: 'Fun fact', hi: 'Mazedaar baat'),
        LocalizedText(en: 'Babies often calm to music they heard often in the womb.', hi: 'Bachche aksar us sangeet se shaant ho jaate hain jo unhone garbh mein baar-baar suna ho.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w28',
    type: JourneyNodeType.babyDev,
    anchorWeek: 28,
    emoji: '👶',
    title: LocalizedText(en: 'Eyes Open', hi: 'Aankhein Khulti Hain'),
    ctaWeek: 28,
    sections: [
      CardSection(
        LocalizedText(en: 'What is happening', hi: 'Kya ho raha hai'),
        LocalizedText(en: 'Your baby\'s eyes can now open and close, and sense light.', hi: 'Aapke baby ki aankhein ab khul-band ho sakti hain aur roshni mehsoos kar sakti hain.'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'Iska matlab'),
        LocalizedText(en: 'The senses are maturing, getting ready for the world outside.', hi: 'Indriyan paripakv ho rahi hain, baahar ki duniya ke liye taiyaar.'),
      ),
      CardSection(
        LocalizedText(en: 'Fun fact', hi: 'Mazedaar baat'),
        LocalizedText(en: 'Your baby may turn toward a soft light shone on your belly.', hi: 'Aapke pet par padi halki roshni ki taraf baby mud sakta hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w32',
    type: JourneyNodeType.babyDev,
    anchorWeek: 32,
    emoji: '👶',
    title: LocalizedText(en: 'Practices Breathing', hi: 'Saans Lena Practice Kar-ta Hai'),
    ctaWeek: 32,
    sections: [
      CardSection(
        LocalizedText(en: 'What is happening', hi: 'Kya ho raha hai'),
        LocalizedText(en: 'Your baby practises breathing movements, getting the lungs ready.', hi: 'Aapka baby saans lene ki harkatein practice karta hai, phephdon ko taiyaar karta hai.'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'Iska matlab'),
        LocalizedText(en: 'Important preparation for that very first breath after birth.', hi: 'Janm ke baad pehli saans ke liye zaroori taiyaari.'),
      ),
      CardSection(
        LocalizedText(en: 'Fun fact', hi: 'Mazedaar baat'),
        LocalizedText(en: 'Your baby "breathes" amniotic fluid in and out to practise.', hi: 'Practice ke liye baby amniotic fluid ko andar-baahar "saans" leta hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'b_w36',
    type: JourneyNodeType.babyDev,
    anchorWeek: 36,
    emoji: '👶',
    title: LocalizedText(en: 'Head May Move Downward', hi: 'Sar Neeche Aa Sak-ta Hai'),
    ctaWeek: 36,
    sections: [
      CardSection(
        LocalizedText(en: 'What is happening', hi: 'Kya ho raha hai'),
        LocalizedText(en: 'Many babies begin to settle head-down, getting into position for birth.', hi: 'Kai bachche sar-neeche settle hone lagte hain, janm ke liye position mein aate hain.'),
      ),
      CardSection(
        LocalizedText(en: 'What it means', hi: 'Iska matlab'),
        LocalizedText(en: 'Your baby is preparing for the journey out. Not all babies do this on the same timeline.', hi: 'Aapka baby baahar ke safar ki taiyaari kar raha hai. Har baby yeh ek hi samay par nahi karta.'),
      ),
      CardSection(
        LocalizedText(en: 'Fun fact', hi: 'Mazedaar baat'),
        LocalizedText(en: 'This settling is sometimes called "lightening".', hi: 'Is settle hone ko kabhi-kabhi "lightening" kehte hain.'),
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 5 · MOTHER (pink) — make the mother feel seen
  // ===========================================================================
  JourneyMilestone(
    id: 'mo_w12',
    type: JourneyNodeType.mother,
    anchorWeek: 12,
    emoji: '🌸',
    title: LocalizedText(en: 'Morning Sickness Often Improves', hi: 'Morning Sickness Aksar Behtar Hoti Hai'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many mothers experience', hi: 'Kai maayein kya mehsoos karti hain'),
        LocalizedText(en: 'Around now, nausea often begins to ease and a little energy returns.', hi: 'Is samay ke aas-paas, matli aksar kam hone lagti hai aur thodi energy laut-ti hai.'),
      ),
      CardSection(
        LocalizedText(en: 'Emotional support', hi: 'Bhaavnaatmak sahaara'),
        LocalizedText(en: 'If you\'re still feeling unwell, that\'s okay too — every body is different.', hi: 'Agar abhi bhi tabiyat theek nahi lag rahi, toh yeh bhi theek hai — har sharir alag hota hai.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Self-care', hi: 'Apna khayal'),
        [
          LocalizedText(en: 'Eat small, frequent meals.', hi: 'Thode-thode, baar-baar khaayein.'),
          LocalizedText(en: 'Rest whenever your body asks for it.', hi: 'Jab bhi sharir kahe, aaram karein.'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'mo_w20',
    type: JourneyNodeType.mother,
    anchorWeek: 20,
    emoji: '🌸',
    title: LocalizedText(en: 'Halfway Through Pregnancy', hi: 'Aadha Safar Poora'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many mothers experience', hi: 'Kai maayein kya mehsoos karti hain'),
        LocalizedText(en: 'A growing bump, first kicks, and often a wave of excitement and connection.', hi: 'Badhta bump, pehli kicks, aur aksar utsaah aur judaav ki ek lehar.'),
      ),
      CardSection(
        LocalizedText(en: 'Emotional support', hi: 'Bhaavnaatmak sahaara'),
        LocalizedText(en: 'It\'s natural to feel both joy and nervousness. Both are welcome.', hi: 'Khushi aur ghabraahat dono mehsoos hona swaabhaavik hai. Dono ka swagat hai.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Self-care', hi: 'Apna khayal'),
        [
          LocalizedText(en: 'Take a photo of your bump to remember this week.', hi: 'Is hafte ko yaad rakhne ke liye apne bump ki photo lein.'),
          LocalizedText(en: 'Gentle movement like walking can feel wonderful.', hi: 'Halki harkat jaise chalna bahut achha lag sakta hai.'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'mo_w28',
    type: JourneyNodeType.mother,
    anchorWeek: 28,
    emoji: '🌸',
    title: LocalizedText(en: 'Body Preparing For Third Trimester', hi: 'Sharir Teesri Trimester Ke Liye Taiyaar'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many mothers experience', hi: 'Kai maayein kya mehsoos karti hain'),
        LocalizedText(en: 'A little more tiredness, some backache, and stronger baby movements.', hi: 'Thodi zyada thakaan, kabhi kamar dard, aur baby ki tej harkatein.'),
      ),
      CardSection(
        LocalizedText(en: 'Emotional support', hi: 'Bhaavnaatmak sahaara'),
        LocalizedText(en: 'You\'re carrying a lot — be as gentle with yourself as you would a friend.', hi: 'Aap bahut kuch sambhaal rahi hain — khud par utni hi narmi rakhein jitni ek dost par.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Self-care', hi: 'Apna khayal'),
        [
          LocalizedText(en: 'Support your back with a pillow when resting.', hi: 'Aaram karte waqt kamar ke neeche takiya lagaayein.'),
          LocalizedText(en: 'Stay hydrated through the day.', hi: 'Din bhar paani peete rahein.'),
        ],
      ),
    ],
  ),
  JourneyMilestone(
    id: 'mo_w36',
    type: JourneyNodeType.mother,
    anchorWeek: 36,
    emoji: '🌸',
    title: LocalizedText(en: 'Final Stretch', hi: 'Aakhri Padaav'),
    sections: [
      CardSection(
        LocalizedText(en: 'What many mothers experience', hi: 'Kai maayein kya mehsoos karti hain'),
        LocalizedText(en: 'Anticipation, nesting energy, and sometimes impatience to meet your baby.', hi: 'Intezaar, ghar sajaane ki energy, aur kabhi baby se milne ki betaabi.'),
      ),
      CardSection(
        LocalizedText(en: 'Emotional support', hi: 'Bhaavnaatmak sahaara'),
        LocalizedText(en: 'You are almost there. Trust your body and lean on the people who love you.', hi: 'Aap bas pahunchne hi waali hain. Apne sharir par bharosa karein aur apno ka sahaara lein.'),
      ),
    ],
    bullets: [
      BulletBlock(
        LocalizedText(en: 'Self-care', hi: 'Apna khayal'),
        [
          LocalizedText(en: 'Rest in short bursts; sleep when you can.', hi: 'Thode-thode aaram karein; jab mauka mile so lein.'),
          LocalizedText(en: 'Keep your hospital bag ready.', hi: 'Apna hospital bag taiyaar rakhein.'),
        ],
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 6 · PARENTVEDA JOURNEY (green) — emotional engagement (day-anchored)
  // ===========================================================================
  JourneyMilestone(
    id: 'pv_d30',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 4,
    anchorDay: 30,
    emoji: '❤️',
    title: LocalizedText(en: '30 Days Together', hi: '30 Din Saath'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'Thirty days of walking this journey together. The bond is already growing. ❤️', hi: 'Tees din is safar mein saath chalte hue. Rishta abhi se gehra ho raha hai. ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d100',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 14,
    anchorDay: 100,
    emoji: '❤️',
    title: LocalizedText(en: '100 Days Together', hi: '100 Din Saath'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'One hundred days of love, care and quiet moments. ❤️', hi: 'Sau din pyaar, dekhbhaal aur shaant palon ke. ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d140',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 20,
    anchorDay: 140,
    emoji: '❤️',
    title: LocalizedText(en: 'Halfway Through Pregnancy', hi: 'Aadha Safar Poora'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'One hundred and forty days — exactly halfway. Look how far you\'ve come. ❤️', hi: 'Ek sau chaalis din — theek aadhe. Dekhiye aap kitni door aa chuki hain. ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d200',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 28,
    anchorDay: 200,
    emoji: '❤️',
    title: LocalizedText(en: '200 Days Together', hi: '200 Din Saath'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'Two hundred days of this beautiful journey. Almost there now. ❤️', hi: 'Do sau din is khoobsurat safar ke. Ab bas thoda aur. ❤️'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'pv_d280',
    type: JourneyNodeType.pvJourney,
    anchorWeek: 40,
    anchorDay: 280,
    emoji: '❤️',
    title: LocalizedText(en: 'Journey Complete', hi: 'Safar Poora'),
    sections: [
      CardSection(
        LocalizedText(en: '', hi: ''),
        LocalizedText(en: 'Two hundred and eighty days of love brought you here. Welcome to the world, little one. ❤️', hi: 'Do sau assi din ke pyaar ne aapko yahan pahunchaaya. Duniya mein swagat hai, nanhe. ❤️'),
      ),
    ],
  ),

  // ===========================================================================
  //  TYPE 7 · FEATURE UNLOCKS (teal) — natural feature discovery
  // ===========================================================================
  JourneyMilestone(
    id: 'f_weight',
    type: JourneyNodeType.feature,
    anchorWeek: 8,
    emoji: '🔓',
    title: LocalizedText(en: 'Weight Tracker', hi: 'Weight Tracker'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'Yeh kya karta hai'),
        LocalizedText(en: 'Gently logs your weight through pregnancy so you can see healthy, steady change over time.', hi: 'Pregnancy mein aapka wazan halke se note karta hai taaki aap samay ke saath sehatmand, sthir badlaav dekh sakein.'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'Yeh kyun maayne rakhta hai'),
        LocalizedText(en: 'Steady weight gain is one simple sign that things are progressing well.', hi: 'Sthir wazan badhna ek aasaan sanket hai ki sab theek chal raha hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_kegel',
    type: JourneyNodeType.feature,
    anchorWeek: 24,
    emoji: '🔓',
    title: LocalizedText(en: 'Kegel Care', hi: 'Kegel Care'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'Yeh kya karta hai'),
        LocalizedText(en: 'Guides you through gentle pelvic-floor exercises with simple reminders.', hi: 'Aasaan reminders ke saath halke pelvic-floor exercises karwata hai.'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'Yeh kyun maayne rakhta hai'),
        LocalizedText(en: 'A strong pelvic floor supports your body now and helps recovery later.', hi: 'Mazboot pelvic floor abhi aapke sharir ko sahaara deta hai aur baad mein recovery mein madad karta hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_movement',
    type: JourneyNodeType.feature,
    anchorWeek: 28,
    emoji: '🔓',
    title: LocalizedText(en: 'Baby Movement Tracker', hi: 'Baby Movement Tracker'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'Yeh kya karta hai'),
        LocalizedText(en: 'Helps you notice your baby\'s daily pattern of movements — no counting pressure.', hi: 'Aapke baby ki rozaana harkaton ke pattern par dhyan dene mein madad karta hai — ginti ka koi dabaav nahi.'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'Yeh kyun maayne rakhta hai'),
        LocalizedText(en: 'Knowing what\'s normal for your baby brings peace of mind in the third trimester.', hi: 'Apne baby ke liye kya normal hai yeh jaan-na teesri trimester mein sukoon deta hai.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_hospital',
    type: JourneyNodeType.feature,
    anchorWeek: 34,
    emoji: '🔓',
    title: LocalizedText(en: 'Hospital Bag Planner', hi: 'Hospital Bag Planner'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'Yeh kya karta hai'),
        LocalizedText(en: 'A ready checklist for your hospital bag — for you, your baby and your partner.', hi: 'Aapke hospital bag ke liye taiyaar checklist — aapke, baby aur partner ke liye.'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'Yeh kyun maayne rakhta hai'),
        LocalizedText(en: 'Packing early means one less thing to worry about when the day arrives.', hi: 'Pehle se pack karna matlab us din ek kam chinta.'),
      ),
    ],
  ),
  JourneyMilestone(
    id: 'f_contraction',
    type: JourneyNodeType.feature,
    anchorWeek: 36,
    emoji: '🔓',
    title: LocalizedText(en: 'Contraction Tracker', hi: 'Contraction Tracker'),
    launchComingSoon: true,
    sections: [
      CardSection(
        LocalizedText(en: 'What it does', hi: 'Yeh kya karta hai'),
        LocalizedText(en: 'Times your contractions and their spacing, so you know when things are progressing.', hi: 'Aapke contractions aur unke beech ka samay note karta hai, taaki pata chale kab cheezein aage badh rahi hain.'),
      ),
      CardSection(
        LocalizedText(en: 'Why it matters', hi: 'Yeh kyun maayne rakhta hai'),
        LocalizedText(en: 'Clear timing helps you and your doctor decide when to head in.', hi: 'Saaf timing aapko aur doctor ko decide karne mein madad karti hai ki kab jaana hai.'),
      ),
    ],
  ),
];
