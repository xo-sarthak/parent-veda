// =============================================================================
//  Complications & conditions — the reads for this door
// -----------------------------------------------------------------------------
//  Six pieces. Three sit on the safety tab and three on "living with it".
//
//  ---------------------------------------------------------------------------
//  ⚠️ FOUR OF THESE ARE MARKED `reslot` IN THE BRIEF AND ARE NEW WORK
//  ---------------------------------------------------------------------------
//
//  The brief moves "When blood pressure gets dangerous", "Handling pregnancy
//  sugar in India", "The daily thyroid tablet" and "Iron, from food and
//  tablets" out of their condition pages as `[Guide] reslot`. Walking the code
//  first — the playbook's step zero — found that none of them exists at that
//  depth:
//
//    · `ConditionEntry.management` is ONE `LocalizedText` paragraph of about
//      forty words. That is the whole of "how it is managed in India" for
//      gestational diabetes, for thyroid and for anaemia.
//    · "When blood pressure gets dangerous" is `high_bp.callNow` — four bullet
//      lines.
//
//  A Guide chip promises a thing you act on. Opening a forty-word paragraph
//  from one is the chip lying about length, which is the exact failure the
//  format system exists to prevent — and there is already a test enforcing it
//  for myth cards. So these are written properly, to the same floor as
//  everything else: four sections, six hundred words, an FAQ, named sources and
//  an urgent when-to-see-someone.
//
//  ⚠️ THE PARAGRAPHS THEY GREW FROM STAY EXACTLY WHERE THEY ARE. The condition
//  pages are not edited — the brief forbids it and it would be wrong anyway:
//  somebody reading the gestational diabetes page still wants a short answer
//  about management in place. These are the longer answer, one tap away, for
//  the woman who is living with it rather than meeting it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE CLINICAL LINE ON THE THREE SAFETY PIECES
//  ---------------------------------------------------------------------------
//
//  Bleeding, reduced movement and rising blood pressure are the three things in
//  pregnancy where a delay costs most, and they are therefore the three where
//  it is most tempting to write a threshold. These do not.
//
//  · **No number decides anything here.** Where figures appear they are what a
//    CLINICIAN watches, given so she can follow a conversation — never so she
//    can rule herself out. Every path ends at a phone call.
//  · **Never "wait and see" as an instruction.** The honest asymmetry is
//    stated instead: calling and being told it is nothing costs an afternoon,
//    and the other mistake does not have a cost you can undo.
//  · **Never a diagnosis, and never contradicting her clinician.** Where a
//    doctor owns a decision we explain it, remind about it, or help her prepare
//    for it.
//
//  ⚠️ COSTS AND FIGURES CARRY A DATE. Checked September 2026.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE PER FILE, matching the convention in every other reads file.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

/// The complications bracket's hue.
const double _hue = 186;

// ⚠️ THE BYLINE IS THE DESK, NOT A DOCTOR — 2026-09-29 (pregnancy gap
// analysis, P1 "No claim we can't back"). These six carried "Dr. Anita Desai,
// reviewed September 2026", a reviewer who does not exist. Until a real
// clinician on the roster reads them they are `reviewed: false` and signed by
// ParentVeda editorial, and the evidence notes say the sources were checked,
// not that the piece was reviewed.
const LocalizedText _desk =
    LocalizedText(en: 'ParentVeda editorial', hi: 'ParentVeda editorial');
const LocalizedText _role = LocalizedText(
    en: 'Complications & conditions', hi: 'Complications & conditions');

