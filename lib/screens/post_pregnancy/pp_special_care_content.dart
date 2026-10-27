// =============================================================================
//  Special care — babies born early, twins, and children who need more
// -----------------------------------------------------------------------------
//  Built 2026-10-02 from the parenting gap analysis. The pieces it found were
//  the NICU, twins (feeding, pumping, potty), sensory differences, ADHD and
//  a parent's fight for early intervention. Two areas are added for the
//  Indian family those pieces leave out: where to get help here (RBSK, DEIC,
//  the disability certificate and UDID card, school rights), and looking
//  after yourself as the parent who carries most of it.
//
//  ⚠️ NEVER A DIAGNOSIS. Every page here describes and routes. "Does my
//  toddler have ADHD?" is answered with what doctors look at and who can
//  assess, never with a checklist she scores at home.
//
//  ⚠️ THE TONE IS THE WHOLE JOB. A parent opening this door may be frightened,
//  grieving or exhausted. Every page starts by saying she is not alone and
//  that help works.
//
//  Door 12 (2026-10-26, `docs/pp-door-plans/12-special-care.md`): five areas,
//  15 pages. New: "Not talking yet", the therapies and their cost, hearing
//  checks, and a diagnosis from birth; Help in India as steps. Speech by age
//  is Development's, the ear pages are Health's, the at-home speech page is
//  Early learning's: linked, never written twice here.
//
//  ⚠️ NO PAGE NAMES A CURE. The one place the word appears is the warning
//  about centres that promise one (`test/pp_special_care_door_test.dart`).
// =============================================================================

import '../../data/mind_mood_data.dart' show kCrisisHelplineName, kCrisisHelplineNumber;
import '../brackets/hub/hub_intent_art.dart';
import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

