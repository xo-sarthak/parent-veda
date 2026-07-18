import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'brand/brand_store.dart';
import 'screens/post_pregnancy/pp_child_profile.dart';
import 'screens/post_pregnancy/pp_journeys_data.dart';
import 'screens/post_pregnancy/pp_family_profile.dart';
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
    // PARENTING: the Living Family Profile — the personalization engine's single
    // source of truth (health/feeding/sleep/priorities/learning). Features read
    // it to tailor content, recommendations and ordering (never navigation).
    FamilyProfileStore.instance.init();
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
      // Inject one Ask-Veda FAB above every route in both apps. It hides itself
      // over sheets / the Premiere / the splash — see GlobalAskFab.
      builder: (context, child) => Stack(children: [
        if (child != null) Positioned.fill(child: child),
        GlobalAskFab(pregnancy: _controller),
      ]),
      // Launch into the splash screen; it cross-fades into MainScaffold.
      home: SplashScreen(pregnancy: _controller, home: _home, father: _father),
    );
  }
}
