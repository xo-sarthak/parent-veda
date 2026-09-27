// =============================================================================
//  Body and cycle › Intimate health — the reads for this tab
// -----------------------------------------------------------------------------
//  Written 2026-09-26 for the TTC gap plan (docs/TTC-GAP-PLAN.md, stream A,
//  "Body and cycle › Intimate health", P2/P3). Forty-one competitor pieces
//  were sent to this tab; they cluster into six reads:
//
//    · discharge through the cycle, and the changes that need a doctor
//    · yeast infections and BV while trying
//    · urine infections (UTIs), plus leaking urine
//    · washing with water, not products (smell, liners, hair)
//    · itching, smells, bumps and bleeding after sex (ectropion lives here)
//    · infections passed on through sex, and testing before trying
//
//  ⚠️ THE SIXTH READ WAS NOT IN THE PLAN, AND IT IS HERE BECAUSE A P2 HAD
//  NOWHERE ELSE TO GO. "Why chlamydia often goes untreated" is the one piece in
//  the pack with a real fertility consequence (tubal damage), and none of the
//  four planned reads could hold it without turning into an STI read anyway.
//  The "Other conditions" tab's pelvic-infection read covers PID itself; this
//  one stops at "test before trying" and does not restate PID in depth.
//
//  ⚠️ NEVER A DIAGNOSIS. Every sign-to-cause line says "often" or "can be",
//  and every read ends by sending her for a swab or a urine test. The same
//  symptom comes from different infections, which is the argument against the
//  chemist's second tube, and the reads make that argument out loud.
//
//  ⚠️ "TELL THEM YOU'RE TRYING" IS THE MEDICINE RULE HERE, NOT A DOSE. Oral
//  fluconazole is usually avoided when she could be pregnant, so the reads say
//  that and route her to her doctor or chemist. No dosing is given anywhere.
//
//  The rules these are written under are stated once, in the aggregator's
//  header. Read that before adding one.
// =============================================================================

import '../../localization/app_language.dart';
import '../../models/pv_read.dart';

// ⚠️ PRIVATE AND DUPLICATED PER FILE, ON PURPOSE — see ttc_reads_conceiving.dart.
LocalizedText _en(String s) => LocalizedText(en: s, hi: s);

