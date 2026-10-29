// =============================================================================
//  The partner's shared habits, read-only (T5 Q1, Wave 3 — 2026-10-29)
// -----------------------------------------------------------------------------
//  docs/preg-ttc-tool-plans/T5-body-checks.md. Five pieces, one file, because
//  each is small and they only make sense together:
//
//    · `ttcPartnerLogRows`     the pure filter the view and the test share
//    · `TtcPartnerLogView`     his (or her) shared tracker, last 4 weeks
//    · `TtcPartnerLogCard`     the way in, on the tracker page
//    · `TtcShareAskCard`       the once-only "Share your habits with her?"
//    · `TtcHerPrivateNote`     what his phone shows for her private tools (D5)
//
//  ⚠️ NEVER MERGED INTO `TtcLogStore`. The partner's rows are fetched for the
//  view and dropped with it. Merged, they would push back up under HER id,
//  and 0131's read-only policy would be the only thing between that and his
//  rows being rewritten as hers. The store pulls with `fetch` (own user); this
//  file reads with `fetchByUser` (his id). The test pins both.
//
//  ⚠️ READ-ONLY, NO STREAK, NO ALERT. Q1: she sees what he logged, and that is
//  all. Nothing here edits, counts days in a row, or tells anyone about the
//  other's entries.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_log_share_store.dart';
import '../../ttc/ttc_log_store.dart';
import '../../ttc/ttc_sync.dart' show TtcTables;
import '../../ttc/ttc_trackers_data.dart';
import '../../widgets/pv_toast.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart' show ttcLine, TtcSectionHeading;
import 'ttc_round_strings.dart' show ttcRoundDate;
import 'ttc_strings.dart' show TtcPartnerMode;
import 'ttc_tool_chrome.dart';
import 'ttc_tool_hues.dart';
import 'ttc_tracker_screen.dart' show openTtcTracker;

/// How far back the view reads, the same four weeks as "Past 4 weeks".
const int kTtcPartnerLogDays = 28;

// ---- the words ---------------------------------------------------------------

/// The ask, once, after the first save to the phone's own shareable tracker.
String ttcShareAskLine({required bool him}) => him
    ? "Share your habits with her? She'll see what you log here, and nothing "
        'else. You can change this in You.'
    : "Share your habits with him? He'll see what you log here, and nothing "
        'else. You can change this in You.';

const String kTtcShareYes = 'Share';
const String kTtcShareNo = 'Keep to myself';

/// What the answer changed, said straight after.
String ttcShareToast(bool shared, {required bool him}) => shared
    ? (him
        ? 'Shared. She can see your habits now. Change it in You.'
        : 'Shared. He can see your habits now. Change it in You.')
    : 'Kept to yourself. You can share it from You at any time.';

/// On her Partner health page when he does not share (PH1's honest line).
const String kTtcPartnerInviteHer =
    "This is his log, on his phone. When he joins and shares it, you'll see "
    'it here.';

/// The empty states of the view. Never "chose not to": nothing that blames.
const String kTtcPartnerNotSharedHim = "He hasn't shared his habits";
const String kTtcPartnerNotSharedHer = "She hasn't shared her habits";
const String kTtcPartnerNothingLogged = 'Nothing logged in the last 4 weeks';

/// The way in, by phone.
const String kTtcSeeHis = 'See his log';
const String kTtcSeeHers = 'See hers';

/// Her own notes on his tracker stay, under this fold (PH1), never deleted.
const String kTtcYourNotes = 'Your notes';
const String kTtcYourNotesLine =
    'What you noted here stays on your account.';

/// D5: his phone, at her logger or her PCOS check.
const String kTtcHerPrivateTitle = 'This is her private log.';
const String kTtcHerPrivateLine =
    'It stays on her account. Your own log is Partner health.';
const String kTtcHerPrivateButton = 'Open my Partner health';

// ---- the filter ---------------------------------------------------------------

/// The partner's rows for [tracker], as values: the tracker's own rows and the
/// four ids folded into `habits` (`ttcMergedTracker`), removed rows dropped,
/// the last [kTtcPartnerLogDays] days only, newest day first.
List<TtcLogValue> ttcPartnerLogRows(
    List<Map<String, dynamic>> rows, String tracker, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final from = today.subtract(const Duration(days: kTtcPartnerLogDays - 1));
  final out = <TtcLogValue>[];
  for (final r in rows) {
    final t = r['tracker'];
    final field = r['field'];
    final day = r['logged_on']?.toString();
    final value = r['value'];
    if (t is! String || field is! String || day == null || value is! num) {
      continue;
    }
    if (ttcMergedTracker(t) != tracker) continue;
    if (r['removed_at'] != null) continue;
    final d = DateTime.tryParse(day);
    if (d == null || d.isBefore(from) || d.isAfter(today)) continue;
    out.add(TtcLogValue(
        tracker: tracker,
        field: field,
        dayKey: TtcLogStore.dayKey(d),
        value: value.toDouble()));
  }
  out.sort((a, b) => b.dayKey.compareTo(a.dayKey));
  return out;
}

