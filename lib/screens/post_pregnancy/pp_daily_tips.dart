// =============================================================================
//  Daily parenting tips - a small rotating set, now the app-open pop-up
// -----------------------------------------------------------------------------
//  One gentle, doable tip changing each calendar day (indexed by day-of-year, so
//  it's stable within a day and rotates on its own). Hand-authored, warm, and
//  never preachy. A real engine would personalise by the child's age/leap; this
//  is a solid seeded set.
//
//  MOVED FROM A SECTION TO A POP-UP in the parenting review. It used to sit on
//  the My Child page above the video; that section is gone (its call site is
//  commented out in my_child_screen.dart) and the same content now arrives once
//  a day when the app opens, where it can be saved and shared.
//
//  TWO FIELDS ADDED, because the review asked for "an actionable tip with a
//  scientific reason (referring to a study)":
//
//    why     what is actually going on - one plain sentence, no jargon
//    source  where that comes from
//
//  HOW `source` IS WRITTEN, and why it is deliberately not a citation.
//
//  These name a real, well-established body of work at the level a parent could
//  go and check ("Tronick's still-face experiments") and NOT a specific paper
//  with a year and a journal. A precise-looking citation that turns out not to
//  exist is worse than none at all: it is the one kind of error a reader cannot
//  catch, and this is health-adjacent content aimed at people who will believe
//  it. So - real named work, honestly unspecific about the exact reference.
//
//  Before launch these want a clinician's read, and the pop-up says out loud
//  that they are general guidance and not advice about one particular child.
//  Recorded in docs/STILL-OPEN.md.
//
//  The old two-argument constructor still works - `why` and `source` default to
//  empty and the pop-up omits those blocks - so nothing that already built a
//  DailyTip needed touching.
// =============================================================================

class DailyTip {
  const DailyTip(this.title, this.body, {this.why = '', this.source = ''});
  final String title;
  final String body;

  /// The mechanism, in one sentence a tired parent can read at 6am.
  final String why;

  /// The body of work this rests on. Named honestly - see the header.
  final String source;
}

