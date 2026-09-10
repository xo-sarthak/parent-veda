// =============================================================================
//  Scans & tests — the reads for this door
// -----------------------------------------------------------------------------
//  ⚠️ ONE FILE PER DOOR, SO EIGHT BRIEFS CAN BE BUILT WITHOUT EIGHT CONFLICTS.
//  Same reason TTC split its own library: every new article is appended at the
//  same closing bracket, so every pair of parallel builds collides — and the
//  failure mode in a content file is not a compile error, it is an article
//  quietly lost in a resolution.
//
//  ⚠️ THE AGGREGATOR IS THE ONLY PUBLIC ENTRY POINT. Nothing outside
//  `pregnancy_reads.dart` should import this file, so the shape test keeps
//  scanning every read through one list.
//
//  ---------------------------------------------------------------------------
//  WHAT IS HERE, AND WHY EACH ONE IS NEW
//  ---------------------------------------------------------------------------
//
//  Six pieces. Everything else the Scans door shows is REUSE — the nine scan
//  pages in `tests_scans_reports_data.dart`, the twenty-seven findings in
//  `report_findings_data.dart`, the timeline, the locker. These six are the
//  gaps that walking the built door exposed, and four of the six are questions
//  that only exist in India:
//
//    · the sex law, which is the single most misread moment in an Indian
//      scan room and has no explainer anywhere in the app
//    · what scans cost, which nobody in this market answers honestly
//    · whether every test on the list is actually hers to take
//    · how to read a report at 11pm without deciding something is wrong
//    · what paper to keep, and what to carry to an appointment
//
//  ⚠️ TWO OF THESE ARE MARKED "short" IN THE BRIEF AND ARE NOT SHORT. The floor
//  on `PvRead` is four sections and six hundred words, and it was kept rather
//  than argued with: these sit on a rail beside nine rich scan pages, and a
//  two-paragraph card there does not read as concise, it reads as the one
//  nobody finished. Where a subject genuinely had less to say, the answer was
//  to find the substance it was missing — what a lab actually keeps and for how
//  long, what a receipt is worth at an insurance desk — not to pad it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ RUPEE FIGURES CARRY A DATE, AND THEY ARE RANGES
//  ---------------------------------------------------------------------------
//
//  Checked September 2026, against public rate cards. The same scan is ₹1,200
//  in a standalone lab in a tier-2 city and ₹4,500 in a corporate hospital in
//  Mumbai, so one number would be wrong for almost everyone. The ranges here
//  are the same ones `kScanCost` carries on the scan pages — that file is the
//  per-scan source and this read is the overview, so if one moves, move both.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE PER FILE, matching the convention in every TTC reads file. One
// line duplicated beats renaming a helper at a thousand call sites, and it
// keeps each content file readable on its own.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The scans bracket's hue — the only cool blue on the grid.
const double _hue = 206;

