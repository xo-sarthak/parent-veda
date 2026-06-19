# Home Daily-Moment — 280-Day Content Spine

Working backbone for authoring `lib/data/home/week_NN.json` (weeks 4–40, 7 days
each). Keeps arcs coherent and titles non-duplicating across batches. Source of
truth for *intent* remains `ParentVeda_Mother_Home_Screen_Spec_v2.md`.

## Day ↔ week ↔ trimester
- Day of pregnancy `d = (week-1)*7 + dayInWeek`. Week 4 = days 22–28 … Week 40 = days 274–280.
- Trimester 1: weeks 4–13 · Trimester 2: weeks 14–27 · Trimester 3: weeks 28–40.
- Baby Movement Check-In: weeks 28–40 only (UI; no per-day content needed).
- Header baby-size reuses `weekContent.json` snapshot; per-day `babyLearning` is a short "learning to…" phrase only.

## Module intent (tone)
- **Grow / Read / Talk** → warm-but-substantive: parenting wisdom, bonding stories, memory-making. Educative where it helps, never pregnancy education (that's the Weekly Journey).
- **Garbh Sanskar / A Moment For You** → emotional & spiritual: ritual, calm, self-care.

## GROW — 10 modules × 28 days (parenting wisdom, NOT pregnancy)
1. wk 4–7   A New Chapter Begins — becoming a parent, identity, first mindset shifts
2. wk 8–11  The Calm Within — calm as the first language; co-regulation
3. wk 12–15 Connection Before Words — presence, responsiveness, attachment
4. wk 16–19 How Little Ones Learn — curiosity, play, modelling
5. wk 20–23 Influence, Not Control — guidance vs control, respect *(anchor: wk20 "Children Borrow Calm From Adults")*
6. wk 24–27 Mistakes Help Us Grow — resilience, safe failure, growth mindset
7. wk 28–31 Roots & Values — culture, family stories, what we pass on
8. wk 32–35 Patience & Presence — slowing down, attention *(anchor: wk32 "Mistakes Help The Brain Grow")*
9. wk 36–38 Confidence Without Comparison — trusting yourself, no comparison
10. wk 39–40 Preparing To Meet You — readiness, hopes, the first days
(Each Grow item: title, insight, expanded, deepDive?, remember.)

## READ TO YOUR BABY — 280 short stories (~120–180 words, complete & meaningful)
Rotate categories so no run repeats: Panchatantra/animal fable · Indian epic & Krishna/mythology · Moral folk tale (Honest Woodcutter etc.) · Jataka/Buddhist · Tenali Rama / Birbal wit · Universal gentle tale · Nature/seasonal parable. Spiritual-tradition stories optional, not in core rotation.
(Each: title, summary, body, audioAvailable:true.)

## TALK TO YOUR BABY — 10-act arc × 28 days (memory-making prompts)
1 Welcoming You · 2 Who I Am · 3 Where You Come From (family) · 4 Our Love Story · 5 Hopes & Dreams · 6 Lessons I've Learned · 7 The World You're Joining · 8 Little Joys & Traditions · 9 Promises To You · 10 Counting Down To You.
(Each: title (a "Tell your baby…" prompt), motivation. Actions are fixed UI: record/write/maybe_later.)

## GARBH SANSKAR — type by trimester (rotate to hit ratios)
- T1 (wk 4–13): affirmation 50% · meditation 30% · raga 20%
- T2 (wk 14–27): raga 35% · affirmation 35% · meditation 30%
- T3 (wk 28–40): meditation 40% · raga 30% · affirmation 30%
Ragas tagged by time-of-day (morning/afternoon/evening/night/anytime); meditations baby-connection themed; affirmations = mother↔baby spiritual bond (distinct from Nurture affirmations). Every item carries `about` + `howToUse` for the "i" sheet.

## A MOMENT FOR YOU (Nurture) — type by trimester
- T1: affirm + breathe priority; almost no food (reassurance, anxiety down)
- T2: food-led + affirm + breathe (energy, nutrition, confidence)
- T3: breathe + food + affirm (calm, rest, birth prep)
Food items are problem-led ("Feeling tired? …"), never nutrition-science-led.
(Each: type, title, content, remember, durationMinutes for breathe.)

## Titles ledger (append as authored — prevents duplicates)
### Grow used
- wk20 d140: Children Borrow Calm From Adults
- wk04: A New Chapter Has Begun · You Don't Have To Know Everything · Love Is Already Enough · You Are Becoming, Too · Small Moments Build A Parent · Your Body Is Already Parenting · The First Gift Is Presence
- wk05: Calm Is A Language · You Cannot Pour From Empty · Feelings Are Not Emergencies · The Pause Is The Power · Your Peace Travels Inward · Soft Is Also Strong · Begin Again, Gently
### Story titles used
- wk20 d140: Krishna & Sudama
- wk04: The Lion And The Mouse · The Thirsty Crow · The Honest Woodcutter · The Two Pots · The Sparrow's Nest · The Moon And The Cap Seller · Ekalavya's Gift
- wk05: The Monkey And The Crocodile · The Foolish Donkey · Birbal And The Pot Of Wit · The Banyan And The Reed · The Boy Who Cried Wolf · The Tortoise And The Hare · The Lamp In The Wind
### Talk prompts used (by act)
- wk20 d140 (act5): favourite childhood memory
- wk04 (act1 Welcoming You): first felt real · chose your name feeling · what you mean to me · the day we found out · how I imagine your face · first hopes whispered · welcoming you to our family
- wk05 (act2 Who I Am): what makes me, me · my favourite things · what I do / my work · my friendships · my faith & what calms me · a fear I'm working on · the kind of parent I hope to be
