# ParentVeda - Mother Home Screen (Daily Moment) Product Specification

You are designing the Mother Home Screen experience for ParentVeda.
Read this entire document before making any design decisions.

---

## CONTEXT

ParentVeda already contains a complete Week 4-40 Pregnancy Journey.

The Weekly Journey already covers:
- Baby development
- Fetal growth
- Pregnancy milestones
- Mother's body changes
- Medical information
- Weekly preparation
- Trimester-specific guidance
- Labour preparation

Therefore:
The Home Screen MUST NOT duplicate pregnancy education.
The Home Screen serves a completely different purpose.

---

## WHAT IS THE HOME SCREEN?

The Home Screen is the first thing a mother sees every day when opening ParentVeda.
It is the daily heartbeat of the platform.

It is not:
- A course
- A lesson
- A dashboard
- A task manager

It is:
A small daily moment between mother and baby.

The entire experience should take:
4-6 minutes maximum.

The mother should finish feeling:
"I am glad I opened ParentVeda today."

---

## RELATIONSHIP WITH WEEKLY JOURNEY

Weekly Journey answers:
"What is happening this week?"

Home Screen answers:
"How can I grow, connect and prepare today?"

Examples:

Weekly Journey:
Your baby's hearing is developing this week.

Home Screen:
Why Talking To Your Baby Matters.

Weekly Journey:
Iron requirements increase in pregnancy.

Home Screen:
Feeling Tired All The Time? Try These Iron-Rich Foods.

Weekly Journey:
Baby is now the size of an avocado.

Home Screen:
There Is No Perfect Parent.

The two experiences should complement each other.
Never compete.
Never duplicate.

---

## HOME SCREEN PHILOSOPHY

The Home Screen exists to help a mother:
- Become a better parent
- Build a bond with her baby
- Connect spiritually and emotionally with pregnancy
- Create memories during pregnancy
- Care for herself
- Capture her emotional journey

Nothing else.
Do not overload the screen.
Do not add extra modules.
Keep it lightweight.

---

## HOME SCREEN HEADER

The first thing a mother sees should NOT be content.
The first thing she sees should be acknowledgement.

Example:
```
Good Morning, Priya
Week 20 · You're halfway there 💜

🍌 Your little one is the size of a kela this week
About 25 cm · learning to yawn and stretch
```

The goal is to create the feeling:
"This small moment is for me and my baby."

Not:
"Here are today's tasks."

### HEADER COMPONENTS

**Greeting**
Examples:
- Good Morning, Priya
- Good Afternoon, Priya
- Good Evening, Priya

**Journey Progress**
- Week 20 · You're halfway there 💜
- Week 32 · Almost there, mamma 💜

Use journey language. Not task language.
"You're halfway there" instead of "143 of 280 days."
Progress should feel encouraging. Never create pressure.

**Baby Size Callout**
Show the baby's size using an Indian fruit or vegetable comparison.
Include what the baby is learning to do this week.
Example:
Your little one is the size of a kela this week.
About 25 cm · learning to yawn and stretch.

**Daily Moment Summary**
```
Today's Moment
~6 min
A small moment for you and your baby.
```

---

## DAILY MOMENT STRUCTURE

Every day contains exactly 6 content modules.
After completion, the Emotional Check-In is shown.
One additional conditional module (Baby Movement Check-In) appears from Week 28 onwards.

The daily flow:

```
🌱 Grow              → Parenting wisdom
📖 Read To Your Baby  → Story and bonding
💬 Talk To Your Baby  → Memory creation
🕉️ Garbh Sanskar      → Spiritual and emotional ritual
🌸 A Moment For You   → Mother self-care
🤍 Baby Movement      → Awareness check (Week 28+ only)
❤️ Emotional Check-In → Mood capture
```

The emotional arc of the flow:

```
Parenting
  ↓
Story
  ↓
Connection
  ↓
Spiritual/Emotional Ritual
  ↓
Self Care
  ↓
Awareness (Week 28+)
  ↓
Reflection
```

