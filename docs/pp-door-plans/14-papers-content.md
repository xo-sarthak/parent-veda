# Door 14: Papers and money, the new copy (PM3, PM4, PM5, PM7)

Written 2026-10-25. This goes into `pp_papers_content.dart` at build. The house rules are the section's own:
- India first.
- No product or provider is named.
- Information, not financial or legal advice.
- Every page says where to check.
- English only. No emoji.
- Every legal, scheme, tax and money line is REQUIRED_REVIEW, checked against the current government page on the release date. Amounts are dated.

---

## 1. The date line (PM7), at the top of every page
> Checked October 2026. Rules change, so confirm at [the portal or office named on the page].

| Page | Where |
|---|---|
| `pm_birth_certificate` | your municipal office, or the CRS portal |
| `pm_aadhaar` | the UIDAI site, or an Aadhaar centre |
| `pm_passport` | the Passport Seva portal |
| `pm_schemes` | your anganwadi or ASHA worker |
| `pm_health_insurance` | your policy wording, or your insurer |
| `pm_saving` | your bank or post office |
| `pm_planning_ahead` | a lawyer, or the free legal aid office |

## 2. `pm_birth_certificate`, two new parts
REQUIRED_REVIEW (Registration of Births and Deaths Act 1969 as amended 2023, and the state rules).

**If something is wrong, or the name comes late**
- **A spelling or date mistake:** apply to the registrar who issued it, with proof (the hospital discharge papers, and an affidavit if asked). Fix it before you apply for Aadhaar or a passport.
- **Adding the name:** free within the first year. After that it's still possible, with a small late fee, usually up to 15 years.
- **A birth never registered:** it can still be done at any age, with more paperwork. After a year, it needs an order from the local magistrate. Ask at your municipal office.

**If you're raising him on your own**
- **A single mother** can register the birth and get the certificate in her name alone. An affidavit may be asked for.
- **Aadhaar** links to one parent's Aadhaar, so one parent is enough.
- **The passport:** one parent can apply, with a declaration form for a single parent instead of both signatures. The portal lists the form.
- **Maintenance and custody** are decided by a family court. Women and children get **free legal aid whatever their income**: call the legal aid helpline, **15100**, or visit the District Legal Services Authority at your district court.
- Link: Family's "Doing it on your own".

Link at the end: "Next: Baal Aadhaar" → `pm_aadhaar`. For school: "Papers for nursery admission" → Early learning's nursery admission page.

## 3. `pm_aadhaar`, the reminder (PM5)
The safety callout changes. The old text is commented out, "kept for revert".
> If the five-year update is missed, the Aadhaar can be suspended. It's free.
> **[ Remind me before he turns five ]**

- **After a tap:** "Reminder set for 12 May 2031. We'll remind you a month before his fifth birthday."
- **With no birth date saved:** a toast says "Add his birth date first, so the reminder lands on the right day", with a button to add it.
- **Over 5 already:** the button is replaced by "The five-year update is due now. It's free at any Aadhaar centre."

Below it, the tool card on the Documents rail:
> **Keep his papers**
> A safe place for the birth certificate, Aadhaar, passport and policy, with a photo or PDF of each.

## 4. `pm_passport`, additions (PM3)
REQUIRED_REVIEW (the Passport Seva rules, as of the release date).

**Intro, rewritten:** "Yes, even a newborn needs his own passport to travel abroad. There's no minimum age. You can apply as soon as the birth certificate is ready."

**New steps and cards:**
- **The name must match** the birth certificate exactly. Fix the certificate first if it's wrong.
- **Photos:** for very young children, bring a passport-size photo on a white background, in case the centre asks for one. Check the portal.
- **How long:** usually a few weeks after the appointment. Tatkal is faster, for a higher fee.
- **Fee:** a minor's passport costs less than an adult's.
- **A single parent,** or one parent abroad or not signing: there's a separate declaration form. See "If you're raising him on your own" on the birth certificate page.
- Link: "Flying with a baby" → Safety `safety_travel`.

## 5. `pm_schemes`, changes (PM2, PM4)
REQUIRED_REVIEW (PMMVY 2.0, RBSK, JSSK, as of the release date).
- **The PMMVY card, made exact:**
  - **₹5,000 ($60) for the first child,** in two instalments: after the pregnancy is registered, and after the birth is registered and his first vaccines are given
  - **₹6,000 ($72) for a second child who is a girl,** in one instalment after the birth
  - apply through your anganwadi or ASHA worker, or the PMMVY portal
  - Don't leave it: the instalments depend on registration and his first vaccines.
- **Free vaccines** gains a link: "The vaccine schedule" → Health.
- **Anganwadi services** gains a link: "Anganwadi preschool and nursery admission" → Early learning.
- **Free care for sick newborns (JSSK)** gains a link: "If your baby is in the NICU" → Special care.
- **A new card, "If your child has a disability":** free early help at the DEIC up to 6, the UDID card, Niramaya health cover, and a tax deduction for the parent. Link: "Help in India, step by step" → Special care `sc_help_india`.

## 6. `pm_health_insurance`, a new card group (PM3)
REQUIRED_REVIEW (IRDAI rules and typical policy terms, as of the release date).

**Vaccines, doctor visits and therapy**
- **Vaccines:** most health policies don't pay for vaccines, because they're outpatient. Some family policies with maternity cover pay for the baby's vaccines in the first year, up to a limit. Look for a "newborn" or "vaccination" clause. Every vaccine on the national schedule is free at government centres; the optional ones, and doses at a private clinic, you pay for. Link: "The vaccine schedule" → Health.
- **Doctor visits (OPD):** usually not covered unless the policy has an OPD add-on. A hospital stay of 24 hours or more is what most policies pay for.
- **Therapy:** speech, occupational and physiotherapy sessions are outpatient, so they're usually not covered. Ask whether developmental delay or autism is excluded. Niramaya covers therapy for some conditions. Link: "Therapies, explained" → Special care.
- **Who to ask:** if your policy comes through work, the company that handles claims (the TPA, named on your health card) can tell you exactly what's covered.

## 7. `pm_saving`, a new card (PM4)
REQUIRED_REVIEW (the Income Tax Act, as of the release date).

**Tax, if you file under the old regime**
- **Section 80C:**
  - his school tuition fees, for up to two children
  - Sukanya Samriddhi and PPF deposits

  These count towards the yearly 80C limit.
- **Section 80D:** the premium for health insurance that covers your children.
- **Under the new tax regime,** most of these deductions don't apply. Ask whoever files your return which suits you.

## 8. `pm_planning_ahead`, links (PM2)
- "What your maternity leave entitles you to" → You, Maa `work_your_entitlement`, replacing the section link. The old link is commented out, "kept for revert".
- "If you're parenting on your own" → Family's "Doing it on your own".

## Sources (REQUIRED_REVIEW at build)
- **Births:** the Registration of Births and Deaths Act 1969, as amended in 2023, and the state rules.
- **Aadhaar:** the UIDAI rules on child enrolment and the mandatory biometric updates.
- **Passports:** the Passport Seva rules for minors (the declaration forms, photos and fees).
- **Schemes:** PMMVY 2.0 guidelines (Mission Shakti), JSSK, RBSK.
- **Legal aid:** the Legal Services Authorities Act 1987, Section 12 (women and children eligible); the NALSA helpline 15100.
- **Tax:** the Income Tax Act, Sections 80C and 80D, and the new regime under Section 115BAC.
- **Insurance:** IRDAI regulations; typical policy wording on newborn and OPD cover.
