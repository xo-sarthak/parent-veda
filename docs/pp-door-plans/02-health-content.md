# Door 2: Health, the 15 new pages (decision H6)

Written 2026-10-23, ready to go into `pp_health_content.dart` in the build.
Each page is written in the content model's own blocks, so the build only types it in:
- `PpIntro`
- `PpArticle` (paragraphs)
- `PpCards`
- `PpSteps`
- `PpCallout`
- `PpWhenLine`
- `PpIndiaNote`
- the doctor callout (`PpCallout`, `kind: doctor`)
- `PpLink`
- `PpConsult`

House rules held throughout:
- **Never a dose from us** (the Medicines tab footer). Programme medicines (deworming, iron syrup, Vitamin A) are named with *who gives them and when*, never an amount to measure at home.
- **Never a diagnosis.** Every clinical page ends with a doctor callout.
- **No pitch on a go-now page** (§3a). `ill_bites` and `ill_head_bump` are emergency pages: no consult, no product.
- **REQUIRED_REVIEW** marks every clinical line. A paediatrician reads all 15 before release (BEFORE-LAUNCH).
- English only, no emoji, "your child" with "he" where the app already uses it.

Sources are at the end. Where a source is secondary (not the ministry's own document), that is marked, and the reviewer checks it against the current MoHFW guideline.

---

## 1. `ill_dengue`: "Dengue: the days that matter"
Area `other_illness` · format ARTICLE · bands all · after `ill_ear`
Placement: also linked from `fever_long` and `prev_monsoon` (`PpLink`)
Consult: Paediatrician, offer card under the doctor box
Product: cot and pram mosquito net (owed), after the prevention cards

**Intro.** Dengue frightens parents more than any other fever, and the fear usually lands on the wrong day. The fever itself is rarely the danger. The days just after the fever drops are the ones to watch.

**Article.**
1. Dengue starts like many fevers: a high temperature, body ache, a headache, sometimes pain behind the eyes and a red flush. Young children often just seem miserable and off their food. Only a blood test confirms it, and your doctor decides when. A test on day one can miss it.
2. Fever usually lasts two to seven days. Then, as it falls, some children enter what doctors call the critical phase: fluid can leak out of the blood vessels for a day or two. **This is why a falling fever in dengue does not mean he is better yet.** Keep watching for two full days after the fever settles. REQUIRED_REVIEW
3. Fluids are the treatment. Small sips, often: ORS, water, coconut water, dal water, soup, buttermilk, breast milk for a baby. Count the wees. A child who is drinking and weeing is a child whose body is coping.
4. Only paracetamol for the fever, in the dose your doctor gives by weight. **Never ibuprofen, aspirin, mefenamic acid or any other painkiller of that family in suspected dengue. They raise the risk of bleeding.** REQUIRED_REVIEW

**Cards, heading "Watch for these, especially as the fever falls" (each one means hospital today):** REQUIRED_REVIEW
- **Tummy pain that is bad or doesn't stop**
- **Vomiting again and again**, or not keeping fluids down
- **Bleeding**: gums, nose, blood in vomit or stool, black stool, new bruises
- **Drowsy, floppy, or very restless and irritable**
- **Fewer wees**: none in six hours for a toddler, or far fewer nappies for a baby
- **Cold, clammy hands and feet**, or fast breathing

**Callout.** Platelet counts are what everyone in the family will ask about. A falling count is expected in dengue, and your doctor reads it alongside how your child looks and drinks. Papaya leaf juice, goat milk and kiwi do not raise platelets in a way that changes the outcome. They can be comforting, but they are not treatment. REQUIRED_REVIEW

**WhenLine.** Fever with body ache in the monsoon or after it: see a doctor on day two or three, not day six.

**IndiaNote.** Dengue mosquitoes bite in the daytime and breed in clean standing water: coolers, flower pots, tyres, the tray under the fridge. Emptying these once a week protects your family more than any coil.

**Cards, heading "Keeping the mosquito away":**
- **Nets for naps**: a net over the cot or pram in the daytime too, because this mosquito bites by day.
- **Long, light sleeves** in the evening and morning.
- **Empty standing water weekly**, including the cooler.
- **Repellents by age**: ask your doctor before using any repellent under two months. For older babies, use one made for children, on clothes more than skin. REQUIRED_REVIEW

**Doctor callout, title "Go to a hospital today if":** any sign from the list above; a baby under one year with suspected dengue; or a child who won't drink. REQUIRED_REVIEW

**Links:** Go to a hospital now (`health_go_now`) · Long fever (`fever_long`) · Monsoon at home (`prev_monsoon`).

---

## 2. `ill_febrile_seizure`: "A fit with a fever"
Area `emergency` (linked from `fever_red_flags`, `health_fit`) · format STEPS · bands I T C
**No pitch** (go-now family). Video: reuses the `health_fit` slot via a link, so there is no second film.

**Intro.** Watching your child have a fit is one of the most frightening things a parent sees. A fit that comes with a fever, between six months and five years, is common and usually does no lasting harm. You still act straight away.

**Steps, heading "During the fit":** REQUIRED_REVIEW
1. **Note the time.** How long it lasts matters to the doctor.
2. **Lay him on his side** on the floor, away from anything hard or sharp.
3. **Nothing in his mouth.** No spoon, no finger, no water, no medicine. He will not swallow his tongue.
4. **Don't hold him down** and don't try to stop the jerking.
5. **Loosen tight clothes** around the neck.
6. **Call 112, or go to hospital, if it lasts more than five minutes**, if his lips stay blue, or if it is his first fit ever.

**Steps, heading "After the fit":**
1. He will be sleepy and confused for a while. That is expected.
2. Keep him on his side until he is awake.
3. **A first fit always gets seen by a doctor the same day**, even if he looks fine afterwards. The doctor looks for what caused the fever.

**Article.**
1. These fits happen because a young brain reacts to a fast-rising temperature. They are not epilepsy, and most children who have one never have another. About a third have one more in a later fever. REQUIRED_REVIEW
2. Bringing the fever down with medicine has not been shown to prevent the next fit. Give paracetamol for comfort, not as protection, so you don't blame yourself if a fit happens after a dose. REQUIRED_REVIEW

**IndiaNote.** Don't put onion, shoes or keys to his nose, and don't sprinkle water on his face. They don't stop a fit, and they waste the minutes you need to time it and keep him safe.

**Doctor callout, title "Straight to hospital if":** the fit lasts more than five minutes; he is under six months; he doesn't wake properly within an hour; there is a stiff neck, a rash that doesn't fade under a glass, or breathing trouble; or one side of the body jerks. REQUIRED_REVIEW

**Links:** Go to a hospital now · A fit or seizure (`health_fit`).

---

## 3. `ill_throat`: "Sore throat and tonsils"
Area `other_illness` · ARTICLE · bands T C · lead of the hb_child age rail
Consult: Paediatrician · Product: none

**Intro.** Most sore throats in children are viruses and get better on their own in a week. A few need antibiotics, and only a doctor can tell which. Big tonsils alone are not a reason for an operation.

**Article.**
1. A viral sore throat usually comes with a cold: a runny nose, a cough, a hoarse voice. A bacterial one (strep) more often comes with a sudden high fever, painful swallowing, swollen glands in the neck and no cough, and is more common after the age of three. REQUIRED_REVIEW
2. Antibiotics help the bacterial kind and do nothing for the viral kind. If your doctor starts one, finish the course. Stopping when he feels better is how the next one fails (see `prev_antibiotics`).
3. Comfort works for both: warm drinks, cold drinks, soft food, rest. For a child over one, a little honey in warm water soothes. **Never honey before one year.** Don't give gargles or lozenges to a child too young to manage them without choking. REQUIRED_REVIEW

**Cards, heading "Tonsils, and the operation question":**
- **Big tonsils are normal** in young children and shrink with age.
- **The operation is considered** for many throat infections in a year, or for loud snoring with pauses in breathing at night. Your doctor counts with you. REQUIRED_REVIEW
- **Snoring with pauses** (sleep apnoea) is worth a visit even without infections.

**WhenLine.** A sore throat with a high fever and no cold: see a doctor in a day or two. Most others can wait a week.

**IndiaNote.** Cold water, curd and ice cream don't cause a sore throat. A cold drink is often the most comforting thing a child with a painful throat will take, so let him have it.

**Doctor callout, title "Go to a doctor today, or hospital, if":** he can't swallow his own spit and is drooling; he can't open his mouth fully; breathing is noisy or hard; or he is very drowsy. These go to hospital. A fever over three days, or a rash like sandpaper, means a doctor the same day. REQUIRED_REVIEW

**Consult (`PpConsult`):** "Paediatrician on video" · whoFor: "If it has gone on more than a week, keeps coming back, or you want to know whether it needs an antibiotic."

---

## 4. `ill_worms`: "Worms, and Deworming Day"
Area `tummy` · ARTICLE · bands T C · in the hb_child age rail
Consult: Paediatrician · Product: none

**Intro.** Worms are common in children who play on the ground, and they are easy to treat. India deworms every child twice a year for free. Knowing the dates means you don't need to buy anything.

**Article.**
1. Roundworm, hookworm and whipworm eggs live in soil. They reach a child's mouth from hands, nails and unwashed fruit. Many children with worms show nothing. Some get tummy aches, a poor appetite, slow weight gain or tiredness from low iron.
2. **National Deworming Day is 10 February and 10 August.** Children from one to nineteen years get one dose of a deworming medicine (albendazole) at school or at the anganwadi. A child who misses it gets it on the mop-up day a few days later. For children under five, the anganwadi worker gives it. REQUIRED_REVIEW (confirm the current dates and mop-up days with MoHFW)
3. Threadworm is different: an itchy bottom at night, sometimes with tiny white threads seen in the morning. It spreads around the family easily, and your doctor may treat everyone at home together.

**Cards, heading "Keeping worms away":**
- **Wash hands** after the toilet, after outdoor play, and before eating.
- **Short nails**, and slippers outdoors (hookworm enters through bare feet).
- **Wash fruit and vegetables** well; peel where you can.
- **Clean drinking water**, boiled or filtered.

**WhenLine.** Missed both deworming days this year? Ask your paediatrician at the next visit; don't buy a dose yourself.

**IndiaNote.** Sweets don't cause worms, and grinding teeth at night is not a sign of them. Teeth grinding is common and usually harmless.

**Doctor callout:** See your doctor if your child has a tummy ache that keeps coming back, is losing weight, looks pale, or you see a worm in the stool or vomit. REQUIRED_REVIEW

---

## 5. `ill_anaemia`: "Iron, anaemia and the iron syrup"
Area `growth` · ARTICLE · bands I T C · after `growth_flags`
Consult: Paediatric nutritionist · Product: none (no supplements, H4)

**Intro.** Low iron is the most common nutrition problem in Indian children, and it is quiet. A child can look fine and still be short of iron, which affects energy, attention and learning. The fix is food, the government's iron syrup, and a simple blood test when your doctor asks for one.

**Article.**
1. A baby's iron store from birth lasts about six months. After that, iron has to come from food. Children who drink a lot of cow's milk often eat less of everything else, and milk itself carries almost no iron. That is the commonest route to low iron in toddlers. REQUIRED_REVIEW
2. Signs, when there are any: pale skin, pale inner eyelids and nails, tiredness, being irritable, poor appetite, and sometimes eating mud, chalk or ice. Many children have none of these, which is why doctors test.
3. **Under the Anemia Mukt Bharat programme, children from six months to five years get an iron and folic acid syrup twice a week, free, from the ASHA or anganwadi.** It comes with its own dispenser. Give it as they show you. Don't add other iron drops on top unless your doctor asks. Too much iron is dangerous for a child, and an iron bottle must be kept locked away. REQUIRED_REVIEW (confirm the schedule against the current MoHFW guideline)
4. Iron syrup can darken stools and stain teeth. Giving it with a little water and wiping the teeth afterwards helps.

**Cards, heading "Iron on a child's plate":**
- **Dals, rajma, chana and sprouts**, every day if you can.
- **Green leaves**: palak, methi, bathua and drumstick leaves, cooked into dal or roti.
- **Ragi, bajra and jaggery-sweetened ladoos** (from one year).
- **Eggs, fish and meat**, if your family eats them, are the best-absorbed iron.
- **Add vitamin C**: a squeeze of lemon on dal, or amla or orange alongside, helps the iron in.
- **Keep tea away from meals**: tea blocks iron. No tea for young children at all.

**WhenLine.** Over one year and drinking more than about two glasses of milk a day? Bring meals forward and milk back, before you worry about tests.

**IndiaNote.** Cooking in an iron kadhai adds a little iron to food. It helps, but it is not a treatment.

**Doctor callout:** See your doctor if your child is pale, tired all the time, breathless on play, or eats mud or chalk. A simple blood test tells you. REQUIRED_REVIEW

**Consult:** Paediatric nutritionist · whoFor: "If he is a picky eater or drinks mostly milk, and you want a week of meals that carry iron."

---

## 6. `prev_vitamin_a`: "The free Vitamin A doses"
Area `prevention` · CARDS · bands I T C · near `prev_immunity`
No consult, no product.

**Intro.** From nine months, Indian children are given Vitamin A by mouth at the health centre, usually alongside a vaccine and then every six months. It protects the eyes and helps children fight infections. It's free, and it's easy to miss after the vaccine visits get further apart.

**Cards:** REQUIRED_REVIEW (confirm the current schedule; sources differ on whether the doses run to 3 or 5 years in each state)
- **The first dose at 9 months**, usually with the measles-rubella vaccine.
- **Then every six months**, up to five years in most states.
- **Where:** the government health centre or anganwadi, and often on Child Health or Vitamin A days in your area. Many private clinics don't give it, so ask.
- **Don't give extra at home.** Vitamin A in large amounts is harmful. Only the programme dose, or what your doctor prescribes.
- **Write it on the vaccination card**, or in the app's health record, so the next one isn't missed.

**WhenLine.** It has been more than six months since the last dose and he is under five? Ask at the next health-centre visit.

**IndiaNote.** Night blindness (not seeing well at dusk) and dry, wrinkled whites of the eyes were once common signs of low Vitamin A in India. They are rarer now because of these doses, so keep going.

**Doctor callout:** See an eye doctor or paediatrician if your child struggles to see in dim light, or the white of the eye looks dry or has grey patches. REQUIRED_REVIEW

**Link:** Vaccines, and what is due next (tool `pp_vaccines`).

---

## 7. `prev_heat`: "Summer heat, and heat stroke"
Area `prevention` · ARTICLE · bands all · seasonal lift April to June via the existing signals
Consult: none (emergency content inside) · Products: sun hat, mineral sunscreen 6m+ (owed), at the foot

**Intro.** Babies and young children heat up faster than adults and can't tell you they're too hot. Indian summers, power cuts and parked cars make heat a real risk. Most of it is prevented with water, shade, and timing.

**Article.**
1. Children lose water fast in the heat: through sweat, faster breathing, and more wees and loose stools if a tummy bug comes along. Offer drinks before he asks. A breastfed baby under six months needs more feeds, not water. From six months, add small sips of water. REQUIRED_REVIEW
2. Keep outdoor time to the morning and evening. Avoid roughly 11 to 4 in peak summer. Dress him in loose, light cotton, use a hat with a brim, and keep him in the shade. For babies under six months, shade and clothing come before any sunscreen.
3. **Never leave a child in a parked car, even for a minute, even with the windows down.** A closed car heats up dangerously within minutes. REQUIRED_REVIEW
4. Don't cover the pram with a cloth for shade. It traps heat inside. Use the hood and keep air moving.

**Cards, heading "Heat exhaustion: cool him down now":**
- **Signs**: very thirsty, tired and cranky, a headache, sweating a lot, cool clammy skin, fewer wees.
- **Do**: move him to shade or a cool room, take off extra clothes, give sips of ORS or water, and sponge with room-temperature water.
- **Then**: he should perk up within an hour. If not, see a doctor today.

**Cards, heading "Heat stroke: this is an emergency":** REQUIRED_REVIEW
- **Signs**: hot, red, *dry* skin, a very high temperature, confusion, unusual sleepiness, vomiting, a fit, or not responding properly.
- **Do**: call 112 or go to hospital now. On the way, cool him with wet cloths and a fan. Give no drinks if he is drowsy.

**WhenLine.** On a heat-wave day: indoor play from late morning to late afternoon, and a drink offered every half hour when he is outside.

**IndiaNote.** Aam panna, nimbu pani with a pinch of salt, buttermilk and coconut water are good summer drinks for a child over one. Go light on sugar. Packaged "energy" and soft drinks are not for children.

**Doctor callout:** Any sign of heat stroke is an emergency (112). See a doctor the same day if heat exhaustion doesn't improve within an hour, or a baby under six months seems unwell in the heat. REQUIRED_REVIEW

**Links:** Go to a hospital now · Is he drinking enough? (`tummy_dehydration`).

---

## 8. `ill_bites`: "Dog, monkey, cat, snake or scorpion bites"
Area `emergency` · STEPS · bands all · in the Get help now rail after `health_accidents`
**No pitch, no product** (a go-now page). REQUIRED_REVIEW on every line.

**Intro.** Any bite or scratch from a dog, cat or monkey needs the rabies vaccine the same day, even a small one, and even if the animal looks healthy. Rabies has no cure once it starts. The vaccine works completely when it's given in time.

**Steps, heading "A dog, cat or monkey bite or scratch":**
1. **Wash the wound right away with soap and running water, for fifteen minutes.** This is the most important thing you can do at home. REQUIRED_REVIEW
2. Apply an antiseptic if you have one. **Don't cover it tightly, and don't apply chilli, turmeric, oil, lime or anything else.**
3. **Go to a hospital the same day, even at night.** The doctor decides on the rabies vaccine and, for deeper bites, rabies immunoglobulin, and a tetanus shot.
4. **Government hospitals give the anti-rabies vaccine free** under the National Rabies Control Programme. You don't have to wait for a private clinic. REQUIRED_REVIEW (confirm local availability and the regimen at review)
5. **Finish every dose on the dates you are given.** Missing one leaves him unprotected.

**Callout.** A lick on broken skin, or a scratch from a monkey, also counts. Children often hide a bite because they're afraid of being scolded or of injections. Ask gently after any play with stray animals.

**Steps, heading "A snake bite":** REQUIRED_REVIEW
1. **Keep him still and calm**, and lay him down. Movement spreads venom.
2. Take off rings, bangles and anklets near the bite before swelling starts.
3. **Go to a hospital with anti-snake venom straight away.** Call 108 or 112.
4. **Don't tie a tight band, don't cut the wound, don't suck it, and don't go to a faith healer first.** These lose the hours that matter.

**Steps, heading "A scorpion sting":** REQUIRED_REVIEW
1. Wash, and a cold cloth for the pain.
2. **Go to hospital now for a child.** Scorpion stings are more dangerous in small children: sweating, vomiting, a fast heartbeat or breathlessness can follow within hours.

**IndiaNote.** India has more rabies deaths than any other country, and children are bitten most. Teach children not to touch or feed street dogs, monkeys or puppies, and to tell you about any scratch, without fear of getting into trouble. REQUIRED_REVIEW

**Doctor callout, title "Always hospital, same day":** any bite or scratch that broke skin from a dog, cat or monkey; any snake bite; any scorpion sting in a child.

**Links:** Go to a hospital now · Emergency card (tool).

---

## 9. `ill_insect_bites`: "Mosquito and insect bites"
Area `skin` · ARTICLE · bands all · after `skin_heat_rash`
Consult: Child dermatologist · Product: mosquito net (owed)

**Intro.** Most bites are itchy and annoying, not dangerous. Some children react to bites with crops of hard, itchy bumps that last for weeks. The goal is fewer bites, less scratching, and spotting the rare bite that is infected or an allergy.

**Article.**
1. A normal bite makes a small, itchy bump that fades in a few days. In some young children, bites from mosquitoes, fleas or bedbugs cause **papular urticaria**: groups of firm, very itchy bumps, often on the legs and arms, that keep coming back through the season. It isn't an infection, and it isn't contagious. It eases as the child grows. REQUIRED_REVIEW
2. Scratching is the real problem, because it breaks the skin and lets infection in. Keep nails short, use a cool damp cloth on the bump, and ask your doctor about a soothing cream or an anti-itch medicine for night-time.
3. An infected bite gets redder, hotter and more painful over days, may ooze yellow, and can come with fever. That needs a doctor.

**Cards, heading "Fewer bites":**
- **Nets** over the cot and pram, day and night.
- **Long, light sleeves and pants** at dawn and dusk.
- **Repellents made for children**: ask your doctor before any repellent under two months. For older babies and children, follow the label's age limit, put it on clothes more than skin, and never on hands that go to the mouth. REQUIRED_REVIEW
- **Check bedding** for bedbugs if bites appear in lines every morning.

**WhenLine.** Itchy bumps that keep coming back all monsoon: a skin doctor can confirm papular urticaria and help with the itch.

**IndiaNote.** Coils, liquid vaporisers and smoke inside a closed room are hard on small lungs. Use them only in a room that is aired out, or not at all where a baby sleeps.

**Doctor callout:** **Swelling of the lips, face or tongue, or wheezing after a bite or sting, means 112 now** (an allergic reaction). See a doctor today for a bite that is spreading red, hot and painful, or comes with a fever. REQUIRED_REVIEW

**Consult:** Child dermatologist · whoFor: "If the bumps keep coming back, or the itch keeps him up at night."

---

## 10. `nb_boys_girls`: "Down there: what's normal for boys and girls"
Area `newborn_checks` · CARDS · bands N I
Consult: Paediatrician · Product: none

**Intro.** Parents often notice something in the nappy area and feel shy asking. Your paediatrician has seen it all. Here is what's common, what to leave alone, and what to show the doctor.

**Cards, heading "Boys":** REQUIRED_REVIEW
- **Don't pull back the foreskin.** In babies it is meant to be stuck to the tip. It loosens on its own over years. Forcing it hurts and can scar. Just wash the outside.
- **A testicle that isn't in the scrotum** (undescended testis): the doctor checks at birth and at the early visits. If it hasn't come down by about six months, it needs a specialist, because waiting longer can affect fertility later.
- **A soft swelling in the scrotum** that may look bluish is often fluid (a hydrocele). Many settle by one year. Your doctor watches it.
- **A bulge in the groin** that comes and goes, especially with crying, may be a hernia. Show your doctor soon.

**Cards, heading "Girls":**
- **A little white discharge, or even a few drops of blood**, in the first weeks is from your hormones in pregnancy. It passes.
- **Lips of the vagina stuck together** (labial adhesion) is common in babies and toddlers and usually harmless. Don't try to separate them; show your doctor.
- **Wipe front to back** at every change.

**Callout.** If a hernia bulge becomes hard, painful or red and won't go back in, and your baby is vomiting or crying non-stop, that is an emergency. Go to hospital now. REQUIRED_REVIEW

**WhenLine.** Bring any of these to the 6-week check, unless there's pain, redness or vomiting. Then go the same day.

**IndiaNote.** Don't apply oil, kajal or ash to the cord area or the genitals, and don't massage a swelling to make it go back. Gentle washing with plain water is all the care this area needs.

**Doctor callout:** See your doctor if a testicle can't be felt, a swelling grows or hurts, he cries while passing urine or the stream is very thin, or there is redness or discharge. REQUIRED_REVIEW

**Consult:** Paediatrician · whoFor: "If you'd like a doctor to look at something before the next check-up."

---

## 11. `ill_nosebleed`: "Nosebleeds"
Area `other_illness` · STEPS · bands T C
No consult (the steps are home care; the doctor line carries the rest). Product: none.

**Intro.** Nosebleeds are common in children, especially in dry weather, with a cold, or after a finger in the nose. They look worse than they are, and almost all stop with the right pinch.

**Steps, heading "Stop a nosebleed":** REQUIRED_REVIEW
1. Sit him up and **lean him slightly forward**, not back.
2. **Pinch the soft part of the nose** (below the bony bridge) firmly, for **ten minutes by the clock**, without letting go to check.
3. Let him breathe through his mouth and spit any blood into a bowl. Swallowed blood makes children sick.
4. A cold cloth on the bridge of the nose can help.
5. Afterwards, no nose-blowing or picking for a day.

**Callout.** Leaning back, or lying flat, sends blood down the throat. That's the most common mistake, and many people still learn it.

**Cards, heading "Fewer nosebleeds":**
- A little petroleum jelly inside the nostrils at bedtime in dry seasons.
- Short nails, and a gentle word about picking.
- Saline drops when the nose is crusty from a cold.

**WhenLine.** More than one nosebleed a week for a few weeks: mention it at the next visit.

**IndiaNote.** Holding his arms up, or putting cold water on his head, doesn't stop a nosebleed. The pinch does.

**Doctor callout:** Go to hospital if bleeding doesn't stop after twenty minutes of pinching, it followed a hard fall or a blow to the head, he is pale and dizzy, or something may be stuck in the nose. See your doctor if nosebleeds are frequent, or he also bruises easily or bleeds from the gums. REQUIRED_REVIEW

---

## 12. `ill_head_bump`: "A bump on the head, a fall"
Area `emergency` · STEPS · bands all · in the Get help now rail after `health_accidents`
**No pitch** (go-now family). REQUIRED_REVIEW on every line.

**Intro.** Babies roll off beds, toddlers fall down stairs, and big children fall off swings. Most head bumps cause a lump and tears and nothing more. A few need a scan. The signs below tell you which.

**Steps, heading "Right after the fall":**
1. **Comfort him and look at him.** A child who cries straight away, then settles and plays, is a good sign.
2. **A cold cloth on the bump** for ten minutes eases the swelling. A big lump on the forehead is common and on its own is not a danger sign.
3. **Watch him closely for the next 24 hours.** He can sleep, but wake him the way you normally would, to check he wakes properly and knows you. REQUIRED_REVIEW
4. Paracetamol for pain only, at the dose your doctor or the label gives by weight.

**Cards, heading "Go to hospital now if":** REQUIRED_REVIEW
- **He was knocked out**, even for a moment.
- **He is vomiting more than once**, or keeps vomiting.
- **He is unusually sleepy, hard to wake, confused or not himself.**
- **A fit.**
- **Clear fluid or blood from the nose or ears.**
- **He fell from more than his own height**, or down stairs, or **he is under one year with any swelling on the side or back of the head.**
- **He can't walk, talk or use an arm or leg the way he normally does.**
- **You're worried.** That alone is reason enough.

**IndiaNote.** Babies roll earlier than parents expect. A baby on a raised bed or a sofa needs a hand on him, or the floor. Never leave him on a bed with pillows "as a wall". REQUIRED_REVIEW

**Doctor callout, title "Even if he seems fine":** a baby under three months who has fallen should be seen the same day.

**Links:** Go to a hospital now · Falls and accidents (`health_accidents`) · Safety door (`pp_section/parenting_safety`).

---

## 13. `vax_uwin`: "U-WIN: his vaccines, on the government record"
Area `vaccines` · STEPS · bands all · after `vax_catch_up`
No consult · Product: none

**Intro.** Every vaccine given at a government centre, and at many private ones, is recorded on U-WIN, the government's digital vaccination record. It sends reminders and gives you a certificate with a QR code. That's useful for school, travel and moving cities.

**Steps, heading "Getting his record":** REQUIRED_REVIEW (confirm the current portal steps and age scope: sources differ on 0 to 5 versus 0 to 17 years)
1. Visit the U-WIN portal or app and **sign in with the mobile number** you gave at the hospital or vaccination centre.
2. Your child's record appears with each dose, its date and where it was given. If the birth doses are missing, ask the centre where they were given to add them.
3. **Download the certificate.** It can also link to an ABHA health ID (see `rec_abha`).
4. Book the next dose at a nearby centre, and turn on the SMS reminders.

**Callout.** U-WIN and this app's vaccine tracker do the same job in two places. The app's tracker works offline and holds private-clinic doses U-WIN may miss. Keep both, and treat the card from your doctor as the final word if they ever disagree. REQUIRED_REVIEW

**Cards, heading "Behind on a dose?":**
- **Mission Indradhanush** runs catch-up drives for children who missed doses. Your ASHA or anganwadi knows the dates.
- **A missed dose is not a restart.** Most schedules just continue. See `vax_catch_up`.

**WhenLine.** Check his U-WIN record against his card once a year, and before school admission.

**IndiaNote.** Government centres give the vaccines in the national schedule free. Private clinics may add others from the IAP schedule; see `vax_cost`.

**Links:** Vaccines tool (`pp_vaccines`) · Catching up (`vax_catch_up`) · What vaccines cost (`vax_cost`) · ABHA (`rec_abha`).

---

## 14. `rec_abha`: "ABHA, and the papers to keep"
Area `records` · CARDS · bands all · after `rec_checkups_by_age`
No consult · Product: health record folder (owed), at the foot

**Intro.** An ABHA is a free health ID number for your child. It lets hospitals and labs add his records to one place you control. You don't need it to get care. It just makes the next visit easier.

**Cards, heading "ABHA, simply":** REQUIRED_REVIEW (confirm the current steps on abdm.gov.in)
- **What it is**: a 14-digit health ID under the Ayushman Bharat Digital Mission. A child's can be made by a parent.
- **What it does**: hospitals, labs and U-WIN can link reports to it, *with your consent each time*.
- **How**: through the ABHA app or website, or at a hospital or vaccination centre. Children's IDs are usually linked to a parent's mobile and Aadhaar.
- **Privacy**: you choose who sees what, and can stop sharing.

**Cards, heading "The papers that matter, in one folder":**
- **Birth certificate** (see the Papers and money door).
- **Vaccination card**, plus the U-WIN certificate.
- **Discharge summaries** from any hospital stay, including birth.
- **The newborn screening results** and the hearing test.
- **Prescriptions and test reports**, newest on top.
- **Allergy list and blood group**, also on the app's emergency card.

**WhenLine.** After any hospital visit, photograph the discharge summary into the app's health record the same day.

**IndiaNote.** A doctor in another city, or a school, will ask for the vaccination record and birth certificate more than anything else. Keep scans on the phone and the originals in one plastic folder.

**Links:** Health record and papers (tool `pp_health_home`) · Emergency card (tool) · U-WIN (`vax_uwin`) · Papers and money door.

---

## 15. `prev_medicine_box`: "The home medicine box"
Area `medicines` · CARDS · bands all · first page on the Medicines tab
Consult: none · Product: **Baby First-Aid Kit** (`pp_products_data.dart:787`) and the oral dosing syringe set (owed). These are the only shelf on the tab, and equipment only (H4).

**Intro.** A small, well-kept medicine box saves a late-night run to the chemist and stops the wrong bottle being grabbed in a hurry. Here's what to keep, written by kind, not by brand. **The dose always comes from your doctor or the label, by your child's weight.**

**Cards, heading "Keep these":** REQUIRED_REVIEW
- **A digital thermometer** (underarm; see `fever_reading`).
- **Paracetamol for children**, in the form and strength your doctor names, with its own syringe.
- **ORS sachets** (WHO formula), and zinc if your doctor has prescribed it for loose motions.
- **Saline nose drops.**
- **A barrier cream** for nappy rash.
- **Antiseptic, cotton, gauze, a roll bandage and small plasters.**
- **An oral syringe** (not a kitchen spoon).
- **The doctor's number and the nearest children's emergency**, on the lid. The app's emergency card holds them too.

**Cards, heading "Don't keep these for a child":** REQUIRED_REVIEW
- **Cough and cold syrups** for under two (see `cough_syrups`).
- **Aspirin** for any child.
- **Leftover antibiotics.** Never finish an old course on a new illness.
- **Adult medicines "cut in half".**
- **Anything with a smudged label** or past its date.

**Cards, heading "Keep it safe":**
- **High and locked.** Iron syrups and paracetamol are the most common serious poisonings in young children.
- **Check dates twice a year.** The Deworming Days in February and August are a good reminder.
- **Travelling?** Pack a small copy, plus his prescriptions.

**Callout.** If he swallows any medicine that wasn't meant for him, even if he seems fine, call your doctor or go to hospital now, and take the bottle with you. REQUIRED_REVIEW

**IndiaNote.** Chemists in India often sell medicines without a prescription and will suggest one "for children". Ask them to check it with your doctor's slip, and never accept a dose by guess.

**Links:** Giving medicine (`prev_medicine`) · Fever dosing (`fever_dosing`) · Cough syrups (`cough_syrups`) · Emergency card (tool).

---

## Where each page lands (for the build)

| Page | Area | Format | Bands | Age rail |
|---|---|---|---|---|
| ill_dengue | other_illness | ARTICLE | all | |
| ill_febrile_seizure | emergency | STEPS | I T C | hb_infant |
| ill_throat | other_illness | ARTICLE | T C | hb_child (lead) |
| ill_worms | tummy | ARTICLE | T C | hb_child |
| ill_anaemia | growth | ARTICLE | I T C | |
| prev_vitamin_a | prevention | CARDS | I T C | |
| prev_heat | prevention | ARTICLE | all | |
| ill_bites | emergency | STEPS | all | |
| ill_insect_bites | skin | ARTICLE | all | |
| nb_boys_girls | newborn_checks | CARDS | N I | |
| ill_nosebleed | other_illness | STEPS | T C | |
| ill_head_bump | emergency | STEPS | all | |
| vax_uwin | vaccines | STEPS | all | |
| rec_abha | records | CARDS | all | |
| prev_medicine_box | medicines | CARDS | all | |

Ask Veda: new pages reach the service through the existing incremental ingest after the build (the user runs it). No wire change is needed.

## Sources (secondary sources are marked; every fact is REQUIRED_REVIEW against the current MoHFW and IAP guidance)
- Deworming: [Drishti IAS](https://drishtiias.com/pdf/1581412634-national-deworming-day.pdf), [Krishnagiri district NDD page](https://krishnagiri.nic.in/scheme/national-deworming-day/)
- Anemia Mukt Bharat iron syrup, 6 to 59 months, twice a week: [Vikaspedia (secondary)](https://en.vikaspedia.in/viewcontent/health/health-campaigns/anemia-mukt-bharat), [GHSP journal table](https://www.ghspjournal.org/content/13/2/e2400077/tab-figures-tables)
- Vitamin A, 9 months then every 6 months: [NHM Goa, micronutrient supplementation](https://nhm.goa.gov.in/micronutrient-supplementation/), [PMC review](https://pmc.ncbi.nlm.nih.gov/articles/PMC4340548), [Lok Sabha answer (older regimen)](https://eparlib.sansad.in/bitstream/123456789/528043/1/28556.pdf)
- Dengue (no NSAIDs, the critical phase as the fever falls, fluids): [NHM Himachal Pradesh dengue guidelines](https://nhm.hp.gov.in/storage/app/media/uploaded-files/Guidelines_Dengue.pdf) (the IAP guideline itself is still to fetch)
- U-WIN: [PIB](https://static.pib.gov.in/WriteReadData/specificdocs/documents/2024/nov/doc2024119432301.pdf), [MoHFW press release](https://mohfw.gov.in/press-info/7848)
- Rabies PEP free under NRCP: [NHM Himachal Pradesh](https://nhm.hp.gov.in/nrcp)
