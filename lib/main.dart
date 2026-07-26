import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'brand/brand_store.dart';
import 'screens/post_pregnancy/pp_child_profile.dart';
import 'screens/post_pregnancy/pp_development_data.dart';
import 'screens/post_pregnancy/pp_documents_data.dart';
import 'screens/post_pregnancy/pp_food_data.dart';
import 'screens/post_pregnancy/pp_names_data.dart';
import 'screens/post_pregnancy/pp_reading_data.dart';
import 'screens/post_pregnancy/pp_reco_data.dart';
import 'screens/post_pregnancy/pp_watch_data.dart';
import 'screens/post_pregnancy/pp_yoga_data.dart';
import 'screens/post_pregnancy/pp_feeding_data.dart';
import 'screens/post_pregnancy/pp_growth_data.dart';
import 'screens/post_pregnancy/pp_health_data.dart';
import 'screens/post_pregnancy/pp_milestones_data.dart';
import 'screens/post_pregnancy/pp_sleep_data.dart';
import 'screens/post_pregnancy/pp_vaccine_data.dart';
import 'screens/post_pregnancy/pp_journeys_data.dart';
import 'services/family_profile.dart';
import 'services/profile_analytics.dart';
import 'doctor/doctor_schedule_store.dart';
import 'memories/memory_analytics.dart';
import 'care_partner/care_config.dart';
import 'care_partner/care_partner_store.dart';
import 'care_partner/care_presence_store.dart';
import 'referral/install_referrer.dart';
import 'referral/referral_analytics.dart';
import 'referral/referral_links.dart';
import 'referral/referral_store.dart';
import 'services/remote/supabase_memory_sink.dart';
import 'services/remote/supabase_profile_sink.dart';
import 'doctor/doctor_session.dart';
import 'screens/doctor/doctor_scaffold.dart';
import 'screens/splash_screen.dart';
import 'services/baby_voice_service.dart';
import 'services/bought_store.dart';
import 'services/bump_store.dart';
import 'services/calendar_store.dart';
import 'services/can_i_store.dart';
import 'services/cart_store.dart';
import 'services/community_store.dart';
import 'services/expert_follow_store.dart';
import 'services/daily_store.dart';
import 'services/garbh_store.dart';
import 'services/product_store.dart';
import 'services/read_next_store.dart';
import 'services/father_content_controller.dart';
import 'services/home_content_controller.dart';
import 'services/hospital_bag_store.dart';
import 'services/father_journal_store.dart';
import 'services/journal_store.dart';
import 'services/medicine_store.dart';
import 'services/memory_store.dart';
import 'services/pregnancy_controller.dart';
import 'services/product_checklist_store.dart';
import 'services/read_to_baby_saved_store.dart';
import 'services/read_to_baby_store.dart';
import 'services/size_view_pref.dart';
import 'services/journey_dates_store.dart';
import 'services/reminder_store.dart';
import 'services/scans_store.dart';
import 'services/symptom_store.dart';
import 'services/tools_store.dart';
import 'services/video_store.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';
import 'widgets/global_ask_fab.dart';

Future<void> main() async {
  // Flutter must be ready before we do async work like connecting to Supabase.
  WidgetsFlutterBinding.ensureInitialized();

  // Connect to the Supabase backend BEFORE the app starts, using the values
  // from lib/supabase_config.dart. By the time any screen loads, the backend
  // is ready.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const ParentVedaApp());
}

class ParentVedaApp extends StatefulWidget {
  const ParentVedaApp({super.key});

  @override
  State<ParentVedaApp> createState() => _ParentVedaAppState();
}

class _ParentVedaAppState extends State<ParentVedaApp> {
  // The single controller for the Week-on-Week Card Stack. It loads the
  // bundled content and derives the current week from a placeholder due date.
  late final PregnancyController _controller;

  // Loads the daily Home Screen ("Daily Moment") content.
  late final HomeContentController _home;

  // Loads the Father Mode "Daily Moment" content.
  late final FatherContentController _father;

