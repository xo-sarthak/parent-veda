// =============================================================================
//  TTC - bilingual UI strings
// -----------------------------------------------------------------------------
//  "Bilingual from the first string - English and conversational Hinglish,
//   never one retrofitted later."          - Product Reference, rule §12.3.11
//
//  Follows the app's _p(english, hinglish) convention exactly. The Hinglish is
//  real conversational Hinglish in Latin script, not formal Hindi and not
//  transliterated English.
//
//  Kept module-local rather than added to the shared S class: these strings are
//  read by the TTC stage only, and the shared class already carries ~1,800.
//
//  ---------------------------------------------------------------------------
//  TtcLang is a MIRROR, not a second source of truth. The app's language lives
//  on PregnancyController, which is constructed in main.dart and threaded down
//  rather than exposed as a singleton - and the TTC tabs are separate pushed
//  routes, so an InheritedWidget cannot reach across them. The doorway syncs
//  this mirror from the controller on the way in, and the Profile toggle
//  updates it. Documented in docs/TTC-SPEC.md as a seam to remove the day the
//  app language becomes a proper app-wide store.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the TTC stage is running in the PARTNER's experience.
///
/// The real path is pairing - the partner signs up, enters her code, and lands
/// here permanently. This singleton also backs a dev-only Her|Him pill on the
/// TTC Today tab for design review, exactly like the pregnancy shell's Mom|Dad
/// switch, and like that one it is marked for removal before launch.
class TtcPartnerMode extends ChangeNotifier {
  TtcPartnerMode._();
  static final TtcPartnerMode instance = TtcPartnerMode._();

  bool _on = false;
  bool get on => _on;

  set on(bool v) {
    if (_on == v) return;
    _on = v;
    notifyListeners();
  }
}

class TtcLang extends ChangeNotifier {
  TtcLang._() {
    _load();
  }
  static final TtcLang instance = TtcLang._();

  /// Persisted, because it was not.
  ///
  /// This used to be memory-only, and the only thing that ever SET it was the
  /// door on the pregnancy home. A family who signed up as trying-to-conceive
  /// therefore had no way to reach Hinglish at all - every `_p(en, hi)` string
  /// in the stage was written for an audience that could not get to it.
  static const String kKey = 'ttc_hinglish';

  bool _hinglish = false;
  bool get hinglish => _hinglish;

  set hinglish(bool v) {
    if (_hinglish == v) return;
    _hinglish = v;
    _persist();
    notifyListeners();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getBool(kKey);
      if (saved != null && saved != _hinglish) {
        _hinglish = saved;
        notifyListeners();
      }
    } catch (_) {/* keep the default */}
  }

  Future<void> _persist() async {
    try {
      await (await SharedPreferences.getInstance()).setBool(kKey, _hinglish);
    } catch (_) {/* best-effort, same as every other TTC store */}
  }
}

/// TTC strings. Construct with the current language: `final t = TtcS(hi);`
class TtcS {
  const TtcS(this.hinglish);
  final bool hinglish;

  /// Convenience for building from the mirror.
  factory TtcS.current() => TtcS(TtcLang.instance.hinglish);

  String _p(String en, String hi) => hinglish ? hi : en;

  // ---- tabs -----------------------------------------------------------------
  String get tabToday => _p('Today', 'Aaj');
  String get tabPrepare => _p('Prepare', 'Taiyaari');
  String get tabTools => _p('Tools', 'Tools');
  String get tabCalendar => _p('Calendar', 'Calendar');
  String get tabCommunity => _p('Community', 'Community');

  // ---- greetings ------------------------------------------------------------
  String get goodMorning => _p('Good morning', 'Suprabhat');
  String get goodAfternoon => _p('Good afternoon', 'Namaste');
  String get goodEvening => _p('Good evening', 'Shubh sandhya');

  // ---- the hero -------------------------------------------------------------
  String get todaysJourney => _p("Today's journey", 'Aaj ka safar');
  String get yourChapter => _p('Your chapter', 'Aapka chapter');
  String get currentFocus => _p('Focus', 'Dhyaan');
  String get currentGoal => _p('Worth doing', 'Karne layak');

  /// The three in-hero shortcuts. "Me · Us · What's next" replaces pregnancy's
  /// "Baby · Mother · What's next" - the couple is the subject here.
  String get shortcutMe => _p('Me', 'Main');
  String get shortcutUs => _p('Us', 'Hum');
  String get shortcutNext => _p("What's next", 'Aage kya');

  String daysTrying(int days) => days < 1
      ? _p('Starting today', 'Aaj se shuru')
      : days == 1
          ? _p('Day 1 together', 'Saath mein pehla din')
          : _p('$days days together', '$days din saath mein');

  // ---- the cycle card -------------------------------------------------------
  String get yourRhythm => _p('Your rhythm', 'Aapki rhythm');
  String get fertilityToday => _p('Today', 'Aaj');
  String get chanceLabel => _p('Chance of conceiving', 'Conceive karne ka mauka');

  String get logPeriodTitle =>
      _p('Tell us when your last period began', 'Aapka last period kab shuru hua?');
  String get logPeriodBody => _p(
      'One date is all we need to start understanding your rhythm. Nothing else is required, and you can change it any time.',
      'Bas ek date chahiye, taaki hum aapki rhythm samajh sakein. Aur kuch zaroori nahi - aur aap kabhi bhi badal sakti hain.');
  String get logPeriodCta => _p('Add the date', 'Date add karein');

  String get noEstimateYet =>
      _p('We are still learning your rhythm', 'Hum abhi aapki rhythm seekh rahe hain');
  String get noEstimateBody => _p(
      'After a cycle or two we can share a gentle estimate. Until then, nothing here is a guess.',
      'Ek-do cycle ke baad hum ek halka sa andaaza de payenge. Tab tak, yahan kuch bhi guess nahi hai.');

  // ---- why there is no estimate ---------------------------------------------
  //  "Still learning your rhythm" is true for a new user and untrue for
  //  everyone else. Said to someone with a year of entries it reads as the app
  //  being broken, so each refusal now explains itself and, where she can do
  //  something about it, says what.

  String get noEstHistoryOffTitle => _p('Something in your dates looks off',
      'Aapki dates mein kuch theek nahi lag raha');
  String get noEstHistoryOffBody => _p(
      'One of your recorded gaps is far longer than a cycle usually runs - most often a cycle that was never logged. We would rather show nothing than build an estimate on it. Fixing or removing that entry brings the estimate back.',
      'Aapke record kiye gaps mein se ek cycle se kaafi lamba hai - aksar wo cycle jo log hi nahi hua. Uspe andaaza banane se accha hai kuch na dikhayein. Us entry ko theek ya delete karne par andaaza wapas aa jaayega.');

