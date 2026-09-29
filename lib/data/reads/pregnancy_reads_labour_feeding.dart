// =============================================================================
//  Labour prep › Feeding and first days — getting ready to feed, before birth
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "Labour prep › Feeding and first days", P2: *"She is not
//  meeting breastfeeding for the first time at 3 am in a ward."* We had one
//  expert note and a paid masterclass. These five reads are the free
//  preparation, written for the last weeks of pregnancy and for an Indian
//  hospital and home.
//
//  Spread into `kPregnancyReadsLabour`, so the shared index is untouched.
//
//  ⚠️ BREASTFEEDING FIRST, NEVER SHAME. Written the way Indian doctors advise
//  (WHO, IAP, the MAA programme): breast milk first and only for six months.
//  And said without pressure on anyone who can't, or who needs formula. A
//  feeding read that makes a tired mother feel she failed has failed her.
//
//  ⚠️ FAMILY ADVICE IS CORRECTED KINDLY. Ghutti, honey, water, discarding
//  colostrum: every one is answered as "the person who told you loves you,
//  and here is what doctors now advise" (PREG-VOICE §2.8).
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The feeding tab's hue, warmer than the labour red.
const double _hue = 12;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Labour prep');
final LocalizedText _kicker = _en('Feeding and first days');

/// The newborn feeding signs, shared by every read here so they can't drift.
final PvCallout _feedingUrgent = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Call the doctor the same day if'),
  body: _en("Your baby isn't feeding at all, has fewer wet nappies than "
      "expected, is very sleepy and hard to wake for feeds, or looks yellow "
      "in the first day. Call too if you have a fever, or a hot, red, painful "
      "patch on your breast. Go to hospital now if the baby is floppy, blue "
      "around the lips, or breathing very fast or with grunting."),
);

