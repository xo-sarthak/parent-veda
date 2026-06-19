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

## Batch weeks 6-9 (authored) — arc adjusted: calm covered in wk5, so wk6-9 take fresh themes
### Grow used (cont.)
- wk06 (Trust & The Body's Wisdom): Your Body Already Knows The Way · You Can Trust What You Cannot See · Worry Is Not Preparation · Let Go Of The Perfect Plan · Uncertainty Can Be Gentle · Faith In Small Steps · Tomorrow Will Teach You Tomorrow
- wk07 (The Bond Before Words): Love Speaks Before Words · Your Voice Is Already Home · They Feel What You Feel · Connection Is The First Lesson · A Heartbeat They Already Know · Presence Over Perfection · The Bond Grows Both Ways
- wk08 (Your Own Path, no comparison): Your Way Is A Good Way · Advice Is Not Instruction · No Two Journeys Match · Trust Your Quiet Instinct · Comparison Steals Joy · You Know Your Baby Best · Write Your Own Story
- wk09 (Everyday Love & Joy): Joy Is Not Frivolous · Little Rituals, Lasting Roots · Play Is Serious Work · The Magic Of Ordinary Days · Laughter Is A Language Too · Slow Moments Matter Most · Wonder Is Worth Keeping
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk06: The Elephant And The Rope · The Clever Rabbit And The Lion · Krishna And The Govardhan Hill · The Golden Swan · Tenali Rama And The Thieves · The Farmer And The Well · The Seed That Waited
- wk07: The Ant And The Grasshopper · The Talkative Tortoise · Hanuman And The Mountain · The Monkey King's Bridge · Birbal And The Three Questions · The Kind Merchant · The River And The Mountain
- wk08: The Peacock And The Crane · The Blue Jackal · Shravan Kumar's Devotion · The Wise Quail · Tenali Rama And The Well Dispute · The Potter's Promise · The Mountain Stream
- wk09: The Mice That Ate Iron · The Wind And The Sun · Krishna And The Stolen Butter · The Banyan Deer · Birbal's Khichdi · The Two Brothers And The Field · The First Rain
### Talk prompts used (cont., by act)
- wk06 (act3 Where You Come From): your mother · grandparents & origins · a family tradition · hometown · a relative awaiting them · family food/language/roots · the day the family heard
- wk07 (act4 Our Love Story): how we met · a favourite memory · why we chose each other · a hard time we got through · the moment we knew · the home we're building · a promise we made
- wk08 (act5 Hopes & Dreams): one big dream · who I hope you become · an experience to share · a place to take you · what I hope you never doubt · the world you'll help build · a small everyday hope
- wk09 (act6 Lessons I've Learned): the most important lesson · something learned the hard way · what kindness taught me · what 'enough' means · what failure taught me · who taught me most · a lesson to learn sooner
### Garbh ragas used (T1): Bhupali(wk4) · Bhairav(wk5) · Bilawal/morning(wk6 d40) · Desh/evening(wk7 d46) · Kafi/afternoon(wk8 d54) · Khamaj/evening(wk9 d60)

## Batch weeks 10-13 (authored) — closes Trimester 1; completes the 10-act Talk arc
### Grow used (cont.)
- wk10 (Patience Is Love In Practice): Patience Is Love, Slowed Down · The Long Game Of Love · Nothing Good Is Rushed · Slow Is Its Own Gift · Let Things Unfold · Waiting Can Be Tender · One Day Holds Enough
- wk11 (Courage, Quietly): Courage Is Quiet · Brave Is Not Fearless · You Are Stronger Than The Doubt · Small Acts Of Bravery · Fear And Love Can Coexist · Showing Up Is Courage · You Can Do Hard Things
- wk12 (You Are Not Alone): You Were Never Meant To Do This Alone · It Takes A Village · Leaning Is Not Weakness · Let Love Help You · Share The Load · Together Is Lighter · Accept The Hand Offered
- wk13 (Looking Forward With Hope): Hope Is Worth Holding · The Best Is Still Coming · A Season Of Becoming · Anticipation Is A Kind Of Love · Gratitude For The Journey · Trust What Comes Next · Ready In Your Own Time
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk10: The Fox And The Grapes · The Brahmin And The Three Crooks · Krishna And The Serpent Kaliya · The Patient Buffalo · Tenali Rama And The King's Dream · The Magic Pot · The Brook That Became A River
- wk11: The Lion And The Gnat · The Lion-Makers · Abhimanyu's Courage · The Quail And The Falcon · Birbal And The Crow Count · Punyakoti, The Honest Cow · The Sapling In The Storm
- wk12: The Bundle Of Sticks · The Pigeons And The Net · Krishna, Friend Of Arjuna · The United Quails · Tenali Rama And The Shared Feast · Stone Soup · The Weaver Birds' Colony
- wk13: The Two Seeds · The Three Fish · Rama's Return To Ayodhya · The Brave Little Parrot · Birbal And The Most Beautiful Child · The Kind Farmer's Harvest · The First Bud Of Spring
### Talk prompts used (cont., by act) — arc completes at wk13
- wk10 (act7 The World You're Joining): the season you'll be born into · the place & home · what the world is like now · something beautiful to show you · a challenge I hope you help with · the community awaiting you · the world's wonder
- wk11 (act8 Little Joys & Traditions): a festival to share · a special family food · a song/music tradition · a daily ritual I love · a yearly place we visit · a game I'll teach you · a small joy that lifts me
- wk12 (act9 Promises To You): to always listen · to keep you safe · to let you be yourself · to be there in hard times · to laugh and play · to say sorry when wrong · to love you no matter what
- wk13 (act10 Counting Down To You): how I'm getting ready · the first meeting I imagine · the first thing I'll say · who's waiting to hold you · a hope for your first day · what I'll whisper holding you · a welcome as T1 closes
### Garbh ragas used (cont.): Todi/morning(wk10 d68) · Bageshri/night(wk11 d74) · Durga/evening(wk12 d82) · Hansdhwani/evening(wk13 d88)

## Batch weeks 14-17 (Trimester 2 begins) — tone shifts to energy/bonding; Garbh raga-led; Nurture food-led; Talk arc 2nd pass (acts 1-4)
### Grow used (cont.)
- wk14 (Tuning In — responsiveness): The Quiet Conversation · Babies Speak In Signals · Responding Builds Trust · Tune In Before You Fix · Every Cue Is A Word · The Dance Of Back And Forth · To Be Heard Is To Be Loved
- wk15 (How Little Ones Learn): Curiosity Lights The Way · Learning Looks Like Play · Every Question Is A Gift · They Learn By Watching You · Boredom Sparks Imagination · The World Is Their Classroom · Slow Learning Lasts Longest
- wk16 (You Are The First Teacher): You Are The First Teacher · They Copy, They Don't Obey · Your Habits Become Theirs · Show, Don't Just Tell · Little Eyes Are Watching · Values Are Caught, Not Taught · Be What You Hope To See
- wk17 (Warmth Shapes Everything): Warmth Shapes The Brain · Affection Is Never Spoiling · A Safe Base To Explore From · Hugs Are Good Science · Comfort Builds Courage · Love Out Loud · The Warmth They Carry Forever
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk14: The Goose That Laid Golden Eggs · The Crane And The Crab · Dhruva, The Steadfast Star · The Elephant And The Dog · Tenali Rama And The Cat · The King's Seed · The Squirrel And The Mountain
- wk15: The Milkmaid And Her Pail · The Jackal And The Drum · Nachiketa's Questions · The Monkey And The Handful Of Peas · Birbal And The Centre Of The Earth · The Tailor And The Elephant · The Little Cloud's Journey
- wk16: The Dog And Its Reflection · The Jackal And The Bowstring · Prahlad And His Faith · The Selfless Hare · Tenali Rama And The Brinjal Curry · The Grateful Elephant · The Roots And The Leaves
- wk17: The Two Friends And The Bear · The Mice And The Elephants · Krishna Protects Draupadi · The Woodpecker And The Lion · Birbal And The Magic Stick · The Three Wishes · The Old Mango Tree
### Talk prompts (cont.) — 2nd pass through arc, fresh angles
- wk14 (act1 Welcoming You, 2nd): bump growing/showing · feeling closer to meeting you · nicknames already · how my days have changed · imagining your first movements · what I can't wait to feel next · welcome to the second trimester
- wk15 (act2 Who I Am, 2nd): a talent I have · how I handle a bad day · what I was like as a child · a lifelong dream · my favourite weekend · what always makes me laugh · how I've changed over the years
- wk16 (act3 Where You Come From, 2nd): a story of your grandparents' lives · where your/our name comes from · a family recipe passed down · a place in our family history · a family value I'm proud of · an elder I admire · how we mark milestones
- wk17 (act4 Our Love Story, 2nd): a small everyday thing I love about your other parent · how we support each other · a trip we took together · what we each look forward to as parents · parenting as a team · a tradition we two started · the family we're becoming
### Garbh ragas used (T2, raga-led): Bhimpalasi/aft(wk14 d93) · Bihag/night(wk14 d95) · Ahir Bhairav/morn(wk14 d97) · Patdeep/aft(wk15 d99) · Kedar/night(wk15 d101) · Gaud Malhar/eve(wk15 d104) · Madhuvanti/eve(wk16 d107) · Jaunpuri/morn(wk16 d109) · Shivaranjani/night(wk16 d111) · Bhairavi/morn(wk17 d114) · Jog/night(wk17 d116) · Rageshri/night(wk17 d118)
### T2 cadence: Garbh per wk = 3 raga / 2 affirm / 2 med. Nurture per wk = 3 food / 2 affirm / 2 breathe (food = problem-led, warm, not nutrition-science).

## Batch weeks 18-21 (T2 cont.) — wk18 hearing milestone; wk20 anchor folds in approved day-137 verbatim
### Grow used (cont.)
- wk18 (Your Baby Is Listening — sound/voice): They Can Hear You Now · Your Voice Is Their Favourite Sound · Speak, Sing, Be Heard · Words Carry Feeling · The Music You Share · A Lullaby Before Birth · Sound Becomes Memory
- wk19 (Feelings Are Welcome): All Feelings Are Allowed · Feelings Need A Witness · Big Emotions, Small People · You Can Hold The Hard Ones · Tears Are Not Trouble · Anger Has A Message · Comfort Comes Before Calm
- wk20 (Influence, Not Control; d137 ANCHOR=Children Borrow Calm From Adults): You Cannot Force A Flower · Lead, Don't Drag · The Calm Adult Wins · [d137 Children Borrow Calm From Adults] · Guidance Over Orders · Respect Grows Respect · Your Calm Is The Anchor
- wk21 (Calm Is Contagious — co-regulation): Calm Is Contagious · Be The Thermostat, Not The Thermometer · Your Peace Sets The Room · Kind Words Move More Than Loud Ones · Steady Beats Strict · Breathe First, Speak Second · The Calm You Keep, They Keep
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk18: The Ant And The Dove · The Crows And The Serpent · Krishna And The Music Of The Flute · The Crow Who Would Sing · Tenali Rama And The Royal Musician · The Magic Drum · The Song Of The Koel
- wk19: The Boy And The Nettle · The Hermit And The Mouse · Arjuna's Doubt · The Quarrel Of The Quails · Birbal And The Beggar's Bowl · The Princess Who Could Not Cry · Why The Clouds Must Rain
- wk20: The Stargazer · The Cunning Cat's Justice · The Elephant And The Robbers' Talk · [d137 Krishna And Sudama — ANCHOR, verbatim] · Tenali Rama Calms The King · The Two Gardeners · How The Gentle River Shaped The Stone
- wk21: The Hares And The Frogs · The Talking Cave · Yashoda's Calm Love · The Ox Who Pulled For Kind Words · Birbal And The Panic In The Court · The Fisherman Who Stayed Calm · The Eye Of The Storm
### Talk prompts (cont.) — 2nd pass, acts 5-8 (d137 talk FIXED from legacy)
- wk18 (act5 Hopes & Dreams, 2nd): a hope for their health & joy · a skill to nurture · who I hope you're kind to · a dream for your curiosity · an adventure to give you · how I hope you face hard times · a hope for who you love one day
- wk19 (act6 Lessons, 2nd): handling anger · what sadness taught me · about forgiveness · what patience taught me · about honesty · what disappointment taught me · about starting over
- wk20 (act7 The World, 2nd): the languages of our world · a tradition you'll grow in · a problem I'm hopeful about · nature & animals to show you · the music of our world · how people help each other · the wonder of everyday life
- wk21 (act8 Little Joys, 2nd): a comfort food I'll make · a bedtime ritual I imagine · a silly family thing · a holiday to share · a calming place I'll take you · a song to soothe you · a small daily joy
### Garbh ragas used (cont.): Brindavani Sarang/aft(wk18 d121) · Marwa/eve(wk18 d123) · Malkauns/night(wk18 d125) · Gunkali/morn(wk19 d127) · Multani/aft(wk19 d129) · Darbari Kanada/night(wk19 d132) · Tilak Kamod/eve(wk20 d135) · Yaman/eve(wk20 d137 ANCHOR) · Jaijaivanti/eve(wk20 d139) · Basant/eve(wk21 d142) · Hameer/eve(wk21 d144) · Adana/night(wk21 d146)

## Batch weeks 22-24 (T2 cont.) — boundaries/discipline/resilience; Talk tuned to weekly theme
### Grow used (cont.)
- wk22 (Boundaries With Love): Boundaries Are A Form Of Love · Limits Make Them Feel Safe · Kind And Firm Can Coexist · A 'No' Can Be Gentle · Structure Is Security · Loving Does Not Mean Always Yes · Consistency Is Comfort
- wk23 (Teaching, Not Punishing): Discipline Means To Teach · Behind Every Behaviour Is A Need · Connect Before You Correct · Punishment Ends, Teaching Lasts · Mistakes Are Not Misbehaviour · Calm Correction Sticks · Repair, Don't Shame
- wk24 (Mistakes Help Us Grow): Mistakes Are How We Grow · Failing Is Part Of Learning · Let Them Try And Stumble · The Gift Of A Second Try · Praise The Effort, Not Just The Win · Safe To Fail, Safe To Grow · Every Expert Was Once A Beginner
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk22: The Dog In The Manger · The Lapwing And The Sea · Bhishma's Vow · The Foolish Gardener Monkeys · Birbal Settles The Boundary · The King's Garden Wall · The Riverbanks That Held The Flood
- wk23: The Fox And The Crow · The Monkey And The Wedge · Yudhishthira And The Yaksha's Questions · The Archery Teacher's Test · Tenali Rama And The Boastful Pundit · The Two Teachers · The Gardener And The Young Sapling
- wk24: The Bear And The Beehive · The Monkey Who Rang The Bell · Drona And The Bird's Eye · The Young Elephant's First Steps · Birbal And The Spilt Milk · The Young Potter's First Pot · The Sapling That Grew Through Rock
### Talk prompts (cont.) — tuned to weekly Grow theme
- wk22 (Promises, 2nd): set loving limits · be consistent · keep my own calm · apologise & repair · protect your spirit · make our home safe · grow alongside you
- wk23 (Things I Want You To Know): it's okay to make mistakes · you are loved unconditionally · asking for help is strength · kindness beats winning · your feelings are valid · you needn't be perfect · I'll always believe in you
- wk24 (Lessons from my own mistakes): a mistake that taught me most · how I forgave myself · a failure that led to good · what trying again taught me · a time I was wrong and grew · patience with myself · a lesson I'm still learning
### Garbh ragas used (cont.): Shree/sunset(wk22 d149) · Chandrakauns/night(wk22 d151) · Puriya/sunset(wk22 d153) · Hindol/morn(wk23 d155) · Shankara/night(wk23 d157) · Kalavati/night(wk23 d160) · Nand/night(wk24 d163) · Maru Bihag/eve(wk24 d165) · Tilang/eve(wk24 d167)

## Batch weeks 25-27 (closes Trimester 2) — independence / imagination / gratitude
### Grow used (cont.)
- wk25 (Room To Grow — independence): Let Them Do It Themselves · Confidence Is Built, Not Given · The Space To Try · Help Less, Trust More · Struggle Is Not Suffering · Small Freedoms, Big Growth · Step Back To Let Them Rise
- wk26 (The Magic Of Imagination): Imagination Is Intelligence At Play · A Cardboard Box Is A Universe · Pretend Is Practice For Life · Wonder Needs No Screen · Daydreams Are Not Wasted Time · Stories Build Inner Worlds · Let Them Make-Believe
- wk27 (Savour The Moments — gratitude, closes T2): These Days Are The Good Old Days · Savour, Don't Just Survive · Gratitude Changes The Day · The Ordinary Is The Extraordinary · Be Where Your Feet Are · Notice The Small Wonders · Halfway, And Wholly In Love
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk25: The Eaglet's First Flight · The Two-Headed Bird · Lava And Kusha · The Deer Who Learned The Forest Ways · Tenali Rama And The Wise Dolls · The Young Weaver's Own Design · The Stream That Found Its Way
- wk26: The Boy Who Painted The Wind · Castles In The Air · The Universe In Krishna's Mouth · The Painter And The Painted Door · Birbal And The Picture Of A Story · The Magic Paintbrush · The Shapes In The Clouds
- wk27: The Town Mouse And The Country Mouse · The Four Friends · Shabari's Berries · The Monkey King's Sacrifice · Birbal And The Most Precious Thing · The Stonecutter's Wishes · The Blossom And Its Season
### Talk prompts (cont.)
- wk25 (Cheering You On): cheer loudest · celebrate tries not wins · a skill to watch you master · your safe place to fall · the independence I hope you find · proud just watching · trust you to find your way
- wk26 (Imagining You): your laugh · games I dream of · stories I'll make up · an adventure we'll imagine · who I wonder you'll be · the world we'll build in play · a daydream about you
- wk27 (Gratitude For You): grateful you chose us · the joy you've brought · a moment I'm savouring · most thankful today · how you've changed my heart · the gift of these months · how loved you are, halfway here
### Garbh ragas used (cont.): Deshkar/morn(wk25 d170) · Gavti/eve(wk25 d172) · Bhinna Shadja/night(wk25 d174) · Shuddh Sarang/aft(wk26 d176) · Lalit/dawn(wk26 d178) · Sohni/late-night(wk26 d181) · Bahar/spring(wk27 d184) · Gurjari Todi/morn(wk27 d186) · Kirwani/eve(wk27 d188)

## Batch weeks 28-31 (TRIMESTER 3 begins) — Roots & Values; Garbh meditation-led (3m/2r/2a), Nurture breathe-led (3b/2f/2a); wk28+ Movement check-in in UI
### Grow used (cont.)
- wk28 (Roots & Belonging): Where You Come From Matters · Belonging Is A Gift · Roots Give Wings · You Carry Generations · Home Is A Feeling · Know Your Story · A Place To Always Return
- wk29 (Values Are Lived, Not Lectured): Values Are Lived, Not Lectured · Honesty Starts At Home · Kindness Is Taught By Kindness · What You Tolerate, You Teach · Integrity In The Small Things · Generosity Is Learned At The Table · Character Over Achievement
- wk30 (The Stories We Carry): Every Family Has A Story · Tell Them Where They Began · Stories Are How We Remember · The Past Lives In Us · Pass Down The Good · Names Carry Meaning · Memory Is A Kind Of Love
- wk31 (Raising With Meaning): Raise Them With Meaning · Wonder Is A Doorway To Faith · Gratitude Is A Family Habit · Teach Them To Look Up · Purpose Over Possessions · The Sacred In The Ordinary · What Truly Lasts
### Story titles used (cont.) — rotation: universal · Panchatantra · epic/Krishna · Jataka · wit · folk · nature
- wk28: The Acorn's Dream · The Wise Bird And The Foolish Monkeys · Krishna's Two Mothers · The Elephant Who Remembered · Birbal Finds The True Heir · The Swallows Who Came Home · The Seed And The Forest
- wk29: The Wolf In Sheep's Clothing · The Sparrow And The King's Justice · King Harishchandra's Promise · The Honest Merchant And The Greedy One · Tenali Rama And The Honest Thief · The King Who Loved Gold · The Generous Spring
- wk30: The Storyteller Of The Village · The Clever Parrot's Stories · Ganesha Writes The Great Story · The Old Deer's Lessons · Birbal And The Never-Ending Story · The Quilt Of Memories · The Rings Of The Old Tree
- wk31: The Three Stonecutters · The Bird Who Chose Freedom · Krishna's Counsel On Duty · The Monkeys Who Chased The Moon · Birbal On True Riches · The Fisherman And The Rich Merchant · The Tree That Bowed With Fruit
### Talk prompts (cont.)
- wk28 (Where You Belong): the family you're born into · grandparents' love · the home waiting · where we come from · a place that feels like home · the community that'll know you · how you already belong
- wk29 (Values I'll Live For You): why honesty matters · kindness I'll model · how I'll show respect · valuing effort · generosity to see · owning my mistakes · the character I hope you build
- wk30 (Our Family Stories): a grandparents' story · how our families met · a family legend · where your name comes from · a tradition to share · a childhood memory · the story of how you came to be
- wk31 (What I Hope You'll Treasure): what truly matters · the wonder to never lose · why gratitude matters · a simple joy to treasure · what I find meaningful · the kind of rich to become · finding peace within
### Garbh ragas used (cont., T3): Bhatiyar/dawn(wk28 d191) · Jhinjhoti/eve(wk28 d194) · Gorakh Kalyan/eve(wk29 d199) · Pahadi/eve(wk29 d202) · Chhayanat/eve(wk30 d204) · Kamod/eve(wk30 d208) · Puriya Kalyan/eve(wk31 d212) · Saraswati/eve(wk31 d216)
### T3 cadence: Garbh per wk = 3 meditation / 2 raga / 2 affirm (meditation-led). Nurture per wk = 3 breathe / 2 food / 2 affirm (breathe-led; calm, rest, birth-prep). Tone = grounding, preparing-to-meet.