  String get noEstOverdueTitle =>
      _p('This cycle is running long', 'Ye cycle lamba chal raha hai');
  String get noEstOverdueBody => _p(
      'You are past where your own cycles usually end, so today\'s estimate would be arithmetic on an assumption that has already been contradicted. This happens, and on its own it is not a warning sign - but if it keeps happening, it is worth a doctor knowing.',
      'Aap wahan se aage hain jahan aapke cycles aam taur par khatam hote hain, isliye aaj ka andaaza ek galat maani hui baat par hoga. Aisa hota hai, aur akele mein ye chinta ki baat nahi - par baar-baar ho toh doctor ko batana theek rahega.');

  /// "28 days" but "1 day". The list said "1 days".
  String cycleDayCount(int days) => hinglish
      ? '$days din'
      : days == 1
          ? '1 day'
          : '$days days';

  /// Shown against a logged date the engine did not count.
  String get notCountedChip => _p('Not counted', 'Gina nahi gaya');
  String get notCountedWhy => _p(
      'Too close to the entry before it to be a separate cycle, so it is kept but not used in the average.',
      'Pichhli entry ke itne paas hai ki alag cycle nahi ho sakta, isliye rakha gaya hai par average mein use nahi hota.');

  /// Shown at the moment she logs a start that cannot be a new cycle.
  String tooCloseWarning(int days) => _p(
      'That is $days days after the last start you logged. Periods do not usually begin that close together - if this is the same period, you may not need a second entry.',
      'Ye aapke pichhle start ke $days din baad hai. Periods aam taur par itne paas shuru nahi hote - agar ye wahi period hai toh shayad doosri entry ki zaroorat nahi.');
  String get tooCloseKeep => _p('Add it anyway', 'Phir bhi add karein');
  String get tooCloseCancel => _p('Cancel', 'Rehne dein');

  String estimatedOvulation(int day) =>
      _p('Ovulation around day $day', 'Ovulation lagbhag din $day');

  String cycleDayQuiet(int day) => _p('Cycle day $day', 'Cycle din $day');

  String get logNewPeriod => _p('Log a new period', 'Naya period log karein');

  // ---- the daily set --------------------------------------------------------
  String get todaysJourneyTitle =>
      _p('What matters today', 'Aaj kya zaroori hai');

  String get todaysInsight => _p("Today's insight", 'Aaj ki baat');
  String readSeconds(int s) => _p('$s sec read', '$s sec');

  String get todaysVideo => _p("Today's video", 'Aaj ka video');
  String whyNow(String chapter) =>
      _p('Because you are in $chapter', 'Kyunki aap $chapter mein hain');
  String get videoComing => _p(
      'Video is being filmed for this chapter.',
      'Is chapter ke liye video banaya ja raha hai.');

  String get dailyRitual => _p('Daily ritual', 'Roz ka ritual');
  String get dailyRitualTitle =>
      _p('Five minutes, together', 'Paanch minute, saath mein');
  String get dailyRitualBody => _p(
      'Not meditation, and not a task list. One small thing for your head, your breath, each other, and the day.',
      'Na meditation, na kaamon ki list. Ek chhoti cheez dimaag ke liye, saans ke liye, ek doosre ke liye, aur din ke liye.');
  String dayStreak(int days) =>
      _p(days == 1 ? '1 day' : '$days days', days == 1 ? '1 din' : '$days din');

  String get todaysMyth => _p('Myth vs fact', 'Myth aur sach');

  String get myJournal => _p('Our journal', 'Hamara journal');
  String entryCount(int n) =>
      _p(n == 1 ? '1 entry' : '$n entries', n == 1 ? '1 entry' : '$n entries');

  String get todaysNutrition => _p("Today's nutrition", 'Aaj ka khaana');
  String get todaysMovement => _p("Today's movement", 'Aaj ki harkat');
  String minutes(int m) => _p('$m min', '$m min');

  String get todaysPick => _p("Today's pick", 'Aaj ka pick');

  // ---- the chapter page -----------------------------------------------------
  String get chapterTabMe => _p('Me', 'Main');
  String get chapterTabUs => _p('Us', 'Hum');
  String get chapterTabNext => _p("What's next", 'Aage kya');

  String get chapterYouAreHere => _p('You are here', 'Aap yahan hain');
  String get actionsNoScore => _p(
      'Suggestions, not a checklist. Nothing here is scored, and doing none of it this month is fine.',
      'Ye sujhaav hain, checklist nahi. Yahan kisi cheez ka score nahi hai, aur is mahine kuch bhi na karein toh bhi theek hai.');
  String get forPartnerTag => _p('For your partner', 'Partner ke liye');

  String get chapterOverview => _p('What this chapter is', 'Ye chapter kya hai');
  String get chapterScience => _p('The science, gently', 'Science, aaram se');
  String get chapterBody => _p('Your body right now', 'Aapka body abhi');
  String get chapterPartner => _p('For your partner', 'Aapke partner ke liye');
  String get chapterActions => _p('Worth doing this chapter', 'Is chapter mein karne layak');
  String get chapterMedical => _p('When to see someone', 'Doctor se kab milein');
  String get chapterAskVeda => _p('Ask Veda about this', 'Iske baare mein Ask Veda');
  String get chapterJournalPrompts => _p('Write about it', 'Iske baare mein likhein');

  // ---- the journal ----------------------------------------------------------
  String get journalTitle => _p('Our journal', 'Hamara journal');
  String get journalEmptyTitle =>
      _p('Nothing written yet', 'Abhi kuch likha nahi');
  String get journalEmptyBody => _p(
      'This is where the parts you will want to remember go - including the hard ones. Both of you can write here.',
      'Yahan wo cheezein aati hain jo aage yaad rakhna chahenge - mushkil waali bhi. Dono yahan likh sakte hain.');
  String get journalWrite => _p('Write', 'Likhein');
  String get journalSave => _p('Save', 'Save karein');
  String get journalCancel => _p('Cancel', 'Rehne dein');
  String get journalHint => _p('Whatever you want to say', 'Jo bhi kehna hai');
  String get journalByPartner => _p('Written by your partner', 'Partner ne likha');
  String get journalDelete => _p('Delete this entry', 'Ye entry hatayein');

  // ---- the ritual page ------------------------------------------------------
  String get ritualTitle => _p('Your daily ritual', 'Aapka roz ka ritual');
  String get ritualDone => _p('Done for today', 'Aaj ke liye ho gaya');
  String get ritualMarkDone => _p('Mark as done', 'Ho gaya');
  String get ritualWhy => _p('Why this is here', 'Ye yahan kyun hai');

  // ---- trackers -------------------------------------------------------------
  String get trackerToday => _p('Today', 'Aaj');
  String get trackerHistory => _p('What you have recorded', 'Jo aapne record kiya');
  String get trackerClear => _p('Clear', 'Hatayein');
  String get trackerTapToAdd => _p('Tap to add', 'Add karne ke liye tap karein');
  String get trackerEmptyTitle => _p('Nothing recorded yet', 'Abhi kuch record nahi hua');
  String get trackerEmptyBody => _p(
      'Log whenever you feel like it. There is no streak to keep and no gap that counts against you.',
      'Jab man kare tab log karein. Na koi streak nibhani hai, na koi khaali din aapke khilaf ginta hai.');

