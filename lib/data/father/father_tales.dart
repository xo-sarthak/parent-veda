// =============================================================================
//  Father Tales - "Stories, Fables & Mythology" for the Father Daily screen
// -----------------------------------------------------------------------------
//  Original, IP-safe read-aloud pieces written from the FATHER's perspective -
//  deliberately distinct from the mother's Garbh Vichara reflections. The dad
//  reads these aloud (the bump can't follow the plot yet, but it feels the rise
//  and fall of his voice), and each carries a short "From Dad" framing line.
//
//  Three kinds, 20 each:
//    • story - original short stories on presence, courage, wonder, legacy
//    • fable - original moral fables (a clear lesson)
//    • myth  - original retellings of public-domain mythology (own words)
//
//  English only, matching the Father Daily screen. Mythology underlying tales
//  are public domain; all wording here is original (no copied translations).
// =============================================================================

enum FatherTaleKind { story, fable, myth }

class FatherTale {
  const FatherTale({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.moral = '',
    this.dadNote = '',
  });

  final String id;
  final FatherTaleKind kind;
  final String title;
  final String body; // the read-aloud text
  final String moral; // fables: the lesson (one line); '' for story/myth
  final String dadNote; // a short father-perspective framing line
}

String fatherTaleKindLabel(FatherTaleKind k) {
  switch (k) {
    case FatherTaleKind.story:
      return 'Stories';
    case FatherTaleKind.fable:
      return 'Fables';
    case FatherTaleKind.myth:
      return 'Mythology';
  }
}

String fatherTaleKindTag(FatherTaleKind k) {
  switch (k) {
    case FatherTaleKind.story:
      return 'Story';
    case FatherTaleKind.fable:
      return 'Fable';
    case FatherTaleKind.myth:
      return 'Myth';
  }
}

List<FatherTale> fatherTalesOf(FatherTaleKind k) =>
    kFatherTales.where((t) => t.kind == k).toList();

/// Today's single read-aloud piece: alternates across the enabled [kinds] day
/// by day (story → fable → myth …) and rotates the piece within each kind.
/// An empty [kinds] means "a mix of all three".
FatherTale fatherTaleForDay(int day, Set<FatherTaleKind> kinds) {
  final allowed = FatherTaleKind.values
      .where((k) => kinds.isEmpty || kinds.contains(k))
      .toList();
  final kind = allowed[day % allowed.length];
  final list = fatherTalesOf(kind);
  return list[(day ~/ allowed.length) % list.length];
}

