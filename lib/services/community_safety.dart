// The community's safety words, on the phone.
//
// ⚠️ A MIRROR, NOT THE RULE. The rule is `community_check_text` in
// supabase/migrations/0121_community.sql, and the server applies it to every
// post and reply whatever the phone says. This copy exists for one reason:
// the helpline has to appear WHILE she is typing, before she posts, and a
// network round-trip per keystroke is not an option.
// test/community_safety_parity_test.dart reads both lists and fails the build
// when they drift.
//
// Why the words live in code and not in a table someone can edit: CLAUDE.md
// "rules are not content". A crisis rule must not gain a network dependency
// or become a dropdown.

// CRISIS-PHRASES-START
const List<String> kCommunityCrisisPhrases = [
  'kill myself', 'killing myself', 'end my life', 'end it all', 'want to die',
  'wish i was dead', 'wish i were dead', 'suicide', 'suicidal',
  'hurt myself', 'harm myself', 'self harm', 'self-harm', 'cut myself',
  'no reason to live', "can't go on", 'cant go on', 'better off without me',
  'hurt my baby', 'harm my baby', 'mar jaungi', 'mar jaun', 'jeena nahi chahti',
];
// CRISIS-PHRASES-END

// HOLD-WORDS-START
const List<String> kCommunityHoldWords = [
  'fuck', 'fucking', 'bitch', 'bastard', 'slut', 'whore', 'cunt', 'dick',
  'motherfucker', 'retard', 'chutiya', 'chutiye', 'madarchod', 'behenchod',
  'bhenchod', 'bhosdi', 'randi', 'harami', 'kamini', 'gandu', 'lauda', 'lund',
  'porn', 'nude', 'nudes', 'sexting',
];
// HOLD-WORDS-END

String _norm(String s) =>
    s.toLowerCase().replaceAll('’', "'").replaceAll('‘', "'");

/// True when the text reads like someone may be at risk. The phone shows the
/// helplines; the server puts the post first in the moderator queue.
bool communityLooksLikeCrisis(String text) {
  final s = _norm(text);
  return kCommunityCrisisPhrases.any(s.contains);
}

/// The server's other verdict, mirrored: words, links or a phone number hold
/// a post for review. The composer uses it to say so BEFORE she posts.
String? communityHoldReason(String text) {
  final s = _norm(text);
  for (final w in kCommunityHoldWords) {
    if (RegExp('(^|[^a-z])${RegExp.escape(w)}([^a-z]|\$)').hasMatch(s)) return 'language';
  }
  if (RegExp(r'(https?://|www\.|wa\.me/|t\.me/|bit\.ly/)').hasMatch(s)) return 'link';
  if (RegExp(r'(\+?91[ -]?)?[6-9][0-9]{9}').hasMatch(s)) return 'phone';
  return null;
}

/// A helpline she can call from the post screen. Numbers are listed in
/// docs/BEFORE-LAUNCH.md to be re-checked before real users.
class CommunityHelpline {
  const CommunityHelpline(this.name, this.number, this.note);
  final String name;
  final String number;
  final String note;
}

const List<CommunityHelpline> kCommunityHelplines = [
  CommunityHelpline('Tele-MANAS', '14416', 'Free, 24 hours, in many Indian languages'),
  CommunityHelpline('iCall', '9152987821', 'Counsellors, Monday to Saturday, 10 am to 8 pm'),
  CommunityHelpline('Emergency', '112', 'If someone is in danger right now'),
];
