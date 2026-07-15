// =============================================================================
//  Read Next ❤️ - curated, week-aware content (prototype)
// -----------------------------------------------------------------------------
//  A small, curated set across articles, research summaries, books and expert
//  picks. Each item is tagged with the week window where it is relevant, so the
//  engine can surface "the right thing right now" for the mother's stage.
// =============================================================================

import '../models/read_item.dart';

const List<ReadItem> kReadItems = [
  // ---- Articles ----
  ReadItem(
    id: 'managing_nausea',
    whyThisMatters:
        'Nausea can quietly wear you down and make eating feel impossible. Knowing it is common, usually harmless, and manageable protects both your comfort and your baby\'s steady nourishment through these early weeks.',
    researchSimplified:
        'Morning sickness is linked to the rapid rise of pregnancy hormones like hCG. Studies consistently find ginger and vitamin B6 ease mild-to-moderate nausea. It typically peaks around weeks 9–11 and settles by the second trimester for most mothers.',
    myth: 'Morning sickness only happens in the morning.',
    fact:
        'It can strike at any time of day or night - many mothers feel most queasy in the evening. The name is simply misleading.',
    title: 'Managing Morning Sickness',
    type: ReadType.article,
    weekStart: 5,
    weekEnd: 14,
    priority: 'high',
    reason: 'Nausea is common in the first trimester - small, gentle changes help.',
    readingTime: '4 min',
    category: 'Mother Changes',
    emoji: '🤢',
    body:
        'Morning sickness affects many mothers in the first trimester, and despite the name it can strike at any time of day.\n\n'
        'Small, frequent meals keep your stomach from getting empty, which often makes nausea worse. Dry foods like toast or crackers before getting out of bed can help. Ginger - in tea, or a little ginger-honey water - is one of the better-studied natural settlers.\n\n'
        'Stay hydrated in small sips, and rest when you can. For most mothers this eases by the second trimester. If you cannot keep fluids down, tell your doctor - there is safe, effective help available.',
  ),
  ReadItem(
    id: 'first_scan',
    whyThisMatters:
        'This scan turns an abstract idea into a real, beating heartbeat - and confirms your due date, which shapes every milestone ahead. Knowing what happens removes the nervousness of the unknown.',
    researchSimplified:
        'An early dating scan measures the baby crown-to-rump. Before about 13 weeks this size predicts gestational age more accurately than the date of your last period, which is why your due date may be gently adjusted.',
    title: 'Your First Scan, Explained',
    type: ReadType.article,
    weekStart: 7,
    weekEnd: 13,
    priority: 'medium',
    reason: 'Your early dating scan is around now - here is what to expect.',
    readingTime: '3 min',
    category: 'Preparation',
    emoji: '🩻',
    body:
        'The first scan, often called the dating scan, confirms your due date and checks the early heartbeat.\n\n'
        'You may be asked to come with a comfortably full bladder, which helps the image. The scan is painless. Many parents find hearing or seeing the heartbeat a deeply moving first moment.\n\n'
        'Write down any questions beforehand, and remember it is perfectly normal to feel both excited and nervous.',
  ),
  ReadItem(
    id: 'first_trimester',
    whyThisMatters:
        'So much of the first trimester is invisible, which can make the exhaustion and worry feel unearned. Understanding the enormous work happening inside lets you rest without guilt.',
    researchSimplified:
        'By the end of the first trimester all major organs have begun forming and the heart is beating. This is also when the risk of miscarriage falls sharply, which is why many families wait until around 12 weeks to share their news.',
    title: 'Understanding the First Trimester',
    type: ReadType.article,
    weekStart: 4,
    weekEnd: 13,
    priority: 'medium',
    reason: 'So much is happening quietly in these early weeks.',
    readingTime: '5 min',
    category: 'Baby Development',
    emoji: '🌱',
    body:
        'The first trimester is a time of enormous, mostly invisible change. Your baby grows from a tiny cluster of cells to a recognisable form with a beating heart.\n\n'
        'You may feel tired, queasy or emotional - your body is doing remarkable work. Rest is not laziness; it is part of the process. Be gentle with yourself, and know that energy often returns in the second trimester.',
  ),
  ReadItem(
    id: 'halfway',
    whyThisMatters:
        'The halfway mark is a natural moment to pause, celebrate, and gently shift from surviving early symptoms to preparing. First kicks also begin a two-way bond.',
    researchSimplified:
        'Around week 20 the baby\'s hearing is developing and the detailed anomaly scan checks anatomy. Feeling movement (quickening) typically begins between weeks 18–24, often earlier in second pregnancies.',
    myth: 'You should be "eating for two" by now.',
    fact:
        'Most mothers need only about 300 extra calories a day in the second trimester - roughly a glass of milk and a fruit. Quality matters far more than quantity.',
    title: 'You Are Halfway - What Changes Now',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: 'Around week 20 you reach the halfway point of your journey.',
    readingTime: '4 min',
    category: 'Mother Changes',
    emoji: '🌗',
    body:
        'Reaching the halfway mark is a real milestone. Many mothers feel more energetic now, the bump becomes visible, and the first kicks often arrive.\n\n'
        'This is a lovely window to connect - talk or sing to your baby, who is beginning to hear sounds. It is also a practical time to start thinking gently about the months ahead, without rushing.',
  ),
  ReadItem(
    id: 'anomaly_scan',
    whyThisMatters:
        'This is the most detailed look at your baby\'s development you will get. Knowing what is checked - and that most findings are reassuring - helps you go in calm rather than anxious.',
    researchSimplified:
        'The mid-pregnancy anatomy scan (weeks 18–22) systematically checks the brain, heart, spine, kidneys, limbs and the placenta\'s position. It can detect many structural conditions early enough to plan care.',
    title: 'Making the Most of the Anomaly Scan',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: 'The detailed anatomy scan usually happens around weeks 18–22.',
    readingTime: '4 min',
    category: 'Preparation',
    emoji: '🔍',
    body:
        'The anomaly scan is a detailed look at how your baby is developing - the heart, brain, spine, limbs and organs.\n\n'
        'It takes longer than earlier scans. You can usually bring your partner. It is okay to ask the sonographer to explain what they are measuring. If anything needs a closer look, your doctor will guide the next steps calmly - most findings are reassuring.',
  ),
  ReadItem(
    id: 'baby_sound',
    whyThisMatters:
        'Your voice is your baby\'s first familiar comfort. A few quiet minutes of talking or singing each day genuinely begins the bond that continues after birth.',
    researchSimplified:
        'The inner ear and hearing pathways mature around weeks 18–25. Studies show newborns prefer their mother\'s voice, and can even recognise songs or stories heard repeatedly in the womb.',
    title: 'How Babies Begin Responding to Sound',
    type: ReadType.article,
    weekStart: 20,
    weekEnd: 28,
    priority: 'high',
    reason: 'Your baby is becoming increasingly responsive to sounds during this stage.',
    readingTime: '5 min',
    category: 'Baby Development',
    emoji: '🎵',
    body:
        'Around the middle of pregnancy, your baby\'s hearing develops quickly. They begin to pick up sounds - your heartbeat, your voice, and music from the world outside.\n\n'
        'This is why talking, reading or singing to your bump is more than sweet ritual: your baby is genuinely starting to recognise the rhythm and tone of familiar voices. A few quiet minutes each day is a beautiful way to begin your bond.',
  ),
  ReadItem(
    id: 'talking_baby',
    whyThisMatters:
        'You don\'t need a script or a special time - simply sharing your day lowers your own stress and lays the first thread of connection your baby will recognise at birth.',
    researchSimplified:
        'Research on prenatal bonding links talking and reading aloud to lower maternal stress hormones, and to newborns\' clear preference for familiar voices soon after birth.',
    title: 'Talking to Your Baby Before Birth',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 40,
    priority: 'medium',
    reason: 'Your voice is becoming familiar to your baby.',
    readingTime: '3 min',
    category: 'Emotional Wellbeing',
    emoji: '💬',
    body:
        'You do not need a script. Tell your baby about your day, describe the people who cannot wait to meet them, or simply share what you are feeling.\n\n'
        'These small moments lower your own stress and begin a connection that continues after birth, when your familiar voice becomes an instant comfort.',
  ),
  ReadItem(
    id: 'back_pain',
    whyThisMatters:
        'Back comfort shapes your sleep, mood and mobility. Small posture habits now stop the discomfort from taking over your day as the bump grows.',
    researchSimplified:
        'The hormone relaxin loosens your ligaments and the growing uterus shifts your centre of gravity, straining the lower back. Trials find gentle prenatal exercise and physiotherapy reduce pregnancy back pain safely.',
    title: 'Easing Back Pain in Pregnancy',
    type: ReadType.article,
    weekStart: 20,
    weekEnd: 36,
    priority: 'medium',
    reason: 'As the bump grows, back comfort becomes more important.',
    readingTime: '3 min',
    category: 'Mother Changes',
    emoji: '🧘',
    body:
        'A growing bump shifts your posture and can strain your lower back. Gentle prenatal yoga, a supportive pillow, warm (not hot) compresses, and being mindful of how you sit and lift all help.\n\n'
        'Avoid standing for very long stretches, and bend at the knees. If pain is severe or sudden, mention it to your doctor.',
  ),
  ReadItem(
    id: 'nutrition_t2',
    whyThisMatters:
        'With nausea easing, this is the window to build the iron, calcium and protein stores your baby draws on for rapid growth - nourishing you both.',
    researchSimplified:
        'Iron needs rise sharply in the second trimester to support the baby\'s blood supply, and adequate calcium protects your own bones. Balanced meals plus prescribed supplements meet these needs.',
    myth: 'You need to eat twice as much now.',
    fact:
        'Quality outweighs quantity. A modest ~300 extra calories of nutrient-dense food supports your baby better than simply eating more.',
    title: 'Eating Well in the Second Trimester',
    type: ReadType.article,
    weekStart: 14,
    weekEnd: 27,
    priority: 'medium',
    reason: 'Your appetite often returns now - a good time to nourish well.',
    readingTime: '4 min',
    category: 'Nutrition',
    emoji: '🥗',
    body:
        'With nausea easing, the second trimester is a great time to focus on balanced, nourishing meals - iron-rich greens and dal, calcium from dairy, fruit, and steady hydration.\n\n'
        'You do not need to eat for two; quality matters more than quantity. Keep taking your prescribed supplements, and enjoy your food.',
  ),
  ReadItem(
    id: 'third_tri_prep',
    whyThisMatters:
        'A gentle heads-up lets you pace preparation calmly, rather than scrambling when energy dips and the bump slows you down.',
    researchSimplified:
        'In the third trimester the baby gains most of its birth weight and the lungs and brain mature rapidly. Growth scans and, if needed, birth planning usually begin around this stage.',
    title: 'Getting Ready for the Third Trimester',
    type: ReadType.article,
    weekStart: 24,
    weekEnd: 30,
    priority: 'medium',
    reason: 'The third trimester is coming up - a gentle heads-up helps.',
    readingTime: '4 min',
    category: 'Preparation',
    emoji: '🗓️',
    body:
        'The third trimester brings a bigger bump, more movement, and the first thoughts of birth. Energy can dip again, and rest becomes important.\n\n'
        'There is no need to rush - but knowing what is ahead, from growth scans to birth planning, helps you feel calm and prepared.',
  ),
  ReadItem(
    id: 'movement_awareness',
    whyThisMatters:
        'Getting to know your baby\'s normal movement pattern now is the foundation for one of the simplest, most powerful ways to check on their wellbeing later.',
    researchSimplified:
        'There is no fixed "normal" number of kicks - what matters is your baby\'s individual pattern. Guidance advises getting to know it and reporting any clear reduction, rather than counting to a set target.',
    title: 'Preparing for Baby Movement Awareness',
    type: ReadType.article,
    weekStart: 24,
    weekEnd: 30,
    priority: 'medium',
    reason: 'Tracking your baby\'s movements becomes important soon.',
    readingTime: '3 min',
    category: 'Baby Development',
    emoji: '👣',
    body:
        'As you move through pregnancy, you will get to know your baby\'s unique pattern of movement. Later on, noticing changes in that pattern becomes an important way to check on their wellbeing.\n\n'
        'For now, simply enjoy getting familiar with when and how your baby likes to move.',
  ),
  ReadItem(
    id: 'partner_support',
    whyThisMatters:
        'Feeling supported measurably lowers stress and lifts wellbeing for both you and your baby. Sharing this helps your partner know exactly how to help.',
    researchSimplified:
        'Studies consistently link strong partner support in pregnancy with lower maternal stress, better mental health, and improved birth outcomes.',
    title: 'How Your Partner Can Support You Now',
    type: ReadType.article,
    weekStart: 12,
    weekEnd: 40,
    priority: 'medium',
    reason: 'Support makes the journey lighter - share this with your partner.',
    readingTime: '3 min',
    category: 'Partner Support',
    emoji: '🤝',
    body:
        'Partners often want to help but are not sure how. Small, specific acts matter most: coming to scans, taking a task off your plate, listening without trying to fix, and learning alongside you.\n\n'
        'Becoming a parent is a shared journey - and feeling supported is good for both you and your baby.',
  ),
  ReadItem(
    id: 'hospital_bag',
    whyThisMatters:
        'Packing early trades last-minute panic for calm. When labour begins, everything you and your baby need is simply ready to go.',
    researchSimplified:
        'Labour can begin any time from around week 37 (full term). Having essentials ready by then is why antenatal guidance suggests packing in the mid-third trimester.',
    title: 'Preparing Your Hospital Bag',
    type: ReadType.article,
    weekStart: 32,
    weekEnd: 40,
    priority: 'high',
    reason: 'You are entering the final weeks before delivery.',
    readingTime: '4 min',
    category: 'Preparation',
    emoji: '🧳',
    body:
        'Packing your bag a few weeks early brings real peace of mind. Think in three parts: things for labour, things for after delivery, and things for your baby.\n\n'
        'ParentVeda\'s Hospital Bag planner can build the full checklist for you - this is a good time to start it.',
  ),
  ReadItem(
    id: 'labour_prep',
    whyThisMatters:
        'Fear of the unknown makes labour harder. Understanding the stages replaces dread with confidence, so you know what is happening and when to head in.',
    researchSimplified:
        'Labour unfolds in three stages - dilation, delivery of the baby, and delivery of the placenta. Evidence links continuous support and understanding of the process with calmer, more positive birth experiences.',
    title: 'Labour, Step by Step',
    type: ReadType.article,
    weekStart: 34,
    weekEnd: 40,
    priority: 'medium',
    reason: 'Knowing the stages of labour helps you feel calmer.',
    readingTime: '6 min',
    category: 'Preparation',
    emoji: '🌅',
    body:
        'Labour usually unfolds in stages, often more gradually than films suggest. Understanding early signs, when to head in, and what each stage feels like can replace fear with confidence.\n\n'
        'Your birth plan is a guide, not a rulebook - staying flexible and trusting your care team matters most.',
  ),
  ReadItem(
    id: 'first_24h',
    whyThisMatters:
        'Knowing the first day is a blur of sleepy firsts sets gentle expectations, so you can rest and bond rather than worry that something is wrong.',
    researchSimplified:
        'Immediate skin-to-skin contact and early feeding support bonding, temperature regulation and breastfeeding. Newborns are often very sleepy in the first 24 hours, which is entirely normal.',
    title: 'The First 24 Hours After Birth',
    type: ReadType.article,
    weekStart: 36,
    weekEnd: 40,
    priority: 'medium',
    reason: 'A gentle picture of what the first day with your baby looks like.',
    readingTime: '5 min',
    category: 'Preparation',
    emoji: '👶',
    body:
        'The first day is a blur of firsts - skin-to-skin, the first feed, tiny checks by the team. Your baby may be sleepy, and that is normal.\n\n'
        'Rest whenever you can, accept help, and know that you and your baby are learning each other. There is no need to have everything figured out at once.',
  ),

  // ---- Research summaries ----
  ReadItem(
    id: 'res_voices',
    whyThisMatters:
        'It is a lovely, evidence-backed reason to talk and read aloud now - you are already building a comfort your newborn will reach for.',
    researchSimplified:
        'In the final months, babies can hear and begin recognising frequently-heard voices - especially the mother\'s. After birth, newborns turn toward and are soothed by these familiar voices.',
    title: 'Babies Recognise Familiar Voices Before Birth',
    type: ReadType.research,
    weekStart: 20,
    weekEnd: 32,
    priority: 'high',
    reason: 'Your baby is increasingly able to hear sounds around this stage.',
    readingTime: '2 min',
    category: 'Baby Development',
    emoji: '🔬',
    body:
        'Research suggests that in the later months, babies begin to recognise voices and sounds they hear often - especially their mother\'s.\n\n'
        'After birth, newborns tend to turn toward familiar voices and can be soothed by them. It is a lovely reason to talk and read aloud now.',
  ),
  ReadItem(
    id: 'res_music',
    whyThisMatters:
        'It frees you from any pressure to find a "brain-boosting" playlist. What helps your baby is simply what helps you relax.',
    researchSimplified:
        'Reviews of music in pregnancy find the main benefit is maternal relaxation, which the baby shares. There is no evidence that any particular music makes babies smarter.',
    myth: 'Playing classical music to your bump makes your baby smarter.',
    fact:
        'There is no good evidence for a "Mozart effect" in the womb. The real benefit is that calming music relaxes you, and that calm is shared with your baby.',
    title: 'What Research Says About Music and the Womb',
    type: ReadType.research,
    weekStart: 18,
    weekEnd: 36,
    priority: 'medium',
    reason: 'Gentle sound and music can be calming for you and your baby.',
    readingTime: '3 min',
    category: 'Baby Development',
    emoji: '🎶',
    body:
        'Studies on music in pregnancy point to a simple, reassuring idea: calm, gentle sound is soothing - mostly because it helps the mother relax, and that calm is shared.\n\n'
        'There is no magic playlist that makes babies smarter. Choose what relaxes you.',
  ),
  ReadItem(
    id: 'res_stress',
    whyThisMatters:
        'You do not need to be perfectly serene - but small, repeated calming habits genuinely support both your wellbeing and your baby\'s.',
    researchSimplified:
        'Occasional stress is normal and harmless. Research links only high, sustained stress with pregnancy risks, and finds simple habits - rest, breathing, connection and support - effective at easing it.',
    title: 'Calm Matters: Stress and Pregnancy',
    type: ReadType.research,
    weekStart: 6,
    weekEnd: 40,
    priority: 'medium',
    reason: 'Looking after your own calm is good for your baby too.',
    readingTime: '2 min',
    category: 'Emotional Wellbeing',
    emoji: '🌿',
    body:
        'Some stress in pregnancy is completely normal. What research highlights is the value of everyday calming habits - rest, breathing, connection, and asking for support.\n\n'
        'You do not need to be perfectly serene. Small moments of calm, repeated, are what matter.',
  ),

  // ---- Books ----
  ReadItem(
    id: 'book_what_to_expect',
    title: 'What to Expect When You\'re Expecting',
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 44,
    reason:
        'A calm, month-by-month reference for the 2 a.m. question every expectant parent asks — "is this normal?" — useful right through pregnancy and the fourth trimester.',
    readingTime: '10 min',
    category: 'Pregnancy Guide',
    emoji: '📖',
    author: 'Heidi Murkoff',
    why:
        'The classic month-by-month pregnancy reference — reassuring, practical, and honest about when to actually worry. Best used as a patient companion you consult by symptom and stage, not read cover to cover.',
    rating: 4.6,
    ratingCount: 15000,
    companion: BookCompanion(
      recommendedFor: [
        'First-time expectant parents',
        'Anxious pregnancy trackers',
        'Anyone wanting a month-by-month reference',
      ],
      themes: ['Pregnancy', 'Nutrition', 'Prenatal health', 'Labour & delivery', 'Postpartum'],
      about:
          'Pregnancy floods parents with fear of the unknown — every twinge or missing symptom can feel like a crisis. What to Expect When You\'re Expecting became a nightstand staple by answering the question anxious minds ask at 2 a.m.: is this normal? Organised month-by-month rather than as one narrative, it lets a worried parent find their exact situation fast — treating uncertainty itself as pregnancy\'s real enemy.',
      philosophy:
          'The changes themselves aren\'t what make pregnancy frightening — not knowing what\'s normal is. A strange cramp or an unfamiliar craving isn\'t inherently alarming; what turns it into 2 a.m. panic is the absence of a reliable answer. The method closes the gap between "something is happening to my body" and "someone can tell me whether that\'s expected" — which is why it\'s organised month-by-month, symptom-by-symptom, like a patient nurse who has heard every question before. The underlying belief is that information is a form of care: worry with no target tends to expand, while worry given a clear answer usually deflates. That\'s why nearly every reassurance is paired with a boundary — the rarer symptoms that do warrant a call. The goal isn\'t blanket calm, but calibrated calm: knowing exactly when concern is appropriate.',
      ideas: [
        BookKeyIdea(
          title: 'Every pregnancy is its own story',
          means:
              'No two pregnancies unfold the same way — even across one woman\'s own children. Symptom timing, intensity, bump size and cravings vary enormously, and none of it predicts anything going wrong.',
          matters:
              'Comparison is one of the biggest sources of pregnancy anxiety. Expecting your experience to match a friend\'s, a sibling\'s, or an app\'s average sets you up to worry over ordinary variation rather than a real problem.',
          inRealLife: [
            'Skip trackers that imply your symptoms "should" look a certain way by week.',
            'Treat differences from other parents as expected, not diagnostic.',
            'Bring genuinely unusual or worsening symptoms to your provider — not to a comparison chat.',
          ],
        ),
        BookKeyIdea(
          title: 'Nutrition is about consistency, not perfection',
          means:
              'Pregnancy nutrition is steady, moderate habits — balanced meals, enough protein, key nutrients like folate and iron — not one "perfect" diet followed exactly every day.',
          matters:
              'Nutrient needs do rise, and some deficiencies carry real risks — but an all-or-nothing mindset backfires, especially alongside nausea that makes eating well genuinely hard some weeks.',
          inRealLife: [
            'Aim for a rough week of decent meals rather than one perfect day.',
            'On nausea-heavy days, prioritise eating something over the "ideal" plate.',
            'Keep one boring, reliable go-to meal ready for low-appetite stretches.',
          ],
        ),
        BookKeyIdea(
          title: 'Most symptoms have an ordinary explanation',
          means:
              'For nearly every strange symptom, the book supplies the underlying reason — hormonal shifts, blood-volume changes, a growing uterus pressing on organs — so it stops feeling mysterious.',
          matters:
              'An unexplained symptom recruits imagination, and imagination tends toward worst-case thinking. A named cause is far less frightening even when the sensation itself doesn\'t change.',
          inRealLife: [
            'When something new appears, look for the "why" before "is this bad".',
            'Keep a short weekly symptom log — a pattern calms nerves faster than a single data point.',
            'Use the explanation to decide whether to wait it out or call your provider.',
          ],
        ),
        BookKeyIdea(
          title: 'Preparation turns unknowns into checklists',
          means:
              'The month-by-month structure previews what\'s coming — fetal development, likely changes, and decisions like a birth plan or feeding choice — before you\'re in the middle of them.',
          matters:
              'Anticipated change is far easier to tolerate than surprise change. Knowing roughly what month six feels like before you\'re in it turns dread into a concrete to-do list.',
          inRealLife: [
            'Read a month or two ahead of where you are, not only the current chapter.',
            'Turn upcoming decisions into a simple timeline instead of leaving them until urgent.',
            'Build your hospital bag gradually across the third trimester.',
          ],
        ),
        BookKeyIdea(
          title: 'You\'re allowed to advocate for yourself',
          means:
              'The book encourages asking questions, seeking second opinions, and choosing a provider you trust — treating you as an active participant, not a passive patient.',
          matters:
              'Pregnant women are sometimes dismissed when reporting symptoms. A parent who expects to ask questions is more likely to walk away with a complete answer.',
          inRealLife: [
            'Write questions down before appointments so nerves don\'t erase them.',
            'If a symptom is dismissed but keeps recurring, ask for it to be documented and revisited.',
            'It\'s fine to seek a second opinion on something significant.',
          ],
        ),
        BookKeyIdea(
          title: 'The fourth trimester deserves as much attention as the first three',
          means:
              'The book extends meaningfully past delivery — physical recovery, mood changes, breastfeeding challenges and the emotional adjustment of early parenthood all get real space.',
          matters:
              'Attention tends to drop the moment the baby arrives — right when a parent\'s body and mind are undergoing some of the most intense changes of all.',
          inRealLife: [
            'Prepare postpartum supplies with the same care as the hospital bag.',
            'Line up practical support for the first two weeks before the baby arrives.',
            'Learn the warning signs of postpartum mood disorders before you need them.',
          ],
        ),
      ],
      perspective:
          'This is one of the steadiest, most reassuring books in the category — its real strength is calming panic with plain explanations, not pushing one parenting style. What\'s most worth borrowing: the mindset that most symptoms have an ordinary explanation, and the encouragement to advocate for yourself with your provider. Treat any specific number or diet detail in the book as a starting point for your own doctor conversation, not a rule to follow exactly.',
      chapters: [
        BookChapter(
          title: 'Before You Conceive',
          summary: 'Preconception health — timing conception, starting prenatal vitamins, and adjusting lifestyle habits before trying. Frames early planning as a way to reduce anxiety later, and previews what the first prenatal visit will involve.',
          keyPoints: [
            'How long conception typically takes, and when a longer wait warrants a doctor visit',
            'Folic acid and prenatal vitamin timing before conception, not just after',
            'Lifestyle adjustments — alcohol, smoking, medications, caffeine — before trying',
            'What actually happens at the very first prenatal appointment',
          ],
        ),
        BookChapter(
          title: 'First Trimester (Months 1–3)',
          summary: 'Confirms pregnancy, introduces early symptoms like nausea and fatigue, and covers the first prenatal visits and early testing. Sets honest expectations that this is often the most symptom-heavy, emotionally uncertain stretch.',
          keyPoints: [
            'Why nausea and fatigue happen, and food/timing strategies that help',
            'What each early test (bloodwork, dating scan, genetic screening) actually checks for',
            'Miscarriage risk by week, and which symptoms genuinely warrant a call',
            'When and how to share the news with family, friends, and employers',
          ],
        ),
        BookChapter(
          title: 'Second Trimester (Months 4–6)',
          summary: 'Often the "easier" stretch as energy returns. Chapters shift toward fetal-development milestones, the anatomy scan, and early practical planning.',
          keyPoints: [
            'What the anatomy scan checks, and what "soft markers" mean if mentioned',
            'Round ligament pain, back pain, and other new discomforts explained',
            'Feeling first movements ("quickening") and what timing is normal',
            'Maternity leave planning and disclosure timing at work',
          ],
        ),
        BookChapter(
          title: 'Third Trimester (Months 7–9)',
          summary: 'Focuses on managing physical discomfort alongside concrete birth preparation — hospital bag, paediatrician choice, recognising real labour signs.',
          keyPoints: [
            'Braxton Hicks vs. real contractions, and how to tell the difference',
            'What\'s actually essential in a hospital bag vs. optional',
            'Signs of true labour onset vs. false alarms',
            'Choosing a paediatrician before the baby arrives',
          ],
        ),
        BookChapter(
          title: 'Labour, Delivery & Special Circumstances',
          summary: 'Walks through the stages of labour and common interventions, with dedicated sections for multiples, high-risk pregnancy, and pregnancy loss.',
          keyPoints: [
            'The three stages of labour and what happens in each',
            'Pain-management options, from unmedicated approaches to epidurals',
            'When induction or a C-section becomes medically necessary',
            'Direct, non-footnoted guidance for multiples, high-risk pregnancy, and loss',
          ],
        ),
        BookChapter(
          title: 'Postpartum & Beyond',
          summary: 'Covers physical recovery, feeding decisions, and the emotional adjustment of early parenthood, including recognising postpartum mood disorders.',
          keyPoints: [
            'Recovery timeline for vaginal birth vs. C-section',
            'Breastfeeding, formula, and combination-feeding basics',
            'Warning signs of postpartum depression and anxiety, and when to seek help',
            'What\'s normal in the "baby blues" versus what isn\'t',
          ],
        ),
      ],
      quotes: [
        '"You will want a copilot in whom you have complete faith." — on choosing a healthcare provider you trust.',
        '"What you tell your doctor is confidential; no one else will know." — on being honest with your provider without fear of judgement.',
      ],
    ),
  ),
  ReadItem(
    id: 'book_whole_brain',
    title: 'The Whole-Brain Child',
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 44,
    reason: 'A gentle look ahead at how your child will grow and learn.',
    readingTime: 'Book',
    category: 'Baby Development',
    emoji: '📘',
    author: 'Daniel J. Siegel & Tina Payne Bryson',
    why:
        'A practical, parent-friendly guide to how a child\'s brain develops, with simple everyday strategies to nurture calm, connection and learning. Written by a neuropsychiatrist and a parenting expert, it stays warm and readable rather than academic. Most useful from late pregnancy through the early years, so it keeps giving long after birth.',
    rating: 4.7,
    ratingCount: 3200,
  ),
  ReadItem(
    id: 'book_expecting_better',
    title: 'Expecting Better',
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 40,
    reason: 'A calm, evidence-based companion for pregnancy questions.',
    readingTime: 'Book',
    category: 'Mother Changes',
    emoji: '📗',
    author: 'Emily Oster',
    why:
        'An economist calmly weighs the evidence behind the common dos and don\'ts of pregnancy, so you can make confident decisions instead of worrying about conflicting advice. Honest about where the data is strong and where it is not. Ideal if you like understanding the "why" behind a recommendation.',
    rating: 4.6,
    ratingCount: 2800,
  ),
  ReadItem(
    id: 'book_first_forty',
    title: 'The First Forty Days',
    type: ReadType.book,
    weekStart: 28,
    weekEnd: 44,
    reason: 'Worth reading before birth - nourishing yourself afterwards.',
    readingTime: 'Book',
    category: 'Preparation',
    emoji: '📙',
    author: 'Heng Ou',
    why:
        'A warm guide to the often-overlooked first weeks after birth - rest, recovery and nourishing food - so you feel cared for, not just the baby. It blends traditional postpartum wisdom with practical recipes. Best read before delivery, while you still have time to prepare.',
    rating: 4.5,
    ratingCount: 1100,
  ),
  ReadItem(
    id: 'book_garbh',
    title: 'Garbh Sanskar',
    type: ReadType.book,
    weekStart: 4,
    weekEnd: 40,
    reason: 'A traditional perspective on bonding and calm during pregnancy.',
    readingTime: 'Book',
    category: 'Emotional Wellbeing',
    emoji: '📕',
    author: 'Dr. Balaji Tambe',
    why:
        'A well-loved Indian perspective on bonding, diet, music and calm during pregnancy, blending Ayurvedic wisdom with day-to-day practices many families value. Gentle and ritual-focused rather than clinical. A comforting companion if you would like a traditional lens alongside modern guidance.',
    rating: 4.4,
    ratingCount: 1500,
  ),

  // ---- Expert picks ----
  ReadItem(
    id: 'exp_priya',
    title: 'Building Emotional Connection Before Birth',
    type: ReadType.expert,
    weekStart: 16,
    weekEnd: 40,
    priority: 'medium',
    reason: 'Connecting now helps many families feel more confident.',
    readingTime: '4 min',
    category: 'Emotional Wellbeing',
    emoji: '👩‍⚕️',
    author: 'Dr. Priya Sharma',
    authorRole: 'Pediatrician',
    why: 'Understanding emotional connection before birth helps many families feel more confident.',
    body:
        'Bonding does not begin at birth - it begins now. Talking to your baby, responding to movements, and taking quiet moments together build a foundation of security.\n\n'
        'Parents who connect during pregnancy often feel more confident and calm when their baby arrives.',
  ),
  ReadItem(
    id: 'exp_meera',
    title: 'Why Early Breastfeeding Prep Helps',
    type: ReadType.expert,
    weekStart: 28,
    weekEnd: 40,
    priority: 'medium',
    reason: 'A little preparation now makes the first week far smoother.',
    readingTime: '4 min',
    category: 'Preparation',
    emoji: '🤱',
    author: 'Dr. Meera Nair',
    authorRole: 'Lactation Consultant',
    why: 'Learning the basics before birth makes those first days much easier.',
    body:
        'Breastfeeding is natural, but it is also a skill that both you and your baby learn together. Knowing the basics of positioning and latch before birth removes a lot of first-week stress.\n\n'
        'You do not have to master it now - just gently familiarise yourself.',
  ),
];

