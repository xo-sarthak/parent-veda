import 'package:flutter/material.dart';

import 'screens/weekly_card_stack_screen.dart';
import 'services/baby_voice_service.dart';
import 'services/memory_store.dart';
import 'services/pregnancy_controller.dart';
import 'services/size_view_pref.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = PregnancyController();
    // Kick off the async content load; the screen shows a loader until ready.
    _controller.load();
    // Warm up the baby-voice engine (loads persisted mute state).
    BabyVoiceService.instance.init();
    // Load the persisted Fruit/Baby size-view preference.
    SizeViewPref.init();
    // Load saved journal entries + photo memories.
    MemoryStore.instance.init();
  }

  @override
  void dispose() {
    _controller.dispose();
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
      home: WeeklyCardStackScreen(controller: _controller),
    );
  }
}
