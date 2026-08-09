// =============================================================================
//  ProfileScreen  -  the "Profile" tab
// -----------------------------------------------------------------------------
//  A light profile header, the Dear Baby memory-vault entry point, and a
//  language toggle. Dear Baby lives here (rather than its own tab) so the Tools
//  tab can be a permanent destination.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../doctor/doctor_directory.dart';
import '../doctor/doctor_session.dart';
import 'memories/memories_home_screen.dart';
import 'referral/invite_friends_screen.dart';
import '../care_partner/care_partner_models.dart';
import '../care_partner/care_visibility.dart';
import 'care_partner/care_partner_card.dart';
import 'care_partner/care_partner_slot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../localization/app_language.dart';
import '../services/app_nav.dart';
import '../services/bump_store.dart';
import '../services/daily_store.dart';
import '../services/journal_store.dart';
import '../services/journey_dates_store.dart';
import '../services/pregnancy_controller.dart';
import '../services/remote/supabase_repo.dart';
import '../services/remote/sync_registry.dart';
import '../services/read_next_store.dart';
import '../services/read_to_baby_saved_store.dart';
import '../services/scans_store.dart';
import '../services/video_store.dart';
import '../services/whatsapp_prefs.dart';
import '../theme/app_theme.dart';
import '../services/family_profile.dart';
import 'pregnancy_profile_screen.dart';
import 'profile_analytics_screen.dart';
import '../services/profile_analytics.dart';
import 'auth/auth_flow_screen.dart';
import 'enterprise/activation_flow_screen.dart';
import 'enterprise/employer_benefits_screen.dart';
import '../services/entitlement_store.dart';
import 'bump_journey_screen.dart';
import '../services/father_preview.dart';
import 'dear_baby_vault_screen.dart';
import 'journal_screen.dart';
import 'saved_hub_screen.dart';
import '../theme/pv_fonts.dart';
import '../services/auth/social_auth.dart';
import '../services/auth/delete_account.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen(
      {super.key, required this.controller, this.father = false});

  final PregnancyController controller;

  /// When true, this is the PARTNER (father) account: the mother-only memory
  /// vaults are hidden and a partner-account note is shown instead.
  final bool father;

  @override
  Widget build(BuildContext context) {
    // Listen to the controller so a language toggle (or any profile edit)
    // rebuilds THIS screen live. Without it the segmented toggle only flips
    // after leaving and re-entering the screen — the tap looked like a no-op.
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final name = father ? controller.fatherName : controller.motherName;
    final initial = name.isNotEmpty ? name.characters.first : '🌸';

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        elevation: 0,
        title: Text(s.profileTitle, style: text.titleLarge),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          // --- Profile header ---------------------------------------------
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppTheme.primary100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  initial,
                  style: text.headlineSmall?.copyWith(
                    color: AppTheme.primary600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: text.titleLarge),
                  const SizedBox(height: 2),
                  Text(
                    father
                        ? 'Partner account'
                        : '${s.weekOf(controller.currentWeek, PregnancyController.lastContentWeek)} · ${s.trimesterName(controller.currentWeek)}',
                    style: text.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Mother-only memory vaults (Journal / Bump / Dear Baby / Saved) are
          // hidden for the father - they belong to her account; he sees a
          // partner-account note instead.
          if (father) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.outlineVariant),
              ),
              child: Row(children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: const Color(0xFF2E5266).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.favorite_rounded,
                      color: Color(0xFF2E5266)),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.now.uiPartnerAccount,
                            style: text.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 3),
                        Text(
                            controller.motherName.isNotEmpty
                                ? "You're paired with ${controller.motherName}. Her journal, bump journey and memories live in her account."
                                : "You're paired as a partner. The journal, bump journey and memories live in the mother's account.",
                            style: text.bodySmall?.copyWith(
                                color: AppTheme.neutral600, height: 1.45)),
                      ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
          ] else ...[
          // --- Invite your partner (pairing code) -------------------------
          const _InvitePartnerCard(),
          const SizedBox(height: 14),
          // --- My Journal -------------------------------------------------
          AnimatedBuilder(
            animation: JournalStore.instance,
            builder: (context, _) {
              final count = JournalStore.instance.manualEntries.length;
              return _VaultCard(
                title: s.jrTitle,
                subtitle: s.jrSubtitle,
                trailing: count > 0 ? '$count' : '',
                icon: Icons.auto_stories_rounded,
                accent: AppTheme.primary500,
                accentBg: AppTheme.primary50,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => JournalScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- My Bump Journey --------------------------------------------
          AnimatedBuilder(
            animation: BumpStore.instance,
            builder: (context, _) {
              final count = BumpStore.instance.count;
              return _VaultCard(
                title: s.bumpTitle,
                subtitle: s.bumpSubtitle,
                trailing: count > 0 ? '$count' : '',
                icon: Icons.pregnant_woman_rounded,
                accent: AppTheme.secondary500,
                accentBg: AppTheme.secondary50,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BumpJourneyScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- Dear Baby memory vault -------------------------------------
          AnimatedBuilder(
            animation: DailyStore.instance,
            builder: (context, _) {
              final count = DailyStore.instance.talkEntries.length;
              return _VaultCard(
                title: s.dearBabyVaultTitle,
                subtitle: s.dearBabyVaultSubtitle,
                trailing: s.dearBabyEntries(count),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        DearBabyVaultScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- Saved (bookmarked videos) ----------------------------------
          AnimatedBuilder(
            animation: Listenable.merge([
              VideoStore.instance,
              ReadNextStore.instance,
              ReadToBabySavedStore.instance,
            ]),
            builder: (context, _) {
              final count = VideoStore.instance.savedIds.length +
                  ReadNextStore.instance.savedIds.length +
                  ReadToBabySavedStore.instance.recent().length;
              return _VaultCard(
                title: s.savedVaultTitle,
                subtitle: s.savedHubSubtitle,
                trailing: count > 0 ? '$count' : '',
                icon: Icons.bookmark_rounded,
                accent: const Color(0xFF3FA56A),
                accentBg: const Color(0xFFEAF3EF),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => SavedHubScreen(controller: controller),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          ],
          // --- Personalization: the Living Family Profile ------------------
          // The engine has always existed but was only reachable from the
          // parenting Explore drawer, so a pregnant mother could never tell it
          // anything about herself. This is that door. It changes nothing about
          // the app's structure - only what gets surfaced first inside it.
          AnimatedBuilder(
            animation: FamilyProfileStore.instance,
            builder: (context, _) {
              final p = FamilyProfileStore.instance;
              final pct = p.completenessPercent;
              return _VaultCard(
                title: S.now.uiPersonaliseParentveda,
                subtitle: pct == 0
                    ? 'Tell us a little about your pregnancy and we will surface what matters to you first.'
                    : 'Your profile is $pct% complete - the more we know, the more useful ParentVeda gets.',
                trailing: pct > 0 ? '$pct%' : '',
                icon: Icons.auto_awesome_rounded,
                accent: AppTheme.primary600,
                accentBg: AppTheme.surfaceContainer,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PregnancyProfileScreen(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // --- Personalization analytics (development toggle) --------------
          // Built now and shipped OFF, so reaching testers is a switch flip
          // rather than a build under time pressure. Remove this row and the
          // screen when it goes live for real testers.
          AnimatedBuilder(
            animation: ProfileAnalytics.instance,
            builder: (context, _) => _VaultCard(
              title: S.now.uiPersonalizationAnalytics,
              subtitle:
                  'How the ask strips are doing - which questions land, and where.',
              trailing: '${ProfileAnalytics.instance.recent.length}',
              icon: Icons.insights_rounded,
              accent: AppTheme.tertiary500,
              accentBg: AppTheme.surfaceContainer,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const ProfileAnalyticsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 14),
          // --- Employer benefits ------------------------------------------
          // ALWAYS VISIBLE, activated or not, and that is the deliberate part.
          // The spec asks for this to be hidden from consumer users; CLAUDE.md
          // says a feature is never hidden. Both are right about different
          // halves: a parent whose company already pays for ParentVeda would
          // never discover it if the door only appeared once she was through
          // it, so the ROW is always here and the BENEFITS are only real once
          // she has them. Shown to the father too — his employer may be the
          // one sponsoring.
          _EmployerBenefitsCard(controller: controller),
          const SizedBox(height: 14),
          // --- Language toggle --------------------------------------------
          _LanguageCard(controller: controller),
          const SizedBox(height: 14),
          // REFERRAL. A mother who finds ParentVeda useful is the cheapest and
          // most credible way another mother hears about it.
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => InviteFriendsScreen(controller: controller))),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 15, 14, 15),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFF6A30B6), Color(0xFF8B5CD6)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                const Icon(Icons.card_giftcard_rounded,
                    size: 22, color: Colors.white),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.now.uiInviteFriend,
                            style: pvManrope(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text(S.now.uiBothGetFreeConsultation,
                            style: pvManrope(
                                fontSize: 12,
                                height: 1.4,
                                color: Colors.white70)),
                      ]),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: Colors.white),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          // CARE CIRCLE. Renders nothing at all unless a doctor or hospital
          // actually introduced her to ParentVeda — see CarePartnerSlot.
          const CarePartnerSlot(
            surface: CareSurface.profile,
            stage: 'pregnancy',
            shape: CarePartnerCardShape.full,
            padding: EdgeInsets.only(bottom: 14),
          ),
          // --- WhatsApp updates (B2 opt-in) -------------------------------
          // Memories — make a keepsake card for the big milestones.
          GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const MemoriesHomeScreen())),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFF7E2E8), Color(0xFFDCEAF4)]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                const Icon(Icons.auto_awesome_outlined,
                    size: 22, color: Color(0xFF5A4A6B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(S.now.uiMemories3,
                            style: pvFraunces(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF3A352E))),
                        Text(S.now.uiAnnouncePregnancyBabyBeautifully,
                            style: pvManrope(
                                fontSize: 12, color: const Color(0xFF6B6154))),
                      ]),
                ),
                const Icon(Icons.arrow_forward_rounded,
                    size: 20, color: Color(0xFF5A4A6B)),
              ]),
            ),
          ),
          _WhatsAppCard(controller: controller),
          const SizedBox(height: 16),
          // --- Reset to Week 20 (testing) ---------------------------------
          // Clears any saved due date + the pregnancy-map data and snaps the app
          // back to the week-20 placeholder, so features can be re-tested from a
          // clean "halfway" state. (Testing aid - remove/gate before release.)
          OutlinedButton.icon(
            onPressed: () => _resetForTesting(context),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(S.now.uiResetWeekTesting),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.neutral700,
              side: const BorderSide(color: AppTheme.outlineVariant),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          // --- Enter doctor mode (testing) --------------------------------
          // Swaps the whole app to the expert dashboard. For now it enters as
          // Dr. Neha Sharma (a bookable consult doctor); later this becomes a
          // real doctor sign-in from the login screen. Remove/gate before launch.
          OutlinedButton.icon(
            onPressed: () => _pickDoctor(context),
            icon: const Icon(Icons.medical_services_outlined, size: 18),
            label: Text(S.now.uiEnterDoctorModeTesting),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary600,
              side: BorderSide(color: AppTheme.primary500.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 10),
          // --- Sign out (replays the auth flow) ---------------------------
          OutlinedButton.icon(
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: Text(s.profileSignOut),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.secondary600,
              side: BorderSide(
                  color: AppTheme.secondary500.withValues(alpha: 0.35)),
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 18),
          // --- Delete account (permanent) ---------------------------------
          // Play requires this to exist in-app. Placed BELOW sign out, quieter
          // than it, and as a plain text button rather than a filled one — it
          // must be findable without ever being the obvious thing to tap. The
          // confirmation, not the styling, is what actually protects her.
          Center(
            child: TextButton(
              onPressed: () => _deleteAccount(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFB3261E),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              child: Text(s.deleteAccount,
                  style: text.labelLarge?.copyWith(
                      color: const Color(0xFFB3261E),
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(s.moreComingSoon, style: text.labelMedium),
          ),
        ],
      ),
      ),
    );
  }

  /// Permanently delete the account, after a confirmation she has to mean.
  ///
  /// TYPE-TO-CONFIRM, not a yes/no dialog. Everything else in this app is
  /// recoverable — this is the only action that destroys a pregnancy record
  /// with no undo, and a two-tap confirm is muscle memory. Typing the word is a
  /// deliberate speed bump, and it is the standard people already recognise
  /// from GitHub and Stripe for exactly this class of action.
  Future<void> _deleteAccount(BuildContext context) async {
    final s = S.now;
    final controller = TextEditingController();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteAccount),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.deleteAccountBody),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: kDeleteAccountKeyword,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(s.cancelLabel),
          ),
          // Listens so the destructive button stays disabled until the word is
          // typed — an enabled button you must not press is a trap.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => TextButton(
              onPressed: value.text.trim().toUpperCase() ==
                      kDeleteAccountKeyword.toUpperCase()
                  ? () => Navigator.of(ctx).pop(true)
                  : null,
              child: Text(s.deleteAccountConfirm,
                  style: const TextStyle(color: Color(0xFFB3261E))),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(s.deleteAccountWorking)));

    final ok = await DeleteAccount.run();

    messenger.clearSnackBars();
    if (!ok) {
      // Still signed in, nothing lost, free to try again.
      messenger.showSnackBar(SnackBar(content: Text(s.deleteAccountFailed)));
      return;
    }
    if (!context.mounted) return;

    // THE APP CLOSES, and that is the point rather than a shortcut.
    //
    // LocalWipe has emptied storage, but the ~25 singleton stores loaded in
    // this process still hold her data in memory. They would re-persist it on
    // the next write, and a new account created without restarting would be
    // seeded from it — the exact bug LocalWipe exists to prevent, one layer up.
    // Giving every store a reset hook is a lot of surface to keep correct for
    // one rare path; ending the process is the version that cannot be got
    // wrong. Next launch: empty storage, fresh singletons, nothing remembered.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(s.deleteAccountDoneTitle),
        content: Text(s.deleteAccountDoneBody),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              SystemNavigator.pop(); // close the app
            },
            child: Text(s.closeLabel),
          ),
        ],
      ),
    );
    // If the dialog is somehow dismissed without closing, fall back to the
    // first route so she is at least not left inside a deleted account.
    nav.popUntil((r) => r.isFirst);
  }

  /// Testing: pick WHICH doctor to log in as, then enter doctor mode. A live
  /// build would not ask a parent to choose a doctor — this is only so the
  /// doctor experience can be seen. Lists the experts who take consults.
  void _pickDoctor(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            shrinkWrap: true,
            children: [
              Center(
                child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Text(S.now.uiLogAsWhichDoctor,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              _docGroup(ctx, 'Pregnancy side', DoctorStage.pregnancy),
              _docGroup(ctx, 'Parenting side', DoctorStage.parenting),
              // Organisations — hospitals, IVF centres, labs, corporates. They
              // are partners in exactly the same sense a solo doctor is, and
              // they get the same view; what differs is only that they have no
              // consulting record, so slots and availability stay empty.
              //
              // Which partner an account actually IS remains the server's
              // answer (my_care_partner, 0068). Entering here without a
              // link_partner_account row gives a view that correctly finds
              // nothing rather than one that invents an identity.
              const _OrgSignInGroup(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _docGroup(BuildContext ctx, String label, DoctorStage stage) {
    final docs = doctorsForStage(stage);
    if (docs.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 14),
      Text(label.toUpperCase(),
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppTheme.neutral500)),
      const SizedBox(height: 4),
      for (final d in docs)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary500,
            child: Text(
                d.name.replaceAll(RegExp(r'^Dr\.?\s*'), '').characters.first
                    .toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          title:
              Text(d.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(d.credential,
              maxLines: 1, overflow: TextOverflow.ellipsis),
          onTap: () {
            Navigator.of(ctx).pop();
            DoctorSession.instance.enter(d.id);
          },
        ),
    ]);
  }

  /// Testing reset - clear the due date + pregnancy-map data, snap back to the
  /// week-20 placeholder, and drop the user on a fresh Today screen.
  Future<void> _resetForTesting(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    await controller.resetForTesting();
    JourneyDatesStore.instance.clearAll();
    await ScansStore.instance.clearAllForTesting();
    AppNav.instance.goToday();
    nav.popUntil((r) => r.isFirst); // back to the main scaffold (Today)
    messenger.showSnackBar(SnackBar(
        content: Text(S.now.uiResetWeekDueDate)));
  }

  /// "Sign out" - clears the local auth flag and replays the auth flow over the
  /// app; completing it re-sets the flag (and feeds any picked due date in).
  Future<void> _signOut(BuildContext context) async {
    final nav = Navigator.of(context);
    try {
      // Google caches "this app uses this account" inside Play Services, quite
      // separately from our session. Without this, the next Google tap silently
      // re-signs-in the same person with no picker — so on a shared phone,
      // signing out and handing it over would land the next person straight
      // back in the first person's account.
      await SocialAuth.signOutGoogle();
      await Supabase.instance.client.auth.signOut(); // clear the real session
      await (await SharedPreferences.getInstance())
          .setBool(kAuthCompletedKey, false);
    } catch (_) {/* best-effort */}
    nav.push(MaterialPageRoute(
      builder: (_) => AuthFlowScreen(onDone: (due, isFather) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(kAuthCompletedKey, true);
          await prefs.setString(kUserRoleKey, isFather ? 'father' : 'mother');
        } catch (_) {/* best-effort */}
        // PINNED TO WEEK 20 (testing): disabled so re-login can't move the week.
        // Re-enable with the load() restore block in pregnancy_controller.dart.
        // if (!isFather && due != null) await controller.setDueDate(due);
        // Load the real profile name(s) so the app shows them (not placeholders).
        await controller.loadProfileFromCloud();
        // Re-pull every store's cloud data now that we're logged in.
        SyncRegistry.resyncAll();
        if (isFather) {
          // Paired as the father → switch the app into the unified father shell
          // (the same MainScaffold, Slate structure) via the preview flag, then
          // drop back to the root so it re-renders in father mode.
          FatherPreview.instance.on = true;
          nav.popUntil((r) => r.isFirst);
        } else {
          FatherPreview.instance.on = false;
          nav.pop(); // back to the mother app
        }
      }),
    ));
  }
}

