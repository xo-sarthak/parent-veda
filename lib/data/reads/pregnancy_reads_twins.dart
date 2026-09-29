// =============================================================================
//  Twins and more (pregnancy) — the reads behind the door
// -----------------------------------------------------------------------------
//  Added 2026-09-29 from the pregnancy gap analysis (Flo / What to Expect vs
//  ParentVeda), "New section: Twins and more", P3: *"Carrying twins: types of
//  twins, extra scans, weight and food, how twins are delivered, getting
//  ready for two."* The door is `lib/data/doors/pv_door_twins.dart`; every
//  read here sits on one of its tiles, and `test/pv_door_twins_test.dart`
//  holds that.
//
//  Beyond `docs/PREG-VOICE.md`:
//
//  · Population facts only. "More common with twins" is a statement about
//    twin pregnancies; no sentence puts "your" beside a chance word
//    (`test/pregnancy_reads_shape_test.dart` scans for exactly that).
//  · Her doctor sets the plan. Scan schedules and birth timing are given as
//    what the guidelines usually suggest, and every one defers to her own
//    doctor. We explain, remind and help her prepare; we never set a date.
//  · Nothing about the babies' sex, in any form (PCPNDT Act). That rules out
//    even the true, harmless-looking facts about which twins share a sex.
//  · The condition pages ("Preeclampsia", "Preterm labour"), the "Twin
//    Pregnancy" report word and Nutrition's "Carrying twins" guide keep their
//    facts; these reads agree with them and refer to them by name.
//  · `reviewed: false`, ParentVeda editorial, until a doctor has read them.
//
//  Not yet spread into `kPregnancyReads`: the lead does that in
//  `pregnancy_reads.dart`, one line.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, as in the other pregnancy reads files.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

const double _hue = 322;

final LocalizedText _desk = _en('ParentVeda editorial');
final LocalizedText _deskRole = _en('Twins and more');

final LocalizedText _kCarrying = _en('Carrying twins');
final LocalizedText _kCare = _en('Your care');
final LocalizedText _kBirth = _en('The birth');
final LocalizedText _kTwo = _en('Getting ready for two');

/// The signs, in one place so they can't drift apart between reads. Agrees
/// with the door's pinned flag, the "Preterm labour" and "Preeclampsia"
/// condition pages, and the movement lines in the scan reads.
final PvCallout _twinsUrgent = PvCallout(
  tone: PvCalloutTone.urgent,
  title: _en('When to call your doctor or go to hospital'),
  body: _en("Go to hospital straight away for any bleeding from the vagina, "
      "or a severe headache with blurred vision or flashing lights, pain "
      "under your ribs, or sudden swelling of your face or hands. Call your "
      "hospital straight away if your babies are moving less than usual. "
      "Call your doctor or go in the same day for regular tightenings, "
      "period-like pain or pressure low down before 37 weeks, or fluid "
      "leaking from the vagina. If your twins share a placenta, call your "
      "doctor today if your bump grows much bigger over a few days, feels "
      "very tight, or you become breathless. If you can't get there safely, "
      "call 108 for an ambulance."),
);

final LocalizedText _evCare = _en('NICE guideline NG137, Twin and triplet '
    'pregnancy (2019) · RCOG Green-top Guideline 51, Management of '
    'monochorionic twin pregnancy (2016) · ACOG Practice Bulletin 231, '
    'Multifetal gestations (2021) · Ministry of Health and Family Welfare, '
    'Pradhan Mantri Surakshit Matritva Abhiyan (PMSMA) guidance.');