final List<PvRead> kTtcReadsBodyIntimate = [
  // ===========================================================================
  //  1. Discharge through the cycle
  // ===========================================================================
  PvRead(
    id: 'ttc_read_discharge_guide',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Is my discharge normal? What each kind means, and when to see '
        'a doctor'),
    teaser: _en("What healthy discharge looks like through your cycle, and the "
        "few changes that mean it's time to see a doctor."),
    shortAnswer: _en("Clear, white or creamy discharge that changes through the "
        "month is normal and healthy. It gets wetter and stretchier before "
        "ovulation, which is a good sign when you're trying. See a doctor if "
        "it turns green, grey or frothy, smells fishy or bad, or comes with "
        "itching, soreness or pain."),
    scaleSetter: _en("Most discharge is normal. Nearly every woman has some on "
        "most days, and it changes on purpose through the month. The changes "
        "that point to an infection are fairly easy to spot, and the "
        "infections behind them are common and easy to treat."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Discharge is the fluid your vagina and cervix make to keep the "
              "area moist and protected. Healthy discharge is one of the ways "
              "your body keeps infections out."),
          _en("When you're trying, it's also useful. The kind of discharge you "
              "see changes with your hormones, so it can show you when "
              "ovulation is getting close."),
          _en("Many women in India grow up hearing that white discharge drains "
              "your strength or causes back pain and tiredness. It doesn't. "
              "Normal discharge is a sign of a working body, not a loss of "
              "anything."),
        ],
      ),
      PvReadSection(
        heading: _en('What does normal discharge look like through the month?'),
        paragraphs: [
          _en("Here's the usual pattern in one cycle. Yours may not match it "
              "exactly, and that's fine."),
        ],
        bullets: [
          _en('Just after your period: little or none. You may feel dry for a '
              'few days.'),
          _en("The days after that: a small amount that's sticky, pasty or "
              "crumbly, often white or cloudy."),
          _en('Getting closer to ovulation: more of it, creamier and wetter, '
              'a bit like lotion.'),
          _en('Your most fertile days: clear, slippery and stretchy, a lot like '
              'raw egg white. You may feel wet down there.'),
          _en("After ovulation: it turns thick, tacky or dry again, and there's "
              "less of it until your next period."),
        ],
      ),
      PvReadSection(
        heading: _en('What does fertile discharge look like?'),
        paragraphs: [
          _en("Clear, stretchy discharge is the sign your fertile days are "
              "here. It helps sperm swim up through the cervix and keeps them "
              "alive for several days. If you see it, that's a good time to "
              "have sex."),
        ],
        tip: PvReadTip(
          title: _en('Noticing it without fuss'),
          body: _en("Look at the tissue when you wipe, or notice how your "
              "underwear feels. You don't need to put fingers inside. A quick "
              "note in your cycle log for two or three months shows your own "
              "pattern."),
        ),
      ),
      PvReadSection(
        heading: _en('Is heavy or white discharge normal?'),
        paragraphs: [
          _en("Often, yes. The amount varies a lot between women and from week "
              "to week. Some women want to change their underwear in the middle "
              "of the day around ovulation, and that's still normal."),
          _en("White or milky discharge is normal at many points in the month, "
              "especially before ovulation and before your period. If it has no "
              "strong smell and doesn't itch, it's usually just your body at "
              "work."),
          _en("Discharge also increases in early pregnancy, with some "
              "medicines, and when you start or stop hormones. More of it, on "
              "its own, isn't a warning sign."),
        ],
      ),
      PvReadSection(
        heading: _en('What about yellow or brown discharge?'),
        paragraphs: [
          _en("Normal discharge can leave a pale yellow mark on underwear as "
              "it dries. Yellow that's darker or greener, or comes with a "
              "smell, is different, and it's worth a check."),
          _en("Brown discharge at the very start or end of a period is usually "
              "old blood, and it's normal. Light spotting around ovulation "
              "happens to some women too."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I tell arousal fluid or semen from fertile '
            'discharge?'),
        paragraphs: [
          _en("Being aroused makes the vagina wet with a clear, slippery fluid. "
              "It can look like fertile discharge, but it comes on with arousal "
              "and dries up within an hour or so."),
          _en("Semen can look similar too, and it can leak out for several "
              "hours after sex. That's normal, and it doesn't mean the sperm "
              "didn't make it. The sperm that matter reach the cervix within "
              "minutes."),
          _en("So if you're checking for fertile signs, look at a time when you "
              "haven't had sex for a while and aren't aroused. During the day "
              "works for most women."),
        ],
      ),
      PvReadSection(
        heading: _en('What changes could mean an infection?'),
        paragraphs: [
          _en("These are the signs worth a doctor's check. They can't tell you "
              "which infection it is. A simple swab or test can."),
        ],
        bullets: [
          _en('Thick, white and lumpy, like curd or paneer, with itching or '
              'soreness. This is often a yeast infection.'),
          _en("Thin, grey or watery white, with a fishy smell that's stronger "
              "after sex or your period. This is often bacterial vaginosis "
              "(BV)."),
          _en('Yellow or green and frothy, with a smell and soreness. This can '
              'be trichomoniasis, an infection passed on through sex.'),
          _en('Yellow or green with pain low in your belly, bleeding between '
              'periods or pain during sex. This can be chlamydia or '
              'gonorrhoea.'),
          _en('A strong, bad smell that came on suddenly. Sometimes a forgotten '
              'tampon, cup or piece of condom is the cause.'),
          _en("Pink or brown discharge that isn't just before or after your "
              "period, or that keeps coming back after sex."),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Treatable, and worth treating'),
          body: _en("Most of these infections clear with a short course of "
              "medicine. Treating them before you conceive helps your comfort "
              "now and, for some, protects your tubes and a future "
              "pregnancy."),
        ),
      ),
      PvReadSection(
        heading: _en('Why do these infections matter when I\'m trying?'),
        paragraphs: [
          _en("Yeast infections and BV don't damage your fertility, but they "
              "can make sex sore, which is hard when timing matters. BV is also "
              "worth clearing because in pregnancy it's linked with the baby "
              "coming early."),
          _en("Chlamydia and gonorrhoea are different. They often cause no "
              "symptoms, and left untreated they can spread up to the womb and "
              "tubes. Scarring there is one known cause of trouble getting "
              "pregnant."),
          _en("That's why a doctor's check is better than a guess from the "
              "chemist. The same symptom can come from different infections, "
              "and each one needs its own treatment."),
        ],
      ),
      PvReadSection(
        heading: _en('What happens when I see a doctor about it?'),
        paragraphs: [
          _en("A gynaecologist sees discharge problems every day, and you won't "
              "shock them. Many women in India put off this visit for months "
              "because it feels embarrassing, and live with itching or worry "
              "they didn't need to."),
          _en("Usually the doctor asks a few questions, looks, and may take a "
              "gentle swab from the vagina. Sometimes a urine test is enough. "
              "It's quick and shouldn't hurt. You can ask for a woman doctor, "
              "or for a woman to be in the room."),
          _en("If you can, don't wash inside, use a vaginal cream or have sex "
              "for a day before the visit. These can hide what the swab needs "
              "to find."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is it normal to have discharge every day?'),
        answer: _en("Yes. Most women have some discharge on most days. Having "
            "none for a few days after your period is normal too."),
      ),
      PvReadFaq(
        question: _en('Does white discharge make you weak?'),
        answer: _en("No. Discharge is fluid your body makes all the time, and it "
            "doesn't take away your strength or cause back pain. If you feel "
            "tired or achy, it's worth seeing a doctor for other reasons, such "
            "as low iron."),
      ),
      PvReadFaq(
        question: _en("I never see stretchy, egg-white discharge. Does that mean "
            "I don't ovulate?"),
        answer: _en("Not necessarily. Some women make only a little, or it's "
            "wetter rather than stretchy. If your periods come regularly, every "
            "21 to 35 days, you're most likely ovulating. Ovulation strips or a "
            "blood test from your doctor can confirm it."),
      ),
      PvReadFaq(
        question: _en('Can my husband give me an infection that causes '
            'discharge?'),
        answer: _en("Some, yes, like trichomoniasis and chlamydia. Yeast and BV "
            "aren't passed on in the same way. Your doctor will tell you if he "
            "needs treatment too."),
      ),
      PvReadFaq(
        question: _en('Should I wear a panty liner every day for discharge?'),
        answer: _en("On heavy days, if you like, but try not to every day. "
            "Liners can trap heat and moisture, which irritates some women's "
            "skin. Plain cotton underwear, changed daily, is usually enough."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("Book a visit within a few days if your discharge turns grey, "
          "green or yellow-green, becomes frothy or lumpy, smells fishy or bad, "
          "or comes with itching, burning or soreness. See a doctor the same "
          "day if discharge comes with a fever, pain low in your belly, or new "
          "pain during sex. Bleeding between periods or after sex needs a "
          "check within a week or two."),
    ),
    evidence: _en('Normal discharge through the cycle follows Cleveland Clinic '
        'and StatPearls/NCBI, "Vaginal Discharge". Signs of infection follow '
        'NHS guidance on vaginal discharge, the CDC Sexually Transmitted '
        'Infections Treatment Guidelines 2021, and the WHO guidelines on the '
        'management of symptomatic sexually transmitted infections (2021). '
        'Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Note your discharge in your cycle log'),
        value: _en('Two or three months of notes show your own pattern and '
            'your fertile days.'),
        surfaceId: 'ttc_cycle',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan a doctor\'s visit'),
        value: _en('Keep the date and the questions you want to ask in one '
            'place.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: ['ttc_read_yeast_bv', 'ttc_read_sti_testing'],
  ),

  // ===========================================================================
  //  2. Yeast infections and BV
  // ===========================================================================
  PvRead(
    id: 'ttc_read_yeast_bv',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Yeast infections and BV while trying: what they are and '
        'what\'s safe'),
    teaser: _en('The two most common reasons for itching, odd discharge or a '
        "smell, and how to get them treated safely while you're trying."),
    shortAnswer: _en("A yeast infection or BV won't stop you getting pregnant, "
        "and both are easy to treat. Tell your doctor or chemist you're "
        "trying, because some tablets are best avoided if you could already be "
        "pregnant. If it keeps coming back, get a swab test rather than another "
        "box from the chemist."),
    scaleSetter: _en("These are two of the commonest things a gynaecologist "
        "treats. Most women have at least one yeast infection in their life, "
        "and BV is the most common cause of unusual discharge in women your "
        "age. Neither harms your fertility, and both usually clear within a "
        "week of treatment."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Itching, soreness or a new smell down there can make you "
              "anxious, especially when you want everything to be right for "
              "trying. Most of the time the cause is one of these two, and "
              "neither is serious."),
          _en("They're different conditions with different treatments, so it "
              "helps to know which is which. But the signs overlap, and only a "
              "test tells them apart for sure."),
        ],
      ),
      PvReadSection(
        heading: _en('What is a yeast infection?'),
        paragraphs: [
          _en("Yeast, called candida, lives in most women's vaginas without "
              "causing trouble. An infection happens when it overgrows. It "
              "isn't caused by being unclean, and it isn't usually passed on "
              "through sex."),
          _en("It often shows up as itching and soreness around the vagina, "
              "thick white discharge like curd, burning when you pee, and pain "
              "during sex. It usually doesn't smell much."),
          _en("It's more likely after a course of antibiotics, with high blood "
              "sugar, in pregnancy, in hot and humid weather, and in tight or "
              "synthetic clothes that stay damp. Indian summers and the monsoon "
              "are hard on this."),
        ],
      ),
      PvReadSection(
        heading: _en('What is BV?'),
        paragraphs: [
          _en("BV, or bacterial vaginosis, happens when the balance of bacteria "
              "in the vagina changes. The helpful bacteria that keep it "
              "slightly acidic drop, and other bacteria grow in their place."),
          _en("The main sign is thin grey or white discharge with a fishy "
              "smell, often stronger after sex or during your period. It "
              "usually doesn't itch. About half of women with BV notice no "
              "symptoms at all."),
          _en("BV isn't counted as an infection passed on through sex, but it's "
              "more common in women who are sexually active. Washing inside the "
              "vagina, scented washes and a new partner all make it more "
              "likely."),
        ],
      ),
      PvReadSection(
        heading: _en('Can I get pregnant with a yeast infection or BV?'),
        paragraphs: [
          _en("Yes. Neither one stops sperm reaching the egg, and there's no "
              "good evidence that either causes infertility. The problem is "
              "usually comfort. Sex can feel sore, and that's hard in your "
              "fertile week."),
          _en("It's fine to wait a few days until treatment is done and the "
              "soreness settles. If your fertile days fall in that time, you "
              "can still have sex if it doesn't hurt. Missing one month isn't "
              "a failure."),
          _en("BV is worth treating before pregnancy for one more reason. In "
              "pregnancy, BV is linked with a higher risk of the baby coming "
              "early, so doctors like to clear it when it causes symptoms."),
        ],
      ),
      PvReadSection(
        heading: _en('Which treatments are safe while trying?'),
        paragraphs: [
          _en("Yeast infections are treated with an antifungal. This is a "
              "cream, a pessary (a small tablet you put into the vagina), or a "
              "single tablet you swallow, called fluconazole."),
          _en("Fluconazole tablets are usually avoided if you could be "
              "pregnant. In the second half of your cycle you might be, even "
              "before a test can tell. So tell the doctor or chemist you're "
              "trying. A cream or pessary is the usual choice then."),
          _en("BV is treated with an antibiotic, most often metronidazole as "
              "tablets or a gel, or clindamycin as a cream. Doctors do use these "
              "in pregnancy when needed, but they still want to know you're "
              "trying."),
          _en("Finish the full course, even if you feel better in two days. "
              "Stopping early is one reason these come back."),
        ],
        tip: PvReadTip(
          title: _en('Buying from the chemist'),
          body: _en("Many of these can be bought over the counter in India. "
              "That's reasonable for a yeast infection you've had diagnosed "
              "before and recognise. If it's your first time, or it hasn't "
              "cleared in a week, see a doctor so you're not treating the "
              "wrong thing."),
        ),
      ),
      PvReadSection(
        heading: _en('Why does it keep coming back?'),
        paragraphs: [
          _en("Some women get yeast infections or BV again and again. For "
              "yeast, doctors call it recurrent when it happens four or more "
              "times in a year. It's common and frustrating, and it isn't your "
              "fault."),
          _en("Often the real problem is that yeast was never the cause. Yeast, "
              "BV, trichomoniasis and irritated skin can feel alike, so another "
              "tube from the chemist may miss what's going on."),
          _en("A doctor can take a swab to confirm what it is. Some types of "
              "yeast don't respond to the usual medicine and need a different "
              "one. Your doctor may also check your blood sugar, because high "
              "sugar feeds yeast."),
          _en("For repeated infections, a longer treatment plan over a few "
              "months often works. Your doctor will fit it around your plans "
              "to get pregnant."),
        ],
        mythFact: PvMythFact(
          myth: _en('Yeast that keeps coming back means it has spread through '
              'my whole body, and I need a special diet.'),
          fact: _en("There's no good evidence for this. Repeat infections are "
              "about the vagina itself, or a different cause being treated as "
              "yeast. A swab and the right treatment help far more than "
              "cutting out foods."),
        ),
      ),
      PvReadSection(
        heading: _en('What helps stop them coming back?'),
        bullets: [
          _en('Wash the outside with plain water. Skip scented washes, sprays '
              'and wipes.'),
          _en("Don't wash inside the vagina. It clears out the helpful "
              "bacteria."),
          _en('Wear cotton underwear, and change out of sweaty or damp clothes '
              'soon.'),
          _en('Take antibiotics only when a doctor prescribes them.'),
          _en('If you have diabetes or PCOS, keeping your blood sugar steady '
              'helps.'),
          _en('Skip talc, sprays and perfumed pads, which can irritate the '
              'skin and make itching worse.'),
        ],
        paragraphs: [
          _en("If you often get a yeast infection after a course of "
              "antibiotics, tell the doctor who prescribes them. They may "
              "suggest a treatment to take alongside, so the yeast doesn't get "
              "a chance to overgrow."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Does my husband need treatment too?'),
        answer: _en("For yeast and BV, usually not, unless he has symptoms such "
            "as a red, itchy rash on the penis. For trichomoniasis and "
            "chlamydia, you both need treatment, which is another reason to get "
            "a test."),
      ),
      PvReadFaq(
        question: _en('Is it safe to use the cream during my fertile days?'),
        answer: _en("Vaginal antifungal creams and pessaries are considered safe "
            "in pregnancy, so using one while trying is fine. The bigger issue "
            "is soreness. If sex hurts, it's okay to wait until you've healed. "
            "There will be another window."),
      ),
      PvReadFaq(
        question: _en('Will eating curd or taking probiotics help?'),
        answer: _en("Some women feel they help, and they're safe to try. The "
            "research is mixed, though, so they don't replace treatment when "
            "you have symptoms."),
      ),
      PvReadFaq(
        question: _en('Can a yeast infection confuse my fertile signs?'),
        answer: _en("Yes. Its thick discharge can hide your usual pattern for a "
            "while. Once it's treated, your normal pattern comes back. "
            "Ovulation strips aren't affected by it."),
      ),
      PvReadFaq(
        question: _en('Is BV caused by someone not being clean?'),
        answer: _en("No. BV is about the balance of bacteria inside the vagina, "
            "not about anyone being unclean. It's more common with sex, but it "
            "isn't anyone's fault."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor within a few days if this is your first time "
          "with these symptoms, if a chemist treatment hasn't helped within a "
          "week, or if it's come back four or more times in a year. Go the same "
          "day if you have a fever, pain low in your belly, sores or blisters, "
          "or bleeding you can't explain. If your period is late or you've had "
          "a positive test, see a doctor before using any treatment."),
    ),
    evidence: _en('CDC Sexually Transmitted Infections Treatment Guidelines '
        '2021 (vulvovaginal candidiasis and bacterial vaginosis); NHS guidance '
        'on thrush, bacterial vaginosis and fluconazole; ACOG patient FAQ '
        '"Vaginitis"; StatPearls/NCBI, "Vulvovaginal Candidiasis" and '
        '"Bacterial Vaginosis". Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Check a medicine'),
        value: _en("See what's usually fine while trying, and what to ask about "
            "first."),
        surfaceId: 'ttc_can_i',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan a doctor\'s visit'),
        value: _en('Note your symptoms and questions so the visit is quick.'),
        surfaceId: 'ttc_appointments',
      ),
    ],
    readNext: ['ttc_read_intimate_washing', 'ttc_read_discharge_guide'],
  ),

  // ===========================================================================
  //  3. Urine infections (UTIs), and leaking urine
  // ===========================================================================
  PvRead(
    id: 'ttc_read_uti_trying',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Urine infections (UTIs) while trying: why sex brings them on, '
        'and what to do'),
    teaser: _en('Why burning when you pee often follows a busy week of sex, how '
        "to prevent it, and which treatment is safe while you're trying."),
    shortAnswer: _en("More sex means more times that germs can reach your "
        "bladder, so UTIs are common when you're trying. Peeing after sex and drinking "
        "enough water help prevent them. If you have burning or keep needing "
        "to pee, see a doctor for a urine test and an antibiotic, and tell "
        "them you're trying."),
    scaleSetter: _en("A UTI is uncomfortable but usually simple. It's one of "
        "the most common infections women get, and a short course of "
        "antibiotics clears most within a few days. It won't affect your "
        "fertility. The one thing to watch for is an infection spreading to "
        "the kidneys, and the signs of that are clear."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("A urine infection, or UTI, is when germs get into the urinary "
              "tract. Most often it's the bladder, and doctors call that "
              "cystitis. The germs are usually ones that live harmlessly in the "
              "bowel."),
          _en("Women get UTIs far more than men. The tube from the bladder to "
              "the outside, the urethra, is short in women. It's also close to "
              "the vagina and back passage, so germs don't have far to go."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do UTIs happen after sex?'),
        paragraphs: [
          _en("During sex, movement pushes germs from the skin around the "
              "vagina toward the opening of the urethra. From there, some can "
              "travel up into the bladder."),
          _en("So when sex becomes more frequent, as it often does when you're "
              "trying, UTIs can become more common too. It happens so often to "
              "newly married women that doctors have long called it honeymoon "
              "cystitis."),
          _en("It isn't a sign that anything is wrong with you or your "
              "partner. The germs are usually your own, and sex only moves "
              "them."),
        ],
      ),
      PvReadSection(
        heading: _en('How do I know it\'s a UTI?'),
        bullets: [
          _en('Burning or stinging when you pee'),
          _en('Needing to pee often and urgently, but only a little comes out'),
          _en('Cloudy, dark or strong-smelling urine'),
          _en('Pain or pressure low in your belly'),
          _en('Blood in your urine'),
          _en('Feeling generally unwell, tired or achy'),
        ],
        paragraphs: [
          _en("Burning when you pee can also come from a yeast infection or an "
              "infection passed on through sex, when urine stings sore skin on "
              "the outside. That's one reason a test is better than a guess."),
        ],
      ),
      PvReadSection(
        heading: _en('How is a UTI confirmed?'),
        paragraphs: [
          _en("Your doctor will ask about your symptoms and usually test a "
              "urine sample. A dipstick test gives an answer in minutes. A "
              "urine culture, sent to a lab, shows which germ it is and which "
              "antibiotic will work. It takes two to three days."),
          _en("For the sample, pass a little urine into the toilet first, then "
              "catch the middle part in the clean container. This keeps germs "
              "from your skin out of the result."),
          _en("In India, a urine routine test and a urine culture are easy to "
              "get at most labs, usually for a few hundred rupees each. Try to "
              "give the sample before you start any antibiotic."),
          _en("If you've had two UTIs in six months, or three in a year, your "
              "doctor may look for a cause. This might mean a scan or a check "
              "of your blood sugar."),
        ],
      ),
      PvReadSection(
        heading: _en('Which antibiotics are safe while trying?'),
        paragraphs: [
          _en("Many antibiotics used for UTIs are also used in pregnancy. Tell "
              "your doctor you're trying, and they'll choose one that suits. "
              "Finish the whole course, even once you feel better."),
          _en("Please don't take leftover antibiotics, or buy them from the "
              "chemist without a prescription. It's common in India, but the "
              "wrong antibiotic may not work, and it helps germs become "
              "resistant to medicines."),
          _en("A UTI won't stop you getting pregnant. If you get one in your "
              "fertile week, you can still have sex if it's comfortable. Many "
              "women prefer to wait a day or two until the burning settles."),
        ],
      ),
      PvReadSection(
        heading: _en('How can I stop UTIs coming back?'),
        bullets: [
          _en("Pee soon after sex. The research on this is limited, but it's "
              "easy and harmless."),
          _en('Drink enough water through the day that your urine stays pale.'),
          _en("Don't hold in your pee for hours, including at work or when "
              "travelling."),
          _en('Wipe from front to back after using the toilet.'),
          _en('Skip scented washes, powders and sprays around the vagina.'),
        ],
        paragraphs: [
          _en("If UTIs keep following sex despite all this, talk to your "
              "doctor. There are other options, such as a single antibiotic "
              "dose taken after sex. Your doctor will weigh up whether one "
              "suits you while you're trying."),
          _en("Cranberry juice and D-mannose are popular. The evidence for them "
              "is mixed, and they don't treat an infection you already have. "
              "Ask your doctor before starting any supplement while trying."),
        ],
        mythFact: PvMythFact(
          myth: _en('If I get up to pee after sex, the sperm will come out.'),
          fact: _en("Sperm swim into the cervix within minutes, and urine comes "
              "out of a different opening. Some fluid leaking out is normal. "
              "Peeing after sex is fine, and it helps prevent UTIs."),
        ),
      ),
      PvReadSection(
        heading: _en('What if I leak urine when I cough or sneeze?'),
        paragraphs: [
          _en("Some women leak a little urine when they cough, sneeze, laugh "
              "or lift something. This is called stress incontinence. It's "
              "usually about a weak pelvic floor, the muscles that hold up your "
              "bladder and womb."),
          _en("It's common, even in women who've never been pregnant, and it "
              "isn't an infection. Daily pelvic floor exercises for at least "
              "three months help many women. A physiotherapist can check you're "
              "doing them the right way."),
          _en("A strong pelvic floor is also good preparation for pregnancy, "
              "which puts extra weight on these muscles. If you often need to "
              "rush to the toilet without an infection, tell your doctor. That "
              "can be treated too."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can a UTI affect my fertility?'),
        answer: _en("No. A bladder infection doesn't reach your womb, tubes or "
            "ovaries. Once it's treated, it has no lasting effect on trying."),
      ),
      PvReadFaq(
        question: _en('Did my husband give me the UTI?'),
        answer: _en("Not in the way people usually mean. The germs are usually "
            "your own, from the skin near your back passage. Sex moves them "
            "about, but he isn't passing on an infection."),
      ),
      PvReadFaq(
        question: _en('Is a UTI more serious if I\'m pregnant?'),
        answer: _en("It needs treating promptly, because in pregnancy it can "
            "spread to the kidneys more easily. If your period is late or "
            "you've had a positive test, tell your doctor."),
      ),
      PvReadFaq(
        question: _en('Should I drink lots of water to flush it out instead of '
            'taking antibiotics?'),
        answer: _en("Water helps you feel better, and a very mild UTI sometimes "
            "clears on its own. But if you're trying, or it's not easing in a "
            "day or two, see a doctor. An untreated UTI can reach the "
            "kidneys."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor within a day or two if you have burning, "
          "urgency or blood in your urine, or if you're no better 48 hours "
          "after starting antibiotics. Go the same day, or to hospital, if you "
          "have a fever, shivering, pain in your back or side just under the "
          "ribs, or vomiting. These can mean a kidney infection. If you might "
          "be pregnant, see a doctor for any urine symptoms rather than "
          "waiting."),
    ),
    evidence: _en('NICE guidelines NG109 (lower urinary tract infection: '
        'antimicrobial prescribing), NG112 (recurrent urinary tract infection) '
        'and NG123 (urinary incontinence and pelvic organ prolapse in women); '
        'NHS guidance on cystitis and urinary tract infections; StatPearls/NCBI, '
        '"Urinary Tract Infection"; ICMR Treatment Guidelines for Antimicrobial '
        'Use in Common Syndromes. Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Check a medicine'),
        value: _en("See what's usually fine while trying, and what to ask about "
            "first."),
        surfaceId: 'ttc_can_i',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Keep your test results together'),
        value: _en('A urine culture report is useful the next time a doctor '
            'asks.'),
        surfaceId: 'ttc_records',
      ),
    ],
    readNext: ['ttc_read_intimate_washing', 'ttc_read_yeast_bv'],
  ),

  // ===========================================================================
  //  4. Keeping clean: water, not products
  // ===========================================================================
  PvRead(
    id: 'ttc_read_intimate_washing',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('How to clean down there: water, not products'),
    teaser: _en('What your vagina does for itself, how to wash the outside, '
        "and why the washes, wipes and sprays at the chemist aren't needed."),
    shortAnswer: _en("Your vagina cleans itself, so you only need to wash the "
        "outside, the vulva, with plain water once a day. Scented washes, "
        "wipes, sprays and washing inside can upset the natural balance and "
        "make infections more likely. A mild smell of your own is normal."),
    scaleSetter: _en("There's nothing you need to buy here. If you've been "
        "using intimate washes, you haven't harmed anything, and there's no "
        "need to worry. Switching to plain water is all it takes."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("Adverts tell women they need a special wash to feel fresh and "
              "confident down there, and the shelves at the chemist are full of "
              "them. It's easy to believe you're doing something wrong if you "
              "don't use one."),
          _en("Gynaecologists say the opposite. The less you put on this skin, "
              "the healthier it tends to be."),
        ],
      ),
      PvReadSection(
        heading: _en('Does the vagina clean itself?'),
        paragraphs: [
          _en("Yes. The vagina is the passage inside, and it keeps itself "
              "clean. Its discharge carries old cells and germs out. Helpful "
              "bacteria called lactobacilli keep it slightly acidic, and that "
              "acid stops harmful germs from growing."),
          _en("The vulva is the outside part: the lips, the skin around the "
              "opening, and the area with hair. This is the only part that "
              "needs washing."),
          _en("The balance inside shifts a little with your period, with sex "
              "and in pregnancy. It usually settles again on its own, without "
              "anything from a bottle."),
        ],
      ),
      PvReadSection(
        heading: _en('Should I wash inside?'),
        paragraphs: [
          _en("No. Washing inside, called douching, rinses away the helpful "
              "bacteria. It's linked with more BV and with infections that "
              "travel up to the womb and tubes. It doesn't help you get "
              "pregnant, and there's no need for it before or after sex."),
        ],
      ),
      PvReadSection(
        heading: _en('How should I wash?'),
        bullets: [
          _en('Once a day is enough. Use warm water, not hot, and your hand. '
              'Hot water dries out this skin.'),
          _en("Gently part the outer lips and rinse the folds. Don't push water "
              "or anything else inside."),
          _en('If you like soap, use a mild, unscented one on the outer, hairy '
              'area only, and rinse it off well.'),
          _en('Pat dry with a soft, clean towel, or let the area dry in the '
              'air.'),
          _en('After the toilet, wipe or wash from front to back, so germs from '
              'the back passage stay away.'),
          _en('If you use a toilet jet spray, keep the pressure gentle and aim '
              'it at the outside only.'),
        ],
        tip: PvReadTip(
          title: _en('During your period'),
          body: _en("Change pads every four to six hours, or sooner on heavy "
              "days, and rinse with water when you change. A cup or tampon is "
              "fine too, as long as you empty or change it as the pack "
              "says."),
        ),
      ),
      PvReadSection(
        heading: _en('Are intimate washes, wipes and sprays bad for me?'),
        paragraphs: [
          _en("They aren't needed, and for some women they cause trouble. "
              "Perfume and other chemicals can irritate the thin skin of the "
              "vulva. The itching and redness that follow are easy to mistake "
              "for an infection."),
          _en("Some washes say they're pH balanced. Your vagina already keeps "
              "its own balance, so there's nothing for a wash to fix. If you "
              "like using one, choose an unscented one and use it on the "
              "outside only."),
          _en("Skip talc, deodorants, scented wipes and perfumed pads. Don't "
              "add antiseptic liquid to your bath water either. It's too harsh "
              "for this skin."),
        ],
        mythFact: PvMythFact(
          myth: _en('A good wash inside after sex keeps you clean and healthy.'),
          fact: _en("Your vagina clears itself. Washing inside removes the "
              "helpful bacteria and makes BV more likely. Rinse the outside "
              "with water if you like, and that's all."),
        ),
      ),
      PvReadSection(
        heading: _en('What smell is normal?'),
        paragraphs: [
          _en("Every woman has her own smell, and a healthy vagina isn't meant "
              "to smell of nothing. A mild musky or slightly sour smell is "
              "normal."),
          _en("It changes through the month too. It can be stronger after "
              "exercise, a little metallic around your period, and different "
              "for a few hours after sex, because semen shifts the balance for "
              "a while."),
          _en("A fishy smell, a strong bad smell, or any smell with itching, "
              "soreness or unusual discharge is different. That's a reason to "
              "see a doctor, not to wash more."),
        ],
      ),
      PvReadSection(
        heading: _en('What about underwear, liners and hair?'),
        paragraphs: [
          _en("Cotton underwear lets the skin breathe. Change it every day. "
              "Change out of sweaty gym clothes or wet clothes soon, especially "
              "in summer and the monsoon."),
          _en("Loose cotton at night, or no underwear at all, gives the skin a "
              "rest. Some women who get repeated itching find this helps."),
          _en("Panty liners are fine now and then, like at the end of a period. "
              "Wearing one every day can trap heat and moisture and irritate "
              "the skin. If you use them, pick unscented ones and change them "
              "often."),
          _en("Removing pubic hair is your choice, and it doesn't make you "
              "cleaner. Hair protects the skin. Shaving and waxing can cause "
              "small bumps and ingrown hairs, so be gentle and use a clean "
              "razor."),
          _en("If you need a lubricant, look for one labelled sperm-friendly. "
              "Some ordinary lubricants can slow sperm down."),
        ],
      ),
      PvReadSection(
        heading: _en('What about whitening creams, steaming and tightening '
            'gels?'),
        paragraphs: [
          _en("Some products sold in India promise to lighten, tighten or "
              "perfume the area. For many women the skin of the vulva is "
              "naturally darker than the rest of the body. That's normal, and "
              "nothing needs fixing."),
          _en("These creams and gels aren't needed, and some contain "
              "ingredients that sting or burn this thin skin. Vaginal steaming "
              "isn't recommended either. The steam can scald, and it can upset "
              "the balance inside."),
          _en("If something about how you look or feel down there worries you, "
              "a gynaecologist can talk it through. It's a normal thing to "
              "ask."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Is plain water enough even during my period?'),
        answer: _en("Yes. Water is enough during your period too. You may want "
            "to rinse more often, each time you change a pad."),
      ),
      PvReadFaq(
        question: _en('My mother taught me to wash inside. Was that wrong?'),
        answer: _en("She wanted to keep you healthy, and many women were taught "
            "the same. What doctors know now is that the inside cleans itself. "
            "Rinsing the outside is enough."),
      ),
      PvReadFaq(
        question: _en('Should I wash after sex?'),
        answer: _en("You don't need to. If you'd like to, rinse the outside with "
            "water. Peeing after sex helps prevent urine infections, and it "
            "won't wash away sperm."),
      ),
      PvReadFaq(
        question: _en('Is it normal to have a smell even after washing?'),
        answer: _en("Yes. A mild smell of your own is normal and healthy. If "
            "the smell is fishy, strong or new, see a doctor rather than "
            "washing more."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor within a few days if itching, soreness, redness "
          "or swelling doesn't settle after a week of plain water, or if you "
          "notice a fishy or strong smell. Go within a day or two if there are "
          "sores, blisters or a painful lump. Go the same day if you have "
          "discharge with a fever or belly pain. If a product caused a "
          "reaction, stop it and tell your doctor what you used."),
    ),
    evidence: _en('NHS guidance "Keeping your vagina clean and healthy"; ACOG '
        'patient FAQs on vulvovaginal health and on douching; Cleveland Clinic '
        'on vaginal pH and vaginal odour; StatPearls/NCBI, "Bacterial '
        'Vaginosis", on douching as a risk factor. Sources checked September '
        '2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.product,
        title: _en('See what\'s worth buying'),
        value: _en("A short list of what helps when you're trying, and nothing "
            "you don't need."),
        surfaceId: 'ttc_products',
      ),
    ],
    readNext: ['ttc_read_intimate_worries', 'ttc_read_yeast_bv'],
  ),

  // ===========================================================================
  //  5. Itching, smells, bumps and bleeding after sex
  // ===========================================================================
  PvRead(
    id: 'ttc_read_intimate_worries',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Itching, smells, bumps and bleeding after sex: what\'s common '
        'and what needs a doctor'),
    teaser: _en('The worries many women keep to themselves, with the usual '
        'causes and the signs that mean a visit.'),
    shortAnswer: _en("Most itching, odd smells and small bumps down there come "
        "from common things like irritated skin, yeast, BV or shaving, and "
        "they're easy to sort out. Bleeding after sex is often from a harmless "
        "patch on the cervix, but it always deserves a check. See a doctor if "
        "something is new, doesn't settle in a week, or comes with pain, sores "
        "or bleeding."),
    scaleSetter: _en("Most of what's below is common, and most of it is minor. "
        "A few signs need a doctor's look, not because they're likely to be "
        "serious, but because a test is the only way to sort them out. You "
        "don't have to work it out alone."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("These are the questions women search late at night and don't "
              "ask anyone. They're also questions gynaecologists answer every "
              "day."),
          _en("Trying for a baby often means more sex, more attention to your "
              "body, and more worry about every small change. That's normal. "
              "Here's what the common things usually turn out to be."),
        ],
      ),
      PvReadSection(
        heading: _en('Why do I feel itchy or burning down there?'),
        paragraphs: [
          _en('These are the most common causes. Several can look alike, which '
              'is why a doctor may want a swab.'),
        ],
        bullets: [
          _en('Irritated skin, from scented soap, washes, pads, liners, '
              'detergent, tight clothes or sweat. This is very common and often '
              'mistaken for an infection.'),
          _en('A yeast infection, usually with thick white discharge.'),
          _en('Shaving or waxing, which can leave the skin sore, itchy and '
              'bumpy.'),
          _en('A reaction to a condom, lubricant or cream.'),
          _en('Trichomoniasis, an infection passed on through sex, with frothy '
              'discharge and a smell.'),
          _en('Genital herpes, which often starts with tingling or burning '
              'before small blisters appear.'),
          _en('A skin condition such as eczema, psoriasis or lichen sclerosus, '
              'which can cause thin, white, itchy patches.'),
        ],
        tip: PvReadTip(
          title: _en('For irritated skin'),
          body: _en("Stop anything scented, wash with water only, and wear "
              "loose cotton. Try not to scratch. A cool, clean, damp cloth can "
              "ease the itch. If it isn't better in a week, see a doctor."),
        ),
      ),
      PvReadSection(
        heading: _en('What does a change in smell mean?'),
        paragraphs: [
          _en("A mild smell of your own is normal, and it changes through the "
              "month. A few smells are worth noticing."),
        ],
        bullets: [
          _en('Fishy, often stronger after sex or a period. This is often BV.'),
          _en("Strong and bad, sometimes with brown discharge. Check for a "
              "forgotten tampon or cup, and see a doctor if you can't find one "
              "or the smell stays."),
          _en("Sharp, like ammonia. This usually comes from urine on the skin "
              "or underwear, especially when you're not drinking enough. Drink "
              "more water and see if it fades. If it doesn't, get it "
              "checked."),
          _en("Metallic, around your period. That's from blood, and it's "
              "normal."),
        ],
      ),
      PvReadSection(
        heading: _en('Will washing more help?'),
        paragraphs: [
          _en("Washing more won't fix an infection smell, and scented products "
              "can make it worse. A doctor can usually find the cause in one "
              "visit."),
          _en("Burning when you pee can be a urine infection, or urine "
              "stinging skin that's already sore. A quick look and a urine test "
              "tell them apart."),
          _en("Until you're seen, plain water, loose cotton and a break from "
              "any new product are the kindest things for the skin."),
        ],
      ),
      PvReadSection(
        heading: _en('What are these bumps or pimples?'),
        paragraphs: [
          _en("Small red bumps where hair grows are usually ingrown hairs or "
              "irritated hair roots, often after shaving or waxing. They "
              "usually settle in a few days. Try not to squeeze them, and keep "
              "the area clean and dry."),
          _en("A soft, painless lump at one side of the vaginal opening can be "
              "a Bartholin's cyst, a blocked gland. Many need no treatment. If "
              "it becomes swollen, hot and painful, it may be infected and "
              "needs a doctor within a day or two."),
          _en("Small, painful blisters or open sores are different. They can be "
              "genital herpes. See a doctor while the sores are there, because "
              "a swab from a sore is the best way to confirm it."),
          _en("Small, painless, fleshy growths can be genital warts. They "
              "aren't dangerous, and a doctor can treat them."),
        ],
      ),
      PvReadSection(
        heading: _en('Why did I bleed after sex?'),
        paragraphs: [
          _en("A little bleeding after sex frightens many women who are trying. "
              "The usual causes are minor. It's still worth a doctor's look, "
              "because only an examination can tell them apart."),
        ],
        bullets: [
          _en('Cervical ectropion, a harmless red patch on the cervix, '
              'explained below'),
          _en("A cervical polyp, a small growth on the cervix that's nearly "
              "always harmless and easy to remove"),
          _en('An infection of the cervix, such as chlamydia, gonorrhoea or '
              'trichomoniasis'),
          _en("Dryness or a small tear, especially if sex was rushed or you "
              "weren't fully aroused"),
          _en('Your period starting, or light spotting around ovulation'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.note,
          title: _en('Why the doctor may ask about a smear test'),
          body: _en("Rarely, bleeding after sex comes from changes in the cells "
              "of the cervix. Your doctor may check whether you're due a "
              "cervical screening test, such as a Pap smear or an HPV test. "
              "Changes found early are easy to treat."),
        ),
      ),
      PvReadSection(
        heading: _en('What is cervical ectropion, and does it need treatment?'),
        paragraphs: [
          _en("The cervix is the neck of the womb, at the top of the vagina. "
              "In ectropion, the soft cells that line the inside of the cervix "
              "also sit on its outer surface. They look red and bleed easily "
              "when touched, such as during sex."),
          _en("It's common in younger women, on the pill and in pregnancy, "
              "because it's linked to hormones. It isn't cancer, and it isn't "
              "an infection. Some doctors still call it cervical erosion, an old "
              "name that sounds far worse than it is."),
          _en("Most women need no treatment, and it often goes away on its "
              "own. If it causes a lot of bleeding or discharge, a doctor can "
              "treat it with a short procedure once other causes are ruled out. "
              "It isn't known to stop you getting pregnant."),
          _en("Bleeding after sex doesn't mean the sex harmed anything, or that "
              "a pregnancy can't start that month."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('Can I use an itch cream from the chemist?'),
        answer: _en("For a yeast infection you've had before and recognise, an "
            "antifungal cream is fine if you tell the chemist you're trying. "
            "Avoid creams that mix a steroid with other medicines unless a "
            "doctor prescribes one, because they can make some infections "
            "worse."),
      ),
      PvReadFaq(
        question: _en('Will my husband notice my smell?'),
        answer: _en("A mild smell of your own is part of a healthy body, and "
            "partners rarely mind it. If your smell has changed and it bothers "
            "you, that's worth a check, not a scented wash."),
      ),
      PvReadFaq(
        question: _en('Is it okay to have sex while I\'m itchy?'),
        answer: _en("If it hurts, it's fine to wait. If you might have an "
            "infection passed on through sex, wait until you've both been "
            "checked and treated."),
      ),
      PvReadFaq(
        question: _en('I\'m too shy to be examined by a male doctor.'),
        answer: _en("That's a common feeling. You can ask for a woman doctor at "
            "most clinics and hospitals. You can also ask for a woman to be in "
            "the room during any examination."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor within a few days if itching, soreness or a "
          "smell doesn't settle after a week of plain water, or a bump grows or "
          "doesn't go away. Go within a day or two for blisters, sores, or a "
          "painful, swollen lump. Book a check within a week or two for "
          "bleeding after sex, even if it happened once. Go the same day for "
          "fever with pain low in your belly, or heavy bleeding."),
    ),
    evidence: _en('NHS guidance on vaginal itching, Bartholin\'s cyst, '
        'cervical ectropion and bleeding after sex; StatPearls/NCBI, "Cervical '
        'Ectropion" and "Postcoital Bleeding"; WHO guideline for screening and '
        'treatment of cervical pre-cancer lesions (2021); CDC Sexually '
        'Transmitted Infections Treatment Guidelines 2021. Sources checked '
        'September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('Plan a doctor\'s visit'),
        value: _en('Write down what you noticed and when, so nothing is '
            'forgotten in the room.'),
        surfaceId: 'ttc_appointments',
      ),
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the tests worth doing first'),
        value: _en('Including cervical screening, if you are due one.'),
        surfaceId: 'ttc_tests',
      ),
    ],
    readNext: ['ttc_read_sti_testing', 'ttc_read_intimate_washing'],
  ),

  // ===========================================================================
  //  6. Infections passed on through sex, and testing before trying
  // ===========================================================================
  PvRead(
    id: 'ttc_read_sti_testing',
    hue: 172,
    kicker: _en('Body and cycle'),
    title: _en('Infections passed on through sex: why a quick test before '
        'trying helps'),
    teaser: _en('Some common infections cause no signs at all but can harm the '
        "tubes. Here's which ones matter, and how easy it is to check."),
    shortAnswer: _en("Some infections passed on through sex, like chlamydia, "
        "often cause no symptoms but can scar the fallopian tubes if left "
        "untreated. A simple urine or swab test finds them, and antibiotics "
        "clear them. Testing both of you before trying is sensible, and it says "
        "nothing about your relationship."),
    scaleSetter: _en("Most couples who get tested find nothing. For those who "
        "do, the common infections are treated with a short course of "
        "medicine. Testing is worth it because an infection with no signs is "
        "easy to miss, and easy to fix once it's found."),
    author: _en('Dr Ruchika Sood'),
    authorRole: _en('IVF gynaecologist'),
    sections: [
      PvReadSection(
        paragraphs: [
          _en("In India, many couples feel these tests aren't for them. It can "
              "feel awkward to ask for them, or like a question about trust. "
              "It's neither."),
          _en("Some of these infections stay in the body without signs for "
              "months or years. One of you may have picked one up long before "
              "you met, with no idea it was there. Testing is a routine part "
              "of getting ready, like checking your blood count."),
          _en("Asking for these tests doesn't mean you suspect anyone. Doctors "
              "suggest them to many couples as a normal step in planning a "
              "pregnancy."),
        ],
      ),
      PvReadSection(
        heading: _en('Why does chlamydia so often go untreated?'),
        paragraphs: [
          _en("Chlamydia is one of the most common infections passed on "
              "through sex, worldwide and in India. Most women who have it "
              "notice nothing at all, and many men don't either. It isn't "
              "treated because nobody knows it's there."),
          _en("Left alone, it can spread from the cervix up into the womb and "
              "fallopian tubes. This is called pelvic inflammatory disease, or "
              "PID. It can cause pain low in the belly, but sometimes it has no "
              "signs either."),
          _en("PID can leave scars that narrow or block the tubes. Blocked "
              "tubes are one known cause of trouble getting pregnant, and "
              "damaged tubes make an ectopic pregnancy more likely. Treating "
              "chlamydia early prevents this."),
          _en("Gonorrhoea behaves in a similar way, and the same sample tests "
              "for both."),
        ],
      ),
      PvReadSection(
        heading: _en('Which infections are worth checking for?'),
        bullets: [
          _en('Chlamydia and gonorrhoea: often silent, and can harm the tubes. '
              'A urine test or a vaginal swab checks for both.'),
          _en("Trichomoniasis: a common infection that can cause frothy, smelly "
              "discharge and soreness, or no signs at all. It's cured with an "
              "antibiotic."),
          _en('Syphilis, HIV and hepatitis B: blood tests. These are part of '
              'routine pregnancy care in India, and checking before pregnancy '
              'gives time to treat or plan so a baby is protected.'),
          _en("Genital herpes: usually tested only if you have sores. It "
              "doesn't affect fertility, but tell your doctor early if you've "
              "ever had it."),
        ],
        paragraphs: [
          _en("Genital warts, caused by some types of HPV, don't affect "
              "fertility either. The HPV vaccine protects against the types "
              "behind most warts and cervical cancers. Ask your doctor whether "
              "it still suits you before pregnancy."),
          _en("Your doctor may suggest a different set based on your history. "
              "Both partners should be tested, since an infection treated in "
              "one of you can come straight back from the other."),
        ],
        mythFact: PvMythFact(
          myth: _en("Married women who've only been with their husband don't "
              "need these tests."),
          fact: _en("Many of these infections cause no signs and can stay for "
              "years. Either partner may have had one from long ago without "
              "knowing. A test is routine care, not a judgement."),
        ),
      ),
      PvReadSection(
        heading: _en('What happens if a test is positive?'),
        paragraphs: [
          _en("Chlamydia, gonorrhoea, trichomoniasis and syphilis are cured "
              "with antibiotics, as tablets or an injection. Your doctor will "
              "choose one that's safe while you're trying."),
          _en("You both need treatment at the same time, even if one of you "
              "tested negative. Your doctor will tell you how long to wait "
              "before having sex again, usually until a week after treatment "
              "ends."),
          _en("A repeat test a few months later is often advised, to make sure "
              "it hasn't come back. If you've had PID, your doctor may suggest "
              "checking your tubes sooner rather than later."),
          _en("HIV and hepatitis B can't be cured in the same way, but they're "
              "managed very well today. With treatment in pregnancy, the risk "
              "of passing HIV to a baby can be made very low."),
        ],
      ),
      PvReadSection(
        heading: _en('What about herpes when planning a pregnancy?'),
        paragraphs: [
          _en("Herpes is a common virus. Many people carry it and never know. "
              "Others get small, painful blisters from time to time. It doesn't "
              "stop you getting pregnant."),
          _en("It matters mainly around birth. If you've had herpes before, "
              "your body makes antibodies that help protect the baby. Doctors "
              "can also give tablets late in pregnancy to prevent an outbreak "
              "at delivery."),
          _en("The bigger concern is catching it for the first time late in "
              "pregnancy. So if you or your partner has ever had sores, tell "
              "your doctor early. There's nothing to be ashamed of."),
        ],
      ),
      PvReadSection(
        heading: _en('Where can we get tested in India?'),
        paragraphs: [
          _en("Your gynaecologist can order these tests, and a urologist or "
              "general physician can test your partner. Most private labs offer "
              "them. Prices vary between labs, so ask before the sample is "
              "taken."),
          _en("Government hospitals have free clinics for these infections, "
              "often called Suraksha Clinics, and free HIV testing at "
              "Integrated Counselling and Testing Centres (ICTCs). Your results "
              "are kept confidential."),
          _en("Chlamydia and gonorrhoea need only a urine sample or a quick "
              "swab. The blood tests are a single blood draw. None of it takes "
              "long."),
          _en("If you're already seeing a fertility clinic, some of these tests "
              "are often in the first set of checks. Ask what's included before "
              "paying for them again somewhere else."),
        ],
      ),
    ],
    faqs: [
      PvReadFaq(
        question: _en('How do I bring this up with my husband?'),
        answer: _en("You could say it's on the list of tests the doctor suggests "
            "before trying, which is true. Doing it together, as a couple's "
            "check, makes it feel routine rather than personal."),
      ),
      PvReadFaq(
        question: _en('I had chlamydia years ago. Can I still get pregnant?'),
        answer: _en("Many women do. Treated early, it often leaves no lasting "
            "harm. If it went untreated for a while or you had PID, your doctor "
            "may suggest checking your tubes sooner."),
      ),
      PvReadFaq(
        question: _en('Will anyone else know my results?'),
        answer: _en("Your results are private between you and your doctor. In "
            "India, the HIV and AIDS (Prevention and Control) Act, 2017 "
            "protects the privacy of HIV test results by law."),
      ),
      PvReadFaq(
        question: _en('Can I catch these from a toilet seat?'),
        answer: _en("No. The infections in this read spread through sexual "
            "contact, not through toilet seats or swimming pools."),
      ),
      PvReadFaq(
        question: _en('Does a normal Pap smear mean I have no infections?'),
        answer: _en("No. A Pap smear looks for changes in the cells of the "
            "cervix. It doesn't test for chlamydia, gonorrhoea or most other "
            "infections, so these need their own tests."),
      ),
    ],
    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('When to see a doctor'),
      body: _en("See a doctor within a few days if you have frothy, green or "
          "bad-smelling discharge, pain during sex, bleeding between periods or "
          "after sex, or sores or blisters. Go the same day for pain low in "
          "your belly with a fever. Go to hospital today if your period is "
          "late and you have severe pain on one side, pain at the tip of your "
          "shoulder, heavy bleeding, or you feel faint. If your partner is "
          "diagnosed with an infection, you need a test and treatment too."),
    ),
    evidence: _en('CDC Sexually Transmitted Infections Treatment Guidelines '
        '2021; WHO guidelines on the management of symptomatic sexually '
        'transmitted infections (2021); NICE fertility guideline CG156 on tubal '
        'damage; NACO technical guidelines on the management of sexually '
        'transmitted and reproductive tract infections; the HIV and AIDS '
        '(Prevention and Control) Act, 2017; ACOG patient FAQ "Chlamydia, '
        'Gonorrhea, and Syphilis". Sources checked September 2026.'),
    nextSteps: [
      PvReadNextStep(
        kind: PvNextKind.tool,
        title: _en('See the tests worth doing first'),
        value: _en('The full list for both of you, with what each one checks.'),
        surfaceId: 'ttc_tests',
      ),
      PvReadNextStep(
        kind: PvNextKind.read,
        title: _en('The tests and vaccinations worth doing first'),
        value: _en('The rest of the getting-ready checks, in one place.'),
        surfaceId: 'ttc_read/ttc_read_preconception_tests',
      ),
    ],
    readNext: ['ttc_read_preconception_tests', 'ttc_read_discharge_guide'],
  ),
];