  // ---- cycle tools ----------------------------------------------------------
  String get cycleCompanion => _p('Cycle Companion', 'Cycle Companion');
  String get cycleHistory => _p('Your cycles', 'Aapke cycles');
  String get cycleAverage => _p('Average length', 'Average lambai');
  String get cycleRange => _p('Range', 'Range');
  String get cycleDays => _p('days', 'din');
  String get cycleIrregularNote => _p(
      'Your cycles vary quite a lot. That is worth mentioning to a doctor - it makes timing harder, not impossible, and it is common.',
      'Aapke cycles kaafi badalte hain. Ye doctor ko batane layak hai - isse timing mushkil hoti hai, namumkin nahi, aur ye aam baat hai.');
  String get cycleNeedMore => _p(
      'Log one more period and we can start describing your own rhythm instead of an average one.',
      'Ek aur period log karein, phir hum average ki jagah aapki apni rhythm bata payenge.');

  String get ovulationCompanion => _p('Ovulation Companion', 'Ovulation Companion');
  String get ovulationSignals => _p('Your own signals', 'Aapke apne signals');
  String get ovulationLh => _p('Positive ovulation strip', 'Ovulation strip positive');
  String get ovulationBbt => _p('Temperature rise seen', 'Temperature badha dikha');
  String get ovulationSignalNote => _p(
      'A recorded signal from your own body always beats our calendar estimate, so logging one changes what we show you.',
      'Aapke apne body ka record kiya gaya signal, hamare calendar andaaze se hamesha behtar hai - isliye ise log karne se hum jo dikhate hain wo badal jaata hai.');
  String get ovulationNotYet => _p(
      'Log a period first and we can estimate this.',
      'Pehle ek period log karein, phir hum iska andaaza laga sakte hain.');

  // ---- what these two signals actually are ----------------------------------
  //  The screen named an ovulation strip and a temperature rise and explained
  //  neither, then asked her to "mark as done" - a checklist verb for something
  //  that is a reading, not a task. Someone who already knows this subject
  //  needed none of it; someone who does not learned nothing.

  String get ovulationLhWhat => _p(
      'A pee-on stick from any pharmacy, around ₹30–60 each. It turns positive in the day or two BEFORE you ovulate, which is what makes it useful - it tells you the window is opening, not that it has closed.',
      'Kisi bhi pharmacy se milne wali stick, lagbhag ₹30–60 ki. Ovulation se ek-do din PEHLE positive aati hai - isiliye kaam ki hai. Ye batati hai ki window khul rahi hai, band nahi hui.');

  String get ovulationBbtWhat => _p(
      'Your temperature the moment you wake, before sitting up, taken at the same time each day with a basal thermometer. It rises AFTER ovulation, so it confirms what happened rather than predicting what will - useful for learning your pattern over months, not for timing this week.',
      'Jagte hi, uthne se pehle, roz ek hi waqt par basal thermometer se liya gaya temperature. Ye ovulation ke BAAD badhta hai - yaani jo ho chuka use confirm karta hai, aage ka nahi batata. Mahino mein pattern samajhne ke liye kaam ka, is hafte ki timing ke liye nahi.');

  /// Above the prompt offered on an empty journal.
  String get journalPromptEyebrow =>
      _p('If you want somewhere to start', 'Agar shuru karne ki jagah chahiye');

  // ---- when a logged symptom is worth a doctor -------------------------------
  //  Ask Veda's guardrails treat "severe pain" as a red flag and route to a
  //  doctor. The tracker recorded the identical thing in silence, so two parts
  //  of one product disagreed about what severe pain means.
  //
  //  Deliberately NOT alarming, and deliberately not a diagnosis: it names the
  //  thing worth mentioning and stops. Anything stronger would break the rule
  //  this tracker is built on - notice, never diagnose.
  String get severeNoticedTitle =>
      _p('Worth mentioning to a doctor', 'Doctor ko batane layak');
  String get severeNoticedBody => _p(
      'You have recorded something as severe. That does not mean anything is wrong - but severe pain is one of the things worth saying out loud at your next appointment rather than waiting to see if it settles.',
      'Aapne kuch "bahut zyada" record kiya hai. Iska matlab ye nahi ki kuch galat hai - par tez dard un cheezon mein hai jo agli appointment par khud bata dena behtar hai, ye dekhne se ki apne aap theek hota hai ya nahi.');
  String get severeNoticedAdd =>
      _p('Add it to my questions', 'Mere sawaalon mein jodein');

  /// Replaces "Mark as done".
  String get ovulationRecordIt => _p('Record it', 'Record karein');
  String get ovulationWhichDay => _p('Which day?', 'Kis din?');
  String get ovulationToday => _p('Today', 'Aaj');
  String whichCycleDay(int day) => _p('Cycle day $day', 'Cycle din $day');

  String get fertilityWindow => _p('Fertility Window', 'Fertility Window');
  String get fertilityAcross => _p('Across this cycle', 'Is cycle mein');
  String get fertilityWindowNote => _p(
      'Roughly six days, ending the day after ovulation. Sperm survive about five days; the egg about one. The width is the point - no single day has to be right.',
      'Lagbhag chhe din, ovulation ke agle din tak. Sperm lagbhag paanch din chalte hain; egg lagbhag ek. Yahi chaudai asli baat hai - kisi ek din ka sahi hona zaroori nahi.');

  // ---- supplements ----------------------------------------------------------
  String get supplements => _p('Supplements', 'Supplements');
  String get supplementsTakenToday => _p('Taken today', 'Aaj liya');
  String get supplementsAdd => _p('Add a supplement', 'Supplement add karein');
  String get supplementsEmptyTitle =>
      _p('Nothing added yet', 'Abhi kuch add nahi kiya');
  String get supplementsEmptyBody => _p(
      'Add what you actually take, including anything your doctor prescribed. Folic acid is the one with the strongest evidence behind it.',
      'Jo aap sach mein lete hain wo add karein, doctor ki di hui dawai bhi. Folic acid wo hai jiske peeche sabse mazboot saboot hai.');
  String get supplementsSuggested => _p('Commonly taken', 'Aam taur par liye jaate hain');
  String get supplementsDisclaimer => _p(
      'This is a record of what you take, not a recommendation to take it. Doses and combinations belong with your doctor.',
      'Ye record hai ki aap kya lete hain, ye salaah nahi hai ki lein. Dose aur combination aapke doctor ke saath tay hote hain.');