final List<PvRead> kPregnancyReadsTwins = [
  // ===========================================================================
  //  CARRYING TWINS
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Finding out it's twins
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_twins_read_finding_out',
    hue: _hue,
    kicker: _kCarrying,
    title: _en("Finding out it's twins"),
    teaser: _en("How twins are usually found, why the news can bring every "
        "feeling at once, and what changes in your care from here."),
    shortAnswer: _en("Twins are found on an ultrasound scan, most often the "
        "early dating scan. It's normal to feel thrilled, shocked and scared "
        "all in the same hour. From here your care gets a little closer, "
        "with more scans and visits, and your doctor will make a plan with "
        "you."),
    scaleSetter: _en("Around the world, about 12 in every 1,000 births are "
        "twins, so you're far from alone. Doctors look after twin "
        "pregnancies all the time, and with good care most twins are born "
        "healthy."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Finding out there are two can stop you in your tracks. Maybe "
            "you'd wondered. Maybe it came out of nowhere on the scan screen. "
            "Either way, it's big news, and it's fine to take a while to let "
            "it sink in."),
        _en("This read covers how twins are found, the feelings that come "
            "with it, and what changes in your care now. The rest of this "
            "door goes deeper on each part, whenever you're ready."),
      ]),
      PvReadSection(
        heading: _en("How do doctors find out it's twins?"),
        paragraphs: [
          _en("An ultrasound scan is how twins are found. Most are seen on the "
              "early dating scan, somewhere between 6 and 14 weeks, when the "
              "sonographer sees two sacs or two heartbeats."),
          _en("Sometimes a doctor suspects twins because the bump measures "
              "bigger than expected, or two heartbeats are heard later on. A "
              "scan is what confirms it."),
          _en("A very early scan, before about 8 weeks, now and then shows "
              "one baby and a second is seen at the next scan. That's one "
              "reason the scan at 11 to 14 weeks matters, even if you've had "
              "one before."),
        ],
        mythFact: PvMythFact(
          myth: _en("Strong morning sickness, a big bump or a very high "
              "pregnancy hormone level means it's twins."),
          fact: _en("These can be a little more common with twins, but many "
              "women carrying one baby have all three. No symptom and no "
              "blood test can tell you it's twins. Only a scan can."),
        ),
      ),
      PvReadSection(
        heading: _en('Is it normal to feel like this?'),
        paragraphs: [
          _en("Yes. Many parents of twins say the first feeling was shock, and "
              "the joy came a little later. Others feel excited straight away "
              "and then lie awake worrying. Some feel a pang for the "
              "pregnancy they'd pictured, with one baby and one cot."),
          _en("All of these are normal. None of them says anything about how "
              "much you'll love your babies."),
          _en("Money, space at home, work and help from family can all crowd "
              "in during the first days. You don't have to sort them out now. "
              "There are months to plan, and the last tab of this door helps "
              "with that."),
          _en("If the worry sits with you most days, or you can't sleep for "
              "it, tell your doctor. Talking about it early helps."),
        ],
      ),
      PvReadSection(
        heading: _en('What changes in my care now?'),
        bullets: [
          _en("A scan to see whether the babies share a placenta. It's best "
              "done before 14 weeks. 'Identical, non-identical, and the "
              "placenta' on this door explains why it matters."),
          _en("More scans and check-ups than with one baby. How many depends "
              "mostly on the placentas."),
          _en("In India's government antenatal care, a twin pregnancy is "
              "counted as a high-risk pregnancy. The words sound frightening. "
              "They mean you're offered closer care, with a specialist and a "
              "newborn unit nearby for the birth."),
          _en("Your doctor may suggest giving birth in a hospital with a "
              "newborn unit (NICU), because twins are often born a little "
              "early."),
          _en("Iron, folic acid and calcium tablets, and sometimes other "
              "medicines, as your doctor advises."),
        ],
        tip: PvReadTip(
          title: _en('Free check-ups under PMSMA'),
          body: _en("Under the Pradhan Mantri Surakshit Matritva Abhiyan, "
              "government health centres offer a free antenatal check-up with "
              "a doctor on the 9th of every month, in the second and third "
              "trimesters. It's a good place to ask about twin care if you use "
              "government services."),
        ),
      ),
      PvReadSection(
        heading: _en('What about triplets or more?'),
        paragraphs: [
          _en("Most of what's in this door applies to triplets too. Care is "
              "closer still: more scans, a specialist team, and a birth "
              "that's usually planned earlier."),
          _en("Your doctor will talk you through a plan made for three, and "
              "it's fine to ask for that plan to be explained more than "
              "once."),
        ],
      ),
      PvReadSection(
        heading: _en('When should we tell people?'),
        paragraphs: [
          _en("Whenever you're ready. Some couples wait until after the 11 to "
              "14 week scan, when they know more. Some tell family straight "
              "away, because they know they'll need help."),
          _en("Expect a lot of comments. 'Double trouble' is a favourite, and "
              "so is 'Did you have treatment?' You don't owe anyone an answer "
              "about how you got pregnant."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Can a scan miss a twin?'),
        answer: _en("Now and then, on a very early scan. By the scan at 11 to "
            "14 weeks, twins are almost always clear."),
      ),
      PvReadFaq(
        question: _en('Is a twin pregnancy called high risk?'),
        answer: _en("In Indian government care, yes. It's a label for extra "
            "care, not a prediction. Most twin pregnancies go well with that "
            "care."),
      ),
      PvReadFaq(
        question: _en('Will I need to change doctors or hospitals?'),
        answer: _en("Not always. Many obstetricians look after twins. If your "
            "hospital doesn't have a newborn unit, your doctor may suggest "
            "one that does for the birth, or share your care with a "
            "specialist."),
      ),
    ],
    evidence: _evCare,
    readNext: [
      'preg_twins_read_types',
      'preg_twins_read_scans',
      'preg_twins_read_food',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Types of twins, and the placenta
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_twins_read_types',
    hue: _hue,
    kicker: _kCarrying,
    title: _en('Identical, non-identical, and the placenta'),
    teaser: _en("The kinds of twins in plain words, what the letters on your "
        "report mean, and why the early scan counts the placentas."),
    shortAnswer: _en("Non-identical twins grow from two eggs and always have "
        "two placentas. Identical twins grow from one egg that splits, and "
        "most of them share one placenta. Whether twins share a placenta "
        "shapes your scans and care, so it's checked early, best before 14 "
        "weeks."),
    scaleSetter: _en("The letters on a twin scan report, like DCDA or MCDA, "
        "can look like a code. They describe the placentas and the sacs, and "
        "this read decodes them. No type is a problem in itself. Each one "
        "comes with its own care plan."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("There are two questions about any twins. Are they identical? And "
            "do they share a placenta? They sound like the same question. "
            "They aren't quite, and the second one matters more for your "
            "care."),
      ]),
      PvReadSection(
        heading: _en('What are non-identical twins?'),
        paragraphs: [
          _en("Non-identical twins (fraternal, or dizygotic, twins) grow from "
              "two separate eggs, each fertilised by a different sperm. They're "
              "as alike as any two siblings, just born together."),
          _en("Each baby has its own placenta and its own sac of fluid. Around "
              "the world, most twins are non-identical."),
          _en("The two placentas can sit so close together that they look like "
              "one on a scan. They're still two, and an early scan can usually "
              "tell."),
        ],
      ),
      PvReadSection(
        heading: _en('What are identical twins?'),
        paragraphs: [
          _en("Identical twins (monozygotic twins) grow from one fertilised "
              "egg that splits in two early on. They share the same genes. "
              "Nobody makes an egg split. It isn't linked to anything the "
              "parents did, ate or took."),
          _en("When the egg splits decides how the babies are set up in the "
              "womb:"),
        ],
        bullets: [
          _en("Split in the first few days: two placentas and two sacs, just "
              "like non-identical twins. This happens in about a third of "
              "identical twins."),
          _en("Split a few days later: one shared placenta, with each baby in "
              "its own sac. This is the most common set-up for identical "
              "twins."),
          _en("Split later still: one placenta and one sac, both shared. This "
              "is rare, around 1 in 100 identical twin pregnancies."),
        ],
      ),
      PvReadSection(
        heading: _en('What do DCDA, MCDA and MCMA mean?'),
        paragraphs: [
          _en("The chorion is the outer layer that forms the placenta. The "
              "amnion is the inner sac that holds the fluid around a baby. "
              "The letters count each one."),
        ],
        bullets: [
          _en("DCDA (dichorionic diamniotic): two placentas and two sacs. All "
              "non-identical twins, and some identical twins."),
          _en("MCDA (monochorionic diamniotic): one shared placenta, two "
              "sacs."),
          _en("MCMA (monochorionic monoamniotic): one shared placenta and one "
              "shared sac."),
          _en("Triplets get the same kind of letters, such as TCTA for three "
              "placentas and three sacs."),
        ],
        tip: PvReadTip(
          title: _en('Ask for it on your file'),
          body: _en("Ask your doctor to write the type on your file, for "
              "example 'DCDA twins'. It helps any doctor who sees you later, "
              "including one on a night shift in the labour ward."),
        ),
      ),
      PvReadSection(
        heading: _en('Why does the early scan count the placentas?'),
        paragraphs: [
          _en("Twins who share a placenta also share some of its blood "
              "vessels. Most of the time, blood flows evenly between them. "
              "Now and then it doesn't, and that's what the extra scans for "
              "these twins look for. 'Extra scans and check-ups with twins' "
              "on this door explains more."),
          _en("The placentas are easiest to count early. Before about 14 weeks, "
              "the scan can see where the thin wall between the babies meets "
              "the placenta. A thick, triangle-shaped join usually means two "
              "placentas. A thin, T-shaped join usually means one. Later in "
              "pregnancy this gets much harder to see."),
          _en("So two placentas don't always mean non-identical twins. That's "
              "why the report talks about placentas and sacs rather than "
              "about identical or not."),
          _en("If your 11 to 14 week scan report doesn't mention the "
              "placentas, it's fine to ask. It's one of the most useful facts "
              "in a twin pregnancy."),
        ],
      ),
      PvReadSection(
        heading: _en('Does the type change the birth?'),
        paragraphs: [
          _en("It can. Twins with two placentas, and twins sharing a placenta "
              "in separate sacs, can often be born vaginally if the first baby "
              "is head down. Twins sharing one sac are usually born by planned "
              "caesarean."),
          _en("The type also shapes when the birth is planned. Twins sharing a "
              "placenta are usually born a little earlier than twins with two. "
              "'How twins are born' on this door explains both."),
        ],
      ),
      PvReadSection(
        heading: _en("Can we find out if they're identical?"),
        paragraphs: [
          _en("Not always before birth. If the babies share a placenta, they're "
              "identical. If they have two, the scan can't tell either way."),
          _en("After the birth, a DNA test from a cheek swab can tell for "
              "certain, if you'd like to know. Many families never test, and "
              "that's fine too. It doesn't change how your babies are cared "
              "for once they're born."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Is one kind of twins better than another?'),
        answer: _en("No kind is good or bad. Twins with two placentas need "
            "fewer scans. Twins sharing a placenta need more, and with that "
            "care most do well."),
      ),
      PvReadFaq(
        question: _en('Do identical twins look exactly alike?'),
        answer: _en("Very alike, but not always exactly. Their fingerprints "
            "differ, and small differences in the womb can show in their "
            "birth weights."),
      ),
      PvReadFaq(
        question: _en("My report doesn't say. Is it too late to find out?"),
        answer: _en("Ask your doctor. It's harder to tell later on, but a "
            "specialist scan may still help, and your doctor can plan your "
            "care to be safe either way."),
      ),
    ],
    evidence: _en('NICE guideline NG137, Twin and triplet pregnancy (2019), '
        'on determining chorionicity at 11 to 14 weeks · RCOG Green-top '
        'Guideline 51, Management of monochorionic twin pregnancy (2016) · '
        'ACOG Practice Bulletin 231, Multifetal gestations (2021).'),
    readNext: [
      'preg_twins_read_scans',
      'preg_twins_read_families',
      'preg_twins_read_birth',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Do twins run in families?
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_twins_read_families',
    hue: _hue,
    kicker: _kCarrying,
    title: _en('Do twins run in families?'),
    teaser: _en("What makes twins more common, why identical twins happen by "
        "chance, and the stories that aren't true."),
    shortAnswer: _en("Non-identical twins can run in families, through the "
        "mother's side. Identical twins mostly happen by chance, at about the "
        "same rate everywhere. Being older, having had babies before and "
        "fertility treatment also make non-identical twins more common."),
    scaleSetter: _en("This read is background, for your own curiosity and for "
        "the questions family will ask. It's about twins in general. Nothing "
        "here is a prediction about you, your sisters or your children."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Once twins are on the way, someone always asks where they came "
            "from. The honest answer depends on which kind of twins they "
            "are."),
        _en("Here's what's known, in plain words, and a couple of the stories "
            "you may hear at family gatherings."),
      ]),
      PvReadSection(
        heading: _en('How common are twins?'),
        paragraphs: [
          _en("Around the world, about 12 in every 1,000 births are twins. The "
              "number has gone up since the 1980s, mostly because of fertility "
              "treatment and because more women have babies later in life."),
          _en("Rates differ a lot between countries. They're highest in parts "
              "of Central Africa and lower in much of Asia and Latin America. "
              "Triplets and more are much rarer than twins."),
        ],
      ),
      PvReadSection(
        heading: _en('Do non-identical twins run in families?'),
        paragraphs: [
          _en("They can. Non-identical twins come from two eggs released in "
              "the same cycle. A tendency to release more than one egg can be "
              "passed down in families."),
          _en("That tendency only affects the pregnancies of the woman who has "
              "it. So twins on the mother's side are what counts for her own "
              "pregnancies. It's why twins can seem to cluster in some "
              "families and never appear in others."),
          _en("If you're curious about your own family, the stories that fit "
              "this pattern are twins among the women on the mother's side: "
              "her mother, her sisters, her grandmother."),
          _en("A man can carry the tendency and pass it to his daughters. It "
              "doesn't change how many eggs his partner releases, so twins in "
              "his family don't make twins more common in her pregnancies."),
        ],
      ),
      PvReadSection(
        heading: _en('Do identical twins run in families?'),
        paragraphs: [
          _en("Mostly, no. An egg splitting in two seems to happen by chance, "
              "at about the same rate all over the world: roughly 3 to 4 in "
              "every 1,000 births."),
          _en("A few families do seem to have more identical twins than chance "
              "would explain, but that's unusual, and nobody yet knows why."),
          _en("It isn't caused by anything the parents did, ate or took."),
        ],
      ),
      PvReadSection(
        heading: _en('What else makes twins more common?'),
        paragraphs: [
          _en("These are patterns across many pregnancies. They explain why "
              "some groups have more twins. They can't tell any one woman "
              "what will happen to her."),
        ],
        bullets: [
          _en("Age. Non-identical twins become more common as women get "
              "older, especially after 35, because the body sometimes "
              "releases two eggs in one cycle."),
          _en("Having had babies before."),
          _en("Fertility treatment. Medicines that help you ovulate can "
              "release more than one egg. IVF with more than one embryo put "
              "back can lead to twins, which is why many clinics now transfer "
              "one."),
          _en("Where a family comes from, since twin rates differ between "
              "countries."),
        ],
        mythFact: PvMythFact(
          myth: _en('Twins skip a generation.'),
          fact: _en("There's no good evidence for this. It can look that way "
              "because the tendency passes through women. A man with twins in "
              "his family doesn't have twins himself more often, but his "
              "daughter may. The pattern skips a man, not a generation."),
        ),
      ),
      PvReadSection(
        heading: _en('Can food or home remedies bring twins?'),
        paragraphs: [
          _en("No food, herb or home remedy has been shown to bring on twins. "
              "If someone suggests one, it's fine to smile and leave it."),
          _en("Some fertility medicines do make twins more common. That's why "
              "they're taken only with a doctor watching the scans, never "
              "bought at a chemist on someone's advice."),
        ],
      ),
      PvReadSection(
        heading: _en('What about triplets?'),
        paragraphs: [
          _en("Triplets can be any mix: three babies from three eggs, two "
              "identical babies and one who isn't, or, rarely, all three "
              "identical. The early scan counts the placentas and sacs just "
              "as it does for twins."),
          _en("Many triplets today follow fertility treatment, though some "
              "happen without it."),
        ],
      ),
      PvReadSection(
        heading: _en('What if people ask how we got pregnant?'),
        paragraphs: [
          _en("Twins often bring a question people shouldn't ask: 'Was it "
              "natural?' You don't have to answer. 'We're just happy they're "
              "coming' is enough. Most relatives who ask mean well and are "
              "just excited, and a smile and a change of subject works "
              "too."),
          _en("If your twins came after fertility treatment, they're no less "
              "yours and no less natural. How your pregnancy began is private "
              "unless you choose to share it."),
          _en("If it helps, agree on one short answer with your partner, so "
              "you're both saying the same thing to curious relatives."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('If a woman is a twin, will she have twins?'),
        answer: _en("Women who are non-identical twins themselves have twins "
            "a little more often than average. Being an identical twin "
            "doesn't seem to make much difference."),
      ),
      PvReadFaq(
        question: _en('Is there a way to have twins on purpose?'),
        answer: _en("No safe way, and doctors don't aim for twins. One baby at "
            "a time is safer for mother and baby, which is why fertility "
            "clinics try to avoid twins."),
      ),
      PvReadFaq(
        question: _en("Does the father's family matter?"),
        answer: _en("Not for his partner's pregnancies. It may matter later for "
            "his daughters' pregnancies."),
      ),
    ],
    evidence: _en('Monden, Pison and Smits, Twin Peaks: more twinning in '
        'humans than ever before, Human Reproduction (2021) · ACOG Practice '
        'Bulletin 231, Multifetal gestations (2021) · NICE guideline NG137, '
        'Twin and triplet pregnancy (2019).'),
    readNext: [
      'preg_twins_read_types',
      'preg_twins_read_finding_out',
      'preg_twins_read_ready',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Food, weight and tiredness
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_twins_read_food',
    hue: _hue,
    kicker: _kCarrying,
    title: _en('Food, weight and tiredness with twins'),
    teaser: _en("Why you need more food and iron with twins, how to eat when "
        "there's no room left, and ways to get more rest."),
    shortAnswer: _en("With twins you need more food, protein and iron than "
        "with one baby, and you'll usually gain more weight, more of it "
        "earlier. Your doctor sets your weight range and any higher tablet "
        "doses. Rest when you can, because tiredness is often stronger with "
        "twins."),
    scaleSetter: _en("Nothing here is a target for you. It's the general "
        "picture, so the advice at your visits makes sense. For meals and "
        "recipes, 'Eating well with twins' on this door opens the Nutrition "
        "guide."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Growing two babies asks more of your body, and you'll probably "
            "feel it early: hungrier, more tired, more breathless. Most of "
            "this is expected, and a lot of it can be eased."),
      ]),
      PvReadSection(
        heading: _en('How much more do I need to eat?'),
        paragraphs: [
          _en("More than with one baby, but not double. ICMR's guidance for "
              "India adds about 350 calories a day in the second and third "
              "trimesters for one baby. With twins, most doctors suggest more "
              "than that. Ask your doctor or a dietitian what's right for "
              "you."),
          _en("Think of extra snacks rather than bigger plates: a bowl of dal "
              "or curd, a handful of nuts, an egg, a roti with paneer, fruit "
              "with a glass of milk."),
          _en("Protein helps two babies grow. Dal, rajma, chana, paneer, curd "
              "and milk all count, and so do eggs, fish and chicken if you "
              "eat them."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does iron matter more with twins?'),
        paragraphs: [
          _en("Two babies draw on your blood supply, so anaemia (low "
              "haemoglobin) is more common in twin pregnancies. It can leave "
              "you exhausted and breathless."),
          _en("Take your iron and folic acid tablets as your doctor advises. "
              "With twins, some doctors suggest a higher dose. Take iron with "
              "water or lemon water, not with tea, coffee or milk, which make "
              "it harder to absorb. Take calcium at a different time of day "
              "from iron."),
          _en("Your haemoglobin is usually checked more often with twins. If "
              "it's low, there are other treatments, such as iron given "
              "through a drip."),
          _en("Everyday foods that give you iron:"),
        ],
        bullets: [
          _en("Green leafy vegetables like palak, methi and bathua."),
          _en("Ragi and bajra, and a little jaggery (gur)."),
          _en("Dates, raisins and dried figs."),
          _en("Dal, rajma and chana."),
          _en("Eggs, fish, chicken and meat if you eat them. The body takes up "
              "iron from these most easily."),
          _en("A little vitamin C with meals helps: lemon on your dal, amla, "
              "guava or an orange."),
        ],
      ),
      PvReadSection(
        heading: _en('How much weight will I gain?'),
        paragraphs: [
          _en("More than with one baby, and more of it earlier. That's "
              "expected: there are two babies, more fluid, often two "
              "placentas and a bigger blood supply."),
          _en("Weight charts for one baby don't apply to twins. Your doctor "
              "will weigh you at your visits and tell you what range suits "
              "you. A steady gain in the first half of pregnancy helps twins "
              "grow, since they're often born a little early."),
          _en("Please don't diet or skip meals to slow your gain. If it's on "
              "your mind, talk to your doctor."),
          _en("Swollen feet by evening are common later on. Swelling that comes "
              "on suddenly in your face or hands needs a call to your doctor "
              "the same day."),
        ],
      ),
      PvReadSection(
        heading: _en("What if there's no room to eat?"),
        bullets: [
          _en("Five or six small meals instead of three big ones."),
          _en("Sip water between meals rather than with them."),
          _en("Keep easy snacks close: roasted chana, makhana, fruit, "
              "nuts."),
          _en("Heartburn often starts earlier with twins. Eat dinner a little "
              "earlier and raise your head at night. Ask your doctor before "
              "taking an antacid."),
          _en("Nausea can be stronger with twins in the first months. If you "
              "can't keep food or water down for a day, call your doctor."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I cope with the tiredness?'),
        paragraphs: [
          _en("Tiredness is often stronger with twins, in the first months and "
              "again at the end. It's your body working hard. It isn't you "
              "failing."),
          _en("Sleep on your side, with a pillow between your knees and one "
              "behind your back. Short rests in the day count too."),
          _en("Feeling a bit breathless as the bump grows is common with twins, "
              "because the babies press up under your ribs. Breathlessness that "
              "comes on suddenly, or with chest pain, is different: go to "
              "hospital straight away."),
          _en("Say yes when family offer to cook or help with the house. If "
              "you work, it may help to talk to your manager early about rest "
              "breaks or lighter duties."),
          _en("Gentle walking suits most women carrying twins. Ask your doctor "
              "before anything harder, and stop anything that brings on "
              "tightenings."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Should I eat for three?'),
        answer: _en("Not three full portions. Add a few good snacks through "
            "the day, as your doctor advises."),
      ),
      PvReadFaq(
        question: _en('Can I fast with twins?'),
        answer: _en("Fasting is your doctor's call in a twin pregnancy. Ask "
            "before any fast, even a short one."),
      ),
      PvReadFaq(
        question: _en('Do I need special supplements?'),
        answer: _en("Only what your doctor prescribes. Most women with twins "
            "take iron, folic acid and calcium. Don't add others without "
            "asking."),
      ),
    ],
    evidence: _en('ICMR-National Institute of Nutrition, Nutrient '
        'Requirements for Indians (2020) · Ministry of Health and Family '
        'Welfare, Anemia Mukt Bharat operational guidelines (2018) · NICE '
        'guideline NG137, Twin and triplet pregnancy (2019) · WHO '
        'recommendations on antenatal care for a positive pregnancy '
        'experience (2016).'),
    readNext: [
      'preg_twins_read_watch',
      'preg_twins_read_scans',
      'preg_twins_read_ready',
    ],
  ),

  // ===========================================================================
  //  YOUR CARE
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Extra scans and check-ups, and TTTS
  // ---------------------------------------------------------------------------
  //  ⚠️ "What is TTTS?" is opened by heading from the door
  //  (`atHeading`). Renaming it sends that card to the top of the read, and
  //  `pv_door_twins_test.dart` fails.
  PvRead(
    id: 'preg_twins_read_scans',
    hue: _hue,
    kicker: _kCare,
    title: _en('Extra scans and check-ups with twins'),
    teaser: _en("Why twins are seen more often, the usual schedule for each "
        "kind of twins, and what TTTS is in plain words."),
    shortAnswer: _en("With twins you'll have more scans and visits than with "
        "one baby, so both babies' growth can be checked. Twins with two "
        "placentas are usually scanned about every four weeks from 20 weeks, "
        "and twins sharing a placenta every two weeks from about 16 weeks, to "
        "catch TTTS early. Your doctor sets your own plan."),
    scaleSetter: _en("This is the schedule most guidelines suggest. Your "
        "hospital's plan may differ a little, and your doctor's plan is the "
        "one to follow."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("More scans can feel like more worry. Mostly they're the "
            "opposite: a regular look at two babies, so anything that needs "
            "care is found early, while there's time to act."),
      ]),
      PvReadSection(
        heading: _en('Why do twins need more scans?'),
        paragraphs: [
          _en("With one baby, the size of the bump tells a doctor a lot. With "
              "two, it's hard to know from the outside how each baby is "
              "growing. Scans measure each one."),
          _en("The scans look at each baby's growth and the fluid around each "
              "one. For twins sharing a placenta, they also look at how blood "
              "is flowing between the babies."),
          _en("Each baby is labelled, for example twin 1 and twin 2, or by "
              "where they lie in the womb. That way the same baby is followed "
              "from scan to scan."),
        ],
      ),
      PvReadSection(
        heading: _en('How often will I be scanned?'),
        paragraphs: [
          _en("You'll usually have more antenatal visits than with one baby, "
              "with your blood pressure and urine checked each time, and an "
              "extra blood count around 20 to 24 weeks to check for anaemia. "
              "The scans usually follow a schedule like this:"),
        ],
        bullets: [
          _en("Every twin pregnancy: an early scan, best before 14 weeks, to "
              "date the pregnancy and count the placentas, with screening for "
              "conditions like Down syndrome if you choose it. Then the "
              "detailed anomaly scan, around 18 to 20 weeks."),
          _en("Two placentas (DCDA): usually a growth scan about every four "
              "weeks from 20 weeks."),
          _en("One shared placenta, two sacs (MCDA): usually a scan every two "
              "weeks from about 16 weeks until the birth."),
          _en("One placenta and one sac (MCMA): scans at least as often, with "
              "a specialist fetal medicine team."),
          _en("Triplets: a schedule set by a specialist team."),
        ],
      ),
      PvReadSection(
        heading: _en('What is TTTS?'),
        paragraphs: [
          _en("TTTS stands for twin-to-twin transfusion syndrome. It can only "
              "happen when twins share a placenta."),
          _en("In a shared placenta, blood vessels link the two babies. Usually "
              "blood flows evenly both ways. In TTTS it doesn't: one baby "
              "gives more blood than it gets back, and the other receives too "
              "much. One baby ends up with too little fluid around it and the "
              "other with too much."),
          _en("It affects about 10 to 15 in every 100 twin pregnancies that "
              "share a placenta. It most often shows up between 16 and 26 "
              "weeks, which is why the scans every two weeks start at 16."),
          _en("The scans check the fluid around each baby, their bladders and "
              "their blood flow. When TTTS is found, there are treatments. The "
              "main one is laser treatment at a specialist fetal medicine "
              "centre, which seals the shared vessels. Your doctor would "
              "explain the choices and refer you."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('Call your doctor today if'),
          body: _en("Your twins share a placenta and your bump grows much "
              "bigger over a few days, feels very tight or sore, or you "
              "become breathless. These can be signs of TTTS, and it's worth "
              "a check straight away rather than at your next scan."),
        ),
      ),
      PvReadSection(
        heading: _en('What else do the scans check?'),
        paragraphs: [
          _en("Twins sharing a placenta can have other, rarer conditions, where "
              "one baby grows much less than the other or their blood counts "
              "differ. The same regular scans look for these."),
          _en("In any twin pregnancy, the scans compare the two babies' sizes. "
              "A small difference is normal. A bigger one means closer "
              "checks, and your doctor will explain what it means for your "
              "babies."),
          _en("Later scans also show how each baby is lying, which helps plan "
              "the birth."),
        ],
      ),
      PvReadSection(
        heading: _en('What should I ask at my scans?'),
        bullets: [
          _en("Do my twins share a placenta? Can you write the type on my "
              "file?"),
          _en("How often will I be scanned, and where?"),
          _en("Are both babies growing well, and is the fluid around each one "
              "normal?"),
          _en("Which baby is twin 1, and how are they lying?"),
          _en("Who do I call between scans if something changes?"),
        ],
        tip: PvReadTip(
          title: _en('Keep the reports together'),
          body: _en("Twin reports carry two sets of numbers. Keep every report "
              "in one folder, or photographed on your phone, so a doctor "
              "seeing you at night can find the latest one."),
        ),
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Are so many scans safe for my babies?'),
        answer: _en("Yes. Ultrasound has been used in pregnancy for decades, "
            "and scans done for a medical reason are considered safe."),
      ),
      PvReadFaq(
        question: _en('Can screening for Down syndrome be done with twins?'),
        answer: _en("Yes. The scan at 11 to 14 weeks, with a blood test, can "
            "screen twins, and your doctor will explain how the results work "
            "for two babies. Some blood tests work less well with twins, so "
            "ask which one your hospital offers."),
      ),
      PvReadFaq(
        question: _en('If TTTS is found, what happens next?'),
        answer: _en("A specialist team looks at how far along it is. Milder "
            "TTTS is sometimes watched closely with more scans. More serious "
            "TTTS is usually treated, and treatment has improved a great "
            "deal. Your team will explain what they see and what they "
            "suggest."),
      ),
    ],
    evidence: _evCare,
    readNext: [
      'preg_twins_read_types',
      'preg_twins_read_watch',
      'preg_twins_read_birth',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  What's more common, and when to call
  // ---------------------------------------------------------------------------
  //  ⚠️ "How do I keep track of two babies moving?" is opened by heading from
  //  the door (`atHeading`).
  PvRead(
    id: 'preg_twins_read_watch',
    hue: _hue,
    kicker: _kCare,
    title: _en("What's more common with twins, and when to call"),
    teaser: _en("The things doctors watch more closely in a twin pregnancy, "
        "said calmly, feeling two babies move, and the signs that mean "
        "picking up the phone."),
    shortAnswer: _en("Some things are more common with twins, like early "
        "labour, preeclampsia, anaemia and gestational diabetes. That's why "
        "your care is closer, and most are found early at routine checks. "
        "Bleeding, regular tightenings before 37 weeks, leaking fluid, a "
        "severe headache with vision changes, or your babies moving less "
        "mean calling or going in the same day."),
    scaleSetter: _en("A list like this can be unsettling to read. These are "
        "facts about twin pregnancies in general, not predictions about "
        "yours, and most twin pregnancies go well with good care."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Knowing what your doctor is watching for helps the extra checks "
            "make sense. It also means you'll know which signs to act on, "
            "and which can wait for your next visit."),
      ]),
      PvReadSection(
        heading: _en('What is more common with twins?'),
        paragraphs: [
          _en("These are more common in twin pregnancies. More common doesn't "
              "mean likely: many women carrying twins have none of them, and "
              "the ones that do happen are usually found early at routine "
              "checks."),
        ],
        bullets: [
          _en("Early birth. More than half of twins are born before 37 weeks, "
              "most of them close to it. Babies born near 37 weeks usually do "
              "very well."),
          _en("High blood pressure and preeclampsia. Your blood pressure and "
              "urine are checked at every visit for this."),
          _en("Anaemia, because two babies draw on your blood."),
          _en("Gestational diabetes. You'll be tested for it as in any "
              "pregnancy in India, with a sugar test."),
          _en("Stronger nausea early on, and more heartburn, backache and "
              "swelling later."),
          _en("Babies growing at different rates, which the scans watch "
              "for."),
          _en("Heavier bleeding after the birth, which the team is ready "
              "for."),
        ],
      ),
      PvReadSection(
        heading: _en('What helps prevent problems?'),
        paragraphs: [
          _en("Strict bed rest isn't usually advised for twins. It doesn't "
              "prevent early labour and can bring problems of its own, so "
              "follow your own doctor's advice about how active to be. These "
              "help more:"),
        ],
        bullets: [
          _en("Going to every check-up and scan, even when you feel well."),
          _en("Taking your iron, folic acid and calcium as prescribed."),
          _en("Some doctors prescribe a low dose of aspirin from about 12 "
              "weeks to help prevent preeclampsia. Take it only if your doctor "
              "prescribes it."),
          _en("Resting when you're tired, and asking for help at home."),
          _en("Having your blood pressure checked between visits if your "
              "doctor asks, at a clinic or with a home machine they "
              "recommend."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I keep track of two babies moving?'),
        paragraphs: [
          _en("You'll usually start feeling movements between 16 and 24 weeks, "
              "as with one baby. Some women carrying twins notice them a "
              "little earlier."),
          _en("With two babies it's hard to tell whose kick is whose. You may "
              "feel more on one side, or one baby may seem busier than the "
              "other. That's normal."),
          _en("What matters is the overall pattern you know. Get to know how "
              "your babies usually move through the day. Kick-counting charts "
              "are made for one baby, so there's no need to count each twin."),
          _en("If you feel less movement than usual, or the pattern changes, "
              "call your hospital straight away. Don't wait until the next "
              "day, and don't rely on a home heartbeat monitor. The hospital "
              "can check each baby's heartbeat separately."),
        ],
      ),
      PvReadSection(
        heading: _en('Which signs need a call?'),
        bullets: [
          _en("Any bleeding from the vagina: go to hospital straight away."),
          _en("A severe headache with blurred vision or flashing lights, pain "
              "under your ribs, or sudden swelling of your face or hands: go "
              "to hospital."),
          _en("Your babies moving less than usual: call your hospital straight "
              "away."),
          _en("Regular tightenings, period-like pain, a low backache that "
              "comes and goes, or pressure low down before 37 weeks: call "
              "your doctor or go in the same day."),
          _en("Fluid leaking or gushing from the vagina: call your doctor or "
              "go in the same day."),
          _en("If your twins share a placenta, a bump that grows much bigger "
              "over a few days, feels very tight, or leaves you breathless: "
              "call your doctor today."),
          _en("Vomiting so much you can't keep water down, burning when you "
              "pass urine, or itching on your palms and soles: call your "
              "doctor today."),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm admitted to hospital?"),
        paragraphs: [
          _en("Some women carrying twins spend time in hospital before the "
              "birth, for blood pressure, early tightenings or closer "
              "monitoring. It's a common part of twin care. It doesn't mean "
              "things have gone badly."),
          _en("If you are admitted, ask what the team is watching for and what "
              "would let you go home. Knowing that helps the days pass. Bring "
              "your reports, your phone charger and something to do."),
          _en("Have a small bag packed by around 30 weeks, just in case. "
              "'Getting ready for two' on this door has what to put in it."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Are twins always born early?'),
        answer: _en("No. Many twins are born at or close to 37 weeks. Doctors "
            "also usually plan the birth by then, so a twin pregnancy going "
            "far past 37 weeks is rare."),
      ),
      PvReadFaq(
        question: _en('Should I stop working?'),
        answer: _en("Not necessarily. Many women carrying twins keep working "
            "into the second half. Talk to your doctor about your job, and to "
            "your HR about leave."),
      ),
      PvReadFaq(
        question: _en('Can I travel?'),
        answer: _en("Short trips are usually fine earlier on. Ask your doctor "
            "before any long trip, especially later in pregnancy, as "
            "twins can come early."),
      ),
    ],
    evidence: _en('NICE guideline NG137, Twin and triplet pregnancy (2019) · '
        'NICE guideline NG133, Hypertension in pregnancy (2019, updated '
        '2023) · NICE guideline NG25, Preterm labour and birth (2015, updated '
        '2022) · RCOG Green-top Guideline 57, Reduced fetal movements (2011) · '
        'Ministry of Health and Family Welfare, National guidelines for '
        'diagnosis and management of gestational diabetes mellitus (2018).'),
    readNext: [
      'preg_twins_read_scans',
      'preg_twins_read_birth',
      'preg_twins_read_food',
    ],
  ),

  // ===========================================================================
  //  THE BIRTH
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  How twins are born
  // ---------------------------------------------------------------------------
  //  ⚠️ Two headings are opened from the door by text (`atHeading`): "When
  //  will my twins be born?" and "What happens on the day?".
  PvRead(
    id: 'preg_twins_read_birth',
    hue: _hue,
    kicker: _kBirth,
    title: _en('How twins are born'),
    teaser: _en("Normal birth or caesarean, how the babies' positions decide, "
        "when twins are usually born, and what happens on the day."),
    shortAnswer: _en("Many twins can be born vaginally, especially when the "
        "first baby is head down. Some are born by planned caesarean, for "
        "example when the first baby isn't head down or the twins share a "
        "sac. Twins are usually born earlier than one baby, often around 36 "
        "to 37 weeks, and your doctor plans the timing with you."),
    scaleSetter: _en("How your twins are born is decided by you and your "
        "doctor together, based on how the babies lie and share the "
        "placenta. This read explains the choices, so that conversation is "
        "easier."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Many mothers of twins are told early on that they'll need a "
            "caesarean. That isn't always so. How twins are born depends "
            "mostly on two things: how the babies share the placenta, and "
            "how the first baby is lying."),
      ]),
      PvReadSection(
        heading: _en('Can twins be born normally?'),
        paragraphs: [
          _en("Yes, often. When the pregnancy has gone well and the first baby "
              "(the one lower down, nearest the cervix) is head down, a "
              "vaginal birth is usually a safe choice."),
          _en("The first baby's position matters most, because that baby leads "
              "the way. Once the first baby is born, the second has more room "
              "and can turn. The team may help the second baby into a good "
              "position, or help the baby be born bottom first. Now and then "
              "the second baby needs a caesarean."),
          _en("Your doctor will talk through the options with you, and your "
              "wishes count. Some women who could give birth vaginally choose "
              "a caesarean, and some choose to try for a vaginal birth."),
        ],
      ),
      PvReadSection(
        heading: _en('When is a caesarean planned?'),
        paragraphs: [
          _en("A planned caesarean for twins is a common, well-practised "
              "operation, and the babies are usually born a minute or two "
              "apart. It's usually advised when:"),
        ],
        bullets: [
          _en("The first baby isn't head down, but bottom first or lying "
              "across."),
          _en("The twins share one sac (MCMA twins)."),
          _en("Triplets or more, most of the time."),
          _en("The placenta is low (placenta previa), or there's another "
              "reason that would mean a caesarean with one baby."),
          _en("Your doctor has other concerns about one or both babies."),
        ],
      ),
      PvReadSection(
        heading: _en('How might my twins be lying?'),
        paragraphs: [
          _en("By the last weeks, the babies usually settle into one of a few "
              "positions:"),
        ],
        bullets: [
          _en("Both head down. This is the most common, and a vaginal birth is "
              "often possible."),
          _en("First head down, second bottom first or lying across. A vaginal "
              "birth is often still possible, since the second baby can turn "
              "or be helped."),
          _en("First bottom first or lying across. A caesarean is usually "
              "advised."),
        ],
        tip: PvReadTip(
          title: _en('The plan can change late'),
          body: _en("Positions can change until late in pregnancy, so the plan "
              "is usually confirmed on a scan near the end, or when you come "
              "in for the birth."),
        ),
      ),
      PvReadSection(
        heading: _en('When will my twins be born?'),
        paragraphs: [
          _en("Full term for one baby starts at 37 weeks. Twins are often ready "
              "sooner, and a twin pregnancy that goes on too long becomes less "
              "safe, so doctors usually plan the birth. The guidelines "
              "suggest:"),
        ],
        bullets: [
          _en("Two placentas: a planned birth from about 37 weeks."),
          _en("Sharing one placenta, in separate sacs: from about 36 "
              "weeks."),
          _en("Sharing one sac: a caesarean between 32 and 34 weeks."),
          _en("Triplets: from about 35 weeks."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Your doctor sets your date'),
          body: _en("These are the usual plans, not a date for you. Your "
              "doctor will set it by how your pregnancy is going, and labour "
              "may start on its own before then. If birth is expected before "
              "34 weeks, you may be offered steroid injections to help the "
              "babies' lungs."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens on the day?'),
        bullets: [
          _en("Twins are born in a hospital labour ward or operation theatre, "
              "with a team ready for two babies. If you can, choose a hospital "
              "with a newborn unit (a NICU, or an SNCU in government "
              "hospitals)."),
          _en("Both babies' heartbeats are watched throughout labour, usually "
              "with a monitor on your bump."),
          _en("Many doctors suggest an epidural in a twin labour. If the second "
              "baby needs help, it can then be given quickly and without "
              "pain."),
          _en("In a vaginal birth, the second baby usually follows within "
              "about half an hour, and often sooner."),
          _en("There may be more people in the room, often someone for each "
              "baby. It can look crowded. That's normal."),
          _en("After the birth, your womb has more to shrink back, so the team "
              "watches your bleeding closely and may give you medicine to "
              "help."),
        ],
      ),
      PvReadSection(
        heading: _en('What if my babies need the newborn unit?'),
        paragraphs: [
          _en("Twins born early or small may spend some days in the newborn "
              "unit, for help with warmth, breathing or feeding. Being apart "
              "from them is hard."),
          _en("You can usually visit, hold them skin to skin (kangaroo care) "
              "when they're ready, and give them your milk. Babies born close "
              "to 37 weeks often go home with you, or after a short stay."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Can one baby be born normally and one by caesarean?'),
        answer: _en("It happens now and then, if the second baby's heartbeat "
            "drops or the baby can't be turned. The team is ready for it at "
            "every twin birth."),
      ),
      PvReadFaq(
        question: _en('Can I ask for a caesarean?'),
        answer: _en("Yes. Your doctor will talk through what it means for you "
            "and your babies, and your wishes count."),
      ),
      PvReadFaq(
        question: _en('Can twins be born at home or in a small nursing home?'),
        answer: _en("Twins are best born in a hospital with a full team and a "
            "newborn unit. Two babies need two sets of hands, and early "
            "babies may need extra care."),
      ),
    ],
    evidence: _en('NICE guideline NG137, Twin and triplet pregnancy (2019), on '
        'timing and mode of birth · NICE guideline NG25, Preterm labour and '
        'birth (2015, updated 2022) · ACOG Practice Bulletin 231, Multifetal '
        'gestations (2021) · Ministry of Health and Family Welfare, Special '
        'Newborn Care Units operational guide.'),
    readNext: [
      'preg_twins_read_feeding',
      'preg_twins_read_ready',
      'preg_twins_read_watch',
    ],
  ),

  // ===========================================================================
  //  GETTING READY FOR TWO
  // ===========================================================================

  // ---------------------------------------------------------------------------
  //  Feeding twins
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_twins_read_feeding',
    hue: _hue,
    kicker: _kTwo,
    title: _en('Feeding twins'),
    teaser: _en("Whether you can breastfeed two, feeding together or one at a "
        "time, top-ups, and the help to line up now."),
    shortAnswer: _en("Yes, most women can make enough milk for twins, because "
        "the more milk is taken, the more you make. You can feed the babies "
        "one at a time or both together, and many mothers do a mix. Line up "
        "help before the birth: a lactation counsellor, a twin feeding "
        "pillow and family at home."),
    scaleSetter: _en("Every twin family finds its own way to feed, and any "
        "amount of your milk is good for your babies. This read is about "
        "what helps, not about getting it perfect."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Feeding two babies is a lot of work, especially in the first "
            "weeks. It also gets easier, often sooner than people expect, as "
            "the babies grow and you all learn. Planning now helps."),
      ]),
      PvReadSection(
        heading: _en('Can I make enough milk for two?'),
        paragraphs: [
          _en("Most women can. Milk works on supply and demand: two babies "
              "feeding often tell your body to make more. Many mothers feed "
              "twins on breast milk alone."),
          _en("Starting early helps. Try to put the babies to the breast "
              "within the first hour or so after birth, if they're well "
              "enough. If they're in the newborn unit, ask for help to express "
              "your milk within the first few hours, and then every two to "
              "three hours, including at night."),
          _en("Colostrum, the first thick yellow milk, comes in small amounts. "
              "It's what newborns need, and even a few drops count."),
        ],
      ),
      PvReadSection(
        heading: _en('Together or one at a time?'),
        bullets: [
          _en("One at a time is often easier at first, while you're both "
              "learning to latch. It also gives you time with each baby."),
          _en("Feeding both together (tandem feeding) saves time, especially "
              "at night. Many mothers start once latching is going well."),
          _en("A twin feeding pillow, or firm pillows on each side, holds the "
              "babies at the height of your breasts."),
          _en("The football hold, with a baby tucked under each arm, is a "
              "common way to feed two at once. Try it with a helper at "
              "first."),
          _en("Some mothers swap which baby feeds on which side each day, so "
              "both breasts are emptied evenly."),
        ],
      ),
      PvReadSection(
        heading: _en("What if one twin feeds well and the other doesn't?"),
        paragraphs: [
          _en("It's common for one twin to latch easily and the other to need "
              "more help, especially a smaller or earlier baby. It isn't a "
              "sign that anything is wrong with your milk."),
          _en("Some mothers put the stronger feeder on first to get the milk "
              "flowing, then bring the other baby to that breast. Ask a "
              "lactation counsellor to watch a feed. Small changes in position "
              "often help. If a baby isn't gaining weight, the paediatrician "
              "will guide what to do."),
        ],
      ),
      PvReadSection(
        heading: _en('What if we need top-ups?'),
        paragraphs: [
          _en("Some twins, especially early or small ones, need extra milk at "
              "first. It may be your expressed milk, donor milk or formula, as "
              "the paediatrician advises."),
          _en("Some hospitals in India have a human milk bank that gives donor "
              "milk to babies in the newborn unit. Ask whether yours does."),
          _en("Mixing breast milk and formula is fine. Any amount of your milk "
              "helps your babies."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I keep track of who fed when?'),
        paragraphs: [
          _en("In the first weeks it's easy to forget which baby fed last. A "
              "notebook, or a note on your phone with each baby's feeds and "
              "wet and dirty diapers, helps you and the doctor."),
          _en("Some parents feed the babies on the same rhythm: when one wakes "
              "to feed, they wake the other. It can give you longer breaks. "
              "Ask your paediatrician whether this suits your babies, "
              "especially if they were small or early."),
        ],
      ),
      PvReadSection(
        heading: _en('What help should I line up?'),
        bullets: [
          _en("A lactation counsellor or consultant. Ask your hospital before "
              "the birth. Many have one, and some counsellors visit at "
              "home."),
          _en("Someone to hand you a baby, a glass of water and something to "
              "eat at feeds in the early weeks."),
          _en("Someone to take over burping, changing and settling at night, "
              "so you can sleep between feeds."),
          _en("Your doctor or a counsellor if feeding hurts, a baby isn't "
              "gaining weight, or you feel low."),
        ],
        tip: PvReadTip(
          title: _en('Water and a snack within reach'),
          body: _en("Feeding two makes you hungry and thirsty. Keep a bottle "
              "of water and a snack wherever you usually feed."),
        ),
      ),
      PvReadSection(
        heading: _en('How do I look after myself?'),
        paragraphs: [
          _en("Sleep in blocks when someone else can settle the babies. "
              "Expressing some milk lets another person give a night feed "
              "from a bottle."),
          _en("Feeling low, tearful or overwhelmed is common in the first weeks "
              "with twins. If it lasts more than two weeks, tell your doctor. "
              "If you have any thought of harming yourself, call Tele-MANAS on "
              "14416, free at any hour."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to call the doctor or go to hospital'),
      body: _en("Go to hospital straight away if a baby has trouble breathing, "
          "turns blue or very pale, has a fever, or is floppy and hard to "
          "wake. Call your paediatrician today if a baby feeds poorly, looks "
          "yellow, or has fewer than six wet diapers a day after the first "
          "week. Call your doctor today if you have a hot, red, painful patch "
          "on your breast with a fever, or heavy bleeding after the birth."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I breastfeed twins after a caesarean?'),
        answer: _en("Yes. Ask the team to help you find a position that keeps "
            "weight off your wound, like the football hold."),
      ),
      PvReadFaq(
        question: _en('Should I eat more while feeding twins?'),
        answer: _en("You'll be hungrier, so eat to your appetite and drink to "
            "your thirst. Keep taking the supplements your doctor advises."),
      ),
      PvReadFaq(
        question: _en('Is it okay to use formula?'),
        answer: _en("Yes. Feeding twins is hard work. Well-fed babies and a "
            "mother who gets some rest matter most."),
      ),
    ],
    evidence: _en('WHO guideline, Protecting, promoting and supporting '
        'breastfeeding in facilities providing maternity and newborn services '
        "(2017) · Ministry of Health and Family Welfare, MAA (Mothers' "
        'Absolute Affection) programme (2016) · Ministry of Health and Family '
        'Welfare, National guidelines on lactation management centres in '
        'public health facilities (2017) · NICE guideline NG137, Twin and '
        'triplet pregnancy (2019).'),
    readNext: [
      'preg_twins_read_ready',
      'preg_twins_read_birth',
      'preg_twins_read_food',
    ],
  ),

  // ---------------------------------------------------------------------------
  //  Getting ready for two
  // ---------------------------------------------------------------------------
  PvRead(
    id: 'preg_twins_read_ready',
    hue: _hue,
    kicker: _kTwo,
    title: _en('Getting ready for two'),
    teaser: _en("What you need two of, what two babies can share, how to plan "
        "help at home, and your leave."),
    shortAnswer: _en("You need two of some things, like a safe place for each "
        "baby to sleep and car seats if you travel by car, but many things "
        "can be shared. Plan help at home for the first weeks, nights "
        "included. Get ready a little earlier than with one baby, since "
        "twins often come early."),
    scaleSetter: _en("Two babies don't have to mean double the shopping. This "
        "is a practical list with Indian homes in mind, plus the help that "
        "matters more than any gear."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en("Getting ready for twins can feel like preparing for a small "
            "army. Most of what makes the early weeks easier isn't gear at "
            "all. It's sleep, food and people. Still, a few things are worth "
            "having ready."),
      ]),
      PvReadSection(
        heading: _en('What do we need two of?'),
        bullets: [
          _en("A safe place for each baby to sleep: a cot, crib or basket with "
              "a firm, flat mattress, with the baby on their back and no "
              "pillows or soft toys."),
          _en("Car seats, if you'll travel by car, fitted before the "
              "birth."),
          _en("More clothes, swaddles and bedsheets than you think. Two babies "
              "means twice the spit-up."),
          _en("Diapers in bulk. A newborn can use 8 to 12 a day, so twins can "
              "go through 16 to 24."),
          _en("Bottles and a way to clean them, if you'll be expressing or "
              "giving top-ups."),
        ],
      ),
      PvReadSection(
        heading: _en('What can two babies share?'),
        bullets: [
          _en("A pram or stroller made for twins, side by side or one behind "
              "the other. Check it fits through your door and your lift."),
          _en("A changing mat, a bath tub and baby toiletries."),
          _en("A twin feeding pillow."),
          _en("A baby carrier, if someone else can carry the second baby."),
          _en("Toys and books, for a long while yet."),
        ],
        tip: PvReadTip(
          title: _en('Borrow and pass on'),
          body: _en("Twin families are often glad to hand things on. Ask "
              "around, or look for a twin parents' group in your city."),
        ),
      ),
      PvReadSection(
        heading: _en('How should we plan help at home?'),
        paragraphs: [
          _en("With twins, help matters more than anything you can buy. Plan "
              "it before the birth, and plan for nights as well as days. In "
              "many families the first 40 days are a time of rest for the "
              "mother. With twins that rest matters even more, and it's fine "
              "to ask for it."),
        ],
        bullets: [
          _en("Who will stay for the first weeks, and who will cover the "
              "nights? Many families take turns in shifts."),
          _en("Who will cook, clean and shop, so you and your partner can "
              "look after the babies?"),
          _en("If you'll hire help, such as a japa maid or a nanny, start "
              "looking early, and ask for someone who has cared for twins."),
          _en("If you have an older child, who will give them time and "
              "attention?"),
          _en("Keep a list of who to call for what, on the fridge and in your "
              "phone."),
          _en("Write down what helps you most, like a hot meal or an hour of "
              "sleep, so when people ask what they can do, you have an "
              "answer."),
        ],
      ),
      PvReadSection(
        heading: _en('How do we get through the first nights?'),
        bullets: [
          _en("Take turns. One of you sleeps while the other feeds or settles "
              "the babies."),
          _en("Keep a night station with diapers, wipes, clothes, burp cloths "
              "and water in one place."),
          _en("Keep the babies' sleep spaces in your room for the first six "
              "months."),
          _en("Let the house be messy for a while. Sleep comes first."),
        ],
      ),
      PvReadSection(
        heading: _en('What about leave, work and insurance?'),
        paragraphs: [
          _en("Under the Maternity Benefit Act, 1961, you may be entitled to "
              "up to 26 weeks of paid maternity leave, of which up to 8 weeks "
              "can be taken before your due date. Check with your HR how this "
              "works where you work."),
          _en("Twins often arrive early, so plan to hand over your work sooner "
              "than you would with one baby, and let your manager know the "
              "date may move."),
          _en("Your partner may have paternity leave through their employer, or "
              "under the service rules in a government job. It's "
              "worth asking early."),
          _en("Check with your health insurer whether newborn care, including "
              "a stay in the newborn unit, is covered, and from which day."),
        ],
      ),
      PvReadSection(
        heading: _en('When should everything be ready?'),
        paragraphs: [
          _en("Aim to have the essentials and your hospital bag ready by about "
              "30 weeks. Twins often come early, and it's easier to pack while "
              "you can still bend."),
          _en("Keep your latest scan report, your blood group and your twin "
              "type (for example 'DCDA twins') in your bag. The team at the "
              "hospital will want them."),
          _en("The hospital bag list in ParentVeda has an 'Expecting twins' "
              "switch. Turn it on and the list adds what two babies need."),
          _en("Save your hospital's labour ward number, and plan how you'll "
              "get there at any hour. If you can't get there safely, 108 is "
              "the free ambulance number in most states."),
        ],
      ),
    ],
    whenToSeeSomeone: _twinsUrgent,
    faqs: [
      PvReadFaq(
        question: _en('Do we need a bigger home?'),
        answer: _en("Not for the first months. Babies need very little space, "
            "and many twin families manage well in small flats."),
      ),
      PvReadFaq(
        question: _en('Can the twins sleep in the same cot?'),
        answer: _en("Ask your paediatrician. Many advise a separate safe sleep "
            "space for each baby, always on their backs."),
      ),
      PvReadFaq(
        question: _en('When should we start buying things?'),
        answer: _en("Most things can wait until the second half of pregnancy. "
            "Have sleep spaces, clothes and diapers ready by about 30 "
            "weeks."),
      ),
    ],
    evidence: _en('The Maternity Benefit Act, 1961, as amended in 2017 · '
        'American Academy of Pediatrics, Sleep-related infant deaths: '
        'updated recommendations for a safe infant sleeping environment '
        '(2022) · NICE guideline NG137, Twin and triplet pregnancy (2019).'),
    readNext: [
      'preg_twins_read_feeding',
      'preg_twins_read_birth',
      'preg_twins_read_food',
    ],
  ),
];

/// A read in this file by id, or null.
PvRead? twinsReadById(String id) {
  for (final r in kPregnancyReadsTwins) {
    if (r.id == id) return r;
  }
  return null;
}
