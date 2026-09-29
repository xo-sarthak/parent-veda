// =============================================================================
//  Your birth plan — the questions
// -----------------------------------------------------------------------------
//  The Labour prep brief marks *"Your birth plan, and how to make one"* as a
//  card and `pregnancy_journeys.dart` had removed the step that promised it,
//  with a note: *"The birth-plan tool does not exist, so the step promised a
//  page and delivered a grey card."* Decided 2026-09-11: the brief asks for
//  it, so it exists. This file is what it asks.
//
//  ---------------------------------------------------------------------------
//  ⚠️ EVERY LINE IS A PREFERENCE, NEVER AN INSTRUCTION
//  ---------------------------------------------------------------------------
//
//  Most Indian hospitals do not take birth plans, and a document that reads as
//  a list of demands gets ignored at best. So every choice below is phrased the
//  way she would say it to a doctor she likes: "I'd like…", "if it's allowed",
//  "ask about…". If a choice here could be read as telling the team what to
//  do, the wording is wrong and should be changed — not the section.
//
//  The voice, from the journey step that was removed: *"A plan is a
//  preference, not a promise. Births change, and changing yours is not a
//  failure."* That line is on the screen.
//
//  ---------------------------------------------------------------------------
//  ⚠️ CLINICAL OWNERSHIP: THIS RECORDS WHAT SHE WOULD PREFER, NOTHING MORE
//  ---------------------------------------------------------------------------
//
//  CLAUDE.md: where a clinician owns a decision we may EXPLAIN it, REMIND about
//  it, or help her PREPARE for it — never recreate or compete with it. This
//  tool is the prepare case, and it stays there by never saying which choice
//  is safer, recommended, or better. No option carries a note that leans.
//
//  Which is also why every section has a "talked this through with my doctor"
//  tick and why that tick matters more than any answer: she can write anything
//  she likes, and the thing that makes it real is the conversation.
//
//  ---------------------------------------------------------------------------
//  ⚠️ IDS ARE IDENTITY AND ARE PERSISTED — SEE `BirthPlanStore`
//  ---------------------------------------------------------------------------
//
//  Section, question and choice ids are what the store saves. Reword a label
//  freely; renaming an id silently loses every woman's answer to it, and a
//  lost answer looks exactly like a question she never answered.
// =============================================================================

enum BpKind {
  /// Exactly one choice, or none.
  single,

  /// Any number of choices.
  multi,

  /// Free text.
  text,
}

class BpChoice {
  const BpChoice(this.id, this.label);
  final String id;
  final String label;
}

class BpQuestion {
  const BpQuestion({
    required this.id,
    required this.prompt,
    required this.kind,
    this.choices = const [],
    this.hint,
  });

  final String id;

  /// The question, in her voice. Short.
  final String prompt;
  final BpKind kind;

  /// Empty for [BpKind.text].
  final List<BpChoice> choices;

  /// For text: what the box is for. Shown as a placeholder.
  final String? hint;
}

class BpSection {
  const BpSection({
    required this.id,
    required this.title,
    required this.lead,
    required this.questions,
    this.readId,
  });

  final String id;
  final String title;

  /// One line under the title saying why this section is here.
  final String lead;
  final List<BpQuestion> questions;

  /// A read that helps her decide, if there is one. Linked, never inlined.
  final String? readId;
}

/// The plan's own voice, shown on the screen and at the head of the shared
/// text.
const String kBirthPlanVoice =
    'A plan is a preference, not a promise. Births change, and changing '
    'yours is not a failure.';

