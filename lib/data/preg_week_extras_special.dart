// Weeks 1 to 3, 41 and 42. See preg_week_extras.dart.
//
// weekContent.json runs 4 to 40, so a woman told she is two weeks pregnant,
// or one who goes past her date, found nothing. These three pages fill those
// weeks (pregnancy gap analysis, "Week by week", weeks 1 to 3, 41 and 42).
// Written 2026-09-29 to docs/PREG-VOICE.md. English only. New content, so
// no reviewer is claimed; the clinical lines are owed a doctor's read before
// launch (see the report for this pass).
import 'preg_week_extras.dart';

const List<PregSpecialWeekPage> kPregSpecialWeeks = [
  // ---------------------------------------------------------------------------
  // Weeks 1 to 3
  // ---------------------------------------------------------------------------
  PregSpecialWeekPage(
    id: 'weeks_1_3',
    weeks: [1, 2, 3],
    chipLabel: '1 to 3 weeks',
    title: 'How your weeks are counted',
    shortAnswer:
        "Pregnancy is counted from the first day of your last period, so in "
        "weeks 1 and 2 you weren't pregnant yet. Conception usually happens "
        "around the end of week 2, and the pregnancy settles into your womb "
        "(implantation) around week 3. If your doctor gave you a date from a "
        "scan, that's the one ParentVeda follows.",
    sections: [
      PregWeekSection(
        heading: 'Why are my weeks counted from my last period?',
        paragraphs: [
          "Very few people know the exact day they conceived. Almost everyone "
              "knows the day their last period started. So doctors all over "
              "the world count from that day, and ParentVeda does the same.",
          "This is why the count runs about two weeks ahead of conception. "
              "If you conceived four weeks ago, your doctor will say you're "
              "about six weeks pregnant. Nothing is wrong with your dates. "
              "It's only the way the counting works.",
        ],
      ),
      PregWeekSection(
        heading: 'What happens in weeks 1, 2 and 3?',
        paragraphs: [
          "Week 1 is your period. Your body is shedding last month's lining "
              "and starting to ready a new one.",
          "In week 2, an egg ripens and is released from an ovary "
              "(ovulation). In a 28-day cycle this is around day 14. If "
              "sperm meets the egg in the tube, it's fertilised. That's "
              "conception.",
          "In week 3, the fertilised egg travels down the tube, dividing as "
              "it goes, and settles into the lining of your womb "
              "(implantation). Once it's settled, it starts making the "
              "pregnancy hormone hCG. The level rises day by day, and that's "
              "what a pregnancy test picks up, usually from around the time "
              "your period is due.",
          "Some women notice a little light pink or brown spotting around "
              "implantation. Many notice nothing at all. Either is normal. "
              "Heavy bleeding, or bleeding with pain, is different: call "
              "your doctor.",
        ],
      ),
      PregWeekSection(
        heading: 'Why might my due date change after a scan?',
        paragraphs: [
          "A due date worked out from your last period is an estimate. Cycles "
              "vary, and not everyone ovulates on day 14. An early scan that "
              "measures your baby is a more exact way to date a pregnancy, so "
              "your doctor may move your date after this dating scan.",
          "When your doctor gives you a date, that's your date. ParentVeda "
              "follows it, and we never recalculate a date your doctor set. "
              "If your date changes, put the new one into ParentVeda and your "
              "weeks will follow it.",
        ],
      ),
      PregWeekSection(
        heading: 'How many months is 40 weeks?',
        paragraphs: [
          "Forty weeks is about 9 months and a week or so. That's why people "
              "say nine months, and why the count can feel a little long at "
              "the end.",
          "ParentVeda counts months the way Indian doctors and families do. "
              "Weeks 1 to 4 are your first month, and from week 36 you're in "
              "your ninth.",
        ],
      ),
      PregWeekSection(
        heading: "I've just found out. What should I do first?",
        bullets: [
          "Take a folic acid tablet every day. The usual dose is 400 mcg, "
              "unless your doctor prescribes a different one.",
          "Book your first visit with a doctor, and register your pregnancy "
              "at your hospital or health centre within the first 12 weeks.",
          "Tell your doctor about every medicine you take, including "
              "ayurvedic and home remedies. Don't stop a prescribed medicine "
              "on your own; ask first.",
          "Stay away from alcohol, smoking and tobacco.",
        ],
      ),
    ],
    callYourDoctor:
        "Call your doctor straight away, or go to hospital, if you have heavy "
        "bleeding, strong pain on one side of your tummy, pain at the tip of "
        "your shoulder, or you faint or feel faint.",
    asked: [
      PregWeekQuestion(
        q: 'Am I pregnant at 2 weeks?',
        a: "Not yet. Weeks 1 and 2 are counted from your last period, before "
            "conception. They're part of the count so every pregnancy is "
            "measured from the same starting point.",
      ),
      PregWeekQuestion(
        q: 'Why does the test say 4 weeks when I only just conceived?',
        a: "Because the weeks start from your last period, about two weeks "
            "before conception. So two weeks after conceiving, you're counted "
            "as four weeks pregnant. Your doctor counts it the same way.",
      ),
      PregWeekQuestion(
        q: 'When can I take a pregnancy test?',
        a: "Most home tests pick up hCG from around the day your period is "
            "due. If it's negative and your period still hasn't come, try "
            "again in a few days, using your first urine of the morning.",
      ),
    ],
    sources: ['mohfw_anc', 'who_anc', 'acog_month', 'moore_embryology'],
  ),

  // ---------------------------------------------------------------------------
  // Week 41
  // ---------------------------------------------------------------------------
  PregSpecialWeekPage(
    id: 'week_41',
    weeks: [41],
    chipLabel: '41 weeks',
    title: 'One week past your due date',
    shortAnswer:
        "Going past your due date is common. Only a few babies arrive on the "
        "day itself. From now on your doctor will check on you and your baby "
        "more often.",
    sections: [
      PregWeekSection(
        heading: 'Why is my baby late?',
        paragraphs: [
          "Your due date was always an estimate. A full-term baby can come "
              "any time from 37 to 42 weeks, and first babies often come "
              "after the date.",
          "Nobody knows exactly what starts labour. Going past your date "
              "isn't something you did or didn't do.",
        ],
      ),
      PregWeekSection(
        heading: 'What will my doctor check?',
        paragraphs: [
          "Your doctor will want to see you more often now. The checks are "
              "to make sure your baby is still doing well inside.",
        ],
        bullets: [
          "A trace of your baby's heartbeat "
              "(non-stress test, NST, or CTG).",
          "A scan to check the fluid around your baby.",
          "Your blood pressure, and often your urine.",
        ],
      ),
      PregWeekSection(
        heading: 'What might my doctor offer?',
        paragraphs: [
          "Your doctor may offer a membrane sweep. During an internal "
              "check, they gently sweep a finger around the neck of the womb. "
              "This can help labour start on its own. It can be "
              "uncomfortable, and a little spotting afterwards is common.",
          "Your doctor may also talk to you about starting labour with "
              "medicine or other methods (induction). Your doctor will talk "
              "you through the timing. There's more in Labour prep, under "
              "Induction.",
          "The decision is yours, made with your doctor. Ask why they "
              "suggest it, what will happen, and what the choices are if you "
              "would rather wait.",
        ],
      ),
      PregWeekSection(
        heading: 'Should I keep counting movements?',
        paragraphs: [
          "Yes. Babies don't move less as the due date passes. They may "
              "move differently as space gets tight, but you should still "
              "feel your baby's usual pattern every day.",
          "If the movements slow down or change, call your doctor the same "
              "day, day or night. Don't wait until tomorrow, and don't rely "
              "on a home heartbeat monitor to check.",
        ],
      ),
      PregWeekSection(
        heading: 'Everyone keeps asking. What do I say?',
        paragraphs: [
          "The daily calls and messages come from love, but they can wear "
              "you down. It's fine to pick one person to update the family "
              "and keep your phone on silent for a while.",
          "A gentle line helps: \"The baby is well, the doctor is checking "
              "us often, and we'll tell you as soon as there's news.\"",
        ],
      ),
    ],
    callYourDoctor:
        "Call your doctor the same day, day or night, if your baby's "
        "movements slow down or change. Call straight away, or go to "
        "hospital, if you have any bleeding, your waters break (especially "
        "if the water is green or brown), constant pain that doesn't ease "
        "between contractions, a severe headache, or blurred vision.",
    asked: [
      PregWeekQuestion(
        q: 'Does going past my due date mean something is wrong?',
        a: "No. Many babies come after their date, especially first babies. "
            "The extra checks are there to make sure all is still well, not "
            "because something is expected to go wrong.",
      ),
      PregWeekQuestion(
        q: 'Can I try something at home to bring on labour?',
        a: "Please check with your doctor before trying anything, including "
            "castor oil or herbal mixes. Gentle walks are fine if your doctor "
            "is happy with them. There's more in Labour prep, under Past your "
            "due date.",
      ),
    ],
    sources: ['nice_ng207', 'who_intrapartum', 'rcog_rfm', 'mohfw_anc'],
  ),

  // ---------------------------------------------------------------------------
  // Week 42
  // ---------------------------------------------------------------------------
  PregSpecialWeekPage(
    id: 'week_42',
    weeks: [42],
    chipLabel: '42 weeks',
    title: 'Two weeks past your due date',
    shortAnswer:
        "By now most doctors will have planned with you how and when your "
        "baby will be born, often by starting labour (induction). If you "
        "haven't talked about this with your doctor yet, call them today.",
    sections: [
      PregWeekSection(
        heading: "Why don't doctors wait beyond 42 weeks?",
        paragraphs: [
          "Your placenta has been feeding your baby for many months. After "
              "about 42 weeks it may not work as well for some babies, and "
              "doctors can't always tell in advance which ones.",
          "So most doctors prefer to plan the birth around this time rather "
              "than wait longer. It's a careful step, and it doesn't mean "
              "anything is wrong with you or your baby.",
        ],
      ),
      PregWeekSection(
        heading: 'What does induction involve?',
        paragraphs: [
          "Induction means your doctor helps labour to start. It usually "
              "happens in steps, and your baby's heartbeat is watched along "
              "the way.",
        ],
        bullets: [
          "First, softening and opening the neck of the womb, with a tablet, "
              "a gel or a small balloon.",
          "Then, if needed, breaking your waters.",
          "Then, if needed, a drip of medicine to bring on contractions.",
        ],
      ),
      PregWeekSection(
        heading: 'What does induction feel like, and how long does it take?',
        paragraphs: [
          "It can take a while, sometimes a day or more before labour gets "
              "going, so bring things to pass the time. Ask your doctor about "
              "pain relief before you need it.",
          "There's more in Labour prep, under Induction.",
        ],
      ),
      PregWeekSection(
        heading: 'What should I keep in my hand?',
        paragraphs: [
          "Your hospital bag can stay in the car. Keep these in your "
              "handbag so they're with you at the front desk:",
        ],
        bullets: [
          "Your pregnancy file with all your reports and scans.",
          "Your ID, Aadhaar card, and health insurance card if you have one.",
          "A list of any medicines you take.",
          "Your phone, charger and some cash.",
          "Water and a small snack, in case there's a wait.",
        ],
      ),
      PregWeekSection(
        heading: 'Should I keep counting movements?',
        paragraphs: [
          "Yes, every day, right up to the birth. Your baby should keep to "
              "their usual pattern.",
          "If the movements slow down or change, call your doctor the same "
              "day, day or night. Don't wait until tomorrow.",
        ],
      ),
    ],
    callYourDoctor:
        "Call your doctor the same day, day or night, if your baby's "
        "movements slow down or change. Call straight away, or go to "
        "hospital, if you have any bleeding, your waters break (especially "
        "if the water is green or brown), constant pain that doesn't ease "
        "between contractions, a severe headache, or blurred vision.",
    asked: [
      PregWeekQuestion(
        q: 'Can I choose to wait longer?',
        a: "Some women ask to. If you'd like to wait, talk it through with "
            "your doctor. They may suggest closer checks on you and your "
            "baby while you wait. The decision is yours, made with your "
            "doctor.",
      ),
    ],
    sources: ['nice_ng207', 'who_intrapartum', 'rcog_rfm', 'mohfw_anc'],
  ),
];