/// The partner's shared [tracker] rows from the cloud. [] when nobody is
/// linked, logged out, or offline: the view then says so, it never throws.
Future<List<TtcLogValue>> ttcFetchPartnerLog(String tracker) async {
  final pid = TtcLogShareStore.instance.partnerId ??
      await SupabaseRepo.myPartnerId().catchError((_) => null);
  if (pid == null) return const [];
  try {
    final rows = await SupabaseRepo.fetchByUser(TtcTables.logs, pid,
        orderBy: 'logged_on');
    return ttcPartnerLogRows(rows, tracker, DateTime.now());
  } catch (_) {
    return const [];
  }
}

// ---- the view -------------------------------------------------------------------

/// The partner's shared tracker, read-only, the last four weeks.
class TtcPartnerLogView extends StatefulWidget {
  const TtcPartnerLogView({super.key, required this.tracker, this.load});

  /// `partner_health` (his, on her phone) or `habits` (hers, on his).
  final String tracker;

  /// The rows, for a test. Null reads the cloud.
  final Future<List<TtcLogValue>> Function()? load;

  @override
  State<TtcPartnerLogView> createState() => _TtcPartnerLogViewState();
}

class _TtcPartnerLogViewState extends State<TtcPartnerLogView> {
  late final Future<List<TtcLogValue>> _rows =
      (widget.load ?? () => ttcFetchPartnerLog(widget.tracker))();

  @override
  Widget build(BuildContext context) {
    final him = TtcPartnerMode.instance.on;
    final t = ttcTrackerById(widget.tracker);
    final shares = TtcLogShareStore.instance.partnerShares(widget.tracker);
    final p = V2PaletteStore.instance.current;
    return TtcToolScaffold(
      hue: kTtcToolHueBoth,
      eyebrow: 'Shared with you',
      title: him ? 'Her habits.' : 'His habits.',
      intro: him
          ? 'What she logged in the last 4 weeks. Only she can change it.'
          : 'What he logged in the last 4 weeks. Only he can change it.',
      children: [
        const SizedBox(height: 20),
        FutureBuilder<List<TtcLogValue>>(
          future: _rows,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.all(28),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final rows = snap.data ?? const <TtcLogValue>[];
            if (rows.isEmpty) {
              final line = !shares && widget.load == null
                  ? (him ? kTtcPartnerNotSharedHer : kTtcPartnerNotSharedHim)
                  : kTtcPartnerNothingLogged;
              return ttcToolPad(Text(line,
                  key: const ValueKey('ttc_partner_log_empty'),
                  style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)));
            }
            final days = <String, List<TtcLogValue>>{};
            for (final r in rows) {
              days.putIfAbsent(r.dayKey, () => []).add(r);
            }
            return Column(children: [
              for (final e in days.entries)
                ttcToolPad(Container(
                  key: ValueKey('ttc_partner_log_day_${e.key}'),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: p.line))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ttcRoundDate(DateTime.parse(e.key)),
                          style: pvManrope(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: p.ink1)),
                      const SizedBox(height: 4),
                      for (final v in e.value)
                        Text(_line(t, v),
                            style: pvManrope(
                                fontSize: 13, height: 1.5, color: p.ink2)),
                    ],
                  ),
                )),
            ]);
          },
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  static String _line(TtcTracker? t, TtcLogValue v) {
    TtcField? f;
    for (final x in t?.fields ?? const <TtcField>[]) {
      if (x.id == v.field) f = x;
    }
    if (f == null) return '${v.field}: ${v.value}';
    return '${f.labelEn}: ${f.display(false, v.value)}';
  }
}

void _openPartnerLog(BuildContext context, String tracker) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'ttc/tracker/$tracker/partner'),
      builder: (_) => TtcPartnerLogView(tracker: tracker),
    ));

// ---- the way in, on the tracker page -------------------------------------------

/// On her Partner health page: his shared view, or the honest invitation.
/// On his Habits page: "See hers", when she shares.
class TtcPartnerLogCard extends StatelessWidget {
  const TtcPartnerLogCard({super.key, required this.tracker});