/// The mother's "Invite your partner" card - shows her persistent pairing code
/// with Share + Copy. The father enters this code to link the two accounts.
class _InvitePartnerCard extends StatefulWidget {
  const _InvitePartnerCard();

  @override
  State<_InvitePartnerCard> createState() => _InvitePartnerCardState();
}

class _InvitePartnerCardState extends State<_InvitePartnerCard> {
  String? _code;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid != null) {
        final row = await Supabase.instance.client
            .from('profiles')
            .select('pairing_code')
            .eq('id', uid)
            .maybeSingle();
        if (mounted) {
          setState(() {
            _code = row?['pairing_code'] as String?;
            _loading = false;
          });
          return;
        }
      }
    } catch (_) {/* leave code null */}
    if (mounted) setState(() => _loading = false);
  }

  void _share() {
    final code = _code;
    if (code == null) return;
    Share.share(
      S.now.pairingShareText(code),
      subject: S.now.pairingShareSubject,
    );
  }

  void _copy() {
    final code = _code;
    if (code == null) return;
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.now.uiPairingCodeCopied)));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _code == null) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.primary100),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.favorite_rounded,
              color: AppTheme.primary500, size: 20),
          const SizedBox(width: 8),
          Text(S.now.uiInvitePartner,
              style: text.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        ]),
        const SizedBox(height: 6),
        Text(S.now.uiShareCodeSoPartner,
            style: text.bodySmall?.copyWith(color: AppTheme.neutral600)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Text(_code!,
              style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                  color: AppTheme.primary600)),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _share,
              icon: const Icon(Icons.share_rounded, size: 18),
              label: Text(S.now.uiShare),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(S.now.uiCopy),
          ),
        ]),
      ]),
    );
  }
}

