// =============================================================================
//  Pee Safe — the reading shelf (docs/PEE-SAFE-DEMO.md, item 5)
// -----------------------------------------------------------------------------
//  DEMO ONLY. Six ParentVeda reads and one FAQ, presented by Pee Safe through a
//  `sponsoredEducation` campaign (kPeeSafeEducationId). ParentVeda's words; the
//  brand funds the shelf existing and never touches what it says.
//
//  The sponsored-article shape (Mobbin, "Sponsored article"):
//    · eyebrow "PRESENTED BY PEE SAFE" above the title   → PvRead.eyebrow
//    · one disclosure line straight after the intro       → a custom block on
//      the opening section (PeeSafeDisclosureBlock)
//    · "From Pee Safe" products at the very end only      → PvRead.footer
//      (PeeSafeProductsBlock), drawn AFTER the doctor callout, so the clinical
//      copy finishes at "see your doctor" and the shop comes after it.
//
//  Why custom blocks rather than prose: the reader is shared by every stage
//  and must not learn what a brand is. The blocks are opaque to it; this file
//  turns them back into widgets through `PvReaderScreen.customBlock`. The cost
//  is a reader opened WITHOUT [peeSafeReadBlock] silently drops the disclosure,
//  which is why the only way in is [openPeeSafeRead] and the test opens each
//  read through [peeSafeReader].
//
//  Colour: the reader is a shared surface, so ParentVeda ink throughout. No
//  lime here (the lime belongs to Pee Safe's own page).
//
//  English only (CLAUDE.md, "New work is English"): `_same` because the type
//  is LocalizedText, not because a translation exists.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';
import '../../screens/reader/pv_reader_screen.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart' show PvPress;
import '../brand_analytics.dart';
import '../brand_mark.dart';
import '../brand_models.dart';
import '../brand_page_screen.dart';
import '../brand_studio.dart';
import '../presented_by.dart' show showSponsorSheet;
import 'pee_safe_brand.dart';
import 'pee_safe_products.dart';

LocalizedText _same(String s) => LocalizedText(en: s, hi: s);

/// The route name a pushed Pee Safe read carries.
const String kBrandReadRoute = 'brand_read';

// ---- the two blocks -----------------------------------------------------------

/// "Presented by Pee Safe" in one line, after the intro. Taps open the same
/// sponsor sheet every presented-by surface opens.
@immutable
class PeeSafeDisclosureBlock {
  const PeeSafeDisclosureBlock();
}

/// The "From Pee Safe" products at the foot of a read: [peeSafeFor] a moment,
/// optionally narrowed to [only] (by product id) where the moment is broader
/// than the read.
@immutable
class PeeSafeProductsBlock {
  const PeeSafeProductsBlock(this.moment, {this.only});
  final PeeSafeMoment moment;
  final Set<String>? only;

  List<PeeSafeProduct> get products => [
        for (final p in peeSafeFor(moment))
          if (only == null || only!.contains(p.id)) p,
      ];
}

// ---- shared pieces --------------------------------------------------------------

const LocalizedText _eyebrow = LocalizedText(en: 'Presented by Pee Safe', hi: 'Presented by Pee Safe');
const LocalizedText _kicker = LocalizedText(en: 'Read with Pee Safe', hi: 'Read with Pee Safe');
const LocalizedText _author = LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _role = LocalizedText(
    en: 'Written by ParentVeda · November 2026', hi: 'Written by ParentVeda · November 2026');
const double _hue = 150;

PvCallout _doctor(String body) =>
    PvCallout(tone: PvCalloutTone.urgent, title: _same('When to see your doctor'), body: _same(body));

PvReadSection _intro(List<String> paragraphs) => PvReadSection(
      paragraphs: [for (final p in paragraphs) _same(p)],
      custom: const PeeSafeDisclosureBlock(),
    );

PvReadSection _sec(String heading, List<String> paragraphs,
        {List<String> bullets = const [], PvReadTip? tip, PvMythFact? myth}) =>
    PvReadSection(
      heading: _same(heading),
      paragraphs: [for (final p in paragraphs) _same(p)],
      bullets: [for (final b in bullets) _same(b)],
      tip: tip,
      mythFact: myth,
    );

PvReadFaq _faq(String q, String a) => PvReadFaq(question: _same(q), answer: _same(a));

// ---- the reads -------------------------------------------------------------------