final List<PvRead> kPregnancyReadsLabourFeeding = [
  // ---------------------------------------------------------------------------
  //  How breastfeeding starts
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_bf_start',
    hue: _hue,
    kicker: _kicker,
    title: _en('How breastfeeding starts'),
    teaser: _en("What a good latch looks like, three holds to learn now, "
        "hand expression, and answers for flat nipples, implants and "
        "C-sections."),
    shortAnswer: _en("Breastfeeding is something you and your baby learn "
        "together in the first days. A good latch, with a wide mouth and "
        "plenty of breast in it, is what makes feeding comfortable. Learning "
        "two or three holds and how to hand express before the birth makes "
        "the first days easier."),
    scaleSetter: _en("Almost every woman can breastfeed, including women with "
        "small breasts, flat nipples or a C-section. It's natural, and it's "
        "also a skill, and most of the trouble in the first week comes from "
        "not knowing what normal looks like. That part you can learn now."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Breast milk is all your baby needs for the first six months, "
            "with no water, ghutti or honey. It protects against infections, "
            "is easy to digest, and changes as your baby grows. For you, it "
            "helps your womb shrink back after birth, and over the years it "
            "lowers the rate of breast and ovarian cancer across women who "
            "breastfeed."),
        _en("Some women can't breastfeed, or need to add formula, for medical "
            "or other reasons. That's never a failure. Your doctor will help "
            "you feed your baby well, whichever way it is."),
      ]),
      PvReadSection(
        heading: _en('What does a good latch look like?'),
        paragraphs: [
          _en("Your baby feeds from the breast, not just the nipple. The "
              "nipple should reach the back of the baby's mouth, where it "
              "won't be squashed. When the latch is right, feeding shouldn't "
              "hurt after the first few seconds."),
        ],
        bullets: [
          _en("Bring your baby to your breast, not your breast to the baby. "
              "Tummy to tummy, with the nose opposite your nipple."),
          _en("Wait for a wide-open mouth, like a yawn, then bring the baby "
              "in quickly, chin first."),
          _en("The chin presses into the breast, and the lips are turned "
              "out."),
          _en("More of the dark area (areola) shows above the top lip than "
              "below the bottom one."),
          _en("You hear or see swallowing, and the cheeks stay round, not "
              "sucked in."),
        ],
        tip: PvReadTip(
          title: _en('If it hurts'),
          body: _en("Slide a clean little finger into the corner of the "
              "baby's mouth to break the suction, and try again. A latch that "
              "keeps hurting is worth showing to a nurse or lactation "
              "consultant the same day."),
        ),
      ),
      PvReadSection(
        heading: _en('Which holds should I learn?'),
        bullets: [
          _en("Cradle hold: the baby lies across your lap, head in the crook "
              "of your arm. The classic hold, once feeding is going well."),
          _en("Cross-cradle hold: like the cradle, but you support the baby's "
              "head with the opposite hand. Good for the first days, because "
              "you can guide the latch."),
          _en("Underarm (football) hold: the baby lies along your side, "
              "under your arm, feet towards your back. Good after a C-section, "
              "because it keeps the baby off your wound."),
          _en("Side-lying: you both lie on your sides, facing each other. "
              "Good for rest and night feeds, and after a C-section."),
        ],
        tip: PvReadTip(
          title: _en('Practise with a doll or pillow'),
          body: _en("Try each hold a few times in the last weeks. Use pillows "
              "to bring the baby up to your breast, so you're not bending "
              "over."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I express milk by hand?'),
        paragraphs: [
          _en("Hand expression helps if your baby is sleepy, can't feed yet, "
              "or your breasts are very full. Wash your hands. Make a C shape "
              "with your thumb and fingers, a few centimetres back from the "
              "nipple. Press back towards your chest, then gently squeeze "
              "together and release. Keep a rhythm, and move round the "
              "breast."),
          _en("In the first days you'll only get drops of colostrum. That's "
              "normal and precious. Collect them in a clean spoon or syringe "
              "for your baby."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I have flat nipples, implants or a C-section?'),
        bullets: [
          _en("Flat or inverted nipples: most women still breastfeed, because "
              "the baby latches onto the breast, not just the nipple. Tell the "
              "nurse early. A good latch and some patience usually work. "
              "Don't try to pull or prepare your nipples in pregnancy."),
          _en("Breast implants: most women with implants can breastfeed. "
              "Tell your doctor, and ask for help early. Breast reduction "
              "surgery can affect supply more, so plan feeding support ahead."),
          _en("After a C-section: yes, you can, often in the recovery room. "
              "Milk may take a day longer to come in, so feed often. Use the "
              "underarm or side-lying hold and a pillow over your wound."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I know my baby is hungry?'),
        paragraphs: [
          _en("Crying is a late sign of hunger. Earlier signs are easier to "
              "feed through: turning the head and opening the mouth, sucking "
              "on hands or fists, smacking lips, and wriggling. Feed when you "
              "see these, and let your baby finish the first breast before "
              "offering the second."),
        ],
      ),
    ],
    whenToSeeSomeone: _feedingUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Do I need to prepare my nipples?'),
        answer: _en("No. Rubbing or toughening them doesn't help and can hurt. "
            "Your body gets them ready by itself."),
      ),
      PvReadFaq(
        question: _en('How often will my baby feed?'),
        answer: _en("Often. Newborns usually feed 8 to 12 times in 24 hours, "
            "including at night. Feed whenever the baby shows hunger, like "
            "rooting or sucking hands."),
      ),
      PvReadFaq(
        question: _en('Should I buy a pump before the birth?'),
        answer: _en("Most women don't need one in the first weeks. Wait and "
            "see, unless your baby is likely to need special care."),
      ),
    ],
    evidence: _en('WHO / UNICEF Baby-Friendly Hospital Initiative (2018) and '
        'Ten Steps to Successful Breastfeeding · WHO infant and young child '
        'feeding guidance · Indian Academy of Pediatrics infant feeding '
        'guidelines · Ministry of Health and Family Welfare, Mothers\' '
        'Absolute Affection (MAA) programme (2016) · Lancet Breastfeeding '
        'Series (2016).'),
    readNext: [
      'preg_labour_read_colostrum',
      'preg_labour_read_golden_hour_feed',
      'preg_week_read_exp_meera',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Colostrum
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_colostrum',
    hue: _hue,
    kicker: _kicker,
    title: _en('Colostrum, and when your milk comes in'),
    teaser: _en("The first milk, why a few drops are enough, and what "
        "happens between day two and day four."),
    shortAnswer: _en("Colostrum is the thick, yellowish first milk your "
        "breasts make from pregnancy. A few spoonfuls a day are all a newborn "
        "needs, because the stomach is tiny. Your fuller milk usually comes "
        "in on day two to four."),
    scaleSetter: _en("The most common worry in the first days is 'I don't "
        "have any milk.' You do. It's just a small amount of very rich milk, "
        "and it's exactly right for now."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Your breasts start making colostrum from about the middle of "
            "pregnancy. Some women notice a few yellow drops or crusts on "
            "their nipples. Others see nothing at all. Both are normal and "
            "say nothing about how much milk you'll have."),
        _en("Colostrum is thick and yellow or clear. It's full of "
            "antibodies that protect your baby from infection, which is why "
            "doctors call it the baby's first immunisation."),
      ]),
      PvReadSection(
        heading: _en('Is a few drops really enough?'),
        paragraphs: [
          _en("Yes. On the first day, your baby's stomach holds about a "
              "teaspoon, roughly the size of a marble. Colostrum comes in "
              "small amounts to match. By the end of the first week, the "
              "stomach is about the size of an egg, and your milk has grown "
              "to match."),
          _en("Frequent feeds are how your body knows to make more. That's "
              "why newborns feed so often, 8 to 12 times a day. It's not a "
              "sign you don't have enough."),
        ],
        mythFact: PvMythFact(
          myth: _en("The first yellow milk is dirty or stale and should be "
              "thrown away."),
          fact: _en("Colostrum is the most protective milk your baby will "
              "ever have. Older relatives were often taught to discard it, "
              "with the best intentions. Doctors now advise giving every "
              "drop to the baby."),
        ),
      ),
      PvReadSection(
        heading: _en('When does my milk come in?'),
        paragraphs: [
          _en("Usually on day two to four. Your breasts feel fuller, warmer "
              "and heavier, and the milk turns whiter and more plentiful. You "
              "may hear your baby gulping."),
          _en("It can take a little longer after a C-section, a long or hard "
              "labour, if you have diabetes, or if you and the baby were "
              "apart at first. Keep feeding and expressing, and ask for help. "
              "It usually comes."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my breasts get very full?'),
        paragraphs: [
          _en("When milk comes in, breasts can get hard, swollen and sore. "
              "This is called engorgement. Feeding often is the best cure."),
        ],
        bullets: [
          _en("Feed every two to three hours, including at night."),
          _en("Hand express a little before a feed, to soften the breast so "
              "the baby can latch."),
          _en("Use cool cloths after feeds to ease swelling."),
          _en("Wear a soft, supportive bra that isn't tight."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I collect colostrum before the birth?'),
        paragraphs: [
          _en("Some doctors suggest collecting colostrum by hand from about "
              "36 or 37 weeks, for example if you have diabetes, so there's "
              "some ready if the baby's sugar runs low. It's frozen in small "
              "syringes."),
          _en("Only do this if your doctor suggests it. Touching the nipples "
              "can bring on tightenings, so it's not right for everyone."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I know feeding is going well in the first week?'),
        paragraphs: [
          _en("Nappies are the easiest guide. Wet nappies usually go up by "
              "about one a day: one on day one, two on day two, and so on, "
              "until at least six a day from about day five. Stools change "
              "from black and sticky (meconium) to green, then to soft and "
              "yellow by about day four or five."),
          _en("Most babies lose some weight in the first days, and that's "
              "expected. They usually lose up to about a tenth of their birth "
              "weight, and are back to it by about two weeks. The nurse or "
              "baby doctor will weigh your baby and tell you if it's on "
              "track."),
          _en("A baby who feeds often, wakes for feeds, has plenty of wet "
              "nappies and seems settled after most feeds is usually getting "
              "enough, even when your breasts don't feel full."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does colostrum matter so much?'),
        paragraphs: [
          _en("Colostrum coats your baby's gut and helps protect it from "
              "germs while it's still new. It also works as a gentle laxative, "
              "helping your baby pass the first dark stools. That helps clear "
              "the yellow colour of newborn jaundice."),
          _en("It helps keep your baby's blood sugar steady in the first days, "
              "too. That's why frequent feeds, even short ones, matter so "
              "much, and why nothing else is needed for a well baby."),
          _en("If your baby does need something extra for low sugar, the "
              "doctor may first ask you to hand express colostrum and give it "
              "by spoon. That's another reason to learn hand expression "
              "before the birth."),
        ],
      ),
    ],
    whenToSeeSomeone: _feedingUrgent,
    faqs: [
      PvReadFaq(
        question: _en('My breasts are small. Will I have enough milk?'),
        answer: _en("Yes. Breast size doesn't decide how much milk you make. "
            "How often the baby feeds does."),
      ),
      PvReadFaq(
        question: _en('How do I know my baby is getting enough?'),
        answer: _en("By about day five, look for at least six wet nappies a "
            "day, yellow stools, and a baby who seems content after most "
            "feeds. Weight checks at the clinic confirm it."),
      ),
      PvReadFaq(
        question: _en('Should I drink extra milk or eat special foods?'),
        answer: _en("Drink to thirst, and eat well. Traditional foods are fine "
            "as part of good meals, but nothing special is needed to make "
            "milk."),
      ),
    ],
    evidence: _en('WHO / UNICEF Baby-Friendly Hospital Initiative (2018) · '
        'WHO infant and young child feeding guidance · Indian Academy of '
        'Pediatrics infant feeding guidelines · Cochrane review of antenatal '
        'breast milk expression (2016) · Ministry of Health and Family '
        'Welfare, MAA programme (2016).'),
    readNext: [
      'preg_labour_read_golden_hour_feed',
      'preg_labour_read_feeding_help',
      'preg_labour_read_bf_start',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  The first feed, in the golden hour
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_golden_hour_feed',
    hue: _hue,
    kicker: _kicker,
    title: _en('The first feed, in the golden hour'),
    teaser: _en("Why the first hour matters for feeding, what it looks like, "
        "and how to make it happen in an Indian labour room or theatre."),
    shortAnswer: _en("WHO and Indian doctors advise starting breastfeeding "
        "within an hour of birth. With your baby skin to skin on your chest, "
        "most babies find the breast themselves. Ask for it in your birth "
        "plan, and ask the nurse to help."),
    scaleSetter: _en("Babies are awake and alert in the first hour after "
        "birth, and then often sleep for hours. That's why this first feed "
        "is worth asking for. If it doesn't happen, you haven't missed "
        "anything. The next feed is just as welcome."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The first hour after birth is often called the golden hour. "
            "Your baby is awake and ready to suck, and your body is ready too. "
            "A first feed in this hour helps feeding start well and gives "
            "your baby colostrum straight away."),
        _en("It also helps you. Your baby's sucking releases a hormone that "
            "makes your womb contract, which reduces bleeding after birth."),
      ]),
      PvReadSection(
        heading: _en('What does the first feed look like?'),
        paragraphs: [
          _en("Your baby lies on your bare chest, skin to skin, with a warm "
              "cloth over both of you. For a while, the baby may just rest. "
              "Then you'll see licking, rooting, bobbing the head and moving "
              "towards the breast."),
          _en("Many babies latch on by themselves within the hour. Others "
              "need a little help. Support the baby's back and shoulders, and "
              "let the baby lead. The first feed may be short. That's fine."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I make sure it happens?'),
        bullets: [
          _en("Write it in your birth plan: skin to skin straight away and a "
              "first feed in the first hour, if we're both well."),
          _en("Tell the nurse when you arrive, and remind your companion to "
              "ask again after the birth."),
          _en("Ask for weighing, measuring and the first bath to wait until "
              "after the first feed, if the baby is well."),
          _en("Keep the room quiet, and visitors outside, until the feed is "
              "done."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Nothing else first'),
          body: _en("Your baby doesn't need honey, ghutti, sugar water or "
              "formula before the first feed. Colostrum is all a well baby "
              "needs. If your family suggests otherwise, you can say the "
              "doctor asked for breast milk only."),
        ),
      ),
      PvReadSection(
        heading: _en('What about after a C-section?'),
        paragraphs: [
          _en("You can still feed in the first hour in many hospitals, in "
              "theatre or in recovery. The baby can lie across your chest, "
              "above the wound, with a nurse helping."),
          _en("If you can't hold the baby yet, your partner or mother can "
              "hold the baby skin to skin until you can. You can also hand "
              "express a few drops of colostrum for the baby."),
        ],
      ),
      PvReadSection(
        heading: _en('What if we need to be apart?'),
        paragraphs: [
          _en("Sometimes a baby needs care in the NICU, or you need care "
              "first. That's hard, and it doesn't mean feeding won't work."),
          _en("Ask a nurse to help you hand express within the first hour or "
              "two, and every few hours after that. Your colostrum can be "
              "taken to your baby. Hold your baby skin to skin as soon as you "
              "can."),
        ],
      ),
      PvReadSection(
        heading: _en("What if my baby won't latch in the first hour?"),
        paragraphs: [
          _en("Some babies are sleepy, especially after a long labour, pain "
              "medicine or a C-section. Others need a while to settle. It "
              "doesn't mean something is wrong, and it doesn't mean feeding "
              "won't work."),
          _en("Keep your baby skin to skin, which keeps them warm and close to "
              "the breast. Hand express a few drops of colostrum onto your "
              "nipple, so your baby can smell and taste it. Try a different "
              "hold, like the cross-cradle, with a nurse's help."),
          _en("If your baby still isn't feeding after a few hours, collect "
              "your colostrum in a spoon or syringe and give it that way, and "
              "ask the baby doctor to check your baby. Keep trying at the "
              "breast at every feed."),
        ],
      ),
      PvReadSection(
        heading: _en('Does the first feed make a difference later?'),
        paragraphs: [
          _en("Across large studies, babies who start breastfeeding in the "
              "first hour are more likely to be breastfed for longer, and to "
              "be exclusively breastfed. Early feeding also helps protect "
              "newborns from infection in the first weeks."),
          _en("But feeding is built over days, not decided in one hour. If "
              "your first feed comes later, because of a general anaesthetic, "
              "a NICU stay or anything else, start as soon as you can. Skin to "
              "skin, frequent feeds and good help will get you there."),
          _en("Many women who couldn't feed in the first hour go on to "
              "breastfeed for months. What matters most is what happens over "
              "the next few days: feeding often, staying close, and getting "
              "help early if something hurts or doesn't feel right."),
        ],
      ),
    ],
    whenToSeeSomeone: _feedingUrgent,
    faqs: [
      PvReadFaq(
        question: _en('What if the baby is too sleepy to feed?'),
        answer: _en("Keep the baby skin to skin, and try again in a little "
            "while. In the first day, wake the baby for a feed at least "
            "every three hours, and ask the nurse for help."),
      ),
      PvReadFaq(
        question: _en('Should my baby be bathed first?'),
        answer: _en("No. WHO advises waiting at least a day before the first "
            "bath. It keeps the baby warm and helps feeding."),
      ),
      PvReadFaq(
        question: _en('Is it fine to feed in front of family?'),
        answer: _en("It's your choice. A dupatta or light cloth can help if "
            "you want privacy, and you can ask visitors to step out."),
      ),
    ],
    evidence: _en('WHO recommendation on early initiation of breastfeeding '
        '(2017) · WHO / UNICEF Ten Steps to Successful Breastfeeding (2018) · '
        'Cochrane review of early skin-to-skin contact (2016) · Ministry of '
        'Health and Family Welfare, MAA programme (2016) · Indian Academy of '
        'Pediatrics infant feeding guidelines.'),
    readNext: [
      'preg_labour_read_first_hour',
      'preg_labour_read_feeding_help',
      'preg_labour_read_colostrum',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Asking for help in hospital
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_feeding_help',
    hue: _hue,
    kicker: _kicker,
    title: _en('Asking for feeding help in hospital'),
    teaser: _en("Who can help, what to ask on day one, how a lactation "
        "consultant helps, and where to find support once you're home."),
    shortAnswer: _en("Ask for feeding help on your first day, not the third. "
        "Nurses, a lactation consultant if your hospital has one, and "
        "breastfeeding support groups can all help. Find out now who helps "
        "at your hospital, and save one number for after you go home."),
    scaleSetter: _en("Needing help with feeding is normal, not a sign that "
        "something is wrong with you or your baby. Most problems are small "
        "and easy to fix while someone is watching."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the first days, a lot is happening, and feeding help can "
            "get missed. Nurses are busy, and families may give advice "
            "that's different from the doctor's."),
        _en("It helps to know, before the birth, who you can ask and what "
            "to ask. Then on day one, you can just say: please can someone "
            "watch a feed and check the latch?"),
      ]),
      PvReadSection(
        heading: _en('Who can help?'),
        bullets: [
          _en("The nurses on the ward. Ask any of them to watch a feed."),
          _en("A lactation consultant. Many city hospitals have one. They're "
              "trained in breastfeeding and can help with latch, positions, "
              "pain and supply."),
          _en("Your baby's doctor (paediatrician), especially about weight, "
              "jaundice or a sleepy baby."),
          _en("Breastfeeding support groups. The Breastfeeding Promotion "
              "Network of India (BPNI) and local groups run meetings and "
              "helplines. Other mothers can help a lot."),
          _en("ASHA workers and ANMs in your area, who visit after birth "
              "under government programmes."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask on day one?'),
        bullets: [
          _en("Can someone watch a full feed and check the latch?"),
          _en("How do I know my baby is getting enough?"),
          _en("Can you show me how to hand express?"),
          _en("Which hold is best for me after my stitches or C-section?"),
          _en("If my baby needs anything besides breast milk, why, and can "
              "my expressed colostrum be given first?"),
          _en("Who can I call about feeding after I go home?"),
        ],
      ),
      PvReadSection(
        heading: _en('What does a lactation consultant do?'),
        paragraphs: [
          _en("A lactation consultant is trained to help with feeding. They "
              "watch a feed, look at your baby's mouth and your breasts, and "
              "help with latch, positions and milk supply. Some visit at "
              "home or see you online."),
          _en("It's worth finding one before the birth. Ask your hospital if "
              "they have one, or ask your doctor or friends for a name. The "
              "international qualification is IBCLC. Save a number, so you're "
              "not searching at 3am."),
        ],
      ),
      PvReadSection(
        heading: _en('What if I need formula?'),
        paragraphs: [
          _en("Sometimes a baby needs some formula, for example with low "
              "blood sugar, too much weight loss, or if you're unwell. Your "
              "doctor will tell you. It's fine to ask why and how much, and "
              "whether you can keep breastfeeding alongside it."),
          _en("If you choose formula, or need to use it, your baby will be "
              "fed and loved. No one should make you feel bad about it. Ask "
              "the nurse how to prepare it safely and feed it responsively."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do before the birth?'),
        bullets: [
          _en("Find out who helps with feeding at your hospital, and whether "
              "there's a lactation consultant."),
          _en("Save one feeding helpline or consultant's number in your "
              "phone."),
          _en("Talk to your family now about breast milk only for six months, "
              "so there are no surprises on day one."),
          _en("Learn two holds and hand expression. There's a read on this "
              "tab that shows how."),
          _en("Pack a soft nursing bra and a pillow for feeding."),
        ],
      ),
      PvReadSection(
        heading: _en('What problems are common in the first week?'),
        paragraphs: [
          _en("Sore nipples, usually from a shallow latch. Very full, hard "
              "breasts when the milk comes in. A sleepy baby who needs waking "
              "for feeds. Mild jaundice around day three. And cluster feeding, "
              "when a baby wants to feed again and again for a few hours, "
              "often in the evening."),
          _en("All of these are common and usually settle with help and "
              "time. None of them means you're doing it wrong. Ask about "
              "each one as it comes, rather than waiting for it to pass."),
        ],
      ),
      PvReadSection(
        heading: _en('Where can I get help once I am home?'),
        paragraphs: [
          _en("Under the government's home-based newborn care programme, an "
              "ASHA worker visits several times in the first six weeks. She "
              "can check feeding and weigh the baby. Ask for these visits if "
              "no one comes."),
          _en("Many lactation consultants see mothers at home or on a video "
              "call, which helps in the first weeks when going out is hard. "
              "Your baby doctor's clinic can also check a feed at the first "
              "visit. Ask for help as soon as something feels wrong."),
          _en("A friend who has breastfed can help a lot too."),
        ],
      ),
    ],
    whenToSeeSomeone: _feedingUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Feeding hurts. Is that normal?'),
        answer: _en("A little tenderness in the first days is common. Pain "
            "that lasts through feeds, or cracked or bleeding nipples, usually "
            "means the latch needs help. Ask the same day."),
      ),
      PvReadFaq(
        question: _en('My mother-in-law says my milk is thin.'),
        answer: _en("Breast milk often looks thin or bluish, and that's "
            "normal. It's exactly what the baby needs. She means well, and "
            "you can show her the doctor's advice."),
      ),
      PvReadFaq(
        question: _en('Does a lactation consultant cost money?'),
        answer: _en("In some hospitals it's included, in others it's extra. "
            "Government hospitals and BPNI helplines offer free support. Ask "
            "about costs beforehand."),
      ),
    ],
    evidence: _en('WHO / UNICEF Ten Steps to Successful Breastfeeding (2018) '
        '· WHO guideline on counselling of women to improve breastfeeding '
        'practices (2018) · Breastfeeding Promotion Network of India (BPNI) '
        '· Ministry of Health and Family Welfare, MAA programme (2016) and '
        'Home Based Newborn Care.'),
    readNext: [
      'preg_labour_read_bf_start',
      'preg_labour_read_first_40',
      'preg_week_read_exp_meera',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Planning the first 40 days at home
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_labour_read_first_40',
    hue: _hue,
    kicker: _kicker,
    title: _en('Planning the first 40 days at home'),
    teaser: _en("Rest, help, food and visitors: what to arrange before the "
        "birth, which traditions help, and which signs need a doctor."),
    shortAnswer: _en("Many Indian families keep the first 40 days for rest "
        "and recovery. Plan it now: who helps with what, how nights will "
        "work, what you'll eat, and how many visitors you want. Keep the "
        "warning signs for you and your baby somewhere you'll see them."),
    scaleSetter: _en("The first weeks are tiring for everyone, and nobody "
        "does them perfectly. A little planning now means you can spend them "
        "resting, feeding and getting to know your baby, not sorting things "
        "out."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In many parts of India the weeks after birth have a name, like "
            "jaapa or sawa mahina, and a rhythm: rest, special food, oil "
            "massage and help from family. Much of this is wise. Your body is "
            "healing, and you're feeding round the clock."),
        _en("It helps to talk about the plan with your partner and family "
            "before the birth, when everyone is calm."),
      ]),
      PvReadSection(
        heading: _en('Who will help with what?'),
        bullets: [
          _en("Nights: who will bring the baby to you, change nappies, or "
              "take the baby for an hour so you can sleep?"),
          _en("Food: who will cook, and what? Warm, simple meals, plenty of "
              "water, dal, vegetables, and the traditional foods you enjoy."),
          _en("House and older children: who takes on the chores and the "
              "school run?"),
          _en("Your partner: if he can take leave, the first two weeks are "
              "when it helps most."),
          _en("Paid help: a trained maid or japa helper, if you plan one, "
              "is best booked by 32 to 34 weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('Which traditions help, and which to skip?'),
        bullets: [
          _en("Rest, warm food and help at home: all good."),
          _en("Oil massage for you and the baby: fine, gently. Keep oil out "
              "of the baby's eyes, ears and nose, and away from the cord "
              "stump."),
          _en("Drinking plenty of water: good. Cutting down water to 'stop "
              "swelling' isn't advised, especially when you're feeding."),
          _en("Bathing: fine for you, and helps healing. Wait until the "
              "baby's cord stump has dropped off before tub baths for the "
              "baby."),
          _en("Kajal or surma on the baby: please skip it. Some contain lead, "
              "and it can cause eye infections."),
          _en("A very hot, closed room: keep the room comfortable. Babies "
              "can overheat, especially in summer."),
        ],
      ),
      PvReadSection(
        heading: _en('How many visitors?'),
        paragraphs: [
          _en("Everyone wants to meet the baby, and it's a happy time. But "
              "lots of visitors can tire you and pass on colds to the baby. "
              "It's fine to ask people to come for short visits, to wash "
              "hands, and to stay away if they're unwell."),
          _en("Your partner or mother can be the one who says it, so you "
              "don't have to."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I have ready?'),
        bullets: [
          _en("A feeding corner with a pillow, water and snacks."),
          _en("The doctor's and hospital's numbers on paper, and on the "
              "fridge."),
          _en("Your baby's vaccination card, and the date of the six-week "
              "check for you both."),
          _en("Birth registration: the hospital usually files it. It must be "
              "registered within 21 days, so check who's doing it and "
              "collect the certificate."),
          _en("A plan for your mood. The baby blues in the first two weeks "
              "are common. Low mood that lasts longer, or scary thoughts, "
              "need a doctor. Tell someone early."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens to my body in these weeks?'),
        paragraphs: [
          _en("Bleeding after birth (lochia) is like a heavy period at first, "
              "then turns brown and lighter over four to six weeks. Cramps "
              "while feeding are your womb shrinking back, and they ease "
              "after the first days."),
          _en("Stitches or a C-section wound need gentle care and rest, and "
              "you'll tire quickly for a while. Sleep when your baby sleeps, "
              "even for short stretches, and let others do the rest."),
          _en("At the six-week check, your doctor will look at how you're "
              "healing and talk about contraception, because you can get "
              "pregnant again before your periods return. Ask about "
              "anything else that's on your mind, including sex, leaking or "
              "how you're feeling."),
        ],
      ),
      PvReadSection(
        heading: _en('How can my partner help?'),
        paragraphs: [
          _en("Partners can do almost everything except breastfeed. Burping, "
              "nappies, bathing, rocking the baby to sleep, and holding the "
              "baby skin to skin all build their bond too."),
          _en("They can bring you water and food at every feed, keep "
              "visitors short, and watch your mood as well as the baby's. If "
              "they notice you're low for more than two weeks, they can help "
              "you talk to the doctor."),
          _en("And they can take a night feed with expressed milk once feeding "
              "is going well, so you get a longer stretch of sleep."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('In the first weeks, go to hospital now if'),
      body: _en("You're soaking a pad in an hour or passing large clots, have "
          "a fever, a severe headache, blurred vision, chest pain, "
          "breathlessness, or a painful swollen calf, or you have thoughts of "
          "harming yourself or the baby. Take the baby now if they're floppy, "
          "blue, breathing fast, not feeding, very yellow, or have a fever."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Do I have to stay indoors for 40 days?'),
        answer: _en("No medical rule says so. Rest is what matters. Short "
            "walks and fresh air are fine once you feel ready."),
      ),
      PvReadFaq(
        question: _en('When can I start exercising?'),
        answer: _en("Gentle walks and pelvic floor exercises can start in the "
            "first days. Ask your doctor at the six-week check before "
            "anything harder."),
      ),
      PvReadFaq(
        question: _en('When is my first check-up after birth?'),
        answer: _en("Usually around six weeks, often with the baby's six-week "
            "vaccines. Your hospital may see you sooner for stitches or a "
            "C-section wound."),
      ),
    ],
    evidence: _en('WHO recommendations on maternal and newborn care for a '
        'positive postnatal experience (2022) · Ministry of Health and Family '
        'Welfare, Home Based Newborn Care guidance · Registration of Births '
        'and Deaths Act, 1969 · Indian Academy of Pediatrics newborn care and '
        'immunisation guidance.'),
    readNext: [
      'preg_week_read_first_24h',
      'preg_labour_read_feeding_help',
      'preg_labour_read_bf_start',
    ],
  ),
];