final List<BpSection> kBirthPlanSections = [
  BpSection(
    id: 'who',
    title: 'Who is with me',
    lead: "The first thing the team will ask, and the hardest thing to sort "
        "out once labour has started.",
    // Added 2026-09-29: the partner read covers who Indian hospitals let in.
    readId: 'preg_labour_read_partner',
    questions: const [
      BpQuestion(
        id: 'support_person',
        prompt: 'Who would you like with you?',
        kind: BpKind.multi,
        choices: [
          BpChoice('partner', 'My partner'),
          BpChoice('mother', 'My mother'),
          BpChoice('sister', 'My sister'),
          BpChoice('friend', 'A friend'),
          BpChoice('doula', 'A doula'),
          BpChoice('undecided', 'Not decided yet'),
        ],
      ),
      BpQuestion(
        id: 'support_name',
        prompt: 'Their name and number, so the team knows who to call',
        kind: BpKind.text,
        hint: 'e.g. Rohan, 98xxx xxxxx',
      ),
    ],
  ),

  BpSection(
    id: 'pain',
    title: 'Pain relief',
    lead: "What you're thinking today. You can change your mind on the day, "
        'and most women do.',
    readId: 'preg_labour_read_pain_relief',
    questions: const [
      BpQuestion(
        id: 'pain_pref',
        prompt: 'What are you thinking, today?',
        kind: BpKind.single,
        choices: [
          BpChoice('try_without',
              "I'd like to try without, and ask if I want it"),
          BpChoice('epidural', "I'd like an epidural if it's available"),
          BpChoice('on_the_day', "I'll decide on the day"),
          BpChoice('discuss', 'I want to talk it through with my doctor first'),
        ],
      ),
    ],
  ),

  BpSection(
    id: 'labour',
    title: 'During labour',
    lead: 'Small things that are easier to say now than between contractions.',
    readId: 'preg_labour_read_options',
    questions: const [
      BpQuestion(
        id: 'mobility',
        prompt: 'Moving around',
        kind: BpKind.single,
        choices: [
          BpChoice('move', "I'd like to move and change position if I can"),
          BpChoice('bed', "I'm happy to stay in bed"),
          BpChoice('team', 'Whatever the team suggests'),
        ],
      ),
      BpQuestion(
        id: 'atmosphere',
        prompt: 'The room',
        kind: BpKind.multi,
        choices: [
          BpChoice('quiet', 'Quiet, if possible'),
          BpChoice('music', 'Music from my phone'),
          BpChoice('lights', 'Lights low'),
          BpChoice('photos', 'Photos or video, if allowed'),
        ],
      ),
      BpQuestion(
        id: 'updates',
        prompt: "Being told what's happening",
        kind: BpKind.single,
        choices: [
          BpChoice('everything', 'Tell me everything as it happens'),
          BpChoice('decisions', 'Tell me only what I need to decide'),
          BpChoice('partner_first',
              "Talk to my partner first if I'm not able to"),
        ],
      ),
    ],
  ),

  BpSection(
    id: 'csection',
    title: 'If it becomes a C-section',
    lead: 'Planned or decided during labour, a few things are still yours to '
        'ask for.',
    readId: 'preg_labour_read_c_section',
    questions: const [
      BpQuestion(
        id: 'cs_partner',
        prompt: 'My partner',
        kind: BpKind.single,
        choices: [
          BpChoice('in_theatre', 'With me in theatre, if the hospital allows'),
          BpChoice('outside', 'Waiting outside'),
        ],
      ),
      BpQuestion(
        id: 'cs_baby',
        prompt: 'The baby',
        kind: BpKind.multi,
        choices: [
          BpChoice('show', 'Show me the baby as soon as possible'),
          BpChoice('skin', "Skin-to-skin in theatre, if it's allowed"),
          BpChoice('screen', 'Lower the screen so I can see, if offered'),
        ],
      ),
    ],
  ),

  BpSection(
    id: 'after',
    title: 'Right after birth',
    lead: "The first hour goes quickly. These are worth saying beforehand.",
    readId: 'preg_labour_read_first_hour',
    questions: const [
      BpQuestion(
        id: 'skin',
        prompt: 'First minutes',
        kind: BpKind.single,
        choices: [
          BpChoice('straight_away',
              "Skin-to-skin straight away, if we're both well"),
          BpChoice('wrap_first', 'Clean and wrap first, then hand over'),
          BpChoice('none', 'No preference'),
        ],
      ),
      BpQuestion(
        id: 'cord',
        prompt: 'The cord',
        kind: BpKind.single,
        choices: [
          BpChoice('ask_wait', 'Ask about waiting a minute before clamping'),
          BpChoice('usual', 'Whatever the team does normally'),
        ],
      ),
      BpQuestion(
        id: 'cord_cut',
        prompt: 'Cutting it',
        kind: BpKind.single,
        choices: [
          BpChoice('partner', 'My partner would like to'),
          BpChoice('team', 'The team can'),
        ],
      ),
      BpQuestion(
        id: 'first_feed',
        prompt: 'First feed',
        kind: BpKind.single,
        choices: [
          BpChoice('breast', 'Help me breastfeed in the first hour'),
          BpChoice('formula', "I'm planning formula"),
          BpChoice('undecided', "Not decided. I'd like to talk to someone"),
        ],
      ),
    ],
  ),

  BpSection(
    id: 'team',
    title: 'Things the team should know',
    lead: 'Anything that would help them look after you, that they might not '
        'think to ask.',
    questions: const [
      BpQuestion(
        id: 'team_notes',
        prompt: 'In your own words',
        kind: BpKind.text,
        hint: 'Allergies, previous births, anything cultural or religious (a '
            "prayer, an item, who may come in), and the language you're most "
            'comfortable in.',
      ),
    ],
  ),
];

/// Every question on the plan, in page order.
Iterable<BpQuestion> get kBirthPlanQuestions =>
    kBirthPlanSections.expand((s) => s.questions);

BpQuestion? birthPlanQuestionById(String id) {
  for (final q in kBirthPlanQuestions) {
    if (q.id == id) return q;
  }
  return null;
}
