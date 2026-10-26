// =============================================================================
//  "Remind me before your child turns five" — the Aadhaar update reminder
// -----------------------------------------------------------------------------
//  Papers door 14 (PM5, 2026-10-26, `docs/pp-door-plans/14-papers.md`). The
//  Baal Aadhaar page said "Set a reminder for your child's fifth birthday",
//  with no way to set one. This is the way: one tap, one dated reminder.
//
//  ⚠️ NOT A `ReminderStore` REMINDER, BECAUSE THAT STORE HAS NO DATE. A
//  `Reminder` is a time of day and a repeat; `once` rings at the next hh:mm,
//  not on a day in 2031. Adding a date there is a model field, a column, a
//  migration and a sync change, for one reminder. The user's choice
//  (2026-10-26): reuse the child calendar's dated reminder, `PpApptReminders`,
//  which is phone-only like the vaccine alarms and is re-armed after every
//  launch (main.dart). The cost: it is not in her Reminders list and does not
//  follow her to a second phone.
//
//  ⚠️ DERIVE, NEVER ASK. The date is the child's own: one month before the
//  fifth birthday, from the profile. With no birth date saved there is no
//  date to derive, so the tap says why and offers to add one (S8: no silent
//  tap). A child already five, or inside that last month, gets the line that
//  the update is due now instead of a button that would set nothing.
//
//  ⚠️ A BIRTH DATE CHANGED LATER moves the reminder the next time the page is
//  drawn ([_rederive]). Not at launch: the child profiles load after the
//  alarm chain starts (main.dart), so a launch-time re-derive would race them.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_toast.dart';
import '../v2/v2_palette.dart';
import 'calendar/pp_cal_data.dart' show PpApptReminders;
import 'my_child_screen.dart';
import 'pp_child_profile.dart';

/// The words, one place each, so the test reads what the screen draws.
const String kPpAadhaarRemindLabel = 'Remind me before your child turns five';
const String kPpAadhaarDueNow =
    "The five-year update is due now. It's free at any Aadhaar centre.";
const String kPpAadhaarNoDate =
    "Add your child's birth date first, so the reminder lands on the right day.";

/// The reminder's id in [PpApptReminders], one per child.
String ppAadhaarReminderId(String childId) => 'aadhaar5_$childId';

/// The day the reminder is for: one month before the fifth birthday. A day
/// the earlier month does not have (31 March -> February) takes that
/// month's last day, never a day in the next month.
DateTime ppAadhaarReminderDate(DateTime dob) {
  final y = dob.year + 5 - (dob.month == 1 ? 1 : 0);
  final m = dob.month == 1 ? 12 : dob.month - 1;
  final last = DateTime(y, m + 1, 0).day;
  return DateTime(y, m, dob.day > last ? last : dob.day);
}

/// True once the reminder's day has come: the update is due now.
bool ppAadhaarDueNow(DateTime dob, DateTime now) =>
    !now.isBefore(ppAadhaarReminderDate(dob));

/// "12 May 2031".
String ppAadhaarDateLabel(DateTime d) {
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June', 'July',
    'August', 'September', 'October', 'November', 'December',
  ];
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

/// What a tap says once the reminder is set.
String ppAadhaarSetLine(DateTime d) =>
    "Reminder set for ${ppAadhaarDateLabel(d)}. We'll remind you a month "
    "before your child's fifth birthday.";

/// Sets the reminder for the active child. Returns the day it is for, or
/// null when there is nothing to set: no birth date saved, or the day has
/// already come.
Future<DateTime?> ppSetAadhaarReminder({DateTime? now}) async {
  final kids = ChildProfileStore.instance;
  final id = kids.activeChildId;
  if (id == null) return null;
  final t = now ?? DateTime.now();
  if (ppAadhaarDueNow(kids.dob, t)) return null;
  final day = ppAadhaarReminderDate(kids.dob);
  // `remind` rings at 7 pm the evening before the day it is given, so it is
  // given the next day: the reminder rings on [day] itself.
  final rings = await PpApptReminders.instance.remind(
    ppAadhaarReminderId(id),
    day.add(const Duration(days: 1)),
    title: "Your child's Aadhaar update",
    body: "The free five-year update is due. Book it at any Aadhaar centre "
        "before the fifth birthday.",
    now: t,
  );
  return rings == null ? null : day;
}

/// The block on the Baal Aadhaar page, under the safety callout.
class PpAadhaarReminderView extends StatefulWidget {
  const PpAadhaarReminderView({super.key, this.now});

  /// The clock, for the tests.
  final DateTime? now;

  @override
  State<PpAadhaarReminderView> createState() => _PpAadhaarReminderViewState();
}

class _PpAadhaarReminderViewState extends State<PpAadhaarReminderView> {
  DateTime? _set;

  DateTime get _now => widget.now ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    _rederive();
  }

  /// A reminder already on for this child is re-set from today's birth date,
  /// so an edited birthday moves it.
  Future<void> _rederive() async {
    final id = ChildProfileStore.instance.activeChildId;
    if (id == null) return;
    if (!PpApptReminders.instance.isOn(ppAadhaarReminderId(id))) return;
    final day = await ppSetAadhaarReminder(now: _now);
    if (mounted) setState(() => _set = day);
  }

  Future<void> _tap() async {
    final kids = ChildProfileStore.instance;
    if (!kids.hasRealChild) {
      pvToast(context, kPpAadhaarNoDate,
          action: 'Add the date',
          onAction: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'pp/my_child'),
              builder: (_) => const MyChildScreen())));
      return;
    }
    final day = await ppSetAadhaarReminder(now: _now);
    if (!mounted) return;
    if (day == null) {
      setState(() {}); // the day has come: the due-now line takes over
      return;
    }
    setState(() => _set = day);
    pvToast(context, ppAadhaarSetLine(day), kind: PvToastKind.done);
  }

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final kids = ChildProfileStore.instance;
    final line = pvManrope(
        fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.5, color: p.ink1);
    if (kids.hasRealChild && ppAadhaarDueNow(kids.dob, _now)) {
      return Text(kPpAadhaarDueNow, key: const ValueKey('pp_aadhaar_due_now'), style: line);
    }
    if (_set case final day?) {
      return Text(ppAadhaarSetLine(day), key: const ValueKey('pp_aadhaar_set'), style: line);
    }
    // One button style: ink fill, white words. Full width, and the words
    // wrap inside it rather than running off a narrow phone.
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        key: const ValueKey('pp_aadhaar_remind'),
        onPressed: _tap,
        style: FilledButton.styleFrom(
          backgroundColor: p.ink1,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          shape: const StadiumBorder(),
        ),
        child: Text(kPpAadhaarRemindLabel,
            textAlign: TextAlign.center,
            style: pvManrope(
                fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.3, color: Colors.white)),
      ),
    );
  }
}
