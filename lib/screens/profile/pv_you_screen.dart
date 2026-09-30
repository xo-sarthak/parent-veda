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
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

import '../auth/onboarding/onboarding_flow.dart';
import '../../booking/booking_store.dart';
import '../../care_partner/care_visibility.dart';
import '../../localization/app_language.dart';
import '../../screens/post_pregnancy/pp_child_profile.dart';
import '../../services/app_nav.dart';
import '../../services/entitlement_store.dart';
import '../../services/family_profile.dart';
import '../../services/ready_birth_context_store.dart';
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
import '../learn/pv_my_learning_screen.dart' show PvMyLearningScreen;
import '../post_pregnancy/family_profile_screen.dart';
import '../pregnancy_profile_screen.dart';
import '../products/pv_orders_screen.dart';
import '../referral/invite_friends_screen.dart';
import '../reminders_screen.dart';
import '../skilling/sk_child_store.dart';
import '../ttc/ttc_strings.dart' show TtcLang, TtcPartnerMode, TtcS;
import 'pv_account_actions.dart';
import 'pv_child_screen.dart';
import 'pv_data_privacy_screen.dart';
import 'pv_details_screen.dart';
import 'pv_more_bento.dart';
import 'pv_partner_screen.dart';
import 'pv_settings_screen.dart';
import '../ttc/doors/ttc_tab_art.dart' show TtcTabArt, TtcTabMark;
import '../ttc/ttc_more_marks.dart' show TtcMoreArt, TtcMoreMark;
import '../ttc/ttc_tool_marks.dart' show TtcToolArt, TtcToolMark;
import '../../ttc/cycle_store.dart' show CycleStore;
import '../../ttc/ttc_day_context.dart' show ttcDayContext;
import 'pv_profile_marks.dart';
import '../ttc/ttc_content_prefs_sheet.dart' show kTtcWhatYouSee;
import '../ttc/ttc_get_help_screen.dart' show kTtcGetHelpTitle;
import '../v2/v2_palette.dart';
import 'pv_you_chrome.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/profile_photo_store.dart';
import '../ttc/ttc_surface_router.dart' show openTtcSurface;
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

/// Where "Contact us" writes (the address Help has always named).
const String kPvContactEmail = 'hello@parentveda.in';

/// ⚠️ THE TTC TAB IS "MORE", A BENTO (2026-09-28, the user: "the last option
/// in bottom navigation pill should be 'more' not you ... for each heading
/// follow bento design ... like CRED"). On trying to conceive the screen
/// draws the identity card, then one tile per heading (`pv_more_bento.dart`),
/// and a tile opens its rows on a page of their own. Every other stage draws
/// the eight sections exactly as before.
///
/// Kept for revert: false draws TTC's short grouped list of 2026-09-27 again,
/// whose code is untouched below (`_journey`, `_family`, `_things`, …).
///
/// ⚠️ SUPERSEDED 2026-09-29 by [kPvTtcProfileV2]: the user found the bento
/// "poor", and More and the avatar opened the same screen. More is its own
/// screen now (lib/screens/ttc/ttc_more_tab.dart) and this screen is her
/// profile. The bento only draws again if both flags are flipped.
/// Kept for revert: const bool kPvTtcMoreBento = true;
const bool kPvTtcMoreBento = false;

/// ⚠️ TTC'S PROFILE (2026-09-29). On trying to conceive this screen is the
/// PROFILE the avatar opens: the identity card, her stage, her answers, her
/// notes for the doctor, her family, Saved, and ONE Settings row into
/// `PvSettingsScreen` (account, preferences, notifications, privacy, support,
/// about, and Developer last). What the app offers lives on More. Every other
/// stage draws its eight sections exactly as before. Where each former row
/// went: `kTtcFormerYouRows` (ttc_more_tab.dart), held by
/// `test/ttc_more_profile_test.dart`.
///
/// From Mobbin: Airbnb's Profile (identity card, a few rows, one settings
/// row: https://mobbin.com/screens/8f7c5b27-db62-48f9-a403-7b8bdba1253b) and
/// Flo's (the identity, "My goal" as the stage, "Report for a doctor", then
/// Settings: https://mobbin.com/screens/b633224b-1ff0-48de-b39b-23f37ea41c41).
const bool kPvTtcProfileV2 = true;

/// ⚠️ TTC'S PROFILE, V3 (2026-09-29, build 19). The user: the V2 profile
/// "looks very bad. It's very random", its top "does not make any sense",
/// and "spacing, margins, a lot of things are not right". V3 is a hero (a
/// soft band, a large monogram, her name in the serif, ONE status line
/// derived from her cycle, her partner status, Edit as a small pill), a
/// glance of two facts from her own logs, then short headed groups whose
/// every row leads with a drawn mark in one tint, and one Settings row. The
/// chapter stepper is gone: no profile on Mobbin draws the life stages as a
/// track, and she cannot act on one. "I got a positive test" is a row of its
/// own under Your journey. The parts and the Mobbin evidence are in
/// pv_you_chrome.dart ("THE PROFILE, V3").
///
/// Kept for revert: false draws V2 (`_ttcProfile`) exactly as it was.
const bool kPvTtcProfileV3 = true;