class _VaultCard extends StatelessWidget {
  const _VaultCard({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
    this.icon = Icons.favorite_rounded,
    this.accent = AppTheme.secondary500,
    this.accentBg = AppTheme.secondary50,
  });

  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  final IconData icon;
  final Color accent;
  final Color accentBg;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accentBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: text.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800)),
                        ),
                        Text(trailing, style: text.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: text.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.neutral400),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Employer Benefits row.
///
/// Two states, one entry point. Not activated: an invitation, worded so that
/// someone whose company does NOT sponsor ParentVeda is not made to feel they
/// are missing out on something — "your employer MAY already provide this".
/// Activated: the benefit and who is paying for it, which is the only branding
/// a sponsor ever gets in this app.
///
/// Reads [EntitlementStore] through an [AnimatedBuilder] so activating in the
/// flow updates this row on the way back without anyone re-navigating.
class _EmployerBenefitsCard extends StatelessWidget {
  const _EmployerBenefitsCard({required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: EntitlementStore.instance,
      builder: (context, _) {
        final sponsor = EntitlementStore.instance.sponsor;
        final hinglish = controller.language.isHinglish;
        final active = sponsor != null;

        return _VaultCard(
          // "Employer benefits" is left in English in both languages on
          // purpose: it is what HR calls it in the email an employee will have
          // already received, and matching that wording is worth more here
          // than translating it.
          title: S.now.uiEmployerBenefits,
          subtitle: active
              ? (hinglish
                  ? 'ParentVeda Premium — ${sponsor.name} ki taraf se.'
                  : 'ParentVeda Premium, provided by ${sponsor.name}.')
              : (hinglish
                  ? 'Ho sakta hai aapki company ParentVeda ka kharcha uthati '
                      'ho. Work email se check kar lijiye.'
                  : 'Your employer may already provide ParentVeda. Check with '
                      'your work email.'),
          trailing: active ? (hinglish ? 'Chalu' : 'Active') : '',
          icon: active
              ? Icons.workspace_premium_outlined
              : Icons.business_outlined,
          accent: AppTheme.primary600,
          accentBg: AppTheme.primary50,
          onTap: () {
            if (active) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  settings: const RouteSettings(name: 'enterprise/benefits'),
                  builder: (_) =>
                      EmployerBenefitsScreen(lang: controller.language),
                ),
              );
            } else {
              openActivationFlow(context, lang: controller.language);
            }
          },
        );
      },
    );
  }
}

