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
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The prefix that ties a full read to its weekly `ReadItem`.
const String kPregWeekReadPrefix = 'preg_week_read_';

const double _hue = 344;

final List<PvRead> kPregnancyReadsWeeklyA = [
  // ---------------------------------------------------------------------------
  //  managing_nausea · weeks 5–14
  // ---------------------------------------------------------------------------
  PvRead(
    id: '${kPregWeekReadPrefix}managing_nausea',
    hue: _hue,
    kicker: _en('First trimester'),
    title: _en('Managing morning sickness'),
    teaser: _en('It is rarely only in the morning, it usually eases by week '
        '14, and there is more you can do about it than eat dry biscuits.'),
    scaleSetter: _en('About seven in ten pregnant women feel sick in the first '
        'trimester, and for most of them it is a sign the pregnancy hormones '
        'are doing exactly what they should. Miserable and normal can be true '
        'at the same time — and a small number of women need more than home '
        'measures, which is why the last section of this piece matters.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('The name is the first thing to let go of. Nausea in early '
            'pregnancy comes at any hour, and for many women it is worst in '
            'the late afternoon, on an empty stomach, or the moment a smell '
            'arrives from the kitchen. It usually begins between weeks five '
            'and six, peaks around week nine, and eases for most women by '
            'weeks twelve to fourteen. A minority carry some of it into the '
            'second trimester; a very few carry it to the end.'),
        _en('What causes it is not fully settled. Rising hCG and oestrogen, '
            'a more sensitive sense of smell, slower emptying of the stomach '
            'and low blood sugar between meals all play a part. That is why '
            'no single remedy works for everyone, and why the ones that work '
            'tend to work on the stomach and the sugar rather than on the '
            'hormones.'),
      ]),
      PvReadSection(
        heading: _en('What actually helps'),
        paragraphs: [
          _en('Small and often is the rule that survives every guideline. An '
              'empty stomach makes nausea worse, and so does a full one. '
              'Something dry and plain before you sit up in the morning — a '
              'few Marie biscuits, a handful of murmura, a piece of toast — '
              'then five or six small meals rather than three large ones.'),
          _en('Protein and complex carbohydrates hold you longer than sugar '
              'does: dal, curd, peanuts, a boiled egg, khichdi, a banana with '
              'milk. Cold food often goes down better than hot, because it '
              'smells less. Sipping fluids between meals rather than with '
              'them keeps the stomach from filling up on water.'),
        ],
        bullets: [
          _en('Ginger — as tea, in warm water with a pinch of salt, or as a '
              'dry-ginger sweet — has the best evidence of any kitchen remedy.'),
          _en('Lemon: the smell alone helps many women; keep a cut half in a '
              'small box for the bus or the office.'),
          _en('Vitamin B6 (pyridoxine) 10 to 25 mg up to three times a day is '
              'the first-line medicine in most guidelines and is available in '
              'India over the counter — ask your doctor before starting it.'),
          _en('Acupressure wristbands at the P6 point have mixed evidence but '
              'no downside.'),
        ],
      ),
      PvReadSection(
        heading: _en('The things that make it worse'),
        paragraphs: [
          _en('Iron tablets are a common trigger, and many women stop them '
              'silently in the first trimester and feel guilty. Tell your '
              'doctor instead: most will move iron to after twelve weeks and '
              'keep only folic acid going, which is the one that matters '
              'most now. Taking any tablet with food rather than on an empty '
              'stomach, and at night rather than in the morning, helps.'),
          _en('Strong cooking smells, tadka especially, are a reliable '
              'trigger. Opening the kitchen window, cooking in a batch when '
              'you feel best, or asking someone else to do the frying for a '
              'few weeks is not weakness; it is management. Tiredness makes '
              'nausea worse too, so the afternoon rest you feel you should '
              'skip is part of the treatment.'),
        ],
      ),
      PvReadSection(
        heading: _en('When it is more than morning sickness'),
        paragraphs: [
          _en('Hyperemesis gravidarum is the severe form: vomiting several '
              'times a day, unable to keep fluids down, losing weight, '
              'passing very little dark urine. It affects around one to three '
              'women in a hundred and is not a failure of willpower — it is a '
              'medical condition that responds to treatment, sometimes with '
              'a short admission for fluids and anti-sickness medicine.'),
          _en('Safe anti-sickness medicines exist in pregnancy — doxylamine '
              'with B6, and others your obstetrician can choose from. Nobody '
              'should be left to "get through it" when a prescription would '
              'let her eat.'),
        ],
      ),
      PvReadSection(
        heading: _en('What it means for the baby'),
        paragraphs: [
          _en('Ordinary morning sickness does not harm the baby. In the first '
              'trimester the baby is tiny and takes what it needs from your '
              'reserves; a few weeks of eating less well than you would like '
              'does not show up in birth weight. What matters is fluids. If '
              'you are keeping water down, you are doing enough.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You cannot keep any fluids down for 24 hours; you are '
          'vomiting more than three or four times a day; your urine is dark '
          'and scanty; you feel dizzy standing up; you have lost more than '
          'about two kilos; or the vomiting starts for the first time after '
          'the first trimester. These are the signs of dehydration or of '
          'something other than morning sickness, and both are treatable.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is it a good sign if I feel very sick?'),
        answer: _en('Nausea is loosely linked with a healthy rise in hormones, '
            'but plenty of healthy pregnancies have none at all. Neither the '
            'presence nor the absence of sickness tells you anything you '
            'need to act on.'),
      ),
      PvReadFaq(
        question: _en('Can I take my usual antacid?'),
        answer: _en('Most simple antacids are considered safe, but check the '
            'one you have with your doctor or pharmacist, because a few '
            'contain ingredients not recommended in pregnancy.'),
      ),
      PvReadFaq(
        question: _en('Will it come back later?'),
        answer: _en('For most women it fades and stays away. Heartburn, a '
            'different thing, is common in the third trimester as the baby '
            'presses on the stomach.'),
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
    teaser: _en('What the dating scan is looking for, why it may be done '
        'through the abdomen or internally, and what the numbers on the '
        'report mean.'),
    scaleSetter: _en('The first scan is the one that turns a positive test '
        'into a pregnancy you can see. It answers three questions — is the '
        'pregnancy in the right place, is there a heartbeat, and how far '
        'along are you — and it sets the due date every later scan is '
        'measured against.'),
    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Radiologist · 17 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('In India the first scan is usually done between six and nine '
            'weeks, often on the day the pregnancy is confirmed at a clinic, '
            'and sometimes again at eleven to thirteen weeks for the nuchal '
            'translucency scan. In some public systems the first scan is not '
            'until twelve weeks. Neither timing is wrong; they answer '
            'slightly different questions.'),
        _en('Before about eight weeks the pregnancy is small enough that a '
            'transvaginal scan — a slim probe, inside — gives a much clearer '
            'picture than a scan through the abdomen. It is not painful, '
            'takes a few minutes, and is the standard way to see an early '
            'heartbeat. After nine or ten weeks the abdominal scan is usually '
            'enough, and a full bladder helps it.'),
      ]),
      PvReadSection(
        heading: _en('What the sonographer is checking'),
        bullets: [
          _en('Location — that the sac is inside the uterus, which rules out '
              'an ectopic pregnancy.'),
          _en('Number — one sac or two.'),
          _en('Heartbeat — usually visible from six weeks; the rate is noted '
              'and is typically 110 to 170 beats a minute at this stage.'),
          _en('Size — the crown-rump length (CRL), the baby measured head to '
              'bottom, which gives the most accurate dating of the whole '
              'pregnancy.'),
          _en('Your ovaries and the fluid around them, briefly.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why the scan changes your due date'),
        paragraphs: [
          _en('The date from your last period assumes a 28-day cycle and '
              'ovulation on day 14. Many cycles are neither. A CRL measured '
              'before fourteen weeks dates a pregnancy to within about five '
              'days, so if the scan date differs from the period date by more '
              'than a week, doctors use the scan. That is not the scan being '
              '"wrong" about your period; it is the scan being right about '
              'the baby.'),
          _en('Once a due date is set by an early scan, it is not usually '
              'changed by later scans, even if the baby measures big or small '
              'then — later size reflects growth, not age.'),
        ],
      ),
      PvReadSection(
        heading: _en('Reading the report'),
        paragraphs: [
          _en('The report will list GS (gestational sac), YS (yolk sac), CRL, '
              'FHR (fetal heart rate) and an estimated gestational age with '
              'an EDD. "Subchorionic" or "retroplacental" collections are '
              'small bleeds beside the sac that are common and usually '
              'resolve. "Corpus luteum cyst" is the ovary doing its job. '
              'None of these lines is a verdict; your doctor reads them '
              'together with your history and your dates.'),
        ],
      ),
      PvReadSection(
        heading: _en('If a heartbeat is not seen yet'),
        paragraphs: [
          _en('Very early — under six weeks, or when the dates are uncertain '
              '— a scan can be simply too early. The usual step is a repeat '
              'scan in seven to fourteen days, sometimes with a blood test '
              'for hCG in between. A wait like that is one of the hardest '
              'weeks of a pregnancy, and it is also the honest one: the scan '
              'cannot say more than it can see.'),
        ],
      ),

      PvReadSection(
        heading: _en('What this scan cannot tell you'),
        paragraphs: [
          _en('A first scan says where the pregnancy is, whether it has a '
              'heartbeat, and how old it is. It does not say whether the '
              'baby is developing normally — that is the anomaly scan at '
              'twenty weeks — and it does not predict how the pregnancy '
              'will go. A strong heartbeat at seven weeks is reassuring '
              'because the numbers say so, not because the scan can see '
              'the future.'),
          _en('It also cannot tell you why you are bleeding, if you are. A '
              'subchorionic bleed seen on the scan is the commonest '
              'explanation and usually resolves; a scan that shows a '
              'healthy pregnancy and no obvious cause is not a failure of '
              'the scan. In both cases the plan is the same: rest, no '
              'heavy lifting, and a repeat look in one to two weeks.'),
          _en('Nuchal translucency, the fluid at the back of the baby\'s '
              'neck, is measured only in the 11-to-13-week window and only '
              'if you have opted for first-trimester screening. If your '
              'first scan was at seven weeks, it will not appear on the '
              'report — that is timing, not an omission.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go the same day if'),
      body: _en('You have one-sided lower abdominal pain, shoulder-tip pain, '
          'bleeding with pain, or feel faint — before the first scan or '
          'after it. These can be signs of an ectopic pregnancy and are '
          'checked urgently. Any bleeding in early pregnancy is worth a call.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is an internal scan safe for the baby?'),
        answer: _en('Yes. The probe sits in the vagina, well away from the '
            'cervix and the pregnancy, and ultrasound at diagnostic levels '
            'has no known harm.'),
      ),
      PvReadFaq(
        question: _en('Can the scan tell the sex?'),
        answer: _en('Not at this stage, and in India revealing the sex of a '
            'baby is illegal under the PCPNDT Act at any stage.'),
      ),
      PvReadFaq(
        question: _en('Do I need to bring anything?'),
        answer: _en('Your last period date, any earlier reports, and — for an '
            'abdominal scan — a comfortably full bladder.'),
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
        'almost nothing shows. What is happening, what you feel, and what '
        'is worth doing now.'),
    scaleSetter: _en('By the end of week twelve the baby has a beating heart, '
        'every major organ in place, fingers, and a face. All of that happens '
        'while you look the same from the outside and feel, mostly, tired '
        'and slightly sick. The first trimester is the busiest stretch of '
        'the pregnancy and the least visible one.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Pregnancy is counted from the first day of your last period, so '
            'by the time a test turns positive you are already about four '
            'weeks along, with the baby around two weeks old. That '
            'convention confuses everyone once. The first trimester runs to '
            'the end of week thirteen.'),
        _en('The hormone doing most of the work is hCG, which doubles every '
            'two to three days early on and is what the test detects. '
            'Progesterone keeps the lining of the uterus in place and relaxes '
            'smooth muscle everywhere — which is why the bowel slows, the '
            'bladder is busy, and you feel warm and sleepy.'),
      ]),
      PvReadSection(
        heading: _en('What you are likely to feel'),
        bullets: [
          _en('Tiredness that is hard to explain to anyone — the body is '
              'building a placenta, and that is real work.'),
          _en('Nausea, at any hour, usually easing by week 14.'),
          _en('Tender, fuller breasts and darker areolae.'),
          _en('Needing to pass urine often, from week six or so.'),
          _en('Food going off — coffee, tea, and anything fried are the '
              'common ones — and odd cravings.'),
          _en('Mood that swings more than you would like. Hormones, '
              'tiredness and the size of the news all at once.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is worth doing now'),
        paragraphs: [
          _en('Folic acid, 400 micrograms a day, ideally started before '
              'conception and continued through week twelve; some women are '
              'advised a higher dose. It cuts the risk of neural tube '
              'defects, and the neural tube closes by week six, which is why '
              '"start when you find out" is already a little late but still '
              'worth it.'),
          _en('Book the first antenatal visit. In most Indian cities that '
              'means a blood group, haemoglobin, thyroid, blood sugar and '
              'infection screen, blood pressure, and a dating scan. If you '
              'take any regular medicine, ask now whether it stays — do not '
              'stop it on your own.'),
          _en('Stop alcohol and smoking entirely; cut caffeine to under about '
              '200 mg a day (roughly two small cups of coffee). Avoid '
              'unpasteurised milk and soft cheeses, raw or undercooked eggs '
              'and meat, and papaya that is not fully ripe.'),
        ],
      ),
      PvReadSection(
        heading: _en('The worry that sits under everything'),
        paragraphs: [
          _en('Early loss is common — around one pregnancy in six or seven '
              'that is confirmed, most of them before week twelve, and the '
              'great majority because of a chromosomal problem present from '
              'the start that nothing you did caused or could have prevented. '
              'Once a heartbeat has been seen at eight weeks, the chance of '
              'the pregnancy continuing is above ninety per cent.'),
          _en('Light spotting happens in about a quarter of pregnancies and '
              'most of those go on normally. It is still always worth '
              'telling your doctor about, because the ones that need '
              'attention look the same at first.'),
        ],
      ),
      PvReadSection(
        heading: _en('Telling people'),
        paragraphs: [
          _en('There is no rule. Many couples wait until twelve weeks for the '
              'reason above. Some tell close family sooner so that the '
              'tiredness and the nausea have an explanation and a helper. '
              'Whatever you choose, tell your employer in writing when you '
              'are ready; the Maternity Benefit Act protects paid leave of '
              'twenty-six weeks for your first two children.'),
        ],
      ),

      PvReadSection(
        heading: _en('Medicines, and the ones people stop by mistake'),
        paragraphs: [
          _en('Thyroid tablets, asthma inhalers, epilepsy medicine, '
              'antidepressants, blood pressure tablets and insulin are all '
              'commonly stopped by women in the first trimester out of '
              'caution, and stopping most of them is riskier than '
              'continuing. Levothyroxine in particular usually needs to go '
              'UP in early pregnancy, not off. Take the list of what you '
              'take to the first visit and ask, drug by drug.'),
          _en('The ones to avoid without asking are the ones you reach for '
              'casually: ibuprofen and other NSAIDs, high-dose vitamin A, '
              'most acne treatments, and the ayurvedic or herbal preparations '
              'that a relative is sure are harmless. Paracetamol is the '
              'painkiller of pregnancy. A pharmacist will check anything '
              'else in a minute.'),
        ],
      ),

      PvReadSection(
        heading: _en('The visit schedule from here'),
        paragraphs: [
          _en('After the first visit, expect to be seen every four weeks '
              'until 28 weeks, then every two, then weekly from 36. Each '
              'early visit checks your weight, blood pressure and urine, '
              'and from around 12 weeks listens for the heartbeat. The '
              'dating scan, the 11-to-13-week screening scan if you choose '
              'it, and the first round of blood tests all fall in this '
              'trimester, so the first three months are busier at the '
              'clinic than the middle three will be.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en('You have bleeding heavier than spotting, cramping pain, '
          'one-sided pain, shoulder-tip pain, fever, burning on passing '
          'urine, or you cannot keep fluids down. None of these is a '
          'verdict; all of them are checked quickly.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I keep exercising?'),
        answer: _en('Yes, at the level you are used to. Walking, swimming, '
            'prenatal yoga and light weights are all fine; avoid anything '
            'with a fall risk or contact. If you were not exercising before, '
            'start gently.'),
      ),
      PvReadFaq(
        question: _en('Is it safe to travel?'),
        answer: _en('Usually. The first trimester is not a reason to cancel a '
            'trip; nausea and tiredness are the practical limits. Carry your '
            'reports and know where a hospital is.'),
      ),
      PvReadFaq(
        question: _en('Why am I so tired?'),
        answer: _en('Progesterone, a rising blood volume, and the building of '
            'a placenta. It eases for most women in the second trimester.'),
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
    teaser: _en('Appetite comes back, the baby starts growing fast, and what '
        'is on the plate matters more than how much of it there is.'),
    scaleSetter: _en('You are not eating for two. In the second trimester the '
        'extra energy the body needs is about 340 calories a day — a glass '
        'of milk and a banana, or a bowl of dal and a roti. What changes '
        'more is what those calories need to carry: iron, calcium, protein '
        'and folate, in amounts an ordinary Indian plate does not always '
        'reach.'),
    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('For most women the nausea lifts somewhere between weeks twelve '
            'and sixteen and food is welcome again. This is the stretch in '
            'which the baby goes from about 40 grams to nearly a kilo, the '
            'skeleton starts to harden, and your own blood volume rises by '
            'almost half. Every one of those needs a specific nutrient, and '
            'the specific ones are where Indian diets most often fall '
            'short.'),
      ]),
      PvReadSection(
        heading: _en('The four that matter most'),
        bullets: [
          _en('Iron — about 27 mg a day. Blood volume is rising and the baby '
              'is storing iron for its first six months. Anaemia affects '
              'roughly half of pregnant women in India. Sources: dal, rajma, '
              'chana, green leafy vegetables, jaggery, dates, and the '
              'supplement your doctor prescribes — taken with a vitamin C '
              'food and not with tea, which blocks absorption.'),
          _en('Calcium — 1,000 mg a day. Milk, curd, paneer, ragi, sesame '
              '(til), and small fish with bones. If dairy is not part of '
              'your diet, say so; a supplement is usually advised.'),
          _en('Protein — about 60 grams a day, up from 45. Dal at both meals, '
              'eggs, curd, paneer, chicken or fish, peanuts and soya. A '
              'vegetarian plate can reach it; it needs dal or a pulse in '
              'every meal to do so.'),
          _en('Folate and B12 — folate from leafy greens and pulses '
              'continues to matter; B12 is found almost only in animal '
              'foods, so vegetarians are often prescribed it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What a day can look like'),
        paragraphs: [
          _en('Breakfast: poha or upma with peanuts and a glass of milk, or '
              'an egg with toast and fruit. Mid-morning: a handful of dates or '
              'a banana. Lunch: roti, sabzi, dal, curd, salad. Evening: '
              'sprouts chaat, roasted chana, or fruit with a little paneer. '
              'Dinner: rice or roti with dal or fish or chicken, and a green '
              'vegetable. Water through the day — about two and a half '
              'litres, more in summer.'),
          _en('Small frequent meals still help, now less for nausea and more '
              'for the heartburn and fullness that arrive as the uterus '
              'rises. Eating the vegetable before the rice keeps blood sugar '
              'steadier — a habit worth having before the glucose test at '
              '24 to 28 weeks.'),
        ],
      ),
      PvReadSection(
        heading: _en('What to go easy on'),
        paragraphs: [
          _en('Caffeine stays under about 200 mg a day. Large predatory fish '
              '(shark, swordfish, king mackerel) carry mercury; smaller fish '
              'like rohu, pomfret, sardines and hilsa are good sources of '
              'omega-3 and are encouraged two or three times a week. '
              'Unpasteurised milk, soft unpasteurised cheese, raw sprouts '
              'from unknown water, and street food you cannot see being '
              'cooked are the realistic infection risks.'),
          _en('Sugar and refined flour are not forbidden; they simply '
              'displace the foods above. A sweet after a meal is a pleasure, '
              'not a problem. A packet of biscuits instead of lunch is.'),
        ],
      ),
      PvReadSection(
        heading: _en('Weight, and the question nobody likes'),
        paragraphs: [
          _en('For a woman who started at a healthy weight, the usual gain '
              'over the whole pregnancy is 11 to 16 kilos, most of it in the '
              'second and third trimesters at roughly half a kilo a week. '
              'The range is wide and your doctor will have a target for you; '
              'the point of it is the baby\'s growth and your own health '
              'afterwards, not a number to chase.'),
        ],
      ),

      PvReadSection(
        heading: _en('If you are vegetarian'),
        paragraphs: [
          _en('A vegetarian pregnancy is entirely workable and most Indian '
              'pregnancies are one. Three nutrients need deliberate '
              'attention rather than chance. Iron from plants is absorbed '
              'less well than from meat, so the supplement matters more and '
              'the vitamin C with each meal — a squeeze of lemon, a tomato, '
              'amla — is not decoration. Vitamin B12 comes almost only from '
              'animal foods; milk and curd provide some, and most doctors '
              'prescribe it. Omega-3 fats, which the baby\'s brain uses in '
              'the third trimester, come from walnuts, flaxseed and chia in '
              'the plant form, and from an algae-based DHA supplement if '
              'you want the form fish provide.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell your doctor promptly if'),
      body: _en('You are unusually breathless or your heart races on mild '
          'effort, you crave ice or clay, you are very pale, or you are '
          'losing weight in the second trimester. These are worth a blood '
          'test the same week, and the treatable causes are common.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I eat papaya and pineapple?'),
        answer: _en('Ripe papaya is fine and is a good source of vitamin C. '
            'Raw or half-ripe papaya contains latex and is best avoided. '
            'Pineapple in ordinary amounts is safe.'),
      ),
      PvReadFaq(
        question: _en('Is ghee good in pregnancy?'),
        answer: _en('In ordinary amounts, yes — it is a fat like any other. '
            'The traditional advice to eat a lot of it to ease labour has no '
            'evidence behind it.'),
      ),
      PvReadFaq(
        question: _en('Do I need a multivitamin?'),
        answer: _en('Iron, folic acid and calcium are usually prescribed; a '
            'general multivitamin is optional and not a substitute for '
            'food. Vitamin D is often low in Indian women and is worth '
            'checking.'),
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
    teaser: _en('Not "be supportive" — a list of things a partner can '
        'actually do, week by week, that make a measurable difference.'),
    scaleSetter: _en('Women whose partners are involved in the pregnancy go '
        'to more antenatal visits, are less likely to be anaemic at '
        'delivery, and are less likely to develop depression afterwards. '
        'That is not sentiment; it is what the studies find. The involvement '
        'that works is practical and specific, and it starts before anyone '
        'can see a bump.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),
    sections: [
      PvReadSection(paragraphs: [
        _en('Most partners want to help and are not sure how. The pregnancy '
            'is happening inside someone else; the appointments are in '
            'office hours; the advice arriving from every direction is aimed '
            'at her. The way through is to take on tasks rather than '
            'feelings — a partner who owns the appointment diary is doing '
            'more than one who asks "how are you feeling" every evening.'),
      ]),
      PvReadSection(
        heading: _en('In the first trimester'),
        bullets: [
          _en('Take over the cooking, or at least the frying, while smells '
              'are the enemy.'),
          _en('Keep the biscuits by the bed and the water bottle full.'),
          _en('Be the one who remembers the folic acid.'),
          _en('Come to the first scan. It is the moment the pregnancy becomes '
              'real for both of you, and the one appointment nobody regrets '
              'attending.'),
          _en('Handle the relatives. Deciding together who is told and when, '
              'and then holding that line, is a real job.'),
        ],
      ),
      PvReadSection(
        heading: _en('In the second trimester'),
        bullets: [
          _en('Learn the names of the tests — anomaly scan, glucose test, '
              'growth scan — and what week each falls in, so the diary is '
              'shared and not carried by one head.'),
          _en('Walk together in the evening. The exercise guidance is easier '
              'to keep as a pair.'),
          _en('Sort the money conversation early: what the hospital package '
              'covers, what insurance covers, what leave each of you can '
              'take. The Paternity Benefit is not law in India; many '
              'employers offer it anyway, and it needs asking for.'),
          _en('Talk to the baby. From about 24 weeks the baby hears voices '
              'and will know yours at birth.'),
        ],
      ),
      PvReadSection(
        heading: _en('In the third trimester'),
        bullets: [
          _en('Own the hospital bag and the route — where to park, which '
              'entrance is open at 3am, whose phone has the doctor\'s '
              'number.'),
          _en('Learn the signs of labour and the reasons to go in early, so '
              'that at the moment it matters two people know them.'),
          _en('Attend the birth class if there is one. Knowing what a '
              'contraction looks like from the outside, and what to do with '
              'your hands, changes the experience of being in the room.'),
          _en('Plan the first two weeks at home before they arrive: who '
              'cooks, who sleeps when, who takes the visitors.'),
        ],
      ),
      PvReadSection(
        heading: _en('The two things to watch for'),
        paragraphs: [
          _en('Partners are often the first to notice antenatal depression '
              'and anxiety, because they see the withdrawal that a woman '
              'does not report at a check-up. Low mood most days for two '
              'weeks, losing interest in things, not sleeping even when the '
              'baby allows it — these are worth raising with the doctor as a '
              'couple, not left for her to mention.'),
          _en('And the danger signs of pregnancy — heavy bleeding, severe '
              'headache with vision changes, sudden swelling of the face and '
              'hands, the baby moving much less, fever, or fluid leaking — '
              'are easier to act on when two people know them. Read them '
              'once together.'),
        ],
      ),

      PvReadSection(
        heading: _en('The mother-in-law question'),
        paragraphs: [
          _en('In many Indian homes the person with the most opinions about '
              'the pregnancy is not the partner but his mother, and the '
              'partner\'s most useful job is to be the one who says "the '
              'doctor said" so that she does not have to. Agree in advance '
              'on the two or three things that are not negotiable — the '
              'iron tablets, the scan schedule, the hospital — and let him '
              'carry them into the family. A partner who takes that on '
              'removes a source of daily strain that no amount of foot '
              'massage addresses.'),
          _en('And a note for the partner reading this: the pregnancy '
              'happens to her, but the household happens to both of you. '
              'Take one recurring job entirely — the morning tea, the '
              'evening cooking, the bills — and keep it without being '
              'reminded. That is what "support" looks like from the '
              'inside.'),
        ],
      ),

      PvReadSection(
        heading: _en('And your own health'),
        paragraphs: [
          _en('Partners get less sleep, more worry and no appointments of '
              'their own. Around one father in ten meets the criteria for '
              'depression in the perinatal year. The same rule applies: two '
              'weeks of low mood is a reason to say so, to her or to a '
              'doctor, and not a thing to carry so as not to add to hers.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Take her in, do not wait, if'),
      body: _en('There is heavy bleeding, a severe headache with blurred '
          'vision or flashing lights, sudden swelling of the face or hands, '
          'a marked drop in the baby\'s movements after 28 weeks, a fever '
          'over 38°C, or fluid leaking before 37 weeks. Call the hospital '
          'on the way; do not drive her yourself if she is faint or in '
          'severe pain — call an ambulance.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is sex safe during pregnancy?'),
        answer: _en('In a normal pregnancy, yes, throughout. Your doctor will '
            'say if there is a specific reason to avoid it, such as a low '
            'placenta or a history of preterm labour.'),
      ),
      PvReadFaq(
        question: _en('She is irritable with me. Is that the pregnancy?'),
        answer: _en('Often, partly. Tiredness, nausea, discomfort and a very '
            'large change all land on the nearest person. It is not a '
            'verdict on you; it is a reason to do the tasks above without '
            'being asked.'),
      ),
    ],
    evidence: _en('WHO recommendations on health promotion interventions '
        'for maternal and newborn health (2015) on male involvement; '
        'Yargawa & Leonardi-Bee, Journal of Epidemiology and Community '
        'Health (2015); NICE NG201.'),
    readNext: ['${kPregWeekReadPrefix}talking_baby', '${kPregWeekReadPrefix}hospital_bag'],
  ),
];
