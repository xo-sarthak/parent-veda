// =============================================================================
//  Daily parenting tips - a small rotating set for the My Child home
// -----------------------------------------------------------------------------
//  One gentle, doable tip shown on the My Child home, changing each calendar day
//  (indexed by day-of-year, so it's stable within a day and rotates on its own).
//  Hand-authored, warm, and never preachy. A real engine would personalise by
//  the child's age/leap; this is a solid seeded set.
// =============================================================================

class DailyTip {
  const DailyTip(this.title, this.body);
  final String title;
  final String body;
}

const List<DailyTip> kDailyTips = [
  DailyTip('Narrate the ordinary',
      'Talk through whatever you\'re doing — “now we\'re pouring the water”. To him it\'s music, and it\'s wiring his brain for language long before words.'),
  DailyTip('Pause before you rush in',
      'When he stirs at night, wait a slow two minutes. Many babies are just surfacing between sleep cycles and will resettle on their own.'),
  DailyTip('End tummy time happy',
      'Scoop him up while he\'s still content, not mid-grumble. Ending on a high makes the next session far easier.'),
  DailyTip('Get down to his level',
      'Lie on the floor face-to-face for a few minutes. Your face is the most interesting thing in his world right now.'),
  DailyTip('Name the feeling',
      'When he\'s upset, put words to it — “you\'re so frustrated”. Naming feelings, even now, slowly builds the brain that will manage them.'),
  DailyTip('Follow his gaze',
      'Notice what he\'s looking at and talk about it. Sharing his focus, rather than redirecting it, is how curiosity grows.'),
  DailyTip('One slow breath',
      'When he fusses, slow your own breathing first. He can\'t calm himself yet — he borrows your calm.'),
  DailyTip('Leave room for his reply',
      'After you say something, pause. That little silence invites him to “answer” with a coo, and teaches the rhythm of conversation.'),
  DailyTip('Offer, don\'t force',
      'Hold a light toy at his midline and let him reach. Aiming and grasping on his own terms is what sharpens hand-eye coordination.'),
  DailyTip('Keep nights boring',
      'Dark, quiet and low-key for night feeds; save the smiles and chat for daytime. It helps him learn night from day.'),
  DailyTip('A predictable wind-down',
      'The same few calm steps before sleep — dim, feed, cuddle, cot — become the cue his body learns to trust.'),
  DailyTip('Sing the same song',
      'Babies adore the familiar. Repeat a simple song and pause before the last word — watch him anticipate what\'s coming.'),
  DailyTip('Let him be a little bored',
      'A few unstructured minutes on a safe mat, no toys shoved in, and he\'ll find his own hands and feet to study. That\'s real learning.'),
  DailyTip('Accept the help',
      'Say yes when someone offers to hold him or bring you food. Looking after yourself is part of looking after him.'),
];

/// Today's tip — stable within a calendar day, rotating by day-of-year.
DailyTip dailyTip() {
  final now = DateTime.now();
  final doy = now.difference(DateTime(now.year)).inDays;
  return kDailyTips[doy % kDailyTips.length];
}