/// The WhatsApp opt-in card (B2). Shown to mother AND father (each is their own
/// recipient). Toggling saves immediately; the phone field saves on submit.
/// Writes the same `profiles` columns onboarding does, via [WhatsAppPrefs].
class _WhatsAppCard extends StatefulWidget {
  const _WhatsAppCard({required this.controller});

  final PregnancyController controller;

  @override
  State<_WhatsAppCard> createState() => _WhatsAppCardState();
}

class _WhatsAppCardState extends State<_WhatsAppCard> {
  bool _optIn = false;
  bool _loading = true;
  final _phone = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await WhatsAppPrefs.load();
    if (!mounted) return;
    setState(() {
      _optIn = p.optIn;
      _phone.text = p.phone ?? '';
      _loading = false;
    });
  }

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String get _lang => widget.controller.language.isEnglish ? 'en' : 'hi';

  Future<void> _save({required bool optIn}) async {
    final ok = await WhatsAppPrefs.save(
      optIn: optIn,
      phone: _phone.text,
      language: _lang,
      source: 'profile_screen',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(ok
            ? (optIn ? S.now.whatsappUpdatesOn : S.now.whatsappUpdatesOff)
            : S.now.couldNotSaveRetry),
        duration: const Duration(milliseconds: 1400),
      ));
  }

  Future<void> _toggle(bool v) async {
    setState(() => _optIn = v);
    await _save(optIn: v);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const waGreen = Color(0xFF128C4B);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: waGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.chat_rounded, color: waGreen, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S.now.uiWhatsappUpdates, style: text.titleMedium),
                  const SizedBox(height: 2),
                  Text(S.now.uiWeeklyGuideRemindersTurn,
                      style:
                          text.bodySmall?.copyWith(color: AppTheme.neutral600)),
                ]),
          ),
          if (_loading)
            const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2))
          else
            Switch(
              value: _optIn,
              activeThumbColor: waGreen,
              onChanged: _toggle,
            ),
        ]),
        if (_optIn && !_loading) ...[
          const SizedBox(height: 12),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            onEditingComplete: () => _save(optIn: true),
            onSubmitted: (_) => _save(optIn: true),
            style: text.bodyMedium,
            decoration: InputDecoration(
              isDense: true,
              prefixIcon: const Icon(Icons.phone_rounded, size: 18),
              hintText: '+91 98765 43210',
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: waGreen, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(S.now.uiWeOnlyMessageNumber,
              style: text.labelSmall?.copyWith(color: AppTheme.neutral500)),
        ],
      ]),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.controller});

  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final text = Theme.of(context).textTheme;
    final isEnglish = controller.language.isEnglish;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.translate_rounded,
                color: AppTheme.primary500, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Text(s.languageLabel, style: text.titleMedium)),
          _Segmented(
            leftLabel: s.languageHinglish,
            rightLabel: s.languageEnglish,
            rightSelected: isEnglish,
            onLeft: () => controller.setLanguage(AppLanguage.hinglish),
            onRight: () => controller.setLanguage(AppLanguage.english),
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  const _Segmented({
    required this.leftLabel,
    required this.rightLabel,
    required this.rightSelected,
    required this.onLeft,
    required this.onRight,
  });

  final String leftLabel;
  final String rightLabel;
  final bool rightSelected;
  final VoidCallback onLeft;
  final VoidCallback onRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(context, leftLabel, !rightSelected, onLeft),
          _seg(context, rightLabel, rightSelected, onRight),
        ],
      ),
    );
  }

  Widget _seg(
      BuildContext context, String label, bool selected, VoidCallback onTap) {
    final text = Theme.of(context).textTheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary500 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          label,
          style: text.labelMedium?.copyWith(
            color: selected ? Colors.white : AppTheme.neutral600,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// TESTING: sign in to the partner view as an ORGANISATION.
///
/// Reads the live care_partners table rather than a compiled list, because an
/// organisation is created by ParentVeda in SQL (or later Directus) and never
/// exists in the kExperts catalogue. Shows only partners with no expert record,
/// since the doctor groups above already cover the ones that consult.
class _OrgSignInGroup extends StatefulWidget {
  const _OrgSignInGroup();

  @override
  State<_OrgSignInGroup> createState() => _OrgSignInGroupState();
}

class _OrgSignInGroupState extends State<_OrgSignInGroup> {
  List<Map<String, dynamic>> _orgs = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await SupabaseRepo.selectAll('care_partners');
      final orgs = rows
          .whereType<Map>()
          .where((r) =>
              (r['expert_id'] == null ||
                  '${r['expert_id']}'.trim().isEmpty) &&
              // Only an approved partner can acquire families, so only an
              // approved one is worth signing in as.
              '${r['status']}' == 'active')
          .map((r) => Map<String, dynamic>.from(r))
          .toList();
      if (mounted) setState(() => _orgs = orgs);
    } catch (_) {
      // Signed out or offline: the group simply does not appear. Nothing here
      // is required to reach the doctor view.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orgs.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 14),
      Text(S.now.uiOrganisations,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppTheme.neutral500)),
      const SizedBox(height: 4),
      for (final o in _orgs)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppTheme.primary500,
            child: Text(
                ('${o['name']}'.trim().isEmpty ? '?' : '${o['name']}'.trim())
                    .characters
                    .first
                    .toUpperCase(),
                style: const TextStyle(color: Colors.white)),
          ),
          title: Text('${o['name']}',
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(
              [
                CarePartnerType.label('${o['type']}'),
                if ('${o['city']}'.trim().isNotEmpty) '${o['city']}',
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          onTap: () {
            Navigator.of(context).pop();
            DoctorSession.instance.enterAsPartner('${o['id']}');
          },
        ),
    ]);
  }
}
