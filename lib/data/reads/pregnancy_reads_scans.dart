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
//  2026-09-29 (pregnancy warmth pass, gap analysis): the six were rewritten
//  to docs/PREG-VOICE.md, lost the invented reviewers (desk byline,
//  `reviewed: false`), gained short answers, and seven were added after
//  them: the scan person (the coming-soon card, finished), the first
//  antenatal visit, hCG and early blood tests, blood group and Rh, vaccines,
//  NST and BPP.
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
    // Rewritten 2026-09-29 to docs/PREG-VOICE.md. No clinician has reviewed
    // this piece, so it carries the desk byline and no verified mark.
    reviewed: false,
    shortAnswer: _en(
        "By law, nobody in India can tell anyone the baby's sex before birth. Every clinic says no to every woman, so the refusal isn't about your scan or your baby. You can ask about everything else."),
    kicker: _en('Scans & tests'),
    title: _en('Why nobody will tell you the sex'),
    teaser: _en("It isn't the clinic being unkind, and it isn't about you. "
                "What the law says, why it's there, and what to expect in "
                "the room."),

    // ⚠️ SCALE FIRST, AND THE SCALE HERE IS "you have not been singled out".
    // The question underneath is rarely curiosity about the law; it is "did
    // they see something and decide not to tell me".
    scaleSetter: _en("Every woman having a scan in India is told the same "
                     "thing, in every clinic, by every sonographer. The "
                     "refusal isn't about your scan, your baby or you. It's "
                     "the one thing they aren't allowed to say to anybody."),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("You'll see a board on the wall of most scan rooms in India. "
              "In some form, it says the sex of the baby isn't disclosed "
              "here. Some sonographers point at it. Some say it before "
              "you've asked. A few say it sharply, because they've been "
              "asked forty times this month and the question makes them "
              "nervous."),
          _en("It helps to understand that sharpness before you meet it, "
              "because it can hurt in a room where you're already anxious "
              "and half undressed. It isn't aimed at you. Telling you could "
              "cost that person their licence and could send them to prison, "
              "and in the ninety seconds they have with you, they can't know "
              "you were only curious."),
          _en("The law is the Pre-Conception and Pre-Natal Diagnostic "
              "Techniques Act. You may see it written as PCPNDT on the "
              "board. That's the only place in this piece you need the name. "
              "The rest is what it means for your afternoon."),
        ],
      ),

      PvReadSection(
        heading: _en('Why is there a law about this?'),
        paragraphs: [
          _en('In the 1980s, ultrasound machines spread across India faster '
              'than anyone had planned for. Within a few years, clinics in '
              'several states were openly advertising sex determination, and '
              'a large number of pregnancies carrying girls were ended '
              'because of what a scan showed.'),
          _en("You can see the result in the census. In the decades that "
              "followed, the number of girls born for every thousand boys "
              "fell steadily, and in some districts it fell very far. "
              "Demographers put the number of girls missing from India's "
              "population at several tens of millions. That isn't a figure "
              "about attitudes. It's a count of people who aren't here."),
          _en("The law was written to shut that trade down. It's a crime to "
              "tell anyone the sex of a baby before birth, to ask, or to "
              "advertise that you can find out. It holds the clinic, the "
              "doctor and the machine operator responsible, not the woman on "
              "the table. Clinics register their machines, keep a signed "
              "form for every scan, and are inspected."),
          _en("So the sentence you hear in the room is the last, smallest "
              "part of something much bigger. It's also the part that works. "
              "The ratio has been slowly climbing back since the law was "
              "enforced more strictly."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Nobody suspects you of anything'),
          body: _en("The form you sign before a scan is the clinic's record "
                    "that it followed the law. It's their paperwork, not a "
                    "comment on you, and every woman who has a scan signs "
                    "one."),
        ),
      ),

      PvReadSection(
        heading: _en('What does this mean on the day?'),
        paragraphs: [
          _en('Three things follow, and knowing them in advance takes most '
              'of the sting out of the room.'),
        ],
        bullets: [
          _en("You'll be asked to sign a short form saying you haven't come "
              "to find out the sex. Read it, sign it, and don't give it "
              "another thought. It's routine."),
          _en("Please don't ask, even lightly or as a joke. It puts the "
              "person holding the probe in a hard spot, and it can change "
              "how the rest of the appointment goes."),
          _en("Nobody can tell you afterwards either: not the doctor who "
              "reads the report, not a friend who works at the lab, not a "
              "second clinic. The report won't contain it."),
        ],
      ),

      PvReadSection(
        heading: _en('What can they tell you?'),
        paragraphs: [
          _en("Almost everything else. It's easy to come away thinking scans "
              "are secretive, and they aren't. One fact is off limits, and "
              "the rest is yours to ask about."),
          _en("You can ask what they're measuring and why. You can ask "
              "whether your baby is lying in a way that makes the pictures "
              "harder. You can ask how many weeks the measurements suggest, "
              "whether the placenta is where they'd expect, and how much "
              "fluid there is."),
          _en('What you may not get is an answer in the room. Many '
              'sonographers stay quiet through a scan and send the report to '
              'your doctor. That silence is a habit, not a signal. They\'re '
              'concentrating, and in most clinics explaining findings isn\'t '
              'their job. If the quiet worries you, say so. "I know you '
              'can\'t tell me the sex, but is everything else looking as '
              'you\'d expect?" is a fair question, and it usually gets a '
              'fair answer.'),
        ],
      ),

      PvReadSection(
        heading: _en('What if someone offers to tell you?'),
        collapsible: true,
        summary: _en("It's rare, but it happens, and the cost isn't only "
                     "legal."),
        paragraphs: [
          _en("Now and then a small clinic, a travelling machine or a "
              "middleman offers to find out for a fee. It's a crime for them "
              "to offer and a crime to arrange it, and everyone involved can "
              "be punished."),
          _en("There's another reason to walk away. A clinic willing to "
              "break this law is showing you what it thinks of rules, and "
              "you're about to trust it with measurements that decide "
              "whether your pregnancy is treated as routine or watched "
              "closely. An unregistered machine, an untrained operator and a "
              "report nobody can check tend to come together."),
          _en("If anyone, at home or outside it, is pressuring you to find "
              "out, please tell your doctor. They've heard it before, and "
              "there are people whose job is to help with exactly this."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Speak to your doctor if'),
      body: _en("Anyone is pressuring you to find out the sex of your baby, "
                "or threatening you over it. Tell your obstetrician, or call "
                "the national women's helpline on 181. It isn't a small "
                "thing to raise, and they won't think it is."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Can my doctor tell me privately closer to the birth?'),
        answer: _en("No. The law covers the whole pregnancy, and there's no "
                    "week when it stops. You'll find out at the birth."),
      ),
      PvReadFaq(
        question: _en('Is it different in a private hospital?'),
        answer: _en('No. Corporate hospital, government hospital or '
                    'standalone lab: the same law, the same board on the '
                    'wall, the same form.'),
      ),
      PvReadFaq(
        question: _en("What if I'm abroad for part of my pregnancy?"),
        answer: _en("ParentVeda doesn't help with learning the baby's sex "
                    "anywhere, so this piece won't go there. What matters "
                    "for your care is that any scan report you have abroad "
                    "comes home with you, so your doctor here can read it "
                    "with the rest of your notes."),
      ),
      PvReadFaq(
        question: _en('The sonographer was rude about it. Should I complain?'),
        answer: _en("You can, and the clinic should hear it. It also helps "
                    "to know that bluntness here is usually fear, not "
                    "contempt, because the person using the machine carries "
                    "the legal risk personally. If it affected your care "
                    "itself, that's a different matter and worth raising."),
      ),
    ],

    evidence: _en('Pre-Conception and Pre-Natal Diagnostic Techniques Act, '
                  '1994, as amended 2003 · Ministry of Health and Family '
                  'Welfare, PCPNDT implementation guidance · Census of India '
                  'sex ratio at birth series · Sources checked September '
                  '2026.'),

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
    // Rewritten 2026-09-29 to docs/PREG-VOICE.md. No clinician has reviewed
    // this piece, so it carries the desk byline and no verified mark.
    reviewed: false,
    shortAnswer: _en(
        "A whole pregnancy of scans and blood tests, done privately, usually costs ₹8,000 to ₹25,000 without the optional ones. Most of it is free at a government hospital. A higher price isn't always better care."),
    kicker: _en('Scans & tests'),
    title: _en('What scans cost in India'),
    teaser: _en('Real ranges for each scan, why the same test can cost three '
                'times more across town, and what you can get free.'),

    scaleSetter: _en('A whole pregnancy of scans and blood tests, done '
                     'privately, usually comes to somewhere between ₹8,000 '
                     'and ₹25,000, not counting the optional ones. At a '
                     'government hospital most of it is free. Neither figure '
                     'is the price of good care.'),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Public rate cards, checked September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Prices for the same scan vary a lot in India, and it isn't "
              "mostly about quality. A dating scan is around ₹800 at a "
              "standalone diagnostic centre in a smaller city and can be "
              "₹2,500 at a corporate hospital in a metro. Both are the same "
              "fifteen minutes on a similar machine."),
          _en("At the higher end you're usually paying for the building, the "
              "waiting time, and a radiologist writing the report instead of "
              "a technician. Sometimes that matters a lot, because a "
              "detailed anomaly scan is a skilled reading, not a photograph. "
              "Sometimes it doesn't."),
          _en("The ranges below are what these cost across private centres, "
              "checked in September 2026. They're here so you can plan and "
              "can tell when a quote is well outside the usual. They aren't "
              "a quote, and your city may sit at one end of each range."),
        ],
      ),

      PvReadSection(
        heading: _en('What does each scan usually cost?'),
        paragraphs: [
          _en('This is the usual set for a pregnancy with no particular '
              'concerns. Not everyone has all of them.'),
        ],
        bullets: [
          _en('First blood tests, weeks 6 to 10: ₹800 to ₹3,000 for the '
              'whole first panel together. Free at most government hospitals.'),
          _en('Dating scan, weeks 6 to 9: ₹800 to ₹2,500.'),
          _en('NT scan, weeks 11 to 13: ₹1,500 to ₹4,000, often quoted '
              'together with the double marker blood test.'),
          _en('NIPT, weeks 10 to 14: ₹11,000 to ₹25,000. The most expensive '
              'test in pregnancy, and optional.'),
          _en("Anomaly scan, weeks 18 to 22: ₹2,000 to ₹5,000. It's the "
              "longest scan, so the price is for the time as much as the "
              "machine."),
          _en('Sugar test, weeks 24 to 28: ₹400 to ₹1,200.'),
          _en('Growth scan, weeks 28 to 36: ₹1,200 to ₹3,000.'),
          _en('Doppler, weeks 30 to 40: ₹1,500 to ₹3,500, usually done with '
              'a growth scan and billed as one.'),
          _en('Group B Strep swab, weeks 35 to 37: ₹600 to ₹1,800.'),
        ],
      ),

      PvReadSection(
        heading: _en('What can you get free?'),
        paragraphs: [
          _en("India runs a national antenatal programme, and it's free, not "
              "just subsidised. Registering at a government facility covers "
              "the routine blood tests, blood pressure and weight checks, "
              "iron and folic acid tablets, tetanus vaccination and at least "
              "one ultrasound."),
          _en("There's also a scheme where private doctors give a day a "
              "month to see pregnant women free at government centres, "
              "usually on the ninth of the month. If your pregnancy has been "
              "flagged as needing a closer eye, it's a way to see a "
              "specialist without a private fee."),
          _en("Many women use both: free registration and routine care at a "
              "government centre, and a private anomaly scan, where the "
              "reading is what you're paying for. That's a sensible way to "
              "spend a tight budget."),
        ],
        tip: PvReadTip(
          title: _en('Ask for the package price, not the test price'),
          body: _en('Most centres quote a lower total when a scan and its '
                    'blood test are booked together, like the NT scan with '
                    'the double marker, or the growth scan with the Doppler. '
                    'Ask before you book them separately, because the '
                    'discount is rarely offered.'),
        ),
      ),

      PvReadSection(
        heading: _en('What should you ask before you pay?'),
        paragraphs: [
          _en('Three habits save most of the money that gets wasted here.'),
          _en("Ask what's included. A quoted scan price sometimes leaves out "
              "the radiologist's report, the printed films, or a repeat if "
              "your baby is lying awkwardly and they need you to come back. "
              "A repeat visit for the same scan shouldn't be a second full "
              "charge."),
          _en("Ask whether the test is being ordered or offered. Ordered "
              "means your doctor wants the answer. Offered means it's "
              "available. Both are fine, and only one of them is a plan."),
          _en('Keep the receipt with the report. Many employer and personal '
              'health policies cover some maternity tests, and a claim '
              'almost always needs the bill, the prescription that asked for '
              'the test, and the report. Losing any one of the three is the '
              'most common reason a claim is refused.'),
        ],
      ),

      PvReadSection(
        heading: _en('When is a price a warning sign?'),
        collapsible: true,
        summary: _en('Very cheap and very expensive can both be signs.'),
        paragraphs: [
          _en('A scan offered well below the usual range is worth a '
              'question. Registered machines, trained operators and a '
              'reporting radiologist all cost money, and the places that '
              'skip them are the ones that quote very low.'),
          _en("At the other end, a bill far above the range isn't fraud, but "
              "it's fair to ask what it buys. If the answer is a longer slot "
              "with a fetal medicine specialist because your pregnancy is "
              "being watched closely, that's real. If the answer is the "
              "lobby, you can decide."),
          _en("Be careful with packages sold in advance for the whole "
              "pregnancy. They can be good value, but it's money paid to one "
              "centre before you know whether you'll still be with that "
              "doctor in five months."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Please don't skip a scan over money without saying so"),
      body: _en("If a test your doctor has asked for is out of reach, tell "
                "them plainly. There's almost always a cheaper route, like a "
                "government centre, a different lab, or a simpler version of "
                "the same check, and they can only offer it if they know. "
                "Missing a scan your doctor is waiting on, without telling "
                "them, is the one option with a real cost."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Is a costlier scan a better scan?'),
        answer: _en('Not always. For the anomaly scan, the skill of the '
                    'person reading it matters, so a centre with a fetal '
                    'medicine specialist is worth paying for. For a dating '
                    'scan or a growth scan, any registered centre with a '
                    'working machine will do the job.'),
      ),
      PvReadFaq(
        question: _en('Does insurance cover any of this?'),
        answer: _en('It varies a lot. Many policies have a waiting period of '
                    'two to four years before maternity cover starts, and '
                    'they cover delivery more often than routine scans. '
                    'Check your policy document rather than asking at the '
                    'hospital desk, and keep every bill either way.'),
      ),
      PvReadFaq(
        question: _en('Why does the same lab quote differently on two days?'),
        answer: _en("Usually because one quote included the blood test that "
                    "goes with the scan and the other didn't, or because a "
                    "discount applies to a bundle. Ask for the total in "
                    "writing before you pay."),
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
    // Rewritten 2026-09-29 to docs/PREG-VOICE.md. No clinician has reviewed
    // this piece, so it carries the desk byline and no verified mark.
    reviewed: false,
    shortAnswer: _en(
        "No. A few tests are offered in almost every pregnancy, some depend on your history, and a few are your choice. The timeline is the usual run, not a checklist, and your doctor decides which ones you need."),
    kicker: _en('Scans & tests'),
    title: _en('Do I need every scan on the list?'),
    teaser: _en("The timeline shows the usual run. It isn't a checklist "
                "you're failing, and it isn't a menu either."),

    scaleSetter: _en("There's a short list of tests almost every pregnancy "
                     "has, a longer list that depends on your history, and a "
                     "few that are your choice. This piece helps you tell "
                     "which is which. Your doctor decides the first group, "
                     "not you and not us."),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),

    sections: [
      PvReadSection(
        // ⚠️ NO HEADING. The opening section runs straight on from the teaser,
        // and the myth block is the first thing under it — see the note above.
        mythFact: PvMythFact(
          myth: _en('The scan timeline is a checklist, and a pregnancy that '
                    'misses one of them has gone wrong somewhere.'),
          fact: _en("It's the usual run, not a rule. Some of those tests are "
                    "offered to everyone, some only when your history or an "
                    "earlier result points to them, and one or two are fully "
                    "optional. A pregnancy with six ticked and three blank "
                    "is an ordinary pregnancy."),
        ),
        paragraphs: [
          _en("The timeline in this app shows nine tests across a pregnancy. "
              "It's drawn as one line because that's how time works, and "
              "that shape can suggest something it shouldn't: that the line "
              "is a target and you're behind on it."),
          _en("It isn't. It shows what a typical pregnancy in India "
              "involves, so you know roughly what's coming and when. Your "
              "own set will be shorter or longer, and either is normal."),
        ],
      ),

      PvReadSection(
        heading: _en('Which tests does almost everyone have?'),
        paragraphs: [
          _en("These are offered in every pregnancy, and there's usually a "
              "good reason to have them. If your doctor has asked for one of "
              "these and you're thinking of skipping it, talk it through "
              "with them rather than deciding alone."),
        ],
        bullets: [
          _en("The first blood panel. Blood group, haemoglobin, thyroid, "
              "sugar and a few infections. It's cheap, it often changes your "
              "care, and it's free at government centres."),
          _en('A dating scan. It sets how many weeks you are, and every '
              'measurement for the rest of the pregnancy is read against '
              'that date. Getting it wrong early makes everything afterwards '
              'harder to read.'),
          _en('The anomaly scan around 20 weeks. The one detailed look at '
              'how your baby has formed. If you have only one scan '
              'privately, most doctors would say make it this one.'),
          _en('The sugar test around 24 to 28 weeks. Pregnancy diabetes is '
              'common in India, usually has no symptoms at all, and is very '
              'treatable once found.'),
        ],
      ),

      PvReadSection(
        heading: _en('Which ones depend on you?'),
        paragraphs: [
          _en('This is where "do I need it" has a real answer, and the '
              'answer comes from your history, not from a list.'),
          _en("Growth scans and Doppler scans in the last three months are "
              "routine with some doctors and kept for particular reasons by "
              "others. They're more clearly useful if your blood pressure is "
              "high, your baby has measured small, you have diabetes, or "
              "you're carrying twins."),
          _en("The Group B Strep swab near the end is standard in some "
              "countries and used selectively in India. It's a quick swab, "
              "and what it changes is whether you're given antibiotics "
              "during labour."),
          _en('Extra thyroid or iron checks, repeat scans after a finding '
              'that needed watching, and extra blood pressure checks all '
              'belong here too. None of them means something is wrong. They '
              'mean somebody is paying attention.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("A repeat scan isn't bad news by itself"),
          body: _en('Babies lie in awkward positions, bladders aren\'t '
                    'always full enough, and some views can\'t be got on the '
                    'day. "Come back next week" is far more often about the '
                    'picture than about your baby.'),
        ),
      ),

      PvReadSection(
        heading: _en('Which ones are your choice?'),
        paragraphs: [
          _en("A few tests are offered rather than ordered, and the decision "
              "is yours. NIPT is the clearest example: a blood test that "
              "screens for a few chromosomal conditions. It's accurate, "
              "expensive, and fully optional."),
          _en("The question to ask yourself about any optional test isn't "
              "whether it's accurate. It's what you'd do with the answer. A "
              "screening result changes what comes next. It can lead to a "
              "further, more certain test, and it helps to think about that "
              "before you start, not after."),
          _en("There's no wrong answer here, and saying no to one isn't "
              "careless. What's worth avoiding is having it done just "
              "because it was in a package, without thinking about it."),
        ],
      ),

      PvReadSection(
        heading: _en('How can you ask about a test?'),
        collapsible: true,
        summary: _en('Four questions that settle almost any test.'),
        bullets: [
          _en('"Is this one you\'re asking for, or one that\'s available?"'),
          _en('"What would it change if the result came back not normal?"'),
          _en('"Is there a simpler or cheaper test that answers the same '
              'question?"'),
          _en('"What happens if I wait two weeks?"'),
        ],
        paragraphs: [
          _en("These aren't rude questions, and no reasonable doctor hears "
              "them that way. They're the questions a doctor asks themselves "
              "before ordering something, and asking them out loud usually "
              "gets you the reasoning, not just the instruction."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Please don't delay these"),
      body: _en("If you have bleeding, one-sided pain low down, fluid "
                "leaking, a bad headache with blurred vision, or your baby "
                "moving much less than usual, it isn't a question of which "
                "scan you need. Call your doctor the same day, whatever the "
                "timeline says."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('I missed the NT scan window. Have I lost something?'),
        answer: _en("Not everything. The NT measurement itself has to be "
                    "taken in a narrow window, but blood screening is "
                    "possible a little later, and the anomaly scan at 20 "
                    "weeks is still ahead of you. Tell your doctor your "
                    "dates and they'll tell you what's still open."),
      ),
      PvReadFaq(
        question: _en("My doctor orders far more scans than my sister's did. "
                      "Is that a problem?"),
        answer: _en('Doctors and cities vary a lot, and more checking isn\'t '
                    'harmful. It\'s fair to ask what each one is for. If the '
                    'answer is about you, that\'s a plan. If it\'s "we do it '
                    'for everyone", that\'s a fair answer too, and now you '
                    'know which it is.'),
      ),
      PvReadFaq(
        question: _en('Can I have the anomaly scan and skip the rest?'),
        answer: _en('You can say no to anything, but skipping the dating '
                    'scan makes the anomaly scan harder to read, because the '
                    'measurements are compared with how many weeks you are. '
                    'The two are more useful together than the second is '
                    'alone.'),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare antenatal care '
                  'guidance · FOGSI good clinical practice recommendations '
                  'on antenatal ultrasound · NICE guideline NG201, antenatal '
                  'care · Sources checked September 2026.'),

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
    // Rewritten 2026-09-29 to docs/PREG-VOICE.md. No clinician has reviewed
    // this piece, so it carries the desk byline and no verified mark.
    reviewed: false,
    shortAnswer: _en(
        "A report is written for your doctor, and one number outside a range is usually noise. Your doctor reads the trend, your dates and your history together. If nothing urgent is happening, let it wait until morning."),
    kicker: _en('Scans & tests'),
    title: _en('Reading a report without panicking'),
    teaser: _en("One reading is one moment. What a range really means, why "
                "labs disagree, and why a single number isn't a verdict."),

    scaleSetter: _en("Most reports that frighten people at 11pm are read as "
                     "reassuring by a doctor at 10am. That isn't the doctor "
                     "being kind. A report is a set of measurements, and "
                     "measurements only mean something next to your history, "
                     "your dates and each other."),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("A scan or blood report is written for your doctor, not for "
              "you. That isn't secrecy. It's like a recipe written for a "
              "cook that leaves out how to boil water. So the language is "
              "short, the tone is flat, and anything unusual is written just "
              "as plainly as anything usual."),
          _en("So a line saying the placenta is low sits in exactly the same "
              "type as a line about your baby's heartbeat, and it can look "
              "as if it carries the same weight. It doesn't. One is a "
              "finding that settles by itself in most pregnancies. The other "
              "is a fact."),
          _en("It helps to read a report twice: once for what it says, and "
              "once for what it doesn't say. Reports are usually longer "
              "about normal things than anything else, because normal has "
              "more parts."),
        ],
      ),

      PvReadSection(
        heading: _en('What does a "normal range" mean?'),
        paragraphs: [
          _en("A reference range isn't the line between healthy and ill. "
              "It's the middle stretch of what was measured in a group of "
              "people the lab thought of as typical, usually the middle "
              "ninety or ninety-five per cent of them."),
          _en("That has a surprising result. If the range holds the middle "
              "ninety-five per cent, then one healthy person in twenty sits "
              "outside it on any given test. Run eight tests on someone "
              "completely well, and it's more likely than not that one comes "
              "back flagged."),
          _en("That's why one value a little outside a range is so rarely "
              "acted on by itself, and why your doctor may just repeat it. A "
              "number that's out on its own is usually noise. A number "
              "that's out, and moving, and matches how you feel, is a "
              "finding."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("An asterisk isn't a diagnosis"),
          body: _en("Lab software flags anything outside its range "
                    "automatically. It doesn't know you're pregnant, which "
                    "trimester you're in, or what your last result was. "
                    "Several values shift in a normal pregnancy and get "
                    "flagged every time."),
        ),
      ),

      PvReadSection(
        heading: _en('Why do two labs give different numbers?'),
        paragraphs: [
          _en("If you've had the same test at two centres and got two "
              "answers, nothing has gone wrong. Different machines, "
              "different methods and different reference groups give "
              "different numbers for the same blood."),
          _en("It matters most for thyroid, for haemoglobin, and for "
              "anything in units you have to squint at. A thyroid result "
              "from one lab can't be compared directly with one from "
              "another, which is why doctors ask you to stay with one lab "
              "through a pregnancy when they're tracking a value."),
          _en("Scans have their own version of this. An estimated fetal "
              "weight is worked out from three or four measurements using a "
              "formula, and centres use different formulas. The real margin "
              "on that estimate is around ten to fifteen per cent either "
              "way. So a baby estimated at 2.5 kilograms could be anywhere "
              "from about 2.1 to 2.9. It's an estimate that looks like a "
              "measurement."),
        ],
        tip: PvReadTip(
          title: _en('Compare like with like'),
          body: _en("When you're tracking something across a pregnancy, use "
                    "the same lab each time if you can, and keep the reports "
                    "together so the trend is easy to see. A trend tells you "
                    "far more than any one reading."),
        ),
      ),

      PvReadSection(
        heading: _en('What should you do with a report tonight?'),
        paragraphs: [
          _en('Four small things, in order.'),
        ],
        bullets: [
          _en("Take a photo of it, so you can't lose it and you have it with "
              "you the next time you speak to someone."),
          _en("Look up the words you don't know, and stop there. "
              "Understanding a word is useful. Searching for what it means "
              "for your baby is where a calm evening ends."),
          _en('Write down the one or two things you want to ask. Writing it '
              'down usually shrinks it from a feeling to a question.'),
          _en("If it isn't urgent, let it wait until morning. Nothing on a "
              "routine report is a decision to make at midnight."),
        ],
      ),

      PvReadSection(
        heading: _en('What if a report does change things?'),
        collapsible: true,
        summary: _en('Some findings do need a plan, and they still need your '
                     'doctor, not a search.'),
        paragraphs: [
          _en("None of this means ignoring a report. Some findings do change "
              "what happens next. A placenta lying over the exit late in "
              "pregnancy changes how you give birth. A high sugar result "
              "changes what you eat and how closely you're watched. A baby "
              "who keeps measuring small changes how often you're seen."),
          _en('What these have in common is that the answer is a plan made '
              'with a person, not a conclusion reached alone. The report is '
              'the start of a conversation. It was never meant to be the end '
              'of one.'),
          _en('If ParentVeda can explain the finding, read the explanation '
              'before your appointment, not instead of it. Walking in with a '
              'clear question is the best use of a fifteen-minute slot.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day if'),
      body: _en("The report itself says to contact your doctor urgently, or "
                "you have bleeding, fluid leaking, a bad headache with "
                "blurred vision or swelling, one-sided pain low down, or "
                "your baby is moving much less than usual. Don't wait for an "
                "appointment to talk about a result if any of these is "
                "happening now."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My report says "cannot be excluded". What does that '
                      'mean?'),
        answer: _en("It's careful wording, not a warning. It means the "
                    "pictures didn't show something but also couldn't "
                    "completely rule it out, often because of your baby's "
                    "position or how clear the view was. It usually leads to "
                    "another look, not to anything more."),
      ),
      PvReadFaq(
        question: _en('Should I get a second opinion on a scan?'),
        answer: _en('For a significant finding on an anomaly scan, a second '
                    'reading by a fetal medicine specialist is reasonable '
                    'and common. For a routine growth scan, repeating it '
                    'elsewhere usually just gives you a second estimate with '
                    'the same margin of error.'),
      ),
      PvReadFaq(
        question: _en('The estimated weight jumped a lot between two scans. '
                      'Is that possible?'),
        answer: _en("Often it's the estimate that jumped, not the baby. With "
                    "a margin of ten to fifteen per cent on each reading, "
                    "two scans a fortnight apart can look like a sharp "
                    "change when growth has been steady. Your doctor reads "
                    "the curve, not the points."),
      ),
      PvReadFaq(
        question: _en('Can I ask the sonographer to explain the report?'),
        answer: _en("You can ask, and sometimes you'll get an answer. In "
                    "many Indian clinics the person scanning isn't the "
                    "person writing the report, and explaining findings "
                    "isn't their job. The doctor who ordered the scan is the "
                    "right person."),
      ),
    ],

    evidence: _en('Royal College of Obstetricians and Gynaecologists patient '
                  'information on ultrasound in pregnancy · ISUOG practice '
                  'guidelines on fetal biometry and estimated weight '
                  'accuracy · IFCC guidance on method-dependent reference '
                  'intervals · Sources checked September 2026.'),

    readNext: ['preg_scan_read_keep', 'preg_scan_read_take_along'],
  ),

  // ===========================================================================
  //  5. What to keep, and why
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_keep',
    hue: _hue,
    // Rewritten 2026-09-29 to docs/PREG-VOICE.md. No clinician has reviewed
    // this piece, so it carries the desk byline and no verified mark.
    reviewed: false,
    shortAnswer: _en(
        "Keep six things: your blood group and Rh status, the dating and anomaly scan reports, any result outside the range with its repeat, your antenatal card, and bills if you'll claim. A clear photo counts. Make sure one other person can find your blood group and due date."),
    kicker: _en('Scans & tests'),
    title: _en('What to keep, and why'),
    teaser: _en('Which papers matter later, how long a lab keeps yours, and '
                'what a photo on your phone is worth.'),

    scaleSetter: _en("You'll collect more paper in nine months than you "
                     "expect, and about six items matter afterwards. Knowing "
                     "which six turns a bag of receipts into a record you "
                     "can hand to someone."),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("The reason to keep things isn't tidiness. At some point in "
              "the next few years, someone will ask you a question you can't "
              "answer from memory. It might be a new doctor in a new city, "
              "an insurance desk, or a paediatrician asking your blood group "
              "and whether you needed an injection for it."),
          _en("The other reason is more immediate. Labs and clinics don't "
              "keep your records as long as you'd think, and a scan centre "
              "you visited once early on may have nothing to give you "
              "eighteen months later. The only copy sure to exist in five "
              "years is yours."),
        ],
      ),

      PvReadSection(
        heading: _en('Which six papers matter most?'),
        paragraphs: [
          _en('If you keep nothing else, keep these.'),
        ],
        bullets: [
          _en("Your blood group and Rh status. It decides whether you need "
              "an anti-D injection, and you'll be asked for it at every "
              "hospital admission for the rest of your life."),
          _en('The dating scan report. It sets your due date, and every '
              'later measurement is read against it.'),
          _en("The anomaly scan report. It's the one detailed look at how "
              "your baby formed, and it's the first thing a specialist asks "
              "for if anything is ever questioned."),
          _en("Any result that was outside the usual range, and the repeat "
              "that followed it. The pair together is what's useful. Either "
              "one alone tells half the story."),
          _en("Your antenatal card or booklet, with the blood pressure, "
              "weight and haemoglobin entries. It's the only running record "
              "of your pregnancy, and it's easy to leave behind at a clinic."),
          _en('Bills and the prescriptions for each test, if you might claim '
              'on insurance. A claim needs the prescription, the bill and '
              'the report, and missing one of the three is the most common '
              'reason claims are refused.'),
        ],
      ),

      PvReadSection(
        heading: _en('Does a photo count?'),
        paragraphs: [
          _en("A clear photo of a report is a real record. Doctors read them "
              "from phones every day, and it's far better than a lost "
              "original."),
          _en("It has to be readable, though, and that's where most phone "
              "copies fall short. Photograph the whole page flat, in "
              "daylight or under a plain ceiling light, without your shadow "
              "across it and without the flash bouncing off glossy paper. "
              "Zoom in and check the small print at the bottom (the date, "
              "the lab name and the reference ranges) is clear, because "
              "that's the part a doctor needs."),
          _en("And you have to be able to find it. Four hundred photos into "
              "a pregnancy, a report saved between two bump pictures is as "
              "good as gone. Keeping them in one place, named, is what turns "
              "a photo into a record, and that's what the report locker in "
              "this app is for."),
        ],
        tip: PvReadTip(
          title: _en('Photograph the films too, not only the report'),
          body: _en("Scan films fade. The heat-sensitive paper the pictures "
                    "are printed on darkens or washes out within a few "
                    "years, sometimes within one, and it can't be recovered. "
                    "Photograph them the week you get them."),
        ),
      ),

      PvReadSection(
        heading: _en('How long should you keep them?'),
        paragraphs: [
          _en('For the six items above, keep them for good. As photos they '
              'take up almost no room, and people ask about them years later.'),
          _en("Routine reports that came back normal and were never followed "
              "up matter much less. Keeping them digitally costs nothing, so "
              "there's no reason to throw them away, and no reason to worry "
              "if one is missing."),
          _en("Bills are the one thing with a real deadline. Most insurers "
              "want a claim filed within a fixed time after treatment, often "
              "weeks rather than months. If you're going to claim, do it "
              "while the pregnancy is still what you're thinking about."),
        ],
      ),

      PvReadSection(
        heading: _en('Who else should have a copy?'),
        collapsible: true,
        summary: _en('At least one other person.'),
        paragraphs: [
          _en("Your partner, your mother, or whoever would be with you in an "
              "emergency should be able to find your blood group and due "
              "date without you. If you're the only person who can open the "
              "folder, the record can't help at the one moment it's there "
              "for."),
          _en("Keep the essentials somewhere that works without a signal "
              "too, like a screenshot in your phone's photos or one printed "
              "page in your bag. In a hospital basement or a village with no "
              "network, a cloud folder is no use at all."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Tell your doctor if you can't find these"),
      body: _en("If your blood group or Rh status isn't written down "
                "anywhere and you're bleeding, or you're being admitted, say "
                "so straight away rather than waiting to be asked. It's a "
                "quick test to repeat, and it changes what you're given."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('How long does a lab keep my report?'),
        answer: _en('It varies a lot, and small centres keep less than big '
                    'chains. Some online portals expire after a year. Assume '
                    'nothing can be found after a couple of years, and treat '
                    'your own copy as the real one.'),
      ),
      PvReadFaq(
        question: _en('Do I need the printed films, or is the report enough?'),
        answer: _en("The report carries the findings, and it's what a doctor "
                    "reads. The films matter if a specialist wants to look "
                    "at the pictures themselves, which happens mainly after "
                    "a finding on the anomaly scan. Keep both if you can, "
                    "and photograph both either way."),
      ),
      PvReadFaq(
        question: _en('Is it safe to keep medical reports in a phone app?'),
        answer: _en('Keep them somewhere you control and can reach without a '
                    'signal. Whatever you use, make sure one other person '
                    'you trust can find your blood group and due date in an '
                    'emergency.'),
      ),
    ],

    evidence: _en('National Health Mission Mother and Child Protection Card '
                  'guidance · Insurance Regulatory and Development Authority '
                  'of India health claim documentation norms · Sources '
                  'checked September 2026.'),

    readNext: ['preg_scan_read_take_along', 'preg_scan_read_calm'],
  ),

  // ===========================================================================
  //  6. Take it to your appointment
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_take_along',
    hue: _hue,
    // Rewritten 2026-09-29 to docs/PREG-VOICE.md. No clinician has reviewed
    // this piece, so it carries the desk byline and no verified mark.
    reviewed: false,
    shortAnswer: _en(
        "Carry your antenatal card, every report since your last visit, your tablets and three written questions. Say the thing that worried you first. Before you leave, repeat back what was decided and ask when you should call."),
    kicker: _en('Scans & tests'),
    title: _en('Take it to your appointment'),
    teaser: _en("What to carry, what to have ready, and how to use ten "
                "minutes with a doctor who's running late."),

    scaleSetter: _en('An antenatal appointment in India often lasts eight or '
                     'ten minutes, and a good part of that can go on finding '
                     'a piece of paper. Five minutes of getting ready the '
                     'night before can double the useful part.'),

    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en("The most common way an appointment gets wasted isn't rudeness "
              "or rushing. It's the first four minutes going on piecing "
              "things together: which lab, which week, what the last "
              "haemoglobin was, whether the tablets were the white ones or "
              "the red ones."),
          _en("None of that is hard to have ready. It's only hard to "
              "remember to have ready, which is why this is a list, not "
              "advice."),
        ],
      ),

      PvReadSection(
        heading: _en('What should you carry?'),
        bullets: [
          _en("Your antenatal card or booklet. It's the most useful thing in "
              "your bag, and the one most often left at home."),
          _en("Every report since your last visit, in date order. If they're "
              "on your phone, have them open before you go in, so you're not "
              "searching in the chair."),
          _en("The strips or boxes of anything you're taking, including "
              "anything bought without a prescription and anything "
              "traditional. The box answers questions a name often can't."),
          _en("Your questions, written down. Three is a good number. With "
              "more than five, the last ones won't get asked."),
          _en('Your blood group, the date of your last period and your due '
              'date, somewhere you can read them out without looking '
              'anything up.'),
          _en("Your blood pressure or sugar readings from home, if you've been "
              'asked to keep them, with the date and time of each one.'),
          _en('Water and a small snack. Waits can be long, and some checks go '
              "better when you've eaten."),
        ],
        paragraphs: [
          _en("If you use the locker in this app, all of that except the "
              "tablets is already in one place, which is a big part of why "
              "it's there."),
        ],
      ),

      PvReadSection(
        heading: _en('What should you have ready to say?'),
        paragraphs: [
          _en('Doctors ask a few questions at almost every antenatal visit, '
              'and answering them exactly, not roughly, changes what they '
              'can do with the answer.'),
          _en("How your baby has been moving in the last two days, not in "
              "general. Whether there has been any bleeding or fluid, even a "
              "little, even once. Whether you've had headaches, swelling in "
              "your face or hands, or changes in your vision. How you're "
              "sleeping and eating. And how you've been feeling in yourself, "
              "which is a real medical question and not small talk."),
          _en("If something has changed and you're not sure it counts, say "
              "it anyway. Deciding what matters is the job you came to hand "
              "over."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Start with what worried you'),
          body: _en('Say the most important thing in the first minute, not '
                    'the last. Appointments get interrupted, cut short and '
                    'reordered, and the question saved for the end is the '
                    'one that gets left out.'),
        ),
      ),

      PvReadSection(
        heading: _en('What should you check before you leave?'),
        paragraphs: [
          _en("Three things are worth checking while you're still sitting "
              "down, because each one is a trip back if it's missed."),
        ],
        bullets: [
          _en('What was decided, said back in your own words. "So I\'m '
              'starting the iron tablets and coming back in four weeks" '
              'takes ten seconds and catches most mix-ups.'),
          _en("What's next and when: the next test, the next visit, and "
              "roughly which week it falls in."),
          _en('What should make you call before then. Every doctor has a '
              'line in mind, and very few say it unless you ask.'),
        ],
      ),

      PvReadSection(
        heading: _en("What if you're seeing someone new?"),
        collapsible: true,
        summary: _en('A new city, a new hospital, or a doctor covering for '
                     'yours.'),
        paragraphs: [
          _en('A doctor meeting you for the first time at thirty weeks is '
              'starting from nothing, and what you carry is the whole '
              'history they have. This is when the dating scan report '
              'matters most, because it tells them how many weeks you are, '
              'whatever you remember.'),
          _en('Bring the whole set, not just the recent ones. A finding at '
              'twenty weeks that settled is still useful to know, and "there '
              'was something about the placenta early on but it moved" is '
              'much less useful than the report that says so.'),
          _en("And say who has been looking after you and where. Most "
              "doctors will just call them, and that's much easier than "
              "piecing it together."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Please don't wait for the appointment if"),
      body: _en('You have bleeding, fluid leaking, a bad headache with '
                'blurred vision or sudden swelling, one-sided pain low down, '
                'fever, or your baby is moving much less than usual. These '
                'are reasons to call now, not to add to a list for Thursday.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Should I take someone with me?'),
        answer: _en("If you can, yes, especially to appointments where a "
                    "result is being discussed. Two people remember about "
                    "twice as much of a conversation, and one of them isn't "
                    "the person hearing the news."),
      ),
      PvReadFaq(
        question: _en('Can I record what the doctor says?'),
        answer: _en("Ask first. Many doctors are fine with it and some "
                    "aren't, and asking takes five seconds. Written notes "
                    "are less awkward and almost as useful."),
      ),
      PvReadFaq(
        question: _en("I forgot to ask something and I'm already home."),
        answer: _en("Most clinics will answer a short question by phone or "
                    "message, and it's a normal thing to do. Write it down "
                    "for next time as well, in case it doesn't get answered."),
      ),
    ],

    evidence: _en('World Health Organization recommendations on antenatal '
                  'care for a positive pregnancy experience · Ministry of '
                  'Health and Family Welfare antenatal care module · Sources '
                  'checked September 2026.'),

    readNext: ['preg_scan_read_keep', 'preg_scan_read_calm'],
  ),
  // ===========================================================================
  //  7. What the scan person can and cannot tell you
  // ---------------------------------------------------------------------------
  //  Added 2026-09-29 (pregnancy gap analysis, Scans & tests, P2): the
  //  coming-soon card on "Before any scan", finished. `content_slots.dart`
  //  declared it for step 2 ("Why they go quiet, why they will not discuss
  //  the sex, and who gives you the result"), and those are its three jobs.
  //
  //  ⚠️ THE SEX IS NAMED ONCE, CALMLY, AND NEVER AS SOMETHING TO WORK AROUND.
  //  PCPNDT: nothing here suggests a way to learn it. The sex-law read carries
  //  the history; this one only says what happens in the room.
  //
  //  ⚠️ AND THE DUE DATE STAYS THE DOCTOR'S. The sonographer measures; if the
  //  measurements suggest a different week, her doctor decides whether the
  //  due date moves. We never recalculate a date her doctor has set.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_scan_person',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('What the scan person can and cannot tell you'),
    teaser: _en("Why they go quiet, what you can ask in the room, and who "
        'gives you the result.'),
    shortAnswer: _en("The person doing your scan can tell you what they're "
        "looking at and whether they got the views they need. They can't tell "
        "anyone the baby's sex, and in most clinics they don't explain "
        'findings. Your doctor gives you the result.'),
    scaleSetter: _en("A quiet sonographer is the normal kind. Most of them "
        "say very little during a scan, to everyone, whatever they're seeing. "
        'The silence is about concentration and about whose job it is to '
        'explain, not about your baby.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("You lie down, the gel goes on, the screen lights up, and the "
              "person holding the probe goes silent. For a few minutes all you "
              "hear is clicking. It's one of the hardest parts of any scan, "
              "and almost every woman feels it."),
          _en("It helps to know who is in the room. In India the scan may be "
              "done by a radiologist (a doctor trained in reading scans), a "
              "gynaecologist who does her own scans, or a trained sonographer "
              "or technician. The person scanning isn't always the person who "
              "writes the report, and they're rarely the doctor looking after "
              "your pregnancy."),
          _en("Each of them has a clear job. Knowing what it is makes the "
              "quiet much easier to sit through."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do they go quiet?'),
        paragraphs: [
          _en("A scan is a set of careful measurements. The person scanning "
              "is finding exact views of your baby's head, tummy and legs, "
              "freezing the picture at the right moment and placing markers "
              "on it. It takes all their attention, and talking at the same "
              "time makes mistakes more likely."),
          _en("They also know their words carry weight. A half-finished "
              "sentence in a scan room can worry a woman for weeks. So many "
              "of them say nothing until they're sure, and some say nothing "
              "at all, because giving results isn't their role."),
          _en("If they go quiet, call a colleague in, or ask you to walk "
              "about and come back, it's almost always about the picture. "
              "Babies turn away, lie curled up or sit low, and a view that "
              "won't come today often comes easily next week."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('A second look is routine'),
          body: _en("Being asked to come back for another try is common, "
              "especially for the anomaly scan. It usually means one view "
              "wasn't clear, not that something was seen."),
        ),
      ),
      PvReadSection(
        heading: _en('What can you ask in the room?'),
        paragraphs: [
          _en("More than you might think. These are fair questions, and most "
              'scan staff are happy to answer them.'),
        ],
        bullets: [
          _en("\"What are you measuring now?\" Many will point things out on "
              'the screen if you ask.'),
          _en('"Did you get all the views you need, or should I come back?"'),
          _en('"Can you show me the heartbeat?"'),
          _en("\"Is my baby lying in a way that makes it harder today?\""),
          _en('"When will the report be ready, and does it go to me or my '
              'doctor?"'),
          _en("\"I know you can't tell me the sex. Is everything else looking "
              "as you'd expect?\""),
        ],
      ),
      PvReadSection(
        heading: _en("What won't they tell you?"),
        paragraphs: [
          _en("The baby's sex, ever. Under the PCPNDT Act, no one in India "
              "may tell anyone the sex of a baby before birth: not the "
              "sonographer, not the radiologist, not your doctor, and not the "
              "report. It's the same for every woman in every clinic, and it "
              "says nothing about your scan. If you'd like to understand why "
              "the law exists, there's a piece on it in this door."),
          _en("A diagnosis. If something needs a closer look, most scan "
              "staff will write it in the report and leave the explaining to "
              "your doctor, who knows your history and your earlier results. "
              "That isn't hiding anything. It's making sure the person who "
              "tells you can also tell you what happens next."),
          _en("A new due date. The report may say how many weeks your baby "
              "measures. If that's different from your dates, your doctor "
              "decides whether anything changes. A due date set from your "
              "dating scan or by your doctor stays yours, and ParentVeda never "
              "recalculates it."),
        ],
      ),
      PvReadSection(
        heading: _en('Who gives you the result?'),
        paragraphs: [
          _en("The doctor who asked for the scan. Sometimes the report is "
              "handed to you the same day, and sometimes it goes straight to "
              "your doctor. Either way, it's written for them, in short "
              "medical words, so it can read more worrying than it is."),
          _en("If you're holding the report before you've seen your doctor, "
              "the result decoder in this door explains the words you'll "
              "meet. Read it for meaning, then take your questions to your "
              "appointment."),
        ],
      ),
      PvReadSection(
        heading: _en('What if they do say something?'),
        collapsible: true,
        summary: _en('A word in the room, and what to do with it.'),
        paragraphs: [
          _en("Sometimes a sonographer says \"the placenta is a bit low\" or "
              "\"your baby is measuring small\" on the way out. Those words "
              "can ring in your head all evening."),
          _en("Write down exactly what was said, and ask when your doctor "
              "will see the report. Most of these findings are common and "
              "are checked again later. If they asked you to see your doctor "
              "today, do that. Otherwise the next step is a normal "
              "appointment, and the words will make much more sense with the "
              "report in front of you both."),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en("The scan team tells you to see your doctor today, or you "
          "have bleeding, fluid leaking, pain low down on one side, or your "
          "baby is moving much less than usual. Don't wait for the report to "
          'reach your doctor first.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Can I take my husband or mother into the scan room?'),
        answer: _en("Usually one person can come in, but it depends on the "
            "clinic and the scan. For an internal scan some clinics ask "
            'partners to wait outside. Ask when you book.'),
      ),
      PvReadFaq(
        question: _en('Can I record the scan on my phone?'),
        answer: _en("Ask first. Many clinics don't allow it, partly because "
            "of the law around scans. Most will give you a printed picture "
            'if you ask.'),
      ),
      PvReadFaq(
        question: _en("The sonographer said nothing at all. Should I worry?"),
        answer: _en("No. Saying nothing is the most common way scans are "
            "done. If anything needed urgent action, you'd be told to see a "
            'doctor straight away.'),
      ),
    ],
    evidence: _en('Pre-Conception and Pre-Natal Diagnostic Techniques Act, '
        '1994 · FOGSI good clinical practice recommendations on antenatal '
        'ultrasound · Indian Radiological and Imaging Association guidance on '
        'obstetric ultrasound reporting · Sources checked September 2026.'),
    readNext: ['preg_scan_read_sex_law', 'preg_scan_read_calm'],
  ),

  // ===========================================================================
  //  8. Your first antenatal visit
  // ---------------------------------------------------------------------------
  //  Added 2026-09-29 (gap analysis, Scans & tests › My scans, P1/P2/P3):
  //  "Prenatal appointments", "Checkups: when, how and why" and "late
  //  pregnancy care" in one read. What is checked, what to carry, and how
  //  visits go from monthly to weekly. Our own words, Indian schedule.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_first_visit',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('Your first antenatal visit, and the ones after'),
    teaser: _en("What's checked, what to carry, and how often you'll be seen "
        'from now until the birth.'),
    shortAnswer: _en("Your first visit is mostly questions, a blood pressure "
        "and weight check, a urine test and a list of blood tests. Carry any "
        "pregnancy report, the date of your last period and your medicines. "
        'After that, visits are usually monthly, then every two weeks, then '
        'weekly near the end.'),
    scaleSetter: _en("You'll see your doctor ten or more times before your "
        "baby comes. Most visits are short and routine, and each one checks "
        'the same few things. Knowing what they are makes every appointment '
        'less of a mystery.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("The first antenatal visit (often called the booking visit) "
              "usually happens between 8 and 12 weeks. If you're unsure of "
              "your dates, have any pain or bleeding, or have a health "
              "condition, go sooner. The national programme asks women to "
              "register within the first 12 weeks, and registering early at "
              "a government centre gets you the free tests and tablets."),
          _en("It's usually the longest visit of the pregnancy, because your "
              "doctor is getting to know you. Expect lots of questions and "
              "some paperwork. It's fine to feel a little overwhelmed. Nobody "
              "expects you to remember everything."),
        ],
      ),
      PvReadSection(
        heading: _en('What will they check at the first visit?'),
        bullets: [
          _en("Questions about you: the first day of your last period, "
              "earlier pregnancies, any illnesses or operations, medicines "
              'you take, and health conditions in your family.'),
          _en('Your height and weight, to track your weight gain from here.'),
          _en('Your blood pressure. This one number is checked at every visit '
              'from now on.'),
          _en('A urine test, for protein, sugar and signs of infection.'),
          _en("A list of blood tests: blood group, haemoglobin, sugar, "
              "thyroid and a few infections. There's a piece in this door on "
              'what each one is for.'),
          _en("A dating scan, if you haven't had one, to confirm your weeks "
              'and set your due date.'),
          _en('Tablets to start or carry on with, usually folic acid, then '
              'iron and calcium, and your first tetanus injection.'),
        ],
        paragraphs: [
          _en("An internal examination isn't routine at the first visit. If "
              "your doctor suggests one, they'll say why, and you can ask for "
              'a woman to be in the room.'),
        ],
      ),
      PvReadSection(
        heading: _en('What should you carry?'),
        bullets: [
          _en('Any pregnancy test result or hCG blood report you already '
              'have.'),
          _en('The date your last period started, written down.'),
          _en("Reports and discharge papers from earlier pregnancies, "
              'miscarriages or operations.'),
          _en("The strips or boxes of every medicine you take, including "
              'anything traditional or bought without a prescription.'),
          _en("An ID card. Government centres usually ask for Aadhaar to "
              'register you and give you a Mother and Child Protection card.'),
          _en('Your questions, written down, and if you can, someone to come '
              'with you.'),
        ],
      ),
      PvReadSection(
        heading: _en("How often will you be seen?"),
        paragraphs: [
          _en("Doctors differ, but a common pattern in India is once a month "
              "until about 28 weeks, every two weeks from 28 to 36 weeks, and "
              "every week from 36 weeks until your baby comes. The national "
              "programme sets at least four visits as the minimum, and most "
              'women have more.'),
          _en("You may be seen more often if you're carrying twins, have high "
              "blood pressure or diabetes, or if something needs watching. "
              "More visits mean more care, not that something is wrong."),
          _en("Near the end, the visits get closer together because more "
              "changes in those weeks. Your blood pressure, your baby's "
              "position and your baby's movements matter more each week, and "
              'your doctor wants to see them often.'),
        ],
      ),
      PvReadSection(
        heading: _en('What happens at the visits in between?'),
        paragraphs: [
          _en("Most routine visits are short, and they check the same things "
              'each time.'),
        ],
        bullets: [
          _en('Your blood pressure and weight.'),
          _en('A urine test for protein and sugar.'),
          _en('Your bump measured with a tape, from about 24 weeks, to follow '
              "your baby's growth."),
          _en("Your baby's heartbeat, heard with a small handheld monitor, "
              'usually from around 12 weeks.'),
          _en('Haemoglobin checked again at some visits, and your tablets '
              'reviewed.'),
          _en("Questions about how you're feeling, how you're sleeping and, "
              "later, how your baby is moving."),
        ],
        tip: PvReadTip(
          title: _en('Keep your card with you'),
          body: _en("Your antenatal card or booklet holds every reading from "
              "every visit. Take it to each appointment, and to hospital if "
              'you ever go in unplanned.'),
        ),
      ),
      PvReadSection(
        heading: _en('Questions worth asking at the first visit'),
        collapsible: true,
        summary: _en('Six that save a lot of confusion later.'),
        bullets: [
          _en('"Which tablets should I take, and for how long?"'),
          _en('"Which tests and scans do you want, and roughly when?"'),
          _en('"Who do I call if something worries me out of hours?"'),
          _en('"Which hospital would I deliver at?"'),
          _en('"Is there anything in my history you want to watch?"'),
          _en('"When should I come back?"'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for your booking visit if"),
      body: _en("You have bleeding, pain low down on one side, pain at the "
          "tip of your shoulder, fever, or vomiting so bad you can't keep "
          'fluids down. Call your doctor or go to hospital the same day.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en("I'm already 14 weeks. Is it too late to book?"),
        answer: _en("No. Book as soon as you can. Your doctor will fit in the "
            "tests and scans that are still useful, and many are done later "
            'anyway.'),
      ),
      PvReadFaq(
        question: _en('Should I see a doctor before my first scan?'),
        answer: _en("Either order is fine. Many doctors see you first and send "
            "you for the dating scan. If you have pain or bleeding, see a "
            'doctor first.'),
      ),
      PvReadFaq(
        question: _en('Can I go to a government centre and a private doctor?'),
        answer: _en("Yes, many women do. Registering at a government centre "
            "gets you the free tests, tablets and vaccines. Just tell each "
            'doctor about the other and carry your reports to both.'),
      ),
    ],
    evidence: _en('Ministry of Health and Family Welfare, antenatal care '
        'guidance and Mother and Child Protection Card · Pradhan Mantri '
        'Surakshit Matritva Abhiyan guidance · World Health Organization '
        'recommendations on antenatal care for a positive pregnancy experience '
        '· Sources checked September 2026.'),
    readNext: ['preg_scan_read_early_bloods', 'preg_scan_read_take_along'],
  ),

  // ===========================================================================
  //  9. hCG and your early blood tests
  // ---------------------------------------------------------------------------
  //  Added 2026-09-29 (gap analysis, Understand a result, P2): many Indian
  //  women are sent for repeat beta hCG and progesterone early and worry over
  //  the numbers. It explains what the tests are for and never judges her own
  //  result: her doctor reads the numbers.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_early_bloods',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('hCG and your early blood tests'),
    teaser: _en("What the hCG number means, why it's repeated after two "
        'days, and what the first blood panel checks.'),
    shortAnswer: _en("hCG is the pregnancy hormone, and one reading tells "
        "very little because healthy levels vary widely. Your doctor may "
        "repeat it after about 48 hours to see the trend. The first blood "
        'panel checks your blood group, haemoglobin, sugar, thyroid and a few '
        'infections.'),
    scaleSetter: _en("Early blood reports are some of the most worrying "
        "papers in a pregnancy, because they come before any scan can "
        "reassure you. Most of the numbers only make sense next to a second "
        'reading or a scan, and your doctor reads them that way.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A home test turns positive because of hCG (human chorionic "
              "gonadotropin), a hormone made by the early placenta. A blood "
              "test (serum beta hCG) measures the same hormone as a number, "
              "in mIU/mL."),
          _en("Your doctor may ask for it to confirm the pregnancy, to date "
              "it roughly before a scan can, or to follow it if there's "
              "bleeding, pain, an earlier loss or an IVF pregnancy. It's a "
              "useful test, and it's easy to read too much into one result."),
        ],
      ),
      PvReadSection(
        heading: _en('What does the hCG number tell you?'),
        paragraphs: [
          _en("Less than it seems to. At the same week, healthy pregnancies "
              "can have hCG levels that are very far apart, so a single "
              "number can't tell you whether things are going well. Charts "
              "online show ranges so wide they're little use for one "
              'person.'),
          _en("What doctors look at is the pattern. In the first weeks the "
              "level usually rises quickly, often roughly doubling every two "
              "to three days. It peaks at around 8 to 11 weeks and then "
              "falls, which is normal. After that, hCG isn't usually "
              'followed at all.'),
          _en("Once a scan shows a baby with a heartbeat in the womb, the "
              "scan tells your doctor far more than hCG can, and the blood "
              'test usually stops.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("Don't compare numbers"),
          body: _en("A friend's hCG, a chart online or a forum post can't be "
              "compared with yours. Different weeks, different labs and "
              "different pregnancies give very different numbers, all of "
              'them healthy.'),
        ),
      ),
      PvReadSection(
        heading: _en('Why is it repeated after 48 hours?'),
        paragraphs: [
          _en("Because two readings show a direction and one doesn't. If "
              "your doctor wants the trend, they'll usually repeat the test "
              "about 48 hours later, at the same lab if possible, since labs "
              'measure a little differently.'),
          _en("They'll read the two numbers with your dates, how you're "
              "feeling and, when it's possible, an early scan. They decide "
              "what the trend means and what happens next. Please don't try "
              'to work it out from a calculator online.'),
          _en("Waiting two days for a second number is hard. It may help to "
              "plan something for those days, and to have one person you can "
              'talk to about it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about progesterone?'),
        paragraphs: [
          _en("Progesterone is a hormone that helps the lining of the womb "
              "hold a pregnancy. Some doctors test it early, especially after "
              'IVF, after an earlier loss, or if there has been bleeding.'),
          _en("Like hCG, the level varies from woman to woman and even "
              "through the day. If your doctor prescribes progesterone "
              "tablets, injections or pessaries, take them exactly as they "
              "say, and don't stop without asking them first."),
        ],
      ),
      PvReadSection(
        heading: _en("What's in the first blood panel?"),
        paragraphs: [
          _en("At your first antenatal visit you'll be sent for a set of "
              "blood and urine tests. Most are free at government centres. "
              'The usual list is:'),
        ],
        bullets: [
          _en('Blood group and Rh type, which decides whether you need an '
              'anti-D injection later.'),
          _en('Haemoglobin and a full blood count, to look for anaemia.'),
          _en('Blood sugar, to catch diabetes early.'),
          _en('Thyroid (TSH), since an underactive thyroid is common and easy '
              'to treat.'),
          _en('HIV, hepatitis B and syphilis (VDRL), which are checked for '
              "every pregnant woman because treatment protects the baby."),
          _en('A urine test for protein, sugar and infection.'),
          _en('Often a thalassaemia screen (HPLC), and sometimes vitamin D, '
              'rubella or hepatitis C, depending on your doctor.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('If the thalassaemia screen shows the trait'),
          body: _en("Carrying the trait is common in India and usually causes "
              "no illness. Your doctor will usually ask for your husband to be "
              "tested too. If only one of you carries it, your baby can't have "
              "the major form. It's a quick blood test, and knowing early "
              'gives you both time to talk it through with your doctor.'),
        ),
      ),
      PvReadSection(
        heading: _en('When a number on the report worries you'),
        collapsible: true,
        summary: _en('What to do between the report and the doctor.'),
        paragraphs: [
          _en("Lab software marks anything outside its range, and it doesn't "
              "know you're pregnant. Several values shift in a healthy "
              'pregnancy and get flagged every time.'),
          _en("Photograph the report, write down your question, and send it "
              "to your doctor or take it to your next visit. If there's "
              "bleeding or pain, don't wait for the appointment. Call the "
              'same day.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en("You have bleeding, pain low down on one side, pain at the "
          "tip of your shoulder, or you feel faint, whatever your hCG number "
          'says. Go to hospital if the pain or bleeding is bad.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en("My hCG is lower than my friend's at the same week. Is "
            'that bad?'),
        answer: _en("Not by itself. Healthy levels at the same week can be "
            "very far apart. Your doctor looks at your trend and your scan, "
            "not a comparison."),
      ),
      PvReadFaq(
        question: _en('Do I need to fast for these tests?'),
        answer: _en("Usually not, unless a fasting sugar test is included. "
            'The lab will tell you when you book.'),
      ),
      PvReadFaq(
        question: _en('Can a home test tell me if hCG is rising?'),
        answer: _en("No. A darker or lighter line isn't a reliable measure. "
            'Only the blood test gives a number your doctor can use.'),
      ),
    ],
    evidence: _en('Royal College of Obstetricians and Gynaecologists guidance '
        'on early pregnancy assessment · NICE guideline NG126, ectopic '
        'pregnancy and miscarriage · Ministry of Health and Family Welfare '
        'antenatal care guidance · Sources checked September 2026.'),
    readNext: ['preg_scan_read_blood_group', 'preg_scan_read_first_visit'],
  ),

  // ===========================================================================
  //  10. Blood group and Rh
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_blood_group',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('Blood group and Rh: what your result means'),
    teaser: _en("What Rh positive and Rh negative mean in pregnancy, and what "
        'the anti-D injection is for.'),
    shortAnswer: _en("Most women in India are Rh positive, and for them this "
        "result changes nothing. If you're Rh negative, your doctor will "
        'check your blood for antibodies and usually offer an anti-D '
        'injection to protect future pregnancies. It\'s routine and well '
        'understood.'),
    scaleSetter: _en("About 5 in every 100 people in India are Rh negative. "
        "It's a normal blood type, not an illness, and the care for it in "
        'pregnancy is simple and well known.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Your blood group has two parts. The letter (A, B, AB or O) and "
              "the Rh type, positive or negative. So a report might say B "
              'positive, or O negative.'),
          _en("It's one of the first tests of your pregnancy, and one of the "
              "few you'll be asked about for the rest of your life. Write it "
              'down somewhere you and your family can find it.'),
          _en('Reports write it in different ways. "B Rh(D) positive", "B +ve" '
              'and "B positive" all mean the same thing.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why does Rh matter in pregnancy?'),
        paragraphs: [
          _en("If you're Rh positive, it doesn't. Your care carries on as "
              'usual.'),
          _en("If you're Rh negative and your baby is Rh positive (which "
              "depends on the father's blood group), a small amount of your "
              "baby's blood can sometimes reach your bloodstream. This can "
              "happen at birth, with bleeding, or after a fall or a blow to "
              'the tummy.'),
          _en("Your body may then make antibodies against Rh positive blood. "
              "They usually don't affect the baby you're carrying. The "
              "concern is a later pregnancy with an Rh positive baby, where "
              "those antibodies could affect the baby's blood. The anti-D "
              'injection is there to stop the antibodies forming at all.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('This is prevented, not just managed'),
          body: _en("Anti-D has been used for decades, and it works very well "
              "when it's given at the right times. Being Rh negative isn't "
              "something you have to fix. It's something your doctor plans "
              'around.'),
        ),
      ),
      PvReadSection(
        heading: _en("What happens if you're Rh negative?"),
        bullets: [
          _en("Your doctor may ask for your husband's blood group. If he's "
              "Rh negative too, the baby will be Rh negative, and your doctor "
              'will tell you what that changes.'),
          _en('A blood test called the indirect Coombs test (ICT) checks '
              'whether you already have antibodies. It is often done early and '
              'again around 28 weeks.'),
          _en('Many doctors give an anti-D injection at about 28 weeks, as a '
              'routine step.'),
          _en("After birth, your baby's blood group is checked. If your baby "
              "is Rh positive, you're given anti-D within 72 hours."),
          _en("Your blood group may be checked again later in pregnancy or "
              "when you're admitted, even if it's already on your card. "
              "That's a routine safety step."),
          _en('Anti-D is also given after bleeding, a miscarriage, an '
              'ectopic pregnancy, a termination, an amniocentesis, a turning '
              'of the baby (ECV) or a blow to the tummy, as your doctor '
              'advises.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does the Coombs test show?'),
        paragraphs: [
          _en("The indirect Coombs test (ICT) looks for Rh antibodies in your "
              "blood. Negative is the result you want. It means you haven't "
              "made antibodies, and anti-D can still do its job. Most Rh "
              'negative women have a negative ICT all through pregnancy.'),
          _en("If antibodies are found, it usually means your body met Rh "
              "positive blood in an earlier pregnancy, a miscarriage or a "
              "transfusion. Your doctor will then measure the level over time "
              "and may send you to a fetal medicine specialist, who can check "
              "your baby with special scans. It's closely watched care, and "
              'many babies do well with it.'),
        ],
      ),
      PvReadSection(
        heading: _en('What about the letter, A, B, AB or O?'),
        paragraphs: [
          _en("The letter matters mostly for transfusions, which is why "
              "hospitals always want to know it. In pregnancy it rarely "
              'changes anything.'),
          _en("If you're group O and your baby is A or B, some babies get "
              "a little more jaundice in the first days. The newborn team "
              "knows to look for it, and it's very treatable. Nothing needs "
              'to be done before birth.'),
        ],
      ),
      PvReadSection(
        heading: _en('Keeping your blood group handy'),
        collapsible: true,
        summary: _en('Why one other person should know it too.'),
        paragraphs: [
          _en("Save a photo of the report in your phone, write it on your "
              "antenatal card, and tell whoever would come with you to "
              "hospital. If you're ever admitted in a hurry, it helps the "
              'team to know it straight away, though they will still check.'),
          _en("If you're Rh negative, keep a note of every anti-D injection "
              "you've had, with the date. Your doctor in any later pregnancy "
              'will want to see it.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("If you're Rh negative, call your doctor within a day if"),
      body: _en("You have any bleeding, a fall or a blow to your tummy, at any "
          "point in pregnancy. You may need anti-D within 72 hours, so don't "
          'wait for your next visit. Go to hospital straight away if the '
          'bleeding is heavy or you have pain.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is the anti-D injection safe for my baby?'),
        answer: _en("Yes. It's been given to pregnant women for decades and is "
            'considered safe. Your doctor will tell you when you need it.'),
      ),
      PvReadFaq(
        question: _en("Does being Rh negative mean I can't have a normal "
            'delivery?'),
        answer: _en("No. Rh type doesn't change how you give birth. It only "
            'changes the blood tests and injections around it.'),
      ),
      PvReadFaq(
        question: _en('I had anti-D in my last pregnancy. Do I need it again?'),
        answer: _en("Usually, yes. Each pregnancy is looked at afresh. Tell "
            'your doctor about the last one and carry the dates if you have '
            'them.'),
      ),
    ],
    evidence: _en('FOGSI good clinical practice recommendations on Rh '
        'negative pregnancy · Royal College of Obstetricians and '
        'Gynaecologists Green-top Guideline 22, anti-D immunoglobulin · '
        'Ministry of Health and Family Welfare antenatal care guidance · '
        'Sources checked September 2026.'),
    readNext: ['preg_scan_read_early_bloods', 'preg_scan_read_keep'],
  ),

  // ===========================================================================
  //  11. Vaccines in pregnancy
  // ---------------------------------------------------------------------------
  //  Added 2026-09-29 (gap analysis, P1 x3): the tetanus shot every Indian
  //  mother gets, whooping cough (Tdap) and flu had one Can I line and no
  //  read. India's schedule, always "as your doctor advises".
  //
  //  ⚠️ THE "no possessive beside a chance word" RULE HOLDS HERE. Vaccines
  //  are easy to describe as lowering "your baby's risk"; the shape test
  //  forbids that sentence, so the protection is described, not scored.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_vaccines',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('Vaccines in pregnancy: tetanus, whooping cough and flu'),
    teaser: _en('Which injections you may be offered, when, and how they '
        'protect your baby in the first months.'),
    shortAnswer: _en("In India every pregnant woman is offered tetanus and "
        "diphtheria (Td) injections. Many doctors also advise one whooping "
        "cough vaccine (Tdap) at 27 to 36 weeks and a flu vaccine. They pass "
        "protection to your baby before birth, and your doctor decides which "
        'you need.'),
    scaleSetter: _en("A newborn can't have most vaccines until 6 weeks old. "
        "Antibodies you make in pregnancy cross the placenta and cover your "
        "baby in those first weeks. That's the main reason pregnancy "
        'vaccines exist.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Vaccines in pregnancy protect two people at once. Your body "
              "makes antibodies, and some of them travel through the placenta "
              "to your baby. When your baby is born, those borrowed "
              'antibodies guard them until their own vaccines start working.'),
          _en("The vaccines used in pregnancy are inactivated, which means "
              "they can't cause the illness they protect against. Your doctor "
              "will tell you which ones to have and when, and it's always "
              'fine to ask why.'),
        ],
      ),
      PvReadSection(
        heading: _en('The tetanus injection (Td)'),
        paragraphs: [
          _en("This is the injection almost every Indian mother is given, and "
              "it's free at government centres. It used to be called TT. Since "
              "2018 the national programme uses Td, which protects against "
              'tetanus and diphtheria together.'),
          _en("In a first pregnancy, or if you've never had it, the usual "
              "plan is two doses: the first early in pregnancy and the second "
              "four weeks later. If you had two doses in a pregnancy within "
              "the last three years, one booster dose is usually enough."),
          _en("Tetanus in newborns used to be a common cause of death in "
              "India. Vaccinating mothers is a big part of why it's now rare."),
        ],
      ),
      PvReadSection(
        heading: _en('The whooping cough vaccine (Tdap)'),
        paragraphs: [
          _en("Whooping cough (pertussis) is a cough illness that can be very "
              "serious in young babies. Tdap protects against tetanus, "
              'diphtheria and whooping cough in one injection.'),
          _en("Indian doctors' guidance (FOGSI) advises one dose of Tdap in "
              "every pregnancy, between 27 and 36 weeks, so the antibodies are "
              "at their highest when your baby is born. It's usually "
              "available privately rather than free. Your doctor may give it "
              'in place of one of the Td doses.'),
          _en("It's given in every pregnancy, even if you had it last time, "
              "because the antibodies fade and each baby needs their own "
              'supply.'),
        ],
        tip: PvReadTip(
          title: _en('Ask at your 24 to 28 week visit'),
          body: _en("That's a good time to ask whether your doctor wants you "
              "to have Tdap, and where to get it, so it fits into the 27 to "
              '36 week window.'),
        ),
      ),
      PvReadSection(
        heading: _en('The flu vaccine'),
        paragraphs: [
          _en("Flu can hit harder in pregnancy, because pregnancy changes "
              "your breathing, your heart and your immune system. An "
              "inactivated flu vaccine can be given in any trimester, and "
              "FOGSI advises it, especially before the flu season in your "
              'area.'),
          _en("It also protects your baby for the first months, when they're "
              "too young for a flu vaccine of their own. Ask your doctor "
              'whether and when to have it.'),
          _en('In much of India flu peaks in the monsoon and again in winter, '
              'so your doctor may time it to your area.'),
        ],
      ),
      PvReadSection(
        heading: _en("What's normal after an injection?"),
        paragraphs: [
          _en("A sore, slightly swollen arm for a day or two is the most "
              "common reaction. Some women feel tired or have a mild "
              "temperature. Paracetamol is usually fine if your doctor has "
              'said so before.'),
          _en("Vaccines with live virus, such as MMR (measles, mumps and "
              "rubella) and chickenpox, aren't given in pregnancy. If you had "
              "one before you knew you were pregnant, tell your doctor, who "
              'will advise you.'),
          _en("If you've reacted badly to a vaccine before, or you have a "
              "severe allergy, tell your doctor before the injection. They'll "
              'decide which vaccines suit you and where you should have them.'),
        ],
      ),
      PvReadSection(
        heading: _en('Where can you get them, and how do you keep a record?'),
        paragraphs: [
          _en("Td is free at government hospitals, primary health centres and "
              "village immunisation days, and most private clinics give it "
              "too. Tdap and the flu vaccine are usually given at a private "
              "clinic or hospital, or bought from a chemist on your doctor's "
              'prescription. Ask your doctor to write down the exact name.'),
          _en("Write the date and name of each vaccine on your antenatal card, "
              "or photograph the label with the date. Your baby's "
              "paediatrician may ask, and in your next pregnancy your doctor "
              'will want to know which tetanus doses you had and when.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Get help straight away if'),
      body: _en("After any injection you have swelling of your face, lips or "
          "throat, trouble breathing, or feel faint. Tell the staff at once, "
          'or go to the nearest hospital. Call your doctor the same day for a '
          'fever above 38°C that lasts more than a day.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Are these vaccines safe for my baby?'),
        answer: _en("Td, Tdap and the flu vaccine have been given to millions "
            "of pregnant women and are recommended in pregnancy by Indian and "
            'international guidance. Your doctor will check what suits you.'),
      ),
      PvReadFaq(
        question: _en("I missed the 27 to 36 week window for Tdap. Can I still "
            'have it?'),
        answer: _en("Ask your doctor. It can still be given later in "
            "pregnancy, though it may give your baby less protection at "
            'birth.'),
      ),
      PvReadFaq(
        question: _en('Should my family be vaccinated too?'),
        answer: _en("It helps. Whooping cough often reaches babies from older "
            "children and adults at home, so ask your doctor whether others "
            'in the house should have a booster.'),
      ),
    ],
    evidence: _en('Ministry of Health and Family Welfare, Universal '
        'Immunization Programme (Td in pregnancy, 2018) · FOGSI '
        'recommendations on immunisation in pregnancy · World Health '
        'Organization position papers on pertussis and influenza vaccines · '
        'Sources checked September 2026.'),
    readNext: ['preg_scan_read_first_visit', 'preg_scan_read_take_along'],
  ),

  // ===========================================================================
  //  12. NST and fetal monitoring
  // ---------------------------------------------------------------------------
  //  Added 2026-09-29 (gap analysis, Understand a scan, P2): often called an
  //  NST or CTG in India, common after 36 weeks, and not in our nine.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_nst',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('NST and fetal monitoring (CTG)'),
    teaser: _en("What the belts on your bump are recording, why you might be "
        'sent for one, and what reactive means.'),
    shortAnswer: _en("An NST (often called a CTG in India) records your "
        "baby's heartbeat and any tightenings for about 20 to 40 minutes. It "
        "doesn't hurt. \"Reactive\" is the reassuring result, and a baby who "
        'is asleep can make it take longer.'),
    scaleSetter: _en("An NST is one of the most common checks in the last "
        "weeks of pregnancy. Being sent for one usually means your doctor "
        'wants a closer look, not that something is wrong.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("NST stands for non-stress test. The name only means that "
              "nothing is done to your baby: the machine listens and records. "
              "In India the machine and its paper printout are often called a "
              'CTG (cardiotocograph).'),
          _en("It's usually done in the last weeks of pregnancy, most often "
              "from about 36 weeks, and sometimes earlier if your doctor "
              'wants to keep a closer eye on your baby.'),
          _en("It's quiet and still, and many women say it's the first time "
              "they've listened to their baby's heartbeat for that long. It's "
              'usually done in the clinic or on the labour ward, on a bed or a '
              'reclining chair.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why might you be sent for one?'),
        bullets: [
          _en('You feel your baby moving less than usual.'),
          _en("You're past your due date."),
          _en('You have high blood pressure or diabetes in pregnancy.'),
          _en("Your baby is measuring small, or there's less fluid than "
              'usual.'),
          _en("You're carrying twins, or your doctor wants a routine check "
              'near the end.'),
          _en("You've had some bleeding, a fall or a blow to your tummy later "
              'in pregnancy.'),
        ],
        paragraphs: [
          _en("Many doctors in India do an NST at every visit after 36 or 37 "
              "weeks. That's a routine habit, not a sign of concern."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens during it?'),
        paragraphs: [
          _en("You lie back or sit tilted slightly to your left. Two soft "
              "belts go around your bump. One holds a small sensor that "
              "picks up your baby's heartbeat, and the other records any "
              'tightening of your womb.'),
          _en("You may be given a button to press each time you feel your "
              "baby move. The machine draws two lines on a paper strip, and "
              'you can usually hear the heartbeat the whole time.'),
          _en("It takes about 20 minutes, sometimes 40. Eat something before "
              "you go, empty your bladder, and wear clothes that open easily "
              'at the tummy.'),
        ],
      ),
      PvReadSection(
        heading: _en("What's a normal heart rate on the trace?"),
        paragraphs: [
          _en("Your baby's heart beats much faster than yours, usually between "
              "110 and 160 beats a minute. The line goes up and down all the "
              "time, and that wobble is a good sign. It shows your baby's "
              'nervous system is responding.'),
          _en("The second line shows your womb. Small waves are common, and "
              "many of them you won't feel. Your doctor reads the two lines "
              'together.'),
        ],
        tip: PvReadTip(
          title: _en("Lie tilted, not flat"),
          body: _en("Lying flat on your back late in pregnancy can make you "
              "feel faint. Ask for a pillow under one side, and tell the staff "
              "if you're uncomfortable. You can usually sit up."),
        ),
      ),
      PvReadSection(
        heading: _en('What do reactive and non-reactive mean?'),
        paragraphs: [
          _en("\"Reactive\" means your baby's heart rate went up for a short "
              "while when they moved, a set number of times in the time "
              "recorded. It's the reassuring result, and it's what most tests "
              'show.'),
          _en("\"Non-reactive\" means those rises didn't show up during the "
              "test. By far the most common reason is that your baby was "
              "asleep. Babies sleep in stretches of 20 to 40 minutes, so the "
              "staff may carry on longer, ask you to eat or drink something, "
              'or gently move your bump to wake them.'),
          _en("If the trace is still unclear, your doctor may ask for a "
              "biophysical profile or a Doppler scan to get a fuller picture. "
              "They read the whole trace, not one line of it, and they'll "
              'tell you what happens next.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Your baby sleeps too'),
          body: _en("A quiet stretch on the trace very often means a sleeping "
              "baby. The staff know this, and a longer test isn't a sign that "
              'they\'re worried.'),
        ),
      ),
      PvReadSection(
        heading: _en('Monitoring during labour'),
        collapsible: true,
        summary: _en('The same machine, used in a different way.'),
        paragraphs: [
          _en("In labour your baby's heartbeat is checked regularly. It may "
              "be with a handheld monitor every so often, or with the CTG "
              'belts on for longer stretches.'),
          _en("Continuous monitoring is more common if you're being induced, "
              "have an epidural, or have a condition your doctor is watching. "
              "You can usually still change position. Ask the staff to help "
              'you move the belts.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en("Don't wait for a booked NST if"),
      body: _en("Your baby is moving much less than usual, or the pattern "
          "has changed. Call your doctor or go to the labour ward the same "
          'day. A check is quick, and nobody will mind you coming in.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Is an NST safe for my baby?'),
        answer: _en("Yes. It only listens to the heartbeat and records "
            'tightenings. Nothing is sent into your body.'),
      ),
      PvReadFaq(
        question: _en('Will I get the result straight away?'),
        answer: _en("Usually, yes. Your doctor or the labour ward staff read "
            'the paper strip as soon as the test is done.'),
      ),
      PvReadFaq(
        question: _en('Is an NST the same as a Doppler scan?'),
        answer: _en("No. An NST records the heartbeat over time. A Doppler "
            "scan looks at blood flow in the cord and the baby's vessels. "
            'Your doctor may ask for both.'),
      ),
    ],
    evidence: _en('FOGSI good clinical practice recommendations on antenatal '
        'fetal surveillance · American College of Obstetricians and '
        'Gynecologists practice bulletin on antepartum fetal surveillance · '
        'NICE guideline NG229, fetal monitoring in labour · Sources checked '
        'September 2026.'),
    readNext: ['preg_scan_read_bpp', 'preg_scan_read_calm'],
  ),

  // ===========================================================================
  //  13. Biophysical profile
  // ---------------------------------------------------------------------------
  //  Added 2026-09-29 (gap analysis, Understand a scan, P2): ordered late in
  //  pregnancy in India, often past the due date, and missing from our nine.
  //  ⚠️ The score is explained, never read for her. Her doctor decides.
  // ===========================================================================
  PvRead(
    id: 'preg_scan_read_bpp',
    hue: _hue,
    reviewed: false,
    kicker: _en('Scans & tests'),
    title: _en('Biophysical profile (BPP)'),
    teaser: _en("A late-pregnancy check that scores your baby's breathing, "
        'movement, tone and fluid. What the score out of 10 means.'),
    shortAnswer: _en("A biophysical profile is a scan, usually with an NST, "
        "that looks at five signs of how your baby is doing in the last "
        "weeks. Each scores 0 or 2, for a total out of 10. A score of 8 or 10 "
        'is reassuring, and your doctor explains any other score.'),
    scaleSetter: _en("A BPP is usually ordered to check on a baby, not "
        "because something has been found. It's common when you're past "
        'your due date, and most results are reassuring.'),
    author: _en('ParentVeda editorial'),
    authorRole: _en('Scans & tests'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A biophysical profile (BPP) looks at the things a healthy, "
              "well-fed baby does: breathing movements, moving about, "
              "stretching and curling, and making enough urine to keep the "
              'fluid topped up.'),
          _en("It's done in the last weeks, often from about 32 weeks, when "
              "your doctor wants more than a heartbeat check. It adds up "
              'several small signs into one picture. Some reports call it a '
              'fetal wellbeing scan.'),
          _en('With the NST it usually takes 30 to 60 minutes, and the result '
              'is often ready before you leave.'),
        ],
      ),
      PvReadSection(
        heading: _en('Why might you have one?'),
        bullets: [
          _en("You're past your due date."),
          _en('You feel your baby moving less than usual.'),
          _en('An NST was unclear.'),
          _en('You have diabetes or high blood pressure in pregnancy.'),
          _en("Your baby is measuring small, or there's less fluid than "
              'usual.'),
          _en("You're carrying twins, or a past pregnancy had problems late "
              'on and your doctor wants a closer eye this time.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does it look at?'),
        paragraphs: [
          _en("Four things are watched on an ordinary scan for up to 30 "
              "minutes, and the fifth is an NST. Each one scores 2 if it's "
              'seen and 0 if it isn\'t.'),
        ],
        bullets: [
          _en('Breathing movements: your baby practising breathing, with the '
              'chest moving.'),
          _en('Body movements: rolling, kicking or stretching.'),
          _en('Tone: an arm or leg stretching out and curling back.'),
          _en('Fluid: enough amniotic fluid around your baby.'),
          _en("Heart rate (the NST): your baby's heart rate rising when they "
              'move.'),
        ],
        tip: PvReadTip(
          title: _en('Eat before you go'),
          body: _en("Babies are often livelier after you've eaten. Have a "
              'normal meal or a snack beforehand unless you\'re told not to.'),
        ),
      ),
      PvReadSection(
        heading: _en('Why these five signs?'),
        paragraphs: [
          _en("Each sign depends on your baby getting enough oxygen, and each "
              "one appears at a different stage of growth. Tone comes first, "
              "then movement, then breathing movements, and the heart rate "
              'rising with movement comes last.'),
          _en("When a baby is short of oxygen, the signs that came last tend "
              "to stop first. Fluid changes more slowly, over days, as the "
              "kidneys make less urine. That's why the test looks at several "
              "together. One missing sign during a nap means little. A "
              'pattern gives your doctor a clearer picture.'),
          _en("Your baby is watched without being disturbed. If they're "
              "asleep, the sonographer waits, and may ask you to change "
              'position or have a drink.'),
        ],
      ),
      PvReadSection(
        heading: _en('What does the score mean?'),
        paragraphs: [
          _en("The scores are added up to a total out of 10, and the report "
              "writes it as, for example, 8/10, often with the fluid "
              "measurement beside it. A score of 8 or "
              "10 is reassuring, and it's what most babies get. Sometimes the "
              "NST part is left out when everything on the scan is normal, "
              'and the result is given as 8 out of 8.'),
          _en("A score of 6 is usually called borderline. The most common "
              "reason is a sleeping baby. Your doctor may repeat the test "
              "later that day or the next day, or look at how many weeks you "
              'are before deciding the next step.'),
          _en("A lower score means your doctor will look again at the plan "
              "straight away, and near your due date that may mean talking "
              "about delivery. Low fluid on its own also gets extra "
              "attention, whatever the total. Your doctor reads the score "
              'with everything else they know about you.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Some centres do a shorter version"),
          body: _en("A \"modified BPP\" is an NST plus a fluid measurement. It "
              "answers the same question more quickly, and many Indian "
              'hospitals use it.'),
        ),
      ),
      PvReadSection(
        heading: _en('If you have more than one'),
        collapsible: true,
        summary: _en('Twice a week near the end is common.'),
        paragraphs: [
          _en("If you're past your due date or your doctor is watching "
              "something, you may have a BPP or NST once or twice a week "
              "until your baby comes. Each one is a fresh check, and a good "
              'result is good for a few days.'),
          _en("Keep counting your baby's movements between checks. A "
              "reassuring BPP on Monday doesn't replace calling on Wednesday "
              'if your baby goes quiet.'),
        ],
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en("Your baby is moving much less than usual, you have fluid "
          "leaking, bleeding, or a bad headache with blurred vision. Don't "
          'wait for your next booked check.'),
    ),
    faqs: [
      PvReadFaq(
        question: _en('Does a BPP hurt?'),
        answer: _en("No. It's an ordinary scan on your tummy, plus the NST "
            'belts if that part is included.'),
      ),
      PvReadFaq(
        question: _en('My score was 6. Should I be worried?'),
        answer: _en("A 6 is most often a sleepy baby. Your doctor will tell "
            "you whether to repeat it and when. Follow their plan, and call "
            'if your baby moves less in the meantime.'),
      ),
      PvReadFaq(
        question: _en('Is a BPP the same as a growth scan?'),
        answer: _en("No. A growth scan measures size. A BPP watches what "
            'your baby is doing. They are sometimes done on the same day.'),
      ),
    ],
    evidence: _en('American College of Obstetricians and Gynecologists '
        'practice bulletin on antepartum fetal surveillance · FOGSI good '
        'clinical practice recommendations on antenatal fetal surveillance · '
        'Manning biophysical profile scoring · Sources checked September '
        '2026.'),
    readNext: ['preg_scan_read_nst', 'preg_scan_read_calm'],
  ),
];
