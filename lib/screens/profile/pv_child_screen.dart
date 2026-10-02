// =============================================================================
//  PvChildScreen — one child's page
// -----------------------------------------------------------------------------
//  Garmin's Child Account + Apple's Medical ID (docs/PROFILE-AUDIT.md §3):
//  avatar · name · age · date of birth with Edit; the facts as rows with
//  `--` when empty; WHO CAN SEE (the partner, because a child's records are
//  the child's — FAMILY-MODEL §1); the records as rows into their tools; and
//  on the skilling side, the grown-up gate's things — wrapped in the gate
//  row by row, not around the whole page.
//
//  The child is the ACTIVE child of `ChildProfileStore`; opening a chip
//  switches first, so every store that reads "the active child" (the family
//  profile's per-child answers, growth, vaccines) is already looking at her.
//
//  Delete is at the end, in red, with the sentence that says what goes with
//  it. Removing a child does not touch the parent or the partner.
// =============================================================================

import 'package:flutter/material.dart';

import '../../screens/post_pregnancy/pp_child_profile.dart';
import '../../services/family_profile.dart';
import '../../services/life_stage_store.dart';
import '../../theme/pv_fonts.dart';
import '../post_pregnancy/family_profile_screen.dart';
import '../post_pregnancy/growth_journey_screen.dart';
import '../post_pregnancy/health_guide_screen.dart';
import '../post_pregnancy/vaccination_screen.dart';
import '../skilling/sk_child_store.dart';
import 'pv_partner_screen.dart';
import 'pv_you_chrome.dart';
import 'pv_you_sheets.dart';

class PvChildScreen extends StatefulWidget {
  const PvChildScreen({super.key, required this.childId, required this.stage});
  final String childId;
  final LifeStage stage;

  @override
  State<PvChildScreen> createState() => _PvChildScreenState();
}

class _PvChildScreenState extends State<PvChildScreen> {
  @override
  void initState() {
    super.initState();
    final s = ChildProfileStore.instance;
    if (s.activeChildId != widget.childId) s.switchTo(widget.childId);
  }