  @override
  void initState() {
    super.initState();
    _controller = PregnancyController();
    // Kick off the async content load; the screen shows a loader until ready.
    _controller.load();
    _home = HomeContentController();
    _home.load();
    _father = FatherContentController();
    _father.load();
    // Warm up the baby-voice engine (loads persisted mute state).
    BabyVoiceService.instance.init();
    // Load the persisted Fruit/Baby size-view preference.
    SizeViewPref.init();
    // Load saved journal entries + photo memories.
    MemoryStore.instance.init();
    // Load Daily Moment persistence (moods, Talk-to-baby, kept affirmations).
    DailyStore.instance.init();
    // Load Tools persistence (movement, weight, kegel, contractions).
    ToolsStore.instance.init();
    // Load My Hospital Bag persistence.
    HospitalBagStore.instance.init();
    // Doctors' real availability (0033). The PARENT side needs this, not just
    // the doctor app: it is what makes a consult's bookable times the doctor's
    // actual hours instead of generated ones. Local first, then the server.
    DoctorScheduleStore.instance
        .init()
        .then((_) => DoctorScheduleStore.instance.syncFromServer());
    // Load Can I? saved-questions persistence.
    CanIStore.instance.init();
    // Load Garbh Sanskar Journey persistence (favorites, reflective tally).
    GarbhStore.instance.init();
    // Load Community persistence (joins, likes, saves, votes, posts).
    CommunityStore.instance.init();
    // Load followed experts (Twitter-style following, experts only).
    ExpertFollowStore.instance.init();
    // Load Products saved-list persistence.
    ProductStore.instance.init();
    // Load user-built Product Checklists.
    ProductChecklistStore.instance.init();
    // Load the preview shopping cart (products + hospital bag).
    CartStore.instance.init();
    // Load "bought" products (drives Already-bought markers on checklists).
    BoughtStore.instance.init();
    // Load Read Next saved/reading/completed states.
    ReadNextStore.instance.init();
    // Load My Journal entries.
    JournalStore.instance.init();
    // Load the father's separate journal entries.
    FatherJournalStore.instance.init();
    // Load My Calendar personal events.
    CalendarStore.instance.init();
    // Load My Bump Journey photos.
    BumpStore.instance.init();
    // Load Medication & Supplement tracking.
    MedicineStore.instance.init();
    // Load saved Watch & Learn videos.
    VideoStore.instance.init();
    // Load Symptoms Companion logs.
    SymptomStore.instance.init();
    // Load Scans & Appointments data.
    ScansStore.instance.init();
    // Load customizable reminders.
    ReminderStore.instance.init();
    // Load Read-to-your-baby feed preferences + saved pieces.
    ReadToBabyStore.instance.init();
    ReadToBabySavedStore.instance.init();
    // Load edited "when did this happen" dates for journey-map milestones.
    JourneyDatesStore.instance.init();
    // PARENTING: load the child profile(s). The keystone of the post-pregnancy
    // side - every other parenting feature keys its rows to a child from here.
    ChildProfileStore.instance.init();
    // PARENTING: the child's health record (medications, prescriptions,
    // allergies, symptoms, reports, doctor visits). Child-scoped and
    // co-parented - both paired parents read and write the same rows.
    HealthStore.instance.init();
    // PARENTING: growth measurements, vaccination doses, feed + sleep logs,
    // milestones observed and the document wallet. All child-scoped and
    // co-parented - one shared record per baby, either parent may write.
    GrowthStore.instance.init();
    VaxStore.instance.init();
    FeedingStore.instance.init();
    SleepStore.instance.init();
    MilestoneStore.instance.init();
    BabyDocumentsStore.instance.init();
    // PARENTING (light): saved lists, progress and preferences. These sync one
    // JSON blob each into user_state, where own-only RLS is exactly right - a
    // saved recipe or reading position is personal, not shared with a partner.
    DevStore.instance.init();
    FoodStore.instance.init();
    WatchStore.instance.init();
    ReadingStore.instance.init();
    RecoStore.instance.init();
    YogaStore.instance.init();
    NameMatchStore.instance.init();
    // PARENTING: the Living Family Profile — the personalization engine's single
    // source of truth (health/feeding/sleep/priorities/learning). Features read
    // it to tailor content, recommendations and ordering (never navigation).
    FamilyProfileStore.instance.init();
    // Send profiling analytics to Supabase (profile_events, 0028) instead of
    // the debug sink - one line, covers both sides of the app, and every insert
    // is fire-and-forget so a network hiccup can never touch a session.
    ProfileAnalytics.instance.setSink(const SupabaseProfileSink());
    // Init resolves the persistent install id, then one completeness snapshot
    // per launch - which is how "are profiles filling up over weeks?" becomes
    // answerable at all.
    ProfileAnalytics.instance.init().then((_) {
      ProfileAnalytics.instance
          .completeness(FamilyProfileStore.instance.completenessPercent);
    });
    // MEMORIES: the share-card funnel (started -> template -> photo -> preview
    // -> saved -> shared) into the SAME profile_events table, tagged
    // surface='memories'. Reuses ProfileAnalytics' install/session ids, so it
    // must be set after that sink above.
    MemoryAnalytics.instance.setSink(const SupabaseMemorySink());
    // REFERRAL: the growth funnel into the SAME profile_events table, tagged
    // surface='referral'. Anonymous by inheritance - no user_id, and never the
    // referral code, which identifies a person.
    ReferralAnalytics.setSink(const SupabaseReferralSink());
    ReferralStore.instance.init().then((_) async {
      // Play Install Referrer FIRST: a friend who installed from a shared link
      // arrives with the code attached, and it should be applied before we
      // sync anything up. Once ever, Android only, silent when there is none.
      // Campaign terms first (0036): everything below reads config, and a
      // stale reward label on the invite screen is a promise we did not make.
      await ReferralStore.instance.loadConfig();
      // Care Partner state is restored BEFORE the install referrer runs, not
      // after: checkOnce() can hold a partner token, and a load that landed
      // afterwards would overwrite it with what was on disk a moment earlier.
      // (CarePartnerStore.init also refuses to clobber a token already held in
      // memory, because a deep link can arrive at any point.)
      await CarePartnerStore.instance.init();
      await CarePresenceStore.instance.init();
      await InstallReferrerService.instance.checkOnce();
      // Care Partner attribution: a QR scanned before signup is held until
      // there is an account to bind it to, then applied here.
      await CareConfig.instance.load();
      await CarePartnerStore.instance.applyPending();
      await CarePartnerStore.instance.refreshFromServer();
      await ReferralStore.instance.syncToServer();
    });
    // Listen for invite links from the OS. Covers the cold-start case too (the
    // app launched BY the link), which is the one that silently loses codes.
    ReferralLinks.startListening();
    // PARENTING: guided day-by-day journeys (enrolment + which days are read).
    JourneyStore.instance.init();
    // BRAND STUDIO: which campaigns this parent has already been shown. Loaded
    // so frequency caps ("once per campaign") survive a restart or reinstall.
    BrandStudioStore.instance.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _home.dispose();
    _father.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParentVeda',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      // Root navigator key + observer power the global "Ask Veda" FAB.
      navigatorKey: appNavigatorKey,
      navigatorObservers: [fabRouteObserver],
      // Two things wrap every route here:
      //   * the global Ask-Veda FAB (parent app only), and
      //   * the doctor swap — when a doctor logs in, the WHOLE app becomes their
      //     dashboard, exactly as FatherPreview flips mother/father. Done in the
      //     builder (not home) so it holds across every navigation, and the
      //     parent app is kept OFFSTAGE (state preserved) so exiting returns
      //     right where they were. The doctor app gets its own Navigator so its
      //     pushes (availability, prescription, call) work.
      builder: (context, child) => AnimatedBuilder(
        animation: DoctorSession.instance,
        builder: (context, _) {
          final doctor = DoctorSession.instance.active;
          return Stack(fit: StackFit.expand, children: [
            Offstage(
              offstage: doctor,
              // fit: StackFit.expand is load-bearing. This Stack is a
              // non-positioned child of the outer Stack, so it is laid out with
              // LOOSE constraints (min 0x0). A Stack with no non-positioned
              // child takes constraints.biggest - fine - but the moment its only
              // non-positioned child is zero-sized it collapses to 0x0 and
              // everything inside, i.e. THE ENTIRE APP, renders at zero size:
              // a totally black screen.
              //
              // That is exactly what happened whenever GlobalAskFab hid itself
              // (it returned a bare SizedBox.shrink): over the Ask Veda screen,
              // over the Premiere takeover, and over EVERY modal bottom sheet
              // and dialog, because the FAB suppresses itself on any PopupRoute.
              // Hence "black screens all over the app" that no renderer flag
              // could fix - it was never Impeller, it was layout. Expanding
              // pins this Stack to the full screen whatever the FAB returns.
              child: Stack(fit: StackFit.expand, children: [
                ?child,
                GlobalAskFab(pregnancy: _controller),
              ]),
            ),
            if (doctor)
              Positioned.fill(
                child: Navigator(
                  onGenerateRoute: (_) => MaterialPageRoute<void>(
                      builder: (_) => const DoctorScaffold()),
                ),
              ),
          ]);
        },
      ),
      home: SplashScreen(pregnancy: _controller, home: _home, father: _father),
    );
  }
}
