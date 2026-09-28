# TTC expert sign-off list

Written 2026-09-26 in the TTC warmth pass. The made-up reviewer names in TTC were replaced with real people
from the expert roster (`Downloads/MASTER-CONTENT-PLAN-v3.xlsx`, sheet "Expert roster"), or with
"ParentVeda team" where no roster expert fits. This is the list to send each expert before launch. Where an
expert asks for changes, the text changes.

**Until a piece is signed off, the app does not name its expert (launch sanity H14, 2026-09-28).** A read, a
door carousel or an infographic shows "By ParentVeda team" with no tick. When an expert signs a piece off,
fill in its Signed off date here and, in the same commit, add it to that expert's set in
`lib/ttc/ttc_expert_signoff.dart`: a read by its id in `kTtcSignedOffReads`, a door carousel or infographic
by its Title as listed here in `kTtcSignedOffStories` (tiles have no id; the title is the id). That one line
brings back "Reviewed by" and the tick. `test/ttc_expert_signoff_test.dart` holds the rule.

Films are placeholders (nothing filmed yet); the name on a film is the plan for who presents it.

**Status (2026-09-26): nothing sent yet.** The user will send these later. Fill in the Sent and Signed off
columns with dates as it happens. Keep this list current: whenever a TTC read, door carousel or film
changes its named expert, run `py -3.11 tools/ttc_expert_signoff.py` (it reads the code, so the list always matches the app).

