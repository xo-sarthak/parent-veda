// =============================================================================
//  Father Read slots - "Read recommendations" tailored for the dad
// -----------------------------------------------------------------------------
//  The mother's daily reads come from kReadItems (read_next_data.dart). These
//  are the FATHER slots for the same Read-recommendations layer: week-aware
//  reads written for the dad - about her, the baby, and how to support - so the
//  Father Daily "Daily read" card surfaces real, relevant content instead of a
//  placeholder. Re-voiced from the mother set (third-person about her) plus a
//  few dad-specific pieces. English only, matching the Father screen.
// =============================================================================

import '../../models/read_item.dart';

const List<ReadItem> kFatherReadItems = [
  ReadItem(
    id: 'f_baby_hears',
    title: 'What Your Baby Can Hear at 20 Weeks',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 24,
    priority: 'high',
    reason: 'Your voice carries especially well now - here is why reading aloud matters.',
    readingTime: '3 min',
    category: 'Bonding',
    emoji: '👂',
    body:
        'Around now the tiny bones of your baby\'s inner ear finish forming, and sound begins to reach them. Your voice - lower and slower than hers - carries especially well through the body.\n\n'
        'Reading a few lines aloud each day is not sentimental; it is how your baby starts to know you before they ever see you. The rhythm matters more than the words.\n\n'
        'A minute is plenty. Pick a short story, sit close to her bump, and let your voice rise and fall.',
  ),
  ReadItem(
    id: 'f_halfway',
    title: "She's Halfway - What's Changing for Her",
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: 'Around week 20 she reaches the halfway point - here is how to show up.',
    readingTime: '4 min',
    category: 'Supporting Her',
    emoji: '🌗',
    body:
        'Around week 20 she reaches the halfway mark - a real milestone. Many mothers feel more energetic now, the bump becomes visible, and the first kicks often arrive.\n\n'
        'What she needs from you is presence, not fixes. Her body is doing enormous work, and a little practical help - a chore taken off her plate, an early night - lands bigger than grand gestures.\n\n'
        'It is also a lovely window to connect with the baby together: your voice is clear to them now, so read or talk to the bump while she rests.',
  ),
  ReadItem(
    id: 'f_anomaly_scan',
    title: 'The 20-Week Scan - How to Be There for Her',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 22,
    priority: 'high',
    reason: 'The detailed anatomy scan is around now - your presence matters.',
    readingTime: '4 min',
    category: 'Supporting Her',
    emoji: '🔍',
    body:
        'The anomaly scan, usually around weeks 18–22, is a detailed look at how your baby is developing - heart, brain, spine, limbs and organs. It takes longer than earlier scans.\n\n'
        'You can usually go with her, and your presence matters more than you think - these appointments can carry quiet anxiety. Write down any questions beforehand so neither of you forgets them in the moment.\n\n'
        'Most findings are reassuring. If anything needs a closer look, the doctor will guide the next steps calmly - your job is simply to be steady beside her.',
  ),
  ReadItem(
    id: 'f_back_ache',
    title: 'Why Her Back Aches Now - and What Helps',
    type: ReadType.article,
    weekStart: 16,
    weekEnd: 30,
    priority: 'medium',
    reason: 'Her centre of gravity is shifting - small, specific help lands big.',
    readingTime: '3 min',
    category: 'Supporting Her',
    emoji: '🤰',
    body:
        'As the bump grows, her centre of gravity shifts forward and her lower back takes the strain. By evening, it often aches.\n\n'
        'Small, specific help works best: offer a five-minute back rub, take the heavy lifting off her, and encourage her to rest on her side with a pillow for support.\n\n'
        'You do not need to solve it - just notice it before she has to ask. That noticing is its own kind of care.',
  ),
  ReadItem(
    id: 'f_first_kicks',
    title: 'Feeling the First Kicks Together',
    type: ReadType.article,
    weekStart: 18,
    weekEnd: 26,
    priority: 'medium',
    reason: 'The first movements often arrive now - a moment to share.',
    readingTime: '2 min',
    category: 'Bonding',
    emoji: '👣',
    body:
        'Around now, the first flutters and kicks often arrive. At first they are faint - easy to miss - but they grow stronger over the coming weeks.\n\n'
        'Ask her to tell you when she feels one, and rest your hand gently on her bump. It may take patience; babies often go quiet when they sense a new pressure, then start again.\n\n'
        'The first time you feel that little nudge against your palm is a moment you will remember. Do not rush it - just be there for it.',
  ),
];

int _rank(ReadItem r) => r.isHigh ? 0 : 1;

/// The single father read pick for [week] (week-relevant, high-priority first;
/// falls back to the first item so the card always has something).
ReadItem fatherReadForWeek(int week) {
  final relevant = kFatherReadItems.where((r) => r.relevantAt(week)).toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  return relevant.isNotEmpty ? relevant.first : kFatherReadItems.first;
}

/// [count] father read picks for [week], rotating by [day] so it refreshes.
List<ReadItem> fatherDailyReads(int week, int day, {int count = 3}) {
  final relevant = kFatherReadItems.where((r) => r.relevantAt(week)).toList()
    ..sort((a, b) => _rank(a).compareTo(_rank(b)));
  final pool = <ReadItem>[...relevant];
  if (pool.length < count) {
    pool.addAll(kFatherReadItems.where((r) => !pool.contains(r)));
  }
  if (pool.isEmpty) return const [];
  final n = pool.length;
  final start = day % n;
  return List.generate(count.clamp(0, n), (i) => pool[(start + i) % n]);
}
