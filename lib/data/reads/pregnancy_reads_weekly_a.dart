// =============================================================================
//  Pregnancy reads — the weekly reads, written out (a: weeks 4–22)
// -----------------------------------------------------------------------------
//  The V3 pregnancy home's "Recommended reads" rail was fed by `kReadItems`
//  — twenty pieces of forty to a hundred words each. In the one reader they
//  opened as a title, a byline and five lines. The user, on the phone
//  (2026-09-18): *"the article is like not even there… The articles that are
//  not written, you can write them. You know you can have a reference
//  article — the one in the fertility window."*
//
//  So each weekly read is now a full `PvRead` at the library's bar
//  (`assertShape`: four sections, three headings, an FAQ, six hundred words,
//  a named source, an urgent when-to-see-someone), and `ReadItemScreen`
//  opens the full piece when one exists for the item's id
//  (`preg_week_read_<id>`). The `ReadItem` seeds stay — the rail, Saved and
//  search still read their titles, reasons and reading times.
//
//  The clinical rules at the head of pregnancy_reads.dart apply unchanged:
//  never a diagnosis, never contradict her clinician, named sources, costs
//  carry a date. Nothing here tells her what HER result means.
//
//  Rewritten 2026-09-29 to docs/PREG-VOICE.md, each read with a shortAnswer.
//
//  ⚠️ TRUST, 2026-09-29 (pregnancy gap analysis, "Behind · Trust", P1): these
//  reads used to carry named reviewers and "reviewed September 2026". No
//  doctor has reviewed them and the names belonged to nobody. Every read is
//  now `reviewed: false` under the desk byline, set explicitly because
//  `PvRead.reviewed` defaults to true. A reviewer goes back only when a real,
//  named review has happened.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The prefix that ties a full read to its weekly `ReadItem`.
const String kPregWeekReadPrefix = 'preg_week_read_';

const double _hue = 344;

/// The honest byline until a real, named clinician has read the piece.
const LocalizedText _desk =
    LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _deskRole = LocalizedText(
    en: 'Written by the ParentVeda team', hi: 'Written by the ParentVeda team');