## Dr Ruchika Sood (72)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | after loss | Physical recovery, in plain terms | `ttc_read_loss_recovery` | | |
| Read | after loss | On trying again | `ttc_read_trying_again` | | |
| Read | body conditions | Your thyroid and fertility: the TSH test | `ttc_read_thyroid_tsh` | | |
| Read | body conditions | High prolactin and trying to conceive | `ttc_read_high_prolactin` | | |
| Read | body conditions | Genital TB and fertility | `ttc_read_genital_tb` | | |
| Read | body conditions | Pelvic infections (PID) and fertility | `ttc_read_pelvic_infection` | | |
| Read | body conditions | Seven things that can slow conception | `ttc_read_slow_conception` | | |
| Read | body conditions | Ovarian cysts: which ones matter when you're trying | `ttc_read_ovarian_cysts` | | |
| Read | body cycle | What counts as a late period, and the usual reasons | `ttc_read_late_period` | | |
| Read | body cycle | Irregular cycles when it isn't PCOS | `ttc_read_irregular_not_pcos` | | |
| Read | body cycle | Five kinds of bleeding, and how to tell them apart | `ttc_read_bleeding_kinds` | | |
| Read | body cycle | Spotting between periods: what it usually means | `ttc_read_spotting` | | |
| Read | body cycle | Ovulation pain and other mid-cycle signs | `ttc_read_ovulation_pain` | | |
| Read | body cycle | Is there such a thing as a "normal" cycle? | `ttc_read_normal_cycle` | | |
| Read | body cycle | Period pain: what's usual and what isn't | `ttc_read_period_pain` | | |
| Read | body cycle | Heavy, light or long periods: when to get them checked | `ttc_read_heavy_flow` | | |
| Read | body intimate | Is my discharge normal? What each kind means, and when to see a doctor | `ttc_read_discharge_guide` | | |
| Read | body intimate | Yeast infections and BV while trying: what they are and what's safe | `ttc_read_yeast_bv` | | |
| Read | body intimate | Urine infections (UTIs) while trying: why sex brings them on, and what to do | `ttc_read_uti_trying` | | |
| Read | body intimate | How to clean down there: water, not products | `ttc_read_intimate_washing` | | |
| Read | body intimate | Itching, smells, bumps and bleeding after sex: what's common and what needs a doctor | `ttc_read_intimate_worries` | | |
| Read | body intimate | Infections passed on through sex: why a quick test before trying helps | `ttc_read_sti_testing` | | |
| Read | conceiving | How conception works | `ttc_read_how_conception_works` | | |
| Read | conceiving | Timing, and the advice you can let go of | `ttc_read_timing_myths` | | |
| Read | conceiving | Ovulation kits: do they help? | `ttc_read_ovulation_kits` | | |
| Read | extra | Ovulation tests when your cycles are irregular | `ttc_read_ovulation_tests_irregular` | | |
| Read | extra | Can a past abortion affect getting pregnant? | `ttc_read_after_abortion` | | |
| Read | extra | Seeing a gynaecologist before you try: what to ask | `ttc_read_first_gyn_visit` | | |
| Read | getting ready | The tests and vaccinations worth doing first | `ttc_read_preconception_tests` | | |
| Read | getting ready | Folic acid: why you need it before, not after | `ttc_read_folic_acid` | | |
| Read | getting ready | What to cut before trying | `ttc_read_what_to_cut` | | |
| Read | getting ready | When to start what, and how early | `ttc_read_supplement_timing` | | |
| Read | getting ready | Weight before pregnancy, said kindly | `ttc_read_weight_kindly` | | |
| Read | getting ready | Coming off birth control | `ttc_read_coming_off_birth_control` | | |
| Read | getting ready | Medicines and conditions to check with a doctor | `ttc_read_meds_and_conditions` | | |
| Read | getting ready | The carrier screening that matters in India | `ttc_read_carrier_screening` | | |
| Read | loss more | Chemical pregnancy: what it is, and what it isn't | `ttc_read_chemical_pregnancy` | | |
| Read | loss more | Ectopic pregnancy: the signs that need a hospital today | `ttc_read_ectopic_pregnancy` | | |
| Read | loss more | What causes a miscarriage, and what doesn't | `ttc_read_miscarriage_causes` | | |
| Read | pcos | What PCOS is doing to your cycle | `ttc_read_pcos_cycle` | | |
| Read | pcos | What treatment usually looks like | `ttc_read_pcos_treatment` | | |
| Read | pcos | Irregular periods, explained | `ttc_read_pcos_irregular` | | |
| Read | pcos | If a doctor says PCOS | `ttc_read_pcos_diagnosed` | | |
| Read | pcos | PCOS and ovulation | `ttc_read_pcos_ovulation` | | |
| Read | pcos | Getting pregnant with PCOS: what to expect | `ttc_read_pcos_timelines` | | |
| Read | pcos | Eating for steadier blood sugar, with nothing banned | `ttc_read_pcos_insulin` | | |
| Read | pcos | Inositol: what the studies show | `ttc_read_pcos_inositol` | | |
| Read | pcos | Weight and PCOS, said kindly | `ttc_read_pcos_weight` | | |
| Read | pcos | Letrozole, metformin and the usual order | `ttc_read_pcos_meds` | | |
| Read | sex | Lubricants while trying: which ones are sperm-friendly? | `ttc_read_lubricants` | | |
| Read | sex | Sex after the fertile window: can it affect an early pregnancy? | `ttc_read_sex_after_window` | | |
| Read | waiting | The two-week wait, day by day | `ttc_read_two_week_wait` | | |
| Read | waiting | When to take a pregnancy test, and which one | `ttc_read_when_to_test` | | |
| Read | waiting | How to take a home pregnancy test, step by step | `ttc_read_how_to_test` | | |
| Read | waiting | A faint line on a pregnancy test: what does it mean? | `ttc_read_faint_line` | | |
| Read | waiting | Is it implantation bleeding or my period? | `ttc_read_implantation_bleeding` | | |
| Read | waiting | My period is late but the test is negative | `ttc_read_late_negative` | | |
| Read | waiting | Early pregnancy signs, and why most are also PMS | `ttc_read_early_signs` | | |
| Read | waiting | Feeling pregnant, but the test says no | `ttc_read_feeling_pregnant` | | |
| Door carousel | pcos | PCOS or ovarian cysts |  | | |
| Door carousel | pcos | PCOS or thyroid |  | | |
| Door carousel | pcos | Hair changes, explained |  | | |
| Door carousel | pcos | Cycles without ovulation |  | | |
| Door carousel | pcos | When to see a doctor |  | | |
| Film (not yet made) |  | PCOS, explained in five minutes | `ttc_vid_pcos_explained` | | |
| Film (not yet made) |  | The PCOS treatments your doctor may offer | `ttc_vid_pcos_treatment` | | |
| Film (not yet made) |  | Your cycle, drawn out step by step | `ttc_vid_cycle_basics` | | |
| Film (not yet made) |  | Six myths about timing, one by one | `ttc_vid_timing_myths` | | |
| Film (not yet made) |  | Is it time to see someone? | `ttc_vid_when_to_seek_help` | | |
| Film (not yet made) |  | An IVF cycle, start to finish | `ttc_vid_ivf_walkthrough` | | |
| Film (not yet made) |  | The tests and jabs to sort out once | `ttc_vid_preconception_tests` | | |
| Film (not yet made) |  | What the next few weeks look like | `ttc_vid_loss_recovery` | | |

