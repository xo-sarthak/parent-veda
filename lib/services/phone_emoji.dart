// =============================================================================
//  The phone notification's emoji: one map, every stage (2026-10-29)
// -----------------------------------------------------------------------------
//  ⚠️ THE ONE EXCEPTION TO "NO DECORATIVE EMOJI" (CLAUDE.md, recorded there
//  and in docs/CHATGPT-BRIEF.md). The user's call, on the PP 11 prototype:
//  a lock screen is a crowded list of apps, and one emoji at the END of the
//  title is how a parent tells "a vaccine" from "a tip" at a glance.
//
//  The rules, all held by `test/phone_emoji_test.dart`:
//    * phone only. Added when the notification is SCHEDULED (each store's
//      arming), never stored: the message's own title, its id and its cloud
//      row are unchanged, and Messages in the app stays plain;
//    * one per kind, at the end, after a space;
//    * NONE on the sensitive kinds: a period that came, a late period, the
//      "first check" after trying long, the two-week wait, a clinic's
//      treatment reminders, the baby's movements. A cheerful mark on those
//      reads as not listening;
//    * an age: 🎂 on a whole year, 🎉 on any other; two only once, on the
//      sixth birthday (🎂🎒), the day the learning space opens.
// =============================================================================

import '../ttc/ttc_messages_store.dart' show TtcMessageKind;
import 'pp_messages_store.dart' show PpMessageKind;
import 'preg_messages_store.dart' show PregMessageKind;

/// Kind to emoji, for TTC, Pregnancy and Parenting. A kind that is not here
/// gets none, on purpose (see the header). [PpMessageKind.age] is decided by
/// [phoneEmojiFor], from the age itself.
const Map<Enum, String> kPhoneEmoji = {
  // ---- TTC ----
  TtcMessageKind.windowOpens: '🌸',
  TtcMessageKind.periodSoon: '🗓️',
  TtcMessageKind.cycleReport: '📊',
  TtcMessageKind.dayLine: '💡',
  TtcMessageKind.checkIn: '💬',
  TtcMessageKind.offer: '🛍️',
  // ---- Pregnancy ----
  PregMessageKind.newWeek: '🌸',
  PregMessageKind.dayLine: '💡',
  PregMessageKind.checkIn: '💬',
  PregMessageKind.offer: '🛍️',
  PregMessageKind.firstVisit: '🩺',
  PregMessageKind.datingScan: '🩺',
  PregMessageKind.ntScan: '🩺',
  PregMessageKind.anomalyScan: '🩺',
  PregMessageKind.glucoseTest: '🩺',
  PregMessageKind.growthScan: '🩺',
  PregMessageKind.tdap: '💉',
  PregMessageKind.hospitalBag: '🧳',
  PregMessageKind.babyArrived: '👶',
  // ---- Parenting ----
  PpMessageKind.vaccine: '💉',
  PpMessageKind.milestones: '🌱',
  PpMessageKind.activity: '🧸',
  PpMessageKind.tip: '💡',
  PpMessageKind.offer: '🛍️',
};

/// The kinds that never carry one. Listed so a test can hold that each was
/// left out on purpose, not forgotten.
const Set<Enum> kPhoneEmojiNever = {
  TtcMessageKind.periodCame,
  TtcMessageKind.lateByOne,
  TtcMessageKind.tryingLong,
  TtcMessageKind.waitStarts,
  TtcMessageKind.treatment,
  PregMessageKind.movements,
};

final RegExp _ageMonths = RegExp(r'age:m(\d+)$');

/// The emoji for a message of [kind], or '' for none. [id] is the message's
/// id, which an age message needs (`age:m24` is a whole year).
String phoneEmojiFor(Enum kind, {String id = ''}) {
  if (kind == PpMessageKind.age) {
    final m = _ageMonths.firstMatch(id);
    final months = m == null ? null : int.parse(m.group(1)!);
    if (months == 72) return '🎂🎒';
    if (months != null && months % 12 == 0) return '🎂';
    return '🎉';
  }
  return kPhoneEmoji[kind] ?? '';
}

/// [title] as the phone shows it: with the kind's emoji at the end, or as
/// it is when the kind has none.
String phoneTitle(String title, Enum kind, {String id = ''}) {
  final e = phoneEmojiFor(kind, id: id);
  return e.isEmpty ? title : '$title $e';
}