final PpSection kPpSpecialCareSection = PpSection(
  id: 'parenting_special_care', // MUST match the hub's bracketId.
  title: 'Special care',
  subtitle: 'Born early, twins, and children who need a little more',
  autoScope: true,
  intro: 'Some children arrive early, some arrive in pairs, and some need '
      'extra help along the way. If that\'s your family, you are far from '
      'alone. Here is what to expect, where to find help in India, and how '
      'to look after yourself too.',
  bandSet: kPpChildBands,
  areas: [
    // =========================================================================
    //  1. BORN EARLY AND THE NICU
    // =========================================================================
    PpArea(
      id: 'born_early',
      mark: IntentMark.cuppedHands,
      title: 'Born early, and the NICU',
      blurb: 'What happens in the NICU, and bringing your baby home.',
      hue: 344,
      pages: [
        PpPage(
          id: 'sc_nicu',
          title: 'If your baby goes to the NICU',
          subtitle: 'What happens there, and how you can be part of it',
          bands: ['infant'], // SC1: a baby's page
          format: 'ARTICLE',
          blocks: [
            PpIntro('Seeing your baby in an incubator, with wires and tubes, '
                'is not what anyone pictures. It\'s frightening. It also '
                'means your baby is in the best place for what\'s needed right '
                'now, and most babies who spend time in the NICU go home healthy.'),
            // SC6: a real NICU nurse and parent. Taps "still being made" (S8a).
            PpVideoSlot(
              title: 'Kangaroo care in the NICU',
              subtitle: 'Holding your baby skin to skin, with the wires',
              slotId: 'special_care/kangaroo_care',
            ),
            PpArticle(heading: 'Why babies go to the NICU', [
              'The neonatal intensive care unit looks after babies born '
                  'early and babies who are small. It also cares for babies '
                  'who need help with breathing, jaundice, low sugar, '
                  'infection or a difficult birth. Some stay a day or two for '
                  'observation; others stay for weeks.',
            ]),
            PpCards(heading: 'What you might see', [
              PpCard('The incubator',
                  'A warm, clear box that keeps your baby\'s temperature steady.'),
              PpCard('The monitors',
                  'They track breathing, heart rate and oxygen. Alarms go '
                      'off often, and most are not emergencies.'),
              PpCard('A feeding tube',
                  'A thin tube through the nose or mouth, until sucking and '
                      'swallowing are strong enough.'),
              PpCard('Phototherapy lights',
                  'Blue lights that treat jaundice.'),
            ]),
            PpSteps(heading: 'How you can be part of the care', [
              PpStep('Express your milk',
                  'Start within the first hours if you can. Your milk is '
                      'medicine for a small baby. Ask the nurses for help.'),
              PpStep('Kangaroo care',
                  'Holding your baby skin to skin on your chest steadies '
                      'breathing and temperature, and helps growth. Fathers '
                      'can do it too.'),
              PpStep('Ask questions every day',
                  'Write them down. "What are we working on this week?" is a '
                      'good one.'),
              PpStep('Learn the daily care before discharge',
                  'Feeding, bathing, and what to watch for at home.'),
            ]),
            PpCallout('It\'s normal to feel numb, guilty, angry or afraid. '
                'If those feelings don\'t ease once your baby is home, talk '
                'to your doctor. Parents of NICU babies are more likely to '
                'have anxiety and low mood, and help works.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('Many government hospitals have Special Newborn Care '
                'Units (SNCUs) with free care. If cost is a worry, ask the '
                'hospital about government schemes before you assume you '
                'can\'t afford it.'),
            // SC5: feeding is Feeding's, coming home is First 40's.
            PpLink('Pumping when your baby can\'t feed yet',
                surfaceId: 'pp_page/parenting_feeding/bf_exclusive_pumping'),
            PpLink('Donor milk and milk banks',
                surfaceId: 'pp_page/parenting_feeding/bf_special_situations'),
            PpLink('Bringing home a small or early baby',
                surfaceId: 'pp_page/parenting_first_40/f40_small_or_early'),
          ],
        ),
        PpPage(
          id: 'sc_preemie_home',
          title: 'Bringing a premature baby home',
          subtitle: 'Feeds, warmth, infections and corrected age',
          bands: ['infant', 'toddler_1'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Going home is a big step, and leaving the monitors '
                'behind can feel scary. The NICU team only sends a baby home '
                'when ready. These are the things that matter most in the '
                'first months.'),
            PpSteps([
              PpStep('Keep your baby warm',
                  'Small babies lose heat fast. A cap, socks, and kangaroo '
                      'care at home all help.'),
              PpStep('Feed often',
                  'Usually every two to three hours, waking your baby if the '
                      'doctor advises.'),
              PpStep('Protect against infection',
                  'Hand washing, few visitors for the first weeks, and no one '
                      'unwell nearby.'),
              PpStep('Keep every follow-up visit',
                  'Including eye checks (ROP screening), hearing tests and '
                      'growth checks. These catch problems early.'),
              PpStep('Use the corrected age',
                  'For milestones, count from the due date, not the birth '
                      'date, until about two years.'),
            ]),
            PpCallout('Go to a doctor straight away for trouble breathing, '
                'pauses in breathing, turning blue, feeling cold or a fever. '
                'Go too if your baby won\'t feed, or is unusually floppy or '
                'sleepy.',
                kind: PpCalloutKind.doctor),
            PpLink('Milestones for babies born early',
                surfaceId: 'pp_page/parenting_development/dev_born_early'),
            // SC5: First 40's page links here; this is the way back.
            PpLink('Temperature, feeding and kangaroo care at home',
                surfaceId: 'pp_page/parenting_first_40/f40_small_or_early'),
            PpLink('Pumping when your baby can\'t feed yet',
                surfaceId: 'pp_page/parenting_feeding/bf_exclusive_pumping'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  2. TWINS
    // =========================================================================
    PpArea(
      id: 'twins',
      mark: IntentMark.feedMark,
      title: 'Twins',
      blurb: 'Feeding two, pumping, sleep and potty.',
      hue: 206,
      pages: [
        PpPage(
          id: 'sc_twins_breastfeeding',
          title: 'Breastfeeding twins',
          subtitle: 'Yes, you can make enough milk for two',
          bands: ['infant', 'toddler_1'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Your body makes milk by supply and demand, so most '
                'mothers can make enough for two. It takes practice, help '
                'and plenty of food and water. Many mothers of twins '
                'breastfeed for months, fully or partly.'),
            PpSteps(heading: 'Getting started', [
              PpStep('Start early, and often',
                  'Eight to twelve feeds a day for each baby in the first '
                      'weeks. If they\'re in the NICU, pump instead.'),
              PpStep('Feed one at a time first',
                  'Until each latches well. Then try both together.'),
              PpStep('Try the double rugby hold',
                  'A baby under each arm, on a firm twin pillow or pillows. '
                      'Feeding together saves hours each day.'),
              PpStep('Keep an easy log',
                  'Who fed when, and from which side. Swap sides each feed.'),
            ]),
            PpCards(heading: 'Keeping your supply up', [
              PpCard('Eat and drink well',
                  'Feeding twins uses a lot of energy. Eat regular meals and '
                      'snacks, and keep water close.'),
              PpCard('Watch the nappies, not the clock',
                  'Six or more wet nappies each, and steady weight gain, mean '
                      'they\'re getting enough.'),
              PpCard('Topping up is fine',
                  'If one twin needs extra, expressed milk or formula on the '
                      'doctor\'s advice is not a failure.'),
            ]),
            PpCallout('Ask for a lactation consultant early, in the hospital '
                'if possible. With twins, help in the first week makes the '
                'biggest difference.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'sc_twins_pumping',
          title: 'Pumping milk for twins',
          subtitle: 'How often, how long, and how much',
          bands: ['infant'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('If your twins are in the NICU, or you choose to pump, a '
                'steady routine builds a full supply. A double electric pump '
                'saves a great deal of time.'),
            PpSteps([
              PpStep('Start within six hours of birth if you can',
                  'Even a few drops of colostrum matter for small babies.'),
              PpStep('Pump eight to ten times in 24 hours',
                  'Including once at night, when milk-making hormones are '
                      'highest.'),
              PpStep('Pump for about 15 to 20 minutes',
                  'Both sides together, and a couple of minutes after the '
                      'milk stops.'),
              PpStep('Aim for a full supply by two weeks',
                  'Around 750 ml to 1 litre a day for two, though it varies.'),
              PpStep('Store milk safely',
                  'Label each container. Fresh milk is fine for about four '
                      'hours out on the counter. In the fridge, it keeps up to '
                      'four days.'),
            ]),
            PpWhenLine('Milk can be slow to come in after twins, especially '
                'after a caesarean or an early birth. Keep pumping. It often '
                'catches up over the first two weeks.'),
            // Door 12: every page routes to someone. REQUIRED_REVIEW
            // (paediatrician or IBCLC).
            PpCallout('A painful, red or hot patch on the breast, or a fever, '
                'needs a doctor the same day. If your supply is still low '
                'after two weeks, a lactation consultant can help.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'sc_twins_daily_life',
          title: 'Sleep, routines and potty training with twins',
          subtitle: 'One routine, two different children',
          format: 'CARDS',
          blocks: [
            PpIntro('Twins share a birthday, not a personality. A shared '
                'routine keeps you sane, and room for their differences '
                'keeps them happy.'),
            PpCards([
              PpCard('Sleep',
                  'Many families keep twins on the same feeding and sleep '
                      'times: when one wakes to feed, feed both. Twins sleep '
                      'in separate safe spaces, each on the back.'),
              PpCard('Accept every offer of help',
                  'Twins need two pairs of hands at bath and bedtime. Say '
                      'yes to family who offer.'),
              PpCard('Potty training',
                  'Twins may be ready months apart. Start each twin when '
                      'ready, not on the same day.'),
              PpCard('Two potties',
                  'Saves waiting, and lets one copy the other.'),
              PpCard('No comparing',
                  '"Your brother can do it" leaves one twin feeling less. '
                      'Praise each twin\'s own progress.'),
              PpCard('Time alone with each',
                  'A few minutes a day with each twin, one at a time.'),
            ]),
            // Door 12: every page routes to someone. REQUIRED_REVIEW
            // (paediatrician).
            PpCallout('Twins can be months apart in a skill and both be fine. '
                'If one seems far behind the other, ask your paediatrician '
                'at the next check.',
                kind: PpCalloutKind.doctor),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  3. CHILDREN WHO NEED MORE
    // =========================================================================
    PpArea(
      id: 'additional_needs',
      mark: IntentMark.compassMark,
      title: 'When your child needs a little more',
      blurb: 'Sensory differences, autism, attention, and taking more time.',
      hue: 268,
      pages: [
        // =====================================================================
        //  Door 12, SC2: "Not talking yet", first on Extra support from one.
        //  The by-age signs are Development's (linked, never repeated); the
        //  at-home speech page is Early learning's "Help him talk".
        //  REQUIRED_REVIEW (developmental paediatrician, speech therapist).
        // =====================================================================
        PpPage(
          id: 'sc_not_talking',
          title: 'Not talking yet: what to do next',
          subtitle: 'The hearing check, a speech assessment, and where to go',
          bands: ['toddler_1', 'toddler_2', 'preschool'],
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Children start talking at very different ages, and many '
                'late talkers catch up. But you never have to wait to ask. A '
                'check costs you nothing, and if your child needs help, '
                'starting early is what makes the biggest difference.'),
            PpSteps([
              PpStep('Check what\'s usual for your child\'s age',
                  'Development has talking month by month, and the signs '
                      'worth a check. Both are linked below.'),
              PpStep('Get hearing checked first',
                  'Many speech delays are a hearing problem, often from '
                      'repeated ear infections.'),
              PpStep('Ask your paediatrician: "Would a speech assessment help?"',
                  'You don\'t need to be sure.'),
              PpStep('Where to go',
                  'The DEIC (District Early Intervention Centre) at your '
                      'district hospital, free up to six years. Or a '
                      'government hospital\'s speech and hearing department, '
                      'or a private speech therapist registered with the RCI.'),
              PpStep('While you wait, at home',
                  'Talk about what your child is looking at. Add one word to '
                      'theirs. Wait five seconds for an answer. Read together. '
                      'Keep the TV off in the background.'),
            ]),
            PpLink('What talking looks like, month by month',
                surfaceId: 'pp_page/parenting_development/dev_speech_by_age'),
            PpLink('When talking is worth checking',
                surfaceId: 'pp_page/parenting_development/dev_speech_flags'),
            PpLink('Hearing checks', surfaceId: 'pp_page/parenting_special_care/sc_hearing'),
            PpLink('Help him talk',
                surfaceId: 'pp_page/parenting_early_learning/skills_language',
                blurb: 'Five minutes a day at home, while you wait.'),
            PpCallout('See your paediatrician soon if your child loses words '
                'they had, doesn\'t respond to sounds or their name, or has '
                'no words at all by 16 to 18 months.',
                kind: PpCalloutKind.doctor),
            PpConsult(
              title: 'Talk to a speech therapist',
              whoFor: 'If you want a check, or ideas for home, before a long wait.',
              surfaceId: 'pp_experts/Speech therapist',
            ),
            PpIndiaNote('"Boys talk late" and "the child is just lazy to talk" '
                'are said with love. Your instinct still counts, and a check '
                'settles it.'),
          ],
        ),
        // SC2: the therapies, what they cost, and how to find a good one.
        // Costs in rupees only (the user, 2026-10-26). REQUIRED_REVIEW
        // (developmental paediatrician, speech therapist; costs dated 2026).
        PpPage(
          id: 'sc_therapies',
          title: 'Speech therapy and the other therapies, explained',
          subtitle: 'What each one does, what it costs, and how to find a good one',
          bands: ['toddler_1', 'toddler_2', 'preschool'],
          format: 'CARDS',
          blocks: [
            PpIntro('"Your child needs therapy" can sound frightening. In '
                'practice it usually means playing with a trained person who '
                'shows you what to do at home.'),
            // SC6: a real speech therapist and a real child. Taps "still
            // being made" (S8a).
            PpVideoSlot(
              title: 'What a speech therapy session looks like',
              subtitle: 'Toys, pictures and songs, with a parent in the room',
              slotId: 'special_care/speech_session',
            ),
            PpCards(heading: 'The therapies', [
              PpCard('Speech therapy',
                  'Helps with understanding, talking and sounds, and '
                      'sometimes eating and swallowing. A session is usually '
                      'play: toys, pictures, songs, with you in the room.'),
              PpCard('Occupational therapy (OT)',
                  'Helps with everyday skills like holding a spoon, dressing '
                      'and handwriting, and with sensory struggles: clothes, '
                      'noise, textures.'),
              PpCard('Physiotherapy',
                  'Helps with sitting, walking, balance and strength.'),
              PpCard('A special educator',
                  'Helps with learning at the child\'s own pace, and with '
                      'getting ready for school.'),
            ]),
            PpWhenLine('Usually one to three sessions a week, 30 to 45 minutes '
                'each. The practice at home between sessions matters more '
                'than the session itself.'),
            PpCards(heading: 'What it costs in India', [
              PpCard('Free',
                  'At a DEIC under RBSK, and at many government hospitals and '
                      'medical colleges.'),
              PpCard('Private, per session',
                  'About ₹500 to ₹1,500 in most cities, and more in metros. '
                      'Ranges checked in 2026; they vary by city.'),
              PpCard('Ask about a home programme',
                  'A centre that teaches you a home programme means fewer '
                      'paid sessions.'),
            ]),
            PpSteps(heading: 'How to find a good one', [
              PpStep('Registered with the RCI',
                  'The Rehabilitation Council of India. Ask for the '
                      'registration number, and check it on the RCI site.'),
              PpStep('Works with you in the room',
                  'And teaches you what to do.'),
              PpStep('Sets goals you can see',
                  'And reviews them every few months.'),
              PpStep('Be careful of any centre that promises a "cure"',
                  'Or that wants a long package paid upfront.'),
            ]),
            PpCallout('Your paediatrician or a developmental paediatrician can '
                'tell you which therapy your child needs, and how often. '
                'Start with them.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        // SC2: hearing. The newborn test and the signs by age are Health's
        // (`ears_hearing`), ear infections too (`ill_ear`); this page says
        // where to get tested and links them. REQUIRED_REVIEW (paediatrician,
        // audiologist).
        PpPage(
          id: 'sc_hearing',
          title: 'Hearing checks',
          subtitle: 'Where to get tested, at any age',
          format: 'CARDS',
          blocks: [
            PpIntro('Children learn to talk by hearing, so a hearing check is '
                'often the first step when talking is slow. It is quick and '
                'painless, and no child is too young to be tested.'),
            PpCards(heading: 'Where to get tested', [
              PpCard('An ENT doctor or an audiologist',
                  'At a government hospital, where it is often free, or at a '
                      'private clinic. Your paediatrician can refer you.'),
              PpCard('The DEIC',
                  'The District Early Intervention Centre checks hearing as '
                      'part of a free assessment, up to six years.'),
              PpCard('Tests that need no answers',
                  'Babies and toddlers have hearing tests that work while '
                      'they sleep or play. Your child doesn\'t need to say '
                      'anything.'),
            ]),
            PpLink('The newborn test, and the signs by age',
                surfaceId: 'pp_page/parenting_health/ears_hearing'),
            PpLink('Ear infections, and fluid that dulls hearing',
                surfaceId: 'pp_page/parenting_health/ill_ear'),
            PpCallout('See a doctor if your child doesn\'t react to loud '
                'sounds, has ear discharge or pain, or you or anyone in the '
                'family feels your child isn\'t hearing well.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        // Moved here from Development when this door was built (P1 from the
        // gap analysis); the page id is unchanged.
        PpPage(
          id: 'dev_autism_signs',
          title: 'Early signs of autism, and what to do if you wonder',
          subtitle: 'Noticing early opens doors to help',
          bands: ['toddler_1', 'toddler_2', 'preschool'],
          format: 'ARTICLE',
          blocks: [
            PpIntro('Many parents wonder about autism, often after something '
                'a relative or a video says. Wondering doesn\'t mean anything '
                'is wrong. And if your child is autistic, finding out early '
                'brings the right support at the age it helps most.'),
            PpCards(heading: 'Signs worth talking to a doctor about', [
              PpCard('Not turning when called by name',
                  'Most of the time, by about 12 months, even when hearing '
                      'is fine.'),
              PpCard('Little pointing or showing',
                  'Not pointing to share something interesting by about 14 to '
                      '16 months.'),
              PpCard('Few shared smiles and looks',
                  'Rarely looking at your face to share a moment.'),
              PpCard('No pretend play by about 18 months',
                  'Like feeding a doll or talking on a toy phone.'),
              PpCard('Repeated movements or routines',
                  'Hand flapping, spinning, lining things up, and great '
                      'distress at small changes.'),
              PpCard('Strong reactions to sounds, textures or lights',
                  'Or seeming not to notice pain at all.'),
              PpCard('Words that come and go',
                  'Losing words that were there, or repeating phrases without '
                      'using them to talk to you.'),
            ]),
            PpArticle([
              'One or two of these on their own is common in children who are '
                  'not autistic. Doctors look at the whole picture, over '
                  'time. Only a trained professional can say whether a child '
                  'is autistic, using a proper assessment. That is usually a '
                  'developmental paediatrician or a child psychologist.',
              'Ask your paediatrician about a developmental screen at 18 and '
                  '24 months, or sooner if you\'re worried. It takes a few '
                  'minutes and is a normal part of good care.',
            ]),
            PpCallout('If you\'re worried, talk to your paediatrician now '
                'rather than waiting to see. Early therapy for communication '
                'and play makes a real difference. Early help works best, and '
                'it does no harm if all turns out well.',
                kind: PpCalloutKind.doctor),
            PpIndiaNote('"Boys talk late" and "it will pass" are well meant, '
                'but your instinct as a parent counts too.'),
            // SC5: Behaviour's two pages link here (BH6); this is the way back.
            PpLink('Head-banging and rocking',
                surfaceId: 'pp_page/parenting_behaviour/beh_head_banging'),
            PpLink('Eating mud, chalk or paper',
                surfaceId: 'pp_page/parenting_behaviour/beh_eating_nonfood'),
            PpLink('Not talking yet: what to do next', surfaceId: 'pp_page/parenting_special_care/sc_not_talking'),
          ],
        ),
        PpPage(
          id: 'sc_sensory',
          title: 'When clothes, noise or mess feel like too much',
          subtitle: 'Sensory differences, and how to help',
          bands: ['toddler_1', 'toddler_2', 'preschool'], // SC1
          format: 'ARTICLE',
          blocks: [
            PpIntro('Some children are bothered far more than others by tags '
                'in clothes, loud noises, messy hands or certain food '
                'textures. Others seek out more: spinning, crashing, '
                'chewing. Every child has preferences. When they get in the '
                'way of daily life, a little help goes a long way.'),
            PpCards(heading: 'What it can look like', [
              PpCard('Clothes',
                  'Meltdowns over socks, tags or certain fabrics.'),
              PpCard('Noise',
                  'Covering ears at the mixer, crackers or a pressure cooker '
                      'whistle.'),
              PpCard('Food',
                  'Gagging at lumpy or mixed textures well past toddlerhood.'),
              PpCard('Seeking',
                  'Always crashing, jumping or chewing on things.'),
              PpCard('Haircuts, nail cutting and baths',
                  'Distress far beyond ordinary fussing.'),
            ]),
            PpSteps(heading: 'What helps at home', [
              PpStep('Give a warning before loud or busy moments'),
              PpStep('Offer a choice of soft, tagless clothes'),
              PpStep('Offer new textures slowly, without pressure'),
              PpStep('Give a quiet corner to calm down in'),
            ]),
            PpCallout('If sensory struggles get in the way of eating enough, '
                'sleeping, playing with others or going out, ask your '
                'paediatrician about an occupational therapist. Sensory '
                'differences are also common in autism and ADHD, so a full '
                'look is worth it.',
                kind: PpCalloutKind.doctor),
          ],
        ),
        PpPage(
          id: 'sc_attention',
          title: 'Never sits still: is it ADHD?',
          subtitle: 'What is usual at this age, and who can tell',
          bands: ['toddler_2', 'preschool'],
          format: 'ARTICLE',
          blocks: [
            PpIntro('Toddlers and young children are meant to be busy, '
                'impulsive and easily distracted. That\'s how they learn. A '
                'two-year-old who can\'t sit through a meal is usual. So how '
                'do you know when it\'s more?'),
            PpArticle([
              'ADHD is rarely diagnosed before about four to six years, '
                  'because high energy and short attention are normal before '
                  'then. Doctors look for attention or activity far beyond '
                  'what is usual at that age. It shows up at home and at '
                  'school and lasts at least six months. It also gets in the '
                  'way of learning, friendships or safety.',
              'Poor sleep, hearing problems, stress at home and too much '
                  'screen time can all look like attention problems, so a '
                  'good assessment checks these too.',
            ]),
            PpSteps(heading: 'What helps every busy child', [
              PpStep('Plenty of active play outdoors, every day'),
              PpStep('Regular sleep and meal times'),
              PpStep('Short, clear instructions, one at a time'),
              PpStep('Less screen time, especially before bed'),
            ]),
            PpCallout('If a teacher raises concerns, or acting without '
                'thinking often leads into danger, talk to your paediatrician. '
                'A developmental paediatrician or child psychologist can '
                'assess properly.',
                kind: PpCalloutKind.doctor),
            // SC4: the specialist the callout names.
            PpConsult(
              title: 'Talk to a child psychologist',
              whoFor: 'If a teacher has raised it, or busy has started to feel unsafe.',
              surfaceId: 'pp_experts/Child psychologist',
            ),
          ],
        ),
        PpPage(
          id: 'sc_late_bloomer',
          title: 'When your child needs more time: acting early',
          subtitle: 'Waiting and watching isn\'t always the kind choice',
          bands: ['toddler_1', 'toddler_2', 'preschool'], // SC1
          format: 'ARTICLE',
          blocks: [
            PpIntro('Many parents hear "it will come in time". Often it does. '
                'But when talking, moving or playing is slow to come, help '
                'early is never wasted. A young brain changes fastest before '
                'five, which is when therapy works best.'),
            PpArticle([
              'A parent is often the first to notice. You don\'t need to be '
                  'sure, and you don\'t need a name for it, to ask for a '
                  'check. If the assessment finds nothing, you have peace of '
                  'mind. If it finds something, you have a head start.',
            ]),
            PpSteps(heading: 'The steps', [
              PpStep('Write down what you notice',
                  'What your child does and doesn\'t do yet, with examples and videos.'),
              PpStep('Talk to your paediatrician',
                  'Ask directly: "Would an assessment help?"'),
              PpStep('See the right specialist',
                  'A developmental paediatrician, speech therapist, '
                      'occupational therapist or child psychologist.'),
              PpStep('Start therapy, and do it at home too',
                  'The hours with you between sessions matter most.'),
            ]),
            // SC2 (content §6). REQUIRED_REVIEW (developmental paediatrician).
            PpSteps(heading: 'Questions to ask at the assessment', [
              PpStep('What did you see today, and what does it mean for my child?'),
              PpStep('What should we do at home this week?'),
              PpStep('Which therapy, how often, and for how long before we review?'),
              PpStep('Is it free anywhere near us?'),
              PpStep('What signs should make us come back sooner?'),
            ]),
            PpCallout('Losing words or skills that were there before is always '
                'worth a doctor visit soon, at any age.',
                kind: PpCalloutKind.doctor),
            PpLink('Where to get help in India',
                surfaceId: 'pp_page/parenting_special_care/sc_help_india'),
            PpLink('The therapies, and what they cost', surfaceId: 'pp_page/parenting_special_care/sc_therapies'),
          ],
        ),
        // SC2: a diagnosis from birth. Every age (the first weeks, and the
        // years after). REQUIRED_REVIEW (developmental paediatrician).
        PpPage(
          id: 'sc_from_birth',
          title: 'If your child has a diagnosis from birth',
          subtitle: 'Down syndrome, cerebral palsy, a heart condition: the first steps',
          format: 'STEPS',
          blocks: [
            PpIntro('Hearing that your baby has Down syndrome, cerebral palsy, '
                'a heart condition or another diagnosis can turn the first '
                'weeks upside down. You don\'t have to understand everything '
                'at once. This is your baby first.'),
            PpSteps([
              PpStep('Ask for the plan, in writing',
                  'Who follows your baby (paediatrician, cardiologist, '
                      'neurologist), which tests are next, and when the next '
                      'visit is.'),
              PpStep('Feeding help, early',
                  'Some babies tire easily or find sucking hard. Ask for a '
                      'lactation consultant or a feeding specialist while '
                      'you are still in hospital.'),
              PpStep('Early intervention',
                  'Register at the DEIC, free, from birth. Therapy started in '
                      'the first months makes the biggest difference.'),
              PpStep('Find other parents',
                  'Ask your hospital or the DEIC for a parent group. They '
                      'know the local doctors, therapists and schools.'),
              PpStep('The papers, when you\'re ready',
                  'The disability certificate and UDID card open benefits.'),
              PpStep('Look after yourself too',
                  'The page on caring for yourself is linked below.'),
            ]),
            PpLink('Getting help with feeding',
                surfaceId: 'pp_page/parenting_feeding/bf_lactation_help'),
            PpLink('Free help, certificates and school rights',
                surfaceId: 'pp_page/parenting_special_care/sc_help_india'),
            PpLink('Caring for a child who needs more, and for yourself',
                surfaceId: 'pp_page/parenting_special_care/sc_parent_wellbeing'),
            PpConsult(
              title: 'Talk to a developmental paediatrician',
              whoFor: 'For a plan across the doctors, and when to start therapy.',
              surfaceId: 'pp_experts/Development expert',
            ),
            PpIndiaNote('Relatives may ask "whose side is it from", or suggest '
                'remedies. Nothing you or your family did caused this.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  4. HELP IN INDIA
    // =========================================================================
    PpArea(
      id: 'help_india',
      mark: IntentMark.checkMark,
      title: 'Where to get help in India',
      blurb: 'Free assessment centres, certificates and school rights.',
      hue: 160,
      pages: [
        PpPage(
          id: 'sc_help_india',
          title: 'Free help, certificates and school rights',
          subtitle: 'RBSK, DEIC, the UDID card and RTE',
          // SC3: steps, not names; the old cards stay below them.
          // format: 'CARDS', // kept for revert
          format: 'STEPS',
          blocks: [
            PpIntro('Getting support for a child who needs more can feel '
                'like a maze. India has real, free help, and knowing the '
                'names makes it much easier to ask for.'),
            // SC3. REQUIRED_REVIEW: every scheme, step, document and the tax
            // section, checked against current government notices before
            // release (DEPwD and the UDID portal, the National Trust,
            // the Income Tax Act, MoHFW's RBSK guidelines, the RCI).
            PpSteps(heading: 'Step by step', [
              PpStep('Start at the DEIC',
                  'Free screening, assessment and therapy up to six years, '
                      'under RBSK, at your district hospital. You don\'t need '
                      'a diagnosis to ask.'),
              PpStep('The disability certificate and UDID card',
                  'Apply online at the UDID portal (swavlambancard.gov.in). '
                      'Go for the medical board assessment at the district '
                      'hospital on the date you are given. The card comes by '
                      'post. Carry the birth certificate, Aadhaar (your '
                      'child\'s or yours), photos, address proof and every '
                      'medical report.'),
              PpStep('Niramaya health insurance',
                  'From the National Trust: low-cost cover for children with '
                      'autism, cerebral palsy, intellectual disability or '
                      'multiple disabilities. Apply through a registered '
                      'organisation.'),
              PpStep('Tax',
                  'Under Section 80DD, a parent who cares for a dependant '
                      'with a disability can claim a fixed deduction, with a '
                      'certificate. Ask your tax adviser.'),
              PpStep('Pensions and scholarships',
                  'Many states pay a monthly disability pension and offer '
                      'school scholarships. Ask at the district social welfare '
                      'office. Amounts vary by state.'),
              PpStep('School',
                  'The RPwD Act 2016 and RTE give your child the right to a '
                      'regular school, with support. An IEP (Individual '
                      'Education Plan) sets your child\'s own goals. A shadow '
                      'teacher sits with your child in class. Boards like CBSE '
                      'allow exemptions and extra time later.'),
              PpStep('Check every professional',
                  'Therapists and special educators should be registered with '
                      'the RCI (Rehabilitation Council of India).'),
            ]),
            PpLink('Nursery admission, step by step',
                surfaceId: 'pp_page/parenting_early_learning/school_admission'),
            PpLink('Not sure yet? Acting early, step by step',
                surfaceId: 'pp_page/parenting_special_care/sc_late_bloomer'),
            PpCards(heading: 'The names, in short', [
              PpCard('RBSK and DEIC',
                  'Under the Rashtriya Bal Swasthya Karyakram, District Early '
                      'Intervention Centres screen and support children up to '
                      'six years, free, including therapy. Ask at your '
                      'district hospital.'),
              PpCard('The disability certificate and UDID card',
                  'If a doctor confirms a disability, a certificate and the '
                      'Unique Disability ID card open access to benefits and '
                      'concessions. Apply online at the UDID portal.'),
              PpCard('Your rights by law',
                  'The Rights of Persons with Disabilities Act, 2016 '
                      'protects your child from discrimination, including in '
                      'school admission.'),
              PpCard('School',
                  'Under the Right to Education Act, children with '
                      'disabilities have the right to study in a regular '
                      'school, with support. Schools can\'t refuse admission '
                      'on that basis.'),
              PpCard('Parent groups',
                  'Other parents are the best guides to local therapists and '
                      'schools. Ask your therapist or hospital for a group.'),
            ]),
            // REQUIRED_REVIEW: scheme names and coverage, as of 2026-10.
            PpWhenLine.doctor('Ask at the first sign of a concern. You don\'t need a '
                'diagnosis to get an assessment at a DEIC.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  5. LOOKING AFTER YOURSELF
    // =========================================================================
    PpArea(
      id: 'caring_for_you',
      mark: IntentMark.moodArc,
      title: 'Looking after yourself too',
      blurb: 'When you\'re the one carrying most of it.',
      hue: 28,
      pages: [
        PpPage(
          id: 'sc_parent_wellbeing',
          title: 'Caring for a child who needs more, and for yourself',
          subtitle: 'You matter in this too',
          format: 'ARTICLE',
          blocks: [
            PpIntro('When a child needs more care, appointments, therapies '
                'and worry can fill every hour. Many parents, most often '
                'mothers, put themselves last for years. Looking after '
                'yourself isn\'t selfish. It\'s what lets you keep going.'),
            PpSteps([
              PpStep('Share the load',
                  'Teach your partner and family the therapies and routines, '
                      'so it isn\'t all on you.'),
              PpStep('Find your people',
                  'Parents of children with similar needs understand in a '
                      'way others can\'t.'),
              PpStep('Take one small thing for yourself each day',
                  'A walk, a cup of tea in quiet, a call with a friend.'),
              PpStep('Let go of the guilt',
                  'Nothing you did or didn\'t do in pregnancy caused this.'),
            ]),
            // Door 12: the helpline was typed inside the doctor box. It is its
            // own card now, from the one constant (BH4 rule c). Kept for revert:
            // PpCallout('If you feel hopeless, can\'t sleep or eat, or feel you '
            //     'can\'t cope, talk to your doctor or call Tele-MANAS on '
            //     '14416, free and any time.',
            //     kind: PpCalloutKind.doctor),
            PpCallout('If you feel hopeless, can\'t sleep or eat, or feel you '
                'can\'t cope, talk to your doctor.',
                kind: PpCalloutKind.doctor),
            // REQUIRED_REVIEW (Tele-MANAS, MoHFW; the number is
            // REQUIRED_TO_CONFIRM at the constant).
            PpCallout('Free, any hour: $kCrisisHelplineName, '
                '$kCrisisHelplineNumber. Trained counsellors, in your language.',
                title: 'If there is nobody to talk to'),
            // SC5: You, Maa owns the anger and the low mood.
            PpLink('The anger nobody warned me about',
                surfaceId: 'pp_page/parenting_maternal/mind_rage'),
            PpLink('I love my baby and I am not okay',
                surfaceId: 'pp_page/parenting_maternal/mind_love_but_not_okay'),
          ],
        ),
      ],
    ),
  ],
);
