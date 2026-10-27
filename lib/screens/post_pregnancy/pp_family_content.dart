// =============================================================================
//  Your growing family — the parenting Family section
// -----------------------------------------------------------------------------
//  Built 2026-10-02 from the parenting gap analysis
//  (`docs/gap-analysis/parenting/`). What to Expect and theAsianparent both
//  carry a shelf on second babies, fathers and siblings; ParentVeda had none.
//  Two areas come from the analysis (A second baby, For fathers). Three are
//  the Indian home those pieces leave out: grandparents and the joint family,
//  brothers and sisters, and who looks after him when you work.
//
//  ⚠️ WRITTEN NEW, NEVER COPIED. The competitor pieces were a list of
//  questions; every answer here is ours, for an Indian family.
//
//  ⚠️ NO BANDS ON MOST PAGES. A second pregnancy, a father's low mood or a
//  grandmother's advice is not tied to the child's age. Where a page plainly
//  is (tandem feeding, settling into a creche), it says so.
//
//  Door 13 (2026-10-26, `docs/pp-door-plans/13-family.md`): the fathers'
//  newborn pages tagged to the first year, tandem feeding from one (FM1);
//  every page linked to the door that answers the next question (FM2); two
//  short pages, "You two, after the baby" and "Doing it on your own", that
//  hold only what You, Maa's people pages do not (FM3); the Care tab links
//  You, Maa's back-to-work pages and writes none of its own (FM6). Five areas,
//  18 pages. Tele-MANAS is always its own card, read from the constant.
//  `test/pp_family_door_test.dart` holds it.
// =============================================================================

import '../../data/mind_mood_data.dart'
    show kCrisisHelplineName, kCrisisHelplineNumber, kEmergencyNumber;
import '../brackets/hub/hub_intent_art.dart';
import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