final PvRead _discharge = PvRead(
  id: 'ps_read_discharge',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('Discharge in pregnancy'),
  teaser: _same('Why there is more of it, what normal looks like, and the few changes worth a call.'),
  scaleSetter: _same(
      'More discharge in pregnancy is one of the most common changes there is, and on its own it is a sign of a body doing its job. '
      'What matters is not how much, but whether its colour, smell or feel changes, or whether it comes with itching, pain or blood.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'Many women notice it in the first weeks: underwear that is damp by the afternoon, a thin white or clear discharge that was not there before. '
          'It can be one of the first signs of pregnancy, and it usually increases steadily until the birth.',
    ]),
    _sec('Why there is more of it', [
      'Rising oestrogen and a greater blood flow to the pelvis make the cervix and the vaginal walls produce more fluid. '
          'That fluid carries old cells and bacteria out of the vagina, which is part of how the body protects the pregnancy from infection.',
      'Late in pregnancy the amount often rises again. In the last weeks you may also lose the mucus plug, a thicker, jelly-like discharge that can be clear, pink or streaked with a little brown blood. '
          'It is a sign that the cervix is getting ready, not that labour has started; labour can still be days or weeks away.',
    ]),
    _sec('What normal looks like', [
      'Normal pregnancy discharge has a few steady features. It is the thing to compare against when you are unsure.',
    ], bullets: [
      'Thin and milky white, or clear',
      'A mild smell, or none',
      'No itching, soreness or burning',
      'More of it as the weeks go on',
    ], tip: PvReadTip(
      title: _same('A liner, not a tampon'),
      body: _same('If the dampness bothers you, a thin, unperfumed panty liner changed through the day is enough. '
          'Tampons and menstrual cups are not used in pregnancy, because anything inside the vagina can carry bacteria up towards the cervix.'),
    )),
    _sec('Changes worth a call', [
      'Thrush (a yeast infection) is more common in pregnancy because of the hormone changes. It usually brings a thick, white, cottage-cheese discharge with itching or soreness. '
          'It is easy to treat, but ask your doctor or pharmacist which treatment is safe in pregnancy, because some tablets used outside pregnancy are not.',
      'Bacterial vaginosis tends to give a thin grey discharge with a fishy smell, often stronger after sex. A green or yellow, frothy discharge can mean another infection. '
          'Both are worth treating in pregnancy, so they are worth mentioning even if they feel minor.',
      'A watery leak is different from discharge. If you feel a gush or a steady trickle of clear fluid, especially one you cannot stop the way you would stop urine, it may be your waters. '
          'Before 37 weeks, a sudden increase in discharge or a change to watery, mucus-like or bloody discharge can also be an early sign of labour.',
    ]),
    _sec('Everyday care', [
      'The vagina cleans itself, so care is mostly about leaving it alone. Wash the outside once a day with plain water or a mild, unperfumed wash, and pat dry. '
          'Wipe from front to back after the toilet. Wear cotton underwear, and change it if it gets damp.',
      'Skip douching, vaginal deodorants, scented wipes and bubble baths. They upset the balance of healthy bacteria, which is exactly what keeps infections like thrush and bacterial vaginosis away.',
    ], myth: PvMythFact(
      myth: _same('More discharge means you are not clean enough, so wash more often.'),
      fact: _same('More discharge is normal in pregnancy. Washing inside, or washing more, removes the healthy bacteria and makes infections more likely, not less.'),
    )),
  ],
  faqs: [
    _faq('Is it normal to need to change my underwear during the day?',
        'Yes, for many women. A panty liner changed every few hours, or a change of cotton underwear, is fine.'),
    _faq('Can I use an intimate wash in pregnancy?',
        'On the outside only, and only a mild, unperfumed one. Plain water is just as good. Never use it inside the vagina.'),
    _faq('How do I tell discharge from my waters?',
        'Discharge is usually thicker and comes slowly. Waters are thin and watery and keep coming. If you are not sure, call your maternity unit; they would rather check.'),
  ],
  whenToSeeSomeone: _doctor(
      'Call your maternity unit straight away if you have a gush or steady leak of watery fluid, any bleeding, or, before 37 weeks, a sudden change or increase in discharge with tightening or back pain. '
      'If your discharge itches, smells unpleasant, changes colour or comes with burning when you pass urine, see your doctor.'),
  evidence: _same('NHS: Vaginal discharge in pregnancy; ACOG: Vaginitis in pregnancy; RCOG patient information on preterm labour.'),
  readNext: const ['ps_read_uti', 'ps_read_faq'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.pregnancy, only: {'ps_panty_liners', 'ps_intimate_wash'}),
);