  // ---- medical tests --------------------------------------------------------
  String get medicalTests => _p('Medical Tests', 'Medical Tests');
  String get testsIntro => _p(
      'What each test actually tells you, in plain language - so you can decide what is worth doing and understand what comes back.',
      'Har test asal mein kya batata hai, saaf bhaasha mein - taaki aap tay kar sakein ki kya karwana hai, aur jo result aaye use samajh sakein.');
  String get testWhat => _p('What it measures', 'Ye kya naapta hai');
  String get testWhy => _p('Why it is done', 'Ye kyun hota hai');
  String get testWhen => _p('When in the cycle', 'Cycle mein kab');
  String get testCost => _p('Typical cost in India', 'India mein aam kharcha');
  String get testReading => _p('Reading the result', 'Result samajhna');
  String get testForHim => _p('For him', 'Unke liye');
  String get testForHer => _p('For her', 'Uske liye');
  String get testMore => _p('Read more', 'Aur padhein');
  String get testLess => _p('Less', 'Kam');

  // ---- journey map, milestones, timeline ------------------------------------
  String get journeyMap => _p('Journey Map', 'Journey Map');
  String get journeyMapIntro => _p(
      'The chapters you move through, and everything you have done so far. Chapters two to four come round again with each cycle - that is the shape of this, not a step backwards.',
      'Wo chapters jinse aap guzarti hain, aur ab tak jo kuch kiya. Chapter do se chaar har cycle ke saath dobara aate hain - yahi iska aakaar hai, peechhe jaana nahi.');
  String get milestones => _p('What you have done', 'Jo aapne kiya');
  String get milestonesAhead => _p('Still ahead', 'Aage aur');
  String get milestonesNone => _p(
      'Your first milestone is already here - you started.',
      'Aapka pehla milestone pehle se hai - aapne shuru kiya.');

  String get familyTimeline => _p('Family Timeline', 'Family Timeline');
  String get familyTimelineIntro => _p(
      'One continuous story - from the day you decided, through pregnancy, into the years after. Nothing here restarts when a stage changes.',
      'Ek continuous kahani - jis din aapne socha, us din se pregnancy tak, aur uske baad ke saalon tak. Stage badalne par yahan kuch phir se shuru nahi hota.');
  String get timelineEmptyTitle =>
      _p('Your story starts here', 'Aapki kahani yahin se');
  String get timelineEmptyBody => _p(
      'As you log, write and reach things, they land here in order - and they stay here through pregnancy and parenting.',
      'Jaise-jaise aap log karengi, likhengi aur cheezein poori karengi, wo yahan kramvaar aati jayengi - aur pregnancy aur parenting tak yahin rahengi.');

  // ---- calendar -------------------------------------------------------------
  String get calendarLegend => _p('What the colours mean', 'Rang kya kehte hain');
  String get calendarPeriod => _p('Period', 'Period');
  String get calendarFertile => _p('Fertile days', 'Fertile din');
  String get calendarOvulation => _p('Estimated ovulation', 'Ovulation ka andaaza');
  String get calendarLogged => _p('You logged something', 'Aapne kuch log kiya');
  String get calendarNothing =>
      _p('Nothing on this day', 'Is din kuch nahi');
  String get calendarUpcoming => _p('Coming up', 'Aage');
  String get calendarNextPeriod => _p('Next period expected', 'Agla period expected');
  String get calendarToday => _p('Today', 'Aaj');

  // ---- the partner ----------------------------------------------------------
  String get partnerToday => _p('Today', 'Aaj');
  String get partnerTodayTitle => _p('Your part today', 'Aaj aapka hissa');
  String get partnerMission => _p("Today's mission", 'Aaj ka kaam');
  String get partnerLearn => _p("Today's learn", 'Aaj seekhein');
  String get partnerSupport => _p('Supporting her', 'Unka saath');
  String get partnerSheMayFeel =>
      _p('What she may be carrying', 'Wo kya jhel rahi hain');
  String get partnerYouCan => _p('What you can do', 'Aap kya kar sakte hain');
  String get partnerYourBody => _p('Your half of this', 'Iska aapka aadha hissa');
  String get partnerReflection => _p("Today's reflection", 'Aaj ka vichaar');
  String get partnerNutrition => _p("Today's nutrition", 'Aaj ka khaana');
  String get partnerMovement => _p("Today's movement", 'Aaj ki harkat');
  String get partnerJournal => _p('Shared journal', 'Shared journal');
  String get partnerJournalNote => _p(
      'She can read what you write here, and you can read hers. That is the point of it.',
      'Aap jo yahan likhte hain wo padh sakti hain, aur aap unka. Yahi iska maqsad hai.');
  String get partnerAboutHimself => _p('This one is about you', 'Ye aapke baare mein hai');
  String get partnerReadTogether => _p('Read together', 'Saath padhein');
  String get partnerSwitch => _p('Her view', 'Unka view');
  String get partnerHim => _p('Him', 'Unka');
  String get partnerHer => _p('Her', 'Unka');

  // ---- prepare --------------------------------------------------------------
  String get prepareForBoth => _p('For both of you', 'Aap dono ke liye');
  String prepareSessions(int n) => _p(
      n == 1 ? '1 session' : '$n sessions', n == 1 ? '1 session' : '$n sessions');
  String get prepareBuy => _p('Get this', 'Ye lein');
  String get prepareBought => _p('Added to your bookings', 'Aapki bookings mein add ho gaya');
  String get prepareOwned => _p('You have this', 'Aapke paas hai');
  String prepareCreditsLeft(int n) =>
      _p(n == 1 ? '1 left' : '$n left', n == 1 ? '1 bacha' : '$n bache');
  String get prepareSlots => _p('Pick a time', 'Samay chunein');
  String get prepareBuyFirst =>
      _p('Times appear once you have this.', 'Ye lene ke baad samay dikhenge.');
  String get prepareBook => _p('Book', 'Book karein');
  String get prepareBooked => _p('Booked', 'Book ho gaya');
  String get prepareBookFailed => _p(
      'That time was taken. Please pick another.',
      'Wo samay le liya gaya. Koi aur chunein.');
  String get prepareNoSlots => _p('No times open right now', 'Abhi koi samay khaali nahi');
  String get prepareNoSlotsBody => _p(
      'New times open regularly. Nothing has been lost - what you have stays yours.',
      'Naye samay aate rehte hain. Kuch khoya nahi - jo aapke paas hai wo aapka hi rahega.');
  String get prepareNoPayment => _p(
      'No payment is taken yet. Buying here records what you chose so the flow can be tested end to end - no money moves.',
      'Abhi koi payment nahi li jaati. Yahan lene se sirf record hota hai ki aapne kya chuna, taaki poora flow test ho sake - paisa kahin nahi jaata.');

