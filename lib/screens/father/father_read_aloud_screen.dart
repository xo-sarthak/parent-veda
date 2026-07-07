// =============================================================================
//  FatherReadAloudScreen - the father's "Read to baby" tab (Slate)
// -----------------------------------------------------------------------------
//  Same 4-tab structure as the mother's Samvad (Affirmations & Blessings ·
//  Stories & Fables · Mantras & Lullabies · Spiritual Reading), in the Slate
//  father skin. The father CANNOT customize - Spiritual mirrors whatever the
//  mother has chosen (read-only). Everything is the same as the mother's except
//  Affirmations & Blessings, which draws from a distinct father slice.
//  Embedded as a tab → no back button, bottom padding clears the floating pill.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/garbh_data.dart';
import '../../data/read_to_baby_data.dart';
import '../../data/spiritual_reading_data.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/read_to_baby_saved_store.dart';
import '../../services/read_to_baby_store.dart';
import '../../theme/father_skin.dart';

// One read-aloud piece (optional title + body) + a stable save key + group.
typedef _FSP = ({String? title, String body, String saveKey, String group});

class FatherReadAloudScreen extends StatefulWidget {
  const FatherReadAloudScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<FatherReadAloudScreen> createState() => _FatherReadAloudScreenState();
}

class _FatherReadAloudScreenState extends State<FatherReadAloudScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  ReadToBabyStore get _store => ReadToBabyStore.instance;
  int get _t => garbhTrimester(widget.controller.currentWeek);

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  TextStyle _body(double s,
          {FontWeight w = FontWeight.w400, Color c = kFInk, double h = 1.5}) =>
      GoogleFonts.plusJakartaSans(
          fontSize: s, fontWeight: w, color: c, height: h);
  TextStyle _eyebrow(Color c) => GoogleFonts.plusJakartaSans(
      fontSize: 11, fontWeight: FontWeight.w700, color: c, letterSpacing: 1.4);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kFBg,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('READ TO YOUR BABY', style: _eyebrow(kFMuted)),
                  const SizedBox(height: 4),
                  Text('Read to your baby',
                      style: fatherSerif(26, weight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                      "The same words she's reading - say them aloud to the bump. Your voice is one they already know.",
                      style: _body(13, c: kFMuted)),
                ],
              ),
            ),
            TabBar(
              controller: _tab,
              isScrollable: true,
              labelColor: kFAccent,
              unselectedLabelColor: kFMuted,
              indicatorColor: kFAccent,
              tabAlignment: TabAlignment.start,
              labelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, fontSize: 13),
              unselectedLabelStyle: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600, fontSize: 13),
              tabs: const [
                Tab(text: 'Affirmations & Blessings'),
                Tab(text: 'Stories & Fables'),
                Tab(text: 'Mantras & Lullabies'),
                Tab(text: 'Spiritual Reading'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _listTab(_affirmations()),
                  _listTab(_stories()),
                  _listTab(_mantrasLullabies()),
                  _spiritualTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Content per section --------------------------------------------------
  // Affirmations: a distinct father slice (differs from the mother's full set).
  List<_FSP> _affirmations() => [
        for (final p in readAloudFatherAffirmations())
          (
            title: p.title,
            body: p.body,
            saveKey: p.title,
            group: 'Affirmations & Blessings'
          ),
      ];

  List<_FSP> _stories() => [
        for (final p in readAloudByCategory(kRtbStories))
          (
            title: p.title,
            body: p.body,
            saveKey: p.title,
            group: 'Stories & Fables'
          ),
      ];

  List<_FSP> _mantrasLullabies() => [
        for (final p in samvadForTrimester(_t))
          (
            title: null,
            body: p.text,
            saveKey: 'mantra_${p.id}',
            group: 'Mantras & Lullabies'
          ),
        for (final p in readAloudByCategory(kRtbRhymes))
          (
            title: p.title,
            body: p.body,
            saveKey: p.title,
            group: 'Mantras & Lullabies'
          ),
      ];

  // Spiritual - mirrors the mother's chosen traditions (father can't customize).
  List<_FSP> _spiritual() {
    final out = <_FSP>[];
    for (final tr in kSpiritualTraditions) {
      if (!_store.isReligionOn(tr.id)) continue;
      for (var i = 0; i < tr.sections.length; i++) {
        if (!_store.isSectionOn(tr.id, i)) continue;
        for (final r in tr.sections[i].reads) {
          out.add(
              (title: r.title, body: r.body, saveKey: r.title, group: tr.name));
        }
      }
    }
    return out;
  }

  // ---- Tabs -----------------------------------------------------------------
  Widget _listTab(List<_FSP> pieces) => AnimatedBuilder(
        animation: ReadToBabySavedStore.instance,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
          children: [for (final p in pieces) _card(p)],
        ),
      );

  Widget _spiritualTab() => AnimatedBuilder(
        animation:
            Listenable.merge([_store, ReadToBabySavedStore.instance]),
        builder: (context, _) {
          final pieces = _spiritual();
          if (pieces.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: kFAccentSoft,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: kFLine),
                  ),
                  child: Text(
                      "Nothing chosen yet - she picks the spiritual reading in her app, and it shows up here for you.",
                      style: _body(14, c: kFInk)),
                ),
              ],
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 120),
            children: [for (final p in pieces) _card(p)],
          );
        },
      );

  Widget _card(_FSP p) {
    final saved = ReadToBabySavedStore.instance.isSaved(p.saveKey);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kFCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kFLine),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (p.title != null && p.title!.trim().isNotEmpty) ...[
          Text(p.title!, style: fatherSerif(16, weight: FontWeight.w700)),
          const SizedBox(height: 8),
        ],
        Text('“${p.body}”',
            style: GoogleFonts.fraunces(
                fontSize: 15.5,
                fontStyle: FontStyle.italic,
                height: 1.55,
                color: kFInk)),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => ReadToBabySavedStore.instance
                .toggleSave(p.saveKey, p.body, p.group),
            icon: Icon(
                saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                size: 18,
                color: kFAccent),
            label: Text('Save', style: _body(13, w: FontWeight.w700, c: kFAccent)),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ]),
    );
  }
}