final PvRead _uti = PvRead(
  id: 'ps_read_uti',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('UTIs and toilet hygiene in pregnancy'),
  teaser: _same('Why urine infections are more common now, the signs, and what actually helps on the loo.'),
  scaleSetter: _same(
      'Urine infections are common in pregnancy and usually clear quickly with the right antibiotic. '
      'The one thing not to do is wait them out: in pregnancy a bladder infection can travel to the kidneys, so even mild symptoms are worth a urine test.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'You will be going to the toilet more often now, and sometimes in places you would rather not. '
          'It helps to know which habits really protect you from infection and which are mostly about comfort.',
    ]),
    _sec('Why pregnancy makes them more likely', [
      'Pregnancy hormones relax the muscle in the tubes that carry urine from the kidneys, so urine flows more slowly. '
          'As the womb grows it presses on the bladder, which can stop it emptying completely. Urine that sits for longer gives bacteria time to grow.',
      'Most urine infections come from your own bowel bacteria travelling a short distance to the urethra. That is why the direction you wipe matters more than almost anything else.',
      'Some women carry bacteria in their urine with no symptoms at all. That is why a urine sample is tested at your booking visit, and it is treated if bacteria are found.',
    ]),
    _sec('The signs', [
      'A bladder infection usually brings one or more of these. Some women have only one, and some feel just generally unwell.',
    ], bullets: [
      'Burning or stinging when you pass urine',
      'Needing to go far more often or urgently, and passing only a little',
      'Cloudy, strong-smelling or blood-tinged urine',
      'Pain or pressure low in the tummy',
    ]),
    _sec('Habits that help', [
      'Wipe from front to back, every time. Drink enough water that your urine is pale, which flushes the bladder through. '
          'Go when you need to rather than holding on, and pass urine soon after sex. Cotton underwear and loose clothing keep the area dry.',
      'When you pass urine, sit down properly and lean slightly forward to help the bladder empty. Take your time, and when you think you have finished, wait a moment and try again.',
    ], tip: PvReadTip(
      title: _same('Sit, do not hover'),
      body: _same('Hovering over a public toilet tightens the pelvic floor and can stop the bladder emptying fully, which is the thing that matters for infection. '
          'If a seat puts you off, wipe or spray it, or use a seat cover, and then sit.'),
    )),
    _sec('About public toilets', [
      'Toilet seats are rarely how a urine infection starts. The bacteria that cause most of them are already your own. '
          'Cleaning a seat is still reasonable, for comfort and for other germs on surfaces, but it is your wiping, your fluids and emptying your bladder that do most of the protecting.',
      'Carry what makes a public toilet bearable for you: tissues, a small hand sanitiser, wipes, or a seat spray. Wash or sanitise your hands afterwards, especially before you eat.',
    ], myth: PvMythFact(
      myth: _same('You catch urine infections from dirty toilet seats.'),
      fact: _same('Most urine infections come from your own gut bacteria. Wiping front to back, drinking water and not holding on do far more than any seat product.'),
    )),
  ],
  faqs: [
    _faq('Are antibiotics safe in pregnancy?',
        'Several antibiotics are safe in pregnancy and are used routinely for urine infections. Your doctor will choose one that suits your stage of pregnancy. Finish the whole course.'),
    _faq('Does cranberry juice prevent UTIs?',
        'The evidence is mixed, and it is no substitute for treatment. Water does the flushing; cranberry adds sugar.'),
    _faq('I am going to the toilet all the time. Is that an infection?',
        'Not necessarily. Needing to go more often is normal in early and late pregnancy. Burning, pain, blood or a fever are what point to infection.'),
  ],
  whenToSeeSomeone: _doctor(
      'Get urgent care the same day if you have a fever, chills, pain in your back or side below the ribs, or you are being sick, because these can mean the infection has reached the kidneys. '
      'If it burns or stings when you pass urine, or you notice blood or cloudy urine, see your doctor.'),
  evidence: _same('NICE NG109: Urinary tract infection (lower) — antimicrobial prescribing; NHS: Urinary tract infections in pregnancy; ACOG: Urinary tract infections in pregnancy.'),
  readNext: const ['ps_read_discharge', 'ps_read_faq'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.travel,
      only: {'ps_seat_sanitizer', 'ps_travels_kit', 'ps_intimate_wipes'}),
);