  // ---- care circle ----------------------------------------------------------
  String get careCircle => _p('Your Care Circle', 'Aapka Care Circle');
  String get careCircleIntro => _p(
      'Everyone walking this with you, in one place - and where every recommendation you see comes from.',
      'Wo sab jo is safar mein aapke saath hain, ek jagah - aur aap jo bhi recommendation dekhte hain wo kahan se aati hai.');
  String get careCircleWhy => _p(
      'Every recommendation in ParentVeda says who it came from. Trust should be visible, not assumed.',
      'ParentVeda mein har recommendation batati hai ki wo kahan se aayi. Bharosa dikhna chahiye, maana nahi jaana chahiye.');
  String get careCircleEmpty => _p(
      'Only ParentVeda so far. As you add a doctor, a nutritionist or a clinic, they appear here.',
      'Abhi sirf ParentVeda. Jaise-jaise aap doctor, nutritionist ya clinic jodenge, wo yahan dikhenge.');
  String get careCircleAdd => _p('Add someone', 'Kisi ko jodein');
  String get careCirclePartner => _p('Your partner', 'Aapka partner');
  String get careCircleInvite => _p('Not joined yet', 'Abhi juda nahi');
  String get careCircleJoined => _p('Joined', 'Juda hua');

  // ---- products -------------------------------------------------------------
  String get productsTitle => _p('Worth knowing about', 'Jaanne layak');
  String get productsIntro => _p(
      'Research first, buy second - and several of these say plainly that you probably do not need them. Every entry shows what to look for and what to watch out for.',
      'Pehle research, phir kharid - aur inmein se kai saaf kehti hain ki shayad aapko inki zaroorat hi nahi. Har entry batati hai kya dekhna hai aur kis cheez ka dhyaan rakhna hai.');
  String get productsLookFor => _p('What to look for', 'Kya dekhein');
  String get productsWatchOut => _p('What to watch out for', 'Kis baat ka dhyaan');
  String get productsDisclaimer => _p(
      'Nothing is sold here. Prices are indicative Indian ranges so the advice is usable, and no link takes payment.',
      'Yahan kuch becha nahi jaata. Prices Indian andaaze hain taaki salaah kaam ki rahe, aur koi link payment nahi leta.');

  // ---- the transition -------------------------------------------------------
  String get transitionRecord => _p('Record a positive test', 'Positive test record karein');
  String get transitionRecordBody => _p(
      'Whenever it happens, this is where you tell us. Nothing restarts.',
      'Jab bhi ho, yahan bata dijiye. Kuch phir se shuru nahi hoga.');
  String get transitionConfirmTitle =>
      _p('Is the test positive?', 'Kya test positive hai?');
  String get transitionConfirmBody => _p(
      'We will date the pregnancy from your last period, move you into the pregnancy journey, and keep every single thing you have written here. You can undo this.',
      'Hum pregnancy ki ginti aapke aakhri period se karenge, aapko pregnancy ke safar mein le jayenge, aur yahan aapne jo bhi likha hai wo sab rakhenge. Aap ise wapas bhi kar sakti hain.');
  String get transitionYes => _p('Yes, it is positive', 'Haan, positive hai');
  String get transitionNotYet => _p('Not yet', 'Abhi nahi');

  String get transitionTitle =>
      _p('A beautiful new chapter begins', 'Ek khoobsurat naya chapter shuru hota hai');
  String get transitionSubtitle => _p(
      'Nothing here restarts. Everything you built is already where it should be.',
      'Yahan kuch phir se shuru nahi hota. Aapne jo banaya wo pehle se apni jagah par hai.');
  String transitionWeeks(int w) => _p(
      'You are about $w weeks pregnant', 'Aap lagbhag $w hafte pregnant hain');
  String get transitionWhyWeeks => _p(
      'Pregnancy is dated from the first day of your last period, not from conception - which is why a positive test usually lands around week four. It is a convention, not a mistake in the arithmetic.',
      'Pregnancy ki ginti aakhri period ke pehle din se hoti hai, conception se nahi - isiliye positive test aksar chauthe hafte ke aas-paas aata hai. Ye ek convention hai, hisaab ki galti nahi.');
  String get transitionDueDate => _p('Estimated due date', 'Anumaanit due date');
  String get transitionDueDateGuess => _p(
      'We had no period logged, so this is dated from today assuming about four weeks. Your first scan will correct it - and it usually does, for everyone.',
      'Koi period log nahi tha, isliye ye aaj se lagbhag chaar hafte maan kar gini gayi hai. Aapka pehla scan ise theek kar dega - aur wo sabke liye karta hai.');
  String get transitionCarried => _p('What came with you', 'Aapke saath kya aaya');
  String transitionJournal(int n) =>
      _p(n == 1 ? '1 journal entry' : '$n journal entries',
          n == 1 ? '1 journal entry' : '$n journal entries');
  String transitionStory(int n) => _p(
      n == 1 ? '1 moment in your story' : '$n moments in your story',
      n == 1 ? 'Aapki kahani mein 1 lamha' : 'Aapki kahani mein $n lamhe');
  String transitionSupplements(int n) =>
      _p(n == 1 ? '1 supplement' : '$n supplements',
          n == 1 ? '1 supplement' : '$n supplements');
  String transitionCycles(int n) =>
      _p(n == 1 ? '1 cycle logged' : '$n cycles logged',
          n == 1 ? '1 cycle log kiya' : '$n cycles log kiye');
  String get transitionPartner => _p('Your partner, still here', 'Aapka partner, abhi bhi saath');
  String get transitionNext => _p('Book your first appointment', 'Pehli appointment book karein');
  String get transitionUndo => _p('That was a mistake - undo', 'Wo galti thi - wapas karein');
  String get transitionUndone =>
      _p('Undone. You are back where you were.', 'Wapas ho gaya. Aap wahin hain jahan thin.');

  // ---- community ------------------------------------------------------------
  String get communityYourRooms => _p('Your rooms', 'Aapke rooms');
  String get communityRooms => _p('Rooms', 'Rooms');
  String get communityMoreRooms => _p('More rooms', 'Aur rooms');
  String get communityJoin => _p('Join', 'Judein');
  String get communityJoined => _p('Joined', 'Jud gaye');
  String communityMembers(int n) {
    final label = n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';
    return _p('$label members', '$label log');
  }

  String get communityFeed => _p('What people are saying', 'Log kya keh rahe hain');
  String get communityAll => _p('All', 'Sab');
  String get communityComment => _p('Comments', 'Comments');
  String get communityEmptyTitle =>
      _p('Nothing here yet', 'Abhi yahan kuch nahi');
  String get communityEmptyBody => _p(
      'This room is quiet today. Join it and you will see new posts as they arrive.',
      'Aaj ye room shaant hai. Ismein judein, naye posts aate hi dikhenge.');

