import 'package:flutter/material.dart';

import 'screens/main_scaffold.dart';
import 'services/baby_voice_service.dart';
import 'services/can_i_store.dart';
import 'services/community_store.dart';
import 'services/daily_store.dart';
import 'services/garbh_store.dart';
import 'services/father_content_controller.dart';
import 'services/home_content_controller.dart';
import 'services/hospital_bag_store.dart';
import 'services/memory_store.dart';
import 'services/pregnancy_controller.dart';
import 'services/size_view_pref.dart';
import 'services/tools_store.dart';
import 'theme/app_theme.dart';

void main() {
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
      home: MainScaffold(pregnancy: _controller, home: _home, father: _father),
    );
  }
}