const List<DailyTip> kDailyTips = [
  DailyTip('Narrate the ordinary',
      'Talk through whatever you\'re doing — “now we\'re pouring the water”. To him it\'s music, and it\'s wiring his brain for language long before words.',
      why: 'How many words a baby hears in the early years tracks closely with '
          'the size of their vocabulary later. Ordinary running commentary '
          'counts — it does not have to be teaching.',
      source: 'Hart & Risley\'s work on early language exposure, and the '
          'research that followed it on conversational turns'),
  DailyTip('Pause before you rush in',
      'When he stirs at night, wait a slow two minutes. Many babies are just surfacing between sleep cycles and will resettle on their own.',
      why: 'Sleep runs in cycles, with a brief surfacing between each one. '
          'Going in during that window can wake a baby who was already on the '
          'way back down.',
      source: 'Established infant sleep-architecture research'),
  DailyTip('End tummy time happy',
      'Scoop him up while he\'s still content, not mid-grumble. Ending on a high makes the next session far easier.',
      why: 'What anyone remembers of an activity is weighted towards how it '
          'ended. Stopping early keeps the association a good one.',
      source: 'Paediatric tummy-time guidance, plus the peak-end effect in '
          'memory research'),
  DailyTip('Get down to his level',
      'Lie on the floor face-to-face for a few minutes. Your face is the most interesting thing in his world right now.',
      why: 'Newborns see most clearly at roughly the distance to a parent\'s '
          'face while feeding, and they prefer faces to almost anything else '
          'from the first days.',
      source: 'Classic infant visual-preference studies (Fantz and after)'),
  DailyTip('Name the feeling',
      'When he\'s upset, put words to it — “you\'re so frustrated”. Naming feelings, even now, slowly builds the brain that will manage them.',
      why: 'Putting a word to a feeling reliably takes some heat out of it. A '
          'small child cannot do that for himself yet, so you do it for him — '
          'thousands of times.',
      source: 'Affect-labelling research on emotion regulation'),
  DailyTip('Follow his gaze',
      'Notice what he\'s looking at and talk about it. Sharing his focus, rather than redirecting it, is how curiosity grows.',
      why: 'Words stick far better when they land on something the child had '
          'already chosen to look at. Naming what you find interesting teaches '
          'much less.',
      source: 'Joint-attention research in early language development'),
  DailyTip('One slow breath',
      'When he fusses, slow your own breathing first. He can\'t calm himself yet — he borrows your calm.',
      why: 'Babies regulate against an adult\'s state long before they can '
          'regulate their own. Being soothed thousands of times is how '
          'self-soothing is eventually built.',
      source: 'Co-regulation research; Tronick\'s still-face experiments'),
  DailyTip('Leave room for his reply',
      'After you say something, pause. That little silence invites him to “answer” with a coo, and teaches the rhythm of conversation.',
      why: 'Back-and-forth turns matter more than sheer word count. The pause '
          'is the turn you are handing him.',
      source: 'Conversational-turn research on early brain development'),
  DailyTip('Offer, don\'t force',
      'Hold a light toy at his midline and let him reach. Aiming and grasping on his own terms is what sharpens hand-eye coordination.',
      why: 'Motor skill is built by the attempt, not by the success. A reach '
          'that misses is doing the work.',
      source: 'Motor-learning research in infancy'),
  DailyTip('Keep nights boring',
      'Dark, quiet and low-key for night feeds; save the smiles and chat for daytime. It helps him learn night from day.',
      why: 'The body clock settles using light and social cues. Keeping nights '
          'dull and days bright gives it something to settle on.',
      source: 'Circadian-rhythm research on infant sleep'),
  DailyTip('A predictable wind-down',
      'The same few calm steps before sleep — dim, feed, cuddle, cot — become the cue his body learns to trust.',
      why: 'A consistent short routine before bed is one of the few sleep '
          'interventions that holds up well across studies.',
      source: 'Trials of bedtime-routine interventions in infants and toddlers'),
  DailyTip('Sing the same song',
      'Babies adore the familiar. Repeat a simple song and pause before the last word — watch him anticipate what\'s coming.',
      why: 'Anticipating what comes next is prediction — one of the first '
          'things a baby brain learns to do, and repetition is what makes it '
          'possible.',
      source: 'Infant statistical-learning research'),
  DailyTip('Let him be a little bored',
      'A few unstructured minutes on a safe mat, no toys shoved in, and he\'ll find his own hands and feet to study. That\'s real learning.',
      why: 'Self-directed attention is a skill, and it only gets practised '
          'when nobody else is directing it.',
      source: 'Research on unstructured play and the development of executive '
          'function'),
  DailyTip('Accept the help',
      'Say yes when someone offers to hold him or bring you food. Looking after yourself is part of looking after him.',
      why: 'A parent\'s own wellbeing is one of the strongest influences on '
          'how a baby fares. This is not an indulgence; it is part of the job.',
      source: 'Research on parental mental health and infant outcomes'),
];

/// Today's tip — stable within a calendar day, rotating by day-of-year.
DailyTip dailyTip() {
  final now = DateTime.now();
  final doy = now.difference(DateTime(now.year)).inDays;
  return kDailyTips[doy % kDailyTips.length];
}

/// A stable id for today's tip, so a save survives a restart.
String dailyTipId([DateTime? on]) {
  final now = on ?? DateTime.now();
  final doy = now.difference(DateTime(now.year)).inDays;
  return 'tip_${doy % kDailyTips.length}';
}

/// The plain-text form used by the share sheet.
///
/// Includes the source line: a tip forwarded to a WhatsApp group with no
/// provenance is exactly the kind of parenting advice this app exists to be an
/// alternative to.
String dailyTipShareText(DailyTip t) {
  final b = StringBuffer()
    ..writeln(t.title)
    ..writeln()
    ..writeln(t.body);
  if (t.why.isNotEmpty) {
    b
      ..writeln()
      ..writeln('Why it works: ${t.why}');
  }
  if (t.source.isNotEmpty) b.writeln('Based on: ${t.source}');
  b
    ..writeln()
    ..write('via ParentVeda — general guidance, not advice about one child.');
  return b.toString();
}