## Dr Surbhi Sharma (37)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | age | Trying for a baby after 35: what changes? | `ttc_read_age_after_35` | | |
| Read | age | Trying for a baby after 40 | `ttc_read_age_after_40` | | |
| Read | age | How long does getting pregnant usually take? | `ttc_read_how_long_it_takes` | | |
| Read | age | Why is it harder to get pregnant the second time? | `ttc_read_second_baby` | | |
| Read | age | Egg freezing in India: is it right for me? | `ttc_read_egg_freezing` | | |
| Read | age | Donor eggs and donor sperm in India: what the law says | `ttc_read_donor_eggs_sperm` | | |
| Read | age | Surrogacy in India: who it's for and what the law says | `ttc_read_surrogacy_india` | | |
| Read | age | Words your clinic uses: a plain glossary | `ttc_read_clinic_glossary` | | |
| Read | age | Ovulation tablets in plain words: letrozole and clomiphene | `ttc_read_ovulation_tablets` | | |
| Read | age | Follicle scans: what is the doctor looking for? | `ttc_read_follicle_scans` | | |
| Read | body conditions | Endometriosis and trying to conceive | `ttc_read_endometriosis` | | |
| Read | body conditions | Fibroids and polyps: which ones matter when you're trying | `ttc_read_fibroids_polyps` | | |
| Read | body conditions | Blocked tubes and the HSG test | `ttc_read_blocked_tubes_hsg` | | |
| Read | ivf | When it's time to see a doctor | `ttc_read_when_to_seek_help` | | |
| Read | ivf | What IUI and IVF involve | `ttc_read_ivf_explained` | | |
| Read | ivf | How to read a clinic's success rate | `ttc_read_ivf_success_rates` | | |
| Read | ivf | What IVF really costs in India | `ttc_read_ivf_costs` | | |
| Read | ivf | ICSI: when it's needed, and when it's just routine | `ttc_read_ivf_icsi` | | |
| Read | ivf | What a fertility check involves | `ttc_read_ivf_workup` | | |
| Read | ivf | The injections: what they're really like | `ttc_read_ivf_injections` | | |
| Read | ivf | OHSS: when to call the clinic | `ttc_read_ivf_ohss` | | |
| Read | ivf | What a package leaves out | `ttc_read_ivf_package` | | |
| Read | ivf | Is egg retrieval painful? | `ttc_read_ivf_retrieval` | | |
| Read | ivf | Can I work through a cycle? | `ttc_read_ivf_working` | | |
| Read | treatment | The trigger injection: why the time is exact | `ttc_read_tx_trigger_shot` | | |
| Read | treatment | Transfer day, and the progesterone after it | `ttc_read_tx_transfer_day` | | |
| Read | treatment | The two-week wait after IVF or IUI | `ttc_read_tx_wait_after_treatment` | | |
| Read | treatment | The beta test: what it is, and why it's sometimes repeated | `ttc_read_tx_beta_test` | | |
| Read | treatment | When the test is negative after treatment: the next few weeks | `ttc_read_tx_negative_after_treatment` | | |
| Read | treatment | Your first treatment visit: the baseline scan | `ttc_read_tx_baseline_scan` | | |
| Read | treatment | Frozen embryo transfer, step by step | `ttc_read_tx_frozen_transfer` | | |
| Read | treatment | Monitoring scans during IVF: what they're checking | `ttc_read_tx_monitoring_scans` | | |
| Read | treatment | IUI day: what happens | `ttc_read_tx_iui_day` | | |
| Read | treatment | Day 1, day 3, day 5: the words the lab uses | `ttc_read_tx_embryo_days` | | |
| Read | treatment | Fresh or frozen transfer: how clinics decide | `ttc_read_tx_fresh_or_frozen` | | |
| Read | treatment | Your review appointment: questions to take | `ttc_read_tx_review_appointment` | | |
| Door carousel | ivf | IUI or IVF, and when to move from one to the other |  | | |

## ParentVeda team (19)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | conceiving | Morning temperature: how it works | `ttc_read_morning_temperature` | | |
| Read | extra | When sex is hard for him under pressure | `ttc_read_his_side_pressure` | | |
| Read | extra | Does his age affect getting pregnant? | `ttc_read_his_age` | | |
| Read | extra | Money before a baby: what to sort out now | `ttc_read_money_before_baby` | | |
| Read | his side | Whose "side" is it, really | `ttc_read_whose_side` | | |
| Read | his side | What a semen analysis involves | `ttc_read_semen_analysis` | | |
| Read | his side | Heat, habits and time | `ttc_read_heat_habits` | | |
| Read | his side | If no sperm is found | `ttc_read_azoospermia` | | |
| Read | his side | The words on the report, in plain English | `ttc_read_report_words` | | |
| Read | his side | If the result is normal | `ttc_read_result_normal` | | |
| Read | his side | If the first test is abnormal | `ttc_read_result_abnormal` | | |
| Read | his side | The case for testing early | `ttc_read_case_for_testing` | | |
| Read | his side | What three months looks like | `ttc_read_three_months` | | |
| Read | his side | Zinc and CoQ10, honestly | `ttc_read_zinc_coq10` | | |
| Door carousel | conceiving | How sperm are made |  | | |
| Door carousel | screen | Every door myth (the story built in code) |  | | |
| Film (not yet made) |  | Why his side gets tested last | `ttc_vid_whose_side` | | |
| Film (not yet made) |  | Reading a semen report without panicking | `ttc_vid_semen_analysis` | | |
| Film (not yet made) |  | Three things that really change his numbers | `ttc_vid_heat_habits` | | |