final List<PvRead> kPregnancyReadsWeeklyA = [
  // ---------------------------------------------------------------------------
  //  managing_nausea · weeks 5–14
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}managing_nausea',
    hue: _hue,
    kicker: _en('First trimester'),
    title: _en('Managing morning sickness'),
    teaser: _en("It's rarely only in the morning, it usually eases by week "
        "14, and there's more you can do than eat dry biscuits."),
    shortAnswer: _en('Morning sickness can come at any hour. It usually starts '
        'around week 5 or 6, peaks around week 9 and eases for most women by '
        "weeks 12 to 14. Small, frequent meals and ginger help many women, "
        "and if you can't keep fluids down, your doctor has safe medicines "
        'that work.'),
    scaleSetter: _en('About seven in ten pregnant women feel sick in the first '
        "trimester. For most, it's a sign the pregnancy hormones are doing "
        'what they should. You can feel miserable and be completely normal at '
        'the same time. A small number of women need more than home care, '
        'which is why the last part of this piece matters.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('First, let go of the name. Nausea in early pregnancy can come at '
            "any hour. For many women it's worst in the late afternoon, on an "
            'empty stomach, or the moment a smell drifts in from the kitchen.'),
        _en('It usually starts between weeks five and six, peaks around week '
            'nine, and eases for most women by weeks twelve to fourteen. Some '
            'carry a little of it into the second trimester. A very few have '
            'it to the end.'),
        _en("Nobody is fully sure what causes it. Rising hCG and oestrogen, a "
            'sharper sense of smell, a stomach that empties more slowly and '
            "low blood sugar between meals all play a part. That's why no "
            'single remedy works for everyone. The ones that help tend to work '
            'on your stomach and your blood sugar, not on the hormones.'),
      ]),
      PvReadSection(
        heading: _en('What helps?'),
        paragraphs: [
          _en('Small and often is the advice every guideline agrees on. An '
              'empty stomach makes nausea worse, and so does a full one. '
              'Before you sit up in the morning, eat something dry and plain: '
              'a few Marie biscuits, a handful of murmura, a piece of toast. '
              'Then have five or six small meals instead of three big ones.'),
          _en('Protein and slow carbohydrates keep you going longer than sugar '
              'does: dal, curd, peanuts, a boiled egg, khichdi, a banana with '
              'milk. Cold food often goes down better than hot, because it '
              'smells less. Sip fluids between meals rather than with them, '
              "so your stomach doesn't fill up on water."),
        ],
        bullets: [
          _en('Ginger has the best evidence of any kitchen remedy. Try it as '
              'tea, in warm water with a pinch of salt, or as a dry-ginger '
              'sweet.'),
          _en('Lemon: the smell alone helps many women. Keep a cut half in a '
              'small box for the bus or the office.'),
          _en('Vitamin B6 (pyridoxine), 10 to 25 mg up to three times a day, '
              'is the first medicine most guidelines suggest. You can buy it '
              'over the counter in India, but ask your doctor before you '
              'start it.'),
          _en('Acupressure wristbands at the P6 point have mixed evidence, but '
              'they do no harm.'),
        ],
      ),
      PvReadSection(
        heading: _en('What makes it worse?'),
        paragraphs: [
          _en('Iron tablets are a common trigger. Many women stop them in the '
              'first trimester without telling anyone, and then feel guilty. '
              'Tell your doctor instead. Most will move iron to after twelve '
              'weeks and keep only folic acid going, which is the one that '
              'matters most now. Taking any tablet with food, and at night '
              'rather than in the morning, also helps.'),
          _en('Strong cooking smells are a reliable trigger, tadka most of '
              'all. Open the kitchen window, cook in a batch when you feel '
              'best, or ask someone else to do the frying for a few weeks. '
              "That isn't weakness. It's looking after yourself. Tiredness "
              'makes nausea worse too, so the afternoon rest you feel you '
              'should skip is part of the treatment.'),
        ],
      ),
      PvReadSection(
        heading: _en('When is it more than morning sickness?'),
        paragraphs: [
          _en('The severe form is called hyperemesis gravidarum. It means '
              'vomiting several times a day, not keeping fluids down, losing '
              'weight and passing very little dark urine. It affects around '
              'one to three women in a hundred.'),
          _en("It isn't a lack of willpower. It's a medical condition that "
              'responds to treatment, sometimes with a short hospital stay '
              'for fluids and anti-sickness medicine.'),
          _en('There are anti-sickness medicines that are safe in pregnancy, '
              'such as doxylamine with B6, and others your obstetrician can '
              "choose from. You shouldn't be left to \"get through it\" when "
              'a prescription would let you eat.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does it harm the baby?'),
        paragraphs: [
          _en("Ordinary morning sickness doesn't harm your baby. In the first "
              'trimester your baby is tiny and takes what it needs from your '
              "reserves. A few weeks of eating less well than you'd like "
              "doesn't show up in birth weight."),
          _en("What matters is fluids. If you're keeping water down, you're "
              'doing enough.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en("You can't keep any fluids down for 24 hours, you're vomiting "
          'more than three or four times a day, your urine is dark and '
          "scanty, you feel dizzy when you stand up, you've lost more than "
          'about two kilos, or the vomiting starts for the first time after '
          'the first trimester. These can be signs of dehydration or of '
          'something other than morning sickness, and both can be treated.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it a good sign if I feel very sick?'),
        answer: _en('Nausea is loosely linked with a healthy rise in hormones, '
            'but plenty of healthy pregnancies have none at all. Feeling '
            "sick, or not feeling sick, doesn't tell you anything you need "
            'to act on.'),
      ),
      PvReadFaq(
        question: _en('Can I take my usual antacid?'),
        answer: _en('Most simple antacids are considered safe. Check yours '
            'with your doctor or chemist, because a few contain ingredients '
            'not recommended in pregnancy.'),
      ),
      PvReadFaq(
        question: _en('Will it come back later?'),
        answer: _en('For most women it fades and stays away. Heartburn is a '
            "different thing. It's common in the third trimester, as your "
            'baby presses up on your stomach.'),
      ),
    ],
    evidence: _en('ACOG Practice Bulletin 189, Nausea and Vomiting of '
        'Pregnancy (reaffirmed 2023); NICE guideline NG201 Antenatal care '
        '(2021); FOGSI good clinical practice recommendations on hyperemesis.'),
    readNext: ['${kPregWeekReadPrefix}first_trimester', '${kPregWeekReadPrefix}nutrition_t2'],
  ),

  // ---------------------------------------------------------------------------
  //  first_scan · weeks 7–13
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}first_scan',
    hue: 206,
    kicker: _en('First trimester'),
    title: _en('Your first scan, explained'),
    teaser: _en("What the dating scan looks for, why it may be done on your "
        'tummy or internally, and what the numbers on the report mean.'),
    shortAnswer: _en('Your first scan checks that the pregnancy is in the '
        "womb, looks for a heartbeat and measures how far along you are. "
        "It's painless and takes a few minutes. The date it gives becomes "
        'the due date every later scan is compared with.'),
    scaleSetter: _en('The first scan is the one that turns a positive test '
        'into a pregnancy you can see. It answers three questions. Is the '
        'pregnancy in the right place? Is there a heartbeat? How far along '
        'are you? It also sets the due date that every later scan is '
        'measured against.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('In India the first scan is usually done between six and nine '
            "weeks, often on the day your pregnancy is confirmed at a clinic. "
            'Sometimes there is another at eleven to thirteen weeks, for the '
            'nuchal translucency scan. In some public hospitals the first '
            "scan isn't until twelve weeks. Neither timing is wrong. They "
            'answer slightly different questions.'),
        _en('Before about eight weeks the pregnancy is small, so an internal '
            'scan (transvaginal scan) gives a much clearer picture than a '
            "scan on your tummy. A slim probe goes inside. It isn't painful, "
            'takes a few minutes, and is the usual way to see an early '
            'heartbeat. After nine or ten weeks a scan on your tummy is '
            'usually enough, and a full bladder helps.'),
      ]),
      PvReadSection(
        heading: _en('What is the sonographer checking?'),
        bullets: [
          _en('Where: that the sac is inside the womb (uterus). This rules out '
              'an ectopic pregnancy.'),
          _en('How many: one sac or two.'),
          _en('Heartbeat: usually visible from six weeks. The rate is noted, '
              'and at this stage it is typically 110 to 170 beats a minute.'),
          _en('Size: the crown-rump length (CRL), your baby measured from head '
              'to bottom. This gives the most accurate dating of the whole '
              'pregnancy.'),
          _en('A quick look at your ovaries and the fluid around them.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why can the scan change your due date?'),
        paragraphs: [
          _en('The date from your last period assumes a 28-day cycle and '
              'ovulation on day 14. Many cycles are neither. A CRL measured '
              'before fourteen weeks dates a pregnancy to within about five '
              'days.'),
          _en('So if the scan date and the period date differ by more than a '
              'week, doctors go by the scan. The scan isn\'t "wrong" about '
              "your period. It's right about your baby."),
          _en('Once an early scan has set your due date, later scans usually '
              "don't change it, even if your baby measures big or small then. "
              'Later size shows growth, not age.'),
        ],
      ),
      PvReadSection(
        heading: _en('How do I read the report?'),
        paragraphs: [
          _en('The report will list GS (gestational sac), YS (yolk sac), CRL, '
              'FHR (fetal heart rate), and an estimated gestational age with '
              'an EDD (your due date).'),
          _en('"Subchorionic" or "retroplacental" collections are small bleeds '
              'beside the sac. They are common and usually settle. "Corpus '
              'luteum cyst" is your ovary doing its job. None of these lines '
              'is a verdict. Your doctor reads them together with your history '
              'and your dates.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if a heartbeat isn't seen yet?"),
        paragraphs: [
          _en('Very early on, under six weeks or when the dates are uncertain, '
              'a scan can be too early to see it. The usual next step is a '
              'repeat scan in seven to fourteen days, sometimes with a blood '
              'test for hCG in between.'),
          _en('A wait like that can be one of the hardest weeks of a '
              "pregnancy. It's also the honest answer: the scan can't say more "
              'than it can see. If you can, take someone with you to the '
              'repeat scan.'),
        ],
      ),

      PvReadSection(
        heading: _en("What can't this scan tell you?"),
        paragraphs: [
          _en('A first scan says where the pregnancy is, whether it has a '
              "heartbeat, and how old it is. It doesn't say whether your baby "
              "is developing normally. That's the anomaly scan at twenty "
              "weeks. It also doesn't predict how the pregnancy will go. A "
              'strong heartbeat at seven weeks is reassuring because the '
              "numbers say so, not because the scan can see the future."),
          _en("If you're bleeding, it can't always tell you why. A subchorionic "
              'bleed seen on the scan is the most common reason and usually '
              'settles. A scan that shows a healthy pregnancy and no clear '
              "cause hasn't failed. Either way the plan is the same: rest, no "
              'heavy lifting, and another look in one to two weeks.'),
          _en("Nuchal translucency, the fluid at the back of your baby's neck, "
              'is measured only between 11 and 13 weeks, and only if you have '
              'chosen first-trimester screening. If your first scan was at '
              "seven weeks, it won't be on the report. That's timing, not "
              'something missed.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go the same day if'),
      body: _en('You have pain low down on one side of your tummy, pain at the '
          'tip of your shoulder, bleeding with pain, or you feel faint. This '
          'applies before the first scan or after it. These can be signs of '
          'an ectopic pregnancy and are checked urgently. Any bleeding in '
          'early pregnancy is worth a call.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is an internal scan safe for the baby?'),
        answer: _en('Yes. The probe sits in the vagina, well away from the '
            'cervix and the pregnancy. Ultrasound at the levels used for '
            'scans has no known harm.'),
      ),
      PvReadFaq(
        question: _en('Can the scan tell the sex?'),
        answer: _en('Not at this stage. In India, telling anyone the sex of a '
            'baby before birth is illegal at any stage, under the PCPNDT Act.'),
      ),
      PvReadFaq(
        question: _en('Do I need to bring anything?'),
        answer: _en('The date of your last period and any earlier reports. For '
            'a scan on your tummy, come with a comfortably full bladder.'),
      ),
    ],
    evidence: _en('ISUOG practice guidelines on first-trimester ultrasound '
        '(2023); NICE NG201; the Pre-Conception and Pre-Natal Diagnostic '
        'Techniques Act, 1994.'),
    readNext: ['${kPregWeekReadPrefix}first_trimester', 'preg_scan_read_calm'],
  ),

  // ---------------------------------------------------------------------------
  //  first_trimester · weeks 4–13
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}first_trimester',
    hue: _hue,
    kicker: _en('First trimester'),
    title: _en('Understanding the first trimester'),
    teaser: _en('Thirteen weeks in which almost everything is built and '
        "almost nothing shows. What's happening, what you'll feel, and what "
        'to do now.'),
    shortAnswer: _en('The first trimester runs to the end of week 13. By week '
        "12 your baby has a beating heart, every major organ and a face, "
        "while you mostly feel tired and a little sick. It's the time to take "
        'folic acid, book your first visit and ask about any medicines you '
        'take.'),
    scaleSetter: _en('By the end of week twelve your baby has a beating heart, '
        'every major organ in place, fingers and a face. All of that happens '
        "while you look the same from the outside and feel, mostly, tired "
        "and a bit sick. It's the busiest stretch of pregnancy and the "
        'least visible one.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Pregnancy is counted from the first day of your last period. So '
            "by the time a test turns positive, you're already about four "
            'weeks along, and your baby is around two weeks old. That way of '
            'counting confuses everyone at first. The first trimester runs '
            'to the end of week thirteen.'),
        _en('The hormone doing most of the work is hCG. It doubles every two '
            'to three days early on, and it is what the test picks up. '
            'Progesterone keeps the lining of the womb in place and relaxes '
            "muscle all over your body. That's why your bowels slow down, you "
            'need to pass urine often, and you feel warm and sleepy.'),
      ]),
      PvReadSection(
        heading: _en('What will you probably feel?'),
        bullets: [
          _en("Tiredness that's hard to explain to anyone. Your body is "
              "building a placenta, and that's real work."),
          _en('Nausea, at any hour, usually easing by week 14.'),
          _en('Tender, fuller breasts and darker skin around the nipples '
              '(areolae).'),
          _en('Needing to pass urine often, from about week six.'),
          _en('Going off foods, often coffee, tea and anything fried, and '
              'odd cravings.'),
          _en("Moods that swing more than you'd like. Hormones, tiredness "
              'and the size of the news, all at once.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you do now?'),
        paragraphs: [
          _en('Take folic acid, 400 micrograms a day. Ideally it starts before '
              'conception and carries on through week twelve. Some women are '
              'advised a higher dose. It cuts the risk of neural tube defects. '
              'The neural tube closes by week six, so starting when you find '
              "out is a little late, but it's still worth it."),
          _en('Book your first antenatal visit. In most Indian cities that '
              'means blood group, haemoglobin, thyroid, blood sugar and an '
              'infection screen, a blood pressure check, and a dating scan. If '
              "you take any regular medicine, ask now whether it stays. Don't "
              'stop it on your own.'),
          _en('Stop alcohol and smoking completely. Keep caffeine under about '
              '200 mg a day (roughly two small cups of coffee). Avoid '
              'unpasteurised milk and soft cheeses, raw or undercooked eggs '
              "and meat, and papaya that isn't fully ripe."),
        ],
      ),
      PvReadSection(
        heading: _en('What about the worry underneath it all?'),
        paragraphs: [
          _en('Early loss is common. It happens in around one confirmed '
              'pregnancy in six or seven, mostly before week twelve. Most are '
              'caused by a chromosome problem present from the start, which '
              'nothing you did caused and nothing could have prevented.'),
          _en('Once a heartbeat has been seen at eight weeks, the chance of '
              'the pregnancy continuing is above ninety per cent.'),
          _en('Light spotting happens in about a quarter of pregnancies, and '
              "most of those go on normally. It's still always worth telling "
              'your doctor, because the ones that need attention look the '
              'same at first.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should you tell people?'),
        paragraphs: [
          _en('There is no rule. Many couples wait until twelve weeks, for the '
              'reason above. Some tell close family sooner, so the tiredness '
              'and nausea have an explanation and a helper.'),
          _en("Whatever you choose, tell your employer in writing when you're "
              'ready. The Maternity Benefit Act protects twenty-six weeks of '
              'paid leave for your first two children.'),
        ],
      ),

      PvReadSection(
        heading: _en('Which medicines should you keep taking?'),
        paragraphs: [
          _en('Many women stop thyroid tablets, asthma inhalers, epilepsy '
              'medicine, antidepressants, blood pressure tablets or insulin '
              'in the first trimester to be careful. For most of them, '
              'stopping is riskier than carrying on. Levothyroxine in '
              'particular usually needs to go up in early pregnancy, not '
              'stop. Take a list of everything you take to your first visit '
              'and ask about each one.'),
          _en("The ones to avoid without asking are the ones you'd reach for "
              'without thinking: ibuprofen and other NSAIDs, high-dose vitamin '
              'A, most acne treatments, and the ayurvedic or herbal mixtures a '
              'relative is sure are harmless. Paracetamol is the painkiller '
              "for pregnancy. A chemist can check anything else in a minute."),
        ],
      ),

      PvReadSection(
        heading: _en('How often will you see your doctor?'),
        paragraphs: [
          _en('After the first visit, expect a check every four weeks until '
              '28 weeks, then every two weeks, then weekly from 36. Each early '
              'visit checks your weight, blood pressure and urine. From '
              "around 12 weeks your doctor listens for your baby's heartbeat."),
          _en('The dating scan, the 11-to-13-week screening scan if you choose '
              'it, and the first blood tests all fall in this trimester. So '
              "the first three months are busier at the clinic than the "
              'middle three will be.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You have bleeding heavier than spotting, cramping pain, pain '
          'on one side, pain at the tip of your shoulder, fever, burning when '
          "you pass urine, or you can't keep fluids down. None of these is a "
          'verdict. All of them are checked quickly.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I keep exercising?'),
        answer: _en("Yes, at the level you're used to. Walking, swimming, "
            'prenatal yoga and light weights are all fine. Avoid contact '
            "sports and anything you could fall from. If you weren't "
            'exercising before, start gently.'),
      ),
      PvReadFaq(
        question: _en('Is it safe to travel?'),
        answer: _en("Usually, yes. The first trimester isn't a reason to "
            'cancel a trip. Nausea and tiredness are the practical limits. '
            'Carry your reports and know where the nearest hospital is.'),
      ),
      PvReadFaq(
        question: _en('Why am I so tired?'),
        answer: _en('Progesterone, a rising blood volume, and the work of '
            'building a placenta. For most women it eases in the second '
            'trimester.'),
      ),
    ],
    evidence: _en('NICE NG201 Antenatal care (2021); WHO recommendations on '
        'antenatal care (2016); FOGSI folic acid guidance; the Maternity '
        'Benefit (Amendment) Act, 2017.'),
    readNext: ['${kPregWeekReadPrefix}managing_nausea', '${kPregWeekReadPrefix}first_scan'],
  ),

  // ---------------------------------------------------------------------------
  //  nutrition_t2 · weeks 14–27
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}nutrition_t2',
    hue: 104,
    kicker: _en('Second trimester'),
    title: _en('Eating well in the second trimester'),
    teaser: _en('Your appetite comes back, your baby starts growing fast, and '
        "what's on your plate matters more than how much of it there is."),
    shortAnswer: _en("You're not eating for two. You need about 340 extra "
        'calories a day now, roughly a glass of milk and a banana. What '
        'matters more is iron, calcium, protein and folate, which an ordinary '
        'Indian plate often falls short on.'),
    scaleSetter: _en("You aren't eating for two. In the second trimester your "
        'body needs about 340 extra calories a day. That\'s a glass of milk '
        'and a banana, or a bowl of dal and a roti. What changes more is what '
        'those calories need to carry: iron, calcium, protein and folate, in '
        "amounts an ordinary Indian plate doesn't always reach."),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('For most women the nausea lifts somewhere between weeks twelve '
            'and sixteen, and food is welcome again. In these weeks your baby '
            'grows from about 40 grams to nearly a kilo, and the bones start '
            'to harden. Your own blood volume rises by almost half.'),
        _en('Each of those needs a particular nutrient. Those are exactly '
            'where Indian diets most often fall short.'),
      ]),
      PvReadSection(
        heading: _en('Which four nutrients matter most?'),
        bullets: [
          _en('Iron: about 27 mg a day. Your blood volume is rising and your '
              'baby is storing iron for its first six months. Anaemia affects '
              'roughly half of pregnant women in India. Get it from dal, '
              'rajma, chana, green leafy vegetables, jaggery, dates, and the '
              'tablet your doctor prescribes. Take it with a vitamin C food, '
              'not with tea, which blocks it.'),
          _en('Calcium: 1,000 mg a day. Milk, curd, paneer, ragi, sesame '
              "(til), and small fish with bones. If you don't eat dairy, tell "
              'your doctor. A supplement is usually advised.'),
          _en('Protein: about 60 grams a day, up from 45. Dal at both meals, '
              'eggs, curd, paneer, chicken or fish, peanuts and soya. A '
              'vegetarian plate can reach it, as long as there is dal or a '
              'pulse at every meal.'),
          _en('Folate and B12: folate from leafy greens and pulses still '
              'matters. B12 is found almost only in animal foods, so '
              'vegetarians are often prescribed it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What can a day of eating look like?'),
        paragraphs: [
          _en('Breakfast: poha or upma with peanuts and a glass of milk, or an '
              'egg with toast and fruit. Mid-morning: a few dates or a banana. '
              'Lunch: roti, sabzi, dal, curd, salad. Evening: sprouts chaat, '
              'roasted chana, or fruit with a little paneer. Dinner: rice or '
              'roti with dal, fish or chicken, and a green vegetable. Drink '
              'water through the day, about two and a half litres, more in '
              'summer. If you\'re out at work all day, a tiffin with roasted '
              'chana, a fruit and a small box of curd rice covers the gaps.'),
          _en('Small, frequent meals still help. Now it\'s less about nausea '
              'and more about the heartburn and fullness that come as your '
              'womb rises. Eating your vegetables before the rice keeps blood '
              'sugar steadier. That habit is worth building before the '
              'glucose test at 24 to 28 weeks.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you go easy on?'),
        paragraphs: [
          _en('Keep caffeine under about 200 mg a day. Large predatory fish '
              '(shark, swordfish, king mackerel) carry mercury. Smaller fish '
              'like rohu, pomfret, sardines and hilsa are good sources of '
              'omega-3, and two or three times a week is encouraged.'),
          _en('The real infection risks are unpasteurised milk, soft '
              'unpasteurised cheese, raw sprouts washed in unknown water, and '
              "street food you can't see being cooked."),
          _en("Sugar and refined flour aren't forbidden. They just push out "
              'the foods above. A sweet after a meal is a pleasure, not a '
              'problem. A packet of biscuits instead of lunch is.'),
        ],
      ),
      PvReadSection(
        heading: _en('How much weight should you gain?'),
        paragraphs: [
          _en('If you started at a healthy weight, the usual gain over the '
              'whole pregnancy is 11 to 16 kilos. Most of it comes in the '
              'second and third trimesters, at roughly half a kilo a week.'),
          _en('The range is wide, and your doctor will have a target for you. '
              "It's there for your baby's growth and your own health "
              'afterwards, not as a number to chase.'),
        ],
      ),

      PvReadSection(
        heading: _en("What if you're vegetarian?"),
        paragraphs: [
          _en('A vegetarian pregnancy works well, and most Indian pregnancies '
              'are vegetarian. Three nutrients need planning rather than luck.'),
          _en('Iron from plants is absorbed less well than iron from meat. So '
              'the tablet matters more, and the vitamin C at each meal '
              "(a squeeze of lemon, a tomato, amla) isn't just decoration."),
          _en('Vitamin B12 comes almost only from animal foods. Milk and curd '
              'give some, and most doctors prescribe it.'),
          _en("Omega-3 fats, which your baby's brain uses in the third "
              'trimester, come from walnuts, flaxseed and chia in plant form. '
              'An algae-based DHA supplement gives the form fish provide, if '
              'you want it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell your doctor soon if'),
      body: _en("You're unusually breathless or your heart races with little "
          "effort, you crave ice or clay, you're very pale, or you're losing "
          'weight in the second trimester. These are worth a blood test the '
          'same week. The causes are common and can be treated.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I eat papaya and pineapple?'),
        answer: _en('Ripe papaya is fine and a good source of vitamin C. Raw '
            'or half-ripe papaya contains latex and is best avoided. '
            'Pineapple in ordinary amounts is safe.'),
      ),
      PvReadFaq(
        question: _en('Is ghee good in pregnancy?'),
        answer: _en("In ordinary amounts, yes. It's a fat like any other. The "
            'old advice to eat a lot of it to ease labour has no evidence '
            'behind it.'),
      ),
      PvReadFaq(
        question: _en('Do I need a multivitamin?'),
        answer: _en('Iron, folic acid and calcium are usually prescribed. A '
            "general multivitamin is optional and doesn't replace food. "
            "Vitamin D is often low in Indian women, so it's worth checking."),
      ),
    ],
    evidence: _en('ICMR–NIN Dietary Guidelines for Indians (2024); NICE '
        'NG201; National Family Health Survey 5 anaemia figures; WHO '
        'recommendations on antenatal care (2016).'),
    readNext: ['preg_diet_read_add_now', 'preg_cond_read_iron'],
  ),

  // ---------------------------------------------------------------------------
  //  partner_support · weeks 12–40
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}partner_support',
    hue: 205,
    kicker: _en('For both of you'),
    title: _en('How your partner can support you now'),
    teaser: _en('Not "be supportive", but a list of things your partner can '
        'do, trimester by trimester, that make a real difference.'),
    shortAnswer: _en('The support that helps most is practical: taking over '
        'jobs, coming to scans, sharing the diary and handling the family. '
        'Women whose partners are involved go to more check-ups and are less '
        'likely to be depressed afterwards. Read this one together.'),
    scaleSetter: _en('Women whose partners are involved in the pregnancy go '
        'to more antenatal visits, are less likely to be anaemic at delivery, '
        'and are less likely to develop depression afterwards. That comes '
        'from the studies, not from sentiment. The help that works is '
        'practical and specific, and it starts before anyone can see a bump.'),
    author: _desk,
    authorRole: _deskRole,
    reviewed: false,
    sections: [
      PvReadSection(paragraphs: [
        _en('Most partners want to help and aren\'t sure how. The pregnancy '
            'is happening in your body. The appointments are in office hours. '
            'The advice coming from every direction is aimed at you.'),
        _en('The way through is for your partner to take on tasks, not just '
            'ask about feelings. A partner who keeps the appointment diary '
            'does more than one who asks "how are you feeling" every evening.'),
      ]),
      PvReadSection(
        heading: _en('In the first trimester'),
        bullets: [
          _en('Take over the cooking, or at least the frying, while smells '
              'set off your nausea.'),
          _en('Keep biscuits by the bed and the water bottle full.'),
          _en('Be the one who remembers the folic acid.'),
          _en('Come to the first scan. It\'s when the pregnancy becomes real '
              'for both of you, and nobody regrets being there.'),
          _en('Handle the relatives. Deciding together who is told and when, '
              'and then sticking to it, is a real job.'),
        ],
      ),
      PvReadSection(
        heading: _en('In the second trimester'),
        bullets: [
          _en('Learn the names of the tests (anomaly scan, glucose test, '
              'growth scan) and the week each one falls in. Then the diary is '
              "shared, not carried in one head."),
          _en('Walk together in the evening. Exercise is easier to keep up '
              'as a pair.'),
          _en('Have the money conversation early: what the hospital package '
              'covers, what insurance covers, and what leave each of you can '
              "take. Paternity leave isn't law in India. Many employers offer "
              'it anyway, but it needs asking for.'),
          _en('Talk to the baby. From about 24 weeks your baby hears voices '
              'and will know your partner\'s at birth.'),
        ],
      ),
      PvReadSection(
        heading: _en('In the third trimester'),
        bullets: [
          _en('Own the hospital bag and the route: where to park, which '
              "entrance is open at 3am, whose phone has the doctor's number."),
          _en('Learn the signs of labour and the reasons to go in early. Then '
              'two people know them when it matters.'),
          _en('Come to the birth class if there is one. Knowing what a '
              'contraction looks like from outside, and what to do with your '
              'hands, changes what it\'s like to be in the room.'),
          _en('Plan the first two weeks at home before the baby arrives: who '
              'cooks, who sleeps when, who handles the visitors.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should your partner watch for?'),
        paragraphs: [
          _en('Partners are often the first to notice depression or anxiety '
              'in pregnancy. They see the withdrawal you might not mention at '
              'a check-up. Low mood most days for two weeks, losing interest '
              "in things, or not sleeping even when you could. These are "
              'worth raising with the doctor together, rather than waiting '
              'for you to bring them up.'),
          _en('The danger signs of pregnancy are easier to act on when two '
              'people know them. They are heavy bleeding, a severe headache '
              'with vision changes, sudden swelling of the face and hands, '
              'your baby moving much less, fever, or fluid leaking. Read them '
              'once together.'),
        ],
      ),

      PvReadSection(
        heading: _en('What about the mother-in-law?'),
        paragraphs: [
          _en('In many Indian homes the person with the most opinions about '
              'the pregnancy is your mother-in-law. Your partner\'s most '
              'useful job is to be the one who says "the doctor said", so '
              "you don't have to."),
          _en('Agree in advance on the two or three things that aren\'t up '
              'for debate: the iron tablets, the scan schedule, the hospital. '
              'Then let him carry them into the family. That takes away a '
              'daily strain no foot massage can fix.'),
          _en('A note for the partner reading this: the pregnancy is happening '
              'to her, but the household belongs to both of you. Take one '
              'regular job completely, like the morning tea, the evening '
              'cooking or the bills, and keep it up without being reminded. '
              'That is what support looks like from the inside.'),
        ],
      ),

      PvReadSection(
        heading: _en("And your partner's own health?"),
        paragraphs: [
          _en('Partners get less sleep, more worry and no appointments of '
              'their own. Around one father in ten meets the criteria for '
              'depression in the year around the birth.'),
          _en('The same rule applies. Two weeks of low mood is a reason to '
              "say so, to you or to a doctor. It isn't something to carry "
              'alone to spare you.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Go to hospital, don't wait, if"),
      body: _en('There is heavy bleeding, a severe headache with blurred '
          'vision or flashing lights, sudden swelling of the face or hands, '
          "a clear drop in your baby's movements after 28 weeks, a fever "
          'over 38°C, or fluid leaking before 37 weeks. Call the hospital on '
          "the way. If you feel faint or are in severe pain, your partner "
          "shouldn't drive you: call an ambulance."),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is sex safe during pregnancy?'),
        answer: _en('In a normal pregnancy, yes, all the way through. Your '
            'doctor will tell you if there\'s a specific reason to avoid it, '
            'such as a low placenta or a history of preterm labour.'),
      ),
      PvReadFaq(
        question: _en('She is irritable with me. Is that the pregnancy?'),
        answer: _en('Often, partly. Tiredness, nausea, discomfort and a very '
            'big change all land on the nearest person. It isn\'t a verdict '
            "on you. It's a reason to do the jobs above without being asked."),
      ),
    ],
    evidence: _en('WHO recommendations on health promotion interventions '
        'for maternal and newborn health (2015) on male involvement; '
        'Yargawa & Leonardi-Bee, Journal of Epidemiology and Community '
        'Health (2015); NICE NG201.'),
    readNext: ['${kPregWeekReadPrefix}talking_baby', '${kPregWeekReadPrefix}hospital_bag'],
  ),
];
