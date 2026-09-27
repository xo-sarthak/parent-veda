// =============================================================================
//  After a loss — the second set of reads for this door
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap analysis v2 (docs/TTC-GAP-PLAN.md,
//  stream A, "After a loss › Understand"). The two reads that were already
//  here (`ttc_reads_after_loss.dart`: physical recovery, and on trying again)
//  set the tone and are NOT repeated: these five go where those two stop.
//
//    · chemical pregnancy, and a late period or an early loss
//    · ectopic pregnancy: the signs, the tests, treatment, trying again
//    · what causes a miscarriage, and the long list of things that don't
//    · recurrent miscarriage: which tests, which not, genetic counselling
//    · the feelings of trying again, and where to find help in India
//
//  ⚠️ THE SAME RULES AS THE FIRST FILE. The quietest writing in the stage: no
//  brightness, no hurry, no silver lining, never blame. No product row, no
//  course, no tracker offered as a next step. Every urgent line keeps its full
//  urgency, because two of these topics (ectopic, and heavy bleeding) are
//  emergencies.
//
//  ⚠️ THE AGGREGATOR IS STILL THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `ttc_reads_data.dart` should import this file.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE (see the other read files).
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsLossMore = [
  // ===========================================================================
  //  CHEMICAL PREGNANCY — and "was it a late period or an early loss?"
  // ===========================================================================
  //  Gap pack: "What's a chemical pregnancy?" (P1) and "Period bleeding vs.
  //  miscarriage" (P2) are one read, because the second question is usually
  //  asked by someone who has just had the first thing happen.
  PvRead(
    id: 'ttc_read_chemical_pregnancy',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en("Chemical pregnancy: what it is, and what it isn't"),
    teaser: _en('What it means when a positive test turns into a period, and '
        'what it means for next month.'),
    shortAnswer: _en('A chemical pregnancy is a pregnancy that ends very '
        'early, before a scan could see it. The test was right: a pregnancy '
        "did begin. It's common, it isn't caused by anything you did, and you "
        'can usually try again in your next cycle.'),
    scaleSetter: _en('Physically, a chemical pregnancy usually passes like a '
        'period, sometimes a heavier one, and needs no treatment. It doesn\'t '
        'mean something is wrong with you. The one thing to watch for is pain '
        'on one side, and that is covered below.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('You saw a positive test, maybe a faint line, and then your '
              'period came. Or a line that was there a few days ago has '
              'faded. This can hurt more than the people around you expect, '
              'even though it was so early.'),
          _en("Whatever you're feeling about it is fair. Some people feel sad "
              'for weeks. Some mostly feel confused. This page explains what '
              'happened, so that at least one part of it is clear.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is a chemical pregnancy?'),
        paragraphs: [
          _en("It's a pregnancy that ends in the first few weeks, usually "
              'close to when your period is due, or just after. An egg was '
              'fertilised and started to settle into the lining of your womb. '
              'Then it stopped growing.'),
          _en("It's called chemical because the only sign it ever gave was a "
              'chemical one: hCG, the pregnancy hormone, which a test picks up '
              'in urine or blood. It ended before anything could be seen on a '
              'scan.'),
          _en('Doctors also call it a biochemical pregnancy, or a very early '
              'miscarriage. All three names mean the same thing.'),
          _en("So the test wasn't faulty, and you didn't imagine it. You were "
              'pregnant, for a short time.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why did it happen?'),
        paragraphs: [
          _en('Most of the time, the reason is a chromosome problem in the '
              'fertilised egg. Something went wrong when the cells first '
              "divided, so the pregnancy couldn't grow. It's a random event. "
              "It isn't passed down, and nobody could have stopped it."),
          _en("Sometimes the pregnancy doesn't settle into the lining well. "
              "Doctors often can't say which it was, and after a single "
              "chemical pregnancy they don't need to."),
          _en('Chemical pregnancies are very common. Many happen without '
              'anyone knowing, because the period comes on time or a day or '
              'two late. Sensitive home tests mean more people see them now.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Testing too early caused it, or jinxed it.'),
          fact: _en("A test only shows what's already happening. Testing "
              "early didn't cause the loss. It let you see a pregnancy that, "
              'with older tests, would have looked like a slightly late '
              'period.'),
        ),
      ),
      PvReadSection(
        heading: _en('What will it feel like?'),
        paragraphs: [
          _en('For most people it feels like a period. It may come a few days '
              'late. It can be heavier than usual, with more cramping or a few '
              'small clots.'),
          _en('The test line fades over the next days, and within a week or '
              'two a test turns negative as the hormone clears.'),
          _en("You don't need to keep testing to watch it happen. If you'd "
              'like to be sure, one test about two weeks later is enough, or '
              'your doctor can do a blood test.'),
          _en('Some people notice early pregnancy signs, like sore breasts or '
              'feeling sick, fading a day or two before the bleeding starts. '
              'Usually no treatment is needed. Your body does this on its '
              'own.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why pain on one side matters'),
          body: _en('Now and then, a positive test followed by bleeding is an '
              'ectopic pregnancy, one growing outside the womb. That is rare. '
              "It's why pain on one side, pain in the tip of your shoulder or "
              'feeling faint needs a hospital the same day. The read on '
              'ectopic pregnancy lists the signs.'),
        ),
      ),
      PvReadSection(
        heading: _en('Was it a late period, or an early loss?'),
        paragraphs: [
          _en("Without a test, it's often hard to know. A period and a very "
              "early loss can look much the same, and bleeding alone can't "
              'tell you which it was.'),
          _en('A few things make an early loss more likely: a positive test '
              "before the bleeding, bleeding that's much heavier or more "
              'painful than your usual period, or passing more clots or some '
              'greyish tissue. A period that comes much later than usual can '
              'be either.'),
          _en("If you're unsure, a doctor can check hCG with a blood test. It "
              "helps most in the first days after bleeding starts. If it's "
              "been weeks and you feel well, you don't need to find out for "
              'certain. You can mention it at your next visit.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can we try again straight away?'),
        paragraphs: [
          _en("In most cases, yes. After a chemical pregnancy there's no "
              'medical reason to wait. Your next cycle is usually normal, and '
              'ovulation comes back on time.'),
          _en('Some people want to try the very next month. Some want a '
              "break. Either is fine, and you don't have to explain the "
              'choice to anyone.'),
          _en("If you're tracking your cycle, count the first day of this "
              'bleeding as day 1 of a new cycle. Your fertile days that month '
              'usually fall where they normally would.'),
          _en('Some doctors point out that a chemical pregnancy shows an egg '
              'was fertilised and began to implant. Some people find that '
              "helpful to know. If it doesn't comfort you right now, that's "
              'fine too.'),
        ],
      ),
      PvReadSection(
        heading: _en('Should I tell my doctor?'),
        paragraphs: [
          _en("Yes, even if it's one line at your next visit. It belongs in "
              'your history, and if it ever happens again your doctor will '
              'want to know how many there have been.'),
          _en('ESHRE, the European fertility society, counts losses seen only '
              'on a hormone test when it looks at repeated losses. After two '
              'or more losses of any kind, it is reasonable to ask for tests.'),
          _en("If you're having IVF or IUI, your clinic is already checking "
              'your hormone level. A result that rises and then falls is '
              'often a chemical pregnancy. Your clinic will explain what it '
              'means for your next cycle.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does a chemical pregnancy count as a miscarriage?'),
        answer: _en("Medically, yes. It's the earliest kind of pregnancy "
            'loss. How you think of it is up to you. Some people grieve it as '
            'a loss, and some think of it more like a late period. Both are '
            'fine.'),
      ),
      PvReadFaq(
        question: _en('Will it happen again?'),
        answer: _en('Most people who have one go on to have an ongoing '
            "pregnancy later. One chemical pregnancy doesn't mean anything is "
            'wrong. If you have two or more losses of any kind, ask your '
            'doctor about tests.'),
      ),
      PvReadFaq(
        question: _en('Do I need a D&C or any medicine?'),
        answer: _en('Almost never. The pregnancy was so small that your body '
            'clears it like a period. A doctor will only suggest more if the '
            "bleeding doesn't settle or a test stays positive for weeks."),
      ),
      PvReadFaq(
        question: _en("Is it okay that I'm this upset about something so "
            'early?'),
        answer: _en("Yes. How early it was doesn't decide how much it "
            'matters to you. For many people, the plans start the moment the '
            'line appears.'),
      ),
      PvReadFaq(
        question: _en('When can I trust a pregnancy test again?'),
        answer: _en('Wait until your next period is due, or a few days after. '
            'By then the hormone from this time will have cleared, so a '
            'positive test means a new pregnancy.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to a hospital today if you have any of these'),
      body: _en('Pain on one side of your lower tummy, especially if it is '
          'sharp or getting worse. Pain in the tip of your shoulder. Feeling '
          'faint, dizzy or very weak. Soaking through more than two thick pads '
          'an hour for two hours in a row. A fever, or discharge that smells '
          'bad. These can mean an ectopic pregnancy, heavy bleeding or an '
          'infection, and each needs to be seen the same day. If bleeding '
          "hasn't settled after two weeks, or a test is still positive after "
          'three weeks, book a visit this week.'),
    ),
    evidence: _en('What a biochemical pregnancy is, and the counting of '
        'losses seen only on a hormone test, follow the ESHRE guideline on '
        'recurrent pregnancy loss (2022), with Cleveland Clinic and '
        'StatPearls/NCBI summaries. Warning signs follow NICE guideline NG126 '
        'on ectopic pregnancy and miscarriage, and NHS guidance. Sources '
        'checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Ectopic pregnancy'),
        value: _en('The signs that need a hospital today, so you know them.'),
        surfaceId: 'ttc_read/ttc_read_ectopic_pregnancy',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep a note for your doctor'),
        value: _en('The date and what happened, in one place, for when a '
            'doctor asks.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_miscarriage_causes',
      'ttc_read_loss_recovery',
      'ttc_read_trying_again',
    ],
  ),

  // ===========================================================================
  //  ECTOPIC PREGNANCY — the signs, the tests, the treatment, trying again
  // ===========================================================================
  //  Gap pack: four P2 pieces (the course, risk factors, symptoms and
  //  diagnosis, treatment options) in one read. The signs come first and the
  //  treatment folds, because the only part that is time-critical is knowing
  //  when to go.
  //
  //  ⚠️ THE URGENT LINES ARE FIRM ON PURPOSE. This is the one read in the door
  //  where the kind thing is to be direct: "go today, call 108 or 112, don't
  //  drive yourself". Softening them would be the unkind edit.
  PvRead(
    id: 'ttc_read_ectopic_pregnancy',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('Ectopic pregnancy: the signs that need a hospital today'),
    teaser: _en('The warning signs to know, how doctors find it, and what '
        'treatment and trying again look like.'),
    shortAnswer: _en('An ectopic pregnancy grows outside the womb, most often '
        "in a fallopian tube. It can't become a baby, and it can cause "
        "serious bleeding if it isn't treated. After a positive test, pain on "
        'one side, shoulder-tip pain, bleeding or feeling faint mean going to '
        'a hospital today.'),
    scaleSetter: _en("Ectopic pregnancy isn't common: about 1 or 2 in every "
        "100 pregnancies. When it's found early it's very treatable, and most "
        'women can still get pregnant afterwards. Knowing the signs is how it '
        'gets found early.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Most people reading this won't ever have an ectopic pregnancy. "
              'This page is here so that, if it ever happens to you or '
              "someone close to you, you know the signs and don't wait."),
          _en('If you have any of the warning signs right now, stop reading '
              'and go to a hospital emergency department. If you feel faint, '
              'call 108 or 112 for an ambulance.'),
        ],
      ),
      PvReadSection(
        heading: _en('What is an ectopic pregnancy?'),
        paragraphs: [
          _en('Normally a fertilised egg travels down a fallopian tube and '
              'settles in the lining of the womb. In an ectopic pregnancy it '
              "settles somewhere else. Most often that's inside the tube "
              'itself.'),
          _en("A tube is narrow and can't stretch the way the womb does. As "
              'the pregnancy grows, it can burst the tube and cause bleeding '
              'inside the tummy. This is called a rupture, and it is an '
              'emergency.'),
          _en("An ectopic pregnancy can't survive, and there's no way to move "
              "it into the womb. That's hard to hear. It also means treatment "
              "isn't a choice between you and the pregnancy. Treatment is how "
              'you stay safe.'),
        ],
      ),
      PvReadSection(
        heading: _en('What are the signs?'),
        paragraphs: [
          _en('The signs of an ectopic pregnancy can look like a normal early '
              "pregnancy or a miscarriage, and symptoms alone can't tell you "
              'which it is. A doctor needs to check. One-sided pain with a '
              'positive test should be seen the same day.'),
          _en('Signs usually show between weeks 4 and 12 of pregnancy, '
              'counted from your last period. Some women have no signs at all '
              'until an early scan finds it. Others notice one or more of '
              'these:'),
        ],
        bullets: [
          _en('A missed period and a positive test, though not always.'),
          _en('Pain low in your tummy, often on one side. It can be mild at '
              'first.'),
          _en("Bleeding, or a brown watery discharge, that's different from "
              'your usual period.'),
          _en('Pain in the tip of your shoulder, where your shoulder ends and '
              'your arm begins. It comes from blood irritating a nerve, and it '
              'needs a hospital straight away.'),
          _en('Pain or discomfort when you pee or poo, or diarrhoea.'),
          _en('Feeling dizzy, faint, very pale or sick.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('If it may have burst'),
          body: _en('Sudden, sharp, severe pain in your tummy, feeling very '
              'dizzy or fainting, or looking very pale can mean the tube has '
              'burst. Call 108 or 112, or have someone take you to the '
              "nearest emergency department now. Don't drive yourself."),
        ),
      ),
      PvReadSection(
        heading: _en('How do doctors find it?'),
        paragraphs: [
          _en('The main test is an internal ultrasound scan, done with a '
              'small probe placed in the vagina. It gives a closer view of the '
              'womb and tubes than a scan over the tummy. It can feel a little '
              "uncomfortable, but it's safe in pregnancy."),
          _en('Your doctor will also check hCG in your blood, usually twice, '
              '48 hours apart. In a healthy early pregnancy the level rises '
              'steadily. If it rises slowly, stays flat or falls, and nothing '
              'is seen in the womb, the pregnancy may be ectopic.'),
          _en("Sometimes it's too early to see anything anywhere. Doctors "
              "call this a pregnancy of unknown location. It isn't a "
              'diagnosis. It means more blood tests and scans over the next '
              'days until the picture is clear. Keep these appointments, even '
              'if you feel fine.'),
        ],
      ),
      PvReadSection(
        heading: _en('Who is more likely to have one?'),
        paragraphs: [
          _en('Anyone can have an ectopic pregnancy, and many women who do '
              'have none of the things below. The risk is higher when the '
              'tubes have been damaged or operated on before:'),
        ],
        bullets: [
          _en('An ectopic pregnancy before.'),
          _en('Surgery on your tubes, or other surgery in your pelvis.'),
          _en('A past infection of the womb and tubes (pelvic inflammatory '
              'disease), such as chlamydia.'),
          _en('Genital TB, which is more common in India than in many '
              'countries and can damage the tubes without clear symptoms.'),
          _en('Getting pregnant through IVF or other fertility treatment.'),
          _en('Smoking, and being over 35.'),
        ],
      ),
      PvReadSection(
        heading: _en('What changes if one of these applies to me?'),
        paragraphs: [
          _en('Tell your doctor as soon as you get a positive test. They will '
              'usually suggest an early scan, often at around 6 weeks, to see '
              'where the pregnancy is. Having that plan means that if it ever '
              "happens, it's found early."),
          _en('After one ectopic pregnancy, around 1 in 10 women have '
              'another. Most go on to a pregnancy in the womb. The early scan '
              'is the main thing that changes next time.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('The three usual treatments, and what each means for '
            'trying again. Your doctor decides with you which one fits.'),
        heading: _en('How is it treated?'),
        paragraphs: [
          _en('The right treatment depends on how far along the pregnancy is, '
              'your hCG level, what the scan shows and how you are. Your '
              'doctor will explain why they suggest one. There are three main '
              'routes.'),
          _en('Watching and waiting. If the pregnancy is very small, the '
              "hormone is already falling and you're well, it may end on its "
              'own. You will have blood tests every few days until hCG is back '
              'to zero.'),
          _en('An injection of methotrexate. This medicine stops the '
              'pregnancy growing, and your body then absorbs it. Blood tests '
              'follow for a few weeks. Doctors usually advise waiting at least '
              'three months after methotrexate before trying again, because '
              'the medicine can affect a new pregnancy.'),
          _en('Keyhole surgery. Through small cuts in the tummy, the surgeon '
              'removes the pregnancy. Usually the affected tube is removed '
              'too, and sometimes it can be kept. If the tube has burst, '
              'surgery is done as an emergency.'),
          _en('If your blood group is Rh negative, ask whether you need an '
              'anti-D injection after surgery.'),
        ],
      ),
      PvReadSection(
        heading: _en('Can I get pregnant after an ectopic pregnancy?'),
        paragraphs: [
          _en("Most women can, including those who've had a tube removed. "
              'One healthy tube is often enough, because it can pick up an '
              'egg released on either side.'),
          _en('Many doctors suggest waiting for at least two periods after '
              'surgery before trying, so your body can recover and the next '
              'pregnancy is easier to date. After methotrexate, the usual wait '
              'is three months. Your doctor will tell you what applies to '
              'you.'),
          _en('If both tubes are damaged or removed, IVF can help, because it '
              "doesn't need the tubes. That's a conversation for later, when "
              "you're ready."),
          _en('An ectopic pregnancy is also a pregnancy loss. The grief can '
              'get lost behind the relief of being safe, and feeling both at '
              'once is normal.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can an ectopic pregnancy be moved into the womb?'),
        answer: _en("No. There's no safe way to do this. It's one of the most "
            "common questions, and it's a painful answer. Treating it is what "
            'keeps you safe.'),
      ),
      PvReadFaq(
        question: _en('Did something I did cause it?'),
        answer: _en('No. Nothing you did in this pregnancy made it settle in '
            'the wrong place. Lifting, sex, work, travel or what you ate '
            "don't cause an ectopic pregnancy."),
      ),
      PvReadFaq(
        question: _en('Could my home test have shown it was ectopic?'),
        answer: _en('No. A home test shows the pregnancy hormone, not where '
            'the pregnancy is. Only a scan and blood tests can tell.'),
      ),
      PvReadFaq(
        question: _en('Can it happen after IVF, when the embryo goes into the '
            'womb?'),
        answer: _en("Yes, though it's uncommon. An embryo placed in the womb "
            'can still move into a tube. That is one reason clinics do an '
            'early scan after a positive test.'),
      ),
      PvReadFaq(
        question: _en('Will I need an early scan every time now?'),
        answer: _en('Usually, yes. Tell your doctor as soon as you get a '
            'positive test, so they can plan a scan at around 6 weeks.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go to a hospital today, not tomorrow'),
      body: _en('If you could be pregnant and have pain on one side of your '
          'lower tummy, pain in the tip of your shoulder, bleeding with pain, '
          'or you feel dizzy or faint, go to a hospital emergency department '
          'today. If the pain is sudden and severe, or you faint, call 108 or '
          "112 and don't drive yourself. Tell them you may be pregnant. It is "
          'always better to be checked and sent home than to wait.'),
    ),
    evidence: _en('Signs, tests and treatments follow NICE guideline NG126 on '
        'ectopic pregnancy and miscarriage, the RCOG guideline on the '
        'diagnosis and management of ectopic pregnancy, and NHS information. '
        'Risk factors, the chance of a repeat ectopic across all women, and '
        'genital tuberculosis follow NHS and StatPearls/NCBI. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan an early scan'),
        value: _en('If your tubes have had problems before, note down to ask '
            'for a scan at around 6 weeks next time.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Trying again after a loss: the feelings'),
        value: _en('Fear, guilt and hope, often in the same day.'),
        surfaceId: 'ttc_read/ttc_read_loss_feelings',
      ),
    ],
    readNext: [
      'ttc_read_chemical_pregnancy',
      'ttc_read_loss_recovery',
      'ttc_read_trying_again',
    ],
  ),

  // ===========================================================================
  //  WHAT CAUSES A MISCARRIAGE, AND WHAT DOESN'T
  // ===========================================================================
  //  Gap pack: "The truth about what causes miscarriage (and what doesn't)"
  //  (P2). Added as a fifth read beyond the four planned, because its reader
  //  is different: a woman after ONE loss asking "was it me" will not open a
  //  read titled recurrent miscarriage. The existing reads answer it in one
  //  FAQ and one section; this is the full answer, with the Indian myths
  //  (papaya, garam foods, nazar, stairs) named and corrected gently.
  PvRead(
    id: 'ttc_read_miscarriage_causes',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en("What causes a miscarriage, and what doesn't"),
    teaser: _en('The real reasons early losses happen, and the long list of '
        "everyday things that don't cause them."),
    shortAnswer: _en('Most miscarriages happen because of a chromosome '
        'problem in the pregnancy, which starts by chance at conception. '
        'Everyday things like work, lifting, sex, stress, travel or eating '
        "papaya don't cause them. A few health conditions can raise the risk, "
        'and those can be tested for and treated.'),
    scaleSetter: _en("If you're asking whether it was your fault, the answer "
        'is almost certainly no. This page explains why, in enough detail '
        'that you can believe it, and gives you words for anyone who says '
        'otherwise.'),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost everyone who loses a pregnancy goes back over the days '
              'and weeks '
              'before it. The meal, the stairs, the long day at work, the '
              "argument. It's how a mind tries to make sense of something that "
              "happened for a reason you couldn't see."),
          _en('Here is what doctors know about why miscarriages happen, '
              'starting with the most common reason by far.'),
        ],
      ),
      PvReadSection(
        heading: _en('What causes most miscarriages?'),
        paragraphs: [
          _en('In the first 12 weeks, at least half of all miscarriages '
              'happen because the pregnancy had the wrong number of '
              'chromosomes. Chromosomes carry the instructions for growing. '
              "With too many or too few, the pregnancy can't develop, and it "
              'stops.'),
          _en('This happens by chance, when the egg or sperm forms or when '
              "the fertilised egg first divides. It's there from the very "
              'start. Nothing you did afterwards caused it, and nothing could '
              'have fixed it.'),
          _en("It's also why miscarriage is so common. Around 1 in 5 known "
              'pregnancies end in miscarriage, most of them in the first 12 '
              'weeks.'),
          _en('Often the pregnancy stops growing days or even weeks before '
              'any bleeding starts. So whatever you did the day before the '
              'bleeding almost never had anything to do with it. The loss had '
              'usually begun before then.'),
        ],
      ),
      PvReadSection(
        heading: _en('Does age play a part?'),
        paragraphs: [
          _en('Yes. As eggs age, chromosome errors become more common, so '
              'miscarriage happens more often after 35, and more again after '
              "40. This is about how eggs work. It isn't a judgment on when "
              'you started trying.'),
          _en("If you're over 35, this can feel like one more worry. It helps "
              'to know that most pregnancies in the late thirties still '
              "continue. Age changes the numbers across large groups. It can't "
              'tell you why one particular pregnancy ended.'),
          _en("A man's age matters a little too, though much less. Neither is "
              'something to blame yourself or your partner for.'),
        ],
      ),
      PvReadSection(
        heading: _en('What else can raise the risk?'),
        paragraphs: [
          _en('A smaller number of losses are linked to something that can be '
              'found and helped. These matter most after two or more losses, '
              'and they are the reason tests exist.'),
          _en("Having one of them doesn't mean it caused your loss, and most "
              'people with them have healthy pregnancies. Your doctor can say '
              'whether any is worth checking. They include:'),
        ],
        bullets: [
          _en("Thyroid problems or diabetes that aren't well controlled."),
          _en('Antiphospholipid syndrome, a condition that makes the blood '
              'clot too easily.'),
          _en('A womb with a different shape, such as a wall of tissue down '
              'the middle, or fibroids inside the cavity.'),
          _en('Some serious infections, especially with a high fever.'),
          _en('Smoking, heavy drinking and recreational drugs.'),
          _en('A few medicines, such as some acne and epilepsy medicines. '
              "Don't stop a medicine on your own. Ask your doctor first."),
        ],
        tip: PvReadTip(
          title: _en('About coffee and chai'),
          body: _en('Very high caffeine has been linked to a small rise in '
              'risk, which is why doctors suggest keeping to 200 mg a day in '
              "pregnancy. That's about two mugs of instant coffee, or a few "
              "small cups of chai. A normal amount of either didn't cause your "
              'loss.'),
        ),
      ),
      PvReadSection(
        heading: _en("What doesn't cause a miscarriage?"),
        paragraphs: [
          _en('Some everyday things sound as if they should matter, like a '
              'heavy bag or a busy week. Early on, the pregnancy is well '
              'cushioned inside the womb, and it is far sturdier than it '
              'feels.'),
          _en('This list is long because the myths are. None of these has '
              'been shown to cause an early miscarriage:'),
        ],
        bullets: [
          _en('Working, including long days, jobs on your feet and a '
              'stressful office.'),
          _en('Lifting, bending, climbing stairs or everyday housework.'),
          _en('Exercise you were used to, walking or yoga.'),
          _en('Having sex.'),
          _en('Stress, worry, a fight or crying.'),
          _en('Travel, including flights and long car or train journeys.'),
          _en('Spicy food, cold food, or foods called garam or heating.'),
          _en('A small fall or bump. Early on, the womb sits low and is '
              'protected by the bones of the pelvis.'),
          _en('Sitting cross-legged on the floor, squatting, or a warm '
              'shower.'),
          _en('Using a phone or laptop, or walking through a security scanner '
              'at the airport.'),
          _en('Telling people about the pregnancy too early.'),
          _en('Nazar, bad luck, or anything anyone said about you.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Eating papaya or pineapple brought it on.'),
          fact: _en('Ripe papaya and pineapple, eaten as everyday food, '
              "haven't been shown to cause miscarriage. Many doctors still "
              'suggest skipping raw, unripe papaya in pregnancy, to be '
              "careful. Eating these as part of your normal meals didn't cause "
              'your loss.'),
        ),
      ),
      PvReadSection(
        heading: _en('What if family say it was something I did?'),
        paragraphs: [
          _en('People who love you often look for a reason too. It can come '
              'out as blame: you worked too much, you travelled, you ate the '
              "wrong thing. Usually they're frightened and don't know what "
              'else to say.'),
          _en('You can correct them, or not. A short line helps: "The doctor '
              'said it was a chromosome problem that started at conception. '
              'Nothing anyone did caused it." You can say it once and leave it '
              'there.'),
          _en('If someone keeps blaming you, it is fair to ask your doctor to '
              'explain it to them. Many will. It can help to hear it from the '
              'doctor yourself, too. Ask at your follow-up: "Did anything I '
              'did cause this?"'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Could I have saved the pregnancy by resting more?'),
        answer: _en("No. Bed rest hasn't been shown to prevent miscarriage. "
            "Once a pregnancy has stopped growing, rest can't restart it."),
      ),
      PvReadFaq(
        question: _en('I took a tablet for a headache before I knew. Was it '
            'that?'),
        answer: _en('Very unlikely. Paracetamol, and most common medicines '
            "taken for a short time, aren't linked to miscarriage. If you "
            "took something you're worried about, ask your doctor. They can "
            'put it in context.'),
      ),
      PvReadFaq(
        question: _en('Did my partner play a part?'),
        answer: _en('Most losses come from a chance error that neither of you '
            'caused. Heavy smoking, heavy drinking and older age in men are '
            "linked to a small rise in risk, but they don't explain a single "
            "loss, and there's no reason to blame him either."),
      ),
      PvReadFaq(
        question: _en('If it was a chromosome problem, will the next '
            'pregnancy have one too?'),
        answer: _en('Almost always, no. These errors happen by chance, and '
            'each pregnancy starts fresh. Only rarely does a parent carry a '
            'chromosome change that repeats, and doctors look for that after '
            'repeated losses.'),
      ),
      PvReadFaq(
        question: _en('Does a miscarriage mean something is wrong with my '
            'body?'),
        answer: _en("Usually not. After one miscarriage, most women's bodies "
            'are working as they should. The problem was in that one '
            'pregnancy, not in you.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor, and when to go today'),
      body: _en("If you're bleeding now, go to a hospital today for heavy "
          'bleeding (soaking more than two thick pads an hour for two hours), '
          'severe pain, pain on one side or in your shoulder tip, a fever, or '
          "feeling faint. Once you're well, book a visit if you've had two or "
          'more losses, a loss after 12 weeks, or a known condition like '
          'thyroid disease, diabetes or a clotting problem. Those are worth '
          'looking into, because some causes can be treated.'),
    ),
    evidence: _en('Chromosome errors as the most common cause, the link with '
        'age, and the conditions that raise risk follow the ESHRE guideline '
        'on recurrent pregnancy loss (2022), RCOG patient information on '
        'miscarriage and NHS guidance. Everyday activities not causing '
        'miscarriage follow ACOG, NHS and Cleveland Clinic. The caffeine '
        'limit follows NHS and ACOG. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('Recurrent miscarriage: when to ask for tests'),
        value: _en('If this has happened more than once, which tests help '
            "and which don't."),
        surfaceId: 'ttc_read/ttc_read_recurrent_miscarriage',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Questions for your follow-up'),
        value: _en('Write down what you want to ask, so it gets asked.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: [
      'ttc_read_loss_recovery',
      'ttc_read_recurrent_miscarriage',
      'ttc_read_loss_feelings',
    ],
  ),

  // ===========================================================================
  //  RECURRENT MISCARRIAGE — which tests, which not, genetic counselling
  // ===========================================================================
  //  Gap pack: "Can it happen again?", "Tests that can help you after
  //  miscarriage", "Should I get tested?", "Do I need genetic counseling?"
  //  (all P2), "What are my odds?" (P2) as POPULATION figures only, and
  //  "The (rare) complications after miscarriage" (P3) as the Asherman line.
  //
  //  ⚠️ THE TWO-LOSS THRESHOLD IS SAID ONCE AND LINKED. `ttc_read_trying_again`
  //  already carries it; this read is what comes after that sentence.
  //
  //  ⚠️ THE "NOT RECOMMENDED" FOLD IS THE MOST USEFUL PART FOR INDIA. Immune
  //  panels, NK cell tests and intralipid drips are sold hard after repeated
  //  loss. ESHRE recommends against them. Naming them lets her ask why.
  PvRead(
    id: 'ttc_read_recurrent_miscarriage',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('Recurrent miscarriage: when to ask for tests'),
    teaser: _en('Which tests help after more than one loss, which ones '
        "don't, and when a genetic counsellor fits in."),
    shortAnswer: _en("After two or more miscarriages, it's reasonable to ask "
        'for tests. They look at hormones, blood clotting, the shape of the '
        'womb and sometimes chromosomes. Many of the causes they find can be '
        'treated, and even when nothing is found, most couples still go on to '
        'have a baby.'),
    scaleSetter: _en('One miscarriage is common and usually points to no '
        'problem at all. After two or more, it is worth looking for a cause. '
        'Often none is found, and when one is, many can be treated. The '
        'outlook is better than most people fear.'),
    author: _en('Dr Simranpreet Sandhu'),
    authorRole: _en('IVF counsellor and genetic medicine'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en('Losing more than one pregnancy wears you down in a way that is '
              'hard to describe. Each time, the hope and the fear both grow. '
              "It's natural to wonder if something is wrong, and whether it "
              'will keep happening.'),
          _en('This page is about the practical side: when tests make sense, '
              'what they look for, which are worth your money, and where a '
              'genetic counsellor fits. "On trying again" covers timing and '
              'the feelings around it.'),
        ],
      ),
      PvReadSection(
        heading: _en('Will it happen again?'),
        paragraphs: [
          _en('After one miscarriage, the risk in the next pregnancy is about '
              "the same as anyone else's. One loss isn't a pattern."),
          _en('The risk rises a little with each further loss, and with age. '
              'Even so, most women who have had two or even three '
              'miscarriages go on to have a baby, including many whose tests '
              'find no cause.'),
          _en("These figures come from large groups of women. They can't say "
              'what will happen to you, and nobody can. What they do show is '
              'that a good outcome is common, even after several losses.'),
        ],
      ),
      PvReadSection(
        heading: _en('When should we ask for tests?'),
        paragraphs: [
          _en('ESHRE, the European fertility society, says tests can start '
              "after two losses. They don't have to be one after the other, "
              'and losses seen only on a hormone test count too. Some '
              'guidelines, and many doctors in India, still wait for three.'),
          _en("It's also reasonable to ask sooner after a loss past 12 weeks, "
              "if you're over 35, or if you already have a condition like "
              'thyroid disease, diabetes or lupus.'),
          _en('A gynaecologist who sees many couples after loss, or a '
              'fertility clinic, is a good place to start. Take the dates of '
              'each loss, how far along you were, and any scan or test '
              'reports.'),
        ],
        tip: PvReadTip(
          title: _en('If it happens again, ask about testing the tissue'),
          body: _en('If there is another loss, ask whether the pregnancy '
              "tissue can be sent for a chromosome test. It isn't always "
              'possible, and it usually costs several thousand rupees. It can '
              'show whether a chance error caused that loss, which answers a '
              'question many couples carry for years.'),
        ),
      ),
      PvReadSection(
        heading: _en('What do the tests look for?'),
        paragraphs: [
          _en('These are the tests international guidelines support. Your '
              'doctor will choose from them based on your history, so you may '
              'not need all of them:'),
        ],
        bullets: [
          _en('Antiphospholipid antibodies. A blood test, repeated after 12 '
              'weeks, for a condition that makes blood clot too easily in the '
              'placenta.'),
          _en('Thyroid. TSH, which shows how your thyroid is working, and '
              'thyroid antibodies.'),
          _en('The shape of your womb. Usually a 3D ultrasound. Sometimes a '
              'camera test through the cervix, called a hysteroscopy, which '
              'can also treat some problems.'),
          _en('Blood sugar, if diabetes is possible and has never been '
              'checked.'),
          _en('Chromosomes. The pregnancy tissue first, if it was tested, and '
              'blood tests for both of you only when your history points '
              'that way.'),
          _en('Scarring inside the womb, called Asherman syndrome. It is '
              'rare, and can follow a D&C or an infection. Much lighter '
              'periods afterwards can be a sign. A hysteroscopy can find and '
              'treat it.'),
        ],
      ),
      PvReadSection(
        collapsible: true,
        summary: _en('Some costly tests and treatments are sold after loss '
            'without good evidence. This list helps you ask why.'),
        heading: _en("Tests you may be offered that guidelines don't "
            'recommend'),
        paragraphs: [
          _en("After repeated losses, it's easy to be handed long lists of "
              'tests. Some are useful. Others are sold with more confidence '
              'than the evidence gives them.'),
          _en("Guidelines don't recommend these for most couples: natural "
              'killer (NK) cell tests and other broad immune panels, routine '
              'tests for inherited clotting conditions, and hormone tests '
              "without a clear reason. Treatments based on them, such as "
              "steroids or intralipid drips, haven't been shown to help."),
          _en('It\'s fine to ask: "Which guideline suggests this test, and '
              'what would we do differently with the result?" A good doctor '
              "won't mind the question."),
        ],
        mythFact: PvMythFact(
          myth: _en('The more tests we do, the more likely we are to find the '
              'answer.'),
          fact: _en('A test helps only when its result would change what you '
              'do. Long panels can find things that mean nothing and lead to '
              "treatments that don't help, at a high cost."),
        ),
      ),
      PvReadSection(
        heading: _en('Is there treatment if they find something?'),
        paragraphs: [
          _en('Often, yes. Antiphospholipid syndrome is usually treated with '
              'low-dose aspirin and heparin injections in the next pregnancy. '
              'An underactive thyroid is treated with a daily tablet. Some '
              'problems with the shape of the womb can be treated during a '
              'hysteroscopy.'),
          _en('NICE also advises progesterone for women who bleed in early '
              'pregnancy and have had a miscarriage before. Your doctor will '
              'say if this applies to you.'),
          _en('When nothing is found, the care with the best evidence is '
              'support: early scans, a named doctor or clinic you can call, '
              'and someone who knows your history. Guidelines note that '
              'couples with no cause found often do well with this care '
              'alone.'),
        ],
      ),
      PvReadSection(
        heading: _en('Do we need genetic counselling?'),
        paragraphs: [
          _en("Most couples after one or two losses don't. A genetic "
              'counsellor explains chromosome and inherited conditions, what '
              'test results mean, and the options for a next pregnancy. Large '
              'hospitals with a medical genetics department usually offer '
              'it.'),
          _en('A doctor may suggest seeing one if:'),
        ],
        bullets: [
          _en('Tests on the pregnancy tissue showed a chromosome change that '
              'could be inherited.'),
          _en('One of you carries a balanced translocation, where pieces of '
              "two chromosomes have swapped places. It doesn't affect the "
              "carrier's health, but it can cause losses."),
          _en('There is a known genetic condition in either family.'),
          _en('You and your partner are related by blood, as happens in some '
              'families.'),
          _en('A loss happened later in pregnancy, or a baby was born with a '
              'serious condition.'),
        ],
        tip: PvReadTip(
          title: _en('If one of you is a carrier'),
          body: _en('The counsellor will go through your options. These may '
              'include trying naturally with testing early in pregnancy, or '
              'IVF with testing of embryos. Many carriers have healthy babies '
              'without any treatment.'),
        ),
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en("Is it my fault, or my partner's, that this keeps "
            'happening?'),
        answer: _en('No. Even when a cause is found, it is something about '
            'how a body works, not something either of you did. Nobody '
            'chooses a clotting condition or a chromosome swap.'),
      ),
      PvReadFaq(
        question: _en('How much do these tests cost in India?'),
        answer: _en('It varies a lot between cities and hospitals. The basic '
            'blood tests and a scan often add up to a few thousand rupees, '
            "and chromosome tests cost more. It's fine to ask what each test "
            'costs before it is done.'),
      ),
      PvReadFaq(
        question: _en('Should I start aspirin or progesterone on my own, just '
            'in case?'),
        answer: _en("Please don't. Aspirin and heparin help in one specific "
            'condition, and progesterone in one specific situation. Taken '
            "without a reason, they don't help and can cause side effects. "
            'Ask your doctor first.'),
      ),
      PvReadFaq(
        question: _en('Our tests found nothing. Is there any point trying '
            'again?'),
        answer: _en('Yes. Repeated loss with no cause found often ends in a '
            'healthy pregnancy with good support, and many couples in this '
            'place do have a baby. Whether and when to try again is your '
            "choice, and there's no wrong answer."),
      ),
      PvReadFaq(
        question: _en('Should my husband be tested too?'),
        answer: _en('Sometimes. Chromosome blood tests are for both of you '
            'when they are needed. Some clinics also suggest a sperm DNA '
            'test. The evidence for it is still limited, so ask what the '
            'result would change.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to book, and when to go today'),
      body: _en('Book a visit with a gynaecologist or fertility clinic if '
          "you've had two or more losses, a loss after 12 weeks, or have a "
          "known thyroid, sugar or clotting condition. If you're pregnant now "
          'and have heavy bleeding, severe or one-sided pain, shoulder-tip '
          'pain or feel faint, go to a hospital today. If grief is making it '
          'hard to get through each day, tell your doctor. That is part of '
          'your care too.'),
    ),
    evidence: _en('The two-loss threshold, which tests to do and not do, '
        'and supportive care follow the ESHRE guideline on recurrent '
        'pregnancy loss (2022) and ASRM guidance. Testing the pregnancy '
        'tissue follows RCOG guidance on recurrent miscarriage. Progesterone '
        'for bleeding after a previous miscarriage follows NICE guideline '
        'NG126. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Book the visit'),
        value: _en('Note each loss and its date, so the first appointment '
            'starts with the full picture.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep the reports together'),
        value: _en('Scans, blood tests and tissue results in one place, for '
            'whoever you see next.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: [
      'ttc_read_trying_again',
      'ttc_read_miscarriage_causes',
      'ttc_read_loss_feelings',
    ],
  ),

  // ===========================================================================
  //  TRYING AGAIN — the feelings, and where to find help in India
  // ===========================================================================
  //  Gap pack: "Miscarriage and mental health: who to turn to" (P2, Support)
  //  and "How does a rainbow pregnancy feel?" (P3). The existing
  //  `ttc_read_trying_again` gives the feelings one section; this is the
  //  whole read, by the psychologist.
  //
  //  ⚠️ TITLE SOFTENED FROM THE PLAN ("the feelings nobody mentions"): the
  //  voice guide bans the "nobody tells you" construction.
  //
  //  ⚠️ THE HELPLINE IS THE SAME ONE `mind_mood_data.dart` VERIFIED
  //  (Tele-MANAS, 14416 / 1-800-891-4416, sources checked 2026-08-20). If
  //  that constant ever changes, change these three strings with it.
  PvRead(
    id: 'ttc_read_loss_feelings',
    hue: 26,
    kicker: _en('After a loss'),
    title: _en('Trying again after a loss: the feelings that come with it'),
    teaser: _en('Fear, guilt, envy and hope, often in the same day, and what '
        'helps with each.'),
    shortAnswer: _en('Trying again after a loss often brings fear and guilt '
        "alongside hope, and that's normal. There's no right time to feel "
        'ready, and a new pregnancy can feel frightening before it feels '
        'happy. If grief is making daily life hard, help is there, including '
        'Tele-MANAS on 14416.'),
    scaleSetter: _en('Most of what you feel while trying again is common, and '
        "it eases with time, even when it doesn't feel that way. Some people "
        'need more support than friends and family can give. The last part '
        'of this page says how to tell, and where to go.'),
    author: _en('Parmeshwari'),
    authorRole: _en('Clinical psychologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Trying again after a loss isn't the same as trying the first "
              'time. The first time, a late period meant hope. Now it can mean '
              'hope and dread together.'),
          _en("This page doesn't tell you how to feel. It names some feelings "
              "people often have, so that if they come, you know you're not "
              'alone in them.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does trying again feel so scary?'),
        paragraphs: [
          _en("Once you've lost a pregnancy, you know it can happen, and you "
              "can't unknow it. So the two-week wait may feel longer, a twinge "
              'may feel like a warning, and a positive test may bring as much '
              'fear as joy.'),
          _en("It doesn't mean you're being negative, and it doesn't affect "
              'whether you get pregnant. Your mind is trying to protect you '
              'from being hurt that way again.'),
          _en('Some people find it helps to decide ahead of time how they '
              'will test, such as waiting until the day the period is due, and '
              'who they will tell. A plan can make the wait feel a little less '
              'out of your hands.'),
        ],
      ),
      PvReadSection(
        heading: _en('Is it wrong to want to try so soon, or not at all?'),
        paragraphs: [
          _en('Some people want to try again straight away, then feel guilty, '
              "as if they're replacing the baby they lost. They aren't. "
              'Wanting another pregnancy and grieving this one can sit side '
              'by side.'),
          _en("Others don't want to try for a long time, or aren't sure they "
              "will again. That's just as valid. Feeling ready isn't a test "
              'you have to pass by a certain date.'),
          _en("Couples often don't feel the same thing at the same time. One "
              'of you may want to try next month while the other needs more '
              "time. Say it out loud, gently. You don't have to agree today."),
        ],
        tip: PvReadTip(
          title: _en('For partners'),
          body: _en('Partners grieve too, though it often looks different: '
              'busier, quieter, focused on her. If you are the partner, ask '
              'how she is doing, and say how you are doing as well. Many women '
              'say the hardest part was feeling they grieved alone.'),
        ),
      ),
      PvReadSection(
        heading: _en("Why do other people's pregnancies hurt so much?"),
        paragraphs: [
          _en("A friend's announcement, a baby shower or a godh bharai can be "
              'very painful right now. You may feel jealous, then guilty for '
              "feeling jealous. Both are normal. They don't make you a bad "
              'person.'),
          _en("You're allowed to skip an event, leave early or send a gift "
              'instead. You can mute a group chat for a while. Looking after '
              "yourself isn't rudeness."),
          _en('Some dates may be hard, like the day the baby was due or the '
              'day you found out. It can help to expect them, and to plan '
              'something small and gentle for that day.'),
        ],
      ),
      PvReadSection(
        heading: _en('What do I say when family ask?'),
        paragraphs: [
          _en("In many families a loss isn't talked about, and trying again is "
              'watched closely. You may hear "koi good news?", advice on food, '
              'or "it was God\'s will". Most of it comes from love, even when '
              'it hurts.'),
          _en('You don\'t owe anyone details. Short answers work: "We\'re '
              'taking our time." "We\'ll share news when there is some." '
              '"The doctor said nothing we did caused it." You can ask one '
              "trusted person to pass the word around, so you don't have to."),
          _en('If the comments keep coming from one side of the family, your '
              'partner can be the one to answer them. It is often easier for '
              'parents to hear it from their own son or daughter.'),
        ],
      ),
      PvReadSection(
        heading: _en("What if I'm pregnant again and can't feel happy?"),
        paragraphs: [
          _en('A pregnancy after a loss is sometimes called a rainbow '
              'pregnancy. Many people find it more anxious than joyful at '
              'first, especially until they pass the week when the last loss '
              "happened. That's very common, and it doesn't mean you love this "
              'baby any less.'),
          _en('Things that help: telling your doctor about your loss at the '
              'first visit, asking about an early scan, and asking who to call '
              "if you're worried between appointments. It's okay to ask for "
              'reassurance. Your care team is there for that.'),
          _en('Some people hold back from getting attached, from shopping or '
              "from telling anyone. That's okay too. A feeling of connection "
              "often grows as the weeks pass, and there's no deadline for it."),
        ],
      ),
      PvReadSection(
        heading: _en('When does grief need more help?'),
        paragraphs: [
          _en('Sadness, crying, anger and poor sleep are normal in the weeks '
              'after a loss. Ask for more help if, after a few weeks, the '
              "feelings are getting heavier instead of easing, or you can't "
              'manage work, meals or sleep.'),
          _en('Other signs are panic that keeps coming back, not wanting to '
              'see anyone at all, or feeling numb for a long time. Strong '
              'anxiety or flashbacks can follow a loss, especially one that '
              'needed emergency care. These can be treated.'),
          _en('In India you can call Tele-MANAS, the government\'s mental '
              'health helpline, on 14416 or 1-800-891-4416. It is free, open '
              'day and night, and you can speak in many Indian languages. Your '
              'gynaecologist can refer you to a clinical psychologist or '
              'psychiatrist, and many fertility clinics have a counsellor.'),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it normal to still cry about it months later?'),
        answer: _en("Yes. Grief doesn't follow a timetable, and it often comes "
            'back around dates, news or a negative test. Over time it usually '
            "becomes easier to carry, even if it doesn't go away completely."),
      ),
      PvReadFaq(
        question: _en("Should I see a counsellor even if I'm coping?"),
        answer: _en("You can. You don't have to be falling apart to deserve "
            'support. One or two sessions can help you make sense of what '
            'happened, especially before trying again.'),
      ),
      PvReadFaq(
        question: _en('Will the stress of grieving stop me getting pregnant?'),
        answer: _en("Everyday stress and sadness haven't been shown to stop "
            "you getting pregnant. Please don't add that worry to what you're "
            'already carrying.'),
      ),
      PvReadFaq(
        question: _en('Is it okay to name or remember the baby?'),
        answer: _en('Yes. Some people give the baby a name, plant a tree, '
            'light a diya on the due date or keep the scan picture. Others '
            'prefer not to. Whatever helps you is right.'),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell someone today if this is you'),
      body: _en('If you have thoughts of harming yourself, or feel others '
          "would be better off without you, don't wait for an appointment. "
          'Tell someone you trust today, and call Tele-MANAS on 14416 or '
          '1-800-891-4416 at any hour. If you feel you might act on these '
          'thoughts, call 112 or go to the nearest hospital emergency '
          'department. If low mood, panic or poor sleep have lasted more than '
          "two weeks and aren't easing, book a visit with your doctor or a "
          'counsellor within a week or two.'),
    ),
    evidence: _en('Grief, anxiety and post-traumatic stress after pregnancy '
        'loss follow NICE guideline NG126 on ectopic pregnancy and '
        'miscarriage, NICE guideline CG192 on antenatal and postnatal mental '
        'health, RCOG patient information and NHS guidance. Tele-MANAS is the '
        'national tele mental health service of the Ministry of Health and '
        'Family Welfare. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Write it down'),
        value: _en("A private place for what you're feeling, only if writing "
            'helps.'),
        surfaceId: 'ttc_journal',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Bring your partner in'),
        value: _en('Ways to talk about trying again as two people, at your '
            'own pace.'),
        surfaceId: 'ttc_partner',
      ),
    ],
    readNext: [
      'ttc_read_trying_again',
      'ttc_read_family_asking',
      'ttc_read_recurrent_miscarriage',
    ],
  ),
];