/// The Settings row's key on the profile, for tests.
const Key kPvProfileSettingsRowKey = ValueKey('pv_profile_settings');

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
    this.onSwitchViewer,
  });

  /// What the "View as" pill does when the screen is a tab of a host rather
  /// than a route of its own (TTC's tab host, 2026-09-28). Null, everywhere
  /// else, keeps the pill's route swap. Inside the host the swap would have
  /// REPLACED the stage's home route, the host with it.
  final VoidCallback? onSwitchViewer;

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

  /// Ticks on every setState, so a bento page (a route of its own, built
  /// from this state's row builders) repaints when this state changes: the
  /// WhatsApp switch and the language live in this state, not in a store.
  final ValueNotifier<int> _tick = ValueNotifier<int>(0);

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _tick.value++;
  }

  @override
  void dispose() {
    _tick.dispose();
    super.dispose();
  }

  /// Everything the screen repaints on.
  List<Listenable> get _listenables => [
    LifeStageStore.instance,
    FamilyProfileStore.instance,
    ChildProfileStore.instance,
    SavedStore.instance,
    PvOrderStore.instance,
    EntitlementStore.instance,
    SkChildStore.instance,
    FatherPreview.instance,
    // The profile's glance and status line read her cycle (V3, 2026-09-29).
    CycleStore.instance,
    // The bookings tile's line reads the next session (2026-09-29).
    BookingStore.instance,
    // Her photo on the hero (2026-09-30).
    ProfilePhotoStore.instance,
    // The Twins or more row reads it (2026-09-30).
    ReadyBirthContextStore.instance,
    if (PregnancyController.current != null) PregnancyController.current!,
  ];

  @override
  void initState() {
    super.initState();
    PvOrderStore.instance.init();
    ProfilePhotoStore.instance.load();
    _load();
  }

  // ---- her photo (2026-09-30) ---------------------------------------------------

  /// Add, change or remove her photo: one sheet, three plain choices (Flo's
  /// avatar pencil, the platform's own photo sheet). The camera asks for its
  /// permission first, because the app declares the camera for video calls
  /// and Android then refuses a camera intent without it; a refusal says so
  /// kindly and changes nothing.
  Future<void> _photoSheet() async {
    final has = ProfilePhotoStore.instance.hasPhoto;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        Widget row(String id, IconData icon, String label, {bool danger = false}) =>
            ListTile(
              key: ValueKey('pv_profile_photo_$id'),
              leading: Icon(icon, color: danger ? const Color(0xFFC6295A) : pvStorePalette.ink1),
              title: Text(
                label,
                style: pvManrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: danger ? const Color(0xFFC6295A) : pvStorePalette.ink1,
                ),
              ),
              onTap: () => Navigator.of(ctx).pop(id),
            );
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Text(
                    has ? 'Your photo' : 'Add a photo',
                    style: pvFraunces(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: pvStorePalette.ink1,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'It stays on this phone and shows on your profile and your home.',
                    style: pvManrope(
                      fontSize: 13,
                      height: 1.4,
                      color: pvStorePalette.ink3,
                    ),
                  ),
                ),
                row('camera', Icons.photo_camera_outlined, 'Take a photo'),
                row('gallery', Icons.photo_library_outlined, 'Choose from your photos'),
                if (has)
                  row('remove', Icons.delete_outline_rounded, 'Remove photo',
                      danger: true),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || choice == null) return;
    if (choice == 'remove') {
      await ProfilePhotoStore.instance.remove();
      if (mounted) pvSnack(context, 'Photo removed', icon: Icons.check_rounded);
      return;
    }
    final camera = choice == 'camera';
    try {
      if (camera) {
        final status = await Permission.camera.request();
        if (!status.isGranted) {
          if (mounted) {
            pvSnack(context,
                'The camera needs your permission. You can choose a photo instead.');
          }
          return;
        }
      }
      final x = await ImagePicker().pickImage(
        source: camera ? ImageSource.camera : ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 88,
      );
      if (x == null) return;
      await ProfilePhotoStore.instance.setFrom(x.path);
      if (mounted) pvSnack(context, 'Photo saved', icon: Icons.check_rounded);
    } catch (_) {
      if (mounted) pvSnack(context, 'That photo could not be added. Try another.');
    }
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

  /// Whether [_name] is a name she gave, not the placeholder.
  bool get _hasName {
    final c = PregnancyController.current;
    return _nonEmpty(widget.father ? c?.fatherName : c?.myName) != null;
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

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
    // ⚠️ NOT DISPOSED ON THE SAME FRAME (2026-09-28, found by
    // test/ttc_no_repetition_test.dart). The sheet's future completes when
    // the pop STARTS, and the TextField is rebuilt through the whole slide
    // down; disposing here tripped "used after being disposed" in debug. The
    // controller is let go once the sheet has left. Kept for revert:
    //   ctl.dispose();
    Future<void>.delayed(const Duration(milliseconds: 600), ctl.dispose);
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
    // TTC only: the groups are its signal, as they were for the short list.
    // Kept for revert: final bento = kPvTtcMoreBento && content.groups != null;
    final ttcProfile = kPvTtcProfileV2 && content.groups != null;
    final ttcV3 = ttcProfile && kPvTtcProfileV3;
    final bento = !ttcProfile && kPvTtcMoreBento && content.groups != null;
    return ListenableBuilder(
      listenable: Listenable.merge(_listenables),
      builder: (context, _) {
        final sponsor = EntitlementStore.instance.sponsor;
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // V3's hero carries its own bar (the back button and the
                  // title sit on its band).
                  if (!ttcV3)
                  SliverToBoxAdapter(
                    // Kept for revert: title: bento ? 'More' : 'You'
                    child: _topBar(
                      p,
                      title: ttcProfile ? 'Profile' : (bento ? 'More' : 'You'),
                    ),
                  ),
                  if (ttcV3) ...[
                    for (final w in _ttcProfileV3(p, stage, content))
                      SliverToBoxAdapter(child: w),
                  ] else if (ttcProfile) ...[
                    for (final w in _ttcProfile(p, stage, content))
                      SliverToBoxAdapter(child: w),
                  ] else if (bento) ...[
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
                    SliverToBoxAdapter(
                      child: PvBentoGrid(tiles: _bentoTiles(p, stage, content)),
                    ),
                  ] else ...[
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
                  ],
                  // On TTC's profile the footer and Developer live in Settings
                  // (2026-09-29): the profile is about her, nothing else.
                  if (!ttcProfile)
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
                  if (kPvShowDeveloper && !ttcProfile)
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

  Widget _topBar(V2Palette p, {String title = 'You'}) => Padding(
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
            // Kept for revert: 'You' on every stage. TTC's tab says More.
            title,
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

  // ---- the bento (TTC's More tab, 2026-09-28) ----------------------------------------

  /// Opens one tile's rows on a page of their own. The rows are this
  /// state's own builders, so every row keeps its destination; the page
  /// repaints on the same stores and on this state's setState.
  void _openGroup(
    String id,
    String title,
    String caption,
    List<Widget> Function() rows,
  ) => _push(
    PvMoreGroupScreen(
      title: title,
      caption: caption,
      rows: rows,
      listen: Listenable.merge([..._listenables, _tick]),
    ),
    'you/more/$id',
  );

  PvBentoTileData _tile({
    required String id,
    required String title,
    required String caption,
    required IconData icon,
    required double? hue,
    required List<Widget> Function() rows,
    String? Function()? status,
    bool Function()? dot,
    Listenable? listen,
  }) => PvBentoTileData(
    id: id,
    title: title,
    caption: caption,
    icon: icon,
    hue: hue,
    status: status,
    dot: dot,
    listen: listen,
    onTap: () => _openGroup(id, title, caption, rows),
  );

  /// One tile per heading, in the grid's order: her health tall first (the
  /// most used), her things and the app beside it, the journey full width,
  /// then pairs. Every heading the list drew is here, and nothing else.
  List<PvBentoTileData> _bentoTiles(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content,
  ) {
    final groups = content.groups ?? const <PvYouGroup>[];
    // Sage, blue-grey, teal, then spares: meaning, not prettiness (the
    // home's V2BlockHues rule). No violet.
    const groupHues = [150.0, 206.0, 176.0, 96.0, 120.0];
    PvBentoTileData group(int i) {
      final g = groups[i];
      return _tile(
        // "Your health" → your_health, for its key and its route name.
        id: g.title.toLowerCase().replaceAll(RegExp('[^a-z0-9]+'), '_'),
        title: g.title,
        caption: g.caption ?? g.things.map((t) => t.title).join(', '),
        icon: g.icon ?? Icons.folder_open_outlined,
        hue: groupHues[i % groupHues.length],
        status: g.status,
        dot: g.dot,
        listen: g.listen,
        rows: () => [for (final t in g.things) _thingRow(p, t)],
      );
    }

    // "Your things": the counted tiles of the old row, as rows. The caption
    // is read from them, so it cannot name one that has gone.
    final things = content.tiles;
    final thingNames = [
      for (var i = 0; i < things.length; i++)
        i == 0 ? things[i].title : things[i].title.toLowerCase(),
    ];
    final thingsCaption = thingNames.length < 2
        ? thingNames.join()
        : '${thingNames.sublist(0, thingNames.length - 1).join(', ')} and ${thingNames.last}';
    String? thingsStatus() {
      final parts = [
        for (final t in things)
          // "1 order", not "1 orders" (2026-09-28): a count of one takes the
          // singular. Kept for revert: '${t.count!()} ${t.title.toLowerCase()}'.
          if ((t.count?.call() ?? 0) > 0) _countLine(t.count!(), t.title),
      ];
      return parts.isEmpty ? null : parts.join(' · ');
    }

    final a = content.action;
    final signedIn = SupabaseRepo.isLoggedIn;
    return [
      if (groups.isNotEmpty) group(0),
      _tile(
        id: 'things',
        title: 'Your things',
        // A stage may name the contents more fully (2026-09-28: TTC's one
        // row is Saved, and "Saved" alone did not say what is in it).
        caption: content.tilesCaption ?? thingsCaption,
        icon: Icons.bookmark_outline_rounded,
        hue: 36,
        status: thingsStatus,
        rows: () => [for (final t in things) _thingRow(p, t)],
      ),
      if (groups.length > 1) group(1),
      _tile(
        id: 'journey',
        title: 'Your journey',
        caption: widget.father
            ? '$_partnerName\'s journey, which moves when she says so'
            : (content.journeyCaption ??
                  (a == null
                      ? 'Where you are across the four chapters'
                      : 'Where you are, and the "${a.label}" button')),
        icon: Icons.route_outlined,
        hue: 350,
        // The stage's journey rows under the chapters (2026-09-28: TTC's
        // journey map, which left Tools). Empty on every other stage. Kept
        // for revert: rows: () => _journeyRows(p, stage, content, stepper: true),
        rows: () => [
          ..._journeyRows(p, stage, content, stepper: true),
          for (final t in content.journeyThings) _thingRow(p, t),
        ],
      ),
      _tile(
        id: 'family',
        title: 'Family',
        caption: widget.father
            ? 'Your pairing with $_partnerName'
            : (_partnerLinked
                  ? 'Paired with $_partnerName'
                  : 'Invite your partner to a side of their own'),
        icon: Icons.people_outline_rounded,
        hue: 20,
        rows: () => _familyRows(p, stage, content),
      ),
      for (var i = 2; i < groups.length; i++) group(i),
      _tile(
        id: 'preferences',
        title: 'Preferences',
        // "What leads on your home" was the Personalise row, which is not on
        // this stage since 2026-09-28 (its page is Your answers, under Your
        // health). Kept for revert:
        //   'Language, reminders, WhatsApp updates and what leads on your home',
        caption: 'Language, reminders and WhatsApp updates',
        icon: Icons.tune_rounded,
        hue: 222,
        rows: () => _preferencesRows(p, stage),
      ),
      _tile(
        id: 'support',
        title: 'Support',
        caption:
            'Help, invite a friend, employer benefits and about ParentVeda',
        icon: Icons.help_outline_rounded,
        hue: 48,
        rows: () => _supportRows(p, stage),
      ),
      _tile(
        id: 'account',
        title: 'Account',
        caption: signedIn
            ? 'How you are signed in, data and privacy, signing out, deleting your account'
            : 'Signing in, data and privacy, deleting your account',
        icon: Icons.person_outline_rounded,
        hue: null,
        rows: () => _accountRows(p, stage),
      ),
    ];
  }

  // ---- B: your journey ------------------------------------------------------------

  Widget _journey(V2Palette p, LifeStage stage, PvYouStageContent content) {
    return PvYouSection(
      title: 'Your journey',
      children: _journeyRows(p, stage, content),
    );
  }

  /// The journey's body, shared by its section and its bento page.
  ///
  /// [stepper] (the bento page only) draws the four chapters as four equal
  /// columns whose names shrink to fit, so the row holds at 360dp and at
  /// large text. The row the other stages draw is untouched; it overflows at
  /// 360dp (STILL-OPEN §79.10) and stays theirs to change.
  List<Widget> _journeyRows(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content, {
    bool stepper = false,
  }) {
    const chapters = [
      (LifeStage.tryingToConceive, 'Trying'),
      (LifeStage.pregnancy, 'Pregnancy'),
      (LifeStage.parenting, 'Parenting'),
      (LifeStage.skilling, '6+'),
    ];
    final idx = chapters.indexWhere((c) => c.$1 == stage);
    final a = content.action;
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stepper)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < chapters.length; i++)
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 12,
                            child: Row(
                              children: [
                                Expanded(
                                  child: i == 0
                                      ? const SizedBox()
                                      : Container(
                                          height: 1.5,
                                          color: i <= idx ? p.ink1 : kPvLine,
                                        ),
                                ),
                                Container(
                                  width: i == idx ? 12 : 8,
                                  height: i == idx ? 12 : 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: i <= idx ? p.ink1 : Colors.white,
                                    border: Border.all(
                                      color: i <= idx ? p.ink1 : p.ink3,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: i == chapters.length - 1
                                      ? const SizedBox()
                                      : Container(
                                          height: 1.5,
                                          color: i < idx ? p.ink1 : kPvLine,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              chapters[i].$2,
                              maxLines: 1,
                              style: pvManrope(
                                fontSize: 11.5,
                                fontWeight: i == idx
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: i == idx ? p.ink1 : p.ink3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            else
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
    ];
  }

  // ---- C: family --------------------------------------------------------------------

  Widget _family(V2Palette p, LifeStage stage, PvYouStageContent content) =>
      PvYouSection(title: 'Family', children: _familyRows(p, stage, content));

  /// The family's rows, shared by its section and its bento page.
  List<Widget> _familyRows(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content,
  ) {
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
    return [
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
          onOpen: (id) =>
              _push(PvChildScreen(childId: id, stage: stage), 'you/child/$id'),
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
    ];
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

  /// [leading] is a drawn mark in place of the icon (TTC's profile).
  Widget _thingRow(V2Palette p, PvYouThing thing, {Widget? leading}) {
    Widget row() => PvYouRow(
      icon: thing.icon,
      leading: leading,
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

  Widget _preferences(V2Palette p, LifeStage stage) =>
      PvYouSection(title: 'Preferences', children: _preferencesRows(p, stage));

  /// The preferences' rows, shared by its section and its bento page.
  ///
  /// ⚠️ SPLIT INTO ITS ROWS (2026-09-29), so TTC's Settings page can put
  /// Language under Preferences and Reminders and WhatsApp under
  /// Notifications. The list below is the same rows in the same order.
  bool _hindiFor(LifeStage stage) =>
      stage.shopStage == LifeStage.tryingToConceive
      ? TtcLang.instance.hinglish
      : (PregnancyController.current?.language.isHindi ?? false);

  Widget _languageRow(LifeStage stage) {
    final hindi = _hindiFor(stage);
    return PvYouRow(
      icon: Icons.translate_rounded,
      title: 'Language',
      value: hindi ? 'हिंदी' : 'English',
      onTap: () => _pickLanguage(stage, hindi),
    );
  }

  /// [0] Language, [1] Reminders, [2] WhatsApp updates, then Personalise on
  /// every stage but TTC. TTC's Settings reads [1] and [2] by position.
  List<Widget> _preferencesRows(V2Palette p, LifeStage stage) {
    final ctl = PregnancyController.current;
    final hindi = _hindiFor(stage);
    return [
      _languageRow(stage),
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
          // ⚠️ NO NUMBER, NO "ON" (2026-09-30, found by the profile walk
          // test). With no phone on file the switch said "WhatsApp updates
          // on." with nowhere to send them. It stays off and says what it
          // needs instead.
          if (v && (_phone == null || _phone!.isEmpty)) {
            pvSnack(
              context,
              'WhatsApp needs your phone number. Sign in with your number to turn this on.',
            );
            return;
          }
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
      // ⚠️ NOT ON TRYING TO CONCEIVE (2026-09-28, the user: "no random
      // repetition"). On this stage the row opened Your details, the same
      // page as Reminders just above it (there scrolled to its reminders)
      // and as "Your answers" under Your health: one page behind three rows.
      // "Your answers" is its one entrance on this stage; every other stage
      // keeps the row, which opens a profile of its own there. Kept for
      // revert: the row on every stage.
      if (stage.shopStage != LifeStage.tryingToConceive)
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
    ];
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

  Widget _support(V2Palette p, LifeStage stage) =>
      PvYouSection(title: 'Support', children: _supportRows(p, stage));

  /// Support's rows, shared by its section and its bento page.
  List<Widget> _supportRows(V2Palette p, LifeStage stage) {
    final ctl = PregnancyController.current;
    final sponsor = EntitlementStore.instance.sponsor;
    return [
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
    ];
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

  Widget _account(V2Palette p, LifeStage stage) =>
      PvYouSection(title: 'Account', children: _accountRows(p, stage));

  /// The account's rows, shared by its section and its bento page.
  ///
  /// [privacy] false leaves out the Data and privacy row, which TTC's
  /// Settings page draws under its own "Privacy and data" heading
  /// (2026-09-29). Every other caller keeps it.
  List<Widget> _accountRows(
    V2Palette p,
    LifeStage stage, {
    bool privacy = true,
  }) {
    final signedIn = SupabaseRepo.isLoggedIn;
    return [
      PvYouRow(
        icon: Icons.person_outline_rounded,
        title: signedIn ? 'Signed in' : 'Not signed in',
        subtitle: signedIn
            ? (_email ?? _phone ?? '')
            : 'Sign in to keep everything across phones',
        value: _phoneVerified ? 'Phone verified' : null,
        onTap: signedIn ? null : () => pvSignOut(context),
      ),
      if (privacy) _privacyRow(stage),
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
    ];
  }

  Widget _privacyRow(LifeStage stage) => PvYouRow(
    icon: Icons.shield_outlined,
    title: 'Data and privacy',
    // Change 5 (2026-09-28): the row names what is downloaded or
    // deleted. Every stage. Kept for revert:
    //   'What we store, download it, delete it'
    subtitle: 'What we store; download or delete your data',
    onTap: () => _push(PvDataPrivacyScreen(stage: stage), 'you/privacy'),
  );

  // ---- TTC's profile and its Settings page (2026-09-29) -----------------------------

  /// The TTC profile, top to bottom: who she is, where she is, what she told
  /// us, her notes for the doctor, her family, what she saved, and one
  /// Settings row. Her answers and her doctor notes are hers: his view
  /// (father) never draws them.
  List<Widget> _ttcProfile(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content,
  ) {
    final sponsor = EntitlementStore.instance.sponsor;
    // Airbnb's Profile and Flo's: the identity names the stage and the
    // partner, so she sees both before she scrolls.
    final partnerLine = widget.father
        ? 'Partner of $_partnerName'
        : (_partnerLinked
              ? 'Paired with $_partnerName'
              : 'Not paired with your partner yet');
    Color tint(double hue) => v2BlockTint(hue, p);
    Widget markRow(PvYouThing t, double hue) =>
        _thingRow(p, t, leading: t.art?.call(tint(hue)));
    return [
      PvIdentityCard(
        name: _name,
        meta: partnerLine,
        clock: widget.father
            ? '$_partnerName · ${content.clock()}'
            : content.clock(),
        verified: _phoneVerified,
        chip: sponsor?.name,
        onEdit: widget.father ? null : _editName,
      ),
      // Flo's "My goal": the stage she is in and the one way forward.
      PvYouSection(
        key: const ValueKey('pv_profile_stage'),
        title: 'Your stage',
        children: _journeyRows(p, stage, content, stepper: true),
      ),
      if (!widget.father)
        PvYouSection(
          key: const ValueKey('pv_profile_answers'),
          title: 'Your answers',
          lead: 'What you told us. Your answers decide what leads on your home.',
          // ⚠️ THE FACTS, THEN ONE WAY TO CHANGE THEM (Klima's Account: the
          // values on the right, one edit). Every detail opened the same
          // answers page, so five taps to one page read as repetition
          // (test/ttc_no_repetition_test.dart). Kept for revert: each row
          // tappable, onTap: () => d.edit(context).
          children: [
            for (final d in content.details)
              PvYouRow(
                icon: Icons.notes_rounded,
                leading: d.art?.call(tint(206)),
                title: d.label,
                subtitle: d.note,
                value: d.value(),
              ),
            PvYouRow(
              key: const ValueKey('pv_profile_change_answers'),
              icon: Icons.edit_outlined,
              leading: TtcTabArt(mark: TtcTabMark.checklist, tint: tint(206)),
              title: 'Change your answers',
              onTap: () => _push(
                const PvDetailsScreen(stageId: 'trying'),
                'you/details',
              ),
            ),
          ],
        ),
      if (!widget.father && content.profileThings.isNotEmpty)
        PvYouSection(
          key: const ValueKey('pv_profile_doctor'),
          title: 'For your doctor',
          children: [for (final t in content.profileThings) markRow(t, 150)],
        ),
      PvYouSection(
        key: const ValueKey('pv_profile_family'),
        title: 'Family',
        children: _familyRows(p, stage, content),
      ),
      PvYouSection(
        key: const ValueKey('pv_profile_things'),
        title: 'Your things',
        children: [for (final t in content.tiles) markRow(t, 36)],
      ),
      // ONE Settings row, apart from the sections (Airbnb's "Account
      // settings" under the profile's rows).
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: kPvLine),
          ),
          child: PvYouRow(
            key: kPvProfileSettingsRowKey,
            icon: Icons.settings_outlined,
            leading: TtcMoreArt(mark: TtcMoreMark.gear, tint: tint(222)),
            title: 'Settings',
            subtitle: 'Account, language, notifications, privacy and help',
            onTap: () => _openSettings(p, stage, content),
          ),
        ),
      ),
    ];
  }

  // ---- TTC's profile, V3 (2026-09-29) --------------------------------------------

  /// The one tint of the page: the hero's band and every row's mark.
  Color _profileTint(V2Palette p) => v2BlockTint(kPvProfileMarkHue, p);

  /// ONE plain status line, derived from her data and never asked: the
  /// stage, and today's cycle day when her latest logged period opened the
  /// cycle she is in. A cycle day is a count from a date she logged, not a
  /// prediction, so it holds on a clinic's cycle too. Past day 60 the log is
  /// stale rather than her cycle long, so the day is left out.
  ///
  /// His line names who he is trying with, and nothing of her cycle: her
  /// logs are hers.
  String _ttcStatus() {
    if (widget.father) {
      return _partnerLinked
          ? 'Trying to conceive with $_partnerName'
          : 'Trying to conceive';
    }
    try {
      final ctx = ttcDayContext(DateTime.now());
      final d = ctx.cycleDay;
      if (ctx.isCurrentCycle && d != null && d > 0 && d <= 60) {
        return 'Trying to conceive · cycle day $d';
      }
    } catch (_) {
      // Local-first: a store that has not loaded is a line without a day.
    }
    return 'Trying to conceive';
  }

  /// Two facts from her own logs (Lifesum's card, Headspace's Stats): her
  /// usual cycle once it is hers, and how many periods she has logged. An
  /// average of her own cycles is a fact about the past, never a chance.
  Widget _ttcGlance({double top = 24}) {
    final n = CycleStore.instance.periodStarts.length;
    var own = false;
    var usual = 0;
    try {
      final ctx = ttcDayContext(DateTime.now());
      own = ctx.hasOwnLength;
      usual = ctx.usualLength;
    } catch (_) {
      own = false;
    }
    // ⚠️ NO DASHES (2026-09-30, the user: two dashes over "Your usual
    // cycle" when nothing is logged). Nothing logged: one card that says
    // what will be here and starts it. One period: "Not yet", in words, and
    // what brings it. Kept for revert: facts ('--', 'Your usual cycle') and
    // ('0', 'Periods logged') with a grey note.
    if (n == 0) {
      return PvProfileGlance(
        key: const ValueKey('pv_profile_glance'),
        top: top,
        facts: const [],
        mark: TtcTabArt(
          mark: TtcTabMark.cycleDrops,
          tint: _profileTint(pvStorePalette),
        ),
        title: 'Your cycle at a glance',
        note: 'Log your first period and your usual cycle length and the '
            'periods you have logged show here.',
        actionLabel: 'Log your period',
        onAction: () => openTtcSurface(context, 'ttc_calendar'),
      );
    }
    return PvProfileGlance(
      key: const ValueKey('pv_profile_glance'),
      top: top,
      facts: [
        (own ? '$usual days' : kPvGlancePending, 'Your usual cycle'),
        ('$n', n == 1 ? 'Period logged' : 'Periods logged'),
      ],
      // What unlocks "Not yet", said once (derive, never ask).
      note: own ? null : 'Your usual cycle shows after your next period.',
    );
  }

  /// The two tiles under the hero: Your orders and Your bookings, each with
  /// a drawn mark in the page's one tint and one line of state. The lines
  /// are counts and dates from her own records, never a promise the store
  /// has not made.
  Widget _ttcOrdersAndBookings(Color tint) => PvProfileTiles(
    key: const ValueKey('pv_profile_purchases'),
    tiles: [
      PvProfileTile(
        key: const ValueKey('pv_profile_orders'),
        mark: TtcMoreArt(mark: TtcMoreMark.parcel, tint: tint),
        title: kPvProfileOrdersTitle,
        line: pvProfileOrdersLine(PvOrderStore.instance.orders),
        onTap: () => _push(const PvOrdersScreen(), 'store/orders'),
      ),
      PvProfileTile(
        key: const ValueKey('pv_profile_bookings'),
        // The calendar page with one day ringed: the Appointments tool's
        // own drawing, so one object is one drawing wherever it appears.
        mark: TtcToolArt(mark: TtcToolMark.appointments, tint: tint),
        title: kPvProfileBookingsTitle,
        line: pvProfileBookingsLine(
          next: BookingStore.instance.nextUp?.startsUtc.toLocal(),
          total: BookingStore.instance.bookings().length,
        ),
        // Consults, masterclasses, courses and cohorts, in one list: the
        // same screen and route More's former Bookings row opened.
        onTap: () => _push(const PvMyLearningScreen(), 'bookings'),
      ),
    ],
  );

  /// A content row on the profile: its drawn mark in the page's tint, its
  /// words, its count or dot, and its own destination.
  Widget _profileThingRow(V2Palette p, PvYouThing t, {String? subtitle}) {
    final tint = _profileTint(p);
    Widget row() => PvProfileRow(
      mark:
          t.art?.call(tint) ??
          PvProfileArt(mark: PvProfileMark.info, tint: tint),
      title: t.title,
      subtitle: subtitle ?? t.subtitleNow?.call() ?? t.subtitle,
      badge: t.count?.call(),
      trailing: t.dot?.call() == true
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
      onTap: () => t.open(context),
    );
    final l = t.listen;
    if (l == null) return row();
    return ListenableBuilder(listenable: l, builder: (_, _) => row());
  }

  /// The TTC profile, V3, top to bottom:
  ///
  ///   hero        her monogram, name, one status line, partner status, Edit
  ///   tiles       Your orders and Your bookings (2026-09-29; his too)
  ///   glance      her usual cycle and periods logged (hers only)
  ///   YOUR ANSWERS          the facts she gave, read-only, and one way to
  ///                         change them (hers only)
  ///   FOR YOUR DOCTOR       notes laid out for the appointment (hers only)
  ///   YOUR JOURNEY          "I got a positive test" (his: how his side moves)
  ///   FAMILY AND PARTNER    the partner row, the care partner's card
  ///   YOUR THINGS           Saved
  ///   one Settings row
  ///
  /// Every destination is the one V2's row had.
  List<Widget> _ttcProfileV3(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content,
  ) {
    final tint = _profileTint(p);
    final him = widget.father;
    final a = content.action;
    // ⚠️ THE PARTNER LINE ONLY ONCE THEY ARE PAIRED (2026-09-30, the user:
    // "Not paired with your partner yet" under her name). Unpaired, the
    // Family and partner row below says it with its Invite, the one place to
    // act. Kept for revert:
    //   final partnerLine = _partnerLinked ? 'Paired with $_partnerName'
    //       : 'Not paired with ${him ? _partnerName : 'your partner'} yet';
    final String? partnerLine =
        _partnerLinked ? 'Paired with $_partnerName' : null;
    return [
      PvProfileHero(
        key: const ValueKey('pv_profile_hero'),
        name: _name,
        hasName: _hasName,
        status: _ttcStatus(),
        partnerLine: partnerLine,
        partnerMark: TtcTabArt(mark: TtcTabMark.twoFigures, tint: tint),
        bandTint: tint,
        // White from the top, no tinted band (2026-09-30, "cleaner").
        showBand: false,
        verified: _phoneVerified,
        showBack: widget.bottomNav == null,
        onEdit: him ? null : _editName,
        editLabel: _hasName ? 'Edit name' : 'Add your name',
        // Her photo, on her side (2026-09-30).
        photoPath: him ? null : ProfilePhotoStore.instance.path,
        onPhoto: him ? null : _photoSheet,
      ),
      // ⚠️ WHAT SHE BOUGHT AND BOOKED, FIRST UNDER THE HERO (2026-09-29, the
      // lead with the user: things she HAS bought or booked live on the
      // profile, things she COULD buy or book live on More and the store).
      // His side too: the orders and bookings on this phone are his as much
      // as hers. Mobbin evidence in pv_you_chrome.dart, PvProfileTile.
      _ttcOrdersAndBookings(tint),
      // Kept for revert (2026-09-29): if (!him) _ttcGlance(),
      if (!him) _ttcGlance(top: 12),
      if (!him)
        PvProfileGroup(
          key: const ValueKey('pv_profile_answers'),
          title: 'Your answers',
          // Apple Health's Health Details: the facts as values, read-only,
          // and one way to change them. Five taps to one page read as
          // repetition (test/ttc_no_repetition_test.dart).
          // ⚠️ EACH ANSWER IS ITS OWN EDIT (2026-09-30, the user: we collect
          // data at onboarding, so let her know she can change it; Paired's
          // "About you": every answer a row with its value and an arrow).
          // Each row opens its own question, so no two rows share a
          // destination. An empty answer says "Not answered", never "--".
          // Kept for revert: read-only rows and one "Change your answers" row
          // opening PvDetailsScreen(stageId: 'trying').
          //
          // ⚠️ AND ONE WAY IN, THE SAME NIGHT (test/ttc_no_repetition_test):
          // every answer's editor is the one Your details page, scrolled to
          // its question, so three tappable rows were three doors to one
          // room. The rows show the values; one row changes them, and the
          // line above says she can. Kept for revert: onTap: () =>
          // d.edit(context) on each row, and no Change your answers row.
          lead: 'What you told us when you joined. You can change any answer.',
          children: [
            for (final d in content.details)
              if (!d.hideWhenEmpty || d.value() != '--')
                PvProfileRow(
                  key: ValueKey('pv_profile_answer_${d.label}'),
                  mark:
                      d.art?.call(tint) ??
                      PvProfileArt(mark: PvProfileMark.info, tint: tint),
                  title: d.label,
                  subtitle: d.note,
                  value: d.value() == '--' ? 'Not answered' : d.value(),
                ),
            PvProfileRow(
              key: const ValueKey('pv_profile_change_answers'),
              mark: TtcTabArt(mark: TtcTabMark.checklist, tint: tint),
              title: 'Change your answers',
              subtitle: 'They decide what leads on your home',
              onTap: () => _push(
                const PvDetailsScreen(stageId: 'trying'),
                'you/details',
              ),
            ),
          ],
        ),
      if (!him && content.profileThings.isNotEmpty)
        PvProfileGroup(
          key: const ValueKey('pv_profile_doctor'),
          title: 'For your doctor',
          children: [
            for (final t in content.profileThings) _profileThingRow(p, t),
          ],
        ),
      // ⚠️ THE STEPPER IS GONE (2026-09-29, the user: the top "which
      // displays where are you right now ... does not make any sense"). The
      // four chapters as a track told her nothing she could act on. What she
      // can act on is one thing: recording a positive test. Kept for revert:
      //   PvYouSection(title: 'Your stage',
      //       children: _journeyRows(p, stage, content, stepper: true)),
      PvProfileGroup(
        key: const ValueKey('pv_profile_journey'),
        title: 'Your journey',
        children: [
          if (!him && a != null)
            PvProfileRow(
              key: const ValueKey('pv_profile_positive_test'),
              mark: TtcTabArt(mark: TtcTabMark.testStrip, tint: tint),
              title: a.label,
              subtitle:
                  'Dates your pregnancy and carries over everything you have logged',
              onTap: () => a.run(context),
            )
          else
            // His side moves with hers; there is nothing for him to press.
            PvProfileRow(
              key: const ValueKey('pv_profile_journey_his'),
              mark: TtcTabArt(mark: TtcTabMark.testStrip, tint: tint),
              // "your partner" stays lower case mid-sentence.
              title: 'Moves when $_partnerName says so',
              subtitle:
                  'When she records a positive test, your side moves into pregnancy with hers',
            ),
        ],
      ),
      PvProfileGroup(
        key: const ValueKey('pv_profile_family'),
        title: 'Family and partner',
        // Care circle: renders nothing unless a doctor or hospital actually
        // introduced her. Under the group, not inside it, so an empty slot
        // leaves no stray hairline.
        footer: CarePartnerSlot(
          surface: CareSurface.profile,
          stage: _stageId(stage),
          shape: CarePartnerCardShape.full,
          padding: const EdgeInsets.only(top: 10),
        ),
        children: [
          PvProfileRow(
            key: const ValueKey('pv_profile_partner_row'),
            mark: TtcTabArt(mark: TtcTabMark.twoFigures, tint: tint),
            title: _partnerLinked
                ? _partnerName
                : (him ? _cap(_partnerName) : 'Your partner'),
            subtitle: _partnerLinked
                ? 'Their own side, in step with yours'
                : (him
                      ? 'Pair with her phone, so your side follows hers'
                      : 'Invite your partner to a side of their own, in step with yours'),
            // The row is the tap; the pill says what it does.
            trailing: _partnerLinked
                ? null
                : const PvProfilePill(label: 'Invite'),
            onTap: () => _push(
              PvPartnerScreen(
                stage: stage,
                partnerName: _partnerLinked ? _partnerName : null,
              ),
              'you/partner',
            ),
          ),
        ],
      ),
      PvProfileGroup(
        key: const ValueKey('pv_profile_things'),
        title: 'Your things',
        children: [
          for (final t in content.tiles)
            _profileThingRow(
              p,
              t,
              // Saved names what is in it (content.tilesCaption).
              subtitle: t.title == 'Saved' ? content.tilesCaption : null,
            ),
        ],
      ),
      // ONE Settings row, apart from the groups (Airbnb's "Account settings"
      // under the profile's rows), with no heading of its own.
      PvProfileGroup(
        children: [
          PvProfileRow(
            key: kPvProfileSettingsRowKey,
            mark: TtcMoreArt(mark: TtcMoreMark.gear, tint: tint),
            title: 'Settings',
            subtitle: 'Account, language, notifications, privacy and help',
            onTap: () => _openSettings(p, stage, content),
          ),
        ],
      ),
    ];
  }

  /// A Settings row's drawn mark, by the row's own title (the rows come from
  /// the shared builders, which draw line icons on every other stage).
  /// Null for a row this page does not draw.
  PvProfileMark? _settingsMarkFor(String title) => switch (title) {
    'Signed in' || 'Not signed in' => PvProfileMark.person,
    'Sign out' => PvProfileMark.door,
    'Delete account' => PvProfileMark.bin,
    'Data and privacy' => PvProfileMark.shield,
    'Language' => PvProfileMark.globe,
    'Reminders' => PvProfileMark.bell,
    'WhatsApp updates' => PvProfileMark.bubble,
    'Messages' => PvProfileMark.envelope,
    kTtcWhatYouSee => PvProfileMark.eye,
    'Help' => PvProfileMark.lifebuoy,
    'Contact us' => PvProfileMark.plane,
    kTtcGetHelpTitle => PvProfileMark.phone,
    'About ParentVeda' => PvProfileMark.info,
    _ => null,
  };

  /// [row] with its drawn mark, in the page's one tint (the one icon rule,
  /// 2026-09-29). A row with no mark is returned as it was.
  Widget _marked(V2Palette p, Widget row) {
    final tint = _profileTint(p);
    Widget art(PvProfileMark m) => PvProfileArt(mark: m, tint: tint);
    if (row is PvYouRow) {
      final m = _settingsMarkFor(row.title);
      return m == null ? row : row.withLeading(art(m));
    }
    if (row is PvYouSwitchRow) {
      final m = _settingsMarkFor(row.title);
      return m == null ? row : row.withLeading(art(m));
    }
    return row;
  }

  /// A content row in Settings with its mark.
  Widget _markedThing(V2Palette p, PvYouThing t) {
    final m = _settingsMarkFor(t.title);
    return _thingRow(
      p,
      t,
      leading: m == null
          ? null
          : PvProfileArt(mark: m, tint: _profileTint(p)),
    );
  }

  void _openSettings(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content,
  ) => _push(
    PvSettingsScreen(
      sections: () => _ttcSettingsSections(p, stage, content),
      // Gated exactly as the profile's Developer section always was.
      developer: kPvShowDeveloper ? () => _developer(p) : null,
      listen: Listenable.merge([..._listenables, _tick]),
    ),
    kPvSettingsRoute,
  );

  /// Settings, in order: Account, Preferences, Notifications, Privacy and
  /// data, Support, About. The rows are this state's own builders.
  List<PvSettingsSection> _ttcSettingsSections(
    V2Palette p,
    LifeStage stage,
    PvYouStageContent content,
  ) {
    final prefs = _preferencesRows(p, stage);
    final support = _supportRows(p, stage);
    // ⚠️ EVERY ROW LEADS WITH A DRAWN MARK (2026-09-29, the one icon rule:
    // marks for rows that go somewhere, line icons only for controls), all
    // in the profile's one tint. Only with V3; kPvTtcProfileV3 false draws
    // the line icons as before.
    Widget m(Widget row) => kPvTtcProfileV3 ? _marked(p, row) : row;
    Widget thing(PvYouThing t) =>
        kPvTtcProfileV3 ? _markedThing(p, t) : _thingRow(p, t);
    return [
      // Kept for revert (2026-09-29), before Delivery addresses moved here:
      //   rows: [for (final r in _accountRows(p, stage, privacy: false)) m(r)],
      PvSettingsSection(
        title: 'Account',
        rows: [
          for (final (i, r) in _accountRows(
            p,
            stage,
            privacy: false,
          ).indexed) ...[
            m(r),
            // After how she is signed in, before Sign out and Delete.
            if (i == 0) _deliveryAddressesRow(p),
            // ⚠️ WHAT SHE TOLD US, CHANGEABLE HERE TOO (2026-09-30, the user:
            // the onboarding answers should be visible in Settings, or let
            // her know she can change them). The same page every answer row
            // on the profile leads to; hers only.
            // ⚠️ OFF THE SAME NIGHT: Reminders already opens Your details, so
            // this was a second door to it (test/ttc_no_repetition_test). The
            // profile's "Change your answers" is the one way in. Kept for
            // revert: the condition was `i == 0 && !widget.father`.
            if (false)
              m(
                PvYouRow(
                  key: const ValueKey('pv_settings_your_details'),
                  icon: Icons.fact_check_outlined,
                  leading: PvProfileArt(
                    mark: PvProfileMark.person,
                    tint: _profileTint(p),
                  ),
                  title: 'Your details',
                  subtitle: 'What you told us when you joined. Change any of it.',
                  onTap: () => _push(
                    const PvDetailsScreen(stageId: 'trying'),
                    'you/details',
                  ),
                ),
              ),
          ],
        ],
      ),
      PvSettingsSection(
        title: 'Preferences',
        rows: [
          m(_languageRow(stage)),
          for (final t in content.preferenceThings) thing(t),
        ],
      ),
      PvSettingsSection(
        title: 'Notifications',
        rows: [
          for (final t in content.notificationThings) thing(t),
          m(prefs[1]), // Reminders
          m(prefs[2]), // WhatsApp updates
        ],
      ),
      PvSettingsSection(
        title: 'Privacy and data',
        rows: [m(_privacyRow(stage))],
      ),
      PvSettingsSection(
        title: 'Support',
        rows: [
          m(support[0]), // Help
          m(
            PvYouRow(
              icon: Icons.alternate_email_rounded,
              title: 'Contact us',
              subtitle: kPvContactEmail,
              onTap: _contactUs,
            ),
          ),
          for (final t in content.supportThings) thing(t),
        ],
      ),
      PvSettingsSection(
        title: 'About',
        rows: [m(support[3])], // About ParentVeda
      ),
    ];
  }

  /// ⚠️ DELIVERY ADDRESSES LIVE IN SETTINGS, ACCOUNT (2026-09-29). They left
  /// More with the orders; they did not go to the profile with them,
  /// because an address is account detail rather than something she bought
  /// (Deliveroo keeps addresses in its account settings; Ro lists Shipping
  /// Address under Personal information, apart from its Orders tile:
  /// https://mobbin.com/screens/2f69a9eb-9760-4183-abe2-4da5660c87e9). One
  /// home: `kTtcFormerYouRows['Addresses']`.
  Widget _deliveryAddressesRow(V2Palette p) {
    final n = PvOrderStore.instance.addresses.length;
    return _thingRow(
      p,
      PvYouThing(
        icon: Icons.home_outlined,
        title: kPvDeliveryAddressesTitle,
        subtitle: n == 0
            ? 'Where your orders are delivered'
            : (n == 1
                  ? '1 address saved for delivery'
                  : '$n addresses saved for delivery'),
        open: (c) => showPvAddressesSheet(c),
      ),
      leading: TtcMoreArt(mark: TtcMoreMark.house, tint: _profileTint(p)),
    );
  }

  /// Opens her mail app to us; when none opens, copies the address so it is
  /// never a dead tap.
  Future<void> _contactUs() async {
    var opened = false;
    try {
      opened = await launchUrl(Uri(scheme: 'mailto', path: kPvContactEmail));
    } catch (_) {
      opened = false;
    }
    if (opened || !mounted) return;
    await Clipboard.setData(const ClipboardData(text: kPvContactEmail));
    if (mounted) pvSnack(context, 'Email address copied: $kPvContactEmail');
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
            // A tab of a host swaps in place (the host flips the preview).
            if (widget.onSwitchViewer != null) {
              widget.onSwitchViewer!();
              return;
            }
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

/// "2 saved", "1 order", "3 orders": a count and the row's name, singular for
/// one. Names that are not plural nouns ("Saved") stay as they are.
String _countLine(int n, String title) {
  var w = title.toLowerCase();
  if (n == 1 && w.endsWith('s') && !w.endsWith('ss')) {
    w = w.substring(0, w.length - 1);
  }
  return '$n $w';
}

// ---- the orders and bookings tiles (2026-09-29) ---------------------------------------

/// The tiles' titles. The ledger (`kTtcFormerYouRows`) and the tests read them.
const String kPvProfileOrdersTitle = 'Your orders';
const String kPvProfileBookingsTitle = 'Your bookings';

/// The Your orders tile's one line, from the orders on this phone.
///
/// A paid order within a week is "on the way": the orders screen itself
/// says a confirmed order is packing with delivery in 3 to 6 days, and this
/// line says no more than that. An order still waiting for its payment says
/// so first, because it is the one she may need to act on.
String pvProfileOrdersLine(List<PvOrder> orders, {DateTime? now}) {
  if (orders.isEmpty) return 'None yet';
  final at = now ?? DateTime.now();
  final waiting = orders.where((o) => o.status == PvOrderStatus.placed).length;
  if (waiting > 0) return '$waiting waiting for payment';
  final onTheWay = orders
      .where(
        (o) =>
            o.status == PvOrderStatus.paid &&
            at.difference(o.createdAt).inDays < 7,
      )
      .length;
  // "Confirmed", not "on the way" (the lead, 2026-09-29): nothing here tracks
  // a parcel, so a shipping word would claim what the app does not know.
  // Kept for revert: '$onTheWay on the way'.
  if (onTheWay > 0) return '$onTheWay confirmed';
  return orders.length == 1 ? '1 order' : '${orders.length} orders';
}

/// The Your bookings tile's one line: the next session's day when one is
/// coming ("Next: Thu 2 Oct", "Next: today"), else how many she has booked.
String pvProfileBookingsLine({
  required DateTime? next,
  required int total,
  DateTime? now,
}) {
  if (next != null) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final day = DateTime(next.year, next.month, next.day);
    final gap = day.difference(today).inDays;
    if (gap <= 0) return 'Next: today';
    if (gap == 1) return 'Next: tomorrow';
    const wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
    return 'Next: ${wd[next.weekday - 1]} ${next.day} ${m[next.month - 1]}';
  }
  if (total == 0) return 'None yet';
  return total == 1 ? '1 booking' : '$total bookings';
}

/// The Settings row's title for delivery addresses (Account section, TTC).
const String kPvDeliveryAddressesTitle = 'Delivery addresses';