  // ---- records --------------------------------------------------------------
  String get recordsTitle => _p('Health Records', 'Health Records');
  String get recordsReports => _p('Reports', 'Reports');
  String get recordsIntro => _p(
      'Both of your results, in one place and one date order - so an appointment starts with facts rather than with trying to remember.',
      'Aap dono ke results, ek jagah aur ek kram mein - taaki appointment yaad karne se nahi, jaankari se shuru ho.');
  String get recordsAdd => _p('Add', 'Add karein');
  String get recordsBoth => _p('Both', 'Dono');
  String get recordsLabel => _p('What was it?', 'Kya tha?');
  String get recordsValue => _p('Result (as printed)', 'Result (jaisa likha hai)');
  String get recordsWhose => _p('Whose result', 'Kiska result');
  String get recordsHistory => _p('Earlier results', 'Pehle ke results');
  String get recordsRemove => _p('Remove', 'Hatayein');
  String get recordsEmptyTitle => _p('Nothing added yet', 'Abhi kuch add nahi');
  String get recordsEmptyBody => _p(
      'Add a result the day it arrives, while the paper is still in your hand. A number you can show a doctor beats a memory of how you have been feeling.',
      'Jis din result aaye usi din add karein, jab kaagaz haath mein ho. Jo number aap doctor ko dikha sakein, wo "aisa lag raha tha" se behtar hai.');
  String get recordsDisclaimer => _p(
      'ParentVeda stores what your report said. It never interprets a result - that belongs with your doctor.',
      'ParentVeda wahi rakhta hai jo aapki report mein likha hai. Wo result ka matlab nahi nikaalta - wo aapke doctor ka kaam hai.');

  // ---- appointments ---------------------------------------------------------
  String get appointmentsTitle => _p('Appointments', 'Appointments');
  String get appointmentsIntro => _p(
      'Everything you have booked through ParentVeda and everything you arranged yourselves, on one list in time order.',
      'Jo aapne ParentVeda se book kiya aur jo aapne khud tay kiya - sab ek list mein, samay ke hisaab se.');
  String get appointmentsAdd => _p('Add', 'Add karein');
  String get appointmentsWhat => _p('What is it?', 'Kya hai?');
  String get appointmentsWho => _p('With whom (optional)', 'Kiske saath (optional)');
  String get appointmentsViaParentVeda => _p('Booked in ParentVeda', 'ParentVeda se book');
  String get appointmentsPast => _p('Earlier', 'Pehle');
  String get appointmentsEmptyTitle =>
      _p('Nothing coming up', 'Aage kuch nahi');
  String get appointmentsEmptyBody => _p(
      'Add the clinic visits you arrange yourselves and they will show here and on your calendar.',
      'Jo clinic visits aap khud tay karte hain wo add karein - wo yahan aur calendar par dikhengi.');
  String get appointmentsQuestions =>
      _p('Questions for the doctor', 'Doctor ke liye sawaal');
  String get appointmentsAddQuestion => _p('Add a question', 'Sawaal jodein');
  String get appointmentsNoQuestionsTitle =>
      _p('Nothing saved yet', 'Abhi kuch save nahi');
  String get appointmentsNoQuestionsBody => _p(
      'Write questions down when they occur to you, not in the waiting room. Walking in with the ones you thought of at 2am is most of what makes a short consultation useful.',
      'Sawaal tab likhein jab dimaag mein aayein, waiting room mein nahi. Raat 2 baje jo sawaal aaye the, unke saath jaana hi chhoti consultation ko kaam ka banata hai.');

  // ---- nutrition planner ----------------------------------------------------
  String get nutritionTitle => _p('Nutrition Planner', 'Nutrition Planner');
  String get nutritionIntro => _p(
      'A week of ideas, not a plan to follow. Nothing to tick, nothing to fall off, and every day is for both of you.',
      'Ek hafte ke ideas, koi plan nahi jise nibhana ho. Na kuch tick karna hai, na kuch chhootne ka dar - aur har din aap dono ke liye hai.');
  String get nutritionFocus => _p('What this week leans on', 'Is hafte kis par zor hai');
  String get nutritionWeek => _p('The week ahead', 'Aane wala hafta');
  String get nutritionDisclaimer => _p(
      'General guidance, not a prescribed diet. If you have diabetes, thyroid disease, PCOS or any condition affecting food, plan it with your doctor.',
      'Ye aam salaah hai, koi tay ki hui diet nahi. Agar aapko diabetes, thyroid, PCOS ya khaane se judi koi condition hai, toh doctor ke saath plan karein.');

  // ---- can I...? ------------------------------------------------------------
  String get canITitle => _p('Can I...?', 'Kya main...?');
  String get canIIntro => _p(
      'The everyday worries, settled quickly. While you are trying, the honest answer to most of these is yes.',
      'Rozmarra ki chintaayein, jaldi se saaf. Koshish ke dauraan, inmein se zyadatar ka imaandaar jawab haan hai.');
  String get canISearch => _p('Chai, travel, painkillers...', 'Chai, safar, painkiller...');
  String get canINoneTitle => _p('Not answered here yet', 'Iska jawab abhi yahan nahi');
  String get canINoneBody => _p(
      'If it is worrying you, it is worth asking a doctor rather than the internet - and worth telling us, so it gets added.',
      'Agar ye pareshaan kar raha hai, toh internet se behtar hai doctor se poochhna - aur hume batayein, taaki ise jod dein.');
  String get canIDisclaimer => _p(
      'General information, never a diagnosis. If you have a medical condition or take regular medication, your doctor\'s answer replaces this one.',
      'Aam jaankari hai, diagnosis nahi. Agar aapko koi medical condition hai ya aap regular dawai lete hain, toh doctor ka jawab isse upar hai.');

  // ---- clinic-led cycles ----------------------------------------------------
  //  Shown instead of a calendar fertility reading on IVF / IUI / ovulation
  //  induction / FET. The tone is deferring, not apologising - we are not
  //  failing to calculate, we are declining to guess over a doctor.
  String get clinicLedTitle =>
      _p('Your clinic is running this cycle', 'Ye cycle aapki clinic chala rahi hai');
  String get clinicLedBody => _p(
      'On this path ovulation is triggered and tracked by scan, so a calendar estimate could disagree with what your clinic told you. Their dates are the ones that count - we will not put a second set of numbers next to them.',
      'Is raaste par ovulation trigger se hota hai aur scan se dekha jaata hai, isliye calendar ka andaaza aapki clinic ki baat se alag ho sakta hai. Unki dates hi asli hain - hum unke saath doosre numbers nahi rakhenge.');
  String get clinicLedStillUseful => _p(
      'Everything else still works. Keep logging periods, symptoms and results - your clinic will ask for exactly this.',
      'Baaki sab chalta rahega. Periods, symptoms aur results log karti rahein - aapki clinic yahi poochhegi.');

