// =============================================================================
//  PvYouScreen — "You": one profile for four stages
// -----------------------------------------------------------------------------
//  Built 2026-09-19 from the Mobbin profile audit (docs/PROFILE-AUDIT.md).
//  Before this there were four: the pregnancy `ProfileScreen`, the TTC
//  `TtcProfileScreen` + `TtcMoreScreen`, parenting's `PpMoreSheet` +
//  `FamilyProfileScreen`, and skilling's `SkGrownUpScreen`. Each was right
//  for its stage and none looked like the others. The user: *"a format that
//  stays consistent throughout all four stages."*
//
//  THE RULE. Eight sections, fixed, in this order, on every stage:
//
//    A  identity card      B  your journey     C  family        D  your details
//    E  your things        F  preferences      G  support       H  account
//
//  A stage changes what is INSIDE a section — the clock, the one forward
//  action, the rows — and it does that in `pv_you_content.dart`, as data.
//  This file never switches on stage. A section with nothing in it renders
//  its invitation; nothing disappears. That is what makes it one screen
//  (the store's stage switch and the family model's "stage is a tag" are
//  the same idea).
//
//  Reached from the avatar on every home (the user's call), pushed with its
//  own back arrow — not a tab. Flo puts the stage on the profile; Oura
//  splits profile from settings; Clue groups rows under headers; Fitbit puts
//  the adult at the root and the children beneath; Airbnb floats the mode
//  switch as a pill. All five are here.
//
//  ⚠️ THE FORWARD ACTION IS NOT A STAGE SWITCH. The team's switch stays
//  under Developer, debug-only, with the other "· testing" affordances.
// =============================================================================

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/onboarding/onboarding_flow.dart';
import '../../care_partner/care_visibility.dart';
import '../../localization/app_language.dart';
import '../../screens/post_pregnancy/pp_child_profile.dart';
import '../../services/app_nav.dart';
import '../../services/entitlement_store.dart';
import '../../services/family_profile.dart';
import '../../services/journey_dates_store.dart';
import '../../services/father_preview.dart';
import '../../models/pv_product.dart' show PvStageCopy;
import '../../services/life_stage_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/pv_order_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../services/saved_store.dart';
import '../../services/scans_store.dart';
import '../../services/stage_gateway.dart';
import '../../services/whatsapp_prefs.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_nav_bar.dart' show pvNavClearance;
import '../care_partner/care_partner_card.dart';
import '../care_partner/care_partner_slot.dart';
import '../developer_switches.dart';
import '../enterprise/employer_benefits_screen.dart';
import '../post_pregnancy/family_profile_screen.dart';
import '../pregnancy_profile_screen.dart';
import '../referral/invite_friends_screen.dart';
import '../reminders_screen.dart';
import '../skilling/sk_child_store.dart';
import '../ttc/ttc_strings.dart' show TtcLang, TtcPartnerMode, TtcS;
import 'pv_account_actions.dart';
import 'pv_child_screen.dart';
import 'pv_data_privacy_screen.dart';
import 'pv_details_screen.dart';
import 'pv_partner_screen.dart';
import '../v2/v2_palette.dart';
import 'pv_you_chrome.dart';
import 'pv_you_content.dart';
import 'pv_you_sheets.dart';

/// Our own walk builds are `--release` (the only honest way to judge motion)
/// and release strips `kDebugMode`, which took the Developer section — and
/// the stage switch inside it — off the phone (the user, 2026-09-22: "from
/// profile u removed the toggle"). So the section also shows when a build is
/// made with `--dart-define=PV_DEV=true`. A store build never passes it.
const bool kPvDevBuild = bool.fromEnvironment('PV_DEV');

/// Whether the team's affordances are on this build.
const bool kPvShowDeveloper = kDebugMode || kPvDevBuild;

const String kPvYouRoute = 'you';

/// Opens You for the current stage. Every avatar on every home calls this.
void openPvYou(BuildContext context, {LifeStage? stage, bool father = false}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PvYouScreen(stage: stage, father: father),
      settings: const RouteSettings(name: kPvYouRoute),
    ),
  );
}