---

### 1. 🌱 Grow

**Purpose:**
Help mother become a better parent.

**Source:**
280-Day Learn Journey.

**Examples:**
- A New Chapter Has Begun
- There Is No Perfect Parent
- Children Borrow Calm From Adults
- Parenting Is Influence, Not Control

**Important:**
Grow teaches parenting wisdom.
It does NOT teach:
- Pregnancy symptoms
- Baby size
- Fetal growth
- Medical information
- Trimester education

Those belong in Weekly Journey.

**Structure:**
- Title
- Short Insight (card layer, 3-5 seconds)
- Expanded Insight (30-60 seconds)
- Optional Deep Dive (research, expert notes, references)
- Remember statement (1 memorable line)

**Card Example:**
```
🌱 Grow

"Children Borrow Calm From Adults"

Your baby is learning from you long before they understand words.
Your calm is their first lullaby.

[Read More →]
```

---

### 2. 📖 Read To Your Baby

**Purpose:**
Build a bond through stories.
Language exposure.
Value transmission.

**Source:**
280 Read Together Stories (Master Library).
Optional Spiritual Stories (user-selected traditions, shown separately below core story if enabled).

**Examples:**
- Krishna & Sudama
- The Lion And The Mouse
- The Honest Woodcutter
- The Monkey and the Crocodile

**Structure:**
- Story Title
- Story Summary
- Read CTA
- Listen CTA (audio version)

**Card Example:**
```
📖 Read To Your Baby

"Krishna & Sudama"

A story about friendship, kindness,
and remembering those who matter.

[📄 Read]  [〰️ Listen]
```

---

### 3. 💬 Talk To Your Baby

**Purpose:**
Create memories before birth.
Build emotional attachment.
Populate the Dear Baby memory vault.

**Source:**
280 Talk To Baby Prompts (10-Act narrative arc).

**Examples:**
- Tell your baby about your favourite childhood memory.
- Tell your baby how you met their father.
- Tell your baby what kindness means to you.
- Tell your baby about your dreams for them.

**Actions:**
- Record Audio
- Write Message
- Maybe Later (not "Skip")

Output automatically saves into Dear Baby.

**Card Example:**
```
💬 Talk To Your Baby

"Tell your baby about your favourite
childhood memory."

"One day your child may hear this
story in your own voice."

[🎙 Record]  [✏️ Write]  [Maybe later]
```

---

### 4. 🕉️ Garbh Sanskar

**Purpose:**
Create a uniquely Indian daily spiritual and emotional ritual.
This is the emotional and spiritual core of the daily experience.
This is ParentVeda's India-specific moat. No Western pregnancy app has this.

**Important:**
Garbh Sanskar is NOT part of Nurture.
Garbh Sanskar = Baby Connection (spiritual, emotional bond)
Nurture = Mother Care (self-care, wellbeing)
These are very different jobs. Keep them separate.

**Position:**
After Talk To Your Baby.
Before A Moment For You.

**Source:**
280 Garbh Sanskar assets.

**Content Types:**

**Raga (30% of assets = ~84)**
Classical Indian ragas known for their calming and developmental properties.
Examples:
- Raga Yaman
- Raga Bhupali
- Raga Hamsadhwani
- Raga Desh
- Raga Durga
Format: Play button with 2-5 min audio clip.
Include raga name, duration, and a one-line description of its mood/purpose.

**Affirmation (40% of assets = ~112)**
Spiritually-grounded affirmations connecting mother and baby.
Examples:
- I welcome this child with love.
- My baby is growing in a space filled with calm.
- I am creating a peaceful world for my child.
- My love surrounds my baby today.
Format: Affirmation text with optional soft background.

**Guided Meditation (30% of assets = ~84)**
Short guided meditations focused on baby connection.
Examples:
- Connecting With Your Baby
- Gratitude For Today
- Sending Love To Your Child
- Trusting The Journey
- Breathing With Your Baby
Format: 1-2 min guided audio with introduction and closing thought.

