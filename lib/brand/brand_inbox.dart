// =============================================================================
//  Brand inbox: a sponsored notification, kept in Messages after it is sent
// -----------------------------------------------------------------------------
//  Pee Safe demo (2026-11-03, the user: notifications should be in Messages
//  too, "but shouldn't look like coming from Pee Safe, ParentVeda should be
//  there"). So the row is ParentVeda's: ParentVeda's mark, ParentVeda's words,
//  and the partner named once, small, as the disclosure ("With Pee Safe ·
//  Sponsored"). The disclosure standard (BRAND-STUDIO.md §6) is not optional.
//
//  WHY A STORE OF ITS OWN, NOT A NEW KIND IN THE THREE MESSAGES STORES. Those
//  stores are cloud-synced and REBUILD their list from rules on every
//  refresh, so a message pushed in from outside would either be dropped on
//  the next refresh or have to grow a new persisted kind, a cloud shape and a
//  sign-out path in three places. This keeps it to one local list read by one
//  widget that all three Messages screens place. The trade: these rows are on
//  this phone only. Acceptable: a sponsored note is not her record.
//
//  Written ONLY by BrandNotifications, after a send actually reached the OS.
//  The row taps through the same router as the phone notification.
// =============================================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/doors/pv_list_row.dart';
import '../screens/v2/v2_palette.dart';
import '../services/remote/sync_registry.dart';
import 'brand_models.dart';
import 'brand_studio.dart';
import 'pee_safe/pee_safe_notifications.dart' show openPeeSafeNotification;

/// One sent note: which campaign, and when.
class BrandInboxEntry {
  const BrandInboxEntry(this.campaignId, this.at);
  final String campaignId;
  final DateTime at;
}

/// The sent notes, newest first. Device-local; a sign-out forgets them.
class BrandInbox extends ChangeNotifier {
  BrandInbox._() {
    // They say which stage she is at (week 36, the first days after birth),
    // so they are hers, not the phone's (test/sync_reset_coverage_test.dart).
    SyncRegistry.registerReset(_resetForAccount);
  }
  static final BrandInbox instance = BrandInbox._();

  static const String _key = 'brand_inbox';

  /// A note stays this long, as Messages' daily kinds do.
  static const Duration keep = Duration(days: 14);

  final List<BrandInboxEntry> _entries = [];
  bool _loaded = false;

  List<BrandInboxEntry> entries({DateTime? now}) {
    final cut = (now ?? DateTime.now()).subtract(keep);
    return [for (final e in _entries) if (e.at.isAfter(cut)) e];
  }

  Future<void> load() async {
    if (_loaded) return;
    try {
      final p = await SharedPreferences.getInstance();
      final raw = p.getString(_key);
      if (raw != null) {
        for (final m in (jsonDecode(raw) as List).cast<Map>()) {
          final at = DateTime.tryParse('${m['at']}');
          if (m['id'] is String && at != null) _entries.add(BrandInboxEntry(m['id'] as String, at));
        }
      }
    } catch (_) {/* start empty */}
    _loaded = true;
    notifyListeners();
  }

  /// Record a send. The same campaign sent again moves to the top, once.
  Future<void> add(String campaignId, DateTime at) async {
    await load();
    _entries
      ..removeWhere((e) => e.campaignId == campaignId)
      ..insert(0, BrandInboxEntry(campaignId, at));
    notifyListeners();
    await _save();
  }

  /// For the Showcase "Reset demo".
  Future<void> reset() async {
    _entries.clear();
    notifyListeners();
    await _save();
  }

  void _resetForAccount() {
    _entries.clear();
    _loaded = false;
    notifyListeners();
  }

  Future<void> _save() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key, jsonEncode([
        for (final e in _entries) {'id': e.campaignId, 'at': e.at.toIso8601String()},
      ]));
    } catch (_) {}
  }
}

/// The sent notes as Messages rows, in ParentVeda's voice. Draws nothing
/// when there are none: Messages' own empty state stays the invitation.
class BrandInboxRows extends StatefulWidget {
  const BrandInboxRows({
    super.key,
    required this.p,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 18),
  });

  final V2Palette p;
  final EdgeInsets padding;

  @override
  State<BrandInboxRows> createState() => _BrandInboxRowsState();
}

class _BrandInboxRowsState extends State<BrandInboxRows> {
  @override
  void initState() {
    super.initState();
    BrandInbox.instance.load();
  }

  BrandCampaign? _campaign(String id) {
    for (final c in BrandStudio.instance.campaigns) {
      if (c.id == id) return c;
    }
    return null;
  }

  String _ago(DateTime at) {
    final d = DateTime.now().difference(at);
    if (d.inMinutes < 1) return 'Now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    return '${d.inDays}d';
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: BrandInbox.instance,
        builder: (context, _) {
          final rows = [
            for (final e in BrandInbox.instance.entries())
              if (_campaign(e.campaignId) case final c?) (e, c),
          ];
          if (rows.isEmpty) return const SizedBox.shrink();
          final p = widget.p;
          return Padding(
            padding: widget.padding,
            child: PvRowGroup(p: p, children: [
              for (final (e, c) in rows)
                PvListRow(
                  key: ValueKey('brand_inbox_${c.id}'),
                  p: p,
                  leading: PvMarkWell(p: p, hue: 96, size: 44, icon: Icons.spa_outlined),
                  title: c.creative.headline,
                  line: '${c.creative.subline}\nWith ${c.brand.name} · Sponsored',
                  lineMaxLines: 4,
                  meta: _ago(e.at),
                  onTap: () => openPeeSafeNotification(context, c.id),
                ),
            ]),
          );
        },
      );
}
