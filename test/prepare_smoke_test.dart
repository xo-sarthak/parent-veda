// Smoke test: every Prepare screen must build without throwing. Confirms the
// runtime "Null is not a subtype of Specialist" seen after a hot-reload is a
// stale-instance artifact (fixed by hot restart), not a code bug.
//
// It now builds every screen TWICE, once per language. The Prepare tab shipped
// language-unaware - its data was translated but not one screen took an
// AppLanguage - so a Hindi build rendered Hindi programme titles inside English
// chrome. Building in both languages is what stops that regressing: a screen
// that forgets to take `lang` will not compile, and one that takes it but keeps
// a hardcoded literal still shows up here the moment someone asserts on copy.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parentveda/data/prepare_data.dart';
import 'package:parentveda/localization/app_language.dart';
import 'package:parentveda/screens/prepare/birthing_classes_screen.dart';
import 'package:parentveda/screens/prepare/cohort_detail_screen.dart';
import 'package:parentveda/screens/prepare/cohorts_screen.dart';
import 'package:parentveda/screens/prepare/consultation_detail_screen.dart';
import 'package:parentveda/screens/prepare/consultations_screen.dart';
import 'package:parentveda/screens/prepare/masterclass_detail_screen.dart';
import 'package:parentveda/screens/prepare/masterclasses_screen.dart';
import 'package:parentveda/screens/prepare/courses_cohorts_screen.dart';
import 'package:parentveda/screens/prepare/nutrition_screen.dart';
import 'package:parentveda/screens/post_pregnancy/yoga_home_screen.dart';
import 'package:parentveda/screens/prepare/prenatal_yoga_screen.dart';
import 'package:parentveda/screens/prepare/prepare_common.dart';
import 'package:parentveda/screens/prepare/prepare_hub_screen.dart';
import 'package:parentveda/screens/prepare/prepare_video_screen.dart';
import 'package:parentveda/screens/prepare/program_detail_screen.dart';

Map<String, Widget> _screens(AppLanguage lang) => <String, Widget>{
      'hub': PrepareHubScreen(lang: lang),
      'masterclasses': MasterclassesScreen(lang: lang),
      'consultations': ConsultationsScreen(lang: lang),
      'cohorts': CohortsScreen(lang: lang),
      // Yoga now uses the shared cult.fit screen, filtered to pregnancy categories.
      'yoga': const YogaHomeScreen(categoryFilter: kPregnancyYogaCategories),
      'prenatal yoga': PrenatalYogaScreen(lang: lang),
      'birthing': BirthingClassesScreen(lang: lang),
      'masterclass detail':
          MasterclassDetailScreen(m: kMasterclasses.first, lang: lang),
      'consultation detail':
          ConsultationDetailScreen(specialist: kSpecialists.first, lang: lang),
      'cohort detail': CohortDetailScreen(cohort: kCohorts.first, lang: lang),
      'courses & cohorts': CoursesCohortsScreen(lang: lang),
      'program detail': ProgramDetailScreen(program: kPrepPrograms.first, lang: lang),
      'nutrition': NutritionScreen(lang: lang),
      'nutrition plans': NutritionPlansScreen(goalId: 'gd', lang: lang),
      'nutrition trailer':
          NutritionTrailerScreen(plan: kNutritionPlans.first, lang: lang),
      'nutrition diet plan':
          NutritionDietPlanScreen(plan: kNutritionPlans.first, lang: lang),
      'video': PrepareVideoScreen(lang: lang, title: 'A class'),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  for (final lang in AppLanguage.values) {
    final label = lang.isEnglish ? 'english' : 'hindi';
    _screens(lang).forEach((name, screen) {
      testWidgets('$name builds without throwing ($label)', (tester) async {
        // Same 800px width as the default harness window, but taller. The
        // default 800x600 is shorter than any real device, and
        // PrepareVideoScreen is a fixed-height Column (a 16:10 player plus
        // copy) rather than a scroller - it overflows 600px here while
        // fitting every handset. Only the height is changed: narrowing the
        // width instead makes the wide cards overflow sideways and turns this
        // smoke test into a layout test it was never meant to be.
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(MaterialApp(home: screen));
        await tester.pump();
        expect(tester.takeException(), isNull);
      });
    });
  }

  // The pill used to be hardcoded with EN highlighted whatever language was in
  // force, so a mother reading Hindi was told she was in English. Colour is the
  // only thing that carries the claim - both labels are always on screen - so
  // colour is what this asserts.
  group('the language pill states the language actually in force', () {
    Color? colourOf(WidgetTester tester, String label) {
      final rich = tester.widget<RichText>(find.byType(RichText).first);
      Color? found;
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text == label) {
          found = span.style?.color;
          return false;
        }
        return true;
      });
      return found;
    }

    for (final lang in AppLanguage.values) {
      testWidgets(lang.isEnglish ? 'english' : 'hindi', (tester) async {
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(body: Center(child: pvLangToggle(lang))),
        ));
        expect(colourOf(tester, 'EN'), lang.isEnglish ? kPurple : kMuted);
        expect(colourOf(tester, 'हिं'), lang.isEnglish ? kMuted : kPurple);
      });
    }
  });
}
