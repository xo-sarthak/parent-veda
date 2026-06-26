// =============================================================================
//  Mother's Body Changes — week-by-week, in gentle biological sections
// -----------------------------------------------------------------------------
//  Richer, researched "what is changing in your body this week" content, broken
//  into small biological sections (hormones, womb, breasts…). Seeded for the
//  preview weeks (4 & 5); when a week is present here, the Mom's Journey card
//  renders these sections instead of the single physical-changes paragraph.
//  Educational + reassuring only — never diagnostic.
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
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'The pregnancy hormone hCG is rising — this is what a home test detects.',
          hi: 'Pregnancy hormone hCG badh raha hai — yahi home test detect karta hai.'),
    ),
    BodyChange(
      LocalizedText(en: 'Your womb', hi: 'Aapka garbhashay'),
      LocalizedText(
          en: 'The tiny embryo is settling into your uterus lining; light spotting can be normal.',
          hi: 'Nanha embryo aapke uterus ki lining mein bas raha hai; halki spotting normal ho sakti hai.'),
    ),
    BodyChange(
      LocalizedText(en: 'How you may feel', hi: 'Kaisa lag sakta hai'),
      LocalizedText(
          en: 'Often nothing obvious yet — perhaps mild cramps or slightly tender breasts.',
          hi: 'Aksar abhi kuch khaas nahi — halki cramps ya breasts mein halka khinchaav ho sakta hai.'),
    ),
    BodyChange(
      LocalizedText(en: 'Blood supply', hi: 'Blood supply'),
      LocalizedText(
          en: 'Your body is beginning to make more blood to support your baby.',
          hi: 'Aapka sharir baby ke liye zyada khoon banana shuru kar raha hai.'),
    ),
  ],
  5: [
    BodyChange(
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'Progesterone and hCG keep rising, which can bring the first symptoms.',
          hi: 'Progesterone aur hCG badhte rehte hain, jisse pehle lakshan aa sakte hain.'),
    ),
    BodyChange(
      LocalizedText(en: 'Breasts', hi: 'Breasts'),
      LocalizedText(
          en: 'They may feel fuller, tingly or tender as milk ducts begin to form.',
          hi: 'Ye bhare, jhunjhunaahat-bhare ya naram lag sakte hain jaise milk ducts banna shuru hote hain.'),
    ),
    BodyChange(
      LocalizedText(en: 'Energy', hi: 'Urja'),
      LocalizedText(
          en: 'Rising progesterone can leave you feeling unusually tired.',
          hi: 'Badhta progesterone aapko bahut zyada thaka mehsoos kara sakta hai.'),
    ),
    BodyChange(
      LocalizedText(en: 'Nausea', hi: 'Matli'),
      LocalizedText(
          en: 'Early morning sickness may begin — small, frequent meals help.',
          hi: 'Subah ki matli shuru ho sakti hai — thode-thode baar-baar meals madad karte hain.'),
    ),
    BodyChange(
      LocalizedText(en: 'Your womb', hi: 'Aapka garbhashay'),
      LocalizedText(
          en: 'Your uterus is still small (about a lemon) — no visible bump yet.',
          hi: 'Aapka uterus abhi chhota hai (lagbhag nimbu jitna) — abhi bump nahi dikhega.'),
    ),
  ],
  20: [
    BodyChange(
      LocalizedText(en: 'Hormones', hi: 'Hormones'),
      LocalizedText(
          en: 'Levels are steadier now — many feel more energy in the second trimester.',
          hi: 'Ab levels zyada sthir hain — doosri trimester mein kai logon ko zyada urja mehsoos hoti hai.'),
    ),
    BodyChange(
      LocalizedText(en: 'Your bump', hi: 'Aapka bump'),
      LocalizedText(
          en: 'The top of your uterus reaches your belly button — your bump is clearly showing.',
          hi: 'Aapke uterus ka upri hissa naabhi tak pahunch jaata hai — bump saaf dikhne lagta hai.'),
    ),
    BodyChange(
      LocalizedText(en: 'First movements', hi: 'Pehli harkatein'),
      LocalizedText(
          en: 'You may feel the first gentle flutters (quickening) around now.',
          hi: 'Aap is samay ke aas-paas pehli halki harkatein (quickening) mehsoos kar sakti hain.'),
    ),
    BodyChange(
      LocalizedText(en: 'Body', hi: 'Sharir'),
      LocalizedText(
          en: 'More blood flow can bring a warm "glow", fuller hair, and occasional round-ligament twinges.',
          hi: 'Zyada blood flow se ek garm "glow", ghane baal, aur kabhi-kabhi round-ligament khinchaav aa sakta hai.'),
    ),
  ],
};