**Daily Rotation:**
Each day shows ONE Garbh Sanskar item.
Rotate across the three content types using the 40/30/30 distribution.

**Card Example (Raga day):**
```
🕉️ Garbh Sanskar

Today's Practice

[🎵 Album Art]  RAGA
                Raga Yaman
                4 min · Evening raga for peace
                [▶ Play]

"I welcome this child with love.
My baby is growing in a space filled with calm."
```

**Card Example (Meditation day):**
```
🕉️ Garbh Sanskar

Today's Practice

GUIDED MEDITATION
Connecting With Your Baby
2 min

[▶ Begin]

"Close your eyes. Place your hands on your belly.
Imagine sending warmth and love to your baby."
```

**Card Example (Affirmation day):**
```
🕉️ Garbh Sanskar

Today's Practice

AFFIRMATION

"My baby is growing in a space
filled with calm and love.
I trust this journey."

[🤍 Keep This With Me]
```

---

### 5. 🌸 A Moment For You (Nurture)

**Purpose:**
Help mother care for herself today.

This section is NOT educational.
It is NOT parenting content.
It is NOT pregnancy education.
It exists only to support the mother.

Only ONE Nurture item appears each day.
Never show multiple nurture items.

**Content Types:**

**💛 Affirm (100 assets)**
Examples:
- I can take this one day at a time.
- My baby does not need a perfect mother.
- I trust myself more than I think.

Format:
- Title
- Affirmation text
- Remember statement

**🧘 Breathe (40 assets)**
Examples:
- Calm In Uncertainty
- One Minute Of Stillness
- Trusting The Process
- Preparing For Birth

Length: 1-3 minutes.

Format:
- Title
- Duration
- Introduction
- Guided Audio Script
- Closing Thought

**🥗 Food For Today (140 assets)**
Purpose: Solve real pregnancy problems.

Always lead with the mother's problem.
Never lead with nutrition science.

Bad Example: Vitamin C Helps Absorb Iron
Good Example: Feeling Tired All The Time? Pair spinach with lemon to help your body absorb more iron.

Format:
- Title (problem-led)
- Content (solution)
- Remember statement

**Card Example:**
```
🌸 A Moment For You

"I Can Take This One Day At A Time"

"I do not need all the answers today.
I only need the next step."

[🤍 Keep This With Me]
```

**Distribution Across Pregnancy:**

First Trimester (Days 1-84):
Priority: Affirm, Breathe. Very little food content.
Focus: Reassurance, anxiety reduction, emotional support.

Second Trimester (Days 85-196):
Priority: Food For Today, Affirm, Breathe.
Focus: Energy, nutrition, confidence.

Third Trimester (Days 197-280):
Priority: Breathe, Food For Today, Affirm.
Focus: Calm, readiness, rest, birth preparation.

---

### 6. 🤍 Baby Movement Check-In (Conditional)

**Purpose:**
Create awareness without anxiety.
No counting. No targets. No gamification.

**Visibility Rules:**
- Week 1-27: DO NOT show this card.
- Week 28-40: Show this card.

**Position:**
Below A Moment For You (Nurture).
Above Emotional Check-In.

**Important Design Principles:**
Most pregnancy apps turn movement tracking into:
```
Kick Count
14 kicks today
Target: 10
```
This creates anxiety.

ParentVeda's version creates:
Awareness without Obsession.

**Question:**
Did your baby move today?

**Options:**
- Yes
- Not yet