class PvYouScreen extends StatefulWidget {
  const PvYouScreen({
    super.key,
    this.stage,
    this.father = false,
    this.bottomNav,
  });

  /// Null = her current stage. Skilling passes itself explicitly (it is a
  /// child's chapter and never the persisted stage).
  final LifeStage? stage;

  /// The partner's view: his card, her journey read-only.
  final bool father;

  /// A stage's tab bar, when You is one of that stage's tabs (TTC since
  /// 2026-09-26). Null everywhere else, which is exactly the screen as it was:
  /// a back arrow and no bar.
  ///
  /// ⚠️ A SLOT, NOT A STAGE SWITCH. The same idea as `PvStoreChrome`: this
  /// file still never asks which stage it is on. The caller hands in the bar
  /// it already owns; the skeleton, the sections and their order do not move,
  /// which `test/pv_you_test.dart` holds for every stage.
  final Widget? bottomNav;

  @override
  State<PvYouScreen> createState() => _PvYouScreenState();
}

class _PvYouScreenState extends State<PvYouScreen> {
  // Facts that live only on the profiles row.
  String? _email;
  String? _phone;
  bool _phoneVerified = false;
  DateTime? _since;
  bool _partnerLinked = false;
  bool _whatsapp = false;

  LifeStage get _stage =>
      (widget.stage ?? LifeStageStore.instance.stage ?? LifeStage.pregnancy);

  @override
  void initState() {
    super.initState();
    PvOrderStore.instance.init();
    _load();
  }

  Future<void> _load() async {
    _email = SupabaseRepo.userEmail;
    try {
      final wa = await WhatsAppPrefs.load();
      _whatsapp = wa.optIn;
      final uid = SupabaseRepo.userId;
      if (uid != null) {
        final row = await Supabase.instance.client
            .from('profiles')
            .select('phone, phone_verified_at, created_at, partner_id')
            .eq('id', uid)
            .maybeSingle();
        _phone = row?['phone'] as String?;
        _phoneVerified = row?['phone_verified_at'] != null;
        final c = row?['created_at'] as String?;
        _since = c == null ? null : DateTime.tryParse(c);
        _partnerLinked = row?['partner_id'] != null;
      }
    } catch (_) {
      /* local-first: the page renders without */
    }
    if (mounted) setState(() {});
  }

