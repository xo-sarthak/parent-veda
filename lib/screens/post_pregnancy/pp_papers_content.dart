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
//
//  Door 14 (2026-10-26, `docs/pp-door-plans/14-papers.md`): every page opens
//  its body on "Checked October 2026" and where to confirm (PM7); every page
//  links the page that answers the next step (PM2); insurance answers the
//  door's top question, vaccines, OPD and therapy (PM3); the passport, the
//  corrections, a single parent's papers, PMMVY's instalments, a disability
//  card and tax fill the small gaps (PM4); the Baal Aadhaar page sets its own
//  reminder (PM5). Legal aid, leave and the scheme details another door owns
//  are linked, never written twice. `test/pp_papers_door_test.dart`.
//
//  ⚠️ NO `PpWhenLine` ON THESE PAGES. The reader draws a when-line under
//  "When to see a doctor", so the passport's validity and "ask your ASHA
//  worker" read as doctor lines. They are titled callouts now (door 14).
// =============================================================================

import '../brackets/hub/hub_intent_art.dart';
import 'pp_age_bands.dart';
import 'pp_content.dart';
import 'pp_section_screen.dart';

/// The quiet date line at the top of every page (PM7). Re-dated whenever a
/// page is re-checked.
const String kPpPapersChecked = 'Checked October 2026';

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
            PpCallout('Rules change, so confirm at your municipal office, or '
                'on the CRS portal.',
                title: kPpPapersChecked),
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
            // PM4. REQUIRED_REVIEW: corrections, the name after a year (up to
            // 15 years, with a late fee) and a registration after a year (a
            // magistrate's order), under the Registration of Births and
            // Deaths Act 1969 as amended in 2023, and the state rules.
            PpSteps(heading: 'If something is wrong, or the name comes late', [
              PpStep('A spelling or date mistake',
                  'Apply to the registrar who issued the certificate, with '
                      'proof: the hospital discharge papers, and an affidavit '
                      'if asked. Fix it before you apply for Aadhaar or a '
                      'passport.'),
              PpStep('Adding the name',
                  'Free within the first year. After that it is still '
                      'possible, with a small late fee, usually up to 15 '
                      'years.'),
              PpStep('A birth never registered',
                  'It can still be done at any age, with more paperwork. '
                      'After a year, it needs an order from the local '
                      'magistrate. Ask at your municipal office.'),
            ]),
            // PM4. Only the how: Family's `fam_on_your_own` says a single
            // parent may apply alone, and You, Maa's `people_separated`
            // holds maintenance, custody and free legal aid (linked below,
            // never written twice). REQUIRED_REVIEW: the registration rules
            // for a single mother, and the Passport Seva annexures (C, the
            // single parent's declaration; D, both parents').
            PpSteps(heading: 'If you\'re raising your child on your own', [
              PpStep('A single mother can register the birth alone',
                  'And get the certificate with only her name as the '
                      'parent. An affidavit may be asked for.'),
              PpStep('Aadhaar needs one parent',
                  'Your child\'s Aadhaar is linked to one parent\'s Aadhaar, '
                      'so yours is enough.'),
              PpStep('The passport needs one signature',
                  'Apply with Annexure C, the declaration for a single '
                      'parent, in place of Annexure D, which both parents '
                      'sign. The Passport Seva portal lists the forms and '
                      'which one fits your case.'),
            ]),
            // PM2: the next document, then school.
            PpLink('Baal Aadhaar for your child',
                surfaceId: 'pp_page/parenting_papers/pm_aadhaar',
                blurb: 'The next document, made from this one.'),
            PpLink('Nursery admission, step by step',
                surfaceId: 'pp_page/parenting_early_learning/school_admission',
                blurb: 'The papers a nursery asks for, in Early learning.'),
            PpLink('Parenting apart: separation, divorce and new families',
                surfaceId: 'pp_page/parenting_maternal/people_separated',
                blurb: 'Maintenance, custody and free legal aid, in You, Maa.'),
            PpLink('Doing it on your own',
                surfaceId: 'pp_page/parenting_family/fam_on_your_own',
                blurb: 'For a single mother or father, in Family.'),
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
            PpCallout('Rules change, so confirm on the UIDAI site, or at an '
                'Aadhaar centre.',
                title: kPpPapersChecked),
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
            // PM5: the callout no longer asks her to set a reminder herself;
            // the button under it does. Kept for revert:
            // PpCallout('If the five-year update is missed, the Aadhaar can be '
            //     'suspended. Set a reminder for your child\'s fifth birthday.',
            //     kind: PpCalloutKind.safety),
            // REQUIRED_REVIEW: the mandatory biometric update at 5 and 15,
            // free, and suspension if missed (UIDAI).
            PpCallout('If the five-year update is missed, the Aadhaar can be '
                'suspended. It\'s free.',
                kind: PpCalloutKind.safety),
            PpAadhaarReminder(),
            // PM2: the vault, where the blue card's photo is kept.
            PpLink('Document vault',
                surfaceId: 'pp_baby_documents',
                blurb: 'Keep a photo of the Baal Aadhaar and the birth '
                    'certificate, ready when someone asks.'),
          ],
        ),
        PpPage(
          id: 'pm_passport',
          title: 'A passport for your baby',
          subtitle: 'If you might travel abroad',
          format: 'STEP-LIST',
          blocks: [
            // PM3: answers "does a 3 month old need a passport" first. Kept
            // for revert:
            // PpIntro('Even a newborn needs a separate passport to travel '
            //     'abroad. Once the birth certificate is ready, the process is '
            //     'straightforward.'),
            PpIntro('Yes, even a newborn needs a passport of their own to '
                'travel abroad. There\'s no minimum age. You can apply as '
                'soon as the birth certificate is ready.'),
            PpCallout('Rules change, so confirm on the Passport Seva portal.',
                title: kPpPapersChecked),
            // REQUIRED_REVIEW (PM3): the Passport Seva rules for minors, the
            // photo for a child under four, the timing, Tatkal and the fees,
            // as of the release date.
            PpSteps([
              PpStep('Check the name first',
                  'It must match the birth certificate exactly. Fix the '
                      'certificate first if it is wrong.'),
              PpStep('Apply online on the Passport Seva portal',
                  'Choose the minor\'s application.'),
              PpStep('Documents', 'The birth certificate, both parents\' '
                  'passports or address proof, and a signed consent form '
                  'from both parents.'),
              PpStep('Visit the Passport Seva Kendra together',
                  'Both parents usually need to come, with the baby.'),
              // Kept for revert:
              // PpStep('Photos', 'Taken at the centre. No fingerprints for '
              //     'young children.'),
              PpStep('Photos', 'Taken at the centre. No fingerprints for '
                  'young children. For a child under four, bring a '
                  'passport-size photo on a white background as well, in '
                  'case the centre asks. Check the portal.'),
              PpStep('How long it takes',
                  'Usually a few weeks after the appointment. Tatkal is '
                      'faster, for a higher fee.'),
              PpStep('The fee',
                  'A minor\'s passport costs less than an adult\'s. The '
                      'portal shows the current fee.'),
            ]),
            PpCallout('There\'s a separate declaration form if you are a '
                'single parent, or one parent is abroad or not signing. See '
                '"If you\'re raising your child on your own" on the birth '
                'certificate page.',
                title: 'If one parent signs'),
            // Was a when-line, which the reader draws as "When to see a
            // doctor". Kept for revert:
            // PpWhenLine('A minor\'s passport is valid for five years, or until '
            //     'age 18 if that is sooner. Renew it with fresh photos.'),
            PpCallout('A minor\'s passport is valid for five years, or until '
                'age 18 if that is sooner. Renew it with fresh photos.',
                title: 'How long it lasts'),
            PpLink('The birth certificate: the first and most important',
                surfaceId: 'pp_page/parenting_papers/pm_birth_certificate',
                blurb: 'Corrections, and a single parent\'s forms.'),
            PpLink('Travelling with a baby or toddler',
                surfaceId: 'pp_page/parenting_safety/safety_travel',
                blurb: 'Flying with a baby, in Safety.'),
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
          // Door 14: a CARDS page opens as the story deck, and the deck
          // drops every link to another door (`ppCardsAsSlides` keeps only a
          // same-section page link), so the four PM2 links would never be
          // seen. The reader shows the same cards and the links. Kept for
          // revert:
          // format: 'CARDS',
          format: 'ARTICLE',
          blocks: [
            PpIntro('Many families don\'t claim help they are entitled to, '
                'only because no one told them. These are the main central '
                'schemes. Your state may have its own as well, often more '
                'generous.'),
            PpCallout('Rules change, so confirm with your anganwadi or ASHA '
                'worker.',
                title: kPpPapersChecked),
            // REQUIRED_REVIEW: PMMVY 2.0 amounts, instalments and conditions
            // (Mission Shakti), JSSK, RBSK, as of the release date. You, Maa's
            // `work_schemes` states the same PMMVY amounts: check both
            // together.
            PpCards([
              // PM4: made exact. Kept for revert:
              // PpCard('Pradhan Mantri Matru Vandana Yojana (PMMVY)',
              //     'Cash support of ₹5,000 for the first child, paid in '
              //         'instalments after pregnancy registration and after the '
              //         'birth is registered and vaccines begin. A second child '
              //         'who is a girl may also qualify. Apply through your '
              //         'anganwadi or ASHA worker, or the PMMVY portal.'),
              PpCard('Pradhan Mantri Matru Vandana Yojana (PMMVY)',
                  '₹5,000 for the first child, in two instalments: after the '
                      'pregnancy is registered, and after the birth is '
                      'registered and the first vaccines are given. ₹6,000 '
                      'for a second child who is a girl, in one instalment '
                      'after the birth. Apply through your anganwadi or ASHA '
                      'worker, or the PMMVY portal. Don\'t leave it: the '
                      'instalments wait on the registration and the first '
                      'vaccines.'),
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
              // PM4: one line here; Special care holds the steps.
              PpCard('If your child has a disability',
                  'Free early help at the DEIC up to six, the UDID card, '
                      'Niramaya health cover, and a tax deduction for the '
                      'parent. Special care takes you through each one.'),
            ]),
            // Was a when-line ("When to see a doctor" in the reader). Kept
            // for revert:
            // PpWhenLine('Ask your ASHA worker or the anganwadi first. They '
            //     'know the local schemes and can help with the forms.'),
            PpCallout('Ask your ASHA worker or the anganwadi first. They know '
                'the local schemes and can help with the forms.',
                title: 'Who to ask'),
            // PM2: each scheme to the page that takes it further.
            PpLink('What\'s due, and when',
                surfaceId: 'pp_page/parenting_health/vax_schedule',
                blurb: 'The vaccine schedule, in Health.'),
            PpLink('Nursery admission, step by step',
                surfaceId: 'pp_page/parenting_early_learning/school_admission',
                blurb: 'Anganwadi preschool and nursery admission, in Early '
                    'learning.'),
            PpLink('If your baby goes to the NICU',
                surfaceId: 'pp_page/parenting_special_care/sc_nicu',
                blurb: 'Free care for sick newborns, in Special care.'),
            PpLink('Free help, certificates and school rights',
                surfaceId: 'pp_page/parenting_special_care/sc_help_india',
                blurb: 'The DEIC, the UDID card, Niramaya and 80DD, step by '
                    'step.'),
            PpLink('Money the government gives mothers',
                surfaceId: 'pp_page/parenting_maternal/work_schemes',
                blurb: 'PMMVY with JSY and your state\'s own scheme, in You, '
                    'Maa.'),
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
            PpCallout('Rules change, so confirm in your policy wording, or '
                'with your insurer.',
                title: kPpPapersChecked),
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
            // PM3: the door's most-asked question ("is baby vaccination
            // covered by insurance"). REQUIRED_REVIEW: IRDAI rules and
            // typical policy terms on newborn, vaccination and OPD cover, and
            // Niramaya's therapy cover, as of the release date.
            PpCards(heading: 'Vaccines, doctor visits and therapy', [
              PpCard('Vaccines',
                  'Most health policies don\'t pay for vaccines, because '
                      'they\'re outpatient. Some family policies with '
                      'maternity cover pay for the baby\'s vaccines in the '
                      'first year, up to a limit: look for a "newborn" or '
                      '"vaccination" clause. Every vaccine on the national '
                      'schedule is free at government centres; the optional '
                      'ones, and doses at a private clinic, you pay for.'),
              PpCard('Doctor visits (OPD)',
                  'Usually not covered unless the policy has an OPD add-on. '
                      'A hospital stay of 24 hours or more is what most '
                      'policies pay for.'),
              PpCard('Therapy',
                  'Speech, occupational and physiotherapy sessions are '
                      'outpatient, so they\'re usually not covered. Ask '
                      'whether developmental delay or autism is excluded. '
                      'Niramaya covers therapy for some conditions.'),
              PpCard('Who to ask',
                  'If your policy comes through work, the company that '
                      'handles claims (the TPA, named on your health card) '
                      'can tell you exactly what\'s covered.'),
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
            // PM2.
            PpLink('What\'s due, and when',
                surfaceId: 'pp_page/parenting_health/vax_schedule',
                blurb: 'The vaccine schedule, in Health.'),
            PpLink('Speech therapy and the other therapies, explained',
                surfaceId: 'pp_page/parenting_special_care/sc_therapies',
                blurb: 'What each one does and what it costs, in Special '
                    'care.'),
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
            PpCallout('Rules change, so confirm with your bank or post office.',
                title: kPpPapersChecked),
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
            // PM4. REQUIRED_REVIEW: the Income Tax Act, Sections 80C and
            // 80D, and the new regime under Section 115BAC, as of the release
            // date. No limit is quoted: it changes with the budget.
            PpCards(heading: 'Tax, if you file under the old regime', [
              PpCard('Section 80C',
                  'Your child\'s school tuition fees, for up to two children, '
                      'and Sukanya Samriddhi and PPF deposits. These count '
                      'towards the yearly 80C limit.'),
              PpCard('Section 80D',
                  'The premium for health insurance that covers your '
                      'children.'),
              PpCard('Under the new tax regime',
                  'Most of these deductions don\'t apply. Ask whoever files '
                      'your return which regime suits you.'),
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
            PpCallout('Rules change, so confirm with a lawyer, or at the free '
                'legal aid office at your district court.',
                title: kPpPapersChecked),
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
            // PM2: the leave page itself, not the whole section (Papers has
            // no leave page; You, Maa owns the rules). Kept for revert:
            // PpLink('Maternity leave, creche rights and going back to work',
            //     surfaceId: 'pp_section/parenting_maternal',
            //     blurb: 'In the You, the mother door.'),
            PpLink('What your maternity leave entitles you to',
                surfaceId: 'pp_page/parenting_maternal/work_your_entitlement',
                blurb: 'Leave, creche rights and going back to work, in You, '
                    'Maa.'),
            PpLink('Doing it on your own',
                surfaceId: 'pp_page/parenting_family/fam_on_your_own',
                blurb: 'If you\'re parenting on your own, in Family.'),
          ],
        ),
      ],
    ),
  ],
);