// Rewritten 2026-09-29 to docs/PREG-VOICE.md: short answers on top, headings
// asked as her questions, the same facts and the same urgency. The previous
// English is in git history.
final List<PvRead> kPregnancyReadsConditions = [
  // ===========================================================================
  //  1. When blood pressure gets dangerous
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_bp_dangerous',
    hue: _hue,
    kicker: _role,
    title: _en('When blood pressure gets dangerous'),
    teaser: _en("Most raised blood pressure in pregnancy is watched, not "
        "feared. Here's how to tell the difference, and what not to sit on."),
    shortAnswer: _en("Most raised blood pressure in pregnancy is managed with "
        "closer check-ups and sometimes a tablet. It becomes urgent when it "
        "comes with a bad headache, changes in your vision, pain under your "
        "ribs, sudden swelling of your face or hands, or your baby moving "
        "less. Any of those means going in the same day."),

    scaleSetter: _en("Raised blood pressure is one of the most common things "
        "flagged in an Indian pregnancy, and most of it is managed with "
        "closer check-ups and, if needed, a tablet. What changes the picture "
        "isn't the number on its own. It's the number together with how you "
        "feel."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Your blood pressure is measured at every pregnancy visit. For "
              "most women it's a number that goes into the file and is never "
              "mentioned again. When it starts to climb, your doctor isn't "
              "watching for one high reading. They're watching for a "
              "pattern, and for whether the rest of your body has started to "
              "be affected."),
          _en("That difference is what this piece is about. High blood "
              "pressure by itself is a plumbing problem: the pressure in the "
              "pipes is up, and it's brought down. High blood pressure that "
              "has started to affect your kidneys, liver, eyes or baby is a "
              "different condition (preeclampsia), with a different name and "
              "a different urgency."),
          _en("You can't tell which one you have from a machine at home. You "
              "can tell a lot from how you feel, which is why the signs below "
              "matter more than any reading you take yourself."),
        ],
      ),

      PvReadSection(
        heading: _en('Which signs mean I should go in today?'),
        paragraphs: [
          _en("These mean call today, not mention it at your next visit. "
              "They're the same list your doctor carries, and none of them "
              "needs you to have taken a reading."),
        ],
        bullets: [
          _en("A bad headache that doesn't ease with rest or paracetamol."),
          _en("Changes in your vision: blurring, flashing lights, spots, or "
              "losing part of what you can see."),
          _en("Pain just under your ribs, usually on the right side. This is "
              "the least known sign and one of the most important, because "
              "it's easy to mistake for indigestion."),
          _en("Sudden swelling of your face or hands. Ankles that puff up "
              "through the day are ordinary. A face that looks different in "
              "the mirror overnight is not."),
          _en("Vomiting that starts late in pregnancy, when you had none "
              "before."),
          _en('Your baby moving less than usual.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('If two of these come together'),
          body: _en("Go in the same day. Don't phone and wait for a call back. "
              "A headache with changes in your vision is the combination "
              "doctors treat as an emergency."),
        ),
      ),

      PvReadSection(
        heading: _en("What do the numbers mean, and what don't they tell me?"),
        paragraphs: [
          _en("Doctors talk about two numbers: the pressure when your heart "
              "beats, and the pressure between beats. In pregnancy the second "
              "one is watched closely. Your readings are compared with your "
              "own earlier ones, not only with one line that fits everyone."),
          _en("That's why your first-visit reading matters so much. If you "
              "normally run low, a real rise can happen well before you reach "
              "a number that would look ordinary on someone else. Your "
              "booking reading is the baseline your whole pregnancy is "
              "compared against."),
          _en("What a number can't tell you is whether the rest of your body "
              "is affected. That takes a urine test for protein and a blood "
              "test. Both are quick, and neither can be done at home. So a "
              "home monitor is useful for spotting a trend, and poor for "
              "reassurance. A normal reading with a bad headache is not a "
              "normal situation."),
        ],
        tip: PvReadTip(
          title: _en("If you're checking at home"),
          body: _en("Sit still for five minutes first, feet flat, arm resting "
              "at the level of your heart. Take two readings a minute apart "
              "and write both down. A reading taken just after climbing "
              "stairs isn't a real measurement, and it's the most common "
              "reason women frighten themselves at 10pm."),
        ),
      ),

      PvReadSection(
        heading: _en('What happens if it does climb?'),
        paragraphs: [
          _en("Usually it means more checks, not a different life. More "
              "frequent visits, a urine test at each one, blood tests to see "
              "whether anything else is affected, and growth scans, because a "
              "placenta working against high pressure sometimes passes on "
              "less."),
          _en("If the numbers stay high, you'll probably be offered a tablet. "
              "Some blood pressure medicines have a long, well-studied record "
              "in pregnancy. They're given because bringing the pressure down "
              "protects you, not because something has gone wrong that can't "
              "be handled."),
          _en("Rest and less salt are often advised alongside medicine, not "
              "instead of it. If you've been given a tablet, take it. Stopping "
              "because you feel fine is the most common mistake here. Feeling "
              "fine is the tablet doing its job."),
          _en("The other thing that may change is the plan for the birth. "
              "When pressure is hard to control, delivery is the treatment, "
              "and the conversation turns to the safest week, not whether. "
              "That's a plan being made, not a failure."),
        ],
      ),

      PvReadSection(
        heading: _en('Does it end when the baby is born?'),
        collapsible: true,
        summary: _en("Not always straight away, and the weeks after birth are "
            "when it's most often missed."),
        paragraphs: [
          _en("Blood pressure that rose in pregnancy usually settles within a "
              "few weeks of the birth, but not always at once. Now and then "
              "it rises for the first time after delivery. The signs to watch "
              "for are the same ones as above."),
          _en("It's easy to miss, because everyone's attention is on the "
              "baby and a new mother expects to feel awful. A severe headache "
              "in the first two weeks after birth is worth a phone call, not "
              "just a paracetamol."),
          _en("Later on, keep in mind that you had raised blood pressure in "
              "pregnancy, and tell any future doctor. It's a piece of your "
              "history that changes how you're looked after, in a later "
              "pregnancy and outside one."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go in the same day if'),
      body: _en("You have a bad headache that won't ease, any change in your "
          "vision, pain under your ribs, sudden swelling of your face or "
          "hands, or your baby is moving less than usual. Don't wait for your "
          "next appointment, and don't wait to take a reading first."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My reading was high once and normal since. Does that '
            'count?'),
        answer: _en("Tell your doctor at your next visit rather than brushing "
            "it off. One high reading in an otherwise ordinary pregnancy is "
            "usually nothing, and it's also worth having written down so a "
            "pattern can be seen if one starts."),
      ),
      PvReadFaq(
        question: _en('Is the medicine safe for my baby?'),
        answer: _en("The ones used in pregnancy are chosen because they have "
            "long safety records in it. Uncontrolled high pressure carries a "
            "clearer risk to you both than the tablets do. If you're worried, "
            "ask which one you're on and why. It's a fair question, and "
            "there's a real answer."),
      ),
      PvReadFaq(
        question: _en('Will I definitely need a caesarean?'),
        answer: _en("No. Raised blood pressure on its own doesn't decide how "
            "you deliver. It may bring the timing forward, and how you "
            "deliver is decided on the day by how you and your baby are "
            "doing."),
      ),
      PvReadFaq(
        question: _en('Can I bring it down by resting more?'),
        answer: _en("Rest helps and is worth doing, but it isn't a treatment "
            "on its own. If you've been offered a tablet, rest is what you do "
            "alongside it."),
      ),
    ],

    evidence: _en('NICE guideline NG133, hypertension in pregnancy · FOGSI '
        'good clinical practice recommendations on hypertensive disorders of '
        'pregnancy · WHO recommendations on antenatal care · Sources checked '
        'September 2026.'),

    readNext: ['preg_cond_read_bleeding', 'preg_cond_read_less_movement'],
  ),

  // ===========================================================================
  //  2. Bleeding in pregnancy
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_bleeding',
    hue: _hue,
    kicker: _role,
    title: _en('Bleeding in pregnancy'),
    teaser: _en("What's usually nothing, what isn't, and why the answer is "
        "the same either way: tell someone today."),
    shortAnswer: _en("Bleeding in pregnancy is common, and many women who "
        "bleed go on to have ordinary pregnancies. You can't tell the "
        "harmless kinds from the serious ones by looking, so call your doctor "
        "the same day for any bleeding. Go straight to hospital if it's "
        "heavy, has clots or comes with pain."),

    scaleSetter: _en("Bleeding in pregnancy is common and frightening, and "
        "those two things sit oddly together. Many women who bleed early go "
        "on to have completely ordinary pregnancies. That's a real comfort, "
        "and it's not a reason to wait. The only way to know which kind you "
        "have is for someone to look."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("There's one instruction in this piece, and everything else is "
              "background: if you're bleeding, tell your doctor the same day. "
              "Not at your next appointment, and not after you've searched "
              "for what it might be."),
          _en("That isn't because bleeding is usually serious. It's because "
              "the harmless kinds and the serious kinds can't be told apart by "
              "how much blood there is, what colour it is, or how you feel. A "
              "small amount can matter, and a larger amount can turn out to "
              "be nothing."),
          _en("So here it is plainly. Calling and being told it's nothing "
              "costs you an afternoon. The other mistake can't be undone. And "
              "no doctor has ever been annoyed by a woman who called about "
              "bleeding."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('Go straight to hospital if'),
          body: _en("The bleeding is heavy, there are clots, or it comes with "
              "pain, especially sharp pain low down on one side, or pain at "
              "the tip of your shoulder. Don't drive yourself."),
        ),
      ),

      PvReadSection(
        heading: _en("What kinds are often nothing?"),
        paragraphs: [
          _en("Light spotting in the first weeks is the most common kind, and "
              "often there's no clear reason for it. Some happens around the "
              "time the pregnancy settles into the womb (implantation "
              "bleeding), some has no cause anyone can find, and a great many "
              "pregnancies that start with it carry on perfectly well."),
          _en("Bleeding after sex or after an internal examination is common "
              "too. In pregnancy your cervix has a much richer blood supply "
              "and is easily irritated. It looks alarming, and it's usually "
              "just what it looks like."),
          _en("Small harmless growths on the cervix can bleed on and off "
              "through a pregnancy. So can a small collection of blood beside "
              "the pregnancy that a scan sometimes picks up, which usually "
              "clears on its own."),
          _en("All of these still get reported. What makes them harmless is "
              "that someone looked and said so, not that they matched a "
              "description in an article."),
        ],
      ),

      PvReadSection(
        heading: _en("Which kinds aren't?"),
        paragraphs: [
          _en("A small number of causes are urgent. The reason to know them "
              "isn't to diagnose yourself. It's to know which ones mean "
              "hospital rather than a phone call."),
          _en("Bleeding with sharp pain on one side very early in pregnancy "
              "can mean the pregnancy has settled outside the womb (an "
              "ectopic pregnancy). Pain at the tip of your shoulder alongside "
              "it sounds like nothing, and it's the most important sign on "
              "this page. That's an emergency, and it's treatable when it's "
              "caught."),
          _en("Later in pregnancy, bleeding can come from a placenta lying "
              "low across the exit of the womb, or from a placenta starting "
              "to come away. The second usually hurts and the first often "
              "doesn't, which is exactly why \"it doesn't hurt\" isn't "
              "reassurance."),
          _en("Bleeding close to your due weeks may be labour starting. A "
              "small amount of blood-stained mucus is normal then. Anything "
              "heavier still gets a call."),
        ],
      ),

      PvReadSection(
        heading: _en('What should I do, and what should I notice?'),
        paragraphs: [
          _en("Use a pad, not a tampon, so someone can see how much there has "
              "been. Don't put anything inside, and hold off on sex until "
              "you've been told it's fine."),
          _en("Notice three things before you call, because they're the "
              "three you'll be asked: roughly how much, what colour, and "
              "whether there's pain. \"Two spots, brown, no pain\" and "
              "\"soaking a pad in an hour, red, cramping\" are two very "
              "different conversations."),
          _en("If you know your blood group, say it. Women who are Rh "
              "negative may need an injection after bleeding, and its timing "
              "matters. It's one of the clearest reasons not to sit on it for "
              "a week."),
        ],
        tip: PvReadTip(
          title: _en('Brown is older, red is newer'),
          body: _en("Brown blood has taken time to come away and usually means "
              "something that has already happened. Fresh red means it's "
              "happening now. It's useful to say on the phone. It isn't a "
              "way of deciding whether to make the call."),
        ),
      ),

      PvReadSection(
        heading: _en('What if it means a loss?'),
        collapsible: true,
        summary: _en("Sometimes bleeding is the start of a loss, and that "
            "deserves saying gently rather than avoiding."),
        paragraphs: [
          _en("Some bleeding is an early pregnancy ending. Most early loss "
              "comes from how that particular pregnancy formed, right from "
              "the start. It isn't caused by lifting something, by working, "
              "by an argument, by travel, or by anything you ate."),
          _en("That's here because it's what almost every woman goes looking "
              "for afterwards, and because the answer is clear and kind and "
              "true."),
          _en("You'll be looked after either way. Ask what's happening, ask "
              "what your choices are, and ask to have someone with you. None "
              "of it has to be decided in the first hour."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day for any bleeding'),
      body: _en("However light. Go straight to hospital if it's heavy, has "
          "clots, or comes with pain, especially sharp pain low down on one "
          "side, pain at the tip of your shoulder, or feeling faint."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('It stopped after an hour. Do I still need to say '
            'anything?'),
        answer: _en("Yes, the same day. Bleeding that has stopped is still "
            "bleeding that happened. It may change what your doctor wants to "
            "check, or whether you need an injection for your blood group."),
      ),
      PvReadFaq(
        question: _en('Is spotting normal around the time my period would '
            'have been due?'),
        answer: _en("Some women notice light spotting around those dates in "
            "early pregnancy, and it's often nothing. It's still worth "
            "mentioning, because \"often nothing\" isn't the same as \"known "
            "to be nothing for you\"."),
      ),
      // Added 2026-09-29 (gap analysis, Appendix A, "Implantation or
      // miscarriage?"): the early-weeks question she asks, ending at the call.
      PvReadFaq(
        question: _en('Is this implantation bleeding or a miscarriage?'),
        answer: _en("You can't tell from the blood alone. Implantation "
            "spotting is usually light, pink or brown, and lasts a day or "
            "two. Bleeding that gets heavier, turns bright red, or comes with "
            "clots or cramping pain is more worrying. Either way, only a "
            "check can say, so call your doctor the same day."),
      ),
      PvReadFaq(
        question: _en('Did I cause this?'),
        answer: _en("Almost certainly not. Ordinary activity, work, travel, "
            "lifting a toddler and sex don't cause bleeding that matters. "
            "Early loss is overwhelmingly about how a pregnancy formed, not "
            "anything that was done to it."),
      ),
    ],

    evidence: _en('Royal College of Obstetricians and Gynaecologists patient '
        'information on early pregnancy loss and on bleeding in later '
        'pregnancy · FOGSI recommendations on antepartum haemorrhage · '
        'Ministry of Health and Family Welfare anti-D guidance · Sources '
        'checked September 2026.'),

    readNext: ['preg_cond_read_less_movement', 'preg_cond_read_bp_dangerous'],
  ),

  // ===========================================================================
  //  3. When the baby moves less
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_less_movement',
    hue: _hue,
    kicker: _role,
    title: _en('When the baby moves less'),
    teaser: _en("Don't wait until tomorrow, don't drink something cold "
        "first, and don't count for two hours before you call."),
    shortAnswer: _en("If your baby is moving less than usual, call your "
        "maternity unit now, at any hour. Don't wait until morning and don't "
        "try tricks or count first. Most women who go in are checked and sent "
        "home reassured the same day."),

    scaleSetter: _en("Most women who go in because their baby is moving less "
        "are sent home reassured the same day. That's the point of going. "
        "It's a quick check, it's free at a government hospital, and it's one "
        "of the few things in pregnancy where being early costs nothing and "
        "being late can cost a great deal."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("When a baby who moves in a pattern you know stops moving that "
              "way, it's one of the most useful warning signs in late "
              "pregnancy. It tells you more than any measurement you can "
              "take, and you have it every day, for free."),
          _en("It's also the sign women are most often talked out of. Almost "
              "everyone is told to lie down, eat something sweet, drink "
              "something cold and count. Some of that is well meant and some "
              "is handed down. None of it should delay a phone call, and "
              "that's what this piece is about."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en("There's no good hour to wait"),
          body: _en("If the movements are less than usual right now, call now, "
              "day or night. Maternity units expect these calls, take them "
              "seriously, and would much rather see you."),
        ),
      ),

      PvReadSection(
        heading: _en('What counts as "less"?'),
        paragraphs: [
          _en("Less than your baby's usual, not less than a number. Babies "
              "differ a lot. Some are busy all evening, some move in short "
              "bursts through the day. What matters is a change from the "
              "pattern you've got used to."),
          _en("You'll start to feel movements somewhere between eighteen and "
              "twenty-four weeks, later if this is your first pregnancy or if "
              "your placenta is at the front. From around twenty-eight weeks "
              "the pattern becomes something you recognise, and from then on "
              "you're the person best placed to notice it change."),
          _en("Babies don't run out of room and move less near the end. It's "
              "a common belief and it's wrong, and it's the most common reason "
              "women wait. Movements should stay recognisable right up to "
              "labour."),
        ],
        mythFact: PvMythFact(
          myth: _en('Babies move less in the last weeks because there is no '
              'space left.'),
          fact: _en("They don't. The kind of movement changes: more stretching "
              "and rolling, fewer sharp kicks, because a bigger baby moves "
              "differently. But how often you feel something shouldn't fall "
              "away. A real drop near your due date is a reason to be seen, "
              "not a stage to expect."),
        ),
      ),

      PvReadSection(
        heading: _en('What should I not do first?'),
        paragraphs: [
          _en("Three things get suggested all the time, and each one uses up "
              "time for no good reason."),
        ],
        bullets: [
          _en("Don't lie down and count to ten before deciding. Formal "
              "counting schemes haven't been shown to change outcomes, and "
              "they reliably delay the call."),
          _en("Don't drink something cold or sugary to \"wake the baby\". If "
              "your baby moves afterwards it proves very little, and if they "
              "don't, you've lost an hour being frightened."),
          _en("Don't wait for morning. A maternity unit is staffed at 3am, and "
              "the check is the same at 3am as at 10am."),
        ],
        // Added 2026-09-29 (gap analysis, Appendix A, "Getting Your Baby to
        // Move in Utero"): the tricks, only with the line that outranks them.
        tip: PvReadTip(
          title: _en('The tricks everyone suggests'),
          body: _en("Lying on your left side, a cold drink, a snack, or a "
              "gentle press on your bump. On an ordinary day, while you're "
              "getting to know your baby's pattern, these do no harm. They "
              "are never a test. If your baby is moving less than usual, call "
              "your maternity unit today and don't wait to see whether a "
              "trick works."),
        ),
      ),

      PvReadSection(
        heading: _en('What happens when I go in?'),
        paragraphs: [
          _en("It's quick and it isn't invasive. Someone listens to your "
              "baby's heartbeat, usually with a monitor strapped on for twenty "
              "to forty minutes so the trace can be watched over time. Your "
              "blood pressure is checked, and often your urine too."),
          _en("Depending on what they see and how many weeks you are, you may "
              "be offered a scan to look at your baby's growth and the fluid "
              "around them. Most of the time everything is normal and you go "
              "home."),
          _en("If it happens again, go again. Coming back a second or third "
              "time isn't being a nuisance. Repeated episodes are exactly what "
              "doctors want to know about, and each visit is looked at on its "
              "own."),
        ],
        tip: PvReadTip(
          title: _en('Save the number before you need it'),
          body: _en("Find the direct number for your hospital's labour ward or "
              "maternity triage now, and save it in your phone. At 2am, "
              "hunting for a number is what causes the delay."),
        ),
      ),

      PvReadSection(
        heading: _en("How do I get to know my baby's pattern?"),
        collapsible: true,
        summary: _en("You don't need an app or a chart. You need a small daily "
            "habit."),
        paragraphs: [
          _en("From around twenty-eight weeks, spend a little time each day in "
              "the same position, at roughly the same time, paying attention. "
              "Many women find the evening works, because babies are often "
              "active then and you're finally still."),
          _en("You're not looking for a count. You're building a sense of "
              "what ordinary feels like, so a change feels like a change, not "
              "a vague unease you talk yourself out of."),
          _en("If your husband or partner has felt the baby move from "
              "outside, they'll often notice a quiet spell too. Two people "
              "paying attention is better than a chart."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call now, at any hour'),
      body: _en("If your baby is moving less than usual, or the pattern has "
          "changed, contact your maternity unit straight away. Don't wait "
          "until morning and don't count first. If you've also had bleeding, "
          "a bad headache or fluid leaking, say so on the call."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My baby started moving again while I was on the phone. '
            'Should I still go?'),
        answer: _en("Say so on the call and let them decide. Movements coming "
            "back is reassuring, and it doesn't automatically cancel the "
            "check, especially if this has happened before."),
      ),
      PvReadFaq(
        question: _en("My placenta is at the front and I feel less anyway."),
        answer: _en("A placenta at the front (anterior placenta) does cushion "
            "the movements, so you may feel them later and more faintly. It "
            "doesn't change the rule: what matters is a change from your own "
            "usual, whatever that is."),
      ),
      PvReadFaq(
        question: _en("This is my third time going in this month."),
        answer: _en("Then go. Repeated episodes are exactly what your doctor "
            "wants to know about, and each one is checked on its own. Nobody "
            "is counting your visits against you."),
      ),
      PvReadFaq(
        question: _en('Is a home doppler a good idea?'),
        answer: _en("No. Finding a heartbeat at home is the most common way "
            "women are falsely reassured and delay going in. A heartbeat now "
            "says nothing about how your baby has been. Use how your baby "
            "moves, and use the phone."),
      ),
    ],

    evidence: _en('Royal College of Obstetricians and Gynaecologists Green-top '
        'Guideline 57, reduced fetal movements · AFFIRM trial, Lancet 2018 · '
        'FOGSI good clinical practice recommendations on fetal surveillance · '
        'Sources checked September 2026.'),

    readNext: ['preg_cond_read_bleeding', 'preg_cond_read_bp_dangerous'],
  ),

  // ===========================================================================
  //  4. Handling pregnancy sugar in India
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_sugar_india',
    hue: _hue,
    kicker: _role,
    title: _en('Handling pregnancy sugar in India'),
    teaser: _en("Rice, roti, festivals and a joint family kitchen: what "
        "shifts the numbers, and what only makes meals miserable."),
    shortAnswer: _en("You don't have to give up rice or roti. Eat the "
        "vegetables and dal first, walk for ten to fifteen minutes after each "
        "main meal, and have smaller meals more often. Most women manage "
        "pregnancy sugar this way, and needing medicine later isn't a "
        "failure."),

    scaleSetter: _en("Most women with pregnancy sugar manage it with food "
        "and walking alone, and most have healthy babies without anything "
        "else changing. Needing tablets or insulin later isn't a failure. For "
        "some women it's what their body needs, and it works."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Almost every piece of advice about pregnancy sugar was written "
              "for a plate that looks nothing like an Indian one. \"Cut "
              "carbs\" isn't useful in a home where rice or roti is the meal, "
              "and it's usually heard as \"eat less\", which is the wrong "
              "instruction in pregnancy."),
          _en("The useful version is smaller and easier: keep the food, "
              "change the shape of the meal, and move afterwards. Nothing "
              "below asks you to stop eating what your family eats."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("This isn't about your weight"),
          body: _en("Pregnancy sugar happens because pregnancy hormones block "
              "the effect of insulin. Thin women get it, women who eat "
              "carefully get it, and it's not something you brought on "
              "yourself."),
        ),
      ),

      PvReadSection(
        heading: _en('Which three changes help most?'),
        paragraphs: [
          _en("If you do nothing else, do these. They shift your readings "
              "more than any list of forbidden foods."),
        ],
        bullets: [
          _en("Don't eat the rice or roti first or on its own. Start the "
              "meal with the vegetable or the dal, keep the curd, and eat the "
              "rice or roti alongside them. The same food in a different "
              "order reaches your blood more slowly."),
          _en("Walk for ten to fifteen minutes after each main meal. This "
              "helps more than anything else on the list, and it's the one "
              "most often skipped. Round the terrace or down the corridor is "
              "enough."),
          _en("Split your day into smaller meals more often, rather than two "
              "or three big ones, and don't skip breakfast. A long gap "
              "followed by a big plate gives the worst readings."),
        ],
      ),

      PvReadSection(
        heading: _en('What about the Indian plate?'),
        paragraphs: [
          _en("Rice doesn't have to go. Which rice and how much matters, and "
              "so does what's beside it. Hand-pounded and parboiled rice "
              "behave better than highly polished white rice, and a smaller "
              "portion of rice with more dal and sabzi behaves better than "
              "either."),
          _en("Roti is usually kinder than white rice, and mixing the atta "
              "with besan, jowar or bajra is kinder still. A spoon of ghee in "
              "the dough isn't the problem it's often thought to be. Fat slows "
              "the meal down."),
          _en("The things that do need to go are the ones that turn into "
              "sugar almost at once: sweetened tea and coffee, packaged "
              "juices, colas and mithai. Fruit isn't in that group. Whole "
              "fruit with its fibre is fine in sensible amounts. It's fruit "
              "juice that behaves like a soft drink."),
          _en("Curd, paneer, eggs, dal, nuts and seeds all help. Adding "
              "protein to a meal does more good than taking carbohydrate "
              "away from it."),
        ],
        tip: PvReadTip(
          title: _en('Festivals and guests'),
          body: _en("You'll be offered sweets, and saying no every time is "
              "exhausting. Eat the piece you want, after a proper meal rather "
              "than on an empty stomach, and walk afterwards. One planned "
              "sweet eaten well beats three unplanned ones and a week of "
              "guilt."),
        ),
      ),

      PvReadSection(
        heading: _en('Why am I testing, and what are the numbers for?'),
        paragraphs: [
          _en("You'll most likely be asked to check your sugar at home, "
              "fasting and after meals, and to write the readings down. The "
              "record isn't there to grade you. It shows your doctor which "
              "meals are the problem, and no single reading can tell them "
              "that."),
          _en("So write down what you ate beside each number. A high reading "
              "after one particular breakfast is something you can fix. A "
              "column of numbers with no food beside them is just a column of "
              "numbers."),
          _en("Your doctor sets your targets, and they aren't the same for "
              "everyone. If your readings stay above them despite the changes "
              "above, that's what the plan needs to know. It isn't a reason to "
              "eat less."),
        ],
      ),

      PvReadSection(
        heading: _en("What if I'm offered tablets or insulin?"),
        collapsible: true,
        summary: _en("It's common, it isn't a failure, and insulin doesn't "
            "cross to your baby."),
        paragraphs: [
          _en("A good number of women need medicine as well as food changes, "
              "most often in the last three months, when the hormones "
              "blocking insulin are strongest. That's the pregnancy changing, "
              "not your effort failing."),
          _en("Insulin doesn't cross the placenta to your baby. High sugar "
              "does. Put side by side, those two facts often make the choice "
              "look different from how it first feels."),
          _en("Whatever you're given, keep the food changes going alongside "
              "it. Medicine works better on top of them than instead of them, "
              "and the walking still helps."),
        ],
      ),

      PvReadSection(
        heading: _en('What happens after the birth?'),
        paragraphs: [
          _en("Pregnancy sugar usually goes within days of delivery, and most "
              "women stop all treatment straight away."),
          _en("The part that gets forgotten is the follow-up test a few weeks "
              "later, which checks that things are back to normal. Having had "
              "pregnancy sugar raises the chance of type 2 diabetes years "
              "later. That's worth knowing because regular checks and "
              "everyday habits help keep it away."),
          _en("Book that test before you leave hospital if you can. In the "
              "first month with a newborn, nothing happens unless it's "
              "booked."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en("You feel shaky, sweaty, confused or faint after starting "
          "medicine. This can mean your sugar has dropped too low and needs "
          "treating now. Also call if your readings stay high despite the "
          "changes, or if your baby is moving less than usual."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Do I have to stop rice completely?'),
        answer: _en("No. How much, which kind and what's beside it matter far "
            "more than cutting it out. A smaller serving of parboiled rice "
            "with plenty of dal and sabzi, followed by a walk, works for most "
            "women."),
      ),
      PvReadFaq(
        question: _en('Can I fast during a festival?'),
        answer: _en("Ask your doctor before you decide, especially if you're "
            "on any medicine. Long gaps without food can send your sugar too "
            "low. Many women find a gentler way of observing the fast is "
            "agreed easily once they ask."),
      ),
      PvReadFaq(
        question: _en('Will my baby be very large?'),
        answer: _en("Well-controlled sugar largely removes that concern, which "
            "is why it's monitored. Your growth scans are how this is "
            "watched, so it's a conversation to have with your doctor, not "
            "something to predict."),
      ),
      PvReadFaq(
        question: _en('Is a sugar-free sweetener safe?'),
        answer: _en("Some are considered fine in pregnancy and some aren't, "
            "and it varies by product. Ask your doctor about the one you use "
            "rather than assuming they're all fine."),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare, National Guidelines '
        'for Diagnosis and Management of Gestational Diabetes Mellitus · FOGSI '
        'and DIPSI recommendations · Indian Council of Medical Research '
        'dietary guidelines · Sources checked September 2026.'),

    readNext: ['preg_cond_read_iron', 'preg_cond_read_thyroid_tablet'],
  ),

  // ===========================================================================
  //  5. The daily thyroid tablet
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_thyroid_tablet',
    hue: _hue,
    kicker: _role,
    title: _en('The daily thyroid tablet'),
    teaser: _en('When to take it, what stops it working, and why the dose '
        'changes during pregnancy.'),
    shortAnswer: _en("Take your thyroid tablet first thing in the morning "
        "with plain water, and wait 30 to 60 minutes before tea or breakfast. "
        "Keep it four hours away from iron and calcium tablets. Your dose will "
        "probably go up as your pregnancy goes on, and that's expected."),

    scaleSetter: _en("An underactive thyroid in pregnancy is common in India, "
        "and it's one of the most fixable things on any pregnancy list. One "
        "tablet, taken the right way, brings the level back where it should "
        "be. Taking it the right way is most of the work."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Your thyroid is a small gland in your neck that sets the pace "
              "of a lot of things in your body. In the first months of "
              "pregnancy your baby depends on your thyroid hormone, before "
              "making any of their own. That's why a level that would be "
              "ignored outside pregnancy gets treated inside it."),
          _en("The treatment is a tablet that replaces exactly what your "
              "gland isn't making enough of. It isn't a drug doing something "
              "new to your body. It's the same hormone, taken by mouth. That's "
              "why it's considered safe in pregnancy, and why the dose is set "
              "by blood tests rather than by how you feel."),
        ],
      ),

      PvReadSection(
        heading: _en('How do I take it so it works?'),
        paragraphs: [
          _en("This tablet is fussy about company. Most of the reasons a "
              "level stays wrong are here, not in the dose."),
        ],
        bullets: [
          _en("First thing in the morning, on an empty stomach, with plain "
              "water. Then wait thirty to sixty minutes before tea, coffee or "
              "breakfast."),
          _en("Keep it four hours away from iron and from calcium. Both bind "
              "to it in your gut, and much of the dose never gets in. Since "
              "almost every pregnant woman in India also takes iron and "
              "calcium, this is the most common problem of all."),
          _en('Keep it away from antacids too, and from meals heavy in soya.'),
          _en("Take it at the same time every day. If mornings are "
              "impossible, ask about taking it at bedtime instead, three "
              "hours after eating. That works for many women and is better "
              "than a dose taken at random with breakfast."),
        ],
        tip: PvReadTip(
          title: _en('If morning sickness gets in the way'),
          body: _en("Tell your doctor rather than skipping it. Taking it at "
              "bedtime, or the moment you wake and then lying still for a "
              "while, both help. A tablet you can keep down is worth more "
              "than the perfect timing on paper."),
        ),
      ),

      PvReadSection(
        heading: _en('Why does my dose keep changing?'),
        paragraphs: [
          _en("Your need for thyroid hormone rises early in pregnancy and "
              "keeps rising into the middle months. So a dose that was right "
              "before you conceived is usually not enough by the second "
              "month. Women already on treatment are often asked to increase "
              "it as soon as the pregnancy is confirmed."),
          _en("That's why the blood test is repeated every few weeks, not "
              "done once. The test is checking whether your dose is keeping up "
              "with a need that keeps moving, not whether you have the "
              "condition."),
          _en("So a rising dose isn't a sign of getting worse. It's what a "
              "normal pregnancy on treatment looks like."),
        ],
      ),

      PvReadSection(
        heading: _en('What if I miss a dose?'),
        paragraphs: [
          _en("If you forget one, take it as soon as you remember on the same "
              "day. If you only remember the next day, take that day's dose as "
              "usual and don't double up. The hormone stays in your body for a "
              "long time, and one missed tablet doesn't undo anything."),
          _en("If you've missed several, say so at your next visit. Nobody "
              "will be cross, and it changes how your next blood test is "
              "read. A level that looks wrong because doses were missed can "
              "lead to a dose increase you don't need."),
          _en("Don't stop because you feel well. Feeling well is the tablet "
              "working, and stopping in the middle of a pregnancy is the one "
              "risky thing you can do with it."),
        ],
      ),

      PvReadSection(
        heading: _en('What happens after the birth?'),
        collapsible: true,
        summary: _en("The dose usually drops back, and the tablet is safe "
            "while breastfeeding."),
        paragraphs: [
          _en("Most women go back to roughly their pre-pregnancy dose after "
              "delivery, and a blood test a few weeks later confirms where it "
              "should sit. Don't change it yourself."),
          _en("The tablet is safe while breastfeeding. Only tiny amounts "
              "reach your milk, and it's the same hormone your baby needs "
              "anyway."),
          _en("Some women whose thyroid was normal before pregnancy develop a "
              "short-lived problem in the months after birth. Tiredness and "
              "low mood then are usually just new parenthood. But if you had "
              "thyroid trouble in pregnancy, mention them rather than "
              "assuming."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Talk to your doctor if'),
      body: _en("You have a racing heart, feel very jittery or are losing "
          "weight. A dose can be too high as well as too low. Also call if "
          "you've run out of tablets or missed them for more than a few days. "
          "Never stop or change the dose on your own."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Can I take it with my iron tablet to save time?'),
        answer: _en("No. That's the change most likely to stop it working. "
            "Keep four hours between them: the thyroid tablet in the "
            "morning, the iron later in the day."),
      ),
      PvReadFaq(
        question: _en('Do I need iodised salt as well?'),
        answer: _en("Use iodised salt, yes. It doesn't replace the tablet. "
            "Iodine levels vary a lot across India, which is part of why "
            "thyroid problems are picked up so often here."),
      ),
      PvReadFaq(
        question: _en('Will my baby have a thyroid problem?'),
        answer: _en("Treated properly, this isn't usually passed on. Newborns "
            "in India are often screened for thyroid problems anyway, as "
            "part of routine checks."),
      ),
      PvReadFaq(
        question: _en('Does the brand matter?'),
        answer: _en("Try to stay on the same brand through your pregnancy if "
            "you can. Small differences between makers can shift your levels "
            "enough to notice, and switching midway makes a blood test harder "
            "to read."),
      ),
    ],

    evidence: _en('American Thyroid Association guidelines for thyroid disease '
        'during pregnancy and postpartum · Indian Thyroid Society '
        'recommendations · Ministry of Health and Family Welfare national '
        'iodine programme · Sources checked September 2026.'),

    readNext: ['preg_cond_read_iron', 'preg_cond_read_sugar_india'],
  ),

  // ===========================================================================
  //  6. Iron, from food and tablets
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_iron',
    hue: _hue,
    kicker: _role,
    title: _en('Iron, from food and tablets'),
    teaser: _en('Why the tablets upset your stomach, what to take them with, '
        'and which foods help.'),
    shortAnswer: _en("Take your iron tablet with something that has vitamin C, "
        "like nimbu pani or amla, and keep tea, coffee and milk an hour away "
        "from it. If it upsets your stomach, take it after a small meal or ask "
        "about another form rather than stopping. Food helps, but in "
        "pregnancy most women need the tablet as well."),

    scaleSetter: _en("Low iron is by far the most common thing found in "
        "Indian pregnancies, and it's also one of the easiest to correct. "
        "Most of the difficulty isn't medical. It's that the tablets are "
        "unpleasant and easy to give up on without telling anyone."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Your blood volume rises a lot in pregnancy, and iron is what "
              "lets that extra blood carry oxygen. Your need roughly doubles "
              "over nine months. That's more than most diets supply and more "
              "than most bodies have stored, which is why iron is given to "
              "nearly every pregnant woman in India, not only to those who "
              "test low."),
          _en("Being low makes you tired, breathless on the stairs, and less "
              "able to cope with the normal blood loss of a delivery. It's "
              "worth fixing for how you feel, not only for a number on a "
              "report."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("Tiredness doesn't prove anything"),
          body: _en("Pregnancy is tiring whether your iron is low or not, and "
              "plenty of women with low iron feel fine. A blood test answers "
              "this, not how you feel, which is why the test is routine."),
        ),
      ),

      PvReadSection(
        heading: _en('How can I make the tablets easier?'),
        paragraphs: [
          _en("Constipation, nausea, a metallic taste and black stools are the "
              "usual complaints. Black stools are harmless and expected. The "
              "rest can almost always be improved without stopping."),
        ],
        bullets: [
          _en("Take it with vitamin C and far more is absorbed: a glass of "
              "nimbu pani, an orange, or amla with the tablet. This is the most "
              "useful habit here."),
          _en("Never with tea, coffee or milk. Tannins and calcium both block "
              "a lot of the iron, and chai with the tablet is the most common "
              "way a full dose does almost nothing. Leave an hour on either "
              "side."),
          _en("If it makes you sick on an empty stomach, take it after a small "
              "meal. A little less is absorbed, but a tablet you keep taking "
              "beats a better-absorbed one you stop."),
          _en("For constipation: more water, more fibre, and ask about a stool "
              "softener rather than giving up the iron. Doctors get asked this "
              "all the time."),
          _en("If one kind is unbearable, ask about another. There are several "
              "forms and they sit very differently. Some women also do better "
              "taking it every other day."),
        ],
      ),

      PvReadSection(
        heading: _en('Can food give me enough iron?'),
        paragraphs: [
          _en("Food matters, and food alone usually won't correct a real "
              "shortfall in pregnancy. Both are true, and the second is why "
              "the tablets exist."),
          _en("Iron from meat, fish and eggs is absorbed several times more "
              "easily than iron from plants. If you eat them, they're the "
              "quickest route by far."),
          _en("If you're vegetarian, good sources are dal and rajma, green "
              "leafy vegetables, ragi, bajra, jaggery, sesame, dates and "
              "raisins. Sprouting, soaking and fermenting all help you absorb "
              "more of that iron, which is part of why idli and dosa batter "
              "is made the way it is."),
          _en("Cooking in an iron kadhai does add some iron to food, "
              "especially with something sour in it. It's a real effect and a "
              "small one: a helpful habit, not a treatment."),
        ],
        tip: PvReadTip(
          title: _en('The pairing that does the work'),
          body: _en("Put some vitamin C in the same meal as your iron-rich "
              "food: lemon over the dal, tomato in the sabzi, amla or guava "
              "after. It changes how much you absorb far more than swapping "
              "one iron-rich food for another."),
        ),
      ),

      PvReadSection(
        heading: _en("What if tablets aren't enough?"),
        paragraphs: [
          _en("If your level is very low, if you can't manage the tablets, or "
              "if you're close to your due date and there isn't time for "
              "tablets to work, you may be offered iron straight into a vein "
              "(an iron infusion)."),
          _en("It's given in hospital or a day-care unit and takes an hour or "
              "so. It's a normal part of pregnancy care in India, not a sign "
              "that something has gone badly wrong, and it works much faster "
              "than tablets."),
          _en("Very severe anaemia close to delivery is sometimes treated with "
              "a blood transfusion. That's uncommon, and it's one of the "
              "reasons routine testing exists. Finding it early is how it "
              "never gets that far."),
        ],
      ),

      PvReadSection(
        heading: _en('Do I keep taking it after the birth?'),
        collapsible: true,
        summary: _en("Yes. Delivery is when your stores are lowest."),
        paragraphs: [
          _en("You'll usually be asked to carry on with iron for some months "
              "after the birth. A delivery involves real blood loss, and "
              "rebuilding your stores takes far longer than losing them did."),
          _en("It matters for how you feel at a time when you're already "
              "exhausted, and low iron after birth is easy to mistake for "
              "ordinary new-baby tiredness. If you're still breathless on the "
              "stairs at three months, ask for a test rather than assuming."),
          _en('Iron tablets are safe while breastfeeding.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en("You're breathless at rest, have chest pain or a racing heart, "
          "or feel faint when you stand. Also call if you can't keep the "
          "tablets down at all. There are other ways to give iron, and "
          "stopping without telling anyone is the one choice that leaves you "
          "low."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My stools have gone black. Is that a problem?'),
        answer: _en("No, that's expected with iron and it's harmless. Black "
            "stools that are sticky and smell very bad, or any blood, are "
            "different and need a call."),
      ),
      PvReadFaq(
        question: _en('Can I take iron and calcium together?'),
        answer: _en("Better not, because calcium blocks iron. Take iron at one "
            "time of day and calcium at another. If you also take a thyroid "
            "tablet, that goes first thing and the iron much later."),
      ),
      PvReadFaq(
        question: _en('Is beetroot or pomegranate juice enough?'),
        answer: _en("They're healthy, but they aren't iron treatments. Neither "
            "has much iron, and their reputation is mostly about colour. Keep "
            "them if you enjoy them, and keep the tablet."),
      ),
      PvReadFaq(
        question: _en('How long until I feel better?'),
        answer: _en("Often two to four weeks for the tiredness to lift, and a "
            "good while longer to rebuild your stores. That's why the course "
            "carries on after your report looks normal."),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare, Anemia Mukt Bharat '
        'operational guidelines · WHO recommendations on antenatal iron and '
        'folic acid supplementation · FOGSI recommendations on anaemia in '
        'pregnancy · Sources checked September 2026.'),

    readNext: ['preg_cond_read_sugar_india', 'preg_cond_read_thyroid_tablet'],
  ),

  // ===========================================================================
  //  7. Told you're high risk — added 2026-09-29
  // ===========================================================================
  //  Gap analysis, Complications › Living with it, "Having a High-Risk
  //  Pregnancy" (P2): many women are told they are high risk with no
  //  explanation. Written from scratch. It explains the label and what changes
  //  in her care; it never assigns the label, and nothing in the app infers
  //  it (`PregCondition.highRisk` stays unmapped on purpose).
  PvRead(
    id: 'preg_cond_read_high_risk',
    hue: _hue,
    kicker: _role,
    title: _en("Told you're \"high risk\"? What it means"),
    teaser: _en("What the label means, why doctors use it, and what changes "
        "in your care."),
    shortAnswer: _en("\"High risk\" means your pregnancy needs closer watching, "
        "not that something is going wrong. It's used for many common "
        "reasons, like blood pressure, sugar, twins, age or a past "
        "caesarean. Most women given the label have healthy babies, with "
        "more check-ups along the way."),

    scaleSetter: _en("Being told you're high risk can feel like being told "
        "something bad will happen. It doesn't mean that. It's a label for "
        "care, not a prediction, and it usually means you'll be seen more "
        "often by people paying closer attention."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("Doctors in India use \"high risk\" a lot, and often say it "
              "quickly, at the end of a busy visit. Many women go home with "
              "the words and no explanation, and spend the night reading. If "
              "that's you, this is the explanation you didn't get."),
          _en("The label means one thing: something about your health or "
              "your pregnancy means it should be watched more closely than "
              "usual. It says nothing about how your pregnancy will turn out. "
              "Its whole purpose is to make sure anything that does come up "
              "is caught early."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en("It's about care, not about you"),
          body: _en("Nothing on this page means you did something wrong. Most "
              "of the reasons a pregnancy is called high risk are things "
              "nobody chooses."),
        ),
      ),

      PvReadSection(
        heading: _en('Why might I be called high risk?'),
        paragraphs: [
          _en("The reasons are many, and most are common. Your doctor may "
              "have used the label for one of these, or for something else in "
              "your history."),
        ],
        bullets: [
          _en('High blood pressure, or sugar that runs high, before or during '
              'this pregnancy.'),
          _en('A condition you had before, like thyroid trouble, epilepsy, '
              'heart or kidney disease.'),
          _en('Carrying twins or more.'),
          _en('Being under 18 or over 35.'),
          _en('A past caesarean, early birth, miscarriage or stillbirth.'),
          _en('Severe anaemia, or being Rh negative.'),
          _en('Something found on a scan, like a low-lying placenta or a baby '
              'measuring small.'),
        ],
      ),

      PvReadSection(
        heading: _en('What changes in my care?'),
        paragraphs: [
          _en("Usually, more of the same care, closer together. You may have "
              "check-ups every two weeks instead of every four, more blood "
              "and urine tests, and extra scans to follow your baby's "
              "growth."),
          _en("You may be asked to see a specialist as well, or to have your "
              "delivery planned in a hospital with a newborn unit (NICU) and "
              "a blood bank. That isn't because something is expected to go "
              "wrong. It's so that everything is close by if it's needed."),
          _en("Some of the extra care is for you, not only for your baby. "
              "Your blood pressure, sugar and blood count may be checked more "
              "often, and your doctor may start a medicine, like low-dose "
              "aspirin or extra iron, if it suits the reason for the "
              "label."),
          _en("In government hospitals the label often means a coloured "
              "sticker on your card, so every doctor who sees you knows to "
              "look closer. Under the Pradhan Mantri Surakshit Matritva "
              "Abhiyan, government health centres also offer a free check-up "
              "by a doctor on the 9th of every month in the second and third "
              "trimesters."),
        ],
        tip: PvReadTip(
          title: _en('Keep your file together'),
          body: _en("Keep every report, scan and prescription in one folder "
              "and take it to every visit. When several doctors are involved, "
              "the file is what joins them up."),
        ),
      ),

      PvReadSection(
        heading: _en('What can I ask my doctor?'),
        paragraphs: [
          _en("You're allowed to ask what the label means for you. These "
              "questions help, and your doctor is used to them."),
        ],
        bullets: [
          _en('Why am I high risk, in plain words?'),
          _en('What are you watching for, and how will we know?'),
          _en('How often do I need to come in, and which tests will I have?'),
          _en('Where should I plan to deliver?'),
          _en('What should make me call you, or go in, the same day?'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I live with the label?'),
        collapsible: true,
        summary: _en("Keep your ordinary life going, and let the extra checks "
            "do their job."),
        paragraphs: [
          _en("Most women with a high-risk pregnancy keep working, cooking, "
              "walking and living much as before, unless their doctor says "
              "otherwise. The label doesn't mean bed rest or stopping "
              "everything. If you've been told to rest, ask what that means "
              "for you in practice."),
          _en("Family may become more protective, or more anxious, once they "
              "hear the words. It can help to share what the label means and "
              "what your doctor has asked you to do, so the house follows one "
              "plan rather than everyone's worries."),
          _en("It's normal to feel scared or low. If the worry is taking over "
              "your days or nights, tell your doctor. That's part of your "
              "care too."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor or go in the same day if'),
      body: _en("You have any bleeding, a bad headache that won't ease, "
          "changes in your vision, fluid leaking, regular tightenings before "
          "37 weeks, or your baby is moving less than usual. With a high-risk "
          "pregnancy, don't wait for your next visit."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Does high risk mean I will need a caesarean?'),
        answer: _en("Not necessarily. Many women with high-risk pregnancies "
            "have a normal delivery. How you deliver depends on the reason "
            "for the label and how you and your baby are doing near the end."),
      ),
      PvReadFaq(
        question: _en('Can the label be taken away?'),
        answer: _en("Sometimes. If a low placenta moves up or a worry on a scan "
            "clears, your doctor may go back to the usual schedule. Other "
            "reasons, like a past caesarean, stay for the whole pregnancy."),
      ),
      PvReadFaq(
        question: _en('Should I stop working?'),
        answer: _en("Most women don't need to. Ask your doctor what's safe for "
            "your job and your reason for the label. Some jobs with heavy "
            "lifting, long standing or night shifts may need changes."),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare, Pradhan Mantri '
        'Surakshit Matritva Abhiyan (PMSMA) guidelines · WHO recommendations '
        'on antenatal care for a positive pregnancy experience · FOGSI good '
        'clinical practice recommendations · Sources checked September 2026.'),

    readNext: ['preg_cond_read_bed_rest', 'preg_cond_read_bp_dangerous'],
  ),

  // ===========================================================================
  //  8. Told to rest — added 2026-09-29
  // ===========================================================================
  //  Gap analysis, Complications › Living with it, "Bed Rest During
  //  Pregnancy" (P2). Indian doctors still often advise rest and families take
  //  it very strictly. The piece explains what rest usually means and how to
  //  keep moving safely INSIDE the doctor's advice; it never tells her to
  //  ignore an instruction she has been given.
  PvRead(
    id: 'preg_cond_read_bed_rest',
    hue: _hue,
    kicker: _role,
    title: _en('Told to rest: what it usually means'),
    teaser: _en("What \"rest\" usually means, what to ask, and how to keep "
        "your body moving within your doctor's advice."),
    shortAnswer: _en("\"Rest\" rarely means lying in bed all day. Usually it "
        "means cutting down on heavy work, long standing and lifting, while "
        "still moving gently. Ask your doctor exactly what you can and can't "
        "do, and follow that rather than the strictest version."),

    scaleSetter: _en("Being told to rest often turns, at home, into not being "
        "allowed to do anything at all. That's usually not what your doctor "
        "meant. Strict bed rest is rarely advised now, because lying still "
        "for days has its own problems."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("\"Take rest\" is one of the most common things said in an "
              "Indian clinic. It's said for bleeding, for a low placenta, for "
              "blood pressure, for a short cervix, for twins, and sometimes "
              "just as kindness. At home, it can become weeks in bed while "
              "everyone else does everything."),
          _en("Resting less is not the answer either. The answer is knowing "
              "what your doctor meant, for your reason, and doing that. This "
              "piece helps you ask."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en("Your doctor's words come first"),
          body: _en("If your doctor has told you to stay in bed, follow that. "
              "This page is to help you understand and ask, not to change "
              "what you've been told."),
        ),
      ),

      PvReadSection(
        heading: _en('What does "rest" usually mean?'),
        paragraphs: [
          _en("Most of the time it means modified activity: doing less, not "
              "doing nothing. That often looks like this."),
        ],
        bullets: [
          _en('No heavy lifting, like full buckets, gas cylinders or a '
              'toddler on your hip.'),
          _en('Less time on your feet, with breaks to sit or lie down during '
              'the day.'),
          _en('No hard exercise, and sometimes no sex, until your doctor says '
              'so.'),
          _en('Short, gentle walks around the house are usually still fine.'),
          _en('Sitting work, like office work from home, is often fine too.'),
        ],
      ),

      PvReadSection(
        heading: _en("Why isn't strict bed rest used much any more?"),
        paragraphs: [
          _en("For most reasons it's given, studies haven't shown that lying "
              "in bed prevents early labour or loss. Meanwhile, lying still "
              "for days raises the chance of blood clots in the legs, weakens "
              "muscles and bones, and can leave you low and lonely."),
          _en("That's why many guidelines now advise against routine bed "
              "rest. Your doctor may still advise it for a particular reason, "
              "or for a short time, and that's their call to make for you."),
          _en("If you're resting for weeks, ask about gentle exercises you can "
              "do sitting or lying down, and whether you need anything to "
              "help prevent clots."),
        ],
      ),

      PvReadSection(
        heading: _en('What about housework, work and sex?'),
        paragraphs: [
          _en("Housework is where rest usually breaks down. Sweeping, mopping "
              "on your knees, carrying water and standing at the stove for "
              "long spells are the things to hand over first. Sitting to chop "
              "vegetables or fold clothes is often fine, if your doctor "
              "agrees."),
          _en("Work depends on your job. A desk job, or working from home, is "
              "often possible. A job with lifting, long standing or night "
              "shifts may need a break or lighter duties, and your doctor can "
              "write a note for your employer."),
          _en("Sex is sometimes paused, for example with bleeding, a low "
              "placenta or a short cervix. Ask directly. Doctors expect the "
              "question, and it's better to know than to guess."),
        ],
      ),

      PvReadSection(
        heading: _en('What should I ask my doctor?'),
        paragraphs: [
          _en("Short, specific questions get the clearest answers. You can "
              "ask your husband or mother-in-law to come in and hear them "
              "too, so the whole family follows the same plan."),
        ],
        bullets: [
          _en('Do you mean bed rest, or just less activity?'),
          _en('Can I walk around the house, use the toilet and bathe as '
              'usual?'),
          _en('Can I climb stairs, cook, or work from home?'),
          _en('Is sex okay?'),
          _en('How long is this for, and when will we review it?'),
        ],
      ),

      PvReadSection(
        heading: _en('How do I keep well while resting?'),
        paragraphs: [
          _en("If you're resting more than usual, a few small habits help "
              "your body. Check each with your doctor if you've been told to "
              "stay in bed."),
        ],
        bullets: [
          _en('Move your feet and ankles in circles, and point and flex them, '
              'several times an hour.'),
          _en('Drink plenty of water, and eat fibre to keep constipation '
              'away.'),
          _en('Change position often, and lie on your side rather than flat '
              'on your back later in pregnancy.'),
          _en('Keep your phone, water and things you need within reach.'),
          _en('Stay in touch with friends. A daily call helps more than it '
              'sounds.'),
        ],
        tip: PvReadTip(
          title: _en('When the family is stricter than the doctor'),
          body: _en("Well-meaning relatives may not let you walk to the "
              "kitchen. Show them what your doctor said, in writing if you "
              "can. It's easier for them to follow a plan than to argue with "
              "their worry."),
        ),
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en("One leg becomes swollen, red, hot or painful, you have "
          "chest pain or sudden breathlessness, or you have bleeding, fluid "
          "leaking, regular tightenings or your baby moving less than usual. "
          "Chest pain or sudden breathlessness means going to hospital "
          "straight away."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Will resting more save my pregnancy?'),
        answer: _en("For most reasons it's given, lying in bed hasn't been "
            "shown to prevent loss or early labour. What helps is the care "
            "your doctor has planned. Rest is part of that plan only where "
            "they say so."),
      ),
      PvReadFaq(
        question: _en("Can I go to work?"),
        answer: _en("Often yes, especially with a desk job, but ask. Your "
            "doctor can write a note for your employer if you need lighter "
            "duties or time off."),
      ),
      PvReadFaq(
        question: _en('Should I lie on my left side?'),
        answer: _en("Later in pregnancy, lying on either side is better than "
            "flat on your back for long. Left or right both work. Use a "
            "pillow between your knees if it helps."),
      ),
    ],

    evidence: _en('American College of Obstetricians and Gynecologists, '
        'committee opinions on activity restriction in pregnancy · Cochrane '
        'reviews of bed rest for preterm birth and for multiple pregnancy · '
        'Royal College of Obstetricians and Gynaecologists guidance on '
        'reducing the risk of blood clots in pregnancy · Sources checked '
        'September 2026.'),

    readNext: ['preg_cond_read_high_risk', 'preg_cond_read_disability'],
  ),

  // ===========================================================================
  //  9. Pregnancy with a disability or long-term illness — added 2026-09-29
  // ===========================================================================
  //  Gap analysis, Complications › Living with it, "How to Have a Healthy
  //  Pregnancy With a Physical Disability" (P3): "a short, practical page would
  //  show them the app is for them too." A first page, not a clinical guide:
  //  it points to her own team for every decision.
  PvRead(
    id: 'preg_cond_read_disability',
    hue: _hue,
    kicker: _role,
    title: _en('Pregnancy with a disability or long-term illness'),
    teaser: _en("Planning your care, being heard at appointments, and "
        "getting the support you need."),
    shortAnswer: _en("Many women with a disability or long-term illness have "
        "healthy pregnancies. Tell your doctor early what you need, bring your "
        "own specialist into the plan, and ask for support with appointments, "
        "birth and the weeks after. You know your body best, and your care "
        "should fit you."),

    scaleSetter: _en("Having a disability or a long-term illness doesn't "
        "decide whether you can have a healthy pregnancy. It changes some of "
        "the planning. You're the expert on your own body, and good care "
        "starts from that."),

    author: _desk,
    authorRole: _role,
    reviewed: false,

    sections: [
      PvReadSection(
        paragraphs: [
          _en("This page is for women who use a wheelchair or other aids, "
              "who have a hearing or sight impairment, or who live with a "
              "long-term illness like arthritis, a spinal injury, multiple "
              "sclerosis, a heart condition or lupus. Your situation is your "
              "own, and your doctors will plan around it."),
          _en("What's shared is the shape of good care: plan early, bring "
              "everyone who knows you into it, and say clearly what you "
              "need."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('This app is for you too'),
          body: _en("Everything else in ParentVeda applies to you. Where "
              "something doesn't fit, your doctor's plan for you comes "
              "first."),
        ),
      ),

      PvReadSection(
        heading: _en('Who should be part of my care?'),
        paragraphs: [
          _en("Your obstetrician leads the pregnancy. The specialist who "
              "already looks after your condition should stay involved, and "
              "the two should talk to each other. You may also meet a "
              "physiotherapist, an anaesthetist before the birth, and "
              "sometimes a counsellor."),
          _en("If you can, see your doctors before or very early in "
              "pregnancy. Some medicines need to be reviewed, and some plans, "
              "like how pain relief will work in labour, are easier to make "
              "early."),
          _en("If you see several doctors, ask one of them, often your "
              "obstetrician, to be the person who pulls the plan together. "
              "That way you're not the only one carrying it between clinics."),
        ],
        tip: PvReadTip(
          title: _en('Bring your medicines list'),
          body: _en("Take every tablet, injection and cream you use to your "
              "first visit. Never stop one on your own. Your doctors will "
              "decide together what to keep and what to change."),
        ),
      ),

      PvReadSection(
        heading: _en('How do I make appointments work for me?'),
        paragraphs: [
          _en("You have a right to care you can reach and understand. Under "
              "the Rights of Persons with Disabilities Act, 2016, hospitals "
              "should make reasonable changes so you can use their "
              "services."),
        ],
        bullets: [
          _en('Ask for a ground-floor room, a ramp or lift, or a height-'
              'adjustable examination table.'),
          _en('Ask for a sign language interpreter, written notes or large '
              'print if you need them.'),
          _en('Ask for a longer appointment if transfers or communication '
              'take time.'),
          _en('Bring someone you trust, if that helps you, and say whether '
              'you want the doctor to speak to you or to them.'),
        ],
      ),

      PvReadSection(
        heading: _en('What might change as my body changes?'),
        paragraphs: [
          _en("As your bump grows, your balance, breathing, bladder and "
              "movement may change, and so might your condition. Some "
              "conditions get better in pregnancy and some get harder. Tell "
              "your team about changes early, rather than waiting to see."),
          _en("If you use a wheelchair or have limited movement, ask about "
              "pressure care for your skin, preventing blood clots, bladder "
              "care, and how to move and transfer safely as your weight "
              "shifts. A physiotherapist can help with all of these."),
        ],
      ),

      PvReadSection(
        heading: _en('What support can I get?'),
        paragraphs: [
          _en("If you have a Unique Disability ID (UDID) card, keep a copy in "
              "your pregnancy file. It can help you get concessions and "
              "access to some services."),
          _en("Government schemes for pregnant women, like the Janani "
              "Suraksha Yojana and the Pradhan Mantri Matru Vandana Yojana, "
              "may apply to you as they do to other mothers. Ask your ASHA "
              "worker or your hospital which ones you can use."),
          _en("It's normal to feel tired of explaining yourself, or worried "
              "about how others see you as a mother. Talking to other "
              "disabled mothers, online or through a disability "
              "organisation, can help a lot. If worry or low mood is taking "
              "over, tell your doctor."),
        ],
      ),

      PvReadSection(
        heading: _en('How do I plan for the birth and after?'),
        collapsible: true,
        summary: _en("Plan the birth and the first weeks early, with the "
            "people who'll be there."),
        paragraphs: [
          _en("Ask to meet the team at the hospital where you'll deliver, "
              "and talk through your options for labour, pain relief and "
              "delivery. Many women with a disability have a normal delivery. "
              "Your doctor will explain what suits you."),
          _en("Think ahead about feeding, holding and changing your baby. "
              "Simple changes, like a changing table at the right height or "
              "a sling, can make a big difference. Ask who will help at home "
              "in the first weeks, and what support your hospital or local "
              "services offer."),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor the same day if'),
      body: _en("Your condition suddenly gets worse, you have new weakness, "
          "pain or breathlessness, or you have bleeding, fluid leaking, a bad "
          "headache or your baby is moving less than usual. If you're unsure "
          "whether a change is your condition or the pregnancy, call anyway."),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Will my baby have my condition?'),
        answer: _en("Many disabilities and long-term illnesses aren't passed "
            "on. Some can be. Ask your doctor, and if it's a question for "
            "you, ask about seeing a genetic counsellor."),
      ),
      PvReadFaq(
        question: _en('Can I have an epidural?'),
        answer: _en("Often yes, but it depends on your condition. Ask to see an "
            "anaesthetist before your due date so it's planned, not decided "
            "in a rush."),
      ),
      PvReadFaq(
        question: _en("What if someone doubts I can manage?"),
        answer: _en("You have the same right to a family and to good care as "
            "anyone else. If you feel you're not being heard, ask for a "
            "second opinion, or bring someone who can help you speak up."),
      ),
    ],

    evidence: _en('Rights of Persons with Disabilities Act, 2016 (India) · '
        'WHO recommendations on antenatal care for a positive pregnancy '
        'experience · Royal College of Obstetricians and Gynaecologists '
        'information on pregnancy with a physical disability · Sources '
        'checked September 2026.'),

    readNext: ['preg_cond_read_high_risk', 'preg_cond_read_bed_rest'],
  ),
];