final PvRead _lochia = PvRead(
  id: 'ps_read_lochia',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('Bleeding after birth, and the pads for it'),
  teaser: _same('How long it lasts, how it changes week by week, what to wear, and the signs that need a doctor.'),
  scaleSetter: _same(
      'Bleeding after birth, called lochia, happens after every birth, including a caesarean. It is heaviest in the first days and slowly fades over about six weeks. '
      'Most of it is simply the lining of the womb healing. A few specific signs, listed at the end, need care that day.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'Nobody quite prepares you for how much bleeding there is in the first days. It helps to know what is expected, so that you can spot what is not.',
    ]),
    _sec('How it changes', [
      'For the first three or four days the blood is bright or dark red and heavy, like a heavy period, often with small clots. '
          'Over the next week or two it turns pink or brown and becomes lighter. After that it fades to a yellowish-white discharge that can last until around six weeks.',
      'It often comes in a rush when you stand up after lying down, because blood has pooled while you rested. It can also get heavier while breastfeeding, because feeding releases the hormone that makes the womb contract. '
          'Both are normal and both ease with time.',
    ], bullets: [
      'Days 1 to 4: red, heavy, small clots',
      'About days 4 to 12: pink or brown, lighter',
      'Up to about six weeks: yellowish-white, light',
    ]),
    _sec('Pads only, until your check-up', [
      'Use pads, not tampons or a menstrual cup, until your doctor has seen you at your postnatal check, usually around six weeks. '
          'While the womb heals, anything inside the vagina can carry bacteria in and raise the risk of infection.',
      'Choose long, high-absorbency maternity or night pads for the first days. They are softer than everyday pads and let you see how much you are losing, which matters for the warning signs. '
          'Change them every two to four hours, or sooner if they are full, and wash your hands before and after.',
      'Disposable underwear or period panties are easier than your own for the first week, especially after a caesarean, when a waistband can sit on the wound. '
          'As the bleeding lightens, move to ordinary pads and then to panty liners.',
    ], tip: PvReadTip(
      title: _same('Keep a pad count'),
      body: _same('For the first few days, notice roughly how often you change. If you suddenly need a fresh pad every hour, that is the most useful thing to tell a doctor.'),
    )),
    _sec('Rest helps it settle', [
      'Lochia often gets briefly heavier if you do too much too soon. If it turns red again after it had become pink or brown, treat it as a sign to rest, and if it does not settle, call.',
      'Passing urine often helps too. A full bladder makes it harder for the womb to contract, and in the first days it may be hard to feel when you need to go.',
    ], myth: PvMythFact(
      myth: _same('Bleeding after a caesarean is lighter, so you will not need maternity pads.'),
      fact: _same('After a caesarean you still have lochia for several weeks. It may be lighter at first, but you will need the same kind of pads.'),
    )),
    _sec('When it is not the usual', [
      'Rarely, heavy bleeding starts or returns days or weeks after the birth. This can happen if a small piece of placenta stays behind or an infection develops. '
          'It is treatable, and the sooner it is seen the simpler the treatment.',
    ]),
  ],
  faqs: [
    _faq('Is it normal to pass clots?',
        'Small clots in the first few days are common, especially when you stand up. Clots larger than a golf ball, or many clots, need a call to your doctor.'),
    _faq('Can I use a menstrual cup after birth?',
        'Not until your postnatal check. After that, ask whether you need a different size, as some women do after a vaginal birth.'),
    _faq('When can I use tampons again?',
        'After your postnatal check, usually around six weeks, once the bleeding has stopped and your doctor is happy.'),
  ],
  whenToSeeSomeone: _doctor(
      'Call an ambulance or go to hospital now if you soak through a pad in an hour or less, pass clots larger than a golf ball, or feel faint, dizzy or have a racing heart. '
      'If the bleeding gets heavier or turns bright red again after slowing, smells unpleasant, or comes with a fever, chills or tummy pain, do not wait for your check-up: see your doctor.'),
  evidence: _same('NHS: Your body after the birth; RCOG Green-top Guideline 52: Postpartum haemorrhage; WHO recommendations on maternal and newborn care for a positive postnatal experience (2022).'),
  readNext: const ['ps_read_peri', 'ps_read_periods'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.postpartum,
      only: {'ps_night_pads', 'ps_all_night_kit', 'ps_period_panty', 'ps_panty_liners'}),
);

