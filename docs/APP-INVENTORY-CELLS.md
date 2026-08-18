# The 280 cells — generated from lib/data/brackets/*.dart

Companion to `APP-INVENTORY-DUMP.md`. **This is the reconciliation surface.**

Format — `layer  STATE  → surface ids` for live cells, `layer  state  workbook reason` otherwise.

LIVE = existing, map it · notReady = NEW · notCore = exists elsewhere · notApplicable = refused, never render

```

### PREGNANCY  (10 brackets)

pregnancy_scans_tests   [Scans & tests]
   content     LIVE        -> tests_scans
   activities  notCore     Not core (rides week spine)
   tools       LIVE        -> appointments, due_date
   products    notApplicable Not a fit
   course      notCore     Not standalone (module of childbirth prep)
   consult     LIVE        -> consults
   extras      LIVE        -> reports

pregnancy_complications   [Complications]
   content     LIVE        -> tests_scans
   activities  notCore     Not core
   tools       LIVE        -> movement
   products    notReady    Glucometer, BP monitor (affiliate)
   course      notCore     Modules, not standalone
   consult     LIVE        -> consults
   extras      LIVE        -> symptoms

pregnancy_is_it_safe   [Is it safe?]
   content     LIVE        -> can_i
   activities  notCore     Not core
   tools       LIVE        -> can_i
   products    notApplicable Not a fit
   course      notApplicable Not a fit
   consult     notReady    Light quick-query consult
   extras      LIVE        -> can_i

pregnancy_nutrition   [Nutrition]
   content     LIVE        -> nutrition
   activities  notCore     Not core
   tools       LIVE        -> nutrition, weight
   products    notReady    Prenatal supplements, protein (affiliate)
   course      notReady    Trimester nutrition masterclass (paid)
   consult     LIVE        -> consults
   extras      notReady    Pregnancy-safe recipe playlist

pregnancy_symptoms   [Symptoms]
   content     LIVE        -> symptoms
   activities  LIVE        -> yoga
   tools       LIVE        -> symptoms
   products    LIVE        -> shop
   course      notApplicable Not a fit
   consult     notApplicable Not a fit
   extras      notApplicable None proposed

pregnancy_labour   [Labour prep]
   content     LIVE        -> hospital_bag, daily_reads
   activities  LIVE        -> yoga
   tools       LIVE        -> contractions, hospital_bag, kegel
   products    LIVE        -> shop, product_guide
   course      LIVE        -> masterclasses, cohorts, birthing_classes
   consult     LIVE        -> consults
   extras      notReady    Birth-plan builder

pregnancy_garbh   [Garbh Sanskar]
   content     LIVE        -> garbh_daily
   activities  LIVE        -> garbh_daily
   tools       LIVE        -> garbh_daily
   products    notReady    Garbh sanskar music / books (affiliate)
   course      notReady    Recorded trimester-wise garbh sanskar (free hero course)
   consult     notCore     Not core
   extras      notApplicable None proposed

pregnancy_fitness   [Yoga & fitness]
   content     LIVE        -> yoga
   activities  LIVE        -> yoga
   tools       notCore     Not core
   products    notReady    Mat, ball (minor affiliate)
   course      LIVE        -> cohorts, masterclasses
   consult     LIVE        -> consults
   extras      notApplicable None proposed

pregnancy_mental_health   [Mind & mood]
   content     notReady    Anxiety, prenatal depression, mood, common fears
   activities  LIVE        -> yoga
   tools       notReady    Mood check
   products    notApplicable Not a fit
   course      notApplicable Not a fit
   consult     LIVE        -> consults
   extras      notApplicable None proposed

pregnancy_belly_skin   [Belly & skin]
   content     notReady    Stretch marks (prevent & treat), pigmentation, itching
   activities  notApplicable Not a fit
   tools       notApplicable Not a fit
   products    LIVE        -> shop
   course      notApplicable Not a fit
   consult     notApplicable Not a fit
   extras      notApplicable None proposed

### TTC  (7 brackets)

ttc_conceiving   [Fertile window]
   content     LIVE        -> ttc_chapter, ttc_can_i
   activities  notCore     Not core (prep sits in mind-body)
   tools       LIVE        -> ttc_cycle, ttc_ovulation, ttc_window, ttc_calendar
   products    LIVE        -> ttc_products
   course      LIVE        -> ttc_prepare
   consult     LIVE        -> ttc_prepare
   extras      notApplicable Nothing proposed

ttc_pcos   [PCOS]
   content     LIVE        -> ttc_chapter
   activities  notCore     Not core
   tools       LIVE        -> ttc_cycle, ttc_calendar
   products    LIVE        -> ttc_supplements
   course      LIVE        -> ttc_prepare
   consult     LIVE        -> ttc_prepare
   extras      notApplicable Nothing proposed

ttc_infertility   [IVF & IUI]
   content     LIVE        -> ttc_treatment
   activities  notCore     Not core
   tools       notReady    
   products    notApplicable Not a fit (clinical)
   course      notCore     Workbook: "Not a fit (too clinical to package)". 
   consult     LIVE        -> ttc_prepare
   extras      LIVE        -> ttc_records, ttc_tests

ttc_preconception_health   [Getting ready]
   content     LIVE        -> ttc_nutrition, ttc_tests
   activities  notReady    Light habit-building
   tools       notReady    Pre-pregnancy checklist, BMI
   products    LIVE        -> ttc_supplements, ttc_products
   course      notCore     Folds into the conception masterclass
   consult     LIVE        -> ttc_prepare
   extras      notApplicable Nothing proposed

ttc_male_fertility   [His side]
   content     LIVE        -> ttc_partner
   activities  notApplicable Not a fit
   tools       notApplicable Not a fit
   products    notReady    Male fertility supplements (careful)
   course      LIVE        -> ttc_prepare
   consult     LIVE        -> ttc_prepare
   extras      notApplicable Nothing proposed

ttc_after_loss   [After a loss]
   content     notReady    Physical recovery, when it is safe to try again, emotional support
   activities  notApplicable Not a fit
   tools       notApplicable Not a fit
   products    notApplicable Not a fit
   course      notCore     Workbook: "Not a fit". "After a loss" ships in Prepare — 
   consult     LIVE        -> ttc_prepare
   extras      LIVE        -> ttc_community

ttc_mind_body   [Mind & body]
   content     LIVE        -> ttc_chapter
   activities  LIVE        -> ttc_ritual, ttc_journal
   tools       notCore     Not core
   products    notCore     Not core
   course      notReady    Preconception garbh sanskar (FREE acquisition hook)
   consult     notCore     Not core
   extras      notApplicable Nothing proposed

### PARENTING  (11 brackets)

parenting_sleep   [Sleep]
   content     LIVE        -> pp_read, pp_watch
   activities  notReady    Wind-down routine, drowsy-but-awake practice
   tools       LIVE        -> pp_sleep, pp_what_changed
   products    LIVE        -> pp_products
   course      LIVE        -> pp_courses
   consult     LIVE        -> pp_experts
   extras      LIVE        -> pp_nuskhe

parenting_feeding   [Feeding]
   content     LIVE        -> pp_food, pp_read
   activities  notCore     Not core
   tools       LIVE        -> pp_feeding, pp_growth, pp_what_changed
   products    LIVE        -> pp_products
   course      LIVE        -> pp_courses
   consult     notReady    Lactation (paid, most certain sale) + pediatric nutrition
   extras      LIVE        -> pp_food

parenting_health   [Health]
   content     LIVE        -> pp_read, pp_watch
   activities  notCore     Not core
   tools       LIVE        -> pp_vaccines, pp_health, pp_what_changed, pp_growth
   products    LIVE        -> pp_products
   course      notApplicable Not a fit (reactive; content + consult)
   consult     LIVE        -> pp_experts
   extras      LIVE        -> pp_health

parenting_development   [Development]
   content     LIVE        -> pp_development
   activities  LIVE        -> pp_activities
   tools       LIVE        -> pp_milestones, pp_development
   products    notApplicable Not a fit
   course      LIVE        -> pp_courses
   consult     LIVE        -> pp_experts
   extras      notApplicable None proposed

parenting_behaviour   [Behaviour]
   content     notReady    Tantrums, discipline, screen time, biting / hitting, sharing
   activities  notReady    Connection / regulation techniques
   tools       LIVE        -> pp_what_changed
   products    notReady    Emotion cards, books (minor affiliate)
   course      notReady    Positive discipline / toddler behaviour masterclass (paid)
   consult     LIVE        -> pp_experts
   extras      notReady    

parenting_potty   [Potty training]
   content     notReady    Readiness signs, methods, night training, regressions
   activities  notReady    Potty routine
   tools       notApplicable None proposed
   products    notReady    Potty seat, training pants (affiliate)
   course      notReady    Short potty-training masterclass (paid, low ticket)
   consult     notReady    Light
   extras      notApplicable None proposed

parenting_early_learning   [Early learning]
   content     notReady    Montessori-at-home, activities, good habits, moral stories
   activities  LIVE        -> pp_activities
   tools       notReady    Not strong
   products    LIVE        -> pp_recos
   course      notReady    Early-learning / school-readiness masterclass + activity box
   consult     notCore     Not core
   extras      notReady    Bridges into skilling (Stage 4)

parenting_first_40   [First 40 days]
   content     notReady    Newborn care A-Z, feeding / sleep basics, mother recovery
   activities  notReady    Newborn soothing, malish, baby-wearing
   tools       notReady    Newborn feed / sleep / diaper tracker
   products    notReady    Postpartum care kit, malish oil, newborn essentials
   course      LIVE        -> pp_courses
   consult     notReady    Newborn-care + lactation consult
   extras      notApplicable None proposed

parenting_maternal   [You]
   content     LIVE        -> pp_read, pp_watch
   activities  LIVE        -> pp_yoga
   tools       notReady    No maternal tracker exists
   products    notReady    Postpartum belt, nursing essentials
   course      LIVE        -> pp_courses
   consult     notReady    Maternal mental-health counselling; pelvic-floor physio
   extras      notReady    4th-trimester peer circle (community)

parenting_buying   [What to buy]
   content     LIVE        -> pp_product_guide
   activities  notApplicable Not a fit
   tools       LIVE        -> pp_product_guide, pp_recos
   products    LIVE        -> pp_products
   course      notApplicable Not a fit
   consult     notApplicable Not a fit
   extras      notApplicable None proposed

parenting_traditional   [Traditions]
   content     LIVE        -> pp_nuskhe
   activities  notReady    Ritual or event how-tos
   tools       LIVE        -> pp_nuskhe, pp_names
   products    notReady    Ceremony essentials (minor affiliate)
   course      notApplicable Not a fit
   consult     notCore     Not core
   extras      notApplicable None proposed

### SKILLING  (12 brackets)

skilling_focus   [Focus]
   content     notReady    Attention games, sustained-focus drills
   activities  notReady    Practice set (per skilling pattern)
   tools       notReady    Rubric progress tracker
   products    notReady    Optional workbook
   course      notReady    Leveled program (paid)
   consult     notReady    Rare
   extras      notReady    Challenges, certificates, progress report

skilling_confidence   [Confidence]
   content     notReady    Speaking practice with prompts, stage exercises
   activities  notReady    Practice + record & self-review
   tools       notReady    Record & self-review tool + rubric tracker
   products    notReady    Optional
   course      notReady    Leveled program (paid)
   consult     notReady    Speaking coach
   extras      notReady    Challenges, certificates, progress report

skilling_communication   [Expression]
   content     notReady    Daily speaking prompts, storytelling, spoken expression
   activities  notReady    Practice set
   tools       notReady    Rubric tracker
   products    notReady    Optional
   course      notReady    Leveled program (paid)
   consult     notReady    Rare
   extras      notReady    Challenges, certificates, progress report

skilling_critical_thinking   [Thinking]
   content     notReady    
   activities  notReady    Practice set
   tools       notReady    Rubric tracker
   products    notReady    Optional
   course      notReady    Leveled program (paid)
   consult     notReady    Rare
   extras      notReady    Challenges, certificates, progress report

skilling_values   [Values]
   content     notReady    Moral stories & good habits, habit-building (rooted, secular)
   activities  notReady    Habit / story practice
   tools       notReady    Habit / rubric tracker
   products    notReady    Story books / values workbook
   course      notReady    Leveled program (paid) - the rooted layer for kids
   consult     notReady    Rare
   extras      notReady    

skilling_maths   [Maths]
   content     notReady    Vedic maths, abacus, mental-math drills (leveled)
   activities  notReady    Drill practice
   tools       notReady    Rubric tracker
   products    notReady    Workbook
   course      notReady    Leveled program (paid)
   consult     notReady    Rare
   extras      notReady    Challenges, certificates, progress report

skilling_coding   [Coding]
   content     notReady    Unplugged -> block-based -> projects, age-banded
   activities  notReady    Project practice
   tools       notReady    Project / rubric tracker (honest, no outcome promises)
   products    notReady    Optional
   course      notReady    Leveled program (paid) - WhiteHat Jr caution
   consult     notReady    Rare
   extras      notReady    Challenges, certificates, progress report

skilling_reading   [Reading]
   content     notReady    Leveled reading challenges, book lists by age
   activities  notReady    Reading practice
   tools       notReady    Reading tracker
   products    notReady    Book lists (affiliate)
   course      notReady    Optional
   consult     notReady    Rare
   extras      notReady    Challenges, streaks, progress report

skilling_creativity   [Making]
   content     notReady    Art, music, and making prompts
   activities  notReady    Making practice
   tools       notReady    Portfolio tracker
   products    notReady    Optional
   course      notReady    Optional
   consult     notReady    Rare
   extras      notReady    Portfolio showcase

skilling_emotional   [Feelings]
   content     notReady    Scenario practice, journaling prompts
   activities  notReady    Scenario / journal practice
   tools       notReady    Rubric tracker
   products    notReady    Optional
   course      notReady    Optional
   consult     notReady    Rare
   extras      notReady    Progress report

skilling_stillness   [Stillness]
   content     notReady    Guided kid meditations & yoga
   activities  notReady    Guided practice
   tools       notReady    Streak tracker
   products    notReady    Optional
   course      notReady    Optional
   consult     notReady    Rare
   extras      notReady    Streaks, progress report

skilling_memory   [Memory]
   content     notReady    Memory techniques, study skills
   activities  notReady    Technique practice
   tools       notReady    Rubric tracker
   products    notReady    Optional
   course      notReady    Optional
   consult     notReady    Rare
   extras      notReady    Progress report


=== TOTALS === {'live': 91, 'notReady': 129, 'notCore': 21, 'notApplicable': 39}  sum=280
```