  /// Replaces the confidence phrase wherever a clinic owns the timing.
  ///
  /// A confidence line is a statement about OUR estimate. Showing one after we
  /// have just said we defer to the clinic tells her both things at once, and
  /// the quieter contradiction is the one that erodes trust.
  String get clinicGuidingTiming => _p('Your clinic is guiding the timing here',
      'Timing yahan aapki clinic tay kar rahi hai');
  String clinicLedPath(String path) =>
      _p('You told us: $path', 'Aapne bataya: $path');
  String get clinicLedChange =>
      _p('Change your path', 'Apna raasta badlein');

  // ---- writing a post -------------------------------------------------------
  String get communityWrite => _p('Write something', 'Kuch likhein');
  String get communityWriteTitle => _p('Say it here', 'Yahan kehiye');
  String get communityWriteHint => _p(
      'A question, or something you wish someone had told you',
      'Koi sawaal, ya wo baat jo kaash koi aapko pehle bata deta');
  String get communityPickRoom => _p('Which room?', 'Kaunsa room?');
  String get communityPost => _p('Post', 'Post karein');
  String get communityPosted => _p('Posted', 'Post ho gaya');
  String get communityAnonymous => _p('Post without my name', 'Mere naam ke bina');
  String get communityAnonymousNote => _p(
      'Some of this is hard to say with your name on it. That is allowed here.',
      'Kuch baatein apne naam ke saath kehna mushkil hota hai. Yahan wo theek hai.');

  // ---- treatment cycle ------------------------------------------------------
  String get treatmentTitle => _p('Your treatment cycle', 'Aapka treatment cycle');
  String get treatmentIntro => _p(
      'The dates your clinic gave you. We do not calculate these - they chose them, and theirs are the ones that count. Fill in what you know; the rest can wait.',
      'Wo dates jo aapki clinic ne di. Hum inhe calculate nahi karte - unhone tay ki hain, aur unki hi chalti hai. Jo pata hai wo bhar dein; baaki baad mein.');
  String get treatmentNext => _p('Next', 'Agla');
  String get treatmentDates => _p('Your dates', 'Aapki dates');
  String get treatmentNotSet => _p('Not added yet', 'Abhi add nahi kiya');
  String get treatmentAddDates =>
      _p('Add the dates your clinic gave you', 'Clinic ki di hui dates add karein');
  String get treatmentAddDatesBody => _p(
      'Then we can remind you about the trigger shot and count to your blood test instead of guessing at a period.',
      'Phir hum trigger shot ki yaad dila payenge aur period ka andaaza lagane ke bajaye blood test tak gin payenge.');
  String get treatmentTriggerTime => _p('What time exactly?', 'Theek kitne baje?');
  String get treatmentTriggerReminder => _p(
      'We will remind you two hours before the trigger shot.',
      'Trigger shot se do ghante pehle hum yaad dila denge.');
  String get treatmentClear => _p('Clear this cycle', 'Ye cycle hata dein');
  String get treatmentClearBody => _p(
      'Use this when a round ends, so the next one starts clean. Nothing else is deleted.',
      'Jab ek round khatam ho tab ye istemaal karein, taaki agla saaf shuru ho. Aur kuch nahi hatega.');
  String get treatmentDisclaimer => _p(
      'These are the dates you entered from your clinic. ParentVeda never changes them and never adds one of its own - if anything here disagrees with your clinic, your clinic is right.',
      'Ye wahi dates hain jo aapne clinic se li hain. ParentVeda inhe kabhi nahi badalta aur apni taraf se koi nahi jodta - agar yahan kuch aapki clinic se alag lage, toh clinic sahi hai.');

  String get betaWaitTitle => _p('Until your blood test', 'Blood test tak');
  String betaWaitDays(int days) => _p(
      days <= 0 ? 'Today' : (days == 1 ? 'Tomorrow' : 'in $days days'),
      days <= 0 ? 'Aaj' : (days == 1 ? 'Kal' : '$days din mein'));
  String get betaWaitNote => _p(
      'A home test before this can read wrong because of the trigger shot. The blood test is the real answer.',
      'Isse pehle ghar ka test trigger shot ki wajah se galat aa sakta hai. Blood test hi asli jawab hai.');

  // ---- the two pathway questions --------------------------------------------
  //  The only two facts that separate "letrozole, time it yourself" from
  //  "letrozole, scans and a trigger". Genuinely unknowable to us, so the
  //  product is allowed to ask - and asking is what stops us over-correcting.
  String get pathwayQuestionsTitle =>
      _p('Two questions about this cycle', 'Is cycle ke baare mein do sawaal');
  String get pathwayQuestionsWhy => _p(
      'The same treatment works differently depending on these, and they decide whether we can help with timing at all. If you are not sure, leave them — we assume the safer answer.',
      'Ek hi treatment inke hisaab se alag chalta hai, aur inhi se tay hota hai ki hum timing mein madad kar sakte hain ya nahi. Pata na ho toh chhod dein - hum surakshit jawab maan lete hain.');
  /// Asks the PRINCIPLE, not a clinical event.
  ///
  /// This used to ask about scans and blood tests, which is a proxy: a clinic
  /// can be deciding the dates without either. The examples underneath do the
  /// work of recognition, so she does not have to translate her cycle into our
  /// vocabulary.
  String get pathwayQMonitor => _p(
      'Is your fertility clinic deciding the important dates for this cycle?',
      'Kya aapki fertility clinic is cycle ki ahem tareekhein tay kar rahi hai?');
  String get pathwayQMonitorEg => _p(
      'Scans or blood tests · a trigger injection · IUI timing · egg retrieval · embryo transfer',
      'Scan ya blood test · trigger injection · IUI ki timing · egg retrieval · embryo transfer');

  /// The second question separates GUIDED from CONTROLLED, which decides
  /// whether her own body signals still mean anything.
  ///
  /// Deliberately not "have you had a trigger injection". A trigger is one
  /// route to the same place, and a fully medicated transfer has no trigger at
  /// all - so asking about the injection would let a medicated cycle answer no.
  String get pathwayQMedicated => _p(
      'Has medication taken over WHEN ovulation or transfer happens — an injection that sets the hour, or a fully medicated schedule?',
      'Kya dawai ne tay kar liya hai ki ovulation ya transfer KAB hoga — koi injection jo waqt tay karta hai, ya poori tarah medicated schedule?');
  String get pathwayQMedicatedEg => _p(
      'If your own body still decides the day, answer no.',
      'Agar din abhi bhi aapka apna body tay karta hai, toh nahi chunein.');
  String get pathwayYes => _p('Yes', 'Haan');
  String get pathwayNo => _p('No', 'Nahi');
  String get pathwayNotSure => _p('Not sure', 'Pata nahi');
  String get pathwayAnswerCta =>
      _p('Answer two questions', 'Do sawaal ka jawab dein');
  String get pathwayAnswerBody => _p(
      'It takes a moment, and it may turn your fertile window back on.',
      'Ek pal lagega, aur ho sakta hai aapki fertile window wapas aa jaye.');