final PvRead _peri = PvRead(
  id: 'ps_read_peri',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('Gentle care down below after birth'),
  teaser: _same('Looking after stitches, tears and soreness in the first weeks, from the first wee to the first walk.'),
  scaleSetter: _same(
      'Most women are sore down below after a vaginal birth, and many have a tear or stitches. For most, the soreness is much better within one to two weeks and the stitches dissolve on their own. '
      'Simple care at home does most of the work; a few signs of infection need a doctor.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'The area between the vagina and the back passage, the perineum, stretches a great deal during birth. Whether it tore, was cut or simply bruised, it needs a few weeks of gentle care.',
    ]),
    _sec('The first wee', [
      'The first few times you pass urine can sting, especially over a graze or stitches. Pouring warm water over the area while you go dilutes the urine and takes away most of the sting. '
          'A peri bottle or a portable jet spray makes this easy, and you can keep using it to rinse after every toilet visit.',
      'Afterwards, pat the area dry from front to back with clean toilet paper or a soft towel. Do not rub. Change your pad at the same time.',
    ], tip: PvReadTip(
      title: _same('Lean forward'),
      body: _same('Leaning forward on the toilet takes the stream of urine away from the stitches. Many women find it is the single most helpful trick of the first days.'),
    )),
    _sec('Easing the soreness', [
      'In the first day or two, a cold pack wrapped in a cloth, held on the area for ten to twenty minutes, reduces swelling. Never put ice directly on the skin.',
      'After that, a shallow bath of plain warm water for a few minutes can soothe. You do not need salt, oils or antiseptic in the water. '
          'Sitting on a soft cushion and lying on your side to feed can take the pressure off. Paracetamol is generally fine while breastfeeding; ask your doctor what suits you.',
    ], bullets: [
      'A wrapped cold pack in the first 48 hours',
      'Warm water rinses after the toilet',
      'Pads changed every few hours',
      'Air: some time each day without underwear, lying on a towel',
    ]),
    _sec('Your first poo', [
      'Many women dread it, and it is almost always easier than feared. Stitches very rarely come apart from a bowel movement.',
      'Drink plenty, eat fruit, vegetables and wholegrains, and go when you feel the urge rather than putting it off. '
          'Holding a clean pad against the stitches as you go gives support and confidence. If you are constipated, ask your doctor for a softener that is safe while breastfeeding.',
    ], myth: PvMythFact(
      myth: _same('You should wash stitches with antiseptic or a strong soap to keep them clean.'),
      fact: _same('Plain warm water is best. Antiseptics, scented soaps and strong washes can sting and slow healing.'),
    )),
    _sec('Healing and your pelvic floor', [
      'Gentle pelvic floor exercises can start in the first days, as soon as they feel comfortable. They improve blood flow to the area, help healing and protect against leaking later. '
          'Squeeze and lift as if stopping wind and urine at the same time, hold for a few seconds, then let go fully.',
      'After a caesarean the perineum is usually less sore, but the same toilet care helps, and your wound needs keeping clean and dry. '
          'Wash it gently with water and pat dry, and wear loose, high-waisted underwear so nothing rubs.',
    ]),
  ],
  faqs: [
    _faq('When do stitches dissolve?',
        'Most dissolve on their own within two to four weeks. You may notice small pieces of thread on your pad; that is normal.'),
    _faq('Is a jet spray better than a peri bottle?',
        'Either works. What matters is warm, clean water and patting dry afterwards. Use whichever you find easier to hold.'),
    _faq('When will sitting feel normal?',
        'For most women it is much more comfortable within two weeks. If it is getting worse rather than better, that is worth a check.'),
  ],
  whenToSeeSomeone: _doctor(
      'Pain that gets worse rather than better, swelling, redness, pus, a bad smell, a wound that seems to be opening, or a fever can be signs of infection. '
      'If you have any of these, or you cannot control wind or bowel movements, see your doctor.'),
  evidence: _same('NHS: Episiotomy and perineal tears; RCOG patient information: Perineal tears during childbirth; NICE NG194: Postnatal care.'),
  readNext: const ['ps_read_lochia', 'ps_read_periods'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.postpartum,
      only: {'ps_jet_spray', 'ps_period_panty', 'ps_panty_liners'}),
);

