// =============================================================================
//  Getting ready for baby — the reads behind the new pregnancy door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Getting ready for baby", P2: *"We have products
//  but no guidance, and no names in pregnancy."* Three tabs' worth: Baby
//  names, What to buy (an Indian "need and skip" list the door links to our
//  store), and Home and help (the home, the last months, the first 40 days).
//  These are our own versions, in the pregnancy voice (`docs/PREG-VOICE.md`),
//  never Flo's or What to Expect's sentences.
//
//  Every read here sits on a tile of `kGettingReadyDoor`
//  (`pv_door_getting_ready.dart`); `test/pv_door_getting_ready_test.dart`
//  fails if one is orphaned.
//
//  ⚠️ THE LINES THIS FILE HOLDS
//
//  · Nothing about learning the baby's sex (PCPNDT Act). The names reads are
//    not a guessing tool: families keep a few names that suit any baby.
//  · Star letters (rashi, nakshatra) are described as a family custom she may
//    follow, never as something ParentVeda vouches for or calculates.
//  · Feeding supplies put breastfeeding first, and no read recommends formula
//    or feeding bottles as a purchase (the Infant Milk Substitutes Act, 1992).
//  · The hospital bag is a shipped tool (Ready for Birth). These reads point
//    to it in words and never repeat its list.
//  · Safe sleep is stated once, plainly, and every read that touches it says
//    the same thing (back to sleep, firm flat surface, nothing soft around).
//  · No sentence puts "your" beside a chance word.
//  · `reviewed: false`, ParentVeda editorial, until a clinician has read them.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The Getting ready bracket's own hue (`pregnancy_brackets.dart`), so a
/// read opened from the door keeps the door's colour.
const double _hue = 36;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Getting ready for baby');
final LocalizedText _kNames = _en('Baby names');
final LocalizedText _kBuy = _en('What to buy');
final LocalizedText _kHome = _en('Home and help');

/// The pregnancy warning signs, for the reads whose subject has no urgent
/// signs of its own. MoHFW's danger signs in pregnancy, unsoftened.
final PvCallout _signs = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en("Whatever you're planning, call your doctor straight away if"),
  body: _en("You have bleeding or fluid leaking from your vagina, your baby "
      "is moving less than usual, or you have a severe headache, blurred "
      "vision, or sudden swelling of your face, hands or feet. The same goes "
      "for a fever, strong pain in your tummy, or fits. For heavy bleeding, "
      "fits or fainting, call 108 or go to hospital now."),
);

/// For the reads about work around the home: a fall, a knock, fumes.
final PvCallout _homeCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('Call your doctor today if'),
  body: _en("You slip, fall or take a knock to your tummy, even if you feel "
      "fine afterwards. Call straight away, or go to hospital, if you then "
      "have bleeding, fluid leaking, tummy pain or tightenings that don't "
      "stop, or your baby is moving less than usual. If you feel dizzy, sick "
      "or breathless after breathing in fumes, go out into fresh air and "
      "call your doctor."),
);

/// For the read about the weeks after the birth: her body, her mind, the
/// baby. WHO's postnatal danger signs and the newborn danger signs used in
/// India's home-based newborn care.
final PvCallout _afterBirthCall = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('After the birth, call your doctor straight away if'),
  body: _en("You're soaking a pad in an hour or less, pass large clots, have "
      "a fever, a bad headache or blurred vision, or pain and swelling in "
      "one leg. Call the baby's doctor or go to hospital straight away if "
      "your baby isn't feeding, is very sleepy or floppy, has a fit, feels "
      "hot or very cold, breathes fast or with effort, or looks yellow in "
      "the first day. If you have thoughts of harming yourself or your "
      "baby, tell someone close to you now, or call Tele-MANAS on 14416."),
);