  /// The one disclaimer, in one place.
  ///
  /// It used to live privately inside the cycle tools, which meant the screen
  /// with the most traffic and the least reliable number - Today - carried no
  /// caveat at all.
  String get estimatesDisclaimer => _p(
      'These are estimates, never guarantees. If your cycles change, stop, or you are worried, talk to a doctor.',
      'Ye andaaze hain, guarantee nahi. Agar aapke cycles badalte hain, periods band hain ya aap chinta mein hain, toh doctor se baat karein.');

  // ---- the hero's position line ---------------------------------------------
  /// "Day 3 of 28" - position WITHIN the chapter, never "chapter 1 of 5".
  /// A denominator across the whole stage would promise a finish line that
  /// chapters 2-4 do not have, since they come round with every cycle.
  String dayOfChapter(int day, int length) => hinglish
      ? 'Is chapter ka din $day / $length'
      : 'Day $day of $length in this chapter';

  String get journeyMapLink => _p('Journey map', 'Journey map');

  /// The way out of the rhythm card, which used to route nowhere.
  String get understandThis => _p('Understand this', 'Ye samjhein');

  // ---- profile --------------------------------------------------------------
  String get profileTitle => _p('Profile', 'Profile');
  String get profileLanguage => _p('Language', 'Bhasha');
  String get profileEnglish => _p('English', 'English');
  String get profileHinglish => _p('Hinglish', 'Hinglish');
  String get profileSignOut => _p('Sign out', 'Sign out');
  String get profileSignOutBody => _p(
      'You will be asked to sign in again. Nothing you have logged is deleted.',
      'Aapko dobara sign in karna hoga. Aapka logged data delete nahi hota.');

  /// The partner half, named honestly. Pairing is not built yet, so this says
  /// what is true rather than offering a button that does nothing.
  String get profilePartner => _p('Your partner', 'Aapka partner');
  String get profilePartnerSoon => _p(
      'Pairing his phone to this journey is being built. For now the Her / Him switch on Today shows you both sides.',
      'Unke phone ko is journey se jodna abhi ban raha hai. Filhaal Today par Her / Him switch se dono taraf dikhti hai.');

  /// Testing only, and labelled so - exactly like the pregnancy Profile's
  /// "Reset to Week 20 - testing" and "Enter doctor mode - testing".
  String get profileStageSwitch =>
      _p('Switch stage · testing', 'Stage badlein · testing');
  String get profileStageSwitchBody => _p(
      'Moves the app to the pregnancy shell. Real families move by recording a positive test, never by a switch.',
      'App ko pregnancy shell par le jaata hai. Asli families positive test record karke aage badhti hain, switch se nahi.');
  String get profileGoPregnancy =>
      _p('Go to pregnancy', 'Pregnancy par jaayein');

  // ---- shared chrome --------------------------------------------------------
  String get seeAll => _p('See all', 'Sab dekhein');
  String get comingSoon => _p('Coming soon', 'Jald aa raha hai');
  String get openTools => _p('Open Tools', 'Tools kholein');

  /// On every Tools tile. The card was already tappable and nothing said so -
  /// the pregnancy hub has carried an explicit "Open →" all along.
  String get openTool => _p('Open', 'Kholein');

  /// Used by every section that is genuinely not built yet. Honest wording -
  /// "we are building this", never a dead button pretending to work.
  String get beingBuilt => _p('We are building this', 'Hum ise bana rahe hain');

  // ---- the five chapters' section names (Prepare / Tools / etc.) ------------
  String get prepareTitle => _p('Prepare for conception', 'Conception ki taiyaari');
  String get prepareBody => _p(
      'Consultations, courses, fertility yoga, nutrition and mental wellness - the things that make you healthier parents, whenever it happens.',
      'Consultations, courses, fertility yoga, nutrition aur mental wellness - jo aapko behtar parents banate hain, jab bhi ho.');

  String get toolsTitle => _p('Tools that help, never judge', 'Tools jo madad karte hain, judge nahi');
  String get toolsBody => _p(
      'Your cycle, ovulation, supplements, tests, sleep, mood and reports - each one optional, each one yours.',
      'Aapka cycle, ovulation, supplements, tests, neend, mood aur reports - har ek optional, har ek aapka.');

  /// Was "Your command centre" - a cold, corporate phrase sitting in a stage
  /// whose every other headline is warm.
  String get calendarTitle =>
      _p('Everything, in one place', 'Sab kuch, ek jagah');

  // ---- the fertile window summary -------------------------------------------
  //  The screen used to open with the whole cycle laid out a day at a time -
  //  fifty-four rows on real data, of which seven carried information and the
  //  rest said "Low". The one sentence she came for was never stated.

  String get windowYourDays => _p('Your fertile days', 'Aapke fertile din');
  String windowRange(String from, String to) =>
      hinglish ? '$from se $to' : '$from to $to';
  String get windowPeakDay => _p('Most likely', 'Sabse zyada mauka');
  String get windowOpenNow => _p('Open now', 'Abhi khuli hai');
  String windowOpensIn(int days) => hinglish
      ? days == 1
          ? 'Kal khulti hai'
          : '$days din mein khulti hai'
      : days == 1
          ? 'Opens tomorrow'
          : 'Opens in $days days';
  String get windowClosed =>
      _p('This cycle\'s window has passed', 'Is cycle ki window nikal gayi');

  /// The whole cycle, kept but folded away.
  String get windowSeeWhole =>
      _p('See the whole cycle', 'Poora cycle dekhein');
  String get windowHideWhole => _p('Hide the whole cycle', 'Poora cycle chhupayein');

  /// Shown under the grid when the fertile run does not fit in this month.
  String continuesInto(String month) => hinglish
      ? 'Ye fertile window $month tak jaati hai'
      : 'This fertile window continues into $month';
  String continuedFrom(String month) => hinglish
      ? 'Ye fertile window $month se chali aa rahi hai'
      : 'This fertile window began in $month';
  String get calendarBody => _p(
      'Everything in one place: your cycle, appointments, supplements, tests and the moments you write down.',
      'Sab kuch ek jagah: aapka cycle, appointments, supplements, tests aur wo lamhe jo aap likhti hain.');

  String get communityTitle => _p('You are not the only one', 'Aap akeli nahi hain');
  String get communityBody => _p(
      'Rooms for trying naturally, PCOS, endometriosis, IVF, male fertility and emotional support - calm, never competitive.',
      'Trying naturally, PCOS, endometriosis, IVF, male fertility aur emotional support ke rooms - shaant, kabhi competitive nahi.');

  // ---- the doorway ----------------------------------------------------------
  String get doorTitle => _p('Trying to conceive', 'Conceive karne ki koshish');
  String get doorBody => _p('Planning a baby? Start the journey here',
      'Baby plan kar rahe hain? Safar yahin se shuru');
}
