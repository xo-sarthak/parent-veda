// =============================================================================
//  Weekly Articles — short, week-relevant reads for the "This week's reads"
//  carousel in the weekly flow (mother + father). Mirrors the weekly-videos
//  pattern. Week 21 is seeded as the prototype; add more weeks the same way.
//  (English for now — a prototype; can move to LocalizedText later.)
// =============================================================================

class WeekArticle {
  const WeekArticle({
    required this.week,
    required this.emoji,
    required this.title,
    required this.readMins,
    required this.body, // paragraphs separated by a blank line (\n\n)
  });

  final int week;
  final String emoji;
  final String title;
  final int readMins;
  final String body;
}

const List<WeekArticle> kWeekArticles = [
  // ---- Week 20 (the app's default view) -------------------------------------
  WeekArticle(
    week: 20,
    emoji: '🎉',
    title: "You're halfway there",
    readMins: 3,
    body:
        "Week 20 — you've reached the halfway mark. It's a lovely moment to pause and take it in: from a single cell to a fully-forming little person, in just twenty weeks.\n\n"
        "Your baby is now around the length of a banana — roughly 25 cm from head to heel — and weighs about 300 grams. Fine hair, tiny eyebrows, and even the ridges of fingerprints are forming. They're swallowing small amounts of amniotic fluid, practising for feeding, and settling into cycles of sleep and wakefulness.\n\n"
        "For you, this is often the most comfortable stretch of pregnancy — the early tiredness has usually eased, and the bump is proudly showing but not yet heavy. Enjoy it. Take the photo, note how you feel; halfway is worth marking.",
  ),
  WeekArticle(
    week: 20,
    emoji: '🩺',
    title: 'The anatomy scan, explained',
    readMins: 4,
    body:
        "Around now, most mothers have their mid-pregnancy scan — often called the anatomy or anomaly scan. It's usually the most detailed look at your baby in the whole pregnancy, so it's normal to feel both excited and a little nervous.\n\n"
        "During it, the sonographer checks your baby's growth and carefully examines the developing organs — the heart, brain, spine, kidneys and more — along with the placenta, the fluid around the baby, and the umbilical cord. It's a thorough, reassuring check that everything is coming along as expected. In many places this is also the scan where you can find out the baby's sex, if you'd like to.\n\n"
        "It can take a while, and the sonographer may go quiet as they concentrate — that's routine, not a warning sign. Bring your partner if you can; it's a special one to share. And if the results raise any questions, your doctor will walk you through them — that's exactly what they're there for.",
  ),
  WeekArticle(
    week: 20,
    emoji: '🍎',
    title: 'Eating well in the second trimester',
    readMins: 4,
    body:
        "If your appetite is bouncing back after the queasy early weeks, you're right on time. The second trimester is when many mothers feel more like themselves again — and when your baby is growing fast, so good nourishment matters more than ever.\n\n"
        "A few things your body especially needs now: iron, to build your baby's blood supply and keep your energy up (lentils, leafy greens, dates, and lean meat if you eat it); calcium, for those developing bones (milk, yoghurt, paneer, ragi, sesame); and some protein at most meals to support all that growth. Keep water close by — staying hydrated eases many second-trimester niggles.\n\n"
        "You don't need to \"eat for two\" in quantity — just aim for steady, varied, colourful meals. If heartburn creeps in, smaller and more frequent meals help more than large ones. And if you follow a specific diet or have any condition, your doctor or a nutritionist can help you tailor this to you.",
  ),
  // ---- Week 21 (prototype) --------------------------------------------------
  WeekArticle(
    week: 21,
    emoji: '👂',
    title: 'Your baby can hear you now',
    readMins: 3,
    body:
        "Around this week, your baby's hearing is coming alive. The tiny bones and nerves that carry sound have formed enough to pick up noises from the world around them — and the one they hear most clearly is you.\n\n"
        "Inside, it's far from silent. Your baby is surrounded by the steady thump of your heartbeat, the rush of blood, the gurgle of digestion, and — muffled but real — the sound of your voice. Over the coming weeks they'll begin to recognise it, which is why newborns so often calm at the very voice they heard before birth.\n\n"
        "You don't need to do anything special. Talk about your day, read a few lines aloud, hum a song you love. It all reaches them — and it's the start of a conversation that lasts a lifetime.",
  ),
  WeekArticle(
    week: 21,
    emoji: '🦶',
    title: 'Those first flutters and kicks',
    readMins: 3,
    body:
        "Somewhere around now, many mothers feel their baby move for the first time — a moment called \"quickening.\" It rarely feels like a kick at first. Most describe it as bubbles, a flutter, a little pop, or even the feeling of gas — easy to miss, and easy to fall in love with once you notice it.\n\n"
        "Early movements come and go without any pattern, and that's completely normal this week. Your baby is small and has plenty of room, so they may be busy one hour and still the next. If this is your first pregnancy, it can take a little longer to recognise the feeling — don't worry if a friend felt it sooner.\n\n"
        "As the weeks pass, those flutters grow into unmistakable kicks and rolls. For now, simply enjoy them. And if you ever notice a clear change in your baby's usual movements later in pregnancy, check in with your doctor or midwife — they'd always rather you asked.",
  ),
  WeekArticle(
    week: 21,
    emoji: '🍎',
    title: 'Eating well in the second trimester',
    readMins: 4,
    body:
        "If your appetite is bouncing back after the queasy early weeks, you're right on time. The second trimester is when many mothers feel more like themselves again — and when your baby is growing fast, so good nourishment matters more than ever.\n\n"
        "A few things your body especially needs now: iron, to build your baby's blood supply and keep your energy up (lentils, leafy greens, dates, and lean meat if you eat it); calcium, for those developing bones (milk, yoghurt, paneer, ragi, sesame); and some protein at most meals to support all that growth. Keep water close by — staying hydrated eases many second-trimester niggles.\n\n"
        "You don't need to \"eat for two\" in quantity — just aim for steady, varied, colourful meals. If heartburn creeps in, smaller and more frequent meals help more than large ones. And if you follow a specific diet or have any condition, your doctor or a nutritionist can help you tailor this to you.",
  ),
];

/// Articles relevant to [week] (empty if none — the carousel hides itself).
List<WeekArticle> weekArticlesFor(int week) =>
    kWeekArticles.where((a) => a.week == week).toList();