  static String _d(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  void _push(Widget w, String name) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => w,
      settings: RouteSettings(name: name),
    ),
  );

  String _list<T>(Set<T> s, String Function(T) label) =>
      s.isEmpty ? '--' : s.map(label).join(', ');

  static String _birthValue(FamilyProfileStore fam) {
    final parts = [
      if (fam.premature) 'Born early',
      if (fam.nicu) 'NICU',
      if (fam.multiple) 'Twin / multiple',
    ];
    return parts.isEmpty ? '--' : parts.join(', ');
  }

  Future<void> _editBasics(Child c) async {
    final p = pvStorePalette;
    final name = TextEditingController(text: c.name);
    var isBoy = c.isBoy;
    var dob = c.dob;
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit',
                    style: pvFraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: p.ink1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: name,
                    textCapitalization: TextCapitalization.words,
                    style: pvManrope(fontSize: 15, color: p.ink1),
                    decoration: InputDecoration(
                      hintText: 'Name',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: kPvLine),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: p.ink1, width: 1.4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      PvChip(
                        label: 'Girl',
                        selected: !isBoy,
                        onTap: () => setSheet(() => isBoy = false),
                      ),
                      PvChip(
                        label: 'Boy',
                        selected: isBoy,
                        onTap: () => setSheet(() => isBoy = true),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PvSecondary(
                    label: 'Born ${_d(dob)}',
                    icon: Icons.cake_outlined,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: ctx,
                        initialDate: dob,
                        firstDate: DateTime(DateTime.now().year - 18),
                        lastDate: DateTime.now(),
                      );
                      if (d != null) setSheet(() => dob = d);
                    },
                  ),
                  const SizedBox(height: 18),
                  PvCommit(
                    label: 'Save',
                    onTap: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    if (saved == true) {
      await ChildProfileStore.instance.update(
        name: name.text.trim().isEmpty ? c.name : name.text.trim(),
        isBoy: isBoy,
        dob: dob,
      );
    }
    // ⚠️ NOT DISPOSED THE MOMENT THE ROUTE CLOSES (2026-10-02, the red screen '_dependents.isEmpty'): the TextField is still on screen for the exit animation and still listening. Same fix as the add-child sheet.
    Future<void>.delayed(const Duration(milliseconds: 600), name.dispose);
  }

  Future<void> _remove(Child c) async {
    final p = pvStorePalette;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remove ${c.name}?',
          style: pvFraunces(fontSize: 20, color: p.ink1),
        ),
        content: Text(
          'Their records on this account — feeds, sleep, growth, vaccines, notes — go with them. You and your partner are not affected. This cannot be undone.',
          style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Color(0xFFC6295A)),
            ),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ChildProfileStore.instance.deleteChild(c.id);
      if (mounted) Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([
        ChildProfileStore.instance,
        FamilyProfileStore.instance,
        SkChildStore.instance,
      ]),
      builder: (context, _) {
        final store = ChildProfileStore.instance;
        final c = store.children
            .where((x) => x.id == widget.childId)
            .firstOrNull;
        if (c == null) {
          return Scaffold(
            backgroundColor: p.ground,
            body: Column(
              children: [
                const PvYouTopBar(title: 'Child', eyebrow: 'Family'),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'This child is no longer on this account.',
                    style: pvManrope(fontSize: 14, color: p.ink2),
                  ),
                ),
              ],
            ),
          );
        }
        final fam = FamilyProfileStore.instance;
        final sk = SkChildStore.instance;
        final skilling =
            widget.stage == LifeStage.skilling ||
            (c.dob.isBefore(
              DateTime.now().subtract(const Duration(days: 365 * 6)),
            ));
        return Scaffold(
          backgroundColor: p.ground,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: PvYouTopBar(title: c.name, eyebrow: 'Family'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kPvLine),
                    ),
                    child: Row(
                      children: [
                        PvAvatar(name: c.name, size: 64, hue: 26, child: true),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: pvFraunces(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                  color: p.ink1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${store.activeChildId == c.id ? store.ageLabel : ''} · ${c.isBoy ? 'boy' : 'girl'} · born ${_d(c.dob)}',
                                style: pvManrope(fontSize: 12.5, color: p.ink3),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _editBasics(c),
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Edit',
                              style: pvManrope(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: p.action,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!skilling)
                SliverToBoxAdapter(
                  child: PvYouSection(
                    title: 'About ${c.name}',
                    lead:
                        'What leads on the home for ${c.name}. Tap a row to change it.',
                    children: [
                      PvYouRow(
                        icon: Icons.local_drink_outlined,
                        title: 'Feeding',
                        value: _list(fam.feedings, (x) => x.label),
                        onTap: () =>
                            _push(const FamilyProfileScreen(), 'pp/profile'),
                      ),
                      PvYouRow(
                        icon: Icons.bedtime_outlined,
                        title: 'Sleep',
                        value: _list(fam.sleeps, (x) => x.label),
                        onTap: () =>
                            _push(const FamilyProfileScreen(), 'pp/profile'),
                      ),
                      PvYouRow(
                        icon: Icons.healing_outlined,
                        title: 'Conditions',
                        value: _list(fam.conditions, (x) => x.label),
                        onTap: () =>
                            _push(const FamilyProfileScreen(), 'pp/profile'),
                      ),
                      PvYouRow(
                        icon: Icons.child_friendly_outlined,
                        title: 'Birth',
                        value: _birthValue(fam),
                        onTap: () =>
                            _push(const FamilyProfileScreen(), 'pp/profile'),
                      ),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: PvYouSection(
                  title: 'Who can see ${c.name}',
                  lead:
                      'A child\'s records are the child\'s — both parents see them.',
                  children: [
                    PvYouRow(
                      icon: Icons.people_outline_rounded,
                      title: 'Your partner',
                      subtitle: 'Feeds, sleep, growth, vaccines, appointments',
                      onTap: () => _push(
                        PvPartnerScreen(stage: widget.stage),
                        'you/partner',
                      ),
                    ),
                  ],
                ),
              ),
              if (!skilling)
                SliverToBoxAdapter(
                  child: PvYouSection(
                    title: 'Records',
                    children: [
                      PvYouRow(
                        icon: Icons.show_chart_rounded,
                        title: 'Growth',
                        subtitle: 'Weight, height, head — on the curve',
                        onTap: () =>
                            _push(const GrowthJourneyScreen(), 'pp/growth'),
                      ),
                      PvYouRow(
                        icon: Icons.vaccines_outlined,
                        title: 'Vaccinations',
                        subtitle: 'The schedule, and what is done',
                        onTap: () =>
                            _push(const VaccinationScreen(), 'pp/vaccines'),
                      ),
                      PvYouRow(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Health',
                        subtitle: 'Fever, illness, the health log',
                        onTap: () =>
                            _push(const HealthGuideScreen(), 'pp/health'),
                      ),
                    ],
                  ),
                ),
              if (skilling)
                SliverToBoxAdapter(
                  child: PvYouSection(
                    title: 'Skilling',
                    lead:
                        'Behind the grown-up gate. ${c.name} never sees this side.',
                    children: [
                      PvYouRow(
                        icon: Icons.lock_outline_rounded,
                        title: 'Grown-up gate',
                        value: sk.hasPin ? 'PIN set' : 'A sum in words',
                        subtitle:
                            'Consent: ${sk.consented ? 'given' : 'not yet'}',
                        onTap: () => showPvKeepsakesSheet(context),
                      ),
                      PvYouRow(
                        icon: Icons.auto_awesome_outlined,
                        title: 'Her keepsakes',
                        subtitle: 'Journal, photos, voice — on this phone only',
                        onTap: () => showPvKeepsakesSheet(context),
                      ),
                    ],
                  ),
                ),
              SliverToBoxAdapter(
                child: PvYouSection(
                  title: 'Remove',
                  lead:
                      'Only ${c.name}\'s records go. You and your partner stay as you are.',
                  children: [
                    PvYouRow(
                      icon: Icons.person_remove_outlined,
                      title: 'Remove ${c.name} from this account',
                      danger: true,
                      onTap: () => _remove(c),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}