## Parmeshwari (18)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | hard days | Your period came. What now? | `ttc_read_period_came` | | |
| Read | hard days | When other people's pregnancy news is hard | `ttc_read_others_news` | | |
| Read | hard days | Should you tell family you're trying? | `ttc_read_telling_family` | | |
| Read | hard days | When trying starts to take over your life | `ttc_read_trying_takes_over` | | |
| Read | hard days | Three answers for "Koi good news?" | `ttc_read_good_news_answers` | | |
| Read | hard days | Coping when month after month doesn't work | `ttc_read_month_after_month` | | |
| Read | loss more | Trying again after a loss: the feelings that come with it | `ttc_read_loss_feelings` | | |
| Read | mind body | Stress, and the thing everyone says about it | `ttc_read_stress_fertility` | | |
| Read | mind body | Preconception garbh sanskar, honestly | `ttc_read_garbh_sanskar` | | |
| Read | mind body | Why sleep matters when you're trying | `ttc_read_sleep_trying` | | |
| Read | mind body | Setting a bedtime you can keep | `ttc_read_bedtime` | | |
| Read | mind body | When family keeps asking | `ttc_read_family_asking` | | |
| Read | mind body | Bringing him into this | `ttc_read_bringing_him_in` | | |
| Read | safety | When a relationship doesn't feel safe | `ttc_read_relationship_safety` | | |
| Read | sex | When sex starts to feel like homework | `ttc_read_sex_homework` | | |
| Read | sex | Low desire while trying, hers and his | `ttc_read_low_desire` | | |
| Read | sex | Keeping closeness alive through the months | `ttc_read_keeping_close` | | |
| Film (not yet made) |  | Why "just relax" is the wrong advice | `ttc_vid_stress_fertility` | | |

## Akanksha Srivastava (9)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | getting ready | The three months before | `ttc_read_three_months_before` | | |
| Read | meal plan | A week of fertility-friendly Indian meals | `ttc_read_meal_plan_week` | | |
| Read | meal plan | Ten everyday recipes for the months before pregnancy | `ttc_read_everyday_recipes` | | |
| Read | meal plan | Ask a dietitian: ten questions answered | `ttc_read_ask_dietitian` | | |
| Read | meal plan | Iron before pregnancy: Indian foods, vitamin C and tea timing | `ttc_read_iron_before_pregnancy` | | |
| Read | meal plan | Omega-3 without fish: what vegetarians can eat | `ttc_read_omega3_without_fish` | | |
| Read | pcos | Food, insulin and PCOS | `ttc_read_pcos_food` | | |
| Film (not yet made) |  | What a PCOS-friendly Indian plate looks like | `ttc_vid_pcos_plate` | | |
| Film (not yet made) |  | Why three months, and not three weeks | `ttc_vid_three_months_before` | | |

## Dr Kajal Sharma (2)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Film (not yet made) |  | Preconception garbh sanskar, taught | `ttc_vid_garbh_preconception` | | |
| Film (not yet made) |  | A longer session, for a day you have time | `ttc_vid_mind_longer_session` | | |

## Dr Simranpreet Sandhu (1)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | loss more | Recurrent miscarriage: when to ask for tests | `ttc_read_recurrent_miscarriage` | | |

## Dr Vaishnavi (1)

| Kind | Door | Title | id | Sent | Signed off |
|---|---|---|---|---|---|
| Read | sex | Pain during sex, including vaginismus | `ttc_read_pain_vaginismus` | | |

## Gaps and notes

- **No male-fertility specialist on the roster.** The ten His side reads say "By ParentVeda team" with no tick.
  Adding an andrologist or urologist to the "still to hire" list would let them carry a real reviewer.
- **Dr Ruchika Sood carries most of TTC.** The roster already calls her the single sign-off bottleneck; this list
  makes that concrete. Dr Simranpreet Sandhu (IVF counsellor) could take the IVF basics reads if the roster owner
  agrees.
- **Dr Ruchika Sood is not in the app's expert directory (`kExperts`)**, so tapping her byline may not open a
  profile yet.
- Out of TTC scope but carrying the same made-up names: `lib/data/community_data.dart` and
  `lib/data/mind_mood_data.dart` (pregnancy and community), plus pregnancy reads.