final List<PvRead> kPregnancyReadsScans = [
  // ===========================================================================
  //  1. The sex law
  // ---------------------------------------------------------------------------
  //  ⚠️ THE MOST INDIA-SPECIFIC PIECE IN THE PRODUCT, and the reason it exists
  //  is a failure that happens in a scan room every day: the sonographer
  //  refuses, sometimes brusquely, sometimes in a way that sounds like an
  //  accusation — and a mother who was not told beforehand reads that refusal
  //  as something being hidden about her baby.
  //
  //  `kPcpndtLine` in `scan_extras.dart` says this in one sentence on every
  //  scan page, before the day. This is the same fact with room to explain why
  //  the law exists, which is the half that turns a refusal from obstruction
  //  into protection.
  //
  //  ⚠️ NO LEGAL JARGON IN THE TITLE OR THE BODY — the brief says so twice. The
  //  Act is named once, because she may see it on a board on the wall and needs
  //  to recognise the words. Everywhere else it is "the law".
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_sex_law',
    hue: _hue,
    kicker: _en('Scans & tests'),
    title: _en('Why nobody will tell you the sex'),
    teaser: _en('It is not the clinic being unkind, and it is not about you. '
        'What the law says, why it exists, and what to expect in the room.'),

    // ⚠️ SCALE FIRST, AND THE SCALE HERE IS "you have not been singled out".
    // The question underneath is rarely curiosity about the law; it is "did
    // they see something and decide not to tell me".
    scaleSetter: _en('Every woman having a scan in India is told the same '
        'thing, in every clinic, by every sonographer. The refusal is not '
        'about your scan, your baby or you. It is the one thing they are not '
        'allowed to say to anybody.'),

    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Radiologist · 17 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('You will see a board on the wall of most scan rooms in India. '
              'It says, in some form, that the sex of the baby is not '
              'disclosed here. Some sonographers point at it. Some say it '
              'before you have asked. A few say it sharply, because they have '
              'been asked forty times this month and the question makes them '
              'nervous.'),
          _en('That sharpness is worth understanding before you meet it, '
              'because it lands badly in a room where you are already anxious '
              'and half-undressed. It is not aimed at you. Telling you would '
              'cost that person their licence and could send them to prison, '
              'and they have no way of knowing, in the ninety seconds they '
              'have with you, that you were only curious.'),
          _en('The law is the Pre-Conception and Pre-Natal Diagnostic '
              'Techniques Act. You may see it written as PCPNDT on the board. '
              'That is the only place in this piece you need the name — the '
              'rest is what it actually means for your afternoon.'),
        ],
      ),

      PvReadSection(
        heading: _en('Why the law exists'),
        paragraphs: [
          _en('In the 1980s, ultrasound machines arrived in India faster than '
              'anyone had planned for. Within a few years, clinics in several '
              'states were openly advertising sex determination, and a large '
              'number of pregnancies carrying girls were ended because of what '
              'a scan showed.'),
          _en('You can see the result in the census. In the decades that '
              'followed, the number of girls born for every thousand boys fell '
              'steadily, and in some districts it fell very far indeed. '
              'Demographers put the number of girls missing from the Indian '
              'population at several tens of millions. That is not a figure '
              'about attitudes. It is a count of people who are not here.'),
          _en('The law was written to shut that trade down. It makes it a '
              'crime to tell anyone the sex of a foetus, to ask, or to '
              'advertise that you can find out — and it holds the clinic, the '
              'doctor and the machine operator responsible rather than the '
              'woman on the table. Clinics register their machines, keep a '
              'signed form for every scan, and are inspected.'),
          _en('So the sentence you hear in the room is the last, smallest part '
              'of something quite large. It is also the part that works: the '
              'ratio has been climbing back, slowly, since enforcement '
              'tightened.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('You are not being suspected of anything'),
          body: _en('The form you sign before a scan is the clinic recording '
              'that it followed the law. It is their paperwork, not an '
              'accusation about your intentions, and every woman who has a '
              'scan signs one.'),
        ),
      ),

      PvReadSection(
        heading: _en('What this means on the day'),
        paragraphs: [
          _en('Practically, three things follow, and knowing them in advance '
              'takes most of the sting out of the room.'),
        ],
        bullets: [
          _en('You will be asked to sign a short form saying you have not come '
              'to find out the sex. Read it, sign it, and think no more about '
              'it. It is routine.'),
          _en('Do not ask, even lightly, even as a joke. It puts the person '
              'holding the probe in a genuinely difficult position, and it can '
              'change how the rest of the appointment goes.'),
          _en('Nobody can tell you afterwards either — not the doctor who '
              'reads the report, not a friend who works at the lab, not a '
              'second clinic. The report itself will not contain it.'),
        ],
      ),

      PvReadSection(
        heading: _en('What they can tell you'),
        paragraphs: [
          _en('Almost everything else. It is easy to come away thinking scans '
              'are secretive, and they are not — one single fact is off '
              'limits and the rest is yours to ask about.'),
          _en('You can ask what they are measuring and why. You can ask '
              'whether the baby is lying in a position that makes the pictures '
              'harder. You can ask how many weeks the measurements suggest, '
              'whether the placenta is where they expect it to be, and how '
              'much fluid there is.'),
          _en('What you may not get is an answer in the room. Many '
              'sonographers stay quiet through a scan and hand the report to '
              'your doctor, and that silence is a habit rather than a signal — '
              'they are concentrating, and in most clinics they are not the '
              'person whose job it is to explain findings. If the quiet '
              'worries you, say so. "I know you cannot tell me the sex, but is '
              'everything else looking as you would expect?" is a fair '
              'question and usually gets a fair answer.'),
        ],
      ),

      PvReadSection(
        heading: _en('If someone offers to tell you'),
        collapsible: true,
        summary: _en('Rare, but it happens — and what it costs is not only '
            'legal.'),
        paragraphs: [
          _en('Occasionally a small clinic, a travelling machine or an '
              'intermediary will offer to find out for a fee. It is a crime '
              'for them to offer and a crime to arrange it, and the penalties '
              'fall on everyone involved.'),
          _en('There is a quieter reason to walk away too. A clinic willing to '
              'break this law is telling you what it thinks rules are for, and '
              'you are about to trust it with measurements that decide whether '
              'your pregnancy is treated as ordinary or watched closely. An '
              'unregistered machine, an unqualified operator and an '
              'unverifiable report are the same package.'),
          _en('If you are being pressured by anyone — at home or outside it — '
              'to find out, that is worth saying out loud to your doctor. They '
              'have heard it before, and there are people whose job is exactly '
              'this.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Speak to your doctor if'),
      body: _en('Anyone is pressuring you to find out the sex of your baby, or '
          'threatening you over it. Tell your obstetrician, or call the '
          'national women\'s helpline on 181. This is not a small problem to '
          'raise, and they will not think it is.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Can my doctor tell me privately after the birth is '
            'closer?'),
        answer: _en('No. The law covers the whole pregnancy, and there is no '
            'week at which it stops applying. You will find out at the birth.'),
      ),
      PvReadFaq(
        question: _en('Is it different in a private hospital?'),
        answer: _en('No. Corporate hospital, government hospital, standalone '
            'lab — the same law, the same board on the wall, the same form.'),
      ),
      PvReadFaq(
        question: _en('What if I am abroad for part of my pregnancy?'),
        answer: _en('Other countries have their own rules and many do allow '
            'it. What is not allowed is arranging a scan abroad in order to '
            'act on the answer here. If you are travelling for other reasons '
            'and it comes up, that is a conversation to have with your own '
            'doctor rather than with us.'),
      ),
      PvReadFaq(
        question: _en('The sonographer was rude about it. Should I complain?'),
        answer: _en('You can, and the clinic should hear it. It is also worth '
            'knowing that brusqueness here is usually fear rather than '
            'contempt — the person operating the machine carries the legal '
            'risk personally. If it affected the care itself, that is a '
            'different matter and worth raising.'),
      ),
    ],

    evidence: _en('Pre-Conception and Pre-Natal Diagnostic Techniques Act, '
        '1994, as amended 2003 · Ministry of Health and Family Welfare, PCPNDT '
        'implementation guidance · Census of India sex ratio at birth series · '
        'Reviewed September 2026.'),

    readNext: ['preg_scan_read_costs', 'preg_scan_read_calm'],
  ),

  // ===========================================================================
  //  2. What scans cost
  // ---------------------------------------------------------------------------
  //  ⚠️ NOBODY IN THIS MARKET ANSWERS THIS HONESTLY, which is the whole reason
  //  it is here. The ranges are the ones `kScanCost` already carries per scan;
  //  this is the overview that lets her plan the whole pregnancy rather than
  //  one appointment.
  //
  //  ⚠️ THE JOB IS NOT "cheapest". It is to stop her being surprised at a
  //  counter and to let her recognise being overcharged. A range does that; a
  //  single number does not.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_costs',
    hue: _hue,
    kicker: _en('Scans & tests'),
    title: _en('What scans cost in India'),
    teaser: _en('Real ranges for each scan, what makes the same test cost '
        'three times more across town, and what you can get free.'),

    scaleSetter: _en('A whole pregnancy of scans and blood tests, done '
        'privately, usually lands somewhere between ₹8,000 and ₹25,000 — '
        'without the optional ones. At a government hospital most of it is '
        'free. Neither of those is the price of good care.'),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Public rate cards, checked September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Prices for the same scan vary enormously in India, and the '
              'variation is not mostly about quality. A dating scan is around '
              '₹800 at a standalone diagnostic centre in a smaller city and '
              'can be ₹2,500 at a corporate hospital in a metro. Both are the '
              'same fifteen minutes on a similar machine.'),
          _en('What you are paying for at the higher end is usually the '
              'building, the wait time, and a radiologist reporting rather '
              'than a technician. Sometimes that matters a great deal — a '
              'detailed anomaly scan is a skilled reading, not a photograph — '
              'and sometimes it does not.'),
          _en('The ranges below are what these actually cost across private '
              'centres, checked in September 2026. They are here so you can '
              'plan and so you can tell when a quote is well outside the '
              'usual. They are not a quote, and your city may sit at one end '
              'of each range consistently.'),
        ],
      ),

      PvReadSection(
        heading: _en('The usual run, and what each one costs'),
        paragraphs: [
          _en('This is the ordinary set for a pregnancy with no particular '
              'concerns. Not everyone has all of them.'),
        ],
        bullets: [
          _en('First blood tests, weeks 6 to 10 — ₹800 to ₹3,000 for the whole '
              'first panel together. Free at most government hospitals.'),
          _en('Dating scan, weeks 6 to 9 — ₹800 to ₹2,500.'),
          _en('NT scan, weeks 11 to 13 — ₹1,500 to ₹4,000, often quoted '
              'together with the double marker blood test.'),
          _en('NIPT, weeks 10 to 14 — ₹11,000 to ₹25,000. The most expensive '
              'test in pregnancy, and optional.'),
          _en('Anomaly scan, weeks 18 to 22 — ₹2,000 to ₹5,000. The longest '
              'scan, so the price reflects the time as much as the machine.'),
          _en('Sugar test, weeks 24 to 28 — ₹400 to ₹1,200.'),
          _en('Growth scan, weeks 28 to 36 — ₹1,200 to ₹3,000.'),
          _en('Doppler, weeks 30 to 40 — ₹1,500 to ₹3,500, usually done with a '
              'growth scan and billed as one.'),
          _en('Group B Strep swab, weeks 35 to 37 — ₹600 to ₹1,800.'),
        ],
      ),

      PvReadSection(
        heading: _en('What you can get free'),
        paragraphs: [
          _en('India runs a national antenatal programme, and it is genuinely '
              'free rather than subsidised. Registration at a government '
              'facility covers the routine blood tests, blood pressure and '
              'weight checks, iron and folic acid tablets, tetanus vaccination '
              'and at least one ultrasound.'),
          _en('There is also a scheme under which private doctors volunteer a '
              'day a month to see pregnant women free of charge at government '
              'centres, usually on the ninth of the month. If your pregnancy '
              'has been flagged as needing closer watching, that is a way to '
              'get a specialist opinion without a private fee.'),
          _en('Many women use both systems — free registration and routine '
              'care at a government centre, and pay privately for the anomaly '
              'scan, where the reading is the thing you are buying. That is a '
              'reasonable way to spend a limited budget.'),
        ],
        tip: PvReadTip(
          title: _en('Ask for the package price, not the test price'),
          body: _en('Most centres quote a lower total when scans and their '
              'blood tests are booked together — the NT scan with the double '
              'marker, the growth scan with the Doppler. Ask before you book '
              'them separately, because the discount is rarely offered.'),
        ),
      ),

      PvReadSection(
        heading: _en('Before you pay'),
        paragraphs: [
          _en('Three habits save most of the money that gets wasted here.'),
          _en('Ask what is included. A quoted scan price sometimes excludes '
              'the radiologist\'s report, the printed films, or a repeat if '
              'the baby is lying awkwardly and they need you to come back. A '
              'repeat visit for the same scan should not be a second full '
              'charge.'),
          _en('Ask whether the test is being ordered or offered. Ordered means '
              'your doctor wants the answer. Offered means it is available. '
              'Both are legitimate; only one of them is a plan.'),
          _en('Keep the receipt with the report. Many employer and individual '
              'health policies cover some maternity diagnostics, and a claim '
              'almost always needs the bill, the prescription that asked for '
              'the test, and the report itself. Losing any one of the three is '
              'the commonest reason a claim is refused.'),
        ],
      ),

      PvReadSection(
        heading: _en('When a price is a warning'),
        collapsible: true,
        summary: _en('Very cheap and very expensive can both be signals.'),
        paragraphs: [
          _en('A scan offered well below the usual range is worth a question. '
              'Registered machines, trained operators and a reporting '
              'radiologist all cost money, and the places that skip them are '
              'the places that quote unusually low.'),
          _en('At the other end, a bill far above the range is not fraud, but '
              'it is worth asking what it buys. If the answer is a longer slot '
              'with a foetal medicine specialist for a pregnancy being watched '
              'closely, that is real. If the answer is the lobby, you can '
              'decide.'),
          _en('And be careful with packages sold in advance for the whole '
              'pregnancy. They can be good value, and they are also money paid '
              'to one centre before you know whether you will still be with '
              'that doctor in five months.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not skip a scan over money without saying so'),
      body: _en('If a test your doctor has asked for is out of reach, tell '
          'them plainly. There is almost always a cheaper route — a government '
          'centre, a different lab, a simpler version of the same check — and '
          'they can only offer it if they know. Quietly missing a scan your '
          'doctor is waiting on is the one option with a real cost.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Is a costlier scan a better scan?'),
        answer: _en('Not reliably. For the anomaly scan the skill of the '
            'person reading it genuinely matters, so a centre with a foetal '
            'medicine specialist is worth paying for. For a dating scan or a '
            'growth scan, a registered centre with a working machine is a '
            'registered centre with a working machine.'),
      ),
      PvReadFaq(
        question: _en('Does insurance cover any of this?'),
        answer: _en('It varies a lot. Many policies have a waiting period of '
            'two to four years before maternity benefits start, and cover '
            'delivery more often than routine scans. Check your policy '
            'document rather than asking at the hospital desk, and keep every '
            'bill either way.'),
      ),
      PvReadFaq(
        question: _en('Why does the same lab quote differently on two days?'),
        answer: _en('Usually because one quote included the blood test that '
            'goes with the scan and the other did not, or because a discount '
            'applies to a bundle. Ask for the total in writing before you pay.'),
      ),
    ],

    evidence: _en('Public rate cards from private diagnostic chains and '
        'hospitals across metro and tier-2 cities, sampled September 2026 · '
        'National Health Mission antenatal care entitlements · Pradhan Mantri '
        'Surakshit Matritva Abhiyan scheme guidance, Ministry of Health and '
        'Family Welfare.'),

    readNext: ['preg_scan_read_every_scan', 'preg_scan_read_keep'],
  ),

  // ===========================================================================
  //  3. Do I need every scan on the list?
  // ---------------------------------------------------------------------------
  //  ⚠️ THE MYTH BLOCK IS IN THE OPENING SECTION, AND THAT IS A CONTRACT.
  //  `PvDoorMythTile` puts the chip "Myth vs fact" on the card. A chip is a
  //  promise about what the tap gives you, and a chip promising two lines that
  //  opens seven hundred words of essay is a chip that lies about length.
  //
  //  So the claim and the correction are the first thing on the screen, and
  //  `test/pv_door_scans_test.dart` asserts that any read a myth tile points at
  //  carries a `mythFact` in `sections.first`. The depth underneath is the
  //  reward for staying, not the price of entry.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_every_scan',
    hue: _hue,
    kicker: _en('Scans & tests'),
    title: _en('Do I need every scan on the list?'),
    teaser: _en('The timeline shows the usual run. It is not a checklist you '
        'are failing, and it is not a menu either.'),

    scaleSetter: _en('There is a short list of tests almost every pregnancy '
        'has, a longer list that depends on your history, and a few that are '
        'genuinely your choice. Knowing which is which is the whole of this '
        'piece — and your doctor decides the first group, not you and not us.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        // ⚠️ NO HEADING. The opening section runs straight on from the teaser,
        // and the myth block is the first thing under it — see the note above.
        mythFact: PvMythFact(
          myth: _en('The scan timeline is a checklist, and a pregnancy that '
              'misses one of them has gone wrong somewhere.'),
          fact: _en('It is the usual run, not a rule. Some of those tests are '
              'offered to everyone, some only when something in your history '
              'or an earlier result suggests them, and one or two are entirely '
              'optional. A pregnancy with six entries ticked and three blank '
              'is an ordinary pregnancy.'),
        ),
        paragraphs: [
          _en('The timeline in this app shows nine tests across a pregnancy. '
              'It is drawn as one line because that is how time works, and '
              'that shape accidentally suggests something it should not: that '
              'the line is a target and you are behind on it.'),
          _en('It is not. It is what a typical pregnancy in India involves, '
              'laid out so you know roughly what is coming and when. Your own '
              'set will be shorter or longer, and either is normal.'),
        ],
      ),

      PvReadSection(
        heading: _en('The ones almost everyone has'),
        paragraphs: [
          _en('These are offered to every pregnancy, and there is usually a '
              'good reason to have them. If your doctor has asked for one of '
              'these and you are thinking of skipping it, that is a '
              'conversation to have out loud rather than a decision to take '
              'quietly.'),
        ],
        bullets: [
          _en('The first blood panel. Blood group, haemoglobin, thyroid, sugar '
              'and a few infections. It is cheap, it changes management often, '
              'and it is free at government centres.'),
          _en('A dating scan. It fixes how many weeks you are, and every '
              'measurement for the rest of the pregnancy is read against that '
              'date. Getting it wrong early makes everything afterwards harder '
              'to interpret.'),
          _en('The anomaly scan around 20 weeks. The one detailed look at how '
              'the baby has formed. If you have one scan privately, most '
              'doctors would say make it this one.'),
          _en('The sugar test around 24 to 28 weeks. Pregnancy diabetes is '
              'common in India, usually has no symptoms at all, and is very '
              'treatable once found.'),
        ],
      ),

      PvReadSection(
        heading: _en('The ones that depend on you'),
        paragraphs: [
          _en('This group is where "do I need it" has a real answer, and the '
              'answer comes from your history rather than from a list.'),
          _en('Growth scans and Doppler studies in the last three months are '
              'routine in some practices and reserved in others. They are more '
              'clearly useful if your blood pressure is high, if the baby has '
              'measured small, if you have diabetes, or if you are carrying '
              'twins.'),
          _en('The Group B Strep swab near the end is standard practice in '
              'some countries and selective in India. It is a swab, it is '
              'quick, and what it changes is whether you are given antibiotics '
              'during labour.'),
          _en('Extra thyroid or iron checks, repeat scans after a finding that '
              'needed watching, and additional blood pressure monitoring all '
              'sit here too. None of them means something is wrong. They mean '
              'somebody is paying attention.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('A repeat scan is not bad news by itself'),
          body: _en('Babies lie in awkward positions, bladders are not always '
              'full enough, and some views simply cannot be got on the day. '
              '"Come back next week" is far more often about the picture than '
              'about the baby.'),
        ),
      ),

      PvReadSection(
        heading: _en('The ones that are genuinely your choice'),
        paragraphs: [
          _en('A small number of tests are offered rather than ordered, and '
              'the decision is properly yours. NIPT is the clearest example: a '
              'blood test that screens for a few chromosomal conditions, '
              'accurate, expensive, and optional in every sense.'),
          _en('The question worth asking yourself about any optional test is '
              'not whether it is accurate. It is what you would do with the '
              'answer. A screening result changes what comes next — it can '
              'lead to a further, more definite test, and that is a road worth '
              'looking down before you set off rather than after.'),
          _en('There is no wrong answer here, and declining one is not '
              'negligence. What is worth avoiding is having it done because it '
              'was on a package, without having thought about it.'),
        ],
      ),

      PvReadSection(
        heading: _en('How to ask'),
        collapsible: true,
        summary: _en('Four questions that settle almost any test.'),
        bullets: [
          _en('"Is this one you are asking for, or one that is available?"'),
          _en('"What would it change, if the result came back not normal?"'),
          _en('"Is there a simpler or cheaper test that answers the same '
              'question?"'),
          _en('"What happens if I wait two weeks?"'),
        ],
        paragraphs: [
          _en('These are not confrontational questions and no reasonable '
              'doctor hears them that way. They are the questions a doctor '
              'asks themselves before ordering something, and asking them out '
              'loud usually gets you the reasoning rather than just the '
              'instruction.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not delay these ones'),
      body: _en('If you have bleeding, one-sided pain low down, fluid leaking, '
          'a bad headache with blurred vision, or the baby moving much less '
          'than usual, that is not a question about which scan is necessary. '
          'Call your doctor the same day, whatever the timeline says.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('I missed the NT scan window. Have I lost something?'),
        answer: _en('Not everything. The NT measurement itself has to be taken '
            'in a narrow window, but blood screening is possible slightly '
            'later and the anomaly scan at 20 weeks is still ahead of you. '
            'Tell your doctor the dates you have and they will tell you what '
            'is still open.'),
      ),
      PvReadFaq(
        question: _en('My doctor orders far more scans than my sister\'s did. '
            'Is that a problem?'),
        answer: _en('Practice varies a great deal between doctors and between '
            'cities, and more monitoring is not harmful. It is fair to ask '
            'what each one is for. If the answer is specific to you, that is '
            'a plan; if it is "we do it for everyone", that is also a legitimate '
            'answer, and now you know which it is.'),
      ),
      PvReadFaq(
        question: _en('Can I have the anomaly scan and skip the rest?'),
        answer: _en('You can decline anything, but skipping the dating scan '
            'makes the anomaly scan harder to read, because the measurements '
            'are compared against how many weeks you are. The two are more '
            'useful together than the second is alone.'),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare antenatal care '
        'guidance · FOGSI good clinical practice recommendations on antenatal '
        'ultrasound · NICE guideline NG201, antenatal care · Reviewed '
        'September 2026.'),

    readNext: ['preg_scan_read_costs', 'preg_scan_read_calm'],
  ),

  // ===========================================================================
  //  4. Reading a report without panicking
  // ---------------------------------------------------------------------------
  //  ⚠️ THE MOMENT THIS APP EXISTS FOR IS A PRINTOUT AT 11pm. The decoder
  //  answers "what does this word mean"; nothing answered "how much weight
  //  should I put on this piece of paper at all", which is the question
  //  underneath the search.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_calm',
    hue: _hue,
    kicker: _en('Scans & tests'),
    title: _en('Reading a report without panicking'),
    teaser: _en('One reading is one moment. What a range really means, why '
        'labs disagree, and why a single number is not a verdict.'),

    scaleSetter: _en('Most reports that frighten people at 11pm are read as '
        'reassuring by a doctor at 10am. That is not because the doctor is '
        'being kind — it is because a report is a set of measurements, and '
        'measurements only mean something next to your history, your dates and '
        'each other.'),

    author: _en('Dr. Meera Krishnan'),
    authorRole: _en('Radiologist · 17 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('A scan or blood report is written for your doctor, not for you. '
              'That is not secrecy; it is the same reason a recipe written for '
              'a chef leaves out how to boil water. It means the language is '
              'compressed, the tone is flat, and anything unusual is stated '
              'as plainly as anything usual.'),
          _en('So a line noting that the placenta is low sits in exactly the '
              'same typeface as a line noting the baby\'s heartbeat, and reads '
              'to you as though it carries the same weight. It does not. One '
              'of those is a finding that resolves on its own in the large '
              'majority of pregnancies; the other is a fact.'),
          _en('The habit worth building is to read a report twice — once for '
              'what it says, and once for what it does not. Reports are '
              'usually longer about normal things than about anything else, '
              'because normal has more parts.'),
        ],
      ),

      PvReadSection(
        heading: _en('What a "normal range" actually is'),
        paragraphs: [
          _en('A reference range is not the boundary between healthy and ill. '
              'It is the middle stretch of what was measured in a group of '
              'people the lab considered typical — usually the middle ninety '
              'or ninety-five per cent of them.'),
          _en('Read that carefully and something follows immediately. If the '
              'range holds the middle ninety-five per cent, then one healthy '
              'person in twenty sits outside it, by definition, on any given '
              'test. Run eight tests on a completely well person and it is '
              'more likely than not that one comes back flagged.'),
          _en('This is why a single value a little outside a range is so '
              'rarely acted on by itself, and why your doctor may simply '
              'repeat it. A number that is out on its own is usually noise. A '
              'number that is out, and moving, and matches how you feel, is a '
              'finding.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('An asterisk is not a diagnosis'),
          body: _en('Lab software flags anything outside its range '
              'automatically, with no knowledge of you being pregnant, which '
              'trimester you are in, or what your last result was. Several '
              'values shift in normal pregnancy and get flagged every time.'),
        ),
      ),

      PvReadSection(
        heading: _en('Why two labs disagree'),
        paragraphs: [
          _en('If you have had the same test at two centres and got two '
              'answers, nothing has gone wrong. Different machines, different '
              'chemical methods and different reference populations give '
              'genuinely different numbers for the same blood.'),
          _en('It matters most for thyroid, for haemoglobin, and for anything '
              'reported in units you have to squint at. A thyroid result from '
              'one lab is not directly comparable to one from another, which '
              'is why doctors ask you to stay with one lab through a '
              'pregnancy where they are tracking a value.'),
          _en('Scans have their own version of this. An estimated foetal '
              'weight is calculated from three or four measurements using a '
              'formula, and different centres use different formulas. The '
              'honest margin on that estimate is around ten to fifteen per '
              'cent in either direction — so a baby estimated at 2.5 '
              'kilograms could reasonably be anywhere from about 2.1 to 2.9. '
              'It is an estimate wearing the clothes of a measurement.'),
        ],
        tip: PvReadTip(
          title: _en('Compare like with like'),
          body: _en('When you are tracking something across a pregnancy, use '
              'the same lab each time if you can, and keep the reports '
              'together so the trend is visible. A trend is far more '
              'informative than any single reading.'),
        ),
      ),

      PvReadSection(
        heading: _en('What to do with a report tonight'),
        paragraphs: [
          _en('Four things, in order, and they are deliberately small.'),
        ],
        bullets: [
          _en('Photograph it, so you cannot lose it and so you have it with '
              'you when you next speak to someone.'),
          _en('Look up the words you do not recognise, and stop there. '
              'Understanding a term is useful; searching for what it means for '
              'your baby is where a calm evening ends.'),
          _en('Write down the one or two things you actually want to ask. The '
              'act of writing usually shrinks it from a feeling to a question.'),
          _en('If it is not urgent, let it wait until morning. Nothing on a '
              'routine report is a decision to be taken at midnight.'),
        ],
      ),

      PvReadSection(
        heading: _en('When a report genuinely does change things'),
        collapsible: true,
        summary: _en('Some findings do need a plan — and they still need your '
            'doctor, not a search.'),
        paragraphs: [
          _en('None of this is an argument for ignoring a report. Some '
              'findings really do change what happens next: a placenta lying '
              'over the exit late in pregnancy changes how you are delivered, '
              'a high sugar result changes what you eat and how closely you '
              'are watched, and a baby measuring consistently small changes '
              'how often you are seen.'),
          _en('What those have in common is that the response is a plan made '
              'with a person, not a conclusion reached alone. The report is '
              'the beginning of a conversation. It was never intended to be '
              'the end of one.'),
          _en('And if the finding is one your app can explain, read the '
              'explanation before the appointment rather than instead of it. '
              'Arriving with an informed question is the best possible use of '
              'a fifteen-minute slot.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day if'),
      body: _en('The report itself says to contact your doctor urgently, or '
          'you have bleeding, fluid leaking, a bad headache with blurred '
          'vision or swelling, one-sided pain low down, or the baby is moving '
          'much less than usual. Do not wait for an appointment to discuss a '
          'result if any of those is happening now.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My report says "cannot be excluded". What does that '
            'mean?'),
        answer: _en('It is honest hedging, not a warning. It means the images '
            'did not show something and also could not completely rule it '
            'out — often because of the baby\'s position or the quality of the '
            'view. It usually leads to a repeat look rather than to anything '
            'else.'),
      ),
      PvReadFaq(
        question: _en('Should I get a second opinion on a scan?'),
        answer: _en('For a significant finding on an anomaly scan, a second '
            'reading by a foetal medicine specialist is reasonable and '
            'commonly done. For a routine growth scan, repeating it elsewhere '
            'usually just gives you a second estimate with the same margin of '
            'error.'),
      ),
      PvReadFaq(
        question: _en('The estimated weight jumped a lot between two scans. '
            'Is that possible?'),
        answer: _en('Often it is the estimate that jumped rather than the '
            'baby. With a margin of ten to fifteen per cent on each reading, '
            'two scans a fortnight apart can look like a sharp change when '
            'growth has been steady. Your doctor reads the curve, not the '
            'points.'),
      ),
      PvReadFaq(
        question: _en('Can I ask the sonographer to explain the report?'),
        answer: _en('You can ask, and sometimes you will get an answer. In '
            'many Indian clinics the person scanning is not the person '
            'reporting, and explaining findings is not their role. The doctor '
            'who ordered the scan is the right person.'),
      ),
    ],

    evidence: _en('Royal College of Obstetricians and Gynaecologists patient '
        'information on ultrasound in pregnancy · ISUOG practice guidelines on '
        'foetal biometry and estimated weight accuracy · IFCC guidance on '
        'method-dependent reference intervals · Reviewed September 2026.'),

    readNext: ['preg_scan_read_keep', 'preg_scan_read_take_along'],
  ),

  // ===========================================================================
  //  5. What to keep, and why
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_keep',
    hue: _hue,
    kicker: _en('Scans & tests'),
    title: _en('What to keep, and why'),
    teaser: _en('Which pieces of paper matter later, how long a lab actually '
        'keeps yours, and what a photograph on your phone is worth.'),

    scaleSetter: _en('You will collect more paper in nine months than you '
        'expect, and about six items of it matter afterwards. Knowing which '
        'six turns a bag of receipts into a record you can hand to somebody.'),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('The reason to keep things is not tidiness. It is that at some '
              'point in the next few years somebody will ask you a question '
              'you cannot answer from memory — a new doctor in a new city, an '
              'insurance desk, or a paediatrician asking what your blood group '
              'is and whether you needed an injection for it.'),
          _en('The other reason is more immediate. Labs and clinics do not '
              'keep your records as long as you would assume, and a scan '
              'centre you visited once in the first trimester may have nothing '
              'retrievable eighteen months later. In practice, the only copy '
              'certain to exist in five years is yours.'),
        ],
      ),

      PvReadSection(
        heading: _en('The six that matter'),
        paragraphs: [
          _en('If you keep nothing else, keep these.'),
        ],
        bullets: [
          _en('Your blood group and Rh status. It decides whether you need an '
              'anti-D injection, and it is asked for at every admission for '
              'the rest of your life.'),
          _en('The dating scan report. It is what fixes your due date, and '
              'every later measurement is read against it.'),
          _en('The anomaly scan report. The one detailed look at how the baby '
              'formed, and the document a specialist will ask for first if '
              'anything is ever queried.'),
          _en('Any result that was outside the usual range, and the repeat '
              'that followed it. The pair together is the useful thing; either '
              'one alone tells half a story.'),
          _en('Your antenatal card or booklet, with the blood pressure, weight '
              'and haemoglobin entries. It is the only continuous record of '
              'the pregnancy, and it is easy to leave behind at a clinic.'),
          _en('Bills and the prescriptions that asked for each test, if you '
              'may claim on insurance. A claim needs the prescription, the '
              'bill and the report — and is refused for missing any of the '
              'three more often than for anything else.'),
        ],
      ),

      PvReadSection(
        heading: _en('A photograph counts, with two conditions'),
        paragraphs: [
          _en('A clear photograph of a report is a real record. Doctors read '
              'them from phones every day, and it is far better than a lost '
              'original.'),
          _en('It has to be readable, though, and that is where most phone '
              'copies fail. Shoot the whole page flat, in daylight or under a '
              'plain ceiling light, without your own shadow across it and '
              'without the flash bouncing off glossy paper. Check that the '
              'small print at the bottom — the date, the lab name and the '
              'reference ranges — is legible when you zoom in, because that '
              'is the part a doctor actually needs.'),
          _en('And it has to be findable. Four hundred photographs into a '
              'pregnancy, a report taken between two pictures of a bump is '
              'effectively gone. Putting them in one place, named, is the '
              'whole difference between a photograph and a record — which is '
              'what the report locker in this app is for.'),
        ],
        tip: PvReadTip(
          title: _en('Photograph the films too, not only the report'),
          body: _en('Ultrasound films fade. The thermal paper the images are '
              'printed on darkens or washes out within a few years, sometimes '
              'within one, and there is no way to recover it. Photograph them '
              'the week you get them.'),
        ),
      ),

      PvReadSection(
        heading: _en('What to keep for how long'),
        paragraphs: [
          _en('The honest answer for the six items above is indefinitely; '
              'they take up almost no room as photographs and they get asked '
              'about years later.'),
          _en('Routine reports that came back normal and were never followed '
              'up matter far less. Keeping them costs nothing digitally, so '
              'there is no reason to throw them away, but there is also no '
              'reason to worry if one is missing.'),
          _en('Bills are the exception with a real deadline. Most insurers '
              'require a claim to be filed within a fixed window after the '
              'treatment, often measured in weeks rather than months, so bills '
              'are the one category where "I will sort it out later" has a '
              'cost. If you are going to claim, do it while the pregnancy is '
              'still the thing you are thinking about.'),
        ],
      ),

      PvReadSection(
        heading: _en('Who else should have a copy'),
        collapsible: true,
        summary: _en('One other person, at minimum.'),
        paragraphs: [
          _en('Your partner, your mother or whoever would be with you in an '
              'emergency should be able to reach your blood group and your '
              'due date without you. If you are the only person who can open '
              'the folder, the record is not doing its job at the one moment '
              'it exists for.'),
          _en('It is also worth carrying the essentials somewhere that works '
              'without a signal — a screenshot in your phone\'s photos, or a '
              'single printed page in your bag. Hospitals and rural areas are '
              'both places where a cloud folder is exactly as useful as no '
              'folder at all.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Tell your doctor if you cannot find these'),
      body: _en('If your blood group or your Rh status is not written down '
          'anywhere and you are bleeding, or you are being admitted, say so '
          'immediately rather than waiting to be asked. It is a quick test to '
          'repeat, and it changes what is given to you.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('How long does a lab keep my report?'),
        answer: _en('It varies widely, and small centres keep less than large '
            'chains. Some online portals expire after a year. Assume nothing '
            'is retrievable after a couple of years, and treat your own copy '
            'as the real one.'),
      ),
      PvReadFaq(
        question: _en('Do I need the printed films, or is the report enough?'),
        answer: _en('The report is what carries the findings and is what a '
            'doctor reads. The films matter if a specialist wants to look at '
            'the images themselves, which happens mainly after a finding on '
            'the anomaly scan. Keep both if you can; photograph both either '
            'way.'),
      ),
      PvReadFaq(
        question: _en('Is it safe to keep medical reports in a phone app?'),
        answer: _en('Keep them somewhere you control and can reach without a '
            'signal. Whatever you use, make sure one other person you trust '
            'can get to your blood group and due date in an emergency.'),
      ),
    ],

    evidence: _en('National Health Mission Mother and Child Protection Card '
        'guidance · Insurance Regulatory and Development Authority of India '
        'health claim documentation norms · Reviewed September 2026.'),

    readNext: ['preg_scan_read_take_along', 'preg_scan_read_calm'],
  ),

  // ===========================================================================
  //  6. Take it to your appointment
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_take_along',
    hue: _hue,
    kicker: _en('Scans & tests'),
    title: _en('Take it to your appointment'),
    teaser: _en('What to carry, what to have ready, and how to use ten '
        'minutes with a doctor who is running late.'),

    scaleSetter: _en('An antenatal appointment in India often runs to eight or '
        'ten minutes, and a good part of that can go on finding a piece of '
        'paper. Five minutes of preparation the night before roughly doubles '
        'the useful part.'),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Reviewed by Dr. Anita Desai, Obstetrician · September '
        '2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('The commonest way an appointment is wasted is not rudeness or '
              'rushing. It is the first four minutes going on reconstruction — '
              'which lab, which week, what the last haemoglobin was, whether '
              'the tablets were the white ones or the red ones.'),
          _en('None of that is difficult to have ready. It is only difficult '
              'to remember to have ready, which is why this is a list rather '
              'than advice.'),
        ],
      ),

      PvReadSection(
        heading: _en('What to carry'),
        bullets: [
          _en('Your antenatal card or booklet. The single most useful object '
              'in the bag, and the one most often left at home.'),
          _en('Every report since your last visit, in date order. If they are '
              'on your phone, have them open before you go in rather than '
              'searching in the chair.'),
          _en('The strips or boxes of anything you are taking, including '
              'anything bought without a prescription and anything traditional. '
              'The box answers a question the name usually cannot.'),
          _en('Your list of questions, written down. Three is a good number; '
              'more than five and the last ones will not get asked.'),
          _en('Your blood group, your last period date and your due date, '
              'somewhere you can read them out without looking anything up.'),
        ],
        paragraphs: [
          _en('If you use the locker in this app, all of that except the '
              'tablets is already in one place, which is most of the point of '
              'putting it there.'),
        ],
      ),

      PvReadSection(
        heading: _en('What to have ready to say'),
        paragraphs: [
          _en('Doctors ask a small number of questions at almost every '
              'antenatal visit, and answering them precisely rather than '
              'approximately changes what they can do with the answer.'),
          _en('How the baby has been moving, in the last two days rather than '
              'in general. Whether there has been any bleeding or fluid, even '
              'a small amount, even once. Whether you have had headaches, '
              'swelling in your face or hands, or changes in your vision. How '
              'you are sleeping and eating. And how you have been feeling in '
              'yourself, which is a real medical question and not small talk.'),
          _en('If something has changed and you are not sure whether it '
              'counts, say it anyway. Deciding what is relevant is the job you '
              'came to hand over.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Lead with the thing that worried you'),
          body: _en('Say the most important thing in the first minute, not the '
              'last. Appointments are interrupted, shortened and reordered, '
              'and the question saved for the end is the one that gets left '
              'out.'),
        ),
      ),

      PvReadSection(
        heading: _en('Before you leave the room'),
        paragraphs: [
          _en('Three things are worth confirming while you are still sitting '
              'down, because each of them is a return trip if it is missed.'),
        ],
        bullets: [
          _en('What was decided, said back in your own words. "So I am '
              'starting the iron tablets and coming back in four weeks" takes '
              'ten seconds and catches most misunderstandings.'),
          _en('What is next and when — the next test, the next visit, and '
              'roughly which week it falls in.'),
          _en('What would make you call before then. Every doctor has a '
              'threshold in mind; very few say it out loud unless asked.'),
        ],
      ),

      PvReadSection(
        heading: _en('If you are seeing someone new'),
        collapsible: true,
        summary: _en('A new city, a new hospital, or a doctor covering for '
            'yours.'),
        paragraphs: [
          _en('A doctor meeting you for the first time at thirty weeks is '
              'starting from nothing, and what you carry is the entire history '
              'they have. This is the appointment where the dating scan '
              'report matters most — it is what tells them how many weeks you '
              'are, independently of what you remember.'),
          _en('Bring the whole set rather than the recent ones. A finding from '
              'twenty weeks that resolved is still context, and "there was '
              'something about the placenta early on but it moved" is much '
              'less useful than the report that says so.'),
          _en('And say who has been looking after you and where. Continuity '
              'is easier to restore than to reconstruct, and most doctors will '
              'simply call.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Do not wait for the appointment if'),
      body: _en('You have bleeding, fluid leaking, a bad headache with blurred '
          'vision or sudden swelling, one-sided pain low down, fever, or the '
          'baby is moving much less than usual. These are reasons to call now '
          'rather than to add to a list for Thursday.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Should I take someone with me?'),
        answer: _en('If you can, yes — for the appointments where a result is '
            'being discussed in particular. Two people remember roughly twice '
            'as much of a conversation, and one of them is not the person '
            'being told the news.'),
      ),
      PvReadFaq(
        question: _en('Can I record what the doctor says?'),
        answer: _en('Ask first. Many doctors are fine with it and some are '
            'not, and asking takes five seconds. Written notes are less '
            'awkward and almost as useful.'),
      ),
      PvReadFaq(
        question: _en('I forgot to ask something and I am already home.'),
        answer: _en('Most clinics will answer a short question by phone or '
            'message, and it is a normal thing to do. Write it down for next '
            'time as well, in case it is not answered.'),
      ),
    ],

    evidence: _en('World Health Organization recommendations on antenatal care '
        'for a positive pregnancy experience · Ministry of Health and Family '
        'Welfare antenatal care module · Reviewed September 2026.'),

    readNext: ['preg_scan_read_keep', 'preg_scan_read_calm'],
  ),
];