final PpSection kPpFamilySection = PpSection(
  id: 'parenting_family', // MUST match the hub's bracketId.
  title: 'Your growing family',
  subtitle: 'A second baby, fathers, grandparents and siblings',
  autoScope: true,
  intro: 'A baby changes everyone in the house, parents and all. Here\'s '
      'help for each of them: a sibling-to-be, a new father, grandparents '
      'with strong views, and care for your child when you return to '
      'work.',
  bandSet: kPpChildBands,
  areas: [
    // =========================================================================
    //  1. A SECOND BABY
    // =========================================================================
    PpArea(
      id: 'second_baby',
      mark: IntentMark.cuppedHands,
      title: 'A second baby on the way',
      blurb: 'Telling your firstborn, getting ready, and the first weeks with '
          'two.',
      hue: 322,
      pages: [
        PpPage(
          id: 'fam_telling_toddler',
          title: 'Telling your child a baby is coming',
          subtitle: 'When, how, and what to expect',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Your firstborn is about to become a big brother or '
                'sister, one of the biggest changes of early childhood. How '
                'you share the news matters less than you fear. What matters '
                'is hearing it from you, and feeling just as loved afterwards.'),
            PpSteps(heading: 'When to tell your child', [
              PpStep('Under two',
                  'Time means little yet. Wait until your bump shows, or the '
                      'last few months, so nine months doesn\'t feel '
                      'endless.'),
              PpStep('Two to four',
                  'Tell your child before someone else does. Relatives talk, '
                      'and children overhear everything.'),
              PpStep('Link it to something familiar',
                  '"The baby will come when it is cold again", or "after '
                      'Diwali", is easier than a month.'),
            ]),
            PpSteps(heading: 'How to tell your child', [
              PpStep('Keep it short and true',
                  '"There is a baby growing in Mummy\'s tummy. You are going '
                      'to be a big brother."'),
              PpStep('Be honest about what babies are like',
                  'They cry, sleep and drink milk, and can\'t play for a long '
                      'time. That avoids a disappointed "send it back".'),
              PpStep('Read picture books about a new baby',
                  'Welcome the same questions again and again.'),
              PpStep('Look at your firstborn\'s baby photos together',
                  'Children love hearing about when they were tiny, and that '
                      'you looked after them too.'),
            ]),
            PpCallout('Make big changes, like a new bed, starting potty '
                'training or a new playschool, a couple of months before the '
                'baby arrives or a couple of months after. Not in the same '
                'week.'),
            PpIndiaNote('Grandparents sometimes tease, "Now no one will love '
                'you." It\'s meant as a joke and lands as a fear. A gentle '
                'word with them in advance saves a lot of tears.'),
            // FM2: the kids shelf on its own screen, New Sibling chosen
            // (BHO4). Never the whole library.
            PpLink('Picture books about a new baby',
                surfaceId: 'pp_books/New sibling',
                blurb: 'Books to read together, while you wait.'),
          ],
        ),
        PpPage(
          id: 'fam_getting_ready',
          title: 'Getting your firstborn ready for the baby',
          subtitle: 'Small jobs, time of their own, and practice',
          format: 'CARDS',
          blocks: [
            PpIntro('You can\'t stop a little jealousy, and you don\'t need '
                'to. You can help your firstborn feel part of the team, so the '
                'baby arrives into a family rather than taking anyone\'s place.'),
            PpCards([
              PpCard('Give your firstborn a job',
                  'Choosing the baby\'s clothes, a toy to give, or fetching '
                      'nappies later. Being needed beats being displaced.'),
              PpCard('Practise with a doll',
                  'Holding a baby gently, patting, singing. It shows what '
                      'gentle means before the real baby arrives.'),
              PpCard('Plan the days while you are in hospital',
                  'Who will look after your firstborn, where bedtime will be, '
                      'and a short visit if the hospital allows.'),
              PpCard('A gift from the baby',
                  'A small present "from the baby" at the first meeting works '
                      'surprisingly well.'),
              PpCard('Protect one special time',
                  'Story at bedtime, or a walk with Papa, that stays the same '
                      'after the baby comes.'),
            ]),
            PpWhenLine('Start a month or two before your due date. Keep the '
                'favourite routines exactly the same through the change.'),
            // FM2: the days in hospital are often the first time apart.
            // Behaviour owns separation.
            PpLink('My child cries every time I leave',
                surfaceId: 'pp_page/parenting_behaviour/separation',
                blurb: 'If the days you are in hospital worry you.'),
            PpLink('Picture books about a new baby',
                surfaceId: 'pp_books/New sibling'),
          ],
        ),
        PpPage(
          id: 'fam_first_weeks_two',
          title: 'The first weeks with two',
          subtitle: 'Feeding the baby with a toddler at your knee',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('The first weeks with a newborn and an older child are '
                'hard on everyone. Feeding time is often when your toddler '
                'acts out most, because that\'s when you are plainly busy. '
                'That\'s normal, and it settles.'),
            PpSteps(heading: 'Making feeds easier', [
              PpStep('Keep a feeding basket',
                  'A few special toys or books that only come out while you '
                      'feed the baby.'),
              PpStep('Bring your toddler close',
                  'Read, sing, or have your toddler sit beside you with a '
                      'snack while you feed.'),
              PpStep('Talk to your toddler too, not only the baby',
                  '"The baby is having milk. Shall we do a puzzle '
                      'together after?"'),
              PpStep('Ask for help at the hard times',
                  'Someone to take your toddler out during evening feeds can '
                      'change the whole day.'),
            ]),
            PpSteps(heading: 'Keeping the newborn well', [
              PpStep('Hand washing on coming home',
                  'From school, playschool or the park, before touching the '
                      'baby.'),
              PpStep('Kisses on the feet, not the face',
                  'Make it a game, not a rule that feels like a punishment.'),
              PpStep('If your older child is unwell, keep a little distance',
                  'Coughs and runny noses are much harder on a newborn.'),
            ]),
            PpCallout('If your older child has a fever, cough or rash and the '
                'baby is under three months, ask your paediatrician what to '
                'watch for. A fever in a young baby always needs a doctor.',
                kind: PpCalloutKind.doctor),
            PpWhenLine('Expect some going backwards: wanting a bottle, '
                'accidents after being dry, baby talk. Extra cuddles help more '
                'than scolding, and it usually passes in a few weeks.'),
          ],
        ),
        PpPage(
          id: 'fam_age_gap',
          title: 'Is there a best age gap between children?',
          subtitle: 'What your body needs, and what families find',
          format: 'ARTICLE',
          blocks: [
            PpIntro('There\'s no perfect age gap, and every family finds its '
                'own rhythm. There is one piece of real health advice about '
                'spacing, and the rest is about what suits your family.'),
            PpArticle(heading: 'What doctors advise', [
              'The World Health Organization suggests waiting at least two '
                  'years after a birth before trying to get pregnant again. '
                  'That means about three years between children. It gives '
                  'your body time to rebuild iron and other stores. It also '
                  'lowers the chance of an early birth or a low birth weight '
                  'baby next time.',
              'After a caesarean, many doctors also advise waiting at least '
                  'eighteen months before the next pregnancy, to let the scar '
                  'heal well. Your own doctor knows your history best.',
            ]),
            PpCards(heading: 'What families tell us', [
              PpCard('Close together, under two years',
                  'Intense early years with two in nappies, then they grow up '
                      'as close playmates.'),
              PpCard('Two to four years',
                  'The older one is more independent and understands more. A '
                      'common choice.'),
              PpCard('Four years or more',
                  'The older child can really help and feels less displaced, '
                      'though the two play together less.'),
            ]),
            PpCallout('Talk to your gynaecologist about contraception at your '
                'six-week check. Breastfeeding alone isn\'t reliable '
                'protection once periods return or the baby starts other '
                'food.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'fam_tandem_feeding',
          title: 'Breastfeeding while pregnant, and feeding two',
          subtitle: 'Tandem feeding, honestly',
          // FM1: an older child still feeding is one or more.
          bands: ['toddler_1', 'toddler_2', 'preschool'],
          format: 'ARTICLE',
          blocks: [
            PpIntro('Some mothers are still breastfeeding when they find '
                'they\'re pregnant again, and wonder whether to stop. For most '
                'healthy pregnancies, you don\'t have to. Whether you carry '
                'on is your choice.'),
            PpArticle([
              'In a healthy pregnancy, breastfeeding is generally safe. Your '
                  'milk often drops and changes taste around the middle of '
                  'pregnancy, and many toddlers wean themselves then. Others '
                  'carry on. After the birth some mothers feed both, which '
                  'is called tandem feeding.',
              'Tandem feeding can comfort a toddler through the change and '
                  'helps your milk come in. It can also be tiring, and some '
                  'mothers feel touched-out or irritable while feeding. Both '
                  'feelings are common and neither is wrong.',
            ]),
            PpSteps(heading: 'If you tandem feed', [
              PpStep('The newborn feeds first',
                  'Especially in the first days, when the colostrum is for the newborn.'),
              PpStep('Eat and drink well',
                  'You\'re feeding two. Water by your side at every feed.'),
              PpStep('It\'s fine to set limits',
                  'Fewer feeds for the older one, or only at bedtime.'),
            ]),
            PpCallout('Ask your doctor before continuing if you have had a '
                'miscarriage or early labour before, bleeding or pain in '
                'this pregnancy, or if you are carrying twins.',
                kind: PpCalloutKind.doctor),
            // FM2: Feeding owns the latch and the supply.
            PpLink('Getting the latch right',
                surfaceId: 'pp_page/parenting_feeding/bf_latch',
                blurb: 'For the newborn, from the first feed.'),
            PpLink('Making enough milk, and keeping it',
                surfaceId: 'pp_page/parenting_feeding/bf_supply'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  2. FOR FATHERS
    // =========================================================================
    PpArea(
      id: 'fathers',
      mark: IntentMark.compassMark,
      title: 'For fathers',
      // FM4: the tab keeps its name; the blurb names parents on their own.
      // Kept for revert:
      // blurb: 'Your own feelings, and how to support your partner and the baby.',
      blurb: 'Your own feelings, how to support your partner and the baby, and '
          'parents on their own.',
      hue: 206,
      pages: [
        PpPage(
          id: 'fam_dad_depression',
          title: 'When fathers feel low after a baby',
          subtitle: 'It happens to dads too, and it\'s treatable',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Everyone asks how the mother and baby are. Fewer people '
                'ask how you are. About one in ten fathers feels depressed in '
                'the year after a baby arrives. It\'s real, it\'s common, and '
                'it gets better with help.'),
            PpCards(heading: 'How it can show in men', [
              PpCard('Irritability and anger',
                  'Snapping at small things, more than sadness.'),
              PpCard('Pulling away',
                  'Working longer, staying on the phone, avoiding home.'),
              PpCard('Drinking or smoking more', 'Using them to cope or switch off.'),
              PpCard('Feeling useless or trapped',
                  'Or that the family would be better off without you.'),
              PpCard('Tired, but not sleeping when you can', 'Lying awake even when the baby is asleep.'),
            ]),
            PpArticle(heading: 'Why it happens', [
              'Lost sleep, money worries, a changed relationship, pressure to '
                  'provide, and less time with your partner all add up. '
                  'Fathers whose partners are depressed are at higher risk '
                  'too, so it\'s worth both of you being checked.',
            ]),
            PpSteps(heading: 'What helps', [
              PpStep('Say it out loud', 'To your partner, a friend or a '
                  'doctor. Naming it is the first step.'),
              PpStep('Sleep in shifts', 'So each of you gets one longer '
                  'stretch.'),
              PpStep('Move your body', 'A daily walk, even with the pram.'),
              PpStep('Talk to a doctor or counsellor',
                  'Talking therapy works well, and medicine helps when it\'s '
                      'needed.'),
            ]),
            // FM2 / BH4 rule c: the helpline is its own card, never inside
            // the doctor box. Kept for revert:
            // PpCallout('If you have thoughts of harming yourself or anyone '
            //     'else, get help today: call Tele-MANAS on 14416, free and any '
            //     'time, or go to a hospital.',
            //     kind: PpCalloutKind.doctor),
            PpCallout('If you have thoughts of harming yourself or anyone '
                'else, get help today: see a doctor, or go to a hospital. If '
                'you have felt low for more than two weeks, your own doctor is '
                'the right first step.',
                kind: PpCalloutKind.doctor),
            // REQUIRED_REVIEW (Tele-MANAS, MoHFW; the number is
            // REQUIRED_TO_CONFIRM at the constant).
            PpCallout('Free, any hour: $kCrisisHelplineName, '
                '$kCrisisHelplineNumber. Fathers call too. Trained counsellors, '
                'in your language.',
                title: 'If there is nobody to talk to'),
            // FM2: You, Maa owns the anger.
            PpLink('The anger nobody warned me about',
                surfaceId: 'pp_page/parenting_maternal/mind_rage',
                blurb: 'Written for mothers. The snapping and the shame read '
                    'the same for fathers.'),
          ],
        ),
        PpPage(
          id: 'fam_dad_breastfeeding',
          title: 'How you can help with breastfeeding',
          subtitle: 'You can\'t breastfeed, but you can do almost everything '
              'else',
          bands: ['infant'], // FM1: the fathers' newborn pages
          format: 'CARDS',
          blocks: [
            PpIntro('Breastfeeding goes better with a partner on the same '
                'side. Mothers whose partners support it feed longer and feel '
                'more confident. Here is what that looks like day to day, '
                'in practice.'),
            PpCards([
              PpCard('Bring the baby, take the baby',
                  'At night, bring the baby for the feed. Then burp, change '
                      'and settle the baby so your partner can sleep again.'),
              PpCard('Keep your partner fed',
                  'A glass of water and a snack within reach of every feed.'),
              PpCard('Learn the latch together',
                  'Go to the lactation visit. A second pair of eyes helps, '
                      'since the baby\'s mouth is hard to see while feeding.'),
              PpCard('Stand together',
                  'When relatives say "your milk is not enough, give a '
                      'bottle", back your partner, and the doctor\'s advice.'),
              PpCard('Your own bond',
                  'Bath time, skin-to-skin, walks and lullabies are yours. '
                      'Your baby will know you just as well.'),
            ]),
            PpArticle(heading: 'If you feel left out', [
              'Many fathers feel a little shut out of the feeding bond, or '
                  'unsure about seeing breasts as feeding rather than '
                  'intimate. Both are common. Say so kindly, and find the '
                  'jobs that are yours. Closeness between you returns as '
                  'sleep returns.',
            ]),
            // FM2: Feeding owns the latch and the supply; Behaviour's What to
            // say owns the words for the relatives ("Stand together" above).
            PpLink('Getting the latch right',
                surfaceId: 'pp_page/parenting_feeding/bf_latch',
                slide: 'Learn the latch together'),
            PpLink('Making enough milk, and keeping it',
                surfaceId: 'pp_page/parenting_feeding/bf_supply'),
            PpLink('When they say "your milk isn\'t enough"',
                surfaceId: 'pp_scripts/family_milk',
                blurb: 'The words that back her up, without a fight.'),
          ],
        ),
        // The father strand (2026-10-07, gap analysis P1, Behind · Partner):
        // "a page each on paternity leave, the night shift, bonding, and her
        // mood after the birth". Her mood is `people_partner_anxiety` below.
        PpPage(
          id: 'fam_dad_leave',
          title: 'Paternity leave: what you can take',
          subtitle: 'What the rules give, and how to use the days well',
          format: 'SHORT ARTICLE',
          // REQUIRED_REVIEW (HR or legal): the central government figure.
          blocks: [
            PpIntro('The first weeks at home are when a father learns the '
                'baby, and when a mother needs the most help. Leave is worth '
                'asking for, even a few days.'),
            PpArticle(heading: 'What the rules give', [
              'Central government employees get 15 days of paternity leave, '
                  'taken within six months of the birth.',
              'There is no law yet that makes private companies give it. Many '
                  'do, often one to four weeks. Ask HR, and ask early, so the '
                  'dates can be planned.',
            ]),
            PpSteps(heading: 'Making the days count', [
              PpStep('Take some days right after the birth, when recovery is hardest.'),
              PpStep('Keep a few back for the weeks after relatives leave.'),
              PpStep('Learn the baby\'s care yourself: nappies, bath, settling.'),
              PpStep('Take one night shift each night you are home.'),
            ]),
            // FM2: You, Maa owns the leave rules, paternity and child care
            // leave included (Papers has no leave page, PM2).
            PpLink('What your maternity leave entitles you to',
                surfaceId: 'pp_page/parenting_maternal/work_your_entitlement',
                blurb: 'Paternity leave and child care leave are on it too.'),
          ],
        ),
        PpPage(
          id: 'fam_dad_night_shift',
          title: 'The night shift',
          subtitle: 'Splitting the nights so both of you sleep',
          bands: ['infant'], // FM1: the fathers' newborn pages
          format: 'CARDS',
          blocks: [
            PpIntro('Broken sleep is the hardest part of the early months. '
                'Splitting the night gives each of you one long stretch, and '
                'one long stretch does more good than many short ones.'),
            PpCards([
              PpCard('Split the night in two',
                  'One of you is on from bedtime to about 2am, the other from '
                      '2am to morning. The one off sleeps in another room, '
                      'with earplugs if needed.'),
              PpCard('If she is breastfeeding',
                  'Bring the baby to her for the feed. Then you burp, change '
                      'and settle, so she goes straight back to sleep.'),
              PpCard('If there is a bottle',
                  'Expressed milk or formula means you can do a whole feed. '
                      'Make it up fresh each time.'),
              PpCard('Stay safe when you are tired',
                  'Never doze off with the baby on a sofa or armchair. If you '
                      'feel sleep coming, put the baby down on the back in '
                      'the cot.'),
            ]),
          ],
        ),
        PpPage(
          id: 'fam_dad_bonding',
          title: 'Getting close to your baby',
          subtitle: 'The bond grows from small, everyday care',
          bands: ['infant'], // FM1: the fathers' newborn pages
          format: 'SHORT ARTICLE',
          blocks: [
            PpIntro('Many fathers do not feel a rush of love on day one. That '
                'is common. Closeness grows from the hours you spend caring, '
                'and it grows quickly.'),
            PpSteps(heading: 'Things that are yours', [
              PpStep('Skin to skin: the baby in a nappy, on your bare chest.'),
              PpStep('The bath, every time, so it becomes your job.'),
              PpStep('Talk and sing while you change or carry. Your voice is learned fast.'),
              PpStep('A walk with the baby in a carrier or pram, every day.'),
              PpStep('Read aloud, even to a newborn. It is the voice that matters.'),
            ]),
            PpArticle(heading: 'If it still feels distant', [
              'If weeks pass and you feel flat, cut off, or low most days, it '
                  'may be more than tiredness. Fathers get low after a baby '
                  'too. Talk to your doctor; it can be treated.',
            ]),
          ],
        ),
        // Moved here from You, Maa when this door was built (P1 from the gap
        // analysis); the page id is unchanged.
        PpPage(
          id: 'people_partner_anxiety',
          title: 'When your partner is anxious, not only tired',
          subtitle: 'How to notice, what to say, and how to help her get '
              'support',
          format: 'ARTICLE',
          blocks: [
            PpIntro('After a baby, some worry is normal. But for many '
                'mothers, around one in five, the worry grows into anxiety '
                'that won\'t switch off. It\'s common, it\'s nobody\'s '
                'fault, and it gets better with help. You are often the first '
                'person who can see it.'),
            PpCards(heading: 'What it can look like', [
              PpCard('Worry that won\'t stop',
                  'Checking the baby again and again, unable to rest even '
                      'while the baby sleeps.'),
              PpCard('Frightening thoughts',
                  'Pictures of something bad happening to the baby that pop '
                      'into her head. These are a symptom of anxiety, not a '
                      'wish.'),
              PpCard('A body on alert',
                  'A racing heart, tight chest, trouble breathing, not '
                      'sleeping even when exhausted, not eating.'),
              PpCard('Needing control',
                  'Not letting anyone else hold or feed the baby, or getting '
                      'very upset when routines change.'),
            ]),
            PpScript(heading: 'What you can say', [
              PpScriptLine(
                  say: 'You seem really worried lately. I am here. How are '
                      'you feeling, really?',
                  notThis: 'You are overthinking. Just relax.',
                  why: 'Being told to relax leaves a person feeling unheard.'),
              PpScriptLine(
                  say: 'Lots of new mothers feel this. Shall we talk to the '
                      'doctor together?',
                  why: 'It makes asking for help feel ordinary, and shared.'),
            ]),
            PpSteps(heading: 'How to help', [
              PpStep('Take over a night or a feed',
                  'Sleep loss makes anxiety much worse.'),
              PpStep('Go to the doctor together',
                  'Her obstetrician or GP can help, and refer on if needed. '
                      'Write down what you have noticed.'),
              PpStep('Gently hold back the advice',
                  'Too many voices saying what she is doing wrong feeds the '
                      'worry. Be the calm one.'),
            ]),
            // Door 13, fixed in passing (BH4 rule c): the helpline was typed
            // inside the doctor box. Kept for revert:
            // PpCallout('Get help today if your partner talks about self-harm or '
            //     'harming the baby, or seems confused or not at all herself. '
            //     'Call her doctor, go to a hospital, or call Tele-MANAS on '
            //     '14416, free and any time.',
            //     kind: PpCalloutKind.doctor),
            PpCallout('Get help today if your partner talks about self-harm or '
                'harming the baby, or seems confused or not at all herself. '
                'Call her doctor, or go to a hospital.',
                kind: PpCalloutKind.doctor),
            // REQUIRED_REVIEW (Tele-MANAS; the number is REQUIRED_TO_CONFIRM
            // at the constant).
            PpCallout('Free, any hour: $kCrisisHelplineName, '
                '$kCrisisHelplineNumber. For her, or for you. Trained '
                'counsellors, in your language.',
                title: 'If there is nobody to talk to'),
          ],
        ),
        // FM3: "Doing it on your own". You, Maa already owns asking for help
        // (`people_asking_for_help`) and maintenance, legal aid and the
        // birth certificate for a mother on her own (`people_separated`), so
        // this page holds only what those do not: a father on his own too,
        // the small circle, the papers a single parent signs alone, one thing
        // that's yours, and losing a partner. REQUIRED_REVIEW (legal: step 3;
        // clinical: the doctor line).
        PpPage(
          id: 'fam_on_your_own',
          title: 'Doing it on your own',
          subtitle: 'For a single mother or father',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Whether you\'re a single mother or a single father, '
                'through choice, separation or loss, you\'re doing two '
                'people\'s work. This page is for you.'),
            PpSteps([
              PpStep('Ask for help, and name it',
                  '"Can you take the baby from 5 to 7 on Saturday" works far '
                      'better than "let me know if I can help".'),
              PpStep('Build a small circle',
                  'One or two people who can come at short notice, a '
                      'neighbour, and a parent group, online or near you.'),
              PpStep('The papers are yours to sign',
                  'A single parent can apply for the birth certificate, the '
                      'child\'s Aadhaar and the passport on their own. Name a '
                      'guardian in a will, in case anything happens to you.'),
              PpStep('Keep one thing that\'s yours',
                  'A walk, a call with a friend, an hour on Sunday. It is not '
                      'a luxury; it is what keeps you going.'),
              PpStep('If you have lost your partner',
                  'Grief and a baby together are a lot to carry. It\'s all '
                      'right to need help, and to take it for as long as you '
                      'need it.'),
            ]),
            PpLink('Asking for help without apologising for it',
                surfaceId: 'pp_page/parenting_maternal/people_asking_for_help'),
            PpLink('Parenting apart: separation, divorce and new families',
                surfaceId: 'pp_page/parenting_maternal/people_separated',
                blurb: 'Maintenance, free legal aid, and the birth certificate '
                    'if you are on your own from the start.'),
            PpLink('The birth certificate: the first and most important',
                surfaceId: 'pp_page/parenting_papers/pm_birth_certificate'),
            PpLink('Nominees, a will, and who would care for your child',
                surfaceId: 'pp_page/parenting_papers/pm_planning_ahead'),
            PpCallout('If you feel low most days, can\'t sleep or eat, or '
                'can\'t cope, talk to your doctor. It is treatable, and asking '
                'is not failing.',
                kind: PpCalloutKind.doctor),
            // REQUIRED_REVIEW (Tele-MANAS; the number is REQUIRED_TO_CONFIRM
            // at the constant).
            PpCallout('Free, any hour: $kCrisisHelplineName, '
                '$kCrisisHelplineNumber. Trained counsellors, in your '
                'language.',
                title: 'If there is nobody to talk to'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  3. GRANDPARENTS AND THE JOINT FAMILY
    // =========================================================================
    PpArea(
      id: 'grandparents',
      mark: IntentMark.lampMark,
      title: 'Grandparents and the joint family',
      blurb: 'A great support, and sometimes a lot of advice.',
      hue: 28,
      pages: [
        PpPage(
          id: 'fam_grandparents_help',
          title: 'Raising your child with grandparents close by',
          subtitle: 'The gift, the friction, and keeping it kind',
          format: 'ARTICLE',
          blocks: [
            PpIntro('In many Indian homes, grandparents are a child\'s second '
                'parents. That is a real gift: more love, more hands, and a '
                'deep sense of family. It also means a lot of opinions. Most '
                'friction comes from love on both sides.'),
            PpArticle([
              'Much of the advice you hear is wise, and some is out of date. '
                  'Practices that were normal thirty years ago are now known '
                  'to be unsafe, like tummy sleeping, or water and herbal drops for '
                  'a newborn. That isn\'t their fault. Advice changes as we '
                  'learn.',
              'Sort the few things that are about safety, where you hold '
                  'firm, from the many that are just a different way. Those '
                  'you can let go.',
            ]),
            PpCards(heading: 'Hold firm on', [
              PpCard('Safe sleep', 'Always on the back, nothing soft around.'),
              PpCard('Nothing but milk before six months',
                  'No water, honey, herbal drops (ghutti) or gripe water.'),
              PpCard('Vaccines on time', 'On the schedule, not delayed for a festival or a cold.'),
              PpCard('Medicines only as the doctor says', 'No leftover or adult medicines.'),
            ]),
            PpCards(heading: 'Let go of', [
              PpCard('How many layers to wear', 'Within reason.'),
              PpCard('Lullabies, baby massage and stories',
                  'These are treasures. Let them share them.'),
              PpCard('A little extra indulgence', 'It\'s what grandparents are for.'),
            ]),
            PpScript(heading: 'Words that keep the peace', [
              PpScriptLine(
                  say: 'The doctor told us this changed recently. Shall I show '
                      'you what the doctor said?',
                  notThis: 'That is wrong, nobody does that any more.',
                  why: 'Putting the doctor between you takes the sting out.'),
              PpScriptLine(
                  say: 'You raised us so well. Can you help me with this '
                      'part?',
                  why: 'Asking for help with something else makes room to '
                      'hold firm on safety.'),
            ]),
            // FM2: Behaviour owns discipline across generations and the
            // family scripts (BH2); Traditions owns the pressure over
            // ceremonies.
            PpLink('When elders discipline differently',
                surfaceId: 'pp_page/parenting_behaviour/beh_elders'),
            PpLink('When they say you\'re spoiling the baby',
                surfaceId: 'pp_scripts/family_spoiling',
                blurb: 'What to say, word for word.'),
            PpLink('When they offer honey or gripe water',
                surfaceId: 'pp_scripts/family_honey',
                blurb: 'Holding firm on safety, kindly.'),
            PpLink('What to say when family wants it bigger',
                surfaceId: 'pp_page/parenting_traditional/family_pressure',
                blurb: 'When the ceremonies grow past what you want.'),
          ],
        ),
        PpPage(
          id: 'fam_couple_on_same_page',
          title: 'When you and your husband disagree about the baby',
          subtitle: 'Agree in private, speak as one',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Every couple disagrees about some parenting choices. In '
                'a joint family, each of you may also be caught between your '
                'partner and your own parents. A few habits help you stay a '
                'team.'),
            PpSteps([
              PpStep('Talk when the baby is asleep, not in the moment',
                  'Tired arguments at 2am rarely end well.'),
              PpStep('Each of you speaks to your own parents',
                  'A son talking to his mother is heard differently from a '
                      'daughter-in-law saying the same words.'),
              PpStep('Agree the few non-negotiables together',
                  'Usually safety, sleep and feeding. Then present them as '
                      '"we decided".'),
              PpStep('Let the rest be different',
                  'One way with Papa and another way with you is fine. '
                      'Children cope with that well.'),
            ]),
            PpCallout('If disagreements turn into shouting, threats or '
                'feeling afraid at home, that is not a normal parenting '
                'difference. Talk to someone you trust, or call the women\'s '
                'helpline on 181.',
                kind: PpCalloutKind.safety),
            // FM2: the next page, for the two of you.
            PpLink('You two, after the baby',
                surfaceId: 'pp_page/parenting_family/fam_you_two'),
          ],
        ),
        // FM3: "You two, after the baby". You, Maa already owns dividing the
        // work and the ten minutes a day (`people_partner`), sex, closeness
        // and contraception (`people_intimacy`), and safety at home
        // (`people_safe_at_home`). This page holds only what those do not:
        // that more arguing in the first year is common, how to argue less
        // and make up, written to both of you; and it links the rest.
        PpPage(
          id: 'fam_you_two',
          title: 'You two, after the baby',
          subtitle: 'More arguments, less time, and finding your way back',
          format: 'CARDS',
          blocks: [
            PpIntro('A baby changes a couple more than almost anything. Less '
                'sleep, less time, and two tired people. Arguing more in the '
                'first year is very common, and so is finding your way back.'),
            PpCards(heading: 'The fights', [
              PpCard('Most are about three things',
                  'Sleep, chores and the in-laws. Knowing that makes them '
                      'feel less personal.'),
              PpCard('One thing at a time, at a calm moment',
                  'Not at 3am and not in front of the family. Pick one '
                      'problem and agree one change.'),
              PpCard('Say what you need, not what they did',
                  '"I need two hours to sleep on Sunday" lands better than '
                      '"you never help".'),
              PpCard('Make up out loud',
                  'A "sorry, I was exhausted" closes a fight. Children who see '
                      'you make up learn that love survives an argument.'),
            ]),
            // REQUIRED_REVIEW (clinical: low desire while breastfeeding).
            PpCards(heading: 'Closeness', [
              PpCard('There is no deadline for sex',
                  'Low desire is very common in the first year, especially '
                      'while breastfeeding, from hormones and tiredness. '
                      'Closeness that is not sex counts, and usually comes '
                      'back first.'),
            ]),
            PpLink('Your partner, and the work that goes unseen',
                surfaceId: 'pp_page/parenting_maternal/people_partner',
                blurb: 'Dividing the jobs out loud, and ten minutes a day for '
                    'the two of you.'),
            PpLink('Sex, contraception, and the two of you',
                surfaceId: 'pp_page/parenting_maternal/people_intimacy',
                blurb: 'When, what helps, and why you can get pregnant before '
                    'your period returns.',
                slide: 'There is no deadline for sex'),
            PpCallout('If there is shouting, fear, control, or anyone is '
                'hurt, that isn\'t a normal rough patch. Call the women\'s '
                'helpline on 181, or $kEmergencyNumber in an emergency.',
                kind: PpCalloutKind.safety),
            PpLink('If you are not safe at home',
                surfaceId: 'pp_page/parenting_maternal/people_safe_at_home',
                slide: 'For safety'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  4. BROTHERS AND SISTERS
    // =========================================================================
    PpArea(
      id: 'siblings',
      mark: IntentMark.blocksMark,
      title: 'Brothers and sisters',
      blurb: 'Jealousy, fighting and being fair.',
      hue: 160,
      pages: [
        PpPage(
          id: 'fam_sibling_jealousy',
          title: 'Jealousy and fighting between siblings',
          subtitle: 'Normal, and a chance to learn',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Siblings fight. It\'s how children learn to share, '
                'negotiate and make up, and it doesn\'t mean they won\'t be '
                'close. Your job is to keep everyone safe and help them find '
                'their own way through, rather than stop every quarrel.'),
            PpSteps(heading: 'What helps', [
              PpStep('Give each child time alone with you',
                  'Even ten minutes a day, just the two of you, eases '
                      'jealousy more than anything else.'),
              PpStep('Don\'t compare',
                  '"Why can\'t you eat like your sister?" plants rivalry.'),
              PpStep('Fair is not the same as equal',
                  'Each child gets what is needed, not exactly the same '
                      'thing.'),
              PpStep('Step in for hitting, not for every squabble',
                  'Separate them calmly, then help both say what they '
                      'wanted.'),
              PpStep('Don\'t make the older one always give in',
                  '"You\'re older, just let the baby have it" breeds resentment.'),
            ]),
            PpScript(heading: 'Words to borrow', [
              PpScriptLine(
                  say: 'You both want the red car. What can we do?',
                  why: 'Hands them the problem to solve.'),
              PpScriptLine(
                  say: 'I will not let you hit. You can be angry. Let us '
                      'stamp our feet instead.',
                  why: 'The feeling is allowed; the hitting is not.'),
            ]),
            // FM2: Behaviour owns the fighting and the anger, Potty the
            // going backwards. All three link back here.
            PpLink('The fighting between them',
                surfaceId: 'pp_page/parenting_behaviour/siblings'),
            PpLink('Anger, and hurting out of it',
                surfaceId: 'pp_page/parenting_behaviour/beh_anger',
                blurb: 'When the jealousy comes out as hitting or biting.'),
            PpLink('It was going so well, and now it isn\'t',
                surfaceId: 'pp_page/parenting_potty/regressions',
                blurb: 'Accidents again after the new baby.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  5. WHO LOOKS AFTER HIM
    // =========================================================================
    PpArea(
      id: 'childcare',
      mark: IntentMark.checkMark,
      title: 'Who looks after your child when you work',
      blurb: 'Grandparents, a nanny or a creche, and settling in.',
      hue: 42,
      pages: [
        PpPage(
          id: 'fam_choosing_childcare',
          title: 'Choosing care: grandparents, a nanny or a creche',
          subtitle: 'What to look for in each',
          format: 'CARDS',
          blocks: [
            PpIntro('Going back to work is easier when you trust who is with '
                'your child. Each option has real strengths. The right one '
                'depends on your family, your work and your child.'),
            PpCards(heading: 'Grandparents', [
              PpCard('The strengths',
                  'Love, trust, and no cost. Your child stays at home.'),
              PpCard('Think about',
                  'Their health and energy, especially with a toddler who '
                      'runs. Agree the safety basics together.'),
            ]),
            PpCards(heading: 'A nanny at home', [
              PpCard('The strengths',
                  'One-to-one care, in your own home, on your timings.'),
              PpCard('Check',
                  'References from families she has worked with, and police '
                      'verification through your local station. Spend the '
                      'first few days at home together.'),
            ]),
            PpCards(heading: 'A creche or daycare', [
              PpCard('The strengths',
                  'Trained staff, other children, and a backup when one '
                      'carer is ill.'),
              PpCard('Visit and look for',
                  'Few children per carer, clean nappy and food areas, safe '
                      'sleep, CCTV you can view, and how they handle a sick '
                      'child or an emergency.'),
            ]),
            PpIndiaNote('Under the Maternity Benefit Act, an employer with 50 '
                'or more employees must provide a creche, and you can visit '
                'your child there during the day. Ask your HR.'),
            // FM6: going back to work is You, Maa's (`back_to_work`). Linked
            // by page, so a father or a grandparent finds them too; Family
            // writes none of its own.
            PpArticle(heading: 'Going back to work', [
              'Planning the return, your leave, the milk and the first week '
                  'each have a page of their own.',
            ]),
            PpLink('Planning your return, starting about four weeks out',
                surfaceId: 'pp_page/parenting_maternal/work_planning',
                blurb: 'Including the bottle, offered by someone else.'),
            PpLink('What your maternity leave entitles you to',
                surfaceId: 'pp_page/parenting_maternal/work_your_entitlement'),
            PpLink('Building a milk stash before you go back',
                surfaceId: 'pp_page/parenting_maternal/work_milk_stash'),
            PpLink('Pumping at work when there is no room to pump in',
                surfaceId: 'pp_page/parenting_maternal/work_pumping_no_room'),
            PpLink('The first week back',
                surfaceId: 'pp_page/parenting_maternal/work_first_week'),
          ],
        ),
        PpPage(
          id: 'fam_settling_in',
          title: 'Settling in with a new carer',
          subtitle: 'Short goodbyes, and a few weeks of patience',
          bands: ['infant', 'toddler_1', 'toddler_2', 'preschool'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Tears at drop-off are normal, especially between eight '
                'months and two years, when separation anxiety peaks. Most '
                'children settle within a few weeks, and many stop crying '
                'within minutes of you leaving.'),
            PpSteps([
              PpStep('Start before you go back',
                  'A few short sessions with you there, then a short time '
                      'without you, building up.'),
              PpStep('Send something from home',
                  'A soft toy, or a cloth that smells of you.'),
              // FM2 (§4 of the content file).
              PpStep('Keep the vaccination card ready',
                  'Most creches ask for your child\'s vaccination card before '
                      'the first day.'),
              PpStep('Make goodbyes short and warm',
                  'A hug, "I will come after your nap", and leave. Sneaking '
                      'away makes the next goodbye harder.'),
              PpStep('Always come back when you said',
                  'That\'s how children learn to trust the goodbye.'),
              PpStep('Ask the carer for a quick update',
                  'A photo or message once your child has settled helps you '
                      'through the day.'),
            ]),
            PpCallout('If, after a month, your child is still very '
                'distressed, not eating or sleeping, or frightened of one '
                'person, take it seriously. Talk to the carer and your '
                'paediatrician.',
                kind: PpCalloutKind.doctor),
            // FM2: Behaviour owns separation; Health the vaccine record.
            PpLink('My child cries every time I leave',
                surfaceId: 'pp_page/parenting_behaviour/separation'),
            PpLink('U-WIN: his vaccines, on the government record',
                surfaceId: 'pp_page/parenting_health/vax_uwin',
                blurb: 'The certificate a creche asks for, downloaded.'),
          ],
        ),
      ],
    ),
  ],
);