final PvRead _periods = PvRead(
  id: 'ps_read_periods',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('When your periods come back'),
  teaser: _same('When to expect them, how the first ones can feel, and why contraception matters before they return.'),
  scaleSetter: _same(
      'There is no single right time for periods to return after a baby. It can be six weeks or more than a year, and both are normal. '
      'The one thing worth knowing early is that you can be fertile before your first period arrives.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'Once the bleeding after birth has stopped, the next bleed you see may be your first period. When it arrives depends mostly on how you are feeding your baby.',
    ]),
    _sec('When to expect them', [
      'If you are not breastfeeding, or are mixing breastfeeding with formula, periods often return within about five to ten weeks after the birth.',
      'Breastfeeding, especially feeding often and at night, keeps the hormone that delays ovulation high. Many women who breastfeed exclusively do not have a period for several months, and some not until they stop. '
          'As feeds drop, solid food starts or the baby sleeps longer at night, periods often return.',
    ]),
    _sec('You can be fertile before the first period', [
      'Ovulation happens about two weeks before a period, so the first egg is released before you see any bleeding. That means you can become pregnant again before you know your cycle is back.',
      'Breastfeeding alone only works as contraception if all of these are true: your baby is under six months, you are feeding only breast milk day and night with no long gaps, and your periods have not returned. '
          'If any one changes, it no longer protects you. Talk to your doctor about contraception at your postnatal check, or sooner.',
    ]),
    _sec('How the first periods can feel', [
      'The first few periods can be heavier, longer, lighter or more irregular than before, and cramps may be different. It often takes a few cycles for a pattern to settle.',
      'Pads are the simplest place to start. Tampons and cups are fine again once your doctor has cleared you at your postnatal check. '
          'After a vaginal birth some women find they need a different cup size or a different way of inserting it, so give it a few tries before deciding.',
    ], bullets: [
      'Heavier or longer bleeding for a cycle or two',
      'Irregular timing while you are still breastfeeding',
      'Cramps that feel different from before',
    ], tip: PvReadTip(
      title: _same('Lochia or a period?'),
      body: _same('Lochia fades steadily from red to pink to yellowish-white. Bright red bleeding that returns after lochia has finished, and lasts a few days, is more likely a period.'),
    )),
    _sec('Breastfeeding and your period', [
      'You can keep breastfeeding through your periods. Some babies are a little fussier for a day or two, and some mothers notice a small dip in supply just before a period, which settles.',
    ], myth: PvMythFact(
      myth: _same('Your milk goes bad when your period comes back.'),
      fact: _same('Breast milk stays good for your baby during your period. You do not need to stop feeding.'),
    )),
  ],
  faqs: [
    _faq('Is a very heavy first period normal?',
        'It can be heavier than you are used to. Soaking a pad or tampon every hour for several hours, or large clots, is not; see a doctor.'),
    _faq('My periods have not come back and I stopped breastfeeding. When should I worry?',
        'If three months pass after you stopped breastfeeding with no period, take a pregnancy test and see your doctor.'),
    _faq('Can I use a menstrual cup again?',
        'Yes, after your postnatal check. You may need a different size or a few tries to find a comfortable fit.'),
  ],
  whenToSeeSomeone: _doctor(
      'If your periods are very heavy, last more than seven days, come with severe pain, or have not returned three months after you stop breastfeeding, '
      'or if you want to plan or avoid another pregnancy, see your doctor.'),
  evidence: _same('NHS: Periods after pregnancy; WHO Family Planning: A Global Handbook for Providers (lactational amenorrhoea method); FSRH Guideline: Contraception after pregnancy.'),
  readNext: const ['ps_read_lochia', 'ps_read_ttc'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.periodsReturn),
);

final PvRead _ttc = PvRead(
  id: 'ps_read_ttc',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('Intimate hygiene while trying to conceive'),
  teaser: _same('What to keep, what to drop, and why the simplest routine is the kindest one right now.'),
  scaleSetter: _same(
      'No intimate hygiene product helps you conceive, and most of what you need is nothing at all. '
      'A few common habits, such as douching and some lubricants, are worth dropping while you try. Everything else can stay as it is.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'When you are trying for a baby it is natural to look at every routine and wonder whether it helps or harms. For intimate hygiene, the answer is reassuringly simple.',
    ]),
    _sec('The vagina looks after itself', [
      'The vagina keeps a slightly acidic balance of healthy bacteria that protects against infection. It cleans itself with its own discharge, and it does not need washing inside.',
      'Wash the outside, the vulva, once a day with plain water or a mild, unperfumed wash, and pat dry. Wipe front to back. Cotton underwear lets the area breathe.',
    ]),
    _sec('What to drop', [
      'Douching, rinsing inside the vagina, upsets the natural balance and is linked with bacterial vaginosis and other infections. It is worth stopping completely.',
      'Scented washes, sprays, wipes and bubble baths can irritate the skin and change the balance of bacteria too. If you like using a wash, keep it mild, unperfumed and on the outside only.',
    ], bullets: [
      'Douching or washing inside the vagina',
      'Scented soaps, sprays and deodorants on the vulva',
      'Steaming, herbal inserts and other vaginal cleanses',
    ], myth: PvMythFact(
      myth: _same('A special wash or a vaginal cleanse makes it easier to get pregnant.'),
      fact: _same('There is no evidence for that. Washing inside can upset the healthy bacteria that protect you, so less is better.'),
    )),
    _sec('Lubricants and sperm', [
      'Some everyday lubricants slow sperm down in laboratory tests, and so can saliva and oils. If you need a lubricant, a fertility-friendly one labelled as sperm-safe is a sensible choice while you are trying.',
      'Changes in your discharge through the cycle are normal and useful. Around ovulation it often becomes clear, stretchy and slippery, like raw egg white. Washing does not change it, and it is not a sign of anything wrong.',
    ], tip: PvReadTip(
      title: _same('Your discharge is information'),
      body: _same('If you track your cycle, noticing when discharge turns clear and stretchy is one of the simplest signs of your fertile days. It needs no product at all.'),
    )),
    _sec('Period products while you try', [
      'Pads, tampons, period pants and menstrual cups are all fine while trying to conceive. Choose whatever is comfortable. A cup should be emptied and rinsed at least every twelve hours and cleaned between cycles.',
      'If you have thrush or bacterial vaginosis, treat it before you carry on as normal. Both are common, both are easily treated, and neither is something to put up with.',
    ]),
  ],
  faqs: [
    _faq('Does using a menstrual cup affect fertility?',
        'No. Cups, tampons and pads do not affect your fertility. Use whichever you prefer.'),
    _faq('Is it safe to use an intimate wash while trying?',
        'A mild, unperfumed wash on the outside is fine. Plain water works just as well. Never use one inside.'),
    _faq('Should I lie down after sex?',
        'There is no good evidence that it helps. Stay as long as you are comfortable, then get up and pass urine, which helps prevent urine infections.'),
  ],
  whenToSeeSomeone: _doctor(
      'If your discharge itches, smells unpleasant, changes colour, or you have pain during sex or bleeding between periods, it may be an infection worth treating. '
      'And if you have been trying for a year, or six months if you are 35 or over, see your doctor.'),
  evidence: _same('NICE CG156: Fertility problems — assessment and treatment; NHS: Keeping your vagina clean and healthy; ACOG: Douching (FAQ).'),
  readNext: const ['ps_read_periods', 'ps_read_faq'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.tryingToConceive),
);