  final String tracker;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: TtcLogShareStore.instance,
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final him = TtcPartnerMode.instance.on;
          final shares = TtcLogShareStore.instance.partnerShares(tracker);
          if (!shares) {
            // His Habits page says nothing until she shares; her Partner
            // health page always says where his log is (PH1).
            if (him) return const SizedBox.shrink();
            return Text(kTtcPartnerInviteHer,
                key: const ValueKey('ttc_partner_log_invite'),
                style: pvManrope(
                    fontSize: 12.5,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink2));
          }
          return Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: p.line)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: const ValueKey('ttc_partner_log_open'),
              onTap: () => _openPartnerLog(context, tracker),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(children: [
                  Icon(Icons.people_outline_rounded, size: 20, color: p.ink1),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(him ? kTtcSeeHers : kTtcSeeHis,
                        style: pvManrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: p.ink1)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: p.ink3),
                ]),
              ),
            ),
          );
        },
      );
}

/// Whether the ask card shows on [tracker]'s page: the phone's own shareable
/// tracker (his `partner_health`, her `habits`), something saved on it, not
/// asked yet, and a partner linked to share with.
bool ttcShareAskDue(String tracker, {required bool him}) {
  final own = him ? 'partner_health' : 'habits';
  if (tracker != own) return false;
  final s = TtcLogShareStore.instance;
  return s.hasPartner &&
      s.sharedFor(tracker) == null &&
      TtcLogStore.instance.hasAnythingFor(tracker);
}

/// The once-only ask. "Share" first, in ink.
class TtcShareAskCard extends StatelessWidget {
  const TtcShareAskCard({super.key, required this.tracker});

  final String tracker;

  void _answer(BuildContext context, bool shared, bool him) {
    TtcLogShareStore.instance.set(tracker, shared);
    pvToast(context, ttcShareToast(shared, him: him),
        kind: PvToastKind.done);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge(
            [TtcLogShareStore.instance, TtcLogStore.instance]),
        builder: (context, _) {
          final him = TtcPartnerMode.instance.on;
          if (!ttcShareAskDue(tracker, him: him)) {
            return const SizedBox.shrink();
          }
          final p = V2PaletteStore.instance.current;
          return Container(
            key: const ValueKey('ttc_share_ask'),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: ttcLine),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(ttcShareAskLine(him: him),
                    style: pvManrope(
                        fontSize: 13.5, height: 1.5, color: p.ink1)),
                const SizedBox(height: 12),
                TtcToolPrimary(
                    key: const ValueKey('ttc_share_yes'),
                    label: kTtcShareYes,
                    onTap: () => _answer(context, true, him)),
                const SizedBox(height: 8),
                TtcToolSecondary(
                    key: const ValueKey('ttc_share_no'),
                    label: kTtcShareNo,
                    onTap: () => _answer(context, false, him)),
              ],
            ),
          );
        },
      );
}

// ---- D5: his phone at her private tools ----------------------------------------

/// The words and the way to his own tracker, with no frame: the PCOS door
/// shows it inline, the router pushes it in [TtcHerPrivateNote].
class TtcHerPrivateNoteBody extends StatelessWidget {
  const TtcHerPrivateNoteBody({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return ttcToolPad(Column(
      key: const ValueKey('ttc_her_private_note'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        const TtcSectionHeading(kTtcHerPrivateTitle),
        const SizedBox(height: 8),
        Text(kTtcHerPrivateLine,
            style: pvManrope(fontSize: 14, height: 1.55, color: p.ink2)),
        const SizedBox(height: 18),
        TtcToolPrimary(
            key: const ValueKey('ttc_her_private_open_his'),
            label: kTtcHerPrivateButton,
            onTap: () => openTtcTracker(context, 'partner_health')),
        const SizedBox(height: 24),
      ],
    ));
  }
}

/// D5: what the router opens on his phone for `ttc_symptom_log` and
/// `ttc_pcos_check`. No silent tap and no hiding: the tile still opens, and
/// says whose it is.
class TtcHerPrivateNote extends StatelessWidget {
  const TtcHerPrivateNote({super.key});

  @override
  Widget build(BuildContext context) => const TtcToolScaffold(
        hue: kTtcToolHueBody,
        eyebrow: 'Her log',
        title: 'This one is hers.',
        children: [TtcHerPrivateNoteBody()],
      );
}

/// The surfaces his phone may not open as hers.
bool ttcIsHerPrivateSurface(String id) =>
    id == 'ttc_symptom_log' ||
    id.startsWith('ttc_symptom_log/') ||
    id == 'ttc_pcos_check';
