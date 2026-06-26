// =============================================================================
//  Read to your baby — content pools (gentle pieces to read aloud)
// -----------------------------------------------------------------------------
//  Original, warm pieces for the customizable "Read to your baby" daily feed:
//  children's stories, rhymes/lullabies, and affirmations/blessings. The
//  spiritual-reading category draws from kSpiritualTraditions instead (not here).
//
//  TONE: every piece is written to be read DIRECTLY TO THE BABY — the mother is
//  speaking to her little one ("Little one…", "My darling…"). It's "read to your
//  baby", so it feels addressed to the baby, not narrated about the world.
//
//  IMPORTANT: every piece below is ORIGINAL writing. No existing or copyrighted
//  nursery rhyme, lullaby, song, poem or story is reproduced or reworded — these
//  are fresh, gentle pieces written for an expectant mother to read aloud.
// =============================================================================

/// Category keys (must match ReadToBabyStore + the customize sheet).
const String kRtbStories = 'stories';
const String kRtbSpiritual = 'spiritual';
const String kRtbRhymes = 'rhymes';
const String kRtbAffirmations = 'affirmations';

class ReadAloudPiece {
  const ReadAloudPiece(
      {required this.category, required this.title, required this.body});
  final String category;
  final String title;
  final String body;
}

const List<ReadAloudPiece> kReadAloudPieces = [
  // ---------- Children's stories (told to the baby) ----------
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Little Cloud Who Loved to Rain',
      body:
          "Little one, let me tell you about a small grey cloud that drifted over the fields, sprinkling soft rain so the flowers could drink and the rivers could sing. Everywhere it floated, the world turned a little greener. You are like that little cloud, my love — wherever you go, you will leave the world a little fresher and kinder, just by being you."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'Mira and the Sleepy Moon',
      body:
          "My darling, a little girl named Mira waved to the moon every night. One evening the moon looked tired, its glow soft and dim, so Mira whispered, \"Rest now — I'll keep watch.\" And she hummed a quiet tune until morning. One day, when I am tired, you and I will keep watch for each other too. That is what love does, sweet one."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Elephant Who Shared His Shade',
      body:
          "Sweet baby, under the hot afternoon sun a kind elephant stood beneath the only tree, and one by one he waved all the little animals into his cool shade. \"There's room for everyone,\" he rumbled softly. I hope you grow up with a heart like his, little one — big enough to make room for everyone you meet."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Smallest Seed',
      body:
          "Little one, in a corner of the garden lay the tiniest seed, sure it was far too small to matter. But the rain came, and the sun came, and slowly it pushed up a single green leaf — until one morning it was the tallest sunflower of all. You are small right now too, my love, but oh, how wonderfully you are growing."),
  ReadAloudPiece(
      category: kRtbStories,
      title: "Bunny's Lost Button",
      body:
          "My love, a little bunny once lost the button from her coat, and all her friends helped her look — the birds, the beetles, even the breeze, lifting the leaves. At last they found it shining in the grass. \"Thank you, friends,\" said Bunny. One day you'll have friends like that, little one, and a family who is always here to help you."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Star That Came to Visit',
      body:
          "Sweet baby, one night a tiny star slipped down to see the world up close. It tiptoed past sleeping flowers and quiet streams, marvelling at how soft the night could be. \"What a gentle place,\" it twinkled, and shone a little brighter ever after. The world is waiting to show you all its gentle wonders, my darling."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The River and the Stone',
      body:
          "Little one, a round little stone sat in the middle of a river, worried it was in the way. But the water simply sang around it, and over the years made it smooth and beautiful. \"We are better together,\" laughed the river. You and I are like that too, my love — gentler, and stronger, together."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'Little Owl Learns to Wait',
      body:
          "My darling, a little owl wanted to fly before her wings were quite ready. \"Soon,\" said her mother, tucking her close. Each night she grew a little stronger, until one evening she lifted into the sky all on her own. There's no hurry, little one — I'm holding you close, and your day to soar will surely come."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Kind Little Boat',
      body:
          "Sweet baby, a small wooden boat carried anyone who needed to cross the pond — the duck, the frog, the careful little mouse. It was never the fastest or the grandest, but it was always there. \"Slow and kind gets everyone home,\" it creaked happily. May you always be that kind, my love."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'Mango for Everyone',
      body:
          "Little one, a monkey once found one perfect mango at the very top of the tree. He could have kept it all, but instead he called his friends and shared it slice by slice. The mango was small, but the laughter was big. \"Shared sweetness tastes the best,\" he grinned — and one day, my love, I think you'll agree."),
  ReadAloudPiece(
      category: kRtbStories,
      title: "The Firefly's Little Light",
      body:
          "My darling, a firefly felt its glow was far too small to matter in the wide dark night. But a lost beetle followed that tiny light all the way safely home. \"Even the smallest light can lead someone,\" said the beetle. Your light is small and new, little one, but already it has lit up my whole world."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'Tortoise Takes His Time',
      body:
          "Sweet baby, while everyone rushed past, a tortoise walked slowly along the path, noticing the dewdrops and the singing birds. He arrived last, but he had seen the most beautiful morning of all. \"The world is lovely when you take your time,\" he smiled. Take your time, my love — we have all the time we need."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Blanket of Stars',
      body:
          "Little one, when night fell, the sky pulled a soft blanket of stars over the sleeping world. The mountains grew quiet, the oceans grew calm, and every little creature curled up safe and warm. \"Goodnight, world,\" whispered the sky. And goodnight to you, my darling — safe, and warm, and so very loved."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'Pip the Curious Sparrow',
      body:
          "My love, a little sparrow named Pip longed to see what lay beyond the garden wall. He flew a little farther each day — past the pond, past the field — then returned each evening to tell his family all about it. The world is big and wonderful, little one, and no matter how far you go, home will always be here for you."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Two Little Streams',
      body:
          "Sweet baby, two little streams trickled down the hillside, each one all alone. When they finally met in the valley, they became a wide, happy river, strong enough to turn the old mill wheel. \"Together we can do so much,\" they sang. You are never alone, my darling — we will flow through this life together."),
  ReadAloudPiece(
      category: kRtbStories,
      title: 'The Gentle Giant',
      body:
          "Little one, deep in the forest lived a giant so big that birds nested in his hair. Yet he moved so softly he never startled a deer or crushed a single flower. \"Big hearts step gently,\" he would say. May you grow a heart that big and that gentle, my love — and the whole world will feel safe beside you."),

  // ---------- Rhymes, poems & lullabies (sung to the baby) ----------
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Sleepy Time Song',
      body:
          "The candle's low, the night is deep,\nThe little birds have gone to sleep.\nClose your eyes and softly rest,\nMy darling, held against my chest."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Counting Stars',
      body:
          "One little star to wish you goodnight,\nTwo little stars, so soft and bright.\nThree little stars above the tree,\nFour little stars to watch over thee."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: "The Rain's Lullaby",
      body:
          "Pitter, patter, gentle rain,\nTapping soft on the window-pane.\nSleep, my love, so calm and slow,\nOff to dreamland we will go."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Tiny Toes',
      body:
          "Ten tiny toes and ten tiny fingers,\nA soft little nose where your sweet smile lingers.\nTwo little ears and one sleepy yawn —\nDream, little darling, until the dawn."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Moonbeam Boat',
      body:
          "Climb aboard the moonbeam boat,\nAcross the quiet sky we'll float,\nPast the clouds so soft and white —\nSail with me, my love, tonight."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: "The Garden's Asleep",
      body:
          "The roses nod, the daisies fold,\nThe evening turns from blue to gold.\nThe garden's tucked in, snug and deep,\nAnd so, my love, it's time to sleep."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Whispering Wind',
      body:
          "The wind goes whispering through the trees,\nA soft and sleepy, swaying breeze.\nIt hums a tune both low and sweet —\nA lullaby for your tiny feet."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'My Little Wonder',
      body:
          "Of all the wonders, big and small,\nYou are the dearest one of all.\nThe stars may shine, the oceans roll,\nBut you, my love, light up my whole."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Cradle of Leaves',
      body:
          "In a cradle made of leaves,\nRocked by gentle evening breeze,\nThe little bird tucks in its head —\nAnd you, my love, in your soft bed."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Slow the Day',
      body:
          "Slow the day and dim the light,\nSoft the blanket, warm and tight.\nThe world says hush, the stars agree —\nSleep, my love, so peacefully."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Tiny Heartbeat',
      body:
          "Your tiny heartbeat, soft and true,\nBeats its little song just for you.\nDrum, drum, drum, so steady and small —\nThe sweetest sound I know at all."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Dreamland Train',
      body:
          "All aboard the dreamland train,\nDown the soft and sleepy lane,\nChugging slow past fields of sheep —\nOff we go, my love, to sleep."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: "Bumble's Lullaby",
      body:
          "The busy bee has flown back home,\nNo more across the fields to roam.\nIt folds its wings, begins to hum —\nSleep now, my love, till morning's come."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Snug as Can Be',
      body:
          "Snug as a pea in a cosy pod,\nSafe as a seed in the warm soft sod,\nTucked away where the world is mild —\nSleep, my dear, my little child."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'The Sleepy Sea',
      body:
          "The waves roll in, then roll away,\nThey've sung their songs throughout the day.\nNow soft and slow they kiss the shore\nAnd whisper, \"sleep, my love,\" once more."),
  ReadAloudPiece(
      category: kRtbRhymes,
      title: 'Goodnight, Everything',
      body:
          "Goodnight to the hills, goodnight to the streams,\nGoodnight to the world and all of its dreams.\nGoodnight to the stars and the silvery moon —\nGoodnight, my love, I'll hold you soon."),

  // ---------- Affirmations & blessings (spoken to the baby) ----------
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'You are loved',
      body:
          "Little one, you are already so deeply loved. Before your first breath, before your first cry, you are wanted, treasured and adored."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Grow gently',
      body:
          "Take your time, my darling. Grow strong and grow gently — there is no rush at all. We will be right here, waiting with open arms."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'You are safe',
      body:
          "You are warm, you are held, you are safe. Wherever this journey takes us, you will never be alone."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'A wish for joy',
      body:
          "May your days be full of laughter, your nights full of rest, and your heart full of all the love this world can hold."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Brave and kind',
      body:
          "May you grow up brave enough to follow your heart, and kind enough to look after others along the way."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Our little blessing',
      body:
          "You are our greatest blessing, the answer to wishes we hardly dared to make. Thank you for choosing us."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Sweet dreams',
      body:
          "Rest now, little one. Dream of soft skies and gentle seas, and know that you are dreamed of too."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'You are enough',
      body:
          "Just as you are, you are enough. You don't have to be anything other than exactly, wonderfully you."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'A calm heart',
      body:
          "May you carry a calm heart through the busy world, and always find your way back to peace."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'The world is waiting',
      body:
          "There is so much beauty waiting for you — sunrises and seashells, music and friends. We cannot wait to show you all of it."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Held in love',
      body:
          "Today and every day, you are held in love. It surrounds you now, and it always will."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'A wish for strength',
      body:
          "When the days are hard, may you find the strength inside you that has been there all along."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'You belong',
      body:
          "You have a place in this family and in this world. You belong, simply by being you."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Gentle beginnings',
      body:
          "May your beginning be gentle and your welcome be warm. We are getting everything ready for you."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'Loved beyond measure',
      body:
          "There is no measuring how much you are loved — it is wider than the sky and deeper than the sea."),
  ReadAloudPiece(
      category: kRtbAffirmations,
      title: 'A blessing for the journey',
      body:
          "May good health follow you, may kindness surround you, and may you always know how very loved you are."),
];

List<ReadAloudPiece> readAloudByCategory(String category) =>
    kReadAloudPieces.where((p) => p.category == category).toList();