/// The FAQ: short sections, many questions. Not held to the long-read shape
/// (it is a look-up, not an argument); the test holds it to its FAQ count.
final PvRead _faqRead = PvRead(
  id: 'ps_read_faq',
  eyebrow: _eyebrow,
  kicker: _kicker,
  title: _same('Intimate hygiene: your questions'),
  teaser: _same('The questions people search for late at night, answered plainly.'),
  scaleSetter: _same(
      'Most intimate hygiene questions have a calm answer: less is more, water is usually enough, and changes that come with itching, pain, smell or blood are the ones to have checked.'),
  author: _author,
  authorRole: _role,
  reviewed: false,
  hue: _hue,
  sections: [
    _intro([
      'Short answers to the questions we hear most, from trying to conceive to the months after birth. Each links to a longer read on the shelf.',
    ]),
    _sec('The one rule', [
      'The vagina cleans itself. Wash only the outside, with water or a mild unperfumed wash, and never douche.',
    ]),
    _sec('In pregnancy', [
      'More discharge is normal. Use liners, not tampons or cups. Urine infections need treating, so get any burning checked.',
    ]),
    _sec('After birth', [
      'Pads only until your postnatal check. Rinse with warm water after the toilet and pat dry. Watch the pad count in the first days.',
    ]),
  ],
  faqs: [
    _faq('Do I need an intimate wash?',
        'No. Water is enough. If you prefer a wash, choose a mild, unperfumed one and use it on the outside only.'),
    _faq('Are scented panty liners a problem?',
        'They can irritate sensitive skin. Unperfumed liners, changed every few hours, are kinder.'),
    _faq('Can I catch an infection from a toilet seat?',
        'It is unlikely. Most urine infections come from your own gut bacteria. Wiping front to back matters more.'),
    _faq('Is it safe to use a menstrual cup in pregnancy?',
        'No. Nothing goes inside the vagina for bleeding or discharge in pregnancy, and any bleeding in pregnancy needs a call to your doctor.'),
    _faq('How long will I bleed after birth?',
        'Usually up to about six weeks, getting lighter and paler over time.'),
    _faq('When can I use tampons or a cup again after birth?',
        'After your postnatal check, once the bleeding has stopped and your doctor is happy.'),
    _faq('Can I get pregnant before my first period after birth?',
        'Yes. You ovulate before your first period, so plan contraception early if you want to avoid another pregnancy.'),
    _faq('Does a vaginal cleanse help me conceive?',
        'No. Cleansing inside upsets the healthy balance and can make infections more likely.'),
  ],
  whenToSeeSomeone: _doctor(
      'Itching, an unpleasant smell, a change in colour, pain, a fever, or any bleeding in pregnancy are worth a call. If you are unsure, see your doctor.'),
  evidence: _same('NHS: Keeping your vagina clean and healthy; NHS: Your body after the birth; NICE NG194: Postnatal care.'),
  readNext: const ['ps_read_discharge', 'ps_read_lochia', 'ps_read_ttc'],
  footer: const PeeSafeProductsBlock(PeeSafeMoment.pregnancy, only: {'ps_intimate_wash', 'ps_panty_liners'}),
);

