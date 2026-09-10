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

final List<PvRead> kPregnancyReadsConditions = [
  // ===========================================================================
  //  1. When blood pressure gets dangerous
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_bp_dangerous',
    hue: _hue,
    kicker: _en('Complications & conditions'),
    title: _en('When blood pressure gets dangerous'),
    teaser: _en('Most raised blood pressure in pregnancy is watched, not '
        'feared. This is how to tell the difference, and what not to sit on.'),

    scaleSetter: _en('Raised blood pressure is one of the commonest things '
        'flagged in an Indian pregnancy, and the large majority of it is '
        'managed with closer check-ups and, if needed, a tablet. What changes '
        'the picture is not the number on its own — it is the number together '
        'with how you feel.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Blood pressure gets measured at every antenatal visit, and for '
              'most women it is a number that goes into a book and is never '
              'mentioned again. When it starts to climb, what your doctor is '
              'watching for is not one high reading. It is a pattern, and it '
              'is whether the rest of you has started to be affected.'),
          _en('That distinction is the whole of this piece. High blood '
              'pressure by itself is a plumbing problem: the pressure in the '
              'pipes is up, and it is brought down. High blood pressure that '
              'has started to affect your kidneys, your liver, your eyes or '
              'your baby is a different condition with a different name and a '
              'different urgency.'),
          _en('You cannot tell which you have from a machine at home. You can '
              'tell a great deal from how you feel, which is why the symptoms '
              'below matter more than any reading you take yourself.'),
        ],
      ),

      PvReadSection(
        heading: _en('The signs that change the answer'),
        paragraphs: [
          _en('These are the ones that mean call today rather than mention it '
              'at your next visit. They are the same list your doctor is '
              'carrying, and none of them requires you to have taken a '
              'reading.'),
        ],
        bullets: [
          _en('A bad headache that does not ease with rest or paracetamol.'),
          _en('Changes in your vision — blurring, flashing lights, spots, or '
              'losing part of what you can see.'),
          _en('Pain just under your ribs, usually on the right side. This one '
              'is the least known and the most important, because it is easy '
              'to mistake for indigestion.'),
          _en('Sudden swelling of your face or hands. Ankles that puff up '
              'through the day are ordinary; a face that looks different in '
              'the mirror overnight is not.'),
          _en('Vomiting that starts late in pregnancy, when you had none.'),
          _en('The baby moving less than usual.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('Any two of these together'),
          body: _en('Go in the same day rather than phoning and waiting for a '
              'call back. A headache with vision changes in particular is the '
              'combination doctors treat as an emergency.'),
        ),
      ),

      PvReadSection(
        heading: _en('What the numbers mean, and what they do not'),
        paragraphs: [
          _en('Doctors talk about two figures — the pressure when the heart '
              'beats and the pressure between beats. In pregnancy the second '
              'one is watched particularly closely, and readings are compared '
              'against your own earlier ones rather than against a single '
              'universal line.'),
          _en('That comparison is why your first-visit reading matters so '
              'much. Someone who normally runs low has had a meaningful rise '
              'well before she reaches a number that would look ordinary on '
              'somebody else. Your booking reading is the baseline the whole '
              'pregnancy is read against.'),
          _en('What a number cannot do is tell you whether the rest of you is '
              'affected. That takes a urine test for protein and a blood test, '
              'both of which are quick, and neither of which you can do at '
              'home. So a home monitor is a useful tool for spotting a trend '
              'and a poor tool for reassurance — a normal reading with a bad '
              'headache is not a normal situation.'),
        ],
        tip: PvReadTip(
          title: _en('If you are measuring at home'),
          body: _en('Sit still for five minutes first, feet flat, arm '
              'supported at the level of your heart, and take two readings a '
              'minute apart. Write down both. A single reading taken after '
              'climbing stairs is not a measurement, and it is the commonest '
              'reason somebody frightens themselves at 10pm.'),
        ),
      ),

      PvReadSection(
        heading: _en('What happens if it does climb'),
        paragraphs: [
          _en('The usual path is more monitoring rather than less normality. '
              'More frequent check-ups, a urine test at each one, blood tests '
              'to see whether anything else is affected, and growth scans '
              'because a placenta working against high pressure sometimes '
              'delivers less.'),
          _en('If the numbers stay high you are likely to be offered a tablet. '
              'There are blood-pressure medicines with a long, well-studied '
              'record in pregnancy, and they are given because bringing the '
              'pressure down protects you — not because something has gone '
              'wrong that cannot be handled.'),
          _en('Rest and less salt are commonly advised alongside medicine and '
              'not instead of it. If you have been given a tablet, take it. '
              'Stopping because you feel fine is the single commonest mistake '
              'here, and feeling fine is exactly what the tablet is doing.'),
          _en('The other thing that changes is the plan for the birth. Where '
              'pressure is hard to control, delivering is the treatment, and '
              'the conversation becomes about the safest week rather than '
              'about whether. That is a plan being made, not a failure.'),
        ],
      ),

      PvReadSection(
        heading: _en('After the birth'),
        collapsible: true,
        summary: _en('It does not always end with the delivery, and the weeks '
            'after are when it is most often missed.'),
        paragraphs: [
          _en('Blood pressure raised in pregnancy usually settles within a few '
              'weeks of the birth, but not always immediately, and it can '
              'occasionally rise for the first time AFTER delivery. The '
              'symptoms to watch for are the same ones as above.'),
          _en('That is easy to miss because attention has moved to the baby '
              'and because a new mother expects to feel terrible. A severe '
              'headache in the first fortnight after birth is worth a phone '
              'call, not a paracetamol.'),
          _en('Longer term, having had raised blood pressure in pregnancy is '
              'worth remembering and worth telling a future doctor. It is a '
              'piece of history that changes how you are watched, in a later '
              'pregnancy and outside one.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Go in the same day if'),
      body: _en('You have a bad headache that will not ease, any change in '
          'your vision, pain under your ribs, sudden swelling of your face or '
          'hands, or the baby is moving less than usual. Do not wait for your '
          'next appointment and do not wait to take a reading first.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My reading was high once and normal since. Does that '
            'count?'),
        answer: _en('Tell your doctor at your next visit rather than dismissing '
            'it. One high reading in an otherwise ordinary pregnancy is '
            'usually nothing, and it is also the sort of thing that is worth '
            'having written down so a pattern can be seen if one starts.'),
      ),
      PvReadFaq(
        question: _en('Is the medicine safe for the baby?'),
        answer: _en('The ones used in pregnancy are chosen precisely because '
            'they have long safety records in it. Uncontrolled high pressure '
            'carries a clearer risk to both of you than the tablets do. If you '
            'have a specific worry, ask which one you are on and why that one — '
            'it is a reasonable question and there is a real answer.'),
      ),
      PvReadFaq(
        question: _en('Will I definitely need a caesarean?'),
        answer: _en('No. Raised blood pressure on its own does not decide the '
            'route of delivery. It may bring the timing forward, and how you '
            'deliver is decided on the day by how you and the baby are doing.'),
      ),
      PvReadFaq(
        question: _en('Can I bring it down by resting more?'),
        answer: _en('Rest helps and is worth doing, and it is not a treatment '
            'on its own. If you have been offered a tablet, rest is what you do '
            'alongside it.'),
      ),
    ],

    evidence: _en('NICE guideline NG133, hypertension in pregnancy · FOGSI '
        'good clinical practice recommendations on hypertensive disorders of '
        'pregnancy · WHO recommendations on antenatal care · Reviewed '
        'September 2026.'),

    readNext: ['preg_cond_read_bleeding', 'preg_cond_read_less_movement'],
  ),

  // ===========================================================================
  //  2. Bleeding in pregnancy
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_bleeding',
    hue: _hue,
    kicker: _en('Complications & conditions'),
    title: _en('Bleeding in pregnancy'),
    teaser: _en('What is usually nothing, what is not, and why the answer is '
        'the same either way — tell someone today.'),

    scaleSetter: _en('Bleeding in pregnancy is common and frightening, and '
        'those two facts sit oddly together. Many women who bleed early go on '
        'to have entirely ordinary pregnancies. That is a real comfort and it '
        'is not a reason to wait — the only way to know which kind you have is '
        'for somebody to look.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('There is one instruction in this piece and everything else is '
              'context: if you are bleeding, tell your doctor the same day. '
              'Not at your next appointment, and not after you have searched '
              'for what it might be.'),
          _en('The reason is not that bleeding is usually serious. It is that '
              'the difference between the harmless kinds and the serious kinds '
              'cannot be told apart by how much blood there is, what colour it '
              'is, or how you feel. A small amount can matter and a larger '
              'amount can turn out to be nothing.'),
          _en('The asymmetry is worth saying plainly. Calling and being told '
              'it is nothing costs you an afternoon. The other mistake does '
              'not have a cost you can undo, and no doctor has ever been '
              'annoyed by a woman who called about bleeding.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('Go straight to hospital if'),
          body: _en('The bleeding is heavy, there are clots, or it comes with '
              'pain — especially sharp pain low down on one side, or pain at '
              'the tip of your shoulder. Do not drive yourself.'),
        ),
      ),

      PvReadSection(
        heading: _en('What is often nothing'),
        paragraphs: [
          _en('Light spotting in the first weeks is the commonest kind and is '
              'often unexplained. Some of it happens around the time the '
              'pregnancy settles into the womb, some of it has no identified '
              'cause at all, and a great many pregnancies that begin with it '
              'continue perfectly well.'),
          _en('Bleeding after sex or after an internal examination is also '
              'common. The cervix has a much richer blood supply in pregnancy '
              'and is easily irritated. It looks alarming and is usually '
              'exactly what it looks like.'),
          _en('Small harmless growths on the cervix can bleed on and off '
              'through a pregnancy. So can a small collection of blood beside '
              'the pregnancy that a scan sometimes picks up, which usually '
              'resolves on its own.'),
          _en('All of these still get reported. What makes them harmless is '
              'that somebody looked and said so, not that they matched a '
              'description in an article.'),
        ],
      ),

      PvReadSection(
        heading: _en('What is not'),
        paragraphs: [
          _en('A small number of causes are urgent, and the reason to know '
              'them is not to self-diagnose — it is to know which ones mean '
              'hospital rather than a phone call.'),
          _en('Bleeding with sharp one-sided pain very early in pregnancy can '
              'mean the pregnancy has settled outside the womb. Pain at the '
              'tip of your shoulder alongside it is the sign that sounds like '
              'nothing and is the most important one on this page. That is an '
              'emergency and it is treatable when it is caught.'),
          _en('Later in pregnancy, bleeding can come from the placenta lying '
              'low across the exit, or from a placenta beginning to separate. '
              'The second usually hurts and the first often does not, which is '
              'exactly why "it does not hurt" is not reassurance.'),
          _en('Bleeding near your due weeks may simply be labour beginning — a '
              'small amount of blood-stained mucus is normal at that point. '
              'Anything heavier than that still gets a call.'),
        ],
      ),

      PvReadSection(
        heading: _en('What to do, and what to notice'),
        paragraphs: [
          _en('Use a pad rather than a tampon, so somebody can see how much '
              'there has been. Do not put anything inside, and hold off on sex '
              'until you have been told it is fine.'),
          _en('Note three things before you call, because they are the three '
              'you will be asked: roughly how much, what colour, and whether '
              'there is pain. "Two spots, brown, no pain" and "soaking a pad '
              'in an hour, red, cramping" are two entirely different '
              'conversations.'),
          _en('If you know your blood group, say it. Women who are rhesus '
              'negative may need an injection after bleeding, and the timing '
              'of that matters — it is one of the clearest reasons not to sit '
              'on it for a week.'),
        ],
        tip: PvReadTip(
          title: _en('Brown is older, red is newer'),
          body: _en('Brown blood has taken time to come away and usually means '
              'something that has already happened; fresh red means it is '
              'happening now. It is a useful thing to be able to say on the '
              'phone. It is not a way of deciding whether to make the call.'),
        ),
      ),

      PvReadSection(
        heading: _en('If the news is bad'),
        collapsible: true,
        summary: _en('Sometimes bleeding is the beginning of a loss, and that '
            'deserves saying rather than avoiding.'),
        paragraphs: [
          _en('Some bleeding is an early pregnancy ending, and most early loss '
              'is caused by something in how that particular pregnancy formed '
              'from the very beginning. It is not caused by lifting something, '
              'by working, by an argument, by travel, or by anything you ate.'),
          _en('That sentence is here because it is the one thing almost every '
              'woman goes looking for afterwards, and because the answer is '
              'clear and kind and true.'),
          _en('You will be looked after either way. Ask what is happening, ask '
              'what your choices are, and ask to have someone with you. None '
              'of it has to be decided in the first hour.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call the same day for any bleeding'),
      body: _en('However light. Go straight to hospital if it is heavy, has '
          'clots, or comes with pain — particularly sharp pain low down on one '
          'side, pain at the tip of your shoulder, or feeling faint.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('It stopped after an hour. Do I still need to say '
            'anything?'),
        answer: _en('Yes, the same day. Bleeding that has stopped is still '
            'bleeding that happened, and it may change what your doctor wants '
            'to check or whether you need an injection for your blood group.'),
      ),
      PvReadFaq(
        question: _en('Is spotting normal at the time my period would have '
            'been due?'),
        answer: _en('Some women do notice light spotting around those dates '
            'early on and it is often nothing. It is still worth mentioning, '
            'because "often nothing" is not the same as "known to be nothing '
            'in your case".'),
      ),
      PvReadFaq(
        question: _en('Did I cause this?'),
        answer: _en('Almost certainly not. Ordinary activity, work, travel, '
            'lifting a toddler and sex do not cause bleeding that matters, and '
            'early loss is overwhelmingly about how a pregnancy formed rather '
            'than anything that was done to it.'),
      ),
    ],

    evidence: _en('Royal College of Obstetricians and Gynaecologists patient '
        'information on early pregnancy loss and on bleeding in later '
        'pregnancy · FOGSI recommendations on antepartum haemorrhage · '
        'Ministry of Health and Family Welfare anti-D guidance · Reviewed '
        'September 2026.'),

    readNext: ['preg_cond_read_less_movement', 'preg_cond_read_bp_dangerous'],
  ),

  // ===========================================================================
  //  3. When the baby moves less
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_less_movement',
    hue: _hue,
    kicker: _en('Complications & conditions'),
    title: _en('When the baby moves less'),
    teaser: _en('Do not wait until tomorrow, do not drink something cold '
        'first, and do not count for two hours before you call.'),

    scaleSetter: _en('Most women who go in because the baby is moving less are '
        'sent home reassured the same day. That is the point of going: it is a '
        'quick check, it is free of charge at a government hospital, and it is '
        'one of the few things in pregnancy where being early costs nothing '
        'and being late can cost a great deal.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('A baby that has been moving in a pattern you recognise and has '
              'stopped moving that way is the single most useful warning sign '
              'in late pregnancy. It is more useful than any measurement you '
              'can take, and it is available to you every day for nothing.'),
          _en('It is also the sign most often talked out of. Almost everyone '
              'is told to lie down, eat something sweet, drink something cold, '
              'and count. Some of that advice is well meant and some of it is '
              'passed down. None of it should delay a phone call, and that is '
              'the whole of this piece.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.urgent,
          title: _en('There is no good hour to wait'),
          body: _en('If the movements are less than usual right now, call now — '
              'day or night. Maternity units expect these calls, take them '
              'seriously, and would far rather see you.'),
        ),
      ),

      PvReadSection(
        heading: _en('What "less" actually means'),
        paragraphs: [
          _en('It means less than YOUR baby\'s usual, not less than some '
              'number. Babies differ enormously — some are busy all evening, '
              'some move in short bursts through the day — and what matters is '
              'a change from the pattern you have got used to.'),
          _en('You will start to feel movements somewhere between eighteen and '
              'twenty-four weeks, later if this is your first pregnancy or if '
              'the placenta is lying at the front. From around twenty-eight '
              'weeks the pattern becomes recognisable, and from then on you are '
              'the person best placed to notice it change.'),
          _en('Babies do not run out of room and move less near the end. That '
              'belief is widespread and it is wrong, and it is the single most '
              'common reason a woman waits. Movements should stay recognisable '
              'right up to labour.'),
        ],
        mythFact: PvMythFact(
          myth: _en('Babies move less in the last weeks because there is no '
              'space left.'),
          fact: _en('They do not. The KIND of movement changes — more '
              'stretching and rolling, fewer sharp kicks, because a bigger '
              'baby moves differently — but how often you feel something '
              'should not fall away. A genuine reduction near your due date is '
              'a reason to be seen, not a stage to expect.'),
        ),
      ),

      PvReadSection(
        heading: _en('What not to do first'),
        paragraphs: [
          _en('Three things get suggested constantly, and each one costs time '
              'that has no reason to be spent.'),
        ],
        bullets: [
          _en('Do not lie down and count to ten before deciding. Formal '
              'counting schemes have not been shown to change outcomes, and '
              'they reliably delay the call.'),
          _en('Do not drink something cold or sugary to "wake the baby". If a '
              'baby moves afterwards it proves very little, and if the baby '
              'does not you have lost an hour being frightened.'),
          _en('Do not wait for morning. A maternity unit is staffed at 3am and '
              'the check is the same at 3am as it is at 10am.'),
        ],
      ),

      PvReadSection(
        heading: _en('What happens when you go in'),
        paragraphs: [
          _en('It is quick and it is not invasive. Somebody listens to the '
              'baby\'s heartbeat, usually with a monitor strapped on for '
              'twenty to forty minutes so the trace can be watched over time. '
              'Your blood pressure is checked and often your urine too.'),
          _en('Depending on what they see and how many weeks you are, you may '
              'be offered a scan to look at growth and the fluid around the '
              'baby. In most cases everything is normal and you go home.'),
          _en('If it happens again, go again. Coming back a second or third '
              'time is not being a nuisance — repeated episodes are '
              'specifically what doctors want to know about, and each visit is '
              'assessed on its own.'),
        ],
        tip: PvReadTip(
          title: _en('Know the number before you need it'),
          body: _en('Find the direct number for your hospital\'s labour ward '
              'or maternity triage now, and save it. At 2am, hunting for a '
              'number is the delay, not the decision.'),
        ),
      ),

      PvReadSection(
        heading: _en('Getting to know the pattern'),
        collapsible: true,
        summary: _en('You do not need an app or a chart — you need a habit.'),
        paragraphs: [
          _en('From around twenty-eight weeks, spend a little while each day '
              'in the same position, at roughly the same time, paying '
              'attention. Many women find the evening works because babies are '
              'often active then and because you are finally still.'),
          _en('You are not looking for a count. You are building a sense of '
              'what ordinary feels like, so that a change registers as a '
              'change rather than as a vague unease you talk yourself out of.'),
          _en('If your partner has felt the baby move from outside, they will '
              'often notice a quiet spell too. Two people paying attention is '
              'better than a chart.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call now, at any hour'),
      body: _en('If your baby is moving less than usual, or the pattern has '
          'changed, contact your maternity unit straight away — do not wait '
          'until morning and do not count first. If you have also had '
          'bleeding, a bad headache or fluid leaking, say so on the call.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('The baby started moving again while I was on the phone. '
            'Should I still go?'),
        answer: _en('Say that on the call and let them decide. Movements '
            'returning is genuinely reassuring and it does not automatically '
            'cancel the check — especially if this has happened before.'),
      ),
      PvReadFaq(
        question: _en('I have an anterior placenta and feel less anyway.'),
        answer: _en('A placenta at the front does cushion the movements, so '
            'you may feel them later and more faintly. It does not change the '
            'rule: what matters is a change from your own usual, whatever your '
            'usual is.'),
      ),
      PvReadFaq(
        question: _en('This is my third time going in this month.'),
        answer: _en('Then go. Repeated episodes are exactly what your doctor '
            'wants to know about, and each one is checked on its own merits. '
            'Nobody is counting your visits against you.'),
      ),
      PvReadFaq(
        question: _en('Is a home doppler a good idea?'),
        answer: _en('No. Finding a heartbeat at home is the commonest way '
            'women are falsely reassured and delay going in — a heartbeat now '
            'says nothing about how the baby has been. Use how the baby moves, '
            'and use the phone.'),
      ),
    ],

    evidence: _en('Royal College of Obstetricians and Gynaecologists Green-top '
        'Guideline 57, reduced fetal movements · AFFIRM trial, Lancet 2018 · '
        'FOGSI good clinical practice recommendations on fetal surveillance · '
        'Reviewed September 2026.'),

    readNext: ['preg_cond_read_bleeding', 'preg_cond_read_bp_dangerous'],
  ),

  // ===========================================================================
  //  4. Handling pregnancy sugar in India
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_sugar_india',
    hue: _hue,
    kicker: _en('Complications & conditions'),
    title: _en('Handling pregnancy sugar in India'),
    teaser: _en('Rice, roti, festivals and a joint family kitchen — what '
        'actually shifts the numbers, and what only makes meals miserable.'),

    scaleSetter: _en('Most women with pregnancy sugar manage it on food and '
        'walking alone, and the majority deliver healthy babies without '
        'anything else changing. Needing tablets or insulin later is not a '
        'failure — for some people it is simply what their body needs, and it '
        'works.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Almost every piece of advice about pregnancy sugar was written '
              'for a plate that looks nothing like an Indian one. "Cut carbs" '
              'is not useful guidance in a household where rice or roti is '
              'the meal, and it is usually heard as "eat less", which is the '
              'wrong instruction in pregnancy.'),
          _en('The useful version is narrower and easier: keep the food, '
              'change the shape of the meal, and move afterwards. Nothing '
              'below asks you to stop eating what your family eats.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('This is not about weight'),
          body: _en('Pregnancy sugar is caused by pregnancy hormones blocking '
              'the effect of insulin. Thin women get it, women who eat '
              'carefully get it, and it is not something you brought on '
              'yourself.'),
        ),
      ),

      PvReadSection(
        heading: _en('The three changes that do most'),
        paragraphs: [
          _en('If you do nothing else, do these. They shift readings more than '
              'any list of forbidden foods.'),
        ],
        bullets: [
          _en('Never eat the carbohydrate first or alone. Start the meal with '
              'the vegetable or the dal, keep the curd, and eat the rice or '
              'roti alongside them rather than as the opening. The same food, '
              'in a different order, arrives in your blood more slowly.'),
          _en('Walk for ten to fifteen minutes after each main meal. This is '
              'the single most effective thing on the list and the one most '
              'often skipped. Around the terrace or the corridor is enough.'),
          _en('Split the day into smaller, more frequent meals rather than two '
              'or three large ones, and do not skip breakfast. A long gap '
              'followed by a big plate is the pattern that produces the worst '
              'readings.'),
        ],
      ),

      PvReadSection(
        heading: _en('The Indian plate, honestly'),
        paragraphs: [
          _en('Rice does not have to go. Which rice and how much of it '
              'matters, and so does what is beside it. Hand-pounded and '
              'parboiled varieties behave better than highly polished white '
              'rice, and a smaller portion of rice with a larger portion of '
              'dal and sabzi behaves better than either.'),
          _en('Roti is generally kinder than white rice, and mixing the atta '
              'with besan, jowar or bajra is kinder still. Adding a spoon of '
              'ghee to the dough is not the problem it is often assumed to '
              'be — fat slows the meal down.'),
          _en('The things that genuinely need to go are the ones that arrive '
              'as sugar almost immediately: sweetened tea and coffee, packaged '
              'juices, colas, and mithai. Fruit is not in that group — whole '
              'fruit with the fibre intact is fine in sensible amounts, and it '
              'is fruit JUICE that behaves like a soft drink.'),
          _en('Curd, paneer, eggs, dal, nuts and seeds are all useful, and '
              'adding protein to a meal is more productive than removing '
              'carbohydrate from it.'),
        ],
        tip: PvReadTip(
          title: _en('Festivals and guests'),
          body: _en('You are going to be offered sweets, and refusing every '
              'time is exhausting. Eat the piece you actually want, after a '
              'proper meal rather than on an empty stomach, and walk '
              'afterwards. One planned sweet handled well beats three '
              'unplanned ones and a week of guilt.'),
        ),
      ),

      PvReadSection(
        heading: _en('Testing, and what the numbers are for'),
        paragraphs: [
          _en('You will most likely be asked to check your sugar at home, '
              'fasting and after meals, and to write the readings down. The '
              'point of the record is not to grade you — it is to show your '
              'doctor which MEALS are the problem, which is information no '
              'single reading carries.'),
          _en('So write down what you ate beside the number. A high reading '
              'after one particular breakfast is a fixable thing; a column of '
              'numbers with no food beside them is just a column of numbers.'),
          _en('Your doctor sets your targets, and they are not the same for '
              'everyone. If your readings are consistently above them despite '
              'the changes above, that is the information the plan needs — not '
              'a reason to eat less.'),
        ],
      ),

      PvReadSection(
        heading: _en('If you are offered tablets or insulin'),
        collapsible: true,
        summary: _en('It is common, it is not a failure, and insulin does not '
            'cross to the baby.'),
        paragraphs: [
          _en('A meaningful share of women need medicine as well as food '
              'changes, most often in the last third of pregnancy when the '
              'hormones blocking insulin are at their strongest. That is the '
              'pregnancy changing, not your effort failing.'),
          _en('Insulin does not cross the placenta to your baby. High sugar '
              'does. When those two facts are put side by side the choice '
              'usually looks different from how it first feels.'),
          _en('Whatever you are given, keep the food changes going alongside '
              'it. Medicine works better on top of them than instead of them, '
              'and the walking still helps.'),
        ],
      ),

      PvReadSection(
        heading: _en('After the birth'),
        paragraphs: [
          _en('Pregnancy sugar usually resolves within days of delivery, and '
              'most women stop all treatment straight away.'),
          _en('The part that gets forgotten is the follow-up test a few weeks '
              'later, which checks that things have genuinely returned to '
              'normal. Having had pregnancy sugar raises the chance of '
              'developing type 2 diabetes years later, and that is worth '
              'knowing precisely because it is the kind of thing regular '
              'checks and ordinary habits keep at bay.'),
          _en('Book that test before you leave hospital if you can. In the '
              'first month with a newborn, nothing that has not been booked '
              'happens.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en('You feel shaky, sweaty, confused or faint after starting '
          'medicine — this can mean your sugar has dropped too low and needs '
          'treating now. Also call if your readings stay high despite the '
          'changes, or if the baby is moving less than usual.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Do I have to stop rice completely?'),
        answer: _en('No. Portion, variety and what is beside it matter far '
            'more than removing it. A smaller serving of parboiled rice with '
            'plenty of dal and sabzi, followed by a walk, is a workable meal '
            'for most people.'),
      ),
      PvReadFaq(
        question: _en('Can I fast during a festival?'),
        answer: _en('Ask your doctor before you decide, particularly if you '
            'are on any medicine — long gaps without food can send sugar too '
            'low. Many women find a modified observance is agreed easily once '
            'they ask.'),
      ),
      PvReadFaq(
        question: _en('Will my baby be very large?'),
        answer: _en('Well-controlled sugar largely removes that concern, which '
            'is the whole reason for the monitoring. Your growth scans are how '
            'this is watched, and they are the conversation to have with your '
            'doctor rather than a thing to predict.'),
      ),
      PvReadFaq(
        question: _en('Is a sugar-free sweetener safe?'),
        answer: _en('Some are considered acceptable in pregnancy and some are '
            'not, and it varies by product. Ask your doctor about the specific '
            'one rather than assuming the category is fine.'),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare, National Guidelines '
        'for Diagnosis and Management of Gestational Diabetes Mellitus · FOGSI '
        'and DIPSI recommendations · Indian Council of Medical Research '
        'dietary guidelines · Reviewed September 2026.'),

    readNext: ['preg_cond_read_iron', 'preg_cond_read_thyroid_tablet'],
  ),

  // ===========================================================================
  //  5. The daily thyroid tablet
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_thyroid_tablet',
    hue: _hue,
    kicker: _en('Complications & conditions'),
    title: _en('The daily thyroid tablet'),
    teaser: _en('When to take it, what stops it working, and why the dose '
        'changes during pregnancy.'),

    scaleSetter: _en('An underactive thyroid in pregnancy is common in India '
        'and is one of the most completely fixable things on any antenatal '
        'list. One tablet, taken properly, brings the level back where it '
        'should be — and taking it properly is most of the difficulty.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('The thyroid is a small gland in your neck that sets the pace of '
              'a great many things in the body. In pregnancy your baby depends '
              'on your thyroid hormone for the first months, before making any '
              'of its own — which is why a level that would be ignored outside '
              'pregnancy gets treated inside it.'),
          _en('The treatment is a tablet that replaces exactly what your '
              'gland is not making enough of. It is not a drug that does '
              'something new to your body; it is the same hormone, taken by '
              'mouth. That is why it is considered safe in pregnancy and why '
              'the dose is worked out by blood test rather than by symptoms.'),
        ],
      ),

      PvReadSection(
        heading: _en('How to take it so it works'),
        paragraphs: [
          _en('This tablet is unusually fussy about company. Most of the '
              'reasons a level stays wrong are here rather than in the dose.'),
        ],
        bullets: [
          _en('First thing in the morning, on an empty stomach, with plain '
              'water. Then wait thirty to sixty minutes before tea, coffee or '
              'breakfast.'),
          _en('Keep it four hours away from iron and from calcium. Both bind '
              'to it in the gut and a great deal of the dose simply never gets '
              'in. Since almost every pregnant woman in India is also on iron '
              'and calcium, this is the commonest problem of all.'),
          _en('Keep it away from antacids too, and from soya-heavy meals.'),
          _en('Take it at the same time every day. If mornings are impossible, '
              'ask about taking it at bedtime instead — three hours after '
              'eating — which works for many people and is better than a dose '
              'taken erratically with breakfast.'),
        ],
        tip: PvReadTip(
          title: _en('If morning sickness is the obstacle'),
          body: _en('Say so rather than skipping. Bedtime dosing, or taking it '
              'the moment you wake and lying still for a while, both help. A '
              'tablet you can actually keep down is worth more than the '
              'theoretically ideal timing.'),
        ),
      ),

      PvReadSection(
        heading: _en('Why the dose keeps changing'),
        paragraphs: [
          _en('Your need for thyroid hormone rises early in pregnancy and '
              'keeps rising into the middle months. So a dose that was correct '
              'before you conceived is usually not enough by the second month, '
              'and women already on treatment are often asked to increase it '
              'as soon as a pregnancy is confirmed.'),
          _en('That is why the blood test is repeated every few weeks rather '
              'than once. The test is looking at whether the current dose is '
              'keeping up with a moving requirement, not at whether you have '
              'the condition.'),
          _en('It also means a rising dose is not a sign of getting worse. It '
              'is the expected shape of a normal pregnancy on treatment.'),
        ],
      ),

      PvReadSection(
        heading: _en('Missed doses, and the questions people are shy about'),
        paragraphs: [
          _en('If you forget one, take it as soon as you remember on the same '
              'day. If you only remember the next day, take that day\'s dose '
              'as usual and do not double up — the hormone stays in your body '
              'for a long time and one missed tablet does not undo anything.'),
          _en('If you have missed several, say so at your next visit. Nobody '
              'is going to be cross, and it changes how the next blood test is '
              'read — a level that looks wrong because doses were missed leads '
              'to a dose increase that is not actually needed.'),
          _en('Do not stop because you feel well. Feeling well is the tablet '
              'working, and stopping in the middle of a pregnancy is the one '
              'genuinely risky thing you can do with it.'),
        ],
      ),

      PvReadSection(
        heading: _en('After the birth'),
        collapsible: true,
        summary: _en('The dose usually drops back, and the tablet is safe '
            'while breastfeeding.'),
        paragraphs: [
          _en('Most women go back to roughly their pre-pregnancy dose after '
              'delivery, and a blood test a few weeks later confirms where it '
              'should sit. Do not adjust it yourself.'),
          _en('The tablet is safe while breastfeeding. Only tiny amounts reach '
              'the milk and it is the same hormone your baby needs anyway.'),
          _en('Some women who had a normal thyroid before pregnancy develop a '
              'temporary problem in the months after birth. Tiredness and low '
              'mood in that period are usually just new parenthood — and if '
              'you had thyroid trouble in pregnancy, it is worth mentioning '
              'them rather than assuming.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Speak to your doctor if'),
      body: _en('You have a racing heart, feel very jittery or are losing '
          'weight — a dose can be too high as well as too low. Also call if '
          'you have run out of tablets, or have missed them for more than a '
          'few days. Never stop or change the dose on your own.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('Can I take it with my iron tablet to save time?'),
        answer: _en('No — that is the change most likely to make it stop '
            'working. Keep four hours between them: the thyroid tablet in the '
            'morning, the iron later in the day.'),
      ),
      PvReadFaq(
        question: _en('Do I need iodised salt as well?'),
        answer: _en('Use iodised salt, yes. It is not a substitute for the '
            'tablet, and iodine levels vary a lot by region in India, which is '
            'part of why thyroid problems are picked up so often here.'),
      ),
      PvReadFaq(
        question: _en('Will my baby have a thyroid problem?'),
        answer: _en('Treated properly, this is not usually passed on. Newborns '
            'in India are commonly screened for thyroid problems anyway as '
            'part of routine checks.'),
      ),
      PvReadFaq(
        question: _en('Different brands — does it matter?'),
        answer: _en('Try to stay on the same brand through the pregnancy if '
            'you can. Small differences between manufacturers can shift your '
            'levels enough to be noticed, and switching mid-way makes a blood '
            'test harder to interpret.'),
      ),
    ],

    evidence: _en('American Thyroid Association guidelines for thyroid disease '
        'during pregnancy and postpartum · Indian Thyroid Society '
        'recommendations · Ministry of Health and Family Welfare national '
        'iodine programme · Reviewed September 2026.'),

    readNext: ['preg_cond_read_iron', 'preg_cond_read_sugar_india'],
  ),

  // ===========================================================================
  //  6. Iron, from food and tablets
  // ===========================================================================
  PvRead(
    id: 'preg_cond_read_iron',
    hue: _hue,
    kicker: _en('Complications & conditions'),
    title: _en('Iron, from food and tablets'),
    teaser: _en('Why the tablets upset your stomach, what to take them with, '
        'and which foods actually help.'),

    scaleSetter: _en('Low iron is the commonest thing found in Indian '
        'pregnancies by a wide margin, and it is also among the most '
        'straightforward to correct. Most of the difficulty is not medical — '
        'it is that the tablets are unpleasant and easy to abandon quietly.'),

    author: _en('Dr. Anita Desai'),
    authorRole: _en('Obstetrician · 21 years · reviewed September 2026'),

    sections: [
      PvReadSection(
        paragraphs: [
          _en('Your blood volume rises substantially in pregnancy, and iron is '
              'what lets that extra blood carry oxygen. Demand roughly doubles '
              'over nine months, which is more than most diets supply and more '
              'than most bodies have in store — which is why iron is given to '
              'nearly every pregnant woman in India rather than only to those '
              'who test low.'),
          _en('Being low makes you tired, breathless on stairs, and less able '
              'to cope with the ordinary blood loss of a delivery. It is worth '
              'fixing for how you feel, not only for a number on a report.'),
        ],
        callout: PvCallout(
          tone: PvCalloutTone.reassure,
          title: _en('Tiredness is not proof of anything'),
          body: _en('Pregnancy is tiring whether your iron is low or not, and '
              'plenty of women with low iron feel fine. It is a blood test '
              'that answers this, not how you feel — which is why the test is '
              'routine.'),
        ),
      ),

      PvReadSection(
        heading: _en('Making the tablets bearable'),
        paragraphs: [
          _en('Constipation, nausea, a metallic taste and black stools are the '
              'usual complaints. The black stools are harmless and expected. '
              'The rest can almost always be improved without stopping.'),
        ],
        bullets: [
          _en('Take it with vitamin C and it is absorbed far better — a '
              'glass of nimbu pani, an orange, or amla alongside the tablet. '
              'This is the single most useful habit here.'),
          _en('Never with tea, coffee or milk. Tannins and calcium both block '
              'absorption substantially, and chai with the tablet is the '
              'commonest way a full dose does almost nothing. Leave an hour on '
              'either side.'),
          _en('If it makes you sick on an empty stomach, take it after a small '
              'meal. Slightly less is absorbed, and a tablet you keep taking '
              'beats a better-absorbed one you stop.'),
          _en('For constipation: more water, more fibre, and ask about a stool '
              'softener rather than abandoning the iron. It is a very common '
              'request and easily answered.'),
          _en('If one preparation is intolerable, ask about another. There are '
              'several forms and they differ a lot in how they sit; some '
              'people also do better taking it every other day.'),
        ],
      ),

      PvReadSection(
        heading: _en('Iron from food, honestly'),
        paragraphs: [
          _en('Food matters and food alone will usually not correct a real '
              'deficiency in pregnancy. Both halves of that sentence are true '
              'and the second one is the reason the tablets exist.'),
          _en('Iron from meat, fish and eggs is absorbed several times more '
              'readily than iron from plants. If you eat them, they are the '
              'most efficient route by a distance.'),
          _en('On a vegetarian diet the useful sources are dal and rajma, '
              'green leafy vegetables, ragi, bajra, jaggery, sesame, dates and '
              'raisins. Sprouting, soaking and fermenting all meaningfully '
              'improve how much of that iron you actually absorb — which is '
              'part of why idli and dosa batter is treated the way it is.'),
          _en('Cooking in an iron kadhai genuinely adds some iron to the food, '
              'particularly with something acidic. It is a real effect and a '
              'small one — a helpful habit, not a treatment.'),
        ],
        tip: PvReadTip(
          title: _en('The pairing that does the work'),
          body: _en('Put a source of vitamin C in the same meal as your iron-'
              'rich food — lemon over the dal, tomato in the sabzi, amla or '
              'guava afterwards. It changes how much you absorb far more than '
              'swapping one iron-rich food for another.'),
        ),
      ),

      PvReadSection(
        heading: _en('When tablets are not enough'),
        paragraphs: [
          _en('If your level is very low, or if you cannot tolerate tablets, '
              'or if you are close to your due date and there is not enough '
              'time for tablets to work, you may be offered iron directly into '
              'a vein.'),
          _en('It is given in hospital or a day-care unit, takes an hour or '
              'so, and is a normal part of Indian antenatal practice rather '
              'than a sign that something has gone badly wrong. It works much '
              'faster than tablets.'),
          _en('Very severe anaemia close to delivery is occasionally treated '
              'with a transfusion. That is uncommon, and it is one of the '
              'reasons the routine testing exists — the point of finding it '
              'early is precisely so it never gets there.'),
        ],
      ),

      PvReadSection(
        heading: _en('After the birth'),
        collapsible: true,
        summary: _en('Keep taking it — delivery is when the stores are most '
            'depleted.'),
        paragraphs: [
          _en('You will usually be asked to continue iron for some months '
              'after the birth. A delivery involves real blood loss, and '
              'rebuilding stores takes far longer than losing them did.'),
          _en('It matters for how you feel in a period when you are already '
              'exhausted, and low iron after birth is easy to mistake for '
              'ordinary new-parent tiredness. If you are still breathless on '
              'stairs at three months, ask for a test rather than assuming.'),
          _en('Iron tablets are safe while breastfeeding.'),
        ],
      ),
    ],

    whenToSeeSomeone: PvCallout(
      tone: PvCalloutTone.urgent,
      title: _en('Call your doctor if'),
      body: _en('You are breathless at rest, have chest pain or a racing '
          'heart, or feel faint when you stand. Also call if you cannot keep '
          'the tablets down at all — there are other ways to give iron, and '
          'stopping quietly is the one option that leaves you low.'),
    ),

    faqs: [
      PvReadFaq(
        question: _en('My stools have gone black. Is that a problem?'),
        answer: _en('No, that is expected with iron and is harmless. Black '
            'stools that are sticky and foul-smelling, or any blood, are '
            'different and need a call.'),
      ),
      PvReadFaq(
        question: _en('Can I take iron and calcium together?'),
        answer: _en('Better not — calcium blocks iron absorption. Iron at one '
            'time of day and calcium at another. If you also take a thyroid '
            'tablet, that goes first thing and the iron much later.'),
      ),
      PvReadFaq(
        question: _en('Is beetroot or pomegranate juice enough?'),
        answer: _en('They are healthy and they are not iron treatments — '
            'neither contains much iron. Their reputation is largely about '
            'colour. Keep them if you enjoy them, and keep the tablet.'),
      ),
      PvReadFaq(
        question: _en('How long until I feel better?'),
        answer: _en('Often two to four weeks for the tiredness to lift, and '
            'considerably longer to rebuild stores — which is why the course '
            'continues after your report looks normal.'),
      ),
    ],

    evidence: _en('Ministry of Health and Family Welfare, Anemia Mukt Bharat '
        'operational guidelines · WHO recommendations on antenatal iron and '
        'folic acid supplementation · FOGSI recommendations on anaemia in '
        'pregnancy · Reviewed September 2026.'),

    readNext: ['preg_cond_read_sugar_india', 'preg_cond_read_thyroid_tablet'],
  ),
];