(Use "Not yet" instead of "No". "Not yet" implies the baby will move, it just hasn't happened yet. This is awareness, not alarm.)

**If Yes:**
```
Wonderful 💚
Your baby is active today.
```
Done. No further action needed.

**If Not Yet:**
```
That's okay.
Try lying on your left side.
Drink something cold.
Spend 30 minutes focusing on movement.

Still not feeling movement?
Contact your doctor.
```

Calm guidance. No panic. Clear escalation path.

**Card Example:**
```
🤍 Baby Movement Check-In

Did your baby move today?

No counting. No targets. Just awareness.

[💚 Yes]  [Not yet]
```

---

## DAILY COMPLETION

A Daily Moment is considered complete when:
- Grow opened
- Read To Your Baby opened
- Talk To Your Baby completed OR skipped
- Garbh Sanskar opened
- A Moment For You opened
- Baby Movement Check-In answered (Week 28+ only)

Completion should feel rewarding.
Never feel like work.

**Completion Message:**
Do NOT use a checkmark or "Today's Moment Complete."
Instead, use warm acknowledgement:

```
🌸
You gave yourself 6 minutes today.
That matters more than you know.
```

---

## POST-COMPLETION: EMOTIONAL CHECK-IN

After Daily Moment completion, reveal the Emotional Check-In.

This creates a separation between:
The baby-focused ritual
and
The mother-focused reflection.

---

### 7. ❤️ Emotional Check-In

**Purpose:**
Capture the emotional journey of pregnancy.
Create a 280-day emotional timeline.

This is NOT part of Nurture.
This is NOT part of Garbh Sanskar.
This is a separate feature.

**Question:**
How are you feeling right now?

**Subtext:**
No right answer. Just checking in with you.

**Rules:**
- Single-select only
- One tap
- Less than 2 seconds
- Can be skipped (use "Maybe later" not "Skip")
- Stored permanently
- Later shown inside Dear Baby ("Before You Were Born" emotional timeline)

**Check-In Options:**

😊 Happy
🙏 Grateful
🌿 Calm
✨ Hopeful
😴 Tired
💭 Anxious
🌊 Overwhelmed
💗 Loved

**Design Notes:**
- Do NOT use stock yellow emoji faces. Use icons that feel intentional and warm.
- Each mood option should have its own soft background color when selected.
- "Overwhelmed" gets equal visual weight to positive emotions. Do not minimize it.
- Use "Maybe later" instead of "Skip."

**At the end of pregnancy, the mother should be able to see:**
- Emotional timeline
- Most common emotions
- Emotional trends across pregnancy
- Emotional milestones

The goal is to create a beautiful emotional story of the journey into motherhood.

---

## DEAR BABY

Dear Baby is NOT part of Daily Moment.
Dear Baby is a separate destination in the app.

Purpose: Preserve the story of pregnancy.

Contents:
- Talk To Baby recordings
- Written messages
- Photos
- Weekly memories
- Emotional timeline
- Pregnancy milestones

Do NOT create a separate "Save Memory" card on Home Screen.
Memories are automatically generated through Talk To Your Baby and Emotional Check-In.

---

## PLATFORM STRUCTURE

- Home: Daily Moment
- My Baby: Child profile
- Dear Baby: Memory vault
- Explore: Content, experts, products and tools
- Profile: Settings, preferences

---

## RESPONSIBILITY OF EACH MODULE

| Module | Responsibility |
|---|---|
| Weekly Journey | Explains pregnancy |
| Grow | Develops parenting wisdom |
| Read To Your Baby | Builds bond through stories |
| Talk To Your Baby | Creates memories |
| Garbh Sanskar | Spiritual and emotional baby connection |
| A Moment For You | Supports the mother |
| Baby Movement | Creates movement awareness (Week 28+) |
| Emotional Check-In | Captures emotional journey |
| Dear Baby | Preserves the story |

Never mix responsibilities.

---

## JSON STRUCTURE

### Week 20 Example (Before Week 28, no movement check-in):

```json
{
  "day": 143,
  "week": 20,
  "baby_size": {
    "fruit": "kela",
    "fruit_emoji": "🍌",
    "size_cm": 25,
    "milestone": "learning to yawn and stretch"
  },
  "grow": {
    "title": "Children Borrow Calm From Adults",
    "type": "lesson",
    "insight": "Your baby is learning from you long before they understand words. Your calm is their first lullaby.",
    "remember": "Every parent begins exactly where you are today."
  },
  "read_to_baby": {
    "title": "Krishna And Sudama",
    "type": "story",
    "summary": "A story about friendship, kindness, and remembering those who matter.",
    "audio_available": true
  },
  "talk_to_baby": {
    "title": "Tell your baby about your favorite childhood memory.",
    "type": "conversation",
    "motivation": "One day your child may hear this story in your own voice.",
    "actions": ["record", "write", "maybe_later"],
    "saves_to": "dear_baby"
  },
  "garbh_sanskar": {
    "type": "raga",
    "title": "Raga Yaman",
    "duration_minutes": 4,
    "description": "Evening raga for peace",
    "affirmation": "I welcome this child with love. My baby is growing in a space filled with calm."
  },
  "nurture": {
    "type": "affirm",
    "title": "I Can Take This One Day At A Time",
    "content": "I do not need all the answers today. I only need the next step.",
    "remember": "Parenthood is learned one day at a time."
  },
  "movement_checkin": null,
  "emotional_checkin": {
    "question": "How are you feeling right now?",
    "subtext": "No right answer. Just checking in with you.",
    "single_select": true
  }
}
```

### Week 32 Example (Week 28+, movement check-in visible):

```json
{
  "day": 220,
  "week": 32,
  "baby_size": {
    "fruit": "nariyal",
    "fruit_emoji": "🥥",
    "size_cm": 42,
    "milestone": "practising breathing movements"
  },
  "grow": {
    "title": "Mistakes Help The Brain Grow",
    "type": "lesson",
    "insight": "When children are allowed to make mistakes in safe environments, their brains build stronger problem-solving pathways.",
    "remember": "The goal is not to prevent mistakes. It is to make them safe to learn from."
  },
  "read_to_baby": {
    "title": "The Sleeping Mountain",
    "type": "story",
    "summary": "A gentle story about patience, stillness, and the quiet strength of waiting.",
    "audio_available": true
  },
  "talk_to_baby": {
    "title": "What do you think will surprise you most about parenthood?",
    "type": "conversation",
    "motivation": "Your honesty today becomes their wisdom tomorrow.",
    "actions": ["record", "write", "maybe_later"],
    "saves_to": "dear_baby"
  },
  "garbh_sanskar": {
    "type": "meditation",
    "title": "Sending Love To Your Child",
    "duration_minutes": 2,
    "description": "A short guided meditation to connect with your baby.",
    "introduction": "Close your eyes. Place your hands on your belly. Imagine sending warmth and love to your baby.",
    "closing_thought": "Your baby feels your calm. That is enough."
  },
  "nurture": {
    "type": "breathe",
    "title": "Preparing For Birth",
    "duration_minutes": 2,
    "content": "A gentle breathing exercise to help you feel calm and ready.",
    "remember": "You do not need to be fearless. You only need to breathe."
  },
  "movement_checkin": {
    "question": "Did your baby move today?",
    "subtext": "No counting. No targets. Just awareness.",
    "options": ["yes", "not_yet"],
    "yes_response": {
      "message": "Wonderful 💚 Your baby is active today."
    },
    "not_yet_response": {
      "message": "That's okay. Try lying on your left side. Drink something cold. Spend 30 minutes focusing on movement.",
      "escalation": "Still not feeling movement? Contact your doctor."
    }
  },
  "emotional_checkin": {
    "question": "How are you feeling right now?",
    "subtext": "No right answer. Just checking in with you.",
    "single_select": true
  }
}
```

---

## REVISED DAILY RITUAL SUMMARY

```
🌱 GROW
Today's Parenting Insight

📖 READ TO YOUR BABY
Today's Story

💬 TALK TO YOUR BABY
Today's Conversation

🕉️ GARBH SANSKAR
Today's Spiritual Practice

🌸 A MOMENT FOR YOU
One care moment

🤍 BABY MOVEMENT CHECK-IN
(Week 28+ only)

❤️ EMOTIONAL CHECK-IN
How are you feeling right now?
```

6 daily modules + 1 conditional + 1 reflection.
Clean. Warm. Achievable in 4-6 minutes.

---

## DAY EXAMPLE: Week 20, Day 143

```
🌱 GROW

"Children Borrow Calm From Adults"

Your baby is learning from you long before they
understand words. Your calm is their first lullaby.

[Read More →]
```

```
📖 READ TO YOUR BABY

"Krishna & Sudama"

A story about friendship, kindness,
and remembering those who matter.

[📄 Read]  [〰️ Listen]
```

```
💬 TALK TO YOUR BABY

"Tell your baby about your favourite
childhood memory."

"One day your child may hear this
story in your own voice."

[🎙 Record]  [✏️ Write]  [Maybe later]
```

```
🕉️ GARBH SANSKAR

Today's Practice

RAGA
Raga Yaman
4 min · Evening raga for peace

[▶ Play]

"I welcome this child with love.
My baby is growing in a space filled with calm."
```

```
🌸 A MOMENT FOR YOU

"I Can Take This One Day At A Time"

"I do not need all the answers today.
I only need the next step."

[🤍 Keep This With Me]
```

```
🌸
You gave yourself 6 minutes today.
That matters more than you know.
```

```
❤️ HOW ARE YOU FEELING RIGHT NOW?

No right answer. Just checking in with you.

😊 Happy    🙏 Grateful   🌿 Calm     ✨ Hopeful
😴 Tired    💭 Anxious    🌊 Overwhelmed  💗 Loved

[Maybe later]
```

---

## DAY EXAMPLE: Week 32, Day 220 (with Baby Movement)

Same structure as above, plus after A Moment For You:

```
🤍 BABY MOVEMENT CHECK-IN

Did your baby move today?

No counting. No targets. Just awareness.

[💚 Yes]  [Not yet]
```

If Yes:
```
Wonderful 💚
Your baby is active today.
```

If Not Yet:
```
That's okay.
Try lying on your left side.
Drink something cold.
Spend 30 minutes focusing on movement.

Still not feeling movement?
Contact your doctor.
```

---

## DESIGN PRINCIPLES

1. The Home Screen is a moment, not a dashboard.
2. Use journey language, not task language. "You're halfway there" not "143 of 280 days."
3. "Maybe later" instead of "Skip" everywhere.
4. Completion should feel like acknowledgement, not a checkbox. "You gave yourself 6 minutes today" not "Today's Moment Complete ✓."
5. Warm background gradients (cream, peach, lavender). Not pure white.
6. Cards should feel soft and organic. No hard outlines. Subtle shadows.
7. Garbh Sanskar card uses a distinct warm amber/saffron palette to signal its sacred positioning.
8. Baby Movement uses "Not yet" instead of "No." No counting, no targets, no gamification.
9. Emotional Check-In uses intentional icons, not stock yellow emojis. Each mood gets its own soft background color.
10. The daily flow should feel like a gentle arc: learn, bond, connect, ritual, care, reflect. Never feel like a checklist.

---

## CONTENT INVENTORY SUMMARY

| Module | Assets | Source |
|---|---|---|
| Grow | 280 | Learn Journey v2.0 (10 modules x 28 days) |
| Read To Your Baby | 280 core + 120 optional spiritual | Master Story Library (7 categories + 6 spiritual traditions) |
| Talk To Your Baby | 280 | Talk To Baby Journey v1.0 (10 acts) |
| Garbh Sanskar | 280 | 112 affirmations (40%) + 84 meditations (30%) + 84 ragas (30%) |
| A Moment For You | 280 | 100 affirmations + 40 breathe + 140 food |
| Baby Movement | N/A | Conditional UI, no content assets needed |
| Emotional Check-In | N/A | UI component, no content assets needed |

Total daily content universe: 1,400 unique assets across the 280-day journey.

---

## GARBH SANSKAR CONTENT SPECIFICATION

### Raga Library (~84 assets)

Source authentic Indian classical ragas known for their calming, developmental, and spiritual properties.

Organize by time of day and mood:
- Morning ragas (e.g., Raga Bhairav, Raga Todi)
- Afternoon ragas (e.g., Raga Sarang, Raga Bhimpalasi)
- Evening ragas (e.g., Raga Yaman, Raga Puriya Dhanashri)
- Night ragas (e.g., Raga Malkauns, Raga Darbari)
- Universal/anytime ragas (e.g., Raga Bhupali, Raga Hamsadhwani)

Each raga asset:
```json
{
  "type": "raga",
  "title": "Raga Yaman",
  "duration_minutes": 4,
  "time_of_day": "evening",
  "description": "Evening raga for peace",
  "instrument": "sitar"
}
```

### Affirmation Library (~112 assets)

Spiritually-grounded affirmations connecting mother to baby.
These are distinct from Nurture affirmations.

Nurture affirmations = About the mother's wellbeing.
Garbh Sanskar affirmations = About the mother-baby spiritual connection.

Themes:
- Welcoming the child
- Sending love and calm
- Spiritual connection
- Gratitude for the pregnancy journey
- Creating a peaceful inner world
- Trust in the process of creation

Each affirmation asset:
```json
{
  "type": "affirmation",
  "title": "A Space Filled With Calm",
  "affirmation": "My baby is growing in a space filled with calm. I trust this journey.",
  "theme": "peace"
}
```

### Guided Meditation Library (~84 assets)

Short, gentle meditations focused on baby connection.
Not generic mindfulness. Specifically pregnancy and baby-focused.

Themes:
- Connecting with baby
- Sending love
- Gratitude for pregnancy
- Trusting the body
- Preparing for birth (third trimester)
- Visualization of meeting baby

Each meditation asset:
```json
{
  "type": "meditation",
  "title": "Connecting With Your Baby",
  "duration_minutes": 2,
  "introduction": "Close your eyes. Place your hands on your belly.",
  "closing_thought": "Your baby feels your calm. That is enough."
}
```

### Trimester Distribution for Garbh Sanskar

First Trimester (Days 1-84):
Priority: Affirmations (50%), Meditations (30%), Ragas (20%).
Focus: Reassurance, welcoming, establishing the practice.

Second Trimester (Days 85-196):
Priority: Ragas (35%), Affirmations (35%), Meditations (30%).
Focus: Deeper connection, enjoyment, musical exposure for baby.

Third Trimester (Days 197-280):
Priority: Meditations (40%), Ragas (30%), Affirmations (30%).
Focus: Preparation, visualization, calm before birth.

---

## BABY MOVEMENT CHECK-IN SPECIFICATION

### Technical Rules

```
if (current_week < 28) {
  // Do not render movement check-in card
  movement_checkin = null
}

if (current_week >= 28) {
  // Show movement check-in card
  // Position: after Nurture, before Emotional Check-In
}
```

### State Management

Movement check-in has three states:
1. **Not answered** (default daily state)
2. **Yes** (baby moved)
3. **Not yet** (baby has not moved)

If "Not yet" is selected:
- Show calm guidance
- Allow re-answering later in the day (mother can come back and change to "Yes")
- If still "Not yet" at end of day, store as "Not yet" and show doctor contact recommendation

### Data Storage

Store daily movement responses for Week 28-40.
This data can be shown in:
- Dear Baby timeline
- Weekly summary
- Doctor visit preparation (optional future feature)

Do NOT:
- Count kicks
- Set targets
- Show streaks
- Gamify in any way
- Create anxiety through comparisons or benchmarks

---

## BOTTOM NAVIGATION

```
🏠 Home    👶 My Baby    💌 Dear Baby    🧭 Explore    👤 Profile
```

Dear Baby in the navigation is important. The name alone signals emotional depth.

---

Design the complete Mother Home Screen and Daily Moment experience following these principles.