/// Every Pee Safe read, in shelf order. The six long reads, then the FAQ.
final List<PvRead> kPeeSafeReads = [_discharge, _uti, _lochia, _peri, _periods, _ttc, _faqRead];

PvRead? peeSafeReadById(String id) {
  for (final r in kPeeSafeReads) {
    if (r.id == id) return r;
  }
  return null;
}

/// The shelf's campaign, by id. A lookup, not a resolve: the read is already
/// open, so this is attribution for taps, not a new impression.
BrandCampaign? peeSafeEducationCampaign() {
  for (final c in BrandStudio.instance.campaigns) {
    if (c.id == kPeeSafeEducationId && c.active) return c;
  }
  return null;
}

// ---- opening a read ---------------------------------------------------------------

/// The reader for a Pee Safe read, with the block renderer that draws its
/// disclosure and products. The one way to build it.
Widget peeSafeReader(PvRead read) => PvReaderScreen(
      read: read,
      lang: AppLanguage.english,
      customBlock: peeSafeReadBlock,
      resolveRead: peeSafeReadById,
      readTitle: (id) => peeSafeReadById(id)?.title,
      openRead: (context, id) => openPeeSafeRead(context, id),
    );

/// Opens the Pee Safe read [readId] in `PvReaderScreen`. False when the id is
/// not a Pee Safe read, so the caller can fall back (a toast) rather than
/// push an empty page.
bool openPeeSafeRead(BuildContext context, String readId) {
  final read = peeSafeReadById(readId);
  if (read == null) return false;
  final c = peeSafeEducationCampaign();
  if (c != null) BrandAnalytics.instance.event(c, BrandEvent.opened, meta: {'read': readId});
  Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kBrandReadRoute),
    builder: (_) => peeSafeReader(read),
  ));
  return true;
}

// ---- rendering the blocks -----------------------------------------------------------

// Kept for revert: _ink 0xFF2D144C (a purple ink, 2026-11-03: the app's one ink).
const Color _ink = Color(0xFF2F2C30);
const Color _soft = Color(0xFF69636C);
const Color _line = Color(0xFFE4E2E5);

/// `PvReaderScreen.customBlock` for Pee Safe reads.
Widget peeSafeReadBlock(BuildContext context, Object block) => switch (block) {
      PeeSafeDisclosureBlock() => const _Disclosure(),
      PeeSafeProductsBlock() => _Products(block: block),
      _ => const SizedBox.shrink(),
    };

class _Disclosure extends StatelessWidget {
  const _Disclosure();

  @override
  Widget build(BuildContext context) {
    final c = peeSafeEducationCampaign();
    return PvPress(
      child: GestureDetector(
        key: const ValueKey('ps_read_disclosure'),
        behavior: HitTestBehavior.opaque,
        onTap: c == null ? null : () => showSponsorSheet(context, c),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _line), bottom: BorderSide(color: _line)),
          ),
          child: Row(children: [
            BrandMark(brand: kPeeSafe, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Presented by Pee Safe. Pee Safe funded this read; ParentVeda wrote it and decides what it says.',
                style: pvManrope(fontSize: 12, height: 1.45, fontWeight: FontWeight.w600, color: _soft),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.info_outline_rounded, size: 14, color: _soft),
          ]),
        ),
      ),
    );
  }
}

class _Products extends StatelessWidget {
  const _Products({required this.block});
  final PeeSafeProductsBlock block;

  @override
  Widget build(BuildContext context) {
    final products = block.products;
    final c = peeSafeEducationCampaign();
    return Column(
      key: const ValueKey('ps_read_products'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FROM PEE SAFE',
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: _ink)),
        const SizedBox(height: 4),
        Text('Sponsored. Nothing above was written to sell these, and no ParentVeda rating is for sale.',
            style: pvManrope(fontSize: 12, height: 1.45, color: _soft)),
        const SizedBox(height: 12),
        for (final p in products)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PvPress(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => p.open(campaign: c),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _line),
                  ),
                  child: Row(children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(p.image,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(width: 52, height: 52, color: _line)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(p.name, style: pvJakarta(fontSize: 13.5, fontWeight: FontWeight.w700, color: _ink)),
                        const SizedBox(height: 2),
                        Text(p.line, style: pvManrope(fontSize: 12, height: 1.4, color: _soft)),
                      ]),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.open_in_new_rounded, size: 15, color: _soft),
                  ]),
                ),
              ),
            ),
          ),
        // Brand mentions link to the brand page (Mobbin, "Sponsored article").
        PvPress(
          child: GestureDetector(
            key: const ValueKey('ps_read_brand_link'),
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(context).push(BrandPageScreen.route(kPeeSafe)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text('More on the Pee Safe page',
                    style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 16, color: _ink),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}