final List<PvRead> kPregnancyReadsReady = [
  // ===========================================================================
  //  BABY NAMES
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Choosing a name together
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_choosing_name',
    hue: _hue,
    kicker: _kNames,
    title: _en('Choosing a name together'),
    teaser: _en("Where to start, who gets a say, names that work in two "
        "languages, and a few ideas to get you going."),
    shortAnswer: _en("Start with a list each, then swap and keep the names "
        "you both like. Say each one out loud with your surname, and check "
        "how it sounds in the languages your family speaks. Keep a few names "
        "that suit any baby, and give yourselves time."),
    scaleSetter: _en("There's no deadline in pregnancy. Many Indian families "
        "don't choose the name until the naming ceremony, days or weeks "
        "after the birth. You can enjoy this slowly."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Choosing a name is one of the first things you'll do for your "
            "baby, and in India it's rarely just the two of you. Parents, "
            "grandparents, a favourite aunt and sometimes the family priest "
            "may all have ideas. That can feel warm, and it can feel like a "
            "lot."),
        _en("This read is about the choosing itself. The customs around "
            "naming, such as the naamkaran, star letters and keeping the name "
            "a secret, have their own read on this tab."),
      ]),
      PvReadSection(
        heading: _en('Where do we start?'),
        paragraphs: [
          _en("Start apart. Each of you writes down every name you like, "
              "without judging it yet. Ten or twenty is plenty. Then swap "
              "lists and mark the ones you could live with."),
          _en("If you're stuck, these questions can help you both find what "
              "matters to you:"),
        ],
        bullets: [
          _en("Is there a meaning you'd love the name to carry, such as "
              "light, strength, kindness or peace?"),
          _en("Would you like to honour someone, like a grandparent, or keep "
              "a sound or a letter that runs in the family?"),
          _en("Do you want a name from your faith, a place you love, a book "
              "or a song?"),
          _en("Short and simple, or long with a pet name for home?"),
        ],
      ),
      PvReadSection(
        heading: _en('Who gets a say?'),
        paragraphs: [
          _en("In many families, the grandparents or the father's sister "
              "(bua) have a traditional part in naming. That's worth "
              "honouring if it matters to you both. It still helps to agree "
              "between yourselves first, before the wider family joins in."),
          _en("One gentle way is to invite suggestions early, and say you'll "
              "decide together as a couple. A name from a grandparent can "
              "become a middle name, a pet name, or the name used at the "
              "ceremony. If feelings run high, it's fine to say, \"We love "
              "that you care. We'll share the name when we're ready.\""),
        ],
      ),
      PvReadSection(
        heading: _en('Will the name work in two languages?'),
        paragraphs: [
          _en("Most Indian children grow up with at least two languages, and "
              "many move between cities or countries. A few quick checks "
              "save surprises later:"),
        ],
        bullets: [
          _en("Say it in each language your family speaks. Some names mean "
              "something unexpected in another Indian language, or in "
              "English."),
          _en("Say it with your surname, and with the full name as it will "
              "sit on a school register."),
          _en("Settle one English spelling now. It will go on the birth "
              "certificate, the Aadhaar card and later a passport, and "
              "changing it later means paperwork."),
          _en("Look at the initials, and what friends might shorten it to."),
          _en("Think about a pet name for home (a ghar ka naam, or daak naam "
              "in Bengali homes). Many children have both, and that's a "
              "lovely tradition."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we shortlist together?'),
        paragraphs: [
          _en("Once you've swapped lists, keep only the names you both like. "
              "Each of you can veto any name, no reason needed. That keeps it "
              "kind."),
          _en("Live with your shortlist for a week or two. Say the names out "
              "loud. Call the bump by one of them for a day and see how it "
              "feels. The names that still make you smile are the ones to "
              "keep."),
          _en("Most families keep a few favourites that would suit any baby, "
              "and choose once they've met them. A face can make the choice "
              "for you."),
          _en("The name finder on this tab lets you each swipe through names "
              "and keep the ones you like. The names you both keep show up "
              "together, so you can start your shortlist from those."),
        ],
        tip: PvReadTip(
          title: _en('Keep it in one place'),
          body: _en("A shared note on your phones works well too. "
              "Add names whenever you hear one you like, and cross them off "
              "together."),
        ),
      ),
      PvReadSection(
        heading: _en('A few names, by meaning'),
        paragraphs: [
          _en("Here are a handful of names to start the conversation. Several "
              "are used for girls and for boys, and all of them travel well "
              "between languages."),
        ],
        bullets: [
          _en("Kiran: a ray of light."),
          _en("Noor: light."),
          _en("Tara: a star."),
          _en("Aman: peace."),
          _en("Ira: the earth."),
          _en("Neel: blue, like the sky."),
          _en("Arya: noble."),
          _en("Ahaan: dawn, the first light of the day."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('When should we decide?'),
        answer: _en("Whenever you're ready. Some couples know months ahead. "
            "Many decide after the birth, or at the naming ceremony. The "
            "hospital can register the birth without a name, and you add "
            "it later."),
      ),
      PvReadFaq(
        question: _en('We keep disagreeing. What helps?'),
        answer: _en("Take a break for a week, then each pick your top three "
            "from the other person's list. It's often easier to agree on a "
            "name you both chose from the other's favourites."),
      ),
      PvReadFaq(
        question: _en('Is it okay to use a name from another faith or '
            'region?'),
        answer: _en("Yes. Many names cross faiths and languages. It's worth "
            "knowing the meaning and saying it the way the language says "
            "it, so the name is used with care."),
      ),
      PvReadFaq(
        question: _en('Should the name match the family surname or '
            'community?'),
        answer: _en("That's your choice. Some families like a name that fits "
            "their tradition, others choose freely. Saying the full name out "
            "loud is the best test."),
      ),
    ],
    evidence: _en('The Registration of Births and Deaths Act, 1969 (as '
        'amended in 2023), on registering a birth and adding the name later '
        '· Office of the Registrar General of India, Civil Registration '
        'System. The customs described are family traditions, not medical '
        'advice.'),
    readNext: [
      'preg_ready_read_naming_customs',
      'preg_ready_read_godh_bharai',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Naming customs
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_naming_customs',
    hue: _hue,
    kicker: _kNames,
    title: _en('Naamkaran, star letters and keeping the name a secret'),
    teaser: _en("How families across India name a baby, what star letters "
        "are, and whether to tell anyone before the day."),
    shortAnswer: _en("Many Indian families name the baby at a ceremony after "
        "the birth, such as the naamkaran, often around the 11th or 12th "
        "day. Some follow star letters (rashi or nakshatra), which depend on "
        "the time of birth, so they can't be known ahead. Keeping the name "
        "secret until the day is common, and it's your choice."),
    scaleSetter: _en("Every family does this differently, and there's no "
        "wrong way. Follow the customs that mean something to you, and let "
        "the rest go. The law only asks that the birth is registered, and "
        "the name can follow."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In many Indian homes, a baby's name isn't only chosen. It's "
            "given, at a ceremony, with the family around. Knowing how your "
            "family does it helps you plan, and helps you decide which parts "
            "you'd like to keep."),
      ]),
      PvReadSection(
        heading: _en('When is a baby named?'),
        paragraphs: [
          _en("It depends on the family and the faith. These are some of the "
              "customs you may meet:"),
        ],
        bullets: [
          _en("Naamkaran: in many Hindu and Jain families, the name is given "
              "at a small puja, often around the 11th or 12th day after the "
              "birth. Some families choose another day with the family "
              "priest."),
          _en("In many Kerala families, the naming comes with the "
              "noolukettu, on the 28th day."),
          _en("Aqiqah: in many Muslim families, the baby is named on or "
              "around the seventh day, and the name may be whispered with "
              "the azaan soon after the birth."),
          _en("In many Sikh families, the name is chosen at the gurdwara. "
              "The first letter of the verse read that day guides the "
              "name."),
          _en("In many Christian families, the name is given at the baptism "
              "or naming service in church."),
        ],
        tip: PvReadTip(
          title: _en('Keep the day gentle'),
          body: _en("If the ceremony is in the first weeks, you'll still be "
              "healing. A short puja, a chair to sit on and a room to feed "
              "the baby in make it easier. Guests with a cough or cold can "
              "send their blessings from home."),
        ),
      ),
      PvReadSection(
        heading: _en('What are star letters?'),
        paragraphs: [
          _en("Some families follow Vedic astrology when naming. The baby's "
              "moon sign (rashi) and birth star (nakshatra) are worked out "
              "from the exact time and place of birth. Each birth star is "
              "linked to a few starting sounds (akshar), and the name begins "
              "with one of them."),
          _en("This is a family custom, and whether you follow it is up to "
              "you. ParentVeda doesn't work out star letters. A family "
              "priest or astrologer usually does, after the birth."),
          _en("Because it depends on the time of birth, no one can know the "
              "letter in pregnancy. If your family follows it, keep names "
              "under a few different letters, or wait until the letter is "
              "known and choose then. Some families use the star name at "
              "ceremonies and a different name every day, and that works "
              "well too."),
        ],
      ),
      PvReadSection(
        heading: _en('Should we keep the name a secret?'),
        paragraphs: [
          _en("Many Indian families keep the name private until the "
              "ceremony. For some it's tradition. For others it's "
              "nicer to hear the name for the first time on the day, all "
              "together."),
          _en("There are good reasons both ways. Keeping it private means "
              "fewer opinions while you're still deciding, and a lovely "
              "moment when you share it. Telling close family early can help "
              "them feel part of it, and some grandparents like to practise "
              "saying it."),
          _en("If you keep it secret, a kind line helps when people ask: "
              "\"We've chosen, and we can't wait to tell you on the day.\" If "
              "someone is hurt, it's usually about wanting to be close. A "
              "call to them first, just before everyone else, can mean a "
              "lot."),
        ],
      ),
      PvReadSection(
        heading: _en("When does the name go on the birth certificate?"),
        paragraphs: [
          _en("Under the Registration of Births and Deaths Act, a birth is "
              "registered within 21 days. When the baby is born in hospital, "
              "the hospital usually reports the birth for you. Ask at the "
              "front desk what they need, and when the certificate will be "
              "ready."),
          _en("The birth can be registered without a name. You can add the "
              "name later at the birth registrar's office of your municipal "
              "body or panchayat. Ask them how long you have, because a "
              "later change can need more paperwork. Check the spelling "
              "carefully, as it will follow your child to school and beyond."),
        ],
      ),
      PvReadSection(
        heading: _en("What if we still haven't agreed by the day?"),
        paragraphs: [
          _en("That happens more than people say. You can hold the ceremony "
              "with the name you're leaning towards, or ask for a few more "
              "days. Some families give a ceremonial name on the day and "
              "choose the everyday name after."),
          _en("A name that grows on you is still the right name. Most "
              "parents say that within a few weeks, the name and the baby "
              "feel like one."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('Can the naming ceremony be held in hospital?'),
        answer: _en("If the baby is still in hospital, many families wait, or "
            "hold a small prayer at the bedside and the full ceremony at "
            "home later. Ask the ward what they allow."),
      ),
      PvReadFaq(
        question: _en('Our families follow different customs. Which do we '
            'use?'),
        answer: _en("Many couples blend them: one family's ceremony, the "
            "other's naming day, or a name that works in both traditions. "
            "Decide together what matters most, then share the plan."),
      ),
      PvReadFaq(
        question: _en('Do we need the star letter for any official form?'),
        answer: _en("No. Official papers only need the name you choose. The "
            "star letter is a family custom."),
      ),
      PvReadFaq(
        question: _en('Can we change the name after it is registered?'),
        answer: _en("Usually yes, with paperwork, but it's easier to get it "
            "right the first time. Ask your birth registrar what's needed."),
      ),
    ],
    evidence: _en('The Registration of Births and Deaths Act, 1969 (as '
        'amended in 2023), on registering a birth within 21 days and adding '
        'the name later · Office of the Registrar General '
        'of India, Civil Registration System. The customs described are '
        'family and faith traditions, not medical advice.'),
    readNext: [
      'preg_ready_read_choosing_name',
      'preg_ready_read_last_months',
    ],
  ),

  // ===========================================================================
  //  WHAT TO BUY
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  What you need
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_need',
    hue: _hue,
    kicker: _kBuy,
    title: _en('What you need for the first three months'),
    teaser: _en("A plain list for an Indian home: clothes, nappies, a safe "
        "place to sleep, feeding, bathing and getting about."),
    shortAnswer: _en("A newborn needs less than the shops suggest: soft "
        "cotton clothes, nappies, a safe flat place to sleep, a few feeding "
        "basics, and a way to carry them. If you'll drive your baby "
        "anywhere, a car seat is the safe way to carry a baby in a car. "
        "Most other things can wait or be borrowed."),
    scaleSetter: _en("You don't need everything before the birth. Buy the "
        "basics, and add what you find you need in the first weeks. Shops "
        "deliver almost everything within a day or two in most cities."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("In the first three months, your baby needs warmth, milk, clean "
            "nappies, a safe place to sleep, and you. Everything below "
            "supports one of those. The numbers are a rough guide for a "
            "family doing laundry every day or two."),
        _en("If you'd like, the Shop the list card on this tab opens a "
            "shopping checklist you can build and tick off, with a starter "
            "list for newborns. You don't have to buy anything from us to "
            "use this list."),
      ]),
      PvReadSection(
        heading: _en('What clothes does a newborn need?'),
        paragraphs: [
          _en("Soft cotton is best for Indian weather. Newborns grow fast, so "
              "buy mostly in the 0 to 3 months size, and only a few in "
              "newborn size."),
        ],
        bullets: [
          _en("6 to 8 front-opening cotton vests (jhablas), so nothing is "
              "pulled over the head."),
          _en("4 to 6 soft pyjamas or bottoms, with loose elastic."),
          _en("4 to 6 large muslin cloths (malmal). They work as a swaddle, a "
              "light cover, a burp cloth and a sunshade."),
          _en("In cooler months or cities: 2 or 3 caps, socks and mittens, "
              "and a warm layer or two."),
          _en("A light cotton blanket or wrap."),
        ],
        tip: PvReadTip(
          title: _en('How warm should my baby be?'),
          body: _en("As a rough guide, a baby needs about one more layer than "
              "you're wearing. In an Indian summer that may be only a thin "
              "vest and a muslin cloth. Feel the back of their neck: warm "
              "is right, sweaty means too many layers."),
        ),
      ),
      PvReadSection(
        heading: _en('Cloth or disposable nappies?'),
        paragraphs: [
          _en("Either is fine, and many families use both: cloth nappies "
              "(langot) at home in the day, and disposables at night or when "
              "you're out. A newborn goes through about 8 to 12 nappies a day "
              "in the first weeks."),
        ],
        bullets: [
          _en("If disposable: two or three small packs in newborn size to "
              "start. Buy more once you know which brand suits your baby's "
              "skin."),
          _en("If cloth: 20 to 30 cotton langots or cloth nappies, and a few "
              "waterproof covers."),
          _en("3 or 4 waterproof sheets (the rubber sheet many Indian homes "
              "call a mackintosh) to lay under the baby."),
          _en("Cotton wool or soft cloths and warm water for cleaning. Wipes "
              "are optional; choose unscented ones."),
          _en("A nappy cream if your doctor suggests one for a rash."),
        ],
      ),
      PvReadSection(
        heading: _en('Where will the baby sleep?'),
        paragraphs: [
          _en("Your baby needs a firm, flat place of their own, next to your "
              "bed. That can be a cot, a crib, a bassinet or a traditional "
              "wooden cradle (palna), as long as the mattress is firm, flat "
              "and fits well."),
        ],
        bullets: [
          _en("A firm, flat mattress that fits the cot with no gaps."),
          _en("3 or 4 fitted cotton sheets."),
          _en("A mosquito net that fits over the cot and can't fall onto the "
              "baby."),
          _en("Nothing else in the cot: no pillow, quilt, bumper or soft toy."),
        ],
      ),
      PvReadSection(
        heading: _en('What do we need for feeding?'),
        paragraphs: [
          _en("If you plan to breastfeed, you need very little. Your milk is "
              "made for your baby, and most help comes from people, not "
              "things."),
        ],
        bullets: [
          _en("2 or 3 nursing bras, bought in the last weeks of pregnancy."),
          _en("Breast pads for leaks."),
          _en("A pillow to support the baby at your breast. Pillows you "
              "already own often work."),
          _en("A few muslin cloths for burping."),
          _en("A big water bottle for you. Feeding makes you thirsty."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Pumps, bottles and formula'),
          body: _en("Most families don't need these before the birth. If you "
              "go back to work, your baby needs special care, or feeding "
              "needs support, your doctor or a lactation counsellor will "
              "help you choose what's right, and when."),
        ),
      ),
      PvReadSection(
        heading: _en('Bathing and everyday care'),
        bullets: [
          _en("A small tub or a clean basin. Many families bathe the baby on "
              "their legs with a bucket and mug, and that works well."),
          _en("2 or 3 soft cotton towels."),
          _en("Plain water is enough for the first few weeks. After that, a "
              "mild, unscented baby soap."),
          _en("Soft baby nail clippers or a nail file."),
          _en("A digital thermometer. It's one of the most useful things you "
              "can own."),
          _en("A mild detergent to wash baby clothes before first use."),
        ],
      ),
      PvReadSection(
        heading: _en('Getting about'),
        paragraphs: [
          _en("A baby carrier or sling keeps your baby close and your hands "
              "free, and it suits Indian lanes and stairs better than many "
              "prams. Choose one that holds the baby upright, facing you, "
              "with their knees higher than their bottom. You should always "
              "be able to see their face, and their chin should stay off "
              "their chest."),
          _en("If you drive, or will bring your baby home in a car, you need "
              "a car seat. It's the safe way to carry a baby in a car. A baby "
              "held in someone's arms can't be held on to in a sudden stop. "
              "The next read on this tab says how to choose and fit one."),
          _en("A pram or stroller is useful if you walk a lot on smooth "
              "pavements. It isn't a must, and a good one can often be "
              "borrowed."),
        ],
      ),
      PvReadSection(
        heading: _en("What if my family says not to buy before the birth?"),
        paragraphs: [
          _en("In many Indian families, it's the custom to wait until the "
              "baby is born before buying things. That comes from care, and "
              "it's easy to respect."),
          _en("You can still make your list now and choose what you'd like. "
              "A relative can buy the things after the birth, or keep them "
              "at their home until then. Only the car seat, if you need one, "
              "has to be ready before you leave hospital."),
          _en("Your hospital bag has its own list in ParentVeda. Look for "
              "Ready for Birth on this tab, so you only pack once."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('How many newborn-size clothes should we buy?'),
        answer: _en("Only a few. Many babies outgrow newborn size in two to "
            "four weeks, and some are too big for it from day one. Buy "
            "mostly 0 to 3 months."),
      ),
      PvReadFaq(
        question: _en('Do we need a breast pump before the baby comes?'),
        answer: _en("Usually not. If you need one later, your doctor or a "
            "lactation counsellor can help you choose, and many hospitals "
            "can lend one."),
      ),
      PvReadFaq(
        question: _en('Is a baby monitor needed?'),
        answer: _en("Not when the baby sleeps in your room, which is the "
            "advice for at least the first six months."),
      ),
      PvReadFaq(
        question: _en('Should we wash new baby clothes first?'),
        answer: _en("Yes. Wash them once in a mild detergent and rinse well, "
            "then dry them in the sun if you can."),
      ),
    ],
    evidence: _en('MoHFW, Home Based Newborn Care operational guidelines '
        '(2014) · WHO recommendations on maternal and newborn care for a '
        'positive postnatal experience (2022) · American Academy of '
        'Pediatrics, Sleep-related infant deaths: updated 2022 '
        'recommendations · NHS Start for Life, newborn care · UK Sling '
        'Consortium, the TICKS rule for safe babywearing · The Infant Milk '
        'Substitutes, Feeding Bottles, and Infant Foods Act, 1992.'),
    readNext: [
      'preg_ready_read_skip',
      'preg_ready_read_buying_safely',
      'preg_ready_read_home',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  What you can skip or borrow
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_skip',
    hue: _hue,
    kicker: _kBuy,
    title: _en('What you can skip or borrow'),
    teaser: _en("The things you won't miss, the things better borrowed, and "
        "the few things it's kinder to leave out altogether."),
    shortAnswer: _en("You can skip a separate nursery, a changing table, "
        "fancy gadgets and piles of newborn clothes. A cot, a pram and "
        "baby clothes are often easy to borrow. Leave out pillows, bumpers, "
        "baby powder, kajal and walkers, as doctors advise against them."),
    scaleSetter: _en("Most of what's sold for babies is nice to have, not "
        "needed. Spending less now leaves money for the things you'll find "
        "you want once you know your baby."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Baby shops, advertisements and well-meaning relatives can make "
            "it feel as if you need a room full of things. You don't. Most "
            "Indian babies sleep in their parents' room, are carried more "
            "than pushed, and are happiest close to you."),
        _en("This list is in three parts: what you can skip, what you can "
            "borrow, and what doctors advise leaving out."),
      ]),
      PvReadSection(
        heading: _en('What can we skip?'),
        bullets: [
          _en("A separate nursery. Your baby sleeps next to your bed for at "
              "least the first six months."),
          _en("A changing table. A waterproof mat on the bed or the floor "
              "works, and the floor is where a baby can't roll off."),
          _en("Lots of newborn-size clothes. Babies outgrow them in weeks."),
          _en("Shoes for a newborn. Soft socks keep feet warm until they walk."),
          _en("Wipe warmers, bottle warmers and most gadgets."),
          _en("A baby monitor, while the baby sleeps in your room."),
          _en("A big bath with a stand. A basin or a bucket bath on your legs "
              "works."),
          _en("Lots of toys. A newborn's favourite thing to look at is your "
              "face."),
          _en("Bottles, a steriliser and formula, if you plan to breastfeed. "
              "If you need them later, your doctor will help you choose."),
        ],
      ),
      PvReadSection(
        heading: _en('What can we borrow?'),
        paragraphs: [
          _en("Hand-me-downs from cousins and friends are a lovely Indian "
              "habit. These are usually fine to borrow, after a good clean "
              "and a check:"),
        ],
        bullets: [
          _en("Baby clothes, washed in a mild detergent."),
          _en("A cot or palna, if it passes the checks in \"Buying safely\" "
              "on this tab."),
          _en("A pram or stroller, if the brakes and straps work."),
          _en("A baby bath, a bouncer or a play mat."),
          _en("A carrier or sling, if the buckles and fabric are in good "
              "shape."),
        ],
        tip: PvReadTip(
          title: _en('Better bought new'),
          body: _en("A car seat you don't know the history of, a cot "
              "mattress, bottle teats, and a breast pump meant for one user. "
              "These can't be checked or cleaned well enough to share."),
        ),
      ),
      PvReadSection(
        heading: _en("What's better left out?"),
        paragraphs: [
          _en("Some things are sold for babies, or handed down with love, "
              "that doctors now advise against. You don't need to argue "
              "with anyone about them. You can leave them off your list."),
        ],
        bullets: [
          _en("Pillows, including the mustard seed pillow (rai ka takiya). "
              "Babies sleep safest with no pillow at all."),
          _en("Cot bumpers, sleep positioners and wedges. A baby's face can "
              "press into them."),
          _en("Heavy quilts and soft toys in the cot."),
          _en("Baby powder. The fine dust can be breathed in."),
          _en("Kajal or surma for the baby's eyes. Many contain lead, which "
              "harms a growing brain."),
          _en("A black thread, chain or necklace around the neck, especially "
              "during sleep."),
          _en("Baby walkers. Doctors' groups advise against them at any age, "
              "because of falls and injuries."),
        ],
        mythFact: PvMythFact(
          myth: _en("A baby needs a pillow for a nicely shaped head."),
          fact: _en("A baby should sleep flat on their back with no pillow. A "
              "flat patch on the head is usually prevented by tummy time "
              "while awake and by turning the baby's head a different way "
              "at each sleep."),
        ),
      ),
      PvReadSection(
        heading: _en("What will we be given anyway?"),
        paragraphs: [
          _en("In most Indian families, a new baby brings gifts. Before you "
              "buy, think about what usually arrives on its own:"),
        ],
        bullets: [
          _en("Clothes, often lots of them, in every size."),
          _en("Silver items, such as a bowl, spoon, glass or anklets."),
          _en("Blankets and quilts, many of them handmade. Keep these for "
              "cuddles and play mats, not for the cot."),
          _en("Soft toys, which are lovely to look at and best kept out of "
              "the cot."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we say no kindly?'),
        paragraphs: [
          _en("Much of this comes from grandparents who did these things for "
              "you, and you turned out fine. They're not wrong to care. The "
              "advice has changed because doctors now know more."),
          _en("A gentle way to put it: \"Our doctor asked us to keep the cot "
              "empty and skip the kajal. Can you help us with the massage "
              "instead?\" Giving someone a job they love often goes further "
              "than a no."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en("Is a second-hand cot okay?"),
        answer: _en("Often, yes, if it passes a few checks. \"Buying "
            "safely\" on this tab goes through them. Buy a new mattress for "
            "it."),
      ),
      PvReadFaq(
        question: _en('Is baby oil massage okay?'),
        answer: _en("Gentle massage is a warm tradition many families keep. "
            "Keep oil out of the nose, ears and eyes, and ask your baby's "
            "doctor which oil suits their skin."),
      ),
      PvReadFaq(
        question: _en('Do we need a pram?'),
        answer: _en("Not always. A sling or carrier works for most Indian "
            "homes and streets. If you walk a lot on smooth paths, a "
            "borrowed pram is a good choice."),
      ),
    ],
    evidence: _en('American Academy of Pediatrics, Sleep-related infant '
        'deaths: updated 2022 recommendations · AAP policy statement, Injuries '
        'associated with infant walkers · US Food and Drug Administration and AAP guidance on '
        'lead in kohl, kajal and surma · The Lullaby Trust, safer sleep advice '
        'on mattresses · US FDA guidance on sharing breast pumps · The Infant '
        'Milk Substitutes, Feeding Bottles, and Infant Foods Act, 1992.'),
    readNext: [
      'preg_ready_read_need',
      'preg_ready_read_buying_safely',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Buying safely
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_buying_safely',
    hue: _hue,
    kicker: _kBuy,
    title: _en('Buying safely: cots, cradles and car seats'),
    teaser: _en("What to check on a new or second-hand cot or palna, how to "
        "choose and fit a car seat, and getting home from hospital."),
    shortAnswer: _en("Choose a cot or cradle with a firm, flat mattress that "
        "fits snugly and bars close enough that a head can't pass through. "
        "If you'll use a car, a rear-facing baby car seat in the back is the "
        "safe way to carry your baby. Don't use a second-hand car seat unless "
        "you know it has never been in a crash."),
    scaleSetter: _en("Most cots and cradles in Indian homes are safe with a "
        "few checks, and most checks take five minutes. The car seat is the "
        "one thing worth buying new and fitting before the birth."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Where your baby sleeps and how they travel are the two buying "
            "choices that matter most for safety. Neither has to be "
            "expensive. Both are worth a few careful minutes."),
      ]),
      PvReadSection(
        heading: _en('What should I check on a cot?'),
        paragraphs: [
          _en("These checks work for a new cot, and for one handed down in "
              "the family:"),
        ],
        bullets: [
          _en("The gaps between the bars are no wider than about 6 cm. If a "
              "can of soft drink slides through, the gap is too wide."),
          _en("The mattress is firm and flat and fits snugly. You shouldn't "
              "be able to fit more than two fingers between the mattress and "
              "the side."),
          _en("No drop side that slides down. These have trapped babies."),
          _en("No cut-out shapes in the ends where a head or arm could get "
              "caught, and no tall corner posts that clothing could snag on."),
          _en("Every screw and joint is tight, with nothing loose, cracked or "
              "missing."),
          _en("The paint isn't peeling. Old paint on older furniture can "
              "contain lead."),
        ],
      ),
      PvReadSection(
        heading: _en('Is a palna or jhoola safe?'),
        paragraphs: [
          _en("A wooden cradle (palna) with a firm, flat base can be a safe "
              "place to sleep. Check it stands steady, can be stopped from "
              "swinging, and has sides high enough that the baby can't roll "
              "out. Stop using it once your baby can roll or push up."),
          _en("A cloth hammock or saree jhoola is different. The cloth "
              "curves, so the baby's chin can drop to their chest, which "
              "can make breathing harder. Use it for rocking while you "
              "watch, if you like, and move your baby to a flat surface to "
              "sleep."),
        ],
      ),
      PvReadSection(
        heading: _en('Why a car seat?'),
        paragraphs: [
          _en("A car seat is the safe way to carry a baby in a car. In a "
              "sudden stop, even at low speed, no one can hold on to a baby "
              "in their arms. A seat belt around you and the baby together "
              "is not safe either."),
          _en("For a newborn, you need a rear-facing infant seat, or a "
              "convertible seat that faces backwards. Babies ride facing the "
              "back for as long as their seat allows, because it protects "
              "the head and neck best."),
        ],
        bullets: [
          _en("Look for a seat certified to the European standard, marked "
              "ECE R44 or R129 (i-Size), on its label."),
          _en("Fit it in the back seat. Never put a rear-facing seat in "
              "front of an airbag."),
          _en("Fit it with ISOFIX points if your car has them, or with the "
              "seat belt exactly as the manual shows. Once fitted, it "
              "shouldn't move more than a couple of centimetres side to side."),
          _en("The straps sit flat and snug over the shoulders. No thick "
              "jacket or blanket under the straps; tuck a blanket over them "
              "instead."),
          _en("Fit it before your due date, and practise once or twice."),
        ],
      ),
      PvReadSection(
        heading: _en('Can we use a second-hand car seat?'),
        paragraphs: [
          _en("Only if you know its whole story, for example from a close "
              "friend or family member. Don't use one if any of these apply:"),
        ],
        bullets: [
          _en("It has been in a crash, even a small one."),
          _en("You don't know where it came from."),
          _en("It's past the expiry date on its label, or has no label."),
          _en("Any part, strap or the manual is missing, or the plastic is "
              "cracked."),
        ],
      ),
      PvReadSection(
        heading: _en('How will we get home from hospital?'),
        paragraphs: [
          _en("Plan this in the last weeks. If your family drives, fit the "
              "car seat before the birth. If you use a cab, you can carry "
              "your own car seat and fit it in the back."),
          _en("A newborn shouldn't travel on a scooter or motorbike. There's "
              "no safe way to hold a baby on a two-wheeler. Under the Janani "
              "Shishu Suraksha Karyakram, government hospitals offer free "
              "transport home for you and your baby after the birth, so ask "
              "about it before you're discharged."),
          _en("If you do travel in a car without a car seat, sit in the back, "
              "hold your baby close, and ask the driver to go slowly. It's "
              "not as safe as a car seat, which is why a seat is worth it if "
              "you'll be using a car."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('How long can a newborn stay in a car seat?'),
        answer: _en("A common guide is no more than two hours at a stretch. "
            "On long drives, stop, take the baby out, feed and change them."),
      ),
      PvReadFaq(
        question: _en('Can the baby sleep in the car seat at home?'),
        answer: _en("No. Once you're home, move your baby to a flat cot to "
            "sleep. Car seats keep a baby safe while travelling, not for "
            "sleep."),
      ),
      PvReadFaq(
        question: _en('Is an old family cot safe?'),
        answer: _en("Often it is, if it passes the checks above. Buy a new "
            "firm mattress that fits it well."),
      ),
      PvReadFaq(
        question: _en('Do car seats have to face forward in the front?'),
        answer: _en("No. A baby's seat goes in the back, facing the back. "
            "Never put it in the front seat if there is an airbag there."),
      ),
    ],
    evidence: _en('MoHFW, Janani Shishu Suraksha Karyakram (JSSK) guidelines '
        '(2011) on free drop-back transport · WHO, Global status report on '
        'road safety (2023), on child restraint systems · UN ECE Regulations '
        '44 and 129 (i-Size) · American Academy of Pediatrics, Car seats: '
        'information for families · US Consumer Product Safety '
        'Commission, full-size crib standard (16 CFR 1219) · British '
        'Standard BS EN 716 for cots.'),
    readNext: [
      'preg_ready_read_need',
      'preg_ready_read_home',
    ],
  ),

  // ===========================================================================
  //  HOME AND HELP
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Getting the home ready
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_home',
    hue: _hue,
    kicker: _kHome,
    title: _en('Getting your home ready'),
    teaser: _en("A safe sleep corner in your room, cleaning without harsh "
        "chemicals, and getting pets used to a baby."),
    shortAnswer: _en("You don't need a nursery. Make a safe sleep corner "
        "next to your bed: a firm, flat cot with nothing soft in it. Clean "
        "with mild soap and water and open windows, and keep smoke away from "
        "the home. Start getting any pets used to the change a few weeks "
        "ahead."),
    scaleSetter: _en("Getting ready is mostly a few small changes, not a "
        "renovation. Most of it can be done in a weekend, by someone other "
        "than you."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most Indian babies sleep in their parents' room, often in a "
              "home shared with grandparents. So getting ready is about one "
              "safe corner, a calm home, and a plan for everyone living "
              "there."),
        ],
        mythFact: PvMythFact(
          myth: _en("A newborn needs a pillow to sleep well and to shape the "
              "head."),
          fact: _en("A baby sleeps safest flat on their back, with no pillow. "
              "Tummy time while awake and changing which way the baby's "
              "head faces at each sleep help keep the head a good shape."),
        ),
      ),
      PvReadSection(
        heading: _en('What makes a safe sleep corner?'),
        paragraphs: [
          _en("Doctors recommend your baby sleeps in your room, in their own "
              "cot, for at least the first six months. This makes it easier "
              "to feed and settle them, and it's the safest way for a baby "
              "to sleep."),
        ],
        bullets: [
          _en("Put your baby down on their back for every sleep, day and "
              "night."),
          _en("A firm, flat mattress with a fitted sheet. Nothing else in "
              "the cot."),
          _en("Keep the cot away from windows, cords and curtains, and away "
              "from a heater or the direct blast of an AC or cooler."),
          _en("A fan to move the air is fine. Keep the room comfortable, "
              "not hot, and don't bundle the baby up."),
          _en("A fitted mosquito net is the safest guard against mosquitoes "
              "for a newborn."),
          _en("No smoking in the home, and no smoking near the baby. Ask "
              "visitors to smoke outside, far from the door."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If your baby will share your bed'),
          body: _en("Many Indian families sleep with their baby. If you do, "
              "keep the baby on their back, on a firm mattress, away from "
              "pillows and heavy quilts, and not between two adults. Don't "
              "share a bed if anyone in it smokes, has had alcohol or a "
              "medicine that makes them drowsy, or if your baby was born "
              "early or small. Never sleep with a baby on a sofa or chair."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I clean without harsh chemicals?'),
        paragraphs: [
          _en("Mild soap and water clean most things well enough for a baby. "
              "You don't need to disinfect the whole house, and strong "
              "fumes aren't good for you or a newborn."),
        ],
        bullets: [
          _en("Open windows while you clean, and while floors dry."),
          _en("Wear gloves for floor cleaners and phenyl, and use them "
              "diluted as the label says."),
          _en("Never mix bleach with other cleaners, such as toilet cleaners "
              "or ammonia. The mix gives off a gas that harms the lungs."),
          _en("Leave painting, pest control and deep cleaning to someone "
              "else, and stay out of the rooms until the smell has gone."),
          _en("Skip strong room fresheners and incense near where the baby "
              "will sleep."),
        ],
      ),
      PvReadSection(
        heading: _en('What about pets?'),
        paragraphs: [
          _en("Many families bring a baby home to a dog or a cat, and it "
              "usually goes well with some planning. Start a few weeks "
              "before the birth."),
        ],
        bullets: [
          _en("Take your pet to the vet for a check, and make sure "
              "vaccinations and deworming are up to date."),
          _en("Make changes to your pet's routine and sleeping place now, "
              "not the week the baby arrives."),
          _en("Let a dog get used to baby sounds and smells. Before you come "
              "home, someone can bring home a cloth the baby has worn."),
          _en("Keep pets out of the baby's cot and sleep space, always."),
          _en("Never leave a baby alone with a pet, even a gentle one, even "
              "for a minute."),
          _en("If you have a cat, ask someone else to clean the litter tray "
              "while you're pregnant. If you must, wear gloves and wash your "
              "hands well, as cat litter can carry an infection called "
              "toxoplasmosis."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the rest of the home?'),
        paragraphs: [
          _en("Babyproofing for crawling can wait until about six months. "
              "For now, a few small things help:"),
        ],
        bullets: [
          _en("A place to change nappies with everything in reach, so you "
              "never step away from the baby."),
          _en("A comfortable chair or corner for feeding, with a pillow, "
              "water and a phone charger."),
          _en("A low light for night feeds."),
          _en("Medicines, cleaners and small objects put high up, out of "
              "reach of any older children."),
          _en("Smoke-free rooms, and a working smoke alarm if you can get "
              "one."),
        ],
      ),
    ],
    whenToSeeSomeone: _homeCall,
    faqs: [
      PvReadFaq(
        question: _en('Can the baby sleep in the AC?'),
        answer: _en("Yes, at a comfortable temperature, with the cool air "
            "not blowing straight at the cot. Dress the baby in a thin "
            "layer and check they're warm, not cold or sweaty."),
      ),
      PvReadFaq(
        question: _en('Is a mosquito repellent safe for a newborn?'),
        answer: _en("For a newborn, a fitted net over the cot is the safest "
            "choice. Ask your baby's doctor before using any repellent on or "
            "near a young baby."),
      ),
      PvReadFaq(
        question: _en('Do we need to paint the room?'),
        answer: _en("No. If you'd like to, ask someone else to do it well "
            "before the birth, keep the windows open, and stay out until the "
            "smell has gone."),
      ),
      PvReadFaq(
        question: _en('Is it safe to keep our dog?'),
        answer: _en("Yes, for most families. Prepare your dog early, keep it "
            "out of the sleep space, and never leave the baby alone with it. "
            "Ask your vet if your dog has any behaviour worries."),
      ),
    ],
    evidence: _en('American Academy of Pediatrics, Sleep-related infant '
        'deaths: updated 2022 recommendations · NHS and The Lullaby Trust, '
        'safer sleep and bed-sharing advice · ACOG Committee Opinion 832, '
        'Reducing prenatal exposure to toxic environmental agents (2021) · '
        'CDC, Toxoplasmosis and pregnancy · WHO, Tobacco and second-hand '
        'smoke.'),
    readNext: [
      'preg_ready_read_nesting',
      'preg_ready_read_last_months',
      'preg_ready_read_buying_safely',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Nesting, safely
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_nesting',
    hue: _hue,
    kicker: _kHome,
    title: _en('Nesting: getting ready, safely'),
    teaser: _en("Why you might suddenly want to clean and sort everything, "
        "and how to do it without ladders, lifting or strong fumes."),
    shortAnswer: _en("The urge to clean, sort and get everything ready "
        "(nesting) is common in the last weeks of pregnancy. Enjoy it, but "
        "hand over the ladders, the heavy lifting and the strong cleaners. "
        "Work in short bursts, sit when you can, and rest often."),
    scaleSetter: _en("Nesting is a normal part of late pregnancy for many "
        "women, and some don't feel it at all. Either way is fine, and "
        "neither says anything about when labour will start."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("One day you may find yourself folding tiny clothes at midnight, "
            "or wanting every cupboard emptied and scrubbed. Many women feel "
            "this strong pull to get the home ready, usually in the last "
            "weeks of pregnancy. It has a name: nesting."),
        _en("It can feel good to get things done. The aim is to do it in a "
            "way that keeps you and your baby safe, and leaves you with "
            "energy for the birth."),
      ]),
      PvReadSection(
        heading: _en('Why does it happen?'),
        paragraphs: [
          _en("No one knows exactly. It's likely a mix of hormones, a natural "
              "wish to protect your baby, and a very real list of jobs to "
              "finish. In India it often comes at the same time as festival "
              "cleaning or a move to your mother's home, which adds to the "
              "list."),
          _en("Some women notice a burst of energy in the days before "
              "labour. It isn't a reliable sign, though, and nesting on its "
              "own doesn't mean labour is near."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I hand over?'),
        paragraphs: [
          _en("Your balance changes as your bump grows, and your joints are "
              "looser in pregnancy. So some jobs are better given to "
              "someone else:"),
        ],
        bullets: [
          _en("Anything on a ladder, stool or chair, like dusting fans, "
              "changing bulbs or reaching the top shelf."),
          _en("Moving furniture, lifting heavy buckets, gas cylinders, water "
              "cans or full suitcases."),
          _en("Painting, varnishing and pest control."),
          _en("Scrubbing with bleach, acid toilet cleaners or strong floor "
              "cleaners."),
          _en("Cleaning the cat's litter tray."),
          _en("Diwali or festival cleaning that means hours of bending, "
              "climbing or dust."),
        ],
      ),
      PvReadSection(
        heading: _en('What can I do safely?'),
        bullets: [
          _en("Sort and wash baby clothes, sitting down."),
          _en("Make lists: what to buy, what to pack, who to call."),
          _en("Set up the sleep corner once someone has moved the cot into "
              "place."),
          _en("Pack your hospital bag, with the Ready for Birth list in "
              "ParentVeda."),
          _en("Cook and freeze a few simple meals for the first weeks, if "
              "your family would like that."),
          _en("Sort papers: your reports, ID and insurance, in one folder."),
          _en("Wipe surfaces with mild soap and water, with the windows open."),
        ],
        tip: PvReadTip(
          title: _en('Short bursts'),
          body: _en("Work for 20 or 30 minutes, then sit with your feet up "
              "and drink some water. Bend your knees, not your back, and "
              "keep anything you lift close to your body."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I look after my body while I do it?'),
        paragraphs: [
          _en("In the last months your body is carrying a lot, and it tires "
              "faster than it used to. Small changes help you keep going "
              "without paying for it later."),
        ],
        bullets: [
          _en("Drink water often, more in the heat. Keep a bottle in each "
              "room you're working in."),
          _en("Eat something every few hours. A handful of nuts, a fruit or "
              "a roti keeps your energy steady."),
          _en("Sit for any job you can do sitting: folding, sorting, "
              "chopping, packing."),
          _en("If your feet swell, put them up for a while. Swelling that "
              "comes on suddenly, or is in your face or hands, needs a call "
              "to your doctor."),
          _en("If your back aches, stop and rest on your side with a pillow "
              "between your knees."),
          _en("Keep the late evenings for rest. Tired women sleep badly, and "
              "sleep matters more than a tidy cupboard."),
        ],
      ),
      PvReadSection(
        heading: _en('How can the family help?'),
        paragraphs: [
          _en("Nesting is easier as a team. Make a list of the jobs and let "
              "people choose. Many family members like being given a clear "
              "task, and it lets them feel part of getting ready."),
          _en("Your partner can take the heavy and high jobs, fit the car "
              "seat and set up the cot. Grandparents may love sorting the "
              "baby clothes or teaching you the family way of wrapping a "
              "baby. You get to be in charge of the list."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I can't stop?"),
        paragraphs: [
          _en("Sometimes the urge to get everything ready tips into worry. "
              "You may feel you can't rest until it's perfect, or lie awake "
              "running through lists."),
          _en("Some worry is normal before a baby. If it's taking over your "
              "days or your sleep, tell your doctor, or look at the Mind and "
              "mood section in ParentVeda. Tele-MANAS, the government's free "
              "mental health helpline, answers day and night on 14416."),
          _en("And if you don't feel any urge to nest, that's fine too. It "
              "doesn't mean you're less ready or less excited."),
        ],
      ),
    ],
    whenToSeeSomeone: _homeCall,
    faqs: [
      PvReadFaq(
        question: _en('Is it safe to climb stairs?'),
        answer: _en("Yes, for most women. Hold the rail, take your time, and "
            "don't carry heavy things up and down."),
      ),
      PvReadFaq(
        question: _en('Can I squat and mop the floor?'),
        answer: _en("If it's comfortable and you feel steady, yes. Use a mop "
            "with a long handle when your bump makes squatting hard, and "
            "stop if anything hurts."),
      ),
      PvReadFaq(
        question: _en('Does nesting mean labour is coming?'),
        answer: _en("Not reliably. Watch for the real signs of labour, which "
            "the Labour prep section explains, and call your hospital when "
            "they start."),
      ),
      PvReadFaq(
        question: _en('Is washing baby clothes by hand safe?'),
        answer: _en("Yes. Use a mild detergent, rinse well, and sit on a "
            "stool rather than bending over a bucket for long."),
      ),
    ],
    evidence: _en('ACOG Committee Opinion 832, Reducing prenatal exposure to '
        'toxic environmental agents (2021) · NHS, Your pregnancy and baby '
        'guide: back pain and lifting · CDC, Toxoplasmosis and pregnancy · '
        'Tele-MANAS, National Tele Mental Health Programme, MoHFW (2022).'),
    readNext: [
      'preg_ready_read_home',
      'preg_ready_read_last_months',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  The last three months: a to-do list
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_last_months',
    hue: _hue,
    kicker: _kHome,
    title: _en('Your last three months: a simple to-do list'),
    teaser: _en("The jobs worth doing before the birth, from choosing your "
        "baby's doctor to sorting the hospital papers."),
    shortAnswer: _en("In the last three months, choose where you'll give "
        "birth and your baby's doctor, sort your papers and insurance, plan "
        "how you'll get to hospital, and pack your bag by about 36 weeks. "
        "Plan who will help after the birth. A little each week is enough."),
    scaleSetter: _en("This is a list to pick from, not a test. Some of it "
        "your hospital or family will already have done, and some babies "
        "come before the list is finished. That's fine."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("The third trimester runs from week 28 to the birth. You'll see "
            "your doctor more often now, and there's a lot to think about. "
            "Doing one or two jobs a week keeps it calm."),
      ]),
      PvReadSection(
        heading: _en('From about 28 weeks'),
        bullets: [
          _en("Confirm where you'll give birth, and find out what happens "
              "when you arrive, by day and at night."),
          _en("Choose your baby's doctor (a paediatrician) or clinic. Ask "
              "whether they see babies in your hospital, and where your baby "
              "will get their vaccines. The first vaccines are given at "
              "birth, usually before you go home."),
          _en("If you're working, check your leave with your HR. Under the "
              "Maternity Benefit Act, 1961, you may be entitled to up to 26 "
              "weeks of paid leave, of which up to 8 can be before the birth."),
          _en("If you're going to your mother's home for the birth, plan "
              "when to travel with your doctor, and arrange care at a "
              "hospital there."),
          _en("Start thinking about who will help after the birth. The read "
              "\"Planning help for the first 40 days\" can help."),
        ],
      ),
      PvReadSection(
        heading: _en('From about 32 weeks'),
        bullets: [
          _en("Put your papers in one folder: ID for you both, your antenatal "
              "card (the Mother and Child Protection card, if you have one), "
              "your scan and blood reports, and your insurance card."),
          _en("If you have health insurance, call your insurer or its TPA. "
              "Ask what the policy covers for the birth and the newborn, and "
              "how pre-authorisation for a cashless stay works."),
          _en("If you're giving birth in a government hospital, ask your "
              "ASHA, ANM or the hospital about schemes you may be entitled "
              "to, such as the Janani Suraksha Yojana and PMMVY."),
          _en("Ask the hospital how they register the birth, and what they "
              "need from you."),
          _en("Think through a birth plan. The Labour prep section has one "
              "you can fill in and share."),
        ],
      ),
      PvReadSection(
        heading: _en('From about 36 weeks'),
        bullets: [
          _en("Have your hospital bag packed. The Ready for Birth list in "
              "ParentVeda covers you, the baby, your papers and whoever comes "
              "with you."),
          _en("Plan the ride to hospital, day and night, and a back-up. Save "
              "108 for emergencies. In many states, 102 is the free "
              "ambulance for pregnant women."),
          _en("Save your doctor's and hospital's numbers in your phone and "
              "your partner's, and on paper by the door."),
          _en("If you'll use a car, fit the baby's car seat."),
          _en("Set up the baby's sleep corner, and wash the baby clothes."),
          _en("Stock the kitchen with simple food, and some of the "
              "traditional foods your family makes after a birth, if you'd "
              "like them."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask at my visits now?'),
        paragraphs: [
          _en("Your antenatal visits come closer together in these months. "
              "They're a good time to ask the practical questions, so you "
              "know what to do when the day comes. You might ask:"),
        ],
        bullets: [
          _en("How will I know labour has started, and when should I come "
              "in?"),
          _en("What should I do if my waters break, or I bleed?"),
          _en("Who do I call at night or on a holiday, and which entrance "
              "do I use?"),
          _en("Can someone stay with me during the birth, and after?"),
          _en("How long will we stay in hospital after a normal birth, or a "
              "caesarean?"),
        ],
      ),
      PvReadSection(
        heading: _en('What about feeding?'),
        paragraphs: [
          _en("Breastfeeding comes more easily with a little knowledge "
              "before the birth. Ask your hospital if they run an antenatal "
              "class, or read the feeding pages in the Labour prep section."),
          _en("Ask the hospital if your baby can stay with you after the "
              "birth, skin to skin, and be fed within the first hour. Most "
              "hospitals in India now encourage this. Knowing the plan ahead "
              "helps you both ask for it."),
        ],
      ),
      PvReadSection(
        heading: _en('And for you'),
        paragraphs: [
          _en("Rest when you can. Say no to one or two things. Spend some "
              "time as a couple before the baby comes, even if it's a walk "
              "in the evening. Everything on this list matters less than "
              "arriving at the birth rested."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('When should I pack my hospital bag?'),
        answer: _en("By about 36 weeks, or earlier if your doctor expects an "
            "early birth. Ready for Birth has the full list."),
      ),
      PvReadFaq(
        question: _en('Do we need to choose the paediatrician before the '
            'birth?'),
        answer: _en("It helps. The hospital's doctor will check your baby "
            "at birth, but knowing who you'll see afterwards makes the first "
            "weeks easier."),
      ),
      PvReadFaq(
        question: _en('What if the baby comes early?'),
        answer: _en("Then the list waits. The hospital will look after you "
            "both, and your family can bring what you need."),
      ),
    ],
    evidence: _en('MoHFW, Mother and Child Protection card; Janani Suraksha '
        'Yojana; Janani Shishu Suraksha Karyakram (2011); Pradhan Mantri '
        'Matru Vandana Yojana · The Maternity Benefit Act, 1961 (as amended '
        'in 2017) · MoHFW, Universal Immunisation Programme schedule · WHO '
        'recommendations on antenatal care for a positive pregnancy '
        'experience (2016) · WHO and UNICEF, early initiation of '
        'breastfeeding.'),
    readNext: [
      'preg_ready_read_help',
      'preg_ready_read_home',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Planning help for the first 40 days
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_help',
    hue: _hue,
    kicker: _kHome,
    title: _en('Planning help for the first 40 days'),
    teaser: _en("Going to your mother's home, hiring a japa maid or a "
        "nanny, and sharing the nights, planned before the baby comes."),
    shortAnswer: _en("Decide now who will help in the first 40 days and "
        "where you'll stay. If you hire a japa maid or nanny, check their "
        "experience and references, and agree how they'll care for the "
        "baby. Plan how the two of you will share nights, so you both get "
        "some sleep."),
    scaleSetter: _en("The weeks after a birth are hard for everyone, even "
        "with lots of help. Planning ahead doesn't make them easy, but it "
        "makes them kinder, and you won't be deciding while exhausted."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Across India, the first 40 days after a birth are a time set "
            "aside for rest. Families call it by many names, such as sawa "
            "mahina, jaapa or the confinement. The idea is sound: your body "
            "needs about six weeks to recover, and a newborn needs feeding "
            "day and night."),
        _en("Help makes the biggest difference. The time to plan it is now."),
      ]),
      PvReadSection(
        heading: _en('Where will we stay?'),
        paragraphs: [
          _en("Many women go to their mother's home for the birth and the "
              "weeks after, especially the first time. It can be a lovely "
              "time of being cared for. It also needs some planning:"),
        ],
        bullets: [
          _en("Talk to your doctor about when it's safe to travel, and "
              "arrange care at a hospital near your mother's home well "
              "before your due date."),
          _en("Take copies of all your reports, and ask your doctor for a "
              "short summary letter."),
          _en("Plan how the baby's father will be part of the first weeks. "
              "Visits, video calls and time holding the baby help him bond, "
              "too."),
          _en("Plan the return home: when, how, and who will help there."),
        ],
      ),
      PvReadSection(
        heading: _en('Who will do what?'),
        paragraphs: [
          _en("Whether help is family, a paid helper or both, it's easier "
              "when jobs are clear. A simple plan might look like this:"),
        ],
        bullets: [
          _en("You: feeding the baby, resting, and healing."),
          _en("Your partner: nappies, burping, settling, and bringing you "
              "water and food."),
          _en("Grandparents or family: cooking, laundry, and holding the "
              "baby so you can sleep."),
          _en("A helper, if you hire one: the baby's bath and massage, "
              "washing, and help with your meals."),
        ],
        tip: PvReadTip(
          title: _en('Visitors'),
          body: _en("It's fine to limit visitors in the first weeks. Ask "
              "people with a cough, cold or fever to wait. Ask everyone to "
              "wash their hands before holding the baby."),
        ),
      ),
      PvReadSection(
        heading: _en('Hiring a japa maid or a nanny'),
        paragraphs: [
          _en("A japa maid cares for the mother and the newborn in the first "
              "weeks, often with massage, baths and cooking. A nanny looks "
              "after the baby, usually for longer. Before you hire, ask:"),
        ],
        bullets: [
          _en("How many newborns have you cared for? Can I call two families "
              "you worked for?"),
          _en("Are you well, and are your vaccines up to date? Will you wash "
              "your hands before touching the baby?"),
          _en("Will you follow our doctor's advice, even when it's different "
              "from how you usually do things?"),
          _en("What hours, which days off, and what pay? Will you stay at "
              "night?"),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Agree these before day one'),
          body: _en("The baby sleeps on their back in their own cot. Nothing "
              "but breast milk (or formula, if your doctor has advised it): "
              "no honey, water, ghutti or gripe water. No kajal, no powder, "
              "no oil in the nose or ears, and no pressing or shaping the "
              "baby's head or nose. Many city police stations offer "
              "verification for domestic workers; ask at yours."),
        ),
      ),
      PvReadSection(
        heading: _en('What about my own recovery?'),
        paragraphs: [
          _en("Plans often focus on the baby. Plan for yourself too. Your "
              "body needs good food, water, rest and time, whether the birth "
              "was normal or a caesarean."),
          _en("Ask your family to keep meals simple, warm and regular, with "
              "dal, vegetables, fruit and enough water, as well as any "
              "traditional foods you enjoy. Keep taking the iron and calcium "
              "your doctor prescribed for as long as they advise. Book your "
              "own check-up about six weeks after the birth, alongside the "
              "baby's vaccine visits."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we share the nights?'),
        paragraphs: [
          _en("Newborns wake every two to three hours to feed, day and night. "
              "No one can do that alone for long."),
          _en("Some couples take shifts. One sleeps in another room for a "
              "stretch of four or five hours while the other settles the "
              "baby and brings them to you to feed. Others split the jobs: "
              "you feed, your partner changes and settles. Try one way for a "
              "week and change what doesn't work."),
          _en("Sleep when the baby sleeps, at least once a day. The dishes "
              "can wait."),
        ],
      ),
      PvReadSection(
        heading: _en('How will we know if I need more help?'),
        paragraphs: [
          _en("Feeling weepy and up and down in the first two weeks is very "
              "common (the baby blues). If low mood, worry or feeling unable "
              "to cope lasts longer than two weeks, or gets worse, tell your "
              "doctor. It's common and it's treatable."),
          _en("Your ASHA may visit you and the baby at home in the first six "
              "weeks. She's there to help, and you can ask her anything."),
        ],
      ),
    ],
    whenToSeeSomeone: _afterBirthCall,
    faqs: [
      PvReadFaq(
        question: _en("Is it okay not to follow every confinement custom?"),
        answer: _en("Yes. Rest, good food and help are the heart of it. "
            "Bathing, washing your hair and short walks are safe after a "
            "normal birth; ask your doctor about anything you're unsure of."),
      ),
      PvReadFaq(
        question: _en('What should a japa maid not do?'),
        answer: _en("Give the baby anything but milk, put anything in the "
            "baby's eyes, nose or ears, or massage roughly. Agree this "
            "kindly on the first day."),
      ),
      PvReadFaq(
        question: _en('My partner is going back to work soon. What helps?'),
        answer: _en("Ask about paternity leave, and plan the first two weeks "
            "together. After that, even an hour with the baby each evening "
            "gives you rest."),
      ),
      PvReadFaq(
        question: _en('We have no family nearby. What can we do?'),
        answer: _en("Line up paid help, friends who can bring food, and an "
            "online grocery plan. Ask your hospital about a lactation "
            "counsellor you can call."),
      ),
    ],
    evidence: _en('MoHFW, Home Based Newborn Care operational guidelines '
        '(2014), on ASHA home visits in the first six weeks · WHO '
        'recommendations on maternal and newborn care for a positive '
        'postnatal experience (2022) · WHO, Exclusive breastfeeding for six '
        'months · American Academy of Pediatrics, Sleep-related infant '
        'deaths: updated 2022 recommendations · Tele-MANAS, MoHFW (2022).'),
    readNext: [
      'preg_ready_read_older_child',
      'preg_ready_read_last_months',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Preparing an older child
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_older_child',
    hue: _hue,
    kicker: _kHome,
    title: _en('Getting an older child ready for the baby'),
    teaser: _en("When and how to tell them, keeping their world steady, and "
        "the first days together."),
    shortAnswer: _en("Tell your older child in simple words, closer to the "
        "birth for a toddler and earlier for an older child. Keep their "
        "routine steady, plan who will look after them during the birth, "
        "and give them time that's only theirs. Going back to baby "
        "habits for a while is normal."),
    scaleSetter: _en("Most children take a new baby in their stride within "
        "a few months. Some jealousy, clinginess or baby talk along the way "
        "is part of it, not a sign anything is wrong."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("A new baby changes your older child's world too. They may be "
            "excited, worried, or both in the same afternoon. A little "
            "preparing makes the change feel safer for them."),
      ]),
      PvReadSection(
        heading: _en('When should we tell them?'),
        paragraphs: [
          _en("It depends on their age. Young children have little sense of "
              "time, so nine months is a long wait."),
        ],
        bullets: [
          _en("Under three: tell them once the bump shows, and talk about it "
              "more in the last couple of months."),
          _en("Three to five: tell them in the middle of the pregnancy. Link "
              "the birth to a season or a festival they know."),
          _en("Older children: tell them early, before they hear it from "
              "someone else."),
        ],
        tip: PvReadTip(
          title: _en('Simple words'),
          body: _en("\"There's a baby growing in Mummy's tummy. The baby will "
              "come after Diwali. You'll be a big sister.\" Answer their "
              "questions honestly and briefly."),
        ),
      ),
      PvReadSection(
        heading: _en('How can we help them get ready?'),
        bullets: [
          _en("Read picture books about a new baby together."),
          _en("Look at their own baby photos and tell them stories about "
              "when they were small."),
          _en("Let them help: choose a soft toy for the baby, fold tiny "
              "clothes, or help pick a song."),
          _en("If they know a baby in the family, visit together."),
          _en("Make big changes, like a new school, toilet training or "
              "moving to their own bed, a few months before the birth or a "
              "few months after, not in the same weeks."),
        ],
      ),
      PvReadSection(
        heading: _en('Who will look after them during the birth?'),
        paragraphs: [
          _en("Plan this early, and have a back-up, because babies don't "
              "keep to dates. Tell your child who will be with them, where "
              "they'll sleep, and that you'll be back."),
          _en("If you're going to your mother's home, think about whether "
              "your older child comes too. Ask your family which is easier, "
              "and what your child would like."),
          _en("A practice run helps. A night or two with the person who "
              "will look after them, a few weeks before your due date, makes "
              "the real night feel familiar. Pack a small bag for them too, "
              "with a favourite toy, a photo of you and clothes for two or "
              "three days."),
        ],
      ),
      PvReadSection(
        heading: _en('The first days together'),
        bullets: [
          _en("Let their first meeting with the baby be calm. If you can, "
              "have your arms free for a hug when they walk in."),
          _en("A small gift \"from the baby\" can help."),
          _en("Ask visitors to greet your older child first, and to bring "
              "attention, not only gifts, for them too."),
          _en("Give them 15 minutes a day that's only theirs, doing what "
              "they choose."),
          _en("Let them help, but never leave them alone with the baby. "
              "Young children may try to pick up the baby, or give them food "
              "or small toys."),
        ],
      ),
      PvReadSection(
        heading: _en('What about feeding times?'),
        paragraphs: [
          _en("Feeds can be when an older child feels most left out. The "
              "baby is in your arms, and you can't get up."),
          _en("A feeding basket helps: a few books, a small snack, a "
              "drink and a quiet toy that only comes out while you feed. "
              "Read to your older child, sing, or let them tell you about "
              "their day. Feeding time can become their time with you too."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we keep their world steady?'),
        paragraphs: [
          _en("Children feel safe when the day looks the same. Keep "
              "bedtime, meals, school and play as close to usual as you can, "
              "even if someone else is doing them for a while."),
          _en("Grandparents, aunts and uncles can help a lot here. Ask them "
              "to take your older child to the park, or keep a special "
              "outing going, rather than spending every visit with the "
              "baby. And tell your child's teacher or daycare about the new "
              "baby, so they can be gentle if your child seems unsettled."),
        ],
      ),
      PvReadSection(
        heading: _en("What if they go back to baby ways?"),
        paragraphs: [
          _en("Wetting again, wanting a bottle, baby talk or tantrums are "
              "common. It's their way of asking, \"Do you still love me?\" "
              "Answer that with cuddles and time, not scolding."),
          _en("Let them talk about all their feelings, even \"I don't like "
              "the baby.\" Saying it out loud is how they work through it. "
              "Most of these habits fade in a few weeks to months."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('Should my child visit me in hospital?'),
        answer: _en("If the hospital allows it and your child is well, a "
            "short visit can help. Ask the ward about their rules for "
            "children."),
      ),
      PvReadFaq(
        question: _en('What if they say they hate the baby?'),
        answer: _en("That's a normal feeling. Say, \"It's hard sharing "
            "Mummy, isn't it?\" and give them a cuddle. Feelings said out "
            "loud tend to pass."),
      ),
      PvReadFaq(
        question: _en("When should I talk to their doctor?"),
        answer: _en("If changes in sleep, eating or behaviour last for "
            "months, or worry you, their paediatrician can help."),
      ),
    ],
    evidence: _en('American Academy of Pediatrics (HealthyChildren.org), '
        'Preparing your family for a new baby · NHS, Siblings and a new '
        'baby · UNICEF, Parenting guidance on a new sibling.'),
    readNext: [
      'preg_ready_read_help',
      'preg_ready_read_last_months',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Godh bharai
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_ready_read_godh_bharai',
    hue: _hue,
    kicker: _kHome,
    title: _en('Godh bharai and baby showers'),
    teaser: _en("When families hold it, keeping the day comfortable for you, "
        "and what to ask your guests for."),
    shortAnswer: _en("Godh bharai, seemantham, valaikappu and similar "
        "ceremonies bless you and your baby before the birth. Many families "
        "hold them in the seventh month. Keep the day short and "
        "comfortable, sit with support, eat and drink, and step away to rest "
        "when you need to."),
    scaleSetter: _en("It's your day. Enjoy the parts you love, and it's "
        "fine to keep it small, move it, or skip parts that tire you."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Across India, families celebrate a mother before the birth. In "
            "the north it's the godh bharai, filling your lap with fruit, "
            "sweets and blessings. In the south there's the seemantham and "
            "the valaikappu, with glass bangles. Bengali families hold the "
            "shaadh, and Maharashtrian families the dohale jevan."),
        _en("The names and rituals differ. The heart is the same: the women "
            "of the family gather to bless you and your baby."),
      ]),
      PvReadSection(
        heading: _en('When is it usually held?'),
        paragraphs: [
          _en("Many families hold it in the seventh month. Some choose the "
              "fifth, eighth or ninth, or an auspicious day the family priest "
              "suggests. Your family's custom decides."),
          _en("From a comfort point of view, the seventh or early eighth "
              "month often works well. You're past the tiredness of the "
              "early weeks, and not yet at the heaviest stage. If your "
              "doctor has asked you to rest, or your pregnancy needs extra "
              "care, ask them before you plan the date."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I keep the day comfortable?'),
        bullets: [
          _en("Keep it to two or three hours. Morning is often cooler."),
          _en("Sit on a chair or a low sofa with back support, rather than "
              "on the floor for long."),
          _en("Choose a light saree or outfit you can breathe in. Loose "
              "bangles and light jewellery are kinder on swollen hands."),
          _en("Eat a proper meal and keep water close. Say yes to sweets, "
              "and choose freshly cooked food."),
          _en("Sit away from the smoke of lamps, incense or a havan, and "
              "keep a fan or AC running."),
          _en("Have a quiet room ready where you can lie on your side for a "
              "while."),
          _en("Ask guests with a cough, cold or fever to send their "
              "blessings from home."),
        ],
      ),
      PvReadSection(
        heading: _en('What can we ask guests for?'),
        paragraphs: [
          _en("Gifts at a godh bharai are often for you: sarees, fruit, "
              "dry fruits and sweets, sometimes gold or cash. It's fine to "
              "tell close family what would help most."),
        ],
        bullets: [
          _en("Things from your list of what you need, so you don't get five "
              "of the same thing."),
          _en("A home-cooked meal in the first weeks after the birth."),
          _en("Time: an afternoon of help, a night of holding the baby, or a "
              "ride to a check-up."),
          _en("Hand-me-downs from cousins, cleaned and checked."),
        ],
        tip: PvReadTip(
          title: _en('Share one list'),
          body: _en("One family member can keep the list and tell guests what "
              "is already covered. It saves you the awkward part."),
        ),
      ),
      PvReadSection(
        heading: _en('What about the food?'),
        paragraphs: [
          _en("Food is part of the blessing. Families often cook your "
              "favourite dishes, and some make seven or nine kinds of sweets "
              "or rice dishes."),
          _en("Enjoy them. Choose food that's freshly cooked and served "
              "hot, and skip anything made with unboiled milk, raw sprouts "
              "or food that has sat out in the heat for hours. If you're "
              "managing sugar in pregnancy (gestational diabetes), have a "
              "small taste of the sweets with your meal, and ask your "
              "doctor or dietitian how to plan the day."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we plan it without tiring me out?'),
        paragraphs: [
          _en("Let someone else be the organiser. A sister, cousin or "
              "mother-in-law can keep the guest list, book the cook, and "
              "sort the flowers and the priest. Your jobs are to choose "
              "what matters to you and to turn up."),
          _en("Agree on an end time, and a signal that you're tired. It's "
              "fine to leave the photos and the last guests to others. If "
              "your family lives far away, a video call for the rituals lets "
              "everyone share the moment."),
        ],
      ),
      PvReadSection(
        heading: _en('What if we want something different?'),
        paragraphs: [
          _en("Some couples hold a small dinner with friends, a virtual "
              "gathering for family abroad, or a baby shower in the Western "
              "style. All are fine, and many families blend the two."),
          _en("Many families now include the baby's father too, with a "
              "blessing, a gift or a place beside you for the rituals. If "
              "that would mean something to you both, ask the elders "
              "planning the day. Most are happy to make room for it."),
          _en("If you've lost a pregnancy before, you may feel unsure about "
              "celebrating before the birth. Some families wait, keep it "
              "very small, or hold a blessing after the baby comes. Do what "
              "feels right to you."),
        ],
      ),
    ],
    whenToSeeSomeone: _signs,
    faqs: [
      PvReadFaq(
        question: _en('Is it safe to travel to my in-laws for the ceremony?'),
        answer: _en("Usually, in the middle of pregnancy. Ask your doctor "
            "before long journeys, especially after 28 weeks, and carry your "
            "reports."),
      ),
      PvReadFaq(
        question: _en('Can I skip the ceremony?'),
        answer: _en("Yes. Talk it over with your family. A small blessing at "
            "home or after the birth means just as much."),
      ),
      PvReadFaq(
        question: _en('I feel faint in crowds. What helps?'),
        answer: _en("Sit near a window or fan, drink water, eat something, "
            "and step out for fresh air. If you faint, call your doctor."),
      ),
    ],
    evidence: _en('Family and regional customs as practised across India. '
        'The comfort advice follows WHO recommendations on antenatal care '
        'for a positive pregnancy experience (2016) and NHS guidance on '
        'fainting and overheating in pregnancy.'),
    readNext: [
      'preg_ready_read_need',
      'preg_ready_read_naming_customs',
    ],
  ),
];

/// A read in this file by id, or null.
PvRead? readyReadById(String id) {
  for (final r in kPregnancyReadsReady) {
    if (r.id == id) return r;
  }
  return null;
}