// ---------------------------------------------------------------------------
//  Lookups + stage-aware selection
// ---------------------------------------------------------------------------
ReadItem? readById(String id) {
  for (final r in kReadItems) {
    if (r.id == id) return r;
  }
  return null;
}

int _rank(ReadItem r) => r.isHigh ? 0 : 1;

/// Items relevant at [week] (articles/research/expert), high-priority first.
List<ReadItem> recommendedForWeek(int week) {
  final list = kReadItems
      .where((r) =>
          r.type != ReadType.book && r.relevantAt(week))
      .toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  return list;
}

/// The single hero pick for [week].
ReadItem? heroForWeek(int week) {
  final rec = recommendedForWeek(week);
  return rec.isEmpty ? null : rec.first;
}

/// Items that become relevant soon (start within the next ~8 weeks).
List<ReadItem> lookingAhead(int week) {
  final list = kReadItems
      .where((r) =>
          r.type != ReadType.book &&
          r.weekStart > week &&
          r.weekStart <= week + 8)
      .toList()
    ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
  return list;
}

List<ReadItem> readByType(ReadType type) =>
    kReadItems.where((r) => r.type == type).toList();

/// Daily Reads - [count] article picks for [week], rotating by [day] so the set
/// refreshes each day. Week-relevant articles come first; if there are fewer
/// than [count], it tops up with other articles so the section always fills.
List<ReadItem> dailyArticleReads(int week, int day, {int count = 3}) {
  final relevant = kReadItems
      .where((r) => r.type == ReadType.article && r.relevantAt(week))
      .toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  final pool = <ReadItem>[...relevant];
  if (pool.length < count) {
    pool.addAll(kReadItems
        .where((r) => r.type == ReadType.article && !pool.contains(r)));
  }
  if (pool.isEmpty) return const [];
  final n = pool.length;
  final start = day % n;
  return List.generate(count.clamp(0, n), (i) => pool[(start + i) % n]);
}

/// Daily Reads - [count] book picks, rotating by [day].
List<ReadItem> dailyBookReads(int day, {int count = 3}) {
  final books = readByType(ReadType.book);
  if (books.isEmpty) return const [];
  final n = books.length;
  final start = day % n;
  return List.generate(count.clamp(0, n), (i) => books[(start + i) % n]);
}

/// Daily Reads - [count] research-summary picks, rotating by [day].
List<ReadItem> dailyResearchReads(int day, {int count = 2}) {
  final research = readByType(ReadType.research);
  if (research.isEmpty) return const [];
  final n = research.length;
  final start = day % n;
  return List.generate(count.clamp(0, n), (i) => research[(start + i) % n]);
}

List<ReadItem> readSearch(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  return kReadItems
      .where((r) =>
          r.title.toLowerCase().contains(q) ||
          r.category.toLowerCase().contains(q) ||
          r.author.toLowerCase().contains(q))
      .toList();
}