  void _push(Widget w, String name) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => w,
      settings: RouteSettings(name: name),
    ),
  );

  // ---- identity ------------------------------------------------------------------

  static String? _nonEmpty(String? s) =>
      (s == null || s.trim().isEmpty) ? null : s.trim();

  /// Her own name, or the honest placeholder — never the 'Priya' the
  /// pregnancy copy falls back to. A profile card that invents a name she
  /// never gave is a lie she would notice first.
  String get _name {
    final c = PregnancyController.current;
    if (widget.father) return _nonEmpty(c?.fatherName) ?? 'Dad';
    return _nonEmpty(c?.myName) ?? 'You';
  }

  String get _partnerName {
    final c = PregnancyController.current;
    return _nonEmpty(widget.father ? c?.motherName : c?.partnerName) ??
        'your partner';
  }

  String _sinceLine() {
    if (_since == null) return 'with ParentVeda';
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
    return 'with ParentVeda since ${m[_since!.month - 1]} ${_since!.year}';
  }

  Future<void> _editName() async {
    final p = pvStorePalette;
    final ctl = TextEditingController(
      text: PregnancyController.current?.myName ?? '',
    );
    final v = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your name',
                  style: pvFraunces(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'As you would like to be greeted. Your partner sees it too.',
                  style: pvManrope(fontSize: 13, color: p.ink2),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: pvManrope(fontSize: 15, color: p.ink1),
                  decoration: InputDecoration(
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
                const SizedBox(height: 16),
                PvCommit(
                  label: 'Save',
                  onTap: () => Navigator.of(ctx).pop(ctl.text.trim()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    ctl.dispose();
    if (v == null || v.isEmpty) return;
    await SupabaseRepo.updateMyProfile({'name': v});
    await PregnancyController.current?.loadProfileFromCloud();
    if (mounted) setState(() {});
  }

  // ---- build ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final stage = _stage;
    final content = pvYouContentFor(stage);
    return ListenableBuilder(
      listenable: Listenable.merge([
        LifeStageStore.instance,
        FamilyProfileStore.instance,
        ChildProfileStore.instance,
        SavedStore.instance,
        PvOrderStore.instance,
        EntitlementStore.instance,
        SkChildStore.instance,
        FatherPreview.instance,
        if (PregnancyController.current != null) PregnancyController.current!,
      ]),
      builder: (context, _) {
        final sponsor = EntitlementStore.instance.sponsor;
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _topBar(p)),
                  // A — identity
                  SliverToBoxAdapter(
                    child: PvIdentityCard(
                      name: _name,
                      meta: _sinceLine(),
                      clock: widget.father
                          ? '$_partnerName · ${content.clock()}'
                          : content.clock(),
                      verified: _phoneVerified,
                      chip: sponsor?.name,
                      onEdit: widget.father ? null : _editName,
                    ),
                  ),
                  // B — your journey
                  SliverToBoxAdapter(child: _journey(p, stage, content)),
                  // C — family
                  SliverToBoxAdapter(child: _family(p, stage, content)),
                  // D — your details (folded into "Your answers" when the
                  // stage gives groups, 2026-09-27)
                  if (content.groups == null)
                    SliverToBoxAdapter(child: _details(p, content)),
                  // E — your things
                  SliverToBoxAdapter(child: _things(p, content)),
                  // F — preferences
                  SliverToBoxAdapter(child: _preferences(p, stage)),
                  // G — support
                  SliverToBoxAdapter(child: _support(p, stage)),
                  // H — account
                  SliverToBoxAdapter(child: _account(p, stage)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Text(
                        'ParentVeda',
                        style: pvManrope(fontSize: 11.5, color: p.ink3),
                      ),
                    ),
                  ),
                  // ⚠️ DEVELOPER LAST, UNDER THE FOOTER (the user, 2026-09-27):
                  // it is never in a release build, so it must read as apart
                  // from the screen she will get. Kept for revert: it sat above
                  // the "ParentVeda" line.
                  if (kPvShowDeveloper)
                    SliverToBoxAdapter(child: _developer(p)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          (_partnerLinked || FatherPreview.instance.on
                              ? 120
                              : 40) +
                          (widget.bottomNav == null
                              ? 0
                              : pvNavClearance(context)),
                    ),
                  ),
                ],
              ),
              if (_partnerLinked || FatherPreview.instance.on)
                _viewingAsPill(p),
              if (widget.bottomNav != null)
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 14,
                  child: SafeArea(top: false, child: widget.bottomNav!),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _topBar(V2Palette p) => Padding(
    padding: EdgeInsets.fromLTRB(
      16,
      MediaQuery.of(context).padding.top + 10,
      16,
      6,
    ),
    child: Row(
      children: [
        // A tab root has nowhere to go back to: the bar is the way out.
        if (widget.bottomNav == null) ...[
          PvRoundIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 12),
        ] else
          const SizedBox(width: 4),
        Expanded(
          child: Text(
            'You',
            style: pvFraunces(
              fontSize: 26,
              fontWeight: FontWeight.w500,
              color: p.ink1,
            ),
          ),
        ),
      ],
    ),
  );

  // ---- B: your journey ------------------------------------------------------------

  Widget _journey(V2Palette p, LifeStage stage, PvYouStageContent content) {
    const chapters = [
      (LifeStage.tryingToConceive, 'Trying'),
      (LifeStage.pregnancy, 'Pregnancy'),
      (LifeStage.parenting, 'Parenting'),
      (LifeStage.skilling, '6+'),
    ];
    final idx = chapters.indexWhere((c) => c.$1 == stage);
    final a = content.action;
    return PvYouSection(
      title: 'Your journey',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (var i = 0; i < chapters.length; i++) ...[
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 1.5,
                          color: i <= idx ? p.ink1 : kPvLine,
                        ),
                      ),
                    Column(
                      children: [
                        Container(
                          width: i == idx ? 12 : 8,
                          height: i == idx ? 12 : 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < idx
                                ? p.ink1
                                : (i == idx ? p.ink1 : Colors.white),
                            border: Border.all(
                              color: i <= idx ? p.ink1 : p.ink3,
                              width: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          chapters[i].$2,
                          style: pvManrope(
                            fontSize: 11.5,
                            fontWeight: i == idx
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: i == idx ? p.ink1 : p.ink3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              if (a != null && !widget.father) ...[
                const SizedBox(height: 14),
                PvSecondary(
                  label: a.label,
                  icon: a.icon,
                  onTap: () => a.run(context),
                ),
                if (a.note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    a.note!,
                    style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3),
                  ),
                ],
              ],
              if (widget.father) ...[
                const SizedBox(height: 10),
                Text(
                  '$_partnerName\'s journey. It moves when she says so.',
                  style: pvManrope(fontSize: 12, height: 1.4, color: p.ink3),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ---- C: family --------------------------------------------------------------------

  Widget _family(V2Palette p, LifeStage stage, PvYouStageContent content) {
    final kids = ChildProfileStore.instance;
    final children = kids.hasRealChild
        ? [
            for (final c in kids.children)
              (id: c.id, name: c.name, age: _ageOf(c)),
          ]
        : <({String id, String name, String age})>[];
    // TTC says it without the dash its voice leaves out (2026-09-27); the
    // other stages keep their line.
    final partnerLine = _partnerLinked
        ? 'Paired · sees your week and calendar'
        : stage == LifeStage.tryingToConceive
            ? 'Invite ${widget.father ? 'her' : 'your partner'}: their own side, in step with yours'
            : 'Invite ${widget.father ? 'her' : 'your partner'} — their own side, in step with yours';
    return PvYouSection(
      title: 'Family',
      children: [
        PvPersonCard(
          name: _partnerLinked
              ? _partnerName
              : (widget.father ? _partnerName : 'Your partner'),
          // No "partner" tag after "Your partner" (2026-09-27, build 11: it
          // read "Your partner partner"). The tag stays when a real name is
          // shown, where it says who that person is.
          role: widget.father || !_partnerLinked ? '' : 'partner',
          line: partnerLine,
          verified: false,
          hue: 206,
          action: _partnerLinked ? null : 'Invite',
          onTap: () => _push(
            PvPartnerScreen(
              stage: stage,
              partnerName: _partnerLinked ? _partnerName : null,
            ),
            'you/partner',
          ),
        ),
        // Care circle: renders nothing unless a doctor or hospital actually
        // introduced her — the slot decides, not this screen.
        CarePartnerSlot(
          surface: CareSurface.profile,
          stage: _stageId(stage),
          shape: CarePartnerCardShape.full,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        ),
        if (children.isNotEmpty)
          PvChildChips(
            children: children,
            activeId: kids.activeChildId,
            onOpen: (id) => _push(
              PvChildScreen(childId: id, stage: stage),
              'you/child/$id',
            ),
            onAdd: () => showPvAddChildSheet(context),
          )
        // While trying there is no child's page to add or open; the row
        // was a dash that could not be tapped (2026-09-27).
        else if (content.groups == null)
          PvYouRow(
            icon: Icons.child_care_outlined,
            title: 'Children',
            subtitle: content.childrenInvitation,
            value: '--',
            onTap: stage == LifeStage.tryingToConceive
                ? null
                : () => showPvAddChildSheet(context),
          ),
      ],
    );
  }

  String _ageOf(Child c) {
    final days = DateTime.now().difference(c.dob).inDays;
    if (days < 0) return '';
    if (days < 60) return '${(days / 7).floor()} wk';
    if (days < 730) return '${(days / 30.4).floor()} mo';
    return '${(days / 365.25).floor()}';
  }

  // ---- D: your details -----------------------------------------------------------------

  Widget _details(V2Palette p, PvYouStageContent content) => PvYouSection(
    title: 'Your details',
    lead: widget.father
        ? 'Hers to edit, not yours.'
        : 'What we know. Tap to correct anything.',
    children: [
      for (final d in content.details)
        PvYouRow(
          icon: Icons.notes_rounded,
          title: d.label,
          subtitle: d.note,
          value: d.value(),
          onTap: widget.father ? null : () => d.edit(context),
        ),
    ],
  );

  // ---- E: your things ---------------------------------------------------------------------

  Widget _things(V2Palette p, PvYouStageContent content) => Padding(
    padding: const EdgeInsets.only(top: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'YOUR THINGS',
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.action,
            ),
          ),
        ),
        const SizedBox(height: 10),
        // ⚠️ ONE HEIGHT FOR ALL THREE (the user, 2026-09-27: "why is the
        // Journal tab smaller than the tab on the left and the right?"). A
        // tile with a count draws two lines and one without draws one, so the
        // countless tile came out short. IntrinsicHeight + stretch makes the
        // row as tall as its tallest tile. Kept for revert: a bare Row.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: IntrinsicHeight(
           child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < content.tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                PvYouTile(
                  icon: content.tiles[i].icon,
                  label: content.tiles[i].title,
                  count: content.tiles[i].count?.call(),
                  hue: const [268.0, 344.0, 26.0][i % 3],
                  onTap: () => content.tiles[i].open(context),
                ),
              ],
            ],
           ),
          ),
        ),
        const SizedBox(height: 10),
        // Short and grouped (2026-09-27): a titled card per group.
        if (content.groups != null)
          for (final g in content.groups!) _group(p, g)
        else
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPvLine),
            ),
            child: Column(
              children: [
                for (var i = 0; i < content.things.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kPvLine,
                      indent: 16,
                      endIndent: 16,
                    ),
                  // ⚠️ ADDITIVE (2026-09-26, the TTC review's Y1 and Y3). A row
                  // that sets `listen` repaints on its own store; one that sets
                  // `dot` shows a dot and no number; one that sets
                  // `subtitleNow` shows its state. Rows that set none of the
                  // three, every row on the other stages, draw exactly as
                  // before.
                  _thingRow(p, content.things[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );

  /// One titled group: the section label, then its rows in one card.
  Widget _group(V2Palette p, PvYouGroup g) => Padding(
    padding: const EdgeInsets.only(top: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            g.title.toUpperCase(),
            style: pvManrope(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: p.action,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: kPvLine),
            ),
            child: Column(
              children: [
                for (var i = 0; i < g.things.length; i++) ...[
                  if (i > 0)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: kPvLine,
                      indent: 16,
                      endIndent: 16,
                    ),
                  _thingRow(p, g.things[i]),
                ],
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _thingRow(V2Palette p, PvYouThing thing) {
    Widget row() => PvYouRow(
      icon: thing.icon,
      title: thing.title,
      subtitle: thing.subtitleNow?.call() ?? thing.subtitle,
      badge: thing.count?.call(),
      trailing: thing.dot?.call() == true
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  key: const ValueKey('pv_you_thing_dot'),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    // The TTC coral, the home envelope's dot.
                    color: Color(0xFFFF5A79),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
              ],
            )
          : null,
      onTap: () => thing.open(context),
    );
    final l = thing.listen;
    if (l == null) return row();
    return ListenableBuilder(listenable: l, builder: (_, _) => row());
  }

  // ---- F: preferences ------------------------------------------------------------------------

  Widget _preferences(V2Palette p, LifeStage stage) {
    final ctl = PregnancyController.current;
    final hindi = stage.shopStage == LifeStage.tryingToConceive
        ? TtcLang.instance.hinglish
        : (ctl?.language.isHindi ?? false);
    return PvYouSection(
      title: 'Preferences',
      children: [
        PvYouRow(
          icon: Icons.translate_rounded,
          title: 'Language',
          value: hindi ? 'हिंदी' : 'English',
          onTap: () => _pickLanguage(stage, hindi),
        ),
        PvYouRow(
          icon: Icons.notifications_none_rounded,
          title: 'Reminders',
          subtitle: 'What we nudge you about, and when',
          onTap: () {
            if (ctl != null && stage.shopStage == LifeStage.pregnancy) {
              _push(RemindersScreen(controller: ctl), 'reminders');
            } else {
              _push(
                PvDetailsScreen(stageId: _stageId(stage), focusId: 'notify'),
                'you/details',
              );
            }
          },
        ),
        PvYouSwitchRow(
          icon: Icons.chat_outlined,
          title: 'WhatsApp updates',
          subtitle: _phone == null || _phone!.isEmpty
              ? 'Your number is not on file yet'
              : 'To $_phone',
          value: _whatsapp,
          onChanged: (v) async {
            setState(() => _whatsapp = v);
            final ok = await WhatsAppPrefs.save(
              optIn: v,
              phone: _phone ?? '',
              language: hindi ? 'hi' : 'en',
              source: 'you_screen',
            );
            if (mounted) {
              pvSnack(
                context,
                ok
                    ? (v ? 'WhatsApp updates on.' : 'WhatsApp updates off.')
                    : 'Could not save — try again.',
              );
            }
          },
        ),
        PvYouRow(
          icon: Icons.tune_rounded,
          title: 'Personalise ParentVeda',
          subtitle: 'What leads on your home, and why',
          onTap: () => _push(
            stage.shopStage == LifeStage.parenting
                ? const FamilyProfileScreen()
                : (stage.shopStage == LifeStage.pregnancy
                      ? const PregnancyProfileScreen()
                      : PvDetailsScreen(stageId: _stageId(stage))),
            'personalise',
          ),
        ),
      ],
    );
  }

  String _stageId(LifeStage s) => switch (s) {
    LifeStage.tryingToConceive => 'trying',
    LifeStage.pregnancy => 'pregnancy',
    LifeStage.parenting => 'parenting',
    LifeStage.skilling => 'skilling',
  };

  Future<void> _pickLanguage(LifeStage stage, bool hindi) async {
    final p = pvStorePalette;
    final v = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: p.ground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Language',
                style: pvFraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'New writing is in English; a large part of the pregnancy chapter is also in Hindi.',
                style: pvManrope(fontSize: 13, height: 1.4, color: p.ink2),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  PvChip(
                    label: 'English',
                    selected: !hindi,
                    onTap: () => Navigator.of(ctx).pop(false),
                  ),
                  PvChip(
                    label: 'हिंदी',
                    selected: hindi,
                    onTap: () => Navigator.of(ctx).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (v == null) return;
    if (stage.shopStage == LifeStage.tryingToConceive) {
      TtcLang.instance.hinglish = v;
    } else {
      PregnancyController.current?.setLanguage(
        v ? AppLanguage.hinglish : AppLanguage.english,
      );
    }
    if (mounted) setState(() {});
  }

  // ---- G: support ---------------------------------------------------------------------------

  Widget _support(V2Palette p, LifeStage stage) {
    final ctl = PregnancyController.current;
    final sponsor = EntitlementStore.instance.sponsor;
    return PvYouSection(
      title: 'Support',
      children: [
        PvYouRow(
          icon: Icons.help_outline_rounded,
          title: 'Help',
          subtitle: 'Questions about the app, orders or bookings',
          onTap: () => pvSnack(
            context,
            'Help opens here once support is set up. Until then, write to hello@parentveda.in.',
          ),
        ),
        PvYouRow(
          icon: Icons.card_giftcard_outlined,
          title: 'Invite a friend',
          onTap: () => _push(InviteFriendsScreen(controller: ctl), 'invite'),
        ),
        PvYouRow(
          icon: Icons.business_center_outlined,
          title: sponsor == null
              ? 'Employer benefits'
              : 'Your benefits from ${sponsor.name}',
          subtitle: sponsor == null
              ? 'Does your employer offer ParentVeda?'
              : null,
          onTap: () => _push(
            EmployerBenefitsScreen(lang: ctl?.language ?? AppLanguage.english),
            'employer',
          ),
        ),
        PvYouRow(
          icon: Icons.info_outline_rounded,
          title: 'About ParentVeda',
          subtitle: 'How we review, how we sell, who we are',
          onTap: () => _about(p),
        ),
      ],
    );
  }

  Future<void> _about(V2Palette p) => showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ParentVeda',
              style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: p.ink1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'A calm companion from trying to conceive through pregnancy, parenting and your child\'s first skills. '
              'Nothing here is a diagnosis; your own doctor\'s word comes first. '
              'Some products are ours and some are affiliate links — every product page says which, and "ParentVeda recommends" appears on a few, with the reason and the reviewer\'s name. '
              'Community is never used as a source.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
            ),
            const SizedBox(height: 12),
            Text(
              'Made in India · English and हिंदी',
              style: pvManrope(fontSize: 12, color: p.ink3),
            ),
          ],
        ),
      ),
    ),
  );

  // ---- H: account -----------------------------------------------------------------------------

  Widget _account(V2Palette p, LifeStage stage) {
    final signedIn = SupabaseRepo.isLoggedIn;
    return PvYouSection(
      title: 'Account',
      children: [
        PvYouRow(
          icon: Icons.person_outline_rounded,
          title: signedIn ? 'Signed in' : 'Not signed in',
          subtitle: signedIn
              ? (_email ?? _phone ?? '')
              : 'Sign in to keep everything across phones',
          value: _phoneVerified ? 'Phone verified' : null,
          onTap: signedIn ? null : () => pvSignOut(context),
        ),
        PvYouRow(
          icon: Icons.shield_outlined,
          title: 'Data and privacy',
          subtitle: 'What we store, download it, delete it',
          onTap: () => _push(PvDataPrivacyScreen(stage: stage), 'you/privacy'),
        ),
        if (signedIn)
          PvYouRow(
            icon: Icons.logout_rounded,
            title: 'Sign out',
            onTap: () => pvSignOut(context),
          ),
        PvYouRow(
          icon: Icons.delete_outline_rounded,
          title: 'Delete account',
          danger: true,
          onTap: () => pvDeleteAccount(context),
        ),
      ],
    );
  }

  /// The team's affordances, `kDebugMode` only. The stage switch lives HERE
  /// and nowhere else on You: a family trying to conceive is not pregnant,
  /// and their real way forward is the one action under Your journey. This
  /// is how the team moves between shells without re-onboarding — the same
  /// reason the classic profiles carried "· testing" buttons in the open.
  Widget _developer(V2Palette p) {
    final ctl = PregnancyController.current;
    final current = LifeStageStore.instance.stage;
    return PvYouSection(
      title: 'Developer · debug only',
      lead:
          'Version pills, the stage switch, a clean week-20 reset. Never in a release.',
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Stage · testing',
                style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: p.ink1,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in StageDoor.values)
                    PvChip(
                      label: d.label,
                      selected: _doorOf(current) == d,
                      onTap: () => _switchStage(d),
                    ),
                ],
              ),
              // The TTC "view as her / him" switch — the classic TTC
              // profile's `_ModeSegment`, a testing affordance for crossing
              // between the two halves of that stage. Debug only, here,
              // because Profile is the one surface both shells share.
              if (_stage == LifeStage.tryingToConceive) ...[
                const SizedBox(height: 14),
                Text(
                  'View as · testing',
                  style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: p.ink1,
                  ),
                ),
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: TtcPartnerMode.instance,
                  builder: (context, _) {
                    final t = TtcS.current();
                    final him = TtcPartnerMode.instance.on;
                    return Wrap(
                      spacing: 8,
                      children: [
                        PvChip(
                          label: t.partnerHer,
                          selected: !him,
                          onTap: () => TtcPartnerMode.instance.on = false,
                        ),
                        PvChip(
                          label: t.partnerHim,
                          selected: him,
                          onTap: () => TtcPartnerMode.instance.on = true,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
        if (ctl != null)
          PvYouRow(
            icon: Icons.refresh_rounded,
            title: 'Reset to week 20 · testing',
            subtitle:
                'Clears the due date, journey dates and scans; back to the placeholder week',
            onTap: () async {
              final nav = Navigator.of(context);
              await ctl.resetForTesting();
              JourneyDatesStore.instance.clearAll();
              await ScansStore.instance.clearAllForTesting();
              AppNav.instance.goToday();
              nav.popUntil((r) => r.isFirst);
            },
          ),
        // ⚠️ A WALK DOOR, NOT A RESET. Onboarding only runs on a fresh
        // install, so the only way to look at it on a phone that has already
        // been through it was `adb shell pm clear` — which wipes the due
        // date, the logs and the saved items the device walk needs. This
        // opens the real flow with a no-op finish: nothing it writes is kept
        // and it pops back here. Debug builds only, like everything in this
        // section.
        if (ctl != null)
          PvYouRow(
            icon: Icons.restart_alt_rounded,
            title: 'Replay onboarding · testing',
            subtitle:
                'Opens the first-run flow; finishing it just comes back here',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'dev/onboarding'),
                builder: (ctx) => OnboardingFlow(
                  pregnancy: ctl,
                  onDone: (_, _) => Navigator.of(ctx).maybePop(),
                  onDoctor: (_) => Navigator.of(ctx).maybePop(),
                ),
              ),
            ),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
          child: DeveloperSwitches(),
        ),
      ],
    );
  }

  static StageDoor? _doorOf(LifeStage? s) => switch (s) {
    LifeStage.tryingToConceive => StageDoor.tryingToConceive,
    LifeStage.pregnancy => StageDoor.pregnancy,
    LifeStage.parenting => StageDoor.parenting,
    _ => null,
  };

  /// The stage is written first and the navigation second, on purpose: if
  /// the swap fails we are still in the state that was asked for and the
  /// next launch honours it. `openStageDoor` returns false only when the
  /// pregnancy shell is not registered (a widget test), so the message is
  /// the genuinely-stuck path, not the ordinary one.
  void _switchStage(StageDoor d) {
    LifeStageStore.instance.setStage(switch (d) {
      StageDoor.tryingToConceive => LifeStage.tryingToConceive,
      StageDoor.pregnancy => LifeStage.pregnancy,
      StageDoor.parenting => LifeStage.parenting,
    });
    if (!openStageDoor(context, d)) {
      pvSnack(context, 'Stage set. Close and reopen the app to see it.');
    }
  }

  // ---- the floating pill (Airbnb's "Switch to hosting") -------------------------------------

  Widget _viewingAsPill(V2Palette p) {
    final fatherOn = FatherPreview.instance.on;
    final label = fatherOn ? 'Back to $_partnerName' : 'View as $_partnerName';
    return Positioned(
      left: 0,
      right: 0,
      // Above the bar when there is one.
      bottom:
          MediaQuery.of(context).padding.bottom +
          (widget.bottomNav == null ? 20 : 96),
      child: Center(
        child: InkWell(
          onTap: () {
            FatherPreview.instance.on = !fatherOn;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(
                builder: (_) => PvYouScreen(
                  stage: widget.stage,
                  father: !fatherOn,
                  bottomNav: widget.bottomNav,
                ),
                // The same name, so a tab stays the tab it was.
                settings: RouteSettings(
                  name: ModalRoute.of(context)?.settings.name ?? kPvYouRoute,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: p.ink1,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swap_horiz_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: pvManrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
