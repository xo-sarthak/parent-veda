// =============================================================================
//  Papers and money — documents, schemes, insurance and saving, for India
// -----------------------------------------------------------------------------
//  Built 2026-10-02 from the parenting gap analysis. All seven competitor
//  pieces here were theAsianparent's Singapore money articles (Baby Bonus,
//  ang pow, children's bank accounts). The analysis's verdict was "write it
//  for India", and nothing in them transfers, so every page is ours: the
//  birth certificate, Baal Aadhaar, the passport, PMMVY and Sukanya
//  Samriddhi, adding him to health insurance, and saving for his future.
//
//  ⚠️ FIGURES CHANGE. Every amount, age limit and rule here is a fact that a
//  government can change. Each page says where to check, names no product or
//  provider, and is REQUIRED_REVIEW as of 2026-10. This is information, not
//  financial advice.
// =============================================================================

import '../brackets/hub/hub_intent_art.dart';
import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

final PpSection kPpPapersSection = PpSection(
  id: 'parenting_papers', // MUST match the hub's bracketId.
  title: 'Papers and money',
  subtitle: 'Documents, schemes, insurance and saving',
  autoScope: true,
  intro: 'Alongside the nappies come the forms. Here are the documents your '
      'child needs and when, the government schemes you may be entitled to, '
      'and plain, honest steps for insurance and saving. Rules change, so '
      'each page tells you where to check.',
  bandSet: kPpChildBands,
  areas: [
    // =========================================================================
    //  1. HIS DOCUMENTS
    // =========================================================================
    PpArea(
      id: 'documents',
      mark: IntentMark.checkMark,
      title: 'Your child\'s documents',
      blurb: 'Birth certificate, Aadhaar and passport, in order.',
      hue: 206,
      pages: [
        PpPage(
          id: 'pm_birth_certificate',
          title: 'The birth certificate: the first and most important',
          subtitle: 'Register within 21 days, free',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('The birth certificate is the document every other one is '
                'built on: Aadhaar, passport, school admission. Getting it '
                'early, and getting it right, saves a lot of trouble later.'),
            PpSteps([
              PpStep('The hospital usually registers the birth',
                  'Ask before discharge whether they have, and how you collect '
                      'the certificate.'),
              PpStep('For a birth at home, register it yourself',
                  'At your municipal office or gram panchayat, or online on '
                      'your state\'s portal or the national CRS portal.'),
              PpStep('Do it within 21 days',
                  'Registration is free within 21 days. Later registration is '
                      'still possible but needs more paperwork.'),
              PpStep('Add the name once you have chosen it',
                  'You can register without a name and add it later, '
                      'usually within a year without fuss.'),
              PpStep('Check every spelling',
                  'Your child\'s name, your names and the date. A mistake here '
                      'carries into every later document.'),
            ]),
            // REQUIRED_REVIEW: 21-day window and name-addition rules under
            // the Registration of Births and Deaths Act as amended in 2023.
            PpCallout('Keep several copies and a scan. Since 2023, the birth '
                'certificate is accepted as single proof of date of birth for '
                'school admission and many other services.'),
          ],
        ),
        PpPage(
          id: 'pm_aadhaar',
          title: 'Baal Aadhaar for your child',
          subtitle: 'The blue Aadhaar, and the updates at 5 and 15',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Children can have Aadhaar from birth. Under five, it\'s '
                'called Baal Aadhaar, printed in blue, and needs no '
                'fingerprints. Many schemes and schools ask for it.'),
            PpSteps([
              PpStep('Take the birth certificate and a parent\'s Aadhaar',
                  'To an Aadhaar enrolment centre. Some hospitals and post '
                      'offices enrol newborns.'),
              PpStep('A photo is taken, no fingerprints',
                  'Your child\'s Aadhaar is linked to a parent\'s.'),
              PpStep('Update the biometrics at five years',
                  'Fingerprints and iris are added then. It\'s free.'),
              PpStep('Update again at fifteen', 'Also free.'),
            ]),
            PpCallout('If the five-year update is missed, the Aadhaar can be '
                'suspended. Set a reminder for your child\'s fifth birthday.',
                kind: PpCalloutKind.safety),
          ],
        ),
        PpPage(
          id: 'pm_passport',
          title: 'A passport for your baby',
          subtitle: 'If you might travel abroad',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Even a newborn needs a separate passport to travel '
                'abroad. Once the birth certificate is ready, the process is '
                'straightforward.'),
            PpSteps([
              PpStep('Apply online on the Passport Seva portal',
                  'Choose the minor\'s application.'),
              PpStep('Documents', 'The birth certificate, both parents\' '
                  'passports or address proof, and a signed consent form '
                  'from both parents.'),
              PpStep('Visit the Passport Seva Kendra together',
                  'Both parents usually need to come, with the baby.'),
              PpStep('Photos', 'Taken at the centre. No fingerprints for '
                  'young children.'),
            ]),
            PpWhenLine('A minor\'s passport is valid for five years, or until '
                'age 18 if that is sooner. Renew it with fresh photos.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  2. GOVERNMENT SCHEMES
    // =========================================================================
    PpArea(
      id: 'schemes',
      mark: IntentMark.lampMark,
      title: 'Government schemes you may get',
      blurb: 'Maternity benefit, anganwadi services, and savings for a girl.',
      hue: 42,
      pages: [
        PpPage(
          id: 'pm_schemes',
          title: 'Schemes for mothers and young children',
          subtitle: 'PMMVY, anganwadi services, free vaccines and more',
          format: 'CARDS',
          blocks: [
            PpIntro('Many families don\'t claim help they are entitled to, '
                'only because no one told them. These are the main central '
                'schemes. Your state may have its own as well, often more '
                'generous.'),
            // REQUIRED_REVIEW: PMMVY amounts and conditions (PMMVY 2.0),
            // as of 2026-10.
            PpCards([
              PpCard('Pradhan Mantri Matru Vandana Yojana (PMMVY)',
                  'Cash support of ₹5,000 for the first child, paid in '
                      'instalments after pregnancy registration and after the '
                      'birth is registered and vaccines begin. A second child '
                      'who is a girl may also qualify. Apply through your '
                      'anganwadi or ASHA worker, or the PMMVY portal.'),
              PpCard('Anganwadi services',
                  'Free take-home food for young children and breastfeeding '
                      'mothers, growth checks, and preschool from three. Find '
                      'your nearest anganwadi centre.'),
              PpCard('Free vaccines',
                  'Every vaccine on the national schedule is free at '
                      'government hospitals and health centres.'),
              PpCard('Free care for sick newborns',
                  'Government hospitals provide free treatment for sick '
                      'babies, including transport, under JSSK.'),
              PpCard('Sukanya Samriddhi Yojana',
                  'A government savings account for a girl, with a good '
                      'interest rate. See the saving page.'),
            ]),
            PpWhenLine('Ask your ASHA worker or the anganwadi first. They '
                'know the local schemes and can help with the forms.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  3. HEALTH INSURANCE
    // =========================================================================
    PpArea(
      id: 'insurance',
      mark: IntentMark.cuppedHands,
      title: 'Health insurance for your child',
      blurb: 'Adding your child to your policy, and what to check.',
      hue: 344,
      pages: [
        PpPage(
          id: 'pm_health_insurance',
          title: 'Adding your baby to health insurance',
          subtitle: 'From birth if you can, and what to check',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('A short hospital stay for a child can cost a great deal. '
                'Adding your baby to health insurance early is one of the '
                'most useful things you can do for your family\'s money.'),
            PpSteps([
              PpStep('Check your current policy now',
                  'Some family policies cover a newborn from birth, '
                      'especially if they include maternity cover. Others '
                      'start cover only from 90 days, or only once added.'),
              PpStep('Tell your insurer or HR within the time limit',
                  'Often within 30 to 90 days of birth. Miss it and you may '
                      'have to wait for renewal.'),
              PpStep('If your work policy covers children, add your baby there',
                  'And consider your own family floater policy too, because '
                      'work cover ends when you change jobs.'),
              PpStep('Check what is excluded',
                  'Birth conditions, vaccines and outpatient visits are '
                      'often not covered.'),
            ]),
            PpCards(heading: 'Also worth knowing', [
              PpCard('Ayushman Bharat (PM-JAY)',
                  'Eligible families get free hospital cover of up to ₹5 lakh '
                      'a year. Check eligibility at the PM-JAY portal or a '
                      'government hospital.'),
              PpCard('Term life insurance for parents',
                  'Many financial planners suggest parents of young children '
                      'have term life cover, so the child is protected if '
                      'something happens to a parent.'),
            ]),
            PpCallout('This is general information, not advice on any '
                'product. Read the policy wording, or ask an adviser you '
                'trust who is not paid by the insurer.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  4. SAVING FOR HIM
    // =========================================================================
    PpArea(
      id: 'saving',
      mark: IntentMark.improveMark,
      title: 'Saving for your child\'s future',
      blurb: 'Gift money, education costs, and easy accounts.',
      hue: 160,
      pages: [
        PpPage(
          id: 'pm_saving',
          title: 'Saving for your child, step by step',
          subtitle: 'From gift-money envelopes to school and college',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Children receive a lot of money in their first years: '
                'gift money (shagun) at the naming ceremony, birthdays, Diwali. Putting '
                'it to work early, even small amounts, grows into something '
                'real by the time it\'s needed.'),
            PpArticle([
              'School and college costs in India rise faster than prices in '
                  'general, often by around ten percent a year. Saving from '
                  'the baby years gives the money the longest time to grow. '
                  'That matters far more than how much you start with.',
            ]),
            // REQUIRED_REVIEW: scheme rules (age limits, tenures) as of
            // 2026-10. Rates are not quoted because they change quarterly.
            PpCards(heading: 'Common choices', [
              PpCard('A minor\'s bank account',
                  'Most banks open one in the child\'s name, run by a parent. '
                      'An easy home for gift money.'),
              PpCard('Sukanya Samriddhi Yojana, for a girl',
                  'Can be opened for a daughter under ten, at a post office '
                      'or bank. Government-backed, with tax benefits, and '
                      'matures when your daughter is 21.'),
              PpCard('Public Provident Fund in your child\'s name',
                  'Long-term, government-backed, with tax benefits.'),
              PpCard('Mutual fund SIPs',
                  'For goals ten or more years away, a monthly SIP in a '
                      'diversified fund can grow more, with more ups and '
                      'downs.'),
            ]),
            PpCallout('Be careful of policies that mix insurance and saving '
                'for children. They often have high costs. Keep insurance '
                'and saving separate, and ask a fee-only adviser if unsure.'),
          ],
        ),
      ],
    ),

    // =========================================================================
    //  5. PLANNING AHEAD
    // =========================================================================
    PpArea(
      id: 'planning',
      mark: IntentMark.listMark,
      title: 'Planning ahead',
      blurb: 'Nominees, a will, and leave at work.',
      hue: 268,
      pages: [
        PpPage(
          id: 'pm_planning_ahead',
          title: 'Nominees, a will, and who would care for your child',
          subtitle: 'Ten minutes now that protects your child later',
          format: 'STEP-LIST',
          blocks: [
            PpIntro('Nobody likes to think about it. Still, a few small steps '
                'now mean your child is looked after if something happens '
                'to you.'),
            PpSteps([
              PpStep('Update your nominees',
                  'On your bank accounts, PF, insurance and investments.'),
              PpStep('Make a simple will',
                  'It can name a guardian for your child. A will doesn\'t '
                      'have to be registered to be valid, though registering '
                      'it helps.'),
              PpStep('Tell someone where things are',
                  'A list of accounts and policies, kept safely, that your '
                      'partner or a trusted person can find.'),
            ]),
            PpLink('Maternity leave, creche rights and going back to work',
                surfaceId: 'pp_section/parenting_maternal',
                blurb: 'In the You, the mother door.'),
          ],
        ),
      ],
    ),
  ],
);