// =============================================================================
//  The library - 20 stories, 20 fables, 20 myths.
// =============================================================================
const List<FatherTale> kFatherTales = [
  // ========================================================== STORIES (20) ===
  FatherTale(
    id: 'st1',
    kind: FatherTaleKind.story,
    title: 'The Lighthouse Keeper',
    body:
        "On a rocky shore stood a lighthouse, and in it lived a keeper who lit "
        "the lamp every single night. Some nights the sea was calm and no ships "
        "passed at all. \"Why bother?\" a gull once asked him. \"No one is even "
        "out there.\" The keeper smiled and lit it anyway. \"A light is not for "
        "the nights you can see the ships,\" he said. \"It is for the one night a "
        "ship needs it - and you never know which night that is.\" So he kept his "
        "light steady, year after year, for travellers he would never meet. And "
        "every sailor who found their way home in a storm owed it to a small, "
        "faithful flame that simply refused to go out.",
    dadNote:
        "I'll be your steady light, little one - lit every night, whether you "
        "think you need it or not.",
  ),
  FatherTale(
    id: 'st2',
    kind: FatherTaleKind.story,
    title: 'The Boy Who Planted a Slow Tree',
    body:
        "A boy once asked his grandfather for a tree that would grow tall in a "
        "single week. The old man only smiled and handed him a small, slow seed "
        "instead. \"This one takes a hundred years,\" he said. \"Then plant it "
        "now,\" the boy laughed, \"so it isn't even later!\" So they dug "
        "together, and watered it, and the boy visited it every spring of his "
        "life. He never saw it reach its full height - but his children climbed "
        "it, and their children rested in its shade. The best things, the "
        "grandfather had known, are the ones we begin without needing to see "
        "them finished.",
    dadNote:
        "I'm planting slow trees for you, little one - things you'll enjoy long "
        "after you've forgotten who started them.",
  ),
  FatherTale(
    id: 'st3',
    kind: FatherTaleKind.story,
    title: 'The First Word',
    body:
        "In a quiet village lived a man who collected first words - the very "
        "first sound each child ever spoke. He kept them in a little book: a "
        "giggle, a 'ba', a name. People thought it odd, until they grew old and "
        "came to him, asking to hear their own first word again. \"Why does it "
        "matter?\" a traveller asked. \"Because a first word is a door,\" the man "
        "said. \"It is the moment a person decides the world is worth talking "
        "to.\" He waited all his life for the children who hadn't spoken yet, "
        "certain that every new voice was a story the world had never heard "
        "before.",
    dadNote:
        "I can't wait to hear your first word, little one, whatever it is. I'll "
        "keep it forever.",
  ),
  FatherTale(
    id: 'st4',
    kind: FatherTaleKind.story,
    title: 'The Keeper of Names',
    body:
        "High on a hill lived a keeper who remembered every name that had ever "
        "passed through the town. When a child was born, the parents climbed to "
        "him and whispered the new name, and he would repeat it back slowly, as "
        "if tasting something precious. \"A name is a promise,\" he told them. "
        "\"It says: there will only ever be one of you, and we were waiting.\" "
        "Years later, when those children felt lost or small, they would climb "
        "the hill just to hear their own name spoken aloud - and somehow, "
        "hearing it, they remembered they belonged.",
    dadNote:
        "We chose your name carefully, and I'll say it like it matters - because "
        "it does. There will only ever be one you.",
  ),
  FatherTale(
    id: 'st5',
    kind: FatherTaleKind.story,
    title: 'The Smallest Lantern',
    body:
        "A great procession set out to cross a dark mountain, every traveller "
        "carrying a bright torch - all but a small child, who held only a tiny "
        "lantern barely brighter than a firefly. \"You'll be no help with "
        "that,\" the others said. But high on the pass a fierce wind rose and "
        "blew out every great torch at once. Only the small lantern, cupped "
        "close to the child's chest and sheltered by two careful hands, kept "
        "burning. By its little light, the whole procession found the path and "
        "came down safely. It was not the biggest light that saved them - it was "
        "the one that was guarded most gently.",
    dadNote:
        "Your light doesn't have to be the brightest, little one. It only has to "
        "be yours, and kept burning. I'll help you guard it.",
  ),
  FatherTale(
    id: 'st6',
    kind: FatherTaleKind.story,
    title: 'The River That Found the Sea',
    body:
        "A young river tumbled down from the mountains, sure it would reach the "
        "sea by nightfall. But the land was long, and it met deserts that drank "
        "it, rocks that split it, and plains that slowed it to a crawl. Many "
        "times it nearly gave up. \"Keep going,\" whispered the rain. \"You "
        "don't have to arrive all at once.\" So the river wound and waited and "
        "pressed on, gathering smaller streams as friends along the way. When at "
        "last it reached the sea, it was no longer a thin mountain trickle but "
        "something wide and deep and unstoppable - made, in the end, of "
        "everywhere it had been.",
    dadNote:
        "Your road may be longer than you'd like, little one. Keep going. Every "
        "detour is making you wider and deeper than you know.",
  ),
  FatherTale(
    id: 'st7',
    kind: FatherTaleKind.story,
    title: 'The Carpenter and the Crooked Board',
    body:
        "A carpenter's apprentice threw a crooked board onto the fire pile. "
        "\"It's bent and useless,\" he said. The old carpenter picked it up, "
        "turned it slowly in the light, and set it aside. Weeks later he built a "
        "curved doorway - the most beautiful in the town - and the crooked board "
        "fit its arch perfectly, as though it had been waiting all along. "
        "\"There is no useless wood,\" the carpenter said. \"Only wood whose "
        "purpose you haven't found yet.\" The apprentice never looked at a "
        "crooked thing the same way again.",
    dadNote:
        "If the world ever calls some part of you crooked or wrong, come find "
        "me. I'll help you see the doorway you were shaped for.",
  ),
  FatherTale(
    id: 'st8',
    kind: FatherTaleKind.story,
    title: 'The Night the Stars Went Out',
    body:
        "One strange night, the stars all dimmed at once, and the whole world "
        "held its breath in the dark. Children cried, and even grown-ups grew "
        "afraid. But in one small house, a father lit a single candle and told "
        "his frightened child, \"The stars haven't gone - they're only resting. "
        "And until they wake, we'll be each other's light.\" All night long, "
        "candle by candle, house by house, the people kept small flames burning. "
        "And when dawn came and the stars returned, they shone - people said - a "
        "little brighter, as if grateful they had not been the only light after "
        "all.",
    dadNote:
        "When your sky goes dark, I'll light a candle and sit with you until the "
        "stars come back. We'll be each other's light.",
  ),
  FatherTale(
    id: 'st9',
    kind: FatherTaleKind.story,
    title: 'Learning to Fall',
    body:
        "Before a young acrobat was ever allowed to climb the high rope, her "
        "teacher spent a whole month teaching her just one thing: how to fall. "
        "\"I came to learn to fly,\" she protested. \"You will,\" said the "
        "teacher, \"but first you must stop being afraid of the ground.\" So she "
        "fell, and rolled, and rose, a hundred times a day, until falling no "
        "longer frightened her at all. And when at last she climbed the rope and "
        "slipped, as everyone does, she landed soft and laughing - and climbed "
        "straight back up. The ones who fly highest, her teacher said, are "
        "simply the ones who've made friends with falling.",
    dadNote:
        "You're going to fall, little one - everyone does. I won't always catch "
        "you, but I'll teach you how to land, and how to climb back up.",
  ),
  FatherTale(
    id: 'st10',
    kind: FatherTaleKind.story,
    title: 'The Empty Chair Kept Warm',
    body:
        "In a small house by the road, a family always set one extra chair at "
        "the table, with a cushion and a warm bowl, though no one sat in it yet. "
        "\"Who is it for?\" a guest once asked. \"For the one still on their "
        "way,\" the mother said. \"So that when they arrive, they'll know they "
        "were expected - that there was always a place saved.\" Travellers "
        "passing through that house never forgot it: the feeling of walking in "
        "cold and tired, and finding a seat already warm, kept just for them.",
    dadNote:
        "There's a chair at our table with your name on it, already warm. You "
        "were expected, little one. You always had a place.",
  ),
  FatherTale(
    id: 'st11',
    kind: FatherTaleKind.story,
    title: "The Clockmaker's Son",
    body:
        "A famous clockmaker could build any machine to measure time, yet he was "
        "always too busy to spend it. His small son would tug his sleeve, and he "
        "would say, \"Later - I'm making something important.\" One evening the "
        "boy left a gift on the workbench: a clock with no hands at all, and a "
        "note that read, \"This one is for the time we spend together - it "
        "doesn't need counting.\" The clockmaker set down his tools, and from "
        "that day kept the handless clock above his bench, to remind him which "
        "hours were the ones that truly mattered.",
    dadNote:
        "I'll be busy sometimes, little one - but never too busy for you. Some "
        "hours don't need counting; they just need to be spent.",
  ),
  FatherTale(
    id: 'st12',
    kind: FatherTaleKind.story,
    title: 'The Boy Who Carried the Mountain',
    body:
        "A boy was told he must move a mountain of stones from one field to "
        "another before he could grow up. \"That's impossible,\" he wept. An old "
        "woman passing by said, \"Then don't move the mountain. Move one "
        "stone.\" So each morning the boy carried a single stone across the "
        "field, and each morning the mountain looked exactly the same. But years "
        "later he stood in the cleared field, looked back at the great pile he "
        "had built stone by stone, and understood: impossible things are only "
        "possible things, carried one at a time.",
    dadNote:
        "When something feels too big to face, little one, we won't move the "
        "mountain. We'll just move one stone, together, today.",
  ),
  FatherTale(
    id: 'st13',
    kind: FatherTaleKind.story,
    title: 'The Bridge Builder',
    body:
        "An old traveller crossed a deep, cold river at great difficulty, then "
        "sat down on the far bank and began to build a bridge. A younger man "
        "laughed. \"You've already crossed. You'll never need this bridge "
        "again.\" The old man kept working. \"This morning a child like you may "
        "come this way,\" he said, \"and the river will be just as deep for them "
        "as it was for me. I build for the one who comes after.\" And so the "
        "bridge stood, long after the old man was gone, carrying strangers "
        "safely over water they never even feared.",
    dadNote:
        "I'm building bridges you'll never see me build, little one - so the "
        "rivers that were hard for me will be easy for you.",
  ),
  FatherTale(
    id: 'st14',
    kind: FatherTaleKind.story,
    title: 'The Gardener Who Talked to Seeds',
    body:
        "A gardener was famous for the richest garden in the land, and people "
        "begged to know his secret. \"I talk to my seeds,\" he said simply. They "
        "laughed - until they noticed he visited each seed while it was still "
        "buried, unseen, with nothing yet to show. \"Anyone can praise a "
        "flower,\" he told them. \"I speak to them in the dark, before they've "
        "done a single thing, so they grow knowing they were loved first.\" And "
        "his garden, people swore, bloomed as though it had something to live up "
        "to.",
    dadNote:
        "I'm talking to you now, in the dark, before you've done a single thing "
        "- so you'll grow up knowing you were loved first.",
  ),
  FatherTale(
    id: 'st15',
    kind: FatherTaleKind.story,
    title: 'The Kite and the String',
    body:
        "A kite climbed high into the wind and felt the tug of the string below. "
        "\"Let me go!\" it cried. \"I could touch the clouds if you'd only "
        "release me!\" The child holding the string loosened her grip - and at "
        "once the kite tumbled, spun, and fell. She caught the string just in "
        "time and let it climb again. \"The string isn't holding you down,\" she "
        "said gently. \"It's what lets you rise.\" And the kite understood: it "
        "was not trapped by the hand that held it, but lifted - free precisely "
        "because it was not alone.",
    dadNote:
        "I'll hold your string, little one - not to keep you low, but to help "
        "you climb. And when you're ready, I'll let it run.",
  ),
  FatherTale(
    id: 'st16',
    kind: FatherTaleKind.story,
    title: 'The Old Dog and the New Pup',
    body:
        "An old farm dog watched a clumsy new pup trip over its own paws, bark "
        "at its own tail, and tumble into the water trough. The other animals "
        "snickered. But the old dog only walked beside the pup each day, slow "
        "and patient, showing it where the soft grass was, how to listen for the "
        "farmer's whistle, when to rest. He never scolded the stumbles. \"I was "
        "clumsy once too,\" he said. \"Someone walked slow for me.\" And in time "
        "the pup grew sure-footed and wise, and walked slow, one day, for a "
        "clumsy pup of its own.",
    dadNote:
        "You'll stumble, and I'll never laugh. I'll just walk slow beside you, "
        "the way someone once did for me.",
  ),
  FatherTale(
    id: 'st17',
    kind: FatherTaleKind.story,
    title: "The Fisherman's Patience",
    body:
        "A boy went fishing with his father and grew restless within minutes. "
        "\"Nothing's biting! This is boring!\" The father only smiled and kept "
        "his line in the still water. \"Fishing isn't about the fish,\" he said. "
        "\"It's about learning to be quiet enough to notice everything else.\" "
        "So the boy went quiet - and slowly began to see: the heron stalking the "
        "reeds, the dragonfly stitching the air, the morning light lying gold "
        "across the water. They caught nothing that day. It was, the boy would "
        "say long afterward, one of the best days of his life.",
    dadNote:
        "I'll teach you to fish, little one - and more than that, to sit still "
        "enough to notice the whole quiet world while you wait.",
  ),
  FatherTale(
    id: 'st18',
    kind: FatherTaleKind.story,
    title: 'The Boy and the Echo',
    body:
        "A small boy, angry one morning, ran to the edge of a valley and "
        "shouted, \"I hate you!\" Back came the voice: \"I hate you... hate "
        "you...\" Frightened, he ran to his father. \"There's a mean boy in the "
        "mountains!\" The father walked him back and said, \"Now call out "
        "something kind.\" The boy cupped his hands and shouted, \"I'm sorry! I "
        "love you!\" And the whole valley answered, warm and ringing: \"I love "
        "you... love you...\" \"The mountain only gives back what you give it,\" "
        "his father said. \"So does the world. So does a heart.\"",
    dadNote:
        "The world tends to echo what you give it, little one. Send out "
        "kindness, and listen for how it comes home to you.",
  ),
  FatherTale(
    id: 'st19',
    kind: FatherTaleKind.story,
    title: "The Watchmaker's Promise",
    body:
        "A watchmaker promised his daughter he would be home before the last "
        "bell each night, and for years he kept it - though it meant leaving "
        "fine work unfinished and rich customers waiting. \"Why turn away "
        "gold,\" they asked, \"for a child who's already asleep?\" \"Because a "
        "promise isn't kept only when it's seen,\" he said. \"She'll grow up "
        "sure of one thing: that when her father gives his word, the world "
        "itself comes second.\" And she did grow up sure of it - so sure that "
        "she gave her own word carefully all her life, and kept it the same way.",
    dadNote:
        "When I give you my word, little one, I'll keep it - even the small "
        "ones, even when no one's watching. Especially then.",
  ),
  FatherTale(
    id: 'st20',
    kind: FatherTaleKind.story,
    title: "The Stonecutter's Hundredth Blow",
    body:
        "A stonecutter struck a great boulder once, twice, fifty times, and not "
        "a crack appeared. A passer-by shook his head. \"You're wasting your "
        "strength; that stone will never break.\" The stonecutter said nothing "
        "and kept swinging. On the hundredth blow the boulder split clean in "
        "two. \"It wasn't the last blow that broke it,\" he said, wiping his "
        "brow, \"but all the ones before that no one thought were working.\" The "
        "watcher had seen only the failure. The stonecutter had trusted the "
        "unseen cracks growing quietly with every strike.",
    dadNote:
        "Most of the work that matters won't show, little one. Keep swinging. "
        "The hundredth blow only lands because of the ninety-nine before it.",
  ),

  // =========================================================== FABLES (20) ===
  FatherTale(
    id: 'fa1',
    kind: FatherTaleKind.fable,
    title: 'The Sparrow and the Storm',
    body:
        "Two sparrows built nests in the same tall tree. One spent the sunny "
        "days singing and feasting, while the other quietly carried twig after "
        "twig, weaving her nest deep and strong. \"You work too hard,\" laughed "
        "the first. \"The sun will shine forever!\" But one evening the sky "
        "turned grey, and a great wind came roaring through the branches. The "
        "careless sparrow's nest scattered like dust - while the other sat dry "
        "and safe inside her sturdy home, watching the rain. When morning came, "
        "she shared her shelter without a word, and the first sparrow never "
        "laughed at hard work again.",
    moral: 'The work we do in calm weather is what keeps us safe in the storm.',
    dadNote:
        "I'm building our nest now, before you arrive - so whatever weather "
        "comes, you'll always have somewhere safe.",
  ),
  FatherTale(
    id: 'fa2',
    kind: FatherTaleKind.fable,
    title: 'The Two Streams',
    body:
        "Two little streams trickled down opposite sides of a hill, each certain "
        "it would reach the great river first. They raced and rushed and wore "
        "themselves thin against the rocks, until both nearly dried up under the "
        "summer sun. Then a wise old willow whispered, \"Why race? Join, and "
        "you'll have water enough to reach the sea.\" Swallowing their pride, the "
        "streams wound toward each other and merged into one. Together they ran "
        "deep and strong, past the dust that had nearly stopped them, all the "
        "way to the shining river - arriving, in the end, at the very same "
        "moment.",
    moral: 'We go farther together than we ever could apart.',
    dadNote:
        "You don't have to race anyone, little one. Find the ones worth joining, "
        "and go far together.",
  ),
  FatherTale(
    id: 'fa3',
    kind: FatherTaleKind.fable,
    title: 'The Peacock and the Crow',
    body:
        "A peacock spread his dazzling tail and mocked a plain black crow. "
        "\"Look at me - a living jewel! And you? Drab as a shadow.\" The crow "
        "simply ruffled her wings and flew, high and free, over fields and "
        "rivers and far blue hills. The peacock tried to follow and could not "
        "lift his heavy, glittering tail more than a hop off the ground. \"Your "
        "beauty is lovely to look at,\" the crow called down, \"but mine carries "
        "me to the sky.\" The peacock, for once, had nothing to say.",
    moral: 'What shines on the outside is not the same as what carries you forward.',
    dadNote:
        "Don't be fooled by what only looks impressive, little one - or worried "
        "that you don't. Ask instead what gives you wings.",
  ),
  FatherTale(
    id: 'fa4',
    kind: FatherTaleKind.fable,
    title: 'The Ant Who Shared a Crumb',
    body:
        "On a cold morning a tiny ant found a single crumb and, though hungry "
        "herself, broke it in half to share with a shivering beetle by the path. "
        "\"Foolish,\" said a passing grasshopper. \"Keep it all!\" Weeks later a "
        "flood swept through the meadow and the little ant was carried off on a "
        "leaf, spinning helplessly toward the rapids. From the bank, the beetle "
        "she had fed flung out a blade of grass and pulled her to safety. \"A "
        "kindness,\" the beetle said, \"is a seed. You never know when it will "
        "grow back to shelter you.\"",
    moral: 'Kindness given quietly has a way of coming home.',
    dadNote:
        "Give what you can, little one, even when it's small. Kindness is a seed "
        "- and it grows in directions you'll never expect.",
  ),
  FatherTale(
    id: 'fa5',
    kind: FatherTaleKind.fable,
    title: 'The Tortoise Who Truly Listened',
    body:
        "The animals held a council to solve a great problem, and everyone spoke "
        "at once - the loud monkey, the proud stag, the clever fox - each in "
        "love with his own voice. Only the old tortoise stayed silent, "
        "listening. When at last she spoke, she gently wove together the one "
        "good idea hidden in each loud speech, and the council marvelled at her "
        "wisdom. \"How did you grow so wise?\" they asked. \"I didn't,\" said the "
        "tortoise. \"I only listened while you were all busy talking.\"",
    moral: 'We learn far more from listening than from waiting to speak.',
    dadNote:
        "You were born with two ears and one mouth, little one. I'll try to "
        "remember that too - especially when I'm listening to you.",
  ),
  FatherTale(
    id: 'fa6',
    kind: FatherTaleKind.fable,
    title: 'The Firefly Who Wanted to Be the Sun',
    body:
        "A little firefly grew ashamed of her tiny glow. \"What use is my speck "
        "of light next to the great golden sun?\" she sighed, and hid herself "
        "away in the day, refusing to shine. But that night the woods were "
        "caught in deep darkness, and a lost fawn could not find its mother. No "
        "sun could help in the dark - but one small firefly, coaxed out at last, "
        "lit a soft path through the trees, and the fawn followed her glow "
        "safely home. \"The sun has its hour,\" she learned, \"and I have "
        "mine.\"",
    moral: 'Your light is not too small - it is needed where the great lights cannot reach.',
    dadNote:
        "Never wish your light away because someone else's seems bigger. The "
        "dark places of this world are waiting for exactly your glow.",
  ),
  FatherTale(
    id: 'fa7',
    kind: FatherTaleKind.fable,
    title: 'The Bamboo and the Oak',
    body:
        "A proud oak laughed at the slender bamboo bending in the breeze. \"Have "
        "some backbone! I never bow to any wind.\" That night a tremendous storm "
        "tore down from the hills. The bamboo bent low, low, almost to the "
        "ground, letting the gale pass over it. The mighty oak stood stiff and "
        "proud against the wind - until, with a great groan, it cracked and "
        "crashed to the earth. In the calm morning the bamboo rose again, "
        "unbroken and green. \"There is strength in standing firm,\" it "
        "whispered, \"and a deeper strength in knowing when to bend.\"",
    moral: 'What bends in the storm often outlasts what refuses to.',
    dadNote:
        "Be strong, little one - but not so stiff you break. Sometimes the "
        "bravest thing is to bend, then rise again.",
  ),
  FatherTale(
    id: 'fa8',
    kind: FatherTaleKind.fable,
    title: 'The Woodcutter and the River',
    body:
        "A poor woodcutter dropped his only axe into a deep river and wept. The "
        "river spirit rose and offered first a golden axe, then a silver one. "
        "\"Neither is mine,\" the woodcutter said honestly, though he was poor "
        "enough to long for them. \"Mine was only worn old iron.\" Pleased by his "
        "honesty, the spirit returned his plain iron axe - and the gold and "
        "silver besides, as a gift. A greedy neighbour heard of it, threw in his "
        "own axe on purpose, and claimed the gold one as his. The river gave him "
        "nothing back at all - not even the axe he came with.",
    moral: 'Honesty may cost you something today, but it pays in ways a lie never can.',
    dadNote:
        "Tell the truth, little one, even when a lie looks like gold. What "
        "honesty earns, no one can ever take from you.",
  ),
  FatherTale(
    id: 'fa9',
    kind: FatherTaleKind.fable,
    title: 'The Elephant and the Thorn-Bird',
    body:
        "A great elephant got a sharp thorn lodged deep in his foot and could "
        "barely limp. The big animals all backed away - too busy, too important "
        "to help. But a tiny thorn-bird hopped up, worked the thorn loose with "
        "her small sharp beak, and freed him. \"How could one so small help one "
        "so great?\" the others scoffed. Seasons later, hunters set a net for "
        "the elephant in the night, and it was the little thorn-bird's shrill, "
        "frantic cry that woke him in time to escape. \"No friend is too "
        "small,\" the elephant said, \"to be the one who saves you.\"",
    moral: 'Never measure a friend, or a kindness, by its size.',
    dadNote:
        "Be kind to everyone, little one, big or small. The smallest hand is "
        "often the one that lifts you when you fall.",
  ),
  FatherTale(
    id: 'fa10',
    kind: FatherTaleKind.fable,
    title: 'The Squirrel and the Feast',
    body:
        "All autumn a squirrel gathered acorns while a careless mouse feasted "
        "and played. \"Why work when the woods are full?\" laughed the mouse. "
        "\"Eat! Enjoy!\" But winter came hard and white, and the woods went bare "
        "and silent. The shivering mouse crept to the squirrel's door, and the "
        "squirrel - who had worked and saved - opened it, and shared. \"I won't "
        "scold you,\" she said, setting out acorns. \"But come spring, gather a "
        "little while you feast. The kindest thing you can do for your future "
        "self is to think of him today.\"",
    moral: 'A little saved in good times is a kindness to the self who meets hard ones.',
    dadNote:
        "Enjoy the good days fully, little one - but tuck a little away too. "
        "Your future self is someone worth looking after.",
  ),
  FatherTale(
    id: 'fa11',
    kind: FatherTaleKind.fable,
    title: 'The Clever Mouse and the Bell',
    body:
        "The mice lived in terror of the cat, until a young one had a bold idea: "
        "\"Let's tie a bell around the cat's neck, so we'll always hear it "
        "coming!\" The mice cheered - until an old grey mouse asked quietly, \"A "
        "fine plan. Now, which of us will hang the bell?\" The cheering stopped. "
        "Not one mouse stepped forward. \"A clever idea,\" said the old mouse, "
        "\"is only worth as much as the courage to carry it out. Do not mistake "
        "the wish for the deed.\"",
    moral: 'An idea is only as good as the courage that puts it to work.',
    dadNote:
        "Dream up bold plans, little one - then be the one brave enough to act "
        "on them. Wishing and doing are different things.",
  ),
  FatherTale(
    id: 'fa12',
    kind: FatherTaleKind.fable,
    title: 'The Two Goats on the Narrow Log',
    body:
        "Two stubborn goats met in the middle of a narrow log crossing a deep "
        "ravine, each facing the other. \"Move aside! I was here first!\" "
        "bellowed one. \"Never! Move yourself!\" snapped the other. They locked "
        "horns, pushed and shoved - and both tumbled together into the rushing "
        "water below. A third goat watched from the bank, then crossed by simply "
        "lying down to let her neighbour step gently over. \"I lost a moment's "
        "pride,\" she said, shaking off the dust, \"and kept everything else.\"",
    moral: 'A little yielding can carry you across what stubbornness only sinks.',
    dadNote:
        "Standing your ground matters, little one - but so does knowing when to "
        "let someone pass. Pride is a costly bridge.",
  ),
  FatherTale(
    id: 'fa13',
    kind: FatherTaleKind.fable,
    title: 'The Caterpillar Who Was Teased',
    body:
        "A plump caterpillar inched slowly along a branch while the swift "
        "insects mocked her. \"Look at the slow, fat crawler! She'll never go "
        "anywhere!\" The caterpillar said nothing. Quietly she spun herself a "
        "small silk room and disappeared inside, and the teasing insects forgot "
        "all about her. Then one bright morning the cocoon split, and out "
        "climbed a butterfly with wings like stained glass, lifting on the "
        "breeze far above them all. \"You only saw what I was,\" she called down "
        "softly, \"never what I was becoming.\"",
    moral: 'Never judge anyone - or yourself - by an unfinished chapter.',
    dadNote:
        "If anyone mocks who you are right now, little one, remember: they can't "
        "see who you're becoming. But I can.",
  ),
  FatherTale(
    id: 'fa14',
    kind: FatherTaleKind.fable,
    title: 'The Jackal in Borrowed Colours',
    body:
        "A jackal fell into a dyer's vat and climbed out stained a brilliant "
        "blue. The other animals, having never seen such a creature, bowed and "
        "made him their king. He strutted and ruled and pretended to be "
        "something rare - until one night, hearing a distant pack, he forgot "
        "himself and howled. At once every animal knew that howl: just a jackal "
        "after all. His borrowed colours could not hide his true voice, and his "
        "little kingdom scattered, laughing. \"I might have been loved as I truly "
        "was,\" he realised too late, \"instead of feared as something I was "
        "not.\"",
    moral: 'Pretending to be more than you are costs the chance to be loved for who you are.',
    dadNote:
        "You never have to paint yourself blue to matter, little one. The real "
        "you is more than enough - and far easier to carry.",
  ),
  FatherTale(
    id: 'fa15',
    kind: FatherTaleKind.fable,
    title: 'The Bee and the Idle Drone',
    body:
        "All summer a worker bee flew from blossom to blossom while an idle "
        "drone lounged in the sun. \"You'll wear your wings out,\" the drone "
        "yawned. \"The hive will feed me anyway.\" But when the cold set in and "
        "food grew scarce, the hive could no longer spare a share for one who "
        "had given nothing. The worker bee, though, was warm and welcome, fed "
        "gladly by all. \"I didn't gather only for myself,\" she said. \"I "
        "gathered for the hive - and the hive remembers who carried it.\"",
    moral: 'What we give to those around us comes back to hold us up.',
    dadNote:
        "Do your share, little one, and a little more. The ones you help in "
        "summer are the ones who'll keep you warm in winter.",
  ),
  FatherTale(
    id: 'fa16',
    kind: FatherTaleKind.fable,
    title: 'The Hawk and the Contented Hen',
    body:
        "A hawk soared above a farmyard and sneered at a hen scratching in the "
        "dirt. \"What a small, dull life - pecking at seeds while I command the "
        "sky!\" The hen looked up calmly. \"You hunt all day, alone and hungry, "
        "and sleep with one eye open. I have warm straw, full grain, and chicks "
        "who tuck under my wing each night. Your sky is wide, friend - but my "
        "small yard is full.\" The hawk flew on, and found, somewhere over the "
        "cold hills, that he had nothing to say.",
    moral: 'A life is measured not by how high it flies, but by how full it is.',
    dadNote:
        "Don't envy anyone's sky, little one. A small life, full of warmth and "
        "the ones you love, is a rich life indeed.",
  ),
  FatherTale(
    id: 'fa17',
    kind: FatherTaleKind.fable,
    title: 'The Spider Who Began Again',
    body:
        "A spider strung her web between two reeds, and the wind tore it down. "
        "She spun it again; a deer brushed past and broke it. A third time, and "
        "the rain washed it away. A beetle watching shook his head. \"Give up - "
        "the world is against you.\" But the spider only set her first silk "
        "thread once more. By dawn her web hung perfect and jewelled with dew, "
        "catching the morning light and her breakfast besides. \"The world "
        "wasn't against me,\" she said. \"It was only seeing whether I meant "
        "it.\"",
    moral: 'Begin again often enough, and what kept stopping you finally steps aside.',
    dadNote:
        "You'll have webs torn down, little one. Spin the next thread anyway. "
        "Persistence is just love that refuses to quit.",
  ),
  FatherTale(
    id: 'fa18',
    kind: FatherTaleKind.fable,
    title: 'The Fox and the Overfull Belly',
    body:
        "A hungry fox squeezed through a narrow gap into a granary and ate, and "
        "ate, and ate, until his belly was round and tight. But when he tried to "
        "leave, he was far too full to fit back through the gap. Stuck and "
        "groaning, he had to wait, hungry and uncomfortable, until his belly "
        "shrank back to the size it had been when he came in. \"All that "
        "feasting,\" he sighed, crawling out at last, \"and I leave exactly as I "
        "arrived. Enough would have served me better than too much.\"",
    moral: 'Enough is a feast; too much is its own kind of trap.',
    dadNote:
        "Enjoy good things, little one - but know when enough is enough. More "
        "isn't always more; sometimes it just gets you stuck.",
  ),
  FatherTale(
    id: 'fa19',
    kind: FatherTaleKind.fable,
    title: 'The Owl Who Judged in Haste',
    body:
        "An owl saw a young fox digging frantically at the roots of a tree and "
        "snapped, \"Lazy, destructive creature, ruining the forest!\" and told "
        "all the animals so. But the fox had smelled smoke; he was digging a "
        "firebreak to stop a blaze creeping up the valley. By the time the owl "
        "understood, the fox had already saved a whole stretch of woodland - and "
        "the owl's hasty words. \"I judged what I saw,\" the owl admitted, "
        "ashamed, \"before I understood what I was looking at.\"",
    moral: 'Understand first; judge later - or you may scold the very one who is saving you.',
    dadNote:
        "Before you decide what someone is, little one, find out what they're "
        "doing and why. Most stories look different up close.",
  ),
  FatherTale(
    id: 'fa20',
    kind: FatherTaleKind.fable,
    title: 'The Drummer Ants',
    body:
        "A colony of ants faced a stream too wide to cross, and they pushed and "
        "scrambled in a panicked, useless crowd. Then one small ant began to tap "
        "a steady rhythm - tap, tap, tap - and the others, almost without "
        "thinking, began to move in time. Together, in rhythm, they linked legs "
        "and bodies into a living bridge and crossed the water as one. \"We were "
        "the same ants a moment ago,\" they marvelled. \"All that changed was "
        "that we moved together.\"",
    moral: 'A crowd becomes a force the moment it moves as one.',
    dadNote:
        "Alone you are strong, little one. In step with others, you can build a "
        "bridge across almost anything.",
  ),

  // ============================================================ MYTHS (20) ===
  FatherTale(
    id: 'my1',
    kind: FatherTaleKind.myth,
    title: 'The Leap of Hanuman',
    body:
        "Long ago, a mighty figure named Hanuman stood at the edge of the sea, "
        "which stretched so far that no shore could be seen on the other side. "
        "His friends needed him to cross it, but the water was endless and his "
        "heart filled with doubt. Then a wise voice reminded him of who he truly "
        "was - that strength beyond measure had always slept inside him, waiting "
        "only to be remembered. Hanuman breathed deep, grew vast as a mountain, "
        "and leapt. He flew over the whole ocean in a single bound, clearing "
        "clouds and crests, because once he believed in his own strength, "
        "nothing could hold him back.",
    dadNote:
        "One day you'll face your own ocean, little one. I'll be the voice that "
        "reminds you how strong you already are.",
  ),
  FatherTale(
    id: 'my2',
    kind: FatherTaleKind.myth,
    title: 'Abhimanyu, Who Listened in the Womb',
    body:
        "Long ago, before the brave warrior Abhimanyu was even born, his father "
        "told his mother the secret of breaking into a great spiral battle "
        "formation. Curled and listening inside her, the unborn child drank in "
        "every word - how to enter, how to fight his way in, ring by ring. But "
        "his mother drifted to sleep before the telling of how to come out "
        "again, and so the child learned only half. Years later, grown and bold, "
        "Abhimanyu broke into that very formation exactly as he had heard in the "
        "dark before his birth. Even before they are born, the old tellers said, "
        "children are listening - and what we say around them takes root.",
    dadNote:
        "You're listening to me right now, little one, long before you can "
        "understand. So I'll fill these days with words worth keeping.",
  ),
  FatherTale(
    id: 'my3',
    kind: FatherTaleKind.myth,
    title: 'Ganesha Circles His Parents',
    body:
        "Two divine brothers were set a contest: whoever could circle the whole "
        "world three times would win the prize. The swift one leapt upon his "
        "mount and sped off around the earth, sure of victory. But round little "
        "Ganesha simply walked three slow circles around his mother and father, "
        "then bowed. \"The contest was the world,\" the judges said. \"And you "
        "are my whole world,\" answered Ganesha, gesturing to his parents. He was "
        "given the prize - not for speed, but for wisdom. Sometimes the greatest "
        "journey is the small circle you make around the ones you love.",
    dadNote:
        "You don't have to race around the world to make me proud, little one. "
        "Some of the wisest journeys are the short ones, made with love.",
  ),
  FatherTale(
    id: 'my4',
    kind: FatherTaleKind.myth,
    title: 'Krishna Lifts the Hill',
    body:
        "When fierce storms came to flood a village, the people trembled, for "
        "they had always begged the sky for mercy and still the rains came. A "
        "young cowherd named Krishna told them to look instead to their own hill, "
        "which sheltered and fed them all year. Then, as the skies broke open, he "
        "lifted the entire hill upon one finger and held it high like a great "
        "umbrella, and the whole village - people, cattle, and all - sheltered "
        "beneath it, dry and safe, until the storm wore itself out. He asked for "
        "no worship, only that they remember who truly shelters them.",
    dadNote:
        "If the storms ever come for you, little one, I'll be your hill - "
        "holding the sky off you until the worst has passed.",
  ),
  FatherTale(
    id: 'my5',
    kind: FatherTaleKind.myth,
    title: 'Shravan and His Parents',
    body:
        "Long ago a devoted son named Shravan cared for his aged, blind parents, "
        "who longed to visit the holy rivers before they grew too old. Too poor "
        "for a cart, Shravan made a sling of bamboo, seated his mother and "
        "father in baskets on either end, balanced the pole across his own "
        "shoulders, and carried them on foot across forests and hills to every "
        "sacred place they wished to see. He never once complained of the "
        "weight. The old tellers held him up forever after as the very picture "
        "of a child's love - proof that the care our parents give us is meant, "
        "one day, to be gently carried back.",
    dadNote:
        "I'll carry you when you're small, little one. Whatever you do with your "
        "life, I hope you carry kindness the way Shravan did.",
  ),
  FatherTale(
    id: 'my6',
    kind: FatherTaleKind.myth,
    title: "Eklavya's Devotion",
    body:
        "A forest boy named Eklavya longed to learn archery from the greatest "
        "teacher in the land, but the master would not take him. Undefeated, "
        "Eklavya shaped a humble statue of the teacher from clay, set it before "
        "him, and practised every single day with that silent image as his "
        "guide. Through nothing but devotion and relentless effort, he taught "
        "himself a skill to rival the finest archers in any kingdom. The tellers "
        "remembered him not for any prize, for his story holds its share of "
        "sorrow - but for a truth that outshone it: a heart set fully on its "
        "purpose can teach itself almost anything.",
    dadNote:
        "If a door you knock on won't open, little one, you can still teach "
        "yourself wonders. Devotion is its own kind of teacher.",
  ),
  FatherTale(
    id: 'my7',
    kind: FatherTaleKind.myth,
    title: 'Arjuna and the Eye of the Bird',
    body:
        "A teacher set a wooden bird high in a tree and asked each young archer "
        "what he saw before he drew his bow. \"I see the tree, the branches, the "
        "leaves, the bird,\" said one. \"I see the garden and the sky,\" said "
        "another. He told them all to lower their bows. Then he came to Arjuna. "
        "\"What do you see?\" \"Only the eye of the bird,\" said Arjuna. "
        "\"Nothing else - not the tree, not the branch, not even the whole "
        "bird.\" \"Then shoot,\" said the teacher. The arrow flew true. \"That,\" "
        "he told the others, \"is what it means to truly aim.\"",
    dadNote:
        "When something matters, little one, give it your whole gaze. The world "
        "quiets, and the target comes clear, for those who truly look.",
  ),
  FatherTale(
    id: 'my8',
    kind: FatherTaleKind.myth,
    title: 'Dhruva and the Pole Star',
    body:
        "A small prince named Dhruva, turned away and told he was not worthy of "
        "his father's lap, did not sulk or rage. Instead he set off alone to "
        "seek something no one could ever take from him. With astonishing "
        "steadiness for one so young, he held to his purpose through cold and "
        "hunger and fear, refusing to be moved. So unshakable was his resolve "
        "that, the old stories say, he was lifted to the night sky and set there "
        "as the Pole Star - the one star that never wanders, around which all "
        "the others turn. Travellers have steered by his steadiness ever since.",
    dadNote:
        "Find the thing in you that won't be moved, little one, and hold it. The "
        "whole sky learns to turn around a steady heart.",
  ),
  FatherTale(
    id: 'my9',
    kind: FatherTaleKind.myth,
    title: 'Bhagiratha Brings the River',
    body:
        "A king named Bhagiratha set himself an impossible task: to bring the "
        "great heavenly river down to the parched earth to heal his people. It "
        "could not be done in a single lifetime, nor two. He gave years to it, "
        "and when he could give no more, those who came after took up his "
        "unfinished work, and those after them again, until at last the mighty "
        "river came thundering down from the heavens to bless the land - and it "
        "has flowed ever since. The tellers gave his name to any great effort "
        "carried across generations, begun by one who knew he might never see it "
        "done.",
    dadNote:
        "Some of what I begin for you, little one, I may never see finished. "
        "I'll begin it anyway. That's what fathers are for.",
  ),
  FatherTale(
    id: 'my10',
    kind: FatherTaleKind.myth,
    title: "Nachiketa's Brave Questions",
    body:
        "A boy named Nachiketa was sent, through a hasty word, to the house of "
        "Death itself. Most would have trembled. But Nachiketa waited patiently "
        "at the door for three days, and when Death returned and offered him any "
        "gift to make amends, the boy did not ask for riches or long life. He "
        "asked the hardest question of all: what truly lasts, beyond all that "
        "fades? Death tried to tempt him with treasures instead, but the boy "
        "would not be turned aside. Impressed by such courage, Death taught him "
        "the deepest wisdom - given, in the end, only because the boy was brave "
        "enough to ask.",
    dadNote:
        "Never be afraid of the big questions, little one. Ask them boldly. The "
        "bravest minds are the ones still curious in the dark.",
  ),
  FatherTale(
    id: 'my11',
    kind: FatherTaleKind.myth,
    title: "Prahlada's Unshaken Heart",
    body:
        "Young Prahlada believed quietly but completely in a goodness greater "
        "than any king, even when his powerful father forbade it and tried every "
        "threat to frighten him out of it. Through every storm of anger sent his "
        "way, the boy stayed calm and kind, never hating his father in return, "
        "simply holding to what he knew in his heart was true. In the end no "
        "force could shake him, and goodness itself, the old stories say, rose "
        "up to protect the child who had trusted it. His name became a byword "
        "for a heart that bends to no fear.",
    dadNote:
        "Hold to what you know is good, little one, even if you must hold it "
        "alone. A steady, kind heart is stronger than any threat.",
  ),
  FatherTale(
    id: 'my12',
    kind: FatherTaleKind.myth,
    title: 'Markandeya and the Gift of Time',
    body:
        "A boy named Markandeya was blessed with brilliance but destined for a "
        "very short life. As his final hour drew near, he did not despair; he "
        "gave himself wholly, with his whole heart, to what he loved and "
        "believed in. When Death came for him, the boy held so fully to the "
        "source of all life, with such pure devotion, that even Death was "
        "stayed - and the stories say the boy was granted to remain ever young, "
        "untouched by time. It is not the length of a life that makes it great, "
        "the tellers said, but the wholeness with which it is lived.",
    dadNote:
        "However long your days, little one, live them whole and bright. A life "
        "is measured by its depth, never only its length.",
  ),
  FatherTale(
    id: 'my13',
    kind: FatherTaleKind.myth,
    title: 'The Churning of the Ocean',
    body:
        "Long ago, gods and demons both wanted the nectar of life, hidden deep "
        "in the sea of milk. Alone, neither side could reach it. So - enemies "
        "though they were - they wound a great serpent around a mountain and "
        "used it as a rope, one side pulling, then the other, churning the vast "
        "ocean together for ages. Many wonders rose from the swirling waters, "
        "and at long last the nectar itself. The old tellers loved this tale for "
        "its quiet lesson: even those who pull in different directions can, by "
        "working the same rope together, bring forth something neither could "
        "have won alone.",
    dadNote:
        "Great things often need many hands, little one - even hands that "
        "disagree. Learn to pull the same rope, and oceans give up their "
        "treasure.",
  ),
  FatherTale(
    id: 'my14',
    kind: FatherTaleKind.myth,
    title: "Savitri's Resolve",
    body:
        "Savitri loved her husband so dearly that when Death came to carry him "
        "away, she would not turn back. She followed Death down the long road, "
        "step for step, speaking with such wisdom and such steady devotion that "
        "Death, impressed, offered her any boon - except her husband's life. "
        "Cleverly and lovingly, she asked for blessings that could only come "
        "true if her husband lived. Caught by her quick heart and her unbending "
        "love, Death at last relented and gave him back. Love joined to wisdom, "
        "the tellers said, can walk right up to the impossible and turn it "
        "around.",
    dadNote:
        "Love hard, little one, and think clearly while you do. A devoted heart "
        "with a quick mind can soften the hardest road.",
  ),
  FatherTale(
    id: 'my15',
    kind: FatherTaleKind.myth,
    title: 'Prometheus and the Gift of Fire',
    body:
        "In the old Greek tales, people shivered in the cold and the dark, for "
        "fire belonged only to the gods. One bold spirit named Prometheus could "
        "not bear to see them suffer. He carried a single spark down from the "
        "heavens, hidden in a hollow reed, and gave it to humankind. With it "
        "came warmth, and light, and the beginning of every craft and comfort we "
        "know. He paid dearly for his daring - but he never regretted it, for he "
        "had given a gift that would warm the world for all time. Some gifts, "
        "the tellers said, are worth any cost to the one who gives them.",
    dadNote:
        "I'd carry fire down a mountain for you, little one. There's almost "
        "nothing a father won't give to keep his child warm.",
  ),
  FatherTale(
    id: 'my16',
    kind: FatherTaleKind.myth,
    title: 'Icarus and the Wax Wings',
    body:
        "A clever maker named Daedalus built wings of feathers and wax so that "
        "he and his son Icarus could escape across the sea. \"Fly the middle "
        "path,\" he warned. \"Too low, and the sea-spray will weigh your wings; "
        "too high, and the sun will melt the wax.\" For a while they soared "
        "together. But young Icarus, drunk on the joy of flight, forgot his "
        "father's words and climbed higher and higher toward the sun - until the "
        "wax softened and he fell. The tellers kept the tale not to forbid us "
        "the sky, but to remind us that even soaring needs a steady, listening "
        "heart.",
    dadNote:
        "Fly, little one - fly high and bold. But keep a corner of your heart "
        "for the wisdom of those who've flown before you.",
  ),
  FatherTale(
    id: 'my17',
    kind: FatherTaleKind.myth,
    title: 'The Phoenix Reborn',
    body:
        "In old tales there lived a wondrous bird called the phoenix, with "
        "feathers of flame, that lived for hundreds of years. When at last its "
        "long life drew to a close, it did not simply vanish. It built a nest of "
        "fragrant branches, settled into it, and let itself be wrapped in fire - "
        "and from the ashes of what it had been, a new young phoenix rose, "
        "bright and whole, to begin again. People told the story whenever a "
        "thing seemed truly ended, to remember that some endings are only the "
        "doorway to a new beginning.",
    dadNote:
        "Endings will come, little one, even hard ones. But you carry the "
        "phoenix in you - the power to rise from the ash and begin again.",
  ),
  FatherTale(
    id: 'my18',
    kind: FatherTaleKind.myth,
    title: 'Atlas Who Held the Sky',
    body:
        "In the Greek tales there was a mighty figure named Atlas whose task it "
        "was to hold the great weight of the sky upon his shoulders, so that it "
        "would not come crashing down upon the earth. Day and night he stood, "
        "strong and steady, bearing a burden no one else could carry, asking for "
        "no praise and taking no rest. People looking up at the unbroken sky "
        "rarely thought of him at all - yet it stayed up because of him. The "
        "tellers remembered Atlas whenever someone quietly carried a great "
        "weight so that others could live easy beneath it.",
    dadNote:
        "There's a kind of strength that holds up the sky so others can live "
        "easy beneath it. I'll carry what I can, so your sky stays clear.",
  ),
  FatherTale(
    id: 'my19',
    kind: FatherTaleKind.myth,
    title: 'Anansi and the Box of Stories',
    body:
        "In the old West African tales, all the world's stories belonged to the "
        "sky-god and were locked away in a single box. A small, clever spider "
        "named Anansi longed to share them with everyone below. He could not win "
        "them by strength, for he had little - but by cleverness, patience, and "
        "a great deal of cunning, he completed the seemingly impossible tasks "
        "the sky-god set, and earned the box. Then he opened it, and the stories "
        "spilled out across the whole world, where they have lived ever since. "
        "That is why stories belong to everyone now - because a little spider "
        "thought they should.",
    dadNote:
        "Stories are for everyone, little one - and I'll fill yours with as many "
        "as I can. Cleverness and heart can unlock almost anything.",
  ),
  FatherTale(
    id: 'my20',
    kind: FatherTaleKind.myth,
    title: 'Daedalus the Maker',
    body:
        "In the Greek tales, Daedalus was the greatest maker and inventor of his "
        "age - a builder of wonders, a solver of puzzles no one else could "
        "solve. When he and his son were trapped on an island with the sea all "
        "around and no ship to take them, he did not surrender to the walls of "
        "his prison. He looked up at the birds, studied the lift of their wings, "
        "and built a way out of nothing but feathers, thread, and a bold idea. "
        "The tellers loved him as the friend of every craftsman: proof that a "
        "curious, patient maker can find a door where others see only a wall.",
    dadNote:
        "When you're hemmed in with no way out, little one, look up and make "
        "one. A patient maker's hands can build wings from almost nothing.",
  ),
];
